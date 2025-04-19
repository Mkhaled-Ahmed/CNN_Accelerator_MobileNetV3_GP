`timescale 1ns / 1ps

module test_Memory_1x1_Point_Bneck_2;

    // Parameters
    parameter Data_Width = 14;
    parameter height = 938;
    parameter Num_Files = 16;
    parameter Row_Length = 16;
    parameter Total_Values = Num_Files * Row_Length;
    parameter Total_Width = Total_Values * Data_Width;

    // Inputs
    reg signed [Total_Width-1:0] data_in;
    reg clk;
    reg [9:0] index;
    reg en;
    reg rd;
    reg wr;
    reg rst;

    // Outputs
    wire signed [Total_Width-1:0] data_out;
       

    // Instantiate the Unit Under Test (UUT)
    Memory_1x1_EX_bneck #(
        .Data_Width(Data_Width),
        .height(height)
    ) point_weights_mem (
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

    // Test stimulus
    initial begin
        // Initialize signals
        data_in = 0;
        index = 0;
        en = 0;
        rd = 0;
        wr = 0;
        rst = 0;

        // File paths
        file_names[0]  = "D:\\GRADUATION_PROJECT\\CONTROLLER\\Weights_1x1\\Pointwise_Row1.txt";
        file_names[1]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row2.txt";
        file_names[2]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row3.txt";
        file_names[3]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row4.txt";
        file_names[4]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row5.txt";
        file_names[5]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row6.txt";
        file_names[6]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row7.txt";
        file_names[7]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row8.txt";
        file_names[8]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row9.txt";
        file_names[9]  = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row10.txt";
        file_names[10] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row11.txt";
        file_names[11] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row12.txt";
        file_names[12] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row13.txt";
        file_names[13] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row14.txt";
        file_names[14] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row15.txt";
        file_names[15] = "D:/GRADUATION_PROJECT/CONTROLLER/Weights_1x1/Pointwise_Row16.txt";

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

        // Stop simulation
        #100;
        $stop;

    end


endmodule
