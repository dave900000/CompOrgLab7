#decrypt.asm
#
#Author: Matt Hampton - mthampton@gmail.com / mhampto8@jh.edu
#
#Takes a string of characters encrpyted by the RSA algorithm and
#produces a decrypted result in a file.
#

.data
input_A:	.asciiz "Please enter the encrypted byte value: "
input_B:	.asciiz "Please enter the modulus: "
input_C:	.asciiz "Please enter the private key: "

.text
#Begin main---------------------------------
		li $v0,4
		la $a0,input_A
		syscall
		li $v0,5
		syscall
		move $t0,$v0 #c into $t0
		li $v0,4
		la $a0,input_B
		syscall
		li $v0,5
		syscall
		move $t1,$v0 #n into $t1
		li $v0,4
		la $a0,input_C
		syscall
		li $v0,5
		syscall
		move $t2,$v0 #d into $t2
		move $a0,$t0
		move $a1,$t2
		move $a2,$t1
		
		jal powmodB

end_main:
		li $v0,10
		syscall
#End main-----------------------------------

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
