EXECUTABLE=Addition

all:
	nasm -f elf64 add.asm -o add.o 
	ld add.o -o $(EXECUTABLE)
	./$(EXECUTABLE)

#Clean folder
clean:
	rm -rf *o *.lst $(EXECUTABLE)
