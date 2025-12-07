module Final (
input reset,
input phcOne,phcTwo, // phc -> abbriviation for photocell // input 1-> if no interrupt, 0-> if interrupted, then it's negative edge activation -> in the senetivity list, which matches the push buttons in the FPGA Kit.
input [1:0] Tcount, // Number of tellers, MAX = 3 tellers
input FPGA_clk,

output wire [6:0] Seg1,
output wire [6:0] Seg2,
output wire [6:0] Seg3,
output wire [6:0] Seg4,
output wire [1:0] flags
);


      wire [3:0] PSeg1;  // tens digit of Pcount
      wire [3:0] PSeg2;  // units digit of Pcount
      wire [3:0] TSeg1;  // tens digit of Pwait
      wire [3:0] TSeg2;   // units digit of Pwait
     wire clock;
     
divider #(.n(500_000)) Div1 (
    .clk(FPGA_clk),
    .reset(reset),
    .clock(clock)
);

queue Q1(
    .reset(reset),
    .phcOne(phcOne),
    .phcTwo(phcTwo),
    .Tcount(Tcount),
    .clock(clock),
    .Pcount(Pcount),
    .Pwait(Pwait),
    .emptyFlag(flags[0]),
    .fullFlag(flags[1])
);

display D1(
    .Pcount(Pcount),
    .Pwait(Pwait),
    .PSeg1(PSeg1),
    .PSeg2(PSeg2),
    .TSeg1(TSeg1),
    .TSeg2(TSeg2)
);

sevenBehavioral segment1(.digit(PSeg1), .seg(Seg1));
sevenBehavioral segment2(.digit(PSeg2), .seg(Seg2));
sevenBehavioral segment3(.digit(TSeg1), .seg(Seg3));
sevenBehavioral segment4(.digit(TSeg2), .seg(Seg4));


endmodule
