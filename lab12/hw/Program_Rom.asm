#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;
temp		equ	0x22
temph		equ 0x21
temp1		equ 0x23
temp2		equ 0x24
temp3		equ 0x25
temp4		equ 0x26
temp5		equ 0x27
;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
		
	
start		movlw 	.3
			movwf	temp1
			movwf	temp5
			clrf	temp
			clrf	temph
			clrw
loop1		movlw 	.4
			decfsz	temp1,1
			movlw 	.10
			movwf	temp2
loop2				movlw 	.6
					movwf	temp3
loop3						movlw 	.9
							movwf	temp4
loop4								movlw	1
									addwf	temp,1
									movf	temp,0
									decfsz	temp4,1
									bra 	loop4
							decfsz	temp3,0
							call	carry_on
							decfsz	temp3,1
							bra 	loop3
					clrf	temp
					decfsz	temp2,0
				    incf	temph
					decfsz	temp2,1
					bra 	loop2
			decfsz	temp5,0
			call	carry_on_h
			decfsz	temp5,1
			bra 	loop1
			bra 	start

carry_on	movlw	.7
			addwf	temp,1
			movf	temp,0
			return
carry_on_h	movlw	.7
			addwf	temph,1
			movf	temph,0
			return
			end	