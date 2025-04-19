module Point_Controller #()
(

    input clk,
    input rst,
    input Point_Enabel, //* will be high for one cycle only 

    //! input of Weights 
    input   [9:0]W_start_address,
    input   [3:0]filter_channel_max,   //* (channels of filter)/16 (required cycle to get one pixel for out)   max (96/16) =6
    input   [5:0]filter_number_max,     //* (number of filters )/16 (increas when window is done)             max (576/16)=36
    
    //! input of data
    input [13:0] window_size_max, //* size of window (112*112) =12544

    //! activation_function_enable
    input activation_function_enable,

    //! output of weights 
    output [9:0] weights_address,
    output weights_read_en,

    //! output of read address of data
    output reg [12:0] read_data_address,//* max is  (28*28*88)/16= 4312
    output data_read_en,
    //! output of weight address of data
    output [13:0] write_data_address,//* max is (112*112)=12544
    output data_write_en,
	output reg Multplication_EN,
    output Point_End


);

reg start_op; //* will be high when Point_enable and zero when Point end 

reg [9:0] weight_temp_address_1; //* increase with channels (connected to output weights address) 
reg [9:0] weight_temp_address_2; //* hold start address of filter  which temp_1 will read 

reg [3:0] filter_channel_counter;
wire       filter_channel_flag;

reg [5:0] filter_number_counter;
wire       filter_number_flag;

reg [13:0] window_size_counter; //* increase during feating pixels return to zero when window is done 
wire       window_size_flag;

//! temp reg for reading data address
reg [12:0] data_temp_address_1; //* increase with channels (connected to output weights address) 
reg [12:0] data_temp_address_2; //* hold start address of filter  which temp_1 will read 

reg temp_end;
wire weight_temp2_flag;
reg data_temp2_flag;


reg [13:0] write_data_address_temp; //* increase with channels (connected to output weights address)
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                start_op<='b0;
            end
        else
            begin
                if(Point_Enabel)
                    begin
                        start_op<='b1;
                    end
                else if(Point_End)
                    begin
                        start_op<='b0;
                    end
            end
    end


//! window counter
    always @(posedge clk or negedge rst)
        begin
            if(!rst)
                begin
                    window_size_counter <= 14'b0;
                end
            else
                begin
                    if(start_op)
                        begin
                             if(window_size_flag)
                                begin
                                    window_size_counter <= 14'b0;
                                end
                            else if(filter_channel_flag)
                                begin
                                    window_size_counter <= window_size_counter + 1;
                                end

                        end
                end
        end

    assign window_size_flag = ((window_size_max - 1'b1 == window_size_counter) &&filter_channel_flag) ;

///////////////////////////////////////////////////
//////////////! addressing Weights//////////////// 
///////////////////////////////////////////////////

//! channel counter

assign weights_address=weight_temp_address_1; //* assign output of weights

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                filter_channel_counter<=4'b0;
            end
        else
            begin
                if(start_op)
                    begin
                        if(!filter_channel_flag)
                            begin
                                filter_channel_counter<=filter_channel_counter+1'b1;
                            end
                        else
                            begin
                                filter_channel_counter<=4'b0;
                            end
                    end
            end
    end


//! channel counter of filters 
assign filter_channel_flag=((filter_channel_max-1'b1)==filter_channel_counter); 

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                weight_temp_address_1<='b0;
            end
        else 
            begin
              if(Point_Enabel)
                begin
                    weight_temp_address_1<=W_start_address;
                end
            else if(start_op)
                begin
                    if(!filter_channel_flag)
                       begin
                    weight_temp_address_1<=weight_temp_address_1+1'b1;
                        end
                    else if(filter_channel_flag)
                        begin
                            weight_temp_address_1<=weight_temp_address_2;
                        end
            end
    end
end



assign weight_temp2_flag=(((window_size_max-1'b1)==window_size_counter) && !filter_channel_flag);
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                weight_temp_address_2<='b0;
            end
        else 
            begin
              if(Point_Enabel)
                begin
                    weight_temp_address_2<=W_start_address;
                end
                else if(start_op)
                    begin
                        if(weight_temp2_flag)
                            begin
                                weight_temp_address_2<=weight_temp_address_2+filter_channel_max;
                            end
                    end
            end
    end


assign filter_number_flag=((filter_number_max-1'b1)==filter_number_counter);
always @(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            filter_number_counter<='b0;   
        end
    else
        begin
            if(start_op)
            begin
                     if(filter_number_flag &&window_size_flag )
                        begin
                            filter_number_counter<='b0;
                        end
                   else  if(window_size_flag)
                    begin
                        filter_number_counter<= filter_number_counter+1'b1;
                    end


            end       
        end

end


//! Data Addressing

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                data_temp_address_1<='b0;
            end
        else

        if(start_op)
            begin
                if(window_size_flag)
                    begin
                        data_temp_address_1<='b0;
                    end
                else if(filter_channel_flag)
                    begin
                        data_temp_address_1<=data_temp_address_2;
                    end
                else
                    begin
                        data_temp_address_1<=data_temp_address_1+window_size_max;
                    end
            end
            
    end

//*assign read_data_address=data_temp_address_1;

///*assign data_temp2_flag=((filter_channel_max-2'b10)==filter_channel_counter);

always @(*)
    begin
        if(filter_channel_max==1)
            begin
                data_temp2_flag=((filter_channel_max-1'b1)==filter_channel_counter);

                read_data_address=window_size_counter;
            end
        else
            begin
                data_temp2_flag=((filter_channel_max-2'b10)==filter_channel_counter);
                read_data_address=data_temp_address_1;
            end
    end



always @(posedge clk or negedge rst) 
    begin
        if (!rst) 
            begin
                data_temp_address_2<='b0;
            end
        else
            begin
            if(start_op)
                begin            
                    if(window_size_flag)
                        begin
                            data_temp_address_2<='b0;
                        end
                    else if(data_temp2_flag)
                        begin
                            data_temp_address_2<=data_temp_address_2+1'b1;
                        end            
                end
            end
    end
    

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                write_data_address_temp<='b0;
            end
        else
            begin
                if(activation_function_enable)
                    begin
                        write_data_address_temp<=write_data_address_temp+1'b1;

                    end

            end
    end

assign write_data_address=write_data_address_temp; //* assign output of weights
assign data_write_en=activation_function_enable; //* will be high when Point_enable and zero when Point end


 //! end of Point
 assign Point_End=(filter_number_flag && window_size_flag); 
 assign weights_read_en=Point_Enabel || start_op; //* will be high when Point_enable and zero when Point end
 assign data_read_en=Point_Enabel || start_op; //* will be high when Point_enable and zero when Point end
 
 
 always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Multplication_EN<='b0;
            end
        else 
            begin
                Multplication_EN<=start_op;
            end
    end
endmodule
