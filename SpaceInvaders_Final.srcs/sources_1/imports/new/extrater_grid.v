`timescale 1ns / 1ps

module extrater_grid(
    input  wire       clk,
    input  wire       game_reset,
    input  wire       wave_reset,
    input  wire [9:0] p_x,
    input  wire [9:0] p_y,
    input  wire [9:0] bullet_x,
    input  wire [9:0] bullet_y,
    input  wire       bullet_active,
    output reg        pixel_on_aliens,
    output reg        alien_hit,
    output wire [9:0] alien_shoot_x,
    output wire [9:0] alien_shoot_y,
    output wire       alien_reached_bottom,
    output reg        wave_cleared
);

    localparam ROWS    = 4;
    localparam COLS    = 8;
    localparam ALIEN_W = 16;
    localparam ALIEN_H = 12;
    localparam GAP_X   = 12;
    localparam GAP_Y   = 10;
    localparam START_X = 80;
    localparam START_Y = 50;

    localparam GRID_W = COLS*ALIEN_W + (COLS-1)*GAP_X;
    localparam GRID_H = ROWS*ALIEN_H + (ROWS-1)*GAP_Y;

    // offset_x doit être signé pour pouvoir aller à gauche sans overflow
    reg signed [10:0] offset_x = 11'sd0;
    reg        [9:0]  offset_y = 10'd0;
    reg direction = 1'b0; // 0 = droite, 1 = gauche

    reg [20:0] move_counter = 21'd0;
    wire move_tick;

    reg alive [0:ROWS-1][0:COLS-1];

    integer row, col;
    integer alien_x, alien_y;
    integer lx, ly;
    integer shoot_row;
    reg found_shooter;
    reg [9:0] shoot_x_r;
    reg [9:0] shoot_y_r;
    reg any_alive;

    assign move_tick = (move_counter == 21'd800000);
    assign alien_shoot_x = shoot_x_r;
    assign alien_shoot_y = shoot_y_r;
    assign alien_reached_bottom = (START_Y + offset_y + GRID_H >= 10'd320);

    // --------------------------------------------------
    // Sprite alien 16x12
    // --------------------------------------------------
    function alien_shape;
        input [4:0] ax;
        input [4:0] ay;
        begin
            case (ay)
                0:  alien_shape = (ax >= 5 && ax <= 10);
                1:  alien_shape = (ax >= 4 && ax <= 11);
                2:  alien_shape = (ax >= 2 && ax <= 13);
                3:  alien_shape = (ax == 1 || ax == 3 || (ax >= 5 && ax <= 10) || ax == 12 || ax == 14);
                4:  alien_shape = (ax >= 1 && ax <= 14);
                5:  alien_shape = (ax == 0 || (ax >= 2 && ax <= 5) || (ax >= 10 && ax <= 13) || ax == 15);
                6:  alien_shape = (ax == 0 || (ax >= 2 && ax <= 13) || ax == 15);
                7:  alien_shape = (ax == 0 || ax == 4 || (ax >= 5 && ax <= 10) || ax == 11 || ax == 15);
                8:  alien_shape = (ax >= 0 && ax <= 15);
                9:  alien_shape = ((ax >= 1 && ax <= 3) || (ax >= 12 && ax <= 14));
                10: alien_shape = ((ax >= 2 && ax <= 4) || (ax >= 11 && ax <= 13));
                11: alien_shape = ((ax >= 3 && ax <= 5) || (ax >= 10 && ax <= 12));
                default: alien_shape = 1'b0;
            endcase
        end
    endfunction

    // --------------------------------------------------
    // Initialisation / reset / mouvement / collision
    // --------------------------------------------------
    always @(posedge clk) begin
        if (game_reset || wave_reset) begin
            offset_x <= 11'sd0;
            offset_y <= 10'd0;
            direction <= 1'b0;
            move_counter <= 21'd0;
            alien_hit <= 1'b0;

            for (row = 0; row < ROWS; row = row + 1)
                for (col = 0; col < COLS; col = col + 1)
                    alive[row][col] <= 1'b1;

        end else begin
            if (move_tick)
                move_counter <= 21'd0;
            else
                move_counter <= move_counter + 21'd1;

            // Mouvement global
            if (move_tick) begin
                if (!direction) begin
                    // vers la droite
                    if ((11'sd80 + offset_x + GRID_W + 11'sd4) >= 11'sd620) begin
                        direction <= 1'b1;
                        offset_y <= offset_y + 10'd20;
                    end else begin
                        offset_x <= offset_x + 11'sd4;
                    end
                end else begin
                    // vers la gauche
                    if ((11'sd80 + offset_x) <= 11'sd20) begin
                        direction <= 1'b0;
                        offset_y <= offset_y + 10'd20;
                    end else begin
                        offset_x <= offset_x - 11'sd4;
                    end
                end
            end

            alien_hit <= 1'b0;

            // Collision bullet joueur / alien
            if (bullet_active) begin
                for (row = 0; row < ROWS; row = row + 1) begin
                    for (col = 0; col < COLS; col = col + 1) begin
                        if (alive[row][col]) begin
                            alien_x = START_X + offset_x + col * (ALIEN_W + GAP_X);
                            alien_y = START_Y + offset_y + row * (ALIEN_H + GAP_Y);

                            if ((bullet_x + 10'd4 >= alien_x) &&
                                (bullet_x <= alien_x + ALIEN_W) &&
                                (bullet_y + 10'd12 >= alien_y) &&
                                (bullet_y <= alien_y + ALIEN_H)) begin
                                alive[row][col] <= 1'b0;
                                alien_hit <= 1'b1;
                            end
                        end
                    end
                end
            end
        end
    end

    // --------------------------------------------------
    // Dessin des aliens
    // --------------------------------------------------
    always @(*) begin
        pixel_on_aliens = 1'b0;

        for (row = 0; row < ROWS; row = row + 1) begin
            for (col = 0; col < COLS; col = col + 1) begin
                if (alive[row][col]) begin
                    alien_x = START_X + offset_x + col * (ALIEN_W + GAP_X);
                    alien_y = START_Y + offset_y + row * (ALIEN_H + GAP_Y);

                    if ((p_x >= alien_x) && (p_x < alien_x + ALIEN_W) &&
                        (p_y >= alien_y) && (p_y < alien_y + ALIEN_H)) begin
                        lx = p_x - alien_x;
                        ly = p_y - alien_y;

                        if (alien_shape(lx[4:0], ly[4:0]))
                            pixel_on_aliens = 1'b1;
                    end
                end
            end
        end
    end

    // --------------------------------------------------
    // Détection de fin de vague
    // --------------------------------------------------
    always @(*) begin
        any_alive = 1'b0;

        for (row = 0; row < ROWS; row = row + 1)
            for (col = 0; col < COLS; col = col + 1)
                if (alive[row][col])
                    any_alive = 1'b1;

        wave_cleared = !any_alive;
    end

    // --------------------------------------------------
    // Choix de l'alien tireur
    // priorité à la colonne 3, sinon premier vivant trouvé
    // --------------------------------------------------
    always @(*) begin
        found_shooter = 1'b0;
        shoot_x_r = START_X + offset_x;
        shoot_y_r = START_Y + offset_y;

        for (shoot_row = ROWS-1; shoot_row >= 0; shoot_row = shoot_row - 1) begin
            if (alive[shoot_row][3] && !found_shooter) begin
                shoot_x_r = START_X + offset_x + 3 * (ALIEN_W + GAP_X);
                shoot_y_r = START_Y + offset_y + shoot_row * (ALIEN_H + GAP_Y);
                found_shooter = 1'b1;
            end
        end

        if (!found_shooter) begin
            for (row = ROWS-1; row >= 0; row = row - 1) begin
                for (col = 0; col < COLS; col = col + 1) begin
                    if (alive[row][col] && !found_shooter) begin
                        shoot_x_r = START_X + offset_x + col * (ALIEN_W + GAP_X);
                        shoot_y_r = START_Y + offset_y + row * (ALIEN_H + GAP_Y);
                        found_shooter = 1'b1;
                    end
                end
            end
        end
    end

endmodule