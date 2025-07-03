/*--------------------------------------
// AXI PKG
// file : axi_pkg.sv
// author : SeanChen
// date : 2013/05/06
// notes
---------------------------------------*/

`ifndef AXI_PKG_SV
`define AXI_PKG_SV

`include "../public/axi_vip/common/axi_type.sv"
`include "../public/axi_vip/common/axi_conf.sv"
`include "../public/axi_vip/common/axi_transfer.sv"
`include "../public/axi_vip/common/axi_common.sv"

`include "../public/axi_vip/axi_master_pkg/axi_master_monitor.sv"
`include "../public/axi_vip/axi_master_pkg/axi_master_driver.sv"
`include "../public/axi_vip/axi_master_pkg/axi_master_sequencer.sv"
`include "../public/axi_vip/axi_master_pkg/axi_master_agent.sv"

`include "../public/axi_vip/axi_slaver_pkg/axi_slave_monitor.sv"
`include "../public/axi_vip/axi_slaver_pkg/axi_slave_driver.sv"
`include "../public/axi_vip/axi_slaver_pkg/axi_slave_sequencer.sv"
`include "../public/axi_vip/axi_slaver_pkg/axi_slave_agent.sv"

`include "../public/axi_vip/common/axi_env.sv"

`endif  // AXI_PKG_SV
