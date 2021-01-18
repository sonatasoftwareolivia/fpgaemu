//-----------------------------------------------------------------------------
//
// (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : AXI Memory Mapped Bridge to PCI Express
// File       : board.v
// Version    : 2.8
///-----------------------------------------------------------------------------
//
// (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : AXI Memory Mapped Bridge to PCI Express
// File       : board.v
// Version    : 2.7
// Description : Top-level testbench file
//
// Hierarchy   : board
//               |
//               |--xilinx_pcie_2_1_rport_7x
//               |  |
//               |  |--cgator_wrapper
//               |  |  |
//               |  |  |--pcie_2_1_rport_7x (in source directory)
//               |  |  |  |
//               |  |  |  |--<various>
//               |  |  |
//               |  |  |--cgator
//               |  |     |
//               |  |     |--cgator_cpl_decoder
//               |  |     |--cgator_pkt_generator
//               |  |     |--cgator_tx_mux
//               |  |     |--cgator_controller
//               |  |        |--<cgator_cfg_rom.data> (specified by ROM_FILE)
//               |  |
//               |  |--pio_master
//               |     |
//               |     |--pio_master_controller
//               |     |--pio_master_checker
//               |     |--pio_master_pkt_generator
//               |
//               |--xilinx_axi_pcie_ep
//                  |
//                  |--axi_bram_cntrl
//					|--axi_pcie_0 if PCIE_EXT_CLK & PCIE_EXT_GT_COMMON are FALSE
//						|
//						|--axi_pcie (axi pcie design)
//							|
//							|--<various>
//					|--axi_pcie_0_support If either of or both PCIE_EXT_CLK & PCIE_EXT_GT_COMMON are TRUE
//						|
//						|--ext_pipe_clk(external pipe clock)
//						|--ext_gt_common(external gt common)
//						|--axi_pcie_0
//							|
//							|--axi_pcie (axi pcie design)
//								|
//								|--<various>
//
//-----------------------------------------------------------------------------

`timescale 1ns/1ps //fix this

`include "board_common.vh"

`define SIMULATION

module board;

  parameter  REF_CLK_FREQ          = 0;
  localparam REF_CLK_HALF_CYCLE    = (REF_CLK_FREQ == 0) ? 5000 :
                                     (REF_CLK_FREQ == 1) ? 4000 :
                                     (REF_CLK_FREQ == 2) ? 2000 : 0;

  // EP Parameters
  parameter USER_CLK_FREQ_EP           = 2; 
  parameter USER_CLK2_DIV2_EP          = "FALSE";
  parameter LINK_CAP_MAX_LINK_WIDTH_EP = 6'h4;

  // RP Parameters
  parameter USER_CLK_FREQ_RP           = 4;
  parameter USER_CLK2_DIV2_RP          = "TRUE";
  parameter LINK_CAP_MAX_LINK_WIDTH_RP = 6'h8;

  integer            i;
  // System-level clock and reset
  wire               ep_sys_clk_p;
  wire               ep_sys_clk_n;
  wire               rp_sys_clk;
  reg                sys_rst_n;

localparam EXT_PIPE_SIM              = "FALSE";


//
// PCI-Express Serial Interconnect
//
  wire  [3:0]  ep_pci_exp_txn;
  wire  [3:0]  ep_pci_exp_txp;
  wire  [3:0]  rp_pci_exp_txn;
  wire  [3:0]  rp_pci_exp_txp;
  
 
 
  //INSERT PARAMETERS FOR MIG//
  
  // Traffic Gen related parameters
   parameter SIMULATION            = "TRUE";
   parameter BEGIN_ADDRESS         = 32'h00000000;
   parameter END_ADDRESS           = 32'h00000fff;
   parameter PRBS_EADDR_MASK_POS   = 32'hff000000;

   // The following parameters refer to width of various ports
   parameter COL_WIDTH             = 10;
                                     // # of memory Column Address bits.
   parameter CS_WIDTH              = 1;
                                     // # of unique CS outputs to memory.
   parameter DM_WIDTH              = 1;
                                     // # of DM (data mask)
   parameter DQ_WIDTH              = 8;
                                     // # of DQ (data)
   parameter DQS_WIDTH             = 1;
   parameter DQS_CNT_WIDTH         = 1;
                                     // = ceil(log2(DQS_WIDTH))
   parameter DRAM_WIDTH            = 8;
                                     // # of DQ per DQS
   parameter ECC                   = "OFF";
   parameter RANKS                 = 1;
                                     // # of Ranks.
   parameter ODT_WIDTH             = 1;
                                     // # of ODT outputs to memory.
   parameter ROW_WIDTH             = 14;
                                     // # of memory Row Address bits.
   parameter ADDR_WIDTH            = 28;
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices

   // The following parameters are mode register settings
   parameter BURST_MODE            = "8";
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
   parameter CA_MIRROR             = "OFF";
                                     // C/A mirror opt for DDR3 dual rank
   
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter CLKIN_PERIOD          = 5; //convert to ns 5000 -> 5
                                     // Input Clock Period
                                     
   // Simulation parameters
   parameter SIM_BYPASS_INIT_CAL   = "FAST";
                                     // # = "SIM_INIT_CAL_FULL" -  Complete
                                     //              memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   // IODELAY and PHY related parameters
   parameter TCQ_MIG                   = 0.1; //convert to ns 100 -> 0.1

   // IODELAY and PHY related parameters
   parameter RST_ACT_LOW           = 0;
                                     // =1 for active low reset,
                                     // =0 for active high.

   // Referece clock frequency parameters
   parameter REFCLK_FREQ           = 200.0;
                                     // IODELAYCTRL reference clock frequency

   // System clock frequency parameters
   parameter tCK                   = 2500;
                                     // memory tCK paramter.
                                    // # = Clock Period in pS.
   parameter nCK_PER_CLK           = 4;
                                     // # of memory CKs per fabric CLK

   // AXI4 Shim parameters
   parameter C_S_AXI_ID_WIDTH              = 4;
                                             // Width of all master and slave ID signals.
                                             // # = >= 1.
   parameter C_S_AXI_ADDR_WIDTH            = 27;
                                             // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                             // M_AXI_ARADDR for all SI/MI slots.
                                             // # = 32.
   parameter C_S_AXI_DATA_WIDTH            = 32;
                                             // Width of WDATA and RDATA on SI slot.
                                             // Must be <= APP_DATA_WIDTH.
                                             // # = 32, 64, 128, 256.
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0;
                                             // Indicates whether to instatiate upsizer
                                             // Range: 0, 1

   // Debug and Internal parameters
   parameter DEBUG_PORT            = "OFF";
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
   // Debug and Internal parameters
   parameter DRAM_TYPE             = "DDR3";

  // Local parameters Declarations
  localparam real TPROP_DQS          = 0.00;
                                       // Delay for DQS signal during Write Operation
  localparam real TPROP_DQS_RD       = 0.00;
                       // Delay for DQS signal during Read Operation
  localparam real TPROP_PCB_CTRL     = 0.00;
                       // Delay for Address and Ctrl signals
  localparam real TPROP_PCB_DATA     = 0.00;
                       // Delay for data signal during Write operation
  localparam real TPROP_PCB_DATA_RD  = 0.00;
                       // Delay for data signal during Read operation

  localparam MEMORY_WIDTH            = 8;
  localparam NUM_COMP                = DQ_WIDTH/MEMORY_WIDTH;
  localparam ECC_TEST 		   	= "OFF" ;
  localparam ERR_INSERT = (ECC_TEST == "ON") ? "OFF" : ECC ;
  
  localparam real REFCLK_PERIOD = (1000.0/(2*REFCLK_FREQ)); //convert to ns
  localparam RESET_PERIOD = 200; //convert to ns
  localparam real SYSCLK_PERIOD = tCK;

 //**************************************************************************//
  // MIG Wire Declarations
  //**************************************************************************//
  reg                                sys_rst_n_mig; //was originaly sys_rst_n, but that variable already exists for PCIE
  wire                               sys_rst;
  reg                                sys_clk_i;
  reg                                clk_ref_i;
  wire                               ddr3_reset_n;
  wire [DQ_WIDTH-1:0]                ddr3_dq_fpga;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_p_fpga;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_n_fpga;
  wire [ROW_WIDTH-1:0]               ddr3_addr_fpga;
  wire [3-1:0]                       ddr3_ba_fpga;
  wire                               ddr3_ras_n_fpga;
  wire                               ddr3_cas_n_fpga;
  wire                               ddr3_we_n_fpga;
  wire [1-1:0]                       ddr3_cke_fpga;
  wire [1-1:0]                       ddr3_ck_p_fpga;
  wire [1-1:0]                       ddr3_ck_n_fpga;
  wire                               init_calib_complete;
  wire                               tg_compare_error;
  wire [(CS_WIDTH*1)-1:0]            ddr3_cs_n_fpga;
  wire [DM_WIDTH-1:0]                ddr3_dm_fpga;
  wire [ODT_WIDTH-1:0]               ddr3_odt_fpga;
  reg [(CS_WIDTH*1)-1:0]             ddr3_cs_n_sdram_tmp;
  reg [DM_WIDTH-1:0]                 ddr3_dm_sdram_tmp;
  reg [ODT_WIDTH-1:0]                ddr3_odt_sdram_tmp;
  wire [DQ_WIDTH-1:0]                ddr3_dq_sdram;
  reg [ROW_WIDTH-1:0]                ddr3_addr_sdram [0:1];
  reg [3-1:0]                        ddr3_ba_sdram [0:1];
  reg                                ddr3_ras_n_sdram;
  reg                                ddr3_cas_n_sdram;
  reg                                ddr3_we_n_sdram;
  wire [(CS_WIDTH*1)-1:0]            ddr3_cs_n_sdram;
  wire [ODT_WIDTH-1:0]               ddr3_odt_sdram;
  reg [1-1:0]                        ddr3_cke_sdram;
  wire [DM_WIDTH-1:0]                ddr3_dm_sdram;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_p_sdram;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_n_sdram;
  reg [1-1:0]                        ddr3_ck_p_sdram;
  reg [1-1:0]                        ddr3_ck_n_sdram;
  
  //**************************************************************************//
  // Reset Generation
  //**************************************************************************//
  initial begin
    sys_rst_n_mig = 1'b0; //change all syst_
    #RESET_PERIOD
      sys_rst_n_mig = 1'b1;
   end

   assign sys_rst = RST_ACT_LOW ? sys_rst_n_mig : ~sys_rst_n_mig;

  //**************************************************************************//
  // Clock Generation
  //**************************************************************************//
  initial
    sys_clk_i = 1'b0;
  always
    sys_clk_i = #2.5 ~sys_clk_i; //200 MHz

  initial
    clk_ref_i = 1'b0;
  always
    clk_ref_i = #2.5 ~clk_ref_i; //200 MHz
    
   //**************************************************************************//
  // Using DDR3 Memory Model
  //**************************************************************************//
 
 always @( * ) begin
    ddr3_ck_p_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_p_fpga;
    ddr3_ck_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_n_fpga;
    ddr3_addr_sdram[0]   <=  #(TPROP_PCB_CTRL) ddr3_addr_fpga;
    ddr3_addr_sdram[1]   <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
                                                 {ddr3_addr_fpga[ROW_WIDTH-1:9],
                                                  ddr3_addr_fpga[7], ddr3_addr_fpga[8],
                                                  ddr3_addr_fpga[5], ddr3_addr_fpga[6],
                                                  ddr3_addr_fpga[3], ddr3_addr_fpga[4],
                                                  ddr3_addr_fpga[2:0]} :
                                                 ddr3_addr_fpga;
    ddr3_ba_sdram[0]     <=  #(TPROP_PCB_CTRL) ddr3_ba_fpga;
    ddr3_ba_sdram[1]     <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
                                                 {ddr3_ba_fpga[3-1:2],
                                                  ddr3_ba_fpga[0],
                                                  ddr3_ba_fpga[1]} :
                                                 ddr3_ba_fpga;
    ddr3_ras_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_ras_n_fpga;
    ddr3_cas_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_cas_n_fpga;
    ddr3_we_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_we_n_fpga;
    ddr3_cke_sdram       <=  #(TPROP_PCB_CTRL) ddr3_cke_fpga;
  end
  
  always @( * )
    ddr3_cs_n_sdram_tmp   <=  #(TPROP_PCB_CTRL) ddr3_cs_n_fpga;
  assign ddr3_cs_n_sdram =  ddr3_cs_n_sdram_tmp;
    

  always @( * )
    ddr3_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation
  assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;
    

  always @( * )
    ddr3_odt_sdram_tmp  <=  #(TPROP_PCB_CTRL) ddr3_odt_fpga;
  assign ddr3_odt_sdram =  ddr3_odt_sdram_tmp;

// Controlling the bi-directional BUS
  genvar dqwd;
  generate
    for (dqwd = 1;dqwd < DQ_WIDTH;dqwd = dqwd+1) begin : dq_delay
      WireDelay #
       (
        .Delay_g    (TPROP_PCB_DATA),
        .Delay_rd   (TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dq
       (
        .A             (ddr3_dq_fpga[dqwd]),
        .B             (ddr3_dq_sdram[dqwd]),
        .reset         (sys_rst_n_mig),
        .phy_init_done (init_calib_complete)
       );
    end
          WireDelay #
       (
        .Delay_g    (TPROP_PCB_DATA),
        .Delay_rd   (TPROP_PCB_DATA_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dq_0
       (
        .A             (ddr3_dq_fpga[0]),
        .B             (ddr3_dq_sdram[0]),
        .reset         (sys_rst_n_mig),
        .phy_init_done (init_calib_complete)
       );
  endgenerate
  
  genvar dqswd;
  generate
    for (dqswd = 0;dqswd < DQS_WIDTH;dqswd = dqswd+1) begin : dqs_delay
      WireDelay #
       (
        .Delay_g    (TPROP_DQS),
        .Delay_rd   (TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dqs_p
       (
        .A             (ddr3_dqs_p_fpga[dqswd]),
        .B             (ddr3_dqs_p_sdram[dqswd]),
        .reset         (sys_rst_n_mig),
        .phy_init_done (init_calib_complete)
       );

      WireDelay #
       (
        .Delay_g    (TPROP_DQS),
        .Delay_rd   (TPROP_DQS_RD),
        .ERR_INSERT ("OFF")
       )
      u_delay_dqs_n
       (
        .A             (ddr3_dqs_n_fpga[dqswd]),
        .B             (ddr3_dqs_n_sdram[dqswd]),
        .reset         (sys_rst_n_mig),
        .phy_init_done (init_calib_complete)
       );
    end
  endgenerate

//-------------------------------------------------------
// For PIPE simulation run only
// pipe_clock module resides in axi_pcie_2_phy_gen_rp_ep_i
//assign XILINX_AXIPCIE_EP.mmcm_lock = axi_pcie_2_phy_gen_rp_ep_i.mmcm_lock_ep;

  //------------------------------------------------------------------------------//
  // Generate system clock
  //------------------------------------------------------------------------------// 

  sys_clk_gen
  #(
    .halfcycle (REF_CLK_HALF_CYCLE),
    .offset    (0)
  ) CLK_GEN (
    .sys_clk (rp_sys_clk)
  );

sys_clk_gen_ds # (

  .halfcycle(REF_CLK_HALF_CYCLE),
  .offset(0)

)
CLK_GEN_EP (

  .sys_clk_p(ep_sys_clk_p),
  .sys_clk_n(ep_sys_clk_n)

);

  //------------------------------------------------------------------------------//
  // Generate system-level reset
  //------------------------------------------------------------------------------//
  
  initial begin
  $display("[%t] : System Reset Asserted...", $realtime);

  sys_rst_n = 1'b0;

  for (i = 0; i < 500; i = i + 1) begin

    @(posedge ep_sys_clk_p);

  end

  $display("[%t] : System Reset De-asserted...", $realtime);

  sys_rst_n = 1'b1;
  end


  //
  // INSTANTIATE PCIE ENDPOINT WITH MIG CONNECTED
  //
  xilinx_axi_pcie_ep #(
     .SIMULATION                (SIMULATION),
     .BEGIN_ADDRESS             (BEGIN_ADDRESS),
     .END_ADDRESS               (END_ADDRESS),
     .PRBS_EADDR_MASK_POS       (PRBS_EADDR_MASK_POS),

     .COL_WIDTH                 (COL_WIDTH),
     .CS_WIDTH                  (CS_WIDTH),
     .DM_WIDTH                  (DM_WIDTH),
    
     .DQ_WIDTH                  (DQ_WIDTH),
     .DQS_CNT_WIDTH             (DQS_CNT_WIDTH),
     .DRAM_WIDTH                (DRAM_WIDTH),
     .ECC_TEST                  (ECC_TEST),
     .RANKS                     (RANKS),
     .ROW_WIDTH                 (ROW_WIDTH),
     .ADDR_WIDTH                (ADDR_WIDTH),
     .BURST_MODE                (BURST_MODE),
     .TCQ_MIG                   (TCQ_MIG), //change this

     
    .DRAM_TYPE                 (DRAM_TYPE),
    
     
    .nCK_PER_CLK               (nCK_PER_CLK),
    
     
     .C_S_AXI_ID_WIDTH          (C_S_AXI_ID_WIDTH),
     .C_S_AXI_ADDR_WIDTH        (C_S_AXI_ADDR_WIDTH),
     .C_S_AXI_DATA_WIDTH        (C_S_AXI_DATA_WIDTH),
     .C_S_AXI_SUPPORTS_NARROW_BURST (C_S_AXI_SUPPORTS_NARROW_BURST),
    
     .DEBUG_PORT                (DEBUG_PORT),
    
     .RST_ACT_LOW               (RST_ACT_LOW)
     )
     XILINX_AXIPCIE_EP (
  // SYS Inteface
  .sys_clk_n                    ( ep_sys_clk_n           ),
  .sys_clk_p                    ( ep_sys_clk_p           ),
  .sys_rst_n                    ( sys_rst_n              ),
  
  // PCI-Express Interface
  .pci_exp_txn(ep_pci_exp_txn),
  .pci_exp_txp(ep_pci_exp_txp),
  .pci_exp_rxn(rp_pci_exp_txn),
  .pci_exp_rxp(rp_pci_exp_txp),
  
  //INSERT REST OF PORTS FOR MIG
  .ddr3_dq              (ddr3_dq_fpga),
  .ddr3_dqs_n           (ddr3_dqs_n_fpga),
  .ddr3_dqs_p           (ddr3_dqs_p_fpga),
  .ddr3_addr            (ddr3_addr_fpga),
  .ddr3_ba              (ddr3_ba_fpga),
  .ddr3_ras_n           (ddr3_ras_n_fpga),
  .ddr3_cas_n           (ddr3_cas_n_fpga),
  .ddr3_we_n            (ddr3_we_n_fpga),
  .ddr3_reset_n         (ddr3_reset_n),
  .ddr3_ck_p            (ddr3_ck_p_fpga),
  .ddr3_ck_n            (ddr3_ck_n_fpga),
  .ddr3_cke             (ddr3_cke_fpga),
  .ddr3_cs_n            (ddr3_cs_n_fpga),    
  .ddr3_dm              (ddr3_dm_fpga),
  .ddr3_odt             (ddr3_odt_fpga),
  .sys_clk_i            (sys_clk_i),
  .init_calib_complete (init_calib_complete),
  .tg_compare_error    (tg_compare_error),
  .sys_rst             (sys_rst)
);

//**************************************************************************//
// Memory Models instantiations
//**************************************************************************//
  genvar r,s;
  generate
    for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
      for (s = 0; s < NUM_COMP; s = s + 1) begin: gen_mem //convert all 'i' variables to 's'
        ddr3_model u_comp_ddr3
          (
           .rst_n   (ddr3_reset_n),
           .ck      (ddr3_ck_p_sdram),
           .ck_n    (ddr3_ck_n_sdram),
           .cke     (ddr3_cke_sdram[r]),
           .cs_n    (ddr3_cs_n_sdram[r]),
           .ras_n   (ddr3_ras_n_sdram),
           .cas_n   (ddr3_cas_n_sdram),
           .we_n    (ddr3_we_n_sdram),
           .dm_tdqs (ddr3_dm_sdram[s]),
           .ba      (ddr3_ba_sdram[r]),
           .addr    (ddr3_addr_sdram[r]),
           .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(s+1)-1:MEMORY_WIDTH*(s)]),
           .dqs     (ddr3_dqs_p_sdram[s]),
           .dqs_n   (ddr3_dqs_n_sdram[s]),
           .tdqs_n  (),
           .odt     (ddr3_odt_sdram[r])
           );
      end
    end
  endgenerate


  //
  // PCI-Express Root Port FPGA Instantiation
  //
  xilinx_pcie_2_1_rport_7x
  #(
  .REF_CLK_FREQ                   ( REF_CLK_FREQ               ),
  .PL_FAST_TRAIN                  ( "TRUE"                     ),
  .ALLOW_X8_GEN2                  ( "TRUE"                     ),
  .C_DATA_WIDTH                   ( 128                        ),
  .LINK_CAP_MAX_LINK_WIDTH        ( LINK_CAP_MAX_LINK_WIDTH_RP ),
  .DEVICE_ID                      ( 16'h7100                   ),
  .LINK_CAP_MAX_LINK_SPEED        ( 4'h2                       ),
  .LINK_CTRL2_TARGET_LINK_SPEED   ( 4'h2                       ),
  .DEV_CAP_MAX_PAYLOAD_SUPPORTED  ( 1                          ),
  .TRN_DW                         ( "TRUE"                     ),
  .PCIE_EXT_CLK                   ( "TRUE"                     ),
  .VC0_TX_LASTPACKET              ( 29                         ),
  .VC0_RX_RAM_LIMIT               ( 13'h7FF                    ),
  .VC0_CPL_INFINITE               ( "TRUE"                     ),
  .VC0_TOTAL_CREDITS_PD           ( 437                        ),
  .VC0_TOTAL_CREDITS_CD           ( 461                        ),
  .USER_CLK_FREQ                  ( USER_CLK_FREQ_RP           ),
  .USER_CLK2_DIV2                 ( USER_CLK2_DIV2_RP          )
  ) RP (
 
  // SYS Inteface
  .sys_clk(rp_sys_clk),
  .sys_rst_n(sys_rst_n),
  
  // PCI-Express Interface
  .pci_exp_txn(rp_pci_exp_txn),
  .pci_exp_txp(rp_pci_exp_txp),
  .pci_exp_rxn(ep_pci_exp_txn),
  .pci_exp_rxp(ep_pci_exp_txp)

);


  // Messages and simulation control
//  initial begin
//    #200;
//    @(negedge RP.user_reset);
//    $display("[%t] : TRN Reset deasserted", $realtime);
//  end
//  initial begin
//    #200;
//    @(posedge RP.user_lnk_up);
//    $display("[%t] : Link up", $realtime);
//  end
//  initial begin
//    #200;
//    @(posedge RP.pl_sel_link_rate);
//    $display("[%t] : Link trained up to 5.0 GT/s", $realtime);
//  end
//  initial begin
//    #200;
//    @(posedge RP.finished_config);
//    $display("[%t] : Configuration succeeded", $realtime);
//  end
//  initial begin
//    #200;
//    @(posedge RP.failed_config);
//    $display("[%t] : Configuration failed. TEST FAILED.", $realtime);
//  end
//  initial begin
//    #200;
//    @(posedge RP.pio_test_finished);
//    $display("[%t] : PIO TEST PASSED", $realtime);
//    $display("Test Completed Successfully");
//    #100;
//    #1000;
//    $finish;
//  end
//  initial begin
//    #200;
//    @(posedge RP.pio_test_failed);
//    $display("[%t] : PIO TEST FAILED", $realtime);
//    #100;
//    $finish;
//  end

initial
  begin : Logging
           wait (init_calib_complete); //wait until init_calib_complete is done
           $display("MIG Calibration Done");
  end

  initial begin
    #2500000;  // 200us timeout
    $display("[%t] : Simulation timeout. TEST FAILED", $realtime);
    #100;
    $finish;
  end

  initial begin
    #2500000;  // 200us timeout
    $display("[%t] : Simulation timeout. TEST FAILED", $realtime);
    #100;
    $finish;
  end

initial begin

  if ($test$plusargs ("dump_all")) begin

`ifdef NCV // Cadence TRN dump

    $recordsetup("design=board",
                 "compress",
                 "wrapsize=100M",
                 "version=1",
                 "run=1");
    $recordvars();

`elsif VCS //Synopsys VPD dump

    $vcdplusfile("board.vpd");
    $vcdpluson;
    $vcdplusglitchon;
    $vcdplusflush;

`else

    // Verilog VC dump
    $dumpfile("board.vcd");
    $dumpvars(0, board);

`endif

  end

end


endmodule // BOARD
