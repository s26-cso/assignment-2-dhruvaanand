.data
mode: .string "r"
file_name: .string "input.txt"
no_msg: .string "No\n"
yes_msg: .string "Yes\n"

.text
.globl main
main:
    # grab stack space
    addi sp, sp, -48
    sd s3, 8(sp)        # save s3
    sd s2, 16(sp)       # save s2
    sd s1, 24(sp)       # save s1
    sd s0, 32(sp)       # save s0
    sd ra, 40(sp)       # save ra

    # open the joke file
    la a0, file_name
    la a1, mode
    call fopen
    mv s0, a0           # keep file ptr in s0

    # find where the file ends
    li a1, 0
    li a2, 2            # SEEK_END
    mv a0, s0           # a0 has file ptr
    call fseek
    
    # get total file size
    mv a0, s0
    call ftell
    mv s1, a0           # s1 = size (n)

    # check if the last char is a newline to avoid bugs
    li a2, 0            # SEEK_SET
    addi a1, s1, -1
    mv a0, s0
    call fseek
    mv a0, s0
    call fgetc
    li t0, 10           # ascii for '\n'
    bne a0, t0, .start_logic
    addi s1, s1, -1     # ignore newline if found

.start_logic:
    addi s3, s1, -1     # j = n - 1 (right)
    li s2, 0            # i = 0 (left)

.loop:
    # stop if pointers meet or cross
    bge s2, s3, .is_palindrome
    
    # read char from the left index
    mv a1, s2
    li a2, 0            # SEEK_SET
    mv a0, s0
    call fseek
    mv a0, s0
    call fgetc
    mv t0, a0           # char 1 in t0
    
    # read char from the right index
    mv a1, s3
    li a2, 0            # SEEK_SET
    mv a0, s0
    call fseek
    mv a0, s0
    call fgetc
    mv t1, a0           # char 2 in t1
    
    # compare them
    bne t0, t1, .not_palindrome
    
    # move both pointers
    addi s2, s2, 1
    addi s3, s3, -1
    j .loop

.is_palindrome:
    la a0, yes_msg
    call printf
    j .cleanup

.not_palindrome:
    la a0, no_msg
    call printf
    j .cleanup

.cleanup:
    mv a0, s0
    call fclose

    # restore registers and leave
    li a0, 0
    ld s3, 8(sp)
    ld s2, 16(sp)
    ld s1, 24(sp)
    ld s0, 32(sp)
    ld ra, 40(sp)
    addi sp, sp, 48
    ret