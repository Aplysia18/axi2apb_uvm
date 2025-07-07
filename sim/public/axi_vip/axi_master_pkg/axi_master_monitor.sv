/*--------------------------------------
// AXI master monitor
// file : axi_master_monitor.sv
// author : FX
// date : 2018/05/06
// description : master watch monitor
---------------------------------------*/

`ifndef AXI_MASTER_MONITOR_SV
`define AXI_MASTER_MONITOR_SV

class AXI_master_monitor extends uvm_monitor;

  virtual interface AXI_master_vif    m_vif;
  AXI_master_conf                    m_conf;

  // cycle count
  longint                     m_cycle = 0;

  // Count transfers collected
  int           m_num_col;

  // trx stored queue
  AXI_queue     m_wr_queue;
  AXI_queue     m_rd_queue;

  // trx mem map table
  AXI_mem_map   m_mem_map;

  //virtual write_id
  int unsigned  vir_write_addr_id = 0;
  int unsigned  vir_write_data_id = 0;
  int unsigned  vir_write_resp_id = 0;
  int unsigned  vir_read_addr_id = 0;
  int unsigned  vir_read_data_id = 0;

  // recorder
  integer       m_file;

  // The following two bits are used to control whether checks and coverage are
  // done in the monitor
  bit checks_enable   = 1;
  bit coverage_enable = 1;

  // The current AXI_transfer
  protected AXI_transfer trans_collected;

  // This TLM port is used to connect the monitor to the scoreboard
  uvm_analysis_port #(AXI_transfer) item_collected_port;

  /*--------------------------------
  // Covergroup for transfer
  ----------------------------------*/
  covergroup master_transfer_cg;
    TRANS_ADDR : coverpoint trans_collected.addr {
      bins ZERO     = {0};
      bins NON_ZERO = {[1:8'hff]};
    }
    TRANS_DIRECTION : coverpoint trans_collected.rw {
      bins READ   = {READ};
      bins WRITE  = {WRITE};
    }
    TRANS_LEN : coverpoint trans_collected.len {
      bins len_0  = {0 };
      bins len_1  = {1 };
      bins len_2  = {2 };
      bins len_3  = {3 };
      bins len_4  = {4 };
      bins len_5  = {5 };
      bins len_6  = {6 };
      bins len_7  = {7 };
      bins len_8  = {8 };
      bins len_9  = {9 };
      bins len_10 = {10};
      bins len_11 = {11};
      bins len_12 = {12};
      bins len_13 = {13};
      bins len_14 = {14};
      bins len_15 = {15};
    }
    TRANS_SIZE : coverpoint trans_collected.size {
    }

//    TRANS_DATA : coverpoint trans_collected.data {
//      bins ZERO     = {0};
//      bins NON_ZERO = {[1:8'hff]};
//    }
    TRANS_ADDR_X_TRANS_DIRECTION: cross TRANS_ADDR, TRANS_DIRECTION;
  endgroup : master_transfer_cg

  // Provide UVM automation and utility methods
  `uvm_component_utils_begin(AXI_master_monitor)
    `uvm_field_int  (m_num_col,       UVM_DEFAULT)
    `uvm_field_int  (checks_enable,   UVM_ALL_ON)
    `uvm_field_int  (coverage_enable, UVM_ALL_ON)
  `uvm_component_utils_end


  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);

    // Create the covergroup
    // master_transfer_cg = new();
    // master_transfer_cg.set_inst_name("master_transfer_cg");

    // Create the TLM port
    item_collected_port = new("item_collected_port", this);

    // wr/rd queue
    m_wr_queue = new();
    m_rd_queue = new();

    // mem map
    m_mem_map  = new();
  endfunction : new

  // Additional class methods
  extern virtual function void assign_vi(virtual interface AXI_master_vif vif);
  extern virtual function void assign_conf(AXI_master_conf conf);

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

endclass : AXI_master_monitor


function void AXI_master_monitor::assign_vi(virtual interface AXI_master_vif vif);
  m_vif = vif;
endfunction : assign_vi


function void AXI_master_monitor::assign_conf(AXI_master_conf conf);
  m_conf = conf;
endfunction : assign_conf


//UVM connect_phase
function void AXI_master_monitor::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if (!uvm_config_db#(virtual AXI_master_vif)::get(this, "", "AXI_master_vif", m_vif))
   `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})

  assert(m_conf!=null);
//  if (!uvm_config_db#(AXI_master_conf)::get(this, "", "m_conf", m_conf))
//    `uvm_error("NOCONF",{"axi conf must be set for: ", get_full_name(), ".m_conf"})

endfunction : connect_phase
// UVM run() phase
task AXI_master_monitor::run_phase(uvm_phase phase);
  fork
    collect_write_transfer();
    collect_read_transfer();
    collect_cycle_count();
  join
endtask : run_phase

/***************************************************************************
 IVB-NOTE : REQUIRED : master Monitor : Monitors
 -------------------------------------------------------------------------
 Modify the collect_transfers() method to match your protocol.
 Note that if you change/add signals to the physical interface, you must
 also change this method.
 ***************************************************************************/

task AXI_master_monitor::collect_cycle_count();
  forever begin
    @m_vif.mon_cb;
    m_cycle += 1;
  end
endtask : collect_cycle_count


task AXI_master_monitor::collect_write_transfer();
  fork
    collect_addr_write_trx();
    collect_data_write_trx();
    collect_resp_write_trx();

    if (checks_enable)
       perform_write_checks();
    // if (coverage_enable)
    //    perform_write_coverage();
  join
endtask : collect_write_transfer


task AXI_master_monitor::collect_read_transfer();
  fork
    collect_addr_read_trx();
    collect_data_read_trx();

    if (checks_enable)
      perform_read_checks();
    // if (coverage_enable)
    //   perform_read_coverage();
  join
endtask : collect_read_transfer


// collect addr write @ neg edge
task AXI_master_monitor::collect_addr_write_trx();
    AXI_transfer t_trx;

    // check write pool, if the W(id) is not found,then create a new one
    // and recored it's timing

    forever begin
        @(negedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_AWVALID == 1'b1 &&
                                      m_vif.mon_cb.AXI_AWREADY == 1'b1));

        // if (!m_wr_queue.fd_queued(m_vif.mon_cb.AXI_AWID)) begin
        //     m_wr_queue.en_queued(m_vif.mon_cb.AXI_AWID);
         if (!m_wr_queue.fd_queued(vir_write_addr_id)) begin
             m_wr_queue.en_queued(vir_write_addr_id);
             t_trx = m_wr_queue.peak_trx();
             t_trx.begin_cycle = m_cycle;
             t_trx.begin_time  = $time;
             void'(begin_tr(t_trx, {$psprintf("axi_master_monitor[%h]", this)}));
         end
	
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

         t_trx.itype  = MASTER;
         t_trx.master = get_full_name();

         t_trx.addr_done = `TRUE;
	
    end

endtask : collect_addr_write_trx


// collect write data @ neg edge
task AXI_master_monitor::collect_data_write_trx();
    AXI_transfer t_trx;

    // check write pool, if the W(id) is not found, create a new one
    // and recored it's timing

    forever begin
        @(negedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_WVALID == 1'b1 &&
                                     m_vif.mon_cb.AXI_WREADY == 1'b1));

       // if (!m_wr_queue.fd_queued(m_vif.mon_cb.AXI_WID)) begin
       //     m_wr_queue.en_queued(m_vif.mon_cb.AXI_WID);
        if (!m_wr_queue.fd_queued(vir_write_data_id)) begin
            m_wr_queue.en_queued(vir_write_data_id);
            t_trx = m_wr_queue.peak_trx();
            t_trx.begin_cycle = m_cycle;
            t_trx.begin_time  = $time;
            void'(begin_tr(t_trx, {$psprintf("axi_master_monitor[%h]", this)}));
       end

        t_trx = m_wr_queue.peak_trx();
        t_trx.data.push_back( dec_data(m_vif.mon_cb.AXI_WDATA) );
        t_trx.strb.push_back( dec_strb(m_vif.mon_cb.AXI_WSTRB) );

        t_trx.used_cycle = t_trx.used_cycle + 1;

        if (m_vif.mon_cb.AXI_WLAST == 1'b1)
		  vir_write_data_id++;
          t_trx.data_done = `TRUE;

    end

endtask : collect_data_write_trx


// collect resp @ pos edge
task AXI_master_monitor::collect_resp_write_trx();
  AXI_transfer t_trx;

  forever begin
      @(posedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_BVALID == 1'b1 &&
                                   m_vif.mon_cb.AXI_BREADY == 1'b1));

      //if (m_wr_queue.fd_queued(m_vif.mon_cb.AXI_BID)) begin
      if (m_wr_queue.fd_queued(vir_write_resp_id)) begin
        t_trx       = m_wr_queue.peak_trx();

        if (t_trx.addr_done == `TRUE &&
            t_trx.data_done == `TRUE) begin

            t_trx.resp  = dec_resp(m_vif.mon_cb.AXI_BRESP);
            t_trx.end_cycle = m_cycle;
            t_trx.end_time  = $time;
            void'(end_tr(t_trx));
            // if(coverage_enable) begin
              // trans_collected = t_trx;
              // perform_read_coverage();
            // end

            // Send transfer to scoreboard via TLM write()
            item_collected_port.write(t_trx);
            // m_wr_queue.del_queued(m_vif.mon_cb.AXI_BID);
            m_wr_queue.del_queued(vir_write_resp_id);
            vir_write_resp_id++;
        end else
          `uvm_error("TRXERROR", {$psprintf("B channel done before addr&data done"), get_full_name()})
      end else begin
        `uvm_error("NOIDMATCH", {$psprintf("BID %h is not found in write queue", m_vif.mon_cb.AXI_BID), get_full_name()})
      end
    end

endtask : collect_resp_write_trx


// collect addr read @ neg edge
task AXI_master_monitor::collect_addr_read_trx();
  AXI_transfer t_trx;

  forever begin
      @(negedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_ARVALID == 1'b1 &&
                                    m_vif.mon_cb.AXI_ARREADY == 1'b1));

     // if (!m_rd_queue.fd_queued(m_vif.mon_cb.AXI_ARID)) begin
     //     m_rd_queue.en_queued(m_vif.mon_cb.AXI_ARID);
      if (!m_rd_queue.fd_queued(vir_read_addr_id)) begin
          m_rd_queue.en_queued(vir_read_addr_id);
          t_trx = m_rd_queue.peak_trx();
          t_trx.begin_cycle = m_cycle;
          t_trx.begin_time  = $time;
          void'(begin_tr(t_trx, {$psprintf("axi_master_monitor[%h]", this)}));
      end

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

      // extend trx
      m_mem_map.run(t_trx);
      t_trx.mem_addrs = m_mem_map.addrs;
      t_trx.mem_datas = m_mem_map.datas;
      m_mem_map.clear();

      t_trx.itype = MASTER;
      t_trx.master = get_full_name();
	
	  vir_read_addr_id++;
      t_trx.addr_done = `TRUE;
  end

endtask : collect_addr_read_trx


// collect data read @ pos edge
task AXI_master_monitor::collect_data_read_trx();
    AXI_transfer t_trx;

    forever begin
        @(posedge m_vif.AXI_MON_ACLK iff (m_vif.mon_cb.AXI_RVALID == 1'b1 &&
                                      m_vif.mon_cb.AXI_RREADY == 1'b1));

       // if (m_rd_queue.fd_queued(m_vif.mon_cb.AXI_RID)) begin
        if (m_rd_queue.fd_queued(vir_read_data_id)) begin
          t_trx = m_rd_queue.peak_trx();

          if (t_trx.addr_done==`TRUE) begin

              t_trx.data.push_back( dec_data(m_vif.mon_cb.AXI_RDATA));
              t_trx.resp = dec_resp(m_vif.mon_cb.AXI_RRESP);

              t_trx.used_cycle = t_trx.used_cycle + 1;

              if (m_vif.mon_cb.AXI_RLAST == 1'b1) begin
                  t_trx.data_done = `TRUE;
                  t_trx.end_cycle = m_cycle;
                  t_trx.end_time  = $time;
                  void'(end_tr(t_trx));

                  // Send transfer to scoreboard via TLM write()
                  item_collected_port.write(t_trx);

                  // if(coverage_enable) begin
                    // trans_collected = t_trx;
                    // perform_write_coverage();
                  // end
                 // m_rd_queue.del_queued(m_vif.mon_cb.AXI_RID);
                  m_rd_queue.del_queued(vir_read_data_id);
				  vir_read_data_id++;
              end
          end else
            `uvm_error("TRXERROR", {$psprintf("R channel done before AR done"), get_full_name()})
        end
    end

endtask : collect_data_read_trx


/***************************************************************************
 IVB-NOTE : OPTIONAL : master Monitor Protocol Checks : Checks
 -------------------------------------------------------------------------
 Add protocol checks within the perform_checks() method.
 ***************************************************************************/

// perform read queue check
task AXI_master_monitor::perform_write_checks();
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
task AXI_master_monitor::perform_read_checks();
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
IVB-NOTE : OPTIONAL : master Monitor Coverage : Coverage
-------------------------------------------------------------------------
Modify the master_transfer_cg coverage group to match your protocol.
Add new coverage groups, and edit the perform_coverage() method to sample
them.
***************************************************************************/

// Triggers coverage events
task AXI_master_monitor::perform_write_coverage();
  master_transfer_cg.sample();
endtask : perform_write_coverage


task AXI_master_monitor::perform_read_coverage();
  master_transfer_cg.sample();
endtask : perform_read_coverage


// UVM report() phase
function void AXI_master_monitor::report();
  `uvm_info(get_type_name(), $psprintf("\nReport: AXI master monitor collected %0d transfers", m_num_col),
    UVM_MEDIUM)
endfunction : report

`endif // AXI_MASTER_MONITOR_SV

