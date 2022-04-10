#phi.asm
#RSA encryption program.
#
#Authors: 
#	Matt Hampton - mhampton8@jh.edu / mthampton@gmail.com
#
#4/10/2022
#
# Program is a simple implementation of the RSA encryption algorithm using
# small inputs. Program will walk the user through the required inputs that encrypt
# and decrypt a short message.
#
#GLOBAL VARS:
# $s0 = P
# $s1 = Q
# $s2 = N ( modulus of p & q )

.data
printpqmsg:	.asciiz	"Please input 2 values ( p and q ). Each value should be greater than 1, less than 50."
inputp:		.asciiz "Input a value for p: "
inputq:		.asciiz "Input a value for q: "
printpqerr:	.asciiz "P and Q are not relatively prime - please select new values."

#Begin main function ----------------------------------------
.text
	li $v0,4
	la $a0,printpqmsg
	syscall
	li $v0,11 #Print a new line.
	li $a0,10 #Ascii value for line feed
	syscall
	#Input value for p and loop until value is between 1-50.
ploop:	
	li $v0,4
	la $a0,inputp
	syscall
	li $v0,5
	syscall
	move $s0,$v0	# P will be stored in $s0
	move $a0,$s0
	slti $t0,$s0,1  # Test if P is < 1
	slti $t1,$s0,50 # Test if P is < 50
	beq $t0,1,ploop
	bne $t1,1,ploop
		
	#Input value for q and loop until value is between 1-50.
qloop:
	li $v0,4
	la $a0,inputq
	syscall
	li $v0,5
	syscall
	move $s1,$v0	# Q will be stored in $s0
	move $a0,$s1
	slti $t0,$s1,1  # Test if Q is < 1
	slti $t1,$s1,50 # Test if Q is < 50
	beq $t0,1,qloop
	bne $t1,1,qloop

	#Test to ensure P & Q are prime.
	move $a0,$s0
	move $a1,$s1
	jal gcd
	beq $v0,1,postpq #If p and q are prime, continue with program
	li $v0,4
	la $a0,printpqerr
	syscall
	li $v0,11
	li $a0,10
	syscall
	j ploop	#P and Q are not prime - pick again.
postpq:
	#Calculate and store modulus
	mult $s0,$s1
	mflo $s2
	
	li $v0,10
	syscall
#End main---------------------------------------------

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
	
	