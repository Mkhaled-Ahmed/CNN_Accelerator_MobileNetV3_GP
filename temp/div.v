module div #(
    parameter WIDTH = 14,    // width of dividend and quotient (integer + fractional)
    parameter FBITS = 7,     // fractional bits for dividend and quotient
    parameter BWIDTH = 12    // width of divisor (integer only)
) (
    input wire clk,    
    input wire rst,    
    input wire start,  
    output reg busy,   
    output reg done,   
    input wire signed [WIDTH-1:0] a,    // dividend (14-bit with 7 fraction bits)
    input wire signed [BWIDTH-1:0] b,   // divisor (12-bit integer, always positive)
    output reg signed [WIDTH-1:0] val   // result (14-bit with 7 fraction bits)
);

    localparam WIDTHU = WIDTH - 1;
    localparam BWIDTHU = BWIDTH - 1;
    localparam FBITSW = (FBITS == 0) ? 1 : FBITS;
    localparam SMALLEST = {1'b1, {WIDTHU{1'b0}}};
    localparam ITER = WIDTH + FBITS;
    
    reg [$clog2(ITER):0] i;
    reg a_sig;
    reg [WIDTHU-1:0] au;
    reg [WIDTH-1:0] bu_scaled;    
    reg [WIDTHU-1:0] quo, quo_next;
    reg [WIDTH:0] acc, acc_next;  
    
    // Extract dividend sign
    always @* begin
        a_sig = a[WIDTH-1];
    end
    
    // Division logic
    always @* begin
        if (acc >= {1'b0, bu_scaled}) begin
            acc_next = acc - {1'b0, bu_scaled};
            {acc_next, quo_next} = {acc_next[WIDTH-1:0], quo, 1'b1};
        end else begin
            {acc_next, quo_next} = {acc, quo} << 1;
        end
    end
    
    reg [2:0] state;
    localparam IDLE = 0, INIT = 1, CALC = 2, ROUND = 3, SIGN = 4;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            busy <= 0;
            done <= 0;
            val <= 0;
            bu_scaled <= 0;
        end else begin
            done <= 0;
            case (state)
                INIT: begin
                    state <= CALC;
                    i <= 0;
                    // Scale up divisor (always positive)
                    bu_scaled <= {1'b0, (b[BWIDTHU-1:0] << FBITS)};
                    // Initialize accumulator and quotient
                    {acc, quo} <= {{WIDTH{1'b0}}, au, 1'b0};
                end
                CALC: begin
                    if (i == ITER-1) begin
                        state <= ROUND;
                    end else begin
                        i <= i + 1;
                        acc <= acc_next;
                        quo <= quo_next;
                    end
                end
                ROUND: begin
                    state <= SIGN;
                    if (acc >= {1'b0, bu_scaled[WIDTH-1:1]}) begin
                        quo <= quo + 1'b1;
                    end
                end
                SIGN: begin
                    state <= IDLE;
                    // Apply sign based only on dividend sign (divisor always positive)
                    val <= (a_sig) ? {1'b1, -quo} : {1'b0, quo};
                    busy <= 0;
                    done <= 1;
                end
                default: begin // IDLE
                    if (start) begin
                        if (b == 0) begin
                            state <= IDLE;
                            busy <= 0;
                            done <= 1;
                            val <= {WIDTH{1'b1}}; // Return max negative for divide by zero
                        end else if (a == SMALLEST || b == {1'b1, {(BWIDTH-1){1'b0}}}) begin
                            state <= IDLE;
                            busy <= 0;
                            done <= 1;
                            val <= {WIDTH{1'b1}}; // Return max negative for overflow
                        end else begin
                            state <= INIT;
                            au <= (a_sig) ? -a[WIDTHU-1:0] : a[WIDTHU-1:0];
                            busy <= 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule