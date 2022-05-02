.data

message: .space 200
encrypted_char: .space 200
input_number_array: .space 200
newline: .ascii "\n"
str_file: .asciiz "encrypted.txt"
str_exponent: .asciiz "\n enter your exponent:\n"
str_modulus: .asciiz "enter modulus: \n"
str_plain_text: .asciiz "enter plain text: \n"
end_message: .asciiz "enter plain text: \n"
 buffer:   .space 100

  string:  .asciiz "Hello"     # We want to lower this string 


.text

main:

         la $a0,str_plain_text #Load and print string asking for string
         li $v0,4
         syscall

         li $v0,8 #take in input
         la $a0, buffer #load byte space into address
         li $a1, 20 # allot the byte space for string
         move $t2,$a0 #save string to t0
         syscall
	
 	li $s0, 5   #e
 	li $s1, 5    #mod
 	#la $t2, string # Load here the ttring  
	
 	
       encrypt:  
       lb $t3, ($t2)  # get the firtt byte pointed by the address  
       beqz $t3, end  # if is equal to zero, the string is terminated  

       continue: 
       move $a0, $t3	
       jal powmod
        
        # Printing out the text
    	li $v0, 1
    	move  $a0, $s3
    	syscall			
 
        add  $t2, $t2, 1   # Increment the address  
        j encrypt  
  # The while loop ends here --------------------
  
      end:    
       li $v0, 10  
       syscall  
       
     
    powmod:
    addi $sp, $sp, -16
sw $t1, 0($sp)
sw $t2, 4($sp)
sw $t3, 8($sp)
sw $t4, 12($sp)


    	li $s0, 5   #e
 	li $s1, 5    #mod
	li $t9, 1 				# start counter at 1 since the first expo is itself
	move $t1, $a0				# char
	li $t2, 1				# set $t3 as the result/intial var for mult
	expo:
		bge $t9, $s2, mod		# branch to modulus part if counter is equal to exponent
		mul $t3, $t3, $t1		# char = char*last_result
		addi $t9, $t9, 1		# add 1 to counter 
		j expo				# jump back to top
	mod:
		div $t3, $s1			# divid the result of t^e by n (taking the remainder)
		mfhi $s3			# store remainder in $s0
	
	lw $t4 12($sp)
	lw $t3 8($sp)
	lw $t2 4($sp)
	lw $t1 0($sp)
	addi $sp,$sp,16
		jr $ra 				# return to encrypt
		
		

	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
