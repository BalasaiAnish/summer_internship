instr_count = 100000
normal_fraction = 0.4
lw_stall = 0.1
lw_cycles = 2
branch = 0.2
branch_mispredict = 0.7
mem = 0.3
mem_miss_rate = 0.05
mem_miss_penalty = 100

mt_mem_miss_rate = 0.1
mt_mem_miss_penalty = (mem*mt_mem_miss_rate*(mem_miss_penalty)*2)/2
