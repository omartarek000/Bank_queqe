module Final (
input reset,
input phcOne,phcTwo, // phc -> abbriviation for photocell // input 1-> if no interrupt, 0-> if interrupted, then it's negative edge activation -> in the senetivity list, which matches the push buttons in the FPGA Kit.
input [1:0] Tcount, // Number of tellers, MAX = 3 tellers
input clock,

output wire [6:0] Seg1,
output wire [6:0] Seg2,
output wire [6:0] Seg3,
output wire [6:0] Seg4,
output wire [1:0] flags,
);


     reg [3:0] PSeg1;  // tens digit of Pcount
     reg [3:0] PSeg2;  // units digit of Pcount
     reg [3:0] TSeg1;  // tens digit of Pwait
     reg [3:0] TSeg2;   // units digit of Pwait


queue Q1(reset,phcOne,phcTwo,Tcount,clock,Pcount,Pwait,emptyFlag.(flags[0]),fullFlag.(flags[1]));


display D1(.Pcount(Pcount), .Pwait(Pwait),PSeg1,PSeg2,TSeg1,TSeg2); // output Pset ... TSeg to the sevenbehavioral

sevenBehavioral segment1(.digit(PSeg1), .seg(Seg1));
sevenBehavioral segment2(.digit(PSeg2), .seg(Seg2));
sevenBehavioral segment3(.digit(PSeg3), .seg(Seg3));
sevenBehavioral segment4(.digit(PSeg4), .seg(Seg4));

endmodule