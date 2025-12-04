// display.v
// Converts Pcount and Pwait (binary) to 4 BCD digits for 7-seg display
// Author: Mahmoud
// Fully parameterized and ModelSim/Quartus compatible (Verilog-2001)

module display #(
    parameter n = 3,
    // Derived parameters (computed at elaboration time)
    parameter P_COUNT_MAX = (1 << (n+1)) - 1,
    parameter P_WAIT_MAX  = 3 * P_COUNT_MAX,
    parameter WTIME_WIDTH = $clog2(P_WAIT_MAX + 1)
)(
    input  [n:0] Pcount,
    input  [WTIME_WIDTH-1:0] Pwait,
    
    output reg [3:0] PSeg1,  // tens digit of Pcount
    output reg [3:0] PSeg2,  // units digit of Pcount
    output reg [3:0] TSeg1,  // tens digit of Pwait
    output reg [3:0] TSeg2   // units digit of Pwait
);

    // Convert Pcount to decimal digits
    always @(*) begin
        PSeg1 = Pcount / 10;
        PSeg2 = Pcount % 10;
    end

    // Convert Pwait to decimal digits
    always @(*) begin
        TSeg1 = Pwait / 10;
        TSeg2 = Pwait % 10;
    end

endmodule
