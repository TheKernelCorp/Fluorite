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
  extern kearly
  extern kmain

  ; StartInfo structure
  struc StartInfo
    .multiboot_ptr: resd 1
    .end_of_kernel: resd 1
    .size:
  endstruc

  ; Entry point
  start:
    cli                       ; Disable interrupts
    mov esp, stack.top        ; Setup kernel stack
    mov [startinfo + StartInfo.multiboot_ptr], ebx
    mov [startinfo + StartInfo.end_of_kernel], dword END_OF_KERNEL
    push ebp                  ; Save old call frame
    mov ebp, esp              ; Init new call frame
    push startinfo            ; Push start info
    call kearly               ; Call kearly
    mov esp, ebp              ; Clear call frame
    pop ebp                   ; Restore call frame
    call kmain                ; Call kmain
  .hang:
    cli                       ; Disable interrupts
    hlt                       ; Halt
    jmp .hang                 ; Repeat
  
  ;
  ; Glue
  ;

  global glue_flush_gdt
  glue_flush_gdt:
    jmp 0x08:.flush
  .flush:
    ret

;
; Uninitialized data
;
section .bss

  ; Stack
  stack:
    resb 16384 ; 16 KiB
  .top:

  ; StartInfo
  startinfo:
    resb StartInfo.size