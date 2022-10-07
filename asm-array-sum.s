# Команды для компиляции, компоновки и запуска в gdb
# as --gstabs -o asm-array-sum.o asm-array-sum.s
# gcc asm-array-sum.o -o asm-array-sum
# ./asm-array-sum
#------------------------------------------------
# "asm-array-sum.s"
# Использование подпрограмм для демонстрации разделения по функциям
    .intel_syntax noprefix

    .equ    max_size, 10
    .equ    long_size, 4

    .section .rodata
message_length:
    .string      "Input length (0 < length <= %d): "
message_incorrect_length:
    .string      "Incorrect length = %d\n"
format_in_array_i:
    .string      "array[%d]? "
format_in:
    .string      "%d"
format_out_array_i:
    .string      "array[%d] = %d\n"
format_out_sum:
    .string      "summa = %d\n"

    #.section .bss
    .section .data
array:
    .space max_size*long_size
    #.comm   array, max_size*long_size
length:
    .long   0
i:
    .long   0
sum:
    .long   0

#------------------------------------------------
# Подпрограмма ввода элементов массива
    .section .text
    #.global array_input --- пока функции сделаны статическими (внутренними)
array_input:      # ввод массива с консоли
    push    rbp
    mov     rbp, rsp

    # Приглашение для ввода значения длины
    lea     rdi, message_length[rip]
    mov     rsi, max_size
    mov     eax, 0
    call    printf@PLT

   # Ввод длины в заданном диапазоне
    lea     rdi, format_in[rip]     # формат вывода
    lea     rsi, length[rip]        #  адрес для ввода
    mov     eax, 0                  # ввод целых чисел
    call    scanf@PLT

    # Проверка значения введенной длины
    cmp     dword ptr length[rip], 1
    jl      incorrect_length
    cmp     dword ptr length[rip], max_size   # если > выделенной области
    jle     ok
incorrect_length: # если < 1 или > max_size
    lea     rdi, message_incorrect_length[rip]
    mov     rsi, length[rip]
    mov     eax, 0
    call    printf@PLT
    mov     rax, 1
    jmp     end_incorrect_input

ok:         # Цикл ввода элементов массива
    mov     dword ptr i[rip], 0               # i: обнуление
loop_scan:
    mov     ecx, i[rip]             # временное использование
    cmp     ecx, length[rip]        # проверка на окончание
    jge     end_loop_scan           # завершение ввода элементов
    push    rcx                     # сохранение текущего i
    push    rbx                     # сохранение адреса массива
    lea     rdi, format_in_array_i[rip] # приглашение к вводу
    mov     esi, ecx                #  индекс элемента массива
    mov     eax, 0
    call    printf@PLT
    mov     ecx, i[rip]             # i: восстановление после printf
    shl     ecx, 2                  # получение сдвига от значения i
    lea     rbx, array[rip]         # адрес начала массива
    lea     rdi, format_in[rip]     # формат вывода
    lea     rsi, array[rip]         #  адрес для ввода
    add     rsi, rcx
    mov     eax, 0                  # ввод целых чисел
    call    scanf@PLT
    pop     rbx                     # адреса массива
    pop     rcx                     # восстановление i
    inc     dword ptr i[rip]                  # ++i
    jmp     loop_scan
end_loop_scan:
    mov	eax, 0                      # it's OK

end_incorrect_input:
    pop	rbp
    ret

#------------------------------------------------
# Подпрограмма вывода элементов массива
    .section .text
    #.global array_output --- пока функции сделаны статическими (внутренними)
array_output:      # вывод массива на дисплей
    push    rbp
    mov     rbp, rsp

    # Вывод массива
    mov     dword ptr i[rip], 0
loop_print:
    mov     ecx, i[rip]
    mov     edx, length[rip]
    lea     rbx, array[rip]
    cmp     ecx, edx
    jge     end_loop_print
    lea     rdi, format_out_array_i[rip] # формат вывода
    mov     esi, i[rip]             #  индекс числа
    mov     rdx, [rcx*4+rbx]        #  выводимое число
    mov     eax, 0                  # вывод целых чисел
    call    printf@PLT
    inc     dword ptr i[rip]
    jmp     loop_print
end_loop_print:

    mov	eax, 0                      # it's OK
    pop	rbp
    ret

#------------------------------------------------
# Подпрограмма суммирования элементов массива
    .section .text
    #.global array_sum --- пока функции сделаны статическими (внутренними)
array_sum:
    push    rbp
    mov     rbp, rsp

    # Цикл суммирования элементов массива
    mov     ecx, 0                  # i
    lea     rbx, array[rip]         # адрес начала массива
    mov     eax, 0                  # sum
loop_sum:
    cmp     ecx, length[rip]
    jge     end_loop_sum
    add     eax, [rbx+rcx*4]
    inc     rcx
    jmp     loop_sum
end_loop_sum:
    mov     sum[rip], eax

    mov	eax, 0                      # it's OK
    pop	rbp
    ret

#------------------------------------------------
# Главная функция программы
    .section .text
    .global main
main:
    push    rbp
    mov     rbp, rsp

    # Вызов подпрограммы ввода элементов массива
    call    array_input
    jnz     end

    # Вызов подпрограммы вычисления суммы
    call    array_sum

    # Вызов подпрограммы вывода элементов массива
    call    array_output

    # Вывод суммы
    lea     rdi, format_out_sum[rip] # формат вывода
    mov     esi, sum[rip]           #  выводимое число
    mov     eax, 0                  # вывод целых чисел
    call    printf@PLT

end:
    mov	eax, 0
    mov     rsp, rbp            # удалить локальные переменные
    pop     rbp                 # восстановить кадр вызывающего
    ret
