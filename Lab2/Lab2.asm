section .data
x dd 0 ; длина числа (количество разрядов)
i dd 0
j dd 0
x1 dd 0
n dd 2 ; основание системы счисления
num dd 0 ; переменная, в которой хранится число
m1 dd 1 ; переменная, в которой хранится разряд числа
m2 dd 1
ms_e dd 10 ; номер символа «перенос строки» в таблице ; ASCII

section .text
global _start
_start:
	mov r14d, 0x0deadbeef        ; заносим число
	mov dword [num], r14d
	mov byte [i], 3
	mov byte [j], 4
	mov eax, dword [num]
;Вывод значения до преобразований
	mov edx, 0
	loop1: ; занесение цифр в стек
		div dword [n]
		push rdx
		inc dword [x1]
		mov edx, 0
		sub eax, 0
		jnz loop1 ;
	loop2:
		pop r10 ; извлечение цифр из стека
		add r10d, 48 ; перевод символов в цифры
		mov [m2], r10d
		dec dword [x1]
		mov rax, 1
		mov rdi, 1
		mov rsi, m2
		mov rdx, 1
		syscall ; вывод на экран
		sub dword [x1], 0 ; проверка конца цикла
		jnz loop2
	mov rsi, ms_e
	mov rdx, 1
	syscall
	
	mov bh, 0                       ; счетчик для первого цикла, i
	for1:
	mov dl, 8
	mov al, bh
	mul dl                     ; 8 * i
	mov dl, 24
	sub dl, al              ; 24 - 8 * i
	mov cl, dl 
	mov r10d,  [num]       ; заносим число
	shr r10, cl                           
	and r10, 0x0FF     ; значение левого байта
	

	mov r11, r10       ; заносим левый байт
	and r11, 0x0F         ; (b & 0xF) - правая тетрада
	mov rdx, r11    
	
	mov r11, r10       ; заносим левый байт
	mov cl, 4
	shr r11, cl
	and r11, 0x0F       ; (b >> 4) & 0xF) - левая тетрада
	mov rax, r11

	cmp rdx, rax      ; сравниваем тетрады для получения неотрицательной разности
	jg lab1
	sub rax, rdx
	mov rdx, rax
	jmp lab2
	lab1:                     
	sub rdx, rax
	lab2:
	mov r11, rdx      ; разность тетрад
	
	mov bl, bh						 ; счетчик для второго цикла, j
	inc bl    ; j = i + 1
	for2:
		
		mov dl, 8
		mov al, bl
		mul dl                     ; 8 * j
		mov dl, 24
		sub dl, al              ; 24 - 8 * j
		mov cl, dl 
		mov r12d, [num]       ; заносим число
		shr r12, cl                            
		and r12, 0x0FF        ; правый байт
		
		
		mov r13, r12       ; заносим правый байт
		and r13, 0x0F         ; (b2 & 0xF)  правая тетрада
		mov rdx, r13    
		
		mov r13, r12       ; заносим правый байт
		mov cl, 4
		shr r13, cl
		and r13, 0x0F       ; (b2 >> 4) & 0xF) левая тетрада
		mov rax, r13

		cmp rdx, rax
		jg lab3
		sub rax, rdx
		mov rdx, rax
		jmp lab4
		lab3:                     
		sub rdx, rax
		lab4:
		mov r13, rdx   ; разность тетрад
		
		
		cmp r13, r11       ; сравнение разностей
		jle lab5
		
		
		mov r8, 0x0FFFFFF00
		mov dl, 8
		mov al, bh
		mul dl                     ; 8 * i
		mov dl, 24
		sub dl, al              ; 24 - 8 * i
		mov cl, dl 
		shl r8, cl                 ;  0xFFFFFF00 << (24 - 8 * i)
		
		
		mov r9, 0x0FFFFFF00
		mov dl, 8
		mov al, bh
		mul dl            ; 8 * i
		add al, 8        ; 8 + 8 * i
		mov cl, al
		shr r9, cl        ; 0xFFFFFF00 >> (8 + 8 * i)
		
		or r8, r9
		and  [num], r8d      ; N &= (0xFFFFFF00 << (24 - 8 * i) | 0xFFFFFF00 >> (8 + 8 * i))

		mov r8, 0x0FFFFFF00
		mov dl, 8
		mov al, bl
		mul dl                     ; 8 * j
		mov dl, 24
		sub dl, al              ; 24 - 8 * j
		mov cl, dl 
		shl r8, cl                 ;  0xFFFFFF00 << (24 - 8 * j)
		
		
		mov r9, 0x0FFFFFF00
		mov dl, 8
		mov al, bl
		mul dl            ; 8 * j
		add al, 8        ; 8 + 8 * j
		mov cl, al
		shr r9, cl        ; 0xFFFFFF00 >> (8 + 8 * j)
		
		or r8, r9
		and [num], r8d     ; N &= (0xFFFFFF00 << (24 - 8 * j) | 0xFFFFFF00 >> (8 + 8 * j))

		mov dl, 8
		mov al, bh
		mul dl                     ; 8 * i
		mov dl, 24
		sub dl, al              ; 24 - 8 * i
		mov cl, dl
		mov r15, r12
		shl r15, cl
		or [num], r15d      ; N |= (b2 << (24 - 8 * i))
	
		mov dl, 8
		mov al, bl
		mul dl                     ; 8 * j
		mov dl, 24
		sub dl, al              ; 24 - 8 * j
		mov cl, dl
		mov r15, r10
		shl r15, cl
		or [num], r15d      ; N |= (b << (24 - 8 * j))
		
		mov r10, r12   ;b = b2
		mov r11, r13   ; raz = raz2;
		
		lab5:
		inc bl
		cmp bl, [j]
		jl for2

inc bh
cmp bh, [i]
jl for1

mov eax, [num]
;Вывод получившегося значения
	mov edx, 0
	loop3: ; занесение цифр в стек
		div dword [n]
		push rdx
		inc dword [x1]
		mov edx, 0
		sub eax, 0
		jnz loop3 ;
	loop4:
		pop r10 ; извлечение цифр из стека
		add r10d, 48 ; перевод символов в цифры
		mov [m2], r10d
		dec dword [x1]
		mov rax, 1
		mov rdi, 1
		mov rsi, m2
		mov rdx, 1
		syscall ; вывод на экран
		sub dword [x1], 0 ; проверка конца цикла
		jnz loop4
	mov rsi, ms_e
	mov rdx, 1
	syscall
	mov eax, 60
	xor rdi, rdi
	syscall
