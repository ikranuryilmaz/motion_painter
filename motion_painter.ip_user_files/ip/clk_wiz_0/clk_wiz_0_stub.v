// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sat Apr 27 20:59:24 2024
// Host        : ikra running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/Users/ikran/lab6/lab6.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_25MHz, clk_24MHz, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_in1" */
/* synthesis syn_force_seq_prim="clk_25MHz" */
/* synthesis syn_force_seq_prim="clk_24MHz" */;
  output clk_25MHz /* synthesis syn_isclock = 1 */;
  output clk_24MHz /* synthesis syn_isclock = 1 */;
  input clk_in1;
endmodule
