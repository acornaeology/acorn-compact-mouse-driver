# Acorn Master Compact Mouse Driver (PMFS)

[![Verify disassembly](https://github.com/acornaeology/acorn-compact-mouse-driver/actions/workflows/verify.yml/badge.svg)](https://github.com/acornaeology/acorn-compact-mouse-driver/actions/workflows/verify.yml)

An annotated disassembly of PMFS, the pointer and mouse driver on the Acorn BBC Master Compact Welcome disc. PMFS is a 65C02 sideways ROM image, loaded into sideways RAM, that moves a software pointer from a quadrature mouse or trackerball, an analogue or digital joystick, or the cursor keys, and reports its position through ADVAL. MOS 5 has no mouse support of its own, so PMFS is the Master Compact's mouse driver, and the interface it presents is the one Welcome-era software expects. PMFS is (C) 1986 PMF; the annotations and disassembly scripts here are (C) 2026 Acornaeology.

This repository contains an annotated disassembly of the PMFS ROM image, produced by reverse-engineering the original 65C02 machine code. Each disassembly includes named labels, comments explaining the logic, and cross-references between subroutines.

## Versions

- **PMFS 136, the Master Compact pointer and mouse driver**
  - [Formatted disassembly on acornaeology.uk](https://acornaeology.uk/acorn-compact-mouse-driver/136.html)
  - [Disassembly source on GitHub](https://github.com/acornaeology/acorn-compact-mouse-driver/blob/master/versions/pmfs-136/output/pmfs-136.asm)
  - [Stardot thread: Master Compact Welcome disc](https://stardot.org.uk/forums/viewtopic.php?t=33348)

## How it works

The disassembly is produced by a Python script that drives [dasmos](https://github.com/acornaeology/dasmos), a programmable disassembler for 6502 binaries. The script feeds the original ROM image to dasmos along with annotations — entry points, labels, constants, and comments — to produce readable assembly output.

The output is verified by reassembling with [beebasm](https://github.com/stardot/beebasm) and comparing the result byte-for-byte against the original ROM image. This round-trip verification runs automatically in CI on every push.

The analysis surface around dasmos (verify, lint, audit, cfg, comments, address mapping across versions, …) is provided by [fantasm](https://acornaeology.github.io/fantasm/) — see its docs for the full command and API reference.

## Provenance

The ROM image is the file `$.WIMPS.R.PMFS` on the Master Compact Welcome disc, a copy of which is kept beside it in `versions/pmfs-136/`. To re-extract it from the disc image and check it against the committed copy:

```sh
uv run python tools/extract_rom.py
```

## Disassembling locally

Requires [uv](https://docs.astral.sh/uv/) and [beebasm](https://github.com/stardot/beebasm) (v1.10+).

```sh
uv sync
uv run fantasm disassemble 136
uv run fantasm verify 136
```

## (Re-)Assembling locally

To assemble the `.asm` file back into a ROM image using [beebasm](https://github.com/stardot/beebasm):

```sh
beebasm -i versions/pmfs-136/output/pmfs-136.asm -o pmfs-136.rom
```

## References

- [Stardot thread: Master Compact Welcome disc](https://stardot.org.uk/forums/viewtopic.php?t=33348)
  Disc images of the Master Compact Welcome disc, from which PMFS is extracted.
- [Tom Seddon's annotated disassembly of MOS 3.20 and 5.00](https://github.com/tom-seddon/acorn_mos_disassembly)
  The Master Compact's MOS 5.00, whose joystick, ADVAL and User VIA handling PMFS builds on.

## Credits

- [dasmos](https://github.com/acornaeology/dasmos) — programmable 6502 disassembler used to drive the annotation pipeline. dasmos is a ground-up rewrite of [py8dis](https://github.com/acornaeology/py8dis) (originally by [SteveF](https://github.com/ZornsLemma), forked for acornaeology), to which it owes its core ideas
- [beebasm](https://github.com/stardot/beebasm) by Rich Talbot-Watkins and contributors
- [oaknut](https://github.com/rob-smallshire/oaknut), used to extract the ROM image from the Welcome disc image

## License

The annotations and disassembly scripts in this repository are released under the [MIT License](LICENSE). PMFS and the Welcome disc remain the property of their respective copyright holders.
