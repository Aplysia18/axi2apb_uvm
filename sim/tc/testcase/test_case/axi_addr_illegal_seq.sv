// testsuite sets....

`ifndef axi_addr_illegal_SEQ_SV
`define axi_addr_illegal_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_addr_illegal_seq
//---------------------------------------------
class axi_addr_illegal_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_addr_illegal_seq)

  function new(string name="axi_addr_illegal_seq");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();

	for(int i = 0; i < 5; i++)
	begin
		write_data(0,1,(32'h1400+i*32*16),0,15,1);
		rand_delay(500,500);
	end

	rand_delay(15000,15000);
	for(int i = 0; i < 5; i++)
	begin
		read_data(0,1,(32'h1400+i*16*32),0,15,1);
		rand_delay(500,500);
	end
	rand_delay(100000,100000);
  endtask

endclass : axi_addr_illegal_seq

`endif // axi_addr_illegal_seq_SV
