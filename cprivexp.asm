
#in a0 -> phi 
#in a1 -> e
#out ra -> d

li $a0, 20   #phi = 20
li $a1, 7    #e = 7


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
