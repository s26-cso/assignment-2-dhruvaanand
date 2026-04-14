.data
newline_str:
    .string "\n"
format_no_space:
    .string "%ld"
format_with_space:
    .string " %ld"

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
    addi s0, a0, -1             # n = argc - 1
    blez s0, .end               # if no args given, just dip

    mv s1, a1                   # keep argv safe in s1

    # allocate space for stack, result, and numbers
    slli a0, s0, 3
    call malloc
    mv s5, a0                   # s5 = stack array

    slli a0, s0, 3
    call malloc
    mv s4, a0                   # s4 = result array

    slli a0, s0, 3
    call malloc
    mv s2, a0                   # s2 = numbers array

    li s3, 0                    # i = 0
.read_loop:
    bge s3, s0, .read_done
    addi t0, s3, 1              # i + 1
    slli t0, t0, 3
    add t0, s1, t0
    ld a0, 0(t0)                # load argv[i+1]
    call atol
    slli t1, s3, 3
    add t1, s2, t1
    sd a0, 0(t1)                # store in arr[i]
    addi s3, s3, 1
    j .read_loop

.read_done:
    addi t0, s0, -1             # i = n - 1
    li t4, 0                    # stack size = 0
.algo_loop:
    bltz t0, .algo_done
.while_loop:
    beqz t4, .while_done
    addi t1, t4, -1
    slli t1, t1, 3
    add t1, s5, t1
    ld t2, 0(t1)                # t2 = stack.top()
    
    slli t5, t0, 3
    add t5, s2, t5
    ld t6, 0(t5)                # arr[i]
    
    slli t3, t2, 3
    add t3, s2, t3
    ld t3, 0(t3)                # arr[stack.top()]
    
    bgt t3, t6, .while_done
    addi t4, t4, -1
    j .while_loop

.while_done:
    beqz t4, .stack_empty
    addi t1, t4, -1
    slli t1, t1, 3
    add t1, s5, t1
    ld t2, 0(t1)
    j .set_result
.stack_empty:
    li t2, -1
.set_result:
    slli t1, t0, 3
    add t1, s4, t1
    sd t2, 0(t1)                # result[i] = stack.top()
    
    slli t1, t4, 3
    add t1, s5, t1
    sd t0, 0(t1)                # push i
    addi t4, t4, 1
    addi t0, t0, -1
    j .algo_loop

.algo_done:
    li s3, 0
.print_loop:
    bge s3, s0, .print_done
    
    # logic for no trailing space: 
    # if i == 0, use "%ld", else use " %ld"
    beqz s3, .first_element
    la a0, format_with_space
    j .do_print
.first_element:
    la a0, format_no_space
.do_print:
    slli t1, s3, 3
    add t1, s4, t1
    ld a1, 0(t1)
    call printf
    addi s3, s3, 1
    j .print_loop

.print_done:
    la a0, newline_str
    call printf

    # cleanup
    mv a0, s4
    call free
    mv a0, s5
    call free
    mv a0, s2
    call free

.end:
    li a0, 0
    ld s5, 8(sp)
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    ret