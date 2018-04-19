/* the INSTRUCTION DECODE stage */

module instr_decode(

	input clk,
	input rst,

	input hz_bubble,

	// signals to regfile
		// write back to here
	input [4:0] WB_rd,
	input [31:0] WB_wdata,
	input WB_RegWrite,


	// ** ID stage to EX stage REGS  **//
	input [31:0] IF_ID_PC,

	output reg [31:0] ID_EX_PC,

	output reg [1:0] ID_EX_PCsrc,

	// Instruction segment REGS
	output reg [4:0] ID_EX_rd,
	output reg [2:0] ID_EX_funct3,

	// datas from regfile
	output reg [31:0] ID_EX_rdata1,
	output reg [31:0] ID_EX_rdata2,

	// signals from contrl_unit
	output reg [3:0] ID_EX_ALUop,
	output reg [1:0] ID_EX_ALU_srcB,

	output reg ID_EX_MemWrite,
	output reg ID_EX_MemRead,

	output reg [1:0] ID_EX_Mem2Reg,
	output reg ID_EX_RegWrite,
	output reg ID_EX_Branch,
	output reg ID_EX_JARL,

	/* output for branch and jump */
	// output reg branch_taken, if branch module is put in decode stage
	output [1:0] cu_PCsrc,
	output cu_jump,
	output cu_Branch,
	output cu_IF_flush,
	output cu_jalr,

	output [31:0] I_sign_extend,
	output [31:0] S_sign_extend,
	output [31:0] J_sign_extend,
	output [31:0] B_sign_extend,
	output [31:0] U_sign_extend,

	output reg [31:0] ID_EX_I_sign_extend,
	output reg [31:0] ID_EX_B_sign_extend,
	output reg [31:0] ID_EX_U_sign_extend,
	output reg [31:0] ID_EX_S_sign_extend,
	
	output reg [4:0] ID_EX_rs1,
	output reg [4:0] ID_EX_rs2,

	output [4:0] rs1,
	output [4:0] rs2,

	input [31:0] IF_ID_Instr,
	output reg [31:0] ID_EX_Instr

);

	/* imm_sign_extends */


	assign I_sign_extend = (IF_ID_Instr[31]==0) 
		? {20'd0 ,IF_ID_Instr[31:20]}
		: {20'hFFFFF ,IF_ID_Instr[31:20]};

	assign S_sign_extend = (IF_ID_Instr[31]==0) 
		? {20'd0 ,IF_ID_Instr[31:25], IF_ID_Instr[11:7]}
		: {20'hFFFFF ,IF_ID_Instr[31:25], IF_ID_Instr[11:7]};

	assign B_sign_extend = (IF_ID_Instr[31]==0) 
		? {19'd0, IF_ID_Instr[31], IF_ID_Instr[7], IF_ID_Instr[31:25], IF_ID_Instr[11:8], 1'd0}
		: {19'h7FFF, IF_ID_Instr[31], IF_ID_Instr[7], IF_ID_Instr[31:25], IF_ID_Instr[11:8], 1'd0};

	assign U_sign_extend = {IF_ID_Instr[31:12], 12'd0};

	assign J_sign_extend = (IF_ID_Instr[31]==0) 
		? { 11'd0, IF_ID_Instr[31], IF_ID_Instr[19:12], IF_ID_Instr[20], IF_ID_Instr[30:21], 1'd0}
		: { 11'h7FF, IF_ID_Instr[31], IF_ID_Instr[19:12], IF_ID_Instr[20], IF_ID_Instr[30:21], 1'd0};

	/* contrl_unit in-out signals and module */

	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;

	assign opcode = IF_ID_Instr[6:0];
	assign funct3 = IF_ID_Instr[14:12];
	assign funct7 = IF_ID_Instr[31:25];

	wire cu_PCwrite;
	wire [1:0] cu_ALU_srcB;
	wire [3:0] cu_alu_op;
	wire cu_MemWrite;
	wire cu_MemRead;
	wire [1:0] cu_Mem2Reg;
	wire cu_IRwrite;
	wire cu_Regwrite;

	contrl_unit u_contrl_unit(
		// input signals
		.funct3(funct3),
		.funct7(funct7),
		.opcode(opcode),

		.hz_bubble(hz_bubble),

		// output signals
		.cu_PCsrc(cu_PCsrc),

		.cu_Branch(cu_Branch),
		.cu_jump(cu_jump),

		.cu_ALU_srcB(cu_ALU_srcB),
		.cu_alu_op(cu_alu_op),

		.cu_MemWrite(cu_MemWrite),
		.cu_MemRead(cu_MemRead),

		.cu_Mem2Reg(cu_Mem2Reg),
		.cu_Regwrite(cu_Regwrite),
		.cu_IF_flush(cu_IF_flush),
		.cu_jalr(cu_jalr)
		
		);


	/* regfiles wires and module */
	// wire [4:0] rs1;
	// wire [4:0] rs2;
	wire [4:0] rd;

	assign rs1 = IF_ID_Instr[19:15];
	assign rs2 = IF_ID_Instr[24:20];
	assign rd = IF_ID_Instr[11:7];


	wire [31:0] rdata1;
	wire [31:0] rdata2;

	reg_file u_reg_file(
		.clk(clk),
		.rst(rst),
		.waddr(WB_rd),
		.raddr1(rs1),
		.raddr2(rs2),
		.wen(WB_RegWrite),
		.wdata(WB_wdata),
		.rdata1(rdata1),
		.rdata2(rdata2)
		);


	// /* Branch judge Part */
	// wire [31:0] branch_cmp_result;
	//
	// branch_cmp_unit c_branch_cmp_unit(
	// 	.branch_cmp_op(funct3),
	// 	.data1(rdata1),
	// 	.data2(rdata2),
	// 	.branch_cmp_result(branch_cmp_result)
	// 	);
	//
	// always @ ( * ) begin
	// 	case (funct3) // BEQ BNE BGE BGEU BLT BLTU
	// 		3'b000: branch_taken = cu_Branch && (branch_cmp_result == 32'd0);
	// 		3'b001: branch_taken = cu_Branch && (branch_cmp_result == 32'd0);
	// 		3'b101: branch_taken = cu_Branch && branch_cmp_result;
	// 		3'b111: branch_taken = cu_Branch && branch_cmp_result;
	// 		3'b100: branch_taken = cu_Branch && branch_cmp_result;
	// 		3'b110: branch_taken = cu_Branch && branch_cmp_result;
	// 		default: branch_taken  =1'b0;
	// 	endcase
	// end



	/* pip pip pip pip  */

	always @(posedge clk) begin

		if(rst) begin

			ID_EX_PC <= 31'd0;
			ID_EX_PCsrc <= 2'b00;

			ID_EX_rd <= 5'd0;
			ID_EX_funct3 <= 3'd0;

			ID_EX_rdata1 <= 32'd0;
			ID_EX_rdata2 <= 32'd0;

			ID_EX_ALU_srcB <= 2'b00;
			ID_EX_ALUop <= 4'b0000;
			ID_EX_MemWrite <= 1'b0;
			ID_EX_MemRead <= 1'b0;
			ID_EX_Mem2Reg <= 2'b00;
			ID_EX_RegWrite <= 1'b0;
			ID_EX_Branch <= 1'b0;
			ID_EX_JARL <= 1'b0;

			ID_EX_B_sign_extend <= 32'd0;
			ID_EX_I_sign_extend <=32'd0;
			ID_EX_U_sign_extend <=32'd0;
			ID_EX_S_sign_extend <=32'd0;

			ID_EX_rs1 <= 5'd0;
			ID_EX_rs2 <= 5'd0;

			ID_EX_Instr <= 32'd0;
		end
		else begin

			ID_EX_PC <= IF_ID_PC;
			ID_EX_PCsrc <= cu_PCsrc;

			ID_EX_rd <= rd;
			ID_EX_funct3 <= funct3;

			ID_EX_rdata1 <= rdata1;
			ID_EX_rdata2 <= rdata2;

			ID_EX_ALU_srcB <= cu_ALU_srcB;
			ID_EX_ALUop <= cu_alu_op;
			ID_EX_MemWrite <= cu_MemWrite;
			ID_EX_MemRead <= cu_MemRead;
			ID_EX_Mem2Reg <= cu_Mem2Reg;
			ID_EX_RegWrite <= cu_Regwrite;
			ID_EX_Branch <= cu_Branch;
			ID_EX_JARL <= cu_jalr;

			ID_EX_B_sign_extend <= B_sign_extend;
			ID_EX_I_sign_extend <= I_sign_extend;
			ID_EX_U_sign_extend <= U_sign_extend;
			ID_EX_S_sign_extend <= S_sign_extend;

			ID_EX_rs1 <= rs1;
			ID_EX_rs2 <= rs2;

			ID_EX_Instr <= IF_ID_Instr;
		end
	end


endmodule
