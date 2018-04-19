module riscv_cpu(

	input wire rst,
	input wire clk,

	output reg [31:0] PC,
	input wire [31:0] Instruction,

	output wire [31:0] Address,
	output wire MemWrite,
	output wire [31:0] WriteData,

	input wire [31:0] ReadData,
	output wire MemRead

	);
	
	/* Instruction partation */

	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;

	assign rs1 = Instruction[19:15];
	assign rs2 = Instruction[24:20];
	assign rd  = Instruction[11:7];

	wire [6:0] opcode;
	wire [6:0] funct7;
	wire [2:0] funct3;

	assign opcode = Instruction[6:0];
	assign funct7 = Instruction[31:25];
	assign funct3 = Instruction[14:12];

	wire [31:0] I_sign_extend;
	wire [31:0] S_sign_extend;
	wire [31:0] B_sign_extend;
	wire [31:0] U_sign_extend;
	wire [31:0] J_sign_extend;

	assign I_sign_extend = (Instruction[31]==0) 
		? {20'd0 ,Instruction[31:20]}
		: {20'hFFFFF ,Instruction[31:20]};

	assign S_sign_extend = (Instruction[31]==0) 
		? {20'd0 ,Instruction[31:25], Instruction[11:7]}
		: {20'hFFFFF ,Instruction[31:25], Instruction[11:7]};

	assign B_sign_extend = (Instruction[31]==0) 
		? {19'd0, Instruction[31], Instruction[7], Instruction[31:25], Instruction[11:8], 1'd0}
		: {19'h7FFF, Instruction[31], Instruction[7], Instruction[31:25], Instruction[11:8], 1'd0};

	assign U_sign_extend = {Instruction[31:12], 12'd0};

	assign J_sign_extend = (Instruction[31]==0) 
		? { 11'd0, Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'd0}
		: { 11'h7FF, Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'd0};


	/* some signals */

	wire [1:0] cu_PC_src;
	wire cu_reg_w_en;
	wire [2:0] cu_alu_b_src;
	wire [3:0] cu_alu_op;
	wire cu_mem_r_en;
	wire cu_mem_w_en;
	wire [1:0] cu_mem_2_reg;
	wire cu_branch;

	/* the control unit */
	cu u_cu(

		.opcode (opcode),
		.funct3 (funct3),
		.funct7 (funct7),

		.cu_PC_src  (cu_PC_src),

		.cu_reg_w_en  (cu_reg_w_en),

		.cu_alu_b_src  (cu_alu_b_src),
		.cu_alu_op  (cu_alu_op),

		.cu_mem_r_en  (cu_mem_r_en),
		.cu_mem_w_en  (cu_mem_w_en),
		.cu_mem_2_reg  (cu_mem_2_reg),

		.cu_branch  (cu_branch)
		);


	reg branch_taken;
	wire [31:0] PC_next;

	wire [31:0] reg_w_data;
	wire [31:0] reg_r_data1;
	wire [31:0] reg_r_data2;

	wire [31:0] alu_a;
	wire [31:0] alu_b;
	wire [31:0] alu_result;

	/* select datas */
	data_path u_for_data_select(

		// next pc
		.cu_PC_src(cu_PC_src),
		.branch_taken(branch_taken),
		.PC(PC),
		.I_sign_extend(I_sign_extend),
		.J_sign_extend(J_sign_extend),
		.B_sign_extend(B_sign_extend),
		.PC_next(PC_next),

		// w reg data
		.cu_mem_2_reg(cu_mem_2_reg),
		.alu_result(alu_result),
		.mem_r_data(ReadData),
		.reg_w_data(reg_w_data),

		// alu_b
		.cu_alu_b_src(cu_alu_b_src),
		.reg_r_data2(reg_r_data2),
		.S_sign_extend(S_sign_extend),
		.U_sign_extend(U_sign_extend),
		.alu_b(alu_b)

		);
	/*regfiles*/
	reg_file u_reg_file(
		.clk(clk),
		.rst(rst),

		.waddr(rd),
		.raddr1(rs1),
		.raddr2(rs2),
		.wen(cu_reg_w_en),
		.wdata(reg_w_data),

		.rdata1(reg_r_data1),
		.rdata2(reg_r_data2)
		);

	assign alu_a = reg_r_data1;

	/* alu */
	alu u_alu(
		.A(alu_a),
		.B(alu_b),
		.ALUop(cu_alu_op),

		.Overflow(),
		.CarryOut(),
		.Zero(),
		.Result(alu_result)
		);

	/* judge branch */ 
	always @( * ) begin
        case (funct3) // BEQ BNE BGE BGEU BLT BLTU
            3'b000: branch_taken = cu_branch && (alu_result == 32'd0);
            3'b001: branch_taken = cu_branch && (alu_result != 32'd0);
            3'b101: branch_taken = cu_branch && alu_result;
            3'b111: branch_taken = cu_branch && alu_result;
            3'b100: branch_taken = cu_branch && alu_result;
            3'b110: branch_taken = cu_branch && alu_result;
            default: branch_taken  =1'b0;
        endcase
	end

	/* update pc */
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// reset
			PC <= 32'd0;
		end
		else begin
			PC <= PC_next;
		end
	end

	assign WriteData = reg_r_data2;
	assign MemWrite = cu_mem_w_en;
	assign MemRead = cu_mem_r_en;
	assign Address = alu_result;

endmodule
