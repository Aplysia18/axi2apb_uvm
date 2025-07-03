
`ifndef AXI_BUS_CONF_SV
`define AXI_BUS_CONF_SV

class axi_bus_conf extends AXI_env_conf;

  `uvm_object_utils(axi_bus_conf)

  function new(string name = "axi_bus_config");
    super.new(name);
    add_master(.name             ("m_masters[0]"),
               .is_active         (UVM_ACTIVE));
  endfunction

endclass : axi_bus_conf

`endif // AXI_BUS_CONF_SV

