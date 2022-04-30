# Written by Noah Regnier
# April 20th 2022 - JHU Computer Org.
######################################

# Encryption function will take two inputs (n,e) from the other functions and use them to encrypt a string of characters
# input by the user. The encrypted string will be written to a file called encrypted.txt

# Start with data declarations
#
.data

input_number_array: .space 300
message: .byte 200
encrypted_word: .word 200
newline: .ascii "\n"
str_file: .asciiz "encrypted.txt"
str_exponent: .asciiz "\n enter your exponent:\n"
str_modulus: .asciiz "enter modulus: \n"
str_plain_text: .asciiz "enter plain text: \n"
end_message: .asciiz "enter plain text: \n"


.align 2

.text
.globl __start	# leave this here for the moment



__start:
main:
	li $v0, 4              	# system call code for Print String
	la $a0, str_exponent    # Print "get expo" string        
	syscall  
	
	li $v0, 5       	# system call code for Get String
	syscall	
	move $s4, $v0		# Get exponent (e) and move to $s4
	
	li $v0, 4		# system call code for Print String
	la $a0, str_modulus     # Print "get mod" string       
	syscall  

	li $v0, 5       	# system call code for Get String
	syscall			
	move $s5, $v0		# Get modulus (n) move to $s5
	
	li $v0, 4              	# system call code for Print String
	la $a0, str_plain_text  # Print "Enter string"           
	syscall  
	
	li $v0, 8       	# Take in input
    	la $a0, message  	# Load byte space into address
   	addi $a1, $a1, 200      # Allot the byte space for string
  	move $s7, $a0   	# Save string to $s7
 	syscall
		  
	add $s6, $zero, $zero	# Save 0 to $s6
	
	loop: 	
		add $t0, $s7, $s6 	# address of byte to examine next
		lb $t1, 0($t0)		# load that byte to get *(s + ct)
		beq $t1, $zero, exit 	# branch if *(s + ct) == ’\0’
		addi $s6, $s6, 1 	# increment ct
		j loop
	exit:
	addi $s6 ,$s6, -1		# set c back to legnth of s
	la $s0, input_number_array 	# unsigned int* ptr = number_array
	li $s1, 1			# num_array_length
	
	encrypt_loop_test_in: 		# do {
		#li $v0, 5 
		#syscall
		lb $t0, 0($s7)  	#    scanf("%d", &read_num)
		sw $t0, 0($s0)		#    *ptr = read_num
		addi $s1, $s1, 1	#    num_array_length++
		addi $s0, $s0, 4
		addi $s7, $s7, 1	#    ptr += sizeof(unsigned int)
		bge $s6, $s1, encrypt_loop_test_in 	# } while(read_num != 0)

		la $a0, input_number_array
		move $a1, $s4
		move $a2, $s5
		move $a3, $s1

		jal encrypt

		move $s2, $s6
		move $s1, $v0

	# Open (for reading) a file
        li $v0, 13
        la $a0, str_file
        li $a1, 1
        li $a2, 0
	syscall  		# File descriptor gets returned in $v0
	move $s6, $v0  		# Syscall 15 requires file descriptor in $a0
   	 
   	# file_write: 
          
	# move $s5, $v0	#: byte output
	la $s5, encrypted_word
	sll $t0, $s2, 2
        li $t1, 0
        move $t2, $s5
        
        encrypt_loop_test_out:
            
        # address of buffer from which to write
        # lw $t1 ,0($s1)
       		
		lb $t3, ($s1)
       		sb $t3, ($t2)
       		addi $t1, $t1, 1
		addi $s1 , $s1, 1
		addi $t2 , $t2, 1
        	bne $t0, $t1 , encrypt_loop_test_out
            	li $v0, 15
          	move $a0, $s6 		# file descriptor 
          	move $a1, $s5 
		# li $a2, 16
		addi $t0, $t0 , 4
		move   $a2, $t0         # hardcoded buffer length
            	syscall
        	# bgt $s2, $zero, encrypt_loop_test_out
        
    	# file_close:
        li $v0, 16  		# $a0 already has the file descriptor
      	move $a0, $s6      
        syscall
        
  	li $v0, 10    		# syscall code 10 for terminating the program
  	syscall

	powmod:
	# PUSH_REGISTERS
	li $t0, 1		# unsigned int x = 1
	move $t1, $a0		# unsigned int y = a

	powmod_loop:					# while (
		ble $a1, $zero, powmod_while_end 	# b > 0 ) {
		
		andi $t2, $a1, 1			# t2 = b % 2
		beq $t2, $zero, powmod_b_mod_2		# if (t2) {
		mul $t0, $t0, $t1			# x *= y
		divu $t0, $a2				# HI = x % mod
		mfhi $t0				# x = HI
		
		powmod_b_mod_2:				# }
		mul $t1, $t1, $t1			# y *= y
		divu $t1, $a2				# HI = y % mod
		mfhi $t1				# y = HI

		srl $a1, $a1, 1				# b /= 2

		j powmod_loop
		
		powmod_while_end:

		move $v0, $t0
		# POP_REGISTERS
		jr $ra 			# return a
		# END


encrypt:
	# PUSH_REGISTERS
	move $t7, $ra
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	sll $a0, $s3, 2 			# size_in_bytes = text_length * 4
	li $v0, 9 				# cipher = malloc(size_in_bytes)
	syscall					# // output in $v0
	move $s5, $v0				# cipher

	li $s4, 0				# for (int i = 0; i < count; ++i) {
	encrypt_loop:
		bge $s4, $s3, encrypt_exit 	# 
		sll $t0, $s4, 2
		add $t0, $t0, $s0		# unsigned* msg = M + i;
		lw $a0, 0($t0) 			# unsigned b = *msg;

		move $a1, $s1
		move $a2, $s2
		#move $s6, $s0
		#move $s7, $s1
		jal powmod			# unsigned mod (aka. $v0) = powmod(b, e, modN)
		#move $s0, $s6
		#move $s1, $s7
		sll $t0, $s4, 2
		add $t0, $t0, $s5		# unsigned* decry = cipher + i;
		sw $v0, 0($t0)			# *decry = mod

		addi $s4, $s4, 1		# ++i
		j encrypt_loop			# } 
	
	encrypt_exit:
		move $v0, $s5

	#POP_REGISTERS
	jr $t7

#END}}
