default:
	del *.exe *.obj
	nasm -g -f win32 -o main.obj main.asm
	nasm -g -f win32 -o utils.obj utils.asm
	gcc main.obj utils.obj -o program.exe

