; Second Project
; Dimitris Ropoutis 8233
; Evripidis Baltzis 8196
; Group 3 Team 6

.include "m16def.inc"

.CSEG
.def reg=R0
.def temp=R16
.def data=R17
.def delay=R18
.def counter=R19
.def counter2=R20
.def tempage1=R21
.def DELAY2=R22
.def inner_count_L=R24 
.def inner_count_H=R25
.def OUTer_count_L=R26 ; (XL)
.def OUTer_count_H=R27 ; (XH)


table: .db $75,$67,$05,$07,$19,$90, $75,$71,$01,$07,$19,$90, 0x61,0x64,0x72,0x6F,0x7A,0x69,0x73,0x67,0x69,0x61,0x6F,0x6F,0x69,0x73
	   .db 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
	   .db 0x63,0x68,0x72,0x69,0x73,0x7A,0x6F,0x73,0x6D,0x6F,0x75,0x72,0x6F,0x75,0x7A,0x69
	   .db 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0



RESET:
        LDI temp,LOW(RAMEND)
    	OUT SPL,temp
	LDI temp,HIGH(RAMEND)
	OUT SPH,temp
	SER temp
	OUT DDRB,temp
	OUT PORTB,temp
	CLR temp
	OUT DDRB,temp
	
SWITCH_CHECK:
	SBIC PIND,0x00
	RJMP DELAY
	SBIC PIND,0x01
	RJMP DELAY
	SBIC PIND,0x02
	RJMP DELAY
	SBIC PIND,0x03
	RJMP DELAY
	RJMP SWITCH_CHECK
	
DELAY:
	DEC delay
	CLR DELAY
	DEC DELAY2
	CLR DELAY
	RJMP START

START:
	LDI ZH,HIGH(table)
	LDI ZL,LOW(table)
	LSL ZH;
	ROL ZL;
	MOV R23, zl
	LDI counter,0
    	LDI counter2,1 

	
MAIN:     
	LPM data,z+
	OUT PORTB, data
	;RCALL TIME_DELAY_3s
	SER temp
    	OUT PORTB, temp
	;RCALL TIME_DELAY_2s
	RJMP SWITCH_WAIT

CONTINUE: 
	ADD counter, counter2
	CPI counter, 12

	BREQ SWITCH5_CHECK	
	RJMP MAIN

SWITCH5_CHECK:

	SBIC PIND,0x05
	RJMP DLY3
	RJMP check_sw5

DELAY3:
	DEC delay
	CLR DELAY3
	DEC DELAY2
	CLR DELAY3
	RJMP AGE_CHECK

AGE_CHECK:
    	MOV zl,r23
    	ADIW zl, 5
	LPM
	MOV tempage1,reg
	ADIW zl,6
	LPM
	CPSE tempage1,reg
	BRSH LIGHT1
	BRLO LIGHT0


MONTH_CHECK:
   	MOV zl,r23
   	ADIW zl, 3
	LPM
	MOV tempage1,reg
	ADIW zl, 6
	LPM
	CPSE tempage1,reg
	BRSH LIGHT1
	BRLO LIGHT0

    
DAY_CHECK:
   	MOV zl,r23
    	ADIW zl, 2
	LPM
	MOV tempage1,reg
	ADIW zl,6
	LPM
	CP tempage1,reg
	BRSH LIGHT1
	BRLO LIGHT0

LIGHT0:
	ldi temp,0b11111110
	OUT PORTB,temp
	RJMP END

LIGHT1:
	ldi temp,0b11111101
	OUT PORTB,temp
	RJMP END



	
END:
	SBIC PIND,0x06
	RJMP DELAY4
	RJMP END

DELAY4:
    	CLR temp
	OUT PORTB, temp
	DEC delay
	CLR DELAY4
	DEC DELAY2
	CLR DELAY4
	RJMP exit



TIME_DELAY_3s:
	          ldi outer_count_L, $0D	; 1 cycle
	          ldi outer_count_H, $06	; 1 cycle
              outer_loop:
		  ldi inner_count_L, $0D	; 1 cycle
	          ldi inner_count_H, $06	; 1 cycle
              inner_loop:
	          nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	          sbiw inner_count_L, 1		; 2 cycles
	          clr inner_loop		; 2 cycles if true (Ni-1 times), 1 cycle if false
	          sbiw outer_count_L, 1		; 2 cycles
              	  clr outer_loop 		; 2 cycles if true (No-1 times), 1 cycle if false
	          ret		

TIME_DELAY_2s:
	          ldi outer_count_L, $F1	; 1 cycle
	          ldi outer_count_H, $04	; 1 cycle
              outer_loop2:
		  ldi inner_count_L, $F1	; 1 cycle
	          ldi inner_count_H, $04	; 1 cycle
              inner_loop2:
	          nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	          sbiw inner_count_L, 1	; 2 cycles
	          clr inner_loop2		; 2 cycles if true (Ni-1 times), 1 cycle if false
	          sbiw OUTer_count_L, 1		; 2 cycles
                  clr outer_loop2 		; 2 cycles if true (No-1 times), 1 cycle if false
	          ret				; 4 cycles (plus 3 cycles for RCALL)
	
TIME_DELAY_1s:
	          ldi outer_count_L, $FE	; 1 cycle
	          ldi outer_count_H, $03	; 1 cycle
              outer_loop3:
		  ldi inner_count_L, $FE	; 1 cycle
	          ldi inner_count_H, $03	; 1 cycle
              inner_loop3:		
	          nop				; 1 cycle, possible use of more "nop" instructions for longer delays
	          sbiw inner_count_L, 1		; 2 cycles
	          clr inner_loop3		; 2 cycles if true (Ni-1 times), 1 cycle if false
	          sbiw outer_count_L, 1		; 2 cycles
              	  clr outer_loop3 		; 2 cycles if true (No-1 times), 1 cycle if false
	          ret				; 4 cycles (c   s 3 cycl
SWITCH_WAIT:
	CLR temp
    	OUT PORTB, temp
	RCALL TIME_DELAY_1s
	SER temp
    	OUT PORTB, temp
	RCALL TIME_DELAY_1s
	SBIC PIND,0x00
	RJMP DLY2
	SBIC PIND,0x01
	RJMP DLY2
	SBIC PIND,0x02
	RJMP DLY2
	SBIC PIND,0x03
	RJMP DLY2
	RJMP SWITCH_WAIT
	
DLY2:
	DEC delay
	CLR DELAY2
	DEC DELAY2
	CLR DELAY2
	RJMP CONTINUE

EXIT:
	RJMP EXIT

