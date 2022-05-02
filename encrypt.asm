# Written by Noah Regnier
# April 20th 2022 - JHU Computer Org.
######################################

# Encryption function will take two inputs (n,e) from the other functions and use them to encrypt a string of characters
# input by the user. The encrypted string will be written to a file called encrypted.txt

# Start with data declarations
#
.data

message: .space 200
encrypted_char: .space 200
input_number_array: .space 200
newline: .ascii "\n"
str_file: .asciiz "encrypted.txt"
str_exponent: .asciiz "\n enter your exponent:\n"
str_modulus: .asciiz "enter modulus: \n"
str_plain_text: .asciiz "enter plain text: \n"
end_message: .asciiz "enter plain text: \n"


.text

main:
	li $v0, 4              		# system call code for Print String
	la $a0, str_exponent    	# Print "get expo" string        
	syscall  
	
	li $v0, 5       		# system call code for Get String
	syscall	
	move $s0, $v0			# Get exponent (e) and move to $s0
	
	li $v0, 4			# system call code for Print String
	la $a0, str_modulus     	# Print "get mod" string       
	syscall  

	li $v0, 5       		# system call code for Get String
	syscall			
	move $s1, $v0			# Get modulus (n) move to $s1
	
	li $v0, 4              		# system call code for Print String
	la $a0, str_plain_text  	# Print "Enter string"           
	syscall  
	
	li $v0, 8       		# Take in input
    	la $a0, message  		# Load byte space into address
   	li $a1, 200      		# Allot the byte space for string
  	move $s7, $a0   		# Save string to $s7
 	syscall
 	
 	
 	li $t0, 0			# counter for loop
 	loop: 	
		add $t1, $s7, $t0 		# increment $s7 (message) by the counter to access the next char 
		lb $t2, 0($t1)			# load byte of addr into $t2
		beq $t2, $zero, exit 		# branch if $t2 is 0x00 
		addi $t0, $t0, 1 		# increment counter
		move $s4, $t0			# move str_length to $s4 for later use
		j loop			
	exit:
		addi $s4 ,$s4, -1		# set c back to legnth of s
			
	jal encrypt
	
	# Open (for reading) a file
        li $v0, 13				# syscall for open file
        la $a0, str_file			# name of file
        li $a1, 1				# open for writing 
        li $a2, 0				# mode is ignored 
	syscall  				# File descriptor gets returned in $v0
	move $s6, $v0  				# Syscall 15 requires file descriptor in $a0
	
	# Write to the file: 
	li $v0, 15				# syscall for write file
	move $a0, $s6				# file descriptor
	la $a1, encrypted_char			# addr of encrypted message
	li $a2, 200				# hardcoded length of message
        syscall					# write to file
	
	# Close the file
	li $v0, 16				# syscall for close file
	move $a0, $s6				# file descriptor to close
	syscall					# close file
	
	###############PRINT TEST for encrypted chars (IRGNORE)#####################
	#li $t0, 0				# counter for print_loop
	#la $t1, encrypted_char			# load addr of first encrypted_char
	#print_loop:
	#	bge $t0, $s4, end		# branch if >= length of the message
	#	add $t2, $t1, $t0		# add counter to addr of char
	#	lb $s7, 0($t2)			# load byte into $t3
	#	
		li $v0, 4              		# system call code for Print String
	#	move $a0, $s7    		# move content of $t3 into $a0 for printing        
		la $a0, encrypted_char
		syscall
	#	addi $t0, $t0, 1
	#	j print_loop  
	
	end:
		li $v0, 10    			# syscall for terminating the program
  		syscall				# end program
	

encrypt:
	move $s6, $ra
	li $t0, 0
	move $t5, $s4				# ideally is equal to the length of the message
	encrypt_loop:
		bge $t0, $t5, encrypt_exit 	# branch if counter is >= length of pt
		add $t2, $s7, $t0
		lb $t1,0($t2)			# load byte from pt message into $t1
		move $a0, $t1			# move pt char into $a0 for powmod
		jal powmod			# jump/link to powmod for encryption 
		la $s5, encrypted_char		#0x10010001
		add $t8, $s5, $t0
		sb $s2, 0($s5)			# store result of powmod ($s2) in $s4 
		#addi $s7, $s7, 1		# add 1 to the address of $s7 to access the next char
		addi $t0, $t0, 1		# add 1 to the address of $t0 to access the next byte in the string
		
		j encrypt_loop			

		
	encrypt_exit:
		move $ra, $s6
		jr $ra				# return to main


powmod:
	li $t9, 1 				# start counter at 1 since the first expo is itself
	move $t1, $a0				# load byte from pt string argument
	move $t2, $s0				# move (e) from $s4 into $t2
	move $t4, $s1				# move (n) from $s5 into $t4
	move $t3, $t1				# set $t3 as the result/intial var for mult
	expo:
		bge $t9, $t2, mod		# branch to modulus part if counter is equal to exponent
		mult $t3, $t1			# multiply (pt char) by itself (exponential mult)
		mflo $t3			# take the result and store in $t3
		addi $t9, $t9, 1		# add 1 to counter 
		j expo				# jump back to top
	mod:
		div $t3, $t4			# divid the result of t^e by n (taking the remainder)
		mfhi $s2			# store remainder in $s0
		jr $ra 				# return to encrypt

	
