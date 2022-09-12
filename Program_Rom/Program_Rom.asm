#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;
a		equ 0x25
c		equ 0x24
temp	equ 0x23
temp2	equ 0x22
;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
			
start		movlw	.21
			movwf	a
			movlw	.36
			movwf	c
			call	euclidean
			movf	a,0
			movwf	PORTB

			movlw	.21
			movwf	a
			movlw	.35
			movwf	c
			call	euclidean
			movf	a,0
			movwf	PORTB

			movlw	.16
			movwf	a
			movlw	.28
			movwf	c
			call	euclidean
			movf	a,0		
			movwf	PORTB


			movlw	.14
			movwf	a
			movlw	.42
			movwf	c
			call	euclidean
			movf	a,0
			movwf	PORTB

			movlw	.7
			movwf	a
			movlw	.29
			movwf	c
			call	euclidean
			movf	a,0
			movwf	PORTB
			goto	$

euclidean	call 	mod
			movf	c,0
			movwf	a
			movf	temp,0
			movwf	c
			movwf	temp2
			decf	temp2
			btfss	temp2,7	
			bra		euclidean
			return

mod			movf	c,0
			subwf	a,1
			btfss	a,7
			bra		mod	
			movf	a,0
			addwf	c,0
			movwf	temp
			return
			end