; Vilius Junevičius, 4 grupė
; MOV registras/atmintis, betarpiskas operandas
; 1100 011w mod 000 r/m [poslinkis] bojb [bovb]

; A program that disassembles the "MOV regsiter/memory, operand" command

.model small
.stack 100h
.data

	informacija db "Vilius Junevicius", 0dh, 0ah, "Zingsninio rezimo pertraukimo (int 1) apdorojimo procedura, atpazistanti komanda MOV r/m <= betarpiskas operandas", 0dh, 0ah, "$"

	senasIP dw ?
	senasCS dw ?
	
	regAX dw ?
	regBX dw ?
	regCX dw ?
	regDX dw ?
	regSP dw ?
	regBP dw ?
	regSI dw ?
	regDI dw ?
	
	baitas1 db ?
	baitas2 db ?
	baitas3 db ?
	baitas4 db ?
	baitas5 db ?
	baitas6 db ?
	baitas7 db ?
	baitas8 db ?
	
	tiesiog_mov db "MOV ", "$"
    mov_byte db "MOV byte ptr ", "$"
    mov_word db "MOV word ptr ", "$"

	prefiksas db 0
    es_prefiksas db "es:", "$"
    cs_prefiksas db "cs:", "$"
    ss_prefiksas db "ss:", "$"
    ds_prefiksas db "ds:", "$"


	lentele db "[BX+SI$$","[BX+DI$$","[BP+SI$$","[BP+DI$$","[SI$$$$$","[DI$$$$$","[$$$$$$$","[BX$$$$$","[BX+SI+$","[BX+DI+$","[BP+DI+$","[SI+$$$$","[DI+$$$$","[BP+$$$$","[BX+$$$$" 
	vieta dw ?

	result_array db 20h dup (0), 0
	_length dw ?

	mod_place db ?
    reg_place db ?
    r_m_place db ?
    w_place db ?

	formatas db 0
	formatas2 db 0

	zingsninis db "Zingsninio rezimo pertraukimas! ", "$"

	ax_lygu db " ax= ", "$"
	bx_lygu db " bx= ", "$"
	cx_lygu db " cx= ", "$"
	dx_lygu db " dx= ", "$"
	sp_lygu db " sp= ", "$"
	bp_lygu db " bp= ", "$"
	si_lygu db " si= ", "$"
	di_lygu db " di= ", "$"

	ax_skliaustai db " [ax]= ", "$"
	bx_skliaustai db " [bx]= ", "$"
	cx_skliaustai db " [cx]= ", "$"
	dx_skliaustai db " [dx]= ", "$"
	sp_skliaustai db " [sp]= ", "$"
	bp_skliaustai db " [bp]= ", "$"
	si_skliaustai db " [si]= ", "$"
	di_skliaustai db " [di]= ", "$"

	galas db "], ", "$"
	kablelis db ", ", "$"
	enteris db "", 0dh, 0ah,"$"

.code
	mov ax, @data
	mov ds, ax
	
	mov ah, 9h
	mov dx, offset informacija
	int 21h

;----------------ISSISAUGOJAM SENUS CS IR IP---------------
	mov ax, 0
	mov es, ax 
	
	mov ax, es:[4]
	mov bx, es:[6]
	mov senasCS, bx
	mov senasIP, ax

;------------------PERIMAME PERTRAUKIMA-----------------------
	mov ax, cs
	mov bx, offset pertraukimas
	
	mov es:[4], bx
	mov es:[6], ax

;---------------AKTYVUOJAME ZINGSNINI REZIMA-----------------------
	pushf 
	pop ax
	or ax, 100h ; 0000 0001 0000 0000b 
	push ax
	popf

;---------------------KOMANDU VYKDYMAS-----------------------------

    mov word ptr ds:[12h], 1234h
	mov byte ptr [bp+si], 12h
	mov word ptr [bp+si], 9988h

	db 36h, 0C6h, 46h, 00h, 00h
	;mov byte ptr ss:[bp], 00h
	mov word ptr ss:[di], 1234h
	mov byte ptr [bx + 1234h], 12h
	mov word ptr cs:[bp+di+1234h], 5678h
	mov word ptr ss:[bx+si+34h], 5678h
	mov word ptr es:[1234h], 5678h

	mov al, 12h ; Traktuoja, kaip B0 12
	db 0C6h, 0C0h, 12h ; Todel priversitinai masinini koda parasau
    mov cx, 1234h		; Traktuoja kaip B9 34 12
	db 0C7h, 0C1h, 34h, 12h  ; Todel priversitinai masinini koda parasau


;---------------ISJUNGIAME ZINGSNINI REZIMA----------------------
	pushf
	pop  ax
	and  ax, 0FEFFh ; 1111 1110 1111 1111b 
	push ax
	popf 
;-----------GRAZINAM PERTRAUKIMO CS IR IP REIKSMES------------------
	mov ax, senasIP
	mov bx, senasCS
	mov es:[4], ax
	mov es:[6], bx
	
uzdaryti_programa:
	mov ah, 4Ch
	int 21h
	
	
	
;----------------------------------------------------------;
;            PERTRAUKIMO APDOROJIMO PROCEDURA              ;
;----------------------------------------------------------;
pertraukimas:	
	mov regAX, ax				
	mov regBX, bx
	mov regCX, cx
	mov regDX, dx
	mov regSP, sp
	mov regBP, bp
	mov regSI, si
	mov regDI, di
	
		pop si ;pasiimam IP 
		pop di ;pasiimam CS 
		push di ;padedam CS 
		push si ;padedam, naudosime DI:SI, kaip CS:IP
		
		;Susidedam masininio kodo baitus i atminti
		mov ax, cs:[si]
		mov bx, cs:[si+2]
		mov cx, cs:[si+4]
		mov dx, cs:[si+6]
		
		mov baitas1, al
		mov baitas2, ah
		mov baitas3, bl
		mov baitas4, bh
		mov baitas5, cl
		mov baitas6, ch
		mov baitas7, dl
		mov baitas8, dh

		; Nunulinam kintamuosius
        mov byte ptr prefiksas, 0
		mov byte ptr formatas, 0
		mov byte ptr formatas2, 0



		; Tikrinam, ar yra prefiksas, o po to ar C6 ar C7
		cmp byte ptr baitas1, 26h
        jne nextt
        jmp es_prefix
        nextt:
            cmp byte ptr baitas1, 2Eh
            jne nextt2
            jmp cs_prefix
        nextt2:
            cmp byte ptr baitas1, 36h
            jne nextt3
            jmp ss_prefix
        nextt3:
            cmp byte ptr baitas1, 3Eh
            jne nextt4
            jmp ds_prefix

        nextt4:
            cmp byte ptr baitas1, 0C6h
            jne nextt5
            jmp tinka
        nextt5:
            cmp byte ptr baitas1, 0C7h
            je toliau
            jmp grizti_is_pertraukimo
            toliau:
            jmp tinka

        es_prefix:
            mov byte ptr prefiksas, 1
            jmp nexttt6
        cs_prefix:
            mov byte ptr prefiksas, 2
            jmp nexttt6
        ss_prefix:
            mov byte ptr prefiksas, 3
            jmp nexttt6
        ds_prefix:
            mov byte ptr prefiksas, 4
            jmp nexttt6

		nexttt6:
			cmp byte ptr baitas2, 0C6h
            jne nexttt7
            jmp tinka
        nexttt7:
            cmp byte ptr baitas2, 0C7h
            je toliau1
            jmp grizti_is_pertraukimo
            toliau1:
            jmp tinka
		
        tinka:
		mov ah, 9
		mov dx, offset zingsninis
		int 21h
		

		; Isspausdinam CS:IP 
		mov ax, di ;spausdinam CS, di registre esam pasideja CS
		call printAX
	
		mov ah, 2 
		mov dl, ":" 
		int 21h
		
		mov ax, si ;spausdinam IP, si registre esam pasideja IP
		call printAX
	
		call printSpace


	
	; Spausdinam masininio kodo baitus 
    yra_prefiksas:
        cmp byte ptr prefiksas, 0
        jne ne_nera_prefikso    ; Patikrinam, ar yra prefiksas
		jmp nera_prefikso
		ne_nera_prefikso:
        mov ah, baitas1 
        mov al, baitas2     ; Isspausdinam prefikso ir musu komandos baitus
        call printAX
		mov bl, baitas3
		and bl, 11000000b
		mov mod_place, bl		
		mov bl, baitas3
		and bl, 00111000b	; Isimenam mod reg r/m bitus
		mov reg_place, bl
		mov bl, baitas3
		and bl, 00000111b
		mov r_m_place, bl
        mov bl, baitas2
        and bl, 00000001b   ; Komandos paskutiniam bite patikrinam ar operuojam zodziais ar baitais
        mov w_place, bl
        cmp bl, 00000001b
        je zodziai
        baitai:
            mov ah, baitas3 ; Isspausdinam adresavimo baito ir vieno baito poslinkio masinini koda
            mov al, baitas4 
            call printAX
            cmp byte ptr mod_place, 01000000b
			je vienas1
			cmp byte ptr mod_place, 10000000b
			je du1
			cmp byte ptr mod_place, 00000000b
			je toliau3
			jmp nextt6
			toliau3:
			cmp byte ptr r_m_place, 00000110b
			je du1
            jmp nextt6
			vienas1:
				mov al, baitas5		; Isspausdinam vieno baito betarpisko operando masinini koda
				call printAL
				jmp nextt6
			du1:
				mov ah, baitas5
				mov al, baitas6		; Isspausdinam dvieju baitu betarpisko operando masinini koda
				call printAX
				jmp nextt6
        zodziai:
            mov ah, baitas3 ; Isspausdinam adresavimo baita ir dvieju baitu poslinkio masinini koda
            mov al, baitas4
            call printAX
            mov al, baitas5
            call printAL
            cmp byte ptr mod_place, 01000000b
			je vienas2
			cmp byte ptr mod_place, 10000000b
			je du2
			cmp byte ptr mod_place, 00000000b
			je toliau4
			jmp nextt6
			toliau4:
			cmp byte ptr r_m_place, 00000110b
			je du2
            jmp nextt6
			vienas2:
				mov al, baitas6		; Isspausdinam vieno baito betarpisko operando masinini koda
				call printAL
				jmp nextt6
			du2:
				mov ah, baitas6
				mov al, baitas7     ; Isspausdinam dvieju baitu betarpisko operando masinini koda
				call printAX
				jmp nextt6

    nera_prefikso:
        mov al, baitas1			; Isspausdinam komandos baita
        call printAL
		mov bl, baitas2
		and bl, 11000000b
		mov mod_place, bl		
		mov bl, baitas2
		and bl, 00111000b	; Isimenam mod reg r/m bitus
		mov reg_place, bl
		mov bl, baitas2
		and bl, 00000111b
		mov r_m_place, bl
        mov bl, baitas1
        and bl, 00000001b   ; Komandos baite patikrinam ar operuojam zodziais ar baitais
        mov w_place, bl
        cmp bl, 00000001b
        je zodziai1
        baitai1:
            mov ah, baitas2 ; Isspausdinam adresavimo baita ir vieno baito poslinkio masinin koda
            mov al, baitas3 
            call printAX
			cmp byte ptr mod_place, 01000000b
			je vienas3
			cmp byte ptr mod_place, 10000000b
			je du3
			cmp byte ptr mod_place, 00000000b
			je toliau5
			jmp nextt6
			toliau5:
			cmp byte ptr r_m_place, 00000110b
			je du3
            jmp nextt6
			vienas3:
				mov al, baitas4
				call printAL	; Isspausdinam vieno baito betarpiska operanda
				jmp nextt6
			du3:
				mov ah, baitas4		; Isspausdinam dvieju baitu betarpiska operanda
				mov al, baitas5
				call printAX
				jmp nextt6
        zodziai1:
            mov ah, baitas2	 ; Isspausdinam adresavimo baita ir dvieju baitu poslinkio masinini koda
            mov al, baitas3
            call printAX
            mov al, baitas4
            call printAL
            cmp byte ptr mod_place, 01000000b
			je vienas4
			cmp byte ptr mod_place, 10000000b
			je du4
			cmp byte ptr mod_place, 00000000b
			je toliau6
			jmp nextt6
			toliau6:
			cmp byte ptr r_m_place, 00000110b
			je du4
            jmp nextt6
			vienas4:
				mov al, baitas5  ; Isspausdinam vieno baito betarpiska operanda
				call printAL
				jmp nextt6
			du4:
				mov ah, baitas5
				mov al, baitas6   ; Isspausdinam dvieju baitu betarpiska operanda
				call printAX
				jmp nextt6

    nextt6:
    skip2:
        call printSpace
        call printSpace



	
	;Spausdinam komandos mnemonika (asemblerini uzrasa)
	; Jeigu mov komanda su registrais, tai isspausdinam MOV, o jeigu ne,
	; tuomet MOV byte ptr arba MOV word ptr
	cmp byte ptr mod_place, 11000000b    
	jne praleidziam							
	mov ah, 9
	mov dx, offset tiesiog_mov
	int 21h
	jmp mod_reg_r_m
	praleidziam:

    cmp byte ptr w_place, 00000001b
    jne baitas

	zodis1:
		mov ah, 9
		mov dx, offset mov_word 
		int 21h
		jmp mod_reg_r_m

    baitas:
        mov ah, 9
        mov dx, offset mov_byte 
        int 21h


	; Pagal mod reg r/m duomenis issiaiskinam kurie registrai bus naudojami
		; Juos issisaugojam result_array
	mod_reg_r_m:
		push di

		cmp byte ptr mod_place, 11000000b
		jne not_mod11
		jmp mod11
		not_mod11:
		cmp byte ptr mod_place, 10000000b
		jne not_mod10
		jmp mod10
		not_mod10:
		cmp byte ptr mod_place, 01000000b
		jne not_mod01
		jmp mod01
		not_mod01:
		cmp byte ptr mod_place, 00000000b
		jne not_mod00
		jmp mod00
		not_mod00:

		mod11:
			cmp w_place, 00000001b
			je mod11_w1
			cmp w_place, 00000000b
			jne not_mod11_w0
			jmp mod11_w0
			not_mod11_w0:

			mod11_w1:
				cmp byte ptr r_m_place, 000b
				jne next
					mov byte ptr formatas, 1
					mov di, 0
					mov result_array[di], 'A'
					inc di
					mov result_array[di], 'X'
					mov _length, di
					jmp back
				next:
				cmp byte ptr r_m_place, 001b
				jne next1
					mov byte ptr formatas, 3
					mov di, 0
					mov result_array[di], 'C'
					inc di
					mov result_array[di], 'X'
					mov _length, di
					jmp back
				next1:
				cmp byte ptr r_m_place, 010b
				jne next2
					mov byte ptr formatas, 4
					mov di, 0
					mov result_array[di], 'D'
					inc di
					mov result_array[di], 'X'
					mov _length, di
					jmp back
				next2:
				cmp byte ptr r_m_place, 011b
				jne next3
					mov byte ptr formatas, 2
					mov di, 0
					mov result_array[di], 'B'
					inc di
					mov result_array[di], 'X'
					mov _length, di
					jmp back
				next3:
				cmp byte ptr r_m_place, 100b
				jne next4
					mov byte ptr formatas, 5
					mov di, 0
					mov result_array[di], 'S'
					inc di
					mov result_array[di], 'P'
					mov _length, di
					jmp back
				next4:
				cmp byte ptr r_m_place, 101b
				jne next5
					mov byte ptr formatas, 6
					mov di, 0
					mov result_array[di], 'B'
					inc di
					mov result_array[di], 'P'
					mov _length, di
					jmp back
				next5:
				cmp byte ptr r_m_place, 110b
				jne next6
					mov byte ptr formatas, 7
					mov di, 0
					mov result_array[di], 'S'
					inc di
					mov result_array[di], 'I'
					mov _length, di
					jmp back
				next6:
				cmp byte ptr r_m_place, 111b
				je not_back
				jmp back
				not_back:
					mov byte ptr formatas, 8
					mov di, 0
					mov result_array[di], 'D'
					inc di
					mov result_array[di], 'I'
					mov _length, di
					jmp back

			mod11_w0:
				cmp byte ptr r_m_place, 000b
				jne next29
					mov byte ptr formatas, 1
					mov di, 0
					mov result_array[di], 'A'
					inc di
					mov result_array[di], 'L'
					mov _length, di
					jmp back
				next29:
				cmp byte ptr r_m_place, 001b
				jne next30
					mov byte ptr formatas, 3
					mov di, 0
					mov result_array[di], 'C'
					inc di
					mov result_array[di], 'L'
					mov _length, di
					jmp back
				next30:
				cmp byte ptr r_m_place, 010b
				jne next31
					mov byte ptr formatas, 4
					mov di, 0
					mov result_array[di], 'D'
					inc di
					mov result_array[di], 'L'
					mov _length, di
					jmp back
				next31:
				cmp byte ptr r_m_place, 011b
				jne next32
					mov byte ptr formatas, 2
					mov di, 0
					mov result_array[di], 'B'
					inc di
					mov result_array[di], 'L'
					mov _length, di
					jmp back
				next32:
				cmp byte ptr r_m_place, 100b
				jne next33
					mov byte ptr formatas, 1
					mov di, 0
					mov result_array[di], 'A'
					inc di
					mov result_array[di], 'H'
					mov _length, di
					jmp back
				next33:
				cmp byte ptr r_m_place, 101b
				jne next34
					mov byte ptr formatas, 3
					mov di, 0
					mov result_array[di], 'C'
					inc di
					mov result_array[di], 'H'
					mov _length, di
					jmp back
				next34:
				cmp byte ptr r_m_place, 110b
				jne next35
					mov byte ptr formatas, 4
					mov di, 0
					mov result_array[di], 'D'
					inc di
					mov result_array[di], 'H'
					mov _length, di
					jmp back
				next35:
				cmp byte ptr r_m_place, 111b
				je not_back1
				jmp back
				not_back1:
					mov byte ptr formatas, 2
					mov di, 0
					mov result_array[di], 'B'
					inc di
					mov result_array[di], 'H'
					mov _length, di
					jmp back
		
		mod00:
			cmp byte ptr r_m_place, 000b
			jne next7
				mov byte ptr formatas, 2
				mov byte ptr formatas2, 7
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'X'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'S'
				inc di
				mov result_array[di], 'I'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next7:
			cmp byte ptr r_m_place, 001b
			jne next8
				mov byte ptr formatas, 2
				mov byte ptr formatas2, 8
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'X'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'D'
				inc di
				mov result_array[di], 'I'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next8:
			cmp byte ptr r_m_place, 010b
			jne next9
				mov byte ptr formatas, 6
				mov byte ptr formatas2, 7
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'P'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'S'
				inc di
				mov result_array[di], 'I'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next9:
			cmp byte ptr r_m_place, 011b
			jne next10
				mov byte ptr formatas, 6
				mov byte ptr formatas2, 8
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'P'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'D'
				inc di
				mov result_array[di], 'I'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next10:
			cmp byte ptr r_m_place, 100b
			jne next11
				mov byte ptr formatas, 7
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'S'
				inc di
				mov result_array[di], 'I'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next11:
			cmp byte ptr r_m_place, 101b
			jne next12
				mov byte ptr formatas, 8
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'D'
				inc di
				mov result_array[di], 'I'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next12:
			cmp byte ptr r_m_place, 110b
			jne next13
				mov byte ptr formatas, 0
				mov di, 0
				mov result_array[di], '['
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next13:
			cmp byte ptr r_m_place, 111b
			je not_back2
			jmp back
			not_back2:
				mov byte ptr formatas, 2
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'X'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
	

		mod01:
		mod10:
			cmp byte ptr r_m_place, 000b
			jne next14
				mov byte ptr formatas, 2
				mov byte ptr formatas2, 7
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'X'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'S'
				inc di
				mov result_array[di], 'I'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next14:
			cmp byte ptr r_m_place, 001b
			jne next15
				mov byte ptr formatas, 2
				mov byte ptr formatas2, 8
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'X'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'D'
				inc di
				mov result_array[di], 'I'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next15:
			cmp byte ptr r_m_place, 010b
			jne next16
				mov byte ptr formatas, 6
				mov byte ptr formatas2, 7
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'P'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'S'
				inc di
				mov result_array[di], 'I'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next16:
			cmp byte ptr r_m_place, 011b
			jne next17
				mov byte ptr formatas, 6
				mov byte ptr formatas2, 8
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'P'
				inc di
				mov result_array[di], '+'
				inc di
				mov result_array[di], 'D'
				inc di
				mov result_array[di], 'I'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next17:
			cmp byte ptr r_m_place, 100b
			jne next18
				mov byte ptr formatas, 7
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'S'
				inc di
				mov result_array[di], 'I'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next18:
			cmp byte ptr r_m_place, 101b
			jne next19
				mov byte ptr formatas, 8
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'D'
				inc di
				mov result_array[di], 'I'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next19:
			cmp byte ptr r_m_place, 110b
			jne next20
				mov byte ptr formatas, 6
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'P'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
			next20:
			cmp byte ptr r_m_place, 111b
			jne back
				mov byte ptr formatas, 2
				mov di, 0
				mov result_array[di], '['
				inc di
				mov result_array[di], 'B'
				inc di
				mov result_array[di], 'X'
				inc di
				mov result_array[di], '+'
				mov _length, di
				mov al, r_m_place
				mov bl, 8h
				mul bl
				mov vieta, ax
				jmp back
		
	back:
	pop di

	; Isspaudsdinam prefiksa, jeigu jis yra
	cmp byte ptr prefiksas, 0
	je no_prefix
	cmp prefiksas, 1
	jne ne_es
	mov dx, offset es_prefiksas
	mov ah, 9
	int 21h
	jmp printinam
	ne_es:
		cmp byte ptr prefiksas, 2
		jne ne_cs
		mov dx, offset cs_prefiksas
		mov ah, 9
		int 21h
		jmp printinam
	ne_cs:
		cmp byte ptr prefiksas, 3
		jne ne_ss
		mov dx, offset ss_prefiksas
		mov ah, 9
		int 21h
		jmp printinam
	ne_ss:
		cmp byte ptr prefiksas, 4
		jne ne_ds
		mov dx, offset ds_prefiksas
		mov ah, 9
		int 21h
		jmp printinam
	ne_ds:
	printinam:
            

    no_prefix:
	; cmp byte ptr mod_place, 11000000b
	; jne lenteles_budas
	mov cx, _length
	inc cx
	push si
	mov si, 0
	repeat:
	mov ah, 2
	mov dx, offset result_array[si]
	int 21h
	inc si
	dec cx
	jne repeat
	pop si
	jmp spausdinam_poslinki
	; lenteles_budas:
	; 	mov bx, vieta
	; 	mov ah, 9h
	; 	mov dx, offset lentele
	; 	add dx, bx
	; 	int 21h



	; Isspausdinam poslinki
	spausdinam_poslinki:
		cmp byte ptr mod_place, 01000000b		; Patikrinam ar mod lygus 01 ar 10
		je vienas_baitas_poslinkis
		cmp byte ptr mod_place, 10000000b
		je du_baitai_poslinkis
		cmp byte ptr mod_place, 00000000b		; Patikrinam ar mod lygus 00 ur r/m lygus 110 (tiesioginis adresas)
		je toliau2
		jmp skip_poslinkis
		toliau2:
		cmp byte ptr r_m_place, 00000110b
		je du_baitai_poslinkis
		jmp skip_poslinkis

		vienas_baitas_poslinkis:
			; mov ah, 2
			; mov dx, '+'
			; int 21h
			cmp prefiksas, 0
			je nera_prefikso2

			yra_prefiksas2:
				mov al, baitas4
				call printAL
				jmp h_raide
			nera_prefikso2:
				mov al, baitas3
				call printAL
				jmp h_raide

		du_baitai_poslinkis:
			; mov ah, 2
			; mov dx, '+'
			; int 21h
			cmp prefiksas, 0
			je nera_prefikso3

			yra_prefiksas3:
				mov ah, baitas5
				mov al, baitas4
				call printAX
				jmp h_raide
			nera_prefikso3:
				mov ah, baitas4
				mov al, baitas3
				call printAX
				jmp h_raide

	h_raide:
		mov ah, 2
		mov dx, 'h'
		int 21h

	skip_poslinkis:
		cmp byte ptr mod_place, 11000000b
		jne tesiam										; Jei mov komanda su registrais, tai spausdinam tik kableli
		mov ah, 9
		mov dx, offset kablelis
		int 21h
		jmp spausdinam_betarpiska

		tesiam:
		mov ah, 9
		mov dx, offset galas						; Jei ne, tai isspausdinam lauztini skliausta ir kableli
		int 21h
	 
	;spausdinam betarpiska operanda (operanda konstanta)
    spausdinam_betarpiska:
		cmp prefiksas, 0
		jne ne_nera_prefikso1
		jmp nera_prefikso1
		ne_nera_prefikso1:

		yra_prefiksas1:
			cmp w_place, 00000001b
			je operuojam_zodziais

			operuojam_baitais:
				cmp byte ptr mod_place, 01000000b
				je vieno_baito_poslinkis
				cmp byte ptr mod_place, 10000000b
				je dvieju_baitu_poslinkis
				cmp byte ptr mod_place, 00000000b
				je toliau7
				jmp be_poslinkio
				toliau7:
				cmp byte ptr r_m_place, 00000110b
				je dvieju_baitu_poslinkis

				be_poslinkio:
					mov al, baitas4
					call printAL
					jmp betarpisko_galas

				vieno_baito_poslinkis:
					mov al, baitas5
					call printAL
					jmp betarpisko_galas

				dvieju_baitu_poslinkis:
					mov al, baitas6
					call printAL
					jmp betarpisko_galas

			operuojam_zodziais:
				cmp byte ptr mod_place, 01000000b
				je vieno_baito_poslinkis2
				cmp byte ptr mod_place, 10000000b
				je dvieju_baitu_poslinkis2
				cmp byte ptr mod_place, 00000000b
				je toliau8
				jmp be_poslinkio2
				toliau8:
				cmp byte ptr r_m_place, 00000110b
				je dvieju_baitu_poslinkis2

				be_poslinkio2:
					mov ah, baitas5
					mov al, baitas4
					call printAX
					jmp betarpisko_galas

				vieno_baito_poslinkis2:
					mov ah, baitas6
					mov al, baitas5
					call printAX
					jmp betarpisko_galas

				dvieju_baitu_poslinkis2:
					mov ah, baitas7
					mov al, baitas6
					call printAX
					jmp betarpisko_galas

		nera_prefikso1:
			cmp w_place, 00000001b
			je operuojam_zodziais1

			operuojam_baitais1:
				cmp byte ptr mod_place, 01000000b
				je vieno_baito_poslinkis3
				cmp byte ptr mod_place, 10000000b
				je dvieju_baitu_poslinkis3
				cmp byte ptr mod_place, 00000000b
				je toliau9
				jmp be_poslinkio3
				toliau9:
				cmp byte ptr r_m_place, 00000110b
				je dvieju_baitu_poslinkis3

				be_poslinkio3:
					mov al, baitas3
					call printAL
					jmp betarpisko_galas

				vieno_baito_poslinkis3:
					mov al, baitas4
					call printAL
					jmp betarpisko_galas

				dvieju_baitu_poslinkis3:
					mov al, baitas5
					call printAL
					jmp betarpisko_galas

			operuojam_zodziais1:
				cmp byte ptr mod_place, 01000000b
				je vieno_baito_poslinkis4
				cmp byte ptr mod_place, 10000000b
				je dvieju_baitu_poslinkis4
				cmp byte ptr mod_place, 00000000b
				je toliau10
				jmp be_poslinkio4
				toliau10:
				cmp byte ptr r_m_place, 00000110b
				je dvieju_baitu_poslinkis4

				be_poslinkio4:
					mov ah, baitas4
					mov al, baitas3
					call printAX
					jmp betarpisko_galas

				vieno_baito_poslinkis4:
					mov ah, baitas5
					mov al, baitas4
					call printAX
					jmp betarpisko_galas

				dvieju_baitu_poslinkis4:
					mov ah, baitas6
					mov al, baitas5
					call printAX
					jmp betarpisko_galas
			
	betarpisko_galas:
	mov ah, 2 ;h raide prie sesioliktainio skaiciaus (butina rasant asemblerines komandas)
	mov dl, "h"
	int 21h
	
	call printSpace
	
	mov ah, 2 ;Spausdinam kabliataski
	mov dl, ";"
	int 21h
	call printSpace
	call printSpace
	
	call formatai
	mov al, formatas2
	mov formatas, al
	call formatai
	

	mov ah, 9
	mov dx, offset enteris
	int 21h
	
	grizti_is_pertraukimo:
	mov ax, regAX
	mov bx, regBX
	mov cx, regCX
	mov dx, regDX
	mov sp, regSP
	mov bp, regBP
	mov si, regSI
	mov di, regDI
IRET ;grizimas is pertraukimo apdorojimo proceduros

;-----------------PROCEDUROS--------------

; Isspausdinam ax reiksme
printAX:
	push ax
	mov al, ah
	call printAL
	pop ax
	call printAL
RET

; Isspausdinam al reiksme
printAL:
	push ax
	push cx
		push ax
		mov cl, 4
		shr al, cl
		call printHexSkaitmuo
		pop ax
		call printHexSkaitmuo
	pop cx
	pop ax
RET

; Isspausdina AL reiksme paversta i ascii koda
printHexSkaitmuo:
	push ax
	push dx
	
	and al, 0Fh ;nunulinam vyresniji pusbaiti AND al, 00001111b
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
	PrintHexSkaitmuo_A_F: 
	sub al, 10 ;10-15 ===> 0-5
	add al, 41h
	mov dl, al
	mov ah, 2; spausdiname simboli (A-F) is DL'o
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
	PrintHexSkaitmuo_0_9: ;0-9
	mov dl, al
	add dl, 30h
	mov ah, 2 ;spausdiname simboli (0-9) is DL'o
	int 21h
	jmp printHexSkaitmuo_grizti
	
	printHexSkaitmuo_grizti:
	pop dx
	pop ax
RET

; Isspausdinam tarpa
printSpace:
	push ax
	push dx
		mov ah, 2
		mov dl, " "
		int 21h
	pop dx
	pop ax
RET

; Isspausdinam informacija apie registrus, ju reiksmes ir adresus
formatai:
	cmp byte ptr formatas, 0
	jne ne_pabaiga_proceduros
	jmp pabaiga_proceduros
	ne_pabaiga_proceduros:

	cmp byte ptr formatas, 1
	jne skip6
	mov ah, 9
	mov dx, offset ax_lygu
	int 21h
	mov ax, regAX
	call printAX
	mov ah, 9
	mov dx, offset ax_skliaustai
	int 21h
	mov ax, offset regAX
	call printAX
	jmp pabaiga_proceduros
	
	skip6:
	cmp byte ptr formatas, 2
	jne skip7
	mov ah, 9
	mov dx, offset bx_lygu
	int 21h
	mov ax, regBX
	call printAX
	mov ah, 9
	mov dx, offset bx_skliaustai
	int 21h
	mov ax, offset regBX
	call printAX
	jmp pabaiga_proceduros

	skip7:
	cmp byte ptr formatas, 3
	jne skip8
	mov ah, 9
	mov dx, offset cx_lygu
	int 21h
	mov ax, regCX
	call printAX
	mov ah, 9
	mov dx, offset cx_skliaustai
	int 21h
	mov ax, offset regCX
	call printAX
	jmp pabaiga_proceduros

	skip8:
	cmp byte ptr formatas, 4
	jne skip9
	mov ah, 9
	mov dx, offset dx_lygu
	int 21h
	mov ax, regDX
	call printAX
	mov ah, 9
	mov dx, offset dx_skliaustai
	int 21h
	mov ax, offset regDX
	call printAX
	jmp pabaiga_proceduros
	
	skip9:
	cmp byte ptr formatas, 5
	jne skip10
	mov ah, 9
	mov dx, offset sp_lygu
	int 21h
	mov ax, regSP
	call printAX
	mov ah, 9
	mov dx, offset sp_skliaustai
	int 21h
	mov ax, offset regSP
	call printAX
	jmp pabaiga_proceduros

	skip10:
	cmp byte ptr formatas, 6
	jne skip11
	mov ah, 9
	mov dx, offset bp_lygu
	int 21h
	mov ax, regBP
	call printAX
	mov ah, 9
	mov dx, offset bp_skliaustai
	int 21h
	mov ax, offset regBP
	call printAX
	jmp pabaiga_proceduros

	skip11:
	cmp byte ptr formatas, 7
	jne skip12
	mov ah, 9
	mov dx, offset si_lygu
	int 21h
	mov ax, regSI
	call printAX
	mov ah, 9
	mov dx, offset si_skliaustai
	int 21h
	mov ax, offset regSI
	call printAX
	jmp pabaiga_proceduros

	skip12:
	cmp byte ptr formatas, 8
	jne skip13
	mov ah, 9
	mov dx, offset di_lygu
	int 21h
	mov ax, regDI
	call printAX
	mov ah, 9
	mov dx, offset di_skliaustai
	int 21h
	mov ax, offset regDI
	call printAX
	jmp pabaiga_proceduros
	skip13:

	pabaiga_proceduros:
RET

END
