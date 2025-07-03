
/*--------------------------------------
// APB slave agent
// file : apb_slave_agent.sv
// author : FX
// date : 2018/05/06
// description : slave agent, contain monitor or sequencer if the ACTIVE is on
---------------------------------------*/

`ifndef APB_SLAVE_AGENT_SV
`define APB_SLAVE_AGENT_SV

class apb_slave_agent extends uvm_agent;

  virtual interface apb_slave_vif m_vif;

	apb_slave_drv		m_driver;
	apb_slave_mon		m_monitor;

	// reserve fields
	`uvm_component_utils_begin(apb_slave_agent)
	`uvm_component_utils_end


	// constructor
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	// build phase
	virtual function void build_phase(uvm_phase phase);
		super.build();

		m_monitor = apb_slave_mon::type_id::create("m_monitor", this);
		m_driver = apb_slave_drv::type_id::create("m_driver", this);
	endfunction : build_phase


	// connect phase
	virtual function void connect_phase(uvm_phase phase);
	endfunction : connect_phase

endclass : apb_slave_agent

`endif // APB_SLAVE_AGENT_SV

