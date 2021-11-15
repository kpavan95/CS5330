# File Name: Program_assignment_2.asm
# Author: Pavan Kumar (pavan.kumar@utdallas.edu)
# Modification History
# - This code was first written on 20th October 2021.
# - The Code has been submitted to be reviewed by Dr. Richard Goodrum on 22nd October 2021 

# Procedures:
# main: Recieves Recieves a Filename and sends it for parsing and printing data
# nameClean: Removes trailing \n off of filename
# clean: Loop that iterates through the file name checking for \n
# incrementForCleanup: increments the counter used to loop the clean filename function
# initialize: Initialize the counters used to store data
# parseFileLoop: loop through each character in the file and increment appropriate counters
# countUppercase: Check if character is uppercase and if so increment uppercase counter
# countLowercase: Check if character is lowercase and if so increment lowercase counter
# countNumberSymbols: Check if character is number and if so increment number counter
# countOtherSymbols: Remove count of uppercase, lowercase and increment from the total char count
# countNoOfLines: Check if character is newline and if so increment no of lines counter
# countSignedNumbers: Check if the number is signed if so increment signed number counter
# checkNextForNumber: Check if next char in the file is a number
# print: Print the counters with appropriate messages onto console
# printMsg: Prints a string msg present in $a0
# printNumberWithNewLine: Prints a number msg present in $a0 and then prints a new line
# closeFile: Closes the file
# L1-6: returns to parent function 

# Data Segment :
# This segment is where data is stored in RAM. It is set as key value pairs
# syntax: label: .type value(s)
#
# Types Used :
# - ascii  : This is used to declare a string which does not have a null at the ed. This causes the next declared string to 
#            be part of the same label. Used here to have a multi-line initialization of label.
# - asciiz : This is used to declare a null terminated string. The null here is needed to imply the end of the string.
#            The characters in the string is encoded using ASCII code (American Standard Code for Information Interchange) 
.data 

	# Below I have initialised few messages that willl help provide a discriptive output to the user
	prompt1:	
				.ascii  "Welcome to Programming Assignment 2 !!"
				.ascii  "\n\nThis program will take a file name from the user, parse it and divulge"
				.ascii  "\ninformation about the characters used in the file."
				.ascii  "\n[Note: The name of file cannot be more than 32 characters in length and"
				.ascii  "\nthe file size cannot exceed 30kb]"
				.asciiz "\n\nPlease enter the file name: "
	totalCharMsg:		.asciiz "Total Characters Count: " 
	upperCaseMsg:		.asciiz "Uppercase Characters Count (A-Z): " 
	lowerCaseMsg:		.asciiz "Lowercase Characters Count (a-z): " 
	numberSymbolsMsg:	.asciiz "Number Symbols Count (0-9): "
	otherSymbolsMsg:	.asciiz "Other Symbols Count: "
	newLineMsg:		.asciiz "Lines Of Text Count: "
	signedNumberMsg:	.asciiz "Signed Numbers Count: "
	# Constants declared below
	newLine:  		.asciiz "\n"		# string for newLine
	# Below I have initialized buffers that will help to store data that can be processed in the program
	fileName: 		.asciiz ""
	arr1:			.space 32 	# Space reserved for the prev label fileName
	data:			.asciiz ""
	arr2:			.space 30720	# Space reserved for the prev label data
# Text Segment :
# This segment contains the logic and instructions for this program.
.text

# main: 
# This is the primary function that executes the entire code. 
# In this program we get a file name of maximum size 32 bits from the user.
# We open the file and send the data from the file to the parse function.
# Once Parsed, we call the print function to output results. We then close the file
# and finish execution.
#
# Arguments: None
#
main:
	#
	# Print Welcome message and request user for Name of the file to be read
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, prompt1       # Load address of Welcome message(Prompt1) string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its prompt1 msg).
	
	li $v0, 8		# Load constant 8 to $v0 implying we are going to recieve a string as input from user
	la $a0, fileName	# The label filename is a buffer space that will store the input from the user
	li $a1, 32		# We are allowing a length of 32 bytes of size for the file name 
	syscall			# Execute system call that takes a string input from the user and stores it in filename
	
	jal nameClean		# The filename obtained has a trailing \n character that needs to be removed so passing to this finction for cleanup
	
	li $v0, 13		# Load constant 13 to $v0 implying we are going to open a file
	la $a0, fileName	# Load address of filename string to $a0 so that it gets opened
	li $a1, 0		# Load constant 0 to $a1 so that the file is opened in read mode
	li $a2, 0		# set file mode which is unused here
	syscall			# Execute system call that opens the file in read mode
	move $s0 $v0		# save the file descriptor in $s0 
	
	li $v0 14		# Load constant 14 to $v0 implying we are going to read a file
	move $a0 $s0		# Load the file descriptor we obtained to $a0 thus poining the read to proper file
	la $a1 data		# provide a buffer address in memory that will hold the data from the file
	la $a2 30720		# We have set the limit of the file size to 30kb
	syscall			# Execute system call that reads file and loads it in data buffer 
	
	move $s1, $v0           # Save the file size as total no of bytes in $s1
	
	jal initialize		# We use certain counters to process data. We are initializing those so as to remove any garbage data.
	
	jal parseFileLoop	# This is a function where the file is parsed and the details are analysed to populate the counters

loopend:
	jal countOtherSymbols	# This is a function to check for other symbols and count them.
	ble $t0, $zero, output	# If file size is less than or equal to 0, jump to output label
	addi $t6, $t6, 1	# Here the file is not empty so the first line is also being counted towards number of lines
output:
	jal print		# This function prints the analysis onto console
	jal closeFile		# This function closes the file

	li $v0, 10		# Load constant 10 to $vo implying we r going to exit the program
	syscall			# Execute system call that looks at $v0(Here its exit) and thus it terminates the program.

# nameClean:
# The file name obtained from the user via console has a trailing \n character. This causes issues while opening the file
# Thus to fix this issue, we loop through the characters of the file and replace the \n character with a 0
#
# Arguments: filename 
nameClean:
	li $t0, 0       	# this value stores the loop counter
	li $t1, 32      	# Masimum size of filename to signify loop end
clean:
	beq $t0, $t1, L5			# Check if loop counter has reached the end. If so proceed to L5 label to return back
	lb $t2, fileName($t0)			# load the character corresponding to the counter from filename
	bne $t2, 10, incrementForCleanup	# if the character does not equal \n, jump to increment loop counter
	sb $zero, fileName($t0)			# the character is \n so replace that character with a 0
incrementForCleanup:
	addi $t0, $t0, 1			# Increment the loop counter
	j clean					# return the loop to starting. i.e clean label
L5:
	jr $ra					# Function is completed. Return to parent

# initialize:
# This functions initializes the counters so as to eliminate any garbage data stored in them
#
#Arguments: none
initialize:
	li $t0, 0		# Loop start counter
	li $t1, 0      		# Current Char of file
	li $t2, 0   		# Uppercase counter
	li $t3, 0   		# Lowercase counter 
	li $t4, 0   		# Number Symbols counter
	li $t5, 0   		# Other Symbols counter
	li $t6, 0   		# Lines of Text counter
	li $t7, 0   		# Signed Numbers counter
	li $t8, 0		# Next Char of file

# parseFileLoop:
# This function loops through each char of the file and passes it on to nested functions to analyse and increment counters
#
# Arguments: none
parseFileLoop:
	bge $t0, $s1, loopend           # Jump to loopend if end of file reached or if there is an error in the file
	lb $t1, data($t0)        	# Load next byte from file. This is the current character
	
	jal countUppercase              # This function checks for upper case letters and counts them
	jal countLowercase              # This function checks for lower case letters and counts them
	jal countNumberSymbols		# This function checks for number symbols and counts them
	jal countNoOfLines 		# This function checks for number of lines and counts them
	jal countSignedNumbers          # This function checks for signed numbers and counts them
	addi $t0, $t0, 1            	# Increment loop counter
	j parseFileLoop			# Returning back to start of the loop

# countUppercase:
# Check if the char lies between A to Z in Ascii table and if so increment uppercase counter
#
# Arguments: none
countUppercase:
	blt $t1, 0x41, L1		# Check if less than 'A' (0x41 = A in Ascii) and branch if true
	bgt $t1, 0x5a, L1		# Check if less than 'A' (0x5a = Z in Ascii) and branch if true
	addi $t2, $t2, 1		# Increment Uppercase counter as the value is within the ascii representation
L1:
	jr $ra				# Function is completed. Return to parent

# countLowercase:
# Check if the char lies between a to z in Ascii table and if so increment lowercase counter
#
# Arguments: none
countLowercase:
	blt $t1, 0x61, L2		# Check if less than 'A' (0x61 = a in Ascii) and branch if true
	bgt $t1, 0x7a, L2		# Check if less than 'A' (0x7a = z in Ascii) and branch if true
	addi $t3, $t3, 1		# Increment Lowercase counter as the value is within the ascii representation
L2:
	jr $ra				# Function is completed. Return to parent

# countNumberSymbols:
# Check if the char lies between 0 to 9 in Ascii table and if so increment number counter
#
# Arguments: none
countNumberSymbols:
	blt $t1, 0x30, L3		# Check if less than 'A' (0x30 = 0 in Ascii) and branch if true
	bgt $t1, 0x39, L3		# Check if less than 'A' (0x39 = 9 in Ascii) and branch if true
	addi $t4, $t4, 1		# Increment decimal counter as the value is within the ascii representation

L3:
	jr $ra				# Function is completed. Return to parent

# countOtherSymbols:
# From the total number of char, subtract the uppercase, lowercase and number char. Value obtained is the other symbols
#
# Arguments: none
countOtherSymbols:
	move $t5, $t0			# Copy the total character size of the file to a new variable $t5
	sub $t5, $t5, $t2		# Subtract all the uppercase characters from the total
	sub $t5, $t5, $t3		# Subtract all the lowercase characters from the total
	sub $t5, $t5, $t4		# Subtract all the number symbols from the total
	jr $ra				# Function is completed. Return to parent

# countNoOfLines:
# Count the number of \n in the file. This is not the complete value of no of lines. For that, you need to check if
# the file is empty or not. That is computed in the main function. Check the logic there
#
#
# Arguments: none
countNoOfLines:				
	bne $t1, 0x0a, L4		# Check if not equal to '\n' (0x0a = \n in Ascii) and branch if true
	addi $t6, $t6, 1		# Increment no of lines counter as the value is within the ascii representation
L4:
	jr $ra				# Function is completed. Return to parent

# countSignedNumbers:
# Check if char is + or -. If so check the next char and if it is a number, then increment the signed number counter
#
# Arguments: none
countSignedNumbers:
	beq $t1, 0x2b, checkNextForNumber	# Check if equal to '+' (0x2b = + in Ascii) and branch if true
	beq $t1, 0x2d, checkNextForNumber	# Check if equal to '-' (0x2d = - in Ascii) and branch if true
L6:
	jr $ra					# Function is completed. Return to parent
	
# checkNextForNumber:
# Get the next char by incrementing the current index and check if it is a number. If it is, increment the signed number counter
#
# Arguments: none
checkNextForNumber:
	addi $t8, $t0, 1			# Get the next character index and store it in $t8
	lb $t8, data($t8)			# Get the next character from file using index and store it in $t8
	blt $t8, 0x30, L6			# Check if the next char is less than '-' (0x30 = 0 in Ascii) and if so branch
	bgt $t8, 0x39, L6			# Check if the next char is greater than '+' (0x39 = 9 in Ascii) and if so branch
	addi $t7, $t7, 1			# As the char is a number, increment the counter
	j L6					# Jump to L6 so as to return back to parent function

# print:
# Print the appropriate messages and the values of counters associated to it
#
# Arguments: none
print:
	
	#
	# Save $ra on stack as we have a lot of nested calls which will cause the $ra to get overwritten
	#
	addi $sp $sp -4			# remove space the stack pointer anticipating the new value to be stored
	sw   $ra  -4($sp)		# Store $ra in the stack
	
	la $a0, totalCharMsg 		# Load address of totalCharMsg string to $a0 so that it gets printed on the console
	jal printMsg			# Call print function
	move $a0, $t0			# Load val of rem string to $t0 so that it gets printed on the console
	jal printNumberWithNewLine	# Call print function that also prints a new line
    
	la $a0, upperCaseMsg		# Load address of upperCaseMsg string to $a0 so that it gets printed on the console
	jal printMsg			# Call print function
	move $a0, $t2			# Load val of rem string to $t2 so that it gets printed on the console
	jal printNumberWithNewLine	# Call print function that also prints a new line
	
	la $a0, lowerCaseMsg		# Load address of lowerCaseMsg string to $a0 so that it gets printed on the console
	jal printMsg			# Call print function
	move $a0, $t3			# Load val of rem string to $t3 so that it gets printed on the console
	jal printNumberWithNewLine	# Call print function that also prints a new line
	
	la $a0, numberSymbolsMsg	# Load address of numberSymbolsMsg string to $a0 so that it gets printed on the console
	jal printMsg			# Call print function
	move $a0, $t4			# Load val of rem string to $t4 so that it gets printed on the console
	jal printNumberWithNewLine	# Call print function that also prints a new line
	
	la $a0, otherSymbolsMsg		# Load address of otherSymbolsMsg string to $a0 so that it gets printed on the console
	jal printMsg			# Call print function
	move $a0, $t5			# Load val of rem string to $t5 so that it gets printed on the console
	jal printNumberWithNewLine	# Call print function that also prints a new line

	la $a0, newLineMsg		# Load address of newLineMsg string to $a0 so that it gets printed on the console
	jal printMsg			# Call print function
	move $a0, $t6			# Load val of rem string to $t6 so that it gets printed on the console
	jal printNumberWithNewLine	# Call print function that also prints a new line
	
	la $a0, signedNumberMsg		# Load address of signedNumberMsg string to $a0 so that it gets printed on the console
	jal printMsg			# Call print function
	move $a0, $t7			# Load val of rem string to $t7 so that it gets printed on the console
	jal printNumberWithNewLine	# Call print function that also prints a new line
	
	#
	# Restore $ra and shrink stack
	#
	lw $ra  -4($sp)			# load $ra from the stack
	addi $sp $sp 4			# Add space back in the stack pointer

	jr $ra				# Function is completed. Return to parent

# printMsg:
# Prints a string msg present in $a0
#
# Arguments: none
printMsg:
	li $v0, 4			# Load constant 4 to $v0 implying we are going to print a string
	syscall				# Execute system call that looks at $v0(Here its print) and prints value in $a0.
	jr $ra				# Function is completed. Return to parent
	
# printNumberWithNewLine:
# Prints a number msg present in $a0 and then prints a new line
#
# Arguments: none
printNumberWithNewLine:
	li $v0, 1			# Load constant 4 to $v0 implying we are going to print a number
	syscall				# Execute system call that looks at $v0(Here its print) and prints value in $a0.
	li $v0, 4			# Load constant 4 to $v0 implying we are going to print a string
	la $a0, newLine			# Load newline char in $a0 so that it gets printed
	syscall				# Execute system call that looks at $v0(Here its print) and prints value in $a0.
	jr $ra				# Function is completed. Return to parent

# closeFile:
# Closes the file whose descriptor is in $s0
# Arguments: $s0 file descriptor
closeFile:
    # Close the file 
	li   $v0, 16       		# Load constant 16 to $v0 implying we are going to close a file
	move $a0, $s0      		# Load the file descriptor in $a0 thereby signalling the closing of the file
	syscall            		# Execute system call to close file
	jr $ra				# Function is completed. Return to parent
