default:
	del *.exe *.obj
	nasm -g -f win32 -o main.obj main.asm
	nasm -g -f win32 -o utils.obj utils.asm
	nasm -g -f win32 -o window_test.obj utils.asm
	gcc main.obj utils.obj window_test.obj -o program.exe

