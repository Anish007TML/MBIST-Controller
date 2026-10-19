`timescale 1ns / 1ps

module tb_mbist;

    reg clk;
    reg reset;
    reg start;

    wire done_good;
    wire fail_good;

    wire done_faulty;
    wire fail_faulty;

    // Clock generation: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Normal memory test
    mbist_top #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32),
        .FAULT_ENABLE(0)
    ) mbist_good (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done_good),
        .fail(fail_good)
    );

    // Fault-injected memory test
    mbist_top #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32),
        .FAULT_ENABLE(1),
        .FAULT_ADDR(8'd10)
    ) mbist_faulty (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done_faulty),
        .fail(fail_faulty)
    );

    initial begin

        reset = 1'b1;
        start = 1'b0;

        // Hold reset for several clock cycles
        repeat (3) @(negedge clk);

        reset = 1'b0;

        // Start the MBIST test
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Wait for both tests to finish
        wait (done_good && done_faulty);

        #1;
        $display("MBIST SIMULATION RESULTS");

        $display("Normal memory DONE = %b", done_good);
        $display("Normal memory FAIL = %b", fail_good);

        $display("Faulty memory DONE = %b", done_faulty);
        $display("Faulty memory FAIL = %b", fail_faulty);

        if (done_good && !fail_good)
            $display("PASS: Normal memory test passed.");
        else
            $display("ERROR: Normal memory test failed.");

        if (done_faulty && fail_faulty)
            $display("PASS: Injected memory fault detected.");
        else
            $display("ERROR: Injected fault was not detected.");

        $finish;
    end
endmodule
