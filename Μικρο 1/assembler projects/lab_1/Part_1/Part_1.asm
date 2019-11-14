; First project
; Παστάκας Γιώργος 7507
; Φουντουκίδης Ιάσων Ιωάννης 7549
; Ομάδα 30 

.CSEG
.org 0x0000

.def ZH=R31
.def ZL=R30
	
/*** PART_1 ***/

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
	
	; If First_AEM>Second_AEM the appropriate LEDS turn on 
	; thereafter, we form the number that consists of the last two digits of the First_AEM
	LDI ZL, LOW((2*AEMs_table)+2)
	LDI ZH, HIGH((2*AEMs_table)+2)
	LPM R16, Z+ ; we load to R16 the 3rd digit of First_AEM from PM
	SUBI R16, 0x30
	SWAP R16
	LPM R17, Z ; we load to R17 the 4th digit of First_AEM from PM
	SUBI R17, 0x30
	ADD R16, R17 
	COM R16
	OUT 0x18, R16 ; We copy the 3rd and 4th digits of First_AEM (if it's greater than Second_AEM) to Port B (LEDS)
	; [0x18 is equivalent to PORTB]
	SET ; If T=1 then First_AEM>Second_AEM, else if T=0 then First_AEM<Second_AEM

; delay subroutine

.def inner_count_L=R24 
.def inner_count_H=R25
.def outer_count_L=R26 ; (XL)
.def outer_count_H=R27 ; (XH)
;----------
TIME_DEL_A1:
	ldi outer_count_L, 0x8E	; 1 cycle
	ldi outer_count_H, 0x08	; 1 cycle
outer_loop1:
	ldi inner_count_L, 0x8E	; 1 cycle
	ldi inner_count_H, 0x08	; 1 cycle
inner_loop1:
	nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	sbiw inner_count_L, 1	; 2 cycles
	brne inner_loop1		; 2 cycles if true (Ni-1 times), 1 cycle if false
	sbiw outer_count_L, 1	; 2 cycles
	brne outer_loop1 		; 2 cycles if true (No-1 times), 1 cycle if false
	ret				; 4 cycles (plus 3 cycles for rcall)
;----- End of subroutine TIME_DEL_A -----
.undef inner_count_L
.undef inner_count_H
.undef outer_count_L
.undef outer_count_H

; end of delay subroutine

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
	SBRC R17, 0
	CBI 0x18, 1 ; we clear bit 1 of POTRTB if the greater AEM is odd
	SBRC R16, 0
	CBI 0x18, 0 ; we clear bit 0 of POTRTB if the smaller AEM is odd

	.UNDEF ZH
	.UNDEF ZL

FAR_END:
	RJMP FAR_END

AEMs_table:	
	.DB 0x37, 0x35, 0x30, 0x37 ; First_AEM (7507)
	.DB 0x37, 0x35, 0x34, 0x39 ; Second_AEM (7549)
