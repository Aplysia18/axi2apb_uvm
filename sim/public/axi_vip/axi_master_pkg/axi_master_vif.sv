
/*--------------------------------------
// AXI virtual interface
// description : axi virtual interface which is a connection pool interface for DUT and Virtual test
// file : axi_master_vif.sv
// author : FX
// date : 2018/04/10
---------------------------------------*/

`timescale 1ns/10ps

interface AXI_master_vif #(
				parameter integer C_AXI_ID_WIDTH 	= 8, // default 4
				parameter integer C_AXI_ADDR_WIDTH 	= 32,
        parameter integer C_AXI_REG_WITH    = 4,
				parameter integer C_AXI_DATA_WIDTH 	= 64,
				parameter integer C_AXI_LEN_WIDTH 	= 4,  // default 4
				parameter integer C_AXI_SIZE_WIDTH 	= 3,
				parameter integer C_AXI_BURST_WIDTH = 2,
				parameter integer C_AXI_CACHE_WIDTH = 4,
				parameter integer C_AXI_PROT_WIDTH 	= 3,
				parameter integer C_AXI_QOS_WIDTH	= 4,
				parameter integer C_AXI_STRB_WIDTH 	= 8,
				parameter integer C_AXI_RESP_WIDTH 	= 2,
        parameter integer C_AXI_LOCK_WIDTH  = 2,
				parameter integer C_AXI_VALID_WIDTH = 1,
				parameter integer C_AXI_READY_WIDTH = 1,
				parameter integer C_AXI_LAST_WIDTH  = 1,
				parameter string name = "master_vif"

)( input AXI_DRV_ACLK, input AXI_MON_ACLK, input AXI_ARESET_N);

	// control flags
	  bit has_checks 		= 1;
	  bit has_coverage	= 1;


	// AXI address write phase
    logic [C_AXI_ID_WIDTH-1:0]		AXI_AWID; //axi4 remove it
    logic [C_AXI_ADDR_WIDTH-1:0]	AXI_AWADDR;
    logic [C_AXI_REG_WITH-1:0]    AXI_AWREG;
    logic [C_AXI_LEN_WIDTH-1:0]		AXI_AWLEN;
    logic [C_AXI_SIZE_WIDTH-1:0]	AXI_AWSIZE;
    logic [C_AXI_BURST_WIDTH-1:0]	AXI_AWBURST;
    logic [C_AXI_LOCK_WIDTH-1:0]	AXI_AWLOCK;
    logic [C_AXI_CACHE_WIDTH-1:0]	AXI_AWCACHE;
    logic [C_AXI_PROT_WIDTH-1:0]	AXI_AWPROT;
    logic [C_AXI_QOS_WIDTH-1:0]		AXI_AWQOS;
    logic [C_AXI_VALID_WIDTH-1:0]	AXI_AWVALID;
    logic [C_AXI_READY_WIDTH-1:0]	AXI_AWREADY;

	// AXI data write phase
    logic [C_AXI_ID_WIDTH-1:-0]   AXI_WID;
    logic [C_AXI_DATA_WIDTH-1:0]	AXI_WDATA;
    logic [C_AXI_STRB_WIDTH-1:0]	AXI_WSTRB;
    logic [C_AXI_LAST_WIDTH-1:0]	AXI_WLAST;
    logic [C_AXI_VALID_WIDTH-1:0] AXI_WVALID;
    logic [C_AXI_READY_WIDTH-1:0]	AXI_WREADY;

	// AXI response write phase
    logic [C_AXI_ID_WIDTH-1:0]		AXI_BID;
    logic [C_AXI_RESP_WIDTH-1:0]	AXI_BRESP;
    logic [C_AXI_VALID_WIDTH-1:0]	AXI_BVALID;
    logic [C_AXI_READY_WIDTH-1:0]	AXI_BREADY;

	// AXI address read phase
    logic [C_AXI_ID_WIDTH-1:0]		AXI_ARID;
    logic [C_AXI_ADDR_WIDTH-1:0]	AXI_ARADDR;
    logic [C_AXI_REG_WITH-1:0]    AXI_ARREG;
    logic [C_AXI_LEN_WIDTH-1:0]		AXI_ARLEN;
    logic [C_AXI_SIZE_WIDTH-1:0]	AXI_ARSIZE;
    logic [C_AXI_BURST_WIDTH-1:0]	AXI_ARBURST;
    logic [C_AXI_LOCK_WIDTH-1:0]	AXI_ARLOCK;
    logic [C_AXI_CACHE_WIDTH-1:0]	AXI_ARCACHE;
    logic [C_AXI_PROT_WIDTH-1:0]	AXI_ARPROT;
    logic [C_AXI_QOS_WIDTH-1:0]		AXI_ARQOS;
    logic [C_AXI_VALID_WIDTH-1:0]	AXI_ARVALID;
    logic [C_AXI_READY_WIDTH-1:0]	AXI_ARREADY;

	// AXI data read phase
    logic [C_AXI_ID_WIDTH-1:0]		AXI_RID;
    logic [C_AXI_DATA_WIDTH-1:0]	AXI_RDATA;
    logic [C_AXI_RESP_WIDTH-1:0]	AXI_RRESP;
    logic [C_AXI_LAST_WIDTH-1:0]	AXI_RLAST;
    logic [C_AXI_VALID_WIDTH-1:0]	AXI_RVALID;
    logic [C_AXI_READY_WIDTH-1:0]	AXI_RREADY;

    //from model to DUT
    clocking drv_cb @(posedge AXI_DRV_ACLK);
		output  #1 AXI_AWID, AXI_AWADDR, AXI_AWREG, AXI_AWLEN, AXI_AWSIZE, AXI_AWBURST, AXI_AWLOCK, AXI_AWCACHE, AXI_AWPROT, AXI_AWQOS, AXI_AWVALID, AXI_WID, AXI_WDATA, AXI_WSTRB, AXI_WVALID, AXI_WLAST, AXI_BREADY, AXI_ARID, AXI_ARADDR, AXI_ARREG, AXI_ARLEN, AXI_ARSIZE, AXI_ARBURST, AXI_ARLOCK, AXI_ARCACHE, AXI_ARPROT, AXI_ARQOS, AXI_ARVALID, AXI_RREADY;
        input #1 AXI_AWREADY, AXI_WREADY, AXI_BID, AXI_BRESP, AXI_BVALID, AXI_ARREADY, AXI_RID, AXI_RDATA, AXI_RRESP, AXI_RLAST, AXI_RVALID;
    endclocking
    
    clocking mon_cb @(posedge AXI_MON_ACLK);
        input #1 AXI_AWID, AXI_AWADDR, AXI_AWREG, AXI_AWLEN, AXI_AWSIZE, AXI_AWBURST, AXI_AWLOCK, AXI_AWCACHE, AXI_AWPROT, AXI_AWQOS, AXI_AWVALID, AXI_WID, AXI_WDATA, AXI_WSTRB, AXI_WVALID, AXI_WLAST, AXI_BREADY, AXI_ARID, AXI_ARADDR, AXI_ARREG, AXI_ARLEN, AXI_ARSIZE, AXI_ARBURST, AXI_ARLOCK, AXI_ARCACHE, AXI_ARPROT, AXI_ARQOS, AXI_ARVALID, AXI_RREADY, AXI_AWREADY, AXI_WREADY, AXI_BID, AXI_BRESP, AXI_BVALID, AXI_ARREADY, AXI_RID, AXI_RDATA, AXI_RRESP, AXI_RLAST, AXI_RVALID;
    endclocking

always @(negedge AXI_MON_ACLK)
begin

// write address must not be X or Z during address write phase
assertWriteAddrUnknown:assert property (
    disable iff(!has_checks)
		  ($onehot(AXI_AWVALID) && $onehot(AXI_AWREADY) |-> !$isunknown(AXI_AWADDR)))
		else
		  $error({$psprintf("ERR_AXI_AWADDR %s went to X or Z during address write phase when AXI_AWVALID=1", name)});

// write data must not be X or Z during data write phase
assertWriteDataUnknown:assert property (
    disable iff(!has_checks)
		  ($onehot(AXI_WVALID) && $onehot(AXI_WREADY) |-> !$isunknown(AXI_WDATA)))
		else
		  $error({$psprintf("ERR_AXI_WDATA %s went to X or Z during data write phase when AXI_WVALID=1", name)});

// write resp must not be X or Z during resp write phase
assertWriteRespUnKnown:assert property (
    disable iff(!has_checks)
      ($onehot(AXI_BVALID) && $onehot(AXI_BREADY) |-> !$isunknown(AXI_BRESP)))
    else
      $error({$psprintf("ERR_AXI_BRESP %s went to X or Z during response write phase when AXI_BVALID=1", name)});

// read address must not be X or Z during address read phase
assertReadAddrUnKnown:assert property (
    disable iff(!has_checks)
      ($onehot(AXI_ARVALID) && $onehot(AXI_ARREADY) |-> !$isunknown(AXI_ARADDR)))
    else
      $error({$psprintf("ERR_AXI_ARADDR %s went to X or Z during address read phase when AXI_ARVALID=1", name)});

// read data must not be X or Z during read data phase
assertReadDataUnKnown:assert property (
    disable iff(!has_checks)
      ($onehot(AXI_RVALID) && $onehot(AXI_RREADY) |-> !$isunknown(AXI_RDATA)))
    else
      $error({$psprintf("ERR_AXI_AWDATA %s went to X or Z during data read phase when AXI_RVALID=1", name)});

// assert each pin has value not unknown

end

endinterface : AXI_master_vif

