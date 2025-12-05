module ALU(
    input [1:0] A, 
    input [1:0] B, 
    input [2:0] Control, 
    input clock,
    output reg [3:0] Output
);

always @(posedge clock) begin

	case(Control)
		3'b000: begin // AND
		Output <= A & B;// take first two bits in the pin assignment for the first two lids
		end
		
		3'b001: begin // or
		Output <= A | B;
		end
		
		3'b010: begin // SUM
		Output <= A + B;
		end
		
		3'b011: begin // SUB
		Output <= A - B;
		end
		
		3'b100: begin // MUL
		Output <= A * B;
		end
		
		3'b101: begin // output-> 4'd10 (Draw the bigger NUM on the seven segment )
		if(A>B) Output<=4'hA;
		else if (A<B) Output<=4'hB;
		else Output<=4'hE;
		end
		
		3'b110: begin // output-> (Draw the smaller NUM on the seven segment)
		if(A<B) Output<=4'hA;
		else if (A>B) Output<=4'hB;
		else Output<=4'hE;
		end
		
		3'b111: begin // output-> one bit boolean (Draw = on the seven segment if true)
		if(A>B) Output<=4'h0;
		else if (A<B) Output<=4'h0;
		else Output<=4'hE;
		end
		
		default: Output <= 4'h0;
		
		endcase
		

end

endmodule