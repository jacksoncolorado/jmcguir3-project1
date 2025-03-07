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
    call puts

	#  Read up to 100 characters from the terminal (stdin)
	la a0, buffer
	call gets

	# Write the just read characters to the terminal (stdout)
	la a0, buffer
	call puts

	# main() epilog
	lw ra, 100(sp)
	addi sp, sp, 104
	ret
	
puts:
    mv t0, a0
    
    loop:
        lb a0, 0(t0)
        beqz a0, finish
        call putchar
        addi, t0, t0 , 1
        j loop
      
    finish:
        li a0, '\n'
        call putchar
        li a0, 0 
        ret

putchar:
    li a7, __NR_WRITE
    mv t0, a0
    li a0, STDOUT
    la a1, temp
    sb t0, 0(a1)
    li a2, 1
    ecall
    mv a0, t0
    ret
    


gets:
    mv t0, a0

    loop2:
        call getchar
        sb a0, 0(t0)
        beq a0, '\n\, finish2
        addi, t0, t0 , 1
        j loop
    
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
    lb buf, a0
    ret

.data
	prompt: .ascii "Enter a message"
		prompt.end
	temp: .space 1
	    temp.end
	buff: .space 100
		buff.end
