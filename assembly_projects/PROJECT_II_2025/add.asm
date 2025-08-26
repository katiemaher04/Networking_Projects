;x86_64 Assembly Project
;By: Katie Maher (c00294512)
;Converted from 68000 Assembly program
;Completed 29/04/25

SECTION .data
PROMPT         db 'Enter number: ', 0
RESULT         db 'The sum is: ', 0
FINAL_RESULT   db 'Final sum is: ', 0
CRLF           db 0x0D, 0x0A, 0
ERR_INVALID    db 'Error: Invalid input (must be a positive number)', 0x0D, 0x0A, 0
ERR_OVERFLOW   db 'Error: Number out of range (max 4294967295)', 0x0D, 0x0A, 0

SECTION .bss
sinput         resb 255        ; Input buffer for user input
buffer         resb 16         ; Output buffer (handles 4294967295, 10 digits)
D1             resd 1          ; First input/sum (32-bit unsigned, was D1.L)
D2             resd 1          ; Second input (32-bit unsigned, was D2.L)
D3             resd 1          ; Running sum (32-bit unsigned, was D3.L)
D4             resw 1          ; Loop counter (16-bit, was D4.W)

global _start
section .text
_start:
    ; CLR.L D3
    xor     eax, eax
    mov     dword [D3], eax        ; Clear running sum

    ; MOVE.W #3, D4
    mov     word [D4], 3           ; Set loop counter to 3
GAME_LOOP:
    ; MOVE.B #14, D0
    ; LEA PROMPT, A1
    ; TRAP #15
    mov     rdi, PROMPT
    call    sprint                 ; Display prompt

    ; MOVE.B #4, D0
    ; TRAP #15
    ; MOVE.L D1, D2
    call    read_and_convert
    jc      .error                 ; Handle invalid input
    mov     dword [D2], eax        ; MOVE.L result, D2

    ; MOVE.B #14, D0
    ; LEA PROMPT, A1
    ; TRAP #15
    mov     rdi, PROMPT
    call    sprint                 ; Display prompt again

    ; MOVE.B #4, D0
    ; TRAP #15
    call    read_and_convert
    jc      .error                 ; Handle invalid input
    mov     dword [D1], eax        ; MOVE.L result, D1

    ; BSR REGISTER_ADDER
    call    REGISTER_ADDER

    ; ADD.L D1, D3
    mov     eax, [D1]
    add     dword [D3], eax        ; Add D1 to running sum

    ; MOVE.B #14, D0
    ; LEA RESULT, A1
    ; TRAP #15
    mov     rdi, RESULT
    call    sprint                 ; Display "The sum is: "

    ; MOVE.B #3, D0
    ; TRAP #15
    mov     edi, [D3]
    call    iprintLF               ; Print partial sum with newline

    ; SUBQ.W #1, D4
    dec     word [D4]              ; Decrement loop counter

    ; BNE GAME_LOOP
    cmp     word [D4], 0
    jne     GAME_LOOP              ; Loop if D4 != 0

    ; MOVE.B #14, D0
    ; LEA FINAL_RESULT, A1
    ; TRAP #15
    mov     rdi, FINAL_RESULT
    call    sprint                 ; Display "Final sum is: "

    ; MOVE.L D3, D1
    ; MOVE.B #3, D0
    ; TRAP #15
    mov     edi, [D3]
    call    iprintLF               ; Print final sum with newline

    ; SIMHALT
    xor     rdi, rdi
    call    quit                   ; Exit with status 0

.error:
    ; Exit with error status
    mov     rdi, 1
    call    quit

; --- Subroutines ---

; REGISTER_ADDER: Adds D2 to D1
; Input: D1, D2 (memory)
; Output: D1 = D1 + D2
REGISTER_ADDER:
    ; ADD.L D2, D1
    mov     eax, [D2]
    add     dword [D1], eax        ; D1 += D2
    ; RTS
    ret

; --- Helper Functions ---

; sprint: Print null-terminated string
; Input: RDI = string pointer
sprint:
    push    rbx
    push    rsi
    push    rdx

    mov     rsi, rdi               ; RSI = string pointer
    call    slen                   ; Get string length in RAX
    mov     rdx, rax               ; RDX = length
    mov     rax, 1                 ; sys_write
    mov     rdi, 1                 ; FD 1 (stdout)
    syscall                        ; Write string

    pop     rdx
    pop     rsi
    pop     rbx
    ret


; slen: Compute length of null-terminated string
; Input: RSI = string pointer
; Output: RAX = length
slen:
    xor     rax, rax            ; length = 0
.nextchar:
    cmp     byte [rsi + rax], 0 ; check for null terminator
    je      .done
    inc     rax
    jmp     .nextchar
.done:
    ret


; read_and_convert: Read input and convert to integer
; Output: EAX = converted number, carry flag set on error
; read_and_convert: Read input and convert to integer
; Output: EAX = converted number, carry flag set on error
read_and_convert:
    push    rbx
    push    rsi
    push    rdx
    push    rcx

    ; Clear the input buffer before reading
    mov     rbx, sinput
    mov     rcx, 255               ; Clear up to 255 bytes
.clear_buffer:
    mov     byte [rbx], 0
    inc     rbx
    loop    .clear_buffer

    ; Read input (limit to 10 digits max)
    mov     rax, 0                 ; sys_read
    mov     rdi, 0                 ; FD 0 (stdin)
    mov     rsi, sinput            ; Buffer
    mov     rdx, 11                ; Read up to 11 bytes (10 digits + newline)
    syscall

    ; Check if read was successful
    cmp     rax, 0
    jle     .invalid_input         ; EOF or error

    ; Check if input is too long (no newline within 11 bytes)
    cmp     rax, 11
    je      .flush_excess          ; If exactly 11 bytes, may lack newline

    ; Find and null-terminate at newline
    mov     rbx, sinput
    mov     rcx, rax               ; Number of bytes read
    xor     rdx, rdx               ; Index
.find_newline:
    cmp     byte [rbx + rdx], 0x0A
    je      .replace_newline
    inc     rdx
    cmp     rdx, rcx
    jb      .find_newline
    jmp     .flush_excess          ; No newline found, consume excess

.replace_newline:
    mov     byte [rbx + rdx], 0    ; Replace newline with null

    ; Convert to integer
    mov     rdi, sinput
    call    atoi
    jc      .handle_error          ; If carry flag set, error (invalid or overflow)

    ; Ensure no excess input remains in stdin
    call    flush_stdin
    pop     rcx
    pop     rdx
    pop     rsi
    pop     rbx
    ret

.flush_excess:
    ; Input too long or no newline, consume all remaining input
    call    flush_stdin
    jmp     .invalid_input

.invalid_input:
    mov     rdi, ERR_INVALID
    call    sprint
    stc                            ; Set carry flag
    call    flush_stdin            ; Ensure stdin is clear before reprompt
    pop     rcx
    pop     rdx
    pop     rsi
    pop     rbx
    jmp     GAME_LOOP              ; Restart the loop

.handle_error:
    cmp     eax, 1
    je      .overflow
    mov     rdi, ERR_INVALID
    jmp     .print_error

.overflow:
    mov     rdi, ERR_OVERFLOW
.print_error:
    call    sprint
    stc
    call    flush_stdin            ; Ensure stdin is clear
    pop     rcx
    pop     rdx
    pop     rsi
    pop     rbx
    jmp     GAME_LOOP              ; Restart the loop

; flush_stdin: Consume all remaining input in stdin until newline or EOF
flush_stdin:
    push    rax
    push    rdi
    push    rsi
    push    rdx
    push    rcx
    push    rbx

    mov     rax, 0                 ; sys_read
    mov     rdi, 0                 ; FD 0 (stdin)
    mov     rsi, sinput            ; Reuse sinput buffer
    mov     rdx, 255               ; Read up to 255 bytes
.read_loop:
    syscall
    cmp     rax, 0
    jle     .done                  ; EOF or error, stop
    mov     rcx, rax               ; Bytes read
    mov     rbx, sinput
    xor     rdx, rdx
.check_newline:
    cmp     byte [rbx + rdx], 0x0A
    je      .done                  ; Newline found, stop
    inc     rdx
    cmp     rdx, rcx
    jb      .check_newline
    jmp     .read_loop             ; No newline, read more

.done:
    pop     rbx
    pop     rcx
    pop     rdx
    pop     rsi
    pop     rdi
    pop     rax
    ret




; atoi: Convert string to unsigned 32-bit integer
; Input: RDI = string pointer
; Output: EAX = converted number, carry flag set on error
;         EAX = 1 on overflow, 0 on invalid input
atoi:
    push    rbx
    push    rcx
    push    rdx

    mov     rbx, rdi               ; Save string pointer
    xor     eax, eax               ; Clear result (EAX = 0)
    xor     rcx, rcx               ; Clear digit count

    ; Check for empty string
    cmp     byte [rdi], 0
    je      .invalid               ; If empty, it's invalid

    ; Reject minus sign
    cmp     byte [rdi], '-'
    je      .invalid               ; If minus, it's invalid

.convert_loop:
    mov     dl, [rdi]
    cmp     dl, 0                  ; Check for null terminator
    je      .done

    ; Validate digit (only '0' to '9')
    cmp     dl, '0'
    jb      .invalid               ; If not '0'-'9', invalid
    cmp     dl, '9'
    ja      .invalid               ; If not '0'-'9', invalid
    sub     dl, '0'                ; Convert ASCII to integer

    ; Check for overflow due to too many digits (unsigned)
    cmp     rcx, 9                 ; Max digits reached (0-9)
    jae     .overflow              ; If more than 9 digits, it's overflow

    ; EAX = EAX * 10 + digit
    mov     r8d, eax
    shl     eax, 2
    add     eax, r8d
    add     eax, eax
    add     eax, edx

    inc     rcx
    inc     rdi
    jmp     .convert_loop

.done:
    ; Check if the number exceeds the max unsigned 32-bit value
    cmp     eax, 4294967295        ; Check if the number exceeds the 32-bit unsigned limit
    ja      .overflow              ; If it does, it's overflow

    ; No extra characters after the number
    cmp     byte [rdi], 0
    je      .success
    jmp     .invalid

.success:
    clc                            ; Clear carry flag (success)
    pop     rdx
    pop     rcx
    pop     rbx
    ret

.invalid:
    xor     eax, eax               ; Return 0 for invalid
    stc                            ; Set carry flag
    pop     rdx
    pop     rcx
    pop     rbx
    ret

.overflow:
    mov     eax, 1                 ; Return 1 for overflow
    stc
    pop     rdx
    pop     rcx
    pop     rbx
    ret



; iprintLF: Print unsigned integer with newline
; Input: EDI = integer
iprintLF:
    push    rax
    push    rbx
    push    rcx
    push    rdx
    push    rsi

    mov     eax, edi               ; Number to print
    mov     rcx, 10                ; Divisor
    mov     rsi, buffer + 15
    mov     byte [rsi], 0          ; Null terminator
    dec     rsi

.convert:
    xor     edx, edx
    div     rcx
    add     dl, '0'
    mov     [rsi], dl
    dec     rsi
    test    eax, eax
    jnz     .convert

    inc     rsi
    mov     rdi, rsi
    call    sprint                 ; Print number

    mov     rdi, CRLF
    call    sprint                 ; Print newline

    pop     rsi
    pop     rdx
    pop     rcx
    pop     rbx
    pop     rax
    ret

; quit: Exit program
; Input: RDI = exit status
quit:
    mov     rax, 60                ; sys_exit
    syscall
    ret

