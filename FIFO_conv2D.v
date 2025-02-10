module FIFO_conv2D#(
    parameter DATA_Width = 14,
    parameter FIFO_Depth = 432,
    parameter f_bit = 7
)(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [DATA_Width-1:0] data_in,
    output reg  [DATA_Width*FIFO_Depth-1:0] data_out
);

reg [DATA_Width-1:0] mem [FIFO_Depth-1:0];
integer i;
always @(posedge clk or negedge rst) begin
    if (rst) begin
        for (i =0 ;i<FIFO_Depth ;i=i+1) begin
            mem[i]<=0;        
        end
        
    end
    else begin
        if (rd_en) begin
            for (i = 0; i < FIFO_Depth; i=i+1) begin
                data_out[i*DATA_Width +: DATA_Width] = mem[i]; // Correct packing
            end
        end
    end
end



endmodule