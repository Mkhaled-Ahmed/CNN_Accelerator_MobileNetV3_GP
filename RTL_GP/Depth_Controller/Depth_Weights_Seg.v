
module Depth_Weights_Seg(data_in,clk,index,en,rd,wr,rst,data_out);
    parameter height =2480; //32531;     //*Height of the memory (rows)
    parameter bitsize = 14;        //*width of the memory size of pixel
    parameter address_width = 12; // Address width (for 1024 locations, 10 bits are needed)


    input signed [bitsize-1:0] data_in;
    input  clk,en,rd,wr,rst;
    input  [address_width-1:0] index;

   (* ram_style = "block" *) reg signed [bitsize-1:0] mem [height-1:0];

    reg signed[bitsize-1:0]data_out_temp;

    output signed [bitsize-1:0] data_out;

    assign data_out=data_out_temp;

    always @(posedge clk ) 
    begin //!rst need a lookup for it
        begin
            if (en) begin
                if(rd)begin
                    data_out_temp<=mem[index];
                end
                if(wr) begin
                    mem[index]<=data_in;
                end
            end
        end
    end
endmodule
