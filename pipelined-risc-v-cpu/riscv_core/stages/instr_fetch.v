/*the INSTRUCTION FETCH stage*/

module instr_fetch(

	input clk,
	input rst,
	input hz_IF_ID_Write,
	input cu_IF_flush,
	input ID_EX_Branch,
	input ID_EX_JARL,

	input [31:0] Instruction,
	// next pc
	input branch_taken,
	// input cu_jalr,
	input [1:0] cu_PCsrc,
	input [1:0] ID_EX_PCsrc,
	input [31:0] PC,
	
	input [31:0] EX_B_sign_extend,
	input [31:0] J_sign_extend,
	input [31:0] alu_result,

	output reg [31:0] IF_ID_Instr,
	output reg [31:0] IF_ID_PC,

	output reg [31:0] PC_next
);

	always @(posedge clk) begin
		// branch flush 2 times
		// jump flush 1 times
		if(rst || cu_IF_flush || ID_EX_Branch || ID_EX_JARL) begin
			IF_ID_Instr <= 32'd0;
		end
		else if (hz_IF_ID_Write) begin
			IF_ID_Instr <= Instruction;
		end
		// stall
		else begin
			IF_ID_Instr <= IF_ID_Instr;
		end

	end


	always @( *  ) begin
		// PC_add4 = PC + 32'd4;
		IF_ID_PC = PC;
	end


	/* PC_next selector */


    always @( * ) begin
        case((branch_taken || ID_EX_JARL) ? ID_EX_PCsrc : cu_PCsrc)
            2'b00: PC_next = PC + 32'd4;
                // branch
            2'b01: PC_next = PC + EX_B_sign_extend - 32'd4;
                // jal
            2'b10: PC_next = PC + J_sign_extend - 32'd4;
                // jalr
            2'b11: PC_next = alu_result;
        endcase
    end


endmodule
