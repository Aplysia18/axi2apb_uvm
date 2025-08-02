/*--------------------------------------
// apb slave driver
// file : apb_slave_drv.sv
// author : FX
// date : 2018/05/06
// brief : slave driver, transfer TLM level info to pin level info
---------------------------------------*/

`ifndef APB_SLAVE_DRV_SV
`define APB_SLAVE_DRV_SV

class apb_slave_drv extends uvm_driver;

  virtual interface apb_slave_vif   m_vif;

  bit[`APB_DATA_SIZE-1:0]         m_mem[int unsigned];

	// reserve fields
	`uvm_component_utils_begin(apb_slave_drv)
	`uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // Additional class methods
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

  extern virtual protected task write_trx_op();
  extern virtual protected task read_trx_op();
  extern virtual protected task pready_pslveer_op();

  extern virtual protected task cleanup_on_reset();
  extern virtual protected task reset_signals();

endclass : apb_slave_drv

//UVM connect_phase
function void apb_slave_drv::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if (!uvm_config_db#(virtual interface apb_slave_vif)::get(this, "", "apb_slave_vif", m_vif))
   `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".m_vif"})

endfunction : connect_phase


// UVM run() phase
task apb_slave_drv::run_phase(uvm_phase phase);
  forever begin
    @(posedge m_vif.APB_ARESET_N);
    `uvm_info(get_type_name(), "Reset asserted", UVM_MEDIUM)
    fork
      write_trx_op();
      read_trx_op();
      pready_pslveer_op();
    join_none
    @(negedge m_vif.APB_ARESET_N);
    `uvm_info(get_type_name(), "Reset deasserted", UVM_MEDIUM)
    disable fork;
    cleanup_on_reset();
  end
endtask : run_phase

task apb_slave_drv::write_trx_op();

  forever begin
	@(m_vif.drv_cb iff((1 == m_vif.psel) && (1 == m_vif.pwrite) && (1 == m_vif.penable))); 
		m_mem[m_vif.paddr] = m_vif.pwdata;
$display("VVVVVVVVVV_m_mem[%h]=%h,time=%t",m_vif.paddr,m_mem[m_vif.paddr],$time);
  end
endtask : write_trx_op

task apb_slave_drv::read_trx_op();

  forever begin

	@(m_vif.drv_cb iff((1 == m_vif.psel) && (1 == m_vif.penable) && (0 == m_vif.pwrite))) begin
$display("XXXXXXXXXXX_m_mem[%h]=%h,time=%t",m_vif.paddr,m_mem[m_vif.paddr],$time);
		m_vif.prdata = m_mem[m_vif.paddr];
	end
  end
endtask : read_trx_op

task apb_slave_drv::pready_pslveer_op();
	fork
		while(1) begin
			if(1 == $urandom_range(5))
				m_vif.drv_cb.pready <= 0;
			else
				m_vif.drv_cb.pready <= 1;
			@m_vif.drv_cb;
		end
/*	
		while(1) begin
		//	if(1 == $urandom_range(15))
				m_vif.drv_cb.pslveer <= 1;
		//	else
		//		m_vif.drv_cb.pslveer <= 0;
			@m_vif.drv_cb;
		end 
*/
	join
endtask : pready_pslveer_op

task apb_slave_drv::cleanup_on_reset();
    `uvm_info(get_type_name(), "Cleanup on reset", UVM_MEDIUM)
    // Reset memory
    foreach (m_mem[i]) begin
      m_mem[i] = 0;
    end
    // Reset signals
    reset_signals();
endtask : cleanup_on_reset

// Reset all slave signals
task apb_slave_drv::reset_signals();
    `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
    m_vif.drv_cb.prdata  <= 0; 
endtask : reset_signals
`endif // APB_SLAVE_DRV_SV


