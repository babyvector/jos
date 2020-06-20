// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;
	//cprintf("the error addr is:%x\n",addr);
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
		//cprintf("can't copy-on-write.\n");
	}

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
	envid_t envid = sys_getenvid();
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
		panic("sys_page_alloc");
	}
	//we can access that addr memory,but copy one ,for other 
	//env have the addr.
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
	retv = sys_page_unmap(envid, addr);
	if(retv < 0){
		panic("pgfault:page unmapping failed : %e",retv);
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
	if(retv < 0){
		panic("sys_page_map");
	}
	retv = sys_page_unmap(envid, PFTEMP);
	if(retv < 0){
		panic("pgfault: can not unmap page.");
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
	envid_t kern_envid = sys_getenvid();
	if (uvpt[pn] & PTE_SHARE) {
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
			panic("duppage:page_re-mapping failed : %e",r);
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
			panic("duppage:page re-mapping failed:%e",r);
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
	}
	//cprintf("the addr is: %x\n",addr);
	//cprintf("duppage:after second page_map.\n");
	/*
	if( (uvpt[pn] & PTE_W)||(uvpt[pn]) & PTE_COW ){
		//cprintf("!!start page map.\n");	
		cprintf("the addr is:%x\n",addr);
		r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_P|PTE_U);
		if(r<0){
			cprintf("sys_page_map failed :%d\n",r);
			panic("map env id 0 to child_envid failed.");
		
		}
		cprintf("\tafter mapping1 addr is:%x\n",addr);
		r = sys_page_map(0, addr, 0, addr,PTE_W|PTE_COW|PTE_P|PTE_U);
//		cprintf("!!end sys_page_map 0.\n");
		if(r<0){
			cprintf("sys_page_map failed :%d\n",r);
			panic("map env id 0 to 0");
		}//?we should mark PTE_COW both to two id.
		cprintf("\t after mapping2.\n");	
	}else{
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
	}
	*/
	//cprintf("out of duppage.\n");
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
	void * addr = (void*)(pn*PGSIZE);

        int r;
       	cprintf("we are copying %x.",addr);
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
                panic("sys_page_alloc: %e", r);
      	//panic("we panic here.\n");
	cprintf("af p_a.");
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
                panic("sys_page_map: %e", r);
        cprintf("af_p_m.");
	memmove(UTEMP, addr, PGSIZE);
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
}
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
		panic("sys_exofork failed.");
	} 
	if(child_envid == 0){
		thisenv = &envs[ENVX(sys_getenvid())];
//		cprintf("we are the child.\n");
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
	if(retv < 0){
		panic("sys_page_alloc failed.\n");
	}
	/*
	retv = sys_page_map(child_envid, (void*)(UXSTACKTOP - PGSIZE), sys_getenvid(),PFTEMP, PTE_U|PTE_W|PTE_P);
	if(retv < 0){
		panic("sys_page_map failed.\n");
	}
	memmove((void*)(UXSTACKTOP - PGSIZE), PFTEMP, PGSIZE);
	retv = sys_page_unmap(sys_getenvid(), PFTEMP);
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
	if(retv < 0){
		panic("sys_env_set_status failed.\n");
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
	panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
