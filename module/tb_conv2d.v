module tb_conv2d();
    parameter bitsize = 18;
    parameter FRAC_BITS = 9;
    parameter NUM_INPUTS = 27;
    parameter window_size = 3;

// output declaration of module fifo_image_input
wire data_valid;
wire [(bitsize*window_size*window_size)-1:0] output_windowR;
wire [(bitsize*window_size*window_size)-1:0] output_windowG;
wire [(bitsize*window_size*window_size)-1:0] output_windowB;

wire [(bitsize*window_size*window_size)*3-1:0] outfifo_window;

assign outfifo_window = {output_windowR,output_windowG,output_windowB};

reg [bitsize-1:0] input_pixelR;
reg [bitsize-1:0] input_pixelG;
reg [bitsize-1:0] input_pixelB;
reg wr_en;
reg start_flag;
reg clk;
reg rst;
reg [bitsize*NUM_INPUTS-1:0] data_in;
reg [bitsize*16-1:0] bias;
reg [bitsize*27*16-1:0] weights;
integer weights_file,bias_file,data_in_fileR,data_in_fileG,data_in_fileB,scan_file;
integer i,forward;
integer out_file;
integer count=0;
fifo_image_input #(
    .image_size  	(224  ),
    .window_size 	(3    ),
    .padding     	(1    ),
    .bitsize     	(bitsize   ),
    .FRAC_BITS   	(FRAC_BITS    ))
u_fifo_image_input(
    .clk            	(clk             ),
    .rst            	(rst             ),
    .input_pixelR   	(input_pixelR    ),
    .input_pixelG   	(input_pixelG    ),
    .input_pixelB   	(input_pixelB    ),
    .wr_en          	(wr_en           ),
    .data_valid     	(data_valid      ),
    .output_windowR 	(output_windowR  ),
    .output_windowG 	(output_windowG  ),
    .output_windowB 	(output_windowB  )
);

// output declaration of module conv2d
wire [bitsize*16-1:0] hs_result;
wire hs_valid;

conv2d #(
    .bitsize   	(bitsize  ),
    .FRAC_BITS 	(FRAC_BITS))
u_conv2d(
    .bias       	(bias        ),
    .clk        	(clk         ),
    .rst        	(rst         ),
    .start_flag 	(data_valid  ),
    .data_in    	(outfifo_window     ),
    .weights    	(weights     ),
    .hs_result  	(hs_result   ),
    .hs_valid   	(hs_valid    )
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end





initial begin
    rst =0;
    @(negedge clk);
    rst =1;
    wr_en = 1;
    data_in_fileR = $fopen("textfiles/inputR.txt","r");
    data_in_fileG = $fopen("textfiles/inputG.txt","r");
    data_in_fileB = $fopen("textfiles/inputB.txt","r");
    while(1)begin
        scan_file = $fscanf(data_in_fileR, "%b\n", input_pixelR);
        scan_file = $fscanf(data_in_fileR, "%b\n", input_pixelG);
        scan_file = $fscanf(data_in_fileR, "%b\n", input_pixelB);
        @(negedge clk);
    end
end

initial begin
    weights_file = $fopen("textfiles/weights_B.txt","r");
    out_file = $fopen("textfiles/output.txt","w");
    bias_file = $fopen("textfiles/bias_B.txt","r");
    scan_file = $fscanf(weights_file, "%b\n", weights);
    scan_file = $fscanf(bias_file, "%b\n", bias);
end
always @(negedge clk) begin
    if(hs_valid)begin
        $fwrite(out_file,"%b",hs_result);
        $fdisplay(out_file, "");
        count=count+1;
        if(count==112*112)begin
            $fclose(out_file);
            $fclose(weights_file);
            $fclose(bias_file);
            $fclose(data_in_fileR);
            $fclose(data_in_fileG);
            $fclose(data_in_fileB);
            $fclose(out_file);
            $stop();
        end
    end
end
endmodule