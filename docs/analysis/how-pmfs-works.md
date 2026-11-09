# How PMFS works

> **Scope.** This article explains the internal design of PMFS 136, the
> Master Compact Welcome disc's pointer and mouse driver: how it attaches
> itself to the MOS, where it keeps its state, how it reads the mouse, and
> how it draws the pointer. The interface it presents to software is
> specified separately in [The Master Compact pointer driver
> interface](pointer-driver-interface.md). Routine and label names refer to
> the [annotated disassembly](../../versions/pmfs-136/output/pmfs-136.asm),
> which reassembles byte-for-byte to the file `$.WIMPS.R.PMFS` on the disc.

---

## 1. A sideways ROM in sideways RAM

PMFS is an 8 KB sideways ROM image (&8000-&9FFF) with a service entry only.
Its code and data end at &8F99; the rest of the image is zero. The Welcome
disc's `$.Loader` loads it into sideways RAM bank 5 with `*SRLOAD`, marks
bank 5 in the MOS's ROM type table so that the MOS calls it at once, and
turns it on with `*DIGITAL`.

The zero-filled top of the image matters: PMFS uses it as RAM. Its variables
are at &9000-&9037, and the pages above hold the pointer images and the
screen bytes under the pointer. These addresses are only RAM, and only
visible, while PMFS's own bank is paged in, which is whenever the MOS calls
it. This is why PMFS must run from sideways RAM, and why every one of its
entry points is a call the MOS makes with the bank paged in: service calls,
and extended vectors.

On every service call PMFS writes &91 into its entry in the MOS's private
workspace table at &0DF0, and then finds its pages from that entry: page +1
(&9200) for the pointer images, +2 (&9300) for the masks and +3 (&9400) for
the saved screen bytes and the stored workspace.

## 2. Getting control

PMFS gets control in four ways.

**Service calls** (`service_handler`). Call &04 runs its star commands; call
&07 handles OSBYTE &A3,&F3 (the desktop colours); call &15, the MOS's
centisecond polling call, moves and redraws the pointer and reads the
buttons; call &27, issued after a reset, clears some of its state.

**The polling semaphore.** The MOS only issues call &15 while its ROM polling
semaphore is non-zero. Turning the driver on increments it (OSBYTE &16), and
turning it off decrements it (OSBYTE &17).

**BYTEV, through an extended vector** (`select_device`). To answer
`ADVAL(5)`-`ADVAL(9)` PMFS must see OSBYTE &80 before the MOS does. A
sideways ROM cannot simply point a vector at itself, because the vector may
be called when another ROM is paged in. The Master's extended vectors solve
this: BYTEV is pointed at &FF0F, the MOS's extended vector entry for BYTEV,
and entry 5 of the extended vector table (found with OSBYTE &A8) is set to
PMFS's handler and ROM number. The MOS then pages PMFS in to run
`bytev_handler`, which answers channels 5-9 and passes everything else to the
previous BYTEV.

**IRQ1V, through an extended vector and a trampoline.** The mouse interrupts
on the User VIA's CB1 and CB2. PMFS wants to see every interrupt and then let
the MOS handle it as usual. If IRQ1V pointed straight at the extended vector
entry, PMFS's handler would have to jump on to the old IRQ1V handler itself,
with its own ROM still paged in. Instead PMFS builds a six-byte routine in
page &0D, `irq1v_trampoline`:

```
&0D99  JSR &FF06        ; extended vector entry 2 (IRQ1V's)
&0D9C  JMP old_irq1v    ; the operand is saved_irq1v
```

It points IRQ1V at the trampoline, and sets entry 2 of the extended vector
table to `irq_handler` in PMFS. Every interrupt now pages PMFS in and calls
`irq_handler`; when it returns, the MOS pages the previous ROM back in, and
the trampoline continues to the old handler.

In the setup code one register load serves twice for each vector: the low
byte of an extended vector entry point (&0F for BYTEV, &06 for IRQ1V) is
also the offset of that vector's entry in the table, both being three times
the vector number.

## 3. The workspace exchange

PMFS's state lives in two copies. While PMFS runs, its variables are at
&9000-&902F, where its code addresses them directly. Between calls they are
stored at &9440-&946F. `exchange_workspace` swaps the 48 bytes, and every way
into the driver calls it on the way in and again on the way out:

| Entry | Exchange |
|-------|----------|
| Star commands, polls | `enter_driver` and `leave_driver`, which also save and restore zero page &84-&90 |
| `bytev_handler` (ADVAL 5-8) | `exchange_workspace` around the read |
| `irq_handler` | `exchange_position_workspace`: the first 10 bytes only |

All of these run with interrupts disabled, so the two copies cannot be
caught half-exchanged. The bytes at &9030-&9037 (the device mode, the
joystick speeds and the desktop colours) are not exchanged and are always
used in place.

The code does not say why the state is kept this way. One consequence is a
defect: the reset service call clears three flags in the &9000 copy without
exchanging first, so the stored state, which is what the next call uses, is
not reset (`reset_driver_state`).

## 4. Reading the mouse

A quadrature mouse produces two square waves per axis, a quarter of a cycle
apart. PMFS connects one of each pair to an interrupt line (CB1 for X, CB2 for
Y, interrupting on a falling edge) and reads the other from a port B line
when the interrupt arrives: high means right or up, low means left or down
(`mouse_movement`). Each interrupt moves the pointer 4 graphics units.
Reading port B also clears the interrupt flags.

There are two wirings, recorded in `pinout_table`: the Compact's joystick
port (directions on PB3 and PB4, buttons on PB0-PB2), and a User Port
wiring like the AMX mouse's (directions on PB0 and PB2, buttons on
PB5-PB7). PMFS works out which from the hardware: a button press on PB5-PB7
means the User Port wiring, and a movement interrupt with PB3 or PB4 low
means the Compact wiring. Until one is seen, each reading guesses.

The mouse interrupts are only enabled in mouse mode. In the other modes the
pointer is moved by the poll instead (`poll_move_pointer`), from the
analogue joystick (`ADVAL(1)` and `ADVAL(2)`), the digital joystick
(`ADVAL(0)`'s direction bits, which MOS 5 reads from the Compact's joystick
port) or the cursor keys, with acceleration.

## 5. Buttons as keys

PMFS has no `ADVAL` channel for the buttons. Instead, `scan_buttons`, in the
poll, reads them every centisecond and, when a new state has been seen
twice running, puts a key in the keyboard buffer with OSBYTE &99: RETURN for
the left button, &C0 for the right, and the TAB key's code for the middle.
The Welcome programs simply wait for RETURN.

## 6. Drawing the pointer

The pointer is drawn in software on the bitmap screen (`update_pointer`).

**Images.** The ROM holds one 64-byte image and one 64-byte mask for each of
MODEs 0, 1, 2, 4 and 5 (`pointer_images`, `pointer_masks`), each 4 screen
bytes wide and 16 pixel rows high. A screen byte holds several pixels, so to
place the pointer at any pixel PMFS would need a shifted copy for each pixel
position in a byte. It compromises on four: when `*POINTER` shows the
pointer, `build_pointer_images` copies the current mode's image and mask into
the bank and makes three more copies of each, shifted right by a quarter, a
half and three quarters of a byte. The shifting differs by mode, because the
pixels' bits are interleaved differently in 2-, 4- and 16-colour modes
(`shift_2colour_pixel`, `shift_4colour_copy`, `shift_16colour_copy`). So
the pointer moves in steps of 2 pixels in MODEs 0 and 4, 1 pixel in MODEs 1
and 5, and 1 pixel every other step in MODE 2.

**Addresses.** `calc_pointer_screen_address` converts the top left corner of
the image, in graphics units, into a screen address, using tables of
character row addresses (`mode012_row_addr_lo` and the others) and the
character cell layout of the Acorn screen, and picks the shifted copy.

**Drawing and removing.** For each of the 64 bytes, the screen byte is saved
in a buffer, ANDed with the mask and ORed with the image. Removing the
pointer writes the saved bytes back (`restore_screen_under_pointer`). Bytes
off the screen are skipped. In shadow modes, ACCCON's X bit is set to match
its E bit while drawing, so that PMFS writes to the screen the VDU drivers
are using.

**When.** The poll counts down from 10 and redraws when the count runs out,
if the pointer has moved; mouse interrupts count it down too, so a moving
mouse is redrawn more often.

## 7. Things to watch out for

The [interface specification](pointer-driver-interface.md#12-pmfs-defects)
lists PMFS's defects. Two have effects outside the driver: drawing or
removing the pointer leaves ACCCON's value in zero page &90, because the byte
used to save ACCCON is also the one used to save &90 (`saved_acccon`); and
the reset service call does not reset the driver's stored state.

The disassembly also contains a routine that nothing calls,
`read_mouse_buttons`, which returns the mouse buttons in the form of an
OSBYTE &80 result. It is the button-reading `ADVAL(9)` that some other mouse
drivers provide; PMFS's `ADVAL(9)` returns the device mode instead.
