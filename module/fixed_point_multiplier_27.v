module fixed_point_multiplier_27(data_in,weights,clk,rst,start_flag,Mul_result,valid);
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    
    
    input wire clk;
    input wire rst;
    input start_flag;
    input signed [bitsize*27-1:0] data_in;
    input signed [bitsize*27-1:0] weights;
        // First signed input
    output signed [(bitsize*2-FRAC_BITS)*27-1:0] Mul_result; // Rounded result
    output valid;
    
    wire [26:0]valid_temp; // Rounded result

    generate
        genvar i;
        for(i=0;i<27;i=i+1)begin
            fixed_point_multiplier #(.bitsize(bitsize),.FRAC_BITS(FRAC_BITS)) 
                fixed_point_multiplier_inst(
                    .a(data_in[i*bitsize+bitsize-1:i*bitsize])
                    ,.b(weights[i*bitsize+bitsize-1:i*bitsize])
                    ,.clk(clk)
                    ,.rst(rst)
                    ,.start_flag(start_flag)
                    ,.Mul_result(Mul_result[i*(bitsize*2-FRAC_BITS)+(bitsize*2-FRAC_BITS)-1:i*(bitsize*2-FRAC_BITS)])
                    ,.valid(valid_temp[i])
                    );
        end
    endgenerate

assign valid = &valid_temp;

endmodule