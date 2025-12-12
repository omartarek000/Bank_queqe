`timescale 1ns / 1ps

module tb_Final;

    // Inputs
    reg reset;
    reg phcOne, phcTwo;
    reg [2:0] Tcount;
    reg FPGA_clk;

    // Outputs
    wire [6:0] Seg1, Seg2, Seg3, Seg4;
    wire [1:0] flags;  // {emptyFlag, fullFlag}

    // Instantiate the top module
    Final uut (
        .reset     (reset),
        .phcOne    (phcOne),
        .phcTwo    (phcTwo),
        .Tcount    (Tcount),
        .FPGA_clk  (FPGA_clk),
        .Seg1      (Seg1),
        .Seg2      (Seg2),
        .Seg3      (Seg3),
        .Seg4      (Seg4),
        .flags     (flags)
    );

    // Make simulation fast: change clock divider from 500_000 to 50
    defparam uut.Div1.COUNT_MAX = 50;

    // 50 MHz clock ? 20 ns period
    always #10 FPGA_clk = ~FPGA_clk;

    // Tasks ? synchronized to the divided clock (uut.clock)
    task photocell_enter;
        begin
            @(posedge uut.clock);
            phcOne = 0;           // person blocks photocell ? falling edge
            @(posedge uut.clock);
            phcOne = 1;           // person passed
        end
    endtask

    task photocell_leave;
        begin
            @(posedge uut.clock);
            phcTwo = 0;
            @(posedge uut.clock);
            phcTwo = 1;
        end
    endtask

    initial begin
        // Initial values
        FPGA_clk = 0;
        reset    = 0;   // active-low reset
        phcOne   = 1;
        phcTwo   = 1;
        Tcount   = 3'b000;

        // Reset pulse
        #200;
        reset = 1;      // release reset
        #400;

        $display("\n=== Bank Queue System Test Started ===\n");

        // Test 1: 1 teller
        Tcount = 3'b001;
        $display("[%0t] 1 Teller active", $time);
        repeat(8) photocell_enter();
        #2000;
        if (uut.Q1.Pcount == 8 && uut.Q1.Pwait == 24)
            $display("PASS: 8 people ? Pwait = 24");
        else
            $display("FAIL: Pcount=%d Pwait=%d", uut.Q1.Pcount, uut.Q1.Pwait);

        // Test 2: 2 tellers
        Tcount = 3'b011;
        $display("[%0t] 2 Tellers active", $time);
        repeat(10) photocell_enter();
        #2000;
        if (uut.Q1.Pcount == 18 && uut.Q1.Pwait == 27)  // base=18+2-1=19 ? 3*19/2 = 28?27 (integer div)
            $display("PASS: 18 people, 2 tellers ? Pwait = 27");
        else
            $display("FAIL");

        // Test 3: 3 tellers (fastest)
        Tcount = 3'b111;
        $display("[%0t] 3 Tellers active", $time);
        #2000;

        // Fill queue to max (15)
        Tcount = 3'b001;
        repeat(20) photocell_enter();  // should stop at 15
        #2000;
        if (uut.Q1.Pcount == 15 && flags[1]==1)
            $display("PASS: Queue FULL detected");
        else
            $display("FAIL: Full flag");

        // Empty queue
        repeat(20) photocell_leave();
        #2000;
        if (uut.Q1.Pcount == 0 && flags[0]==1)
            $display("PASS: Queue EMPTY detected");
        else
            $display("FAIL: Empty flag");

        $display("\n=== ALL TESTS FINISHED ===\n");
        #5000 $finish;
    end

    // Nice monitoring
    initial
        $monitor("t=%0t | T=%d | P=%02d Wait=%02d | Flags(E F)=%b%b | Disp %d%d : %d%d",
                 $time,
                 Tcount[0]+Tcount[1]+Tcount[2],
                 uut.Q1.Pcount,
                 uut.Q1.Pwait,
                 flags[0], flags[1],
                 uut.D1.Pseg1, uut.D1.Pseg2,
                 uut.D1.TSeg1, uut.D1.TSeg2);

    // Waveform dump
    initial begin
        $dumpfile("queue_system.vcd");
        $dumpvars(0, tb_Final);
    end

endmodule