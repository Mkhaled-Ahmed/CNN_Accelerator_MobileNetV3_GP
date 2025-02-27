module tp_multi();
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 9;

    reg clk;
    reg rst;
    reg start_flag;
    reg signed [bitsize-1:0] data_in;
    reg signed [bitsize-1:0] weights;
    wire signed [(bitsize*2-FRAC_BITS)-1:0] Mult_result;
    wire valid;
    integer file;

    fixed_point_multiplier #(.bitsize(bitsize),.FRAC_BITS(FRAC_BITS))fixed_point_multiplier_inst(
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
        data_in= 14'b00000_001101000;
        weights=-14'b00000_000001100;
        
        @(negedge clk);
        rst=1;
        @(negedge clk);
        $display();
        $display("%b",Mult_result);
        $display("%b",fixed_point_multiplier_inst.mult_round_temp);
        $display("valid = %d",valid);
        file=$fopen("output.txt","w");
        $fwrite(file,"%b",data_in);
        $fdisplay(file, "");
        $fwrite(file,"%b",weights);
        $fdisplay(file, "");
        $fwrite(file,"%b",Mult_result);
        $fdisplay(file, "");
        $fwrite(file,"%b",fixed_point_multiplier_inst.Mul_result_temp);
        $fclose(file);
        $stop;
    end

endmodule