#pubexpisvalid.asm
#Function for use in RSA - will test wether or not a chosen public key exponent
#is valid or not.
#
#REQUIRES: gcd function which returns gcd of 2 values in $v0.
#
#Author: Matt Hampton - mhampton8@jh.edu / mthampton@gmail.com
#3/28/2022
#
# User supplies public key exponent and the totient of the modulus.
.data
inputA:		.asciiz "Please enter a public key exponent(integer): "
inputB:		.asciiz "Please enter the totient of the modulus: "
output:		.asciiz "The result is: "

.text
#Begin main------------------
	li $v0,4
	la $a0,inputA
	syscall
	li $v0,5
	syscall
	move $t0,$v0
	li $v0,4
	la $a0,inputB
	syscall
	li $v0,5
	syscall
	move $a0,$t0
	move $a1,$v0
	jal pubexpisvalid
	move $t0,$v0
	li $v0,4
	la $a0,output
	syscall
	li $v0,1
	move $a0,$t0
	syscall
end:
	li $v0,10
	syscall

#End main--------------------

#Begin pubexpisvalid---------
#Input: #a0 = chosen public key expoenent integer
#	#a1 = totient of modulus
#Output: $v0 will contain 1(true) if exponent is valid 0 if not
#
pubexpisvalid:
	#Stack calls...
	addi $sp,$sp,-12
	sw $ra,8($sp)
	sw $a1,4($sp)
	sw $a0,0($sp)
	#Set $t0 to 0 and $t1 to 1 for testing
	move $t0,$zero
	li $t1,1
	#Save variables to stack and call gcd function
	#to test gcd of exp and totient of modulus.
	addi $sp,$sp,-8
	sw $t1,4($sp)
	sw $t0,0($sp)
	jal gcd
	lw $t1,4($sp)
	lw $t0,0($sp)
	addi $sp,$sp,8
	#Begin tests to see if exponent is valid. If any test fails
	#return and use $t0 as return value ( starts with 0 ) otherwise
	#change #t0 to true and return.
	bne $v0,$t1,endpubexpisvalid #Is the gcd of e == 1?
	bge $a0,$a1,endpubexpisvalid #Is e < toteint of modulus?
	ble $a0,$t1,endpubexpisvalid #Is e > 1?
	li $t0,1
endpubexpisvalid:
	#Move final result into $v0 and return.
	move $v0,$t0
	lw $ra,8($sp)
	lw $a1,4($sp)
	lw $a0,0($sp)
	addi $sp,$sp,12
	jr $ra
#
#End pubexpisvalid-----------

#Begin GCD Function-----------------------------------
#Input: $a0/$a1 contain 2 positive integers
#Output: $v0 will contain the gcd
#
gcd:
	addi $sp,$sp,-12
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	
	
	bge $a0,$a1 gcdcalc #Ensure $a0 contains the larger #.
	move $t0,$a0
	move $a0,$a1
	move $a1,$t0
gcdcalc:
	divu $a0,$a1
	mfhi $t0
	#Return if remainder is 0, otherwise set $a0 to smaller
	#value, $a1 to reminder and recalculate.
	beq $t0,$zero gcdret
	move $a0,$a1
	move $a1,$t0
	j gcdcalc
gcdret:
	
	move $v0,$a1
	
	lw $ra, 8($sp)
	lw $a0, 4($sp)
	lw $a1, 0($sp)
	addi $sp,$sp,12
	
	jr $ra
#
#End gcd function------------------------------------- 
