`timescale 1ns / 1ps

module mbist_ram #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter FAULT_ENABLE = 0,
    parameter FAULT_ADDR = 8'd10
)(
    input                       clk,
    input                       en,
    input                       we,
    input [ADDR_WIDTH-1:0]      addr,
    input [DATA_WIDTH-1:0]      din,
    output reg [DATA_WIDTH-1:0] dout
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                if (FAULT_ENABLE && (addr == FAULT_ADDR))
                    mem[addr] <= din | {{(DATA_WIDTH-1){1'b0}}, 1'b1};
                else
                    mem[addr] <= din;
            end
            else begin
                dout <= mem[addr];
            end
        end
    end

endmodule
