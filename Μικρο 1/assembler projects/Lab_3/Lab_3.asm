; Third project
; Παστάκας Γιώργος 7507
; Φουντουκίδης Ιάσων Ιωάννης 7549
; Ομάδα 30 

.include "m16def.inc"

	RJMP RESET
.CSEG
.DEF YL=R28
.DEF YH=R29
.DEF MASK=R21
.DEF COUNTER=R22

RESET: 
	LDI R18, LOW(RAMEND)   ; Stack pointer points at the end of SRAM
	OUT SPL, R18
	LDI R18, HIGH(RAMEND)
	OUT SPH, R18
	
	LDI R18, 0x00
	OUT 0x11, R18  ; Port D (SWITCHES) becomes an input port [0x11 is equivalent to DDRD]
	LDI R18, 0xFF
	OUT 0x17, R18  ; Port B (LEDS) becomes an output port [0x17 is equivalent to DDRB]
	OUT 0x10, R18
	LDI R18, 0x7E
	OUT 0x18, R18

	LDI R20, 0xFF

LOOP:
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP 
	IN R16, 0x10
	CPI R16, 0xFE ; SWITCH_0 is pressed
	BREQ LOOP
	IN R16, 0x10
	CPI R16, 0xFD ; SWITCH_1 is pressed
	BREQ LOOP
	IN R16, 0x10
	CPI R16, 0xFB ; SWITCH_2 is pressed
	BREQ LOOP2
	IN R16, 0x10
	CPI R16, 0xF7 ; SWITCH_3 is pressed
	BREQ LOOP2 
	IN R16, 0x10
	CPI R16, 0xEF ; SWITCH_4 is pressed
	BREQ LOOP2 
	IN R16, 0x10
	CPI R16, 0xDF ; SWITCH_5 is pressed
	BREQ LOOP2
	IN R16, 0x10
	CPI R16, 0xBF ; SWITCH_6 is pressed
	BREQ LOOP2 
	IN R16, 0x10
	CPI R16, 0x7F ; SWITCH_7 is pressed
	BREQ LOOP
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP 
	
LOOP2:
	IN R18, 0x10
	CPI R18, 0xFF
	BRNE LOOP2

	SBRS R16, 2
	AND R20, R16
	SBRS R16, 3
	AND R20, R16
	SBRS R16, 4
	AND R20, R16
	SBRS R16, 5
	AND R20, R16
	SBRS R16, 6
	RJMP CONT_1
	RJMP LOOP


CONT_1:
	SBRC R20, 2
	RJMP CONT_1_1
	LDI R18, 0x78
	OUT 0x18, R18
	LDI COUNTER, 0x04
CONT_1_0:
	RCALL DELAY_1sec
	DEC COUNTER
	BRNE CONT_1_0

CONT_1_1:
	LDI MASK, 0x18
	AND MASK, R20
	CPI MASK, 0x00
	BREQ SECS8
	CPI MASK, 0x08
	BREQ SECS12
	CPI MASK, 0x10
	BREQ SECS24
	CPI MASK, 0x18
	BREQ SECS30
SECS8:	
		LDI COUNTER, 0x08
		RJMP CONT_2
SECS12:
		LDI COUNTER, 0x0C
		RJMP CONT_2
SECS24:
		LDI COUNTER, 0x18
		RJMP CONT_2
SECS30:
		LDI COUNTER, 0x1E
		RJMP CONT_2
CONT_2:
	LDI R18, 0x74
	OUT 0x18, R18
	RCALL DELAY_1sec
	DEC COUNTER
	BRNE CONT_2
	LDI R18, 0x6C
	OUT 0x18, R18
	RCALL DELAY_1sec

	SBRC R20, 5
	RJMP CONT_3
	LDI R18, 0x5C
	OUT 0x18, R18
	LDI COUNTER, 0x02
CONT_3_0:
	RCALL DELAY_1sec
	DEC COUNTER
	BRNE CONT_3_0

CONT_3:
	LDI R18, 0x7E
	OUT 0x18, R18

	RJMP FAR_END



DOOR_OPEN:
	LDI R19, 0x7E
	OUT 0x18, R19
	RCALL DELAY_1sec_2
	IN R16, 0x10
	SBRS R16, 0 
	RJMP LOOP3
	LDI R19, 0x7F
	OUT 0x18, R19
	RCALL DELAY_1sec_2
	IN R16, 0x10
	SBRS R16, 0 
	RJMP LOOP3
	RJMP DOOR_OPEN

OVERLOAD:
	LDI R19, 0x7C
	OUT 0x18, R19
	RCALL DELAY_1sec_2
	IN R16, 0x10
	SBRS R16, 1 
	RJMP LOOP3
	LDI R19, 0x7E
	OUT 0x18, R19
	RCALL DELAY_1sec_2
	IN R16, 0x10
	SBRS R16, 1 
	RJMP LOOP3
	RJMP OVERLOAD

NO_WATER:
	LDI R19, 0x3C
	OUT 0x18, R19
	RCALL DELAY_1sec_2
	IN R16, 0x10
	SBRS R16, 7 
	RJMP LOOP3
	LDI R19, 0x3E
	OUT 0x18, R19
	RCALL DELAY_1sec_2
	IN R16, 0x10
	SBRS R16, 7 
	RJMP LOOP3
	RJMP NO_WATER

LOOP3:
	IN R18, 0x10
	CPI R18, 0xFF
	BRNE LOOP3
	OUT 0x18, R18
	RET



DELAY_1sec:
.def inner_count_L=R24 
.def inner_count_H=R25
.def outer_count_L=R26 ; (XL)
.def outer_count_H=R27 ; (XH)
;----------
	ldi outer_count_L, 0x7E ;1 cycle
	ldi outer_count_H, 0x03; 1 cycle
outer_loop:
	ldi inner_count_L, 0x7E ;1 cycle
	ldi inner_count_H, 0x03; 1 cycle
	IN R16, 0x10
	SBRS R16, 0
	RCALL DOOR_OPEN
	IN R16, 0x10
	SBRS R16, 1
	RCALL OVERLOAD
	IN R16, 0x10
	SBRS R16, 7
	RCALL NO_WATER
inner_loop:
	nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	sbiw inner_count_L, 1	; 2 cycles
	brne inner_loop		; 2 cycles if true (Ni-1 times), 1 cycle if false
	sbiw outer_count_L, 1	; 2 cycles
	brne outer_loop 		; 2 cycles if true (No-1 times), 1 cycle if false
;----- End of subroutine DELAY_1sec -----
.undef inner_count_L
.undef inner_count_H
.undef outer_count_L
.undef outer_count_H
	RET
; end of delay subroutine


DELAY_1sec_2:
.def inner_count_L=R24 
.def inner_count_H=R25
.def outer_count_L=R26 ; (XL)
.def outer_count_H=R27 ; (XH)
;----------
	ldi outer_count_L, 0x7E ;1 cycle
	ldi outer_count_H, 0x03; 1 cycle
outer_loop2:
	ldi inner_count_L, 0x7E ;1 cycle
	ldi inner_count_H, 0x03; 1 cycle
inner_loop2:
	nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	sbiw inner_count_L, 1	; 2 cycles
	brne inner_loop2		; 2 cycles if true (Ni-1 times), 1 cycle if false
	sbiw outer_count_L, 1	; 2 cycles
	brne outer_loop2 		; 2 cycles if true (No-1 times), 1 cycle if false
;----- End of subroutine DELAY_1sec -----
.undef inner_count_L
.undef inner_count_H
.undef outer_count_L
.undef outer_count_H
	RET
; end of delay subroutine

FAR_END:
	RJMP FAR_END
