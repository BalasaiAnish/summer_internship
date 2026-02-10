import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from numpy.ma.core import append


class Config():
    def __init__(self, params: list) -> None:
        self.cfgs = dict()
        for i in range(0,len(params)):
            self.cfgs[params[i][0]] = params[i][1]

    def get(self, param: str) -> float:
        if param in self.cfgs:
            return self.cfgs[param]
        else:
            return 0.0

    def set(self, param: str, val: float) -> None:
        self.cfgs[param] = val

class Metrics():
    def __init__(self, metrics_list: list = []) -> None:
        self.metrics = dict()
        if len(metrics_list) < 1:
            self.metrics["cycles"] = 0
            self.metrics["time"] = 0
            self.metrics["ops_per_sec"] = 0
            self.metrics["ops_per_joule"] = 0

        else:
            for metric in metrics_list:
                self.metrics[metric] = None

    def keys(self):
        return self.metrics.keys()

    def set(self, metric: str, val: float) -> None:
        self.metrics[metric] = val

    def get(self, metric: str) -> float:
        if metric in self.metrics:
            return self.metrics[metric]
        else :
            return 0.0

class CPU():
    def __init__(self, workload_cfg: Config, system_cfg: Config, metrics: Metrics) -> None:
        self.workload_cfg = workload_cfg
        self.system_cfg = system_cfg
        self.metrics = metrics

    def set_workload(self, wcfg: Config) -> None:
        self.workload_cfg = wcfg

    def sim(self) -> None:
        cycles = 0
        instr_count = self.workload_cfg.get("instr_count")
        normal_fraction = self.workload_cfg.get("normal_fraction")
        lw_stall_fraction = self.workload_cfg.get("lw_stall_fraction")
        lw_stall_cycles = self.workload_cfg.get("lw_stall_cycles")
        branch_fraction = self.workload_cfg.get("branch_fraction")
        branch_mispredict_rate = self.workload_cfg.get("branch_mispredict_rate")
        branch_penalty = self.workload_cfg.get("branch_penalty")
        mem_fraction = self.workload_cfg.get("mem_fraction")
        mem_miss_rate = self.workload_cfg.get("mem_miss_rate")
        mem_hit_rate = 1-self.workload_cfg.get("mem_miss_rate")
        mem_penalty = self.workload_cfg.get("mem_penalty")
        cycles += instr_count*normal_fraction
        cycles += instr_count*lw_stall_fraction*lw_stall_cycles
        cycles += instr_count*branch_fraction*branch_mispredict_rate*branch_penalty
        cycles += instr_count*mem_fraction*(mem_hit_rate+mem_miss_rate*mem_penalty)

        self.metrics.set("cycles", cycles)
        self.metrics.set("time", cycles*self.system_cfg.get("cycle_time"))
        self.metrics.set("ops_per_sec", self.workload_cfg.get("instr_count")/self.metrics.get("time"))
        self.metrics.set("ops_per_joule", self.metrics.get("ops_per_sec")/self.system_cfg.get("power"))

    def sweep(self, metric: str, param: str, start: float, end: float, points: int, workload_cfg: Config, plot: bool = False) -> tuple:
        x = list()
        y = list()
        inc = (end-start)/points
        for i in range(0,points):
            curr = workload_cfg.get(param)
            workload_cfg.set(param,curr+inc)
            self.sim()
            x.append(curr)
            y.append(self.metrics.get(metric))

        if plot:
            sns.lineplot(x=x, y=y)
            plt.xlabel(param)
            plt.ylabel(metric)
            plt.title(f"{metric} vs {param}")
            plt.show()

        return (x,y)

    def sweep_all(self, param: str, start: float, end: float, points: int, workload_cfg: Config, plot: bool = False) -> tuple:
        x = list()
        y = [[],[],[],[]]
        inc = (end-start)/points
        for i in range(0,points):
            curr = workload_cfg.get(param)
            workload_cfg.set(param,curr+inc)
            self.sim()
            x.append(curr)
            y[0].append(self.metrics.get("cycles"))
            y[1].append(self.metrics.get("time"))
            y[2].append(self.metrics.get("ops_per_sec"))
            y[3].append(self.metrics.get("ops_per_joule"))

        if plot:
            sns.set_palette("pastel")
            fig, axs = plt.subplots(2,2)
            sns.lineplot(x=x, y=y[0],ax=axs[0,0],color="r")
            axs[0,0].set_xlabel(param)
            axs[0,0].set_ylabel("cycles")
            axs[0,0].set_title(f"cycles vs {param}")

            sns.lineplot(x=x, y=y[1],ax=axs[0,1],color="g")
            axs[0,1].set_xlabel(param)
            axs[0,1].set_ylabel("time")
            axs[0,1].set_title(f"time vs {param}")

            sns.lineplot(x=x, y=y[2],ax=axs[1,0],color="b")
            axs[1,0].set_xlabel(param)
            axs[1,0].set_ylabel("ops_per_sec")
            axs[1,0].set_title(f"ops_per_sec vs {param}")

            sns.lineplot(x=x, y=y[3],ax=axs[1,1],color="orange")
            axs[1,1].set_xlabel(param)
            axs[1,1].set_ylabel("ops_per_joule")
            axs[1,1].set_title(f"ops_per_joule vs {param}")

        return (x,y)

    def sweep_mem_frac(self, start: float, end: float, points: int, workload_cfg: Config, plot: bool = False) -> tuple:
        lw_mult = 0.25
        param = "mem_fraction"
        x = list()
        y = [[],[],[],[]]
        inc = (end-start)/points
        self.workload_cfg = workload_cfg
        for i in range(0,points):
            curr = self.workload_cfg.get(param)
            workload_cfg.set(param,curr+inc)
            x.append(curr)
            curr = workload_cfg.get("normal_fraction")
            workload_cfg.set("normal_fraction",curr-inc)
            curr = workload_cfg.get("lw_stall_fraction")
            workload_cfg.set("lw_stall_fraction",curr+inc*lw_mult)
            self.workload_cfg = workload_cfg
            self.sim()
            y[0].append(self.metrics.get("cycles"))
            y[1].append(self.metrics.get("time"))
            y[2].append(self.metrics.get("ops_per_sec"))
            y[3].append(self.metrics.get("ops_per_joule"))

        if plot:
            sns.set_palette("pastel")
            fig, axs = plt.subplots(2,2)
            sns.lineplot(x=x, y=y[0],ax=axs[0,0],color="r")
            axs[0,0].set_xlabel(param)
            axs[0,0].set_ylabel("cycles")
            axs[0,0].set_title(f"cycles vs {param}")

            sns.lineplot(x=x, y=y[1],ax=axs[0,1],color="g")
            axs[0,1].set_xlabel(param)
            axs[0,1].set_ylabel("time")
            axs[0,1].set_title(f"time vs {param}")

            sns.lineplot(x=x, y=y[2],ax=axs[1,0],color="b")
            axs[1,0].set_xlabel(param)
            axs[1,0].set_ylabel("ops_per_sec")
            axs[1,0].set_title(f"ops_per_sec vs {param}")

            sns.lineplot(x=x, y=y[3],ax=axs[1,1],color="orange")
            axs[1,1].set_xlabel(param)
            axs[1,1].set_ylabel("ops_per_joule")
            axs[1,1].set_title(f"ops_per_joule vs {param}")

        return (x,y)

    def sweep_branch_frac(self, start: float, end: float, points: int, workload_cfg: Config, plot: bool = False) -> tuple:
        param = "branch_fraction"
        x = list()
        y = [[],[],[],[]]
        inc = (end-start)/points
        self.workload_cfg = workload_cfg

        for i in range(0,points):
            curr = self.workload_cfg.get(param)
            workload_cfg.set(param,curr+inc)
            x.append(curr)
            curr = workload_cfg.get("normal_fraction")
            workload_cfg.set("normal_fraction",curr-inc)
            self.workload_cfg = workload_cfg

            self.sim()
            y[0].append(self.metrics.get("cycles"))
            y[1].append(self.metrics.get("time"))
            y[2].append(self.metrics.get("ops_per_sec"))
            y[3].append(self.metrics.get("ops_per_joule"))

        if plot:
            sns.set_palette("pastel")
            fig, axs = plt.subplots(2,2)
            sns.lineplot(x=x, y=y[0],ax=axs[0,0],color="r")
            axs[0,0].set_xlabel(param)
            axs[0,0].set_ylabel("cycles")
            axs[0,0].set_title(f"cycles vs {param}")

            sns.lineplot(x=x, y=y[1],ax=axs[0,1],color="g")
            axs[0,1].set_xlabel(param)
            axs[0,1].set_ylabel("time")
            axs[0,1].set_title(f"time vs {param}")

            sns.lineplot(x=x, y=y[2],ax=axs[1,0],color="b")
            axs[1,0].set_xlabel(param)
            axs[1,0].set_ylabel("ops_per_sec")
            axs[1,0].set_title(f"ops_per_sec vs {param}")

            sns.lineplot(x=x, y=y[3],ax=axs[1,1],color="orange")
            axs[1,1].set_xlabel(param)
            axs[1,1].set_ylabel("ops_per_joule")
            axs[1,1].set_title(f"ops_per_joule vs {param}")

        return (x,y)

    def sweep_mem_miss(self, start: float, end: float, points: int, workload_cfg: Config, plot: bool = False) -> tuple:
        param = "mem_miss_rate"
        x = list()
        y = [[],[],[],[]]
        inc = (end-start)/points
        self.workload_cfg = workload_cfg

        for i in range(0,points):
            curr = self.workload_cfg.get("mem_miss_rate")
            workload_cfg.set("mem_miss_rate",curr+inc)
            x.append(curr)
            self.workload_cfg = workload_cfg

            self.sim()
            y[0].append(self.metrics.get("cycles"))
            y[1].append(self.metrics.get("time"))
            y[2].append(self.metrics.get("ops_per_sec"))
            y[3].append(self.metrics.get("ops_per_joule"))

        if plot:
            sns.set_palette("pastel")
            fig, axs = plt.subplots(2,2)
            sns.lineplot(x=x, y=y[0],ax=axs[0,0],color="r")
            axs[0,0].set_xlabel(param)
            axs[0,0].set_ylabel("cycles")
            axs[0,0].set_title(f"cycles vs {param}")

            sns.lineplot(x=x, y=y[1],ax=axs[0,1],color="g")
            axs[0,1].set_xlabel(param)
            axs[0,1].set_ylabel("time")
            axs[0,1].set_title(f"time vs {param}")

            sns.lineplot(x=x, y=y[2],ax=axs[1,0],color="b")
            axs[1,0].set_xlabel(param)
            axs[1,0].set_ylabel("ops_per_sec")
            axs[1,0].set_title(f"ops_per_sec vs {param}")

            sns.lineplot(x=x, y=y[3],ax=axs[1,1],color="orange")
            axs[1,1].set_xlabel(param)
            axs[1,1].set_ylabel("ops_per_joule")
            axs[1,1].set_title(f"ops_per_joule vs {param}")

        return (x,y)

class MT_CPU(CPU):
    def __init__(self, workload_cfg: Config, system_cfg: Config, metrics: Metrics) -> None:
        super().__init__(workload_cfg, system_cfg, metrics)

    def sim(self) -> None:
        cycles = 0
        instr_count = self.workload_cfg.get("instr_count")
        normal_fraction = self.workload_cfg.get("normal_fraction")
        mem_fraction = self.workload_cfg.get("mem_fraction")
        mem_miss_rate = self.workload_cfg.get("mem_miss_rate")
        mem_hit_rate = 1-self.workload_cfg.get("mem_miss_rate")
        mem_penalty = self.workload_cfg.get("mem_penalty")
        mem_penalty = (mem_fraction*mem_miss_rate*(mem_penalty)*2)/2
        cycles += instr_count
        cycles += instr_count*mem_fraction*(mem_hit_rate+mem_miss_rate*mem_penalty)

        self.metrics.set("cycles", cycles)
        self.metrics.set("time", cycles*self.system_cfg.get("cycle_time"))
        self.metrics.set("ops_per_sec", self.workload_cfg.get("instr_count")/self.metrics.get("time"))
        self.metrics.set("ops_per_joule", self.metrics.get("ops_per_sec")/self.system_cfg.get("power"))

def compare(param: str, inp1: tuple, inp2: tuple):
    plt.figure()
    cpu_type = []
    oppj = []
    par = []
    for i in range(0,len(inp1[0])):
        cpu_type.append("single thread")
        oppj.append(inp1[1][3][i])
        par.append(inp1[0][i])
    for i in range(0,len(inp2[0])):
        cpu_type.append("multi thread")
        oppj.append(inp2[1][3][i])
        par.append(inp2[0][i])
    eff_df = pd.DataFrame({
        "cpu": cpu_type,
        "ops_per_joule": oppj,
        param: par
    })
    sns.lineplot(data=eff_df,x=param,y="ops_per_joule",hue="cpu")
    # sns.lineplot(data=eff_df)

def compare_all(param: str, inp1: tuple, inp2: tuple):
    # plt.figure()
    cpu_type = []
    opval = []
    par = []
    out = ["cycles","time","ops_per_sec","ops_per_joule"]
    for i in range(0,len(inp1[0])):
        cpu_type.append("single thread")
        opval.append(inp1[1][3][i])
        par.append(inp1[0][i])
    for i in range(0,len(inp2[0])):
        cpu_type.append("multi thread")
        opval.append(inp2[1][3][i])
        par.append(inp2[0][i])
    oppj_df = pd.DataFrame({
        "cpu": cpu_type,
        "ops_per_joule": opval,
        param: par
    })
    cpu_type = []
    opval = []
    par = []
    for i in range(0,len(inp1[0])):
        cpu_type.append("single thread")
        opval.append(inp1[1][0][i])
        par.append(inp1[0][i])
    for i in range(0,len(inp2[0])):
        cpu_type.append("multi thread")
        opval.append(inp2[1][0][i])
        par.append(inp2[0][i])
    cyc_df = pd.DataFrame({
        "cpu": cpu_type,
        "cycles": opval,
        param: par
    })
    cpu_type = []
    opval = []
    par = []

    for i in range(0,len(inp1[0])):
        cpu_type.append("single thread")
        opval.append(inp1[1][1][i])
        par.append(inp1[0][i])
    for i in range(0,len(inp2[0])):
        cpu_type.append("multi thread")
        opval.append(inp2[1][1][i])
        par.append(inp2[0][i])
    time_df = pd.DataFrame({
        "cpu": cpu_type,
        "time": opval,
        param: par
    })
    cpu_type = []
    opval = []
    par = []

    for i in range(0,len(inp1[0])):
        cpu_type.append("single thread")
        opval.append(inp1[1][2][i])
        par.append(inp1[0][i])
    for i in range(0,len(inp2[0])):
        cpu_type.append("multi thread")
        opval.append(inp2[1][2][i])
        par.append(inp2[0][i])
    opps_df = pd.DataFrame({
        "cpu": cpu_type,
        "ops_per_sec": opval,
        param: par
    })

    sns.set_palette("pastel")

    fig, axs = plt.subplots(2,2)
    fig.set_figheight(10)
    fig.set_figwidth(10)
    sns.lineplot(data=cyc_df,x=param,y="cycles",hue="cpu",ax=axs[0,0],color="r")
    axs[0,0].set_xlabel(param)
    axs[0,0].set_ylabel("cycles")
    axs[0,0].set_title(f"cycles vs {param}")

    sns.lineplot(data=time_df,x=param,y="time",hue="cpu",ax=axs[0,1],color="g")
    axs[0,1].set_xlabel(param)
    axs[0,1].set_ylabel("time")
    axs[0,1].set_title(f"time vs {param}")

    sns.lineplot(data=opps_df,x=param,y="ops_per_sec",hue="cpu",ax=axs[1,0],color="b")
    axs[1,0].set_xlabel(param)
    axs[1,0].set_ylabel("ops_per_sec")
    axs[1,0].set_title(f"ops_per_sec vs {param}")

    sns.lineplot(data=oppj_df,x=param,y="ops_per_joule",hue="cpu",ax=axs[1,1],color="orange")
    axs[1,1].set_xlabel(param)
    axs[1,1].set_ylabel("ops_per_joule")
    axs[1,1].set_title(f"ops_per_joule vs {param}")

    plt.savefig(f"{param}_plot.png")
