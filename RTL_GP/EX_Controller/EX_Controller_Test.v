module EX_Controller_Test #()
(

    input clk,
    input rst,
    input EX_Enabel, //* will be high for one cycle only 

    //! input of Weights 
    input   [9:0]W_start_address,
    input   [3:0]filter_channel_max,   //* (channels of filter)/16 (required cycle to get one pixel for out)   max (96/16) =6
    input   [5:0]filter_number_max,     //* (number of filters )/16 (increas when window is done)             max (576/16)=36
    
    //! input of data
    input [13:0] window_size_max, //* size of window (112*112) =12544
    input [1:0] padding,
    input [6:0] row_size, //* max is 112

    //! output of weights 
    output [9:0] weights_address,
    output weights_read_en,

    //! output of data
    output reg [13:0] data_address,
    output data_read_en,
    output EX_End,
    output reg Multplication_EN,
    output Zero_Buffering_EN

);

reg start_op; //* will be high when EX_enable and zero when EX end 

reg [9:0] weight_temp_address_1; //* increase with channels (connected to output weights address) 
reg [9:0] weight_temp_address_2; //* hold start address of filter  which temp_1 will read 

reg [3:0] filter_channel_counter;
wire       filter_channel_flag;

reg [5:0] filter_number_counter;
wire       filter_number_flag;

reg [13:0] window_size_counter; //* increase during feating pixels return to zero when window is done 
wire       window_size_flag;

reg [13:0] data_temp_address_1; //* increase with channels (connected to output weights address) 
reg [13:0] data_temp_address_2; //* hold start address of filter  which temp_1 will read 

reg [1:0] padding_counter_1,padding_counter_2; //* hold padding value to be used in data address calculation
wire padding_flag_1,padding_flag_2; //* will be high when padding is done


reg [6:0] row_size_counter;
wire row_size_flag; //* will be high when row size is done

reg temp_end;
wire weight_temp2_flag;
reg data_temp2_flag;
reg EX_End_temp; //* will be high when EX_end is done


reg start_loading_row; //* will be high when loading row
reg start_padding_1; //* will be high when padding 1
reg start_padding_2; //* will be high when padding 2

reg zero_buffering_en_temp; //* will be high when padding 1 and 2 are done

assign padding_flag_1=(padding_counter_1==padding-1'b1); //* will be high when padding is done
always @(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            padding_counter_1<='b0;
        end
    else
        begin
                begin
                    if(padding_flag_1 || start_op || EX_Enabel)
                        begin
                            padding_counter_1<='b0;
                        end 
                    else if       (start_padding_1)  //*(!padding_flag)
                        begin
                            padding_counter_1<=padding_counter_1+1'b1;
                        end
                end
        end
end

assign padding_flag_2=(padding_counter_2==padding-1'b1); //* will be high when padding is done
always @(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            padding_counter_2<='b0;
        end
    else
        begin
                begin
                    if(padding_flag_2 || start_op)
                        begin
                            padding_counter_2<='b0;
                        end 
                    else if (start_padding_2) //*if       (row_size_counter==row_size-1'b1)  //*(!padding_flag)
                        begin
                            padding_counter_2<=padding_counter_2+1'b1;
                        end
                end
        end
end




assign row_size_flag=(row_size_counter==row_size-1'b1); //* will be high when row size is done

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                row_size_counter<='b0;
            end
        else
            begin
                if(row_size_flag && filter_channel_flag)
                    begin
                        row_size_counter<='b0;
                    end
                else if(start_op && filter_channel_flag)
                    begin
                        row_size_counter<=row_size_counter+1'b1;
                    end
            end
    end

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                start_op<='b0;
            end
        else
            begin
                if(EX_End || row_size_flag && filter_channel_flag)
                    begin
                        start_op<='b0;
                    end
                else if(start_loading_row )//*|| padding_flag_1)
                    begin
                        start_op<='b1;
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
              if(EX_Enabel)
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
              if(EX_Enabel)
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

//*assign data_address=data_temp_address_1;


always @(*)
    begin
        if(filter_channel_max==1)
            begin
                data_temp2_flag=((filter_channel_max-1'b1)==filter_channel_counter);

                data_address=window_size_counter;
            end
        else
            begin
                data_temp2_flag=((filter_channel_max-2'b10)==filter_channel_counter);
                data_address=data_temp_address_1;
            end
    end
//*assign data_temp2_flag=((filter_channel_max-2'b10)==filter_channel_counter);

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
    




 //! end of EX


always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                EX_End_temp<='b0;
            end
        else 
            begin
                    if(filter_number_flag && window_size_flag )
                        begin
                            EX_End_temp<=1'b1;
                        end
                    else //*if(padding_flag_2)
                        begin
                            EX_End_temp<=1'b0;
                        end
            end
    end

 assign weights_read_en=start_op; //* will be high when EX_enable and zero when EX end
 assign data_read_en=start_op; //* will be high when EX_enable and zero when EX end
 assign EX_End=EX_End_temp; //* will be high when EX_end is done



reg [1:0] Current_state,Next_state; //* state machine to control the operation of the module

parameter IDLE=2'b00,Padding_1=2'b01,Loading_Row=2'b10,Padding_2=2'b11; //* states of the module

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Current_state<=IDLE;
            end
        else
            begin
                Current_state<=Next_state;
            end
    end

always @(*)
    begin
        case(Current_state)
            IDLE:
                begin
                    if(EX_Enabel)
                        begin
                            Next_state=Padding_1;
                        end
                    else
                        begin
                            Next_state=IDLE;
                        end
                end

            Padding_1:
                begin
                    if(EX_End_temp)
                        begin
                            Next_state=IDLE;
                        end
                    else if(padding_flag_1)
                        begin
                            Next_state=Loading_Row;
                        end
                    else
                        begin
                            Next_state=Padding_1;
                        end
                end

            Loading_Row:
                begin
                    if(row_size_flag && filter_channel_flag)
                        begin
                            Next_state=Padding_2;
                        end
                    else if(EX_End)
                        begin
                            Next_state=IDLE;
                        end
                    else 
                        begin
                            Next_state=Loading_Row;
                        end

                end

            Padding_2:
                begin      
                    if(EX_End_temp)
                        begin
                            Next_state=IDLE;
                        end
                    else if(padding_flag_2)
                        begin
                            Next_state=Padding_1;
                        end
                    else 
                        begin
                            Next_state=Padding_2;
                        end

                end

            default:Next_state=IDLE;

        endcase

    end





always @(*)
    begin
        case(Current_state)
            IDLE:
                begin
                    start_loading_row=1'b0;
                    start_padding_1=1'b0;
                    start_padding_2=1'b0;
                    zero_buffering_en_temp=1'b0;
                    
                end

            Padding_1:
                begin
                    if(padding_flag_1)
                        begin
                            start_loading_row=1'b1;
                           
                        end
                    else
                        begin
                            start_loading_row=1'b0;
                            
                        end

                   //* start_loading_row=1'b0;
                   
                    start_padding_1=1'b1;
                    start_padding_2=1'b0;
                    zero_buffering_en_temp=1'b1;

                end

            Loading_Row:
                begin
                    start_loading_row=1'b1;
                    start_padding_1=1'b0;
                    start_padding_2=1'b0;
                    zero_buffering_en_temp=1'b0;

                //     if(EX_End || (row_size_flag && filter_channel_flag))
                //             begin
                //                 start_loading_row=1'b0;
                //                 start_padding_2=1'b1;
                //             end
                //         else 
                //             begin
                //                 start_loading_row=1'b1;
                //                 start_padding_2=1'b0;
                //             end
                 end

            Padding_2:
                begin
                    start_loading_row=1'b0;
                    start_padding_1=1'b0;
                    start_padding_2=1'b1;
                    zero_buffering_en_temp=1'b1;
                // if(padding_flag_2)
                //     begin
                //         start_padding_1=1'b1;
                //         start_padding_2=1'b0;
                //     end
                // else 
                //     begin
                //         start_padding_2=1'b1;
                //         start_padding_1=1'b0;
                //     end
                 end

            default:begin
                start_loading_row=1'b0;
                start_padding_1=1'b0;
                start_padding_2=1'b0;
                zero_buffering_en_temp=1'b0;
            end
    endcase

    end

assign Zero_Buffering_EN=zero_buffering_en_temp; //* will be high when padding 1 and 2 are done


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