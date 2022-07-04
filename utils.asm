extern _system
extern _printf

global byte_to_string
global set_cursor_position
global save_cursor_position
global restore_cursor_position
global stop_cursor_blinking
global hide_cursor
global clear_console

section .data

systemarg_cls	db	"cls", 0x00

ansidata01	db	0x1B, 0x5B
		db	0x30, 0x30, 0x30, 0x30, 0x31
		db	0x3B
		db	0x30, 0x30, 0x30, 0x30, 0x31
		db	0x48, 0x00
		db	0x00				; Set the cursor position

ansidata02	db	0x1B, 0x37, 0x00, 0x00		; Save the cursor position
ansidata03	db	0x1B, 0x38, 0x00, 0x00		; Restore the cursor position

ansidata04	db	0x1B, "[?12l", 0x00, 0x00	; Stop blinking the cursor
ansidata05	db	0x1B, "[?25l", 0x00, 0x00	; Hide the cursor

section .bss

array		resb	0x04

section .text

byte_to_string:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]	; byte to convert
	mov	ebx, dword [ebp + 0x0C]	; address of array
	mov	ecx, 0x03		; array offset

.while_loop:
	mov	edx, 0x00		; reset edx ready for div
	push	ebx
	mov	ebx, 0x0A
	div	ebx			; divide eax by 0x0A
	pop	ebx
	add	edx, 0x30
	mov	[ebx + ecx], byte dl	; move remainder to array+offset
	dec	ecx			; decrease offset
	cmp	eax, 0x0A		; continue loop if eax >= 0x0A
	jae	.while_loop

	add	eax, 0x30
	mov	[ebx + ecx], byte al	; add last divide result to array

	mov	esp, ebp
	pop	ebp
	ret

set_cursor_position:
	push	ebp,
	mov	ebp, esp

	mov	[array], dword 0x31303030

	push	array
	push	dword [ebp + 0x08]
	call	byte_to_string
	add	esp, 0x08

	mov	eax, dword [array]
	mov	[ansidata01 + 0x09], eax

	mov	[array], dword 0x31303030

	push	array
	push	dword [ebp + 0x0C]
	call	byte_to_string
	add	esp, 0x08

	mov	eax, dword [array]
	mov	[ansidata01 + 0x03], eax

	push	ansidata01
	call	_printf
	add	esp, 0x04

	mov	esp, ebp
	pop	ebp
	ret

save_cursor_position:
	push	ansidata02
	call	_printf
	add	esp, 0x04
	ret

restore_cursor_position:
	push	ansidata03
	call	_printf
	add	esp, 0x04
	ret

stop_cursor_blinking:
	push	ansidata04
	call	_printf
	add	esp, 0x04
	ret

hide_cursor:
	push	ansidata05
	call	_printf
	add	esp, 0x04
	ret

clear_console:
	push	systemarg_cls
	call	_system
	add	esp, 0x04
	ret

