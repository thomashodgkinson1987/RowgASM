extern _memset

section .data

offset_id	db	0x00		; unsigned
offset_x	db	0x01		; signed
offset_y	db	0x02		; signed
offset_width	db	0x03		; unsigned
offset_height	db	0x04		; unsigned
offset_title	db	0x05		; unsigned
offset_visible	db	0x15		; unsigned
offset_content	db	0x16		; unsigned

array_limit	dw	0x0100		; unsigned
entry_size	dd	0x00010000	; unsigned

section .bss

array_data	resb	0x01000000	; unsigned
array_pointers	resd	0x0100		; unsigned
array_count	resb	0x01		; unsigned

section .text

;id		resb	0x01		; unsigned
;x		resb	0x01		; signed
;y		resb	0x01		; signed
;width		resb	0x01		; unsigned
;height		resb	0x01		; unsigned
;title		resb	0x10		; unsigned
;visible	resb	0x01		; unsigned
;content	resb	0xFFEA		; unsigned
;total	0x00010000

global create_window
create_window:
	push	ebp
	mov	ebp, esp

	mov	eax, dword [array_limit]
	movzx	ebx, byte [array_count]
	cmp	ebx, eax
	jae	.array_full

	mov	eax, dword [entry_size]
	movzx	ebx, byte [array_count]
	imul	eax, ebx
	mov	ebx, array_data
	add	eax, ebx
	movzx	ebx, byte [array_count]
	imul	ebx, 0x04
	mov	[array_pointers + ebx], eax

	movzx	ebx, byte [array_count]
	movzx	ecx, byte [offset_id]
	mov	[eax + ecx], byte bl

	movzx	ebx, byte [ebp + 0x08]
	movzx	ecx, byte [offset_x]
	mov	[eax + ecx], byte bl

	movzx	ebx, byte [ebp + 0x0C]
	movzx	ecx, byte [offset_y]
	mov	[eax + ecx], byte bl

	movzx	ebx, byte [ebp + 0x10]
	movzx	ecx, byte [offset_width]
	mov	[eax + ecx], byte bl

	movzx	ebx, byte [ebp + 0x14]
	movzx	ecx, byte [offset_height]
	mov	[eax + ecx], byte bl

	movzx	ecx, byte [offset_visible]
	mov	[eax + ecx], byte 0x01

	inc	byte [array_count]
	jmp	.end

	.array_full:
	mov	eax, dword 0x00

	.end:

	mov	esp, ebp
	pop	ebp
	ret

global get_window_x
get_window_x:
	push	ebp
	mov	ebp, esp

	movzx	ebx, byte [ebp + 0x08]
	mov	ecx, dword [entry_size]
	imul	ebx, ecx
	add	ebx, offset_x

	movzx	eax, byte [ebx]

	mov	esp, ebp
	pop	ebp
	ret
