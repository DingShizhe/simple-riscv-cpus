
module alu(
	input [31:0] A,
	input [31:0] B,
	input [3:0] ALUop,

	output reg Overflow,
	output reg CarryOut,
	output reg Zero,
	output reg [31:0] Result
	);
	
	// carry
	reg CarryIn;
	reg [31:0] B_c;
	
	always @( * ) begin
		case(ALUop)
			// AND
			4'b0000:begin
				Result = A & B;
				Overflow = 1'b0;
				CarryOut = 1'b0;
				Zero = 1'b0;
			end

			// OR
			4'b0001:begin
				Result = A | B;
				Overflow = 1'b0;
				CarryOut = 1'b0;
				Zero = 1'b0;
			end


			// need to be optimized
			// ADD
			4'b0010:begin
				if (A[31] == B[31]) begin
					{CarryIn, Result[30:0]} = A[30:0] + B[30:0];
					Result[31] = ((A[31] ^ B[31]) ^ CarryIn);
                    CarryOut = ((A[31] & B[31]) | (CarryIn & B[31]) | (A[31] & CarryIn));
                    Overflow = CarryIn ^ CarryOut;
                    Zero = (Result == 31'd0);
				end
				else begin
					Overflow = 0;
					{CarryOut, Result} = A + B;
					Zero = (Result == 31'd0);
				end
			end

			// SUB
			4'b0110:begin
				B_c = ~B + 1;
				if( A==31'd0 && B[31]==1 && B[30:0]==31'd0)begin
					Overflow = 1'b1;
					CarryOut = 1'b1;
					Zero = 1'b0;
					Result[31] = 1'b1;
					Result[30:0] = 31'd0;
				end
				else if (A[31]==B_c[31]) begin
				    {CarryIn, Result[30:0]} = (A[30:0]+B_c[30:0]);
				    Result[31] = ((A[31] ^ B_c[31]) ^ CarryIn);
				    CarryOut = ~((A[31] & B_c[31])|(CarryIn & B_c[31])|(A[31] & CarryIn));
				    Overflow = CarryIn ^ (~CarryOut);
				    Zero = (Result == 0);
				end else begin
				    Overflow = 0;
				    {CarryOut, Result} = (A+B_c);
				    Zero = (Result == 0);
				end
			end

			// SLT signed
			4'b0111:begin
				if (A[31]==B[31]) begin
				    Result = (A[31:0]<B[31:0]);
				end else begin
				    if(A[31]==0) Result = 0;
				    else Result = 1;
				end
				Overflow = 0;
				CarryOut = 0;
				Zero = 0;
			end

			// SGE signed
			4'b1111:begin
				if (A[31]==B[31]) begin
				    Result = (A[31:0]>=B[31:0]);
				end else begin
				    if(A[31]==0) Result = 31'd1;
				    else Result = 31'd0;
				end
				Overflow = 0;
				CarryOut = 0;
				Zero = 0;
			end


			// SGEU unsigned
			4'b0011: begin
			        Result = (A[31:0]>=B[31:0]);
			        Overflow = 0;
			        CarryOut = 0;
			        Zero = 0;
			    end

			// SLTU unsigned
			4'b1011: begin
					Result = (A[31:0]<B[31:0]);
					Overflow = 0;
					CarryOut = 0;
					Zero = 0;
				end


			// SLL
			4'b0100: begin
			        Result = A << B;
			        Overflow = 0;
			        CarryOut = 0;
			        Zero = 0;
			    end


			default:begin
				Result = 32'd0;
				Overflow = 1'b0;
				CarryOut = 1'b0;
				Zero = 1'b0;
			end

		endcase
	end

endmodule
