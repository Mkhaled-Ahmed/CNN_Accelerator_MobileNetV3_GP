module tb_hs ();


    parameter DATA_WIDTH = 32;
    parameter FRAC_BITS=9;
    parameter OUT_SIZE=18;
    reg signed [DATA_WIDTH-1:0] input_data;
    reg signed [DATA_WIDTH-1:0] input_data_temp;
    reg clk,rst,en;
    wire signed [OUT_SIZE-1:0] output_data;
    wire valid;
    reg start=0;
    integer file;
    reg [25:0]i;

// output declaration of module hs_segment
// wire [OUT_SIZE-1:0] output_data;
// wire valid;

hs_segment #(
    .DATA_WIDTH 	(32  ),
    .FRAC_BITS  	(9  ),
    .OUT_SIZE   	(18  ))
u_hs_segment(
    .input_data  	(input_data   ),
    .clk         	(clk          ),
    .rst         	(rst          ),
    .en          	(en           ),
    .output_data 	(output_data  ),
    .valid       	(valid        )
);


    // hs_block #(
    //     .DATA_WIDTH 	(DATA_WIDTH  ),
    //     .FRAC_BITS  	(FRAC_BITS   ),
    //     .OUT_SIZE   	(OUT_SIZE    )
    //     )
    // u_hs_segment(
    //     .input_data  	(input_data   ),
    //     .clk         	(clk          ),
    //     .rst         	(rst          ),
    //     .en          	(en           ),
    //     .output_data 	(output_data  ),
    //     .valid       	(valid        )
    // );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        i=0;
        file = $fopen("textfiles/output.txt", "w");
        input_data_temp [DATA_WIDTH-1:0]= -8*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*2-1:DATA_WIDTH]= -7*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*3-1:DATA_WIDTH*2]= -6*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*4-1:DATA_WIDTH*3]= -5*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*5-1:DATA_WIDTH*4]= -4*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*6-1:DATA_WIDTH*5]= -3*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*7-1:DATA_WIDTH*6]= -2*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*8-1:DATA_WIDTH*7]= -1*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*9-1:DATA_WIDTH*8]= 0*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*10-1:DATA_WIDTH*9]= 1*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*11-1:DATA_WIDTH*10]= 2*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*12-1:DATA_WIDTH*11]= 3*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*13-1:DATA_WIDTH*12]= 4*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*14-1:DATA_WIDTH*13]= 5*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*15-1:DATA_WIDTH*14]= 6*2**FRAC_BITS;
        input_data_temp [DATA_WIDTH*16-1:DATA_WIDTH*15]= 7*2**FRAC_BITS;
        // for (i = 1; i <= 16; i = i + 1) begin
        //     $fwrite(file, "%b", input_data[(i-1)*DATA_WIDTH+:DATA_WIDTH]);
        //     $fdisplay(file, "");
        // end
        // for (i = 0; i < 16; i = i + 1) begin
        //     input_data_temp[DATA_WIDTH*(i+1)-1 : DATA_WIDTH*i] = i - 8;
        // end 
        rst=0;
        start=0;
        en=1;
        @(negedge clk);
        rst=1;
        input_data=input_data_temp;
        @(posedge valid);

            // $fwrite(file, "%b", input_data[(i-1)*DATA_WIDTH+:DATA_WIDTH]);
            // $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(0+1)*OUT_SIZE-1:OUT_SIZE*0]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(1+1)*OUT_SIZE-1:OUT_SIZE*1]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(2+1)*OUT_SIZE-1:OUT_SIZE*2]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(3+1)*OUT_SIZE-1:OUT_SIZE*3]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(4+1)*OUT_SIZE-1:OUT_SIZE*4]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(5+1)*OUT_SIZE-1:OUT_SIZE*5]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(6+1)*OUT_SIZE-1:OUT_SIZE*6]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(7+1)*OUT_SIZE-1:OUT_SIZE*7]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(8+1)*OUT_SIZE-1:OUT_SIZE*8]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(9+1)*OUT_SIZE-1:OUT_SIZE*9]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(10+1)*OUT_SIZE-1:OUT_SIZE*10]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(11+1)*OUT_SIZE-1:OUT_SIZE*11]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(12+1)*OUT_SIZE-1:OUT_SIZE*12]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(13+1)*OUT_SIZE-1:OUT_SIZE*13]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(14+1)*OUT_SIZE-1:OUT_SIZE*14]);
            $fdisplay(file, "");
            $fwrite(file, "%b", output_data[(15+1)*OUT_SIZE-1:OUT_SIZE*15]);
            $fdisplay(file, "");
        $fclose(file);
        $stop;
    end

endmodule