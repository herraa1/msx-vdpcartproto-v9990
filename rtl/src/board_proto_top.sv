//
// board_proto_top.sv
//
// BSD 3-Clause License
// 
// Copyright (c) 2026, Albert Herranz
//
// based on board_rev1_top.sv
// Copyright (c) 2024, Shinobu Hashimoto
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

`default_nettype none

module BOARD_PROTO_TOP (
    input   wire            CLK_27M, // tang nano 20k internal clock
    //input   wire            CLK_14M, // original vdp proto cart clock 14.318180MHz, unused

    // SDRAM
    inout   wire            O_sdram_clk,
    output  wire            O_sdram_cke,
    output  wire            O_sdram_cs_n,
    output  wire            O_sdram_cas_n,
    output  wire            O_sdram_ras_n,
    output  wire            O_sdram_wen_n,
    inout   wire    [31:0]  IO_sdram_dq,
    output  wire    [10:0]  O_sdram_addr,
    output  wire    [1:0]   O_sdram_ba,
    output  wire    [3:0]   O_sdram_dqm,

    // BUS (limited signals available)
    input   wire            CART_RESET_n,
    input   wire            CART_IORQ_n,
    input   wire            CART_RD_n,
    input   wire            CART_WR_n,
    input   wire    [7:0]   CART_ADDR_SIG,
    inout   wire    [7:0]   CART_DATA_SIG,
    output  wire            CART_OE_n,
    output  wire            CART_DATA_DIR, // 0: CPU -> Cart (write), 1: Cart -> CPU (read)
    output  wire            CART_INT,
    output  wire            CART_WAIT,

    // TMDS
    output wire             tmds_clk_p,
    output wire             tmds_clk_n,
    output wire    [2:0]    tmds_data_p,
    output wire    [2:0]    tmds_data_n
);
    // UMA を有効 / Enable UMA
    localparam          ENABLE_UMA              = 1;//CONFIG::ENABLE_V9990; // always enable for now

    /***************************************************************
     * CLOCK
     ***************************************************************/
    logic CLK_BASE/* synthesis syn_keep=1 */;
    logic CLK_21M/* synthesis syn_keep=1 */;
    logic CLK_BASE_READY;
    logic CLK_MEM;
    logic CLK_MEM_P;
    logic CLK_MEM_READY;
    logic CLK_TMDS_S/* synthesis syn_keep=1 */;
    logic CLK_TMDS_P/* synthesis syn_keep=1 */;
    logic CLK_TMDS_READY;
    BOARD_PROTO_CLOCK u_clk (
        .RESET_n        (1'b1),
        .CLK_IN         (CLK_27M),
        .CLK_BASE,
        .CLK_21M,
        .CLK_BASE_READY,
        .CLK_MEM,
        .CLK_MEM_P,
        .CLK_MEM_READY,
        .CLK_TMDS_S,
        .CLK_TMDS_P,
        .CLK_TMDS_READY
    );

    /***************************************************************
     * MSX バス / MSX bus
     ***************************************************************/
    wire RESET_n;
    wire CLK = CLK_BASE;
    BUS_IF Bus();

    // リセット信号処理 / Reset signal processing
    reg reset_n = 0;
    assign RESET_n = reset_n;
    always_ff @(posedge CLK_BASE or negedge CLK_BASE_READY or negedge sdram_ready) begin
        if(!CLK_BASE_READY) reset_n <= 0;       // PLL 準備中ならリセット
        else if(!sdram_ready) reset_n <= 0;     // SDRAM 準備中ならリセット
        else reset_n <= 1; 
    end

    // バス信号処理 / Bus signal processing
    BOARD_PROTO_BUS u_bus (
        .RESET_n,
        .CLK,
        .CLK_21M,
        .CART_RESET_n,
        .CART_RD_n,
        .CART_WR_n,
        .CART_IORQ_n,
        .CART_ADDR_SIG,
        .CART_DATA_SIG,
        .CART_OE_n,
        .CART_DATA_DIR,
        .CART_INT,
        .CART_WAIT,
        .Bus
    );

    /***************************************************************
     * SDRAM
     ***************************************************************/
    RAM_IF Ram();
    logic sdram_ready;
    SDRAM #(
        .SDRAM_A_WIDTH      (11),
        .SDRAM_BA_WIDTH     (2),
        .SDRAM_COL_WIDTH    (8),
        .SDRAM_ROW_WIDTH    (11),
        .SDRAM_DQ_WIDTH     (32)
    ) u_sdram (
        .CLK                (CLK_MEM),
        .CLK_PS             (CLK_MEM_P),
        .RESET_n            (CLK_MEM_READY),

        .READY              (sdram_ready),

        .SDRAM_CLK          (O_sdram_clk),
        .SDRAM_CKE          (O_sdram_cke),
        .SDRAM_CS_n         (O_sdram_cs_n),
        .SDRAM_RAS_n        (O_sdram_ras_n),
        .SDRAM_CAS_n        (O_sdram_cas_n),
        .SDRAM_WE_n         (O_sdram_wen_n),
        .SDRAM_A            (O_sdram_addr),
        .SDRAM_BA           (O_sdram_ba),
        .SDRAM_DQM          (O_sdram_dqm),
        .SDRAM_DQ           (IO_sdram_dq),

        .Ram
    );

    /***************************************************************
     * RAM wait 制御 / RAM wait control
     ***************************************************************/
    wire uma_wait;
    // simply don't wait
    assign uma_wait = 0;

    /***************************************************************
     * UMA CLK_EN
     ***************************************************************/
    wire uma_clk;
    // we don't need/use CLK_EN because CONFIG_BOARD::SYNC_CPU_UMA is 0
    // expect fireworks if CONFIG_BOARD::SYNC_CPU_UMA is not 0
    assign uma_clk = 0;

    /***************************************************************
     * UMA
     ***************************************************************/
    // UMA is kept for simplicity in porting the RTL 
    UMA_IF Uma();
    // Uma[0] is unused here, Uma[1] is VRAM
    assign Uma.ADDR[0] = 0;                         // Uma[0] の SDRAM 先頭アドレス / SDRAM starting address of Uma[0]
    assign Uma.ADDR[1] = CONFIG::RAM_ADDR_VRAM;     // Uma[1] の SDRAM 先頭アドレス / SDRAM starting address of Uma[1]

    RAM_IF UmaRam[0:Uma.COUNT-1]();

    // provide a driver for unused UmaRam[0] signals
    assign UmaRam[0].ADDR = 24'b0;
    assign UmaRam[0].OE_n = 1'b1;
    assign UmaRam[0].WE_n = 1'b1;
    assign UmaRam[0].RFSH_n = 1'b1;
    assign UmaRam[0].DIN = 32'b0;
    assign UmaRam[0].DIN_SIZE = 3'b0;

    if(ENABLE_UMA) begin
        UMA #(
            .COUNT      (Uma.COUNT),
            .SYNC_CLK_EN(CONFIG_BOARD::SYNC_CPU_UMA),
            .DIV        (30)                        // 108MHz/3.58MHz = 30
        ) u_uma (
            .RESET_n,
            .CLK,
            .CLK_EN     (uma_clk),
            .WAIT_EN    (uma_wait),
            .Primary    (Ram),
            .Secondary  (UmaRam),
            .Uma
        );
    end
    else begin
        // XXX this is unused, we always enable UMA for now
        // UMA を使わない時 / When not using UMA
        BYPASS_RAM u_bypass_uma (
            .Primary    (Ram),
            .Secondary  (UmaRam[0])
        );
        assign UmaRam[1].DOUT = 0;
        assign UmaRam[1].ACK_n = 1;
        assign UmaRam[1].TIMING = 0;
        assign Uma.CLK14M_EN = 0;
        assign Uma.CLK21M_EN = 0;
        assign Uma.CLK25M_EN = 0;
    end

    /***************************************************************
     * VIDEO
     ***************************************************************/
    VIDEO_IF Video();
    VIDEO_IF VideoTmds();
    VIDEO_UPSCAN #(
        .ENABLE_SCANLINE(CONFIG::ENABLE_SCANLINE)
    ) u_upscan (
        .RESET_n,
        .DCLK           (CLK_TMDS_P),
        .IN             (Video),
        .OUT            (VideoTmds)
    );

    BOARD_PROTO_TMDS_OUT u_tmds (
        .RESET_n,
        .IN             (VideoTmds),
        .TMDS_READY     (CART_RESET_n ? CLK_TMDS_READY : 1'b0),
        .CLK_S          (CLK_TMDS_S),
        .CLK_P          (CLK_TMDS_P),
        .TMDS_CLKP      (tmds_clk_p),
        .TMDS_CLKN      (tmds_clk_n),
        .TMDS_DATAP     (tmds_data_p),
        .TMDS_DATAN     (tmds_data_n)
    );

    /***************************************************************
     * MAIN
     ***************************************************************/
    MAIN u_main (
        .RESET_n,
        .CLK,
        .Bus,
        .VideoRam       (UmaRam[1]),
        .UmaClock       (Uma),
        .Video
    );

endmodule


`default_nettype wire
