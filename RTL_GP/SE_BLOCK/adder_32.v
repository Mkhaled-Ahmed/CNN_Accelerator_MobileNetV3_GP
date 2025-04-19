module adder_32 #(
    parameter bitsize = 14,
    parameter NUM_INPUTS = 32,  // Changed to 32 inputs
    parameter FRAC_BITS = 7,
    parameter input_size=NUM_INPUTS*(bitsize*2-FRAC_BITS)
)(
    input wire clk,
    input wire rst,
    
    input fully_1,
    input fully_2,
    input [4:0] fc1_max_loop,
    input [2:0] fc2_max_loop,


    input signed [input_size-1:0] input_numbers,
    input wire start_adder,
    output signed[bitsize*2-FRAC_BITS+5:0] sum_output,         // Final sum
    output data_valid
);


    
    // Pipeline stages
    reg signed[bitsize*2-FRAC_BITS+1:0] stage1_sum [0:15];  // Changed to 16 partial sums (16 pairs)
    reg signed[bitsize*2-FRAC_BITS+2:0] stage2_sum [0:7];   // Changed to 8 partial sums
    reg signed[bitsize*2-FRAC_BITS+3:0] stage3_sum [0:3];   // Changed to 4 partial sums
    reg signed[bitsize*2-FRAC_BITS+4:0] stage4_sum [0:1];   // Added new stage for 2 partial sums
    reg signed[bitsize*2-FRAC_BITS+5:0] stage5_sum;         // Final sum
    reg stage2_en;
    reg stage3_en;
    reg stage4_en;
    reg stage5_en;
    reg data_valid_temp;
    reg [1:0] counter_selector;

    reg [4:0] fc1_loop_counter; //*max  (576/32=18)
    reg [2:0] fc2_loop_counter; //*max  (144/32=5)

    wire fc1_loop_done;
    wire fc2_loop_done;
    wire fc1_acc;
    wire fc2_acc;

    reg fully_1_temp2,fully_1_temp3,fully_1_temp4,fully_1_temp5;
    reg fully_2_temp2,fully_2_temp3,fully_2_temp4,fully_2_temp5;


    always @(posedge clk or negedge rst)
        begin
            if(!rst)
                counter_selector <= 0;
            else
                begin
                    if(fully_1)
                        counter_selector <=2'b01;
                    else if(fully_2)
                        counter_selector <= 2'b10;

                end
        end


    assign sum_output = stage5_sum;
    assign data_valid = data_valid_temp;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
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
            stage1_sum[14] <= 0;
            stage1_sum[15] <= 0;
            stage2_en <= 0;
            fully_1_temp2 <= 0;
            fully_2_temp2 <= 0;
        end else begin
            if (start_adder) begin
            // First stage: 16 pairs
            stage1_sum[0] <= $signed(input_numbers[1*(bitsize*2-FRAC_BITS)-1:0]) + $signed(input_numbers[2*(bitsize*2-FRAC_BITS)-1:1*(bitsize*2-FRAC_BITS)]);
            stage1_sum[1] <= $signed(input_numbers[3*(bitsize*2-FRAC_BITS)-1:2*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[4*(bitsize*2-FRAC_BITS)-1:3*(bitsize*2-FRAC_BITS)]);
            stage1_sum[2] <= $signed(input_numbers[5*(bitsize*2-FRAC_BITS)-1:4*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[6*(bitsize*2-FRAC_BITS)-1:5*(bitsize*2-FRAC_BITS)]);
            stage1_sum[3] <= $signed(input_numbers[7*(bitsize*2-FRAC_BITS)-1:6*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[8*(bitsize*2-FRAC_BITS)-1:7*(bitsize*2-FRAC_BITS)]);
            stage1_sum[4] <= $signed(input_numbers[9*(bitsize*2-FRAC_BITS)-1:8*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[10*(bitsize*2-FRAC_BITS)-1:9*(bitsize*2-FRAC_BITS)]);
            stage1_sum[5] <= $signed(input_numbers[11*(bitsize*2-FRAC_BITS)-1:10*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[12*(bitsize*2-FRAC_BITS)-1:11*(bitsize*2-FRAC_BITS)]);
            stage1_sum[6] <= $signed(input_numbers[13*(bitsize*2-FRAC_BITS)-1:12*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[14*(bitsize*2-FRAC_BITS)-1:13*(bitsize*2-FRAC_BITS)]);
            stage1_sum[7] <= $signed(input_numbers[15*(bitsize*2-FRAC_BITS)-1:14*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[16*(bitsize*2-FRAC_BITS)-1:15*(bitsize*2-FRAC_BITS)]);
            stage1_sum[8] <= $signed(input_numbers[17*(bitsize*2-FRAC_BITS)-1:16*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[18*(bitsize*2-FRAC_BITS)-1:17*(bitsize*2-FRAC_BITS)]);
            stage1_sum[9] <= $signed(input_numbers[19*(bitsize*2-FRAC_BITS)-1:18*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[20*(bitsize*2-FRAC_BITS)-1:19*(bitsize*2-FRAC_BITS)]);
            stage1_sum[10] <= $signed(input_numbers[21*(bitsize*2-FRAC_BITS)-1:20*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[22*(bitsize*2-FRAC_BITS)-1:21*(bitsize*2-FRAC_BITS)]);
            stage1_sum[11] <= $signed(input_numbers[23*(bitsize*2-FRAC_BITS)-1:22*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[24*(bitsize*2-FRAC_BITS)-1:23*(bitsize*2-FRAC_BITS)]);
            stage1_sum[12] <= $signed(input_numbers[25*(bitsize*2-FRAC_BITS)-1:24*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[26*(bitsize*2-FRAC_BITS)-1:25*(bitsize*2-FRAC_BITS)]);
            stage1_sum[13] <= $signed(input_numbers[27*(bitsize*2-FRAC_BITS)-1:26*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[28*(bitsize*2-FRAC_BITS)-1:27*(bitsize*2-FRAC_BITS)]);
            stage1_sum[14] <= $signed(input_numbers[29*(bitsize*2-FRAC_BITS)-1:28*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[30*(bitsize*2-FRAC_BITS)-1:29*(bitsize*2-FRAC_BITS)]);
            stage1_sum[15] <= $signed(input_numbers[31*(bitsize*2-FRAC_BITS)-1:30*(bitsize*2-FRAC_BITS)]) + $signed(input_numbers[32*(bitsize*2-FRAC_BITS)-1:31*(bitsize*2-FRAC_BITS)]);  // Last pair of inputs
    

            fully_1_temp2 <= fully_1;
            fully_2_temp2 <= fully_2;
 
            stage2_en <= 1;
            end else begin
            stage2_en <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst) begin 
        if (!rst) begin
            stage2_sum[0] <= 0;
            stage2_sum[1] <= 0;
            stage2_sum[2] <= 0;
            stage2_sum[3] <= 0;
            stage2_sum[4] <= 0;
            stage2_sum[5] <= 0;
            stage2_sum[6] <= 0;
            stage2_sum[7] <= 0;
            stage3_en <= 0;
            fully_1_temp3 <= 0;
            fully_2_temp3 <= 0;
        end else begin
            if (stage2_en) begin
                // Second stage: 8 partial sums
                stage2_sum[0] <= $signed(stage1_sum[0]) + $signed(stage1_sum[1]);
                stage2_sum[1] <= $signed(stage1_sum[2]) + $signed(stage1_sum[3]);
                stage2_sum[2] <= $signed(stage1_sum[4]) + $signed(stage1_sum[5]);
                stage2_sum[3] <= $signed(stage1_sum[6]) + $signed(stage1_sum[7]);
                stage2_sum[4] <= $signed(stage1_sum[8]) + $signed(stage1_sum[9]);
                stage2_sum[5] <= $signed(stage1_sum[10]) + $signed(stage1_sum[11]);
                stage2_sum[6] <= $signed(stage1_sum[12]) + $signed(stage1_sum[13]);
                stage2_sum[7] <= $signed(stage1_sum[14]) + $signed(stage1_sum[15]);
                stage3_en <= 1;
                fully_1_temp3 <= fully_1_temp2;
                fully_2_temp3 <= fully_2_temp2;
            end else begin
                stage3_en <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            stage3_sum[0] <= 0;
            stage3_sum[1] <= 0;
            stage3_sum[2] <= 0;
            stage3_sum[3] <= 0;
            stage4_en <= 0;
            fully_1_temp4 <= 0;
            fully_2_temp4 <= 0;
        end else begin
            if (stage3_en) begin
                // Third stage: 4 partial sums
                stage3_sum[0] <= $signed(stage2_sum[0]) + $signed(stage2_sum[1]);
                stage3_sum[1] <= $signed(stage2_sum[2]) + $signed(stage2_sum[3]);
                stage3_sum[2] <= $signed(stage2_sum[4]) + $signed(stage2_sum[5]);
                stage3_sum[3] <= $signed(stage2_sum[6]) + $signed(stage2_sum[7]);
                stage4_en <= 1;
                fully_1_temp4 <= fully_1_temp3;
                fully_2_temp4 <= fully_2_temp3;
            end else begin
                stage4_en <= 0;
            end 
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            stage4_sum[0] <= 0;
            stage4_sum[1] <= 0;
            stage5_en <= 0;
            fully_1_temp5 <= 0;
            fully_2_temp5 <= 0;
        end else begin
            if (stage4_en) begin
                // Fourth stage: 2 partial sums
                stage4_sum[0] <= $signed(stage3_sum[0]) + $signed(stage3_sum[1]);
                stage4_sum[1] <= $signed(stage3_sum[2]) + $signed(stage3_sum[3]);
                stage5_en <= 1;
                fully_1_temp5 <= fully_1_temp4;
                fully_2_temp5 <= fully_2_temp4;
            end else begin
                stage5_en <= 0;

            end
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            stage5_sum <= 0;
            data_valid_temp <= 0;
        end else begin

                if((fc1_loop_done && (counter_selector==2'b01) ) || (fc2_loop_done && (counter_selector==2'b10) ))
                    data_valid_temp <= stage5_en;
                else 
                    data_valid_temp <= 0;
            
            if (stage5_en) begin
                // Final stage: combine last 2 sums\
                if(fc1_acc || fc2_acc)
                    stage5_sum <= $signed(stage4_sum[0]) + $signed(stage4_sum[1]);
                else 
                    stage5_sum <= $signed(stage4_sum[0]) + $signed(stage4_sum[1]) + $signed(stage5_sum);
        end
    end
    end

    assign fc1_acc= (fc1_loop_counter==0) && (counter_selector==2'b01);
    assign fc2_acc= (fc2_loop_counter==0) && (counter_selector==2'b10);

    
    assign fc1_loop_done = (fc1_loop_counter == fc1_max_loop-1'b1);
    assign fc2_loop_done = (fc2_loop_counter == fc2_max_loop-1'b1);

    always @(posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            fc1_loop_counter <= 0;
            fc2_loop_counter <= 0;
        end
        else
        begin
          //  if (start_adder)
           // begin                               
                if (stage5_en) begin
                    if(fc1_loop_done)
                        fc1_loop_counter <= 0;
                    else
                        fc1_loop_counter <= fc1_loop_counter + 1'b1;

                    if(fc2_loop_done)
                        fc2_loop_counter <= 0;
                    else
                        fc2_loop_counter <= fc2_loop_counter + 1'b1;
                end
                
        //end
    end
    end


endmodule
