.data
 buffer:   .space 100
message: .space 200
encrypted_char: .space 200
input_number_array: .space 200
newline: .ascii "\n"
str_file: .asciiz "encrypted.txt"
str_exponent: .asciiz "\n enter your exponent:\n"
str_modulus: .asciiz "enter modulus: \n"
str_plain_text: .asciiz "enter plain text: \n"
end_message: .asciiz "enter plain text: \n"

fout:   .asciiz "testout.txt"      # filename for output

  string:  .asciiz "Hello"     # We want to lower this string 


.text

main:

addi $sp, $sp, -16
sw $t1, 0($sp)
sw $t2, 4($sp)
sw $t3, 8($sp)
sw $t4, 12($sp)

         la $a0,str_plain_text #Load and print string asking for string
         li $v0,4
         syscall

         li $v0,8 #take in input
         la $a0, buffer #load byte space into address
         li $a1, 20 # allot the byte space for string
         move $t2,$a0 #save string to t0
         syscall
	

 	#la $t2, string # Load here the ttring  
	li $t7, 0
	
	move $t4, $t2
 	
       encrypt:  
       
       
       lbu $t3, ($t2)  # get the firtt byte pointed by the address  
       li  $t6, 10 
       beq $t3, $t6, end  # if is equal to zero, the string is terminated  

       continue: 
       addi, $t7, $t7, 1
       move $a0, $t3	
       jal powmodB
       
        move  $t3, $s3
	sb $t3, 0($t2)
	

        
        # Printing out the text
        move  $a0, $v0
    	li $v0, 1
    	
    	syscall			
 
        add  $t2, $t2, 1   # Increment the address  
        j encrypt  
  # The while loop ends here --------------------
  
      end:  
      
      # Open (for writing) a file that does not exist
li   $v0, 13       # system call for open file
la   $a0, fout     # output file name
li   $a1, 1       # Open for writing (flags are 0: read, 1: write)
li   $a2, 0        # mode is ignored
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

# Write to file just opened
li   $v0, 15       # system call for write to file
move $a0, $s6      # file descriptor 
move $a1, $t4      # address of buffer from which to write
move   $a2, $t7        # hardcoded buffer length
syscall            # write to file

# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file  
      
      
 	lw $t4 12($sp)
	lw $t3 8($sp)
	lw $t2 4($sp)
	lw $t1 0($sp)
	addi $sp,$sp,16     
       li $v0, 10  
       syscall  
     
       
#Begin powmodB------------------------------
#
#Input: $a0 contains encrypted or unencrypted byte value(c) or (m) 
#	$a1 has exponent (d or e)
#	$a2 has modulus (n)
#Output: $v0 will contain c^d % n or m^e%n for encryption and decryption.
#

powmodB:
		
		li $a1, 35   #e
 		li $a2, 221    #mod
 		
 		
		addi $sp, $sp, -8
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		
		addi $sp,$sp,-4
		sw $ra,0($sp)
		
		move $t0,$zero 	#Loop counter
		move $t1,$zero 	#Initialize intermediate register to hold multiplcation results
		li $v0,1	#Initialize result register to 1
		
powmodB_loop:	
		#Loop executes the calculation result = (bytevalue * lastresult) % n
		#This is using the concept that (a ? b) mod m = [(a mod m) ? (b mod m)] mod m
		#Result will be in $v0 when complete
		addi $t0,$t0,1 		#Increment counter
		multu $a0,$v0 		#Multiply byte value by last modulus calculation in $v0
		mflo $t1
		divu $t1,$a2		#Calculate modulus of above result and update $v0
		mfhi $v0
		blt $t0,$a1,powmodB_loop#Loop if counter < exponent
		
		lw $ra,0($sp)
		addi $sp,$sp,4
		
		lw $t1 4($sp)
		lw $t0 0($sp)
		addi $sp,$sp,8
		
		jr $ra
#
#End powmodB--------------------------------
        
                     
                       
                           
     
    powmod_old:
    addi $sp, $sp, -16
sw $t1, 0($sp)
sw $t2, 4($sp)
sw $t3, 8($sp)
sw $t4, 12($sp)



    	
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
		
		

	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
