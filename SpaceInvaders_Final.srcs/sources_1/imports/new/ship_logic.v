`timescale 1ns / 1ps

module ship_logic(
    input  wire       clk,
    input  wire       enable,
    input  wire       btnL,
    input  wire       btnR,
    input  wire [9:0] p_x,
    input  wire [9:0] p_y,
    output reg        pixel_on_ship,
    output wire [9:0] ship_x_out
);

    localparam SHIP_Y = 10'd440;
    localparam SHIP_W = 10'd16;
    localparam SHIP_H = 10'd8;
    localparam X_MIN  = 10'd2;
    localparam X_MAX  = 10'd622; // 640 - 16 - 2

    reg [9:0] ship_x = 10'd312;

    reg [19:0] move_cnt = 20'd0;
    wire move_tick;

    assign move_tick = (move_cnt == 20'd200000);

    always @(posedge clk) begin
        if (!enable)
            move_cnt <= 20'd0;
        else if (move_tick)
            move_cnt <= 20'd0;
        else
            move_cnt <= move_cnt + 20'd1;
    end

    always @(posedge clk) begin
        if (!enable) begin
            ship_x <= 10'd312;
        end
        else if (move_tick) begin
            if (btnL && !btnR) begin
                if (ship_x > X_MIN + 10'd3)
                    ship_x <= ship_x - 10'd4;
                else
                    ship_x <= X_MIN;
            end
            else if (btnR && !btnL) begin
                if (ship_x < X_MAX - 10'd3)
                    ship_x <= ship_x + 10'd4;
                else
                    ship_x <= X_MAX;
            end
        end
    end

    always @(*) begin
        pixel_on_ship = 1'b0;

        if ((p_y >= SHIP_Y) && (p_y < SHIP_Y + SHIP_H) &&
            (p_x >= ship_x) && (p_x < ship_x + SHIP_W)) begin

            case (p_y - SHIP_Y)
                0: pixel_on_ship = (p_x >= ship_x + 10'd6  && p_x < ship_x + 10'd10);
                1: pixel_on_ship = (p_x >= ship_x + 10'd4  && p_x < ship_x + 10'd12);
                2: pixel_on_ship = (p_x >= ship_x + 10'd2  && p_x < ship_x + 10'd14);
                3: pixel_on_ship = (p_x >= ship_x         && p_x < ship_x + 10'd16);
                4: pixel_on_ship = (p_x >= ship_x         && p_x < ship_x + 10'd16);
                5: pixel_on_ship = (p_x >= ship_x + 10'd4  && p_x < ship_x + 10'd12);
                6: pixel_on_ship = ((p_x >= ship_x + 10'd3 && p_x < ship_x + 10'd6) ||
                                    (p_x >= ship_x + 10'd10 && p_x < ship_x + 10'd13));
                default: pixel_on_ship = 1'b0;
            endcase
        end
    end

    assign ship_x_out = ship_x;

endmodule