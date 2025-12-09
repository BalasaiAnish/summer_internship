`default_nettype wire
module mt_reg_file_bhv #(
    parameter NUM_THREADS = 8,
    parameter DATA_WIDTH = 32,
    parameter NUM_REGS = 16,
    parameter BITS_THREADS = $clog2(NUM_THREADS)
    )(
        input clk, write_enable,
        input tgrp,
        input [BITS_THREADS-1:0] tid_read, tid_write,
        input [4:0] a1, a2, a3,
        input [DATA_WIDTH-1:0] wd3,
        output [DATA_WIDTH-1:0] rd1, rd2
    );

    reg [DATA_WIDTH-1:0] reg_array_1 [0:NUM_REGS*NUM_THREADS-1];
    reg [DATA_WIDTH-1:0] reg_array_2 [0:NUM_REGS*NUM_THREADS-1];
    reg [DATA_WIDTH-1:0] curr_reg_read [0:NUM_REGS-1];

    wire [BITS_THREADS-1:0] curr_read_tid;

    integer i;

    initial begin
        for(i=0;i<NUM_REGS*NUM_THREADS-1;i=i+1) begin
            reg_array_1[i] = 32'd0;
            reg_array_2[i] = 32'd0;
        end
    end

    //asynchronous read logic
    assign rd1 = (a1[$clog2(NUM_REGS)-1:0] == 0) ? (32'd0) : (curr_reg_read[a1[$clog2(NUM_REGS)-1:0]]);
    assign rd2 = (a2[$clog2(NUM_REGS)-1:0] == 0) ? (32'd0) : (curr_reg_read[a2[$clog2(NUM_REGS)-1:0]]);

    // update curr reg and reg array
    always@(posedge clk) begin
        // copy current values into reg array
        // for(i=0;i<16;i=i+1) begin
        //     reg_array[prev_read_tid*16 + i] <= curr_reg_read[i];
        // end

        if(write_enable)
            if(tgrp == 0) begin
                reg_array_1[tid_write*NUM_REGS + a3[$clog2(NUM_REGS)-1:0]] <= wd3;
            end
            else begin
                reg_array_2[tid_write*NUM_REGS + a3[$clog2(NUM_REGS)-1:0]] <= wd3;
            end

        for(i=0;i<NUM_REGS;i=i+1) begin
            if(tgrp == 0) begin
                curr_reg_read[i] <= reg_array_1[curr_read_tid*NUM_REGS + i];
            end
            else begin
                curr_reg_read[i] <= reg_array_2[curr_read_tid*NUM_REGS + i];
            end
        end

    end

    assign curr_read_tid = tid_read;

endmodule
