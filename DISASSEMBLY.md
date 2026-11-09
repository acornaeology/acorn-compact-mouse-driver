# Disassembly Guide

How the PMFS disassembly is produced and checked.

For project overview and build instructions, see [README.md](README.md). For architecture details, see [CLAUDE.md](CLAUDE.md). For terminology, see [GLOSSARY.md](GLOSSARY.md).

PMFS is a sideways ROM image, so this project follows the ROM layout of the sibling projects: the image is loaded at &8000 and the whole 8 KB image must reassemble byte-for-byte.

## Prerequisites

- [uv](https://docs.astral.sh/uv/)
- [beebasm](https://github.com/stardot/beebasm) (v1.10+)

## Quick reference

| Command | Description |
|---------|-------------|
| `uv run fantasm disassemble 136` | Run the dasmos driver, writing `output/pmfs-136.asm` and `.json` |
| `uv run fantasm verify 136` | Reassemble with beebasm and byte-compare all 8192 bytes |
| `uv run fantasm lint 136 versions/pmfs-136/disassemble/disasm_pmfs_136.py` | Check that every annotation address lands on an item |
| `uv run fantasm comments check 136` | Comments inside items, or contradicting their instruction |
| `uv run fantasm coverage 136` | Proportion of instructions with inline comments |
| `uv run fantasm data runs 136 --unannotated` | Data with no label or comment |
| `uv run fantasm audit undeclared 136` | Call targets with no declaration |
| `uv run python tools/extract_rom.py` | Check the ROM image against the Welcome disc image |

## Layout

```
versions/pmfs-136/
  BBC_Master_Compact_Welcome_Disc.adl   # the Welcome disc (ADFS L), source of the ROM image
  rom/
    pmfs-136.rom                        # $.WIMPS.R.PMFS, byte for byte
    rom.json                            # title, hashes, memory-map groups, links
  disassemble/
    disasm_pmfs_136.py                  # the dasmos driver: the source of truth
  output/
    pmfs-136.asm, pmfs-136.json         # generated; never edit by hand
```

## The driver script

`disasm_pmfs_136.py` is organised top to bottom as the ROM is:

1. External labels (MOS entry points, vectors, page &0D, zero page) and PMFS's workspace in its own bank, each with `group=` and a description for the memory-map page.
2. Constants for service calls, device modes, VIA and ACCCON bits, and limits.
3. One section per area of the ROM: service handler, screen address calculation, desktop colours, star commands, device commands, `*POINTER`, drawing, the workspace exchange, the shifted images, BYTEV, IRQ, polling, buttons, mouse movement, `*TMAX` and `*TSET`, and the data tables and images.
4. Below the `END OF ANNOTATIONS` marker, the entry points reached only through tables and vectors, then the render.

Every instruction has an inline comment (`cm(addr, text)`), every routine a `d.subroutine` banner and every data region a `d.banner`. Addresses in immediates are rendered symbolically with `d.expr`.

## Checks before committing

```sh
uv run fantasm disassemble 136
uv run fantasm verify 136
uv run fantasm lint 136 versions/pmfs-136/disassemble/disasm_pmfs_136.py
uv run fantasm comments check 136
```

`comments check` reports a few medium-confidence notes about &3000, &7FFF and &946F in text; those are screen and workspace addresses, not stale labels.
