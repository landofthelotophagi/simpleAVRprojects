; First project
; Παστάκας Γιώργος 7507
; Φουντουκίδης Ιάσων Ιωάννης 7549
; Ομάδα 30 

.CSEG
.org 0x0000

.def ZH=R31
.def ZL=R30
	
/*** PART_2 ***/

	RJMP RESET

RESET:
	LDI R18, 0x00
	OUT 0x11, R18 ; Port D (SWITCHES) becomes an input port [0x11 is equivalent to DDRD]
	LDI R18, 0xFF
	OUT 0x17, R18 ; Port B (LEDS) becomes an output port [0x17 is equivalent to DDRB]

	CLT

AEMs_COMP:
	LDI ZL, LOW(2*AEMs_table)
	LDI ZH, HIGH(2*AEMs_table)

COMP:	
	LPM R16, Z
	SUBI ZL, -4
	LPM R17, Z
	SUBI ZL, 3
	CP R16, R17
	BRLO PART_1_3 ; If First_AEM<Second_AEM the programme moves on to the 3rd part of the exercise
	BREQ COMP ; If the present digits of AEMs are equal we load the next two digits and compare them
	
	SET ; If T=1 then First_AEM>Second_AEM, else if T=0 then First_AEM<Second_AEM
PART_1_3:
	LDI R18, 0xFF
	OUT 0x18, R18 ; we turn off all the LEDS in output

	BRTS First_AEM_Greater
Second_AEM_Greater:
	LDI ZL, LOW((2*AEMs_table)+7)
	LDI ZH, HIGH((2*AEMs_table)+7)
	LPM R17, Z
	SUBI ZL, 4
	LPM R16, Z	
	RJMP ODD_OR_EVEN
First_AEM_Greater:
	LDI ZL, LOW((2*AEMs_table)+3)
	LDI ZH, HIGH((2*AEMs_table)+3)
	LPM R17, Z
	SUBI ZL, -4
	LPM R16, Z
	RJMP ODD_OR_EVEN

ODD_OR_EVEN:
	LDI R21, 0xFF
	SBRC R17, 0
	SUBI R21, 2
	SBRC R16, 0
	SUBI R21, 1

	LDI R16, 0xFF
	OUT 0x10, R16

LOOP:
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
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
	IN R16, 0x10 ; [0x10 is equivalent to PIND]
	CPI R16, 0xFF ; none of the SWITCHES is pressed
	BREQ LOOP 
	
LOOP2:
	IN R18, 0x10
	CPI R18, 0xFF
	BRNE LOOP2

SWITCH_PRESSED:
	CPI R16, 0xFE
	BREQ SW0_PRESSED
	CPI R16, 0xFD
	BREQ SW1_PRESSED
	CPI R16, 0xFB
	BREQ SW2_PRESSED
	CPI R16, 0xF7
	BREQ SW3_PRESSED
	CPI R16, 0x7F
	BREQ SW7_PRESSED

SW7_PRESSED:
	OUT 0x18, R21
	
	RJMP FAR_END

SW0_PRESSED:
	BRTS First_AEM_bigger_SW0
Second_AEM_bigger_SW0:
	LDI ZL, LOW((2*AEMs_table)+4)
	LDI ZH, HIGH((2*AEMs_table)+4)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END
First_AEM_bigger_SW0:
	LDI ZL, LOW(2*AEMs_Table)
	LDI ZH, HIGH(2*AEMs_Table)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END

SW1_PRESSED:
	BRTS First_AEM_bigger_SW1
Second_AEM_bigger_SW1:
	LDI ZL, LOW((2*AEMs_table)+6)
	LDI ZH, HIGH((2*AEMs_table)+6)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END
First_AEM_bigger_SW1:
	LDI ZL, LOW((2*AEMs_table)+2)
	LDI ZH, HIGH((2*AEMs_table)+2)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END

SW2_PRESSED:
	BRTC First_AEM_smaller_SW2
Second_AEM_smaller_SW2:
	LDI ZL, LOW((2*AEMs_table)+4)
	LDI ZH, HIGH((2*AEMs_table)+4)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END
First_AEM_smaller_SW2:
	LDI ZL, LOW(2*AEMs_Table)
	LDI ZH, HIGH(2*AEMs_Table)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END
	
SW3_PRESSED:
	BRTC First_AEM_smaller_SW3
Second_AEM_smaller_SW3:
	LDI ZL, LOW((2*AEMs_table)+6)
	LDI ZH, HIGH((2*AEMs_table)+6)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END
First_AEM_smaller_SW3:
	LDI ZL, LOW((2*AEMs_table)+2)
	LDI ZH, HIGH((2*AEMs_table)+2)
	LPM R19, Z+
	SUBI R19, 0x30
	SWAP R19
	LPM R20, Z
	SUBI R20, 0x30
	ADD R19, R20
	RJMP END



END:
	COM R19
	OUT 0x18, R19

; delay subroutine

.def inner_count_L=R24 
.def inner_count_H=R25
.def outer_count_L=R26 ; (XL)
.def outer_count_H=R27 ; (XH)
;----------
TIME_DEL_A:
	ldi outer_count_L, 0x8E	; 1 cycle
	ldi outer_count_H, 0x08	; 1 cycle
outer_loop:
	ldi inner_count_L, 0x8E	; 1 cycle
	ldi inner_count_H, 0x08	; 1 cycle
inner_loop:
	nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	sbiw inner_count_L, 1	; 2 cycles
	brne inner_loop		; 2 cycles if true (Ni-1 times), 1 cycle if false
	sbiw outer_count_L, 1	; 2 cycles
	brne outer_loop 		; 2 cycles if true (No-1 times), 1 cycle if false
	ret				; 4 cycles (plus 3 cycles for rcall)
;----- End of subroutine TIME_DEL_A -----
.undef inner_count_L
.undef inner_count_H
.undef outer_count_L
.undef outer_count_H

; end of delay subroutine

	LDI R21, 0xFF
	OUT 0x18, R21
	.UNDEF ZH
	.UNDEF ZL
	RJMP FAR_END

	
FAR_END:
	RJMP FAR_END

AEMs_table:	
	.DB 0x37, 0x35, 0x30, 0x37 ; First_AEM (7507)
	.DB 0x37, 0x35, 0x34, 0x39 ; Second_AEM (7549)

