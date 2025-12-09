module mt_pc #(
    parameter NUM_THREADS = 4,
    parameter NUM_THREAD_GRPS = 2,
    parameter BITS_THREADS = $clog2(NUM_THREADS),
    parameter BITS_THREAD_GRPS = $clog2(NUM_THREAD_GRPS),
    parameter BITS_TID = $clog2(NUM_THREADS) + $clog2(NUM_THREAD_GRPS),
    parameter ADDRESS_WIDTH = 32
    )(
        input clk,rst,
        input sub_pcs,
        input tgrp_stalled,
        input [BITS_THREADS-1:0] tid_stalled,
        input tgrp,
        input [BITS_THREADS-1:0] tid,
        input pc_src_e,
        input branch_tgrp_e,
        input [BITS_THREADS-1:0] branch_tid_e,
        input [ADDRESS_WIDTH-1:0] pc_target_e,
        output reg [ADDRESS_WIDTH-1:0] pc,
        output [ADDRESS_WIDTH-1:0] pc_plus4
    );

reg [ADDRESS_WIDTH-1:0] t_pc [NUM_THREADS*NUM_THREAD_GRPS-1:0];
integer i;
integer j;

always @(*) begin
    // combinational read, avoid glitch
    pc = t_pc[{tgrp,tid}];
end

always @(posedge clk) begin
    if(rst) begin
        // clear all PC vals to 0
        // change later to seperate start vectors
        for(i=0;i<NUM_THREADS*NUM_THREAD_GRPS;i=i+1) begin
            t_pc[i] <= {ADDRESS_WIDTH{1'd0}};
        end
    end

    else begin
        if (sub_pcs) begin
            // for(j=0; j < tid_stalled; j=j+1) begin
            //     t_pc[j] <= t_pc[j]-4;
            // end
            // reset stalled thread group
            t_pc[{tgrp,tid_stalled-2'd2}] <= t_pc[{tgrp,tid_stalled-2'd2}]-4;
            t_pc[{tgrp,tid_stalled-2'd1}] <= t_pc[{tgrp,tid_stalled-2'd1}]-4;
            t_pc[{tgrp,tid_stalled}] <= t_pc[{tgrp_stalled,tid_stalled}]-4;
        end
        else begin
            // sequential update of pc
            t_pc[{tgrp,tid}] <= pc_plus4;
            // if branch/jump instruction, change pc accordingly
            if(pc_src_e)
                t_pc[{branch_tgrp_e,branch_tid_e}] <= pc_target_e;
        end

    end
end

assign pc_plus4 = pc + 4;

endmodule
