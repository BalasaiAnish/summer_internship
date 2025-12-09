module memory #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter DMEM_SIZE = 64,
    parameter NUM_THREADS = 4
    )(
    input clk, reg_write_e,
    input [1:0] result_src_e,
    input mem_write_e,
    input [14:12] funct3_e,

    input [DATA_WIDTH-1:0] alu_result_e, write_data_e,
    input [4:0] rd_e,
    input [ADDRESS_WIDTH-1:0] pc_plus4_e,
    input [BITS_THREADS-1:0] tid_e,

    output reg_write_m,
    output [1:0] result_src_m,
    output [DATA_WIDTH-1:0] alu_result_m,
    output [DATA_WIDTH-1:0] read_data_m,
    output [4:0] rd_m,
    output [ADDRESS_WIDTH-1:0] pc_plus4_m,
    output [BITS_THREADS-1:0] tid_m
);
localparam BITS_THREADS = $clog2(NUM_THREADS);

data_memory #(
    .ADDRESS_WIDTH(ADDRESS_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_SIZE(DMEM_SIZE)
)
dm(
    .clk(clk),
    .mem_write_e(mem_write_e),
    .funct3(funct3_e),
    .data_mem_addr(alu_result_e),
    .write_data_e(write_data_e),
    .read_data_m(read_data_m)
);

assign reg_write_m = reg_write_e;
assign result_src_m = result_src_e;
assign alu_result_m = alu_result_e;
assign rd_m = rd_e;
assign pc_plus4_m = pc_plus4_e;
assign tid_m = tid_e;

endmodule
