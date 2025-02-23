module relu_segment #(      
    parameter FRAC_BITS = 7,     
    parameter DATA_WIDTH = 14  
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output reg  signed [DATA_WIDTH-1:0] data_out,
    output reg                      valid
    
);
localparam INT_BITS = DATA_WIDTH - FRAC_BITS;


    // Single always block for synchronous logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {DATA_WIDTH{1'b0}};
            valid <= 1'b0;
            
        end
        else if (enable) begin
            valid <= 1'b1;
            if (data_in[DATA_WIDTH-1]) begin  // Negative number
                data_out <= {DATA_WIDTH{1'b0}};
                
            end
            else if (data_in > {1'b0, {INT_BITS-1{1'b1}}, {FRAC_BITS{1'b0}}}) begin  // Overflow
                data_out <= {1'b0, {INT_BITS-1{1'b1}}, {FRAC_BITS{1'b0}}};  // MAX_VALUE
                
            end
            else begin  // Positive number within range
                data_out <= data_in;
            
            end
        end
        else begin
            valid <= 1'b0;
        end
    end

endmodule