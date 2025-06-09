module fifo5x5(clk,
    rst,
    input_pixel,
    wr_en,
    data_valid,
    output_window,
    end_of_layer,
    window_done,
    layer_fifosize//0 = 112, 1 = 56
    );
    parameter maxfiforaw = 28;
    parameter window_size = 5;
    parameter padding = 2;
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    localparam n28= 28;
    localparam n14 = 14;    
    localparam n7 = 7;
    localparam fifo_size = (maxfiforaw+2*padding)*(window_size-1)+(window_size);
    input  clk;
    input  rst;
    input window_done;
    input signed[bitsize-1:0] input_pixel;
    input wr_en;
    input end_of_layer;
    reg data_valid_temp;
    output  data_valid;
    input [$clog2(32):0]layer_fifosize;
    integer i;
    output signed[(bitsize*25)-1:0] output_window;
    reg signed[bitsize-1:0]fifo[fifo_size-1:0];
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
                if(layer_fifosize==28)begin
                    for(i=1;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                else if(layer_fifosize==14)begin
                    fifo[1]<= fifo[0];
                    fifo[2] <= fifo[1];
                    fifo[3] <= fifo[2];
                    fifo[4] <= fifo[3];
                    fifo[19] <= fifo[4];
                    for(i=20;i<=36;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[51] <= fifo[36];
                    for(i=52;i<68;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[83]<= fifo[68];
                    for(i=84;i<100;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[115] <= fifo[100];
                    for(i=116;i<fifo_size;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                end
                else if (layer_fifosize==7) begin
                    fifo[1]<= fifo[0];
                    fifo[2] <= fifo[1];
                    fifo[3] <= fifo[2];
                    fifo[4] <= fifo[3];
                    fifo[26] <= fifo[4];
                    for(i=27;i<36;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[58] <= fifo[36];
                    for(i=59;i<68;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[90] <= fifo[68];
                    for(i=91;i<100;i=i+1)begin
                        fifo[i] <= fifo[i-1];
                    end
                    fifo[122] <= fifo[100];
                    for(i=123;i<fifo_size;i=i+1)begin
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
            n28: begin
                if(count >= (28+4)*2+5) begin
                    data_valid_temp = 1;
                end
                else begin
                    data_valid_temp = 0;
                end
            end
            n14: begin
                if(count >= (14+4)*2+5) begin
                    data_valid_temp = 1;
                end
                else begin
                    data_valid_temp = 0;
                end
            end
            n7: begin
                if(count >= (7+4)*2+5) begin
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





    assign data_valid = data_valid_temp;
    generate
        if(window_size==5)begin
            assign output_window [bitsize-1:0] = fifo[(maxfiforaw+2*padding)*4+4];
            assign output_window [bitsize*2-1:bitsize] = fifo[(maxfiforaw+2*padding)*4+3];
            assign output_window [bitsize*3-1:bitsize*2] = fifo[(maxfiforaw+2*padding)*4+2];
            assign output_window [bitsize*4-1:bitsize*3] = fifo[(maxfiforaw+2*padding)*4+1];
            assign output_window [bitsize*5-1:bitsize*4] = fifo[(maxfiforaw+2*padding)*4];

            assign output_window [bitsize*6-1:bitsize*5] = fifo[(maxfiforaw+2*padding)*3+4];
            assign output_window [bitsize*7-1:bitsize*6] = fifo[(maxfiforaw+2*padding)*3+3];
            assign output_window [bitsize*8-1:bitsize*7] = fifo[(maxfiforaw+2*padding)*3+2];
            assign output_window [bitsize*9-1:bitsize*8] = fifo[(maxfiforaw+2*padding)*3+1];
            assign output_window [bitsize*10-1:bitsize*9] = fifo[(maxfiforaw+2*padding)*3];

            assign output_window [bitsize*11-1:bitsize*10] = fifo[(maxfiforaw+2*padding)*2+4];
            assign output_window [bitsize*12-1:bitsize*11] = fifo[(maxfiforaw+2*padding)*2+3];
            assign output_window [bitsize*13-1:bitsize*12] = fifo[(maxfiforaw+2*padding)*2+2];
            assign output_window [bitsize*14-1:bitsize*13] = fifo[(maxfiforaw+2*padding)*2+1];
            assign output_window [bitsize*15-1:bitsize*14] = fifo[(maxfiforaw+2*padding)*2];

            assign output_window [bitsize*16-1:bitsize*15] = fifo[maxfiforaw+2*padding+4];
            assign output_window [bitsize*17-1:bitsize*16] = fifo[maxfiforaw+2*padding+3];
            assign output_window [bitsize*18-1:bitsize*17] = fifo[maxfiforaw+2*padding+2];
            assign output_window [bitsize*19-1:bitsize*18] = fifo[maxfiforaw+2*padding+1];
            assign output_window [bitsize*20-1:bitsize*19] = fifo[maxfiforaw+2*padding];

            assign output_window [bitsize*21-1:bitsize*20] = fifo[4];
            assign output_window [bitsize*22-1:bitsize*21] = fifo[3];
            assign output_window [bitsize*23-1:bitsize*22] = fifo[2];
            assign output_window [bitsize*24-1:bitsize*23] = fifo[1];
            assign output_window [bitsize*25-1:bitsize*24] = fifo[0];
        end
        endgenerate
endmodule