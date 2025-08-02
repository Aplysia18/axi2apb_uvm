`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class AXI_master_driver extends uvm_driver #(AXI_transfer);

  virtual interface AXI_master_vif   m_vif;
  AXI_master_conf             m_conf;
  AXI_transfer                m_wr_queue[$];
  AXI_transfer                m_rd_queue[$];
  int unsigned                m_num_sent;

  int unsigned                m_wr_addr_indx = 0;
  int unsigned                m_wr_data_indx = 0;

  int unsigned                m_rd_addr_indx = 0;

	// reserve fields
	`uvm_component_utils_begin(AXI_master_driver)
		`uvm_field_int		(m_num_sent,			UVM_ALL_ON)
	`uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    // Create the TLM port
    // item_collected_port = new("item_collected_port", this);
  endfunction : new

  // Additional class methods
  extern virtual function void assign_vi(virtual interface AXI_master_vif vif);
  extern virtual function void assign_conf(AXI_master_conf conf);

  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

  extern virtual protected task get_and_drive();
  extern virtual protected task drive_transfer(AXI_transfer trx);
 // extern virtual function void report();

  extern virtual task sent_addr_write_trx();
  extern virtual task sent_data_write_trx();
  extern virtual task received_resp_write_trx();

  extern virtual task sent_addr_read_trx();
  extern virtual task received_data_read_trx();

  extern virtual task cleanup_on_reset();
  extern virtual protected task reset_signals();

endclass : AXI_master_driver

function void AXI_master_driver::assign_vi(virtual interface AXI_master_vif vif);
  m_vif = vif;
endfunction


function void AXI_master_driver::assign_conf(AXI_master_conf conf);
  m_conf = conf;
endfunction


//UVM connect_phase
function void AXI_master_driver::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if (!uvm_config_db#(virtual interface AXI_master_vif)::get(this, "", "AXI_master_vif", m_vif))
   `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".m_vif"})

  assert(m_conf!=null);
//  if (!uvm_config_db#(AXI_master_conf)::get(this, "", "m_conf", m_conf))
//    `uvm_error("NOCONF",{"axi conf must be set for: ", get_full_name(), ".m_conf"})

endfunction : connect_phase


// UVM run() phase spawn sub events
task AXI_master_driver::run_phase(uvm_phase phase);
  forever begin

    // wait for reset deassert
    @(posedge m_vif.AXI_ARESET_N);
    `uvm_info(get_type_name(), "Reset dropped, starting driver", UVM_MEDIUM)

    //normal driver
    fork
      get_and_drive();
      sent_addr_write_trx();
      sent_data_write_trx();
      received_resp_write_trx();
      sent_addr_read_trx();
      received_data_read_trx();
    join_none
    
    // wait for reset assert
    @(negedge m_vif.AXI_ARESET_N);
    `uvm_info(get_type_name(), "Reset asserted, stopping driver", UVM_MEDIUM)
    disable fork;

    cleanup_on_reset();
  end
endtask : run_phase


// Gets transfers from the sequencer and passes them to the driver.
task AXI_master_driver::get_and_drive();
    forever begin
      seq_item_port.get_next_item(req);
      drive_transfer(req);
      seq_item_port.item_done();
		end
endtask : get_and_drive

// Gets a transfer and drive it into the DUT
// push the trx to trx async queue
task AXI_master_driver::drive_transfer(AXI_transfer trx);

    `uvm_info(get_type_name(), $psprintf("Driving \n%s", trx.sprint()), UVM_HIGH)

    if (trx.rw == READ) begin
        m_rd_queue.push_back(trx);

    end else if (trx.rw == WRITE) begin
        m_wr_queue.push_back(trx);
		//$display("DDDDDDDDDDDDDDDD");
		//trx.print();
    end else begin
      `uvm_error("NOTYPE",{"type not support"})
    end

    m_num_sent++;
    `uvm_info(get_type_name(), $psprintf("Item %0d Sent ...", m_num_sent), UVM_HIGH)

endtask : drive_transfer


// addr write trx task by event_sent_write_trx.trigger
task AXI_master_driver::sent_addr_write_trx();
    AXI_transfer m_trx;

    forever begin
      // if write trx has existed...
      repeat(m_wr_queue.size()==0) @m_vif.drv_cb;

      if (m_wr_addr_indx < m_wr_queue.size()) begin
          m_trx = m_wr_queue[m_wr_addr_indx];

          repeat(m_trx.addr_wt_delay) @m_vif.drv_cb;
          // sent trx
          `delay(m_conf.half_cycle);
          m_vif.drv_cb.AXI_AWVALID <= 1'b1;
          m_vif.drv_cb.AXI_AWID    <= m_trx.id;
          m_vif.drv_cb.AXI_AWADDR  <= m_trx.addr;
          m_vif.drv_cb.AXI_AWREG   <= m_trx.region;
          m_vif.drv_cb.AXI_AWLEN   <= m_trx.len;
          m_vif.drv_cb.AXI_AWSIZE  <= m_trx.size;
          m_vif.drv_cb.AXI_AWBURST <= m_trx.burst;
          m_vif.drv_cb.AXI_AWLOCK  <= m_trx.lock;
          m_vif.drv_cb.AXI_AWCACHE <= m_trx.cache;
          m_vif.drv_cb.AXI_AWPROT  <= m_trx.prot;
          m_vif.drv_cb.AXI_AWQOS   <= m_trx.qos;
          @m_vif.drv_cb;

          // hold until AWREADY received
          while (!m_vif.drv_cb.AXI_AWREADY) @m_vif.drv_cb;

          // free trx
          `delay(m_conf.half_cycle);
          m_vif.drv_cb.AXI_AWVALID <= 1'b0;
          m_trx.addr_done = `TRUE;
          @m_vif.drv_cb;

          m_wr_addr_indx += 1;

      end else begin
        @m_vif.drv_cb;
      end
    end

endtask : sent_addr_write_trx


// data write trx task by event_sent_write_trx.trigger
task AXI_master_driver::sent_data_write_trx();
    int unsigned  i = 0;
    AXI_transfer  m_trx;

    forever begin

      repeat(m_wr_queue.size()==0) @m_vif.drv_cb;

      if (m_wr_data_indx < m_wr_queue.size()) begin
          m_trx = m_wr_queue[m_wr_data_indx];

          repeat(m_trx.data_wt_delay) @m_vif.drv_cb;

          // sent trx
          while (i<=m_trx.len) begin

            `delay(m_conf.half_cycle);
            m_vif.drv_cb.AXI_WVALID  <= 1'b1;
            m_vif.drv_cb.AXI_WDATA   <= m_trx.data[i];
            m_vif.drv_cb.AXI_WSTRB   <= m_trx.strb[i];
            m_vif.drv_cb.AXI_WID     <= m_trx.id;
            m_vif.drv_cb.AXI_WLAST   <= (i==m_trx.len)? 1'b1 : 1'b0;
            @m_vif.drv_cb;
            if (m_vif.drv_cb.AXI_WREADY && m_vif.mon_cb.AXI_WVALID)
              i = i+1;
          end

          // hold until all finish

          // free trx
          `delay(m_conf.half_cycle);
          m_vif.drv_cb.AXI_WVALID <= 1'b0;
          m_vif.drv_cb.AXI_WLAST  <= 1'b0;
          i = 0;
          m_trx.data_done = `TRUE;
          @m_vif.drv_cb;

          m_wr_data_indx += 1;

        end else begin
          @m_vif.drv_cb;
        end
      end

endtask : sent_data_write_trx


// data resp trx collect resp to trx
task AXI_master_driver::received_resp_write_trx();

  forever begin
	if(1 == $urandom_range(3))
		m_vif.drv_cb.AXI_BREADY <= 1'b1;
	else
		m_vif.drv_cb.AXI_BREADY <= 1'b0;

	repeat($urandom_range(3)) @m_vif.drv_cb;
    // hold until BVALID received
    while(!m_vif.drv_cb.AXI_BVALID) @m_vif.drv_cb;
  end

endtask : received_resp_write_trx


// addr read trx
task AXI_master_driver::sent_addr_read_trx();
    AXI_transfer m_trx;

    forever begin

      repeat(m_rd_queue.size()==0) @m_vif.drv_cb;

      if (m_rd_addr_indx < m_rd_queue.size()) begin
          m_trx = m_rd_queue[m_rd_addr_indx];

          repeat(m_trx.addr_rd_delay) @m_vif.drv_cb;

          // sent trx
          `delay(m_conf.half_cycle);
          m_vif.drv_cb.AXI_ARVALID <= 1'b1;
          m_vif.drv_cb.AXI_ARID    <= m_trx.id;
          m_vif.drv_cb.AXI_ARADDR  <= m_trx.addr;
          m_vif.drv_cb.AXI_ARREG   <= m_trx.region;
          m_vif.drv_cb.AXI_ARLEN   <= m_trx.len;
          m_vif.drv_cb.AXI_ARSIZE  <= m_trx.size;
          m_vif.drv_cb.AXI_ARBURST <= m_trx.burst;
          m_vif.drv_cb.AXI_ARLOCK  <= m_trx.lock;
          m_vif.drv_cb.AXI_ARCACHE <= m_trx.cache;
          m_vif.drv_cb.AXI_ARPROT  <= m_trx.prot;
          m_vif.drv_cb.AXI_ARQOS   <= m_trx.qos;
          @m_vif.drv_cb;
          // hold until ARREADY received
          while(!m_vif.drv_cb.AXI_ARREADY) @m_vif.drv_cb;
          //void'(m_rd_queue.pop_front());
          // free trx
         `delay(m_conf.half_cycle);
         m_vif.drv_cb.AXI_ARVALID <= 1'b0;
         @m_vif.drv_cb;

         m_rd_addr_indx += 1;

      end else begin
        @m_vif.drv_cb;
      end
    end

endtask : sent_addr_read_trx


// data read trx
task AXI_master_driver::received_data_read_trx();

  forever begin
	if(1 == $urandom_range(3))
		m_vif.drv_cb.AXI_RREADY <= 1'b0;
	else
		m_vif.drv_cb.AXI_RREADY <= 1'b1;

	@m_vif.drv_cb;
     // hold until RVALID received
     while(!m_vif.drv_cb.AXI_RVALID) @m_vif.drv_cb;
  end

endtask : received_data_read_trx

task AXI_master_driver::cleanup_on_reset();
  `uvm_info(get_type_name(), "Cleaning up on reset", UVM_MEDIUM)
  // Reset all queues
  m_wr_queue.delete();
  m_rd_queue.delete();
  m_wr_addr_indx = 0;
  m_wr_data_indx = 0;
  m_rd_addr_indx = 0;

  // Reset counters
  m_num_sent = 0;

  // Reset signals
  reset_signals();

endtask : cleanup_on_reset

// Reset all master signals
task AXI_master_driver::reset_signals();
    m_vif.drv_cb.AXI_AWID    <= 0; 
    m_vif.drv_cb.AXI_AWADDR  <= 0; 
    m_vif.drv_cb.AXI_AWREG   <= 0; 
    m_vif.drv_cb.AXI_AWLEN   <= 0; 
    m_vif.drv_cb.AXI_AWSIZE  <= 0; 
    m_vif.drv_cb.AXI_AWBURST <= 0; 
    m_vif.drv_cb.AXI_AWLOCK  <= 0; 
    m_vif.drv_cb.AXI_AWCACHE <= 0; 
    m_vif.drv_cb.AXI_AWPROT  <= 0; 
    m_vif.drv_cb.AXI_AWQOS   <= 0; 
    m_vif.drv_cb.AXI_AWVALID <= 0; 
    m_vif.drv_cb.AXI_WID     <= 0; 
    m_vif.drv_cb.AXI_WDATA   <= 0; 
    m_vif.drv_cb.AXI_WSTRB   <= 0; 
    m_vif.drv_cb.AXI_WVALID  <= 0; 
    m_vif.drv_cb.AXI_WLAST   <= 0; 
    m_vif.drv_cb.AXI_BREADY  <= 0; 
    m_vif.drv_cb.AXI_ARID    <= 0; 
    m_vif.drv_cb.AXI_ARADDR  <= 0; 
    m_vif.drv_cb.AXI_ARREG   <= 0; 
    m_vif.drv_cb.AXI_ARLEN   <= 0; 
    m_vif.drv_cb.AXI_ARSIZE  <= 0; 
    m_vif.drv_cb.AXI_ARBURST <= 0; 
    m_vif.drv_cb.AXI_ARLOCK  <= 0; 
    m_vif.drv_cb.AXI_ARCACHE <= 0; 
    m_vif.drv_cb.AXI_ARPROT  <= 0; 
    m_vif.drv_cb.AXI_ARQOS   <= 0; 
    m_vif.drv_cb.AXI_ARVALID <= 0; 
    m_vif.drv_cb.AXI_RREADY  <= 0;
endtask : reset_signals


`endif // AXI_MASTER_DRIVER_SV


