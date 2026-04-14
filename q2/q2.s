.data
newline_str:
    .string "\n"
format_str:
    .string "%ld "

.text
.globl main
main:
    # grab stack space
    addi sp, sp, -64
    sd s0, 48(sp)               # save s0
    sd ra, 56(sp)               # save ra
    sd s2, 32(sp)               # save s2
    sd s1, 40(sp)               # save s1
    sd s4, 16(sp)               # save s4
    sd s3, 24(sp)               # save s3
    sd s5, 8(sp)                # save s5

    # a0 is argc, a1 is argv
    addi s0, a0, -1             # subtract 1 for the program name
    blez s0, .end               # if no args given, just dip

    mv s1, a1                   # keep argv safe in s1

    # allocate space for our stack array
    slli a0, s0, 3
    call malloc
    mv s5, a0                   # s5 holds the stack array

    # allocate space for our result array
    slli a0, s0, 3
    call malloc
    mv s4, a0                   # s4 holds the result array

    # allocate space for our array of numbers (n * 8 bytes)
    slli a0, s0, 3
    call malloc
    mv s2, a0                   # s2 holds our array pointer

    li s3, 0                    # i = 0

.read_loop:
    bge s3, s0, .read_done

    # get argv[i+1] string
    addi t0, s3, 1              # i + 1
    slli t0, t0, 3              # (i + 1) * 8
    add t0, s1, t0              # pointer to argv[i+1]
    ld a0, 0(t0)                # load the string pointer
    call atol                   # convert string to number, put in a0

    # store in arr[i]
    slli t1, s3, 3              # i * 8
    add t1, s2, t1              # address of arr[i]
    sd a0, 0(t1)                # store the number

    addi s3, s3, 1              # move to next index
    j .read_loop

.read_done:
    addi t0, s0, -1             # t0 = i = n - 1 (start from the end)
    li t4, 0                    # t4 acts as our stack size / pointer

.algo_loop:
    bltz t0, .algo_done         # stop when i < 0

.while_loop:
    # while stack not empty and arr[stack.top()] <= arr[i]
    beqz t4, .while_done        # stop if stack is empty

    # get the index at the top of the stack
    addi t1, t4, -1             # stack_size - 1
    slli t1, t1, 3              # multiply by 8
    add t1, s5, t1              # offset into stack array
    ld t2, 0(t1)                # t2 = stack.top()

    # grab arr[i]
    slli t5, t0, 3
    add t5, s2, t5
    ld t6, 0(t5)                # t6 holds arr[i]

    # grab arr[stack.top()]
    slli t3, t2, 3
    add t3, s2, t3
    ld t3, 0(t3)                # t3 holds arr[stack.top()]

    bgt t3, t6, .while_done     # stop if stack top is greater

    # pop it!
    addi t4, t4, -1             # decrease stack size
    j .while_loop

.while_done:
    # if stack isn't empty, result[i] = stack.top()
    beqz t4, .stack_empty

    addi t1, t4, -1             # stack_size - 1
    slli t1, t1, 3
    add t1, s5, t1
    ld t2, 0(t1)                # load the index
    j .set_result

.stack_empty:
    li t2, -1                   # default to -1 if empty

.set_result:
    slli t1, t0, 3              # i * 8
    add t1, s4, t1              # address of result[i]
    sd t2, 0(t1)                # save the result

    # stack.push(i)
    slli t1, t4, 3              # stack_size * 8
    add t1, s5, t1              # address for the new stack element
    sd t0, 0(t1)                # put current index onto stack
    addi t4, t4, 1              # increase stack size

    addi t0, t0, -1             # go to the previous element
    j .algo_loop

.algo_done:
    li s3, 0                    # reset loop index

.print_loop:
    bge s3, s0, .print_done

    la a0, format_str           # get ready to print
    slli t1, s3, 3              # i * 8
    add t1, s4, t1              # address of result[i]
    ld a1, 0(t1)                # grab the result number
    call printf                 # print it

    addi s3, s3, 1              # bump index
    j .print_loop

.print_done:
    la a0, newline_str          # print a newline at the very end
    call printf

    # free all the memory we grabbed
    mv a0, s4
    call free
    mv a0, s5
    call free
    mv a0, s2
    call free

.end:
    li a0, 0                    # return 0
    # bring back our preserved registers
    ld s5, 8(sp)
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64             # clean up stack space
    ret