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

	wire hz_PC_Write;
	wire hz_bubble;
	wire hz_IF_ID_Write;
	wire cu_IF_flush;
	wire cu_Branch;
	wire cu_jalr;

	wire [1:0] cu_PCsrc;
	wire [1:0] ID_EX_PCsrc;

	wire [31:0] PC_next;
	wire [31:0] IF_ID_PC;
	wire [31:0] B_sign_extend;
	wire [31:0] EX_B_sign_extend;
	wire [31:0] I_sign_extend;
	wire [31:0] J_sign_extend;
	wire [31:0] alu_result;

	wire [31:0] IF_ID_Instr;
	wire [31:0] ID_EX_Instr;
	wire [31:0] EX_MEM_Instr;
	wire [31:0] MEM_WB_Instr;

	wire ID_EX_Branch;
	wire ID_EX_JARL;
	wire branch_taken;

	instr_fetch u_instr_fetch(
		.clk(clk),
		.rst(rst),
		.hz_IF_ID_Write(hz_IF_ID_Write),
		.cu_IF_flush(cu_IF_flush),
		.ID_EX_Branch(ID_EX_Branch),
		.ID_EX_JARL(ID_EX_JARL),

		.Instruction(Instruction),

		.branch_taken(branch_taken),
		// .cu_jalr(cu_jalr),
		.cu_PCsrc(cu_PCsrc),
		.ID_EX_PCsrc(ID_EX_PCsrc),
		.PC(PC),

		.EX_B_sign_extend(EX_B_sign_extend),
		.J_sign_extend(J_sign_extend),
		.alu_result(alu_result),

		.IF_ID_Instr(IF_ID_Instr),
		.IF_ID_PC(IF_ID_PC),

		.PC_next(PC_next)	// pc_next then update pc
		);


	// update PC
	always @ (posedge clk) begin
		if(rst)begin
			PC <= 32'd0;
		end

		else begin
		// branch stall 2 ,,,  pc + 1 * 4
			if(hz_PC_Write && ((~cu_Branch) && (~cu_jalr)))
				PC <= PC_next;
			else
				PC <= PC;
		end
	end

	// write back to instr_decode stage
	wire [4:0] WB_rd;
	wire [4:0] WB_rd_reg;
	wire [31:0] WB_wdata;
	wire [31:0] WB_wdata_reg;
	// wire WB_;
	wire WB_RegWrite_reg;

	// output signals from decode stage
	wire [31:0] ID_EX_PC;
	wire [4:0] ID_EX_rd;
	wire [2:0] ID_EX_funct3;
	wire [31:0] ID_EX_rdata1;
	wire [31:0] ID_EX_rdata2;
	wire [1:0] ID_EX_ALU_srcB;
	wire [3:0] ID_EX_ALUop;
	wire ID_EX_MemWrite;
	wire ID_EX_MemRead;
	wire [1:0] ID_EX_Mem2Reg;
	wire ID_EX_RegWrite;
	wire [31:0] S_sign_extend;
	wire [31:0] U_sign_extend;

	wire [31:0] ID_EX_B_sign_extend;
	wire [31:0] ID_EX_I_sign_extend;
	wire [31:0] ID_EX_U_sign_extend;
	wire [31:0] ID_EX_S_sign_extend;

	wire [4:0] ID_EX_rs1;
	wire [4:0] ID_EX_rs2;

	wire [4:0] rs1;
	wire [4:0] rs2;


	instr_decode u_instr_decode(
		.clk(clk),
		.rst(rst),

		.hz_bubble(hz_bubble),

		.WB_rd(WB_rd),
		.WB_wdata(WB_wdata),
		.WB_RegWrite(WB_RegWrite),

		.IF_ID_PC(IF_ID_PC),

		.ID_EX_PCsrc(ID_EX_PCsrc),

		.ID_EX_PC(ID_EX_PC),
		.ID_EX_rd(ID_EX_rd),
		.ID_EX_funct3(ID_EX_funct3),
		.ID_EX_rdata1(ID_EX_rdata1),
		.ID_EX_rdata2(ID_EX_rdata2),
		.ID_EX_ALU_srcB(ID_EX_ALU_srcB),
		.ID_EX_ALUop(ID_EX_ALUop),

		.ID_EX_MemWrite(ID_EX_MemWrite),
		.ID_EX_MemRead(ID_EX_MemRead),
		.ID_EX_Mem2Reg(ID_EX_Mem2Reg),
		.ID_EX_RegWrite(ID_EX_RegWrite),
		.ID_EX_Branch(ID_EX_Branch),
		.ID_EX_JARL(ID_EX_JARL),

		.cu_PCsrc(cu_PCsrc),
		.cu_jump(cu_jump),
		.cu_Branch(cu_Branch),
		.cu_IF_flush(cu_IF_flush),
		.cu_jalr(cu_jalr),

		.I_sign_extend(I_sign_extend),
		.S_sign_extend(S_sign_extend),
		.J_sign_extend(J_sign_extend),
		.B_sign_extend(B_sign_extend),
		.U_sign_extend(U_sign_extend),

		.ID_EX_B_sign_extend(ID_EX_B_sign_extend),
		.ID_EX_I_sign_extend(ID_EX_I_sign_extend),
		.ID_EX_U_sign_extend(ID_EX_U_sign_extend),
		.ID_EX_S_sign_extend(ID_EX_S_sign_extend),

		.ID_EX_rs1(ID_EX_rs1),
		.ID_EX_rs2(ID_EX_rs2),

		.rs1(rs1),
		.rs2(rs2),

		.IF_ID_Instr(IF_ID_Instr),
		.ID_EX_Instr(ID_EX_Instr)

		);


	hazrd_unit u_hazrd_unit(
		.clk(clk),
		.rst(rst),
		.ID_EX_MemRead(ID_EX_MemRead),
		.rs1(rs1),
		.rs2(rs2),
		.ID_EX_rd(ID_EX_rd),

		.hz_bubble(hz_bubble),
		.hz_PC_Write(hz_PC_Write),
		.hz_IF_ID_Write(hz_IF_ID_Write)
		);

	wire [1:0] forward_A;
	wire [1:0] forward_B;

	wire [4:0] EX_MEM_rd;
	wire [31:0] EX_MEM_PC;
	wire [31:0] EX_MEM_ALU_Result;
	wire [31:0] EX_MEM_rdata2;
	wire EX_MEM_MemWrite;
	wire EX_MEM_MemRead;
	wire [1:0] EX_MEM_Mem2Reg;
	wire EX_MEM_IRWrite;
	wire EX_MEM_RegWrite;

	execution u_execution(
		.clk (clk),
		.rst (rst),

		.ID_EX_rd (ID_EX_rd),
		.ID_EX_funct3 (ID_EX_funct3),
		.ID_EX_PC (ID_EX_PC),

		.EX_MEM_rd (EX_MEM_rd),
		.EX_MEM_PC (EX_MEM_PC),

		.ID_EX_rdata1 (ID_EX_rdata1),
		.ID_EX_rdata2 (ID_EX_rdata2),
		.ID_EX_ALU_srcB (ID_EX_ALU_srcB),
		.ID_EX_ALUop (ID_EX_ALUop),
		.ID_EX_MemWrite (ID_EX_MemWrite),
		.ID_EX_MemRead (ID_EX_MemRead),
		.ID_EX_Mem2Reg (ID_EX_Mem2Reg),
		.ID_EX_RegWrite (ID_EX_RegWrite),
		.ID_EX_Branch (ID_EX_Branch),

		.EX_MEM_ALU_Result (EX_MEM_ALU_Result),
		.alu_result(alu_result),

		.EX_MEM_rdata2 (EX_MEM_rdata2),
		.EX_MEM_MemWrite (EX_MEM_MemWrite),
		.EX_MEM_MemRead (EX_MEM_MemRead),
		.EX_MEM_Mem2Reg (EX_MEM_Mem2Reg),
		.EX_MEM_RegWrite (EX_MEM_RegWrite),

		.forward_A (forward_A),
		.forward_B (forward_B),

		.WB_wdata (WB_wdata),
		.WB_wdata_reg (WB_wdata_reg),
		.ID_EX_U_sign_extend (ID_EX_U_sign_extend),
		.ID_EX_I_sign_extend (ID_EX_I_sign_extend),
		.ID_EX_S_sign_extend (ID_EX_S_sign_extend),
		.ID_EX_B_sign_extend (ID_EX_B_sign_extend),

		.branch_taken (branch_taken),
		.EX_B_sign_extend (EX_B_sign_extend),

		.ID_EX_Instr(ID_EX_Instr),
		.EX_MEM_Instr(EX_MEM_Instr)

		);

	wire [4:0] MEM_WB_rd;
	wire MEM_WB_RegWrite;

	forwarding_unit u_forwarding_unit(
		.EX_MEM_RegWrite (EX_MEM_RegWrite),
		.MEM_WB_RegWrite (MEM_WB_RegWrite),
		.WB_RegWrite_reg (WB_RegWrite_reg),

		.EX_MEM_rd (EX_MEM_rd),
		.MEM_WB_rd (MEM_WB_rd),
		.WB_rd_reg (WB_rd_reg),
		.ID_EX_rs1 (ID_EX_rs1),
		.ID_EX_rs2 (ID_EX_rs2),

		.forward_A (forward_A),
		.forward_B (forward_B)
		);

	wire [31:0] MEM_WB_PC;
	wire [31:0] MEM_WB_ReadData;
	wire [31:0] MEM_WB_ALU_Result;
	wire [1:0] MEM_WB_Mem2Reg;

	memory u_memory(
		.clk (clk),
		.rst (rst),
		.EX_MEM_rd (EX_MEM_rd),
		.EX_MEM_PC (EX_MEM_PC),
		.MEM_WB_rd (MEM_WB_rd),
		.MEM_WB_PC (MEM_WB_PC),

		.EX_MEM_ALU_Result (EX_MEM_ALU_Result),
		.EX_MEM_rdata2 (EX_MEM_rdata2),
		.EX_MEM_MemWrite (EX_MEM_MemWrite),
		.EX_MEM_MemRead (EX_MEM_MemRead),
		.EX_MEM_Mem2Reg (EX_MEM_Mem2Reg),
		.EX_MEM_RegWrite (EX_MEM_RegWrite),

		.Address (Address),
		.WriteData (WriteData),
		.MemWrite (MemWrite),
		.MemRead (MemRead),
		.ReadData (ReadData),

		.MEM_WB_ReadData (MEM_WB_ReadData),
		.MEM_WB_ALU_Result (MEM_WB_ALU_Result),
		.MEM_WB_Mem2Reg (MEM_WB_Mem2Reg),
		.MEM_WB_RegWrite (MEM_WB_RegWrite),

		.EX_MEM_Instr(EX_MEM_Instr),
		.MEM_WB_Instr(MEM_WB_Instr)

		);


	write_back u_write_back(
		.clk(clk),
		.rst(rst),

		.MEM_WB_rd (MEM_WB_rd),

		.MEM_WB_RegWrite (MEM_WB_RegWrite),
		.MEM_WB_Mem2Reg (MEM_WB_Mem2Reg),
		.MEM_WB_ALU_Result (MEM_WB_ALU_Result),
		.MEM_WB_PC (MEM_WB_PC),
		.MEM_WB_ReadData (MEM_WB_ReadData),

		.WB_rd (WB_rd),
		.WB_rd_reg (WB_rd_reg),
		.WB_RegWrite(WB_RegWrite),
		.WB_wdata (WB_wdata),
		.WB_wdata_reg (WB_wdata_reg),
		.WB_RegWrite_reg (WB_RegWrite_reg)
		);


	/* the performance counters */

	always @ ( posedge clk ) begin
		if (rst) begin
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

			inst_cnt <= inst_cnt + {31'd0, hz_IF_ID_Write || ~(rst || cu_IF_flush || ID_EX_Branch || ID_EX_JARL)};

			br_cnt <= br_cnt + {31'd0, cu_Branch};
			ld_cnt <= ld_cnt + {31'd0, cu_MemRead};
			st_cnt <= st_cnt + {31'd0, cu_MemWrite};
			br_taken_cnt <= br_taken_cnt + {31'd0, branch_taken};
			jmp_cnt <= jmp_cnt + {31'd0, (cu_jalr||cu_jump)};
			user3_cnt <= user3_cnt + 1;
		end
	end
endmodule
