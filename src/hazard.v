module hazard #(
	parameter ADDRESS_WIDTH = 32,
	parameter DATA_WIDTH = 32
	)(
	input [4:0] rs1_d, rs2_d,

	input [4:0] rs1_e, rs2_e, rd_e,
	input pc_src_e,
	input res_src_e_b0,

	input [4:0] rd_m,
	input reg_write_m,

	input [4:0] rd_w,
	input reg_write_w,

	output stall_f,

	output stall_d, flush_d,

	output flush_e,
	output [1:0] forward_a_e, forward_b_e
);

wire lw_stall;

assign lw_stall = res_src_e_b0 & ((rs1_d == rd_e) | (rs2_d == rd_e));

assign stall_f = lw_stall;
assign stall_d = lw_stall;

assign forward_a_e = (((rs1_e == rd_m) & reg_write_m) & (rs1_e != 0)) ? 2'b01 : ( (((rs1_e == rd_w) & reg_write_w) & (rs1_e != 0)) ? 2'b10 : 2'b00);

assign forward_b_e = (((rs2_e == rd_m) & reg_write_m) & (rs2_e != 0)) ? 2'b01 : ( (((rs2_e == rd_w) & reg_write_w) & (rs2_e != 0)) ? 2'b10 : 2'b00);

assign flush_d = pc_src_e;
assign flush_e = lw_stall | pc_src_e;

endmodule
