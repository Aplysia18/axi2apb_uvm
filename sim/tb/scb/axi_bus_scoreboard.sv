`ifndef AXI_BUS_SCOREBOARD_SV
`define AXI_BUS_SCOREBOARD_SV
// `uvm_analysis_imp_decl(_mst_drv_write_scb)
`uvm_analysis_imp_decl(_mst_mon_scb)
`uvm_analysis_imp_decl(_apb_to_scb)

class axi_bus_scoreboard extends uvm_scoreboard;

//   uvm_analysis_imp_mst_drv_write_scb#(AXI_transfer, axi_bus_scoreboard) mst_drv_write_scb_imp;
  uvm_analysis_imp_mst_mon_scb#(AXI_transfer, axi_bus_scoreboard) mst_mon_scb_imp;
  uvm_analysis_imp_apb_to_scb#(apb_txn, axi_bus_scoreboard) apb_to_scb_imp;

  AXI_transfer  mst_mon_write_trans_s[$], mst_mon_read_trans_s[$];
  apb_txn       apb_to_scb_write_trans_s[$], apb_to_scb_read_trans_s[$], mst_mon_write_trans_op_s[$], mst_mon_read_trans_op_s[$];

  `uvm_component_utils_begin(axi_bus_scoreboard)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    // Construct the TLM interface
    // mst_drv_write_scb_imp = new("mst_drv_write_scb_imp", this);
    apb_to_scb_imp = new("apb_to_scb_imp", this);
    mst_mon_scb_imp = new("mst_mon_scb_imp", this);
  endfunction : new

  extern virtual task run_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
  // Additional class methods
//   extern virtual function void write_mst_drv_write_scb(AXI_transfer trx);
  extern virtual function void write_apb_to_scb(apb_txn trx);
  extern virtual function void write_mst_mon_scb(AXI_transfer trx);
  extern task deal_axi_write_trans();
  extern task deal_axi_read_trans();
  extern task deal_write_cmp_data();
  extern task deal_read_cmp_data();
endclass : axi_bus_scoreboard

task axi_bus_scoreboard::deal_axi_write_trans();

	AXI_transfer tr_temp;	
	apb_txn      apb_tr_temp;

	while(1) begin
		if(0 != mst_mon_write_trans_s.size()) begin
			tr_temp = new();
			tr_temp = mst_mon_write_trans_s.pop_front;
			if(tr_temp.mem_addrs.size()!=tr_temp.data.size())
				`uvm_error("scoreboard","mst_mon_write_trans addr and data size mismatch")
			if(tr_temp.addr[1:0]!=0) begin
				if(tr_temp.resp!=SLVERR) begin
					`uvm_error("scoreboard", "mst_mon_write_trans unaligned addr should response SLVERR")
				end
			end else if(tr_temp.size!=BYTE_4) begin
				if(tr_temp.resp!=SLVERR) begin
					`uvm_error("scoreboard", "mst_mon_write_trans wrong awsize should response SLVERR")
				end
			end else
				for(int i = 0; i < tr_temp.data.size(); i++)
				begin
					apb_tr_temp = new();
					apb_tr_temp.kind = apb_txn::WRITE;
					if(4'hf == tr_temp.strb[i]) begin
						apb_tr_temp.addr = tr_temp.mem_addrs[i];
						if(apb_tr_temp.addr>=32'h1000||apb_tr_temp.addr<32'h400) begin
							if(tr_temp.resp!=SLVERR) begin
								`uvm_error("scoreboard", "mst_mon_write_trans wrong addr should response SLVERR")
							end else begin
								`uvm_info("scoreboard", "mst_mon_write_trans wrong addr match SLVERR", UVM_HIGH)
								break;
							end
						end
						apb_tr_temp.data = (tr_temp.data[i] & 32'hffff_ffff);
						mst_mon_write_trans_op_s.push_back(apb_tr_temp);
					end else if(4'h0 != tr_temp.strb[i]) begin
						if(tr_temp.resp!=SLVERR) begin
							`uvm_error("scoreboard", "mst_mon_write_trans wrong strb should response SLVERR")
						end else begin
							`uvm_info("scoreboard", "mst_mon_write_trans wrong strb match SLVERR", UVM_HIGH)
							break;
						end
					end
				end
		end
		else begin
			@(posedge axi_bus_top.clk);
		end
	end 
endtask

task axi_bus_scoreboard::deal_axi_read_trans();

	AXI_transfer tr_temp;	
	apb_txn      apb_tr_temp;

	while(1) begin
		if(0 != mst_mon_read_trans_s.size()) begin
			tr_temp = new();
			tr_temp = mst_mon_read_trans_s.pop_front;
			if(tr_temp.mem_addrs.size()!=tr_temp.data.size())
				`uvm_error("scoreboard","mst_mon_read_trans addr and data size mismatch")
			if(tr_temp.addr[1:0]!=0) begin
				if(tr_temp.resp!=SLVERR) begin
					`uvm_error("scoreboard", "mst_mon_read_trans unaligned addr should response SLVERR")
				end
			end else if(tr_temp.size!=BYTE_4) begin
				if(tr_temp.resp!=SLVERR) begin
					`uvm_error("scoreboard", "mst_mon_read_trans wrong arsize should response SLVERR")
				end
			end else 
				for(int i = 0; i < tr_temp.data.size(); i++)
				begin
					apb_tr_temp = new();
					apb_tr_temp.kind = apb_txn::READ;
					apb_tr_temp.addr = tr_temp.mem_addrs[i];
					if(apb_tr_temp.addr>=32'h1000||apb_tr_temp.addr<32'h400) begin
						if(tr_temp.resp!=SLVERR) begin
							`uvm_error("scoreboard", "mst_mon_read_trans wrong addr should response SLVERR")
						end else begin
							`uvm_info("scoreboard", "mst_mon_read_trans wrong addr match SLVERR", UVM_HIGH)
							break;
						end
					end
					apb_tr_temp.data = (tr_temp.data[i] & 32'hffff_ffff);
					mst_mon_read_trans_op_s.push_back(apb_tr_temp);
				end 
		end
		else begin
			@(posedge axi_bus_top.clk);
		end
	end 
endtask

task axi_bus_scoreboard::deal_write_cmp_data();
	
	apb_txn    apb_tr_temp;
	apb_txn	   axi_to_apb_tr_temp;

	forever begin
		if(0 != mst_mon_write_trans_op_s.size()) begin
			axi_to_apb_tr_temp = mst_mon_write_trans_op_s.pop_front;
			if(apb_to_scb_write_trans_s.size()==0) begin
				`uvm_error("scoreboard", "apb_to_scb_write_trans_s is empty when deal_write_cmp_data");
			end else begin
				apb_tr_temp = apb_to_scb_write_trans_s.pop_front;
				if(apb_tr_temp.compare(axi_to_apb_tr_temp))
				begin
					`uvm_info("axi_bus_scoreboard::deal_write_cmp_data is OKAY",$psprintf("addr=%h,data=%h",apb_tr_temp.addr,apb_tr_temp.data),UVM_LOW)
				end else begin
					`uvm_error("scoreboard", "apb_to_scb_write_trans_s is not equal to mst_mon_write_trans_op_s");
				end
			end
		end
		else begin
			@(posedge axi_bus_top.clk);
		end
	end
endtask

task axi_bus_scoreboard::deal_read_cmp_data();
	apb_txn    apb_tr_temp;
	apb_txn	 axi_to_apb_tr_temp;
	
	forever begin
		if(0 != mst_mon_read_trans_op_s.size()) begin
			axi_to_apb_tr_temp = mst_mon_read_trans_op_s.pop_front;
			if(apb_to_scb_read_trans_s.size()==0) begin
				`uvm_error("scoreboard", "apb_to_scb_read_trans_s is empty when deal_read_cmp_data");
			end else begin
				apb_tr_temp = apb_to_scb_read_trans_s.pop_front;
				if(apb_tr_temp.compare(axi_to_apb_tr_temp))
				begin
					`uvm_info("axi_bus_scoreboard::deal_read_cmp_data is OKAY",$psprintf("addr=%h,data=%h",apb_tr_temp.addr,apb_tr_temp.data),UVM_LOW)
				end else begin
					`uvm_error("scoreboard", "apb_to_scb_read_trans_s is not equal to mst_mon_read_trans_op_s");
				end
			end
		end
		else begin
			@(posedge axi_bus_top.clk);
		end
	end
endtask

// UVM run() phase spawn sub events
task axi_bus_scoreboard::run_phase(uvm_phase phase);
    fork
		deal_axi_write_trans();
		deal_axi_read_trans();
		deal_write_cmp_data();
		deal_read_cmp_data();
    join
endtask : run_phase

function void axi_bus_scoreboard::check_phase(uvm_phase phase);

	if(0 != apb_to_scb_write_trans_s.size())
	begin
		for(int i = 0; i < apb_to_scb_write_trans_s.size(); i++)
		begin
			$display("apb_to_scb_write_trans_s[%d]=%h",i,apb_to_scb_write_trans_s[i]);
			apb_to_scb_write_trans_s[i].print();
		end
	end
	if(0 != apb_to_scb_read_trans_s.size())
	begin
		for(int i = 0; i < apb_to_scb_read_trans_s.size(); i++)
		begin
			$display("apb_to_scb_read_trans_s[%d]=%h",i,apb_to_scb_read_trans_s[i]);
			apb_to_scb_read_trans_s[i].print();
		end
	end
	if(0 != mst_mon_write_trans_op_s.size())
	begin
		for(int i = 0; i < mst_mon_write_trans_op_s.size(); i++)
		begin
			$display("mst_mon_write_trans_op_s[%d]=%h",i,mst_mon_write_trans_op_s[i]);
			mst_mon_write_trans_op_s[i].print();
		end
	end
	if(0 != mst_mon_read_trans_op_s.size())
	begin
		for(int i = 0; i < mst_mon_read_trans_op_s.size(); i++)
		begin
			$display("mst_mon_read_trans_op_s[%d]=%h",i,mst_mon_read_trans_op_s[i]);
			mst_mon_read_trans_op_s[i].print();
		end
	end

endfunction : check_phase

// TLM write() implementation
// function void axi_bus_scoreboard::write_mst_drv_write_scb(AXI_transfer trx);
// 	$display("DDDDDDDDDDD_drv_scb");
// 	trx.print();
// 	if(WRITE == trx.rw)
// 		mst_drv_write_trans_s.push_back(trx);
// endfunction : write_mst_drv_write_scb

function void axi_bus_scoreboard::write_apb_to_scb(apb_txn trx);
	if(apb_txn::WRITE == trx.kind) begin
		apb_to_scb_write_trans_s.push_back(trx);
		`uvm_info("DDDDDDDDDDD_apb_to_scb_READ", $sformatf("Transaction content:\n%s", trx.sprint()), UVM_LOW);
	end else begin
		apb_to_scb_read_trans_s.push_back(trx);
		`uvm_info("DDDDDDDDDDD_apb_to_scb_WRITE", $sformatf("Transaction content:\n%s", trx.sprint()), UVM_LOW);
	end
endfunction : write_apb_to_scb

function void axi_bus_scoreboard::write_mst_mon_scb(AXI_transfer trx);
	if(READ == trx.rw) begin
		mst_mon_read_trans_s.push_back(trx);
		`uvm_info("DDDDDDDDDDD_mon_scb_READ", $sformatf("Transaction content:\n%s", trx.sprint()), UVM_LOW);
	end else begin 
		mst_mon_write_trans_s.push_back(trx);
		`uvm_info("DDDDDDDDDDD_mon_scb_WRITE", $sformatf("Transaction content:\n%s", trx.sprint()), UVM_LOW);
	end
endfunction : write_mst_mon_scb

`endif // AXI_BUS_SCOREBOARD_SV
