extern _malloc
extern _memset
extern _printf

section .data

offset_x	db	0x00
offset_y	db	0x01
offset_width	db	0x02
offset_height	db	0x03
offset_title	db	0x04
offset_content	db	0x14

section .bss

pointers	resd	0x00000100	; unsigned
data		resb	0x01000000	; unsigned
count		resb	0x00000100	; unsigned
limit		resb	0x00000100	; unsigned

section .text

;x		resb	0x00000001	; signed
;y		resb	0x00000001	; signed
;width		resb	0x00000001	; unsigned
;height		resb	0x00000001	; unsigned
;title		resb	0x00000010	; unsigned
;content	resb	0x0000FFEC	; unsigned

global foo
foo:
	push	ebp
	mov	ebp, esp



	mov	esp, ebp
	pop	ebp
	ret

create_window:
	push	ebp
	mov	ebp, esp

	mov	esp, ebp
	pop	ebp
	ret

