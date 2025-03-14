module fixed_point_multiplier_27X16 (data_in,weights,rst,start_flag,clk,Mult_result,valid);
    

    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;

    input wire clk;
    input wire rst;
    input start_flag;
    input signed [bitsize*27-1:0] data_in;
    input signed [bitsize*27*16-1:0] weights;
    
    output signed [bitsize*27*16-1:0] Mult_result; 
    output valid;

    wire [15:0]valid_temp; 

    generate
        genvar i;
        for(i=0;i<16;i=i+1)begin
            fixed_point_multiplier_27 #(.bitsize(bitsize),.FRAC_BITS(FRAC_BITS)) 
                fixed_point_multiplier_27_inst(
                    .data_in(data_in)
                    ,.weights(weights[i*27*bitsize + 27*bitsize-1:i*27*bitsize])
                    ,.clk(clk)
                    ,.rst(rst)
                    ,.start_flag(start_flag)
                    ,.Mul_result(Mult_result[i*27*bitsize + 27*bitsize-1:i*27*bitsize])
                    ,.valid(valid_temp[i])
                    );
        end
    endgenerate

assign valid = &valid_temp;
endmodule