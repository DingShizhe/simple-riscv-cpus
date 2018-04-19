module branch_cmp_unit (

    input [2:0] branch_cmp_op,
    input [31:0] data1,
    input [31:0] data2,

    output reg [31:0] branch_cmp_result
    );

    always @ ( * ) begin
        case (branch_cmp_op)
        // BEQ BNE BGE BGEU BLT BLTU
            3'b000: branch_cmp_result = (data1[31:0] ^ data2[31:0]);

            3'b001: branch_cmp_result = !(data1[31:0] ^ data2[31:0]);

            3'b101: begin   //1111
                if (data1[31]==data2[31]) begin
                    branch_cmp_result = (data1[31:0]>=data2[31:0]);
                end else begin
                    if(data1[31]==0) branch_cmp_result = 31'd1;
                    else branch_cmp_result = 31'd0;
                end
            end

            //0011
            3'b111: branch_cmp_result = (data1[31:0] >= data2[31:0]);

            3'b100: begin   //0111
                if (data1[31]==data2[31]) begin
                    branch_cmp_result = (data1[31:0]<data2[31:0]);
                end else begin
                    if(data1[31]==0) branch_cmp_result = 32'd0;
                    else branch_cmp_result = 32'd1;
                end
            end

            //1011
            3'b110: branch_cmp_result = (data1[31:0] < data2[31:0] );

        endcase
    end

endmodule // branch_cmp_unit
