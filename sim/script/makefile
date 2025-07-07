## 
## -------------------------------------------------------------
##    Copyright 2010-2011 Synopsys, Inc.
##    All Rights Reserved Worldwide
## 
##    Licensed under the Apache License, Version 2.0 (the
##    "License"); you may not use this file except in
##    compliance with the License.  You may obtain a copy of
##    the License at
## 
##        http://www.apache.org/licenses/LICENSE-2.0
## 
##    Unless required by applicable law or agreed to in
##    writing, software distributed under the License is
##    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.  See
##    the License for the specific language governing
##    permissions and limitations under the License.
## -------------------------------------------------------------
## 
# UVM_HOME=/tools/synopsys/vcs-mx_2016.06/etc/uvm-1.1
UVM_HOME=/home/jjt/install/synopsys/vcs/vcs/T-2022.06/etc/uvm-1.1
UVM_VERBOSITY=UVM_LOW
DEBUG=NODUMP
TC=0
SEED=`date +%N`
UVM_TRACE=
IS_COV=1
RAMDOM := $(shell perl -e "print int($(SEED))")

#############COV enable###############
COV_ROOT = coverage
cov_dir = $(COV_ROOT)/cov_$(TC)_$(RAMDOM)
ifeq ($(IS_COV),1)
	vcs_cov_opt = -cm line+cond+fsm+tgl+branch+assert -cm_dir $(cov_dir)
else
	vcs_cov_opt = 
endif
#######################################

################main###################
all: clean comp run

clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log *.fsdb *.vf *.vdb novas.* vdCovLog verdiLog

comp:
	@mkdir -p $(COV_ROOT)
	$(VCS) +incdir+. \
	-f ../tb/filelist/axi_bus.f \
    +incdir+ ../tc/testcase/test_case/$(TC).sv 

run:
	$(SIMV)
#######################################

VCS =	vcs -full64 -sverilog -debug_all -timescale=1ns/10ps +notimingcheck +nospecify \
		+acc +vpi \
		+lint=TFIPC-L \
		+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
    	+define+$(DEBUG)+UVM_REG_DATA_WIDTH=1024 \
		+incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv \
		$(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
    	+libext+.sv+.v+.vp+.vhd+.vh \
    	-lca \
    	-kdb \
		-cpp g++ -cc gcc -LDFLAGS -Wl,-no-as-needed \
		-assert svaext \
		-assert dve \
		-assert enable_diag \
		-assert vpiSeqBeginTime \
		-assert vpiSeqFail \
		$(vcs_cov_opt) \
		-l vcs_cmp.log \
		-P ${VERDI_HOME}/share/PLI/VCS/LINUX64/verdi.tab  ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a 


SIMV = 	./simv +$(UVM_TRACE) +UVM_TESTNAME=$(TC) +UVM_VERBOSITY=$(UVM_VERBOSITY) \
		+ntb_random_seed=$(RAMDOM) \
		$(vcs_cov_opt) \
   		-l $(cov_dir).vdb/vcs_run.log

###################cov_report#########
VDB_FILES := $(wildcard $(COV_ROOT)/cov_*.vdb)
urg:
	@echo "Merging coverage from all testcases, found VDB files: $(VDB_FILES)"
	mkdir -p urg_report
	urg -full64 -dir $(VDB_FILES) -dbname urg_report/merge.vdb -report urg_report -show tests -grade

verdi:
	verdi -dbdir simv.daidir -ssf *.fsdb &	
