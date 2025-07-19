`ifndef HAVE_DDR_CMP
	`define HAVE_DDR_CMP
`endif
`include "../tc/testcase/axi_base_tc.sv"
`include "../tc/testcase/test_case/axi_unaligned_seq.sv"
//----------------------------------------------
// TEST: axi_unaligned_tc
//----------------------------------------------
class axi_unaligned_tc extends axi_base_test;

  `uvm_component_utils(axi_unaligned_tc)

  function new(string name = "axi_unaligned_tc", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

	uvm_config_db#(uvm_object_wrapper)::set(this,"v_sqr.main_phase","default_sequence",axi_unaligned_seq::type_id::get());

    super.build_phase(phase);
  endfunction : build_phase

endclass : axi_unaligned_tc

