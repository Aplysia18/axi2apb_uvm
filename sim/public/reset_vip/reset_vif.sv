`ifndef RST_VIF_SV
`define RST_VIF_SV

interface reset_vif(input logic clk);
    logic reset_n;

    clocking drv_cb @(posedge clk);
        output #1 reset_n;
    endclocking

    clocking mon_cb @(posedge clk);
        input #1 reset_n;
    endclocking

endinterface: reset_vif

`endif