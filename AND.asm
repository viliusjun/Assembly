; Vilius Junevičius, 4 grupė, 1 pogrupis, 2 užduotis, užduoties nr. 21

; A program that does the AND opperation to two binary numbers which are in two different files and outputs the result into the third file

;Parašykite programą, kuri atlieka operaciją AND dviems beveik bet kokio ilgio dvejetainiams skaičiams, esantiems failuose, ir išveda rezultatą į trečią failą.

; Visi parametrai programai turi būti paduodami komandine eilute, o ne prašant juos įvesti iš klaviatūros. Pvz.: antra duom.txt rez.txt
; Jeigu programa paleista be parametrų arba parametrai nekorektiški, reikia atspausdinti pagalbos pranešimą tokį patį, kaip paleidus programą su parametru /?.
; Programa turi apdoroti įvedimo išvedimo (ir kitokias) klaidas. Pavyzdžiui, nustačius, kad nurodytas failas neegzistuoja - ji turi išvesti pagalbos pranešimą ir baigti darbą.
; Failų skaitymo ar rašymo buferio dydis turi būti nemažesnis už 10 baitų.
; Failo dydis gali viršyti skaitymo ar rašymo buferio dydį.
; Panaudot funkciją.

.MODEL small        ; atminties modelis
.STACK 100h         ; steko dydis
.DATA               ; duomenu segmentas

help_msg db "Usage:", 0dh, 0ah, "A2.exe input_file.txt output_file.txt result_file.txt", 0dh, 0ah, "$"
wrong_msg db "You should input THREE files that are seperated by a space", 0dh, 0ah, "$"
not_opened_msg db "The file could not be opened", 0dh, 0ah, "$"
not_created_msg db "The file could not be created", 0dh, 0ah, "$"
cannot_LSEEK_msg db "The file courser could not be moved", 0dh, 0ah, "$"
cannot_read_msg db "Can't read from file", 0dh, 0ah, "$"
cannot_write_msg db "Can't write into file", 0dh, 0ah, "$"
not_all_written_msg db "Wierdly, not all of the bites were written", 0dh, 0ah, "$"
success_msg db "Everything is successful!", 0dh, 0ah, "$"

file1 db 10h dup (0), 0 ; failas turetu baigtis 0
file2 db 10h dup (0), 0
file3 db 10h dup (0), 0
handle1 dw 0    ; failu deskriptoriai
handle2 dw 0
handle3 dw 0

read dw ? ; Kiek simboliu is tikro perskaitem
read1 dw ?
read2 dw ?
difference dw ?

zero db '0'
array1 db 10h dup (0) ; Perskaityti skaiciai failuose bus irasomi i masyvus
array2 db 10h dup (0)
array3 db 10h dup (0)
temporary_array db 10h dup (0)

.CODE
start:
	mov ax, @data   ; ds registro inicializavimas
	mov ds, ax
	

no_command_line_arguments:
    mov bx, 80h
    cmp byte ptr es:[80h], 0 ; poslinkiu 80h yra pateikta perskaitytu simboliu kiekis
	je help

spaces:
    inc bx ; poslinkiu 81h yra pateikti patys parametrai
    mov ax, es:[bx]
    cmp al, " " ; ignoruojam visus tarpus pries parametrus
    je spaces

asking_for_help: 
	cmp es:[bx], "?/" ; jeigu neirase /? sokam i file_name1 (skaitant is parametru pirma uzpildomas jaunesnysis baitas, tik po to vyresnysis, todel atvirksciai /?)
	jne file_name1
    add bx, 2         
	cmp byte ptr es:[bx], 0Dh ; jeigu po /? iskart paspausta enter, sokam i pagalba
	je help
	jmp file_name1

help:
    mov ah, 09h
    mov dx, offset help_msg
    int 21h
    jmp finish

file_name1:
    mov si, offset file1 ; rasysim, ka perskaitysim parametruose, i file1
repeat:
	mov dl, byte ptr es:[bx] ;[si] = es:[bx], negalima rasyti is atminties i atminti, todel naudojam dl
	mov [si], dl
	
    cmp byte ptr es:[bx], " " ; jeigu pasiekem space, pradedam skaityti kita failo pavadinima
	je file_name2
    cmp byte ptr es:[bx], 0Dh ; jeigu jau pasiekem enter, sokam i wrong_usage
    je wrong_usage

	inc bx
	inc si
	jmp repeat

file_name2:
    mov dl, 0   ; Paskutini file1 simboli paverciam 0, vietoj irasyto tarpo
    mov [si], dl
    inc bx
    mov si, offset file2 ; rasysim, ka perskaitysim parametruose, i file2
repeat2:
	mov dl, byte ptr es:[bx] 
	mov [si], dl
	
    cmp byte ptr es:[bx], " "
	je file_name3
    cmp byte ptr es:[bx], 0Dh
    je wrong_usage

	inc bx
	inc si
	jmp repeat2

file_name3:
    mov dl, 0   ; Paskutini file2 simboli paverciam 0, vietoj irasyto tarpo
    mov [si], dl
    inc bx
    mov si, offset file3 ; rasysim, ka perskaitysim parametruose, i file3
repeat3:
	mov dl, byte ptr es:[bx] 
	mov [si], dl
	
    cmp byte ptr es:[bx], " " ; jeigu jau dabar pasiekiem space arba enter sokam i open
	je open
    cmp byte ptr es:[bx], 0Dh
    je open

	inc bx
	inc si
	jmp repeat3

wrong_usage:
    mov ah, 09h
    mov dx, offset wrong_msg
    int 21h
    jmp finish

open:
    mov dl, 0                   ; Paskutini file3 simboli paverciam 0, vietoj irasyto enter arba tarpo
    mov [si], dl
    mov dx, offset file1
    mov ax, 3D00h               ; Atidaryti faila tik skaitymui
    int 21h
    jnc opened               ; Jeigu carry flag = 1, tai neatsidare
    jmp not_open
    opened:
    mov [handle1], ax           ; Issaugoti deskriptoriu

    mov dx, offset file2
    mov ax, 3D00h               
    int 21h
    jnc opened2
    jmp not_open
    opened2:               
    mov [handle2], ax
    jmp create

create:
    mov dx, offset file3       ; Sukuriam trecia faila rezultatam
    mov cx, 2                  ; sisteminis irasymas
    mov ah, 3Ch
    int 21h
    mov [handle3], ax
    jnc created            ; Jeigu carry flag = 1, tai nesusikure
    jmp not_created
    created:
    jmp counting_difference

counting_difference:
    mov bx, [handle1]
    mov ah, 3Fh             ; Skaityti faila
    mov cx, 10h            ; Kiek baitu perskaityti
    mov dx, offset temporary_array     
    int 21h 
    jnc can_read                 ; Jeigu carry neperskaitemt
    jmp cannot_read
    can_read:
    mov read1, ax

    mov bx, [handle2]
    mov ah, 3Fh             
    mov cx, 10h            
    mov dx, offset temporary_array 
    int 21h 
    jnc can_read2
    jmp cannot_read
    can_read2:
    mov read2, ax

    cmp read1, ax      ; Tikrinam, ar perskaitem abiejuose failuose tiek pat baitu
    je equal
    jmp next           

    equal:
    cmp word ptr read1, 0   ; Tikrinam, ar dabar abiejuose failuose perskaityta po 0 baitu
    jne counting_difference ; jeigu ne, kartojam vel skaityma

    next:
    cmp read1, ax           ; Tikrinam, ar is pirmo failo perskaitem maziau arba tiek pat skaitmenu, kiek is antro
    jbe second_file_is_longer_or_equal 

    first_file_is_longer:
    sub read1, ax
    mov ax, read1
    mov difference, ax  
    mov bx, [handle1]
    mov ax, 4200h       ; Zymeklis bus padetas i prieki
    mov cx, 0
    mov dx, difference ; Perstumiam zymekli per tiek poziciju, koks yra skirtumas tarp failo skaitmenu
    int 21h
    jnc can_LSEEK      ; Jeigu carry flag = 1, tai nepavyko perstumti zymeklio
    jmp cannot_LSEEK    
    can_LSEEK:
    mov bx, [handle2]
    mov ax, 4200h
    mov cx, 0
    mov dx, 0         ; Antram faile padedam zymekli i prieki
    int 21h
    jnc can_LSEEK2
    jmp cannot_LSEEK
    can_LSEEK2:
    jmp reading

    second_file_is_longer_or_equal:
    sub ax, read1
    mov difference, ax
    mov bx, [handle2]
    mov ax, 4200h
    mov cx, 0
    mov dx, difference
    int 21h
    jnc can_LSEEK3
    jmp cannot_LSEEK
    can_LSEEK3:
    mov bx, [handle1] 
    mov ax, 4200h
    mov cx, 0
    mov dx, 0
    int 21h
    jnc can_LSEEK4
    jmp cannot_LSEEK
    can_LSEEK4:
    jmp reading

reading:
    mov bx, [handle1]
    mov ah, 3Fh             ; Skaityti faila
    mov cx, 10h            ; Kiek baitu perskaityti
    mov dx, offset array1     
    int 21h 
    jnc can_read3               ; Jeigu carry neperskaitem
    jmp cannot_read
    can_read3:
    mov read, ax                  ; Kiek is tikruju perskaitem

    mov bx, [handle2]
    mov ah, 3Fh             
    mov cx, 10h            
    mov dx, offset array2  
    int 21h 
    jc cannot_read
    cmp read, ax            ; Jeigu antram faile perskaitem dar maziau, tada issiaugojam mazesni skaiciu
    jb skip 
    mov read, ax
    skip:
    mov cx, read

    call FUNCTION_AND

    jmp write_zeros      

write_zeros:
    cmp word ptr difference, 0
    je skip1
    call WRITING_ZEROS
    skip1:
    jmp write

write:
    mov bx, [handle3]     ; Rasymas i faila
    mov cx, read          ; Kiek baitu irasyti
    mov dx, offset array3
    mov ah, 40h
    int 21h
    jc cannot_write       ; Jeigu carry flag = 1, tai neirasem i faila
    cmp read, ax
    jne not_all_written   ; Jeigu irasem ne tiek, kiek perskaitem, pranesam vartotojui

    cmp read, 10h         ; Jeigu perskaitem 10h, tada vel kartojam skaitymo cikla
    je reading
    jmp successful        ; Kitu atveju viskas pavyko

; -----------------
; error messages
not_open:
    mov ah, 09h
    mov dx, offset not_opened_msg
    int 21h
    jmp close_first

not_created:
    mov ah, 09h
    mov dx, offset not_created_msg
    int 21h
    jmp close_first

cannot_LSEEK:
    mov ah, 09h
    mov dx, offset cannot_LSEEK_msg
    int 21h
    jmp close_first

cannot_read:
    mov ah, 09h
    mov dx, offset cannot_read_msg
    int 21h
    jmp close_first

cannot_write:
    mov ah, 09h
    mov dx, offset cannot_write_msg
    int 21h
    jmp close_first

not_all_written:
    mov ah, 09h
    mov dx, offset not_all_written_msg
    int 21h
    jmp close_first
;----------------

successful:
    mov ah, 09h
    mov dx, offset success_msg
    int 21h
    jmp close_first

close_first:
    mov bx, [handle1]
    or bx, bx ; cmp bx, 0
    jz close_second ; Jeigu neatidarytas failas, tada uzdarinejam sekanti
    mov ah, 3Eh ; Uzdarome faila
    int 21h
    jmp close_second

close_second:
    mov bx, [handle2]
    or bx, bx 
    jz close_third
    mov ah, 3Eh
    int 21h
    jmp close_third

close_third:
    mov bx, [handle3]
    or bx, bx 
    jz finish
    mov ah, 3Eh
    int 21h
    jmp finish

finish:
    mov ax, 4C00h      ; programos darbo pabaiga
    int 21h


;----------------------------------------------------------------------------------------------;
; Funkcija, kuri atlieka operaciją AND dviems skaiciams ir issaugo informacija masyve array3   ;
;----------------------------------------------------------------------------------------------;
FUNCTION_AND PROC        NEAR   
    push ax
    push bx

    mov di, 0

    ciklas:
    mov al, array1[di]
    mov bl, array2[di]
    AND al, bl
    mov array3[di], al
    inc di
    dec cx
    jnz ciklas

    pop bx
    pop ax
    ret
FUNCTION_AND ENDP

;----------------------------------------------------------------------------------------------------------;
; Funkcija, kuri atspausdina tiek nuliu failo pradzioje, koks yra skaitmenu skirtumas abiejuose failuose   ;
;----------------------------------------------------------------------------------------------------------;
WRITING_ZEROS PROC   NEAR
    mov cx, difference
    repeat4:
    push cx

    mov bx, [handle3]
    mov cx, 1h
    mov dx, offset zero
    mov ah, 40h
    int 21h
    jc cannot_write       ; Jeigu carry flag = 1, tai neirasem i faila

    pop cx

    dec cx
    jnz repeat4
    ret
WRITING_ZEROS ENDP

    end start