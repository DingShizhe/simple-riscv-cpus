/* =========================================
* Ideal Memory Module for MIPS CPU Core
* Synchronize write (clock enable)
* Asynchronize read (do not use clock signal)
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 31/05/2016
* Version: v0.0.1
*===========================================
*/

`timescale 1 ps / 1 ps

module ideal_mem #(
	parameter ADDR_WIDTH = 11,
	parameter MEM_WIDTH = 2 ** (ADDR_WIDTH - 2)
	) (
	input			clk,			//source clock of the MIPS CPU Evaluation Module

	input [ADDR_WIDTH - 3:0]	Waddr,			//Memory write port address
	input [ADDR_WIDTH - 3:0]	Raddr1,			//Read port 1 address
	input [ADDR_WIDTH - 3:0]	Raddr2,			//Read port 2 address

	input			Wren,			//write enable
	input			Rden1,			//port 1 read enable
	input			Rden2,			//port 2 read enable

	input [31:0]	Wdata,			//Memory write data
	output [31:0]	Rdata1,			//Memory read data 1
	output [31:0]	Rdata2			//Memory read data 2
);

reg [31:0]	mem [MEM_WIDTH - 1:0];


`ifdef MIPS_CPU_SIM

	initial begin
	//Add memory initialization here
	// pass: sum pascal fib mov-c bubble-sort if-else switch add max min3 select-sort quick-sort
	// loop: 
	// fail: 

	`include "/home/dingshizhe/Documents/CCP_Exp/happy_summer_holiday/risc-v-cpu-test/sim2/quick-sort.vh"

	end
	always@(posedge clk) begin
	    if(mem[2] == 32'd0) begin
	    $display("pass");
	    $finish;
	    end
	    else if(mem[2] == 32'd1) begin
	    $display("fail");
	    $finish;
	    end
    end
`endif

always @ (posedge clk)
begin
	if (Wren)
		mem[Waddr] <= Wdata;
end

assign Rdata1 = {32{Rden1}} & mem[Raddr1];
assign Rdata2 = {32{Rden2}} & mem[Raddr2];

endmodule
