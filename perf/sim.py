import random

import matplotlib.pyplot as plt
import model
import pandas as pd
import seaborn as sns


def print_metrics(metrics):
    for i in metrics.keys():
        print(f"{i}: {metrics[i]}")

def print_diffs(orig_metrics, new_metrics):
    for i in orig_metrics:
        diff = ((new_metrics[i]-orig_metrics[i])/orig_metrics[i])*100
        print(f"{i}: {diff:0.2f}%")

if __name__ == "__main__":
    workload_params = [
        ("instr_count", 1000000),
        ("mem_fraction", 0.0),
        ("mem_miss_rate", 0.1),
        ("mem_penalty", 100),
    ]
    system_params = [
        ("power",1.407473e-02),
        ("cycle_time",24e-9)
    ]
    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    mt_cpu = model.MT_CPU(workload_cfg,system_cfg,metrics)

    mt_in1 = mt_cpu.sweep_mem_frac(0,1,100,workload_cfg)

    workload_params = [
        ("instr_count", 1000000),
        ("mem_fraction", 0.2),
        ("mem_miss_rate", 0.1),
        ("mem_penalty", 100),
    ]
    system_params = [
        ("power",1.407473e-02),
        ("cycle_time",24e-9)
    ]
    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    mt_cpu = model.MT_CPU(workload_cfg,system_cfg,metrics)
    mt_in2 = mt_cpu.sweep_branch_frac(0,1,100,workload_cfg)

    workload_params = [
        ("instr_count", 1000000),
        ("mem_fraction", 0.2),
        ("mem_miss_rate", 0.0),
        ("mem_penalty", 100),
    ]
    system_params = [
        ("power",1.407473e-02),
        ("cycle_time",24e-9)
    ]
    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    mt_cpu = model.MT_CPU(workload_cfg,system_cfg,metrics)

    mt_in3 = mt_cpu.sweep_mem_miss(0,1,100,workload_cfg)

    workload_params = [
        ("instr_count", 1000000),
        ("normal_fraction", 1-0.2),
        ("mem_fraction", 0.0),
        ("mem_miss_rate", 0.05),
        ("mem_penalty", 100),
        ("lw_stall_fraction", 0.0),
        ("lw_stall_cycles", 1),
        ("branch_fraction", 0.2),
        ("branch_penalty", 2),
        ("branch_mispredict_rate", 0.7),
    ]
    system_params = [
        ("power",1.207269e-02),
        ("cycle_time",21e-9)
    ]

    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    cpu = model.CPU(workload_cfg,system_cfg,metrics)

    st_in1 = cpu.sweep_mem_frac(0,1,100,workload_cfg)


    workload_params = [
        ("instr_count", 1000000),
        ("normal_fraction", 1-0.2),
        ("mem_fraction", 0.2),
        ("mem_miss_rate", 0.05),
        ("mem_penalty", 100),
        ("lw_stall_fraction", 0.25*0.2),
        ("lw_stall_cycles", 1),
        ("branch_fraction", 0.0),
        ("branch_penalty", 2),
        ("branch_mispredict_rate", 0.7),
    ]
    system_params = [
        ("power",1.207269e-02),
        ("cycle_time",21e-9)
    ]

    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    cpu = model.CPU(workload_cfg,system_cfg,metrics)
    st_in2 = cpu.sweep_branch_frac(0,1,100,workload_cfg)

    workload_params = [
        ("instr_count", 1000000),
        ("normal_fraction", 1-0.2-0.2),
        ("mem_fraction", 0.2),
        ("mem_miss_rate", 0.0),
        ("mem_penalty", 100),
        ("lw_stall_fraction", 0.25*0.2),
        ("lw_stall_cycles", 1),
        ("branch_fraction", 0.2),
        ("branch_penalty", 2),
        ("branch_mispredict_rate", 0.7),
    ]
    system_params = [
        ("power",1.207269e-02),
        ("cycle_time",21e-9)
    ]

    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    cpu = model.CPU(workload_cfg,system_cfg,metrics)

    st_in3 = cpu.sweep_mem_miss(0,1,100,workload_cfg)

    model.compare_all("mem_fraction",st_in1,mt_in1)
    model.compare_all("branch_fraction",st_in2,mt_in2)
    model.compare_all("mem_miss_rate",st_in3,mt_in3)

    workload_params = [
        ("instr_count", 1000000),
        ("mem_fraction", 0.2),
        ("mem_miss_rate", 0.1),
        ("mem_penalty", 100),
    ]
    system_params = [
        ("power",1.407473e-02),
        ("cycle_time",24e-9)
    ]
    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    mt_cpu = model.MT_CPU(workload_cfg,system_cfg,metrics)
    mt_cpu.sim()

    workload_params = [
        ("instr_count", 1000000),
        ("normal_fraction", 1-0.2-0.2),
        ("mem_fraction", 0.2),
        ("mem_miss_rate", 0.05),
        ("mem_penalty", 100),
        ("lw_stall_fraction", 0.25*0.2),
        ("lw_stall_cycles", 1),
        ("branch_fraction", 0.2),
        ("branch_penalty", 2),
        ("branch_mispredict_rate", 0.7),
    ]
    system_params = [
        ("power",1.207269e-02),
        ("cycle_time",21e-9)
    ]
    workload_cfg = model.Config(workload_params)
    system_cfg = model.Config(system_params)
    metrics = model.Metrics()

    cpu = model.CPU(workload_cfg,system_cfg,metrics)
    cpu.sim()

    print_metrics(cpu.metrics.metrics)
    print_metrics(mt_cpu.metrics.metrics)
    print_diffs(cpu.metrics.metrics,mt_cpu.metrics.metrics)
    plt.show()
