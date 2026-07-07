//
// board_proto_bus.sv
//
// BSD 3-Clause License
// 
// Copyright (c) 2026, Albert Herranz
//
// based on board_rev1_bus.sv
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

/***************************************************************
 * MSX バスの入力 / MSX Bus input
 ***************************************************************/
module BOARD_PROTO_BUS (
    input wire              RESET_n,
    input wire              CLK,
    input wire              CLK_21M,

    input   wire            CART_RESET_n,
    input   wire            CART_RD_n,
    input   wire            CART_WR_n,
    input   wire            CART_IORQ_n,
    input   wire    [7:0]   CART_ADDR_SIG,
    inout   wire    [7:0]   CART_DATA_SIG,
    output  wire            CART_OE_n,
    output  wire            CART_DATA_DIR,

    output  wire            CART_INT,
    output  wire            CART_WAIT,

    BUS_IF.MSX              Bus
);

    /***************************************************************
     * Bus I/F の更新 / Bus I/F update
     ***************************************************************/
    always_ff @(posedge CLK or negedge RESET_n) begin
        if(!RESET_n) begin
            Bus.ADDR[7:0] <= 8'hFF;
            Bus.DIN       <= 8'hFF;
            Bus.IORQ_n    <= 1;
            Bus.RD_n      <= 1;
            Bus.WR_n      <= 1;
            Bus.RESET_n   <= 1;
        end
        else begin
            Bus.ADDR[7:0] <= w_bus_addr[7:0];
            Bus.DIN       <= w_bus_din;
            Bus.IORQ_n    <= w_bus_iorq_n;
            Bus.RD_n      <= w_bus_rd_n;
            Bus.WR_n      <= w_bus_wr_n;
            Bus.RESET_n   <= w_bus_reset_n;
        end
    end

    /***************************************************************
     * アドレスバスの取得 / Obtaining an address bus
     ***************************************************************/
    wire [7:0] w_bus_addr;
    PIN_FILTER u_a0    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[0]), .OUT(w_bus_addr[ 0]));
    PIN_FILTER u_a1    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[1]), .OUT(w_bus_addr[ 1]));
    PIN_FILTER u_a2    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[2]), .OUT(w_bus_addr[ 2]));
    PIN_FILTER u_a3    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[3]), .OUT(w_bus_addr[ 3]));
    PIN_FILTER u_a4    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[4]), .OUT(w_bus_addr[ 4]));
    PIN_FILTER u_a5    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[5]), .OUT(w_bus_addr[ 5]));
    PIN_FILTER u_a6    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[6]), .OUT(w_bus_addr[ 6]));
    PIN_FILTER u_a7    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_ADDR_SIG[7]), .OUT(w_bus_addr[ 7]));

    /***************************************************************
     * その他の信号の取得 / Other progress acquisition
     ***************************************************************/
    wire w_bus_rd_n;
    wire w_bus_wr_n;
    wire w_bus_iorq_n;
    wire w_bus_reset_n;
    PIN_FILTER u_nrd    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_RD_n   ), .OUT(w_bus_rd_n   ));
    PIN_FILTER u_nwr    (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_WR_n   ), .OUT(w_bus_wr_n  ));
    PIN_FILTER u_niorq  (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_IORQ_n ), .OUT(w_bus_iorq_n ));
    PIN_FILTER u_nreset (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_RESET_n), .OUT(w_bus_reset_n));

    /***************************************************************
     * データバス / Data bus
     ***************************************************************/
    wire [7:0] w_bus_din;
    // 0: CPU->Cartridge (WRITE from CPU), 1: Cartridge->CPU (READ from CPU)
    wire dir = !Bus.BUSDIR_n;
    assign  CART_OE_n = 1'b0;
    assign  CART_DATA_DIR = dir;
    assign  CART_DATA_SIG = dir ? Bus.DOUT : 8'bZZZZ_ZZZZ;
    PIN_FILTER u_d0_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[0]), .OUT(w_bus_din[0]));
    PIN_FILTER u_d1_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[1]), .OUT(w_bus_din[1]));
    PIN_FILTER u_d2_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[2]), .OUT(w_bus_din[2]));
    PIN_FILTER u_d3_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[3]), .OUT(w_bus_din[3]));
    PIN_FILTER u_d4_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[4]), .OUT(w_bus_din[4]));
    PIN_FILTER u_d5_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[5]), .OUT(w_bus_din[5]));
    PIN_FILTER u_d6_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[6]), .OUT(w_bus_din[6]));
    PIN_FILTER u_d7_in (.CLK(CLK), .RESET_n(RESET_n), .ENA(1'b1), .IN(CART_DATA_SIG[7]), .OUT(w_bus_din[7]));

    /***************************************************************
     * その他の信号の出力 / Other signal outputs
     ***************************************************************/
    assign  CART_INT = !Bus.INT_n;
    assign  CART_WAIT = !Bus.WAIT_n;

endmodule

/***************************************************************
 * input filter
 ***************************************************************/
module PIN_FILTER #(
    parameter   DEFAULT = 1    
) (
    input   wire        CLK,
    input   wire        RESET_n,
    input   wire        ENA,
    input   wire        IN,
    output  reg         OUT
) /* synthesis syn_preserve=1 */;
    logic prev;

    always_ff @(posedge CLK or negedge RESET_n)
    begin
        if(!RESET_n) begin
            OUT <= DEFAULT;
            prev <= DEFAULT;
        end
        else if(ENA) begin
            OUT <= (prev == IN) ? prev : OUT;
            prev <= IN;
        end
    end
endmodule

`default_nettype wire
