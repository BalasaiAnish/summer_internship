read_liberty ~/skywater-pdk/libraries/sky130_fd_sc_hs/latest/timing/sky130_fd_sc_hs__tt_025C_1v80.lib
read_verilog ./syn/nl.v
link_design mt_cpu
read_sdc ./syn/cons.sdc
read_vcd ./dumpfile.vcd
report_checks
report_power
report_checks > ./syn/timing.txt
report_power > ./syn/power.txt
exit
