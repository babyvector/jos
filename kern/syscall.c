/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.


	struct Env *e;
	//envid2env(sys_getenvid(), &e, 1);
	user_mem_assert(curenv, s, len, PTE_U);

	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;

	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	//cprintf("xdest\n");
	cprintf("going to destroy user program.\n");
	env_destroy(e);
	cprintf("after destroy.\n");
	//if("xdest."){;}
	//cprintf("xdest.\n");
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env * newenv_store;
	if(curenv->env_id == 0)
		return 0;
	int r_env_alloc = env_alloc(&newenv_store,curenv->env_id);
	
	if(r_env_alloc<0)
		return r_env_alloc;
	
	newenv_store->env_status = ENV_NOT_RUNNABLE;
	memmove(&newenv_store->env_tf,&curenv->env_tf,sizeof(curenv->env_tf));
	newenv_store->env_tf.tf_regs.reg_eax =0;
	return newenv_store->env_id;
	//panic("sys_exofork not implemented");
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	//cprintf("r_value is:%d\n", r_value);
	if(r_value)
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
	newenv_store->env_status = status;

	return 0;
	// LAB 4: Your code here.
	//panic("sys_env_set_status not implemented");
}

// Set envid's trap frame to 'tf'.
// tf is modified to make sure that user environments always run at code
// protection level 3 (CPL 3), interrupts enabled, and IOPL of 0.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
	if (ret) return ret;
//	cprintf("\t\t OVER ENVID2ENV in set_trapframe.\n");
	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
	e->env_tf = *tf;
	e->env_tf.tf_eflags |= FL_IF;
	e->env_tf.tf_cs = GD_UT | 3;
	return 0;
	panic("sys_env_set_trapframe not implemented");
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	//panic("\t we panic at sys_env_set_pgfault_upcall.\n");
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value){
		return r_value;
	}
	newenv_store->env_pgfault_upcall = func;	
	//cprintf("\tnewenv_store->env_pgfault_upcall is:%d\n",newenv_store->env_pgfault_upcall);
	return 0;
	//panic("sys_env_set_pgfault_upcall not implemented");
	
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
//	cprintf("the kernel env index is:%d\n",ENVX(curenv->env_id));
	//cprintf("get in sys_page_alloc.\n");
	struct Env *newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	//cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
		return -E_INVAL;
	
	/*//this is old version, can not extension! 2020.5.5
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
		return -E_INVAL;
	*/
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
	
	struct PageInfo*pp;
	pp = page_alloc(0);
	//cprintf("after page_alloc.\n");
	if(!pp)
		return -E_NO_MEM;

	int ret = page_insert(newenv_store->env_pgdir,pp,va,perm);	
	/*
	if((uint32_t)va == 0xa00000){
		pte_t * ret_pte = pgdir_walk(newenv_store->env_pgdir,va,0);
		cprintf("\n\n\t\tafter page_alloc,ret_pte & PTE_W:%d\n",(uint32_t)ret_pte&PTE_W);
		cprintf("\n\n\t\tthe perm sendin is perm&PTE_W:%d\n",perm&PTE_W);
	}
	*/	
	//cprintf("after page_insert.\n");	
	if(!ret)
		return ret;
	return 0;
	//panic("sys_page_alloc not implemented");
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
/*
if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
    if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
    if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0) return -E_INVAL;
    struct Env *src_e, *dst_e;
    if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
    pte_t *src_ptab;    
    struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_ptab);
    if ((*src_ptab & PTE_W) == 0 && (perm & PTE_W) == 1) return -E_INVAL;
    if (page_insert(dst_e->env_pgdir, pp, dstva, perm) < 0) return -E_NO_MEM;
cprintf("syscall:after page_map\n");

	return 0;
*/
/*//old version 2020.5.5 self version
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
		return -E_BAD_ENV;
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
		return -E_INVAL;

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
		return -E_INVAL;

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
	if(!pp)
		return -E_INVAL;
//	panic("sys_page_map run here.\n");
	if( (perm&PTE_U) && (perm&PTE_P) == 0) {
		return -E_INVAL;
	}
	if(!( perm&PTE_W || perm&PTE_AVAIL )){
		return -E_INVAL;
	}
//	panic("sys_page_map run here.\n");
	if(perm&PTE_W && !((*pte_store)&PTE_W))
		return -E_INVAL;

//	cprintf("error before page_insert newenv_store_dst: %x,dstva:%x .\n",newenv_store_dst,dstva);
	int ret = 0;
	ret = (page_insert(newenv_store_dst->env_pgdir,pp,dstva,perm));
//	cprintf("after page_insert.\n");

	if(ret < 0)
		return -E_NO_MEM;
	else{
		//cprintf("page_map:finish page_map.\n");
		return 0;	
	}	

	// LAB 4: Your code here.
	//panic("sys_page_map not implemented");
*/
//copy from internet. clann24
struct Env *se, *de;
	int ret = envid2env(srcenvid, &se, 1);
	if (ret) return ret;	//bad_env
	ret = envid2env(dstenvid, &de, 1);
	if (ret) return ret;	//bad_env
	// cprintf("src env: %x, dst env: %x, src va: %x, dst va: %x\n", 
		// se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
	if (!pg) return -E_INVAL;

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;

	//	-E_NO_MEM if there's no memory to allocate any necessary page tables.

	ret = page_insert(de->env_pgdir, pg, dstva, perm);
// cprintf("map done %x\n", ret);
	return ret;
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value == -E_BAD_ENV)
		return -E_BAD_ENV;
	
	if(va>=(void*)UTOP)
		return -E_INVAL;

	if(((unsigned int)va<<20))
		return -E_INVAL;

	page_remove(newenv_store->env_pgdir,va);
	
	return 0;
	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");
}
/*
// Values of env_status in struct Env
enum {
        ENV_FREE = 0,
        ENV_DYING,
        ENV_RUNNABLE,
        ENV_RUNNING,
        ENV_NOT_RUNNABLE
};

// Special environment types
enum EnvType {
        ENV_TYPE_USER = 0,
};

struct Env {
        struct Trapframe env_tf;        // Saved registers
        struct Env *env_link;           // Next free Env
        envid_t env_id;                 // Unique environment identifier
        envid_t env_parent_id;          // env_id of this env's parent
        enum EnvType env_type;          // Indicates special system environments
        unsigned env_status;            // Status of the environment
        uint32_t env_runs;              // Number of times environment has run
        int env_cpunum;                 // The CPU that the env is running on

        // Address space
        pde_t *env_pgdir;               // Kernel virtual address of page dir

        // Exception handling
        void *env_pgfault_upcall;       // Page fault upcall entry point

        // Lab 4 IPC
        bool env_ipc_recving;           // Env is blocked receiving
        void *env_ipc_dstva;            // VA at which to map received page
        uint32_t env_ipc_value;         // Data value sent to us
        envid_t env_ipc_from;           // envid of the sender
        int env_ipc_perm;               // Perm of page mapping received
};



*/
// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
//struct PageInfo *
//page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)

static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
/*// old version 2020.5.5
	// LAB 4: Your code here.
	cprintf("-E_BAD_ENV IS:%d\n", -E_BAD_ENV);
	//cprintf("-E_IPC_NOT_RECV IS:%d\n", -E_IPC_NOT_RECV);

	if(envs[ ENVX(envid) ].env_status == ENV_FREE){
		return -E_BAD_ENV;//-3
	}	
	if(! envs[ ENVX(envid) ].env_ipc_recving){
		return -E_IPC_NOT_RECV;//-7
	}	
	if( srcva < (void*)UTOP ){
		if((uint32_t)srcva%(uint32_t)PGSIZE != 0){
			return -E_INVAL-1;//E_INVAL -3
		}
		if( !(perm&PTE_P && perm&PTE_U)  ){
			return -E_INVAL-2;
		}
		if( ( perm & ~(PTE_P|PTE_U|PTE_AVAIL|PTE_W) ) != 0 ){
		//we can't set other bits.
			return -E_INVAL-3;
		}
	}

	envid_t caller_envid = sys_getenvid();
	cprintf("-E_INVAL IS :%d\n", -E_INVAL);		
	if( srcva < (void*)UTOP ){
		struct PageInfo * ret_p = page_lookup( envs[ ENVX(caller_envid) ].env_pgdir, srcva, 0);	
		if( ret_p == NULL ){
			return -E_INVAL-5;
		}	
	}
	if( srcva < (void*)UTOP ){
		if( (uint32_t)perm & (uint32_t)PTE_W ){
			pte_t * ret_pte = pgdir_walk(envs[ ENVX(caller_envid) ].env_pgdir, srcva, 0);
			if( ( (uint32_t)*ret_pte & (uint32_t)PTE_W) == 0){
				return -E_INVAL-6;
			}
		}
	}
	//cprintf("\t\t\twe send here.\n");
	//ready to ipc
	envs[ ENVX(envid) ].env_ipc_recving = 0;
	envs[ ENVX(envid) ].env_ipc_from = sys_getenvid();
	if( srcva < (void*)UTOP ){
		int ret = 0;
		ret = sys_page_alloc(envid, srcva, perm);
		cprintf("BEFORE ret is %d\n", ret);
		if ((perm & PTE_W) && !(*pte & PTE_W)){
		cprintf("perm failed.\n");
		
		 return -E_INVAL;
		}
		if (srcva != ROUNDDOWN(srcva, PGSIZE)){
		cprintf("srcva is not rounddown.\n");
		 return -E_INVAL;
		}
		if(ret<0){
			return ret;
		}
		ret = sys_page_map(sys_getenvid(), srcva, envid, envs[ ENVX(envid) ].env_ipc_dstva, perm);
		cprintf("BEFORE ret is %d\n", ret);
		if(ret<0){
			return ret;
		}
		envs[ ENVX(envid) ].env_ipc_perm = perm;
		envs[ ENVX(envid) ].env_ipc_value = value;
		
	}else{
		envs[ ENVX(envid) ].env_ipc_perm = 0;
		envs[ ENVX(envid) ].env_ipc_value = value;
		
	}	
	return 0;
*/
struct Env *e;
	int ret = envid2env(envid, &e, 0);
	if (ret) return ret;//bad env
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
	if (srcva < (void*)UTOP) {
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) return -E_INVAL;
		if ((*pte & perm & 7) != (perm & 7)) return -E_INVAL;
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
		if (e->env_ipc_dstva < (void*)UTOP) {
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
			if (ret) return ret;
			e->env_ipc_perm = perm;
		}
	}
	e->env_ipc_recving = 0;
	e->env_ipc_from = curenv->env_id;
	e->env_ipc_value = value; 
	e->env_status = ENV_RUNNABLE;
	e->env_tf.tf_regs.reg_eax = 0;
	return 0;
	panic("sys_ipc_try_send not implemented");
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
/*//old version:2020.5.5
	envs[ ENVX(sys_getenvid())  ].env_ipc_recving = true;
	if((uint32_t)dstva < (uint32_t)UTOP){
		if( (uint32_t)dstva%(uint32_t)PGSIZE != 0  ){
			return -E_INVAL;
		}
		envid_t recv_envid = sys_getenvid();
		envs[ ENVX( recv_envid )  ].env_ipc_dstva = dstva;
	}
*/

/*
	//new version:2020.5.5
	cprintf("in sys_ipc_recv\n");
	if(dstva < (void*)UTOP)
		if(dstva != ROUNDDOWN(dstva, PGSIZE))
			return -E_INVAL;
	curenv->env_ipc_recving = -1;
	//curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_ipc_dstva = dstva;
//	sys_yield();
	cprintf("in sys_ipc_recv. after sys_yield().\n");
	//panic("sys_ipc_recv not implemented");

*/
	if (dstva < (void*)UTOP) 
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
			return -E_INVAL;
	curenv->env_ipc_recving = 1;
	curenv->env_status = ENV_NOT_RUNNABLE;
	curenv->env_ipc_dstva = dstva;
	sys_yield();
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
       	       case SYS_cputs:
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
       	       case SYS_getenvid:
           		 assert(curenv);
            		return sys_getenvid();
      	       case SYS_env_destroy:
          		  assert(curenv);
            		return sys_env_destroy(sys_getenvid());
	       case SYS_yield:
			assert(curenv);
			sys_yield();
			return 1;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send( (envid_t)a1, (uint32_t)a2, (void*)a3, (unsigned)a4 );
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (void*)a2);
	//syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
		default:
			return -E_INVAL;
	}
}
