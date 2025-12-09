module pl_reg_em #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_THREADS = 8
    )(
    input clk,
    en,
    clr,

    input reg_write_e,
    input mem_write_e,
    input [1:0] result_src_e,
    input [14:12] funct3_e,
    input [DATA_WIDTH-1:0] alu_result_e,
    write_data_e,
    input [4:0] rd_e,
    input [ADDRESS_WIDTH-1:0] pc_plus4_e,
    input [BITS_THREADS-1:0] tid_e,

    output reg reg_write_m,
    output reg mem_write_m,
    output reg [1:0] result_src_m,
    output reg [14:12] funct3_m,
    output reg [DATA_WIDTH-1:0] alu_result_m,
    write_data_m,
    output reg [4:0] rd_m,
    output reg [ADDRESS_WIDTH-1:0] pc_plus4_m,
    output reg [BITS_THREADS-1:0] tid_m
);
localparam BITS_THREADS = $clog2(NUM_THREADS);

    always @(posedge clk) begin
        if (clr) begin
            reg_write_m <= 1'b0;
            mem_write_m <= 1'b0;
            result_src_m <= 2'b00;
            funct3_m <= 3'b0;
            alu_result_m <= 32'd0;
            write_data_m <= 32'd0;
            rd_m <= 5'd0;
            pc_plus4_m <= 32'd0;
            tid_m <= 3'd0;
        end else if (!en) begin
            reg_write_m <= reg_write_e;
            mem_write_m <= mem_write_e;
            result_src_m <= result_src_e;
            funct3_m <= funct3_e;
            alu_result_m <= alu_result_e;
            write_data_m <= write_data_e;
            rd_m <= rd_e;
            pc_plus4_m <= pc_plus4_e;
            tid_m <= tid_e;
        end
    end
endmodule
