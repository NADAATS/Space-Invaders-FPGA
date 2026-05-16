`timescale 1ns / 1ps

module top_game(
    input wire clk,
    input wire btnL,
    input wire btnR,
    input wire btnC,
    output wire Hsync,
    output wire Vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

    localparam INIT      = 2'b00;
    localparam PLAY      = 2'b01;
    localparam GAME_OVER = 2'b10;

    wire clk_25MHz;
    wire video_on;
    wire [9:0] p_x, p_y;

    wire ship_on;
    wire alien_on;
    wire bullet_on;
    wire [9:0] ship_x;

    wire score_digit_on;
    wire level_digit_on;
    wire lives_digit_on;

    wire [9:0] bullet_x;
    wire [9:0] bullet_y;
    wire bullet_active;
    wire bullet_kill;

    wire alien_bullet_on;
    wire [9:0] alien_bullet_x;
    wire [9:0] alien_bullet_y;
    wire alien_bullet_active;
    wire alien_bullet_kill;

    wire [9:0] alien_shoot_x;
    wire [9:0] alien_shoot_y;

    wire alien_hit;
    wire alien_reached_bottom;
    wire wave_cleared;
    wire hit;
    wire player_hit;

    wire init_text_on;
    wire gameover_text_on;

    reg [1:0] state = INIT;
    reg [7:0] score = 8'd0;
    reg [3:0] level = 4'd1;
    reg [3:0] lives = 4'd3;
    reg player_hit_reg = 1'b0;
    reg wave_reset = 1'b0;

    wire hud_on;
    wire star_on;

    assign hit = alien_hit;
    assign bullet_kill = hit;
    assign alien_bullet_kill = player_hit;

    assign player_hit =
        alien_bullet_active &&
        (alien_bullet_x + 10'd4 >= ship_x) &&
        (alien_bullet_x <= ship_x + 10'd16) &&
        (alien_bullet_y + 10'd12 >= 10'd440) &&
        (alien_bullet_y <= 10'd448);

    assign hud_on = video_on && (p_y < 10'd30);

    assign star_on = video_on &&
                     !hud_on &&
                     (((p_x[4:0] ^ p_y[4:0]) == 5'b10101) ||
                      ((p_x[5:2] + p_y[5:2]) == 8'd30));

    clk_wiz_0 instance_clk (
        .clk_in1(clk),
        .clk_out1(clk_25MHz)
    );

    vga_sync instance_vga (
        .clk(clk_25MHz),
        .hsync(Hsync),
        .vsync(Vsync),
        .video_on(video_on),
        .p_x(p_x),
        .p_y(p_y)
    );

    ship_logic instance_ship (
        .clk(clk_25MHz),
        .enable(state == PLAY),
        .btnL(btnL),
        .btnR(btnR),
        .p_x(p_x),
        .p_y(p_y),
        .pixel_on_ship(ship_on),
        .ship_x_out(ship_x)
    );

    extrater_grid instance_aliens (
        .clk(clk_25MHz),
        .game_reset(state == INIT),
        .wave_reset(wave_reset),
        .p_x(p_x),
        .p_y(p_y),
        .bullet_x(bullet_x),
        .bullet_y(bullet_y),
        .bullet_active(bullet_active),
        .pixel_on_aliens(alien_on),
        .alien_hit(alien_hit),
        .alien_shoot_x(alien_shoot_x),
        .alien_shoot_y(alien_shoot_y),
        .alien_reached_bottom(alien_reached_bottom),
        .wave_cleared(wave_cleared)
    );

    bullet_logic instance_bullet (
        .clk(clk_25MHz),
        .enable(state == PLAY),
        .btn_fire(btnC),
        .ship_x(ship_x),
        .p_x(p_x),
        .p_y(p_y),
        .bullet_kill(bullet_kill),
        .pixel_on_bullet(bullet_on),
        .bullet_x_out(bullet_x),
        .bullet_y_out(bullet_y),
        .bullet_active(bullet_active)
    );

    alien_bullet_logic instance_alien_bullet (
        .clk(clk_25MHz),
        .enable(state == PLAY),
        .bullet_kill(alien_bullet_kill),
        .alien_x(alien_shoot_x),
        .alien_y(alien_shoot_y),
        .p_x(p_x),
        .p_y(p_y),
        .pixel_on_alien_bullet(alien_bullet_on),
        .bullet_x_out(alien_bullet_x),
        .bullet_y_out(alien_bullet_y),
        .bullet_active(alien_bullet_active)
    );

    digit_7seg instance_score (
        .digit(score % 10),
        .p_x(p_x),
        .p_y(p_y),
        .x0(10'd20),
        .y0(10'd2),
        .pixel_on(score_digit_on)
    );

    digit_7seg instance_level (
        .digit(level),
        .p_x(p_x),
        .p_y(p_y),
        .x0(10'd540),
        .y0(10'd2),
        .pixel_on(level_digit_on)
    );

    digit_7seg instance_lives (
        .digit(lives),
        .p_x(p_x),
        .p_y(p_y),
        .x0(10'd280),
        .y0(10'd2),
        .pixel_on(lives_digit_on)
    );

    game_text instance_text (
        .state(state),
        .p_x(p_x),
        .p_y(p_y),
        .init_on(init_text_on),
        .gameover_on(gameover_text_on)
    );

    always @(posedge clk_25MHz) begin
        wave_reset <= 1'b0;

        case (state)
            INIT: begin
                score <= 8'd0;
                level <= 4'd1;
                lives <= 4'd3;
                player_hit_reg <= 1'b0;

                if (btnC)
                    state <= PLAY;
            end

            PLAY: begin
                if (hit)
                    score <= score + 8'd1;

                if (player_hit && !player_hit_reg) begin
                    player_hit_reg <= 1'b1;

                    if (lives > 4'd1)
                        lives <= lives - 4'd1;
                    else
                        state <= GAME_OVER;
                end else if (!player_hit) begin
                    player_hit_reg <= 1'b0;
                end

                if (wave_cleared) begin
                    level <= level + 4'd1;
                    wave_reset <= 1'b1;
                end

                if (alien_reached_bottom)
                    state <= GAME_OVER;
            end

            GAME_OVER: begin
                if (btnC)
                    state <= INIT;
            end

            default: begin
                state <= INIT;
            end
        endcase
    end

    assign vgaRed =
        (!video_on)          ? 4'h0 :
        (gameover_text_on)   ? 4'hF :
        (init_text_on)       ? 4'hF :
        (state == PLAY && score_digit_on) ? 4'hF :
        (state == PLAY && ship_on) ? 4'hF :
        (state == PLAY && bullet_on) ? 4'hF :
        (state == PLAY && alien_bullet_on) ? 4'hF :
                               4'h0;

    assign vgaGreen =
        (!video_on)          ? 4'h0 :
        (init_text_on)       ? 4'hF :
        (state == PLAY && level_digit_on) ? 4'hF :
        (state == PLAY && lives_digit_on) ? 4'hF :
        (state == PLAY && alien_on) ? 4'hF :
        (state == PLAY && bullet_on) ? 4'hF :
        (star_on)            ? 4'h1 :
                               4'h0;

    assign vgaBlue =
        (!video_on)          ? 4'h0 :
        (init_text_on)       ? 4'hF :
        (state == PLAY && level_digit_on) ? 4'hF :
        (state == PLAY && lives_digit_on) ? 4'hF :
        (state == PLAY && bullet_on) ? 4'hF :
        (star_on)            ? 4'h3 :
                               4'h1;

endmodule