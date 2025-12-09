// OpenRAM SRAM model
// Words: 128
// Word size: 32

module sram_128x32(
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
// Port 0: RW
    clk0,csb0,web0,spare_wen0,addr0,din0,dout0,
// Port 1: R
    clk1,csb1,addr1,dout1
  );

`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
  input  clk0; // clock
  input   csb0; // active low chip select
  input  web0; // active low write control
  input [7-1:0]  addr0;
  input           spare_wen0; // spare mask
  input [33-1:0]  din0;
  output [33-1:0] dout0;
  input  clk1; // clock
  input   csb1; // active low chip select
  input [7-1:0]  addr1;
  output [33-1:0] dout1;

  reg [33-1:0]    mem [0:(1 << 7)-1];

  reg  csb0_reg;
  reg  web0_reg;
  reg spare_wen0_reg;
  reg [7-1:0]  addr0_reg;
  reg [33-1:0]  din0_reg;
  reg [33-1:0]  dout0;

  // All inputs are registers
  always @(posedge clk0)
  begin
    csb0_reg = csb0;
    web0_reg = web0;
    spare_wen0_reg = spare_wen0;
    addr0_reg = addr0;
    din0_reg = din0;
    #(1) dout0 = 32'bx;
    if ( !csb0_reg && web0_reg && 1 )
      $display($time," Reading %m addr0=%b dout0=%b",addr0_reg,mem[addr0_reg]);
    if ( !csb0_reg && !web0_reg && 1 )
      $display($time," Writing %m addr0=%b din0=%b",addr0_reg,din0_reg);
  end

  reg  csb1_reg;
  reg [7-1:0]  addr1_reg;
  reg [33-1:0]  dout1;

  // All inputs are registers
  always @(posedge clk1)
  begin
    csb1_reg = csb1;
    addr1_reg = addr1;
    if (!csb0 && !web0 && !csb1 && (addr0 == addr1))
         $display($time," WARNING: Writing and reading addr0=%b and addr1=%b simultaneously!",addr0,addr1);
    #(1) dout1 = 32'bx;
    if ( !csb1_reg && 1 )
      $display($time," Reading %m addr1=%b dout1=%b",addr1_reg,mem[addr1_reg]);
  end


  // Memory Write Block Port 0
  // Write Operation : When web0 = 0, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_WRITE0
    if ( !csb0_reg && !web0_reg ) begin
        mem[addr0_reg][30:0] = din0_reg[30:0];
        if (spare_wen0_reg)
                mem[addr0_reg][32] = din0_reg[32];
    end
  end

  // Memory Read Block Port 0
  // Read Operation : When web0 = 1, csb0 = 0
  always @ (negedge clk0)
  begin : MEM_READ0
    if (!csb0_reg && web0_reg)
       dout0 <= #(3) mem[addr0_reg];
  end

  // Memory Read Block Port 1
  // Read Operation : When web1 = 1, csb1 = 0
  always @ (negedge clk1)
  begin : MEM_READ1
    if (!csb1_reg)
       dout1 <= #(3) mem[addr1_reg];
  end

endmodule
