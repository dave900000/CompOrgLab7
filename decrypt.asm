#decrypt.asm
#
#Author: Matt Hampton - mthampton@gmail.com / mhampto8@jh.edu
#
#Takes a string of characters encrpyted by the RSA algorithm and
#produces a decrypted result in a file.
#

.data
in_buf:		.space 201
in_file:	.asciiz "encrypted.txt"
out_file:	.asciiz "plaintext.txt"
input_A:	.asciiz "Please enter the modulus: "
input_B:	.asciiz "Please enter the private key: "

.text
#Begin main---------------------------------
		li $v0,4
		la $a0,input_A
		syscall
		li $v0,5
		syscall
		move $t0,$v0 #n into $t0
		li $v0,4
		la $a0,input_B
		syscall
		li $v0,5
		syscall
		la $a0,in_file
		move $a1,$v0
		move $a2,$t0
		la $a3,out_file
		
		jal decrypt
		

end_main:
		li $v0,10
		syscall
#End main-----------------------------------

#Begin decrypt
#
#Input: $a0 = filename to decrypt
#	$a1 = key
#	$a2 = modulus
#	$a3 = filename for output
#
#Out: None - a file is generated based on user input in working directory containing
#encrypted message.
#
decrypt:
		addi $sp,$sp,-20
		sw $ra,16($sp)
		sw $a3,12($sp)
		sw $a2,8($sp)
		sw $a1,4($sp)
		sw $a0,0($sp)
		
		#Open file for read
		li $v0,13
		#$a0 already has file name
		li $a1,0
		li $a2,0
		syscall
		move $t0,$v0 #File descriptor in $t0
		lw $a0,0($sp)
		lw $a1,4($sp)
		lw $a2,8($sp)
		
		#Create string buffer on heap
		li $v0,9
		li $a0,201
		syscall
		move $t1,$v0 #String buffer for file read in $t1
		lw $a0,0($sp)
		
		#Read from file into buffer
		li $v0,14
		move $a0,$t0
		move $a1,$t1
		li $a2,200
		syscall
		lw $a0,0($sp)
		lw $a1,4($sp)
		lw $a2,8($sp)
		move $t6,$v0 #$t6 will have # of chars read to buffer
		
		li $t4,0x0a #Definition of null terminator
		move $t3,$t1 #t3 holds address iterator for string to decrypt
decrypt_loop:
		#Loop through input string and decrypt at each offset until  null is reached
		lb $t5,($t3) #Load next byte		
		beq $t5,$t4,exit_decrypt_loop #If value at iterator is null, branch out
		move $a0,$t5
		addi $sp,$sp,-16
		sw $t6,12($sp)
		sw $t1,8($sp)
		sw $t3,4($sp)
		sw $t0,0($sp)
		jal powmodB
		lw $t6,12($sp)
		lw $t1,8($sp)
		lw $t3,4($sp)
		lw $t0,0($sp)
		addi $sp,$sp,16
		lw $a0,0($sp)
		lw $a3,12($sp)
		sb $v0,($t3) #Store decrypted result in current byte.
		addi $t3,$t3,1
		j decrypt_loop
exit_decrypt_loop:
		#Close input file
		li $v0,16
		move $a0,$t0
		syscall
		lw $a0,0($sp)
		
		#Open output file for writing
		li $v0,13
		move $a0,$a3
		li $a1,1
		li $a2,0
		syscall
		lw $a0,0($sp)
		lw $a1,4($sp)
		lw $a2,8($sp)
		move $t0,$v0 #New file descriptor in $t0
		
		#Write decrypted buffer to output file.
		li $v0,15
		move $a0,$t0
		move $a1,$t1
		move $a2,$t6
		syscall
		
		#Close the file
		li $v0,16
		move $a0,$t0
		syscall
		
		lw $ra,16($sp)
		lw $a3,12($sp)
		lw $a2,8($sp)
		lw $a1,4($sp)
		lw $a0,0($sp)
		addi $sp,$sp,20
		jr $ra
#End decrypt

#Begin powmodB------------------------------
#
#Input: $a0 contains encrypted or unencrypted byte value(c) or (m) 
#	$a1 has exponent (d or e)
#	$a2 has modulus (n)
#Output: $v0 will contain c^d % n or m^e%n for encryption and decryption.
#
powmodB:
		addi $sp,$sp,-4
		sw $ra,0($sp)
		
		move $t0,$zero 	#Loop counter
		move $t1,$zero 	#Initialize intermediate register to hold multiplcation results
		li $v0,1	#Initialize result register to 1
		
powmodB_loop:	
		#Loop executes the calculation result = (bytevalue * lastresult) % n
		#This is using the concept that (a ? b) mod m = [(a mod m) ? (b mod m)] mod m
		#Result will be in $v0 when complete
		addi $t0,$t0,1 		#Increment counter
		multu $a0,$v0 		#Multiply byte value by last modulus calculation in $v0
		mflo $t1
		divu $t1,$a2		#Calculate modulus of above result and update $v0
		mfhi $v0
		blt $t0,$a1,powmodB_loop#Loop if counter < exponent
		
		lw $ra,0($sp)
		addi $sp,$sp,4
		
		jr $ra
#
#End powmodB--------------------------------
