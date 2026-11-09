# Preliminary notes on PMFS

These notes predate the annotated disassembly in this repository. They
were made from the 6 KB build of PMFS; the disassembly is of the 8 KB
build on the Welcome disc. Where they disagree, the disassembly is
authoritative.

Notes towards an annotated disassembly of PMFS, the pointer and mouse
driver on Acorn's Master Compact Welcome disc (`$.WIMPS.R.PMFS`,
"PMFS 136 (C)1986 PMF").

Very little has been published about PMFS. This material comes from an
investigation in October 2026 while designing the SPItFIRE joystick and
mouse adapter for the Master Compact (`~/Code/spitfire`; see
`docs/adval-and-mouse-conventions.md` there).

## Contents

| Path | What it is |
|---|---|
| [pmfs-6k-investigation.md](pmfs-6k-investigation.md) | Everything known about PMFS: identification, builds, loading, commands, ADVAL, buttons, hooks, hardware, workspace, and how the Welcome software uses it |
| `recovered/` | Command output saved from the original investigation (see below) |

## What was lost, and what survives

The original work was done in a temporary directory that has since been
cleared. Lost:
- the extracted ROM images `PMFS_6k.rom` and `PMFS_8k.rom`;
- their full disassembly listings;
- the full exports of the five disc images and the detokenised BASIC
  listings.

The `recovered/` files were rebuilt from the session transcript. Each is
one command from the original investigation and the output it printed at
the time, so they are partial: only the ranges that were looked at.
`$SCRATCH` in them stands for the old temporary directory.

| Files | Contents |
|---|---|
| `02`-`05` | The Stardot thread's posts and attachment list, and the downloads |
| `07`, `08`, `20` | The oaknut-disc crash on the 40-track Welcome image, image sizes, and its disc title ("Welcome 1.03C Iss4") |
| `11`-`15` | File lists, `.inf` files and PMFS checksums from each disc image |
| `17` | Extracts from `$.Loader`, `QLOADER`, `WELCOME.Menu` and TimPaint |
| `18`, `19` | 6 KB vs 8 KB comparison; hexdump of the 8 KB image's first &280 bytes; strings |
| `22`-`25` | 6 KB disassembly: &81B7-&8400 (command table, turning on and off), &8740-&8A00 (BYTEV, IRQ, poll), &8A00-&8B40 (buttons, quadrature), &8B90-&8C20 (`*TMAX`, `*TSET`) |
| `26`, `27` | 8 KB disassembly extracts, and a diff of the two builds' first 1,500 lines |
| `28`-`32` | Checks for references to &87B2, and MOS 5.00 disassembly extracts (joystick, OSBYTE &80, User VIA set-up) |

The disassemblies were made with a small py65 wrapper, so data areas are shown
as (meaningless) instructions.

## Getting the images again

PMFS is in the disc images attached to the Stardot thread
"Master Compact Welcome disc"
(<https://stardot.org.uk/forums/viewtopic.php?t=33348>). Attachments
downloaded without a login at the time.

| Attachment | Download | Contents |
|---|---|---|
| `tbi103-2a.zip` (posted by markusher) | `https://stardot.org.uk/forums/download/file.php?id=120568` | `tbi103-2.adl`, `tbi103-2-prodest-128s.adl`, `tbi103-2a3.adl`, `tbi103-2a4.adl` (8BS-sourced Compact images; see <https://8bs.com/catalogue/tbi.htm>) |
| `master compact welcome.zip` (posted by SevernWolf) | `https://stardot.org.uk/forums/download/file.php?id=121857` | `watford-master-compact.adl` (80T) and `welcome-master-compact.adm` (40T capture, only half the disc; no PMFS in it) |

VectorEyes also posted a flux image of both sides at 80 tracks,
<https://vectoreyes.github.io/MasterCompactWelcomeDisc_BothSides_80T.scp>,
and a photo of the disc,
<https://vectoreyes.github.io/MasterCompactWelcomeDisc.png>. The
`master_welcome_rel*` attachments in the thread are Master 128 discs, not
Compact ones.

To extract PMFS ([oaknut-disc](https://rob-smallshire.github.io/oaknut/disc/install.html)):

```sh
unzip tbi103-2a.zip
uvx oaknut-disc export --meta-format inf-trad tbi103-2.adl x_tbi103-2
md5 x_tbi103-2/WIMPS/R/PMFS     # 8826f28b3575e9481944528ebf09893c (6 KB)
```

`tbi103-2a4.adl` gives the 8 KB build (`6f95ee5f69b7273c7bf0b932ebdb975f`).
oaknut-disc used to crash with an uncaught `ValueError` on the truncated
`welcome-master-compact.adm`
([oaknut #88](https://github.com/rob-smallshire/oaknut/issues/88), since
fixed).

The MOS 5.00 extracts came from Tom Seddon's annotated disassembly,
<https://github.com/tom-seddon/acorn_mos_disassembly>.

## Copyright

PMFS is (C) 1986 "PMF", and the Welcome software is Acorn's. The ROM
images and complete listings are not kept here; the `recovered/` files
contain extracts of the disassembly made for study.
