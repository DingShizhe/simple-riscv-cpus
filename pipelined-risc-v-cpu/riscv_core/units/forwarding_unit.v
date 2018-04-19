module forwarding_unit (
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input WB_RegWrite_reg,

    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    input [4:0] WB_rd_reg,
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,

    output reg [1:0] forward_A,
    output reg [1:0] forward_B
    );

    always @ ( * ) begin

        // EX-Hazard

        if (EX_MEM_RegWrite && (EX_MEM_rd!=5'd0) && (EX_MEM_rd==ID_EX_rs1))
            forward_A = 2'b10;
        // MEM-Hazard
        else if (MEM_WB_RegWrite && (MEM_WB_rd!=5'd0) && (MEM_WB_rd==ID_EX_rs1))
            forward_A = 2'b01;
        else if (WB_RegWrite_reg && (WB_rd_reg!=5'd0) && (WB_rd_reg==ID_EX_rs1))
            forward_A = 2'b11;
        else
            forward_A = 2'b00;



        // EX-Hazard
        if (EX_MEM_RegWrite && (EX_MEM_rd!=5'd0) && (EX_MEM_rd==ID_EX_rs2))
            forward_B = 2'b10;
        // MEM-Hazard
        else if (MEM_WB_RegWrite && (MEM_WB_rd!=5'd0) && (MEM_WB_rd==ID_EX_rs2))
            forward_B = 2'b01;
        else if (WB_RegWrite_reg && (WB_rd_reg!=5'd0) && (WB_rd_reg==ID_EX_rs2))
            forward_B = 2'b11;
        else
            forward_B = 2'b00;

    end

endmodule // forwarding_unit
