; Second project
; Παστάκας Γιώργος 7507
; Φουντουκίδης Ιάσων Ιωάννης 7549
; Ομάδα 30 

.include "m16def.inc"

	RJMP RESET
.CSEG
.DEF YL=R28
.DEF YH=R29

RESET: 
	LDI R18, LOW(RAMEND)   ; Stack pointer points at the end of SRAM
	OUT SPL, R18
	LDI R18, HIGH(RAMEND)
	OUT SPH, R18
	LDI R18, 0x00
	OUT 0x11, R18 ; Port D (SWITCHES) becomes an input port [0x11 is equivalent to DDRD]
	LDI R18, 0xFF
	OUT 0x17, R18 ; Port B (LEDS) becomes an output port [0x17 is equivalent to DDRB]	
	LDI R18, 0xFF
	OUT 0x18, R18
	CLR R0
	CLR R1
	CLR R2
	CLR R3
	CLR R4

	LDI YL, 0x00
	LDI YH, 0x01
	LDI R16, 0x07 ; Insert both AEMs (BCD coded) in SRAM [SRAM begins from address 0x0100] 
	ST Y+, R16
	LDI R16, 0x05
	ST Y+, R16
	LDI R16, 0x00
	ST Y+, R16
	LDI R16, 0x07
	ST Y+, R16
	LDI R16, 0x07
	ST Y+, R16
	LDI R16, 0x05
	ST Y+, R16
	LDI R16, 0x04
	ST Y+, R16
	LDI R16, 0x09
	ST Y, R16
	
	CLR R15        ; R15 is used to keep the carry

	CALL ADD_AEMs
	MOV R4, R16
	CALL ADD_AEMs
	MOV R3, R16
	CALL ADD_AEMs
	MOV R2, R16
	CALL ADD_AEMs
	MOV R1, R16	
	MOV R0, R15
	RJMP Cont2

ADD_AEMs:
	LD R16, Y
	SUBI YL, 4
	LD R17, Y
	ADD R16, R17
	ADD R16, R15
	SBRC R15, 0
	DEC R15
	CPI R16, 0x0A
	BRLO Cont
	SUBI R16, 0x0A
	INC R15
	
Cont:
	SUBI YL, -3
	RET

Cont2:
	LDI YL, 0x08
	LDI YH, 0x01
	ST Y+, R0
	ST Y+, R1
	ST Y+, R2
	ST Y+, R3
	ST Y, R4

/** PART 2 **/

	LDI R21, 0xFF
	OUT 0x10, R21

LOOP:
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP 
	IN R16, 0x10
	CPI R16, 0xFE ; SWITCH_0 is pressed
	BREQ LOOP
	IN R16, 0x10
	CPI R16, 0xFB ; SWITCH_2 is pressed
	BREQ LOOP
	IN R16, 0x10
	CPI R16, 0xF7 ; SWITCH_3 is pressed
	BREQ LOOP
	IN R16, 0x10
	CPI R16, 0xEF ; SWITCH_4 is pressed
	BREQ LOOP 
	IN R16, 0x10
	CPI R16, 0xDF ; SWITCH_5 is pressed
	BREQ LOOP 
	IN R16, 0x10
	CPI R16, 0xBF ; SWITCH_6 is pressed
	BREQ LOOP 
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

SWITCH1_PRESSED:
	LDI YL, 0x04
	LDI R22, 4
Display_next_digit1:
	LD R20, -Y
	SWAP R20
	COM R20
	OUT 0x18, R20
	RCALL TIME_DEL_A
	DEC R22
	BRNE Display_next_digit1
	LDI R18, 0xFF
	OUT 0x18, R18
	
LOOP3:
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP3 
	IN R16, 0x10
	CPI R16, 0xFE ; SWITCH_0 is pressed
	BREQ LOOP3
	IN R16, 0x10
	CPI R16, 0xFD ; SWITCH_1 is pressed
	BREQ LOOP3
	IN R16, 0x10
	CPI R16, 0xF7 ; SWITCH_3 is pressed
	BREQ LOOP3
	IN R16, 0x10
	CPI R16, 0xEF ; SWITCH_4 is pressed
	BREQ LOOP3 
	IN R16, 0x10
	CPI R16, 0xDF ; SWITCH_5 is pressed
	BREQ LOOP3 
	IN R16, 0x10
	CPI R16, 0xBF ; SWITCH_6 is pressed
	BREQ LOOP3 
	IN R16, 0x10
	CPI R16, 0x7F ; SWITCH_7 is pressed
	BREQ LOOP3
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP3 
	
LOOP4:
	IN R18, 0x10
	CPI R18, 0xFF
	BRNE LOOP4

SWITCH2_PRESSED:
	LDI YL, 0x08
	LDI R22, 4
Display_next_digit2:
	LD R20, -Y
	SWAP R20
	COM R20
	OUT 0x18, R20
	RCALL TIME_DEL_A
	DEC R22
	BRNE Display_next_digit2

	LDI R18, 0xFF
	OUT 0x18, R18
	LDI R22, 5
	LDI YL, 0x0D

LOOP5:
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP5

	IN R16, 0x10 
	CPI R16, 0xF7 ; SWITCH_3 is pressed
	BREQ LOOP6

	IN R16, 0x10
	CPI R16, 0xFE ; SWITCH_0 is pressed
	BREQ LOOP5
	IN R16, 0x10
	CPI R16, 0xFD ; SWITCH_1 is pressed
	BREQ LOOP5
	IN R16, 0x10
	CPI R16, 0xFB ; SWITCH_2 is pressed
	BREQ LOOP5
	IN R16, 0x10
	CPI R16, 0xEF ; SWITCH_4 is pressed
	BREQ LOOP5 
	IN R16, 0x10
	CPI R16, 0xDF ; SWITCH_5 is pressed
	BREQ LOOP5 
	IN R16, 0x10
	CPI R16, 0xBF ; SWITCH_6 is pressed
	BREQ LOOP5 
	IN R16, 0x10
	CPI R16, 0x7F ; SWITCH_7 is pressed
	BREQ LOOP5
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP5
	
LOOP6:
	IN R18, 0x10
	CPI R18, 0xFF
	BRNE LOOP6

SWITCH3_PRESSED:
	LD R20, -Y
	SWAP R20
	COM R20
	OUT 0x18, R20
	RCALL TIME_DEL_B
	DEC R22
	BRNE LOOP5
	
	RJMP FAR_END

; delay subroutine

TIME_DEL_A:
.def inner_count_L=R24 
.def inner_count_H=R25
.def outer_count_L=R26 ; (XL)
.def outer_count_H=R27 ; (XH)
;----------
	ldi outer_count_L, 0xFC ;1 cycle
	ldi outer_count_H, 0x06; 1 cycle
outer_loop:
	ldi inner_count_L, 0xFC ;1 cycle
	ldi inner_count_H, 0x06; 1 cycle
inner_loop:
	nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	sbiw inner_count_L, 1	; 2 cycles
	brne inner_loop		; 2 cycles if true (Ni-1 times), 1 cycle if false
	sbiw outer_count_L, 1	; 2 cycles
	brne outer_loop 		; 2 cycles if true (No-1 times), 1 cycle if false
;----- End of subroutine TIME_DEL_A -----
.undef inner_count_L
.undef inner_count_H
.undef outer_count_L
.undef outer_count_H
	RET
; end of delay subroutine

; delay subroutine

TIME_DEL_B:
.def inner_count_L=R24 
.def inner_count_H=R25
.def outer_count_L=R26 ; (XL)
.def outer_count_H=R27 ; (XH)
;----------
	ldi outer_count_L, 0xAC ;1 cycle
	ldi outer_count_H, 0x00; 1 cycle
outer_loop_b:
	ldi inner_count_L, 0xAC ;1 cycle
	ldi inner_count_H, 0x00; 1 cycle
inner_loop_b:
	nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	sbiw inner_count_L, 1	; 2 cycles
	brne inner_loop_b	; 2 cycles if true (Ni-1 times), 1 cycle if false
	sbiw outer_count_L, 1	; 2 cycles
	brne outer_loop_b	; 2 cycles if true (No-1 times), 1 cycle if false
;----- End of subroutine TIME_DEL_A -----
.undef inner_count_L
.undef inner_count_H
.undef outer_count_L
.undef outer_count_H
	RET
; end of delay subroutine

FAR_END:
	RJMP FAR_END
	
