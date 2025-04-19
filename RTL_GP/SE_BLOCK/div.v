module div #(
    parameter IN_WIDTH=26,  // Input width in bits (integer and fractional)
    parameter FBITS=9,  // Input fractional bits
    parameter OUT_WIDTH=14 // Output width in bits
   
    ) (
    input wire clk,    // clock
    input wire rst,    // reset
    input wire start,  // start calculation
    output reg busy,   // calculation in progress
    output reg done,   // calculation is complete (high for one tick)
    input wire [IN_WIDTH-1:0] a,   // dividend (numerator)
    input wire [IN_WIDTH-1:0] b,   // divisor (denominator)
    output reg [OUT_WIDTH-1:0] val  // result value: quotient
    );

    localparam IN_WIDTHU = IN_WIDTH - 1;                 // unsigned input width
    localparam ITER = IN_WIDTHU + FBITS;  // iteration count: unsigned input width + fractional bits
    reg [$clog2(ITER):0] i;            // iteration counter

    wire a_sig, b_sig;                 // signs of inputs
    reg sig_diff;                      // whether signs are different
    reg [IN_WIDTHU-1:0] au, bu;        // absolute version of inputs (unsigned)
    reg [IN_WIDTHU-1:0] quo, quo_next; // intermediate quotients (unsigned)
    reg [IN_WIDTHU:0] acc, acc_next;   // accumulator (unsigned but 1 bit wider)

    // input signs
    assign a_sig = a[IN_WIDTH-1];
    assign b_sig = b[IN_WIDTH-1];

    // division algorithm iteration
    always @(*) begin
        if (acc >= {1'b0, bu}) begin
            acc_next = acc - bu;
            {acc_next, quo_next} = {acc_next[IN_WIDTHU-1:0], quo, 1'b1};
        end else begin
            {acc_next, quo_next} = {acc, quo} << 1;
        end
    end

    // state encoding
    parameter [2:0] IDLE = 3'b000,
                   INIT = 3'b001,
                   CALC = 3'b010,
                   ROUND = 3'b011,
                   SIGN = 3'b100;
    
    reg [2:0] state;
    
    always @(posedge clk or negedge rst) begin
        done <= 0;
        case (state)
            INIT: begin
                state <= CALC;
                i <= 0;
                {acc, quo} <= {{IN_WIDTHU{1'b0}}, au, 1'b0};
            end
            CALC: begin
                if (i == ITER-1) state <= ROUND;  // calculation complete
                i <= i + 1;
                acc <= acc_next;
                quo <= quo_next;
            end
            ROUND: begin  // Gaussian rounding
                state <= SIGN;
                if (quo_next[0] == 1'b1) begin  // next digit is 1, so consider rounding
                    if (quo[0] == 1'b1 || acc_next[IN_WIDTHU:1] != 0) quo <= quo + 1;
                end
            end
            SIGN: begin  // adjust quotient sign
                state <= IDLE;
                val <= sig_diff ? {1'b1, (~quo[OUT_WIDTH-2:0] + 1)} : {1'b0, quo[OUT_WIDTH-2:0]};
                busy <= 0;
                done <= 1;
            end
            default: begin  // IDLE
                if (start) begin
                    state <= INIT;
                    au <= a_sig ? (~a[IN_WIDTHU-1:0] + 1) : a[IN_WIDTHU-1:0];
                    bu <= b_sig ? (~b[IN_WIDTHU-1:0] + 1) : b[IN_WIDTHU-1:0];
                    sig_diff <= (a_sig ^ b_sig);
                    busy <= 1;
                end
            end
        endcase
        if (!rst) begin
            state <= IDLE;
            busy <= 0;
            done <= 0;
            val <= 0;
        end
    end
endmodule
