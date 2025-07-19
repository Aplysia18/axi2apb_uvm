// testsuite sets....

`ifndef AXI_UNALIGNED_SEQ_SV
`define AXI_UNALIGNED_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_unaligned_seq
//---------------------------------------------
class axi_unaligned_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_unaligned_seq)

  function new(string name="axi_unaligned_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
	int unsigned strb[$];
	int unsigned strb_temp;
	int burst;
	int len;
	int unsigned mask_start;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	for(int i = 0; i < 500; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000);
		len = $urandom_range(0,15);
		burst = $urandom_range(2);
		strb = {};
		case(addr%4)
			0: mask_start = 4'hf;
			1: mask_start = 4'he;
			2: mask_start = 4'hc;
			3: mask_start = 4'h8;
		endcase
		for (int j=0; j<len; j++) begin
			strb_temp = $urandom_range(0,4'hf);
			if(j==0||burst==0) begin
				strb_temp = mask_start & strb_temp;
			end
			strb.push_back(strb_temp);
		end
		`uvm_info("strb", $sformatf("strb is %p", strb), UVM_LOW);
		write_data(0,$urandom_range(0,8'hff),addr,0,len,burst,2,4,strb,$urandom_range(10),$urandom_range(10),$urandom_range(10));
		rand_delay(0,500);
		read_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),2,$urandom_range(10),$urandom_range(10));
		rand_delay(0,500);
	end
	rand_delay(15000,15000);
  endtask

endclass : axi_unaligned_seq

`endif // axi_unaligned_seq_SV
