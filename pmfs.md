# PMFS: the Master Compact's pointer and mouse driver

PMFS is the pointer driver on Acorn's Master Compact Welcome disc, at
`$.WIMPS.R.PMFS`. It is a sideways ROM image, loaded into sideways RAM,
that drives a software pointer from a mouse, trackerball, digital or
analogue joystick, or the cursor keys, and reports it through `ADVAL`.
MOS 5 has no mouse code of its own, so PMFS is the Compact's mouse
support.

These notes were written from a disassembly made in October 2026 while
designing the SPItFIRE adapter's ROM. The ROM images and full listings
were in a temporary directory and are now lost, but fragments of the
listings survive in `recovered/` (see the README). Addresses are from
the 6 KB build unless stated. Statements marked *(inferred)* come from
reading the code, not from running it.

## Identification

| | |
|---|---|
| ROM title | `PMFS` |
| Version string | `136` |
| Copyright | `(C)1986 PMF` |
| Other text | `JPG,PMF` near the end of the image (initials, presumably) |
| ROM type byte | &82 (service entry, no language entry) |
| CPU | 65C02 (uses STZ, PHX, PHY, BRA), so it needs a Master-series machine |

What "PMFS" stands for, and who PMF and JPG were, is not known.

The image starts `00 00 00 4C 1E 80 82 11 01`: no language entry, a
service entry `JMP &801E`, ROM type &82, copyright offset &11 and binary
version 1.

## Builds

| Build | Size | MD5 | Found on |
|---|---|---|---|
| 6 KB | &1800 | `8826f28b3575e9481944528ebf09893c` | tbi103-2, tbi103-2-prodest-128s, watford-master-compact |
| 8 KB | &2000 | `6f95ee5f69b7273c7bf0b932ebdb975f` | tbi103-2a3, tbi103-2a4 |

The two differ in 3,365 byte positions, mostly because code has moved.
Both have the same commands and the same ADVAL handling. In the 8 KB file,
the regions checked (&1800-&184F and &1EC0-&1FFF) are all zero, so it is
probably a slightly longer build padded to 8 KB *(inferred)*.

Differences seen:

| | 6 KB | 8 KB |
|---|---|---|
| Command table | &81FF | &81F5 |
| BYTEV handler | &8786 | &87C1 |
| `*TMAX` / `*TSET` handlers | &8BAF / &8BEC | &8C0B / &8C48 |
| ADVAL(5)-(8) read | Reads the workspace directly | First calls &8561 |

## Loading

The Welcome disc's `$.Loader` (BASIC) loads PMFS and turns it on:

```
170 _%=&2A1:*DIR &.WI*.R
190 *SRLOAD PMFS 8000 5 Q
200 *SRLOAD SPRITER 8000 4 Q
210 *SRLOAD CLEAN_PAD A000 5 Q
220 *SRLOAD CLEAN_INDX 8000 6 Q
230 _%?5=&82:_%?4=&82:*DIGITAL
```

- PMFS goes in sideways RAM bank 5, and SPRITER in bank 4.
- `_%` is &2A1, the MOS's ROM type table. The pokes mark banks 4 and 5
  as service ROMs, because `*SRLOAD ... Q` does not make the MOS
  recognise them until the next BREAK.
- `*DIGITAL` then turns the driver on in digital joystick mode.

Note that line 210 loads `CLEAN_PAD` at &A000 in the same bank 5, above
PMFS's code. PMFS's workspace is at &9000-&9037, so this does not clash.

PMFS keeps its workspace inside its own bank (&9000-&9037), so it only
works from sideways RAM *(inferred)*.

## Commands

Star commands are recognised on service call 4. Each table entry is the
command name followed by the handler address, high byte first (the high
byte has bit 7 set, which ends the name).

| Command | Handler (6 KB) | Effect |
|---|---|---|
| `*KEYS` | &829D | Mode &20: steers the pointer with the cursor keys (INKEY -26, -122, -58, -42), faster with SHIFT. Also does `*FX4,2` and `*FX226,0` |
| `*DIGITAL` | &82B6 | Mode &40: steers from the MOS digital joystick (`ADVAL(0)` direction bits) |
| `*JOYSTICK` | &82BD | Mode &80: steers from `ADVAL(1)` and `ADVAL(2)`. A high byte of &C0 or above, or below &40, moves the pointer |
| `*MOUSE` | &82C4 | Mode 0: quadrature mouse |
| `*TRACKERBALL` | &82C4 | The same code as `*MOUSE` |
| `*POINTER` | &838A | Shows the software pointer in modes 0, 1, 2, 4 and 5. `*POINTER 0` or `*POINTER 2` removes it |
| `*TMAX x,y` | &8BAF | Stores x and y at &9000 and &9002 |
| `*TSET x,y` | &8BEC | Moves the pointer to x, y (&9004 and &9006) |
| `*SETPAL` | &80ED | Sends VDU 19 for logical colours 0 and 1 (from &9036, &9037) |

- A device command with the argument `0` (for example `*MOUSE 0`) turns
  the driver off (&8271): it restores the vectors, stops the poll with
  OSBYTE &17, removes the pointer (&83DA) and clears the on flag &900A.
- Otherwise a device command sets the mode in &9031. If the driver was
  off, it also turns it on (&82D6-&831F): it sets &900A to &FF, clears
  &900B and &9015, starts the poll with OSBYTE &16, sets &9008 to &FF
  (pinout to be detected), sets up the User VIA and the vectors, and
  puts the pointer at 640, 512. If the driver was already on, only the
  mode changes.
- Bad numeric arguments give error &DC, "Bad number".
- Switching devices in Welcome is done as `*DIGITAL 0` then `*MOUSE`, or
  `*MOUSE 0` then `*DIGITAL`.

## ADVAL (OSBYTE &80 through BYTEV)

PMFS claims BYTEV as an extended vector (set up through OSBYTE &A8) and
handles OSBYTE &80 at &8786. Anything else goes to the previous BYTEV,
saved at &0D97.

```
8786  CMP #&80 : BEQ +3 : JMP (&0D97)     ; not OSBYTE &80: pass on
878D  CPX #9   : BEQ mode                 ; ADVAL(9)
8791  BCS pass                            ; X >= 10: pass on
8793  CPX #5   : BCC pass                 ; X <= 4: pass on
8797  PHP : SEI
8799  TXA : ASL A : ADC #&F6 : TAY        ; Y = 2X - 10 (ASL leaves C clear, X < 128)
879E  LDA &9000,Y : TAX                   ; low byte
87A2  INY : LDA &9000,Y : TAY             ; high byte
87A7  PLP : LDA #&80 : CLV : RTS
87AC  mode: LDY #0 : LDX &9031 : RTS
```

| Channel | Returns | Workspace |
|---|---|---|
| `ADVAL(5)` | `*TMAX` x | &9000 |
| `ADVAL(6)` | `*TMAX` y | &9002 |
| `ADVAL(7)` | Pointer X, 0-1276 (&4FC), in graphics units | &9004 |
| `ADVAL(8)` | Pointer Y, 0-1020 (&3FC), in graphics units | &9006 |
| `ADVAL(9)` | **Device mode**, not buttons: 0 mouse or trackerball, &20 keys, &40 digital, &80 joystick (Y=0) | &9031 |

- Channels 0-4 and 10 upwards are passed on, so `ADVAL(0)`-`(4)` remain
  the MOS's.
- When turned on, the pointer starts at 640, 512 (&830B).
- The clamps on X and Y are fixed in the code. Nothing else in the 6 KB
  build reads the `*TMAX` values *(inferred)*, so `*TMAX` only changes
  what `ADVAL(5)` and `(6)` return.
- This `ADVAL(9)` differs from the JGH and AMX convention, where
  `ADVAL(9)` is the button state. Software that tests `ADVAL(9)=0` for
  "mouse present" (as TimPaint does) works with either, as long as no
  button is held.

### The unused routine at &87B2

Directly after the ADVAL handler is a routine that nothing calls (no
`B2 87` address appears anywhere in the image):

```
87B2  PHP : SEI : JSR &8553
87B7  LDX &9008 : BPL known               ; bit 7 set: pinout not yet known
87BC  LDX #0
87BE  LDA &FE60 : AND #&E0 : CMP #&E0     ; PB5-PB7 all high?
87C5  BEQ +5 : LDX #7 : STX &9008
87CC  known: LDA &FE60
87CF  CPX #0 : BEQ +4 : ROL A x4          ; X<>0: move PB5-PB7 to bits 0-2
87D7  AND #7 : EOR #7 : TAX               ; buttons, 1 = pressed
87DC  JSR &8553 : PLP
87E0  LDY #0 : BEQ &87A8                  ; return A=&80, X=buttons, Y=0
```

It returns the three buttons in X with Y=0, in exactly the form of an
OSBYTE &80 result, and it picks between the buttons on PB0-PB2 (Compact
pinout) and PB5-PB7 (AMX pinout). It looks like an `ADVAL(9)`-returns-
buttons handler in the JGH/AMX style, disconnected when `ADVAL(9)` became
the device mode *(inferred)*.

## Buttons

PMFS has no INKEY numbers for the buttons and no OSWORD. When a button
has been held for two 100 Hz polls, it puts a key into the keyboard
buffer with OSBYTE &99 (&89DA-&8A6C):

| Button | Key |
|---|---|
| Left | RETURN (&0D) |
| Right | &C0 |
| Middle | The TAB key's code, read with OSBYTE &DB |

With the Compact pinout the buttons are on PB0-PB2, which the MOS's
digital joystick code also reads. So a mouse button probably also shows
as a bit in `ADVAL(0)` *(inferred)*. Welcome's menu waits for
`GET=13 OR (ADVAL(0) AND 7)<>0`, which accepts either.

## Hooks

**Service calls** (entry &801E):

| Call | Use |
|---|---|
| &04 | Star commands |
| &07 | OSBYTE &A3 with X=&F3 (&8031): sets or steps the pointer and palette colours |
| &15 | 100 Hz poll, turned on with OSBYTE &16 and off with OSBYTE &17. Moves the pointer in joystick, digital and keys modes, debounces the buttons and redraws the pointer |
| &27 | Reset: clears its state with STZ to &900A, &900B, &9015 and &9031 (at &804E in the 8 KB build) |

**Vectors:**
- **BYTEV:** extended vector, through OSBYTE &A8, to &8786. The old BYTEV
  is saved at &0D97.
- **IRQ1V:** a trampoline at &0D99 does `JSR &FF06` (extended vector
  entry 2, which points at &87E4) and then jumps to the old IRQ1V, saved
  at &0D9D.

Turning the driver off (&8271) copies the saved vectors back, with
interrupts disabled, from &0D9D/&0D9E to &0204/&0205 (IRQ1V) and from
&0D97/&0D98 to &020A/&020B (BYTEV).

**Zero page:** saves &84-&90 to &9022 while it works.

## Polling (service call &15, &87FD)

The poll dispatches on the mode in &9031:

| Mode | Code | What it does |
|---|---|---|
| 0 (mouse) | &8889 | No movement to do (the IRQ does it); buttons and redraw |
| &80 (joystick) | &884D | Reads OSBYTE &80 with X=1 and X=2 |
| &40 (digital) | &8816 | Reads `ADVAL(0)` (OSBYTE &80, X=0). Bit 4 or bit 7 runs &8900 or &8929, otherwise &89B0; bit 6 or bit 5 runs &8981 or &8958, otherwise &89B9. These look like left/right/stop X and up/down/stop Y *(inferred)* |
| &20 (keys) | &888C | Cursor keys |

## Hardware

**When turned on** (&82F1-&8308), it sets up the User VIA:
- PCR `AND &0F`: CB1 and CB2 interrupt on falling edges.
- ACR `AND &FC`: port latching off.
- IER = &98: CB1 and CB2 interrupts on.
- DDRB = 0: port B all inputs.

**IRQ handler** (&87E4): if IER AND IFR AND &18 is non-zero (CB2 is bit 3,
CB1 bit 4), it calls &8A6F with the flags in Y, then exits through &81B3.

**Quadrature** (&8A6F): each CB1 interrupt moves X by 4 graphics units
and each CB2 interrupt moves Y by 4, with the direction taken from a port
B bit read at the edge. Only one edge of one phase is counted, so there
is one count per quadrature cycle *(inferred)*.

**Two pinouts,** chosen with an index in &9008 into a table at &8B36,
and detected automatically:

| Pinout | X direction | Y direction | Buttons |
|---|---|---|---|
| AMX (User Port) | PB0 | PB2 | PB5-PB7 |
| Compact (joystick port) | PB3 | PB4 | PB0-PB2 |

Any mouse interrupt while the driver is in another mode switches it to
mouse mode and recentres the pointer (&8A72).

## Workspace (in its own bank)

| Address | Use |
|---|---|
| &9000-&9001 | `*TMAX` x (`ADVAL(5)`) |
| &9002-&9003 | `*TMAX` y (`ADVAL(6)`) |
| &9004-&9005 | Pointer X (`ADVAL(7)`) |
| &9006-&9007 | Pointer Y (`ADVAL(8)`) |
| &9008 | Pinout index; bit 7 set means not yet detected |
| &900A | Driver on flag: &FF on, 0 off |
| &900B | State, cleared when turned on and on reset (purpose not worked out) |
| &9015 | State, cleared when turned on and on reset (purpose not worked out) |
| &9022-&902E | Saved zero page &84-&90 |
| &9031 | Device mode (`ADVAL(9)`) |
| &9036, &9037 | Physical colours for logical colours 0 and 1, sent by `*SETPAL` (set to 6 and 4 at &8124 in the 8 KB build) |

## What MOS 5 does itself

From the MOS 5.00 disassembly
([tom-seddon/acorn_mos_disassembly](https://github.com/tom-seddon/acorn_mos_disassembly)):
- **Joystick port:** the MOS reads only PB0-PB4. `ADVAL(0)` carries the
  fire button and the four directions.
- **Mouse button bits:** bits 1-3 of `ADVAL(0)` are documented as mouse
  buttons, and the switch-to-key table maps them to DELETE, RETURN and
  COPY, but the MOS never sets them. Only a ROM writing the ADVAL
  workspace (&2B6) through service call &2C could fill them. PMFS does
  not.
- **Analogue channels:** OSBYTE &80 with X of 1 or more has no range
  check: odd channels return `ADVAL(1)` and even channels `ADVAL(2)`.
  This is why PMFS has to hook BYTEV to give channels 5-9 their own
  meanings.
- **CB interrupts:** the MOS sets the User VIA IER to &98 (CB1 and CB2)
  at reset, but has no handler for them. All mouse handling is PMFS's.

## How the Welcome software uses it

| Program | Use |
|---|---|
| `WELCOME.Menu` | Reads the pointer with `ADVAL(7)` and `ADVAL(8)` (line 3370, `DEFPROC5`) |
| `WELCOME.Menu` | Shows the pointer with `*POINTER`, hides it with `*POINTER 0`, also uses `*POINTER 2` |
| `WELCOME.Menu` | Switches devices with `*DIGITAL 0` + `*MOUSE`, or `*MOUSE 0` + `*DIGITAL` (lines 2480-2490) |
| `WELCOME.Menu` | Waits for `GET=13 OR (ADVAL(0) AND 7)<>0`; calls OSBYTE &A3,&F3 (line 3450) |
| `WIMPS.P.crnw` | Moves the pointer with `*TSET x,y` |
| TimPaint | `IF ADVAL(9)=0` means mouse; then reads `ADVAL(8)` and `ADVAL(7)` |
| TimPaint | Otherwise uses the joystick: Y from `ADVAL(2) DIV 64`, X reversed as `1276-ADVAL(1)*5 DIV 256` |
| TimPaint | Fire is `ADVAL(0) AND 1`, or SHIFT (`INKEY-2`) without the mouse |

## Compatibility notes for other drivers

A replacement mouse driver that wants Welcome-era software to work should
provide `ADVAL(5)`-`(8)`, `*POINTER`, `*TSET` and `*TMAX`, and the buttons
as keys in the keyboard buffer.

PMFS cannot run alongside hardware that uses the Compact's port B for
anything else: it makes port B all inputs, and it counts every CB1 and
CB2 edge as movement.

## Open questions

- What PMFS stands for, and who PMF and JPG are.
- The exact debounce and redraw timing, and the pointer shapes.
- The purpose of &900A, &900B and &9015.
- How the pinout auto-detection decides. Turning on sets &9008 to &FF;
  the unused routine at &87B2 shows one test (PB5-PB7 all high), but the
  code that sets &9008 in normal use (around the table at &8B36) was not
  traced.
- What the 8 KB build's extra code does (for example the call to &8561
  before reading the ADVAL values).
