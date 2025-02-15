module EX_Controller
#(
    parameter Data_Width=16
)

(
input clk,
input RST,
//R_Start row and col of reading 0 or 1 or 2
input [1:0] R_Start,
//W_Start row and col of reading 0 or 1 or 2
input [1:0] W_Start,

// Largest value is 112 (using 7 bit)
input [6:0] R_Final_Row,
 

// Largest value is 112 (using 7 bit)
input [6:0] W_Final_Row,
 

    // Largest Value is 6  (96/16)
input [2:0] Final_Feature,
    //largest Value is 36 (576/16)
input [5:0] Final_Filter,
// output form Expand Blok
input       Activation_Done,
//input from Main Controller
input       EX_EN,
// value of filter at which Depth will Start
input  [5:0]     Depth_EN,


output reg [3:0] Feature_Counter,//output for both Feature map and Channel of filter 

output reg [5:0] R_Filter_Counter,// output for access filter 

output reg [5:0] W_Filter_Counter,//output For access memory where output of activation will be stored

output reg [6:0] R_Row_Counter,  // output for Read Row Counter

output reg [6:0] R_Col_Counter,    // output for Read Col counter 

output reg [6:0] W_Row_Counter,     // output for Write Row counter 

output reg [6:0] W_Col_Counter,// output for write Col counter 

output  Depth_Start, // flag for Depth to R_Start 

output  R_EX_Done, // flag for end of reading

output  W_EX_Done // flag for end of writing also for end of expansion 


);

wire Feature_Counter_Flag;

wire R_Filter_Counter_Flag;

wire W_Filter_Counter_Flag;

wire R_Row_Counter_Flag;

wire R_Col_Counter_Flag;

wire W_Row_Counter_Flag; 

wire W_Col_Counter_Flag;

/////////////////////////////////////////////////////
//////////////////*feature Counter //////////////////
///////////////////////////////////////////////////
assign Feature_Counter_Flag=(Feature_Counter==Final_Feature);


always @(posedge clk or negedge RST)
    begin
        if(!RST)
            begin
                Feature_Counter<='b0;

            end
        else
            begin
                if(EX_EN)
                    begin
                      Feature_Counter<=Feature_Counter+1'b1;
                      if(Feature_Counter_Flag==1'b1)
                        Feature_Counter<=1'b0;

                    end
                else
                    Feature_Counter<=1'b0;
            end
    end

////////////////////////////////////
///////////////////////////////////
//*COL_Counter for Reading///////
//////////////////////////////////
assign R_Col_Counter_Flag=(R_Col_Counter==R_Final_Row);

always @(posedge clk or negedge RST)
   begin 
        if(!RST)
            begin
                R_Col_Counter<='b0;
            end 
        else
            begin
                if(!EX_EN)
                R_Col_Counter<=R_Start;
                else if(EX_EN)
                    begin
                        if(Feature_Counter_Flag )
                        R_Col_Counter<=R_Col_Counter+1;

                        else if(R_Col_Counter_Flag==1'b1) //|| R_EX_Done)
                               R_Col_Counter<=R_Start;

                    end
            end
   end
///////////////////////////////////////////////////////////
////////////////////*ROW_READING///////////////////////////
//////////////////////////////////////////////////////////
assign R_Row_Counter_Flag=(R_Row_Counter==R_Final_Row);
always @(posedge clk or negedge RST)
    begin
        if(!RST)
        begin
            R_Row_Counter<='b0;
        end
        else
            begin
                if(!EX_EN)
                R_Row_Counter<=R_Start;
                
                else if(R_Col_Counter_Flag)
                    begin
                        R_Row_Counter<=R_Row_Counter+1;

                        if(R_Row_Counter_Flag==1'b1 )//|| R_EX_Done)
                               R_Row_Counter<=R_Start;

                    end
            end  


    end
////////////////////////////////////////////////////////////////
////////////////*filter read counter for output /////////////////
////////////////////////////////////////////////////////////////
assign R_Filter_Counter_Flag=(R_Filter_Counter==Final_Filter);
always @(posedge clk  or negedge RST)
    begin
        if(!RST)
            begin
                R_Filter_Counter<='b0;
            end
        else    
            begin
                if(R_Col_Counter_Flag && R_Row_Counter_Flag)
                    begin
                        if(!R_Filter_Counter_Flag)
                            R_Filter_Counter<=R_Filter_Counter+1'b1;
                        else
                            R_Filter_Counter<='b0;
                    end
               

            end


    end
/////////////////////////////////////////////////////////////////////////////////
////*Read End Flag ///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
assign R_EX_Done=(R_Col_Counter_Flag && R_Row_Counter_Flag&&R_Filter_Counter_Flag);


/////////////////////////////////////////
////// * Col Write Counter /////////////
///////////////////////////////////////

assign W_Col_Counter_Flag=(W_Col_Counter==W_Final_Row);
always @(posedge clk or negedge RST)
    begin
        if(!RST)
            begin
                W_Col_Counter<='b0;
            end
        else
            begin
                if(!Activation_Done || W_Col_Counter_Flag)
                    begin
                        W_Col_Counter<=W_Start;
                    end
                else if(Activation_Done)
                    begin
                        W_Col_Counter<=W_Col_Counter+'b1;
                    end                
            end

    end

///////////////////////////////////////////////////
//* W Row Counter/////////////////////////////////
/////////////////////////////////////////////////
assign W_Row_Counter_Flag=(W_Row_Counter==W_Final_Row);
always @(posedge clk or negedge RST)
    begin
        if(!RST)
            begin
              W_Row_Counter<='b0;
            end
        else
            begin
                if(!Activation_Done || W_Row_Counter_Flag)
                    begin
                        W_Row_Counter<=W_Start;
                    end
                else if(W_Col_Counter_Flag)
                    begin
                        W_Row_Counter<=W_Row_Counter+1'b1;
                    end
            end

    end

//* Filter Counter For Output to be stored//
assign W_Filter_Counter_Flag=(W_Filter_Counter==Final_Filter);
always @(posedge clk or negedge RST )
    begin
        if(!RST)
            begin
                W_Filter_Counter<='b0;
            end
        else
            begin
                if(W_Col_Counter_Flag && W_Row_Counter_Flag)
                    begin
                        W_Filter_Counter<=W_Filter_Counter+1'b1;
                    end
                else if(W_Filter_Counter_Flag)
                    begin
                        W_Filter_Counter<='b0;
                    end
            end

    end

    assign W_EX_Done=(W_Col_Counter_Flag && W_Row_Counter_Flag && W_Filter_Counter_Flag );

    assign Depth_Start =(W_Row_Counter_Flag && W_Filter_Counter_Flag&&(Depth_EN==W_Filter_Counter))  ; 

endmodule
