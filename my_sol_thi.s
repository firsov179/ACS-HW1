    .intel_syntax noprefix

    .equ    max_size, 1000                     # максимально разрешенная длина массива
    .equ    int_size, 4

    .section .rodata
message_incorrect_length:
    .string      "Incorrect length = %d\n"    # Сообщение о некорректной длине
B_msg:
    .string      "B:"                         # Формат начала вывода B
A_msg:
    .string      "A:"                         # Формат начала вывода A
format_elem:
    .string      " %d"                        # Формат для ввода/вывода числа
end_msg:
    .string      "\n"                         # перевод строки
errMessage:
    .ascii  "incorrect command line!\n"
    .ascii  "  Waited:\n"
    .string "     command infile outfile\n"
toRead:
    .string "r"
toWrite:
    .string "w"
    
    .section .data
array:
    .space max_size * int_size                # выделяем память для массива A
array_B:
    .space max_size * int_size                # выделяем память для массива B
length:
    .long   0
    
argc:
    .space  4
ifst:           # указатель на файл, открываемый файл для чтения
    .space  8
ofst:           # указатель на файл, открываемый файл для записи
    .space  8
    
    
#-------------------------------------------------------------------------------
# Подпрограмма ввода размера и элементов массива
.section .text
input_array:                                  # Ввод длины с заданными ограничениями
    push    rbp
    mov     rbp, rsp
    
    mov     rdi, ifst[rip]                    # указатель на файл
    lea     rsi, format_elem[rip]             # адрес формата числа
    lea     rdx, length[rip]                  # адрес n
    mov     rax, 0                            # ввод целых чисел
    call    fscanf
    
    cmp     dword ptr length[rip], 1          # если length < 1, то ввод некорректный
    jl      incorrect_length
    mov     r11, length[rip]                  # то ввод некорректный
    and     r11, 1
    cmp     r11, 1
    jge     incorrect_length                  # если length нечетное, то ввод некоректный 
    mov     r11, 0
    cmp     dword ptr length[rip], max_size   # если > выделенной области
    jle     loop_scan
    
incorrect_length: 
                                              # если length < 1 или length > max_size, то ввод некоректный
                                              # если length нечетное, то ввод некоректный
    lea     rdi, message_incorrect_length[rip]
    mov     rsi, length[rip]
    mov     eax, 0
    call    printf@PLT
    pop	rbp
    ret
    
loop_scan:                                    # ввод массива
    cmp     r11, length[rip]                  # проверка на окончание
    jge     scan_end                          # завершение ввода элементов
    push    r11
    push    rbx  
    
    mov     rdi, ifst[rip]                    # указатель на файл
    lea     rsi, format_elem[rip]             # адрес формата числа
    lea     rdx, array[rip]                   # адрес n
    shl     r11, 2
    add     rdx, r11
    mov     eax, 0   
    mov     rax, 0                            # ввод целых чисел
    call    fscanf
    
    pop     rbx
    pop     r11
    
    inc     r11                               # ++i
    jmp     loop_scan
    
scan_end:
    pop	rbp
    ret

    
#-------------------------------------------------------------------------------
# Подпрограмма получения элементов массива B
    .section .text
    .global  create_B
create_B:                                     # вывод массива на дисплей
    push    rbp
    mov     rbp, rsp  

    mov     r11, 0                            # Индексатор для прохода по массиву
    mov     r14, 0                            # Четность r11
start_step:
    lea     r12, array[rip]
    lea     r13, array_B[rip]
    cmp     r11, length[rip]
    jge     create_B_end
    cmp     r14, 1
    jge     even
    cmp     r14, 0
    jge     odd

even:                                         # Элемент в позиции A[2n + 1] -> B[2n]
    mov     eax, dword ptr [r11*4+r12]
    dec r11
    mov     dword ptr [r11*4+r13], eax
    inc r11
    jmp     end_step
    
odd:                                          # Элемент в позиции A[2n] -> B[2n + 1]           
    mov     eax, dword ptr [r11*4+r12]
    inc r11
    mov     dword ptr [r11*4+r13], eax
    dec r11
    jmp     end_step
    
end_step:                                     # Переход к новому элементу
    inc     r11
    inc     r14
    and     r14, 1                            # меняем с 1 на 0 или наоборот
    jmp     start_step
    
create_B_end:
    pop	rbp
    ret


#-------------------------------------------------------------------------------
# Подпрограмма вывода элементов массива A
    .section .text
    .global print_A
print_A:                                       # вывод массива А на дисплей
    push    rbp
    mov     rbp, rsp
    
    mov     rdi, ofst[rip]                     # указатель на файл
    lea     rsi, A_msg[rip]                    # формат вывода
    xor     eax, 0                             # вывод целых чисел
    call    fprintf@PLT    
    mov     r11, 0
    
    mov r11, 0


print_A_elem:                                    # Вывод i-го элемента
    lea     rbx, array[rip]
    cmp     r11, length[rip]
    jge     print_A_end                          # Если прошли все элементы, то закончить
    
    push r11
    push rbx
    mov     rdi, ofst[rip]                       # указатель на файл
    lea     rsi, format_elem[rip]                # формат вывода
    mov     rdx, [r11*4+rbx]                     # номер выводимого числа
    xor     eax, 0                               # вывод целых чисел
    call    fprintf@PLT    
    
    
    pop     rbx
    pop     r11
    inc     r11                                  # i++
    jmp     print_A_elem                         # Переход к следующему элементу
print_A_end:
    mov     rdi, ofst[rip]                     
    lea     rsi, end_msg[rip]                    # Перевод строки
    xor     eax, 0                             
    call    fprintf@PLT   
             
    pop	rbp
    ret

#-------------------------------------------------------------------------------
# Подпрограмма вывода элементов массива B
    .section .text
    .global print_B
print_B:                                       # вывод массива В на дисплей
    push    rbp
    mov     rbp, rsp  
    
    mov     rdi, ofst[rip]                     # указатель на файл
    lea     rsi, B_msg[rip]                    # формат вывода
    xor     eax, 0                             # вывод целых чисел
    call    fprintf@PLT    
    mov     r11, 0
    
print_B_elem:                                  # Вывод i-го элемента
    lea     rbx, array_B[rip]
    cmp     r11, length[rip]
    jge     print_B_end                        # Если прошли все элементы, то закончить
    
    push r11
    push rbx
    mov     rdi, ofst[rip]                     # указатель на файл
    lea     rsi, format_elem[rip]              # формат вывода
    mov     rdx, [r11*4+rbx]                   # номер выводимого числа
    xor     eax, 0                             # вывод целых чисел
    call    fprintf@PLT    
    
    pop     rbx
    pop     r11
    inc     r11                                # i++
    jmp     print_B_elem                       # Переход к следующему элементу
    
print_B_end:
    mov     rdi, ofst[rip]                     
    lea     rsi, end_msg[rip]                  # Перевод строки
    xor     eax, 0                             
    call    fprintf@PLT   
    
    pop	rbp
    ret


#-------------------------------------------------------------------------------
# Главная функция программы
    .section .text
    .global main
main:
    push    rbp
    mov     rbp, rsp
    
    mov r12, rdi
    mov r13, rsi

    cmp r12, 3                                # проверка количества аргументов
    je next
    lea     rdi, errMessage[rip]
    xor     eax, eax
    call    printf
    mov     eax, 0
    jmp     main_end
    
    
    
next:
                                              # Открытие файла для вовода
    mov     rdi, [r13+8]                      # имя открываемого файла
    lea     rsi, toRead[rip]                  # открыть для чтения
    mov     rax, 0
    call    fopen
    mov     ifst[rip], rax                    # сохранение указателя на файл
    
                                              # Открытие файла для вывода
    mov     rdi, [r13+16]                     # имя открываемого файла
    lea     rsi, toWrite[rip]                 # открыть для чтения
    mov     rax, 0
    call    fopen
    mov     ofst[rip], rax                    # сохранение указателя на файл
    
    call    input_array
    jnz     main_end
   
    call    create_B                          # получаем массив В из А
    call    print_A                           # вывод А в формате "A: 1 2 3 4"
    call    print_B                           # вывод B в формате "B: 2 1 4 3"

    
main_end: 
    mov     eax, 0
    mov     rsp, rbp                          # удалить локальные переменные
    pop     rbp                               # восстановить кадр вызывающего
    ret
    
