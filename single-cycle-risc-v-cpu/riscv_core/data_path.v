// Give how data selected by the chontrol unit
// pc, waddr, reg_w_data, alu_a, alu_b and so on...

module data_path(

	// select pc
	input [1:0] cu_PC_src,
	input branch_taken,
	input [31:0] PC,
	input [31:0] I_sign_extend,
	input [31:0] J_sign_extend,
	input [31:0] B_sign_extend,
	output reg [31:0] PC_next,

	// select write reg data
	input [1:0] cu_mem_2_reg,
	input [31:0] alu_result,
	input [31:0] mem_r_data,	// from Readdata
	output reg [31:0] reg_w_data,

	// select alu_b
	input [2:0] cu_alu_b_src,
	input [31:0] reg_r_data2,
	input [31:0] S_sign_extend,
	input [31:0] U_sign_extend,
	// input [31:0] shamt_extend,
	output reg [31:0] alu_b

	// select Memory Address
	// input

	);

	// pc source
	always @( * ) begin
		if(branch_taken)
			PC_next = PC + B_sign_extend;

		else begin
			case(cu_PC_src)
				2'b00: PC_next = PC + 32'd4;			// common
					// ////add module needed
				// 2'b01: PC_next = PC + B_sign_extend;	// Branch
					// jump and link
				2'b10: PC_next = PC + J_sign_extend;	// JAL

				2'b11: PC_next = alu_result;	// JALR

				default:
					   PC_next = PC + 32'd4;
			endcase

		end
	end

	// regfile r & w source
	always @( * ) begin
		case(cu_mem_2_reg)
			2'b00: reg_w_data = alu_result;
			2'b01: reg_w_data = mem_r_data;
			2'b10: reg_w_data = PC + 32'd4;
			default: reg_w_data = mem_r_data;
		endcase
	end

	// alu a & b source
	always @( * ) begin

		case (cu_alu_b_src)
			3'b000: alu_b = reg_r_data2;
			3'b010: alu_b = I_sign_extend;
			3'b011: alu_b = S_sign_extend;
			3'b100: alu_b = B_sign_extend;
			3'b101: alu_b = J_sign_extend;
			3'b110: alu_b = U_sign_extend;
			// 3'b111: alu_b = shamt_extend;
			default: alu_b = reg_r_data2;
		endcase
	end


endmodule
