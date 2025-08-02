// testsuite sets....

`ifndef AXI_RESET_SEQ_SV
`define AXI_RESET_SEQ_SV
`include "../tc/testcase/sequence_libs/reset_seq.sv"

//---------------------------------------------
// SEQUENCE: axi_reset_seq
//---------------------------------------------
class axi_reset_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_reset_seq)

  function new(string name="axi_reset_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
	reset_seq rst_seq;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	for(int i = 0; i < 100; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		write_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),2,1,,0,$urandom_range(10),$urandom_range(10));
		rand_delay(0,200);

        rst_seq = reset_seq::type_id::create("rst_seq");
        rst_seq.start(p_sequencer.rst_sqr);

		read_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),2,0,$urandom_range(10));
		rand_delay(0,200);

		rst_seq = reset_seq::type_id::create("rst_seq");
        rst_seq.start(p_sequencer.rst_sqr);
	end
	rand_delay(15000,15000);
  endtask

endclass : axi_reset_seq

`endif
