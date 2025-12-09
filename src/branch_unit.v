module branch_unit #(
    parameter DATA_WIDTH = 32
    )(
    input [DATA_WIDTH-1:0] a,b,
    input [2:0] funct3,
    output reg branch_result
    );

always @(*) begin
    casez(funct3)
        // branch eq, neq
        3'b00?: branch_result = funct3[0] ^ (a == b);
        // branch lt, ge
        3'b10?: branch_result = funct3[0] ^ ($signed(a) < $signed(b));
        // branch ltu, geu
        3'b11?: branch_result = funct3[0] ^ (a < b);
        default: branch_result = 0;
    endcase
end

endmodule
