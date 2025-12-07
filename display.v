module display #(
    parameter n = 3,
    parameter P_COUNT_MAX = (1 << (n+1)) - 1,
    parameter P_WAIT_MAX  = 3 * P_COUNT_MAX,
    parameter WTIME_WIDTH = $clog2(P_WAIT_MAX + 1)
)(
    input  wire [n:0] Pcount,
    input  wire [WTIME_WIDTH:0] Pwait,
    output reg [3:0] pcount_seg, 
    output reg [3:0] TSeg1,  
    output reg [3:0] TSeg2   
);

    always @(*) begin
        pcount_seg = Pcount;
    end

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