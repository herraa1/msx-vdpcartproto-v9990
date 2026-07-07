# V9990 on HRA! VDP Cartridge Prototype

This is a port by @herraa1 of [Shinobu Hashimoto's](https://github.com/buppu3) [V9990 RTL](https://github.com/buppu3/tnCart) to [Takayuki Hara's](https://github.com/hra1129) [VDP Prototype Cartridge for V9968](https://github.com/hra1129/V9968_Cartridge).

Using this RTL you can repurpose the HRA! V9968 prototype cartridge as a V9990 cartridge and enjoy [MSX software written for the V9990 VDP](https://www.msx.org/wiki/Category:V9990).

> [!NOTE]
> Successfully tested on all tested MSX machines so far: Omega MSX2+, Tides Rider MSX2+, JFF-TMSHAT MSX1 and Panasonic FS-A1WSX MSX2+.


## How to build the bitstream on Linux

- Launch GoWin IDE (GOWIN FPGA Designer Version V1.9.9.03 Education build(73833))

  ~~~Shell
  gw_ide
  ~~~

- Load the `rtl/board_proto.gprj` (File | Open ...)

- Go to the Process window, right click on "Synthesize" and select "Clean&Rerun All"


## Flashing instructions

> [!NOTE]
> You will need to use openFPGALoader >= v0.10.0.

- Flash the bitstream [`board_proto.fs`](https://github.com/herraa1/msx-vdpcartproto-v9990/raw/refs/heads/main/rtl/impl/pnr/board_proto.fs) into the Tang Nano 20k used in your HRA! VDP Cartridge.

  ~~~Shell
  cd rtl
  openFPGALoader -f -b tangnano20k --external-flash impl/pnr/board_proto.fs
  ~~~


## Usage

With your MSX computer turned off, insert your HRA! VDP Cartridge flashed with the V9990 RTL into a free cartridge slot of your MSX computer and connect an HDMI display to the HDMI connector of the Tang Nano 20k in your HRA! VDP Cartridge.
Prepare whatever V9990 software you plan to run (game cartridge, disk, flash rom cartridge, etc.), turn on your MSX computer and load the V9990-enabled software according to the software's provided instructions. You should see in your HDMI display the output of the V9990 VDP. Enjoy!


## Random Notes

* For simplicity in porting the RTL, the VRAM still uses the UMA module even now being the unique user of the RAM
