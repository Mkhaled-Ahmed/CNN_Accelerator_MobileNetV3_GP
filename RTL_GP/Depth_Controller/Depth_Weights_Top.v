module Depth_Weights_Top #(
    parameter Data_Width = 14,
    parameter height = 2480,
    parameter address_width = 12 // Address width (for 1024 locations, 10 bits are needed)

)

(
    input wire signed [25*Data_Width-1:0] data_in,
    input wire clk,
    input wire [address_width-1:0] index,
    input wire en,
    input wire rd,
    input wire wr,
    input wire rst,
    output wire signed [16*25*Data_Width-1:0] data_out
);

wire counter_flag; // Flag to indicate when the filter counter reaches a certain value
reg [3:0] filter_counter; 
wire signed [Data_Width-1:0] data_temp[24:0]; // Temporary data output for each segment

reg signed [25*Data_Width-1:0] data_out_temp[15:0]; // Temporary data output for the entire module

reg counter_enable;

always @(posedge clk or negedge rst)
    begin
        if(!rst)
        begin   
        counter_enable<='b0;
        end
        else begin
            if (rd) begin
                counter_enable <= 1'b1; // Enable counter when en is high
            end
        end

    end

assign counter_flag = (filter_counter == 4'b1111); // Set the flag when the filter counter reaches 15

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        filter_counter <= 0; // Reset filter counter on reset signal
    end else begin
            if (counter_enable) begin
                filter_counter <= filter_counter + 1; // Increment filter counter on read enable
            end
            else if(counter_flag) 
                begin
                    filter_counter <= 0; // Reset filter counter when it reaches 15
                end
        end
    end
integer j;
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                for(j=0;j<16;j=j+1)
                begin
                    data_out_temp[j] <= 'b0; // Reset data output on reset signal
                end
            end     
        else
            begin
                if(counter_enable)
                    begin
                        data_out_temp[filter_counter]<={data_temp[24],data_temp[23],data_temp[22],data_temp[21],data_temp[20],data_temp[19],data_temp[18],data_temp[17],
                        data_temp[16],data_temp[15],data_temp[14],data_temp[13],data_temp[12],data_temp[11],data_temp[10],data_temp[9],data_temp[8],data_temp[7],
                        data_temp[6],data_temp[5],data_temp[4],data_temp[3],data_temp[2],data_temp[1],data_temp[0]};
                    end

            end
    end


        assign data_out = {data_out_temp[15], data_out_temp[14], data_out_temp[13], data_out_temp[12], 
                           data_out_temp[11], data_out_temp[10], data_out_temp[9], data_out_temp[8], 
                           data_out_temp[7], data_out_temp[6], data_out_temp[5], data_out_temp[4], 
                           data_out_temp[3], data_out_temp[2], data_out_temp[1], data_out_temp[0]};



    generate
        genvar i;
        for(i=0;i<25;i=i+1)begin
            Depth_Weights_Seg #(.bitsize(Data_Width),.height(height),.address_width(address_width)) 
            Depth_Weights_Seg_inst
            (
            data_in[i*Data_Width+Data_Width-1:i*Data_Width],
            clk,
            index,
            en,
            rd,
            wr,
            rst,
            data_temp[i]
            );
        end
    endgenerate





    endmodule