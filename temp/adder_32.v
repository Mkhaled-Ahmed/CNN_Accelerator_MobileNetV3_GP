/*

module adder_32 #(
    parameter DATA_WIDTH = 12,
    parameter NUM_INPUTS = 32
)(
    input wire clk,
    input wire reset,
    input wire data_valid_in,
    input wire end_flag,
    input wire [NUM_INPUTS*DATA_WIDTH-1:0] input_numbers,
    output reg [DATA_WIDTH-1:0] sum_output,
    output reg data_valid_out
);
    // Internal width for calculations
    localparam INTERNAL_WIDTH = DATA_WIDTH + 6;
    
    // Pipeline stage registers
    reg [INTERNAL_WIDTH-1:0] stage1_sums [0:15];
    reg [INTERNAL_WIDTH-1:0] stage2_sums [0:7];
    reg [INTERNAL_WIDTH-1:0] stage3_sums [0:3];
    reg [INTERNAL_WIDTH-1:0] stage4_sums [0:1];
    reg [INTERNAL_WIDTH-1:0] final_sum;
    
    // Valid flags for each stage
    reg [5:0] valid_pipeline;
    reg [NUM_INPUTS*DATA_WIDTH-1:0] input_reg;
    
    integer i;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline stages
            for (i = 0; i < 16; i = i + 1) stage1_sums[i] <= 0;
            for (i = 0; i < 8; i = i + 1) stage2_sums[i] <= 0;
            for (i = 0; i < 4; i = i + 1) stage3_sums[i] <= 0;
            for (i = 0; i < 2; i = i + 1) stage4_sums[i] <= 0;
            final_sum <= 0;
            sum_output <= 0;
            data_valid_out <= 0;
            valid_pipeline <= 0;
            input_reg <= 0;
        end else begin
            // Input stage - register inputs when valid
            if (data_valid_in) begin
                input_reg <= input_numbers;
            end
            
            // Shift valid signal through pipeline
            valid_pipeline <= {valid_pipeline[4:0], data_valid_in};
            
            // Stage 1: First level additions
            if (valid_pipeline[0]) begin
                for (i = 0; i < 16; i = i + 1) begin
                    stage1_sums[i] <= {{(INTERNAL_WIDTH-DATA_WIDTH){1'b0}}, input_reg[(2*i)*DATA_WIDTH +: DATA_WIDTH]} +
                                    {{(INTERNAL_WIDTH-DATA_WIDTH){1'b0}}, input_reg[(2*i+1)*DATA_WIDTH +: DATA_WIDTH]};
                end
            end
            
            // Stage 2: Second level additions
            if (valid_pipeline[1]) begin
                for (i = 0; i < 8; i = i + 1) begin
                    stage2_sums[i] <= stage1_sums[2*i] + stage1_sums[2*i+1];
                end
            end
            
            // Stage 3: Third level additions
            if (valid_pipeline[2]) begin
                for (i = 0; i < 4; i = i + 1) begin
                    stage3_sums[i] <= stage2_sums[2*i] + stage2_sums[2*i+1];
                end
            end
            
            // Stage 4: Fourth level additions
            if (valid_pipeline[3]) begin
                stage4_sums[0] <= stage3_sums[0] + stage3_sums[1];
                stage4_sums[1] <= stage3_sums[2] + stage3_sums[3];
            end
            
            // Stage 5: Final addition
            if (valid_pipeline[4]) begin
                final_sum <= stage4_sums[0] + stage4_sums[1];
            end
            
            // Output stage
            data_valid_out <= valid_pipeline[5];
            if (valid_pipeline[5]) begin
                sum_output <= final_sum[DATA_WIDTH-1:0];
            end
            
            // Handle end flag
            if (end_flag) begin
                valid_pipeline <= 0;
                data_valid_out <= 0;
            end
        end
    end
endmodule
*/


module adder_32 #(
    parameter DATA_WIDTH = 12,    // Total width (Q7.5 format)
    parameter FRAC_WIDTH = 5,     // Fractional bits
    parameter NUM_INPUTS = 32     // Number of inputs
)(
    input wire clk,
    input wire reset,
    input wire data_valid_in,
    input wire end_flag,
    input wire signed [NUM_INPUTS*DATA_WIDTH-1:0] input_numbers, // Signed fixed-point inputs
    output reg signed [DATA_WIDTH-1:0] sum_output,              // Signed fixed-point output
    output reg data_valid_out
);
    // Internal width for calculations to prevent overflow
    localparam INTERNAL_WIDTH = DATA_WIDTH + 6; // Extra bits for summing 32 values
    
    // Pipeline stage registers
    reg signed [INTERNAL_WIDTH-1:0] stage1_sums [0:15];
    reg signed [INTERNAL_WIDTH-1:0] stage2_sums [0:7];
    reg signed [INTERNAL_WIDTH-1:0] stage3_sums [0:3];
    reg signed [INTERNAL_WIDTH-1:0] stage4_sums [0:1];
    reg signed [INTERNAL_WIDTH-1:0] final_sum;
    reg signed [INTERNAL_WIDTH-1:0] rounded_sum;
    
    // Valid flags for each stage
    reg [6:0] valid_pipeline;  // Added one more bit for rounding stage
    reg signed [NUM_INPUTS*DATA_WIDTH-1:0] input_reg;
    
    // Rounding logic signals - declared outside always block
    reg round_up;
    wire [FRAC_WIDTH-2:0] sticky_bits;
    wire round_bit;
    wire sticky_bit;
    
    // Extract rounding bits
    assign round_bit = final_sum[FRAC_WIDTH-1];
    assign sticky_bits = final_sum[FRAC_WIDTH-2:0];
    assign sticky_bit = |sticky_bits;
    
    integer i;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline stages
            for (i = 0; i < 16; i = i + 1) stage1_sums[i] <= 0;
            for (i = 0; i < 8; i = i + 1) stage2_sums[i] <= 0;
            for (i = 0; i < 4; i = i + 1) stage3_sums[i] <= 0;
            for (i = 0; i < 2; i = i + 1) stage4_sums[i] <= 0;
            final_sum <= 0;
            rounded_sum <= 0;
            sum_output <= 0;
            data_valid_out <= 0;
            valid_pipeline <= 0;
            input_reg <= 0;
            round_up <= 0;
        end else begin
            // Input stage - register inputs when valid
            if (data_valid_in) begin
                input_reg <= input_numbers;
            end
            
            // Shift valid signal through pipeline
            valid_pipeline <= {valid_pipeline[5:0], data_valid_in};
            
            // Stage 1: First level additions
            if (valid_pipeline[0]) begin
                for (i = 0; i < 16; i = i + 1) begin
                    stage1_sums[i] <= $signed(input_reg[(2*i)*DATA_WIDTH +: DATA_WIDTH]) +
                                    $signed(input_reg[(2*i+1)*DATA_WIDTH +: DATA_WIDTH]);
                end
            end
            
            // Stage 2: Second level additions
            if (valid_pipeline[1]) begin
                for (i = 0; i < 8; i = i + 1) begin
                    stage2_sums[i] <= stage1_sums[2*i] + stage1_sums[2*i+1];
                end
            end
            
            // Stage 3: Third level additions
            if (valid_pipeline[2]) begin
                for (i = 0; i < 4; i = i + 1) begin
                    stage3_sums[i] <= stage2_sums[2*i] + stage2_sums[2*i+1];
                end
            end
            
            // Stage 4: Fourth level additions
            if (valid_pipeline[3]) begin
                stage4_sums[0] <= stage3_sums[0] + stage3_sums[1];
                stage4_sums[1] <= stage3_sums[2] + stage3_sums[3];
            end
            
            // Stage 5: Final addition
            if (valid_pipeline[4]) begin
                final_sum <= stage4_sums[0] + stage4_sums[1];
            end
            
            // Stage 6: Rounding stage
            if (valid_pipeline[5]) begin
                // Determine if we should round up
                round_up <= (round_bit && sticky_bit) || 
                           (round_bit && !sticky_bit && final_sum[FRAC_WIDTH]);
                
                // Apply rounding
                rounded_sum <= round_up ? 
                             (final_sum + (1 << (FRAC_WIDTH - 1))) : 
                             final_sum;
                
                $display("Final Sum (before rounding): %b", final_sum);
                $display("Round bit: %b, Sticky bit: %b", round_bit, sticky_bit);
            end
            
            // Stage 7: Output stage
            if (valid_pipeline[6]) begin
                sum_output <= rounded_sum >>> FRAC_WIDTH;
                data_valid_out <= 1'b1;
                $display("Sum Output (after rounding and shifting): %b", sum_output);
            end else begin
                data_valid_out <= 1'b0;
            end
            
            // Handle end flag
            if (end_flag) begin
                valid_pipeline <= 0;
                data_valid_out <= 0;
            end
        end
    end
endmodule