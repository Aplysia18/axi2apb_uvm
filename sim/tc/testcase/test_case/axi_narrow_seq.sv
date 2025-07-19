// testsuite sets....

`ifndef AXI_NARROW_SEQ_SV
`define AXI_NARROW_SEQ_SV

//---------------------------------------------
// SEQUENCE: axi_narrow_seq
//---------------------------------------------
class axi_narrow_seq extends AXI_master_base_seq;

  `uvm_object_utils(axi_narrow_seq)

  function new(string name="axi_narrow_seq");
    super.new(name);
  endfunction

  virtual task body();
	int addr;
	int addr_temp;
	int addr_wrap_bound;
	int unsigned strb[$];
	int unsigned strb_temp;
	int burst;
	int len;
	int size;
	int unsigned mask;
    `uvm_info(get_type_name(), "Starting...", UVM_MEDIUM)
	super.body();
	for(int i = 0; i < 500; i++)
	begin
		addr = $urandom_range(32'h400,32'h1000);
		len = $urandom_range(0,15);
		burst = $urandom_range(2);
		size = $urandom_range(0,1);
		addr_temp = addr;
		addr_wrap_bound = addr % ((2**size) * (len+1)) + ((2**size) * (len+1));
		strb = {};
		
		for (int j=0; j<len; j++) begin
			strb_temp = $urandom_range(0,4'hf);
			if(size==0) begin
				case(addr[1:0])
					0: mask = 4'h1;
					1: mask = 4'h2;
					2: mask = 4'h4;
					3: mask = 4'h8;
				endcase
			end else begin
				case(addr[1:0])
					0: mask = 4'h3;
					1: mask = 4'h2;
					2: mask = 4'hc;
					3: mask = 4'h8;
				endcase
			end
			strb_temp = mask & strb_temp;
			strb.push_back(strb_temp);
			if(burst == 1) begin	//incr
				addr_temp = addr_temp/(2**size)*(2**size) + (2**size);
			end else if(burst==2) begin	//wrap
				addr_temp = addr_temp/(2**size)*(2**size) + (2**size);
				if(addr_temp >= addr_wrap_bound) begin
					addr_temp = addr_temp - ((2**size) * (len+1));
				end
			end
		end
		`uvm_info("strb", $sformatf("strb is %p", strb), UVM_LOW);
		write_data(0,$urandom_range(0,8'hff),addr,0,len,burst,size,4,strb,$urandom_range(10),$urandom_range(10),$urandom_range(10));
		rand_delay(0,500);
		read_data(0,$urandom_range(0,8'hff),addr,0,$urandom_range(15),$urandom_range(2),size,$urandom_range(10),$urandom_range(10));
		rand_delay(0,500);
	end
	rand_delay(15000,15000);
  endtask

endclass : axi_narrow_seq

`endif // axi_narrow_seq_SV
