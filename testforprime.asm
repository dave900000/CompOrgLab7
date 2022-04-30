#testforprime.asm
#Function for use in RSA - will loop through the valid prime
#numbers that can be used as a public key exponent - print them,
#ask user for input until a valid selection is made.
#
#Author: Matt Hampton - mhampton8@jh.edu / mthampton@gmail.com
#4/25/2022
#
# User supplies a number and the function will test for primality.
#





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