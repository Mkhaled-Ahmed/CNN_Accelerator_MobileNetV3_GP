module conv2d(bias,clk,rst,start_flag,data_in,weights,hs_result,hs_valid);
    parameter bitsize = 18;        // Total width of inputs
    parameter FRAC_BITS = 9;

    input wire [bitsize*16-1:0]bias;
    input wire clk;
    input wire rst;
    input wire start_flag;
    input signed [bitsize*27-1:0] data_in;
    input signed [bitsize*27*16-1:0] weights;
    output signed [bitsize*16-1:0] hs_result;
    output hs_valid;

    // output declaration of module fixed_point_multiplier_27X16
    wire [(bitsize*2-FRAC_BITS)*27*16-1:0] Mult_result;
    wire valid_mult;
    wire valid_add;
    wire [(bitsize*2-FRAC_BITS+5)*16-1:0] adder_result;
    
    fixed_point_multiplier_27X16 #(
        .bitsize   	(bitsize  ),
        .FRAC_BITS 	(FRAC_BITS)
    )
    fixed_point_multiplier_27X16_inst(
        .clk         	(clk          ),
        .rst         	(rst          ),
        .start_flag  	(start_flag   ),
        .data_in     	(data_in      ),
        .weights     	(weights      ),
        .Mult_result 	(Mult_result  ),
        .valid       	(valid_mult   )
    );
    // output declaration of module conv_2d_adder_16

    
    conv2d_adder_16 #(
        .bitsize    	(bitsize*2-FRAC_BITS    ),
        .bias_size  	(bitsize                ),
        .NUM_INPUTS 	(27         ),
        .FRAC_BITS 	(FRAC_BITS )
        )
    conv2d_adder_16_inst(
        .data_in   	(Mult_result),
        .start_adder(valid_mult        ),
        .rst       	(rst        ),
        .clk       	(clk        ),
        .bias      	(bias       ),
        .valid_out 	(valid_add  ),
        .dataout   	(adder_result)
    );
    hs_block #(
        .DATA_WIDTH 	(bitsize*2-FRAC_BITS+5),
        .FRAC_BITS  	(FRAC_BITS),
        .OUT_SIZE   	(bitsize)
    )
    hs_block_inst(
        .input_data  	(adder_result),
        .clk         	(clk        ),
        .rst         	(rst        ),
        .en          	(valid_add  ),
        .output_data 	(hs_result),
        .valid       	(hs_valid)
    );
    // output declaration of module conv2d_relu_16
    
    // conv2d_relu_16 #(
    //     .FRAC_BITS  	(FRAC_BITS),
    //     .DATA_WIDTH 	(bitsize))
    // conv2d_relu_16_inst(
    //     .clk      	(clk       ),
    //     .rst      	(rst       ),
    //     //.bias     	(bias             ),//! need to add bias
    //     .enable   	(valid_add ),
    //     .data_in  	(adder_result),
    //     .data_out 	(relu_result),
    //     .valid    	(valid_relu)
    // );
    
endmodule
