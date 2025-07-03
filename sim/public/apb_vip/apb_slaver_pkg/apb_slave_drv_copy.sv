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
  extern virtual protected task reset_signals();
  extern virtual protected task drive_transfer();
 // extern virtual function void report();

  extern virtual protected task write_trx_op();
  extern virtual protected task read_trx_op();
  extern virtual protected task pready_pslveer_op();
  extern virtual protected task get_and_drive();
  extern virtual protected task wait_for_reset();
  extern virtual protected task sent_trx_to_seq();

//  extern virtual protected task
endclass : apb_slave_drv

//UVM connect_phase
function void apb_slave_drv::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if (!uvm_config_db#(virtual interface apb_slave_vif)::get(this, "", "apb_slave_vif", m_vif))
   `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".m_vif"})

endfunction : connect_phase


// UVM run() phase
task apb_slave_drv::run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
endtask : run_phase


// Gets transfers from the sequencer and passes them to the driver.
task apb_slave_drv::get_and_drive();
    wait_for_reset();
    sent_trx_to_seq();
	
endtask : get_and_drive


// Reset all slave signals
task apb_slave_drv::reset_signals();
    forever begin
      @(posedge m_vif.APB_ARESET_N);
      `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
        m_vif.drv_cb.prdata  <= 0; 
    end
endtask : reset_signals


task apb_slave_drv::wait_for_reset();
    wait(!m_vif.APB_ARESET_N)
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)
endtask : wait_for_reset


// get next trx when reset has already done
// default : set init memory map
task apb_slave_drv::sent_trx_to_seq();
  drive_transfer();
endtask : sent_trx_to_seq


// Gets a transfer and drive it into the DUT
// ps addr_write and data_write can be the same time
task apb_slave_drv::drive_transfer();
  fork
    write_trx_op();
	read_trx_op();
	pready_pslveer_op();
  join
endtask : drive_transfer

task apb_slave_drv::write_trx_op();

  forever begin
	@(m_vif.drv_cb iff((1 == m_vif.psel) && (1 == m_vif.penable) && (1 == m_vif.pready))); 
	if(1 == m_vif.pwrite)
	begin
		m_mem[m_vif.paddr] = m_vif.pwdata;
$display("VVVVVVVVVV_m_mem[%h]=%h",m_vif.paddr,m_mem[m_vif.paddr]);
	end
  end
endtask : write_trx_op

task apb_slave_drv::read_trx_op();

  forever begin

	if((1 == m_vif.psel) && (1 == m_vif.penable) && (0 == m_vif.pwrite) && (1 == m_vif.pready)) begin
		m_vif.prdata <= m_mem[m_vif.paddr];
$display("XXXXXXXXXXX_m_mem[%h]=%h",m_vif.paddr,m_mem[m_vif.paddr]);
	end
	else
		m_vif.prdata <= 0;

	@m_vif.drv_cb;

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
`endif // APB_SLAVE_DRV_SV


