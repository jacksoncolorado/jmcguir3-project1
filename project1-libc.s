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
	la a0, prompt	# Put string pointer ( prompt ) into a0
        call puts	# Call puts

	#  Read up to 100 characters from the terminal (stdin)
	la a0, buffer	# Put address pointer ( buf ) into a0
	call gets	# Call gets

	# Write the just read characters to the terminal (stdout)
	la a0, buff	# Put string pointer ( buf ) into a0
	call puts	# Call puts

	# main() epilog
	lw ra, 100(sp)
	addi sp, sp, 104
	ret
halt :
	ebreak
	j halt 	# stop execution
	
puts:
	// prolog
	addi sp, sp, -12
	sw ra, 8(sp)	# push ra
	sw t0, 4(sp)	# push t0
	sw a0, 0(sp)	# push a0

    mv t0, a0
    
    puts_loop:
        lb a0, 0(t0)
        beqz a0, puts_finish
        call putchar
	blti a0, 0, puts_error
        addi, t0, t0, 1
        j puts_loop

	# Error branch ( a0 < 0)
    puts_error:
    	li a0, -1	# Put -1 into a0 // return -1
	j epil_error	# Restore stack items and sp      
    
    puts_finish:
        li a0, '\n'
        call putchar
        li a0, 0 
	
// epilog
lw a0, 0(sp)	# pop a0

# epilogue without a0
epil_error:

	lw ra, 8(sp)	# push ra
	lw t0, 4(sp)	# push t0
	addi sp, sp, 12

ret

putchar:
    // prolog
    addi sp, sp, -1
    sb a0, 0(sp)	# push a0

    addi sp, sp, -16
    sw ra, 12(sp)	# push ra
    sw a1, 8(sp)	# push a1
    sw a2, 4(sp)	# push a2
    sw a7, 0(sp)	# push a7


    li a0, STDOUT	# Put STDOUT code into a0
    la a1, sp	# Put sp into a1 // pointer to input char
    li a2, 1	# Put value 1 into a2 // write 1 byte
    li a7, __NR_WRITE	# Put NR_WRITE code into a7
    ecall

    // epilog
    sw a7, 0(sp)	# push a7
    sw a2, 4(sp)	# push a2
    sw a1, 8(sp)	# push a1
    sw ra, 12(sp)	# push ra
    addi sp, sp, -16

    lbu a0, 0(a1)	# load ( byte value ) of * sp back into a0 ( using lbu )
    addi sp, sp, 1	# restore sp

ret

gets:
// Prolog
addi sp, sp, -12 # make room for 3 items on the stack
sw ra, 8(sp)	# save ra 
sw a0, 4(sp)	# a0 ( original s pointer )

// Body
mv t0, a0	# move a0 into t0 ( use t0 for local pointer p )

gets_loop:
    // do-while body
    sw t0, 0(sp)	# save t0 into stack ( local p pointer )
    call getchar	# Call getchar
    lw t0, 0(sp)	# Restore t0 from stack, At this point , the read-in char put into a0
    blt a0, zero, gets_exit	# If read - in char is negative , goto gets_exit
    sb a0, 0(t0)
    addi t0, t0, 1	# Increment t0 by 1

    // Condition check ( do-while )
    li t1, 10	# put newline char into an unused register ( ascii value 10)
    bne a0, t1, gets_loop	# goto gets_loop if read - in char is not newline

    // If was newline
    addi t0, t0, -1	# end the input string with a terminating 0 byte ( note that this will overwrite the ‘\n ’ with NULL char )
    sb zero, 0(t0)
    lw a0, 4(sp)	# Restore base address s into register a0
    sub a0, t0, a0 	# Put t0 - a0 into a0 // return length of read - in string (p - s )

gets_exit:
    lw ra, 8(sp)	# Restore return address from stack
    addi sp, sp, 12	# restore stack

ret

getchar:
    la a1, temp
    li a2, 1
    li a7, __NR_READ
    li a0, STDIN
    ecall
    lb temp, a0
    ret

.data
	prompt: .ascii "Enter a message"
		prompt.end
	temp: .space 1
	    temp.end
	buff: .space 100
		buff.end
