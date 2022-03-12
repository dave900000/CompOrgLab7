#GCD.asm
#Function to find greatest common divisor of 2 supplied numbers.
#
#Author: Matt Hampton - mhampton8@jh.edu / mthampton@gmail.com
#3/12/2022
#
# User may supply 2 positive ingegers - the program will output the gcd.
.data
inputA:		.asciiz	"Please enter first number: "
inputB:		.asciiz	"Please enter second number: "
outString:	.asciiz "The greatest common divisor is: "

.text
#Begin main function-----------------------------------
	#Get inputs from user.
	li $v0, 4
	la $a0, inputA
	syscall
	li $v0, 5
	syscall
	move $s0, $v0
	li $v0, 4
	la $a0, inputB
	syscall
	li $v0, 5
	syscall
	move $s1, $v0
	
	#Load function arguments and call gcd function
	move $a0, $s0
	move $a1, $s1
	jal gcd
	
	#Store result then print
	move $s0,$v0
	li $v0, 4
	la $a0, outString
	syscall
	li $v0, 1
	move $a0,$s0
	syscall

end:
	li $v0, 10
	syscall
#End main function------------------------------------

#Begin GCD Function-----------------------------------
#Input: $a0/$a1 contain 2 positive integers
#Output: $v0 will contain the gcd
#
gcd:
	sw $ra, 0($sp)
	addi $sp,$sp,-4
	
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
	j gcd
gcdret:
	addi $sp,$sp,4
	lw $ra, 0($sp)
	
	move $v0,$a1
	jr $ra
#
#End gcd function------------------------------------- 