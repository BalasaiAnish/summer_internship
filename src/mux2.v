
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12/27/2024 12:02:59 PM
// Design Name:
// Module Name: mux2
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


module mux2 #(
    parameter DATA_WIDTH=32
    )(
    input [DATA_WIDTH-1:0] in1,in2,
    input sel,
    output[DATA_WIDTH-1:0] out
);

assign out = sel ? in2 : in1;
endmodule
