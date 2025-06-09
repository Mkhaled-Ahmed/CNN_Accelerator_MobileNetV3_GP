module fifox3x16(
    clk,rst,input_pixels,stride,EX_Window_Done,
    Zero_Buffreing,row_size,full_window_size
    ,wr_en,data_valid,depth_window_done,output_window
    );
    
    
    parameter bitsize = 14;        // Total width of inputs
    parameter FRAC_BITS = 7;
    input  clk;
    input  rst;
    input signed[16*bitsize-1:0] input_pixels;
    input [11:0] full_window_size; //* including padding
    input wr_en;
    input stride;
    input [6:0]row_size; //* without padding
    input EX_Window_Done;
    input Zero_Buffreing;
    output reg data_valid;
    output depth_window_done;
    output wire [(bitsize*25*16)-1:0] output_window;



    wire data_valid_add_operation_temp;
    reg data_valid_temp;
    reg [7:0]counter;
    reg skip_row;
    reg [11:0] window_counter;
    wire window_done;
    reg  signed [bitsize-1:0] input_data[15:0];
    reg ex_end_flag;
    reg temp_data_valid99;


    always @(posedge clk or negedge rst)
        begin
            if(!rst)
                begin
                    ex_end_flag<=1'b0;
                end
            else 
                begin
                    if(EX_Window_Done)
                        begin
                            ex_end_flag<=1'b1;
                        end
                    else if(window_done && data_valid)
                        begin   
                            ex_end_flag<=1'b0;
                        end
                end
        end
integer k;
always @(*)
    begin
        if(Zero_Buffreing || ex_end_flag)
            begin
                for(k=0;k<16;k=k+1)
                    begin
                        input_data[k]='b0;
                    end
            end
        else 
        begin   for(k=0;k<16;k=k+1)
                    begin
                        input_data[k]=input_pixels[k*bitsize +:bitsize];
                    end
                
        end

    end
assign window_flag=(window_counter==full_window_size-1'b1);
always @(posedge clk or negedge rst)
    begin
        if(!rst) 
            begin
                window_counter<='b0;
            end
        else 
            begin
                if(data_valid && window_flag)
                    begin
                        window_counter<='b0;
                    end
                else if(data_valid)
                    begin
                        window_counter<=window_counter+1'b1;
                    end
            end
    end
wire seg_data_valid [15:0];
wire signed [bitsize*25-1:0] seg_output_window [15:0];

genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : fifo_segments
            fifo3x3 #(.bitsize(bitsize))
                u_fifo3x3(
                .clk(clk),
                .rst(rst),
                .input_pixel(input_data[i]),
                .wr_en(wr_en),
                .window_done(window_done),
                .end_of_layer(EX_Window_Done),
                .data_valid(seg_data_valid[i]),
                .layer_fifosize(row_size),
                .output_window(seg_output_window[i])
            );
        end
    endgenerate

assign output_window = {seg_output_window[15],seg_output_window[14],seg_output_window[13],
                       seg_output_window[12],seg_output_window[11],seg_output_window[10],
                       seg_output_window[9],seg_output_window[8],seg_output_window[7],
                       seg_output_window[6],seg_output_window[5],seg_output_window[4],
                       seg_output_window[3],seg_output_window[2],seg_output_window[1],
                       seg_output_window[0]};
always @(posedge clk or negedge rst) begin
        if(!rst) begin
            temp_data_valid99 <= 0;
        end
        else begin
            temp_data_valid99 <= data_valid_add_operation_temp;
        end
    end
always @(*)
    begin
   if(!stride) //* this mean stride is equal one
        begin
            data_valid=temp_data_valid99;
        end
    else 
        begin //* this mean stride is equal two 
            data_valid = (skip_row)? 1'b0:data_valid_temp;
        end

    end

    //*assign data_valid = (skip_row)? 1'b0:data_valid_temp;
    assign data_valid_add_operation_temp = seg_data_valid[0];

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            data_valid_temp <= 0;
            counter <= 0;
            skip_row <= 0;
        end
        else begin
            if(!data_valid_add_operation_temp) begin
                data_valid_temp <= 0;
                counter<=0;
            end
            else begin
                data_valid_temp <= !data_valid_temp;
                if(counter == row_size+1'b1) begin
                    skip_row <= !skip_row;
                    counter <= 0;
                end
                else begin
                    counter <= counter + 1;
                end
            end
        end
    end 


assign window_done = data_valid && window_flag;
assign depth_window_done = window_done;
endmodule