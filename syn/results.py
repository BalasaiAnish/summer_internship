import subprocess

if __name__ == "__main__":
	# ~/skywater-pdk/libraries/sky130_fd_sc_hs/latest/timing/sky130_fd_sc_hs__tt_025C_1v80.lib
	# ~/skywater-pdk/libraries/sky130_fd_sc_hd/latest/timing/sky130_fd_sc_hd__tt_025C_1v80.lib
	subprocess.run("source ~/oss-cad-suite/environment; yosys ./syn/synth.ys",shell=True,executable="/bin/bash",check=True)
	subprocess.run("sta ./syn/mc.tcl",shell=True,executable="/bin/bash",check=True)
