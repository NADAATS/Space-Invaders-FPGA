`timescale 1ns / 1ps

module game_text(
    input  wire [1:0] state,
    input  wire [9:0] p_x,
    input  wire [9:0] p_y,
    output reg        init_on,
    output reg        gameover_on
);

    localparam INIT      = 2'b00;
    localparam GAME_OVER = 2'b10;

    localparam X0 = 180;
    localparam Y0 = 180;

    always @(*) begin
        init_on = 1'b0;
        gameover_on = 1'b0;

        if (state == INIT) begin
            // I
            if ((p_x >= X0     && p_x < X0+8)  && (p_y >= Y0 && p_y < Y0+40)) init_on = 1'b1;
            // N
            if ((p_x >= X0+20  && p_x < X0+28) && (p_y >= Y0 && p_y < Y0+40)) init_on = 1'b1;
            if ((p_x >= X0+40  && p_x < X0+48) && (p_y >= Y0 && p_y < Y0+40)) init_on = 1'b1;
            if ((p_x - (X0+20)) == (p_y - Y0) && p_x < X0+48 && p_y < Y0+40) init_on = 1'b1;
            // I
            if ((p_x >= X0+60  && p_x < X0+68) && (p_y >= Y0 && p_y < Y0+40)) init_on = 1'b1;
            // T
            if ((p_x >= X0+80  && p_x < X0+104) && (p_y >= Y0 && p_y < Y0+8)) init_on = 1'b1;
            if ((p_x >= X0+90  && p_x < X0+98)  && (p_y >= Y0 && p_y < Y0+40)) init_on = 1'b1;
        end

        if (state == GAME_OVER) begin
            // simple big GAME OVER blocks
            if ((p_x >= 150 && p_x < 490) && (p_y >= 150 && p_y < 230))
                gameover_on = 1'b1;
            if ((p_x >= 170 && p_x < 470) && (p_y >= 170 && p_y < 210))
                gameover_on = 1'b0;

            // middle bar to make it look like text-ish banner
            if ((p_x >= 180 && p_x < 460) && (p_y >= 186 && p_y < 194))
                gameover_on = 1'b1;
        end
    end

endmodule