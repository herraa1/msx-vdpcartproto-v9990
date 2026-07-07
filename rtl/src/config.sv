//
// config.sv
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

/***********************************************************************************
 * メイン設定
 ***********************************************************************************/
package CONFIG;
    /***************************************************************
     * 機能に指定する定数 / Constants to specify for a function
     ***************************************************************/
    localparam DISABLE          = 0;            // 機能の無効 / Disable function
    localparam ENABLE           = 1;            // 機能の有効 / Enable function

    /***************************************************************
     * SD-RAM メモリマップ / SD-RAM memory map
     * We keep just the VDP VRAM.
     *
     *  78_0000 +-------------------+
     *          | VRAM(512KB)       |
     *  80_0000 +-------------------+
     ***************************************************************/
    localparam [23:0]   RAM_ADDR_VRAM           = 24'h78_0000;

    localparam          RAM_V9990               = 0;
    localparam          RAM_COUNT               = 1;

    localparam          ENABLE_V9990            = ENABLE;           // V9990 を有効にするか(DISABLE/ENABLE) / Enable V9990 (DISABLE/ENABLE)
    localparam          ENABLE_V9990_CMD        = ENABLE;           // V9990 の VDP コマンドを有効(V9990のVDPコマンドを有効にすると回路の規模が大きくなるので、他の大きな機能と同時使用はできない)
                                                                    // Enable the VDP command for the V9990 (Enabling the VDP command for the V9990 increases the circuit size, so it cannot be used simultaneously with other large functions).
    localparam          ENABLE_SCANLINE         = DISABLE;          // 200ラインモード時に走査線の隙間を空ける / When in 200-line mode, leave a gap between scan lines.

    localparam          RAM_IF_EXPANSION_USES_FF= 0;                // RAM I/F 拡張動作に FF を使用(0=使用しない/1=使用する) / Use FF for RAM I/F expansion operation (0 = not used / 1 = used)
endpackage

`default_nettype wire
