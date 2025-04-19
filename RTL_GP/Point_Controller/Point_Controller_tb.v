`timescale 1ns / 1ps
module Point_Controller_tb;










//! Controller signals
reg clk_tb,rst_tb, Point_Enabel_tb;

 
    reg     [9:0]   W_start_address_tb;
    reg     [3:0]   filter_channel_max_tb;   
    reg     [5:0]   filter_number_max_tb;      
    reg     [13:0]  window_size_max_tb;  
    reg     [1:0]   padding_tb;
    reg     [6:0]   row_size_tb;
    reg             activation_function_enable_tb;
    wire    [9:0]   weights_address_tb;
    wire    [13:0]  write_data_address_tb;
    wire    [12:0]  read_data_address_tb;

    wire            Point_End_tb;
    wire            weight_read_en_tb;
    wire            data_read_en_tb;
    wire            data_write_en_tb;
 
    
    Point_Controller #()
    Point_Controller_unite(

    .clk(clk_tb),
    .rst(rst_tb),
    .Point_Enabel(Point_Enabel_tb),
    .W_start_address(W_start_address_tb),
    .filter_channel_max(filter_channel_max_tb),  
    .filter_number_max(filter_number_max_tb),   
    .window_size_max(window_size_max_tb),
    .weights_address(weights_address_tb),
    .read_data_address(read_data_address_tb),
    .Point_End(Point_End_tb),
    .activation_function_enable(activation_function_enable_tb),
    .weights_read_en(weight_read_en_tb),
    .data_read_en(data_read_en_tb),
    .data_write_en(data_write_en_tb),
    .write_data_address(write_data_address_tb)
    

);

always 
begin
#5 clk_tb=~clk_tb;
end

initial begin
    clk_tb=1'b0;
    rst_tb=1'b0;
    Point_Enabel_tb=1'b0;
    W_start_address_tb='b0;
    filter_channel_max_tb=1;   
    filter_number_max_tb=1;      
    window_size_max_tb=3136;
    activation_function_enable_tb=1'b0;

    @(negedge clk_tb)
    rst_tb=1'b1;
    Point_Enabel_tb=1'b1;


   @(negedge clk_tb)
    Point_Enabel_tb=1'b0;
 
 #50;
 activation_function_enable_tb=1'b1;

    while (!Point_End_tb) begin
           @(negedge clk_tb);
    end

    #60;
/*
    W_start_address_tb='b0;
    filter_channel_max_tb=1;   
    filter_number_max_tb=1;      
    window_size_max_tb=14'd12544;
    row_size_tb=7'd112;

    @(negedge clk_tb)
    Point_Enabel_tb=1'b1;
       @(negedge clk_tb)
    Point_Enabel_tb=1'b0;

     while (!Point_End_tb) begin
           @(negedge clk_tb);
    end
        #500
        */

            $stop;
      
    

end

endmodule