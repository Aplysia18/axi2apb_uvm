// testsuite sets....

`ifndef axi_burst_SEQ_SV
`define axi_burst_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_burst_seq
//---------------------------------------------
class axi_burst_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_burst_seq)

  function new(string name="axi_burst_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	//read and write burst
	for(int i = 0; i < 50; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		write_data(0,$urandom_range(0,8'hff),addr,0,15,1,2,1,,0,0,0);
		read_data(0,$urandom_range(0,8'hff),addr,0,15,1,2,0,0);
	end

	rand_delay(10000, 10000);
	//write outstanding len_max
	for(int i=0; i<50; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		write_data(0,$urandom_range(0,8'hff),addr,0,15,1,2,1,,0,0,0);
	end
	rand_delay(10000, 10000);
	//write outstanding len_min
	for(int i=0; i<50; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		write_data(0,$urandom_range(0,8'hff),addr,0,0,1,2,1,,0,0,0);
	end
	rand_delay(10000, 10000);
	//read outstanding len_max
	for(int i=0; i<50; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		read_data(0,$urandom_range(0,8'hff),addr,0,15,1,2,0,0);
	end
	rand_delay(10000, 10000);
	//read outstanding len_min
	for(int i=0; i<50; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000)/4*4;
		read_data(0,$urandom_range(0,8'hff),addr,0,0,1,2,0,0);
	end

		// write_data(0,1,addr,0,$urandom_range(15),$urandom_range(2),2,1,,$urandom_range(10),$urandom_range(10),$urandom_range(10));
		// rand_delay(500,500);
		// read_data(0,1,addr,0,$urandom_range(15),$urandom_range(2),2,$urandom_range(10),$urandom_range(10));

	rand_delay(15000,15000);

  endtask

endclass : axi_burst_seq

`endif // axi_burst_seq_SV
