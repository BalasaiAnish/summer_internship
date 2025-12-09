module decode #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_THREADS = 4
    )(
    input clk, reg_write_w,
    input [DATA_WIDTH-1:0] result_w,
    input [4:0] rd_w,

    input [ADDRESS_WIDTH-1:0] pc_f, pc_plus4_f,
    input [DATA_WIDTH-1:0] instr_f,
    input [BITS_THREADS-1:0] tid_f, tid_w,
    input tgrp,

    output reg_write_d,
    output [1:0] res_src_d,
    output mem_write_d, jump_d, branch_d,
    output [3:0] alu_control_d,
    output [2:0] funct3_d,
    output alu_src_b_d,
    alu_src_a_d,

    output [DATA_WIDTH-1:0] rd1_d,
    rd2_d,
    output [ADDRESS_WIDTH-1:0] pc_d,
    output [4:0] rd_d,
    output [DATA_WIDTH-1:0] imm_val_d,
    output [ADDRESS_WIDTH-1:0] pc_plus4_d,
    output [BITS_THREADS-1:0] tid_d
);

localparam BITS_THREADS = $clog2(NUM_THREADS);

    wire [2:0] imm_src_d;

    control_unit cu (
        .op(instr_f[6:0]),
        .funct3(instr_f[14:12]),
        .funct7b5(instr_f[30]),
        .reg_write_d(reg_write_d),
        .res_src_d(res_src_d),
        .mem_write_d(mem_write_d),
        .jump_d(jump_d),
        .branch_d(branch_d),
        .alu_control_d(alu_control_d),
        .alu_src_a_d(alu_src_a_d),
        .alu_src_b_d(alu_src_b_d),
        .imm_src_d(imm_src_d)
    );

    mt_reg_file #(
        .NUM_THREADS(NUM_THREADS),
        .DATA_WIDTH(DATA_WIDTH)
    )
    rf (
        .clk(clk),
        .write_enable(reg_write_w),
        .tgrp(tgrp),
        .tid_read(tid_f),
        .tid_write(tid_w),
        .a1(instr_f[19:15]),
        .a2(instr_f[24:20]),
        .a3(rd_w),
        .wd3(result_w),
        .rd1(rd1_d),
        .rd2(rd2_d)
    );

    imm_ext imex (
        .instr(instr_f[31:7]),
        .imm_type(imm_src_d),
        .imm_val(imm_val_d)
    );

    assign funct3_d = instr_f[14:12];

    assign pc_d = pc_f;
    assign pc_plus4_d = pc_plus4_f;
    assign rd_d = instr_f[11:7];

    assign tid_d = tid_f;

endmodule
