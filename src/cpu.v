module cpu #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32
    )(
    input clk,
    input rst,

    output [DATA_WIDTH-1:0] result,
    output [ADDRESS_WIDTH-1:0] pcw
);

    // f to d
    wire [ADDRESS_WIDTH-1:0] pc_f_i, pc_plus4_f_i;
    wire [DATA_WIDTH-1:0] instr_f_i;

    wire [ADDRESS_WIDTH-1:0] pc_f_o, pc_plus4_f_o;
    wire [DATA_WIDTH-1:0] instr_f_o;

    // d to e
    wire [DATA_WIDTH-1:0] instr_d_i, rd1_d_i, rd2_d_i, imm_val_d_i;
    wire [ADDRESS_WIDTH-1:0] pc_d_i, pc_plus4_d_i;
    wire [4:0] rs1_d_i, rs2_d_i, rd_d_i;
    wire [3:0] alu_control_d_i;
    wire [1:0] res_src_d_i;
    wire mem_write_d_i, reg_write_d_i, jump_d_i, branch_d_i, alu_src_a_d_i, alu_src_b_d_i, adder_src_d_i;
    wire [2:0] funct3_d_i;

    wire [DATA_WIDTH-1:0] instr_d_o, rd1_d_o, rd2_d_o, imm_val_d_o;
    wire [ADDRESS_WIDTH-1:0] pc_d_o, pc_plus4_d_o;
    wire [4:0] rs1_d_o, rs2_d_o, rd_d_o;
    wire [3:0] alu_control_d_o;
    wire [1:0] res_src_d_o;
    wire mem_write_d_o, reg_write_d_o, jump_d_o, branch_d_o, alu_src_a_d_o, alu_src_b_d_o, adder_src_d_o;
    wire [2:0] funct3_d_o;

    // e to m
    wire [DATA_WIDTH-1:0] alu_result_e_i, write_data_e_i;
    wire [ADDRESS_WIDTH-1:0] pc_target_e_i, pc_plus4_e_i;
    wire pc_src_e_i, mem_write_e_i, reg_write_e_i;
    wire [1:0] res_src_e_i;
    wire [2:0] funct3_e_i;
    wire [4:0] rs1_e_i, rs2_e_i, rd_e_i;

    wire [DATA_WIDTH-1:0] alu_result_e_o, write_data_e_o;
    wire [ADDRESS_WIDTH-1:0] pc_target_e_o, pc_plus4_e_o;
    wire pc_src_e_o, mem_write_e_o, reg_write_e_o;
    wire [1:0] res_src_e_o;
    wire [2:0] funct3_e_o;
    wire [4:0] rd_e_o;

    // m to w
    wire reg_write_m_i;
    wire [1:0] result_src_m_i;
    wire [DATA_WIDTH-1:0] alu_result_m_i;
    wire [DATA_WIDTH-1:0] read_data_m_i;
    wire [4:0] rd_m_i;
    wire [ADDRESS_WIDTH-1:0] pc_plus4_m_i;

    wire reg_write_m_o;
    wire [1:0] result_src_m_o;
    wire [DATA_WIDTH-1:0] alu_result_m_o;
    wire [DATA_WIDTH-1:0] read_data_m_o;
    wire [4:0] rd_m_o;
    wire [ADDRESS_WIDTH-1:0] pc_plus4_m_o;

    // w to f
    wire [DATA_WIDTH-1:0] mem_data_w_i, alu_result_w_i;
    wire [ADDRESS_WIDTH-1:0] pc_plus4_w_i;
    wire [1:0] res_src_w_i;
    wire reg_write_w_i;
    wire [4:0] rd_w_i;

    wire [DATA_WIDTH-1:0] mem_data_w_o, alu_result_w_o;
    wire [ADDRESS_WIDTH-1:0] pc_plus4_w_o;
    wire [1:0] res_src_w_o;
    wire reg_write_w_o;

    // hazards
    wire stall_f, stall_d, flush_d, flush_e;
    wire [1:0] forward_a_e, forward_b_e;

    hazard hazard_unit(
        .rs1_d(instr_f_o[19:15]),
        .rs2_d(instr_f_o[24:20]),
    	.rs1_e(rs1_d_o),
    	.rs2_e(rs2_d_o),
    	.rd_e(rd_d_o),
    	.pc_src_e(pc_src_e_i),
    	.res_src_e_b0(res_src_d_o[0]),
    	.rd_m(rd_e_o),
    	.reg_write_m(reg_write_e_o),
    	.rd_w(rd_m_o),
    	.reg_write_w(reg_write_m_o),

    	.stall_f(stall_f),
    	.stall_d(stall_d),
    	.flush_d(flush_d),
    	.flush_e(flush_e),
    	.forward_a_e(forward_a_e),
    	.forward_b_e(forward_b_e)
    );

    // Fetch
    fetch fetch_stage (
        .clk(clk),
        .en(stall_f),
        .rst(rst),
        .pc_src_e(pc_src_e_i),
        .pc_target_e(pc_target_e_i),
        .pc_f(pc_f_i),
        .pc_plus4_f(pc_plus4_f_i),
        .instr_f(instr_f_i)
    );

    // f to d pl_reg

    pl_reg_fd fd (
        .clk(clk),
        .en(stall_f),
        .clr(rst),
        .pc_f_i(pc_f_i),
        .pc_plus4_f_i(pc_plus4_f_i),
        .instr_f_i(instr_f_i),
        .pc_f_o(pc_f_o),
        .pc_plus4_f_o(pc_plus4_f_o),
        .instr_f_o(instr_f_o)
    );

    // Decode
    decode decode_stage (
        .clk(clk),
        .reg_write_w(reg_write_w_i),
        .result_w(alu_result_w_i),
        .rd_w(rd_w_i),

        .instr_f(instr_f_o),
        .pc_f(pc_f_o),
        .pc_plus4_f(pc_plus4_f_o),

        .alu_control_d(alu_control_d_i),
        .funct3_d(funct3_d_i),
        .rd1_d(rd1_d_i),
        .rd2_d(rd2_d_i),
        .imm_val_d(imm_val_d_i),
        .pc_plus4_d(pc_plus4_d_i),
        .rs1_d(rs1_d_i),
        .rs2_d(rs2_d_i),
        .rd_d(rd_d_i),
        .pc_d(pc_d_i),
        .res_src_d(res_src_d_i),
        .mem_write_d(mem_write_d_i),
        .reg_write_d(reg_write_d_i),
        .jump_d(jump_d_i),
        .branch_d(branch_d_i),
        .alu_src_a_d(alu_src_a_d_i),
        .alu_src_b_d(alu_src_b_d_i),
        .adder_src_d(adder_src_d_i)
    );

    // d to e pl_reg
    pl_reg_de de (
        .clk(clk),
        .en (1'b0),
        .clr(flush_e | rst),

        .reg_write_d_i(reg_write_d_i),
        .res_src_d_i(res_src_d_i),
        .mem_write_d_i(mem_write_d_i),
        .jump_d_i(jump_d_i),
        .branch_d_i(branch_d_i),
        .alu_control_d_i(alu_control_d_i),
        .funct3_d_i(funct3_d_i),
        .alu_src_b_d_i(alu_src_b_d_i),
        .alu_src_a_d_i(alu_src_a_d_i),
        .adder_src_d_i(adder_src_d_i),
        .rd1_d_i(rd1_d_i),
        .rd2_d_i(rd2_d_i),
        .pc_d_i(pc_d_i),
        .rs1_d_i(rs1_d_i),
        .rs2_d_i(rs2_d_i),
        .rd_d_i(rd_d_i),
        .imm_val_d_i(imm_val_d_i),
        .pc_plus4_d_i(pc_plus4_d_i),

        .reg_write_d_o(reg_write_d_o),
        .res_src_d_o(res_src_d_o),
        .mem_write_d_o(mem_write_d_o),
        .jump_d_o(jump_d_o),
        .branch_d_o(branch_d_o),
        .alu_control_d_o(alu_control_d_o),
        .funct3_d_o(funct3_d_o),
        .alu_src_b_d_o(alu_src_b_d_o),
        .alu_src_a_d_o(alu_src_a_d_o),
        .adder_src_d_o(adder_src_d_o),
        .rd1_d_o(rd1_d_o),
        .rd2_d_o(rd2_d_o),
        .pc_d_o(pc_d_o),
        .rs1_d_o(rs1_d_o),
        .rs2_d_o(rs2_d_o),
        .rd_d_o(rd_d_o),
        .imm_val_d_o(imm_val_d_o),
        .pc_plus4_d_o(pc_plus4_d_o)
    );
    // Execute
    execute execute_stage (
        .reg_write_d(reg_write_d_o),
        .res_src_d(res_src_d_o),
        .mem_write_d(mem_write_d_o),
        .jump_d(jump_d_o),
        .branch_d(branch_d_o),
        .alu_control_d(alu_control_d_o),
        .funct3_d(funct3_d_o),
        .alu_src_b_d(alu_src_b_d_o),
        .alu_src_a_d(alu_src_a_d_o),
        .adder_src_d(adder_src_d_o),
        .rd1_d(rd1_d_o),
        .rd2_d(rd2_d_o),
        .pc_d(pc_d_o),
        .rs1_d(rs1_d_o),
        .rs2_d(rs2_d_o),
        .rd_d(rd_d_o),
        .imm_val_d(imm_val_d_o),
        .pc_plus4_d(pc_plus4_d_o),

        .alu_result_m(alu_result_m_i),
        .alu_result_w(alu_result_w_i),
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e),

        .reg_write_e(reg_write_e_i),
        .res_src_e(res_src_e_i),
        .mem_write_e(mem_write_e_i),
        .alu_result_e(alu_result_e_i),
        .write_data_e(write_data_e_i),
        .pc_plus4_e(pc_plus4_e_i),
        .pc_target_e(pc_target_e_i),
        .pc_src_e(pc_src_e_i),
        .funct3_e(funct3_e_i),
        .rd_e(rd_e_i)
    );

    // e to m pl_reg
    pl_reg_em em (
        .clk(clk),
        .en (1'b0),
        .clr(rst),

        .reg_write_e_i(reg_write_e_i),
        .mem_write_e_i(mem_write_e_i),
        .result_src_e_i(res_src_e_i),
        .funct3_e_i(funct3_e_i),
        .alu_result_e_i(alu_result_e_i),
        .write_data_e_i(write_data_e_i),
        .rd_e_i(rd_e_i),
        .pc_plus4_e_i(pc_plus4_e_i),

        .reg_write_e_o(reg_write_e_o),
        .mem_write_e_o(mem_write_e_o),
        .result_src_e_o(res_src_e_o),
        .funct3_e_o(funct3_e_o),
        .alu_result_e_o(alu_result_e_o),
        .write_data_e_o(write_data_e_o),
        .rd_e_o(rd_e_o),
        .pc_plus4_e_o(pc_plus4_e_o)
    );
    // Memory
    memory memory_stage (
        .clk(clk),
        .reg_write_e(reg_write_e_o),
        .result_src_e(res_src_e_o),
        .mem_write_e(mem_write_e_o),
        .funct3_e(funct3_e_o),
        .alu_result_e(alu_result_e_o),
        .write_data_e(write_data_e_o),
        .rd_e(rd_e_o),
        .pc_plus4_e(pc_plus4_e_o),

        .reg_write_m(reg_write_m_i),
        .result_src_m(result_src_m_i),
        .alu_result_m(alu_result_m_i),
        .read_data_m(read_data_m_i),
        .rd_m(rd_m_i),
        .pc_plus4_m(pc_plus4_m_i)
    );

    // m to w pl_reg
    pl_reg_mw mw (
        .clk(clk),
        .en (1'b0),
        .clr(rst),

        .reg_write_m_i(reg_write_m_i),
        .result_src_m_i(result_src_m_i),
        .alu_result_m_i(alu_result_m_i),
        .read_data_m_i(read_data_m_i),
        .rd_m_i(rd_m_i),
        .pc_plus4_m_i(pc_plus4_m_i),

        .reg_write_m_o(reg_write_m_o),
        .result_src_m_o(result_src_m_o),
        .alu_result_m_o(alu_result_m_o),
        .read_data_m_o(read_data_m_o),
        .rd_m_o(rd_m_o),
        .pc_plus4_m_o(pc_plus4_m_o)
    );

    // Writeback
    writeback writeback_stage (
        .reg_write_m(reg_write_m_o),
        .result_src_m(result_src_m_o),
        .alu_result_m(alu_result_m_o),
        .read_data_m(read_data_m_o),
        .rd_m(rd_m_o),
        .pc_plus4_m(pc_plus4_m_o),

        .result_w(alu_result_w_i),
        .reg_write_w(reg_write_w_i),
        .rd_w(rd_w_i)
    );

    assign result = alu_result_w_i;

    assign pcw = pc_plus4_m_o - 4;

endmodule
