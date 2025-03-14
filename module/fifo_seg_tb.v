module fifo_seg_tb;
    parameter bitsize = 14;        // Total width of inputs
    reg  clk;
    reg  rst;
    reg signed[bitsize-1:0] input_pixelR;
    reg signed[bitsize-1:0] input_pixelG;
    reg signed[bitsize-1:0] input_pixelB;
    reg wr_en;
    wire data_valid;
    wire signed[(bitsize*3*3)-1:0] output_windowR;
    wire signed[(bitsize*3*3)-1:0] output_windowG;
    wire signed[(bitsize*3*3)-1:0] output_windowB;
    integer file_inputR;
    integer file_inputG;
    integer file_inputB;
    integer file_output;
    integer scan_file;
    always begin
        #5 clk = ~clk;
    end

fifo_image_input u_fifo_image_input(
    .clk(clk),
    .rst(rst),
    .input_pixelR(input_pixelR),
    .input_pixelG(input_pixelG),
    .input_pixelB(input_pixelB),
    .wr_en(wr_en),
    .data_valid(data_valid),
    .output_windowR(output_windowR),
    .output_windowG(output_windowG),
    .output_windowB(output_windowB)
);


    initial begin
        file_output=$fopen("output.txt","w");
        // $fwrite(file,"%b",sum_output);
        // $fdisplay(file, "");
        //while (2) begin
            @(posedge data_valid);
            repeat(600)begin
                @(negedge clk);
                $fwrite(file_output," %d ",output_windowR [13: 0] );
                $fwrite(file_output," %d ", output_windowR [27:14] );
                $fwrite(file_output," %d ", output_windowR [41:28] );
                $fdisplay(file_output, "");
                $fwrite(file_output," %d ", output_windowR [55:42] );
                $fwrite(file_output," %d ", output_windowR [69:56] );
                $fwrite(file_output," %d ", output_windowR [83:70] );
                $fdisplay(file_output, "");
                $fwrite(file_output," %d ", output_windowR [97:84] );
                $fwrite(file_output," %d ", output_windowR [111:98] );
                $fwrite(file_output," %d ", output_windowR [125:112] );
                $fdisplay(file_output, "");
                $fwrite(file_output,"data valid: %d ", data_valid);
                $fwrite(file_output,"skip row: %d ", u_fifo_image_input.skip_row);
                $fdisplay(file_output, "");
            end
        //end
        $fclose(file_output);
        $fclose(file_inputR);
        $fclose(file_inputG);
        $fclose(file_inputB);
        $stop();
    end



    initial begin
                //file_output=$fopen("input.txt","r");
        clk=0;
        rst=0;
        @(negedge clk);
        rst=1;
        wr_en=1;
        file_inputR = $fopen("inputR.txt", "r");
        file_inputG = $fopen("inputG.txt", "r");
        file_inputB = $fopen("inputB.txt", "r");
        //@(negedge clk);
        while(1)begin
                scan_file = $fscanf(file_inputR, "%d\n", input_pixelR);
                scan_file = $fscanf(file_inputG, "%d\n", input_pixelG);
                scan_file = $fscanf(file_inputB, "%d\n", input_pixelB);
                @(negedge clk);
            end
        end
endmodule