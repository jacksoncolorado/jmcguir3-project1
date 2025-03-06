.globl main 
.equ STDOUT, 1
.equ STDIN, 0
.equ __NR_READ, 63
.equ __NR_WRITE, 64
.equ __NR_EXIT, 93

.text
main:
	# main() prolog
	addi sp, sp, -104
	sw ra, 100(sp)

	# main() body

	# Write the prompt to the terminal (stdout)
	la a0, prompt
	addi  a1, zero, prompt_end - prompt        
    call write_string

	#  Read up to 100 characters from the terminal (stdin)
	mv a1, sp
	addi a2, zero, 100
	call read_string

	# Write the just read characters to the terminal (stdout)
	mv a1, a0
	mv a0, sp
	call write_string

	# main() epilog
	lw ra, 100(sp)
	addi sp, sp, 104
	ret

.data
prompt:   .ascii  "Enter a message: "
prompt_end:

write_string:
    mv a2, a1
    mv a1, a0
    li a7, __NR_WRITE
    li a0, STDOUT
    ecall
    ret
    
read_string:
    mv a2, a1
    mv a1, a0
    li a7, __NR_READ
	li a0, STDIN
	ecall
	ret
    
