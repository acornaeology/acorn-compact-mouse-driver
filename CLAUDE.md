# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

An annotated disassembly of **PMFS**, the pointer and mouse driver on the Acorn BBC Master Compact Welcome disc (`$.WIMPS.R.PMFS`, "PMFS 136 (C)1986 PMF"). PMFS is a 65C02 sideways ROM image, loaded into sideways RAM with `*SRLOAD`, so the project follows the layout of the sibling ROM projects (acorn-adfs, acorn-nfs), with one fantasm version, id `136`.

The project has two goals:

1. A fully annotated disassembly to the same standard as the sibling projects, verified by byte-identical reassembly.
2. A formal definition of the driver's API (star commands, ADVAL channels, service calls, OSBYTE extensions, button-to-key mapping, hardware conventions), so that compatible drivers for other mouse hardware can be written. This lives in `docs/analysis/`.

Follow the `disassembly-skills:6502-disassembly` skill's method.

## Build commands

Requires [uv](https://docs.astral.sh/uv/) and [beebasm](https://github.com/stardot/beebasm) (v1.10+).

```sh
uv sync
uv run fantasm disassemble 136
uv run fantasm verify 136          # must report 8192 bytes match
uv run fantasm lint 136 versions/pmfs-136/disassemble/disasm_pmfs_136.py
uv run fantasm comments check 136
uv run python tools/extract_rom.py # the ROM image matches the file on the disc image
uv run generate_readme.py          # after changing acornaeology.json, rom.json or README.md.j2
```

## Binaries

| File | Load | Size | MD5 | Notes |
|---|---|---|---|---|
| `versions/pmfs-136/rom/pmfs-136.rom` | &8000 (`.inf` load &FFFF8000) | &2000 | `6f95ee5f69b7273c7bf0b932ebdb975f` | `$.WIMPS.R.PMFS` on the Welcome disc |
| `versions/pmfs-136/BBC_Master_Compact_Welcome_Disc.adl` | | 640 KB | `96d54a27b237886fd76bcc5ad2574e33` | ADFS L image of the Welcome disc; the ROM's source. Identical to b2's `etc/discs/CompactWelcome.adl` |

- CPU: 65C02 (`cpu="65c02"`). PMFS uses STZ, PHX, PHY and BRA.
- Header: no language entry; service entry `JMP &801E`; ROM type &82; binary version 1.
- The ROM keeps its workspace inside its own bank at &9000 upwards, so it only works from sideways RAM.
- A 6 KB build of PMFS (MD5 `8826f28b3575e9481944528ebf09893c`) exists on other Compact disc images (tbi103-2 and others, see `docs/notes/README.md`). It is not on this Welcome disc and is not disassembled here.
- The rest of the Welcome disc (including SPRITER, Acorn's separate Sprite ROM) is out of scope.

## Layout

- Driver: `versions/pmfs-136/disassemble/disasm_pmfs_136.py`. The source of truth; never edit `output/` by hand.
- Generated: `versions/pmfs-136/output/pmfs-136.asm`, `pmfs-136.json`.
- `versions/pmfs-136/rom/rom.json`: title, hashes, memory-map groups and links used by the website.
- `docs/analysis/`: long-form articles, registered as `analyses` in `acornaeology.json`: `pointer-driver-interface.md` (the formal API specification, goal 2) and `how-pmfs-works.md` (internal design). Keep them in step with the driver's routine names.
- `docs/notes/`: preliminary notes from an earlier investigation of the 6 KB build, and recovered command output. Addresses there are mostly for the 6 KB build and some statements are inferences; the disassembly is authoritative.

## Coupling to the website

The sibling [acornaeology.github.io](https://github.com/acornaeology/acornaeology.github.io) generator renders each version's committed `output/*.json` plus `rom/rom.json`, and reads `acornaeology.json` for the project page. Keep `rom.json` `memory_map_groups` in step with the `group=` values used on `d.label(...)`.

## Conventions

- Hex as `&XXXX` in prose and comments, `0xXXXX` in Python.
- Comment every instruction; banner every routine and data region.
- Inline comments describe intent in domain terms (the pointer, the mouse, device mode, buttons), never a paraphrase of the mnemonic.
- Published text describes the program as it is; no history of the disassembly.
- Out-of-ROM labels (OS entry points, vectors, hardware registers, PMFS's own workspace at &9000) carry `group=`/`description=`/`access=`/`length=` so they populate the memory-map page.
- Do not identify "PMF" or "JPG" in the listing; the ROM shows only the initials.

## Key technical context

- **Workspace exchange.** PMFS's state lives at &9440-&946F between calls and is swapped into &9000-&902F while it runs (`exchange_workspace`; the IRQ path swaps only &9000-&9009). Anything at &9000-&902F that is read or written outside an enter/leave pair touches the wrong copy; &9030-&9037 are used in place.
- **Vectors.** BYTEV -> &FF0F (BYTEV's extended vector entry) -> `bytev_handler`. IRQ1V -> `irq1v_trampoline` at &0D99 (`JSR &FF06 : JMP old`) -> IRQ1V's extended vector entry -> `irq_handler`. Extended vector entry points are &FF00 + 3n, and n*3 is also the table offset.
- **MOS 5 facts used** (from `~/Code/acorn_mos_disassembly`): service &15 is issued each centisecond while the ROM polling semaphore is non-zero; service &07 has the OSBYTE's A/X in &EF/&F0 and Y in Y; Compact joystick port is PB0 fire, PB1 left, PB2 down, PB3 up, PB4 right, read into `ADVAL(0)` bits 0, 4, 5, 6, 7; `ADVAL(0)` bits 1-3 are mouse buttons only a ROM can supply (service &2C); `&034E` is the screen start high byte.
- **Welcome software usage** was read from its detokenised BASIC (oaknut-basic): `$.Loader` does `*SRLOAD PMFS 8000 5 Q`, `?&2A6=&82`, `*DIGITAL`, `*FX23`, `*FX163,243,128`; programs use `*POINTER`/`*POINTER 0`/`*POINTER 2`, `ADVAL(7)`/`(8)`, `ADVAL(9)=0` (TimPaint), `*TSET` (crnw), `*SETPAL`, `*FX22`, and OSBYTE &A3,&F3 with Y=(n*8) OR &40.

## Open questions

- Behaviour claims are from reading the code; none has yet been confirmed in an emulator. b2 (`~/Code/b2`) has a Master Compact config and an HTTP API on port 48075 (reset, paste, peek, poke), but requests timed out when tried; worth retrying to confirm the defects listed in the interface specification (section 12), especially the reset defect and the &90 corruption.
- Why the state is exchanged between &9000 and &9440 rather than used in place.
- What PMFS, PMF and JPG stand for.
