module adder_27 #(
    parameter DATA_WIDTH = 14,
    parameter NUM_INPUTS = 27
)(
    input wire clk,
    input wire reset,
    input wire [NUM_INPUTS*DATA_WIDTH-1:0] input_numbers,
    output reg [DATA_WIDTH-1:0] sum_output,
    output reg data_valid
);
    // Pipeline stages
    reg [DATA_WIDTH+4:0] stage1_sum [0:13];  // Changed to 14 partial sums (13 pairs + 1 single)
    reg [DATA_WIDTH+4:0] stage2_sum [0:6];   // Changed to 7 partial sums
    reg [DATA_WIDTH+4:0] stage3_sum [0:3];   // Changed to 4 partial sums
    reg [DATA_WIDTH+4:0] stage4_sum [0:1];   // Added new stage for 2 partial sums
    reg [DATA_WIDTH+4:0] stage5_sum;         // Final sum

    // State machine for pipeline control
    reg [2:0] pipeline_state;
    localparam 
        STAGE1 = 3'b001,
        STAGE2 = 3'b010,
        STAGE3 = 3'b011,
        STAGE4 = 3'b100,
        STAGE5 = 3'b101,
        COMPLETE = 3'b110;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pipeline_state <= STAGE1;
            data_valid <= 0;
        end else begin
            case (pipeline_state)
                STAGE1: begin
                    // First stage: 13 pairs + 1 single number
                    stage1_sum[0] = input_numbers[0+:DATA_WIDTH] + input_numbers[DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[1] = input_numbers[2*DATA_WIDTH+:DATA_WIDTH] + input_numbers[3*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[2] = input_numbers[4*DATA_WIDTH+:DATA_WIDTH] + input_numbers[5*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[3] = input_numbers[6*DATA_WIDTH+:DATA_WIDTH] + input_numbers[7*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[4] = input_numbers[8*DATA_WIDTH+:DATA_WIDTH] + input_numbers[9*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[5] = input_numbers[10*DATA_WIDTH+:DATA_WIDTH] + input_numbers[11*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[6] = input_numbers[12*DATA_WIDTH+:DATA_WIDTH] + input_numbers[13*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[7] = input_numbers[14*DATA_WIDTH+:DATA_WIDTH] + input_numbers[15*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[8] = input_numbers[16*DATA_WIDTH+:DATA_WIDTH] + input_numbers[17*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[9] = input_numbers[18*DATA_WIDTH+:DATA_WIDTH] + input_numbers[19*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[10] = input_numbers[20*DATA_WIDTH+:DATA_WIDTH] + input_numbers[21*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[11] = input_numbers[22*DATA_WIDTH+:DATA_WIDTH] + input_numbers[23*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[12] = input_numbers[24*DATA_WIDTH+:DATA_WIDTH] + input_numbers[25*DATA_WIDTH+:DATA_WIDTH];
                    stage1_sum[13] = input_numbers[26*DATA_WIDTH+:DATA_WIDTH];  // Last single input
                    
                    pipeline_state <= STAGE2;
                end

                STAGE2: begin
                    // Second stage: 7 partial sums
                    stage2_sum[0] = stage1_sum[0] + stage1_sum[1];
                    stage2_sum[1] = stage1_sum[2] + stage1_sum[3];
                    stage2_sum[2] = stage1_sum[4] + stage1_sum[5];
                    stage2_sum[3] = stage1_sum[6] + stage1_sum[7];
                    stage2_sum[4] = stage1_sum[8] + stage1_sum[9];
                    stage2_sum[5] = stage1_sum[10] + stage1_sum[11];
                    stage2_sum[6] = stage1_sum[12] + stage1_sum[13];
                    
                    pipeline_state <= STAGE3;
                end

                STAGE3: begin
                    // Third stage: 4 partial sums
                    stage3_sum[0] = stage2_sum[0] + stage2_sum[1];
                    stage3_sum[1] = stage2_sum[2] + stage2_sum[3];
                    stage3_sum[2] = stage2_sum[4] + stage2_sum[5];
                    stage3_sum[3] = stage2_sum[6];
                    
                    pipeline_state <= STAGE4;
                end

                STAGE4: begin
                    // Fourth stage: 2 partial sums
                    stage4_sum[0] = stage3_sum[0] + stage3_sum[1];
                    stage4_sum[1] = stage3_sum[2] + stage3_sum[3];
                    
                    pipeline_state <= STAGE5;
                end

                STAGE5: begin
                    // Final stage: combine last 2 sums
                    stage5_sum = stage4_sum[0] + stage4_sum[1];
                    
                    // Truncate to 12 bits
                    sum_output <= stage5_sum[DATA_WIDTH-1:0];
                    data_valid <= 1;

                    pipeline_state <= COMPLETE;
                end

                COMPLETE: begin
                    data_valid <= 0;
                    pipeline_state <= STAGE1;
                end
            endcase
        end
    end
endmodule