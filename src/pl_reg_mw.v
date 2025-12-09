module pl_reg_mw #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_THREADS = 8
    )(
    input clk,
    en,
    clr,
    input reg_write_m,
    input [1:0] result_src_m,
    input [DATA_WIDTH-1:0] alu_result_m,
    input [DATA_WIDTH-1:0] read_data_m,
    input [4:0] rd_m,
    input [ADDRESS_WIDTH-1:0] pc_plus4_m,
    input [BITS_THREADS-1:0] tid_m,

    output reg reg_write_w,
    output reg [1:0] result_src_w,
    output reg [DATA_WIDTH-1:0] alu_result_w,
    output reg [DATA_WIDTH-1:0] read_data_w,
    output reg [4:0] rd_w,
    output reg [ADDRESS_WIDTH-1:0] pc_plus4_w,
    output reg [BITS_THREADS-1:0] tid_w
);

localparam BITS_THREADS = $clog2(NUM_THREADS);

    always @(posedge clk) begin
        if (clr) begin
            reg_write_w <= 1'b0;
            result_src_w <= 2'b00;
            alu_result_w <= 32'd0;
            read_data_w <= 32'd0;
            rd_w <= 5'd0;
            pc_plus4_w <= 32'd0;
            tid_w <= 3'd0;
        end else if (!en) begin
            reg_write_w <= reg_write_m;
            result_src_w <= result_src_m;
            alu_result_w <= alu_result_m;
            read_data_w <= read_data_m;
            rd_w <= rd_m;
            pc_plus4_w <= pc_plus4_m;
            tid_w <= tid_m;
        end
    end
endmodule
