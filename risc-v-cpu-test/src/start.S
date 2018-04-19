.section .text

.globl _start
.globl global_result
.globl end_loop


_start:
	nop
	j real_start

global_result:
	.long 0xffffffff

real_start:
	li sp, 0x800
	jal main
	sw x0, 8(x0) 

end_loop:
	j end_loop
