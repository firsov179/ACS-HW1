    .intel_syntax noprefix

    .equ    max_size, 100 # максимально разрешенная длина массива
    .equ    int_size, 4

    .section .rodata
message_incorrect_length:
    .string      "Incorrect length = %d\n"
format_in:
    .string      "%d"
B_msg:
    .string      "\nB:"
A_msg:
    .string      "A:"
format_elem:
    .string      " %d"
end_msg:
    .string      "\n"
    .section .data
array:
    .space max_size * int_size # выделяем память для массива A
array_B:
    .space max_size * int_size # выделяем память для массива B
length:
    .long   0

    .section .text
    .global main
main:
    push    rbp
    mov     rbp, rsp

    # Ввод длины в заданном диапазоне
    lea     rdi, format_in[rip]     # формат вывода
    lea     rsi, length[rip]        #  адрес для ввода
    mov     eax, 0                  # ввод целых чисел
    call    scanf@PLT
    # Проверка значения введенной длины
    cmp     dword ptr length[rip], 1
    jl      incorrect_length
    # если length < выделенной области, то ввод корректный
    cmp     dword ptr length[rip], max_size   
    mov     r11, 0
    jle     loop_scan
incorrect_length: 
    # если length < 1 или length > max_size, то ввод некоректный
    lea     rdi, message_incorrect_length[rip]
    mov     rsi, length[rip]
    mov     eax, 0
    call    printf@PLT
    jmp     end
    
loop_scan:
    # ввод массива

    cmp     r11, length[rip]        # проверка на окончание
    jge     start_change_array              # завершение ввода элементов
    push    r11
    push    rbx  
    lea     rbx, array[rip]         # адрес начала массива
    lea     rdi, format_in[rip]     # формат вывода
    lea     rsi, array[rip]         #  адрес для ввода
    shl     r11, 2
    add     rsi, r11
    mov     eax, 0                  # ввод целых чисел
    call    scanf@PLT
    pop     rbx
    pop     r11
    
    inc     r11                     # ++i
    jmp     loop_scan

start_change_array:
    mov     r11, 0 # Индексатор для прохода по массиву
    mov     r14, 0 # Четность r11
start:
    # Получание В из А
    lea     r12, array[rip]
    lea     r13, array_B[rip]
    cmp     r11, length[rip]
    jge     start_loop_print_A
    cmp     r14, 1
    jge     even
    cmp     r14, 0
    jge     odd

    
even:
    #  Элемент с позиции A[2n + 1] -> B[2n]
    mov     eax, dword ptr [r11*4+r12]
    dec r11
    mov     dword ptr [r11*4+r13], eax
    inc r11
    jmp     finish
    
odd:
    #  Элемент с позиции A[2n] -> B[2n + 1]
    mov     eax, dword ptr [r11*4+r12]
    inc r11
    mov     dword ptr [r11*4+r13], eax
    dec r11
    jmp     finish
    
finish:
    # Переход к новому элементу
    inc     r11
    inc     r14
    and     r14, 1
    jmp     start
     
     
start_loop_print_A:

    lea     rdi, A_msg[rip]
    call    printf@PLT # Выводим конец строки
    mov r11, 0


loop_print_A: 
    # Вывод A
    mov     edx, length[rip]
    lea     rbx, array[rip]
    cmp     r11, length[rip]
    jge     start_loop_print_B
    lea     rdi, format_elem[rip]     # формат вывода
    mov     rsi, [r11*4+rbx]         # выводимое число
    mov     eax, 0                  
    push    r11
    push    rbx  
    call    printf@PLT
    pop     rbx
    pop     r11
    inc     r11
    jmp     loop_print_A
    
start_loop_print_B:
    lea     rdi, B_msg[rip]
    call    printf@PLT
    mov     r11, 0
loop_print_B:
    # Вывод B
    mov     edx, length[rip]
    lea     rbx, array_B[rip]
    cmp     r11, length[rip]
    jge     end
    lea     rdi, format_elem[rip]     # формат вывода
    mov     rsi, [r11*4+rbx]         # выводимое число
    mov     eax, 0                  
    push    r11
    push    rbx 
    call    printf@PLT
    pop     rbx
    pop     r11
    inc     r11
    jmp     loop_print_B
end: 
    lea     rdi, end_msg[rip]
    call    printf@PLT
    mov     eax, 0
    mov     rsp, rbp            # удалить локальные переменные
    pop     rbp                 # восстановить кадр вызывающего
    ret
    