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
	la a0, prompt	# Put address of prompt into a0
	addi  a1, zero, prompt_end - prompt	# Put the length of the string ( in bytes ) into a1   
        call write_string	# Call write_string

	#  Read up to 100 characters from the terminal (stdin)
	mv a0, sp	# Put address of buf into a0
	addi a1, zero, buf_end - buffer	# Put ( buf_end - buffer ) into a1
	call read_string	# Call read_string

	// At this point , a0 holds the number of bytes of the input

	# Write the just read characters to the terminal (stdout)
	mv a1, a0	# Move a0 to a1
	mv a0, sp	# Put address of buf into a0
	call write_string	# Call write_string

	# main() epilog
	lw ra, 100(sp)
	addi sp, sp, 104
	ret

write_string:
    mv a2, a1	# move a1 into a2
    mv a1, a0	# move a0 into a1
    li a7, __NR_WRITE	# Put NR_WRITE code into a7
    li a0, STDOUT	# Put STDOUT code into a0
    ecall
    ret
    
read_string:
    mv a2, a1	# move a1 into a2
    mv a1, a0	# move a0 into a1
    li a7, __NR_READ	# Put NR_READ code into a7
    li a0, STDIN	# Put STDIN code into a0
    ecall
    ret
    
.data
    prompt:   .ascii  "Enter a message: "
    prompt_end:

    buf: .space 100	# new
    buf_end:	# new

    
