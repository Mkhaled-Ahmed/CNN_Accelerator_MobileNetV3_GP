module div_top #(
    parameter WIDTH = 14,     // width of dividend and quotient (integer + fractional)
    parameter FBITS = 7,      // fractional bits for dividend and quotient
    parameter IN_WIDTH=WIDTH+12  //?12 for sum addation bits they are constant
) (
    input wire clk,    
    input wire rst,    
    input wire start,  
    output wire  busy,   
    output wire  done,   
    input wire signed [16*IN_WIDTH-1:0] dividends,  // Packed array of 16 dividends
    input wire signed [IN_WIDTH-1:0] divisor,      // Common divisor (always positive)
    output wire signed [16*WIDTH-1:0] results    // Packed array of 16 results
);
    
    wire [15:0] in_done;
    wire [15:0] in_busy;
    // Generate 16 instances of the divider module
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : div_inst
            div #(
                .OUT_WIDTH(WIDTH),
                .FBITS(FBITS),
                .IN_WIDTH(IN_WIDTH)

            ) div_instance (
                .clk(clk),
                .rst(rst),
                .start(start),
                .busy(in_busy[i]),
                .done(in_done[i]),
                .a(dividends[IN_WIDTH*(i+1)-1 : IN_WIDTH*i]),  // Select appropriate dividend slice
                .b(divisor),
                .val(results[WIDTH*(i+1)-1 : WIDTH*i])   // Select appropriate result slice
            );
        end
    endgenerate
    
    assign done = &in_done;
    assign busy = &in_busy;
    
    endmodule