module alu_src_selector (
    // input [1:0] ID_EX_ALU_srcA,

    input [1:0] forward_A,
    input [1:0] forward_B,

    input [31:0] ID_EX_rdata1,
    input [31:0] ID_EX_rdata2,
    input [31:0] EX_MEM_ALU_Result,
    input [31:0] WB_wdata,
    input [31:0] WB_wdata_reg,
    input [31:0] ID_EX_U_sign_extend,
    input [31:0] ID_EX_I_sign_extend,
    input [31:0] ID_EX_S_sign_extend,

    // output reg [31:0] alu_a,
    // output reg [31:0] alu_b,

    output reg [31:0] the_right_rdata1,
    output reg [31:0] the_right_rdata2

    );


    // get the real read datas


    always @ ( * ) begin
        case(forward_A)
            2'b00: the_right_rdata1 = ID_EX_rdata1;
            2'b01: the_right_rdata1 = WB_wdata;
            2'b10: the_right_rdata1 = EX_MEM_ALU_Result;
            2'b11: the_right_rdata1 = WB_wdata_reg;
        endcase

        case(forward_B)
            2'b00: the_right_rdata2 = ID_EX_rdata2;
            2'b01: the_right_rdata2 = WB_wdata;
            2'b10: the_right_rdata2 = EX_MEM_ALU_Result;
            2'b11: the_right_rdata2 = WB_wdata_reg;
        endcase
    end

endmodule // alu_src_selector
