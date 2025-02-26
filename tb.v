module adder_tb();

    parameter bitsize = 14;
    parameter NUM_INPUTS = 27;

    reg clk;
    reg rst;
    reg signed  [NUM_INPUTS*bitsize-1:0] input_numbers;
    wire signed [bitsize+6:0] sum_output;
    wire data_valid;
    reg [bitsize-1:0]i; 
    integer file;

    adder_27 adder_27_inst(
        .clk(clk),
        .rst(rst),
        .input_numbers(input_numbers),
        .sum_output(sum_output),
        .data_valid(data_valid),
        .start_adder(1'b1)
    );
    always begin
        #10 clk = ~clk;
    end

    initial begin
        for (i =1 ;i<=27 ;i=i+1 ) begin
            input_numbers[(i-1)*bitsize+:bitsize] = 14'b0000011_0100000; 
        end
        // for (i =1 ;i<=27 ;i=i+1 ) begin
        //     $display(input_numbers[(i-1)*bitsize+:bitsize]); 
        // end

                // for (i =1 ;i<=27 ;i=i+1 ) begin
        //     input_numbers[(i-1)*bitsize+:bitsize] = i*-2; 
        // end
        clk=0;
        rst=0;
        
        @(negedge clk);
        rst=1;
        repeat(7)@(negedge clk);
        $display("sum_output = %b",sum_output);
        file=$fopen("output.txt","w");
        $fwrite(file,"%b",sum_output);
        $fclose(file);

        //$display("stage5 = %d",adder_27_inst.stage5_sum);
        //$display("data_valid = %d",data_valid);
        $stop;
    end

endmodule


//!01011011100100
//?01111111111111

//0110111011011100011
//1101010100100011101