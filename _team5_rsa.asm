#_team5_rsa.asm
#RSA encryption program.
#
#Authors: 
#	Matt Hampton - mhampton8@jh.edu / mthampton@gmail.com
#	Mike Curran - mcurran6@jhu.edu
#4/28/2022
#
# Program is a simple implementation of the RSA encryption algorithm using
# small inputs. Program will walk the user through the required inputs that encrypt
# and decrypt a short message.
#
#GLOBAL VARS:
# $s0 = p
# $s1 = q
# $s2 = n ( modulus of p & q )
# $s3 = e ( public key exponent )
# $s4 = d ( private key exponent )

.data
#Needed for cpubexp
primelist: 		.space	12 #This is set aside as a linked list header to store the
		           #prime numbers counted in this funciton.
cpuberrmsgA: 		.asciiz "Error. Modulus is not valid (too small). Choose new values for p and q."
cpuberrmsgB:		.asciiz "Error. No valid prime #'s found for exponent. Unexpected condition. Review inputs."
cpubprimes:		.asciiz "Valid choices for public exponent are: "
cpubinput:		.asciiz "Please enter a public key exponent selection: "
comma:			.asciiz ","
newline:		.asciiz "\n"

#For main function
printpqmsg:	.asciiz	"Please input 2 values ( p and q ). Each value should be greater than 1, less than 50, and must be prime."
inputp:		.asciiz "Input a value for p: "
inputq:		.asciiz "Input a value for q: "
printd:		.asciiz "d is set to: "



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
	#Test for primality
	jal testForPrime
	beq $v0,$zero,ploop #Loop if number is not prime.
	
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
	#Test for primality
	jal testForPrime
	beq $v0,$zero,qloop #Loop if number is not prime.

postpq:
	#Calculate and store modulus
	mult $s0,$s1
	mflo $s2
	move $a0,$s2
	
	#Call public key function and store in $s3.
	jal cpubexp
	move $s3,$v0
	
	#TO-DO - Call private key function and store in $s4
	#Calculate phi(n) for priv key function
	move $a0,$s2
	jal phi
	move $a0,$v0 #Move phi(n) into $a0
	move $a1,$s3 #Move e into $a1
	jal cprivexp
	move $s4,$v0
	
endmain:	
	li $v0,10
	syscall
#End main---------------------------------------------

#Begin cpubexp----------------------
#Inpust: Provide modulus of RSA function in $a0
#
#Output: System prints all valid prime #'s - user makes a selection.
#Selection is returned in $v0
#
cpubexp:
	#Basic function stack operatoins
	addi $sp,$sp,-8
	sw $ra,4($sp)
	sw $a0,0($sp)
	
	#Calculate the toteint of the modulus and
	#totient of phi(n). Capture all prime #'s
	#from 1-phi(n) in a list.
	li $t0,4 #Value of 2 for comparisons
	bgt $a0,$t0,cpubnoerr #Code branches when n > 4 (n  must be > 4 to work with RSA
	#Print an error and return 0 if n <= 4
	li $v0,4
	la $a0,cpuberrmsgA
	syscall
	lw $ra,4($sp)
	lw $a0,0($sp)
	addi $sp,$sp,8
	move $v0,$zero
	jr $ra
cpubnoerr:
	#Calculate totient of n and phi n
	#Store in $t0 and $t1 respectively
	#Store a linked list header address in $t2
	#See phi function for documentation and data structure info
	jal phi
	move $t0,$v0
	move $a0,$v0
	addi $sp,$sp,-4
	sw $t0,0($sp)
	#The following 3 lines will erase the primes list header
	#we only want the primes list from the 2nd call to phi
	#following.
	sw $zero,0($v1)
	sw $zero,4($v1)
	sw $zero,8($v1)
	jal phi
	lw $t0,0($sp)
	addi $sp,$sp,4
	move $t1,$v0
	lw $a0,0($sp)
	move $t2,$v1   #$v1 contains linked list header
	#Iterate through the primes list and print for user
	li $v0,4
	la $a0,cpubprimes
	syscall
	lw $a0,0($sp)
	lw $t3,0($t2) #Load size of prime # list into $t3
	lw $t4,4($t2) #Load address of list head node into $t4
	bne $t3,$zero,cpubloopA #Branch to loop as long as there is no error
	#$t3 is zero - indicating no primes to test for valid options. Print error message and
	#return 0.
	li $v0,4
	la $a0,cpuberrmsgB
	syscall
	lw $a0,0($sp)
	lw $ra,4($sp)
	addi $sp,$sp,8
	move $v0,$zero
	jr $ra
	move $t6,$zero #Set flag $t6 to zero indicating no output (will be zero at end of loop if there are no valid public key exponents)
cpubloopA:
	#Iterate through all items in primes list. Address iterator
	#is $t4 - offset 0 is integer and offset 4 is the address of
	#the next item. Loop until next item is null, printing each
	#value.
	lw $a0,0($t4) #Load data in node into $a0 for testing
	move $a1,$t0    #Put totient of modulus in $a1
	#Stack operations before calling pubexpisvalid function
	addi $sp,$sp,-24
	sw $t6,20($sp)
	sw $t4,16($sp)
	sw $t3,12($sp)
	sw $t2,8($sp)
	sw $t1,4($sp)
	sw $t0,0($sp)
	jal pubexpisvalid #$v0 will return true(valid e) or false(invalid e)
	lw $t6,20($sp)
	lw $t4,16($sp)
	lw $t3,12($sp)
	lw $t2,8($sp)
	lw $t1,4($sp)
	lw $t0,0($sp)
	addi $sp,$sp,24
	beq $v0,$zero,cpubskipprint #If value for e is not valid - do not print to output.
	li $t6,1 #Set output flag to true - indicating at least some valid output.
	#e is valid - print to output.
	syscall #$v0 has returned 1 to reach this point this will print $a0 to output
	#If the address of 4($t4) ( next node ) is not null, then print a comma
	lw $t5,4($t4)
	beq $t5,$zero,cpubskipprint #Do not print comma if there is no next value in the list
	li $v0,4
	la $a0,comma
	syscall
cpubskipprint:
	lw $a0,0($sp)
	lw $t4,4($t4) #Increment primes list pointer to the next address.
	bne $t4,$zero,cpubloopA #If next address is not null, continue to loop.
	#If no valid output was produced, print error and return 0.
	bne $t6,$zero,cpubloopB
	li $v0,4
	la $a0,cpuberrmsgB
	syscall
	lw $ra,4($sp)
	lw $a0,0($sp)
	addi $sp,$sp,8
	jr $ra
cpubloopB:
	li $v0,4
	la $a0,newline
	syscall
	#Ask user for exponent input - loop until input is valid.
	la $a0,cpubinput
	syscall
	lw $a0,0($sp)
	li $v0,5
	syscall
	move $a0,$v0 #Input chosen exponent to $a0 for testing
	move   $a1,$t0 #Put totient of modulus in $a1
	addi $sp,$sp,-20
	sw $t4,16($sp)
	sw $t3,12($sp)
	sw $t2,8($sp)
	sw $t1,4($sp)
	sw $t0,0($sp)
	jal pubexpisvalid #$v0 will return true(valid e) or false(invalid e)
	lw $t4,16($sp)
	lw $t3,12($sp)
	lw $t2,8($sp)
	lw $t1,4($sp)
	lw $t0,0($sp)
	addi $sp,$sp,20
	bne $v0,$zero,endcpubexp #If e is valid, branch out of loop and return
	j cpubloopB #Continue asking user for input.
endcpubexp:
	move $v0,$a0
	lw $ra,4($sp)
	lw $a0,0($sp)
	addi $sp,$sp,8
	jr $ra
#
#End cpubexp-----------------------

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
	la $v1,primelist
	
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

#Begin cprivexp---------------------------------------
cprivexp:
addi $sp, $sp, -32
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)
sw $s5, 24($sp)
sw $s6, 28($sp)

la $k0, ($a0)  
la $k1, ($a1)   

li $s0, 1    #a-2
li $s1, 0    #b-2
la $s2, ($k0)  #d-2
li $s3, 0    #k-2

li $s4, 0    #a-1
li $s5, 1    #b-1
la $s6, ($a1)  #d-1
div $s7, $k0, $a1 #k-1

d_calc:

#(a-2) - (a-1)*(k-1)
mul $t0, $s4,$s7    
sub $t0, $s0, $t0   #a 

#(b-2) - (b-1)*(k-1)
mul $t1, $s5,$s7   
sub $t1, $s1, $t1   #b 

#(d-2) - (d-1)*(k-1)
mul $t2, $s6,$s7   
sub $t2, $s2, $t2   #d

#(d-1)/d 
div $t3, $s6, $t2   #k

beq $t2, 1, finish

#new -2 
la $s0, ($s4)  
la $s1, ($s5)
la $s2, ($s6)
la $s3, ($s7)

#new -1 
la $s4, ($t0)  
la $s5, ($t1)
la $s6, ($t2)
la $s7, ($t3)

j d_calc

finish:


#if b > phi, b = b mod(phi)
sgt $t4, $s1, $k0 
beq $t4, $zero, elif
la $a0, ($t1)
jal phi  #b mod(phi)
la $t1, ($a0)
j gcd_check

#if b < 0, b = b + phi
elif:
slt $t4, $s1, $zero 
beq $t4, $zero, gcd_check
add $t1, $t1, $k0 # b = b + phi
j gcd_check



gcd_check: 
# check that gcd(\phi, e) = phi*a +ed = 1 
mul $t5, $k0,$t0  #phi*a 
mul $t6, $k1,$t1  #e*dorb??
add $t7,$t6,$t5
seq $t8, $t7, 1 
bne  $t8, $zero, end
la $v0, ($zero) #a = 0 mean we have an error 
j end

end:
la $v0, ($t1) #a = 0 mean we have an error 
#Restore Registers
lw $s6 28($sp)
lw $s5 24($sp)
lw $s4 20($sp)
lw $s3 16($sp)
lw $s2 12($sp)
lw $s1 8($sp)
lw $s0 4($sp)
lw $ra 0($sp)
addi $sp,$sp,32
jr $ra
#End cprivexp---------------------------------------

#Begin testForPrime function--------------------------------------
#
testForPrime:
		#Test $a0 for primality and set $v1 to 1 true or 0 false as appropriate, then return.
		#Tests for 1-3
		beq	$a0, 1, notPrime
		beq	$a0, 2, isPrime
		beq	$a0, 3, isPrime

		#Numbers >3 divisible by 2 or 3 are not prime
		divu	$t0, $a0, 2
		mfhi	$t1
		beq	$t1, 0, notPrime
		divu	$t0, $a0, 3
		mfhi	$t1
		beq	$t1, 0, notPrime

		#Starting with the first prime after 3 (5). Square it and test.
		#Loop until all options have been exausted.
		li	$t2, 5
loop:
		multu	$t2, $t2
		mflo	$t3
		bge	$t3, $t0, isPrime #IF squre of test value is > number, number is prime.
		divu	$t2, $t0
		mfhi	$t1
		beq	$t1, 0, notPrime #If number is divisible by test value, it is not prime.
		addu	$t0, $t2, 2
		divu	$t2, $t0
		mfhi	$t1
		beq	$t1, 0, notPrime #If number is divisible by test value + 2 it is not prime.
		addu	$t2, $t2, 6
		j	loop

isPrime:
		li	$v0, 1
		jr	$ra

notPrime:
		li	$v0, 0
		jr 	$ra
#End test for prime function.
