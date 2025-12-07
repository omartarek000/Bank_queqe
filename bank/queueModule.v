module queue #(                 
    parameter n = 3,
    parameter P_COUNT_MAX = (1 << (n+1)) - 1, 
    parameter P_WAIT_MAX  = 3 * P_COUNT_MAX,  
    parameter WTIME_WIDTH = $clog2(P_WAIT_MAX + 1) 
)(
    input wire reset,             
    input wire phcOne, phcTwo,    
    input wire [1:0] Tcount,      
    input wire clock,             
    output reg [n:0] Pcount,
    output reg [WTIME_WIDTH:0] Pwait,
    output reg emptyFlag, fullFlag    
);

    localparam IDLE    = 2'b00;
    localparam COMING  = 2'b01;
    localparam LEAVING = 2'b10;
    
    reg [1:0] state;

    reg phcOne_safe, phcOne_prev;
    reg phcTwo_safe, phcTwo_prev;

    wire one_fall = (!phcOne_safe && phcOne_prev);
    wire two_fall = (!phcTwo_safe && phcTwo_prev);

    wire [n+3:0] base_wait;
    //assign base_wait = (Pcount + Tcount > 0) ? (Pcount + Tcount - 1) : 0;
	 assign base_wait = (Tcount == 0) ? 0 : 
                   ((Pcount + Tcount > 0) ? (Pcount + Tcount - 1) : 0);
	// if(Tcount ==0 ) assign base_wait =0;
	// else if(Pcount + Tcount > 0) assign base_wait = (Pcount + Tcount - 1);
	// else assign base_wait = 0;

    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            state       <= IDLE;
            Pcount      <= 0;
            fullFlag    <= 0;
            emptyFlag   <= 1;
            
            phcOne_safe <= 1'b1; 
            phcOne_prev <= 1'b1;
            phcTwo_safe <= 1'b1; 
            phcTwo_prev <= 1'b1;
            
            Pwait       <= 0;
        end else begin
            phcOne_safe <= phcOne; 
            phcTwo_safe <= phcTwo;
            
            phcOne_prev <= phcOne_safe;
            phcTwo_prev <= phcTwo_safe;

            fullFlag  <= (Pcount == P_COUNT_MAX);
            emptyFlag <= (Pcount == 0);

            case (state)
                IDLE: begin
                    if (one_fall && (Pcount < P_COUNT_MAX)) begin
                        state <= COMING;
                    end 
                    else if (two_fall && (Pcount > 0)) begin
                        state <= LEAVING;
                    end
                end

                COMING: begin
                    Pcount <= Pcount + 1;
                    state  <= IDLE;
                end

                LEAVING: begin
                    Pcount <= Pcount - 1;
                    state  <= IDLE; 
                end
                
                default: state <= IDLE;
            endcase

            if (Pcount == 0) begin
                Pwait <= 0;
            end else begin
                case(Tcount)
                    2'd1: Pwait <= 3 * base_wait;
                    2'd2: Pwait <= (3 * base_wait) >> 1; 
                    2'd3: Pwait <= base_wait;            
                    default: Pwait <= 3 * base_wait;
                endcase
            end
        end
    end

endmodule