/*the EXECUTION stage*/

module execution(

	input clk,
	input rst,

	//
	input [4:0] ID_EX_rd,
	input [2:0] ID_EX_funct3,
	input [31:0] ID_EX_PC,
	//
	output reg [4:0] EX_MEM_rd,
	output reg [31:0] EX_MEM_PC,

	// datas from ID regfile
	input [31:0] ID_EX_rdata1,
	input [31:0] ID_EX_rdata2,

	// signals from ID contrl_unit
	input [1:0] ID_EX_ALU_srcB,
	input [3:0] ID_EX_ALUop,

	input ID_EX_MemWrite,
	input ID_EX_MemRead,

	input [1:0] ID_EX_Mem2Reg,
	input ID_EX_RegWrite,

	input ID_EX_Branch,


	/* EX stage to MEM stage REGS  */

	output reg [31:0] EX_MEM_ALU_Result,
	output wire [31:0] alu_result,

	// // datas from ID regfile ~~NO_NEED~~
	// output reg [31:0] EX_MEM_rdata1,
	// // SW WriteData
	output reg [31:0] EX_MEM_rdata2,
	//
	// // signals from contrl_unit ~~NO_NEED~~
	// output reg [1:0] EX_MEM_ALU_srcA,
	// output reg [2:0] EX_MEM_ALU_srcB,
	// output reg [3:0] EX_MEM_ALUop,

	output reg EX_MEM_MemWrite,
	output reg EX_MEM_MemRead,

	output reg [1:0] EX_MEM_Mem2Reg,
	output reg EX_MEM_RegWrite,

	/* forwarding and alu src */
	input [1:0] forward_A,
	input [1:0] forward_B,
	// input [31:0] EX_MEM_ALU_Result,
	input [31:0] WB_wdata,
	input [31:0] WB_wdata_reg,
	input [31:0] ID_EX_U_sign_extend,
	input [31:0] ID_EX_I_sign_extend,
	input [31:0] ID_EX_S_sign_extend,
	input [31:0] ID_EX_B_sign_extend,

	output reg branch_taken,
	output [31:0] EX_B_sign_extend,

	input [31:0] ID_EX_Instr,
	output reg [31:0] EX_MEM_Instr

);



	/* alu wires and module */

	reg [31:0] alu_a;
	reg [31:0] alu_b;

	wire [31:0] the_right_rdata1;
	wire [31:0] the_right_rdata2;

	/* alu data selector */
	alu_src_selector u_alu_src_selector(

		.forward_A(forward_A),
	    .forward_B(forward_B),

	    .ID_EX_rdata1(ID_EX_rdata1),
	    .ID_EX_rdata2(ID_EX_rdata2),
	    .EX_MEM_ALU_Result(EX_MEM_ALU_Result),
	    .WB_wdata(WB_wdata),
	    .WB_wdata_reg(WB_wdata_reg),
	    .ID_EX_U_sign_extend(ID_EX_U_sign_extend),
	    .ID_EX_I_sign_extend(ID_EX_I_sign_extend),
		.ID_EX_S_sign_extend(ID_EX_S_sign_extend),

		.the_right_rdata1(the_right_rdata1),
		.the_right_rdata2(the_right_rdata2)
	    );


    // out put the alu operands

    always @ ( * ) begin
        alu_a = the_right_rdata1;

        case (ID_EX_ALU_srcB)
            2'b00: alu_b = the_right_rdata2;
            2'b01: alu_b = ID_EX_U_sign_extend;
            2'b10: alu_b = ID_EX_I_sign_extend;
            2'b11: alu_b = ID_EX_S_sign_extend;

        endcase
    end



	alu u_alu(
		.A(alu_a), .B(alu_b), .ALUop(ID_EX_ALUop),
		.Overflow(),
		.CarryOut(),
		.Zero(),
		.Result(alu_result)
		);


	/* branch taken and pre_address */
	always @ ( * ) begin
		case (ID_EX_funct3) // BEQ BNE BGE BGEU BLT BLTU
			3'b000: branch_taken = ID_EX_Branch && (alu_result == 32'd0);
			3'b001: branch_taken = ID_EX_Branch && (alu_result == 32'd0);
			3'b101: branch_taken = ID_EX_Branch && alu_result;
			3'b111: branch_taken = ID_EX_Branch && alu_result;
			3'b100: branch_taken = ID_EX_Branch && alu_result;
			3'b110: branch_taken = ID_EX_Branch && alu_result;
			default: branch_taken  =1'b0;
		endcase
	end

	// to instruction fetch stage make a pc src
	assign EX_B_sign_extend = ID_EX_B_sign_extend;

	/* pip pip pip pip */

	always @ (posedge clk) begin
		if(rst)begin
			EX_MEM_PC <= 32'd0;
			EX_MEM_rd <= 5'd0;
			EX_MEM_ALU_Result <= 32'd0;
			EX_MEM_MemWrite <= 1'b0;
			EX_MEM_MemRead <= 1'b0;
			EX_MEM_Mem2Reg <= 2'b00;
			EX_MEM_RegWrite <= 1'b0;
			EX_MEM_rdata2 <= 32'd0;

			EX_MEM_Instr <= 32'd0;
		end
		else begin
			EX_MEM_PC <= ID_EX_PC;
			EX_MEM_rd <= ID_EX_rd;
			EX_MEM_ALU_Result <= alu_result;
			EX_MEM_MemWrite <= ID_EX_MemWrite;
			EX_MEM_MemRead <= ID_EX_MemRead;
			EX_MEM_Mem2Reg <= ID_EX_Mem2Reg;
			EX_MEM_RegWrite <= ID_EX_RegWrite;
			EX_MEM_rdata2 <= the_right_rdata2;

			EX_MEM_Instr <= ID_EX_Instr;
		end

	end





endmodule
