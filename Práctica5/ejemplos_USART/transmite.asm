;* Este programa envía repetidamente una cadena de caracteres a través
;* del puerto serie asíncrono USART, La cadena utiliza como terminador
;* un carácter "$". El oscilador del sistema es de Fosc=4 Mhz
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
rep CLRF apun 			;inicializa apuntador
cic2 CALL letrero 		;obtiene el siguiente carácter apuntado
MOVWF dato 				;lo guarda en dato
SUBLW "$" 				;Compara con el signo "$"
BTFSC STATUS,Z 			;
GOTO rep 				;si es, reinicia
CALL envia 				;si no es "$" envía el dato
INCF apun,1				;apunta al siguiente carácter
GOTO cic2 				;repite
;*************************************************
;Subrutina para enviar un dato por el puerto serie
;*************************************************
envia BSF STATUS,RP0 	;banco 1
esp BTFSS TXSTA,TRMT 	;checa si el buffer de transmisión
GOTO esp 				;si está ocupado espera
BCF STATUS,RP0 			;regresa al banco 0
MOVF dato,W 			;rescata dato a enviar
MOVWF TXREG 			;lo envía
RETURN
letrero:
MOVF apun,W				 ;carga apuntador en W
ADDWF PCL,1 			;Salta W instrucciones adelante
DT "HOLA GRUPO 03",0x0D,0x0A,"$"
end