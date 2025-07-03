`timescale 1ns/10ps
`include "uvm_macros.svh"
//import uvm_pkg::*;

`ifndef MST_NUM
	`define MST_NUM 1
`endif

`ifndef DATA_SIZE
	`define DATA_SIZE 32
`endif

`ifndef APB_DATA_SIZE
	`define APB_DATA_SIZE 32
`endif

`include "../public/axi_vip/axi_master_pkg/axi_master_vif.sv"
`include "../public/axi_vip/axi_slaver_pkg/axi_slave_vif.sv"
`include "../public/apb_vip/apb_slaver_pkg/apb_slave_if.sv"

module axi_bus_top;

	parameter PERIOD          = 10;

    reg clk;
	reg resetn;
	reg psel_s0;
	reg psel_s1;
	reg psel_s2;
	reg prdata0;
	reg prdata1;
	reg prdata2;

	AXI_master_vif  axi_bus_mst_io[`MST_NUM](clk,clk,resetn);
	apb_slave_vif   apb_bus_slv_io(clk,clk,resetn);

	DW_axi_x2p     DW_axi_x2p_u (
				       .aclk             (clk                          ),                       
				       .aresetn          (resetn                       ),
				       // Write Address Channel from Master1
				       .awvalid          (axi_bus_mst_io[0].AXI_AWVALID),
				       .awaddr           (axi_bus_mst_io[0].AXI_AWADDR ),
				       .awid             (axi_bus_mst_io[0].AXI_AWID   ),
				       .awlen            (axi_bus_mst_io[0].AXI_AWLEN  ),
				       .awsize           (axi_bus_mst_io[0].AXI_AWSIZE ),
				       .awburst          (axi_bus_mst_io[0].AXI_AWBURST),
				       .awlock           (axi_bus_mst_io[0].AXI_AWLOCK ),
				       .awcache          (axi_bus_mst_io[0].AXI_AWCACHE),
				       .awprot           (axi_bus_mst_io[0].AXI_AWPROT ),
				       .awready          (axi_bus_mst_io[0].AXI_AWREADY),
				       // Write Data Channel from Master1
				       .wvalid           (axi_bus_mst_io[0].AXI_WVALID ),
				       .wid              (axi_bus_mst_io[0].AXI_WID    ),
				       .wdata            (axi_bus_mst_io[0].AXI_WDATA  ),
				       .wstrb            (axi_bus_mst_io[0].AXI_WSTRB  ),
				       .wlast            (axi_bus_mst_io[0].AXI_WLAST  ),
				       .wready           (axi_bus_mst_io[0].AXI_WREADY ),
				       // Write Response Channel from Master1
				       .bvalid           (axi_bus_mst_io[0].AXI_BVALID ),
				       .bid              (axi_bus_mst_io[0].AXI_BID    ),
				       .bresp            (axi_bus_mst_io[0].AXI_BRESP  ),
				       .bready           (axi_bus_mst_io[0].AXI_BREADY ),
				       // Read Address Channel from Master1
				       .arvalid          (axi_bus_mst_io[0].AXI_ARVALID),
				       .arid             (axi_bus_mst_io[0].AXI_ARID   ),
				       .araddr           (axi_bus_mst_io[0].AXI_ARADDR ),
				       .arlen            (axi_bus_mst_io[0].AXI_ARLEN  ),
				       .arsize           (axi_bus_mst_io[0].AXI_ARSIZE ),
				       .arburst          (axi_bus_mst_io[0].AXI_ARBURST),
				       .arlock           (axi_bus_mst_io[0].AXI_ARLOCK ),
				       .arcache          (axi_bus_mst_io[0].AXI_ARCACHE),
				       .arprot           (axi_bus_mst_io[0].AXI_ARPROT ),
				       .arready          (axi_bus_mst_io[0].AXI_ARREADY),
				       // Read Data Channel from Master1
				       .rvalid           (axi_bus_mst_io[0].AXI_RVALID ),
				       .rid              (axi_bus_mst_io[0].AXI_RID    ),
				       .rdata            (axi_bus_mst_io[0].AXI_RDATA  ),
				       .rresp            (axi_bus_mst_io[0].AXI_RRESP  ),
				       .rlast            (axi_bus_mst_io[0].AXI_RLAST  ),
				       .rready           (axi_bus_mst_io[0].AXI_RREADY ),
						//apb
					   .pclk             (clk                          ),
					   .presetn          (resetn                       ),
					   .psel_s0          (psel_s0          ),
					   .psel_s1          (psel_s1      ),
					   .psel_s2          (psel_s2      ),
				       .paddr            (apb_bus_slv_io.paddr         ),
				       .penable          (apb_bus_slv_io.penable       ),
				       .pwdata           (apb_bus_slv_io.pwdata        ),
				       .pwrite           (apb_bus_slv_io.pwrite        ), 
				//	   .pready_s0        (apb_bus_slv_io.pready        ),
				       .prdata_s0        (apb_bus_slv_io.prdata        ),
					.prdata_s1        (apb_bus_slv_io.prdata        ),
					.prdata_s2        (apb_bus_slv_io.prdata        )
					 );

    initial begin
        assign apb_bus_slv_io.psel = psel_s0 | psel_s1 | psel_s2;
    end

    initial begin
        clk = 0;
        forever begin
            #(PERIOD/2);clk = ~clk;
        end
    end

    initial begin
        resetn = 1;
        #50;resetn = 0;
        #50;resetn = 1;
    end

    initial begin

        //master
        axi_bus_mst_io[0].AXI_AWID    <= 0; 
		axi_bus_mst_io[0].AXI_AWADDR  <= 0; 
		axi_bus_mst_io[0].AXI_AWREG   <= 0; 
		axi_bus_mst_io[0].AXI_AWLEN   <= 0; 
        axi_bus_mst_io[0].AXI_AWSIZE  <= 0; 
        axi_bus_mst_io[0].AXI_AWBURST <= 0; 
        axi_bus_mst_io[0].AXI_AWLOCK  <= 0; 
        axi_bus_mst_io[0].AXI_AWCACHE <= 0; 
        axi_bus_mst_io[0].AXI_AWPROT  <= 0; 
        axi_bus_mst_io[0].AXI_AWQOS   <= 0; 
        axi_bus_mst_io[0].AXI_AWVALID <= 0; 
        axi_bus_mst_io[0].AXI_WID     <= 0; 
        axi_bus_mst_io[0].AXI_WDATA   <= 0; 
        axi_bus_mst_io[0].AXI_WSTRB   <= 0; 
        axi_bus_mst_io[0].AXI_WVALID  <= 0; 
        axi_bus_mst_io[0].AXI_WLAST   <= 0; 
        axi_bus_mst_io[0].AXI_BREADY  <= 0; 
        axi_bus_mst_io[0].AXI_ARID    <= 0; 
        axi_bus_mst_io[0].AXI_ARADDR  <= 0; 
        axi_bus_mst_io[0].AXI_ARREG   <= 0; 
        axi_bus_mst_io[0].AXI_ARLEN   <= 0; 
        axi_bus_mst_io[0].AXI_ARSIZE  <= 0; 
        axi_bus_mst_io[0].AXI_ARBURST <= 0; 
        axi_bus_mst_io[0].AXI_ARLOCK  <= 0; 
        axi_bus_mst_io[0].AXI_ARCACHE <= 0; 
        axi_bus_mst_io[0].AXI_ARPROT  <= 0; 
        axi_bus_mst_io[0].AXI_ARQOS   <= 0; 
        axi_bus_mst_io[0].AXI_ARVALID <= 0; 
        axi_bus_mst_io[0].AXI_RREADY  <= 0;
		//apb
		apb_bus_slv_io.prdata         <= 0;
		apb_bus_slv_io.pready         <= 1;
		apb_bus_slv_io.pslveer        <= 0;
    end
//---------------------------------------------
//		set fsdb_file commend
//--------------------------------------------

	initial begin
		//`ifdef DUMP
			$fsdbAutoSwitchDumpfile(800,"waveform.fsdb",50);
			$fsdbDumpvars(0, axi_bus_top);
			$fsdbDumpon;
		//`endif
	end
   





    initial begin
        uvm_config_db#(virtual AXI_master_vif)::set(null, "uvm_test_top.m_axi_bus_env.m_axi_env.m_masters[0].*", "AXI_master_vif", axi_bus_mst_io[0]);
        uvm_config_db#(virtual apb_slave_vif)::set(null,"uvm_test_top.m_axi_bus_env.m_apb_slave_agent.*","apb_slave_vif",apb_bus_slv_io);
        run_test();
    end

endmodule
