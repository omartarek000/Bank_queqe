`timescale 1ns / 1ps

module queue_tb;

    // =====================================================================
    // Signal Declarations (Using compatible reg/wire)
    // =====================================================================
    
    // Inputs must be declared as 'reg'
    reg clock;
    reg reset;
    
    reg phcOne;     
    reg phcTwo;
    reg [1:0] Tcount;       // 2 bits (0-3 tellers)

    // Outputs must be declared as 'wire'
    wire [3:0] Pcount;       // 4 bits (n+1)
    wire [5:0] Pwait;        // 6 bits 
    wire emptyFlag;
    wire fullFlag;

    // Clock Generation
    always #5 clock = ~clock;

    // =====================================================================
    // Instantiate Device Under Test (DUT)
    // =====================================================================
    queue #(
        .n(3) 
    ) DUT (
        .reset(reset),
        .phcOne(phcOne),
        .phcTwo(phcTwo),
        .Tcount(Tcount),
        .clock(clock),
        .Pcount(Pcount),
        .Pwait(Pwait),
        .emptyFlag(emptyFlag),
        .fullFlag(fullFlag)
    );

    // =====================================================================
    // Test Sequence
    // =====================================================================
    initial begin
        // ... (Test stimuli block)
        // Reset and initial conditions
        clock = 0;
        reset = 1;      
        phcOne = 1;     
        phcTwo = 1;
        Tcount = 2'd2;  
        
        $display("--- Start Test ---");
        
        #10 reset = 0; // Assert asynchronous reset
        #20 reset = 1; // De-assert reset 
        
        // Count Up
        $display("--- Phase 2: Counting Up ---");
        repeat (5) begin
            @(posedge clock) phcOne = 0;
            @(posedge clock) phcOne = 1;
            #1;
        end
        $display("Pcount: %0d | Empty: %0d | Full: %0d", Pcount, emptyFlag, fullFlag); 

        // Wait Time Test
        #10 Tcount = 2'd2; @(posedge clock);
        $display("Pwait @ T=2: %0d (Expected: 9)", Pwait); 

        #10 Tcount = 2'd3; @(posedge clock);
        $display("Pwait @ T=3: %0d (Expected: 7)", Pwait); 
        
        // Max Count Test
        $display("--- Phase 4: Reaching Max ---");
        repeat (10) begin
            @(posedge clock) phcOne = 0;
            @(posedge clock) phcOne = 1;
            #1;
        end
        $display("Pcount Max: %0d | Full: %0d", Pcount, fullFlag); 

        // Count Down
        $display("--- Phase 5: Counting Down ---");
        repeat (14) begin
            @(posedge clock) phcTwo = 0;
            @(posedge clock) phcTwo = 1;
            #1;
        end
        $display("Pcount Low: %0d | Empty: %0d", Pcount, emptyFlag); 

        // Final Exit
        @(posedge clock) phcTwo = 0;
        @(posedge clock) phcTwo = 1;
        #10;
        $display("Pcount Zero: %0d | Empty: %0d", Pcount, emptyFlag); 
        
        $display("--- Test Complete ---");
        $stop;
    end // End of initial block

endmodule // End of module