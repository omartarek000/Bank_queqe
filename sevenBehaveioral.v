// sevenBehavioral.v
// Converts 4-bit BCD digit (0-9) to 7-segment display pattern (common cathode)
// Author:(Mahmoud)
// Designed for DE10-Lite (common cathode 7-seg: HEX0-HEX5)

module sevenBehavioral (
    input  [3:0] digit,   // BCD input: 0 to 9 (4-bit)
    output reg [6:0] seg  // 7-seg output: {a, b, c, d, e, f, g}
                          // Segment mapping: 
                          //       a
                          //     ?????
                          //   f ?   ? b
                          //     ? g ?
                          //     ?????
                          //   e ?   ? c
                          //     ?   ?
                          //     ?????
                          //       d
);

    // Common cathode: '1' = LED ON, '0' = OFF
    // Truth table for digits 0-9:
    // digit | a b c d e f g | seg[6:0] = {a,b,c,d,e,f,g}
    //   0   | 1 1 1 1 1 1 0 ? 7'b1111110
    //   1   | 0 1 1 0 0 0 0 ? 7'b0110000
    //   2   | 1 1 0 1 1 0 1 ? 7'b1101101
    //   3   | 1 1 1 1 0 0 1 ? 7'b1111001
    //   4   | 0 1 1 0 0 1 1 ? 7'b0110011
    //   5   | 1 0 1 1 0 1 1 ? 7'b1011011
    //   6   | 1 0 1 1 1 1 1 ? 7'b1011111
    //   7   | 1 1 1 0 0 0 0 ? 7'b1110000
    //   8   | 1 1 1 1 1 1 1 ? 7'b1111111
    //   9   | 1 1 1 1 0 1 1 ? 7'b1111011

    always @(*) begin
        case (digit)
            4'd0: seg = 7'b1111110;  // 0
            4'd1: seg = 7'b0110000;  // 1
            4'd2: seg = 7'b1101101;  // 2
            4'd3: seg = 7'b1111001;  // 3
            4'd4: seg = 7'b0110011;  // 4
            4'd5: seg = 7'b1011011;  // 5
            4'd6: seg = 7'b1011111;  // 6
            4'd7: seg = 7'b1110000;  // 7
            4'd8: seg = 7'b1111111;  // 8
            4'd9: seg = 7'b1111011;  // 9
            // Optional: handle invalid inputs (10-15)
            default: seg = 7'b0000000;  // blank (all off) ? safe for common cathode
            // Or: seg = 7'b0000001;  // '-' (only g on)
        endcase
    end

endmodule
