`timescale 1ns / 1ps

module bullet_logic(
    input  wire       clk,
    input  wire       enable,
    input  wire       btn_fire,
    input  wire [9:0] ship_x,
    input  wire [9:0] p_x,
    input  wire [9:0] p_y,
    input  wire       bullet_kill,

    output reg        pixel_on_bullet,
    output wire [9:0] bullet_x_out,
    output wire [9:0] bullet_y_out,
    output wire       bullet_active
);

    reg [9:0] b_x = 10'd0;
    reg [9:0] b_y = 10'd0;
    reg active = 1'b0;
    reg btn_fire_d = 1'b0;

    reg [18:0] move_cnt = 19'd0;
    wire move_tick;

    assign move_tick = (move_cnt == 19'd120000);

    always @(posedge clk) begin
        btn_fire_d <= btn_fire;

        if (!enable) begin
            active   <= 1'b0;
            b_x      <= 10'd0;
            b_y      <= 10'd0;
            move_cnt <= 19'd0;
        end else begin
            if (move_tick)
                move_cnt <= 19'd0;
            else
                move_cnt <= move_cnt + 19'd1;

            if (bullet_kill) begin
                active <= 1'b0;
            end else if (btn_fire && !btn_fire_d && !active) begin
                active <= 1'b1;
                b_x <= ship_x + 10'd6;
                b_y <= 10'd428;
            end else if (active && move_tick) begin
                if (b_y <= 10'd12)
                    active <= 1'b0;
                else
                    b_y <= b_y - 10'd3;
            end
        end
    end

    always @(*) begin
        if (active &&
            (p_x >= b_x) && (p_x < b_x + 10'd4) &&
            (p_y >= b_y) && (p_y < b_y + 10'd12))
            pixel_on_bullet = 1'b1;
        else
            pixel_on_bullet = 1'b0;
    end

    assign bullet_x_out  = b_x;
    assign bullet_y_out  = b_y;
    assign bullet_active = active;

endmodule