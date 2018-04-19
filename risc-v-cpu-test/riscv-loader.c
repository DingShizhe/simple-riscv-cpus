//==========================================================
// RISCV CPU binary executable file loader
//
// Main Function:
// 1. Loads binary excutable file into distributed memory
// 2. Waits RISCV CPU for finishing program execution
//
// Author:
// Yisong Chang (changyisong@ict.ac.cn)
//
// Revision History:
// 14/06/2016	v0.0.1	Add cycle counte support
//==========================================================
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <memory.h>
#include <unistd.h>  
#include <sys/mman.h>  
#include <sys/types.h>  
#include <sys/stat.h>  
#include <fcntl.h>
#include <elf.h>

#include <assert.h>
#include <sys/time.h>

#define RISCV_CPU_REG_TOTAL_SIZE		(1 << 14)
#define RISCV_CPU_REG_BASE_ADDR		0x40000000

#define RISCV_CPU_MEM_SIZE		(1 << 11)
#define RISCV_CPU_FINISH_DW_OFFSET	0x00000002	// mem[2] = 0xffffffff;
#define RISCV_CPU_RESET_REG_OFFSET	0x00002000
#define RISCV_CPU_RES_DW_OFFSET		0x000000A8

#define RISCV_CPU_CYCLES_OFFSET 0x00002004
#define RISCV_CPU_INST_OFFSET 0x00002008
#define RISCV_CPU_BR_OFFSET 0x0000200C
#define RISCV_CPU_LW_OFFSET 0x00002010
#define RISCV_CPU_SW_OFFSET 0x00002014
#define RISCV_CPU_ISBR_OFFSET 0x00002018
#define RISCV_CPU_JUMP_OFFSET 0x0000201C
#define RISCV_CPU_RESERVED_OFFSET 0x00002020

void *map_base;
volatile uint32_t *map_base_word;
int	fd;

#define riscv_addr(p) (map_base + (uintptr_t)(p))

void loader(char *file) {
	FILE *fp = fopen(file, "rb");
	assert(fp);
	Elf32_Ehdr *elf;
	Elf32_Phdr *ph = NULL;
	int i;
	uint8_t buf[4096];

	// the program header should be located within the first
	// 4096 byte of the ELF file
	fread(buf, 4096, 1, fp);
	elf = (void *)buf;

	// TODO: fix the magic number with the correct one
	const uint32_t elf_magic = 0x464c457f;
	uint32_t *p_magic = (void *)buf;
	// check the magic number
	assert(*p_magic == elf_magic);

	// our RISCV CPU can only reset with PC = 0
	assert(elf->e_entry == 0);

	for(i = 0, ph = (void *)buf + elf->e_phoff; i < elf->e_phnum; i ++) {
		// scan the program header table, load each segment into memory
		if(ph[i].p_type == PT_LOAD) {
			uint32_t addr = ph[i].p_vaddr;

			if(addr >= RISCV_CPU_REG_TOTAL_SIZE) {
				// Ignore segments with address out of ideal memory
				// All segments we need to load can fit in the ideal memory
				continue;
			}

			// TODO: read the content of the segment from the ELF file
			// to the memory region [VirtAddr, VirtAddr + FileSiz)
			// Use file operations
			// Use `riscv_addr(addr)` to refer to address in mips CPU
            fseek(fp, ph[i].p_offset, SEEK_SET);
			fread(riscv_addr(addr), ph[i].p_filesz, 1, fp);
			memset(riscv_addr(addr)+ph[i].p_filesz, 0, ph[i].p_memsz-ph[i].p_filesz);
			// TODO: zero the memory region
			// [VirtAddr + FileSiz, VirtAddr + MemSiz)

		}
	}

	fclose(fp);
}

void init_map() {
	fd = open("/dev/mem", O_RDWR|O_SYNC);  
	if (fd == -1)  {  
		perror("init_map open failed:");
		exit(1);
	} 

	//physical mapping to virtual memory 
	map_base = mmap(NULL, RISCV_CPU_REG_TOTAL_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, RISCV_CPU_REG_BASE_ADDR);
	
	if (map_base == NULL) {
		perror("init_map mmap failed:");
		close(fd);
		exit(1);
	}  

	map_base_word = (uint32_t *)map_base;
}

void resetn(int val) {
	*(map_base_word + (RISCV_CPU_RESET_REG_OFFSET >> 2)) = val;
}

int wait_for_finish() {
	int ret;
	while((ret = *(map_base_word + RISCV_CPU_FINISH_DW_OFFSET)) == 0xFFFFFFFF);
	return ret;
}

void memdump() {
	int i;

	printf("Memory dump:\n");
	for(i = 0; i < RISCV_CPU_MEM_SIZE / sizeof(int); i++) {
		if(i % 4 == 0) {
			printf("0x%04x:", i << 2);
		}

		printf(" 0x%08x", map_base_word[i]);
		
		if(i % 4 == 3) {
			printf("\n");
		}
	}

	printf("\n");
}

void finish_map() {
	munmap(map_base, RISCV_CPU_REG_TOTAL_SIZE);
	close(fd);
}

int main(int argc, char *argv[]) {  
	/* mapping the RISCV distributed memory into the address space of this program */
	init_map();

	/* reset MISP CPU */
	resetn(0);

	/* load RISCV binary executable file to distributed memory */
	loader(argv[1]);

	// memdump();

	/* finish reset RISCV CPU */
	resetn(1);

	/* wait for RISCV CPU finish  */
	printf("Running %s...", argv[1]);
	fflush(stdout);

	int ret = wait_for_finish();
	printf("\t\t%s\n", (ret == 0 ? "pass" : "fail!"));

	printf( "\tcycles: %d\n", *(map_base_word + (RISCV_CPU_CYCLES_OFFSET >> 2)) );
	printf( "\tinstructions: %d\n", *(map_base_word + (RISCV_CPU_INST_OFFSET >> 2)) );
	printf( "\tCPI: %f\n", (float)*(map_base_word + (RISCV_CPU_CYCLES_OFFSET >> 2)) / (float)*(map_base_word + (RISCV_CPU_INST_OFFSET >> 2)) );
	printf( "\tlw inst: %d\n", *(map_base_word + (RISCV_CPU_LW_OFFSET >> 2)) );
	printf( "\tsw inst: %d\n", *(map_base_word + (RISCV_CPU_SW_OFFSET >> 2)) );
	printf( "\tbranch number: %d\n", *(map_base_word + (RISCV_CPU_BR_OFFSET >> 2)) );
	printf( "\tTaken: %d\n", *(map_base_word + (RISCV_CPU_ISBR_OFFSET >> 2)) );
	printf( "\tnot Taken: %d\n\n", *(map_base_word + (RISCV_CPU_JUMP_OFFSET >> 2)) );
	// printf( "\tcycles: %d\n", *(map_base_word + (RISCV_CPU_RESERVED_OFFSET >> 2)) );

	/* reset MISP CPU */
	resetn(0);

	/* dump all distributed memory */
	//memdump();

	finish_map();

	return 0; 
} 
