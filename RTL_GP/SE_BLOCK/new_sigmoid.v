module hs_segment(input_data,clk,rst,en,output_data,valid);
    //?Hardswitch segment
    parameter DATA_WIDTH = 14;
    parameter FRAC_BITS = 9;
    localparam BIT_SIZE =14;
    //localparam num3 = 3 * 2**FRAC_BITS;
  input signed [DATA_WIDTH*2-FRAC_BITS+5:0] input_data;
    input clk,rst,en;
    output signed [BIT_SIZE-1:0] output_data;
    output valid;
	
	localparam input_width =DATA_WIDTH*2-FRAC_BITS+5+1;

    //?Register
    reg valid_temp;
    reg signed [DATA_WIDTH-1:0] output_data_temp;
    reg signed [(input_width*2)-1:0] stage1_out;

    reg signed [(input_width*2)-1:0] stage2_out;
    reg signed [DATA_WIDTH-1:0] stage2_in;

    reg signed [(DATA_WIDTH+1)*4-1:0] stage3_out;
    reg signed [DATA_WIDTH-1:0] stage3_in;

    reg signed [DATA_WIDTH-1:0] stage4_out;
    reg signed [DATA_WIDTH-1:0] stage4_in;

    reg signed [DATA_WIDTH-1:0] stage5_out;
    reg signed [DATA_WIDTH-1:0] stage5_in;

    reg stage2_en,stage3_en,stage4_en,stage5_en;

    wire firstbit,otherbits,round;

    always @(posedge clk or negedge rst) begin//? *0.2
        if(~rst) begin
            stage1_out <= 0;
            stage2_in <= 0;
            stage2_en <= 0;
        end
        else if(en) begin
            stage1_out <= input_data *25'd102;//* *0.2
            stage2_in <= input_data;
            stage2_en <= 1;
        end
        else stage2_en <= 0;
    end

    always @(posedge clk or negedge rst) begin//? +0.5
        if(~rst) begin
            stage2_out <= 0;
            stage3_in <= 0;
            stage3_en <= 0;
        end
        else if(stage2_en) begin
            stage2_out <= stage1_out +50'd131072;//* 0.5 18 fracrion bit
            //stage2_out <= stage1_out * 26'd43690;//* 1/6 18 fracrion bit
            stage3_in <= stage2_in;
            stage3_en <= 1;
        end
        else stage3_en <= 0;
    end


    assign firstbit = stage2_out[FRAC_BITS-1];
    assign otherbits= |stage2_out[FRAC_BITS-2:0];
    assign round= firstbit&otherbits;
    //assign sign = stage3_out[(DATA_WIDTH+1)*4-1];

    always @(posedge clk or negedge rst)begin//? round
        if(!rst) begin
            stage3_out <= 0;
            stage4_in <= 0;
            stage4_en <= 0;
        end
        else if(stage3_en) begin
            stage4_in <= stage3_in;
            stage4_en <= 1;
            if(!round)begin//1
                stage3_out <= stage2_out[FRAC_BITS*2+DATA_WIDTH-1:FRAC_BITS];
            end
            else begin//0
                stage3_out <= stage2_out[FRAC_BITS*2+DATA_WIDTH-1:FRAC_BITS]+1'b1;
            end
        end
        else stage4_en <= 0;
    end

    always @(posedge clk or negedge rst) begin//? output
        if(~rst) begin
            output_data_temp <= 0;
            valid_temp <= 0;
        end
        else if(stage4_en) begin
            // output_data_temp <= stage4_out;
            // valid_temp <= 1;
            if($signed(stage4_in) >= $signed(26'd1280)) begin
                output_data_temp <= 14'd512;
                valid_temp <= 1;
            end
            else if($signed(stage4_in) <= $signed(-26'd1280)) begin
                output_data_temp <= 14'd0;
                valid_temp <= 1;
            end
            else begin
                output_data_temp <= stage3_out;
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