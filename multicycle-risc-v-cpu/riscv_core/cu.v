module cu(
	input clk,
	input rst,
	input [2:0] funct3,
	input [6:0] funct7,
	input [6:0] opcode,
	input [3:0] State,

	// output signals
	output reg cu_IRwrite,
	output reg cu_Regwrite,
	output reg cu_MemWrite,
	output reg cu_MemRead,
	output reg [1:0] cu_Mem2Reg,
	output reg cu_PCwrite,
	output reg [1:0] cu_PCsrc,
	output reg [1:0] cu_ALUsrcA,
	output reg [2:0] cu_ALUsrcB,
	output reg [3:0] alu_op,
	output reg cu_Branch,

	output reg [3:0] Next_State
	);

	reg [1:0] cu_ALUop;

	// S-type
	parameter SW_op = 		7'b0100011;

	// I-type
	parameter JALR_op = 	7'b1100111;
	parameter LW_op = 		7'b0000011;
	parameter Itype_op = 	7'b0010011;

	// R-type
	parameter Rtype_op = 	7'b0110011;

	// J-type & B-type
	parameter JAL_op = 		7'b1101111;
	parameter Btype_op = 	7'b1100011;

	// U-type
	parameter LUI_op = 		7'b0110111;
	parameter AUIPC_op = 	7'b0010111;



	always @( * ) begin
		if (rst) begin
			cu_IRwrite = 1'b0;
			cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
			cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
			cu_PCwrite = 1'b0;	cu_PCsrc = 2'b00;  cu_Branch = 1'b0;
			cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b00;
			// Next State
			Next_State = 4'd0;
			end
		else begin
			case (State)
			// Instruction Fetch
				4'd0: begin
					cu_IRwrite = 1'b1;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b1;	cu_PCsrc = 2'b00;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b01;	cu_ALUsrcB = 3'b001; cu_ALUop = 2'b00;
					// Next State
					Next_State = 4'd1;
				end

			// Instruction Decode
				4'd1: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b00;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b00;
					// Next State
					case(opcode)
						Rtype_op: Next_State = 4'd2;
						Itype_op: Next_State = 4'd4;
						JALR_op:  Next_State = 4'd4;
						Btype_op: Next_State = 4'd5;
						JAL_op:	  Next_State = 4'd6;
						SW_op: 	  Next_State = 4'd7;
						LW_op:	  Next_State = 4'd7;
						LUI_op:	  Next_State = 4'd11;
						default: Next_State = 4'd0;
					endcase
				end

			// Rtype Execution
				4'd2: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b00;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b01;
					// Next State Rtype
					Next_State = 4'd3;
				end

			// Rtype Itype Utype Store
				4'd3: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b1;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b00;
					// Next State
					Next_State = 0;

					if (opcode==JALR_op) begin
						cu_PCwrite = 1;
						cu_PCsrc = 2'b11;
						cu_Mem2Reg = 2'b10;
					end
					else begin
						cu_PCwrite = 0;
						cu_PCsrc = 0;
						cu_Mem2Reg = 2'b00;
					end
				end

			// Itype Execution
				4'd4: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b00;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b010; cu_ALUop = 2'b10;
					// Next State
					Next_State = 3;
				end


			// Btype
				4'd5: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b01;  cu_Branch = 1'b1;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b11;
					// Next State
					Next_State = 0;
				end

			// Jump and link
				4'd6: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b1; cu_Mem2Reg = 2'b10;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b1;	cu_PCsrc = 2'b10;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b00;
					// Next State
					Next_State = 0;
				end


			// SW & LW
				4'd7: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b10;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	/*cu_ALUsrcB*/ cu_ALUop = 2'b00;
					// Next State
					case(opcode)
						SW_op: begin
							Next_State = 4'd8;
							cu_ALUsrcB = 3'b011;
						end
						LW_op: begin
							Next_State = 4'd9;
							cu_ALUsrcB = 3'b010;
						end
						default: begin
							Next_State = 4'd0;
							cu_ALUsrcB = 3'b000;
						end
					endcase
				end

			// SW
				4'd8: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b01;
					cu_MemWrite = 1'b1;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b10;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b011; cu_ALUop = 2'b00;
					// Next State
					Next_State = 0;
				end

			// LW
				4'd9: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b1;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b10;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b00;
					// Next State
					Next_State = 4'd10;
				end


			// LW
				4'd10: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b1; cu_Mem2Reg = 2'b01;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b10;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 3'b000; cu_ALUop = 2'b00;
					// Next State
					Next_State = 4'd0;
				end


			// Utype Execution  LUI
				4'd11: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b0;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b00;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b10;	cu_ALUsrcB = 3'b110; cu_ALUop = 2'b00;
					// Next State
					Next_State = 4'd3;
				end


				default: begin
					cu_IRwrite = 1'b0;
					cu_Regwrite = 1'b0; cu_Mem2Reg = 2'b00;
					cu_MemWrite = 1'b1;	cu_MemRead = 1'b0;
					cu_PCwrite = 1'b0;	cu_PCsrc = 2'b00;  cu_Branch = 1'b0;
					cu_ALUsrcA = 2'b00;	cu_ALUsrcB = 2'b00; cu_ALUop = 2'b00;
					// Next State
					Next_State = 4'd0;
				end

			endcase


			case(cu_ALUop)
				2'b00: alu_op = 4'b0010;

				// R-type
				2'b01: case({funct3, funct7})
					//ADD
					{3'b000, 7'b0000000}: alu_op = 4'b0010;
					//SUB
					{3'b000, 7'b0100000}: alu_op = 4'b0110;
					//SLL
					{3'b001, 7'b0000000}: alu_op = 4'b0100;
					//SLT
					{3'b010, 7'b0000000}: alu_op = 4'b0111;
					//AND
					{3'b111, 7'b0000000}: alu_op = 4'b0000;
					//default
					default: 			  alu_op = 4'b0000;
				endcase

				// I-type
				2'b10: case(funct3)
					// ADDI
					3'b000: alu_op = 4'b0010;
					// SLTI
					3'b010: alu_op = 4'b0111;
					// SLLI
					3'b001: alu_op = 4'b0100;
					// default
					default: alu_op = 4'b0000;
				endcase

				// B-type
				2'b11: case(funct3)
					// BEQ
					3'b000: alu_op = 4'b0110;
					// BNE
					3'b001: alu_op = 4'b0110;
					// BLT BGT
					3'b100: alu_op = 4'b0111;
					// BGE BLE
					3'b101: alu_op = 4'b1111;
					// BGEU BLEU
					3'b111: alu_op = 4'b0011;
					// BLTU
					3'b110: alu_op = 4'b1011;
					// default
					default: alu_op = 4'b0110;

				endcase

				default: alu_op = 4'b0000;
			endcase
		end

	end


endmodule
