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

    li a0, STDOUT	# Put STDOUT code into a0
    la a1, sp	# Put sp into a1 // pointer to input char
    li a2, 1	# Put value 1 into a2 // write 1 byte
    li a7, __NR_WRITE	# Put NR_WRITE code into a7
    ecall


    // epilog
    lbu a0, 0(a1)	# load ( byte value ) of * sp back into a0 ( using lbu )
    lb a0, 0(sp)	# push a0
    addi sp, sp, 1	# restore sp

ret

gets:
# Prolog : a0 contains addr pointer s
# make room for 3 items on the stack
# save ra , a0 ( original s pointer )
    mv t0, a0
# Body
# move a0 into t0 ( use t0 for local pointer p )
gets_loop :
// do - while body
# save t0 into stack ( local p pointer )

    loop2:
        call getchar
        sb a0, 0(t0)
        beq a0, '\n', finish2
        addi, t0, t0 , 1
        j loop2
    
    finish2:
        sb zero, 0(t0)
        mv a0, t0
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
