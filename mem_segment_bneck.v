module mem_segment_bneck(data_in,clk,index,en,rd,wr,rst,data_out);
    parameter height = 112*112;     //*Height of the memory (rows)
    parameter bitsize = 14;        //*width of the memory size of pixel


    input signed [bitsize-1:0] data_in;
    input  clk,en,rd,wr,rst;
    input  [13:0] index;

    reg signed [bitsize-1:0] mem [height-1:0];

    reg signed[bitsize-1:0]data_out_temp;

    output signed [bitsize-1:0] data_out;

    assign data_out=data_out_temp;

    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            data_out_temp<=0;
        end
        else begin
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