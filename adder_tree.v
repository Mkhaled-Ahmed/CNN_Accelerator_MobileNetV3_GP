module adder_27 #(
    parameter bitsize = 14,
    parameter NUM_INPUTS = 27,
    parameter FRAC_BITS = 7
)(
    clk,
    rst,
    input_numbers,
    start_adder,
    sum_output,
    data_valid,
    bias
    //output reg signed [data_size-1:0] sum_output,
    //output reg data_data_valid
);
localparam data_size = bitsize*2+FRAC_BITS;

input wire clk;
input wire rst;
input signed  [bitsize-1:0] bias;
input signed  [NUM_INPUTS*data_size-1:0] input_numbers;
input wire start_adder;
output signed[data_size+6:0] sum_output;         // Final sum
output data_valid;

    
    // Pipeline stages
    reg signed[data_size+5:0] stage1_sum [0:13];  // Changed to 14 partial sums (13 pairs + 1 single)
    reg signed[data_size+5:0] stage2_sum [0:6];   // Changed to 7 partial sums
    reg signed[data_size+5:0] stage3_sum [0:3];   // Changed to 4 partial sums
    reg signed[data_size+5:0] stage4_sum [0:1];   // Added new stage for 2 partial sums
    reg signed[data_size+5:0] stage5_sum;         // Final sum
    reg stage2_en;
    reg stage3_en;
    reg stage4_en;
    reg stage5_en;
    reg data_valid_temp;
    //reg data_data_valid;
    //reg signed [data_size-1:0] result;


    reg sign;
    reg round_bit;
    reg sticky_bit;

assign sum_output = stage5_sum;
assign data_valid = data_valid_temp;

    always @(posedge clk or negedge rst)begin
        if(!rst)begin
            stage1_sum[0] <= 0;
            stage1_sum[1] <= 0;
            stage1_sum[2] <= 0;
            stage1_sum[3] <= 0;
            stage1_sum[4] <= 0;
            stage1_sum[5] <= 0;
            stage1_sum[6] <= 0;
            stage1_sum[7] <= 0;
            stage1_sum[8] <= 0;
            stage1_sum[9] <= 0;
            stage1_sum[10] <= 0;
            stage1_sum[11] <= 0;
            stage1_sum[12] <= 0;
            stage1_sum[13] <= 0;
            stage2_en<=0;
        end else begin
            if(start_adder)begin
                // First stage: 13 pairs + 1 single number
                stage1_sum[0] <= $signed(input_numbers[0+:data_size]) + $signed(input_numbers[data_size+:data_size]);
                stage1_sum[1] <= $signed(input_numbers[2*data_size+:data_size]) + $signed(input_numbers[3*data_size+:data_size]);
                stage1_sum[2] <= $signed(input_numbers[4*data_size+:data_size]) + $signed(input_numbers[5*data_size+:data_size]);
                stage1_sum[3] <= $signed(input_numbers[6*data_size+:data_size]) + $signed(input_numbers[7*data_size+:data_size]);
                stage1_sum[4] <= $signed(input_numbers[8*data_size+:data_size]) + $signed(input_numbers[9*data_size+:data_size]);
                stage1_sum[5] <= $signed(input_numbers[10*data_size+:data_size]) + $signed(input_numbers[11*data_size+:data_size]);
                stage1_sum[6] <= $signed(input_numbers[12*data_size+:data_size]) + $signed(input_numbers[13*data_size+:data_size]);
                stage1_sum[7] <= $signed(input_numbers[14*data_size+:data_size]) + $signed(input_numbers[15*data_size+:data_size]);
                stage1_sum[8] <= $signed(input_numbers[16*data_size+:data_size]) + $signed(input_numbers[17*data_size+:data_size]);
                stage1_sum[9] <= $signed(input_numbers[18*data_size+:data_size]) + $signed(input_numbers[19*data_size+:data_size]);
                stage1_sum[10] <= $signed(input_numbers[20*data_size+:data_size]) + $signed(input_numbers[21*data_size+:data_size]);
                stage1_sum[11] <= $signed(input_numbers[22*data_size+:data_size]) + $signed(input_numbers[23*data_size+:data_size]);
                stage1_sum[12] <= $signed(input_numbers[24*data_size+:data_size]) + $signed(input_numbers[25*data_size+:data_size]);
                stage1_sum[13] <= $signed(input_numbers[26*data_size+:data_size]) + $signed(bias);  // Last single input
                stage2_en <= 1;
            end
            else begin
                stage2_en <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst)begin 
        if(!rst)begin
            stage2_sum[0] <= 0;
            stage2_sum[1] <= 0;
            stage2_sum[2] <= 0;
            stage2_sum[3] <= 0;
            stage2_sum[4] <= 0;
            stage2_sum[5] <= 0;
            stage2_sum[6] <= 0;
            stage3_en<=0;
        end 
        else begin
            if(stage2_en)begin
                // Second stage: 7 partial sums
                stage2_sum[0] <= $signed(stage1_sum[0]) + $signed(stage1_sum[1]);
                stage2_sum[1] <= $signed(stage1_sum[2]) + $signed(stage1_sum[3]);
                stage2_sum[2] <= $signed(stage1_sum[4]) + $signed(stage1_sum[5]);
                stage2_sum[3] <= $signed(stage1_sum[6]) + $signed(stage1_sum[7]);
                stage2_sum[4] <= $signed(stage1_sum[8]) + $signed(stage1_sum[9]);
                stage2_sum[5] <= $signed(stage1_sum[10]) +$signed( stage1_sum[11]);
                stage2_sum[6] <= $signed(stage1_sum[12]) +$signed( stage1_sum[13]);
                stage3_en <= 1;
            end
            else begin
                stage3_en <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst)begin
        if(!rst)begin
            stage3_sum[0] <= 0;
            stage3_sum[1] <= 0;
            stage3_sum[2] <= 0;
            stage3_sum[3] <= 0;
            stage4_en<=0;
        end else begin
            if(stage3_en)begin
                // Third stage: 4 partial sums
                stage3_sum[0] <= $signed(stage2_sum[0]) + $signed(stage2_sum[1]);
                stage3_sum[1] <= $signed(stage2_sum[2]) + $signed(stage2_sum[3]);
                stage3_sum[2] <= $signed(stage2_sum[4]) + $signed(stage2_sum[5]);
                stage3_sum[3] <= $signed(stage2_sum[6]);
                stage4_en <= 1;
            end
            else begin
                stage4_en <= 0;
            end 
        end
    end

    always@(posedge clk or negedge rst)begin
        if(!rst)begin
            stage4_sum[0] <= 0;
            stage4_sum[1] <= 0;
            stage5_en<=0;
        end else begin
            if(stage4_en)begin
                // Fourth stage: 2 partial sums
                stage4_sum[0] <= $signed(stage3_sum[0]) + $signed(stage3_sum[1]);
                stage4_sum[1] <= $signed(stage3_sum[2]) + $signed(stage3_sum[3]);
                stage5_en <= 1;
            end
            else begin
                stage5_en <= 0;
            end
        end
    end

    always@(posedge clk or negedge rst)begin
        if(!rst)begin
            stage5_sum <= 0;
            data_valid_temp<=0;
        end else begin
                if(stage5_en)begin
                    // Final stage: combine last 2 sums
                    stage5_sum <= $signed(stage4_sum[0]) + $signed(stage4_sum[1]);
                    data_valid_temp <= 1;
                end
                else begin
                    data_valid_temp <= 0;
                end
        end
    end
endmodule