module display #(
    parameter n = 3,
    parameter P_COUNT_MAX = (1 << (n+1)) - 1,
    parameter P_WAIT_MAX  = 3 * P_COUNT_MAX,
    parameter WTIME_WIDTH = $clog2(P_WAIT_MAX + 1)
)(
    input  wire [n:0] Pcount,
    input  wire [WTIME_WIDTH:0] Pwait,
    output reg [3:0] Pseg1,
	 output reg [3:0] Pseg2,
    output reg [3:0] TSeg1,  // tens digit of Pwait
    output reg [3:0] TSeg2   // units digit of Pwait
);

    // Extract tens and units digits of Pcount
    always @(*) begin
	 
		//pcount_seg = Pcount;
		  if (Pcount >= 60) begin
            Pseg1 = 6;
            Pseg2 = Pcount - 60;
        end else if (Pcount >= 50) begin
            Pseg1 = 5;
            Pseg2 = Pcount - 50;
        end else if (Pcount >= 40) begin
            Pseg1 = 4;
            Pseg2 = Pcount - 40;
        end else if (Pcount >= 30) begin
            Pseg1 = 3;
            Pseg2 = Pcount - 30;
        end else if (Pcount >= 20) begin
            Pseg1 = 2;
            Pseg2 = Pcount - 20;
        end else if (Pcount >= 10) begin
            Pseg1 = 1;
            Pseg2 = Pcount - 10;
        end else begin
            Pseg1 = 0;
            Pseg2 = Pcount;
        end

    end

    // Extract tens and units digits of Pwait
    always @(*) begin
        if (Pwait >= 60) begin
            TSeg1 = 6;
            TSeg2 = Pwait - 60;
        end else if (Pwait >= 50) begin
            TSeg1 = 5;
            TSeg2 = Pwait - 50;
        end else if (Pwait >= 40) begin
            TSeg1 = 4;
            TSeg2 = Pwait - 40;
        end else if (Pwait >= 30) begin
            TSeg1 = 3;
            TSeg2 = Pwait - 30;
        end else if (Pwait >= 20) begin
            TSeg1 = 2;
            TSeg2 = Pwait - 20;
        end else if (Pwait >= 10) begin
            TSeg1 = 1;
            TSeg2 = Pwait - 10;
        end else begin
            TSeg1 = 0;
            TSeg2 = Pwait;
        end
		  
		  
    end

endmodule