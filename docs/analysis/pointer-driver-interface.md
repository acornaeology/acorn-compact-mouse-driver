# The Master Compact pointer driver interface: a specification

> **Scope.** This document defines the programming interface that PMFS, the
> pointer and mouse driver on the Acorn BBC Master Compact Welcome disc,
> presents to software: its star commands, its `ADVAL` channels, its OSBYTE
> call, the keys it generates from buttons, its coordinate system and its
> pointer display. It is written so that a driver for different pointing
> hardware can present the same interface, and software written for the
> Welcome disc will work with it unchanged.
>
> Every statement about PMFS's behaviour here was read from the
> [annotated disassembly](../../versions/pmfs-136/output/pmfs-136.asm) of
> PMFS 136 in this repository. Each is referenced to the routine that
> implements it. Statements about the Welcome software were read from its
> BASIC programs on the same disc. Statements about MOS 5.00 were read from
> [Tom Seddon's annotated MOS disassembly](https://github.com/tom-seddon/acorn_mos_disassembly).
> The reserved area of page &0D is from David Atherton's *Master Operating
> System: A Dabhand Guide* (Dabs Press, 1987), pp79 and 205, in its
> [remade edition](https://github.com/acheton1984/AcornDocsRemade/blob/main/DabsMOS/dabs%20mos%20remade%20draft%201c.pdf).

---

## 1. Conventions

The key words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT** and **MAY** are
used as in RFC 2119. A requirement marked **MUST** is something existing
software depends on. One marked **SHOULD** is PMFS behaviour that software
could reasonably depend on. Behaviour described as *PMFS behaviour* without a
key word is recorded for completeness: a compatible driver may differ.

Section 12 lists behaviour of PMFS that is a defect, which a compatible driver
**SHOULD NOT** reproduce.

Numbers are written in Acorn style: `&` for hexadecimal. "Graphics units" are
the MOS's graphics coordinates, in which the screen is 1280 units wide and
1024 units high in every graphics mode, with (0, 0) at the bottom left.

A driver is **on** when it has claimed its vectors and is moving the pointer,
and **off** otherwise. The pointer is **shown** when the driver draws it on the
screen.

## 2. Overview

The driver maintains a **pointer position** in graphics units. It moves the
position in response to one **input device**, chosen by a star command:

| Device mode | Command | Device |
|-------------|---------|--------|
| 0 | `*MOUSE`, `*TRACKERBALL` | quadrature mouse or trackerball |
| &20 | `*KEYS` | cursor keys |
| &40 | `*DIGITAL` | digital (switched) joystick |
| &80 | `*JOYSTICK` | analogue joystick |

Software reads the position with `ADVAL(7)` and `ADVAL(8)`, and the device
mode with `ADVAL(9)`. It can move the position with `*TSET`. It can ask for a
pointer to be drawn on a graphics screen with `*POINTER`. Buttons are not read
through `ADVAL`; instead, pressing a button puts a character into the keyboard
buffer, as if a key had been typed.

The driver also stores two **desktop colours**, set through OSBYTE &A3 and
sent to the VDU by `*SETPAL`.

## 3. Coordinates

**3.1** The pointer position **MUST** be reported in graphics units, X
increasing to the right and Y increasing upwards.

**3.2** When the driver moves the pointer, X **MUST** stay in the range 0 to
1276 (&4FC) and Y in the range 0 to 1020 (&3FC). (These are the largest
multiples of 4 below 1280 and 1024. PMFS clamps to them in
[`move_pointer_right`](label:move_pointer_right@136), [`move_pointer_up`](label:move_pointer_up@136) and [`mouse_movement`](label:mouse_movement@136).)

**3.3** When the driver is turned on, the pointer **MUST** be placed at
(640, 512), the middle of the screen ([`select_device`](label:select_device@136)). Selecting another
device while the driver is on does not move it.

**3.4** `*TSET` sets the position to the values given, without clamping
([`cmd_tset`](label:cmd_tset@136)). PMFS does not then always bring an out-of-range position back
into range: the joystick and key movements clamp any X of 1280 or more and any
Y of 1024 or more, but a mouse step stops only at positions from the limit
up to 1279 (X) or 1023 (Y), and moves a position beyond those further out. Software **SHOULD** give `*TSET` values within the ranges of 3.2.

## 4. Star commands

### 4.1 Parsing

**4.1.1** Commands **MUST** be recognised whatever their case
([`service_command`](label:service_command@136) compares with bit 5 cleared).

**4.1.2** A command **MAY** be abbreviated with a full stop after one or more
of its letters. Abbreviations **MUST** resolve in this order of commands:
`KEYS`, `DIGITAL`, `JOYSTICK`, `MOUSE`, `POINTER`, `TMAX`, `TRACKERBALL`,
`TSET`, `SETPAL` (the order of [`command_table`](label:command_table@136)). So `*T.` is `*TMAX` and
`*M.` is `*MOUSE`.

**4.1.3** A complete command name **MUST** be followed by a space or the end of
the line to be recognised. PMFS leaves a name followed by anything else
(`*MOUSE0`, say) for other ROMs.

**4.1.4** Arguments follow the name after any spaces and commas. Numbers are
decimal, 0 to 65535, separated by spaces or commas ([`parse_number`](label:parse_number@136)).

**4.1.5** A missing number, a number above 65535, or any character other than a
digit, space, comma or CR in a number **MUST** raise error &DC,
`Bad number` ([`bad_number_error`](label:bad_number_error@136)).

**4.1.6** PMFS runs every command with interrupts disabled. It claims the
service call for every command it recognises.

### 4.2 Device commands: `*MOUSE`, `*TRACKERBALL`, `*JOYSTICK`, `*DIGITAL`, `*KEYS`

```
*MOUSE [0]
*TRACKERBALL [0]
*JOYSTICK [0]
*DIGITAL [0]
*KEYS [0]
```

**4.2.1** If the argument begins with the character `0`, the command **MUST**
turn the driver off, whichever device it names ([`turn_driver_off`](label:turn_driver_off@136)). Turning
off **MUST** remove the pointer if it is shown, stop all movement and button
handling, and restore the vectors the driver claimed. It does not change the
device mode. Turning off a driver that is already off does nothing.

**4.2.2** Otherwise the command **MUST** select the device mode in the table in
section 2 (`*MOUSE` and `*TRACKERBALL` are the same), and reset the joystick
and key acceleration (section 7.3).

**4.2.3** If the driver is off, the command **MUST** then turn it on: claim the
vectors and polling it needs, put the pointer in the middle of the screen
(3.3), and start reporting the position. Turning on does not show the pointer;
that needs `*POINTER`.

**4.2.4** If the driver is already on, the command changes only the device
mode.

*PMFS behaviour.* PMFS enables the mouse interrupts when it is turned on in
mouse mode, or when `*POINTER` shows the pointer in mouse mode, and disables
them otherwise. Changing from another mode to `*MOUSE` while the driver is on
therefore leaves the mouse disabled until `*POINTER` is next used to show the
pointer. The Welcome software switches device by turning the driver off and
on again, which avoids this:

```
OSCLI "DIGITAL 0" : OSCLI "MOUSE"
OSCLI "MOUSE 0" : OSCLI "DIGITAL"
```

A compatible driver **SHOULD** support that sequence, and **MAY** also allow a
direct change of device while on.

**4.2.5** `*KEYS` also issues `*FX4,2` (the cursor keys act as function keys)
and `*FX226,0` (SHIFT with a function key is ignored), so that the cursor keys
steer the pointer and do not edit ([`cmd_keys`](label:cmd_keys@136)). It does so each time it is
used, even when turning the driver off. Neither setting is restored by
another device command, or when the driver is turned off. A compatible driver
**SHOULD** do the same, because software may rely on the cursor keys being
quiet in keys mode.

### 4.3 `*POINTER`

```
*POINTER        show the pointer
*POINTER 0      remove the pointer
*POINTER 2      remove the pointer and disable the mouse
```

**4.3.1** `*POINTER` with no argument, or with an argument beginning with any
character other than `0` or `2`, **MUST** show the pointer, if the driver is on
and the pointer is not already shown ([`cmd_pointer`](label:cmd_pointer@136)).

**4.3.2** `*POINTER 0` **MUST** remove the pointer from the screen, restoring
what was under it ([`remove_pointer`](label:remove_pointer@136)). The driver stays on and keeps moving the
position.

**4.3.3** `*POINTER 2` **MUST** do the same as `*POINTER 0`. PMFS also disables
the mouse interrupts ([`remove_pointer_and_mouse`](label:remove_pointer_and_mouse@136)), so mouse movement stops
until the pointer is next shown or the driver is next turned on. The Welcome
programs use `*POINTER 2` before running other programs.

**4.3.4** The pointer is drawn only in MODEs 0, 1, 2, 4 and 5, and their shadow
equivalents. In MODEs 3, 6 and 7, PMFS ignores `*POINTER` entirely, including
`*POINTER 0`.

**4.3.5** The pointer is drawn for the screen mode in force when `*POINTER`
shows it. Software **MUST** remove the pointer before changing mode or clearing
the screen, and show it again afterwards. While the pointer is shown, the
driver owns the screen bytes under it: software that draws there **SHOULD**
remove the pointer first.

**4.3.6** The usual pattern in the Welcome software is to show the pointer
while waiting for input, and remove it before acting:

```
*POINTER
REPEAT : key% = INKEY(0) : x% = ADVAL(7) : y% = ADVAL(8) : UNTIL key% > -1
*POINTER 0
```

### 4.4 `*TSET`

```
*TSET x,y
```

**4.4.1** `*TSET` **MUST** set the pointer position to (x, y)
([`cmd_tset`](label:cmd_tset@136)). Both numbers are required. The pointer, if shown, is moved at the
next redraw (section 8.4).

**4.4.2** It works whether or not the driver is on.

### 4.5 `*TMAX`

```
*TMAX x,y
```

**4.5.1** `*TMAX` **MUST** record x and y, and `ADVAL(5)` and `ADVAL(6)` **MUST**
then return them ([`cmd_tmax`](label:cmd_tmax@136)). Both numbers are required.

**4.5.2** In PMFS the values have no other effect; in particular they do not
limit the pointer's movement.

### 4.6 `*SETPAL`

```
*SETPAL
```

**4.6.1** `*SETPAL` **MUST** send `VDU 19,0,c0,0,0,0` and `VDU 19,1,c1,0,0,0`,
where c0 and c1 are the two desktop colours (section 6), setting logical
colours 0 and 1 ([`cmd_setpal`](label:cmd_setpal@136)). It takes no arguments and works whether or
not the driver is on.

## 5. ADVAL channels

The driver extends OSBYTE &80 (`ADVAL`) with channels 5 to 9
([`bytev_handler`](label:bytev_handler@136)). PMFS does this through BYTEV, only while the driver is on.

| Channel | Returns |
|---------|---------|
| `ADVAL(5)` | x from the last `*TMAX` |
| `ADVAL(6)` | y from the last `*TMAX` |
| `ADVAL(7)` | pointer X, 0-1276 |
| `ADVAL(8)` | pointer Y, 0-1020 |
| `ADVAL(9)` | device mode: 0 mouse, &20 keys, &40 digital joystick, &80 analogue joystick |

**5.1** For channels 5 to 9, OSBYTE &80 **MUST** return the value with its low
byte in X and its high byte in Y, as the MOS does for the other channels. PMFS
returns A=&80.

**5.2** `ADVAL(9)` **MUST** return the device mode, not the state of the buttons.
Software on the Welcome disc (TimPaint) tests `ADVAL(9)=0` to decide whether
a mouse is in use. Some other mouse drivers for the BBC Micro return the
buttons in `ADVAL(9)`; a driver following them will not work with this
software while a button is held.

**5.3** Channels 0 to 4, and 10 upwards, **MUST** be left to the MOS. On MOS 5,
OSBYTE &80 does not range-check the channel and returns the analogue
readings for any channel above 0, which is why a driver must intercept
channels 5 to 9.

**5.4** The values **MUST** be consistent: a read must never see the low byte of
one position and the high byte of another. PMFS reads them with interrupts
disabled.

**5.5** The position is in graphics units whichever device is in use, and
`ADVAL(7)` and `ADVAL(8)` are what software uses to read it. Software
**SHOULD NOT** need to know the device.

## 6. OSBYTE &A3,&F3: desktop colours

```
A=&A3, X=&F3, Y=parameter
```

The driver stores two physical colours for logical colours 0 and 1, the
**desktop colours** ([`set_desktop_colours`](label:set_desktop_colours@136)). The call claims the OSBYTE (it
is handled on service call 7) and returns X and Y unchanged.

| Y | Effect |
|---|--------|
| bit 7 set | reset to the defaults: colour 0 = 6 (cyan), colour 1 = 4 (blue) |
| bit 7 clear, bit 6 set | step colour (Y bit 3) to the next physical colour, 0-7, wrapping, skipping the other desktop colour's value |
| bits 7 and 6 clear | set colour (Y bit 3) to physical colour Y AND 7 |

**6.1** The call **MUST** only store the colours; `*SETPAL` applies them
(section 4.6).

**6.2** The call **MUST** work whether or not the driver is on.

The Welcome disc uses it as follows:

```
*FX163,243,128                                        : REM defaults
A%=163 : X%=243 : Y%=((n% AND 1)*8) OR &40 : CALL &FFF4 : REM step colour n%
*SETPAL
```

Before the first call, the desktop colours are both 0. (They are in RAM in
PMFS's bank, which the ROM image initialises to zero.)

## 7. Movement

### 7.1 Mouse and trackerball

**7.1.1** Each step of the mouse **MUST** move the pointer 4 graphics units in
the direction of movement, clamped as in 3.2. PMFS counts one step per
quadrature cycle on each axis ([`mouse_movement`](label:mouse_movement@136)).

**7.1.2** The mouse moves the pointer as it moves, whether or not the pointer is
shown.

### 7.2 Joysticks and keys

Every centisecond the driver reads the device and moves the pointer
([`poll_move_pointer`](label:poll_move_pointer@136)):

| Device | Left | Right | Down | Up |
|--------|------|-------|------|----|
| Analogue joystick | `ADVAL(1)` high byte &C0 or more | below &40 | `ADVAL(2)` high byte below &40 | &C0 or more |
| Digital joystick | `ADVAL(0)` bit 4 | bit 7 | bit 5 | bit 6 |
| Keys | cursor left (`INKEY-26`) | cursor right (`INKEY-122`) | cursor down (`INKEY-42`) | cursor up (`INKEY-58`) |

These are MOS 5's meanings of `ADVAL(0)`'s bits for the Compact's digital
joystick port, and the BBC Micro's analogue joystick convention, in which
high readings are left and up.

### 7.3 Acceleration

**7.3.1** For joysticks and keys, each axis has a speed in 1/256 graphics
units, reset to &0080 when the axis stops moving and when a device is
selected ([`reset_x_speed`](label:reset_x_speed@136)). While the axis moves, each centisecond moves the
pointer by the whole part of the speed and then adds &0010 to it
([`move_pointer_left`](label:move_pointer_left@136) and the others).

So the pointer first moves after 8 centiseconds, and then moves one unit
further each step for every 16 centiseconds held: after half a second it
moves 3 units a centisecond, and after a second 6.

**7.3.2** With the cursor keys, holding SHIFT adds a further &0040 to both
speeds every centisecond, so the pointer accelerates five times as fast
([`poll_keys`](label:poll_keys@136)).

A compatible driver **SHOULD** give similar acceleration, so that software
tuned for PMFS's feel remains usable. Exact figures are not required.

## 8. The pointer on the screen

### 8.1 Shape and hot spot

**8.1.1** The pointer is an arrow 16 pixel rows high, outlined in logical colour
0 and filled with logical colour 1, with its tip at the top left. In MODE 0
(`#` is colour 1, `.` is colour 0, blank is transparent):

```
....
..##..
..####..
..######..
..########..
..##########..
..############..
..########....
..##..####..
........####..
      ..####..
        ..####..
        ..####..
          ..####..
          ..####..
            ....
```

**8.1.2** The pointer position is the **hot spot**, 4 graphics units right of
and 4 below the top left corner of the image, at the tip of the arrow
([`hotspot_x`](label:hotspot_x@136), [`hotspot_y`](label:hotspot_y@136)). Software **MUST** be able to assume that the tip
of the arrow is at (`ADVAL(7)`, `ADVAL(8)`).

**8.1.3** The image is 4 screen bytes wide: 32 pixels in MODEs 0 and 4, 16 in
MODEs 1 and 5, and 8 in MODE 2. Each mode has its own image
([`pointer_images`](label:pointer_images@136)) and mask ([`pointer_masks`](label:pointer_masks@136)). The pointer moves in
quarter-byte steps: PMFS keeps four copies of the image, each shifted a
quarter of a byte further right ([`build_pointer_images`](label:build_pointer_images@136)).

### 8.2 Drawing

**8.2.1** The pointer **MUST** be drawn so that removing it restores the screen
exactly. PMFS saves the 64 screen bytes under the image, ANDs each with the
mask and ORs in the image ([`update_pointer`](label:update_pointer@136)), and puts the saved bytes back
to remove it ([`restore_screen_under_pointer`](label:restore_screen_under_pointer@136)).

**8.2.2** The pointer **MUST** be clipped at the edges of the screen; it can
reach to the screen's right and top edges.

**8.2.3** In shadow screen modes the pointer **MUST** be drawn in the screen
memory that is displayed. PMFS sets ACCCON bit X to match bit E while it
draws, so it writes to the same RAM as the VDU drivers.

**8.2.4** PMFS computes screen addresses from fixed tables, assuming the screen
starts at &3000 (MODEs 0-2) or &5800 (MODEs 4 and 5) and has not been
scrolled by hardware. Software that uses the pointer **SHOULD NOT** scroll the
screen while it is shown.

### 8.3 Colours

The image uses logical colours 0 and 1, which are also the colours that
`*SETPAL` sets. In four- and sixteen-colour modes the pointer is still drawn
in colours 0 and 1.

### 8.4 Redrawing

**8.4.1** PMFS redraws the pointer when it has moved, at most once every 11
centiseconds when only the joystick or keys move it, and sooner when the mouse
is moving: each mouse step also counts down to the next redraw
([`poll_redraw_and_buttons`](label:poll_redraw_and_buttons@136), [`mouse_movement`](label:mouse_movement@136)). The pointer therefore lags the
position reported by `ADVAL(7)` and `ADVAL(8)` slightly. A compatible driver
**MAY** redraw more often.

**8.4.2** Redrawing happens in the polling service call, so it does not happen
while polling is stopped (section 10.3).

## 9. Buttons

**9.1** Buttons **MUST** be reported by inserting a character into the keyboard
buffer with OSBYTE &99, as if it were typed ([`scan_buttons`](label:scan_buttons@136)):

| Device | Button | Character |
|--------|--------|-----------|
| Mouse | left | RETURN (&0D) |
| Mouse | right | &C0 |
| Mouse | middle | the TAB key's code (read with OSBYTE &DB; 9 by default) |
| Joysticks | fire button 1 (`ADVAL(0)` bit 0) | RETURN (&0D) |
| Joysticks | fire button 2 (`ADVAL(0)` bit 1) | the TAB key's code |
| Keys | none | |

**9.2** A character **MUST** be sent when a button is pressed, not while it is
held: one character per press, without auto-repeat. PMFS sends one character
when a changed button state has been seen at two successive centisecond
polls. If more than one button is pressed in the new state, PMFS sends only
the first in the order RETURN, &C0, TAB. Releasing a button sends nothing.

**9.3** The left button **MUST** send RETURN, because the Welcome software uses
RETURN as "select" (`GET=13`, `INKEY` returning 13).

**9.4** On the Master Compact, the joystick port's fire line (PB0) is also the
left mouse button's line in the Compact mouse wiring (section 11.2). The MOS
reads PB0 into `ADVAL(0)` bit 0 independently of the driver, so software also
sees the left button as the fire button. The Welcome software accepts either:

```
REPEAT UNTIL GET=13 OR ((ADVAL(0) AND 7)<>0)
```

A compatible driver for other hardware **SHOULD** make the left button
visible in `ADVAL(0)` too, as described in section 13.3.

**9.5** On MOS 5, `ADVAL(0)` bit 1 is never set by the MOS itself (it is one of
the mouse-button bits a ROM can supply through service call &2C). So on the
Compact, joystick fire button 2 is only reported if something supplies it.

## 10. System interface

This section describes how PMFS fits into the MOS. It is the part a
compatible driver is most free to do differently, but the resources PMFS uses
are listed so that other software can avoid them.

### 10.1 Form

PMFS is a 65C02 sideways ROM image, with a service entry and no language
entry (ROM type &82). The Welcome disc's `$.Loader` puts it in sideways RAM
bank 5 and makes the MOS call it without a BREAK:

```
*SRLOAD PMFS 8000 5 Q
?&2A6=&82 : REM ROM type table entry for bank 5
*DIGITAL
```

The second line enters bank 5 in the MOS's ROM type table, which the MOS
otherwise does only after a BREAK. MOS 5 can do this itself. A Master
Compact application note, quoted in the MOS disassembly, says: "A facility
to load an SRAM image and update the MOS ROM type table has been added. An
"I" should be added to the *SRLOAD command." MOS 5 accepts the `I` before
the `Q` (`*SRLOAD PMFS 8000 5 I Q`). The Welcome disc's loader does not use
it.

PMFS keeps its workspace in RAM in its own bank, at &9000-&946F, so it **only
works from sideways RAM**. It writes &91 to its entry in the MOS's private
workspace table (&0DF0+ROM number) on every service call.

### 10.2 Service calls

| Call | PMFS's use |
|------|-----------|
| &04 | Star commands (section 4) |
| &07 | OSBYTE &A3,&F3 (section 6) |
| &15 | Polling: movement by joystick and keys, redrawing, buttons |
| &27 | Reset (but see section 12) |

### 10.3 Polling

**10.3.1** Turning the driver on increments the MOS's ROM polling semaphore
(OSBYTE &16), so that the MOS issues service call &15 every centisecond;
turning it off decrements it (OSBYTE &17).

**10.3.2** The Welcome software also controls polling directly. `$.Loader` turns
the driver on and then issues `*FX23` ("halt the interrupt polling"), and
other programs issue `*FX22`. While polling is stopped, a PMFS mouse still
moves the position (it uses interrupts), but joysticks and keys do not, the
pointer is not redrawn, and no buttons are reported.

A compatible driver **SHOULD** use the polling semaphore in the same way,
counting on and off with OSBYTE &16 and &17, so that this use keeps working.

### 10.4 Vectors

**10.4.1** BYTEV: PMFS points BYTEV at the extended vector entry for BYTEV
(&FF0F) and puts its handler in that entry of the extended vector table
(found with OSBYTE &A8). The old BYTEV is kept at &0D97 and restored when
the driver is turned off.

**10.4.2** IRQ1V: PMFS builds a six-byte routine at &0D99,
`JSR &FF06 : JMP old_irq1v`, and points IRQ1V at it. &FF06 is the extended
vector entry for IRQ1V, whose table entry PMFS sets to its own interrupt
handler. The old IRQ1V is kept at &0D9D and restored when the driver is
turned off; the extended vector table entries are left as they are.

**10.4.3** The mouse interrupt is never claimed: after PMFS's handler, the
previous IRQ1V handler runs.

### 10.5 Memory

| Address | Use |
|---------|-----|
| &84-&90 | Used while the driver runs, saved and restored (but see section 12) |
| &A8-&AB | Used while a command runs |
| &0D97-&0D9E | Saved vectors and the IRQ1V routine |
| &9000-&946F in PMFS's bank | Workspace, pointer images, screen under the pointer |

**10.5.1** Zero page &84-&8F is part of the current language's workspace
(&00-&8F). BASIC leaves &70-&8F to the user, but another language may use
it. PMFS copies &84-&90 into its own workspace when it is entered and copies
them back when it leaves, so the language's values survive a call to PMFS,
except for &90 (section 12, defect 2).

**10.5.2** &0D97-&0D9E lies within &0D92-&0D9E, which *Master Operating
System: A Dabhand Guide* lists as "Reserved for use by Trackerball / input
device" on all machines (p205), adding that "if writing code for a mouse it
is also permissible to use the trackerball reserved space in page &D" (p79).
PMFS keeps its saved vectors and its IRQ1V routine there.

### 10.6 Hardware

In mouse mode PMFS sets up the User VIA when the driver is turned on: CB1
and CB2 interrupt on a falling edge, port latching off, CB1 and CB2
interrupts enabled, and port B all inputs ([`select_device`](label:select_device@136)). It reads port
B. It does not restore the VIA when turned off, beyond disabling the CB1 and
CB2 interrupts. Hardware that uses the User VIA's port B or CB lines for
anything else cannot be used at the same time.

## 11. Mouse hardware (informative)

This section describes the hardware PMFS drives. It does not constrain a
compatible driver for other hardware, but defines what "a mouse" means to
the interface.

### 11.1 Quadrature

Each axis has two signals in quadrature. One of them interrupts on CB1 (X)
or CB2 (Y), on a falling edge; the other is read from a port B line at the
interrupt to give the direction: high is right or up, low is left or down.

### 11.2 Two wirings

| | Compact joystick port | User Port (AMX style) |
|---|---|---|
| X direction | PB3 | PB0 |
| Y direction | PB4 | PB2 |
| X interrupt | CB1 | CB1 |
| Y interrupt | CB2 | CB2 |
| Left button | PB0 | PB5 |
| Middle button | PB1 | PB6 |
| Right button | PB2 | PB7 |

Buttons read low when pressed. The table is [`pinout_table`](label:pinout_table@136).

PMFS detects the wiring once after being turned on: the first button reading
with any of PB5-PB7 low selects the User Port wiring, and the first mouse
interrupt with either of PB3 and PB4 low selects the Compact wiring
([`scan_buttons`](label:scan_buttons@136), [`mouse_movement`](label:mouse_movement@136)).

On the Compact joystick port, MOS 5 reads PB0-PB4 as fire, left, down, up and
right. With the Compact wiring, the mouse's left button is therefore the
joystick's fire button.

## 12. PMFS defects

These are places where PMFS 136's code does not do what it evidently
intends, or has side effects. A compatible driver **SHOULD NOT** reproduce
them, and software **SHOULD NOT** depend on them.

1. **Reset does not reset.** On service call &27 PMFS clears its "on",
   "pointer shown" and "button pending" flags at &900A, &900B and &9015 with
   direct stores. But PMFS keeps its state at &9440 between calls and
   exchanges it into &9000 only while it runs ([`exchange_workspace`](label:exchange_workspace@136)), so the
   stores reach the wrong copy ([`reset_driver_state`](label:reset_driver_state@136)). The device mode, at
   &9031, is outside the exchanged area and is reset. After a reset the MOS
   has restored BYTEV and IRQ1V, but PMFS's live state still says the
   driver is on.
2. **Zero page &90 is overwritten.** PMFS saves ACCCON at &902E while drawing,
   which is also where it saved the caller's zero page &90. On exit it
   "restores" &90 with ACCCON's value ([`leave_driver`](label:leave_driver@136)). This happens whenever
   the pointer is drawn or removed.
3. **Command arguments on the next page.** When moving past the command name,
   a carry increments the pointer's low byte instead of its high byte
   ([`advance_to_arguments`](label:advance_to_arguments@136)), so arguments that start on the page after the
   command name are read from the wrong place.
4. **Changing to the mouse while on.** As described in 4.2.4, the mouse
   interrupts are only enabled when the driver is turned on in mouse mode or
   the pointer is shown in mouse mode.
5. **All buttons at once.** A button reading of 0 (all three mouse buttons,
   or both fire buttons, pressed) is confused with "no change pending", so
   while it lasts the character for the previous reading is sent again every
   centisecond ([`scan_buttons`](label:scan_buttons@136)).
6. **`*TSET` is not clamped**, and the drawing routines handle positions
   above the top of the screen only approximately; the restore routine does
   not skip rows there ([`restore_screen_under_pointer`](label:restore_screen_under_pointer@136)). Within the clamped
   range this makes no difference.
7. **`*POINTER 0` in a text mode** is ignored, so a pointer shown in a graphics
   mode cannot be removed after a mode change to MODE 3, 6 or 7 except by
   changing back.

## 13. Guidance for compatible drivers

### 13.1 Minimum interface

A driver is compatible with the Welcome-era software if it provides:

- the star commands `*MOUSE`, `*TRACKERBALL`, `*JOYSTICK`, `*DIGITAL` and
  `*KEYS`, with the argument `0` turning the driver off (4.2), `*POINTER`,
  `*POINTER 0` and `*POINTER 2` (4.3), `*TSET` (4.4), `*TMAX` (4.5) and
  `*SETPAL` (4.6);
- `ADVAL(7)` and `ADVAL(8)` as the pointer position in graphics units, and
  `ADVAL(9)` as the device mode, 0 for a mouse (5);
- OSBYTE &A3,&F3 for the desktop colours (6);
- RETURN in the keyboard buffer for a press of the left button (9);
- a pointer whose hot spot is the reported position (8.1.2);
- tolerance of `*FX22` and `*FX23` used by applications (10.3.2).

### 13.2 Hardware independence

Everything in sections 3 to 9 is independent of how the mouse is connected.
A driver for different hardware needs to replace only the input side: where
PMFS takes CB1 and CB2 interrupts and reads port B (section 11), it can read
its own hardware, from an interrupt or from the centisecond poll, and add
the movement to the position in graphics units, clamped as in 3.2. Moving
4 graphics units per mouse step matches PMFS's feel in MODE 0 (2 pixels).

### 13.3 Buttons in `ADVAL(0)`

MOS 5 reserves `ADVAL(0)` bits 1-3 for mouse buttons (left, middle and right)
and offers ROMs a way to supply them: when bit 7 of its ADC conversion type
is set, it issues service call &2C each centisecond, with Y the offset in
page 2 of the `ADVAL(0)` low byte, so a ROM can set those bits. PMFS does not
do this. A driver that does would let software test `(ADVAL(0) AND 7)<>0` for
any button, as the Welcome software does, on hardware where the left button
is not wired to the fire line.

### 13.4 Memory

A compatible driver **SHOULD** keep its page &0D variables within &0D92-&0D9E,
the area reserved for an input device driver (10.5.2), and **SHOULD NOT** use
the language's zero page (&00-&8F) except as PMFS does, saving and restoring
it around each entry. Zero page outside &00-&8F belongs to the MOS and
filing systems.

### 13.5 Running from ROM

PMFS's workspace is in its own bank, which ties it to sideways RAM. A driver
that claims private workspace through the normal service calls could also
run from ROM.

## 14. Open questions

- What PMFS stands for, and who "JPG" (the other initials in the ROM) is.
  "PMF" has been identified as Paul Fellows.
- The intended use of `*TMAX`, whose values nothing in PMFS reads.
- The intended use of the &C0 character sent for the right mouse button: no
  BASIC program on the Welcome disc tests for it.
- Why PMFS keeps its state at &9440 and exchanges it into &9000 while it
  runs, instead of using &9000 directly.
- How PMFS's behaviour differs in the 6 KB build on later Compact Welcome
  discs and on the Econet Level 4 File Server supplementary discs
  (`$.Comp_Wel.WIMPS.R.PMFS`, MD5 `8826f28b3575e9481944528ebf09893c`).
