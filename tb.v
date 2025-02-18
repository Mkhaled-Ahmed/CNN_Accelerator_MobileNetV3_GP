module adder_tb();

    parameter bitsize = 14;
    parameter NUM_INPUTS = 27;

    reg clk;
    reg rst;
    reg signed  [NUM_INPUTS*bitsize-1:0] input_numbers;
    wire signed [bitsize-1:0] sum_output;
    wire data_valid;
    reg [bitsize-1:0]i; 

    adder_27 adder_27_inst(
        .clk(clk),
        .rst(rst),
        .input_numbers(input_numbers),
        .sum_output(sum_output),
        .data_valid(data_valid)
    );
    always begin
        #10 clk = ~clk;
    end

    initial begin
        for (i =1 ;i<=27 ;i=i+1 ) begin
            input_numbers[(i-1)*bitsize+:bitsize] = i; 
        end
        // for (i =1 ;i<=27 ;i=i+1 ) begin
        //     $display(input_numbers[(i-1)*bitsize+:bitsize]); 
        // end
        clk=0;
        rst=0;
        
        @(negedge clk);
        rst=1;
        @(negedge clk);
        for (i =1 ;i<=27 ;i=i+1 ) begin
            input_numbers[(i-1)*bitsize+:bitsize] = i*2; 
        end
        repeat(5) @(negedge clk);
        $display("sum_output = %d",sum_output);
        @(negedge clk);
        $display("sum_output = %d",sum_output);
        $stop;
    end

endmodule