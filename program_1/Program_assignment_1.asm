# File Name: Program_assignment_1.asm
# Author: Pavan Kumar (pavan.kumar@utdallas.edu)
# Modification History
# - This code was first written on 10th September 2021.
# - The Code has been submitted to be reviewed by Dr. Richard Goodrum on 13th September 2021 

# Procedures:
# main: Recieves two numbers as inputs from the user and 
#       does airthematic operations (addition, substraction, multiplication & division)

# Data Segment :
# This segment is where data is stored in RAM. It is set as key value pairs
# syntax: label: .type value(s)
#
# Types Used :
# - ascii  : This is used to declare a string which does not have a null at the ed. This causes the next declared string to 
#            be part of the same label. Used here to have a multi-line initialization of label.
# - asciiz : This is used to declare a null terminated string. The null here is needed to imply the end of the string.
#            The charecters in the string is encoded using ASCII code (American Standard Code for Information Interchange) 
.data 

	# Below I have initialised few messages that willl help provide a discriptive output to the user
	prompt1:	
		.ascii  "Welcome to Programming Assignment!!"
		.ascii  "\n\nThis program will take two integers (A & B) as input from the user and output the airthematic"
		.ascii  "\noperations performed on them."
		.ascii  "\nNote: The program is limited to numbers between -2,147,483,648 to 2,147,483,647."
		.ascii  "\nIf the multiplication of the two inputs yield values greater than this range, overflows can be possble."
		.asciiz "\n\nPlease enter an integer value for A: "

	prompt2:.asciiz "Please enter an integer value for B: "
	sum:	.asciiz "\nA + B: " 
	sub1:	.asciiz "\nA - B: "
	sub2:	.asciiz "\nB - A: "
	multi:	.asciiz "\nA * B: "
	div1:	.asciiz "\nA / B: Quotient: "
	rem:	.asciiz " Reminder: "
	div2:	.asciiz "\nB / A: "
	
# Text Segment :
# This segment contains the logic and instructions for this program.
.text

# main: 
# This is the primary function that executes the entire code. 
# In this program we get two integers between –2,147,483,648 to 2,147,483,647. 
# However due to limitation on multiplication size of 32 bit so if the value 
# of the multiplication is more than 2,147,483,647, there could be issues of overflow.
# 
# Arguments: None
#
main:
	#
	# Print Welcome message and request user for value of first integer
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, prompt1       # Load address of Welcome message(Prompt1) string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its prompt1 msg).
	li   $v0, 5		# Load $v0 with 5 indicating we are requesting an integer from the user via console
	syscall			# Execute system call that looks at $v0(Here its accept integer from console) and waits for user to input a integer number
	move $t0 $v0		# Store the value of A recieved from user in a temporary variable register $t0
	
	#
	# Request User for value of second integer
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, prompt2	# Load address of prompt2 string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its prompt2 msg).
	li   $v0, 5		# Load $v0 with 5 indicating we are requesting an integer from the user via console
	syscall			# Execute system call that looks at $v0(Here its accept integer from console) and waits for user to input a integer number
	move $t1 $v0		# Store the value of B recieved from user in a temporary variable register $t1
	
	#
	# Compute the sum of integers A & B and print the output on console
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, sum		# Load address of sum string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its sum msg).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	add  $a0, $t0, $t1	# Add both intigers taken from the user and save the sum in variable $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its sum of integers).
	
	#
	# Compute the value of A - B and then print the output on console
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, sub1		# Load address of sub1 string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its sub1 msg).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	sub  $a0, $t0, $t1	# Subtract B from A and save the value in variable $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its diff of B from A).
	
	#
	# Compute the value of B - A and then print the output on console
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, sub2		# Load address of sub2 string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its sub2 msg).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	sub  $a0, $t1, $t0	# Subtract A from B and save the value in variable $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its diff of A from B).
	
	#
	# Compute the value of B * A and then print the output on console
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, multi		# Load address of multi string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its multi msg).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	mult $t1, $t0		# Multiply the intigers A & B. Their values will be stored in $hi & $lo based on the size of the value
	mflo $a0		# We only consider the low value. i.e the output of the prev multiplication must be at most 32bits in size. We save that value in register $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its value of A * B).
	
	#
	# Compute the value of A/B and then print the output on console
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, div1		# Load address of div1 string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its div1 msg).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	div  $t0, $t1		# Divide the integer A by B. The Quotient will be stored in $lo & reminder in $hi.
	mflo $a0		# Move the quotient stored in $lo to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its Quotient of A/B).
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string.
	la   $a0, rem		# Load address of rem string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its rem string).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	mfhi $a0		# Move the reminder stored in $hi to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its reminder of A / B).
	
	#
	# Compute the value of B/A and then print the output on console
	#
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string
	la   $a0, div2		# Load address of div2 string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its div2 msg).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	div  $t1, $t0		# Divide the integer B by A. The Quotient will be stored in $lo & reminder in $hi.
	mflo $a0		# Move the quotient stored in $lo to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its Quotient of B / A).
	li   $v0, 4		# Load constant 4 to $v0 implying we are going to print a string.
	la   $a0, rem		# Load address of rem string to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its rem string).
	li   $v0, 1		# Load constant 1 to $v0 implying we are going to print a integer
	mfhi $a0		# Move the reminder stored in $hi to $a0 so that it gets printed on the console
	syscall			# Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its reminder of B / A).
	
	#
	# Program has completed. Exit
	#
	li   $v0, 10		# Load constant 10 to $vo implying we r going to exit the program
	syscall			# Execute system call that looks at $v0(Here its exit) and thus it terminates the program.

