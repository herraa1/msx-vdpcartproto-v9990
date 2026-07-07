//
// main.sv
//
// BSD 3-Clause License
// 
// Copyright (c) 2024, Shinobu Hashimoto
// Copyright (c) 2026, Albert Herranz
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

module MAIN #(
) (
    input   wire            RESET_n,
    input   wire            CLK,
    BUS_IF.CARTRIDGE        Bus,                // BUS I/F
    RAM_IF                  VideoRam,           // VRAM I/F
    UMA_IF.CLK              UmaClock,           // UMA クロック
    VIDEO_IF                Video               // ビデオ出力
);
    /***************************************************************
     * V9990 カートリッジ / V9990 Cartridge
     ***************************************************************/
    if(CONFIG::ENABLE_V9990) begin
        CARTRIDGE_V9990 u_v9990 (
            .RESET_n        (SYS_RESET_n),
            .CLK,
            .P_WAIT_n       (BOOT_WAIT_n),
            .Bus            (Bus),
            .Ram            (VideoRam),
            .UmaClock,
            .Video          (Video)
        );
    end
    else begin
        always_comb Bus.connect_dummy();
        always_comb Video.connect_dummy();
        always_comb VideoRam.connect_dummy();
    end

    /***************************************************************
     * ブートローダー / Bootloader
     * Just used to make sure that modules start when conditions
     * are ready.
     ***************************************************************/
    logic SYS_RESET_n;
    logic BOOT_WAIT_n;
    logic BOOT_n;

    always_ff @(posedge CLK or negedge RESET_n) begin
        if(!RESET_n)     SYS_RESET_n <= 0;
        else if(!BOOT_n) SYS_RESET_n <= 0;
        else             SYS_RESET_n <= 1;
    end

    BOOTLOADER #(
    ) u_boot (
        .RESET_n,
        .CLK,
        .BusReset_n     (Bus.RESET_n),
        .RD_n           (Bus.RD_n),
        .WR_n           (Bus.WR_n),
        .WAIT_n         (BOOT_WAIT_n),
        .READY          (BOOT_n)
    );

endmodule


`default_nettype wire
