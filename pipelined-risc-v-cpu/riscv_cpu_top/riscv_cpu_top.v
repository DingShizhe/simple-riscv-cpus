/* =========================================
* Top module for RISCV cores in the FPGA
* evaluation platform
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 1 ps / 1 ps

module riscv_cpu_top (

`ifndef MIPS_CPU_SIM
	//AXI AR Channel
    input  [13:0]	riscv_cpu_axi_if_araddr,
    output			riscv_cpu_axi_if_arready,
    input			riscv_cpu_axi_if_arvalid,

	//AXI AW Channel
    input  [13:0]	riscv_cpu_axi_if_awaddr,
    output			riscv_cpu_axi_if_awready,
    input			riscv_cpu_axi_if_awvalid,

	//AXI B Channel
    input			riscv_cpu_axi_if_bready,
    output [1:0]	riscv_cpu_axi_if_bresp,
    output			riscv_cpu_axi_if_bvalid,

	//AXI R Channel
    output [31:0]	riscv_cpu_axi_if_rdata,
    input			riscv_cpu_axi_if_rready,
    output [1:0]	riscv_cpu_axi_if_rresp,
    output			riscv_cpu_axi_if_rvalid,

	//AXI W Channel
    input  [31:0]	riscv_cpu_axi_if_wdata,
    output			riscv_cpu_axi_if_wready,
    input  [3:0]	riscv_cpu_axi_if_wstrb,
    input			riscv_cpu_axi_if_wvalid,
`endif
	input			riscv_cpu_clk,
    input			riscv_cpu_reset
);

//AXI Lite IF ports to distributed memory
wire [10:0]		axi_lite_mem_addr;
wire [31:0]		axi_lite_mem_wdata;
wire			axi_lite_mem_wren;
wire			axi_lite_mem_rden;
wire [31:0]		axi_lite_mem_rdata;

//RISCV CPU ports to distributed memory
wire [31:0]		riscv_mem_addr;
wire			riscv_mem_wren;
wire			riscv_mem_rden;
wire [31:0]		riscv_mem_wdata;
wire [31:0]		riscv_mem_rdata;

//read arbitration signal
wire			riscv_mem_rd;
wire			axi_lite_mem_rd;

//Distributed memory ports
wire [10:0]		Waddr;
wire [31:0]		Raddr1;
wire [10:0]		Raddr2;
wire			Wren;
wire			Rden2;
wire [31:0]		Wdata;
wire [31:0]		Rdata1;
wire [31:0]		Rdata2;

//Synchronized reset signal generated from AXI Lite IF
wire			riscv_rst;

`ifndef MIPS_CPU_SIM
  //AXI Lite Interface Module
  //Receving memory read/write requests from ARM CPU cores
  axi_lite_if 	u_axi_lite_slave (
	  .S_AXI_ACLK		(riscv_cpu_clk),
	  .S_AXI_ARESETN	(~riscv_cpu_reset),

	  .S_AXI_ARADDR		(riscv_cpu_axi_if_araddr),
	  .S_AXI_ARREADY	(riscv_cpu_axi_if_arready),
	  .S_AXI_ARVALID	(riscv_cpu_axi_if_arvalid),

	  .S_AXI_AWADDR		(riscv_cpu_axi_if_awaddr),
	  .S_AXI_AWREADY	(riscv_cpu_axi_if_awready),
	  .S_AXI_AWVALID	(riscv_cpu_axi_if_awvalid),

	  .S_AXI_BREADY		(riscv_cpu_axi_if_bready),
	  .S_AXI_BRESP		(riscv_cpu_axi_if_bresp),
	  .S_AXI_BVALID		(riscv_cpu_axi_if_bvalid),

	  .S_AXI_RDATA		(riscv_cpu_axi_if_rdata),
	  .S_AXI_RREADY		(riscv_cpu_axi_if_rready),
	  .S_AXI_RRESP		(riscv_cpu_axi_if_rresp),
	  .S_AXI_RVALID		(riscv_cpu_axi_if_rvalid),

	  .S_AXI_WDATA		(riscv_cpu_axi_if_wdata),
	  .S_AXI_WREADY		(riscv_cpu_axi_if_wready),
	  .S_AXI_WSTRB		(riscv_cpu_axi_if_wstrb),
	  .S_AXI_WVALID		(riscv_cpu_axi_if_wvalid),

	  .Address			(axi_lite_mem_addr),
	  .MemRead			(axi_lite_mem_rden),
	  .MemWrite			(axi_lite_mem_wren),
	  .Read_data		(axi_lite_mem_rdata),
	  .Write_data		(axi_lite_mem_wdata),

	  .riscv_rst			(riscv_rst)
  );
`else
  assign axi_lite_mem_addr = 'd0;
  assign axi_lite_mem_rden = 'd0;
  assign axi_lite_mem_wren = 'd0;
  assign axi_lite_mem_wdata = 'd0;
  assign riscv_rst = riscv_cpu_reset;
`endif

//RISCV CPU cores
  riscv_cpu	u_riscv_cpu (
	  .clk			(riscv_cpu_clk),
	  .rst			(riscv_rst),

	  .PC			(Raddr1),
	  .Instruction	(Rdata1),

	  .Address		(riscv_mem_addr),
	  .MemWrite		(riscv_mem_wren),
	  .WriteData	(riscv_mem_wdata),

	  .MemRead		(riscv_mem_rden),
	  .ReadData	(riscv_mem_rdata),

      .cycle_cnt(),
      .inst_cnt(),
      .br_cnt(),
      .ld_cnt(),
      .st_cnt(),
      .br_taken_cnt(),
      .jmp_cnt(),
      .user3_cnt()
  );

/*
 * ==============================================================
 * Memory read arbitration between AXI Lite IF and RISCV CPU
 * ==============================================================
 */

  //AXI Lite IF can read distributed memory only when RISCV CPU has no memory operations
  //if contention occurs, return 0xFFFFFFFF to Read_data port of AXI Lite IF
  assign riscv_mem_rd = riscv_mem_rden & (~riscv_rst);
  assign axi_lite_mem_rd = axi_lite_mem_rden & (riscv_rst | (~riscv_mem_rden));

  assign Rden2 = riscv_mem_rd | axi_lite_mem_rd;

  assign axi_lite_mem_rdata = ({32{axi_lite_mem_rd}} & Rdata2) | ({32{~axi_lite_mem_rd}});

  assign riscv_mem_rdata = {32{riscv_mem_rd}} & Rdata2;

  assign Raddr2 = ({9{riscv_mem_rd}} & riscv_mem_addr[10:2]) | ({9{axi_lite_mem_rd}} & axi_lite_mem_addr);

/*
 * ==============================================================
 * Memory write arbitration between AXI Lite IF and RISCV CPU
 * ==============================================================
 */
  //AXI Lite IF only generates memory write requests before RISCV CPU is running
  assign Wren = riscv_mem_wren | axi_lite_mem_wren;

  assign Wdata = ({32{riscv_mem_wren}} & riscv_mem_wdata) | ({32{axi_lite_mem_wren}} & axi_lite_mem_wdata);
  assign Waddr = ({9{riscv_mem_wren}} & riscv_mem_addr[10:2]) | ({9{axi_lite_mem_wren}} & axi_lite_mem_addr);

  //Distributed memory module used as main memory of RISCV CPU
  ideal_mem 		u_ideal_mem (
	  .clk			(riscv_cpu_clk),

	  .Waddr		(Waddr),
	  .Raddr1		(Raddr1[10:2]),
	  .Raddr2		(Raddr2),

	  .Wren			(Wren),
	  .Rden1		(1'b1),
	  .Rden2		(Rden2),

	  .Wdata		(Wdata),
	  .Rdata1		(Rdata1),
	  .Rdata2		(Rdata2)
  );

endmodule
