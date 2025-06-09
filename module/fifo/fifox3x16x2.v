module fifox3x16x2 #(
    parameter bitsize = 14,        // Total width of inputs
    parameter FRAC_BITS = 7,
    parameter window_size =3 // 3x3 window
)(
    input clk,
    input rst,
    input signed [16*bitsize-1:0] input_pixels,
    input [11:0] full_window_size,
    input wr_en,
    input stride,
    input [6:0] row_size,
    input EX_Window_Done,
    input Zero_Buffreing,
    output reg data_valid,
    output wire depth_window_done,
    output wire [(bitsize*25*16)-1:0] output_window
);

    // Ping-pong control
    reg current_bank;  // 0 or 1

    // Outputs from both FIFOs
    wire data_valid_0, data_valid_1;
    wire depth_done_0, depth_done_1;
    wire [(bitsize*25*16)-1:0] out_win_0, out_win_1;
    wire [(bitsize*25*16)-1:0] output_window_temp;

    // Control signal: switch after window done
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_bank <= 0;
        end else if ((current_bank == 0 && depth_done_0) || (current_bank == 1 && depth_done_1)) begin
            current_bank <= ~current_bank;
        end
    end

    // Instantiate FIFO 0
    fifo_image_input fifo_0 (
        .clk(clk),
        .rst(rst),
        .input_pixels(input_pixels),
        .stride(stride),
        .EX_Window_Done(EX_Window_Done),
        .Zero_Buffreing(Zero_Buffreing),
        .row_size(row_size),
        .full_window_size(full_window_size),
        .wr_en(wr_en && (current_bank == 0)),  // Enable only for active bank
        .data_valid(data_valid_0),
        .depth_window_done(depth_done_0),
        .output_window(out_win_0)
    );

    // Instantiate FIFO 1
    fifo_image_input fifo_1 (
        .clk(clk),
        .rst(rst),
        .input_pixels(input_pixels),
        .stride(stride),
        .EX_Window_Done(EX_Window_Done),
        .Zero_Buffreing(Zero_Buffreing),
        .row_size(row_size),
        .full_window_size(full_window_size),
        .wr_en(wr_en && (current_bank == 1)),  // Enable only for active bank
        .data_valid(data_valid_1),
        .depth_window_done(depth_done_1),
        .output_window(out_win_1)
    );

    // Output mux based on current bank
    assign output_window_temp = (current_bank == 0) ? out_win_0 : out_win_1;
    assign output_window = {output_window_temp};
    assign depth_window_done = (current_bank == 0) ? depth_done_0 : depth_done_1;

    // Data valid mux
    always @(*) begin
        data_valid = (current_bank == 0) ? data_valid_0 : data_valid_1;
    end

endmodule
