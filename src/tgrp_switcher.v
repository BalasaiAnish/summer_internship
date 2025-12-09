module tgrp_switcher #(
        parameter NUM_THREADS=4,
        parameter NUM_THREAD_GROUPS=2,
        parameter ADDRESS_WIDTH=32
    ) (
        input clk, rst, mem_stall,
        input [$clog2(NUM_THREADS)-1:0] tid_stalled,
        output tgrp
    );

reg [$clog2(NUM_THREAD_GROUPS)-1:0] tgrp_reg;

always @(posedge clk) begin
    if(rst) begin
        tgrp_reg <= 0;
    end
    else if (mem_stall) begin
        tgrp_reg <= ~tgrp;
    end
end

assign tgrp = tgrp_reg;

endmodule
