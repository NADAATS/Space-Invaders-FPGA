`timescale 1ns / 1ps

module vga_sync(
    input  wire clk,
    output reg  hsync,
    output reg  vsync,
    output wire [9:0] p_x,
    output wire [9:0] p_y,
    output wire video_on
);

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk) begin
        if (h_count == 799) begin
            h_count <= 0;
            if (v_count == 524)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end

    assign video_on = (h_count < 640) && (v_count < 480);
    assign p_x = h_count;
    assign p_y = v_count;

    always @(posedge clk) begin
        hsync <= ~((h_count >= 656) && (h_count <= 751));
        vsync <= ~((v_count >= 490) && (v_count <= 491));
    end

endmodule