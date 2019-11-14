@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\Assembler projects\Lab_1\Part_1\labels.tmp" -fI -W+ie -C V2E -o "C:\Assembler projects\Lab_1\Part_1\Part_1.hex" -d "C:\Assembler projects\Lab_1\Part_1\Part_1.obj" -e "C:\Assembler projects\Lab_1\Part_1\Part_1.eep" -m "C:\Assembler projects\Lab_1\Part_1\Part_1.map" "C:\Assembler projects\Lab_1\Part_1\Part_1.asm"
