module tb_conv2d();
    parameter bitsize = 18;
    parameter FRAC_BITS = 9;
    parameter NUM_INPUTS = 27;
    parameter window_size = 3;
    parameter Row_Length = 1;

// output declaration of module fifo_image_input
wire data_valid;
wire [(bitsize*window_size*window_size)-1:0] output_windowR;
wire [(bitsize*window_size*window_size)-1:0] output_windowG;
wire [(bitsize*window_size*window_size)-1:0] output_windowB;

wire [(bitsize*window_size*window_size)*3-1:0] outfifo_window;

assign outfifo_window = {output_windowB,output_windowG,output_windowR};

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
integer out_file,j;
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



reg signed[bitsize-1:0]weight_arr[431:0];
reg signed[bitsize-1:0]bias_arr[15:0];
initial begin
weights_file = $fopen("textfiles/conv2d_weights.txt","r");
bias_file = $fopen("textfiles/bias.txt","r");
for (i=0;i<16;i=i+1)begin
    scan_file = $fscanf(bias_file, "%d\n", bias_arr[i]);
end
for (i=0;i<432;i=i+1)begin
    scan_file = $fscanf(weights_file, "%d\n", weight_arr[i]);
end
$fclose(weights_file);
$fclose(bias_file);
// for (i=0;i<16;i=i+1)begin
//     $display("%b",bias_arr[i]);
// end
// for (i=0;i<432;i=i+1)begin
//     $display("%b",weight_arr[i]);
// end
end
always @(*)begin
    for(j=0;j<432;j=j+1)begin
        weights[j*bitsize+:bitsize] = weight_arr[j];
    end
end

always @(*)begin
    for(j=0;j<16;j=j+1)begin
        bias[j*bitsize+:bitsize] = bias_arr[j];
    end
end
// generate
// genvar j;


// for(j=0;j<16;j=j+1)begin
// always @(*)begin
//     bias[j*bitsize+:bitsize] = bias_arr[j];
// end
// end
// endgenerate

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
        scan_file = $fscanf(data_in_fileG, "%b\n", input_pixelG);
        scan_file = $fscanf(data_in_fileB, "%b\n", input_pixelB);
        @(negedge clk);
    end
end

initial begin
//     weights_file = $fopen("textfiles/weights_B.txt","r");
    out_file = $fopen("textfiles/output.txt","w");
//     bias_file = $fopen("textfiles/bias_B.txt","r");
//     scan_file = $fscanf(weights_file, "%b\n", weights);
//     scan_file = $fscanf(bias_file, "%b\n", bias);
end
always @(negedge clk) begin
    if(hs_valid)begin
        $fwrite(out_file,"%b\n",hs_result);
        // $fdisplay(out_file, "");
        count=count+1;
        if(count==112*112)begin
            $fclose(out_file);
            // $fclose(weights_file);
            // $fclose(bias_file);
            $fclose(data_in_fileR);
            $fclose(data_in_fileG);
            $fclose(data_in_fileB);
            $fclose(out_file);
            $stop();
        end
    end
end
// integer  status;
//         reg signed [bitsize-1:0] data0 [Row_Length-1:0];  // Array to store 16 numbers
//         reg signed [bitsize-1:0] data1 [Row_Length-1:0];  // Array to store 16 numbers


endmodule