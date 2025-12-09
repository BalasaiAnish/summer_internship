module pl_reg_de #(
	parameter ADDRESS_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter NUM_THREADS = 8
	)(
	input clk,en,clr,

	input reg_write_d,
	input [1:0] res_src_d,
	input mem_write_d, jump_d, branch_d,
	input [3:0] alu_control_d,
	input [14:12] funct3_d,
	input alu_src_b_d, alu_src_a_d,
	input [DATA_WIDTH-1:0] rd1_d, rd2_d,
	input [ADDRESS_WIDTH-1:0] pc_d,
	input [4:0] rd_d,
	input [DATA_WIDTH-1:0] imm_val_d,
	input [ADDRESS_WIDTH-1:0] pc_plus4_d,
	input [BITS_THREADS-1:0] tid_d,

	output reg reg_write_e,
    output reg [1:0] res_src_e,
    output reg mem_write_e, jump_e, branch_e,
    output reg [3:0] alu_control_e,
    output reg [14:12] funct3_e,
    output reg alu_src_b_e, alu_src_a_e,
    output reg [DATA_WIDTH-1:0] rd1_e, rd2_e,
    output reg [ADDRESS_WIDTH-1:0] pc_e,
    output reg [4:0] rd_e,
    output reg [DATA_WIDTH-1:0] imm_val_e,
    output reg [ADDRESS_WIDTH-1:0] pc_plus4_e,
    output reg [BITS_THREADS-1:0] tid_e
);

localparam BITS_THREADS = $clog2(NUM_THREADS);

always@(posedge clk) begin
	if(clr) begin
	reg_write_e <= 0;
    res_src_e <= 0;
    mem_write_e <= 0;
    jump_e <= 0;
    branch_e <= 0;
    alu_control_e <= 0;
    funct3_e <= 0;
    alu_src_b_e <= 0;
    alu_src_a_e <= 0;
    rd1_e <= 0; rd2_e <= 0;
    pc_e <= 0;
    rd_e <= 0;
    imm_val_e <= 0;
    pc_plus4_e <= 0;
    tid_e <= 0;
	end

	else if(!en) begin
	reg_write_e <= reg_write_d;
    res_src_e <= res_src_d;
    mem_write_e <= mem_write_d;
    jump_e <= jump_d;
    branch_e <= branch_d;
    alu_control_e <= alu_control_d;
    funct3_e <= funct3_d;
    alu_src_b_e <= alu_src_b_d;
    alu_src_a_e <= alu_src_a_d;
    rd1_e <= rd1_d; rd2_e <= rd2_d;
    pc_e <= pc_d;
    rd_e <= rd_d;
    imm_val_e <= imm_val_d;
    pc_plus4_e <= pc_plus4_d;
    tid_e <= tid_d;
	end
end

endmodule
