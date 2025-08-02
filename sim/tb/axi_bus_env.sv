
`ifndef AXI_BUS_ENV_SV
`define AXI_BUS_ENV_SV

class axi_bus_env extends uvm_env;

  `uvm_component_utils_begin(axi_bus_env)
  `uvm_component_utils_end

   axi_bus_conf        m_axi_bus_conf;
   AXI_env             m_axi_env;
   axi_bus_scoreboard  m_axi_bus_scoreboard;
   apb_slave_agent     m_apb_slave_agent;
   axi_bus_fun_cov     m_axi_bus_fun_cov;
   reset_agent         m_reset_agent;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);

endclass : axi_bus_env

// set up conf to sub leaf masters/slaves
function void axi_bus_env::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_axi_bus_conf       = axi_bus_conf::type_id::create("m_axi_bus_conf", this);
  m_axi_bus_scoreboard = axi_bus_scoreboard::type_id::create("m_axi_bus_scoreboard", this);
  m_axi_env         = AXI_env::type_id::create("m_axi_env", this);
  m_axi_env.assign_conf(m_axi_bus_conf);
  m_apb_slave_agent = apb_slave_agent::type_id::create("m_apb_slave_agent", this);
  m_axi_bus_fun_cov = axi_bus_fun_cov::type_id::create("m_axi_bus_fun_cov", this);
  uvm_config_db#(bit)::get(this, "", "coverage_enable", m_axi_bus_fun_cov.coverage_enable);
  m_reset_agent = reset_agent::type_id::create("m_reset_agent", this);
  m_reset_agent.is_active = UVM_ACTIVE;

endfunction : build_phase

// TLM analysis port from master/slave monitor to scoreboard
function void axi_bus_env::connect_phase(uvm_phase phase);
  for(int i = 0; i < `MST_NUM; i++)
  begin
  	m_axi_env.m_masters[i].m_monitor.item_collected_port.connect(m_axi_bus_scoreboard.mst_mon_scb_imp);
    m_axi_env.m_masters[i].m_monitor.item_collected_port.connect(m_axi_bus_fun_cov.axi_cov_imp);
    // m_axi_env.m_masters[i].m_driver.item_collected_port.connect(m_axi_bus_scoreboard.mst_drv_write_scb_imp);
  end

  m_apb_slave_agent.m_monitor.item_collected_port.connect(m_axi_bus_scoreboard.apb_to_scb_imp);
  m_apb_slave_agent.m_monitor.item_collected_port.connect(m_axi_bus_fun_cov.apb_cov_imp);
endfunction : connect_phase

`endif // AXI_BUS_ENV_SV
