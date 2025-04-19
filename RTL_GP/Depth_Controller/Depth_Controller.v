module Depth_Controller #()  
(
    input clk,
    input rst,

    input [11:0] filter_start_address, //*max is 2480
    input [5:0]  filter_unmber_max, //* (576/16) = 36

    input Depth_Enable, //* input from controller top module (high for one cycle)
    input Window_Done, //* input from FIFO modules        (high for one cycle)
    input SE_Enable, //* input from controller top module (high for one cycle)
    input Activation_Done, //* input from activation module
    input [11:0] Window_Size, //* max is 56*56= 3136


    output data_write_enable, //* write enable for the depth data (equal activation done)
    output [12:0] data_write_address, //* write address for the depth data (equal activation done) 
    output [11:0] filter_address, //* address for the weights memory (max is 2480)
    output Weights_Read_Enable //* read enable for the weights memory (max is 2480)
);

//! will be used to enable weights reading only for 16 cycle 
reg [3:0]filter_counter; //*max is 16 filters
wire filter_counter_flag; //* flag to indicate that the filter counter has reached its maximum value (16 filters)

reg [11:0] filter_address_temp; //* address for the weights memory (max is 2480)

reg weight_read_enable_temp; //* read enable for the depth data (equal activation done)

reg [12:0] data_write_address_temp; //* write address for the depth data (equal activation done)


always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                filter_address_temp <= 12'b0;
            end
        else
            begin
                if(Depth_Enable)begin
                    filter_address_temp <= filter_start_address; //* set the filter address to the start address
                end
                else if(filter_counter_flag)begin
                    filter_address_temp <= filter_address_temp + 5'd16; //* set the filter address to the start address + number of filters
                end
            end
    end

assign filter_counter_flag = (filter_counter == 4'd15);
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                filter_counter <= 4'b0;
            end
        else
            begin
                if(Depth_Enable || Window_Done || weight_read_enable_temp)begin
                    filter_counter <=filter_counter+1'b1; //* reset the filter counter to 0
                end
                else if(filter_counter_flag)begin
                    filter_counter <= 0; //* increment the filter counter by 1
                end
            end
    end

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                weight_read_enable_temp <= 1'b0;
            end
        else
            begin
                if(Depth_Enable||Window_Done )begin
                    weight_read_enable_temp<= 1'b1; //* read enable for the depth data (equal activation done)
                end
                else if(filter_counter_flag)begin
                    weight_read_enable_temp<= 1'b0; //* read enable for the depth data (equal activation done)
                end
            end

    end


assign data_write_address = data_write_address_temp; //* write address for the depth data (equal activation done)
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                data_write_address_temp <= 12'b0;
            end
        else   
        begin
                if(Activation_Done)
                    begin
                        data_write_address_temp <= data_write_address_temp + 1'b1; //* write address for the depth data (equal activation done)
                    end
                else if(Depth_Enable)
                        begin
                            data_write_address_temp <= 12'b0; //* set the write address to 0
                        end
        end
    end





assign data_write_enable = Activation_Done; //* write enable for the depth data (equal activation done)
assign Weights_Read_Enable = weight_read_enable_temp; //* read enable for the depth data (equal activation done)
assign filter_address = filter_address_temp; //* address for the weights memory (max is 2480)
endmodule