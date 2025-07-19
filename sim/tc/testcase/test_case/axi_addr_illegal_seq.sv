// testsuite sets....

`ifndef axi_addr_illegal_SEQ_SV
`define axi_addr_illegal_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_addr_illegal_seq
//---------------------------------------------
class axi_addr_illegal_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_addr_illegal_seq)
	rand bit [31:0] addr;
	constraint c_addr {addr dist {[0:32'h3ff]:/40, [32'h1000:32'hffffffff]:/60};}

  function new(string name="axi_addr_illegal_seq");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();

	for(int i = 0; i < 100; i++)
	begin
		if (!this.randomize()) begin
			`uvm_error("RAND_FAIL", $sformatf("Randomization failed at write iteration %0d", i))
		end
		write_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),2,2,,$urandom_range(10),$urandom_range(10),$urandom_range(10));
		rand_delay(500,500);
	end

	rand_delay(15000,15000);
	for(int i = 0; i < 100; i++)
	begin
		if (!this.randomize()) begin
			`uvm_error("RAND_FAIL", $sformatf("Randomization failed at read iteration %0d", i))
		end
		read_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),2,$urandom_range(10),$urandom_range(10));
		rand_delay(500,500);
	end
	rand_delay(100000,100000);
  endtask

endclass : axi_addr_illegal_seq

`endif // axi_addr_illegal_seq_SV
