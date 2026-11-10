# Glossary

Terms used in the PMFS disassembly and its articles: the Master Compact and MOS 5 facilities PMFS relies on, and PMFS's own concepts.

## Machine and MOS

**Master Compact**
: Acorn's BBC Master Compact (1986), a cost-reduced member of the Master series with a 65C02, MOS 5, a built-in 3.5-inch disc drive, and a 9-way joystick port wired to the User VIA's port B and CB lines. It has no MOS mouse support of its own; PMFS provides it.

**MOS 5**
: The Master Compact's operating system. Its OSBYTE &80 reads the Compact's digital joystick port into `ADVAL(0)` and emulates analogue readings from it.

**Sideways ROM, sideways RAM**
: The 16 KB banks paged in at &8000-&BFFF, one at a time. PMFS is a ROM image loaded into a RAM bank with `*SRLOAD`, and uses the upper part of its own bank as workspace.

**Service call**
: A call the MOS makes to each sideways ROM in turn through its service entry, with a reason code in A. PMFS handles &04 (unrecognised star command), &07 (unrecognised OSBYTE), &15 (polling) and &27 (reset).

**Polling interrupt (service call &15)**
: Issued by the MOS every centisecond, from its timer interrupt, while the ROM polling semaphore is non-zero. OSBYTE &16 increments the semaphore and OSBYTE &17 decrements it (`*FX22`, `*FX23`).

**Extended vector**
: The Master's way of pointing a MOS vector into a sideways ROM. The vector holds &FF00 + 3n (n the vector number); the extended vector table (address from OSBYTE &A8) holds the target address and ROM number for each vector; the MOS pages the ROM in, calls it, and pages the previous ROM back in on return.

**ACCCON**
: The Master's access control register at &FE34. Bit E makes the VDU drivers use shadow screen RAM; bit X makes ordinary accesses to &3000-&7FFF go to shadow RAM. PMFS sets X to match E while drawing the pointer.

**User VIA**
: The 6522 at &FE60. On the Compact its port B lines PB0-PB4 and CB1, CB2 go to the joystick port; on other Masters port B and CB1, CB2 are the User Port. PMFS reads the mouse through it.

**`ADVAL`**
: BASIC's interface to OSBYTE &80. Channel 0 is the digital joystick and fire buttons, 1-4 the analogue channels. PMFS adds channels 5-9.

## PMFS

**PMFS**
: The pointer and mouse driver on the Master Compact Welcome disc, `$.WIMPS.R.PMFS`, "PMFS 136 (C)1986 PMF". What the name stands for is not known.

  PMF has been identified, by @acheton1984, as Paul Fellows, who ran Acornsoft's languages group and led the team that wrote Arthur. The ROM also holds the initials JPG, whose owner is not known. An 8 KB build is on the Welcome disc titled "Welcome 1.03C Iss4"; later Welcome discs, and the Econet Level 4 File Server supplementary discs, carry a 6 KB build with the same version number.

**Driver on / off**
: On: PMFS has claimed BYTEV and IRQ1V and is polling. Turned on by any device command, off by a device command with the argument 0.

**Device mode**
: Which input moves the pointer: 0 mouse or trackerball, &20 cursor keys, &40 digital joystick, &80 analogue joystick. Returned by `ADVAL(9)`.

**Pointer position**
: The position reported by `ADVAL(7)` and `ADVAL(8)`, in graphics units: X 0-1276, Y 0-1020.

**Hot spot**
: The point of the pointer image that is at the pointer position: the tip of the arrow, 4 graphics units right of and below the image's top left corner.

**Screen format**
: PMFS's index for the screen layout the pointer is drawn in: 0, 1, 2 for MODEs 0, 1, 2, and 3, 4 for MODEs 4, 5.

**Shifted copies**
: The four copies of the pointer image and mask that PMFS builds, each shifted right a further quarter of a screen byte, so that the pointer can be drawn at positions finer than a byte.

**Desktop colours**
: Two physical colours for logical colours 0 and 1, set with OSBYTE &A3,&F3 and applied with `*SETPAL`. Defaults 6 (cyan) and 4 (blue).

**Workspace exchange**
: PMFS's practice of keeping its state at &9440-&946F between calls and swapping it into &9000-&902F while it runs.

**Pinout, Compact and AMX**
: The two ways PMFS knows of wiring a mouse to port B: on the Compact's joystick port (directions on PB3, PB4; buttons on PB0-PB2), or as on a User Port mouse such as the AMX (directions on PB0, PB2; buttons on PB5-PB7). In both, CB1 and CB2 take the X and Y interrupts.

**Quadrature**
: Two square waves a quarter cycle apart, as produced by a mouse's encoders. Which one leads gives the direction of movement.

**Welcome disc**
: The disc supplied with the Master Compact, with a desktop-style menu, applications and demonstrations, and the drivers they use (PMFS, and Acorn's Sprite ROM, SPRITER).
