module instr_mem #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE = 512
    )(
    /* verilator lint_off UNUSEDSIGNAL */
    input [ADDRESS_WIDTH-1:0] instr_addr,
    output [DATA_WIDTH-1:0] instr
    );

// wire for memory address access
// array of 32-bit words or instructions
reg [DATA_WIDTH-1:0] instr_rom [0:MEM_SIZE-1];
initial begin
        $readmemh("/home/bala/git_stuff/summer_internship/src/code.mem", instr_rom);
    end

// word-aligned memory access
// combinational read logic
assign instr = instr_rom[instr_addr[$clog2(MEM_SIZE)+2-1:2]];

endmodule
