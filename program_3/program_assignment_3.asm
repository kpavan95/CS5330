# File Name: Program_assignment_3.asm
# Author: Pavan Kumar (pavan.kumar@utdallas.edu)
# Modification History
# - This code was first written on 12th November 2021.
# - The Code has been submitted to be reviewed by Dr. Richard Goodrum on 15nd October 2021
#
# Saved Registers Used:
# $s0 = store descriptor of file
# $s1 = store input Type 
# $s2 = store count of input value
# $s3 = store output Type
# $s4 = store negetive sign
# $s5 = store input value
# $s6 = store numerical base of Input Type and then the base of Output Type
#
# Procedures:
# main: Opens the file, reads the data and outputs in proper format in console
# readNextByte: reads the next byte in the file
# openFile: this function asks user to input file name and then opens the file
# getBase: This function returns the numerical base of the type representation of digits
# obtainAndPrintNextValue: This function reads bytes from file till valid byte(non-whitespace) is encountered. It also prints all that it reads
# atoi: converts the value to decimal number based on base
#
#
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
        # Constants
        colonSpace: .asciiz ": "
        semiColonSpace: .asciiz "; "
        newline: .asciiz "\n"

# Text Segment :
# This segment contains the logic and instructions for this program.
        .text
# main:
# Author: Pavan Kumar
# Modification History
#       Initial Version, 13 Nov 2021
# Description: This is the primary function that executes the entire code. 
# In this program we call the function to get file name
# read 1 byte at a time
# parse each line in a loop and decern variables per syntax
# convert the input value to desired output value and print it on console
# close the file and finish execution.
#
# Arguments: None
main:
        jal openFile                          # invoke openFile function to get file name from user and open it
        move $s0, $v0                         # store the file descriptor in saved register $s0
        
readLineloop:
        li $s1, 0                             # initialise $s1 to 0
        li $s2, 0                             # initialise $s2 to 0
        li $s3, 0                             # initialise $s3 to 0
        li $s4, 0                             # initialise $s4 to 0
        li $s5, 0                             # initialise $s5 to 0

#
#                              INPUT SEGMENT
#
        # Read Input Type
        move $a0, $s0                         # Set file descriptor in $a0 so that it is passed as input parameter to function in next line
        jal readNextByte                      # invoke readNextByte function to get the next byte in the file
        move $s1, $v1                         # store the byte read in saved register $s1
        beq $v0, $0, fileEnd                  # Check if end of file is reached. If so jump to end
        
        # Print Input Type
        li $v0, 11                            # Load constant 11 to $v0 implying we are going to print a character
        move $a0, $s1                         # Load input type to $a0 so that it gets printed on the console
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its input type).
        li $v0, 4                             # Load constant 4 to $v0 implying we are going to print a string
        la $a0, colonSpace                    # Load address of constant colonSpace to $a0 so that it gets printed on the console
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its constant colonSpace).
        
        # Read Input Value digits count
        move $a0, $s0                         # Set file descriptor in $a0 so that it is passed as input parameter to function in next line
        jal readNextByte                      # invoke readNextByte function to get the next byte in the file
        subi $s2, $v1, 48                     # Convert the read byte from ascii to integer and store in saved register $s2
        
        #
        # Check for next charecter and appropriately add to digits count or output type
        # This is because the digits can be either 1 char or 2 char
        # 
        jal readNextByte                      # invoke readNextByte function to get the next byte in the file
        blt $v1, 0x30, storeOutputType        # If less that sumbol 0 in ascii table (0x30 = 0 in ascii), jump to storeOutputType as it is not number
        bgt $v1, 0x39, storeOutputType        # If more that sumbol 9 in ascii table (0x30 = 0 in ascii), jump to storeOutputType as it is not number
        subi $v1, $v1, 48                     # Convert the read byte from ascii to integer
        mul $s2, $s2, 10                      # multiply $s2 by 10 as the digit count is double digits
        add $s2, $s2, $v1                     # add the 2nd digit to $s2 to complete reading digit count

        # Read and Save Output Type
readOutputType:
        jal readNextByte                      # invoke readNextByte function to get the next byte in the file. which will be output type
storeOutputType:
        move $s3,$v1                          # store the byte read in saved register $s3
        
        #
        # Skip ': '
        # As per input syntax, the next two characters just server delimiter purpose so we can skip them
        #
        jal readNextByte                      # invoke readNextByte function
        jal readNextByte                      # invoke readNextByte function
        
        #
        # Read Input Value
        # While reading the Input value, we need to ignore the white space. Also given the presence of whitespace, the character length of the input 
        # value can be too large so we output it in console as we read it so thatwe need not save it in buffer and waste memory
        #
        jal obtainAndPrintNextValue           # invoke obtainAndPrintNextValue function to get the next valid byte (non whitespace) in the file.
        beq $v1, 0x2b, readFirstValue	      # Check if equal to '+' (0x2b = + in Ascii) and branch if true
        beq $v1, 0x2d, setnegetiveSign        # Check if equal to '-' (0x2d = + in Ascii) and branch if true
        j storeFirstValue                     # Neither positive or negetive meaning it's a digit so we jump to store the value
setnegetiveSign:
        li $s4, 1                             # We set the flag to negetive

readFirstValue:
        jal obtainAndPrintNextValue           # invoke obtainAndPrintNextValue function to get the next valid byte (non whitespace) in the file.
storeFirstValue:
        move $s5,$v1                          # Store the obtained value in saved register $s5
        
        # Get Base
        move $a1, $s1                         # Put the input type in $a1 so that it gets passed as a parameter into the function
        jal getBase                           # Invoke getBase function to get the numerical base of the type
        move $s6, $v0                         # store the base in saved register $s6 
        
        # atoi
        move $a1, $s6                         # Put the base in $a1 so that it gets passed as a parameter into the function
        move $a2, $s5                         # Put the input value in $a2 so that it gets passed as a parameter into the function
        jal atoi                              # Invoke atoi function that converts the input value from ascii based on the base
        move $s5, $v0                         # Save the converted input value back in saved register $s5
        
        subi $t3, $s2, 1                      # We need to iterate to the digit count - 1 (As we have already read the first char) to read input value
        li $t2, 0                             # Initialise the loop counter

        # Loop to read all input values
valueStoreLoop:
        bge $t2, $t3, valueStoreLoopEnd       # If counter exceeds the digts count, end the loop
        mul $s5, $s5, $s6                     # multiply Input value with base as we are increasing the digits place to accept the next read value
        jal obtainAndPrintNextValue           # invoke obtainAndPrintNextValue function to get the next valid byte (non whitespace) in the file.
        
        # atoi
        move $a1, $s6                         # Put the base in $a1 so that it gets passed as a parameter into the function
        move $a2, $v1                         # Put the input value in $a2 so that it gets passed as a parameter into the function
        jal atoi                              # Invoke atoi function that converts the input value from ascii based on the base
        add $s5, $s5, $v0                     # Save the converted input value back in saved register $s5
        
        addi $t2, $t2, 1                      # Increment the loop counter
        j valueStoreLoop                      # Jump back to start of loop
valueStoreLoopEnd:

        #
        # End Of Line Loop :We have read all that we need for the line but there can 
        # be more un-necessary chararcters so we need to loop till end of the line
        #
EOLLoop:
        jal readNextByte                      # invoke readNextByte function 
        beq $v1, 0x0a, EOLLoopEnd             # If newline (0x0a = \n in ascii), break the loop
        beq $v0, $0, EOLLoopEnd               # If end of file (file descriptor is 0), break the loop
        j EOLLoop                             # Jump back to start of loop
EOLLoopEnd:
        
        # If the input value had a negetive symbol, we need to negate the input value
negation:        
        bne $s4, 1, negationEnd               # If negetive symbol is not present, jump to next segment
        sub $s5, $0, $s5                      # Negate the input value in $s5
negationEnd:
        
#
#                              OUTPUT SEGMENT
#
# Data Segment :
# This segment is where data is stored in RAM. It is set as key value pairs
# syntax: label: .type value(s)
#
# Types Used :
# - space  : This is used to allocate certain bytes (Digits mentioned) in memory
        .data
        outputValue: .space 41                # Buffer to hold the output value

# Text Segment :
# This segment contains the logic and instructions for this program.
        .text
output:
        
        la $t2, outputValue                   # initialise $t2 to address of outputValue variable

#
# Output value may have data from previous loop so we reset that here
#
        li $t1, 0                             # initialise counter $t1 to 0
clearOutputValue:
        beq $t1, 40, clearOutputValueEnd      # check if loop completed. If so jump to end
        sb $0, 0($t2)                         # Put $0 in current address
        addi $t2, $t2, 1                      # Increment the address
        addi $t1, $t1, 1                      # Increment the loop counter
        j clearOutputValue                    # Jump back to start of loop
clearOutputValueEnd:

        # Compute and Store Output Type's numerical base
        move $a1, $s3                         # Put the output type in $a1 so that it gets passed as a parameter into the function
        jal getBase                           # Invoke getBase function to get the numerical base of the type
        move $s6, $v0                         # store the base in saved register $s6
        
        la $t2, outputValue                   # Load address of outputValue
        addi $t2, $t2, 39                     # add 39 to address as we are filling the string from back

        # Initialise variables
        move $t1, $s5                         # Store the input value in temporary variable $t1 so that it can be computed on
        li $t3, 0                             # initialise $t3(Used for storing remainder of division) to 0
        li $t4, 0                             # initialise $t4(Used for storing counter based on base) to 0
        li $t5, 0                             # initialise $t4(Used for storing loop counter) to 0
                 
        # If the number is negetive, we make it positive for deriving the output
        # The point is for binary, Decimal and Hex, only the moduli of the value is needed. The sign is to be removed
        bge $t1, $0, binaryCounter            # If not negetive, jump this segment
        sub $t1, $0, $t1                      # Subtract the value from 0 so that it becomes positive
        # For Hex and Binary, the negetive sign is part of the number as it is represented in 2's complement. As we need to output the
        # 2's complement of the positive part of input value, we use the following logic
        # 1. subtract 1 from the input value.
        # 2. for each output digit obtained, subtract it from the base of the output type to get the complement
        beq $s6, 10, binaryCounter            # If output is in decimal, we can skip this segment
        subi $t1, $t1, 1                      # We subtract 1 from the input value which just became positive as it helps to obtain the 2's compliment
        
        # Get the maximum extent to which the loop must run
binaryCounter:
        bne $s6, 2, decimalCounter            # If Output type is not binary, skip next line
        addi $t4, $t4, 32                     # For Binary, 32 digits are needed so loop should happen 32 times
decimalCounter:
        bne $s6, 10, hexCounter               # If Output type is not decimal, skip next line
        addi $t4, $t4, 10                     # For Decimal, 10 digits are needed as max value is 2ˆ31 = 2147483648
hexCounter:                                
        bne $s6, 16, outputValueloop          # If Output type is not hex, skip next line
        addi $t4, $t4, 8                      # For Hex, 8 digits are needed so loop should happen 8 times

outputValueloop:
        bge $t5, $t4, outputValueloopExit     # Exit loop if counter reaches the required base counter
        bnez $t1, divisionByBase              # When the input value is fully processed, go to next line else skip it
        beq $s6, 10, outputValueloopExit      # For decimal, leading 0's are not needed so we can end the loop
        
divisionByBase:
        div $t1, $s6                          # Divide by base to split into quotient and remainder
        mfhi $t3                              # Store remainder in $t3
        mflo $t1                              # Store quotient back in $t1
        
        # Based on logic explained before, we are negating the remainder for 2s complement for binary and hex
twosComplementConversion:
        bge $s5, $0, hexOutput                # If the original Input value is positive, this segment is skipped
        beq $s6, 10, hexOutput                # For decimal, this segment is skipped
        # to get the complement value, we need to subtract the value from (Base-1)
        sub $t3, $s6, $t3                     # subtract the remained from the base of output type to get the complement
        subi $t3, $t3, 1                      # subtract 1 so complete the equation. Now $t3 has the complement
        
        # for hex, we need to get the proper ascii symbol as it can lie in 0-9 or in a-f
hexOutput:
        bne $s6, 16, Sum                      # If not hex, skip this segment
        ble $t3, 9, Sum                       # if less than or equal to nine, same as normal digits so we can skip this segment
        addi $t3, $t3, 0x37                   # Here the value is from a-f so we are adding 0x37 (9 lower than A in ascii as first 9 values are numerical digits)
        b sumEnd                              # Conversion to digit symbols can be skipped. Directly store the obtained value

Sum:
         addi $t3, $t3, 0x30                  # add 0x30 ('0' in ascii) to result
sumEnd:
         
         # Delimiter: As part of bonus points, we need to put delimiter of ',' for decimal after every 3 digits and ' ' for binary and hex after every 4 digits
         beqz $t5 storeOutputValue            # If t5 is 0, the following computaion will work and delimiter will be set at start of value so if 0, we skip the segment
setDelimiterDecimal:
        bne $s6, 10, setDelimiterHexOrBinary  # If not decimal, skip to binary & Hex delimiter
        li $t8, 3                             # Delimiter has to be set after every 3 digits
        div $t5, $t8                          # check if the index is divisible by 3
        mfhi $t7                              # store the remainder from $hi to $t7
        bne $t7, 0, storeOutputValue          # if counter is not a multiple of 3 skip this segment
        li $t8, 0x2c                          # load 0x2c (',' in ascii) into variable $t8
        sb $t8, 0($t2)                        # store delimiter into current address of output value
        subi $t2, $t2, 1                      # decrement address counter

setDelimiterHexOrBinary:
        li $t8, 4                             # Delimiter has to be set after every 4 digits
        div $t5, $t8                          # check if the index is divisible by 4
        mfhi $t7                              # store the remainder from $hi to $t7
        bne $t7, 0, storeOutputValue          # if counter is not a multiple of 4 skip this segment
        li $t8, 0x20                          # load 0x20 (' ' in ascii) into variable $t8
        sb $t8, 0($t2)                        # store delimiter into current address of output value
        subi $t2, $t2, 1                      # decrement address counter
        
storeOutputValue:
        sb $t3, 0($t2)                        # store output digit into current address of output value
        subi $t2, $t2, 1                      # decrement address counter
        addi $t5, $t5, 1                      # increment loop counter
        j outputValueloop                     # Jump back to start of loop

outputValueloopExit:

        # Set '-' symbol if necessary
        bne $s6, 10, printOutputValue         # Only for decimal so if not decimal, skip this segment
        bge $s5, 0, printOutputValue          # Only for negetive input vlue so if original input value is not negetive, skip this segment
        li $t3, '-'                           # load '-' into variable $t3
        sb $t3, 0($t2)                        # store negetive symbol in the current address of output value
        subi $t2, $t2, 1                      # decrement address counter
        
printOutputValue:
        li $v0, 4                             # Load constant 4 to $v0 implying we are going to print a string
        la $a0, semiColonSpace                # Load address of constant semiColonSpace to $a0 so that it gets printed on the console
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its constant semiColonSpace).
        li $v0, 11                            # Load constant 11 to $v0 implying we are going to print a character
        move $a0, $s3                         # Load output type to $a0 so that it gets printed on the console
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its output type).
        li $v0, 4                             # Load constant 4 to $v0 implying we are going to print a string
        la $a0, colonSpace                    # Load address of constant colonSpace to $a0 so that it gets printed on the console
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its constant colonSpace).
        addi $t2, $t2, 1                      # increment address of output value so that it points to first charecter
        move $a0, $t2                         # Load output value to $a0 so that it gets printed on the console
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its output value).
        la $a0, newline                       # Load address of constant newline to $a0 so that it gets printed on the console
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its constant newline).
        
        j readLineloop                        # Jump back to start of loop
        
fileEnd:   

# Close the file 
        li   $v0, 16                          # Load constant 16 to $v0 implying we are going to close a file
        move $a0, $s0                         # Load the file descriptor in $a0 thereby signalling the closing of the file
        syscall                               # Execute system call to close file     

# Standard Termination
        li $v0, 10                            # Load constant 10 to $vo implying we are going to exit the program
        syscall                               # Execute system call that looks at $v0(Here its exit) and thus it terminates the program.
        
# Read Next Byte (readNextByte)
# Dr. Richard A. Goodrum, Ph.D.
# Modification History
#        Initial Version, 9 Nov 2021
# Description: Read the next byte from the filenoted by the descriptor
#
# Arguments
# $a0 = I/P int File Descriptor
# $v0 = O/P int Number of bytes read
# $v1 = O/P char Byte read
#
# Data Segment :
# This segment is where data is stored in RAM. It is set as key value pairs
# syntax: label: .type value(s)
#
# Types Used :
# - space  : This is used to allocate certain bytes (Digits mentioned) in memory
# - word   : This allocates 4 bytes of memory
        .data
buffer:         .space       1                # buffer to hold data from file. Here 1 byte is read at a time
readLength:     .word        1                # length of bytes read from file. Here it is 1
# Text Segment :
# This segment contains the logic and instructions for this program.
        .text
readNextByte:
        la $a1, buffer                        # provide a buffer address in memory that will hold the data from the file 
        la $a2, readLength                    # set the address of number of bytes to be read.
        lb $a2, 0($a2)                        # set the value from the address of number of bytes to be read. Here it is 1
        li $v0, 14                            # Load constant 14 to $v0 implying we are going to read a file
        syscall                               # Execute system call that reads file and loads it in data buffer

        lbu $v1, 0($a1)                       # store the read byte in $v1 so that it returns to parent function

        jr $ra                                # Function is completed. Return to parent
        
# Open File (openFile)
# Dr. Richard A. Goodrum, Ph.D.
# Modification History
#       Initial Version, 9 Nov 2021 provided in class
# Description: Prompt the user for a filename, clean it of newline, then open it.
#
# Arguments
# $v0 O/P int File Descriptor
#
# Data Segment :
# This segment is where data is stored in RAM. It is set as key value pairs
# syntax: label: .type value(s)
#
# Types Used :
# - space  : This is used to allocate certain bytes (Digits mentioned) in memory
# - word   : This allocates 4 bytes of memory
# - asciiz : This is used to declare a null terminated string. The null here is needed to imply the end of the string.
#            The characters in the string is encoded using ASCII code (American Standard Code for Information Interchange) 
        .data
filenameLength: .word       128
filename:       .space      128
prompt:	        .asciiz     "Enter file name: "
# Text Segment :
# This segment contains the logic and instructions for this program.
        .text
openFile:
        la $a0, prompt                        # Load address of Welcome message(Prompt) string to $a0 so that it gets printed on the console
        li $v0, 4                             # Load constant 4 to $v0 implying we are going to print a string
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its prompt msg).

        li $v0, 8                             # Load constant 8 to $v0 implying we are going to recieve a string as input from user
        la $a0, filename                      # The label filename is a buffer space that will store the input from the user
        la $a1, filenameLength                # set the address of max length of filename.
        lw $a1, 0($a1)                        # We are allowing a length of 128 bytes of size for the file name 
        syscall                               # Execute system call that takes a string input from the user and stores it in filename

        # The file name obtained may have \n at the end so we need to clean that up
        add $a1, $a0, $a1                     # Set loop end to address of file name plus filenameLength
cleaningLoop:
        beq $a0, $a1, cleaningDone            # if the fileLength is completely iterated, break the loop
        lbu $t0, 0($a0)                       # load charecter of file name at current address
        beq $t0, '\n', badCharacter           # check if newline char. If so skip to section that deals with it
        addi $a0, $a0, 1                      # increment the address by 1 which acts as the counter for this loop
        j cleaningLoop                        # jump back to start of loop

badCharacter:
        sb $0, 0($a0)                         # reset the char in current address of file name replacing \n with 0

cleaningDone:

        la $a0, filename                      # Load address of filename string to $a0 so that it gets opened
        li $a1, 0                             # Load constant 0 to $a1 so that the file is opened in read mode
        li $a2, 0                             # set file mode which is unused here
        li $v0, 13                            # Load constant 13 to $v0 implying we are going to open a file
        syscall                               # Execute system call that opens the file in read mode

        jr $ra                                # Function is completed. Return to parent

# Get Base (getBase)
# Pavan
# Modification History
#       Initial Version, 13 Nov 2021
# Description: get the base of the type from letter
#
# Arguments
# $a1 I/P char Type of number representation. b or B for binary, d or D for decimal, h or H for hexadecimal
# $v0 O/P int  Base of the type. 2 for binary, 10 for decimal, 16 for hexadecimal
getBase:
        beq $a1, 0x62, binaryBase             # If the base is 0x62('b' in ascii), jump to binary base segment
        beq $a1, 0x42, binaryBase             # If the base is 0x42('B' in ascii), jump to binary base segment
        beq $a1, 0x64, decimalBase            # If the base is 0x64('d' in ascii), jump to decimal base segment
        beq $a1, 0x44, decimalBase            # If the base is 0x44('D' in ascii), jump to decimal base segment
        beq $a1, 0x68, hexBase                # If the base is 0x68('h' in ascii), jump to hex base segment
        beq $a1, 0x48, hexBase                # If the base is 0x48('H' in ascii), jump to hex base segment
        
binaryBase:
        li $v0, 2                             # Binary base is 2 so load it in $v0 which becomes the return value
        j getBaseEnd                          # jump to end of function
        
decimalBase:
        li $v0, 10                            # Decimal base is 10 so load it in $v0 which becomes the return value
        j getBaseEnd                          # jump to end of function
        
hexBase:
        li $v0, 16                            # Hex base is 16 so load it in $v0 which becomes the return value
        
getBaseEnd:
        jr $ra                                # Function is completed. Return to parent
        
# Obtain and Print Next Value (obtainAndPrintNextValue)
# Author: Pavan Kumar
# Modification History
#       Initial Version, 13 Nov 2021
# Description: get the next valid value. i.e any value that is not a white space 
#
# Arguments
# $a0 	I/P int File Descriptor
# $v0	O/P int Number of bytes read
# $v1	O/P char Byte read
obtainAndPrintNextValue:
        # store $ra in stack
        addi $sp $sp -4                       # remove space the stack pointer anticipating the new value to be stored
        sw   $ra  -4($sp)                     # Store $ra in the stack
        
readnextvalidByteLoop:
        jal readNextByte                      # invoke readNextByte function to get the next byte in the file
        
        # print value
        move $t0, $a0                         # store $a0 in temp variable
        move $t1, $v0                         # store $v0 in temp variable
        
        move $a0, $v1                         # Load value read to $a0 so that it gets printed on the console
        li $v0, 11                            # Load constant 11 to $v0 implying we are going to print a character
        syscall                               # Execute system call that looks at $v0(Here its print) and prints value in $a0(Here its value read).
        
        move $a0, $t0                         # put back the value of $a0 from temp variable
        move $v0, $t1                         # put back the value of $v0 from temp variable
        # End Print value
        
        # remain in loop if whitespace
        beq $v1, 0x20, readnextvalidByteLoop  # if space, branch to start of function and repeat the process. 0x20 = space in ascii
        beq $v1, 0x09, readnextvalidByteLoop  # if tab, branch to start of function and repeat the process. 0x09 = tab in ascii
        beq $v1, 0x0a, readnextvalidByteLoop  # if new line, branch to start of function and repeat the process. 0x0a = new line in ascii
        beq $v1, 0x0b, readnextvalidByteLoop  # if vertical tab, branch to start of function and repeat the process. 0x0b = vertical tab in ascii
        beq $v1, 0x0c, readnextvalidByteLoop  # if form feed, branch to start of function and repeat the process. 0x0c = form feed in ascii
        beq $v1, 0x0d, readnextvalidByteLoop  # if carriage return, branch to start of function and repeat the process. 0x0d = carriage return in ascii
        
        # fetch $ra from stack
        lw $ra  -4($sp)                       # load $ra from the stack
        addi $sp $sp 4                        # Add space back in the stack pointer
        
        # return to parent function
        jr $ra                                # Function is completed. Return to parent

# Ascii to Integer (atoi)   
# Author: Pavan Kumar
# Modification History
#       Initial Version, 13 Nov 2021
# Description: convert the value to decimal number based on base
#
# Arguments
# $a1 	I/P base value
# $a2	I/P Ascii value
# $v0	O/P decimal value
atoi:
        bne $a1, 16, numericalatoi            # If base is not hex, skip directly to handling digit symbols
        ble $a2, '9', numericalatoi           # If value less than value of '9' in ascii, skip directly to handling digit symbols
        
smallHex:
        blt $a2, 'a', capitalHex              # If value is less than value of 'a' in ascii, jump to handling capital values
        sub $v0, $a2, 'a'                     # Convert from symbol to integer by subtracting the value of 'a' in ascii
        addi $v0, $v0, 10                     # Add 10 as we need to account for the digit symbols in hex
        j atoiEnd                             # Jump to end of function
        
capitalHex:
        sub $v0, $a2, 'A'                     # Convert from symbol to integer by subtracting the value of 'A' in ascii
        addi $v0, $v0, 10                     # Add 10 as we need to account for the digit symbols in hex
        j atoiEnd                             # Jump to end of function
        
numericalatoi:
        sub $v0, $a2, '0'                     # Convert from symbol to integer by subtracting the value of '0' in ascii

atoiEnd:
        jr $ra                                # Function is completed. Return to parent
