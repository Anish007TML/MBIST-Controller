`timescale 1ns / 1ps

module mbist_controller #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input clk,
    input reset,
    input start,

    output reg ram_en,
    output reg ram_we,
    output reg [ADDR_WIDTH-1:0] ram_addr,
    output reg [DATA_WIDTH-1:0] ram_din,
    input [DATA_WIDTH-1:0] ram_dout,

    output reg done,
    output reg fail
);

    localparam DEPTH = (1 << ADDR_WIDTH);
    localparam LAST_ADDR = DEPTH - 1;

    localparam ZERO = {DATA_WIDTH{1'b0}};
    localparam ONES = {DATA_WIDTH{1'b1}};

    // FSM state encoding
    localparam IDLE       = 5'd0;
    localparam W0_UP      = 5'd1;

    localparam R0W1_READ  = 5'd2;
    localparam R0W1_CHECK = 5'd3;
    localparam R0W1_WRITE = 5'd4;

    localparam R1W0_READ  = 5'd5;
    localparam R1W0_CHECK = 5'd6;
    localparam R1W0_WRITE = 5'd7;

    localparam R0W1D_READ  = 5'd8;
    localparam R0W1D_CHECK = 5'd9;
    localparam R0W1D_WRITE = 5'd10;

    localparam R1W0D_READ  = 5'd11;
    localparam R1W0D_CHECK = 5'd12;
    localparam R1W0D_WRITE = 5'd13;

    localparam FINAL_READ  = 5'd14;
    localparam FINAL_CHECK = 5'd15;

    localparam FINISH = 5'd16;

    reg [4:0] state;

    always @(posedge clk) begin

        if (reset) begin
            state    <= IDLE;
            ram_en   <= 1'b0;
            ram_we   <= 1'b0;
            ram_addr <= {ADDR_WIDTH{1'b0}};
            ram_din  <= ZERO;
            done     <= 1'b0;
            fail     <= 1'b0;
        end

        else begin

            // Default controls
            ram_en <= 1'b0;
            ram_we <= 1'b0;

            case (state)

                IDLE: begin
                    done <= 1'b0;
                    fail <= 1'b0;

                    if (start) begin
                        ram_addr <= {ADDR_WIDTH{1'b0}};
                        state <= W0_UP;
                    end
                end

                // Phase 1: (ascending) write 0
                W0_UP: begin
                    ram_en   <= 1'b1;
                    ram_we   <= 1'b1;
                    ram_din  <= ZERO;

                    if (ram_addr == LAST_ADDR) begin
                        ram_addr <= {ADDR_WIDTH{1'b0}};
                        state <= R0W1_READ;
                    end
                    else begin
                        ram_addr <= ram_addr + 1'b1;
                    end
                end

                // Phase 2: (ascending) read 0, write 1
                R0W1_READ: begin
                    ram_en <= 1'b1;
                    ram_we <= 1'b0;
                    state <= R0W1_CHECK;
                end

                R0W1_CHECK: begin
                    if (ram_dout !== ZERO)
                        fail <= 1'b1;

                    state <= R0W1_WRITE;
                end

                R0W1_WRITE: begin
                    ram_en  <= 1'b1;
                    ram_we  <= 1'b1;
                    ram_din <= ONES;

                    if (ram_addr == LAST_ADDR) begin
                        ram_addr <= {ADDR_WIDTH{1'b0}};
                        state <= R1W0_READ;
                    end
                    else begin
                        ram_addr <= ram_addr + 1'b1;
                        state <= R0W1_READ;
                    end
                end

                // Phase 3: (ascending) read 1, write 0
                R1W0_READ: begin
                    ram_en <= 1'b1;
                    ram_we <= 1'b0;
                    state <= R1W0_CHECK;
                end

                R1W0_CHECK: begin
                    if (ram_dout !== ONES)
                        fail <= 1'b1;

                    state <= R1W0_WRITE;
                end

                R1W0_WRITE: begin
                    ram_en  <= 1'b1;
                    ram_we  <= 1'b1;
                    ram_din <= ZERO;

                    if (ram_addr == LAST_ADDR) begin
                        ram_addr <= LAST_ADDR;
                        state <= R0W1D_READ;
                    end
                    else begin
                        ram_addr <= ram_addr + 1'b1;
                        state <= R1W0_READ;
                    end
                end

                // Phase 4: (descending) read 0, write 1
                R0W1D_READ: begin
                    ram_en <= 1'b1;
                    ram_we <= 1'b0;
                    state <= R0W1D_CHECK;
                end

                R0W1D_CHECK: begin
                    if (ram_dout !== ZERO)
                        fail <= 1'b1;

                    state <= R0W1D_WRITE;
                end

                R0W1D_WRITE: begin
                    ram_en  <= 1'b1;
                    ram_we  <= 1'b1;
                    ram_din <= ONES;

                    if (ram_addr == 0) begin
                        ram_addr <= {ADDR_WIDTH{1'b0}};
                        state <= R1W0D_READ;
                    end
                    else begin
                        ram_addr <= ram_addr - 1'b1;
                        state <= R0W1D_READ;
                    end
                end
              
              // Phase 5: (descending) read 1, write 0
                R1W0D_READ: begin
                    ram_en <= 1'b1;
                    ram_we <= 1'b0;
                    state <= R1W0D_CHECK;
                end

                R1W0D_CHECK: begin
                    if (ram_dout !== ONES)
                        fail <= 1'b1;

                    state <= R1W0D_WRITE;
                end

                R1W0D_WRITE: begin
                    ram_en  <= 1'b1;
                    ram_we  <= 1'b1;
                    ram_din <= ZERO;

                    if (ram_addr == 0) begin
                        ram_addr <= {ADDR_WIDTH{1'b0}};
                        state <= FINAL_READ;
                    end
                    else begin
                        ram_addr <= ram_addr - 1'b1;
                        state <= R1W0D_READ;
                    end
                end

                // Phase 6: (ascending) read 0
                FINAL_READ: begin
                    ram_en <= 1'b1;
                    ram_we <= 1'b0;
                    state <= FINAL_CHECK;
                end

                FINAL_CHECK: begin
                    if (ram_dout !== ZERO)
                        fail <= 1'b1;

                    if (ram_addr == LAST_ADDR) begin
                        state <= FINISH;
                    end
                    else begin
                        ram_addr <= ram_addr + 1'b1;
                        state <= FINAL_READ;
                    end
                end

                FINISH: begin
                    done <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
