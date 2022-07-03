default:
	del *.exe *.obj
	nasm -g -f win32 -o other.obj other.asm
	nasm -g -f win32 -o utils.obj utils.asm
	nasm -g -f win32 -o main.obj main.asm
	gcc main.obj utils.obj other.obj -o program.exe
