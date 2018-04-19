#ifndef __TRAP_H__
#define __TRAP_H__

#ifndef __ASSEMBLER__

extern int global_result;
extern int end_loop;

#define HIT_GOOD_TRAP \
	global_result = 0; \
	asm volatile("ret")

#define HIT_BAD_TRAP \
	global_result = 1; \
	asm volatile("j end_loop")

#define nemu_assert(cond) \
	do { \
		if( !(cond) ) { \
			HIT_BAD_TRAP; \
		} \
	} while(0)

#endif

#endif
