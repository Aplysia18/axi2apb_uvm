// testsuite sets....

`ifndef AXI_RANDOM_SEQ_SV
`define AXI_RANDOM_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_random_seq
//---------------------------------------------
class axi_random_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_random_seq)

  function new(string name="axi_random_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	for(int i = 0; i < 1000; i++)
	begin
		if($urandom_range(0,1)) begin
			addr = $urandom_range(32'h0,32'hffffffff);
			write_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),$urandom_range(0,7),3,,$urandom_range(10),$urandom_range(10),$urandom_range(10));
		end else begin
			addr = $urandom_range(32'h0,32'hffffffff);
			read_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),$urandom_range(0,7),$urandom_range(10),$urandom_range(10));
		end
		rand_delay(0,500);
	end
	for(int i = 0; i < 1000; i++)
	begin
		if($urandom_range(0,1)) begin
			addr = $urandom_range(32'h400,32'h1000);
			write_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),$urandom_range(0,7),3,,$urandom_range(10),$urandom_range(10),$urandom_range(10));
		end else begin
			addr = $urandom_range(32'h400,32'h1000);
			read_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),$urandom_range(0,7),$urandom_range(10),$urandom_range(10));
		end
		rand_delay(0,500);
	end
	rand_delay(15000,15000);
  endtask

endclass : axi_random_seq

`endif
