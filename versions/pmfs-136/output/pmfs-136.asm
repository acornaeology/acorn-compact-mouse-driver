; Constants
service_unrecognised_command         = &04
service_unrecognised_osbyte          = &07
service_polling_interrupt            = &15
service_reset                        = &27
pmfs_workspace_page                  = &91
osbyte_application                   = &a3
osbyte_a3_pmfs_colours               = &f3
osbyte_read_adc                      = &80
device_mode_mouse                    = &00
device_mode_keys                     = &20
device_mode_digital                  = &40
device_mode_joystick                 = &80
via_ier_enable_cb1_cb2               = &98
via_ier_disable_cb1_cb2              = &18
via_int_cb1                          = &10
via_int_cb2                          = &08
acccon_e                             = &02
acccon_x                             = &04
err_bad_number                       = &dc
key_return                           = &0d
key_right_button                     = &c0
vdu_set_palette                      = &13
ext_vector_offset_irq1v              = &06
ext_vector_offset_bytev              = &0f
opcode_jsr                           = &20
opcode_jmp                           = &4c
pointer_x_max                        = &04fc
pointer_y_max                        = &03fc
pointer_x_centre                     = &0280
pointer_y_centre                     = &0200
redraw_interval                      = &0a
pointer_image_size                   = &40
speed_shift_boost                    = &40
speed_acceleration                   = &10
speed_initial                        = &80
osbyte_decrement_polling_semaphore   = &17
osbyte_set_cursor_editing            = &04
osbyte_shift_fkey_status             = &e2
osbyte_increment_polling_semaphore   = &16
osbyte_read_rom_ptr_table_low        = &a8
osbyte_read_char_at_cursor           = &87
osbyte_read_adc_or_get_buffer_status = &80
osbyte_inkey                         = &81
osbyte_tab_char                      = &db
osbyte_insert_input_buffer           = &99
inkey_key_shift                      = &ff
inkey_key_left                       = &e6
inkey_key_right                      = &86
inkey_key_up                         = &c6
inkey_key_down                       = &d6

; Memory locations
zp_image_ptr               = &84  ; Pointer to the pointer image being drawn (the mask is the page above it). Also the source when building the pointer images, and the stored-workspace address in exchange_workspace.
; &84 referenced 24 times by &848c, &84cd, &84d1, &8564, &8576, &857d, &8583, &858c, &8667, &8691, &86ad, &86c4, &8701, &872a, &8745, &875c, &878b, &879d, &87b7, &8b73, &8b85, &8b8c, &8b92, &8b9b; also used as index base 2 times by &855c, &8597
zp_image_ptr_hi            = &85
; &85 referenced 14 times by &8487, &84cb, &84cf, &8567, &8572, &8589, &866e, &86b9, &86d2, &8724, &873f, &8b76, &8b81, &8b98
zp_under_ptr               = &86  ; Pointer to the buffer holding the screen bytes under the pointer (&9400). Also the destination when building the pointer images.
; &86 referenced 14 times by &84c9, &85b4, &85da, &8676, &8699, &86b1, &86c8, &8713, &8728, &872f, &8743, &8761, &879b, &87b9
zp_under_ptr_hi            = &87
; &87 referenced 7 times by &85b2, &867d, &86bb, &86d4, &8726, &8733, &8741
zp_temp                    = &88  ; Scratch: the high byte of a byte offset in calc_pointer_screen_address; the fill bit pattern (&00 for an image, &FF for a mask) when building shifted pointer images.
; &88 referenced 11 times by &80b2, &80be, &80c1, &80cb, &86bf, &86d6, &86f4, &870c, &874f, &877e, &8793
zp_row_in_cell             = &89  ; Offset of the current pixel row from the start of the current screen address, while drawing or removing the pointer. Also the destination index when copying the pointer images.
; &89 referenced 14 times by &84af, &84c3, &84d3, &84df, &84e1, &85c4, &85dc, &85e8, &85ea, &868d, &8693, &869b, &86a5, &86a7
zp_image_index             = &8a  ; Index into the 64-byte pointer image, mask and under-pointer buffer: 16 rows for each of 4 byte columns. Also the column offset when building shifted pointer images.
; &8a referenced 29 times by &84ab, &84c7, &84d7, &84d9, &8505, &8507, &850b, &8512, &8535, &85c0, &85d8, &85e0, &85e2, &862b, &8634, &863b, &8689, &868f, &8697, &86a3, &86fb, &86fe, &8715, &8756, &8759, &8763, &8785, &8788, &87a3
zp_skip_rows               = &8b  ; Scratch: rows to skip above the top of the screen in restore_screen_under_pointer.
; &8b referenced 2 times by &8644, &8648
zp_screen_ptr              = &8c  ; Screen address being drawn to. Also the destination when copying the pointer images into the bank.
; &8c referenced 23 times by &8064, &8069, &806c, &807c, &809c, &80a8, &80c7, &80c9, &80d8, &80da, &84a0, &84a6, &84c5, &84d5, &84e4, &84ed, &84f5, &8500, &852a, &8532, &8687, &8695, &869f
zp_screen_ptr_hi           = &8d
; &8d referenced 13 times by &8097, &80a3, &80cd, &80cf, &849d, &84a3, &84b1, &84f7, &84fc, &852f, &8685, &869d, &86a1
zp_drawn_ptr               = &8e  ; Screen address at which the pointer is drawn; bit 7 of the high byte set means nothing is drawn. Kept in saved_drawn_ptr between calls.
; &8e referenced 11 times by &8541, &854d, &85a2, &85bb, &85de, &85ed, &85f6, &85fe, &8620, &8628, &8640
zp_drawn_ptr_hi            = &8f
; &8f referenced 9 times by &83c2, &8544, &8552, &85a7, &85b6, &85c6, &8600, &8605, &8625
cmd_ptr                    = &a8  ; Pointer to the star command being decoded, and then to its arguments. Also the extended vector table address while the driver is turned on. In the MOS's command workspace (&A8-&AF).
; &a8 referenced 19 times by &8173, &8185, &818e, &81b6, &81cf, &81d1, &81d5, &8259, &82c6, &832a, &8346, &834b, &8350, &837e, &8383, &8388, &83a7, &8ba9, &8bee
cmd_ptr_hi                 = &a9
; &a9 referenced 2 times by &8179, &832c
cmd_handler_ptr            = &aa  ; Address of the star command handler, for the indirect jump through jump_to_command_handler.
; &aa referenced 2 times by &81df, &81f2
cmd_handler_ptr_hi         = &ab
; &ab referenced 1 time by &81da
osbyte_a                   = &ef  ; The A register of the current OSBYTE call, kept by the MOS for service call 7 (unrecognised OSBYTE).
; &ef referenced 1 time by &8033
osbyte_x                   = &f0  ; The X register of the current OSBYTE call, kept by the MOS for service call 7 (unrecognised OSBYTE).
; &f0 referenced 1 time by &8039
os_text_ptr                = &f2
; &f2 referenced 1 time by &8171
os_text_ptr_hi             = &f3
; &f3 referenced 1 time by &8175
romsel_copy                = &f4
; &f4 referenced 10 times by &805c, &834e, &8386, &8481, &856a, &85aa, &867f, &86b3, &86ca, &8b79
irq1v                      = &0204  ; Primary interrupt vector. While the driver is on, it points at the trampoline at irq1v_trampoline (&0D99); the previous value is kept in saved_irq1v.
; &0204 referenced 3 times by &8271, &8352, &8374
bytev                      = &020a  ; OSBYTE vector. While the driver is on, it points at bytev_extended_entry (&FF0F), so that OSBYTE calls reach bytev_handler; the previous value is kept in saved_bytev.
; &020a referenced 3 times by &827d, &832e, &833c
vdu_screen_start_hi        = &034e  ; VDU variable: high byte of the address of the first byte of screen memory. The pointer drawing routines do not draw rows whose address is below it, which are above the top of the screen.
; &034e referenced 2 times by &84b5, &85ca
saved_bytev                = &0d97  ; The value BYTEV had before the driver was turned on. OSBYTE calls the driver does not handle are passed on through it, and it is put back in BYTEV when the driver is turned off. Page &0D below the extended vector table, used by PMFS without any claim.
; &0d97 referenced 3 times by &827a, &8331, &87c5
saved_bytev_hi             = &0d98
; &0d98 referenced 2 times by &8280, &8337
irq1v_trampoline           = &0d99  ; Six bytes of code built by the driver when it is turned on: JSR irq1v_extended_entry : JMP old_irq1v_handler, where the JMP's operand is saved_irq1v. IRQ1V points here, so each interrupt first pages in PMFS and runs irq_handler, then continues to the previous IRQ1V handler.
; &0d99 referenced 1 time by &8360
irq1v_trampoline_target    = &0d9a
; &0d9a referenced 1 time by &8365
irq1v_trampoline_target_hi = &0d9b
; &0d9b referenced 1 time by &836a
irq1v_trampoline_jmp       = &0d9c
; &0d9c referenced 1 time by &836f
saved_irq1v                = &0d9d  ; The value IRQ1V had before the driver was turned on. It is also the operand of the JMP that ends irq1v_trampoline, and it is put back in IRQ1V when the driver is turned off.
; &0d9d referenced 2 times by &826e, &8355
saved_irq1v_hi             = &0d9e
; &0d9e referenced 2 times by &8274, &835b
rom_workspace_table        = &0df0  ; The MOS's table of sideways ROM private workspace pages, one byte per ROM. On every service call PMFS writes &91 into its own entry, then uses that entry to find the pages it keeps in its own bank: &9200 (pointer images), &9300 (pointer masks), &9400 (the screen under the pointer) and &9440 (the stored workspace).
; &0df0 used as index base 8 times by &8021, &8483, &856c, &85ac, &8681, &86b5, &86cc, &8b7b
acccon                     = &fe34
; &fe34 referenced 6 times by &83ec, &83fa, &8403, &842f, &843d, &8549
user_via_orb_irb           = &fe60
; &fe60 referenced 7 times by &87ff, &880d, &8a39, &8a47, &8acc, &8adf, &8b24
user_via_ddrb              = &fe62
; &fe62 referenced 1 time by &8303
user_via_acr               = &fe6b
; &fe6b referenced 2 times by &82f4, &82f9
user_via_pcr               = &fe6c
; &fe6c referenced 2 times by &82ec, &82f1
user_via_ifr               = &fe6d
; &fe6d referenced 1 time by &8830
user_via_ier               = &fe6e
; &fe6e referenced 5 times by &82fe, &830a, &83cf, &83e4, &8829
irq1v_extended_entry       = &ff06  ; Extended vector entry point for vector 2 (IRQ1V). Calling it pages in the ROM recorded in entry 2 of the extended vector table, calls the address held there, and pages the previous ROM back in. PMFS's IRQ1V trampoline calls it to run irq_handler.
bytev_extended_entry       = &ff0f  ; Extended vector entry point for vector 5 (BYTEV). PMFS points BYTEV here, and puts its OSBYTE handler in entry 5 of the extended vector table.
oswrch                     = &ffee  ; Write a character to the VDU stream. PMFS uses it only for the VDU 19 palette commands sent by *SETPAL.
; &ffee referenced 12 times by &80ef, &80f4, &80fa, &80ff, &8102, &8105, &810a, &810f, &8115, &811a, &811d, &8120
osbyte                     = &fff4  ; OSBYTE. PMFS reads the ADC and digital joystick (&80), the keyboard (&81), the screen mode (&87), the extended vector table address (&A8) and the TAB key's code (&DB); it sets the cursor-key behaviour (&04, &E2), the ROM polling semaphore (&16, &17) and inserts keys into the keyboard buffer (&99).
; &fff4 referenced 17 times by &8289, &829e, &82a7, &82dd, &8327, &838e, &8866, &889d, &88bb, &88df, &8907, &8918, &892c, &893d, &8a69, &8ab6, &8abf

cpu 1

    org &8000

.dasmos_start
; PMFS 136
; ***************************************************************************************
; Sideways ROM header — language-entry slot (3 bytes)
;
; MOS dispatches JMP &8000 on language startup.
;
; Service-only ROM (rom_type bit 6 clear). Per-byte detail is inline.
;
; Reason code in A on entry:
;
; | A | Meaning                                           |
; |---|---------------------------------------------------|
; | 0 | No language available — MOS calling Tube ROM      |
; | 1 | Normal startup                                    |
; | 2 | Request next byte of softkey expansion (Electron) |
; | 3 | Request length of softkey expansion (Electron)    |
.language_entry
    equb &00                            ; no-language sentinel (rom_type bit 6 clear)
    equb &00, &00                       ; unused padding
; ***************************************************************************************
; Service-entry slot (3 bytes)
;
; MOS calls JMP &8003 for service-call dispatch — unrecognised * commands, OSWORDs,
; OSBYTEs, *HELP, filing-system init / select, paged-ROM scans, and many other events.
; The reason code arrives in A.
.service_entry
    jmp service_handler                 ; Service entry: every service call comes here
; ***************************************************************************************
; ROM identification
;
; Six descriptive fields that follow the entry-point JMPs: ROM type flag byte,
; copyright-string offset, binary version, title string, optional version string, and
; copyright string. The MOS uses these for identification, dispatch-table lookup, and the
; (C)-prefix validity check.
.rom_type
; ***************************************************************************************
; ROM type byte
;
; | Bit | Value | Meaning                     |
; |-----|-------|-----------------------------|
; | 7   | 1     | Service entry present       |
; | 6   | 0     | No language entry           |
; | 5   | 0     | No Tube relocation          |
; | 4   | 0     | No Electron firmkey         |
; | 3-0 | 0010  | Processor: 6502 (non-BASIC) |
    equb %10000010                      ; ROM type
.copyright_offset
    equb copyright - language_entry     ; Offset of NUL preceding copyright (= &11 → copyright at &8011)
.binary_version
    equb &01                            ; Binary version: &01 (informational, not used by MOS)
.title
    equs "PMFS"
    equb &00                            ; NUL terminator
.version
    equs "136"
.copyright
    equb &00                            ; NUL preceding copyright string
.copyright_string
    equs "(C)1986 PMF"
    equb &00                            ; NUL terminator
; ***************************************************************************************
; Service call handler
;
; Entered through the service entry for every service call, with the reason code in A and
; the ROM number in X.
;
; On every call it first sets the ROM's entry in rom_workspace_table to &91, so that its
; private workspace is taken to be page &91 of its own bank; the drawing and workspace
; routines find their pages from that entry.
;
; Calls handled:
;
; | A   | Call                      | Action                                               |
; |-----|---------------------------|------------------------------------------------------|
; | &04 | Unrecognised star command | Decode and run a PMFS command (service_command)      |
; | &07 | Unrecognised OSBYTE       | Claim OSBYTE &A3 with X=&F3: set the desktop colours |
; | &15 | Polling interrupt         | Move the pointer, redraw it, read the buttons        |
; | &27 | Reset                     | Clear the driver state                               |
;
; Calls &04 and &15 are dispatched by dispatch_service; the others are handled here.
; Every exit goes through return_from_service, which puts the ROM number back in X.
;
; The reset call clears driver_on, pointer_shown, button_pending and device_mode with
; direct stores, without first exchanging the workspace (see exchange_workspace).
; device_mode lies outside the exchanged area and is cleared, but the other three are in
; it, so the stores reach the copy at &9000, not the copy at &9440 that the driver uses
; on its next call.
;
; On Entry:
;     A: service call number
;     X: this ROM's number
;     Y: service call parameter
;
; On Exit:
;     A: 0 if the call was claimed, otherwise preserved
;     X: this ROM's number
; &801e referenced 1 time by &8003
.service_handler
    pha                                 ; Save the service call number
    lda #pmfs_workspace_page            ; Private workspace page &91, in this bank...
    sta rom_workspace_table,x           ; ...goes in this ROM's workspace table entry
    pla                                 ; Recover the service call number
    jsr dispatch_service                ; Handle a command (&04) or a poll (&15)
    pha                                 ; Save the (possibly claimed) call number again
    cmp #service_reset                  ; Reset?
    beq reset_driver_state              ; Yes: clear the driver state
    cmp #service_unrecognised_osbyte    ; Unrecognised OSBYTE?
    bne return_from_service             ; No: return the call as it is
    phx                                 ; Keep X...
    phy                                 ; ...and Y for the OSBYTE caller
    lda osbyte_a                        ; Is the OSBYTE number &A3...
    cmp #osbyte_application             ; ...(application OSBYTE)?
    bne not_pmfs_osbyte                 ; No: not ours
    lda osbyte_x                        ; And is X &F3...
    cmp #osbyte_a3_pmfs_colours         ; ...the PMFS sub-call?
    bne not_pmfs_osbyte                 ; No: not ours
    jsr set_desktop_colours             ; Set the desktop colours from Y
    lda #0                              ; A=0: claim the call
    ply                                 ; Restore Y...
    plx                                 ; ...and X
    bra return_from_service             ; Return the call claimed
; &8048 referenced 2 times by &8037, &803d
.not_pmfs_osbyte
    lda #service_unrecognised_osbyte    ; A=7: leave the OSBYTE call unclaimed
    ply                                 ; Restore Y...
    plx                                 ; ...and X
    bra return_from_service             ; Return the call unclaimed
; &804e referenced 1 time by &802b
.reset_driver_state
    stz driver_on                       ; Driver off, in the copy at &9000 (see banner)
    stz pointer_shown                   ; Pointer not shown, in the copy at &9000
    stz button_pending                  ; No button change pending, in the copy at &9000
    stz device_mode                     ; Device mode back to mouse
    bra return_from_service             ; Return the call unclaimed
; &805c referenced 4 times by &802f, &8046, &804c, &805a
.return_from_service
    ldx romsel_copy                     ; Restore X: this ROM's number
    pla                                 ; A = the call number, or 0 if claimed
    rts                                 ; Return to the MOS
    equb &ea                            ; Unused (a NOP opcode)
; ***************************************************************************************
; Find the screen address of the top left of the pointer
;
; Turn the top left corner of the pointer image, pointer_left and pointer_top in graphics
; units, into a screen address and a shift.
;
; Graphics Y runs up the screen from 0 to 1023 in steps of 4 per pixel row, so
; pointer_top / 4 is a pixel row counted up from the bottom, and that / 8 is a character
; row counted up from the bottom. The character row indexes a table of row start
; addresses for the screen format (mode012_row_addr or mode45_row_addr), which counts up
; from the bottom row too and has two extra entries above the top of the screen. The
; pixel row within the character row is inverted (EOR 7) because screen rows run
; downwards.
;
; The byte column is pointer_left / 16 in MODEs 0-2 and pointer_left / 32 in MODEs 4 and
; 5, which is a screen offset of 8 bytes per column. A negative pointer_left (the pointer
; partly off the left edge) is handled without signed arithmetic: 1280 is added, which
; moves it to the right-hand end of the row below, and the row is moved up one to
; compensate.
;
; The shift is which quarter of a screen byte the image starts at, 0-3, used to choose
; one of the four shifted copies of the image.
;
; Rows above the top of the screen (pointer_top of 1024 or more) take the two extra table
; entries. Their addresses are below the start of screen memory, so the drawing routines
; skip them.
;
; On Entry:
;     POINTER_LEFT: X of the left edge of the image
;     POINTER_TOP: Y of the top edge of the image
;
; On Exit:
;     ZP_SCREEN_PTR: screen address of the top left byte
;     X: shift, 0-3 (which shifted copy of the image to use)
;     POINTER_TOP: pixel row (Y / 4), possibly inverted
;     A: corrupted
;     Y: preserved
; &8061 referenced 1 time by &847e
.calc_pointer_screen_address
    lda pointer_top_hi                  ; Pixel row = pointer_top / 4: take the high byte
    sta zp_screen_ptr                   ; ...into a scratch byte
    lda pointer_top                     ; and the low byte
    lsr zp_screen_ptr                   ; Divide by 2...
    ror a                               ; ...through both bytes
    lsr zp_screen_ptr                   ; and by 2 again
    ror a                               ; ...(carry bit 8 of the row stays in zp_screen_ptr)
    sta pointer_top                     ; Keep the pixel row, 0-255 on the screen
    lsr a                               ; Character row = pixel row / 8...
    lsr a                               ; ...
    lsr a                               ; ...counted up from the bottom
    tax                                 ; X = character row, indexing the row tables
    lda pointer_left_hi                 ; Is the image's left edge negative?
    bpl check_above_screen              ; No
    inx                                 ; Yes: one row up, to undo the +1280 applied below
; &807c referenced 1 time by &8079
.check_above_screen
    lda zp_screen_ptr                   ; Is the pixel row 256 or more (above the screen)?
    beq look_up_row_address             ; No
    txa                                 ; Yes: use the extra table entries above the top...
    clc                                 ; ...
    adc #&20 ; ' '                      ; ...32 rows up
    tax                                 ; ...
    lda pointer_top                     ; and invert the pixel row within the character
    eor #7                              ; row, so that the EOR below cancels it out
    sta pointer_top                     ; ...
; &808d referenced 1 time by &807e
.look_up_row_address
    lda screen_format                   ; Which screen format?
    cmp #3                              ; MODEs 4 and 5 (formats 3 and 4)?
    bcs look_up_mode45_row_address      ; Yes: use the 320-byte row table
    lda mode012_row_addr_hi,x           ; MODEs 0-2: row address high byte...
    sta zp_screen_ptr_hi                ; ...
    lda mode012_row_addr_lo,x           ; and low byte, from the 640-byte row table
    sta zp_screen_ptr                   ; ...
    bra add_column_offset               ; Go and add the column
; &80a0 referenced 1 time by &8092
.look_up_mode45_row_address
    lda mode45_row_addr_hi,x            ; MODEs 4 and 5: row address high byte...
    sta zp_screen_ptr_hi                ; ...
    lda mode45_row_addr_lo,x            ; and low byte
    sta zp_screen_ptr                   ; ...
; &80aa referenced 1 time by &809e
.add_column_offset
    lda pointer_left_hi                 ; High byte of the left edge
    bpl store_column_offset_hi          ; Positive: use it as it is
    clc                                 ; Negative: add 1280 (&500), wrapping to the right
    adc #5                              ; end of the row below
; &80b2 referenced 1 time by &80ad
.store_column_offset_hi
    sta zp_temp                         ; Keep the high byte
    lda pointer_left                    ; Low byte of the left edge
    ldx screen_format                   ; Which screen format?
    cpx #3                              ; MODEs 4 and 5?
    bcc halve_column_offset             ; No: 16 units a byte, so offset = X / 2
    lsr zp_temp                         ; Yes: 32 units a byte, so offset = X / 4:
    ror a                               ; one extra halving
; &80c1 referenced 1 time by &80bc
.halve_column_offset
    lsr zp_temp                         ; Halve the left edge...
    ror a                               ; ...
    and #&f8                            ; Round down to a whole byte column (8 bytes each)
    clc                                 ; Add the column offset...
    adc zp_screen_ptr                   ; ...to the row address
    sta zp_screen_ptr                   ; ...
    lda zp_temp                         ; and the high byte
    adc zp_screen_ptr_hi                ; ...
    sta zp_screen_ptr_hi                ; ...
    lda pointer_top                     ; Pixel row within the character row...
    and #7                              ; ...
    eor #7                              ; ...counted down from the top of it
    ora zp_screen_ptr                   ; is the byte within the character cell
    sta zp_screen_ptr                   ; ...
    lda pointer_left                    ; Left edge again, for the shift
    ldx screen_format                   ; Which screen format?
    cpx #3                              ; MODEs 4 and 5?
    bcc calc_shift                      ; No: shift = (X / 4) MOD 4
    lsr a                               ; Yes: shift = (X / 8) MOD 4
; &80e7 referenced 1 time by &80e4
.calc_shift
    lsr a                               ; Quarter-byte steps...
    lsr a                               ; ...
    and #3                              ; ...within the byte
    tax                                 ; X = shift, 0-3
    rts                                 ; Return
; ***************************************************************************************
; *SETPAL: set the desktop colours
;
; Send VDU 19,0,c0,0,0,0 and VDU 19,1,c1,0,0,0, setting logical colours 0 and 1 to the
; physical colours in desktop_colours, which OSBYTE &A3,&F3 chooses. The command takes no
; arguments, and it works whether or not the driver is on.
;
; On Exit:
;     A: corrupted
.cmd_setpal
    lda #vdu_set_palette                ; VDU 19: define a logical colour...
    jsr oswrch                          ; ...
    lda #0                              ; logical colour 0...
    jsr oswrch                          ; ...
    lda desktop_colours                 ; physical colour: desktop colour 0...
    jsr oswrch                          ; ...
    lda #0                              ; and three zero bytes...
    jsr oswrch                          ; ...
    jsr oswrch                          ; ...
    jsr oswrch                          ; ...
    lda #vdu_set_palette                ; VDU 19 again...
    jsr oswrch                          ; ...
    lda #1                              ; logical colour 1...
    jsr oswrch                          ; ...
    lda desktop_colour_1                ; physical colour: desktop colour 1...
    jsr oswrch                          ; ...
    lda #0                              ; and three zero bytes...
    jsr oswrch                          ; ...
    jsr oswrch                          ; ...
    jsr oswrch                          ; ...
    rts                                 ; Return
; ***************************************************************************************
; Set the default desktop colours
;
; Set desktop colour 0 to 6 (cyan) and desktop colour 1 to 4 (blue). Reached from
; set_desktop_colours when bit 7 of Y is set.
; &8124 referenced 1 time by &814a
.reset_desktop_colours
    lda #6                              ; Colour 0 = 6, cyan
    sta desktop_colours                 ; ...
    lda #4                              ; Colour 1 = 4, blue
    sta desktop_colour_1                ; ...
    rts                                 ; Return
; ***************************************************************************************
; Step a desktop colour to the next physical colour
;
; Advance the desktop colour chosen by bit 3 of Y to the next physical colour, 0-7,
; wrapping round, and skipping the colour the other desktop colour has, so that the two
; never match. Reached from set_desktop_colours when bit 6 of Y is set.
;
; On Entry:
;     Y: bit 3: which colour to step (0 or 1)
; &812f referenced 1 time by &814d
.step_desktop_colour
    tya                                 ; Bit 3 of Y...
    lsr a                               ; ...
    lsr a                               ; ...
    lsr a                               ; ...
    and #1                              ; ...selects the colour to step
    tax                                 ; X = that colour
    eor #1                              ; Y = the other one
    tay                                 ; ...
    lda desktop_colours,x               ; Current physical colour
; &813c referenced 1 time by &8142
.try_next_colour
    inc a                               ; Next physical colour...
    and #7                              ; ...modulo 8
    cmp desktop_colours,y               ; Same as the other desktop colour?
    beq try_next_colour                 ; Yes: skip it
    sta desktop_colours,x               ; Store the new colour
    rts                                 ; Return
; ***************************************************************************************
; OSBYTE &A3,&F3: set the desktop colours
;
; Handle OSBYTE &A3 with X=&F3, according to Y:
;
; | Y         | Effect                                            |
; |-----------|---------------------------------------------------|
; | bit 7 set | Reset both colours to the defaults (6 and 4)      |
; | bit 6 set | Step colour (Y bit 3) to the next physical colour |
; | otherwise | Set colour (Y bit 3) to physical colour Y AND 7   |
;
; The colours are only stored; *SETPAL sends them to the VDU. service_handler returns X
; and Y to the OSBYTE caller unchanged.
;
; On Entry:
;     Y: the OSBYTE's Y parameter
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: corrupted
; &8148 referenced 1 time by &803f
.set_desktop_colours
    tya                                 ; Bit 7 of Y...
    rol a                               ; ...into carry
    bcs reset_desktop_colours           ; Set: reset both colours
    rol a                               ; Bit 6 into carry
    bcs step_desktop_colour             ; Set: step a colour
    tya                                 ; Bit 3 of Y...
    lsr a                               ; ...
    lsr a                               ; ...
    lsr a                               ; ...
    and #1                              ; ...selects the colour
    tax                                 ; ...
    tya                                 ; Bits 0-2...
    and #7                              ; ...are the physical colour
    sta desktop_colours,x               ; Store it
    rts                                 ; Return
; ***************************************************************************************
; Handle the polling and star command service calls
;
; Called from service_handler with the service call number in A. On a poll (&15), move
; the pointer for the joystick or keys, then redraw it and read the buttons; the call is
; not claimed. On an unrecognised star command (&04), decode it. Other calls return at
; once.
;
; On Entry:
;     A: service call number
;     Y: for &04, the offset of the command at (os_text_ptr)
;
; On Exit:
;     A: 0 if a command was run, otherwise preserved
;     X: preserved
;     Y: preserved
; &815d referenced 1 time by &8025
.dispatch_service
    cmp #service_polling_interrupt      ; Polling interrupt?
    bne service_command                 ; No
    jsr poll_move_pointer               ; Yes: move the pointer for joystick or keys
    jmp poll_redraw_and_buttons         ; then redraw and read the buttons, and return
; ***************************************************************************************
; Decode a star command
;
; Service call &04. Match the command at (os_text_ptr),Y against command_table, ignoring
; case. A name may be abbreviated with a full stop after at least one letter; otherwise
; the name must be followed by a space or the end of the line. The first table entry that
; matches is run; if the whole name matched but is followed by anything else, the command
; is left for other ROMs without trying further entries.
;
; On a match, cmd_ptr is moved past the name and any spaces or commas, interrupts are
; disabled, the driver's workspace is brought in (enter_driver), the handler is called
; with Y=0, and the workspace is put back (leave_driver). The call is then claimed. The
; handler runs with interrupts disabled throughout; the caller's flags are restored on
; return.
;
; When moving cmd_ptr past the name, a carry out of the low byte increments the low byte
; instead of the high byte, so a command whose arguments start on a later page than its
; name is read from the wrong place.
; &8167 referenced 1 time by &815f
.service_command
    cmp #service_unrecognised_command   ; Unrecognised star command?
    bne return_from_dispatch            ; No: return
    php                                 ; Save the flags
    pha                                 ; and the registers
    phx                                 ; ...
    phy                                 ; ...
    tya                                 ; cmd_ptr = os_text_ptr + Y,
    clc                                 ; the start of the command
    adc os_text_ptr                     ; ...
    sta cmd_ptr                         ; ...
    lda os_text_ptr_hi                  ; ...
    adc #0                              ; ...
    sta cmd_ptr_hi                      ; ...
    ldy #0                              ; From its first character
    jsr skip_separators                 ; skip leading spaces and commas
    ldx #0                              ; X = offset into command_table
    sty cmd_start_offset                ; Remember where the name starts
; &8185 referenced 2 times by &81a7, &81b0
.match_command_char
    lda (cmd_ptr),y                     ; Next character of the command...
    and #&df                            ; ...in upper case
    cmp command_table,x                 ; Same as the table?
    beq next_command_char               ; Yes: compare the next one
    lda (cmd_ptr),y                     ; No: is it a full stop (an abbreviation)?
    cmp #&2e ; '.'                      ; ...
    beq command_abbreviated             ; Yes: accept the name so far
    lda command_table,x                 ; Has the table name ended (address byte)?
    bmi command_name_matched            ; Yes: the whole name matched
    ldy cmd_start_offset                ; No match: back to the start of the command
; &819c referenced 1 time by &81a0
.skip_to_next_command
    inx                                 ; Skip the rest of this table name...
    lda command_table,x                 ; ...up to its address byte
    bpl skip_to_next_command            ; ...
    inx                                 ; and the two address bytes
    inx                                 ; ...
    lda command_table,x                 ; End of the table (&FF)?
    bpl match_command_char              ; No: try this entry
; ***************************************************************************************
; Restore the registers and flags and return
;
; Pull Y, X, A and the flags, pushed in that order's reverse by the caller, and return.
; Used to leave service_command without claiming the call, and as the common exit of
; irq_handler, poll_move_pointer and poll_redraw_and_buttons.
;
; On Exit:
;     A: restored
;     X: restored
;     Y: restored
;     FLAGS: restored
; &81a9 referenced 4 times by &81be, &8841, &88d6, &8a2a
.restore_registers_and_return
    ply                                 ; Restore Y
    plx                                 ; X
    pla                                 ; A
    plp                                 ; and the flags
; &81ad referenced 1 time by &8169
.return_from_dispatch
    rts                                 ; Return
; &81ae referenced 1 time by &818c
.next_command_char
    inx                                 ; Next table character
    iny                                 ; and next command character
    bne match_command_char              ; Always taken (Y does not wrap)
; &81b2 referenced 1 time by &8192
.command_abbreviated
    iny                                 ; Step past the full stop
    bne find_handler_address            ; Always taken: no terminator check after a stop
; &81b5 referenced 1 time by &8197
.command_name_matched
    dex                                 ; Back onto the last name character
    lda (cmd_ptr),y                     ; The name must be followed by...
    cmp #ASC(" ")                       ; ...a space
    beq find_handler_address            ; ...
    cmp #key_return                     ; ...or the end of the line
    bne restore_registers_and_return    ; Neither: not a PMFS command after all
; &81c0 referenced 3 times by &81b3, &81ba, &81c4
.find_handler_address
    inx                                 ; Find the address bytes after the name
    lda command_table,x                 ; ...
    bpl find_handler_address            ; ...
    cpx #&4b ; 'K'                      ; Index &4B: no entry's address is here, so this
    beq advance_to_arguments            ; never branches
    jsr skip_separators                 ; Skip spaces and commas before the arguments
; &81cd referenced 1 time by &81c8
.advance_to_arguments
    tya                                 ; cmd_ptr += Y: point at the arguments
    clc                                 ; ...
    adc cmd_ptr                         ; ...
    sta cmd_ptr                         ; ...
    bcc call_command_handler            ; ...
    inc cmd_ptr                         ; Carry: increments the low byte, not the high byte
; &81d7 referenced 1 time by &81d3
.call_command_handler
    lda command_table,x                 ; Handler address, high byte first...
    sta cmd_handler_ptr_hi              ; ...
    lda command_table + 1,x             ; then low byte
    sta cmd_handler_ptr                 ; ...
    sei                                 ; Interrupts off while the workspace is in use
    jsr enter_driver                    ; Bring in the workspace, save zero page
    jsr jump_to_command_handler         ; Run the command
    jsr leave_driver                    ; Put back zero page and the workspace
    ply                                 ; Restore Y
    plx                                 ; and X
    pla                                 ; Discard the saved call number
    lda #0                              ; A=0: claim the call
    plp                                 ; Restore the caller's flags
    rts                                 ; Return
; ***************************************************************************************
; Jump to the command handler
;
; Called by service_command so that the handler's RTS returns to it.
; &81f2 referenced 1 time by &81e5
.jump_to_command_handler
    jmp (cmd_handler_ptr)               ; Jump to the handler at cmd_handler_ptr
; ***************************************************************************************
; Star command table
;
; Each entry is a command name in upper case, followed by the address of its handler,
; high byte first. The high byte has bit 7 set, which ends the name; the table ends with
; &FF. *MOUSE and *TRACKERBALL share a handler. TSET's low address byte happens to be
; &48, the code for "H".
;
; | Command      | Handler      |
; |--------------|--------------|
; | *KEYS        | cmd_keys     |
; | *DIGITAL     | cmd_digital  |
; | *JOYSTICK    | cmd_joystick |
; | *MOUSE       | cmd_mouse    |
; | *POINTER     | cmd_pointer  |
; | *TMAX        | cmd_tmax     |
; | *TRACKERBALL | cmd_mouse    |
; | *TSET        | cmd_tset     |
; | *SETPAL      | cmd_setpal   |
;
; Entries are tried in order, so an abbreviation takes the first command it fits: *T. is
; *TMAX and *M. is *MOUSE.
; &81f5 used as index base 1 time by &8189
.command_table
    equs "KEYS"                         ; *KEYS
    equb >(cmd_keys)                    ; Handler cmd_keys, high byte (bit 7 ends the name)
    equb <(cmd_keys)                    ; and low byte
    equs "DIGITAL"                      ; *DIGITAL
    equb >(cmd_digital)                 ; Handler cmd_digital, high byte (bit 7 ends the name)
    equb <(cmd_digital)                 ; and low byte
    equs "JOYSTICK"                     ; *JOYSTICK
    equb >(cmd_joystick)                ; Handler cmd_joystick, high byte (bit 7 ends the name)
    equb <(cmd_joystick)                ; and low byte
    equs "MOUSE"                        ; *MOUSE
    equb >(cmd_mouse)                   ; Handler cmd_mouse, high byte (bit 7 ends the name)
    equb <(cmd_mouse)                   ; and low byte
    equs "POINTER"                      ; *POINTER
    equb >(cmd_pointer)                 ; Handler cmd_pointer, high byte (bit 7 ends the name)
    equb <(cmd_pointer)                 ; and low byte
    equs "TMAX"                         ; *TMAX
    equb >(cmd_tmax)                    ; Handler cmd_tmax, high byte (bit 7 ends the name)
    equb <(cmd_tmax)                    ; and low byte
    equs "TRACKERBALL"                  ; *TRACKERBALL
    equb >(cmd_mouse)                   ; Handler cmd_mouse, high byte (bit 7 ends the name)
    equb <(cmd_mouse)                   ; and low byte
    equs "TSET"                         ; *TSET
    equb >(cmd_tset)                    ; Handler cmd_tset, high byte (bit 7 ends the name)
    equb <(cmd_tset)                    ; and low byte
    equs "SETPAL"                       ; *SETPAL
    equb >(cmd_setpal)                  ; Handler cmd_setpal, high byte (bit 7 ends the name)
    equb <(cmd_setpal)                  ; and low byte
    equb &ff                            ; End of the table
; ***************************************************************************************
; Point Y at the first argument
;
; Set Y=0, the first character at cmd_ptr, which service_command has left pointing at the
; command's arguments.
;
; On Exit:
;     Y: 0
; &8240 referenced 4 times by &82c3, &83a4, &8c0b, &8c48
.reset_argument_index
    ldy #0                              ; Offset 0 from cmd_ptr
    rts                                 ; Return
; ***************************************************************************************
; Check that a character is a decimal digit
;
; Return if A is "0"-"9"; otherwise raise error &DC, "Bad number".
;
; On Entry:
;     A: character
;
; On Exit:
;     A: preserved
;     FLAGS: C set
; &8243 referenced 1 time by &8bb7
.check_digit
    cmp #ASC("0")                       ; Below "0"?
    bcc bad_number_error                ; Yes: bad number
    cmp #ASC(":")                       ; Above "9"?
    bcs bad_number_error                ; Yes: bad number
    rts                                 ; A digit: return
; ***************************************************************************************
; Error &DC, "Bad number"
;
; A BRK error block, raised by falling into it from check_digit, or by jumping to it from
; *TMAX and *TSET.
; &824c referenced 3 times by &8245, &8249, &8c45
.bad_number_error
    brk                                 ; BRK: raise an error
    equb err_bad_number                 ; Error number
    equs "Bad number"                   ; Error message
    equb &00                            ; End of the message
; ***************************************************************************************
; Skip spaces and commas
;
; Advance Y past any spaces and commas at (cmd_ptr),Y.
;
; On Entry:
;     Y: offset into the command line
;
; On Exit:
;     Y: offset of the next other character
;     A: that character
; &8259 referenced 5 times by &817d, &81ca, &8264, &8c1b, &8c58
.skip_separators
    lda (cmd_ptr),y                     ; Next character
    cmp #ASC(",")                       ; A comma?
    beq skip_separator                  ; Yes: skip it
    cmp #ASC(" ")                       ; A space?
    bne return_from_skip_separators     ; No: done
; &8263 referenced 1 time by &825d
.skip_separator
    iny                                 ; Step past it
    bne skip_separators                 ; Always taken (Y does not wrap)
; &8266 referenced 1 time by &8261
.return_from_skip_separators
    rts                                 ; Return
; ***************************************************************************************
; Turn the driver off
;
; Reached from select_device when a device command's argument is 0 (for example *MOUSE
; 0). If the driver is on: put back the IRQ1V and BYTEV values saved when it was turned
; on, stop the polling service calls (OSBYTE &17), disable the mouse interrupts, remove
; the pointer, and mark the driver off. The extended vector table entries it set are left
; as they are. device_mode is not changed.
; &8267 referenced 1 time by &82ca
.turn_driver_off
    lda driver_on                       ; Is the driver on?
    beq return_from_device_command      ; No: nothing to do
    php                                 ; Interrupts off while the vectors change
    sei                                 ; ...
    lda saved_irq1v                     ; Put back the old IRQ1V...
    sta irq1v                           ; ...
    lda saved_irq1v_hi                  ; ...
    sta irq1v + 1                       ; ...
    lda saved_bytev                     ; and the old BYTEV
    sta bytev                           ; ...
    lda saved_bytev_hi                  ; ...
    sta bytev + 1                       ; ...
    plp                                 ; Interrupts back as they were
    lda #osbyte_decrement_polling_semaphore  ; OSBYTE &17: decrement the ROM polling semaphore,
    jsr osbyte                          ; ending the polling service calls  Electron and Master: Decrement polling semaphore
    jsr remove_pointer_and_mouse        ; Disable the mouse interrupts, remove the pointer
    stz driver_on                       ; The driver is off
; &8292 referenced 2 times by &826a, &82cf
.return_from_device_command
    rts                                 ; Return
; ***************************************************************************************
; *KEYS: steer the pointer with the cursor keys
;
; Select device mode &20. *FX4,2 makes the cursor keys act as function keys, and *FX226,0
; makes the MOS ignore SHIFT with the function keys, so that the cursor keys, now
; steering the pointer, are not seen as cursor editing. Neither setting is undone when
; another device is chosen or the driver is turned off. Continues at select_device.
.cmd_keys
    lda #device_mode_keys               ; Device mode: cursor keys
    sta device_mode                     ; ...
    lda #osbyte_set_cursor_editing      ; OSBYTE 4 with X=2:
    ldx #2                              ; cursor keys act as function keys
    ldy #0                              ; ...
    jsr osbyte                          ; ...  Set cursor editing keys
    lda #osbyte_shift_fkey_status       ; OSBYTE &E2 with X=0, Y=0:
    ldx #0                              ; SHIFT with a function key is ignored
    ldy #0                              ; ...
    jsr osbyte                          ; ...  osbyte: shift fkey status
    bra select_device                   ; Go on to select the device
; ***************************************************************************************
; *DIGITAL: steer the pointer with a digital joystick
;
; Select device mode &40, in which the pointer follows the direction bits the MOS returns
; from ADVAL(0). Continues at select_device.
.cmd_digital
    lda #device_mode_digital            ; Device mode: digital joystick
    sta device_mode                     ; ...
    bra select_device                   ; Go on to select the device
; ***************************************************************************************
; *JOYSTICK: steer the pointer with an analogue joystick
;
; Select device mode &80, in which the pointer follows ADVAL(1) and ADVAL(2). Continues
; at select_device.
.cmd_joystick
    lda #device_mode_joystick           ; Device mode: analogue joystick
    sta device_mode                     ; ...
    bra select_device                   ; Go on to select the device
; ***************************************************************************************
; *MOUSE and *TRACKERBALL: move the pointer with a mouse
;
; Select device mode 0, in which the pointer is moved by the User VIA's CB1 and CB2
; interrupts (irq_handler). Falls into select_device.
.cmd_mouse
    stz device_mode                     ; Device mode: mouse or trackerball
; ***************************************************************************************
; Select a device, and turn the driver on or off
;
; Common tail of the device commands, with device_mode already set. The joystick and key
; speeds are reset. If the argument starts with "0" the driver is turned off
; (turn_driver_off). Otherwise, if the driver is already on, nothing more is done: only
; the device mode has changed. In particular the mouse interrupts are not enabled or
; disabled to suit the new mode until *POINTER shows the pointer again, which is why
; software switches devices with, for example, *DIGITAL 0 then *MOUSE.
;
; If the driver is off, it is turned on:
;
; - driver_on is set, the pointer is marked not shown, and no button change is pending;
; - OSBYTE &16 starts the polling service calls;
; - the mouse pinout is marked as not yet detected;
; - in mouse mode the User VIA is set up for the mouse: CB1 and CB2 interrupt on a
;   falling edge, port latching off, CB1 and CB2 interrupts enabled and port B all
;   inputs; in other modes the CB1 and CB2 interrupts are disabled;
; - the pointer is put in the middle of the screen, at (640, 512);
; - BYTEV is pointed at the extended vector entry for BYTEV, and the extended vector
;   table entry at bytev_handler in this ROM;
; - IRQ1V is pointed at irq1v_trampoline, which is built here, and the extended vector
;   table entry for IRQ1V is pointed at irq_handler in this ROM. IRQ1V does not point at
;   that entry itself: the trampoline calls it, so that when irq_handler returns, the
;   previous ROM is paged back in and the trampoline continues to the old IRQ1V handler.
;
; In both cases the low byte of the extended vector entry point (&0F, &06) is also the
; offset of the vector's entry in the table, three times the vector number, so one
; register load serves for both.
;
; The pointer is not shown; that takes *POINTER.
; &82bd referenced 3 times by &82aa, &82b1, &82b8
.select_device
    jsr reset_x_speed                   ; Horizontal speed back to the start
    jsr reset_y_speed                   ; Vertical speed back to the start
    jsr reset_argument_index            ; First argument character
    lda (cmd_ptr),y                     ; ...
    cmp #ASC("0")                       ; Is it "0"?
    beq turn_driver_off                 ; Yes: turn the driver off
    ldx driver_on                       ; Is the driver already on?
    bne return_from_device_command      ; Yes: just the mode has changed
    stx button_pending                  ; X=0: no button change pending
    stx pointer_shown                   ; pointer not shown
    dex                                 ; X=&FF...
    stx driver_on                       ; ...the driver is on
    lda #osbyte_increment_polling_semaphore  ; OSBYTE &16: increment the ROM polling semaphore,
    jsr osbyte                          ; so that the MOS issues service call &15 every 10 ms  Electron and Master: Increment polling semaphore
    php                                 ; Interrupts off while the hardware and vectors
    sei                                 ; are set up
    lda #&ff                            ; Mouse pinout not yet detected
    sta pinout_index                    ; ...
    lda device_mode                     ; Mouse mode?
    bne disable_mouse_interrupts        ; No: disable the mouse interrupts
    lda user_via_pcr                    ; User VIA PCR: clear bits 4-7, so CB1 and CB2
    and #&0f                            ; are inputs that interrupt on a falling edge
    sta user_via_pcr                    ; ...
    lda user_via_acr                    ; User VIA ACR: clear bits 0-1,
    and #&fc                            ; port A and B latching off
    sta user_via_acr                    ; ...
    lda #via_ier_enable_cb1_cb2         ; IER: enable the CB1 and CB2 interrupts
    sta user_via_ier                    ; ...
    lda #0                              ; DDRB = 0: port B all inputs
    sta user_via_ddrb                   ; ...
    bra centre_pointer                  ; Go on to place the pointer
; &8308 referenced 1 time by &82ea
.disable_mouse_interrupts
    lda #via_ier_disable_cb1_cb2        ; IER: disable the CB1 and CB2 interrupts
    sta user_via_ier                    ; ...
; &830d referenced 1 time by &8306
.centre_pointer
    lda #<(pointer_x_centre)            ; Pointer X = 640 (&280)
    sta pointer_x                       ; ...
    lda #>(pointer_x_centre)            ; ...
    sta pointer_x_hi                    ; ...
    lda #<(pointer_y_centre)            ; Pointer Y = 512 (&200)
    sta pointer_y                       ; ...
    lda #>(pointer_y_centre)            ; ...
    sta pointer_y_hi                    ; ...
    lda #osbyte_read_rom_ptr_table_low  ; OSBYTE &A8: read the address of the extended
    ldx #0                              ; vector table
    ldy #&ff                            ; ...
    jsr osbyte                          ; ...  Read low byte of ROM pointer table address
    stx cmd_ptr                         ; Keep it in cmd_ptr
    sty cmd_ptr_hi                      ; ...
    lda bytev                           ; Save the current BYTEV...
    sta saved_bytev                     ; ...
    lda bytev + 1                       ; ...
    sta saved_bytev_hi                  ; ...
    ldy #<(bytev_extended_entry)        ; BYTEV = &FF0F, the extended vector entry for
    sty bytev                           ; BYTEV; &0F is also its offset in the table
    ldx #>(bytev_extended_entry)        ; ...
    stx bytev + 1                       ; ...
    lda #<(bytev_handler)               ; Table entry for BYTEV: address of bytev_handler
    sta (cmd_ptr),y                     ; ...
    lda #>(bytev_handler)               ; ...
    iny                                 ; ...
    sta (cmd_ptr),y                     ; ...
    iny                                 ; and the ROM number, this ROM
    lda romsel_copy                     ; ...
    sta (cmd_ptr),y                     ; ...
    lda irq1v                           ; Save the current IRQ1V; it is also the operand
    sta saved_irq1v                     ; of the JMP ending the trampoline
    lda irq1v + 1                       ; ...
    sta saved_irq1v_hi                  ; ...
    lda #opcode_jsr                     ; Build the trampoline: JSR...
    sta irq1v_trampoline                ; ...
    ldy #<(irq1v_extended_entry)        ; &FF06, the extended vector entry for IRQ1V;
    sty irq1v_trampoline_target         ; &06 is also its offset in the table
    lda #>(irq1v_extended_entry)        ; ...
    sta irq1v_trampoline_target_hi      ; ...
    lda #opcode_jmp                     ; then JMP (to the old IRQ1V handler)
    sta irq1v_trampoline_jmp            ; ...
    lda #<(irq1v_trampoline)            ; IRQ1V = the trampoline
    sta irq1v                           ; ...
    lda #>(irq1v_trampoline)            ; ...
    sta irq1v + 1                       ; ...
    lda #<(irq_handler)                 ; Table entry for IRQ1V: address of irq_handler
    sta (cmd_ptr),y                     ; ...
    iny                                 ; ...
    lda #>(irq_handler)                 ; ...
    sta (cmd_ptr),y                     ; ...
    iny                                 ; ...
    lda romsel_copy                     ; and the ROM number, this ROM
    sta (cmd_ptr),y                     ; ...
    plp                                 ; Interrupts back as they were
    rts                                 ; Return
; ***************************************************************************************
; *POINTER: show or remove the pointer
;
; Record the screen format for the current mode, then act on the first argument
; character:
;
; | Argument               | Effect                                              |
; |------------------------|-----------------------------------------------------|
; | 0                      | Remove the pointer                                  |
; | 2                      | Disable the mouse interrupts and remove the pointer |
; | anything else, or none | Show the pointer                                    |
;
; The screen format is 0, 1 or 2 in MODEs 0, 1 and 2, and 3 or 4 in MODEs 4 and 5 (a
; shadow mode counts as its non-shadow equivalent). In MODEs 3, 6 and 7, which have no
; pointer images, the command does nothing.
;
; Showing the pointer needs the driver to be on, and does nothing if the pointer is
; already shown. It enables the mouse interrupts if the device is the mouse and disables
; them otherwise, builds the four shifted copies of the pointer image and mask for the
; screen format, and draws the pointer.
.cmd_pointer
    lda #osbyte_read_char_at_cursor     ; OSBYTE &87: read the screen mode into Y
    jsr osbyte                          ; ...  Read character at text cursor position and current screen MODE
    tya                                 ; Mode number...
    and #7                              ; ...ignoring the shadow bit
    cmp #3                              ; MODE 0, 1 or 2?
    bcc set_screen_format               ; Yes: screen format = mode
    cmp #3                              ; MODE 3?
    beq return_from_pointer             ; Yes: no pointer in a text mode
    cmp #6                              ; MODE 6 or 7?
    bcs return_from_pointer             ; Yes: no pointer in a text mode
    dec a                               ; MODE 4 or 5: screen format 3 or 4
; &83a1 referenced 1 time by &8396
.set_screen_format
    sta screen_format                   ; Record the screen format
    jsr reset_argument_index            ; First argument character...
    lda (cmd_ptr),y                     ; ...
    sec                                 ; as a digit
    sbc #ASC("0")                       ; ...
    beq remove_pointer                  ; 0: remove the pointer
    cmp #2                              ; 2?
    beq remove_pointer_and_mouse        ; Yes: disable the mouse, remove the pointer
    lda driver_on                       ; Show it: is the driver on?
    beq return_from_pointer             ; No: nothing to do
    lda pointer_shown                   ; Is the pointer already shown?
    bne return_from_pointer             ; Yes: nothing to do
    lda driver_on                       ; &FF...
    sta pointer_shown                   ; ...the pointer is shown
    sta zp_drawn_ptr_hi                 ; and nothing has been drawn yet (bit 7 set)
    lda device_mode                     ; Mouse mode?
    bne pointer_mouse_interrupts_off    ; No: disable the mouse interrupts
    lda #via_ier_enable_cb1_cb2         ; Yes: enable them
    bra set_mouse_interrupts            ; ...
; &83cd referenced 1 time by &83c7
.pointer_mouse_interrupts_off
    lda #via_ier_disable_cb1_cb2        ; Disable the CB1 and CB2 interrupts
; &83cf referenced 1 time by &83cb
.set_mouse_interrupts
    sta user_via_ier                    ; ...
    lda #0                              ; Build the shifted pointer images and masks
    jsr build_pointer_images            ; ...
    ldy pointer_x                       ; Make drawn_x differ from pointer_x...
    dey                                 ; ...
    sty drawn_x                         ; ...so that the pointer is drawn
    jmp update_pointer                  ; Draw it
; &83e1 referenced 6 times by &839a, &839e, &83b5, &83ba, &83ea, &842d
.return_from_pointer
    rts                                 ; Return
; ***************************************************************************************
; Disable the mouse interrupts and remove the pointer
;
; Disable the User VIA's CB1 and CB2 interrupts, then remove the pointer
; (remove_pointer).
; &83e2 referenced 2 times by &828c, &83b0
.remove_pointer_and_mouse
    lda #via_ier_disable_cb1_cb2        ; Disable the CB1 and CB2 interrupts
    sta user_via_ier                    ; ...
; ***************************************************************************************
; Remove the pointer from the screen
;
; If the pointer is shown, put back the screen bytes it covers and mark it not shown.
; Main-memory accesses are pointed at the same RAM as the VDU drivers while this is done
; (see update_pointer), and ACCCON is then restored.
; &83e7 referenced 1 time by &83ac
.remove_pointer
    lda pointer_shown                   ; Is the pointer shown?
    beq return_from_pointer             ; No: nothing to do
    lda acccon                          ; Save ACCCON
    sta saved_acccon                    ; ...
    and #&fb                            ; Clear X (main memory, not shadow, at &3000)
    bit #acccon_e                       ; Are the VDU drivers using shadow RAM (E)?
    beq remove_pointer_set_acccon       ; No
    ora #acccon_x                       ; Yes: access shadow RAM too (set X)
; &83fa referenced 1 time by &83f6
.remove_pointer_set_acccon
    sta acccon                          ; ...
    jsr restore_screen_under_pointer    ; Put back the screen under the pointer
    lda saved_acccon                    ; Restore ACCCON
    sta acccon                          ; ...
    stz pointer_shown                   ; The pointer is not shown
    rts                                 ; Return
; ***************************************************************************************
; Redraw the pointer if it has moved
;
; Restart the redraw countdown, and if the pointer has moved since it was last drawn,
; move it: put back the screen under it at the old position, then draw it at the new one.
;
; The pointer image is 4 screen bytes wide and 16 pixel rows high, held as 4 columns of
; 16 bytes. Its top left corner is the hot spot (hotspot_x, hotspot_y) left of and above
; (pointer_x, pointer_y). The image used is the one of the four shifted copies (see
; build_pointer_images) that matches how far into a screen byte the left edge falls, so
; the pointer moves in steps finer than a byte.
;
; Each screen byte is saved in screen_under_pointer, then ANDed with the mask and ORed
; with the image. Columns left of the screen or bytes below its bottom are skipped;
; drawing stops at the first column right of the screen; rows above the top of the screen
; are skipped.
;
; During drawing, main-memory accesses are switched to the RAM the VDU drivers are using:
; ACCCON bit X (main memory at &3000-&7FFF is shadow RAM) is set to match bit E (VDU
; driver accesses go to shadow RAM), so the pointer is drawn on the screen being written
; in both shadow and normal modes. ACCCON is restored afterwards, through saved_acccon,
; which is also the last byte of saved_zero_page (see the workspace notes).
;
; Called from cmd_pointer, and from poll_redraw_and_buttons when the countdown expires.
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: corrupted
; &840a referenced 2 times by &83de, &8a21
.update_pointer
    lda #redraw_interval                ; Next redraw in 10 polls
    sta redraw_countdown                ; ...
    lda pointer_x                       ; Has the pointer moved since it was drawn?
    cmp drawn_x                         ; ...
    bne move_pointer_on_screen          ; Yes
    lda pointer_y                       ; ...
    cmp drawn_y                         ; ...
    bne move_pointer_on_screen          ; Yes
    lda pointer_x_hi                    ; ...
    cmp drawn_x_hi                      ; ...
    bne move_pointer_on_screen          ; Yes
    lda pointer_y_hi                    ; ...
    cmp drawn_y_hi                      ; ...
    beq return_from_pointer             ; No: nothing to do
; &842f referenced 3 times by &8415, &841d, &8425
.move_pointer_on_screen
    lda acccon                          ; Save ACCCON
    sta saved_acccon                    ; ...
    and #&fb                            ; Clear X (main memory, not shadow, at &3000)
    bit #acccon_e                       ; Are the VDU drivers using shadow RAM (E)?
    beq draw_set_acccon                 ; No
    ora #acccon_x                       ; Yes: access shadow RAM too (set X)
; &843d referenced 1 time by &8439
.draw_set_acccon
    sta acccon                          ; ...
    lda pointer_y                       ; Record the position being drawn...
    sta drawn_y                         ; ...
    lda pointer_y_hi                    ; ...
    sta drawn_y_hi                      ; ...
    lda pointer_x                       ; ...
    sta drawn_x                         ; ...
    lda pointer_x_hi                    ; ...
    sta drawn_x_hi                      ; ...
    ldx #0                              ; (X is set again below)
    lda pointer_x                       ; Left edge = pointer_x - hot spot X
    sec                                 ; ...
    sbc hotspot_x                       ; ...
    sta pointer_left                    ; ...
    lda pointer_x_hi                    ; ...
    sbc #0                              ; ...
    sta pointer_left_hi                 ; ...
    lda hotspot_y                       ; Top edge = pointer_y + hot spot Y
    clc                                 ; ...
    adc pointer_y                       ; ...
    sta pointer_top                     ; ...
    lda pointer_y_hi                    ; ...
    adc #0                              ; ...
    sta pointer_top_hi                  ; ...
    jsr calc_pointer_screen_address     ; Screen address of the top left, and the shift
    ldy romsel_copy                     ; zp_image_ptr = the image copy for the shift:
    lda rom_workspace_table,y           ; page +1 of the workspace...
    inc a                               ; ...
    sta zp_image_ptr_hi                 ; ...
    lda shifted_copy_offsets,x          ; plus the copy's offset
    sta zp_image_ptr                    ; ...
    jsr restore_screen_under_pointer    ; Put back the screen under the old pointer
    lda pointer_left                    ; Remember the new left edge for removing it
    sta drawn_left                      ; ...
    lda pointer_left_hi                 ; ...
    sta drawn_left_hi                   ; ...
    lda zp_screen_ptr_hi                ; Push the screen address twice: the top copy
    pha                                 ; steps along the columns, the bottom one is
    lda zp_screen_ptr                   ; kept as the address of the drawn pointer
    pha                                 ; ...
    lda zp_screen_ptr_hi                ; ...
    pha                                 ; ...
    lda zp_screen_ptr                   ; ...
    pha                                 ; ...
    ldx #0                              ; Start at image byte 0
    stx zp_image_index                  ; ...
; &84ad referenced 2 times by &84fe, &853b
.draw_char_row
    ldy #0                              ; Start at the address's own pixel row
    sty zp_row_in_cell                  ; ...
    lda zp_screen_ptr_hi                ; Address &8000 or above (below the screen)?
    bmi draw_skip_column                ; Yes: skip the rest of this column
    cmp vdu_screen_start_hi             ; Below the start of screen memory (above it)?
    bcc draw_skip_rows_above_screen     ; Yes: skip rows to the next character row
    lda pointer_left_hi                 ; Is this column left of the screen?
    bmi draw_skip_column                ; Yes: skip the column
    cmp #5                              ; Is it right of the screen (X >= 1280)?
    bcs finish_drawing                  ; Yes: stop drawing
; &84c3 referenced 1 time by &84e8
.draw_pixel_row
    ldy zp_row_in_cell                  ; Screen byte...
    lda (zp_screen_ptr),y               ; ...
    ldy zp_image_index                  ; saved in the buffer
    sta (zp_under_ptr),y                ; ...
    inc zp_image_ptr_hi                 ; AND with the mask, one page above the image
    and (zp_image_ptr),y                ; ...
    dec zp_image_ptr_hi                 ; ...
    ora (zp_image_ptr),y                ; OR in the image
    ldy zp_row_in_cell                  ; and put it on the screen
    sta (zp_screen_ptr),y               ; ...
    inc zp_image_index                  ; Next image byte
    lda zp_image_index                  ; All 16 rows of this column done?
    and #&0f                            ; ...
    beq draw_next_column                ; Yes: next column
    inc zp_row_in_cell                  ; Next pixel row down
    lda zp_row_in_cell                  ; Still in the same character row?
    clc                                 ; ...
    adc zp_screen_ptr                   ; ...
    and #7                              ; ...
    bne draw_pixel_row                  ; Yes: draw it
; &84ea referenced 1 time by &8509
.draw_next_char_row
    ldy screen_format                   ; Down a character row: back to its top byte...
    lda zp_screen_ptr                   ; ...
    and #&f8                            ; ...
    clc                                 ; ...
    adc char_row_bytes_lo,y             ; plus the bytes in a character row
    sta zp_screen_ptr                   ; ...
    lda zp_screen_ptr_hi                ; ...
    adc char_row_bytes_hi,y             ; ...
    sta zp_screen_ptr_hi                ; ...
    bra draw_char_row                   ; Draw that row
; &8500 referenced 1 time by &84b8
.draw_skip_rows_above_screen
    lda zp_screen_ptr                   ; Above the screen: skip as many image rows as
    and #7                              ; the address's pixel row within the character
    clc                                 ; ...
    adc zp_image_index                  ; ...
    sta zp_image_index                  ; ...
    bra draw_next_char_row              ; and try the next character row
; &850b referenced 2 times by &84b3, &84bd
.draw_skip_column
    lda zp_image_index                  ; Skip to the next column of the image
    and #&f0                            ; ...
    clc                                 ; ...
    adc #&10                            ; ...
    sta zp_image_index                  ; ...
; &8514 referenced 1 time by &84dd
.draw_next_column
    ldy screen_format                   ; Move the left edge right one screen byte
    lda pointer_left                    ; ...
    clc                                 ; ...
    adc units_per_screen_byte,y         ; ...
    sta pointer_left                    ; ...
    bcc draw_next_column_address        ; ...
    inc pointer_left_hi                 ; ...
; &8526 referenced 1 time by &8521
.draw_next_column_address
    pla                                 ; Next column's screen address: 8 bytes on
    clc                                 ; ...
    adc #8                              ; ...
    sta zp_screen_ptr                   ; ...
    pla                                 ; ...
    adc #0                              ; ...
    sta zp_screen_ptr_hi                ; ...
    pha                                 ; kept on the stack
    lda zp_screen_ptr                   ; ...
    pha                                 ; ...
    lda zp_image_index                  ; All four columns done?
    cmp #&40 ; '@'                      ; ...
    beq finish_drawing                  ; Yes: finish
    jmp draw_char_row                   ; No: draw the next column
; &853e referenced 2 times by &84c1, &8539
.finish_drawing
    pla                                 ; Drop the column address
    pla                                 ; ...
    pla                                 ; The pointer is now drawn at the address...
    sta zp_drawn_ptr                    ; ...
    pla                                 ; ...
    sta zp_drawn_ptr_hi                 ; ...
    lda saved_acccon                    ; Restore ACCCON
    sta acccon                          ; ...
    rts                                 ; Return
; ***************************************************************************************
; Leave the driver: restore zero page and store the workspace
;
; The partner of enter_driver. Keep zp_drawn_ptr in saved_drawn_ptr, restore the caller's
; zero page &84-&90 from saved_zero_page, and fall into exchange_workspace to store the
; workspace at &9440.
;
; The 13th byte restored, &90, is saved_acccon, so if the pointer was drawn or removed
; since enter_driver, &90 is left holding ACCCON.
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: preserved
; &854d referenced 3 times by &81e8, &88d3, &8a27
.leave_driver
    lda zp_drawn_ptr                    ; Keep the drawn pointer's address
    sta saved_drawn_ptr                 ; ...
    lda zp_drawn_ptr_hi                 ; ...
    sta saved_drawn_ptr_hi              ; ...
    ldx #&0c                            ; Restore zero page &84-&90
; &8559 referenced 1 time by &855f
.restore_zero_page
    lda saved_zero_page,x               ; ...
    sta zp_image_ptr,x                  ; ...
    dex                                 ; ...
    bpl restore_zero_page               ; ...
; ***************************************************************************************
; Exchange the working and stored copies of the workspace
;
; Swap the 48 bytes at &9000-&902F with the 48 bytes at offset &40 in page +3 of the
; private workspace (rom_workspace_table, set to &91, so &9440-&946F).
;
; Every way into the driver calls this on the way in and again on the way out, so the
; driver's state is at &9000 while it runs and at &9440 in between. enter_driver and
; leave_driver do this for the commands and the polls; bytev_handler calls it directly;
; irq_handler exchanges only the first ten bytes (exchange_position_workspace).
;
; &9030-&9037 (the device mode, the speeds and the desktop colours) are not exchanged.
;
; On Exit:
;     A: preserved
;     X: preserved
;     Y: preserved
; &8561 referenced 5 times by &8592, &87d4, &87e5, &87f5, &881d
.exchange_workspace
    pha                                 ; Save A
    phx                                 ; X
    phy                                 ; and Y
    lda zp_image_ptr                    ; and the zero page pointer used
    pha                                 ; ...
    lda zp_image_ptr_hi                 ; ...
    pha                                 ; ...
    ldx romsel_copy                     ; Point it at the stored copy: page +3...
    lda rom_workspace_table,x           ; ...
    clc                                 ; ...
    adc #3                              ; ...
    sta zp_image_ptr_hi                 ; ...
    lda #&40 ; '@'                      ; offset &40
    sta zp_image_ptr                    ; ...
    ldy #&2f ; '/'                      ; 48 bytes, from the last
; &857a referenced 1 time by &8586
.exchange_workspace_byte
    ldx tmax_x,y                        ; Working byte
    lda (zp_image_ptr),y                ; Stored byte...
    sta tmax_x,y                        ; ...becomes the working byte
    txa                                 ; Working byte...
    sta (zp_image_ptr),y                ; ...becomes the stored byte
    dey                                 ; Next
    bpl exchange_workspace_byte         ; ...
    pla                                 ; Restore the zero page pointer
    sta zp_image_ptr_hi                 ; ...
    pla                                 ; ...
    sta zp_image_ptr                    ; ...
    ply                                 ; Restore Y
    plx                                 ; X
    pla                                 ; and A
    rts                                 ; Return
; ***************************************************************************************
; Enter the driver: bring in the workspace and save zero page
;
; Bring the stored workspace into &9000 (exchange_workspace), save the caller's zero page
; &84-&90 in saved_zero_page, and load zp_drawn_ptr from saved_drawn_ptr. Called with
; interrupts disabled. leave_driver undoes it.
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: preserved
; &8592 referenced 3 times by &81e2, &8849, &8a14
.enter_driver
    jsr exchange_workspace              ; Bring in the workspace
    ldx #&0c                            ; Save zero page &84-&90
; &8597 referenced 1 time by &859d
.save_zero_page
    lda zp_image_ptr,x                  ; ...
    sta saved_zero_page,x               ; ...
    dex                                 ; ...
    bpl save_zero_page                  ; ...
    lda saved_drawn_ptr                 ; Load the drawn pointer's address
    sta zp_drawn_ptr                    ; ...
    lda saved_drawn_ptr_hi              ; ...
    sta zp_drawn_ptr_hi                 ; ...
; &85a9 referenced 1 time by &85b8
.return_from_enter_driver
    rts                                 ; Return
; ***************************************************************************************
; Put back the screen under the pointer
;
; Copy the 64 bytes saved in screen_under_pointer back to the screen at zp_drawn_ptr,
; column by column, with the same clipping as update_pointer and using drawn_left for the
; column positions. Nothing is done if bit 7 of zp_drawn_ptr's high byte is set (no
; pointer drawn).
;
; zp_drawn_ptr and drawn_left are stepped along as it works, so they no longer describe
; the pointer afterwards.
;
; For rows above the top of the screen, the number of rows to skip is added to X instead
; of to the buffer index, so the index is not advanced. While pointer_y is within its
; range (at most 1020), the count is always 0 and this makes no difference.
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: corrupted
; &85aa referenced 2 times by &83fd, &848e
.restore_screen_under_pointer
    ldy romsel_copy                     ; zp_under_ptr = the saved-screen buffer,
    lda rom_workspace_table,y           ; page +3 of the workspace
    clc                                 ; ...
    adc #3                              ; ...
    sta zp_under_ptr_hi                 ; ...
    stz zp_under_ptr                    ; ...
    lda zp_drawn_ptr_hi                 ; Is a pointer drawn?
    bmi return_from_enter_driver        ; No: nothing to put back
    pha                                 ; Push its screen address, to step along
    lda zp_drawn_ptr                    ; the columns
    pha                                 ; ...
    ldy #0                              ; Start at buffer byte 0
    sty zp_image_index                  ; ...
; &85c2 referenced 2 times by &8607, &862f
.restore_char_row
    ldy #0                              ; Start at the address's own pixel row
    sty zp_row_in_cell                  ; ...
    lda zp_drawn_ptr_hi                 ; Address &8000 or above (below the screen)?
    bmi restore_skip_column             ; Yes: skip the rest of this column
    cmp vdu_screen_start_hi             ; Below the start of screen memory (above it)?
    bcc restore_skip_rows_above_screen  ; Yes: go to the next character row
    lda drawn_left_hi                   ; Is this column left of the screen?
    bmi restore_skip_column             ; Yes: skip the column
    cmp #5                              ; Is it right of the screen (X >= 1280)?
    bcs finish_restoring                ; Yes: stop
; &85d8 referenced 1 time by &85f1
.restore_pixel_row
    ldy zp_image_index                  ; Saved byte...
    lda (zp_under_ptr),y                ; ...
    ldy zp_row_in_cell                  ; ...back on the screen
    sta (zp_drawn_ptr),y                ; ...
    inc zp_image_index                  ; Next saved byte
    lda zp_image_index                  ; All 16 rows of this column done?
    and #&0f                            ; ...
    beq restore_next_column             ; Yes: next column
    inc zp_row_in_cell                  ; Next pixel row down
    lda zp_row_in_cell                  ; Still in the same character row?
    clc                                 ; ...
    adc zp_drawn_ptr                    ; ...
    and #7                              ; ...
    bne restore_pixel_row               ; Yes: put it back
; &85f3 referenced 1 time by &864b
.restore_next_char_row
    ldy screen_format                   ; Down a character row: back to its top byte...
    lda zp_drawn_ptr                    ; ...
    and #&f8                            ; ...
    clc                                 ; ...
    adc char_row_bytes_lo,y             ; plus the bytes in a character row
    sta zp_drawn_ptr                    ; ...
    lda zp_drawn_ptr_hi                 ; ...
    adc char_row_bytes_hi,y             ; ...
    sta zp_drawn_ptr_hi                 ; ...
    jmp restore_char_row                ; Restore that row
; &860a referenced 2 times by &85e6, &863d
.restore_next_column
    ldy screen_format                   ; Move the left edge right one screen byte
    lda drawn_left                      ; ...
    clc                                 ; ...
    adc units_per_screen_byte,y         ; ...
    sta drawn_left                      ; ...
    bcc restore_next_column_address     ; ...
    inc drawn_left_hi                   ; ...
; &861c referenced 1 time by &8617
.restore_next_column_address
    pla                                 ; Next column's screen address: 8 bytes on
    clc                                 ; ...
    adc #8                              ; ...
    sta zp_drawn_ptr                    ; ...
    pla                                 ; ...
    adc #0                              ; ...
    sta zp_drawn_ptr_hi                 ; ...
    pha                                 ; kept on the stack
    lda zp_drawn_ptr                    ; ...
    pha                                 ; ...
    ldy zp_image_index                  ; All four columns done?
    cpy #&40 ; '@'                      ; ...
    bne restore_char_row                ; No: restore the next column
; &8631 referenced 1 time by &85d6
.finish_restoring
    pla                                 ; Drop the column address
    pla                                 ; ...
    rts                                 ; Return
; &8634 referenced 2 times by &85c8, &85d2
.restore_skip_column
    lda zp_image_index                  ; Skip to the next column of the buffer
    and #&f0                            ; ...
    clc                                 ; ...
    adc #&10                            ; ...
    sta zp_image_index                  ; ...
    jmp restore_next_column             ; ...
; &8640 referenced 1 time by &85cd
.restore_skip_rows_above_screen
    lda zp_drawn_ptr                    ; Above the screen: rows to skip = the pixel row
    and #7                              ; within the character row
    sta zp_skip_rows                    ; ...
    txa                                 ; added to X, which is not used: the buffer
    clc                                 ; index is not advanced
    adc zp_skip_rows                    ; ...
    tax                                 ; ...
    jmp restore_next_char_row           ; Try the next character row
; ***************************************************************************************
; Offsets of each screen format's pointer image and mask
;
; Low and high bytes of the offset, from pointer_images and from pointer_masks, of the
; 64-byte image and mask for each screen format: &000, &040, &080, &0C0 and &100 for
; formats 0-4. The sixth entry (&140) is not used.
.pointer_format_offsets
    equb &00, &40, &80, &c0, &00, &40   ; Low bytes, formats 0-5
.pointer_format_offsets_hi
    equb &00, &00, &00, &00, &01, &01   ; High bytes, formats 0-5
; ***************************************************************************************
; Build the shifted pointer images and masks
;
; Copy the 64-byte pointer image and mask for the current screen format from the ROM into
; the bank, at pointer_image_copies (page +1 of the workspace) and pointer_mask_copies
; (page +2), then build three more copies of each after it, each shifted right by a
; further quarter of a screen byte (build_shifted_copies). update_pointer picks the copy
; that matches the pointer's position within a screen byte.
;
; The images are laid out as 4 byte columns of 16 rows each. A selects a byte offset into
; the format's image and mask; cmd_pointer always passes 0.
;
; On Entry:
;     A: offset into the image and mask (0)
;     SCREEN_FORMAT: which image and mask to use
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: corrupted
; &865a referenced 1 time by &83d4
.build_pointer_images
    sta pointer_shape                   ; Record the offset
    tay                                 ; ...
    ldx screen_format                   ; For this screen format:
    lda pointer_format_offsets,x        ; source image = pointer_images + format offset
    clc                                 ; ...
    adc #<(pointer_images)              ; ...
    sta zp_image_ptr                    ; ...
    lda pointer_format_offsets_hi,x     ; ...
    adc #>(pointer_images)              ; ...
    sta zp_image_ptr_hi                 ; ...
    lda pointer_format_offsets,x        ; source mask = pointer_masks + format offset
    clc                                 ; ...
    adc #<(pointer_masks)               ; ...
    sta zp_under_ptr                    ; ...
    lda pointer_format_offsets_hi,x     ; ...
    adc #>(pointer_masks)               ; ...
    sta zp_under_ptr_hi                 ; ...
    ldx romsel_copy                     ; Destination: page +1 of the workspace
    lda rom_workspace_table,x           ; ...
    inc a                               ; ...
    sta zp_screen_ptr_hi                ; ...
    stz zp_screen_ptr                   ; ...
    sty zp_image_index                  ; Source index starts at the offset
    ldy #0                              ; Destination index starts at 0
    sty zp_row_in_cell                  ; ...
; &868f referenced 1 time by &86ab
.copy_image_and_mask_byte
    ldy zp_image_index                  ; Image byte...
    lda (zp_image_ptr),y                ; ...
    ldy zp_row_in_cell                  ; ...to page +1
    sta (zp_screen_ptr),y               ; ...
    ldy zp_image_index                  ; Mask byte...
    lda (zp_under_ptr),y                ; ...
    ldy zp_row_in_cell                  ; ...
    inc zp_screen_ptr_hi                ; ...to page +2
    sta (zp_screen_ptr),y               ; ...
    dec zp_screen_ptr_hi                ; ...
    inc zp_image_index                  ; Next source byte
    inc zp_row_in_cell                  ; Next destination byte
    ldy zp_row_in_cell                  ; All 64 copied?
    cpy #pointer_image_size             ; ...
    bne copy_image_and_mask_byte        ; No: copy the next
    stz zp_image_ptr                    ; Shift the image: from offset &00 of page +1...
    lda #&40 ; '@'                      ; to offset &40
    sta zp_under_ptr                    ; ...
    ldx romsel_copy                     ; ...
    lda rom_workspace_table,x           ; ...
    inc a                               ; ...
    sta zp_image_ptr_hi                 ; ...
    sta zp_under_ptr_hi                 ; ...
    lda #0                              ; shifting in 0 bits (transparent in an image)
    sta zp_temp                         ; ...
    jsr build_shifted_copies            ; Build the three shifted image copies
    stz zp_image_ptr                    ; Then the mask: from offset &00 of page +2...
    lda #&40 ; '@'                      ; to offset &40
    sta zp_under_ptr                    ; ...
    ldx romsel_copy                     ; ...
    lda rom_workspace_table,x           ; ...
    clc                                 ; ...
    adc #2                              ; ...
    sta zp_image_ptr_hi                 ; ...
    sta zp_under_ptr_hi                 ; ...
    dec zp_temp                         ; shifting in 1 bits (transparent in a mask)
; ***************************************************************************************
; Build three shifted copies of an image or mask
;
; From the 64-byte copy at zp_image_ptr, build three copies, each a quarter of a screen
; byte further right, at zp_under_ptr, zp_under_ptr+&40 and zp_under_ptr+&80. Bits
; shifted in at the left are zp_temp's (0 for an image, 1 for a mask). How far a quarter
; byte is depends on the screen format:
;
; | Format | MODE | Pixels per byte | Each copy is                                       |
; |--------|------|-----------------|----------------------------------------------------|
; | 0, 3   | 0, 4 | 8               | 2 pixels further right                             |
; | 1, 4   | 1, 5 | 4               | 1 pixel further right                              |
; | 2      | 2    | 2               | half a pixel: copies are 0, 0, 1 and 1 pixel right |
;
; On Entry:
;     ZP_IMAGE_PTR: unshifted copy
;     ZP_UNDER_PTR: where the first shifted copy goes
;     ZP_TEMP: &00 (image) or &FF (mask)
; &86d8 referenced 1 time by &86c1
.build_shifted_copies
    lda screen_format                   ; Screen format 0 or 3 (two colours)?
    beq build_2colour_copies            ; Yes
    cmp #3                              ; ...
    beq build_2colour_copies            ; ...
    cmp #4                              ; Format 1 or 4 (four colours)?
    beq build_4colour_copies            ; Yes
    cmp #1                              ; ...
    beq build_4colour_copies            ; ...
    jmp build_16colour_copies           ; Format 2 (sixteen colours)
; ***************************************************************************************
; Build the shifted copies for MODEs 1 and 5
;
; Three copies, each one pixel further right.
; &86ec referenced 2 times by &86e3, &86e7
.build_4colour_copies
    jsr shift_4colour_copy              ; First copy, 1 pixel right
    jsr shift_4colour_copy              ; Second copy, 2 pixels right
; ***************************************************************************************
; Make the next copy one 4-colour pixel further right
;
; Shift the 64-byte copy at zp_image_ptr right by one pixel into zp_under_ptr, for MODEs
; 1 and 5, where a byte holds 4 pixels with the two bits of pixel n in bits 7-n and 3-n.
; Each of the 16 rows is shifted across its 4 bytes, carrying the rightmost pixel of each
; byte into the leftmost of the next. Only the pixel's low colour bit is carried: for an
; image the high bit of the pixel shifted in is 0, for a mask it is a copy of the low
; bit, which is right for images drawn in colours 0 and 1 and for masks whose pixels are
; all-0 or all-1. Then step on to the next copy (advance_to_next_copy).
; &86f2 referenced 2 times by &86ec, &86ef
.shift_4colour_copy
    ldx #0                              ; Row 0
; &86f4 referenced 1 time by &8722
.shift_4colour_row
    lda zp_temp                         ; Carry = the fill bit: 1 for a mask...
    cmp #&ff                            ; ...
    lda #0                              ; Column 0
    php                                 ; Carry into the first byte of the row
; &86fb referenced 1 time by &871c
.shift_4colour_byte
    sta zp_image_index                  ; Byte index = column * 16 + row
    txa                                 ; ...
    ora zp_image_index                  ; ...
    tay                                 ; ...
    lda (zp_image_ptr),y                ; Source byte
    plp                                 ; Carry from the byte to the left
    bcs shift_4colour_set_bit4          ; Set: put it in bit 4 (becomes bit 3)
    and #&ef                            ; Clear: clear bit 4
    bcc shift_4colour_high_bit          ; Always taken (carry clear)
; &870a referenced 1 time by &8704
.shift_4colour_set_bit4
    ora #&10                            ; ...
; &870c referenced 1 time by &8708
.shift_4colour_high_bit
    bit zp_temp                         ; Mask: keep the carry for bit 7
    bmi shift_4colour_rotate            ; ...
    clc                                 ; Image: bit 7 = 0
; &8711 referenced 1 time by &870e
.shift_4colour_rotate
    ror a                               ; Shift right one pixel; carry = old bit 0
    php                                 ; Keep the carry for the next byte
    sta (zp_under_ptr),y                ; Store the shifted byte
    lda zp_image_index                  ; Next column...
    clc                                 ; ...
    adc #&10                            ; ...
    cmp #&40 ; '@'                      ; of the 4
    bne shift_4colour_byte              ; ...
    plp                                 ; Drop the last carry
    inx                                 ; Next row...
    cpx #&10                            ; of the 16
    bne shift_4colour_row               ; ...
; ***************************************************************************************
; Step on to the next shifted copy
;
; Make the copy just built the source, and the next 64 bytes the destination.
; &8724 referenced 3 times by &874a, &87b2, &87be
.advance_to_next_copy
    lda zp_image_ptr_hi                 ; Source = the copy just built...
    sta zp_under_ptr_hi                 ; ...
    lda zp_under_ptr                    ; ...
    sta zp_image_ptr                    ; ...
    clc                                 ; Destination = 64 bytes further on
    adc #pointer_image_size             ; ...
    sta zp_under_ptr                    ; ...
    bcc return_from_shifting            ; ...
    inc zp_under_ptr_hi                 ; ...
; &8735 referenced 1 time by &8731
.return_from_shifting
    rts                                 ; Return
; ***************************************************************************************
; Build the shifted copies for MODEs 0 and 4
;
; Three copies, each two pixels further right.
; &8736 referenced 2 times by &86db, &86df
.build_2colour_copies
    jsr shift_2colour_copy              ; First copy, 2 pixels right
    jsr shift_2colour_copy              ; Second copy, 4 pixels right
; ***************************************************************************************
; Make the next copy two 2-colour pixels further right
;
; For MODEs 0 and 4, where a byte holds 8 pixels: shift the copy at zp_image_ptr right
; one pixel into zp_under_ptr, then shift that right one more pixel in place, then step
; on to the next copy.
; &873c referenced 2 times by &8736, &8739
.shift_2colour_copy
    jsr shift_2colour_pixel             ; Shift right one pixel into the destination
    lda zp_image_ptr_hi                 ; Then shift the destination in place...
    sta zp_under_ptr_hi                 ; ...
    lda zp_under_ptr                    ; ...
    sta zp_image_ptr                    ; ...
    jsr shift_2colour_pixel             ; by one more pixel
    jmp advance_to_next_copy            ; Step on to the next copy
; ***************************************************************************************
; Shift a 2-colour copy right one pixel
;
; Shift each of the 16 rows of the copy at zp_image_ptr right one bit, across its 4
; bytes, into zp_under_ptr, shifting in zp_temp's fill bit at the left.
; &874d referenced 2 times by &873c, &8747
.shift_2colour_pixel
    ldx #0                              ; Row 0
; &874f referenced 1 time by &8770
.shift_2colour_row
    lda zp_temp                         ; Carry = the fill bit: 1 for a mask...
    cmp #&ff                            ; ...
    lda #0                              ; Column 0
    php                                 ; Carry into the first byte of the row
; &8756 referenced 1 time by &876a
.shift_2colour_byte
    sta zp_image_index                  ; Byte index = column * 16 + row
    txa                                 ; ...
    ora zp_image_index                  ; ...
    tay                                 ; ...
    lda (zp_image_ptr),y                ; Source byte
    plp                                 ; Carry from the byte to the left
    ror a                               ; Shift right one pixel
    php                                 ; Keep the carry for the next byte
    sta (zp_under_ptr),y                ; Store the shifted byte
    lda zp_image_index                  ; Next column...
    clc                                 ; ...
    adc #&10                            ; ...
    cmp #&40 ; '@'                      ; of the 4
    bne shift_2colour_byte              ; ...
    plp                                 ; Drop the last carry
    inx                                 ; Next row...
    cpx #&10                            ; of the 16
    bne shift_2colour_row               ; ...
    rts                                 ; Return
; ***************************************************************************************
; Build the shifted copies for MODE 2
;
; A quarter of a screen byte is half a pixel, so the copies are the original, the
; original again, one pixel right, and that again.
; &8773 referenced 1 time by &86e9
.build_16colour_copies
    jsr copy_unshifted                  ; First copy: unshifted
    jsr shift_16colour_copy             ; Second copy: one pixel right
    jmp copy_unshifted                  ; Third copy: the same as the second
; ***************************************************************************************
; Make the next copy one 16-colour pixel further right
;
; For MODE 2, where a byte holds 2 pixels with the bits of the left pixel in bits 7, 5, 3
; and 1 and the right pixel in bits 6, 4, 2 and 0: move the left pixel of each byte to
; the right, and bring in the right pixel of the byte to the left as the new left pixel.
; Only that pixel's lowest colour bit is carried: if it is set, a mask's new pixel is all
; ones and an image's is colour 1; otherwise it is 0. The first byte of each row takes
; the fill bit. Then step on to the next copy.
; &877c referenced 1 time by &8776
.shift_16colour_copy
    ldx #0                              ; Row 0
; &877e referenced 1 time by &87b0
.shift_16colour_row
    lda zp_temp                         ; Carry = the fill bit: 1 for a mask...
    cmp #&ff                            ; ...
    lda #0                              ; Column 0
    php                                 ; Carry into the first byte of the row
; &8785 referenced 1 time by &87aa
.shift_16colour_byte
    sta zp_image_index                  ; Byte index = column * 16 + row
    txa                                 ; ...
    ora zp_image_index                  ; ...
    tay                                 ; ...
    lda (zp_image_ptr),y                ; Source byte: its left pixel...
    and #&aa                            ; ...
    lsr a                               ; ...moves to the right
    plp                                 ; Was the left neighbour's right pixel set?
    bcc shift_16colour_store            ; No: new left pixel is 0
    bit zp_temp                         ; Yes: for a mask...
    bpl shift_16colour_set_pixel        ; ...
    ora #&aa                            ; ...the new left pixel is all ones
; &8799 referenced 1 time by &8795
.shift_16colour_set_pixel
    ora #2                              ; For an image, colour 1
; &879b referenced 1 time by &8791
.shift_16colour_store
    sta (zp_under_ptr),y                ; Store the shifted byte
    lda (zp_image_ptr),y                ; This byte's right pixel...
    and #&55 ; 'U'                      ; ...
    lsr a                               ; ...lowest bit into the carry
    php                                 ; Keep it for the next byte
    lda zp_image_index                  ; Next column...
    clc                                 ; ...
    adc #&10                            ; ...
    cmp #&40 ; '@'                      ; of the 4
    bne shift_16colour_byte             ; ...
    plp                                 ; Drop the last carry
    inx                                 ; Next row...
    cpx #&10                            ; of the 16
    bne shift_16colour_row              ; ...
    jmp advance_to_next_copy            ; Step on to the next copy
; ***************************************************************************************
; Make the next copy the same as the last
;
; Copy the 64 bytes at zp_image_ptr to zp_under_ptr, then step on to the next copy. Used
; in MODE 2, where a quarter-byte step is half a pixel.
; &87b5 referenced 2 times by &8773, &8779
.copy_unshifted
    ldy #&3f ; '?'                      ; 64 bytes
; &87b7 referenced 1 time by &87bc
.copy_unshifted_byte
    lda (zp_image_ptr),y                ; Copy a byte
    sta (zp_under_ptr),y                ; ...
    dey                                 ; Next
    bpl copy_unshifted_byte             ; ...
    jmp advance_to_next_copy            ; Step on to the next copy
; ***************************************************************************************
; OSBYTE handler: ADVAL(5) to ADVAL(9)
;
; Reached through BYTEV, by way of the extended vector entry, for every OSBYTE call while
; the driver is on. OSBYTE &80 (ADVAL) with X from 5 to 9 is answered here; every other
; call goes on to the previous BYTEV.
;
; | X | ADVAL    | Returns in X (low) and Y (high)  |
; |---|----------|----------------------------------|
; | 5 | ADVAL(5) | *TMAX x                          |
; | 6 | ADVAL(6) | *TMAX y                          |
; | 7 | ADVAL(7) | pointer X, 0-1276                |
; | 8 | ADVAL(8) | pointer Y, 0-1020                |
; | 9 | ADVAL(9) | device mode (0, &20, &40 or &80) |
;
; ADVAL(0)-(4), and channels 10 and above, remain the MOS's.
;
; For channels 5-8 the stored workspace is brought in to read the value and put back,
; with interrupts disabled. The device mode is outside the exchanged area and is read
; directly. Channels 5-8 return with A=&80 and V clear; channel 9 returns with A=&80 and
; V unchanged.
;
; On Entry:
;     A: OSBYTE number
;     X: first parameter (ADVAL channel)
;
; On Exit:
;     A: &80
;     X: value, low byte
;     Y: value, high byte
.bytev_handler
    cmp #osbyte_read_adc                ; OSBYTE &80 (ADVAL)?
    beq bytev_adval                     ; Yes
; &87c5 referenced 2 times by &87cc, &87d0
.pass_to_previous_bytev
    jmp (saved_bytev)                   ; No: on to the previous OSBYTE handler
; &87c8 referenced 1 time by &87c3
.bytev_adval
    cpx #9                              ; ADVAL(9)?
    beq read_device_mode                ; Yes: return the device mode
    bcs pass_to_previous_bytev          ; Channel 10 and up (or negative): not ours
    cpx #5                              ; Channel 4 or below?
    bcc pass_to_previous_bytev          ; Yes: not ours
    php                                 ; Save the flags and disable interrupts
    sei                                 ; ...
    jsr exchange_workspace              ; Bring in the workspace
    txa                                 ; Offset = 2 * channel - 10...
    asl a                               ; ...(ASL leaves carry clear)
    adc #&f6                            ; ...
    tay                                 ; ...
    lda tmax_x,y                        ; Value low byte
    tax                                 ; ...into X
    iny                                 ; Value high byte
    lda tmax_x,y                        ; ...
    tay                                 ; ...into Y
    jsr exchange_workspace              ; Put the workspace back
    plp                                 ; Restore the flags
; &87e9 referenced 1 time by &8823
.return_adval
    lda #&80                            ; A = &80, as for OSBYTE &80
    clv                                 ; V clear
    rts                                 ; Return to the OSBYTE caller
; &87ed referenced 1 time by &87ca
.read_device_mode
    ldy #0                              ; High byte 0
    ldx device_mode                     ; Low byte: the device mode
    rts                                 ; Return to the OSBYTE caller
; ***************************************************************************************
; Read the mouse buttons (not used)
;
; Nothing in the ROM calls this routine or holds its address.
;
; It reads the three mouse buttons from User VIA port B and returns them as an OSBYTE &80
; result would be: A=&80, X = the buttons (bit set = pressed) and Y=0. If the pinout has
; not yet been detected, it is taken to be AMX if any of PB5-PB7 is low (a button is
; pressed), and recorded; otherwise the Compact pinout is used for this read only. With
; the AMX pinout, PB5-PB7 are rotated down to bits 0-2.
;
; This is the button-reading form of ADVAL(9) used by other mouse drivers; in PMFS,
; ADVAL(9) returns the device mode instead.
;
; On Exit:
;     A: &80
;     X: buttons, bits 0-2, 1 = pressed
;     Y: 0
.read_mouse_buttons
    php                                 ; Save the flags and disable interrupts
    sei                                 ; ...
    jsr exchange_workspace              ; Bring in the workspace
    ldx pinout_index                    ; Pinout detected?
    bpl read_mouse_buttons_port         ; Yes
    ldx #0                              ; Assume the Compact pinout
    lda user_via_orb_irb                ; Are PB5-PB7 all high...
    and #&e0                            ; ...
    cmp #&e0                            ; ...(no AMX button pressed)?
    beq read_mouse_buttons_port         ; Yes: Compact, for this read
    ldx #7                              ; No: the AMX pinout...
    stx pinout_index                    ; ...recorded
; &880d referenced 2 times by &87fb, &8806
.read_mouse_buttons_port
    lda user_via_orb_irb                ; Read port B
    cpx #0                              ; Compact pinout?
    beq read_mouse_buttons_bits         ; Yes: buttons are PB0-PB2
    rol a                               ; AMX: rotate PB5-PB7...
    rol a                               ; ...through the carry...
    rol a                               ; ...
    rol a                               ; ...into bits 0-2
; &8818 referenced 1 time by &8812
.read_mouse_buttons_bits
    and #7                              ; Keep the three button bits
    eor #7                              ; 1 = pressed (the inputs are low when pressed)
    tax                                 ; X = buttons
    jsr exchange_workspace              ; Put the workspace back
    plp                                 ; Restore the flags
    ldy #0                              ; Y = 0
    beq return_adval                    ; Always taken: return A=&80
; ***************************************************************************************
; Interrupt handler: mouse movement
;
; Reached on every interrupt while the driver is on: IRQ1V points at irq1v_trampoline,
; whose JSR to the IRQ1V extended vector entry pages in this ROM and calls here, and
; whose JMP then goes on to the previous IRQ1V handler. So the interrupt is never
; claimed; the MOS handles it too.
;
; If the User VIA's CB1 or CB2 interrupt is enabled and either has occurred, the first
; ten bytes of the workspace (the pointer position, the pinout and the redraw countdown)
; are brought in, the pointer is moved (mouse_movement), and they are put back. The CB1
; and CB2 interrupts are only enabled in mouse mode.
;
; On Exit:
;     A: preserved
;     X: preserved
;     Y: preserved
;     FLAGS: preserved
.irq_handler
    php                                 ; Save the flags
    pha                                 ; and the registers
    phx                                 ; ...
    phy                                 ; ...
    lda user_via_ier                    ; Are CB1 or CB2 interrupts enabled?
    and #via_ier_disable_cb1_cb2        ; ...
    beq irq_return                      ; No: not a mouse interrupt
    lda user_via_ifr                    ; Has CB1 or CB2 interrupted?
    and #via_ier_disable_cb1_cb2        ; ...
    beq irq_return                      ; No: not a mouse interrupt
    jsr exchange_position_workspace     ; Bring in the position workspace
    tay                                 ; Y = which of CB1 and CB2 interrupted
    jsr mouse_movement                  ; Move the pointer
    jsr exchange_position_workspace     ; Put the position workspace back
; &8841 referenced 2 times by &882e, &8835
.irq_return
    jmp restore_registers_and_return    ; Restore everything and return to the trampoline
; ***************************************************************************************
; Poll: move the pointer with the joystick or keys
;
; The first half of the polling service call (&15), issued by the MOS every centisecond
; while the driver is on. Moves the pointer according to the device mode:
;
; | Mode | Device            | Input                                    | Left / right        | Up / down           |
; |------|-------------------|------------------------------------------|---------------------|---------------------|
; | 0    | Mouse             | none here: irq_handler moves the pointer |                     |                     |
; | &80  | Analogue joystick | ADVAL(1), ADVAL(2) high bytes            | ch 1 >= &C0 / < &40 | ch 2 >= &C0 / < &40 |
; | &40  | Digital joystick  | ADVAL(0) low byte                        | bit 4 / bit 7       | bit 6 / bit 5       |
; | &20  | Cursor keys       | INKEY -26, -122, -58, -42                | left / right        | up / down           |
;
; When an axis is not moving, its speed is reset. With the cursor keys, holding SHIFT
; accelerates both speeds faster. Runs with interrupts disabled, inside enter_driver and
; leave_driver.
;
; On Exit:
;     A: preserved
;     X: preserved
;     Y: preserved
;     FLAGS: preserved
; &8844 referenced 1 time by &8161
.poll_move_pointer
    php                                 ; Save the flags
    sei                                 ; Interrupts off while the workspace is in use
    pha                                 ; Save the registers
    phx                                 ; ...
    phy                                 ; ...
    jsr enter_driver                    ; Bring in the workspace, save zero page
    lda device_mode                     ; Device mode
    bne poll_not_mouse                  ; Not the mouse
    jmp finish_poll_move                ; Mouse: nothing to do here
; &8854 referenced 1 time by &884f
.poll_not_mouse
    bpl poll_digital_or_keys            ; Bit 7 clear: digital joystick or keys
    jmp poll_joystick                   ; Analogue joystick
; &8859 referenced 1 time by &8854
.poll_digital_or_keys
    cmp #device_mode_digital            ; Digital joystick?
    beq poll_digital                    ; Yes
    jmp poll_keys                       ; No: cursor keys
; &8860 referenced 1 time by &885b
.poll_digital
    lda #osbyte_read_adc_or_get_buffer_status  ; OSBYTE &80 with X=0: ADVAL(0)...
    ldx #0                              ; ...
    ldy #0                              ; ...
    jsr osbyte                          ; ...  Read ADC channel X or buffer status
    txa                                 ; Bit 4 of the low byte: left?
    and #&10                            ; ...
    beq poll_digital_right              ; No
    jsr move_pointer_left               ; Yes: move left
    bra poll_digital_vertical           ; ...
; &8873 referenced 1 time by &886c
.poll_digital_right
    txa                                 ; Bit 7: right?
    bpl poll_digital_x_still            ; No
    jsr move_pointer_right              ; Yes: move right
    bra poll_digital_vertical           ; ...
; &887b referenced 1 time by &8874
.poll_digital_x_still
    jsr reset_x_speed                   ; Neither: reset the horizontal speed
; &887e referenced 2 times by &8871, &8879
.poll_digital_vertical
    txa                                 ; Bit 6: up?
    and #&40 ; '@'                      ; ...
    beq poll_digital_down               ; No
    jsr move_pointer_up                 ; Yes: move up
    bra poll_digital_done               ; ...
; &8888 referenced 1 time by &8881
.poll_digital_down
    txa                                 ; Bit 5: down?
    and #&20 ; ' '                      ; ...
    beq poll_digital_y_still            ; No
    jsr move_pointer_down               ; Yes: move down
    bra poll_digital_done               ; ...
; &8892 referenced 1 time by &888b
.poll_digital_y_still
    jsr reset_y_speed                   ; Neither: reset the vertical speed
; &8895 referenced 2 times by &8886, &8890
.poll_digital_done
    bra finish_poll_move                ; Finish
; &8897 referenced 1 time by &8856
.poll_joystick
    lda #osbyte_read_adc_or_get_buffer_status  ; OSBYTE &80 with X=1: ADVAL(1), horizontal
    ldx #1                              ; ...
    ldy #0                              ; ...
    jsr osbyte                          ; ...  Read ADC channel X or buffer status
    cpy #&c0                            ; High byte &C0 or more: pushed left?
    bcc poll_joystick_right             ; No
    jsr move_pointer_left               ; Yes: move left
    bra poll_joystick_vertical          ; ...
; &88a9 referenced 1 time by &88a2
.poll_joystick_right
    cpy #&40 ; '@'                      ; Below &40: pushed right?
    bcs poll_joystick_x_still           ; No
    jsr move_pointer_right              ; Yes: move right
    bra poll_joystick_vertical          ; ...
; &88b2 referenced 1 time by &88ab
.poll_joystick_x_still
    jsr reset_x_speed                   ; Centred: reset the horizontal speed
; &88b5 referenced 2 times by &88a7, &88b0
.poll_joystick_vertical
    lda #osbyte_read_adc_or_get_buffer_status  ; OSBYTE &80 with X=2: ADVAL(2), vertical
    ldx #2                              ; ...
    ldy #0                              ; ...
    jsr osbyte                          ; ...  Read ADC channel X or buffer status
    cpy #&c0                            ; High byte &C0 or more: pushed up?
    bcc poll_joystick_down              ; No
    jsr move_pointer_up                 ; Yes: move up
    bra finish_poll_move                ; ...
; &88c7 referenced 1 time by &88c0
.poll_joystick_down
    cpy #&40 ; '@'                      ; Below &40: pulled down?
    bcs poll_joystick_y_still           ; No
    jsr move_pointer_down               ; Yes: move down
    bra finish_poll_move                ; ...
; &88d0 referenced 1 time by &88c9
.poll_joystick_y_still
    jsr reset_y_speed                   ; Centred: reset the vertical speed
; &88d3 referenced 5 times by &8851, &8895, &88c5, &88ce, &894b
.finish_poll_move
    jsr leave_driver                    ; Put back zero page and the workspace
    jmp restore_registers_and_return    ; Restore everything and return
; ***************************************************************************************
; Poll the cursor keys
;
; Device mode &20. SHIFT adds an extra &40 to both speeds, so the pointer accelerates
; five times as fast; then the cursor keys move it, each axis resetting its speed when
; neither of its keys is pressed.
; &88d9 referenced 1 time by &885d
.poll_keys
    lda #osbyte_inkey                   ; OSBYTE &81 with X=-1: is SHIFT pressed?
    ldx #inkey_key_shift                ; ...
    ldy #&ff                            ; ...
    jsr osbyte                          ; ...  Test for shift key pressed
    txa                                 ; X=&FF if pressed
    beq poll_keys_left                  ; No
    clc                                 ; Yes: add an extra &40 to the horizontal...
    lda #speed_shift_boost              ; ...
    adc x_speed                         ; ...
    sta x_speed                         ; ...
    bcc poll_keys_boost_y               ; ...
    inc x_speed_hi                      ; ...
; &88f3 referenced 1 time by &88ee
.poll_keys_boost_y
    clc                                 ; and vertical speeds
    lda #speed_shift_boost              ; ...
    adc y_speed                         ; ...
    sta y_speed                         ; ...
    bcc poll_keys_left                  ; ...
    inc y_speed_hi                      ; ...
; &8901 referenced 2 times by &88e3, &88fc
.poll_keys_left
    lda #osbyte_inkey                   ; Cursor left pressed?
    ldx #inkey_key_left                 ; ...
    ldy #&ff                            ; ...
    jsr osbyte                          ; ...  Test for left key pressed
    txa                                 ; ...
    beq poll_keys_right                 ; No
    jsr move_pointer_left               ; Yes: move left
    bra poll_keys_up                    ; ...
; &8912 referenced 1 time by &890b
.poll_keys_right
    lda #osbyte_inkey                   ; Cursor right pressed?
    ldx #inkey_key_right                ; ...
    ldy #&ff                            ; ...
    jsr osbyte                          ; ...  Test for right key pressed
    txa                                 ; ...
    beq poll_keys_x_still               ; No
    jsr move_pointer_right              ; Yes: move right
    bra poll_keys_up                    ; ...
; &8923 referenced 1 time by &891c
.poll_keys_x_still
    jsr reset_x_speed                   ; Neither: reset the horizontal speed
; &8926 referenced 2 times by &8910, &8921
.poll_keys_up
    lda #osbyte_inkey                   ; Cursor up pressed?
    ldx #inkey_key_up                   ; ...
    ldy #&ff                            ; ...
    jsr osbyte                          ; ...  Test for up key pressed
    txa                                 ; ...
    beq poll_keys_down                  ; No
    jsr move_pointer_up                 ; Yes: move up
    bra poll_keys_done                  ; ...
; &8937 referenced 1 time by &8930
.poll_keys_down
    lda #osbyte_inkey                   ; Cursor down pressed?
    ldx #inkey_key_down                 ; ...
    ldy #&ff                            ; ...
    jsr osbyte                          ; ...  Test for down key pressed
    txa                                 ; ...
    beq poll_keys_y_still               ; No
    jsr move_pointer_down               ; Yes: move down
    bra poll_keys_done                  ; ...
; &8948 referenced 1 time by &8941
.poll_keys_y_still
    jsr reset_y_speed                   ; Neither: reset the vertical speed
; &894b referenced 2 times by &8935, &8946
.poll_keys_done
    bra finish_poll_move                ; Finish
; ***************************************************************************************
; Move the pointer left
;
; Subtract the whole part of x_speed from pointer_x, stopping at 0, then accelerate:
; x_speed grows by &10 (1/16 of a graphics unit) each call.
;
; On Exit:
;     A: corrupted
;     X: preserved
;     Y: preserved
; &894d referenced 3 times by &886e, &88a4, &890d
.move_pointer_left
    lda pointer_x                       ; pointer_x -= whole part of the speed
    sec                                 ; ...
    sbc x_speed_hi                      ; ...
    sta pointer_x                       ; ...
    lda pointer_x_hi                    ; ...
    sbc #0                              ; ...
    sta pointer_x_hi                    ; ...
    bpl accelerate_x_left               ; Still 0 or more?
    stz pointer_x_hi                    ; No: stop at 0
    stz pointer_x                       ; ...
; &8967 referenced 1 time by &895f
.accelerate_x_left
    clc                                 ; x_speed += &10
    lda #speed_acceleration             ; ...
    adc x_speed                         ; ...
    sta x_speed                         ; ...
    bcc return_from_move_left           ; ...
    inc x_speed_hi                      ; ...
; &8975 referenced 1 time by &8970
.return_from_move_left
    rts                                 ; Return
; ***************************************************************************************
; Move the pointer right
;
; Add the whole part of x_speed to pointer_x, stopping at 1276 (&4FC), then accelerate:
; x_speed grows by &10 each call.
;
; On Exit:
;     A: corrupted
;     X: preserved
;     Y: preserved
; &8976 referenced 3 times by &8876, &88ad, &891e
.move_pointer_right
    lda pointer_x                       ; pointer_x += whole part of the speed
    clc                                 ; ...
    adc x_speed_hi                      ; ...
    sta pointer_x                       ; ...
    lda pointer_x_hi                    ; ...
    adc #0                              ; ...
    sta pointer_x_hi                    ; ...
    cmp #5                              ; Beyond the right edge (high byte 5 or more)?
    bcc accelerate_x_right              ; No
    lda #>(pointer_x_max)               ; Yes: stop at 1276 (&4FC)
    sta pointer_x_hi                    ; ...
    lda #<(pointer_x_max)               ; ...
    sta pointer_x                       ; ...
; &8996 referenced 1 time by &898a
.accelerate_x_right
    clc                                 ; x_speed += &10
    lda #speed_acceleration             ; ...
    adc x_speed                         ; ...
    sta x_speed                         ; ...
    bcc return_from_move_right          ; ...
    inc x_speed_hi                      ; ...
; &89a4 referenced 1 time by &899f
.return_from_move_right
    rts                                 ; Return
; ***************************************************************************************
; Move the pointer down
;
; Subtract the whole part of y_speed from pointer_y, stopping at 0, then accelerate:
; y_speed grows by &10 each call.
;
; On Exit:
;     A: corrupted
;     X: preserved
;     Y: preserved
; &89a5 referenced 3 times by &888d, &88cb, &8943
.move_pointer_down
    lda pointer_y                       ; pointer_y -= whole part of the speed
    sec                                 ; ...
    sbc y_speed_hi                      ; ...
    sta pointer_y                       ; ...
    lda pointer_y_hi                    ; ...
    sbc #0                              ; ...
    sta pointer_y_hi                    ; ...
    bpl accelerate_y_down               ; Still 0 or more?
    stz pointer_y                       ; No: stop at 0
    stz pointer_y_hi                    ; ...
; &89bf referenced 1 time by &89b7
.accelerate_y_down
    clc                                 ; y_speed += &10
    lda #speed_acceleration             ; ...
    adc y_speed                         ; ...
    sta y_speed                         ; ...
    bcc return_from_move_down           ; ...
    inc y_speed_hi                      ; ...
; &89cd referenced 1 time by &89c8
.return_from_move_down
    rts                                 ; Return
; ***************************************************************************************
; Move the pointer up
;
; Add the whole part of y_speed to pointer_y, stopping at 1020 (&3FC), then accelerate:
; y_speed grows by &10 each call.
;
; On Exit:
;     A: corrupted
;     X: preserved
;     Y: preserved
; &89ce referenced 3 times by &8883, &88c2, &8932
.move_pointer_up
    lda pointer_y                       ; pointer_y += whole part of the speed
    clc                                 ; ...
    adc y_speed_hi                      ; ...
    sta pointer_y                       ; ...
    lda pointer_y_hi                    ; ...
    adc #0                              ; ...
    sta pointer_y_hi                    ; ...
    cmp #4                              ; Beyond the top (high byte 4 or more)?
    bcc accelerate_y_up                 ; No
    lda #>(pointer_y_max)               ; Yes: stop at 1020 (&3FC)
    sta pointer_y_hi                    ; ...
    lda #<(pointer_y_max)               ; ...
    sta pointer_y                       ; ...
; &89ee referenced 1 time by &89e2
.accelerate_y_up
    clc                                 ; y_speed += &10
    lda #speed_acceleration             ; ...
    adc y_speed                         ; ...
    sta y_speed                         ; ...
    bcc return_from_move_up             ; ...
    inc y_speed_hi                      ; ...
; &89fc referenced 1 time by &89f7
.return_from_move_up
    rts                                 ; Return
; ***************************************************************************************
; Reset the horizontal speed
;
; Set x_speed to &0080, half a graphics unit: the first step after starting to move is 0,
; and steps grow by one unit every 16 polls.
; &89fd referenced 4 times by &82bd, &887b, &88b2, &8923
.reset_x_speed
    stz x_speed_hi                      ; Whole part 0
    lda #speed_initial                  ; Fraction one half
    sta x_speed                         ; ...
    rts                                 ; Return
; ***************************************************************************************
; Reset the vertical speed
;
; Set y_speed to &0080, as reset_x_speed.
; &8a06 referenced 4 times by &82c0, &8892, &88d0, &8948
.reset_y_speed
    stz y_speed_hi                      ; Whole part 0
    lda #speed_initial                  ; Fraction one half
    sta y_speed                         ; ...
    rts                                 ; Return
; ***************************************************************************************
; Poll: redraw the pointer and read the buttons
;
; The second half of the polling service call. If the pointer is shown, count down
; redraw_countdown and redraw the pointer when it goes negative (update_pointer, which
; only draws if the pointer has moved, and restarts the count at 10). Mouse interrupts
; also count it down, so a moving mouse is redrawn sooner. Then read the buttons
; (scan_buttons). Runs with interrupts disabled, inside enter_driver and leave_driver.
;
; On Exit:
;     A: preserved
;     X: preserved
;     Y: preserved
;     FLAGS: preserved
; &8a0f referenced 1 time by &8164
.poll_redraw_and_buttons
    php                                 ; Save the flags
    pha                                 ; and the registers
    phx                                 ; ...
    phy                                 ; ...
    sei                                 ; Interrupts off while the workspace is in use
    jsr enter_driver                    ; Bring in the workspace, save zero page
    lda pointer_shown                   ; Is the pointer shown?
    beq poll_buttons                    ; No
    dec redraw_countdown                ; Count down to the next redraw
    bpl poll_buttons                    ; Not yet
    jsr update_pointer                  ; Redraw it if it has moved
; &8a24 referenced 2 times by &8a1a, &8a1f
.poll_buttons
    jsr scan_buttons                    ; Read the buttons
    jsr leave_driver                    ; Put back zero page and the workspace
    jmp restore_registers_and_return    ; Restore everything and return
; ***************************************************************************************
; Read the buttons and turn presses into keys
;
; Read the buttons and, when a new button state has been seen on two polls running, put a
; key into the keyboard buffer (OSBYTE &99) for any button pressed in it:
;
; | Device    | Button                         | Key                             |
; |-----------|--------------------------------|---------------------------------|
; | Mouse     | left (Compact PB0, AMX PB5)    | RETURN (&0D)                    |
; | Mouse     | right (Compact PB2, AMX PB7)   | &C0                             |
; | Mouse     | middle (Compact PB1, AMX PB6)  | the TAB key's code (OSBYTE &DB) |
; | Joysticks | fire button 1 (ADVAL(0) bit 0) | RETURN (&0D)                    |
; | Joysticks | fire button 2 (ADVAL(0) bit 1) | the TAB key's code              |
; | Keys      | none                           |                                 |
;
; One key is sent per change, with priority in the order listed. The mouse buttons are
; read from User VIA port B, where a pressed button reads low, through pinout_table. If
; the pinout is not yet known, it is taken to be AMX if any of PB5-PB7 is low, and
; recorded; otherwise the Compact pinout is used for this read only.
;
; The debounce: button_state holds the last reading and button_pending a change waiting
; to be confirmed. A reading different from both is stored in both. A reading equal to
; button_pending is a confirmed change: the pending change is cleared and the keys are
; sent for button_state.
;
; 0 doubles as "nothing pending", so a reading of 0 (all three mouse buttons pressed, or
; both fire buttons) is never recorded: at every poll while it lasts it is taken as
; confirming a change, and the keys for button_state, the last other reading, are sent
; again.
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: corrupted
; &8a2d referenced 1 time by &8a24
.scan_buttons
    ldx device_mode                     ; Device mode
    bne scan_joystick_buttons           ; Not the mouse
    ldx pinout_index                    ; Mouse: is the pinout known?
    bpl scan_mouse_buttons              ; Yes
    ldx #0                              ; Assume the Compact pinout
    lda user_via_orb_irb                ; Are PB5-PB7 all high...
    and #&e0                            ; ...
    cmp #&e0                            ; ...(no AMX button pressed)?
    beq scan_mouse_buttons              ; Yes: Compact, for this read
    ldx #7                              ; No: the AMX pinout...
    stx pinout_index                    ; ...recorded
; &8a47 referenced 2 times by &8a35, &8a40
.scan_mouse_buttons
    lda user_via_orb_irb                ; Read port B...
    and pinout_table + 1,x              ; ...keeping the button bits
    cmp button_pending                  ; The pending change confirmed?
    beq mouse_buttons_changed           ; Yes: send the keys
    cmp button_state                    ; Same as the last reading?
    sta button_state                    ; Keep this reading
    beq return_from_buttons             ; Same: nothing to do
    sta button_pending                  ; Changed: wait for the next poll to confirm it
; &8a5d referenced 4 times by &8a58, &8a7c, &8a8a, &8a9d
.return_from_buttons
    rts                                 ; Return
; &8a5e referenced 1 time by &8a30
.scan_joystick_buttons
    cpx #device_mode_keys               ; Cursor keys?
    bne read_fire_buttons               ; No: joystick fire buttons
    rts                                 ; Yes: no buttons
; &8a63 referenced 1 time by &8a60
.read_fire_buttons
    lda #osbyte_read_adc_or_get_buffer_status  ; OSBYTE &80 with X=0: ADVAL(0)
    ldx #0                              ; ...
    ldy #0                              ; ...
    jsr osbyte                          ; ...  Read ADC channel X or buffer status
    txa                                 ; The two fire button bits...
    and #3                              ; ...
    eor #3                              ; ...inverted, so 0 = pressed as for the mouse
    cmp button_pending                  ; The pending change confirmed?
    beq joystick_buttons_changed        ; Yes: send the keys
    cmp button_state                    ; Same as the last reading?
    sta button_state                    ; Keep this reading
    beq return_from_buttons             ; Same: nothing to do
    sta button_pending                  ; Changed: wait for the next poll to confirm it
    rts                                 ; Return
; &8a82 referenced 1 time by &8a74
.joystick_buttons_changed
    stz button_pending                  ; Nothing pending now
    lda button_state                    ; Both buttons released?
    cmp #3                              ; ...
    beq return_from_buttons             ; Yes: no key
    ldy #key_return                     ; RETURN...
    and #1                              ; ...if fire button 1 is pressed
    beq insert_key                      ; ...
    bra insert_tab_key                  ; Otherwise fire button 2: TAB
; &8a94 referenced 1 time by &8a50
.mouse_buttons_changed
    stz button_pending                  ; Nothing pending now
    lda button_state                    ; All buttons released?
    cmp pinout_table + 1,x              ; ...
    beq return_from_buttons             ; Yes: no key
    ldy #key_return                     ; RETURN...
    and pinout_table + 2,x              ; ...if the left button is pressed
    beq insert_key                      ; ...
    lda button_state                    ; &C0...
    ldy #key_right_button               ; ...
    and pinout_table + 4,x              ; ...if the right button is pressed
    beq insert_key                      ; ...
; &8ab0 referenced 1 time by &8a92
.insert_tab_key
    lda #osbyte_tab_char                ; Otherwise the middle button: OSBYTE &DB, the TAB key code
    ldx #0                              ; X=0...
    ldy #&ff                            ; ...and Y=&FF: read it without changing it
    jsr osbyte                          ; ...  osbyte: tab char
    txa                                 ; ...
    tay                                 ; Y = that code
; &8abb referenced 3 times by &8a90, &8aa4, &8aae
.insert_key
    lda #osbyte_insert_input_buffer     ; OSBYTE &99: put Y into the keyboard buffer
    ldx #0                              ; (buffer 0) as if typed, and return
    jmp osbyte                          ; ...  Insert byte Y into input buffer X
; ***************************************************************************************
; Move the pointer for a mouse interrupt
;
; Called from irq_handler with the User VIA interrupt flags for CB1 and CB2 in Y. The
; mouse's two quadrature channels interrupt on CB1 (X) and CB2 (Y); at each interrupt the
; other signal of the channel, read from a port B bit, gives the direction:
;
; | Pinout                  | X direction | Y direction |
; |-------------------------|-------------|-------------|
; | Compact (joystick port) | PB3         | PB4         |
; | AMX (User Port)         | PB0         | PB2         |
;
; Each interrupt moves the pointer 4 graphics units, high meaning right or up and low
; left or down, clamped to 0-1276 and 0-1020. Only one edge of one signal per channel
; interrupts, so there is one step per quadrature cycle. Reading port B also clears the
; CB1 and CB2 interrupt flags.
;
; If the pinout is not yet known, it is taken to be Compact if either of PB3 and PB4 is
; low, and recorded; otherwise the AMX pinout is used for this interrupt only. Each
; interrupt also counts down redraw_countdown.
;
; On Entry:
;     Y: interrupt flags: bit 4 CB1, bit 3 CB2
;
; On Exit:
;     A: corrupted
;     X: corrupted
;     Y: preserved
; &8ac2 referenced 1 time by &883b
.mouse_movement
    dec redraw_countdown                ; Bring the next redraw forward
    ldx pinout_index                    ; Is the pinout known?
    bpl mouse_movement_x                ; Yes
    ldx #7                              ; Assume AMX
    lda user_via_orb_irb                ; Are PB3 and PB4 both high?
    and #&18                            ; ...
    cmp #&18                            ; ...
    beq mouse_movement_x                ; Yes: AMX, for this interrupt
    ldx #0                              ; No: the Compact pinout...
    stx pinout_index                    ; ...recorded
; &8ada referenced 2 times by &8ac8, &8ad3
.mouse_movement_x
    tya                                 ; Did CB1 (X) interrupt?
    and #via_int_cb1                    ; ...
    beq mouse_movement_y                ; No: check Y
    lda user_via_orb_irb                ; Read the X direction bit
    and pinout_table + 6,x              ; ...
    beq mouse_left                      ; Low: left
    lda pointer_x_hi                    ; High: right. Already at 1276 (&4FC)?
    cmp #4                              ; ...
    bne mouse_right                     ; No
    lda pointer_x                       ; ...
    cmp #&fc                            ; ...
    bcs mouse_movement_y                ; Yes: stay there
; &8af5 referenced 1 time by &8aec
.mouse_right
    lda pointer_x                       ; pointer_x += 4 (carry clear from the CMP)
    adc #4                              ; ...
    sta pointer_x                       ; ...
    bcc mouse_x_done                    ; ...
    inc pointer_x_hi                    ; ...
; &8b02 referenced 1 time by &8afd
.mouse_x_done
    bra mouse_movement_y                ; Go on to Y
; &8b04 referenced 1 time by &8ae5
.mouse_left
    lda pointer_x                       ; Already at 0?
    bne mouse_left_step                 ; No
    lda pointer_x_hi                    ; ...
    beq mouse_movement_y                ; Yes: stay there
    lda pointer_x                       ; ...
; &8b11 referenced 1 time by &8b07
.mouse_left_step
    sec                                 ; pointer_x -= 4
    sbc #4                              ; ...
    sta pointer_x                       ; ...
    lda pointer_x_hi                    ; ...
    sbc #0                              ; ...
    sta pointer_x_hi                    ; ...
; &8b1f referenced 4 times by &8add, &8af3, &8b02, &8b0c
.mouse_movement_y
    tya                                 ; Did CB2 (Y) interrupt?
    and #via_int_cb2                    ; ...
    beq return_from_mouse_movement      ; No: done
    lda user_via_orb_irb                ; Read the Y direction bit
    and pinout_table + 5,x              ; ...
    beq mouse_down                      ; Low: down
    lda pointer_y_hi                    ; High: up. Already at 1020 (&3FC)?
    cmp #3                              ; ...
    bne mouse_up                        ; No
    lda pointer_y                       ; ...
    cmp #&fc                            ; ...
    bcs return_from_mouse_movement      ; Yes: stay there
; &8b3a referenced 1 time by &8b31
.mouse_up
    lda pointer_y                       ; pointer_y += 4 (carry clear from the CMP)
    adc #4                              ; ...
    sta pointer_y                       ; ...
    bne return_from_mouse_up            ; ...
    inc pointer_y_hi                    ; ...
; &8b47 referenced 1 time by &8b42
.return_from_mouse_up
    rts                                 ; Return
; &8b48 referenced 1 time by &8b2a
.mouse_down
    lda pointer_y                       ; Already at 0?
    bne mouse_down_step                 ; No
    lda pointer_y_hi                    ; ...
    beq return_from_mouse_movement      ; Yes: stay there
    lda pointer_y                       ; ...
; &8b55 referenced 1 time by &8b4b
.mouse_down_step
    sec                                 ; pointer_y -= 4
    sbc #4                              ; ...
    sta pointer_y                       ; ...
    lda pointer_y_hi                    ; ...
    sbc #0                              ; ...
    sta pointer_y_hi                    ; ...
; &8b63 referenced 3 times by &8b22, &8b38, &8b50
.return_from_mouse_movement
    rts                                 ; Return
; ***************************************************************************************
; Mouse pinout table
;
; Two 7-byte records of User VIA port B masks, one for each way of wiring a mouse,
; indexed by pinout_index (0 or 7):
;
; | Offset | Use                            | Compact (0)   | AMX (7)       |
; |--------|--------------------------------|---------------|---------------|
; | +0     | both direction bits (not read) | &18: PB3, PB4 | &05: PB0, PB2 |
; | +1     | all three buttons              | &07: PB0-PB2  | &E0: PB5-PB7  |
; | +2     | left button                    | &01: PB0      | &20: PB5      |
; | +3     | middle button (not read)       | &02: PB1      | &40: PB6      |
; | +4     | right button                   | &04: PB2      | &80: PB7      |
; | +5     | Y direction                    | &10: PB4      | &04: PB2      |
; | +6     | X direction                    | &08: PB3      | &01: PB0      |
;
; The code reads offsets 1, 2, 4, 5 and 6; it tests the direction bits for pinout
; detection with a literal &18.
.pinout_table
    equb &18                            ; Compact: direction bits
    equb &07                            ; Compact: buttons
    equb &01                            ; Compact: left button
    equb &02                            ; Compact: middle button
    equb &04                            ; Compact: right button
    equb &10                            ; Compact: Y direction
    equb &08                            ; Compact: X direction
    equb &05                            ; AMX: direction bits
    equb &e0                            ; AMX: buttons
    equb &20                            ; AMX: left button
    equb &40                            ; AMX: middle button
    equb &80                            ; AMX: right button
    equb &04                            ; AMX: Y direction
    equb &01                            ; AMX: X direction
; ***************************************************************************************
; Exchange the working and stored pointer position
;
; As exchange_workspace, but for the first ten bytes only (&9000-&9009: the *TMAX values,
; the pointer position, the pinout and the redraw countdown), which is all the mouse
; interrupt needs.
;
; On Exit:
;     A: preserved
;     X: corrupted
;     Y: corrupted
; &8b72 referenced 2 times by &8837, &883e
.exchange_position_workspace
    pha                                 ; Save A
    lda zp_image_ptr                    ; and the zero page pointer used
    pha                                 ; ...
    lda zp_image_ptr_hi                 ; ...
    pha                                 ; ...
    ldx romsel_copy                     ; Point it at the stored copy: page +3...
    lda rom_workspace_table,x           ; ...
    clc                                 ; ...
    adc #3                              ; ...
    sta zp_image_ptr_hi                 ; ...
    lda #&40 ; '@'                      ; offset &40
    sta zp_image_ptr                    ; ...
    ldy #9                              ; 10 bytes, from the last
; &8b89 referenced 1 time by &8b95
.exchange_position_byte
    ldx tmax_x,y                        ; Working byte
    lda (zp_image_ptr),y                ; Stored byte...
    sta tmax_x,y                        ; ...becomes the working byte
    txa                                 ; Working byte...
    sta (zp_image_ptr),y                ; ...becomes the stored byte
    dey                                 ; Next
    bpl exchange_position_byte          ; ...
    pla                                 ; Restore the zero page pointer
    sta zp_image_ptr_hi                 ; ...
    pla                                 ; ...
    sta zp_image_ptr                    ; ...
    pla                                 ; Restore A
    rts                                 ; Return
; ***************************************************************************************
; Read a decimal number from the command line
;
; Read decimal digits at (cmd_ptr),Y into parsed_number, up to a space, comma or CR. Any
; other character raises "Bad number" (check_digit). Returns with carry set if there were
; no digits or the value exceeded 65535.
;
; On Entry:
;     Y: offset of the number
;
; On Exit:
;     PARSED_NUMBER: the value
;     FLAGS: C clear if a number was read, set otherwise
;     Y: offset of the terminator
;     A: corrupted
; &8b9f referenced 4 times by &8c0e, &8c1e, &8c4b, &8c5b
.parse_number
    lda #0                              ; Value = 0
    sta parsed_number                   ; ...
    sta parsed_number_hi                ; ...
    sec                                 ; Carry set on the stack: no digits yet
    php                                 ; ...
; &8ba9 referenced 1 time by &8c04
.parse_number_char
    lda (cmd_ptr),y                     ; Next character
    cmp #ASC(" ")                       ; Space?
    beq parse_number_done               ; Yes: end of the number
    cmp #ASC(",")                       ; Comma?
    beq parse_number_done               ; Yes: end of the number
    cmp #key_return                     ; CR?
    beq parse_number_done               ; Yes: end of the number
    jsr check_digit                     ; Anything but a digit: "Bad number"
    lda parsed_number                   ; Copy the value so far
    sta parse_temp                      ; ...
    lda parsed_number_hi                ; ...
    sta parse_temp_hi                   ; ...
    lda parsed_number                   ; Value * 2...
    asl a                               ; ...
    rol parsed_number_hi                ; ...
    bcs parse_number_too_big            ; Too big
    asl a                               ; - 4...
    rol parsed_number_hi                ; ...
    bcs parse_number_too_big            ; Too big
    adc parse_temp                      ; - the copy = * 5...
    sta parsed_number                   ; ...
    lda parsed_number_hi                ; ...
    adc parse_temp_hi                   ; ...
    bcs parse_number_too_big            ; Too big
    sta parsed_number_hi                ; ...
    asl parsed_number                   ; - 2 = * 10
    rol parsed_number_hi                ; ...
    bcs parse_number_too_big            ; Too big
    lda (cmd_ptr),y                     ; Add the digit
    and #&0f                            ; ...
    clc                                 ; ...
    adc parsed_number                   ; ...
    sta parsed_number                   ; ...
    bcc parse_number_digit_done         ; ...
    inc parsed_number_hi                ; ...
    beq parse_number_too_big            ; Too big
; &8c00 referenced 1 time by &8bf9
.parse_number_digit_done
    plp                                 ; Carry clear on the stack: a digit was read
    clc                                 ; ...
    php                                 ; ...
    iny                                 ; Next character
    bne parse_number_char               ; Always taken (Y does not wrap)
; &8c06 referenced 5 times by &8bcd, &8bd3, &8be1, &8bec, &8bfe
.parse_number_too_big
    plp                                 ; Carry set on the stack: failed
    sec                                 ; ...
    php                                 ; ...
; &8c09 referenced 3 times by &8bad, &8bb1, &8bb5
.parse_number_done
    plp                                 ; Carry = the result
    rts                                 ; Return
; ***************************************************************************************
; *TMAX x,y: set the values returned by ADVAL(5) and ADVAL(6)
;
; Read two numbers, 0-65535, separated by spaces or commas, and store them in tmax_x and
; tmax_y. Nothing else in PMFS uses them; in particular the pointer is not limited by
; them. A missing, malformed or too-large number gives "Bad number".
.cmd_tmax
    jsr reset_argument_index            ; First argument
    jsr parse_number                    ; Read x
    bcs raise_bad_number                ; None, or too big: "Bad number"
    lda parsed_number                   ; Keep x on the stack
    pha                                 ; ...
    lda parsed_number_hi                ; ...
    pha                                 ; ...
    jsr skip_separators                 ; Skip spaces and commas
    jsr parse_number                    ; Read y
    bcs discard_first_number            ; None, or too big: "Bad number"
    ldy #2                              ; Store y in tmax_y
    jsr store_parsed_number             ; ...
    pla                                 ; Recover x
    sta parsed_number_hi                ; ...
    pla                                 ; ...
    sta parsed_number                   ; ...
    ldy #0                              ; and store it in tmax_x
; ***************************************************************************************
; Store parsed_number in the workspace
;
; Store parsed_number at tmax_x+Y, with interrupts disabled.
;
; On Entry:
;     Y: offset from tmax_x: 0, 2, 4 or 6
;
; On Exit:
;     Y: incremented
;     A: corrupted
; &8c32 referenced 3 times by &8c25, &8c62, &8c6f
.store_parsed_number
    lda parsed_number                   ; Low byte
    php                                 ; Interrupts off
    sei                                 ; ...
    sta tmax_x,y                        ; ...
    lda parsed_number_hi                ; High byte
    iny                                 ; ...
    sta tmax_x,y                        ; ...
    plp                                 ; Interrupts back as they were
    rts                                 ; Return
; &8c43 referenced 2 times by &8c21, &8c5e
.discard_first_number
    pla                                 ; Drop the first number
    pla                                 ; ...
; &8c45 referenced 2 times by &8c11, &8c4e
.raise_bad_number
    jmp bad_number_error                ; "Bad number"
; ***************************************************************************************
; *TSET x,y: move the pointer
;
; Read two numbers, as *TMAX, and store them in pointer_x and pointer_y. They are not
; clamped to the screen. The pointer is redrawn at the next poll that redraws it.
.cmd_tset
    jsr reset_argument_index            ; First argument
    jsr parse_number                    ; Read x
    bcs raise_bad_number                ; None, or too big: "Bad number"
    lda parsed_number                   ; Keep x on the stack
    pha                                 ; ...
    lda parsed_number_hi                ; ...
    pha                                 ; ...
    jsr skip_separators                 ; Skip spaces and commas
    jsr parse_number                    ; Read y
    bcs discard_first_number            ; None, or too big: "Bad number"
    ldy #6                              ; Store y in pointer_y
    jsr store_parsed_number             ; ...
    pla                                 ; Recover x
    sta parsed_number_hi                ; ...
    pla                                 ; ...
    sta parsed_number                   ; ...
    ldy #4                              ; Store it in pointer_x and return
    jmp store_parsed_number             ; ...
; ***************************************************************************************
; Character row addresses for MODEs 0, 1 and 2, low bytes
;
; Start addresses of the 32 character rows of a 640-byte-per-row screen starting at
; &3000, counted up from the bottom row, followed by two more rows above the top of the
; screen. Indexed by calc_pointer_screen_address. The addresses assume the screen has not
; been scrolled by hardware.
.mode012_row_addr_lo
    equb <(&7d80)                       ; &7D80: row 0 from the bottom
    equb <(&7b00)                       ; &7B00: row 1 from the bottom
    equb <(&7880)                       ; &7880: row 2 from the bottom
    equb <(&7600)                       ; &7600: row 3 from the bottom
    equb <(&7380)                       ; &7380: row 4 from the bottom
    equb <(&7100)                       ; &7100: row 5 from the bottom
    equb <(&6e80)                       ; &6E80: row 6 from the bottom
    equb <(&6c00)                       ; &6C00: row 7 from the bottom
    equb <(&6980)                       ; &6980: row 8 from the bottom
    equb <(&6700)                       ; &6700: row 9 from the bottom
    equb <(&6480)                       ; &6480: row 10 from the bottom
    equb <(&6200)                       ; &6200: row 11 from the bottom
    equb <(&5f80)                       ; &5F80: row 12 from the bottom
    equb <(&5d00)                       ; &5D00: row 13 from the bottom
    equb <(&5a80)                       ; &5A80: row 14 from the bottom
    equb <(&5800)                       ; &5800: row 15 from the bottom
    equb <(&5580)                       ; &5580: row 16 from the bottom
    equb <(&5300)                       ; &5300: row 17 from the bottom
    equb <(&5080)                       ; &5080: row 18 from the bottom
    equb <(&4e00)                       ; &4E00: row 19 from the bottom
    equb <(&4b80)                       ; &4B80: row 20 from the bottom
    equb <(&4900)                       ; &4900: row 21 from the bottom
    equb <(&4680)                       ; &4680: row 22 from the bottom
    equb <(&4400)                       ; &4400: row 23 from the bottom
    equb <(&4180)                       ; &4180: row 24 from the bottom
    equb <(&3f00)                       ; &3F00: row 25 from the bottom
    equb <(&3c80)                       ; &3C80: row 26 from the bottom
    equb <(&3a00)                       ; &3A00: row 27 from the bottom
    equb <(&3780)                       ; &3780: row 28 from the bottom
    equb <(&3500)                       ; &3500: row 29 from the bottom
    equb <(&3280)                       ; &3280: row 30 from the bottom
    equb <(&3000)                       ; &3000: row 31 from the bottom
    equb <(&2d80)                       ; &2D80: above the screen
    equb <(&2b00)                       ; &2B00: above the screen
; ***************************************************************************************
; Character row addresses for MODEs 0, 1 and 2, high bytes
.mode012_row_addr_hi
    equb >(&7d80)                       ; &7D80: row 0 from the bottom
    equb >(&7b00)                       ; &7B00: row 1 from the bottom
    equb >(&7880)                       ; &7880: row 2 from the bottom
    equb >(&7600)                       ; &7600: row 3 from the bottom
    equb >(&7380)                       ; &7380: row 4 from the bottom
    equb >(&7100)                       ; &7100: row 5 from the bottom
    equb >(&6e80)                       ; &6E80: row 6 from the bottom
    equb >(&6c00)                       ; &6C00: row 7 from the bottom
    equb >(&6980)                       ; &6980: row 8 from the bottom
    equb >(&6700)                       ; &6700: row 9 from the bottom
    equb >(&6480)                       ; &6480: row 10 from the bottom
    equb >(&6200)                       ; &6200: row 11 from the bottom
    equb >(&5f80)                       ; &5F80: row 12 from the bottom
    equb >(&5d00)                       ; &5D00: row 13 from the bottom
    equb >(&5a80)                       ; &5A80: row 14 from the bottom
    equb >(&5800)                       ; &5800: row 15 from the bottom
    equb >(&5580)                       ; &5580: row 16 from the bottom
    equb >(&5300)                       ; &5300: row 17 from the bottom
    equb >(&5080)                       ; &5080: row 18 from the bottom
    equb >(&4e00)                       ; &4E00: row 19 from the bottom
    equb >(&4b80)                       ; &4B80: row 20 from the bottom
    equb >(&4900)                       ; &4900: row 21 from the bottom
    equb >(&4680)                       ; &4680: row 22 from the bottom
    equb >(&4400)                       ; &4400: row 23 from the bottom
    equb >(&4180)                       ; &4180: row 24 from the bottom
    equb >(&3f00)                       ; &3F00: row 25 from the bottom
    equb >(&3c80)                       ; &3C80: row 26 from the bottom
    equb >(&3a00)                       ; &3A00: row 27 from the bottom
    equb >(&3780)                       ; &3780: row 28 from the bottom
    equb >(&3500)                       ; &3500: row 29 from the bottom
    equb >(&3280)                       ; &3280: row 30 from the bottom
    equb >(&3000)                       ; &3000: row 31 from the bottom
    equb >(&2d80)                       ; &2D80: above the screen
    equb >(&2b00)                       ; &2B00: above the screen
; ***************************************************************************************
; Character row addresses for MODEs 4 and 5, low bytes
;
; Start addresses of the 32 character rows of a 320-byte-per-row screen starting at
; &5800, counted up from the bottom row, followed by two more rows above the top of the
; screen. Indexed by calc_pointer_screen_address. The addresses assume the screen has not
; been scrolled by hardware.
.mode45_row_addr_lo
    equb <(&7ec0)                       ; &7EC0: row 0 from the bottom
    equb <(&7d80)                       ; &7D80: row 1 from the bottom
    equb <(&7c40)                       ; &7C40: row 2 from the bottom
    equb <(&7b00)                       ; &7B00: row 3 from the bottom
    equb <(&79c0)                       ; &79C0: row 4 from the bottom
    equb <(&7880)                       ; &7880: row 5 from the bottom
    equb <(&7740)                       ; &7740: row 6 from the bottom
    equb <(&7600)                       ; &7600: row 7 from the bottom
    equb <(&74c0)                       ; &74C0: row 8 from the bottom
    equb <(&7380)                       ; &7380: row 9 from the bottom
    equb <(&7240)                       ; &7240: row 10 from the bottom
    equb <(&7100)                       ; &7100: row 11 from the bottom
    equb <(&6fc0)                       ; &6FC0: row 12 from the bottom
    equb <(&6e80)                       ; &6E80: row 13 from the bottom
    equb <(&6d40)                       ; &6D40: row 14 from the bottom
    equb <(&6c00)                       ; &6C00: row 15 from the bottom
    equb <(&6ac0)                       ; &6AC0: row 16 from the bottom
    equb <(&6980)                       ; &6980: row 17 from the bottom
    equb <(&6840)                       ; &6840: row 18 from the bottom
    equb <(&6700)                       ; &6700: row 19 from the bottom
    equb <(&65c0)                       ; &65C0: row 20 from the bottom
    equb <(&6480)                       ; &6480: row 21 from the bottom
    equb <(&6340)                       ; &6340: row 22 from the bottom
    equb <(&6200)                       ; &6200: row 23 from the bottom
    equb <(&60c0)                       ; &60C0: row 24 from the bottom
    equb <(&5f80)                       ; &5F80: row 25 from the bottom
    equb <(&5e40)                       ; &5E40: row 26 from the bottom
    equb <(&5d00)                       ; &5D00: row 27 from the bottom
    equb <(&5bc0)                       ; &5BC0: row 28 from the bottom
    equb <(&5a80)                       ; &5A80: row 29 from the bottom
    equb <(&5940)                       ; &5940: row 30 from the bottom
    equb <(&5800)                       ; &5800: row 31 from the bottom
    equb <(&56c0)                       ; &56C0: above the screen
    equb <(&5580)                       ; &5580: above the screen
; ***************************************************************************************
; Character row addresses for MODEs 4 and 5, high bytes
.mode45_row_addr_hi
    equb >(&7ec0)                       ; &7EC0: row 0 from the bottom
    equb >(&7d80)                       ; &7D80: row 1 from the bottom
    equb >(&7c40)                       ; &7C40: row 2 from the bottom
    equb >(&7b00)                       ; &7B00: row 3 from the bottom
    equb >(&79c0)                       ; &79C0: row 4 from the bottom
    equb >(&7880)                       ; &7880: row 5 from the bottom
    equb >(&7740)                       ; &7740: row 6 from the bottom
    equb >(&7600)                       ; &7600: row 7 from the bottom
    equb >(&74c0)                       ; &74C0: row 8 from the bottom
    equb >(&7380)                       ; &7380: row 9 from the bottom
    equb >(&7240)                       ; &7240: row 10 from the bottom
    equb >(&7100)                       ; &7100: row 11 from the bottom
    equb >(&6fc0)                       ; &6FC0: row 12 from the bottom
    equb >(&6e80)                       ; &6E80: row 13 from the bottom
    equb >(&6d40)                       ; &6D40: row 14 from the bottom
    equb >(&6c00)                       ; &6C00: row 15 from the bottom
    equb >(&6ac0)                       ; &6AC0: row 16 from the bottom
    equb >(&6980)                       ; &6980: row 17 from the bottom
    equb >(&6840)                       ; &6840: row 18 from the bottom
    equb >(&6700)                       ; &6700: row 19 from the bottom
    equb >(&65c0)                       ; &65C0: row 20 from the bottom
    equb >(&6480)                       ; &6480: row 21 from the bottom
    equb >(&6340)                       ; &6340: row 22 from the bottom
    equb >(&6200)                       ; &6200: row 23 from the bottom
    equb >(&60c0)                       ; &60C0: row 24 from the bottom
    equb >(&5f80)                       ; &5F80: row 25 from the bottom
    equb >(&5e40)                       ; &5E40: row 26 from the bottom
    equb >(&5d00)                       ; &5D00: row 27 from the bottom
    equb >(&5bc0)                       ; &5BC0: row 28 from the bottom
    equb >(&5a80)                       ; &5A80: row 29 from the bottom
    equb >(&5940)                       ; &5940: row 30 from the bottom
    equb >(&5800)                       ; &5800: row 31 from the bottom
    equb >(&56c0)                       ; &56C0: above the screen
    equb >(&5580)                       ; &5580: above the screen
; ***************************************************************************************
; Graphics units per screen byte, by screen format
;
; How far the left edge moves for each byte column: 16 graphics units in MODEs 0-2 (8, 4
; or 2 pixels of 2, 4 or 8 units), 32 in MODEs 4 and 5.
.units_per_screen_byte
    equb &10                            ; Format 0, MODE 0
    equb &10                            ; Format 1, MODE 1
    equb &10                            ; Format 2, MODE 2
    equb &20                            ; Format 3, MODE 4
    equb &20                            ; Format 4, MODE 5
; ***************************************************************************************
; Bytes per character row, by screen format
;
; Low bytes then high bytes: 640 (&280) in MODEs 0-2, 320 (&140) in MODEs 4 and 5.
.char_row_bytes_lo
    equb &80                            ; Format 0, MODE 0: low byte
    equb &80                            ; Format 1, MODE 1: low byte
    equb &80                            ; Format 2, MODE 2: low byte
    equb &40                            ; Format 3, MODE 4: low byte
    equb &40                            ; Format 4, MODE 5: low byte
.char_row_bytes_hi
    equb &02                            ; Format 0, MODE 0: high byte
    equb &02                            ; Format 1, MODE 1: high byte
    equb &02                            ; Format 2, MODE 2: high byte
    equb &01                            ; Format 3, MODE 4: high byte
    equb &01                            ; Format 4, MODE 5: high byte
; ***************************************************************************************
; Offsets of the four shifted pointer copies
;
; Offset within pointer_image_copies of the copy for each shift, 0-3. The second four
; bytes repeat the first and are not read.
.shifted_copy_offsets
    equb &00                            ; Shift 0
    equb &40                            ; Shift 1
    equb &80                            ; Shift 2
    equb &c0                            ; Shift 3
    equb &00                            ; Not read
    equb &40                            ; Not read
    equb &80                            ; Not read
    equb &c0                            ; Not read
; ***************************************************************************************
; Pointer hot spot
;
; How far the pointer's position is right of the left edge and below the top edge of the
; image, in graphics units: 4 and 4, which is the tip of the arrow.
.hotspot_x
    equb &04                            ; X: graphics units right of the left edge
.hotspot_y
    equb &04                            ; Y: graphics units below the top edge
; ***************************************************************************************
; Pointer images
;
; One 64-byte image for each screen format, 0-4: 4 byte columns of 16 pixel rows each,
; column by column. Bits set are drawn in logical colour 1 (OR onto the screen). Together
; with the masks that follow, the pointer is an arrow outlined in colour 0. In MODE 0
; ("#" image, "." outline in colour 0, blank transparent):
;
;     ....
;     ..##..
;     ..####..
;     ..######..
;     ..########..
;     ..##########..
;     ..############..
;     ..########....
;     ..##..####..
;     ........####..
;           ..####..
;             ..####..
;             ..####..
;               ..####..
;               ..####..
;                 ....
;
; The other formats have the same shape at their own pixel sizes, except at the left
; edge, where the outline is one pixel wide in MODE 4 and absent in MODE 5.
.pointer_images
    equb &00, &30, &3c, &3f, &3f, &3f, &3f, &3f, &33, &00, &00, &00, &00, &00, &00, &00  ; MODE 0 image, column 0
    equb &00, &00, &00, &00, &c0, &f0, &fc, &c0, &c0, &f0, &f0, &3c, &3c, &0f, &0f, &00  ; MODE 0 image, column 1
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 0 image, column 2
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 0 image, column 3
    equb &00, &04, &06, &07, &07, &07, &07, &07, &05, &00, &00, &00, &00, &00, &00, &00  ; MODE 1 image, column 0
    equb &00, &00, &00, &00, &08, &0c, &0e, &08, &08, &0c, &0c, &06, &06, &03, &03, &00  ; MODE 1 image, column 1
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 1 image, column 2
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 1 image, column 3
    equb &00, &01, &01, &01, &01, &01, &01, &01, &01, &00, &00, &00, &00, &00, &00, &00  ; MODE 2 image, column 0
    equb &00, &00, &00, &02, &02, &03, &03, &02, &02, &01, &01, &01, &01, &00, &00, &00  ; MODE 2 image, column 1
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &02, &02, &00  ; MODE 2 image, column 2
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 2 image, column 3
    equb &00, &70, &7c, &7f, &7f, &7f, &7f, &7f, &73, &40, &00, &00, &00, &00, &00, &00  ; MODE 4 image, column 0
    equb &00, &00, &00, &00, &c0, &f0, &fc, &c0, &c0, &f0, &f0, &3c, &3c, &0f, &0f, &00  ; MODE 4 image, column 1
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 4 image, column 2
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 4 image, column 3
    equb &08, &0c, &0e, &0f, &0f, &0f, &0f, &0f, &0d, &08, &00, &00, &00, &00, &00, &00  ; MODE 5 image, column 0
    equb &00, &00, &00, &00, &08, &0c, &0e, &08, &08, &0c, &0c, &06, &06, &03, &03, &00  ; MODE 5 image, column 1
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 5 image, column 2
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00  ; MODE 5 image, column 3
; ***************************************************************************************
; Pointer masks
;
; One 64-byte mask for each screen format, laid out as the images. The screen is ANDed
; with the mask before the image is ORed in, so set bits leave the screen showing through
; and clear bits are the pointer's shape.
.pointer_masks
    equb &0f, &03, &00, &00, &00, &00, &00, &00, &00, &00, &fc, &ff, &ff, &ff, &ff, &ff  ; MODE 0 mask, column 0
    equb &ff, &ff, &ff, &3f, &0f, &03, &00, &03, &0f, &03, &03, &00, &00, &c0, &c0, &f0  ; MODE 0 mask, column 1
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &3f, &3f, &ff  ; MODE 0 mask, column 2
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff  ; MODE 0 mask, column 3
    equb &33, &11, &00, &00, &00, &00, &00, &00, &00, &00, &ee, &ff, &ff, &ff, &ff, &ff  ; MODE 1 mask, column 0
    equb &ff, &ff, &ff, &77, &33, &11, &00, &11, &33, &11, &11, &00, &00, &88, &88, &cc  ; MODE 1 mask, column 1
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &77, &77, &ff  ; MODE 1 mask, column 2
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff  ; MODE 1 mask, column 3
    equb &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &ff, &ff, &ff, &ff, &ff, &ff  ; MODE 2 mask, column 0
    equb &ff, &55, &55, &00, &00, &00, &00, &00, &00, &00, &00, &00, &00, &aa, &aa, &ff  ; MODE 2 mask, column 1
    equb &ff, &ff, &ff, &ff, &ff, &55, &55, &ff, &ff, &55, &55, &55, &55, &00, &00, &55  ; MODE 2 mask, column 2
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff  ; MODE 2 mask, column 3
    equb &0f, &03, &00, &00, &00, &00, &00, &00, &00, &00, &fc, &ff, &ff, &ff, &ff, &ff  ; MODE 4 mask, column 0
    equb &ff, &ff, &ff, &3f, &0f, &03, &00, &03, &0f, &03, &03, &00, &00, &c0, &c0, &f0  ; MODE 4 mask, column 1
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &3f, &3f, &ff  ; MODE 4 mask, column 2
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff  ; MODE 4 mask, column 3
    equb &33, &11, &00, &00, &00, &00, &00, &00, &00, &00, &ee, &ff, &ff, &ff, &ff, &ff  ; MODE 5 mask, column 0
    equb &ff, &ff, &ff, &77, &33, &11, &00, &11, &33, &11, &11, &00, &00, &88, &88, &cc  ; MODE 5 mask, column 1
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &77, &77, &ff  ; MODE 5 mask, column 2
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff  ; MODE 5 mask, column 3
; ***************************************************************************************
; Initials
;
; Two sets of initials, JPG and PMF, after the code and data. Nothing refers to them. PMF
; also appears in the ROM's copyright string, (C)1986 PMF, and has been identified as
; Paul Fellows, who led Acornsoft's languages group and then the team that wrote Arthur.
; Who JPG is is not known.
.initials
    equs "JPG,PMF"                      ; Not used by the code
; ***************************************************************************************
; Unused space and workspace
;
; Zero to the end of the 8 KB image. The driver's RAM workspace is in this area: it runs
; from sideways RAM, and &9000 upwards in its own bank holds its variables (labelled from
; tmax_x), pointer_image_copies (&9200), pointer_mask_copies (&9300),
; screen_under_pointer (&9400) and stored_workspace (&9440). The image carries them as
; zero.
.unused_space
    for _dasmos_fill%, 1, 102 : equb &00 : next  ; Unused
; ***************************************************************************************
; Driver workspace
;
; &9000-&902F is the working copy of the driver's state, exchanged with stored_workspace
; on entry to and exit from the driver (exchange_workspace). &9030-&9037 is used in
; place. See each label for its use.
; &9000 used as index base 8 times by &857a, &857f, &87dc, &87e1, &8b89, &8b8e, &8c37, &8c3e
.tmax_x
    equb &00
.tmax_x_hi
    equb &00
.tmax_y
    equb &00, &00
; &9004 referenced 17 times by &830f, &83d7, &840f, &844c, &845a, &894d, &8954, &8964, &8976, &897d, &8993, &8aee, &8af5, &8afa, &8b04, &8b0e, &8b14
.pointer_x
    equb &00
; &9005 referenced 15 times by &8314, &841f, &8452, &8464, &8957, &895c, &8961, &8980, &8985, &898e, &8ae7, &8aff, &8b09, &8b17, &8b1c
.pointer_x_hi
    equb &00
; &9006 referenced 16 times by &8319, &8417, &8440, &8470, &89a5, &89ac, &89b9, &89ce, &89d5, &89eb, &8b33, &8b3a, &8b3f, &8b48, &8b52, &8b58
.pointer_y
    equb &00
; &9007 referenced 15 times by &831e, &8427, &8446, &8476, &89af, &89b4, &89bc, &89d8, &89dd, &89e6, &8b2c, &8b44, &8b4d, &8b5b, &8b60
.pointer_y_hi
    equb &00
; &9008 referenced 7 times by &82e4, &87f8, &880a, &8a32, &8a44, &8ac5, &8ad7
.pinout_index
    equb &00
; &9009 referenced 3 times by &840c, &8a1c, &8ac2
.redraw_countdown
    equb &00
; &900a referenced 7 times by &804e, &8267, &828f, &82cc, &82d8, &83b2, &83bc
.driver_on
    equb &00
; &900b referenced 7 times by &8051, &82d4, &83b7, &83bf, &83e7, &8406, &8a17
.pointer_shown
    equb &00
; &900c referenced 12 times by &8ba1, &8bba, &8bc6, &8bd8, &8be6, &8bf3, &8bf6, &8c13, &8c2d, &8c32, &8c50, &8c6a
.parsed_number
    equb &00
; &900d referenced 13 times by &8ba4, &8bc0, &8bca, &8bd0, &8bdb, &8be3, &8be9, &8bfb, &8c17, &8c29, &8c3a, &8c54, &8c66
.parsed_number_hi
    equb &00
; &900e referenced 2 times by &8bbd, &8bd5
.parse_temp
    equb &00
; &900f referenced 2 times by &8bc3, &8bde
.parse_temp_hi
    equb &00
    for _dasmos_fill%, 1, 2 : equb &00 : next  ; Not used
; &9012 referenced 10 times by &808d, &80b7, &80df, &83a1, &84ea, &8514, &85f3, &860a, &865e, &86d8
.screen_format
    equb &00
; &9013 referenced 1 time by &865a
.pointer_shape
    equb &00
; &9014 referenced 7 times by &8a52, &8a55, &8a76, &8a79, &8a85, &8a97, &8aa6
.button_state
    equb &00
; &9015 referenced 8 times by &8054, &82d1, &8a4d, &8a5a, &8a71, &8a7e, &8a82, &8a94
.button_pending
    equb &00
; &9016 referenced 3 times by &83db, &8412, &844f
.drawn_x
    equb &00
; &9017 referenced 2 times by &8422, &8455
.drawn_x_hi
    equb &00
; &9018 referenced 2 times by &841a, &8443
.drawn_y
    equb &00
; &9019 referenced 2 times by &842a, &8449
.drawn_y_hi
    equb &00
; &901a referenced 6 times by &80b4, &80dc, &8461, &8491, &8517, &851e
.pointer_left
    equb &00
; &901b referenced 6 times by &8076, &80aa, &8469, &8497, &84ba, &8523
.pointer_left_hi
    equb &00
; &901c referenced 3 times by &8494, &860d, &8614
.drawn_left
    equb &00
; &901d referenced 3 times by &849a, &85cf, &8619
.drawn_left_hi
    equb &00
; &901e referenced 6 times by &8066, &806f, &8085, &808a, &80d1, &8473
.pointer_top
    equb &00
; &901f referenced 2 times by &8061, &847b
.pointer_top_hi
    equb &00
; &9020 referenced 2 times by &854f, &859f
.saved_drawn_ptr
    equb &00
; &9021 referenced 2 times by &8554, &85a4
.saved_drawn_ptr_hi
    equb &00
; &9022 used as index base 2 times by &8559, &8599
.saved_zero_page
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00
; &902e referenced 4 times by &83ef, &8400, &8432, &8546
.saved_acccon
    equb &00
    for _dasmos_fill%, 1, 1 : equb &00 : next  ; Not used
; &9030 referenced 2 times by &8182, &8199
.cmd_start_offset
    equb &00
; &9031 referenced 10 times by &8057, &8295, &82ae, &82b5, &82ba, &82e7, &83c4, &87ef, &884c, &8a2d
.device_mode
    equb &00
; &9032 referenced 7 times by &88e8, &88eb, &896a, &896d, &8999, &899c, &8a02
.x_speed
    equb &00
; &9033 referenced 6 times by &88f0, &8951, &8972, &897a, &89a1, &89fd
.x_speed_hi
    equb &00
; &9034 referenced 7 times by &88f6, &88f9, &89c2, &89c5, &89f1, &89f4, &8a0b
.y_speed
    equb &00
; &9035 referenced 6 times by &88fe, &89a9, &89ca, &89d2, &89f9, &8a06
.y_speed_hi
    equb &00
; &9036 referenced 2 times by &80f7, &8126; also used as index base 4 times by &8139, &813f, &8144, &8159
.desktop_colours
    equb &00
; &9037 referenced 2 times by &8112, &812b
.desktop_colour_1
    equb &00
    for _dasmos_fill%, 1, 456 : equb &00 : next  ; Not used
.pointer_image_copies
    for _dasmos_fill%, 1, 256 : equb &00 : next  ; Pointer image copies (built at run time)
.pointer_mask_copies
    for _dasmos_fill%, 1, 256 : equb &00 : next  ; Pointer mask copies (built at run time)
.screen_under_pointer
    for _dasmos_fill%, 1, 64 : equb &00 : next  ; Screen under the pointer (at run time)
.stored_workspace
    for _dasmos_fill%, 1, 48 : equb &00 : next  ; Stored workspace (at run time)
    for _dasmos_fill%, 1, 2960 : equb &00 : next  ; Not used
.dasmos_end

save dasmos_start, dasmos_end

; Label references by decreasing frequency:
;     zp_image_index:                  29
;     zp_image_ptr:                    26
;     zp_screen_ptr:                   23
;     cmd_ptr:                         19
;     osbyte:                          17
;     pointer_x:                       17
;     pointer_y:                       16
;     pointer_x_hi:                    15
;     pointer_y_hi:                    15
;     zp_image_ptr_hi:                 14
;     zp_row_in_cell:                  14
;     zp_under_ptr:                    14
;     parsed_number_hi:                13
;     zp_screen_ptr_hi:                13
;     oswrch:                          12
;     parsed_number:                   12
;     zp_drawn_ptr:                    11
;     zp_temp:                         11
;     device_mode:                     10
;     romsel_copy:                     10
;     screen_format:                   10
;     zp_drawn_ptr_hi:                  9
;     button_pending:                   8
;     rom_workspace_table:              8
;     tmax_x:                           8
;     button_state:                     7
;     driver_on:                        7
;     pinout_index:                     7
;     pointer_shown:                    7
;     user_via_orb_irb:                 7
;     x_speed:                          7
;     y_speed:                          7
;     zp_under_ptr_hi:                  7
;     acccon:                           6
;     desktop_colours:                  6
;     pointer_left:                     6
;     pointer_left_hi:                  6
;     pointer_top:                      6
;     return_from_pointer:              6
;     x_speed_hi:                       6
;     y_speed_hi:                       6
;     exchange_workspace:               5
;     finish_poll_move:                 5
;     parse_number_too_big:             5
;     skip_separators:                  5
;     user_via_ier:                     5
;     mouse_movement_y:                 4
;     parse_number:                     4
;     reset_argument_index:             4
;     reset_x_speed:                    4
;     reset_y_speed:                    4
;     restore_registers_and_return:     4
;     return_from_buttons:              4
;     return_from_service:              4
;     saved_acccon:                     4
;     advance_to_next_copy:             3
;     bad_number_error:                 3
;     bytev:                            3
;     bytev + 1:                        3
;     drawn_left:                       3
;     drawn_left_hi:                    3
;     drawn_x:                          3
;     enter_driver:                     3
;     find_handler_address:             3
;     insert_key:                       3
;     irq1v:                            3
;     irq1v + 1:                        3
;     leave_driver:                     3
;     move_pointer_down:                3
;     move_pointer_left:                3
;     move_pointer_on_screen:           3
;     move_pointer_right:               3
;     move_pointer_up:                  3
;     parse_number_done:                3
;     redraw_countdown:                 3
;     return_from_mouse_movement:       3
;     saved_bytev:                      3
;     select_device:                    3
;     store_parsed_number:              3
;     build_2colour_copies:             2
;     build_4colour_copies:             2
;     cmd_handler_ptr:                  2
;     cmd_ptr_hi:                       2
;     cmd_start_offset:                 2
;     copy_unshifted:                   2
;     desktop_colour_1:                 2
;     discard_first_number:             2
;     draw_char_row:                    2
;     draw_skip_column:                 2
;     drawn_x_hi:                       2
;     drawn_y:                          2
;     drawn_y_hi:                       2
;     exchange_position_workspace:      2
;     finish_drawing:                   2
;     irq_return:                       2
;     match_command_char:               2
;     mouse_movement_x:                 2
;     not_pmfs_osbyte:                  2
;     parse_temp:                       2
;     parse_temp_hi:                    2
;     pass_to_previous_bytev:           2
;     pointer_top_hi:                   2
;     poll_buttons:                     2
;     poll_digital_done:                2
;     poll_digital_vertical:            2
;     poll_joystick_vertical:           2
;     poll_keys_done:                   2
;     poll_keys_left:                   2
;     poll_keys_up:                     2
;     raise_bad_number:                 2
;     read_mouse_buttons_port:          2
;     remove_pointer_and_mouse:         2
;     restore_char_row:                 2
;     restore_next_column:              2
;     restore_screen_under_pointer:     2
;     restore_skip_column:              2
;     return_from_device_command:       2
;     saved_bytev_hi:                   2
;     saved_drawn_ptr:                  2
;     saved_drawn_ptr_hi:               2
;     saved_irq1v:                      2
;     saved_irq1v_hi:                   2
;     saved_zero_page:                  2
;     scan_mouse_buttons:               2
;     shift_2colour_copy:               2
;     shift_2colour_pixel:              2
;     shift_4colour_copy:               2
;     update_pointer:                   2
;     user_via_acr:                     2
;     user_via_pcr:                     2
;     vdu_screen_start_hi:              2
;     zp_skip_rows:                     2
;     accelerate_x_left:                1
;     accelerate_x_right:               1
;     accelerate_y_down:                1
;     accelerate_y_up:                  1
;     add_column_offset:                1
;     advance_to_arguments:             1
;     build_16colour_copies:            1
;     build_pointer_images:             1
;     build_shifted_copies:             1
;     bytev_adval:                      1
;     calc_pointer_screen_address:      1
;     calc_shift:                       1
;     call_command_handler:             1
;     centre_pointer:                   1
;     check_above_screen:               1
;     check_digit:                      1
;     cmd_handler_ptr_hi:               1
;     command_abbreviated:              1
;     command_name_matched:             1
;     command_table:                    1
;     copy_image_and_mask_byte:         1
;     copy_unshifted_byte:              1
;     disable_mouse_interrupts:         1
;     dispatch_service:                 1
;     draw_next_char_row:               1
;     draw_next_column:                 1
;     draw_next_column_address:         1
;     draw_pixel_row:                   1
;     draw_set_acccon:                  1
;     draw_skip_rows_above_screen:      1
;     exchange_position_byte:           1
;     exchange_workspace_byte:          1
;     finish_restoring:                 1
;     halve_column_offset:              1
;     insert_tab_key:                   1
;     irq1v_trampoline:                 1
;     irq1v_trampoline_jmp:             1
;     irq1v_trampoline_target:          1
;     irq1v_trampoline_target_hi:       1
;     joystick_buttons_changed:         1
;     jump_to_command_handler:          1
;     look_up_mode45_row_address:       1
;     look_up_row_address:              1
;     mouse_buttons_changed:            1
;     mouse_down:                       1
;     mouse_down_step:                  1
;     mouse_left:                       1
;     mouse_left_step:                  1
;     mouse_movement:                   1
;     mouse_right:                      1
;     mouse_up:                         1
;     mouse_x_done:                     1
;     next_command_char:                1
;     os_text_ptr:                      1
;     os_text_ptr_hi:                   1
;     osbyte_a:                         1
;     osbyte_x:                         1
;     parse_number_char:                1
;     parse_number_digit_done:          1
;     pointer_mouse_interrupts_off:     1
;     pointer_shape:                    1
;     poll_digital:                     1
;     poll_digital_down:                1
;     poll_digital_or_keys:             1
;     poll_digital_right:               1
;     poll_digital_x_still:             1
;     poll_digital_y_still:             1
;     poll_joystick:                    1
;     poll_joystick_down:               1
;     poll_joystick_right:              1
;     poll_joystick_x_still:            1
;     poll_joystick_y_still:            1
;     poll_keys:                        1
;     poll_keys_boost_y:                1
;     poll_keys_down:                   1
;     poll_keys_right:                  1
;     poll_keys_x_still:                1
;     poll_keys_y_still:                1
;     poll_move_pointer:                1
;     poll_not_mouse:                   1
;     poll_redraw_and_buttons:          1
;     read_device_mode:                 1
;     read_fire_buttons:                1
;     read_mouse_buttons_bits:          1
;     remove_pointer:                   1
;     remove_pointer_set_acccon:        1
;     reset_desktop_colours:            1
;     reset_driver_state:               1
;     restore_next_char_row:            1
;     restore_next_column_address:      1
;     restore_pixel_row:                1
;     restore_skip_rows_above_screen:   1
;     restore_zero_page:                1
;     return_adval:                     1
;     return_from_dispatch:             1
;     return_from_enter_driver:         1
;     return_from_mouse_up:             1
;     return_from_move_down:            1
;     return_from_move_left:            1
;     return_from_move_right:           1
;     return_from_move_up:              1
;     return_from_shifting:             1
;     return_from_skip_separators:      1
;     save_zero_page:                   1
;     scan_buttons:                     1
;     scan_joystick_buttons:            1
;     service_command:                  1
;     service_handler:                  1
;     set_desktop_colours:              1
;     set_mouse_interrupts:             1
;     set_screen_format:                1
;     shift_16colour_byte:              1
;     shift_16colour_copy:              1
;     shift_16colour_row:               1
;     shift_16colour_set_pixel:         1
;     shift_16colour_store:             1
;     shift_2colour_byte:               1
;     shift_2colour_row:                1
;     shift_4colour_byte:               1
;     shift_4colour_high_bit:           1
;     shift_4colour_rotate:             1
;     shift_4colour_row:                1
;     shift_4colour_set_bit4:           1
;     skip_separator:                   1
;     skip_to_next_command:             1
;     step_desktop_colour:              1
;     store_column_offset_hi:           1
;     try_next_colour:                  1
;     turn_driver_off:                  1
;     user_via_ddrb:                    1
;     user_via_ifr:                     1

; Stats:
;     Total size (Code + Data) = 8192 bytes
;     Code                     = 3045 bytes (37%)
;     Data                     = 5147 bytes (63%)
;
;     Number of instructions   = 1452
;     Number of data bytes     = 5056 bytes
;     Number of data words     = 0 bytes
;     Number of string bytes   = 91 bytes
;     Number of strings        = 14
