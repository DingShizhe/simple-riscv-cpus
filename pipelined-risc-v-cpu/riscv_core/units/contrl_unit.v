module contrl_unit (


    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,

    // make a bubble in execution stage
    input hz_bubble,

    // signals may effective in INSTRUCTION FETCH stage
    output reg [1:0] cu_PCsrc,

    // signals may effective in INSTRUCTION DECODE stage
    output reg cu_Branch,
    output reg cu_jump,

    // signals may effective in EXECUTION stage
    output reg [1:0] cu_ALU_srcB,
    output reg [3:0] cu_alu_op,

    // signals may effective in MEMORY stage
    output reg cu_MemWrite,
    output reg cu_MemRead,

    // signals may effective in WRITE BACK stage
    output reg [1:0] cu_Mem2Reg,
    output reg cu_Regwrite,
    output reg cu_IF_flush,
    output reg cu_jalr

    );

    // to get ALUop
    reg [1:0] cu_ALU_Op;

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

    always @ ( * ) begin

        if (hz_bubble) begin
            cu_PCsrc = 2'b00;
            cu_Branch = 1'b0;
            cu_jump = 1'b0;

            cu_ALU_Op = 2'b00;
            cu_ALU_srcB = 3'b000;

            cu_MemRead = 1'b0;
            cu_MemWrite = 1'b0;

            cu_Mem2Reg = 2'b00;
            cu_Regwrite = 1'b0;

            cu_IF_flush = 1'b0;
            cu_jalr = 1'b0;
        end

        else begin
            case (opcode)

                Rtype_op: begin
                    cu_PCsrc = 2'b00;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b0;

                    cu_ALU_Op = 2'b01;
                    cu_ALU_srcB = 2'b00;

                    cu_MemRead = 1'b0;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b00;
                    cu_Regwrite = 1'b1;
                    cu_IF_flush = 1'b0;
                    cu_jalr = 1'b0;
                end

                Itype_op: begin
                    cu_PCsrc = 2'b00;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b0;

                    cu_ALU_Op = 2'b10;         // cu_ALU_Op
                    cu_ALU_srcB = 2'b10;    // imd

                    cu_MemRead = 1'b0;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b00;
                    cu_Regwrite = 1'b1;
                    cu_IF_flush = 1'b0;
                    cu_jalr = 1'b0;
                end

                Btype_op: begin
                    cu_PCsrc = 2'b01;       // pc_src
                    cu_Branch = 1'b1;
                    cu_jump = 1'b0;

                    cu_ALU_Op = 2'b11;         // cu_ALU_Op
                    cu_ALU_srcB = 2'b00;

                    cu_MemRead = 1'b0;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b00;
                    cu_Regwrite = 1'b0;
                    cu_IF_flush = 1'b0;
                    cu_jalr = 1'b0;
                end

                SW_op: begin
                    cu_PCsrc = 2'b00;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b0;

                    cu_ALU_Op = 2'b00;
                    cu_ALU_srcB = 2'b11;    // imd

                    cu_MemRead = 1'b0;      // mem_read
                    cu_MemWrite = 1'b1;     // mem_wriet

                    cu_Mem2Reg = 2'b00;
                    cu_Regwrite = 1'b0;
                    cu_IF_flush = 1'b0;
                    cu_jalr = 1'b0;
                end

                LW_op: begin
                    cu_PCsrc = 2'b00;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b0;

                    cu_ALU_Op = 2'b00;
                    cu_ALU_srcB = 2'b10;    // imd

                    cu_MemRead = 1'b1;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b01;
                    cu_Regwrite = 1'b1;
                    cu_IF_flush = 1'b0;
                    cu_jalr = 1'b0;
                end

                LUI_op: begin
                    cu_PCsrc = 2'b00;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b0;

                    cu_ALU_Op = 2'b00;        // cu_ALU_Op
                    cu_ALU_srcB = 2'b01;    // imd

                    cu_MemRead = 1'b0;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b00;
                    cu_Regwrite = 1'b1;
                    cu_IF_flush = 1'b0;
                    cu_jalr = 1'b0;
                end


                JAL_op: begin
                    cu_PCsrc = 2'b10;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b1;

                    cu_ALU_Op = 2'b00;        // cu_ALU_Op
                    cu_ALU_srcB = 2'b00;

                    cu_MemRead = 1'b0;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b10;
                    cu_Regwrite = 1'b1;
                    cu_IF_flush = 1'b1;        // cu_IF_flush
                    cu_jalr = 1'b0;
                end

                JALR_op: begin
                    cu_PCsrc = 2'b11;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b1;

                    cu_ALU_Op = 2'b00;        // cu_ALU_Op
                    cu_ALU_srcB = 2'b10;    // imd

                    cu_MemRead = 1'b0;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b10;
                    cu_Regwrite = 1'b1;
                    cu_IF_flush = 1'b1;        // cu_IF_flush
                    cu_jalr = 1'b1;             // cu_jalr   stall 2
                end

                default: begin
                    cu_PCsrc = 2'b00;
                    cu_Branch = 1'b0;
                    cu_jump = 1'b0;

                    cu_ALU_Op = 2'b01;
                    cu_ALU_srcB = 2'b00;

                    cu_MemRead = 1'b0;
                    cu_MemWrite = 1'b0;

                    cu_Mem2Reg = 2'b00;
                    cu_Regwrite = 1'b0;

                    cu_IF_flush = 1'b0;
                    cu_jalr = 1'b0;
                end
            endcase
        end




        case(cu_ALU_Op)
            2'b00: cu_alu_op = 4'b0010;

            // R-type
            2'b01: case({funct3, funct7})
                //ADD
                {3'b000, 7'b0000000}: cu_alu_op = 4'b0010;
                //SUB
                {3'b000, 7'b0100000}: cu_alu_op = 4'b0110;
                //SLL
                {3'b001, 7'b0000000}: cu_alu_op = 4'b0100;
                //SLT
                {3'b010, 7'b0000000}: cu_alu_op = 4'b0111;
                //AND
                {3'b111, 7'b0000000}: cu_alu_op = 4'b0000;
                //default
                default: 			  cu_alu_op = 4'b0000;
            endcase

            // I-type
            2'b10: case(funct3)
                // ADDI
                3'b000: cu_alu_op = 4'b0010;
                // SLTI
                3'b010: cu_alu_op = 4'b0111;
                // SLLI
                3'b001: cu_alu_op = 4'b0100;
                // default
                default: cu_alu_op = 4'b0000;
            endcase

            // B-type
            2'b11: case(funct3)
                // BEQ
                3'b000: cu_alu_op = 4'b0110;
                // BNE
                3'b001: cu_alu_op = 4'b0110;
                // BLT BGT
                3'b100: cu_alu_op = 4'b0111;
                // BGE BLE
                3'b101: cu_alu_op = 4'b1111;
                // BGEU BLEU
                3'b111: cu_alu_op = 4'b0011;
                // BLTU
                3'b110: cu_alu_op = 4'b1011;
                // default
                default: cu_alu_op = 4'b0110;

            endcase

            default: cu_alu_op = 4'b0000;
        endcase

    end

endmodule // contrl_unit
