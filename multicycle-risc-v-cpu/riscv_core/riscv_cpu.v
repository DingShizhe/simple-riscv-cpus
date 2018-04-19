module riscv_cpu(
	input rst,
	input clk,

	output reg [31:0] PC,
	input [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] WriteData,

	input [31:0] ReadData,
	output MemRead,

	output reg [31:0] cycle_cnt,		//counter of total cycles
	output reg [31:0] inst_cnt,			//counter of total instructions
	output reg [31:0] br_cnt,			//counter of branch/jump instructions
	output reg [31:0] ld_cnt,			//counter of load instructions
	output reg [31:0] st_cnt,			//counter of store instructions
	output reg [31:0] br_taken_cnt,		//user defined counter (reserved)
	output reg [31:0] jmp_cnt,
	output reg [31:0] user3_cnt
	);


	// ALL THE REGS //

    reg [31:0] IR;
    reg [31:0] MemReg;
    reg [31:0] Rdata1;
    reg [31:0] Rdata2;
    reg [31:0] ALU_Out;


	// Instruction Partation //

	wire [6:0] opcode; 				assign opcode = IR[6:0];		//for all type

	wire [6:0] funct7; 				assign funct7 = IR[31:25];	// R-type
	wire [4:0] rs2; 				assign rs2 = IR[24:20];
	wire [4:0] rs1; 				assign rs1 = IR[19:15];
	wire [2:0] funct3; 				assign funct3 = IR[14:12];
	wire [4:0] rd; 					assign rd = IR[11:7];

	wire [11:0] imm11_0; 			assign imm11_0 = IR[31:20];	// I-type
	// wire [4:0] shamt;				assign shamt = IR[24:20];
	// wire [31:0]	shamt_extend;		assign shamt_extend = {27'd0, shamt};
	wire [31:0] I_sign_extend;
									assign I_sign_extend = (IR[31]==0) ?
									{20'd0 ,imm11_0} : {20'hFFFFF ,imm11_0};

	wire [6:0] imm11_5; 			assign imm11_5 = IR[31:25];	// S-type
	wire [4:0] imm4_0; 				assign imm4_0 =	IR[11:7];
	wire [31:0] S_sign_extend;
									assign S_sign_extend = (IR[31]==0) ?
									{20'd0 ,imm11_5, imm4_0} : {20'hFFFFF ,imm11_5, imm4_0};

	wire imm12; 					assign imm12 = 	IR[31];		// B-type
	wire [5:0] imm10_5; 			assign imm10_5 = IR[30:25];
	wire [3:0] imm4_1; 				assign imm4_1 = IR[11:8];
	wire imm11; 					assign imm11 = 	IR[7];
	wire [31:0] B_sign_extend;
									assign B_sign_extend = (imm12==0) ?
									{19'd0, imm12, imm11, imm10_5, imm4_1, 1'd0}
									: {19'h7FFF, imm12, imm11, imm10_5, imm4_1, 1'd0};

	wire [19:0] imm31_12; 			assign imm31_12 = IR[31:12];	// U-type
	wire [31:0] U_sign_extend;
									assign U_sign_extend = {IR[31:12], 12'd0};

	wire imm20; 					assign imm20 =	IR[31];		// J-type
	wire [9:0] imm10_1; 			assign imm10_1 = IR[30:21];
	wire imm_11; 					assign imm_11 = IR[20];			//different from imm11 in B-type
	wire [7:0] imm19_12; 			assign imm19_12 = IR[19:12];
	wire [31:0] J_sign_extend;
									assign J_sign_extend = (IR[31]==0) ?
									{ 11'd0, imm20, imm19_12, imm_11, imm10_1, 1'd0}
									: { 11'h7FF, imm20, imm19_12, imm_11, imm10_1, 1'd0};


	// signals from control unit to datapath//

	wire cu_IRwrite;
	wire cu_Regwrite;
	wire cu_MemWrite;
	wire cu_MemRead;
	wire [1:0] cu_Mem2Reg;
	wire cu_PCwrite;
	wire [1:0] cu_PCsrc;
	wire [1:0] cu_ALUsrcA;
	wire [2:0] cu_ALUsrcB;
	wire cu_Branch;

	// wires about regfiles //

	// wire waddr = rd
	// wire raddr1 = rs1
	// wire raddr2 = rs2
	wire [31:0] rdata1;
	wire [31:0] rdata2;
	wire [31:0] wdata;


	// wires linked with alu //

	wire [31:0] alu_a;
	wire [31:0] alu_b;
	wire [3:0] alu_op;
	wire [31:0] alu_result;
	wire Zero;


	// wires to pc //

	reg branch_taken;
	wire [31:0] PC_next;


	// BEQ funct3[0]==0   BNE funct3[0]==1
	always @( * ) begin
		case (funct3)	// BEQ BNE BGE BGEU BLT BLTU
			3'b000: branch_taken = cu_Branch && (IR[12] ^ Zero);
			3'b001: branch_taken = cu_Branch && (IR[12] ^ Zero);
			3'b101: branch_taken = alu_result && cu_Branch;
			3'b111: branch_taken = alu_result && cu_Branch;
			3'b100: branch_taken = alu_result && cu_Branch;
			3'b110: branch_taken = alu_result && cu_Branch;
			default: branch_taken  =1'b0;
		endcase
	end



	// State and Control unit //

	reg [3:0] State;
	wire [3:0] Next_State;

	cu u_control_unit(.clk(clk),
		// input to cu
		.rst(rst),
		.funct3(funct3),
		.funct7(funct7),
		.opcode(opcode),
		.State(State),

		// output signals
		.cu_IRwrite(cu_IRwrite),
		.cu_Regwrite(cu_Regwrite),
		.cu_MemWrite(cu_MemWrite),
		.cu_MemRead(cu_MemRead),
		.cu_Mem2Reg(cu_Mem2Reg),
		.cu_PCwrite(cu_PCwrite),
		.cu_PCsrc(cu_PCsrc),
		.cu_ALUsrcA(cu_ALUsrcA),
		.cu_ALUsrcB(cu_ALUsrcB),
		.alu_op(alu_op),
		.cu_Branch(cu_Branch),

		.Next_State(Next_State)
		);


	assign MemWrite = cu_MemWrite;
	assign MemRead = cu_MemRead;


	data_path for_data_select(
		// choose PC
		.cu_PCsrc(cu_PCsrc),
		.PC(PC),
		.alu_result(alu_result),
		.PC_next(PC_next),


		// choose write reg data
		.cu_Mem2Reg(cu_Mem2Reg),
		.ALU_out(ALU_Out),
		.MemReg(MemReg),	/* from Readdata*/
		.wdata(wdata),

		// choose alu_a
		.cu_ALUsrcA(cu_ALUsrcA),
		.Rdata1(Rdata1),
		//.PC(PC),
		.alu_a(alu_a),

		// choose alu_b
		.cu_ALUsrcB(cu_ALUsrcB),
		.Rdata2(Rdata2),
		.I_sign_extend(I_sign_extend),
		.S_sign_extend(S_sign_extend),
		.B_sign_extend(B_sign_extend),
		.J_sign_extend(J_sign_extend),
		.U_sign_extend(U_sign_extend),
		// .shamt_extend(shamt_extend),
		.alu_b(alu_b)

		);


	reg_file u_reg_file(
		.clk(clk),
		.rst(rst),
		.waddr(rd),
		.raddr1(rs1),
		.raddr2(rs2),
		.wen(cu_Regwrite),
		.wdata(wdata),
		.rdata1(rdata1),
		.rdata2(rdata2)
		);


	alu u_alu(
		.A(alu_a), .B(alu_b), .ALUop(alu_op),
		.Overflow(),
		.CarryOut(),
		.Zero(Zero),
		.Result(alu_result)
		);



	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			PC <= 32'd0;
			IR <= 32'd0;
			Rdata1 <= 32'd0;
			Rdata2 <= 32'd0;
			ALU_Out <= 32'd0;
			MemReg <= 32'd0;
			State <= 4'd0;
		end
		else begin
			Rdata1 <= rdata1;	// from reg
			Rdata2 <= rdata2;	// from reg
			ALU_Out <= alu_result;
			MemReg <= ReadData;
			State = Next_State;
			if(cu_IRwrite)
				IR <= Instruction;
			if(cu_PCwrite || branch_taken)
				PC <= PC_next;
		end
	end


	assign WriteData = Rdata2;
	assign Address = ALU_Out;


	/* the performance counters */

	always @ (posedge clk) begin
		if(rst) begin
			cycle_cnt <= 32'd0;
			inst_cnt <= 32'd0;
			br_cnt <= 32'd0;
			ld_cnt <= 32'd0;
			st_cnt <= 32'd0;
			br_taken_cnt <= 32'd0;
			jmp_cnt <= 32'd0;
			user3_cnt <= 32'd0;
		end

		else begin
			cycle_cnt <= cycle_cnt + 1;
			inst_cnt <= inst_cnt + {31'd0 ,cu_IRwrite};
			br_cnt <= br_cnt + {31'd0, cu_Branch};
			ld_cnt <= ld_cnt + {31'd0, cu_MemRead};
			st_cnt <= st_cnt + {31'd0, cu_MemWrite};
			br_taken_cnt <= br_taken_cnt + {31'd0, branch_taken};
			jmp_cnt <= jmp_cnt + {31'd0, cu_PCsrc[1]};
			user3_cnt <= user3_cnt + 1;
		end
	end


endmodule
