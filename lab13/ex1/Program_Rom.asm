#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;
count1		equ h'20'
count2		equ h'21'
count3		equ h'22'
;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
		
	
start		movlw 	.0
			movwf	PORTB
			call	delay
			movlw 	.0
			movwf	PORTB
			call	delay
			movlw 	.8
			movwf	PORTB
			call	delay
			movlw 	.8
			movwf	PORTB
			call	delay
			movlw 	.1
			movwf	PORTB
			call	delay
			movlw 	.0
			movwf	PORTB
			call	delay
			movlw 	.4
			movwf	PORTB
			call	delay
			movlw 	.1
			movwf	PORTB
			goto	$

delay		movlw	.30
			movwf	count1
delay1		clrf	count2
delay2		clrf	count3
delay3		decfsz	count3,1
			bra		delay3	
			decfsz	count2,1
			bra		delay2	
			decfsz	count1,1
			bra		delay1
			return	
			end	