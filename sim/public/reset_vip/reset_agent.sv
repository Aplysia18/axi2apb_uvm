`ifndef RESET_AGENT_SV
`define RESET_AGENT_SV

typedef class reset_driver;
typedef class reset_sequencer;
typedef class reset_monitor;

class reset_agent extends uvm_agent;

    `uvm_component_utils(reset_agent)

    virtual reset_vif rst_vif;

    reset_driver     drv;
    reset_sequencer  sqr;
    reset_monitor    mon;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Creating reset_agent", UVM_HIGH);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Building reset_agent", UVM_HIGH);

        // if (!uvm_config_db#(virtual reset_vif)::get(this, "", "rst_vif", rst_vif)) begin
        //     `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".rst_vif"});
        // end
        uvm_config_db#(virtual reset_vif)::set(this, "*", "rst_vif", rst_vif);

        // uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);
        if(is_active==UVM_ACTIVE) begin
            drv = reset_driver::type_id::create("drv", this);
            sqr = reset_sequencer::type_id::create("sqr", this);
        end
        mon = reset_monitor::type_id::create("mon", this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connecting reset_agent", UVM_HIGH);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
            // mon.analysis_port.
        end
    endfunction

endclass : reset_agent

class reset_driver extends uvm_driver #(reset_tr);

    virtual reset_vif rst_vif;
    `uvm_component_utils(reset_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Creating reset_driver", UVM_HIGH);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Building reset_driver", UVM_HIGH);
        if (!uvm_config_db#(virtual reset_vif)::get(this, "", "rst_vif", rst_vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".rst_vif"});
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end
    endtask : run_phase

    virtual task drive(reset_tr req);
        `uvm_info(get_type_name(), $sformatf("Driving reset request: %s, cycles: %0d", req.kind.name(), req.cycles), UVM_HIGH);
        if (req.kind == reset_tr::ASSERT) begin
            rst_vif.reset_n <= 0;
            repeat(req.cycles) @(rst_vif.drv_cb);
            `uvm_info(get_type_name(), "Reset asserted", UVM_HIGH);
        end else if (req.kind == reset_tr::DEASSERT) begin
            rst_vif.reset_n <= 1;
            repeat(req.cycles) @(rst_vif.drv_cb);
            `uvm_info(get_type_name(), "Reset deasserted", UVM_HIGH);
        end
    endtask : drive

endclass : reset_driver

class reset_sequencer extends uvm_sequencer #(reset_tr);

    `uvm_component_utils(reset_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : reset_sequencer

class reset_monitor extends uvm_monitor;
    virtual reset_vif rst_vif;
    // uvm_analysis_port #(reset_tr) analysis_port;
    protected reset_tr tr;

    uvm_event reset_event;
    
    `uvm_component_utils(reset_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Building reset_monitor", UVM_HIGH);
        if (!uvm_config_db#(virtual reset_vif)::get(this, "", "rst_vif", rst_vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".rst_vif"});
        end
        reset_event = uvm_event_pool::get_global("reset");
        // analysis_port = new("analysis_port", this);
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        forever begin
            tr = new();
            @(rst_vif.reset_n);
            assert(!$isunknown(rst_vif.reset_n));
            if (rst_vif.reset_n == 0) begin
                tr.kind = reset_tr::ASSERT;
                reset_event.trigger();
                `uvm_info(get_type_name(), "Reset asserted", UVM_HIGH);
            end else begin
                tr.kind = reset_tr::DEASSERT;
                `uvm_info(get_type_name(), "Reset deasserted", UVM_HIGH);
                reset_event.reset();
            end
            // analysis_port.write(tr);
        end
    endtask : run_phase

endclass

`endif