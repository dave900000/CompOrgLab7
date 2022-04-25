#phi.asm
#Function to find the totient (phi) of an integer.
#
#Author: Matt Hampton - mhampton8@jh.edu / mthampton@gmail.com
#3/22/2022
#
# User supplies 1 integer as input, function will calculate and return the totient(phi).
.data
inputA:		.asciiz "Please enter a positive integer: "
outputA: 	.asciiz "The totient is: "

.text
#Begin main function----------------------------------
#
	li $v0,4
	la $a0,inputA
	syscall
	li $v0,5
	syscall
	move $a0,$v0
	jal phi
	move $s0,$v0
	li $v0,4
	la $a0,outputA
	syscall
	li $v0,1
	move $a0,$s0
	syscall
	
end:
	li $v0,10
	syscall
	
#
#End main function------------------------------------

#Begin phi function----------------------------------
#Input: $a0 contains positive integer to calculate from.
#Output: $v0 will contain the totient(phi) value.
#
phi:
	#Push params and return value to stack
	addi $sp,$sp -8
	sw $ra,4($sp)
	sw $a0,0($sp)
	
	#Local vars needed
	li $t0,1 #Will contain value of the result
	li $t1,2 #Iterator for loop
	li $t2,1 #Holds value of 1 for comparisons
	
	#Loop for each value of #a0 and
	#increment $t0(result) for each prime num
	#Return 1 if $a0 is 1 or 2
philoop:
	bge $t1,$a0,retphi
	move $a1,$t1
	
	#Save local variables to stack
	#Call gcd function then reload vars.
	addi $sp,$sp,-12
	sw $t0,8($sp)
	sw $t1,4($sp)
	sw $t2,0($sp)
	jal gcd
	lw $t0,8($sp)
	lw $t1,4($sp)
	lw $t2,0($sp)
	addi $sp,$sp,12
	
	bne $v0,$t2,nextphiloop
	addi $t0,$t0,1
nextphiloop:
	addi $t1,$t1,1
	j philoop
retphi:
	move $v0,$t0
	
	#Pop ra and $a0
	lw $ra,4($sp)
	lw $a0,0($sp)
	addi $sp,$sp,8
	
	jr $ra
#
#End phi function---------------------------

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
	
	
	
	
