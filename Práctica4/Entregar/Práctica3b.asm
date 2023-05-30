		PROCESSOR 16F877
		INCLUDE <P16F877.INC>
		cblock
			d1
			d2
			d3
			d4
			d5
			d6
		endc
		cblock 0x37
			count
			times
		endc
	
		ORG 0
		GOTO INICIO
		ORG 5
;DELAYS
		;DELAY150
		movlw	0x86
		movwf	d1
		movlw	0xA3
		movwf	d2
		movlw	0x02
		movwf	d3
	
		;DELAY4S
		movlw	0xB6
		movwf	d4
		movlw	0x99
		movwf	d5
		movlw	0x2C
	movwf	d6

;CARLOS CASTELAN RAMOS - PEDRO JAIR CORONA NAVA

INICIO:		CLRF PORTA ;Limpia PORTA
			CLRF PORTB ;Limpia PORTB
		
			;CAMBIA A BANCO 1
			BSF STATUS, RP0 
			BCF STATUS, RP1
			
			;PORT A - ENTRADA
			MOVLW H'FF'
			MOVWF TRISA
	
			;PORTB - SALIDA
			MOVLW H'0'
			MOVWF TRISB

			;DEFINIR INICIO DE ESCRITURA DE MEMORIA FSR
			MOVLW 0X20
			MOVWF FSR ;FSR=20

			;CAMBIA A BANCO 0
			BCF STATUS,5
		
;PREGUNTA SI QUIERE GRABAR
GRABAR:		CALL DEBOUNE1
			BTFSS PORTA, 2
				GOTO REPRODUCIR ;Reproduce lo que tenga guardado
				GOTO SELEC_G ;SI - LOOP DE SELECCIÓN A GRABAR


SELEC_G:	MOVF PORTA,W	;W<-- (PORTE)
			ANDLW 3			;W <-- W&00000011
			ADDWF PCL,F		;(PCL)<-- (PCL)+W
			GOTO G_DESP_IZQ	;PC+0	-> Switches: 00
			GOTO G_DESP_DER	;PC+1	-> Switches: 01
			GOTO G_ON_OFF ;PC+2	-> Switches: 10
			GOTO G_ON4  ;PC+3	  -> Switches: 11

G_DESP_IZQ:	MOVLW H'0' 	;Carga 00 a W
			MOVWF INDF 	;Mueve el valor de W a contenido de FSR
			INCF FSR 	;Incrementa posición FSR
			GOTO REPRODUCIR
G_DESP_DER:	MOVLW H'1' 	;Carga 01 a W
			MOVWF INDF 	;Mueve el valor de W a contenido de FSR
			INCF FSR 	;Incrementa posición FSR
			GOTO REPRODUCIR
G_ON_OFF:	MOVLW H'2' 	;Carga 10 a W
			MOVWF INDF 	;Mueve el valor de W a contenido de FSR
			INCF FSR 	;Incrementa posición FSR
			GOTO REPRODUCIR
G_ON4:  	MOVLW H'3' 	;Carga 11 a W
			MOVWF INDF 	;Mueve el valor de W a contenido de FSR
			INCF FSR 	;Incrementa posición FSR
			GOTO REPRODUCIR

;PREGUNTA SI QUIERE REPRODUCIR
REPRODUCIR:	CALL DEBOUNE2
			BTFSS PORTA, 3
				GOTO GRABAR ; NO - Pregunta si quiere grabar de nuevo
				GOTO LEER_MEM; SI - Lee memoria de instrucciones guardadas

;LECTURA DE MEMORIA
LEER_MEM: 	MOVLW 0X20 ;Parte de la posición 20
			GOTO LECTURA
LECTURA:	MOVF FSR, W
			ANDLW 3			;W <-- W&00000011
			ADDWF PCL,F		;(PCL)<-- (PCL)+W
			GOTO DESP_IZQ	;PC+0	-> Switches: 00
			GOTO DESP_DER	;PC+1	-> Switches: 01
			GOTO ON_OFF ;PC+2	-> Switches: 10
			GOTO ON4  ;PC+3	  -> Switches: 11
	
;DESPLAZAMIENTO A LA IZQUIERDA		
DESP_IZQ:	BCF PORTB, 0 ; Apagamos el LED
		    CALL DELAY150 ; Retardo de 150 ms
		    RLF PORTB, F ; Desplaza a la izquierda
		    BSF PORTB, 7 ; Enciende el LED
   	 		CALL DELAY150 ; Retardo de 150 ms
			INCF FSR 	;Incrementa posición FSR
			GOTO LECTURA

;DESPLAZAMIENTO A LA DERECHA
DESP_DER:	BCF PORTB, 0 ; Apagamos el LED
		    CALL DELAY150 ; Retardo de 150 ms
			RRF PORTB, F ; Desplazamiento a la derecha del valor en el puerto B
			BSF PORTB, 7 ; Enciende el LED
		    CALL DELAY150 ; Retardo de 150 ms
			INCF FSR 	;Incrementa posición FSR
			GOTO LECTURA

;ENCENDER Y APAGAR 8 VECES
ON_OFF:		CLRF PORTB ;Apaga todos los leds
			MOVLW .8     ; Establecer el número de iteraciones
   			MOVWF times
LOOP:		MOVLW 0xFF	; Encender todos los LEDs 
		    MOVWF PORTB
		    CALL DELAY150   ; Esperar un momento
		    ; Apagar todos los LEDs
		    CLRF PORTB
		    CALL DELAY150   ; Esperar un momento
		
		    ; Decrementar el contador de iteraciones
		    DECFSZ times,f
		    GOTO LOOP   ; Volver al inicio del loop si no ha terminado
		
		    ; Detener el programa
		    GOTO $     ; Bucle infinito
			INCF FSR 	;Incrementa posición FSR
			GOTO LECTURA

;ENCENDER 4 SEGUNDOS
ON4:    	CLRF PORTB; APAGAMOS LOS LEDS
			MOVLW H'FF' ;Pasamos puros 1 a w
			MOVWF PORTB; Encendemos los leds
			CALL DELAY4S
			INCF FSR 	;Incrementa posición FSR
			GOTO LECTURA
			
;DELAY150MS
DELAY150:	decfsz	d1, f
			goto	$+2
			decfsz	d2, f
			goto	$+2
			decfsz	d3, f
			goto	DELAY150
		
					;1 cycle
			nop

;DELAY 4 SEG
DELAY4S:	decfsz	d3, f			
			goto	$+2
			decfsz	d4, f
			goto	$+2
			decfsz	d5, f
			goto	DELAY4S


			;1 cycle
			nop

;DEBOUNE PARA OSICLACIÓN DE GRABAR
DEBOUNE1: 	BTFSC PORTA, 2
			GOTO $-1
			CALL DELAY150
			BTFSS PORTA, 2
			GOTO $-2
			CALL DELAY150

;DEBOUNE PARA OSICLACIÓN DE REPRODUCIR
DEBOUNE2: 	BTFSC PORTA, 3
			GOTO $-1
			CALL DELAY150
			BTFSS PORTA, 3
			GOTO $-2
			CALL DELAY150


END