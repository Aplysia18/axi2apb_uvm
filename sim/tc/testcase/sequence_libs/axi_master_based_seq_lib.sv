`ifndef AXI_MASTER_BASED_SEQ_LIB_SV
`define AXI_MASTER_BASED_SEQ_LIB_SV

class AXI_master_base_seq extends AXI_base_seq;
  AXI_master_seq seq[`MST_NUM];

  function new(string name="axi_master_base_seq");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(AXI_master_base_seq)
  `uvm_object_utils_end

  `uvm_declare_p_sequencer(vir_sequencer)

// Use a base sequence to raise/drop objections if this is a default sequence
  virtual task pre_body();
     if (starting_phase != null)
        starting_phase.raise_objection(this, {"Running sequence '",
                                              get_full_name(), "'"});
  endtask

  virtual task body();
     repeat(200) @(posedge axi_bus_top.clk);
  endtask

  virtual task post_body();
	 repeat(80000) @(posedge axi_bus_top.clk);
     if (starting_phase != null)
        starting_phase.drop_objection(this, {"Completed sequence '",
                                             get_full_name(), "'"});
  endtask

  extern task rand_delay(input bit[31:0] delay_min = 0, bit[31:0] delay_max = 100); 
  extern task write_data(input bit[31:0] port_num = 0, bit[7:0] write_id = 0, bit[31:0] write_addr = 32'h1000, bit random_flag = 1, int write_len = 9, int write_burst = 1, int addr_delay = 0, int data_delay = 0, int resp_delay = 0);
  extern task read_data(input bit[31:0] port_num = 0, bit[7:0] read_id = 0, bit[31:0] read_addr = 32'h1000, bit random_flag = 1, int read_len = 9, int read_burst = 1, int addr_delay = 0, int data_delay = 0);
endclass : AXI_master_base_seq

task AXI_master_base_seq::rand_delay(input bit[31:0] delay_min = 0, bit[31:0] delay_max = 100);
	bit[31:0] delay_time;
	
	delay_time = $urandom_range(delay_min, delay_max);
	repeat(delay_time) @(posedge axi_bus_top.clk);
endtask

task AXI_master_base_seq::write_data(input bit[31:0] port_num = 0, bit[7:0] write_id = 0, bit[31:0] write_addr = 32'h1000, bit random_flag = 1, int write_len = 9, int write_burst = 1, int addr_delay = 0, int data_delay = 0, int resp_delay = 0);

	if(1 == random_flag)
	begin
		write_len = $urandom_range(15);
		write_burst = $urandom_range(2);
	end
	
	`uvm_do_on_with(seq[port_num], p_sequencer.axi_bus_mst_sqr[port_num], {seq[port_num].itype==MASTER;seq[port_num].rw==WRITE;seq[port_num].id==write_id;seq[port_num].addr==write_addr;seq[port_num].len==write_len;seq[port_num].burst==write_burst;seq[port_num].addr_wt_delay==addr_delay;seq[port_num].data_wt_delay==data_delay;seq[port_num].resp_wt_delay==resp_delay;});
	
endtask

task AXI_master_base_seq::read_data(input bit[31:0] port_num = 0, bit[7:0] read_id = 0, bit[31:0] read_addr = 32'h1000, bit random_flag = 1, int read_len = 9, int read_burst = 1, int addr_delay = 0, int data_delay = 0);
	
	if(1 == random_flag)
	begin
		read_len = $urandom_range(15);
		read_burst = $urandom_range(2);
	end

	`uvm_do_on_with(seq[port_num], p_sequencer.axi_bus_mst_sqr[port_num], {seq[port_num].itype==MASTER;seq[port_num].rw==READ;seq[port_num].id==read_id;seq[port_num].addr==read_addr;seq[port_num].len==read_len;seq[port_num].burst==read_burst;seq[port_num].addr_rd_delay==addr_delay;seq[port_num].data_rd_delay==data_delay;});
	
endtask
`endif // AXI_MASTER_BASED_SEQ_LIB_SV

