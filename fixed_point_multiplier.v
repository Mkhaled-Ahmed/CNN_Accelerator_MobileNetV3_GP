module fixed_point_multiplier(a,b,rst,start_flag,clk,Mul_result,valid);
    parameter bitsize = 14;        // Total bitsize of inputs
    parameter FRAC_BITS = 7;      // Number of fractional bits

    input wire clk;
    input wire rst;
    input start_flag;

    input wire signed [bitsize-1:0] a;    // First signed input
    input wire signed [bitsize-1:0] b;    // Second signed input
    
    
    output signed [bitsize-1:0] Mul_result; // Rounded result
    output valid; // Rounded result
    // Internal signals for full multiplication result
    reg signed [2*bitsize-1:0] full_mult;
    wire signed [2*bitsize-1:0] shifted_result;
    wire round_bit;
    wire sticky_bit;
    wire sign;
    reg signed [bitsize-1:0] result;
    reg valid_temp;
    reg signed [bitsize-1:0] Mul_result_temp;
    
    // Store sign for rounding decisions
    assign sign = full_mult[2*bitsize-1];
    
    // Perform full signed multiplication
    always @(*) begin
        if(start_flag)begin
            full_mult = $signed(a) * $signed(b);
        end
        else begin
            full_mult=0;
        end
    end
    
    // Align decimal point
    assign shifted_result = full_mult >>> FRAC_BITS;
    
    // Extract rounding information
    // Round bit is the last bit we'll drop
    //! 000000000011110000000_0_000000
    assign round_bit = full_mult[FRAC_BITS-1];
    
    // Sticky bit is OR of all lower bits
    assign sticky_bit = |full_mult[FRAC_BITS-2:0];
    
    // Rounding logic with sign handling
    always @(*) begin
        if(start_flag)begin
        // Default: truncate
        result = shifted_result[bitsize-1:0];
        
        // Round to nearest even, considering sign
        if (round_bit && (sticky_bit || result[0])) begin
            if (!sign) begin
                // For positive numbers, round up
                result = result + 1'b1;
            end else begin
                // For negative numbers, round down (more negative)
                result = result - 1'b1;
            end
        end
        // Saturate if overflow occurs
        if (sign) begin
            // Negative overflow
            if (shifted_result[2*bitsize-1:bitsize-1] != {bitsize{1'b1}}) begin
                result = {1'b1, {(bitsize-1){1'b0}}}; // Min negative value
            end
        end else begin
            // Positive overflow
            if (shifted_result[2*bitsize-1:bitsize-1] != {bitsize{1'b0}}) begin
                result = {1'b0, {(bitsize-1){1'b1}}}; // Max positive value
            end
        end
    end
    else begin
        result=0;
    end
end


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
                Mul_result_temp<=result;
            end
            else begin
                valid_temp<=0;
                Mul_result_temp<=0;
            end
        end
    end

    assign Mul_result= Mul_result_temp;
    assign valid=valid_temp;
endmodule   