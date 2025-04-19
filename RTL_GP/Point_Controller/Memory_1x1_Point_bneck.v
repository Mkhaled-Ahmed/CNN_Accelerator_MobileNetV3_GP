module Memory_1x1_EX_bneck #(
    parameter Data_Width = 14,
    parameter height =938 

)

(
    input wire signed [256*Data_Width-1:0] data_in,
    input wire clk,
    input wire [9:0] index,
    input wire en,
    input wire rd,
    input wire wr,
    input wire rst,
    output wire signed [256*Data_Width-1:0] data_out
);


    generate
        genvar i;
        for(i=0;i<256;i=i+1)begin
            EX_Weigths_Mem_Seg #(.bitsize(Data_Width),.height(height)) 
            mem_bneck_1x1_inst
            (
            data_in[i*Data_Width+Data_Width-1:i*Data_Width],
            clk,
            index,
            en,
            rd,
            wr,
            rst,
            data_out[i*Data_Width+Data_Width-1:i*Data_Width]
            );
        end
    endgenerate

    endmodule