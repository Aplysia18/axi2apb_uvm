`ifndef AXI_BUS_SCOREBOARD_SV
`define AXI_BUS_SCOREBOARD_SV
`uvm_analysis_imp_decl(_mst_drv_write_scb)
`uvm_analysis_imp_decl(_mst_mon_read_scb)
`uvm_analysis_imp_decl(_apb_to_scb)

class axi_bus_scoreboard extends uvm_scoreboard;

  uvm_analysis_imp_mst_drv_write_scb#(AXI_transfer, axi_bus_scoreboard) mst_drv_write_scb_imp;
  uvm_analysis_imp_mst_mon_read_scb#(AXI_transfer, axi_bus_scoreboard) mst_mon_read_scb_imp;
  uvm_analysis_imp_apb_to_scb#(apb_txn, axi_bus_scoreboard) apb_to_scb_imp;

  AXI_transfer  mst_drv_write_trans_s[$], mst_mon_read_trans_s[$];
  apb_txn       apb_to_scb_write_trans_s[$], apb_to_scb_read_trans_s[$], mst_drv_write_trans_op_s[$], mst_mon_read_trans_op_s[$];

  `uvm_component_utils_begin(axi_bus_scoreboard)
  `uvm_component_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name, uvm_component parent);
    super.new(name, parent);
    // Construct the TLM interface
    mst_drv_write_scb_imp = new("mst_drv_write_scb_imp", this);
    apb_to_scb_imp = new("apb_to_scb_imp", this);
    mst_mon_read_scb_imp = new("mst_mon_read_scb_imp", this);
  endfunction : new

  extern virtual task run_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
  // Additional class methods
  extern virtual function void write_mst_drv_write_scb(AXI_transfer trx);
  extern virtual function void write_apb_to_scb(apb_txn trx);
  extern virtual function void write_mst_mon_read_scb(AXI_transfer trx);
  extern task deal_axi_write_trans();
  extern task deal_axi_read_trans();
  extern task deal_write_cmp_data();
  extern task deal_read_cmp_data();
endclass : axi_bus_scoreboard

task axi_bus_scoreboard::deal_axi_write_trans();

	AXI_transfer tr_temp;	
	apb_txn      apb_tr_temp;

	while(1) begin
		if(0 != mst_drv_write_trans_s.size()) begin
			tr_temp = new();
			tr_temp = mst_drv_write_trans_s.pop_front;
			for(int i = 0; i < tr_temp.data.size(); i++)
			begin
				apb_tr_temp = new();
				apb_tr_temp.kind = apb_txn::WRITE;
				if(8'hff == tr_temp.strb[i]) begin
					apb_tr_temp.addr = tr_temp.addr + i*4;
					apb_tr_temp.data = (tr_temp.data[i] & 32'hffff_ffff);
					mst_drv_write_trans_op_s.push_back(apb_tr_temp);
					apb_tr_temp = new();
					apb_tr_temp.addr = tr_temp.addr + i*4 + 4;
					apb_tr_temp.data = (tr_temp.data[i] >> 32);
					mst_drv_write_trans_op_s.push_back(apb_tr_temp);
				end
				else if(8'hf == tr_temp.strb[i]) begin
					apb_tr_temp.addr = tr_temp.addr + i*4;
					apb_tr_temp.data = (tr_temp.data[i] & 32'hffff_ffff);
					mst_drv_write_trans_op_s.push_back(apb_tr_temp);
				end
				else if(8'hf0 == tr_temp.strb[i]) begin
					apb_tr_temp.addr = tr_temp.addr + i*4 + 4;
					apb_tr_temp.data = (tr_temp.data[i] >> 32);
					mst_drv_write_trans_op_s.push_back(apb_tr_temp);
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
			for(int i = 0; i < tr_temp.data.size(); i++)
			begin
				apb_tr_temp = new();
				apb_tr_temp.kind = apb_txn::READ;
				apb_tr_temp.addr = tr_temp.addr + i*4;
				apb_tr_temp.data = (tr_temp.data[i] & 32'hffff_ffff);
				mst_mon_read_trans_op_s.push_back(apb_tr_temp);
				//apb_tr_temp = new();
				//apb_tr_temp.addr = tr_temp.addr + i*4 + 4;
				//apb_tr_temp.data = (tr_temp.data[i] >> 32);
				//mst_mon_read_trans_op_s.push_back(apb_tr_temp);
			end 
		end
		else begin
			@(posedge axi_bus_top.clk);
		end
	end 
endtask

task axi_bus_scoreboard::deal_write_cmp_data();
	
	apb_txn    apb_tr_temp;
	bit        flag;

	while(1) begin
		if((0 != mst_drv_write_trans_op_s.size()) && (0 != apb_to_scb_write_trans_s.size())) begin
			flag = 0;
			apb_tr_temp = apb_to_scb_write_trans_s.pop_front;
			for(int i = 0; i < mst_drv_write_trans_op_s.size(); i++)
			begin
				if(apb_tr_temp.addr == mst_drv_write_trans_op_s[i].addr)
				begin
					flag = 1;
					if(apb_tr_temp.data == mst_drv_write_trans_op_s[i].data) begin
						`uvm_info("axi_bus_scoreboard::deal_write_cmp_data is OKAY",$psprintf("addr=%h,data=%h",apb_tr_temp.addr,apb_tr_temp.data),UVM_LOW)
						mst_drv_write_trans_op_s.delete(i);
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

task axi_bus_scoreboard::deal_read_cmp_data();
	apb_txn    apb_tr_temp;
	bit        flag;

	while(1) begin
		if((0 != mst_mon_read_trans_op_s.size()) && (0 != apb_to_scb_read_trans_s.size())) begin
			flag = 0;
			apb_tr_temp = apb_to_scb_read_trans_s.pop_front;
			for(int i = 0; i < mst_mon_read_trans_op_s.size(); i++)
			begin
				if(apb_tr_temp.addr == mst_mon_read_trans_op_s[i].addr)
				begin
					flag = 1;
					if(apb_tr_temp.data == mst_mon_read_trans_op_s[i].data) begin
						`uvm_info("axi_bus_scoreboard::deal_read_cmp_data is OKAY",$psprintf("addr=%h,data=%h",apb_tr_temp.addr,apb_tr_temp.data),UVM_LOW)
						mst_mon_read_trans_op_s.delete(i);
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
		end
	end
	if(0 != apb_to_scb_read_trans_s.size())
	begin
		for(int i = 0; i < apb_to_scb_read_trans_s.size(); i++)
		begin
			$display("apb_to_scb_read_trans_s[%d]=%h",i,apb_to_scb_read_trans_s[i]);
		end
	end
	if(0 != mst_drv_write_trans_op_s.size())
	begin
		for(int i = 0; i < mst_drv_write_trans_op_s.size(); i++)
		begin
			$display("mst_drv_write_trans_op_s[%d]=%h",i,mst_drv_write_trans_op_s[i]);
		end
	end
	if(0 != mst_mon_read_trans_op_s.size())
	begin
		for(int i = 0; i < mst_mon_read_trans_op_s.size(); i++)
		begin
			$display("mst_mon_read_trans_op_s[%d]=%h",i,mst_mon_read_trans_op_s[i]);
		end
	end

endfunction : check_phase

// TLM write() implementation
function void axi_bus_scoreboard::write_mst_drv_write_scb(AXI_transfer trx);
	//$display("DDDDDDDDDDD_drv_scb");
	//trx.print();
	if(WRITE == trx.rw)
		mst_drv_write_trans_s.push_back(trx);
endfunction : write_mst_drv_write_scb

function void axi_bus_scoreboard::write_apb_to_scb(apb_txn trx);
	$display("DDDDDDDDDDD_apb_to_scb");
	trx.print();
	if(apb_txn::WRITE == trx.kind)
		apb_to_scb_write_trans_s.push_back(trx);
	else
		apb_to_scb_read_trans_s.push_back(trx);
endfunction : write_apb_to_scb

function void axi_bus_scoreboard::write_mst_mon_read_scb(AXI_transfer trx);
	$display("DDDDDDDDDDD_mon_scb");
	trx.print();
	if(READ == trx.rw)
		mst_mon_read_trans_s.push_back(trx);
endfunction : write_mst_mon_read_scb

`endif // AXI_BUS_SCOREBOARD_SV
