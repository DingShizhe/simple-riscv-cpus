module hazrd_unit (
    // input
    input clk,
    input rst,

    input ID_EX_MemRead,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] ID_EX_rd,

    output reg hz_bubble,
    output reg hz_PC_Write,
    output reg hz_IF_ID_Write
    );

    /* detect LW Instruction */
    // if then stall

    always @( * ) begin
        if (rst) begin
            hz_bubble = 1'b0;
            hz_PC_Write = 1'b0;
            hz_IF_ID_Write = 1'b0;
        end
        else begin
            // Branch stall 2 
        //     // Jump stall 1
            // LW stall 1
                if(ID_EX_MemRead ) begin
                    if(rs1==ID_EX_rd || rs2==ID_EX_rd)begin
                        hz_bubble = 1'b1;
                        hz_PC_Write = 1'b0;
                        hz_IF_ID_Write = 1'b0;
                    end
                    else begin
                        hz_bubble = 1'b0;
                        hz_PC_Write = 1'b1;
                        hz_IF_ID_Write = 1'b1;
                    end
                end

                else begin
                    hz_bubble = 1'b0;
                    hz_PC_Write = 1'b1;
                    hz_IF_ID_Write = 1'b1;
                end
        end
    end


endmodule // hazrd_unit
