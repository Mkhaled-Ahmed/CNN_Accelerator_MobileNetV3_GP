module fixed_point_multiplier_top(data_in,weights,clk,rst,start_flag,Mul_result,valid);
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    parameter NUM_INSTANCES=32;
    
    localparam output_size=NUM_INSTANCES*(bitsize*2-FRAC_BITS);
    
    localparam one_out_size=bitsize*2-FRAC_BITS;

    input wire clk;
    input wire rst;
    input start_flag;
    input signed [bitsize*NUM_INSTANCES-1:0] data_in;
    input signed [bitsize*NUM_INSTANCES-1:0] weights;
        // First signed input
    output signed [output_size-1:0] Mul_result; // Rounded result
    output valid;
    
    wire [NUM_INSTANCES-1:0]valid_temp; // Rounded result

    generate
        genvar i;
        for(i=0;i<NUM_INSTANCES;i=i+1)begin
            fixed_point_multiplier #(.bitsize(bitsize),.FRAC_BITS(FRAC_BITS)) 
                fixed_point_multiplier_inst(
                    .a(data_in[i*bitsize+bitsize-1:i*bitsize])
                    ,.b(weights[i*bitsize+bitsize-1:i*bitsize])
                    ,.clk(clk)
                    ,.rst(rst)
                    ,.start_flag(start_flag)
                    ,.Mul_result(Mul_result[(i*one_out_size+one_out_size-1):i*one_out_size])
                    ,.valid(valid_temp[i])
                    );
        end
    endgenerate

assign valid = &valid_temp;

endmodule