module adder #(
    parameter DATA_WIDTH = 32
    )(
    input [DATA_WIDTH-1:0] a,b,
    output [DATA_WIDTH-1:0] res
);

assign res = a+b;

endmodule
