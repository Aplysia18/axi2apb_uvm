// testsuite sets....

`ifndef axi_strob_SEQ_SV
`define axi_strob_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_strob_seq
//---------------------------------------------
class axi_strob_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_strob_seq)

  function new(string name="axi_strob_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	for(int i = 0; i < 50; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		write_data(0,1,addr,0,15,1,,0);
		rand_delay(500,500);
		read_data(0,1,addr,0,15,1,,0);
		rand_delay(500,500);
	end

	rand_delay(15000,15000);
  endtask

endclass : axi_strob_seq

`endif // axi_strob_seq_SV
