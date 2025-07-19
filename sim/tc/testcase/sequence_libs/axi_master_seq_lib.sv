
`ifndef AXI_MASTER_SEQ_LIB_SV
`define AXI_MASTER_SEQ_LIB_SV

//---------------------------------------------
// SEQUENCE: write_read_seq
// create write read trx
//---------------------------------------------
class AXI_master_seq extends uvm_sequence #(AXI_transfer);

	rand int unsigned     id;
	rand itype_enum       itype;
	rand direction_enum   rw;
	rand int unsigned     addr;
	rand len_enum 	      len;
	rand byte_enum        size;
	rand burst_enum       burst;
	rand int unsigned     strb[$];
	rand bit[`DATA_SIZE-1:0] data[$];
	rand int unsigned 	  addr_wt_delay;
	rand int unsigned 	  data_wt_delay;
	rand int unsigned 	  resp_wt_delay;
	rand int unsigned 	  addr_rd_delay;
	rand int unsigned 	  data_rd_delay;
    AXI_transfer 		  m_trans;
	rand int              strb_flag;	//0: all 0; 1: all 1; 2: random 0/1; 3: random 4: user-defined

    extern function new(string name ="AXI_master_seq");
	extern task reset_phase(uvm_phase phase);
    virtual task body();
		m_trans = new();
		start_item(m_trans);
		if(rw == WRITE)
		begin
			// if(strb_flag == 0 || strb_flag == 1 || strb_flag == 2 || strb_flag == 3) strb = {};
			// `uvm_info("strb", $psprintf("strb_flag = %h",strb_flag), UVM_LOW);
			for(int i = 0; i < len+1; i++)
			begin
				// data.push_back({$urandom_range(32'hffff_ffff),$urandom_range(32'hffff_ffff)});
				bit [`DATA_SIZE-1:0] data_temp;
				randcase
					1: data_temp = {`DATA_SIZE{1'b1}};
					8: data_temp = $urandom_range(1,{`DATA_SIZE{1'b1}});
					1: data_temp = 0;
				endcase
				data.push_back(data_temp);
				if(0 == strb_flag)
					strb.push_back(4'h0);
				else if(1 == strb_flag)
					strb.push_back(4'hf);
				else if(2 == strb_flag) begin
					int unsigned strb_temp;
					randcase
						8: strb_temp = 4'hf;
						2: strb_temp = 4'h0;
					endcase
					strb.push_back(strb_temp);
				end else if(3 == strb_flag)
					strb.push_back($urandom_range(4'hf));
			end
		end	

		m_trans.id           = id;
		m_trans.itype        = itype;
		m_trans.rw           = rw;
		m_trans.addr         = addr;
		m_trans.len          = len;
		m_trans.size         = size;
		m_trans.burst        = burst;
		m_trans.strb         = strb;
		m_trans.data         = data;
		m_trans.addr_wt_delay= addr_wt_delay;
		m_trans.data_wt_delay= data_wt_delay;
		m_trans.resp_wt_delay= resp_wt_delay;
		m_trans.addr_rd_delay= addr_rd_delay;
		m_trans.data_rd_delay= data_rd_delay;

		$display("sequence m_trans pkt is:");
		m_trans.print();
		finish_item(m_trans);
    endtask

    `uvm_object_utils(AXI_master_seq)
endclass

function AXI_master_seq::new(string name = "AXI_master_seq");
    super.new(name);
endfunction

task AXI_master_seq::reset_phase(uvm_phase phase);
	phase.raise_objection(this);
	phase.drop_objection(this);
endtask

`endif // AXI_MASTER_SEQ_LIB_SV
