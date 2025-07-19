// testsuite sets....

`ifndef AXI_STROB_RANDOM_SEQ_SV
`define AXI_STROB_RANDOM_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_strob_random_seq
//---------------------------------------------
class axi_strob_random_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_strob_random_seq)

  function new(string name="axi_strob_random_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	for(int i = 0; i < 100; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		write_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),2,3,,$urandom_range(10),$urandom_range(10),$urandom_range(10));
		rand_delay(0,500);
		read_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),2,$urandom_range(10),$urandom_range(10));
		rand_delay(0,500);
	end
	rand_delay(15000,15000);
  endtask

endclass : axi_strob_random_seq

`endif // axi_strob_random_seq_SV
