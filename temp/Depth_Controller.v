module Depth_Controller
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

//Step of Filter on feature map 
input [1:0] Stride ,

// Largest value is 112 (using 7 bit)
input [6:0] W_Final_Row,
 
//largest Value is 36 (576/16)
input [5:0] Final_Filter,
// output form Expand Blok
input       Activation_Done,
//input from Main Controller
input       Depth_EN,
// value of filter at which Depth will Start
input  [5:0]     SE_EN,


output reg [5:0] R_Filter_Counter,// output for access filter 

output reg [5:0] W_Filter_Counter,//output For access memory where output of activation will be stored

output reg [6:0] R_Row_Counter,  // output for Read Row Counter

output reg [6:0] R_Col_Counter,    // output for Read Col counter 

output reg [6:0] W_Row_Counter,     // output for Write Row counter 

output reg [6:0] W_Col_Counter,// output for write Col counter 

output  SE_Start, // flag for Depth to R_Start 

output  R_Depth_Done, // flag for end of reading

output  W_Depth_Done // flag for end of writing also for end of expansion 


);

wire R_Filter_Counter_Flag;

wire W_Filter_Counter_Flag;

wire R_Row_Counter_Flag;

wire R_Col_Counter_Flag;

wire W_Row_Counter_Flag; 

wire W_Col_Counter_Flag;

reg depth_en_temp;//* flag to catch value of Depth enable 

////////////////////////////////
//* depth_en_temp///////////////
///////////////////////////////

always  @ (posedge clk or negedge RST)
    begin
        if(!RST)
            begin
                depth_en_temp<='b0;
            end
        else
            begin
             if(Depth_EN)
                depth_en_temp<='b1;
            else if(R_Depth_Done)
                depth_en_temp<='b0;
            end
    end

//////////////////////////////////
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
                if(!depth_en_temp)
                R_Col_Counter<=R_Start;
                else 
                    begin
                        
                        R_Col_Counter<=R_Col_Counter+Stride;

                       if(R_Col_Counter_Flag==1'b1) //|| R_EX_Done)
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
                if(!depth_en_temp)
                R_Row_Counter<=R_Start;
                
                else if(R_Col_Counter_Flag)
                    begin
                        R_Row_Counter<=R_Row_Counter+Stride;

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
assign R_Depth_Done=(R_Col_Counter_Flag && R_Row_Counter_Flag&&R_Filter_Counter_Flag);



////////////////////////////////////////
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


////////////* Filter Counter For Output to be stored///////////
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

    assign W_Depth_Done=(W_Col_Counter_Flag && W_Row_Counter_Flag && W_Filter_Counter_Flag );

    assign SE_Start=(SE_EN==W_Filter_Counter)&& W_Col_Counter_Flag && W_Row_Counter_Flag;
endmodule