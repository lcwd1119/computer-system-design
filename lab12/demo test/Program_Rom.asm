#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;
temp		equ	0x25
temp1		equ 0x24
temp2		equ 0x23
count1		equ h'20'
count2		equ h'21'
count3		equ h'22'
;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
			
start		movlw 	.6
			movwf	temp1
			clrf	temp
			clrw
			movwf	PORTB
			call	delay

loop1		movlw 	.9
			movwf	temp2

loop2		movlw	1
			addwf	temp,1
			movf	temp,0
			movwf	PORTB
			call 	delay
			decfsz	temp2,1
			bra		loop2 	
			
			
			decfsz	temp1,0
			call	carry_on
			decfsz	temp1,1
			bra 	loop1
			bra 	start

carry_on	movlw	.7
			addwf	temp,1
			movf	temp,0
			movwf	PORTB
			call	delay
			return
	

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