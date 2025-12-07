module divider #(
    parameter COUNT_MAX = 25_000_000  // Default for 1Hz from 50MHz
)(
    input clk,
    input reset,
    output reg clock
);

reg [24:0] count;

always@(posedge clk or negedge reset) begin
    if(!reset) begin 
        count <= 0;
        clock <= 0;
    end 
    else begin
        if(count < COUNT_MAX) begin
            count <= count + 1;
        end 
        else begin
            count <= 0;
            clock <= ~clock;
        end 
    end
end 

endmodule