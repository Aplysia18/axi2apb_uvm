`include "../public/axi_vip/axi_pkg.sv"
`include "../public/apb_vip/apb_pkg.sv"
`include "../tb/axi_bus_conf.sv"
`include "../tb/scb/axi_bus_scoreboard.sv"
`include "../tb/cov/axi_bus_fun_cov.sv"
`include "../tb/axi_bus_env.sv"
`include "../tb/vir_sequencer.sv"
`include "../tc/testcase/sequence_libs/axi_seq_lib_pkg.sv"

class axi_base_test extends uvm_test;

  `uvm_component_utils_begin(axi_base_test)
  `uvm_component_utils_end

  axi_bus_env       m_axi_bus_env;
  uvm_table_printer m_printer;
  vir_sequencer     v_sqr;

  function new(string name = "axi_base_test", uvm_component parent);
    super.new(name,parent);
    m_printer = new();
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_axi_bus_env = axi_bus_env::type_id::create("m_axi_bus_env", this);
	v_sqr = vir_sequencer::type_id::create("v_sqr",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
	for(int i = 0; i < `MST_NUM; i++)
	begin
		v_sqr.axi_bus_mst_sqr[i] = m_axi_bus_env.m_axi_env.m_masters[i].m_sequencer;
	end
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    m_printer.knobs.depth = 5;
    this.print(m_printer);
  //  phase.phase_done.set_drain_time(this, 1000000);
  endtask : run_phase

endclass : axi_base_test

