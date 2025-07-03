////////////////////////////////////////////////////////////////////////////////
//
// MIT License
//
// Copyright (c) 2017 Smartfox Data Solutions Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////


// TO DO: handle pready and pslverr
`ifndef APB_SLAVE_MONITOR_SV
`define APB_SLAVE_MONITOR_SV

class apb_slave_mon extends uvm_monitor;
   protected virtual interface apb_slave_vif vif;

   uvm_analysis_port #(apb_txn) item_collected_port;

   protected apb_txn txn;

   `uvm_component_utils_begin(apb_slave_mon)
   `uvm_component_utils_end

   function new (string name, uvm_component parent);
      super.new(name, parent);
      //txn = new();
      item_collected_port = new("item_collected_port", this);
   endfunction // new

   function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual interface apb_slave_vif)::get(this, "", "apb_slave_vif", vif))
	`uvm_fatal("NOVIF",
		   {"virtual interface must be set for: ",
                    get_full_name(), ".vif"});
   endfunction // build_phase

   virtual task run_phase (uvm_phase phase);
      fork
	 	collect_transactions();
		assert_penable_op();
      join
   endtask // run_phase

   virtual protected task collect_transactions();
     forever begin
		 txn = new();
		 if (vif.APB_ARESET_N == 'b0) begin
		   @(posedge vif.APB_ARESET_N);
		 end

		@(vif.mon_cb iff((vif.psel == 1'b1) && (vif.penable == 1'b1)));
	 	if (vif.pwrite == 'b0) begin
			@(vif.mon_cb);
			txn.kind = apb_txn::READ;
		  	txn.data = vif.mon_cb.prdata;
		  	txn.addr = vif.mon_cb.paddr;
		end
		else begin
			txn.kind = apb_txn::WRITE;
		  	txn.data = vif.mon_cb.pwdata;
		  	txn.addr = vif.mon_cb.paddr;
		end
		//`uvm_info("MON", txn.convert2string(), UVM_LOW)
		item_collected_port.write(txn);
     end // forever begin
   endtask // collect_transactions
 
   virtual protected task assert_penable_op();
     forever begin
		 if (vif.APB_ARESET_N == 'b0) begin
		   @(posedge vif.APB_ARESET_N);
		 end

		 @(posedge vif.APB_MON_ACLK iff(vif.mon_cb.psel == 'b1));
		 @(posedge vif.APB_MON_ACLK);
		 if(0 == vif.mon_cb.penable)
		 begin
		 	`uvm_warning("MON", "APB failed to assert penable after psel cycle")
		 end 
		 while(1 == vif.penable) begin
			@(posedge vif.APB_MON_ACLK);
		 end
     end // forever begin
   endtask // collect_transactions  
endclass // apb_slave_mon
`endif
