module relu #(
    parameter INT_BITS = 16,      
    parameter FRAC_BITS = 16,     
    parameter DATA_WIDTH = INT_BITS + FRAC_BITS  
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    output reg  signed [DATA_WIDTH-1:0] data_out,
    output reg                      valid
     
);

    // Initialize all registers
    initial begin
        data_out = {DATA_WIDTH{1'b0}};
        valid = 1'b0;
   
    end

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