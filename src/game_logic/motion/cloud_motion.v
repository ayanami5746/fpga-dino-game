`timescale 1ns / 1ps

// ============================================================
// Dino Cloud Motion
// 功能：维护 3 个云朵槽位，负责生成、左移和移出清空。
// 说明：
//   1. 云朵属于背景元素，速度约为 speed_px / 2。
//   2. 最低速度为 1 px/frame，避免速度过小时完全不动。
//   3. cloud_y_new 来自随机生成系统。
// ============================================================

module cloud_motion(
    input  wire       clk,
    input  wire       rst,
    input  wire       frame_end,
    input  wire [1:0] game_state,
    input  wire       game_start,
    input  wire [4:0] speed_px,
    input  wire       cloud_new,
    input  wire [8:0] cloud_y_new,

    output reg  [2:0] cloud_valid,
    output reg  [9:0] cloud_x0,
    output reg  [9:0] cloud_x1,
    output reg  [9:0] cloud_x2,
    output reg  [8:0] cloud_y0,
    output reg  [8:0] cloud_y1,
    output reg  [8:0] cloud_y2,
    output wire       cloud_ready
);

    localparam S_PLAY = 2'b01;
    localparam [9:0] NEW_X = 10'd700;

    wire       is_play;
    wire [9:0] cloud_spd;

    assign is_play = (game_state == S_PLAY);
    assign cloud_spd = (speed_px <= 5'd2) ? 10'd1 : {6'd0, speed_px[4:1]};
    assign cloud_ready = ~(&cloud_valid);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cloud_valid <= 3'b000;
            cloud_x0 <= 10'd0;
            cloud_x1 <= 10'd0;
            cloud_x2 <= 10'd0;
            cloud_y0 <= 9'd0;
            cloud_y1 <= 9'd0;
            cloud_y2 <= 9'd0;
        end else begin
            if (game_start) begin
                cloud_valid <= 3'b000;
                cloud_x0 <= 10'd0;
                cloud_x1 <= 10'd0;
                cloud_x2 <= 10'd0;
                cloud_y0 <= 9'd0;
                cloud_y1 <= 9'd0;
                cloud_y2 <= 9'd0;
            end else if (frame_end && is_play) begin
                if (cloud_valid[0]) begin
                    if (cloud_x0 > cloud_spd)
                        cloud_x0 <= cloud_x0 - cloud_spd;
                    else begin
                        cloud_valid[0] <= 1'b0;
                        cloud_x0 <= 10'd0;
                        cloud_y0 <= 9'd0;
                    end
                end

                if (cloud_valid[1]) begin
                    if (cloud_x1 > cloud_spd)
                        cloud_x1 <= cloud_x1 - cloud_spd;
                    else begin
                        cloud_valid[1] <= 1'b0;
                        cloud_x1 <= 10'd0;
                        cloud_y1 <= 9'd0;
                    end
                end

                if (cloud_valid[2]) begin
                    if (cloud_x2 > cloud_spd)
                        cloud_x2 <= cloud_x2 - cloud_spd;
                    else begin
                        cloud_valid[2] <= 1'b0;
                        cloud_x2 <= 10'd0;
                        cloud_y2 <= 9'd0;
                    end
                end

                if (cloud_new) begin
                    if (!cloud_valid[0]) begin
                        cloud_valid[0] <= 1'b1;
                        cloud_x0 <= NEW_X;
                        cloud_y0 <= cloud_y_new;
                    end else if (!cloud_valid[1]) begin
                        cloud_valid[1] <= 1'b1;
                        cloud_x1 <= NEW_X;
                        cloud_y1 <= cloud_y_new;
                    end else if (!cloud_valid[2]) begin
                        cloud_valid[2] <= 1'b1;
                        cloud_x2 <= NEW_X;
                        cloud_y2 <= cloud_y_new;
                    end
                end
            end
        end
    end

endmodule