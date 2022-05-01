


li $a0, 98
li $a1, 7

jal powFP
move $t1,$v0
li $v0, 10
syscall

# compute $a0 ^ $a1 and return in $v0
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
