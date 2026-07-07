//
// bootloader.sv
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

/***************************************************************
 * ブートローダー / Bootloader
 ***************************************************************/
module BOOTLOADER #(
) (
    input wire              RESET_n,
    input wire              CLK,
    input wire              BusReset_n,
    input wire              RD_n,
    input wire              WR_n,
    output wire             WAIT_n,
    output reg              READY
);

    /***************************************************************
     * WAIT_n
     ***************************************************************/
    assign WAIT_n = READY;

    /***************************************************************
     * Bootloader state machine
     ***************************************************************/
    enum logic [4:0] {
        STATE_WAIT_POR = 0,
        STATE_WAIT_BOOT,

        STATE_COMPLETE
    } state;

    always @(posedge CLK or negedge RESET_n)
    begin
        if(!RESET_n)
        begin
            READY <= 0;
            state <= STATE_WAIT_POR;
        end
        else begin
            case (state)
                //------------------------------
                // wait RESET inactive
                //------------------------------
                STATE_WAIT_POR:
                begin
                    if(BusReset_n && RD_n && WR_n) begin
                        state <= STATE_COMPLETE;
                    end
                end

                //------------------------------
                // COMPLETE 
                //------------------------------
                STATE_COMPLETE:
                begin
                    if(!BusReset_n) begin
                        // リセットされた時 / When it is reset
                        state <= STATE_WAIT_POR;
                        READY <= 0;
                    end
                    else begin
                        READY <= 1;
                    end
                end
            endcase
        end
    end

endmodule


`default_nettype wire
