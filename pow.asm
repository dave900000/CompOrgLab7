


li $a0, 5
li $a1, 7

jal pow
move $t1,$v0
li $v0, 10
syscall

# compute $a0 ^ $a1 and return in $v0
pow: 
li $v0,1
move $t1,$a1
loop :
beq $t1,$zero, exit
mul $v0,$v0,$a0 #loop for the value of s2
subi $t1,$t1,1
j loop
exit:
jr $ra