module branch_src_selector (
    input [1:0] forward_data1,
    input [1:0] forward_data2,

    input [1:0] EX_MEM_Mem2Reg,
    input [31:0] rdata1,
    input [31:0] rdata2,
    input [31:0] alu_result,
    input [31:0] EX_MEM_ALU_Result,
    input [31:0] ReadData,
    input [31:0] WB_Data
    );

endmodule // branch_src_selector
