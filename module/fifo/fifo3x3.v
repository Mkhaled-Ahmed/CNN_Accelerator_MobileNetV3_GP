module fifo3x3(clk,
    rst,
    input_pixel,
    wr_en,
    data_valid,
    output_window,
    end_of_layer,
    window_done,
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
    input  rst;
    input window_done;
    input signed[bitsize-1:0] input_pixel;
    input wr_en;
    input end_of_layer;
    reg data_valid_temp;
    output  data_valid;
    input [$clog2(112)-1:0]layer_fifosize;
    integer i;

    

    output signed[(bitsize*25)-1:0] output_window;

    reg signed[bitsize-1:0]fifo[fifo_size-1:0];

    //reg data_valid_temp_temp;
    reg [$clog2(fifo_size)-1:0] count;
    always @(posedge clk or negedge rst) begin
        if(!rst)begin
            count <= 0;
            for(i=0;i<fifo_size;i=i+1)begin
                fifo[i] <= 0;
            end
        end
        else if(wr_en) begin 
                fifo[0] <= input_pixel;
                if(layer_fifosize==112)begin
                    for(i=1;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                else if(layer_fifosize==56)begin
                    fifo[1]<= fifo[0];
                    fifo[2] <= fifo[1];
                    fifo[59] <= fifo[2];
                    for(i=60;i<=116;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[173] <= fifo[116];
                    for(i=118;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                else if (layer_fifosize==28) begin
                    fifo[1]<= fifo[0];
                    fifo[2] <= fifo[1];
                    fifo[87] <= fifo[2];
                    for(i=88;i<=116;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[207] <= fifo[116];
                    for(i=208;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                if(window_done)begin
                count<=0;
                for(i=0;i<fifo_size;i=i+1)begin
                    fifo[i] <= 0;
                end
                end
                else if(!data_valid_temp) begin
                    count <= count + 1 ;
                end
                
            end
        end

    always @(*) begin
        case(layer_fifosize)
            n112: begin
                if(count >= 112+2+3) begin
                    data_valid_temp = 1;
                end
                else begin
                    data_valid_temp = 0;
                end
            end
            n56: begin
                if(count >= 56+2+3) begin
                    data_valid_temp = 1;
                end
                else begin
                    data_valid_temp = 0;
                end
            end
            n26: begin
                if(count >= 28+2+3) begin
                    data_valid_temp = 1;
                end
                else begin
                    data_valid_temp = 0;
                end
            end
            default: begin
                data_valid_temp = 0;
            end
        endcase 
    end
    generate
        if(window_size==3)begin
            assign output_window [bitsize-1:0] = fifo[(maxfiforaw+2*padding)*2+2];
            assign output_window [bitsize*2-1:bitsize] = fifo[(maxfiforaw+2*padding)*2+1];
            assign output_window [bitsize*3-1:bitsize*2] = fifo[(maxfiforaw+2*padding)*2];

            assign output_window [bitsize*4-1:bitsize*3] = 0;
            assign output_window [bitsize*5-1:bitsize*4] = 0;

            assign output_window [bitsize*6-1:bitsize*5] = fifo[maxfiforaw+2*padding+2];
            assign output_window [bitsize*7-1:bitsize*6] = fifo[maxfiforaw+2*padding+1];
            assign output_window [bitsize*8-1:bitsize*7] = fifo[maxfiforaw+2*padding];

            assign output_window [bitsize*9-1:bitsize*8] = 0;
            assign output_window [bitsize*10-1:bitsize*9] = 0;

            assign output_window [bitsize*11-1:bitsize*10] = fifo[2];
            assign output_window [bitsize*12-1:bitsize*11] = fifo[1];
            assign output_window [bitsize*13-1:bitsize*12] = fifo[0];

            assign output_window [(bitsize*25)-1:bitsize*13] = 0;

            assign data_valid = data_valid_temp;
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


