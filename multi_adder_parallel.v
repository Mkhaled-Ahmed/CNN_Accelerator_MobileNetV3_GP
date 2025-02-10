module multi_adder_parallel #(
    parameter DATA_WIDTH = 14,
    parameter NUM_ADDERS = 16,
    parameter INPUTS_PER_ADDER = 27,
    parameter TOTAL_INPUTS = NUM_ADDERS * INPUTS_PER_ADDER
)(
    input wire clk,
    input wire reset,
    input wire [TOTAL_INPUTS*DATA_WIDTH-1:0] input_data,
    output wire [NUM_ADDERS*DATA_WIDTH-1:0] adder_outputs,
    output wire [NUM_ADDERS-1:0] output_valids
);

    // Generate 16 instances of the 27-input adder
    generate
        genvar i;
        for (i = 0; i < NUM_ADDERS; i = i + 1) begin : adder_inst
            adder_27 #(
                .DATA_WIDTH(DATA_WIDTH),
                .NUM_INPUTS(INPUTS_PER_ADDER)
            ) adder (
                .clk(clk),
                .reset(reset),
                .input_numbers(input_data[i*INPUTS_PER_ADDER*DATA_WIDTH +: INPUTS_PER_ADDER*DATA_WIDTH]),
                .sum_output(adder_outputs[i*DATA_WIDTH +: DATA_WIDTH]),
                .data_valid(output_valids[i])
            );
        end
    endgenerate

endmodule

// // Testbench for verification
// module multi_adder_parallel_tb;
//     parameter DATA_WIDTH = 12;
//     parameter NUM_ADDERS = 16;
//     parameter INPUTS_PER_ADDER = 27;
//     parameter TOTAL_INPUTS = NUM_ADDERS * INPUTS_PER_ADDER;

//     reg clk;
//     reg reset;
//     reg [TOTAL_INPUTS*DATA_WIDTH-1:0] input_data;
//     wire [NUM_ADDERS*DATA_WIDTH-1:0] adder_outputs;
//     wire [NUM_ADDERS-1:0] output_valids;

//     // Instantiate the top module
//     multi_adder_parallel #(
//         .DATA_WIDTH(DATA_WIDTH),
//         .NUM_ADDERS(NUM_ADDERS),
//         .INPUTS_PER_ADDER(INPUTS_PER_ADDER)
//     ) dut (
//         .clk(clk),
//         .reset(reset),
//         .input_data(input_data),
//         .adder_outputs(adder_outputs),
//         .output_valids(output_valids)
//     );

//     // Clock generation
//     initial begin
//         clk = 0;
//         forever #5 clk = ~clk;
//     end

//     // Test stimulus
//     initial begin
//         // Initialize inputs
//         reset = 1;
//         input_data = 0;
//         #20;
//         reset = 0;

//         // Set test data - different values for each adder's inputs
//         for (integer i = 0; i < TOTAL_INPUTS; i = i + 1) begin
//             input_data[i*DATA_WIDTH +: DATA_WIDTH] = i % 16 + 1; // Different values for each adder
//         end

//         // Wait for results
//         repeat(10) @(posedge clk);
        
//         // Monitor all outputs
//         for (integer i = 0; i < NUM_ADDERS; i = i + 1) begin
//             if (output_valids[i]) begin
//                 $display("Adder %d output: %d", i, adder_outputs[i*DATA_WIDTH +: DATA_WIDTH]);
//             end
//         end

//         #100;
//         $finish;
//     end

//     // Monitor outputs continuously
//     always @(posedge clk) begin
//         for (integer i = 0; i < NUM_ADDERS; i = i + 1) begin
//             if (output_valids[i]) begin
//                 $display("Time %t: Adder %d output = %d", $time, i, 
//                         adder_outputs[i*DATA_WIDTH +: DATA_WIDTH]);
//             end
//         end
//     end
// endmodule