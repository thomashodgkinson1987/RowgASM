extern _system
extern _printf
extern _getch
extern _rand
extern _srand
extern _time
extern _memset
extern _fopen
extern _fclose
extern _fseek
extern _fgetc
extern _fputs
extern _fread
extern _ExitProcess@4

extern print

global _main

section .data

	screen_width		equ	0x10
	screen_height		equ	0x10
	screen_length		equ	screen_width * screen_height

	titlemsg		db	"RowgASM", 0x0A, 0x00
	helpmsg1		db	"Num pad keys to move", 0x0A, 0x00
	helpmsg2		db	"Press 'r' to reload", 0x0A, 0x00
	helpmsg3		db	"Press 'p' to toggle player visibility", 0x0A, 0x00
	helpmsg4		db	"Press 'f' to toggle floor visibility", 0x0A, 0x00
	helpmsg5		db	"Press 'w' to toggle wall visibility", 0x0A, 0x00
	helpmsg6		db	"Press 'z' to load level 1", 0x0A, 0x00
	helpmsg7		db	"Press 'x' to load level 2", 0x0A, 0x00
	helpmsg8		db	"Press 'q' to quit", 0x0A, 0x00
	newline			db	0x0A, 0x00

	ui_player_pos_lbl1	db	"Player position: x=", 0x00
	ui_player_pos_lbl2	db	" y=", 0x00

	level1data_filename	db	"level1data.bin", 0x00
	level1data_filemode	db	"rb", 0x00

	level2data_filename	db	"level2data.bin", 0x00
	level2data_filemode	db	"rb", 0x00

section .bss

	screen_buffer		resb	screen_length

	wall_tiles		resb	screen_length
	floor_tiles		resb	screen_length

	player_x		resb	0x01
	player_y		resb	0x01

	player_tile		resb	0x01
	floor_tile		resb	0x01
	wall_tile		resb	0x01

	input_table_x		resb	0x09
	input_table_y		resb	0x09

	player_visible		resb	0x01
	wall_visible		resb	0x01
	floor_visible		resb	0x01

	level1data_fileptr	resb	0x04
	level2data_fileptr	resb	0x04

section .text

_main:
	call	print

	jmp	exit

	call	init_random_number_generator

start:
	mov	[player_x], byte 0x09
	mov	[player_y], byte 0x09

	mov	[player_tile], byte 0x40
	mov	[floor_tile], byte 0x2E
	mov	[wall_tile], byte 0x23

	mov	[input_table_x + 0x00], byte 0xFF
	mov	[input_table_x + 0x01], byte 0x00
	mov	[input_table_x + 0x02], byte 0x01
	mov	[input_table_x + 0x03], byte 0xFF
	mov	[input_table_x + 0x04], byte 0x00
	mov	[input_table_x + 0x05], byte 0x01
	mov	[input_table_x + 0x06], byte 0xFF
	mov	[input_table_x + 0x07], byte 0x00
	mov	[input_table_x + 0x08], byte 0x01

	mov	[input_table_y + 0x00], byte 0x01
	mov	[input_table_y + 0x01], byte 0x01
	mov	[input_table_y + 0x02], byte 0x01
	mov	[input_table_y + 0x03], byte 0x00
	mov	[input_table_y + 0x04], byte 0x00
	mov	[input_table_y + 0x05], byte 0x00
	mov	[input_table_y + 0x06], byte 0xFF
	mov	[input_table_y + 0x07], byte 0xFF
	mov	[input_table_y + 0x08], byte 0xFF

	mov	[player_visible], byte 0x01
	mov	[wall_visible], byte 0x01
	mov	[floor_visible], byte 0x01

	push	level1data_fileptr
	push	level1data_filemode
	push	level1data_filename
	call	load_level_data
	add	esp, 0x0C

	call	draw
	jmp	tick

init_random_number_generator:
	push	0x00
	call	_time
	add	esp, 0x04

	push	eax
	call	_srand
	add	esp, 0x04

	call	_rand

	ret

tick:
	call	_getch

	cmp	al, 0x71
	je	exit

	cmp	al, 0x72
	je	start

	cmp	al, 0x7A
	je	.load_level_1

	cmp	al, 0x78
	je	.load_level_2

	cmp	al, 0x70
	je	.toggle_player_visibility

	cmp	al, 0x77
	je	.toggle_wall_visibility

	cmp	al, 0x66
	je	.toggle_floor_visibility

	sub	eax, 0x31
	cmp	eax, 0x39 - 0x31
	jna	.handle_player_input

	jmp	.end

.load_level_1:
	mov	[player_x], byte 0x09
	mov	[player_y], byte 0x09
	mov	[player_visible], byte 0x01
	mov	[wall_visible], byte 0x01
	mov	[floor_visible], byte 0x01
	push	level1data_fileptr
	push	level1data_filemode
	push	level1data_filename
	call	load_level_data
	add	esp, 0x0C
	jmp	.end

.load_level_2:
	mov	[player_x], byte 0x09
	mov	[player_y], byte 0x09
	mov	[player_visible], byte 0x01
	mov	[wall_visible], byte 0x01
	mov	[floor_visible], byte 0x01
	push	level2data_fileptr
	push	level2data_filemode
	push	level2data_filename
	call	load_level_data
	add	esp, 0x0C
	jmp	.end

.toggle_player_visibility:
	xor	[player_visible], byte 01b
	jmp	.end

.toggle_wall_visibility:
	xor	[wall_visible], byte 01b
	jmp	.end

.toggle_floor_visibility:
	xor	[floor_visible], byte 01b
	jmp	.end

.handle_player_input:
	push	eax
	call	handle_player_input
	add	esp, 0x04

.end:
	call	draw
	jmp	tick

draw:
	push	ebp
	mov	ebp, esp

	call	clear_screen

	push	titlemsg
	call	_printf
	add	esp, 0x04

	push	newline
	call	_printf
	add	esp, 0x04

	call	clear_screen_buffer

	cmp	[floor_visible], byte 01b
	jne	.check_wall_visible

	call	add_floors_to_screen_buffer

.check_wall_visible:
	cmp	[wall_visible], byte 01b
	jne	.check_player_visible

	call	add_walls_to_screen_buffer

.check_player_visible:
	cmp	[player_visible], byte 01b
	jne	.visible_checks_end

	call	add_player_to_screen_buffer

.visible_checks_end:
	call	print_screen_buffer
	
	push	newline
	call	_printf
	add	esp, 0x04

	call	print_help_messages

	push	newline
	call	_printf
	add	esp, 0x04

	call	print_player_position

	push	newline
	call	_printf
	add	esp, 0x04

	mov	esp, ebp
	pop	ebp
	ret

load_level_data:
	push	ebp
	mov	ebp, esp

	push	screen_length
	push	0x00
	push	floor_tiles
	call	_memset
	add	esp, 0x0C

	push	screen_length
	push	0x00
	push	wall_tiles
	call	_memset
	add	esp, 0x0C

	push	dword [ebp + 0x0C]
	push	dword [ebp + 0x08]
	call	_fopen
	add	esp, 0x08

	mov	[ebp + 0x10], eax

.start_load_floor_tiles:
	mov	eax, 0x00

	jmp	.load_next_floor_tile

.increase_floor_byte:
	inc	eax
	cmp	eax, screen_length
	je	.load_floor_tiles_end

.load_next_floor_tile:
	push	eax
	push	dword [ebp + 0x10]
	call	_fgetc
	add	esp, 0x04
	cmp	al, 0x00
	pop	eax
	je	.increase_floor_byte
	push	eax
	call	add_floor_using_byte_position
	pop	eax
	jmp	.increase_floor_byte

.load_floor_tiles_end:

.start_load_wall_tiles:
	mov	eax, 0x00
	jmp	.load_next_wall_tile

.increase_wall_byte:
	inc	eax
	cmp	eax, screen_length
	je	.load_wall_tiles_end

.load_next_wall_tile:
	push	eax
	push	dword [ebp + 0x10]
	call	_fgetc
	add	esp, 0x04
	cmp	al, 0x00
	pop	eax
	je	.increase_wall_byte
	push	eax
	call	add_wall_using_byte_position
	pop	eax
	jmp	.increase_wall_byte

.load_wall_tiles_end:

	push	dword [ebp + 0x10]
	call	_fclose
	add	esp, 0x04

	mov	esp, ebp
	pop	ebp
	ret

remove_random_floor_tiles:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]

.loop:
	push	eax
	call	_rand
	mov	edx, 0x00
	mov	ebx, screen_length
	div	ebx
	mov	[floor_tiles + edx], byte 0x00
	pop	eax
	dec	eax
	cmp	eax, 0x00
	ja	.loop

	mov	esp, ebp
	pop	ebp
	ret

handle_player_input:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]

	movzx	ebx, byte [input_table_x + eax]
	movzx	edx, byte [player_x]
	add	ebx, edx

	movzx	ecx, byte [input_table_y + eax]
	movzx	edx, byte [player_y]
	add	ecx, edx

	cmp	bl, byte 0x00
	jl	.end
	cmp	bl, screen_width
	jge	.end
	cmp	cl, byte 0x00
	jl	.end
	cmp	cl, screen_height
	jge	.end

	push	ecx
	push	ebx
	call	is_floor_at_position
	pop	ebx
	pop	ecx

	cmp	eax, 0x01
	jb	.end

	push	ecx
	push	ebx
	call	is_wall_at_position
	pop	ebx
	pop	ecx

	cmp	eax, 0x00
	ja	.end

	mov	[player_x], bl
	mov	[player_y], cl

.end:
	mov	esp, ebp
	pop	ebp
	ret

is_floor_at_position:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]
	movzx	ebx, byte [ebp + 0x0C]

	mov	ecx, screen_width
	imul	ecx, ebx
	add	ecx, eax
	add	ecx, floor_tiles
	movzx	edx, byte [ecx]

	cmp	edx, 0x01
	jb	.no

	mov	eax, 0x01
	jmp	.end

.no:
	mov	eax, 0x00

.end:
	mov	esp, ebp
	pop	ebp
	ret

is_wall_at_position:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]
	movzx	ebx, byte [ebp + 0x0C]

	mov	ecx, screen_width
	imul	ecx, ebx
	add	ecx, eax
	add	ecx, wall_tiles
	movzx	edx, byte [ecx]

	cmp	edx, 0x01
	jb	.no

	mov	eax, 0x01
	jmp	.end

.no:
	mov	eax, 0x00

.end:
	mov	esp, ebp
	pop	ebp
	ret

add_floor_using_byte_position:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]

	mov	ebx, floor_tiles
	add	ebx, eax
	mov	[ebx], byte 0x01

	mov	esp, ebp
	pop	ebp
	ret

add_floor_using_coordinates:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]
	movzx	ebx, byte [ebp + 0x0C]

	mov	ecx, screen_width
	imul	ecx, ebx
	add	ecx, eax
	add	ecx, floor_tiles
	movzx	edx, byte [ecx]

	cmp	edx, 0x00
	ja	.end

	mov	[ecx], byte 0x01

.end:
	mov	esp, ebp
	pop	ebp
	ret

remove_floor_using_byte_position:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]

	mov	ebx, floor_tiles
	add	ebx, eax
	mov	[ebx], byte 0x00

	mov	esp, ebp
	pop	ebp
	ret

remove_floor_using_coordinates:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]
	movzx	ebx, byte [ebp + 0x0C]

	mov	ecx, screen_width
	imul	ecx, ebx
	add	ecx, eax
	add	ecx, floor_tiles
	movzx	edx, byte [ecx]

	cmp	edx, 0x01
	jb	.end

	mov	[ecx], byte 0x00

.end:
	mov	esp, ebp
	pop	ebp
	ret

add_wall_using_byte_position:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]

	mov	ebx, wall_tiles
	add	ebx, eax
	mov	[ebx], byte 0x01

	mov	esp, ebp
	pop	ebp
	ret

add_wall_using_coordinates:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]
	movzx	ebx, byte [ebp + 0x0C]

	mov	ecx, screen_width
	imul	ecx, ebx
	add	ecx, eax
	add	ecx, wall_tiles
	movzx	edx, byte [ecx]

	cmp	edx, 0x00
	ja	.end

	mov	[ecx], byte 0x01

.end:
	mov	esp, ebp
	pop	ebp
	ret

remove_wall_using_byte_position:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]

	mov	ebx, wall_tiles
	add	ebx, eax
	mov	[ebx], byte 0x00

	mov	esp, ebp
	pop	ebp
	ret

remove_wall_using_coordinates:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]
	movzx	ebx, byte [ebp + 0x0C]

	mov	ecx, screen_width
	imul	ecx, ebx
	add	ecx, eax
	add	ecx, wall_tiles
	movzx	edx, byte [ecx]

	cmp	edx, 0x01
	jb	.end

	mov	[ecx], byte 0x00

.end:
	mov	esp, ebp
	pop	ebp
	ret

add_floors_to_screen_buffer:
	push	ebp
	mov	ebp, esp

	mov	eax, 0x00

.check:
	cmp	eax, screen_length
	je	.end

	movzx	ebx, byte [floor_tiles + eax]
	cmp	ebx, 0x01
	inc	eax
	jb	.check

	movzx	ebx, byte [floor_tile]
	mov	[screen_buffer + eax - 0x01], byte bl
	jmp	.check

.end:
	mov	esp, ebp
	pop	ebp
	ret

add_walls_to_screen_buffer:
	push	ebp
	mov	ebp, esp

	mov	eax, 0x00

.check:
	cmp	eax, screen_length
	je	.end

	movzx	ebx, byte [wall_tiles + eax]
	cmp	ebx, 0x01
	inc	eax
	jb	.check

	movzx	ebx, byte [wall_tile]
	mov	[screen_buffer + eax - 0x01], byte bl
	jmp	.check

.end:
	mov	esp, ebp
	pop	ebp
	ret

add_player_to_screen_buffer:
	push	ebp
	mov	ebp, esp

	push	dword [player_tile]
	push	dword [player_y]
	push	dword [player_x]
	call	set_pixel

	mov	esp, ebp
	pop	ebp
	ret

set_pixel:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]
	movzx	ebx, byte [ebp + 0x0C]
	movzx	ecx, byte [ebp + 0x10]

	mov	edx, screen_width
	imul	edx, ebx
	add	edx, eax
	add	edx, screen_buffer

	mov	[edx], byte cl

	mov	esp, ebp
	pop	ebp
	ret

fill_screen_buffer:
	push	ebp
	mov	ebp, esp

	movzx	eax, byte [ebp + 0x08]

	push	screen_length
	push	eax
	push	screen_buffer
	call	_memset
	add	esp, 0x0C

	mov	esp, ebp
	pop	ebp
	ret

print_screen_buffer:
	push	ebp
	mov	ebp, esp
	sub	esp, screen_length
	sub	esp, screen_height
	sub	esp, 0x04

	mov	eax, esp
	mov	ebx, 0x00
	mov	ecx, screen_buffer

.loop:
	movzx	edx, byte [ecx + ebx]
	mov	[eax + ebx], byte dl
	inc	ebx

	cmp	ebx, screen_width
	jb	.loop

	mov	byte [eax + ebx], 0x0A
	mov	ebx, 0x00

	add	ecx, screen_width
	add	eax, screen_width
	inc	eax

	mov	edx, esp
	add	edx, screen_length
	add	edx, screen_height
	sub	edx, screen_width
	dec	edx

	cmp	eax, edx
	jbe	.loop

	mov	eax, esp
	add	eax, screen_length
	add	eax, screen_height
	mov	[eax], byte 0x00

	push	esp
	call	_printf
	add	esp, 0x04

	mov	esp, ebp
	pop	ebp
	ret

print_help_messages:
	push	helpmsg1
	call	_printf
	add	esp, 0x04

	push	helpmsg2
	call	_printf
	add	esp, 0x04

	push	helpmsg3
	call	_printf
	add	esp, 0x04

	push	helpmsg4
	call	_printf
	add	esp, 0x04

	push	helpmsg5
	call	_printf
	add	esp, 0x04

	push	helpmsg6
	call	_printf
	add	esp, 0x04
	
	push	helpmsg7
	call	_printf
	add	esp, 0x04
	
	push	helpmsg8
	call	_printf
	add	esp, 0x04
	
	ret

print_player_position:
	push	ebp
	mov	ebp, esp
	sub	esp, 0x04

	push	ui_player_pos_lbl1
	call	_printf
	add	esp, 0x04

	mov	eax, ebp
	sub	eax, 0x04
	mov	[eax], dword 0x00007525

	movzx	ebx, byte [player_x]
	push	ebx
	push	eax
	call	_printf
	add	esp, 0x08

	push	ui_player_pos_lbl2
	call	_printf
	add	esp, 0x04

	mov	eax, ebp
	sub	eax, 0x04
	mov	[eax], dword 0x00007525

	movzx	ebx, byte [player_y]
	push	ebx
	push	eax
	call	_printf
	add	esp, 0x08

	add	esp, 0x04

	mov	esp, ebp
	pop	ebp
	ret

clear_screen_buffer:
	push	ebp
	mov	ebp, esp

	push	dword 0x20
	call	fill_screen_buffer
	add	esp, 0x04

	mov	esp, ebp
	pop	ebp
	ret

clear_screen:
	push	ebp
	mov	ebp, esp
	sub	esp, 0x04

	mov	eax, ebp
	sub	eax, 0x04
	mov	[eax], dword 0x00736C63

	push	eax
	call	_system
	add	esp, 0x08

	mov	esp, ebp
	pop	ebp
	ret

exit:
	push	0x00
	call	_ExitProcess@4

