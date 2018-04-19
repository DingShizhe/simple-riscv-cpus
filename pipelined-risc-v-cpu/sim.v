`timescale 10ns / 1ns

module riscv_cpu_test
();

	// TODO: implement your testbench
	reg		riscv_cpu_clk;
    reg     riscv_cpu_reset;

	initial begin
		riscv_cpu_clk = 1'b0;
		riscv_cpu_reset = 1'b1;
		# 3
		riscv_cpu_reset = 1'b0;

		# 80000
		$finish;
	end

	always begin
		# 2 riscv_cpu_clk = ~riscv_cpu_clk;
	end

    riscv_cpu_top    u_riscv_cpu_top (
        .riscv_cpu_clk       (riscv_cpu_clk),
        .riscv_cpu_reset   (riscv_cpu_reset)
    );

endmodule
