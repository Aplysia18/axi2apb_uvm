
`ifndef AXI_SLAVE_MONITOR_SV
`define AXI_SLAVE_MONITOR_SV

class AXI_slave_monitor extends uvm_monitor;

  virtual interface AXI_slave_vif   m_vif;
  AXI_slave_conf              m_conf;

  // cycle count
  longint                     m_cycle;

  // Count transfers collected
  int           m_num_col;

  // trx stored queue
  AXI_queue     m_wr_queue;
  AXI_queue     m_rd_queue;

  //virtual write_id
  int unsigned  vir_write_addr_id = 0;
  int unsigned  vir_write_data_id = 0;
  int unsigned  vir_write_resp_id = 0;
  int unsigned  vir_read_addr_id = 0;
  int unsigned  vir_read_data_id = 0;

  // trx map table
  AXI_mem_map   m_mem_map;

  // The following two bits are used to control whether checks and coverage are
  // done in the monitor
  bit checks_enable   = 0;
  bit coverage_enable = 1;

  // The current AXI_transfer
  protected AXI_transfer trans_collected;

  // This TLM port is used to connect the monitor to the scoreboard
  uvm_analysis_port #(AXI_transfer) item_write_collected_port;
  uvm_analysis_port #(AXI_transfer) item_read_collected_port;

  // This TLM port is used to connect the monitor to driver, that can help driver to identify
  // the trx mapping table based on trx's ID...
  uvm_analysis_port #(AXI_transfer) item_write_port;
  uvm_analysis_port #(AXI_transfer) item_read_port;

  /*--------------------------------
  // Covergroup for transfer
  ----------------------------------*/
  covergroup slave_transfer_cg;
    TRANS_ADDR : coverpoint trans_collected.addr {
      bins ZERO     = {0};
      bins NON_ZERO = {[1:8'hff]};
    }
    TRANS_DIRECTION : coverpoint trans_collected.rw {
      bins READ   = {READ};
      bins WRITE  = {WRITE};
    }
    TRANS_LEN : coverpoint trans_collected.len {

    }
    TRANS_SIZE : coverpoint trans_collected.size {
    }

//    TRANS_DATA : coverpoint trans_collected.data {
//      bins ZERO     = {0};
//      bins NON_ZERO = {[1:8'hff]};
//    }
    TRANS_ADDR_X_TRANS_DIRECTION: cross TRANS_ADDR, TRANS_DIRECTION;
  endgroup : slave_transfer_cg

  // Provide UVM automation and utility methods
  `uvm_component_utils_begin(AXI_slave_monitor)
    `uvm_field_int  (m_num_col,       UVM_DEFAULT)
    `uvm_field_int  (checks_enable,   UVM_ALL_ON)
    `uvm_field_int  (coverage_enable, UVM_ALL_ON)
  `uvm_component_utils_end


  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);

    // Create the covergroup
    slave_transfer_cg = new();
    slave_transfer_cg.set_inst_name("slave_transfer_cg");

    // Create the TLM port
    item_write_collected_port = new("item_write_collected_port", this);
    item_read_collected_port = new("item_read_collected_port", this);

    item_write_port   = new("item_write_port", this);
    item_read_port   = new("item_read_port", this);

    // wr/rd queue
    m_wr_queue = new();
    m_rd_queue = new();

    // mem map
    m_mem_map = new();

  endfunction : new

  // Additional class methods
  extern virtual function void assign_vi(virtual interface AXI_slave_vif vif);
  extern virtual function void assign_conf(AXI_slave_conf conf);

  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual protected task collect_write_transfer();
  extern virtual protected task collect_read_transfer();
  extern virtual protected task perform_write_checks();
  extern virtual protected task perform_read_checks();
  extern virtual protected task perform_write_coverage();
  extern virtual protected task perform_read_coverage();
  extern virtual function void report();

  extern virtual protected task collect_addr_write_trx();
  extern virtual protected task collect_data_write_trx();
  extern virtual protected task collect_resp_write_trx();
  extern virtual protected task collect_addr_read_trx();
  extern virtual protected task collect_data_read_trx();

  extern virtual protected task collect_cycle_count();

endclass : AXI_slave_monitor


function void AXI_slave_monitor::assign_vi(virtual interface AXI_slave_vif vif);
  m_vif = vif;
endfunction : assign_vi


function void AXI_slave_monitor::assign_conf(AXI_slave_conf conf);
  m_conf = conf;
endfunction : assign_conf


//UVM connect_phase
function void AXI_slave_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if (!uvm_config_db#(virtual AXI_slave_vif)::get(this, "", "AXI_slave_vif", m_vif))
   `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

  assert(m_conf!=null);
//  if (!uvm_config_db#(AXI_slave_conf)::get(this, "", "m_conf", m_conf))
//    `uvm_error("NOCONF",{"axi conf must be set for: ", get_full_name(), ".m_conf"})
endfunction : connect_phase

// UVM run() phase
task AXI_slave_monitor::run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "sssss", UVM_MEDIUM)
  fork
    collect_cycle_count();
    collect_write_transfer();
    collect_read_transfer();
  join
endtask : run_phase


/***************************************************************************
 IVB-NOTE : REQUIRED : slave Monitor : Monitors
 -------------------------------------------------------------------------
 Modify the collect_transfers() method to match your protocol.
 Note that if you change/add signals to the physical interface, you must
 also change this method.
 ***************************************************************************/

task AXI_slave_monitor::collect_cycle_count();
  forever begin
    @m_vif.mon_cb;
    m_cycle += 1;
  end
endtask : collect_cycle_count


task AXI_slave_monitor::collect_write_transfer();
  fork
    collect_addr_write_trx();
    collect_data_write_trx();
    collect_resp_write_trx();

    if (checks_enable)
       perform_write_checks();
    if (coverage_enable)
       perform_write_coverage();
  join
endtask : collect_write_transfer


task AXI_slave_monitor::collect_read_transfer();
  fork
    collect_addr_read_trx();
    collect_data_read_trx();

    if (checks_enable)
      perform_read_checks();
    if (coverage_enable)
      perform_read_coverage();
  join
endtask : collect_read_transfer


// collect addr write @ pos edge
task AXI_slave_monitor::collect_addr_write_trx();
    AXI_transfer t_trx;

    // check write pool, if the W(id) is not found,then create a new one
    // and recored it's timing

    forever begin
        @(posedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_AWVALID == 1'b1 &&
                                      m_vif.mon_cb.AXI_AWREADY == 1'b1));

         //if (!m_wr_queue.fd_queued(m_vif.mon_cb.AXI_AWID)) begin
         //    m_wr_queue.en_queued(m_vif.mon_cb.AXI_AWID);
         if (!m_wr_queue.fd_queued(vir_write_addr_id)) begin
             m_wr_queue.en_queued(vir_write_addr_id);
             t_trx = m_wr_queue.peak_trx();
             t_trx.begin_cycle = m_cycle;
             t_trx.begin_time  = $time;
             void'(begin_tr(t_trx, {$psprintf("axi_slave_monitor[%h]", this)}));
         end

         if (m_conf.start_addr > m_vif.mon_cb.AXI_AWADDR || m_conf.end_addr < m_vif.mon_cb.AXI_AWADDR)
            `uvm_error("NOADDRMATCH", {$psprintf("AWADDR %h is not found in [%h:%h]",
                                      m_vif.mon_cb.AXI_AWADDR,
                                      m_conf.start_addr,
                                      m_conf.end_addr), get_full_name()})

         t_trx         = m_wr_queue.peak_trx();
         t_trx.rw      = WRITE;
         t_trx.addr    = dec_addr  (m_vif.mon_cb.AXI_AWADDR);
         t_trx.id      = dec_id    (m_vif.mon_cb.AXI_AWID);
         t_trx.region  = dec_region(m_vif.mon_cb.AXI_AWREG);
         t_trx.len     = dec_len   (m_vif.mon_cb.AXI_AWLEN);
         t_trx.size    = dec_byte  (m_vif.mon_cb.AXI_AWSIZE);
         t_trx.burst   = dec_burst (m_vif.mon_cb.AXI_AWBURST);
         t_trx.lock    = dec_lock  (m_vif.mon_cb.AXI_AWLOCK);
         t_trx.cache   = dec_cache (m_vif.mon_cb.AXI_AWCACHE);
         t_trx.prot    = dec_prot  (m_vif.mon_cb.AXI_AWPROT);
         t_trx.qos     = dec_qos   (m_vif.mon_cb.AXI_AWQOS);

		vir_write_addr_id++;
        `uvm_info(get_type_name(), $psprintf("collected write addr addr : %h, len : %h", t_trx.addr, t_trx.len), UVM_MEDIUM)

         // extend trx
         m_mem_map.run(t_trx);
         t_trx.mem_addrs = m_mem_map.addrs;
         t_trx.mem_datas = m_mem_map.datas;
         m_mem_map.clear();

         t_trx.itype = SLAVE;
         t_trx.slave = get_full_name();

         t_trx.addr_done = `TRUE;

        if ((t_trx.addr_done == `TRUE) && (t_trx.data_done == `TRUE))
            item_write_port.write(t_trx); // call back to slave driver
    end

endtask : collect_addr_write_trx


// collect data write @ pos edge
task AXI_slave_monitor::collect_data_write_trx();
    AXI_transfer t_trx;

    // check write pool, if the W(id) is not found, create a new one
    // and recored it's timing

    forever begin
        @(posedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_WVALID == 1'b1 &&
                                     m_vif.mon_cb.AXI_WREADY == 1'b1));

        //if (!m_wr_queue.fd_queued(m_vif.mon_cb.AXI_WID)) begin
        //    m_wr_queue.en_queued(m_vif.mon_cb.AXI_WID);
        if (!m_wr_queue.fd_queued(vir_write_data_id)) begin
            m_wr_queue.en_queued(vir_write_data_id);
            t_trx = m_wr_queue.peak_trx();
            t_trx.begin_cycle = m_cycle;
            t_trx.begin_time  = $time;
            void'(begin_tr(t_trx, {$psprintf("axi_slave_monitor[%h]", this)}));
        end

        t_trx = m_wr_queue.peak_trx();
        t_trx.data.push_back( dec_data(m_vif.mon_cb.AXI_WDATA) );
        t_trx.strb.push_back( dec_strb(m_vif.mon_cb.AXI_WSTRB) );
        t_trx.used_cycle = t_trx.used_cycle + 1;

        if (m_vif.mon_cb.AXI_WLAST == 1'b1) begin
          t_trx.data_done = `TRUE;
		  vir_write_data_id++;
         `uvm_info(get_type_name(), $psprintf("collected write data last"), UVM_MEDIUM)
        end

        if ((t_trx.addr_done == `TRUE) && (t_trx.data_done == `TRUE))
            item_write_port.write(t_trx); // call back to slave driver
    end

endtask : collect_data_write_trx


// collect resp write @ neg edge
task AXI_slave_monitor::collect_resp_write_trx();
  AXI_transfer t_trx;

  forever begin
      @(negedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_BVALID == 1'b1 &&
                                   m_vif.mon_cb.AXI_BREADY == 1'b1));

      //if (m_wr_queue.fd_queued(m_vif.mon_cb.AXI_BID)) begin
      if (m_wr_queue.fd_queued(vir_write_resp_id)) begin
        t_trx       = m_wr_queue.peak_trx();

        if (t_trx.addr_done == `TRUE &&
            t_trx.data_done == `TRUE) begin

            t_trx.resp  = dec_resp  (m_vif.mon_cb.AXI_BRESP);
            t_trx.end_cycle = m_cycle;
            t_trx.end_time  = $time;
            void'(end_tr(t_trx));

            `uvm_info(get_type_name(), $psprintf("collected write data resp"), UVM_MEDIUM)

            // Send transfer to scoreboard via TLM write()
            item_write_collected_port.write(t_trx);
           // m_wr_queue.del_queued(m_vif.mon_cb.AXI_BID);
            m_wr_queue.del_queued(vir_write_resp_id);
	  		vir_write_resp_id++;
        end

      end else begin
        `uvm_error("NOIDMATCH", {"BID is not found in write queue: ",get_full_name()})
      end
    end

endtask : collect_resp_write_trx


// collect addr read @ pos edge
task AXI_slave_monitor::collect_addr_read_trx();
  AXI_transfer t_trx;

  forever begin
      @(posedge m_vif.AXI_MON_ACLK iff ((m_vif.mon_cb.AXI_ARVALID == 1'b1) && (m_vif.mon_cb.AXI_ARREADY == 1'b1)));
     // if (!m_rd_queue.fd_queued(m_vif.mon_cb.AXI_ARID)) begin
     //     m_rd_queue.en_queued(m_vif.mon_cb.AXI_ARID);
      if (!m_rd_queue.fd_queued(vir_read_addr_id)) begin
          m_rd_queue.en_queued(vir_read_addr_id);
          t_trx = m_rd_queue.peak_trx();
          t_trx.begin_cycle = m_cycle;
          t_trx.begin_time  = $time;
          void'(begin_tr(t_trx, {$psprintf("axi_slave_monitor[%h]", this)}));
      end

      if (m_conf.start_addr > m_vif.mon_cb.AXI_ARADDR || m_conf.end_addr < m_vif.mon_cb.AXI_ARADDR)
         `uvm_error("NOADDRMATCH", {$psprintf("ARADDR %h is not found in [%h:%h]",
                                   m_vif.mon_cb.AXI_ARADDR,
                                   m_conf.start_addr,
                                   m_conf.end_addr), get_full_name()})

      t_trx         = m_rd_queue.peak_trx();
      t_trx.rw      = READ;
      t_trx.addr    = dec_addr  (m_vif.mon_cb.AXI_ARADDR);
      t_trx.id      = dec_id    (m_vif.mon_cb.AXI_ARID);
      t_trx.region  = dec_region(m_vif.mon_cb.AXI_ARREG);
      t_trx.len     = dec_len   (m_vif.mon_cb.AXI_ARLEN);
      t_trx.size    = dec_byte  (m_vif.mon_cb.AXI_ARSIZE);
      t_trx.burst   = dec_burst (m_vif.mon_cb.AXI_ARBURST);
      t_trx.lock    = dec_lock  (m_vif.mon_cb.AXI_ARLOCK);
      t_trx.cache   = dec_cache (m_vif.mon_cb.AXI_ARCACHE);
      t_trx.prot    = dec_prot  (m_vif.mon_cb.AXI_ARPROT);
      t_trx.qos     = dec_qos   (m_vif.mon_cb.AXI_ARQOS);

      `uvm_info(get_type_name(), $psprintf("collected read addr addr : %h, len %h, id %h", t_trx.addr, t_trx.len, t_trx.id), UVM_MEDIUM)

      // extend trx
      m_mem_map.run(t_trx);
      t_trx.mem_addrs = m_mem_map.addrs;
      t_trx.mem_datas = m_mem_map.datas;
      m_mem_map.clear();

      t_trx.itype = SLAVE;
      t_trx.slave = get_full_name();
      t_trx.addr_done = `TRUE;

	  vir_read_addr_id++;
      item_read_port.write(t_trx); // call back to slave driver
  end

endtask : collect_addr_read_trx

// collect data read @ neg edge
task AXI_slave_monitor::collect_data_read_trx();
    AXI_transfer t_trx;

    forever begin
        @(negedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_RVALID == 1'b1 &&
                                      m_vif.mon_cb.AXI_RREADY == 1'b1));

       // if (m_rd_queue.fd_queued(m_vif.mon_cb.AXI_RID)) begin
        if (m_rd_queue.fd_queued(vir_read_data_id)) begin
              t_trx = m_rd_queue.peak_trx();

              if (t_trx.addr_done==`TRUE) begin

              t_trx.data.push_back( dec_data(m_vif.mon_cb.AXI_RDATA) );
              t_trx.resp = dec_resp(m_vif.mon_cb.AXI_RRESP);

              t_trx.used_cycle = t_trx.used_cycle +  1;

              if (m_vif.mon_cb.AXI_RLAST == 1'b1) begin
                    t_trx.data_done = `TRUE;
                    t_trx.end_cycle = m_cycle;
                    t_trx.end_time  = $time;
                    void'(end_tr(t_trx));

                    // Send transfer to scoreboard via TLM write()
                    item_read_collected_port.write(t_trx);
                    //m_rd_queue.del_queued(m_vif.mon_cb.AXI_RID);
                    m_rd_queue.del_queued(vir_read_data_id);
					vir_read_data_id++;
              end
            end
        end
    end

endtask : collect_data_read_trx

/***************************************************************************
 IVB-NOTE : OPTIONAL : slave Monitor Protocol Checks : Checks
 -------------------------------------------------------------------------
 Add protocol checks within the perform_checks() method.
 ***************************************************************************/

// perform read queue check
task AXI_slave_monitor::perform_write_checks();
  AXI_transfer  t_trx;
  AXI_map       t_map;

  forever begin
      @(negedge m_vif.AXI_MON_ACLK);

      foreach (m_wr_queue.m_queue[i]) begin
        $cast(t_map,m_wr_queue.m_queue[i]);
        t_trx = t_map.m_trx;

        if (m_cycle - t_trx.begin_cycle >= m_conf.tolerate_wt_delay)
          `uvm_error("OUTTIMING", {$psprintf("trx @addr %h @time %d+%d is out of %d write trx time",
                              t_trx.addr,
                              t_trx.begin_cycle,
                              m_conf.tolerate_wt_delay,
                              m_cycle), get_full_name()})

      end
  end

endtask : perform_write_checks

// perform write queue check
task AXI_slave_monitor::perform_read_checks();
  AXI_transfer  t_trx;
  AXI_map       t_map;

  forever begin
      @(negedge m_vif.AXI_MON_ACLK);

      foreach (m_rd_queue.m_queue[i]) begin
        $cast(t_map,m_rd_queue.m_queue[i]);
        t_trx = t_map.m_trx;

        if (m_cycle - t_trx.begin_cycle >= m_conf.tolerate_wt_delay)
          `uvm_error("OUTTIMING", {$psprintf("trx @addr %h @time %d+%d is out of %d read trx time",
                                t_trx.addr,
                                t_trx.begin_cycle,
                                m_conf.tolerate_rd_delay,
                                m_cycle), get_full_name()})

      end
  end

endtask : perform_read_checks


/***************************************************************************
IVB-NOTE : OPTIONAL : slave Monitor Coverage : Coverage
-------------------------------------------------------------------------
Modify the slave_transfer_cg coverage group to match your protocol.
Add new coverage groups, and edit the perform_coverage() method to sample
them.
***************************************************************************/

// Triggers coverage events
task AXI_slave_monitor::perform_write_coverage();
//  slave_transfer_cg.sample();
endtask : perform_write_coverage


task AXI_slave_monitor::perform_read_coverage();
//  slave_transfer_cg.sample();
endtask : perform_read_coverage


// UVM report() phase
function void AXI_slave_monitor::report();
  `uvm_info(get_type_name(), $psprintf("\nReport: AXI slave monitor collected %0d transfers", m_num_col),
    UVM_MEDIUM)
endfunction : report

`endif // AXI_SLAVE_MONITOR_SV

