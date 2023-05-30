;* Este programa recibe un carácter por el puerto serie asíncrono USART
;* y lo regresa tal cual por el mismo puerto, hasta recibir un <esc>
;* Fosc=4 Mhz
;************************************************************************
 __CONFIG    _CONFIG1, (_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF)
 

processor PIC16F886
#include P16F886.inc
apun EQU 0x20
dato EQU 0x21

org 0x0000
GOTO 0X05
org 0X0005

trans BSF STATUS,RP0	 ;banco 1
BSF TXSTA,BRGH 			;pone bit BRGH=1
MOVLW 0x19				;valor para 9600 Bauds (Fosc=4 Mhz)
MOVWF SPBRG 			;configura 9600 Bauds
CLRF SPBRGH			;
BCF TXSTA,SYNC 			;limpia bit SYNC (modo asíncrono)
BSF TXSTA,TXEN 			;pone bit TXEN=1 (habilita transmisión)
BSF STATUS,RP1			;escribe cero en el bot BRG16
BCF BAUDCTL,BRG16
BCF STATUS,RP0 			;regresa al banco 0
BCF STATUS,RP1
BSF RCSTA,SPEN 			;pone bit SPEN=1 (habilita puerto serie)
BSF RCSTA,CREN 			;Habilita recepción
rep CALL recibe			 ;recibe dato
MOVLW 0x1B				 ;carga código ASCII de <escape>
SUBWF dato,W			 ;es igual?
BTFSC STATUS,Z				 ;
GOTO fin 				;si es igual termina
CALL envia				 ;si n, retransmite el dato
GOTO rep ;repite
fin GOTO fin ;ciclo infinito

;*************************************************
;Subrutina para enviar un dato por el puerto serie
;*************************************************
envia BSF STATUS,RP0 ;banco 1
esp BTFSS TXSTA,TRMT ;checa si el buffer de transmisión
GOTO esp ;si está ocupado espera
BCF STATUS,RP0 ;regresa al banco 0
MOVF dato,W ;rescata dato a enviar
MOVWF TXREG ;lo envía
RETURN

;**************************************************
;subrutina de recepción de un dato del puerto serie
;**************************************************
recibe BTFSS PIR1,RCIF ;checa el buffer de recepción
GOTO recibe ;si no hay dato listo espera
MOVF RCREG,W ;si hay dato, lo lee
MOVWF dato ;lo almacena en dato
RETURN

end