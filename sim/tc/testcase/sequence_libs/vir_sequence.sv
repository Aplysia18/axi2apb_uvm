`ifndef VIR_SEQUENCE_SV
`define VIR_SEQUENCE_SV

class vir_sequence extends uvm_sequence;
    `uvm_object_utils(vir_sequence)
    
    `uvm_declare_p_sequencer(vir_sequencer)

    // reset_seq r_seq;
    AXI_master_base_seq axi_mst_seq;

    function new(string name = "vir_sequence");
        super.new(name);
        `uvm_info(get_type_name(), "Creating vir_sequence", UVM_HIGH);
    endfunction : new

endclass

`endif // VIR_SEQUENCE_SV