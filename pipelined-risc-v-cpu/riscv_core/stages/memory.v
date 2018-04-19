/*the MEMORY stage*/

module memory(

	input clk,
	input rst,

	input [4:0] EX_MEM_rd,
	input [31:0] EX_MEM_PC,
	////
	output reg [4:0] MEM_WB_rd,
	output reg [31:0] MEM_WB_PC,

	// signals and datas from EX stage to MEM stage
	input [31:0] EX_MEM_ALU_Result,
	input [31:0] EX_MEM_rdata2,

	input EX_MEM_MemWrite,
	input EX_MEM_MemRead,

	input [1:0] EX_MEM_Mem2Reg,
	input EX_MEM_RegWrite,

	// outputs to or ideal_mem
	output wire [31:0] Address,
	output wire [31:0] WriteData,
	output wire MemWrite,
	output wire MemRead,

	// input from ideal_mem
	input [31:0] ReadData,

	// output to WB stage
	output reg [31:0] MEM_WB_ReadData,
	output reg [31:0] MEM_WB_ALU_Result,
	output reg [1:0] MEM_WB_Mem2Reg,
	output reg MEM_WB_RegWrite,

	input [31:0] EX_MEM_Instr,
	output reg [31:0] MEM_WB_Instr
);

	assign Address = EX_MEM_ALU_Result;
	assign WriteData = EX_MEM_rdata2;
	assign MemWrite = EX_MEM_MemWrite;
	assign MemRead = EX_MEM_MemRead;

	/* pip pip pip pip */

	always @(posedge clk) begin

		if(rst) begin
			MEM_WB_PC <= 32'd0;
			MEM_WB_rd <= 5'd0;
			MEM_WB_ReadData <= 32'd0;
			MEM_WB_ALU_Result <= 32'b0;
			MEM_WB_RegWrite <= 1'b0;
			MEM_WB_Mem2Reg <= 2'b00;

			MEM_WB_Instr <= 32'd0;
		end
		else begin
			MEM_WB_PC <= EX_MEM_PC;
			MEM_WB_rd <= EX_MEM_rd;
			MEM_WB_ReadData <= ReadData;
			MEM_WB_RegWrite <= EX_MEM_RegWrite;
			MEM_WB_Mem2Reg <= EX_MEM_Mem2Reg;
			MEM_WB_ALU_Result <= EX_MEM_ALU_Result;

			MEM_WB_Instr <= EX_MEM_Instr;
		end

	end

endmodule
