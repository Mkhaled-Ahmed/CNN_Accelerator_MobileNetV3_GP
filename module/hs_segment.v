module hs_segment(input_data,clk,rst,en,output_data,valid);
    //?Hardswitch segment
    parameter DATA_WIDTH = 21;
    parameter FRAC_BITS = 7;
    localparam INT_BITS = DATA_WIDTH - FRAC_BITS;
    input signed [DATA_WIDTH-1:0] input_data;
    input clk,rst,en;
    output signed [(DATA_WIDTH+1)*4-1:0] output_data;
    output valid;

    //?Register
    reg signed [DATA_WIDTH+1-1:0] stage1_out;

    reg signed [(DATA_WIDTH+1)*2-1:0] stage2_out;
    reg signed [(DATA_WIDTH+1)*2-1:0] stage2_in;

    reg signed [(DATA_WIDTH+1)*4-1:0] stage3_out;
    reg signed [(DATA_WIDTH+1)*4-1:0] stage3_in;

    reg signed [DATA_WIDTH-1:0] stage4_out;
    reg signed [DATA_WIDTH-1:0] stage4_in;

    reg signed [DATA_WIDTH-1:0] stage5_out;
    reg signed [DATA_WIDTH-1:0] stage5_in;

    reg stage2_en,stage3_en,stage4_en,stage5_en;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            stage1_out <= 0;
            stage2_in <= 0;
            stage2_en <= 0;
        end
        else if(en) begin
            stage1_out <= input_data+21'd384;//*3.0
            stage2_in <= input_data;
            stage2_en <= 1;
        end
        else stage2_en <= 0;
    end

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            stage2_out <= 0;
            stage3_in <= 0;
            stage3_en <= 0;
        end
        else if(stage2_en) begin
            stage2_out <= stage1_out * 22'd21;//* 1/6
            stage3_in <= stage2_in;
            stage3_en <= 1;
        end
        else stage3_en <= 0;
    end

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            stage3_out <= 0;
            stage4_in <= 0;
            stage4_en <= 0;
        end
        else if(stage3_en) begin
            stage3_out <= stage2_out * {16'b0,stage2_in,7'b0};
            stage4_in <= stage3_in;
            stage4_en <= 1;
        end
        else stage4_en <= 0;
    end

    assign output_data = stage3_out;
    assign valid=stage4_en;


endmodule