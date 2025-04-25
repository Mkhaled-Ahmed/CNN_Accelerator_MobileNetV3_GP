module hs_segment(input_data,clk,rst,en,output_data,valid);
    //?Hardswitch segment
    parameter DATA_WIDTH = 32;
    parameter FRAC_BITS = 9;
    parameter OUT_SIZE =18;
    //localparam num3 = 3 * 2**FRAC_BITS;
    input signed [DATA_WIDTH-1:0] input_data;
    input clk,rst,en;
    output signed [OUT_SIZE-1:0] output_data;
    output valid;

    //?Register
    reg valid_temp;
    reg signed [OUT_SIZE-1:0] output_data_temp;
    reg signed [DATA_WIDTH+1-1:0] stage1_out;

    reg signed [(DATA_WIDTH+1)*2-1:0] stage2_out;
    reg signed [DATA_WIDTH-1:0] stage2_in;

    reg signed [(DATA_WIDTH+1)*4-1:0] stage3_out;
    reg signed [DATA_WIDTH-1:0] stage3_in;

    reg signed [DATA_WIDTH-1:0] stage4_out;
    reg signed [DATA_WIDTH-1:0] stage4_in;

    reg signed [DATA_WIDTH-1:0] stage5_in;

    reg stage2_en,stage3_en,stage4_en,stage5_en;

    wire firstbit,otherbits,round;

    always @(posedge clk or negedge rst) begin//? +3
        if(~rst) begin
            stage1_out <= 0;
            stage2_in <= 0;
            stage2_en <= 0;
        end
        else if(en) begin
            stage1_out <= $signed(input_data) + $signed(32'd1536);//* +3.0
            stage2_in <= input_data;
            stage2_en <= 1;
        end
        else stage2_en <= 0;
    end

    always @(posedge clk or negedge rst) begin//? *1/6
        if(~rst) begin
            stage2_out <= 0;
            stage3_in <= 0;
            stage3_en <= 0;
        end
        else if(stage2_en) begin
            stage2_out <= stage1_out * 32'd85;//* 1/6 9 fracrion bit
            //stage2_out <= stage1_out * 26'd43690;//* 1/6 18 fracrion bit
            stage3_in <= stage2_in;
            stage3_en <= 1;
        end
        else stage3_en <= 0;
    end

    always @(posedge clk or negedge rst) begin//? *x
        if(~rst) begin
            stage3_out <= 0;
            stage4_in <= 0;
            stage4_en <= 0;
        end
        else if(stage3_en) begin
            stage3_out <= stage2_out * stage3_in;
            stage4_in <= stage3_in;
            stage4_en <= 1;
        end
        else stage4_en <= 0;
    end

    assign firstbit = stage3_out[FRAC_BITS*2-1];
    assign otherbits= |stage3_out[FRAC_BITS*2-2:0];
    assign round= firstbit&otherbits;
    //assign sign = stage3_out[(DATA_WIDTH+1)*4-1];

    always @(posedge clk or negedge rst)begin//? round
        if(~rst) begin
            stage4_out <= 0;
            stage5_in <= 0;
            stage5_en <= 0;
        end
        else if(stage4_en) begin
            stage5_in <= stage4_in;
            stage5_en <= 1;
            if(!round)begin
                stage4_out <= stage3_out[FRAC_BITS*2+OUT_SIZE-1:FRAC_BITS*2];
            end
            else begin
                stage4_out <= stage3_out[FRAC_BITS*2+OUT_SIZE-1:FRAC_BITS*2]+1'b1;
            end
        end
        else stage5_en <= 0;
    end

    always @(posedge clk or negedge rst) begin//? output
        if(~rst) begin
            output_data_temp <= 0;
            valid_temp <= 0;
        end
        else if(stage5_en) begin
            // output_data_temp <= stage4_out;
            // valid_temp <= 1;
            if($signed(stage5_in) >= $signed(32'd1536)) begin//!! data is 26 bit and we put it in a 14 bit ???
                output_data_temp <= stage5_in[OUT_SIZE-1:0];
                valid_temp <= 1;
            end
            else if($signed(stage5_in) <= $signed(-32'd1536)) begin
                output_data_temp <= 18'd0;
                valid_temp <= 1;
            end
            else begin
                output_data_temp <= stage4_out;
                valid_temp <= 1;
            end
        end
        else begin
            output_data_temp <= 0;
            valid_temp <= 0;
        end
    end

    assign output_data = output_data_temp;
    assign valid = valid_temp;


endmodule