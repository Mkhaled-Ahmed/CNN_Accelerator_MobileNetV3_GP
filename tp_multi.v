module tp_multi();
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;

    reg clk;
    reg rst;
    reg start_flag;
    reg signed [bitsize-1:0] data_in;
    reg signed [bitsize-1:0] weights;
    wire signed [bitsize-1:0] Mult_result;
    wire valid;

    fixed_point_multiplier fixed_point_multiplier_inst(
        .clk(clk),
        .rst(rst),
        .start_flag(start_flag),
        .a(data_in),
        .b(weights),
        .Mul_result(Mult_result),
        .valid(valid)
    );

    always begin
        #10 clk = ~clk;
    end

    initial begin
        clk=0;
        rst=0;
        start_flag=1;
        data_in=-14'b0_000001_1011001;
        weights=-14'b0_000001_1011001;
        
        @(negedge clk);
        rst=1;
        @(negedge clk);
        $display("Mult_result = %b",Mult_result);
        $display("valid = %d",valid);
        $stop;
    end

endmodule