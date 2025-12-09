# Data word size
word_size = 32
# Number of words in the memory
num_words = 128

# Avoid odd number of cols error
num_spare_cols = 1
# num_spare_rows = 1

# Read write ports
num_rw_ports = 1
num_r_ports = 1

# Technology to use in $OPENRAM_TECH
tech_name = "sky130"
# Process corners to characterize
process_corners = ["TT"]
# Voltage corners to characterize
supply_voltages = [1.8]
# Temperature corners to characterize
temperatures = [25]
only_use_config_corners = True
use_specified_corners = (("TT",1.8,25),("FF",1.95,-40),("SS",1.6,100))

# Output directory for the results
output_path = "out_char"
# Output file base name
output_name = "sram_128x32"

# Disable analytical models for full characterization (WARNING: slow!)
analytical_delay = False
#
# # Speed
num_threads = 16
num_sim_threads = 16

# To force this to use magic and netgen for DRC/LVS/PEX
# Could be calibre for FreePDK45
drc_name = "magic"
lvs_name = "netgen"
pex_name = "magic"
