
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/10/2025 11:02:30 AM
// Design Name:
// Module Name: imm_ext
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module imm_ext(
    input [31:7] instr,
    input [2:0] imm_type,
    output reg [31:0] imm_val
    );

always @(*) begin
    case(imm_type)
        // I-type
        3'b000: imm_val = {{20{instr[31]}},instr[31:20]};
        // S-type
        3'b001: imm_val = {{20{instr[31]}},instr[31:25],instr[11:7]};
        // B-type
        3'b010: imm_val = {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
        // J-type
        3'b011: imm_val = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        // U-type
        3'b100: imm_val = {instr[31:12],12'b0};
        default: imm_val = 32'dx;
    endcase
end
endmodule
