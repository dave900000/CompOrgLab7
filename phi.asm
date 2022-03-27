#phi.asm
#Function to find the totient (phi) of an integer.
#
#Author: Matt Hampton - mhampton8@jh.edu / mthampton@gmail.com
#3/22/2022
#
# User supplies 1 integer as input, function will calculate and return the totient(phi).
.data
primelist: 	.space	12 #This is set aside as a linked list header to store the
		           #prime numbers counted in this funciton.
inputA:		.asciiz "Please enter a positive integer: "
outputA: 	.asciiz "The totient is: "
outputB:	.asciiz "The list of prime #'s: "
newline:	.asciiz "\n"



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
	li $v0,4
	la $a0,newline
	syscall
	#Print out the list of prime #'s
	li $v0,4
	la $a0,outputB
	syscall
	la $t0,primelist
	lw $t1,4($t0)
	lw $t2,4($t1)
printloop:
	beq $t2,$zero,end
	li $v0,1
	lw $a0,0($t2)
	syscall
	lw $t2,4($t2)
	li $v0,4
	la $a0,newline
	syscall
	j printloop
		
end:
	li $v0,10
	syscall
	
#
#End main function------------------------------------

#Begin phi function----------------------------------
#Input: $a0 contains positive integer to calculate from.
#Output: $v0 will contain the totient(phi) value.
#$v1 will contain the address of a linked list header
#that points to a list of the primes generated from
#this function.
#
phi:
	#Push params and return value to stack
	addi $sp,$sp -8
	sw $ra,4($sp)
	sw $a0,0($sp)
	
	#Add '1' to the primelist ( 1 is alwayse prime ).
	li $a0,1
	jal storeprime
	lw $a0,0($sp)
	
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
	#Call storeprime to add prime # to primelist
	#Restore $a0
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
	#number is prime - save it to primelist then
	#increment $t0.
	move $a0,$t1
	addi $sp,$sp,-12
	sw $t0,8($sp)
	sw $t1,4($sp)
	sw $t2,0($sp)
	jal storeprime
	lw $t0,8($sp)
	lw $t1,4($sp)
	lw $t2,0($sp)
	addi $sp,$sp,12
	lw $a0,0($sp)
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

#Begin storeprime function----------------------------
#Input: $a0 will contain an integer to add to a dynamic list
#Requires a 12-byte item in .data named: primelist
#Output: None. Creates a new node in the list and adds the data
#then updates the tail pointer. If the list was empty, head and
#tail pointers are set to the new node.
#Size variable in the header will be incremented.
#STRUCTURE of 12-byte header 'primelist'
#
#	BYTE OFFSET	CONTENTS
#	0		list size int
#	4		address to head of list
#	8		address to tail of list
#
storeprime:
	#Stack operatoins
	addi $sp,$sp,-8
	sw $ra,4($sp)
	sw $a0,0($sp)	
	#Create new node
	li $v0,9
	li $a0,8
	syscall
	move $t0,$v0
	lw $a0,0($sp)
	sw $a0,0($t0)
	#Get header and check if list is empty
	la $t1,primelist
	lw $t2,0($t1)
	bne $t2,$zero,skipempty
	#List is empty, point head and tail
	#addresses in the header to the new node
	sw $t0,4($t1)
	sw $t0,8($t1)
	j endstoreprime
skipempty:
	#List is not empty. Update tail node next
	#address to point to new node, then set
	#tail address itself to the address of the
	#new node.
	lw $t3,8($t1)
	sw $t0,4($t3)
	move $t3,$t0
	sw $t3,8($t1)
endstoreprime:
	#Increment size of list then return.
	addi $t2,$t2,1
	sw $t2,0($t1)
	lw $ra,4($sp)
	lw $a0,0($sp)
	addi $sp,$sp,8
	jr $ra
#
#End storeprime function---------------------------	 
	
	
	
	
