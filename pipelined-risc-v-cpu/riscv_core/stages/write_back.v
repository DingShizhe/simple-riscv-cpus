/*the WRITE BACK stage*/

module write_back(
	input clk,
	input rst,

	input [4:0] MEM_WB_rd,

	input MEM_WB_RegWrite,
	input [1:0] MEM_WB_Mem2Reg,
	input [31:0] MEM_WB_ALU_Result,
	input [31:0] MEM_WB_PC,
	input [31:0] MEM_WB_ReadData,

	/* write back to regfile */
	output [4:0] WB_rd,
	output reg [4:0] WB_rd_reg,
	output WB_RegWrite,
	output reg [31:0] WB_wdata,
	output reg [31:0] WB_wdata_reg,
	output reg WB_RegWrite_reg

);
	/* Write regfile data selector */
	always @( * ) begin
		case(MEM_WB_Mem2Reg)
			2'b00: WB_wdata = MEM_WB_ALU_Result;
			2'b01: WB_wdata = MEM_WB_ReadData;
			2'b10: WB_wdata = MEM_WB_PC;
			default: WB_wdata = MEM_WB_ALU_Result;
		endcase
	end

	/* Write Address */
	assign WB_rd = MEM_WB_rd;

	/* Write enable */
	assign WB_RegWrite = MEM_WB_RegWrite;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			WB_wdata_reg <= 32'd0;
			WB_rd_reg <= 5'd0;
			WB_RegWrite_reg <= 1'd0;
		end
		else begin
			WB_wdata_reg <= WB_wdata;
			WB_rd_reg <= WB_rd;
			WB_RegWrite_reg <= MEM_WB_RegWrite;
		end
	end
endmodule
