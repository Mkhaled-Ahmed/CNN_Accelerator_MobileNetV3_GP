module tb_hs ();


    parameter DATA_WIDTH = 21;
    reg signed [DATA_WIDTH-1:0] input_data;
    reg clk,rst,en;
    wire signed [(DATA_WIDTH+1)*4-1:0] output_data;
    wire valid;

    integer file;



    hs_segment #(
        .DATA_WIDTH 	(21  ),
        .FRAC_BITS  	(7   ))
    u_hs_segment(
        .input_data  	(input_data   ),
        .clk         	(clk          ),
        .rst         	(rst          ),
        .en          	(en           ),
        .output_data 	(output_data  ),
        .valid       	(valid        )
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst=0;
        en=1;
        @(negedge clk);
        rst=1;
        input_data=21'd896;
        @(posedge valid);
        file=$fopen("textfiles/output.txt","w");
        $fwrite(file,"%b",output_data);
        $fclose(file);
        $stop;
    end

endmodule