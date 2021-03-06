extern _system
extern _printf
extern _memset

global print

section .data
	
	screen_width	equ	0x10
	screen_height	equ	0x10
	screen_length	equ	screen_width * screen_height
	
	systemarg_cls	db	"cls", 0x00
	
	newline			db	0x0A, 0x00, 0x00, 0x00
	
	format1			db	"%s", 0x00, 0x00
	format2			db	"%x", 0x00, 0x00
	format3			db	"%X", 0x00, 0x00
	format4			db	"%d", 0x00, 0x00
	format5			db	"%u", 0x00, 0x00
	
	string1			db	"Hello", 0x00, 0x00, 0x00
	string2			db	"Goodbye", 0x00
	string3			db	"123", 0x00
	string4			db	"X", 0x00, 0x00, 0x00
	string5			db	".....", 0x00, 0x00, 0x00
	
	ansimod01		db	0x1B, 0x5B
					db	0x30, 0x30, 0x30, 0x30, 0x31
					db	0x3B
					db	0x30, 0x30, 0x30, 0x30, 0x31
					db	0x48, 0x00
					db	0x00	; Set y x
					
	ansimod02		db	0x1B, 0x5B
					db	0x30, 0x30, 0x30, 0x30, 0x31
					db	0x44, 0x00
					db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; Move left
	
	ansimod03		db	0x1B, 0x5B
					db	0x30, 0x30, 0x30, 0x30, 0x31
					db	0x43, 0x00
					db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; Move right
	
	ansimod04		db	0x1B, 0x5B
					db	0x30, 0x30, 0x30, 0x30, 0x31
					db	0x41, 0x00
					db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; Move up

	ansimod05		db	0x1B, 0x5B
					db	0x30, 0x30, 0x30, 0x30, 0x31
					db	0x42, 0x00
					db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; Move down

	ansimod06		db	0x1B, 0x4D, 0x00, 0x00	; RI
	
	ansimod07		db	0x1B, 0x37, 0x00, 0x00	; Save
	ansimod08		db	0x1B, 0x38, 0x00, 0x00	; Restore
	
	ansimod09		db	0x1B, 0x5B, 0x73, 0x00	; Save
	ansimod10		db	0x1B, 0x5B, 0x75, 0x00	; Restore
	
	ansimod11		db	0x1B, "[?12l", 0x00
	ansimod12		db	0x1B, "[?25l", 0x00

section .bss

	screen_buffer	resb	screen_length
	
section .text

print:
	push	ebp
	mov		ebp, esp
	
	push	ansimod11
	call	_printf
	add		esp, 0x04
	
	push	ansimod12
	call	_printf
	add		esp, 0x04
	
	push	systemarg_cls
	call	_system
	add		esp, 0x04
	
	push	screen_length
	push	0x2E
	push	screen_buffer
	call	_memset
	add		esp, 0x0C
	
	push	screen_buffer
	call	_printf
	add		esp, 0x04
	
	push	ansimod09
	call	_printf
	add		esp, 0x04
	
	mov		eax, 0x00
	
.loop:
	push	eax
	
	push	screen_length
	push	0x2E
	push	screen_buffer
	call	_memset
	add		esp, 0x0C

	push	ansimod01
	call	_printf
	add		esp, 0x04

	pop		eax
	mov		[screen_buffer + eax], byte 0x23
	push	eax

	push	screen_buffer
	call	_printf
	add		esp, 0x04
	
	pop		eax
	add		eax, screen_width
	cmp		eax, screen_length
	jb		.loop
	mov		eax, 0x00
	jmp		.loop
	
	push	ansimod10
	call	_printf
	add		esp, 0x04
	
	mov		esp, ebp
	pop		ebp
	ret