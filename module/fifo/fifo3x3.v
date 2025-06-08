module fifo_3x3(clk,
    rst,
    input_pixel,
    wr_en,
    data_valid,
    output_window,
    zero_buffer,
    end_of_layer,
    in_valid,
    layer_fifosize//0 = 112, 1 = 56
    );
    parameter maxfiforaw = 112;
    parameter window_size = 3;
    parameter padding = 1;
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    localparam n112= 112;
    localparam n56 = 56;    
    localparam n26 = 26;
    localparam fifo_size = (maxfiforaw+2*padding)*(window_size-1)+(window_size);
    input  clk;
    input zero_buffer;
    input  rst;
    input signed[bitsize-1:0] input_pixel;
    input wr_en;
    input end_of_layer;
    output reg data_valid;
    input in_valid;
    input [$clog2(112):0]layer_fifosize;
    integer i;

    

    output signed[(bitsize*window_size*window_size)-1:0] output_window;

    reg signed[bitsize-1:0]fifo[fifo_size-1:0];

    //reg data_valid_temp;
    reg [$clog2(fifo_size)-1:0] ptr;
    reg [$clog2(fifo_size)-1:0] count;
    reg [$clog2(fifo_size)-1:0] endcount;
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            ptr<=0;
            count <= 0;
            for(i=0;i<fifo_size;i=i+1)begin
                fifo[i] <= 0;
            end
        end
        else begin//*if(wr_en 
                if(in_valid) begin
                    endcount<= 0;
                    fifo[0] <= input_pixel;
                end
                if(zero_buffer) begin
                    fifo[0] <= 14'd0;
                    endcount=0;
                    end
                if(end_of_layer) begin
                    for(i=0;i<fifo_size;i=i+1)begin
                        fifo[i] <= 0;
                    end
                    ptr <= 0;
                    count <= 0;
                end
                if(layer_fifosize==112)begin
                    for(i=1;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                else if(layer_fifosize==56)begin
                    fifo[1]<= fifo[0];
                    fifo[2] <= fifo[1];
                    fifo[59] <= fifo[2];
                    for(i=60;i<116;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[116] <= fifo[173];
                    for(i=118;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                else if (layer_fifosize==26) begin
                    fifo[1]<= fifo[0];
                    fifo[2] <= fifo[1];
                    fifo[87] <= fifo[2];
                    for(i=88;i<116;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[116] <= fifo[207];
                    for(i=208;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                count=count+1;
                if(ptr < fifo_size-1)begin
                    ptr <= ptr + 1;
                end
                
            end
        end

    always @(*) begin
        case(layer_fifosize)
            n112: begin
                if(count >= 112+2+3) begin
                    data_valid = 1;
                end
                else begin
                    data_valid = 0;
                end
            end
            n56: begin
                if(count >= 56+2+3) begin
                    data_valid = 1;
                end
                else begin
                    data_valid = 0;
                end
            end
            n26: begin
                if(count >= 26+2+3) begin
                    data_valid = 1;
                end
                else begin
                    data_valid = 0;
                end
            end
            default: begin
                data_valid = 0;
            end
        endcase 
    end
    generate
        if(window_size==3)begin
            assign output_window [bitsize-1:0] = fifo[(maxfiforaw+2*padding)*2+2];
            assign output_window [bitsize*2-1:bitsize] = fifo[(maxfiforaw+2*padding)*2+1];
            assign output_window [bitsize*3-1:bitsize*2] = fifo[(maxfiforaw+2*padding)*2];
            assign output_window [bitsize*4-1:bitsize*3] = fifo[maxfiforaw+2*padding+2];
            assign output_window [bitsize*5-1:bitsize*4] = fifo[maxfiforaw+2*padding+1];
            assign output_window [bitsize*6-1:bitsize*5] = fifo[maxfiforaw+2*padding];
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


