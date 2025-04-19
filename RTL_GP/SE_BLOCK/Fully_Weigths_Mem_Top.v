module Fully_Weigths_Mem_Top(data_in,clk,index,en,rd,wr,rst,data_out);
    parameter height_1 = 32768;//32744;          // Height of the memory (rows)
    parameter height_2=1256; 
    parameter bitsize = 14;        // Bit size for each data element

    input wire signed [bitsize*32-1:0] data_in;
    input wire  clk,en,rd,wr,rst;
    input wire  [14:0] index; //!check

    output wire signed [bitsize*32-1:0] data_out;


    // Internal signals
    reg signed[bitsize*32-1:0] data_out_temp;
    reg mem_sel;
    reg mem_sel_shifted;
    reg rd_1;
    reg wr_1;
    reg en_1;
    reg [14:0] index_1;
    wire signed [bitsize*32-1:0] data_out_1;


    reg rd_2;
    reg wr_2;
    reg en_2;
    reg [14:0] index_2;
    wire signed [bitsize*32-1:0] data_out_2;

    wire index_1_flag; //! high when index_1 is 32764 
    wire index_2_flag; //! high when index_2 is 1237
    
    assign index_1_flag = (index_1 == height_1-1'b1) ? 1'b1 : 1'b0; 
    assign index_2_flag = (index_2 == height_2-1'b1) ? 1'b1 : 1'b0; 
/*
always @(*)
    begin
        if(mem_sel==1'b0 && index_1_flag==1'b0)
            mem_sel = 1'b0;
        else 
            mem_sel = 1'b1;

    end
*/

always @(posedge clk or negedge rst)
    begin
            if(!rst)begin
                mem_sel <= 1'b0;
            end
            else begin
                if(index_1_flag==1'b1)begin
                    mem_sel <= 1'b1;
                end
                else if(index_2_flag==1'b1)begin
                    mem_sel <= 1'b0;
                end
                else begin
                    mem_sel <= mem_sel;
                end
            end
    end




        always @(*)
        begin
            if(mem_sel==1'b0)begin
                data_out_temp = data_out_1;
            end
            else begin
                data_out_temp = data_out_2;
            end
        end
        
assign data_out = data_out_temp;

    always @(*)
        begin

                    if(mem_sel==1'b0)begin
                        rd_1 <= rd;
                        wr_1 <= wr;
                        en_1 <= en;
                        index_1 <= index;
              
                        rd_2 <= 1'b0;
                        wr_2 <= 1'b0;
                        en_2 <= 1'b0;
                        index_2 <= 'b0;
                    end
                    else begin
                        rd_2 <= rd;
                        wr_2 <= wr;
                        en_2 <= en;
                        index_2 <= index;
            
                        rd_1 <= 1'b0;
                        wr_1 <= 1'b0;
                        en_1 <= 1'b0;
                        index_1 <= 'b0;
                    end


                end

        

    generate
        genvar i;
        for(i=0;i<32;i=i+1)begin
            Fully_Weigths_Mem_Seg #(.bitsize(bitsize),.height(height_1)) 
            mem_segment_bneck_inst_1
            (
            data_in[i*bitsize+bitsize-1:i*bitsize],
            clk,
            index_1,
            en_1,
            rd_1,
            wr_1,
            rst,
            data_out_1[i*bitsize+bitsize-1:i*bitsize]
            );
        end
    endgenerate


    generate
       genvar k;
        for(k=0;k<32;k=k+1)begin
            Fully_Weigths_Mem_Seg #(.bitsize(bitsize),.height(height_2)) 
            mem_segment_bneck_inst_2
            (
            data_in[k*bitsize+bitsize-1:k*bitsize],
            clk,
            index_2,
            en_2,
            rd_2,
            wr_2,
            rst,
            data_out_2[k*bitsize+bitsize-1:k*bitsize]
            );
        end
    endgenerate
endmodule
