module tellers_to_digit(
input t1, t2, t3,
output reg [1:0] digit
); 

always@(*) begin
 digit = t1 + t2 + t3 ;
end
endmodule