;
; Multiboot
;
section .multiboot
  align 4

  ; Constants
  MBALIGN   equ 1<<0
  MEMINFO   equ 1<<1
  VIDINFO   equ 1<<2
  FLAGS     equ MBALIGN | MEMINFO | VIDINFO
  MAGIC     equ 0x1BADB002
  CHECKSUM  equ -(MAGIC + FLAGS)

  ; Header
  dd MAGIC
  dd FLAGS
  dd CHECKSUM
  dd 0x00000000 
  dd 0x00000000
  dd 0x00000000
  dd 0x00000000
  dd 0x00000000
  dd 0x00000000
  dd 0
  dd 0
  dd 32

;
; Text
;
section .text

  ; Global
  global start

  ; Extern
  extern END_OF_KERNEL
  extern kmain

  ; Entry point
  start:
    cli                       ; Disable interrupts
    mov esp, stack.top        ; Setup kernel stack
    push ebx                  ; Push multiboot pointer
    push dword END_OF_KERNEL  ; Push end of kernel
    call kmain                ; Action!
  .hang:
    cli                       ; Disable interrupts
    hlt                       ; Halt
    jmp .hang                 ; Repeat

;
; Uninitialized data
;
section .bss

  ; Stack
  stack:
    resb 16384 ; 16 KiB
  .top: