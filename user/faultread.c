// buggy program - faults with a read from location zero

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	cprintf("\t we are at faultread umain now.\n");
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
}

