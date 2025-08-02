`ifndef RST_TR_SV
`define RST_TR_SV

class reset_tr extends uvm_sequence_item;

    typedef enum {ASSERT, DEASSERT} kind_e;
    rand kind_e kind;
    rand int unsigned cycles = 1;

    `uvm_object_utils_begin(reset_tr)
        `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
        `uvm_field_int(cycles, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="reset_tr");
        super.new(name);
        `uvm_info(get_type_name(), "Creating reset_tr", UVM_MEDIUM);
    endfunction

endclass

`endif