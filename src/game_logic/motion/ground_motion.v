`timescale 1ns / 1ps

// ============================================================
// Dino Ground Motion
// 功能：维护两段循环地面，负责地面横向滚动。
// 说明：
//   1. ground_x0 对应 0 号地面，显示为无凹凸地面。
//   2. ground_x1 对应 1 号地面，显示为有凹凸地面。
//   3. 两段地面宽度均为 1200 * 0.75 = 900 像素。
//   4. 地面 Y 坐标固定为 360，不在本模块中输出。
// ============================================================

module ground_motion(
    input  wire              clk,
    input  wire              rst,
    input  wire              frame_end,
    input  wire [1:0]        game_state,
    input  wire              game_start,
    input  wire [4:0]        speed_px,

    output reg signed [10:0] ground_x0,
    output reg signed [10:0] ground_x1
);

    localparam S_PLAY = 2'b01;

    localparam signed [10:0] GROUND_W = 11'sd900;
    localparam signed [10:0] LEFT_LIM = -11'sd900;

    wire       is_play;
    wire signed [10:0] spd;

    assign is_play = (game_state == S_PLAY);
    assign spd = {6'd0, speed_px};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ground_x0 <= 11'sd0;
            ground_x1 <= GROUND_W;
        end else begin
            if (game_start) begin
                ground_x0 <= 11'sd0;
                ground_x1 <= GROUND_W;
            end else if (frame_end && is_play) begin
                if (speed_px != 5'd0) begin
                    // 0号地面移出左侧后，接到1号地面右边
                    if (ground_x0 <= LEFT_LIM + spd)
                        ground_x0 <= ground_x1 + GROUND_W - spd;
                    else
                        ground_x0 <= ground_x0 - spd;

                    // 1号地面移出左侧后，接到0号地面右边
                    if (ground_x1 <= LEFT_LIM + spd)
                        ground_x1 <= ground_x0 + GROUND_W - spd;
                    else
                        ground_x1 <= ground_x1 - spd;
                end
            end
        end
    end

endmodule