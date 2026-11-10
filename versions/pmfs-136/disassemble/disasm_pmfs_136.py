"""dasmos driver for PMFS 136, the Master Compact pointer and mouse driver.

PMFS is the file $.WIMPS.R.PMFS on the Acorn BBC Master Compact Welcome
disc: an 8 KB 65C02 sideways ROM image that the Welcome disc's $.Loader puts
in sideways RAM bank 5 with *SRLOAD. Run via:

  uv run fantasm disassemble 136

or directly:

  uv run python versions/pmfs-136/disassemble/disasm_pmfs_136.py

Layout of the image (&8000-&9FFF):

  &8000-&801D  sideways ROM header: service entry only, title "PMFS",
               version "136", copyright "(C)1986 PMF"
  &801E-&8C71  code: service handler, star commands, pointer drawing,
               BYTEV (ADVAL) handler, IRQ (mouse) handler, polling
  &8C72-&8D12  screen-geometry tables
  &8D13-&8F92  pointer images and masks, one of each per screen format
  &8F93-&8F99  initials "JPG,PMF"
  &8F9A-&9FFF  zero: unused space, and the driver's RAM workspace, which
               lies inside its own sideways RAM bank
"""
import os
from pathlib import Path

import dasmos
from dasmos import Align
from dasmos.expr import sym, lo, hi

_script_dirpath = Path(__file__).resolve().parent
_version_dirpath = _script_dirpath.parent
_rom_filepath = os.environ.get('FANTASM_ROM', str(_version_dirpath / 'rom' / 'pmfs-136.rom'))
_output_dirpath = Path(os.environ.get('FANTASM_OUTPUT_DIR', str(_version_dirpath / 'output')))

d = dasmos.Disassembler.create(cpu='65c02')
d.load(_rom_filepath, 0x8000)
d.use_environment('acorn_mos')
d.use_environment('acorn_master_hardware')
d.use_environment('acorn_sideways_rom', rom_title='PMFS 136')

INLINE = Align.INLINE


def cm(addr, text):
    """Inline comment on the instruction or data item at addr."""
    d.comment(addr, text, align=INLINE)


# ---------------------------------------------------------------------------
# MOS entry points, vectors and workspace
# ---------------------------------------------------------------------------

d.label(0xFFEE, 'oswrch', group='os_entry_points',
        description="Write a character to the VDU stream. PMFS uses it only for "
        "the VDU 19 palette commands sent by *SETPAL.")
d.label(0xFFF4, 'osbyte', group='os_entry_points',
        description="OSBYTE. PMFS reads the ADC and digital joystick (&80), the "
        "keyboard (&81), the screen mode (&87), the extended vector table "
        "address (&A8) and the TAB key's code (&DB); it sets the cursor-key "
        "behaviour (&04, &E2), the ROM polling semaphore (&16, &17) and "
        "inserts keys into the keyboard buffer (&99).")
d.label(0xFF06, 'irq1v_extended_entry', group='os_entry_points',
        description="Extended vector entry point for vector 2 (IRQ1V). Calling it "
        "pages in the ROM recorded in entry 2 of the extended vector table, "
        "calls the address held there, and pages the previous ROM back in. "
        "PMFS's IRQ1V trampoline calls it to run irq_handler.")
d.label(0xFF0F, 'bytev_extended_entry', group='os_entry_points',
        description="Extended vector entry point for vector 5 (BYTEV). PMFS points "
        "BYTEV here, and puts its OSBYTE handler in entry 5 of the extended "
        "vector table.")

d.label(0x0204, 'irq1v', group='os_vectors', access='rw', length=2,
        description="Primary interrupt vector. While the driver is on, it points "
        "at the trampoline at irq1v_trampoline (&0D99); the previous value is "
        "kept in saved_irq1v.")
d.label(0x020A, 'bytev', group='os_vectors', access='rw', length=2,
        description="OSBYTE vector. While the driver is on, it points at "
        "bytev_extended_entry (&FF0F), so that OSBYTE calls reach "
        "bytev_handler; the previous value is kept in saved_bytev.")

d.label(0x034E, 'vdu_screen_start_hi', group='os_workspace', access='r',
        description="VDU variable: high byte of the address of the first byte "
        "of screen memory. The pointer drawing routines do not draw rows "
        "whose address is below it, which are above the top of the screen.")
d.label(0x0D97, 'saved_bytev', group='os_workspace', access='rw', length=2,
        description="The value BYTEV had before the driver was turned on. OSBYTE "
        "calls the driver does not handle are passed on through it, and it "
        "is put back in BYTEV when the driver is turned off. Page &0D below "
        "the extended vector table, used by PMFS without any claim.")
d.label(0x0D99, 'irq1v_trampoline', group='os_workspace', access='w', length=6,
        description="Six bytes of code built by the driver when it is turned on: "
        "JSR irq1v_extended_entry : JMP old_irq1v_handler, where the JMP's "
        "operand is saved_irq1v. IRQ1V points "
        "here, so each interrupt first pages in PMFS and runs irq_handler, "
        "then continues to the previous IRQ1V handler.")
d.label(0x0D9C, 'irq1v_trampoline_jmp')
d.label(0x0D9D, 'saved_irq1v', group='os_workspace', access='rw', length=2,
        description="The value IRQ1V had before the driver was turned on. It "
        "is also the operand of the JMP that ends irq1v_trampoline, and it "
        "is put back in IRQ1V when the driver is turned off.")
d.label(0x0DF0, 'rom_workspace_table', group='os_workspace', access='w',
        length=16,
        description="The MOS's table of sideways ROM private workspace pages, "
        "one byte per ROM. On every service call PMFS writes &91 into its "
        "own entry, then uses that entry to find the pages it keeps in its "
        "own bank: &9200 (pointer images), &9300 (pointer masks), &9400 "
        "(the screen under the pointer) and &9440 (the stored workspace).")

d.label(0x00A8, 'cmd_ptr', group='zero_page', access='rw', length=2,
        description="Pointer to the star command being decoded, and then to "
        "its arguments. Also the extended vector table address while the "
        "driver is turned on. In the MOS's command workspace (&A8-&AF).")
d.label(0x00A9, 'cmd_ptr_hi')
d.label(0x00AA, 'cmd_handler_ptr', group='zero_page', access='rw', length=2,
        description="Address of the star command handler, for the indirect "
        "jump through jump_to_command_handler.")
d.label(0x00AB, 'cmd_handler_ptr_hi')
d.label(0x00EF, 'osbyte_a', group='zero_page', access='r',
        description="The A register of the current OSBYTE call, kept by the MOS "
        "for service call 7 (unrecognised OSBYTE).")
d.label(0x00F0, 'osbyte_x', group='zero_page', access='r',
        description="The X register of the current OSBYTE call, kept by the MOS "
        "for service call 7 (unrecognised OSBYTE).")
d.label(0x00F3, 'os_text_ptr_hi')

# Zero page &84-&90 is saved in saved_zero_page on entry to the driver and
# restored on exit. The routines use it as follows.
d.label(0x0084, 'zp_image_ptr', group='zero_page', access='rw', length=2,
        description="Pointer to the pointer image being drawn (the mask is the "
        "page above it). Also the source when building the pointer images, "
        "and the stored-workspace address in exchange_workspace.")
d.label(0x0085, 'zp_image_ptr_hi')
d.label(0x0086, 'zp_under_ptr', group='zero_page', access='rw', length=2,
        description="Pointer to the buffer holding the screen bytes under the "
        "pointer (&9400). Also the destination when building the pointer "
        "images.")
d.label(0x0087, 'zp_under_ptr_hi')
d.label(0x0088, 'zp_temp', group='zero_page', access='rw',
        description="Scratch: the high byte of a byte offset in "
        "calc_pointer_screen_address; the fill bit pattern (&00 for an image, "
        "&FF for a mask) when building shifted pointer images.")
d.label(0x0089, 'zp_row_in_cell', group='zero_page', access='rw',
        description="Offset of the current pixel row from the start of the "
        "current screen address, while drawing or removing the pointer. Also "
        "the destination index when copying the pointer images.")
d.label(0x008A, 'zp_image_index', group='zero_page', access='rw',
        description="Index into the 64-byte pointer image, mask and under-pointer "
        "buffer: 16 rows for each of 4 byte columns. Also the column offset "
        "when building shifted pointer images.")
d.label(0x008B, 'zp_skip_rows', group='zero_page', access='rw',
        description="Scratch: rows to skip above the top of the screen in "
        "restore_screen_under_pointer.")
d.label(0x008C, 'zp_screen_ptr', group='zero_page', access='rw', length=2,
        description="Screen address being drawn to. Also the destination when "
        "copying the pointer images into the bank.")
d.label(0x008D, 'zp_screen_ptr_hi')
d.label(0x008E, 'zp_drawn_ptr', group='zero_page', access='rw', length=2,
        description="Screen address at which the pointer is drawn; bit 7 of the "
        "high byte set means nothing is drawn. Kept in saved_drawn_ptr "
        "between calls.")
d.label(0x008F, 'zp_drawn_ptr_hi')

# ---------------------------------------------------------------------------
# PMFS workspace, in its own sideways RAM bank
# ---------------------------------------------------------------------------
#
# &9000-&902F is exchanged with &9440-&946F (exchange_workspace) on entry
# to and exit from the driver, so the driver addresses its state at &9000
# while it runs and the state is stored at &9440 in between. &9030-&9037
# are not exchanged.

d.label(0x9000, 'tmax_x', group='pmfs_workspace', access='rw', length=2,
        description="The x value given to *TMAX, returned by ADVAL(5). Nothing "
        "else uses it.")
d.label(0x9001, 'tmax_x_hi')
d.label(0x9002, 'tmax_y', group='pmfs_workspace', access='rw', length=2,
        description="The y value given to *TMAX, returned by ADVAL(6). Nothing "
        "else uses it.")
d.label(0x9004, 'pointer_x', group='pmfs_workspace', access='rw', length=2,
        description="Pointer X position in graphics units, 0-1276 (&4FC). Set by "
        "*TSET, returned by ADVAL(7).")
d.label(0x9005, 'pointer_x_hi')
d.label(0x9006, 'pointer_y', group='pmfs_workspace', access='rw', length=2,
        description="Pointer Y position in graphics units, 0-1020 (&3FC). Set by "
        "*TSET, returned by ADVAL(8).")
d.label(0x9007, 'pointer_y_hi')
d.label(0x9008, 'pinout_index', group='pmfs_workspace', access='rw',
        description="Which mouse wiring is in use: 0 for the Master Compact "
        "joystick port, 7 for an AMX-style User Port mouse (the offset of its "
        "record in pinout_table). &FF means not yet detected; set when the "
        "driver is turned on.")
d.label(0x9009, 'redraw_countdown', group='pmfs_workspace', access='rw',
        description="Counts down to the next pointer redraw. Reset to 10 by "
        "update_pointer; decremented by each poll and each mouse interrupt; "
        "the poll redraws the pointer when it goes negative.")
d.label(0x900A, 'driver_on', group='pmfs_workspace', access='rw',
        description="&FF while the driver is on (vectors claimed, polling "
        "enabled), 0 while it is off.")
d.label(0x900B, 'pointer_shown', group='pmfs_workspace', access='rw',
        description="Non-zero while the pointer is shown on the screen.")
d.label(0x900C, 'parsed_number', group='pmfs_workspace', access='rw', length=2,
        description="Result of parse_number.")
d.label(0x900D, 'parsed_number_hi')
d.label(0x900E, 'parse_temp', group='pmfs_workspace', access='rw', length=2,
        description="parse_number's copy of the value so far, used to multiply "
        "it by 10.")
d.label(0x900F, 'parse_temp_hi')
d.label(0x9012, 'screen_format', group='pmfs_workspace', access='rw',
        description="Screen format for drawing the pointer, set by *POINTER from "
        "the screen mode: 0, 1 and 2 for MODEs 0, 1 and 2; 3 and 4 for MODEs "
        "4 and 5.")
d.label(0x9013, 'pointer_shape', group='pmfs_workspace', access='w',
        description="Byte offset into the pointer image and mask tables given "
        "to build_pointer_images. *POINTER always passes 0.")
d.label(0x9014, 'button_state', group='pmfs_workspace', access='rw',
        description="The button bits read at the previous poll.")
d.label(0x9015, 'button_pending', group='pmfs_workspace', access='rw',
        description="A changed button reading waiting to be confirmed by the next "
        "poll; 0 when none is pending.")
d.label(0x9016, 'drawn_x', group='pmfs_workspace', access='rw', length=2,
        description="pointer_x when the pointer was last drawn.")
d.label(0x9017, 'drawn_x_hi')
d.label(0x9018, 'drawn_y', group='pmfs_workspace', access='rw', length=2,
        description="pointer_y when the pointer was last drawn.")
d.label(0x9019, 'drawn_y_hi')
d.label(0x901A, 'pointer_left', group='pmfs_workspace', access='rw', length=2,
        description="X of the left edge of the pointer image (pointer_x less the "
        "hot spot), stepped along each byte column while drawing.")
d.label(0x901B, 'pointer_left_hi')
d.label(0x901C, 'drawn_left', group='pmfs_workspace', access='rw', length=2,
        description="pointer_left for the pointer as drawn, used to remove it.")
d.label(0x901D, 'drawn_left_hi')
d.label(0x901E, 'pointer_top', group='pmfs_workspace', access='rw', length=2,
        description="Y of the top edge of the pointer image (pointer_y plus the "
        "hot spot); calc_pointer_screen_address turns it into a pixel row.")
d.label(0x901F, 'pointer_top_hi')
d.label(0x9020, 'saved_drawn_ptr', group='pmfs_workspace', access='rw',
        length=2,
        description="zp_drawn_ptr kept between calls to the driver.")
d.label(0x9021, 'saved_drawn_ptr_hi')
d.label(0x9022, 'saved_zero_page', group='pmfs_workspace', access='rw',
        length=13,
        description="The caller's zero page &84-&90, saved on entry to the driver "
        "and restored on exit. Its last byte is shared with saved_acccon.")
d.label(0x902E, 'saved_acccon', group='pmfs_workspace', access='rw',
        description="ACCCON saved while the pointer is drawn or removed. The same "
        "byte holds the saved value of zero page &90, so drawing or removing "
        "the pointer leaves ACCCON's value in &90.")
d.label(0x9030, 'cmd_start_offset', group='pmfs_workspace', access='rw',
        description="Offset of the start of the command name, so the matcher can "
        "go back to it for the next table entry.")
d.label(0x9031, 'device_mode', group='pmfs_workspace', access='rw',
        description="The input device: 0 mouse or trackerball, &20 cursor keys, "
        "&40 digital joystick, &80 analogue joystick. Returned by ADVAL(9).")
d.label(0x9032, 'x_speed', group='pmfs_workspace', access='rw', length=2,
        description="Horizontal step for joystick and keys, in 1/256 graphics "
        "units: the high byte is added to or subtracted from pointer_x.")
d.label(0x9033, 'x_speed_hi')
d.label(0x9034, 'y_speed', group='pmfs_workspace', access='rw', length=2,
        description="Vertical step for joystick and keys, in 1/256 graphics "
        "units.")
d.label(0x9035, 'y_speed_hi')
d.label(0x9036, 'desktop_colours', group='pmfs_workspace', access='rw',
        length=2,
        description="Physical colours for logical colours 0 and 1, set through "
        "OSBYTE &A3,&F3 and sent to the VDU by *SETPAL.")
d.label(0x9037, 'desktop_colour_1')

# Pages in the bank found through rom_workspace_table (set to &91), so &92xx
# is page +1, &93xx page +2 and &94xx page +3.
d.label(0x9200, 'pointer_image_copies', group='pmfs_workspace', access='rw',
        length=256,
        description="The pointer image for the current screen format, in four "
        "copies shifted right by a quarter of a byte each (&40 bytes apiece). "
        "Built by build_pointer_images; addressed as rom_workspace_table+1.")
d.label(0x9300, 'pointer_mask_copies', group='pmfs_workspace', access='rw',
        length=256,
        description="The pointer mask in four shifted copies, one page above the "
        "images. Addressed as rom_workspace_table+2.")
d.label(0x9400, 'screen_under_pointer', group='pmfs_workspace', access='rw',
        length=64,
        description="The 64 screen bytes covered by the pointer, saved when it is "
        "drawn and put back when it is removed. Addressed as "
        "rom_workspace_table+3.")
d.label(0x9440, 'stored_workspace', group='pmfs_workspace', access='rw',
        length=48,
        description="Where &9000-&902F is kept between calls to the driver; see "
        "exchange_workspace.")

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

d.constant(0x04, 'service_unrecognised_command')
d.constant(0x07, 'service_unrecognised_osbyte')
d.constant(0x15, 'service_polling_interrupt')
d.constant(0x27, 'service_reset')
d.constant(0x91, 'pmfs_workspace_page')
d.constant(0xA3, 'osbyte_application')
d.constant(0xF3, 'osbyte_a3_pmfs_colours')
d.constant(0x80, 'osbyte_read_adc')
d.constant(0x00, 'device_mode_mouse')
d.constant(0x20, 'device_mode_keys')
d.constant(0x40, 'device_mode_digital')
d.constant(0x80, 'device_mode_joystick')
d.constant(0x98, 'via_ier_enable_cb1_cb2')
d.constant(0x18, 'via_ier_disable_cb1_cb2')
d.constant(0x10, 'via_int_cb1')
d.constant(0x08, 'via_int_cb2')
d.constant(0x02, 'acccon_e')
d.constant(0x04, 'acccon_x')
d.constant(0xDC, 'err_bad_number')
d.constant(0x0D, 'key_return')
d.constant(0xC0, 'key_right_button')
d.constant(0x13, 'vdu_set_palette')
d.constant(0x06, 'ext_vector_offset_irq1v')
d.constant(0x0F, 'ext_vector_offset_bytev')
d.constant(0x20, 'opcode_jsr')
d.constant(0x4C, 'opcode_jmp')
d.constant(0x04FC, 'pointer_x_max')
d.constant(0x03FC, 'pointer_y_max')
d.constant(0x0280, 'pointer_x_centre')
d.constant(0x0200, 'pointer_y_centre')
d.constant(0x0A, 'redraw_interval')
d.constant(0x40, 'pointer_image_size')
d.constant(0x40, 'speed_shift_boost')
d.constant(0x10, 'speed_acceleration')
d.constant(0x80, 'speed_initial')


# ---------------------------------------------------------------------------
# Service handler
# ---------------------------------------------------------------------------

d.subroutine(0x801E, 'service_handler',
    title='Service call handler',
    description="""Entered through the service entry for every service call, with the
reason code in A and the ROM number in X.

On every call it first sets the ROM's entry in rom_workspace_table to &91,
so that its private workspace is taken to be page &91 of its own bank;
the drawing and workspace routines find their pages from that entry.

Calls handled:

| A | Call | Action |
|---|------|--------|
| &04 | Unrecognised star command | Decode and run a PMFS command (service_command) |
| &07 | Unrecognised OSBYTE | Claim OSBYTE &A3 with X=&F3: set the desktop colours |
| &15 | Polling interrupt | Move the pointer, redraw it, read the buttons |
| &27 | Reset | Clear the driver state |

Calls &04 and &15 are dispatched by dispatch_service; the others are
handled here. Every exit goes through return_from_service, which puts the
ROM number back in X.

The reset call clears driver_on, pointer_shown, button_pending and
device_mode with direct stores, without first exchanging the workspace
(see exchange_workspace). device_mode lies outside the exchanged area and
is cleared, but the other three are in it, so the stores reach the copy at
&9000, not the copy at &9440 that the driver uses on its next call.""",
    on_entry={'A': 'service call number', 'X': 'this ROM\'s number',
              'Y': 'service call parameter'},
    on_exit={'A': '0 if the call was claimed, otherwise preserved',
             'X': 'this ROM\'s number'})
cm(0x801E, 'Save the service call number')
cm(0x801F, 'Private workspace page &91, in this bank...')
d.expr(0x8020, 'pmfs_workspace_page')
cm(0x8021, '...goes in this ROM\'s workspace table entry')
cm(0x8024, 'Recover the service call number')
cm(0x8025, 'Handle a command (&04) or a poll (&15)')
cm(0x8028, 'Save the (possibly claimed) call number again')
cm(0x8029, 'Reset?')
d.expr(0x802A, 'service_reset')
cm(0x802B, 'Yes: clear the driver state')
cm(0x802D, 'Unrecognised OSBYTE?')
d.expr(0x802E, 'service_unrecognised_osbyte')
cm(0x802F, 'No: return the call as it is')
cm(0x8031, 'Keep X...')
cm(0x8032, '...and Y for the OSBYTE caller')
cm(0x8033, 'Is the OSBYTE number &A3...')
cm(0x8035, '...(application OSBYTE)?')
d.expr(0x8036, 'osbyte_application')
cm(0x8037, 'No: not ours')
cm(0x8039, 'And is X &F3...')
cm(0x803B, '...the PMFS sub-call?')
d.expr(0x803C, 'osbyte_a3_pmfs_colours')
cm(0x803D, 'No: not ours')
cm(0x803F, 'Set the desktop colours from Y')
cm(0x8042, 'A=0: claim the call')
cm(0x8044, 'Restore Y...')
cm(0x8045, '...and X')
cm(0x8046, 'Return the call claimed')

d.label(0x8048, 'not_pmfs_osbyte')
cm(0x8048, 'A=7: leave the OSBYTE call unclaimed')
d.expr(0x8049, 'service_unrecognised_osbyte')
cm(0x804A, 'Restore Y...')
cm(0x804B, '...and X')
cm(0x804C, 'Return the call unclaimed')

d.label(0x804E, 'reset_driver_state')
cm(0x804E, 'Driver off, in the copy at &9000 (see banner)')
cm(0x8051, 'Pointer not shown, in the copy at &9000')
cm(0x8054, 'No button change pending, in the copy at &9000')
cm(0x8057, 'Device mode back to mouse')
cm(0x805A, 'Return the call unclaimed')

d.label(0x805C, 'return_from_service')
cm(0x805C, 'Restore X: this ROM\'s number')
cm(0x805E, 'A = the call number, or 0 if claimed')
cm(0x805F, 'Return to the MOS')
d.byte(0x8060)
cm(0x8060, 'Unused (a NOP opcode)')

# ---------------------------------------------------------------------------
# Screen address of the pointer
# ---------------------------------------------------------------------------

d.subroutine(0x8061, 'calc_pointer_screen_address',
    title='Find the screen address of the top left of the pointer',
    description="""Turn the top left corner of the pointer image, pointer_left and
pointer_top in graphics units, into a screen address and a shift.

Graphics Y runs up the screen from 0 to 1023 in steps of 4 per pixel row,
so pointer_top / 4 is a pixel row counted up from the bottom, and that / 8
is a character row counted up from the bottom. The character row indexes
a table of row start addresses for the screen format (mode012_row_addr or
mode45_row_addr), which counts up from the bottom row too and has two
extra entries above the top of the screen. The pixel row within the
character row is inverted (EOR 7) because screen rows run downwards.

The byte column is pointer_left / 16 in MODEs 0-2 and pointer_left / 32
in MODEs 4 and 5, which is a screen offset of 8 bytes per column. A
negative pointer_left (the pointer partly off the left edge) is handled
without signed arithmetic: 1280 is added, which moves it to the right-hand
end of the row below, and the row is moved up one to compensate.

The shift is which quarter of a screen byte the image starts at,
0-3, used to choose one of the four shifted copies of the image.

Rows above the top of the screen (pointer_top of 1024 or more) take the
two extra table entries. Their addresses are below the start of screen
memory, so the drawing routines skip them.""",
    on_entry={'pointer_left': 'X of the left edge of the image',
              'pointer_top': 'Y of the top edge of the image'},
    on_exit={'zp_screen_ptr': 'screen address of the top left byte',
             'X': 'shift, 0-3 (which shifted copy of the image to use)',
             'pointer_top': 'pixel row (Y / 4), possibly inverted',
             'A': 'corrupted', 'Y': 'preserved'})
cm(0x8061, 'Pixel row = pointer_top / 4: take the high byte')
cm(0x8064, '...into a scratch byte')
cm(0x8066, 'and the low byte')
cm(0x8069, 'Divide by 2...')
cm(0x806B, '...through both bytes')
cm(0x806C, 'and by 2 again')
cm(0x806E, '...(carry bit 8 of the row stays in zp_screen_ptr)')
cm(0x806F, 'Keep the pixel row, 0-255 on the screen')
cm(0x8072, 'Character row = pixel row / 8...')
cm(0x8073, '...')
cm(0x8074, '...counted up from the bottom')
cm(0x8075, 'X = character row, indexing the row tables')
cm(0x8076, 'Is the image\'s left edge negative?')
cm(0x8079, 'No')
cm(0x807B, 'Yes: one row up, to undo the +1280 applied below')
d.label(0x807C, 'check_above_screen')
cm(0x807C, 'Is the pixel row 256 or more (above the screen)?')
cm(0x807E, 'No')
cm(0x8080, 'Yes: use the extra table entries above the top...')
cm(0x8081, '...')
cm(0x8082, '...32 rows up')
cm(0x8084, '...')
cm(0x8085, 'and invert the pixel row within the character')
cm(0x8088, 'row, so that the EOR below cancels it out')
cm(0x808A, '...')
d.label(0x808D, 'look_up_row_address')
cm(0x808D, 'Which screen format?')
cm(0x8090, 'MODEs 4 and 5 (formats 3 and 4)?')
cm(0x8092, 'Yes: use the 320-byte row table')
cm(0x8094, 'MODEs 0-2: row address high byte...')
cm(0x8097, '...')
cm(0x8099, 'and low byte, from the 640-byte row table')
cm(0x809C, '...')
cm(0x809E, 'Go and add the column')
d.label(0x80A0, 'look_up_mode45_row_address')
cm(0x80A0, 'MODEs 4 and 5: row address high byte...')
cm(0x80A3, '...')
cm(0x80A5, 'and low byte')
cm(0x80A8, '...')
d.label(0x80AA, 'add_column_offset')
cm(0x80AA, 'High byte of the left edge')
cm(0x80AD, 'Positive: use it as it is')
cm(0x80AF, 'Negative: add 1280 (&500), wrapping to the right')
cm(0x80B0, 'end of the row below')
cm(0x80B2, 'Keep the high byte')
cm(0x80B4, 'Low byte of the left edge')
cm(0x80B7, 'Which screen format?')
cm(0x80BA, 'MODEs 4 and 5?')
cm(0x80BC, 'No: 16 units a byte, so offset = X / 2')
cm(0x80BE, 'Yes: 32 units a byte, so offset = X / 4:')
cm(0x80C0, 'one extra halving')
d.label(0x80C1, 'halve_column_offset')
cm(0x80C1, 'Halve the left edge...')
cm(0x80C3, '...')
cm(0x80C4, 'Round down to a whole byte column (8 bytes each)')
cm(0x80C6, 'Add the column offset...')
cm(0x80C7, '...to the row address')
cm(0x80C9, '...')
cm(0x80CB, 'and the high byte')
cm(0x80CD, '...')
cm(0x80CF, '...')
cm(0x80D1, 'Pixel row within the character row...')
cm(0x80D4, '...')
cm(0x80D6, '...counted down from the top of it')
cm(0x80D8, 'is the byte within the character cell')
cm(0x80DA, '...')
cm(0x80DC, 'Left edge again, for the shift')
cm(0x80DF, 'Which screen format?')
cm(0x80E2, 'MODEs 4 and 5?')
cm(0x80E4, 'No: shift = (X / 4) MOD 4')
cm(0x80E6, 'Yes: shift = (X / 8) MOD 4')
d.label(0x80E7, 'calc_shift')
cm(0x80E7, 'Quarter-byte steps...')
cm(0x80E8, '...')
cm(0x80E9, '...within the byte')
cm(0x80EB, 'X = shift, 0-3')
cm(0x80EC, 'Return')

# ---------------------------------------------------------------------------
# Desktop colours
# ---------------------------------------------------------------------------

d.subroutine(0x80ED, 'cmd_setpal',
    title='*SETPAL: set the desktop colours',
    description="""Send VDU 19,0,c0,0,0,0 and VDU 19,1,c1,0,0,0, setting logical colours 0
and 1 to the physical colours in desktop_colours, which OSBYTE &A3,&F3
chooses. The command takes no arguments, and it works whether or not
the driver is on.""",
    on_exit={'A': 'corrupted'})
cm(0x80ED, 'VDU 19: define a logical colour...')
d.expr(0x80EE, 'vdu_set_palette')
cm(0x80EF, '...')
cm(0x80F2, 'logical colour 0...')
cm(0x80F4, '...')
cm(0x80F7, 'physical colour: desktop colour 0...')
cm(0x80FA, '...')
cm(0x80FD, 'and three zero bytes...')
cm(0x80FF, '...')
cm(0x8102, '...')
cm(0x8105, '...')
cm(0x8108, 'VDU 19 again...')
d.expr(0x8109, 'vdu_set_palette')
cm(0x810A, '...')
cm(0x810D, 'logical colour 1...')
cm(0x810F, '...')
cm(0x8112, 'physical colour: desktop colour 1...')
cm(0x8115, '...')
cm(0x8118, 'and three zero bytes...')
cm(0x811A, '...')
cm(0x811D, '...')
cm(0x8120, '...')
cm(0x8123, 'Return')

d.subroutine(0x8124, 'reset_desktop_colours',
    title='Set the default desktop colours',
    description="""Set desktop colour 0 to 6 (cyan) and desktop colour 1 to 4 (blue).
Reached from set_desktop_colours when bit 7 of Y is set.""")
cm(0x8124, 'Colour 0 = 6, cyan')
cm(0x8126, '...')
cm(0x8129, 'Colour 1 = 4, blue')
cm(0x812B, '...')
cm(0x812E, 'Return')

d.subroutine(0x812F, 'step_desktop_colour',
    title='Step a desktop colour to the next physical colour',
    description="""Advance the desktop colour chosen by bit 3 of Y to the next physical
colour, 0-7, wrapping round, and skipping the colour the other desktop
colour has, so that the two never match. Reached from
set_desktop_colours when bit 6 of Y is set.""",
    on_entry={'Y': 'bit 3: which colour to step (0 or 1)'})
cm(0x812F, 'Bit 3 of Y...')
cm(0x8130, '...')
cm(0x8131, '...')
cm(0x8132, '...')
cm(0x8133, '...selects the colour to step')
cm(0x8135, 'X = that colour')
cm(0x8136, 'Y = the other one')
cm(0x8138, '...')
cm(0x8139, 'Current physical colour')
d.label(0x813C, 'try_next_colour')
cm(0x813C, 'Next physical colour...')
cm(0x813D, '...modulo 8')
cm(0x813F, 'Same as the other desktop colour?')
cm(0x8142, 'Yes: skip it')
cm(0x8144, 'Store the new colour')
cm(0x8147, 'Return')

d.subroutine(0x8148, 'set_desktop_colours',
    title='OSBYTE &A3,&F3: set the desktop colours',
    description="""Handle OSBYTE &A3 with X=&F3, according to Y:

| Y | Effect |
|---|--------|
| bit 7 set | Reset both colours to the defaults (6 and 4) |
| bit 6 set | Step colour (Y bit 3) to the next physical colour |
| otherwise | Set colour (Y bit 3) to physical colour Y AND 7 |

The colours are only stored; *SETPAL sends them to the VDU.
service_handler returns X and Y to the OSBYTE caller unchanged.""",
    on_entry={'Y': 'the OSBYTE\'s Y parameter'},
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'corrupted'})
cm(0x8148, 'Bit 7 of Y...')
cm(0x8149, '...into carry')
cm(0x814A, 'Set: reset both colours')
cm(0x814C, 'Bit 6 into carry')
cm(0x814D, 'Set: step a colour')
cm(0x814F, 'Bit 3 of Y...')
cm(0x8150, '...')
cm(0x8151, '...')
cm(0x8152, '...')
cm(0x8153, '...selects the colour')
cm(0x8155, '...')
cm(0x8156, 'Bits 0-2...')
cm(0x8157, '...are the physical colour')
cm(0x8159, 'Store it')
cm(0x815C, 'Return')

# ---------------------------------------------------------------------------
# Star commands
# ---------------------------------------------------------------------------

d.subroutine(0x815D, 'dispatch_service',
    title='Handle the polling and star command service calls',
    description="""Called from service_handler with the service call number in A. On a
poll (&15), move the pointer for the joystick or keys, then redraw it
and read the buttons; the call is not claimed. On an unrecognised star
command (&04), decode it. Other calls return at once.""",
    on_entry={'A': 'service call number', 'Y': 'for &04, the offset of the command at (os_text_ptr)'},
    on_exit={'A': '0 if a command was run, otherwise preserved',
             'X': 'preserved', 'Y': 'preserved'})
cm(0x815D, 'Polling interrupt?')
d.expr(0x815E, 'service_polling_interrupt')
cm(0x815F, 'No')
cm(0x8161, 'Yes: move the pointer for joystick or keys')
cm(0x8164, 'then redraw and read the buttons, and return')

d.label(0x8167, 'service_command')
d.banner(0x8167, title='Decode a star command',
    description="""Service call &04. Match the command at (os_text_ptr),Y against
command_table, ignoring case. A name may be abbreviated with a full stop
after at least one letter; otherwise the name must be followed by a space
or the end of the line. The first table entry that matches is run; if the
whole name matched but is followed by anything else, the command is
left for other ROMs without trying further entries.

On a match, cmd_ptr is moved past the name and any spaces or commas,
interrupts are disabled, the driver's workspace is brought in
(enter_driver), the handler is called with Y=0, and the workspace is put
back (leave_driver). The call is then claimed. The handler runs with
interrupts disabled throughout; the caller's flags are restored on
return.

When moving cmd_ptr past the name, a carry out of the low byte
increments the low byte instead of the high byte, so a command whose
arguments start on a later page than its name is read from the wrong
place.""")
cm(0x8167, 'Unrecognised star command?')
d.expr(0x8168, 'service_unrecognised_command')
cm(0x8169, 'No: return')
cm(0x816B, 'Save the flags')
cm(0x816C, 'and the registers')
cm(0x816D, '...')
cm(0x816E, '...')
cm(0x816F, 'cmd_ptr = os_text_ptr + Y,')
cm(0x8170, 'the start of the command')
cm(0x8171, '...')
cm(0x8173, '...')
cm(0x8175, '...')
cm(0x8177, '...')
cm(0x8179, '...')
cm(0x817B, 'From its first character')
cm(0x817D, 'skip leading spaces and commas')
cm(0x8180, 'X = offset into command_table')
cm(0x8182, 'Remember where the name starts')
d.label(0x8185, 'match_command_char')
cm(0x8185, 'Next character of the command...')
cm(0x8187, '...in upper case')
cm(0x8189, 'Same as the table?')
cm(0x818C, 'Yes: compare the next one')
cm(0x818E, 'No: is it a full stop (an abbreviation)?')
d.char_literal(0x818F)
cm(0x8190, '...')
cm(0x8192, 'Yes: accept the name so far')
cm(0x8194, 'Has the table name ended (address byte)?')
cm(0x8197, 'Yes: the whole name matched')
cm(0x8199, 'No match: back to the start of the command')
d.label(0x819C, 'skip_to_next_command')
cm(0x819C, 'Skip the rest of this table name...')
cm(0x819D, '...up to its address byte')
cm(0x81A0, '...')
cm(0x81A2, 'and the two address bytes')
cm(0x81A3, '...')
cm(0x81A4, 'End of the table (&FF)?')
cm(0x81A7, 'No: try this entry')

d.subroutine(0x81A9, 'restore_registers_and_return',
    title='Restore the registers and flags and return',
    description="""Pull Y, X, A and the flags, pushed in that order's reverse by the
caller, and return. Used to leave service_command without claiming the
call, and as the common exit of irq_handler, poll_move_pointer and
poll_redraw_and_buttons.""",
    on_exit={'A': 'restored', 'X': 'restored', 'Y': 'restored', 'flags': 'restored'})
cm(0x81A9, 'Restore Y')
cm(0x81AA, 'X')
cm(0x81AB, 'A')
cm(0x81AC, 'and the flags')
cm(0x81AD, 'Return')

d.label(0x81AE, 'next_command_char')
cm(0x81AE, 'Next table character')
cm(0x81AF, 'and next command character')
cm(0x81B0, 'Always taken (Y does not wrap)')
d.label(0x81B2, 'command_abbreviated')
cm(0x81B2, 'Step past the full stop')
cm(0x81B3, 'Always taken: no terminator check after a stop')
d.label(0x81B5, 'command_name_matched')
cm(0x81B5, 'Back onto the last name character')
cm(0x81B6, 'The name must be followed by...')
cm(0x81B8, '...a space')
d.char_literal(0x81B9)
cm(0x81BA, '...')
cm(0x81BC, '...or the end of the line')
d.expr(0x81BD, 'key_return')
cm(0x81BE, 'Neither: not a PMFS command after all')
d.label(0x81C0, 'find_handler_address')
cm(0x81C0, 'Find the address bytes after the name')
cm(0x81C1, '...')
cm(0x81C4, '...')
cm(0x81C6, 'Index &4B: no entry\'s address is here, so this')
cm(0x81C8, 'never branches')
cm(0x81CA, 'Skip spaces and commas before the arguments')
d.label(0x81CD, 'advance_to_arguments')
cm(0x81CD, 'cmd_ptr += Y: point at the arguments')
cm(0x81CE, '...')
cm(0x81CF, '...')
cm(0x81D1, '...')
cm(0x81D3, '...')
cm(0x81D5, 'Carry: increments the low byte, not the high byte')
d.label(0x81D7, 'call_command_handler')
cm(0x81D7, 'Handler address, high byte first...')
cm(0x81DA, '...')
cm(0x81DC, 'then low byte')
cm(0x81DF, '...')
cm(0x81E1, 'Interrupts off while the workspace is in use')
cm(0x81E2, 'Bring in the workspace, save zero page')
cm(0x81E5, 'Run the command')
cm(0x81E8, 'Put back zero page and the workspace')
cm(0x81EB, 'Restore Y')
cm(0x81EC, 'and X')
cm(0x81ED, 'Discard the saved call number')
cm(0x81EE, 'A=0: claim the call')
cm(0x81F0, 'Restore the caller\'s flags')
cm(0x81F1, 'Return')

d.subroutine(0x81F2, 'jump_to_command_handler',
    title='Jump to the command handler',
    description="""Called by service_command so that the handler's RTS returns to it.""")
cm(0x81F2, 'Jump to the handler at cmd_handler_ptr')

d.label(0x81F5, 'command_table')
d.banner(0x81F5, title='Star command table',
    description="""Each entry is a command name in upper case, followed by the address of
its handler, high byte first. The high byte has bit 7 set, which ends the
name; the table ends with &FF. *MOUSE and *TRACKERBALL share a handler.
TSET's low address byte happens to be &48, the code for "H".

| Command | Handler |
|---------|---------|
| *KEYS | cmd_keys |
| *DIGITAL | cmd_digital |
| *JOYSTICK | cmd_joystick |
| *MOUSE | cmd_mouse |
| *POINTER | cmd_pointer |
| *TMAX | cmd_tmax |
| *TRACKERBALL | cmd_mouse |
| *TSET | cmd_tset |
| *SETPAL | cmd_setpal |

Entries are tried in order, so an abbreviation takes the first command
it fits: *T. is *TMAX and *M. is *MOUSE.""")
_commands = [
    (0x81F5, 'KEYS', 'cmd_keys'),
    (0x81FB, 'DIGITAL', 'cmd_digital'),
    (0x8204, 'JOYSTICK', 'cmd_joystick'),
    (0x820E, 'MOUSE', 'cmd_mouse'),
    (0x8215, 'POINTER', 'cmd_pointer'),
    (0x821E, 'TMAX', 'cmd_tmax'),
    (0x8224, 'TRACKERBALL', 'cmd_mouse'),
    (0x8231, 'TSET', 'cmd_tset'),
    (0x8237, 'SETPAL', 'cmd_setpal'),
]
for _addr, _name, _handler in _commands:
    d.string(_addr, len(_name))
    cm(_addr, f'*{_name}')
    _addr_hi = _addr + len(_name)
    d.byte(_addr_hi)
    d.expr(_addr_hi, hi(sym(_handler)))
    cm(_addr_hi, f'Handler {_handler}, high byte (bit 7 ends the name)')
    d.byte(_addr_hi + 1)
    d.expr(_addr_hi + 1, lo(sym(_handler)))
    cm(_addr_hi + 1, 'and low byte')
d.byte(0x823F)
cm(0x823F, 'End of the table')
d.expr(0x8189, 'command_table')
d.expr(0x8195, 'command_table')
d.expr(0x819E, 'command_table')
d.expr(0x81A5, 'command_table')
d.expr(0x81C2, 'command_table')
d.expr(0x81D8, 'command_table')
d.expr(0x81DD, sym('command_table') + 1)

d.subroutine(0x8240, 'reset_argument_index',
    title='Point Y at the first argument',
    description="""Set Y=0, the first character at cmd_ptr, which service_command has left
pointing at the command's arguments.""",
    on_exit={'Y': '0'})
cm(0x8240, 'Offset 0 from cmd_ptr')
cm(0x8242, 'Return')

d.subroutine(0x8243, 'check_digit',
    title='Check that a character is a decimal digit',
    description="""Return if A is "0"-"9"; otherwise raise error &DC, "Bad number".""",
    on_entry={'A': 'character'},
    on_exit={'A': 'preserved', 'flags': 'C set'})
cm(0x8243, 'Below "0"?')
d.char_literal(0x8244)
cm(0x8245, 'Yes: bad number')
cm(0x8247, 'Above "9"?')
d.char_literal(0x8248)
cm(0x8249, 'Yes: bad number')
cm(0x824B, 'A digit: return')

d.label(0x824C, 'bad_number_error')
d.banner(0x824C, title='Error &DC, "Bad number"',
    description="""A BRK error block, raised by falling into it from check_digit, or by
jumping to it from *TMAX and *TSET.""")
cm(0x824C, 'BRK: raise an error')
d.byte(0x824D)
d.expr(0x824D, 'err_bad_number')
cm(0x824D, 'Error number')
d.string(0x824E, 10)
cm(0x824E, 'Error message')
d.byte(0x8258)
cm(0x8258, 'End of the message')

d.subroutine(0x8259, 'skip_separators',
    title='Skip spaces and commas',
    description="""Advance Y past any spaces and commas at (cmd_ptr),Y.""",
    on_entry={'Y': 'offset into the command line'},
    on_exit={'Y': 'offset of the next other character',
             'A': 'that character'})
cm(0x8259, 'Next character')
cm(0x825B, 'A comma?')
d.char_literal(0x825C)
cm(0x825D, 'Yes: skip it')
cm(0x825F, 'A space?')
d.char_literal(0x8260)
cm(0x8261, 'No: done')
d.label(0x8263, 'skip_separator')
cm(0x8263, 'Step past it')
cm(0x8264, 'Always taken (Y does not wrap)')
cm(0x8266, 'Return')

# ---------------------------------------------------------------------------
# Device commands: turning the driver on and off
# ---------------------------------------------------------------------------

d.subroutine(0x8267, 'turn_driver_off',
    title='Turn the driver off',
    description="""Reached from select_device when a device command's argument is 0
(for example *MOUSE 0). If the driver is on: put back the IRQ1V and BYTEV
values saved when it was turned on, stop the polling service calls
(OSBYTE &17), disable the mouse interrupts, remove the pointer, and mark
the driver off. The extended vector table entries it set are left as
they are. device_mode is not changed.""")
cm(0x8267, 'Is the driver on?')
cm(0x826A, 'No: nothing to do')
cm(0x826C, 'Interrupts off while the vectors change')
cm(0x826D, '...')
cm(0x826E, 'Put back the old IRQ1V...')
cm(0x8271, '...')
cm(0x8274, '...')
cm(0x8277, '...')
cm(0x827A, 'and the old BYTEV')
cm(0x827D, '...')
cm(0x8280, '...')
cm(0x8283, '...')
cm(0x8286, 'Interrupts back as they were')
cm(0x8287, 'OSBYTE &17: decrement the ROM polling semaphore,')
cm(0x8289, 'ending the polling service calls')
cm(0x828C, 'Disable the mouse interrupts, remove the pointer')
cm(0x828F, 'The driver is off')
d.label(0x8292, 'return_from_device_command')
cm(0x8292, 'Return')

d.subroutine(0x8293, 'cmd_keys',
    title='*KEYS: steer the pointer with the cursor keys',
    description="""Select device mode &20. *FX4,2 makes the cursor keys act as function
keys, and *FX226,0 makes the MOS ignore SHIFT with the function keys, so
that the cursor keys, now steering the pointer, are not seen as cursor
editing. Neither setting is undone when another device is chosen or the
driver is turned off. Continues at select_device.""")
cm(0x8293, 'Device mode: cursor keys')
d.expr(0x8294, 'device_mode_keys')
cm(0x8295, '...')
cm(0x8298, 'OSBYTE 4 with X=2:')
cm(0x829A, 'cursor keys act as function keys')
cm(0x829C, '...')
cm(0x829E, '...')
cm(0x82A1, 'OSBYTE &E2 with X=0, Y=0:')
cm(0x82A3, 'SHIFT with a function key is ignored')
cm(0x82A5, '...')
cm(0x82A7, '...')
cm(0x82AA, 'Go on to select the device')

d.subroutine(0x82AC, 'cmd_digital',
    title='*DIGITAL: steer the pointer with a digital joystick',
    description="""Select device mode &40, in which the pointer follows the direction bits
the MOS returns from ADVAL(0). Continues at select_device.""")
cm(0x82AC, 'Device mode: digital joystick')
d.expr(0x82AD, 'device_mode_digital')
cm(0x82AE, '...')
cm(0x82B1, 'Go on to select the device')

d.subroutine(0x82B3, 'cmd_joystick',
    title='*JOYSTICK: steer the pointer with an analogue joystick',
    description="""Select device mode &80, in which the pointer follows ADVAL(1) and
ADVAL(2). Continues at select_device.""")
cm(0x82B3, 'Device mode: analogue joystick')
d.expr(0x82B4, 'device_mode_joystick')
cm(0x82B5, '...')
cm(0x82B8, 'Go on to select the device')

d.subroutine(0x82BA, 'cmd_mouse',
    title='*MOUSE and *TRACKERBALL: move the pointer with a mouse',
    description="""Select device mode 0, in which the pointer is moved by the User VIA's
CB1 and CB2 interrupts (irq_handler). Falls into select_device.""")
cm(0x82BA, 'Device mode: mouse or trackerball')

d.label(0x82BD, 'select_device')
d.banner(0x82BD, title='Select a device, and turn the driver on or off',
    description="""Common tail of the device commands, with device_mode already set. The
joystick and key speeds are reset. If the argument starts with "0" the
driver is turned off (turn_driver_off). Otherwise, if the driver is
already on, nothing more is done: only the device mode has changed. In
particular the mouse interrupts are not enabled or disabled to suit the
new mode until *POINTER shows the pointer again, which is why software
switches devices with, for example, *DIGITAL 0 then *MOUSE.

If the driver is off, it is turned on:

- driver_on is set, the pointer is marked not shown, and no button change
  is pending;
- OSBYTE &16 starts the polling service calls;
- the mouse pinout is marked as not yet detected;
- in mouse mode the User VIA is set up for the mouse: CB1 and CB2
  interrupt on a falling edge, port latching off, CB1 and CB2 interrupts
  enabled and port B all inputs; in other modes the CB1 and CB2
  interrupts are disabled;
- the pointer is put in the middle of the screen, at (640, 512);
- BYTEV is pointed at the extended vector entry for BYTEV, and the
  extended vector table entry at bytev_handler in this ROM;
- IRQ1V is pointed at irq1v_trampoline, which is built here, and the
  extended vector table entry for IRQ1V is pointed at irq_handler in this
  ROM. IRQ1V does not point at that entry itself: the trampoline calls it,
  so that when irq_handler returns, the previous ROM is paged back in and
  the trampoline continues to the old IRQ1V handler.

In both cases the low byte of the extended vector entry point (&0F, &06) is
also the offset of the vector's entry in the table, three times the vector
number, so one register load serves for both.

The pointer is not shown; that takes *POINTER.""")
cm(0x82BD, 'Horizontal speed back to the start')
cm(0x82C0, 'Vertical speed back to the start')
cm(0x82C3, 'First argument character')
cm(0x82C6, '...')
cm(0x82C8, 'Is it "0"?')
d.char_literal(0x82C9)
cm(0x82CA, 'Yes: turn the driver off')
cm(0x82CC, 'Is the driver already on?')
cm(0x82CF, 'Yes: just the mode has changed')
cm(0x82D1, 'X=0: no button change pending')
cm(0x82D4, 'pointer not shown')
cm(0x82D7, 'X=&FF...')
cm(0x82D8, '...the driver is on')
cm(0x82DB, 'OSBYTE &16: increment the ROM polling semaphore,')
cm(0x82DD, 'so that the MOS issues service call &15 every 10 ms')
cm(0x82E0, 'Interrupts off while the hardware and vectors')
cm(0x82E1, 'are set up')
cm(0x82E2, 'Mouse pinout not yet detected')
cm(0x82E4, '...')
cm(0x82E7, 'Mouse mode?')
cm(0x82EA, 'No: disable the mouse interrupts')
cm(0x82EC, 'User VIA PCR: clear bits 4-7, so CB1 and CB2')
cm(0x82EF, 'are inputs that interrupt on a falling edge')
cm(0x82F1, '...')
cm(0x82F4, 'User VIA ACR: clear bits 0-1,')
cm(0x82F7, 'port A and B latching off')
cm(0x82F9, '...')
cm(0x82FC, 'IER: enable the CB1 and CB2 interrupts')
d.expr(0x82FD, 'via_ier_enable_cb1_cb2')
cm(0x82FE, '...')
cm(0x8301, 'DDRB = 0: port B all inputs')
cm(0x8303, '...')
cm(0x8306, 'Go on to place the pointer')
d.label(0x8308, 'disable_mouse_interrupts')
cm(0x8308, 'IER: disable the CB1 and CB2 interrupts')
d.expr(0x8309, 'via_ier_disable_cb1_cb2')
cm(0x830A, '...')
d.label(0x830D, 'centre_pointer')
cm(0x830D, 'Pointer X = 640 (&280)')
d.expr(0x830E, lo(sym('pointer_x_centre')))
cm(0x830F, '...')
cm(0x8312, '...')
d.expr(0x8313, hi(sym('pointer_x_centre')))
cm(0x8314, '...')
cm(0x8317, 'Pointer Y = 512 (&200)')
d.expr(0x8318, lo(sym('pointer_y_centre')))
cm(0x8319, '...')
cm(0x831C, '...')
d.expr(0x831D, hi(sym('pointer_y_centre')))
cm(0x831E, '...')
cm(0x8321, 'OSBYTE &A8: read the address of the extended')
cm(0x8323, 'vector table')
cm(0x8325, '...')
cm(0x8327, '...')
cm(0x832A, 'Keep it in cmd_ptr')
cm(0x832C, '...')
cm(0x832E, 'Save the current BYTEV...')
cm(0x8331, '...')
cm(0x8334, '...')
cm(0x8337, '...')
cm(0x833A, 'BYTEV = &FF0F, the extended vector entry for')
d.expr(0x833B, lo(sym('bytev_extended_entry')))
cm(0x833C, 'BYTEV; &0F is also its offset in the table')
cm(0x833F, '...')
d.expr(0x8340, hi(sym('bytev_extended_entry')))
cm(0x8341, '...')
cm(0x8344, 'Table entry for BYTEV: address of bytev_handler')
d.expr(0x8345, lo(sym('bytev_handler')))
cm(0x8346, '...')
cm(0x8348, '...')
d.expr(0x8349, hi(sym('bytev_handler')))
cm(0x834A, '...')
cm(0x834B, '...')
cm(0x834D, 'and the ROM number, this ROM')
cm(0x834E, '...')
cm(0x8350, '...')
cm(0x8352, 'Save the current IRQ1V; it is also the operand')
cm(0x8355, 'of the JMP ending the trampoline')
cm(0x8358, '...')
cm(0x835B, '...')
cm(0x835E, 'Build the trampoline: JSR...')
d.expr(0x835F, 'opcode_jsr')
cm(0x8360, '...')
cm(0x8363, '&FF06, the extended vector entry for IRQ1V;')
d.expr(0x8364, lo(sym('irq1v_extended_entry')))
cm(0x8365, '&06 is also its offset in the table')
cm(0x8368, '...')
d.expr(0x8369, hi(sym('irq1v_extended_entry')))
cm(0x836A, '...')
cm(0x836D, 'then JMP (to the old IRQ1V handler)')
d.expr(0x836E, 'opcode_jmp')
cm(0x836F, '...')
cm(0x8372, 'IRQ1V = the trampoline')
d.expr(0x8373, lo(sym('irq1v_trampoline')))
cm(0x8374, '...')
cm(0x8377, '...')
d.expr(0x8378, hi(sym('irq1v_trampoline')))
cm(0x8379, '...')
cm(0x837C, 'Table entry for IRQ1V: address of irq_handler')
d.expr(0x837D, lo(sym('irq_handler')))
cm(0x837E, '...')
cm(0x8380, '...')
cm(0x8381, '...')
d.expr(0x8382, hi(sym('irq_handler')))
cm(0x8383, '...')
cm(0x8385, '...')
cm(0x8386, 'and the ROM number, this ROM')
cm(0x8388, '...')
cm(0x838A, 'Interrupts back as they were')
cm(0x838B, 'Return')

# ---------------------------------------------------------------------------
# *POINTER
# ---------------------------------------------------------------------------

d.subroutine(0x838C, 'cmd_pointer',
    title='*POINTER: show or remove the pointer',
    description="""Record the screen format for the current mode, then act on the first
argument character:

| Argument | Effect |
|----------|--------|
| 0 | Remove the pointer |
| 2 | Disable the mouse interrupts and remove the pointer |
| anything else, or none | Show the pointer |

The screen format is 0, 1 or 2 in MODEs 0, 1 and 2, and 3 or 4 in MODEs
4 and 5 (a shadow mode counts as its non-shadow equivalent). In MODEs 3,
6 and 7, which have no pointer images, the command does nothing.

Showing the pointer needs the driver to be on, and does nothing if the
pointer is already shown. It enables the mouse interrupts if the device
is the mouse and disables them otherwise, builds the four shifted
copies of the pointer image and mask for the screen format, and draws
the pointer.""")
cm(0x838C, 'OSBYTE &87: read the screen mode into Y')
cm(0x838E, '...')
cm(0x8391, 'Mode number...')
cm(0x8392, '...ignoring the shadow bit')
cm(0x8394, 'MODE 0, 1 or 2?')
cm(0x8396, 'Yes: screen format = mode')
cm(0x8398, 'MODE 3?')
cm(0x839A, 'Yes: no pointer in a text mode')
cm(0x839C, 'MODE 6 or 7?')
cm(0x839E, 'Yes: no pointer in a text mode')
cm(0x83A0, 'MODE 4 or 5: screen format 3 or 4')
d.label(0x83A1, 'set_screen_format')
cm(0x83A1, 'Record the screen format')
cm(0x83A4, 'First argument character...')
cm(0x83A7, '...')
cm(0x83A9, 'as a digit')
cm(0x83AA, '...')
d.char_literal(0x83AB)
cm(0x83AC, '0: remove the pointer')
cm(0x83AE, '2?')
cm(0x83B0, 'Yes: disable the mouse, remove the pointer')
cm(0x83B2, 'Show it: is the driver on?')
cm(0x83B5, 'No: nothing to do')
cm(0x83B7, 'Is the pointer already shown?')
cm(0x83BA, 'Yes: nothing to do')
cm(0x83BC, '&FF...')
cm(0x83BF, '...the pointer is shown')
cm(0x83C2, 'and nothing has been drawn yet (bit 7 set)')
cm(0x83C4, 'Mouse mode?')
cm(0x83C7, 'No: disable the mouse interrupts')
cm(0x83C9, 'Yes: enable them')
d.expr(0x83CA, 'via_ier_enable_cb1_cb2')
cm(0x83CB, '...')
d.label(0x83CD, 'pointer_mouse_interrupts_off')
cm(0x83CD, 'Disable the CB1 and CB2 interrupts')
d.expr(0x83CE, 'via_ier_disable_cb1_cb2')
d.label(0x83CF, 'set_mouse_interrupts')
cm(0x83CF, '...')
cm(0x83D2, 'Build the shifted pointer images and masks')
cm(0x83D4, '...')
cm(0x83D7, 'Make drawn_x differ from pointer_x...')
cm(0x83DA, '...')
cm(0x83DB, '...so that the pointer is drawn')
cm(0x83DE, 'Draw it')
d.label(0x83E1, 'return_from_pointer')
cm(0x83E1, 'Return')

d.subroutine(0x83E2, 'remove_pointer_and_mouse',
    title='Disable the mouse interrupts and remove the pointer',
    description="""Disable the User VIA's CB1 and CB2 interrupts, then remove the pointer
(remove_pointer).""")
cm(0x83E2, 'Disable the CB1 and CB2 interrupts')
d.expr(0x83E3, 'via_ier_disable_cb1_cb2')
cm(0x83E4, '...')

d.subroutine(0x83E7, 'remove_pointer',
    title='Remove the pointer from the screen',
    description="""If the pointer is shown, put back the screen bytes it covers and mark
it not shown. Main-memory accesses are pointed at the same RAM as the
VDU drivers while this is done (see update_pointer), and ACCCON is then
restored.""")
cm(0x83E7, 'Is the pointer shown?')
cm(0x83EA, 'No: nothing to do')
cm(0x83EC, 'Save ACCCON')
cm(0x83EF, '...')
cm(0x83F2, 'Clear X (main memory, not shadow, at &3000)')
cm(0x83F4, 'Are the VDU drivers using shadow RAM (E)?')
d.expr(0x83F5, 'acccon_e')
cm(0x83F6, 'No')
cm(0x83F8, 'Yes: access shadow RAM too (set X)')
d.expr(0x83F9, 'acccon_x')
d.label(0x83FA, 'remove_pointer_set_acccon')
cm(0x83FA, '...')
cm(0x83FD, 'Put back the screen under the pointer')
cm(0x8400, 'Restore ACCCON')
cm(0x8403, '...')
cm(0x8406, 'The pointer is not shown')
cm(0x8409, 'Return')

# ---------------------------------------------------------------------------
# Drawing the pointer
# ---------------------------------------------------------------------------

d.subroutine(0x840A, 'update_pointer',
    title='Redraw the pointer if it has moved',
    description="""Restart the redraw countdown, and if the pointer has moved since it was
last drawn, move it: put back the screen under it at the old position,
then draw it at the new one.

The pointer image is 4 screen bytes wide and 16 pixel rows high, held as
4 columns of 16 bytes. Its top left corner is the hot spot (hotspot_x,
hotspot_y) left of and above (pointer_x, pointer_y). The image used is the
one of the four shifted copies (see build_pointer_images) that matches
how far into a screen byte the left edge falls, so the pointer moves in
steps finer than a byte.

Each screen byte is saved in screen_under_pointer, then ANDed with the
mask and ORed with the image. Columns left of the screen or bytes below
its bottom are skipped; drawing stops at the first column right of the
screen; rows above the top of the screen are skipped.

During drawing, main-memory accesses are switched to the RAM the VDU
drivers are using: ACCCON bit X (main memory at &3000-&7FFF is shadow
RAM) is set to match bit E (VDU driver accesses go to shadow RAM), so the
pointer is drawn on the screen being written in both shadow and normal
modes. ACCCON is restored afterwards, through saved_acccon, which is also
the last byte of saved_zero_page (see the workspace notes).

Called from cmd_pointer, and from poll_redraw_and_buttons when the
countdown expires.""",
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'corrupted'})
cm(0x840A, 'Next redraw in 10 polls')
d.expr(0x840B, 'redraw_interval')
cm(0x840C, '...')
cm(0x840F, 'Has the pointer moved since it was drawn?')
cm(0x8412, '...')
cm(0x8415, 'Yes')
cm(0x8417, '...')
cm(0x841A, '...')
cm(0x841D, 'Yes')
cm(0x841F, '...')
cm(0x8422, '...')
cm(0x8425, 'Yes')
cm(0x8427, '...')
cm(0x842A, '...')
cm(0x842D, 'No: nothing to do')
d.label(0x842F, 'move_pointer_on_screen')
cm(0x842F, 'Save ACCCON')
cm(0x8432, '...')
cm(0x8435, 'Clear X (main memory, not shadow, at &3000)')
cm(0x8437, 'Are the VDU drivers using shadow RAM (E)?')
d.expr(0x8438, 'acccon_e')
cm(0x8439, 'No')
cm(0x843B, 'Yes: access shadow RAM too (set X)')
d.expr(0x843C, 'acccon_x')
d.label(0x843D, 'draw_set_acccon')
cm(0x843D, '...')
cm(0x8440, 'Record the position being drawn...')
cm(0x8443, '...')
cm(0x8446, '...')
cm(0x8449, '...')
cm(0x844C, '...')
cm(0x844F, '...')
cm(0x8452, '...')
cm(0x8455, '...')
cm(0x8458, '(X is set again below)')
cm(0x845A, 'Left edge = pointer_x - hot spot X')
cm(0x845D, '...')
cm(0x845E, '...')
cm(0x8461, '...')
cm(0x8464, '...')
cm(0x8467, '...')
cm(0x8469, '...')
cm(0x846C, 'Top edge = pointer_y + hot spot Y')
cm(0x846F, '...')
cm(0x8470, '...')
cm(0x8473, '...')
cm(0x8476, '...')
cm(0x8479, '...')
cm(0x847B, '...')
cm(0x847E, 'Screen address of the top left, and the shift')
cm(0x8481, 'zp_image_ptr = the image copy for the shift:')
cm(0x8483, 'page +1 of the workspace...')
cm(0x8486, '...')
cm(0x8487, '...')
cm(0x8489, 'plus the copy\'s offset')
cm(0x848C, '...')
cm(0x848E, 'Put back the screen under the old pointer')
cm(0x8491, 'Remember the new left edge for removing it')
cm(0x8494, '...')
cm(0x8497, '...')
cm(0x849A, '...')
cm(0x849D, 'Push the screen address twice: the top copy')
cm(0x849F, 'steps along the columns, the bottom one is')
cm(0x84A0, 'kept as the address of the drawn pointer')
cm(0x84A2, '...')
cm(0x84A3, '...')
cm(0x84A5, '...')
cm(0x84A6, '...')
cm(0x84A8, '...')
cm(0x84A9, 'Start at image byte 0')
cm(0x84AB, '...')
d.label(0x84AD, 'draw_char_row')
cm(0x84AD, 'Start at the address\'s own pixel row')
cm(0x84AF, '...')
cm(0x84B1, 'Address &8000 or above (below the screen)?')
cm(0x84B3, 'Yes: skip the rest of this column')
cm(0x84B5, 'Below the start of screen memory (above it)?')
cm(0x84B8, 'Yes: skip rows to the next character row')
cm(0x84BA, 'Is this column left of the screen?')
cm(0x84BD, 'Yes: skip the column')
cm(0x84BF, 'Is it right of the screen (X >= 1280)?')
cm(0x84C1, 'Yes: stop drawing')
d.label(0x84C3, 'draw_pixel_row')
cm(0x84C3, 'Screen byte...')
cm(0x84C5, '...')
cm(0x84C7, 'saved in the buffer')
cm(0x84C9, '...')
cm(0x84CB, 'AND with the mask, one page above the image')
cm(0x84CD, '...')
cm(0x84CF, '...')
cm(0x84D1, 'OR in the image')
cm(0x84D3, 'and put it on the screen')
cm(0x84D5, '...')
cm(0x84D7, 'Next image byte')
cm(0x84D9, 'All 16 rows of this column done?')
cm(0x84DB, '...')
cm(0x84DD, 'Yes: next column')
cm(0x84DF, 'Next pixel row down')
cm(0x84E1, 'Still in the same character row?')
cm(0x84E3, '...')
cm(0x84E4, '...')
cm(0x84E6, '...')
cm(0x84E8, 'Yes: draw it')
d.label(0x84EA, 'draw_next_char_row')
cm(0x84EA, 'Down a character row: back to its top byte...')
cm(0x84ED, '...')
cm(0x84EF, '...')
cm(0x84F1, '...')
cm(0x84F2, 'plus the bytes in a character row')
cm(0x84F5, '...')
cm(0x84F7, '...')
cm(0x84F9, '...')
cm(0x84FC, '...')
cm(0x84FE, 'Draw that row')
d.label(0x8500, 'draw_skip_rows_above_screen')
cm(0x8500, 'Above the screen: skip as many image rows as')
cm(0x8502, 'the address\'s pixel row within the character')
cm(0x8504, '...')
cm(0x8505, '...')
cm(0x8507, '...')
cm(0x8509, 'and try the next character row')
d.label(0x850B, 'draw_skip_column')
cm(0x850B, 'Skip to the next column of the image')
cm(0x850D, '...')
cm(0x850F, '...')
cm(0x8510, '...')
cm(0x8512, '...')
d.label(0x8514, 'draw_next_column')
cm(0x8514, 'Move the left edge right one screen byte')
cm(0x8517, '...')
cm(0x851A, '...')
cm(0x851B, '...')
cm(0x851E, '...')
cm(0x8521, '...')
cm(0x8523, '...')
d.label(0x8526, 'draw_next_column_address')
cm(0x8526, 'Next column\'s screen address: 8 bytes on')
cm(0x8527, '...')
cm(0x8528, '...')
cm(0x852A, '...')
cm(0x852C, '...')
cm(0x852D, '...')
cm(0x852F, '...')
cm(0x8531, 'kept on the stack')
cm(0x8532, '...')
cm(0x8534, '...')
cm(0x8535, 'All four columns done?')
cm(0x8537, '...')
cm(0x8539, 'Yes: finish')
cm(0x853B, 'No: draw the next column')
d.label(0x853E, 'finish_drawing')
cm(0x853E, 'Drop the column address')
cm(0x853F, '...')
cm(0x8540, 'The pointer is now drawn at the address...')
cm(0x8541, '...')
cm(0x8543, '...')
cm(0x8544, '...')
cm(0x8546, 'Restore ACCCON')
cm(0x8549, '...')
cm(0x854C, 'Return')

# ---------------------------------------------------------------------------
# Entering and leaving the driver
# ---------------------------------------------------------------------------

d.subroutine(0x854D, 'leave_driver',
    title='Leave the driver: restore zero page and store the workspace',
    description="""The partner of enter_driver. Keep zp_drawn_ptr in saved_drawn_ptr,
restore the caller's zero page &84-&90 from saved_zero_page, and fall
into exchange_workspace to store the workspace at &9440.

The 13th byte restored, &90, is saved_acccon, so if the pointer was
drawn or removed since enter_driver, &90 is left holding ACCCON.""",
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'preserved'})
cm(0x854D, 'Keep the drawn pointer\'s address')
cm(0x854F, '...')
cm(0x8552, '...')
cm(0x8554, '...')
cm(0x8557, 'Restore zero page &84-&90')
d.label(0x8559, 'restore_zero_page')
cm(0x8559, '...')
cm(0x855C, '...')
cm(0x855E, '...')
cm(0x855F, '...')

d.subroutine(0x8561, 'exchange_workspace',
    title='Exchange the working and stored copies of the workspace',
    description="""Swap the 48 bytes at &9000-&902F with the 48 bytes at offset &40 in
page +3 of the private workspace (rom_workspace_table, set to &91, so
&9440-&946F).

Every way into the driver calls this on the way in and again on the way
out, so the driver's state is at &9000 while it runs and at &9440 in
between. enter_driver and leave_driver do this for the commands and the
polls; bytev_handler calls it directly; irq_handler exchanges only the
first ten bytes (exchange_position_workspace).

&9030-&9037 (the device mode, the speeds and the desktop colours) are
not exchanged.""",
    on_exit={'A': 'preserved', 'X': 'preserved', 'Y': 'preserved'})
cm(0x8561, 'Save A')
cm(0x8562, 'X')
cm(0x8563, 'and Y')
cm(0x8564, 'and the zero page pointer used')
cm(0x8566, '...')
cm(0x8567, '...')
cm(0x8569, '...')
cm(0x856A, 'Point it at the stored copy: page +3...')
cm(0x856C, '...')
cm(0x856F, '...')
cm(0x8570, '...')
cm(0x8572, '...')
cm(0x8574, 'offset &40')
cm(0x8576, '...')
cm(0x8578, '48 bytes, from the last')
d.label(0x857A, 'exchange_workspace_byte')
cm(0x857A, 'Working byte')
cm(0x857D, 'Stored byte...')
cm(0x857F, '...becomes the working byte')
cm(0x8582, 'Working byte...')
cm(0x8583, '...becomes the stored byte')
cm(0x8585, 'Next')
cm(0x8586, '...')
cm(0x8588, 'Restore the zero page pointer')
cm(0x8589, '...')
cm(0x858B, '...')
cm(0x858C, '...')
cm(0x858E, 'Restore Y')
cm(0x858F, 'X')
cm(0x8590, 'and A')
cm(0x8591, 'Return')

d.subroutine(0x8592, 'enter_driver',
    title='Enter the driver: bring in the workspace and save zero page',
    description="""Bring the stored workspace into &9000 (exchange_workspace), save the
caller's zero page &84-&90 in saved_zero_page, and load zp_drawn_ptr from
saved_drawn_ptr. Called with interrupts disabled. leave_driver undoes it.""",
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'preserved'})
cm(0x8592, 'Bring in the workspace')
cm(0x8595, 'Save zero page &84-&90')
d.label(0x8597, 'save_zero_page')
cm(0x8597, '...')
cm(0x8599, '...')
cm(0x859C, '...')
cm(0x859D, '...')
cm(0x859F, 'Load the drawn pointer\'s address')
cm(0x85A2, '...')
cm(0x85A4, '...')
cm(0x85A7, '...')
d.label(0x85A9, 'return_from_enter_driver')
cm(0x85A9, 'Return')

d.subroutine(0x85AA, 'restore_screen_under_pointer',
    title='Put back the screen under the pointer',
    description="""Copy the 64 bytes saved in screen_under_pointer back to the screen at
zp_drawn_ptr, column by column, with the same clipping as update_pointer
and using drawn_left for the column positions. Nothing is done if bit 7
of zp_drawn_ptr's high byte is set (no pointer drawn).

zp_drawn_ptr and drawn_left are stepped along as it works, so they no
longer describe the pointer afterwards.

For rows above the top of the screen, the number of rows to skip is
added to X instead of to the buffer index, so the index is not advanced.
While pointer_y is within its range (at most 1020), the count is always
0 and this makes no difference.""",
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'corrupted'})
cm(0x85AA, 'zp_under_ptr = the saved-screen buffer,')
cm(0x85AC, 'page +3 of the workspace')
cm(0x85AF, '...')
cm(0x85B0, '...')
cm(0x85B2, '...')
cm(0x85B4, '...')
cm(0x85B6, 'Is a pointer drawn?')
cm(0x85B8, 'No: nothing to put back')
cm(0x85BA, 'Push its screen address, to step along')
cm(0x85BB, 'the columns')
cm(0x85BD, '...')
cm(0x85BE, 'Start at buffer byte 0')
cm(0x85C0, '...')
d.label(0x85C2, 'restore_char_row')
cm(0x85C2, 'Start at the address\'s own pixel row')
cm(0x85C4, '...')
cm(0x85C6, 'Address &8000 or above (below the screen)?')
cm(0x85C8, 'Yes: skip the rest of this column')
cm(0x85CA, 'Below the start of screen memory (above it)?')
cm(0x85CD, 'Yes: go to the next character row')
cm(0x85CF, 'Is this column left of the screen?')
cm(0x85D2, 'Yes: skip the column')
cm(0x85D4, 'Is it right of the screen (X >= 1280)?')
cm(0x85D6, 'Yes: stop')
d.label(0x85D8, 'restore_pixel_row')
cm(0x85D8, 'Saved byte...')
cm(0x85DA, '...')
cm(0x85DC, '...back on the screen')
cm(0x85DE, '...')
cm(0x85E0, 'Next saved byte')
cm(0x85E2, 'All 16 rows of this column done?')
cm(0x85E4, '...')
cm(0x85E6, 'Yes: next column')
cm(0x85E8, 'Next pixel row down')
cm(0x85EA, 'Still in the same character row?')
cm(0x85EC, '...')
cm(0x85ED, '...')
cm(0x85EF, '...')
cm(0x85F1, 'Yes: put it back')
d.label(0x85F3, 'restore_next_char_row')
cm(0x85F3, 'Down a character row: back to its top byte...')
cm(0x85F6, '...')
cm(0x85F8, '...')
cm(0x85FA, '...')
cm(0x85FB, 'plus the bytes in a character row')
cm(0x85FE, '...')
cm(0x8600, '...')
cm(0x8602, '...')
cm(0x8605, '...')
cm(0x8607, 'Restore that row')
d.label(0x860A, 'restore_next_column')
cm(0x860A, 'Move the left edge right one screen byte')
cm(0x860D, '...')
cm(0x8610, '...')
cm(0x8611, '...')
cm(0x8614, '...')
cm(0x8617, '...')
cm(0x8619, '...')
d.label(0x861C, 'restore_next_column_address')
cm(0x861C, 'Next column\'s screen address: 8 bytes on')
cm(0x861D, '...')
cm(0x861E, '...')
cm(0x8620, '...')
cm(0x8622, '...')
cm(0x8623, '...')
cm(0x8625, '...')
cm(0x8627, 'kept on the stack')
cm(0x8628, '...')
cm(0x862A, '...')
cm(0x862B, 'All four columns done?')
cm(0x862D, '...')
cm(0x862F, 'No: restore the next column')
d.label(0x8631, 'finish_restoring')
cm(0x8631, 'Drop the column address')
cm(0x8632, '...')
cm(0x8633, 'Return')
d.label(0x8634, 'restore_skip_column')
cm(0x8634, 'Skip to the next column of the buffer')
cm(0x8636, '...')
cm(0x8638, '...')
cm(0x8639, '...')
cm(0x863B, '...')
cm(0x863D, '...')
d.label(0x8640, 'restore_skip_rows_above_screen')
cm(0x8640, 'Above the screen: rows to skip = the pixel row')
cm(0x8642, 'within the character row')
cm(0x8644, '...')
cm(0x8646, 'added to X, which is not used: the buffer')
cm(0x8647, 'index is not advanced')
cm(0x8648, '...')
cm(0x864A, '...')
cm(0x864B, 'Try the next character row')

# ---------------------------------------------------------------------------
# Building the shifted pointer images
# ---------------------------------------------------------------------------

d.label(0x864E, 'pointer_format_offsets')
d.banner(0x864E, title='Offsets of each screen format\'s pointer image and mask',
    description="""Low and high bytes of the offset, from pointer_images and from
pointer_masks, of the 64-byte image and mask for each screen format:
&000, &040, &080, &0C0 and &100 for formats 0-4. The sixth entry (&140)
is not used.""")
d.byte(0x864E, 6)
cm(0x864E, 'Low bytes, formats 0-5')
d.label(0x8654, 'pointer_format_offsets_hi')
d.byte(0x8654, 6)
cm(0x8654, 'High bytes, formats 0-5')

d.subroutine(0x865A, 'build_pointer_images',
    title='Build the shifted pointer images and masks',
    description="""Copy the 64-byte pointer image and mask for the current screen format
from the ROM into the bank, at pointer_image_copies (page +1 of the
workspace) and pointer_mask_copies (page +2), then build three more
copies of each after it, each shifted right by a further quarter of a
screen byte (build_shifted_copies). update_pointer picks the copy that
matches the pointer's position within a screen byte.

The images are laid out as 4 byte columns of 16 rows each. A selects a
byte offset into the format's image and mask; cmd_pointer always passes
0.""",
    on_entry={'A': 'offset into the image and mask (0)',
              'screen_format': 'which image and mask to use'},
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'corrupted'})
cm(0x865A, 'Record the offset')
cm(0x865D, '...')
cm(0x865E, 'For this screen format:')
cm(0x8661, 'source image = pointer_images + format offset')
d.expr(0x8662, 'pointer_format_offsets')
cm(0x8664, '...')
cm(0x8665, '...')
d.expr(0x8666, lo(sym('pointer_images')))
cm(0x8667, '...')
cm(0x8669, '...')
d.expr(0x866A, 'pointer_format_offsets_hi')
cm(0x866C, '...')
d.expr(0x866D, hi(sym('pointer_images')))
cm(0x866E, '...')
cm(0x8670, 'source mask = pointer_masks + format offset')
d.expr(0x8671, 'pointer_format_offsets')
cm(0x8673, '...')
cm(0x8674, '...')
d.expr(0x8675, lo(sym('pointer_masks')))
cm(0x8676, '...')
cm(0x8678, '...')
d.expr(0x8679, 'pointer_format_offsets_hi')
cm(0x867B, '...')
d.expr(0x867C, hi(sym('pointer_masks')))
cm(0x867D, '...')
cm(0x867F, 'Destination: page +1 of the workspace')
cm(0x8681, '...')
cm(0x8684, '...')
cm(0x8685, '...')
cm(0x8687, '...')
cm(0x8689, 'Source index starts at the offset')
cm(0x868B, 'Destination index starts at 0')
cm(0x868D, '...')
d.label(0x868F, 'copy_image_and_mask_byte')
cm(0x868F, 'Image byte...')
cm(0x8691, '...')
cm(0x8693, '...to page +1')
cm(0x8695, '...')
cm(0x8697, 'Mask byte...')
cm(0x8699, '...')
cm(0x869B, '...')
cm(0x869D, '...to page +2')
cm(0x869F, '...')
cm(0x86A1, '...')
cm(0x86A3, 'Next source byte')
cm(0x86A5, 'Next destination byte')
cm(0x86A7, 'All 64 copied?')
cm(0x86A9, '...')
d.expr(0x86AA, 'pointer_image_size')
cm(0x86AB, 'No: copy the next')
cm(0x86AD, 'Shift the image: from offset &00 of page +1...')
cm(0x86AF, 'to offset &40')
cm(0x86B1, '...')
cm(0x86B3, '...')
cm(0x86B5, '...')
cm(0x86B8, '...')
cm(0x86B9, '...')
cm(0x86BB, '...')
cm(0x86BD, 'shifting in 0 bits (transparent in an image)')
cm(0x86BF, '...')
cm(0x86C1, 'Build the three shifted image copies')
cm(0x86C4, 'Then the mask: from offset &00 of page +2...')
cm(0x86C6, 'to offset &40')
cm(0x86C8, '...')
cm(0x86CA, '...')
cm(0x86CC, '...')
cm(0x86CF, '...')
cm(0x86D0, '...')
cm(0x86D2, '...')
cm(0x86D4, '...')
cm(0x86D6, 'shifting in 1 bits (transparent in a mask)')

d.subroutine(0x86D8, 'build_shifted_copies',
    title='Build three shifted copies of an image or mask',
    description="""From the 64-byte copy at zp_image_ptr, build three copies, each a
quarter of a screen byte further right, at zp_under_ptr, zp_under_ptr+&40
and zp_under_ptr+&80. Bits shifted in at the left are zp_temp's (0 for an
image, 1 for a mask). How far a quarter byte is depends on the screen
format:

| Format | MODE | Pixels per byte | Each copy is |
|--------|------|-----------------|--------------|
| 0, 3 | 0, 4 | 8 | 2 pixels further right |
| 1, 4 | 1, 5 | 4 | 1 pixel further right |
| 2 | 2 | 2 | half a pixel: copies are 0, 0, 1 and 1 pixel right |""",
    on_entry={'zp_image_ptr': 'unshifted copy',
              'zp_under_ptr': 'where the first shifted copy goes',
              'zp_temp': '&00 (image) or &FF (mask)'})
cm(0x86D8, 'Screen format 0 or 3 (two colours)?')
cm(0x86DB, 'Yes')
cm(0x86DD, '...')
cm(0x86DF, '...')
cm(0x86E1, 'Format 1 or 4 (four colours)?')
cm(0x86E3, 'Yes')
cm(0x86E5, '...')
cm(0x86E7, '...')
cm(0x86E9, 'Format 2 (sixteen colours)')
d.label(0x86EC, 'build_4colour_copies')
cm(0x86EC, 'First copy, 1 pixel right')
cm(0x86EF, 'Second copy, 2 pixels right')

d.subroutine(0x86F2, 'shift_4colour_copy',
    title='Make the next copy one 4-colour pixel further right',
    description="""Shift the 64-byte copy at zp_image_ptr right by one pixel into
zp_under_ptr, for MODEs 1 and 5, where a byte holds 4 pixels with the
two bits of pixel n in bits 7-n and 3-n. Each of the 16 rows is shifted
across its 4 bytes, carrying the rightmost pixel of each byte into the
leftmost of the next. Only the pixel's low colour bit is carried: for an
image the high bit of the pixel shifted in is 0, for a mask it is a copy
of the low bit, which is right for images drawn in colours 0 and 1 and
for masks whose pixels are all-0 or all-1. Then step on to the next copy
(advance_to_next_copy).""")
cm(0x86F2, 'Row 0')
d.label(0x86F4, 'shift_4colour_row')
cm(0x86F4, 'Carry = the fill bit: 1 for a mask...')
cm(0x86F6, '...')
cm(0x86F8, 'Column 0')
cm(0x86FA, 'Carry into the first byte of the row')
d.label(0x86FB, 'shift_4colour_byte')
cm(0x86FB, 'Byte index = column * 16 + row')
cm(0x86FD, '...')
cm(0x86FE, '...')
cm(0x8700, '...')
cm(0x8701, 'Source byte')
cm(0x8703, 'Carry from the byte to the left')
cm(0x8704, 'Set: put it in bit 4 (becomes bit 3)')
cm(0x8706, 'Clear: clear bit 4')
cm(0x8708, 'Always taken (carry clear)')
d.label(0x870A, 'shift_4colour_set_bit4')
cm(0x870A, '...')
d.label(0x870C, 'shift_4colour_high_bit')
cm(0x870C, 'Mask: keep the carry for bit 7')
cm(0x870E, '...')
cm(0x8710, 'Image: bit 7 = 0')
d.label(0x8711, 'shift_4colour_rotate')
cm(0x8711, 'Shift right one pixel; carry = old bit 0')
cm(0x8712, 'Keep the carry for the next byte')
cm(0x8713, 'Store the shifted byte')
cm(0x8715, 'Next column...')
cm(0x8717, '...')
cm(0x8718, '...')
cm(0x871A, 'of the 4')
cm(0x871C, '...')
cm(0x871E, 'Drop the last carry')
cm(0x871F, 'Next row...')
cm(0x8720, 'of the 16')
cm(0x8722, '...')

d.subroutine(0x8724, 'advance_to_next_copy',
    title='Step on to the next shifted copy',
    description="""Make the copy just built the source, and the next 64 bytes the
destination.""")
cm(0x8724, 'Source = the copy just built...')
cm(0x8726, '...')
cm(0x8728, '...')
cm(0x872A, '...')
cm(0x872C, 'Destination = 64 bytes further on')
cm(0x872D, '...')
d.expr(0x872E, 'pointer_image_size')
cm(0x872F, '...')
cm(0x8731, '...')
cm(0x8733, '...')
d.label(0x8735, 'return_from_shifting')
cm(0x8735, 'Return')

d.label(0x8736, 'build_2colour_copies')
cm(0x8736, 'First copy, 2 pixels right')
cm(0x8739, 'Second copy, 4 pixels right')

d.subroutine(0x873C, 'shift_2colour_copy',
    title='Make the next copy two 2-colour pixels further right',
    description="""For MODEs 0 and 4, where a byte holds 8 pixels: shift the copy at
zp_image_ptr right one pixel into zp_under_ptr, then shift that right
one more pixel in place, then step on to the next copy.""")
cm(0x873C, 'Shift right one pixel into the destination')
cm(0x873F, 'Then shift the destination in place...')
cm(0x8741, '...')
cm(0x8743, '...')
cm(0x8745, '...')
cm(0x8747, 'by one more pixel')
cm(0x874A, 'Step on to the next copy')

d.subroutine(0x874D, 'shift_2colour_pixel',
    title='Shift a 2-colour copy right one pixel',
    description="""Shift each of the 16 rows of the copy at zp_image_ptr right one bit,
across its 4 bytes, into zp_under_ptr, shifting in zp_temp's fill bit at
the left.""")
cm(0x874D, 'Row 0')
d.label(0x874F, 'shift_2colour_row')
cm(0x874F, 'Carry = the fill bit: 1 for a mask...')
cm(0x8751, '...')
cm(0x8753, 'Column 0')
cm(0x8755, 'Carry into the first byte of the row')
d.label(0x8756, 'shift_2colour_byte')
cm(0x8756, 'Byte index = column * 16 + row')
cm(0x8758, '...')
cm(0x8759, '...')
cm(0x875B, '...')
cm(0x875C, 'Source byte')
cm(0x875E, 'Carry from the byte to the left')
cm(0x875F, 'Shift right one pixel')
cm(0x8760, 'Keep the carry for the next byte')
cm(0x8761, 'Store the shifted byte')
cm(0x8763, 'Next column...')
cm(0x8765, '...')
cm(0x8766, '...')
cm(0x8768, 'of the 4')
cm(0x876A, '...')
cm(0x876C, 'Drop the last carry')
cm(0x876D, 'Next row...')
cm(0x876E, 'of the 16')
cm(0x8770, '...')
cm(0x8772, 'Return')

d.label(0x8773, 'build_16colour_copies')
cm(0x8773, 'First copy: unshifted')
cm(0x8776, 'Second copy: one pixel right')
cm(0x8779, 'Third copy: the same as the second')

d.subroutine(0x877C, 'shift_16colour_copy',
    title='Make the next copy one 16-colour pixel further right',
    description="""For MODE 2, where a byte holds 2 pixels with the bits of the left pixel
in bits 7, 5, 3 and 1 and the right pixel in bits 6, 4, 2 and 0: move
the left pixel of each byte to the right, and bring in the right pixel
of the byte to the left as the new left pixel. Only that pixel's lowest
colour bit is carried: if it is set, a mask's new pixel is all ones and
an image's is colour 1; otherwise it is 0. The first byte of each row
takes the fill bit. Then step on to the next copy.""")
cm(0x877C, 'Row 0')
d.label(0x877E, 'shift_16colour_row')
cm(0x877E, 'Carry = the fill bit: 1 for a mask...')
cm(0x8780, '...')
cm(0x8782, 'Column 0')
cm(0x8784, 'Carry into the first byte of the row')
d.label(0x8785, 'shift_16colour_byte')
cm(0x8785, 'Byte index = column * 16 + row')
cm(0x8787, '...')
cm(0x8788, '...')
cm(0x878A, '...')
cm(0x878B, 'Source byte: its left pixel...')
cm(0x878D, '...')
cm(0x878F, '...moves to the right')
cm(0x8790, 'Was the left neighbour\'s right pixel set?')
cm(0x8791, 'No: new left pixel is 0')
cm(0x8793, 'Yes: for a mask...')
cm(0x8795, '...')
cm(0x8797, '...the new left pixel is all ones')
d.label(0x8799, 'shift_16colour_set_pixel')
cm(0x8799, 'For an image, colour 1')
d.label(0x879B, 'shift_16colour_store')
cm(0x879B, 'Store the shifted byte')
cm(0x879D, 'This byte\'s right pixel...')
cm(0x879F, '...')
cm(0x87A1, '...lowest bit into the carry')
cm(0x87A2, 'Keep it for the next byte')
cm(0x87A3, 'Next column...')
cm(0x87A5, '...')
cm(0x87A6, '...')
cm(0x87A8, 'of the 4')
cm(0x87AA, '...')
cm(0x87AC, 'Drop the last carry')
cm(0x87AD, 'Next row...')
cm(0x87AE, 'of the 16')
cm(0x87B0, '...')
cm(0x87B2, 'Step on to the next copy')

d.subroutine(0x87B5, 'copy_unshifted',
    title='Make the next copy the same as the last',
    description="""Copy the 64 bytes at zp_image_ptr to zp_under_ptr, then step on to the
next copy. Used in MODE 2, where a quarter-byte step is half a pixel.""")
cm(0x87B5, '64 bytes')
d.label(0x87B7, 'copy_unshifted_byte')
cm(0x87B7, 'Copy a byte')
cm(0x87B9, '...')
cm(0x87BB, 'Next')
cm(0x87BC, '...')
cm(0x87BE, 'Step on to the next copy')

# ---------------------------------------------------------------------------
# BYTEV: ADVAL
# ---------------------------------------------------------------------------

d.subroutine(0x87C1, 'bytev_handler',
    title='OSBYTE handler: ADVAL(5) to ADVAL(9)',
    description="""Reached through BYTEV, by way of the extended vector entry, for every
OSBYTE call while the driver is on. OSBYTE &80 (ADVAL) with X from 5 to 9
is answered here; every other call goes on to the previous BYTEV.

| X | ADVAL | Returns in X (low) and Y (high) |
|---|-------|---------------------------------|
| 5 | ADVAL(5) | *TMAX x |
| 6 | ADVAL(6) | *TMAX y |
| 7 | ADVAL(7) | pointer X, 0-1276 |
| 8 | ADVAL(8) | pointer Y, 0-1020 |
| 9 | ADVAL(9) | device mode (0, &20, &40 or &80) |

ADVAL(0)-(4), and channels 10 and above, remain the MOS's.

For channels 5-8 the stored workspace is brought in to read the value
and put back, with interrupts disabled. The device mode is outside the
exchanged area and is read directly. Channels 5-8 return with A=&80 and
V clear; channel 9 returns with A=&80 and V unchanged.""",
    on_entry={'A': 'OSBYTE number', 'X': 'first parameter (ADVAL channel)'},
    on_exit={'A': '&80', 'X': 'value, low byte', 'Y': 'value, high byte'})
cm(0x87C1, 'OSBYTE &80 (ADVAL)?')
d.expr(0x87C2, 'osbyte_read_adc')
cm(0x87C3, 'Yes')
d.label(0x87C5, 'pass_to_previous_bytev')
cm(0x87C5, 'No: on to the previous OSBYTE handler')
d.label(0x87C8, 'bytev_adval')
cm(0x87C8, 'ADVAL(9)?')
cm(0x87CA, 'Yes: return the device mode')
cm(0x87CC, 'Channel 10 and up (or negative): not ours')
cm(0x87CE, 'Channel 4 or below?')
cm(0x87D0, 'Yes: not ours')
cm(0x87D2, 'Save the flags and disable interrupts')
cm(0x87D3, '...')
cm(0x87D4, 'Bring in the workspace')
cm(0x87D7, 'Offset = 2 * channel - 10...')
cm(0x87D8, '...(ASL leaves carry clear)')
cm(0x87D9, '...')
cm(0x87DB, '...')
cm(0x87DC, 'Value low byte')
cm(0x87DF, '...into X')
cm(0x87E0, 'Value high byte')
cm(0x87E1, '...')
cm(0x87E4, '...into Y')
cm(0x87E5, 'Put the workspace back')
cm(0x87E8, 'Restore the flags')
d.label(0x87E9, 'return_adval')
cm(0x87E9, 'A = &80, as for OSBYTE &80')
cm(0x87EB, 'V clear')
cm(0x87EC, 'Return to the OSBYTE caller')
d.label(0x87ED, 'read_device_mode')
cm(0x87ED, 'High byte 0')
cm(0x87EF, 'Low byte: the device mode')
cm(0x87F2, 'Return to the OSBYTE caller')

d.subroutine(0x87F3, 'read_mouse_buttons',
    title='Read the mouse buttons (not used)',
    description="""Nothing in the ROM calls this routine or holds its address.

It reads the three mouse buttons from User VIA port B and returns them
as an OSBYTE &80 result would be: A=&80, X = the buttons (bit set =
pressed) and Y=0. If the pinout has not yet been detected, it is taken
to be AMX if any of PB5-PB7 is low (a button is pressed), and recorded;
otherwise the Compact pinout is used for this read only. With the AMX
pinout, PB5-PB7 are rotated down to bits 0-2.

This is the button-reading form of ADVAL(9) used by other mouse drivers;
in PMFS, ADVAL(9) returns the device mode instead.""",
    on_exit={'A': '&80', 'X': 'buttons, bits 0-2, 1 = pressed', 'Y': '0'})
cm(0x87F3, 'Save the flags and disable interrupts')
cm(0x87F4, '...')
cm(0x87F5, 'Bring in the workspace')
cm(0x87F8, 'Pinout detected?')
cm(0x87FB, 'Yes')
cm(0x87FD, 'Assume the Compact pinout')
cm(0x87FF, 'Are PB5-PB7 all high...')
cm(0x8802, '...')
cm(0x8804, '...(no AMX button pressed)?')
cm(0x8806, 'Yes: Compact, for this read')
cm(0x8808, 'No: the AMX pinout...')
cm(0x880A, '...recorded')
d.label(0x880D, 'read_mouse_buttons_port')
cm(0x880D, 'Read port B')
cm(0x8810, 'Compact pinout?')
cm(0x8812, 'Yes: buttons are PB0-PB2')
cm(0x8814, 'AMX: rotate PB5-PB7...')
cm(0x8815, '...through the carry...')
cm(0x8816, '...')
cm(0x8817, '...into bits 0-2')
d.label(0x8818, 'read_mouse_buttons_bits')
cm(0x8818, 'Keep the three button bits')
cm(0x881A, '1 = pressed (the inputs are low when pressed)')
cm(0x881C, 'X = buttons')
cm(0x881D, 'Put the workspace back')
cm(0x8820, 'Restore the flags')
cm(0x8821, 'Y = 0')
cm(0x8823, 'Always taken: return A=&80')

# ---------------------------------------------------------------------------
# IRQ: the mouse
# ---------------------------------------------------------------------------

d.subroutine(0x8825, 'irq_handler',
    title='Interrupt handler: mouse movement',
    description="""Reached on every interrupt while the driver is on: IRQ1V points at
irq1v_trampoline, whose JSR to the IRQ1V extended vector entry pages in
this ROM and calls here, and whose JMP then goes on to the previous IRQ1V
handler. So the interrupt is never claimed; the MOS handles it too.

If the User VIA's CB1 or CB2 interrupt is enabled and either has
occurred, the first ten bytes of the workspace (the pointer position,
the pinout and the redraw countdown) are brought in, the pointer is
moved (mouse_movement), and they are put back. The CB1 and CB2
interrupts are only enabled in mouse mode.""",
    on_exit={'A': 'preserved', 'X': 'preserved', 'Y': 'preserved',
             'flags': 'preserved'})
cm(0x8825, 'Save the flags')
cm(0x8826, 'and the registers')
cm(0x8827, '...')
cm(0x8828, '...')
cm(0x8829, 'Are CB1 or CB2 interrupts enabled?')
cm(0x882C, '...')
d.expr(0x882D, 'via_ier_disable_cb1_cb2')
cm(0x882E, 'No: not a mouse interrupt')
cm(0x8830, 'Has CB1 or CB2 interrupted?')
cm(0x8833, '...')
d.expr(0x8834, 'via_ier_disable_cb1_cb2')
cm(0x8835, 'No: not a mouse interrupt')
cm(0x8837, 'Bring in the position workspace')
cm(0x883A, 'Y = which of CB1 and CB2 interrupted')
cm(0x883B, 'Move the pointer')
cm(0x883E, 'Put the position workspace back')
d.label(0x8841, 'irq_return')
cm(0x8841, 'Restore everything and return to the trampoline')

# ---------------------------------------------------------------------------
# Polling: joystick and keys
# ---------------------------------------------------------------------------

d.subroutine(0x8844, 'poll_move_pointer',
    title='Poll: move the pointer with the joystick or keys',
    description="""The first half of the polling service call (&15), issued by the MOS
every centisecond while the driver is on. Moves the pointer according to
the device mode:

| Mode | Device | Input | Left / right | Up / down |
|------|--------|-------|--------------|-----------|
| 0 | Mouse | none here: irq_handler moves the pointer | | |
| &80 | Analogue joystick | ADVAL(1), ADVAL(2) high bytes | ch 1 >= &C0 / < &40 | ch 2 >= &C0 / < &40 |
| &40 | Digital joystick | ADVAL(0) low byte | bit 4 / bit 7 | bit 6 / bit 5 |
| &20 | Cursor keys | INKEY -26, -122, -58, -42 | left / right | up / down |

When an axis is not moving, its speed is reset. With the cursor keys,
holding SHIFT accelerates both speeds faster. Runs with interrupts
disabled, inside enter_driver and leave_driver.""",
    on_exit={'A': 'preserved', 'X': 'preserved', 'Y': 'preserved', 'flags': 'preserved'})
cm(0x8844, 'Save the flags')
cm(0x8845, 'Interrupts off while the workspace is in use')
cm(0x8846, 'Save the registers')
cm(0x8847, '...')
cm(0x8848, '...')
cm(0x8849, 'Bring in the workspace, save zero page')
cm(0x884C, 'Device mode')
cm(0x884F, 'Not the mouse')
cm(0x8851, 'Mouse: nothing to do here')
d.label(0x8854, 'poll_not_mouse')
cm(0x8854, 'Bit 7 clear: digital joystick or keys')
cm(0x8856, 'Analogue joystick')
d.label(0x8859, 'poll_digital_or_keys')
cm(0x8859, 'Digital joystick?')
d.expr(0x885A, 'device_mode_digital')
cm(0x885B, 'Yes')
cm(0x885D, 'No: cursor keys')
d.label(0x8860, 'poll_digital')
cm(0x8860, 'OSBYTE &80 with X=0: ADVAL(0)...')
cm(0x8862, '...')
cm(0x8864, '...')
cm(0x8866, '...')
cm(0x8869, 'Bit 4 of the low byte: left?')
cm(0x886A, '...')
cm(0x886C, 'No')
cm(0x886E, 'Yes: move left')
cm(0x8871, '...')
d.label(0x8873, 'poll_digital_right')
cm(0x8873, 'Bit 7: right?')
cm(0x8874, 'No')
cm(0x8876, 'Yes: move right')
cm(0x8879, '...')
d.label(0x887B, 'poll_digital_x_still')
cm(0x887B, 'Neither: reset the horizontal speed')
d.label(0x887E, 'poll_digital_vertical')
cm(0x887E, 'Bit 6: up?')
cm(0x887F, '...')
cm(0x8881, 'No')
cm(0x8883, 'Yes: move up')
cm(0x8886, '...')
d.label(0x8888, 'poll_digital_down')
cm(0x8888, 'Bit 5: down?')
cm(0x8889, '...')
cm(0x888B, 'No')
cm(0x888D, 'Yes: move down')
cm(0x8890, '...')
d.label(0x8892, 'poll_digital_y_still')
cm(0x8892, 'Neither: reset the vertical speed')
d.label(0x8895, 'poll_digital_done')
cm(0x8895, 'Finish')
d.label(0x8897, 'poll_joystick')
cm(0x8897, 'OSBYTE &80 with X=1: ADVAL(1), horizontal')
cm(0x8899, '...')
cm(0x889B, '...')
cm(0x889D, '...')
cm(0x88A0, 'High byte &C0 or more: pushed left?')
cm(0x88A2, 'No')
cm(0x88A4, 'Yes: move left')
cm(0x88A7, '...')
d.label(0x88A9, 'poll_joystick_right')
cm(0x88A9, 'Below &40: pushed right?')
cm(0x88AB, 'No')
cm(0x88AD, 'Yes: move right')
cm(0x88B0, '...')
d.label(0x88B2, 'poll_joystick_x_still')
cm(0x88B2, 'Centred: reset the horizontal speed')
d.label(0x88B5, 'poll_joystick_vertical')
cm(0x88B5, 'OSBYTE &80 with X=2: ADVAL(2), vertical')
cm(0x88B7, '...')
cm(0x88B9, '...')
cm(0x88BB, '...')
cm(0x88BE, 'High byte &C0 or more: pushed up?')
cm(0x88C0, 'No')
cm(0x88C2, 'Yes: move up')
cm(0x88C5, '...')
d.label(0x88C7, 'poll_joystick_down')
cm(0x88C7, 'Below &40: pulled down?')
cm(0x88C9, 'No')
cm(0x88CB, 'Yes: move down')
cm(0x88CE, '...')
d.label(0x88D0, 'poll_joystick_y_still')
cm(0x88D0, 'Centred: reset the vertical speed')
d.label(0x88D3, 'finish_poll_move')
cm(0x88D3, 'Put back zero page and the workspace')
cm(0x88D6, 'Restore everything and return')
d.label(0x88D9, 'poll_keys')
cm(0x88D9, 'OSBYTE &81 with X=-1: is SHIFT pressed?')
cm(0x88DB, '...')
cm(0x88DD, '...')
cm(0x88DF, '...')
cm(0x88E2, 'X=&FF if pressed')
cm(0x88E3, 'No')
cm(0x88E5, 'Yes: add an extra &40 to the horizontal...')
cm(0x88E6, '...')
d.expr(0x88E7, 'speed_shift_boost')
cm(0x88E8, '...')
cm(0x88EB, '...')
cm(0x88EE, '...')
cm(0x88F0, '...')
d.label(0x88F3, 'poll_keys_boost_y')
cm(0x88F3, 'and vertical speeds')
cm(0x88F4, '...')
d.expr(0x88F5, 'speed_shift_boost')
cm(0x88F6, '...')
cm(0x88F9, '...')
cm(0x88FC, '...')
cm(0x88FE, '...')
d.label(0x8901, 'poll_keys_left')
cm(0x8901, 'Cursor left pressed?')
cm(0x8903, '...')
cm(0x8905, '...')
cm(0x8907, '...')
cm(0x890A, '...')
cm(0x890B, 'No')
cm(0x890D, 'Yes: move left')
cm(0x8910, '...')
d.label(0x8912, 'poll_keys_right')
cm(0x8912, 'Cursor right pressed?')
cm(0x8914, '...')
cm(0x8916, '...')
cm(0x8918, '...')
cm(0x891B, '...')
cm(0x891C, 'No')
cm(0x891E, 'Yes: move right')
cm(0x8921, '...')
d.label(0x8923, 'poll_keys_x_still')
cm(0x8923, 'Neither: reset the horizontal speed')
d.label(0x8926, 'poll_keys_up')
cm(0x8926, 'Cursor up pressed?')
cm(0x8928, '...')
cm(0x892A, '...')
cm(0x892C, '...')
cm(0x892F, '...')
cm(0x8930, 'No')
cm(0x8932, 'Yes: move up')
cm(0x8935, '...')
d.label(0x8937, 'poll_keys_down')
cm(0x8937, 'Cursor down pressed?')
cm(0x8939, '...')
cm(0x893B, '...')
cm(0x893D, '...')
cm(0x8940, '...')
cm(0x8941, 'No')
cm(0x8943, 'Yes: move down')
cm(0x8946, '...')
d.label(0x8948, 'poll_keys_y_still')
cm(0x8948, 'Neither: reset the vertical speed')
d.label(0x894B, 'poll_keys_done')
cm(0x894B, 'Finish')

_moves = [
    (0x894D, 'move_pointer_left', 'Move the pointer left',
     """Subtract the whole part of x_speed from pointer_x, stopping at 0, then
accelerate: x_speed grows by &10 (1/16 of a graphics unit) each call."""),
    (0x8976, 'move_pointer_right', 'Move the pointer right',
     """Add the whole part of x_speed to pointer_x, stopping at 1276 (&4FC), then
accelerate: x_speed grows by &10 each call."""),
    (0x89A5, 'move_pointer_down', 'Move the pointer down',
     """Subtract the whole part of y_speed from pointer_y, stopping at 0, then
accelerate: y_speed grows by &10 each call."""),
    (0x89CE, 'move_pointer_up', 'Move the pointer up',
     """Add the whole part of y_speed to pointer_y, stopping at 1020 (&3FC), then
accelerate: y_speed grows by &10 each call."""),
]
for _addr, _name, _title, _desc in _moves:
    d.subroutine(_addr, _name, title=_title, description=_desc,
                 on_exit={'A': 'corrupted', 'X': 'preserved', 'Y': 'preserved'})

cm(0x894D, 'pointer_x -= whole part of the speed')
cm(0x8950, '...')
cm(0x8951, '...')
cm(0x8954, '...')
cm(0x8957, '...')
cm(0x895A, '...')
cm(0x895C, '...')
cm(0x895F, 'Still 0 or more?')
cm(0x8961, 'No: stop at 0')
cm(0x8964, '...')
d.label(0x8967, 'accelerate_x_left')
cm(0x8967, 'x_speed += &10')
cm(0x8968, '...')
d.expr(0x8969, 'speed_acceleration')
cm(0x896A, '...')
cm(0x896D, '...')
cm(0x8970, '...')
cm(0x8972, '...')
d.label(0x8975, 'return_from_move_left')
cm(0x8975, 'Return')
cm(0x8976, 'pointer_x += whole part of the speed')
cm(0x8979, '...')
cm(0x897A, '...')
cm(0x897D, '...')
cm(0x8980, '...')
cm(0x8983, '...')
cm(0x8985, '...')
cm(0x8988, 'Beyond the right edge (high byte 5 or more)?')
cm(0x898A, 'No')
cm(0x898C, 'Yes: stop at 1276 (&4FC)')
d.expr(0x898D, hi(sym('pointer_x_max')))
cm(0x898E, '...')
cm(0x8991, '...')
d.expr(0x8992, lo(sym('pointer_x_max')))
cm(0x8993, '...')
d.label(0x8996, 'accelerate_x_right')
cm(0x8996, 'x_speed += &10')
cm(0x8997, '...')
d.expr(0x8998, 'speed_acceleration')
cm(0x8999, '...')
cm(0x899C, '...')
cm(0x899F, '...')
cm(0x89A1, '...')
d.label(0x89A4, 'return_from_move_right')
cm(0x89A4, 'Return')
cm(0x89A5, 'pointer_y -= whole part of the speed')
cm(0x89A8, '...')
cm(0x89A9, '...')
cm(0x89AC, '...')
cm(0x89AF, '...')
cm(0x89B2, '...')
cm(0x89B4, '...')
cm(0x89B7, 'Still 0 or more?')
cm(0x89B9, 'No: stop at 0')
cm(0x89BC, '...')
d.label(0x89BF, 'accelerate_y_down')
cm(0x89BF, 'y_speed += &10')
cm(0x89C0, '...')
d.expr(0x89C1, 'speed_acceleration')
cm(0x89C2, '...')
cm(0x89C5, '...')
cm(0x89C8, '...')
cm(0x89CA, '...')
d.label(0x89CD, 'return_from_move_down')
cm(0x89CD, 'Return')
cm(0x89CE, 'pointer_y += whole part of the speed')
cm(0x89D1, '...')
cm(0x89D2, '...')
cm(0x89D5, '...')
cm(0x89D8, '...')
cm(0x89DB, '...')
cm(0x89DD, '...')
cm(0x89E0, 'Beyond the top (high byte 4 or more)?')
cm(0x89E2, 'No')
cm(0x89E4, 'Yes: stop at 1020 (&3FC)')
d.expr(0x89E5, hi(sym('pointer_y_max')))
cm(0x89E6, '...')
cm(0x89E9, '...')
d.expr(0x89EA, lo(sym('pointer_y_max')))
cm(0x89EB, '...')
d.label(0x89EE, 'accelerate_y_up')
cm(0x89EE, 'y_speed += &10')
cm(0x89EF, '...')
d.expr(0x89F0, 'speed_acceleration')
cm(0x89F1, '...')
cm(0x89F4, '...')
cm(0x89F7, '...')
cm(0x89F9, '...')
d.label(0x89FC, 'return_from_move_up')
cm(0x89FC, 'Return')

d.subroutine(0x89FD, 'reset_x_speed',
    title='Reset the horizontal speed',
    description="""Set x_speed to &0080, half a graphics unit: the first step after
starting to move is 0, and steps grow by one unit every 16 polls.""")
cm(0x89FD, 'Whole part 0')
cm(0x8A00, 'Fraction one half')
d.expr(0x8A01, 'speed_initial')
cm(0x8A02, '...')
cm(0x8A05, 'Return')
d.subroutine(0x8A06, 'reset_y_speed',
    title='Reset the vertical speed',
    description="""Set y_speed to &0080, as reset_x_speed.""")
cm(0x8A06, 'Whole part 0')
cm(0x8A09, 'Fraction one half')
d.expr(0x8A0A, 'speed_initial')
cm(0x8A0B, '...')
cm(0x8A0E, 'Return')

# ---------------------------------------------------------------------------
# Polling: redraw and buttons
# ---------------------------------------------------------------------------

d.subroutine(0x8A0F, 'poll_redraw_and_buttons',
    title='Poll: redraw the pointer and read the buttons',
    description="""The second half of the polling service call. If the pointer is shown,
count down redraw_countdown and redraw the pointer when it goes negative
(update_pointer, which only draws if the pointer has moved, and restarts
the count at 10). Mouse interrupts also count it down, so a moving mouse
is redrawn sooner. Then read the buttons (scan_buttons). Runs with
interrupts disabled, inside enter_driver and leave_driver.""",
    on_exit={'A': 'preserved', 'X': 'preserved', 'Y': 'preserved', 'flags': 'preserved'})
cm(0x8A0F, 'Save the flags')
cm(0x8A10, 'and the registers')
cm(0x8A11, '...')
cm(0x8A12, '...')
cm(0x8A13, 'Interrupts off while the workspace is in use')
cm(0x8A14, 'Bring in the workspace, save zero page')
cm(0x8A17, 'Is the pointer shown?')
cm(0x8A1A, 'No')
cm(0x8A1C, 'Count down to the next redraw')
cm(0x8A1F, 'Not yet')
cm(0x8A21, 'Redraw it if it has moved')
d.label(0x8A24, 'poll_buttons')
cm(0x8A24, 'Read the buttons')
cm(0x8A27, 'Put back zero page and the workspace')
cm(0x8A2A, 'Restore everything and return')

d.subroutine(0x8A2D, 'scan_buttons',
    title='Read the buttons and turn presses into keys',
    description="""Read the buttons and, when a new button state has been seen on two
polls running, put a key into the keyboard buffer (OSBYTE &99) for any
button pressed in it:

| Device | Button | Key |
|--------|--------|-----|
| Mouse | left (Compact PB0, AMX PB5) | RETURN (&0D) |
| Mouse | right (Compact PB2, AMX PB7) | &C0 |
| Mouse | middle (Compact PB1, AMX PB6) | the TAB key's code (OSBYTE &DB) |
| Joysticks | fire button 1 (ADVAL(0) bit 0) | RETURN (&0D) |
| Joysticks | fire button 2 (ADVAL(0) bit 1) | the TAB key's code |
| Keys | none | |

One key is sent per change, with priority in the order listed. The
mouse buttons are read from User VIA port B, where a pressed button
reads low, through pinout_table. If the pinout is not yet known, it is
taken to be AMX if any of PB5-PB7 is low, and recorded; otherwise the
Compact pinout is used for this read only.

The debounce: button_state holds the last reading and button_pending a
change waiting to be confirmed. A reading different from both is stored
in both. A reading equal to button_pending is a confirmed change: the
pending change is cleared and the keys are sent for button_state.

0 doubles as "nothing pending", so a reading of 0 (all three mouse
buttons pressed, or both fire buttons) is never recorded: at every poll
while it lasts it is taken as confirming a change, and the keys for
button_state, the last other reading, are sent again.""",
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'corrupted'})
cm(0x8A2D, 'Device mode')
cm(0x8A30, 'Not the mouse')
cm(0x8A32, 'Mouse: is the pinout known?')
cm(0x8A35, 'Yes')
cm(0x8A37, 'Assume the Compact pinout')
cm(0x8A39, 'Are PB5-PB7 all high...')
cm(0x8A3C, '...')
cm(0x8A3E, '...(no AMX button pressed)?')
cm(0x8A40, 'Yes: Compact, for this read')
cm(0x8A42, 'No: the AMX pinout...')
cm(0x8A44, '...recorded')
d.label(0x8A47, 'scan_mouse_buttons')
cm(0x8A47, 'Read port B...')
d.expr(0x8A4B, sym('pinout_table') + 1)
cm(0x8A4A, '...keeping the button bits')
cm(0x8A4D, 'The pending change confirmed?')
cm(0x8A50, 'Yes: send the keys')
cm(0x8A52, 'Same as the last reading?')
cm(0x8A55, 'Keep this reading')
cm(0x8A58, 'Same: nothing to do')
cm(0x8A5A, 'Changed: wait for the next poll to confirm it')
d.label(0x8A5D, 'return_from_buttons')
cm(0x8A5D, 'Return')
d.label(0x8A5E, 'scan_joystick_buttons')
cm(0x8A5E, 'Cursor keys?')
d.expr(0x8A5F, 'device_mode_keys')
cm(0x8A60, 'No: joystick fire buttons')
cm(0x8A62, 'Yes: no buttons')
d.label(0x8A63, 'read_fire_buttons')
cm(0x8A63, 'OSBYTE &80 with X=0: ADVAL(0)')
cm(0x8A65, '...')
cm(0x8A67, '...')
cm(0x8A69, '...')
cm(0x8A6C, 'The two fire button bits...')
cm(0x8A6D, '...')
cm(0x8A6F, '...inverted, so 0 = pressed as for the mouse')
cm(0x8A71, 'The pending change confirmed?')
cm(0x8A74, 'Yes: send the keys')
cm(0x8A76, 'Same as the last reading?')
cm(0x8A79, 'Keep this reading')
cm(0x8A7C, 'Same: nothing to do')
cm(0x8A7E, 'Changed: wait for the next poll to confirm it')
cm(0x8A81, 'Return')
d.label(0x8A82, 'joystick_buttons_changed')
cm(0x8A82, 'Nothing pending now')
cm(0x8A85, 'Both buttons released?')
cm(0x8A88, '...')
cm(0x8A8A, 'Yes: no key')
cm(0x8A8C, 'RETURN...')
d.expr(0x8A8D, 'key_return')
cm(0x8A8E, '...if fire button 1 is pressed')
cm(0x8A90, '...')
cm(0x8A92, 'Otherwise fire button 2: TAB')
d.label(0x8A94, 'mouse_buttons_changed')
cm(0x8A94, 'Nothing pending now')
cm(0x8A97, 'All buttons released?')
d.expr(0x8A9B, sym('pinout_table') + 1)
cm(0x8A9A, '...')
cm(0x8A9D, 'Yes: no key')
cm(0x8A9F, 'RETURN...')
d.expr(0x8AA0, 'key_return')
cm(0x8AA1, '...if the left button is pressed')
d.expr(0x8AA2, sym('pinout_table') + 2)
cm(0x8AA4, '...')
cm(0x8AA6, '&C0...')
cm(0x8AA9, '...')
d.expr(0x8AAA, 'key_right_button')
cm(0x8AAB, '...if the right button is pressed')
d.expr(0x8AAC, sym('pinout_table') + 4)
cm(0x8AAE, '...')
d.label(0x8AB0, 'insert_tab_key')
cm(0x8AB0, 'Otherwise the middle button: OSBYTE &DB, the TAB key code')
cm(0x8AB6, '...')
cm(0x8AB9, '...')
cm(0x8ABA, 'Y = that code')
d.label(0x8ABB, 'insert_key')
cm(0x8ABB, 'OSBYTE &99: put Y into the keyboard buffer')
cm(0x8ABD, '(buffer 0) as if typed, and return')
cm(0x8ABF, '...')

# ---------------------------------------------------------------------------
# Mouse movement
# ---------------------------------------------------------------------------

d.subroutine(0x8AC2, 'mouse_movement',
    title='Move the pointer for a mouse interrupt',
    description="""Called from irq_handler with the User VIA interrupt flags for CB1 and
CB2 in Y. The mouse's two quadrature channels interrupt on CB1 (X) and
CB2 (Y); at each interrupt the other signal of the channel, read from a
port B bit, gives the direction:

| Pinout | X direction | Y direction |
|--------|-------------|-------------|
| Compact (joystick port) | PB3 | PB4 |
| AMX (User Port) | PB0 | PB2 |

Each interrupt moves the pointer 4 graphics units, high meaning right or
up and low left or down, clamped to 0-1276 and 0-1020. Only one edge of
one signal per channel interrupts, so there is one step per quadrature
cycle. Reading port B also clears the CB1 and CB2 interrupt flags.

If the pinout is not yet known, it is taken to be Compact if either of
PB3 and PB4 is low, and recorded; otherwise the AMX pinout is used for
this interrupt only. Each interrupt also counts down redraw_countdown.""",
    on_entry={'Y': 'interrupt flags: bit 4 CB1, bit 3 CB2'},
    on_exit={'A': 'corrupted', 'X': 'corrupted', 'Y': 'preserved'})
cm(0x8AC2, 'Bring the next redraw forward')
cm(0x8AC5, 'Is the pinout known?')
cm(0x8AC8, 'Yes')
cm(0x8ACA, 'Assume AMX')
cm(0x8ACC, 'Are PB3 and PB4 both high?')
cm(0x8ACF, '...')
cm(0x8AD1, '...')
cm(0x8AD3, 'Yes: AMX, for this interrupt')
cm(0x8AD5, 'No: the Compact pinout...')
cm(0x8AD7, '...recorded')
d.label(0x8ADA, 'mouse_movement_x')
cm(0x8ADA, 'Did CB1 (X) interrupt?')
cm(0x8ADB, '...')
d.expr(0x8ADC, 'via_int_cb1')
cm(0x8ADD, 'No: check Y')
cm(0x8ADF, 'Read the X direction bit')
cm(0x8AE2, '...')
d.expr(0x8AE3, sym('pinout_table') + 6)
cm(0x8AE5, 'Low: left')
cm(0x8AE7, 'High: right. Already at 1276 (&4FC)?')
cm(0x8AEA, '...')
cm(0x8AEC, 'No')
cm(0x8AEE, '...')
cm(0x8AF1, '...')
cm(0x8AF3, 'Yes: stay there')
d.label(0x8AF5, 'mouse_right')
cm(0x8AF5, 'pointer_x += 4 (carry clear from the CMP)')
cm(0x8AF8, '...')
cm(0x8AFA, '...')
cm(0x8AFD, '...')
cm(0x8AFF, '...')
d.label(0x8B02, 'mouse_x_done')
cm(0x8B02, 'Go on to Y')
d.label(0x8B04, 'mouse_left')
cm(0x8B04, 'Already at 0?')
cm(0x8B07, 'No')
cm(0x8B09, '...')
cm(0x8B0C, 'Yes: stay there')
cm(0x8B0E, '...')
d.label(0x8B11, 'mouse_left_step')
cm(0x8B11, 'pointer_x -= 4')
cm(0x8B12, '...')
cm(0x8B14, '...')
cm(0x8B17, '...')
cm(0x8B1A, '...')
cm(0x8B1C, '...')
d.label(0x8B1F, 'mouse_movement_y')
cm(0x8B1F, 'Did CB2 (Y) interrupt?')
cm(0x8B20, '...')
d.expr(0x8B21, 'via_int_cb2')
cm(0x8B22, 'No: done')
cm(0x8B24, 'Read the Y direction bit')
cm(0x8B27, '...')
d.expr(0x8B28, sym('pinout_table') + 5)
cm(0x8B2A, 'Low: down')
cm(0x8B2C, 'High: up. Already at 1020 (&3FC)?')
cm(0x8B2F, '...')
cm(0x8B31, 'No')
cm(0x8B33, '...')
cm(0x8B36, '...')
cm(0x8B38, 'Yes: stay there')
d.label(0x8B3A, 'mouse_up')
cm(0x8B3A, 'pointer_y += 4 (carry clear from the CMP)')
cm(0x8B3D, '...')
cm(0x8B3F, '...')
cm(0x8B42, '...')
cm(0x8B44, '...')
d.label(0x8B47, 'return_from_mouse_up')
cm(0x8B47, 'Return')
d.label(0x8B48, 'mouse_down')
cm(0x8B48, 'Already at 0?')
cm(0x8B4B, 'No')
cm(0x8B4D, '...')
cm(0x8B50, 'Yes: stay there')
cm(0x8B52, '...')
d.label(0x8B55, 'mouse_down_step')
cm(0x8B55, 'pointer_y -= 4')
cm(0x8B56, '...')
cm(0x8B58, '...')
cm(0x8B5B, '...')
cm(0x8B5E, '...')
cm(0x8B60, '...')
d.label(0x8B63, 'return_from_mouse_movement')
cm(0x8B63, 'Return')

d.label(0x8B64, 'pinout_table')
d.banner(0x8B64, title='Mouse pinout table',
    description="""Two 7-byte records of User VIA port B masks, one for each way of wiring a
mouse, indexed by pinout_index (0 or 7):

| Offset | Use | Compact (0) | AMX (7) |
|--------|-----|-------------|---------|
| +0 | both direction bits (not read) | &18: PB3, PB4 | &05: PB0, PB2 |
| +1 | all three buttons | &07: PB0-PB2 | &E0: PB5-PB7 |
| +2 | left button | &01: PB0 | &20: PB5 |
| +3 | middle button (not read) | &02: PB1 | &40: PB6 |
| +4 | right button | &04: PB2 | &80: PB7 |
| +5 | Y direction | &10: PB4 | &04: PB2 |
| +6 | X direction | &08: PB3 | &01: PB0 |

The code reads offsets 1, 2, 4, 5 and 6; it tests the direction bits
for pinout detection with a literal &18.""")
for _rec, _name in ((0x8B64, 'Compact'), (0x8B6B, 'AMX')):
    _fields = ['direction bits', 'buttons', 'left button', 'middle button',
               'right button', 'Y direction', 'X direction']
    for _i, _f in enumerate(_fields):
        d.byte(_rec + _i)
        cm(_rec + _i, f'{_name}: {_f}')

d.subroutine(0x8B72, 'exchange_position_workspace',
    title='Exchange the working and stored pointer position',
    description="""As exchange_workspace, but for the first ten bytes only (&9000-&9009:
the *TMAX values, the pointer position, the pinout and the redraw
countdown), which is all the mouse interrupt needs.""",
    on_exit={'A': 'preserved', 'X': 'corrupted', 'Y': 'corrupted'})
cm(0x8B72, 'Save A')
cm(0x8B73, 'and the zero page pointer used')
cm(0x8B75, '...')
cm(0x8B76, '...')
cm(0x8B78, '...')
cm(0x8B79, 'Point it at the stored copy: page +3...')
cm(0x8B7B, '...')
cm(0x8B7E, '...')
cm(0x8B7F, '...')
cm(0x8B81, '...')
cm(0x8B83, 'offset &40')
cm(0x8B85, '...')
cm(0x8B87, '10 bytes, from the last')
d.label(0x8B89, 'exchange_position_byte')
cm(0x8B89, 'Working byte')
cm(0x8B8C, 'Stored byte...')
cm(0x8B8E, '...becomes the working byte')
cm(0x8B91, 'Working byte...')
cm(0x8B92, '...becomes the stored byte')
cm(0x8B94, 'Next')
cm(0x8B95, '...')
cm(0x8B97, 'Restore the zero page pointer')
cm(0x8B98, '...')
cm(0x8B9A, '...')
cm(0x8B9B, '...')
cm(0x8B9D, 'Restore A')
cm(0x8B9E, 'Return')

# ---------------------------------------------------------------------------
# *TMAX and *TSET
# ---------------------------------------------------------------------------

d.subroutine(0x8B9F, 'parse_number',
    title='Read a decimal number from the command line',
    description="""Read decimal digits at (cmd_ptr),Y into parsed_number, up to a space,
comma or CR. Any other character raises "Bad number" (check_digit).
Returns with carry set if there were no digits or the value exceeded
65535.""",
    on_entry={'Y': 'offset of the number'},
    on_exit={'parsed_number': 'the value',
             'flags': 'C clear if a number was read, set otherwise',
             'Y': 'offset of the terminator', 'A': 'corrupted'})
cm(0x8B9F, 'Value = 0')
cm(0x8BA1, '...')
cm(0x8BA4, '...')
cm(0x8BA7, 'Carry set on the stack: no digits yet')
cm(0x8BA8, '...')
d.label(0x8BA9, 'parse_number_char')
cm(0x8BA9, 'Next character')
cm(0x8BAB, 'Space?')
d.char_literal(0x8BAC)
cm(0x8BAD, 'Yes: end of the number')
cm(0x8BAF, 'Comma?')
d.char_literal(0x8BB0)
cm(0x8BB1, 'Yes: end of the number')
cm(0x8BB3, 'CR?')
d.expr(0x8BB4, 'key_return')
cm(0x8BB5, 'Yes: end of the number')
cm(0x8BB7, 'Anything but a digit: "Bad number"')
cm(0x8BBA, 'Copy the value so far')
cm(0x8BBD, '...')
cm(0x8BC0, '...')
cm(0x8BC3, '...')
cm(0x8BC6, 'Value * 2...')
cm(0x8BC9, '...')
cm(0x8BCA, '...')
cm(0x8BCD, 'Too big')
cm(0x8BCF, '* 4...')
cm(0x8BD0, '...')
cm(0x8BD3, 'Too big')
cm(0x8BD5, '+ the copy = * 5...')
cm(0x8BD8, '...')
cm(0x8BDB, '...')
cm(0x8BDE, '...')
cm(0x8BE1, 'Too big')
cm(0x8BE3, '...')
cm(0x8BE6, '* 2 = * 10')
cm(0x8BE9, '...')
cm(0x8BEC, 'Too big')
cm(0x8BEE, 'Add the digit')
cm(0x8BF0, '...')
cm(0x8BF2, '...')
cm(0x8BF3, '...')
cm(0x8BF6, '...')
cm(0x8BF9, '...')
cm(0x8BFB, '...')
cm(0x8BFE, 'Too big')
d.label(0x8C00, 'parse_number_digit_done')
cm(0x8C00, 'Carry clear on the stack: a digit was read')
cm(0x8C01, '...')
cm(0x8C02, '...')
cm(0x8C03, 'Next character')
cm(0x8C04, 'Always taken (Y does not wrap)')
d.label(0x8C06, 'parse_number_too_big')
cm(0x8C06, 'Carry set on the stack: failed')
cm(0x8C07, '...')
cm(0x8C08, '...')
d.label(0x8C09, 'parse_number_done')
cm(0x8C09, 'Carry = the result')
cm(0x8C0A, 'Return')

d.subroutine(0x8C0B, 'cmd_tmax',
    title='*TMAX x,y: set the values returned by ADVAL(5) and ADVAL(6)',
    description="""Read two numbers, 0-65535, separated by spaces or commas, and store them
in tmax_x and tmax_y. Nothing else in PMFS uses them; in particular the
pointer is not limited by them. A missing, malformed or too-large number
gives "Bad number".""")
cm(0x8C0B, 'First argument')
cm(0x8C0E, 'Read x')
cm(0x8C11, 'None, or too big: "Bad number"')
cm(0x8C13, 'Keep x on the stack')
cm(0x8C16, '...')
cm(0x8C17, '...')
cm(0x8C1A, '...')
cm(0x8C1B, 'Skip spaces and commas')
cm(0x8C1E, 'Read y')
cm(0x8C21, 'None, or too big: "Bad number"')
cm(0x8C23, 'Store y in tmax_y')
cm(0x8C25, '...')
cm(0x8C28, 'Recover x')
cm(0x8C29, '...')
cm(0x8C2C, '...')
cm(0x8C2D, '...')
cm(0x8C30, 'and store it in tmax_x')

d.subroutine(0x8C32, 'store_parsed_number',
    title='Store parsed_number in the workspace',
    description="""Store parsed_number at tmax_x+Y, with interrupts disabled.""",
    on_entry={'Y': 'offset from tmax_x: 0, 2, 4 or 6'},
    on_exit={'Y': 'incremented', 'A': 'corrupted'})
cm(0x8C32, 'Low byte')
cm(0x8C35, 'Interrupts off')
cm(0x8C36, '...')
cm(0x8C37, '...')
cm(0x8C3A, 'High byte')
cm(0x8C3D, '...')
cm(0x8C3E, '...')
cm(0x8C41, 'Interrupts back as they were')
cm(0x8C42, 'Return')
d.label(0x8C43, 'discard_first_number')
cm(0x8C43, 'Drop the first number')
cm(0x8C44, '...')
d.label(0x8C45, 'raise_bad_number')
cm(0x8C45, '"Bad number"')

d.subroutine(0x8C48, 'cmd_tset',
    title='*TSET x,y: move the pointer',
    description="""Read two numbers, as *TMAX, and store them in pointer_x and pointer_y.
They are not clamped to the screen. The pointer is redrawn at the next
poll that redraws it.""")
cm(0x8C48, 'First argument')
cm(0x8C4B, 'Read x')
cm(0x8C4E, 'None, or too big: "Bad number"')
cm(0x8C50, 'Keep x on the stack')
cm(0x8C53, '...')
cm(0x8C54, '...')
cm(0x8C57, '...')
cm(0x8C58, 'Skip spaces and commas')
cm(0x8C5B, 'Read y')
cm(0x8C5E, 'None, or too big: "Bad number"')
cm(0x8C60, 'Store y in pointer_y')
cm(0x8C62, '...')
cm(0x8C65, 'Recover x')
cm(0x8C66, '...')
cm(0x8C69, '...')
cm(0x8C6A, '...')
cm(0x8C6D, 'Store it in pointer_x and return')
cm(0x8C6F, '...')

# ---------------------------------------------------------------------------
# Screen geometry tables
# ---------------------------------------------------------------------------

_row_tables = [
    (0x8C72, 0x8C94, 'mode012_row_addr', 0x3000, 640, 'MODEs 0, 1 and 2'),
    (0x8CB6, 0x8CD8, 'mode45_row_addr', 0x5800, 320, 'MODEs 4 and 5'),
]
for _lo, _hi, _name, _base, _row_bytes, _modes in _row_tables:
    d.label(_lo, _name + '_lo')
    d.banner(_lo, title=f'Character row addresses for {_modes}, low bytes',
        description=f"""Start addresses of the 32 character rows of a {_row_bytes}-byte-per-row
screen starting at &{_base:04X}, counted up from the bottom row, followed by
two more rows above the top of the screen. Indexed by
calc_pointer_screen_address. The addresses assume the screen has not
been scrolled by hardware.""")
    d.label(_hi, _name + '_hi')
    d.banner(_hi, title=f'Character row addresses for {_modes}, high bytes')
    for _i in range(34):
        _addr = (_base + (31 - _i) * _row_bytes) & 0xFFFF
        _where = 'above the screen' if _i >= 32 else f'row {_i} from the bottom'
        d.byte(_lo + _i)
        d.expr(_lo + _i, lo(_addr))
        cm(_lo + _i, f'&{_addr:04X}: {_where}')
        d.byte(_hi + _i)
        d.expr(_hi + _i, hi(_addr))
        cm(_hi + _i, f'&{_addr:04X}: {_where}')
d.expr(0x8095, 'mode012_row_addr_hi')
d.expr(0x809A, 'mode012_row_addr_lo')
d.expr(0x80A1, 'mode45_row_addr_hi')
d.expr(0x80A6, 'mode45_row_addr_lo')

d.label(0x8CFA, 'units_per_screen_byte')
d.banner(0x8CFA, title='Graphics units per screen byte, by screen format',
    description="""How far the left edge moves for each byte column: 16 graphics units in
MODEs 0-2 (8, 4 or 2 pixels of 2, 4 or 8 units), 32 in MODEs 4 and 5.""")
for _i, _m in enumerate(('MODE 0', 'MODE 1', 'MODE 2', 'MODE 4', 'MODE 5')):
    d.byte(0x8CFA + _i)
    cm(0x8CFA + _i, f'Format {_i}, {_m}')
d.label(0x8CFF, 'char_row_bytes_lo')
d.banner(0x8CFF, title='Bytes per character row, by screen format',
    description="""Low bytes then high bytes: 640 (&280) in MODEs 0-2, 320 (&140) in MODEs
4 and 5.""")
for _i, _m in enumerate(('MODE 0', 'MODE 1', 'MODE 2', 'MODE 4', 'MODE 5')):
    d.byte(0x8CFF + _i)
    cm(0x8CFF + _i, f'Format {_i}, {_m}: low byte')
d.label(0x8D04, 'char_row_bytes_hi')
for _i, _m in enumerate(('MODE 0', 'MODE 1', 'MODE 2', 'MODE 4', 'MODE 5')):
    d.byte(0x8D04 + _i)
    cm(0x8D04 + _i, f'Format {_i}, {_m}: high byte')
d.expr(0x84F3, 'char_row_bytes_lo')
d.expr(0x84FA, 'char_row_bytes_hi')
d.expr(0x85FC, 'char_row_bytes_lo')
d.expr(0x8603, 'char_row_bytes_hi')
d.expr(0x851C, 'units_per_screen_byte')
d.expr(0x8612, 'units_per_screen_byte')

d.label(0x8D09, 'shifted_copy_offsets')
d.banner(0x8D09, title='Offsets of the four shifted pointer copies',
    description="""Offset within pointer_image_copies of the copy for each shift, 0-3.
The second four bytes repeat the first and are not read.""")
for _i in range(8):
    d.byte(0x8D09 + _i)
    cm(0x8D09 + _i, f'Shift {_i}' if _i < 4 else 'Not read')
d.expr(0x848A, 'shifted_copy_offsets')

d.label(0x8D11, 'hotspot_x')
d.banner(0x8D11, title='Pointer hot spot',
    description="""How far the pointer's position is right of the left edge and below the
top edge of the image, in graphics units: 4 and 4, which is the tip of
the arrow.""")
d.byte(0x8D11)
cm(0x8D11, 'X: graphics units right of the left edge')
d.label(0x8D12, 'hotspot_y')
d.byte(0x8D12)
cm(0x8D12, 'Y: graphics units below the top edge')
d.expr(0x845F, 'hotspot_x')
d.expr(0x846D, 'hotspot_y')

# ---------------------------------------------------------------------------
# Pointer images and masks
# ---------------------------------------------------------------------------

_formats = ['MODE 0', 'MODE 1', 'MODE 2', 'MODE 4', 'MODE 5']
d.label(0x8D13, 'pointer_images')
d.banner(0x8D13, title='Pointer images',
    description="""One 64-byte image for each screen format, 0-4: 4 byte columns of 16
pixel rows each, column by column. Bits set are drawn in logical colour
1 (OR onto the screen). Together with the masks that follow, the pointer
is an arrow outlined in colour 0. In MODE 0 ("#" image, "." outline in
colour 0, blank transparent):

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

The other formats have the same shape at their own pixel sizes, except
at the left edge, where the outline is one pixel wide in MODE 4 and
absent in MODE 5.""")
d.label(0x8E53, 'pointer_masks')
d.banner(0x8E53, title='Pointer masks',
    description="""One 64-byte mask for each screen format, laid out as the images. The
screen is ANDed with the mask before the image is ORed in, so set bits
leave the screen showing through and clear bits are the pointer's
shape.""")
for _base, _kind in ((0x8D13, 'image'), (0x8E53, 'mask')):
    for _f in range(5):
        for _c in range(4):
            _addr = _base + _f * 64 + _c * 16
            d.byte(_addr, 16, cols=16)
            cm(_addr, f'{_formats[_f]} {_kind}, column {_c}')

d.label(0x8F93, 'initials')
d.banner(0x8F93, title='Initials',
    description="""Two sets of initials, JPG and PMF, after the code and data. Nothing
refers to them. PMF also appears in the ROM's copyright string, (C)1986 PMF,
and has been identified as Paul Fellows, who led Acornsoft's languages group
and then the team that wrote Arthur. Who JPG is is not known.""")
d.string(0x8F93, 7)
cm(0x8F93, 'Not used by the code')

d.label(0x8F9A, 'unused_space')
d.banner(0x8F9A, title='Unused space and workspace',
    description="""Zero to the end of the 8 KB image. The driver's RAM workspace is in this
area: it runs from sideways RAM, and &9000 upwards in its own bank holds
its variables (labelled from tmax_x), pointer_image_copies (&9200),
pointer_mask_copies (&9300), screen_under_pointer (&9400) and
stored_workspace (&9440). The image carries them as zero.""")
d.fill(0x8F9A, 0x9000 - 0x8F9A)
cm(0x8F9A, 'Unused')
d.banner(0x9000, title='Driver workspace',
    description="""&9000-&902F is the working copy of the driver's state, exchanged with
stored_workspace on entry to and exit from the driver (exchange_workspace).
&9030-&9037 is used in place. See each label for its use.""")
for _start, _end, _what in ((0x9010, 0x9012, 'Not used'),
                            (0x902F, 0x9030, 'Not used'),
                            (0x9038, 0x9200, 'Not used'),
                            (0x9200, 0x9300, 'Pointer image copies (built at run time)'),
                            (0x9300, 0x9400, 'Pointer mask copies (built at run time)'),
                            (0x9400, 0x9440, 'Screen under the pointer (at run time)'),
                            (0x9440, 0x9470, 'Stored workspace (at run time)'),
                            (0x9470, 0xA000, 'Not used')):
    d.fill(_start, _end - _start)
    cm(_start, _what)

# ---------------------------------------------------------------------------
# Remaining names
# ---------------------------------------------------------------------------

cm(0x8003, 'Service entry: every service call comes here')
d.label(0x80B2, 'store_column_offset_hi')
d.label(0x0D98, 'saved_bytev_hi')
d.label(0x0D9A, 'irq1v_trampoline_target')
d.label(0x0D9B, 'irq1v_trampoline_target_hi')
d.label(0x0D9E, 'saved_irq1v_hi')
d.label(0x81AD, 'return_from_dispatch')
d.label(0x8266, 'return_from_skip_separators')
cm(0x8AB2, 'X=0...')
cm(0x8AB4, '...and Y=&FF: read it without changing it')
d.banner(0x88D9, title='Poll the cursor keys',
    description="""Device mode &20. SHIFT adds an extra &40 to both speeds, so the pointer
accelerates five times as fast; then the cursor keys move it, each axis
resetting its speed when neither of its keys is pressed.""")
d.banner(0x86EC, title='Build the shifted copies for MODEs 1 and 5',
    description="""Three copies, each one pixel further right.""")
d.banner(0x8736, title='Build the shifted copies for MODEs 0 and 4',
    description="""Three copies, each two pixels further right.""")
d.banner(0x8773, title='Build the shifted copies for MODE 2',
    description="""A quarter of a screen byte is half a pixel, so the copies are the
original, the original again, one pixel right, and that again.""")

# === END OF ANNOTATIONS ===


for _addr in (0x8240, 0x8243, 0x8293, 0x82AC, 0x82B3, 0x82BA, 0x838C,
              0x8C0B, 0x8C48, 0x87C1, 0x8825, 0x865A, 0x87F3):
    d.entry(_addr)

ir = d.disassemble()
_output_dirpath.mkdir(parents=True, exist_ok=True)
(_output_dirpath / 'pmfs-136.asm').write_text(str(ir.render('beebasm')), encoding='utf-8')
(_output_dirpath / 'pmfs-136.json').write_text(str(ir.render('json')), encoding='utf-8')
