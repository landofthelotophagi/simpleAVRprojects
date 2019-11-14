.include "8515def.inc"

.def Password = R17
.def PassFirstByte = R18
.def PassSecByte = R19
.def PassThirdByte = R20
.def PassFourthByte = R21
.def Counter = R22
.def BreakLoop = R23
.def FirstInputReg = R25 	;if FirstInput==0 tote exoume first input,else exoume second input

.cseg
.org 0x0000
rjmp RESET

IsrFirstAndSec:
ldi r16,0b00000001
cpi r16,Counter;
breq FirstInterrupt
ldi r16,0b00000010
cpi r16,Counter;
breq SecInterrupt
ldi r16,0b00000100
cpi r16,Counter;
breq ThirdInterrupt
ldi r16,0b00001000
cpi r16,Counter;
breq FourthInterrupt

FirstInterrupt:
in PassFirstByte,PINA
com PassFirstByte
rjmp ContinueFromHere


SecondInterrupt:
in PassSecByte,PINA
com PassSecByte
rjmp ContinueFromHere


ThirdInterrupt:
in PassThirdByte,PINA
com PassThirdByte
rjmp ContinueFromHere


FourthInterrupt:
in PassFourthByte,PINA
com PassFourthByte
ldi BreakLoop,0b00000001
rjmp ContinueFromHere


ContinueFromHere:
inc Counter
ret


IsrThird:
ldi R16,0b00000010
in R17,PINA
or R16,R17
com R16
out PORTB,R16
cpi R17,0x0000
breq resetNormalMode
rjmp IsrTend
resetNormalMode:
ldi BreakLoop,0x00FF
IsrTend:
ret

ISR:
;critical section - PAY ATTETION
;isr are about to happen 3 times : one for the first pass input (FirstInputReg==0x000)
;and another one for the second input (FirstInputReg==0x00FF)  
;and another one (third) when we enter the NormalMode (FirstInputReg==0x00000011) 
;the first two interrupts are being handled by the subroutine IsrFirstAndSec
ldi R16,0x0000
cpi R16,FirstInputReg
breq FirstOrSec					;if equal then we have a first time isr
rjmp thirdIsr					;else we have a third time isr

firstOrSec:
rcall IsrFirstAndSec
rjmp IsrEnd

thirdIsr:
rcall IsrThird

IsrEnd:
reti



NormalMode:
sei
ldi BreakLoop,0x0000
LoopNormal:
cpi BreakLoop,0x0000
brne ExitNormalMode
rjmp LoopNormal				;loop forever, or until an interrupt is occured
ExitNormalMode:
ret




PasswordReadingMode:
cpi FirstInputReg,0x0000
breq First
;since you got here,that means that the first pass input was wrong
;we need a delay and an interrupt halding before we procced to SecondInput
rcall SecondInput
rjmp End
First:
rcall FirstInput
End:
ret


SecondInput:
ldi FirstInputReg,0x0000	;that was 0x00FF so function PasswordReadingMode would call
;SecondInput instead of First, but know we change it again to 0x0000 so ISR will call FirstAndSecIsr
;but not the ThirdIsr
;first of all we need a counter to know if that interrupt is being occured for 1st or 2nd, or 3rd ... time
ldi Counter,0b00000001		;counter==1 for first
							;counter will be increased before we return from ISR
ldi BreakLoop,0x0000
;in order to get the code when PinA is changed ,we must
;enable interrupts for PINA

ldi r16,(1<<PINA)
out girg,r16		
;job is done, now if pina changes an interrupt is occured
;and the function ISR is called
						
; delay for ever and wait for user input while led0 goes on and off
ldi R16,0b00000001
sei							;enable global interrupts
DelayForEver:
	;turn on and off the LED-0
	com R16
	out PORTB, R16	
    ldi  r26, 21
    ldi  r27, 75
    ldi  r28, 191
LF: cpi BreakLoop,0x0000
	brne SecCodeInsert
	dec  r28
    brne LF
    dec  r27
    brne LF
    dec  r26
    brne LF
	rjmp DelayForEver
SecCodeInsert:					;since you got here an interrupt was occured and the pass has been entered
cli								;check if the two passwords match
or PassFirstByte,PassSecByte
or PassFirstByte,PassThirdByte
or PassFirstByte,PassFourthByte	;PassFirstByte has now the code that was inserted
cpi Password,PassFirstByte		;compare the passwords
breq SecCodeAccepted			;if equal rjmp to SecCodeAccepted
rjmp SecCodeNotAccepted

SecCodeAccepted:
ldi FirstInputReg,0x00FF		;different value than 0x0000 so the isr function, knows where we are
rcall NormalMode
rjmp END_OF_FUNCTION

SecCodeNotAccepted:
ldi FirstInputReg,0x00FF		;different value than 0x0000 so the isr function, knows where we are
ldi R16,0x0000
LoopForever:
	com R16
	out PORTB, R16	
    ldi  r19, 21
    ldi  r20, 75
    ldi  r21, 191
LS: cpi BreakLoop,0x0000
	brne END_OF_SECInput
	dec  r21
    brne LS
    dec  r20
    brne LS
    dec  r19
    brne LS			;1sec loop
rjmp LoopForever	;anabosbhnoun ola ta led ana 1 sec


END_OF_SECInput:
ret




FirstInput:
;first of all we need a counter to know if that interrupt is being occured for 1st or 2nd, or 3rd ... time
ldi Counter,0b00000001		;counter==1 for first
							;counter will be increased before we return from ISR
ldi BreakLoop,0x0000
;in order to get the code when PinA is changed ,we must
;enable interrupts for PINA
ldi r16,(1<<PINA)
out girg,r16		
;job is done, now if pina changes an interrupt is occured
;and the function ISR is called
sei								;enable global interrupts
DelayForFiveSec:
    ldi  r24, 51
    ldi  r27, 118
    ldi  r26, 194
L1: cpi BreakLoop,0x0000		;takes 1 cpu clock cycle	
	brne CodeInserted			;takes 1 cycle if false
	dec  r26					;takes 1 cpu cycle
    brne L1						;takes 1 if false (and 2 if true)
    dec  r27
    brne L1
    dec  r24
    brne L1						;wait for 5(and bit more) seconds or untill an interrupt occurs
cli
rjmp CodeNotInserted

CodeInserted:
cli								;since you are here the code musth have been inserted, check if right
or PassFirstByte,PassSecByte
or PassFirstByte,PassThirdByte
or PassFirstByte,PassFourthByte	;PassFirstByte has now the code that was inserted
cpi Password,PassFirstByte		;compare the passwords
breq CodeAccepted				;if equal rjmp to CodeAccepted
rjmp CodeNotAccepted			;if not rjmp to CodeNotAccepted

CodeAccepted:
rcall NormalMode
rjmp END_OF_FUNCTION

CodeNotAccepted:				;first input was wrong ,user has to input code again			
ldi FirstInputReg,0x00FF		;now FirstInputReg same as 0x0000 
rcall PasswordReadingMode
rjmp END_OF_FUNCTION

CodeNotInserted:				;since you are here the code hasn't been inserted
ldi FirstInputReg,0x0000		;now FirstInputReg is different than 0x0000 
rcall PasswordReadingMode
rjmp END_OF_FUNCTION


END_OF_FUNCTION:
ret


RESET: 
	ldi	R16, low(RAMEND)
	out	SPL, R16
	ldi	R16, high(RAMEND)
	out	SPH, R16 			;we have now initiallized the stack pointer

	ldi R16, 0x0000    
	out DDRA, R16			;PORTA INPUT MODE
	ldi R16, 0b11111111		;1->OFF | 0-> ON
	out DDRB, R16
	out PORTB, R16			;ALL LEDS OFF

	cli
LoopUntilSw7IsPressed:		;saves the passwords and waits until sw7 is pressed
	in R16, PINA			
	com R16
	mov Password, R16
	andi R16, 0b1000000
	cpi R16, 0b0000000
	breq LoopUntilSw7IsPressed

LoopUntilSw0IsPressed:		;wait until sw0 is pressed
	in R16,PINA
	com R16
	andi R16, 0b0000001
	cpi R16, 0b0000000
	brne ZeroPressed
	rjmp LoopUntilSw0IsPressed

ZeroPressed:
	ldi FirstInputReg,0x0000
	rcall PasswordReadingMode
	rjmp ZeroPressed
