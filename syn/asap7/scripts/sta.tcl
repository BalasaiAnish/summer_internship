# define_corners ss tt ff
define corners tt

read_liberty -corner tt ~/asap7sc6t_26/LIB/CCS/TT/asap7sc6t_AO_RVT_TT_ccs_211010.lib.gz
read_liberty -corner tt ~/asap7sc6t_26/LIB/CCS/TT/asap7sc6t_CKINVDC_RVT_TT_ccs_211010.lib.gz
read_liberty -corner tt ~/asap7sc6t_26/LIB/CCS/TT/asap7sc6t_INVBUF_RVT_TT_ccs_211010.lib.gz
read_liberty -corner tt ~/asap7sc6t_26/LIB/CCS/TT/asap7sc6t_OA_RVT_TT_ccs_211010.lib.gz
read_liberty -corner tt ~/asap7sc6t_26/LIB/CCS/TT/asap7sc6t_SEQ_RVT_TT_ccs_211010.lib.gz
read_liberty -corner tt ~/asap7sc6t_26/LIB/CCS/TT/asap7sc6t_SIMPLE_RVT_TT_ccs_211010.lib

# read_liberty -corner ff ~/asap7sc6t_26/LIB/CCS/FF/asap7sc6t_AO_RVT_FF_ccs_211010.lib.gz
# read_liberty -corner ff ~/asap7sc6t_26/LIB/CCS/FF/asap7sc6t_CKINVDC_RVT_FF_ccs_211010.lib.gz
# read_liberty -corner ff ~/asap7sc6t_26/LIB/CCS/FF/asap7sc6t_INVBUF_RVT_FF_ccs_211010.lib.gz
# read_liberty -corner ff ~/asap7sc6t_26/LIB/CCS/FF/asap7sc6t_OA_RVT_FF_ccs_211010.lib.gz
# read_liberty -corner ff ~/asap7sc6t_26/LIB/CCS/FF/asap7sc6t_SEQ_RVT_FF_ccs_211010.lib.gz
# read_liberty -corner ff ~/asap7sc6t_26/LIB/CCS/FF/asap7sc6t_SIMPLE_RVT_FF_ccs_211010.lib

# read_liberty -corner ss ~/asap7sc6t_26/LIB/CCS/SS/asap7sc6t_AO_RVT_SS_ccs_211010.lib.gz
# read_liberty -corner ss ~/asap7sc6t_26/LIB/CCS/SS/asap7sc6t_CKINVDC_RVT_SS_ccs_211010.lib.gz
# read_liberty -corner ss ~/asap7sc6t_26/LIB/CCS/SS/asap7sc6t_INVBUF_RVT_SS_ccs_211010.lib.gz
# read_liberty -corner ss ~/asap7sc6t_26/LIB/CCS/SS/asap7sc6t_OA_RVT_SS_ccs_211010.lib.gz
# read_liberty -corner ss ~/asap7sc6t_26/LIB/CCS/SS/asap7sc6t_SEQ_RVT_SS_ccs_211010.lib.gz
# read_liberty -corner ss ~/asap7sc6t_26/LIB/CCS/SS/asap7sc6t_SIMPLE_RVT_SS_ccs_211010.lib

read_verilog ./syn/asap7/reports/mt_cpu.nl.v
link_design mt_cpu
read_sdc ./syn/asap7/scripts/cons.sdc
set_power_activity -input -activity 0.5
set_power_activity -input_port rst -activity 0
report_checks -path_delay min_max > ./syn/reports/timing.txt
report_power -corner tt > ./syn/reports/pwr_tt.txt
# report_power -corner ff > ./syn/reports/pwr_ff.txt
# report_power -corner ss > ./syn/reports/pwr_ss.txt
exit
