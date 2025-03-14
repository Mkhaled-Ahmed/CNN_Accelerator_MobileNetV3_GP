module fixed_point_multiplier(a,b,rst,start_flag,clk,Mul_result,valid);
    parameter bitsize = 14;        // Total bitsize of inputs
    parameter FRAC_BITS = 7;      // Number of fractional bits

    input wire clk;
    input wire rst;
    input start_flag;

    input wire signed [bitsize-1:0] a;    // First signed input
    input wire signed [bitsize-1:0] b;    // Second signed input
    
    
    output signed [(bitsize*2-FRAC_BITS)-1:0] Mul_result; // Rounded result
    output valid; // Rounded result

    // Internal signals for full multiplication result
    reg valid_temp;
    reg signed [(bitsize*2)-1:0] Mul_result_temp;
    wire signed [(bitsize*2-FRAC_BITS)-1:0] mult_round_temp;
    reg signed [(bitsize*2-FRAC_BITS)-1:0] data_out_temp;
    wire firstbit;
    wire otherbits;
    wire sign;

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Mul_result_temp<='b0;
                valid_temp<=0;
            end
        else begin
            if(start_flag)begin
                valid_temp<=1;
                Mul_result_temp<=a*b;
            end
            else begin
                valid_temp<=0;
                Mul_result_temp<=0;
            end
        end
    end

    //01010101000011111
    assign firstbit= Mul_result_temp[FRAC_BITS-1];
    assign otherbits= |Mul_result_temp[FRAC_BITS-2:0];
    assign round= firstbit&otherbits;
    assign sign=Mul_result_temp[2*bitsize-1];    
    assign mult_round_temp= Mul_result_temp[(bitsize*2)-1:FRAC_BITS];//trancate
    assign valid=valid_temp;
    assign Mul_result= data_out_temp;
    
    always @(*) begin
            if(!round)begin//1
                data_out_temp= mult_round_temp;
            end
            else begin//0
                data_out_temp= mult_round_temp+1'b1;
            end
    end
    //!! the round may cause a timing problem soon will be checked

endmodule   