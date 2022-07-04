extern _printf
extern _memset
extern set_cursor_position
extern print_char_at_position
extern save_cursor_position
extern restore_cursor_position
extern stop_cursor_blinking
extern hide_cursor
extern clear_console

global print

section .data

	screen_width	equ	0x10
	screen_height	equ	0x10
	screen_length	equ	screen_width * screen_height

	string		db	"Hello", 0x00, 0x00, 0x00
	string2		db	"@", 0x00, 0x00, 0x00

section .bss

	screen_buffer	resb	screen_length

section .text

print:
	push	ebp
	mov	ebp, esp

	call	stop_cursor_blinking
	call	hide_cursor
	call	clear_console

	push	screen_length	; Fill the screen buffer
	push	0x2E		; "."
	push	screen_buffer
	call	_memset
	add	esp, 0x0C

	push	screen_buffer	; Print the screen buffer
	call	_printf
	add	esp, 0x04

	push	string2
	push	dword 0x02
	push	dword 0x03
	call	print_char_at_position
	add	esp, 0x0C

	;call	save_cursor_position

	;push	dword 0x02
	;push	dword 0x02
	;call	set_cursor_position
	;add	esp, 0x08

	;push	string
	;call	_printf
	;add	esp, 0x04

	;call	restore_cursor_position

	mov	esp, ebp
	pop	ebp
	ret

