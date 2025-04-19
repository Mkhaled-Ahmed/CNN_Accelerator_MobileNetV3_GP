module conv2d_adder_16(data_in,start_adder,bias,rst,clk,dataout,valid_out);//! need control signals in adder asap
    parameter bitsize = 14;
    parameter NUM_INPUTS = 27;
    parameter FRAC_BITS = 7;
    parameter bias_size = 14;

    input wire signed [bitsize*27*16-1:0] data_in;
    input wire start_adder;
    input wire rst;
    input wire clk;
    input wire signed [bias_size*16-1:0] bias;

    wire [15:0]valid_out_temp;
    
    output wire valid_out;
    output wire signed [(bitsize+5)*16-1:0] dataout;

    generate
        genvar i;
        for(i=0;i<16;i=i+1)begin
            adder_27 #(.bitsize(bitsize),.NUM_INPUTS(NUM_INPUTS),.bias_size(bias_size),.FRAC_BITS(FRAC_BITS)) 
                adder_27_inst(
                    .clk(clk)
                    ,.rst(rst)
                    ,.start_adder(start_adder)
                    ,.input_numbers(data_in[i*27*bitsize + 27*bitsize-1:i*27*bitsize])
                    ,.bias(bias[i*bias_size+bias_size-1:i*bias_size])//!help
                    ,.sum_output(dataout[i*(bitsize+5) + (bitsize+5)-1:i*(bitsize+5)])
                    ,.data_valid(valid_out_temp[i])
                    );
        end
    endgenerate
    assign valid_out = &valid_out_temp;
endmodule
