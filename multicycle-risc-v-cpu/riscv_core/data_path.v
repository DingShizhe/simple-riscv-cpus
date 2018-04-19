// Give how data selected by the chontrol unit
// pc, waddr, wdata, alu_a, alu_b and so on...

module data_path(

	// choose pc
	input [1:0] cu_PCsrc,
	input [31:0] PC,
	input [31:0] alu_result,
	output reg [31:0] PC_next,

	// // choose write reg address
	// input cu_RegDst,
	// input [4:0] rs1,
	// input [4:0] rs2,
	// output reg [4:0] waddr,

	// choose write reg data
	input [1:0] cu_Mem2Reg,
	input [31:0] ALU_out,
	input [31:0] MemReg,	// from Readdata
	output reg [31:0] wdata,

	// choose alu_a
	input [1:0] cu_ALUsrcA,
	input [31:0] Rdata1,
	output reg [31:0] alu_a,

	// choose alu_b
	input [2:0] cu_ALUsrcB,
	input [31:0] Rdata2,
		// input [31:0] PC,
	input [31:0] I_sign_extend,
	input [31:0] S_sign_extend,
	input [31:0] B_sign_extend,
	input [31:0] J_sign_extend,
	input [31:0] U_sign_extend,
	// input [31:0] shamt_extend,
	output reg [31:0] alu_b

	// choose Memory Address
	// input

	);

	// pc source
	always @( * ) begin
		case(cu_PCsrc)
			2'b00: PC_next = alu_result;
				// ////add module needed
				// branch
			2'b01: PC_next = PC + B_sign_extend - 32'd4;
				// jump and link
			2'b10: PC_next = PC + J_sign_extend - 32'd4;
			2'b11: PC_next = ALU_out;
		endcase
	end

	// regfile r & w source
	always @( * ) begin
		case(cu_Mem2Reg)
			2'b00: wdata = ALU_out;
			2'b01: wdata = MemReg;
			2'b10: wdata = PC;
			default: wdata = MemReg;
		endcase
	end

	// alu a & b source
	always @( * ) begin
		case (cu_ALUsrcA)
			2'b00: alu_a = Rdata1;
			2'b01: alu_a = PC;
			2'b10: alu_a = 0;
			default: alu_a = Rdata1;
		endcase

		case (cu_ALUsrcB)
			3'b000: alu_b = Rdata2;
			3'b001: alu_b = 32'd4;
			3'b010: alu_b = I_sign_extend;
			3'b011: alu_b = S_sign_extend;
			3'b100: alu_b = B_sign_extend;
			3'b101: alu_b = J_sign_extend;
			3'b110: alu_b = U_sign_extend;
			// 3'b111: alu_b = shamt_extend;
			default: alu_b = Rdata2;
		endcase
	end


endmodule
