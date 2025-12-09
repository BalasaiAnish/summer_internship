
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/27/2024 12:02:59 PM
// Design Name:
// Module Name: mux4
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


module mux4#(
    parameter DATA_WIDTH=32
    )(
    input [DATA_WIDTH-1:0] in1,in2,in3,in4,
    input [1:0] sel,
    output reg [DATA_WIDTH-1:0] out
);

always@(*) begin
    case(sel)
        2'b00: out = in1;
        2'b01: out = in2;
        2'b10: out = in3;
        2'b11: out = in4;
        default: out = 0;
    endcase

end
endmodule
