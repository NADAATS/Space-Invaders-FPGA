`timescale 1ns / 1ps

module digit_7seg(
    input  wire [9:0] p_x,
    input  wire [9:0] p_y,
    input  wire [3:0] digit,
    input  wire [9:0] x0,
    input  wire [9:0] y0,
    output reg        pixel_on
);

    wire seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;

    assign seg_a = (digit != 4'd1 && digit != 4'd4);
    assign seg_b = (digit != 4'd5 && digit != 4'd6);
    assign seg_c = (digit != 4'd2);
    assign seg_d = (digit != 4'd1 && digit != 4'd4 && digit != 4'd7);
    assign seg_e = (digit == 4'd0 || digit == 4'd2 || digit == 4'd6 || digit == 4'd8);
    assign seg_f = (digit != 4'd1 && digit != 4'd2 && digit != 4'd3 && digit != 4'd7);
    assign seg_g = (digit != 4'd0 && digit != 4'd1 && digit != 4'd7);

    always @(*) begin
        pixel_on = 1'b0;

        if (seg_a && (p_x >= x0+3  && p_x < x0+13) && (p_y >= y0    && p_y < y0+3))  pixel_on = 1'b1;
        if (seg_b && (p_x >= x0+13 && p_x < x0+16) && (p_y >= y0+3  && p_y < y0+11)) pixel_on = 1'b1;
        if (seg_c && (p_x >= x0+13 && p_x < x0+16) && (p_y >= y0+13 && p_y < y0+21)) pixel_on = 1'b1;
        if (seg_d && (p_x >= x0+3  && p_x < x0+13) && (p_y >= y0+21 && p_y < y0+24)) pixel_on = 1'b1;
        if (seg_e && (p_x >= x0    && p_x < x0+3 ) && (p_y >= y0+13 && p_y < y0+21)) pixel_on = 1'b1;
        if (seg_f && (p_x >= x0    && p_x < x0+3 ) && (p_y >= y0+3  && p_y < y0+11)) pixel_on = 1'b1;
        if (seg_g && (p_x >= x0+3  && p_x < x0+13) && (p_y >= y0+10 && p_y < y0+13)) pixel_on = 1'b1;
    end

endmodule