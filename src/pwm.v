module pwm (
    input clk,
    input [7:0] value,
    output reg out
);
    reg [11:0] counter = 0;  /* 12MHz / 2**12 ≈ 3kHz */

    always @(posedge clk) begin
        counter <= counter + 1;
        out <= (counter[11:4] < value);
    end
endmodule
