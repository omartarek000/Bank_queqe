// Queue NOT Top module, The top module will be the combination of the three modules
// input: two photocells - active low
//        2 bits -> number of tellers
//        clk and reset
// Output: Pcount

module queue #(
    parameter n = 3,
    parameter idle = 2'b00,    // states
    parameter coming = 2'b01,
    parameter leaving = 2'b10,

    parameter P_COUNT_MAX = (1 << (n+1)) - 1,
    parameter P_WAIT_MAX  = 3 * P_COUNT_MAX,
    parameter WTIME_WIDTH = $clog2(P_WAIT_MAX + 1)
)(
    input reset,
    input phcOne, phcTwo,      // phc -> abbreviation for photocell
    input [1:0] Tcount,        // Number of tellers, MAX = 3 tellers
    input clock,
    output reg [n:0] Pcount,   // Number of people, MAX = 15 (for n=3)
    output reg [WTIME_WIDTH:0] Pwait, // expected time to be waited until served
    output reg emptyFlag, fullFlag 
);

  /*  // Derived parameters
    localparam P_COUNT_MAX = (1 << (n+1)) - 1;
    localparam P_WAIT_MAX  = 3 * P_COUNT_MAX;
    localparam WTIME_WIDTH = $clog2(P_WAIT_MAX + 1) - 1;
    */
    
    // FSM state register
    reg [1:0] state, next_state;
    
    // Synchronizers for async inputs (prevents metastability)
    reg phcOne_sync1, phcOne_sync2;
    reg phcTwo_sync1, phcTwo_sync2;
    
    // Edge detection
    reg phcOne_prev, phcTwo_prev;
    wire phcOne_negedge = phcOne_prev && !phcOne_sync2;
    wire phcTwo_negedge = phcTwo_prev && !phcTwo_sync2;
    
    // Intermediate calculation variable
    reg [n+3:0] numerator;     // Sized for 3*(Pcount+Tcount-1)
    
    // Synchronize async inputs
    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            phcOne_sync1 <= 1'b1;
            phcOne_sync2 <= 1'b1;
            phcTwo_sync1 <= 1'b1;
            phcTwo_sync2 <= 1'b1;
            phcOne_prev <= 1'b1;
            phcTwo_prev <= 1'b1;
        end else begin
            phcOne_sync1 <= phcOne;
            phcOne_sync2 <= phcOne_sync1;
            phcTwo_sync1 <= phcTwo;
            phcTwo_sync2 <= phcTwo_sync1;
            phcOne_prev <= phcOne_sync2;
            phcTwo_prev <= phcTwo_sync2;
        end
    end
    
    // FSM: Next state logic
    always @(*) begin
        if (phcOne_negedge)
            next_state = coming;
        else if (phcTwo_negedge)
            next_state = leaving;
        else
            next_state = idle;
    end
    
    // FSM: State register
    always @(posedge clock or negedge reset) begin
        if (!reset)
            state <= idle;
        else
            state <= next_state;
    end
    
    // FSM: Output logic and counter control
    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            Pcount <= 0;
            fullFlag <= 0;
            emptyFlag <= 1;
        end else begin
            case(state) 
                idle: begin
                    fullFlag <= (Pcount == P_COUNT_MAX);
                    emptyFlag <= (Pcount == 0);
                end
                
                coming: begin
                    if (Pcount < P_COUNT_MAX) begin
                        Pcount <= Pcount + 1;
                        emptyFlag <= 0;
                        fullFlag <= (Pcount + 1 == P_COUNT_MAX);
                    end
                end
                
                leaving: begin
                    if (Pcount > 0) begin
                        Pcount <= Pcount - 1;
                        fullFlag <= 0;
                        emptyFlag <= (Pcount - 1 == 0);
                    end
                end
                
                default: begin
                    fullFlag <= (Pcount == P_COUNT_MAX);
                    emptyFlag <= (Pcount == 0);
                end
            endcase
        end
    end
    
    // Wait time calculation
    always @(posedge clock or negedge reset) begin
        if (!reset || emptyFlag) begin
            Pwait <= 0;
        end else begin
            numerator = 3 * (Pcount + Tcount - 1);
            case(Tcount)
                2'd1: Pwait <= numerator;
                2'd2: Pwait <= numerator >> 1;
                2'd3: Pwait <= (numerator * 2'd1) / 2'd3;  // More accurate division
                default: Pwait <= numerator;
            endcase
        end
    end

endmodule
