module top_fifox5x16 (
    input clk,
    input rst,
    input signed [16*14-1:0] input_pixels,
    input [11:0] full_window_size,
    input wr_en,
    input stride,
    input [6:0] row_size,
    input EX_Window_Done,
    input Zero_Buffreing,
    output reg data_valid,
    output wire depth_window_done,
    output wire [(14*25*16)-1:0] output_window
);

    reg current_bank;

    wire data_valid_0, data_valid_1;
    wire depth_done_0, depth_done_1;
    wire [(14*25*16)-1:0] out_win_0, out_win_1;

    // Toggle buffer when current bank finishes
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_bank <= 0;
        end else if ((current_bank == 0 && depth_done_0) || (current_bank == 1 && depth_done_1)) begin
            current_bank <= ~current_bank;
        end
    end

    // Instance 0
    fifox5x16 fifo_bank_0 (
        .clk(clk),
        .rst(rst),
        .input_pixels(input_pixels),
        .stride(stride),
        .EX_Window_Done(EX_Window_Done),
        .Zero_Buffreing(Zero_Buffreing),
        .row_size(row_size),
        .full_window_size(full_window_size),
        .wr_en(wr_en && (current_bank == 0)),
        .data_valid(data_valid_0),
        .depth_window_done(depth_done_0),
        .output_window(out_win_0)
    );

    // Instance 1
    fifox5x16 fifo_bank_1 (
        .clk(clk),
        .rst(rst),
        .input_pixels(input_pixels),
        .stride(stride),
        .EX_Window_Done(EX_Window_Done),
        .Zero_Buffreing(Zero_Buffreing),
        .row_size(row_size),
        .full_window_size(full_window_size),
        .wr_en(wr_en && (current_bank == 1)),
        .data_valid(data_valid_1),
        .depth_window_done(depth_done_1),
        .output_window(out_win_1)
    );

    // Output muxing
    assign output_window = (current_bank == 0) ? out_win_0 : out_win_1;
    assign depth_window_done = (current_bank == 0) ? depth_done_0 : depth_done_1;

    // Data valid logic
    always @(*) begin
        data_valid = (current_bank == 0) ? data_valid_0 : data_valid_1;
    end

endmodule
