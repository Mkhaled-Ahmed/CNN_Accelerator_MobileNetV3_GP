module conv2d_relu_16(clk,rst,enable,data_in,data_out,valid);

    parameter FRAC_BITS = 7;
    parameter DATA_WIDTH = 14;

    input wire clk;
    input wire rst;
    input wire enable;
    input signed [DATA_WIDTH*16-1:0] data_in;
    output signed [DATA_WIDTH*16-1:0] data_out;
    output valid;

    generate
        genvar i;
        for(i=0;i<16;i=i+1)begin
            relu_segment #(.FRAC_BITS(FRAC_BITS),.DATA_WIDTH(DATA_WIDTH)) 
                relu_segment_inst(
                    .clk(clk)
                    ,.rst_n(rst)
                    ,.enable(enable)
                    ,.data_in(data_in[i*DATA_WIDTH+DATA_WIDTH-1:i*DATA_WIDTH])
                    ,.data_out(data_out[i*DATA_WIDTH+DATA_WIDTH-1:i*DATA_WIDTH])
                    ,.valid(valid)
                    );
        end
    endgenerate

endmodule