module fixed_point_multiplier_top #(
    parameter NUM_INSTANCES = 32, // Number of multiplier instances
    parameter WIDTH = 14,         // Bit width of fixed-point numbers
    parameter FRAC_BITS = 7       // Number of fractional bits
)(
    input wire clk,
    input wire rst,
    input wire [NUM_INSTANCES*WIDTH-1:0] a, // Flattened input A
    input wire [NUM_INSTANCES*WIDTH-1:0] b, // Flattened input B
    output wire data_valid,
    output reg [NUM_INSTANCES*WIDTH-1:0] Mul_result // Flattened output
);
wire [NUM_INSTANCES-1:0] valid;

    genvar i;

    generate
        for (i = 0; i < NUM_INSTANCES; i = i + 1) begin : MULTIPLIER_INSTANCES
            fixed_point_multiplier #(
                .WIDTH(WIDTH),
                .FRAC_BITS(FRAC_BITS)
            ) multiplier_inst (
                .clk(clk),
                .rst(rst),
                .a(a[(i+1)*WIDTH-1:i*WIDTH]), // Extract i-th input
                .b(b[(i+1)*WIDTH-1:i*WIDTH]), // Extract i-th input
                .data_valid(valid[i]),
                .Mul_result(Mul_result[(i+1)*WIDTH-1:i*WIDTH]) // Assign i-th output
            );
        end
    endgenerate

assign data_valid= &valid;
endmodule
