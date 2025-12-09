module control_unit(
    input [6:0] op,
    input [14:12] funct3,
    input funct7b5,

    output reg_write_d,
    output [1:0] res_src_d,
    output mem_write_d, jump_d, branch_d,
    output [3:0] alu_control_d,
    output alu_src_b_d, alu_src_a_d,
    output [2:0] imm_src_d
    );


// control bit format is
// regwrite_ressrc_memwrite_jump_branch_alusrca_alusrcb_immsrc
// auipc uses alternate source for a
// jalr uses alternate source for next pc adder
reg [10:0] controls;
reg [3:0] alu_controls;

// main decoder
always @(*) begin
    case(op)
    // load instr
    7'b0000011: controls = 11'b1_01_0_0_0_0_1_000;
    // immediate arithmetic instr
    7'b0010011: controls = 11'b1_00_0_0_0_0_1_000;
    // auipc
    7'b0010111: controls = 11'b1_00_0_0_0_1_1_100;
    // store instr
    7'b0100011: controls = 11'b0_01_1_0_0_0_1_001;
    // register arithmetic instr
    7'b0110011: controls = 11'b1_00_0_0_0_0_0_xxx;
    // lui
    7'b0110111: controls = 11'b1_00_0_0_0_0_1_100;
    // branch
    7'b1100011: controls = 11'b0_00_0_0_1_1_1_010;
    // jalr
    7'b1100111: controls = 11'b1_10_0_1_0_0_1_000;
    // jal
    7'b1101111: controls = 11'b1_10_0_1_0_1_1_011;
    // default
    default: controls = 11'dx;
    endcase
end

// alu decoder
always @(*) begin
    casez(op)
    // load instr
    7'b0000011: alu_controls = 4'b0000;
    // auipc
    7'b0010111: alu_controls = 4'b0000;
    // store instr
    7'b0100011: alu_controls = 4'b0000;
    // immediate and register arithmetic instr
    7'b0?10011: begin
        case(funct3)
            // sub, add
            3'b000: alu_controls = (funct7b5 & op[5]) ? 4'b0001 : 4'b0000;
            // shift left logical
            3'b001: alu_controls = 4'b0010;
            // set less than
            3'b010: alu_controls = 4'b0011;
            // set less than unsigned
            3'b011: alu_controls = 4'b0100;
            // xor
            3'b100: alu_controls = 4'b0101;
            // shift right arithmetic, logical
            3'b101: alu_controls = (funct7b5) ? 4'b0111 : 4'b0110;
            // or
            3'b110: alu_controls = 4'b1000;
            // and
            3'b111: alu_controls = 4'b1001;
        endcase
    end
    // lui
    7'b0110111: alu_controls = 4'b1101;
    // branch
    7'b1100011: alu_controls = 4'b0000;
    // jalr
    7'b1100111: alu_controls = 4'b0000;
    // jal
    7'b1101111: alu_controls = 4'b0000;
    // default
    default: alu_controls = 4'dx;
    endcase
end

assign {reg_write_d,res_src_d,mem_write_d,jump_d,branch_d,alu_src_a_d,alu_src_b_d,imm_src_d} = controls;
assign alu_control_d = alu_controls;
endmodule
