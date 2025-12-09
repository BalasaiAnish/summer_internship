module mt_cpu_tb ();
    parameter ADDRESS_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter NUM_THREADS = 4;
    parameter DMEM_SIZE = 64;
    parameter IMEM_SIZE = 1024;

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
    end

    always #14 clk = ~clk;

    initial begin
        $dumpfile("dumpfile.vcd");
        $dumpvars(0, mt_cpu_tb);

        rst = 1;
        #14 rst = 0;
        #1000 swap_tgrp = 1;
        #14 swap_tgrp = 0;
        #1000000 $finish();

    end
endmodule
