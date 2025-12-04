// Queue NOT Top module, The top module will be the compination of the three modules
// input: two photocells - active low
// 		  2 bits -> number of tellers
// 		  clk and reset
// Output: Pcount

parameter   n = 3,
            idle = 2'b00, //states
            coming = 2'b01,
            leaving = 2'b10,
            P_COUNT_MAX = (1 << (n+1)) - 1, // driven values
            P_WAIT_MAX  = 3 * P_COUNT_MAX,
            WTIME_WIDTH = $clog2(P_WAIT_MAX + 1) -1 ;

module queue(
input reset,
input phcOne,phcTwo, // phc -> abbriviation for photocell // input 1-> if no interrupt, 0-> if interrupted, then it's negative edge activation -> in the senetivity list, which matches the push buttons in the FPGA Kit.
input [1:0] Tcount, // Number of tellers, MAX = 3 tellers
input clock,

output reg [n:0] Pcount, // Number of people , MAX = 99, displayed on Two seven segments
// divide the number by 10, make two instances of sevenBehaveioral, one segment for reminder of the division, other for the result.
output reg [WTIME_WIDTH:0] Pwait, // expected time to be waited untill served

output reg emptyFlag, fullFlag 
);

// TODO add comment here
reg [1:0] state;
reg [n+1:0] numerator;     // For calculation: 3*(Pcount+Tcount-1)

always @(negedge reset or negedge phcOne or negedge phcTwo) begin

    if(!reset) begin 
        Pcount <=0;
        Pwait <=0;
        fullFlag <= 0;
        emptyFlag <=1;

        state <= idle; 
    end
    else if(!phcOne) begin
        state <= coming;
        //Pcount <= Pcount +1;
    end
    else if(!phcTwo) begin
        state <= leaving;
        //Pcount <= Pcount -1;
    end

    else state <= idle;

end

always @(posedge clock) begin

    case(state) 

        idle: begin
                if(Pcount == P_COUNT_MAX ) fullFlag <= 1; 
                else if(Pcount == 0) emptyFlag <= 1;
                else begin
                fullFlag <=0;
                emptyFlag<=0;
                end

        end

        coming: begin
            if (!fullFlag ) begin
            Pcount <= Pcount +1;
            end
            
        end

        leaving: begin
            if(!emptyFlag) begin
            Pcount <= Pcount -1;
             end
        end
    
    endcase

end

always @(posedge clock or negedge reset) begin

    if(emptyFlag || !reset) Pwait <= 0;
    else begin

        numerator = 3 * (Pcount + Tcount - 1);
        case(Tcount)
        1: Pwait <= numerator;
        2: Pwait <= numerator >>1;
        3: Pwait <= numerator / 3;
        default: Pwait <= numerator;
        endcase

    end

end





endmodule
