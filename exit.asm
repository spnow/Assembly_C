section .text  ; start code section of assembly
global _start
_start:        ; keeps the linker from complaining or guessing
xor eax, eax   ; shortcut to zero out the eax register (safely)
xor ebx, ebx   ; shortcut to zero out the ebx register
mov al, 0x01   ; set the syscall # to 1 for exit()
int 0x80       ; call kernel to execute syscall

