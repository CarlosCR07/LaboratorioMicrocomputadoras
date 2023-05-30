processor PIC16f877A ; procesador
org 0x00			 ; vector de reset
Goto 0x05			 ; envia PC a la direccion 0x05
org 0x05			 ; origen del programa

#include <P16F877A.inc>

INDICE EQU 0X20 ; declaracion del Indice
DATO EQU 0X21   ; declaracion del auxiliar DATO
DATO_R EQU 0X22  ; declaracion del segundo auxiliar

BSF STATUS,RP0 ;Cambio de banco
BCF STATUS,RP1 ;Cambio de banco
BCF TRISC,RC6  ; Configramos RC6 como salida
BSF TXSTA,TXEN ; se habilita a transmision
BCF TXSTA,SYNC ;se desactiva la sincronizacion de la transmision
BCF TXSTA,BRGH ;se desactiva la alta velocidad de transmision

MOVLW .31 ; movemos el 31 decimal a w
MOVWF SPBRG ; movemos el valor de w al registro SPBRG

BCF STATUS,RP0 ; cambio al banco 0
BSF RCSTA,SPEN ;Habilitamos el puerto serial
BSF RCSTA,SREN ;Habilitamos la recepcion continua
BSF RCSTA,CREN ;Habilitamos la recepcion continua

INICIA ; Bandera INICIO
	CLRF INDICE ; Limpiamos el registro INDICE
REPITE ; Bandera REPITE
	CALL RECIBE ; Llamamos a la rutina RECIBE
	MOVWF DATO_R ; moemos el valor de w al auxiliar
	XORLW '1' ; Realizamos un XOR de W con 1
	BTFSS STATUS,Z ; verificamos si se encendio la bandera Z
	GOTO DOS? ; si no se encendio llamamos a la rutina DOS?
	CALL UNO ; si se encendio brinacmos a la rutina UNO
	GOTO INICIA ; Regresamos a INICIA

DOS? ; Bandera de DOS?
	MOVF DATO_R,W ; movemos el valor del auxiliar a W
	XORLW '0' ; realizamos un XOR de W con 0
	BTFSS STATUS,Z ; Verificamos si la bandera Z se encendio
	GOTO OTRO ; si no se encendio brinacmos a la rutina de error
	CALL DOS ; si si se encendio nos movemos a la rutina DOS
	GOTO INICIA ; Regresamos a INICIA


UNO ; Bandera UNO
	CLRF INDICE ; Limpiamos el registro INDICE
REGRESA ; Bandera REGRESA
	BSF PORTB, 0 ; Endcendemos el LED del PORTB
	MOVF INDICE,W ; Movemos el valor del auxiliar INDICE a W
	CALL TABLA2 ; Llamamos a la rutina que contiene el mensaje 
	MOVWF DATO ; Movemos a W el valor de DATO
	XORLW '$' ; Verificamos si se llego al caracter de escape
	BTFSC STATUS,Z ; Checamos si la bandera Z esta apagada
	RETURN ; Regresamos
	MOVF DATO,W ; Movemos el valor de DATO a W
	CALL ENVIA ; Llamamos a la rutina para enviar los datos
	INCF INDICE ;Incrementamos el valor de INDICE
	GOTO REGRESA; Saltamos a REGRESA

DOS ; Bandera DOS
	CLRF INDICE ; Limpiamos el registro INDICE
REGRESA_DOS ; Bandera REFRESA_DOS
	BCF PORTB, 0 ; Apagamos el LED del PORTB
	MOVF INDICE,W ; Movemos el valor del auxiliar INDICE a W
	CALL TABLA1 ;Llamamos a la rutina que contiene el mensaje adecuado
	MOVWF DATO ; Movemos a W el valor de DATO
	XORLW '$' ; Verificamos si se llego al caracter de escape
	BTFSC STATUS,Z ; Verificamos si la bandera Z esta apagada
	RETURN ; Regresamos
	MOVF DATO,W ; Movemos el valor de DATO a W
	CALL ENVIA ; Llamamos a la rutina para enviar los datos
	INCF INDICE ;Incrementamos el valor de INDICE
	GOTO REGRESA_DOS; Saltamos a REGRESA_DOS	
	
OTRO; Bandera de OTRO
	CLRF INDICE ; Limpiamos el registro INDICE
REGRESA_OTRO
	MOVF INDICE,W ; Movemos el valor del auxiliar INDICE a W
	CALL TABLA3 ;Llamamos a la rutina que contiene el mensaje adecuado
	MOVWF DATO ; Movemos a W el valor de DATO
	XORLW '$' ; Verificamos si se llego al caracter de escape
	BTFSC STATUS,Z ; Verificamos si la bandera Z esta apagada
	RETURN ; Regresamos
	MOVF DATO,W ; Movemos el valor de DATO a W
	CALL ENVIA ; Llamamos a la rutina para enviar los datos
	INCF INDICE ;Incrementamos el valor de INDICE
	GOTO REGRESA_OTRO; Saltamos a REGRESA_OTRO
	
TABLA1 ; Bandera de TABLA1
	ADDWF PCL,1 ;sumamos PCL con 1  
	RETLW 'A' ; Cargamos y retornamos la letra A a W
	RETLW 'p' ; Cargamos y retornamos la letra p a W
	RETLW 'a' ; Cargamos y retornamos la letra a a W
	RETLW 'g' ; Cargamos y retornamos la letra g a W
	RETLW 'a' ; Cargamos y retornamos la letra a a W
	RETLW 'd' ; Cargamos y retornamos la letra d a W
	RETLW 'o' ; Cargamos y retornamos la letra o a W
	RETLW '\n' ; Cargamos y retornamos un salto de linea W
	RETLW '\r' ; Cargamos y retornamos un retorno de cursor a W
	RETLW '$' ; Cargamos y retornamos el caracter $ a W

TABLA2 ; Bandera de TABLA2
	ADDWF PCL,1 ; Sumamos 1 a PCL
	RETLW 'E' ; Cargamos y retornamos la letra E a W
	RETLW 'n' ; Cargamos y retornamos la letra n a W
	RETLW 'c' ; Cargamos y retornamos la letra c a W
	RETLW 'e' ; Cargamos y retornamos la letra e a W
	RETLW 'n' ; Cargamos y retornamos la letra n a W
	RETLW 'd' ; Cargamos y retornamos la letra d a W
	RETLW 'i' ; Cargamos y retornamos la letra i a W
	RETLW 'd' ; Cargamos y retornamos la letra d a W
	RETLW 'o' ; Cargamos y retornamos la letra o a W
	RETLW '\n' ; Cargamos y retornamos un salto de linea W
	RETLW '\r' ; Cargamos y retornamos un retorno de cursor a W
	RETLW '$' ; Cargamos y retornamos el caracter $ a W
	
TABLA3 ; Bandera para la TABLA3
	ADDWF PCL,1 ; sumamos PCL con 1
	RETLW 'E' ; Cargamos y retornamos la letra E a W
	RETLW 'r' ; Cargamos y retornamos la letra r a W
	RETLW 'r' ; Cargamos y retornamos la letra r a W
	RETLW 'o' ; Cargamos y retornamos la letra o a W
	RETLW 'r' ; Cargamos y retornamos la letra r a W
	RETLW '\n' ; Cargamos y retornamos un salto de linea W
	RETLW '\r' ; Cargamos y retornamos un retorno de cursor a W
	RETLW '$' ; Cargamos y retornamos el caracter $ a W
	
ENVIA ; Rutina de transmision	
	BSF STATUS,RP0 ; cambio de banco
	BCF STATUS,RP1 ; cambio de banco
	BTFSS TXSTA,TRMT ;Verifica si el bit TRMT esta encendido
	GOTO $-1 ; regresamos una instrccion (generando un loop)
	
	BCF STATUS,RP0 ; cambio al banco 0
	MOVF DATO,W ; Cargamos el valor de DATO a W
	MOVWF TXREG ; Cargamos el valor de W al registro TXREG
	RETURN ; retornamos

RECIBE ; Rutina para la recepcion
	BTFSS PIR1,RCIF ; Verificamos si el bit RCIF esta en alto
	GOTO $-1 ; regresamos una instruccion
	MOVF RCREG,W ; Cargamos el valor de RCREG a W
	RETURN; Retornamos

END ; Fin del programa
	
	
	