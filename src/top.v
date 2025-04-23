`include "src/pwm.v"

module top (
    input CLK,
    output LED_B
);
    reg [23:0] value = 24'd0;
    reg led_on;
    assign LED_B = ~led_on;

    pwm pwm_i (.clk(CLK), .value(value[23:18]), .out(led_on));

    always @(posedge CLK) begin
        value <= value + 24'd1;
    end
endmodule
