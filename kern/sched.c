#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

void sched_halt(void);
/*
struct Env {
	struct Trapframe env_tf;	// Saved registers
	struct Env *env_link;		// Next free Env
	envid_t env_id;			// Unique environment identifier
	envid_t env_parent_id;		// env_id of this env's parent
	enum EnvType env_type;		// Indicates special system environments
	unsigned env_status;		// Status of the environment
	uint32_t env_runs;		// Number of times environment has run

	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir
};
*/
// Choose a user environment to run and run it.
void
sched_yield(void)
{
	struct Env *idle;
	//cprintf("curenv is:%x\n", curenv);
	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment. Make sure curenv is not null before
	// dereferencing it.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.


	struct Env *e;
/*
	// cprintf("curenv: %x\n", curenv);

	int i, cur=0;

	if (curenv) cur=ENVX(curenv->env_id);

		else cur = 0;

	// cprintf("cur: %x, thiscpu: %x\n", cur, thiscpu->cpu_id);

	for (i = 0; i < NENV; ++i) {

		int j = (cur+i) % NENV;

		if (j < 2) cprintf("envs[%x].env_status: %x\n", j, envs[j].env_status);

		if (envs[j].env_status == ENV_RUNNABLE) {

			if (j == 1) 

				cprintf("\n");

			env_run(envs + j);

		}

	}

	if (curenv && curenv->env_status == ENV_RUNNING)

		env_run(curenv);

*/

	//	e = &envs[ENVX(envid)];
	//cprintf("\tget in sched_yield.\n");
	int running_env_index = -1;
	//cprintf("curenv is:%d\n", curenv);	
	if(curenv == 0){
		running_env_index = -1;
	}else{
		//cprintf("\t WE MAY CRUSH HERE.\n");
		running_env_index = ENVX(curenv->env_id);
//	cprintf("the curenv->env_id is:%x\n",curenv);
	}
	//cprintf("the real running env_id:%d\n",ENVX(curenv->env_id));
	//cprintf("The running_env_id is:%d\n",running_env_id);
	int count = 1024;
	while(count--)
	{

	

		//cprintf("%d ",running_env_id);
		running_env_index++;
		if(running_env_index == NENV){
			running_env_index = 0;
		}
	//	cprintf("%d ",running_env_index); 
		if(envs[running_env_index].env_status == ENV_RUNNABLE){
//			cprintf("\tWE ARE RUNNING ENV_ID IS:%d\n",running_env_index);
//			cprintf("\tout of sched_yield.\n");
			//env_run(&envs[0]);
//			cprintf("sched.c we are really running envid:%d\n",running_env_id);
//			cprintf("xxx.\n");
//			cprintf("read to run.\n");
//			cprintf("running_env_index is:%d\n",running_env_index);
			env_run(&envs[running_env_index]);			
			return;
		}
	}
	//if the code run here,it says that there is only one env which is
	//running but now and here we are in kern mode,so if we don't chose
	//the running env to run we will trap in sched_halt().AND WE ARE AT
	//KERNEL MODE!
	if(curenv && curenv->env_status == ENV_RUNNING){
	//	cprintf("I AM THE ONLY ONE ENV.\n");
	//	cprintf("curenv is:%x\n", curenv);
		env_run(curenv);
		
		return;
	}
	
	// sched_halt never returns
	cprintf("now in kernel mode, no work to do, so to halt.\n");
	sched_halt();

/*
idle = thiscpu->cpu_env;
   cprintf("curenv is:%x\n", idle);
    uint32_t start = (idle != NULL) ? ENVX( idle->env_id) : 0;
    uint32_t i = start;
    bool first = true;
    for (; i != start || first; i = (i+1) % NENV, first = false)
    {
        if(envs[i].env_status == ENV_RUNNABLE)
        {
            env_run(&envs[i]);
            return ;
        }
    }
 	cprintf("%x, %d %d\n", idle, idle->env_status,ENV_RUNNING);
    if (idle && idle->env_status == ENV_RUNNING)
    {
        env_run(idle);
        return ;
    }
 
	// sched_halt never returns
	sched_halt();
*/
}


// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}

