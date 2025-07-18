module bcd(q, clk, reset, enable); //for digits counting from 0 to 9
    input enable, clk, reset;
    output reg [3:0] q;

    always @(posedge clk) begin
        if (reset)
            q <= 4'd0;
        else if (enable) begin
            if (q == 4'b1001)
                q <= 4'b0;
            else
                q <= q + 1;
        end
    end
endmodule



module bcd_5(q, clk, reset, enable); // for digits counting from 0 to 5
    input enable, clk, reset;
    output reg [3:0] q;

    always @(posedge clk) begin
        if (reset)
            q <= 4'd0;
        else if (enable) begin
            if (q == 4'b0101)
                q <= 4'b0;
            else
                q <= q + 1;
        end
    end
endmodule



module top_module(
    input clk,
    input reset,
    input ena,
    output reg pm, //if pm = 0 time is in am
    output reg [7:0] hh, //hour
    output  [7:0] mm, //minute
    output  [7:0] ss //second
);
    wire e1, e2, e3, e4, e5; //enable inputs for each digit 


    assign e1 = ena&&(ss[3:0] == 4'b1001);
    assign e2 = e1 && (ss[7:4] == 4'b0101);
    assign e3 = e2 && (mm[3:0] == 4'b1001);
    assign e4 = e3 && (mm[7:4] == 4'b0101);
    assign e5 = e4 && (hh[3:0] == 4'b1001);

    wire [3:0] ss_lsb, ss_msb;
    wire [3:0] mm_lsb, mm_msb;

    bcd    b1(.q(ss_lsb), .reset(reset), .clk(clk), .enable(ena));
    bcd_5  b2(.q(ss_msb), .reset(reset), .clk(clk), .enable(e1));
    bcd    b3(.q(mm_lsb), .reset(reset), .clk(clk), .enable(e2));
    bcd_5  b4(.q(mm_msb), .reset(reset), .clk(clk), .enable(e3));

    
    assign ss = {ss_msb, ss_lsb};
    assign mm = {mm_msb, mm_lsb};
    

    always @(posedge clk) begin  // logic for lsb oh hour
        if (reset)
            hh[3:0] <= 4'd2; // decimal 2
        else if (e4) begin
            if (hh[3:0] == 4'b1001)
                hh[3:0] <= 4'b0;
            else if((hh[3:0]==4'b0010)&&(hh[7:4]==4'b0001))
                hh[3:0]<=4'b0001;
            else
                hh[3:0] <= hh[3:0] + 1;
        end
    end
    
    always @(posedge clk) begin //logic for msb of hour
        if (reset)
            hh[7:4] <= 4'd1; // decimal 1
        else if (e5||(e4&&(hh[3:0]==4'b0010)&&hh[7:4]==4'b0001)) begin
            if (hh[7:4] == 4'b0001)
                hh[7:4] <= 4'b0;
            else
                hh[7:4] <= hh[7:4] + 1;
        end
    end
    


    always @(posedge clk) begin  //logic for am/pm
        if (reset)
            pm <= 0;
        else if ((ss[7:4] == 4'b0101) && (ss[3:0] == 4'b1001) &&
                 (mm[7:4] == 4'b0101) && (mm[3:0] == 4'b1001) &&
                 (hh[3:0] == 4'b0001) && (hh[7:4] == 4'b0001))
            pm <= ~pm;
    end

endmodule
