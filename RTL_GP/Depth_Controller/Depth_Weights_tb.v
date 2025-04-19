`timescale 1ns / 1ps

module Depth_Weights_tb;

    // Parameters
    parameter Data_Width = 14;
    parameter height =2480;
    parameter Num_Files = 25;
    parameter Row_Length =1;
    parameter Total_Values = Num_Files * Row_Length;
    parameter Total_Width = Total_Values * Data_Width;
    parameter address_width = 12; // Address width (for 1024 locations, 10 bits are needed)

    // Inputs
    reg signed [Total_Width-1:0] data_in;
    reg clk;
    reg [address_width-1:0] index;
    reg en;
    reg rd;
    reg wr;
    reg rst;

    // Outputs
    wire signed [25*16*Data_Width-1:0] data_out;
       

    // Instantiate the Unit Under Test (UUT)
    Depth_Weights_Top #(
        .Data_Width(Data_Width),
        .height(height),
        .address_width(address_width)
    ) depth_weights_mem (
        .data_in(data_in),
        .clk(clk),
        .index(index),
        .en(en),
        .rd(rd),
        .wr(wr),
        .rst(rst),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // File and data declarations
    integer file_handles [0:Num_Files-1];
    reg [256*8-1:0] file_names [0:Num_Files-1];
   
    integer i, j, status;
        reg signed [Data_Width-1:0] data0   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data1   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data2   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data3   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data4   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data5   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data6   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data7   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data8   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data9   ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data10  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data11  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data12  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data13  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data14  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data15  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data16  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data17  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data18  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data19  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data20  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data21  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data22  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data23  ;   // Array to store 1 number
        reg signed [Data_Width-1:0] data24  ;   // Array to store 1 number
    // Local flag to check EOF status per file
    integer eof_flag;

    // Test stimulus
    initial begin
        // Initialize signals
        data_in = 0;
        index = 0;
        en = 0;
        rd = 0;
        wr = 0;
        rst = 0;

        // File paths;
        file_names[0]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped1.txt";
        file_names[1]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped2.txt";
        file_names[2]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped3.txt";
        file_names[3]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped4.txt";
        file_names[4]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped5.txt";
        file_names[5]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped6.txt";
        file_names[6]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped7.txt";
        file_names[7]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped8.txt";
        file_names[8]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped9.txt";
        file_names[9]  = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped10.txt";
        file_names[10] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped11.txt";
        file_names[11] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped12.txt";
        file_names[12] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped13.txt";
        file_names[13] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped14.txt";
        file_names[14] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped15.txt";
        file_names[15] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped16.txt";
        file_names[16] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped17.txt";
        file_names[17] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped18.txt";
        file_names[18] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped19.txt";
        file_names[19] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped20.txt";
        file_names[20] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped21.txt";
        file_names[21] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped22.txt";
        file_names[22] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped23.txt";
        file_names[23] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped24.txt";
        file_names[24] = "D:/GRADUATION_PROJECT/CONTROLLER/GroupedConv_Weights/Grouped25.txt";       
        // Reset
        #10 rst = 1;
        

        // Load data from files
        for (j = 0; j < Num_Files; j = j + 1) begin
            file_handles[j] = $fopen(file_names[j], "r");
            if (file_handles[j] == 0) begin
                $display("Error: Could not open file %s!", file_names[j]);
                $finish;
                end
        end

        index = 0;
        @(negedge clk);
                en = 1;
                wr = 1;

        while (!$feof(file_handles[0])) begin
                // Read 32 numbers into the array
                  // Synchronize with clock

                //* file0
                    status = $fscanf(file_handles[0], "%d", data0);

                
                //* file1
                    status = $fscanf(file_handles[1], "%d", data1);

                //* file2
                    status = $fscanf(file_handles[2], "%d", data2);
                             
                //* file3
                    status = $fscanf(file_handles[3], "%d", data3);
                    
                //* file4       
                    status = $fscanf(file_handles[4], "%d", data4);

                //* file5
                    status = $fscanf(file_handles[5], "%d", data5);
 
                //* file6       
                    status = $fscanf(file_handles[6], "%d", data6);
 
                
                //* file7
                    status = $fscanf(file_handles[7], "%d", data7);
                     
                //* file8
                    status = $fscanf(file_handles[8], "%d", data8);
                     
                //* file9
                    status = $fscanf(file_handles[9], "%d", data9);
                     
                //* file10
                    status = $fscanf(file_handles[10], "%d", data10);
                     
                //* file11
                    status = $fscanf(file_handles[11], "%d", data11);
                     
                //* file12  
                    status = $fscanf(file_handles[12], "%d", data12);
                     
                //* file13
                    status = $fscanf(file_handles[13], "%d", data13);
                     
                //* file14
                    status = $fscanf(file_handles[14], "%d", data14);
                     
                //* file15
                    status = $fscanf(file_handles[15], "%d", data15);
                     
                //* file16
                    status = $fscanf(file_handles[16], "%d", data16);
                     
                //* file17
                    status = $fscanf(file_handles[17], "%d", data17);
                     
                //* file18
                    status = $fscanf(file_handles[18], "%d", data18);
                     
                //* file19      
                    status = $fscanf(file_handles[19], "%d", data19);
                     
                //* file20  
                    status = $fscanf(file_handles[20], "%d", data20);
                     
                //* file21                      
                    status = $fscanf(file_handles[21], "%d", data21);
                     
                //* file22  
                    status = $fscanf(file_handles[22], "%d", data22);
                     
                //* file23  
                    status = $fscanf(file_handles[23], "%d", data23);
                     
                //* file24  
                    status = $fscanf(file_handles[24], "%d", data24);
                     
                // Check for end of file    
             


      


                //* Assign the read data to data_in
       
                data_in = {data24, data23, data22, data21, data20, data19, data18, data17,
                            data16, data15, data14, data13, data12, data11, data10, data9,
                            data8,  data7,  data6,  data5,  data4,  data3,  data2,  data1,
                            data0};

                @(negedge clk);
                // Increase index after reading the row
                index = index + 1;

             
                
        end
   
        en = 0;
        wr = 0;

        // Close all file handles
        for (j = 0; j < Num_Files; j = j + 1) begin
            $fclose(file_handles[j]);
        end
#20;
 @(posedge clk);
        en = 1;
        rd = 1;
        index = 0;

    @(posedge clk);
    repeat(15)
        begin
            index = index + 1;
            @(posedge clk);
        end

        // Stop simulation
        
        en = 0;
        rd = 0;
        #10;
        $stop;

    end


endmodule
