module SE_Multiplier_Top(data_in,weights,clk,rst,start_flag,Mul_result,valid,in_address,out_address);
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    parameter NUM_INSTANCES=16;
    
    localparam output_size=NUM_INSTANCES*bitsize;
    
    localparam one_out_size=bitsize;

    input wire clk;
    input wire rst;
    input start_flag;
    input signed [bitsize*NUM_INSTANCES-1:0] data_in;
    input signed [bitsize*NUM_INSTANCES-1:0] weights;
        // First signed input
    output signed [output_size-1:0] Mul_result; // Rounded result
    output valid;
    
    input wire [12:0] in_address; // Address for input data
    output wire [12:0] out_address; // Address for output data

    wire [NUM_INSTANCES-1:0]valid_temp; // Rounded result

    generate
        genvar i;
        for(i=0;i<NUM_INSTANCES;i=i+1)begin
            SE_Multiplier_Seg #(.bitsize(bitsize),.FRAC_BITS(FRAC_BITS)) 
                SE_Multiplier_Seg_inst(
                    .a(data_in[i*bitsize+bitsize-1:i*bitsize])
                    ,.b(weights[i*bitsize+bitsize-1:i*bitsize])
                    ,.clk(clk)
                    ,.rst(rst)
                    ,.start_flag(start_flag)
                    ,.Mul_result(Mul_result[(i*one_out_size+one_out_size-1):i*one_out_size])
                    ,.valid(valid_temp[i])
                    ,.in_address(in_address)
                    ,.out_address(out_address)
                    );
        end
    endgenerate

assign valid = &valid_temp;

endmodule