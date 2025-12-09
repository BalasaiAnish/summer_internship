define_corners ss tt ff
read_liberty -corner tt ~/skywater-pdk/libraries/sky130_fd_sc_hd/latest/timing/sky130_fd_sc_hd__tt_025C_1v80.lib
read_liberty -corner tt ~/git_stuff/internship/syn/sram/sram_128x32/out/sram_128x32_TT.lib
read_liberty -corner ff ~/skywater-pdk/libraries/sky130_fd_sc_hd/latest/timing/sky130_fd_sc_hd__ff_n40C_1v95.lib
read_liberty -corner ff ~/git_stuff/internship/syn/sram/sram_128x32/out/sram_128x32_FF.lib
read_liberty -corner ss ~/skywater-pdk/libraries/sky130_fd_sc_hd/latest/timing/sky130_fd_sc_hd__ss_100C_1v60.lib
read_liberty -corner ss ~/git_stuff/internship/syn/sram/sram_128x32/out/sram_128x32_SS.lib
read_verilog ./syn/reports/mt_cpu.nl.v
link_design mt_cpu
read_sdc ./syn/scripts/cons.sdc
set_power_activity -input -activity 0.1
set_power_activity -input_port rst -activity 0
report_checks -path_delay min_max > ./syn/reports/timing.txt
report_power -corner tt > ./syn/reports/pwr_tt.txt
report_power -corner ff > ./syn/reports/pwr_ff.txt
report_power -corner ss > ./syn/reports/pwr_ss.txt
exit
