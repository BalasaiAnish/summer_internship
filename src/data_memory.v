module data_memory #(
    parameter ADDRESS_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE = 64
    )(
    input clk, mem_write_e,
    input [14:12] funct3,
    input [ADDRESS_WIDTH-1:0] data_mem_addr,
    input [DATA_WIDTH-1:0] write_data_e,

    output reg [DATA_WIDTH-1:0] read_data_m
);

// initialise data memory
reg [DATA_WIDTH-1:0] ram [0:MEM_SIZE-1];
// word aligned memory access
/* verilator lint_off UNUSEDSIGNAL */
wire [ADDRESS_WIDTH-1:0] word_addr = {2'd0,data_mem_addr[ADDRESS_WIDTH-1:2]} % MEM_SIZE;
// read word
wire [DATA_WIDTH-1:0] word = ram[word_addr];

integer i;
initial begin
    for(i=0;i<MEM_SIZE;i=i+1) begin
        ram[i] = 0;
    end
end

// asynchronous read logic
always @(*) begin
    case(funct3)
        // lb
        3'b000: begin
            case(data_mem_addr[1:0])
                2'b00: read_data_m = {{24{word[7]}},word[7:0]};
                2'b01: read_data_m = {{24{word[7]}},word[15:8]};
                2'b10: read_data_m = {{24{word[7]}},word[23:16]};
                2'b11: read_data_m = {{24{word[7]}},word[31:24]};
            endcase
        end
        // lbu
        3'b100: begin
            case(data_mem_addr[1:0])
                2'b00: read_data_m = {24'd0,word[7:0]};
                2'b01: read_data_m = {24'd0,word[15:8]};
                2'b10: read_data_m = {24'd0,word[23:16]};
                2'b11: read_data_m = {24'd0,word[31:24]};
            endcase
        end
        // lh
        3'b001: begin
            read_data_m = (data_mem_addr[1]) ? ({{16{word[31]}},word[31:16]}) : ({{16{word[15]}},word[15:0]});
        end
        // lhu
        3'b101: begin
            read_data_m = (data_mem_addr[1]) ? ({16'd0,word[31:16]}) : ({16'd0,word[15:0]});
        end
        3'b010: begin
            read_data_m = word;
        end

        default: begin
            read_data_m = 32'd0;
        end
    endcase
end

// synchronous write logic
always@(posedge clk) begin
    if(mem_write_e) begin
        case(funct3)
            // sb
            3'b000: begin
                case(data_mem_addr[1:0])
                    2'b00: ram[word_addr][7:0] <= write_data_e[7:0];
                    2'b01: ram[word_addr][15:8] <= write_data_e[7:0];
                    2'b10: ram[word_addr][23:16] <= write_data_e[7:0];
                    2'b11: ram[word_addr][31:24] <= write_data_e[7:0];
                endcase
            end

            // sh
            3'b001: begin
                if(data_mem_addr[1]) ram[word_addr][31:16] <= write_data_e[15:0];
                else ram[word_addr][15:0] <= write_data_e[15:0];
            end
            // sw
            3'b010: begin
                ram[word_addr] <= write_data_e;
            end

            default: begin
                ram[word_addr] <= 32'd0;
            end
        endcase
    end

end

endmodule
