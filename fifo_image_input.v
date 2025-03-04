module fifo_image_input(clk,rst,input_pixelR,input_pixelG,input_pixelB,wr_en,data_valid,output_window);
    parameter image_size = 224;
    parameter window_size = 3;
    parameter padding = 1;
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    input  clk;
    input  rst;
    input signed[bitsize:0] input_pixelR;
    input signed[bitsize:0] input_pixelG;
    input signed[bitsize:0] input_pixelB;
    input wr_en;
    output data_valid;

    wire data_validR;
    wire data_validG;
    wire data_validB;
    wire data_valid_add_operation_temp;
    reg data_valid_temp;

    wire [(bitsize*window_size*window_size)-1:0] output_window;
    
    fifo_segment #(
        .image_size  	(image_size  ),
        .window_size 	(window_size    ),
        .padding     	(padding    ),
        .bitsize     	(bitsize   ),
        .FRAC_BITS   	(FRAC_BITS    ))
    u_fifo_segmentR(
        .clk           	(clk            ),
        .rst           	(rst            ),
        .input_pixel   	(input_pixel    ),
        .wr_en         	(wr_en          ),
        .data_valid    	(data_validR     ),
        .output_window 	(output_window  )
    );


    fifo_segment #(
        .image_size  	(image_size  ),
        .window_size 	(window_size    ),
        .padding     	(padding    ),
        .bitsize     	(bitsize   ),
        .FRAC_BITS   	(FRAC_BITS    ))
    u_fifo_segmentG(
        .clk           	(clk            ),
        .rst           	(rst            ),
        .input_pixel   	(input_pixel    ),
        .wr_en         	(wr_en          ),
        .data_valid    	(data_validG     ),
        .output_window 	(output_window  )
    );


    fifo_segment #(
        .image_size  	(image_size  ),
        .window_size 	(window_size    ),
        .padding     	(padding    ),
        .bitsize     	(bitsize   ),
        .FRAC_BITS   	(FRAC_BITS    ))
    u_fifo_segmentB(
        .clk           	(clk            ),
        .rst           	(rst            ),
        .input_pixel   	(input_pixel    ),
        .wr_en         	(wr_en          ),
        .data_valid    	(data_validB     ),
        .output_window 	(output_window  )
    );

    assign data_valid = data_valid_temp;
    assign data_valid_add_operation_temp = data_validR & data_validG & data_validB;
always @(posedge clk) begin
    if(data_valid_add_operation_temp) begin
        data_valid_temp <= 1;
    end
    else begin
        data_valid_temp <= !data_valid_temp;
    end
end

endmodule