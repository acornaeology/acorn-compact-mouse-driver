# Acorn Master Compact Mouse Driver (PMFS)

[![Verify disassembly](https://github.com/acornaeology/acorn-compact-mouse-driver/actions/workflows/verify.yml/badge.svg)](https://github.com/acornaeology/acorn-compact-mouse-driver/actions/workflows/verify.yml)

An annotated disassembly of PMFS, the pointer and mouse driver on the Acorn BBC Master Compact Welcome disc. PMFS is a 65C02 sideways ROM image, loaded into sideways RAM, that moves a software pointer from a quadrature mouse or trackerball, an analogue or digital joystick, or the cursor keys, and reports its position through ADVAL. MOS 5 has no mouse support of its own, so PMFS is the Master Compact's mouse driver, and the interface it presents is the one Welcome-era software expects. PMFS is (C) 1986 PMF, identified as Paul Fellows; the annotations and disassembly scripts here are (C) 2026 Acornaeology.

This repository contains an annotated disassembly of the PMFS ROM image, produced by reverse-engineering the original 65C02 machine code. Each disassembly includes named labels, comments explaining the logic, and cross-references between subroutines.

## Versions

- **PMFS 136, the Master Compact pointer and mouse driver**
  - [Formatted disassembly on acornaeology.uk](https://acornaeology.uk/acorn-compact-mouse-driver/136.html)
  - [Disassembly source on GitHub](https://github.com/acornaeology/acorn-compact-mouse-driver/blob/master/versions/pmfs-136/output/pmfs-136.asm)
  - [PMFS 136 (8 KB) in the ROM Library](https://tobylobster.github.io/rom_library/?md5=6f95ee5f69b7273c7bf0b932ebdb975f)

## How it works

The disassembly is produced by a Python script that drives [dasmos](https://github.com/acornaeology/dasmos), a programmable disassembler for 6502 binaries. The script feeds the original ROM image to dasmos along with annotations — entry points, labels, constants, and comments — to produce readable assembly output.

The output is verified by reassembling with [beebasm](https://github.com/stardot/beebasm) and comparing the result byte-for-byte against the original ROM image. This round-trip verification runs automatically in CI on every push.

The analysis surface around dasmos (verify, lint, audit, cfg, comments, address mapping across versions, …) is provided by [fantasm](https://acornaeology.github.io/fantasm/) — see its docs for the full command and API reference.

## Provenance

The ROM image is the file `$.WIMPS.R.PMFS` on the Master Compact Welcome disc titled "Welcome 1.03C Iss4", a copy of which is kept beside it in `versions/pmfs-136/`. The disc image is byte-identical to the one in the [acorn.huininga.nl archive of original discs](https://acorn.huininga.nl/pub/disks/originals/Acorn/Master%20Compact%20Welcome%20Disc/). Every file on it is identical to [VectorEyes's flux capture](https://stardot.org.uk/forums/viewtopic.php?p=489005#p489005) of a physical disc with the same title, which lacks only three files the Welcome desktop writes in use (`$.WIMPS.Index1ADDR`, `$.WIMPS.Index1adre` and `$.WIMPS.Scratch`).

Later Welcome discs, and the Econet Level 4 File Server supplementary discs, carry a 6 KB build of PMFS 136 (MD5 `8826f28b3575e9481944528ebf09893c`) instead, which is not disassembled here. To re-extract it from the disc image and check it against the committed copy:

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

- [Tom Seddon's annotated disassembly of the Master MOS](https://github.com/tom-seddon/acorn_mos_disassembly)
  The Master Compact's MOS 5.00, whose service calls, extended vectors, joystick handling and *SRLOAD PMFS relies on.
- [David Atherton, Master Operating System: A Dabhand Guide (Dabs Press, 1987), remade edition](https://github.com/acheton1984/AcornDocsRemade/blob/main/DabsMOS/dabs%20mos%20remade%20draft%201c.pdf)
  Reserves &0D92-&0D9E for a trackerball or other input device (p205), where PMFS keeps its saved vectors and IRQ1V routine, and allows a mouse driver to use it (p79).
- [The Master Compact Welcome disc image (acorn.huininga.nl)](https://acorn.huininga.nl/pub/disks/originals/Acorn/Master%20Compact%20Welcome%20Disc/)
  Disc title "Welcome 1.03C Iss4". Byte-identical to the copy kept in this repository, from which the PMFS ROM image is extracted.
- [VectorEyes's flux capture of a Master Compact Welcome disc](https://stardot.org.uk/forums/viewtopic.php?p=489005#p489005)
  A capture of a physical "Welcome, Application and Utilities" disc titled "Welcome 1.03C Iss4". Every file on it, PMFS included, is identical to the image used here, which also holds three files written by the Welcome desktop.
- [Econet Level 4 File Server supplementary discs, issues 1 and 2](https://acorn.huininga.nl/pub/disks/originals/Acorn/)
  Their $.Comp_Wel directory holds the later 6 KB build of PMFS 136 (MD5 8826f28b3575e9481944528ebf09893c), not disassembled here.
- [PMFS in the ROM Library](https://tobylobster.github.io/rom_library/?md5=8826f28b3575e9481944528ebf09893c)
  The ROM Library's entry for PMFS, with the 6 KB and 8 KB builds and links to Acorn User articles of December 1986 and April 1987.
- [Paul Fellows at Binary Dinosaurs](https://binarydinosaurs.co.uk/Museum/Acorn/fellows.php)
  Paul Fellows ran Acornsoft's languages group and led the team that wrote Arthur. He was identified as the PMF of PMFS's copyright string by @acheton1984.
- [Marconi trackerball ROM in the ROM Library](https://tobylobster.github.io/rom_library/?md5=f1bd3ed57e9d6b5380fffe4b91995c6e)
  An earlier Acorn pointer driver, (C) Acorn 1985, supplied with the Marconi trackerball.
- [Domesday VFS ROMs in the ROM Library](https://tobylobster.github.io/rom_library/?search=vfs)
  The Video Filing System of the Domesday (Master AIV) system, (C) 1986 Acorn. Master Operating System: A Dabhand Guide (p79) notes that the Master AIV system includes code to drive the Marconi trackerball.
- [Stardot: the Master Compact Welcome disc versions](https://stardot.org.uk/forums/viewtopic.php?t=33348)
  Physical Welcome discs, their titles and releases.
- [Stardot: Acorn's letters about PMFS and SPRITER](https://stardot.org.uk/forums/viewtopic.php?p=24125#p24125)
  BeebMaster's 1992 letters from Acorn, which could provide no documentation for the PMFS and SPRITER ROMs; see also https://stardot.org.uk/forums/viewtopic.php?p=414279#p414279.
- [Stardot: PMFS's commands](https://stardot.org.uk/forums/viewtopic.php?p=351023#p351023)
  BeebMaster's list of the PMFS star commands, and the Welcome menu items that use them.
- [The Master Compact Welcome disc image](versions/pmfs-136/BBC_Master_Compact_Welcome_Disc.adl)
  The ADFS disc image from which the PMFS ROM image is extracted ($.WIMPS.R.PMFS).

## Credits

- [dasmos](https://github.com/acornaeology/dasmos) — programmable 6502 disassembler used to drive the annotation pipeline. dasmos is a ground-up rewrite of [py8dis](https://github.com/acornaeology/py8dis) (originally by [SteveF](https://github.com/ZornsLemma), forked for acornaeology), to which it owes its core ideas
- [beebasm](https://github.com/stardot/beebasm) by Rich Talbot-Watkins and contributors
- [oaknut](https://github.com/rob-smallshire/oaknut), used to extract the ROM image from the Welcome disc image

## License

The annotations and disassembly scripts in this repository are released under the [MIT License](LICENSE). PMFS and the Welcome disc remain the property of their respective copyright holders.
