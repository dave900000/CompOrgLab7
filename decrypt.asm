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
		move $a0,$t1
		move $a1,$t2
		move $a2,$t0
		
		jal decrypt_str

end_main:
		li $v0,10
		syscall
#End main-----------------------------------

#Begin decrypt_str-------------------------
#
#Input $a0 - modulus(n) $a1 - Private Key(d) $a2 - Encrypted byte value(c)
#
#Output: $v0 contains decrpyted byte value.
decrypt_str:
		#Push ra and params
		addi $sp,$sp,-16
		sw $ra,12($sp)
		sw $a2,8($sp)
		sw $a1,4($sp)
		sw $a0,0($sp)
		
		move $a0,$a2
		#a1 already has private key(d)
		jal powFP #Get c^d and store in $t0
		lw $a0,0($sp) #Reload modulus into $a0
		mov.d $f12,$f0 #Move result of c^d into $f12
		mtc1 $a1,$f14 #Move modulus into $f14
		jal modFP #This should return (c^d) % n int0 $v0
		
		#Pop ra and params and return
		lw $ra,12($sp)
		lw $a2,8($sp)
		lw $a1,4($sp)
		lw $a0,0($sp)
		addi $sp,$sp,16
		
		jr $ra
#
#End decrypt_str----------------------------

#Begin powFP function------------------------------
# compute $a0 ^ $a1 and return in $F0
powFP: 
#Move and convert arguments to FP registers.
mtc1 $a0,$f2
cvt.d.w $f12,$f2 #$a0 converted to FP and stored in $f12
#a1 needs no conversion as it is only used as an integer counter.

li $v0,1
mtc1 $v0,$f2
cvt.d.w $f0,$f2 #Put value of 1 into $f0 ( return value ). As FP double.
move $t1,$a1
loop :
beq $t1,$zero, exit
mul.d $f0,$f0,$f12 #loop for the value of s2
subi $t1,$t1,1
j loop
exit:
jr $ra
#end powFP-------------------------------------

#Begin modFP function--------------------------
#
#In: $f12 contains number to mod  $f14 contains divisor (Values must be positive)
#Out: $v0 will contain the integer result
modFP:
		mov.d $f0,$f12 #Mod will be caluclated into $f0 with repeated subtraction

loopModFP:	
		c.lt.d $f0,$f14
		bc1t exitLoopModFP #Exit when $f0 < $f14
		sub.d $f0,$f0,$f14
		j loopModFP  
exitLoopModFP:
		cvt.w.d $f0,$f0
		mfc1 $v0,$f0
		
		jr $ra
#
#End modFP function----------------------------