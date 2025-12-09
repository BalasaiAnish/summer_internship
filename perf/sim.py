import random

import pandas as pd
import sys_cfg
import wkld_cfg


def regular_model():
    cycles = 0
    instrs = wkld_cfg.instr_count
    cycles += wkld_cfg.instr_count*wkld_cfg.normal_fraction
    cycles += wkld_cfg.instr_count*wkld_cfg.lw_stall*wkld_cfg.lw_cycles
    cycles += wkld_cfg.instr_count*wkld_cfg.branch*wkld_cfg.branch_mispredict
    cycles += wkld_cfg.instr_count*wkld_cfg.mem*((1-wkld_cfg.mem_miss_rate)+wkld_cfg.mem_miss_rate*wkld_cfg.mem_miss_penalty)
    return cycles

def mt_model():
    cycles = 0
    instrs = wkld_cfg.instr_count
    cycles += wkld_cfg.instr_count*(1-wkld_cfg.mem)
    cycles += wkld_cfg.instr_count*wkld_cfg.mem*((1-wkld_cfg.mt_mem_miss_rate)+wkld_cfg.mt_mem_miss_rate*wkld_cfg.mt_mem_miss_penalty)
    return cycles

def regular_metrics(cycles):
    metrics = dict()
    ops_per_second = wkld_cfg.instr_count/(cycles*sys_cfg.cycle_time)
    ops_per_joule = ops_per_second/sys_cfg.power
    exec_time = cycles*sys_cfg.cycle_time
    metrics["cycles"] = cycles
    metrics["exec_time"] = exec_time
    metrics["ops_p_s"] = ops_per_second
    metrics["ops_p_j"] = ops_per_joule
    return metrics

def mt_metrics(cycles):
    metrics = dict()
    ops_per_second = wkld_cfg.instr_count/(cycles*sys_cfg.mt_cycle_time)
    ops_per_joule = ops_per_second/sys_cfg.mt_power
    exec_time = cycles*sys_cfg.mt_cycle_time
    metrics["cycles"] = cycles
    metrics["exec_time"] = exec_time
    metrics["ops_p_s"] = ops_per_second
    metrics["ops_p_j"] = ops_per_joule
    return metrics

def print_metrics(metrics):
    for i in metrics.keys():
        print(f"{i}: {metrics[i]}")

def print_diffs(orig_metrics, new_metrics):
    for i in orig_metrics:
        diff = ((new_metrics[i]-orig_metrics[i])/orig_metrics[i])*100
        print(f"{i}: {diff:0.2f}%")
if __name__ == "__main__":

    # Regular model
    regular = regular_model()

    # MT model
    mt = mt_model()

    rmet = regular_metrics(regular)
    mtmet = mt_metrics(mt)

    # print("Regular Core")
    # print_metrics(rmet)

    # print("MT Core")
    # print_metrics(mtmet)

    # print("Diff")
    # print_diffs(rmet,mtmet)

    rdata = ["regular"]
    mtdata = ["mt"]
    diffs_data = ["diff (%)"]
    cols = ["type"]

    for i in rmet.keys():
        rdata.append(rmet[i])
        mtdata.append(mtmet[i])
        diffs_data.append((100*(mtmet[i]-rmet[i])/rmet[i]))
        cols.append(i)

    data = [rdata, mtdata, diffs_data]
    tbl = pd.DataFrame(data,columns=cols)
    print(tbl)
    tbl.to_csv("metrics.csv")
