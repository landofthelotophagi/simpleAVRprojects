@ECHO OFF
"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler2\avrasm2.exe" -S "C:\Assembler projects\Lab_1\Part_2\labels.tmp" -fI -W+ie -C V2E -o "C:\Assembler projects\Lab_1\Part_2\Part_2.hex" -d "C:\Assembler projects\Lab_1\Part_2\Part_2.obj" -e "C:\Assembler projects\Lab_1\Part_2\Part_2.eep" -m "C:\Assembler projects\Lab_1\Part_2\Part_2.map" "C:\Assembler projects\Lab_1\Part_2\Part_2.asm"
