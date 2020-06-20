
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 b0 00 00 00       	call   f01000ee <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
//<<<<<<< HEAD
//=======
// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx

	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 60 63 10 f0       	push   $0xf0106360
f0100050:	e8 1a 38 00 00       	call   f010386f <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 d2 08 00 00       	call   f010094d <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 7c 63 10 f0       	push   $0xf010637c
f0100087:	e8 e3 37 00 00       	call   f010386f <cprintf>


}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009c:	83 3d 80 2e 21 f0 00 	cmpl   $0x0,0xf0212e80
f01000a3:	75 3a                	jne    f01000df <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f01000a5:	89 35 80 2e 21 f0    	mov    %esi,0xf0212e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000ab:	fa                   	cli    
f01000ac:	fc                   	cld    

	va_start(ap, fmt);
f01000ad:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000b0:	e8 11 5c 00 00       	call   f0105cc6 <cpunum>
f01000b5:	ff 75 0c             	pushl  0xc(%ebp)
f01000b8:	ff 75 08             	pushl  0x8(%ebp)
f01000bb:	50                   	push   %eax
f01000bc:	68 24 64 10 f0       	push   $0xf0106424
f01000c1:	e8 a9 37 00 00       	call   f010386f <cprintf>
	vcprintf(fmt, ap);
f01000c6:	83 c4 08             	add    $0x8,%esp
f01000c9:	53                   	push   %ebx
f01000ca:	56                   	push   %esi
f01000cb:	e8 79 37 00 00       	call   f0103849 <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 84 67 10 f0 	movl   $0xf0106784,(%esp)
f01000d7:	e8 93 37 00 00       	call   f010386f <cprintf>
	va_end(ap);
f01000dc:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	83 ec 0c             	sub    $0xc,%esp
f01000e2:	6a 00                	push   $0x0
f01000e4:	e8 db 08 00 00       	call   f01009c4 <monitor>
f01000e9:	83 c4 10             	add    $0x10,%esp
f01000ec:	eb f1                	jmp    f01000df <_panic+0x4b>

f01000ee <i386_init>:
}
//>>>>>>> lab1

void
i386_init(void)
{
f01000ee:	55                   	push   %ebp
f01000ef:	89 e5                	mov    %esp,%ebp
f01000f1:	53                   	push   %ebx
f01000f2:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000f5:	b8 08 40 25 f0       	mov    $0xf0254008,%eax
f01000fa:	2d e0 1a 21 f0       	sub    $0xf0211ae0,%eax
f01000ff:	50                   	push   %eax
f0100100:	6a 00                	push   $0x0
f0100102:	68 e0 1a 21 f0       	push   $0xf0211ae0
f0100107:	e8 98 55 00 00       	call   f01056a4 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 da 05 00 00       	call   f01006eb <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	68 ac 1a 00 00       	push   $0x1aac
f0100119:	68 97 63 10 f0       	push   $0xf0106397
f010011e:	e8 4c 37 00 00       	call   f010386f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100123:	e8 38 13 00 00       	call   f0101460 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100128:	e8 49 2f 00 00       	call   f0103076 <env_init>

	trap_init();
f010012d:	e8 3e 38 00 00       	call   f0103970 <trap_init>
	cprintf("trap_init\n");
f0100132:	c7 04 24 b2 63 10 f0 	movl   $0xf01063b2,(%esp)
f0100139:	e8 31 37 00 00       	call   f010386f <cprintf>
	// Lab 4 multiprocessor initialization functions
	mp_init();
f010013e:	e8 79 58 00 00       	call   f01059bc <mp_init>
	cprintf("mp_init\n");
f0100143:	c7 04 24 bd 63 10 f0 	movl   $0xf01063bd,(%esp)
f010014a:	e8 20 37 00 00       	call   f010386f <cprintf>
	lapic_init();
f010014f:	e8 8d 5b 00 00       	call   f0105ce1 <lapic_init>
	cprintf("lapic_init.\n");
f0100154:	c7 04 24 c6 63 10 f0 	movl   $0xf01063c6,(%esp)
f010015b:	e8 0f 37 00 00       	call   f010386f <cprintf>
	// Lab 4 multitasking initialization functions
	pic_init();
f0100160:	e8 31 36 00 00       	call   f0103796 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100165:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010016c:	e8 c3 5d 00 00       	call   f0105f34 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100171:	83 c4 10             	add    $0x10,%esp
f0100174:	83 3d 88 2e 21 f0 07 	cmpl   $0x7,0xf0212e88
f010017b:	77 16                	ja     f0100193 <i386_init+0xa5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010017d:	68 00 70 00 00       	push   $0x7000
f0100182:	68 48 64 10 f0       	push   $0xf0106448
f0100187:	6a 7f                	push   $0x7f
f0100189:	68 d3 63 10 f0       	push   $0xf01063d3
f010018e:	e8 01 ff ff ff       	call   f0100094 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100193:	83 ec 04             	sub    $0x4,%esp
f0100196:	b8 22 59 10 f0       	mov    $0xf0105922,%eax
f010019b:	2d a8 58 10 f0       	sub    $0xf01058a8,%eax
f01001a0:	50                   	push   %eax
f01001a1:	68 a8 58 10 f0       	push   $0xf01058a8
f01001a6:	68 00 70 00 f0       	push   $0xf0007000
f01001ab:	e8 41 55 00 00       	call   f01056f1 <memmove>
f01001b0:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001b3:	bb 20 30 21 f0       	mov    $0xf0213020,%ebx
f01001b8:	eb 4d                	jmp    f0100207 <i386_init+0x119>
		if (c == cpus + cpunum())  // We've started already.
f01001ba:	e8 07 5b 00 00       	call   f0105cc6 <cpunum>
f01001bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01001c2:	05 20 30 21 f0       	add    $0xf0213020,%eax
f01001c7:	39 c3                	cmp    %eax,%ebx
f01001c9:	74 39                	je     f0100204 <i386_init+0x116>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001cb:	89 d8                	mov    %ebx,%eax
f01001cd:	2d 20 30 21 f0       	sub    $0xf0213020,%eax
f01001d2:	c1 f8 02             	sar    $0x2,%eax
f01001d5:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001db:	c1 e0 0f             	shl    $0xf,%eax
f01001de:	05 00 c0 21 f0       	add    $0xf021c000,%eax
f01001e3:	a3 84 2e 21 f0       	mov    %eax,0xf0212e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001e8:	83 ec 08             	sub    $0x8,%esp
f01001eb:	68 00 70 00 00       	push   $0x7000
f01001f0:	0f b6 03             	movzbl (%ebx),%eax
f01001f3:	50                   	push   %eax
f01001f4:	e8 36 5c 00 00       	call   f0105e2f <lapic_startap>
f01001f9:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001fc:	8b 43 04             	mov    0x4(%ebx),%eax
f01001ff:	83 f8 01             	cmp    $0x1,%eax
f0100202:	75 f8                	jne    f01001fc <i386_init+0x10e>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100204:	83 c3 74             	add    $0x74,%ebx
f0100207:	6b 05 c4 33 21 f0 74 	imul   $0x74,0xf02133c4,%eax
f010020e:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0100213:	39 c3                	cmp    %eax,%ebx
f0100215:	72 a3                	jb     f01001ba <i386_init+0xcc>
	// Starting non-boot CPUs
	boot_aps();


	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f0100217:	83 ec 08             	sub    $0x8,%esp
f010021a:	6a 01                	push   $0x1
f010021c:	68 b4 0c 1d f0       	push   $0xf01d0cb4
f0100221:	e8 5c 30 00 00       	call   f0103282 <env_create>
#if defined(TEST)
	// Don't touch -- used by grading script!
//	cprintf("in the if TEST.\n");
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	cprintf("in the else TEST.\n");
f0100226:	c7 04 24 df 63 10 f0 	movl   $0xf01063df,(%esp)
f010022d:	e8 3d 36 00 00       	call   f010386f <cprintf>
	// Touch all you want.

	ENV_CREATE(user_icode, ENV_TYPE_USER);
f0100232:	83 c4 08             	add    $0x8,%esp
f0100235:	6a 00                	push   $0x0
f0100237:	68 48 be 1c f0       	push   $0xf01cbe48
f010023c:	e8 41 30 00 00       	call   f0103282 <env_create>
	//ENV_CREATE(user_spawnhello, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100241:	e8 49 04 00 00       	call   f010068f <kbd_intr>
//	ENV_CREATE(user_yield,ENV_TYPE_USER);

	//we use the next  line to test Excerse 7
//	ENV_CREATE(user_forktree,ENV_TYPE_USER);
//	ENV_CREATE(user_forktree,ENV_TYPE_USER); 
	cprintf("in 386_init() we are going to run sched_yield.\n");
f0100246:	c7 04 24 6c 64 10 f0 	movl   $0xf010646c,(%esp)
f010024d:	e8 1d 36 00 00       	call   f010386f <cprintf>

	// Schedule and run the first user environment!
	sched_yield();
f0100252:	e8 8a 42 00 00       	call   f01044e1 <sched_yield>

f0100257 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f0100257:	55                   	push   %ebp
f0100258:	89 e5                	mov    %esp,%ebp
f010025a:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f010025d:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100262:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100267:	77 15                	ja     f010027e <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100269:	50                   	push   %eax
f010026a:	68 9c 64 10 f0       	push   $0xf010649c
f010026f:	68 97 00 00 00       	push   $0x97
f0100274:	68 d3 63 10 f0       	push   $0xf01063d3
f0100279:	e8 16 fe ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010027e:	05 00 00 00 10       	add    $0x10000000,%eax
f0100283:	0f 22 d8             	mov    %eax,%cr3

	cprintf("SMP: CPU %d starting\n", cpunum());
f0100286:	e8 3b 5a 00 00       	call   f0105cc6 <cpunum>
f010028b:	83 ec 08             	sub    $0x8,%esp
f010028e:	50                   	push   %eax
f010028f:	68 f2 63 10 f0       	push   $0xf01063f2
f0100294:	e8 d6 35 00 00       	call   f010386f <cprintf>
	lapic_init();
f0100299:	e8 43 5a 00 00       	call   f0105ce1 <lapic_init>
	env_init_percpu();
f010029e:	e8 a3 2d 00 00       	call   f0103046 <env_init_percpu>
	trap_init_percpu();
f01002a3:	e8 db 35 00 00       	call   f0103883 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002a8:	e8 19 5a 00 00       	call   f0105cc6 <cpunum>
f01002ad:	6b d0 74             	imul   $0x74,%eax,%edx
f01002b0:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01002b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01002bb:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01002bf:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01002c6:	e8 69 5c 00 00       	call   f0105f34 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f01002cb:	e8 11 42 00 00       	call   f01044e1 <sched_yield>

f01002d0 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp
f01002d3:	53                   	push   %ebx
f01002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002d7:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002da:	ff 75 0c             	pushl  0xc(%ebp)
f01002dd:	ff 75 08             	pushl  0x8(%ebp)
f01002e0:	68 08 64 10 f0       	push   $0xf0106408
f01002e5:	e8 85 35 00 00       	call   f010386f <cprintf>
	vcprintf(fmt, ap);
f01002ea:	83 c4 08             	add    $0x8,%esp
f01002ed:	53                   	push   %ebx
f01002ee:	ff 75 10             	pushl  0x10(%ebp)
f01002f1:	e8 53 35 00 00       	call   f0103849 <vcprintf>
	cprintf("\n");
f01002f6:	c7 04 24 84 67 10 f0 	movl   $0xf0106784,(%esp)
f01002fd:	e8 6d 35 00 00       	call   f010386f <cprintf>
	va_end(ap);
}
f0100302:	83 c4 10             	add    $0x10,%esp
f0100305:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100308:	c9                   	leave  
f0100309:	c3                   	ret    

f010030a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010030a:	55                   	push   %ebp
f010030b:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100312:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100313:	a8 01                	test   $0x1,%al
f0100315:	74 0b                	je     f0100322 <serial_proc_data+0x18>
f0100317:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010031c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010031d:	0f b6 c0             	movzbl %al,%eax
f0100320:	eb 05                	jmp    f0100327 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100322:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100327:	5d                   	pop    %ebp
f0100328:	c3                   	ret    

f0100329 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100329:	55                   	push   %ebp
f010032a:	89 e5                	mov    %esp,%ebp
f010032c:	53                   	push   %ebx
f010032d:	83 ec 04             	sub    $0x4,%esp
f0100330:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100332:	eb 2b                	jmp    f010035f <cons_intr+0x36>
		if (c == 0)
f0100334:	85 c0                	test   %eax,%eax
f0100336:	74 27                	je     f010035f <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100338:	8b 0d 24 22 21 f0    	mov    0xf0212224,%ecx
f010033e:	8d 51 01             	lea    0x1(%ecx),%edx
f0100341:	89 15 24 22 21 f0    	mov    %edx,0xf0212224
f0100347:	88 81 20 20 21 f0    	mov    %al,-0xfdedfe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010034d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100353:	75 0a                	jne    f010035f <cons_intr+0x36>
			cons.wpos = 0;
f0100355:	c7 05 24 22 21 f0 00 	movl   $0x0,0xf0212224
f010035c:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010035f:	ff d3                	call   *%ebx
f0100361:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100364:	75 ce                	jne    f0100334 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100366:	83 c4 04             	add    $0x4,%esp
f0100369:	5b                   	pop    %ebx
f010036a:	5d                   	pop    %ebp
f010036b:	c3                   	ret    

f010036c <kbd_proc_data>:
f010036c:	ba 64 00 00 00       	mov    $0x64,%edx
f0100371:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100372:	a8 01                	test   $0x1,%al
f0100374:	0f 84 f8 00 00 00    	je     f0100472 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010037a:	a8 20                	test   $0x20,%al
f010037c:	0f 85 f6 00 00 00    	jne    f0100478 <kbd_proc_data+0x10c>
f0100382:	ba 60 00 00 00       	mov    $0x60,%edx
f0100387:	ec                   	in     (%dx),%al
f0100388:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010038a:	3c e0                	cmp    $0xe0,%al
f010038c:	75 0d                	jne    f010039b <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010038e:	83 0d 00 20 21 f0 40 	orl    $0x40,0xf0212000
		return 0;
f0100395:	b8 00 00 00 00       	mov    $0x0,%eax
f010039a:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010039b:	55                   	push   %ebp
f010039c:	89 e5                	mov    %esp,%ebp
f010039e:	53                   	push   %ebx
f010039f:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01003a2:	84 c0                	test   %al,%al
f01003a4:	79 36                	jns    f01003dc <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003a6:	8b 0d 00 20 21 f0    	mov    0xf0212000,%ecx
f01003ac:	89 cb                	mov    %ecx,%ebx
f01003ae:	83 e3 40             	and    $0x40,%ebx
f01003b1:	83 e0 7f             	and    $0x7f,%eax
f01003b4:	85 db                	test   %ebx,%ebx
f01003b6:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003b9:	0f b6 d2             	movzbl %dl,%edx
f01003bc:	0f b6 82 20 66 10 f0 	movzbl -0xfef99e0(%edx),%eax
f01003c3:	83 c8 40             	or     $0x40,%eax
f01003c6:	0f b6 c0             	movzbl %al,%eax
f01003c9:	f7 d0                	not    %eax
f01003cb:	21 c8                	and    %ecx,%eax
f01003cd:	a3 00 20 21 f0       	mov    %eax,0xf0212000
		return 0;
f01003d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01003d7:	e9 a4 00 00 00       	jmp    f0100480 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01003dc:	8b 0d 00 20 21 f0    	mov    0xf0212000,%ecx
f01003e2:	f6 c1 40             	test   $0x40,%cl
f01003e5:	74 0e                	je     f01003f5 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003e7:	83 c8 80             	or     $0xffffff80,%eax
f01003ea:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003ec:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003ef:	89 0d 00 20 21 f0    	mov    %ecx,0xf0212000
	}

	shift |= shiftcode[data];
f01003f5:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01003f8:	0f b6 82 20 66 10 f0 	movzbl -0xfef99e0(%edx),%eax
f01003ff:	0b 05 00 20 21 f0    	or     0xf0212000,%eax
f0100405:	0f b6 8a 20 65 10 f0 	movzbl -0xfef9ae0(%edx),%ecx
f010040c:	31 c8                	xor    %ecx,%eax
f010040e:	a3 00 20 21 f0       	mov    %eax,0xf0212000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100413:	89 c1                	mov    %eax,%ecx
f0100415:	83 e1 03             	and    $0x3,%ecx
f0100418:	8b 0c 8d 00 65 10 f0 	mov    -0xfef9b00(,%ecx,4),%ecx
f010041f:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100423:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100426:	a8 08                	test   $0x8,%al
f0100428:	74 1b                	je     f0100445 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010042a:	89 da                	mov    %ebx,%edx
f010042c:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010042f:	83 f9 19             	cmp    $0x19,%ecx
f0100432:	77 05                	ja     f0100439 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100434:	83 eb 20             	sub    $0x20,%ebx
f0100437:	eb 0c                	jmp    f0100445 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100439:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010043c:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010043f:	83 fa 19             	cmp    $0x19,%edx
f0100442:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100445:	f7 d0                	not    %eax
f0100447:	a8 06                	test   $0x6,%al
f0100449:	75 33                	jne    f010047e <kbd_proc_data+0x112>
f010044b:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100451:	75 2b                	jne    f010047e <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100453:	83 ec 0c             	sub    $0xc,%esp
f0100456:	68 c0 64 10 f0       	push   $0xf01064c0
f010045b:	e8 0f 34 00 00       	call   f010386f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100460:	ba 92 00 00 00       	mov    $0x92,%edx
f0100465:	b8 03 00 00 00       	mov    $0x3,%eax
f010046a:	ee                   	out    %al,(%dx)
f010046b:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010046e:	89 d8                	mov    %ebx,%eax
f0100470:	eb 0e                	jmp    f0100480 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100477:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100478:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010047d:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010047e:	89 d8                	mov    %ebx,%eax
}
f0100480:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100483:	c9                   	leave  
f0100484:	c3                   	ret    

f0100485 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100485:	55                   	push   %ebp
f0100486:	89 e5                	mov    %esp,%ebp
f0100488:	57                   	push   %edi
f0100489:	56                   	push   %esi
f010048a:	53                   	push   %ebx
f010048b:	83 ec 1c             	sub    $0x1c,%esp
f010048e:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100490:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100495:	be fd 03 00 00       	mov    $0x3fd,%esi
f010049a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010049f:	eb 09                	jmp    f01004aa <cons_putc+0x25>
f01004a1:	89 ca                	mov    %ecx,%edx
f01004a3:	ec                   	in     (%dx),%al
f01004a4:	ec                   	in     (%dx),%al
f01004a5:	ec                   	in     (%dx),%al
f01004a6:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01004a7:	83 c3 01             	add    $0x1,%ebx
f01004aa:	89 f2                	mov    %esi,%edx
f01004ac:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004ad:	a8 20                	test   $0x20,%al
f01004af:	75 08                	jne    f01004b9 <cons_putc+0x34>
f01004b1:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01004b7:	7e e8                	jle    f01004a1 <cons_putc+0x1c>
f01004b9:	89 f8                	mov    %edi,%eax
f01004bb:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004be:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004c3:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004c4:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004c9:	be 79 03 00 00       	mov    $0x379,%esi
f01004ce:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004d3:	eb 09                	jmp    f01004de <cons_putc+0x59>
f01004d5:	89 ca                	mov    %ecx,%edx
f01004d7:	ec                   	in     (%dx),%al
f01004d8:	ec                   	in     (%dx),%al
f01004d9:	ec                   	in     (%dx),%al
f01004da:	ec                   	in     (%dx),%al
f01004db:	83 c3 01             	add    $0x1,%ebx
f01004de:	89 f2                	mov    %esi,%edx
f01004e0:	ec                   	in     (%dx),%al
f01004e1:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01004e7:	7f 04                	jg     f01004ed <cons_putc+0x68>
f01004e9:	84 c0                	test   %al,%al
f01004eb:	79 e8                	jns    f01004d5 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004ed:	ba 78 03 00 00       	mov    $0x378,%edx
f01004f2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01004f6:	ee                   	out    %al,(%dx)
f01004f7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004fc:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100501:	ee                   	out    %al,(%dx)
f0100502:	b8 08 00 00 00       	mov    $0x8,%eax
f0100507:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100508:	89 fa                	mov    %edi,%edx
f010050a:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100510:	89 f8                	mov    %edi,%eax
f0100512:	80 cc 07             	or     $0x7,%ah
f0100515:	85 d2                	test   %edx,%edx
f0100517:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010051a:	89 f8                	mov    %edi,%eax
f010051c:	0f b6 c0             	movzbl %al,%eax
f010051f:	83 f8 09             	cmp    $0x9,%eax
f0100522:	74 78                	je     f010059c <cons_putc+0x117>
f0100524:	83 f8 09             	cmp    $0x9,%eax
f0100527:	7f 0a                	jg     f0100533 <cons_putc+0xae>
f0100529:	83 f8 08             	cmp    $0x8,%eax
f010052c:	74 14                	je     f0100542 <cons_putc+0xbd>
f010052e:	e9 9d 00 00 00       	jmp    f01005d0 <cons_putc+0x14b>
f0100533:	83 f8 0a             	cmp    $0xa,%eax
f0100536:	74 3a                	je     f0100572 <cons_putc+0xed>
f0100538:	83 f8 0d             	cmp    $0xd,%eax
f010053b:	74 3e                	je     f010057b <cons_putc+0xf6>
f010053d:	e9 8e 00 00 00       	jmp    f01005d0 <cons_putc+0x14b>
	case '\b':
		if (crt_pos > 0) {
f0100542:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f0100549:	66 85 c0             	test   %ax,%ax
f010054c:	0f 84 eb 00 00 00    	je     f010063d <cons_putc+0x1b8>
			crt_pos--;
f0100552:	83 e8 01             	sub    $0x1,%eax
f0100555:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010055b:	0f b7 c0             	movzwl %ax,%eax
f010055e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100563:	83 cf 20             	or     $0x20,%edi
f0100566:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f010056c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100570:	eb 7c                	jmp    f01005ee <cons_putc+0x169>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100572:	66 81 05 28 22 21 f0 	addw   $0x8f,0xf0212228
f0100579:	8f 00 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010057b:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f0100582:	69 c0 93 72 00 00    	imul   $0x7293,%eax,%eax
f0100588:	c1 e8 16             	shr    $0x16,%eax
f010058b:	8d 14 c0             	lea    (%eax,%eax,8),%edx
f010058e:	c1 e2 04             	shl    $0x4,%edx
f0100591:	29 c2                	sub    %eax,%edx
f0100593:	66 89 15 28 22 21 f0 	mov    %dx,0xf0212228
f010059a:	eb 52                	jmp    f01005ee <cons_putc+0x169>
		break;
	case '\t':
		cons_putc(' ');
f010059c:	b8 20 00 00 00       	mov    $0x20,%eax
f01005a1:	e8 df fe ff ff       	call   f0100485 <cons_putc>
		cons_putc(' ');
f01005a6:	b8 20 00 00 00       	mov    $0x20,%eax
f01005ab:	e8 d5 fe ff ff       	call   f0100485 <cons_putc>
		cons_putc(' ');
f01005b0:	b8 20 00 00 00       	mov    $0x20,%eax
f01005b5:	e8 cb fe ff ff       	call   f0100485 <cons_putc>
		cons_putc(' ');
f01005ba:	b8 20 00 00 00       	mov    $0x20,%eax
f01005bf:	e8 c1 fe ff ff       	call   f0100485 <cons_putc>
		cons_putc(' ');
f01005c4:	b8 20 00 00 00       	mov    $0x20,%eax
f01005c9:	e8 b7 fe ff ff       	call   f0100485 <cons_putc>
f01005ce:	eb 1e                	jmp    f01005ee <cons_putc+0x169>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01005d0:	0f b7 05 28 22 21 f0 	movzwl 0xf0212228,%eax
f01005d7:	8d 50 01             	lea    0x1(%eax),%edx
f01005da:	66 89 15 28 22 21 f0 	mov    %dx,0xf0212228
f01005e1:	0f b7 c0             	movzwl %ax,%eax
f01005e4:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f01005ea:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005ee:	66 81 3d 28 22 21 f0 	cmpw   $0x1804,0xf0212228
f01005f5:	04 18 
f01005f7:	76 44                	jbe    f010063d <cons_putc+0x1b8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005f9:	a1 2c 22 21 f0       	mov    0xf021222c,%eax
f01005fe:	83 ec 04             	sub    $0x4,%esp
f0100601:	68 ec 2e 00 00       	push   $0x2eec
f0100606:	8d 90 1e 01 00 00    	lea    0x11e(%eax),%edx
f010060c:	52                   	push   %edx
f010060d:	50                   	push   %eax
f010060e:	e8 de 50 00 00       	call   f01056f1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100613:	8b 15 2c 22 21 f0    	mov    0xf021222c,%edx
f0100619:	8d 82 ec 2e 00 00    	lea    0x2eec(%edx),%eax
f010061f:	81 c2 0a 30 00 00    	add    $0x300a,%edx
f0100625:	83 c4 10             	add    $0x10,%esp
f0100628:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010062d:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100630:	39 d0                	cmp    %edx,%eax
f0100632:	75 f4                	jne    f0100628 <cons_putc+0x1a3>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100634:	66 81 2d 28 22 21 f0 	subw   $0x8f,0xf0212228
f010063b:	8f 00 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010063d:	8b 0d 30 22 21 f0    	mov    0xf0212230,%ecx
f0100643:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100648:	89 ca                	mov    %ecx,%edx
f010064a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010064b:	0f b7 1d 28 22 21 f0 	movzwl 0xf0212228,%ebx
f0100652:	8d 71 01             	lea    0x1(%ecx),%esi
f0100655:	89 d8                	mov    %ebx,%eax
f0100657:	66 c1 e8 08          	shr    $0x8,%ax
f010065b:	89 f2                	mov    %esi,%edx
f010065d:	ee                   	out    %al,(%dx)
f010065e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100663:	89 ca                	mov    %ecx,%edx
f0100665:	ee                   	out    %al,(%dx)
f0100666:	89 d8                	mov    %ebx,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010066e:	5b                   	pop    %ebx
f010066f:	5e                   	pop    %esi
f0100670:	5f                   	pop    %edi
f0100671:	5d                   	pop    %ebp
f0100672:	c3                   	ret    

f0100673 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100673:	80 3d 34 22 21 f0 00 	cmpb   $0x0,0xf0212234
f010067a:	74 11                	je     f010068d <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
f010067f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100682:	b8 0a 03 10 f0       	mov    $0xf010030a,%eax
f0100687:	e8 9d fc ff ff       	call   f0100329 <cons_intr>
}
f010068c:	c9                   	leave  
f010068d:	f3 c3                	repz ret 

f010068f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100695:	b8 6c 03 10 f0       	mov    $0xf010036c,%eax
f010069a:	e8 8a fc ff ff       	call   f0100329 <cons_intr>
}
f010069f:	c9                   	leave  
f01006a0:	c3                   	ret    

f01006a1 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01006a1:	55                   	push   %ebp
f01006a2:	89 e5                	mov    %esp,%ebp
f01006a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01006a7:	e8 c7 ff ff ff       	call   f0100673 <serial_intr>
	kbd_intr();
f01006ac:	e8 de ff ff ff       	call   f010068f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01006b1:	a1 20 22 21 f0       	mov    0xf0212220,%eax
f01006b6:	3b 05 24 22 21 f0    	cmp    0xf0212224,%eax
f01006bc:	74 26                	je     f01006e4 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01006be:	8d 50 01             	lea    0x1(%eax),%edx
f01006c1:	89 15 20 22 21 f0    	mov    %edx,0xf0212220
f01006c7:	0f b6 88 20 20 21 f0 	movzbl -0xfdedfe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01006ce:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01006d0:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01006d6:	75 11                	jne    f01006e9 <cons_getc+0x48>
			cons.rpos = 0;
f01006d8:	c7 05 20 22 21 f0 00 	movl   $0x0,0xf0212220
f01006df:	00 00 00 
f01006e2:	eb 05                	jmp    f01006e9 <cons_getc+0x48>
		return c;
	}
	return 0;
f01006e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006e9:	c9                   	leave  
f01006ea:	c3                   	ret    

f01006eb <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006eb:	55                   	push   %ebp
f01006ec:	89 e5                	mov    %esp,%ebp
f01006ee:	57                   	push   %edi
f01006ef:	56                   	push   %esi
f01006f0:	53                   	push   %ebx
f01006f1:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006f4:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006fb:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100702:	5a a5 
	if (*cp != 0xA55A) {
f0100704:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010070b:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010070f:	74 11                	je     f0100722 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100711:	c7 05 30 22 21 f0 b4 	movl   $0x3b4,0xf0212230
f0100718:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010071b:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100720:	eb 16                	jmp    f0100738 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100722:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100729:	c7 05 30 22 21 f0 d4 	movl   $0x3d4,0xf0212230
f0100730:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100733:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100738:	8b 3d 30 22 21 f0    	mov    0xf0212230,%edi
f010073e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100743:	89 fa                	mov    %edi,%edx
f0100745:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100746:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100749:	89 da                	mov    %ebx,%edx
f010074b:	ec                   	in     (%dx),%al
f010074c:	0f b6 c8             	movzbl %al,%ecx
f010074f:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100752:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100757:	89 fa                	mov    %edi,%edx
f0100759:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075a:	89 da                	mov    %ebx,%edx
f010075c:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010075d:	89 35 2c 22 21 f0    	mov    %esi,0xf021222c
	crt_pos = pos;
f0100763:	0f b6 c0             	movzbl %al,%eax
f0100766:	09 c8                	or     %ecx,%eax
f0100768:	66 a3 28 22 21 f0    	mov    %ax,0xf0212228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010076e:	e8 1c ff ff ff       	call   f010068f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100773:	83 ec 0c             	sub    $0xc,%esp
f0100776:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010077d:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100782:	50                   	push   %eax
f0100783:	e8 96 2f 00 00       	call   f010371e <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100788:	be fa 03 00 00       	mov    $0x3fa,%esi
f010078d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100792:	89 f2                	mov    %esi,%edx
f0100794:	ee                   	out    %al,(%dx)
f0100795:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010079a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010079f:	ee                   	out    %al,(%dx)
f01007a0:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01007a5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01007aa:	89 da                	mov    %ebx,%edx
f01007ac:	ee                   	out    %al,(%dx)
f01007ad:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01007b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007b7:	ee                   	out    %al,(%dx)
f01007b8:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01007bd:	b8 03 00 00 00       	mov    $0x3,%eax
f01007c2:	ee                   	out    %al,(%dx)
f01007c3:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01007c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007cd:	ee                   	out    %al,(%dx)
f01007ce:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01007d3:	b8 01 00 00 00       	mov    $0x1,%eax
f01007d8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007d9:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01007de:	ec                   	in     (%dx),%al
f01007df:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007e1:	83 c4 10             	add    $0x10,%esp
f01007e4:	3c ff                	cmp    $0xff,%al
f01007e6:	0f 95 05 34 22 21 f0 	setne  0xf0212234
f01007ed:	89 f2                	mov    %esi,%edx
f01007ef:	ec                   	in     (%dx),%al
f01007f0:	89 da                	mov    %ebx,%edx
f01007f2:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f01007f3:	80 f9 ff             	cmp    $0xff,%cl
f01007f6:	74 21                	je     f0100819 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f01007f8:	83 ec 0c             	sub    $0xc,%esp
f01007fb:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0100802:	25 ef ff 00 00       	and    $0xffef,%eax
f0100807:	50                   	push   %eax
f0100808:	e8 11 2f 00 00       	call   f010371e <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010080d:	83 c4 10             	add    $0x10,%esp
f0100810:	80 3d 34 22 21 f0 00 	cmpb   $0x0,0xf0212234
f0100817:	75 10                	jne    f0100829 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100819:	83 ec 0c             	sub    $0xc,%esp
f010081c:	68 cc 64 10 f0       	push   $0xf01064cc
f0100821:	e8 49 30 00 00       	call   f010386f <cprintf>
f0100826:	83 c4 10             	add    $0x10,%esp
}
f0100829:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010082c:	5b                   	pop    %ebx
f010082d:	5e                   	pop    %esi
f010082e:	5f                   	pop    %edi
f010082f:	5d                   	pop    %ebp
f0100830:	c3                   	ret    

f0100831 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100831:	55                   	push   %ebp
f0100832:	89 e5                	mov    %esp,%ebp
f0100834:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100837:	8b 45 08             	mov    0x8(%ebp),%eax
f010083a:	e8 46 fc ff ff       	call   f0100485 <cons_putc>
}
f010083f:	c9                   	leave  
f0100840:	c3                   	ret    

f0100841 <getchar>:

int
getchar(void)
{
f0100841:	55                   	push   %ebp
f0100842:	89 e5                	mov    %esp,%ebp
f0100844:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100847:	e8 55 fe ff ff       	call   f01006a1 <cons_getc>
f010084c:	85 c0                	test   %eax,%eax
f010084e:	74 f7                	je     f0100847 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100850:	c9                   	leave  
f0100851:	c3                   	ret    

f0100852 <iscons>:

int
iscons(int fdnum)
{
f0100852:	55                   	push   %ebp
f0100853:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100855:	b8 01 00 00 00       	mov    $0x1,%eax
f010085a:	5d                   	pop    %ebp
f010085b:	c3                   	ret    

f010085c <mon_quit>:

	}

	return 0x1001;
}
int mon_quit(int agrc,char **agrv,struct Trapframe *tf){
f010085c:	55                   	push   %ebp
f010085d:	89 e5                	mov    %esp,%ebp
	
	return -1;
}
f010085f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100864:	5d                   	pop    %ebp
f0100865:	c3                   	ret    

f0100866 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100866:	55                   	push   %ebp
f0100867:	89 e5                	mov    %esp,%ebp
f0100869:	56                   	push   %esi
f010086a:	53                   	push   %ebx
f010086b:	bb 20 6a 10 f0       	mov    $0xf0106a20,%ebx
f0100870:	be 50 6a 10 f0       	mov    $0xf0106a50,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100875:	83 ec 04             	sub    $0x4,%esp
f0100878:	ff 73 04             	pushl  0x4(%ebx)
f010087b:	ff 33                	pushl  (%ebx)
f010087d:	68 20 67 10 f0       	push   $0xf0106720
f0100882:	e8 e8 2f 00 00       	call   f010386f <cprintf>
f0100887:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010088a:	83 c4 10             	add    $0x10,%esp
f010088d:	39 f3                	cmp    %esi,%ebx
f010088f:	75 e4                	jne    f0100875 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100891:	b8 00 00 00 00       	mov    $0x0,%eax
f0100896:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100899:	5b                   	pop    %ebx
f010089a:	5e                   	pop    %esi
f010089b:	5d                   	pop    %ebp
f010089c:	c3                   	ret    

f010089d <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010089d:	55                   	push   %ebp
f010089e:	89 e5                	mov    %esp,%ebp
f01008a0:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008a3:	68 29 67 10 f0       	push   $0xf0106729
f01008a8:	e8 c2 2f 00 00       	call   f010386f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008ad:	83 c4 08             	add    $0x8,%esp
f01008b0:	68 0c 00 10 00       	push   $0x10000c
f01008b5:	68 24 68 10 f0       	push   $0xf0106824
f01008ba:	e8 b0 2f 00 00       	call   f010386f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01008bf:	83 c4 0c             	add    $0xc,%esp
f01008c2:	68 0c 00 10 00       	push   $0x10000c
f01008c7:	68 0c 00 10 f0       	push   $0xf010000c
f01008cc:	68 4c 68 10 f0       	push   $0xf010684c
f01008d1:	e8 99 2f 00 00       	call   f010386f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008d6:	83 c4 0c             	add    $0xc,%esp
f01008d9:	68 41 63 10 00       	push   $0x106341
f01008de:	68 41 63 10 f0       	push   $0xf0106341
f01008e3:	68 70 68 10 f0       	push   $0xf0106870
f01008e8:	e8 82 2f 00 00       	call   f010386f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008ed:	83 c4 0c             	add    $0xc,%esp
f01008f0:	68 e0 1a 21 00       	push   $0x211ae0
f01008f5:	68 e0 1a 21 f0       	push   $0xf0211ae0
f01008fa:	68 94 68 10 f0       	push   $0xf0106894
f01008ff:	e8 6b 2f 00 00       	call   f010386f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100904:	83 c4 0c             	add    $0xc,%esp
f0100907:	68 08 40 25 00       	push   $0x254008
f010090c:	68 08 40 25 f0       	push   $0xf0254008
f0100911:	68 b8 68 10 f0       	push   $0xf01068b8
f0100916:	e8 54 2f 00 00       	call   f010386f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010091b:	b8 07 44 25 f0       	mov    $0xf0254407,%eax
f0100920:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100925:	83 c4 08             	add    $0x8,%esp
f0100928:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010092d:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100933:	85 c0                	test   %eax,%eax
f0100935:	0f 48 c2             	cmovs  %edx,%eax
f0100938:	c1 f8 0a             	sar    $0xa,%eax
f010093b:	50                   	push   %eax
f010093c:	68 dc 68 10 f0       	push   $0xf01068dc
f0100941:	e8 29 2f 00 00       	call   f010386f <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100946:	b8 00 00 00 00       	mov    $0x0,%eax
f010094b:	c9                   	leave  
f010094c:	c3                   	ret    

f010094d <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010094d:	55                   	push   %ebp
f010094e:	89 e5                	mov    %esp,%ebp
f0100950:	57                   	push   %edi
f0100951:	56                   	push   %esi
f0100952:	53                   	push   %ebx
f0100953:	83 ec 2c             	sub    $0x2c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100956:	89 ea                	mov    %ebp,%edx
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
f0100958:	89 d0                	mov    %edx,%eax
	int before_ebp = *(int*)esp_position;
f010095a:	8b 32                	mov    (%edx),%esi
		int pra_5 = (int)*((int*)esp_position+6);
	
		cprintf("ebp:0x%8.0x eip:0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x\n",esp_position,eip,pra_1,pra_2,pra_3,pra_4,pra_5);
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f010095c:	8d 7d d0             	lea    -0x30(%ebp),%edi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
	int before_ebp = *(int*)esp_position;
	while(before_ebp != 0){//here the ebp is 0,because the i386_init set it 0 before it comes into a real function
f010095f:	eb 48                	jmp    f01009a9 <mon_backtrace+0x5c>
		before_ebp = *(int*)esp_position;//read the ebp of the before stack
f0100961:	8b 30                	mov    (%eax),%esi
		int eip = (int)*((int*)esp_position+1);
f0100963:	8b 58 04             	mov    0x4(%eax),%ebx
		int pra_2 = (int)*((int*)esp_position+3);
		int pra_3 = (int)*((int*)esp_position+4);
		int pra_4 = (int)*((int*)esp_position+5);
		int pra_5 = (int)*((int*)esp_position+6);
	
		cprintf("ebp:0x%8.0x eip:0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x\n",esp_position,eip,pra_1,pra_2,pra_3,pra_4,pra_5);
f0100966:	ff 70 18             	pushl  0x18(%eax)
f0100969:	ff 70 14             	pushl  0x14(%eax)
f010096c:	ff 70 10             	pushl  0x10(%eax)
f010096f:	ff 70 0c             	pushl  0xc(%eax)
f0100972:	ff 70 08             	pushl  0x8(%eax)
f0100975:	53                   	push   %ebx
f0100976:	50                   	push   %eax
f0100977:	68 08 69 10 f0       	push   $0xf0106908
f010097c:	e8 ee 2e 00 00       	call   f010386f <cprintf>
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f0100981:	83 c4 18             	add    $0x18,%esp
f0100984:	57                   	push   %edi
f0100985:	53                   	push   %ebx
f0100986:	e8 58 43 00 00       	call   f0104ce3 <debuginfo_eip>
		cprintf("%s:%d   %s:%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip-info.eip_fn_addr);	
f010098b:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010098e:	89 1c 24             	mov    %ebx,(%esp)
f0100991:	ff 75 d8             	pushl  -0x28(%ebp)
f0100994:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100997:	ff 75 d0             	pushl  -0x30(%ebp)
f010099a:	68 42 67 10 f0       	push   $0xf0106742
f010099f:	e8 cb 2e 00 00       	call   f010386f <cprintf>
f01009a4:	83 c4 20             	add    $0x20,%esp

		//finally we can get the pra num of one function by info.
		esp_position = before_ebp;		
f01009a7:	89 f0                	mov    %esi,%eax
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
	int before_ebp = *(int*)esp_position;
	while(before_ebp != 0){//here the ebp is 0,because the i386_init set it 0 before it comes into a real function
f01009a9:	85 f6                	test   %esi,%esi
f01009ab:	75 b4                	jne    f0100961 <mon_backtrace+0x14>
		esp_position = before_ebp;		

	}

	return 0x1001;
}
f01009ad:	b8 01 10 00 00       	mov    $0x1001,%eax
f01009b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009b5:	5b                   	pop    %ebx
f01009b6:	5e                   	pop    %esi
f01009b7:	5f                   	pop    %edi
f01009b8:	5d                   	pop    %ebp
f01009b9:	c3                   	ret    

f01009ba <mon_test>:
int mon_quit(int agrc,char **agrv,struct Trapframe *tf){
	
	return -1;
}
//just my own code for test ,delete please.
int mon_test(int argc,char **argv,int argc1,int argc2,int argc3,int argc4,struct Trapframe *tf){
f01009ba:	55                   	push   %ebp
f01009bb:	89 e5                	mov    %esp,%ebp
	return 1;
}
f01009bd:	b8 01 00 00 00       	mov    $0x1,%eax
f01009c2:	5d                   	pop    %ebp
f01009c3:	c3                   	ret    

f01009c4 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009c4:	55                   	push   %ebp
f01009c5:	89 e5                	mov    %esp,%ebp
f01009c7:	57                   	push   %edi
f01009c8:	56                   	push   %esi
f01009c9:	53                   	push   %ebx
f01009ca:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009cd:	68 4c 69 10 f0       	push   $0xf010694c
f01009d2:	e8 98 2e 00 00       	call   f010386f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009d7:	c7 04 24 70 69 10 f0 	movl   $0xf0106970,(%esp)
f01009de:	e8 8c 2e 00 00       	call   f010386f <cprintf>


	if (tf != NULL)
f01009e3:	83 c4 10             	add    $0x10,%esp
f01009e6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009ea:	74 0e                	je     f01009fa <monitor+0x36>
		print_trapframe(tf);
f01009ec:	83 ec 0c             	sub    $0xc,%esp
f01009ef:	ff 75 08             	pushl  0x8(%ebp)
f01009f2:	e8 cb 33 00 00       	call   f0103dc2 <print_trapframe>
f01009f7:	83 c4 10             	add    $0x10,%esp


	//my code here 
	cprintf("here show code of myself\n");
f01009fa:	83 ec 0c             	sub    $0xc,%esp
f01009fd:	68 51 67 10 f0       	push   $0xf0106751
f0100a02:	e8 68 2e 00 00       	call   f010386f <cprintf>
	for(int i = 0;i<200;i++){
		cprintf("%d",i);
		cprintf("abcdefghijklmnopqrstuvwxyz0123456789");
	}
	*/
	cprintf("yourname is xuyongkang.");
f0100a07:	c7 04 24 6b 67 10 f0 	movl   $0xf010676b,(%esp)
f0100a0e:	e8 5c 2e 00 00       	call   f010386f <cprintf>
	cprintf("\033[1m\033[45;33m HELLO_WORLD \033[0m\n");
f0100a13:	c7 04 24 98 69 10 f0 	movl   $0xf0106998,(%esp)
f0100a1a:	e8 50 2e 00 00       	call   f010386f <cprintf>
	cprintf("\a\n");
f0100a1f:	c7 04 24 83 67 10 f0 	movl   $0xf0106783,(%esp)
f0100a26:	e8 44 2e 00 00       	call   f010386f <cprintf>
	cprintf("\a\n");
f0100a2b:	c7 04 24 83 67 10 f0 	movl   $0xf0106783,(%esp)
f0100a32:	e8 38 2e 00 00       	call   f010386f <cprintf>
	int x = 1,y = 3,z = 4;
	cprintf("x %d,y %x,z %x\n",x,y,z);
f0100a37:	6a 04                	push   $0x4
f0100a39:	6a 03                	push   $0x3
f0100a3b:	6a 01                	push   $0x1
f0100a3d:	68 86 67 10 f0       	push   $0xf0106786
f0100a42:	e8 28 2e 00 00       	call   f010386f <cprintf>
	cprintf("x %d,y %x,z %x\n",x,y,z);
f0100a47:	83 c4 20             	add    $0x20,%esp
f0100a4a:	6a 04                	push   $0x4
f0100a4c:	6a 03                	push   $0x3
f0100a4e:	6a 01                	push   $0x1
f0100a50:	68 86 67 10 f0       	push   $0xf0106786
f0100a55:	e8 15 2e 00 00       	call   f010386f <cprintf>
 	cprintf("x,y,x");
f0100a5a:	c7 04 24 96 67 10 f0 	movl   $0xf0106796,(%esp)
f0100a61:	e8 09 2e 00 00       	call   f010386f <cprintf>
f0100a66:	83 c4 10             	add    $0x10,%esp
       

	//my code end

	while (1) {
		buf = readline("K> ");
f0100a69:	83 ec 0c             	sub    $0xc,%esp
f0100a6c:	68 9c 67 10 f0       	push   $0xf010679c
f0100a71:	e8 bf 49 00 00       	call   f0105435 <readline>
f0100a76:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a78:	83 c4 10             	add    $0x10,%esp
f0100a7b:	85 c0                	test   %eax,%eax
f0100a7d:	74 ea                	je     f0100a69 <monitor+0xa5>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a7f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a86:	be 00 00 00 00       	mov    $0x0,%esi
f0100a8b:	eb 0a                	jmp    f0100a97 <monitor+0xd3>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a8d:	c6 03 00             	movb   $0x0,(%ebx)
f0100a90:	89 f7                	mov    %esi,%edi
f0100a92:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a95:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a97:	0f b6 03             	movzbl (%ebx),%eax
f0100a9a:	84 c0                	test   %al,%al
f0100a9c:	74 63                	je     f0100b01 <monitor+0x13d>
f0100a9e:	83 ec 08             	sub    $0x8,%esp
f0100aa1:	0f be c0             	movsbl %al,%eax
f0100aa4:	50                   	push   %eax
f0100aa5:	68 a0 67 10 f0       	push   $0xf01067a0
f0100aaa:	e8 b8 4b 00 00       	call   f0105667 <strchr>
f0100aaf:	83 c4 10             	add    $0x10,%esp
f0100ab2:	85 c0                	test   %eax,%eax
f0100ab4:	75 d7                	jne    f0100a8d <monitor+0xc9>
			*buf++ = 0;
		if (*buf == 0)
f0100ab6:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100ab9:	74 46                	je     f0100b01 <monitor+0x13d>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100abb:	83 fe 0f             	cmp    $0xf,%esi
f0100abe:	75 14                	jne    f0100ad4 <monitor+0x110>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ac0:	83 ec 08             	sub    $0x8,%esp
f0100ac3:	6a 10                	push   $0x10
f0100ac5:	68 a5 67 10 f0       	push   $0xf01067a5
f0100aca:	e8 a0 2d 00 00       	call   f010386f <cprintf>
f0100acf:	83 c4 10             	add    $0x10,%esp
f0100ad2:	eb 95                	jmp    f0100a69 <monitor+0xa5>
			return 0;
		}
		argv[argc++] = buf;
f0100ad4:	8d 7e 01             	lea    0x1(%esi),%edi
f0100ad7:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100adb:	eb 03                	jmp    f0100ae0 <monitor+0x11c>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100add:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ae0:	0f b6 03             	movzbl (%ebx),%eax
f0100ae3:	84 c0                	test   %al,%al
f0100ae5:	74 ae                	je     f0100a95 <monitor+0xd1>
f0100ae7:	83 ec 08             	sub    $0x8,%esp
f0100aea:	0f be c0             	movsbl %al,%eax
f0100aed:	50                   	push   %eax
f0100aee:	68 a0 67 10 f0       	push   $0xf01067a0
f0100af3:	e8 6f 4b 00 00       	call   f0105667 <strchr>
f0100af8:	83 c4 10             	add    $0x10,%esp
f0100afb:	85 c0                	test   %eax,%eax
f0100afd:	74 de                	je     f0100add <monitor+0x119>
f0100aff:	eb 94                	jmp    f0100a95 <monitor+0xd1>
			buf++;
	}
	argv[argc] = 0;
f0100b01:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b08:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100b09:	85 f6                	test   %esi,%esi
f0100b0b:	0f 84 58 ff ff ff    	je     f0100a69 <monitor+0xa5>
f0100b11:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b16:	83 ec 08             	sub    $0x8,%esp
f0100b19:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b1c:	ff 34 85 20 6a 10 f0 	pushl  -0xfef95e0(,%eax,4)
f0100b23:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b26:	e8 de 4a 00 00       	call   f0105609 <strcmp>
f0100b2b:	83 c4 10             	add    $0x10,%esp
f0100b2e:	85 c0                	test   %eax,%eax
f0100b30:	75 21                	jne    f0100b53 <monitor+0x18f>
			return commands[i].func(argc, argv, tf);
f0100b32:	83 ec 04             	sub    $0x4,%esp
f0100b35:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b38:	ff 75 08             	pushl  0x8(%ebp)
f0100b3b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b3e:	52                   	push   %edx
f0100b3f:	56                   	push   %esi
f0100b40:	ff 14 85 28 6a 10 f0 	call   *-0xfef95d8(,%eax,4)
	//my code end

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100b47:	83 c4 10             	add    $0x10,%esp
f0100b4a:	85 c0                	test   %eax,%eax
f0100b4c:	78 25                	js     f0100b73 <monitor+0x1af>
f0100b4e:	e9 16 ff ff ff       	jmp    f0100a69 <monitor+0xa5>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b53:	83 c3 01             	add    $0x1,%ebx
f0100b56:	83 fb 04             	cmp    $0x4,%ebx
f0100b59:	75 bb                	jne    f0100b16 <monitor+0x152>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b5b:	83 ec 08             	sub    $0x8,%esp
f0100b5e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b61:	68 c2 67 10 f0       	push   $0xf01067c2
f0100b66:	e8 04 2d 00 00       	call   f010386f <cprintf>
f0100b6b:	83 c4 10             	add    $0x10,%esp
f0100b6e:	e9 f6 fe ff ff       	jmp    f0100a69 <monitor+0xa5>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b76:	5b                   	pop    %ebx
f0100b77:	5e                   	pop    %esi
f0100b78:	5f                   	pop    %edi
f0100b79:	5d                   	pop    %ebp
f0100b7a:	c3                   	ret    

f0100b7b <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b7b:	55                   	push   %ebp
f0100b7c:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b7e:	83 3d 38 22 21 f0 00 	cmpl   $0x0,0xf0212238
f0100b85:	75 11                	jne    f0100b98 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b87:	ba 07 50 25 f0       	mov    $0xf0255007,%edx
f0100b8c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b92:	89 15 38 22 21 f0    	mov    %edx,0xf0212238
	if(n>0){
		result = nextfree;
		nextfree = ROUNDUP(nextfree+n,PGSIZE);
		return result;
	}else{
		return nextfree;
f0100b98:	8b 15 38 22 21 f0    	mov    0xf0212238,%edx
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n>0){
f0100b9e:	85 c0                	test   %eax,%eax
f0100ba0:	74 11                	je     f0100bb3 <boot_alloc+0x38>
		result = nextfree;
		nextfree = ROUNDUP(nextfree+n,PGSIZE);
f0100ba2:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100ba9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bae:	a3 38 22 21 f0       	mov    %eax,0xf0212238
		return result;
	}else{
		return nextfree;
	}
	return NULL;
}
f0100bb3:	89 d0                	mov    %edx,%eax
f0100bb5:	5d                   	pop    %ebp
f0100bb6:	c3                   	ret    

f0100bb7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bb7:	55                   	push   %ebp
f0100bb8:	89 e5                	mov    %esp,%ebp
f0100bba:	56                   	push   %esi
f0100bbb:	53                   	push   %ebx
f0100bbc:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100bbe:	83 ec 0c             	sub    $0xc,%esp
f0100bc1:	50                   	push   %eax
f0100bc2:	e8 29 2b 00 00       	call   f01036f0 <mc146818_read>
f0100bc7:	89 c6                	mov    %eax,%esi
f0100bc9:	83 c3 01             	add    $0x1,%ebx
f0100bcc:	89 1c 24             	mov    %ebx,(%esp)
f0100bcf:	e8 1c 2b 00 00       	call   f01036f0 <mc146818_read>
f0100bd4:	c1 e0 08             	shl    $0x8,%eax
f0100bd7:	09 f0                	or     %esi,%eax
}
f0100bd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100bdc:	5b                   	pop    %ebx
f0100bdd:	5e                   	pop    %esi
f0100bde:	5d                   	pop    %ebp
f0100bdf:	c3                   	ret    

f0100be0 <check_va2pa>:
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
//	cprintf("	*pgdir: 0x%x\n",*pgdir);
	if (!(*pgdir & PTE_P))
f0100be0:	89 d1                	mov    %edx,%ecx
f0100be2:	c1 e9 16             	shr    $0x16,%ecx
f0100be5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100be8:	a8 01                	test   $0x1,%al
f0100bea:	74 52                	je     f0100c3e <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100bec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bf1:	89 c1                	mov    %eax,%ecx
f0100bf3:	c1 e9 0c             	shr    $0xc,%ecx
f0100bf6:	3b 0d 88 2e 21 f0    	cmp    0xf0212e88,%ecx
f0100bfc:	72 1b                	jb     f0100c19 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100bfe:	55                   	push   %ebp
f0100bff:	89 e5                	mov    %esp,%ebp
f0100c01:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c04:	50                   	push   %eax
f0100c05:	68 48 64 10 f0       	push   $0xf0106448
f0100c0a:	68 2f 05 00 00       	push   $0x52f
f0100c0f:	68 c1 73 10 f0       	push   $0xf01073c1
f0100c14:	e8 7b f4 ff ff       	call   f0100094 <_panic>
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
//	cprintf("	PTX(va):%x\n",PTX(va));
//	cprintf("	p[PTX(va)]:0x%x\n",p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100c19:	c1 ea 0c             	shr    $0xc,%edx
f0100c1c:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c22:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c29:	89 c2                	mov    %eax,%edx
f0100c2b:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c2e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c33:	85 d2                	test   %edx,%edx
f0100c35:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c3a:	0f 44 c2             	cmove  %edx,%eax
f0100c3d:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
//	cprintf("	*pgdir: 0x%x\n",*pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0100c3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
//	cprintf("	PTX(va):%x\n",PTX(va));
//	cprintf("	p[PTX(va)]:0x%x\n",p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100c43:	c3                   	ret    

f0100c44 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100c44:	55                   	push   %ebp
f0100c45:	89 e5                	mov    %esp,%ebp
f0100c47:	57                   	push   %edi
f0100c48:	56                   	push   %esi
f0100c49:	53                   	push   %ebx
f0100c4a:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c4d:	84 c0                	test   %al,%al
f0100c4f:	0f 85 9d 02 00 00    	jne    f0100ef2 <check_page_free_list+0x2ae>
f0100c55:	e9 aa 02 00 00       	jmp    f0100f04 <check_page_free_list+0x2c0>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100c5a:	83 ec 04             	sub    $0x4,%esp
f0100c5d:	68 50 6a 10 f0       	push   $0xf0106a50
f0100c62:	68 31 04 00 00       	push   $0x431
f0100c67:	68 c1 73 10 f0       	push   $0xf01073c1
f0100c6c:	e8 23 f4 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c71:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c74:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c77:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c7d:	89 c2                	mov    %eax,%edx
f0100c7f:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0100c85:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c8b:	0f 95 c2             	setne  %dl
f0100c8e:	0f b6 d2             	movzbl %dl,%edx
			//cprintf("page2pa(pp):%x\n",page2pa(pp));
			//cprintf("PDX(page2pa(pp)):%x\n",PDX(page2pa(pp)));
			//cprintf("pagetype:%x\n",pagetype);
			*tp[pagetype] = pp;
f0100c91:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c95:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c97:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9b:	8b 00                	mov    (%eax),%eax
f0100c9d:	85 c0                	test   %eax,%eax
f0100c9f:	75 dc                	jne    f0100c7d <check_page_free_list+0x39>
			//cprintf("PDX(page2pa(pp)):%x\n",PDX(page2pa(pp)));
			//cprintf("pagetype:%x\n",pagetype);
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ca1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ca4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100caa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cad:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cb0:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cb2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cb5:	a3 40 22 21 f0       	mov    %eax,0xf0212240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cba:	be 01 00 00 00       	mov    $0x1,%esi
//		cprintf("pp1 next :%x\n",pp1->pp_link);
	}
//	cprintf("here after the only_low_memory\n");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cbf:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
f0100cc5:	eb 50                	jmp    f0100d17 <check_page_free_list+0xd3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cc7:	89 d8                	mov    %ebx,%eax
f0100cc9:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0100ccf:	c1 f8 03             	sar    $0x3,%eax
f0100cd2:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit){
f0100cd5:	89 c2                	mov    %eax,%edx
f0100cd7:	c1 ea 16             	shr    $0x16,%edx
f0100cda:	39 f2                	cmp    %esi,%edx
f0100cdc:	73 37                	jae    f0100d15 <check_page_free_list+0xd1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cde:	89 c2                	mov    %eax,%edx
f0100ce0:	c1 ea 0c             	shr    $0xc,%edx
f0100ce3:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0100ce9:	72 12                	jb     f0100cfd <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ceb:	50                   	push   %eax
f0100cec:	68 48 64 10 f0       	push   $0xf0106448
f0100cf1:	6a 58                	push   $0x58
f0100cf3:	68 cd 73 10 f0       	push   $0xf01073cd
f0100cf8:	e8 97 f3 ff ff       	call   f0100094 <_panic>
			//cprintf("PageInfo.size():%x\n",sizeof(struct PageInfo));

			//:/cprintf("#check_page_free_list:page2kva(pp):%x\n",page2kva(pp));
			memset(page2kva(pp), 0x00, 128);
f0100cfd:	83 ec 04             	sub    $0x4,%esp
f0100d00:	68 80 00 00 00       	push   $0x80
f0100d05:	6a 00                	push   $0x0
f0100d07:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d0c:	50                   	push   %eax
f0100d0d:	e8 92 49 00 00       	call   f01056a4 <memset>
f0100d12:	83 c4 10             	add    $0x10,%esp
//		cprintf("pp1 next :%x\n",pp1->pp_link);
	}
//	cprintf("here after the only_low_memory\n");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d15:	8b 1b                	mov    (%ebx),%ebx
f0100d17:	85 db                	test   %ebx,%ebx
f0100d19:	75 ac                	jne    f0100cc7 <check_page_free_list+0x83>
		}else{
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
f0100d1b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d20:	e8 56 fe ff ff       	call   f0100b7b <boot_alloc>
f0100d25:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d28:	8b 15 40 22 21 f0    	mov    0xf0212240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d2e:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
		assert(pp < pages + npages);
f0100d34:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f0100d39:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100d3c:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d42:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d45:	be 00 00 00 00       	mov    $0x0,%esi
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d4a:	e9 52 01 00 00       	jmp    f0100ea1 <check_page_free_list+0x25d>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100d4f:	39 ca                	cmp    %ecx,%edx
f0100d51:	73 19                	jae    f0100d6c <check_page_free_list+0x128>
f0100d53:	68 db 73 10 f0       	push   $0xf01073db
f0100d58:	68 e7 73 10 f0       	push   $0xf01073e7
f0100d5d:	68 58 04 00 00       	push   $0x458
f0100d62:	68 c1 73 10 f0       	push   $0xf01073c1
f0100d67:	e8 28 f3 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100d6c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d6f:	72 19                	jb     f0100d8a <check_page_free_list+0x146>
f0100d71:	68 fc 73 10 f0       	push   $0xf01073fc
f0100d76:	68 e7 73 10 f0       	push   $0xf01073e7
f0100d7b:	68 59 04 00 00       	push   $0x459
f0100d80:	68 c1 73 10 f0       	push   $0xf01073c1
f0100d85:	e8 0a f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d8a:	89 d0                	mov    %edx,%eax
f0100d8c:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d8f:	a8 07                	test   $0x7,%al
f0100d91:	74 19                	je     f0100dac <check_page_free_list+0x168>
f0100d93:	68 74 6a 10 f0       	push   $0xf0106a74
f0100d98:	68 e7 73 10 f0       	push   $0xf01073e7
f0100d9d:	68 5a 04 00 00       	push   $0x45a
f0100da2:	68 c1 73 10 f0       	push   $0xf01073c1
f0100da7:	e8 e8 f2 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dac:	c1 f8 03             	sar    $0x3,%eax
f0100daf:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		//my code:
		//cprintf("pp:%x,page2pa(pp):%x\n",pp,page2pa(pp));
		//my code end.
		assert(page2pa(pp) != 0);
f0100db2:	85 c0                	test   %eax,%eax
f0100db4:	75 19                	jne    f0100dcf <check_page_free_list+0x18b>
f0100db6:	68 10 74 10 f0       	push   $0xf0107410
f0100dbb:	68 e7 73 10 f0       	push   $0xf01073e7
f0100dc0:	68 60 04 00 00       	push   $0x460
f0100dc5:	68 c1 73 10 f0       	push   $0xf01073c1
f0100dca:	e8 c5 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100dcf:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dd4:	75 19                	jne    f0100def <check_page_free_list+0x1ab>
f0100dd6:	68 21 74 10 f0       	push   $0xf0107421
f0100ddb:	68 e7 73 10 f0       	push   $0xf01073e7
f0100de0:	68 61 04 00 00       	push   $0x461
f0100de5:	68 c1 73 10 f0       	push   $0xf01073c1
f0100dea:	e8 a5 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100def:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100df4:	75 19                	jne    f0100e0f <check_page_free_list+0x1cb>
f0100df6:	68 a8 6a 10 f0       	push   $0xf0106aa8
f0100dfb:	68 e7 73 10 f0       	push   $0xf01073e7
f0100e00:	68 62 04 00 00       	push   $0x462
f0100e05:	68 c1 73 10 f0       	push   $0xf01073c1
f0100e0a:	e8 85 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e0f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e14:	75 19                	jne    f0100e2f <check_page_free_list+0x1eb>
f0100e16:	68 3a 74 10 f0       	push   $0xf010743a
f0100e1b:	68 e7 73 10 f0       	push   $0xf01073e7
f0100e20:	68 63 04 00 00       	push   $0x463
f0100e25:	68 c1 73 10 f0       	push   $0xf01073c1
f0100e2a:	e8 65 f2 ff ff       	call   f0100094 <_panic>
		//cprintf("pp'address:%x,page2kva(pp):%x\n",pp,page2kva(pp));
		//cprintf("first_free_page:%x\n",first_free_page);
		//assert( (char *)page2kva(pp) >= first_free_page );
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e2f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e34:	0f 86 f1 00 00 00    	jbe    f0100f2b <check_page_free_list+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e3a:	89 c7                	mov    %eax,%edi
f0100e3c:	c1 ef 0c             	shr    $0xc,%edi
f0100e3f:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100e42:	77 12                	ja     f0100e56 <check_page_free_list+0x212>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e44:	50                   	push   %eax
f0100e45:	68 48 64 10 f0       	push   $0xf0106448
f0100e4a:	6a 58                	push   $0x58
f0100e4c:	68 cd 73 10 f0       	push   $0xf01073cd
f0100e51:	e8 3e f2 ff ff       	call   f0100094 <_panic>
f0100e56:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e5c:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100e5f:	0f 86 b6 00 00 00    	jbe    f0100f1b <check_page_free_list+0x2d7>
f0100e65:	68 cc 6a 10 f0       	push   $0xf0106acc
f0100e6a:	68 e7 73 10 f0       	push   $0xf01073e7
f0100e6f:	68 67 04 00 00       	push   $0x467
f0100e74:	68 c1 73 10 f0       	push   $0xf01073c1
f0100e79:	e8 16 f2 ff ff       	call   f0100094 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e7e:	68 54 74 10 f0       	push   $0xf0107454
f0100e83:	68 e7 73 10 f0       	push   $0xf01073e7
f0100e88:	68 69 04 00 00       	push   $0x469
f0100e8d:	68 c1 73 10 f0       	push   $0xf01073c1
f0100e92:	e8 fd f1 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e97:	83 c6 01             	add    $0x1,%esi
f0100e9a:	eb 03                	jmp    f0100e9f <check_page_free_list+0x25b>
		else
			++nfree_extmem;
f0100e9c:	83 c3 01             	add    $0x1,%ebx
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e9f:	8b 12                	mov    (%edx),%edx
f0100ea1:	85 d2                	test   %edx,%edx
f0100ea3:	0f 85 a6 fe ff ff    	jne    f0100d4f <check_page_free_list+0x10b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100ea9:	85 f6                	test   %esi,%esi
f0100eab:	7f 19                	jg     f0100ec6 <check_page_free_list+0x282>
f0100ead:	68 71 74 10 f0       	push   $0xf0107471
f0100eb2:	68 e7 73 10 f0       	push   $0xf01073e7
f0100eb7:	68 71 04 00 00       	push   $0x471
f0100ebc:	68 c1 73 10 f0       	push   $0xf01073c1
f0100ec1:	e8 ce f1 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100ec6:	85 db                	test   %ebx,%ebx
f0100ec8:	7f 19                	jg     f0100ee3 <check_page_free_list+0x29f>
f0100eca:	68 83 74 10 f0       	push   $0xf0107483
f0100ecf:	68 e7 73 10 f0       	push   $0xf01073e7
f0100ed4:	68 72 04 00 00       	push   $0x472
f0100ed9:	68 c1 73 10 f0       	push   $0xf01073c1
f0100ede:	e8 b1 f1 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ee3:	83 ec 0c             	sub    $0xc,%esp
f0100ee6:	68 14 6b 10 f0       	push   $0xf0106b14
f0100eeb:	e8 7f 29 00 00       	call   f010386f <cprintf>
}
f0100ef0:	eb 49                	jmp    f0100f3b <check_page_free_list+0x2f7>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ef2:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0100ef7:	85 c0                	test   %eax,%eax
f0100ef9:	0f 85 72 fd ff ff    	jne    f0100c71 <check_page_free_list+0x2d>
f0100eff:	e9 56 fd ff ff       	jmp    f0100c5a <check_page_free_list+0x16>
f0100f04:	83 3d 40 22 21 f0 00 	cmpl   $0x0,0xf0212240
f0100f0b:	0f 84 49 fd ff ff    	je     f0100c5a <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f11:	be 00 04 00 00       	mov    $0x400,%esi
f0100f16:	e9 a4 fd ff ff       	jmp    f0100cbf <check_page_free_list+0x7b>
		//cprintf("pp'address:%x,page2kva(pp):%x\n",pp,page2kva(pp));
		//cprintf("first_free_page:%x\n",first_free_page);
		//assert( (char *)page2kva(pp) >= first_free_page );
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f1b:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100f20:	0f 85 76 ff ff ff    	jne    f0100e9c <check_page_free_list+0x258>
f0100f26:	e9 53 ff ff ff       	jmp    f0100e7e <check_page_free_list+0x23a>
f0100f2b:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100f30:	0f 85 61 ff ff ff    	jne    f0100e97 <check_page_free_list+0x253>
f0100f36:	e9 43 ff ff ff       	jmp    f0100e7e <check_page_free_list+0x23a>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100f3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f3e:	5b                   	pop    %ebx
f0100f3f:	5e                   	pop    %esi
f0100f40:	5f                   	pop    %edi
f0100f41:	5d                   	pop    %ebp
f0100f42:	c3                   	ret    

f0100f43 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100f43:	55                   	push   %ebp
f0100f44:	89 e5                	mov    %esp,%ebp
f0100f46:	56                   	push   %esi
f0100f47:	53                   	push   %ebx
	}
*/

//=======
     size_t i;
     pages[0].pp_ref = 1;
f0100f48:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
f0100f4d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
     pages[0].pp_link = NULL;
f0100f53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
f0100f59:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f5e:	e8 18 fc ff ff       	call   f0100b7b <boot_alloc>
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
     {
         if (( (i >= (IOPHYSMEM / PGSIZE)) && (i < ((nextfree - KERNBASE)/ PGSIZE))) || i == (MPENTRY_PADDR/PGSIZE)) 
f0100f63:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f68:	c1 e8 0c             	shr    $0xc,%eax
f0100f6b:	8b 35 40 22 21 f0    	mov    0xf0212240,%esi
     pages[0].pp_link = NULL;
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
f0100f71:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f76:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f7b:	eb 4f                	jmp    f0100fcc <page_init+0x89>
     {
         if (( (i >= (IOPHYSMEM / PGSIZE)) && (i < ((nextfree - KERNBASE)/ PGSIZE))) || i == (MPENTRY_PADDR/PGSIZE)) 
f0100f7d:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f0100f83:	76 04                	jbe    f0100f89 <page_init+0x46>
f0100f85:	39 c2                	cmp    %eax,%edx
f0100f87:	72 05                	jb     f0100f8e <page_init+0x4b>
f0100f89:	83 fa 07             	cmp    $0x7,%edx
f0100f8c:	75 17                	jne    f0100fa5 <page_init+0x62>
         {
             pages[i].pp_ref = 1;
f0100f8e:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
f0100f94:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f0100f97:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
             pages[i].pp_link = NULL;
f0100f9d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100fa3:	eb 24                	jmp    f0100fc9 <page_init+0x86>
         }
         else 
         {
             pages[i].pp_ref = 0;
f0100fa5:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100fac:	89 cb                	mov    %ecx,%ebx
f0100fae:	03 1d 90 2e 21 f0    	add    0xf0212e90,%ebx
f0100fb4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
             pages[i].pp_link = page_free_list;
f0100fba:	89 33                	mov    %esi,(%ebx)
             page_free_list = &pages[i];
f0100fbc:	89 ce                	mov    %ecx,%esi
f0100fbe:	03 35 90 2e 21 f0    	add    0xf0212e90,%esi
f0100fc4:	bb 01 00 00 00       	mov    $0x1,%ebx
     pages[0].pp_link = NULL;
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
f0100fc9:	83 c2 01             	add    $0x1,%edx
f0100fcc:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0100fd2:	72 a9                	jb     f0100f7d <page_init+0x3a>
f0100fd4:	84 db                	test   %bl,%bl
f0100fd6:	74 06                	je     f0100fde <page_init+0x9b>
f0100fd8:	89 35 40 22 21 f0    	mov    %esi,0xf0212240
             page_free_list = &pages[i];
        }
     }

//>>>>>>> lab3
}
f0100fde:	5b                   	pop    %ebx
f0100fdf:	5e                   	pop    %esi
f0100fe0:	5d                   	pop    %ebp
f0100fe1:	c3                   	ret    

f0100fe2 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100fe2:	55                   	push   %ebp
f0100fe3:	89 e5                	mov    %esp,%ebp
f0100fe5:	53                   	push   %ebx
f0100fe6:	83 ec 04             	sub    $0x4,%esp
f0100fe9:	8b 1d 40 22 21 f0    	mov    0xf0212240,%ebx
	//my code start
	//first check is there any pages left

	//here we delete the page in the page_free_list but used by others.e.g.pp2
//cprintf("$$now we are at the page_alloc() function.$$\n\n");
	while( page_free_list && page_free_list->pp_ref > 0 ){
f0100fef:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff4:	eb 07                	jmp    f0100ffd <page_alloc+0x1b>
		page_free_list = page_free_list->pp_link;
f0100ff6:	8b 1b                	mov    (%ebx),%ebx
f0100ff8:	b8 01 00 00 00       	mov    $0x1,%eax
	//my code start
	//first check is there any pages left

	//here we delete the page in the page_free_list but used by others.e.g.pp2
//cprintf("$$now we are at the page_alloc() function.$$\n\n");
	while( page_free_list && page_free_list->pp_ref > 0 ){
f0100ffd:	85 db                	test   %ebx,%ebx
f0100fff:	75 14                	jne    f0101015 <page_alloc+0x33>
f0101001:	84 c0                	test   %al,%al
f0101003:	0f 84 8b 00 00 00    	je     f0101094 <page_alloc+0xb2>
f0101009:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f0101010:	00 00 00 
f0101013:	eb 7f                	jmp    f0101094 <page_alloc+0xb2>
f0101015:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010101a:	75 da                	jne    f0100ff6 <page_alloc+0x14>
f010101c:	84 c0                	test   %al,%al
f010101e:	74 06                	je     f0101026 <page_alloc+0x44>
f0101020:	89 1d 40 22 21 f0    	mov    %ebx,0xf0212240
//cprintf("#497 alloc_error:we don't consider the condition that only one node left.\n");
//cprintf("page_free_list->pp_ref:0x%x,pp_link:0x%x\n\n\n",page_free_list->pp_ref,page_free_list->pp_link);			
		struct PageInfo * return_PageInfo = NULL;
		return_PageInfo = page_free_list;
		
		if(page_free_list->pp_link == NULL){
f0101026:	8b 03                	mov    (%ebx),%eax
f0101028:	85 c0                	test   %eax,%eax
f010102a:	75 12                	jne    f010103e <page_alloc+0x5c>
			page_free_list = NULL;
f010102c:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f0101033:	00 00 00 
			return_PageInfo->pp_link = NULL;
f0101036:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
f010103c:	eb 0b                	jmp    f0101049 <page_alloc+0x67>
		}else{
			page_free_list = return_PageInfo->pp_link;
f010103e:	a3 40 22 21 f0       	mov    %eax,0xf0212240
			return_PageInfo->pp_link = NULL;	
f0101043:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
		
		if(alloc_flags & ALLOC_ZERO){
f0101049:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010104d:	74 45                	je     f0101094 <page_alloc+0xb2>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010104f:	89 d8                	mov    %ebx,%eax
f0101051:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0101057:	c1 f8 03             	sar    $0x3,%eax
f010105a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010105d:	89 c2                	mov    %eax,%edx
f010105f:	c1 ea 0c             	shr    $0xc,%edx
f0101062:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0101068:	72 12                	jb     f010107c <page_alloc+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010106a:	50                   	push   %eax
f010106b:	68 48 64 10 f0       	push   $0xf0106448
f0101070:	6a 58                	push   $0x58
f0101072:	68 cd 73 10 f0       	push   $0xf01073cd
f0101077:	e8 18 f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(return_PageInfo),'\0',PGSIZE);
f010107c:	83 ec 04             	sub    $0x4,%esp
f010107f:	68 00 10 00 00       	push   $0x1000
f0101084:	6a 00                	push   $0x0
f0101086:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010108b:	50                   	push   %eax
f010108c:	e8 13 46 00 00       	call   f01056a4 <memset>
f0101091:	83 c4 10             	add    $0x10,%esp
//		panic("page_alloc():alloc failed.\n");
		return NULL;
	}
	//my code end.
	return 0;
}
f0101094:	89 d8                	mov    %ebx,%eax
f0101096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101099:	c9                   	leave  
f010109a:	c3                   	ret    

f010109b <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010109b:	55                   	push   %ebp
f010109c:	89 e5                	mov    %esp,%ebp
f010109e:	53                   	push   %ebx
f010109f:	83 ec 04             	sub    $0x4,%esp
f01010a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link != NULL){
f01010a5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01010aa:	75 05                	jne    f01010b1 <page_free+0x16>
f01010ac:	83 3b 00             	cmpl   $0x0,(%ebx)
f01010af:	74 17                	je     f01010c8 <page_free+0x2d>
		
		panic("page_free():page free failed.\n");
f01010b1:	83 ec 04             	sub    $0x4,%esp
f01010b4:	68 38 6b 10 f0       	push   $0xf0106b38
f01010b9:	68 ff 01 00 00       	push   $0x1ff
f01010be:	68 c1 73 10 f0       	push   $0xf01073c1
f01010c3:	e8 cc ef ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010c8:	89 d8                	mov    %ebx,%eax
f01010ca:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f01010d0:	c1 f8 03             	sar    $0x3,%eax
f01010d3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010d6:	89 c2                	mov    %eax,%edx
f01010d8:	c1 ea 0c             	shr    $0xc,%edx
f01010db:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f01010e1:	72 12                	jb     f01010f5 <page_free+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010e3:	50                   	push   %eax
f01010e4:	68 48 64 10 f0       	push   $0xf0106448
f01010e9:	6a 58                	push   $0x58
f01010eb:	68 cd 73 10 f0       	push   $0xf01073cd
f01010f0:	e8 9f ef ff ff       	call   f0100094 <_panic>
//			cprintf("$$in the page_free:page_free_list->pp_ref :%x$$\n\n",page_free_list->pp_ref);	
			
			//here we should do something additional,that is clear 
			//the freed page,set the value to 0;
			
			memset((page2kva(pp)),0x00,PGSIZE);
f01010f5:	83 ec 04             	sub    $0x4,%esp
f01010f8:	68 00 10 00 00       	push   $0x1000
f01010fd:	6a 00                	push   $0x0
f01010ff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101104:	50                   	push   %eax
f0101105:	e8 9a 45 00 00       	call   f01056a4 <memset>
f010110a:	a1 40 22 21 f0       	mov    0xf0212240,%eax
			
			while(page_free_list && page_free_list->pp_ref >0){
f010110f:	83 c4 10             	add    $0x10,%esp
f0101112:	ba 00 00 00 00       	mov    $0x0,%edx
f0101117:	eb 07                	jmp    f0101120 <page_free+0x85>
				page_free_list = page_free_list->pp_link;
f0101119:	8b 00                	mov    (%eax),%eax
f010111b:	ba 01 00 00 00       	mov    $0x1,%edx
			//here we should do something additional,that is clear 
			//the freed page,set the value to 0;
			
			memset((page2kva(pp)),0x00,PGSIZE);
			
			while(page_free_list && page_free_list->pp_ref >0){
f0101120:	85 c0                	test   %eax,%eax
f0101122:	75 10                	jne    f0101134 <page_free+0x99>
f0101124:	84 d2                	test   %dl,%dl
f0101126:	74 1c                	je     f0101144 <page_free+0xa9>
f0101128:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f010112f:	00 00 00 
f0101132:	eb 10                	jmp    f0101144 <page_free+0xa9>
f0101134:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101139:	75 de                	jne    f0101119 <page_free+0x7e>
f010113b:	84 d2                	test   %dl,%dl
f010113d:	74 05                	je     f0101144 <page_free+0xa9>
f010113f:	a3 40 22 21 f0       	mov    %eax,0xf0212240
				page_free_list = page_free_list->pp_link;
			}
			if(pp != page_free_list){
f0101144:	39 c3                	cmp    %eax,%ebx
f0101146:	74 08                	je     f0101150 <page_free+0xb5>
				struct PageInfo * temp_free_page_list = page_free_list;
				page_free_list = pp;
f0101148:	89 1d 40 22 21 f0    	mov    %ebx,0xf0212240
				page_free_list->pp_link = temp_free_page_list;
f010114e:	89 03                	mov    %eax,(%ebx)
			}
		return;

	}
	
}
f0101150:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101153:	c9                   	leave  
f0101154:	c3                   	ret    

f0101155 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101155:	55                   	push   %ebp
f0101156:	89 e5                	mov    %esp,%ebp
f0101158:	83 ec 08             	sub    $0x8,%esp
f010115b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010115e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101162:	83 e8 01             	sub    $0x1,%eax
f0101165:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101169:	66 85 c0             	test   %ax,%ax
f010116c:	75 0c                	jne    f010117a <page_decref+0x25>
		page_free(pp);
f010116e:	83 ec 0c             	sub    $0xc,%esp
f0101171:	52                   	push   %edx
f0101172:	e8 24 ff ff ff       	call   f010109b <page_free>
f0101177:	83 c4 10             	add    $0x10,%esp
}
f010117a:	c9                   	leave  
f010117b:	c3                   	ret    

f010117c <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir,const void *va, int create)
{
f010117c:	55                   	push   %ebp
f010117d:	89 e5                	mov    %esp,%ebp
f010117f:	56                   	push   %esi
f0101180:	53                   	push   %ebx
f0101181:	8b 75 0c             	mov    0xc(%ebp),%esi
	//a new page table table if there is not a page table page exist.

const void* out_va = va;
//if( (uint32_t)out_va&0xf0000000 && !((uint32_t)out_va&0x0ffffff) )
//cprintf("va :%x\n",va);
	if( !(pgdir[PDX(va)] & PTE_P) ){//memset has already set it to zero?
f0101184:	89 f3                	mov    %esi,%ebx
f0101186:	c1 eb 16             	shr    $0x16,%ebx
f0101189:	c1 e3 02             	shl    $0x2,%ebx
f010118c:	03 5d 08             	add    0x8(%ebp),%ebx
f010118f:	f6 03 01             	testb  $0x1,(%ebx)
f0101192:	75 2d                	jne    f01011c1 <pgdir_walk+0x45>
		if(create == 0)
f0101194:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101198:	74 62                	je     f01011fc <pgdir_walk+0x80>
			return NULL;
		else{
			struct PageInfo * return_page = page_alloc(ALLOC_ZERO);
f010119a:	83 ec 0c             	sub    $0xc,%esp
f010119d:	6a 01                	push   $0x1
f010119f:	e8 3e fe ff ff       	call   f0100fe2 <page_alloc>
//cprintf(" we are at the page_allloc to check #497\n");
//cprintf("the mapped va is:%x\n",va);
			//return_page->pp_ref++;
			if(return_page == NULL){//run out of memery
f01011a4:	83 c4 10             	add    $0x10,%esp
f01011a7:	85 c0                	test   %eax,%eax
f01011a9:	74 58                	je     f0101203 <pgdir_walk+0x87>
				return NULL;
			}else{
//				cprintf("#page_walk in the if  else(new alloc)\n");
//				cprintf("#page_walk return_page :%x\n",return_page);
//				cprintf("#page_walk page2pa(return_page):%x\n",page2pa(return_page));
				return_page->pp_ref++;
f01011ab:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				//this line can make the
				//the line assert(ptep == ptep1+PTX(va))
				//pass in the check_page();
				pgdir[PDX(va)] = page2pa(return_page)|PTE_P|PTE_U|PTE_W;	
f01011b0:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f01011b6:	c1 f8 03             	sar    $0x3,%eax
f01011b9:	c1 e0 0c             	shl    $0xc,%eax
f01011bc:	83 c8 07             	or     $0x7,%eax
f01011bf:	89 03                	mov    %eax,(%ebx)
	}else{
		//cprintf("B");
		//cprintf("the page_walk else:0x%x\n",pgdir[PDX(va)]);
		//return (pte_t*)(KADDR(PTE_ADDR(pgdir[PDX(va)])))+PTX(va);
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[PDX(va)]));
f01011c1:	8b 03                	mov    (%ebx),%eax
f01011c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011c8:	89 c2                	mov    %eax,%edx
f01011ca:	c1 ea 0c             	shr    $0xc,%edx
f01011cd:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f01011d3:	72 15                	jb     f01011ea <pgdir_walk+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011d5:	50                   	push   %eax
f01011d6:	68 48 64 10 f0       	push   $0xf0106448
f01011db:	68 7b 02 00 00       	push   $0x27b
f01011e0:	68 c1 73 10 f0       	push   $0xf01073c1
f01011e5:	e8 aa ee ff ff       	call   f0100094 <_panic>
	


	//my code end.

	return p+PTX(va);
f01011ea:	c1 ee 0a             	shr    $0xa,%esi
f01011ed:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01011f3:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01011fa:	eb 0c                	jmp    f0101208 <pgdir_walk+0x8c>
const void* out_va = va;
//if( (uint32_t)out_va&0xf0000000 && !((uint32_t)out_va&0x0ffffff) )
//cprintf("va :%x\n",va);
	if( !(pgdir[PDX(va)] & PTE_P) ){//memset has already set it to zero?
		if(create == 0)
			return NULL;
f01011fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0101201:	eb 05                	jmp    f0101208 <pgdir_walk+0x8c>
//cprintf(" we are at the page_allloc to check #497\n");
//cprintf("the mapped va is:%x\n",va);
			//return_page->pp_ref++;
			if(return_page == NULL){//run out of memery
//cprintf("from the NULL exit.\n\n");
				return NULL;
f0101203:	b8 00 00 00 00       	mov    $0x0,%eax


	//my code end.

	return p+PTX(va);
}
f0101208:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010120b:	5b                   	pop    %ebx
f010120c:	5e                   	pop    %esi
f010120d:	5d                   	pop    %ebp
f010120e:	c3                   	ret    

f010120f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010120f:	55                   	push   %ebp
f0101210:	89 e5                	mov    %esp,%ebp
f0101212:	57                   	push   %edi
f0101213:	56                   	push   %esi
f0101214:	53                   	push   %ebx
f0101215:	83 ec 1c             	sub    $0x1c,%esp
f0101218:	89 c7                	mov    %eax,%edi
//			cprintf("*returned_page_table:%x\n",*returned_page_table);

//		}

		*returned_page_table = ((temp_pa))|perm|PTE_P;
		if(temp_va == va+ROUNDUP(size,PGSIZE)-PGSIZE){
f010121a:	8d 5c 0a ff          	lea    -0x1(%edx,%ecx,1),%ebx
f010121e:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0101224:	25 ff 0f 00 00       	and    $0xfff,%eax
f0101229:	29 c3                	sub    %eax,%ebx
f010122b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
	pde_t * returned_page_table;

	//pgdir_walk(pgdir,va,1);
	uintptr_t temp_va;
	physaddr_t temp_pa;
	for(temp_va = va,temp_pa = pa;temp_va<va+size;temp_va+=PGSIZE,temp_pa+=PGSIZE){
f010122e:	89 d3                	mov    %edx,%ebx
f0101230:	8b 45 08             	mov    0x8(%ebp),%eax
f0101233:	29 d0                	sub    %edx,%eax
f0101235:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101238:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010123b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010123e:	eb 56                	jmp    f0101296 <boot_map_region+0x87>
	/* here we should use a new mapping way because we should finish it in static
		
		//the third version is below.
		
	*/
		returned_page_table = pgdir_walk(pgdir,(void*)temp_va,1);
f0101240:	83 ec 04             	sub    $0x4,%esp
f0101243:	6a 01                	push   $0x1
f0101245:	53                   	push   %ebx
f0101246:	57                   	push   %edi
f0101247:	e8 30 ff ff ff       	call   f010117c <pgdir_walk>
//cprintf("A");
//cprintf("w");
		pgdir[PDX(temp_va)] = PADDR((void*)((uint32_t)(returned_page_table)|perm|PTE_P));
f010124c:	89 da                	mov    %ebx,%edx
f010124e:	c1 ea 16             	shr    $0x16,%edx
f0101251:	8d 34 97             	lea    (%edi,%edx,4),%esi
f0101254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101257:	83 c9 01             	or     $0x1,%ecx
f010125a:	89 c2                	mov    %eax,%edx
f010125c:	09 ca                	or     %ecx,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010125e:	83 c4 10             	add    $0x10,%esp
f0101261:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101267:	77 15                	ja     f010127e <boot_map_region+0x6f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101269:	52                   	push   %edx
f010126a:	68 9c 64 10 f0       	push   $0xf010649c
f010126f:	68 a8 02 00 00       	push   $0x2a8
f0101274:	68 c1 73 10 f0       	push   $0xf01073c1
f0101279:	e8 16 ee ff ff       	call   f0100094 <_panic>
f010127e:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101284:	89 16                	mov    %edx,(%esi)
//			cprintf("returned_page_table:%x\n",returned_page_table);
//			cprintf("*returned_page_table:%x\n",*returned_page_table);

//		}

		*returned_page_table = ((temp_pa))|perm|PTE_P;
f0101286:	0b 4d e4             	or     -0x1c(%ebp),%ecx
f0101289:	89 08                	mov    %ecx,(%eax)
		if(temp_va == va+ROUNDUP(size,PGSIZE)-PGSIZE){
f010128b:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f010128e:	74 13                	je     f01012a3 <boot_map_region+0x94>
	pde_t * returned_page_table;

	//pgdir_walk(pgdir,va,1);
	uintptr_t temp_va;
	physaddr_t temp_pa;
	for(temp_va = va,temp_pa = pa;temp_va<va+size;temp_va+=PGSIZE,temp_pa+=PGSIZE){
f0101290:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101296:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101299:	01 d8                	add    %ebx,%eax
f010129b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010129e:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f01012a1:	72 9d                	jb     f0101240 <boot_map_region+0x31>
//cprintf("for test temp_va:%x temp_pa:%x\n",temp_va,temp_pa);
	}	
	
	//my code end
//cprintf("now we get out of boot_map_region\n\n\n");
}
f01012a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a6:	5b                   	pop    %ebx
f01012a7:	5e                   	pop    %esi
f01012a8:	5f                   	pop    %edi
f01012a9:	5d                   	pop    %ebp
f01012aa:	c3                   	ret    

f01012ab <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01012ab:	55                   	push   %ebp
f01012ac:	89 e5                	mov    %esp,%ebp
f01012ae:	53                   	push   %ebx
f01012af:	83 ec 08             	sub    $0x8,%esp
f01012b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01012b5:	6a 00                	push   $0x0
f01012b7:	ff 75 0c             	pushl  0xc(%ebp)
f01012ba:	ff 75 08             	pushl  0x8(%ebp)
f01012bd:	e8 ba fe ff ff       	call   f010117c <pgdir_walk>
	if(!pte || !(*pte & PTE_P))return NULL;
f01012c2:	83 c4 10             	add    $0x10,%esp
f01012c5:	85 c0                	test   %eax,%eax
f01012c7:	74 37                	je     f0101300 <page_lookup+0x55>
f01012c9:	f6 00 01             	testb  $0x1,(%eax)
f01012cc:	74 39                	je     f0101307 <page_lookup+0x5c>
	if(pte_store)
f01012ce:	85 db                	test   %ebx,%ebx
f01012d0:	74 02                	je     f01012d4 <page_lookup+0x29>
		*pte_store = pte;
f01012d2:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012d4:	8b 00                	mov    (%eax),%eax
f01012d6:	c1 e8 0c             	shr    $0xc,%eax
f01012d9:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f01012df:	72 14                	jb     f01012f5 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01012e1:	83 ec 04             	sub    $0x4,%esp
f01012e4:	68 58 6b 10 f0       	push   $0xf0106b58
f01012e9:	6a 51                	push   $0x51
f01012eb:	68 cd 73 10 f0       	push   $0xf01073cd
f01012f0:	e8 9f ed ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f01012f5:	8b 15 90 2e 21 f0    	mov    0xf0212e90,%edx
f01012fb:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));
f01012fe:	eb 0c                	jmp    f010130c <page_lookup+0x61>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if(!pte || !(*pte & PTE_P))return NULL;
f0101300:	b8 00 00 00 00       	mov    $0x0,%eax
f0101305:	eb 05                	jmp    f010130c <page_lookup+0x61>
f0101307:	b8 00 00 00 00       	mov    $0x0,%eax
		return NULL;
	}
	return NULL;
	*/

}
f010130c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010130f:	c9                   	leave  
f0101310:	c3                   	ret    

f0101311 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101311:	55                   	push   %ebp
f0101312:	89 e5                	mov    %esp,%ebp
f0101314:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101317:	e8 aa 49 00 00       	call   f0105cc6 <cpunum>
f010131c:	6b c0 74             	imul   $0x74,%eax,%eax
f010131f:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0101326:	74 16                	je     f010133e <tlb_invalidate+0x2d>
f0101328:	e8 99 49 00 00       	call   f0105cc6 <cpunum>
f010132d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101330:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0101336:	8b 55 08             	mov    0x8(%ebp),%edx
f0101339:	39 50 60             	cmp    %edx,0x60(%eax)
f010133c:	75 06                	jne    f0101344 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010133e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101341:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101344:	c9                   	leave  
f0101345:	c3                   	ret    

f0101346 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101346:	55                   	push   %ebp
f0101347:	89 e5                	mov    %esp,%ebp
f0101349:	56                   	push   %esi
f010134a:	53                   	push   %ebx
f010134b:	83 ec 14             	sub    $0x14,%esp
f010134e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101351:	8b 75 0c             	mov    0xc(%ebp),%esi
	//address space the TLB will be preload the concerned 
	//page table entrys so we invalidate it first...(maybe)
	//but I still do not know when to use it clearly.
	pde_t * temp_pte;
	struct PageInfo * page_to_free;
	page_to_free = page_lookup(pgdir,va,&temp_pte);
f0101354:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101357:	50                   	push   %eax
f0101358:	56                   	push   %esi
f0101359:	53                   	push   %ebx
f010135a:	e8 4c ff ff ff       	call   f01012ab <page_lookup>
	if(!page_to_free || !(*temp_pte & PTE_P))return;
f010135f:	83 c4 10             	add    $0x10,%esp
f0101362:	85 c0                	test   %eax,%eax
f0101364:	74 27                	je     f010138d <page_remove+0x47>
f0101366:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101369:	f6 02 01             	testb  $0x1,(%edx)
f010136c:	74 1f                	je     f010138d <page_remove+0x47>
	page_decref(page_to_free);
f010136e:	83 ec 0c             	sub    $0xc,%esp
f0101371:	50                   	push   %eax
f0101372:	e8 de fd ff ff       	call   f0101155 <page_decref>
	*temp_pte = 0;
f0101377:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010137a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f0101380:	83 c4 08             	add    $0x8,%esp
f0101383:	56                   	push   %esi
f0101384:	53                   	push   %ebx
f0101385:	e8 87 ff ff ff       	call   f0101311 <tlb_invalidate>
f010138a:	83 c4 10             	add    $0x10,%esp
	}
	tlb_invalidate(pgdir,va);
	return;
	//my code end
*/
}
f010138d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101390:	5b                   	pop    %ebx
f0101391:	5e                   	pop    %esi
f0101392:	5d                   	pop    %ebp
f0101393:	c3                   	ret    

f0101394 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101394:	55                   	push   %ebp
f0101395:	89 e5                	mov    %esp,%ebp
f0101397:	57                   	push   %edi
f0101398:	56                   	push   %esi
f0101399:	53                   	push   %ebx
f010139a:	83 ec 10             	sub    $0x10,%esp
f010139d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013a0:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01013a3:	6a 01                	push   $0x1
f01013a5:	57                   	push   %edi
f01013a6:	ff 75 08             	pushl  0x8(%ebp)
f01013a9:	e8 ce fd ff ff       	call   f010117c <pgdir_walk>
	if(!pte)
f01013ae:	83 c4 10             	add    $0x10,%esp
f01013b1:	85 c0                	test   %eax,%eax
f01013b3:	74 38                	je     f01013ed <page_insert+0x59>
f01013b5:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
	pp->pp_ref++;
f01013b7:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if(*pte & PTE_P)
f01013bc:	f6 00 01             	testb  $0x1,(%eax)
f01013bf:	74 0f                	je     f01013d0 <page_insert+0x3c>
		page_remove(pgdir, va);
f01013c1:	83 ec 08             	sub    $0x8,%esp
f01013c4:	57                   	push   %edi
f01013c5:	ff 75 08             	pushl  0x8(%ebp)
f01013c8:	e8 79 ff ff ff       	call   f0101346 <page_remove>
f01013cd:	83 c4 10             	add    $0x10,%esp
	*pte = page2pa(pp)|perm|PTE_P;
f01013d0:	2b 1d 90 2e 21 f0    	sub    0xf0212e90,%ebx
f01013d6:	c1 fb 03             	sar    $0x3,%ebx
f01013d9:	c1 e3 0c             	shl    $0xc,%ebx
f01013dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01013df:	83 c8 01             	or     $0x1,%eax
f01013e2:	09 c3                	or     %eax,%ebx
f01013e4:	89 1e                	mov    %ebx,(%esi)

	return 0;
f01013e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01013eb:	eb 05                	jmp    f01013f2 <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if(!pte)
		return -E_NO_MEM;
f01013ed:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}else{
//		cprintf("E_NO_MEM%d\n",-E_NO_MEM);
		return -E_NO_MEM;
	}
	*/
}
f01013f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013f5:	5b                   	pop    %ebx
f01013f6:	5e                   	pop    %esi
f01013f7:	5f                   	pop    %edi
f01013f8:	5d                   	pop    %ebp
f01013f9:	c3                   	ret    

f01013fa <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013fa:	55                   	push   %ebp
f01013fb:	89 e5                	mov    %esp,%ebp
f01013fd:	53                   	push   %ebx
f01013fe:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t total_size = ROUNDUP(size,PGSIZE);
f0101401:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101404:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010140a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(MMIOBASE+total_size>MMIOLIM){
f0101410:	8d 83 00 00 80 ef    	lea    -0x10800000(%ebx),%eax
f0101416:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010141b:	76 17                	jbe    f0101434 <mmio_map_region+0x3a>
		panic("panic at mmio_map_region.\n");
f010141d:	83 ec 04             	sub    $0x4,%esp
f0101420:	68 94 74 10 f0       	push   $0xf0107494
f0101425:	68 b5 03 00 00       	push   $0x3b5
f010142a:	68 c1 73 10 f0       	push   $0xf01073c1
f010142f:	e8 60 ec ff ff       	call   f0100094 <_panic>
	}else{
		boot_map_region(kern_pgdir,base,total_size,pa,PTE_W|PTE_PCD|PTE_PWT);
f0101434:	83 ec 08             	sub    $0x8,%esp
f0101437:	6a 1a                	push   $0x1a
f0101439:	ff 75 08             	pushl  0x8(%ebp)
f010143c:	89 d9                	mov    %ebx,%ecx
f010143e:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101444:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101449:	e8 c1 fd ff ff       	call   f010120f <boot_map_region>
	}
	base+=total_size;
f010144e:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101453:	01 c3                	add    %eax,%ebx
f0101455:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void *)base-total_size;
}
f010145b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010145e:	c9                   	leave  
f010145f:	c3                   	ret    

f0101460 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101460:	55                   	push   %ebp
f0101461:	89 e5                	mov    %esp,%ebp
f0101463:	57                   	push   %edi
f0101464:	56                   	push   %esi
f0101465:	53                   	push   %ebx
f0101466:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101469:	b8 15 00 00 00       	mov    $0x15,%eax
f010146e:	e8 44 f7 ff ff       	call   f0100bb7 <nvram_read>
f0101473:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101475:	b8 17 00 00 00       	mov    $0x17,%eax
f010147a:	e8 38 f7 ff ff       	call   f0100bb7 <nvram_read>
f010147f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101481:	b8 34 00 00 00       	mov    $0x34,%eax
f0101486:	e8 2c f7 ff ff       	call   f0100bb7 <nvram_read>
f010148b:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010148e:	85 c0                	test   %eax,%eax
f0101490:	74 07                	je     f0101499 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101492:	05 00 40 00 00       	add    $0x4000,%eax
f0101497:	eb 0b                	jmp    f01014a4 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101499:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010149f:	85 f6                	test   %esi,%esi
f01014a1:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014a4:	89 c2                	mov    %eax,%edx
f01014a6:	c1 ea 02             	shr    $0x2,%edx
f01014a9:	89 15 88 2e 21 f0    	mov    %edx,0xf0212e88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014af:	89 c2                	mov    %eax,%edx
f01014b1:	29 da                	sub    %ebx,%edx
f01014b3:	52                   	push   %edx
f01014b4:	53                   	push   %ebx
f01014b5:	50                   	push   %eax
f01014b6:	68 78 6b 10 f0       	push   $0xf0106b78
f01014bb:	e8 af 23 00 00       	call   f010386f <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014c0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014c5:	e8 b1 f6 ff ff       	call   f0100b7b <boot_alloc>
f01014ca:	a3 8c 2e 21 f0       	mov    %eax,0xf0212e8c
	memset(kern_pgdir, 0, PGSIZE);
f01014cf:	83 c4 0c             	add    $0xc,%esp
f01014d2:	68 00 10 00 00       	push   $0x1000
f01014d7:	6a 00                	push   $0x0
f01014d9:	50                   	push   %eax
f01014da:	e8 c5 41 00 00       	call   f01056a4 <memset>
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014df:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014e4:	83 c4 10             	add    $0x10,%esp
f01014e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014ec:	77 15                	ja     f0101503 <mem_init+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014ee:	50                   	push   %eax
f01014ef:	68 9c 64 10 f0       	push   $0xf010649c
f01014f4:	68 9f 00 00 00       	push   $0x9f
f01014f9:	68 c1 73 10 f0       	push   $0xf01073c1
f01014fe:	e8 91 eb ff ff       	call   f0100094 <_panic>
f0101503:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101509:	83 ca 05             	or     $0x5,%edx
f010150c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pde_t * page_root = (pde_t*)boot_alloc(sizeof(struct PageInfo)*npages); 	
f0101512:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f0101517:	c1 e0 03             	shl    $0x3,%eax
f010151a:	e8 5c f6 ff ff       	call   f0100b7b <boot_alloc>
f010151f:	89 c3                	mov    %eax,%ebx
	memset(page_root, 0, (sizeof(struct PageInfo)*npages));
f0101521:	83 ec 04             	sub    $0x4,%esp
f0101524:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f0101529:	c1 e0 03             	shl    $0x3,%eax
f010152c:	50                   	push   %eax
f010152d:	6a 00                	push   $0x0
f010152f:	53                   	push   %ebx
f0101530:	e8 6f 41 00 00       	call   f01056a4 <memset>

        pages = (struct PageInfo*)page_root;
f0101535:	89 1d 90 2e 21 f0    	mov    %ebx,0xf0212e90

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));	
f010153b:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101540:	e8 36 f6 ff ff       	call   f0100b7b <boot_alloc>
f0101545:	a3 44 22 21 f0       	mov    %eax,0xf0212244
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010154a:	e8 f4 f9 ff ff       	call   f0100f43 <page_init>

	check_page_free_list(1);
f010154f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101554:	e8 eb f6 ff ff       	call   f0100c44 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101559:	83 c4 10             	add    $0x10,%esp
f010155c:	83 3d 90 2e 21 f0 00 	cmpl   $0x0,0xf0212e90
f0101563:	75 17                	jne    f010157c <mem_init+0x11c>
		panic("'pages' is a null pointer!");
f0101565:	83 ec 04             	sub    $0x4,%esp
f0101568:	68 af 74 10 f0       	push   $0xf01074af
f010156d:	68 85 04 00 00       	push   $0x485
f0101572:	68 c1 73 10 f0       	push   $0xf01073c1
f0101577:	e8 18 eb ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010157c:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0101581:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101586:	eb 05                	jmp    f010158d <mem_init+0x12d>
		++nfree;
f0101588:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010158b:	8b 00                	mov    (%eax),%eax
f010158d:	85 c0                	test   %eax,%eax
f010158f:	75 f7                	jne    f0101588 <mem_init+0x128>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101591:	83 ec 0c             	sub    $0xc,%esp
f0101594:	6a 00                	push   $0x0
f0101596:	e8 47 fa ff ff       	call   f0100fe2 <page_alloc>
f010159b:	89 c7                	mov    %eax,%edi
f010159d:	83 c4 10             	add    $0x10,%esp
f01015a0:	85 c0                	test   %eax,%eax
f01015a2:	75 19                	jne    f01015bd <mem_init+0x15d>
f01015a4:	68 ca 74 10 f0       	push   $0xf01074ca
f01015a9:	68 e7 73 10 f0       	push   $0xf01073e7
f01015ae:	68 8d 04 00 00       	push   $0x48d
f01015b3:	68 c1 73 10 f0       	push   $0xf01073c1
f01015b8:	e8 d7 ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01015bd:	83 ec 0c             	sub    $0xc,%esp
f01015c0:	6a 00                	push   $0x0
f01015c2:	e8 1b fa ff ff       	call   f0100fe2 <page_alloc>
f01015c7:	89 c6                	mov    %eax,%esi
f01015c9:	83 c4 10             	add    $0x10,%esp
f01015cc:	85 c0                	test   %eax,%eax
f01015ce:	75 19                	jne    f01015e9 <mem_init+0x189>
f01015d0:	68 e0 74 10 f0       	push   $0xf01074e0
f01015d5:	68 e7 73 10 f0       	push   $0xf01073e7
f01015da:	68 8e 04 00 00       	push   $0x48e
f01015df:	68 c1 73 10 f0       	push   $0xf01073c1
f01015e4:	e8 ab ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015e9:	83 ec 0c             	sub    $0xc,%esp
f01015ec:	6a 00                	push   $0x0
f01015ee:	e8 ef f9 ff ff       	call   f0100fe2 <page_alloc>
f01015f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015f6:	83 c4 10             	add    $0x10,%esp
f01015f9:	85 c0                	test   %eax,%eax
f01015fb:	75 19                	jne    f0101616 <mem_init+0x1b6>
f01015fd:	68 f6 74 10 f0       	push   $0xf01074f6
f0101602:	68 e7 73 10 f0       	push   $0xf01073e7
f0101607:	68 8f 04 00 00       	push   $0x48f
f010160c:	68 c1 73 10 f0       	push   $0xf01073c1
f0101611:	e8 7e ea ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1033.\n");	


	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101616:	39 f7                	cmp    %esi,%edi
f0101618:	75 19                	jne    f0101633 <mem_init+0x1d3>
f010161a:	68 0c 75 10 f0       	push   $0xf010750c
f010161f:	68 e7 73 10 f0       	push   $0xf01073e7
f0101624:	68 95 04 00 00       	push   $0x495
f0101629:	68 c1 73 10 f0       	push   $0xf01073c1
f010162e:	e8 61 ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101633:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101636:	39 c6                	cmp    %eax,%esi
f0101638:	74 04                	je     f010163e <mem_init+0x1de>
f010163a:	39 c7                	cmp    %eax,%edi
f010163c:	75 19                	jne    f0101657 <mem_init+0x1f7>
f010163e:	68 b4 6b 10 f0       	push   $0xf0106bb4
f0101643:	68 e7 73 10 f0       	push   $0xf01073e7
f0101648:	68 96 04 00 00       	push   $0x496
f010164d:	68 c1 73 10 f0       	push   $0xf01073c1
f0101652:	e8 3d ea ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101657:	8b 0d 90 2e 21 f0    	mov    0xf0212e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010165d:	8b 15 88 2e 21 f0    	mov    0xf0212e88,%edx
f0101663:	c1 e2 0c             	shl    $0xc,%edx
f0101666:	89 f8                	mov    %edi,%eax
f0101668:	29 c8                	sub    %ecx,%eax
f010166a:	c1 f8 03             	sar    $0x3,%eax
f010166d:	c1 e0 0c             	shl    $0xc,%eax
f0101670:	39 d0                	cmp    %edx,%eax
f0101672:	72 19                	jb     f010168d <mem_init+0x22d>
f0101674:	68 1e 75 10 f0       	push   $0xf010751e
f0101679:	68 e7 73 10 f0       	push   $0xf01073e7
f010167e:	68 97 04 00 00       	push   $0x497
f0101683:	68 c1 73 10 f0       	push   $0xf01073c1
f0101688:	e8 07 ea ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010168d:	89 f0                	mov    %esi,%eax
f010168f:	29 c8                	sub    %ecx,%eax
f0101691:	c1 f8 03             	sar    $0x3,%eax
f0101694:	c1 e0 0c             	shl    $0xc,%eax
f0101697:	39 c2                	cmp    %eax,%edx
f0101699:	77 19                	ja     f01016b4 <mem_init+0x254>
f010169b:	68 3b 75 10 f0       	push   $0xf010753b
f01016a0:	68 e7 73 10 f0       	push   $0xf01073e7
f01016a5:	68 98 04 00 00       	push   $0x498
f01016aa:	68 c1 73 10 f0       	push   $0xf01073c1
f01016af:	e8 e0 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016b7:	29 c8                	sub    %ecx,%eax
f01016b9:	c1 f8 03             	sar    $0x3,%eax
f01016bc:	c1 e0 0c             	shl    $0xc,%eax
f01016bf:	39 c2                	cmp    %eax,%edx
f01016c1:	77 19                	ja     f01016dc <mem_init+0x27c>
f01016c3:	68 58 75 10 f0       	push   $0xf0107558
f01016c8:	68 e7 73 10 f0       	push   $0xf01073e7
f01016cd:	68 99 04 00 00       	push   $0x499
f01016d2:	68 c1 73 10 f0       	push   $0xf01073c1
f01016d7:	e8 b8 e9 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016dc:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f01016e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016e4:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f01016eb:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016ee:	83 ec 0c             	sub    $0xc,%esp
f01016f1:	6a 00                	push   $0x0
f01016f3:	e8 ea f8 ff ff       	call   f0100fe2 <page_alloc>
f01016f8:	83 c4 10             	add    $0x10,%esp
f01016fb:	85 c0                	test   %eax,%eax
f01016fd:	74 19                	je     f0101718 <mem_init+0x2b8>
f01016ff:	68 75 75 10 f0       	push   $0xf0107575
f0101704:	68 e7 73 10 f0       	push   $0xf01073e7
f0101709:	68 a0 04 00 00       	push   $0x4a0
f010170e:	68 c1 73 10 f0       	push   $0xf01073c1
f0101713:	e8 7c e9 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1050.\n");	


	// free and re-allocate?
	page_free(pp0);
f0101718:	83 ec 0c             	sub    $0xc,%esp
f010171b:	57                   	push   %edi
f010171c:	e8 7a f9 ff ff       	call   f010109b <page_free>
	page_free(pp1);
f0101721:	89 34 24             	mov    %esi,(%esp)
f0101724:	e8 72 f9 ff ff       	call   f010109b <page_free>
	page_free(pp2);
f0101729:	83 c4 04             	add    $0x4,%esp
f010172c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010172f:	e8 67 f9 ff ff       	call   f010109b <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101734:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010173b:	e8 a2 f8 ff ff       	call   f0100fe2 <page_alloc>
f0101740:	89 c6                	mov    %eax,%esi
f0101742:	83 c4 10             	add    $0x10,%esp
f0101745:	85 c0                	test   %eax,%eax
f0101747:	75 19                	jne    f0101762 <mem_init+0x302>
f0101749:	68 ca 74 10 f0       	push   $0xf01074ca
f010174e:	68 e7 73 10 f0       	push   $0xf01073e7
f0101753:	68 aa 04 00 00       	push   $0x4aa
f0101758:	68 c1 73 10 f0       	push   $0xf01073c1
f010175d:	e8 32 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101762:	83 ec 0c             	sub    $0xc,%esp
f0101765:	6a 00                	push   $0x0
f0101767:	e8 76 f8 ff ff       	call   f0100fe2 <page_alloc>
f010176c:	89 c7                	mov    %eax,%edi
f010176e:	83 c4 10             	add    $0x10,%esp
f0101771:	85 c0                	test   %eax,%eax
f0101773:	75 19                	jne    f010178e <mem_init+0x32e>
f0101775:	68 e0 74 10 f0       	push   $0xf01074e0
f010177a:	68 e7 73 10 f0       	push   $0xf01073e7
f010177f:	68 ab 04 00 00       	push   $0x4ab
f0101784:	68 c1 73 10 f0       	push   $0xf01073c1
f0101789:	e8 06 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010178e:	83 ec 0c             	sub    $0xc,%esp
f0101791:	6a 00                	push   $0x0
f0101793:	e8 4a f8 ff ff       	call   f0100fe2 <page_alloc>
f0101798:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010179b:	83 c4 10             	add    $0x10,%esp
f010179e:	85 c0                	test   %eax,%eax
f01017a0:	75 19                	jne    f01017bb <mem_init+0x35b>
f01017a2:	68 f6 74 10 f0       	push   $0xf01074f6
f01017a7:	68 e7 73 10 f0       	push   $0xf01073e7
f01017ac:	68 ac 04 00 00       	push   $0x4ac
f01017b1:	68 c1 73 10 f0       	push   $0xf01073c1
f01017b6:	e8 d9 e8 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017bb:	39 fe                	cmp    %edi,%esi
f01017bd:	75 19                	jne    f01017d8 <mem_init+0x378>
f01017bf:	68 0c 75 10 f0       	push   $0xf010750c
f01017c4:	68 e7 73 10 f0       	push   $0xf01073e7
f01017c9:	68 ae 04 00 00       	push   $0x4ae
f01017ce:	68 c1 73 10 f0       	push   $0xf01073c1
f01017d3:	e8 bc e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017db:	39 c7                	cmp    %eax,%edi
f01017dd:	74 04                	je     f01017e3 <mem_init+0x383>
f01017df:	39 c6                	cmp    %eax,%esi
f01017e1:	75 19                	jne    f01017fc <mem_init+0x39c>
f01017e3:	68 b4 6b 10 f0       	push   $0xf0106bb4
f01017e8:	68 e7 73 10 f0       	push   $0xf01073e7
f01017ed:	68 af 04 00 00       	push   $0x4af
f01017f2:	68 c1 73 10 f0       	push   $0xf01073c1
f01017f7:	e8 98 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017fc:	83 ec 0c             	sub    $0xc,%esp
f01017ff:	6a 00                	push   $0x0
f0101801:	e8 dc f7 ff ff       	call   f0100fe2 <page_alloc>
f0101806:	83 c4 10             	add    $0x10,%esp
f0101809:	85 c0                	test   %eax,%eax
f010180b:	74 19                	je     f0101826 <mem_init+0x3c6>
f010180d:	68 75 75 10 f0       	push   $0xf0107575
f0101812:	68 e7 73 10 f0       	push   $0xf01073e7
f0101817:	68 b0 04 00 00       	push   $0x4b0
f010181c:	68 c1 73 10 f0       	push   $0xf01073c1
f0101821:	e8 6e e8 ff ff       	call   f0100094 <_panic>
f0101826:	89 f0                	mov    %esi,%eax
f0101828:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010182e:	c1 f8 03             	sar    $0x3,%eax
f0101831:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101834:	89 c2                	mov    %eax,%edx
f0101836:	c1 ea 0c             	shr    $0xc,%edx
f0101839:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f010183f:	72 12                	jb     f0101853 <mem_init+0x3f3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101841:	50                   	push   %eax
f0101842:	68 48 64 10 f0       	push   $0xf0106448
f0101847:	6a 58                	push   $0x58
f0101849:	68 cd 73 10 f0       	push   $0xf01073cd
f010184e:	e8 41 e8 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1066.\n");	


	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101853:	83 ec 04             	sub    $0x4,%esp
f0101856:	68 00 10 00 00       	push   $0x1000
f010185b:	6a 01                	push   $0x1
f010185d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101862:	50                   	push   %eax
f0101863:	e8 3c 3e 00 00       	call   f01056a4 <memset>
	page_free(pp0);
f0101868:	89 34 24             	mov    %esi,(%esp)
f010186b:	e8 2b f8 ff ff       	call   f010109b <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101870:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101877:	e8 66 f7 ff ff       	call   f0100fe2 <page_alloc>
f010187c:	83 c4 10             	add    $0x10,%esp
f010187f:	85 c0                	test   %eax,%eax
f0101881:	75 19                	jne    f010189c <mem_init+0x43c>
f0101883:	68 84 75 10 f0       	push   $0xf0107584
f0101888:	68 e7 73 10 f0       	push   $0xf01073e7
f010188d:	68 b8 04 00 00       	push   $0x4b8
f0101892:	68 c1 73 10 f0       	push   $0xf01073c1
f0101897:	e8 f8 e7 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010189c:	39 c6                	cmp    %eax,%esi
f010189e:	74 19                	je     f01018b9 <mem_init+0x459>
f01018a0:	68 a2 75 10 f0       	push   $0xf01075a2
f01018a5:	68 e7 73 10 f0       	push   $0xf01073e7
f01018aa:	68 b9 04 00 00       	push   $0x4b9
f01018af:	68 c1 73 10 f0       	push   $0xf01073c1
f01018b4:	e8 db e7 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b9:	89 f0                	mov    %esi,%eax
f01018bb:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f01018c1:	c1 f8 03             	sar    $0x3,%eax
f01018c4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018c7:	89 c2                	mov    %eax,%edx
f01018c9:	c1 ea 0c             	shr    $0xc,%edx
f01018cc:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f01018d2:	72 12                	jb     f01018e6 <mem_init+0x486>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d4:	50                   	push   %eax
f01018d5:	68 48 64 10 f0       	push   $0xf0106448
f01018da:	6a 58                	push   $0x58
f01018dc:	68 cd 73 10 f0       	push   $0xf01073cd
f01018e1:	e8 ae e7 ff ff       	call   f0100094 <_panic>
f01018e6:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018ec:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018f2:	80 38 00             	cmpb   $0x0,(%eax)
f01018f5:	74 19                	je     f0101910 <mem_init+0x4b0>
f01018f7:	68 b2 75 10 f0       	push   $0xf01075b2
f01018fc:	68 e7 73 10 f0       	push   $0xf01073e7
f0101901:	68 bc 04 00 00       	push   $0x4bc
f0101906:	68 c1 73 10 f0       	push   $0xf01073c1
f010190b:	e8 84 e7 ff ff       	call   f0100094 <_panic>
f0101910:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101913:	39 d0                	cmp    %edx,%eax
f0101915:	75 db                	jne    f01018f2 <mem_init+0x492>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101917:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010191a:	a3 40 22 21 f0       	mov    %eax,0xf0212240

	// free the pages we took
	page_free(pp0);
f010191f:	83 ec 0c             	sub    $0xc,%esp
f0101922:	56                   	push   %esi
f0101923:	e8 73 f7 ff ff       	call   f010109b <page_free>
	page_free(pp1);
f0101928:	89 3c 24             	mov    %edi,(%esp)
f010192b:	e8 6b f7 ff ff       	call   f010109b <page_free>
	page_free(pp2);
f0101930:	83 c4 04             	add    $0x4,%esp
f0101933:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101936:	e8 60 f7 ff ff       	call   f010109b <page_free>
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010193b:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0101940:	83 c4 10             	add    $0x10,%esp
f0101943:	eb 05                	jmp    f010194a <mem_init+0x4ea>
		--nfree;
f0101945:	83 eb 01             	sub    $0x1,%ebx
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101948:	8b 00                	mov    (%eax),%eax
f010194a:	85 c0                	test   %eax,%eax
f010194c:	75 f7                	jne    f0101945 <mem_init+0x4e5>
		--nfree;
	assert(nfree == 0);
f010194e:	85 db                	test   %ebx,%ebx
f0101950:	74 19                	je     f010196b <mem_init+0x50b>
f0101952:	68 bc 75 10 f0       	push   $0xf01075bc
f0101957:	68 e7 73 10 f0       	push   $0xf01073e7
f010195c:	68 cc 04 00 00       	push   $0x4cc
f0101961:	68 c1 73 10 f0       	push   $0xf01073c1
f0101966:	e8 29 e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010196b:	83 ec 0c             	sub    $0xc,%esp
f010196e:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0101973:	e8 f7 1e 00 00       	call   f010386f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101978:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010197f:	e8 5e f6 ff ff       	call   f0100fe2 <page_alloc>
f0101984:	89 c6                	mov    %eax,%esi
f0101986:	83 c4 10             	add    $0x10,%esp
f0101989:	85 c0                	test   %eax,%eax
f010198b:	75 19                	jne    f01019a6 <mem_init+0x546>
f010198d:	68 ca 74 10 f0       	push   $0xf01074ca
f0101992:	68 e7 73 10 f0       	push   $0xf01073e7
f0101997:	68 46 05 00 00       	push   $0x546
f010199c:	68 c1 73 10 f0       	push   $0xf01073c1
f01019a1:	e8 ee e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01019a6:	83 ec 0c             	sub    $0xc,%esp
f01019a9:	6a 00                	push   $0x0
f01019ab:	e8 32 f6 ff ff       	call   f0100fe2 <page_alloc>
f01019b0:	89 c3                	mov    %eax,%ebx
f01019b2:	83 c4 10             	add    $0x10,%esp
f01019b5:	85 c0                	test   %eax,%eax
f01019b7:	75 19                	jne    f01019d2 <mem_init+0x572>
f01019b9:	68 e0 74 10 f0       	push   $0xf01074e0
f01019be:	68 e7 73 10 f0       	push   $0xf01073e7
f01019c3:	68 47 05 00 00       	push   $0x547
f01019c8:	68 c1 73 10 f0       	push   $0xf01073c1
f01019cd:	e8 c2 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01019d2:	83 ec 0c             	sub    $0xc,%esp
f01019d5:	6a 00                	push   $0x0
f01019d7:	e8 06 f6 ff ff       	call   f0100fe2 <page_alloc>
f01019dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019df:	83 c4 10             	add    $0x10,%esp
f01019e2:	85 c0                	test   %eax,%eax
f01019e4:	75 19                	jne    f01019ff <mem_init+0x59f>
f01019e6:	68 f6 74 10 f0       	push   $0xf01074f6
f01019eb:	68 e7 73 10 f0       	push   $0xf01073e7
f01019f0:	68 48 05 00 00       	push   $0x548
f01019f5:	68 c1 73 10 f0       	push   $0xf01073c1
f01019fa:	e8 95 e6 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019ff:	39 de                	cmp    %ebx,%esi
f0101a01:	75 19                	jne    f0101a1c <mem_init+0x5bc>
f0101a03:	68 0c 75 10 f0       	push   $0xf010750c
f0101a08:	68 e7 73 10 f0       	push   $0xf01073e7
f0101a0d:	68 4b 05 00 00       	push   $0x54b
f0101a12:	68 c1 73 10 f0       	push   $0xf01073c1
f0101a17:	e8 78 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a1f:	39 c6                	cmp    %eax,%esi
f0101a21:	74 04                	je     f0101a27 <mem_init+0x5c7>
f0101a23:	39 c3                	cmp    %eax,%ebx
f0101a25:	75 19                	jne    f0101a40 <mem_init+0x5e0>
f0101a27:	68 b4 6b 10 f0       	push   $0xf0106bb4
f0101a2c:	68 e7 73 10 f0       	push   $0xf01073e7
f0101a31:	68 4c 05 00 00       	push   $0x54c
f0101a36:	68 c1 73 10 f0       	push   $0xf01073c1
f0101a3b:	e8 54 e6 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a40:	a1 40 22 21 f0       	mov    0xf0212240,%eax
f0101a45:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a48:	c7 05 40 22 21 f0 00 	movl   $0x0,0xf0212240
f0101a4f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a52:	83 ec 0c             	sub    $0xc,%esp
f0101a55:	6a 00                	push   $0x0
f0101a57:	e8 86 f5 ff ff       	call   f0100fe2 <page_alloc>
f0101a5c:	83 c4 10             	add    $0x10,%esp
f0101a5f:	85 c0                	test   %eax,%eax
f0101a61:	74 19                	je     f0101a7c <mem_init+0x61c>
f0101a63:	68 75 75 10 f0       	push   $0xf0107575
f0101a68:	68 e7 73 10 f0       	push   $0xf01073e7
f0101a6d:	68 53 05 00 00       	push   $0x553
f0101a72:	68 c1 73 10 f0       	push   $0xf01073c1
f0101a77:	e8 18 e6 ff ff       	call   f0100094 <_panic>
//cprintf("the page_free_list:%d\n",page_free_list);

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a7c:	83 ec 04             	sub    $0x4,%esp
f0101a7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a82:	50                   	push   %eax
f0101a83:	6a 00                	push   $0x0
f0101a85:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101a8b:	e8 1b f8 ff ff       	call   f01012ab <page_lookup>
f0101a90:	83 c4 10             	add    $0x10,%esp
f0101a93:	85 c0                	test   %eax,%eax
f0101a95:	74 19                	je     f0101ab0 <mem_init+0x650>
f0101a97:	68 f4 6b 10 f0       	push   $0xf0106bf4
f0101a9c:	68 e7 73 10 f0       	push   $0xf01073e7
f0101aa1:	68 57 05 00 00       	push   $0x557
f0101aa6:	68 c1 73 10 f0       	push   $0xf01073c1
f0101aab:	e8 e4 e5 ff ff       	call   f0100094 <_panic>
	
//cprintf("#    the page_free_list:%d\n",page_free_list);

	// there is no free memory, so we can't allocate a page table
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ab0:	6a 02                	push   $0x2
f0101ab2:	6a 00                	push   $0x0
f0101ab4:	53                   	push   %ebx
f0101ab5:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101abb:	e8 d4 f8 ff ff       	call   f0101394 <page_insert>
f0101ac0:	83 c4 10             	add    $0x10,%esp
f0101ac3:	85 c0                	test   %eax,%eax
f0101ac5:	78 19                	js     f0101ae0 <mem_init+0x680>
f0101ac7:	68 2c 6c 10 f0       	push   $0xf0106c2c
f0101acc:	68 e7 73 10 f0       	push   $0xf01073e7
f0101ad1:	68 5f 05 00 00       	push   $0x55f
f0101ad6:	68 c1 73 10 f0       	push   $0xf01073c1
f0101adb:	e8 b4 e5 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
//cprintf("##     the page_free_list:%d\n",page_free_list);
//cprintf("$$ at before the page_free(pp0)\n\n");
	page_free(pp0);
f0101ae0:	83 ec 0c             	sub    $0xc,%esp
f0101ae3:	56                   	push   %esi
f0101ae4:	e8 b2 f5 ff ff       	call   f010109b <page_free>
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ae9:	6a 02                	push   $0x2
f0101aeb:	6a 00                	push   $0x0
f0101aed:	53                   	push   %ebx
f0101aee:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101af4:	e8 9b f8 ff ff       	call   f0101394 <page_insert>
f0101af9:	83 c4 20             	add    $0x20,%esp
f0101afc:	85 c0                	test   %eax,%eax
f0101afe:	74 19                	je     f0101b19 <mem_init+0x6b9>
f0101b00:	68 5c 6c 10 f0       	push   $0xf0106c5c
f0101b05:	68 e7 73 10 f0       	push   $0xf01073e7
f0101b0a:	68 66 05 00 00       	push   $0x566
f0101b0f:	68 c1 73 10 f0       	push   $0xf01073c1
f0101b14:	e8 7b e5 ff ff       	call   f0100094 <_panic>

//cprintf("## %x  %x\n",PTE_ADDR(kern_pgdir[0]),page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b19:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b1f:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
f0101b24:	89 c1                	mov    %eax,%ecx
f0101b26:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b29:	8b 17                	mov    (%edi),%edx
f0101b2b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b31:	89 f0                	mov    %esi,%eax
f0101b33:	29 c8                	sub    %ecx,%eax
f0101b35:	c1 f8 03             	sar    $0x3,%eax
f0101b38:	c1 e0 0c             	shl    $0xc,%eax
f0101b3b:	39 c2                	cmp    %eax,%edx
f0101b3d:	74 19                	je     f0101b58 <mem_init+0x6f8>
f0101b3f:	68 8c 6c 10 f0       	push   $0xf0106c8c
f0101b44:	68 e7 73 10 f0       	push   $0xf01073e7
f0101b49:	68 69 05 00 00       	push   $0x569
f0101b4e:	68 c1 73 10 f0       	push   $0xf01073c1
f0101b53:	e8 3c e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b58:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b5d:	89 f8                	mov    %edi,%eax
f0101b5f:	e8 7c f0 ff ff       	call   f0100be0 <check_va2pa>
f0101b64:	89 da                	mov    %ebx,%edx
f0101b66:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b69:	c1 fa 03             	sar    $0x3,%edx
f0101b6c:	c1 e2 0c             	shl    $0xc,%edx
f0101b6f:	39 d0                	cmp    %edx,%eax
f0101b71:	74 19                	je     f0101b8c <mem_init+0x72c>
f0101b73:	68 b4 6c 10 f0       	push   $0xf0106cb4
f0101b78:	68 e7 73 10 f0       	push   $0xf01073e7
f0101b7d:	68 6a 05 00 00       	push   $0x56a
f0101b82:	68 c1 73 10 f0       	push   $0xf01073c1
f0101b87:	e8 08 e5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101b8c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b91:	74 19                	je     f0101bac <mem_init+0x74c>
f0101b93:	68 c7 75 10 f0       	push   $0xf01075c7
f0101b98:	68 e7 73 10 f0       	push   $0xf01073e7
f0101b9d:	68 6b 05 00 00       	push   $0x56b
f0101ba2:	68 c1 73 10 f0       	push   $0xf01073c1
f0101ba7:	e8 e8 e4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101bac:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bb1:	74 19                	je     f0101bcc <mem_init+0x76c>
f0101bb3:	68 d8 75 10 f0       	push   $0xf01075d8
f0101bb8:	68 e7 73 10 f0       	push   $0xf01073e7
f0101bbd:	68 6c 05 00 00       	push   $0x56c
f0101bc2:	68 c1 73 10 f0       	push   $0xf01073c1
f0101bc7:	e8 c8 e4 ff ff       	call   f0100094 <_panic>
//cprintf("###  before page_insert pp2  the page_free_list:%d\n",page_free_list);

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
//cprintf("$$ at before the page_insert pp2 at PGSIZE\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bcc:	6a 02                	push   $0x2
f0101bce:	68 00 10 00 00       	push   $0x1000
f0101bd3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bd6:	57                   	push   %edi
f0101bd7:	e8 b8 f7 ff ff       	call   f0101394 <page_insert>
f0101bdc:	83 c4 10             	add    $0x10,%esp
f0101bdf:	85 c0                	test   %eax,%eax
f0101be1:	74 19                	je     f0101bfc <mem_init+0x79c>
f0101be3:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0101be8:	68 e7 73 10 f0       	push   $0xf01073e7
f0101bed:	68 71 05 00 00       	push   $0x571
f0101bf2:	68 c1 73 10 f0       	push   $0xf01073c1
f0101bf7:	e8 98 e4 ff ff       	call   f0100094 <_panic>
//cprintf("#### here we get over the page_insert page_free_list:%x.\n",page_free_list);
//cprintf("pp0:%x\npp1:%x\npp2:%x\n",pp0,pp1,pp2);	
//cprintf("!! the check_va2pa is %d,page2pa(pp1) %x\n",check_va2pa(kern_pgdir,PGSIZE),page2pa(pp2));


	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bfc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c01:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101c06:	e8 d5 ef ff ff       	call   f0100be0 <check_va2pa>
f0101c0b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c0e:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101c14:	c1 fa 03             	sar    $0x3,%edx
f0101c17:	c1 e2 0c             	shl    $0xc,%edx
f0101c1a:	39 d0                	cmp    %edx,%eax
f0101c1c:	74 19                	je     f0101c37 <mem_init+0x7d7>
f0101c1e:	68 20 6d 10 f0       	push   $0xf0106d20
f0101c23:	68 e7 73 10 f0       	push   $0xf01073e7
f0101c28:	68 77 05 00 00       	push   $0x577
f0101c2d:	68 c1 73 10 f0       	push   $0xf01073c1
f0101c32:	e8 5d e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101c37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c3a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c3f:	74 19                	je     f0101c5a <mem_init+0x7fa>
f0101c41:	68 e9 75 10 f0       	push   $0xf01075e9
f0101c46:	68 e7 73 10 f0       	push   $0xf01073e7
f0101c4b:	68 78 05 00 00       	push   $0x578
f0101c50:	68 c1 73 10 f0       	push   $0xf01073c1
f0101c55:	e8 3a e4 ff ff       	call   f0100094 <_panic>

	// should be no free memory
//cprintf("##### before_page_alloc:  the page_free_list:%d\n",page_free_list);
	assert(!page_alloc(0));
f0101c5a:	83 ec 0c             	sub    $0xc,%esp
f0101c5d:	6a 00                	push   $0x0
f0101c5f:	e8 7e f3 ff ff       	call   f0100fe2 <page_alloc>
f0101c64:	83 c4 10             	add    $0x10,%esp
f0101c67:	85 c0                	test   %eax,%eax
f0101c69:	74 19                	je     f0101c84 <mem_init+0x824>
f0101c6b:	68 75 75 10 f0       	push   $0xf0107575
f0101c70:	68 e7 73 10 f0       	push   $0xf01073e7
f0101c75:	68 7c 05 00 00       	push   $0x57c
f0101c7a:	68 c1 73 10 f0       	push   $0xf01073c1
f0101c7f:	e8 10 e4 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
//cprintf("$$ at twice before the page_insert pp2 at PGSIZE.\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c84:	6a 02                	push   $0x2
f0101c86:	68 00 10 00 00       	push   $0x1000
f0101c8b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c8e:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101c94:	e8 fb f6 ff ff       	call   f0101394 <page_insert>
f0101c99:	83 c4 10             	add    $0x10,%esp
f0101c9c:	85 c0                	test   %eax,%eax
f0101c9e:	74 19                	je     f0101cb9 <mem_init+0x859>
f0101ca0:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0101ca5:	68 e7 73 10 f0       	push   $0xf01073e7
f0101caa:	68 80 05 00 00       	push   $0x580
f0101caf:	68 c1 73 10 f0       	push   $0xf01073c1
f0101cb4:	e8 db e3 ff ff       	call   f0100094 <_panic>
//	for(struct PageInfo *temp_pp = page_free_list;temp_pp;temp_pp = temp_pp->pp_link){
//		cprintf("the temp_pp:%x\n",temp_pp);
//	}
	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cb9:	83 ec 0c             	sub    $0xc,%esp
f0101cbc:	6a 00                	push   $0x0
f0101cbe:	e8 1f f3 ff ff       	call   f0100fe2 <page_alloc>
f0101cc3:	83 c4 10             	add    $0x10,%esp
f0101cc6:	85 c0                	test   %eax,%eax
f0101cc8:	74 19                	je     f0101ce3 <mem_init+0x883>
f0101cca:	68 75 75 10 f0       	push   $0xf0107575
f0101ccf:	68 e7 73 10 f0       	push   $0xf01073e7
f0101cd4:	68 8c 05 00 00       	push   $0x58c
f0101cd9:	68 c1 73 10 f0       	push   $0xf01073c1
f0101cde:	e8 b1 e3 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ce3:	8b 15 8c 2e 21 f0    	mov    0xf0212e8c,%edx
f0101ce9:	8b 02                	mov    (%edx),%eax
f0101ceb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cf0:	89 c1                	mov    %eax,%ecx
f0101cf2:	c1 e9 0c             	shr    $0xc,%ecx
f0101cf5:	3b 0d 88 2e 21 f0    	cmp    0xf0212e88,%ecx
f0101cfb:	72 15                	jb     f0101d12 <mem_init+0x8b2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cfd:	50                   	push   %eax
f0101cfe:	68 48 64 10 f0       	push   $0xf0106448
f0101d03:	68 8f 05 00 00       	push   $0x58f
f0101d08:	68 c1 73 10 f0       	push   $0xf01073c1
f0101d0d:	e8 82 e3 ff ff       	call   f0100094 <_panic>
f0101d12:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
//cprintf("the pgdir_walk(kern_pgdir,(void*)PGSIZE,0):%x\n",pgdir_walk(kern_pgdir,(void*)PGSIZE,0));
//cprintf("ptep+PTX(PGSIZE):%x\n",ptep+PTX(PGSIZE));
//cprintf("ptep:%x\n",ptep);
//cprintf("PTX(PGSIZE):%x\n",PTX(PGSIZE));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d1a:	83 ec 04             	sub    $0x4,%esp
f0101d1d:	6a 00                	push   $0x0
f0101d1f:	68 00 10 00 00       	push   $0x1000
f0101d24:	52                   	push   %edx
f0101d25:	e8 52 f4 ff ff       	call   f010117c <pgdir_walk>
f0101d2a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d2d:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d30:	83 c4 10             	add    $0x10,%esp
f0101d33:	39 d0                	cmp    %edx,%eax
f0101d35:	74 19                	je     f0101d50 <mem_init+0x8f0>
f0101d37:	68 50 6d 10 f0       	push   $0xf0106d50
f0101d3c:	68 e7 73 10 f0       	push   $0xf01073e7
f0101d41:	68 94 05 00 00       	push   $0x594
f0101d46:	68 c1 73 10 f0       	push   $0xf01073c1
f0101d4b:	e8 44 e3 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 3th page_insert pp2 to PGSIZE with changing the permissions.\n\n");
	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d50:	6a 06                	push   $0x6
f0101d52:	68 00 10 00 00       	push   $0x1000
f0101d57:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d5a:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101d60:	e8 2f f6 ff ff       	call   f0101394 <page_insert>
f0101d65:	83 c4 10             	add    $0x10,%esp
f0101d68:	85 c0                	test   %eax,%eax
f0101d6a:	74 19                	je     f0101d85 <mem_init+0x925>
f0101d6c:	68 90 6d 10 f0       	push   $0xf0106d90
f0101d71:	68 e7 73 10 f0       	push   $0xf01073e7
f0101d76:	68 97 05 00 00       	push   $0x597
f0101d7b:	68 c1 73 10 f0       	push   $0xf01073c1
f0101d80:	e8 0f e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d85:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0101d8b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d90:	89 f8                	mov    %edi,%eax
f0101d92:	e8 49 ee ff ff       	call   f0100be0 <check_va2pa>
f0101d97:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d9a:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f0101da0:	c1 fa 03             	sar    $0x3,%edx
f0101da3:	c1 e2 0c             	shl    $0xc,%edx
f0101da6:	39 d0                	cmp    %edx,%eax
f0101da8:	74 19                	je     f0101dc3 <mem_init+0x963>
f0101daa:	68 20 6d 10 f0       	push   $0xf0106d20
f0101daf:	68 e7 73 10 f0       	push   $0xf01073e7
f0101db4:	68 98 05 00 00       	push   $0x598
f0101db9:	68 c1 73 10 f0       	push   $0xf01073c1
f0101dbe:	e8 d1 e2 ff ff       	call   f0100094 <_panic>
//	cprintf("the final pp2->pp_ref:%x\n",pp2->pp_ref);
	assert(pp2->pp_ref == 1);
f0101dc3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dcb:	74 19                	je     f0101de6 <mem_init+0x986>
f0101dcd:	68 e9 75 10 f0       	push   $0xf01075e9
f0101dd2:	68 e7 73 10 f0       	push   $0xf01073e7
f0101dd7:	68 9a 05 00 00       	push   $0x59a
f0101ddc:	68 c1 73 10 f0       	push   $0xf01073c1
f0101de1:	e8 ae e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101de6:	83 ec 04             	sub    $0x4,%esp
f0101de9:	6a 00                	push   $0x0
f0101deb:	68 00 10 00 00       	push   $0x1000
f0101df0:	57                   	push   %edi
f0101df1:	e8 86 f3 ff ff       	call   f010117c <pgdir_walk>
f0101df6:	83 c4 10             	add    $0x10,%esp
f0101df9:	f6 00 04             	testb  $0x4,(%eax)
f0101dfc:	75 19                	jne    f0101e17 <mem_init+0x9b7>
f0101dfe:	68 d0 6d 10 f0       	push   $0xf0106dd0
f0101e03:	68 e7 73 10 f0       	push   $0xf01073e7
f0101e08:	68 9b 05 00 00       	push   $0x59b
f0101e0d:	68 c1 73 10 f0       	push   $0xf01073c1
f0101e12:	e8 7d e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e17:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0101e1c:	f6 00 04             	testb  $0x4,(%eax)
f0101e1f:	75 19                	jne    f0101e3a <mem_init+0x9da>
f0101e21:	68 fa 75 10 f0       	push   $0xf01075fa
f0101e26:	68 e7 73 10 f0       	push   $0xf01073e7
f0101e2b:	68 9c 05 00 00       	push   $0x59c
f0101e30:	68 c1 73 10 f0       	push   $0xf01073c1
f0101e35:	e8 5a e2 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 4th the new line page_insert pp2 PGSIZE with fewer permissions\n\n");
	// should be able to remap with fewer permissions ??
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e3a:	6a 02                	push   $0x2
f0101e3c:	68 00 10 00 00       	push   $0x1000
f0101e41:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e44:	50                   	push   %eax
f0101e45:	e8 4a f5 ff ff       	call   f0101394 <page_insert>
f0101e4a:	83 c4 10             	add    $0x10,%esp
f0101e4d:	85 c0                	test   %eax,%eax
f0101e4f:	74 19                	je     f0101e6a <mem_init+0xa0a>
f0101e51:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0101e56:	68 e7 73 10 f0       	push   $0xf01073e7
f0101e5b:	68 9f 05 00 00       	push   $0x59f
f0101e60:	68 c1 73 10 f0       	push   $0xf01073c1
f0101e65:	e8 2a e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e6a:	83 ec 04             	sub    $0x4,%esp
f0101e6d:	6a 00                	push   $0x0
f0101e6f:	68 00 10 00 00       	push   $0x1000
f0101e74:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101e7a:	e8 fd f2 ff ff       	call   f010117c <pgdir_walk>
f0101e7f:	83 c4 10             	add    $0x10,%esp
f0101e82:	f6 00 02             	testb  $0x2,(%eax)
f0101e85:	75 19                	jne    f0101ea0 <mem_init+0xa40>
f0101e87:	68 04 6e 10 f0       	push   $0xf0106e04
f0101e8c:	68 e7 73 10 f0       	push   $0xf01073e7
f0101e91:	68 a0 05 00 00       	push   $0x5a0
f0101e96:	68 c1 73 10 f0       	push   $0xf01073c1
f0101e9b:	e8 f4 e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ea0:	83 ec 04             	sub    $0x4,%esp
f0101ea3:	6a 00                	push   $0x0
f0101ea5:	68 00 10 00 00       	push   $0x1000
f0101eaa:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101eb0:	e8 c7 f2 ff ff       	call   f010117c <pgdir_walk>
f0101eb5:	83 c4 10             	add    $0x10,%esp
f0101eb8:	f6 00 04             	testb  $0x4,(%eax)
f0101ebb:	74 19                	je     f0101ed6 <mem_init+0xa76>
f0101ebd:	68 38 6e 10 f0       	push   $0xf0106e38
f0101ec2:	68 e7 73 10 f0       	push   $0xf01073e7
f0101ec7:	68 a1 05 00 00       	push   $0x5a1
f0101ecc:	68 c1 73 10 f0       	push   $0xf01073c1
f0101ed1:	e8 be e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
//cprintf("$$ before the page_insert into PTSIZE\n\n");
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ed6:	6a 02                	push   $0x2
f0101ed8:	68 00 00 40 00       	push   $0x400000
f0101edd:	56                   	push   %esi
f0101ede:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101ee4:	e8 ab f4 ff ff       	call   f0101394 <page_insert>
f0101ee9:	83 c4 10             	add    $0x10,%esp
f0101eec:	85 c0                	test   %eax,%eax
f0101eee:	78 19                	js     f0101f09 <mem_init+0xaa9>
f0101ef0:	68 70 6e 10 f0       	push   $0xf0106e70
f0101ef5:	68 e7 73 10 f0       	push   $0xf01073e7
f0101efa:	68 a5 05 00 00       	push   $0x5a5
f0101eff:	68 c1 73 10 f0       	push   $0xf01073c1
f0101f04:	e8 8b e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
//cprintf("$$ before insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f09:	6a 02                	push   $0x2
f0101f0b:	68 00 10 00 00       	push   $0x1000
f0101f10:	53                   	push   %ebx
f0101f11:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f17:	e8 78 f4 ff ff       	call   f0101394 <page_insert>
f0101f1c:	83 c4 10             	add    $0x10,%esp
f0101f1f:	85 c0                	test   %eax,%eax
f0101f21:	74 19                	je     f0101f3c <mem_init+0xadc>
f0101f23:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101f28:	68 e7 73 10 f0       	push   $0xf01073e7
f0101f2d:	68 a9 05 00 00       	push   $0x5a9
f0101f32:	68 c1 73 10 f0       	push   $0xf01073c1
f0101f37:	e8 58 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f3c:	83 ec 04             	sub    $0x4,%esp
f0101f3f:	6a 00                	push   $0x0
f0101f41:	68 00 10 00 00       	push   $0x1000
f0101f46:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0101f4c:	e8 2b f2 ff ff       	call   f010117c <pgdir_walk>
f0101f51:	83 c4 10             	add    $0x10,%esp
f0101f54:	f6 00 04             	testb  $0x4,(%eax)
f0101f57:	74 19                	je     f0101f72 <mem_init+0xb12>
f0101f59:	68 38 6e 10 f0       	push   $0xf0106e38
f0101f5e:	68 e7 73 10 f0       	push   $0xf01073e7
f0101f63:	68 ab 05 00 00       	push   $0x5ab
f0101f68:	68 c1 73 10 f0       	push   $0xf01073c1
f0101f6d:	e8 22 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after checking the (!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U)\n\n");
	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f72:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0101f78:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f7d:	89 f8                	mov    %edi,%eax
f0101f7f:	e8 5c ec ff ff       	call   f0100be0 <check_va2pa>
f0101f84:	89 c1                	mov    %eax,%ecx
f0101f86:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f89:	89 d8                	mov    %ebx,%eax
f0101f8b:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0101f91:	c1 f8 03             	sar    $0x3,%eax
f0101f94:	c1 e0 0c             	shl    $0xc,%eax
f0101f97:	39 c1                	cmp    %eax,%ecx
f0101f99:	74 19                	je     f0101fb4 <mem_init+0xb54>
f0101f9b:	68 e4 6e 10 f0       	push   $0xf0106ee4
f0101fa0:	68 e7 73 10 f0       	push   $0xf01073e7
f0101fa5:	68 ae 05 00 00       	push   $0x5ae
f0101faa:	68 c1 73 10 f0       	push   $0xf01073c1
f0101faf:	e8 e0 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fb4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fb9:	89 f8                	mov    %edi,%eax
f0101fbb:	e8 20 ec ff ff       	call   f0100be0 <check_va2pa>
f0101fc0:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fc3:	74 19                	je     f0101fde <mem_init+0xb7e>
f0101fc5:	68 10 6f 10 f0       	push   $0xf0106f10
f0101fca:	68 e7 73 10 f0       	push   $0xf01073e7
f0101fcf:	68 af 05 00 00       	push   $0x5af
f0101fd4:	68 c1 73 10 f0       	push   $0xf01073c1
f0101fd9:	e8 b6 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fde:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fe3:	74 19                	je     f0101ffe <mem_init+0xb9e>
f0101fe5:	68 10 76 10 f0       	push   $0xf0107610
f0101fea:	68 e7 73 10 f0       	push   $0xf01073e7
f0101fef:	68 b1 05 00 00       	push   $0x5b1
f0101ff4:	68 c1 73 10 f0       	push   $0xf01073c1
f0101ff9:	e8 96 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0101ffe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102001:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102006:	74 19                	je     f0102021 <mem_init+0xbc1>
f0102008:	68 21 76 10 f0       	push   $0xf0107621
f010200d:	68 e7 73 10 f0       	push   $0xf01073e7
f0102012:	68 b2 05 00 00       	push   $0x5b2
f0102017:	68 c1 73 10 f0       	push   $0xf01073c1
f010201c:	e8 73 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102021:	83 ec 0c             	sub    $0xc,%esp
f0102024:	6a 00                	push   $0x0
f0102026:	e8 b7 ef ff ff       	call   f0100fe2 <page_alloc>
f010202b:	83 c4 10             	add    $0x10,%esp
f010202e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102031:	75 04                	jne    f0102037 <mem_init+0xbd7>
f0102033:	85 c0                	test   %eax,%eax
f0102035:	75 19                	jne    f0102050 <mem_init+0xbf0>
f0102037:	68 40 6f 10 f0       	push   $0xf0106f40
f010203c:	68 e7 73 10 f0       	push   $0xf01073e7
f0102041:	68 b5 05 00 00       	push   $0x5b5
f0102046:	68 c1 73 10 f0       	push   $0xf01073c1
f010204b:	e8 44 e0 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102050:	83 ec 08             	sub    $0x8,%esp
f0102053:	6a 00                	push   $0x0
f0102055:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f010205b:	e8 e6 f2 ff ff       	call   f0101346 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102060:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0102066:	ba 00 00 00 00       	mov    $0x0,%edx
f010206b:	89 f8                	mov    %edi,%eax
f010206d:	e8 6e eb ff ff       	call   f0100be0 <check_va2pa>
f0102072:	83 c4 10             	add    $0x10,%esp
f0102075:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102078:	74 19                	je     f0102093 <mem_init+0xc33>
f010207a:	68 64 6f 10 f0       	push   $0xf0106f64
f010207f:	68 e7 73 10 f0       	push   $0xf01073e7
f0102084:	68 b9 05 00 00       	push   $0x5b9
f0102089:	68 c1 73 10 f0       	push   $0xf01073c1
f010208e:	e8 01 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102093:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102098:	89 f8                	mov    %edi,%eax
f010209a:	e8 41 eb ff ff       	call   f0100be0 <check_va2pa>
f010209f:	89 da                	mov    %ebx,%edx
f01020a1:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f01020a7:	c1 fa 03             	sar    $0x3,%edx
f01020aa:	c1 e2 0c             	shl    $0xc,%edx
f01020ad:	39 d0                	cmp    %edx,%eax
f01020af:	74 19                	je     f01020ca <mem_init+0xc6a>
f01020b1:	68 10 6f 10 f0       	push   $0xf0106f10
f01020b6:	68 e7 73 10 f0       	push   $0xf01073e7
f01020bb:	68 ba 05 00 00       	push   $0x5ba
f01020c0:	68 c1 73 10 f0       	push   $0xf01073c1
f01020c5:	e8 ca df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01020ca:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020cf:	74 19                	je     f01020ea <mem_init+0xc8a>
f01020d1:	68 c7 75 10 f0       	push   $0xf01075c7
f01020d6:	68 e7 73 10 f0       	push   $0xf01073e7
f01020db:	68 bb 05 00 00       	push   $0x5bb
f01020e0:	68 c1 73 10 f0       	push   $0xf01073c1
f01020e5:	e8 aa df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01020ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ed:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01020f2:	74 19                	je     f010210d <mem_init+0xcad>
f01020f4:	68 21 76 10 f0       	push   $0xf0107621
f01020f9:	68 e7 73 10 f0       	push   $0xf01073e7
f01020fe:	68 bc 05 00 00       	push   $0x5bc
f0102103:	68 c1 73 10 f0       	push   $0xf01073c1
f0102108:	e8 87 df ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010210d:	6a 00                	push   $0x0
f010210f:	68 00 10 00 00       	push   $0x1000
f0102114:	53                   	push   %ebx
f0102115:	57                   	push   %edi
f0102116:	e8 79 f2 ff ff       	call   f0101394 <page_insert>
f010211b:	83 c4 10             	add    $0x10,%esp
f010211e:	85 c0                	test   %eax,%eax
f0102120:	74 19                	je     f010213b <mem_init+0xcdb>
f0102122:	68 88 6f 10 f0       	push   $0xf0106f88
f0102127:	68 e7 73 10 f0       	push   $0xf01073e7
f010212c:	68 bf 05 00 00       	push   $0x5bf
f0102131:	68 c1 73 10 f0       	push   $0xf01073c1
f0102136:	e8 59 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010213b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102140:	75 19                	jne    f010215b <mem_init+0xcfb>
f0102142:	68 32 76 10 f0       	push   $0xf0107632
f0102147:	68 e7 73 10 f0       	push   $0xf01073e7
f010214c:	68 c0 05 00 00       	push   $0x5c0
f0102151:	68 c1 73 10 f0       	push   $0xf01073c1
f0102156:	e8 39 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010215b:	83 3b 00             	cmpl   $0x0,(%ebx)
f010215e:	74 19                	je     f0102179 <mem_init+0xd19>
f0102160:	68 3e 76 10 f0       	push   $0xf010763e
f0102165:	68 e7 73 10 f0       	push   $0xf01073e7
f010216a:	68 c1 05 00 00       	push   $0x5c1
f010216f:	68 c1 73 10 f0       	push   $0xf01073c1
f0102174:	e8 1b df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102179:	83 ec 08             	sub    $0x8,%esp
f010217c:	68 00 10 00 00       	push   $0x1000
f0102181:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102187:	e8 ba f1 ff ff       	call   f0101346 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010218c:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0102192:	ba 00 00 00 00       	mov    $0x0,%edx
f0102197:	89 f8                	mov    %edi,%eax
f0102199:	e8 42 ea ff ff       	call   f0100be0 <check_va2pa>
f010219e:	83 c4 10             	add    $0x10,%esp
f01021a1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021a4:	74 19                	je     f01021bf <mem_init+0xd5f>
f01021a6:	68 64 6f 10 f0       	push   $0xf0106f64
f01021ab:	68 e7 73 10 f0       	push   $0xf01073e7
f01021b0:	68 c5 05 00 00       	push   $0x5c5
f01021b5:	68 c1 73 10 f0       	push   $0xf01073c1
f01021ba:	e8 d5 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021bf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021c4:	89 f8                	mov    %edi,%eax
f01021c6:	e8 15 ea ff ff       	call   f0100be0 <check_va2pa>
f01021cb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021ce:	74 19                	je     f01021e9 <mem_init+0xd89>
f01021d0:	68 c0 6f 10 f0       	push   $0xf0106fc0
f01021d5:	68 e7 73 10 f0       	push   $0xf01073e7
f01021da:	68 c6 05 00 00       	push   $0x5c6
f01021df:	68 c1 73 10 f0       	push   $0xf01073c1
f01021e4:	e8 ab de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01021e9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021ee:	74 19                	je     f0102209 <mem_init+0xda9>
f01021f0:	68 53 76 10 f0       	push   $0xf0107653
f01021f5:	68 e7 73 10 f0       	push   $0xf01073e7
f01021fa:	68 c7 05 00 00       	push   $0x5c7
f01021ff:	68 c1 73 10 f0       	push   $0xf01073c1
f0102204:	e8 8b de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102209:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010220c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102211:	74 19                	je     f010222c <mem_init+0xdcc>
f0102213:	68 21 76 10 f0       	push   $0xf0107621
f0102218:	68 e7 73 10 f0       	push   $0xf01073e7
f010221d:	68 c8 05 00 00       	push   $0x5c8
f0102222:	68 c1 73 10 f0       	push   $0xf01073c1
f0102227:	e8 68 de ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010222c:	83 ec 0c             	sub    $0xc,%esp
f010222f:	6a 00                	push   $0x0
f0102231:	e8 ac ed ff ff       	call   f0100fe2 <page_alloc>
f0102236:	83 c4 10             	add    $0x10,%esp
f0102239:	85 c0                	test   %eax,%eax
f010223b:	74 04                	je     f0102241 <mem_init+0xde1>
f010223d:	39 c3                	cmp    %eax,%ebx
f010223f:	74 19                	je     f010225a <mem_init+0xdfa>
f0102241:	68 e8 6f 10 f0       	push   $0xf0106fe8
f0102246:	68 e7 73 10 f0       	push   $0xf01073e7
f010224b:	68 cb 05 00 00       	push   $0x5cb
f0102250:	68 c1 73 10 f0       	push   $0xf01073c1
f0102255:	e8 3a de ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010225a:	83 ec 0c             	sub    $0xc,%esp
f010225d:	6a 00                	push   $0x0
f010225f:	e8 7e ed ff ff       	call   f0100fe2 <page_alloc>
f0102264:	83 c4 10             	add    $0x10,%esp
f0102267:	85 c0                	test   %eax,%eax
f0102269:	74 19                	je     f0102284 <mem_init+0xe24>
f010226b:	68 75 75 10 f0       	push   $0xf0107575
f0102270:	68 e7 73 10 f0       	push   $0xf01073e7
f0102275:	68 ce 05 00 00       	push   $0x5ce
f010227a:	68 c1 73 10 f0       	push   $0xf01073c1
f010227f:	e8 10 de ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102284:	8b 0d 8c 2e 21 f0    	mov    0xf0212e8c,%ecx
f010228a:	8b 11                	mov    (%ecx),%edx
f010228c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102292:	89 f0                	mov    %esi,%eax
f0102294:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010229a:	c1 f8 03             	sar    $0x3,%eax
f010229d:	c1 e0 0c             	shl    $0xc,%eax
f01022a0:	39 c2                	cmp    %eax,%edx
f01022a2:	74 19                	je     f01022bd <mem_init+0xe5d>
f01022a4:	68 8c 6c 10 f0       	push   $0xf0106c8c
f01022a9:	68 e7 73 10 f0       	push   $0xf01073e7
f01022ae:	68 d1 05 00 00       	push   $0x5d1
f01022b3:	68 c1 73 10 f0       	push   $0xf01073c1
f01022b8:	e8 d7 dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01022bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022c3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022c8:	74 19                	je     f01022e3 <mem_init+0xe83>
f01022ca:	68 d8 75 10 f0       	push   $0xf01075d8
f01022cf:	68 e7 73 10 f0       	push   $0xf01073e7
f01022d4:	68 d3 05 00 00       	push   $0x5d3
f01022d9:	68 c1 73 10 f0       	push   $0xf01073c1
f01022de:	e8 b1 dd ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01022e3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022e9:	83 ec 0c             	sub    $0xc,%esp
f01022ec:	56                   	push   %esi
f01022ed:	e8 a9 ed ff ff       	call   f010109b <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022f2:	83 c4 0c             	add    $0xc,%esp
f01022f5:	6a 01                	push   $0x1
f01022f7:	68 00 10 40 00       	push   $0x401000
f01022fc:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102302:	e8 75 ee ff ff       	call   f010117c <pgdir_walk>
f0102307:	89 c7                	mov    %eax,%edi
f0102309:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010230c:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0102311:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102314:	8b 40 04             	mov    0x4(%eax),%eax
f0102317:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010231c:	8b 0d 88 2e 21 f0    	mov    0xf0212e88,%ecx
f0102322:	89 c2                	mov    %eax,%edx
f0102324:	c1 ea 0c             	shr    $0xc,%edx
f0102327:	83 c4 10             	add    $0x10,%esp
f010232a:	39 ca                	cmp    %ecx,%edx
f010232c:	72 15                	jb     f0102343 <mem_init+0xee3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010232e:	50                   	push   %eax
f010232f:	68 48 64 10 f0       	push   $0xf0106448
f0102334:	68 da 05 00 00       	push   $0x5da
f0102339:	68 c1 73 10 f0       	push   $0xf01073c1
f010233e:	e8 51 dd ff ff       	call   f0100094 <_panic>
	
//now we fault at ptep == ptep1+PTX(va)
//cprintf("ptep:%x , PTX(va):%x,va:%x,ptep1:%x\n",ptep,PTX(va),va,ptep1);

	assert(ptep == ptep1 + PTX(va));
f0102343:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102348:	39 c7                	cmp    %eax,%edi
f010234a:	74 19                	je     f0102365 <mem_init+0xf05>
f010234c:	68 64 76 10 f0       	push   $0xf0107664
f0102351:	68 e7 73 10 f0       	push   $0xf01073e7
f0102356:	68 df 05 00 00       	push   $0x5df
f010235b:	68 c1 73 10 f0       	push   $0xf01073c1
f0102360:	e8 2f dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102365:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102368:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010236f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102375:	89 f0                	mov    %esi,%eax
f0102377:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010237d:	c1 f8 03             	sar    $0x3,%eax
f0102380:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102383:	89 c2                	mov    %eax,%edx
f0102385:	c1 ea 0c             	shr    $0xc,%edx
f0102388:	39 d1                	cmp    %edx,%ecx
f010238a:	77 12                	ja     f010239e <mem_init+0xf3e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010238c:	50                   	push   %eax
f010238d:	68 48 64 10 f0       	push   $0xf0106448
f0102392:	6a 58                	push   $0x58
f0102394:	68 cd 73 10 f0       	push   $0xf01073cd
f0102399:	e8 f6 dc ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010239e:	83 ec 04             	sub    $0x4,%esp
f01023a1:	68 00 10 00 00       	push   $0x1000
f01023a6:	68 ff 00 00 00       	push   $0xff
f01023ab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023b0:	50                   	push   %eax
f01023b1:	e8 ee 32 00 00       	call   f01056a4 <memset>
	page_free(pp0);
f01023b6:	89 34 24             	mov    %esi,(%esp)
f01023b9:	e8 dd ec ff ff       	call   f010109b <page_free>


//here below is my commit,so if we set all pp0(the page table entry)
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023be:	83 c4 0c             	add    $0xc,%esp
f01023c1:	6a 01                	push   $0x1
f01023c3:	6a 00                	push   $0x0
f01023c5:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f01023cb:	e8 ac ed ff ff       	call   f010117c <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023d0:	89 f2                	mov    %esi,%edx
f01023d2:	2b 15 90 2e 21 f0    	sub    0xf0212e90,%edx
f01023d8:	c1 fa 03             	sar    $0x3,%edx
f01023db:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023de:	89 d0                	mov    %edx,%eax
f01023e0:	c1 e8 0c             	shr    $0xc,%eax
f01023e3:	83 c4 10             	add    $0x10,%esp
f01023e6:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f01023ec:	72 12                	jb     f0102400 <mem_init+0xfa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023ee:	52                   	push   %edx
f01023ef:	68 48 64 10 f0       	push   $0xf0106448
f01023f4:	6a 58                	push   $0x58
f01023f6:	68 cd 73 10 f0       	push   $0xf01073cd
f01023fb:	e8 94 dc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102400:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102409:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	
	for(i=0; i<NPTENTRIES; i++){
		//:/cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
		assert((ptep[i] & PTE_P) == 0);
f010240f:	f6 00 01             	testb  $0x1,(%eax)
f0102412:	74 19                	je     f010242d <mem_init+0xfcd>
f0102414:	68 7c 76 10 f0       	push   $0xf010767c
f0102419:	68 e7 73 10 f0       	push   $0xf01073e7
f010241e:	68 f3 05 00 00       	push   $0x5f3
f0102423:	68 c1 73 10 f0       	push   $0xf01073c1
f0102428:	e8 67 dc ff ff       	call   f0100094 <_panic>
f010242d:	83 c0 04             	add    $0x4,%eax
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	
	for(i=0; i<NPTENTRIES; i++){
f0102430:	39 d0                	cmp    %edx,%eax
f0102432:	75 db                	jne    f010240f <mem_init+0xfaf>
		assert((ptep[i] & PTE_P) == 0);
	}
//here is the error again.
//	for(i = 0;i<NPTENTRIES;i++)
//		cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
	kern_pgdir[0] = 0;
f0102434:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0102439:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010243f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102445:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102448:	a3 40 22 21 f0       	mov    %eax,0xf0212240

	// free the pages we took
	page_free(pp0);
f010244d:	83 ec 0c             	sub    $0xc,%esp
f0102450:	56                   	push   %esi
f0102451:	e8 45 ec ff ff       	call   f010109b <page_free>
	page_free(pp1);
f0102456:	89 1c 24             	mov    %ebx,(%esp)
f0102459:	e8 3d ec ff ff       	call   f010109b <page_free>
	page_free(pp2);
f010245e:	83 c4 04             	add    $0x4,%esp
f0102461:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102464:	e8 32 ec ff ff       	call   f010109b <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102469:	83 c4 08             	add    $0x8,%esp
f010246c:	68 01 10 00 00       	push   $0x1001
f0102471:	6a 00                	push   $0x0
f0102473:	e8 82 ef ff ff       	call   f01013fa <mmio_map_region>
f0102478:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010247a:	83 c4 08             	add    $0x8,%esp
f010247d:	68 00 10 00 00       	push   $0x1000
f0102482:	6a 00                	push   $0x0
f0102484:	e8 71 ef ff ff       	call   f01013fa <mmio_map_region>
f0102489:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010248b:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102491:	83 c4 10             	add    $0x10,%esp
f0102494:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010249a:	76 07                	jbe    f01024a3 <mem_init+0x1043>
f010249c:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01024a1:	76 19                	jbe    f01024bc <mem_init+0x105c>
f01024a3:	68 0c 70 10 f0       	push   $0xf010700c
f01024a8:	68 e7 73 10 f0       	push   $0xf01073e7
f01024ad:	68 07 06 00 00       	push   $0x607
f01024b2:	68 c1 73 10 f0       	push   $0xf01073c1
f01024b7:	e8 d8 db ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01024bc:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024c2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024c8:	77 08                	ja     f01024d2 <mem_init+0x1072>
f01024ca:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024d0:	77 19                	ja     f01024eb <mem_init+0x108b>
f01024d2:	68 34 70 10 f0       	push   $0xf0107034
f01024d7:	68 e7 73 10 f0       	push   $0xf01073e7
f01024dc:	68 08 06 00 00       	push   $0x608
f01024e1:	68 c1 73 10 f0       	push   $0xf01073c1
f01024e6:	e8 a9 db ff ff       	call   f0100094 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024eb:	89 da                	mov    %ebx,%edx
f01024ed:	09 f2                	or     %esi,%edx
f01024ef:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024f5:	74 19                	je     f0102510 <mem_init+0x10b0>
f01024f7:	68 5c 70 10 f0       	push   $0xf010705c
f01024fc:	68 e7 73 10 f0       	push   $0xf01073e7
f0102501:	68 0a 06 00 00       	push   $0x60a
f0102506:	68 c1 73 10 f0       	push   $0xf01073c1
f010250b:	e8 84 db ff ff       	call   f0100094 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102510:	39 c6                	cmp    %eax,%esi
f0102512:	73 19                	jae    f010252d <mem_init+0x10cd>
f0102514:	68 93 76 10 f0       	push   $0xf0107693
f0102519:	68 e7 73 10 f0       	push   $0xf01073e7
f010251e:	68 0c 06 00 00       	push   $0x60c
f0102523:	68 c1 73 10 f0       	push   $0xf01073c1
f0102528:	e8 67 db ff ff       	call   f0100094 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010252d:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi
f0102533:	89 da                	mov    %ebx,%edx
f0102535:	89 f8                	mov    %edi,%eax
f0102537:	e8 a4 e6 ff ff       	call   f0100be0 <check_va2pa>
f010253c:	85 c0                	test   %eax,%eax
f010253e:	74 19                	je     f0102559 <mem_init+0x10f9>
f0102540:	68 84 70 10 f0       	push   $0xf0107084
f0102545:	68 e7 73 10 f0       	push   $0xf01073e7
f010254a:	68 0e 06 00 00       	push   $0x60e
f010254f:	68 c1 73 10 f0       	push   $0xf01073c1
f0102554:	e8 3b db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102559:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010255f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102562:	89 c2                	mov    %eax,%edx
f0102564:	89 f8                	mov    %edi,%eax
f0102566:	e8 75 e6 ff ff       	call   f0100be0 <check_va2pa>
f010256b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102570:	74 19                	je     f010258b <mem_init+0x112b>
f0102572:	68 a8 70 10 f0       	push   $0xf01070a8
f0102577:	68 e7 73 10 f0       	push   $0xf01073e7
f010257c:	68 0f 06 00 00       	push   $0x60f
f0102581:	68 c1 73 10 f0       	push   $0xf01073c1
f0102586:	e8 09 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010258b:	89 f2                	mov    %esi,%edx
f010258d:	89 f8                	mov    %edi,%eax
f010258f:	e8 4c e6 ff ff       	call   f0100be0 <check_va2pa>
f0102594:	85 c0                	test   %eax,%eax
f0102596:	74 19                	je     f01025b1 <mem_init+0x1151>
f0102598:	68 d8 70 10 f0       	push   $0xf01070d8
f010259d:	68 e7 73 10 f0       	push   $0xf01073e7
f01025a2:	68 10 06 00 00       	push   $0x610
f01025a7:	68 c1 73 10 f0       	push   $0xf01073c1
f01025ac:	e8 e3 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025b1:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01025b7:	89 f8                	mov    %edi,%eax
f01025b9:	e8 22 e6 ff ff       	call   f0100be0 <check_va2pa>
f01025be:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025c1:	74 19                	je     f01025dc <mem_init+0x117c>
f01025c3:	68 fc 70 10 f0       	push   $0xf01070fc
f01025c8:	68 e7 73 10 f0       	push   $0xf01073e7
f01025cd:	68 11 06 00 00       	push   $0x611
f01025d2:	68 c1 73 10 f0       	push   $0xf01073c1
f01025d7:	e8 b8 da ff ff       	call   f0100094 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01025dc:	83 ec 04             	sub    $0x4,%esp
f01025df:	6a 00                	push   $0x0
f01025e1:	53                   	push   %ebx
f01025e2:	57                   	push   %edi
f01025e3:	e8 94 eb ff ff       	call   f010117c <pgdir_walk>
f01025e8:	83 c4 10             	add    $0x10,%esp
f01025eb:	f6 00 1a             	testb  $0x1a,(%eax)
f01025ee:	75 19                	jne    f0102609 <mem_init+0x11a9>
f01025f0:	68 28 71 10 f0       	push   $0xf0107128
f01025f5:	68 e7 73 10 f0       	push   $0xf01073e7
f01025fa:	68 13 06 00 00       	push   $0x613
f01025ff:	68 c1 73 10 f0       	push   $0xf01073c1
f0102604:	e8 8b da ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102609:	83 ec 04             	sub    $0x4,%esp
f010260c:	6a 00                	push   $0x0
f010260e:	53                   	push   %ebx
f010260f:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102615:	e8 62 eb ff ff       	call   f010117c <pgdir_walk>
f010261a:	8b 00                	mov    (%eax),%eax
f010261c:	83 c4 10             	add    $0x10,%esp
f010261f:	83 e0 04             	and    $0x4,%eax
f0102622:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102625:	74 19                	je     f0102640 <mem_init+0x11e0>
f0102627:	68 6c 71 10 f0       	push   $0xf010716c
f010262c:	68 e7 73 10 f0       	push   $0xf01073e7
f0102631:	68 14 06 00 00       	push   $0x614
f0102636:	68 c1 73 10 f0       	push   $0xf01073c1
f010263b:	e8 54 da ff ff       	call   f0100094 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102640:	83 ec 04             	sub    $0x4,%esp
f0102643:	6a 00                	push   $0x0
f0102645:	53                   	push   %ebx
f0102646:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f010264c:	e8 2b eb ff ff       	call   f010117c <pgdir_walk>
f0102651:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102657:	83 c4 0c             	add    $0xc,%esp
f010265a:	6a 00                	push   $0x0
f010265c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010265f:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102665:	e8 12 eb ff ff       	call   f010117c <pgdir_walk>
f010266a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102670:	83 c4 0c             	add    $0xc,%esp
f0102673:	6a 00                	push   $0x0
f0102675:	56                   	push   %esi
f0102676:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f010267c:	e8 fb ea ff ff       	call   f010117c <pgdir_walk>
f0102681:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102687:	c7 04 24 a5 76 10 f0 	movl   $0xf01076a5,(%esp)
f010268e:	e8 dc 11 00 00       	call   f010386f <cprintf>
	//I know the meaning of some special 'entry'  and I know the perm is 
	//set to which entry.
	//it is just 4MB to hold the pages so it is perfect we just need
	//one page table,insert to the kern_pgdir.
//here is the new version,npages*4 because one page address occupy 4B?
	boot_map_region(kern_pgdir,UPAGES,0x400000,PADDR(pages),PTE_U|PTE_P|PTE_W);
f0102693:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102698:	83 c4 10             	add    $0x10,%esp
f010269b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026a0:	77 15                	ja     f01026b7 <mem_init+0x1257>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a2:	50                   	push   %eax
f01026a3:	68 9c 64 10 f0       	push   $0xf010649c
f01026a8:	68 06 01 00 00       	push   $0x106
f01026ad:	68 c1 73 10 f0       	push   $0xf01073c1
f01026b2:	e8 dd d9 ff ff       	call   f0100094 <_panic>
f01026b7:	83 ec 08             	sub    $0x8,%esp
f01026ba:	6a 07                	push   $0x7
f01026bc:	05 00 00 00 10       	add    $0x10000000,%eax
f01026c1:	50                   	push   %eax
f01026c2:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026c7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026cc:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01026d1:	e8 39 eb ff ff       	call   f010120f <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Pemissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,NENV*sizeof(struct Env),PADDR(envs),PTE_P|PTE_W|PTE_A|PTE_U);
f01026d6:	a1 44 22 21 f0       	mov    0xf0212244,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026db:	83 c4 10             	add    $0x10,%esp
f01026de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026e3:	77 15                	ja     f01026fa <mem_init+0x129a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026e5:	50                   	push   %eax
f01026e6:	68 9c 64 10 f0       	push   $0xf010649c
f01026eb:	68 12 01 00 00       	push   $0x112
f01026f0:	68 c1 73 10 f0       	push   $0xf01073c1
f01026f5:	e8 9a d9 ff ff       	call   f0100094 <_panic>
f01026fa:	83 ec 08             	sub    $0x8,%esp
f01026fd:	6a 27                	push   $0x27
f01026ff:	05 00 00 00 10       	add    $0x10000000,%eax
f0102704:	50                   	push   %eax
f0102705:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010270a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010270f:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0102714:	e8 f6 ea ff ff       	call   f010120f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102719:	83 c4 10             	add    $0x10,%esp
f010271c:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102721:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102726:	77 15                	ja     f010273d <mem_init+0x12dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102728:	50                   	push   %eax
f0102729:	68 9c 64 10 f0       	push   $0xf010649c
f010272e:	68 27 01 00 00       	push   $0x127
f0102733:	68 c1 73 10 f0       	push   $0xf01073c1
f0102738:	e8 57 d9 ff ff       	call   f0100094 <_panic>
	//the second seg is 4M-32K size as the guard page.
	//[KSTACKTOP-KSTKSIZE,KSTACKTOP)is mapped in physical address
	//[KSTACKOP-PTSIZE,KSTACKTOP-KSTKSIZE)is not mapped by physical mem
	//so it will cause fault if we access it.(which is the 'back' means)

	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
f010273d:	83 ec 08             	sub    $0x8,%esp
f0102740:	6a 22                	push   $0x22
f0102742:	68 00 60 11 00       	push   $0x116000
f0102747:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010274c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102751:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f0102756:	e8 b4 ea ff ff       	call   f010120f <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
f010275b:	83 c4 08             	add    $0x8,%esp
f010275e:	6a 08                	push   $0x8
f0102760:	68 be 76 10 f0       	push   $0xf01076be
f0102765:	e8 05 11 00 00       	call   f010386f <cprintf>
f010276a:	c7 45 c4 00 40 21 f0 	movl   $0xf0214000,-0x3c(%ebp)
f0102771:	83 c4 10             	add    $0x10,%esp
f0102774:	bb 00 40 21 f0       	mov    $0xf0214000,%ebx
f0102779:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010277e:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102784:	77 15                	ja     f010279b <mem_init+0x133b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102786:	53                   	push   %ebx
f0102787:	68 9c 64 10 f0       	push   $0xf010649c
f010278c:	68 6e 01 00 00       	push   $0x16e
f0102791:	68 c1 73 10 f0       	push   $0xf01073c1
f0102796:	e8 f9 d8 ff ff       	call   f0100094 <_panic>
	for(int i = 0;i<NCPU;i++){
		uintptr_t kstacktop_i = KSTACKTOP-(i)*(KSTKSIZE+KSTKGAP);	
		boot_map_region(kern_pgdir,kstacktop_i-KSTKSIZE,KSTKSIZE,PADDR(&percpu_kstacks[i]),PTE_P|PTE_W);
f010279b:	83 ec 08             	sub    $0x8,%esp
f010279e:	6a 03                	push   $0x3
f01027a0:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01027a6:	50                   	push   %eax
f01027a7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027ac:	89 f2                	mov    %esi,%edx
f01027ae:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01027b3:	e8 57 ea ff ff       	call   f010120f <boot_map_region>
f01027b8:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01027be:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
	for(int i = 0;i<NCPU;i++){
f01027c4:	83 c4 10             	add    $0x10,%esp
f01027c7:	b8 00 40 25 f0       	mov    $0xf0254000,%eax
f01027cc:	39 d8                	cmp    %ebx,%eax
f01027ce:	75 ae                	jne    f010277e <mem_init+0x131e>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	
	boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W|PTE_A);	
f01027d0:	83 ec 08             	sub    $0x8,%esp
f01027d3:	6a 22                	push   $0x22
f01027d5:	6a 00                	push   $0x0
f01027d7:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01027dc:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027e1:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
f01027e6:	e8 24 ea ff ff       	call   f010120f <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027eb:	8b 3d 8c 2e 21 f0    	mov    0xf0212e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027f1:	a1 88 2e 21 f0       	mov    0xf0212e88,%eax
f01027f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027f9:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102800:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102805:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE){

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102808:	8b 35 90 2e 21 f0    	mov    0xf0212e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010280e:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102811:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f0102814:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102819:	eb 55                	jmp    f0102870 <mem_init+0x1410>

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010281b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102821:	89 f8                	mov    %edi,%eax
f0102823:	e8 b8 e3 ff ff       	call   f0100be0 <check_va2pa>
f0102828:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010282f:	77 15                	ja     f0102846 <mem_init+0x13e6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102831:	56                   	push   %esi
f0102832:	68 9c 64 10 f0       	push   $0xf010649c
f0102837:	68 e5 04 00 00       	push   $0x4e5
f010283c:	68 c1 73 10 f0       	push   $0xf01073c1
f0102841:	e8 4e d8 ff ff       	call   f0100094 <_panic>
f0102846:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010284d:	39 c2                	cmp    %eax,%edx
f010284f:	74 19                	je     f010286a <mem_init+0x140a>
f0102851:	68 a0 71 10 f0       	push   $0xf01071a0
f0102856:	68 e7 73 10 f0       	push   $0xf01073e7
f010285b:	68 e5 04 00 00       	push   $0x4e5
f0102860:	68 c1 73 10 f0       	push   $0xf01073c1
f0102865:	e8 2a d8 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f010286a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102870:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102873:	77 a6                	ja     f010281b <mem_init+0x13bb>

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102875:	8b 35 44 22 21 f0    	mov    0xf0212244,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010287b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010287e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102883:	89 da                	mov    %ebx,%edx
f0102885:	89 f8                	mov    %edi,%eax
f0102887:	e8 54 e3 ff ff       	call   f0100be0 <check_va2pa>
f010288c:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102893:	77 15                	ja     f01028aa <mem_init+0x144a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102895:	56                   	push   %esi
f0102896:	68 9c 64 10 f0       	push   $0xf010649c
f010289b:	68 eb 04 00 00       	push   $0x4eb
f01028a0:	68 c1 73 10 f0       	push   $0xf01073c1
f01028a5:	e8 ea d7 ff ff       	call   f0100094 <_panic>
f01028aa:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01028b1:	39 d0                	cmp    %edx,%eax
f01028b3:	74 19                	je     f01028ce <mem_init+0x146e>
f01028b5:	68 d4 71 10 f0       	push   $0xf01071d4
f01028ba:	68 e7 73 10 f0       	push   $0xf01073e7
f01028bf:	68 eb 04 00 00       	push   $0x4eb
f01028c4:	68 c1 73 10 f0       	push   $0xf01073c1
f01028c9:	e8 c6 d7 ff ff       	call   f0100094 <_panic>
f01028ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f01028d4:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028da:	75 a7                	jne    f0102883 <mem_init+0x1423>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f01028dc:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01028df:	c1 e6 0c             	shl    $0xc,%esi
f01028e2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028e7:	eb 30                	jmp    f0102919 <mem_init+0x14b9>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028e9:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028ef:	89 f8                	mov    %edi,%eax
f01028f1:	e8 ea e2 ff ff       	call   f0100be0 <check_va2pa>
f01028f6:	39 c3                	cmp    %eax,%ebx
f01028f8:	74 19                	je     f0102913 <mem_init+0x14b3>
f01028fa:	68 08 72 10 f0       	push   $0xf0107208
f01028ff:	68 e7 73 10 f0       	push   $0xf01073e7
f0102904:	68 f1 04 00 00       	push   $0x4f1
f0102909:	68 c1 73 10 f0       	push   $0xf01073c1
f010290e:	e8 81 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0102913:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102919:	39 f3                	cmp    %esi,%ebx
f010291b:	72 cc                	jb     f01028e9 <mem_init+0x1489>
f010291d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102922:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102925:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102928:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010292b:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102931:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102934:	89 c3                	mov    %eax,%ebx
	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102936:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102939:	05 00 80 00 20       	add    $0x20008000,%eax
f010293e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102941:	89 da                	mov    %ebx,%edx
f0102943:	89 f8                	mov    %edi,%eax
f0102945:	e8 96 e2 ff ff       	call   f0100be0 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010294a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102950:	77 15                	ja     f0102967 <mem_init+0x1507>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102952:	56                   	push   %esi
f0102953:	68 9c 64 10 f0       	push   $0xf010649c
f0102958:	68 fc 04 00 00       	push   $0x4fc
f010295d:	68 c1 73 10 f0       	push   $0xf01073c1
f0102962:	e8 2d d7 ff ff       	call   f0100094 <_panic>
f0102967:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010296a:	8d 94 0b 00 40 21 f0 	lea    -0xfdec000(%ebx,%ecx,1),%edx
f0102971:	39 d0                	cmp    %edx,%eax
f0102973:	74 19                	je     f010298e <mem_init+0x152e>
f0102975:	68 30 72 10 f0       	push   $0xf0107230
f010297a:	68 e7 73 10 f0       	push   $0xf01073e7
f010297f:	68 fc 04 00 00       	push   $0x4fc
f0102984:	68 c1 73 10 f0       	push   $0xf01073c1
f0102989:	e8 06 d7 ff ff       	call   f0100094 <_panic>
f010298e:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102994:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102997:	75 a8                	jne    f0102941 <mem_init+0x14e1>
f0102999:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010299c:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01029a2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029a5:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029a7:	89 da                	mov    %ebx,%edx
f01029a9:	89 f8                	mov    %edi,%eax
f01029ab:	e8 30 e2 ff ff       	call   f0100be0 <check_va2pa>
f01029b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029b3:	74 19                	je     f01029ce <mem_init+0x156e>
f01029b5:	68 78 72 10 f0       	push   $0xf0107278
f01029ba:	68 e7 73 10 f0       	push   $0xf01073e7
f01029bf:	68 fe 04 00 00       	push   $0x4fe
f01029c4:	68 c1 73 10 f0       	push   $0xf01073c1
f01029c9:	e8 c6 d6 ff ff       	call   f0100094 <_panic>
f01029ce:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029d4:	39 f3                	cmp    %esi,%ebx
f01029d6:	75 cf                	jne    f01029a7 <mem_init+0x1547>
f01029d8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01029db:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01029e2:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01029e9:	81 c6 00 80 00 00    	add    $0x8000,%esi

	// check kernel stack

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
f01029ef:	b8 00 40 25 f0       	mov    $0xf0254000,%eax
f01029f4:	39 f0                	cmp    %esi,%eax
f01029f6:	0f 85 2c ff ff ff    	jne    f0102928 <mem_init+0x14c8>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029fc:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a01:	89 f8                	mov    %edi,%eax
f0102a03:	e8 d8 e1 ff ff       	call   f0100be0 <check_va2pa>
f0102a08:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a0b:	74 47                	je     f0102a54 <mem_init+0x15f4>
f0102a0d:	68 9c 72 10 f0       	push   $0xf010729c
f0102a12:	68 e7 73 10 f0       	push   $0xf01073e7
f0102a17:	68 08 05 00 00       	push   $0x508
f0102a1c:	68 c1 73 10 f0       	push   $0xf01073c1
f0102a21:	e8 6e d6 ff ff       	call   f0100094 <_panic>


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a26:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a2c:	83 fa 04             	cmp    $0x4,%edx
f0102a2f:	77 28                	ja     f0102a59 <mem_init+0x15f9>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a31:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a35:	0f 85 83 00 00 00    	jne    f0102abe <mem_init+0x165e>
f0102a3b:	68 c7 76 10 f0       	push   $0xf01076c7
f0102a40:	68 e7 73 10 f0       	push   $0xf01073e7
f0102a45:	68 13 05 00 00       	push   $0x513
f0102a4a:	68 c1 73 10 f0       	push   $0xf01073c1
f0102a4f:	e8 40 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a54:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a59:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a5e:	76 3f                	jbe    f0102a9f <mem_init+0x163f>
				assert(pgdir[i] & PTE_P);
f0102a60:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a63:	f6 c2 01             	test   $0x1,%dl
f0102a66:	75 19                	jne    f0102a81 <mem_init+0x1621>
f0102a68:	68 c7 76 10 f0       	push   $0xf01076c7
f0102a6d:	68 e7 73 10 f0       	push   $0xf01073e7
f0102a72:	68 17 05 00 00       	push   $0x517
f0102a77:	68 c1 73 10 f0       	push   $0xf01073c1
f0102a7c:	e8 13 d6 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a81:	f6 c2 02             	test   $0x2,%dl
f0102a84:	75 38                	jne    f0102abe <mem_init+0x165e>
f0102a86:	68 d8 76 10 f0       	push   $0xf01076d8
f0102a8b:	68 e7 73 10 f0       	push   $0xf01073e7
f0102a90:	68 18 05 00 00       	push   $0x518
f0102a95:	68 c1 73 10 f0       	push   $0xf01073c1
f0102a9a:	e8 f5 d5 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a9f:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102aa3:	74 19                	je     f0102abe <mem_init+0x165e>
f0102aa5:	68 e9 76 10 f0       	push   $0xf01076e9
f0102aaa:	68 e7 73 10 f0       	push   $0xf01073e7
f0102aaf:	68 1a 05 00 00       	push   $0x51a
f0102ab4:	68 c1 73 10 f0       	push   $0xf01073c1
f0102ab9:	e8 d6 d5 ff ff       	call   f0100094 <_panic>
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102abe:	83 c0 01             	add    $0x1,%eax
f0102ac1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ac6:	0f 86 5a ff ff ff    	jbe    f0102a26 <mem_init+0x15c6>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102acc:	83 ec 0c             	sub    $0xc,%esp
f0102acf:	68 cc 72 10 f0       	push   $0xf01072cc
f0102ad4:	e8 96 0d 00 00       	call   f010386f <cprintf>
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.

	lcr3(PADDR(kern_pgdir));
f0102ad9:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ade:	83 c4 10             	add    $0x10,%esp
f0102ae1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ae6:	77 15                	ja     f0102afd <mem_init+0x169d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ae8:	50                   	push   %eax
f0102ae9:	68 9c 64 10 f0       	push   $0xf010649c
f0102aee:	68 43 01 00 00       	push   $0x143
f0102af3:	68 c1 73 10 f0       	push   $0xf01073c1
f0102af8:	e8 97 d5 ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102afd:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b02:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b05:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b0a:	e8 35 e1 ff ff       	call   f0100c44 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b0f:	0f 20 c0             	mov    %cr0,%eax
f0102b12:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b15:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b1a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b1d:	83 ec 0c             	sub    $0xc,%esp
f0102b20:	6a 00                	push   $0x0
f0102b22:	e8 bb e4 ff ff       	call   f0100fe2 <page_alloc>
f0102b27:	89 c3                	mov    %eax,%ebx
f0102b29:	83 c4 10             	add    $0x10,%esp
f0102b2c:	85 c0                	test   %eax,%eax
f0102b2e:	75 19                	jne    f0102b49 <mem_init+0x16e9>
f0102b30:	68 ca 74 10 f0       	push   $0xf01074ca
f0102b35:	68 e7 73 10 f0       	push   $0xf01073e7
f0102b3a:	68 29 06 00 00       	push   $0x629
f0102b3f:	68 c1 73 10 f0       	push   $0xf01073c1
f0102b44:	e8 4b d5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b49:	83 ec 0c             	sub    $0xc,%esp
f0102b4c:	6a 00                	push   $0x0
f0102b4e:	e8 8f e4 ff ff       	call   f0100fe2 <page_alloc>
f0102b53:	89 c7                	mov    %eax,%edi
f0102b55:	83 c4 10             	add    $0x10,%esp
f0102b58:	85 c0                	test   %eax,%eax
f0102b5a:	75 19                	jne    f0102b75 <mem_init+0x1715>
f0102b5c:	68 e0 74 10 f0       	push   $0xf01074e0
f0102b61:	68 e7 73 10 f0       	push   $0xf01073e7
f0102b66:	68 2a 06 00 00       	push   $0x62a
f0102b6b:	68 c1 73 10 f0       	push   $0xf01073c1
f0102b70:	e8 1f d5 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b75:	83 ec 0c             	sub    $0xc,%esp
f0102b78:	6a 00                	push   $0x0
f0102b7a:	e8 63 e4 ff ff       	call   f0100fe2 <page_alloc>
f0102b7f:	89 c6                	mov    %eax,%esi
f0102b81:	83 c4 10             	add    $0x10,%esp
f0102b84:	85 c0                	test   %eax,%eax
f0102b86:	75 19                	jne    f0102ba1 <mem_init+0x1741>
f0102b88:	68 f6 74 10 f0       	push   $0xf01074f6
f0102b8d:	68 e7 73 10 f0       	push   $0xf01073e7
f0102b92:	68 2b 06 00 00       	push   $0x62b
f0102b97:	68 c1 73 10 f0       	push   $0xf01073c1
f0102b9c:	e8 f3 d4 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102ba1:	83 ec 0c             	sub    $0xc,%esp
f0102ba4:	53                   	push   %ebx
f0102ba5:	e8 f1 e4 ff ff       	call   f010109b <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102baa:	89 f8                	mov    %edi,%eax
f0102bac:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102bb2:	c1 f8 03             	sar    $0x3,%eax
f0102bb5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb8:	89 c2                	mov    %eax,%edx
f0102bba:	c1 ea 0c             	shr    $0xc,%edx
f0102bbd:	83 c4 10             	add    $0x10,%esp
f0102bc0:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102bc6:	72 12                	jb     f0102bda <mem_init+0x177a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bc8:	50                   	push   %eax
f0102bc9:	68 48 64 10 f0       	push   $0xf0106448
f0102bce:	6a 58                	push   $0x58
f0102bd0:	68 cd 73 10 f0       	push   $0xf01073cd
f0102bd5:	e8 ba d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bda:	83 ec 04             	sub    $0x4,%esp
f0102bdd:	68 00 10 00 00       	push   $0x1000
f0102be2:	6a 01                	push   $0x1
f0102be4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102be9:	50                   	push   %eax
f0102bea:	e8 b5 2a 00 00       	call   f01056a4 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bef:	89 f0                	mov    %esi,%eax
f0102bf1:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102bf7:	c1 f8 03             	sar    $0x3,%eax
f0102bfa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bfd:	89 c2                	mov    %eax,%edx
f0102bff:	c1 ea 0c             	shr    $0xc,%edx
f0102c02:	83 c4 10             	add    $0x10,%esp
f0102c05:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102c0b:	72 12                	jb     f0102c1f <mem_init+0x17bf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0d:	50                   	push   %eax
f0102c0e:	68 48 64 10 f0       	push   $0xf0106448
f0102c13:	6a 58                	push   $0x58
f0102c15:	68 cd 73 10 f0       	push   $0xf01073cd
f0102c1a:	e8 75 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c1f:	83 ec 04             	sub    $0x4,%esp
f0102c22:	68 00 10 00 00       	push   $0x1000
f0102c27:	6a 02                	push   $0x2
f0102c29:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c2e:	50                   	push   %eax
f0102c2f:	e8 70 2a 00 00       	call   f01056a4 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c34:	6a 02                	push   $0x2
f0102c36:	68 00 10 00 00       	push   $0x1000
f0102c3b:	57                   	push   %edi
f0102c3c:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102c42:	e8 4d e7 ff ff       	call   f0101394 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c47:	83 c4 20             	add    $0x20,%esp
f0102c4a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c4f:	74 19                	je     f0102c6a <mem_init+0x180a>
f0102c51:	68 c7 75 10 f0       	push   $0xf01075c7
f0102c56:	68 e7 73 10 f0       	push   $0xf01073e7
f0102c5b:	68 30 06 00 00       	push   $0x630
f0102c60:	68 c1 73 10 f0       	push   $0xf01073c1
f0102c65:	e8 2a d4 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c6a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c71:	01 01 01 
f0102c74:	74 19                	je     f0102c8f <mem_init+0x182f>
f0102c76:	68 ec 72 10 f0       	push   $0xf01072ec
f0102c7b:	68 e7 73 10 f0       	push   $0xf01073e7
f0102c80:	68 31 06 00 00       	push   $0x631
f0102c85:	68 c1 73 10 f0       	push   $0xf01073c1
f0102c8a:	e8 05 d4 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c8f:	6a 02                	push   $0x2
f0102c91:	68 00 10 00 00       	push   $0x1000
f0102c96:	56                   	push   %esi
f0102c97:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102c9d:	e8 f2 e6 ff ff       	call   f0101394 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ca2:	83 c4 10             	add    $0x10,%esp
f0102ca5:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cac:	02 02 02 
f0102caf:	74 19                	je     f0102cca <mem_init+0x186a>
f0102cb1:	68 10 73 10 f0       	push   $0xf0107310
f0102cb6:	68 e7 73 10 f0       	push   $0xf01073e7
f0102cbb:	68 33 06 00 00       	push   $0x633
f0102cc0:	68 c1 73 10 f0       	push   $0xf01073c1
f0102cc5:	e8 ca d3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102cca:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ccf:	74 19                	je     f0102cea <mem_init+0x188a>
f0102cd1:	68 e9 75 10 f0       	push   $0xf01075e9
f0102cd6:	68 e7 73 10 f0       	push   $0xf01073e7
f0102cdb:	68 34 06 00 00       	push   $0x634
f0102ce0:	68 c1 73 10 f0       	push   $0xf01073c1
f0102ce5:	e8 aa d3 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102cea:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cef:	74 19                	je     f0102d0a <mem_init+0x18aa>
f0102cf1:	68 53 76 10 f0       	push   $0xf0107653
f0102cf6:	68 e7 73 10 f0       	push   $0xf01073e7
f0102cfb:	68 35 06 00 00       	push   $0x635
f0102d00:	68 c1 73 10 f0       	push   $0xf01073c1
f0102d05:	e8 8a d3 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d0a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d11:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d14:	89 f0                	mov    %esi,%eax
f0102d16:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102d1c:	c1 f8 03             	sar    $0x3,%eax
f0102d1f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d22:	89 c2                	mov    %eax,%edx
f0102d24:	c1 ea 0c             	shr    $0xc,%edx
f0102d27:	3b 15 88 2e 21 f0    	cmp    0xf0212e88,%edx
f0102d2d:	72 12                	jb     f0102d41 <mem_init+0x18e1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d2f:	50                   	push   %eax
f0102d30:	68 48 64 10 f0       	push   $0xf0106448
f0102d35:	6a 58                	push   $0x58
f0102d37:	68 cd 73 10 f0       	push   $0xf01073cd
f0102d3c:	e8 53 d3 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d41:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d48:	03 03 03 
f0102d4b:	74 19                	je     f0102d66 <mem_init+0x1906>
f0102d4d:	68 34 73 10 f0       	push   $0xf0107334
f0102d52:	68 e7 73 10 f0       	push   $0xf01073e7
f0102d57:	68 37 06 00 00       	push   $0x637
f0102d5c:	68 c1 73 10 f0       	push   $0xf01073c1
f0102d61:	e8 2e d3 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d66:	83 ec 08             	sub    $0x8,%esp
f0102d69:	68 00 10 00 00       	push   $0x1000
f0102d6e:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0102d74:	e8 cd e5 ff ff       	call   f0101346 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d79:	83 c4 10             	add    $0x10,%esp
f0102d7c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d81:	74 19                	je     f0102d9c <mem_init+0x193c>
f0102d83:	68 21 76 10 f0       	push   $0xf0107621
f0102d88:	68 e7 73 10 f0       	push   $0xf01073e7
f0102d8d:	68 39 06 00 00       	push   $0x639
f0102d92:	68 c1 73 10 f0       	push   $0xf01073c1
f0102d97:	e8 f8 d2 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d9c:	8b 0d 8c 2e 21 f0    	mov    0xf0212e8c,%ecx
f0102da2:	8b 11                	mov    (%ecx),%edx
f0102da4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102daa:	89 d8                	mov    %ebx,%eax
f0102dac:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f0102db2:	c1 f8 03             	sar    $0x3,%eax
f0102db5:	c1 e0 0c             	shl    $0xc,%eax
f0102db8:	39 c2                	cmp    %eax,%edx
f0102dba:	74 19                	je     f0102dd5 <mem_init+0x1975>
f0102dbc:	68 8c 6c 10 f0       	push   $0xf0106c8c
f0102dc1:	68 e7 73 10 f0       	push   $0xf01073e7
f0102dc6:	68 3c 06 00 00       	push   $0x63c
f0102dcb:	68 c1 73 10 f0       	push   $0xf01073c1
f0102dd0:	e8 bf d2 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102dd5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102ddb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102de0:	74 19                	je     f0102dfb <mem_init+0x199b>
f0102de2:	68 d8 75 10 f0       	push   $0xf01075d8
f0102de7:	68 e7 73 10 f0       	push   $0xf01073e7
f0102dec:	68 3e 06 00 00       	push   $0x63e
f0102df1:	68 c1 73 10 f0       	push   $0xf01073c1
f0102df6:	e8 99 d2 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102dfb:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e01:	83 ec 0c             	sub    $0xc,%esp
f0102e04:	53                   	push   %ebx
f0102e05:	e8 91 e2 ff ff       	call   f010109b <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e0a:	c7 04 24 60 73 10 f0 	movl   $0xf0107360,(%esp)
f0102e11:	e8 59 0a 00 00       	call   f010386f <cprintf>
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
	//cprintf("here I put out the tag.\n");
}
f0102e16:	83 c4 10             	add    $0x10,%esp
f0102e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e1c:	5b                   	pop    %ebx
f0102e1d:	5e                   	pop    %esi
f0102e1e:	5f                   	pop    %edi
f0102e1f:	5d                   	pop    %ebp
f0102e20:	c3                   	ret    

f0102e21 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e21:	55                   	push   %ebp
f0102e22:	89 e5                	mov    %esp,%ebp
f0102e24:	57                   	push   %edi
f0102e25:	56                   	push   %esi
f0102e26:	53                   	push   %ebx
f0102e27:	83 ec 1c             	sub    $0x1c,%esp
f0102e2a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e2d:	8b 75 14             	mov    0x14(%ebp),%esi
	//the code is very bad written by myself.
	*/


	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102e30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e33:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102e39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e3c:	03 45 10             	add    0x10(%ebp),%eax
f0102e3f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102e44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102e4c:	eb 43                	jmp    f0102e91 <user_mem_check+0x70>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102e4e:	83 ec 04             	sub    $0x4,%esp
f0102e51:	6a 00                	push   $0x0
f0102e53:	53                   	push   %ebx
f0102e54:	ff 77 60             	pushl  0x60(%edi)
f0102e57:	e8 20 e3 ff ff       	call   f010117c <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102e5c:	83 c4 10             	add    $0x10,%esp
f0102e5f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e65:	77 10                	ja     f0102e77 <user_mem_check+0x56>
f0102e67:	85 c0                	test   %eax,%eax
f0102e69:	74 0c                	je     f0102e77 <user_mem_check+0x56>
f0102e6b:	8b 00                	mov    (%eax),%eax
f0102e6d:	a8 01                	test   $0x1,%al
f0102e6f:	74 06                	je     f0102e77 <user_mem_check+0x56>
f0102e71:	21 f0                	and    %esi,%eax
f0102e73:	39 c6                	cmp    %eax,%esi
f0102e75:	74 14                	je     f0102e8b <user_mem_check+0x6a>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102e77:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e7a:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102e7e:	89 1d 3c 22 21 f0    	mov    %ebx,0xf021223c
			return -E_FAULT;
f0102e84:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e89:	eb 10                	jmp    f0102e9b <user_mem_check+0x7a>

	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102e8b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e91:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e94:	72 b8                	jb     f0102e4e <user_mem_check+0x2d>
			return -E_FAULT;
		}
	}

//	cprintf("user_mem_check success va: %x, len: %x\n", va, len);	
	return 0;
f0102e96:	b8 00 00 00 00       	mov    $0x0,%eax


}
f0102e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e9e:	5b                   	pop    %ebx
f0102e9f:	5e                   	pop    %esi
f0102ea0:	5f                   	pop    %edi
f0102ea1:	5d                   	pop    %ebp
f0102ea2:	c3                   	ret    

f0102ea3 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102ea3:	55                   	push   %ebp
f0102ea4:	89 e5                	mov    %esp,%ebp
f0102ea6:	53                   	push   %ebx
f0102ea7:	83 ec 04             	sub    $0x4,%esp
f0102eaa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102ead:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eb0:	83 c8 04             	or     $0x4,%eax
f0102eb3:	50                   	push   %eax
f0102eb4:	ff 75 10             	pushl  0x10(%ebp)
f0102eb7:	ff 75 0c             	pushl  0xc(%ebp)
f0102eba:	53                   	push   %ebx
f0102ebb:	e8 61 ff ff ff       	call   f0102e21 <user_mem_check>
f0102ec0:	83 c4 10             	add    $0x10,%esp
f0102ec3:	85 c0                	test   %eax,%eax
f0102ec5:	79 21                	jns    f0102ee8 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102ec7:	83 ec 04             	sub    $0x4,%esp
f0102eca:	ff 35 3c 22 21 f0    	pushl  0xf021223c
f0102ed0:	ff 73 48             	pushl  0x48(%ebx)
f0102ed3:	68 8c 73 10 f0       	push   $0xf010738c
f0102ed8:	e8 92 09 00 00       	call   f010386f <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102edd:	89 1c 24             	mov    %ebx,(%esp)
f0102ee0:	e8 b4 06 00 00       	call   f0103599 <env_destroy>
f0102ee5:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ee8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102eeb:	c9                   	leave  
f0102eec:	c3                   	ret    

f0102eed <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102eed:	55                   	push   %ebp
f0102eee:	89 e5                	mov    %esp,%ebp
f0102ef0:	57                   	push   %edi
f0102ef1:	56                   	push   %esi
f0102ef2:	53                   	push   %ebx
f0102ef3:	83 ec 0c             	sub    $0xc,%esp
f0102ef6:	89 c7                	mov    %eax,%edi
		va+=PGSIZE;
	}
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
f0102ef8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102efe:	89 d6                	mov    %edx,%esi
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
f0102f00:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0102f06:	25 ff 0f 00 00       	and    $0xfff,%eax
f0102f0b:	8d 99 ff 1f 00 00    	lea    0x1fff(%ecx),%ebx
f0102f11:	29 c3                	sub    %eax,%ebx
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f13:	eb 5e                	jmp    f0102f73 <region_alloc+0x86>
	{
		pp = page_alloc(0);
f0102f15:	83 ec 0c             	sub    $0xc,%esp
f0102f18:	6a 00                	push   $0x0
f0102f1a:	e8 c3 e0 ff ff       	call   f0100fe2 <page_alloc>
 
		if(!pp)
f0102f1f:	83 c4 10             	add    $0x10,%esp
f0102f22:	85 c0                	test   %eax,%eax
f0102f24:	75 17                	jne    f0102f3d <region_alloc+0x50>
		{
			panic("region_alloc failed!\n");
f0102f26:	83 ec 04             	sub    $0x4,%esp
f0102f29:	68 f7 76 10 f0       	push   $0xf01076f7
f0102f2e:	68 57 01 00 00       	push   $0x157
f0102f33:	68 0d 77 10 f0       	push   $0xf010770d
f0102f38:	e8 57 d1 ff ff       	call   f0100094 <_panic>
		}
		ret = page_insert(e->env_pgdir,pp,va,PTE_U|PTE_W|PTE_P);
f0102f3d:	6a 07                	push   $0x7
f0102f3f:	56                   	push   %esi
f0102f40:	50                   	push   %eax
f0102f41:	ff 77 60             	pushl  0x60(%edi)
f0102f44:	e8 4b e4 ff ff       	call   f0101394 <page_insert>
 
		if(ret)
f0102f49:	83 c4 10             	add    $0x10,%esp
f0102f4c:	85 c0                	test   %eax,%eax
f0102f4e:	74 17                	je     f0102f67 <region_alloc+0x7a>
		{
			panic("region_alloc failed!\n");
f0102f50:	83 ec 04             	sub    $0x4,%esp
f0102f53:	68 f7 76 10 f0       	push   $0xf01076f7
f0102f58:	68 5d 01 00 00       	push   $0x15d
f0102f5d:	68 0d 77 10 f0       	push   $0xf010770d
f0102f62:	e8 2d d1 ff ff       	call   f0100094 <_panic>
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f67:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
f0102f6d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f73:	85 db                	test   %ebx,%ebx
f0102f75:	75 9e                	jne    f0102f15 <region_alloc+0x28>
			panic("region_alloc failed!\n");
		}
	}


}
f0102f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f7a:	5b                   	pop    %ebx
f0102f7b:	5e                   	pop    %esi
f0102f7c:	5f                   	pop    %edi
f0102f7d:	5d                   	pop    %ebp
f0102f7e:	c3                   	ret    

f0102f7f <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f7f:	55                   	push   %ebp
f0102f80:	89 e5                	mov    %esp,%ebp
f0102f82:	56                   	push   %esi
f0102f83:	53                   	push   %ebx
f0102f84:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f87:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;
//	cprintf("\t\tin envid2env.\n");
	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f8a:	85 c0                	test   %eax,%eax
f0102f8c:	75 1d                	jne    f0102fab <envid2env+0x2c>
		*env_store = curenv;
f0102f8e:	e8 33 2d 00 00       	call   f0105cc6 <cpunum>
f0102f93:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f96:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0102f9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f9f:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fa6:	e9 94 00 00 00       	jmp    f010303f <envid2env+0xc0>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102fab:	89 c3                	mov    %eax,%ebx
f0102fad:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fb3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fb6:	03 1d 44 22 21 f0    	add    0xf0212244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fbc:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102fc0:	74 05                	je     f0102fc7 <envid2env+0x48>
f0102fc2:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102fc5:	74 24                	je     f0102feb <envid2env+0x6c>
		cprintf("\t\t\tAAAAAwe are at e->env_id:%d == envid:%d\n",e->env_id,envid);
f0102fc7:	83 ec 04             	sub    $0x4,%esp
f0102fca:	50                   	push   %eax
f0102fcb:	ff 73 48             	pushl  0x48(%ebx)
f0102fce:	68 ac 77 10 f0       	push   $0xf01077ac
f0102fd3:	e8 97 08 00 00       	call   f010386f <cprintf>
		*env_store = 0;
f0102fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fdb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fe1:	83 c4 10             	add    $0x10,%esp
f0102fe4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fe9:	eb 54                	jmp    f010303f <envid2env+0xc0>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102feb:	84 d2                	test   %dl,%dl
f0102fed:	74 46                	je     f0103035 <envid2env+0xb6>
f0102fef:	e8 d2 2c 00 00       	call   f0105cc6 <cpunum>
f0102ff4:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ff7:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f0102ffd:	74 36                	je     f0103035 <envid2env+0xb6>
f0102fff:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103002:	e8 bf 2c 00 00       	call   f0105cc6 <cpunum>
f0103007:	6b c0 74             	imul   $0x74,%eax,%eax
f010300a:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103010:	3b 70 48             	cmp    0x48(%eax),%esi
f0103013:	74 20                	je     f0103035 <envid2env+0xb6>
		cprintf("\t\t\tBBBBin checkperm.\n");
f0103015:	83 ec 0c             	sub    $0xc,%esp
f0103018:	68 18 77 10 f0       	push   $0xf0107718
f010301d:	e8 4d 08 00 00       	call   f010386f <cprintf>
		*env_store = 0;
f0103022:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103025:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010302b:	83 c4 10             	add    $0x10,%esp
f010302e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103033:	eb 0a                	jmp    f010303f <envid2env+0xc0>
	}

	*env_store = e;
f0103035:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103038:	89 18                	mov    %ebx,(%eax)
	return 0;
f010303a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010303f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103042:	5b                   	pop    %ebx
f0103043:	5e                   	pop    %esi
f0103044:	5d                   	pop    %ebp
f0103045:	c3                   	ret    

f0103046 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103046:	55                   	push   %ebp
f0103047:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103049:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f010304e:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103051:	b8 23 00 00 00       	mov    $0x23,%eax
f0103056:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103058:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010305a:	b8 10 00 00 00       	mov    $0x10,%eax
f010305f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103061:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103063:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103065:	ea 6c 30 10 f0 08 00 	ljmp   $0x8,$0xf010306c
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010306c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103071:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103074:	5d                   	pop    %ebp
f0103075:	c3                   	ret    

f0103076 <env_init>:
};
*/

void
env_init(void)
{
f0103076:	55                   	push   %ebp
f0103077:	89 e5                	mov    %esp,%ebp
f0103079:	56                   	push   %esi
f010307a:	53                   	push   %ebx
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
	{
		envs[temp].env_id = 0;
f010307b:	8b 35 44 22 21 f0    	mov    0xf0212244,%esi
f0103081:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103087:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010308a:	ba 00 00 00 00       	mov    $0x0,%edx
f010308f:	89 c1                	mov    %eax,%ecx
f0103091:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[temp].env_parent_id = 0;
f0103098:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		envs[temp].env_type = ENV_TYPE_USER;
f010309f:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		envs[temp].env_status = 0;
f01030a6:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[temp].env_runs = 0;
f01030ad:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
		envs[temp].env_pgdir = NULL;
f01030b4:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
		envs[temp].env_link = env_free_list;
f01030bb:	89 50 44             	mov    %edx,0x44(%eax)
f01030be:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[temp];
f01030c1:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
f01030c3:	39 d8                	cmp    %ebx,%eax
f01030c5:	75 c8                	jne    f010308f <env_init+0x19>
f01030c7:	89 35 48 22 21 f0    	mov    %esi,0xf0212248
		envs[temp].env_pgdir = NULL;
		envs[temp].env_link = env_free_list;
		env_free_list = &envs[temp];
	}
 
	cprintf("env_free_list : 0x%08x, &envs[temp]: 0x%08x\n",env_free_list,&envs[temp]);
f01030cd:	83 ec 04             	sub    $0x4,%esp
f01030d0:	a1 44 22 21 f0       	mov    0xf0212244,%eax
f01030d5:	83 e8 7c             	sub    $0x7c,%eax
f01030d8:	50                   	push   %eax
f01030d9:	56                   	push   %esi
f01030da:	68 d8 77 10 f0       	push   $0xf01077d8
f01030df:	e8 8b 07 00 00       	call   f010386f <cprintf>
 

	// Per-CPU part of the initialization
	env_init_percpu();
f01030e4:	e8 5d ff ff ff       	call   f0103046 <env_init_percpu>
}
f01030e9:	83 c4 10             	add    $0x10,%esp
f01030ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030ef:	5b                   	pop    %ebx
f01030f0:	5e                   	pop    %esi
f01030f1:	5d                   	pop    %ebp
f01030f2:	c3                   	ret    

f01030f3 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030f3:	55                   	push   %ebp
f01030f4:	89 e5                	mov    %esp,%ebp
f01030f6:	57                   	push   %edi
f01030f7:	56                   	push   %esi
f01030f8:	53                   	push   %ebx
f01030f9:	83 ec 0c             	sub    $0xc,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01030fc:	8b 1d 48 22 21 f0    	mov    0xf0212248,%ebx
f0103102:	85 db                	test   %ebx,%ebx
f0103104:	0f 84 64 01 00 00    	je     f010326e <env_alloc+0x17b>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010310a:	83 ec 0c             	sub    $0xc,%esp
f010310d:	6a 01                	push   $0x1
f010310f:	e8 ce de ff ff       	call   f0100fe2 <page_alloc>
f0103114:	83 c4 10             	add    $0x10,%esp
f0103117:	85 c0                	test   %eax,%eax
f0103119:	0f 84 56 01 00 00    	je     f0103275 <env_alloc+0x182>

	
	// LAB 3: Your code here.

	//!copy from web ,just to know how it runs.
	(p->pp_ref)++;
f010311f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103124:	2b 05 90 2e 21 f0    	sub    0xf0212e90,%eax
f010312a:	89 c6                	mov    %eax,%esi
f010312c:	c1 fe 03             	sar    $0x3,%esi
f010312f:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103132:	89 f0                	mov    %esi,%eax
f0103134:	c1 e8 0c             	shr    $0xc,%eax
f0103137:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f010313d:	72 12                	jb     f0103151 <env_alloc+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010313f:	56                   	push   %esi
f0103140:	68 48 64 10 f0       	push   $0xf0106448
f0103145:	6a 58                	push   $0x58
f0103147:	68 cd 73 10 f0       	push   $0xf01073cd
f010314c:	e8 43 cf ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0103151:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
        pde_t* page_dir = page2kva(p);
	memcpy(page_dir,kern_pgdir,PGSIZE);
f0103157:	83 ec 04             	sub    $0x4,%esp
f010315a:	68 00 10 00 00       	push   $0x1000
f010315f:	ff 35 8c 2e 21 f0    	pushl  0xf0212e8c
f0103165:	57                   	push   %edi
f0103166:	e8 ee 25 00 00       	call   f0105759 <memcpy>
	e->env_pgdir = page_dir;
f010316b:	89 7b 60             	mov    %edi,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010316e:	83 c4 10             	add    $0x10,%esp
f0103171:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0103177:	77 15                	ja     f010318e <env_alloc+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103179:	57                   	push   %edi
f010317a:	68 9c 64 10 f0       	push   $0xf010649c
f010317f:	68 e6 00 00 00       	push   $0xe6
f0103184:	68 0d 77 10 f0       	push   $0xf010770d
f0103189:	e8 06 cf ff ff       	call   f0100094 <_panic>
	
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010318e:	83 ce 05             	or     $0x5,%esi
f0103191:	89 b7 f4 0e 00 00    	mov    %esi,0xef4(%edi)

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103197:	8b 43 48             	mov    0x48(%ebx),%eax
f010319a:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010319f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031a4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031a9:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031ac:	89 da                	mov    %ebx,%edx
f01031ae:	2b 15 44 22 21 f0    	sub    0xf0212244,%edx
f01031b4:	c1 fa 02             	sar    $0x2,%edx
f01031b7:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031bd:	09 d0                	or     %edx,%eax
f01031bf:	89 43 48             	mov    %eax,0x48(%ebx)
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031c5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031c8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031cf:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031d6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031dd:	83 ec 04             	sub    $0x4,%esp
f01031e0:	6a 44                	push   $0x44
f01031e2:	6a 00                	push   $0x0
f01031e4:	53                   	push   %ebx
f01031e5:	e8 ba 24 00 00       	call   f01056a4 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031ea:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031f0:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031f6:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031fc:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103203:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103209:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103210:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103217:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010321b:	8b 43 44             	mov    0x44(%ebx),%eax
f010321e:	a3 48 22 21 f0       	mov    %eax,0xf0212248
	*newenv_store = e;
f0103223:	8b 45 08             	mov    0x8(%ebp),%eax
f0103226:	89 18                	mov    %ebx,(%eax)


	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103228:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010322b:	e8 96 2a 00 00       	call   f0105cc6 <cpunum>
f0103230:	6b c0 74             	imul   $0x74,%eax,%eax
f0103233:	83 c4 10             	add    $0x10,%esp
f0103236:	ba 00 00 00 00       	mov    $0x0,%edx
f010323b:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0103242:	74 11                	je     f0103255 <env_alloc+0x162>
f0103244:	e8 7d 2a 00 00       	call   f0105cc6 <cpunum>
f0103249:	6b c0 74             	imul   $0x74,%eax,%eax
f010324c:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103252:	8b 50 48             	mov    0x48(%eax),%edx
f0103255:	83 ec 04             	sub    $0x4,%esp
f0103258:	53                   	push   %ebx
f0103259:	52                   	push   %edx
f010325a:	68 2e 77 10 f0       	push   $0xf010772e
f010325f:	e8 0b 06 00 00       	call   f010386f <cprintf>

	return 0;
f0103264:	83 c4 10             	add    $0x10,%esp
f0103267:	b8 00 00 00 00       	mov    $0x0,%eax
f010326c:	eb 0c                	jmp    f010327a <env_alloc+0x187>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010326e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103273:	eb 05                	jmp    f010327a <env_alloc+0x187>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103275:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	return 0;
}
f010327a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010327d:	5b                   	pop    %ebx
f010327e:	5e                   	pop    %esi
f010327f:	5f                   	pop    %edi
f0103280:	5d                   	pop    %ebp
f0103281:	c3                   	ret    

f0103282 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103282:	55                   	push   %ebp
f0103283:	89 e5                	mov    %esp,%ebp
f0103285:	57                   	push   %edi
f0103286:	56                   	push   %esi
f0103287:	53                   	push   %ebx
f0103288:	83 ec 34             	sub    $0x34,%esp
f010328b:	8b 7d 08             	mov    0x8(%ebp),%edi


	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	int ret = 0;
	struct Env * e = NULL;	
f010328e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	

	ret = env_alloc(&e,0);
f0103295:	6a 00                	push   $0x0
f0103297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010329a:	50                   	push   %eax
f010329b:	e8 53 fe ff ff       	call   f01030f3 <env_alloc>
	//panic("panic at env_alloc().\n");
	if(ret < 0){
f01032a0:	83 c4 10             	add    $0x10,%esp
f01032a3:	85 c0                	test   %eax,%eax
f01032a5:	79 15                	jns    f01032bc <env_create+0x3a>
		panic("env_create:%e\n",ret);
f01032a7:	50                   	push   %eax
f01032a8:	68 43 77 10 f0       	push   $0xf0107743
f01032ad:	68 d9 01 00 00       	push   $0x1d9
f01032b2:	68 0d 77 10 f0       	push   $0xf010770d
f01032b7:	e8 d8 cd ff ff       	call   f0100094 <_panic>
	}
	load_icode(e,binary);
f01032bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Proghdr *ph,*eph;
	struct Elf * ELFHDR = ((struct Elf*)binary);
	
	if(ELFHDR->e_magic != ELF_MAGIC){
f01032c2:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032c8:	74 17                	je     f01032e1 <env_create+0x5f>
		panic("This is not a valid file.\n");
f01032ca:	83 ec 04             	sub    $0x4,%esp
f01032cd:	68 52 77 10 f0       	push   $0xf0107752
f01032d2:	68 9e 01 00 00       	push   $0x19e
f01032d7:	68 0d 77 10 f0       	push   $0xf010770d
f01032dc:	e8 b3 cd ff ff       	call   f0100094 <_panic>
	}
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
f01032e1:	89 fb                	mov    %edi,%ebx
f01032e3:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph+ELFHDR->e_phnum;
f01032e6:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032ea:	c1 e6 05             	shl    $0x5,%esi
f01032ed:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f01032ef:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032f2:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032f5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032fa:	77 15                	ja     f0103311 <env_create+0x8f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032fc:	50                   	push   %eax
f01032fd:	68 9c 64 10 f0       	push   $0xf010649c
f0103302:	68 a3 01 00 00       	push   $0x1a3
f0103307:	68 0d 77 10 f0       	push   $0xf010770d
f010330c:	e8 83 cd ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103311:	05 00 00 00 10       	add    $0x10000000,%eax
f0103316:	0f 22 d8             	mov    %eax,%cr3
f0103319:	eb 60                	jmp    f010337b <env_create+0xf9>

	for(;ph<eph;ph++){

		if(ph->p_type != ELF_PROG_LOAD)
f010331b:	83 3b 01             	cmpl   $0x1,(%ebx)
f010331e:	75 58                	jne    f0103378 <env_create+0xf6>
		{
			continue;
		}
 
		if(ph->p_filesz > ph->p_memsz)
f0103320:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103323:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103326:	76 17                	jbe    f010333f <env_create+0xbd>
		{
			panic("file size is great than memory size\n");
f0103328:	83 ec 04             	sub    $0x4,%esp
f010332b:	68 08 78 10 f0       	push   $0xf0107808
f0103330:	68 ae 01 00 00       	push   $0x1ae
f0103335:	68 0d 77 10 f0       	push   $0xf010770d
f010333a:	e8 55 cd ff ff       	call   f0100094 <_panic>
		}
		//cprintf("ph->p_memsz:0x%x\n",ph->p_memsz); 
		region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f010333f:	8b 53 08             	mov    0x8(%ebx),%edx
f0103342:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103345:	e8 a3 fb ff ff       	call   f0102eed <region_alloc>
		//cprintf("DES:0x%x,SRC:0x%x\n",ph->p_va,binary+ph->p_offset);
		//cprintf("ph->filesz:0x%x\n",ph->p_filesz);
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f010334a:	83 ec 04             	sub    $0x4,%esp
f010334d:	ff 73 10             	pushl  0x10(%ebx)
f0103350:	89 f8                	mov    %edi,%eax
f0103352:	03 43 04             	add    0x4(%ebx),%eax
f0103355:	50                   	push   %eax
f0103356:	ff 73 08             	pushl  0x8(%ebx)
f0103359:	e8 93 23 00 00       	call   f01056f1 <memmove>
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
f010335e:	8b 43 10             	mov    0x10(%ebx),%eax
f0103361:	83 c4 0c             	add    $0xc,%esp
f0103364:	8b 53 14             	mov    0x14(%ebx),%edx
f0103367:	29 c2                	sub    %eax,%edx
f0103369:	52                   	push   %edx
f010336a:	6a 00                	push   $0x0
f010336c:	03 43 08             	add    0x8(%ebx),%eax
f010336f:	50                   	push   %eax
f0103370:	e8 2f 23 00 00       	call   f01056a4 <memset>
f0103375:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
	eph = ph+ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	for(;ph<eph;ph++){
f0103378:	83 c3 20             	add    $0x20,%ebx
f010337b:	39 de                	cmp    %ebx,%esi
f010337d:	77 9c                	ja     f010331b <env_create+0x99>
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
	}


	e->env_tf.tf_eip = ELFHDR->e_entry;
f010337f:	8b 47 18             	mov    0x18(%edi),%eax
f0103382:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103385:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	lcr3(PADDR(kern_pgdir));
f0103388:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010338d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103392:	77 15                	ja     f01033a9 <env_create+0x127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103394:	50                   	push   %eax
f0103395:	68 9c 64 10 f0       	push   $0xf010649c
f010339a:	68 bd 01 00 00       	push   $0x1bd
f010339f:	68 0d 77 10 f0       	push   $0xf010770d
f01033a4:	e8 eb cc ff ff       	call   f0100094 <_panic>
f01033a9:	05 00 00 00 10       	add    $0x10000000,%eax
f01033ae:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e,(void *)USTACKTOP-PGSIZE,(size_t)PGSIZE);	
f01033b1:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033b6:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033be:	e8 2a fb ff ff       	call   f0102eed <region_alloc>
	if(ret < 0){
		panic("env_create:%e\n",ret);
	}
	load_icode(e,binary);
	//panic("panic in the load_icode.\n");
	e->env_type = type;
f01033c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01033c9:	89 78 50             	mov    %edi,0x50(%eax)
	if(type == ENV_TYPE_FS)
f01033cc:	83 ff 01             	cmp    $0x1,%edi
f01033cf:	75 07                	jne    f01033d8 <env_create+0x156>
	{
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f01033d1:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
	cprintf("THE new created e->env_id is:%xn",e->env_id);
f01033d8:	83 ec 08             	sub    $0x8,%esp
f01033db:	ff 70 48             	pushl  0x48(%eax)
f01033de:	68 30 78 10 f0       	push   $0xf0107830
f01033e3:	e8 87 04 00 00       	call   f010386f <cprintf>

}
f01033e8:	83 c4 10             	add    $0x10,%esp
f01033eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ee:	5b                   	pop    %ebx
f01033ef:	5e                   	pop    %esi
f01033f0:	5f                   	pop    %edi
f01033f1:	5d                   	pop    %ebp
f01033f2:	c3                   	ret    

f01033f3 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033f3:	55                   	push   %ebp
f01033f4:	89 e5                	mov    %esp,%ebp
f01033f6:	57                   	push   %edi
f01033f7:	56                   	push   %esi
f01033f8:	53                   	push   %ebx
f01033f9:	83 ec 1c             	sub    $0x1c,%esp
f01033fc:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033ff:	e8 c2 28 00 00       	call   f0105cc6 <cpunum>
f0103404:	6b c0 74             	imul   $0x74,%eax,%eax
f0103407:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010340e:	39 b8 28 30 21 f0    	cmp    %edi,-0xfdecfd8(%eax)
f0103414:	75 30                	jne    f0103446 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103416:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010341b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103420:	77 15                	ja     f0103437 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103422:	50                   	push   %eax
f0103423:	68 9c 64 10 f0       	push   $0xf010649c
f0103428:	68 f4 01 00 00       	push   $0x1f4
f010342d:	68 0d 77 10 f0       	push   $0xf010770d
f0103432:	e8 5d cc ff ff       	call   f0100094 <_panic>
f0103437:	05 00 00 00 10       	add    $0x10000000,%eax
f010343c:	0f 22 d8             	mov    %eax,%cr3
f010343f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103446:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103449:	89 d0                	mov    %edx,%eax
f010344b:	c1 e0 02             	shl    $0x2,%eax
f010344e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103451:	8b 47 60             	mov    0x60(%edi),%eax
f0103454:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103457:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010345d:	0f 84 a8 00 00 00    	je     f010350b <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103463:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103469:	89 f0                	mov    %esi,%eax
f010346b:	c1 e8 0c             	shr    $0xc,%eax
f010346e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103471:	39 05 88 2e 21 f0    	cmp    %eax,0xf0212e88
f0103477:	77 15                	ja     f010348e <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103479:	56                   	push   %esi
f010347a:	68 48 64 10 f0       	push   $0xf0106448
f010347f:	68 03 02 00 00       	push   $0x203
f0103484:	68 0d 77 10 f0       	push   $0xf010770d
f0103489:	e8 06 cc ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010348e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103491:	c1 e0 16             	shl    $0x16,%eax
f0103494:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103497:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010349c:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034a3:	01 
f01034a4:	74 17                	je     f01034bd <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034a6:	83 ec 08             	sub    $0x8,%esp
f01034a9:	89 d8                	mov    %ebx,%eax
f01034ab:	c1 e0 0c             	shl    $0xc,%eax
f01034ae:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034b1:	50                   	push   %eax
f01034b2:	ff 77 60             	pushl  0x60(%edi)
f01034b5:	e8 8c de ff ff       	call   f0101346 <page_remove>
f01034ba:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034bd:	83 c3 01             	add    $0x1,%ebx
f01034c0:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034c6:	75 d4                	jne    f010349c <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034c8:	8b 47 60             	mov    0x60(%edi),%eax
f01034cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034ce:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034d8:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f01034de:	72 14                	jb     f01034f4 <env_free+0x101>
		panic("pa2page called with invalid pa");
f01034e0:	83 ec 04             	sub    $0x4,%esp
f01034e3:	68 58 6b 10 f0       	push   $0xf0106b58
f01034e8:	6a 51                	push   $0x51
f01034ea:	68 cd 73 10 f0       	push   $0xf01073cd
f01034ef:	e8 a0 cb ff ff       	call   f0100094 <_panic>
		page_decref(pa2page(pa));
f01034f4:	83 ec 0c             	sub    $0xc,%esp
f01034f7:	a1 90 2e 21 f0       	mov    0xf0212e90,%eax
f01034fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034ff:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103502:	50                   	push   %eax
f0103503:	e8 4d dc ff ff       	call   f0101155 <page_decref>
f0103508:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010350b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010350f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103512:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103517:	0f 85 29 ff ff ff    	jne    f0103446 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010351d:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103520:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103525:	77 15                	ja     f010353c <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103527:	50                   	push   %eax
f0103528:	68 9c 64 10 f0       	push   $0xf010649c
f010352d:	68 11 02 00 00       	push   $0x211
f0103532:	68 0d 77 10 f0       	push   $0xf010770d
f0103537:	e8 58 cb ff ff       	call   f0100094 <_panic>
	e->env_pgdir = 0;
f010353c:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103543:	05 00 00 00 10       	add    $0x10000000,%eax
f0103548:	c1 e8 0c             	shr    $0xc,%eax
f010354b:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0103551:	72 14                	jb     f0103567 <env_free+0x174>
		panic("pa2page called with invalid pa");
f0103553:	83 ec 04             	sub    $0x4,%esp
f0103556:	68 58 6b 10 f0       	push   $0xf0106b58
f010355b:	6a 51                	push   $0x51
f010355d:	68 cd 73 10 f0       	push   $0xf01073cd
f0103562:	e8 2d cb ff ff       	call   f0100094 <_panic>
	page_decref(pa2page(pa));
f0103567:	83 ec 0c             	sub    $0xc,%esp
f010356a:	8b 15 90 2e 21 f0    	mov    0xf0212e90,%edx
f0103570:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103573:	50                   	push   %eax
f0103574:	e8 dc db ff ff       	call   f0101155 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103579:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103580:	a1 48 22 21 f0       	mov    0xf0212248,%eax
f0103585:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103588:	89 3d 48 22 21 f0    	mov    %edi,0xf0212248
//	cprintf("in the env_free function.\n");
}
f010358e:	83 c4 10             	add    $0x10,%esp
f0103591:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103594:	5b                   	pop    %ebx
f0103595:	5e                   	pop    %esi
f0103596:	5f                   	pop    %edi
f0103597:	5d                   	pop    %ebp
f0103598:	c3                   	ret    

f0103599 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103599:	55                   	push   %ebp
f010359a:	89 e5                	mov    %esp,%ebp
f010359c:	53                   	push   %ebx
f010359d:	83 ec 04             	sub    $0x4,%esp
f01035a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035a3:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035a7:	75 19                	jne    f01035c2 <env_destroy+0x29>
f01035a9:	e8 18 27 00 00       	call   f0105cc6 <cpunum>
f01035ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01035b1:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f01035b7:	74 09                	je     f01035c2 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035b9:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035c0:	eb 4c                	jmp    f010360e <env_destroy+0x75>
	}

	env_free(e);
f01035c2:	83 ec 0c             	sub    $0xc,%esp
f01035c5:	53                   	push   %ebx
f01035c6:	e8 28 fe ff ff       	call   f01033f3 <env_free>
	cprintf("after we env_free the env.\n");
f01035cb:	c7 04 24 6d 77 10 f0 	movl   $0xf010776d,(%esp)
f01035d2:	e8 98 02 00 00       	call   f010386f <cprintf>
	if (curenv == e) {
f01035d7:	e8 ea 26 00 00       	call   f0105cc6 <cpunum>
f01035dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01035df:	83 c4 10             	add    $0x10,%esp
f01035e2:	3b 98 28 30 21 f0    	cmp    -0xfdecfd8(%eax),%ebx
f01035e8:	75 24                	jne    f010360e <env_destroy+0x75>
		cprintf("going to sched_yield.\n");
f01035ea:	83 ec 0c             	sub    $0xc,%esp
f01035ed:	68 89 77 10 f0       	push   $0xf0107789
f01035f2:	e8 78 02 00 00       	call   f010386f <cprintf>
		curenv = NULL;
f01035f7:	e8 ca 26 00 00       	call   f0105cc6 <cpunum>
f01035fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ff:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f0103606:	00 00 00 
		sched_yield();
f0103609:	e8 d3 0e 00 00       	call   f01044e1 <sched_yield>
	}
}
f010360e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103611:	c9                   	leave  
f0103612:	c3                   	ret    

f0103613 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103613:	55                   	push   %ebp
f0103614:	89 e5                	mov    %esp,%ebp
f0103616:	53                   	push   %ebx
f0103617:	83 ec 04             	sub    $0x4,%esp

	// Record the CPU we are running on for user-space debugging

	curenv->env_cpunum = cpunum();
f010361a:	e8 a7 26 00 00       	call   f0105cc6 <cpunum>
f010361f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103622:	8b 98 28 30 21 f0    	mov    -0xfdecfd8(%eax),%ebx
f0103628:	e8 99 26 00 00       	call   f0105cc6 <cpunum>
f010362d:	89 43 5c             	mov    %eax,0x5c(%ebx)
//	cprintf("doing env_pop_tf .\n");
//	cprintf("marked.\n");
	asm volatile(
f0103630:	8b 65 08             	mov    0x8(%ebp),%esp
f0103633:	61                   	popa   
f0103634:	07                   	pop    %es
f0103635:	1f                   	pop    %ds
f0103636:	83 c4 08             	add    $0x8,%esp
f0103639:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010363a:	83 ec 04             	sub    $0x4,%esp
f010363d:	68 a0 77 10 f0       	push   $0xf01077a0
f0103642:	68 4d 02 00 00       	push   $0x24d
f0103647:	68 0d 77 10 f0       	push   $0xf010770d
f010364c:	e8 43 ca ff ff       	call   f0100094 <_panic>

f0103651 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103651:	55                   	push   %ebp
f0103652:	89 e5                	mov    %esp,%ebp
f0103654:	53                   	push   %ebx
f0103655:	83 ec 04             	sub    $0x4,%esp
f0103658:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.

//	cprintf("		We are going to run a env.\n");

	if(curenv && curenv->env_status == ENV_RUNNING)
f010365b:	e8 66 26 00 00       	call   f0105cc6 <cpunum>
f0103660:	6b c0 74             	imul   $0x74,%eax,%eax
f0103663:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f010366a:	74 29                	je     f0103695 <env_run+0x44>
f010366c:	e8 55 26 00 00       	call   f0105cc6 <cpunum>
f0103671:	6b c0 74             	imul   $0x74,%eax,%eax
f0103674:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010367a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010367e:	75 15                	jne    f0103695 <env_run+0x44>
	{
			curenv->env_status = ENV_RUNNABLE;
f0103680:	e8 41 26 00 00       	call   f0105cc6 <cpunum>
f0103685:	6b c0 74             	imul   $0x74,%eax,%eax
f0103688:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010368e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
//	cprintf("at env_run() start.\n"); 

	curenv = e;
f0103695:	e8 2c 26 00 00       	call   f0105cc6 <cpunum>
f010369a:	6b c0 74             	imul   $0x74,%eax,%eax
f010369d:	89 98 28 30 21 f0    	mov    %ebx,-0xfdecfd8(%eax)
	e->env_status = ENV_RUNNING;
f01036a3:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f01036aa:	83 43 58 01          	addl   $0x1,0x58(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036ae:	83 ec 0c             	sub    $0xc,%esp
f01036b1:	68 c0 03 12 f0       	push   $0xf01203c0
f01036b6:	e8 16 29 00 00       	call   f0105fd1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036bb:	f3 90                	pause  
	unlock_kernel();
//	cprintf("at env_run() unlock_kernel.\n");
	lcr3(PADDR(e->env_pgdir));	
f01036bd:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036c0:	83 c4 10             	add    $0x10,%esp
f01036c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036c8:	77 15                	ja     f01036df <env_run+0x8e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036ca:	50                   	push   %eax
f01036cb:	68 9c 64 10 f0       	push   $0xf010649c
f01036d0:	68 79 02 00 00       	push   $0x279
f01036d5:	68 0d 77 10 f0       	push   $0xf010770d
f01036da:	e8 b5 c9 ff ff       	call   f0100094 <_panic>
f01036df:	05 00 00 00 10       	add    $0x10000000,%eax
f01036e4:	0f 22 d8             	mov    %eax,%cr3
//	cprintf("at env_run() access e->env_pgdir.\n");
	env_pop_tf(&(e->env_tf));
f01036e7:	83 ec 0c             	sub    $0xc,%esp
f01036ea:	53                   	push   %ebx
f01036eb:	e8 23 ff ff ff       	call   f0103613 <env_pop_tf>

f01036f0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036f0:	55                   	push   %ebp
f01036f1:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036f3:	ba 70 00 00 00       	mov    $0x70,%edx
f01036f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01036fb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036fc:	ba 71 00 00 00       	mov    $0x71,%edx
f0103701:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103702:	0f b6 c0             	movzbl %al,%eax
}
f0103705:	5d                   	pop    %ebp
f0103706:	c3                   	ret    

f0103707 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103707:	55                   	push   %ebp
f0103708:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010370a:	ba 70 00 00 00       	mov    $0x70,%edx
f010370f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103712:	ee                   	out    %al,(%dx)
f0103713:	ba 71 00 00 00       	mov    $0x71,%edx
f0103718:	8b 45 0c             	mov    0xc(%ebp),%eax
f010371b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010371c:	5d                   	pop    %ebp
f010371d:	c3                   	ret    

f010371e <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010371e:	55                   	push   %ebp
f010371f:	89 e5                	mov    %esp,%ebp
f0103721:	56                   	push   %esi
f0103722:	53                   	push   %ebx
f0103723:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103726:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f010372c:	80 3d 4c 22 21 f0 00 	cmpb   $0x0,0xf021224c
f0103733:	74 5a                	je     f010378f <irq_setmask_8259A+0x71>
f0103735:	89 c6                	mov    %eax,%esi
f0103737:	ba 21 00 00 00       	mov    $0x21,%edx
f010373c:	ee                   	out    %al,(%dx)
f010373d:	66 c1 e8 08          	shr    $0x8,%ax
f0103741:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103746:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103747:	83 ec 0c             	sub    $0xc,%esp
f010374a:	68 51 78 10 f0       	push   $0xf0107851
f010374f:	e8 1b 01 00 00       	call   f010386f <cprintf>
f0103754:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103757:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010375c:	0f b7 f6             	movzwl %si,%esi
f010375f:	f7 d6                	not    %esi
f0103761:	0f a3 de             	bt     %ebx,%esi
f0103764:	73 11                	jae    f0103777 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103766:	83 ec 08             	sub    $0x8,%esp
f0103769:	53                   	push   %ebx
f010376a:	68 17 7e 10 f0       	push   $0xf0107e17
f010376f:	e8 fb 00 00 00       	call   f010386f <cprintf>
f0103774:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103777:	83 c3 01             	add    $0x1,%ebx
f010377a:	83 fb 10             	cmp    $0x10,%ebx
f010377d:	75 e2                	jne    f0103761 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010377f:	83 ec 0c             	sub    $0xc,%esp
f0103782:	68 84 67 10 f0       	push   $0xf0106784
f0103787:	e8 e3 00 00 00       	call   f010386f <cprintf>
f010378c:	83 c4 10             	add    $0x10,%esp
}
f010378f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103792:	5b                   	pop    %ebx
f0103793:	5e                   	pop    %esi
f0103794:	5d                   	pop    %ebp
f0103795:	c3                   	ret    

f0103796 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103796:	c6 05 4c 22 21 f0 01 	movb   $0x1,0xf021224c
f010379d:	ba 21 00 00 00       	mov    $0x21,%edx
f01037a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037a7:	ee                   	out    %al,(%dx)
f01037a8:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037ad:	ee                   	out    %al,(%dx)
f01037ae:	ba 20 00 00 00       	mov    $0x20,%edx
f01037b3:	b8 11 00 00 00       	mov    $0x11,%eax
f01037b8:	ee                   	out    %al,(%dx)
f01037b9:	ba 21 00 00 00       	mov    $0x21,%edx
f01037be:	b8 20 00 00 00       	mov    $0x20,%eax
f01037c3:	ee                   	out    %al,(%dx)
f01037c4:	b8 04 00 00 00       	mov    $0x4,%eax
f01037c9:	ee                   	out    %al,(%dx)
f01037ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01037cf:	ee                   	out    %al,(%dx)
f01037d0:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037d5:	b8 11 00 00 00       	mov    $0x11,%eax
f01037da:	ee                   	out    %al,(%dx)
f01037db:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037e0:	b8 28 00 00 00       	mov    $0x28,%eax
f01037e5:	ee                   	out    %al,(%dx)
f01037e6:	b8 02 00 00 00       	mov    $0x2,%eax
f01037eb:	ee                   	out    %al,(%dx)
f01037ec:	b8 01 00 00 00       	mov    $0x1,%eax
f01037f1:	ee                   	out    %al,(%dx)
f01037f2:	ba 20 00 00 00       	mov    $0x20,%edx
f01037f7:	b8 68 00 00 00       	mov    $0x68,%eax
f01037fc:	ee                   	out    %al,(%dx)
f01037fd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103802:	ee                   	out    %al,(%dx)
f0103803:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103808:	b8 68 00 00 00       	mov    $0x68,%eax
f010380d:	ee                   	out    %al,(%dx)
f010380e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103813:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103814:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010381b:	66 83 f8 ff          	cmp    $0xffff,%ax
f010381f:	74 13                	je     f0103834 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103821:	55                   	push   %ebp
f0103822:	89 e5                	mov    %esp,%ebp
f0103824:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103827:	0f b7 c0             	movzwl %ax,%eax
f010382a:	50                   	push   %eax
f010382b:	e8 ee fe ff ff       	call   f010371e <irq_setmask_8259A>
f0103830:	83 c4 10             	add    $0x10,%esp
}
f0103833:	c9                   	leave  
f0103834:	f3 c3                	repz ret 

f0103836 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103836:	55                   	push   %ebp
f0103837:	89 e5                	mov    %esp,%ebp
f0103839:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010383c:	ff 75 08             	pushl  0x8(%ebp)
f010383f:	e8 ed cf ff ff       	call   f0100831 <cputchar>
	*cnt++;
}
f0103844:	83 c4 10             	add    $0x10,%esp
f0103847:	c9                   	leave  
f0103848:	c3                   	ret    

f0103849 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103849:	55                   	push   %ebp
f010384a:	89 e5                	mov    %esp,%ebp
f010384c:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010384f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103856:	ff 75 0c             	pushl  0xc(%ebp)
f0103859:	ff 75 08             	pushl  0x8(%ebp)
f010385c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010385f:	50                   	push   %eax
f0103860:	68 36 38 10 f0       	push   $0xf0103836
f0103865:	e8 6c 17 00 00       	call   f0104fd6 <vprintfmt>
	return cnt;
}
f010386a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010386d:	c9                   	leave  
f010386e:	c3                   	ret    

f010386f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010386f:	55                   	push   %ebp
f0103870:	89 e5                	mov    %esp,%ebp
f0103872:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103875:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103878:	50                   	push   %eax
f0103879:	ff 75 08             	pushl  0x8(%ebp)
f010387c:	e8 c8 ff ff ff       	call   f0103849 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103881:	c9                   	leave  
f0103882:	c3                   	ret    

f0103883 <trap_init_percpu>:
*/
// Initialize and load the per-CPU TSS and IDT

void
trap_init_percpu(void)
{
f0103883:	55                   	push   %ebp
f0103884:	89 e5                	mov    %esp,%ebp
f0103886:	57                   	push   %edi
f0103887:	56                   	push   %esi
f0103888:	53                   	push   %ebx
f0103889:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP-cpunum()*(KSTKSIZE+KSTKGAP);
f010388c:	e8 35 24 00 00       	call   f0105cc6 <cpunum>
f0103891:	89 c3                	mov    %eax,%ebx
f0103893:	e8 2e 24 00 00       	call   f0105cc6 <cpunum>
f0103898:	6b db 74             	imul   $0x74,%ebx,%ebx
f010389b:	c1 e0 10             	shl    $0x10,%eax
f010389e:	89 c2                	mov    %eax,%edx
f01038a0:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01038a5:	29 d0                	sub    %edx,%eax
f01038a7:	89 83 30 30 21 f0    	mov    %eax,-0xfdecfd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038ad:	e8 14 24 00 00       	call   f0105cc6 <cpunum>
f01038b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b5:	66 c7 80 34 30 21 f0 	movw   $0x10,-0xfdecfcc(%eax)
f01038bc:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038be:	e8 03 24 00 00       	call   f0105cc6 <cpunum>
f01038c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c6:	66 c7 80 92 30 21 f0 	movw   $0x68,-0xfdecf6e(%eax)
f01038cd:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01038cf:	e8 f2 23 00 00       	call   f0105cc6 <cpunum>
f01038d4:	8d 58 05             	lea    0x5(%eax),%ebx
f01038d7:	e8 ea 23 00 00       	call   f0105cc6 <cpunum>
f01038dc:	89 c7                	mov    %eax,%edi
f01038de:	e8 e3 23 00 00       	call   f0105cc6 <cpunum>
f01038e3:	89 c6                	mov    %eax,%esi
f01038e5:	e8 dc 23 00 00       	call   f0105cc6 <cpunum>
f01038ea:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01038f1:	f0 67 00 
f01038f4:	6b ff 74             	imul   $0x74,%edi,%edi
f01038f7:	81 c7 2c 30 21 f0    	add    $0xf021302c,%edi
f01038fd:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103904:	f0 
f0103905:	6b d6 74             	imul   $0x74,%esi,%edx
f0103908:	81 c2 2c 30 21 f0    	add    $0xf021302c,%edx
f010390e:	c1 ea 10             	shr    $0x10,%edx
f0103911:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103918:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f010391f:	99 
f0103920:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103927:	40 
f0103928:	6b c0 74             	imul   $0x74,%eax,%eax
f010392b:	05 2c 30 21 f0       	add    $0xf021302c,%eax
f0103930:	c1 e8 18             	shr    $0x18,%eax
f0103933:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+cpunum()].sd_s = 0;
f010393a:	e8 87 23 00 00       	call   f0105cc6 <cpunum>
f010393f:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f0103946:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(thiscpu->cpu_id<<3));//why do this?I cannot unstanderd.
f0103947:	e8 7a 23 00 00       	call   f0105cc6 <cpunum>
f010394c:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f010394f:	0f b6 80 20 30 21 f0 	movzbl -0xfdecfe0(%eax),%eax
f0103956:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f010395d:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103960:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103965:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
	*/
}
f0103968:	83 c4 0c             	add    $0xc,%esp
f010396b:	5b                   	pop    %ebx
f010396c:	5e                   	pop    %esi
f010396d:	5f                   	pop    %edi
f010396e:	5d                   	pop    %ebp
f010396f:	c3                   	ret    

f0103970 <trap_init>:
}


void
trap_init(void)
{
f0103970:	55                   	push   %ebp
f0103971:	89 e5                	mov    %esp,%ebp
f0103973:	83 ec 48             	sub    $0x48,%esp
	void iqr12(); 
	void iqr13(); 
	void iqr14(); 
	void iqr15();	 

	void (*iqrs[])() = {
f0103976:	c7 45 b8 9a 43 10 f0 	movl   $0xf010439a,-0x48(%ebp)
f010397d:	c7 45 bc a0 43 10 f0 	movl   $0xf01043a0,-0x44(%ebp)
f0103984:	c7 45 c0 a6 43 10 f0 	movl   $0xf01043a6,-0x40(%ebp)
f010398b:	c7 45 c4 ac 43 10 f0 	movl   $0xf01043ac,-0x3c(%ebp)
f0103992:	c7 45 c8 b2 43 10 f0 	movl   $0xf01043b2,-0x38(%ebp)
f0103999:	c7 45 cc b8 43 10 f0 	movl   $0xf01043b8,-0x34(%ebp)
f01039a0:	c7 45 d0 be 43 10 f0 	movl   $0xf01043be,-0x30(%ebp)
f01039a7:	c7 45 d4 c4 43 10 f0 	movl   $0xf01043c4,-0x2c(%ebp)
f01039ae:	c7 45 d8 ca 43 10 f0 	movl   $0xf01043ca,-0x28(%ebp)
f01039b5:	c7 45 dc d0 43 10 f0 	movl   $0xf01043d0,-0x24(%ebp)
f01039bc:	c7 45 e0 d6 43 10 f0 	movl   $0xf01043d6,-0x20(%ebp)
f01039c3:	c7 45 e4 dc 43 10 f0 	movl   $0xf01043dc,-0x1c(%ebp)
f01039ca:	c7 45 e8 e2 43 10 f0 	movl   $0xf01043e2,-0x18(%ebp)
f01039d1:	c7 45 ec e8 43 10 f0 	movl   $0xf01043e8,-0x14(%ebp)
f01039d8:	c7 45 f0 ee 43 10 f0 	movl   $0xf01043ee,-0x10(%ebp)
f01039df:	c7 45 f4 f4 43 10 f0 	movl   $0xf01043f4,-0xc(%ebp)
f01039e6:	b8 20 00 00 00       	mov    $0x20,%eax
		iqr0,iqr1,iqr2,iqr3, iqr4, iqr5, iqr6, iqr7, iqr8, iqr9, iqr10, iqr11, iqr12, iqr13, iqr14, iqr15
	};
	int i;
	for(i = 0;i<16;i++){
		SETGATE(idt[IRQ_OFFSET + i], 0 ,GD_KT, iqrs[i], 0);
f01039eb:	8b 94 85 38 ff ff ff 	mov    -0xc8(%ebp,%eax,4),%edx
f01039f2:	66 89 14 c5 60 22 21 	mov    %dx,-0xfdedda0(,%eax,8)
f01039f9:	f0 
f01039fa:	66 c7 04 c5 62 22 21 	movw   $0x8,-0xfdedd9e(,%eax,8)
f0103a01:	f0 08 00 
f0103a04:	c6 04 c5 64 22 21 f0 	movb   $0x0,-0xfdedd9c(,%eax,8)
f0103a0b:	00 
f0103a0c:	c6 04 c5 65 22 21 f0 	movb   $0x8e,-0xfdedd9b(,%eax,8)
f0103a13:	8e 
f0103a14:	c1 ea 10             	shr    $0x10,%edx
f0103a17:	66 89 14 c5 66 22 21 	mov    %dx,-0xfdedd9a(,%eax,8)
f0103a1e:	f0 
f0103a1f:	83 c0 01             	add    $0x1,%eax

	void (*iqrs[])() = {
		iqr0,iqr1,iqr2,iqr3, iqr4, iqr5, iqr6, iqr7, iqr8, iqr9, iqr10, iqr11, iqr12, iqr13, iqr14, iqr15
	};
	int i;
	for(i = 0;i<16;i++){
f0103a22:	83 f8 30             	cmp    $0x30,%eax
f0103a25:	75 c4                	jne    f01039eb <trap_init+0x7b>
		SETGATE(idt[IRQ_OFFSET + i], 0 ,GD_KT, iqrs[i], 0);
	}
	SETGATE(idt[T_DIVIDE],0,GD_KT,t_divide,0);
f0103a27:	b8 02 43 10 f0       	mov    $0xf0104302,%eax
f0103a2c:	66 a3 60 22 21 f0    	mov    %ax,0xf0212260
f0103a32:	66 c7 05 62 22 21 f0 	movw   $0x8,0xf0212262
f0103a39:	08 00 
f0103a3b:	c6 05 64 22 21 f0 00 	movb   $0x0,0xf0212264
f0103a42:	c6 05 65 22 21 f0 8e 	movb   $0x8e,0xf0212265
f0103a49:	c1 e8 10             	shr    $0x10,%eax
f0103a4c:	66 a3 66 22 21 f0    	mov    %ax,0xf0212266
	SETGATE(idt[T_DEBUG],0,GD_KT,t_debug,0);
f0103a52:	b8 0c 43 10 f0       	mov    $0xf010430c,%eax
f0103a57:	66 a3 68 22 21 f0    	mov    %ax,0xf0212268
f0103a5d:	66 c7 05 6a 22 21 f0 	movw   $0x8,0xf021226a
f0103a64:	08 00 
f0103a66:	c6 05 6c 22 21 f0 00 	movb   $0x0,0xf021226c
f0103a6d:	c6 05 6d 22 21 f0 8e 	movb   $0x8e,0xf021226d
f0103a74:	c1 e8 10             	shr    $0x10,%eax
f0103a77:	66 a3 6e 22 21 f0    	mov    %ax,0xf021226e
//	SETGAET(idt[T_NMI],0,GD_KT,t_nmi,0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103a7d:	b8 20 43 10 f0       	mov    $0xf0104320,%eax
f0103a82:	66 a3 78 22 21 f0    	mov    %ax,0xf0212278
f0103a88:	66 c7 05 7a 22 21 f0 	movw   $0x8,0xf021227a
f0103a8f:	08 00 
f0103a91:	c6 05 7c 22 21 f0 00 	movb   $0x0,0xf021227c
f0103a98:	c6 05 7d 22 21 f0 ee 	movb   $0xee,0xf021227d
f0103a9f:	c1 e8 10             	shr    $0x10,%eax
f0103aa2:	66 a3 7e 22 21 f0    	mov    %ax,0xf021227e
   	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103aa8:	b8 2a 43 10 f0       	mov    $0xf010432a,%eax
f0103aad:	66 a3 80 22 21 f0    	mov    %ax,0xf0212280
f0103ab3:	66 c7 05 82 22 21 f0 	movw   $0x8,0xf0212282
f0103aba:	08 00 
f0103abc:	c6 05 84 22 21 f0 00 	movb   $0x0,0xf0212284
f0103ac3:	c6 05 85 22 21 f0 8e 	movb   $0x8e,0xf0212285
f0103aca:	c1 e8 10             	shr    $0x10,%eax
f0103acd:	66 a3 86 22 21 f0    	mov    %ax,0xf0212286
        SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103ad3:	b8 34 43 10 f0       	mov    $0xf0104334,%eax
f0103ad8:	66 a3 88 22 21 f0    	mov    %ax,0xf0212288
f0103ade:	66 c7 05 8a 22 21 f0 	movw   $0x8,0xf021228a
f0103ae5:	08 00 
f0103ae7:	c6 05 8c 22 21 f0 00 	movb   $0x0,0xf021228c
f0103aee:	c6 05 8d 22 21 f0 8e 	movb   $0x8e,0xf021228d
f0103af5:	c1 e8 10             	shr    $0x10,%eax
f0103af8:	66 a3 8e 22 21 f0    	mov    %ax,0xf021228e
        SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103afe:	b8 3e 43 10 f0       	mov    $0xf010433e,%eax
f0103b03:	66 a3 90 22 21 f0    	mov    %ax,0xf0212290
f0103b09:	66 c7 05 92 22 21 f0 	movw   $0x8,0xf0212292
f0103b10:	08 00 
f0103b12:	c6 05 94 22 21 f0 00 	movb   $0x0,0xf0212294
f0103b19:	c6 05 95 22 21 f0 8e 	movb   $0x8e,0xf0212295
f0103b20:	c1 e8 10             	shr    $0x10,%eax
f0103b23:	66 a3 96 22 21 f0    	mov    %ax,0xf0212296
        SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103b29:	b8 48 43 10 f0       	mov    $0xf0104348,%eax
f0103b2e:	66 a3 98 22 21 f0    	mov    %ax,0xf0212298
f0103b34:	66 c7 05 9a 22 21 f0 	movw   $0x8,0xf021229a
f0103b3b:	08 00 
f0103b3d:	c6 05 9c 22 21 f0 00 	movb   $0x0,0xf021229c
f0103b44:	c6 05 9d 22 21 f0 8e 	movb   $0x8e,0xf021229d
f0103b4b:	c1 e8 10             	shr    $0x10,%eax
f0103b4e:	66 a3 9e 22 21 f0    	mov    %ax,0xf021229e
   	 SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103b54:	b8 52 43 10 f0       	mov    $0xf0104352,%eax
f0103b59:	66 a3 a0 22 21 f0    	mov    %ax,0xf02122a0
f0103b5f:	66 c7 05 a2 22 21 f0 	movw   $0x8,0xf02122a2
f0103b66:	08 00 
f0103b68:	c6 05 a4 22 21 f0 00 	movb   $0x0,0xf02122a4
f0103b6f:	c6 05 a5 22 21 f0 8e 	movb   $0x8e,0xf02122a5
f0103b76:	c1 e8 10             	shr    $0x10,%eax
f0103b79:	66 a3 a6 22 21 f0    	mov    %ax,0xf02122a6
   	 SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103b7f:	b8 5a 43 10 f0       	mov    $0xf010435a,%eax
f0103b84:	66 a3 b0 22 21 f0    	mov    %ax,0xf02122b0
f0103b8a:	66 c7 05 b2 22 21 f0 	movw   $0x8,0xf02122b2
f0103b91:	08 00 
f0103b93:	c6 05 b4 22 21 f0 00 	movb   $0x0,0xf02122b4
f0103b9a:	c6 05 b5 22 21 f0 8e 	movb   $0x8e,0xf02122b5
f0103ba1:	c1 e8 10             	shr    $0x10,%eax
f0103ba4:	66 a3 b6 22 21 f0    	mov    %ax,0xf02122b6
  	 SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103baa:	b8 62 43 10 f0       	mov    $0xf0104362,%eax
f0103baf:	66 a3 b8 22 21 f0    	mov    %ax,0xf02122b8
f0103bb5:	66 c7 05 ba 22 21 f0 	movw   $0x8,0xf02122ba
f0103bbc:	08 00 
f0103bbe:	c6 05 bc 22 21 f0 00 	movb   $0x0,0xf02122bc
f0103bc5:	c6 05 bd 22 21 f0 8e 	movb   $0x8e,0xf02122bd
f0103bcc:	c1 e8 10             	shr    $0x10,%eax
f0103bcf:	66 a3 be 22 21 f0    	mov    %ax,0xf02122be
   	 SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103bd5:	b8 6a 43 10 f0       	mov    $0xf010436a,%eax
f0103bda:	66 a3 c0 22 21 f0    	mov    %ax,0xf02122c0
f0103be0:	66 c7 05 c2 22 21 f0 	movw   $0x8,0xf02122c2
f0103be7:	08 00 
f0103be9:	c6 05 c4 22 21 f0 00 	movb   $0x0,0xf02122c4
f0103bf0:	c6 05 c5 22 21 f0 8e 	movb   $0x8e,0xf02122c5
f0103bf7:	c1 e8 10             	shr    $0x10,%eax
f0103bfa:	66 a3 c6 22 21 f0    	mov    %ax,0xf02122c6
   	 SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103c00:	b8 72 43 10 f0       	mov    $0xf0104372,%eax
f0103c05:	66 a3 c8 22 21 f0    	mov    %ax,0xf02122c8
f0103c0b:	66 c7 05 ca 22 21 f0 	movw   $0x8,0xf02122ca
f0103c12:	08 00 
f0103c14:	c6 05 cc 22 21 f0 00 	movb   $0x0,0xf02122cc
f0103c1b:	c6 05 cd 22 21 f0 8e 	movb   $0x8e,0xf02122cd
f0103c22:	c1 e8 10             	shr    $0x10,%eax
f0103c25:	66 a3 ce 22 21 f0    	mov    %ax,0xf02122ce
   	 SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103c2b:	b8 7a 43 10 f0       	mov    $0xf010437a,%eax
f0103c30:	66 a3 d0 22 21 f0    	mov    %ax,0xf02122d0
f0103c36:	66 c7 05 d2 22 21 f0 	movw   $0x8,0xf02122d2
f0103c3d:	08 00 
f0103c3f:	c6 05 d4 22 21 f0 00 	movb   $0x0,0xf02122d4
f0103c46:	c6 05 d5 22 21 f0 8e 	movb   $0x8e,0xf02122d5
f0103c4d:	c1 e8 10             	shr    $0x10,%eax
f0103c50:	66 a3 d6 22 21 f0    	mov    %ax,0xf02122d6
   	 SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103c56:	b8 7e 43 10 f0       	mov    $0xf010437e,%eax
f0103c5b:	66 a3 e0 22 21 f0    	mov    %ax,0xf02122e0
f0103c61:	66 c7 05 e2 22 21 f0 	movw   $0x8,0xf02122e2
f0103c68:	08 00 
f0103c6a:	c6 05 e4 22 21 f0 00 	movb   $0x0,0xf02122e4
f0103c71:	c6 05 e5 22 21 f0 8e 	movb   $0x8e,0xf02122e5
f0103c78:	c1 e8 10             	shr    $0x10,%eax
f0103c7b:	66 a3 e6 22 21 f0    	mov    %ax,0xf02122e6
   	 SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103c81:	b8 84 43 10 f0       	mov    $0xf0104384,%eax
f0103c86:	66 a3 e8 22 21 f0    	mov    %ax,0xf02122e8
f0103c8c:	66 c7 05 ea 22 21 f0 	movw   $0x8,0xf02122ea
f0103c93:	08 00 
f0103c95:	c6 05 ec 22 21 f0 00 	movb   $0x0,0xf02122ec
f0103c9c:	c6 05 ed 22 21 f0 8e 	movb   $0x8e,0xf02122ed
f0103ca3:	c1 e8 10             	shr    $0x10,%eax
f0103ca6:	66 a3 ee 22 21 f0    	mov    %ax,0xf02122ee
   	 SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103cac:	b8 88 43 10 f0       	mov    $0xf0104388,%eax
f0103cb1:	66 a3 f0 22 21 f0    	mov    %ax,0xf02122f0
f0103cb7:	66 c7 05 f2 22 21 f0 	movw   $0x8,0xf02122f2
f0103cbe:	08 00 
f0103cc0:	c6 05 f4 22 21 f0 00 	movb   $0x0,0xf02122f4
f0103cc7:	c6 05 f5 22 21 f0 8e 	movb   $0x8e,0xf02122f5
f0103cce:	c1 e8 10             	shr    $0x10,%eax
f0103cd1:	66 a3 f6 22 21 f0    	mov    %ax,0xf02122f6
   	 SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103cd7:	b8 8e 43 10 f0       	mov    $0xf010438e,%eax
f0103cdc:	66 a3 f8 22 21 f0    	mov    %ax,0xf02122f8
f0103ce2:	66 c7 05 fa 22 21 f0 	movw   $0x8,0xf02122fa
f0103ce9:	08 00 
f0103ceb:	c6 05 fc 22 21 f0 00 	movb   $0x0,0xf02122fc
f0103cf2:	c6 05 fd 22 21 f0 8e 	movb   $0x8e,0xf02122fd
f0103cf9:	c1 e8 10             	shr    $0x10,%eax
f0103cfc:	66 a3 fe 22 21 f0    	mov    %ax,0xf02122fe
   	 SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103d02:	b8 94 43 10 f0       	mov    $0xf0104394,%eax
f0103d07:	66 a3 e0 23 21 f0    	mov    %ax,0xf02123e0
f0103d0d:	66 c7 05 e2 23 21 f0 	movw   $0x8,0xf02123e2
f0103d14:	08 00 
f0103d16:	c6 05 e4 23 21 f0 00 	movb   $0x0,0xf02123e4
f0103d1d:	c6 05 e5 23 21 f0 ee 	movb   $0xee,0xf02123e5
f0103d24:	c1 e8 10             	shr    $0x10,%eax
f0103d27:	66 a3 e6 23 21 f0    	mov    %ax,0xf02123e6
	// Per-CPU setup 
	trap_init_percpu();
f0103d2d:	e8 51 fb ff ff       	call   f0103883 <trap_init_percpu>
}
f0103d32:	c9                   	leave  
f0103d33:	c3                   	ret    

f0103d34 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d34:	55                   	push   %ebp
f0103d35:	89 e5                	mov    %esp,%ebp
f0103d37:	53                   	push   %ebx
f0103d38:	83 ec 0c             	sub    $0xc,%esp
f0103d3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d3e:	ff 33                	pushl  (%ebx)
f0103d40:	68 65 78 10 f0       	push   $0xf0107865
f0103d45:	e8 25 fb ff ff       	call   f010386f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d4a:	83 c4 08             	add    $0x8,%esp
f0103d4d:	ff 73 04             	pushl  0x4(%ebx)
f0103d50:	68 74 78 10 f0       	push   $0xf0107874
f0103d55:	e8 15 fb ff ff       	call   f010386f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d5a:	83 c4 08             	add    $0x8,%esp
f0103d5d:	ff 73 08             	pushl  0x8(%ebx)
f0103d60:	68 83 78 10 f0       	push   $0xf0107883
f0103d65:	e8 05 fb ff ff       	call   f010386f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d6a:	83 c4 08             	add    $0x8,%esp
f0103d6d:	ff 73 0c             	pushl  0xc(%ebx)
f0103d70:	68 92 78 10 f0       	push   $0xf0107892
f0103d75:	e8 f5 fa ff ff       	call   f010386f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d7a:	83 c4 08             	add    $0x8,%esp
f0103d7d:	ff 73 10             	pushl  0x10(%ebx)
f0103d80:	68 a1 78 10 f0       	push   $0xf01078a1
f0103d85:	e8 e5 fa ff ff       	call   f010386f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103d8a:	83 c4 08             	add    $0x8,%esp
f0103d8d:	ff 73 14             	pushl  0x14(%ebx)
f0103d90:	68 b0 78 10 f0       	push   $0xf01078b0
f0103d95:	e8 d5 fa ff ff       	call   f010386f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103d9a:	83 c4 08             	add    $0x8,%esp
f0103d9d:	ff 73 18             	pushl  0x18(%ebx)
f0103da0:	68 bf 78 10 f0       	push   $0xf01078bf
f0103da5:	e8 c5 fa ff ff       	call   f010386f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103daa:	83 c4 08             	add    $0x8,%esp
f0103dad:	ff 73 1c             	pushl  0x1c(%ebx)
f0103db0:	68 ce 78 10 f0       	push   $0xf01078ce
f0103db5:	e8 b5 fa ff ff       	call   f010386f <cprintf>
}
f0103dba:	83 c4 10             	add    $0x10,%esp
f0103dbd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103dc0:	c9                   	leave  
f0103dc1:	c3                   	ret    

f0103dc2 <print_trapframe>:
	*/
}

void
print_trapframe(struct Trapframe *tf)
{
f0103dc2:	55                   	push   %ebp
f0103dc3:	89 e5                	mov    %esp,%ebp
f0103dc5:	56                   	push   %esi
f0103dc6:	53                   	push   %ebx
f0103dc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103dca:	e8 f7 1e 00 00       	call   f0105cc6 <cpunum>
f0103dcf:	83 ec 04             	sub    $0x4,%esp
f0103dd2:	50                   	push   %eax
f0103dd3:	53                   	push   %ebx
f0103dd4:	68 32 79 10 f0       	push   $0xf0107932
f0103dd9:	e8 91 fa ff ff       	call   f010386f <cprintf>
	print_regs(&tf->tf_regs);
f0103dde:	89 1c 24             	mov    %ebx,(%esp)
f0103de1:	e8 4e ff ff ff       	call   f0103d34 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103de6:	83 c4 08             	add    $0x8,%esp
f0103de9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ded:	50                   	push   %eax
f0103dee:	68 50 79 10 f0       	push   $0xf0107950
f0103df3:	e8 77 fa ff ff       	call   f010386f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103df8:	83 c4 08             	add    $0x8,%esp
f0103dfb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103dff:	50                   	push   %eax
f0103e00:	68 63 79 10 f0       	push   $0xf0107963
f0103e05:	e8 65 fa ff ff       	call   f010386f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e0a:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103e0d:	83 c4 10             	add    $0x10,%esp
f0103e10:	83 f8 13             	cmp    $0x13,%eax
f0103e13:	77 09                	ja     f0103e1e <print_trapframe+0x5c>
		return excnames[trapno];
f0103e15:	8b 14 85 60 7c 10 f0 	mov    -0xfef83a0(,%eax,4),%edx
f0103e1c:	eb 1f                	jmp    f0103e3d <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103e1e:	83 f8 30             	cmp    $0x30,%eax
f0103e21:	74 15                	je     f0103e38 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e23:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e26:	83 fa 10             	cmp    $0x10,%edx
f0103e29:	b9 fc 78 10 f0       	mov    $0xf01078fc,%ecx
f0103e2e:	ba e9 78 10 f0       	mov    $0xf01078e9,%edx
f0103e33:	0f 43 d1             	cmovae %ecx,%edx
f0103e36:	eb 05                	jmp    f0103e3d <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103e38:	ba dd 78 10 f0       	mov    $0xf01078dd,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e3d:	83 ec 04             	sub    $0x4,%esp
f0103e40:	52                   	push   %edx
f0103e41:	50                   	push   %eax
f0103e42:	68 76 79 10 f0       	push   $0xf0107976
f0103e47:	e8 23 fa ff ff       	call   f010386f <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e4c:	83 c4 10             	add    $0x10,%esp
f0103e4f:	3b 1d 60 2a 21 f0    	cmp    0xf0212a60,%ebx
f0103e55:	75 1a                	jne    f0103e71 <print_trapframe+0xaf>
f0103e57:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e5b:	75 14                	jne    f0103e71 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e5d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e60:	83 ec 08             	sub    $0x8,%esp
f0103e63:	50                   	push   %eax
f0103e64:	68 88 79 10 f0       	push   $0xf0107988
f0103e69:	e8 01 fa ff ff       	call   f010386f <cprintf>
f0103e6e:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103e71:	83 ec 08             	sub    $0x8,%esp
f0103e74:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e77:	68 97 79 10 f0       	push   $0xf0107997
f0103e7c:	e8 ee f9 ff ff       	call   f010386f <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e81:	83 c4 10             	add    $0x10,%esp
f0103e84:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e88:	75 49                	jne    f0103ed3 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103e8a:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103e8d:	89 c2                	mov    %eax,%edx
f0103e8f:	83 e2 01             	and    $0x1,%edx
f0103e92:	ba 16 79 10 f0       	mov    $0xf0107916,%edx
f0103e97:	b9 0b 79 10 f0       	mov    $0xf010790b,%ecx
f0103e9c:	0f 44 ca             	cmove  %edx,%ecx
f0103e9f:	89 c2                	mov    %eax,%edx
f0103ea1:	83 e2 02             	and    $0x2,%edx
f0103ea4:	ba 28 79 10 f0       	mov    $0xf0107928,%edx
f0103ea9:	be 22 79 10 f0       	mov    $0xf0107922,%esi
f0103eae:	0f 45 d6             	cmovne %esi,%edx
f0103eb1:	83 e0 04             	and    $0x4,%eax
f0103eb4:	be 5b 7a 10 f0       	mov    $0xf0107a5b,%esi
f0103eb9:	b8 2d 79 10 f0       	mov    $0xf010792d,%eax
f0103ebe:	0f 44 c6             	cmove  %esi,%eax
f0103ec1:	51                   	push   %ecx
f0103ec2:	52                   	push   %edx
f0103ec3:	50                   	push   %eax
f0103ec4:	68 a5 79 10 f0       	push   $0xf01079a5
f0103ec9:	e8 a1 f9 ff ff       	call   f010386f <cprintf>
f0103ece:	83 c4 10             	add    $0x10,%esp
f0103ed1:	eb 10                	jmp    f0103ee3 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103ed3:	83 ec 0c             	sub    $0xc,%esp
f0103ed6:	68 84 67 10 f0       	push   $0xf0106784
f0103edb:	e8 8f f9 ff ff       	call   f010386f <cprintf>
f0103ee0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ee3:	83 ec 08             	sub    $0x8,%esp
f0103ee6:	ff 73 30             	pushl  0x30(%ebx)
f0103ee9:	68 b4 79 10 f0       	push   $0xf01079b4
f0103eee:	e8 7c f9 ff ff       	call   f010386f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103ef3:	83 c4 08             	add    $0x8,%esp
f0103ef6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103efa:	50                   	push   %eax
f0103efb:	68 c3 79 10 f0       	push   $0xf01079c3
f0103f00:	e8 6a f9 ff ff       	call   f010386f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f05:	83 c4 08             	add    $0x8,%esp
f0103f08:	ff 73 38             	pushl  0x38(%ebx)
f0103f0b:	68 d6 79 10 f0       	push   $0xf01079d6
f0103f10:	e8 5a f9 ff ff       	call   f010386f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f15:	83 c4 10             	add    $0x10,%esp
f0103f18:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f1c:	74 25                	je     f0103f43 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f1e:	83 ec 08             	sub    $0x8,%esp
f0103f21:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f24:	68 e5 79 10 f0       	push   $0xf01079e5
f0103f29:	e8 41 f9 ff ff       	call   f010386f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f2e:	83 c4 08             	add    $0x8,%esp
f0103f31:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f35:	50                   	push   %eax
f0103f36:	68 f4 79 10 f0       	push   $0xf01079f4
f0103f3b:	e8 2f f9 ff ff       	call   f010386f <cprintf>
f0103f40:	83 c4 10             	add    $0x10,%esp
	}
}
f0103f43:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f46:	5b                   	pop    %ebx
f0103f47:	5e                   	pop    %esi
f0103f48:	5d                   	pop    %ebp
f0103f49:	c3                   	ret    

f0103f4a <page_fault_handler>:
}

typedef void*(*fun)(void);
void
page_fault_handler(struct Trapframe *tf)
{
f0103f4a:	55                   	push   %ebp
f0103f4b:	89 e5                	mov    %esp,%ebp
f0103f4d:	57                   	push   %edi
f0103f4e:	56                   	push   %esi
f0103f4f:	53                   	push   %ebx
f0103f50:	83 ec 0c             	sub    $0xc,%esp
f0103f53:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f56:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
//	print_trapframe(tf);
	if ((tf->tf_cs&3) == 0)
f0103f59:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f5d:	75 17                	jne    f0103f76 <page_fault_handler+0x2c>
		panic("a page fault happens in kernel [eip:%x]", tf->tf_eip);
f0103f5f:	ff 73 30             	pushl  0x30(%ebx)
f0103f62:	68 a8 7b 10 f0       	push   $0xf0107ba8
f0103f67:	68 29 02 00 00       	push   $0x229
f0103f6c:	68 07 7a 10 f0       	push   $0xf0107a07
f0103f71:	e8 1e c1 ff ff       	call   f0100094 <_panic>
	// LAB 3: Your code here.

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.
	if(curenv == 0){
f0103f76:	e8 4b 1d 00 00       	call   f0105cc6 <cpunum>
f0103f7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f7e:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0103f85:	75 17                	jne    f0103f9e <page_fault_handler+0x54>
		panic("curenv does't exist.\n");
f0103f87:	83 ec 04             	sub    $0x4,%esp
f0103f8a:	68 13 7a 10 f0       	push   $0xf0107a13
f0103f8f:	68 2f 02 00 00       	push   $0x22f
f0103f94:	68 07 7a 10 f0       	push   $0xf0107a07
f0103f99:	e8 f6 c0 ff ff       	call   f0100094 <_panic>
	}
	//cprintf("\ttrap env_id is:%d\n",curenv->env_id);	
	if(curenv->env_pgfault_upcall == 0){
f0103f9e:	e8 23 1d 00 00       	call   f0105cc6 <cpunum>
f0103fa3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa6:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103fac:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fb0:	75 17                	jne    f0103fc9 <page_fault_handler+0x7f>
		panic("curenv->env_pgfault_upcall does't exist.\n");
f0103fb2:	83 ec 04             	sub    $0x4,%esp
f0103fb5:	68 d0 7b 10 f0       	push   $0xf0107bd0
f0103fba:	68 33 02 00 00       	push   $0x233
f0103fbf:	68 07 7a 10 f0       	push   $0xf0107a07
f0103fc4:	e8 cb c0 ff ff       	call   f0100094 <_panic>
	}
	if(curenv->env_pgfault_upcall != 0){
f0103fc9:	e8 f8 1c 00 00       	call   f0105cc6 <cpunum>
f0103fce:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd1:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0103fd7:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fdb:	0f 84 a7 00 00 00    	je     f0104088 <page_fault_handler+0x13e>
		//(fun(curenv->env_pgfault_upcall))();		
	//	( (fun)(curenv->env_pgfault_upcall) )();
	
		struct UTrapframe *utf;
		uintptr_t utf_addr;
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0103fe1:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103fe4:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0103fea:	83 e8 38             	sub    $0x38,%eax
f0103fed:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103ff3:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103ff8:	0f 46 d0             	cmovbe %eax,%edx
f0103ffb:	89 d7                	mov    %edx,%edi
		else 
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
	//	cprintf("\t before user_mem_assert.\n");
		user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
f0103ffd:	e8 c4 1c 00 00       	call   f0105cc6 <cpunum>
f0104002:	6a 02                	push   $0x2
f0104004:	6a 01                	push   $0x1
f0104006:	57                   	push   %edi
f0104007:	6b c0 74             	imul   $0x74,%eax,%eax
f010400a:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104010:	e8 8e ee ff ff       	call   f0102ea3 <user_mem_assert>
	//	cprintf("\t after user_mem_assert.\n");
		utf = (struct UTrapframe *) utf_addr;

		utf->utf_fault_va = fault_va;
f0104015:	89 fa                	mov    %edi,%edx
f0104017:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104019:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010401c:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f010401f:	8d 7f 08             	lea    0x8(%edi),%edi
f0104022:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104027:	89 de                	mov    %ebx,%esi
f0104029:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010402b:	8b 43 30             	mov    0x30(%ebx),%eax
f010402e:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104031:	8b 43 38             	mov    0x38(%ebx),%eax
f0104034:	89 d7                	mov    %edx,%edi
f0104036:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104039:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010403c:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010403f:	e8 82 1c 00 00       	call   f0105cc6 <cpunum>
f0104044:	6b c0 74             	imul   $0x74,%eax,%eax
f0104047:	8b 98 28 30 21 f0    	mov    -0xfdecfd8(%eax),%ebx
f010404d:	e8 74 1c 00 00       	call   f0105cc6 <cpunum>
f0104052:	6b c0 74             	imul   $0x74,%eax,%eax
f0104055:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010405b:	8b 40 64             	mov    0x64(%eax),%eax
f010405e:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = utf_addr;
f0104061:	e8 60 1c 00 00       	call   f0105cc6 <cpunum>
f0104066:	6b c0 74             	imul   $0x74,%eax,%eax
f0104069:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010406f:	89 78 3c             	mov    %edi,0x3c(%eax)
	//	cprintf("\t before env_run curenv.\n");
		env_run(curenv);
f0104072:	e8 4f 1c 00 00       	call   f0105cc6 <cpunum>
f0104077:	83 c4 04             	add    $0x4,%esp
f010407a:	6b c0 74             	imul   $0x74,%eax,%eax
f010407d:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104083:	e8 c9 f5 ff ff       	call   f0103651 <env_run>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
//	print_trapframe(tf);
//	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104088:	8b 5b 30             	mov    0x30(%ebx),%ebx
		curenv->env_id, fault_va, tf->tf_eip);
f010408b:	e8 36 1c 00 00       	call   f0105cc6 <cpunum>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
//	print_trapframe(tf);
//	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104090:	53                   	push   %ebx
f0104091:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104092:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
//	print_trapframe(tf);
//	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104095:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010409b:	ff 70 48             	pushl  0x48(%eax)
f010409e:	68 fc 7b 10 f0       	push   $0xf0107bfc
f01040a3:	e8 c7 f7 ff ff       	call   f010386f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
//	print_trapframe(tf);
	env_destroy(curenv);
f01040a8:	e8 19 1c 00 00       	call   f0105cc6 <cpunum>
f01040ad:	83 c4 04             	add    $0x4,%esp
f01040b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b3:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01040b9:	e8 db f4 ff ff       	call   f0103599 <env_destroy>
	//cprintf("\t OUT function trap.c/page_fault_handler.\n");
}
f01040be:	83 c4 10             	add    $0x10,%esp
f01040c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040c4:	5b                   	pop    %ebx
f01040c5:	5e                   	pop    %esi
f01040c6:	5f                   	pop    %edi
f01040c7:	5d                   	pop    %ebp
f01040c8:	c3                   	ret    

f01040c9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040c9:	55                   	push   %ebp
f01040ca:	89 e5                	mov    %esp,%ebp
f01040cc:	57                   	push   %edi
f01040cd:	56                   	push   %esi
f01040ce:	8b 75 08             	mov    0x8(%ebp),%esi

	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040d1:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040d2:	83 3d 80 2e 21 f0 00 	cmpl   $0x0,0xf0212e80
f01040d9:	74 01                	je     f01040dc <trap+0x13>
		asm volatile("hlt");
f01040db:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040dc:	e8 e5 1b 00 00       	call   f0105cc6 <cpunum>
f01040e1:	6b d0 74             	imul   $0x74,%eax,%edx
f01040e4:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01040ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01040ef:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01040f3:	83 f8 02             	cmp    $0x2,%eax
f01040f6:	75 10                	jne    f0104108 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01040f8:	83 ec 0c             	sub    $0xc,%esp
f01040fb:	68 c0 03 12 f0       	push   $0xf01203c0
f0104100:	e8 2f 1e 00 00       	call   f0105f34 <spin_lock>
f0104105:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104108:	9c                   	pushf  
f0104109:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010410a:	f6 c4 02             	test   $0x2,%ah
f010410d:	74 19                	je     f0104128 <trap+0x5f>
f010410f:	68 29 7a 10 f0       	push   $0xf0107a29
f0104114:	68 e7 73 10 f0       	push   $0xf01073e7
f0104119:	68 e7 01 00 00       	push   $0x1e7
f010411e:	68 07 7a 10 f0       	push   $0xf0107a07
f0104123:	e8 6c bf ff ff       	call   f0100094 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104128:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010412c:	83 e0 03             	and    $0x3,%eax
f010412f:	66 83 f8 03          	cmp    $0x3,%ax
f0104133:	0f 85 a0 00 00 00    	jne    f01041d9 <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104139:	e8 88 1b 00 00       	call   f0105cc6 <cpunum>
f010413e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104141:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104148:	75 19                	jne    f0104163 <trap+0x9a>
f010414a:	68 42 7a 10 f0       	push   $0xf0107a42
f010414f:	68 e7 73 10 f0       	push   $0xf01073e7
f0104154:	68 ee 01 00 00       	push   $0x1ee
f0104159:	68 07 7a 10 f0       	push   $0xf0107a07
f010415e:	e8 31 bf ff ff       	call   f0100094 <_panic>
f0104163:	83 ec 0c             	sub    $0xc,%esp
f0104166:	68 c0 03 12 f0       	push   $0xf01203c0
f010416b:	e8 c4 1d 00 00       	call   f0105f34 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104170:	e8 51 1b 00 00       	call   f0105cc6 <cpunum>
f0104175:	6b c0 74             	imul   $0x74,%eax,%eax
f0104178:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010417e:	83 c4 10             	add    $0x10,%esp
f0104181:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104185:	75 2d                	jne    f01041b4 <trap+0xeb>
			env_free(curenv);
f0104187:	e8 3a 1b 00 00       	call   f0105cc6 <cpunum>
f010418c:	83 ec 0c             	sub    $0xc,%esp
f010418f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104192:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f0104198:	e8 56 f2 ff ff       	call   f01033f3 <env_free>
			curenv = NULL;
f010419d:	e8 24 1b 00 00       	call   f0105cc6 <cpunum>
f01041a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a5:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f01041ac:	00 00 00 
			sched_yield();
f01041af:	e8 2d 03 00 00       	call   f01044e1 <sched_yield>
		}
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041b4:	e8 0d 1b 00 00       	call   f0105cc6 <cpunum>
f01041b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01041bc:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01041c2:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041c7:	89 c7                	mov    %eax,%edi
f01041c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041cb:	e8 f6 1a 00 00       	call   f0105cc6 <cpunum>
f01041d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d3:	8b b0 28 30 21 f0    	mov    -0xfdecfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041d9:	89 35 60 2a 21 f0    	mov    %esi,0xf0212a60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01041df:	8b 46 28             	mov    0x28(%esi),%eax
f01041e2:	83 f8 27             	cmp    $0x27,%eax
f01041e5:	75 1d                	jne    f0104204 <trap+0x13b>
		cprintf("\t\ttrap:Spurious interrupt on irq 7\n");
f01041e7:	83 ec 0c             	sub    $0xc,%esp
f01041ea:	68 20 7c 10 f0       	push   $0xf0107c20
f01041ef:	e8 7b f6 ff ff       	call   f010386f <cprintf>
		print_trapframe(tf);
f01041f4:	89 34 24             	mov    %esi,(%esp)
f01041f7:	e8 c6 fb ff ff       	call   f0103dc2 <print_trapframe>
f01041fc:	83 c4 10             	add    $0x10,%esp
f01041ff:	e9 be 00 00 00       	jmp    f01042c2 <trap+0x1f9>
	// LAB 4: Your code here.


	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD){
f0104204:	83 f8 21             	cmp    $0x21,%eax
f0104207:	75 0a                	jne    f0104213 <trap+0x14a>
///		cprintf("\t\t trap:we are at clock interrupt.\n");
		
		kbd_intr();
f0104209:	e8 81 c4 ff ff       	call   f010068f <kbd_intr>
f010420e:	e9 af 00 00 00       	jmp    f01042c2 <trap+0x1f9>
		return ;
	}

	if(tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL){
f0104213:	83 f8 24             	cmp    $0x24,%eax
f0104216:	75 0a                	jne    f0104222 <trap+0x159>
///		cprintf("\t\t trap:we are at clock interrupt.\n");
		serial_intr();
f0104218:	e8 56 c4 ff ff       	call   f0100673 <serial_intr>
f010421d:	e9 a0 00 00 00       	jmp    f01042c2 <trap+0x1f9>
		return ;
	}



	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f0104222:	83 f8 20             	cmp    $0x20,%eax
f0104225:	75 0a                	jne    f0104231 <trap+0x168>
///		cprintf("\t\t trap:we are at clock interrupt.\n");
		lapic_eoi();
f0104227:	e8 e5 1b 00 00       	call   f0105e11 <lapic_eoi>
		sched_yield();
f010422c:	e8 b0 02 00 00       	call   f01044e1 <sched_yield>
		return ;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	switch(tf->tf_trapno){
f0104231:	83 f8 0e             	cmp    $0xe,%eax
f0104234:	74 0c                	je     f0104242 <trap+0x179>
f0104236:	83 f8 30             	cmp    $0x30,%eax
f0104239:	74 23                	je     f010425e <trap+0x195>
f010423b:	83 f8 03             	cmp    $0x3,%eax
f010423e:	75 3f                	jne    f010427f <trap+0x1b6>
f0104240:	eb 0e                	jmp    f0104250 <trap+0x187>
		case T_PGFLT:
//			cprintf("\tT_PGFLT.\n");
			page_fault_handler(tf);
f0104242:	83 ec 0c             	sub    $0xc,%esp
f0104245:	56                   	push   %esi
f0104246:	e8 ff fc ff ff       	call   f0103f4a <page_fault_handler>
f010424b:	83 c4 10             	add    $0x10,%esp
f010424e:	eb 72                	jmp    f01042c2 <trap+0x1f9>
			return;
		case T_BRKPT:
			//cprintf("Function:trap_dispatch()->T_BRKPT.\n");
			monitor(tf);
f0104250:	83 ec 0c             	sub    $0xc,%esp
f0104253:	56                   	push   %esi
f0104254:	e8 6b c7 ff ff       	call   f01009c4 <monitor>
f0104259:	83 c4 10             	add    $0x10,%esp
f010425c:	eb 64                	jmp    f01042c2 <trap+0x1f9>
			return;
		case T_SYSCALL:
//			cprintf("\tT_SYSCALL.\n");
			tf->tf_regs.reg_eax = syscall(
f010425e:	83 ec 08             	sub    $0x8,%esp
f0104261:	ff 76 04             	pushl  0x4(%esi)
f0104264:	ff 36                	pushl  (%esi)
f0104266:	ff 76 10             	pushl  0x10(%esi)
f0104269:	ff 76 18             	pushl  0x18(%esi)
f010426c:	ff 76 14             	pushl  0x14(%esi)
f010426f:	ff 76 1c             	pushl  0x1c(%esi)
f0104272:	e8 26 03 00 00       	call   f010459d <syscall>
f0104277:	89 46 1c             	mov    %eax,0x1c(%esi)
f010427a:	83 c4 20             	add    $0x20,%esp
f010427d:	eb 43                	jmp    f01042c2 <trap+0x1f9>
   			 );
  //			cprintf("after T_SYSCALL.\n");
			  return;
		default:break;
	}
	print_trapframe(tf);
f010427f:	83 ec 0c             	sub    $0xc,%esp
f0104282:	56                   	push   %esi
f0104283:	e8 3a fb ff ff       	call   f0103dc2 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104288:	83 c4 10             	add    $0x10,%esp
f010428b:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104290:	75 17                	jne    f01042a9 <trap+0x1e0>
		panic("unhandled trap in kernel");
f0104292:	83 ec 04             	sub    $0x4,%esp
f0104295:	68 49 7a 10 f0       	push   $0xf0107a49
f010429a:	68 cc 01 00 00       	push   $0x1cc
f010429f:	68 07 7a 10 f0       	push   $0xf0107a07
f01042a4:	e8 eb bd ff ff       	call   f0100094 <_panic>
	else {
		env_destroy(curenv);
f01042a9:	e8 18 1a 00 00       	call   f0105cc6 <cpunum>
f01042ae:	83 ec 0c             	sub    $0xc,%esp
f01042b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b4:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01042ba:	e8 da f2 ff ff       	call   f0103599 <env_destroy>
f01042bf:	83 c4 10             	add    $0x10,%esp


	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if(curenv && curenv->env_status == ENV_RUNNING){
f01042c2:	e8 ff 19 00 00       	call   f0105cc6 <cpunum>
f01042c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ca:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f01042d1:	74 2a                	je     f01042fd <trap+0x234>
f01042d3:	e8 ee 19 00 00       	call   f0105cc6 <cpunum>
f01042d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01042db:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01042e1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042e5:	75 16                	jne    f01042fd <trap+0x234>
		//cprintf("\t\t\trunning this env.\n");
		//print_trapframe(&(curenv->env_tf));	
		env_run(curenv);
f01042e7:	e8 da 19 00 00       	call   f0105cc6 <cpunum>
f01042ec:	83 ec 0c             	sub    $0xc,%esp
f01042ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01042f2:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01042f8:	e8 54 f3 ff ff       	call   f0103651 <env_run>
	}else{
//		cprintf("\t\t\tsched this env.\n");
		//in here because we killed the parent env,so we should run
		//child env.
		//cprintf("now in the trap(),the curenv is %d\n",curenv);
		sched_yield();
f01042fd:	e8 df 01 00 00       	call   f01044e1 <sched_yield>

f0104302 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f0104302:	6a 00                	push   $0x0
f0104304:	6a 00                	push   $0x0
f0104306:	e9 ef 00 00 00       	jmp    f01043fa <_alltraps>
f010430b:	90                   	nop

f010430c <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);        // 1
f010430c:	6a 00                	push   $0x0
f010430e:	6a 01                	push   $0x1
f0104310:	e9 e5 00 00 00       	jmp    f01043fa <_alltraps>
f0104315:	90                   	nop

f0104316 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);            // 2
f0104316:	6a 00                	push   $0x0
f0104318:	6a 02                	push   $0x2
f010431a:	e9 db 00 00 00       	jmp    f01043fa <_alltraps>
f010431f:	90                   	nop

f0104320 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)        // 3
f0104320:	6a 00                	push   $0x0
f0104322:	6a 03                	push   $0x3
f0104324:	e9 d1 00 00 00       	jmp    f01043fa <_alltraps>
f0104329:	90                   	nop

f010432a <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)        // 4
f010432a:	6a 00                	push   $0x0
f010432c:	6a 04                	push   $0x4
f010432e:	e9 c7 00 00 00       	jmp    f01043fa <_alltraps>
f0104333:	90                   	nop

f0104334 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)        // 5
f0104334:	6a 00                	push   $0x0
f0104336:	6a 05                	push   $0x5
f0104338:	e9 bd 00 00 00       	jmp    f01043fa <_alltraps>
f010433d:	90                   	nop

f010433e <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)        // 6
f010433e:	6a 00                	push   $0x0
f0104340:	6a 06                	push   $0x6
f0104342:	e9 b3 00 00 00       	jmp    f01043fa <_alltraps>
f0104347:	90                   	nop

f0104348 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)    // 7
f0104348:	6a 00                	push   $0x0
f010434a:	6a 07                	push   $0x7
f010434c:	e9 a9 00 00 00       	jmp    f01043fa <_alltraps>
f0104351:	90                   	nop

f0104352 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)            // 8
f0104352:	6a 08                	push   $0x8
f0104354:	e9 a1 00 00 00       	jmp    f01043fa <_alltraps>
f0104359:	90                   	nop

f010435a <t_tss>:
                                        // 9
TRAPHANDLER(t_tss, T_TSS)                // 10
f010435a:	6a 0a                	push   $0xa
f010435c:	e9 99 00 00 00       	jmp    f01043fa <_alltraps>
f0104361:	90                   	nop

f0104362 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)            // 11
f0104362:	6a 0b                	push   $0xb
f0104364:	e9 91 00 00 00       	jmp    f01043fa <_alltraps>
f0104369:	90                   	nop

f010436a <t_stack>:
TRAPHANDLER(t_stack, T_STACK)            // 12
f010436a:	6a 0c                	push   $0xc
f010436c:	e9 89 00 00 00       	jmp    f01043fa <_alltraps>
f0104371:	90                   	nop

f0104372 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)            // 13
f0104372:	6a 0d                	push   $0xd
f0104374:	e9 81 00 00 00       	jmp    f01043fa <_alltraps>
f0104379:	90                   	nop

f010437a <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)            // 14
f010437a:	6a 0e                	push   $0xe
f010437c:	eb 7c                	jmp    f01043fa <_alltraps>

f010437e <t_fperr>:
                                        // 15
TRAPHANDLER_NOEC(t_fperr, T_FPERR)        // 16
f010437e:	6a 00                	push   $0x0
f0104380:	6a 10                	push   $0x10
f0104382:	eb 76                	jmp    f01043fa <_alltraps>

f0104384 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)            // 17
f0104384:	6a 11                	push   $0x11
f0104386:	eb 72                	jmp    f01043fa <_alltraps>

f0104388 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)        // 18
f0104388:	6a 00                	push   $0x0
f010438a:	6a 12                	push   $0x12
f010438c:	eb 6c                	jmp    f01043fa <_alltraps>

f010438e <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)    // 19
f010438e:	6a 00                	push   $0x0
f0104390:	6a 13                	push   $0x13
f0104392:	eb 66                	jmp    f01043fa <_alltraps>

f0104394 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0104394:	6a 00                	push   $0x0
f0104396:	6a 30                	push   $0x30
f0104398:	eb 60                	jmp    f01043fa <_alltraps>

f010439a <iqr0>:

/*registe iqr function to handle interrupt.*/
TRAPHANDLER_NOEC(iqr0, 32) 
f010439a:	6a 00                	push   $0x0
f010439c:	6a 20                	push   $0x20
f010439e:	eb 5a                	jmp    f01043fa <_alltraps>

f01043a0 <iqr1>:
TRAPHANDLER_NOEC(iqr1, 33) 
f01043a0:	6a 00                	push   $0x0
f01043a2:	6a 21                	push   $0x21
f01043a4:	eb 54                	jmp    f01043fa <_alltraps>

f01043a6 <iqr2>:
TRAPHANDLER_NOEC(iqr2, 34) 
f01043a6:	6a 00                	push   $0x0
f01043a8:	6a 22                	push   $0x22
f01043aa:	eb 4e                	jmp    f01043fa <_alltraps>

f01043ac <iqr3>:
TRAPHANDLER_NOEC(iqr3, 35) 
f01043ac:	6a 00                	push   $0x0
f01043ae:	6a 23                	push   $0x23
f01043b0:	eb 48                	jmp    f01043fa <_alltraps>

f01043b2 <iqr4>:
TRAPHANDLER_NOEC(iqr4, 36) 
f01043b2:	6a 00                	push   $0x0
f01043b4:	6a 24                	push   $0x24
f01043b6:	eb 42                	jmp    f01043fa <_alltraps>

f01043b8 <iqr5>:
TRAPHANDLER_NOEC(iqr5, 37) 
f01043b8:	6a 00                	push   $0x0
f01043ba:	6a 25                	push   $0x25
f01043bc:	eb 3c                	jmp    f01043fa <_alltraps>

f01043be <iqr6>:
TRAPHANDLER_NOEC(iqr6, 38) 
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 26                	push   $0x26
f01043c2:	eb 36                	jmp    f01043fa <_alltraps>

f01043c4 <iqr7>:
TRAPHANDLER_NOEC(iqr7, 39) 
f01043c4:	6a 00                	push   $0x0
f01043c6:	6a 27                	push   $0x27
f01043c8:	eb 30                	jmp    f01043fa <_alltraps>

f01043ca <iqr8>:
TRAPHANDLER_NOEC(iqr8, 40) 
f01043ca:	6a 00                	push   $0x0
f01043cc:	6a 28                	push   $0x28
f01043ce:	eb 2a                	jmp    f01043fa <_alltraps>

f01043d0 <iqr9>:
TRAPHANDLER_NOEC(iqr9, 41) 
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 29                	push   $0x29
f01043d4:	eb 24                	jmp    f01043fa <_alltraps>

f01043d6 <iqr10>:
TRAPHANDLER_NOEC(iqr10, 42) 
f01043d6:	6a 00                	push   $0x0
f01043d8:	6a 2a                	push   $0x2a
f01043da:	eb 1e                	jmp    f01043fa <_alltraps>

f01043dc <iqr11>:
TRAPHANDLER_NOEC(iqr11, 43) 
f01043dc:	6a 00                	push   $0x0
f01043de:	6a 2b                	push   $0x2b
f01043e0:	eb 18                	jmp    f01043fa <_alltraps>

f01043e2 <iqr12>:
TRAPHANDLER_NOEC(iqr12, 44) 
f01043e2:	6a 00                	push   $0x0
f01043e4:	6a 2c                	push   $0x2c
f01043e6:	eb 12                	jmp    f01043fa <_alltraps>

f01043e8 <iqr13>:
TRAPHANDLER_NOEC(iqr13, 45) 
f01043e8:	6a 00                	push   $0x0
f01043ea:	6a 2d                	push   $0x2d
f01043ec:	eb 0c                	jmp    f01043fa <_alltraps>

f01043ee <iqr14>:
TRAPHANDLER_NOEC(iqr14, 46) 
f01043ee:	6a 00                	push   $0x0
f01043f0:	6a 2e                	push   $0x2e
f01043f2:	eb 06                	jmp    f01043fa <_alltraps>

f01043f4 <iqr15>:
TRAPHANDLER_NOEC(iqr15, 47)
f01043f4:	6a 00                	push   $0x0
f01043f6:	6a 2f                	push   $0x2f
f01043f8:	eb 00                	jmp    f01043fa <_alltraps>

f01043fa <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01043fa:	1e                   	push   %ds
	pushl %es
f01043fb:	06                   	push   %es
	pushal
f01043fc:	60                   	pusha  

	movw $GD_KD,%eax
f01043fd:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax,%ds
f0104401:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f0104403:	8e c0                	mov    %eax,%es

	pushl %esp
f0104405:	54                   	push   %esp
	call trap
f0104406:	e8 be fc ff ff       	call   f01040c9 <trap>

f010440b <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010440b:	55                   	push   %ebp
f010440c:	89 e5                	mov    %esp,%ebp
f010440e:	83 ec 08             	sub    $0x8,%esp
f0104411:	a1 44 22 21 f0       	mov    0xf0212244,%eax
f0104416:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104419:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010441e:	8b 02                	mov    (%edx),%eax
f0104420:	83 e8 01             	sub    $0x1,%eax
f0104423:	83 f8 02             	cmp    $0x2,%eax
f0104426:	76 10                	jbe    f0104438 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104428:	83 c1 01             	add    $0x1,%ecx
f010442b:	83 c2 7c             	add    $0x7c,%edx
f010442e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104434:	75 e8                	jne    f010441e <sched_halt+0x13>
f0104436:	eb 08                	jmp    f0104440 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104438:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010443e:	75 1f                	jne    f010445f <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104440:	83 ec 0c             	sub    $0xc,%esp
f0104443:	68 b0 7c 10 f0       	push   $0xf0107cb0
f0104448:	e8 22 f4 ff ff       	call   f010386f <cprintf>
f010444d:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104450:	83 ec 0c             	sub    $0xc,%esp
f0104453:	6a 00                	push   $0x0
f0104455:	e8 6a c5 ff ff       	call   f01009c4 <monitor>
f010445a:	83 c4 10             	add    $0x10,%esp
f010445d:	eb f1                	jmp    f0104450 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010445f:	e8 62 18 00 00       	call   f0105cc6 <cpunum>
f0104464:	6b c0 74             	imul   $0x74,%eax,%eax
f0104467:	c7 80 28 30 21 f0 00 	movl   $0x0,-0xfdecfd8(%eax)
f010446e:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104471:	a1 8c 2e 21 f0       	mov    0xf0212e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104476:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010447b:	77 15                	ja     f0104492 <sched_halt+0x87>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010447d:	50                   	push   %eax
f010447e:	68 9c 64 10 f0       	push   $0xf010649c
f0104483:	68 bc 00 00 00       	push   $0xbc
f0104488:	68 0c 7d 10 f0       	push   $0xf0107d0c
f010448d:	e8 02 bc ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104492:	05 00 00 00 10       	add    $0x10000000,%eax
f0104497:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010449a:	e8 27 18 00 00       	call   f0105cc6 <cpunum>
f010449f:	6b d0 74             	imul   $0x74,%eax,%edx
f01044a2:	81 c2 20 30 21 f0    	add    $0xf0213020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01044a8:	b8 02 00 00 00       	mov    $0x2,%eax
f01044ad:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01044b1:	83 ec 0c             	sub    $0xc,%esp
f01044b4:	68 c0 03 12 f0       	push   $0xf01203c0
f01044b9:	e8 13 1b 00 00       	call   f0105fd1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01044be:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01044c0:	e8 01 18 00 00       	call   f0105cc6 <cpunum>
f01044c5:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01044c8:	8b 80 30 30 21 f0    	mov    -0xfdecfd0(%eax),%eax
f01044ce:	bd 00 00 00 00       	mov    $0x0,%ebp
f01044d3:	89 c4                	mov    %eax,%esp
f01044d5:	6a 00                	push   $0x0
f01044d7:	6a 00                	push   $0x0
f01044d9:	f4                   	hlt    
f01044da:	eb fd                	jmp    f01044d9 <sched_halt+0xce>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01044dc:	83 c4 10             	add    $0x10,%esp
f01044df:	c9                   	leave  
f01044e0:	c3                   	ret    

f01044e1 <sched_yield>:
};
*/
// Choose a user environment to run and run it.
void
sched_yield(void)
{
f01044e1:	55                   	push   %ebp
f01044e2:	89 e5                	mov    %esp,%ebp
f01044e4:	56                   	push   %esi
f01044e5:	53                   	push   %ebx

	//	e = &envs[ENVX(envid)];
	//cprintf("\tget in sched_yield.\n");
	int running_env_index = -1;
	//cprintf("curenv is:%d\n", curenv);	
	if(curenv == 0){
f01044e6:	e8 db 17 00 00       	call   f0105cc6 <cpunum>
f01044eb:	6b d0 74             	imul   $0x74,%eax,%edx
		running_env_index = -1;
f01044ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	//	e = &envs[ENVX(envid)];
	//cprintf("\tget in sched_yield.\n");
	int running_env_index = -1;
	//cprintf("curenv is:%d\n", curenv);	
	if(curenv == 0){
f01044f3:	83 ba 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%edx)
f01044fa:	74 16                	je     f0104512 <sched_yield+0x31>
		running_env_index = -1;
	}else{
		//cprintf("\t WE MAY CRUSH HERE.\n");
		running_env_index = ENVX(curenv->env_id);
f01044fc:	e8 c5 17 00 00       	call   f0105cc6 <cpunum>
f0104501:	6b c0 74             	imul   $0x74,%eax,%eax
f0104504:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010450a:	8b 40 48             	mov    0x48(%eax),%eax
f010450d:	25 ff 03 00 00       	and    $0x3ff,%eax
		running_env_index++;
		if(running_env_index == NENV){
			running_env_index = 0;
		}
	//	cprintf("%d ",running_env_index); 
		if(envs[running_env_index].env_status == ENV_RUNNABLE){
f0104512:	8b 35 44 22 21 f0    	mov    0xf0212244,%esi
f0104518:	b9 00 04 00 00       	mov    $0x400,%ecx
	

		//cprintf("%d ",running_env_id);
		running_env_index++;
		if(running_env_index == NENV){
			running_env_index = 0;
f010451d:	bb 00 00 00 00       	mov    $0x0,%ebx
	{

	

		//cprintf("%d ",running_env_id);
		running_env_index++;
f0104522:	83 c0 01             	add    $0x1,%eax
		if(running_env_index == NENV){
			running_env_index = 0;
f0104525:	3d 00 04 00 00       	cmp    $0x400,%eax
f010452a:	0f 44 c3             	cmove  %ebx,%eax
		}
	//	cprintf("%d ",running_env_index); 
		if(envs[running_env_index].env_status == ENV_RUNNABLE){
f010452d:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104530:	01 f2                	add    %esi,%edx
f0104532:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104536:	75 09                	jne    f0104541 <sched_yield+0x60>
			//env_run(&envs[0]);
//			cprintf("sched.c we are really running envid:%d\n",running_env_id);
//			cprintf("xxx.\n");
//			cprintf("read to run.\n");
//			cprintf("running_env_index is:%d\n",running_env_index);
			env_run(&envs[running_env_index]);			
f0104538:	83 ec 0c             	sub    $0xc,%esp
f010453b:	52                   	push   %edx
f010453c:	e8 10 f1 ff ff       	call   f0103651 <env_run>
//	cprintf("the curenv->env_id is:%x\n",curenv);
	}
	//cprintf("the real running env_id:%d\n",ENVX(curenv->env_id));
	//cprintf("The running_env_id is:%d\n",running_env_id);
	int count = 1024;
	while(count--)
f0104541:	83 e9 01             	sub    $0x1,%ecx
f0104544:	75 dc                	jne    f0104522 <sched_yield+0x41>
	}
	//if the code run here,it says that there is only one env which is
	//running but now and here we are in kern mode,so if we don't chose
	//the running env to run we will trap in sched_halt().AND WE ARE AT
	//KERNEL MODE!
	if(curenv && curenv->env_status == ENV_RUNNING){
f0104546:	e8 7b 17 00 00       	call   f0105cc6 <cpunum>
f010454b:	6b c0 74             	imul   $0x74,%eax,%eax
f010454e:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104555:	74 2a                	je     f0104581 <sched_yield+0xa0>
f0104557:	e8 6a 17 00 00       	call   f0105cc6 <cpunum>
f010455c:	6b c0 74             	imul   $0x74,%eax,%eax
f010455f:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104565:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104569:	75 16                	jne    f0104581 <sched_yield+0xa0>
	//	cprintf("I AM THE ONLY ONE ENV.\n");
	//	cprintf("curenv is:%x\n", curenv);
		env_run(curenv);
f010456b:	e8 56 17 00 00       	call   f0105cc6 <cpunum>
f0104570:	83 ec 0c             	sub    $0xc,%esp
f0104573:	6b c0 74             	imul   $0x74,%eax,%eax
f0104576:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f010457c:	e8 d0 f0 ff ff       	call   f0103651 <env_run>
		
		return;
	}
	
	// sched_halt never returns
	cprintf("now in kernel mode, no work to do, so to halt.\n");
f0104581:	83 ec 0c             	sub    $0xc,%esp
f0104584:	68 dc 7c 10 f0       	push   $0xf0107cdc
f0104589:	e8 e1 f2 ff ff       	call   f010386f <cprintf>
	sched_halt();
f010458e:	e8 78 fe ff ff       	call   f010440b <sched_halt>
    }
 
	// sched_halt never returns
	sched_halt();
*/
}
f0104593:	83 c4 10             	add    $0x10,%esp
f0104596:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104599:	5b                   	pop    %ebx
f010459a:	5e                   	pop    %esi
f010459b:	5d                   	pop    %ebp
f010459c:	c3                   	ret    

f010459d <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010459d:	55                   	push   %ebp
f010459e:	89 e5                	mov    %esp,%ebp
f01045a0:	57                   	push   %edi
f01045a1:	56                   	push   %esi
f01045a2:	53                   	push   %ebx
f01045a3:	83 ec 1c             	sub    $0x1c,%esp
f01045a6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
f01045a9:	83 f8 0d             	cmp    $0xd,%eax
f01045ac:	0f 87 27 06 00 00    	ja     f0104bd9 <syscall+0x63c>
f01045b2:	ff 24 85 b8 7d 10 f0 	jmp    *-0xfef8248(,%eax,4)
	// LAB 3: Your code here.


	struct Env *e;
	//envid2env(sys_getenvid(), &e, 1);
	user_mem_assert(curenv, s, len, PTE_U);
f01045b9:	e8 08 17 00 00       	call   f0105cc6 <cpunum>
f01045be:	6a 04                	push   $0x4
f01045c0:	ff 75 10             	pushl  0x10(%ebp)
f01045c3:	ff 75 0c             	pushl  0xc(%ebp)
f01045c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c9:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01045cf:	e8 cf e8 ff ff       	call   f0102ea3 <user_mem_assert>

	cprintf("%.*s", len, s);
f01045d4:	83 c4 0c             	add    $0xc,%esp
f01045d7:	ff 75 0c             	pushl  0xc(%ebp)
f01045da:	ff 75 10             	pushl  0x10(%ebp)
f01045dd:	68 19 7d 10 f0       	push   $0xf0107d19
f01045e2:	e8 88 f2 ff ff       	call   f010386f <cprintf>
f01045e7:	83 c4 10             	add    $0x10,%esp
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01045ea:	e8 b2 c0 ff ff       	call   f01006a1 <cons_getc>
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
       	       case SYS_cputs:
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
f01045ef:	e9 f1 05 00 00       	jmp    f0104be5 <syscall+0x648>
       	       case SYS_getenvid:
           		 assert(curenv);
f01045f4:	e8 cd 16 00 00       	call   f0105cc6 <cpunum>
f01045f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01045fc:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104603:	75 19                	jne    f010461e <syscall+0x81>
f0104605:	68 42 7a 10 f0       	push   $0xf0107a42
f010460a:	68 e7 73 10 f0       	push   $0xf01073e7
f010460f:	68 95 02 00 00       	push   $0x295
f0104614:	68 1e 7d 10 f0       	push   $0xf0107d1e
f0104619:	e8 76 ba ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010461e:	e8 a3 16 00 00       	call   f0105cc6 <cpunum>
f0104623:	6b c0 74             	imul   $0x74,%eax,%eax
f0104626:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010462c:	8b 40 48             	mov    0x48(%eax),%eax
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
       	       case SYS_getenvid:
           		 assert(curenv);
            		return sys_getenvid();
f010462f:	e9 b1 05 00 00       	jmp    f0104be5 <syscall+0x648>
      	       case SYS_env_destroy:
          		  assert(curenv);
f0104634:	e8 8d 16 00 00       	call   f0105cc6 <cpunum>
f0104639:	6b c0 74             	imul   $0x74,%eax,%eax
f010463c:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104643:	75 19                	jne    f010465e <syscall+0xc1>
f0104645:	68 42 7a 10 f0       	push   $0xf0107a42
f010464a:	68 e7 73 10 f0       	push   $0xf01073e7
f010464f:	68 98 02 00 00       	push   $0x298
f0104654:	68 1e 7d 10 f0       	push   $0xf0107d1e
f0104659:	e8 36 ba ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010465e:	e8 63 16 00 00       	call   f0105cc6 <cpunum>
{
	
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104663:	83 ec 04             	sub    $0x4,%esp
f0104666:	6a 01                	push   $0x1
f0104668:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010466b:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010466c:	6b c0 74             	imul   $0x74,%eax,%eax
f010466f:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
{
	
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104675:	ff 70 48             	pushl  0x48(%eax)
f0104678:	e8 02 e9 ff ff       	call   f0102f7f <envid2env>
f010467d:	83 c4 10             	add    $0x10,%esp
f0104680:	85 c0                	test   %eax,%eax
f0104682:	0f 88 5d 05 00 00    	js     f0104be5 <syscall+0x648>
		return r;

	if (e == curenv)
f0104688:	e8 39 16 00 00       	call   f0105cc6 <cpunum>
f010468d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104690:	6b c0 74             	imul   $0x74,%eax,%eax
f0104693:	39 90 28 30 21 f0    	cmp    %edx,-0xfdecfd8(%eax)
f0104699:	75 23                	jne    f01046be <syscall+0x121>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010469b:	e8 26 16 00 00       	call   f0105cc6 <cpunum>
f01046a0:	83 ec 08             	sub    $0x8,%esp
f01046a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a6:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01046ac:	ff 70 48             	pushl  0x48(%eax)
f01046af:	68 2d 7d 10 f0       	push   $0xf0107d2d
f01046b4:	e8 b6 f1 ff ff       	call   f010386f <cprintf>
f01046b9:	83 c4 10             	add    $0x10,%esp
f01046bc:	eb 25                	jmp    f01046e3 <syscall+0x146>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01046be:	8b 5a 48             	mov    0x48(%edx),%ebx
f01046c1:	e8 00 16 00 00       	call   f0105cc6 <cpunum>
f01046c6:	83 ec 04             	sub    $0x4,%esp
f01046c9:	53                   	push   %ebx
f01046ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01046cd:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f01046d3:	ff 70 48             	pushl  0x48(%eax)
f01046d6:	68 48 7d 10 f0       	push   $0xf0107d48
f01046db:	e8 8f f1 ff ff       	call   f010386f <cprintf>
f01046e0:	83 c4 10             	add    $0x10,%esp
	//cprintf("xdest\n");
	cprintf("going to destroy user program.\n");
f01046e3:	83 ec 0c             	sub    $0xc,%esp
f01046e6:	68 70 7d 10 f0       	push   $0xf0107d70
f01046eb:	e8 7f f1 ff ff       	call   f010386f <cprintf>
	env_destroy(e);
f01046f0:	83 c4 04             	add    $0x4,%esp
f01046f3:	ff 75 e4             	pushl  -0x1c(%ebp)
f01046f6:	e8 9e ee ff ff       	call   f0103599 <env_destroy>
	cprintf("after destroy.\n");
f01046fb:	c7 04 24 60 7d 10 f0 	movl   $0xf0107d60,(%esp)
f0104702:	e8 68 f1 ff ff       	call   f010386f <cprintf>
f0104707:	83 c4 10             	add    $0x10,%esp
	//if("xdest."){;}
	//cprintf("xdest.\n");
	return 0;
f010470a:	b8 00 00 00 00       	mov    $0x0,%eax
f010470f:	e9 d1 04 00 00       	jmp    f0104be5 <syscall+0x648>
            		return sys_getenvid();
      	       case SYS_env_destroy:
          		  assert(curenv);
            		return sys_env_destroy(sys_getenvid());
	       case SYS_yield:
			assert(curenv);
f0104714:	e8 ad 15 00 00       	call   f0105cc6 <cpunum>
f0104719:	6b c0 74             	imul   $0x74,%eax,%eax
f010471c:	83 b8 28 30 21 f0 00 	cmpl   $0x0,-0xfdecfd8(%eax)
f0104723:	75 19                	jne    f010473e <syscall+0x1a1>
f0104725:	68 42 7a 10 f0       	push   $0xf0107a42
f010472a:	68 e7 73 10 f0       	push   $0xf01073e7
f010472f:	68 9b 02 00 00       	push   $0x29b
f0104734:	68 1e 7d 10 f0       	push   $0xf0107d1e
f0104739:	e8 56 b9 ff ff       	call   f0100094 <_panic>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010473e:	e8 9e fd ff ff       	call   f01044e1 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env * newenv_store;
	if(curenv->env_id == 0)
f0104743:	e8 7e 15 00 00       	call   f0105cc6 <cpunum>
f0104748:	6b c0 74             	imul   $0x74,%eax,%eax
f010474b:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104751:	8b 40 48             	mov    0x48(%eax),%eax
f0104754:	85 c0                	test   %eax,%eax
f0104756:	0f 84 89 04 00 00    	je     f0104be5 <syscall+0x648>
		return 0;
	int r_env_alloc = env_alloc(&newenv_store,curenv->env_id);
f010475c:	e8 65 15 00 00       	call   f0105cc6 <cpunum>
f0104761:	83 ec 08             	sub    $0x8,%esp
f0104764:	6b c0 74             	imul   $0x74,%eax,%eax
f0104767:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f010476d:	ff 70 48             	pushl  0x48(%eax)
f0104770:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104773:	50                   	push   %eax
f0104774:	e8 7a e9 ff ff       	call   f01030f3 <env_alloc>
	
	if(r_env_alloc<0)
f0104779:	83 c4 10             	add    $0x10,%esp
f010477c:	85 c0                	test   %eax,%eax
f010477e:	0f 88 61 04 00 00    	js     f0104be5 <syscall+0x648>
		return r_env_alloc;
	
	newenv_store->env_status = ENV_NOT_RUNNABLE;
f0104784:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104787:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove(&newenv_store->env_tf,&curenv->env_tf,sizeof(curenv->env_tf));
f010478e:	e8 33 15 00 00       	call   f0105cc6 <cpunum>
f0104793:	83 ec 04             	sub    $0x4,%esp
f0104796:	6a 44                	push   $0x44
f0104798:	6b c0 74             	imul   $0x74,%eax,%eax
f010479b:	ff b0 28 30 21 f0    	pushl  -0xfdecfd8(%eax)
f01047a1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01047a4:	e8 48 0f 00 00       	call   f01056f1 <memmove>
	newenv_store->env_tf.tf_regs.reg_eax =0;
f01047a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047ac:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv_store->env_id;
f01047b3:	8b 40 48             	mov    0x48(%eax),%eax
f01047b6:	83 c4 10             	add    $0x10,%esp
f01047b9:	e9 27 04 00 00       	jmp    f0104be5 <syscall+0x648>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01047be:	83 ec 04             	sub    $0x4,%esp
f01047c1:	6a 01                	push   $0x1
f01047c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047c6:	50                   	push   %eax
f01047c7:	ff 75 0c             	pushl  0xc(%ebp)
f01047ca:	e8 b0 e7 ff ff       	call   f0102f7f <envid2env>
	//cprintf("r_value is:%d\n", r_value);
	if(r_value)
f01047cf:	83 c4 10             	add    $0x10,%esp
f01047d2:	85 c0                	test   %eax,%eax
f01047d4:	0f 85 0b 04 00 00    	jne    f0104be5 <syscall+0x648>
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f01047da:	8b 45 10             	mov    0x10(%ebp),%eax
f01047dd:	83 e8 02             	sub    $0x2,%eax
f01047e0:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01047e5:	75 13                	jne    f01047fa <syscall+0x25d>
		return -E_INVAL;
	newenv_store->env_status = status;
f01047e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047ea:	8b 7d 10             	mov    0x10(%ebp),%edi
f01047ed:	89 78 54             	mov    %edi,0x54(%eax)

	return 0;
f01047f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01047f5:	e9 eb 03 00 00       	jmp    f0104be5 <syscall+0x648>
	int r_value = envid2env(envid,&newenv_store,1);
	//cprintf("r_value is:%d\n", r_value);
	if(r_value)
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f01047fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			sys_yield();
			return 1;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f01047ff:	e9 e1 03 00 00       	jmp    f0104be5 <syscall+0x648>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	//panic("\t we panic at sys_env_set_pgfault_upcall.\n");
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f0104804:	83 ec 04             	sub    $0x4,%esp
f0104807:	6a 01                	push   $0x1
f0104809:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010480c:	50                   	push   %eax
f010480d:	ff 75 0c             	pushl  0xc(%ebp)
f0104810:	e8 6a e7 ff ff       	call   f0102f7f <envid2env>
	if(r_value){
f0104815:	83 c4 10             	add    $0x10,%esp
f0104818:	85 c0                	test   %eax,%eax
f010481a:	0f 85 c5 03 00 00    	jne    f0104be5 <syscall+0x648>
		return r_value;
	}
	newenv_store->env_pgfault_upcall = func;	
f0104820:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104823:	8b 75 10             	mov    0x10(%ebp),%esi
f0104826:	89 72 64             	mov    %esi,0x64(%edx)
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
f0104829:	e9 b7 03 00 00       	jmp    f0104be5 <syscall+0x648>

	// LAB 4: Your code here.
//	cprintf("the kernel env index is:%d\n",ENVX(curenv->env_id));
	//cprintf("get in sys_page_alloc.\n");
	struct Env *newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f010482e:	83 ec 04             	sub    $0x4,%esp
f0104831:	6a 01                	push   $0x1
f0104833:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104836:	50                   	push   %eax
f0104837:	ff 75 0c             	pushl  0xc(%ebp)
f010483a:	e8 40 e7 ff ff       	call   f0102f7f <envid2env>
	if(r_value)
f010483f:	83 c4 10             	add    $0x10,%esp
f0104842:	85 c0                	test   %eax,%eax
f0104844:	0f 85 9b 03 00 00    	jne    f0104be5 <syscall+0x648>
		return r_value;
	//cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
f010484a:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104851:	77 45                	ja     f0104898 <syscall+0x2fb>
f0104853:	8b 45 10             	mov    0x10(%ebp),%eax
f0104856:	c1 e0 14             	shl    $0x14,%eax
f0104859:	85 c0                	test   %eax,%eax
f010485b:	75 45                	jne    f01048a2 <syscall+0x305>
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
		return -E_INVAL;
	*/
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f010485d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104860:	83 e0 05             	and    $0x5,%eax
f0104863:	83 f8 05             	cmp    $0x5,%eax
f0104866:	75 44                	jne    f01048ac <syscall+0x30f>
	
	struct PageInfo*pp;
	pp = page_alloc(0);
f0104868:	83 ec 0c             	sub    $0xc,%esp
f010486b:	6a 00                	push   $0x0
f010486d:	e8 70 c7 ff ff       	call   f0100fe2 <page_alloc>
	//cprintf("after page_alloc.\n");
	if(!pp)
f0104872:	83 c4 10             	add    $0x10,%esp
f0104875:	85 c0                	test   %eax,%eax
f0104877:	74 3d                	je     f01048b6 <syscall+0x319>
		return -E_NO_MEM;

	int ret = page_insert(newenv_store->env_pgdir,pp,va,perm);	
f0104879:	ff 75 14             	pushl  0x14(%ebp)
f010487c:	ff 75 10             	pushl  0x10(%ebp)
f010487f:	50                   	push   %eax
f0104880:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104883:	ff 70 60             	pushl  0x60(%eax)
f0104886:	e8 09 cb ff ff       	call   f0101394 <page_insert>
f010488b:	83 c4 10             	add    $0x10,%esp
	}
	*/	
	//cprintf("after page_insert.\n");	
	if(!ret)
		return ret;
	return 0;
f010488e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104893:	e9 4d 03 00 00       	jmp    f0104be5 <syscall+0x648>
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	//cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
		return -E_INVAL;
f0104898:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010489d:	e9 43 03 00 00       	jmp    f0104be5 <syscall+0x648>
f01048a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048a7:	e9 39 03 00 00       	jmp    f0104be5 <syscall+0x648>
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
		return -E_INVAL;
	*/
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f01048ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048b1:	e9 2f 03 00 00       	jmp    f0104be5 <syscall+0x648>
	
	struct PageInfo*pp;
	pp = page_alloc(0);
	//cprintf("after page_alloc.\n");
	if(!pp)
		return -E_NO_MEM;
f01048b6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f01048bb:	e9 25 03 00 00       	jmp    f0104be5 <syscall+0x648>
	// LAB 4: Your code here.
	//panic("sys_page_map not implemented");
*/
//copy from internet. clann24
struct Env *se, *de;
	int ret = envid2env(srcenvid, &se, 1);
f01048c0:	83 ec 04             	sub    $0x4,%esp
f01048c3:	6a 01                	push   $0x1
f01048c5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01048c8:	50                   	push   %eax
f01048c9:	ff 75 0c             	pushl  0xc(%ebp)
f01048cc:	e8 ae e6 ff ff       	call   f0102f7f <envid2env>
	if (ret) return ret;	//bad_env
f01048d1:	83 c4 10             	add    $0x10,%esp
f01048d4:	85 c0                	test   %eax,%eax
f01048d6:	0f 85 09 03 00 00    	jne    f0104be5 <syscall+0x648>
	ret = envid2env(dstenvid, &de, 1);
f01048dc:	83 ec 04             	sub    $0x4,%esp
f01048df:	6a 01                	push   $0x1
f01048e1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01048e4:	50                   	push   %eax
f01048e5:	ff 75 14             	pushl  0x14(%ebp)
f01048e8:	e8 92 e6 ff ff       	call   f0102f7f <envid2env>
	if (ret) return ret;	//bad_env
f01048ed:	83 c4 10             	add    $0x10,%esp
f01048f0:	85 c0                	test   %eax,%eax
f01048f2:	0f 85 ed 02 00 00    	jne    f0104be5 <syscall+0x648>
	// cprintf("src env: %x, dst env: %x, src va: %x, dst va: %x\n", 
		// se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
f01048f8:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048ff:	77 73                	ja     f0104974 <syscall+0x3d7>
f0104901:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104908:	77 6a                	ja     f0104974 <syscall+0x3d7>
f010490a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104911:	75 6b                	jne    f010497e <syscall+0x3e1>
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;
f0104913:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		// se->env_id, de->env_id, srcva, dstva);

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
f0104918:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010491f:	0f 85 c0 02 00 00    	jne    f0104be5 <syscall+0x648>
		return -E_INVAL;

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
f0104925:	83 ec 04             	sub    $0x4,%esp
f0104928:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010492b:	50                   	push   %eax
f010492c:	ff 75 10             	pushl  0x10(%ebp)
f010492f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104932:	ff 70 60             	pushl  0x60(%eax)
f0104935:	e8 71 c9 ff ff       	call   f01012ab <page_lookup>
	if (!pg) return -E_INVAL;
f010493a:	83 c4 10             	add    $0x10,%esp
f010493d:	85 c0                	test   %eax,%eax
f010493f:	74 47                	je     f0104988 <syscall+0x3eb>

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104941:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104944:	83 e2 05             	and    $0x5,%edx
f0104947:	83 fa 05             	cmp    $0x5,%edx
f010494a:	75 46                	jne    f0104992 <syscall+0x3f5>

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f010494c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010494f:	f6 02 02             	testb  $0x2,(%edx)
f0104952:	75 06                	jne    f010495a <syscall+0x3bd>
f0104954:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104958:	75 42                	jne    f010499c <syscall+0x3ff>

	//	-E_NO_MEM if there's no memory to allocate any necessary page tables.

	ret = page_insert(de->env_pgdir, pg, dstva, perm);
f010495a:	ff 75 1c             	pushl  0x1c(%ebp)
f010495d:	ff 75 18             	pushl  0x18(%ebp)
f0104960:	50                   	push   %eax
f0104961:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104964:	ff 70 60             	pushl  0x60(%eax)
f0104967:	e8 28 ca ff ff       	call   f0101394 <page_insert>
f010496c:	83 c4 10             	add    $0x10,%esp
f010496f:	e9 71 02 00 00       	jmp    f0104be5 <syscall+0x648>

	//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
	//		or dstva >= UTOP or dstva is not page-aligned.
	if (srcva>=(void*)UTOP || dstva>=(void*)UTOP || 
		ROUNDDOWN(srcva,PGSIZE)!=srcva || ROUNDDOWN(dstva,PGSIZE)!=dstva) 
		return -E_INVAL;
f0104974:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104979:	e9 67 02 00 00       	jmp    f0104be5 <syscall+0x648>
f010497e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104983:	e9 5d 02 00 00       	jmp    f0104be5 <syscall+0x648>

	//	-E_INVAL is srcva is not mapped in srcenvid's address space.
	pte_t *pte;
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
	if (!pg) return -E_INVAL;
f0104988:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010498d:	e9 53 02 00 00       	jmp    f0104be5 <syscall+0x648>

	//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
	int flag = PTE_U|PTE_P;
	if ((perm & flag) != flag) return -E_INVAL;
f0104992:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104997:	e9 49 02 00 00       	jmp    f0104be5 <syscall+0x648>

	//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
	//		address space.
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f010499c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
f01049a1:	e9 3f 02 00 00       	jmp    f0104be5 <syscall+0x648>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01049a6:	83 ec 04             	sub    $0x4,%esp
f01049a9:	6a 01                	push   $0x1
f01049ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01049ae:	50                   	push   %eax
f01049af:	ff 75 0c             	pushl  0xc(%ebp)
f01049b2:	e8 c8 e5 ff ff       	call   f0102f7f <envid2env>
	if(r_value == -E_BAD_ENV)
f01049b7:	83 c4 10             	add    $0x10,%esp
f01049ba:	83 f8 fe             	cmp    $0xfffffffe,%eax
f01049bd:	74 31                	je     f01049f0 <syscall+0x453>
		return -E_BAD_ENV;
	
	if(va>=(void*)UTOP)
f01049bf:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01049c6:	77 32                	ja     f01049fa <syscall+0x45d>
		return -E_INVAL;

	if(((unsigned int)va<<20))
f01049c8:	8b 45 10             	mov    0x10(%ebp),%eax
f01049cb:	c1 e0 14             	shl    $0x14,%eax
f01049ce:	85 c0                	test   %eax,%eax
f01049d0:	75 32                	jne    f0104a04 <syscall+0x467>
		return -E_INVAL;

	page_remove(newenv_store->env_pgdir,va);
f01049d2:	83 ec 08             	sub    $0x8,%esp
f01049d5:	ff 75 10             	pushl  0x10(%ebp)
f01049d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049db:	ff 70 60             	pushl  0x60(%eax)
f01049de:	e8 63 c9 ff ff       	call   f0101346 <page_remove>
f01049e3:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f01049e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01049eb:	e9 f5 01 00 00       	jmp    f0104be5 <syscall+0x648>
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value == -E_BAD_ENV)
		return -E_BAD_ENV;
f01049f0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01049f5:	e9 eb 01 00 00       	jmp    f0104be5 <syscall+0x648>
	
	if(va>=(void*)UTOP)
		return -E_INVAL;
f01049fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049ff:	e9 e1 01 00 00       	jmp    f0104be5 <syscall+0x648>

	if(((unsigned int)va<<20))
		return -E_INVAL;
f0104a04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
f0104a09:	e9 d7 01 00 00       	jmp    f0104be5 <syscall+0x648>
		
	}	
	return 0;
*/
struct Env *e;
	int ret = envid2env(envid, &e, 0);
f0104a0e:	83 ec 04             	sub    $0x4,%esp
f0104a11:	6a 00                	push   $0x0
f0104a13:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104a16:	50                   	push   %eax
f0104a17:	ff 75 0c             	pushl  0xc(%ebp)
f0104a1a:	e8 60 e5 ff ff       	call   f0102f7f <envid2env>
	if (ret) return ret;//bad env
f0104a1f:	83 c4 10             	add    $0x10,%esp
f0104a22:	85 c0                	test   %eax,%eax
f0104a24:	0f 85 bb 01 00 00    	jne    f0104be5 <syscall+0x648>
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104a2a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a2d:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104a31:	0f 84 e8 00 00 00    	je     f0104b1f <syscall+0x582>
	if (srcva < (void*)UTOP) {
f0104a37:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104a3e:	0f 87 9f 00 00 00    	ja     f0104ae3 <syscall+0x546>
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104a44:	e8 7d 12 00 00       	call   f0105cc6 <cpunum>
f0104a49:	83 ec 04             	sub    $0x4,%esp
f0104a4c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104a4f:	52                   	push   %edx
f0104a50:	ff 75 14             	pushl  0x14(%ebp)
f0104a53:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a56:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104a5c:	ff 70 60             	pushl  0x60(%eax)
f0104a5f:	e8 47 c8 ff ff       	call   f01012ab <page_lookup>
f0104a64:	89 c1                	mov    %eax,%ecx
		if (!pg) return -E_INVAL;
f0104a66:	83 c4 10             	add    $0x10,%esp
f0104a69:	85 c0                	test   %eax,%eax
f0104a6b:	74 6c                	je     f0104ad9 <syscall+0x53c>
		if ((*pte & perm & 7) != (perm & 7)) return -E_INVAL;
f0104a6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a70:	8b 18                	mov    (%eax),%ebx
f0104a72:	89 da                	mov    %ebx,%edx
f0104a74:	f7 d2                	not    %edx
f0104a76:	23 55 18             	and    0x18(%ebp),%edx
f0104a79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a7e:	f6 c2 07             	test   $0x7,%dl
f0104a81:	0f 85 5e 01 00 00    	jne    f0104be5 <syscall+0x648>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0104a87:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104a8b:	74 09                	je     f0104a96 <syscall+0x4f9>
f0104a8d:	f6 c3 02             	test   $0x2,%bl
f0104a90:	0f 84 4f 01 00 00    	je     f0104be5 <syscall+0x648>
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
f0104a96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a9b:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104aa2:	0f 85 3d 01 00 00    	jne    f0104be5 <syscall+0x648>
		if (e->env_ipc_dstva < (void*)UTOP) {
f0104aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104aab:	8b 50 6c             	mov    0x6c(%eax),%edx
f0104aae:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f0104ab4:	77 2d                	ja     f0104ae3 <syscall+0x546>
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
f0104ab6:	ff 75 18             	pushl  0x18(%ebp)
f0104ab9:	52                   	push   %edx
f0104aba:	51                   	push   %ecx
f0104abb:	ff 70 60             	pushl  0x60(%eax)
f0104abe:	e8 d1 c8 ff ff       	call   f0101394 <page_insert>
			if (ret) return ret;
f0104ac3:	83 c4 10             	add    $0x10,%esp
f0104ac6:	85 c0                	test   %eax,%eax
f0104ac8:	0f 85 17 01 00 00    	jne    f0104be5 <syscall+0x648>
			e->env_ipc_perm = perm;
f0104ace:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ad1:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104ad4:	89 78 78             	mov    %edi,0x78(%eax)
f0104ad7:	eb 0a                	jmp    f0104ae3 <syscall+0x546>
	if (ret) return ret;//bad env
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
	if (srcva < (void*)UTOP) {
		pte_t *pte;
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!pg) return -E_INVAL;
f0104ad9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ade:	e9 02 01 00 00       	jmp    f0104be5 <syscall+0x648>
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
			if (ret) return ret;
			e->env_ipc_perm = perm;
		}
	}
	e->env_ipc_recving = 0;
f0104ae3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ae6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	e->env_ipc_from = curenv->env_id;
f0104aea:	e8 d7 11 00 00       	call   f0105cc6 <cpunum>
f0104aef:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af2:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104af8:	8b 40 48             	mov    0x48(%eax),%eax
f0104afb:	89 43 74             	mov    %eax,0x74(%ebx)
	e->env_ipc_value = value; 
f0104afe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b01:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b04:	89 48 70             	mov    %ecx,0x70(%eax)
	e->env_status = ENV_RUNNABLE;
f0104b07:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;
f0104b0e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104b15:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b1a:	e9 c6 00 00 00       	jmp    f0104be5 <syscall+0x648>
	return 0;
*/
struct Env *e;
	int ret = envid2env(envid, &e, 0);
	if (ret) return ret;//bad env
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104b1f:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send( (envid_t)a1, (uint32_t)a2, (void*)a3, (unsigned)a4 );
f0104b24:	e9 bc 00 00 00       	jmp    f0104be5 <syscall+0x648>
//	sys_yield();
	cprintf("in sys_ipc_recv. after sys_yield().\n");
	//panic("sys_ipc_recv not implemented");

*/
	if (dstva < (void*)UTOP) 
f0104b29:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104b30:	77 0d                	ja     f0104b3f <syscall+0x5a2>
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
f0104b32:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104b39:	0f 85 a1 00 00 00    	jne    f0104be0 <syscall+0x643>
			return -E_INVAL;
	curenv->env_ipc_recving = 1;
f0104b3f:	e8 82 11 00 00       	call   f0105cc6 <cpunum>
f0104b44:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b47:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104b4d:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104b51:	e8 70 11 00 00       	call   f0105cc6 <cpunum>
f0104b56:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b59:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104b5f:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104b66:	e8 5b 11 00 00       	call   f0105cc6 <cpunum>
f0104b6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6e:	8b 80 28 30 21 f0    	mov    -0xfdecfd8(%eax),%eax
f0104b74:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b77:	89 70 6c             	mov    %esi,0x6c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104b7a:	e8 62 f9 ff ff       	call   f01044e1 <sched_yield>
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f0104b7f:	83 ec 04             	sub    $0x4,%esp
f0104b82:	6a 01                	push   $0x1
f0104b84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b87:	50                   	push   %eax
f0104b88:	ff 75 0c             	pushl  0xc(%ebp)
f0104b8b:	e8 ef e3 ff ff       	call   f0102f7f <envid2env>
f0104b90:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;
f0104b92:	83 c4 10             	add    $0x10,%esp
f0104b95:	85 c0                	test   %eax,%eax
f0104b97:	75 3c                	jne    f0104bd5 <syscall+0x638>
	cprintf("\t\t OVER ENVID2ENV in set_trapframe.\n");
f0104b99:	83 ec 0c             	sub    $0xc,%esp
f0104b9c:	68 90 7d 10 f0       	push   $0xf0107d90
f0104ba1:	e8 c9 ec ff ff       	call   f010386f <cprintf>
	user_mem_assert(e, tf, sizeof(struct Trapframe), PTE_U);
f0104ba6:	6a 04                	push   $0x4
f0104ba8:	6a 44                	push   $0x44
f0104baa:	ff 75 10             	pushl  0x10(%ebp)
f0104bad:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104bb0:	e8 ee e2 ff ff       	call   f0102ea3 <user_mem_assert>
	e->env_tf = *tf;
f0104bb5:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104bba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bbd:	8b 75 10             	mov    0x10(%ebp),%esi
f0104bc0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_eflags |= FL_IF;
f0104bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bc5:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f0104bcc:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
f0104bd2:	83 c4 20             	add    $0x20,%esp
		case SYS_ipc_try_send:
			return sys_ipc_try_send( (envid_t)a1, (uint32_t)a2, (void*)a3, (unsigned)a4 );
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe((envid_t)a1, (void*)a2);
f0104bd5:	89 d8                	mov    %ebx,%eax
f0104bd7:	eb 0c                	jmp    f0104be5 <syscall+0x648>
	//syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
		default:
			return -E_INVAL;
f0104bd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104bde:	eb 05                	jmp    f0104be5 <syscall+0x648>
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send( (envid_t)a1, (uint32_t)a2, (void*)a3, (unsigned)a4 );
		case SYS_ipc_recv:
			return sys_ipc_recv((void*)a1);
f0104be0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return sys_env_set_trapframe((envid_t)a1, (void*)a2);
	//syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
		default:
			return -E_INVAL;
	}
}
f0104be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104be8:	5b                   	pop    %ebx
f0104be9:	5e                   	pop    %esi
f0104bea:	5f                   	pop    %edi
f0104beb:	5d                   	pop    %ebp
f0104bec:	c3                   	ret    

f0104bed <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104bed:	55                   	push   %ebp
f0104bee:	89 e5                	mov    %esp,%ebp
f0104bf0:	57                   	push   %edi
f0104bf1:	56                   	push   %esi
f0104bf2:	53                   	push   %ebx
f0104bf3:	83 ec 14             	sub    $0x14,%esp
f0104bf6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104bf9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104bfc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104bff:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104c02:	8b 1a                	mov    (%edx),%ebx
f0104c04:	8b 01                	mov    (%ecx),%eax
f0104c06:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c09:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104c10:	eb 7f                	jmp    f0104c91 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104c12:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104c15:	01 d8                	add    %ebx,%eax
f0104c17:	89 c6                	mov    %eax,%esi
f0104c19:	c1 ee 1f             	shr    $0x1f,%esi
f0104c1c:	01 c6                	add    %eax,%esi
f0104c1e:	d1 fe                	sar    %esi
f0104c20:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104c23:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c26:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c29:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c2b:	eb 03                	jmp    f0104c30 <stab_binsearch+0x43>
			m--;
f0104c2d:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104c30:	39 c3                	cmp    %eax,%ebx
f0104c32:	7f 0d                	jg     f0104c41 <stab_binsearch+0x54>
f0104c34:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104c38:	83 ea 0c             	sub    $0xc,%edx
f0104c3b:	39 f9                	cmp    %edi,%ecx
f0104c3d:	75 ee                	jne    f0104c2d <stab_binsearch+0x40>
f0104c3f:	eb 05                	jmp    f0104c46 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104c41:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104c44:	eb 4b                	jmp    f0104c91 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104c46:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c49:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104c4c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104c50:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c53:	76 11                	jbe    f0104c66 <stab_binsearch+0x79>
			*region_left = m;
f0104c55:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c58:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104c5a:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c5d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c64:	eb 2b                	jmp    f0104c91 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104c66:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104c69:	73 14                	jae    f0104c7f <stab_binsearch+0x92>
			*region_right = m - 1;
f0104c6b:	83 e8 01             	sub    $0x1,%eax
f0104c6e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104c71:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104c74:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c76:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104c7d:	eb 12                	jmp    f0104c91 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104c7f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104c82:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104c84:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104c88:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104c8a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104c91:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104c94:	0f 8e 78 ff ff ff    	jle    f0104c12 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104c9a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104c9e:	75 0f                	jne    f0104caf <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104ca0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ca3:	8b 00                	mov    (%eax),%eax
f0104ca5:	83 e8 01             	sub    $0x1,%eax
f0104ca8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104cab:	89 06                	mov    %eax,(%esi)
f0104cad:	eb 2c                	jmp    f0104cdb <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104caf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cb2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104cb4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cb7:	8b 0e                	mov    (%esi),%ecx
f0104cb9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cbc:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104cbf:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cc2:	eb 03                	jmp    f0104cc7 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104cc4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104cc7:	39 c8                	cmp    %ecx,%eax
f0104cc9:	7e 0b                	jle    f0104cd6 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104ccb:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104ccf:	83 ea 0c             	sub    $0xc,%edx
f0104cd2:	39 df                	cmp    %ebx,%edi
f0104cd4:	75 ee                	jne    f0104cc4 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104cd6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104cd9:	89 06                	mov    %eax,(%esi)
	}
}
f0104cdb:	83 c4 14             	add    $0x14,%esp
f0104cde:	5b                   	pop    %ebx
f0104cdf:	5e                   	pop    %esi
f0104ce0:	5f                   	pop    %edi
f0104ce1:	5d                   	pop    %ebp
f0104ce2:	c3                   	ret    

f0104ce3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ce3:	55                   	push   %ebp
f0104ce4:	89 e5                	mov    %esp,%ebp
f0104ce6:	57                   	push   %edi
f0104ce7:	56                   	push   %esi
f0104ce8:	53                   	push   %ebx
f0104ce9:	83 ec 2c             	sub    $0x2c,%esp
f0104cec:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104cef:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104cf2:	c7 06 f0 7d 10 f0    	movl   $0xf0107df0,(%esi)
	info->eip_line = 0;
f0104cf8:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104cff:	c7 46 08 f0 7d 10 f0 	movl   $0xf0107df0,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104d06:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104d0d:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104d10:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104d17:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104d1d:	77 21                	ja     f0104d40 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104d1f:	a1 00 00 20 00       	mov    0x200000,%eax
f0104d24:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104d27:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104d2c:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104d32:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104d35:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104d3b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104d3e:	eb 1a                	jmp    f0104d5a <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104d40:	c7 45 d0 d1 5f 11 f0 	movl   $0xf0115fd1,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104d47:	c7 45 cc dd 27 11 f0 	movl   $0xf01127dd,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104d4e:	b8 dc 27 11 f0       	mov    $0xf01127dc,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104d53:	c7 45 d4 90 83 10 f0 	movl   $0xf0108390,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d5a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104d5d:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104d60:	0f 83 2b 01 00 00    	jae    f0104e91 <debuginfo_eip+0x1ae>
f0104d66:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104d6a:	0f 85 28 01 00 00    	jne    f0104e98 <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d77:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104d7a:	29 d8                	sub    %ebx,%eax
f0104d7c:	c1 f8 02             	sar    $0x2,%eax
f0104d7f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104d85:	83 e8 01             	sub    $0x1,%eax
f0104d88:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104d8b:	57                   	push   %edi
f0104d8c:	6a 64                	push   $0x64
f0104d8e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d91:	89 c1                	mov    %eax,%ecx
f0104d93:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d96:	89 d8                	mov    %ebx,%eax
f0104d98:	e8 50 fe ff ff       	call   f0104bed <stab_binsearch>
	if (lfile == 0)
f0104d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104da0:	83 c4 08             	add    $0x8,%esp
f0104da3:	85 c0                	test   %eax,%eax
f0104da5:	0f 84 f4 00 00 00    	je     f0104e9f <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104dab:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104dae:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104db1:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104db4:	57                   	push   %edi
f0104db5:	6a 24                	push   $0x24
f0104db7:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104dba:	89 c1                	mov    %eax,%ecx
f0104dbc:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104dbf:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104dc2:	89 d8                	mov    %ebx,%eax
f0104dc4:	e8 24 fe ff ff       	call   f0104bed <stab_binsearch>

	if (lfun <= rfun) {
f0104dc9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104dcc:	83 c4 08             	add    $0x8,%esp
f0104dcf:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104dd2:	7f 24                	jg     f0104df8 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104dd4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104dd7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104dda:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104ddd:	8b 02                	mov    (%edx),%eax
f0104ddf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104de2:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104de5:	29 f9                	sub    %edi,%ecx
f0104de7:	39 c8                	cmp    %ecx,%eax
f0104de9:	73 05                	jae    f0104df0 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104deb:	01 f8                	add    %edi,%eax
f0104ded:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104df0:	8b 42 08             	mov    0x8(%edx),%eax
f0104df3:	89 46 10             	mov    %eax,0x10(%esi)
f0104df6:	eb 06                	jmp    f0104dfe <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104df8:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104dfb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104dfe:	83 ec 08             	sub    $0x8,%esp
f0104e01:	6a 3a                	push   $0x3a
f0104e03:	ff 76 08             	pushl  0x8(%esi)
f0104e06:	e8 7d 08 00 00       	call   f0105688 <strfind>
f0104e0b:	2b 46 08             	sub    0x8(%esi),%eax
f0104e0e:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e14:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104e17:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104e1a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104e1d:	83 c4 10             	add    $0x10,%esp
f0104e20:	eb 06                	jmp    f0104e28 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104e22:	83 eb 01             	sub    $0x1,%ebx
f0104e25:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e28:	39 fb                	cmp    %edi,%ebx
f0104e2a:	7c 2d                	jl     f0104e59 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104e2c:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104e30:	80 fa 84             	cmp    $0x84,%dl
f0104e33:	74 0b                	je     f0104e40 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104e35:	80 fa 64             	cmp    $0x64,%dl
f0104e38:	75 e8                	jne    f0104e22 <debuginfo_eip+0x13f>
f0104e3a:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104e3e:	74 e2                	je     f0104e22 <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104e40:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104e43:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104e46:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104e49:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104e4c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104e4f:	29 f8                	sub    %edi,%eax
f0104e51:	39 c2                	cmp    %eax,%edx
f0104e53:	73 04                	jae    f0104e59 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104e55:	01 fa                	add    %edi,%edx
f0104e57:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104e59:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104e5c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e5f:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104e64:	39 cb                	cmp    %ecx,%ebx
f0104e66:	7d 43                	jge    f0104eab <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104e68:	8d 53 01             	lea    0x1(%ebx),%edx
f0104e6b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104e6e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104e71:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104e74:	eb 07                	jmp    f0104e7d <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104e76:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104e7a:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104e7d:	39 ca                	cmp    %ecx,%edx
f0104e7f:	74 25                	je     f0104ea6 <debuginfo_eip+0x1c3>
f0104e81:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104e84:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104e88:	74 ec                	je     f0104e76 <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104e8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e8f:	eb 1a                	jmp    f0104eab <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e96:	eb 13                	jmp    f0104eab <debuginfo_eip+0x1c8>
f0104e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e9d:	eb 0c                	jmp    f0104eab <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ea4:	eb 05                	jmp    f0104eab <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104eae:	5b                   	pop    %ebx
f0104eaf:	5e                   	pop    %esi
f0104eb0:	5f                   	pop    %edi
f0104eb1:	5d                   	pop    %ebp
f0104eb2:	c3                   	ret    

f0104eb3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104eb3:	55                   	push   %ebp
f0104eb4:	89 e5                	mov    %esp,%ebp
f0104eb6:	57                   	push   %edi
f0104eb7:	56                   	push   %esi
f0104eb8:	53                   	push   %ebx
f0104eb9:	83 ec 1c             	sub    $0x1c,%esp
f0104ebc:	89 c7                	mov    %eax,%edi
f0104ebe:	89 d6                	mov    %edx,%esi
f0104ec0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ec3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ec6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ec9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104ecc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ecf:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ed4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ed7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104eda:	39 d3                	cmp    %edx,%ebx
f0104edc:	72 05                	jb     f0104ee3 <printnum+0x30>
f0104ede:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104ee1:	77 45                	ja     f0104f28 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104ee3:	83 ec 0c             	sub    $0xc,%esp
f0104ee6:	ff 75 18             	pushl  0x18(%ebp)
f0104ee9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eec:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104eef:	53                   	push   %ebx
f0104ef0:	ff 75 10             	pushl  0x10(%ebp)
f0104ef3:	83 ec 08             	sub    $0x8,%esp
f0104ef6:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104ef9:	ff 75 e0             	pushl  -0x20(%ebp)
f0104efc:	ff 75 dc             	pushl  -0x24(%ebp)
f0104eff:	ff 75 d8             	pushl  -0x28(%ebp)
f0104f02:	e8 b9 11 00 00       	call   f01060c0 <__udivdi3>
f0104f07:	83 c4 18             	add    $0x18,%esp
f0104f0a:	52                   	push   %edx
f0104f0b:	50                   	push   %eax
f0104f0c:	89 f2                	mov    %esi,%edx
f0104f0e:	89 f8                	mov    %edi,%eax
f0104f10:	e8 9e ff ff ff       	call   f0104eb3 <printnum>
f0104f15:	83 c4 20             	add    $0x20,%esp
f0104f18:	eb 18                	jmp    f0104f32 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104f1a:	83 ec 08             	sub    $0x8,%esp
f0104f1d:	56                   	push   %esi
f0104f1e:	ff 75 18             	pushl  0x18(%ebp)
f0104f21:	ff d7                	call   *%edi
f0104f23:	83 c4 10             	add    $0x10,%esp
f0104f26:	eb 03                	jmp    f0104f2b <printnum+0x78>
f0104f28:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104f2b:	83 eb 01             	sub    $0x1,%ebx
f0104f2e:	85 db                	test   %ebx,%ebx
f0104f30:	7f e8                	jg     f0104f1a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104f32:	83 ec 08             	sub    $0x8,%esp
f0104f35:	56                   	push   %esi
f0104f36:	83 ec 04             	sub    $0x4,%esp
f0104f39:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104f3c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f3f:	ff 75 dc             	pushl  -0x24(%ebp)
f0104f42:	ff 75 d8             	pushl  -0x28(%ebp)
f0104f45:	e8 a6 12 00 00       	call   f01061f0 <__umoddi3>
f0104f4a:	83 c4 14             	add    $0x14,%esp
f0104f4d:	0f be 80 fa 7d 10 f0 	movsbl -0xfef8206(%eax),%eax
f0104f54:	50                   	push   %eax
f0104f55:	ff d7                	call   *%edi
}
f0104f57:	83 c4 10             	add    $0x10,%esp
f0104f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f5d:	5b                   	pop    %ebx
f0104f5e:	5e                   	pop    %esi
f0104f5f:	5f                   	pop    %edi
f0104f60:	5d                   	pop    %ebp
f0104f61:	c3                   	ret    

f0104f62 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104f62:	55                   	push   %ebp
f0104f63:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104f65:	83 fa 01             	cmp    $0x1,%edx
f0104f68:	7e 0e                	jle    f0104f78 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104f6a:	8b 10                	mov    (%eax),%edx
f0104f6c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104f6f:	89 08                	mov    %ecx,(%eax)
f0104f71:	8b 02                	mov    (%edx),%eax
f0104f73:	8b 52 04             	mov    0x4(%edx),%edx
f0104f76:	eb 22                	jmp    f0104f9a <getuint+0x38>
	else if (lflag)
f0104f78:	85 d2                	test   %edx,%edx
f0104f7a:	74 10                	je     f0104f8c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104f7c:	8b 10                	mov    (%eax),%edx
f0104f7e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f81:	89 08                	mov    %ecx,(%eax)
f0104f83:	8b 02                	mov    (%edx),%eax
f0104f85:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f8a:	eb 0e                	jmp    f0104f9a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104f8c:	8b 10                	mov    (%eax),%edx
f0104f8e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104f91:	89 08                	mov    %ecx,(%eax)
f0104f93:	8b 02                	mov    (%edx),%eax
f0104f95:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104f9a:	5d                   	pop    %ebp
f0104f9b:	c3                   	ret    

f0104f9c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f9c:	55                   	push   %ebp
f0104f9d:	89 e5                	mov    %esp,%ebp
f0104f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104fa2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104fa6:	8b 10                	mov    (%eax),%edx
f0104fa8:	3b 50 04             	cmp    0x4(%eax),%edx
f0104fab:	73 0a                	jae    f0104fb7 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104fad:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104fb0:	89 08                	mov    %ecx,(%eax)
f0104fb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fb5:	88 02                	mov    %al,(%edx)
}
f0104fb7:	5d                   	pop    %ebp
f0104fb8:	c3                   	ret    

f0104fb9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104fb9:	55                   	push   %ebp
f0104fba:	89 e5                	mov    %esp,%ebp
f0104fbc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104fbf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104fc2:	50                   	push   %eax
f0104fc3:	ff 75 10             	pushl  0x10(%ebp)
f0104fc6:	ff 75 0c             	pushl  0xc(%ebp)
f0104fc9:	ff 75 08             	pushl  0x8(%ebp)
f0104fcc:	e8 05 00 00 00       	call   f0104fd6 <vprintfmt>
	va_end(ap);
}
f0104fd1:	83 c4 10             	add    $0x10,%esp
f0104fd4:	c9                   	leave  
f0104fd5:	c3                   	ret    

f0104fd6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104fd6:	55                   	push   %ebp
f0104fd7:	89 e5                	mov    %esp,%ebp
f0104fd9:	57                   	push   %edi
f0104fda:	56                   	push   %esi
f0104fdb:	53                   	push   %ebx
f0104fdc:	83 ec 2c             	sub    $0x2c,%esp
f0104fdf:	8b 75 08             	mov    0x8(%ebp),%esi
f0104fe2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104fe5:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104fe8:	eb 12                	jmp    f0104ffc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104fea:	85 c0                	test   %eax,%eax
f0104fec:	0f 84 d3 03 00 00    	je     f01053c5 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
f0104ff2:	83 ec 08             	sub    $0x8,%esp
f0104ff5:	53                   	push   %ebx
f0104ff6:	50                   	push   %eax
f0104ff7:	ff d6                	call   *%esi
f0104ff9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104ffc:	83 c7 01             	add    $0x1,%edi
f0104fff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105003:	83 f8 25             	cmp    $0x25,%eax
f0105006:	75 e2                	jne    f0104fea <vprintfmt+0x14>
f0105008:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010500c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0105013:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f010501a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105021:	ba 00 00 00 00       	mov    $0x0,%edx
f0105026:	eb 07                	jmp    f010502f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105028:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010502b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010502f:	8d 47 01             	lea    0x1(%edi),%eax
f0105032:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105035:	0f b6 07             	movzbl (%edi),%eax
f0105038:	0f b6 c8             	movzbl %al,%ecx
f010503b:	83 e8 23             	sub    $0x23,%eax
f010503e:	3c 55                	cmp    $0x55,%al
f0105040:	0f 87 64 03 00 00    	ja     f01053aa <vprintfmt+0x3d4>
f0105046:	0f b6 c0             	movzbl %al,%eax
f0105049:	ff 24 85 40 7f 10 f0 	jmp    *-0xfef80c0(,%eax,4)
f0105050:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105053:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0105057:	eb d6                	jmp    f010502f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105059:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010505c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105061:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105064:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105067:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010506b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010506e:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0105071:	83 fa 09             	cmp    $0x9,%edx
f0105074:	77 39                	ja     f01050af <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105076:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105079:	eb e9                	jmp    f0105064 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010507b:	8b 45 14             	mov    0x14(%ebp),%eax
f010507e:	8d 48 04             	lea    0x4(%eax),%ecx
f0105081:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105084:	8b 00                	mov    (%eax),%eax
f0105086:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105089:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010508c:	eb 27                	jmp    f01050b5 <vprintfmt+0xdf>
f010508e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105091:	85 c0                	test   %eax,%eax
f0105093:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105098:	0f 49 c8             	cmovns %eax,%ecx
f010509b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010509e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050a1:	eb 8c                	jmp    f010502f <vprintfmt+0x59>
f01050a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01050a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01050ad:	eb 80                	jmp    f010502f <vprintfmt+0x59>
f01050af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01050b2:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f01050b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01050b9:	0f 89 70 ff ff ff    	jns    f010502f <vprintfmt+0x59>
				width = precision, precision = -1;
f01050bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01050c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050c5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01050cc:	e9 5e ff ff ff       	jmp    f010502f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01050d1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01050d7:	e9 53 ff ff ff       	jmp    f010502f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01050dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01050df:	8d 50 04             	lea    0x4(%eax),%edx
f01050e2:	89 55 14             	mov    %edx,0x14(%ebp)
f01050e5:	83 ec 08             	sub    $0x8,%esp
f01050e8:	53                   	push   %ebx
f01050e9:	ff 30                	pushl  (%eax)
f01050eb:	ff d6                	call   *%esi
			break;
f01050ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01050f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01050f3:	e9 04 ff ff ff       	jmp    f0104ffc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01050f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01050fb:	8d 50 04             	lea    0x4(%eax),%edx
f01050fe:	89 55 14             	mov    %edx,0x14(%ebp)
f0105101:	8b 00                	mov    (%eax),%eax
f0105103:	99                   	cltd   
f0105104:	31 d0                	xor    %edx,%eax
f0105106:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105108:	83 f8 0f             	cmp    $0xf,%eax
f010510b:	7f 0b                	jg     f0105118 <vprintfmt+0x142>
f010510d:	8b 14 85 a0 80 10 f0 	mov    -0xfef7f60(,%eax,4),%edx
f0105114:	85 d2                	test   %edx,%edx
f0105116:	75 18                	jne    f0105130 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0105118:	50                   	push   %eax
f0105119:	68 12 7e 10 f0       	push   $0xf0107e12
f010511e:	53                   	push   %ebx
f010511f:	56                   	push   %esi
f0105120:	e8 94 fe ff ff       	call   f0104fb9 <printfmt>
f0105125:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105128:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010512b:	e9 cc fe ff ff       	jmp    f0104ffc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105130:	52                   	push   %edx
f0105131:	68 f9 73 10 f0       	push   $0xf01073f9
f0105136:	53                   	push   %ebx
f0105137:	56                   	push   %esi
f0105138:	e8 7c fe ff ff       	call   f0104fb9 <printfmt>
f010513d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105140:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105143:	e9 b4 fe ff ff       	jmp    f0104ffc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105148:	8b 45 14             	mov    0x14(%ebp),%eax
f010514b:	8d 50 04             	lea    0x4(%eax),%edx
f010514e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105151:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105153:	85 ff                	test   %edi,%edi
f0105155:	b8 0b 7e 10 f0       	mov    $0xf0107e0b,%eax
f010515a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010515d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105161:	0f 8e 94 00 00 00    	jle    f01051fb <vprintfmt+0x225>
f0105167:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010516b:	0f 84 98 00 00 00    	je     f0105209 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105171:	83 ec 08             	sub    $0x8,%esp
f0105174:	ff 75 c8             	pushl  -0x38(%ebp)
f0105177:	57                   	push   %edi
f0105178:	e8 c1 03 00 00       	call   f010553e <strnlen>
f010517d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105180:	29 c1                	sub    %eax,%ecx
f0105182:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0105185:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105188:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010518c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010518f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105192:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105194:	eb 0f                	jmp    f01051a5 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0105196:	83 ec 08             	sub    $0x8,%esp
f0105199:	53                   	push   %ebx
f010519a:	ff 75 e0             	pushl  -0x20(%ebp)
f010519d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010519f:	83 ef 01             	sub    $0x1,%edi
f01051a2:	83 c4 10             	add    $0x10,%esp
f01051a5:	85 ff                	test   %edi,%edi
f01051a7:	7f ed                	jg     f0105196 <vprintfmt+0x1c0>
f01051a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01051ac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01051af:	85 c9                	test   %ecx,%ecx
f01051b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01051b6:	0f 49 c1             	cmovns %ecx,%eax
f01051b9:	29 c1                	sub    %eax,%ecx
f01051bb:	89 75 08             	mov    %esi,0x8(%ebp)
f01051be:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01051c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01051c4:	89 cb                	mov    %ecx,%ebx
f01051c6:	eb 4d                	jmp    f0105215 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01051c8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01051cc:	74 1b                	je     f01051e9 <vprintfmt+0x213>
f01051ce:	0f be c0             	movsbl %al,%eax
f01051d1:	83 e8 20             	sub    $0x20,%eax
f01051d4:	83 f8 5e             	cmp    $0x5e,%eax
f01051d7:	76 10                	jbe    f01051e9 <vprintfmt+0x213>
					putch('?', putdat);
f01051d9:	83 ec 08             	sub    $0x8,%esp
f01051dc:	ff 75 0c             	pushl  0xc(%ebp)
f01051df:	6a 3f                	push   $0x3f
f01051e1:	ff 55 08             	call   *0x8(%ebp)
f01051e4:	83 c4 10             	add    $0x10,%esp
f01051e7:	eb 0d                	jmp    f01051f6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01051e9:	83 ec 08             	sub    $0x8,%esp
f01051ec:	ff 75 0c             	pushl  0xc(%ebp)
f01051ef:	52                   	push   %edx
f01051f0:	ff 55 08             	call   *0x8(%ebp)
f01051f3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01051f6:	83 eb 01             	sub    $0x1,%ebx
f01051f9:	eb 1a                	jmp    f0105215 <vprintfmt+0x23f>
f01051fb:	89 75 08             	mov    %esi,0x8(%ebp)
f01051fe:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0105201:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105204:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105207:	eb 0c                	jmp    f0105215 <vprintfmt+0x23f>
f0105209:	89 75 08             	mov    %esi,0x8(%ebp)
f010520c:	8b 75 c8             	mov    -0x38(%ebp),%esi
f010520f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105212:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105215:	83 c7 01             	add    $0x1,%edi
f0105218:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010521c:	0f be d0             	movsbl %al,%edx
f010521f:	85 d2                	test   %edx,%edx
f0105221:	74 23                	je     f0105246 <vprintfmt+0x270>
f0105223:	85 f6                	test   %esi,%esi
f0105225:	78 a1                	js     f01051c8 <vprintfmt+0x1f2>
f0105227:	83 ee 01             	sub    $0x1,%esi
f010522a:	79 9c                	jns    f01051c8 <vprintfmt+0x1f2>
f010522c:	89 df                	mov    %ebx,%edi
f010522e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105234:	eb 18                	jmp    f010524e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105236:	83 ec 08             	sub    $0x8,%esp
f0105239:	53                   	push   %ebx
f010523a:	6a 20                	push   $0x20
f010523c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010523e:	83 ef 01             	sub    $0x1,%edi
f0105241:	83 c4 10             	add    $0x10,%esp
f0105244:	eb 08                	jmp    f010524e <vprintfmt+0x278>
f0105246:	89 df                	mov    %ebx,%edi
f0105248:	8b 75 08             	mov    0x8(%ebp),%esi
f010524b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010524e:	85 ff                	test   %edi,%edi
f0105250:	7f e4                	jg     f0105236 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105252:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105255:	e9 a2 fd ff ff       	jmp    f0104ffc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010525a:	83 fa 01             	cmp    $0x1,%edx
f010525d:	7e 16                	jle    f0105275 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010525f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105262:	8d 50 08             	lea    0x8(%eax),%edx
f0105265:	89 55 14             	mov    %edx,0x14(%ebp)
f0105268:	8b 50 04             	mov    0x4(%eax),%edx
f010526b:	8b 00                	mov    (%eax),%eax
f010526d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105270:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0105273:	eb 32                	jmp    f01052a7 <vprintfmt+0x2d1>
	else if (lflag)
f0105275:	85 d2                	test   %edx,%edx
f0105277:	74 18                	je     f0105291 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105279:	8b 45 14             	mov    0x14(%ebp),%eax
f010527c:	8d 50 04             	lea    0x4(%eax),%edx
f010527f:	89 55 14             	mov    %edx,0x14(%ebp)
f0105282:	8b 00                	mov    (%eax),%eax
f0105284:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105287:	89 c1                	mov    %eax,%ecx
f0105289:	c1 f9 1f             	sar    $0x1f,%ecx
f010528c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010528f:	eb 16                	jmp    f01052a7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105291:	8b 45 14             	mov    0x14(%ebp),%eax
f0105294:	8d 50 04             	lea    0x4(%eax),%edx
f0105297:	89 55 14             	mov    %edx,0x14(%ebp)
f010529a:	8b 00                	mov    (%eax),%eax
f010529c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010529f:	89 c1                	mov    %eax,%ecx
f01052a1:	c1 f9 1f             	sar    $0x1f,%ecx
f01052a4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01052a7:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01052aa:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01052ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01052b3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01052b8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01052bc:	0f 89 b0 00 00 00    	jns    f0105372 <vprintfmt+0x39c>
				putch('-', putdat);
f01052c2:	83 ec 08             	sub    $0x8,%esp
f01052c5:	53                   	push   %ebx
f01052c6:	6a 2d                	push   $0x2d
f01052c8:	ff d6                	call   *%esi
				num = -(long long) num;
f01052ca:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01052cd:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01052d0:	f7 d8                	neg    %eax
f01052d2:	83 d2 00             	adc    $0x0,%edx
f01052d5:	f7 da                	neg    %edx
f01052d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052da:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01052dd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01052e0:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052e5:	e9 88 00 00 00       	jmp    f0105372 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01052ea:	8d 45 14             	lea    0x14(%ebp),%eax
f01052ed:	e8 70 fc ff ff       	call   f0104f62 <getuint>
f01052f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f01052f8:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01052fd:	eb 73                	jmp    f0105372 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
f01052ff:	8d 45 14             	lea    0x14(%ebp),%eax
f0105302:	e8 5b fc ff ff       	call   f0104f62 <getuint>
f0105307:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010530a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
f010530d:	83 ec 08             	sub    $0x8,%esp
f0105310:	53                   	push   %ebx
f0105311:	6a 58                	push   $0x58
f0105313:	ff d6                	call   *%esi
			putch('X', putdat);
f0105315:	83 c4 08             	add    $0x8,%esp
f0105318:	53                   	push   %ebx
f0105319:	6a 58                	push   $0x58
f010531b:	ff d6                	call   *%esi
			putch('X', putdat);
f010531d:	83 c4 08             	add    $0x8,%esp
f0105320:	53                   	push   %ebx
f0105321:	6a 58                	push   $0x58
f0105323:	ff d6                	call   *%esi
			goto number;
f0105325:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
f0105328:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
f010532d:	eb 43                	jmp    f0105372 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f010532f:	83 ec 08             	sub    $0x8,%esp
f0105332:	53                   	push   %ebx
f0105333:	6a 30                	push   $0x30
f0105335:	ff d6                	call   *%esi
			putch('x', putdat);
f0105337:	83 c4 08             	add    $0x8,%esp
f010533a:	53                   	push   %ebx
f010533b:	6a 78                	push   $0x78
f010533d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010533f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105342:	8d 50 04             	lea    0x4(%eax),%edx
f0105345:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105348:	8b 00                	mov    (%eax),%eax
f010534a:	ba 00 00 00 00       	mov    $0x0,%edx
f010534f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105352:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105355:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105358:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010535d:	eb 13                	jmp    f0105372 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010535f:	8d 45 14             	lea    0x14(%ebp),%eax
f0105362:	e8 fb fb ff ff       	call   f0104f62 <getuint>
f0105367:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010536a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f010536d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105372:	83 ec 0c             	sub    $0xc,%esp
f0105375:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0105379:	52                   	push   %edx
f010537a:	ff 75 e0             	pushl  -0x20(%ebp)
f010537d:	50                   	push   %eax
f010537e:	ff 75 dc             	pushl  -0x24(%ebp)
f0105381:	ff 75 d8             	pushl  -0x28(%ebp)
f0105384:	89 da                	mov    %ebx,%edx
f0105386:	89 f0                	mov    %esi,%eax
f0105388:	e8 26 fb ff ff       	call   f0104eb3 <printnum>
			break;
f010538d:	83 c4 20             	add    $0x20,%esp
f0105390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105393:	e9 64 fc ff ff       	jmp    f0104ffc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105398:	83 ec 08             	sub    $0x8,%esp
f010539b:	53                   	push   %ebx
f010539c:	51                   	push   %ecx
f010539d:	ff d6                	call   *%esi
			break;
f010539f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01053a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01053a5:	e9 52 fc ff ff       	jmp    f0104ffc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01053aa:	83 ec 08             	sub    $0x8,%esp
f01053ad:	53                   	push   %ebx
f01053ae:	6a 25                	push   $0x25
f01053b0:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01053b2:	83 c4 10             	add    $0x10,%esp
f01053b5:	eb 03                	jmp    f01053ba <vprintfmt+0x3e4>
f01053b7:	83 ef 01             	sub    $0x1,%edi
f01053ba:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01053be:	75 f7                	jne    f01053b7 <vprintfmt+0x3e1>
f01053c0:	e9 37 fc ff ff       	jmp    f0104ffc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01053c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053c8:	5b                   	pop    %ebx
f01053c9:	5e                   	pop    %esi
f01053ca:	5f                   	pop    %edi
f01053cb:	5d                   	pop    %ebp
f01053cc:	c3                   	ret    

f01053cd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01053cd:	55                   	push   %ebp
f01053ce:	89 e5                	mov    %esp,%ebp
f01053d0:	83 ec 18             	sub    $0x18,%esp
f01053d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01053d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01053d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01053dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01053e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01053e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01053ea:	85 c0                	test   %eax,%eax
f01053ec:	74 26                	je     f0105414 <vsnprintf+0x47>
f01053ee:	85 d2                	test   %edx,%edx
f01053f0:	7e 22                	jle    f0105414 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01053f2:	ff 75 14             	pushl  0x14(%ebp)
f01053f5:	ff 75 10             	pushl  0x10(%ebp)
f01053f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01053fb:	50                   	push   %eax
f01053fc:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0105401:	e8 d0 fb ff ff       	call   f0104fd6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105406:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105409:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010540c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010540f:	83 c4 10             	add    $0x10,%esp
f0105412:	eb 05                	jmp    f0105419 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105419:	c9                   	leave  
f010541a:	c3                   	ret    

f010541b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010541b:	55                   	push   %ebp
f010541c:	89 e5                	mov    %esp,%ebp
f010541e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105421:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105424:	50                   	push   %eax
f0105425:	ff 75 10             	pushl  0x10(%ebp)
f0105428:	ff 75 0c             	pushl  0xc(%ebp)
f010542b:	ff 75 08             	pushl  0x8(%ebp)
f010542e:	e8 9a ff ff ff       	call   f01053cd <vsnprintf>
	va_end(ap);

	return rc;
}
f0105433:	c9                   	leave  
f0105434:	c3                   	ret    

f0105435 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105435:	55                   	push   %ebp
f0105436:	89 e5                	mov    %esp,%ebp
f0105438:	57                   	push   %edi
f0105439:	56                   	push   %esi
f010543a:	53                   	push   %ebx
f010543b:	83 ec 0c             	sub    $0xc,%esp
f010543e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105441:	85 c0                	test   %eax,%eax
f0105443:	74 11                	je     f0105456 <readline+0x21>
		cprintf("%s", prompt);
f0105445:	83 ec 08             	sub    $0x8,%esp
f0105448:	50                   	push   %eax
f0105449:	68 f9 73 10 f0       	push   $0xf01073f9
f010544e:	e8 1c e4 ff ff       	call   f010386f <cprintf>
f0105453:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105456:	83 ec 0c             	sub    $0xc,%esp
f0105459:	6a 00                	push   $0x0
f010545b:	e8 f2 b3 ff ff       	call   f0100852 <iscons>
f0105460:	89 c7                	mov    %eax,%edi
f0105462:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105465:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010546a:	e8 d2 b3 ff ff       	call   f0100841 <getchar>
f010546f:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105471:	85 c0                	test   %eax,%eax
f0105473:	79 29                	jns    f010549e <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105475:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f010547a:	83 fb f8             	cmp    $0xfffffff8,%ebx
f010547d:	0f 84 9b 00 00 00    	je     f010551e <readline+0xe9>
				cprintf("read error: %e\n", c);
f0105483:	83 ec 08             	sub    $0x8,%esp
f0105486:	53                   	push   %ebx
f0105487:	68 ff 80 10 f0       	push   $0xf01080ff
f010548c:	e8 de e3 ff ff       	call   f010386f <cprintf>
f0105491:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105494:	b8 00 00 00 00       	mov    $0x0,%eax
f0105499:	e9 80 00 00 00       	jmp    f010551e <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010549e:	83 f8 08             	cmp    $0x8,%eax
f01054a1:	0f 94 c2             	sete   %dl
f01054a4:	83 f8 7f             	cmp    $0x7f,%eax
f01054a7:	0f 94 c0             	sete   %al
f01054aa:	08 c2                	or     %al,%dl
f01054ac:	74 1a                	je     f01054c8 <readline+0x93>
f01054ae:	85 f6                	test   %esi,%esi
f01054b0:	7e 16                	jle    f01054c8 <readline+0x93>
			if (echoing)
f01054b2:	85 ff                	test   %edi,%edi
f01054b4:	74 0d                	je     f01054c3 <readline+0x8e>
				cputchar('\b');
f01054b6:	83 ec 0c             	sub    $0xc,%esp
f01054b9:	6a 08                	push   $0x8
f01054bb:	e8 71 b3 ff ff       	call   f0100831 <cputchar>
f01054c0:	83 c4 10             	add    $0x10,%esp
			i--;
f01054c3:	83 ee 01             	sub    $0x1,%esi
f01054c6:	eb a2                	jmp    f010546a <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01054c8:	83 fb 1f             	cmp    $0x1f,%ebx
f01054cb:	7e 26                	jle    f01054f3 <readline+0xbe>
f01054cd:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01054d3:	7f 1e                	jg     f01054f3 <readline+0xbe>
			if (echoing)
f01054d5:	85 ff                	test   %edi,%edi
f01054d7:	74 0c                	je     f01054e5 <readline+0xb0>
				cputchar(c);
f01054d9:	83 ec 0c             	sub    $0xc,%esp
f01054dc:	53                   	push   %ebx
f01054dd:	e8 4f b3 ff ff       	call   f0100831 <cputchar>
f01054e2:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01054e5:	88 9e 80 2a 21 f0    	mov    %bl,-0xfded580(%esi)
f01054eb:	8d 76 01             	lea    0x1(%esi),%esi
f01054ee:	e9 77 ff ff ff       	jmp    f010546a <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01054f3:	83 fb 0a             	cmp    $0xa,%ebx
f01054f6:	74 09                	je     f0105501 <readline+0xcc>
f01054f8:	83 fb 0d             	cmp    $0xd,%ebx
f01054fb:	0f 85 69 ff ff ff    	jne    f010546a <readline+0x35>
			if (echoing)
f0105501:	85 ff                	test   %edi,%edi
f0105503:	74 0d                	je     f0105512 <readline+0xdd>
				cputchar('\n');
f0105505:	83 ec 0c             	sub    $0xc,%esp
f0105508:	6a 0a                	push   $0xa
f010550a:	e8 22 b3 ff ff       	call   f0100831 <cputchar>
f010550f:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105512:	c6 86 80 2a 21 f0 00 	movb   $0x0,-0xfded580(%esi)
			return buf;
f0105519:	b8 80 2a 21 f0       	mov    $0xf0212a80,%eax
		}
	}
}
f010551e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105521:	5b                   	pop    %ebx
f0105522:	5e                   	pop    %esi
f0105523:	5f                   	pop    %edi
f0105524:	5d                   	pop    %ebp
f0105525:	c3                   	ret    

f0105526 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105526:	55                   	push   %ebp
f0105527:	89 e5                	mov    %esp,%ebp
f0105529:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010552c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105531:	eb 03                	jmp    f0105536 <strlen+0x10>
		n++;
f0105533:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105536:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010553a:	75 f7                	jne    f0105533 <strlen+0xd>
		n++;
	return n;
}
f010553c:	5d                   	pop    %ebp
f010553d:	c3                   	ret    

f010553e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010553e:	55                   	push   %ebp
f010553f:	89 e5                	mov    %esp,%ebp
f0105541:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105544:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105547:	ba 00 00 00 00       	mov    $0x0,%edx
f010554c:	eb 03                	jmp    f0105551 <strnlen+0x13>
		n++;
f010554e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105551:	39 c2                	cmp    %eax,%edx
f0105553:	74 08                	je     f010555d <strnlen+0x1f>
f0105555:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105559:	75 f3                	jne    f010554e <strnlen+0x10>
f010555b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010555d:	5d                   	pop    %ebp
f010555e:	c3                   	ret    

f010555f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010555f:	55                   	push   %ebp
f0105560:	89 e5                	mov    %esp,%ebp
f0105562:	53                   	push   %ebx
f0105563:	8b 45 08             	mov    0x8(%ebp),%eax
f0105566:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105569:	89 c2                	mov    %eax,%edx
f010556b:	83 c2 01             	add    $0x1,%edx
f010556e:	83 c1 01             	add    $0x1,%ecx
f0105571:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105575:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105578:	84 db                	test   %bl,%bl
f010557a:	75 ef                	jne    f010556b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010557c:	5b                   	pop    %ebx
f010557d:	5d                   	pop    %ebp
f010557e:	c3                   	ret    

f010557f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010557f:	55                   	push   %ebp
f0105580:	89 e5                	mov    %esp,%ebp
f0105582:	53                   	push   %ebx
f0105583:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105586:	53                   	push   %ebx
f0105587:	e8 9a ff ff ff       	call   f0105526 <strlen>
f010558c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010558f:	ff 75 0c             	pushl  0xc(%ebp)
f0105592:	01 d8                	add    %ebx,%eax
f0105594:	50                   	push   %eax
f0105595:	e8 c5 ff ff ff       	call   f010555f <strcpy>
	return dst;
}
f010559a:	89 d8                	mov    %ebx,%eax
f010559c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010559f:	c9                   	leave  
f01055a0:	c3                   	ret    

f01055a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01055a1:	55                   	push   %ebp
f01055a2:	89 e5                	mov    %esp,%ebp
f01055a4:	56                   	push   %esi
f01055a5:	53                   	push   %ebx
f01055a6:	8b 75 08             	mov    0x8(%ebp),%esi
f01055a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01055ac:	89 f3                	mov    %esi,%ebx
f01055ae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055b1:	89 f2                	mov    %esi,%edx
f01055b3:	eb 0f                	jmp    f01055c4 <strncpy+0x23>
		*dst++ = *src;
f01055b5:	83 c2 01             	add    $0x1,%edx
f01055b8:	0f b6 01             	movzbl (%ecx),%eax
f01055bb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01055be:	80 39 01             	cmpb   $0x1,(%ecx)
f01055c1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01055c4:	39 da                	cmp    %ebx,%edx
f01055c6:	75 ed                	jne    f01055b5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01055c8:	89 f0                	mov    %esi,%eax
f01055ca:	5b                   	pop    %ebx
f01055cb:	5e                   	pop    %esi
f01055cc:	5d                   	pop    %ebp
f01055cd:	c3                   	ret    

f01055ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01055ce:	55                   	push   %ebp
f01055cf:	89 e5                	mov    %esp,%ebp
f01055d1:	56                   	push   %esi
f01055d2:	53                   	push   %ebx
f01055d3:	8b 75 08             	mov    0x8(%ebp),%esi
f01055d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01055d9:	8b 55 10             	mov    0x10(%ebp),%edx
f01055dc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01055de:	85 d2                	test   %edx,%edx
f01055e0:	74 21                	je     f0105603 <strlcpy+0x35>
f01055e2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01055e6:	89 f2                	mov    %esi,%edx
f01055e8:	eb 09                	jmp    f01055f3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01055ea:	83 c2 01             	add    $0x1,%edx
f01055ed:	83 c1 01             	add    $0x1,%ecx
f01055f0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01055f3:	39 c2                	cmp    %eax,%edx
f01055f5:	74 09                	je     f0105600 <strlcpy+0x32>
f01055f7:	0f b6 19             	movzbl (%ecx),%ebx
f01055fa:	84 db                	test   %bl,%bl
f01055fc:	75 ec                	jne    f01055ea <strlcpy+0x1c>
f01055fe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105600:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105603:	29 f0                	sub    %esi,%eax
}
f0105605:	5b                   	pop    %ebx
f0105606:	5e                   	pop    %esi
f0105607:	5d                   	pop    %ebp
f0105608:	c3                   	ret    

f0105609 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105609:	55                   	push   %ebp
f010560a:	89 e5                	mov    %esp,%ebp
f010560c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010560f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105612:	eb 06                	jmp    f010561a <strcmp+0x11>
		p++, q++;
f0105614:	83 c1 01             	add    $0x1,%ecx
f0105617:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010561a:	0f b6 01             	movzbl (%ecx),%eax
f010561d:	84 c0                	test   %al,%al
f010561f:	74 04                	je     f0105625 <strcmp+0x1c>
f0105621:	3a 02                	cmp    (%edx),%al
f0105623:	74 ef                	je     f0105614 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105625:	0f b6 c0             	movzbl %al,%eax
f0105628:	0f b6 12             	movzbl (%edx),%edx
f010562b:	29 d0                	sub    %edx,%eax
}
f010562d:	5d                   	pop    %ebp
f010562e:	c3                   	ret    

f010562f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010562f:	55                   	push   %ebp
f0105630:	89 e5                	mov    %esp,%ebp
f0105632:	53                   	push   %ebx
f0105633:	8b 45 08             	mov    0x8(%ebp),%eax
f0105636:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105639:	89 c3                	mov    %eax,%ebx
f010563b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010563e:	eb 06                	jmp    f0105646 <strncmp+0x17>
		n--, p++, q++;
f0105640:	83 c0 01             	add    $0x1,%eax
f0105643:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105646:	39 d8                	cmp    %ebx,%eax
f0105648:	74 15                	je     f010565f <strncmp+0x30>
f010564a:	0f b6 08             	movzbl (%eax),%ecx
f010564d:	84 c9                	test   %cl,%cl
f010564f:	74 04                	je     f0105655 <strncmp+0x26>
f0105651:	3a 0a                	cmp    (%edx),%cl
f0105653:	74 eb                	je     f0105640 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105655:	0f b6 00             	movzbl (%eax),%eax
f0105658:	0f b6 12             	movzbl (%edx),%edx
f010565b:	29 d0                	sub    %edx,%eax
f010565d:	eb 05                	jmp    f0105664 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010565f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105664:	5b                   	pop    %ebx
f0105665:	5d                   	pop    %ebp
f0105666:	c3                   	ret    

f0105667 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105667:	55                   	push   %ebp
f0105668:	89 e5                	mov    %esp,%ebp
f010566a:	8b 45 08             	mov    0x8(%ebp),%eax
f010566d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105671:	eb 07                	jmp    f010567a <strchr+0x13>
		if (*s == c)
f0105673:	38 ca                	cmp    %cl,%dl
f0105675:	74 0f                	je     f0105686 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105677:	83 c0 01             	add    $0x1,%eax
f010567a:	0f b6 10             	movzbl (%eax),%edx
f010567d:	84 d2                	test   %dl,%dl
f010567f:	75 f2                	jne    f0105673 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105681:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105686:	5d                   	pop    %ebp
f0105687:	c3                   	ret    

f0105688 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105688:	55                   	push   %ebp
f0105689:	89 e5                	mov    %esp,%ebp
f010568b:	8b 45 08             	mov    0x8(%ebp),%eax
f010568e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105692:	eb 03                	jmp    f0105697 <strfind+0xf>
f0105694:	83 c0 01             	add    $0x1,%eax
f0105697:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010569a:	38 ca                	cmp    %cl,%dl
f010569c:	74 04                	je     f01056a2 <strfind+0x1a>
f010569e:	84 d2                	test   %dl,%dl
f01056a0:	75 f2                	jne    f0105694 <strfind+0xc>
			break;
	return (char *) s;
}
f01056a2:	5d                   	pop    %ebp
f01056a3:	c3                   	ret    

f01056a4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01056a4:	55                   	push   %ebp
f01056a5:	89 e5                	mov    %esp,%ebp
f01056a7:	57                   	push   %edi
f01056a8:	56                   	push   %esi
f01056a9:	53                   	push   %ebx
f01056aa:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01056b0:	85 c9                	test   %ecx,%ecx
f01056b2:	74 36                	je     f01056ea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01056b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01056ba:	75 28                	jne    f01056e4 <memset+0x40>
f01056bc:	f6 c1 03             	test   $0x3,%cl
f01056bf:	75 23                	jne    f01056e4 <memset+0x40>
		c &= 0xFF;
f01056c1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01056c5:	89 d3                	mov    %edx,%ebx
f01056c7:	c1 e3 08             	shl    $0x8,%ebx
f01056ca:	89 d6                	mov    %edx,%esi
f01056cc:	c1 e6 18             	shl    $0x18,%esi
f01056cf:	89 d0                	mov    %edx,%eax
f01056d1:	c1 e0 10             	shl    $0x10,%eax
f01056d4:	09 f0                	or     %esi,%eax
f01056d6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01056d8:	89 d8                	mov    %ebx,%eax
f01056da:	09 d0                	or     %edx,%eax
f01056dc:	c1 e9 02             	shr    $0x2,%ecx
f01056df:	fc                   	cld    
f01056e0:	f3 ab                	rep stos %eax,%es:(%edi)
f01056e2:	eb 06                	jmp    f01056ea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01056e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056e7:	fc                   	cld    
f01056e8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01056ea:	89 f8                	mov    %edi,%eax
f01056ec:	5b                   	pop    %ebx
f01056ed:	5e                   	pop    %esi
f01056ee:	5f                   	pop    %edi
f01056ef:	5d                   	pop    %ebp
f01056f0:	c3                   	ret    

f01056f1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01056f1:	55                   	push   %ebp
f01056f2:	89 e5                	mov    %esp,%ebp
f01056f4:	57                   	push   %edi
f01056f5:	56                   	push   %esi
f01056f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01056f9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01056fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01056ff:	39 c6                	cmp    %eax,%esi
f0105701:	73 35                	jae    f0105738 <memmove+0x47>
f0105703:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105706:	39 d0                	cmp    %edx,%eax
f0105708:	73 2e                	jae    f0105738 <memmove+0x47>
		s += n;
		d += n;
f010570a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010570d:	89 d6                	mov    %edx,%esi
f010570f:	09 fe                	or     %edi,%esi
f0105711:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105717:	75 13                	jne    f010572c <memmove+0x3b>
f0105719:	f6 c1 03             	test   $0x3,%cl
f010571c:	75 0e                	jne    f010572c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010571e:	83 ef 04             	sub    $0x4,%edi
f0105721:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105724:	c1 e9 02             	shr    $0x2,%ecx
f0105727:	fd                   	std    
f0105728:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010572a:	eb 09                	jmp    f0105735 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010572c:	83 ef 01             	sub    $0x1,%edi
f010572f:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105732:	fd                   	std    
f0105733:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105735:	fc                   	cld    
f0105736:	eb 1d                	jmp    f0105755 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105738:	89 f2                	mov    %esi,%edx
f010573a:	09 c2                	or     %eax,%edx
f010573c:	f6 c2 03             	test   $0x3,%dl
f010573f:	75 0f                	jne    f0105750 <memmove+0x5f>
f0105741:	f6 c1 03             	test   $0x3,%cl
f0105744:	75 0a                	jne    f0105750 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105746:	c1 e9 02             	shr    $0x2,%ecx
f0105749:	89 c7                	mov    %eax,%edi
f010574b:	fc                   	cld    
f010574c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010574e:	eb 05                	jmp    f0105755 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105750:	89 c7                	mov    %eax,%edi
f0105752:	fc                   	cld    
f0105753:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105755:	5e                   	pop    %esi
f0105756:	5f                   	pop    %edi
f0105757:	5d                   	pop    %ebp
f0105758:	c3                   	ret    

f0105759 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105759:	55                   	push   %ebp
f010575a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010575c:	ff 75 10             	pushl  0x10(%ebp)
f010575f:	ff 75 0c             	pushl  0xc(%ebp)
f0105762:	ff 75 08             	pushl  0x8(%ebp)
f0105765:	e8 87 ff ff ff       	call   f01056f1 <memmove>
}
f010576a:	c9                   	leave  
f010576b:	c3                   	ret    

f010576c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010576c:	55                   	push   %ebp
f010576d:	89 e5                	mov    %esp,%ebp
f010576f:	56                   	push   %esi
f0105770:	53                   	push   %ebx
f0105771:	8b 45 08             	mov    0x8(%ebp),%eax
f0105774:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105777:	89 c6                	mov    %eax,%esi
f0105779:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010577c:	eb 1a                	jmp    f0105798 <memcmp+0x2c>
		if (*s1 != *s2)
f010577e:	0f b6 08             	movzbl (%eax),%ecx
f0105781:	0f b6 1a             	movzbl (%edx),%ebx
f0105784:	38 d9                	cmp    %bl,%cl
f0105786:	74 0a                	je     f0105792 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105788:	0f b6 c1             	movzbl %cl,%eax
f010578b:	0f b6 db             	movzbl %bl,%ebx
f010578e:	29 d8                	sub    %ebx,%eax
f0105790:	eb 0f                	jmp    f01057a1 <memcmp+0x35>
		s1++, s2++;
f0105792:	83 c0 01             	add    $0x1,%eax
f0105795:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105798:	39 f0                	cmp    %esi,%eax
f010579a:	75 e2                	jne    f010577e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010579c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057a1:	5b                   	pop    %ebx
f01057a2:	5e                   	pop    %esi
f01057a3:	5d                   	pop    %ebp
f01057a4:	c3                   	ret    

f01057a5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01057a5:	55                   	push   %ebp
f01057a6:	89 e5                	mov    %esp,%ebp
f01057a8:	53                   	push   %ebx
f01057a9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01057ac:	89 c1                	mov    %eax,%ecx
f01057ae:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01057b1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01057b5:	eb 0a                	jmp    f01057c1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01057b7:	0f b6 10             	movzbl (%eax),%edx
f01057ba:	39 da                	cmp    %ebx,%edx
f01057bc:	74 07                	je     f01057c5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01057be:	83 c0 01             	add    $0x1,%eax
f01057c1:	39 c8                	cmp    %ecx,%eax
f01057c3:	72 f2                	jb     f01057b7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01057c5:	5b                   	pop    %ebx
f01057c6:	5d                   	pop    %ebp
f01057c7:	c3                   	ret    

f01057c8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01057c8:	55                   	push   %ebp
f01057c9:	89 e5                	mov    %esp,%ebp
f01057cb:	57                   	push   %edi
f01057cc:	56                   	push   %esi
f01057cd:	53                   	push   %ebx
f01057ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01057d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01057d4:	eb 03                	jmp    f01057d9 <strtol+0x11>
		s++;
f01057d6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01057d9:	0f b6 01             	movzbl (%ecx),%eax
f01057dc:	3c 20                	cmp    $0x20,%al
f01057de:	74 f6                	je     f01057d6 <strtol+0xe>
f01057e0:	3c 09                	cmp    $0x9,%al
f01057e2:	74 f2                	je     f01057d6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01057e4:	3c 2b                	cmp    $0x2b,%al
f01057e6:	75 0a                	jne    f01057f2 <strtol+0x2a>
		s++;
f01057e8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01057eb:	bf 00 00 00 00       	mov    $0x0,%edi
f01057f0:	eb 11                	jmp    f0105803 <strtol+0x3b>
f01057f2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01057f7:	3c 2d                	cmp    $0x2d,%al
f01057f9:	75 08                	jne    f0105803 <strtol+0x3b>
		s++, neg = 1;
f01057fb:	83 c1 01             	add    $0x1,%ecx
f01057fe:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105803:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105809:	75 15                	jne    f0105820 <strtol+0x58>
f010580b:	80 39 30             	cmpb   $0x30,(%ecx)
f010580e:	75 10                	jne    f0105820 <strtol+0x58>
f0105810:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105814:	75 7c                	jne    f0105892 <strtol+0xca>
		s += 2, base = 16;
f0105816:	83 c1 02             	add    $0x2,%ecx
f0105819:	bb 10 00 00 00       	mov    $0x10,%ebx
f010581e:	eb 16                	jmp    f0105836 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105820:	85 db                	test   %ebx,%ebx
f0105822:	75 12                	jne    f0105836 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105824:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105829:	80 39 30             	cmpb   $0x30,(%ecx)
f010582c:	75 08                	jne    f0105836 <strtol+0x6e>
		s++, base = 8;
f010582e:	83 c1 01             	add    $0x1,%ecx
f0105831:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105836:	b8 00 00 00 00       	mov    $0x0,%eax
f010583b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010583e:	0f b6 11             	movzbl (%ecx),%edx
f0105841:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105844:	89 f3                	mov    %esi,%ebx
f0105846:	80 fb 09             	cmp    $0x9,%bl
f0105849:	77 08                	ja     f0105853 <strtol+0x8b>
			dig = *s - '0';
f010584b:	0f be d2             	movsbl %dl,%edx
f010584e:	83 ea 30             	sub    $0x30,%edx
f0105851:	eb 22                	jmp    f0105875 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105853:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105856:	89 f3                	mov    %esi,%ebx
f0105858:	80 fb 19             	cmp    $0x19,%bl
f010585b:	77 08                	ja     f0105865 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010585d:	0f be d2             	movsbl %dl,%edx
f0105860:	83 ea 57             	sub    $0x57,%edx
f0105863:	eb 10                	jmp    f0105875 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105865:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105868:	89 f3                	mov    %esi,%ebx
f010586a:	80 fb 19             	cmp    $0x19,%bl
f010586d:	77 16                	ja     f0105885 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010586f:	0f be d2             	movsbl %dl,%edx
f0105872:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105875:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105878:	7d 0b                	jge    f0105885 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010587a:	83 c1 01             	add    $0x1,%ecx
f010587d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105881:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105883:	eb b9                	jmp    f010583e <strtol+0x76>

	if (endptr)
f0105885:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105889:	74 0d                	je     f0105898 <strtol+0xd0>
		*endptr = (char *) s;
f010588b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010588e:	89 0e                	mov    %ecx,(%esi)
f0105890:	eb 06                	jmp    f0105898 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105892:	85 db                	test   %ebx,%ebx
f0105894:	74 98                	je     f010582e <strtol+0x66>
f0105896:	eb 9e                	jmp    f0105836 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105898:	89 c2                	mov    %eax,%edx
f010589a:	f7 da                	neg    %edx
f010589c:	85 ff                	test   %edi,%edi
f010589e:	0f 45 c2             	cmovne %edx,%eax
}
f01058a1:	5b                   	pop    %ebx
f01058a2:	5e                   	pop    %esi
f01058a3:	5f                   	pop    %edi
f01058a4:	5d                   	pop    %ebp
f01058a5:	c3                   	ret    
f01058a6:	66 90                	xchg   %ax,%ax

f01058a8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01058a8:	fa                   	cli    

	xorw    %ax, %ax
f01058a9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01058ab:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01058ad:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01058af:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01058b1:	0f 01 16             	lgdtl  (%esi)
f01058b4:	74 70                	je     f0105926 <mpsearch1+0x3>
	movl    %cr0, %eax
f01058b6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01058b9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01058bd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01058c0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01058c6:	08 00                	or     %al,(%eax)

f01058c8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01058c8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01058cc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01058ce:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01058d0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01058d2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01058d6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01058d8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01058da:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01058df:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01058e2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01058e5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01058ea:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01058ed:	8b 25 84 2e 21 f0    	mov    0xf0212e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01058f3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01058f8:	b8 57 02 10 f0       	mov    $0xf0100257,%eax
	call    *%eax
f01058fd:	ff d0                	call   *%eax

f01058ff <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01058ff:	eb fe                	jmp    f01058ff <spin>
f0105901:	8d 76 00             	lea    0x0(%esi),%esi

f0105904 <gdt>:
	...
f010590c:	ff                   	(bad)  
f010590d:	ff 00                	incl   (%eax)
f010590f:	00 00                	add    %al,(%eax)
f0105911:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105918:	00                   	.byte 0x0
f0105919:	92                   	xchg   %eax,%edx
f010591a:	cf                   	iret   
	...

f010591c <gdtdesc>:
f010591c:	17                   	pop    %ss
f010591d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105922 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105922:	90                   	nop

f0105923 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105923:	55                   	push   %ebp
f0105924:	89 e5                	mov    %esp,%ebp
f0105926:	57                   	push   %edi
f0105927:	56                   	push   %esi
f0105928:	53                   	push   %ebx
f0105929:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010592c:	8b 0d 88 2e 21 f0    	mov    0xf0212e88,%ecx
f0105932:	89 c3                	mov    %eax,%ebx
f0105934:	c1 eb 0c             	shr    $0xc,%ebx
f0105937:	39 cb                	cmp    %ecx,%ebx
f0105939:	72 12                	jb     f010594d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010593b:	50                   	push   %eax
f010593c:	68 48 64 10 f0       	push   $0xf0106448
f0105941:	6a 57                	push   $0x57
f0105943:	68 9d 82 10 f0       	push   $0xf010829d
f0105948:	e8 47 a7 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f010594d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105953:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105955:	89 c2                	mov    %eax,%edx
f0105957:	c1 ea 0c             	shr    $0xc,%edx
f010595a:	39 ca                	cmp    %ecx,%edx
f010595c:	72 12                	jb     f0105970 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010595e:	50                   	push   %eax
f010595f:	68 48 64 10 f0       	push   $0xf0106448
f0105964:	6a 57                	push   $0x57
f0105966:	68 9d 82 10 f0       	push   $0xf010829d
f010596b:	e8 24 a7 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105970:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105976:	eb 2f                	jmp    f01059a7 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105978:	83 ec 04             	sub    $0x4,%esp
f010597b:	6a 04                	push   $0x4
f010597d:	68 ad 82 10 f0       	push   $0xf01082ad
f0105982:	53                   	push   %ebx
f0105983:	e8 e4 fd ff ff       	call   f010576c <memcmp>
f0105988:	83 c4 10             	add    $0x10,%esp
f010598b:	85 c0                	test   %eax,%eax
f010598d:	75 15                	jne    f01059a4 <mpsearch1+0x81>
f010598f:	89 da                	mov    %ebx,%edx
f0105991:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105994:	0f b6 0a             	movzbl (%edx),%ecx
f0105997:	01 c8                	add    %ecx,%eax
f0105999:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010599c:	39 d7                	cmp    %edx,%edi
f010599e:	75 f4                	jne    f0105994 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01059a0:	84 c0                	test   %al,%al
f01059a2:	74 0e                	je     f01059b2 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01059a4:	83 c3 10             	add    $0x10,%ebx
f01059a7:	39 f3                	cmp    %esi,%ebx
f01059a9:	72 cd                	jb     f0105978 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01059ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01059b0:	eb 02                	jmp    f01059b4 <mpsearch1+0x91>
f01059b2:	89 d8                	mov    %ebx,%eax
}
f01059b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059b7:	5b                   	pop    %ebx
f01059b8:	5e                   	pop    %esi
f01059b9:	5f                   	pop    %edi
f01059ba:	5d                   	pop    %ebp
f01059bb:	c3                   	ret    

f01059bc <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01059bc:	55                   	push   %ebp
f01059bd:	89 e5                	mov    %esp,%ebp
f01059bf:	57                   	push   %edi
f01059c0:	56                   	push   %esi
f01059c1:	53                   	push   %ebx
f01059c2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01059c5:	c7 05 c0 33 21 f0 20 	movl   $0xf0213020,0xf02133c0
f01059cc:	30 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01059cf:	83 3d 88 2e 21 f0 00 	cmpl   $0x0,0xf0212e88
f01059d6:	75 16                	jne    f01059ee <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059d8:	68 00 04 00 00       	push   $0x400
f01059dd:	68 48 64 10 f0       	push   $0xf0106448
f01059e2:	6a 6f                	push   $0x6f
f01059e4:	68 9d 82 10 f0       	push   $0xf010829d
f01059e9:	e8 a6 a6 ff ff       	call   f0100094 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01059ee:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01059f5:	85 c0                	test   %eax,%eax
f01059f7:	74 16                	je     f0105a0f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01059f9:	c1 e0 04             	shl    $0x4,%eax
f01059fc:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a01:	e8 1d ff ff ff       	call   f0105923 <mpsearch1>
f0105a06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a09:	85 c0                	test   %eax,%eax
f0105a0b:	75 3c                	jne    f0105a49 <mp_init+0x8d>
f0105a0d:	eb 20                	jmp    f0105a2f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105a0f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105a16:	c1 e0 0a             	shl    $0xa,%eax
f0105a19:	2d 00 04 00 00       	sub    $0x400,%eax
f0105a1e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a23:	e8 fb fe ff ff       	call   f0105923 <mpsearch1>
f0105a28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a2b:	85 c0                	test   %eax,%eax
f0105a2d:	75 1a                	jne    f0105a49 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105a2f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a34:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105a39:	e8 e5 fe ff ff       	call   f0105923 <mpsearch1>
f0105a3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105a41:	85 c0                	test   %eax,%eax
f0105a43:	0f 84 5d 02 00 00    	je     f0105ca6 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105a49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105a4c:	8b 70 04             	mov    0x4(%eax),%esi
f0105a4f:	85 f6                	test   %esi,%esi
f0105a51:	74 06                	je     f0105a59 <mp_init+0x9d>
f0105a53:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105a57:	74 15                	je     f0105a6e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105a59:	83 ec 0c             	sub    $0xc,%esp
f0105a5c:	68 10 81 10 f0       	push   $0xf0108110
f0105a61:	e8 09 de ff ff       	call   f010386f <cprintf>
f0105a66:	83 c4 10             	add    $0x10,%esp
f0105a69:	e9 38 02 00 00       	jmp    f0105ca6 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a6e:	89 f0                	mov    %esi,%eax
f0105a70:	c1 e8 0c             	shr    $0xc,%eax
f0105a73:	3b 05 88 2e 21 f0    	cmp    0xf0212e88,%eax
f0105a79:	72 15                	jb     f0105a90 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a7b:	56                   	push   %esi
f0105a7c:	68 48 64 10 f0       	push   $0xf0106448
f0105a81:	68 90 00 00 00       	push   $0x90
f0105a86:	68 9d 82 10 f0       	push   $0xf010829d
f0105a8b:	e8 04 a6 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105a90:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105a96:	83 ec 04             	sub    $0x4,%esp
f0105a99:	6a 04                	push   $0x4
f0105a9b:	68 b2 82 10 f0       	push   $0xf01082b2
f0105aa0:	53                   	push   %ebx
f0105aa1:	e8 c6 fc ff ff       	call   f010576c <memcmp>
f0105aa6:	83 c4 10             	add    $0x10,%esp
f0105aa9:	85 c0                	test   %eax,%eax
f0105aab:	74 15                	je     f0105ac2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105aad:	83 ec 0c             	sub    $0xc,%esp
f0105ab0:	68 40 81 10 f0       	push   $0xf0108140
f0105ab5:	e8 b5 dd ff ff       	call   f010386f <cprintf>
f0105aba:	83 c4 10             	add    $0x10,%esp
f0105abd:	e9 e4 01 00 00       	jmp    f0105ca6 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105ac2:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105ac6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105aca:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105acd:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105ad2:	b8 00 00 00 00       	mov    $0x0,%eax
f0105ad7:	eb 0d                	jmp    f0105ae6 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105ad9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105ae0:	f0 
f0105ae1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105ae3:	83 c0 01             	add    $0x1,%eax
f0105ae6:	39 c7                	cmp    %eax,%edi
f0105ae8:	75 ef                	jne    f0105ad9 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105aea:	84 d2                	test   %dl,%dl
f0105aec:	74 15                	je     f0105b03 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105aee:	83 ec 0c             	sub    $0xc,%esp
f0105af1:	68 74 81 10 f0       	push   $0xf0108174
f0105af6:	e8 74 dd ff ff       	call   f010386f <cprintf>
f0105afb:	83 c4 10             	add    $0x10,%esp
f0105afe:	e9 a3 01 00 00       	jmp    f0105ca6 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105b03:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105b07:	3c 01                	cmp    $0x1,%al
f0105b09:	74 1d                	je     f0105b28 <mp_init+0x16c>
f0105b0b:	3c 04                	cmp    $0x4,%al
f0105b0d:	74 19                	je     f0105b28 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105b0f:	83 ec 08             	sub    $0x8,%esp
f0105b12:	0f b6 c0             	movzbl %al,%eax
f0105b15:	50                   	push   %eax
f0105b16:	68 98 81 10 f0       	push   $0xf0108198
f0105b1b:	e8 4f dd ff ff       	call   f010386f <cprintf>
f0105b20:	83 c4 10             	add    $0x10,%esp
f0105b23:	e9 7e 01 00 00       	jmp    f0105ca6 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b28:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105b2c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105b30:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105b35:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105b3a:	01 ce                	add    %ecx,%esi
f0105b3c:	eb 0d                	jmp    f0105b4b <mp_init+0x18f>
f0105b3e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105b45:	f0 
f0105b46:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105b48:	83 c0 01             	add    $0x1,%eax
f0105b4b:	39 c7                	cmp    %eax,%edi
f0105b4d:	75 ef                	jne    f0105b3e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105b4f:	89 d0                	mov    %edx,%eax
f0105b51:	02 43 2a             	add    0x2a(%ebx),%al
f0105b54:	74 15                	je     f0105b6b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105b56:	83 ec 0c             	sub    $0xc,%esp
f0105b59:	68 b8 81 10 f0       	push   $0xf01081b8
f0105b5e:	e8 0c dd ff ff       	call   f010386f <cprintf>
f0105b63:	83 c4 10             	add    $0x10,%esp
f0105b66:	e9 3b 01 00 00       	jmp    f0105ca6 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105b6b:	85 db                	test   %ebx,%ebx
f0105b6d:	0f 84 33 01 00 00    	je     f0105ca6 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105b73:	c7 05 00 30 21 f0 01 	movl   $0x1,0xf0213000
f0105b7a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105b7d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105b80:	a3 00 40 25 f0       	mov    %eax,0xf0254000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b85:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105b88:	be 00 00 00 00       	mov    $0x0,%esi
f0105b8d:	e9 85 00 00 00       	jmp    f0105c17 <mp_init+0x25b>
		switch (*p) {
f0105b92:	0f b6 07             	movzbl (%edi),%eax
f0105b95:	84 c0                	test   %al,%al
f0105b97:	74 06                	je     f0105b9f <mp_init+0x1e3>
f0105b99:	3c 04                	cmp    $0x4,%al
f0105b9b:	77 55                	ja     f0105bf2 <mp_init+0x236>
f0105b9d:	eb 4e                	jmp    f0105bed <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105b9f:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105ba3:	74 11                	je     f0105bb6 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105ba5:	6b 05 c4 33 21 f0 74 	imul   $0x74,0xf02133c4,%eax
f0105bac:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0105bb1:	a3 c0 33 21 f0       	mov    %eax,0xf02133c0
			if (ncpu < NCPU) {
f0105bb6:	a1 c4 33 21 f0       	mov    0xf02133c4,%eax
f0105bbb:	83 f8 07             	cmp    $0x7,%eax
f0105bbe:	7f 13                	jg     f0105bd3 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105bc0:	6b d0 74             	imul   $0x74,%eax,%edx
f0105bc3:	88 82 20 30 21 f0    	mov    %al,-0xfdecfe0(%edx)
				ncpu++;
f0105bc9:	83 c0 01             	add    $0x1,%eax
f0105bcc:	a3 c4 33 21 f0       	mov    %eax,0xf02133c4
f0105bd1:	eb 15                	jmp    f0105be8 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105bd3:	83 ec 08             	sub    $0x8,%esp
f0105bd6:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105bda:	50                   	push   %eax
f0105bdb:	68 e8 81 10 f0       	push   $0xf01081e8
f0105be0:	e8 8a dc ff ff       	call   f010386f <cprintf>
f0105be5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105be8:	83 c7 14             	add    $0x14,%edi
			continue;
f0105beb:	eb 27                	jmp    f0105c14 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105bed:	83 c7 08             	add    $0x8,%edi
			continue;
f0105bf0:	eb 22                	jmp    f0105c14 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105bf2:	83 ec 08             	sub    $0x8,%esp
f0105bf5:	0f b6 c0             	movzbl %al,%eax
f0105bf8:	50                   	push   %eax
f0105bf9:	68 10 82 10 f0       	push   $0xf0108210
f0105bfe:	e8 6c dc ff ff       	call   f010386f <cprintf>
			ismp = 0;
f0105c03:	c7 05 00 30 21 f0 00 	movl   $0x0,0xf0213000
f0105c0a:	00 00 00 
			i = conf->entry;
f0105c0d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105c11:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105c14:	83 c6 01             	add    $0x1,%esi
f0105c17:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105c1b:	39 c6                	cmp    %eax,%esi
f0105c1d:	0f 82 6f ff ff ff    	jb     f0105b92 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105c23:	a1 c0 33 21 f0       	mov    0xf02133c0,%eax
f0105c28:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105c2f:	83 3d 00 30 21 f0 00 	cmpl   $0x0,0xf0213000
f0105c36:	75 26                	jne    f0105c5e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105c38:	c7 05 c4 33 21 f0 01 	movl   $0x1,0xf02133c4
f0105c3f:	00 00 00 
		lapicaddr = 0;
f0105c42:	c7 05 00 40 25 f0 00 	movl   $0x0,0xf0254000
f0105c49:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105c4c:	83 ec 0c             	sub    $0xc,%esp
f0105c4f:	68 30 82 10 f0       	push   $0xf0108230
f0105c54:	e8 16 dc ff ff       	call   f010386f <cprintf>
		return;
f0105c59:	83 c4 10             	add    $0x10,%esp
f0105c5c:	eb 48                	jmp    f0105ca6 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105c5e:	83 ec 04             	sub    $0x4,%esp
f0105c61:	ff 35 c4 33 21 f0    	pushl  0xf02133c4
f0105c67:	0f b6 00             	movzbl (%eax),%eax
f0105c6a:	50                   	push   %eax
f0105c6b:	68 b7 82 10 f0       	push   $0xf01082b7
f0105c70:	e8 fa db ff ff       	call   f010386f <cprintf>

	if (mp->imcrp) {
f0105c75:	83 c4 10             	add    $0x10,%esp
f0105c78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105c7b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105c7f:	74 25                	je     f0105ca6 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105c81:	83 ec 0c             	sub    $0xc,%esp
f0105c84:	68 5c 82 10 f0       	push   $0xf010825c
f0105c89:	e8 e1 db ff ff       	call   f010386f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105c8e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105c93:	b8 70 00 00 00       	mov    $0x70,%eax
f0105c98:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105c99:	ba 23 00 00 00       	mov    $0x23,%edx
f0105c9e:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105c9f:	83 c8 01             	or     $0x1,%eax
f0105ca2:	ee                   	out    %al,(%dx)
f0105ca3:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105ca6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105ca9:	5b                   	pop    %ebx
f0105caa:	5e                   	pop    %esi
f0105cab:	5f                   	pop    %edi
f0105cac:	5d                   	pop    %ebp
f0105cad:	c3                   	ret    

f0105cae <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105cae:	55                   	push   %ebp
f0105caf:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105cb1:	8b 0d 04 40 25 f0    	mov    0xf0254004,%ecx
f0105cb7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105cba:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105cbc:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f0105cc1:	8b 40 20             	mov    0x20(%eax),%eax
//	panic("after lapicw.\n");
}
f0105cc4:	5d                   	pop    %ebp
f0105cc5:	c3                   	ret    

f0105cc6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105cc6:	55                   	push   %ebp
f0105cc7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105cc9:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f0105cce:	85 c0                	test   %eax,%eax
f0105cd0:	74 08                	je     f0105cda <cpunum+0x14>
		return lapic[ID] >> 24;
f0105cd2:	8b 40 20             	mov    0x20(%eax),%eax
f0105cd5:	c1 e8 18             	shr    $0x18,%eax
f0105cd8:	eb 05                	jmp    f0105cdf <cpunum+0x19>
	return 0;
f0105cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cdf:	5d                   	pop    %ebp
f0105ce0:	c3                   	ret    

f0105ce1 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105ce1:	a1 00 40 25 f0       	mov    0xf0254000,%eax
f0105ce6:	85 c0                	test   %eax,%eax
f0105ce8:	0f 84 21 01 00 00    	je     f0105e0f <lapic_init+0x12e>
//	panic("after lapicw.\n");
}

void
lapic_init(void)
{
f0105cee:	55                   	push   %ebp
f0105cef:	89 e5                	mov    %esp,%ebp
f0105cf1:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105cf4:	68 00 10 00 00       	push   $0x1000
f0105cf9:	50                   	push   %eax
f0105cfa:	e8 fb b6 ff ff       	call   f01013fa <mmio_map_region>
f0105cff:	a3 04 40 25 f0       	mov    %eax,0xf0254004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105d04:	ba 27 01 00 00       	mov    $0x127,%edx
f0105d09:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105d0e:	e8 9b ff ff ff       	call   f0105cae <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105d13:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105d18:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105d1d:	e8 8c ff ff ff       	call   f0105cae <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105d22:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105d27:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105d2c:	e8 7d ff ff ff       	call   f0105cae <lapicw>
	lapicw(TICR, 10000000); 
f0105d31:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105d36:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105d3b:	e8 6e ff ff ff       	call   f0105cae <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105d40:	e8 81 ff ff ff       	call   f0105cc6 <cpunum>
f0105d45:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d48:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0105d4d:	83 c4 10             	add    $0x10,%esp
f0105d50:	39 05 c0 33 21 f0    	cmp    %eax,0xf02133c0
f0105d56:	74 0f                	je     f0105d67 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105d58:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d5d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105d62:	e8 47 ff ff ff       	call   f0105cae <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105d67:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d6c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105d71:	e8 38 ff ff ff       	call   f0105cae <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105d76:	a1 04 40 25 f0       	mov    0xf0254004,%eax
f0105d7b:	8b 40 30             	mov    0x30(%eax),%eax
f0105d7e:	c1 e8 10             	shr    $0x10,%eax
f0105d81:	3c 03                	cmp    $0x3,%al
f0105d83:	76 0f                	jbe    f0105d94 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105d85:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d8a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105d8f:	e8 1a ff ff ff       	call   f0105cae <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105d94:	ba 33 00 00 00       	mov    $0x33,%edx
f0105d99:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105d9e:	e8 0b ff ff ff       	call   f0105cae <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105da3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105da8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105dad:	e8 fc fe ff ff       	call   f0105cae <lapicw>
	lapicw(ESR, 0);
f0105db2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105db7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105dbc:	e8 ed fe ff ff       	call   f0105cae <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105dc1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dc6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105dcb:	e8 de fe ff ff       	call   f0105cae <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105dd0:	ba 00 00 00 00       	mov    $0x0,%edx
f0105dd5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105dda:	e8 cf fe ff ff       	call   f0105cae <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105ddf:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105de4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105de9:	e8 c0 fe ff ff       	call   f0105cae <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105dee:	8b 15 04 40 25 f0    	mov    0xf0254004,%edx
f0105df4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105dfa:	f6 c4 10             	test   $0x10,%ah
f0105dfd:	75 f5                	jne    f0105df4 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105dff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e04:	b8 20 00 00 00       	mov    $0x20,%eax
f0105e09:	e8 a0 fe ff ff       	call   f0105cae <lapicw>
}
f0105e0e:	c9                   	leave  
f0105e0f:	f3 c3                	repz ret 

f0105e11 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105e11:	83 3d 04 40 25 f0 00 	cmpl   $0x0,0xf0254004
f0105e18:	74 13                	je     f0105e2d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105e1a:	55                   	push   %ebp
f0105e1b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105e1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e22:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e27:	e8 82 fe ff ff       	call   f0105cae <lapicw>
}
f0105e2c:	5d                   	pop    %ebp
f0105e2d:	f3 c3                	repz ret 

f0105e2f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105e2f:	55                   	push   %ebp
f0105e30:	89 e5                	mov    %esp,%ebp
f0105e32:	56                   	push   %esi
f0105e33:	53                   	push   %ebx
f0105e34:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105e3a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105e3f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105e44:	ee                   	out    %al,(%dx)
f0105e45:	ba 71 00 00 00       	mov    $0x71,%edx
f0105e4a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105e4f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e50:	83 3d 88 2e 21 f0 00 	cmpl   $0x0,0xf0212e88
f0105e57:	75 19                	jne    f0105e72 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e59:	68 67 04 00 00       	push   $0x467
f0105e5e:	68 48 64 10 f0       	push   $0xf0106448
f0105e63:	68 99 00 00 00       	push   $0x99
f0105e68:	68 d4 82 10 f0       	push   $0xf01082d4
f0105e6d:	e8 22 a2 ff ff       	call   f0100094 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105e72:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105e79:	00 00 
	wrv[1] = addr >> 4;
f0105e7b:	89 d8                	mov    %ebx,%eax
f0105e7d:	c1 e8 04             	shr    $0x4,%eax
f0105e80:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105e86:	c1 e6 18             	shl    $0x18,%esi
f0105e89:	89 f2                	mov    %esi,%edx
f0105e8b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e90:	e8 19 fe ff ff       	call   f0105cae <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105e95:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105e9a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e9f:	e8 0a fe ff ff       	call   f0105cae <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105ea4:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105ea9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105eae:	e8 fb fd ff ff       	call   f0105cae <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105eb3:	c1 eb 0c             	shr    $0xc,%ebx
f0105eb6:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105eb9:	89 f2                	mov    %esi,%edx
f0105ebb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ec0:	e8 e9 fd ff ff       	call   f0105cae <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ec5:	89 da                	mov    %ebx,%edx
f0105ec7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ecc:	e8 dd fd ff ff       	call   f0105cae <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ed1:	89 f2                	mov    %esi,%edx
f0105ed3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ed8:	e8 d1 fd ff ff       	call   f0105cae <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105edd:	89 da                	mov    %ebx,%edx
f0105edf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ee4:	e8 c5 fd ff ff       	call   f0105cae <lapicw>
		microdelay(200);
	}
}
f0105ee9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105eec:	5b                   	pop    %ebx
f0105eed:	5e                   	pop    %esi
f0105eee:	5d                   	pop    %ebp
f0105eef:	c3                   	ret    

f0105ef0 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105ef0:	55                   	push   %ebp
f0105ef1:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105ef3:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ef6:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105efc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f01:	e8 a8 fd ff ff       	call   f0105cae <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105f06:	8b 15 04 40 25 f0    	mov    0xf0254004,%edx
f0105f0c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105f12:	f6 c4 10             	test   $0x10,%ah
f0105f15:	75 f5                	jne    f0105f0c <lapic_ipi+0x1c>
		;
}
f0105f17:	5d                   	pop    %ebp
f0105f18:	c3                   	ret    

f0105f19 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105f19:	55                   	push   %ebp
f0105f1a:	89 e5                	mov    %esp,%ebp
f0105f1c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105f1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105f25:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f28:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105f2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105f32:	5d                   	pop    %ebp
f0105f33:	c3                   	ret    

f0105f34 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105f34:	55                   	push   %ebp
f0105f35:	89 e5                	mov    %esp,%ebp
f0105f37:	56                   	push   %esi
f0105f38:	53                   	push   %ebx
f0105f39:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105f3c:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105f3f:	74 14                	je     f0105f55 <spin_lock+0x21>
f0105f41:	8b 73 08             	mov    0x8(%ebx),%esi
f0105f44:	e8 7d fd ff ff       	call   f0105cc6 <cpunum>
f0105f49:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f4c:	05 20 30 21 f0       	add    $0xf0213020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105f51:	39 c6                	cmp    %eax,%esi
f0105f53:	74 07                	je     f0105f5c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105f55:	ba 01 00 00 00       	mov    $0x1,%edx
f0105f5a:	eb 20                	jmp    f0105f7c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105f5c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105f5f:	e8 62 fd ff ff       	call   f0105cc6 <cpunum>
f0105f64:	83 ec 0c             	sub    $0xc,%esp
f0105f67:	53                   	push   %ebx
f0105f68:	50                   	push   %eax
f0105f69:	68 e4 82 10 f0       	push   $0xf01082e4
f0105f6e:	6a 41                	push   $0x41
f0105f70:	68 48 83 10 f0       	push   $0xf0108348
f0105f75:	e8 1a a1 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105f7a:	f3 90                	pause  
f0105f7c:	89 d0                	mov    %edx,%eax
f0105f7e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105f81:	85 c0                	test   %eax,%eax
f0105f83:	75 f5                	jne    f0105f7a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105f85:	e8 3c fd ff ff       	call   f0105cc6 <cpunum>
f0105f8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f8d:	05 20 30 21 f0       	add    $0xf0213020,%eax
f0105f92:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105f95:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105f98:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105f9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f9f:	eb 0b                	jmp    f0105fac <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105fa1:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105fa4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105fa7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105fa9:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105fac:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105fb2:	76 11                	jbe    f0105fc5 <spin_lock+0x91>
f0105fb4:	83 f8 09             	cmp    $0x9,%eax
f0105fb7:	7e e8                	jle    f0105fa1 <spin_lock+0x6d>
f0105fb9:	eb 0a                	jmp    f0105fc5 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105fbb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105fc2:	83 c0 01             	add    $0x1,%eax
f0105fc5:	83 f8 09             	cmp    $0x9,%eax
f0105fc8:	7e f1                	jle    f0105fbb <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105fca:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105fcd:	5b                   	pop    %ebx
f0105fce:	5e                   	pop    %esi
f0105fcf:	5d                   	pop    %ebp
f0105fd0:	c3                   	ret    

f0105fd1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105fd1:	55                   	push   %ebp
f0105fd2:	89 e5                	mov    %esp,%ebp
f0105fd4:	57                   	push   %edi
f0105fd5:	56                   	push   %esi
f0105fd6:	53                   	push   %ebx
f0105fd7:	83 ec 4c             	sub    $0x4c,%esp
f0105fda:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105fdd:	83 3e 00             	cmpl   $0x0,(%esi)
f0105fe0:	74 18                	je     f0105ffa <spin_unlock+0x29>
f0105fe2:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105fe5:	e8 dc fc ff ff       	call   f0105cc6 <cpunum>
f0105fea:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fed:	05 20 30 21 f0       	add    $0xf0213020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105ff2:	39 c3                	cmp    %eax,%ebx
f0105ff4:	0f 84 a5 00 00 00    	je     f010609f <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105ffa:	83 ec 04             	sub    $0x4,%esp
f0105ffd:	6a 28                	push   $0x28
f0105fff:	8d 46 0c             	lea    0xc(%esi),%eax
f0106002:	50                   	push   %eax
f0106003:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106006:	53                   	push   %ebx
f0106007:	e8 e5 f6 ff ff       	call   f01056f1 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010600c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010600f:	0f b6 38             	movzbl (%eax),%edi
f0106012:	8b 76 04             	mov    0x4(%esi),%esi
f0106015:	e8 ac fc ff ff       	call   f0105cc6 <cpunum>
f010601a:	57                   	push   %edi
f010601b:	56                   	push   %esi
f010601c:	50                   	push   %eax
f010601d:	68 10 83 10 f0       	push   $0xf0108310
f0106022:	e8 48 d8 ff ff       	call   f010386f <cprintf>
f0106027:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010602a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010602d:	eb 54                	jmp    f0106083 <spin_unlock+0xb2>
f010602f:	83 ec 08             	sub    $0x8,%esp
f0106032:	57                   	push   %edi
f0106033:	50                   	push   %eax
f0106034:	e8 aa ec ff ff       	call   f0104ce3 <debuginfo_eip>
f0106039:	83 c4 10             	add    $0x10,%esp
f010603c:	85 c0                	test   %eax,%eax
f010603e:	78 27                	js     f0106067 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106040:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106042:	83 ec 04             	sub    $0x4,%esp
f0106045:	89 c2                	mov    %eax,%edx
f0106047:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010604a:	52                   	push   %edx
f010604b:	ff 75 b0             	pushl  -0x50(%ebp)
f010604e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106051:	ff 75 ac             	pushl  -0x54(%ebp)
f0106054:	ff 75 a8             	pushl  -0x58(%ebp)
f0106057:	50                   	push   %eax
f0106058:	68 58 83 10 f0       	push   $0xf0108358
f010605d:	e8 0d d8 ff ff       	call   f010386f <cprintf>
f0106062:	83 c4 20             	add    $0x20,%esp
f0106065:	eb 12                	jmp    f0106079 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106067:	83 ec 08             	sub    $0x8,%esp
f010606a:	ff 36                	pushl  (%esi)
f010606c:	68 6f 83 10 f0       	push   $0xf010836f
f0106071:	e8 f9 d7 ff ff       	call   f010386f <cprintf>
f0106076:	83 c4 10             	add    $0x10,%esp
f0106079:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010607c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010607f:	39 c3                	cmp    %eax,%ebx
f0106081:	74 08                	je     f010608b <spin_unlock+0xba>
f0106083:	89 de                	mov    %ebx,%esi
f0106085:	8b 03                	mov    (%ebx),%eax
f0106087:	85 c0                	test   %eax,%eax
f0106089:	75 a4                	jne    f010602f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010608b:	83 ec 04             	sub    $0x4,%esp
f010608e:	68 77 83 10 f0       	push   $0xf0108377
f0106093:	6a 67                	push   $0x67
f0106095:	68 48 83 10 f0       	push   $0xf0108348
f010609a:	e8 f5 9f ff ff       	call   f0100094 <_panic>
	}

	lk->pcs[0] = 0;
f010609f:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01060a6:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01060ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01060b2:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01060b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01060b8:	5b                   	pop    %ebx
f01060b9:	5e                   	pop    %esi
f01060ba:	5f                   	pop    %edi
f01060bb:	5d                   	pop    %ebp
f01060bc:	c3                   	ret    
f01060bd:	66 90                	xchg   %ax,%ax
f01060bf:	90                   	nop

f01060c0 <__udivdi3>:
f01060c0:	55                   	push   %ebp
f01060c1:	57                   	push   %edi
f01060c2:	56                   	push   %esi
f01060c3:	53                   	push   %ebx
f01060c4:	83 ec 1c             	sub    $0x1c,%esp
f01060c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01060cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01060cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01060d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01060d7:	85 f6                	test   %esi,%esi
f01060d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01060dd:	89 ca                	mov    %ecx,%edx
f01060df:	89 f8                	mov    %edi,%eax
f01060e1:	75 3d                	jne    f0106120 <__udivdi3+0x60>
f01060e3:	39 cf                	cmp    %ecx,%edi
f01060e5:	0f 87 c5 00 00 00    	ja     f01061b0 <__udivdi3+0xf0>
f01060eb:	85 ff                	test   %edi,%edi
f01060ed:	89 fd                	mov    %edi,%ebp
f01060ef:	75 0b                	jne    f01060fc <__udivdi3+0x3c>
f01060f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01060f6:	31 d2                	xor    %edx,%edx
f01060f8:	f7 f7                	div    %edi
f01060fa:	89 c5                	mov    %eax,%ebp
f01060fc:	89 c8                	mov    %ecx,%eax
f01060fe:	31 d2                	xor    %edx,%edx
f0106100:	f7 f5                	div    %ebp
f0106102:	89 c1                	mov    %eax,%ecx
f0106104:	89 d8                	mov    %ebx,%eax
f0106106:	89 cf                	mov    %ecx,%edi
f0106108:	f7 f5                	div    %ebp
f010610a:	89 c3                	mov    %eax,%ebx
f010610c:	89 d8                	mov    %ebx,%eax
f010610e:	89 fa                	mov    %edi,%edx
f0106110:	83 c4 1c             	add    $0x1c,%esp
f0106113:	5b                   	pop    %ebx
f0106114:	5e                   	pop    %esi
f0106115:	5f                   	pop    %edi
f0106116:	5d                   	pop    %ebp
f0106117:	c3                   	ret    
f0106118:	90                   	nop
f0106119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106120:	39 ce                	cmp    %ecx,%esi
f0106122:	77 74                	ja     f0106198 <__udivdi3+0xd8>
f0106124:	0f bd fe             	bsr    %esi,%edi
f0106127:	83 f7 1f             	xor    $0x1f,%edi
f010612a:	0f 84 98 00 00 00    	je     f01061c8 <__udivdi3+0x108>
f0106130:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106135:	89 f9                	mov    %edi,%ecx
f0106137:	89 c5                	mov    %eax,%ebp
f0106139:	29 fb                	sub    %edi,%ebx
f010613b:	d3 e6                	shl    %cl,%esi
f010613d:	89 d9                	mov    %ebx,%ecx
f010613f:	d3 ed                	shr    %cl,%ebp
f0106141:	89 f9                	mov    %edi,%ecx
f0106143:	d3 e0                	shl    %cl,%eax
f0106145:	09 ee                	or     %ebp,%esi
f0106147:	89 d9                	mov    %ebx,%ecx
f0106149:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010614d:	89 d5                	mov    %edx,%ebp
f010614f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106153:	d3 ed                	shr    %cl,%ebp
f0106155:	89 f9                	mov    %edi,%ecx
f0106157:	d3 e2                	shl    %cl,%edx
f0106159:	89 d9                	mov    %ebx,%ecx
f010615b:	d3 e8                	shr    %cl,%eax
f010615d:	09 c2                	or     %eax,%edx
f010615f:	89 d0                	mov    %edx,%eax
f0106161:	89 ea                	mov    %ebp,%edx
f0106163:	f7 f6                	div    %esi
f0106165:	89 d5                	mov    %edx,%ebp
f0106167:	89 c3                	mov    %eax,%ebx
f0106169:	f7 64 24 0c          	mull   0xc(%esp)
f010616d:	39 d5                	cmp    %edx,%ebp
f010616f:	72 10                	jb     f0106181 <__udivdi3+0xc1>
f0106171:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106175:	89 f9                	mov    %edi,%ecx
f0106177:	d3 e6                	shl    %cl,%esi
f0106179:	39 c6                	cmp    %eax,%esi
f010617b:	73 07                	jae    f0106184 <__udivdi3+0xc4>
f010617d:	39 d5                	cmp    %edx,%ebp
f010617f:	75 03                	jne    f0106184 <__udivdi3+0xc4>
f0106181:	83 eb 01             	sub    $0x1,%ebx
f0106184:	31 ff                	xor    %edi,%edi
f0106186:	89 d8                	mov    %ebx,%eax
f0106188:	89 fa                	mov    %edi,%edx
f010618a:	83 c4 1c             	add    $0x1c,%esp
f010618d:	5b                   	pop    %ebx
f010618e:	5e                   	pop    %esi
f010618f:	5f                   	pop    %edi
f0106190:	5d                   	pop    %ebp
f0106191:	c3                   	ret    
f0106192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106198:	31 ff                	xor    %edi,%edi
f010619a:	31 db                	xor    %ebx,%ebx
f010619c:	89 d8                	mov    %ebx,%eax
f010619e:	89 fa                	mov    %edi,%edx
f01061a0:	83 c4 1c             	add    $0x1c,%esp
f01061a3:	5b                   	pop    %ebx
f01061a4:	5e                   	pop    %esi
f01061a5:	5f                   	pop    %edi
f01061a6:	5d                   	pop    %ebp
f01061a7:	c3                   	ret    
f01061a8:	90                   	nop
f01061a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01061b0:	89 d8                	mov    %ebx,%eax
f01061b2:	f7 f7                	div    %edi
f01061b4:	31 ff                	xor    %edi,%edi
f01061b6:	89 c3                	mov    %eax,%ebx
f01061b8:	89 d8                	mov    %ebx,%eax
f01061ba:	89 fa                	mov    %edi,%edx
f01061bc:	83 c4 1c             	add    $0x1c,%esp
f01061bf:	5b                   	pop    %ebx
f01061c0:	5e                   	pop    %esi
f01061c1:	5f                   	pop    %edi
f01061c2:	5d                   	pop    %ebp
f01061c3:	c3                   	ret    
f01061c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01061c8:	39 ce                	cmp    %ecx,%esi
f01061ca:	72 0c                	jb     f01061d8 <__udivdi3+0x118>
f01061cc:	31 db                	xor    %ebx,%ebx
f01061ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01061d2:	0f 87 34 ff ff ff    	ja     f010610c <__udivdi3+0x4c>
f01061d8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01061dd:	e9 2a ff ff ff       	jmp    f010610c <__udivdi3+0x4c>
f01061e2:	66 90                	xchg   %ax,%ax
f01061e4:	66 90                	xchg   %ax,%ax
f01061e6:	66 90                	xchg   %ax,%ax
f01061e8:	66 90                	xchg   %ax,%ax
f01061ea:	66 90                	xchg   %ax,%ax
f01061ec:	66 90                	xchg   %ax,%ax
f01061ee:	66 90                	xchg   %ax,%ax

f01061f0 <__umoddi3>:
f01061f0:	55                   	push   %ebp
f01061f1:	57                   	push   %edi
f01061f2:	56                   	push   %esi
f01061f3:	53                   	push   %ebx
f01061f4:	83 ec 1c             	sub    $0x1c,%esp
f01061f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01061fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01061ff:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106203:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106207:	85 d2                	test   %edx,%edx
f0106209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010620d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106211:	89 f3                	mov    %esi,%ebx
f0106213:	89 3c 24             	mov    %edi,(%esp)
f0106216:	89 74 24 04          	mov    %esi,0x4(%esp)
f010621a:	75 1c                	jne    f0106238 <__umoddi3+0x48>
f010621c:	39 f7                	cmp    %esi,%edi
f010621e:	76 50                	jbe    f0106270 <__umoddi3+0x80>
f0106220:	89 c8                	mov    %ecx,%eax
f0106222:	89 f2                	mov    %esi,%edx
f0106224:	f7 f7                	div    %edi
f0106226:	89 d0                	mov    %edx,%eax
f0106228:	31 d2                	xor    %edx,%edx
f010622a:	83 c4 1c             	add    $0x1c,%esp
f010622d:	5b                   	pop    %ebx
f010622e:	5e                   	pop    %esi
f010622f:	5f                   	pop    %edi
f0106230:	5d                   	pop    %ebp
f0106231:	c3                   	ret    
f0106232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106238:	39 f2                	cmp    %esi,%edx
f010623a:	89 d0                	mov    %edx,%eax
f010623c:	77 52                	ja     f0106290 <__umoddi3+0xa0>
f010623e:	0f bd ea             	bsr    %edx,%ebp
f0106241:	83 f5 1f             	xor    $0x1f,%ebp
f0106244:	75 5a                	jne    f01062a0 <__umoddi3+0xb0>
f0106246:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010624a:	0f 82 e0 00 00 00    	jb     f0106330 <__umoddi3+0x140>
f0106250:	39 0c 24             	cmp    %ecx,(%esp)
f0106253:	0f 86 d7 00 00 00    	jbe    f0106330 <__umoddi3+0x140>
f0106259:	8b 44 24 08          	mov    0x8(%esp),%eax
f010625d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106261:	83 c4 1c             	add    $0x1c,%esp
f0106264:	5b                   	pop    %ebx
f0106265:	5e                   	pop    %esi
f0106266:	5f                   	pop    %edi
f0106267:	5d                   	pop    %ebp
f0106268:	c3                   	ret    
f0106269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106270:	85 ff                	test   %edi,%edi
f0106272:	89 fd                	mov    %edi,%ebp
f0106274:	75 0b                	jne    f0106281 <__umoddi3+0x91>
f0106276:	b8 01 00 00 00       	mov    $0x1,%eax
f010627b:	31 d2                	xor    %edx,%edx
f010627d:	f7 f7                	div    %edi
f010627f:	89 c5                	mov    %eax,%ebp
f0106281:	89 f0                	mov    %esi,%eax
f0106283:	31 d2                	xor    %edx,%edx
f0106285:	f7 f5                	div    %ebp
f0106287:	89 c8                	mov    %ecx,%eax
f0106289:	f7 f5                	div    %ebp
f010628b:	89 d0                	mov    %edx,%eax
f010628d:	eb 99                	jmp    f0106228 <__umoddi3+0x38>
f010628f:	90                   	nop
f0106290:	89 c8                	mov    %ecx,%eax
f0106292:	89 f2                	mov    %esi,%edx
f0106294:	83 c4 1c             	add    $0x1c,%esp
f0106297:	5b                   	pop    %ebx
f0106298:	5e                   	pop    %esi
f0106299:	5f                   	pop    %edi
f010629a:	5d                   	pop    %ebp
f010629b:	c3                   	ret    
f010629c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01062a0:	8b 34 24             	mov    (%esp),%esi
f01062a3:	bf 20 00 00 00       	mov    $0x20,%edi
f01062a8:	89 e9                	mov    %ebp,%ecx
f01062aa:	29 ef                	sub    %ebp,%edi
f01062ac:	d3 e0                	shl    %cl,%eax
f01062ae:	89 f9                	mov    %edi,%ecx
f01062b0:	89 f2                	mov    %esi,%edx
f01062b2:	d3 ea                	shr    %cl,%edx
f01062b4:	89 e9                	mov    %ebp,%ecx
f01062b6:	09 c2                	or     %eax,%edx
f01062b8:	89 d8                	mov    %ebx,%eax
f01062ba:	89 14 24             	mov    %edx,(%esp)
f01062bd:	89 f2                	mov    %esi,%edx
f01062bf:	d3 e2                	shl    %cl,%edx
f01062c1:	89 f9                	mov    %edi,%ecx
f01062c3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01062c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01062cb:	d3 e8                	shr    %cl,%eax
f01062cd:	89 e9                	mov    %ebp,%ecx
f01062cf:	89 c6                	mov    %eax,%esi
f01062d1:	d3 e3                	shl    %cl,%ebx
f01062d3:	89 f9                	mov    %edi,%ecx
f01062d5:	89 d0                	mov    %edx,%eax
f01062d7:	d3 e8                	shr    %cl,%eax
f01062d9:	89 e9                	mov    %ebp,%ecx
f01062db:	09 d8                	or     %ebx,%eax
f01062dd:	89 d3                	mov    %edx,%ebx
f01062df:	89 f2                	mov    %esi,%edx
f01062e1:	f7 34 24             	divl   (%esp)
f01062e4:	89 d6                	mov    %edx,%esi
f01062e6:	d3 e3                	shl    %cl,%ebx
f01062e8:	f7 64 24 04          	mull   0x4(%esp)
f01062ec:	39 d6                	cmp    %edx,%esi
f01062ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01062f2:	89 d1                	mov    %edx,%ecx
f01062f4:	89 c3                	mov    %eax,%ebx
f01062f6:	72 08                	jb     f0106300 <__umoddi3+0x110>
f01062f8:	75 11                	jne    f010630b <__umoddi3+0x11b>
f01062fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01062fe:	73 0b                	jae    f010630b <__umoddi3+0x11b>
f0106300:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106304:	1b 14 24             	sbb    (%esp),%edx
f0106307:	89 d1                	mov    %edx,%ecx
f0106309:	89 c3                	mov    %eax,%ebx
f010630b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010630f:	29 da                	sub    %ebx,%edx
f0106311:	19 ce                	sbb    %ecx,%esi
f0106313:	89 f9                	mov    %edi,%ecx
f0106315:	89 f0                	mov    %esi,%eax
f0106317:	d3 e0                	shl    %cl,%eax
f0106319:	89 e9                	mov    %ebp,%ecx
f010631b:	d3 ea                	shr    %cl,%edx
f010631d:	89 e9                	mov    %ebp,%ecx
f010631f:	d3 ee                	shr    %cl,%esi
f0106321:	09 d0                	or     %edx,%eax
f0106323:	89 f2                	mov    %esi,%edx
f0106325:	83 c4 1c             	add    $0x1c,%esp
f0106328:	5b                   	pop    %ebx
f0106329:	5e                   	pop    %esi
f010632a:	5f                   	pop    %edi
f010632b:	5d                   	pop    %ebp
f010632c:	c3                   	ret    
f010632d:	8d 76 00             	lea    0x0(%esi),%esi
f0106330:	29 f9                	sub    %edi,%ecx
f0106332:	19 d6                	sbb    %edx,%esi
f0106334:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010633c:	e9 18 ff ff ff       	jmp    f0106259 <__umoddi3+0x69>
