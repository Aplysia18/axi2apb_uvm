/*--------------------------------------
// AXI common methods
// file : axi_common.sv
// author : FX
// date : 2018/05/06
// description : common function calls, such queue, hash table ....
---------------------------------------*/

`ifndef AXI_COMMON_SV
`define AXI_COMMON_SV

/*-------------------------------------
// hash map table [key(id):val(trx)]
---------------------------------------*/
class AXI_map extends uvm_object;

  int unsigned  m_id;
  AXI_transfer  m_trx;


  function new(string name="aix_map");
//    super.new(name);
  endfunction

endclass : AXI_map


/*-------------------------------------
// hash map Queue // or extends uvm_queue
---------------------------------------*/
class AXI_queue extends uvm_object;

  AXI_map       m_queue[$];
  AXI_transfer  m_match_trx;
  int unsigned  m_sort_queue[$];

  function new(string name="aix_queue");
 //   super.new(name);
  endfunction

  extern virtual function bit  fd_queued(int unsigned id);
  extern virtual function void en_queued(int unsigned id);
  extern virtual function void del_queued(int unsigned id);
  extern virtual function AXI_transfer peak_trx();
  extern virtual function void clear();
endclass : AXI_queue

function bit AXI_queue::fd_queued(int unsigned id);
  foreach(m_queue[i]) begin
    if (m_queue[i].m_id == id) begin
      m_match_trx = m_queue[i].m_trx;
      return `TRUE;
    end
  end
  return `FALSE;
endfunction : fd_queued

function void AXI_queue::en_queued(int unsigned id);
  AXI_transfer m_trx = new("axi_transfer");
	AXI_map      m_map = new("axi_map");
  m_map.m_id = id;
  m_map.m_trx = m_trx;
  m_queue.push_back(m_map);
  m_match_trx = m_trx;
endfunction : en_queued

function void AXI_queue::del_queued(int unsigned id);
  int index = -1;
  foreach(m_queue[i]) begin
    if (m_queue[i].m_id == id) begin
      index = i;
      break;
    end
  end

  if (index >=0) begin
//    delete m_queue[index]; ??? how to del dynamic obj
    m_queue.delete(index);
  end
endfunction : del_queued

function AXI_transfer AXI_queue::peak_trx();
  return m_match_trx;
endfunction : peak_trx

function void AXI_queue::clear();
  m_queue.delete();
  m_match_trx = null;
  m_sort_queue.delete();
endfunction : clear


/*---------------------------------
// memory map table, addr caculate, and data byte map
-----------------------------------*/
class AXI_mem_map extends uvm_object;

  int unsigned    start_addr;
  int unsigned    num_bytes;
  int unsigned    data_bus_bytes;
  int unsigned    aligned_addr;
  int unsigned    burst_len;
  int unsigned    addrs[$];
  bit[`DATA_SIZE-1:0] datas[$];
  int unsigned    wrap_bound;
  bit             aligned;
  int unsigned    data_size;

  function new(string name="aix_queue");
 //   super.new(name);
  endfunction

  extern virtual function void run(AXI_transfer trx);
  extern virtual function void clear();

  extern virtual function void map_start_addr(AXI_transfer trx);
  extern virtual function void map_num_bytes(AXI_transfer trx);
  extern virtual function void map_data_bus_bytes(AXI_transfer trx);
  extern virtual function void map_aligned_addr(AXI_transfer trx);
  extern virtual function void map_burst_len(AXI_transfer trx);
  extern virtual function void map_addrs(AXI_transfer trx);
  extern virtual function void map_datas(AXI_transfer trx);
  extern virtual function void map_wrap_bound(AXI_transfer trx);
  extern virtual function void map_data_size(AXI_transfer trx);

endclass : AXI_mem_map


function void AXI_mem_map::run(AXI_transfer trx);
  map_start_addr(trx);
  map_num_bytes(trx);
  map_data_bus_bytes(trx);
  map_aligned_addr(trx);
  map_burst_len(trx);
  map_data_size(trx);
  map_addrs(trx);
  map_datas(trx);
  map_wrap_bound(trx);
endfunction : run


function void AXI_mem_map::clear();
  start_addr      = 0;
  num_bytes       = 0;
  data_bus_bytes  = 0;
  aligned_addr    = 0;
  burst_len       = 0;
  addrs.delete();
  datas.delete();
  wrap_bound      = 0;
endfunction : clear

// Start_Address
function void AXI_mem_map::map_start_addr(AXI_transfer trx);
  start_addr = trx.addr;
endfunction : map_start_addr

// Number_Bytes
function void AXI_mem_map::map_num_bytes(AXI_transfer trx);
  case(trx.size)
    BYTE_1    : num_bytes = 1;
    BYTE_2    : num_bytes = 2;
    BYTE_4    : num_bytes = 4;
    BYTE_8    : num_bytes = 8;
    BYTE_16   : num_bytes = 16;
    BYTE_32   : num_bytes = 32;
    BYTE_64   : num_bytes = 64;
    BYTE_128  : num_bytes = 128;
    default : `uvm_error("NOBYTE", {$psprintf("byte %d not support", trx.size)})
  endcase
endfunction : map_num_bytes

//Data_Bus_Bytes
function void AXI_mem_map::map_data_bus_bytes(AXI_transfer trx);
    data_bus_bytes = trx.data_bytes;
endfunction : map_data_bus_bytes

// Aligned_Address / Aligned
function void AXI_mem_map::map_aligned_addr(AXI_transfer trx);
    aligned_addr = (start_addr / num_bytes) * num_bytes;
    aligned = (start_addr == aligned_addr);
endfunction : map_aligned_addr

// Burst_Length
function void AXI_mem_map::map_burst_len(AXI_transfer trx);
    burst_len = (trx.len+1);
endfunction : map_burst_len

// Data Size
function void AXI_mem_map::map_data_size(AXI_transfer trx);
    data_size = num_bytes * burst_len;
endfunction : map_data_size

// Address_N
function void AXI_mem_map::map_addrs(AXI_transfer trx);

int unsigned lower_wrap_boundary = 0;
int unsigned upper_wrap_boundary = 0;
int unsigned t_addr              = start_addr;

  if (trx.burst == RESERVED_BURST)
    `uvm_error("NOBURST", {"burst FIXED | RESERVED_BURST not supported"})

  t_addr = (t_addr / num_bytes) * num_bytes;

  if (trx.burst == WRAP) begin
    lower_wrap_boundary = (t_addr/data_size) * data_size;
    upper_wrap_boundary = lower_wrap_boundary + data_size;
  end
  for (int i=1; i<=burst_len; i++) begin
    addrs.push_back(t_addr);
	if (trx.burst == FIXED) begin
	t_addr = t_addr;
	end
	else if (trx.burst == INCR) begin
		t_addr = t_addr + num_bytes;
	end
	else if (trx.burst == WRAP) begin
		t_addr = t_addr + num_bytes;
		if (t_addr >= upper_wrap_boundary)
            t_addr = lower_wrap_boundary;
	end
  end

endfunction : map_addrs

// Datas_N
function void AXI_mem_map::map_datas(AXI_transfer trx);
endfunction : map_datas

// Wrap_Boundary
function void AXI_mem_map::map_wrap_bound(AXI_transfer trx);
    wrap_bound = (start_addr / (num_bytes * burst_len)) * (num_bytes * burst_len);
endfunction : map_wrap_bound


`endif // AXI_COMMON_SV


