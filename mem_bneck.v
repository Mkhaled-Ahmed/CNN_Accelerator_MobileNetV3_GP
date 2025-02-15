module mem_bneck(data_in,clk,index,en,rd,wr,rst,data_out);
    parameter height = 112*112;          // Height of the memory (rows)
    parameter bitsize = 16;        // Bit size for each data element

    input wire [bitsize*16-1:0] data_in;
    input wire clk,en,rd,wr,rst;
    input wire [13:0] index; //!check

    output wire [bitsize*16-1:0] data_out;

    generate
        genvar i;
        for(i=0;i<16;i=i+1)begin
            mem_segment_bneck #(.bitsize(bitsize),.height(height)) mem_segment_bneck_inst(data_in[i*bitsize+bitsize-1:i*bitsize],clk,index,en,rd,wr,rst,data_out[i*bitsize+bitsize-1:i*bitsize]);
        end
    endgenerate
endmodule