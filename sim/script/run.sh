make -f ../script/makefile all TC=axi_write_and_read_all_addr_tc DEBUG=DUMP
make -f ../script/makefile all TC=axi_addr_illegal_tc DEBUG=DUMP
make -f ../script/makefile all TC=axi_burst_tc DEBUG=DUMP
make -f ../script/makefile all TC=axi_len_tc DEBUG=DUMP
make -f ../script/makefile all TC=axi_slave_id_tc DEBUG=DUMP
make -f ../script/makefile all TC=axi_strob_tc DEBUG=DUMP

