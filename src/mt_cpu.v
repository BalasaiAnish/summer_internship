`default_nettype wire

module mt_cpu #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32,
    parameter IMEM_SIZE = 1024,
    parameter DMEM_SIZE = 64,
    parameter NUM_THREADS = 4
    )(
    input clk,
    input rst,
    input swap_tgrp,
    output [DATA_WIDTH-1:0] result,
    output [ADDRESS_WIDTH-1:0] pcw
);
    localparam BITS_THREADS = $clog2(NUM_THREADS);

    // f to d
    wire [ADDRESS_WIDTH-1:0] pc_f_o, pc_plus4_f_o;
    wire [DATA_WIDTH-1:0] instr_f_o;
    wire [BITS_THREADS-1:0] tid_f_o;

    wire [ADDRESS_WIDTH-1:0] pc_d_i, pc_plus4_d_i;
    wire [DATA_WIDTH-1:0] instr_d_i;
    wire [BITS_THREADS-1:0] tid_d_i;

    // d to e
    wire [DATA_WIDTH-1:0] rd1_d_o, rd2_d_o, imm_val_d_o;
    wire [ADDRESS_WIDTH-1:0] pc_d_o, pc_plus4_d_o;
    wire [4:0] rd_d_o;
    wire [3:0] alu_control_d_o;
    wire [1:0] res_src_d_o;
    wire mem_write_d_o, reg_write_d_o, jump_d_o, branch_d_o, alu_src_a_d_o, alu_src_b_d_o;
    wire [2:0] funct3_d_o;
    wire [BITS_THREADS-1:0] tid_d_o;

    wire [DATA_WIDTH-1:0] rd1_e_i, rd2_e_i, imm_val_e_i;
    wire [ADDRESS_WIDTH-1:0] pc_e_i, pc_plus4_e_i;
    wire [4:0] rd_e_i;
    wire [3:0] alu_control_e_i;
    wire [1:0] res_src_e_i;
    wire mem_write_e_i, reg_write_e_i, jump_e_i, branch_e_i, alu_src_a_e_i, alu_src_b_e_i;
    wire [2:0] funct3_e_i;
    wire [BITS_THREADS-1:0] tid_e_i;

    // e to m
    wire [DATA_WIDTH-1:0] alu_result_e_o, write_data_e_o;
    wire [ADDRESS_WIDTH-1:0] pc_target_e_o, pc_plus4_e_o;
    wire pc_src_e_o, mem_write_e_o, reg_write_e_o;
    wire [1:0] res_src_e_o;
    wire [2:0] funct3_e_o;
    wire [4:0] rd_e_o; // rs1_e_o, rs2_e_o,
    wire [BITS_THREADS-1:0] tid_e_o;

    wire [DATA_WIDTH-1:0] alu_result_m_i, write_data_m_i;
    wire [ADDRESS_WIDTH-1:0] pc_plus4_m_i; // pc_target_m_i
    // wire pc_src_m_i;
    wire mem_write_m_i, reg_write_m_i;
    wire [1:0] res_src_m_i;
    wire [2:0] funct3_m_i;
    wire [4:0] rd_m_i;
    wire [BITS_THREADS-1:0] tid_m_i;

    // m to w
    wire reg_write_m_o;
    wire [1:0] result_src_m_o;
    wire [DATA_WIDTH-1:0] alu_result_m_o;
    wire [DATA_WIDTH-1:0] read_data_m_o;
    wire [4:0] rd_m_o;
    wire [ADDRESS_WIDTH-1:0] pc_plus4_m_o;
    wire [BITS_THREADS-1:0] tid_m_o;

    wire reg_write_w_i;
    wire [1:0] result_src_w_i;
    wire [DATA_WIDTH-1:0] alu_result_w_i;
    wire [DATA_WIDTH-1:0] read_data_w_i;
    wire [4:0] rd_w_i;
    wire [ADDRESS_WIDTH-1:0] pc_plus4_w_i;
    wire [BITS_THREADS-1:0] tid_w_i;

    // w to f
    // wire [DATA_WIDTH-1:0] mem_data_w_o,
    wire [DATA_WIDTH-1:0] alu_result_w_o;
    // wire [ADDRESS_WIDTH-1:0] pc_plus4_w_o;
    // wire [1:0] res_src_w_o;
    wire reg_write_w_o;
    wire [4:0] rd_w_o;
    wire [BITS_THREADS-1:0] tid_w_o;

    // thread group
    wire tgrp;
    wire mem_stall;
    wire kill;

    // Fetch
    fetch #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .NUM_THREADS(NUM_THREADS),
        .IMEM_SIZE(IMEM_SIZE)
    )
    fetch_stage (
        .clk(clk),
        .rst(rst),
        .pc_src_e(pc_src_e_o),
        .pc_target_e(pc_target_e_o),
        .sub_pcs(mem_stall),
        .tgrp(tgrp),
        .tid_stalled(tid_w_i-1),
        .tid_e(tid_e_o),
        .pc_f(pc_f_o),
        .pc_plus4_f(pc_plus4_f_o),
        .instr_f(instr_f_o),
        .tid_f(tid_f_o)
    );

    // f to d pl_reg

    pl_reg_fd #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_THREADS(NUM_THREADS)
    )
    fd (
        .clk(clk),
        .en(1'b0),
        .clr(kill),
        .pc_f(pc_f_o),
        .pc_plus4_f(pc_plus4_f_o),
        .instr_f(instr_f_o),
        .tid_f(tid_f_o),
        .pc_d(pc_d_i),
        .pc_plus4_d(pc_plus4_d_i),
        .instr_d(instr_d_i),
        .tid_d(tid_d_i)
    );

    // Decode
    decode #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .NUM_THREADS(NUM_THREADS)
    )
    decode_stage (
        .clk(clk),
        .reg_write_w(reg_write_w_o),
        .result_w(alu_result_w_o),
        .rd_w(rd_w_o),
        .tid_w(tid_w_o),
        .tgrp(tgrp),

        .instr_f(instr_d_i),
        .pc_f(pc_d_i),
        .pc_plus4_f(pc_plus4_d_i),
        .tid_f(tid_d_i),

        .alu_control_d(alu_control_d_o),
        .funct3_d(funct3_d_o),
        .rd1_d(rd1_d_o),
        .rd2_d(rd2_d_o),
        .imm_val_d(imm_val_d_o),
        .pc_plus4_d(pc_plus4_d_o),
        .rd_d(rd_d_o),
        .pc_d(pc_d_o),
        .res_src_d(res_src_d_o),
        .mem_write_d(mem_write_d_o),
        .reg_write_d(reg_write_d_o),
        .jump_d(jump_d_o),
        .branch_d(branch_d_o),
        .alu_src_a_d(alu_src_a_d_o),
        .alu_src_b_d(alu_src_b_d_o),
        .tid_d(tid_d_o)
    );

    // d to e pl_reg
    pl_reg_de #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_THREADS(NUM_THREADS)
    )
    de (
        .clk(clk),
        .en (1'b0),
        .clr(kill),

        .reg_write_d(reg_write_d_o),
        .res_src_d(res_src_d_o),
        .mem_write_d(mem_write_d_o),
        .jump_d(jump_d_o),
        .branch_d(branch_d_o),
        .alu_control_d(alu_control_d_o),
        .funct3_d(funct3_d_o),
        .alu_src_b_d(alu_src_b_d_o),
        .alu_src_a_d(alu_src_a_d_o),
        .rd1_d(rd1_d_o),
        .rd2_d(rd2_d_o),
        .pc_d(pc_d_o),
        .rd_d(rd_d_o),
        .imm_val_d(imm_val_d_o),
        .pc_plus4_d(pc_plus4_d_o),
        .tid_d(tid_d_o),

        .reg_write_e(reg_write_e_i),
        .res_src_e(res_src_e_i),
        .mem_write_e(mem_write_e_i),
        .jump_e(jump_e_i),
        .branch_e(branch_e_i),
        .alu_control_e(alu_control_e_i),
        .funct3_e(funct3_e_i),
        .alu_src_b_e(alu_src_b_e_i),
        .alu_src_a_e(alu_src_a_e_i),
        .rd1_e(rd1_e_i),
        .rd2_e(rd2_e_i),
        .pc_e(pc_e_i),
        .rd_e(rd_e_i),
        .imm_val_e(imm_val_e_i),
        .pc_plus4_e(pc_plus4_e_i),
        .tid_e(tid_e_i)
    );
    // Execute
    execute #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .NUM_THREADS(NUM_THREADS)
    )
    execute_stage (
        .reg_write_d(reg_write_e_i),
        .res_src_d(res_src_e_i),
        .mem_write_d(mem_write_e_i),
        .jump_d(jump_e_i),
        .branch_d(branch_e_i),
        .alu_control_d(alu_control_e_i),
        .funct3_d(funct3_e_i),
        .alu_src_b_d(alu_src_b_e_i),
        .alu_src_a_d(alu_src_a_e_i),
        .rd1_d(rd1_e_i),
        .rd2_d(rd2_e_i),
        .pc_d(pc_e_i),
        .rd_d(rd_e_i),
        .imm_val_d(imm_val_e_i),
        .pc_plus4_d(pc_plus4_e_i),
        .tid_d(tid_e_i),

        .reg_write_e(reg_write_e_o),
        .res_src_e(res_src_e_o),
        .mem_write_e(mem_write_e_o),
        .alu_result_e(alu_result_e_o),
        .write_data_e(write_data_e_o),
        .pc_plus4_e(pc_plus4_e_o),
        .pc_target_e(pc_target_e_o),
        .pc_src_e(pc_src_e_o),
        .funct3_e(funct3_e_o),
        .rd_e(rd_e_o),
        .tid_e(tid_e_o)
    );

    // e to m pl_reg
    pl_reg_em #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_THREADS(NUM_THREADS)
    )
    em (
        .clk(clk),
        .en (1'b0),
        .clr(kill),

        .reg_write_e(reg_write_e_o),
        .mem_write_e(mem_write_e_o),
        .result_src_e(res_src_e_o),
        .funct3_e(funct3_e_o),
        .alu_result_e(alu_result_e_o),
        .write_data_e(write_data_e_o),
        .rd_e(rd_e_o),
        .pc_plus4_e(pc_plus4_e_o),
        .tid_e(tid_e_o),

        .reg_write_m(reg_write_m_i),
        .mem_write_m(mem_write_m_i),
        .result_src_m(res_src_m_i),
        .funct3_m(funct3_m_i),
        .alu_result_m(alu_result_m_i),
        .write_data_m(write_data_m_i),
        .rd_m(rd_m_i),
        .pc_plus4_m(pc_plus4_m_i),
        .tid_m(tid_m_i)
    );
    // Memory
    memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .NUM_THREADS(NUM_THREADS),
        .DMEM_SIZE(DMEM_SIZE)
    )
    memory_stage (
        .clk(clk),
        .reg_write_e(reg_write_m_i),
        .result_src_e(res_src_m_i),
        .mem_write_e(mem_write_m_i),
        .funct3_e(funct3_m_i),
        .alu_result_e(alu_result_m_i),
        .write_data_e(write_data_m_i),
        .rd_e(rd_m_i),
        .pc_plus4_e(pc_plus4_m_i),
        .tid_e(tid_m_i),

        .reg_write_m(reg_write_m_o),
        .result_src_m(result_src_m_o),
        .alu_result_m(alu_result_m_o),
        .read_data_m(read_data_m_o),
        .rd_m(rd_m_o),
        .pc_plus4_m(pc_plus4_m_o),
        .tid_m(tid_m_o)
    );

    // m to w pl_reg
    pl_reg_mw #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_THREADS(NUM_THREADS)
    )
    mw (
        .clk(clk),
        .en (1'b0),
        .clr(rst),

        .reg_write_m(reg_write_m_o),
        .result_src_m(result_src_m_o),
        .alu_result_m(alu_result_m_o),
        .read_data_m(read_data_m_o),
        .rd_m(rd_m_o),
        .pc_plus4_m(pc_plus4_m_o),
        .tid_m(tid_m_o),

        .reg_write_w(reg_write_w_i),
        .result_src_w(result_src_w_i),
        .alu_result_w(alu_result_w_i),
        .read_data_w(read_data_w_i),
        .rd_w(rd_w_i),
        .pc_plus4_w(pc_plus4_w_i),
        .tid_w(tid_w_i)
    );

    // Writeback
    writeback #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS_WIDTH(ADDRESS_WIDTH),
        .NUM_THREADS(NUM_THREADS)
    )
    writeback_stage (
        .reg_write_m(reg_write_w_i),
        .result_src_m(result_src_w_i),
        .alu_result_m(alu_result_w_i),
        .read_data_m(read_data_w_i),
        .rd_m(rd_w_i),
        .pc_plus4_m(pc_plus4_w_i),
        .tid_m(tid_w_i),

        .result_w(alu_result_w_o),
        .reg_write_w(reg_write_w_o),
        .rd_w(rd_w_o),
        .tid_w(tid_w_o)
    );

    tgrp_switcher #(
        .NUM_THREADS(NUM_THREADS)
    ) tgrp_switch (
        .clk(clk),
        .rst(rst),
        .mem_stall(mem_stall),
        .tid_stalled(tid_w_i-1),
        .tgrp(tgrp)
    );

    assign result = alu_result_w_i;
    assign pcw = pc_plus4_w_i - 4;
    assign mem_stall = swap_tgrp;
    assign kill = rst | swap_tgrp;

endmodule
