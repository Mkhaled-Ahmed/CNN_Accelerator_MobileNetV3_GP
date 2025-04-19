module SE_Multiplier_Seg(a,b,rst,start_flag,clk,Mul_result,valid,in_address,out_address);
    parameter bitsize = 14;        // Total bitsize of inputs
    parameter FRAC_BITS = 9;      // Number of fractional bits

    input wire clk;
    input wire rst;
    input start_flag;
    input wire [12:0] in_address; // Address for input data

    input wire signed [bitsize-1:0] a;    // First signed input
    input wire signed [bitsize-1:0] b;    // Second signed input
    

    output wire [12:0] out_address; // Address for output data
    output signed [bitsize-1:0] Mul_result; // Rounded result
    output valid; // Rounded result

    // Internal signals for full multiplication result
    reg valid_temp;
    reg signed [(bitsize*2)-1:0] Mul_result_temp;
    wire signed [(bitsize*2-FRAC_BITS)-1:0] mult_round_temp;
    reg signed [(bitsize*2-FRAC_BITS)-1:0] data_out_temp_1;
    wire firstbit;
    wire otherbits;
    wire sign;

    reg [12:0] out_address_temp_1,out_address_temp_2; // Temporary address for output data
    reg final_valid_temp; // Temporary valid signal for output data
    reg signed [bitsize-1:0] data_out_temp_2; // Temporary data output

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Mul_result_temp<='b0;
                valid_temp<=0;
                out_address_temp_1<=0;
            end
        else begin
            if(start_flag)begin
                valid_temp<=1;
                Mul_result_temp<=a*b;
                out_address_temp_1<=in_address; // Increment input address for output
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
    
  
    
    always @(*) begin
            if(!round)begin//1
                data_out_temp_1= mult_round_temp;
            end
            else begin//0
                data_out_temp_1= mult_round_temp+1'b1;
            end
    end
    //!! the round may cause a timing problem soon will be checked

always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin

                out_address_temp_2<=0;
                final_valid_temp<=0;
                data_out_temp_2<=0;
            end
        else 
            begin
                if(valid_temp)begin
                    out_address_temp_2<=out_address_temp_1; 
                    final_valid_temp<=1;
                    data_out_temp_2<=data_out_temp_1[bitsize-1:0]; // Assign the rounded result to the output

                end
                else begin
                    out_address_temp_2<=0;
                    final_valid_temp<=0;
                    data_out_temp_2<=0; // Assign the rounded result to the output
                end
            end


    end
assign out_address=out_address_temp_2; // Assign the output address
assign valid=final_valid_temp; // Assign the valid signal to the output
assign Mul_result=data_out_temp_2; // Assign the rounded result to the output

endmodule   