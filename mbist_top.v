`timescale 1ns / 1ps

module mbist_top #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter FAULT_ENABLE = 0,
    parameter FAULT_ADDR = 8'd10
)(
    input clk,
    input reset,
    input start,

    output done,
    output fail
);

    wire ram_en;
    wire ram_we;

    wire [ADDR_WIDTH-1:0] ram_addr;
    wire [DATA_WIDTH-1:0] ram_din;
    wire [DATA_WIDTH-1:0] ram_dout;

    mbist_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) controller_inst (
        .clk(clk),
        .reset(reset),
        .start(start),

        .ram_en(ram_en),
        .ram_we(ram_we),
        .ram_addr(ram_addr),
        .ram_din(ram_din),
        .ram_dout(ram_dout),

        .done(done),
        .fail(fail)
    );

    mbist_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .FAULT_ENABLE(FAULT_ENABLE),
        .FAULT_ADDR(FAULT_ADDR)
    ) ram_inst (
        .clk(clk),
        .en(ram_en),
        .we(ram_we),
        .addr(ram_addr),
        .din(ram_din),
        .dout(ram_dout)
    );

endmodule
