`timescale 10 ns / 1 ns

module reg_file(
	input clk,
	input rst,
	input [4:0] waddr,
	input [4:0] raddr1,
	input [4:0] raddr2,
	input wen,
	input [31:0] wdata,
	output [31:0] rdata1,
	output [31:0] rdata2
);

	// TODO: insert your code

	    
    parameter count = 1<<5;

    reg [31:0] REG_Files[count - 1:0];
    integer i;

    always @ (posedge clk) begin
        if(rst) begin
            for(i=0;i<count;i=i+1)
                REG_Files[i] <= 0;
        end
        else if (wen) begin
            if(waddr) REG_Files[waddr] <= wdata;
            else REG_Files[waddr] <= 0;
        end
    end

    assign rdata1 = REG_Files[raddr1];
    assign rdata2 = REG_Files[raddr2];


	
endmodule
