`timescale 1ns / 1ps
module EX_Controller_tb;

//! Memory signals

    // Parameters
    parameter Data_Width = 14;
    parameter height = 657;
    parameter Num_Files = 16;
    parameter Row_Length = 16;
    parameter Total_Values = Num_Files * Row_Length;
    parameter Total_Width = Total_Values * Data_Width;



    reg signed [Total_Width-1:0] data_in;
    reg [10:0] index;
    reg en;
    reg rd;
    reg wr;
 
        // Outputs
    wire signed [Total_Width-1:0] data_out;

    reg signed [Data_Width-1:0] weights_output_array[0:255];
integer t;

    always @(*)
    begin
        for(t=0;t<256;t=t+1)
            begin
                weights_output_array[t] = data_out[t*Data_Width +: Data_Width];
            end
    end

integer file_handles [0:Num_Files-1];
    reg [256*8-1:0] file_names [0:Num_Files-1];
   
    integer i, j, status;
        reg signed [Data_Width-1:0] data0 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data1 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data2 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data3 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data4 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data5 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data6 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data7 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data8 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data9 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data10 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data11 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data12 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data13 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data14 [Row_Length-1:0];  // Array to store 16 numbers
        reg signed [Data_Width-1:0] data15 [Row_Length-1:0];  // Array to store 16 numbers
    // Local flag to check EOF status per file
    integer eof_flag;

//! Controller signals
reg clk_tb,rst_tb, EX_Enabel_tb;

 
    reg     [9:0]   W_start_address_tb;
    reg     [3:0]   filter_channel_max_tb;   
    reg     [5:0]   filter_number_max_tb;      
    reg     [13:0]  window_size_max_tb;  
    reg     [1:0]   padding_tb;
    reg     [6:0]   row_size_tb;
    wire    [9:0]   weights_address_tb;
    wire    [13:0]  data_address_tb;
    wire            EX_End_tb;
    wire            weight_read_en_tb;
    wire            data_read_en_tb;
    wire            Zero_Buffering_EN_tb;
    wire            Multplication_EN_tb;
    EX_Controller_Test #()
    EX_Controller_unite(

    .clk(clk_tb),
    .rst(rst_tb),
    .EX_Enabel(EX_Enabel_tb),
    .W_start_address(W_start_address_tb),
    .filter_channel_max(filter_channel_max_tb),  
    .filter_number_max(filter_number_max_tb),   
    .window_size_max(window_size_max_tb),
    .weights_address(weights_address_tb),
    .data_address(data_address_tb),
    .EX_End(EX_End_tb),
    .weights_read_en(weight_read_en_tb),
    .data_read_en(data_read_en_tb),
    .padding(padding_tb),
    .row_size(row_size_tb),
    .Zero_Buffering_EN(Zero_Buffering_EN_tb),
    .Multplication_EN(Multplication_EN_tb)
);





    Memory_1x1_EX_bneck #(
        .Data_Width(Data_Width),
        .height(height)
    ) uut (
        .data_in(data_in),
        .clk(clk_tb),
        .index(index),
        .en(en),
        .rd(weight_read_en_tb),
        .wr(wr),
        .rst(rst),
        .data_out(data_out)
    );





always @(*)
begin
    if(weight_read_en_tb)
        begin
             index= weights_address_tb;
        end
end

always 
begin
#5 clk_tb=~clk_tb;
end

initial begin


 // Initialize signals
  clk_tb=1'b0;
        data_in = 0;
        index = 0;
        en = 0;
        rd = 0;
        wr = 0;
        rst_tb = 0;

        // File paths
        file_names[0]  = "D:\\GRADUATION_PROJECT\\CONTROLLER\\Weights_1x1\\Expand_Row1.txt";
        file_names[1]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row2.txt";
        file_names[2]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row3.txt";
        file_names[3]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row4.txt";
        file_names[4]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row5.txt";
        file_names[5]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row6.txt";
        file_names[6]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row7.txt";
        file_names[7]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row8.txt";
        file_names[8]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row9.txt";
        file_names[9]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row10.txt";
        file_names[10] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row11.txt";
        file_names[11] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row12.txt";
        file_names[12] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row13.txt";
        file_names[13] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row14.txt";
        file_names[14] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row15.txt";
        file_names[15] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Expand_Row16.txt";
#10;
        // Reset
        rst_tb = 1;
        

        // Load data from files
        for (j = 0; j < Num_Files; j = j + 1) begin
            file_handles[j] = $fopen(file_names[j], "r");
            if (file_handles[j] == 0) begin
                $display("Error: Could not open file %s!", file_names[j]);
                $finish;
                end
        end

        index = 0;
        @(negedge clk_tb);
                en = 1;
                wr = 1;

        while (!$feof(file_handles[0])) begin
                // Read 32 numbers into the array
                  // Synchronize with clock

                //* file0
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[0], "%d", data0[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                
                //* file1
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[1], "%d", data1[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end
        
                //* file2
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[2], "%d", data2[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file3
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[3], "%d", data3[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file4       
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[4], "%d", data4[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file5
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[5], "%d", data5[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file6       
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[6], "%d", data6[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end
                
                //* file7
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[7], "%d", data7[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file8
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[8], "%d", data8[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file9
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[9], "%d", data9[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file10
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[10], "%d", data10[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file11

                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[11], "%d", data11[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file12
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[12], "%d", data12[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file13
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[13], "%d", data13[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file14
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[14], "%d", data14[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* file15
                for (i = 0; i < Row_Length; i = i + 1) begin
                    status = $fscanf(file_handles[15], "%d", data15[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end

                //* Assign the read data to data_in
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[i*Data_Width +: Data_Width] = data0[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(Row_Length+i)*Data_Width +: Data_Width] = data1[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(2*Row_Length+i)*Data_Width +: Data_Width] = data2[i];
                end     
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(3*Row_Length+i)*Data_Width +: Data_Width] = data3[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(4*Row_Length+i)*Data_Width +: Data_Width] = data4[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(5*Row_Length+i)*Data_Width +: Data_Width] = data5[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(6*Row_Length+i)*Data_Width +: Data_Width] = data6[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(7*Row_Length+i)*Data_Width +: Data_Width] = data7[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(8*Row_Length+i)*Data_Width +: Data_Width] = data8[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(9*Row_Length+i)*Data_Width +: Data_Width] = data9[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(10*Row_Length+i)*Data_Width +: Data_Width] = data10[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(11*Row_Length+i)*Data_Width +: Data_Width] = data11[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(12*Row_Length+i)*Data_Width +: Data_Width] = data12[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(13*Row_Length+i)*Data_Width +: Data_Width] = data13[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(14*Row_Length+i)*Data_Width +: Data_Width] = data14[i];
                end
                for (i = 0; i < Row_Length; i = i + 1) begin
                    data_in[(15*Row_Length+i)*Data_Width +: Data_Width] = data15[i];
                end
                // Synchronize with clock
                
                @(negedge clk_tb);
                // Increase index after reading the row
                index = index + 1;

             
                
        end
   
      
        wr = 0;

        // Close all file handles
        for (j = 0; j < Num_Files; j = j + 1) begin
            $fclose(file_handles[j]);
        end

        // Stop simulation
        #100;







@(negedge clk_tb);

    //! controller test bencn

    EX_Enabel_tb=1'b0;
    W_start_address_tb='b0;
    filter_channel_max_tb=6;   
    filter_number_max_tb=36;      
    window_size_max_tb=784;
    padding_tb=2'b10;
    row_size_tb=7'd7;

    @(negedge clk_tb)
    EX_Enabel_tb=1'b1;


   @(negedge clk_tb)
    EX_Enabel_tb=1'b0;
 

    while (!EX_End_tb) begin
           @(negedge clk_tb);
    end

    #100;

    W_start_address_tb='b0;
    filter_channel_max_tb=1;   
    filter_number_max_tb=1;      
    window_size_max_tb=14'd12544;
    padding_tb=2'b01;
    row_size_tb=7'd112;

    @(negedge clk_tb)
    EX_Enabel_tb=1'b1;
       @(negedge clk_tb)
    EX_Enabel_tb=1'b0;

     while (!EX_End_tb) begin
           @(negedge clk_tb);
    end
        #100
            $stop;
        
    

end

endmodule