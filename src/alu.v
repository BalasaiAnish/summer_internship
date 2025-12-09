module alu #(
    parameter DATA_WIDTH = 32
    )(
    input [DATA_WIDTH-1:0] a,b,
    input [3:0] alu_controls,
    output reg [DATA_WIDTH-1:0] res
);

always @(*) begin
    case(alu_controls)
        4'b0000: res = a+b;
        4'b0001: res = a-b;
        4'b0010: res = a << (b[4:0]);
        4'b0011: res = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
        4'b0100: res = ($unsigned(a) < $unsigned(b)) ? 32'd1 : 32'd0;
        4'b0101: res = a^b;
        4'b0110: res = a >> (b[4:0]);
        4'b0111: res = $signed(a) >>> (b[4:0]);
        4'b1000: res = a | b;
        4'b1001: res = a & b;
        4'b1101: res = b;
        default: res = 32'd0;
    endcase

    
end
endmodule
