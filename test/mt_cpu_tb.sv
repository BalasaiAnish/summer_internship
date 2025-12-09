module mt_cpu_tb ();
    parameter ADDRESS_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter NUM_THREADS = 4;
    parameter DMEM_SIZE = 64;
    parameter IMEM_SIZE = 1024;


    reg tgrp_pulse_active;
    int tgrp_cycle_cnt;

    reg rst, clk, swap_tgrp;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [DATA_WIDTH-1:0] result;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [ADDRESS_WIDTH-1:0] pcw;

    mt_cpu #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .NUM_THREADS(NUM_THREADS),
        .IMEM_SIZE(IMEM_SIZE),
        .DMEM_SIZE(DMEM_SIZE)
    )
    dut (
        .clk(clk),
        .rst(rst),
        .swap_tgrp(swap_tgrp),
        .result(result),
        .pcw(pcw)
    );

    initial begin
        clk = 0;
        swap_tgrp = 0;
        tgrp_cycle_cnt = 0;
    end

    always #10 clk = ~clk;


    initial begin
        $dumpfile("dumpfile.vcd");
        $dumpvars(0, mt_cpu_tb);

        rst = 1;
        #10 rst = 0;
        #1000000 $finish();

    end

    always @(posedge clk) begin
        tgrp_cycle_cnt <= tgrp_cycle_cnt+1;
        if (tgrp_cycle_cnt == 23) begin
            swap_tgrp <= 1;
        end
        else if (tgrp_cycle_cnt == 24) begin
            swap_tgrp <= 0;
            tgrp_cycle_cnt <= 0;
        end
        else begin
            swap_tgrp <= 0;
        end
    end
endmodule
