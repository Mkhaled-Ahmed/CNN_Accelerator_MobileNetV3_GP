`timescale 1ns / 1ps

module test_SE_BLOCK;

    // Parameters
    parameter Data_Width = 14;
    parameter FBITS = 9;
    parameter IN_Burst = 16;
    parameter BWIDTH = 12;
    parameter NUM_INSTANCES = 32;
    localparam IN_WIDTH = Data_Width +12; // Input width for the divider

    // Inputs
    reg clk;
    reg rst;
    reg SE_Enable;
    reg [13:0] window_size;
    reg [14:0] FC1_Start_addr_weight;
    reg [14:0] FC2_Start_addr_weight;
    reg [7:0] FC1_Cell;
    reg [9:0] FC2_Cell;
    reg [4:0] FC1_Steps;
    reg [2:0] FC2_Steps;
    reg [5:0] avg_max;
    reg signed [IN_Burst*IN_WIDTH-1:0] sum_data;
    reg signed [IN_WIDTH-1:0] divisor;
    reg Start_Div;
    reg [NUM_INSTANCES*Data_Width-1:0] Weights;

    // Outputs
    wire [14:0] Weights_addr;
    wire [13:0] Data_addr;
    wire busy;
    wire SE_END;
    wire weight_read_enable;
    wire signed [16*Data_Width-1:0] output_data;




    reg [14:0] index;
    reg en;
    reg wr;
    reg signed [NUM_INSTANCES*Data_Width-1:0] data_in;
    wire signed [NUM_INSTANCES*Data_Width-1:0] data_out;
    reg rd;


reg  [2*Data_Width-FBITS-1:0] mul_res_array [NUM_INSTANCES-1:0];
reg [Data_Width-1:0] weights_array [NUM_INSTANCES-1:0];


    
    integer file;   
    reg signed [Data_Width-1:0] data [31:0];  // Array to store 32 numbers
    integer  status;

    integer i,k;
always @(*) begin
    for( i = 0; i < 32; i=i+1) begin
        mul_res_array[i] = uut.SE_Mul_unit_1.Mul_result[i*(2*Data_Width-FBITS)+: (2*Data_Width-FBITS)];
    end
end

always @(*) begin
    for( i = 0; i < 32; i=i+1) begin
        weights_array[i] = memory.Fully_Weigths_Mem_Top.data_out[i*(Data_Width)+: (Data_Width)];
    end
end


always @(*) begin   
    if(weight_read_enable)
        index=Weights_addr;


end




    Fully_Weigths_Mem_Top memory
    (.data_in(data_in),
    .clk(clk),
    .index(index),
    .en(en),
    .rd(weight_read_enable),
    .wr(wr),
    .rst(rst),
    .data_out(data_out)
    );


    // Instantiate the Unit Under Test (UUT)
    SE_BLOCK #(
        .Data_Width(Data_Width),
        .FBITS(FBITS),
        .IN_Burst(IN_Burst),
        .NUM_INSTANCES(NUM_INSTANCES)
    ) uut (
        .clk(clk),
        .rst(rst),
        .SE_Enable(SE_Enable),
        .window_size(window_size),
        .FC1_Start_addr_weight(FC1_Start_addr_weight),
        .FC2_Start_addr_weight(FC2_Start_addr_weight),
        .FC1_Cell(FC1_Cell),
        .FC2_Cell(FC2_Cell),
        .FC1_Steps(FC1_Steps),
        .FC2_Steps(FC2_Steps),
        .avg_max(avg_max),
        .sum_data(sum_data),
        .divisor(divisor),
        .Start_Div(Start_Div),
        .Weights(data_out),
        .Weights_addr(Weights_addr),
        .Data_addr(Data_addr),
        .busy(busy),
        .SE_END(SE_END),
        .weight_read_enable(weight_read_enable),
        .output_data(output_data)
    );



    





    


    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0;
        SE_Enable = 0;
        window_size = 0;
        FC1_Start_addr_weight = 0;
        FC2_Start_addr_weight = 0;
        FC1_Cell = 0;
        FC2_Cell = 0;
        FC1_Steps = 0;
        FC2_Steps = 0;
        avg_max = 0;
        sum_data = 0;
        divisor = 0;
        Start_Div = 0;
        Weights = 0;
     
        
        index = 0;
        en=0;
        wr=0;
        data_in = 0;
        // Reset the system
        rst = 1;
        #10;
        rst = 0;
        #10;
        rst = 1;


  
            file = $fopen("FullyConnected_Weights.txt", "r");  
            if (file == 0) begin
                $display("Error: Could not open file!");
                $finish;
            end
            
            // Wait for 'en' signal to become high
            //wait(en);  

           // index = -1;  // Initialize index to zero before reading the file
            index=0;
                @(negedge clk);
                    en=1;
                    wr=1;
              
            while (!$feof(file)) begin
                // Read 32 numbers into the array
                  // Synchronize with clock
                for (i = 0; i < 32; i = i + 1) begin
                    status = $fscanf(file, "%d", data[i]);
                    // if (status != 1) break;  // Ensure we read valid data
                end
                 
                // Assign the read data to data_in
                for (i = 0; i < 32; i = i + 1) begin
                    data_in[i*Data_Width +: Data_Width] = data[i];
                end
                @(negedge clk);
                // Increase index after reading the row
                index = index + 1;

                if(index==15'd32768)
                    begin
                    index=0;
                    end
                
            end

   
    wr=0;
    $fclose(file);
    #100;



    

        // Test case 1: Basic functionality
        SE_Enable = 1;
        window_size = 14'd3136;
        FC1_Start_addr_weight = 15'd0;
        FC2_Start_addr_weight = 15'd4;
        FC1_Cell = 8'd4;
        FC2_Cell = 10'd16;
        FC1_Steps = 5'd1;
        FC2_Steps = 3'd1;
        avg_max = 6'd01;
        sum_data = {16{26'd12800}}; //*25 * 2^9
        divisor = 26'd1605632; //*56*56*2^9
        Start_Div = 1;
       index=Weights_addr;

        #10;
        Start_Div = 0;
        SE_Enable = 0;

        // Wait for the SE_END signal
        while(!SE_END)
            begin
                @(negedge clk);
            end

        // Check outputs
        $display("Test case 1: Basic functionality");
        $display("Weights_addr: %d", Weights_addr);
        $display("Data_addr: %d", Data_addr);
        $display("busy: %d", busy);
        $display("SE_END: %d", SE_END);
        $display("weight_read_enable: %d", weight_read_enable);
                for (i = 0; i < 16; i = i + 1) begin
            $display("output_data[%0d]: %h", i, output_data[i*Data_Width +: Data_Width]);
            $display("-------------");
        end


#100;



        // Test case 1: Basic functionality
        SE_Enable = 1;
        window_size = 14'd100;
        FC1_Start_addr_weight = 15'd0;
        FC2_Start_addr_weight = 15'd4;
        FC1_Cell = 8'd4;
        FC2_Cell = 10'd16;
        FC1_Steps = 5'd1;
        FC2_Steps = 3'd1;
        avg_max = 6'd01;
        sum_data = {16{26'd17920}}; //*35 * 2^9
        divisor = 26'd1605632;
        Start_Div = 1;
       

        #10;
        Start_Div = 0;
        SE_Enable = 0;

        // Wait for the SE_END signal
        while(!SE_END)
            begin
                @(negedge clk);
            end

        // Check outputs
        $display("Test case 1: Basic functionality");
        $display("Weights_addr: %d", Weights_addr);
        $display("Data_addr: %d", Data_addr);
        $display("busy: %d", busy);
        $display("SE_END: %d", SE_END);
        
        $display("weight_read_enable: %d", weight_read_enable);
        
        for (i = 0; i < 16; i = i + 1) begin
            $display("output_data[%0d]: %h", i, output_data[i*Data_Width +: Data_Width]);
            $display("-------------");

        end
 

 

        // Test case 2: Different parameters
        SE_Enable = 1;
        window_size = 14'd49;
        FC1_Start_addr_weight = 15'd30;
        FC2_Start_addr_weight = 15'd40;
        FC1_Cell = 8'd18;
        FC2_Cell = 10'd72;
        FC1_Steps = 5'd3;
        FC2_Steps = 3'd2;
        avg_max = 6'd5;
        divisor = 26'd401408;
        //Weights = 448'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
        SE_Enable = 0;


        //* in1
        sum_data = {16{26'd17920}}; //* 35* 2^9
        Start_Div = 1;
        #10;
        Start_Div = 0;
        
        while(busy)
            begin
                @(negedge clk);
            end
       //* in2     
        sum_data = {16{-26'd17920}};
        Start_Div = 1;
        #10;
        Start_Div = 0;


        while(busy)
            begin
                @(negedge clk);
            end
       
       //* in3     
        sum_data = {16{26'd17920}};
        Start_Div = 1;
        #10;
        Start_Div = 0;
            
        while(busy)
            begin
                @(negedge clk);
            end
       
       //* in4     
        sum_data = {16{-26'd17920}};
        Start_Div = 1;
        #10;
        Start_Div = 0;


        while(busy)
            begin
                @(negedge clk);
            end
       
       //* in5    
        sum_data = {16{-26'd17920}};
        Start_Div = 1;
        #10;
        Start_Div = 0;


       

k=0;

        repeat(avg_max)
        begin
            wait(uut.window_size_flag)
                begin
                    k=k+1;
                    $display ("num_output %0d",k);
                    $display("Simulation time: %d", $time);
                    for (i = 0; i < 16; i = i + 1) begin
                    $display("output_data[%0d]: %h", i, output_data[i*Data_Width +: Data_Width]);
                    $display("-------------");
                    end
                end
                @(negedge clk);
       

        end

        // Wait for the SE_END signal
        wait(SE_END);

        // Check outputs
        $display("Test case 2: Different parameters");
        $display("Weights_addr: %d", Weights_addr);
        $display("Data_addr: %d", Data_addr);
        $display("busy: %d", busy);
        $display("SE_END: %d", SE_END);
        $display("weight_read_enable: %d", weight_read_enable);
        

    
    #100;
$stop;

    end
endmodule
