`ifndef AXI_BUS_FUN_COV_SV
`define AXI_BUS_FUN_COV_SV

`uvm_analysis_imp_decl(_axi_cov)
`uvm_analysis_imp_decl(_apb_cov)

class axi_bus_fun_cov extends uvm_component;

    `uvm_component_utils(axi_bus_fun_cov)
    uvm_analysis_imp_axi_cov #(AXI_transfer, axi_bus_fun_cov) axi_cov_imp;
    uvm_analysis_imp_apb_cov #(apb_txn, axi_bus_fun_cov) apb_cov_imp;

    // AXI_transfer axi_txn;
    // apb_txn apb_txn;

    bit coverage_enable = 1;

    covergroup axi_transfer_cg with function sample(AXI_transfer trx, int unsigned i);
        TRANS_ADDR : coverpoint trx.mem_addrs[i] {
            bins SLAVE_0 = {[32'h400:32'h7ff]};
            bins SLAVE_1 = {[32'h800:32'hbff]};
            bins SLAVE_2 = {[32'hc00:32'hfff]};
            bins NOT_SLAVE = default;
        }
        TRANS_ADDR_ALIGN : coverpoint trx.addr[1:0] {
            bins aligned = {2'b00};
            bins unaligned = default;
        }
        TRANS_DIRECTION : coverpoint trx.rw {
            bins READ   = {READ};
            bins WRITE  = {WRITE};
        }
        TRANS_LEN : coverpoint trx.len {
            bins len_1  = {LEN_1 };
            bins len_2  = {LEN_2 };
            bins len_3  = {LEN_3 };
            bins len_4  = {LEN_4 };
            bins len_5  = {LEN_5 };
            bins len_6  = {LEN_6 };
            bins len_7  = {LEN_7 };
            bins len_8  = {LEN_8 };
            bins len_9  = {LEN_9 };
            bins len_10 = {LEN_10};
            bins len_11 = {LEN_11};
            bins len_12 = {LEN_12};
            bins len_13 = {LEN_13};
            bins len_14 = {LEN_14};
            bins len_15 = {LEN_15};
            bins len_16 = {LEN_16};
            illegal_bins illegal_len = default; 
        }
        TRANS_SIZE : coverpoint trx.size {
            bins BYTE_4 = {BYTE_4};
            bins OTHER_BYTE = default;
        }
        TRANS_BURST : coverpoint trx.burst {
            bins FIXED = {FIXED};
            bins INCR  = {INCR};
            bins WRAP  = {WRAP};
            illegal_bins RESERVED_BURST = {RESERVED_BURST};
        }
        TRANS_DATA : coverpoint trx.data[i] {
            bins ZERO     = {0};
            bins NON_ZERO = default;
        }

        TRANS_STRB : coverpoint trx.strb[i] {
            bins ALL_ONES = {4'hf};
            bins ALL_ZEROS = {4'h0};
            bins PARTIAL_ONES = default;
        }

        TRANS_RESP: coverpoint trx.resp {
            bins OK = {OKAY};
            bins SLVERR = {SLVERR};
            illegal_bins EXOKAY_DECERR = {EXOKAY, DECERR};
        }

        TRANS_ADDR_X_TRANS_DIRECTION_X_TRANS_RESP: cross TRANS_ADDR, TRANS_DIRECTION, TRANS_RESP;
        TRANS_DIRECTION_X_TRANS_LEN: cross TRANS_DIRECTION, TRANS_LEN;
        TRANS_DIRECTION_X_TRANS_BURST: cross TRANS_DIRECTION, TRANS_BURST;

    endgroup : axi_transfer_cg

    covergroup apb_txn_cg with function sample(apb_txn trx);
        TRANS_ADDR : coverpoint trx.addr {
            bins SLAVE_0 = {[32'h400:32'h7ff]};
            bins SLAVE_1 = {[32'h800:32'hbff]};
            bins SLAVE_2 = {[32'hc00:32'hfff]};
            illegal_bins NOT_SLAVE = default;
        }

        TRANS_ADDR_ALIGN : coverpoint trx.addr[1:0] {
            bins aligned = {2'b00};
            illegal_bins unaligned = {2'b01, 2'b10, 2'b11};
        }

        TRANS_DATA: coverpoint trx.data {
            bins ZERO     = {0};
            bins NON_ZERO = default;
        }
    endgroup : apb_txn_cg

    function new(string name, uvm_component parent);
        super.new(name, parent);
        axi_transfer_cg = new();
        apb_txn_cg = new();
    endfunction : new

    extern virtual function void build_phase(uvm_phase phase);

    extern virtual function void write_axi_cov(AXI_transfer trx);
    extern virtual function void write_apb_cov(apb_txn trx);
endclass

function void axi_bus_fun_cov::build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_cov_imp = new("axi_cov_imp", this);
    apb_cov_imp = new("apb_cov_imp", this);
    // uvm_config_db #(bit):get(this, "", "coverage_enable", coverage_enable);
endfunction

function void axi_bus_fun_cov::write_axi_cov(AXI_transfer trx);
    if (coverage_enable) begin
        for(int i=0; i < trx.data.size(); i++) begin
            axi_transfer_cg.sample(trx, i);
        end
        // axi_transfer_cg.sample(trx);
    end
endfunction

function void axi_bus_fun_cov::write_apb_cov(apb_txn trx);
    if (coverage_enable) begin
        apb_txn_cg.sample(trx);
    end
endfunction

`endif  // AXI_BUS_FUN_COV_SV