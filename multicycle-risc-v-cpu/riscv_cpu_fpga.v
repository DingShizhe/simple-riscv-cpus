/* =========================================
* Top module of FPGA evaluation platform for
* MIPS CPU cores
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 1 ps / 1 ps

module riscv_cpu_fpga (
	DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb
);

  inout [14:0]		DDR_addr;
  inout [2:0]		DDR_ba;
  inout				DDR_cas_n;
  inout				DDR_ck_n;
  inout				DDR_ck_p;
  inout				DDR_cke;
  inout				DDR_cs_n;
  inout [3:0]		DDR_dm;
  inout [31:0]		DDR_dq;
  inout [3:0]		DDR_dqs_n;
  inout [3:0]		DDR_dqs_p;
  inout				DDR_odt;
  inout				DDR_ras_n;
  inout				DDR_reset_n;
  inout				DDR_we_n;
  inout				FIXED_IO_ddr_vrn;
  inout				FIXED_IO_ddr_vrp;
  inout [53:0]		FIXED_IO_mio;
  inout				FIXED_IO_ps_clk;
  inout				FIXED_IO_ps_porb;
  inout				FIXED_IO_ps_srstb;

  wire				riscv_cpu_clk;
  reg [1:0]			riscv_cpu_reset_n_i = 2'b00;
  wire				riscv_cpu_reset_n;
  wire				ps_user_reset_n;


  wire [31:0]		riscv_cpu_axi_if_araddr;
  wire				riscv_cpu_axi_if_arready;
  wire				riscv_cpu_axi_if_arvalid;
  wire [31:0]		riscv_cpu_axi_if_awaddr;
  wire				riscv_cpu_axi_if_awready;
  wire				riscv_cpu_axi_if_awvalid;
  wire				riscv_cpu_axi_if_bready;
  wire [1:0]		riscv_cpu_axi_if_bresp;
  wire				riscv_cpu_axi_if_bvalid;
  wire [31:0]		riscv_cpu_axi_if_rdata;
  wire				riscv_cpu_axi_if_rready;
  wire [1:0]		riscv_cpu_axi_if_rresp;
  wire				riscv_cpu_axi_if_rvalid;
  wire [31:0]		riscv_cpu_axi_if_wdata;
  wire				riscv_cpu_axi_if_wready;
  wire [3:0]		riscv_cpu_axi_if_wstrb;
  wire				riscv_cpu_axi_if_wvalid;

  zynq_soc_wrapper		u_zynq_soc_wrapper (
	  .DDR_addr						(DDR_addr[14:0]),
	  .DDR_ba						(DDR_ba[2:0]),
	  .DDR_cas_n					(DDR_cas_n),
	  .DDR_ck_n						(DDR_ck_n),
	  .DDR_ck_p						(DDR_ck_p),
	  .DDR_cke						(DDR_cke),
	  .DDR_cs_n						(DDR_cs_n),
	  .DDR_dm						(DDR_dm[3:0]),
	  .DDR_dq						(DDR_dq[31:0]),
	  .DDR_dqs_p					(DDR_dqs_p[3:0]),
	  .DDR_dqs_n					(DDR_dqs_n[3:0]),
	  .DDR_reset_n					(DDR_reset_n),
	  .DDR_odt						(DDR_odt),
	  .DDR_ras_n					(DDR_ras_n),
	  .DDR_we_n						(DDR_we_n),

	  .FIXED_IO_ddr_vrn				(FIXED_IO_ddr_vrn),
	  .FIXED_IO_ddr_vrp				(FIXED_IO_ddr_vrp),

	  .FIXED_IO_mio					(FIXED_IO_mio[53:0]),
	  
	  .FIXED_IO_ps_clk				(FIXED_IO_ps_clk ),
	  .FIXED_IO_ps_porb				(FIXED_IO_ps_porb),
	  .FIXED_IO_ps_srstb			(FIXED_IO_ps_srstb),

	  .riscv_cpu_axi_if_araddr		(riscv_cpu_axi_if_araddr),
	  .riscv_cpu_axi_if_arprot		(),
	  .riscv_cpu_axi_if_arready		(riscv_cpu_axi_if_arready),
	  .riscv_cpu_axi_if_arvalid		(riscv_cpu_axi_if_arvalid),
	  .riscv_cpu_axi_if_awaddr		(riscv_cpu_axi_if_awaddr),
	  .riscv_cpu_axi_if_awprot		(),
	  .riscv_cpu_axi_if_awready		(riscv_cpu_axi_if_awready),
	  .riscv_cpu_axi_if_awvalid		(riscv_cpu_axi_if_awvalid),
	  .riscv_cpu_axi_if_bready		(riscv_cpu_axi_if_bready),
	  .riscv_cpu_axi_if_bresp		(riscv_cpu_axi_if_bresp),
	  .riscv_cpu_axi_if_bvalid		(riscv_cpu_axi_if_bvalid),
	  .riscv_cpu_axi_if_rdata		(riscv_cpu_axi_if_rdata),
	  .riscv_cpu_axi_if_rready		(riscv_cpu_axi_if_rready),
	  .riscv_cpu_axi_if_rresp		(riscv_cpu_axi_if_rresp),
	  .riscv_cpu_axi_if_rvalid		(riscv_cpu_axi_if_rvalid),
	  .riscv_cpu_axi_if_wdata		(riscv_cpu_axi_if_wdata),
	  .riscv_cpu_axi_if_wready		(riscv_cpu_axi_if_wready),
	  .riscv_cpu_axi_if_wstrb		(riscv_cpu_axi_if_wstrb),
	  .riscv_cpu_axi_if_wvalid		(riscv_cpu_axi_if_wvalid),
	  
	  .ps_fclk_clk0					(riscv_cpu_clk),
	  .ps_user_reset_n				(ps_user_reset_n),
	  .riscv_cpu_reset_n				(riscv_cpu_reset_n)
  );

  //generate positive reset signal for MIPS CPU core
  always @ (posedge riscv_cpu_clk)
	  riscv_cpu_reset_n_i <= {riscv_cpu_reset_n_i[0], ps_user_reset_n};

  assign riscv_cpu_reset_n = riscv_cpu_reset_n_i[1];
 
  //Instantiation of MIPS CPU core
  riscv_cpu_top		u_riscv_cpu_top (
	  .riscv_cpu_clk					(riscv_cpu_clk),
	  .riscv_cpu_reset				(~riscv_cpu_reset_n),
	  
	  .riscv_cpu_axi_if_araddr		(riscv_cpu_axi_if_araddr[13:0]),
	  .riscv_cpu_axi_if_arready		(riscv_cpu_axi_if_arready),
	  .riscv_cpu_axi_if_arvalid		(riscv_cpu_axi_if_arvalid),
	  .riscv_cpu_axi_if_awaddr		(riscv_cpu_axi_if_awaddr[13:0]),
	  .riscv_cpu_axi_if_awready		(riscv_cpu_axi_if_awready),
	  .riscv_cpu_axi_if_awvalid		(riscv_cpu_axi_if_awvalid),
	  .riscv_cpu_axi_if_bready		(riscv_cpu_axi_if_bready),
	  .riscv_cpu_axi_if_bresp		(riscv_cpu_axi_if_bresp),
	  .riscv_cpu_axi_if_bvalid		(riscv_cpu_axi_if_bvalid),
	  .riscv_cpu_axi_if_rdata		(riscv_cpu_axi_if_rdata),
	  .riscv_cpu_axi_if_rready		(riscv_cpu_axi_if_rready),
	  .riscv_cpu_axi_if_rresp		(riscv_cpu_axi_if_rresp),
	  .riscv_cpu_axi_if_rvalid		(riscv_cpu_axi_if_rvalid),
	  .riscv_cpu_axi_if_wdata		(riscv_cpu_axi_if_wdata),
	  .riscv_cpu_axi_if_wready		(riscv_cpu_axi_if_wready),
	  .riscv_cpu_axi_if_wstrb		(riscv_cpu_axi_if_wstrb),
	  .riscv_cpu_axi_if_wvalid		(riscv_cpu_axi_if_wvalid)
  );

endmodule

