module conv2d(bias,clk,rst,start_flag,data_in,weights,relu_result,valid_relu);
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;

    input wire [bitsize*16-1:0]bias;
    input wire clk;
    input wire rst;
    input wire start_flag;
    input signed [bitsize*27-1:0] data_in;
    input signed [bitsize*27*16-1:0] weights;
    output signed [bitsize*16-1:0] relu_result;
    output valid_relu;

    // output declaration of module fixed_point_multiplier_27X16
    wire [bitsize*27*16-1:0] Mult_result;
    wire valid_mult;
    wire valid_add;
    wire [bitsize*16-1:0] adder_result;
    
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
        .bitsize    	(bitsize    ),
        .NUM_INPUTS 	(27         ))
    conv2d_adder_16_inst(
        .data_in   	(Mult_result),
        .start_adder(valid_mult        ),
        .rst       	(rst        ),
        .clk       	(clk        ),
        .valid_out 	(valid_add  ),
        .dataout   	(adder_result)
    );
    
    // output declaration of module conv2d_relu_16
    
    conv2d_relu_16 #(
        .FRAC_BITS  	(FRAC_BITS),
        .DATA_WIDTH 	(bitsize))
    conv2d_relu_16_inst(
        .clk      	(clk       ),
        .rst      	(rst       ),
        //.bias     	(bias             ),//! need to add bias
        .enable   	(valid_add ),
        .data_in  	(adder_result),
        .data_out 	(relu_result),
        .valid    	(valid_relu)
    );
    
endmodule
