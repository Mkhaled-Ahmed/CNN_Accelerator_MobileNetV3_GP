module fifo_seg_tb;
    parameter bitsize = 14;        // Total width of inputs
    reg  clk;
    reg  rst;
    reg signed[bitsize:0] input_pixel;
    reg wr_en;
    wire data_valid;
    wire signed[(bitsize*3*3)-1:0] output_window;
    integer file_input;
    integer file_output;
    integer scan_file;
    always begin
        #5 clk = ~clk;
    end

    fifo_segment fifo_segment_inst(clk,
        rst,
        input_pixel,
        wr_en,
        data_valid,
        output_window
        );


    initial begin
        @(posedge data_valid);
        repeat(3)begin
            @(negedge clk);
            $display( output_window [13: 0] );
            $display( output_window [27:14] );
            $display( output_window [41:28] );
            $display( output_window [55:42] );
            $display( output_window [69:56] );
            $display( output_window [83:70] );
            $display( output_window [97:84] );
            $display( output_window [111:98] );
            $display( output_window [125:112] );
        end
        $fclose(file_input);
        $stop();
    end



    initial begin
                //file_output=$fopen("input.txt","r");
        clk=0;
        rst=0;
        @(negedge clk);
        rst=1;
        wr_en=1;
        file_input = $fopen("input.txt", "r");
        //@(negedge clk);
        while(1)begin
                scan_file = $fscanf(file_input, "%d\n", input_pixel);
                @(negedge clk);
            end
        end
endmodule