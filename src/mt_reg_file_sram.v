`default_nettype wire
module mt_reg_file #(
    parameter NUM_THREADS = 8,
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS = 32,
    parameter BITS_THREADS = $clog2(NUM_THREADS)
    )(
        input clk, write_enable,
        input tgrp,
        input [BITS_THREADS-1:0] tid_read, tid_write,
        input [4:0] a1, a2, a3,
        input [DATA_WIDTH-1:0] wd3,
        output [DATA_WIDTH-1:0] rd1, rd2
    );


// reg [DATA_WIDTH-1:0] reg_array [0:NUM_REGS*NUM_THREADS-1];
// reg [DATA_WIDTH-1:0] curr_reg_read [0:NUM_REGS-1];

// wire [BITS_THREADS-1:0] curr_read_tid;

// integer i;

// initial begin
//     for(i=0;i<NUM_REGS*NUM_THREADS-1;i=i+1) begin
//         reg_array[i] = 32'd0;
//     end
// end

// //asynchronous read logic
// assign rd1 = (a1[$clog2(NUM_REGS)-1:0] == 0) ? (32'd0) : (curr_reg_read[a1[$clog2(NUM_REGS)-1:0]]);
// assign rd2 = (a2[$clog2(NUM_REGS)-1:0] == 0) ? (32'd0) : (curr_reg_read[a2[$clog2(NUM_REGS)-1:0]]);

// // update curr reg and reg array
// always@(posedge clk) begin

//     if(write_enable)
//         reg_array[tid_write*NUM_REGS + a3[$clog2(NUM_REGS)-1:0]] <= wd3;

//     for(i=0;i<NUM_REGS;i=i+1) begin
//         curr_reg_read[i] <= reg_array[curr_read_tid*NUM_REGS + i];
//     end

// end

// assign curr_read_tid = tid_read;

// even and odd threads access reads and writes on the same cycle
// rf1 -> even threads and rf2 -> odd threads

wire [31:0] rf1rd1, rf1rd2, rf2rd1, rf2rd2;
wire rf1_r, rf1_w, rf2_r, rf2_w;
wire [4+2:0] rf1_index1, rf1_index2, rf2_index1, rf2_index2;

sram_128x32 tgrp_rf1(
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
    .clk0(clk),
    .csb0(rf1_r | rf1_w),
    .web0(rf1_w),
    .addr0(rf1_index1),
    .din0(wd3),
    .dout0(rf1rd1),
    .clk1(clk),
    .csb1(rf1_r),
    .addr1(rf1_index2),
    .dout1(rf1rd2)
);

sram_128x32 tgrp_rf2(
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
    .clk0(clk),
    .csb0(rf2_r | rf2_w),
    .web0(rf2_w),
    .addr0(rf2_index1),
    .din0(wd3),
    .dout0(rf2rd1),
    .clk1(clk),
    .csb1(rf2_r),
    .addr1(rf2_index2),
    .dout1(rf2rd2)
);

assign rf1_w = tid_write[0] == 0;
assign rf1_r = tid_write[0] != 0;
assign rf2_w = tid_write[0] == 1;
assign rf2_r = tid_write[0] != 1;

assign rf1_index1 = (rf1_w) ? {tgrp,tid_write[1],a3} : {tgrp,tid_read[1],a1};
assign rf1_index2 = (rf1_w) ? 0 : {tgrp,tid_read[1],a2};
assign rf2_index1 = (rf2_w) ? {tgrp,tid_write[1],a3} : {tgrp,tid_read[1],a1};
assign rf2_index2 = (rf2_w) ? 0 : {tgrp,tid_read[1],a2};

assign rd1 = (rf1_r) ? ((a1 == 0) ? 0 : rf1rd1) : ((a1 == 0) ? 0 : rf2rd1);
assign rd2 = (rf1_r) ? ((a2 == 0) ? 0 : rf1rd2) : ((a2 == 0) ? 0 : rf2rd2);

endmodule
