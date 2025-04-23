`timescale 1us/10ns

`include "src/pwm.v"

module pwm_tb ();
    reg clk = 1'b0;
    reg out;
    reg [7:0] value = 8'd127;

    always begin
        #0.04167 clk = ~clk; /* 12MHz */
    end

    pwm pwm_i (.clk(clk), .value(value), .out(out));

    initial begin
        $dumpfile("pwm.vcd");
        $dumpvars(1, pwm_tb);
        #10000 $finish;
    end
endmodule
