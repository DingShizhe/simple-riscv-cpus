module forwarding_unit (
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,

    input [4:0] ID_EX_rd,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    input [4:0] rs1,
    input [4:0] rs2,

    output reg [1:0] forward_data1,
    output reg [1:0] forward_data2
    );

    always @ ( * ) begin

        if (EX_MEM_RegWrite && EX_MEM_rd!=5'd0 && ID_EX_rd==rs1)
            forward_data1 = 2'b11;
        // EX-Hazard
        else if (EX_MEM_RegWrite && EX_MEM_rd!=5'd0 && EX_MEM_rd==rs1)
            forward_data1 = 2'b10;
        // MEM-Hazard
        else if (MEM_WB_RegWrite && MEM_WB_rd!=5'd0 && MEM_WB_rd==rs1)
            forward_data1 = 2'b01;
        else
            forward_data1 = 2'b00;


        if (EX_MEM_RegWrite && EX_MEM_rd!=5'd0 && ID_EX_rd==rs2)
            forward_data2 = 2'b11;
        // EX-Hazard
        if (EX_MEM_RegWrite && EX_MEM_rd!=5'd0 && EX_MEM_rd==rs2)
            forward_data2 = 2'b10;
        // MEM-Hazard
        else if (MEM_WB_RegWrite && MEM_WB_rd!=5'd0 && MEM_WB_rd==rs2)
            forward_data2 = 2'b01;
        else
            forward_data2 = 2'b00;

    end

endmodule // forwarding_unit
