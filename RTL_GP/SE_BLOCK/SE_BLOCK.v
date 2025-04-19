module SE_BLOCK 
#(
parameter Data_Width=14,
parameter FBITS=9,
parameter IN_Burst=16,
parameter IN_WIDTH=Data_Width+12,  //?12 for sum addation bits they are constant
parameter NUM_INSTANCES=32
)
(
    input clk,
    input rst,
    input SE_Enable,
    
    input [13:0] window_size, //*max value 12544

    input [14:0] FC1_Start_addr_weight,FC2_Start_addr_weight,          //max value is 32531 
    input [7:0] FC1_Cell, //max value is 144
    input [9:0] FC2_Cell, //max value is 576                //* also same for averaging
    input [4:0] FC1_Steps,   //* max value is (576/32) 18
    input [2:0] FC2_Steps,          //* max value is (144/32) ~5
    input [5:0] avg_max,           //*(576/16) 36 


     //* Division inputs
    input signed [IN_Burst*IN_WIDTH-1:0] sum_data, //output summation fo Depth_Wise  (//* a)
    input signed [IN_WIDTH-1:0] divisor,           //max value is 56*56 //*(b)
    input Start_Div, //division start 
    //* Multiplication inputs for Fully connected layers
    input wire [NUM_INSTANCES*Data_Width-1:0] Weights,           // Flattened weights for multiplication

    //* outputs 
    output  reg  [14:0] Weights_addr,
    output       [13:0] Data_addr,
    output                     busy,
    output SE_END,
    output weight_read_enable,
    //* multiplication output which is 7 elments from each channel 
    output signed [16*Data_Width-1:0] output_data


);

localparam output_size=NUM_INSTANCES*(Data_Width*2-FBITS); //* this out size of multiplication 
localparam one_out_size=Data_Width*2-FBITS;


//? Division Signals
wire Division_End;//* this done for divsion
wire signed [(16*Data_Width)-1:0] Div_result;
reg signed [Data_Width-1:0] Div_result_array [15:0];

//? Stage_1  && average signals 
reg  signed [Data_Width-1:0] Stage_1 [575:0]; //* will be used for Storing output of divsion and output for FC_2
reg [5:0] avg_counter; 
wire avg_counter_flag;

////////////////////////////////////
//////? Fully connected layer 1 signals//////
/////////////////////////////////////? 
///////////////////////////////////
//! multplication Signals
reg signed [NUM_INSTANCES*Data_Width-1:0]Mul_input_flat;
wire signed [output_size-1:0] Mul_result; 
wire        Mul_data_valid;								//* this out signal for multiplication data valid
reg         Start_mul; //* this flag to start multiplication

//! adder tree signals
wire sum_end_flag;          //* will be deasserted during  Fc1 and FC2 else should be asserted 
wire    sum_data_valid_out;          //* when it high this mean Activation should work
wire signed [Data_Width*2-FBITS+5:0] sum_output;

//! Relu activation function signals 
reg relu_enable;
wire Relu_Activation_Done;
wire signed [Data_Width-1:0] Relu_Activation_OUT;

wire fc1_step_flag; //* this indication for end of reading data stage_1 only for one element ;
wire fc1_cell_flag;
reg [7:0]fc1_cell_counter; //*max is 144
reg [4:0] fc1_step_counter; //* to get values in Stage_1 when 0 firts 32 an ....
//? this indication for end of reading data stage_1 and set start of fc1 to zero
reg [7:0] fc1_counter_read; //* this indication for end of reading data stage_1 enabled by start of FC1 
wire fc1_counter_read_flag;



wire fc2_step_flag;
wire fc2_cell_flag;
//? this indication for end of reading data inner_stage and set start of fc2 to zero
reg [7:0] fc2_counter_read; //* this indication for end of reading data stage_1 enabled by start of FC1 
wire fc2_counter_read_flag;



wire hard_sigmoid_Done;
wire signed [Data_Width-1:0] hard_sigmoid_OUT;


reg  signed [Data_Width-1:0]  Inner_Stage [143:0]; //* storeing intermediated value (output from stage 1) 
reg         [14:0] fc1_addr,fc2_addr; //* addressing weights

reg [2:0]  fc2_step_counter; //* to get values in Inner_Stage when 0 firts 5 an ....

reg  Start_FC1_temp;
reg Start_FC1;
//* each time read weight address must increase Note**SE_Enable should be on for one cycle to catch value of start addressing 
reg [4:0]fc1_rows_counter; //* max value is 18 (when reach max value this mean one cell of Fully connected is finised) increase value of fc1_cell/=
reg [2:0]fc2_rows_counter; //*max value is 5

reg [9:0]fc2_cell_counter; //*max is 576
reg signed[Data_Width-1:0] Mul_input[31:0];


reg Start_FC2_temp;
reg Start_FC2; //* start of second fully connected layer 
reg se_end;
reg start_scaling; //? this flag to start scaling after end of FC2 
reg [5:0] out_counter;
wire out_counter_flag;
wire window_size_flag;

wire  read_en_1;
wire read_en_2;

//! Division unit
div_top #(
    .WIDTH(Data_Width),     // width of dividend and quotient (integer + fractional)
    .FBITS(FBITS),      // fractional bits for dividend and quotient
    .IN_WIDTH(IN_WIDTH)  //?12 for sum addation bits they are constant
)SE_Div_unit (
    .clk(clk),    
    .rst(rst),    
    .start(Start_Div),  
    .busy(busy),   
    .done(Division_End),   
    .dividends(sum_data),  // Packed array of 16 dividends
    .divisor(divisor),      // Common divisor (always positive)
    .results(Div_result)    // Packed array of 16 results
);


//! this for storing output of division in array
integer i;
always @(*) begin
    for( i = 0; i < 16; i=i+1) begin
        Div_result_array[i] = Div_result[i*Data_Width +: Data_Width];
    end
end

//! multiplication unit

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Start_mul<=1'b0;
            end
        else
            begin
                if(Start_FC1 || Start_FC2)
                    begin
                        Start_mul<=1'b1;
                    end
                else
                    begin
                        Start_mul<=1'b0;
                    end
            end
    end

fixed_point_multiplier_top #(.bitsize(Data_Width),.FRAC_BITS(FBITS),.NUM_INSTANCES(NUM_INSTANCES))
SE_Mul_unit_1
(.data_in(Mul_input_flat),
.weights(Weights),
.clk(clk),
.rst(rst),
.start_flag(Start_mul),
.Mul_result(Mul_result),
.valid(Mul_data_valid));

//! Adder tree unit
adder_32 #(
. bitsize(Data_Width),    // Total width (Q7.5 format)
.FRAC_BITS(FBITS),     // Fractional bits
.NUM_INPUTS(NUM_INSTANCES)     // Number of inputs
)SE_Adder_unit(
    .clk(clk),
    .rst(rst),
    .fully_1(Start_FC1),
    .fully_2(Start_FC2),
    .fc1_max_loop(FC1_Steps),
    .fc2_max_loop(FC2_Steps),
    .start_adder(Mul_data_valid),
    .input_numbers(Mul_result), // Signed fixed-point inputs
    .sum_output(sum_output),              // Signed fixed-point output
    .data_valid(sum_data_valid_out)
);


reg [1:0] activation_selector;

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                activation_selector<=2'b00;
            end
        else
            begin
                if(Start_FC1)
                    begin
                        activation_selector<=2'b01;
                    end
                else if(Start_FC2)
                    begin
                        activation_selector<=2'b10;
                    end

            end
    end

reg sigmoid_enable;

always @(*)
begin
    if(activation_selector==2'b01)
        begin
            relu_enable=sum_data_valid_out;
            sigmoid_enable=1'b0;
        end
    else if(activation_selector==2'b10)
        begin
            relu_enable=1'b0;
            sigmoid_enable=sum_data_valid_out;
        end
    else
        begin
            relu_enable=1'b0;
            sigmoid_enable=1'b0;
        end
end


relu #(
.INT_BITS(Data_Width-FBITS),      
.FRAC_BITS(FBITS),     
.DATA_WIDTH(Data_Width)
)SE_RELU_unit(
.clk(clk),
.rst_n(rst),
.enable(relu_enable),
.data_in(sum_output),
.data_out(Relu_Activation_OUT),
.valid(Relu_Activation_Done)
     
);


hard_sigmoid #(
    .DATA_WIDTH(Data_Width),            // Total width of data
    .FRAC_BITS(FBITS)             // Width of fractional part
    
)
SE_Sigmoid_unit(
    .clk(clk),
    .rst(rst),
    .en(sigmoid_enable),
    .input_data(sum_output),  // Fixed point: 1 sign bit, INT_WIDTH integer bits, FRAC_WIDTH fractional bits
    .valid(hard_sigmoid_Done),
    .output_data(hard_sigmoid_OUT)  // Same fixed-point format as input
   
);


 
//* average calculation and storing data from Depth Wise


assign avg_counter_flag = (avg_counter == avg_max-1'b1);
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            avg_counter<=1'b0;
        else 
        begin
            if(avg_counter_flag && Division_End)
                avg_counter<=1'b0;
            else if(Division_End)
                avg_counter<=avg_counter+1'b1;

        end 
    end

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                for(i=0; i<576;i=i+1)
                    Stage_1[i]<=1'b0;
            end     
        
        
        else 
            begin
                
                if(Division_End)
                begin
                    for(i=0;i<16;i=i+1)
                        begin
                            Stage_1[16*avg_counter+i]<= Div_result_array[i];
                        end
                end
                else if(hard_sigmoid_Done)
                    begin
                      
                            
                                Stage_1[fc2_cell_counter]<= hard_sigmoid_OUT; //? this for reuse of Stage_1 for storing output of FC2 after H-Sigmoid
                            
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
                Start_FC1_temp<=1'b0;
            end
        else
            begin
                if(avg_counter_flag && Division_End)
                    Start_FC1_temp<=1'b1;
                else  
                    Start_FC1_temp<=1'b0;
            end
    end

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Start_FC1<=1'b0;
            end
        else
            begin
                if(Start_FC1_temp)
                    Start_FC1<=1'b1;
                else if(fc1_counter_read_flag && fc1_step_flag)
                    Start_FC1<=1'b0;
            end
    end
    

assign fc1_counter_read_flag=(fc1_counter_read==FC1_Cell-1'b1);
always @(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            fc1_counter_read<=1'b0;
        end
    else
        begin
            if(fc1_counter_read_flag && fc1_step_flag)
                begin
                    fc1_counter_read<=1'b0;
                end
            else if(fc1_step_flag && Start_FC1)
                begin
                    fc1_counter_read<=fc1_counter_read+1'b1;
                
                end
        end
end


assign fc1_step_flag=(fc1_step_counter==FC1_Steps-1'b1);

//* counter for steps (32)
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_step_counter<=1'b0;
            end
        else 
            begin
                if(fc1_step_flag)
                    begin
                        fc1_step_counter<=1'b0;
                    end
                else if(Start_FC1)
                    begin
                        fc1_step_counter<=fc1_step_counter+1'b1;
                    end

            end
    end


    

//* this for addressing Elments in Stage_1 && inner stage
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                for(i=0;i<NUM_INSTANCES;i=i+1)
                    Mul_input[i]<='b0;
            end
        else 
            begin
                    //? this is for first fully connected layer
                    if(read_en_1)
                        begin
                            for(i=0;i<NUM_INSTANCES;i=i+1)
                                Mul_input[i]<=Stage_1[fc1_step_counter*NUM_INSTANCES+i];
                            
                        end
                        //? this is for second fully connected layer
                   else if(read_en_2) 
                        begin
                            for(i=0;i<NUM_INSTANCES;i=i+1)
                                Mul_input[i]<=Inner_Stage[fc2_step_counter*NUM_INSTANCES+i];
                            
                        end

            end
    end
//* Flattened output for multiplication 
always @(*) 
begin
    for (i = 0; i < NUM_INSTANCES; i=i+1) 
    begin
        Mul_input_flat[(i*Data_Width) +: Data_Width] = Mul_input[i]; // Correct packing
    end
end



always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_addr<=1'b0;
                fc2_addr<=1'b0;
                
            end
        else
            begin
                if(Start_FC1)
                    begin
                    fc1_addr<=fc1_addr+1'b1;
                    end
                if(Start_FC2)
                    begin
                    fc2_addr<=fc2_addr+1'b1;
                    end
                else if(SE_Enable)//* Note** SE_Enable will be high for one cycle
                begin
                    fc1_addr<=FC1_Start_addr_weight;
                    fc2_addr<=FC2_Start_addr_weight;
                end

                
            end
    end


//* not completed will chose between fc1 & fc2
always @(*)
    begin
        if( Start_FC1_temp || Start_FC1)
            Weights_addr<=fc1_addr;
        else if(Start_FC2_temp || Start_FC2)
            Weights_addr<=fc2_addr;
        else 
            Weights_addr<=0;

    end

//*store activation_out into inner_stage
assign fc1_cell_flag=(fc1_cell_counter==FC1_Cell-1'b1);

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc1_cell_counter<=0;
                for(i=0; i<144;i=i+1)
                    Inner_Stage[i]<=1'b0;
            end
        else
            begin
                
                if(Relu_Activation_Done)
                    begin
                        Inner_Stage[fc1_cell_counter]<=Relu_Activation_OUT;
                        
                    end

                if(fc1_cell_flag && Relu_Activation_Done) 
                    begin
                        fc1_cell_counter<=1'b0;
                    end
                else if(Relu_Activation_Done)
                    begin
                        fc1_cell_counter<=fc1_cell_counter+1'b1;
                    end


            end
    end
///////////////////////////////////
//! Second Fully connected layer
///////////////////////////////////
//* this flag to start Fully connected layer


always @(posedge clk or negedge rst)
    begin
    if(!rst)
        begin
            Start_FC2_temp<=1'b0;
        end
    else
        begin
            if(fc1_cell_flag && Relu_Activation_Done)
                begin
                    Start_FC2_temp<=1'b1;
                end
            else
                begin
                    Start_FC2_temp<=1'b0;
                end
        end
    end
always @(posedge clk or negedge rst )
begin
    if(!rst)
        begin
            Start_FC2<=1'b0;
        end
    else 
        begin
            if(Start_FC2_temp)
                begin
                    Start_FC2<=1'b1;
                end
            else if(fc2_counter_read_flag && fc2_step_flag)
                begin
                    Start_FC2<=1'b0;
                end


        end

end    

assign fc2_counter_read_flag=(fc2_counter_read==FC2_Cell-1'b1);
always @(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            fc2_counter_read<=1'b0;
        end
    else
        begin
            if(fc2_counter_read_flag && fc2_step_flag)
                begin
                    fc2_counter_read<=1'b0;
                end
            else if(fc2_step_flag && Start_FC2)
                begin
                    fc2_counter_read<=fc2_counter_read+1'b1;
                end
        end
end



//* counter for steps (5)
assign fc2_step_flag=(fc2_step_counter==FC2_Steps-1'b1);
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc2_step_counter<=1'b0;
            end
        else 
            begin
                
                if(fc2_step_flag)
                    begin
                        fc2_step_counter<=1'b0;
                    end
                else if(Start_FC2)
                    begin
                        fc2_step_counter<=fc2_step_counter+1'b1;

                    end

            end
    end


assign fc2_cell_flag=(fc2_cell_counter==FC2_Cell-1'b1);

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                fc2_cell_counter<=1'b0;
            end
        else
            begin

                if(fc2_cell_flag && hard_sigmoid_Done)
                    begin
                        fc2_cell_counter<=1'b0;
                    end

                else if(hard_sigmoid_Done)
                    begin
                        fc2_cell_counter<=fc2_cell_counter+1'b1;

                    end

            end
    end







reg start_scaling_temp;
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                start_scaling_temp<=1'b0;
            end 
        else
          begin
                if(fc2_cell_flag && hard_sigmoid_Done)
                    begin
                        start_scaling_temp<=1'b1;
                    end
                else 
                    begin
                        start_scaling_temp<=1'b0;
                    end
          end

    end


always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                start_scaling<=1'b0;
            end
        else
            begin
                if(start_scaling_temp)
                    begin
                        start_scaling<=1'b1;
                    end
                else if(out_counter_flag && window_size_flag)
                    begin
                        start_scaling<=1'b0;
                    end
            end
    end

reg [13:0] window_counter;
reg  [5:0]   out_counter_temp;
wire   out_counter_flag_temp;
assign out_counter_flag_temp=(out_counter_temp==avg_max-1'b1);

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                out_counter_temp<=1'b0;
            end
        else
            begin
                if(out_counter_flag_temp && window_size_flag)
                    begin
                        out_counter_temp<=1'b0;
                    end
                else if(window_counter==window_size-1'b1)
                    begin
                        out_counter_temp<=out_counter_temp+1'b1;
                    end
            end
    end



assign out_counter_flag=(out_counter==avg_max-1'b1);


always @(posedge clk or negedge rst)
begin
    if(!rst)
        begin
            out_counter<=1'b0;
        end
    else    
        begin
             if((out_counter_flag && window_size_flag) || se_end )
                begin
                    out_counter<=1'b0;
                end

            else if(window_size_flag)
                begin
                    out_counter<=out_counter+1'b1;
                end
        end
end





reg signed [Data_Width-1:0] output_data_temp[15:0];
reg signed [16*Data_Width-1:0] output_data_temp_flat;
assign window_size_flag=(window_counter==window_size-1'b1);



always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                window_counter<=1'b0;
            end
        else
            begin
                
                if(window_size_flag || se_end)
                    begin
                        window_counter<=1'b0;
                    end

                else if(start_scaling)
                    begin
                        window_counter<=window_counter+1'b1;
                    end
            end
    end
 
 //! start of scaling is also start for reading data from memory in scalling so 
 //! so it will be delayed for one cycle and also data will be delayed for one cycle
 

/*always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
            for(i=0;i<16;i=i+1)
                output_data_temp[i]<='b0;      
                
            end
        else
            begin
                if(start_scaling || start_scaling_temp)
                    begin
                        for(i=0;i<16;i=i+1)
                            begin
                                output_data_temp[i]<=Stage_1[16*out_counter_temp+i];
                            end
                    end
            end
    end*/


    always @(*)
    begin
   

                if(start_scaling || start_scaling_temp)
                    begin
                        for(i=0;i<16;i=i+1)
                            begin
                                output_data_temp[i]=Stage_1[16*out_counter+i];
                            end
                    end
    end







always @(*) 
begin
    for (i = 0; i < 16; i=i+1) 
    begin
        output_data_temp_flat[i*Data_Width +: Data_Width] = output_data_temp[i]; // Correct packing
    end
end

wire  read_data_enable;
assign read_data_enable=start_scaling;
/*
always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                read_data_enable<=1'b0;
            end
        else
            begin
                read_data_enable<=start_scaling || start_scaling_temp;
            end
    end*/


    
    always @(posedge clk or negedge rst)
        begin
            if(!rst)
                begin
                    se_end<=1'b0;
                end
            else
                begin
                    if(out_counter_flag && window_size_flag)
                        begin
                            se_end<=1'b1;
                        end
                    else
                        begin
                            se_end<=1'b0;
                        end
                end
        end



assign output_data=output_data_temp_flat;
assign SE_END=se_end;
assign Data_addr=window_counter;
assign weight_read_enable=read_en_1 || read_en_2;



//assign read_en_1=Start_FC1 || (avg_counter_flag && Division_End) ;
assign read_en_1=Start_FC1; //*|| Start_FC1_temp ;
assign read_en_2=Start_FC2; //*|| Start_FC2_temp ;

endmodule