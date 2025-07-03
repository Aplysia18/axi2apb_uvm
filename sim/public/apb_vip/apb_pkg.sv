/*--------------------------------------
// APB PKG
// file : apb_pkg.sv
// author : SeanChen
// date : 2013/05/06
// notes
---------------------------------------*/

`ifndef APB_PKG_SV
`define APB_PKG_SV

`include "../public/apb_vip/common/apb_txn.sv"

//`include "../public/apb_vip/apb_slaver_pkg/apb_slave_if.sv"
`include "../public/apb_vip/apb_slaver_pkg/apb_slave_mon.sv"
`include "../public/apb_vip/apb_slaver_pkg/apb_slave_drv.sv"
`include "../public/apb_vip/apb_slaver_pkg/apb_slave_agent.sv"

`endif  // APB_PKG_SV
