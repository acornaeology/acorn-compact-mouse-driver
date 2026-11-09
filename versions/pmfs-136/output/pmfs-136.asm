; Constants
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
data_0084        = &84
; &84 referenced 8 times by &848c, &84cd, &84d1, &8564, &8576, &857d, &8583, &858c; also used as index base 2 times by &855c, &8597
data_0085        = &85
; &85 referenced 6 times by &8487, &84cb, &84cf, &8567, &8572, &8589
data_0086        = &86
; &86 referenced 3 times by &84c9, &85b4, &85da
data_0087        = &87
; &87 referenced 1 time by &85b2
data_0088        = &88
; &88 referenced 4 times by &80b2, &80be, &80c1, &80cb
data_0089        = &89
; &89 referenced 9 times by &84af, &84c3, &84d3, &84df, &84e1, &85c4, &85dc, &85e8, &85ea
data_008a        = &8a
; &8a referenced 16 times by &84ab, &84c7, &84d7, &84d9, &8505, &8507, &850b, &8512, &8535, &85c0, &85d8, &85e0, &85e2, &862b, &8634, &863b
data_008b        = &8b
; &8b referenced 2 times by &8644, &8648
data_008c        = &8c
; &8c referenced 20 times by &8064, &8069, &806c, &807c, &809c, &80a8, &80c7, &80c9, &80d8, &80da, &84a0, &84a6, &84c5, &84d5, &84e4, &84ed, &84f5, &8500, &852a, &8532
data_008d        = &8d
; &8d referenced 10 times by &8097, &80a3, &80cd, &80cf, &849d, &84a3, &84b1, &84f7, &84fc, &852f
data_008e        = &8e
; &8e referenced 11 times by &8541, &854d, &85a2, &85bb, &85de, &85ed, &85f6, &85fe, &8620, &8628, &8640
data_008f        = &8f
; &8f referenced 8 times by &8544, &8552, &85a7, &85b6, &85c6, &8600, &8605, &8625
data_00a8        = &a8
; &a8 referenced 8 times by &8173, &8185, &818e, &81b6, &81cf, &81d1, &81d5, &8259
data_00a9        = &a9
; &a9 referenced 1 time by &8179
data_00aa        = &aa
; &aa referenced 2 times by &81df, &81f2
data_00ab        = &ab
; &ab referenced 1 time by &81da
data_00ef        = &ef
; &ef referenced 1 time by &8033
data_00f0        = &f0
; &f0 referenced 1 time by &8039
os_text_ptr      = &f2
; &f2 referenced 1 time by &8171
data_00f3        = &f3
; &f3 referenced 1 time by &8175
romsel_copy      = &f4
; &f4 referenced 4 times by &805c, &8481, &856a, &85aa
data_034e        = &034e
; &034e referenced 2 times by &84b5, &85ca
data_0df0        = &0df0
; &0df0 used as index base 4 times by &8021, &8483, &856c, &85ac
acccon           = &fe34
; &fe34 referenced 3 times by &842f, &843d, &8549
user_via_orb_irb = &fe60
; &fe60 referenced 2 times by &8a39, &8a47
osbyte           = &fff4
; &fff4 referenced 11 times by &8866, &889d, &88bb, &88df, &8907, &8918, &892c, &893d, &8a69, &8ab6, &8abf

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
    jmp service_handler
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
; &801e referenced 1 time by &8003
.service_handler
    pha
    lda #&91
    sta data_0df0,x
    pla
    jsr sub_815d
    pha
    cmp #&27
    beq code_804e
    cmp #7
    bne code_805c
    phx
    phy
    lda data_00ef
    cmp #&a3
    bne code_8048
    lda data_00f0
    cmp #&f3
    bne code_8048
    jsr sub_8148
    lda #0
    ply
    plx
    bra code_805c
; &8048 referenced 2 times by &8037, &803d
.code_8048
    lda #7
    ply
    plx
    bra code_805c
; &804e referenced 1 time by &802b
.code_804e
    stz data_900a
    stz data_900b
    stz data_9015
    stz data_9031
    bra code_805c
; &805c referenced 4 times by &802f, &8046, &804c, &805a
.code_805c
    ldx romsel_copy
    pla
    rts
    equb &ea
; &8061 referenced 1 time by &847e
.sub_8061
    lda data_901f
    sta data_008c
    lda data_901e
    lsr data_008c
    ror a
    lsr data_008c
    ror a
    sta data_901e
    lsr a
    lsr a
    lsr a
    tax
    lda data_901b
    bpl code_807c
    inx
; &807c referenced 1 time by &8079
.code_807c
    lda data_008c
    beq code_808d
    txa
    clc
    adc #&20 ; ' '
    tax
    lda data_901e
    eor #7
    sta data_901e
; &808d referenced 1 time by &807e
.code_808d
    lda data_9012
    cmp #3
    bcs code_80a0
    lda data_8c94,x
    sta data_008d
    lda data_8c72,x
    sta data_008c
    bra code_80aa
; &80a0 referenced 1 time by &8092
.code_80a0
    lda data_8cd8,x
    sta data_008d
    lda data_8cb6,x
    sta data_008c
; &80aa referenced 1 time by &809e
.code_80aa
    lda data_901b
    bpl code_80b2
    clc
    adc #5
; &80b2 referenced 1 time by &80ad
.code_80b2
    sta data_0088
    lda data_901a
    ldx data_9012
    cpx #3
    bcc code_80c1
    lsr data_0088
    ror a
; &80c1 referenced 1 time by &80bc
.code_80c1
    lsr data_0088
    ror a
    and #&f8
    clc
    adc data_008c
    sta data_008c
    lda data_0088
    adc data_008d
    sta data_008d
    lda data_901e
    and #7
    eor #7
    ora data_008c
    sta data_008c
    lda data_901a
    ldx data_9012
    cpx #3
    bcc code_80e7
    lsr a
; &80e7 referenced 1 time by &80e4
.code_80e7
    lsr a
    lsr a
    and #3
    tax
    rts
    equb &a9, &13, &20, &ee, &ff, &a9, &00, &20
    equb &ee, &ff, &ad, &36, &90, &20, &ee, &ff
    equb &a9, &00, &20, &ee, &ff, &20, &ee, &ff
    equb &20, &ee, &ff, &a9, &13, &20, &ee, &ff
    equb &a9, &01, &20, &ee, &ff, &ad, &37, &90
    equb &20, &ee, &ff, &a9, &00, &20, &ee, &ff
    equb &20, &ee, &ff, &20, &ee, &ff, &60
; &8124 referenced 1 time by &814a
.loop_8124
    lda #6
    sta data_9036
    lda #4
    sta data_9037
    rts
; &812f referenced 1 time by &814d
.loop_812f
    tya
    lsr a
    lsr a
    lsr a
    and #1
    tax
    eor #1
    tay
    lda data_9036,x
; &813c referenced 1 time by &8142
.loop_813c
    inc a
    and #7
    cmp data_9036,y
    beq loop_813c
    sta data_9036,x
    rts
; &8148 referenced 1 time by &803f
.sub_8148
    tya
    rol a
    bcs loop_8124
    rol a
    bcs loop_812f
    tya
    lsr a
    lsr a
    lsr a
    and #1
    tax
    tya
    and #7
    sta data_9036,x
    rts
; &815d referenced 1 time by &8025
.sub_815d
    cmp #&15
    bne code_8167
    jsr sub_8844
    jmp code_8a0f
; &8167 referenced 1 time by &815f
.code_8167
    cmp #4
    bne return_1
    php
    pha
    phx
    phy
    tya
    clc
    adc os_text_ptr
    sta data_00a8
    lda data_00f3
    adc #0
    sta data_00a9
    ldy #0
    jsr code_8259
    ldx #0
    sty data_9030
; &8185 referenced 2 times by &81a7, &81b0
.code_8185
    lda (data_00a8),y
    and #&df
    cmp data_81f5,x
    beq code_81ae
    lda (data_00a8),y
    cmp #&2e ; '.'
    beq code_81b2
    lda data_81f5,x
    bmi code_81b5
    ldy data_9030
; &819c referenced 1 time by &81a0
.loop_819c
    inx
    lda data_81f5,x
    bpl loop_819c
    inx
    inx
    lda data_81f5,x
    bpl code_8185
; &81a9 referenced 3 times by &81be, &88d6, &8a2a
.code_81a9
    ply
    plx
    pla
    plp
; &81ad referenced 1 time by &8169
.return_1
    rts
; &81ae referenced 1 time by &818c
.code_81ae
    inx
    iny
    bne code_8185
; &81b2 referenced 1 time by &8192
.code_81b2
    iny
    bne code_81c0
; &81b5 referenced 1 time by &8197
.code_81b5
    dex
    lda (data_00a8),y
    cmp #&20 ; ' '
    beq code_81c0
    cmp #&0d
    bne code_81a9
; &81c0 referenced 3 times by &81b3, &81ba, &81c4
.code_81c0
    inx
    lda data_81f5,x
    bpl code_81c0
    cpx #&4b ; 'K'
    beq code_81cd
    jsr code_8259
; &81cd referenced 1 time by &81c8
.code_81cd
    tya
    clc
    adc data_00a8
    sta data_00a8
    bcc code_81d7
    inc data_00a8
; &81d7 referenced 1 time by &81d3
.code_81d7
    lda data_81f5,x
    sta data_00ab
    lda data_81f6,x
    sta data_00aa
    sei
    jsr sub_8592
    jsr sub_81f2
    jsr sub_854d
    ply
    plx
    pla
    lda #0
    plp
    rts
; &81f2 referenced 1 time by &81e5
.sub_81f2
    jmp (data_00aa)
; &81f5 used as index base 6 times by &8189, &8194, &819d, &81a4, &81c1, &81d7
.data_81f5
; &81f6 used as index base 1 time by &81dc
data_81f6 = data_81f5+1
    equs "KEYS"
    equb &82, &93
    equs "DIGITAL"
    equb &82, &ac
    equs "JOYSTICK"
    equb &82, &b3
    equs "MOUSE"
    equb &82, &ba
    equs "POINTER"
    equb &83, &8c
    equs "TMAX"
    equb &8c, &0b
    equs "TRACKERBALL"
    equb &82, &ba
    equs "TSET"
    equb &8c
    equs "HSETPAL"
    equb &80, &ed, &ff, &a0, &00, &60, &c9, &30
    equb &90, &05, &c9, &3a, &b0, &01, &60, &00
    equb &dc
    equs "Bad number"
    equb &00
; &8259 referenced 3 times by &817d, &81ca, &8264
.code_8259
    lda (data_00a8),y
    cmp #&2c ; ','
    beq code_8263
    cmp #&20 ; ' '
    bne return_2
; &8263 referenced 1 time by &825d
.code_8263
    iny
    bne code_8259
; &8266 referenced 1 time by &8261
.return_2
    rts
    equb &ad, &0a, &90, &f0, &26, &08, &78, &ad
    equb &9d, &0d, &8d, &04, &02, &ad, &9e, &0d
    equb &8d, &05, &02, &ad, &97, &0d, &8d, &0a
    equb &02, &ad, &98, &0d, &8d, &0b, &02, &28
    equb &a9, &17, &20, &f4, &ff, &20, &e2, &83
    equb &9c, &0a, &90, &60, &a9, &20, &8d, &31
    equb &90, &a9, &04, &a2, &02, &a0, &00, &20
    equb &f4, &ff, &a9, &e2, &a2, &00, &a0, &00
    equb &20, &f4, &ff, &80, &11, &a9, &40, &8d
    equb &31, &90, &80, &0a, &a9, &80, &8d, &31
    equb &90, &80, &03, &9c, &31, &90, &20, &fd
    equb &89, &20, &06, &8a, &20, &40, &82, &b1
    equb &a8, &c9, &30, &f0, &9b, &ae, &0a, &90
    equb &d0, &c1, &8e, &15, &90, &8e, &0b, &90
    equb &ca, &8e, &0a, &90, &a9, &16, &20, &f4
    equb &ff, &08, &78, &a9, &ff, &8d, &08, &90
    equb &ad, &31, &90, &d0, &1c, &ad, &6c, &fe
    equb &29, &0f, &8d, &6c, &fe, &ad, &6b, &fe
    equb &29, &fc, &8d, &6b, &fe, &a9, &98, &8d
    equb &6e, &fe, &a9, &00, &8d, &62, &fe, &80
    equb &05, &a9, &18, &8d, &6e, &fe, &a9, &80
    equb &8d, &04, &90, &a9, &02, &8d, &05, &90
    equb &a9, &00, &8d, &06, &90, &a9, &02, &8d
    equb &07, &90, &a9, &a8, &a2, &00, &a0, &ff
    equb &20, &f4, &ff, &86, &a8, &84, &a9, &ad
    equb &0a, &02, &8d, &97, &0d, &ad, &0b, &02
    equb &8d, &98, &0d, &a0, &0f, &8c, &0a, &02
    equb &a2, &ff, &8e, &0b, &02, &a9, &c1, &91
    equb &a8, &a9, &87, &c8, &91, &a8, &c8, &a5
    equb &f4, &91, &a8, &ad, &04, &02, &8d, &9d
    equb &0d, &ad, &05, &02, &8d, &9e, &0d, &a9
    equb &20, &8d, &99, &0d, &a0, &06, &8c, &9a
    equb &0d, &a9, &ff, &8d, &9b, &0d, &a9, &4c
    equb &8d, &9c, &0d, &a9, &99, &8d, &04, &02
    equb &a9, &0d, &8d, &05, &02, &a9, &25, &91
    equb &a8, &c8, &a9, &88, &91, &a8, &c8, &a5
    equb &f4, &91, &a8, &28, &60, &a9, &87, &20
    equb &f4, &ff, &98, &29, &07, &c9, &03, &90
    equb &09, &c9, &03, &f0, &45, &c9, &06, &b0
    equb &41, &3a, &8d, &12, &90, &20, &40, &82
    equb &b1, &a8, &38, &e9, &30, &f0, &39, &c9
    equb &02, &f0, &30, &ad, &0a, &90, &f0, &2a
    equb &ad, &0b, &90, &d0, &25, &ad, &0a, &90
    equb &8d, &0b, &90, &85, &8f, &ad, &31, &90
    equb &d0, &04, &a9, &98, &80, &02, &a9, &18
    equb &8d, &6e, &fe, &a9, &00, &20, &5a, &86
    equb &ac, &04, &90, &88, &8c, &16, &90, &4c
    equb &0a, &84
; &83e1 referenced 1 time by &842d
.return_3
    rts
    equb &a9, &18, &8d, &6e, &fe, &ad, &0b, &90
    equb &f0, &f5, &ad, &34, &fe, &8d, &2e, &90
    equb &29, &fb, &89, &02, &f0, &02, &09, &04
    equb &8d, &34, &fe, &20, &aa, &85, &ad, &2e
    equb &90, &8d, &34, &fe, &9c, &0b, &90, &60
; &840a referenced 1 time by &8a21
.sub_840a
    lda #&0a
    sta data_9009
    lda data_9004
    cmp data_9016
    bne code_842f
    lda data_9006
    cmp data_9018
    bne code_842f
    lda data_9005
    cmp data_9017
    bne code_842f
    lda data_9007
    cmp data_9019
    beq return_3
; &842f referenced 3 times by &8415, &841d, &8425
.code_842f
    lda acccon
    sta data_902e
    and #&fb
    bit #2
    beq code_843d
    ora #4
; &843d referenced 1 time by &8439
.code_843d
    sta acccon
    lda data_9006
    sta data_9018
    lda data_9007
    sta data_9019
    lda data_9004
    sta data_9016
    lda data_9005
    sta data_9017
    ldx #0
    lda data_9004
    sec
    sbc data_8d11
    sta data_901a
    lda data_9005
    sbc #0
    sta data_901b
    lda data_8d12
    clc
    adc data_9006
    sta data_901e
    lda data_9007
    adc #0
    sta data_901f
    jsr sub_8061
    ldy romsel_copy
    lda data_0df0,y
    inc a
    sta data_0085
    lda data_8d09,x
    sta data_0084
    jsr sub_85aa
    lda data_901a
    sta data_901c
    lda data_901b
    sta data_901d
    lda data_008d
    pha
    lda data_008c
    pha
    lda data_008d
    pha
    lda data_008c
    pha
    ldx #0
    stx data_008a
; &84ad referenced 2 times by &84fe, &853b
.code_84ad
    ldy #0
    sty data_0089
    lda data_008d
    bmi code_850b
    cmp data_034e
    bcc code_8500
    lda data_901b
    bmi code_850b
    cmp #5
    bcs code_853e
; &84c3 referenced 1 time by &84e8
.loop_84c3
    ldy data_0089
    lda (data_008c),y
    ldy data_008a
    sta (data_0086),y
    inc data_0085
    and (data_0084),y
    dec data_0085
    ora (data_0084),y
    ldy data_0089
    sta (data_008c),y
    inc data_008a
    lda data_008a
    and #&0f
    beq code_8514
    inc data_0089
    lda data_0089
    clc
    adc data_008c
    and #7
    bne loop_84c3
; &84ea referenced 1 time by &8509
.code_84ea
    ldy data_9012
    lda data_008c
    and #&f8
    clc
    adc data_8cff,y
    sta data_008c
    lda data_008d
    adc data_8d04,y
    sta data_008d
    bra code_84ad
; &8500 referenced 1 time by &84b8
.code_8500
    lda data_008c
    and #7
    clc
    adc data_008a
    sta data_008a
    bra code_84ea
; &850b referenced 2 times by &84b3, &84bd
.code_850b
    lda data_008a
    and #&f0
    clc
    adc #&10
    sta data_008a
; &8514 referenced 1 time by &84dd
.code_8514
    ldy data_9012
    lda data_901a
    clc
    adc data_8cfa,y
    sta data_901a
    bcc code_8526
    inc data_901b
; &8526 referenced 1 time by &8521
.code_8526
    pla
    clc
    adc #8
    sta data_008c
    pla
    adc #0
    sta data_008d
    pha
    lda data_008c
    pha
    lda data_008a
    cmp #&40 ; '@'
    beq code_853e
    jmp code_84ad
; &853e referenced 2 times by &84c1, &8539
.code_853e
    pla
    pla
    pla
    sta data_008e
    pla
    sta data_008f
    lda data_902e
    sta acccon
    rts
; &854d referenced 3 times by &81e8, &88d3, &8a27
.sub_854d
    lda data_008e
    sta data_9020
    lda data_008f
    sta data_9021
    ldx #&0c
; &8559 referenced 1 time by &855f
.loop_8559
    lda data_9022,x
    sta data_0084,x
    dex
    bpl loop_8559
; &8561 referenced 1 time by &8592
.sub_8561
    pha
    phx
    phy
    lda data_0084
    pha
    lda data_0085
    pha
    ldx romsel_copy
    lda data_0df0,x
    clc
    adc #3
    sta data_0085
    lda #&40 ; '@'
    sta data_0084
    ldy #&2f ; '/'
; &857a referenced 1 time by &8586
.loop_857a
    ldx data_9000,y
    lda (data_0084),y
    sta data_9000,y
    txa
    sta (data_0084),y
    dey
    bpl loop_857a
    pla
    sta data_0085
    pla
    sta data_0084
    ply
    plx
    pla
    rts
; &8592 referenced 3 times by &81e2, &8849, &8a14
.sub_8592
    jsr sub_8561
    ldx #&0c
; &8597 referenced 1 time by &859d
.loop_8597
    lda data_0084,x
    sta data_9022,x
    dex
    bpl loop_8597
    lda data_9020
    sta data_008e
    lda data_9021
    sta data_008f
; &85a9 referenced 1 time by &85b8
.return_4
    rts
; &85aa referenced 1 time by &848e
.sub_85aa
    ldy romsel_copy
    lda data_0df0,y
    clc
    adc #3
    sta data_0087
    stz data_0086
    lda data_008f
    bmi return_4
    pha
    lda data_008e
    pha
    ldy #0
    sty data_008a
; &85c2 referenced 2 times by &8607, &862f
.code_85c2
    ldy #0
    sty data_0089
    lda data_008f
    bmi code_8634
    cmp data_034e
    bcc code_8640
    lda data_901d
    bmi code_8634
    cmp #5
    bcs code_8631
; &85d8 referenced 1 time by &85f1
.loop_85d8
    ldy data_008a
    lda (data_0086),y
    ldy data_0089
    sta (data_008e),y
    inc data_008a
    lda data_008a
    and #&0f
    beq code_860a
    inc data_0089
    lda data_0089
    clc
    adc data_008e
    and #7
    bne loop_85d8
; &85f3 referenced 1 time by &864b
.code_85f3
    ldy data_9012
    lda data_008e
    and #&f8
    clc
    adc data_8cff,y
    sta data_008e
    lda data_008f
    adc data_8d04,y
    sta data_008f
    jmp code_85c2
; &860a referenced 2 times by &85e6, &863d
.code_860a
    ldy data_9012
    lda data_901c
    clc
    adc data_8cfa,y
    sta data_901c
    bcc code_861c
    inc data_901d
; &861c referenced 1 time by &8617
.code_861c
    pla
    clc
    adc #8
    sta data_008e
    pla
    adc #0
    sta data_008f
    pha
    lda data_008e
    pha
    ldy data_008a
    cpy #&40 ; '@'
    bne code_85c2
; &8631 referenced 1 time by &85d6
.code_8631
    pla
    pla
    rts
; &8634 referenced 2 times by &85c8, &85d2
.code_8634
    lda data_008a
    and #&f0
    clc
    adc #&10
    sta data_008a
    jmp code_860a
; &8640 referenced 1 time by &85cd
.code_8640
    lda data_008e
    and #7
    sta data_008b
    txa
    clc
    adc data_008b
    tax
    jmp code_85f3
    equb &00, &40, &80, &c0, &00, &40, &00, &00
    equb &00, &00, &01, &01, &8d, &13, &90, &a8
    equb &ae, &12, &90, &bd, &4e, &86, &18, &69
    equb &13, &85, &84, &bd, &54, &86, &69, &8d
    equb &85, &85, &bd, &4e, &86, &18, &69, &53
    equb &85, &86, &bd, &54, &86, &69, &8e, &85
    equb &87, &a6, &f4, &bd, &f0, &0d, &1a, &85
    equb &8d, &64, &8c, &84, &8a, &a0, &00, &84
    equb &89, &a4, &8a, &b1, &84, &a4, &89, &91
    equb &8c, &a4, &8a, &b1, &86, &a4, &89, &e6
    equb &8d, &91, &8c, &c6, &8d, &e6, &8a, &e6
    equb &89, &a4, &89, &c0, &40, &d0, &e2, &64
    equb &84, &a9, &40, &85, &86, &a6, &f4, &bd
    equb &f0, &0d, &1a, &85, &85, &85, &87, &a9
    equb &00, &85, &88, &20, &d8, &86, &64, &84
    equb &a9, &40, &85, &86, &a6, &f4, &bd, &f0
    equb &0d, &18, &69, &02, &85, &85, &85, &87
    equb &c6, &88, &ad, &12, &90, &f0, &59, &c9
    equb &03, &f0, &55, &c9, &04, &f0, &07, &c9
    equb &01, &f0, &03, &4c, &73, &87, &20, &f2
    equb &86, &20, &f2, &86, &a2, &00, &a5, &88
    equb &c9, &ff, &a9, &00, &08, &85, &8a, &8a
    equb &05, &8a, &a8, &b1, &84, &28, &b0, &04
    equb &29, &ef, &90, &02, &09, &10, &24, &88
    equb &30, &01, &18, &6a, &08, &91, &86, &a5
    equb &8a, &18, &69, &10, &c9, &40, &d0, &dd
    equb &28, &e8, &e0, &10, &d0, &d0, &a5, &85
    equb &85, &87, &a5, &86, &85, &84, &18, &69
    equb &40, &85, &86, &90, &02, &e6, &87
    equs "` <"
    equb &87, &20, &3c, &87, &20, &4d, &87, &a5
    equb &85, &85, &87, &a5, &86, &85, &84, &20
    equb &4d, &87, &4c, &24, &87, &a2, &00, &a5
    equb &88, &c9, &ff, &a9, &00, &08, &85, &8a
    equb &8a, &05, &8a, &a8, &b1, &84, &28, &6a
    equb &08, &91, &86, &a5, &8a, &18, &69, &10
    equb &c9, &40, &d0, &ea, &28, &e8, &e0, &10
    equb &d0, &dd, &60, &20, &b5, &87, &20, &7c
    equb &87, &4c, &b5, &87, &a2, &00, &a5, &88
    equb &c9, &ff, &a9, &00, &08, &85, &8a, &8a
    equb &05, &8a, &a8, &b1, &84, &29, &aa, &4a
    equb &28, &90, &08, &24, &88, &10, &02, &09
    equb &aa, &09, &02, &91, &86, &b1, &84
    equs ")UJ"
    equb &08, &a5, &8a, &18, &69, &10, &c9, &40
    equb &d0, &d9, &28, &e8, &e0, &10, &d0, &cc
    equb &4c, &24, &87, &a0, &3f, &b1, &84, &91
    equb &86, &88, &10, &f9, &4c, &24, &87, &c9
    equb &80, &f0, &03, &6c, &97, &0d, &e0, &09
    equb &f0, &21, &b0, &f7, &e0, &05, &90, &f3
    equb &08
    equs "x a"
    equb &85, &8a, &0a, &69, &f6, &a8, &b9, &00
    equb &90, &aa, &c8, &b9, &00, &90, &a8, &20
    equb &61, &85, &28, &a9, &80, &b8, &60, &a0
    equb &00, &ae, &31, &90, &60, &08
    equs "x a"
    equb &85, &ae, &08, &90, &10, &10, &a2, &00
    equb &ad, &60, &fe, &29, &e0, &c9, &e0, &f0
    equb &05, &a2, &07, &8e, &08, &90, &ad, &60
    equb &fe, &e0, &00, &f0, &04
    equs "****)"
    equb &07, &49, &07, &aa, &20, &61, &85, &28
    equb &a0, &00, &f0, &c4, &08, &48, &da, &5a
    equb &ad, &6e, &fe, &29, &18, &f0, &11, &ad
    equb &6d, &fe, &29, &18, &f0, &0a, &20, &72
    equb &8b, &a8, &20, &c2, &8a, &20, &72, &8b
    equb &4c, &a9, &81
; &8844 referenced 1 time by &8161
.sub_8844
    php
    sei
    pha
    phx
    phy
    jsr sub_8592
    lda data_9031
    bne code_8854
    jmp code_88d3
; &8854 referenced 1 time by &884f
.code_8854
    bpl code_8859
    jmp code_8897
; &8859 referenced 1 time by &8854
.code_8859
    cmp #&40 ; '@'
    beq code_8860
    jmp code_88d9
; &8860 referenced 1 time by &885b
.code_8860
    lda #osbyte_read_adc_or_get_buffer_status
    ldx #0
    ldy #0
    jsr osbyte                          ; Read ADC channel X or buffer status
    txa
    and #&10
    beq code_8873
    jsr sub_894d
    bra code_887e
; &8873 referenced 1 time by &886c
.code_8873
    txa
    bpl code_887b
    jsr sub_8976
    bra code_887e
; &887b referenced 1 time by &8874
.code_887b
    jsr sub_89fd
; &887e referenced 2 times by &8871, &8879
.code_887e
    txa
    and #&40 ; '@'
    beq code_8888
    jsr sub_89ce
    bra code_8895
; &8888 referenced 1 time by &8881
.code_8888
    txa
    and #&20 ; ' '
    beq code_8892
    jsr sub_89a5
    bra code_8895
; &8892 referenced 1 time by &888b
.code_8892
    jsr sub_8a06
; &8895 referenced 2 times by &8886, &8890
.code_8895
    bra code_88d3
; &8897 referenced 1 time by &8856
.code_8897
    lda #osbyte_read_adc_or_get_buffer_status
    ldx #1
    ldy #0
    jsr osbyte                          ; Read ADC channel X or buffer status
    cpy #&c0
    bcc code_88a9
    jsr sub_894d
    bra code_88b5
; &88a9 referenced 1 time by &88a2
.code_88a9
    cpy #&40 ; '@'
    bcs code_88b2
    jsr sub_8976
    bra code_88b5
; &88b2 referenced 1 time by &88ab
.code_88b2
    jsr sub_89fd
; &88b5 referenced 2 times by &88a7, &88b0
.code_88b5
    lda #osbyte_read_adc_or_get_buffer_status
    ldx #2
    ldy #0
    jsr osbyte                          ; Read ADC channel X or buffer status
    cpy #&c0
    bcc code_88c7
    jsr sub_89ce
    bra code_88d3
; &88c7 referenced 1 time by &88c0
.code_88c7
    cpy #&40 ; '@'
    bcs code_88d0
    jsr sub_89a5
    bra code_88d3
; &88d0 referenced 1 time by &88c9
.code_88d0
    jsr sub_8a06
; &88d3 referenced 5 times by &8851, &8895, &88c5, &88ce, &894b
.code_88d3
    jsr sub_854d
    jmp code_81a9
; &88d9 referenced 1 time by &885d
.code_88d9
    lda #osbyte_inkey
    ldx #inkey_key_shift
    ldy #&ff
    jsr osbyte                          ; Test for shift key pressed
    txa                                 ; X=ASCII code typed (positive timeout) or internal key number EOR 128 (negative scan) / Y=0 if a key was pressed, Y=&FF on time-out, Y=&1B on Escape
    beq code_8901
    clc
    lda #&40 ; '@'
    adc data_9032
    sta data_9032
    bcc code_88f3
    inc data_9033
; &88f3 referenced 1 time by &88ee
.code_88f3
    clc
    lda #&40 ; '@'
    adc data_9034
    sta data_9034
    bcc code_8901
    inc data_9035
; &8901 referenced 2 times by &88e3, &88fc
.code_8901
    lda #osbyte_inkey
    ldx #inkey_key_left
    ldy #&ff
    jsr osbyte                          ; Test for left key pressed
    txa                                 ; X=ASCII code typed (positive timeout) or internal key number EOR 128 (negative scan) / Y=0 if a key was pressed, Y=&FF on time-out, Y=&1B on Escape
    beq code_8912
    jsr sub_894d
    bra code_8926
; &8912 referenced 1 time by &890b
.code_8912
    lda #osbyte_inkey
    ldx #inkey_key_right
    ldy #&ff
    jsr osbyte                          ; Test for right key pressed
    txa                                 ; X=ASCII code typed (positive timeout) or internal key number EOR 128 (negative scan) / Y=0 if a key was pressed, Y=&FF on time-out, Y=&1B on Escape
    beq code_8923
    jsr sub_8976
    bra code_8926
; &8923 referenced 1 time by &891c
.code_8923
    jsr sub_89fd
; &8926 referenced 2 times by &8910, &8921
.code_8926
    lda #osbyte_inkey
    ldx #inkey_key_up
    ldy #&ff
    jsr osbyte                          ; Test for up key pressed
    txa                                 ; X=ASCII code typed (positive timeout) or internal key number EOR 128 (negative scan) / Y=0 if a key was pressed, Y=&FF on time-out, Y=&1B on Escape
    beq code_8937
    jsr sub_89ce
    bra code_894b
; &8937 referenced 1 time by &8930
.code_8937
    lda #osbyte_inkey
    ldx #inkey_key_down
    ldy #&ff
    jsr osbyte                          ; Test for down key pressed
    txa                                 ; X=ASCII code typed (positive timeout) or internal key number EOR 128 (negative scan) / Y=0 if a key was pressed, Y=&FF on time-out, Y=&1B on Escape
    beq code_8948
    jsr sub_89a5
    bra code_894b
; &8948 referenced 1 time by &8941
.code_8948
    jsr sub_8a06
; &894b referenced 2 times by &8935, &8946
.code_894b
    bra code_88d3
; &894d referenced 3 times by &886e, &88a4, &890d
.sub_894d
    lda data_9004
    sec
    sbc data_9033
    sta data_9004
    lda data_9005
    sbc #0
    sta data_9005
    bpl code_8967
    stz data_9005
    stz data_9004
; &8967 referenced 1 time by &895f
.code_8967
    clc
    lda #&10
    adc data_9032
    sta data_9032
    bcc return_5
    inc data_9033
; &8975 referenced 1 time by &8970
.return_5
    rts
; &8976 referenced 3 times by &8876, &88ad, &891e
.sub_8976
    lda data_9004
    clc
    adc data_9033
    sta data_9004
    lda data_9005
    adc #0
    sta data_9005
    cmp #5
    bcc code_8996
    lda #4
    sta data_9005
    lda #&fc
    sta data_9004
; &8996 referenced 1 time by &898a
.code_8996
    clc
    lda #&10
    adc data_9032
    sta data_9032
    bcc return_6
    inc data_9033
; &89a4 referenced 1 time by &899f
.return_6
    rts
; &89a5 referenced 3 times by &888d, &88cb, &8943
.sub_89a5
    lda data_9006
    sec
    sbc data_9035
    sta data_9006
    lda data_9007
    sbc #0
    sta data_9007
    bpl code_89bf
    stz data_9006
    stz data_9007
; &89bf referenced 1 time by &89b7
.code_89bf
    clc
    lda #&10
    adc data_9034
    sta data_9034
    bcc return_7
    inc data_9035
; &89cd referenced 1 time by &89c8
.return_7
    rts
; &89ce referenced 3 times by &8883, &88c2, &8932
.sub_89ce
    lda data_9006
    clc
    adc data_9035
    sta data_9006
    lda data_9007
    adc #0
    sta data_9007
    cmp #4
    bcc code_89ee
    lda #3
    sta data_9007
    lda #&fc
    sta data_9006
; &89ee referenced 1 time by &89e2
.code_89ee
    clc
    lda #&10
    adc data_9034
    sta data_9034
    bcc return_8
    inc data_9035
; &89fc referenced 1 time by &89f7
.return_8
    rts
; &89fd referenced 3 times by &887b, &88b2, &8923
.sub_89fd
    stz data_9033
    lda #&80
    sta data_9032
    rts
; &8a06 referenced 3 times by &8892, &88d0, &8948
.sub_8a06
    stz data_9035
    lda #&80
    sta data_9034
    rts
; &8a0f referenced 1 time by &8164
.code_8a0f
    php
    pha
    phx
    phy
    sei
    jsr sub_8592
    lda data_900b
    beq code_8a24
    dec data_9009
    bpl code_8a24
    jsr sub_840a
; &8a24 referenced 2 times by &8a1a, &8a1f
.code_8a24
    jsr sub_8a2d
    jsr sub_854d
    jmp code_81a9
; &8a2d referenced 1 time by &8a24
.sub_8a2d
    ldx data_9031
    bne code_8a5e
    ldx data_9008
    bpl code_8a47
    ldx #0
    lda user_via_orb_irb
    and #&e0
    cmp #&e0
    beq code_8a47
    ldx #7
    stx data_9008
; &8a47 referenced 2 times by &8a35, &8a40
.code_8a47
    lda user_via_orb_irb
    and data_8b65,x
    cmp data_9015
    beq code_8a94
    cmp data_9014
    sta data_9014
    beq return_9
    sta data_9015
; &8a5d referenced 4 times by &8a58, &8a7c, &8a8a, &8a9d
.return_9
    rts
; &8a5e referenced 1 time by &8a30
.code_8a5e
    cpx #&20 ; ' '
    bne code_8a63
    rts
; &8a63 referenced 1 time by &8a60
.code_8a63
    lda #osbyte_read_adc_or_get_buffer_status
    ldx #0
    ldy #0
    jsr osbyte                          ; Read ADC channel X or buffer status
    txa
    and #3
    eor #3
    cmp data_9015
    beq code_8a82
    cmp data_9014
    sta data_9014
    beq return_9
    sta data_9015
    rts
; &8a82 referenced 1 time by &8a74
.code_8a82
    stz data_9015
    lda data_9014
    cmp #3
    beq return_9
    ldy #&0d
    and #1
    beq code_8abb
    bra code_8ab0
; &8a94 referenced 1 time by &8a50
.code_8a94
    stz data_9015
    lda data_9014
    cmp data_8b65,x
    beq return_9
    ldy #&0d
    and data_8b66,x
    beq code_8abb
    lda data_9014
    ldy #&c0
    and data_8b68,x
    beq code_8abb
; &8ab0 referenced 1 time by &8a92
.code_8ab0
    lda #osbyte_tab_char
    ldx #0
    ldy #&ff
    jsr osbyte                          ; osbyte: tab char
    txa
    tay
; &8abb referenced 3 times by &8a90, &8aa4, &8aae
.code_8abb
    lda #osbyte_insert_input_buffer
    ldx #0
    jmp osbyte                          ; Insert byte Y into input buffer X
    equb &ce, &09, &90, &ae, &08, &90, &10, &10
    equb &a2, &07, &ad, &60, &fe, &29, &18, &c9
    equb &18, &f0, &05, &a2, &00, &8e, &08, &90
    equb &98, &29, &10, &f0, &40, &ad, &60, &fe
    equb &3d, &6a, &8b, &f0, &1d, &ad, &05, &90
    equb &c9, &04, &d0, &07, &ad, &04, &90, &c9
    equb &fc, &b0, &2a, &ad, &04, &90, &69, &04
    equb &8d, &04, &90, &90, &03, &ee, &05, &90
    equb &80, &1b, &ad, &04, &90, &d0, &08, &ad
    equb &05, &90, &f0, &11, &ad, &04, &90, &38
    equb &e9, &04, &8d, &04, &90, &ad, &05, &90
    equb &e9, &00, &8d, &05, &90, &98, &29, &08
    equb &f0, &3f, &ad, &60, &fe, &3d, &69, &8b
    equb &f0, &1c, &ad, &07, &90, &c9, &03, &d0
    equb &07, &ad, &06, &90, &c9, &fc, &b0, &29
    equb &ad, &06, &90, &69, &04, &8d, &06, &90
    equb &d0, &03, &ee, &07, &90, &60, &ad, &06
    equb &90, &d0, &08, &ad, &07, &90, &f0, &11
    equb &ad, &06, &90, &38, &e9, &04, &8d, &06
    equb &90, &ad, &07, &90, &e9, &00, &8d, &07
    equb &90, &60, &18
; &8b65 used as index base 2 times by &8a4a, &8a9a
.data_8b65
    equb &07
; &8b66 used as index base 1 time by &8aa1
.data_8b66
    equb &01, &02
; &8b68 used as index base 1 time by &8aab
.data_8b68
    equb &04, &10, &08, &05, &e0, &20, &40, &80
    equb &04, &01, &48, &a5, &84, &48, &a5, &85
    equb &48, &a6, &f4, &bd, &f0, &0d, &18, &69
    equb &03, &85, &85, &a9, &40, &85, &84, &a0
    equb &09, &be, &00, &90, &b1, &84, &99, &00
    equb &90, &8a, &91, &84, &88, &10, &f2, &68
    equb &85, &85, &68, &85, &84, &68, &60, &a9
    equb &00, &8d, &0c, &90, &8d, &0d, &90, &38
    equb &08, &b1, &a8, &c9, &20, &f0, &5a, &c9
    equb &2c, &f0, &56, &c9, &0d, &f0
    equs "R C"
    equb &82, &ad, &0c, &90, &8d, &0e, &90, &ad
    equb &0d, &90, &8d, &0f, &90, &ad, &0c, &90
    equb &0a, &2e, &0d, &90, &b0, &37, &0a, &2e
    equb &0d, &90, &b0, &31, &6d, &0e, &90, &8d
    equb &0c, &90, &ad, &0d, &90, &6d, &0f, &90
    equb &b0, &23, &8d, &0d, &90, &0e, &0c, &90
    equb &2e, &0d, &90, &b0, &18, &b1, &a8, &29
    equb &0f, &18, &6d, &0c, &90, &8d, &0c, &90
    equb &90, &05, &ee, &0d, &90, &f0, &06, &28
    equb &18, &08, &c8, &d0, &a3, &28, &38, &08
    equs "(` @"
    equb &82, &20, &9f, &8b, &b0, &32, &ad, &0c
    equb &90, &48, &ad, &0d, &90
    equs "H Y"
    equb &82, &20, &9f, &8b, &b0, &20, &a0, &02
    equb &20, &32, &8c, &68, &8d, &0d, &90, &68
    equb &8d, &0c, &90, &a0, &00, &ad, &0c, &90
    equb &08, &78, &99, &00, &90, &ad, &0d, &90
    equb &c8, &99, &00, &90
    equs "(`hhLL"
    equb &82, &20, &40, &82, &20, &9f, &8b, &b0
    equb &f5, &ad, &0c, &90, &48, &ad, &0d, &90
    equs "H Y"
    equb &82, &20, &9f, &8b, &b0, &e3, &a0, &06
    equb &20, &32, &8c, &68, &8d, &0d, &90, &68
    equb &8d, &0c, &90, &a0, &04, &4c, &32, &8c
; &8c72 used as index base 1 time by &8099
.data_8c72
    equb &80, &00, &80, &00, &80, &00, &80, &00
    equb &80, &00, &80, &00, &80, &00, &80, &00
    equb &80, &00, &80, &00, &80, &00, &80, &00
    equb &80, &00, &80, &00, &80, &00, &80, &00
    equb &80, &00
; &8c94 used as index base 1 time by &8094
.data_8c94
    equs "}{xvsqnligdb_]ZXUSPNKIFDA?<:7520-+"
; &8cb6 used as index base 1 time by &80a5
.data_8cb6
    equb &c0, &80, &40, &00, &c0, &80, &40, &00
    equb &c0, &80, &40, &00, &c0, &80, &40, &00
    equb &c0, &80, &40, &00, &c0, &80, &40, &00
    equb &c0, &80, &40, &00, &c0, &80, &40, &00
    equb &c0, &80
; &8cd8 used as index base 1 time by &80a0
.data_8cd8
    equs "~}|{yxwvtsrqonmljihgedcb`_^][ZYXVU"
; &8cfa used as index base 2 times by &851b, &8611
.data_8cfa
    equb &10, &10, &10, &20, &20
; &8cff used as index base 2 times by &84f2, &85fb
.data_8cff
    equb &80, &80, &80, &40, &40
; &8d04 used as index base 2 times by &84f9, &8602
.data_8d04
    equb &02, &02, &02, &01, &01
; &8d09 used as index base 1 time by &8489
.data_8d09
    equb &00, &40, &80, &c0, &00, &40, &80, &c0
; &8d11 referenced 1 time by &845e
.data_8d11
    equb &04
; &8d12 referenced 1 time by &846c
.data_8d12
    equb &04, &00
    equs "0<?????3"
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &c0, &f0, &fc, &c0, &c0
    equb &f0, &f0, &3c, &3c, &0f, &0f, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &04, &06, &07, &07, &07, &07, &07, &05
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &08, &0c, &0e, &08, &08
    equb &0c, &0c, &06, &06, &03, &03, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &01, &01, &01, &01, &01, &01, &01, &01
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &02, &02, &03, &03, &02, &02
    equb &01, &01, &01, &01, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &02, &02, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &70, &7c, &7f, &7f, &7f, &7f, &7f, &73
    equb &40, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &c0, &f0, &fc, &c0, &c0
    equb &f0, &f0, &3c, &3c, &0f, &0f, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &08
    equb &0c, &0e, &0f, &0f, &0f, &0f, &0f, &0d
    equb &08, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &08, &0c, &0e, &08, &08
    equb &0c, &0c, &06, &06, &03, &03, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &0f
    equb &03, &00, &00, &00, &00, &00, &00, &00
    equb &00, &fc, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &3f, &0f, &03, &00, &03, &0f
    equb &03, &03, &00, &00, &c0, &c0, &f0, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &3f, &3f, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &33
    equb &11, &00, &00, &00, &00, &00, &00, &00
    equb &00, &ee, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &77, &33, &11, &00, &11, &33
    equb &11, &11, &00, &00, &88, &88, &cc, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &77, &77, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &55, &55, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &aa, &aa, &ff, &ff
    equb &ff, &ff, &ff, &ff, &55, &55, &ff, &ff
    equs "UUUU"
    equb &00, &00, &55, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &0f, &03, &00, &00, &00
    equb &00, &00, &00, &00, &00, &fc, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &3f, &0f
    equb &03, &00, &03, &0f, &03, &03, &00, &00
    equb &c0, &c0, &f0, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &3f, &3f, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &33, &11, &00, &00, &00
    equb &00, &00, &00, &00, &00, &ee, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &77, &33
    equb &11, &00, &11, &33, &11, &11, &00, &00
    equb &88, &88, &cc, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &77, &77, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff, &ff, &ff, &ff, &ff, &ff
    equb &ff, &ff, &ff
    equs "JPG,PMF"
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00
; &9000 used as index base 2 times by &857a, &857f
.data_9000
    equb &00, &00, &00, &00
; &9004 referenced 9 times by &840f, &844c, &845a, &894d, &8954, &8964, &8976, &897d, &8993
.data_9004
    equb &00
; &9005 referenced 9 times by &841f, &8452, &8464, &8957, &895c, &8961, &8980, &8985, &898e
.data_9005
    equb &00
; &9006 referenced 9 times by &8417, &8440, &8470, &89a5, &89ac, &89b9, &89ce, &89d5, &89eb
.data_9006
    equb &00
; &9007 referenced 9 times by &8427, &8446, &8476, &89af, &89b4, &89bc, &89d8, &89dd, &89e6
.data_9007
    equb &00
; &9008 referenced 2 times by &8a32, &8a44
.data_9008
    equb &00
; &9009 referenced 2 times by &840c, &8a1c
.data_9009
    equb &00
; &900a referenced 1 time by &804e
.data_900a
    equb &00
; &900b referenced 2 times by &8051, &8a17
.data_900b
    equb &00, &00, &00, &00, &00, &00, &00
; &9012 referenced 7 times by &808d, &80b7, &80df, &84ea, &8514, &85f3, &860a
.data_9012
    equb &00, &00
; &9014 referenced 7 times by &8a52, &8a55, &8a76, &8a79, &8a85, &8a97, &8aa6
.data_9014
    equb &00
; &9015 referenced 7 times by &8054, &8a4d, &8a5a, &8a71, &8a7e, &8a82, &8a94
.data_9015
    equb &00
; &9016 referenced 2 times by &8412, &844f
.data_9016
    equb &00
; &9017 referenced 2 times by &8422, &8455
.data_9017
    equb &00
; &9018 referenced 2 times by &841a, &8443
.data_9018
    equb &00
; &9019 referenced 2 times by &842a, &8449
.data_9019
    equb &00
; &901a referenced 6 times by &80b4, &80dc, &8461, &8491, &8517, &851e
.data_901a
    equb &00
; &901b referenced 6 times by &8076, &80aa, &8469, &8497, &84ba, &8523
.data_901b
    equb &00
; &901c referenced 3 times by &8494, &860d, &8614
.data_901c
    equb &00
; &901d referenced 3 times by &849a, &85cf, &8619
.data_901d
    equb &00
; &901e referenced 6 times by &8066, &806f, &8085, &808a, &80d1, &8473
.data_901e
    equb &00
; &901f referenced 2 times by &8061, &847b
.data_901f
    equb &00
; &9020 referenced 2 times by &854f, &859f
.data_9020
    equb &00
; &9021 referenced 2 times by &8554, &85a4
.data_9021
    equb &00
; &9022 used as index base 2 times by &8559, &8599
.data_9022
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00
; &902e referenced 2 times by &8432, &8546
.data_902e
    equb &00, &00
; &9030 referenced 2 times by &8182, &8199
.data_9030
    equb &00
; &9031 referenced 3 times by &8057, &884c, &8a2d
.data_9031
    equb &00
; &9032 referenced 7 times by &88e8, &88eb, &896a, &896d, &8999, &899c, &8a02
.data_9032
    equb &00
; &9033 referenced 6 times by &88f0, &8951, &8972, &897a, &89a1, &89fd
.data_9033
    equb &00
; &9034 referenced 7 times by &88f6, &88f9, &89c2, &89c5, &89f1, &89f4, &8a0b
.data_9034
    equb &00
; &9035 referenced 6 times by &88fe, &89a9, &89ca, &89d2, &89f9, &8a06
.data_9035
    equb &00
; &9036 referenced 1 time by &8126; also used as index base 4 times by &8139, &813f, &8144, &8159
.data_9036
    equb &00
; &9037 referenced 1 time by &812b
.data_9037
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00, &00, &00, &00, &00, &00, &00, &00
    equb &00
.dasmos_end

save dasmos_start, dasmos_end

; Label references by decreasing frequency:
;     data_008c:         20
;     data_008a:         16
;     data_008e:         11
;     osbyte:            11
;     data_0084:         10
;     data_008d:         10
;     data_0089:          9
;     data_9004:          9
;     data_9005:          9
;     data_9006:          9
;     data_9007:          9
;     data_008f:          8
;     data_00a8:          8
;     data_9012:          7
;     data_9014:          7
;     data_9015:          7
;     data_9032:          7
;     data_9034:          7
;     data_0085:          6
;     data_81f5:          6
;     data_901a:          6
;     data_901b:          6
;     data_901e:          6
;     data_9033:          6
;     data_9035:          6
;     code_88d3:          5
;     data_9036:          5
;     code_805c:          4
;     data_0088:          4
;     data_0df0:          4
;     return_9:           4
;     romsel_copy:        4
;     acccon:             3
;     code_81a9:          3
;     code_81c0:          3
;     code_8259:          3
;     code_842f:          3
;     code_8abb:          3
;     data_0086:          3
;     data_901c:          3
;     data_901d:          3
;     data_9031:          3
;     sub_854d:           3
;     sub_8592:           3
;     sub_894d:           3
;     sub_8976:           3
;     sub_89a5:           3
;     sub_89ce:           3
;     sub_89fd:           3
;     sub_8a06:           3
;     code_8048:          2
;     code_8185:          2
;     code_84ad:          2
;     code_850b:          2
;     code_853e:          2
;     code_85c2:          2
;     code_860a:          2
;     code_8634:          2
;     code_887e:          2
;     code_8895:          2
;     code_88b5:          2
;     code_8901:          2
;     code_8926:          2
;     code_894b:          2
;     code_8a24:          2
;     code_8a47:          2
;     data_008b:          2
;     data_00aa:          2
;     data_034e:          2
;     data_8b65:          2
;     data_8cfa:          2
;     data_8cff:          2
;     data_8d04:          2
;     data_9000:          2
;     data_9008:          2
;     data_9009:          2
;     data_900b:          2
;     data_9016:          2
;     data_9017:          2
;     data_9018:          2
;     data_9019:          2
;     data_901f:          2
;     data_9020:          2
;     data_9021:          2
;     data_9022:          2
;     data_902e:          2
;     data_9030:          2
;     user_via_orb_irb:   2
;     code_804e:          1
;     code_807c:          1
;     code_808d:          1
;     code_80a0:          1
;     code_80aa:          1
;     code_80b2:          1
;     code_80c1:          1
;     code_80e7:          1
;     code_8167:          1
;     code_81ae:          1
;     code_81b2:          1
;     code_81b5:          1
;     code_81cd:          1
;     code_81d7:          1
;     code_8263:          1
;     code_843d:          1
;     code_84ea:          1
;     code_8500:          1
;     code_8514:          1
;     code_8526:          1
;     code_85f3:          1
;     code_861c:          1
;     code_8631:          1
;     code_8640:          1
;     code_8854:          1
;     code_8859:          1
;     code_8860:          1
;     code_8873:          1
;     code_887b:          1
;     code_8888:          1
;     code_8892:          1
;     code_8897:          1
;     code_88a9:          1
;     code_88b2:          1
;     code_88c7:          1
;     code_88d0:          1
;     code_88d9:          1
;     code_88f3:          1
;     code_8912:          1
;     code_8923:          1
;     code_8937:          1
;     code_8948:          1
;     code_8967:          1
;     code_8996:          1
;     code_89bf:          1
;     code_89ee:          1
;     code_8a0f:          1
;     code_8a5e:          1
;     code_8a63:          1
;     code_8a82:          1
;     code_8a94:          1
;     code_8ab0:          1
;     data_0087:          1
;     data_00a9:          1
;     data_00ab:          1
;     data_00ef:          1
;     data_00f0:          1
;     data_00f3:          1
;     data_81f6:          1
;     data_8b66:          1
;     data_8b68:          1
;     data_8c72:          1
;     data_8c94:          1
;     data_8cb6:          1
;     data_8cd8:          1
;     data_8d09:          1
;     data_8d11:          1
;     data_8d12:          1
;     data_900a:          1
;     data_9037:          1
;     loop_8124:          1
;     loop_812f:          1
;     loop_813c:          1
;     loop_819c:          1
;     loop_84c3:          1
;     loop_8559:          1
;     loop_857a:          1
;     loop_8597:          1
;     loop_85d8:          1
;     os_text_ptr:        1
;     return_1:           1
;     return_2:           1
;     return_3:           1
;     return_4:           1
;     return_5:           1
;     return_6:           1
;     return_7:           1
;     return_8:           1
;     service_handler:    1
;     sub_8061:           1
;     sub_8148:           1
;     sub_815d:           1
;     sub_81f2:           1
;     sub_840a:           1
;     sub_8561:           1
;     sub_85aa:           1
;     sub_8844:           1
;     sub_8a2d:           1

; Automatically generated labels:
;     code_8048
;     code_804e
;     code_805c
;     code_807c
;     code_808d
;     code_80a0
;     code_80aa
;     code_80b2
;     code_80c1
;     code_80e7
;     code_8167
;     code_8185
;     code_81a9
;     code_81ae
;     code_81b2
;     code_81b5
;     code_81c0
;     code_81cd
;     code_81d7
;     code_8259
;     code_8263
;     code_842f
;     code_843d
;     code_84ad
;     code_84ea
;     code_8500
;     code_850b
;     code_8514
;     code_8526
;     code_853e
;     code_85c2
;     code_85f3
;     code_860a
;     code_861c
;     code_8631
;     code_8634
;     code_8640
;     code_8854
;     code_8859
;     code_8860
;     code_8873
;     code_887b
;     code_887e
;     code_8888
;     code_8892
;     code_8895
;     code_8897
;     code_88a9
;     code_88b2
;     code_88b5
;     code_88c7
;     code_88d0
;     code_88d3
;     code_88d9
;     code_88f3
;     code_8901
;     code_8912
;     code_8923
;     code_8926
;     code_8937
;     code_8948
;     code_894b
;     code_8967
;     code_8996
;     code_89bf
;     code_89ee
;     code_8a0f
;     code_8a24
;     code_8a47
;     code_8a5e
;     code_8a63
;     code_8a82
;     code_8a94
;     code_8ab0
;     code_8abb
;     data_0084
;     data_0085
;     data_0086
;     data_0087
;     data_0088
;     data_0089
;     data_008a
;     data_008b
;     data_008c
;     data_008d
;     data_008e
;     data_008f
;     data_00a8
;     data_00a9
;     data_00aa
;     data_00ab
;     data_00ef
;     data_00f0
;     data_00f3
;     data_034e
;     data_0df0
;     data_81f5
;     data_81f6
;     data_8b65
;     data_8b66
;     data_8b68
;     data_8c72
;     data_8c94
;     data_8cb6
;     data_8cd8
;     data_8cfa
;     data_8cff
;     data_8d04
;     data_8d09
;     data_8d11
;     data_8d12
;     data_9000
;     data_9004
;     data_9005
;     data_9006
;     data_9007
;     data_9008
;     data_9009
;     data_900a
;     data_900b
;     data_9012
;     data_9014
;     data_9015
;     data_9016
;     data_9017
;     data_9018
;     data_9019
;     data_901a
;     data_901b
;     data_901c
;     data_901d
;     data_901e
;     data_901f
;     data_9020
;     data_9021
;     data_9022
;     data_902e
;     data_9030
;     data_9031
;     data_9032
;     data_9033
;     data_9034
;     data_9035
;     data_9036
;     data_9037
;     loop_8124
;     loop_812f
;     loop_813c
;     loop_819c
;     loop_84c3
;     loop_8559
;     loop_857a
;     loop_8597
;     loop_85d8
;     return_1
;     return_2
;     return_3
;     return_4
;     return_5
;     return_6
;     return_7
;     return_8
;     return_9
;     sub_8061
;     sub_8148
;     sub_815d
;     sub_81f2
;     sub_840a
;     sub_854d
;     sub_8561
;     sub_8592
;     sub_85aa
;     sub_8844
;     sub_894d
;     sub_8976
;     sub_89a5
;     sub_89ce
;     sub_89fd
;     sub_8a06
;     sub_8a2d

; Stats:
;     Total size (Code + Data) = 8192 bytes
;     Code                     = 1651 bytes (20%)
;     Data                     = 6541 bytes (80%)
;
;     Number of instructions   = 795
;     Number of data bytes     = 6333 bytes
;     Number of data words     = 0 bytes
;     Number of string bytes   = 208 bytes
;     Number of strings        = 28
