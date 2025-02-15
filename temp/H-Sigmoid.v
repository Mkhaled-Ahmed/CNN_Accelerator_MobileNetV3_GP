module H_Sigmoid#(
    parameter DATA_WIDTH = 16,   // Q8.8 Fixed-Point
    parameter FRACTION_BITS = 8  // Fraction bits (Q8.8 format)
)(
    input  clk,
    input  rst_n,       // Active-low reset
    input  start,       // Start computation flag
    input  end_flag,    // End flag to disable valid signal
    input  signed [DATA_WIDTH-1:0] x, // Input data (Q8.8 format)
    output reg signed [DATA_WIDTH-1:0] y, // Output data (Q8.8 format)
    output reg valid    // Output valid flag
);

    // Constants in Q format
    localparam signed [DATA_WIDTH-1:0] ONE  = (1 << FRACTION_BITS);  // 1 in Q8.8
    localparam signed [DATA_WIDTH-1:0] HALF = (1 << (FRACTION_BITS - 1)); // 0.5 in Q8.8 (128)
    
    reg signed [DATA_WIDTH-1:0] Mem[200:0];
    // Pipeline registers
    reg signed [DATA_WIDTH-1:0] x_plus_1;
    reg signed [2*DATA_WIDTH-1:0] mult_result;
    reg signed [DATA_WIDTH-1:0] scaled_x;
    reg signed [DATA_WIDTH-1:0] min_x;
    reg [2:0] valid_pipe;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y          <= 0;
            valid      <= 0;
            x_plus_1   <= 0;
            scaled_x   <= 0;
            min_x      <= 0;
            mult_result <= 0;
            valid_pipe <= 3'b000;
        end 
        else begin
            // Stage 1: x + 1
            x_plus_1   <= x + ONE;

            // Stage 2: Multiply by 0.5 (scaling instead of division)
            mult_result <= x_plus_1 * HALF; // Multiply by 0.5
            scaled_x    <= mult_result >> FRACTION_BITS; // Scale back

            // Stage 3: Clamp between 0 and 1
            if (scaled_x > ONE)
                min_x <= ONE; // Clamp to 1
            else
                min_x <= scaled_x;

            if (min_x < 0)
                y <= 0;  // Clamp to 0
            else
                y <= min_x;

            // Valid signal delayed by 3 cycles
            valid_pipe <= {valid_pipe[1:0], start}; // Shift register for valid signal

            valid <= valid_pipe[2] & ~end_flag; // Assert valid after 3 cycles
        end
    end

integer i;
reg [7:0] address;
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        begin
            address<='b0;
            for(i=0;i<201;i=i+1)
                Mem[i]<='b0;  
        end
    else    
        begin
            if(valid)
                begin
                    address<=address+'b1;
                    Mem[address]<=y;
                end
        end

end
endmodule
