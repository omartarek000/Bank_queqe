module Final (
    input reset,
    input phcOne, phcTwo,  // phc -> abbreviation for photocell
    input [2:0] Tcount,    // Number of tellers, MAX = 3 tellers
    input FPGA_clk,

    output wire [6:0] Seg1,
	 output wire [6:0] Seg2,
    output wire [6:0] Seg3,
    output wire [6:0] Seg4,
    output wire [1:0] flags
);

    // Internal wires
    wire [3:0] PSeg1;  // tens digit of Pcount
    wire [3:0] PSeg2;  // tens digit of Pcount
    wire [3:0] TSeg1;  // tens digit of Pwait
    wire [3:0] TSeg2;  // units digit of Pwait
    wire clock;
    wire [3:0] Pcount;
    wire [1:0] Tcount_wire;
    wire [6:0] Pwait;
     
    // Clock divider instance
    divider #(.COUNT_MAX(500_000)) Div1 (
        .clk(FPGA_clk),
        .reset(reset),
        .clock(clock)
    );

	 
	 tellers_to_digit T1(
	 .t1(Tcount[0]),
	 .t2(Tcount[1]),
	 .t3(Tcount[2]),
	 .digit(Tcount_wire)
	 );
    // Queue management instance
    queue Q1(
        .reset(reset),
        .phcOne(phcOne),
        .phcTwo(phcTwo),
        .Tcount(Tcount_wire),
        .clock(clock),
        .Pcount(Pcount),
        .Pwait(Pwait),
        .emptyFlag(flags[0]),
        .fullFlag(flags[1])
    );

    // Display decoder instance
    display D1(
        .Pcount(Pcount),
        .Pwait(Pwait),
        .Pseg1(PSeg1),
		  .Pseg2(PSeg2),
        .TSeg1(TSeg1),
        .TSeg2(TSeg2)
    );

    // Seven-segment decoder instances
    sevenBehavioral segment1(.digit(PSeg1), .seg(Seg1));
    sevenBehavioral segment2(.digit(PSeg2), .seg(Seg2));
    sevenBehavioral segment3(.digit(TSeg1), .seg(Seg3));
    sevenBehavioral segment4(.digit(TSeg2), .seg(Seg4));

endmodule