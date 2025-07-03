// testsuite sets....

`ifndef axi_len_SEQ_SV
`define axi_len_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_len_seq
//---------------------------------------------
class axi_len_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_len_seq)

  function new(string name="axi_len_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	for(int i = 0; i < 50; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		write_data(0,1,addr,0,$urandom_range(15),1);
		rand_delay(500,500);
		read_data(0,1,addr,0,$urandom_range(15),1);
		rand_delay(500,500);
	end

	rand_delay(15000,15000);
  endtask

endclass : axi_len_seq

`endif // axi_len_seq_SV
