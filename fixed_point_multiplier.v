module fixed_point_multiplier #(
    parameter WIDTH = 14,        // Total width of inputs
    parameter FRAC_BITS = 7      // Number of fractional bits
)(
    input wire clk,
    input wire rst,
    input wire signed [WIDTH-1:0] a,    // First signed input
    input wire signed [WIDTH-1:0] b,    // Second signed input
    output reg signed [WIDTH-1:0] Mul_result // Rounded result
);

    // Internal signals for full multiplication result
    reg signed [2*WIDTH-1:0] full_mult;
    wire signed [2*WIDTH-1:0] shifted_result;
    wire round_bit;
    wire sticky_bit;
    wire sign;
    reg signed [WIDTH-1:0] result;
    
    // Store sign for rounding decisions
    assign sign = full_mult[2*WIDTH-1];
    
    // Perform full signed multiplication
    always @(*) begin
        full_mult = $signed(a) * $signed(b);
    end
    
    // Align decimal point
    assign shifted_result = full_mult >>> FRAC_BITS;
    
    // Extract rounding information
    // Round bit is the last bit we'll drop
    assign round_bit = full_mult[FRAC_BITS-1];
    
    // Sticky bit is OR of all lower bits
    assign sticky_bit = |full_mult[FRAC_BITS-2:0];
    
    // Rounding logic with sign handling
    always @(*) begin
        // Default: truncate
        result = shifted_result[WIDTH-1:0];
        
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
            if (shifted_result[2*WIDTH-1:WIDTH-1] != {WIDTH{1'b1}}) begin
                result = {1'b1, {(WIDTH-1){1'b0}}}; // Min negative value
            end
        end else begin
            // Positive overflow
            if (shifted_result[2*WIDTH-1:WIDTH-1] != {WIDTH{1'b0}}) begin
                result = {1'b0, {(WIDTH-1){1'b1}}}; // Max positive value
            end
        end
    end


always @(posedge clk or negedge rst)
    begin
        if(!rst)
            begin
                Mul_result<='b0;
            end
        else 
            begin
                Mul_result<=result;
            end
    end
endmodule