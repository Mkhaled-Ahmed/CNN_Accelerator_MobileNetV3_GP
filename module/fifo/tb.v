module fifo_seg_tb;
    parameter bitsize = 18;        // Total width of inputs
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

fifo_image_input#(.bitsize(bitsize))
    u_fifo_image_input(
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
        file_output=$fopen("outputrpixel.txt","w");
        // $fwrite(file,"%b",sum_output);
        // $fdisplay(file, "");
        //while (2) begin
            @(posedge data_valid);
            repeat(600)begin
                @(negedge clk);
                $fwrite(file_output," %b ",output_windowR [17: 0] );
                $fwrite(file_output," %b ", output_windowR [35:18] );
                $fwrite(file_output," %b ", output_windowR [53:36] );
                $fdisplay(file_output, "");
                $fwrite(file_output," %b ", output_windowR  [71:54] );
                $fwrite(file_output," %b ", output_windowR  [89:72] );
                $fwrite(file_output," %b ", output_windowR [107:90] );
                $fdisplay(file_output, "");
                $fwrite(file_output," %b ", output_windowR [125:108] );
                $fwrite(file_output," %b ", output_windowR [143:126] );
                $fwrite(file_output," %b ", output_windowR [161:144] );
                $fdisplay(file_output, "");
                $fwrite(file_output,"data valid: %b ", data_valid);
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
        file_inputR = $fopen("textfiles/inputR.txt", "r");
        file_inputG = $fopen("textfiles/inputG.txt", "r");
        file_inputB = $fopen("textfiles/inputB.txt", "r");
        //@(negedge clk);
        while(1)begin
                scan_file = $fscanf(file_inputR, "%b\n", input_pixelR);
                scan_file = $fscanf(file_inputG, "%b\n", input_pixelG);
                scan_file = $fscanf(file_inputB, "%b\n", input_pixelB);
                @(negedge clk);
            end
        end
endmodule