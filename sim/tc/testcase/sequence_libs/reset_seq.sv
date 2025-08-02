`ifndef RESET_SEQ_SV
`define RESET_SEQ_SV

class reset_seq extends uvm_sequence #(reset_tr);

    `uvm_object_utils(reset_seq)

    function new(string name = "reset_seq");
        super.new(name);
        `uvm_info(get_type_name(), "Creating reset_seq", UVM_HIGH);
    endfunction : new

    virtual task pre_start();
        `uvm_info(get_type_name(), "Pre-starting reset_seq", UVM_HIGH);
        if(starting_phase != null) begin
            starting_phase.raise_objection(this, {"Running sequence '", get_full_name(), "'"});
        end
    endtask

    virtual task post_start();
        `uvm_info(get_type_name(), "Post-starting reset_seq", UVM_HIGH);
        if(starting_phase != null) begin
            starting_phase.drop_objection(this, {"Completed sequence '", get_full_name(), "'"});
        end
    endtask

    virtual task body();
        `uvm_do_with(req, {kind == DEASSERT; cycles == 1;});
        `uvm_do_with(req, {kind == ASSERT; cycles == 1;});
        `uvm_do_with(req, {kind == DEASSERT; cycles == 15;});
    endtask : body

endclass

`endif // RESET_SEQ_SV