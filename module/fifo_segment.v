module fifo_segment(clk,
    rst,
    input_pixel,
    wr_en,
    data_valid,
    output_window
    );
    parameter image_size = 224;
    parameter window_size = 3;
    parameter padding = 1;
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    localparam fifo_size = (image_size+2*padding)*(window_size-1)+(window_size);
    input  clk;
    input  rst;
    input signed[bitsize-1:0] input_pixel;
    input wr_en;
    output data_valid;

    integer i;

    

    output signed[(bitsize*window_size*window_size)-1:0] output_window;

    reg signed[bitsize-1:0]fifo[fifo_size-1:0];

    //reg data_valid_temp;
    reg [$clog2(fifo_size)-1:0] ptr;
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            ptr<=0;
            for(i=0;i<fifo_size;i=i+1)begin
                fifo[i] <= 0;
            end
        end
        else begin
            if(wr_en)begin
                fifo[0] <= input_pixel;
                for(i=1;i<fifo_size;i=i+1)begin
                    fifo[i] <= fifo[i-1];
                end
                if(ptr < fifo_size-1)begin
                    ptr <= ptr + 1;
                end

            end
        end
    end

    assign data_valid = (ptr==fifo_size-1)?1'b1:1'b0;
    generate
        if(window_size==3)begin
            assign output_window [bitsize-1:0] = fifo[(image_size+2*padding)*2+2];
            assign output_window [bitsize*2-1:bitsize] = fifo[(image_size+2*padding)*2+1];
            assign output_window [bitsize*3-1:bitsize*2] = fifo[(image_size+2*padding)*2];
            assign output_window [bitsize*4-1:bitsize*3] = fifo[image_size+2*padding+2];
            assign output_window [bitsize*5-1:bitsize*4] = fifo[image_size+2*padding+1];
            assign output_window [bitsize*6-1:bitsize*5] = fifo[image_size+2*padding];
            assign output_window [bitsize*7-1:bitsize*6] = fifo[2];
            assign output_window [bitsize*8-1:bitsize*7] = fifo[1];
            assign output_window [bitsize*9-1:bitsize*8] = fifo[0];
        end
        // else if(window_size==5)begin
        //     assign output_window[0] = fifo[0];
        //     assign output_window[1] = fifo[1];
        //     assign output_window[2] = fifo[2];
        //     assign output_window[3] = fifo[3];
        //     assign output_window[4] = fifo[4];
        //     assign output_window[5] = fifo[225];
        //     assign output_window[6] = fifo[226];
        //     assign output_window[7] = fifo[227];
        //     assign output_window[8] = fifo[228];
        //     assign output_window[9] = fifo[229];
        //     assign output_window[10] = fifo[450];
        //     assign output_window[11] = fifo[451];
        //     assign output_window[12] = fifo[452];
        //     assign output_window[13] = fifo[453];
        //     assign output_window[14] = fifo[454];
        //end
    endgenerate
    // assign output_window [13: 0] = fifo[450];
    // assign output_window [27:14] = fifo[449];
    // assign output_window [41:28] = fifo[448];
    // assign output_window [55:42] = fifo[226];
    // assign output_window [69:56] = fifo[225];
    // assign output_window [83:70] = fifo[224];
    // assign output_window [97:84] = fifo[2];
    // assign output_window [111:98] = fifo[1];
    // assign output_window [125:112] = fifo[0];



endmodule


