module relu_tb;
    parameter INT_BITS = 16;
    parameter FRAC_BITS = 16;
    parameter DATA_WIDTH = INT_BITS + FRAC_BITS;
    
    reg clk;
    reg rst_n;
    reg enable;
    reg signed [DATA_WIDTH-1:0] data_in;
    wire signed [DATA_WIDTH-1:0] data_out;
    wire valid;
    wire overflow;
    
    // Test control signals
    reg [31:0] test_vector [0:9];    // Array to store test inputs
    reg [31:0] expected_vector [0:9]; // Array to store expected outputs
    reg [8*20:1] test_names [0:9];   // Array to store test names
    integer test_case;
    integer current_test;
    reg test_in_progress;
    
    // DUT instantiation
    relu #(
        .INT_BITS(INT_BITS),
        .FRAC_BITS(FRAC_BITS)
    ) relu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .data_in(data_in),
        .data_out(data_out),
        .valid(valid),
        .overflow(overflow)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Initialize test vectors
    initial begin
        // Test vectors initialization
        test_vector[0] = 32'h0000ffff; expected_vector[0] = 32'h0000ffff; test_names[0] = "Almost 1";
        test_vector[1] = 32'h00000000; expected_vector[1] = 32'h00000000; test_names[1] = "Zero input";
        test_vector[2] = 32'hffff0000; expected_vector[2] = 32'h00000000; test_names[2] = "Negative one";
        test_vector[3] = 32'h00028000; expected_vector[3] = 32'h00028000; test_names[3] = "Positive 2.5";
        test_vector[4] = 32'h7fff0000; expected_vector[4] = 32'h7fff0000; test_names[4] = "Max positive";
        test_vector[5] = 32'h7fff8000; expected_vector[5] = 32'h7fff0000; test_names[5] = "Overflow case";
        test_vector[6] = 32'h00000001; expected_vector[6] = 32'h00000001; test_names[6] = "Small positive";
        test_vector[7] = 32'h80000000; expected_vector[7] = 32'h00000000; test_names[7] = "Min negative";
        test_vector[8] = 32'h00018001; expected_vector[8] = 32'h00018001; test_names[8] = "Small fraction";
        test_vector[9] = 32'h00008000; expected_vector[9] = 32'h00008000; test_names[9] = "0.5 value";
    end
    
    // Separate process for applying inputs
    initial begin
        // Initialize
        test_case = 0;
        current_test = 0;
        test_in_progress = 0;
        rst_n = 0;
        enable = 0;
        data_in = 0;
        
        // Reset sequence
        #100;
        @(negedge clk);
        rst_n = 1;
        #20;
        
        // Start test sequence
        enable = 1;
        
        // Apply inputs sequentially
        for (current_test = 0; current_test < 10; current_test = current_test + 1) begin
            @(negedge clk);
            test_in_progress = 1;
            data_in = test_vector[current_test];
            test_case = current_test;
            $display("\nApplying Test Case %0d: %s", current_test, test_names[current_test]);
            $display("Input: %h", data_in);
            
            // Wait for checking process to complete
            @(posedge clk);
            #1; // Small delay to ensure stability
        end
        
        // End simulation
        @(negedge clk);
        enable = 0;
        test_in_progress = 0;
        #50;
        $display("\nTestbench completed with %0d test cases", test_case + 1);
        $stop;
    end
    
    // Separate process for checking outputs
    always @(negedge clk) begin
        if (rst_n && enable && test_in_progress) begin
            // Check output on positive edge after input was applied
            if (data_out === expected_vector[test_case])
                $display("PASS: Output %h matches expected %h", data_out, expected_vector[test_case]);
            else
                $display("FAIL: Output %h doesn't match expected %h", data_out, expected_vector[test_case]);
            
            $display("Valid: %b, Overflow: %b", valid, overflow);
            
            // Display decimal values
            $display("Decimal value - Input: %f, Output: %f",
                    $itor(data_in) / (2.0 ** FRAC_BITS),
                    $itor(data_out) / (2.0 ** FRAC_BITS));
        end
    end
    
endmodule