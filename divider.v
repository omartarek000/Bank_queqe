module divider #(
    parameter COUNT_MAX = 25_000_000  // Default for 1Hz from 50MHz
)(
    input FPGA_clk,
    input reset,
    output reg OneHzClk
);

reg [24:0] count;

always@(posedge FPGA_clk or posedge reset) begin

    if(reset) begin 
        count <= 0;
        OneHzClk<=0;
    end 
    else begin
        if(count < COUNT_MAX) begin
            count <= count + 1;
        end 
        else begin
            count <= 0;
            OneHzClk <= ~OneHzClk;
        end 
    end

end 

endmodule
