module adder_27 #(
    parameter bitsize = 14,
    parameter NUM_INPUTS = 27,
    parameter FRAC_BITS = 7
)(
    input wire clk,
    input wire rst,
    input signed  [NUM_INPUTS*bitsize-1:0] input_numbers,
    input wire start_adder,
    output signed[bitsize+6:0] sum_output,         // Final sum
    output data_valid

    //output reg signed [bitsize-1:0] sum_output,
    //output reg data_data_valid
);
    // Pipeline stages
    reg signed[bitsize+6:0] stage1_sum [0:13];  // Changed to 14 partial sums (13 pairs + 1 single)
    reg signed[bitsize+6:0] stage2_sum [0:6];   // Changed to 7 partial sums
    reg signed[bitsize+6:0] stage3_sum [0:3];   // Changed to 4 partial sums
    reg signed[bitsize+6:0] stage4_sum [0:1];   // Added new stage for 2 partial sums
    reg signed[bitsize+6:0] stage5_sum;         // Final sum
    reg stage2_en;
    reg stage3_en;
    reg stage4_en;
    reg stage5_en;
    reg round_en;
    //reg data_data_valid;
    //reg signed [bitsize-1:0] result;


    reg sign;
    reg round_bit;
    reg sticky_bit;

assign sum_output = stage5_sum;
assign data_valid = stage5_en;

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
                stage1_sum[0] <= $signed(input_numbers[0+:bitsize]) + $signed(input_numbers[bitsize+:bitsize]);
                stage1_sum[1] <= $signed(input_numbers[2*bitsize+:bitsize]) + $signed(input_numbers[3*bitsize+:bitsize]);
                stage1_sum[2] <= $signed(input_numbers[4*bitsize+:bitsize]) + $signed(input_numbers[5*bitsize+:bitsize]);
                stage1_sum[3] <= $signed(input_numbers[6*bitsize+:bitsize]) + $signed(input_numbers[7*bitsize+:bitsize]);
                stage1_sum[4] <= $signed(input_numbers[8*bitsize+:bitsize]) + $signed(input_numbers[9*bitsize+:bitsize]);
                stage1_sum[5] <= $signed(input_numbers[10*bitsize+:bitsize]) + $signed(input_numbers[11*bitsize+:bitsize]);
                stage1_sum[6] <= $signed(input_numbers[12*bitsize+:bitsize]) + $signed(input_numbers[13*bitsize+:bitsize]);
                stage1_sum[7] <= $signed(input_numbers[14*bitsize+:bitsize]) + $signed(input_numbers[15*bitsize+:bitsize]);
                stage1_sum[8] <= $signed(input_numbers[16*bitsize+:bitsize]) + $signed(input_numbers[17*bitsize+:bitsize]);
                stage1_sum[9] <= $signed(input_numbers[18*bitsize+:bitsize]) + $signed(input_numbers[19*bitsize+:bitsize]);
                stage1_sum[10] <= $signed(input_numbers[20*bitsize+:bitsize]) + $signed(input_numbers[21*bitsize+:bitsize]);
                stage1_sum[11] <= $signed(input_numbers[22*bitsize+:bitsize]) + $signed(input_numbers[23*bitsize+:bitsize]);
                stage1_sum[12] <= $signed(input_numbers[24*bitsize+:bitsize]) + $signed(input_numbers[25*bitsize+:bitsize]);
                stage1_sum[13] <= $signed(input_numbers[26*bitsize+:bitsize]);  // Last single input
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
            round_en<=0;
        end else begin
                if(stage5_en)begin
                    // Final stage: combine last 2 sums
                    stage5_sum <= $signed(stage4_sum[0]) + $signed(stage4_sum[1]);
                    round_en <= 1;
                end
                else begin
                    round_en <= 0;
                end
        end
    end
    ////!round block
    // always @(posedge clk or negedge rst) begin
    //     if (!rst) begin
    //         sum_output <= 0;
    //         data_valid <= 0;
    //     end else begin
    //         if (round_en) begin
    //             data_valid <= 1;
    //             // Extract sign bit
    //             sign = stage5_sum[bitsize+4]; 
    
    //             // Extract rounding bit and sticky bit
    //             round_bit = stage5_sum[FRAC_BITS-1];  
    //             sticky_bit = |stage5_sum[FRAC_BITS-2:0];  
    
    //             // Initial truncated result
    //             result = stage5_sum[bitsize-1:0];
    
    //             // Round to nearest even
    //             if (round_bit && (sticky_bit || result[0])) begin
    //                 result = result + 1'b1;
    //             end
    
    //             // Handle saturation
    //             if (sign) begin
    //                 if (stage5_sum[bitsize+4:bitsize-1] != {bitsize{1'b1}}) begin
    //                     result = {1'b1, {(bitsize-1){1'b0}}}; // Min negative value
    //                 end
    //             end else begin
    //                 if (stage5_sum[bitsize+4:bitsize-1] != {bitsize{1'b0}}) begin
    //                     result = {1'b0, {(bitsize-1){1'b1}}}; // Max positive value
    //                 end
    //             end
    
    //             // Assign final rounded result
    //             sum_output <= result;
    //         end else begin
    //             data_valid <= 0;
    //         end
    //     end
    // end
    
endmodule







// module adder_27 #(
//     parameter bitsize = 14,
//     parameter NUM_INPUTS = 27
// )(
//     input wire clk,
//     input wire rst,
//     input signed  [NUM_INPUTS*bitsize-1:0] input_numbers,
//     output reg signed [bitsize-1:0] sum_output,
//     output reg data_valid
// );
//     // Pipeline stages
//     reg [bitsize+4:0] stage1_sum [0:13];  // Changed to 14 partial sums (13 pairs + 1 single)
//     reg [bitsize+4:0] stage2_sum [0:6];   // Changed to 7 partial sums
//     reg [bitsize+4:0] stage3_sum [0:3];   // Changed to 4 partial sums
//     reg [bitsize+4:0] stage4_sum [0:1];   // Added new stage for 2 partial sums
//     reg [bitsize+4:0] stage5_sum;         // Final sum

//     // State machine for pipeline control
//     reg [2:0] pipeline_state;
//     localparam 
//         STAGE1 = 3'b001,
//         STAGE2 = 3'b010,
//         STAGE3 = 3'b011,
//         STAGE4 = 3'b100,
//         STAGE5 = 3'b101,
//         COMPLETE = 3'b110;

//     always @(posedge clk or negedge rst) begin
//         if (!rst) begin
//             pipeline_state <= STAGE1;
//             data_valid <= 0;
//         end else  begin
//             case (pipeline_state)
//                 STAGE1: begin
//                     // First stage: 13 pairs + 1 single number
//                     stage1_sum[0] = input_numbers[0+:bitsize] + input_numbers[bitsize+:bitsize];
//                     stage1_sum[1] = input_numbers[2*bitsize+:bitsize] + input_numbers[3*bitsize+:bitsize];
//                     stage1_sum[2] = input_numbers[4*bitsize+:bitsize] + input_numbers[5*bitsize+:bitsize];
//                     stage1_sum[3] = input_numbers[6*bitsize+:bitsize] + input_numbers[7*bitsize+:bitsize];
//                     stage1_sum[4] = input_numbers[8*bitsize+:bitsize] + input_numbers[9*bitsize+:bitsize];
//                     stage1_sum[5] = input_numbers[10*bitsize+:bitsize] + input_numbers[11*bitsize+:bitsize];
//                     stage1_sum[6] = input_numbers[12*bitsize+:bitsize] + input_numbers[13*bitsize+:bitsize];
//                     stage1_sum[7] = input_numbers[14*bitsize+:bitsize] + input_numbers[15*bitsize+:bitsize];
//                     stage1_sum[8] = input_numbers[16*bitsize+:bitsize] + input_numbers[17*bitsize+:bitsize];
//                     stage1_sum[9] = input_numbers[18*bitsize+:bitsize] + input_numbers[19*bitsize+:bitsize];
//                     stage1_sum[10] = input_numbers[20*bitsize+:bitsize] + input_numbers[21*bitsize+:bitsize];
//                     stage1_sum[11] = input_numbers[22*bitsize+:bitsize] + input_numbers[23*bitsize+:bitsize];
//                     stage1_sum[12] = input_numbers[24*bitsize+:bitsize] + input_numbers[25*bitsize+:bitsize];
//                     stage1_sum[13] = input_numbers[26*bitsize+:bitsize];  // Last single input
                    
//                     pipeline_state <= STAGE2;
//                 end

//                 STAGE2: begin
//                     // Second stage: 7 partial sums
//                     stage2_sum[0] = stage1_sum[0] + stage1_sum[1];
//                     stage2_sum[1] = stage1_sum[2] + stage1_sum[3];
//                     stage2_sum[2] = stage1_sum[4] + stage1_sum[5];
//                     stage2_sum[3] = stage1_sum[6] + stage1_sum[7];
//                     stage2_sum[4] = stage1_sum[8] + stage1_sum[9];
//                     stage2_sum[5] = stage1_sum[10] + stage1_sum[11];
//                     stage2_sum[6] = stage1_sum[12] + stage1_sum[13];
                    
//                     pipeline_state <= STAGE3;
//                 end

//                 STAGE3: begin
//                     // Third stage: 4 partial sums
//                     stage3_sum[0] = stage2_sum[0] + stage2_sum[1];
//                     stage3_sum[1] = stage2_sum[2] + stage2_sum[3];
//                     stage3_sum[2] = stage2_sum[4] + stage2_sum[5];
//                     stage3_sum[3] = stage2_sum[6];
                    
//                     pipeline_state <= STAGE4;
//                 end

//                 STAGE4: begin
//                     // Fourth stage: 2 partial sums
//                     stage4_sum[0] = stage3_sum[0] + stage3_sum[1];
//                     stage4_sum[1] = stage3_sum[2] + stage3_sum[3];
                    
//                     pipeline_state <= STAGE5;
//                 end

//                 STAGE5: begin
//                     // Final stage: combine last 2 sums
//                     stage5_sum = stage4_sum[0] + stage4_sum[1];
                    
//                     // Truncate to 12 bits
//                     sum_output <= stage5_sum[bitsize-1:0];
//                     data_valid <= 1;

//                     pipeline_state <= COMPLETE;
//                 end

//                 COMPLETE: begin
//                     data_valid <= 1;
//                     pipeline_state <= STAGE1;
//                 end
//             endcase
//         end
//     end
// endmodule