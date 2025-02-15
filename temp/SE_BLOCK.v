module SE_BLOCK 
#(
parameter Data_Width=14,
parameter FBITS=7,
parameter IN_Burst=16,
parameter BWIDTH = 12,
parameter NUM_INSTANCES=32
)
(
    input clk,
    input rst,
    input SE_Enable,
    
    input [14:0] FC1_Start,FC2_Start, //max value is 32531 
    input [4:0] FC1_Rows,
    input [2:0] FC2_Rows,
    input [7:0] FC1_Cell, //max value is 144
    input [9:0] FC2_Cell, //max value is 576 //* also same for averaging
    input [4:0] FC1_Steps, //* max value is (576/32) 18
    input [2:0] FC2_Steps, //* max value is (144/32) ~5
    input [5:0] avg_max,   //*(576/16) 36

    //*for reading for last stage multiplication and store in memory
    input [2:0] col_read, //* max value is (56/7) 8 
    input [1:0] Row_Start, //* 0 or 1 or 2
    input [5:0] Final_Row, //* max is (padding+window_size-1) also col 
     //* Division inputs
    input signed [0:IN_Burst*Data_Width-1] sum_data, //output summation fo Depth_Wise (//* a)
    input signed [11:0] divisor, //max value is 56*56 //*(b)
    input Start_Div, //division start 
    //* Multiplication inputs for Fully connected layers
    input wire [NUM_INSTANCES*Data_Width-1:0] Weights, // Flattened weights for multiplication

    //* Data from memory to be scalled 
    input signed [7*Data_Width-1:0] data_in ,

    //* outputs 
    output  reg  [14:0] Weights_addr,
    output  reg  [5:0]   R_Row_addr,
    output  reg  [5:0]   W_Row_addr,
    output  reg  [2:0]   R_Col_addr,
    output  reg  [2:0]   W_Col_addr,
    output                     busy,
    //* multiplication output which is 7 elments from each channel 
    output [7*Data_Width-1:0] Final_Data


);



wire Division_End;
wire  Done;
wire fc1_step_max;
wire avg_counter_flag;
wire signed [(16*Data_Width)-1:0] Div_result;
wire fc1_rows_flag;
wire fc2_rows_flag;
wire fc1_cell_flag;
wire signed [NUM_INSTANCES*Data_Width-1:0] Mul_result;
wire        Mul_data_valid;
wire Relu_Activation_Done;
wire signed [Data_Width-1:0] Relu_Activation_OUT;
wire    sum_data_valid_out; //* when it high this mean Activation should work
wire sum_end_flag; //* will be deasserted during  Fc1 and FC2 else should be asserted   
wire signed [Data_Width-1:0] sum_output;


reg  signed [Data_Width-1:0] Stage_1 [575:0] ; //* will be used for Storing output of divsion and output for FC_2
reg  signed [Data_Width-1:0]  Inner_Stage [143:0]; //* storeing intermediated value (output from stage 1) 
reg         [14:0] fc1_addr,fc2_addr; //* addressing weights
reg [4:0] fc1_step_counter; //* to get values in Stage_1 when 0 firts 32 an ....
reg [5:0] avg_counter; 
reg Start_FC1;
//* each time read weight address must increase Note**SE_Enable should be on for one cycle to catch value of start addressing 
reg [4:0]fc1_rows_counter; //* max value is 18 (when reach max value this mean one cell of Fully connected is finised) increase value of fc1_cell/=
reg [2:0]fc2_rows_counter; //*max value is 5
reg [7:0]fc1_cell_counter; //*max is 144
reg signed[Data_Width-1:0] Mul_input[31:0];
reg signed [Data_Width-1:0] Div_result_array [15:0];
reg signed [32*Data_Width-1:0]Mul_input_flat;


div_top #(
    .WIDTH(Data_Width),     // width of dividend and quotient (integer + fractional)
    .FBITS(FBITS),      // fractional bits for dividend and quotient
    .BWIDTH(BWIDTH)     // width of divisor (integer only)
)SE_Div_unit (
    .clk(clk),    
    .rst(rst),    
    .start(Start_Div),  
    .busy(busy),   
    .done(Done),   
    .dividends(sum_data),  // Packed array of 16 dividends
    .divisor(divisor),      // Common divisor (always positive)
    .results(Div_result)    // Packed array of 16 results
);


integer i;
always @(*) begin
    for( i = 0; i < 16; i=i+1) begin
        Div_result_array[i] = Div_result[i*Data_Width +: Data_Width];
    end
end

fixed_point_multiplier_top #(
    .NUM_INSTANCES(NUM_INSTANCES), // Number of multiplier instances
    .WIDTH(Data_Width),         // Bit width of fixed-point numbers
    .FRAC_BITS(FBITS)       // Number of fractional bits
)SE_Mul_unit(
    .clk(clk),
    .rst(rst),
    .a(Weights), // Flattened input A //* weights from memeory
    .b(Mul_input_flat), // Flattened input B
    .data_valid(Mul_data_valid),
    .Mul_result(Mul_result) // Flattened output //* output for Adder Tree
);

adder_32 #(
.DATA_WIDTH(Data_Width),    // Total width (Q7.5 format)
.FRAC_WIDTH(FBITS),     // Fractional bits
.NUM_INPUTS(NUM_INSTANCES)     // Number of inputs
)SE_Adder_unit(
    .clk(clk),
    .reset(rst),
    .data_valid_in(Mul_data_valid),
    .end_flag(sum_end_flag),
    .input_numbers(Mul_result), // Signed fixed-point inputs
    .sum_output(sum_output),              // Signed fixed-point output
    .data_valid_out(sum_data_valid_out)
);

relu #(
.INT_BITS(Data_Width-FBITS),      
.FRAC_BITS(FBITS),     
.DATA_WIDTH(Data_Width)
)SE_RELU_unit(
.clk(clk),
.rst_n(rst),
.enable(sum_data_valid_out),
.data_in(sum_output),
.data_out(Relu_Activation_OUT),
.valid(Relu_Activation_Done)
     
);

/*
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_addr<='b0;
                fc2_addr<='b0;
            end
        else
            begin
                if(SE_Enable)//* Note** SE_Enable will be high for one cycle
                begin
                    fc1_addr<=FC1_Start;
                    fc2_addr<=FC2_Start;
                end
            end
    end
*/
//* average calculation and storing data from Depth Wise


assign avg_counter_flag=(avg_counter==avg_max);
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            avg_counter<='b0;
        else 
        begin
            if(Done)
                avg_counter<=avg_counter+1'b1;
            if(avg_counter_flag)
                avg_counter<='b0;
        end 
    end

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                for(i=0; i<576;i=i+1)
                    Stage_1[i]<='b0;
            end     
        
        
        else 
            begin
                
                if(Done)
                begin
                    for(i=0;i<16;i=i+1)
                        begin
                            Stage_1[16*avg_counter+i]<= Div_result_array[i];
                        end
                end
            end
            
    end
/////////////////////////////////////////
//* first stage of Fully connected layer 
////////////////////////////////////////


//* this flag to start Fully connected layer
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Start_FC1<='b0;
            end
        else
            begin
                if(avg_counter_flag)
                    Start_FC1<='b1;
            end
    end

assign fc1_step_flag=(fc1_step_counter==FC1_Steps);

//* counter for steps (32)
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_step_counter<='b0;
            end
        else 
            begin
                if(Start_FC1)
                    begin
                        fc1_step_counter<=fc1_step_counter+1'b1;
                        if(fc1_step_flag)
                            fc1_step_counter<='b0;
                    end
            end
    end
//* this for addressing Elments in Stage_1
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                for(i=0;i<32;i=i+1)
                    Mul_input[i]<='b0;
            end
        else 
            begin
                    if(Start_FC1)
                        begin
                            for(i=0;i<32;i=i+1)
                                Mul_input[i]<=Stage_1[fc1_step_counter*32+i];
                            
                        end

            end
    end
//* Flattened output for multiplication 
always @(*) 
begin
    for (i = 0; i < 32; i=i+1) 
    begin
        Mul_input_flat[i*Data_Width +: Data_Width] = Mul_input[i]; // Correct packing
    end
end

//* weights reading for FC1 
assign fc1_rows_flag=(fc1_rows_counter==FC1_Rows);

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_rows_counter<='b0;
            end
        else
            begin
                if(Start_FC1)
                begin
                    fc1_rows_counter<=fc1_rows_counter+1'b1;
                        if(fc1_rows_flag)
                            fc1_rows_counter<='b0;
                end
            end
    end


always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_addr<='b0;
                
            end
        else
            begin
                if(Start_FC1)
                    begin
                    fc1_addr<=fc1_addr+1'b1;
                    end

                else if(SE_Enable)//* Note** SE_Enable will be high for one cycle
                begin
                    fc1_addr<=FC1_Start;
                end

                
            end
    end

always @(*)
//* not completed will chose between fc1 & fc2
    begin
        if(Start_FC1)
            Weights_addr=fc1_addr;
    end

//*store activation_out into inner_stage
assign fc1_cell_flag=(fc1_cell_counter==FC1_Cell);

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_cell_counter<='b0;
            end
        else
            begin
                if(Relu_Activation_Done)
                    begin
                        Inner_Stage[fc1_cell_counter]<=Relu_Activation_OUT;
                        fc1_cell_counter<=fc1_cell_counter+1'b1;
                    end
                if(fc1_cell_flag) 
                    begin
                        fc1_cell_counter<='b0;
                    end

            end
    end



endmodule











