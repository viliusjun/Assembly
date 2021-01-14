# Assembly

Here I have uploaded three assembly x86 language codes which I wrote for my university course "Computer architecture".

The comments in the codes are written in Lithuanian, so I'll tell you what these programs do in this file.


1. hex_bin.asm

  This program requires the user to input a hexidecimal number (the digits should be 0 - 9 or A - F). 
  The program converts every digit of the hexidecimal number into binary and prints out the binary and hexidecimal numbers of every digit.
  
  
2. AND.asm

  This program performs the AND opperation to two binary numbers which are in two different files and outputs the result into the third file.
  The names of all three files should be written in the command line.
  /? - write this to understand how the file works.
  If the program is started without the command line parameters or if the are wrong a help message is also printed out.
  
  
3. MOV.asm

  This program disassembles the "MOV regsiter/memory, operand" command of x86 assembly language. 
  With the programmed single-step interept's help we disassemble only our MOV command.
  We print out the type of interupt that happens, then the address of the command, the command's machine code, the mnemonic of the command, the values and addresses that of registers that are used in that command.
  
