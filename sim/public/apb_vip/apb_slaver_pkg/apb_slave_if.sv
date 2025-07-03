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

interface apb_slave_vif #(
				parameter integer C_AXI_ADDR_WIDTH 	= 32,
				parameter integer C_AXI_DATA_WIDTH 	= 32)( input APB_DRV_ACLK, input APB_MON_ACLK, input APB_ARESET_N);

   logic [C_AXI_ADDR_WIDTH-1:0] paddr;
   logic 						pwrite;
   logic 						psel;
   logic 						penable;
   logic [C_AXI_ADDR_WIDTH-1:0] pwdata;
   logic [C_AXI_ADDR_WIDTH-1:0] prdata;
   logic                        pready;
   logic                        pslveer;

    //from model to DUT
    clocking drv_cb @(posedge APB_DRV_ACLK);
		output  #0 prdata, pready, pslveer;
        input #1 paddr, pwrite, psel, penable, pwdata;
    endclocking
    
    clocking mon_cb @(posedge APB_MON_ACLK);
        input #1 prdata, paddr, pwrite, psel, penable, pwdata, pready, pslveer;
    endclocking
endinterface // apb_slave_vif

