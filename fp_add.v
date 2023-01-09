`timescale 1ns / 1ps
module fp_add #(
    parameter Q = 6,
    parameter N = 16
    )(
    input clk,
    input  [N-1:0] a_in,
    input  [N-1:0] b_in,
    output [N-1:0] c_out
    );
    
    wire s1,s2; // input signs
    wire [N-2:0] a,b; // integer parts
    reg res_sign;
    reg [N-2:0] res;
    
    // (Q,N) = (12,16) => 1 sign + 3 integer + 12 fractonal = 16 total bits
    //                    |S|III|FFFFFFFFFFFF|
    // The same thing in A(I,F) format would be A(3,12)
    
    // Since we supply every negative number in it's 2'compliment form by default, all we
    // need to do is add these two numbers together (note that to subtract a binary number 
    //is the same as to add its 2's complement

    // Parse Numbers
    assign s1 = a_in[N-1];
    assign  a = a_in[N-2:0];
    assign s2 = b_in[N-1];
    assign  b = b_in[N-2:0];
    
    //assign c = res;
    
    always@(*) begin
        // Case 1: Both negative or both Positive
        if (s1 == s2) begin  
            res = a + b; // Add absolute magnitude 
            res_sign = s1;              //Both input has same sign
        end 
        // Case 2: One of them is Negative (a = +ve, b = -ve)
        else if(s1== 0 && s2 == 1) begin // Subtrcat a - b
            if(a > b) begin        // a > b
                res = a - b; // Subtract b from a
                res_sign = 0;                
            end
            else begin
                res = b - a; // Subtract a from b to avoid 2' complement answer
                if(res==0)
                    res_sign = 0;  // Dont' like -ve 0
                else
                    res_sign = 1;  // manually set sign to -ve 
            end          
        end
        // Case 3: (a = -ve, b = +ve)
        else begin
             if(a > b) begin        // a > b
                res = a - b; // Subtract b from a to avoid 2' complement answer
                if(res==0)
                    res_sign = 0;  // Dont' like -ve 0
                else
                    res_sign = 1;  // manually set sign to -ve             
            end
            else begin
                res = b - a; // Subtract a from b
                res_sign = 0; // manually set sign to +ve 
            end
        end
    end
    
    assign c_out = {res_sign,res};
    
endmodule
