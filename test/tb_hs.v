module tb_hs ();


    parameter DATA_WIDTH = 26;
    parameter FRAC_BITS=9;
    reg signed [DATA_WIDTH-1:0] input_data;
    reg clk,rst,en;
    wire signed [13:0] output_data;
    wire valid;
    reg start=0;
    integer file;



    hs_segment #(
        .DATA_WIDTH 	(DATA_WIDTH  ),
        .FRAC_BITS  	(FRAC_BITS   ))
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
        start=0;
        en=1;
        @(negedge clk);
        rst=1;
        input_data=-26'd1024;
        @(negedge clk);
        input_data=-26'd1536;
        @(negedge clk);
        input_data=26'd1536;
        @(posedge valid);
        @(negedge clk);
        file=$fopen("textfiles/output.txt","w");
        $fwrite(file,"%b",output_data);
        $fdisplay(file,"");
        @(negedge clk);
        $fwrite(file,"%b",output_data);
        $fdisplay(file,"");
        @(negedge clk);
        $fwrite(file,"%b",output_data);
        $fdisplay(file,"");
        @(negedge clk);
        $fclose(file);
        $stop;
    end

endmodule