module fetch #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32,
    parameter IMEM_SIZE = 1024,
    parameter NUM_THREADS = 4
) (
    input clk, rst,

    input pc_src_e,
    input [ADDRESS_WIDTH-1:0] pc_target_e,
    input sub_pcs,
    input tgrp,
    input [BITS_THREADS-1:0] tid_e,
    input [BITS_THREADS-1:0] tid_stalled,

    output [ADDRESS_WIDTH-1:0] pc_f, pc_plus4_f,
    output [DATA_WIDTH-1:0] instr_f,
    output [BITS_THREADS-1:0] tid_f

);

localparam BITS_THREADS = $clog2(NUM_THREADS);

    wire [31:0] pc;
    wire [BITS_THREADS-1:0] tid;

    thread_sel #(
    .NUM_THREADS(NUM_THREADS)
    )
    ts(
        .clk(clk),
        .rst(rst),
        .tid(tid)
    );

    mt_pc #(
        .NUM_THREADS(NUM_THREADS),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .NUM_THREAD_GRPS(2)
    )
    thread_pc(
        .clk(clk),
        .rst(rst),
        .sub_pcs(sub_pcs),
        .tgrp_stalled(tgrp),
        .tid_stalled(tid_stalled),
        .tgrp(tgrp),
        .tid(tid),
        .pc_src_e(pc_src_e),
        .branch_tgrp_e(tgrp),
        .branch_tid_e(tid_e),
        .pc_target_e(pc_target_e),
        .pc(pc),
        .pc_plus4(pc_plus4_f)
    );

    instr_mem #(
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(IMEM_SIZE)
    )
    i_mem (
        .instr_addr(pc),
        .instr(instr_f)
    );

    assign pc_f = pc;
    assign tid_f = tid;

endmodule
