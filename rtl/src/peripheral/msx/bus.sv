//
// bus.sv
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

// this is a limited set of bus signals available in HRA! VDP Prototype Cartridge

interface BUS_IF;
    // MSX->カートリッジ / MSX -> Cartridge
    logic [7:0]     ADDR;           // ADDRESS
    logic [7:0]     DIN;            // データバス(MSX->DEVICE) / Data bus (MSX->DEVICE)
    logic           RD_n;           // リード信号 / Read signal
    logic           WR_n;           // ライト信号 / Write signal
    logic           IORQ_n;         // I/O 選択 / I/O request
    logic           RESET_n;        // MSX のリセット信号 / MSX reset signal

    // カートリッジ->MSX / Cartridge -> MSX
    logic [7:0]     DOUT;           // データバス / Data bus
    logic           BUSDIR_n;       // データバス方向(0 = DOUT enable) / Data bus direction
    logic           INT_n;          // 割り込み / interrupt
    logic           WAIT_n;         // ウェイト / wait

    // MSX 側ポート / MSX side port
    modport MSX(
                    output ADDR, DIN, RD_n, WR_n, IORQ_n, RESET_n,
                    input  DOUT, BUSDIR_n, INT_n, WAIT_n
                );

    // カートリッジ側ポート / Cartridge side port
    modport CARTRIDGE(
                    input  ADDR, DIN, RD_n, WR_n, IORQ_n, RESET_n,
                    output DOUT, BUSDIR_n, INT_n, WAIT_n
                );

    // ダミー接続 / Dummy connection
    function automatic void connect_dummy();
        DOUT = 0;
        BUSDIR_n = 1;
        INT_n = 1;
        WAIT_n = 1;
    endfunction
endinterface

`default_nettype wire
