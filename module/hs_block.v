module hs_block(input_data,clk,rst,en,output_data,valid);
    //?Hardswitch block
    parameter DATA_WIDTH = 26;
    parameter FRAC_BITS = 7;
    parameter OUT_SIZE =14;
    input signed [DATA_WIDTH*16-1:0] input_data;
    input clk,rst,en;
    output signed [OUT_SIZE*16-1:0] output_data;
    wire [15:0] valid_temp;
    output valid;
    generate
        genvar i;
        for(i=0;i<16;i=i+1) begin:hs_segment
            hs_segment #(
                .DATA_WIDTH 	(DATA_WIDTH  ),
                .FRAC_BITS  	(FRAC_BITS   ),
                .OUT_SIZE   	(OUT_SIZE    )
                )
            u_hs_segment(
                .input_data  	(input_data[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i]   ),
                .clk         	(clk          ),
                .rst         	(rst          ),
                .en          	(en           ),
                .output_data 	(output_data[OUT_SIZE*(i+1)-1:OUT_SIZE*i]  ),
                .valid       	(valid_temp[i]        )
            );
        end
    endgenerate
    assign valid = &valid_temp;
endmodule
