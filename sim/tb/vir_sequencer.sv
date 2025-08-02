`ifndef VIR_SEQUENCER_SV
`define VIR_SEQUENCER_SV

class vir_sequencer extends uvm_sequencer;
	AXI_master_sequencer  axi_bus_mst_sqr[`MST_NUM];  
    reset_sequencer        rst_sqr;

    extern function new(string name,uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    `uvm_component_utils(vir_sequencer)

endclass

function vir_sequencer::new(string name,uvm_component parent);
    super.new(name,parent);
endfunction
	
function void vir_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

`endif
