// testsuite sets....

`ifndef axi_slave_id_SEQ_SV
`define axi_slave_id_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_slave_id_seq
//---------------------------------------------
class axi_slave_id_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_slave_id_seq)

  function new(string name="axi_slave_id_seq");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();

	write_data(0,1,(32'h400),0,15,1);
	rand_delay(500,500);
	write_data(0,1,(32'h800),0,15,1);
	rand_delay(500,500);
	write_data(0,1,(32'hc00),0,15,1);
	rand_delay(500,500);

	rand_delay(15000,15000);
	read_data(0,1,(32'h400),0,15,1);
	rand_delay(500,500);
	read_data(0,1,(32'h800),0,15,1);
	rand_delay(500,500);
	read_data(0,1,(32'hc00),0,15,1);
	rand_delay(500,500);
	rand_delay(100000,100000);
  endtask

endclass : axi_slave_id_seq

`endif // axi_slave_id_seq_SV
