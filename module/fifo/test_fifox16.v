// module/fifo/test_fifox16.v
`timescale 1ns/1ps

module test_fifox16;

    // Parameters
    parameter bitsize = 14;
    parameter FRAC_BITS = 7;

    // DUT signals
    reg clk;
    reg rst;
    reg signed [16*bitsize-1:0] input_pixels;
    reg [11:0] full_window_size;
    reg wr_en;
    reg stride;
    reg [6:0] row_size;
    reg EX_Window_Done;
    reg Zero_Buffreing;
    wire data_valid;
    wire depth_window_done;
    wire [(bitsize*9*16)-1:0] output_window;
    integer file_output;
    // Instantiate DUT
    fifo_image_input dut (
        .clk(clk),
        .rst(rst),
        .input_pixels(input_pixels),
        .stride(stride),
        .EX_Window_Done(EX_Window_Done),
        .Zero_Buffreing(Zero_Buffreing),
        .full_window_size(full_window_size),
        .wr_en(wr_en),
        .data_valid(data_valid),
        .depth_window_done(depth_window_done),
        .output_window(output_window),
        .row_size(row_size)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz

    // Test sequence
    integer i, j;
    initial begin
        // Initialize
        rst = 1;
        wr_en = 0;
        stride = 0;
        EX_Window_Done = 0;
        Zero_Buffreing = 0;
        row_size = 112;
        full_window_size = 56*56; // 56x56 window size

        input_pixels = 0;

        // Apply reset
        @(negedge clk);
        rst = 0;
        @(negedge clk);
        rst = 1;
        input_pixels = 0;
        wr_en = 1;
        Zero_Buffreing = 0;
        EX_Window_Done = 0;
        stride = 1;
        row_size=112;
        full_window_size=56*56;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
    end
integer count;
        initial begin
        // Open output file
        count = 0;
        file_output=$fopen("outputrpixel.txt","w");
        // $fwrite(file,"%b",sum_output);
        // $fdisplay(file, "");
        //while (2) begin
            @(posedge data_valid);
            repeat(600)begin
                @(negedge clk);
                $fwrite(file_output," %b ",output_window [13: 0] );
                $fwrite(file_output," %b ", output_window [27:14] );
                $fwrite(file_output," %b ", output_window [41:28] );
                $fdisplay(file_output, "");
                $fwrite(file_output," %b ", output_window  [55:42] );
                $fwrite(file_output," %b ", output_window  [69:56] );
                $fwrite(file_output," %b ", output_window [83:70] );
                $fdisplay(file_output, "");
                $fwrite(file_output," %b ", output_window [97:84] );
                $fwrite(file_output," %b ", output_window [111:98] );
                $fwrite(file_output," %b ", output_window [125:112] );
                $fdisplay(file_output, "");
                $fwrite(file_output,"data valid: %b  ", data_valid);
                $fwrite(file_output,"skip row: %d  ", dut.skip_row);
                $fwrite(file_output,"count: %d  ", count);
                // $fwrite(file_output,"count_top: %d  ", dut.counter);
                // $fwrite(file_output,"count_segment: %d  ", dut.fifo_segments[0].u_fifo3x3.count);
                $fdisplay(file_output, "");
                count= count + 1;
            end
        //end
        $fclose(file_output);
        $stop();
    end
endmodule