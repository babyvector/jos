
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
f010004b:	68 00 62 10 f0       	push   $0xf0106200
f0100050:	e8 33 38 00 00       	call   f0103888 <cprintf>
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
f0100076:	e8 6e 08 00 00       	call   f01008e9 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 62 10 f0       	push   $0xf010621c
f0100087:	e8 fc 37 00 00       	call   f0103888 <cprintf>


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
f010009c:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f01000a3:	75 3a                	jne    f01000df <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f01000a5:	89 35 80 fe 22 f0    	mov    %esi,0xf022fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000ab:	fa                   	cli    
f01000ac:	fc                   	cld    

	va_start(ap, fmt);
f01000ad:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000b0:	e8 ad 5a 00 00       	call   f0105b62 <cpunum>
f01000b5:	ff 75 0c             	pushl  0xc(%ebp)
f01000b8:	ff 75 08             	pushl  0x8(%ebp)
f01000bb:	50                   	push   %eax
f01000bc:	68 a0 62 10 f0       	push   $0xf01062a0
f01000c1:	e8 c2 37 00 00       	call   f0103888 <cprintf>
	vcprintf(fmt, ap);
f01000c6:	83 c4 08             	add    $0x8,%esp
f01000c9:	53                   	push   %ebx
f01000ca:	56                   	push   %esi
f01000cb:	e8 92 37 00 00       	call   f0103862 <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 c4 65 10 f0 	movl   $0xf01065c4,(%esp)
f01000d7:	e8 ac 37 00 00       	call   f0103888 <cprintf>
	va_end(ap);
f01000dc:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	83 ec 0c             	sub    $0xc,%esp
f01000e2:	6a 00                	push   $0x0
f01000e4:	e8 77 08 00 00       	call   f0100960 <monitor>
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
f01000f5:	b8 08 10 27 f0       	mov    $0xf0271008,%eax
f01000fa:	2d 10 e9 22 f0       	sub    $0xf022e910,%eax
f01000ff:	50                   	push   %eax
f0100100:	6a 00                	push   $0x0
f0100102:	68 10 e9 22 f0       	push   $0xf022e910
f0100107:	e8 35 54 00 00       	call   f0105541 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 97 05 00 00       	call   f01006a8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	68 ac 1a 00 00       	push   $0x1aac
f0100119:	68 37 62 10 f0       	push   $0xf0106237
f010011e:	e8 65 37 00 00       	call   f0103888 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100123:	e8 58 13 00 00       	call   f0101480 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100128:	e8 59 2f 00 00       	call   f0103086 <env_init>

	trap_init();
f010012d:	e8 57 38 00 00       	call   f0103989 <trap_init>
	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100132:	e8 21 57 00 00       	call   f0105858 <mp_init>
	lapic_init();
f0100137:	e8 41 5a 00 00       	call   f0105b7d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013c:	e8 6e 36 00 00       	call   f01037af <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100141:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100148:	e8 83 5c 00 00       	call   f0105dd0 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010014d:	83 c4 10             	add    $0x10,%esp
f0100150:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f0100157:	77 16                	ja     f010016f <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100159:	68 00 70 00 00       	push   $0x7000
f010015e:	68 c4 62 10 f0       	push   $0xf01062c4
f0100163:	6a 6d                	push   $0x6d
f0100165:	68 52 62 10 f0       	push   $0xf0106252
f010016a:	e8 25 ff ff ff       	call   f0100094 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010016f:	83 ec 04             	sub    $0x4,%esp
f0100172:	b8 be 57 10 f0       	mov    $0xf01057be,%eax
f0100177:	2d 44 57 10 f0       	sub    $0xf0105744,%eax
f010017c:	50                   	push   %eax
f010017d:	68 44 57 10 f0       	push   $0xf0105744
f0100182:	68 00 70 00 f0       	push   $0xf0007000
f0100187:	e8 02 54 00 00       	call   f010558e <memmove>
f010018c:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018f:	bb 20 00 23 f0       	mov    $0xf0230020,%ebx
f0100194:	eb 4d                	jmp    f01001e3 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100196:	e8 c7 59 00 00       	call   f0105b62 <cpunum>
f010019b:	6b c0 74             	imul   $0x74,%eax,%eax
f010019e:	05 20 00 23 f0       	add    $0xf0230020,%eax
f01001a3:	39 c3                	cmp    %eax,%ebx
f01001a5:	74 39                	je     f01001e0 <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001a7:	89 d8                	mov    %ebx,%eax
f01001a9:	2d 20 00 23 f0       	sub    $0xf0230020,%eax
f01001ae:	c1 f8 02             	sar    $0x2,%eax
f01001b1:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001b7:	c1 e0 0f             	shl    $0xf,%eax
f01001ba:	05 00 90 23 f0       	add    $0xf0239000,%eax
f01001bf:	a3 84 fe 22 f0       	mov    %eax,0xf022fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001c4:	83 ec 08             	sub    $0x8,%esp
f01001c7:	68 00 70 00 00       	push   $0x7000
f01001cc:	0f b6 03             	movzbl (%ebx),%eax
f01001cf:	50                   	push   %eax
f01001d0:	e8 f6 5a 00 00       	call   f0105ccb <lapic_startap>
f01001d5:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f01001d8:	8b 43 04             	mov    0x4(%ebx),%eax
f01001db:	83 f8 01             	cmp    $0x1,%eax
f01001de:	75 f8                	jne    f01001d8 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001e0:	83 c3 74             	add    $0x74,%ebx
f01001e3:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f01001ea:	05 20 00 23 f0       	add    $0xf0230020,%eax
f01001ef:	39 c3                	cmp    %eax,%ebx
f01001f1:	72 a3                	jb     f0100196 <i386_init+0xa8>
	boot_aps();


#if defined(TEST)
	// Don't touch -- used by grading script!
	cprintf("in the if TEST.\n");
f01001f3:	83 ec 0c             	sub    $0xc,%esp
f01001f6:	68 5e 62 10 f0       	push   $0xf010625e
f01001fb:	e8 88 36 00 00       	call   f0103888 <cprintf>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100200:	83 c4 08             	add    $0x8,%esp
f0100203:	6a 00                	push   $0x0
f0100205:	68 b8 e2 1e f0       	push   $0xf01ee2b8
f010020a:	e8 7c 30 00 00       	call   f010328b <env_create>

	//we use the next  line to test Excerse 7
	ENV_CREATE(user_dumbfork,ENV_TYPE_USER);
#endif 
	// Schedule and run the first user environment!
	sched_yield();
f010020f:	e8 00 43 00 00       	call   f0104514 <sched_yield>

f0100214 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f0100214:	55                   	push   %ebp
f0100215:	89 e5                	mov    %esp,%ebp
f0100217:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f010021a:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010021f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100224:	77 15                	ja     f010023b <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100226:	50                   	push   %eax
f0100227:	68 e8 62 10 f0       	push   $0xf01062e8
f010022c:	68 85 00 00 00       	push   $0x85
f0100231:	68 52 62 10 f0       	push   $0xf0106252
f0100236:	e8 59 fe ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010023b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100240:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100243:	e8 1a 59 00 00       	call   f0105b62 <cpunum>
f0100248:	83 ec 08             	sub    $0x8,%esp
f010024b:	50                   	push   %eax
f010024c:	68 6f 62 10 f0       	push   $0xf010626f
f0100251:	e8 32 36 00 00       	call   f0103888 <cprintf>

	lapic_init();
f0100256:	e8 22 59 00 00       	call   f0105b7d <lapic_init>
	env_init_percpu();
f010025b:	e8 f6 2d 00 00       	call   f0103056 <env_init_percpu>
	trap_init_percpu();
f0100260:	e8 37 36 00 00       	call   f010389c <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100265:	e8 f8 58 00 00       	call   f0105b62 <cpunum>
f010026a:	6b d0 74             	imul   $0x74,%eax,%edx
f010026d:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100273:	b8 01 00 00 00       	mov    $0x1,%eax
f0100278:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010027c:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100283:	e8 48 5b 00 00       	call   f0105dd0 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100288:	e8 87 42 00 00       	call   f0104514 <sched_yield>

f010028d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010028d:	55                   	push   %ebp
f010028e:	89 e5                	mov    %esp,%ebp
f0100290:	53                   	push   %ebx
f0100291:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100294:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100297:	ff 75 0c             	pushl  0xc(%ebp)
f010029a:	ff 75 08             	pushl  0x8(%ebp)
f010029d:	68 85 62 10 f0       	push   $0xf0106285
f01002a2:	e8 e1 35 00 00       	call   f0103888 <cprintf>
	vcprintf(fmt, ap);
f01002a7:	83 c4 08             	add    $0x8,%esp
f01002aa:	53                   	push   %ebx
f01002ab:	ff 75 10             	pushl  0x10(%ebp)
f01002ae:	e8 af 35 00 00       	call   f0103862 <vcprintf>
	cprintf("\n");
f01002b3:	c7 04 24 c4 65 10 f0 	movl   $0xf01065c4,(%esp)
f01002ba:	e8 c9 35 00 00       	call   f0103888 <cprintf>
	va_end(ap);
}
f01002bf:	83 c4 10             	add    $0x10,%esp
f01002c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002c5:	c9                   	leave  
f01002c6:	c3                   	ret    

f01002c7 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002c7:	55                   	push   %ebp
f01002c8:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ca:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002cf:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d0:	a8 01                	test   $0x1,%al
f01002d2:	74 0b                	je     f01002df <serial_proc_data+0x18>
f01002d4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002da:	0f b6 c0             	movzbl %al,%eax
f01002dd:	eb 05                	jmp    f01002e4 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002e4:	5d                   	pop    %ebp
f01002e5:	c3                   	ret    

f01002e6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002e6:	55                   	push   %ebp
f01002e7:	89 e5                	mov    %esp,%ebp
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 04             	sub    $0x4,%esp
f01002ed:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002ef:	eb 2b                	jmp    f010031c <cons_intr+0x36>
		if (c == 0)
f01002f1:	85 c0                	test   %eax,%eax
f01002f3:	74 27                	je     f010031c <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002f5:	8b 0d 24 f2 22 f0    	mov    0xf022f224,%ecx
f01002fb:	8d 51 01             	lea    0x1(%ecx),%edx
f01002fe:	89 15 24 f2 22 f0    	mov    %edx,0xf022f224
f0100304:	88 81 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010030a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100310:	75 0a                	jne    f010031c <cons_intr+0x36>
			cons.wpos = 0;
f0100312:	c7 05 24 f2 22 f0 00 	movl   $0x0,0xf022f224
f0100319:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010031c:	ff d3                	call   *%ebx
f010031e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100321:	75 ce                	jne    f01002f1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100323:	83 c4 04             	add    $0x4,%esp
f0100326:	5b                   	pop    %ebx
f0100327:	5d                   	pop    %ebp
f0100328:	c3                   	ret    

f0100329 <kbd_proc_data>:
f0100329:	ba 64 00 00 00       	mov    $0x64,%edx
f010032e:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f010032f:	a8 01                	test   $0x1,%al
f0100331:	0f 84 f8 00 00 00    	je     f010042f <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100337:	a8 20                	test   $0x20,%al
f0100339:	0f 85 f6 00 00 00    	jne    f0100435 <kbd_proc_data+0x10c>
f010033f:	ba 60 00 00 00       	mov    $0x60,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100347:	3c e0                	cmp    $0xe0,%al
f0100349:	75 0d                	jne    f0100358 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010034b:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
		return 0;
f0100352:	b8 00 00 00 00       	mov    $0x0,%eax
f0100357:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100358:	55                   	push   %ebp
f0100359:	89 e5                	mov    %esp,%ebp
f010035b:	53                   	push   %ebx
f010035c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010035f:	84 c0                	test   %al,%al
f0100361:	79 36                	jns    f0100399 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100363:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f0100369:	89 cb                	mov    %ecx,%ebx
f010036b:	83 e3 40             	and    $0x40,%ebx
f010036e:	83 e0 7f             	and    $0x7f,%eax
f0100371:	85 db                	test   %ebx,%ebx
f0100373:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100376:	0f b6 d2             	movzbl %dl,%edx
f0100379:	0f b6 82 60 64 10 f0 	movzbl -0xfef9ba0(%edx),%eax
f0100380:	83 c8 40             	or     $0x40,%eax
f0100383:	0f b6 c0             	movzbl %al,%eax
f0100386:	f7 d0                	not    %eax
f0100388:	21 c8                	and    %ecx,%eax
f010038a:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f010038f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100394:	e9 a4 00 00 00       	jmp    f010043d <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100399:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f010039f:	f6 c1 40             	test   $0x40,%cl
f01003a2:	74 0e                	je     f01003b2 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003a4:	83 c8 80             	or     $0xffffff80,%eax
f01003a7:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003a9:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003ac:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f01003b2:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01003b5:	0f b6 82 60 64 10 f0 	movzbl -0xfef9ba0(%edx),%eax
f01003bc:	0b 05 00 f0 22 f0    	or     0xf022f000,%eax
f01003c2:	0f b6 8a 60 63 10 f0 	movzbl -0xfef9ca0(%edx),%ecx
f01003c9:	31 c8                	xor    %ecx,%eax
f01003cb:	a3 00 f0 22 f0       	mov    %eax,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003d0:	89 c1                	mov    %eax,%ecx
f01003d2:	83 e1 03             	and    $0x3,%ecx
f01003d5:	8b 0c 8d 40 63 10 f0 	mov    -0xfef9cc0(,%ecx,4),%ecx
f01003dc:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003e0:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003e3:	a8 08                	test   $0x8,%al
f01003e5:	74 1b                	je     f0100402 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01003e7:	89 da                	mov    %ebx,%edx
f01003e9:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003ec:	83 f9 19             	cmp    $0x19,%ecx
f01003ef:	77 05                	ja     f01003f6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003f1:	83 eb 20             	sub    $0x20,%ebx
f01003f4:	eb 0c                	jmp    f0100402 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003f6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003f9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003fc:	83 fa 19             	cmp    $0x19,%edx
f01003ff:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100402:	f7 d0                	not    %eax
f0100404:	a8 06                	test   $0x6,%al
f0100406:	75 33                	jne    f010043b <kbd_proc_data+0x112>
f0100408:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010040e:	75 2b                	jne    f010043b <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100410:	83 ec 0c             	sub    $0xc,%esp
f0100413:	68 0c 63 10 f0       	push   $0xf010630c
f0100418:	e8 6b 34 00 00       	call   f0103888 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041d:	ba 92 00 00 00       	mov    $0x92,%edx
f0100422:	b8 03 00 00 00       	mov    $0x3,%eax
f0100427:	ee                   	out    %al,(%dx)
f0100428:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010042b:	89 d8                	mov    %ebx,%eax
f010042d:	eb 0e                	jmp    f010043d <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f010042f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100434:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100435:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010043a:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010043b:	89 d8                	mov    %ebx,%eax
}
f010043d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100440:	c9                   	leave  
f0100441:	c3                   	ret    

f0100442 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100442:	55                   	push   %ebp
f0100443:	89 e5                	mov    %esp,%ebp
f0100445:	57                   	push   %edi
f0100446:	56                   	push   %esi
f0100447:	53                   	push   %ebx
f0100448:	83 ec 1c             	sub    $0x1c,%esp
f010044b:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010044d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100452:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100457:	b9 84 00 00 00       	mov    $0x84,%ecx
f010045c:	eb 09                	jmp    f0100467 <cons_putc+0x25>
f010045e:	89 ca                	mov    %ecx,%edx
f0100460:	ec                   	in     (%dx),%al
f0100461:	ec                   	in     (%dx),%al
f0100462:	ec                   	in     (%dx),%al
f0100463:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100464:	83 c3 01             	add    $0x1,%ebx
f0100467:	89 f2                	mov    %esi,%edx
f0100469:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010046a:	a8 20                	test   $0x20,%al
f010046c:	75 08                	jne    f0100476 <cons_putc+0x34>
f010046e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100474:	7e e8                	jle    f010045e <cons_putc+0x1c>
f0100476:	89 f8                	mov    %edi,%eax
f0100478:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010047b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100480:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100481:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100486:	be 79 03 00 00       	mov    $0x379,%esi
f010048b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100490:	eb 09                	jmp    f010049b <cons_putc+0x59>
f0100492:	89 ca                	mov    %ecx,%edx
f0100494:	ec                   	in     (%dx),%al
f0100495:	ec                   	in     (%dx),%al
f0100496:	ec                   	in     (%dx),%al
f0100497:	ec                   	in     (%dx),%al
f0100498:	83 c3 01             	add    $0x1,%ebx
f010049b:	89 f2                	mov    %esi,%edx
f010049d:	ec                   	in     (%dx),%al
f010049e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01004a4:	7f 04                	jg     f01004aa <cons_putc+0x68>
f01004a6:	84 c0                	test   %al,%al
f01004a8:	79 e8                	jns    f0100492 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004aa:	ba 78 03 00 00       	mov    $0x378,%edx
f01004af:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01004b3:	ee                   	out    %al,(%dx)
f01004b4:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004b9:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004be:	ee                   	out    %al,(%dx)
f01004bf:	b8 08 00 00 00       	mov    $0x8,%eax
f01004c4:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004c5:	89 fa                	mov    %edi,%edx
f01004c7:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004cd:	89 f8                	mov    %edi,%eax
f01004cf:	80 cc 07             	or     $0x7,%ah
f01004d2:	85 d2                	test   %edx,%edx
f01004d4:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004d7:	89 f8                	mov    %edi,%eax
f01004d9:	0f b6 c0             	movzbl %al,%eax
f01004dc:	83 f8 09             	cmp    $0x9,%eax
f01004df:	74 78                	je     f0100559 <cons_putc+0x117>
f01004e1:	83 f8 09             	cmp    $0x9,%eax
f01004e4:	7f 0a                	jg     f01004f0 <cons_putc+0xae>
f01004e6:	83 f8 08             	cmp    $0x8,%eax
f01004e9:	74 14                	je     f01004ff <cons_putc+0xbd>
f01004eb:	e9 9d 00 00 00       	jmp    f010058d <cons_putc+0x14b>
f01004f0:	83 f8 0a             	cmp    $0xa,%eax
f01004f3:	74 3a                	je     f010052f <cons_putc+0xed>
f01004f5:	83 f8 0d             	cmp    $0xd,%eax
f01004f8:	74 3e                	je     f0100538 <cons_putc+0xf6>
f01004fa:	e9 8e 00 00 00       	jmp    f010058d <cons_putc+0x14b>
	case '\b':
		if (crt_pos > 0) {
f01004ff:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f0100506:	66 85 c0             	test   %ax,%ax
f0100509:	0f 84 eb 00 00 00    	je     f01005fa <cons_putc+0x1b8>
			crt_pos--;
f010050f:	83 e8 01             	sub    $0x1,%eax
f0100512:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100518:	0f b7 c0             	movzwl %ax,%eax
f010051b:	66 81 e7 00 ff       	and    $0xff00,%di
f0100520:	83 cf 20             	or     $0x20,%edi
f0100523:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f0100529:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052d:	eb 7c                	jmp    f01005ab <cons_putc+0x169>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010052f:	66 81 05 28 f2 22 f0 	addw   $0x8f,0xf022f228
f0100536:	8f 00 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100538:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f010053f:	69 c0 93 72 00 00    	imul   $0x7293,%eax,%eax
f0100545:	c1 e8 16             	shr    $0x16,%eax
f0100548:	8d 14 c0             	lea    (%eax,%eax,8),%edx
f010054b:	c1 e2 04             	shl    $0x4,%edx
f010054e:	29 c2                	sub    %eax,%edx
f0100550:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f0100557:	eb 52                	jmp    f01005ab <cons_putc+0x169>
		break;
	case '\t':
		cons_putc(' ');
f0100559:	b8 20 00 00 00       	mov    $0x20,%eax
f010055e:	e8 df fe ff ff       	call   f0100442 <cons_putc>
		cons_putc(' ');
f0100563:	b8 20 00 00 00       	mov    $0x20,%eax
f0100568:	e8 d5 fe ff ff       	call   f0100442 <cons_putc>
		cons_putc(' ');
f010056d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100572:	e8 cb fe ff ff       	call   f0100442 <cons_putc>
		cons_putc(' ');
f0100577:	b8 20 00 00 00       	mov    $0x20,%eax
f010057c:	e8 c1 fe ff ff       	call   f0100442 <cons_putc>
		cons_putc(' ');
f0100581:	b8 20 00 00 00       	mov    $0x20,%eax
f0100586:	e8 b7 fe ff ff       	call   f0100442 <cons_putc>
f010058b:	eb 1e                	jmp    f01005ab <cons_putc+0x169>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010058d:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f0100594:	8d 50 01             	lea    0x1(%eax),%edx
f0100597:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f010059e:	0f b7 c0             	movzwl %ax,%eax
f01005a1:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01005a7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005ab:	66 81 3d 28 f2 22 f0 	cmpw   $0x1804,0xf022f228
f01005b2:	04 18 
f01005b4:	76 44                	jbe    f01005fa <cons_putc+0x1b8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005b6:	a1 2c f2 22 f0       	mov    0xf022f22c,%eax
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	68 ec 2e 00 00       	push   $0x2eec
f01005c3:	8d 90 1e 01 00 00    	lea    0x11e(%eax),%edx
f01005c9:	52                   	push   %edx
f01005ca:	50                   	push   %eax
f01005cb:	e8 be 4f 00 00       	call   f010558e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005d0:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01005d6:	8d 82 ec 2e 00 00    	lea    0x2eec(%edx),%eax
f01005dc:	81 c2 0a 30 00 00    	add    $0x300a,%edx
f01005e2:	83 c4 10             	add    $0x10,%esp
f01005e5:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005ea:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005ed:	39 d0                	cmp    %edx,%eax
f01005ef:	75 f4                	jne    f01005e5 <cons_putc+0x1a3>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005f1:	66 81 2d 28 f2 22 f0 	subw   $0x8f,0xf022f228
f01005f8:	8f 00 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005fa:	8b 0d 30 f2 22 f0    	mov    0xf022f230,%ecx
f0100600:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100605:	89 ca                	mov    %ecx,%edx
f0100607:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100608:	0f b7 1d 28 f2 22 f0 	movzwl 0xf022f228,%ebx
f010060f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100612:	89 d8                	mov    %ebx,%eax
f0100614:	66 c1 e8 08          	shr    $0x8,%ax
f0100618:	89 f2                	mov    %esi,%edx
f010061a:	ee                   	out    %al,(%dx)
f010061b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100620:	89 ca                	mov    %ecx,%edx
f0100622:	ee                   	out    %al,(%dx)
f0100623:	89 d8                	mov    %ebx,%eax
f0100625:	89 f2                	mov    %esi,%edx
f0100627:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100628:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010062b:	5b                   	pop    %ebx
f010062c:	5e                   	pop    %esi
f010062d:	5f                   	pop    %edi
f010062e:	5d                   	pop    %ebp
f010062f:	c3                   	ret    

f0100630 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100630:	80 3d 34 f2 22 f0 00 	cmpb   $0x0,0xf022f234
f0100637:	74 11                	je     f010064a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100639:	55                   	push   %ebp
f010063a:	89 e5                	mov    %esp,%ebp
f010063c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010063f:	b8 c7 02 10 f0       	mov    $0xf01002c7,%eax
f0100644:	e8 9d fc ff ff       	call   f01002e6 <cons_intr>
}
f0100649:	c9                   	leave  
f010064a:	f3 c3                	repz ret 

f010064c <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010064c:	55                   	push   %ebp
f010064d:	89 e5                	mov    %esp,%ebp
f010064f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100652:	b8 29 03 10 f0       	mov    $0xf0100329,%eax
f0100657:	e8 8a fc ff ff       	call   f01002e6 <cons_intr>
}
f010065c:	c9                   	leave  
f010065d:	c3                   	ret    

f010065e <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010065e:	55                   	push   %ebp
f010065f:	89 e5                	mov    %esp,%ebp
f0100661:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100664:	e8 c7 ff ff ff       	call   f0100630 <serial_intr>
	kbd_intr();
f0100669:	e8 de ff ff ff       	call   f010064c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010066e:	a1 20 f2 22 f0       	mov    0xf022f220,%eax
f0100673:	3b 05 24 f2 22 f0    	cmp    0xf022f224,%eax
f0100679:	74 26                	je     f01006a1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010067b:	8d 50 01             	lea    0x1(%eax),%edx
f010067e:	89 15 20 f2 22 f0    	mov    %edx,0xf022f220
f0100684:	0f b6 88 20 f0 22 f0 	movzbl -0xfdd0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010068b:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010068d:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100693:	75 11                	jne    f01006a6 <cons_getc+0x48>
			cons.rpos = 0;
f0100695:	c7 05 20 f2 22 f0 00 	movl   $0x0,0xf022f220
f010069c:	00 00 00 
f010069f:	eb 05                	jmp    f01006a6 <cons_getc+0x48>
		return c;
	}
	return 0;
f01006a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01006a6:	c9                   	leave  
f01006a7:	c3                   	ret    

f01006a8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006a8:	55                   	push   %ebp
f01006a9:	89 e5                	mov    %esp,%ebp
f01006ab:	57                   	push   %edi
f01006ac:	56                   	push   %esi
f01006ad:	53                   	push   %ebx
f01006ae:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006b1:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006b8:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006bf:	5a a5 
	if (*cp != 0xA55A) {
f01006c1:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006c8:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006cc:	74 11                	je     f01006df <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006ce:	c7 05 30 f2 22 f0 b4 	movl   $0x3b4,0xf022f230
f01006d5:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006d8:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006dd:	eb 16                	jmp    f01006f5 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006df:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006e6:	c7 05 30 f2 22 f0 d4 	movl   $0x3d4,0xf022f230
f01006ed:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006f0:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006f5:	8b 3d 30 f2 22 f0    	mov    0xf022f230,%edi
f01006fb:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100700:	89 fa                	mov    %edi,%edx
f0100702:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100703:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100706:	89 da                	mov    %ebx,%edx
f0100708:	ec                   	in     (%dx),%al
f0100709:	0f b6 c8             	movzbl %al,%ecx
f010070c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100714:	89 fa                	mov    %edi,%edx
f0100716:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100717:	89 da                	mov    %ebx,%edx
f0100719:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010071a:	89 35 2c f2 22 f0    	mov    %esi,0xf022f22c
	crt_pos = pos;
f0100720:	0f b6 c0             	movzbl %al,%eax
f0100723:	09 c8                	or     %ecx,%eax
f0100725:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010072b:	e8 1c ff ff ff       	call   f010064c <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100730:	83 ec 0c             	sub    $0xc,%esp
f0100733:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010073a:	25 fd ff 00 00       	and    $0xfffd,%eax
f010073f:	50                   	push   %eax
f0100740:	e8 f2 2f 00 00       	call   f0103737 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100745:	be fa 03 00 00       	mov    $0x3fa,%esi
f010074a:	b8 00 00 00 00       	mov    $0x0,%eax
f010074f:	89 f2                	mov    %esi,%edx
f0100751:	ee                   	out    %al,(%dx)
f0100752:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100757:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010075c:	ee                   	out    %al,(%dx)
f010075d:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100762:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100767:	89 da                	mov    %ebx,%edx
f0100769:	ee                   	out    %al,(%dx)
f010076a:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010076f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100774:	ee                   	out    %al,(%dx)
f0100775:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010077a:	b8 03 00 00 00       	mov    $0x3,%eax
f010077f:	ee                   	out    %al,(%dx)
f0100780:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100785:	b8 00 00 00 00       	mov    $0x0,%eax
f010078a:	ee                   	out    %al,(%dx)
f010078b:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100790:	b8 01 00 00 00       	mov    $0x1,%eax
f0100795:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100796:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010079b:	ec                   	in     (%dx),%al
f010079c:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010079e:	83 c4 10             	add    $0x10,%esp
f01007a1:	3c ff                	cmp    $0xff,%al
f01007a3:	0f 95 05 34 f2 22 f0 	setne  0xf022f234
f01007aa:	89 f2                	mov    %esi,%edx
f01007ac:	ec                   	in     (%dx),%al
f01007ad:	89 da                	mov    %ebx,%edx
f01007af:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007b0:	80 f9 ff             	cmp    $0xff,%cl
f01007b3:	75 10                	jne    f01007c5 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f01007b5:	83 ec 0c             	sub    $0xc,%esp
f01007b8:	68 18 63 10 f0       	push   $0xf0106318
f01007bd:	e8 c6 30 00 00       	call   f0103888 <cprintf>
f01007c2:	83 c4 10             	add    $0x10,%esp
}
f01007c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007c8:	5b                   	pop    %ebx
f01007c9:	5e                   	pop    %esi
f01007ca:	5f                   	pop    %edi
f01007cb:	5d                   	pop    %ebp
f01007cc:	c3                   	ret    

f01007cd <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007cd:	55                   	push   %ebp
f01007ce:	89 e5                	mov    %esp,%ebp
f01007d0:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01007d6:	e8 67 fc ff ff       	call   f0100442 <cons_putc>
}
f01007db:	c9                   	leave  
f01007dc:	c3                   	ret    

f01007dd <getchar>:

int
getchar(void)
{
f01007dd:	55                   	push   %ebp
f01007de:	89 e5                	mov    %esp,%ebp
f01007e0:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007e3:	e8 76 fe ff ff       	call   f010065e <cons_getc>
f01007e8:	85 c0                	test   %eax,%eax
f01007ea:	74 f7                	je     f01007e3 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007ec:	c9                   	leave  
f01007ed:	c3                   	ret    

f01007ee <iscons>:

int
iscons(int fdnum)
{
f01007ee:	55                   	push   %ebp
f01007ef:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01007f6:	5d                   	pop    %ebp
f01007f7:	c3                   	ret    

f01007f8 <mon_quit>:

	}

	return 0x1001;
}
int mon_quit(int agrc,char **agrv,struct Trapframe *tf){
f01007f8:	55                   	push   %ebp
f01007f9:	89 e5                	mov    %esp,%ebp
	
	return -1;
}
f01007fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100800:	5d                   	pop    %ebp
f0100801:	c3                   	ret    

f0100802 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100802:	55                   	push   %ebp
f0100803:	89 e5                	mov    %esp,%ebp
f0100805:	56                   	push   %esi
f0100806:	53                   	push   %ebx
f0100807:	bb 60 68 10 f0       	mov    $0xf0106860,%ebx
f010080c:	be 90 68 10 f0       	mov    $0xf0106890,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100811:	83 ec 04             	sub    $0x4,%esp
f0100814:	ff 73 04             	pushl  0x4(%ebx)
f0100817:	ff 33                	pushl  (%ebx)
f0100819:	68 60 65 10 f0       	push   $0xf0106560
f010081e:	e8 65 30 00 00       	call   f0103888 <cprintf>
f0100823:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100826:	83 c4 10             	add    $0x10,%esp
f0100829:	39 f3                	cmp    %esi,%ebx
f010082b:	75 e4                	jne    f0100811 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f010082d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100832:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100835:	5b                   	pop    %ebx
f0100836:	5e                   	pop    %esi
f0100837:	5d                   	pop    %ebp
f0100838:	c3                   	ret    

f0100839 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100839:	55                   	push   %ebp
f010083a:	89 e5                	mov    %esp,%ebp
f010083c:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010083f:	68 69 65 10 f0       	push   $0xf0106569
f0100844:	e8 3f 30 00 00       	call   f0103888 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100849:	83 c4 08             	add    $0x8,%esp
f010084c:	68 0c 00 10 00       	push   $0x10000c
f0100851:	68 64 66 10 f0       	push   $0xf0106664
f0100856:	e8 2d 30 00 00       	call   f0103888 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010085b:	83 c4 0c             	add    $0xc,%esp
f010085e:	68 0c 00 10 00       	push   $0x10000c
f0100863:	68 0c 00 10 f0       	push   $0xf010000c
f0100868:	68 8c 66 10 f0       	push   $0xf010668c
f010086d:	e8 16 30 00 00       	call   f0103888 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100872:	83 c4 0c             	add    $0xc,%esp
f0100875:	68 e1 61 10 00       	push   $0x1061e1
f010087a:	68 e1 61 10 f0       	push   $0xf01061e1
f010087f:	68 b0 66 10 f0       	push   $0xf01066b0
f0100884:	e8 ff 2f 00 00       	call   f0103888 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100889:	83 c4 0c             	add    $0xc,%esp
f010088c:	68 10 e9 22 00       	push   $0x22e910
f0100891:	68 10 e9 22 f0       	push   $0xf022e910
f0100896:	68 d4 66 10 f0       	push   $0xf01066d4
f010089b:	e8 e8 2f 00 00       	call   f0103888 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008a0:	83 c4 0c             	add    $0xc,%esp
f01008a3:	68 08 10 27 00       	push   $0x271008
f01008a8:	68 08 10 27 f0       	push   $0xf0271008
f01008ad:	68 f8 66 10 f0       	push   $0xf01066f8
f01008b2:	e8 d1 2f 00 00       	call   f0103888 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008b7:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
f01008bc:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008c1:	83 c4 08             	add    $0x8,%esp
f01008c4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008c9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008cf:	85 c0                	test   %eax,%eax
f01008d1:	0f 48 c2             	cmovs  %edx,%eax
f01008d4:	c1 f8 0a             	sar    $0xa,%eax
f01008d7:	50                   	push   %eax
f01008d8:	68 1c 67 10 f0       	push   $0xf010671c
f01008dd:	e8 a6 2f 00 00       	call   f0103888 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e7:	c9                   	leave  
f01008e8:	c3                   	ret    

f01008e9 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008e9:	55                   	push   %ebp
f01008ea:	89 e5                	mov    %esp,%ebp
f01008ec:	57                   	push   %edi
f01008ed:	56                   	push   %esi
f01008ee:	53                   	push   %ebx
f01008ef:	83 ec 2c             	sub    $0x2c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008f2:	89 ea                	mov    %ebp,%edx
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
f01008f4:	89 d0                	mov    %edx,%eax
	int before_ebp = *(int*)esp_position;
f01008f6:	8b 32                	mov    (%edx),%esi
		int pra_5 = (int)*((int*)esp_position+6);
	
		cprintf("ebp:0x%8.0x eip:0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x\n",esp_position,eip,pra_1,pra_2,pra_3,pra_4,pra_5);
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f01008f8:	8d 7d d0             	lea    -0x30(%ebp),%edi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
	int before_ebp = *(int*)esp_position;
	while(before_ebp != 0){//here the ebp is 0,because the i386_init set it 0 before it comes into a real function
f01008fb:	eb 48                	jmp    f0100945 <mon_backtrace+0x5c>
		before_ebp = *(int*)esp_position;//read the ebp of the before stack
f01008fd:	8b 30                	mov    (%eax),%esi
		int eip = (int)*((int*)esp_position+1);
f01008ff:	8b 58 04             	mov    0x4(%eax),%ebx
		int pra_2 = (int)*((int*)esp_position+3);
		int pra_3 = (int)*((int*)esp_position+4);
		int pra_4 = (int)*((int*)esp_position+5);
		int pra_5 = (int)*((int*)esp_position+6);
	
		cprintf("ebp:0x%8.0x eip:0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x\n",esp_position,eip,pra_1,pra_2,pra_3,pra_4,pra_5);
f0100902:	ff 70 18             	pushl  0x18(%eax)
f0100905:	ff 70 14             	pushl  0x14(%eax)
f0100908:	ff 70 10             	pushl  0x10(%eax)
f010090b:	ff 70 0c             	pushl  0xc(%eax)
f010090e:	ff 70 08             	pushl  0x8(%eax)
f0100911:	53                   	push   %ebx
f0100912:	50                   	push   %eax
f0100913:	68 48 67 10 f0       	push   $0xf0106748
f0100918:	e8 6b 2f 00 00       	call   f0103888 <cprintf>
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f010091d:	83 c4 18             	add    $0x18,%esp
f0100920:	57                   	push   %edi
f0100921:	53                   	push   %ebx
f0100922:	e8 71 42 00 00       	call   f0104b98 <debuginfo_eip>
		cprintf("%s:%d   %s:%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip-info.eip_fn_addr);	
f0100927:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010092a:	89 1c 24             	mov    %ebx,(%esp)
f010092d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100930:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100933:	ff 75 d0             	pushl  -0x30(%ebp)
f0100936:	68 82 65 10 f0       	push   $0xf0106582
f010093b:	e8 48 2f 00 00       	call   f0103888 <cprintf>
f0100940:	83 c4 20             	add    $0x20,%esp

		//finally we can get the pra num of one function by info.
		esp_position = before_ebp;		
f0100943:	89 f0                	mov    %esi,%eax
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
	int before_ebp = *(int*)esp_position;
	while(before_ebp != 0){//here the ebp is 0,because the i386_init set it 0 before it comes into a real function
f0100945:	85 f6                	test   %esi,%esi
f0100947:	75 b4                	jne    f01008fd <mon_backtrace+0x14>
		esp_position = before_ebp;		

	}

	return 0x1001;
}
f0100949:	b8 01 10 00 00       	mov    $0x1001,%eax
f010094e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100951:	5b                   	pop    %ebx
f0100952:	5e                   	pop    %esi
f0100953:	5f                   	pop    %edi
f0100954:	5d                   	pop    %ebp
f0100955:	c3                   	ret    

f0100956 <mon_test>:
int mon_quit(int agrc,char **agrv,struct Trapframe *tf){
	
	return -1;
}
//just my own code for test ,delete please.
int mon_test(int argc,char **argv,int argc1,int argc2,int argc3,int argc4,struct Trapframe *tf){
f0100956:	55                   	push   %ebp
f0100957:	89 e5                	mov    %esp,%ebp
	return 1;
}
f0100959:	b8 01 00 00 00       	mov    $0x1,%eax
f010095e:	5d                   	pop    %ebp
f010095f:	c3                   	ret    

f0100960 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100960:	55                   	push   %ebp
f0100961:	89 e5                	mov    %esp,%ebp
f0100963:	57                   	push   %edi
f0100964:	56                   	push   %esi
f0100965:	53                   	push   %ebx
f0100966:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100969:	68 8c 67 10 f0       	push   $0xf010678c
f010096e:	e8 15 2f 00 00       	call   f0103888 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100973:	c7 04 24 b0 67 10 f0 	movl   $0xf01067b0,(%esp)
f010097a:	e8 09 2f 00 00       	call   f0103888 <cprintf>


	if (tf != NULL)
f010097f:	83 c4 10             	add    $0x10,%esp
f0100982:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100986:	74 0e                	je     f0100996 <monitor+0x36>
		print_trapframe(tf);
f0100988:	83 ec 0c             	sub    $0xc,%esp
f010098b:	ff 75 08             	pushl  0x8(%ebp)
f010098e:	e8 48 34 00 00       	call   f0103ddb <print_trapframe>
f0100993:	83 c4 10             	add    $0x10,%esp


	//my code here 
	cprintf("here show code of myself\n");
f0100996:	83 ec 0c             	sub    $0xc,%esp
f0100999:	68 91 65 10 f0       	push   $0xf0106591
f010099e:	e8 e5 2e 00 00       	call   f0103888 <cprintf>
	for(int i = 0;i<200;i++){
		cprintf("%d",i);
		cprintf("abcdefghijklmnopqrstuvwxyz0123456789");
	}
	*/
	cprintf("yourname is xuyongkang.");
f01009a3:	c7 04 24 ab 65 10 f0 	movl   $0xf01065ab,(%esp)
f01009aa:	e8 d9 2e 00 00       	call   f0103888 <cprintf>
	cprintf("\033[1m\033[45;33m HELLO_WORLD \033[0m\n");
f01009af:	c7 04 24 d8 67 10 f0 	movl   $0xf01067d8,(%esp)
f01009b6:	e8 cd 2e 00 00       	call   f0103888 <cprintf>
	cprintf("\a\n");
f01009bb:	c7 04 24 c3 65 10 f0 	movl   $0xf01065c3,(%esp)
f01009c2:	e8 c1 2e 00 00       	call   f0103888 <cprintf>
	cprintf("\a\n");
f01009c7:	c7 04 24 c3 65 10 f0 	movl   $0xf01065c3,(%esp)
f01009ce:	e8 b5 2e 00 00       	call   f0103888 <cprintf>
	int x = 1,y = 3,z = 4;
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009d3:	6a 04                	push   $0x4
f01009d5:	6a 03                	push   $0x3
f01009d7:	6a 01                	push   $0x1
f01009d9:	68 c6 65 10 f0       	push   $0xf01065c6
f01009de:	e8 a5 2e 00 00       	call   f0103888 <cprintf>
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009e3:	83 c4 20             	add    $0x20,%esp
f01009e6:	6a 04                	push   $0x4
f01009e8:	6a 03                	push   $0x3
f01009ea:	6a 01                	push   $0x1
f01009ec:	68 c6 65 10 f0       	push   $0xf01065c6
f01009f1:	e8 92 2e 00 00       	call   f0103888 <cprintf>
 	cprintf("x,y,x");
f01009f6:	c7 04 24 d6 65 10 f0 	movl   $0xf01065d6,(%esp)
f01009fd:	e8 86 2e 00 00       	call   f0103888 <cprintf>
f0100a02:	83 c4 10             	add    $0x10,%esp
       

	//my code end

	while (1) {
		buf = readline("K> ");
f0100a05:	83 ec 0c             	sub    $0xc,%esp
f0100a08:	68 dc 65 10 f0       	push   $0xf01065dc
f0100a0d:	e8 d8 48 00 00       	call   f01052ea <readline>
f0100a12:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a14:	83 c4 10             	add    $0x10,%esp
f0100a17:	85 c0                	test   %eax,%eax
f0100a19:	74 ea                	je     f0100a05 <monitor+0xa5>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a1b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a22:	be 00 00 00 00       	mov    $0x0,%esi
f0100a27:	eb 0a                	jmp    f0100a33 <monitor+0xd3>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a29:	c6 03 00             	movb   $0x0,(%ebx)
f0100a2c:	89 f7                	mov    %esi,%edi
f0100a2e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a31:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a33:	0f b6 03             	movzbl (%ebx),%eax
f0100a36:	84 c0                	test   %al,%al
f0100a38:	74 63                	je     f0100a9d <monitor+0x13d>
f0100a3a:	83 ec 08             	sub    $0x8,%esp
f0100a3d:	0f be c0             	movsbl %al,%eax
f0100a40:	50                   	push   %eax
f0100a41:	68 e0 65 10 f0       	push   $0xf01065e0
f0100a46:	e8 b9 4a 00 00       	call   f0105504 <strchr>
f0100a4b:	83 c4 10             	add    $0x10,%esp
f0100a4e:	85 c0                	test   %eax,%eax
f0100a50:	75 d7                	jne    f0100a29 <monitor+0xc9>
			*buf++ = 0;
		if (*buf == 0)
f0100a52:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a55:	74 46                	je     f0100a9d <monitor+0x13d>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a57:	83 fe 0f             	cmp    $0xf,%esi
f0100a5a:	75 14                	jne    f0100a70 <monitor+0x110>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a5c:	83 ec 08             	sub    $0x8,%esp
f0100a5f:	6a 10                	push   $0x10
f0100a61:	68 e5 65 10 f0       	push   $0xf01065e5
f0100a66:	e8 1d 2e 00 00       	call   f0103888 <cprintf>
f0100a6b:	83 c4 10             	add    $0x10,%esp
f0100a6e:	eb 95                	jmp    f0100a05 <monitor+0xa5>
			return 0;
		}
		argv[argc++] = buf;
f0100a70:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a73:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a77:	eb 03                	jmp    f0100a7c <monitor+0x11c>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a79:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a7c:	0f b6 03             	movzbl (%ebx),%eax
f0100a7f:	84 c0                	test   %al,%al
f0100a81:	74 ae                	je     f0100a31 <monitor+0xd1>
f0100a83:	83 ec 08             	sub    $0x8,%esp
f0100a86:	0f be c0             	movsbl %al,%eax
f0100a89:	50                   	push   %eax
f0100a8a:	68 e0 65 10 f0       	push   $0xf01065e0
f0100a8f:	e8 70 4a 00 00       	call   f0105504 <strchr>
f0100a94:	83 c4 10             	add    $0x10,%esp
f0100a97:	85 c0                	test   %eax,%eax
f0100a99:	74 de                	je     f0100a79 <monitor+0x119>
f0100a9b:	eb 94                	jmp    f0100a31 <monitor+0xd1>
			buf++;
	}
	argv[argc] = 0;
f0100a9d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100aa4:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100aa5:	85 f6                	test   %esi,%esi
f0100aa7:	0f 84 58 ff ff ff    	je     f0100a05 <monitor+0xa5>
f0100aad:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ab2:	83 ec 08             	sub    $0x8,%esp
f0100ab5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ab8:	ff 34 85 60 68 10 f0 	pushl  -0xfef97a0(,%eax,4)
f0100abf:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ac2:	e8 df 49 00 00       	call   f01054a6 <strcmp>
f0100ac7:	83 c4 10             	add    $0x10,%esp
f0100aca:	85 c0                	test   %eax,%eax
f0100acc:	75 21                	jne    f0100aef <monitor+0x18f>
			return commands[i].func(argc, argv, tf);
f0100ace:	83 ec 04             	sub    $0x4,%esp
f0100ad1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ad4:	ff 75 08             	pushl  0x8(%ebp)
f0100ad7:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ada:	52                   	push   %edx
f0100adb:	56                   	push   %esi
f0100adc:	ff 14 85 68 68 10 f0 	call   *-0xfef9798(,%eax,4)
	//my code end

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ae3:	83 c4 10             	add    $0x10,%esp
f0100ae6:	85 c0                	test   %eax,%eax
f0100ae8:	78 25                	js     f0100b0f <monitor+0x1af>
f0100aea:	e9 16 ff ff ff       	jmp    f0100a05 <monitor+0xa5>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100aef:	83 c3 01             	add    $0x1,%ebx
f0100af2:	83 fb 04             	cmp    $0x4,%ebx
f0100af5:	75 bb                	jne    f0100ab2 <monitor+0x152>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100af7:	83 ec 08             	sub    $0x8,%esp
f0100afa:	ff 75 a8             	pushl  -0x58(%ebp)
f0100afd:	68 02 66 10 f0       	push   $0xf0106602
f0100b02:	e8 81 2d 00 00       	call   f0103888 <cprintf>
f0100b07:	83 c4 10             	add    $0x10,%esp
f0100b0a:	e9 f6 fe ff ff       	jmp    f0100a05 <monitor+0xa5>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b12:	5b                   	pop    %ebx
f0100b13:	5e                   	pop    %esi
f0100b14:	5f                   	pop    %edi
f0100b15:	5d                   	pop    %ebp
f0100b16:	c3                   	ret    

f0100b17 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b17:	55                   	push   %ebp
f0100b18:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b1a:	83 3d 38 f2 22 f0 00 	cmpl   $0x0,0xf022f238
f0100b21:	75 11                	jne    f0100b34 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b23:	ba 07 20 27 f0       	mov    $0xf0272007,%edx
f0100b28:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b2e:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	if(n>0){
		result = nextfree;
		nextfree = ROUNDUP(nextfree+n,PGSIZE);
		return result;
	}else{
		return nextfree;
f0100b34:	8b 15 38 f2 22 f0    	mov    0xf022f238,%edx
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n>0){
f0100b3a:	85 c0                	test   %eax,%eax
f0100b3c:	74 11                	je     f0100b4f <boot_alloc+0x38>
		result = nextfree;
		nextfree = ROUNDUP(nextfree+n,PGSIZE);
f0100b3e:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b4a:	a3 38 f2 22 f0       	mov    %eax,0xf022f238
		return result;
	}else{
		return nextfree;
	}
	return NULL;
}
f0100b4f:	89 d0                	mov    %edx,%eax
f0100b51:	5d                   	pop    %ebp
f0100b52:	c3                   	ret    

f0100b53 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b53:	55                   	push   %ebp
f0100b54:	89 e5                	mov    %esp,%ebp
f0100b56:	56                   	push   %esi
f0100b57:	53                   	push   %ebx
f0100b58:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b5a:	83 ec 0c             	sub    $0xc,%esp
f0100b5d:	50                   	push   %eax
f0100b5e:	e8 a6 2b 00 00       	call   f0103709 <mc146818_read>
f0100b63:	89 c6                	mov    %eax,%esi
f0100b65:	83 c3 01             	add    $0x1,%ebx
f0100b68:	89 1c 24             	mov    %ebx,(%esp)
f0100b6b:	e8 99 2b 00 00       	call   f0103709 <mc146818_read>
f0100b70:	c1 e0 08             	shl    $0x8,%eax
f0100b73:	09 f0                	or     %esi,%eax
}
f0100b75:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b78:	5b                   	pop    %ebx
f0100b79:	5e                   	pop    %esi
f0100b7a:	5d                   	pop    %ebp
f0100b7b:	c3                   	ret    

f0100b7c <check_va2pa>:
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
//	cprintf("	*pgdir: 0x%x\n",*pgdir);
	if (!(*pgdir & PTE_P))
f0100b7c:	89 d1                	mov    %edx,%ecx
f0100b7e:	c1 e9 16             	shr    $0x16,%ecx
f0100b81:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b84:	a8 01                	test   $0x1,%al
f0100b86:	74 52                	je     f0100bda <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b8d:	89 c1                	mov    %eax,%ecx
f0100b8f:	c1 e9 0c             	shr    $0xc,%ecx
f0100b92:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0100b98:	72 1b                	jb     f0100bb5 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b9a:	55                   	push   %ebp
f0100b9b:	89 e5                	mov    %esp,%ebp
f0100b9d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ba0:	50                   	push   %eax
f0100ba1:	68 c4 62 10 f0       	push   $0xf01062c4
f0100ba6:	68 45 05 00 00       	push   $0x545
f0100bab:	68 21 72 10 f0       	push   $0xf0107221
f0100bb0:	e8 df f4 ff ff       	call   f0100094 <_panic>
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
//	cprintf("	PTX(va):%x\n",PTX(va));
//	cprintf("	p[PTX(va)]:0x%x\n",p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100bb5:	c1 ea 0c             	shr    $0xc,%edx
f0100bb8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bbe:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bc5:	89 c2                	mov    %eax,%edx
f0100bc7:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bcf:	85 d2                	test   %edx,%edx
f0100bd1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bd6:	0f 44 c2             	cmove  %edx,%eax
f0100bd9:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
//	cprintf("	*pgdir: 0x%x\n",*pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
//	cprintf("	PTX(va):%x\n",PTX(va));
//	cprintf("	p[PTX(va)]:0x%x\n",p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bdf:	c3                   	ret    

f0100be0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100be0:	55                   	push   %ebp
f0100be1:	89 e5                	mov    %esp,%ebp
f0100be3:	57                   	push   %edi
f0100be4:	56                   	push   %esi
f0100be5:	53                   	push   %ebx
f0100be6:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be9:	84 c0                	test   %al,%al
f0100beb:	0f 85 9d 02 00 00    	jne    f0100e8e <check_page_free_list+0x2ae>
f0100bf1:	e9 aa 02 00 00       	jmp    f0100ea0 <check_page_free_list+0x2c0>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100bf6:	83 ec 04             	sub    $0x4,%esp
f0100bf9:	68 90 68 10 f0       	push   $0xf0106890
f0100bfe:	68 47 04 00 00       	push   $0x447
f0100c03:	68 21 72 10 f0       	push   $0xf0107221
f0100c08:	e8 87 f4 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c0d:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c10:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c13:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c19:	89 c2                	mov    %eax,%edx
f0100c1b:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0100c21:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c27:	0f 95 c2             	setne  %dl
f0100c2a:	0f b6 d2             	movzbl %dl,%edx
			//cprintf("page2pa(pp):%x\n",page2pa(pp));
			//cprintf("PDX(page2pa(pp)):%x\n",PDX(page2pa(pp)));
			//cprintf("pagetype:%x\n",pagetype);
			*tp[pagetype] = pp;
f0100c2d:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c31:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c33:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c37:	8b 00                	mov    (%eax),%eax
f0100c39:	85 c0                	test   %eax,%eax
f0100c3b:	75 dc                	jne    f0100c19 <check_page_free_list+0x39>
			//cprintf("PDX(page2pa(pp)):%x\n",PDX(page2pa(pp)));
			//cprintf("pagetype:%x\n",pagetype);
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c46:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c49:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c4c:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c51:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c56:	be 01 00 00 00       	mov    $0x1,%esi
//		cprintf("pp1 next :%x\n",pp1->pp_link);
	}
//	cprintf("here after the only_low_memory\n");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c5b:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100c61:	eb 50                	jmp    f0100cb3 <check_page_free_list+0xd3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c63:	89 d8                	mov    %ebx,%eax
f0100c65:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100c6b:	c1 f8 03             	sar    $0x3,%eax
f0100c6e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit){
f0100c71:	89 c2                	mov    %eax,%edx
f0100c73:	c1 ea 16             	shr    $0x16,%edx
f0100c76:	39 f2                	cmp    %esi,%edx
f0100c78:	73 37                	jae    f0100cb1 <check_page_free_list+0xd1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c7a:	89 c2                	mov    %eax,%edx
f0100c7c:	c1 ea 0c             	shr    $0xc,%edx
f0100c7f:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100c85:	72 12                	jb     f0100c99 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c87:	50                   	push   %eax
f0100c88:	68 c4 62 10 f0       	push   $0xf01062c4
f0100c8d:	6a 58                	push   $0x58
f0100c8f:	68 2d 72 10 f0       	push   $0xf010722d
f0100c94:	e8 fb f3 ff ff       	call   f0100094 <_panic>
			//cprintf("PageInfo.size():%x\n",sizeof(struct PageInfo));

			//:/cprintf("#check_page_free_list:page2kva(pp):%x\n",page2kva(pp));
			memset(page2kva(pp), 0x00, 128);
f0100c99:	83 ec 04             	sub    $0x4,%esp
f0100c9c:	68 80 00 00 00       	push   $0x80
f0100ca1:	6a 00                	push   $0x0
f0100ca3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ca8:	50                   	push   %eax
f0100ca9:	e8 93 48 00 00       	call   f0105541 <memset>
f0100cae:	83 c4 10             	add    $0x10,%esp
//		cprintf("pp1 next :%x\n",pp1->pp_link);
	}
//	cprintf("here after the only_low_memory\n");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cb1:	8b 1b                	mov    (%ebx),%ebx
f0100cb3:	85 db                	test   %ebx,%ebx
f0100cb5:	75 ac                	jne    f0100c63 <check_page_free_list+0x83>
		}else{
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
f0100cb7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cbc:	e8 56 fe ff ff       	call   f0100b17 <boot_alloc>
f0100cc1:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cc4:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cca:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
		assert(pp < pages + npages);
f0100cd0:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0100cd5:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100cd8:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cdb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cde:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ce1:	be 00 00 00 00       	mov    $0x0,%esi
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ce6:	e9 52 01 00 00       	jmp    f0100e3d <check_page_free_list+0x25d>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ceb:	39 ca                	cmp    %ecx,%edx
f0100ced:	73 19                	jae    f0100d08 <check_page_free_list+0x128>
f0100cef:	68 3b 72 10 f0       	push   $0xf010723b
f0100cf4:	68 47 72 10 f0       	push   $0xf0107247
f0100cf9:	68 6e 04 00 00       	push   $0x46e
f0100cfe:	68 21 72 10 f0       	push   $0xf0107221
f0100d03:	e8 8c f3 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100d08:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d0b:	72 19                	jb     f0100d26 <check_page_free_list+0x146>
f0100d0d:	68 5c 72 10 f0       	push   $0xf010725c
f0100d12:	68 47 72 10 f0       	push   $0xf0107247
f0100d17:	68 6f 04 00 00       	push   $0x46f
f0100d1c:	68 21 72 10 f0       	push   $0xf0107221
f0100d21:	e8 6e f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d26:	89 d0                	mov    %edx,%eax
f0100d28:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d2b:	a8 07                	test   $0x7,%al
f0100d2d:	74 19                	je     f0100d48 <check_page_free_list+0x168>
f0100d2f:	68 b4 68 10 f0       	push   $0xf01068b4
f0100d34:	68 47 72 10 f0       	push   $0xf0107247
f0100d39:	68 70 04 00 00       	push   $0x470
f0100d3e:	68 21 72 10 f0       	push   $0xf0107221
f0100d43:	e8 4c f3 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d48:	c1 f8 03             	sar    $0x3,%eax
f0100d4b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		//my code:
		//cprintf("pp:%x,page2pa(pp):%x\n",pp,page2pa(pp));
		//my code end.
		assert(page2pa(pp) != 0);
f0100d4e:	85 c0                	test   %eax,%eax
f0100d50:	75 19                	jne    f0100d6b <check_page_free_list+0x18b>
f0100d52:	68 70 72 10 f0       	push   $0xf0107270
f0100d57:	68 47 72 10 f0       	push   $0xf0107247
f0100d5c:	68 76 04 00 00       	push   $0x476
f0100d61:	68 21 72 10 f0       	push   $0xf0107221
f0100d66:	e8 29 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d6b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d70:	75 19                	jne    f0100d8b <check_page_free_list+0x1ab>
f0100d72:	68 81 72 10 f0       	push   $0xf0107281
f0100d77:	68 47 72 10 f0       	push   $0xf0107247
f0100d7c:	68 77 04 00 00       	push   $0x477
f0100d81:	68 21 72 10 f0       	push   $0xf0107221
f0100d86:	e8 09 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d90:	75 19                	jne    f0100dab <check_page_free_list+0x1cb>
f0100d92:	68 e8 68 10 f0       	push   $0xf01068e8
f0100d97:	68 47 72 10 f0       	push   $0xf0107247
f0100d9c:	68 78 04 00 00       	push   $0x478
f0100da1:	68 21 72 10 f0       	push   $0xf0107221
f0100da6:	e8 e9 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dab:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100db0:	75 19                	jne    f0100dcb <check_page_free_list+0x1eb>
f0100db2:	68 9a 72 10 f0       	push   $0xf010729a
f0100db7:	68 47 72 10 f0       	push   $0xf0107247
f0100dbc:	68 79 04 00 00       	push   $0x479
f0100dc1:	68 21 72 10 f0       	push   $0xf0107221
f0100dc6:	e8 c9 f2 ff ff       	call   f0100094 <_panic>
		//cprintf("pp'address:%x,page2kva(pp):%x\n",pp,page2kva(pp));
		//cprintf("first_free_page:%x\n",first_free_page);
		//assert( (char *)page2kva(pp) >= first_free_page );
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dcb:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dd0:	0f 86 f1 00 00 00    	jbe    f0100ec7 <check_page_free_list+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dd6:	89 c7                	mov    %eax,%edi
f0100dd8:	c1 ef 0c             	shr    $0xc,%edi
f0100ddb:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100dde:	77 12                	ja     f0100df2 <check_page_free_list+0x212>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100de0:	50                   	push   %eax
f0100de1:	68 c4 62 10 f0       	push   $0xf01062c4
f0100de6:	6a 58                	push   $0x58
f0100de8:	68 2d 72 10 f0       	push   $0xf010722d
f0100ded:	e8 a2 f2 ff ff       	call   f0100094 <_panic>
f0100df2:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100df8:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100dfb:	0f 86 b6 00 00 00    	jbe    f0100eb7 <check_page_free_list+0x2d7>
f0100e01:	68 0c 69 10 f0       	push   $0xf010690c
f0100e06:	68 47 72 10 f0       	push   $0xf0107247
f0100e0b:	68 7d 04 00 00       	push   $0x47d
f0100e10:	68 21 72 10 f0       	push   $0xf0107221
f0100e15:	e8 7a f2 ff ff       	call   f0100094 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e1a:	68 b4 72 10 f0       	push   $0xf01072b4
f0100e1f:	68 47 72 10 f0       	push   $0xf0107247
f0100e24:	68 7f 04 00 00       	push   $0x47f
f0100e29:	68 21 72 10 f0       	push   $0xf0107221
f0100e2e:	e8 61 f2 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e33:	83 c6 01             	add    $0x1,%esi
f0100e36:	eb 03                	jmp    f0100e3b <check_page_free_list+0x25b>
		else
			++nfree_extmem;
f0100e38:	83 c3 01             	add    $0x1,%ebx
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e3b:	8b 12                	mov    (%edx),%edx
f0100e3d:	85 d2                	test   %edx,%edx
f0100e3f:	0f 85 a6 fe ff ff    	jne    f0100ceb <check_page_free_list+0x10b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e45:	85 f6                	test   %esi,%esi
f0100e47:	7f 19                	jg     f0100e62 <check_page_free_list+0x282>
f0100e49:	68 d1 72 10 f0       	push   $0xf01072d1
f0100e4e:	68 47 72 10 f0       	push   $0xf0107247
f0100e53:	68 87 04 00 00       	push   $0x487
f0100e58:	68 21 72 10 f0       	push   $0xf0107221
f0100e5d:	e8 32 f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100e62:	85 db                	test   %ebx,%ebx
f0100e64:	7f 19                	jg     f0100e7f <check_page_free_list+0x29f>
f0100e66:	68 e3 72 10 f0       	push   $0xf01072e3
f0100e6b:	68 47 72 10 f0       	push   $0xf0107247
f0100e70:	68 88 04 00 00       	push   $0x488
f0100e75:	68 21 72 10 f0       	push   $0xf0107221
f0100e7a:	e8 15 f2 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e7f:	83 ec 0c             	sub    $0xc,%esp
f0100e82:	68 54 69 10 f0       	push   $0xf0106954
f0100e87:	e8 fc 29 00 00       	call   f0103888 <cprintf>
}
f0100e8c:	eb 49                	jmp    f0100ed7 <check_page_free_list+0x2f7>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e8e:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0100e93:	85 c0                	test   %eax,%eax
f0100e95:	0f 85 72 fd ff ff    	jne    f0100c0d <check_page_free_list+0x2d>
f0100e9b:	e9 56 fd ff ff       	jmp    f0100bf6 <check_page_free_list+0x16>
f0100ea0:	83 3d 40 f2 22 f0 00 	cmpl   $0x0,0xf022f240
f0100ea7:	0f 84 49 fd ff ff    	je     f0100bf6 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ead:	be 00 04 00 00       	mov    $0x400,%esi
f0100eb2:	e9 a4 fd ff ff       	jmp    f0100c5b <check_page_free_list+0x7b>
		//cprintf("pp'address:%x,page2kva(pp):%x\n",pp,page2kva(pp));
		//cprintf("first_free_page:%x\n",first_free_page);
		//assert( (char *)page2kva(pp) >= first_free_page );
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100eb7:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ebc:	0f 85 76 ff ff ff    	jne    f0100e38 <check_page_free_list+0x258>
f0100ec2:	e9 53 ff ff ff       	jmp    f0100e1a <check_page_free_list+0x23a>
f0100ec7:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ecc:	0f 85 61 ff ff ff    	jne    f0100e33 <check_page_free_list+0x253>
f0100ed2:	e9 43 ff ff ff       	jmp    f0100e1a <check_page_free_list+0x23a>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100ed7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eda:	5b                   	pop    %ebx
f0100edb:	5e                   	pop    %esi
f0100edc:	5f                   	pop    %edi
f0100edd:	5d                   	pop    %ebp
f0100ede:	c3                   	ret    

f0100edf <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100edf:	55                   	push   %ebp
f0100ee0:	89 e5                	mov    %esp,%ebp
f0100ee2:	56                   	push   %esi
f0100ee3:	53                   	push   %ebx
	}
*/

//=======
     size_t i;
     pages[0].pp_ref = 1;
f0100ee4:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100ee9:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
     pages[0].pp_link = NULL;
f0100eef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
f0100ef5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100efa:	e8 18 fc ff ff       	call   f0100b17 <boot_alloc>
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
     {
         if (( (i >= (IOPHYSMEM / PGSIZE)) && (i < ((nextfree - KERNBASE)/ PGSIZE))) || i == (MPENTRY_PADDR/PGSIZE)) 
f0100eff:	05 00 00 00 10       	add    $0x10000000,%eax
f0100f04:	c1 e8 0c             	shr    $0xc,%eax
f0100f07:	8b 35 40 f2 22 f0    	mov    0xf022f240,%esi
     pages[0].pp_link = NULL;
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
f0100f0d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f12:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f17:	eb 4f                	jmp    f0100f68 <page_init+0x89>
     {
         if (( (i >= (IOPHYSMEM / PGSIZE)) && (i < ((nextfree - KERNBASE)/ PGSIZE))) || i == (MPENTRY_PADDR/PGSIZE)) 
f0100f19:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f0100f1f:	76 04                	jbe    f0100f25 <page_init+0x46>
f0100f21:	39 c2                	cmp    %eax,%edx
f0100f23:	72 05                	jb     f0100f2a <page_init+0x4b>
f0100f25:	83 fa 07             	cmp    $0x7,%edx
f0100f28:	75 17                	jne    f0100f41 <page_init+0x62>
         {
             pages[i].pp_ref = 1;
f0100f2a:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
f0100f30:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f0100f33:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
             pages[i].pp_link = NULL;
f0100f39:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100f3f:	eb 24                	jmp    f0100f65 <page_init+0x86>
         }
         else 
         {
             pages[i].pp_ref = 0;
f0100f41:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100f48:	89 cb                	mov    %ecx,%ebx
f0100f4a:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx
f0100f50:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
             pages[i].pp_link = page_free_list;
f0100f56:	89 33                	mov    %esi,(%ebx)
             page_free_list = &pages[i];
f0100f58:	89 ce                	mov    %ecx,%esi
f0100f5a:	03 35 90 fe 22 f0    	add    0xf022fe90,%esi
f0100f60:	bb 01 00 00 00       	mov    $0x1,%ebx
     pages[0].pp_link = NULL;
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
f0100f65:	83 c2 01             	add    $0x1,%edx
f0100f68:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100f6e:	72 a9                	jb     f0100f19 <page_init+0x3a>
f0100f70:	84 db                	test   %bl,%bl
f0100f72:	74 06                	je     f0100f7a <page_init+0x9b>
f0100f74:	89 35 40 f2 22 f0    	mov    %esi,0xf022f240
             page_free_list = &pages[i];
        }
     }

//>>>>>>> lab3
}
f0100f7a:	5b                   	pop    %ebx
f0100f7b:	5e                   	pop    %esi
f0100f7c:	5d                   	pop    %ebp
f0100f7d:	c3                   	ret    

f0100f7e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f7e:	55                   	push   %ebp
f0100f7f:	89 e5                	mov    %esp,%ebp
f0100f81:	53                   	push   %ebx
f0100f82:	83 ec 04             	sub    $0x4,%esp
f0100f85:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
	//my code start
	//first check is there any pages left

	//here we delete the page in the page_free_list but used by others.e.g.pp2
//cprintf("$$now we are at the page_alloc() function.$$\n\n");
	while( page_free_list && page_free_list->pp_ref > 0 ){
f0100f8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f90:	eb 07                	jmp    f0100f99 <page_alloc+0x1b>
		page_free_list = page_free_list->pp_link;
f0100f92:	8b 1b                	mov    (%ebx),%ebx
f0100f94:	b8 01 00 00 00       	mov    $0x1,%eax
	//my code start
	//first check is there any pages left

	//here we delete the page in the page_free_list but used by others.e.g.pp2
//cprintf("$$now we are at the page_alloc() function.$$\n\n");
	while( page_free_list && page_free_list->pp_ref > 0 ){
f0100f99:	85 db                	test   %ebx,%ebx
f0100f9b:	75 14                	jne    f0100fb1 <page_alloc+0x33>
f0100f9d:	84 c0                	test   %al,%al
f0100f9f:	0f 84 8b 00 00 00    	je     f0101030 <page_alloc+0xb2>
f0100fa5:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0100fac:	00 00 00 
f0100faf:	eb 7f                	jmp    f0101030 <page_alloc+0xb2>
f0100fb1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100fb6:	75 da                	jne    f0100f92 <page_alloc+0x14>
f0100fb8:	84 c0                	test   %al,%al
f0100fba:	74 06                	je     f0100fc2 <page_alloc+0x44>
f0100fbc:	89 1d 40 f2 22 f0    	mov    %ebx,0xf022f240
//cprintf("#497 alloc_error:we don't consider the condition that only one node left.\n");
//cprintf("page_free_list->pp_ref:0x%x,pp_link:0x%x\n\n\n",page_free_list->pp_ref,page_free_list->pp_link);			
		struct PageInfo * return_PageInfo = NULL;
		return_PageInfo = page_free_list;
		
		if(page_free_list->pp_link == NULL){
f0100fc2:	8b 03                	mov    (%ebx),%eax
f0100fc4:	85 c0                	test   %eax,%eax
f0100fc6:	75 12                	jne    f0100fda <page_alloc+0x5c>
			page_free_list = NULL;
f0100fc8:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0100fcf:	00 00 00 
			return_PageInfo->pp_link = NULL;
f0100fd2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
f0100fd8:	eb 0b                	jmp    f0100fe5 <page_alloc+0x67>
		}else{
			page_free_list = return_PageInfo->pp_link;
f0100fda:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
			return_PageInfo->pp_link = NULL;	
f0100fdf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
		
		if(alloc_flags & ALLOC_ZERO){
f0100fe5:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fe9:	74 45                	je     f0101030 <page_alloc+0xb2>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100feb:	89 d8                	mov    %ebx,%eax
f0100fed:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100ff3:	c1 f8 03             	sar    $0x3,%eax
f0100ff6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff9:	89 c2                	mov    %eax,%edx
f0100ffb:	c1 ea 0c             	shr    $0xc,%edx
f0100ffe:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101004:	72 12                	jb     f0101018 <page_alloc+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101006:	50                   	push   %eax
f0101007:	68 c4 62 10 f0       	push   $0xf01062c4
f010100c:	6a 58                	push   $0x58
f010100e:	68 2d 72 10 f0       	push   $0xf010722d
f0101013:	e8 7c f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(return_PageInfo),'\0',PGSIZE);
f0101018:	83 ec 04             	sub    $0x4,%esp
f010101b:	68 00 10 00 00       	push   $0x1000
f0101020:	6a 00                	push   $0x0
f0101022:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101027:	50                   	push   %eax
f0101028:	e8 14 45 00 00       	call   f0105541 <memset>
f010102d:	83 c4 10             	add    $0x10,%esp
//		panic("page_alloc():alloc failed.\n");
		return NULL;
	}
	//my code end.
	return 0;
}
f0101030:	89 d8                	mov    %ebx,%eax
f0101032:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101035:	c9                   	leave  
f0101036:	c3                   	ret    

f0101037 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101037:	55                   	push   %ebp
f0101038:	89 e5                	mov    %esp,%ebp
f010103a:	53                   	push   %ebx
f010103b:	83 ec 04             	sub    $0x4,%esp
f010103e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link != NULL){
f0101041:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101046:	75 05                	jne    f010104d <page_free+0x16>
f0101048:	83 3b 00             	cmpl   $0x0,(%ebx)
f010104b:	74 17                	je     f0101064 <page_free+0x2d>
		
		panic("page_free():page free failed.\n");
f010104d:	83 ec 04             	sub    $0x4,%esp
f0101050:	68 78 69 10 f0       	push   $0xf0106978
f0101055:	68 ff 01 00 00       	push   $0x1ff
f010105a:	68 21 72 10 f0       	push   $0xf0107221
f010105f:	e8 30 f0 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101064:	89 d8                	mov    %ebx,%eax
f0101066:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010106c:	c1 f8 03             	sar    $0x3,%eax
f010106f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101072:	89 c2                	mov    %eax,%edx
f0101074:	c1 ea 0c             	shr    $0xc,%edx
f0101077:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f010107d:	72 12                	jb     f0101091 <page_free+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107f:	50                   	push   %eax
f0101080:	68 c4 62 10 f0       	push   $0xf01062c4
f0101085:	6a 58                	push   $0x58
f0101087:	68 2d 72 10 f0       	push   $0xf010722d
f010108c:	e8 03 f0 ff ff       	call   f0100094 <_panic>
//			cprintf("$$in the page_free:page_free_list->pp_ref :%x$$\n\n",page_free_list->pp_ref);	
			
			//here we should do something additional,that is clear 
			//the freed page,set the value to 0;
			
			memset((page2kva(pp)),0x00,PGSIZE);
f0101091:	83 ec 04             	sub    $0x4,%esp
f0101094:	68 00 10 00 00       	push   $0x1000
f0101099:	6a 00                	push   $0x0
f010109b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010a0:	50                   	push   %eax
f01010a1:	e8 9b 44 00 00       	call   f0105541 <memset>
f01010a6:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
			
			while(page_free_list && page_free_list->pp_ref >0){
f01010ab:	83 c4 10             	add    $0x10,%esp
f01010ae:	ba 00 00 00 00       	mov    $0x0,%edx
f01010b3:	eb 07                	jmp    f01010bc <page_free+0x85>
				page_free_list = page_free_list->pp_link;
f01010b5:	8b 00                	mov    (%eax),%eax
f01010b7:	ba 01 00 00 00       	mov    $0x1,%edx
			//here we should do something additional,that is clear 
			//the freed page,set the value to 0;
			
			memset((page2kva(pp)),0x00,PGSIZE);
			
			while(page_free_list && page_free_list->pp_ref >0){
f01010bc:	85 c0                	test   %eax,%eax
f01010be:	75 10                	jne    f01010d0 <page_free+0x99>
f01010c0:	84 d2                	test   %dl,%dl
f01010c2:	74 1c                	je     f01010e0 <page_free+0xa9>
f01010c4:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f01010cb:	00 00 00 
f01010ce:	eb 10                	jmp    f01010e0 <page_free+0xa9>
f01010d0:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010d5:	75 de                	jne    f01010b5 <page_free+0x7e>
f01010d7:	84 d2                	test   %dl,%dl
f01010d9:	74 05                	je     f01010e0 <page_free+0xa9>
f01010db:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
				page_free_list = page_free_list->pp_link;
			}
			if(pp != page_free_list){
f01010e0:	39 c3                	cmp    %eax,%ebx
f01010e2:	74 08                	je     f01010ec <page_free+0xb5>
				struct PageInfo * temp_free_page_list = page_free_list;
				page_free_list = pp;
f01010e4:	89 1d 40 f2 22 f0    	mov    %ebx,0xf022f240
				page_free_list->pp_link = temp_free_page_list;
f01010ea:	89 03                	mov    %eax,(%ebx)
			}
		return;

	}
	
}
f01010ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010ef:	c9                   	leave  
f01010f0:	c3                   	ret    

f01010f1 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01010f1:	55                   	push   %ebp
f01010f2:	89 e5                	mov    %esp,%ebp
f01010f4:	83 ec 08             	sub    $0x8,%esp
f01010f7:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010fa:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010fe:	83 e8 01             	sub    $0x1,%eax
f0101101:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101105:	66 85 c0             	test   %ax,%ax
f0101108:	75 0c                	jne    f0101116 <page_decref+0x25>
		page_free(pp);
f010110a:	83 ec 0c             	sub    $0xc,%esp
f010110d:	52                   	push   %edx
f010110e:	e8 24 ff ff ff       	call   f0101037 <page_free>
f0101113:	83 c4 10             	add    $0x10,%esp
}
f0101116:	c9                   	leave  
f0101117:	c3                   	ret    

f0101118 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101118:	55                   	push   %ebp
f0101119:	89 e5                	mov    %esp,%ebp
f010111b:	56                   	push   %esi
f010111c:	53                   	push   %ebx
f010111d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//a new page table table if there is not a page table page exist.

const void* out_va = va;
//if( (uint32_t)out_va&0xf0000000 && !((uint32_t)out_va&0x0ffffff) )
//cprintf("va :%x\n",va);
	if( pgdir[PDX(va)] == 0 ){//memset has already set it to zero?
f0101120:	89 de                	mov    %ebx,%esi
f0101122:	c1 ee 16             	shr    $0x16,%esi
f0101125:	c1 e6 02             	shl    $0x2,%esi
f0101128:	03 75 08             	add    0x8(%ebp),%esi
f010112b:	8b 06                	mov    (%esi),%eax
f010112d:	85 c0                	test   %eax,%eax
f010112f:	75 74                	jne    f01011a5 <pgdir_walk+0x8d>
		if(create == 0)
f0101131:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101135:	0f 84 a3 00 00 00    	je     f01011de <pgdir_walk+0xc6>
			return NULL;
		else{
			struct PageInfo * return_page = page_alloc(0);
f010113b:	83 ec 0c             	sub    $0xc,%esp
f010113e:	6a 00                	push   $0x0
f0101140:	e8 39 fe ff ff       	call   f0100f7e <page_alloc>
//cprintf(" we are at the page_allloc to check #497\n");
//cprintf("the mapped va is:%x\n",va);
			//return_page->pp_ref++;
			if(return_page == NULL){//run out of memery
f0101145:	83 c4 10             	add    $0x10,%esp
f0101148:	85 c0                	test   %eax,%eax
f010114a:	0f 84 95 00 00 00    	je     f01011e5 <pgdir_walk+0xcd>
				return NULL;
			}else{
//				cprintf("#page_walk in the if  else(new alloc)\n");
//				cprintf("#page_walk return_page :%x\n",return_page);
//				cprintf("#page_walk page2pa(return_page):%x\n",page2pa(return_page));
				return_page->pp_ref++;
f0101150:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				//this line can make the
				//the line assert(ptep == ptep1+PTX(va))
				//pass in the check_page();
				pgdir[PDX(va)] = page2pa(return_page);	
f0101155:	89 c2                	mov    %eax,%edx
f0101157:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f010115d:	c1 fa 03             	sar    $0x3,%edx
f0101160:	c1 e2 0c             	shl    $0xc,%edx
f0101163:	89 16                	mov    %edx,(%esi)
//cprintf("from the else exit.\n\n");
				return (pte_t*)(KADDR(PTE_ADDR(page2pa(return_page))))+PTX(va);
f0101165:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010116b:	c1 f8 03             	sar    $0x3,%eax
f010116e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101171:	89 c2                	mov    %eax,%edx
f0101173:	c1 ea 0c             	shr    $0xc,%edx
f0101176:	39 15 88 fe 22 f0    	cmp    %edx,0xf022fe88
f010117c:	77 15                	ja     f0101193 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010117e:	50                   	push   %eax
f010117f:	68 c4 62 10 f0       	push   $0xf01062c4
f0101184:	68 71 02 00 00       	push   $0x271
f0101189:	68 21 72 10 f0       	push   $0xf0107221
f010118e:	e8 01 ef ff ff       	call   f0100094 <_panic>
f0101193:	c1 eb 0a             	shr    $0xa,%ebx
f0101196:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010119c:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01011a3:	eb 45                	jmp    f01011ea <pgdir_walk+0xd2>
			}
		}	
	}else{
		//cprintf("B");
		//cprintf("the page_walk else:0x%x\n",pgdir[PDX(va)]);
		return (pte_t*)(KADDR(PTE_ADDR(pgdir[PDX(va)])))+PTX(va);
f01011a5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011aa:	89 c2                	mov    %eax,%edx
f01011ac:	c1 ea 0c             	shr    $0xc,%edx
f01011af:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01011b5:	72 15                	jb     f01011cc <pgdir_walk+0xb4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011b7:	50                   	push   %eax
f01011b8:	68 c4 62 10 f0       	push   $0xf01062c4
f01011bd:	68 79 02 00 00       	push   $0x279
f01011c2:	68 21 72 10 f0       	push   $0xf0107221
f01011c7:	e8 c8 ee ff ff       	call   f0100094 <_panic>
f01011cc:	c1 eb 0a             	shr    $0xa,%ebx
f01011cf:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01011d5:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01011dc:	eb 0c                	jmp    f01011ea <pgdir_walk+0xd2>
const void* out_va = va;
//if( (uint32_t)out_va&0xf0000000 && !((uint32_t)out_va&0x0ffffff) )
//cprintf("va :%x\n",va);
	if( pgdir[PDX(va)] == 0 ){//memset has already set it to zero?
		if(create == 0)
			return NULL;
f01011de:	b8 00 00 00 00       	mov    $0x0,%eax
f01011e3:	eb 05                	jmp    f01011ea <pgdir_walk+0xd2>
//cprintf(" we are at the page_allloc to check #497\n");
//cprintf("the mapped va is:%x\n",va);
			//return_page->pp_ref++;
			if(return_page == NULL){//run out of memery
//cprintf("from the NULL exit.\n\n");
				return NULL;
f01011e5:	b8 00 00 00 00       	mov    $0x0,%eax


	//my code end.

	return NULL;
}
f01011ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011ed:	5b                   	pop    %ebx
f01011ee:	5e                   	pop    %esi
f01011ef:	5d                   	pop    %ebp
f01011f0:	c3                   	ret    

f01011f1 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011f1:	55                   	push   %ebp
f01011f2:	89 e5                	mov    %esp,%ebp
f01011f4:	57                   	push   %edi
f01011f5:	56                   	push   %esi
f01011f6:	53                   	push   %ebx
f01011f7:	83 ec 1c             	sub    $0x1c,%esp
f01011fa:	89 c7                	mov    %eax,%edi
//			cprintf("*returned_page_table:%x\n",*returned_page_table);

//		}

		*returned_page_table = ((temp_pa))|perm|PTE_P;
		if(temp_va == va+ROUNDUP(size,PGSIZE)-PGSIZE){
f01011fc:	8d 5c 0a ff          	lea    -0x1(%edx,%ecx,1),%ebx
f0101200:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0101206:	25 ff 0f 00 00       	and    $0xfff,%eax
f010120b:	29 c3                	sub    %eax,%ebx
f010120d:	89 5d d8             	mov    %ebx,-0x28(%ebp)
	pde_t * returned_page_table;

	//pgdir_walk(pgdir,va,1);
	uintptr_t temp_va;
	physaddr_t temp_pa;
	for(temp_va = va,temp_pa = pa;temp_va<va+size;temp_va+=PGSIZE,temp_pa+=PGSIZE){
f0101210:	89 d3                	mov    %edx,%ebx
f0101212:	8b 45 08             	mov    0x8(%ebp),%eax
f0101215:	29 d0                	sub    %edx,%eax
f0101217:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010121a:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f010121d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101220:	eb 56                	jmp    f0101278 <boot_map_region+0x87>
	/* here we should use a new mapping way because we should finish it in static
		
		//the third version is below.
		
	*/
		returned_page_table = pgdir_walk(pgdir,(void*)temp_va,1);
f0101222:	83 ec 04             	sub    $0x4,%esp
f0101225:	6a 01                	push   $0x1
f0101227:	53                   	push   %ebx
f0101228:	57                   	push   %edi
f0101229:	e8 ea fe ff ff       	call   f0101118 <pgdir_walk>
//cprintf("A");
//cprintf("w");
		pgdir[PDX(temp_va)] = PADDR((void*)((uint32_t)(returned_page_table)|perm|PTE_P));
f010122e:	89 da                	mov    %ebx,%edx
f0101230:	c1 ea 16             	shr    $0x16,%edx
f0101233:	8d 34 97             	lea    (%edi,%edx,4),%esi
f0101236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101239:	83 c9 01             	or     $0x1,%ecx
f010123c:	89 c2                	mov    %eax,%edx
f010123e:	09 ca                	or     %ecx,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101240:	83 c4 10             	add    $0x10,%esp
f0101243:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0101249:	77 15                	ja     f0101260 <boot_map_region+0x6f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010124b:	52                   	push   %edx
f010124c:	68 e8 62 10 f0       	push   $0xf01062e8
f0101251:	68 a8 02 00 00       	push   $0x2a8
f0101256:	68 21 72 10 f0       	push   $0xf0107221
f010125b:	e8 34 ee ff ff       	call   f0100094 <_panic>
f0101260:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101266:	89 16                	mov    %edx,(%esi)
//			cprintf("returned_page_table:%x\n",returned_page_table);
//			cprintf("*returned_page_table:%x\n",*returned_page_table);

//		}

		*returned_page_table = ((temp_pa))|perm|PTE_P;
f0101268:	0b 4d e4             	or     -0x1c(%ebp),%ecx
f010126b:	89 08                	mov    %ecx,(%eax)
		if(temp_va == va+ROUNDUP(size,PGSIZE)-PGSIZE){
f010126d:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0101270:	74 13                	je     f0101285 <boot_map_region+0x94>
	pde_t * returned_page_table;

	//pgdir_walk(pgdir,va,1);
	uintptr_t temp_va;
	physaddr_t temp_pa;
	for(temp_va = va,temp_pa = pa;temp_va<va+size;temp_va+=PGSIZE,temp_pa+=PGSIZE){
f0101272:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101278:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010127b:	01 d8                	add    %ebx,%eax
f010127d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101280:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0101283:	72 9d                	jb     f0101222 <boot_map_region+0x31>
//cprintf("for test temp_va:%x temp_pa:%x\n",temp_va,temp_pa);
	}	
	
	//my code end
//cprintf("now we get out of boot_map_region\n\n\n");
}
f0101285:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101288:	5b                   	pop    %ebx
f0101289:	5e                   	pop    %esi
f010128a:	5f                   	pop    %edi
f010128b:	5d                   	pop    %ebp
f010128c:	c3                   	ret    

f010128d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010128d:	55                   	push   %ebp
f010128e:	89 e5                	mov    %esp,%ebp
f0101290:	53                   	push   %ebx
f0101291:	83 ec 08             	sub    $0x8,%esp
f0101294:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	//my second time code
	//page_remove(pgdir,va);
	pte_t*p = NULL;
	if((p = pgdir_walk(pgdir,va,0)) == NULL){
f0101297:	6a 00                	push   $0x0
f0101299:	ff 75 0c             	pushl  0xc(%ebp)
f010129c:	ff 75 08             	pushl  0x8(%ebp)
f010129f:	e8 74 fe ff ff       	call   f0101118 <pgdir_walk>
f01012a4:	83 c4 10             	add    $0x10,%esp
f01012a7:	85 c0                	test   %eax,%eax
f01012a9:	74 36                	je     f01012e1 <page_lookup+0x54>
//		cprintf("#page_lookup:in NULL chose.\n");
		return NULL;	
	}else{
//		cprintf("#page_lookup:in else.\n");
		if(pte_store != NULL){
f01012ab:	85 db                	test   %ebx,%ebx
f01012ad:	74 02                	je     f01012b1 <page_lookup+0x24>
			*pte_store = (p);		
f01012af:	89 03                	mov    %eax,(%ebx)
		}
//		//pte_t  inner_p = PTE_ADDR((pte_t)p);
//		cprintf("the address of va is:0x%x\n",va);
//		cprintf("the PTX(va):0x%x\n",PTX(va));
//cprintf("### in page_lookup: 10.3 %x\n",*p);
		if((void*)(*p) == NULL){
f01012b1:	8b 00                	mov    (%eax),%eax
f01012b3:	85 c0                	test   %eax,%eax
f01012b5:	74 31                	je     f01012e8 <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b7:	c1 e8 0c             	shr    $0xc,%eax
f01012ba:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01012c0:	72 14                	jb     f01012d6 <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f01012c2:	83 ec 04             	sub    $0x4,%esp
f01012c5:	68 98 69 10 f0       	push   $0xf0106998
f01012ca:	6a 51                	push   $0x51
f01012cc:	68 2d 72 10 f0       	push   $0xf010722d
f01012d1:	e8 be ed ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f01012d6:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f01012dc:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}else{
//			cprintf("#page_lookup in the else else 0x%x\n",p);
		//	cprintf("#page lookup in the else else 0x%x\n",p[PTX(va)]) ;


			return pa2page( *p );
f01012df:	eb 0c                	jmp    f01012ed <page_lookup+0x60>
	//my second time code
	//page_remove(pgdir,va);
	pte_t*p = NULL;
	if((p = pgdir_walk(pgdir,va,0)) == NULL){
//		cprintf("#page_lookup:in NULL chose.\n");
		return NULL;	
f01012e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e6:	eb 05                	jmp    f01012ed <page_lookup+0x60>
//		cprintf("the address of va is:0x%x\n",va);
//		cprintf("the PTX(va):0x%x\n",PTX(va));
//cprintf("### in page_lookup: 10.3 %x\n",*p);
		if((void*)(*p) == NULL){
	
			return NULL;
f01012e8:	b8 00 00 00 00       	mov    $0x0,%eax
		return NULL;
	}
	return NULL;
	*/

}
f01012ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012f0:	c9                   	leave  
f01012f1:	c3                   	ret    

f01012f2 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012f2:	55                   	push   %ebp
f01012f3:	89 e5                	mov    %esp,%ebp
f01012f5:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012f8:	e8 65 48 00 00       	call   f0105b62 <cpunum>
f01012fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0101300:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0101307:	74 16                	je     f010131f <tlb_invalidate+0x2d>
f0101309:	e8 54 48 00 00       	call   f0105b62 <cpunum>
f010130e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101311:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0101317:	8b 55 08             	mov    0x8(%ebp),%edx
f010131a:	39 50 60             	cmp    %edx,0x60(%eax)
f010131d:	75 06                	jne    f0101325 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010131f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101322:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101325:	c9                   	leave  
f0101326:	c3                   	ret    

f0101327 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101327:	55                   	push   %ebp
f0101328:	89 e5                	mov    %esp,%ebp
f010132a:	56                   	push   %esi
f010132b:	53                   	push   %ebx
f010132c:	83 ec 14             	sub    $0x14,%esp
f010132f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101332:	8b 75 0c             	mov    0xc(%ebp),%esi
	//address space the TLB will be preload the concerned 
	//page table entrys so we invalidate it first...(maybe)
	//but I still do not know when to use it clearly.
	pde_t * temp_pte;
	struct PageInfo * page_to_free;
	page_to_free = page_lookup(pgdir,va,&temp_pte);
f0101335:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101338:	50                   	push   %eax
f0101339:	56                   	push   %esi
f010133a:	53                   	push   %ebx
f010133b:	e8 4d ff ff ff       	call   f010128d <page_lookup>
	
	if(page_to_free != NULL){
f0101340:	83 c4 10             	add    $0x10,%esp
f0101343:	85 c0                	test   %eax,%eax
f0101345:	74 1f                	je     f0101366 <page_remove+0x3f>
	//we should handle the page returned.
		page_decref(page_to_free);	
f0101347:	83 ec 0c             	sub    $0xc,%esp
f010134a:	50                   	push   %eax
f010134b:	e8 a1 fd ff ff       	call   f01010f1 <page_decref>
		tlb_invalidate(pgdir,va);
f0101350:	83 c4 08             	add    $0x8,%esp
f0101353:	56                   	push   %esi
f0101354:	53                   	push   %ebx
f0101355:	e8 98 ff ff ff       	call   f01012f2 <tlb_invalidate>
		//now we remove the entry in page table
		//I don't know 
	//	temp_pte = (pte_t*)(PTE_ADDR(temp_pte));
		//change pa to va so that we can use temp_pte[]
		*temp_pte = 0;
f010135a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010135d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101363:	83 c4 10             	add    $0x10,%esp
	}else{
		//do nothing.
	}
	return;
	//my code end
}
f0101366:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101369:	5b                   	pop    %ebx
f010136a:	5e                   	pop    %esi
f010136b:	5d                   	pop    %ebp
f010136c:	c3                   	ret    

f010136d <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010136d:	55                   	push   %ebp
f010136e:	89 e5                	mov    %esp,%ebp
f0101370:	57                   	push   %edi
f0101371:	56                   	push   %esi
f0101372:	53                   	push   %ebx
f0101373:	83 ec 14             	sub    $0x14,%esp
f0101376:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101379:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	//my code start here
	pde_t * returned_page_table_entry;
	struct PageInfo * returned_page_table_entry_page;
//cprintf("#### before remove page_free_list:%x\n",page_free_list);
	page_remove(pgdir,va);
f010137c:	53                   	push   %ebx
f010137d:	ff 75 08             	pushl  0x8(%ebp)
f0101380:	e8 a2 ff ff ff       	call   f0101327 <page_remove>
//cprintf("#### after remove page_free_list:%x\n",page_free_list);
	//if it is not mapped,page_remove() do nothing.
	returned_page_table_entry = pgdir_walk(pgdir,va,1);
f0101385:	83 c4 0c             	add    $0xc,%esp
f0101388:	6a 01                	push   $0x1
f010138a:	53                   	push   %ebx
f010138b:	ff 75 08             	pushl  0x8(%ebp)
f010138e:	e8 85 fd ff ff       	call   f0101118 <pgdir_walk>
	*/
//	cprintf("the pp is:%x\n",pp);	
//	cprintf("the page2pa(pp) is:%x\n",page2pa(pp));
//	cprintf("the returned_page_table_entry:%x\n",returned_page_table_entry);	

	if(returned_page_table_entry != NULL){
f0101393:	83 c4 10             	add    $0x10,%esp
f0101396:	85 c0                	test   %eax,%eax
f0101398:	74 73                	je     f010140d <page_insert+0xa0>
f010139a:	89 c7                	mov    %eax,%edi
		

		//we have already insert the right side of the equation in
		// the pgdir[PDX(va)] in the pgdir_walk(),but we do it again 
		//here to insert the permission
		pgdir[PDX(va)] = PADDR((void*)((uint32_t)(returned_page_table_entry)|perm|PTE_P));
f010139c:	c1 eb 16             	shr    $0x16,%ebx
f010139f:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a2:	8d 14 98             	lea    (%eax,%ebx,4),%edx
f01013a5:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01013a8:	83 cb 01             	or     $0x1,%ebx
f01013ab:	89 f8                	mov    %edi,%eax
f01013ad:	09 d8                	or     %ebx,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013af:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013b4:	77 15                	ja     f01013cb <page_insert+0x5e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013b6:	50                   	push   %eax
f01013b7:	68 e8 62 10 f0       	push   $0xf01062e8
f01013bc:	68 f1 02 00 00       	push   $0x2f1
f01013c1:	68 21 72 10 f0       	push   $0xf0107221
f01013c6:	e8 c9 ec ff ff       	call   f0100094 <_panic>
f01013cb:	05 00 00 00 10       	add    $0x10000000,%eax
f01013d0:	89 02                	mov    %eax,(%edx)
			//PTE_ADDR(page2pa(returned_page_table_table_entry)));
//		cprintf("in the return is not NULL before\n");
//		cprintf("PTX(va):%d\n",PTX(va));
//		cprintf("the va address:%x\n",va);
//		cprintf("the returned_page_table_entry:%x\n",returned_page_table_entry);
		cprintf("pp:%x\n",pp);
f01013d2:	83 ec 08             	sub    $0x8,%esp
f01013d5:	56                   	push   %esi
f01013d6:	68 f4 72 10 f0       	push   $0xf01072f4
f01013db:	e8 a8 24 00 00       	call   f0103888 <cprintf>
		*returned_page_table_entry = (page2pa(pp))|perm|PTE_P;
f01013e0:	89 f0                	mov    %esi,%eax
f01013e2:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01013e8:	c1 f8 03             	sar    $0x3,%eax
f01013eb:	c1 e0 0c             	shl    $0xc,%eax
f01013ee:	09 c3                	or     %eax,%ebx
f01013f0:	89 1f                	mov    %ebx,(%edi)
		cprintf("after we set page_table_entry\n");
f01013f2:	c7 04 24 b8 69 10 f0 	movl   $0xf01069b8,(%esp)
f01013f9:	e8 8a 24 00 00       	call   f0103888 <cprintf>
		//NOTE. 

	
//cprintf("after KADDR:%x\n",((pde_t*)((pde_t)returned_page_table_entry))[PTX(va)] );

		pp->pp_ref++;
f01013fe:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
//		cprintf("page2pa(pp)|perm|PTE_P:%x\n",page2pa(pp)|perm|PTE_P);	
		//how do you know the 'va' has phy page mapped
		//use function page_lookup.	
		//pgdir_walk();->page_alloc();
		//page_remove();
		return 0;	
f0101403:	83 c4 10             	add    $0x10,%esp
f0101406:	b8 00 00 00 00       	mov    $0x0,%eax
f010140b:	eb 05                	jmp    f0101412 <page_insert+0xa5>
	}else{
//		cprintf("E_NO_MEM%d\n",-E_NO_MEM);
		return -E_NO_MEM;
f010140d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
}
f0101412:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101415:	5b                   	pop    %ebx
f0101416:	5e                   	pop    %esi
f0101417:	5f                   	pop    %edi
f0101418:	5d                   	pop    %ebp
f0101419:	c3                   	ret    

f010141a <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010141a:	55                   	push   %ebp
f010141b:	89 e5                	mov    %esp,%ebp
f010141d:	53                   	push   %ebx
f010141e:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t total_size = ROUNDUP(size,PGSIZE);
f0101421:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101424:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010142a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(MMIOBASE+total_size>MMIOLIM){
f0101430:	8d 83 00 00 80 ef    	lea    -0x10800000(%ebx),%eax
f0101436:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010143b:	76 17                	jbe    f0101454 <mmio_map_region+0x3a>
		panic("panic at mmio_map_region.\n");
f010143d:	83 ec 04             	sub    $0x4,%esp
f0101440:	68 fb 72 10 f0       	push   $0xf01072fb
f0101445:	68 cb 03 00 00       	push   $0x3cb
f010144a:	68 21 72 10 f0       	push   $0xf0107221
f010144f:	e8 40 ec ff ff       	call   f0100094 <_panic>
	}else{
		boot_map_region(kern_pgdir,base,total_size,pa,PTE_W|PTE_PCD|PTE_PWT);
f0101454:	83 ec 08             	sub    $0x8,%esp
f0101457:	6a 1a                	push   $0x1a
f0101459:	ff 75 08             	pushl  0x8(%ebp)
f010145c:	89 d9                	mov    %ebx,%ecx
f010145e:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101464:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101469:	e8 83 fd ff ff       	call   f01011f1 <boot_map_region>
	}
	base+=total_size;
f010146e:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101473:	01 c3                	add    %eax,%ebx
f0101475:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void *)base-total_size;
}
f010147b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010147e:	c9                   	leave  
f010147f:	c3                   	ret    

f0101480 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101480:	55                   	push   %ebp
f0101481:	89 e5                	mov    %esp,%ebp
f0101483:	57                   	push   %edi
f0101484:	56                   	push   %esi
f0101485:	53                   	push   %ebx
f0101486:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101489:	b8 15 00 00 00       	mov    $0x15,%eax
f010148e:	e8 c0 f6 ff ff       	call   f0100b53 <nvram_read>
f0101493:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101495:	b8 17 00 00 00       	mov    $0x17,%eax
f010149a:	e8 b4 f6 ff ff       	call   f0100b53 <nvram_read>
f010149f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014a1:	b8 34 00 00 00       	mov    $0x34,%eax
f01014a6:	e8 a8 f6 ff ff       	call   f0100b53 <nvram_read>
f01014ab:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014ae:	85 c0                	test   %eax,%eax
f01014b0:	74 07                	je     f01014b9 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01014b2:	05 00 40 00 00       	add    $0x4000,%eax
f01014b7:	eb 0b                	jmp    f01014c4 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01014b9:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014bf:	85 f6                	test   %esi,%esi
f01014c1:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014c4:	89 c2                	mov    %eax,%edx
f01014c6:	c1 ea 02             	shr    $0x2,%edx
f01014c9:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014cf:	89 c2                	mov    %eax,%edx
f01014d1:	29 da                	sub    %ebx,%edx
f01014d3:	52                   	push   %edx
f01014d4:	53                   	push   %ebx
f01014d5:	50                   	push   %eax
f01014d6:	68 d8 69 10 f0       	push   $0xf01069d8
f01014db:	e8 a8 23 00 00       	call   f0103888 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014e0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014e5:	e8 2d f6 ff ff       	call   f0100b17 <boot_alloc>
f01014ea:	a3 8c fe 22 f0       	mov    %eax,0xf022fe8c
	memset(kern_pgdir, 0, PGSIZE);
f01014ef:	83 c4 0c             	add    $0xc,%esp
f01014f2:	68 00 10 00 00       	push   $0x1000
f01014f7:	6a 00                	push   $0x0
f01014f9:	50                   	push   %eax
f01014fa:	e8 42 40 00 00       	call   f0105541 <memset>
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014ff:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101504:	83 c4 10             	add    $0x10,%esp
f0101507:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010150c:	77 15                	ja     f0101523 <mem_init+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010150e:	50                   	push   %eax
f010150f:	68 e8 62 10 f0       	push   $0xf01062e8
f0101514:	68 9f 00 00 00       	push   $0x9f
f0101519:	68 21 72 10 f0       	push   $0xf0107221
f010151e:	e8 71 eb ff ff       	call   f0100094 <_panic>
f0101523:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101529:	83 ca 05             	or     $0x5,%edx
f010152c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pde_t * page_root = (pde_t*)boot_alloc(sizeof(struct PageInfo)*npages); 	
f0101532:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0101537:	c1 e0 03             	shl    $0x3,%eax
f010153a:	e8 d8 f5 ff ff       	call   f0100b17 <boot_alloc>
f010153f:	89 c3                	mov    %eax,%ebx
	memset(page_root, 0, (sizeof(struct PageInfo)*npages));
f0101541:	83 ec 04             	sub    $0x4,%esp
f0101544:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0101549:	c1 e0 03             	shl    $0x3,%eax
f010154c:	50                   	push   %eax
f010154d:	6a 00                	push   $0x0
f010154f:	53                   	push   %ebx
f0101550:	e8 ec 3f 00 00       	call   f0105541 <memset>

        pages = (struct PageInfo*)page_root;
f0101555:	89 1d 90 fe 22 f0    	mov    %ebx,0xf022fe90

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));	
f010155b:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101560:	e8 b2 f5 ff ff       	call   f0100b17 <boot_alloc>
f0101565:	a3 44 f2 22 f0       	mov    %eax,0xf022f244
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010156a:	e8 70 f9 ff ff       	call   f0100edf <page_init>

	check_page_free_list(1);
f010156f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101574:	e8 67 f6 ff ff       	call   f0100be0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101579:	83 c4 10             	add    $0x10,%esp
f010157c:	83 3d 90 fe 22 f0 00 	cmpl   $0x0,0xf022fe90
f0101583:	75 17                	jne    f010159c <mem_init+0x11c>
		panic("'pages' is a null pointer!");
f0101585:	83 ec 04             	sub    $0x4,%esp
f0101588:	68 16 73 10 f0       	push   $0xf0107316
f010158d:	68 9b 04 00 00       	push   $0x49b
f0101592:	68 21 72 10 f0       	push   $0xf0107221
f0101597:	e8 f8 ea ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010159c:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01015a1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015a6:	eb 05                	jmp    f01015ad <mem_init+0x12d>
		++nfree;
f01015a8:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015ab:	8b 00                	mov    (%eax),%eax
f01015ad:	85 c0                	test   %eax,%eax
f01015af:	75 f7                	jne    f01015a8 <mem_init+0x128>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015b1:	83 ec 0c             	sub    $0xc,%esp
f01015b4:	6a 00                	push   $0x0
f01015b6:	e8 c3 f9 ff ff       	call   f0100f7e <page_alloc>
f01015bb:	89 c7                	mov    %eax,%edi
f01015bd:	83 c4 10             	add    $0x10,%esp
f01015c0:	85 c0                	test   %eax,%eax
f01015c2:	75 19                	jne    f01015dd <mem_init+0x15d>
f01015c4:	68 31 73 10 f0       	push   $0xf0107331
f01015c9:	68 47 72 10 f0       	push   $0xf0107247
f01015ce:	68 a3 04 00 00       	push   $0x4a3
f01015d3:	68 21 72 10 f0       	push   $0xf0107221
f01015d8:	e8 b7 ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01015dd:	83 ec 0c             	sub    $0xc,%esp
f01015e0:	6a 00                	push   $0x0
f01015e2:	e8 97 f9 ff ff       	call   f0100f7e <page_alloc>
f01015e7:	89 c6                	mov    %eax,%esi
f01015e9:	83 c4 10             	add    $0x10,%esp
f01015ec:	85 c0                	test   %eax,%eax
f01015ee:	75 19                	jne    f0101609 <mem_init+0x189>
f01015f0:	68 47 73 10 f0       	push   $0xf0107347
f01015f5:	68 47 72 10 f0       	push   $0xf0107247
f01015fa:	68 a4 04 00 00       	push   $0x4a4
f01015ff:	68 21 72 10 f0       	push   $0xf0107221
f0101604:	e8 8b ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101609:	83 ec 0c             	sub    $0xc,%esp
f010160c:	6a 00                	push   $0x0
f010160e:	e8 6b f9 ff ff       	call   f0100f7e <page_alloc>
f0101613:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101616:	83 c4 10             	add    $0x10,%esp
f0101619:	85 c0                	test   %eax,%eax
f010161b:	75 19                	jne    f0101636 <mem_init+0x1b6>
f010161d:	68 5d 73 10 f0       	push   $0xf010735d
f0101622:	68 47 72 10 f0       	push   $0xf0107247
f0101627:	68 a5 04 00 00       	push   $0x4a5
f010162c:	68 21 72 10 f0       	push   $0xf0107221
f0101631:	e8 5e ea ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1033.\n");	


	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101636:	39 f7                	cmp    %esi,%edi
f0101638:	75 19                	jne    f0101653 <mem_init+0x1d3>
f010163a:	68 73 73 10 f0       	push   $0xf0107373
f010163f:	68 47 72 10 f0       	push   $0xf0107247
f0101644:	68 ab 04 00 00       	push   $0x4ab
f0101649:	68 21 72 10 f0       	push   $0xf0107221
f010164e:	e8 41 ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101653:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101656:	39 c6                	cmp    %eax,%esi
f0101658:	74 04                	je     f010165e <mem_init+0x1de>
f010165a:	39 c7                	cmp    %eax,%edi
f010165c:	75 19                	jne    f0101677 <mem_init+0x1f7>
f010165e:	68 14 6a 10 f0       	push   $0xf0106a14
f0101663:	68 47 72 10 f0       	push   $0xf0107247
f0101668:	68 ac 04 00 00       	push   $0x4ac
f010166d:	68 21 72 10 f0       	push   $0xf0107221
f0101672:	e8 1d ea ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101677:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010167d:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f0101683:	c1 e2 0c             	shl    $0xc,%edx
f0101686:	89 f8                	mov    %edi,%eax
f0101688:	29 c8                	sub    %ecx,%eax
f010168a:	c1 f8 03             	sar    $0x3,%eax
f010168d:	c1 e0 0c             	shl    $0xc,%eax
f0101690:	39 d0                	cmp    %edx,%eax
f0101692:	72 19                	jb     f01016ad <mem_init+0x22d>
f0101694:	68 85 73 10 f0       	push   $0xf0107385
f0101699:	68 47 72 10 f0       	push   $0xf0107247
f010169e:	68 ad 04 00 00       	push   $0x4ad
f01016a3:	68 21 72 10 f0       	push   $0xf0107221
f01016a8:	e8 e7 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016ad:	89 f0                	mov    %esi,%eax
f01016af:	29 c8                	sub    %ecx,%eax
f01016b1:	c1 f8 03             	sar    $0x3,%eax
f01016b4:	c1 e0 0c             	shl    $0xc,%eax
f01016b7:	39 c2                	cmp    %eax,%edx
f01016b9:	77 19                	ja     f01016d4 <mem_init+0x254>
f01016bb:	68 a2 73 10 f0       	push   $0xf01073a2
f01016c0:	68 47 72 10 f0       	push   $0xf0107247
f01016c5:	68 ae 04 00 00       	push   $0x4ae
f01016ca:	68 21 72 10 f0       	push   $0xf0107221
f01016cf:	e8 c0 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016d7:	29 c8                	sub    %ecx,%eax
f01016d9:	c1 f8 03             	sar    $0x3,%eax
f01016dc:	c1 e0 0c             	shl    $0xc,%eax
f01016df:	39 c2                	cmp    %eax,%edx
f01016e1:	77 19                	ja     f01016fc <mem_init+0x27c>
f01016e3:	68 bf 73 10 f0       	push   $0xf01073bf
f01016e8:	68 47 72 10 f0       	push   $0xf0107247
f01016ed:	68 af 04 00 00       	push   $0x4af
f01016f2:	68 21 72 10 f0       	push   $0xf0107221
f01016f7:	e8 98 e9 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016fc:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101701:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101704:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f010170b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010170e:	83 ec 0c             	sub    $0xc,%esp
f0101711:	6a 00                	push   $0x0
f0101713:	e8 66 f8 ff ff       	call   f0100f7e <page_alloc>
f0101718:	83 c4 10             	add    $0x10,%esp
f010171b:	85 c0                	test   %eax,%eax
f010171d:	74 19                	je     f0101738 <mem_init+0x2b8>
f010171f:	68 dc 73 10 f0       	push   $0xf01073dc
f0101724:	68 47 72 10 f0       	push   $0xf0107247
f0101729:	68 b6 04 00 00       	push   $0x4b6
f010172e:	68 21 72 10 f0       	push   $0xf0107221
f0101733:	e8 5c e9 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1050.\n");	


	// free and re-allocate?
	page_free(pp0);
f0101738:	83 ec 0c             	sub    $0xc,%esp
f010173b:	57                   	push   %edi
f010173c:	e8 f6 f8 ff ff       	call   f0101037 <page_free>
	page_free(pp1);
f0101741:	89 34 24             	mov    %esi,(%esp)
f0101744:	e8 ee f8 ff ff       	call   f0101037 <page_free>
	page_free(pp2);
f0101749:	83 c4 04             	add    $0x4,%esp
f010174c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010174f:	e8 e3 f8 ff ff       	call   f0101037 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101754:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010175b:	e8 1e f8 ff ff       	call   f0100f7e <page_alloc>
f0101760:	89 c6                	mov    %eax,%esi
f0101762:	83 c4 10             	add    $0x10,%esp
f0101765:	85 c0                	test   %eax,%eax
f0101767:	75 19                	jne    f0101782 <mem_init+0x302>
f0101769:	68 31 73 10 f0       	push   $0xf0107331
f010176e:	68 47 72 10 f0       	push   $0xf0107247
f0101773:	68 c0 04 00 00       	push   $0x4c0
f0101778:	68 21 72 10 f0       	push   $0xf0107221
f010177d:	e8 12 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101782:	83 ec 0c             	sub    $0xc,%esp
f0101785:	6a 00                	push   $0x0
f0101787:	e8 f2 f7 ff ff       	call   f0100f7e <page_alloc>
f010178c:	89 c7                	mov    %eax,%edi
f010178e:	83 c4 10             	add    $0x10,%esp
f0101791:	85 c0                	test   %eax,%eax
f0101793:	75 19                	jne    f01017ae <mem_init+0x32e>
f0101795:	68 47 73 10 f0       	push   $0xf0107347
f010179a:	68 47 72 10 f0       	push   $0xf0107247
f010179f:	68 c1 04 00 00       	push   $0x4c1
f01017a4:	68 21 72 10 f0       	push   $0xf0107221
f01017a9:	e8 e6 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017ae:	83 ec 0c             	sub    $0xc,%esp
f01017b1:	6a 00                	push   $0x0
f01017b3:	e8 c6 f7 ff ff       	call   f0100f7e <page_alloc>
f01017b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017bb:	83 c4 10             	add    $0x10,%esp
f01017be:	85 c0                	test   %eax,%eax
f01017c0:	75 19                	jne    f01017db <mem_init+0x35b>
f01017c2:	68 5d 73 10 f0       	push   $0xf010735d
f01017c7:	68 47 72 10 f0       	push   $0xf0107247
f01017cc:	68 c2 04 00 00       	push   $0x4c2
f01017d1:	68 21 72 10 f0       	push   $0xf0107221
f01017d6:	e8 b9 e8 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017db:	39 fe                	cmp    %edi,%esi
f01017dd:	75 19                	jne    f01017f8 <mem_init+0x378>
f01017df:	68 73 73 10 f0       	push   $0xf0107373
f01017e4:	68 47 72 10 f0       	push   $0xf0107247
f01017e9:	68 c4 04 00 00       	push   $0x4c4
f01017ee:	68 21 72 10 f0       	push   $0xf0107221
f01017f3:	e8 9c e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017fb:	39 c7                	cmp    %eax,%edi
f01017fd:	74 04                	je     f0101803 <mem_init+0x383>
f01017ff:	39 c6                	cmp    %eax,%esi
f0101801:	75 19                	jne    f010181c <mem_init+0x39c>
f0101803:	68 14 6a 10 f0       	push   $0xf0106a14
f0101808:	68 47 72 10 f0       	push   $0xf0107247
f010180d:	68 c5 04 00 00       	push   $0x4c5
f0101812:	68 21 72 10 f0       	push   $0xf0107221
f0101817:	e8 78 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010181c:	83 ec 0c             	sub    $0xc,%esp
f010181f:	6a 00                	push   $0x0
f0101821:	e8 58 f7 ff ff       	call   f0100f7e <page_alloc>
f0101826:	83 c4 10             	add    $0x10,%esp
f0101829:	85 c0                	test   %eax,%eax
f010182b:	74 19                	je     f0101846 <mem_init+0x3c6>
f010182d:	68 dc 73 10 f0       	push   $0xf01073dc
f0101832:	68 47 72 10 f0       	push   $0xf0107247
f0101837:	68 c6 04 00 00       	push   $0x4c6
f010183c:	68 21 72 10 f0       	push   $0xf0107221
f0101841:	e8 4e e8 ff ff       	call   f0100094 <_panic>
f0101846:	89 f0                	mov    %esi,%eax
f0101848:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010184e:	c1 f8 03             	sar    $0x3,%eax
f0101851:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101854:	89 c2                	mov    %eax,%edx
f0101856:	c1 ea 0c             	shr    $0xc,%edx
f0101859:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f010185f:	72 12                	jb     f0101873 <mem_init+0x3f3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101861:	50                   	push   %eax
f0101862:	68 c4 62 10 f0       	push   $0xf01062c4
f0101867:	6a 58                	push   $0x58
f0101869:	68 2d 72 10 f0       	push   $0xf010722d
f010186e:	e8 21 e8 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1066.\n");	


	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101873:	83 ec 04             	sub    $0x4,%esp
f0101876:	68 00 10 00 00       	push   $0x1000
f010187b:	6a 01                	push   $0x1
f010187d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101882:	50                   	push   %eax
f0101883:	e8 b9 3c 00 00       	call   f0105541 <memset>
	page_free(pp0);
f0101888:	89 34 24             	mov    %esi,(%esp)
f010188b:	e8 a7 f7 ff ff       	call   f0101037 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101890:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101897:	e8 e2 f6 ff ff       	call   f0100f7e <page_alloc>
f010189c:	83 c4 10             	add    $0x10,%esp
f010189f:	85 c0                	test   %eax,%eax
f01018a1:	75 19                	jne    f01018bc <mem_init+0x43c>
f01018a3:	68 eb 73 10 f0       	push   $0xf01073eb
f01018a8:	68 47 72 10 f0       	push   $0xf0107247
f01018ad:	68 ce 04 00 00       	push   $0x4ce
f01018b2:	68 21 72 10 f0       	push   $0xf0107221
f01018b7:	e8 d8 e7 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f01018bc:	39 c6                	cmp    %eax,%esi
f01018be:	74 19                	je     f01018d9 <mem_init+0x459>
f01018c0:	68 09 74 10 f0       	push   $0xf0107409
f01018c5:	68 47 72 10 f0       	push   $0xf0107247
f01018ca:	68 cf 04 00 00       	push   $0x4cf
f01018cf:	68 21 72 10 f0       	push   $0xf0107221
f01018d4:	e8 bb e7 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018d9:	89 f0                	mov    %esi,%eax
f01018db:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01018e1:	c1 f8 03             	sar    $0x3,%eax
f01018e4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018e7:	89 c2                	mov    %eax,%edx
f01018e9:	c1 ea 0c             	shr    $0xc,%edx
f01018ec:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01018f2:	72 12                	jb     f0101906 <mem_init+0x486>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018f4:	50                   	push   %eax
f01018f5:	68 c4 62 10 f0       	push   $0xf01062c4
f01018fa:	6a 58                	push   $0x58
f01018fc:	68 2d 72 10 f0       	push   $0xf010722d
f0101901:	e8 8e e7 ff ff       	call   f0100094 <_panic>
f0101906:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010190c:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101912:	80 38 00             	cmpb   $0x0,(%eax)
f0101915:	74 19                	je     f0101930 <mem_init+0x4b0>
f0101917:	68 19 74 10 f0       	push   $0xf0107419
f010191c:	68 47 72 10 f0       	push   $0xf0107247
f0101921:	68 d2 04 00 00       	push   $0x4d2
f0101926:	68 21 72 10 f0       	push   $0xf0107221
f010192b:	e8 64 e7 ff ff       	call   f0100094 <_panic>
f0101930:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101933:	39 d0                	cmp    %edx,%eax
f0101935:	75 db                	jne    f0101912 <mem_init+0x492>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101937:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010193a:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

	// free the pages we took
	page_free(pp0);
f010193f:	83 ec 0c             	sub    $0xc,%esp
f0101942:	56                   	push   %esi
f0101943:	e8 ef f6 ff ff       	call   f0101037 <page_free>
	page_free(pp1);
f0101948:	89 3c 24             	mov    %edi,(%esp)
f010194b:	e8 e7 f6 ff ff       	call   f0101037 <page_free>
	page_free(pp2);
f0101950:	83 c4 04             	add    $0x4,%esp
f0101953:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101956:	e8 dc f6 ff ff       	call   f0101037 <page_free>
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010195b:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101960:	83 c4 10             	add    $0x10,%esp
f0101963:	eb 05                	jmp    f010196a <mem_init+0x4ea>
		--nfree;
f0101965:	83 eb 01             	sub    $0x1,%ebx
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101968:	8b 00                	mov    (%eax),%eax
f010196a:	85 c0                	test   %eax,%eax
f010196c:	75 f7                	jne    f0101965 <mem_init+0x4e5>
		--nfree;
	assert(nfree == 0);
f010196e:	85 db                	test   %ebx,%ebx
f0101970:	74 19                	je     f010198b <mem_init+0x50b>
f0101972:	68 23 74 10 f0       	push   $0xf0107423
f0101977:	68 47 72 10 f0       	push   $0xf0107247
f010197c:	68 e2 04 00 00       	push   $0x4e2
f0101981:	68 21 72 10 f0       	push   $0xf0107221
f0101986:	e8 09 e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010198b:	83 ec 0c             	sub    $0xc,%esp
f010198e:	68 34 6a 10 f0       	push   $0xf0106a34
f0101993:	e8 f0 1e 00 00       	call   f0103888 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101998:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010199f:	e8 da f5 ff ff       	call   f0100f7e <page_alloc>
f01019a4:	89 c6                	mov    %eax,%esi
f01019a6:	83 c4 10             	add    $0x10,%esp
f01019a9:	85 c0                	test   %eax,%eax
f01019ab:	75 19                	jne    f01019c6 <mem_init+0x546>
f01019ad:	68 31 73 10 f0       	push   $0xf0107331
f01019b2:	68 47 72 10 f0       	push   $0xf0107247
f01019b7:	68 5c 05 00 00       	push   $0x55c
f01019bc:	68 21 72 10 f0       	push   $0xf0107221
f01019c1:	e8 ce e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01019c6:	83 ec 0c             	sub    $0xc,%esp
f01019c9:	6a 00                	push   $0x0
f01019cb:	e8 ae f5 ff ff       	call   f0100f7e <page_alloc>
f01019d0:	89 c3                	mov    %eax,%ebx
f01019d2:	83 c4 10             	add    $0x10,%esp
f01019d5:	85 c0                	test   %eax,%eax
f01019d7:	75 19                	jne    f01019f2 <mem_init+0x572>
f01019d9:	68 47 73 10 f0       	push   $0xf0107347
f01019de:	68 47 72 10 f0       	push   $0xf0107247
f01019e3:	68 5d 05 00 00       	push   $0x55d
f01019e8:	68 21 72 10 f0       	push   $0xf0107221
f01019ed:	e8 a2 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01019f2:	83 ec 0c             	sub    $0xc,%esp
f01019f5:	6a 00                	push   $0x0
f01019f7:	e8 82 f5 ff ff       	call   f0100f7e <page_alloc>
f01019fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019ff:	83 c4 10             	add    $0x10,%esp
f0101a02:	85 c0                	test   %eax,%eax
f0101a04:	75 19                	jne    f0101a1f <mem_init+0x59f>
f0101a06:	68 5d 73 10 f0       	push   $0xf010735d
f0101a0b:	68 47 72 10 f0       	push   $0xf0107247
f0101a10:	68 5e 05 00 00       	push   $0x55e
f0101a15:	68 21 72 10 f0       	push   $0xf0107221
f0101a1a:	e8 75 e6 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a1f:	39 de                	cmp    %ebx,%esi
f0101a21:	75 19                	jne    f0101a3c <mem_init+0x5bc>
f0101a23:	68 73 73 10 f0       	push   $0xf0107373
f0101a28:	68 47 72 10 f0       	push   $0xf0107247
f0101a2d:	68 61 05 00 00       	push   $0x561
f0101a32:	68 21 72 10 f0       	push   $0xf0107221
f0101a37:	e8 58 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3f:	39 c6                	cmp    %eax,%esi
f0101a41:	74 04                	je     f0101a47 <mem_init+0x5c7>
f0101a43:	39 c3                	cmp    %eax,%ebx
f0101a45:	75 19                	jne    f0101a60 <mem_init+0x5e0>
f0101a47:	68 14 6a 10 f0       	push   $0xf0106a14
f0101a4c:	68 47 72 10 f0       	push   $0xf0107247
f0101a51:	68 62 05 00 00       	push   $0x562
f0101a56:	68 21 72 10 f0       	push   $0xf0107221
f0101a5b:	e8 34 e6 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a60:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101a65:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a68:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0101a6f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a72:	83 ec 0c             	sub    $0xc,%esp
f0101a75:	6a 00                	push   $0x0
f0101a77:	e8 02 f5 ff ff       	call   f0100f7e <page_alloc>
f0101a7c:	83 c4 10             	add    $0x10,%esp
f0101a7f:	85 c0                	test   %eax,%eax
f0101a81:	74 19                	je     f0101a9c <mem_init+0x61c>
f0101a83:	68 dc 73 10 f0       	push   $0xf01073dc
f0101a88:	68 47 72 10 f0       	push   $0xf0107247
f0101a8d:	68 69 05 00 00       	push   $0x569
f0101a92:	68 21 72 10 f0       	push   $0xf0107221
f0101a97:	e8 f8 e5 ff ff       	call   f0100094 <_panic>
//cprintf("the page_free_list:%d\n",page_free_list);

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a9c:	83 ec 04             	sub    $0x4,%esp
f0101a9f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101aa2:	50                   	push   %eax
f0101aa3:	6a 00                	push   $0x0
f0101aa5:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101aab:	e8 dd f7 ff ff       	call   f010128d <page_lookup>
f0101ab0:	83 c4 10             	add    $0x10,%esp
f0101ab3:	85 c0                	test   %eax,%eax
f0101ab5:	74 19                	je     f0101ad0 <mem_init+0x650>
f0101ab7:	68 54 6a 10 f0       	push   $0xf0106a54
f0101abc:	68 47 72 10 f0       	push   $0xf0107247
f0101ac1:	68 6d 05 00 00       	push   $0x56d
f0101ac6:	68 21 72 10 f0       	push   $0xf0107221
f0101acb:	e8 c4 e5 ff ff       	call   f0100094 <_panic>
	
//cprintf("#    the page_free_list:%d\n",page_free_list);

	// there is no free memory, so we can't allocate a page table
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ad0:	6a 02                	push   $0x2
f0101ad2:	6a 00                	push   $0x0
f0101ad4:	53                   	push   %ebx
f0101ad5:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101adb:	e8 8d f8 ff ff       	call   f010136d <page_insert>
f0101ae0:	83 c4 10             	add    $0x10,%esp
f0101ae3:	85 c0                	test   %eax,%eax
f0101ae5:	78 19                	js     f0101b00 <mem_init+0x680>
f0101ae7:	68 8c 6a 10 f0       	push   $0xf0106a8c
f0101aec:	68 47 72 10 f0       	push   $0xf0107247
f0101af1:	68 75 05 00 00       	push   $0x575
f0101af6:	68 21 72 10 f0       	push   $0xf0107221
f0101afb:	e8 94 e5 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
//cprintf("##     the page_free_list:%d\n",page_free_list);
//cprintf("$$ at before the page_free(pp0)\n\n");
	page_free(pp0);
f0101b00:	83 ec 0c             	sub    $0xc,%esp
f0101b03:	56                   	push   %esi
f0101b04:	e8 2e f5 ff ff       	call   f0101037 <page_free>
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b09:	6a 02                	push   $0x2
f0101b0b:	6a 00                	push   $0x0
f0101b0d:	53                   	push   %ebx
f0101b0e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101b14:	e8 54 f8 ff ff       	call   f010136d <page_insert>
f0101b19:	83 c4 20             	add    $0x20,%esp
f0101b1c:	85 c0                	test   %eax,%eax
f0101b1e:	74 19                	je     f0101b39 <mem_init+0x6b9>
f0101b20:	68 bc 6a 10 f0       	push   $0xf0106abc
f0101b25:	68 47 72 10 f0       	push   $0xf0107247
f0101b2a:	68 7c 05 00 00       	push   $0x57c
f0101b2f:	68 21 72 10 f0       	push   $0xf0107221
f0101b34:	e8 5b e5 ff ff       	call   f0100094 <_panic>

//cprintf("## %x  %x\n",PTE_ADDR(kern_pgdir[0]),page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b39:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b3f:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0101b44:	89 c1                	mov    %eax,%ecx
f0101b46:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b49:	8b 17                	mov    (%edi),%edx
f0101b4b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b51:	89 f0                	mov    %esi,%eax
f0101b53:	29 c8                	sub    %ecx,%eax
f0101b55:	c1 f8 03             	sar    $0x3,%eax
f0101b58:	c1 e0 0c             	shl    $0xc,%eax
f0101b5b:	39 c2                	cmp    %eax,%edx
f0101b5d:	74 19                	je     f0101b78 <mem_init+0x6f8>
f0101b5f:	68 ec 6a 10 f0       	push   $0xf0106aec
f0101b64:	68 47 72 10 f0       	push   $0xf0107247
f0101b69:	68 7f 05 00 00       	push   $0x57f
f0101b6e:	68 21 72 10 f0       	push   $0xf0107221
f0101b73:	e8 1c e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b78:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b7d:	89 f8                	mov    %edi,%eax
f0101b7f:	e8 f8 ef ff ff       	call   f0100b7c <check_va2pa>
f0101b84:	89 da                	mov    %ebx,%edx
f0101b86:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b89:	c1 fa 03             	sar    $0x3,%edx
f0101b8c:	c1 e2 0c             	shl    $0xc,%edx
f0101b8f:	39 d0                	cmp    %edx,%eax
f0101b91:	74 19                	je     f0101bac <mem_init+0x72c>
f0101b93:	68 14 6b 10 f0       	push   $0xf0106b14
f0101b98:	68 47 72 10 f0       	push   $0xf0107247
f0101b9d:	68 80 05 00 00       	push   $0x580
f0101ba2:	68 21 72 10 f0       	push   $0xf0107221
f0101ba7:	e8 e8 e4 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101bac:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bb1:	74 19                	je     f0101bcc <mem_init+0x74c>
f0101bb3:	68 2e 74 10 f0       	push   $0xf010742e
f0101bb8:	68 47 72 10 f0       	push   $0xf0107247
f0101bbd:	68 81 05 00 00       	push   $0x581
f0101bc2:	68 21 72 10 f0       	push   $0xf0107221
f0101bc7:	e8 c8 e4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101bcc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bd1:	74 19                	je     f0101bec <mem_init+0x76c>
f0101bd3:	68 3f 74 10 f0       	push   $0xf010743f
f0101bd8:	68 47 72 10 f0       	push   $0xf0107247
f0101bdd:	68 82 05 00 00       	push   $0x582
f0101be2:	68 21 72 10 f0       	push   $0xf0107221
f0101be7:	e8 a8 e4 ff ff       	call   f0100094 <_panic>
//cprintf("###  before page_insert pp2  the page_free_list:%d\n",page_free_list);

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
//cprintf("$$ at before the page_insert pp2 at PGSIZE\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bec:	6a 02                	push   $0x2
f0101bee:	68 00 10 00 00       	push   $0x1000
f0101bf3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bf6:	57                   	push   %edi
f0101bf7:	e8 71 f7 ff ff       	call   f010136d <page_insert>
f0101bfc:	83 c4 10             	add    $0x10,%esp
f0101bff:	85 c0                	test   %eax,%eax
f0101c01:	74 19                	je     f0101c1c <mem_init+0x79c>
f0101c03:	68 44 6b 10 f0       	push   $0xf0106b44
f0101c08:	68 47 72 10 f0       	push   $0xf0107247
f0101c0d:	68 87 05 00 00       	push   $0x587
f0101c12:	68 21 72 10 f0       	push   $0xf0107221
f0101c17:	e8 78 e4 ff ff       	call   f0100094 <_panic>
//cprintf("#### here we get over the page_insert page_free_list:%x.\n",page_free_list);
//cprintf("pp0:%x\npp1:%x\npp2:%x\n",pp0,pp1,pp2);	
//cprintf("!! the check_va2pa is %d,page2pa(pp1) %x\n",check_va2pa(kern_pgdir,PGSIZE),page2pa(pp2));


	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c1c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c21:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101c26:	e8 51 ef ff ff       	call   f0100b7c <check_va2pa>
f0101c2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c2e:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101c34:	c1 fa 03             	sar    $0x3,%edx
f0101c37:	c1 e2 0c             	shl    $0xc,%edx
f0101c3a:	39 d0                	cmp    %edx,%eax
f0101c3c:	74 19                	je     f0101c57 <mem_init+0x7d7>
f0101c3e:	68 80 6b 10 f0       	push   $0xf0106b80
f0101c43:	68 47 72 10 f0       	push   $0xf0107247
f0101c48:	68 8d 05 00 00       	push   $0x58d
f0101c4d:	68 21 72 10 f0       	push   $0xf0107221
f0101c52:	e8 3d e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101c57:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c5a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c5f:	74 19                	je     f0101c7a <mem_init+0x7fa>
f0101c61:	68 50 74 10 f0       	push   $0xf0107450
f0101c66:	68 47 72 10 f0       	push   $0xf0107247
f0101c6b:	68 8e 05 00 00       	push   $0x58e
f0101c70:	68 21 72 10 f0       	push   $0xf0107221
f0101c75:	e8 1a e4 ff ff       	call   f0100094 <_panic>

	// should be no free memory
//cprintf("##### before_page_alloc:  the page_free_list:%d\n",page_free_list);
	assert(!page_alloc(0));
f0101c7a:	83 ec 0c             	sub    $0xc,%esp
f0101c7d:	6a 00                	push   $0x0
f0101c7f:	e8 fa f2 ff ff       	call   f0100f7e <page_alloc>
f0101c84:	83 c4 10             	add    $0x10,%esp
f0101c87:	85 c0                	test   %eax,%eax
f0101c89:	74 19                	je     f0101ca4 <mem_init+0x824>
f0101c8b:	68 dc 73 10 f0       	push   $0xf01073dc
f0101c90:	68 47 72 10 f0       	push   $0xf0107247
f0101c95:	68 92 05 00 00       	push   $0x592
f0101c9a:	68 21 72 10 f0       	push   $0xf0107221
f0101c9f:	e8 f0 e3 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
//cprintf("$$ at twice before the page_insert pp2 at PGSIZE.\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ca4:	6a 02                	push   $0x2
f0101ca6:	68 00 10 00 00       	push   $0x1000
f0101cab:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cae:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101cb4:	e8 b4 f6 ff ff       	call   f010136d <page_insert>
f0101cb9:	83 c4 10             	add    $0x10,%esp
f0101cbc:	85 c0                	test   %eax,%eax
f0101cbe:	74 19                	je     f0101cd9 <mem_init+0x859>
f0101cc0:	68 44 6b 10 f0       	push   $0xf0106b44
f0101cc5:	68 47 72 10 f0       	push   $0xf0107247
f0101cca:	68 96 05 00 00       	push   $0x596
f0101ccf:	68 21 72 10 f0       	push   $0xf0107221
f0101cd4:	e8 bb e3 ff ff       	call   f0100094 <_panic>
//	for(struct PageInfo *temp_pp = page_free_list;temp_pp;temp_pp = temp_pp->pp_link){
//		cprintf("the temp_pp:%x\n",temp_pp);
//	}
	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cd9:	83 ec 0c             	sub    $0xc,%esp
f0101cdc:	6a 00                	push   $0x0
f0101cde:	e8 9b f2 ff ff       	call   f0100f7e <page_alloc>
f0101ce3:	83 c4 10             	add    $0x10,%esp
f0101ce6:	85 c0                	test   %eax,%eax
f0101ce8:	74 19                	je     f0101d03 <mem_init+0x883>
f0101cea:	68 dc 73 10 f0       	push   $0xf01073dc
f0101cef:	68 47 72 10 f0       	push   $0xf0107247
f0101cf4:	68 a2 05 00 00       	push   $0x5a2
f0101cf9:	68 21 72 10 f0       	push   $0xf0107221
f0101cfe:	e8 91 e3 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d03:	8b 15 8c fe 22 f0    	mov    0xf022fe8c,%edx
f0101d09:	8b 02                	mov    (%edx),%eax
f0101d0b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d10:	89 c1                	mov    %eax,%ecx
f0101d12:	c1 e9 0c             	shr    $0xc,%ecx
f0101d15:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0101d1b:	72 15                	jb     f0101d32 <mem_init+0x8b2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d1d:	50                   	push   %eax
f0101d1e:	68 c4 62 10 f0       	push   $0xf01062c4
f0101d23:	68 a5 05 00 00       	push   $0x5a5
f0101d28:	68 21 72 10 f0       	push   $0xf0107221
f0101d2d:	e8 62 e3 ff ff       	call   f0100094 <_panic>
f0101d32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
//cprintf("the pgdir_walk(kern_pgdir,(void*)PGSIZE,0):%x\n",pgdir_walk(kern_pgdir,(void*)PGSIZE,0));
//cprintf("ptep+PTX(PGSIZE):%x\n",ptep+PTX(PGSIZE));
//cprintf("ptep:%x\n",ptep);
//cprintf("PTX(PGSIZE):%x\n",PTX(PGSIZE));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d3a:	83 ec 04             	sub    $0x4,%esp
f0101d3d:	6a 00                	push   $0x0
f0101d3f:	68 00 10 00 00       	push   $0x1000
f0101d44:	52                   	push   %edx
f0101d45:	e8 ce f3 ff ff       	call   f0101118 <pgdir_walk>
f0101d4a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d4d:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d50:	83 c4 10             	add    $0x10,%esp
f0101d53:	39 d0                	cmp    %edx,%eax
f0101d55:	74 19                	je     f0101d70 <mem_init+0x8f0>
f0101d57:	68 b0 6b 10 f0       	push   $0xf0106bb0
f0101d5c:	68 47 72 10 f0       	push   $0xf0107247
f0101d61:	68 aa 05 00 00       	push   $0x5aa
f0101d66:	68 21 72 10 f0       	push   $0xf0107221
f0101d6b:	e8 24 e3 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 3th page_insert pp2 to PGSIZE with changing the permissions.\n\n");
	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d70:	6a 06                	push   $0x6
f0101d72:	68 00 10 00 00       	push   $0x1000
f0101d77:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d7a:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101d80:	e8 e8 f5 ff ff       	call   f010136d <page_insert>
f0101d85:	83 c4 10             	add    $0x10,%esp
f0101d88:	85 c0                	test   %eax,%eax
f0101d8a:	74 19                	je     f0101da5 <mem_init+0x925>
f0101d8c:	68 f0 6b 10 f0       	push   $0xf0106bf0
f0101d91:	68 47 72 10 f0       	push   $0xf0107247
f0101d96:	68 ad 05 00 00       	push   $0x5ad
f0101d9b:	68 21 72 10 f0       	push   $0xf0107221
f0101da0:	e8 ef e2 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101da5:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101dab:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101db0:	89 f8                	mov    %edi,%eax
f0101db2:	e8 c5 ed ff ff       	call   f0100b7c <check_va2pa>
f0101db7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101dba:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101dc0:	c1 fa 03             	sar    $0x3,%edx
f0101dc3:	c1 e2 0c             	shl    $0xc,%edx
f0101dc6:	39 d0                	cmp    %edx,%eax
f0101dc8:	74 19                	je     f0101de3 <mem_init+0x963>
f0101dca:	68 80 6b 10 f0       	push   $0xf0106b80
f0101dcf:	68 47 72 10 f0       	push   $0xf0107247
f0101dd4:	68 ae 05 00 00       	push   $0x5ae
f0101dd9:	68 21 72 10 f0       	push   $0xf0107221
f0101dde:	e8 b1 e2 ff ff       	call   f0100094 <_panic>
//	cprintf("the final pp2->pp_ref:%x\n",pp2->pp_ref);
	assert(pp2->pp_ref == 1);
f0101de3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101de6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101deb:	74 19                	je     f0101e06 <mem_init+0x986>
f0101ded:	68 50 74 10 f0       	push   $0xf0107450
f0101df2:	68 47 72 10 f0       	push   $0xf0107247
f0101df7:	68 b0 05 00 00       	push   $0x5b0
f0101dfc:	68 21 72 10 f0       	push   $0xf0107221
f0101e01:	e8 8e e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e06:	83 ec 04             	sub    $0x4,%esp
f0101e09:	6a 00                	push   $0x0
f0101e0b:	68 00 10 00 00       	push   $0x1000
f0101e10:	57                   	push   %edi
f0101e11:	e8 02 f3 ff ff       	call   f0101118 <pgdir_walk>
f0101e16:	83 c4 10             	add    $0x10,%esp
f0101e19:	f6 00 04             	testb  $0x4,(%eax)
f0101e1c:	75 19                	jne    f0101e37 <mem_init+0x9b7>
f0101e1e:	68 30 6c 10 f0       	push   $0xf0106c30
f0101e23:	68 47 72 10 f0       	push   $0xf0107247
f0101e28:	68 b1 05 00 00       	push   $0x5b1
f0101e2d:	68 21 72 10 f0       	push   $0xf0107221
f0101e32:	e8 5d e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e37:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101e3c:	f6 00 04             	testb  $0x4,(%eax)
f0101e3f:	75 19                	jne    f0101e5a <mem_init+0x9da>
f0101e41:	68 61 74 10 f0       	push   $0xf0107461
f0101e46:	68 47 72 10 f0       	push   $0xf0107247
f0101e4b:	68 b2 05 00 00       	push   $0x5b2
f0101e50:	68 21 72 10 f0       	push   $0xf0107221
f0101e55:	e8 3a e2 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 4th the new line page_insert pp2 PGSIZE with fewer permissions\n\n");
	// should be able to remap with fewer permissions ??
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e5a:	6a 02                	push   $0x2
f0101e5c:	68 00 10 00 00       	push   $0x1000
f0101e61:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e64:	50                   	push   %eax
f0101e65:	e8 03 f5 ff ff       	call   f010136d <page_insert>
f0101e6a:	83 c4 10             	add    $0x10,%esp
f0101e6d:	85 c0                	test   %eax,%eax
f0101e6f:	74 19                	je     f0101e8a <mem_init+0xa0a>
f0101e71:	68 44 6b 10 f0       	push   $0xf0106b44
f0101e76:	68 47 72 10 f0       	push   $0xf0107247
f0101e7b:	68 b5 05 00 00       	push   $0x5b5
f0101e80:	68 21 72 10 f0       	push   $0xf0107221
f0101e85:	e8 0a e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e8a:	83 ec 04             	sub    $0x4,%esp
f0101e8d:	6a 00                	push   $0x0
f0101e8f:	68 00 10 00 00       	push   $0x1000
f0101e94:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101e9a:	e8 79 f2 ff ff       	call   f0101118 <pgdir_walk>
f0101e9f:	83 c4 10             	add    $0x10,%esp
f0101ea2:	f6 00 02             	testb  $0x2,(%eax)
f0101ea5:	75 19                	jne    f0101ec0 <mem_init+0xa40>
f0101ea7:	68 64 6c 10 f0       	push   $0xf0106c64
f0101eac:	68 47 72 10 f0       	push   $0xf0107247
f0101eb1:	68 b6 05 00 00       	push   $0x5b6
f0101eb6:	68 21 72 10 f0       	push   $0xf0107221
f0101ebb:	e8 d4 e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ec0:	83 ec 04             	sub    $0x4,%esp
f0101ec3:	6a 00                	push   $0x0
f0101ec5:	68 00 10 00 00       	push   $0x1000
f0101eca:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101ed0:	e8 43 f2 ff ff       	call   f0101118 <pgdir_walk>
f0101ed5:	83 c4 10             	add    $0x10,%esp
f0101ed8:	f6 00 04             	testb  $0x4,(%eax)
f0101edb:	74 19                	je     f0101ef6 <mem_init+0xa76>
f0101edd:	68 98 6c 10 f0       	push   $0xf0106c98
f0101ee2:	68 47 72 10 f0       	push   $0xf0107247
f0101ee7:	68 b7 05 00 00       	push   $0x5b7
f0101eec:	68 21 72 10 f0       	push   $0xf0107221
f0101ef1:	e8 9e e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
//cprintf("$$ before the page_insert into PTSIZE\n\n");
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ef6:	6a 02                	push   $0x2
f0101ef8:	68 00 00 40 00       	push   $0x400000
f0101efd:	56                   	push   %esi
f0101efe:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f04:	e8 64 f4 ff ff       	call   f010136d <page_insert>
f0101f09:	83 c4 10             	add    $0x10,%esp
f0101f0c:	85 c0                	test   %eax,%eax
f0101f0e:	78 19                	js     f0101f29 <mem_init+0xaa9>
f0101f10:	68 d0 6c 10 f0       	push   $0xf0106cd0
f0101f15:	68 47 72 10 f0       	push   $0xf0107247
f0101f1a:	68 bb 05 00 00       	push   $0x5bb
f0101f1f:	68 21 72 10 f0       	push   $0xf0107221
f0101f24:	e8 6b e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
//cprintf("$$ before insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f29:	6a 02                	push   $0x2
f0101f2b:	68 00 10 00 00       	push   $0x1000
f0101f30:	53                   	push   %ebx
f0101f31:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f37:	e8 31 f4 ff ff       	call   f010136d <page_insert>
f0101f3c:	83 c4 10             	add    $0x10,%esp
f0101f3f:	85 c0                	test   %eax,%eax
f0101f41:	74 19                	je     f0101f5c <mem_init+0xadc>
f0101f43:	68 08 6d 10 f0       	push   $0xf0106d08
f0101f48:	68 47 72 10 f0       	push   $0xf0107247
f0101f4d:	68 bf 05 00 00       	push   $0x5bf
f0101f52:	68 21 72 10 f0       	push   $0xf0107221
f0101f57:	e8 38 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f5c:	83 ec 04             	sub    $0x4,%esp
f0101f5f:	6a 00                	push   $0x0
f0101f61:	68 00 10 00 00       	push   $0x1000
f0101f66:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f6c:	e8 a7 f1 ff ff       	call   f0101118 <pgdir_walk>
f0101f71:	83 c4 10             	add    $0x10,%esp
f0101f74:	f6 00 04             	testb  $0x4,(%eax)
f0101f77:	74 19                	je     f0101f92 <mem_init+0xb12>
f0101f79:	68 98 6c 10 f0       	push   $0xf0106c98
f0101f7e:	68 47 72 10 f0       	push   $0xf0107247
f0101f83:	68 c1 05 00 00       	push   $0x5c1
f0101f88:	68 21 72 10 f0       	push   $0xf0107221
f0101f8d:	e8 02 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after checking the (!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U)\n\n");
	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f92:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101f98:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f9d:	89 f8                	mov    %edi,%eax
f0101f9f:	e8 d8 eb ff ff       	call   f0100b7c <check_va2pa>
f0101fa4:	89 c1                	mov    %eax,%ecx
f0101fa6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fa9:	89 d8                	mov    %ebx,%eax
f0101fab:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101fb1:	c1 f8 03             	sar    $0x3,%eax
f0101fb4:	c1 e0 0c             	shl    $0xc,%eax
f0101fb7:	39 c1                	cmp    %eax,%ecx
f0101fb9:	74 19                	je     f0101fd4 <mem_init+0xb54>
f0101fbb:	68 44 6d 10 f0       	push   $0xf0106d44
f0101fc0:	68 47 72 10 f0       	push   $0xf0107247
f0101fc5:	68 c4 05 00 00       	push   $0x5c4
f0101fca:	68 21 72 10 f0       	push   $0xf0107221
f0101fcf:	e8 c0 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fd4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fd9:	89 f8                	mov    %edi,%eax
f0101fdb:	e8 9c eb ff ff       	call   f0100b7c <check_va2pa>
f0101fe0:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fe3:	74 19                	je     f0101ffe <mem_init+0xb7e>
f0101fe5:	68 70 6d 10 f0       	push   $0xf0106d70
f0101fea:	68 47 72 10 f0       	push   $0xf0107247
f0101fef:	68 c5 05 00 00       	push   $0x5c5
f0101ff4:	68 21 72 10 f0       	push   $0xf0107221
f0101ff9:	e8 96 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ffe:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102003:	74 19                	je     f010201e <mem_init+0xb9e>
f0102005:	68 77 74 10 f0       	push   $0xf0107477
f010200a:	68 47 72 10 f0       	push   $0xf0107247
f010200f:	68 c7 05 00 00       	push   $0x5c7
f0102014:	68 21 72 10 f0       	push   $0xf0107221
f0102019:	e8 76 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010201e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102021:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102026:	74 19                	je     f0102041 <mem_init+0xbc1>
f0102028:	68 88 74 10 f0       	push   $0xf0107488
f010202d:	68 47 72 10 f0       	push   $0xf0107247
f0102032:	68 c8 05 00 00       	push   $0x5c8
f0102037:	68 21 72 10 f0       	push   $0xf0107221
f010203c:	e8 53 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102041:	83 ec 0c             	sub    $0xc,%esp
f0102044:	6a 00                	push   $0x0
f0102046:	e8 33 ef ff ff       	call   f0100f7e <page_alloc>
f010204b:	83 c4 10             	add    $0x10,%esp
f010204e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102051:	75 04                	jne    f0102057 <mem_init+0xbd7>
f0102053:	85 c0                	test   %eax,%eax
f0102055:	75 19                	jne    f0102070 <mem_init+0xbf0>
f0102057:	68 a0 6d 10 f0       	push   $0xf0106da0
f010205c:	68 47 72 10 f0       	push   $0xf0107247
f0102061:	68 cb 05 00 00       	push   $0x5cb
f0102066:	68 21 72 10 f0       	push   $0xf0107221
f010206b:	e8 24 e0 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102070:	83 ec 08             	sub    $0x8,%esp
f0102073:	6a 00                	push   $0x0
f0102075:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010207b:	e8 a7 f2 ff ff       	call   f0101327 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102080:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102086:	ba 00 00 00 00       	mov    $0x0,%edx
f010208b:	89 f8                	mov    %edi,%eax
f010208d:	e8 ea ea ff ff       	call   f0100b7c <check_va2pa>
f0102092:	83 c4 10             	add    $0x10,%esp
f0102095:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102098:	74 19                	je     f01020b3 <mem_init+0xc33>
f010209a:	68 c4 6d 10 f0       	push   $0xf0106dc4
f010209f:	68 47 72 10 f0       	push   $0xf0107247
f01020a4:	68 cf 05 00 00       	push   $0x5cf
f01020a9:	68 21 72 10 f0       	push   $0xf0107221
f01020ae:	e8 e1 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020b3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020b8:	89 f8                	mov    %edi,%eax
f01020ba:	e8 bd ea ff ff       	call   f0100b7c <check_va2pa>
f01020bf:	89 da                	mov    %ebx,%edx
f01020c1:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f01020c7:	c1 fa 03             	sar    $0x3,%edx
f01020ca:	c1 e2 0c             	shl    $0xc,%edx
f01020cd:	39 d0                	cmp    %edx,%eax
f01020cf:	74 19                	je     f01020ea <mem_init+0xc6a>
f01020d1:	68 70 6d 10 f0       	push   $0xf0106d70
f01020d6:	68 47 72 10 f0       	push   $0xf0107247
f01020db:	68 d0 05 00 00       	push   $0x5d0
f01020e0:	68 21 72 10 f0       	push   $0xf0107221
f01020e5:	e8 aa df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01020ea:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020ef:	74 19                	je     f010210a <mem_init+0xc8a>
f01020f1:	68 2e 74 10 f0       	push   $0xf010742e
f01020f6:	68 47 72 10 f0       	push   $0xf0107247
f01020fb:	68 d1 05 00 00       	push   $0x5d1
f0102100:	68 21 72 10 f0       	push   $0xf0107221
f0102105:	e8 8a df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010210a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010210d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102112:	74 19                	je     f010212d <mem_init+0xcad>
f0102114:	68 88 74 10 f0       	push   $0xf0107488
f0102119:	68 47 72 10 f0       	push   $0xf0107247
f010211e:	68 d2 05 00 00       	push   $0x5d2
f0102123:	68 21 72 10 f0       	push   $0xf0107221
f0102128:	e8 67 df ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010212d:	6a 00                	push   $0x0
f010212f:	68 00 10 00 00       	push   $0x1000
f0102134:	53                   	push   %ebx
f0102135:	57                   	push   %edi
f0102136:	e8 32 f2 ff ff       	call   f010136d <page_insert>
f010213b:	83 c4 10             	add    $0x10,%esp
f010213e:	85 c0                	test   %eax,%eax
f0102140:	74 19                	je     f010215b <mem_init+0xcdb>
f0102142:	68 e8 6d 10 f0       	push   $0xf0106de8
f0102147:	68 47 72 10 f0       	push   $0xf0107247
f010214c:	68 d5 05 00 00       	push   $0x5d5
f0102151:	68 21 72 10 f0       	push   $0xf0107221
f0102156:	e8 39 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010215b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102160:	75 19                	jne    f010217b <mem_init+0xcfb>
f0102162:	68 99 74 10 f0       	push   $0xf0107499
f0102167:	68 47 72 10 f0       	push   $0xf0107247
f010216c:	68 d6 05 00 00       	push   $0x5d6
f0102171:	68 21 72 10 f0       	push   $0xf0107221
f0102176:	e8 19 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010217b:	83 3b 00             	cmpl   $0x0,(%ebx)
f010217e:	74 19                	je     f0102199 <mem_init+0xd19>
f0102180:	68 a5 74 10 f0       	push   $0xf01074a5
f0102185:	68 47 72 10 f0       	push   $0xf0107247
f010218a:	68 d7 05 00 00       	push   $0x5d7
f010218f:	68 21 72 10 f0       	push   $0xf0107221
f0102194:	e8 fb de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102199:	83 ec 08             	sub    $0x8,%esp
f010219c:	68 00 10 00 00       	push   $0x1000
f01021a1:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01021a7:	e8 7b f1 ff ff       	call   f0101327 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021ac:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f01021b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01021b7:	89 f8                	mov    %edi,%eax
f01021b9:	e8 be e9 ff ff       	call   f0100b7c <check_va2pa>
f01021be:	83 c4 10             	add    $0x10,%esp
f01021c1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021c4:	74 19                	je     f01021df <mem_init+0xd5f>
f01021c6:	68 c4 6d 10 f0       	push   $0xf0106dc4
f01021cb:	68 47 72 10 f0       	push   $0xf0107247
f01021d0:	68 db 05 00 00       	push   $0x5db
f01021d5:	68 21 72 10 f0       	push   $0xf0107221
f01021da:	e8 b5 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021df:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021e4:	89 f8                	mov    %edi,%eax
f01021e6:	e8 91 e9 ff ff       	call   f0100b7c <check_va2pa>
f01021eb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021ee:	74 19                	je     f0102209 <mem_init+0xd89>
f01021f0:	68 20 6e 10 f0       	push   $0xf0106e20
f01021f5:	68 47 72 10 f0       	push   $0xf0107247
f01021fa:	68 dc 05 00 00       	push   $0x5dc
f01021ff:	68 21 72 10 f0       	push   $0xf0107221
f0102204:	e8 8b de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102209:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010220e:	74 19                	je     f0102229 <mem_init+0xda9>
f0102210:	68 ba 74 10 f0       	push   $0xf01074ba
f0102215:	68 47 72 10 f0       	push   $0xf0107247
f010221a:	68 dd 05 00 00       	push   $0x5dd
f010221f:	68 21 72 10 f0       	push   $0xf0107221
f0102224:	e8 6b de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102229:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010222c:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102231:	74 19                	je     f010224c <mem_init+0xdcc>
f0102233:	68 88 74 10 f0       	push   $0xf0107488
f0102238:	68 47 72 10 f0       	push   $0xf0107247
f010223d:	68 de 05 00 00       	push   $0x5de
f0102242:	68 21 72 10 f0       	push   $0xf0107221
f0102247:	e8 48 de ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010224c:	83 ec 0c             	sub    $0xc,%esp
f010224f:	6a 00                	push   $0x0
f0102251:	e8 28 ed ff ff       	call   f0100f7e <page_alloc>
f0102256:	83 c4 10             	add    $0x10,%esp
f0102259:	85 c0                	test   %eax,%eax
f010225b:	74 04                	je     f0102261 <mem_init+0xde1>
f010225d:	39 c3                	cmp    %eax,%ebx
f010225f:	74 19                	je     f010227a <mem_init+0xdfa>
f0102261:	68 48 6e 10 f0       	push   $0xf0106e48
f0102266:	68 47 72 10 f0       	push   $0xf0107247
f010226b:	68 e1 05 00 00       	push   $0x5e1
f0102270:	68 21 72 10 f0       	push   $0xf0107221
f0102275:	e8 1a de ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010227a:	83 ec 0c             	sub    $0xc,%esp
f010227d:	6a 00                	push   $0x0
f010227f:	e8 fa ec ff ff       	call   f0100f7e <page_alloc>
f0102284:	83 c4 10             	add    $0x10,%esp
f0102287:	85 c0                	test   %eax,%eax
f0102289:	74 19                	je     f01022a4 <mem_init+0xe24>
f010228b:	68 dc 73 10 f0       	push   $0xf01073dc
f0102290:	68 47 72 10 f0       	push   $0xf0107247
f0102295:	68 e4 05 00 00       	push   $0x5e4
f010229a:	68 21 72 10 f0       	push   $0xf0107221
f010229f:	e8 f0 dd ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022a4:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f01022aa:	8b 11                	mov    (%ecx),%edx
f01022ac:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01022b2:	89 f0                	mov    %esi,%eax
f01022b4:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f01022ba:	c1 f8 03             	sar    $0x3,%eax
f01022bd:	c1 e0 0c             	shl    $0xc,%eax
f01022c0:	39 c2                	cmp    %eax,%edx
f01022c2:	74 19                	je     f01022dd <mem_init+0xe5d>
f01022c4:	68 ec 6a 10 f0       	push   $0xf0106aec
f01022c9:	68 47 72 10 f0       	push   $0xf0107247
f01022ce:	68 e7 05 00 00       	push   $0x5e7
f01022d3:	68 21 72 10 f0       	push   $0xf0107221
f01022d8:	e8 b7 dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01022dd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022e3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022e8:	74 19                	je     f0102303 <mem_init+0xe83>
f01022ea:	68 3f 74 10 f0       	push   $0xf010743f
f01022ef:	68 47 72 10 f0       	push   $0xf0107247
f01022f4:	68 e9 05 00 00       	push   $0x5e9
f01022f9:	68 21 72 10 f0       	push   $0xf0107221
f01022fe:	e8 91 dd ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102303:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102309:	83 ec 0c             	sub    $0xc,%esp
f010230c:	56                   	push   %esi
f010230d:	e8 25 ed ff ff       	call   f0101037 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102312:	83 c4 0c             	add    $0xc,%esp
f0102315:	6a 01                	push   $0x1
f0102317:	68 00 10 40 00       	push   $0x401000
f010231c:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102322:	e8 f1 ed ff ff       	call   f0101118 <pgdir_walk>
f0102327:	89 c7                	mov    %eax,%edi
f0102329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010232c:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102331:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102334:	8b 40 04             	mov    0x4(%eax),%eax
f0102337:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010233c:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f0102342:	89 c2                	mov    %eax,%edx
f0102344:	c1 ea 0c             	shr    $0xc,%edx
f0102347:	83 c4 10             	add    $0x10,%esp
f010234a:	39 ca                	cmp    %ecx,%edx
f010234c:	72 15                	jb     f0102363 <mem_init+0xee3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010234e:	50                   	push   %eax
f010234f:	68 c4 62 10 f0       	push   $0xf01062c4
f0102354:	68 f0 05 00 00       	push   $0x5f0
f0102359:	68 21 72 10 f0       	push   $0xf0107221
f010235e:	e8 31 dd ff ff       	call   f0100094 <_panic>
	
//now we fault at ptep == ptep1+PTX(va)
//cprintf("ptep:%x , PTX(va):%x,va:%x,ptep1:%x\n",ptep,PTX(va),va,ptep1);

	assert(ptep == ptep1 + PTX(va));
f0102363:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102368:	39 c7                	cmp    %eax,%edi
f010236a:	74 19                	je     f0102385 <mem_init+0xf05>
f010236c:	68 cb 74 10 f0       	push   $0xf01074cb
f0102371:	68 47 72 10 f0       	push   $0xf0107247
f0102376:	68 f5 05 00 00       	push   $0x5f5
f010237b:	68 21 72 10 f0       	push   $0xf0107221
f0102380:	e8 0f dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102385:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102388:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010238f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102395:	89 f0                	mov    %esi,%eax
f0102397:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010239d:	c1 f8 03             	sar    $0x3,%eax
f01023a0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023a3:	89 c2                	mov    %eax,%edx
f01023a5:	c1 ea 0c             	shr    $0xc,%edx
f01023a8:	39 d1                	cmp    %edx,%ecx
f01023aa:	77 12                	ja     f01023be <mem_init+0xf3e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023ac:	50                   	push   %eax
f01023ad:	68 c4 62 10 f0       	push   $0xf01062c4
f01023b2:	6a 58                	push   $0x58
f01023b4:	68 2d 72 10 f0       	push   $0xf010722d
f01023b9:	e8 d6 dc ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01023be:	83 ec 04             	sub    $0x4,%esp
f01023c1:	68 00 10 00 00       	push   $0x1000
f01023c6:	68 ff 00 00 00       	push   $0xff
f01023cb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023d0:	50                   	push   %eax
f01023d1:	e8 6b 31 00 00       	call   f0105541 <memset>
	page_free(pp0);
f01023d6:	89 34 24             	mov    %esi,(%esp)
f01023d9:	e8 59 ec ff ff       	call   f0101037 <page_free>


//here below is my commit,so if we set all pp0(the page table entry)
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023de:	83 c4 0c             	add    $0xc,%esp
f01023e1:	6a 01                	push   $0x1
f01023e3:	6a 00                	push   $0x0
f01023e5:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01023eb:	e8 28 ed ff ff       	call   f0101118 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023f0:	89 f2                	mov    %esi,%edx
f01023f2:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f01023f8:	c1 fa 03             	sar    $0x3,%edx
f01023fb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023fe:	89 d0                	mov    %edx,%eax
f0102400:	c1 e8 0c             	shr    $0xc,%eax
f0102403:	83 c4 10             	add    $0x10,%esp
f0102406:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010240c:	72 12                	jb     f0102420 <mem_init+0xfa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010240e:	52                   	push   %edx
f010240f:	68 c4 62 10 f0       	push   $0xf01062c4
f0102414:	6a 58                	push   $0x58
f0102416:	68 2d 72 10 f0       	push   $0xf010722d
f010241b:	e8 74 dc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102420:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102426:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102429:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	
	for(i=0; i<NPTENTRIES; i++){
		//:/cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
		assert((ptep[i] & PTE_P) == 0);
f010242f:	f6 00 01             	testb  $0x1,(%eax)
f0102432:	74 19                	je     f010244d <mem_init+0xfcd>
f0102434:	68 e3 74 10 f0       	push   $0xf01074e3
f0102439:	68 47 72 10 f0       	push   $0xf0107247
f010243e:	68 09 06 00 00       	push   $0x609
f0102443:	68 21 72 10 f0       	push   $0xf0107221
f0102448:	e8 47 dc ff ff       	call   f0100094 <_panic>
f010244d:	83 c0 04             	add    $0x4,%eax
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	
	for(i=0; i<NPTENTRIES; i++){
f0102450:	39 d0                	cmp    %edx,%eax
f0102452:	75 db                	jne    f010242f <mem_init+0xfaf>
		assert((ptep[i] & PTE_P) == 0);
	}
//here is the error again.
//	for(i = 0;i<NPTENTRIES;i++)
//		cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
	kern_pgdir[0] = 0;
f0102454:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102459:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010245f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102465:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102468:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

	// free the pages we took
	page_free(pp0);
f010246d:	83 ec 0c             	sub    $0xc,%esp
f0102470:	56                   	push   %esi
f0102471:	e8 c1 eb ff ff       	call   f0101037 <page_free>
	page_free(pp1);
f0102476:	89 1c 24             	mov    %ebx,(%esp)
f0102479:	e8 b9 eb ff ff       	call   f0101037 <page_free>
	page_free(pp2);
f010247e:	83 c4 04             	add    $0x4,%esp
f0102481:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102484:	e8 ae eb ff ff       	call   f0101037 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102489:	83 c4 08             	add    $0x8,%esp
f010248c:	68 01 10 00 00       	push   $0x1001
f0102491:	6a 00                	push   $0x0
f0102493:	e8 82 ef ff ff       	call   f010141a <mmio_map_region>
f0102498:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010249a:	83 c4 08             	add    $0x8,%esp
f010249d:	68 00 10 00 00       	push   $0x1000
f01024a2:	6a 00                	push   $0x0
f01024a4:	e8 71 ef ff ff       	call   f010141a <mmio_map_region>
f01024a9:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01024ab:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01024b1:	83 c4 10             	add    $0x10,%esp
f01024b4:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01024ba:	76 07                	jbe    f01024c3 <mem_init+0x1043>
f01024bc:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01024c1:	76 19                	jbe    f01024dc <mem_init+0x105c>
f01024c3:	68 6c 6e 10 f0       	push   $0xf0106e6c
f01024c8:	68 47 72 10 f0       	push   $0xf0107247
f01024cd:	68 1d 06 00 00       	push   $0x61d
f01024d2:	68 21 72 10 f0       	push   $0xf0107221
f01024d7:	e8 b8 db ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01024dc:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024e2:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024e8:	77 08                	ja     f01024f2 <mem_init+0x1072>
f01024ea:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024f0:	77 19                	ja     f010250b <mem_init+0x108b>
f01024f2:	68 94 6e 10 f0       	push   $0xf0106e94
f01024f7:	68 47 72 10 f0       	push   $0xf0107247
f01024fc:	68 1e 06 00 00       	push   $0x61e
f0102501:	68 21 72 10 f0       	push   $0xf0107221
f0102506:	e8 89 db ff ff       	call   f0100094 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010250b:	89 da                	mov    %ebx,%edx
f010250d:	09 f2                	or     %esi,%edx
f010250f:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102515:	74 19                	je     f0102530 <mem_init+0x10b0>
f0102517:	68 bc 6e 10 f0       	push   $0xf0106ebc
f010251c:	68 47 72 10 f0       	push   $0xf0107247
f0102521:	68 20 06 00 00       	push   $0x620
f0102526:	68 21 72 10 f0       	push   $0xf0107221
f010252b:	e8 64 db ff ff       	call   f0100094 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102530:	39 c6                	cmp    %eax,%esi
f0102532:	73 19                	jae    f010254d <mem_init+0x10cd>
f0102534:	68 fa 74 10 f0       	push   $0xf01074fa
f0102539:	68 47 72 10 f0       	push   $0xf0107247
f010253e:	68 22 06 00 00       	push   $0x622
f0102543:	68 21 72 10 f0       	push   $0xf0107221
f0102548:	e8 47 db ff ff       	call   f0100094 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010254d:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102553:	89 da                	mov    %ebx,%edx
f0102555:	89 f8                	mov    %edi,%eax
f0102557:	e8 20 e6 ff ff       	call   f0100b7c <check_va2pa>
f010255c:	85 c0                	test   %eax,%eax
f010255e:	74 19                	je     f0102579 <mem_init+0x10f9>
f0102560:	68 e4 6e 10 f0       	push   $0xf0106ee4
f0102565:	68 47 72 10 f0       	push   $0xf0107247
f010256a:	68 24 06 00 00       	push   $0x624
f010256f:	68 21 72 10 f0       	push   $0xf0107221
f0102574:	e8 1b db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102579:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010257f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102582:	89 c2                	mov    %eax,%edx
f0102584:	89 f8                	mov    %edi,%eax
f0102586:	e8 f1 e5 ff ff       	call   f0100b7c <check_va2pa>
f010258b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102590:	74 19                	je     f01025ab <mem_init+0x112b>
f0102592:	68 08 6f 10 f0       	push   $0xf0106f08
f0102597:	68 47 72 10 f0       	push   $0xf0107247
f010259c:	68 25 06 00 00       	push   $0x625
f01025a1:	68 21 72 10 f0       	push   $0xf0107221
f01025a6:	e8 e9 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01025ab:	89 f2                	mov    %esi,%edx
f01025ad:	89 f8                	mov    %edi,%eax
f01025af:	e8 c8 e5 ff ff       	call   f0100b7c <check_va2pa>
f01025b4:	85 c0                	test   %eax,%eax
f01025b6:	74 19                	je     f01025d1 <mem_init+0x1151>
f01025b8:	68 38 6f 10 f0       	push   $0xf0106f38
f01025bd:	68 47 72 10 f0       	push   $0xf0107247
f01025c2:	68 26 06 00 00       	push   $0x626
f01025c7:	68 21 72 10 f0       	push   $0xf0107221
f01025cc:	e8 c3 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025d1:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01025d7:	89 f8                	mov    %edi,%eax
f01025d9:	e8 9e e5 ff ff       	call   f0100b7c <check_va2pa>
f01025de:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025e1:	74 19                	je     f01025fc <mem_init+0x117c>
f01025e3:	68 5c 6f 10 f0       	push   $0xf0106f5c
f01025e8:	68 47 72 10 f0       	push   $0xf0107247
f01025ed:	68 27 06 00 00       	push   $0x627
f01025f2:	68 21 72 10 f0       	push   $0xf0107221
f01025f7:	e8 98 da ff ff       	call   f0100094 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01025fc:	83 ec 04             	sub    $0x4,%esp
f01025ff:	6a 00                	push   $0x0
f0102601:	53                   	push   %ebx
f0102602:	57                   	push   %edi
f0102603:	e8 10 eb ff ff       	call   f0101118 <pgdir_walk>
f0102608:	83 c4 10             	add    $0x10,%esp
f010260b:	f6 00 1a             	testb  $0x1a,(%eax)
f010260e:	75 19                	jne    f0102629 <mem_init+0x11a9>
f0102610:	68 88 6f 10 f0       	push   $0xf0106f88
f0102615:	68 47 72 10 f0       	push   $0xf0107247
f010261a:	68 29 06 00 00       	push   $0x629
f010261f:	68 21 72 10 f0       	push   $0xf0107221
f0102624:	e8 6b da ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102629:	83 ec 04             	sub    $0x4,%esp
f010262c:	6a 00                	push   $0x0
f010262e:	53                   	push   %ebx
f010262f:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102635:	e8 de ea ff ff       	call   f0101118 <pgdir_walk>
f010263a:	8b 00                	mov    (%eax),%eax
f010263c:	83 c4 10             	add    $0x10,%esp
f010263f:	83 e0 04             	and    $0x4,%eax
f0102642:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102645:	74 19                	je     f0102660 <mem_init+0x11e0>
f0102647:	68 cc 6f 10 f0       	push   $0xf0106fcc
f010264c:	68 47 72 10 f0       	push   $0xf0107247
f0102651:	68 2a 06 00 00       	push   $0x62a
f0102656:	68 21 72 10 f0       	push   $0xf0107221
f010265b:	e8 34 da ff ff       	call   f0100094 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102660:	83 ec 04             	sub    $0x4,%esp
f0102663:	6a 00                	push   $0x0
f0102665:	53                   	push   %ebx
f0102666:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010266c:	e8 a7 ea ff ff       	call   f0101118 <pgdir_walk>
f0102671:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102677:	83 c4 0c             	add    $0xc,%esp
f010267a:	6a 00                	push   $0x0
f010267c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010267f:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102685:	e8 8e ea ff ff       	call   f0101118 <pgdir_walk>
f010268a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102690:	83 c4 0c             	add    $0xc,%esp
f0102693:	6a 00                	push   $0x0
f0102695:	56                   	push   %esi
f0102696:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010269c:	e8 77 ea ff ff       	call   f0101118 <pgdir_walk>
f01026a1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01026a7:	c7 04 24 0c 75 10 f0 	movl   $0xf010750c,(%esp)
f01026ae:	e8 d5 11 00 00       	call   f0103888 <cprintf>
	//I know the meaning of some special 'entry'  and I know the perm is 
	//set to which entry.
	//it is just 4MB to hold the pages so it is perfect we just need
	//one page table,insert to the kern_pgdir.
//here is the new version,npages*4 because one page address occupy 4B?
	boot_map_region(kern_pgdir,UPAGES,0x400000,PADDR(pages),PTE_U|PTE_P|PTE_W);
f01026b3:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026b8:	83 c4 10             	add    $0x10,%esp
f01026bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026c0:	77 15                	ja     f01026d7 <mem_init+0x1257>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026c2:	50                   	push   %eax
f01026c3:	68 e8 62 10 f0       	push   $0xf01062e8
f01026c8:	68 06 01 00 00       	push   $0x106
f01026cd:	68 21 72 10 f0       	push   $0xf0107221
f01026d2:	e8 bd d9 ff ff       	call   f0100094 <_panic>
f01026d7:	83 ec 08             	sub    $0x8,%esp
f01026da:	6a 07                	push   $0x7
f01026dc:	05 00 00 00 10       	add    $0x10000000,%eax
f01026e1:	50                   	push   %eax
f01026e2:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026e7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026ec:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01026f1:	e8 fb ea ff ff       	call   f01011f1 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Pemissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,NENV*sizeof(struct Env),PADDR(envs),PTE_P|PTE_W|PTE_A|PTE_U);
f01026f6:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026fb:	83 c4 10             	add    $0x10,%esp
f01026fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102703:	77 15                	ja     f010271a <mem_init+0x129a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102705:	50                   	push   %eax
f0102706:	68 e8 62 10 f0       	push   $0xf01062e8
f010270b:	68 12 01 00 00       	push   $0x112
f0102710:	68 21 72 10 f0       	push   $0xf0107221
f0102715:	e8 7a d9 ff ff       	call   f0100094 <_panic>
f010271a:	83 ec 08             	sub    $0x8,%esp
f010271d:	6a 27                	push   $0x27
f010271f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102724:	50                   	push   %eax
f0102725:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010272a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010272f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102734:	e8 b8 ea ff ff       	call   f01011f1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102739:	83 c4 10             	add    $0x10,%esp
f010273c:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102741:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102746:	77 15                	ja     f010275d <mem_init+0x12dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102748:	50                   	push   %eax
f0102749:	68 e8 62 10 f0       	push   $0xf01062e8
f010274e:	68 27 01 00 00       	push   $0x127
f0102753:	68 21 72 10 f0       	push   $0xf0107221
f0102758:	e8 37 d9 ff ff       	call   f0100094 <_panic>
	//the second seg is 4M-32K size as the guard page.
	//[KSTACKTOP-KSTKSIZE,KSTACKTOP)is mapped in physical address
	//[KSTACKOP-PTSIZE,KSTACKTOP-KSTKSIZE)is not mapped by physical mem
	//so it will cause fault if we access it.(which is the 'back' means)

	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
f010275d:	83 ec 08             	sub    $0x8,%esp
f0102760:	6a 22                	push   $0x22
f0102762:	68 00 60 11 00       	push   $0x116000
f0102767:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010276c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102771:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102776:	e8 76 ea ff ff       	call   f01011f1 <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
f010277b:	83 c4 08             	add    $0x8,%esp
f010277e:	6a 08                	push   $0x8
f0102780:	68 25 75 10 f0       	push   $0xf0107525
f0102785:	e8 fe 10 00 00       	call   f0103888 <cprintf>
f010278a:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f0102791:	83 c4 10             	add    $0x10,%esp
f0102794:	bb 00 10 23 f0       	mov    $0xf0231000,%ebx
f0102799:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010279e:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01027a4:	77 15                	ja     f01027bb <mem_init+0x133b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027a6:	53                   	push   %ebx
f01027a7:	68 e8 62 10 f0       	push   $0xf01062e8
f01027ac:	68 6e 01 00 00       	push   $0x16e
f01027b1:	68 21 72 10 f0       	push   $0xf0107221
f01027b6:	e8 d9 d8 ff ff       	call   f0100094 <_panic>
	for(int i = 0;i<NCPU;i++){
		uintptr_t kstacktop_i = KSTACKTOP-(i)*(KSTKSIZE+KSTKGAP);	
		boot_map_region(kern_pgdir,kstacktop_i-KSTKSIZE,KSTKSIZE,PADDR(&percpu_kstacks[i]),PTE_P|PTE_W);
f01027bb:	83 ec 08             	sub    $0x8,%esp
f01027be:	6a 03                	push   $0x3
f01027c0:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01027c6:	50                   	push   %eax
f01027c7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027cc:	89 f2                	mov    %esi,%edx
f01027ce:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01027d3:	e8 19 ea ff ff       	call   f01011f1 <boot_map_region>
f01027d8:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01027de:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
	for(int i = 0;i<NCPU;i++){
f01027e4:	83 c4 10             	add    $0x10,%esp
f01027e7:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f01027ec:	39 d8                	cmp    %ebx,%eax
f01027ee:	75 ae                	jne    f010279e <mem_init+0x131e>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	
	boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W|PTE_A);	
f01027f0:	83 ec 08             	sub    $0x8,%esp
f01027f3:	6a 22                	push   $0x22
f01027f5:	6a 00                	push   $0x0
f01027f7:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01027fc:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102801:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102806:	e8 e6 e9 ff ff       	call   f01011f1 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010280b:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102811:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0102816:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102819:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102820:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102825:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE){

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102828:	8b 35 90 fe 22 f0    	mov    0xf022fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010282e:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102831:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f0102834:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102839:	eb 55                	jmp    f0102890 <mem_init+0x1410>

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010283b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102841:	89 f8                	mov    %edi,%eax
f0102843:	e8 34 e3 ff ff       	call   f0100b7c <check_va2pa>
f0102848:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010284f:	77 15                	ja     f0102866 <mem_init+0x13e6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102851:	56                   	push   %esi
f0102852:	68 e8 62 10 f0       	push   $0xf01062e8
f0102857:	68 fb 04 00 00       	push   $0x4fb
f010285c:	68 21 72 10 f0       	push   $0xf0107221
f0102861:	e8 2e d8 ff ff       	call   f0100094 <_panic>
f0102866:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010286d:	39 c2                	cmp    %eax,%edx
f010286f:	74 19                	je     f010288a <mem_init+0x140a>
f0102871:	68 00 70 10 f0       	push   $0xf0107000
f0102876:	68 47 72 10 f0       	push   $0xf0107247
f010287b:	68 fb 04 00 00       	push   $0x4fb
f0102880:	68 21 72 10 f0       	push   $0xf0107221
f0102885:	e8 0a d8 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f010288a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102890:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102893:	77 a6                	ja     f010283b <mem_init+0x13bb>

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102895:	8b 35 44 f2 22 f0    	mov    0xf022f244,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010289b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010289e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028a3:	89 da                	mov    %ebx,%edx
f01028a5:	89 f8                	mov    %edi,%eax
f01028a7:	e8 d0 e2 ff ff       	call   f0100b7c <check_va2pa>
f01028ac:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01028b3:	77 15                	ja     f01028ca <mem_init+0x144a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028b5:	56                   	push   %esi
f01028b6:	68 e8 62 10 f0       	push   $0xf01062e8
f01028bb:	68 01 05 00 00       	push   $0x501
f01028c0:	68 21 72 10 f0       	push   $0xf0107221
f01028c5:	e8 ca d7 ff ff       	call   f0100094 <_panic>
f01028ca:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01028d1:	39 d0                	cmp    %edx,%eax
f01028d3:	74 19                	je     f01028ee <mem_init+0x146e>
f01028d5:	68 34 70 10 f0       	push   $0xf0107034
f01028da:	68 47 72 10 f0       	push   $0xf0107247
f01028df:	68 01 05 00 00       	push   $0x501
f01028e4:	68 21 72 10 f0       	push   $0xf0107221
f01028e9:	e8 a6 d7 ff ff       	call   f0100094 <_panic>
f01028ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f01028f4:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028fa:	75 a7                	jne    f01028a3 <mem_init+0x1423>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f01028fc:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01028ff:	c1 e6 0c             	shl    $0xc,%esi
f0102902:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102907:	eb 30                	jmp    f0102939 <mem_init+0x14b9>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102909:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010290f:	89 f8                	mov    %edi,%eax
f0102911:	e8 66 e2 ff ff       	call   f0100b7c <check_va2pa>
f0102916:	39 c3                	cmp    %eax,%ebx
f0102918:	74 19                	je     f0102933 <mem_init+0x14b3>
f010291a:	68 68 70 10 f0       	push   $0xf0107068
f010291f:	68 47 72 10 f0       	push   $0xf0107247
f0102924:	68 07 05 00 00       	push   $0x507
f0102929:	68 21 72 10 f0       	push   $0xf0107221
f010292e:	e8 61 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0102933:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102939:	39 f3                	cmp    %esi,%ebx
f010293b:	72 cc                	jb     f0102909 <mem_init+0x1489>
f010293d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102942:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102945:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102948:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010294b:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102951:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102954:	89 c3                	mov    %eax,%ebx
	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102956:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102959:	05 00 80 00 20       	add    $0x20008000,%eax
f010295e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102961:	89 da                	mov    %ebx,%edx
f0102963:	89 f8                	mov    %edi,%eax
f0102965:	e8 12 e2 ff ff       	call   f0100b7c <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010296a:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102970:	77 15                	ja     f0102987 <mem_init+0x1507>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102972:	56                   	push   %esi
f0102973:	68 e8 62 10 f0       	push   $0xf01062e8
f0102978:	68 12 05 00 00       	push   $0x512
f010297d:	68 21 72 10 f0       	push   $0xf0107221
f0102982:	e8 0d d7 ff ff       	call   f0100094 <_panic>
f0102987:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010298a:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f0102991:	39 d0                	cmp    %edx,%eax
f0102993:	74 19                	je     f01029ae <mem_init+0x152e>
f0102995:	68 90 70 10 f0       	push   $0xf0107090
f010299a:	68 47 72 10 f0       	push   $0xf0107247
f010299f:	68 12 05 00 00       	push   $0x512
f01029a4:	68 21 72 10 f0       	push   $0xf0107221
f01029a9:	e8 e6 d6 ff ff       	call   f0100094 <_panic>
f01029ae:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029b4:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f01029b7:	75 a8                	jne    f0102961 <mem_init+0x14e1>
f01029b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029bc:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01029c2:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029c5:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029c7:	89 da                	mov    %ebx,%edx
f01029c9:	89 f8                	mov    %edi,%eax
f01029cb:	e8 ac e1 ff ff       	call   f0100b7c <check_va2pa>
f01029d0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029d3:	74 19                	je     f01029ee <mem_init+0x156e>
f01029d5:	68 d8 70 10 f0       	push   $0xf01070d8
f01029da:	68 47 72 10 f0       	push   $0xf0107247
f01029df:	68 14 05 00 00       	push   $0x514
f01029e4:	68 21 72 10 f0       	push   $0xf0107221
f01029e9:	e8 a6 d6 ff ff       	call   f0100094 <_panic>
f01029ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029f4:	39 f3                	cmp    %esi,%ebx
f01029f6:	75 cf                	jne    f01029c7 <mem_init+0x1547>
f01029f8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01029fb:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102a02:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102a09:	81 c6 00 80 00 00    	add    $0x8000,%esi

	// check kernel stack

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
f0102a0f:	b8 00 10 27 f0       	mov    $0xf0271000,%eax
f0102a14:	39 f0                	cmp    %esi,%eax
f0102a16:	0f 85 2c ff ff ff    	jne    f0102948 <mem_init+0x14c8>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a1c:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a21:	89 f8                	mov    %edi,%eax
f0102a23:	e8 54 e1 ff ff       	call   f0100b7c <check_va2pa>
f0102a28:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a2b:	74 47                	je     f0102a74 <mem_init+0x15f4>
f0102a2d:	68 fc 70 10 f0       	push   $0xf01070fc
f0102a32:	68 47 72 10 f0       	push   $0xf0107247
f0102a37:	68 1e 05 00 00       	push   $0x51e
f0102a3c:	68 21 72 10 f0       	push   $0xf0107221
f0102a41:	e8 4e d6 ff ff       	call   f0100094 <_panic>


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a46:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a4c:	83 fa 04             	cmp    $0x4,%edx
f0102a4f:	77 28                	ja     f0102a79 <mem_init+0x15f9>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a51:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a55:	0f 85 83 00 00 00    	jne    f0102ade <mem_init+0x165e>
f0102a5b:	68 2e 75 10 f0       	push   $0xf010752e
f0102a60:	68 47 72 10 f0       	push   $0xf0107247
f0102a65:	68 29 05 00 00       	push   $0x529
f0102a6a:	68 21 72 10 f0       	push   $0xf0107221
f0102a6f:	e8 20 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a74:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a79:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a7e:	76 3f                	jbe    f0102abf <mem_init+0x163f>
				assert(pgdir[i] & PTE_P);
f0102a80:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a83:	f6 c2 01             	test   $0x1,%dl
f0102a86:	75 19                	jne    f0102aa1 <mem_init+0x1621>
f0102a88:	68 2e 75 10 f0       	push   $0xf010752e
f0102a8d:	68 47 72 10 f0       	push   $0xf0107247
f0102a92:	68 2d 05 00 00       	push   $0x52d
f0102a97:	68 21 72 10 f0       	push   $0xf0107221
f0102a9c:	e8 f3 d5 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102aa1:	f6 c2 02             	test   $0x2,%dl
f0102aa4:	75 38                	jne    f0102ade <mem_init+0x165e>
f0102aa6:	68 3f 75 10 f0       	push   $0xf010753f
f0102aab:	68 47 72 10 f0       	push   $0xf0107247
f0102ab0:	68 2e 05 00 00       	push   $0x52e
f0102ab5:	68 21 72 10 f0       	push   $0xf0107221
f0102aba:	e8 d5 d5 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102abf:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102ac3:	74 19                	je     f0102ade <mem_init+0x165e>
f0102ac5:	68 50 75 10 f0       	push   $0xf0107550
f0102aca:	68 47 72 10 f0       	push   $0xf0107247
f0102acf:	68 30 05 00 00       	push   $0x530
f0102ad4:	68 21 72 10 f0       	push   $0xf0107221
f0102ad9:	e8 b6 d5 ff ff       	call   f0100094 <_panic>
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102ade:	83 c0 01             	add    $0x1,%eax
f0102ae1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ae6:	0f 86 5a ff ff ff    	jbe    f0102a46 <mem_init+0x15c6>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102aec:	83 ec 0c             	sub    $0xc,%esp
f0102aef:	68 2c 71 10 f0       	push   $0xf010712c
f0102af4:	e8 8f 0d 00 00       	call   f0103888 <cprintf>
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.

	lcr3(PADDR(kern_pgdir));
f0102af9:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102afe:	83 c4 10             	add    $0x10,%esp
f0102b01:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b06:	77 15                	ja     f0102b1d <mem_init+0x169d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b08:	50                   	push   %eax
f0102b09:	68 e8 62 10 f0       	push   $0xf01062e8
f0102b0e:	68 43 01 00 00       	push   $0x143
f0102b13:	68 21 72 10 f0       	push   $0xf0107221
f0102b18:	e8 77 d5 ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b1d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b22:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b25:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b2a:	e8 b1 e0 ff ff       	call   f0100be0 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b2f:	0f 20 c0             	mov    %cr0,%eax
f0102b32:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b35:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b3a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b3d:	83 ec 0c             	sub    $0xc,%esp
f0102b40:	6a 00                	push   $0x0
f0102b42:	e8 37 e4 ff ff       	call   f0100f7e <page_alloc>
f0102b47:	89 c3                	mov    %eax,%ebx
f0102b49:	83 c4 10             	add    $0x10,%esp
f0102b4c:	85 c0                	test   %eax,%eax
f0102b4e:	75 19                	jne    f0102b69 <mem_init+0x16e9>
f0102b50:	68 31 73 10 f0       	push   $0xf0107331
f0102b55:	68 47 72 10 f0       	push   $0xf0107247
f0102b5a:	68 3f 06 00 00       	push   $0x63f
f0102b5f:	68 21 72 10 f0       	push   $0xf0107221
f0102b64:	e8 2b d5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b69:	83 ec 0c             	sub    $0xc,%esp
f0102b6c:	6a 00                	push   $0x0
f0102b6e:	e8 0b e4 ff ff       	call   f0100f7e <page_alloc>
f0102b73:	89 c7                	mov    %eax,%edi
f0102b75:	83 c4 10             	add    $0x10,%esp
f0102b78:	85 c0                	test   %eax,%eax
f0102b7a:	75 19                	jne    f0102b95 <mem_init+0x1715>
f0102b7c:	68 47 73 10 f0       	push   $0xf0107347
f0102b81:	68 47 72 10 f0       	push   $0xf0107247
f0102b86:	68 40 06 00 00       	push   $0x640
f0102b8b:	68 21 72 10 f0       	push   $0xf0107221
f0102b90:	e8 ff d4 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b95:	83 ec 0c             	sub    $0xc,%esp
f0102b98:	6a 00                	push   $0x0
f0102b9a:	e8 df e3 ff ff       	call   f0100f7e <page_alloc>
f0102b9f:	89 c6                	mov    %eax,%esi
f0102ba1:	83 c4 10             	add    $0x10,%esp
f0102ba4:	85 c0                	test   %eax,%eax
f0102ba6:	75 19                	jne    f0102bc1 <mem_init+0x1741>
f0102ba8:	68 5d 73 10 f0       	push   $0xf010735d
f0102bad:	68 47 72 10 f0       	push   $0xf0107247
f0102bb2:	68 41 06 00 00       	push   $0x641
f0102bb7:	68 21 72 10 f0       	push   $0xf0107221
f0102bbc:	e8 d3 d4 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102bc1:	83 ec 0c             	sub    $0xc,%esp
f0102bc4:	53                   	push   %ebx
f0102bc5:	e8 6d e4 ff ff       	call   f0101037 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bca:	89 f8                	mov    %edi,%eax
f0102bcc:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102bd2:	c1 f8 03             	sar    $0x3,%eax
f0102bd5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bd8:	89 c2                	mov    %eax,%edx
f0102bda:	c1 ea 0c             	shr    $0xc,%edx
f0102bdd:	83 c4 10             	add    $0x10,%esp
f0102be0:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102be6:	72 12                	jb     f0102bfa <mem_init+0x177a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102be8:	50                   	push   %eax
f0102be9:	68 c4 62 10 f0       	push   $0xf01062c4
f0102bee:	6a 58                	push   $0x58
f0102bf0:	68 2d 72 10 f0       	push   $0xf010722d
f0102bf5:	e8 9a d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bfa:	83 ec 04             	sub    $0x4,%esp
f0102bfd:	68 00 10 00 00       	push   $0x1000
f0102c02:	6a 01                	push   $0x1
f0102c04:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c09:	50                   	push   %eax
f0102c0a:	e8 32 29 00 00       	call   f0105541 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c0f:	89 f0                	mov    %esi,%eax
f0102c11:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102c17:	c1 f8 03             	sar    $0x3,%eax
f0102c1a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c1d:	89 c2                	mov    %eax,%edx
f0102c1f:	c1 ea 0c             	shr    $0xc,%edx
f0102c22:	83 c4 10             	add    $0x10,%esp
f0102c25:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c2b:	72 12                	jb     f0102c3f <mem_init+0x17bf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c2d:	50                   	push   %eax
f0102c2e:	68 c4 62 10 f0       	push   $0xf01062c4
f0102c33:	6a 58                	push   $0x58
f0102c35:	68 2d 72 10 f0       	push   $0xf010722d
f0102c3a:	e8 55 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c3f:	83 ec 04             	sub    $0x4,%esp
f0102c42:	68 00 10 00 00       	push   $0x1000
f0102c47:	6a 02                	push   $0x2
f0102c49:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c4e:	50                   	push   %eax
f0102c4f:	e8 ed 28 00 00       	call   f0105541 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c54:	6a 02                	push   $0x2
f0102c56:	68 00 10 00 00       	push   $0x1000
f0102c5b:	57                   	push   %edi
f0102c5c:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102c62:	e8 06 e7 ff ff       	call   f010136d <page_insert>
	assert(pp1->pp_ref == 1);
f0102c67:	83 c4 20             	add    $0x20,%esp
f0102c6a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c6f:	74 19                	je     f0102c8a <mem_init+0x180a>
f0102c71:	68 2e 74 10 f0       	push   $0xf010742e
f0102c76:	68 47 72 10 f0       	push   $0xf0107247
f0102c7b:	68 46 06 00 00       	push   $0x646
f0102c80:	68 21 72 10 f0       	push   $0xf0107221
f0102c85:	e8 0a d4 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c8a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c91:	01 01 01 
f0102c94:	74 19                	je     f0102caf <mem_init+0x182f>
f0102c96:	68 4c 71 10 f0       	push   $0xf010714c
f0102c9b:	68 47 72 10 f0       	push   $0xf0107247
f0102ca0:	68 47 06 00 00       	push   $0x647
f0102ca5:	68 21 72 10 f0       	push   $0xf0107221
f0102caa:	e8 e5 d3 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102caf:	6a 02                	push   $0x2
f0102cb1:	68 00 10 00 00       	push   $0x1000
f0102cb6:	56                   	push   %esi
f0102cb7:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102cbd:	e8 ab e6 ff ff       	call   f010136d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cc2:	83 c4 10             	add    $0x10,%esp
f0102cc5:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102ccc:	02 02 02 
f0102ccf:	74 19                	je     f0102cea <mem_init+0x186a>
f0102cd1:	68 70 71 10 f0       	push   $0xf0107170
f0102cd6:	68 47 72 10 f0       	push   $0xf0107247
f0102cdb:	68 49 06 00 00       	push   $0x649
f0102ce0:	68 21 72 10 f0       	push   $0xf0107221
f0102ce5:	e8 aa d3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102cea:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cef:	74 19                	je     f0102d0a <mem_init+0x188a>
f0102cf1:	68 50 74 10 f0       	push   $0xf0107450
f0102cf6:	68 47 72 10 f0       	push   $0xf0107247
f0102cfb:	68 4a 06 00 00       	push   $0x64a
f0102d00:	68 21 72 10 f0       	push   $0xf0107221
f0102d05:	e8 8a d3 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102d0a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d0f:	74 19                	je     f0102d2a <mem_init+0x18aa>
f0102d11:	68 ba 74 10 f0       	push   $0xf01074ba
f0102d16:	68 47 72 10 f0       	push   $0xf0107247
f0102d1b:	68 4b 06 00 00       	push   $0x64b
f0102d20:	68 21 72 10 f0       	push   $0xf0107221
f0102d25:	e8 6a d3 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d2a:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d31:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d34:	89 f0                	mov    %esi,%eax
f0102d36:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102d3c:	c1 f8 03             	sar    $0x3,%eax
f0102d3f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d42:	89 c2                	mov    %eax,%edx
f0102d44:	c1 ea 0c             	shr    $0xc,%edx
f0102d47:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102d4d:	72 12                	jb     f0102d61 <mem_init+0x18e1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d4f:	50                   	push   %eax
f0102d50:	68 c4 62 10 f0       	push   $0xf01062c4
f0102d55:	6a 58                	push   $0x58
f0102d57:	68 2d 72 10 f0       	push   $0xf010722d
f0102d5c:	e8 33 d3 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d61:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d68:	03 03 03 
f0102d6b:	74 19                	je     f0102d86 <mem_init+0x1906>
f0102d6d:	68 94 71 10 f0       	push   $0xf0107194
f0102d72:	68 47 72 10 f0       	push   $0xf0107247
f0102d77:	68 4d 06 00 00       	push   $0x64d
f0102d7c:	68 21 72 10 f0       	push   $0xf0107221
f0102d81:	e8 0e d3 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d86:	83 ec 08             	sub    $0x8,%esp
f0102d89:	68 00 10 00 00       	push   $0x1000
f0102d8e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102d94:	e8 8e e5 ff ff       	call   f0101327 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d99:	83 c4 10             	add    $0x10,%esp
f0102d9c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102da1:	74 19                	je     f0102dbc <mem_init+0x193c>
f0102da3:	68 88 74 10 f0       	push   $0xf0107488
f0102da8:	68 47 72 10 f0       	push   $0xf0107247
f0102dad:	68 4f 06 00 00       	push   $0x64f
f0102db2:	68 21 72 10 f0       	push   $0xf0107221
f0102db7:	e8 d8 d2 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dbc:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102dc2:	8b 11                	mov    (%ecx),%edx
f0102dc4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102dca:	89 d8                	mov    %ebx,%eax
f0102dcc:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102dd2:	c1 f8 03             	sar    $0x3,%eax
f0102dd5:	c1 e0 0c             	shl    $0xc,%eax
f0102dd8:	39 c2                	cmp    %eax,%edx
f0102dda:	74 19                	je     f0102df5 <mem_init+0x1975>
f0102ddc:	68 ec 6a 10 f0       	push   $0xf0106aec
f0102de1:	68 47 72 10 f0       	push   $0xf0107247
f0102de6:	68 52 06 00 00       	push   $0x652
f0102deb:	68 21 72 10 f0       	push   $0xf0107221
f0102df0:	e8 9f d2 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102df5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102dfb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e00:	74 19                	je     f0102e1b <mem_init+0x199b>
f0102e02:	68 3f 74 10 f0       	push   $0xf010743f
f0102e07:	68 47 72 10 f0       	push   $0xf0107247
f0102e0c:	68 54 06 00 00       	push   $0x654
f0102e11:	68 21 72 10 f0       	push   $0xf0107221
f0102e16:	e8 79 d2 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102e1b:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e21:	83 ec 0c             	sub    $0xc,%esp
f0102e24:	53                   	push   %ebx
f0102e25:	e8 0d e2 ff ff       	call   f0101037 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e2a:	c7 04 24 c0 71 10 f0 	movl   $0xf01071c0,(%esp)
f0102e31:	e8 52 0a 00 00       	call   f0103888 <cprintf>
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
	//cprintf("here I put out the tag.\n");
}
f0102e36:	83 c4 10             	add    $0x10,%esp
f0102e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e3c:	5b                   	pop    %ebx
f0102e3d:	5e                   	pop    %esi
f0102e3e:	5f                   	pop    %edi
f0102e3f:	5d                   	pop    %ebp
f0102e40:	c3                   	ret    

f0102e41 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e41:	55                   	push   %ebp
f0102e42:	89 e5                	mov    %esp,%ebp
f0102e44:	57                   	push   %edi
f0102e45:	56                   	push   %esi
f0102e46:	53                   	push   %ebx
f0102e47:	83 ec 1c             	sub    $0x1c,%esp
f0102e4a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e4d:	8b 75 14             	mov    0x14(%ebp),%esi
	//the code is very bad written by myself.
	*/


	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102e50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e53:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102e59:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e5c:	03 45 10             	add    0x10(%ebp),%eax
f0102e5f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102e64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102e6c:	eb 43                	jmp    f0102eb1 <user_mem_check+0x70>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102e6e:	83 ec 04             	sub    $0x4,%esp
f0102e71:	6a 00                	push   $0x0
f0102e73:	53                   	push   %ebx
f0102e74:	ff 77 60             	pushl  0x60(%edi)
f0102e77:	e8 9c e2 ff ff       	call   f0101118 <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102e7c:	83 c4 10             	add    $0x10,%esp
f0102e7f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e85:	77 10                	ja     f0102e97 <user_mem_check+0x56>
f0102e87:	85 c0                	test   %eax,%eax
f0102e89:	74 0c                	je     f0102e97 <user_mem_check+0x56>
f0102e8b:	8b 00                	mov    (%eax),%eax
f0102e8d:	a8 01                	test   $0x1,%al
f0102e8f:	74 06                	je     f0102e97 <user_mem_check+0x56>
f0102e91:	21 f0                	and    %esi,%eax
f0102e93:	39 c6                	cmp    %eax,%esi
f0102e95:	74 14                	je     f0102eab <user_mem_check+0x6a>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102e97:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e9a:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102e9e:	89 1d 3c f2 22 f0    	mov    %ebx,0xf022f23c
			return -E_FAULT;
f0102ea4:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102ea9:	eb 10                	jmp    f0102ebb <user_mem_check+0x7a>

	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102eab:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102eb1:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102eb4:	72 b8                	jb     f0102e6e <user_mem_check+0x2d>
			return -E_FAULT;
		}
	}

//	cprintf("user_mem_check success va: %x, len: %x\n", va, len);	
	return 0;
f0102eb6:	b8 00 00 00 00       	mov    $0x0,%eax


}
f0102ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ebe:	5b                   	pop    %ebx
f0102ebf:	5e                   	pop    %esi
f0102ec0:	5f                   	pop    %edi
f0102ec1:	5d                   	pop    %ebp
f0102ec2:	c3                   	ret    

f0102ec3 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102ec3:	55                   	push   %ebp
f0102ec4:	89 e5                	mov    %esp,%ebp
f0102ec6:	53                   	push   %ebx
f0102ec7:	83 ec 04             	sub    $0x4,%esp
f0102eca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102ecd:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ed0:	83 c8 04             	or     $0x4,%eax
f0102ed3:	50                   	push   %eax
f0102ed4:	ff 75 10             	pushl  0x10(%ebp)
f0102ed7:	ff 75 0c             	pushl  0xc(%ebp)
f0102eda:	53                   	push   %ebx
f0102edb:	e8 61 ff ff ff       	call   f0102e41 <user_mem_check>
f0102ee0:	83 c4 10             	add    $0x10,%esp
f0102ee3:	85 c0                	test   %eax,%eax
f0102ee5:	79 21                	jns    f0102f08 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102ee7:	83 ec 04             	sub    $0x4,%esp
f0102eea:	ff 35 3c f2 22 f0    	pushl  0xf022f23c
f0102ef0:	ff 73 48             	pushl  0x48(%ebx)
f0102ef3:	68 ec 71 10 f0       	push   $0xf01071ec
f0102ef8:	e8 8b 09 00 00       	call   f0103888 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102efd:	89 1c 24             	mov    %ebx,(%esp)
f0102f00:	e8 c6 06 00 00       	call   f01035cb <env_destroy>
f0102f05:	83 c4 10             	add    $0x10,%esp
	}
}
f0102f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f0b:	c9                   	leave  
f0102f0c:	c3                   	ret    

f0102f0d <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f0d:	55                   	push   %ebp
f0102f0e:	89 e5                	mov    %esp,%ebp
f0102f10:	57                   	push   %edi
f0102f11:	56                   	push   %esi
f0102f12:	53                   	push   %ebx
f0102f13:	83 ec 0c             	sub    $0xc,%esp
f0102f16:	89 c7                	mov    %eax,%edi
		va+=PGSIZE;
	}
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
f0102f18:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102f1e:	89 d6                	mov    %edx,%esi
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
f0102f20:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0102f26:	25 ff 0f 00 00       	and    $0xfff,%eax
f0102f2b:	8d 99 ff 1f 00 00    	lea    0x1fff(%ecx),%ebx
f0102f31:	29 c3                	sub    %eax,%ebx
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f33:	eb 5e                	jmp    f0102f93 <region_alloc+0x86>
	{
		pp = page_alloc(0);
f0102f35:	83 ec 0c             	sub    $0xc,%esp
f0102f38:	6a 00                	push   $0x0
f0102f3a:	e8 3f e0 ff ff       	call   f0100f7e <page_alloc>
 
		if(!pp)
f0102f3f:	83 c4 10             	add    $0x10,%esp
f0102f42:	85 c0                	test   %eax,%eax
f0102f44:	75 17                	jne    f0102f5d <region_alloc+0x50>
		{
			panic("region_alloc failed!\n");
f0102f46:	83 ec 04             	sub    $0x4,%esp
f0102f49:	68 5e 75 10 f0       	push   $0xf010755e
f0102f4e:	68 51 01 00 00       	push   $0x151
f0102f53:	68 74 75 10 f0       	push   $0xf0107574
f0102f58:	e8 37 d1 ff ff       	call   f0100094 <_panic>
		}
		ret = page_insert(e->env_pgdir,pp,va,PTE_U|PTE_W|PTE_P);
f0102f5d:	6a 07                	push   $0x7
f0102f5f:	56                   	push   %esi
f0102f60:	50                   	push   %eax
f0102f61:	ff 77 60             	pushl  0x60(%edi)
f0102f64:	e8 04 e4 ff ff       	call   f010136d <page_insert>
 
		if(ret)
f0102f69:	83 c4 10             	add    $0x10,%esp
f0102f6c:	85 c0                	test   %eax,%eax
f0102f6e:	74 17                	je     f0102f87 <region_alloc+0x7a>
		{
			panic("region_alloc failed!\n");
f0102f70:	83 ec 04             	sub    $0x4,%esp
f0102f73:	68 5e 75 10 f0       	push   $0xf010755e
f0102f78:	68 57 01 00 00       	push   $0x157
f0102f7d:	68 74 75 10 f0       	push   $0xf0107574
f0102f82:	e8 0d d1 ff ff       	call   f0100094 <_panic>
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f87:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
f0102f8d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f93:	85 db                	test   %ebx,%ebx
f0102f95:	75 9e                	jne    f0102f35 <region_alloc+0x28>
			panic("region_alloc failed!\n");
		}
	}


}
f0102f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f9a:	5b                   	pop    %ebx
f0102f9b:	5e                   	pop    %esi
f0102f9c:	5f                   	pop    %edi
f0102f9d:	5d                   	pop    %ebp
f0102f9e:	c3                   	ret    

f0102f9f <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f9f:	55                   	push   %ebp
f0102fa0:	89 e5                	mov    %esp,%ebp
f0102fa2:	56                   	push   %esi
f0102fa3:	53                   	push   %ebx
f0102fa4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fa7:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102faa:	85 c0                	test   %eax,%eax
f0102fac:	75 1d                	jne    f0102fcb <envid2env+0x2c>
		*env_store = curenv;
f0102fae:	e8 af 2b 00 00       	call   f0105b62 <cpunum>
f0102fb3:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fb6:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0102fbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fbf:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fc1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fc6:	e9 84 00 00 00       	jmp    f010304f <envid2env+0xb0>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102fcb:	89 c3                	mov    %eax,%ebx
f0102fcd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fd3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fd6:	03 1d 44 f2 22 f0    	add    0xf022f244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fdc:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102fe0:	74 05                	je     f0102fe7 <envid2env+0x48>
f0102fe2:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102fe5:	74 24                	je     f010300b <envid2env+0x6c>
		cprintf("we are at e->env_id:%d == envid:%d\n",e->env_id,envid);
f0102fe7:	83 ec 04             	sub    $0x4,%esp
f0102fea:	50                   	push   %eax
f0102feb:	ff 73 48             	pushl  0x48(%ebx)
f0102fee:	68 f8 75 10 f0       	push   $0xf01075f8
f0102ff3:	e8 90 08 00 00       	call   f0103888 <cprintf>
		*env_store = 0;
f0102ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ffb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103001:	83 c4 10             	add    $0x10,%esp
f0103004:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103009:	eb 44                	jmp    f010304f <envid2env+0xb0>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010300b:	84 d2                	test   %dl,%dl
f010300d:	74 36                	je     f0103045 <envid2env+0xa6>
f010300f:	e8 4e 2b 00 00       	call   f0105b62 <cpunum>
f0103014:	6b c0 74             	imul   $0x74,%eax,%eax
f0103017:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f010301d:	74 26                	je     f0103045 <envid2env+0xa6>
f010301f:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103022:	e8 3b 2b 00 00       	call   f0105b62 <cpunum>
f0103027:	6b c0 74             	imul   $0x74,%eax,%eax
f010302a:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103030:	3b 70 48             	cmp    0x48(%eax),%esi
f0103033:	74 10                	je     f0103045 <envid2env+0xa6>
		*env_store = 0;
f0103035:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103038:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010303e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103043:	eb 0a                	jmp    f010304f <envid2env+0xb0>
	}

	*env_store = e;
f0103045:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103048:	89 18                	mov    %ebx,(%eax)
	return 0;
f010304a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010304f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103052:	5b                   	pop    %ebx
f0103053:	5e                   	pop    %esi
f0103054:	5d                   	pop    %ebp
f0103055:	c3                   	ret    

f0103056 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103056:	55                   	push   %ebp
f0103057:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103059:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f010305e:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103061:	b8 23 00 00 00       	mov    $0x23,%eax
f0103066:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103068:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010306a:	b8 10 00 00 00       	mov    $0x10,%eax
f010306f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103071:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103073:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103075:	ea 7c 30 10 f0 08 00 	ljmp   $0x8,$0xf010307c
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010307c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103081:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103084:	5d                   	pop    %ebp
f0103085:	c3                   	ret    

f0103086 <env_init>:
};
*/

void
env_init(void)
{
f0103086:	55                   	push   %ebp
f0103087:	89 e5                	mov    %esp,%ebp
f0103089:	56                   	push   %esi
f010308a:	53                   	push   %ebx
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
	{
		envs[temp].env_id = 0;
f010308b:	8b 35 44 f2 22 f0    	mov    0xf022f244,%esi
f0103091:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103097:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f010309a:	ba 00 00 00 00       	mov    $0x0,%edx
f010309f:	89 c1                	mov    %eax,%ecx
f01030a1:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[temp].env_parent_id = 0;
f01030a8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		envs[temp].env_type = ENV_TYPE_USER;
f01030af:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		envs[temp].env_status = 0;
f01030b6:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[temp].env_runs = 0;
f01030bd:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
		envs[temp].env_pgdir = NULL;
f01030c4:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
		envs[temp].env_link = env_free_list;
f01030cb:	89 50 44             	mov    %edx,0x44(%eax)
f01030ce:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[temp];
f01030d1:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
f01030d3:	39 d8                	cmp    %ebx,%eax
f01030d5:	75 c8                	jne    f010309f <env_init+0x19>
f01030d7:	89 35 48 f2 22 f0    	mov    %esi,0xf022f248
		envs[temp].env_pgdir = NULL;
		envs[temp].env_link = env_free_list;
		env_free_list = &envs[temp];
	}
 
	cprintf("env_free_list : 0x%08x, &envs[temp]: 0x%08x\n",env_free_list,&envs[temp]);
f01030dd:	83 ec 04             	sub    $0x4,%esp
f01030e0:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f01030e5:	83 e8 7c             	sub    $0x7c,%eax
f01030e8:	50                   	push   %eax
f01030e9:	56                   	push   %esi
f01030ea:	68 1c 76 10 f0       	push   $0xf010761c
f01030ef:	e8 94 07 00 00       	call   f0103888 <cprintf>
 

	// Per-CPU part of the initialization
	env_init_percpu();
f01030f4:	e8 5d ff ff ff       	call   f0103056 <env_init_percpu>
}
f01030f9:	83 c4 10             	add    $0x10,%esp
f01030fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030ff:	5b                   	pop    %ebx
f0103100:	5e                   	pop    %esi
f0103101:	5d                   	pop    %ebp
f0103102:	c3                   	ret    

f0103103 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103103:	55                   	push   %ebp
f0103104:	89 e5                	mov    %esp,%ebp
f0103106:	57                   	push   %edi
f0103107:	56                   	push   %esi
f0103108:	53                   	push   %ebx
f0103109:	83 ec 0c             	sub    $0xc,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010310c:	8b 1d 48 f2 22 f0    	mov    0xf022f248,%ebx
f0103112:	85 db                	test   %ebx,%ebx
f0103114:	0f 84 5d 01 00 00    	je     f0103277 <env_alloc+0x174>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010311a:	83 ec 0c             	sub    $0xc,%esp
f010311d:	6a 01                	push   $0x1
f010311f:	e8 5a de ff ff       	call   f0100f7e <page_alloc>
f0103124:	83 c4 10             	add    $0x10,%esp
f0103127:	85 c0                	test   %eax,%eax
f0103129:	0f 84 4f 01 00 00    	je     f010327e <env_alloc+0x17b>

	
	// LAB 3: Your code here.

	//!copy from web ,just to know how it runs.
	(p->pp_ref)++;
f010312f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103134:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010313a:	89 c6                	mov    %eax,%esi
f010313c:	c1 fe 03             	sar    $0x3,%esi
f010313f:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103142:	89 f0                	mov    %esi,%eax
f0103144:	c1 e8 0c             	shr    $0xc,%eax
f0103147:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010314d:	72 12                	jb     f0103161 <env_alloc+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010314f:	56                   	push   %esi
f0103150:	68 c4 62 10 f0       	push   $0xf01062c4
f0103155:	6a 58                	push   $0x58
f0103157:	68 2d 72 10 f0       	push   $0xf010722d
f010315c:	e8 33 cf ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0103161:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
        pde_t* page_dir = page2kva(p);
	memcpy(page_dir,kern_pgdir,PGSIZE);
f0103167:	83 ec 04             	sub    $0x4,%esp
f010316a:	68 00 10 00 00       	push   $0x1000
f010316f:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0103175:	57                   	push   %edi
f0103176:	e8 7b 24 00 00       	call   f01055f6 <memcpy>
	e->env_pgdir = page_dir;
f010317b:	89 7b 60             	mov    %edi,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010317e:	83 c4 10             	add    $0x10,%esp
f0103181:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0103187:	77 15                	ja     f010319e <env_alloc+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103189:	57                   	push   %edi
f010318a:	68 e8 62 10 f0       	push   $0xf01062e8
f010318f:	68 e5 00 00 00       	push   $0xe5
f0103194:	68 74 75 10 f0       	push   $0xf0107574
f0103199:	e8 f6 ce ff ff       	call   f0100094 <_panic>
	
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010319e:	83 ce 05             	or     $0x5,%esi
f01031a1:	89 b7 f4 0e 00 00    	mov    %esi,0xef4(%edi)

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01031a7:	8b 43 48             	mov    0x48(%ebx),%eax
f01031aa:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031af:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031b4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031b9:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031bc:	89 da                	mov    %ebx,%edx
f01031be:	2b 15 44 f2 22 f0    	sub    0xf022f244,%edx
f01031c4:	c1 fa 02             	sar    $0x2,%edx
f01031c7:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031cd:	09 d0                	or     %edx,%eax
f01031cf:	89 43 48             	mov    %eax,0x48(%ebx)
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031d5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031d8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031df:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031e6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031ed:	83 ec 04             	sub    $0x4,%esp
f01031f0:	6a 44                	push   $0x44
f01031f2:	6a 00                	push   $0x0
f01031f4:	53                   	push   %ebx
f01031f5:	e8 47 23 00 00       	call   f0105541 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031fa:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103200:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103206:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010320c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103213:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= 0;//FL_IF;
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103219:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103220:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103224:	8b 43 44             	mov    0x44(%ebx),%eax
f0103227:	a3 48 f2 22 f0       	mov    %eax,0xf022f248
	*newenv_store = e;
f010322c:	8b 45 08             	mov    0x8(%ebp),%eax
f010322f:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103231:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103234:	e8 29 29 00 00       	call   f0105b62 <cpunum>
f0103239:	6b c0 74             	imul   $0x74,%eax,%eax
f010323c:	83 c4 10             	add    $0x10,%esp
f010323f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103244:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010324b:	74 11                	je     f010325e <env_alloc+0x15b>
f010324d:	e8 10 29 00 00       	call   f0105b62 <cpunum>
f0103252:	6b c0 74             	imul   $0x74,%eax,%eax
f0103255:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010325b:	8b 50 48             	mov    0x48(%eax),%edx
f010325e:	83 ec 04             	sub    $0x4,%esp
f0103261:	53                   	push   %ebx
f0103262:	52                   	push   %edx
f0103263:	68 7f 75 10 f0       	push   $0xf010757f
f0103268:	e8 1b 06 00 00       	call   f0103888 <cprintf>
	return 0;
f010326d:	83 c4 10             	add    $0x10,%esp
f0103270:	b8 00 00 00 00       	mov    $0x0,%eax
f0103275:	eb 0c                	jmp    f0103283 <env_alloc+0x180>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103277:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010327c:	eb 05                	jmp    f0103283 <env_alloc+0x180>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010327e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// commit the allocation
	env_free_list = e->env_link;
	*newenv_store = e;
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103283:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103286:	5b                   	pop    %ebx
f0103287:	5e                   	pop    %esi
f0103288:	5f                   	pop    %edi
f0103289:	5d                   	pop    %ebp
f010328a:	c3                   	ret    

f010328b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010328b:	55                   	push   %ebp
f010328c:	89 e5                	mov    %esp,%ebp
f010328e:	57                   	push   %edi
f010328f:	56                   	push   %esi
f0103290:	53                   	push   %ebx
f0103291:	83 ec 34             	sub    $0x34,%esp
f0103294:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	int ret = 0;
	struct Env * e = NULL;	
f0103297:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	

	ret = env_alloc(&e,0);
f010329e:	6a 00                	push   $0x0
f01032a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032a3:	50                   	push   %eax
f01032a4:	e8 5a fe ff ff       	call   f0103103 <env_alloc>
	//panic("panic at env_alloc().\n");
	if(ret < 0){
f01032a9:	83 c4 10             	add    $0x10,%esp
f01032ac:	85 c0                	test   %eax,%eax
f01032ae:	79 15                	jns    f01032c5 <env_create+0x3a>
		panic("env_create:%e\n",ret);
f01032b0:	50                   	push   %eax
f01032b1:	68 94 75 10 f0       	push   $0xf0107594
f01032b6:	68 cf 01 00 00       	push   $0x1cf
f01032bb:	68 74 75 10 f0       	push   $0xf0107574
f01032c0:	e8 cf cd ff ff       	call   f0100094 <_panic>
	}
	load_icode(e,binary);
f01032c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Proghdr *ph,*eph;
	struct Elf * ELFHDR = ((struct Elf*)binary);
	
	if(ELFHDR->e_magic != ELF_MAGIC){
f01032cb:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032d1:	74 17                	je     f01032ea <env_create+0x5f>
		panic("This is not a valid file.\n");
f01032d3:	83 ec 04             	sub    $0x4,%esp
f01032d6:	68 a3 75 10 f0       	push   $0xf01075a3
f01032db:	68 98 01 00 00       	push   $0x198
f01032e0:	68 74 75 10 f0       	push   $0xf0107574
f01032e5:	e8 aa cd ff ff       	call   f0100094 <_panic>
	}
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
f01032ea:	89 fb                	mov    %edi,%ebx
f01032ec:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph+ELFHDR->e_phnum;
f01032ef:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032f3:	c1 e6 05             	shl    $0x5,%esi
f01032f6:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f01032f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032fb:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103303:	77 15                	ja     f010331a <env_create+0x8f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103305:	50                   	push   %eax
f0103306:	68 e8 62 10 f0       	push   $0xf01062e8
f010330b:	68 9d 01 00 00       	push   $0x19d
f0103310:	68 74 75 10 f0       	push   $0xf0107574
f0103315:	e8 7a cd ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010331a:	05 00 00 00 10       	add    $0x10000000,%eax
f010331f:	0f 22 d8             	mov    %eax,%cr3
f0103322:	eb 60                	jmp    f0103384 <env_create+0xf9>

	for(;ph<eph;ph++){

		if(ph->p_type != ELF_PROG_LOAD)
f0103324:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103327:	75 58                	jne    f0103381 <env_create+0xf6>
		{
			continue;
		}
 
		if(ph->p_filesz > ph->p_memsz)
f0103329:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010332c:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f010332f:	76 17                	jbe    f0103348 <env_create+0xbd>
		{
			panic("file size is great than memory size\n");
f0103331:	83 ec 04             	sub    $0x4,%esp
f0103334:	68 4c 76 10 f0       	push   $0xf010764c
f0103339:	68 a8 01 00 00       	push   $0x1a8
f010333e:	68 74 75 10 f0       	push   $0xf0107574
f0103343:	e8 4c cd ff ff       	call   f0100094 <_panic>
		}
		//cprintf("ph->p_memsz:0x%x\n",ph->p_memsz); 
		region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f0103348:	8b 53 08             	mov    0x8(%ebx),%edx
f010334b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010334e:	e8 ba fb ff ff       	call   f0102f0d <region_alloc>
		//cprintf("DES:0x%x,SRC:0x%x\n",ph->p_va,binary+ph->p_offset);
		//cprintf("ph->filesz:0x%x\n",ph->p_filesz);
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f0103353:	83 ec 04             	sub    $0x4,%esp
f0103356:	ff 73 10             	pushl  0x10(%ebx)
f0103359:	89 f8                	mov    %edi,%eax
f010335b:	03 43 04             	add    0x4(%ebx),%eax
f010335e:	50                   	push   %eax
f010335f:	ff 73 08             	pushl  0x8(%ebx)
f0103362:	e8 27 22 00 00       	call   f010558e <memmove>
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
f0103367:	8b 43 10             	mov    0x10(%ebx),%eax
f010336a:	83 c4 0c             	add    $0xc,%esp
f010336d:	8b 53 14             	mov    0x14(%ebx),%edx
f0103370:	29 c2                	sub    %eax,%edx
f0103372:	52                   	push   %edx
f0103373:	6a 00                	push   $0x0
f0103375:	03 43 08             	add    0x8(%ebx),%eax
f0103378:	50                   	push   %eax
f0103379:	e8 c3 21 00 00       	call   f0105541 <memset>
f010337e:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
	eph = ph+ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	for(;ph<eph;ph++){
f0103381:	83 c3 20             	add    $0x20,%ebx
f0103384:	39 de                	cmp    %ebx,%esi
f0103386:	77 9c                	ja     f0103324 <env_create+0x99>
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
	}


	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103388:	8b 47 18             	mov    0x18(%edi),%eax
f010338b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010338e:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	lcr3(PADDR(kern_pgdir));
f0103391:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103396:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010339b:	77 15                	ja     f01033b2 <env_create+0x127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010339d:	50                   	push   %eax
f010339e:	68 e8 62 10 f0       	push   $0xf01062e8
f01033a3:	68 b7 01 00 00       	push   $0x1b7
f01033a8:	68 74 75 10 f0       	push   $0xf0107574
f01033ad:	e8 e2 cc ff ff       	call   f0100094 <_panic>
f01033b2:	05 00 00 00 10       	add    $0x10000000,%eax
f01033b7:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e,(void *)USTACKTOP-PGSIZE,(size_t)PGSIZE);	
f01033ba:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033bf:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033c7:	e8 41 fb ff ff       	call   f0102f0d <region_alloc>
	if(ret < 0){
		panic("env_create:%e\n",ret);
	}
	load_icode(e,binary);
	//panic("panic in the load_icode.\n");
	e->env_type = type;
f01033cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033cf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033d2:	89 50 50             	mov    %edx,0x50(%eax)
	cprintf("THE e->env_id is:%d\n",e->env_id);
f01033d5:	83 ec 08             	sub    $0x8,%esp
f01033d8:	ff 70 48             	pushl  0x48(%eax)
f01033db:	68 be 75 10 f0       	push   $0xf01075be
f01033e0:	e8 a3 04 00 00       	call   f0103888 <cprintf>
}
f01033e5:	83 c4 10             	add    $0x10,%esp
f01033e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033eb:	5b                   	pop    %ebx
f01033ec:	5e                   	pop    %esi
f01033ed:	5f                   	pop    %edi
f01033ee:	5d                   	pop    %ebp
f01033ef:	c3                   	ret    

f01033f0 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033f0:	55                   	push   %ebp
f01033f1:	89 e5                	mov    %esp,%ebp
f01033f3:	57                   	push   %edi
f01033f4:	56                   	push   %esi
f01033f5:	53                   	push   %ebx
f01033f6:	83 ec 1c             	sub    $0x1c,%esp
f01033f9:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033fc:	e8 61 27 00 00       	call   f0105b62 <cpunum>
f0103401:	6b c0 74             	imul   $0x74,%eax,%eax
f0103404:	39 b8 28 00 23 f0    	cmp    %edi,-0xfdcffd8(%eax)
f010340a:	75 29                	jne    f0103435 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f010340c:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103411:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103416:	77 15                	ja     f010342d <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103418:	50                   	push   %eax
f0103419:	68 e8 62 10 f0       	push   $0xf01062e8
f010341e:	68 e5 01 00 00       	push   $0x1e5
f0103423:	68 74 75 10 f0       	push   $0xf0107574
f0103428:	e8 67 cc ff ff       	call   f0100094 <_panic>
f010342d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103432:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103435:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103438:	e8 25 27 00 00       	call   f0105b62 <cpunum>
f010343d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103440:	ba 00 00 00 00       	mov    $0x0,%edx
f0103445:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010344c:	74 11                	je     f010345f <env_free+0x6f>
f010344e:	e8 0f 27 00 00       	call   f0105b62 <cpunum>
f0103453:	6b c0 74             	imul   $0x74,%eax,%eax
f0103456:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010345c:	8b 50 48             	mov    0x48(%eax),%edx
f010345f:	83 ec 04             	sub    $0x4,%esp
f0103462:	53                   	push   %ebx
f0103463:	52                   	push   %edx
f0103464:	68 d3 75 10 f0       	push   $0xf01075d3
f0103469:	e8 1a 04 00 00       	call   f0103888 <cprintf>
f010346e:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103471:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103478:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010347b:	89 d0                	mov    %edx,%eax
f010347d:	c1 e0 02             	shl    $0x2,%eax
f0103480:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103483:	8b 47 60             	mov    0x60(%edi),%eax
f0103486:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103489:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010348f:	0f 84 a8 00 00 00    	je     f010353d <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103495:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010349b:	89 f0                	mov    %esi,%eax
f010349d:	c1 e8 0c             	shr    $0xc,%eax
f01034a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01034a3:	39 05 88 fe 22 f0    	cmp    %eax,0xf022fe88
f01034a9:	77 15                	ja     f01034c0 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034ab:	56                   	push   %esi
f01034ac:	68 c4 62 10 f0       	push   $0xf01062c4
f01034b1:	68 f4 01 00 00       	push   $0x1f4
f01034b6:	68 74 75 10 f0       	push   $0xf0107574
f01034bb:	e8 d4 cb ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034c3:	c1 e0 16             	shl    $0x16,%eax
f01034c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034c9:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034ce:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034d5:	01 
f01034d6:	74 17                	je     f01034ef <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034d8:	83 ec 08             	sub    $0x8,%esp
f01034db:	89 d8                	mov    %ebx,%eax
f01034dd:	c1 e0 0c             	shl    $0xc,%eax
f01034e0:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034e3:	50                   	push   %eax
f01034e4:	ff 77 60             	pushl  0x60(%edi)
f01034e7:	e8 3b de ff ff       	call   f0101327 <page_remove>
f01034ec:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034ef:	83 c3 01             	add    $0x1,%ebx
f01034f2:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034f8:	75 d4                	jne    f01034ce <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034fa:	8b 47 60             	mov    0x60(%edi),%eax
f01034fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103500:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103507:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010350a:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0103510:	72 14                	jb     f0103526 <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103512:	83 ec 04             	sub    $0x4,%esp
f0103515:	68 98 69 10 f0       	push   $0xf0106998
f010351a:	6a 51                	push   $0x51
f010351c:	68 2d 72 10 f0       	push   $0xf010722d
f0103521:	e8 6e cb ff ff       	call   f0100094 <_panic>
		page_decref(pa2page(pa));
f0103526:	83 ec 0c             	sub    $0xc,%esp
f0103529:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f010352e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103531:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103534:	50                   	push   %eax
f0103535:	e8 b7 db ff ff       	call   f01010f1 <page_decref>
f010353a:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010353d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103541:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103544:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103549:	0f 85 29 ff ff ff    	jne    f0103478 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010354f:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103552:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103557:	77 15                	ja     f010356e <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103559:	50                   	push   %eax
f010355a:	68 e8 62 10 f0       	push   $0xf01062e8
f010355f:	68 02 02 00 00       	push   $0x202
f0103564:	68 74 75 10 f0       	push   $0xf0107574
f0103569:	e8 26 cb ff ff       	call   f0100094 <_panic>
	e->env_pgdir = 0;
f010356e:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103575:	05 00 00 00 10       	add    $0x10000000,%eax
f010357a:	c1 e8 0c             	shr    $0xc,%eax
f010357d:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0103583:	72 14                	jb     f0103599 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103585:	83 ec 04             	sub    $0x4,%esp
f0103588:	68 98 69 10 f0       	push   $0xf0106998
f010358d:	6a 51                	push   $0x51
f010358f:	68 2d 72 10 f0       	push   $0xf010722d
f0103594:	e8 fb ca ff ff       	call   f0100094 <_panic>
	page_decref(pa2page(pa));
f0103599:	83 ec 0c             	sub    $0xc,%esp
f010359c:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f01035a2:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01035a5:	50                   	push   %eax
f01035a6:	e8 46 db ff ff       	call   f01010f1 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035ab:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01035b2:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
f01035b7:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01035ba:	89 3d 48 f2 22 f0    	mov    %edi,0xf022f248
}
f01035c0:	83 c4 10             	add    $0x10,%esp
f01035c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035c6:	5b                   	pop    %ebx
f01035c7:	5e                   	pop    %esi
f01035c8:	5f                   	pop    %edi
f01035c9:	5d                   	pop    %ebp
f01035ca:	c3                   	ret    

f01035cb <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035cb:	55                   	push   %ebp
f01035cc:	89 e5                	mov    %esp,%ebp
f01035ce:	53                   	push   %ebx
f01035cf:	83 ec 04             	sub    $0x4,%esp
f01035d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035d5:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035d9:	75 19                	jne    f01035f4 <env_destroy+0x29>
f01035db:	e8 82 25 00 00       	call   f0105b62 <cpunum>
f01035e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e3:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01035e9:	74 09                	je     f01035f4 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035eb:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035f2:	eb 33                	jmp    f0103627 <env_destroy+0x5c>
	}

	env_free(e);
f01035f4:	83 ec 0c             	sub    $0xc,%esp
f01035f7:	53                   	push   %ebx
f01035f8:	e8 f3 fd ff ff       	call   f01033f0 <env_free>

	if (curenv == e) {
f01035fd:	e8 60 25 00 00       	call   f0105b62 <cpunum>
f0103602:	6b c0 74             	imul   $0x74,%eax,%eax
f0103605:	83 c4 10             	add    $0x10,%esp
f0103608:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f010360e:	75 17                	jne    f0103627 <env_destroy+0x5c>
		curenv = NULL;
f0103610:	e8 4d 25 00 00       	call   f0105b62 <cpunum>
f0103615:	6b c0 74             	imul   $0x74,%eax,%eax
f0103618:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f010361f:	00 00 00 
		sched_yield();
f0103622:	e8 ed 0e 00 00       	call   f0104514 <sched_yield>
	}
}
f0103627:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010362a:	c9                   	leave  
f010362b:	c3                   	ret    

f010362c <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010362c:	55                   	push   %ebp
f010362d:	89 e5                	mov    %esp,%ebp
f010362f:	53                   	push   %ebx
f0103630:	83 ec 04             	sub    $0x4,%esp

	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103633:	e8 2a 25 00 00       	call   f0105b62 <cpunum>
f0103638:	6b c0 74             	imul   $0x74,%eax,%eax
f010363b:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f0103641:	e8 1c 25 00 00       	call   f0105b62 <cpunum>
f0103646:	89 43 5c             	mov    %eax,0x5c(%ebx)
	asm volatile(
f0103649:	8b 65 08             	mov    0x8(%ebp),%esp
f010364c:	61                   	popa   
f010364d:	07                   	pop    %es
f010364e:	1f                   	pop    %ds
f010364f:	83 c4 08             	add    $0x8,%esp
f0103652:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103653:	83 ec 04             	sub    $0x4,%esp
f0103656:	68 e9 75 10 f0       	push   $0xf01075e9
f010365b:	68 39 02 00 00       	push   $0x239
f0103660:	68 74 75 10 f0       	push   $0xf0107574
f0103665:	e8 2a ca ff ff       	call   f0100094 <_panic>

f010366a <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010366a:	55                   	push   %ebp
f010366b:	89 e5                	mov    %esp,%ebp
f010366d:	53                   	push   %ebx
f010366e:	83 ec 04             	sub    $0x4,%esp
f0103671:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.

//	cprintf("		We are going to run a env.\n");

	if(curenv && curenv->env_status == ENV_RUNNING)
f0103674:	e8 e9 24 00 00       	call   f0105b62 <cpunum>
f0103679:	6b c0 74             	imul   $0x74,%eax,%eax
f010367c:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103683:	74 29                	je     f01036ae <env_run+0x44>
f0103685:	e8 d8 24 00 00       	call   f0105b62 <cpunum>
f010368a:	6b c0 74             	imul   $0x74,%eax,%eax
f010368d:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103693:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103697:	75 15                	jne    f01036ae <env_run+0x44>
	{
			curenv->env_status = ENV_RUNNABLE;
f0103699:	e8 c4 24 00 00       	call   f0105b62 <cpunum>
f010369e:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a1:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01036a7:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
 
	curenv = e;
f01036ae:	e8 af 24 00 00       	call   f0105b62 <cpunum>
f01036b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b6:	89 98 28 00 23 f0    	mov    %ebx,-0xfdcffd8(%eax)
	e->env_status = ENV_RUNNING;
f01036bc:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f01036c3:	83 43 58 01          	addl   $0x1,0x58(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036c7:	83 ec 0c             	sub    $0xc,%esp
f01036ca:	68 c0 03 12 f0       	push   $0xf01203c0
f01036cf:	e8 99 27 00 00       	call   f0105e6d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036d4:	f3 90                	pause  
	unlock_kernel();
	lcr3(PADDR(e->env_pgdir));	
f01036d6:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036d9:	83 c4 10             	add    $0x10,%esp
f01036dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036e1:	77 15                	ja     f01036f8 <env_run+0x8e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036e3:	50                   	push   %eax
f01036e4:	68 e8 62 10 f0       	push   $0xf01062e8
f01036e9:	68 63 02 00 00       	push   $0x263
f01036ee:	68 74 75 10 f0       	push   $0xf0107574
f01036f3:	e8 9c c9 ff ff       	call   f0100094 <_panic>
f01036f8:	05 00 00 00 10       	add    $0x10000000,%eax
f01036fd:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&(e->env_tf));
f0103700:	83 ec 0c             	sub    $0xc,%esp
f0103703:	53                   	push   %ebx
f0103704:	e8 23 ff ff ff       	call   f010362c <env_pop_tf>

f0103709 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103709:	55                   	push   %ebp
f010370a:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010370c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103711:	8b 45 08             	mov    0x8(%ebp),%eax
f0103714:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103715:	ba 71 00 00 00       	mov    $0x71,%edx
f010371a:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010371b:	0f b6 c0             	movzbl %al,%eax
}
f010371e:	5d                   	pop    %ebp
f010371f:	c3                   	ret    

f0103720 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103720:	55                   	push   %ebp
f0103721:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103723:	ba 70 00 00 00       	mov    $0x70,%edx
f0103728:	8b 45 08             	mov    0x8(%ebp),%eax
f010372b:	ee                   	out    %al,(%dx)
f010372c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103731:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103734:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103735:	5d                   	pop    %ebp
f0103736:	c3                   	ret    

f0103737 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103737:	55                   	push   %ebp
f0103738:	89 e5                	mov    %esp,%ebp
f010373a:	56                   	push   %esi
f010373b:	53                   	push   %ebx
f010373c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010373f:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103745:	80 3d 4c f2 22 f0 00 	cmpb   $0x0,0xf022f24c
f010374c:	74 5a                	je     f01037a8 <irq_setmask_8259A+0x71>
f010374e:	89 c6                	mov    %eax,%esi
f0103750:	ba 21 00 00 00       	mov    $0x21,%edx
f0103755:	ee                   	out    %al,(%dx)
f0103756:	66 c1 e8 08          	shr    $0x8,%ax
f010375a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010375f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103760:	83 ec 0c             	sub    $0xc,%esp
f0103763:	68 71 76 10 f0       	push   $0xf0107671
f0103768:	e8 1b 01 00 00       	call   f0103888 <cprintf>
f010376d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103770:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103775:	0f b7 f6             	movzwl %si,%esi
f0103778:	f7 d6                	not    %esi
f010377a:	0f a3 de             	bt     %ebx,%esi
f010377d:	73 11                	jae    f0103790 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010377f:	83 ec 08             	sub    $0x8,%esp
f0103782:	53                   	push   %ebx
f0103783:	68 77 7c 10 f0       	push   $0xf0107c77
f0103788:	e8 fb 00 00 00       	call   f0103888 <cprintf>
f010378d:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103790:	83 c3 01             	add    $0x1,%ebx
f0103793:	83 fb 10             	cmp    $0x10,%ebx
f0103796:	75 e2                	jne    f010377a <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103798:	83 ec 0c             	sub    $0xc,%esp
f010379b:	68 c4 65 10 f0       	push   $0xf01065c4
f01037a0:	e8 e3 00 00 00       	call   f0103888 <cprintf>
f01037a5:	83 c4 10             	add    $0x10,%esp
}
f01037a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037ab:	5b                   	pop    %ebx
f01037ac:	5e                   	pop    %esi
f01037ad:	5d                   	pop    %ebp
f01037ae:	c3                   	ret    

f01037af <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01037af:	c6 05 4c f2 22 f0 01 	movb   $0x1,0xf022f24c
f01037b6:	ba 21 00 00 00       	mov    $0x21,%edx
f01037bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037c0:	ee                   	out    %al,(%dx)
f01037c1:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037c6:	ee                   	out    %al,(%dx)
f01037c7:	ba 20 00 00 00       	mov    $0x20,%edx
f01037cc:	b8 11 00 00 00       	mov    $0x11,%eax
f01037d1:	ee                   	out    %al,(%dx)
f01037d2:	ba 21 00 00 00       	mov    $0x21,%edx
f01037d7:	b8 20 00 00 00       	mov    $0x20,%eax
f01037dc:	ee                   	out    %al,(%dx)
f01037dd:	b8 04 00 00 00       	mov    $0x4,%eax
f01037e2:	ee                   	out    %al,(%dx)
f01037e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01037e8:	ee                   	out    %al,(%dx)
f01037e9:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037ee:	b8 11 00 00 00       	mov    $0x11,%eax
f01037f3:	ee                   	out    %al,(%dx)
f01037f4:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037f9:	b8 28 00 00 00       	mov    $0x28,%eax
f01037fe:	ee                   	out    %al,(%dx)
f01037ff:	b8 02 00 00 00       	mov    $0x2,%eax
f0103804:	ee                   	out    %al,(%dx)
f0103805:	b8 01 00 00 00       	mov    $0x1,%eax
f010380a:	ee                   	out    %al,(%dx)
f010380b:	ba 20 00 00 00       	mov    $0x20,%edx
f0103810:	b8 68 00 00 00       	mov    $0x68,%eax
f0103815:	ee                   	out    %al,(%dx)
f0103816:	b8 0a 00 00 00       	mov    $0xa,%eax
f010381b:	ee                   	out    %al,(%dx)
f010381c:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103821:	b8 68 00 00 00       	mov    $0x68,%eax
f0103826:	ee                   	out    %al,(%dx)
f0103827:	b8 0a 00 00 00       	mov    $0xa,%eax
f010382c:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010382d:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103834:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103838:	74 13                	je     f010384d <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010383a:	55                   	push   %ebp
f010383b:	89 e5                	mov    %esp,%ebp
f010383d:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103840:	0f b7 c0             	movzwl %ax,%eax
f0103843:	50                   	push   %eax
f0103844:	e8 ee fe ff ff       	call   f0103737 <irq_setmask_8259A>
f0103849:	83 c4 10             	add    $0x10,%esp
}
f010384c:	c9                   	leave  
f010384d:	f3 c3                	repz ret 

f010384f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010384f:	55                   	push   %ebp
f0103850:	89 e5                	mov    %esp,%ebp
f0103852:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103855:	ff 75 08             	pushl  0x8(%ebp)
f0103858:	e8 70 cf ff ff       	call   f01007cd <cputchar>
	*cnt++;
}
f010385d:	83 c4 10             	add    $0x10,%esp
f0103860:	c9                   	leave  
f0103861:	c3                   	ret    

f0103862 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103862:	55                   	push   %ebp
f0103863:	89 e5                	mov    %esp,%ebp
f0103865:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103868:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010386f:	ff 75 0c             	pushl  0xc(%ebp)
f0103872:	ff 75 08             	pushl  0x8(%ebp)
f0103875:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103878:	50                   	push   %eax
f0103879:	68 4f 38 10 f0       	push   $0xf010384f
f010387e:	e8 08 16 00 00       	call   f0104e8b <vprintfmt>
	return cnt;
}
f0103883:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103886:	c9                   	leave  
f0103887:	c3                   	ret    

f0103888 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103888:	55                   	push   %ebp
f0103889:	89 e5                	mov    %esp,%ebp
f010388b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010388e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103891:	50                   	push   %eax
f0103892:	ff 75 08             	pushl  0x8(%ebp)
f0103895:	e8 c8 ff ff ff       	call   f0103862 <vcprintf>
	va_end(ap);

	return cnt;
}
f010389a:	c9                   	leave  
f010389b:	c3                   	ret    

f010389c <trap_init_percpu>:
*/
// Initialize and load the per-CPU TSS and IDT

void
trap_init_percpu(void)
{
f010389c:	55                   	push   %ebp
f010389d:	89 e5                	mov    %esp,%ebp
f010389f:	57                   	push   %edi
f01038a0:	56                   	push   %esi
f01038a1:	53                   	push   %ebx
f01038a2:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP-cpunum()*(KSTKSIZE+KSTKGAP);
f01038a5:	e8 b8 22 00 00       	call   f0105b62 <cpunum>
f01038aa:	89 c3                	mov    %eax,%ebx
f01038ac:	e8 b1 22 00 00       	call   f0105b62 <cpunum>
f01038b1:	6b db 74             	imul   $0x74,%ebx,%ebx
f01038b4:	c1 e0 10             	shl    $0x10,%eax
f01038b7:	89 c2                	mov    %eax,%edx
f01038b9:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01038be:	29 d0                	sub    %edx,%eax
f01038c0:	89 83 30 00 23 f0    	mov    %eax,-0xfdcffd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038c6:	e8 97 22 00 00       	call   f0105b62 <cpunum>
f01038cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ce:	66 c7 80 34 00 23 f0 	movw   $0x10,-0xfdcffcc(%eax)
f01038d5:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038d7:	e8 86 22 00 00       	call   f0105b62 <cpunum>
f01038dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01038df:	66 c7 80 92 00 23 f0 	movw   $0x68,-0xfdcff6e(%eax)
f01038e6:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01038e8:	e8 75 22 00 00       	call   f0105b62 <cpunum>
f01038ed:	8d 58 05             	lea    0x5(%eax),%ebx
f01038f0:	e8 6d 22 00 00       	call   f0105b62 <cpunum>
f01038f5:	89 c7                	mov    %eax,%edi
f01038f7:	e8 66 22 00 00       	call   f0105b62 <cpunum>
f01038fc:	89 c6                	mov    %eax,%esi
f01038fe:	e8 5f 22 00 00       	call   f0105b62 <cpunum>
f0103903:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f010390a:	f0 67 00 
f010390d:	6b ff 74             	imul   $0x74,%edi,%edi
f0103910:	81 c7 2c 00 23 f0    	add    $0xf023002c,%edi
f0103916:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f010391d:	f0 
f010391e:	6b d6 74             	imul   $0x74,%esi,%edx
f0103921:	81 c2 2c 00 23 f0    	add    $0xf023002c,%edx
f0103927:	c1 ea 10             	shr    $0x10,%edx
f010392a:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103931:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103938:	99 
f0103939:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103940:	40 
f0103941:	6b c0 74             	imul   $0x74,%eax,%eax
f0103944:	05 2c 00 23 f0       	add    $0xf023002c,%eax
f0103949:	c1 e8 18             	shr    $0x18,%eax
f010394c:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+cpunum()].sd_s = 0;
f0103953:	e8 0a 22 00 00       	call   f0105b62 <cpunum>
f0103958:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010395f:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(thiscpu->cpu_id<<3));//why do this?I cannot unstanderd.
f0103960:	e8 fd 21 00 00       	call   f0105b62 <cpunum>
f0103965:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103968:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f010396f:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103976:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103979:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010397e:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
	*/
}
f0103981:	83 c4 0c             	add    $0xc,%esp
f0103984:	5b                   	pop    %ebx
f0103985:	5e                   	pop    %esi
f0103986:	5f                   	pop    %edi
f0103987:	5d                   	pop    %ebp
f0103988:	c3                   	ret    

f0103989 <trap_init>:
}


void
trap_init(void)
{
f0103989:	55                   	push   %ebp
f010398a:	89 e5                	mov    %esp,%ebp
f010398c:	83 ec 48             	sub    $0x48,%esp
	void iqr12(); 
	void iqr13(); 
	void iqr14(); 
	void iqr15();	 

	void (*iqrs[])() = {
f010398f:	c7 45 b8 d0 43 10 f0 	movl   $0xf01043d0,-0x48(%ebp)
f0103996:	c7 45 bc d6 43 10 f0 	movl   $0xf01043d6,-0x44(%ebp)
f010399d:	c7 45 c0 dc 43 10 f0 	movl   $0xf01043dc,-0x40(%ebp)
f01039a4:	c7 45 c4 e2 43 10 f0 	movl   $0xf01043e2,-0x3c(%ebp)
f01039ab:	c7 45 c8 e8 43 10 f0 	movl   $0xf01043e8,-0x38(%ebp)
f01039b2:	c7 45 cc ee 43 10 f0 	movl   $0xf01043ee,-0x34(%ebp)
f01039b9:	c7 45 d0 f4 43 10 f0 	movl   $0xf01043f4,-0x30(%ebp)
f01039c0:	c7 45 d4 fa 43 10 f0 	movl   $0xf01043fa,-0x2c(%ebp)
f01039c7:	c7 45 d8 00 44 10 f0 	movl   $0xf0104400,-0x28(%ebp)
f01039ce:	c7 45 dc 06 44 10 f0 	movl   $0xf0104406,-0x24(%ebp)
f01039d5:	c7 45 e0 0c 44 10 f0 	movl   $0xf010440c,-0x20(%ebp)
f01039dc:	c7 45 e4 12 44 10 f0 	movl   $0xf0104412,-0x1c(%ebp)
f01039e3:	c7 45 e8 18 44 10 f0 	movl   $0xf0104418,-0x18(%ebp)
f01039ea:	c7 45 ec 1e 44 10 f0 	movl   $0xf010441e,-0x14(%ebp)
f01039f1:	c7 45 f0 24 44 10 f0 	movl   $0xf0104424,-0x10(%ebp)
f01039f8:	c7 45 f4 2a 44 10 f0 	movl   $0xf010442a,-0xc(%ebp)
f01039ff:	b8 20 00 00 00       	mov    $0x20,%eax
		iqr0,iqr1,iqr2,iqr3, iqr4, iqr5, iqr6, iqr7, iqr8, iqr9, iqr10, iqr11, iqr12, iqr13, iqr14, iqr15
	};
	int i;
	for(i = 0;i<16;i++){
		SETGATE(idt[IRQ_OFFSET + i], 0 ,GD_KT, iqrs[i], 0);
f0103a04:	8b 94 85 38 ff ff ff 	mov    -0xc8(%ebp,%eax,4),%edx
f0103a0b:	66 89 14 c5 60 f2 22 	mov    %dx,-0xfdd0da0(,%eax,8)
f0103a12:	f0 
f0103a13:	66 c7 04 c5 62 f2 22 	movw   $0x8,-0xfdd0d9e(,%eax,8)
f0103a1a:	f0 08 00 
f0103a1d:	c6 04 c5 64 f2 22 f0 	movb   $0x0,-0xfdd0d9c(,%eax,8)
f0103a24:	00 
f0103a25:	c6 04 c5 65 f2 22 f0 	movb   $0x8e,-0xfdd0d9b(,%eax,8)
f0103a2c:	8e 
f0103a2d:	c1 ea 10             	shr    $0x10,%edx
f0103a30:	66 89 14 c5 66 f2 22 	mov    %dx,-0xfdd0d9a(,%eax,8)
f0103a37:	f0 
f0103a38:	83 c0 01             	add    $0x1,%eax

	void (*iqrs[])() = {
		iqr0,iqr1,iqr2,iqr3, iqr4, iqr5, iqr6, iqr7, iqr8, iqr9, iqr10, iqr11, iqr12, iqr13, iqr14, iqr15
	};
	int i;
	for(i = 0;i<16;i++){
f0103a3b:	83 f8 30             	cmp    $0x30,%eax
f0103a3e:	75 c4                	jne    f0103a04 <trap_init+0x7b>
		SETGATE(idt[IRQ_OFFSET + i], 0 ,GD_KT, iqrs[i], 0);
	}
	SETGATE(idt[T_DIVIDE],0,GD_KT,t_divide,0);
f0103a40:	b8 38 43 10 f0       	mov    $0xf0104338,%eax
f0103a45:	66 a3 60 f2 22 f0    	mov    %ax,0xf022f260
f0103a4b:	66 c7 05 62 f2 22 f0 	movw   $0x8,0xf022f262
f0103a52:	08 00 
f0103a54:	c6 05 64 f2 22 f0 00 	movb   $0x0,0xf022f264
f0103a5b:	c6 05 65 f2 22 f0 8e 	movb   $0x8e,0xf022f265
f0103a62:	c1 e8 10             	shr    $0x10,%eax
f0103a65:	66 a3 66 f2 22 f0    	mov    %ax,0xf022f266
	SETGATE(idt[T_DEBUG],0,GD_KT,t_debug,0);
f0103a6b:	b8 42 43 10 f0       	mov    $0xf0104342,%eax
f0103a70:	66 a3 68 f2 22 f0    	mov    %ax,0xf022f268
f0103a76:	66 c7 05 6a f2 22 f0 	movw   $0x8,0xf022f26a
f0103a7d:	08 00 
f0103a7f:	c6 05 6c f2 22 f0 00 	movb   $0x0,0xf022f26c
f0103a86:	c6 05 6d f2 22 f0 8e 	movb   $0x8e,0xf022f26d
f0103a8d:	c1 e8 10             	shr    $0x10,%eax
f0103a90:	66 a3 6e f2 22 f0    	mov    %ax,0xf022f26e
//	SETGAET(idt[T_NMI],0,GD_KT,t_nmi,0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0103a96:	b8 56 43 10 f0       	mov    $0xf0104356,%eax
f0103a9b:	66 a3 78 f2 22 f0    	mov    %ax,0xf022f278
f0103aa1:	66 c7 05 7a f2 22 f0 	movw   $0x8,0xf022f27a
f0103aa8:	08 00 
f0103aaa:	c6 05 7c f2 22 f0 00 	movb   $0x0,0xf022f27c
f0103ab1:	c6 05 7d f2 22 f0 ee 	movb   $0xee,0xf022f27d
f0103ab8:	c1 e8 10             	shr    $0x10,%eax
f0103abb:	66 a3 7e f2 22 f0    	mov    %ax,0xf022f27e
   	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103ac1:	b8 60 43 10 f0       	mov    $0xf0104360,%eax
f0103ac6:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f0103acc:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f0103ad3:	08 00 
f0103ad5:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f0103adc:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f0103ae3:	c1 e8 10             	shr    $0x10,%eax
f0103ae6:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
        SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103aec:	b8 6a 43 10 f0       	mov    $0xf010436a,%eax
f0103af1:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f0103af7:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f0103afe:	08 00 
f0103b00:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f0103b07:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103b0e:	c1 e8 10             	shr    $0x10,%eax
f0103b11:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
        SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103b17:	b8 74 43 10 f0       	mov    $0xf0104374,%eax
f0103b1c:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103b22:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f0103b29:	08 00 
f0103b2b:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103b32:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f0103b39:	c1 e8 10             	shr    $0x10,%eax
f0103b3c:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
        SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103b42:	b8 7e 43 10 f0       	mov    $0xf010437e,%eax
f0103b47:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f0103b4d:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f0103b54:	08 00 
f0103b56:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f0103b5d:	c6 05 9d f2 22 f0 8e 	movb   $0x8e,0xf022f29d
f0103b64:	c1 e8 10             	shr    $0x10,%eax
f0103b67:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
   	 SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103b6d:	b8 88 43 10 f0       	mov    $0xf0104388,%eax
f0103b72:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f0103b78:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f0103b7f:	08 00 
f0103b81:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f0103b88:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f0103b8f:	c1 e8 10             	shr    $0x10,%eax
f0103b92:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6
   	 SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103b98:	b8 90 43 10 f0       	mov    $0xf0104390,%eax
f0103b9d:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f0103ba3:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f0103baa:	08 00 
f0103bac:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f0103bb3:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f0103bba:	c1 e8 10             	shr    $0x10,%eax
f0103bbd:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
  	 SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103bc3:	b8 98 43 10 f0       	mov    $0xf0104398,%eax
f0103bc8:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f0103bce:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f0103bd5:	08 00 
f0103bd7:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f0103bde:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f0103be5:	c1 e8 10             	shr    $0x10,%eax
f0103be8:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
   	 SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103bee:	b8 a0 43 10 f0       	mov    $0xf01043a0,%eax
f0103bf3:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f0103bf9:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f0103c00:	08 00 
f0103c02:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f0103c09:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f0103c10:	c1 e8 10             	shr    $0x10,%eax
f0103c13:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
   	 SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103c19:	b8 a8 43 10 f0       	mov    $0xf01043a8,%eax
f0103c1e:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f0103c24:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f0103c2b:	08 00 
f0103c2d:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f0103c34:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f0103c3b:	c1 e8 10             	shr    $0x10,%eax
f0103c3e:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
   	 SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103c44:	b8 b0 43 10 f0       	mov    $0xf01043b0,%eax
f0103c49:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f0103c4f:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f0103c56:	08 00 
f0103c58:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f0103c5f:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f0103c66:	c1 e8 10             	shr    $0x10,%eax
f0103c69:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
   	 SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103c6f:	b8 b4 43 10 f0       	mov    $0xf01043b4,%eax
f0103c74:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103c7a:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103c81:	08 00 
f0103c83:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103c8a:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103c91:	c1 e8 10             	shr    $0x10,%eax
f0103c94:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6
   	 SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103c9a:	b8 ba 43 10 f0       	mov    $0xf01043ba,%eax
f0103c9f:	66 a3 e8 f2 22 f0    	mov    %ax,0xf022f2e8
f0103ca5:	66 c7 05 ea f2 22 f0 	movw   $0x8,0xf022f2ea
f0103cac:	08 00 
f0103cae:	c6 05 ec f2 22 f0 00 	movb   $0x0,0xf022f2ec
f0103cb5:	c6 05 ed f2 22 f0 8e 	movb   $0x8e,0xf022f2ed
f0103cbc:	c1 e8 10             	shr    $0x10,%eax
f0103cbf:	66 a3 ee f2 22 f0    	mov    %ax,0xf022f2ee
   	 SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103cc5:	b8 be 43 10 f0       	mov    $0xf01043be,%eax
f0103cca:	66 a3 f0 f2 22 f0    	mov    %ax,0xf022f2f0
f0103cd0:	66 c7 05 f2 f2 22 f0 	movw   $0x8,0xf022f2f2
f0103cd7:	08 00 
f0103cd9:	c6 05 f4 f2 22 f0 00 	movb   $0x0,0xf022f2f4
f0103ce0:	c6 05 f5 f2 22 f0 8e 	movb   $0x8e,0xf022f2f5
f0103ce7:	c1 e8 10             	shr    $0x10,%eax
f0103cea:	66 a3 f6 f2 22 f0    	mov    %ax,0xf022f2f6
   	 SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103cf0:	b8 c4 43 10 f0       	mov    $0xf01043c4,%eax
f0103cf5:	66 a3 f8 f2 22 f0    	mov    %ax,0xf022f2f8
f0103cfb:	66 c7 05 fa f2 22 f0 	movw   $0x8,0xf022f2fa
f0103d02:	08 00 
f0103d04:	c6 05 fc f2 22 f0 00 	movb   $0x0,0xf022f2fc
f0103d0b:	c6 05 fd f2 22 f0 8e 	movb   $0x8e,0xf022f2fd
f0103d12:	c1 e8 10             	shr    $0x10,%eax
f0103d15:	66 a3 fe f2 22 f0    	mov    %ax,0xf022f2fe
   	 SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103d1b:	b8 ca 43 10 f0       	mov    $0xf01043ca,%eax
f0103d20:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103d26:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103d2d:	08 00 
f0103d2f:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103d36:	c6 05 e5 f3 22 f0 ee 	movb   $0xee,0xf022f3e5
f0103d3d:	c1 e8 10             	shr    $0x10,%eax
f0103d40:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6
	// Per-CPU setup 
	trap_init_percpu();
f0103d46:	e8 51 fb ff ff       	call   f010389c <trap_init_percpu>
}
f0103d4b:	c9                   	leave  
f0103d4c:	c3                   	ret    

f0103d4d <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d4d:	55                   	push   %ebp
f0103d4e:	89 e5                	mov    %esp,%ebp
f0103d50:	53                   	push   %ebx
f0103d51:	83 ec 0c             	sub    $0xc,%esp
f0103d54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d57:	ff 33                	pushl  (%ebx)
f0103d59:	68 85 76 10 f0       	push   $0xf0107685
f0103d5e:	e8 25 fb ff ff       	call   f0103888 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d63:	83 c4 08             	add    $0x8,%esp
f0103d66:	ff 73 04             	pushl  0x4(%ebx)
f0103d69:	68 94 76 10 f0       	push   $0xf0107694
f0103d6e:	e8 15 fb ff ff       	call   f0103888 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d73:	83 c4 08             	add    $0x8,%esp
f0103d76:	ff 73 08             	pushl  0x8(%ebx)
f0103d79:	68 a3 76 10 f0       	push   $0xf01076a3
f0103d7e:	e8 05 fb ff ff       	call   f0103888 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103d83:	83 c4 08             	add    $0x8,%esp
f0103d86:	ff 73 0c             	pushl  0xc(%ebx)
f0103d89:	68 b2 76 10 f0       	push   $0xf01076b2
f0103d8e:	e8 f5 fa ff ff       	call   f0103888 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103d93:	83 c4 08             	add    $0x8,%esp
f0103d96:	ff 73 10             	pushl  0x10(%ebx)
f0103d99:	68 c1 76 10 f0       	push   $0xf01076c1
f0103d9e:	e8 e5 fa ff ff       	call   f0103888 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103da3:	83 c4 08             	add    $0x8,%esp
f0103da6:	ff 73 14             	pushl  0x14(%ebx)
f0103da9:	68 d0 76 10 f0       	push   $0xf01076d0
f0103dae:	e8 d5 fa ff ff       	call   f0103888 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103db3:	83 c4 08             	add    $0x8,%esp
f0103db6:	ff 73 18             	pushl  0x18(%ebx)
f0103db9:	68 df 76 10 f0       	push   $0xf01076df
f0103dbe:	e8 c5 fa ff ff       	call   f0103888 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103dc3:	83 c4 08             	add    $0x8,%esp
f0103dc6:	ff 73 1c             	pushl  0x1c(%ebx)
f0103dc9:	68 ee 76 10 f0       	push   $0xf01076ee
f0103dce:	e8 b5 fa ff ff       	call   f0103888 <cprintf>
}
f0103dd3:	83 c4 10             	add    $0x10,%esp
f0103dd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103dd9:	c9                   	leave  
f0103dda:	c3                   	ret    

f0103ddb <print_trapframe>:
	*/
}

void
print_trapframe(struct Trapframe *tf)
{
f0103ddb:	55                   	push   %ebp
f0103ddc:	89 e5                	mov    %esp,%ebp
f0103dde:	56                   	push   %esi
f0103ddf:	53                   	push   %ebx
f0103de0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103de3:	e8 7a 1d 00 00       	call   f0105b62 <cpunum>
f0103de8:	83 ec 04             	sub    $0x4,%esp
f0103deb:	50                   	push   %eax
f0103dec:	53                   	push   %ebx
f0103ded:	68 52 77 10 f0       	push   $0xf0107752
f0103df2:	e8 91 fa ff ff       	call   f0103888 <cprintf>
	print_regs(&tf->tf_regs);
f0103df7:	89 1c 24             	mov    %ebx,(%esp)
f0103dfa:	e8 4e ff ff ff       	call   f0103d4d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103dff:	83 c4 08             	add    $0x8,%esp
f0103e02:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e06:	50                   	push   %eax
f0103e07:	68 70 77 10 f0       	push   $0xf0107770
f0103e0c:	e8 77 fa ff ff       	call   f0103888 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e11:	83 c4 08             	add    $0x8,%esp
f0103e14:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e18:	50                   	push   %eax
f0103e19:	68 83 77 10 f0       	push   $0xf0107783
f0103e1e:	e8 65 fa ff ff       	call   f0103888 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e23:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103e26:	83 c4 10             	add    $0x10,%esp
f0103e29:	83 f8 13             	cmp    $0x13,%eax
f0103e2c:	77 09                	ja     f0103e37 <print_trapframe+0x5c>
		return excnames[trapno];
f0103e2e:	8b 14 85 a0 7a 10 f0 	mov    -0xfef8560(,%eax,4),%edx
f0103e35:	eb 1f                	jmp    f0103e56 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103e37:	83 f8 30             	cmp    $0x30,%eax
f0103e3a:	74 15                	je     f0103e51 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e3c:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e3f:	83 fa 10             	cmp    $0x10,%edx
f0103e42:	b9 1c 77 10 f0       	mov    $0xf010771c,%ecx
f0103e47:	ba 09 77 10 f0       	mov    $0xf0107709,%edx
f0103e4c:	0f 43 d1             	cmovae %ecx,%edx
f0103e4f:	eb 05                	jmp    f0103e56 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103e51:	ba fd 76 10 f0       	mov    $0xf01076fd,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e56:	83 ec 04             	sub    $0x4,%esp
f0103e59:	52                   	push   %edx
f0103e5a:	50                   	push   %eax
f0103e5b:	68 96 77 10 f0       	push   $0xf0107796
f0103e60:	e8 23 fa ff ff       	call   f0103888 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e65:	83 c4 10             	add    $0x10,%esp
f0103e68:	3b 1d 60 fa 22 f0    	cmp    0xf022fa60,%ebx
f0103e6e:	75 1a                	jne    f0103e8a <print_trapframe+0xaf>
f0103e70:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103e74:	75 14                	jne    f0103e8a <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103e76:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103e79:	83 ec 08             	sub    $0x8,%esp
f0103e7c:	50                   	push   %eax
f0103e7d:	68 a8 77 10 f0       	push   $0xf01077a8
f0103e82:	e8 01 fa ff ff       	call   f0103888 <cprintf>
f0103e87:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103e8a:	83 ec 08             	sub    $0x8,%esp
f0103e8d:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e90:	68 b7 77 10 f0       	push   $0xf01077b7
f0103e95:	e8 ee f9 ff ff       	call   f0103888 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103e9a:	83 c4 10             	add    $0x10,%esp
f0103e9d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ea1:	75 49                	jne    f0103eec <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ea3:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103ea6:	89 c2                	mov    %eax,%edx
f0103ea8:	83 e2 01             	and    $0x1,%edx
f0103eab:	ba 36 77 10 f0       	mov    $0xf0107736,%edx
f0103eb0:	b9 2b 77 10 f0       	mov    $0xf010772b,%ecx
f0103eb5:	0f 44 ca             	cmove  %edx,%ecx
f0103eb8:	89 c2                	mov    %eax,%edx
f0103eba:	83 e2 02             	and    $0x2,%edx
f0103ebd:	ba 48 77 10 f0       	mov    $0xf0107748,%edx
f0103ec2:	be 42 77 10 f0       	mov    $0xf0107742,%esi
f0103ec7:	0f 45 d6             	cmovne %esi,%edx
f0103eca:	83 e0 04             	and    $0x4,%eax
f0103ecd:	be b0 78 10 f0       	mov    $0xf01078b0,%esi
f0103ed2:	b8 4d 77 10 f0       	mov    $0xf010774d,%eax
f0103ed7:	0f 44 c6             	cmove  %esi,%eax
f0103eda:	51                   	push   %ecx
f0103edb:	52                   	push   %edx
f0103edc:	50                   	push   %eax
f0103edd:	68 c5 77 10 f0       	push   $0xf01077c5
f0103ee2:	e8 a1 f9 ff ff       	call   f0103888 <cprintf>
f0103ee7:	83 c4 10             	add    $0x10,%esp
f0103eea:	eb 10                	jmp    f0103efc <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103eec:	83 ec 0c             	sub    $0xc,%esp
f0103eef:	68 c4 65 10 f0       	push   $0xf01065c4
f0103ef4:	e8 8f f9 ff ff       	call   f0103888 <cprintf>
f0103ef9:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103efc:	83 ec 08             	sub    $0x8,%esp
f0103eff:	ff 73 30             	pushl  0x30(%ebx)
f0103f02:	68 d4 77 10 f0       	push   $0xf01077d4
f0103f07:	e8 7c f9 ff ff       	call   f0103888 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f0c:	83 c4 08             	add    $0x8,%esp
f0103f0f:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f13:	50                   	push   %eax
f0103f14:	68 e3 77 10 f0       	push   $0xf01077e3
f0103f19:	e8 6a f9 ff ff       	call   f0103888 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f1e:	83 c4 08             	add    $0x8,%esp
f0103f21:	ff 73 38             	pushl  0x38(%ebx)
f0103f24:	68 f6 77 10 f0       	push   $0xf01077f6
f0103f29:	e8 5a f9 ff ff       	call   f0103888 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f2e:	83 c4 10             	add    $0x10,%esp
f0103f31:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f35:	74 25                	je     f0103f5c <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f37:	83 ec 08             	sub    $0x8,%esp
f0103f3a:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f3d:	68 05 78 10 f0       	push   $0xf0107805
f0103f42:	e8 41 f9 ff ff       	call   f0103888 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f47:	83 c4 08             	add    $0x8,%esp
f0103f4a:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f4e:	50                   	push   %eax
f0103f4f:	68 14 78 10 f0       	push   $0xf0107814
f0103f54:	e8 2f f9 ff ff       	call   f0103888 <cprintf>
f0103f59:	83 c4 10             	add    $0x10,%esp
	}
}
f0103f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f5f:	5b                   	pop    %ebx
f0103f60:	5e                   	pop    %esi
f0103f61:	5d                   	pop    %ebp
f0103f62:	c3                   	ret    

f0103f63 <page_fault_handler>:
}

typedef void*(*fun)(void);
void
page_fault_handler(struct Trapframe *tf)
{
f0103f63:	55                   	push   %ebp
f0103f64:	89 e5                	mov    %esp,%ebp
f0103f66:	57                   	push   %edi
f0103f67:	56                   	push   %esi
f0103f68:	53                   	push   %ebx
f0103f69:	83 ec 18             	sub    $0x18,%esp
f0103f6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103f6f:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	print_trapframe(tf);
f0103f72:	53                   	push   %ebx
f0103f73:	e8 63 fe ff ff       	call   f0103ddb <print_trapframe>
	if ((tf->tf_cs&3) == 0)
f0103f78:	83 c4 10             	add    $0x10,%esp
f0103f7b:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f7f:	75 17                	jne    f0103f98 <page_fault_handler+0x35>
		panic("a page fault happens in kernel [eip:%x]", tf->tf_eip);
f0103f81:	ff 73 30             	pushl  0x30(%ebx)
f0103f84:	68 fc 79 10 f0       	push   $0xf01079fc
f0103f89:	68 0d 02 00 00       	push   $0x20d
f0103f8e:	68 27 78 10 f0       	push   $0xf0107827
f0103f93:	e8 fc c0 ff ff       	call   f0100094 <_panic>
	// LAB 3: Your code here.

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.
	if(curenv == 0){
f0103f98:	e8 c5 1b 00 00       	call   f0105b62 <cpunum>
f0103f9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa0:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103fa7:	75 17                	jne    f0103fc0 <page_fault_handler+0x5d>
		panic("curenv does't exist.\n");
f0103fa9:	83 ec 04             	sub    $0x4,%esp
f0103fac:	68 33 78 10 f0       	push   $0xf0107833
f0103fb1:	68 13 02 00 00       	push   $0x213
f0103fb6:	68 27 78 10 f0       	push   $0xf0107827
f0103fbb:	e8 d4 c0 ff ff       	call   f0100094 <_panic>
	}
	//cprintf("\ttrap env_id is:%d\n",curenv->env_id);	
	if(curenv->env_pgfault_upcall == 0){
f0103fc0:	e8 9d 1b 00 00       	call   f0105b62 <cpunum>
f0103fc5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fc8:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103fce:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fd2:	75 17                	jne    f0103feb <page_fault_handler+0x88>
		panic("curenv->env_pgfault_upcall does't exist.\n");
f0103fd4:	83 ec 04             	sub    $0x4,%esp
f0103fd7:	68 24 7a 10 f0       	push   $0xf0107a24
f0103fdc:	68 17 02 00 00       	push   $0x217
f0103fe1:	68 27 78 10 f0       	push   $0xf0107827
f0103fe6:	e8 a9 c0 ff ff       	call   f0100094 <_panic>
	}
	if(curenv->env_pgfault_upcall != 0){
f0103feb:	e8 72 1b 00 00       	call   f0105b62 <cpunum>
f0103ff0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff3:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103ff9:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103ffd:	0f 84 a7 00 00 00    	je     f01040aa <page_fault_handler+0x147>
		//(fun(curenv->env_pgfault_upcall))();		
	//	( (fun)(curenv->env_pgfault_upcall) )();
	
		struct UTrapframe *utf;
		uintptr_t utf_addr;
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0104003:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104006:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f010400c:	83 e8 38             	sub    $0x38,%eax
f010400f:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104015:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f010401a:	0f 46 d0             	cmovbe %eax,%edx
f010401d:	89 d7                	mov    %edx,%edi
		else 
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
	//	cprintf("\t before user_mem_assert.\n");
		user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
f010401f:	e8 3e 1b 00 00       	call   f0105b62 <cpunum>
f0104024:	6a 02                	push   $0x2
f0104026:	6a 01                	push   $0x1
f0104028:	57                   	push   %edi
f0104029:	6b c0 74             	imul   $0x74,%eax,%eax
f010402c:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104032:	e8 8c ee ff ff       	call   f0102ec3 <user_mem_assert>
	//	cprintf("\t after user_mem_assert.\n");
		utf = (struct UTrapframe *) utf_addr;

		utf->utf_fault_va = fault_va;
f0104037:	89 fa                	mov    %edi,%edx
f0104039:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f010403b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010403e:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104041:	8d 7f 08             	lea    0x8(%edi),%edi
f0104044:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104049:	89 de                	mov    %ebx,%esi
f010404b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f010404d:	8b 43 30             	mov    0x30(%ebx),%eax
f0104050:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104053:	8b 43 38             	mov    0x38(%ebx),%eax
f0104056:	89 d7                	mov    %edx,%edi
f0104058:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010405b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010405e:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104061:	e8 fc 1a 00 00       	call   f0105b62 <cpunum>
f0104066:	6b c0 74             	imul   $0x74,%eax,%eax
f0104069:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f010406f:	e8 ee 1a 00 00       	call   f0105b62 <cpunum>
f0104074:	6b c0 74             	imul   $0x74,%eax,%eax
f0104077:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010407d:	8b 40 64             	mov    0x64(%eax),%eax
f0104080:	89 43 30             	mov    %eax,0x30(%ebx)
		curenv->env_tf.tf_esp = utf_addr;
f0104083:	e8 da 1a 00 00       	call   f0105b62 <cpunum>
f0104088:	6b c0 74             	imul   $0x74,%eax,%eax
f010408b:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104091:	89 78 3c             	mov    %edi,0x3c(%eax)
	//	cprintf("\t before env_run curenv.\n");
		env_run(curenv);
f0104094:	e8 c9 1a 00 00       	call   f0105b62 <cpunum>
f0104099:	83 c4 04             	add    $0x4,%esp
f010409c:	6b c0 74             	imul   $0x74,%eax,%eax
f010409f:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01040a5:	e8 c0 f5 ff ff       	call   f010366a <env_run>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
//	print_trapframe(tf);
//	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040aa:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01040ad:	e8 b0 1a 00 00       	call   f0105b62 <cpunum>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
//	print_trapframe(tf);
//	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040b2:	57                   	push   %edi
f01040b3:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f01040b4:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
//	print_trapframe(tf);
//	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01040b7:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01040bd:	ff 70 48             	pushl  0x48(%eax)
f01040c0:	68 50 7a 10 f0       	push   $0xf0107a50
f01040c5:	e8 be f7 ff ff       	call   f0103888 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01040ca:	89 1c 24             	mov    %ebx,(%esp)
f01040cd:	e8 09 fd ff ff       	call   f0103ddb <print_trapframe>
	env_destroy(curenv);
f01040d2:	e8 8b 1a 00 00       	call   f0105b62 <cpunum>
f01040d7:	83 c4 04             	add    $0x4,%esp
f01040da:	6b c0 74             	imul   $0x74,%eax,%eax
f01040dd:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01040e3:	e8 e3 f4 ff ff       	call   f01035cb <env_destroy>
	//cprintf("\t OUT function trap.c/page_fault_handler.\n");
}
f01040e8:	83 c4 10             	add    $0x10,%esp
f01040eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040ee:	5b                   	pop    %ebx
f01040ef:	5e                   	pop    %esi
f01040f0:	5f                   	pop    %edi
f01040f1:	5d                   	pop    %ebp
f01040f2:	c3                   	ret    

f01040f3 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040f3:	55                   	push   %ebp
f01040f4:	89 e5                	mov    %esp,%ebp
f01040f6:	57                   	push   %edi
f01040f7:	56                   	push   %esi
f01040f8:	8b 75 08             	mov    0x8(%ebp),%esi

	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040fb:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040fc:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f0104103:	74 01                	je     f0104106 <trap+0x13>
		asm volatile("hlt");
f0104105:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104106:	e8 57 1a 00 00       	call   f0105b62 <cpunum>
f010410b:	6b d0 74             	imul   $0x74,%eax,%edx
f010410e:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104114:	b8 01 00 00 00       	mov    $0x1,%eax
f0104119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010411d:	83 f8 02             	cmp    $0x2,%eax
f0104120:	75 10                	jne    f0104132 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104122:	83 ec 0c             	sub    $0xc,%esp
f0104125:	68 c0 03 12 f0       	push   $0xf01203c0
f010412a:	e8 a1 1c 00 00       	call   f0105dd0 <spin_lock>
f010412f:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104132:	9c                   	pushf  
f0104133:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104134:	f6 c4 02             	test   $0x2,%ah
f0104137:	74 19                	je     f0104152 <trap+0x5f>
f0104139:	68 49 78 10 f0       	push   $0xf0107849
f010413e:	68 47 72 10 f0       	push   $0xf0107247
f0104143:	68 d2 01 00 00       	push   $0x1d2
f0104148:	68 27 78 10 f0       	push   $0xf0107827
f010414d:	e8 42 bf ff ff       	call   f0100094 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104152:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104156:	83 e0 03             	and    $0x3,%eax
f0104159:	66 83 f8 03          	cmp    $0x3,%ax
f010415d:	0f 85 a0 00 00 00    	jne    f0104203 <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104163:	e8 fa 19 00 00       	call   f0105b62 <cpunum>
f0104168:	6b c0 74             	imul   $0x74,%eax,%eax
f010416b:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104172:	75 19                	jne    f010418d <trap+0x9a>
f0104174:	68 62 78 10 f0       	push   $0xf0107862
f0104179:	68 47 72 10 f0       	push   $0xf0107247
f010417e:	68 d9 01 00 00       	push   $0x1d9
f0104183:	68 27 78 10 f0       	push   $0xf0107827
f0104188:	e8 07 bf ff ff       	call   f0100094 <_panic>
f010418d:	83 ec 0c             	sub    $0xc,%esp
f0104190:	68 c0 03 12 f0       	push   $0xf01203c0
f0104195:	e8 36 1c 00 00       	call   f0105dd0 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010419a:	e8 c3 19 00 00       	call   f0105b62 <cpunum>
f010419f:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a2:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01041a8:	83 c4 10             	add    $0x10,%esp
f01041ab:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01041af:	75 2d                	jne    f01041de <trap+0xeb>
			env_free(curenv);
f01041b1:	e8 ac 19 00 00       	call   f0105b62 <cpunum>
f01041b6:	83 ec 0c             	sub    $0xc,%esp
f01041b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01041bc:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01041c2:	e8 29 f2 ff ff       	call   f01033f0 <env_free>
			curenv = NULL;
f01041c7:	e8 96 19 00 00       	call   f0105b62 <cpunum>
f01041cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01041cf:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01041d6:	00 00 00 
			sched_yield();
f01041d9:	e8 36 03 00 00       	call   f0104514 <sched_yield>
		}
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01041de:	e8 7f 19 00 00       	call   f0105b62 <cpunum>
f01041e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01041e6:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01041ec:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041f1:	89 c7                	mov    %eax,%edi
f01041f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041f5:	e8 68 19 00 00       	call   f0105b62 <cpunum>
f01041fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01041fd:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104203:	89 35 60 fa 22 f0    	mov    %esi,0xf022fa60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104209:	8b 46 28             	mov    0x28(%esi),%eax
f010420c:	83 f8 27             	cmp    $0x27,%eax
f010420f:	75 1d                	jne    f010422e <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0104211:	83 ec 0c             	sub    $0xc,%esp
f0104214:	68 69 78 10 f0       	push   $0xf0107869
f0104219:	e8 6a f6 ff ff       	call   f0103888 <cprintf>
		print_trapframe(tf);
f010421e:	89 34 24             	mov    %esi,(%esp)
f0104221:	e8 b5 fb ff ff       	call   f0103ddb <print_trapframe>
f0104226:	83 c4 10             	add    $0x10,%esp
f0104229:	e9 c9 00 00 00       	jmp    f01042f7 <trap+0x204>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
f010422e:	83 f8 20             	cmp    $0x20,%eax
f0104231:	75 1a                	jne    f010424d <trap+0x15a>
		cprintf("\t\t we are at clock interrupt.\n");
f0104233:	83 ec 0c             	sub    $0xc,%esp
f0104236:	68 74 7a 10 f0       	push   $0xf0107a74
f010423b:	e8 48 f6 ff ff       	call   f0103888 <cprintf>
		lapic_eoi();
f0104240:	e8 68 1a 00 00       	call   f0105cad <lapic_eoi>
f0104245:	83 c4 10             	add    $0x10,%esp
f0104248:	e9 aa 00 00 00       	jmp    f01042f7 <trap+0x204>
	//	sched_yield();
		return ;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	switch(tf->tf_trapno){
f010424d:	83 f8 0e             	cmp    $0xe,%eax
f0104250:	74 0c                	je     f010425e <trap+0x16b>
f0104252:	83 f8 30             	cmp    $0x30,%eax
f0104255:	74 2f                	je     f0104286 <trap+0x193>
f0104257:	83 f8 03             	cmp    $0x3,%eax
f010425a:	75 58                	jne    f01042b4 <trap+0x1c1>
f010425c:	eb 1a                	jmp    f0104278 <trap+0x185>
		case T_PGFLT:
			cprintf("\tT_PGFLT.\n");
f010425e:	83 ec 0c             	sub    $0xc,%esp
f0104261:	68 86 78 10 f0       	push   $0xf0107886
f0104266:	e8 1d f6 ff ff       	call   f0103888 <cprintf>
			page_fault_handler(tf);
f010426b:	89 34 24             	mov    %esi,(%esp)
f010426e:	e8 f0 fc ff ff       	call   f0103f63 <page_fault_handler>
f0104273:	83 c4 10             	add    $0x10,%esp
f0104276:	eb 7f                	jmp    f01042f7 <trap+0x204>
			return;
		case T_BRKPT:
			//cprintf("Function:trap_dispatch()->T_BRKPT.\n");
			monitor(tf);
f0104278:	83 ec 0c             	sub    $0xc,%esp
f010427b:	56                   	push   %esi
f010427c:	e8 df c6 ff ff       	call   f0100960 <monitor>
f0104281:	83 c4 10             	add    $0x10,%esp
f0104284:	eb 71                	jmp    f01042f7 <trap+0x204>
			return;
		case T_SYSCALL:
			cprintf("\tT_SYSCALL.\n");
f0104286:	83 ec 0c             	sub    $0xc,%esp
f0104289:	68 91 78 10 f0       	push   $0xf0107891
f010428e:	e8 f5 f5 ff ff       	call   f0103888 <cprintf>
			tf->tf_regs.reg_eax = syscall(
f0104293:	83 c4 08             	add    $0x8,%esp
f0104296:	ff 76 04             	pushl  0x4(%esi)
f0104299:	ff 36                	pushl  (%esi)
f010429b:	ff 76 10             	pushl  0x10(%esi)
f010429e:	ff 76 18             	pushl  0x18(%esi)
f01042a1:	ff 76 14             	pushl  0x14(%esi)
f01042a4:	ff 76 1c             	pushl  0x1c(%esi)
f01042a7:	e8 49 03 00 00       	call   f01045f5 <syscall>
f01042ac:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042af:	83 c4 20             	add    $0x20,%esp
f01042b2:	eb 43                	jmp    f01042f7 <trap+0x204>
       				 tf->tf_regs.reg_esi
   			 );
  			  return;
		default:break;
	}
	print_trapframe(tf);
f01042b4:	83 ec 0c             	sub    $0xc,%esp
f01042b7:	56                   	push   %esi
f01042b8:	e8 1e fb ff ff       	call   f0103ddb <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01042bd:	83 c4 10             	add    $0x10,%esp
f01042c0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01042c5:	75 17                	jne    f01042de <trap+0x1eb>
		panic("unhandled trap in kernel");
f01042c7:	83 ec 04             	sub    $0x4,%esp
f01042ca:	68 9e 78 10 f0       	push   $0xf010789e
f01042cf:	68 b7 01 00 00       	push   $0x1b7
f01042d4:	68 27 78 10 f0       	push   $0xf0107827
f01042d9:	e8 b6 bd ff ff       	call   f0100094 <_panic>
	else {
		env_destroy(curenv);
f01042de:	e8 7f 18 00 00       	call   f0105b62 <cpunum>
f01042e3:	83 ec 0c             	sub    $0xc,%esp
f01042e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01042e9:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01042ef:	e8 d7 f2 ff ff       	call   f01035cb <env_destroy>
f01042f4:	83 c4 10             	add    $0x10,%esp


	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if(curenv && curenv->env_status == ENV_RUNNING)
f01042f7:	e8 66 18 00 00       	call   f0105b62 <cpunum>
f01042fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ff:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104306:	74 2a                	je     f0104332 <trap+0x23f>
f0104308:	e8 55 18 00 00       	call   f0105b62 <cpunum>
f010430d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104310:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104316:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010431a:	75 16                	jne    f0104332 <trap+0x23f>
		env_run(curenv);
f010431c:	e8 41 18 00 00       	call   f0105b62 <cpunum>
f0104321:	83 ec 0c             	sub    $0xc,%esp
f0104324:	6b c0 74             	imul   $0x74,%eax,%eax
f0104327:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010432d:	e8 38 f3 ff ff       	call   f010366a <env_run>
	else
		sched_yield();
f0104332:	e8 dd 01 00 00       	call   f0104514 <sched_yield>
f0104337:	90                   	nop

f0104338 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f0104338:	6a 00                	push   $0x0
f010433a:	6a 00                	push   $0x0
f010433c:	e9 ef 00 00 00       	jmp    f0104430 <_alltraps>
f0104341:	90                   	nop

f0104342 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);        // 1
f0104342:	6a 00                	push   $0x0
f0104344:	6a 01                	push   $0x1
f0104346:	e9 e5 00 00 00       	jmp    f0104430 <_alltraps>
f010434b:	90                   	nop

f010434c <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);            // 2
f010434c:	6a 00                	push   $0x0
f010434e:	6a 02                	push   $0x2
f0104350:	e9 db 00 00 00       	jmp    f0104430 <_alltraps>
f0104355:	90                   	nop

f0104356 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)        // 3
f0104356:	6a 00                	push   $0x0
f0104358:	6a 03                	push   $0x3
f010435a:	e9 d1 00 00 00       	jmp    f0104430 <_alltraps>
f010435f:	90                   	nop

f0104360 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)        // 4
f0104360:	6a 00                	push   $0x0
f0104362:	6a 04                	push   $0x4
f0104364:	e9 c7 00 00 00       	jmp    f0104430 <_alltraps>
f0104369:	90                   	nop

f010436a <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)        // 5
f010436a:	6a 00                	push   $0x0
f010436c:	6a 05                	push   $0x5
f010436e:	e9 bd 00 00 00       	jmp    f0104430 <_alltraps>
f0104373:	90                   	nop

f0104374 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)        // 6
f0104374:	6a 00                	push   $0x0
f0104376:	6a 06                	push   $0x6
f0104378:	e9 b3 00 00 00       	jmp    f0104430 <_alltraps>
f010437d:	90                   	nop

f010437e <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)    // 7
f010437e:	6a 00                	push   $0x0
f0104380:	6a 07                	push   $0x7
f0104382:	e9 a9 00 00 00       	jmp    f0104430 <_alltraps>
f0104387:	90                   	nop

f0104388 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)            // 8
f0104388:	6a 08                	push   $0x8
f010438a:	e9 a1 00 00 00       	jmp    f0104430 <_alltraps>
f010438f:	90                   	nop

f0104390 <t_tss>:
                                        // 9
TRAPHANDLER(t_tss, T_TSS)                // 10
f0104390:	6a 0a                	push   $0xa
f0104392:	e9 99 00 00 00       	jmp    f0104430 <_alltraps>
f0104397:	90                   	nop

f0104398 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)            // 11
f0104398:	6a 0b                	push   $0xb
f010439a:	e9 91 00 00 00       	jmp    f0104430 <_alltraps>
f010439f:	90                   	nop

f01043a0 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)            // 12
f01043a0:	6a 0c                	push   $0xc
f01043a2:	e9 89 00 00 00       	jmp    f0104430 <_alltraps>
f01043a7:	90                   	nop

f01043a8 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)            // 13
f01043a8:	6a 0d                	push   $0xd
f01043aa:	e9 81 00 00 00       	jmp    f0104430 <_alltraps>
f01043af:	90                   	nop

f01043b0 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)            // 14
f01043b0:	6a 0e                	push   $0xe
f01043b2:	eb 7c                	jmp    f0104430 <_alltraps>

f01043b4 <t_fperr>:
                                        // 15
TRAPHANDLER_NOEC(t_fperr, T_FPERR)        // 16
f01043b4:	6a 00                	push   $0x0
f01043b6:	6a 10                	push   $0x10
f01043b8:	eb 76                	jmp    f0104430 <_alltraps>

f01043ba <t_align>:
TRAPHANDLER(t_align, T_ALIGN)            // 17
f01043ba:	6a 11                	push   $0x11
f01043bc:	eb 72                	jmp    f0104430 <_alltraps>

f01043be <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)        // 18
f01043be:	6a 00                	push   $0x0
f01043c0:	6a 12                	push   $0x12
f01043c2:	eb 6c                	jmp    f0104430 <_alltraps>

f01043c4 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)    // 19
f01043c4:	6a 00                	push   $0x0
f01043c6:	6a 13                	push   $0x13
f01043c8:	eb 66                	jmp    f0104430 <_alltraps>

f01043ca <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01043ca:	6a 00                	push   $0x0
f01043cc:	6a 30                	push   $0x30
f01043ce:	eb 60                	jmp    f0104430 <_alltraps>

f01043d0 <iqr0>:

/*registe iqr function to handle interrupt.*/
TRAPHANDLER_NOEC(iqr0, 32) 
f01043d0:	6a 00                	push   $0x0
f01043d2:	6a 20                	push   $0x20
f01043d4:	eb 5a                	jmp    f0104430 <_alltraps>

f01043d6 <iqr1>:
TRAPHANDLER_NOEC(iqr1, 33) 
f01043d6:	6a 00                	push   $0x0
f01043d8:	6a 21                	push   $0x21
f01043da:	eb 54                	jmp    f0104430 <_alltraps>

f01043dc <iqr2>:
TRAPHANDLER_NOEC(iqr2, 34) 
f01043dc:	6a 00                	push   $0x0
f01043de:	6a 22                	push   $0x22
f01043e0:	eb 4e                	jmp    f0104430 <_alltraps>

f01043e2 <iqr3>:
TRAPHANDLER_NOEC(iqr3, 35) 
f01043e2:	6a 00                	push   $0x0
f01043e4:	6a 23                	push   $0x23
f01043e6:	eb 48                	jmp    f0104430 <_alltraps>

f01043e8 <iqr4>:
TRAPHANDLER_NOEC(iqr4, 36) 
f01043e8:	6a 00                	push   $0x0
f01043ea:	6a 24                	push   $0x24
f01043ec:	eb 42                	jmp    f0104430 <_alltraps>

f01043ee <iqr5>:
TRAPHANDLER_NOEC(iqr5, 37) 
f01043ee:	6a 00                	push   $0x0
f01043f0:	6a 25                	push   $0x25
f01043f2:	eb 3c                	jmp    f0104430 <_alltraps>

f01043f4 <iqr6>:
TRAPHANDLER_NOEC(iqr6, 38) 
f01043f4:	6a 00                	push   $0x0
f01043f6:	6a 26                	push   $0x26
f01043f8:	eb 36                	jmp    f0104430 <_alltraps>

f01043fa <iqr7>:
TRAPHANDLER_NOEC(iqr7, 39) 
f01043fa:	6a 00                	push   $0x0
f01043fc:	6a 27                	push   $0x27
f01043fe:	eb 30                	jmp    f0104430 <_alltraps>

f0104400 <iqr8>:
TRAPHANDLER_NOEC(iqr8, 40) 
f0104400:	6a 00                	push   $0x0
f0104402:	6a 28                	push   $0x28
f0104404:	eb 2a                	jmp    f0104430 <_alltraps>

f0104406 <iqr9>:
TRAPHANDLER_NOEC(iqr9, 41) 
f0104406:	6a 00                	push   $0x0
f0104408:	6a 29                	push   $0x29
f010440a:	eb 24                	jmp    f0104430 <_alltraps>

f010440c <iqr10>:
TRAPHANDLER_NOEC(iqr10, 42) 
f010440c:	6a 00                	push   $0x0
f010440e:	6a 2a                	push   $0x2a
f0104410:	eb 1e                	jmp    f0104430 <_alltraps>

f0104412 <iqr11>:
TRAPHANDLER_NOEC(iqr11, 43) 
f0104412:	6a 00                	push   $0x0
f0104414:	6a 2b                	push   $0x2b
f0104416:	eb 18                	jmp    f0104430 <_alltraps>

f0104418 <iqr12>:
TRAPHANDLER_NOEC(iqr12, 44) 
f0104418:	6a 00                	push   $0x0
f010441a:	6a 2c                	push   $0x2c
f010441c:	eb 12                	jmp    f0104430 <_alltraps>

f010441e <iqr13>:
TRAPHANDLER_NOEC(iqr13, 45) 
f010441e:	6a 00                	push   $0x0
f0104420:	6a 2d                	push   $0x2d
f0104422:	eb 0c                	jmp    f0104430 <_alltraps>

f0104424 <iqr14>:
TRAPHANDLER_NOEC(iqr14, 46) 
f0104424:	6a 00                	push   $0x0
f0104426:	6a 2e                	push   $0x2e
f0104428:	eb 06                	jmp    f0104430 <_alltraps>

f010442a <iqr15>:
TRAPHANDLER_NOEC(iqr15, 47)
f010442a:	6a 00                	push   $0x0
f010442c:	6a 2f                	push   $0x2f
f010442e:	eb 00                	jmp    f0104430 <_alltraps>

f0104430 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f0104430:	1e                   	push   %ds
	pushl %es
f0104431:	06                   	push   %es
	pushal
f0104432:	60                   	pusha  

	movw $GD_KD,%eax
f0104433:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax,%ds
f0104437:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f0104439:	8e c0                	mov    %eax,%es

	pushl %esp
f010443b:	54                   	push   %esp
	call trap
f010443c:	e8 b2 fc ff ff       	call   f01040f3 <trap>

f0104441 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104441:	55                   	push   %ebp
f0104442:	89 e5                	mov    %esp,%ebp
f0104444:	83 ec 08             	sub    $0x8,%esp
f0104447:	a1 44 f2 22 f0       	mov    0xf022f244,%eax
f010444c:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010444f:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104454:	8b 02                	mov    (%edx),%eax
f0104456:	83 e8 01             	sub    $0x1,%eax
f0104459:	83 f8 02             	cmp    $0x2,%eax
f010445c:	76 10                	jbe    f010446e <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010445e:	83 c1 01             	add    $0x1,%ecx
f0104461:	83 c2 7c             	add    $0x7c,%edx
f0104464:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010446a:	75 e8                	jne    f0104454 <sched_halt+0x13>
f010446c:	eb 08                	jmp    f0104476 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010446e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104474:	75 1f                	jne    f0104495 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104476:	83 ec 0c             	sub    $0xc,%esp
f0104479:	68 f0 7a 10 f0       	push   $0xf0107af0
f010447e:	e8 05 f4 ff ff       	call   f0103888 <cprintf>
f0104483:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104486:	83 ec 0c             	sub    $0xc,%esp
f0104489:	6a 00                	push   $0x0
f010448b:	e8 d0 c4 ff ff       	call   f0100960 <monitor>
f0104490:	83 c4 10             	add    $0x10,%esp
f0104493:	eb f1                	jmp    f0104486 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104495:	e8 c8 16 00 00       	call   f0105b62 <cpunum>
f010449a:	6b c0 74             	imul   $0x74,%eax,%eax
f010449d:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01044a4:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01044a7:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01044ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01044b1:	77 12                	ja     f01044c5 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01044b3:	50                   	push   %eax
f01044b4:	68 e8 62 10 f0       	push   $0xf01062e8
f01044b9:	6a 6c                	push   $0x6c
f01044bb:	68 19 7b 10 f0       	push   $0xf0107b19
f01044c0:	e8 cf bb ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01044c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01044ca:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01044cd:	e8 90 16 00 00       	call   f0105b62 <cpunum>
f01044d2:	6b d0 74             	imul   $0x74,%eax,%edx
f01044d5:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01044db:	b8 02 00 00 00       	mov    $0x2,%eax
f01044e0:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01044e4:	83 ec 0c             	sub    $0xc,%esp
f01044e7:	68 c0 03 12 f0       	push   $0xf01203c0
f01044ec:	e8 7c 19 00 00       	call   f0105e6d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01044f1:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01044f3:	e8 6a 16 00 00       	call   f0105b62 <cpunum>
f01044f8:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01044fb:	8b 80 30 00 23 f0    	mov    -0xfdcffd0(%eax),%eax
f0104501:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104506:	89 c4                	mov    %eax,%esp
f0104508:	6a 00                	push   $0x0
f010450a:	6a 00                	push   $0x0
f010450c:	f4                   	hlt    
f010450d:	eb fd                	jmp    f010450c <sched_halt+0xcb>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010450f:	83 c4 10             	add    $0x10,%esp
f0104512:	c9                   	leave  
f0104513:	c3                   	ret    

f0104514 <sched_yield>:
};
*/
// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104514:	55                   	push   %ebp
f0104515:	89 e5                	mov    %esp,%ebp
f0104517:	57                   	push   %edi
f0104518:	56                   	push   %esi
f0104519:	53                   	push   %ebx
f010451a:	83 ec 18             	sub    $0x18,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
f010451d:	68 26 7b 10 f0       	push   $0xf0107b26
f0104522:	e8 61 f3 ff ff       	call   f0103888 <cprintf>
	int running_env_id = -1;
	if(curenv == 0){
f0104527:	e8 36 16 00 00       	call   f0105b62 <cpunum>
f010452c:	6b d0 74             	imul   $0x74,%eax,%edx
f010452f:	83 c4 10             	add    $0x10,%esp
		running_env_id = -1;
f0104532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
	int running_env_id = -1;
	if(curenv == 0){
f0104537:	83 ba 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%edx)
f010453e:	74 16                	je     f0104556 <sched_yield+0x42>
		running_env_id = -1;
	}else{
		//cprintf("\t WE MAY CRUSH HERE.\n");
		running_env_id = ENVX(curenv->env_id);
f0104540:	e8 1d 16 00 00       	call   f0105b62 <cpunum>
f0104545:	6b c0 74             	imul   $0x74,%eax,%eax
f0104548:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010454e:	8b 40 48             	mov    0x48(%eax),%eax
f0104551:	25 ff 03 00 00       	and    $0x3ff,%eax
			running_env_id = 0;
		}else{
			running_env_id++;
		}

		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f0104556:	8b 3d 44 f2 22 f0    	mov    0xf022f244,%edi
f010455c:	ba 00 04 00 00       	mov    $0x400,%edx
	for(int i = 0;i<NENV;i++){

		if(running_env_id == NENV-1){
			running_env_id = 0;
		}else{
			running_env_id++;
f0104561:	be 00 00 00 00       	mov    $0x0,%esi
f0104566:	8d 48 01             	lea    0x1(%eax),%ecx
f0104569:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010456e:	89 c8                	mov    %ecx,%eax
f0104570:	0f 44 c6             	cmove  %esi,%eax
		}

		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f0104573:	6b c8 7c             	imul   $0x7c,%eax,%ecx
f0104576:	89 cb                	mov    %ecx,%ebx
f0104578:	83 7c 0f 54 02       	cmpl   $0x2,0x54(%edi,%ecx,1)
f010457d:	75 1c                	jne    f010459b <sched_yield+0x87>
			cprintf("\tWE ARE RUNNING ENV_ID IS:%d\n",running_env_id);
f010457f:	83 ec 08             	sub    $0x8,%esp
f0104582:	50                   	push   %eax
f0104583:	68 3c 7b 10 f0       	push   $0xf0107b3c
f0104588:	e8 fb f2 ff ff       	call   f0103888 <cprintf>
			//env_run(&envs[0]);
			env_run(&envs[running_env_id]);			
f010458d:	03 1d 44 f2 22 f0    	add    0xf022f244,%ebx
f0104593:	89 1c 24             	mov    %ebx,(%esp)
f0104596:	e8 cf f0 ff ff       	call   f010366a <env_run>
		//cprintf("\t WE MAY CRUSH HERE.\n");
		running_env_id = ENVX(curenv->env_id);
	}
	//cprintf("the real running env_id:%d\n",ENVX(curenv->env_id));
	//cprintf("The running_env_id is:%d\n",running_env_id);
	for(int i = 0;i<NENV;i++){
f010459b:	83 ea 01             	sub    $0x1,%edx
f010459e:	75 c6                	jne    f0104566 <sched_yield+0x52>
	}
	//if the code run here,it says that there is only one env which is
	//running but now and here we are in kern mode,so if we don't chose
	//the running env to run we will trap in sched_halt().AND WE ARE AT
	//KERNEL MODE!
	if(curenv && curenv->env_status == ENV_RUNNING){
f01045a0:	e8 bd 15 00 00       	call   f0105b62 <cpunum>
f01045a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a8:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f01045af:	74 37                	je     f01045e8 <sched_yield+0xd4>
f01045b1:	e8 ac 15 00 00       	call   f0105b62 <cpunum>
f01045b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b9:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01045bf:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01045c3:	75 23                	jne    f01045e8 <sched_yield+0xd4>
		cprintf("I AM THE ONLY ONE ENV.\n");
f01045c5:	83 ec 0c             	sub    $0xc,%esp
f01045c8:	68 5a 7b 10 f0       	push   $0xf0107b5a
f01045cd:	e8 b6 f2 ff ff       	call   f0103888 <cprintf>
		env_run(curenv);
f01045d2:	e8 8b 15 00 00       	call   f0105b62 <cpunum>
f01045d7:	83 c4 04             	add    $0x4,%esp
f01045da:	6b c0 74             	imul   $0x74,%eax,%eax
f01045dd:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01045e3:	e8 82 f0 ff ff       	call   f010366a <env_run>
		return;
	}
	// sched_halt never returns
	sched_halt();
f01045e8:	e8 54 fe ff ff       	call   f0104441 <sched_halt>
}
f01045ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045f0:	5b                   	pop    %ebx
f01045f1:	5e                   	pop    %esi
f01045f2:	5f                   	pop    %edi
f01045f3:	5d                   	pop    %ebp
f01045f4:	c3                   	ret    

f01045f5 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045f5:	55                   	push   %ebp
f01045f6:	89 e5                	mov    %esp,%ebp
f01045f8:	53                   	push   %ebx
f01045f9:	83 ec 14             	sub    $0x14,%esp
f01045fc:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
f01045ff:	83 f8 0a             	cmp    $0xa,%eax
f0104602:	0f 87 90 04 00 00    	ja     f0104a98 <syscall+0x4a3>
f0104608:	ff 24 85 24 7c 10 f0 	jmp    *-0xfef83dc(,%eax,4)
	// LAB 3: Your code here.


	struct Env *e;
	//envid2env(sys_getenvid(), &e, 1);
	user_mem_assert(curenv, s, len, PTE_U);
f010460f:	e8 4e 15 00 00       	call   f0105b62 <cpunum>
f0104614:	6a 04                	push   $0x4
f0104616:	ff 75 10             	pushl  0x10(%ebp)
f0104619:	ff 75 0c             	pushl  0xc(%ebp)
f010461c:	6b c0 74             	imul   $0x74,%eax,%eax
f010461f:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104625:	e8 99 e8 ff ff       	call   f0102ec3 <user_mem_assert>

	cprintf("%.*s", len, s);
f010462a:	83 c4 0c             	add    $0xc,%esp
f010462d:	ff 75 0c             	pushl  0xc(%ebp)
f0104630:	ff 75 10             	pushl  0x10(%ebp)
f0104633:	68 72 7b 10 f0       	push   $0xf0107b72
f0104638:	e8 4b f2 ff ff       	call   f0103888 <cprintf>
f010463d:	83 c4 10             	add    $0x10,%esp
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104640:	e8 19 c0 ff ff       	call   f010065e <cons_getc>
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
       	       case SYS_cputs:
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
f0104645:	e9 53 04 00 00       	jmp    f0104a9d <syscall+0x4a8>
       	       case SYS_getenvid:
           		 assert(curenv);
f010464a:	e8 13 15 00 00       	call   f0105b62 <cpunum>
f010464f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104652:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104659:	75 19                	jne    f0104674 <syscall+0x7f>
f010465b:	68 62 78 10 f0       	push   $0xf0107862
f0104660:	68 47 72 10 f0       	push   $0xf0107247
f0104665:	68 87 01 00 00       	push   $0x187
f010466a:	68 77 7b 10 f0       	push   $0xf0107b77
f010466f:	e8 20 ba ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104674:	e8 e9 14 00 00       	call   f0105b62 <cpunum>
f0104679:	6b c0 74             	imul   $0x74,%eax,%eax
f010467c:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104682:	8b 40 48             	mov    0x48(%eax),%eax
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
       	       case SYS_getenvid:
           		 assert(curenv);
            		return sys_getenvid();
f0104685:	e9 13 04 00 00       	jmp    f0104a9d <syscall+0x4a8>
       	       case SYS_env_destroy:
          		  assert(curenv);
f010468a:	e8 d3 14 00 00       	call   f0105b62 <cpunum>
f010468f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104692:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104699:	75 19                	jne    f01046b4 <syscall+0xbf>
f010469b:	68 62 78 10 f0       	push   $0xf0107862
f01046a0:	68 47 72 10 f0       	push   $0xf0107247
f01046a5:	68 8a 01 00 00       	push   $0x18a
f01046aa:	68 77 7b 10 f0       	push   $0xf0107b77
f01046af:	e8 e0 b9 ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046b4:	e8 a9 14 00 00       	call   f0105b62 <cpunum>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046b9:	83 ec 04             	sub    $0x4,%esp
f01046bc:	6a 01                	push   $0x1
f01046be:	8d 55 f4             	lea    -0xc(%ebp),%edx
f01046c1:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c5:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01046cb:	ff 70 48             	pushl  0x48(%eax)
f01046ce:	e8 cc e8 ff ff       	call   f0102f9f <envid2env>
f01046d3:	83 c4 10             	add    $0x10,%esp
f01046d6:	85 c0                	test   %eax,%eax
f01046d8:	0f 88 bf 03 00 00    	js     f0104a9d <syscall+0x4a8>
		return r;
	if (e == curenv)
f01046de:	e8 7f 14 00 00       	call   f0105b62 <cpunum>
f01046e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01046e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e9:	39 90 28 00 23 f0    	cmp    %edx,-0xfdcffd8(%eax)
f01046ef:	75 23                	jne    f0104714 <syscall+0x11f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01046f1:	e8 6c 14 00 00       	call   f0105b62 <cpunum>
f01046f6:	83 ec 08             	sub    $0x8,%esp
f01046f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01046fc:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104702:	ff 70 48             	pushl  0x48(%eax)
f0104705:	68 86 7b 10 f0       	push   $0xf0107b86
f010470a:	e8 79 f1 ff ff       	call   f0103888 <cprintf>
f010470f:	83 c4 10             	add    $0x10,%esp
f0104712:	eb 25                	jmp    f0104739 <syscall+0x144>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104714:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104717:	e8 46 14 00 00       	call   f0105b62 <cpunum>
f010471c:	83 ec 04             	sub    $0x4,%esp
f010471f:	53                   	push   %ebx
f0104720:	6b c0 74             	imul   $0x74,%eax,%eax
f0104723:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104729:	ff 70 48             	pushl  0x48(%eax)
f010472c:	68 a1 7b 10 f0       	push   $0xf0107ba1
f0104731:	e8 52 f1 ff ff       	call   f0103888 <cprintf>
f0104736:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104739:	83 ec 0c             	sub    $0xc,%esp
f010473c:	ff 75 f4             	pushl  -0xc(%ebp)
f010473f:	e8 87 ee ff ff       	call   f01035cb <env_destroy>
f0104744:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104747:	b8 00 00 00 00       	mov    $0x0,%eax
f010474c:	e9 4c 03 00 00       	jmp    f0104a9d <syscall+0x4a8>
            		return sys_getenvid();
       	       case SYS_env_destroy:
          		  assert(curenv);
            		return sys_env_destroy(sys_getenvid());
	       case SYS_yield:
			assert(curenv);
f0104751:	e8 0c 14 00 00       	call   f0105b62 <cpunum>
f0104756:	6b c0 74             	imul   $0x74,%eax,%eax
f0104759:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0104760:	75 19                	jne    f010477b <syscall+0x186>
f0104762:	68 62 78 10 f0       	push   $0xf0107862
f0104767:	68 47 72 10 f0       	push   $0xf0107247
f010476c:	68 8d 01 00 00       	push   $0x18d
f0104771:	68 77 7b 10 f0       	push   $0xf0107b77
f0104776:	e8 19 b9 ff ff       	call   f0100094 <_panic>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010477b:	e8 94 fd ff ff       	call   f0104514 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env * newenv_store;
	if(curenv->env_id == 0)
f0104780:	e8 dd 13 00 00       	call   f0105b62 <cpunum>
f0104785:	6b c0 74             	imul   $0x74,%eax,%eax
f0104788:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010478e:	8b 40 48             	mov    0x48(%eax),%eax
f0104791:	85 c0                	test   %eax,%eax
f0104793:	0f 84 04 03 00 00    	je     f0104a9d <syscall+0x4a8>
		return 0;
	int r_env_alloc = env_alloc(&newenv_store,curenv->env_id);
f0104799:	e8 c4 13 00 00       	call   f0105b62 <cpunum>
f010479e:	83 ec 08             	sub    $0x8,%esp
f01047a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047a4:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01047aa:	ff 70 48             	pushl  0x48(%eax)
f01047ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01047b0:	50                   	push   %eax
f01047b1:	e8 4d e9 ff ff       	call   f0103103 <env_alloc>
	
	if(r_env_alloc<0)
f01047b6:	83 c4 10             	add    $0x10,%esp
f01047b9:	85 c0                	test   %eax,%eax
f01047bb:	0f 88 dc 02 00 00    	js     f0104a9d <syscall+0x4a8>
		return r_env_alloc;
	
	newenv_store->env_status = ENV_NOT_RUNNABLE;
f01047c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047c4:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove(&newenv_store->env_tf,&curenv->env_tf,sizeof(curenv->env_tf));
f01047cb:	e8 92 13 00 00       	call   f0105b62 <cpunum>
f01047d0:	83 ec 04             	sub    $0x4,%esp
f01047d3:	6a 44                	push   $0x44
f01047d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d8:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01047de:	ff 75 f4             	pushl  -0xc(%ebp)
f01047e1:	e8 a8 0d 00 00       	call   f010558e <memmove>
	newenv_store->env_tf.tf_regs.reg_eax =0;
f01047e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047e9:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv_store->env_id;
f01047f0:	8b 40 48             	mov    0x48(%eax),%eax
f01047f3:	83 c4 10             	add    $0x10,%esp
f01047f6:	e9 a2 02 00 00       	jmp    f0104a9d <syscall+0x4a8>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01047fb:	83 ec 04             	sub    $0x4,%esp
f01047fe:	6a 01                	push   $0x1
f0104800:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104803:	50                   	push   %eax
f0104804:	ff 75 0c             	pushl  0xc(%ebp)
f0104807:	e8 93 e7 ff ff       	call   f0102f9f <envid2env>
	if(r_value)
f010480c:	83 c4 10             	add    $0x10,%esp
f010480f:	85 c0                	test   %eax,%eax
f0104811:	0f 85 86 02 00 00    	jne    f0104a9d <syscall+0x4a8>
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0104817:	8b 45 10             	mov    0x10(%ebp),%eax
f010481a:	83 e8 02             	sub    $0x2,%eax
f010481d:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104822:	75 13                	jne    f0104837 <syscall+0x242>
		return -E_INVAL;
	newenv_store->env_status = status;
f0104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104827:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010482a:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f010482d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104832:	e9 66 02 00 00       	jmp    f0104a9d <syscall+0x4a8>
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f0104837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			sys_yield();
			return 1;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f010483c:	e9 5c 02 00 00       	jmp    f0104a9d <syscall+0x4a8>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	//panic("\t we panic at sys_env_set_pgfault_upcall.\n");
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f0104841:	83 ec 04             	sub    $0x4,%esp
f0104844:	6a 01                	push   $0x1
f0104846:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104849:	50                   	push   %eax
f010484a:	ff 75 0c             	pushl  0xc(%ebp)
f010484d:	e8 4d e7 ff ff       	call   f0102f9f <envid2env>
f0104852:	89 c3                	mov    %eax,%ebx
	if(r_value){
f0104854:	83 c4 10             	add    $0x10,%esp
f0104857:	85 c0                	test   %eax,%eax
f0104859:	75 1a                	jne    f0104875 <syscall+0x280>
		return r_value;
	}
	newenv_store->env_pgfault_upcall = func;	
f010485b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010485e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104861:	89 48 64             	mov    %ecx,0x64(%eax)
	cprintf("\tnewenv_store->env_pgfault_upcall is:%d\n",newenv_store->env_pgfault_upcall);
f0104864:	83 ec 08             	sub    $0x8,%esp
f0104867:	51                   	push   %ecx
f0104868:	68 bc 7b 10 f0       	push   $0xf0107bbc
f010486d:	e8 16 f0 ff ff       	call   f0103888 <cprintf>
f0104872:	83 c4 10             	add    $0x10,%esp
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
f0104875:	89 d8                	mov    %ebx,%eax
f0104877:	e9 21 02 00 00       	jmp    f0104a9d <syscall+0x4a8>
	//   allocated!

	// LAB 4: Your code here.
//	cprintf("the kernel env index is:%d\n",ENVX(curenv->env_id));
	struct Env *newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f010487c:	83 ec 04             	sub    $0x4,%esp
f010487f:	6a 01                	push   $0x1
f0104881:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104884:	50                   	push   %eax
f0104885:	ff 75 0c             	pushl  0xc(%ebp)
f0104888:	e8 12 e7 ff ff       	call   f0102f9f <envid2env>
	if(r_value)
f010488d:	83 c4 10             	add    $0x10,%esp
f0104890:	85 c0                	test   %eax,%eax
f0104892:	0f 85 05 02 00 00    	jne    f0104a9d <syscall+0x4a8>
		return r_value;
	//cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
f0104898:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010489f:	77 56                	ja     f01048f7 <syscall+0x302>
f01048a1:	8b 45 10             	mov    0x10(%ebp),%eax
f01048a4:	c1 e0 14             	shl    $0x14,%eax
f01048a7:	85 c0                	test   %eax,%eax
f01048a9:	75 56                	jne    f0104901 <syscall+0x30c>
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f01048ab:	8b 55 14             	mov    0x14(%ebp),%edx
f01048ae:	83 e2 fd             	and    $0xfffffffd,%edx
f01048b1:	83 fa 05             	cmp    $0x5,%edx
f01048b4:	74 11                	je     f01048c7 <syscall+0x2d2>
		return -E_INVAL;
f01048b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f01048bb:	81 fa 05 0e 00 00    	cmp    $0xe05,%edx
f01048c1:	0f 85 d6 01 00 00    	jne    f0104a9d <syscall+0x4a8>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
f01048c7:	83 ec 0c             	sub    $0xc,%esp
f01048ca:	6a 00                	push   $0x0
f01048cc:	e8 ad c6 ff ff       	call   f0100f7e <page_alloc>
	if(!pp)
f01048d1:	83 c4 10             	add    $0x10,%esp
f01048d4:	85 c0                	test   %eax,%eax
f01048d6:	74 33                	je     f010490b <syscall+0x316>
		return -E_NO_MEM;

	int ret = page_insert(newenv_store->env_pgdir,pp,va,perm);	
f01048d8:	ff 75 14             	pushl  0x14(%ebp)
f01048db:	ff 75 10             	pushl  0x10(%ebp)
f01048de:	50                   	push   %eax
f01048df:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01048e2:	ff 70 60             	pushl  0x60(%eax)
f01048e5:	e8 83 ca ff ff       	call   f010136d <page_insert>
f01048ea:	83 c4 10             	add    $0x10,%esp
	if(!ret)
		return ret;
	return 0;
f01048ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01048f2:	e9 a6 01 00 00       	jmp    f0104a9d <syscall+0x4a8>
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	//cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
		return -E_INVAL;
f01048f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048fc:	e9 9c 01 00 00       	jmp    f0104a9d <syscall+0x4a8>
f0104901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104906:	e9 92 01 00 00       	jmp    f0104a9d <syscall+0x4a8>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
	if(!pp)
		return -E_NO_MEM;
f010490b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104910:	e9 88 01 00 00       	jmp    f0104a9d <syscall+0x4a8>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
f0104915:	83 ec 04             	sub    $0x4,%esp
f0104918:	6a 01                	push   $0x1
f010491a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010491d:	50                   	push   %eax
f010491e:	ff 75 0c             	pushl  0xc(%ebp)
f0104921:	e8 79 e6 ff ff       	call   f0102f9f <envid2env>
f0104926:	89 c3                	mov    %eax,%ebx
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
f0104928:	83 c4 0c             	add    $0xc,%esp
f010492b:	6a 01                	push   $0x1
f010492d:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104930:	50                   	push   %eax
f0104931:	ff 75 14             	pushl  0x14(%ebp)
f0104934:	e8 66 e6 ff ff       	call   f0102f9f <envid2env>
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
f0104939:	83 c4 10             	add    $0x10,%esp
f010493c:	83 fb fe             	cmp    $0xfffffffe,%ebx
f010493f:	0f 84 b6 00 00 00    	je     f01049fb <syscall+0x406>
f0104945:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104948:	0f 84 ad 00 00 00    	je     f01049fb <syscall+0x406>
		return -E_BAD_ENV;
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
f010494e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104955:	0f 87 aa 00 00 00    	ja     f0104a05 <syscall+0x410>
f010495b:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104962:	0f 87 9d 00 00 00    	ja     f0104a05 <syscall+0x410>
		return -E_INVAL;

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
f0104968:	8b 45 10             	mov    0x10(%ebp),%eax
f010496b:	c1 e0 14             	shl    $0x14,%eax
f010496e:	85 c0                	test   %eax,%eax
f0104970:	0f 85 99 00 00 00    	jne    f0104a0f <syscall+0x41a>
f0104976:	8b 45 18             	mov    0x18(%ebp),%eax
f0104979:	c1 e0 14             	shl    $0x14,%eax
f010497c:	85 c0                	test   %eax,%eax
f010497e:	0f 85 95 00 00 00    	jne    f0104a19 <syscall+0x424>
		return -E_INVAL;

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
f0104984:	83 ec 04             	sub    $0x4,%esp
f0104987:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010498a:	50                   	push   %eax
f010498b:	ff 75 10             	pushl  0x10(%ebp)
f010498e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104991:	ff 70 60             	pushl  0x60(%eax)
f0104994:	e8 f4 c8 ff ff       	call   f010128d <page_lookup>
f0104999:	89 c3                	mov    %eax,%ebx
	if(!pp)
f010499b:	83 c4 10             	add    $0x10,%esp
f010499e:	85 c0                	test   %eax,%eax
f01049a0:	74 7e                	je     f0104a20 <syscall+0x42b>
//	panic("sys_page_map run here.\n");
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if( (perm&PTE_U) && (perm&PTE_P) == 0) {
f01049a2:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01049a5:	83 e0 05             	and    $0x5,%eax
f01049a8:	83 f8 04             	cmp    $0x4,%eax
f01049ab:	74 7a                	je     f0104a27 <syscall+0x432>
		return -E_INVAL;
	}
	if(!( perm&PTE_W || perm&PTE_AVAIL )){
f01049ad:	f7 45 1c 02 0e 00 00 	testl  $0xe02,0x1c(%ebp)
f01049b4:	74 78                	je     f0104a2e <syscall+0x439>
		return -E_INVAL;
	}
//	panic("sys_page_map run here.\n");
	if(perm&PTE_W && !((*pte_store)&PTE_W))
f01049b6:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01049ba:	74 08                	je     f01049c4 <syscall+0x3cf>
f01049bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01049bf:	f6 00 02             	testb  $0x2,(%eax)
f01049c2:	74 71                	je     f0104a35 <syscall+0x440>
		return -E_INVAL;

	cprintf("error before page_insert newenv_store_dst: %x,dstva:%x .\n",newenv_store_dst,dstva);
f01049c4:	83 ec 04             	sub    $0x4,%esp
f01049c7:	ff 75 18             	pushl  0x18(%ebp)
f01049ca:	ff 75 f0             	pushl  -0x10(%ebp)
f01049cd:	68 e8 7b 10 f0       	push   $0xf0107be8
f01049d2:	e8 b1 ee ff ff       	call   f0103888 <cprintf>
	if(page_insert(newenv_store_dst->env_pgdir,pp,dstva,perm))
f01049d7:	ff 75 1c             	pushl  0x1c(%ebp)
f01049da:	ff 75 18             	pushl  0x18(%ebp)
f01049dd:	53                   	push   %ebx
f01049de:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01049e1:	ff 70 60             	pushl  0x60(%eax)
f01049e4:	e8 84 c9 ff ff       	call   f010136d <page_insert>
f01049e9:	83 c4 20             	add    $0x20,%esp
		return -E_NO_MEM;
f01049ec:	85 c0                	test   %eax,%eax
f01049ee:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f01049f3:	0f 45 c2             	cmovne %edx,%eax
f01049f6:	e9 a2 00 00 00       	jmp    f0104a9d <syscall+0x4a8>
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
		return -E_BAD_ENV;
f01049fb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a00:	e9 98 00 00 00       	jmp    f0104a9d <syscall+0x4a8>
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
		return -E_INVAL;
f0104a05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a0a:	e9 8e 00 00 00       	jmp    f0104a9d <syscall+0x4a8>

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
		return -E_INVAL;
f0104a0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a14:	e9 84 00 00 00       	jmp    f0104a9d <syscall+0x4a8>
f0104a19:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a1e:	eb 7d                	jmp    f0104a9d <syscall+0x4a8>

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
	if(!pp)
		return -E_INVAL;
f0104a20:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a25:	eb 76                	jmp    f0104a9d <syscall+0x4a8>
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if( (perm&PTE_U) && (perm&PTE_P) == 0) {
		return -E_INVAL;
f0104a27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a2c:	eb 6f                	jmp    f0104a9d <syscall+0x4a8>
	}
	if(!( perm&PTE_W || perm&PTE_AVAIL )){
		return -E_INVAL;
f0104a2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a33:	eb 68                	jmp    f0104a9d <syscall+0x4a8>
	}
//	panic("sys_page_map run here.\n");
	if(perm&PTE_W && !((*pte_store)&PTE_W))
		return -E_INVAL;
f0104a35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a3a:	eb 61                	jmp    f0104a9d <syscall+0x4a8>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f0104a3c:	83 ec 04             	sub    $0x4,%esp
f0104a3f:	6a 01                	push   $0x1
f0104a41:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104a44:	50                   	push   %eax
f0104a45:	ff 75 0c             	pushl  0xc(%ebp)
f0104a48:	e8 52 e5 ff ff       	call   f0102f9f <envid2env>
	if(r_value == -E_BAD_ENV)
f0104a4d:	83 c4 10             	add    $0x10,%esp
f0104a50:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104a53:	74 2e                	je     f0104a83 <syscall+0x48e>
		return -E_BAD_ENV;
	
	if(va>=(void*)UTOP)
f0104a55:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104a5c:	77 2c                	ja     f0104a8a <syscall+0x495>
		return -E_INVAL;

	if(((unsigned int)va<<20))
f0104a5e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a61:	c1 e0 14             	shl    $0x14,%eax
f0104a64:	85 c0                	test   %eax,%eax
f0104a66:	75 29                	jne    f0104a91 <syscall+0x49c>
		return -E_INVAL;

	page_remove(newenv_store->env_pgdir,va);
f0104a68:	83 ec 08             	sub    $0x8,%esp
f0104a6b:	ff 75 10             	pushl  0x10(%ebp)
f0104a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a71:	ff 70 60             	pushl  0x60(%eax)
f0104a74:	e8 ae c8 ff ff       	call   f0101327 <page_remove>
f0104a79:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f0104a7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a81:	eb 1a                	jmp    f0104a9d <syscall+0x4a8>
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value == -E_BAD_ENV)
		return -E_BAD_ENV;
f0104a83:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104a88:	eb 13                	jmp    f0104a9d <syscall+0x4a8>
	
	if(va>=(void*)UTOP)
		return -E_INVAL;
f0104a8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a8f:	eb 0c                	jmp    f0104a9d <syscall+0x4a8>

	if(((unsigned int)va<<20))
		return -E_INVAL;
f0104a91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
f0104a96:	eb 05                	jmp    f0104a9d <syscall+0x4a8>
		default:
			return -E_INVAL;
f0104a98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0104a9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104aa0:	c9                   	leave  
f0104aa1:	c3                   	ret    

f0104aa2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104aa2:	55                   	push   %ebp
f0104aa3:	89 e5                	mov    %esp,%ebp
f0104aa5:	57                   	push   %edi
f0104aa6:	56                   	push   %esi
f0104aa7:	53                   	push   %ebx
f0104aa8:	83 ec 14             	sub    $0x14,%esp
f0104aab:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104aae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ab1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ab4:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ab7:	8b 1a                	mov    (%edx),%ebx
f0104ab9:	8b 01                	mov    (%ecx),%eax
f0104abb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104abe:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ac5:	eb 7f                	jmp    f0104b46 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104aca:	01 d8                	add    %ebx,%eax
f0104acc:	89 c6                	mov    %eax,%esi
f0104ace:	c1 ee 1f             	shr    $0x1f,%esi
f0104ad1:	01 c6                	add    %eax,%esi
f0104ad3:	d1 fe                	sar    %esi
f0104ad5:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104ad8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104adb:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104ade:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ae0:	eb 03                	jmp    f0104ae5 <stab_binsearch+0x43>
			m--;
f0104ae2:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ae5:	39 c3                	cmp    %eax,%ebx
f0104ae7:	7f 0d                	jg     f0104af6 <stab_binsearch+0x54>
f0104ae9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104aed:	83 ea 0c             	sub    $0xc,%edx
f0104af0:	39 f9                	cmp    %edi,%ecx
f0104af2:	75 ee                	jne    f0104ae2 <stab_binsearch+0x40>
f0104af4:	eb 05                	jmp    f0104afb <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104af6:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104af9:	eb 4b                	jmp    f0104b46 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104afb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104afe:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b01:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104b05:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b08:	76 11                	jbe    f0104b1b <stab_binsearch+0x79>
			*region_left = m;
f0104b0a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104b0d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104b0f:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b12:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b19:	eb 2b                	jmp    f0104b46 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104b1b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104b1e:	73 14                	jae    f0104b34 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104b20:	83 e8 01             	sub    $0x1,%eax
f0104b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b26:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b29:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b2b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b32:	eb 12                	jmp    f0104b46 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104b34:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b37:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104b39:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b3d:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104b3f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104b46:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104b49:	0f 8e 78 ff ff ff    	jle    f0104ac7 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104b4f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b53:	75 0f                	jne    f0104b64 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104b55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b58:	8b 00                	mov    (%eax),%eax
f0104b5a:	83 e8 01             	sub    $0x1,%eax
f0104b5d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104b60:	89 06                	mov    %eax,(%esi)
f0104b62:	eb 2c                	jmp    f0104b90 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b64:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b67:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b69:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b6c:	8b 0e                	mov    (%esi),%ecx
f0104b6e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b71:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b74:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b77:	eb 03                	jmp    f0104b7c <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104b79:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b7c:	39 c8                	cmp    %ecx,%eax
f0104b7e:	7e 0b                	jle    f0104b8b <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104b80:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104b84:	83 ea 0c             	sub    $0xc,%edx
f0104b87:	39 df                	cmp    %ebx,%edi
f0104b89:	75 ee                	jne    f0104b79 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104b8b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b8e:	89 06                	mov    %eax,(%esi)
	}
}
f0104b90:	83 c4 14             	add    $0x14,%esp
f0104b93:	5b                   	pop    %ebx
f0104b94:	5e                   	pop    %esi
f0104b95:	5f                   	pop    %edi
f0104b96:	5d                   	pop    %ebp
f0104b97:	c3                   	ret    

f0104b98 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b98:	55                   	push   %ebp
f0104b99:	89 e5                	mov    %esp,%ebp
f0104b9b:	57                   	push   %edi
f0104b9c:	56                   	push   %esi
f0104b9d:	53                   	push   %ebx
f0104b9e:	83 ec 2c             	sub    $0x2c,%esp
f0104ba1:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ba4:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104ba7:	c7 06 50 7c 10 f0    	movl   $0xf0107c50,(%esi)
	info->eip_line = 0;
f0104bad:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104bb4:	c7 46 08 50 7c 10 f0 	movl   $0xf0107c50,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104bbb:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104bc2:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104bc5:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104bcc:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104bd2:	77 21                	ja     f0104bf5 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104bd4:	a1 00 00 20 00       	mov    0x200000,%eax
f0104bd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104bdc:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104be1:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104be7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104bea:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104bf0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104bf3:	eb 1a                	jmp    f0104c0f <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104bf5:	c7 45 d0 58 5b 11 f0 	movl   $0xf0115b58,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104bfc:	c7 45 cc 89 23 11 f0 	movl   $0xf0112389,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104c03:	b8 88 23 11 f0       	mov    $0xf0112388,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104c08:	c7 45 d4 34 81 10 f0 	movl   $0xf0108134,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c0f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104c12:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104c15:	0f 83 2b 01 00 00    	jae    f0104d46 <debuginfo_eip+0x1ae>
f0104c1b:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104c1f:	0f 85 28 01 00 00    	jne    f0104d4d <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c25:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c2c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104c2f:	29 d8                	sub    %ebx,%eax
f0104c31:	c1 f8 02             	sar    $0x2,%eax
f0104c34:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104c3a:	83 e8 01             	sub    $0x1,%eax
f0104c3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c40:	57                   	push   %edi
f0104c41:	6a 64                	push   $0x64
f0104c43:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c46:	89 c1                	mov    %eax,%ecx
f0104c48:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c4b:	89 d8                	mov    %ebx,%eax
f0104c4d:	e8 50 fe ff ff       	call   f0104aa2 <stab_binsearch>
	if (lfile == 0)
f0104c52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c55:	83 c4 08             	add    $0x8,%esp
f0104c58:	85 c0                	test   %eax,%eax
f0104c5a:	0f 84 f4 00 00 00    	je     f0104d54 <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c60:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c63:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c66:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c69:	57                   	push   %edi
f0104c6a:	6a 24                	push   $0x24
f0104c6c:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104c6f:	89 c1                	mov    %eax,%ecx
f0104c71:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c74:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104c77:	89 d8                	mov    %ebx,%eax
f0104c79:	e8 24 fe ff ff       	call   f0104aa2 <stab_binsearch>

	if (lfun <= rfun) {
f0104c7e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104c81:	83 c4 08             	add    $0x8,%esp
f0104c84:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104c87:	7f 24                	jg     f0104cad <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104c89:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104c8c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104c8f:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104c92:	8b 02                	mov    (%edx),%eax
f0104c94:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104c97:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104c9a:	29 f9                	sub    %edi,%ecx
f0104c9c:	39 c8                	cmp    %ecx,%eax
f0104c9e:	73 05                	jae    f0104ca5 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104ca0:	01 f8                	add    %edi,%eax
f0104ca2:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104ca5:	8b 42 08             	mov    0x8(%edx),%eax
f0104ca8:	89 46 10             	mov    %eax,0x10(%esi)
f0104cab:	eb 06                	jmp    f0104cb3 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104cad:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104cb0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104cb3:	83 ec 08             	sub    $0x8,%esp
f0104cb6:	6a 3a                	push   $0x3a
f0104cb8:	ff 76 08             	pushl  0x8(%esi)
f0104cbb:	e8 65 08 00 00       	call   f0105525 <strfind>
f0104cc0:	2b 46 08             	sub    0x8(%esi),%eax
f0104cc3:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104cc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cc9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ccc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104ccf:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104cd2:	83 c4 10             	add    $0x10,%esp
f0104cd5:	eb 06                	jmp    f0104cdd <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104cd7:	83 eb 01             	sub    $0x1,%ebx
f0104cda:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104cdd:	39 fb                	cmp    %edi,%ebx
f0104cdf:	7c 2d                	jl     f0104d0e <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104ce1:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104ce5:	80 fa 84             	cmp    $0x84,%dl
f0104ce8:	74 0b                	je     f0104cf5 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104cea:	80 fa 64             	cmp    $0x64,%dl
f0104ced:	75 e8                	jne    f0104cd7 <debuginfo_eip+0x13f>
f0104cef:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104cf3:	74 e2                	je     f0104cd7 <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104cf5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104cf8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104cfb:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104cfe:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d01:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104d04:	29 f8                	sub    %edi,%eax
f0104d06:	39 c2                	cmp    %eax,%edx
f0104d08:	73 04                	jae    f0104d0e <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104d0a:	01 fa                	add    %edi,%edx
f0104d0c:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d0e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104d11:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d14:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d19:	39 cb                	cmp    %ecx,%ebx
f0104d1b:	7d 43                	jge    f0104d60 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104d1d:	8d 53 01             	lea    0x1(%ebx),%edx
f0104d20:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104d23:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104d26:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104d29:	eb 07                	jmp    f0104d32 <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104d2b:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104d2f:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104d32:	39 ca                	cmp    %ecx,%edx
f0104d34:	74 25                	je     f0104d5b <debuginfo_eip+0x1c3>
f0104d36:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104d39:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104d3d:	74 ec                	je     f0104d2b <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d44:	eb 1a                	jmp    f0104d60 <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104d46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d4b:	eb 13                	jmp    f0104d60 <debuginfo_eip+0x1c8>
f0104d4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d52:	eb 0c                	jmp    f0104d60 <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104d54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d59:	eb 05                	jmp    f0104d60 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104d63:	5b                   	pop    %ebx
f0104d64:	5e                   	pop    %esi
f0104d65:	5f                   	pop    %edi
f0104d66:	5d                   	pop    %ebp
f0104d67:	c3                   	ret    

f0104d68 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104d68:	55                   	push   %ebp
f0104d69:	89 e5                	mov    %esp,%ebp
f0104d6b:	57                   	push   %edi
f0104d6c:	56                   	push   %esi
f0104d6d:	53                   	push   %ebx
f0104d6e:	83 ec 1c             	sub    $0x1c,%esp
f0104d71:	89 c7                	mov    %eax,%edi
f0104d73:	89 d6                	mov    %edx,%esi
f0104d75:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d78:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d7b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d7e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104d81:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d84:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d89:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104d8c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104d8f:	39 d3                	cmp    %edx,%ebx
f0104d91:	72 05                	jb     f0104d98 <printnum+0x30>
f0104d93:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104d96:	77 45                	ja     f0104ddd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104d98:	83 ec 0c             	sub    $0xc,%esp
f0104d9b:	ff 75 18             	pushl  0x18(%ebp)
f0104d9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104da1:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104da4:	53                   	push   %ebx
f0104da5:	ff 75 10             	pushl  0x10(%ebp)
f0104da8:	83 ec 08             	sub    $0x8,%esp
f0104dab:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104dae:	ff 75 e0             	pushl  -0x20(%ebp)
f0104db1:	ff 75 dc             	pushl  -0x24(%ebp)
f0104db4:	ff 75 d8             	pushl  -0x28(%ebp)
f0104db7:	e8 a4 11 00 00       	call   f0105f60 <__udivdi3>
f0104dbc:	83 c4 18             	add    $0x18,%esp
f0104dbf:	52                   	push   %edx
f0104dc0:	50                   	push   %eax
f0104dc1:	89 f2                	mov    %esi,%edx
f0104dc3:	89 f8                	mov    %edi,%eax
f0104dc5:	e8 9e ff ff ff       	call   f0104d68 <printnum>
f0104dca:	83 c4 20             	add    $0x20,%esp
f0104dcd:	eb 18                	jmp    f0104de7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104dcf:	83 ec 08             	sub    $0x8,%esp
f0104dd2:	56                   	push   %esi
f0104dd3:	ff 75 18             	pushl  0x18(%ebp)
f0104dd6:	ff d7                	call   *%edi
f0104dd8:	83 c4 10             	add    $0x10,%esp
f0104ddb:	eb 03                	jmp    f0104de0 <printnum+0x78>
f0104ddd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104de0:	83 eb 01             	sub    $0x1,%ebx
f0104de3:	85 db                	test   %ebx,%ebx
f0104de5:	7f e8                	jg     f0104dcf <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104de7:	83 ec 08             	sub    $0x8,%esp
f0104dea:	56                   	push   %esi
f0104deb:	83 ec 04             	sub    $0x4,%esp
f0104dee:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104df1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104df4:	ff 75 dc             	pushl  -0x24(%ebp)
f0104df7:	ff 75 d8             	pushl  -0x28(%ebp)
f0104dfa:	e8 91 12 00 00       	call   f0106090 <__umoddi3>
f0104dff:	83 c4 14             	add    $0x14,%esp
f0104e02:	0f be 80 5a 7c 10 f0 	movsbl -0xfef83a6(%eax),%eax
f0104e09:	50                   	push   %eax
f0104e0a:	ff d7                	call   *%edi
}
f0104e0c:	83 c4 10             	add    $0x10,%esp
f0104e0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e12:	5b                   	pop    %ebx
f0104e13:	5e                   	pop    %esi
f0104e14:	5f                   	pop    %edi
f0104e15:	5d                   	pop    %ebp
f0104e16:	c3                   	ret    

f0104e17 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104e17:	55                   	push   %ebp
f0104e18:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104e1a:	83 fa 01             	cmp    $0x1,%edx
f0104e1d:	7e 0e                	jle    f0104e2d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104e1f:	8b 10                	mov    (%eax),%edx
f0104e21:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104e24:	89 08                	mov    %ecx,(%eax)
f0104e26:	8b 02                	mov    (%edx),%eax
f0104e28:	8b 52 04             	mov    0x4(%edx),%edx
f0104e2b:	eb 22                	jmp    f0104e4f <getuint+0x38>
	else if (lflag)
f0104e2d:	85 d2                	test   %edx,%edx
f0104e2f:	74 10                	je     f0104e41 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104e31:	8b 10                	mov    (%eax),%edx
f0104e33:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104e36:	89 08                	mov    %ecx,(%eax)
f0104e38:	8b 02                	mov    (%edx),%eax
f0104e3a:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e3f:	eb 0e                	jmp    f0104e4f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104e41:	8b 10                	mov    (%eax),%edx
f0104e43:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104e46:	89 08                	mov    %ecx,(%eax)
f0104e48:	8b 02                	mov    (%edx),%eax
f0104e4a:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104e4f:	5d                   	pop    %ebp
f0104e50:	c3                   	ret    

f0104e51 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104e51:	55                   	push   %ebp
f0104e52:	89 e5                	mov    %esp,%ebp
f0104e54:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104e57:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104e5b:	8b 10                	mov    (%eax),%edx
f0104e5d:	3b 50 04             	cmp    0x4(%eax),%edx
f0104e60:	73 0a                	jae    f0104e6c <sprintputch+0x1b>
		*b->buf++ = ch;
f0104e62:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104e65:	89 08                	mov    %ecx,(%eax)
f0104e67:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e6a:	88 02                	mov    %al,(%edx)
}
f0104e6c:	5d                   	pop    %ebp
f0104e6d:	c3                   	ret    

f0104e6e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104e6e:	55                   	push   %ebp
f0104e6f:	89 e5                	mov    %esp,%ebp
f0104e71:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104e74:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104e77:	50                   	push   %eax
f0104e78:	ff 75 10             	pushl  0x10(%ebp)
f0104e7b:	ff 75 0c             	pushl  0xc(%ebp)
f0104e7e:	ff 75 08             	pushl  0x8(%ebp)
f0104e81:	e8 05 00 00 00       	call   f0104e8b <vprintfmt>
	va_end(ap);
}
f0104e86:	83 c4 10             	add    $0x10,%esp
f0104e89:	c9                   	leave  
f0104e8a:	c3                   	ret    

f0104e8b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104e8b:	55                   	push   %ebp
f0104e8c:	89 e5                	mov    %esp,%ebp
f0104e8e:	57                   	push   %edi
f0104e8f:	56                   	push   %esi
f0104e90:	53                   	push   %ebx
f0104e91:	83 ec 2c             	sub    $0x2c,%esp
f0104e94:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e9a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e9d:	eb 12                	jmp    f0104eb1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104e9f:	85 c0                	test   %eax,%eax
f0104ea1:	0f 84 d3 03 00 00    	je     f010527a <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
f0104ea7:	83 ec 08             	sub    $0x8,%esp
f0104eaa:	53                   	push   %ebx
f0104eab:	50                   	push   %eax
f0104eac:	ff d6                	call   *%esi
f0104eae:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104eb1:	83 c7 01             	add    $0x1,%edi
f0104eb4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104eb8:	83 f8 25             	cmp    $0x25,%eax
f0104ebb:	75 e2                	jne    f0104e9f <vprintfmt+0x14>
f0104ebd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104ec1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104ec8:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104ecf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104ed6:	ba 00 00 00 00       	mov    $0x0,%edx
f0104edb:	eb 07                	jmp    f0104ee4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104edd:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104ee0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ee4:	8d 47 01             	lea    0x1(%edi),%eax
f0104ee7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104eea:	0f b6 07             	movzbl (%edi),%eax
f0104eed:	0f b6 c8             	movzbl %al,%ecx
f0104ef0:	83 e8 23             	sub    $0x23,%eax
f0104ef3:	3c 55                	cmp    $0x55,%al
f0104ef5:	0f 87 64 03 00 00    	ja     f010525f <vprintfmt+0x3d4>
f0104efb:	0f b6 c0             	movzbl %al,%eax
f0104efe:	ff 24 85 20 7d 10 f0 	jmp    *-0xfef82e0(,%eax,4)
f0104f05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104f08:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f0c:	eb d6                	jmp    f0104ee4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f11:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f16:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104f19:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104f1c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104f20:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104f23:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104f26:	83 fa 09             	cmp    $0x9,%edx
f0104f29:	77 39                	ja     f0104f64 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104f2b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104f2e:	eb e9                	jmp    f0104f19 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104f30:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f33:	8d 48 04             	lea    0x4(%eax),%ecx
f0104f36:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104f39:	8b 00                	mov    (%eax),%eax
f0104f3b:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104f41:	eb 27                	jmp    f0104f6a <vprintfmt+0xdf>
f0104f43:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f46:	85 c0                	test   %eax,%eax
f0104f48:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104f4d:	0f 49 c8             	cmovns %eax,%ecx
f0104f50:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f56:	eb 8c                	jmp    f0104ee4 <vprintfmt+0x59>
f0104f58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104f5b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104f62:	eb 80                	jmp    f0104ee4 <vprintfmt+0x59>
f0104f64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f67:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f0104f6a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f6e:	0f 89 70 ff ff ff    	jns    f0104ee4 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104f74:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104f77:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f7a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104f81:	e9 5e ff ff ff       	jmp    f0104ee4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104f86:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104f8c:	e9 53 ff ff ff       	jmp    f0104ee4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104f91:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f94:	8d 50 04             	lea    0x4(%eax),%edx
f0104f97:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f9a:	83 ec 08             	sub    $0x8,%esp
f0104f9d:	53                   	push   %ebx
f0104f9e:	ff 30                	pushl  (%eax)
f0104fa0:	ff d6                	call   *%esi
			break;
f0104fa2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104fa8:	e9 04 ff ff ff       	jmp    f0104eb1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104fad:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fb0:	8d 50 04             	lea    0x4(%eax),%edx
f0104fb3:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fb6:	8b 00                	mov    (%eax),%eax
f0104fb8:	99                   	cltd   
f0104fb9:	31 d0                	xor    %edx,%eax
f0104fbb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104fbd:	83 f8 08             	cmp    $0x8,%eax
f0104fc0:	7f 0b                	jg     f0104fcd <vprintfmt+0x142>
f0104fc2:	8b 14 85 80 7e 10 f0 	mov    -0xfef8180(,%eax,4),%edx
f0104fc9:	85 d2                	test   %edx,%edx
f0104fcb:	75 18                	jne    f0104fe5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104fcd:	50                   	push   %eax
f0104fce:	68 72 7c 10 f0       	push   $0xf0107c72
f0104fd3:	53                   	push   %ebx
f0104fd4:	56                   	push   %esi
f0104fd5:	e8 94 fe ff ff       	call   f0104e6e <printfmt>
f0104fda:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104fe0:	e9 cc fe ff ff       	jmp    f0104eb1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104fe5:	52                   	push   %edx
f0104fe6:	68 59 72 10 f0       	push   $0xf0107259
f0104feb:	53                   	push   %ebx
f0104fec:	56                   	push   %esi
f0104fed:	e8 7c fe ff ff       	call   f0104e6e <printfmt>
f0104ff2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ff5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ff8:	e9 b4 fe ff ff       	jmp    f0104eb1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104ffd:	8b 45 14             	mov    0x14(%ebp),%eax
f0105000:	8d 50 04             	lea    0x4(%eax),%edx
f0105003:	89 55 14             	mov    %edx,0x14(%ebp)
f0105006:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105008:	85 ff                	test   %edi,%edi
f010500a:	b8 6b 7c 10 f0       	mov    $0xf0107c6b,%eax
f010500f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105012:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105016:	0f 8e 94 00 00 00    	jle    f01050b0 <vprintfmt+0x225>
f010501c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105020:	0f 84 98 00 00 00    	je     f01050be <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105026:	83 ec 08             	sub    $0x8,%esp
f0105029:	ff 75 c8             	pushl  -0x38(%ebp)
f010502c:	57                   	push   %edi
f010502d:	e8 a9 03 00 00       	call   f01053db <strnlen>
f0105032:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105035:	29 c1                	sub    %eax,%ecx
f0105037:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010503a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010503d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0105041:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105044:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105047:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105049:	eb 0f                	jmp    f010505a <vprintfmt+0x1cf>
					putch(padc, putdat);
f010504b:	83 ec 08             	sub    $0x8,%esp
f010504e:	53                   	push   %ebx
f010504f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105052:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105054:	83 ef 01             	sub    $0x1,%edi
f0105057:	83 c4 10             	add    $0x10,%esp
f010505a:	85 ff                	test   %edi,%edi
f010505c:	7f ed                	jg     f010504b <vprintfmt+0x1c0>
f010505e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0105061:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105064:	85 c9                	test   %ecx,%ecx
f0105066:	b8 00 00 00 00       	mov    $0x0,%eax
f010506b:	0f 49 c1             	cmovns %ecx,%eax
f010506e:	29 c1                	sub    %eax,%ecx
f0105070:	89 75 08             	mov    %esi,0x8(%ebp)
f0105073:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0105076:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105079:	89 cb                	mov    %ecx,%ebx
f010507b:	eb 4d                	jmp    f01050ca <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010507d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105081:	74 1b                	je     f010509e <vprintfmt+0x213>
f0105083:	0f be c0             	movsbl %al,%eax
f0105086:	83 e8 20             	sub    $0x20,%eax
f0105089:	83 f8 5e             	cmp    $0x5e,%eax
f010508c:	76 10                	jbe    f010509e <vprintfmt+0x213>
					putch('?', putdat);
f010508e:	83 ec 08             	sub    $0x8,%esp
f0105091:	ff 75 0c             	pushl  0xc(%ebp)
f0105094:	6a 3f                	push   $0x3f
f0105096:	ff 55 08             	call   *0x8(%ebp)
f0105099:	83 c4 10             	add    $0x10,%esp
f010509c:	eb 0d                	jmp    f01050ab <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010509e:	83 ec 08             	sub    $0x8,%esp
f01050a1:	ff 75 0c             	pushl  0xc(%ebp)
f01050a4:	52                   	push   %edx
f01050a5:	ff 55 08             	call   *0x8(%ebp)
f01050a8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01050ab:	83 eb 01             	sub    $0x1,%ebx
f01050ae:	eb 1a                	jmp    f01050ca <vprintfmt+0x23f>
f01050b0:	89 75 08             	mov    %esi,0x8(%ebp)
f01050b3:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01050b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050bc:	eb 0c                	jmp    f01050ca <vprintfmt+0x23f>
f01050be:	89 75 08             	mov    %esi,0x8(%ebp)
f01050c1:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01050c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050ca:	83 c7 01             	add    $0x1,%edi
f01050cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01050d1:	0f be d0             	movsbl %al,%edx
f01050d4:	85 d2                	test   %edx,%edx
f01050d6:	74 23                	je     f01050fb <vprintfmt+0x270>
f01050d8:	85 f6                	test   %esi,%esi
f01050da:	78 a1                	js     f010507d <vprintfmt+0x1f2>
f01050dc:	83 ee 01             	sub    $0x1,%esi
f01050df:	79 9c                	jns    f010507d <vprintfmt+0x1f2>
f01050e1:	89 df                	mov    %ebx,%edi
f01050e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01050e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01050e9:	eb 18                	jmp    f0105103 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01050eb:	83 ec 08             	sub    $0x8,%esp
f01050ee:	53                   	push   %ebx
f01050ef:	6a 20                	push   $0x20
f01050f1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01050f3:	83 ef 01             	sub    $0x1,%edi
f01050f6:	83 c4 10             	add    $0x10,%esp
f01050f9:	eb 08                	jmp    f0105103 <vprintfmt+0x278>
f01050fb:	89 df                	mov    %ebx,%edi
f01050fd:	8b 75 08             	mov    0x8(%ebp),%esi
f0105100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105103:	85 ff                	test   %edi,%edi
f0105105:	7f e4                	jg     f01050eb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105107:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010510a:	e9 a2 fd ff ff       	jmp    f0104eb1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010510f:	83 fa 01             	cmp    $0x1,%edx
f0105112:	7e 16                	jle    f010512a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105114:	8b 45 14             	mov    0x14(%ebp),%eax
f0105117:	8d 50 08             	lea    0x8(%eax),%edx
f010511a:	89 55 14             	mov    %edx,0x14(%ebp)
f010511d:	8b 50 04             	mov    0x4(%eax),%edx
f0105120:	8b 00                	mov    (%eax),%eax
f0105122:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105125:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0105128:	eb 32                	jmp    f010515c <vprintfmt+0x2d1>
	else if (lflag)
f010512a:	85 d2                	test   %edx,%edx
f010512c:	74 18                	je     f0105146 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010512e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105131:	8d 50 04             	lea    0x4(%eax),%edx
f0105134:	89 55 14             	mov    %edx,0x14(%ebp)
f0105137:	8b 00                	mov    (%eax),%eax
f0105139:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010513c:	89 c1                	mov    %eax,%ecx
f010513e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105141:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105144:	eb 16                	jmp    f010515c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0105146:	8b 45 14             	mov    0x14(%ebp),%eax
f0105149:	8d 50 04             	lea    0x4(%eax),%edx
f010514c:	89 55 14             	mov    %edx,0x14(%ebp)
f010514f:	8b 00                	mov    (%eax),%eax
f0105151:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105154:	89 c1                	mov    %eax,%ecx
f0105156:	c1 f9 1f             	sar    $0x1f,%ecx
f0105159:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010515c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010515f:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105162:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105165:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105168:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010516d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0105171:	0f 89 b0 00 00 00    	jns    f0105227 <vprintfmt+0x39c>
				putch('-', putdat);
f0105177:	83 ec 08             	sub    $0x8,%esp
f010517a:	53                   	push   %ebx
f010517b:	6a 2d                	push   $0x2d
f010517d:	ff d6                	call   *%esi
				num = -(long long) num;
f010517f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105182:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0105185:	f7 d8                	neg    %eax
f0105187:	83 d2 00             	adc    $0x0,%edx
f010518a:	f7 da                	neg    %edx
f010518c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010518f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105192:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0105195:	b8 0a 00 00 00       	mov    $0xa,%eax
f010519a:	e9 88 00 00 00       	jmp    f0105227 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010519f:	8d 45 14             	lea    0x14(%ebp),%eax
f01051a2:	e8 70 fc ff ff       	call   f0104e17 <getuint>
f01051a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f01051ad:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01051b2:	eb 73                	jmp    f0105227 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
f01051b4:	8d 45 14             	lea    0x14(%ebp),%eax
f01051b7:	e8 5b fc ff ff       	call   f0104e17 <getuint>
f01051bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
f01051c2:	83 ec 08             	sub    $0x8,%esp
f01051c5:	53                   	push   %ebx
f01051c6:	6a 58                	push   $0x58
f01051c8:	ff d6                	call   *%esi
			putch('X', putdat);
f01051ca:	83 c4 08             	add    $0x8,%esp
f01051cd:	53                   	push   %ebx
f01051ce:	6a 58                	push   $0x58
f01051d0:	ff d6                	call   *%esi
			putch('X', putdat);
f01051d2:	83 c4 08             	add    $0x8,%esp
f01051d5:	53                   	push   %ebx
f01051d6:	6a 58                	push   $0x58
f01051d8:	ff d6                	call   *%esi
			goto number;
f01051da:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
f01051dd:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
f01051e2:	eb 43                	jmp    f0105227 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f01051e4:	83 ec 08             	sub    $0x8,%esp
f01051e7:	53                   	push   %ebx
f01051e8:	6a 30                	push   $0x30
f01051ea:	ff d6                	call   *%esi
			putch('x', putdat);
f01051ec:	83 c4 08             	add    $0x8,%esp
f01051ef:	53                   	push   %ebx
f01051f0:	6a 78                	push   $0x78
f01051f2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01051f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01051f7:	8d 50 04             	lea    0x4(%eax),%edx
f01051fa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01051fd:	8b 00                	mov    (%eax),%eax
f01051ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105204:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105207:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010520a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010520d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105212:	eb 13                	jmp    f0105227 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105214:	8d 45 14             	lea    0x14(%ebp),%eax
f0105217:	e8 fb fb ff ff       	call   f0104e17 <getuint>
f010521c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010521f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0105222:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105227:	83 ec 0c             	sub    $0xc,%esp
f010522a:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f010522e:	52                   	push   %edx
f010522f:	ff 75 e0             	pushl  -0x20(%ebp)
f0105232:	50                   	push   %eax
f0105233:	ff 75 dc             	pushl  -0x24(%ebp)
f0105236:	ff 75 d8             	pushl  -0x28(%ebp)
f0105239:	89 da                	mov    %ebx,%edx
f010523b:	89 f0                	mov    %esi,%eax
f010523d:	e8 26 fb ff ff       	call   f0104d68 <printnum>
			break;
f0105242:	83 c4 20             	add    $0x20,%esp
f0105245:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105248:	e9 64 fc ff ff       	jmp    f0104eb1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010524d:	83 ec 08             	sub    $0x8,%esp
f0105250:	53                   	push   %ebx
f0105251:	51                   	push   %ecx
f0105252:	ff d6                	call   *%esi
			break;
f0105254:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105257:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010525a:	e9 52 fc ff ff       	jmp    f0104eb1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010525f:	83 ec 08             	sub    $0x8,%esp
f0105262:	53                   	push   %ebx
f0105263:	6a 25                	push   $0x25
f0105265:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105267:	83 c4 10             	add    $0x10,%esp
f010526a:	eb 03                	jmp    f010526f <vprintfmt+0x3e4>
f010526c:	83 ef 01             	sub    $0x1,%edi
f010526f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105273:	75 f7                	jne    f010526c <vprintfmt+0x3e1>
f0105275:	e9 37 fc ff ff       	jmp    f0104eb1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010527a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010527d:	5b                   	pop    %ebx
f010527e:	5e                   	pop    %esi
f010527f:	5f                   	pop    %edi
f0105280:	5d                   	pop    %ebp
f0105281:	c3                   	ret    

f0105282 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105282:	55                   	push   %ebp
f0105283:	89 e5                	mov    %esp,%ebp
f0105285:	83 ec 18             	sub    $0x18,%esp
f0105288:	8b 45 08             	mov    0x8(%ebp),%eax
f010528b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010528e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105291:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105295:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105298:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010529f:	85 c0                	test   %eax,%eax
f01052a1:	74 26                	je     f01052c9 <vsnprintf+0x47>
f01052a3:	85 d2                	test   %edx,%edx
f01052a5:	7e 22                	jle    f01052c9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01052a7:	ff 75 14             	pushl  0x14(%ebp)
f01052aa:	ff 75 10             	pushl  0x10(%ebp)
f01052ad:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01052b0:	50                   	push   %eax
f01052b1:	68 51 4e 10 f0       	push   $0xf0104e51
f01052b6:	e8 d0 fb ff ff       	call   f0104e8b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01052bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01052be:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01052c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052c4:	83 c4 10             	add    $0x10,%esp
f01052c7:	eb 05                	jmp    f01052ce <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01052c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01052ce:	c9                   	leave  
f01052cf:	c3                   	ret    

f01052d0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01052d0:	55                   	push   %ebp
f01052d1:	89 e5                	mov    %esp,%ebp
f01052d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01052d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01052d9:	50                   	push   %eax
f01052da:	ff 75 10             	pushl  0x10(%ebp)
f01052dd:	ff 75 0c             	pushl  0xc(%ebp)
f01052e0:	ff 75 08             	pushl  0x8(%ebp)
f01052e3:	e8 9a ff ff ff       	call   f0105282 <vsnprintf>
	va_end(ap);

	return rc;
}
f01052e8:	c9                   	leave  
f01052e9:	c3                   	ret    

f01052ea <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01052ea:	55                   	push   %ebp
f01052eb:	89 e5                	mov    %esp,%ebp
f01052ed:	57                   	push   %edi
f01052ee:	56                   	push   %esi
f01052ef:	53                   	push   %ebx
f01052f0:	83 ec 0c             	sub    $0xc,%esp
f01052f3:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01052f6:	85 c0                	test   %eax,%eax
f01052f8:	74 11                	je     f010530b <readline+0x21>
		cprintf("%s", prompt);
f01052fa:	83 ec 08             	sub    $0x8,%esp
f01052fd:	50                   	push   %eax
f01052fe:	68 59 72 10 f0       	push   $0xf0107259
f0105303:	e8 80 e5 ff ff       	call   f0103888 <cprintf>
f0105308:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010530b:	83 ec 0c             	sub    $0xc,%esp
f010530e:	6a 00                	push   $0x0
f0105310:	e8 d9 b4 ff ff       	call   f01007ee <iscons>
f0105315:	89 c7                	mov    %eax,%edi
f0105317:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010531a:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010531f:	e8 b9 b4 ff ff       	call   f01007dd <getchar>
f0105324:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105326:	85 c0                	test   %eax,%eax
f0105328:	79 18                	jns    f0105342 <readline+0x58>
			cprintf("read error: %e\n", c);
f010532a:	83 ec 08             	sub    $0x8,%esp
f010532d:	50                   	push   %eax
f010532e:	68 a4 7e 10 f0       	push   $0xf0107ea4
f0105333:	e8 50 e5 ff ff       	call   f0103888 <cprintf>
			return NULL;
f0105338:	83 c4 10             	add    $0x10,%esp
f010533b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105340:	eb 79                	jmp    f01053bb <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105342:	83 f8 08             	cmp    $0x8,%eax
f0105345:	0f 94 c2             	sete   %dl
f0105348:	83 f8 7f             	cmp    $0x7f,%eax
f010534b:	0f 94 c0             	sete   %al
f010534e:	08 c2                	or     %al,%dl
f0105350:	74 1a                	je     f010536c <readline+0x82>
f0105352:	85 f6                	test   %esi,%esi
f0105354:	7e 16                	jle    f010536c <readline+0x82>
			if (echoing)
f0105356:	85 ff                	test   %edi,%edi
f0105358:	74 0d                	je     f0105367 <readline+0x7d>
				cputchar('\b');
f010535a:	83 ec 0c             	sub    $0xc,%esp
f010535d:	6a 08                	push   $0x8
f010535f:	e8 69 b4 ff ff       	call   f01007cd <cputchar>
f0105364:	83 c4 10             	add    $0x10,%esp
			i--;
f0105367:	83 ee 01             	sub    $0x1,%esi
f010536a:	eb b3                	jmp    f010531f <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010536c:	83 fb 1f             	cmp    $0x1f,%ebx
f010536f:	7e 23                	jle    f0105394 <readline+0xaa>
f0105371:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105377:	7f 1b                	jg     f0105394 <readline+0xaa>
			if (echoing)
f0105379:	85 ff                	test   %edi,%edi
f010537b:	74 0c                	je     f0105389 <readline+0x9f>
				cputchar(c);
f010537d:	83 ec 0c             	sub    $0xc,%esp
f0105380:	53                   	push   %ebx
f0105381:	e8 47 b4 ff ff       	call   f01007cd <cputchar>
f0105386:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105389:	88 9e 80 fa 22 f0    	mov    %bl,-0xfdd0580(%esi)
f010538f:	8d 76 01             	lea    0x1(%esi),%esi
f0105392:	eb 8b                	jmp    f010531f <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105394:	83 fb 0a             	cmp    $0xa,%ebx
f0105397:	74 05                	je     f010539e <readline+0xb4>
f0105399:	83 fb 0d             	cmp    $0xd,%ebx
f010539c:	75 81                	jne    f010531f <readline+0x35>
			if (echoing)
f010539e:	85 ff                	test   %edi,%edi
f01053a0:	74 0d                	je     f01053af <readline+0xc5>
				cputchar('\n');
f01053a2:	83 ec 0c             	sub    $0xc,%esp
f01053a5:	6a 0a                	push   $0xa
f01053a7:	e8 21 b4 ff ff       	call   f01007cd <cputchar>
f01053ac:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01053af:	c6 86 80 fa 22 f0 00 	movb   $0x0,-0xfdd0580(%esi)
			return buf;
f01053b6:	b8 80 fa 22 f0       	mov    $0xf022fa80,%eax
		}
	}
}
f01053bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053be:	5b                   	pop    %ebx
f01053bf:	5e                   	pop    %esi
f01053c0:	5f                   	pop    %edi
f01053c1:	5d                   	pop    %ebp
f01053c2:	c3                   	ret    

f01053c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01053c3:	55                   	push   %ebp
f01053c4:	89 e5                	mov    %esp,%ebp
f01053c6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01053c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01053ce:	eb 03                	jmp    f01053d3 <strlen+0x10>
		n++;
f01053d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01053d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01053d7:	75 f7                	jne    f01053d0 <strlen+0xd>
		n++;
	return n;
}
f01053d9:	5d                   	pop    %ebp
f01053da:	c3                   	ret    

f01053db <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01053db:	55                   	push   %ebp
f01053dc:	89 e5                	mov    %esp,%ebp
f01053de:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01053e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01053e9:	eb 03                	jmp    f01053ee <strnlen+0x13>
		n++;
f01053eb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01053ee:	39 c2                	cmp    %eax,%edx
f01053f0:	74 08                	je     f01053fa <strnlen+0x1f>
f01053f2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01053f6:	75 f3                	jne    f01053eb <strnlen+0x10>
f01053f8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01053fa:	5d                   	pop    %ebp
f01053fb:	c3                   	ret    

f01053fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01053fc:	55                   	push   %ebp
f01053fd:	89 e5                	mov    %esp,%ebp
f01053ff:	53                   	push   %ebx
f0105400:	8b 45 08             	mov    0x8(%ebp),%eax
f0105403:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105406:	89 c2                	mov    %eax,%edx
f0105408:	83 c2 01             	add    $0x1,%edx
f010540b:	83 c1 01             	add    $0x1,%ecx
f010540e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105412:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105415:	84 db                	test   %bl,%bl
f0105417:	75 ef                	jne    f0105408 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105419:	5b                   	pop    %ebx
f010541a:	5d                   	pop    %ebp
f010541b:	c3                   	ret    

f010541c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010541c:	55                   	push   %ebp
f010541d:	89 e5                	mov    %esp,%ebp
f010541f:	53                   	push   %ebx
f0105420:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105423:	53                   	push   %ebx
f0105424:	e8 9a ff ff ff       	call   f01053c3 <strlen>
f0105429:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010542c:	ff 75 0c             	pushl  0xc(%ebp)
f010542f:	01 d8                	add    %ebx,%eax
f0105431:	50                   	push   %eax
f0105432:	e8 c5 ff ff ff       	call   f01053fc <strcpy>
	return dst;
}
f0105437:	89 d8                	mov    %ebx,%eax
f0105439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010543c:	c9                   	leave  
f010543d:	c3                   	ret    

f010543e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010543e:	55                   	push   %ebp
f010543f:	89 e5                	mov    %esp,%ebp
f0105441:	56                   	push   %esi
f0105442:	53                   	push   %ebx
f0105443:	8b 75 08             	mov    0x8(%ebp),%esi
f0105446:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105449:	89 f3                	mov    %esi,%ebx
f010544b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010544e:	89 f2                	mov    %esi,%edx
f0105450:	eb 0f                	jmp    f0105461 <strncpy+0x23>
		*dst++ = *src;
f0105452:	83 c2 01             	add    $0x1,%edx
f0105455:	0f b6 01             	movzbl (%ecx),%eax
f0105458:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010545b:	80 39 01             	cmpb   $0x1,(%ecx)
f010545e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105461:	39 da                	cmp    %ebx,%edx
f0105463:	75 ed                	jne    f0105452 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105465:	89 f0                	mov    %esi,%eax
f0105467:	5b                   	pop    %ebx
f0105468:	5e                   	pop    %esi
f0105469:	5d                   	pop    %ebp
f010546a:	c3                   	ret    

f010546b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010546b:	55                   	push   %ebp
f010546c:	89 e5                	mov    %esp,%ebp
f010546e:	56                   	push   %esi
f010546f:	53                   	push   %ebx
f0105470:	8b 75 08             	mov    0x8(%ebp),%esi
f0105473:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105476:	8b 55 10             	mov    0x10(%ebp),%edx
f0105479:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010547b:	85 d2                	test   %edx,%edx
f010547d:	74 21                	je     f01054a0 <strlcpy+0x35>
f010547f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105483:	89 f2                	mov    %esi,%edx
f0105485:	eb 09                	jmp    f0105490 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105487:	83 c2 01             	add    $0x1,%edx
f010548a:	83 c1 01             	add    $0x1,%ecx
f010548d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105490:	39 c2                	cmp    %eax,%edx
f0105492:	74 09                	je     f010549d <strlcpy+0x32>
f0105494:	0f b6 19             	movzbl (%ecx),%ebx
f0105497:	84 db                	test   %bl,%bl
f0105499:	75 ec                	jne    f0105487 <strlcpy+0x1c>
f010549b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010549d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01054a0:	29 f0                	sub    %esi,%eax
}
f01054a2:	5b                   	pop    %ebx
f01054a3:	5e                   	pop    %esi
f01054a4:	5d                   	pop    %ebp
f01054a5:	c3                   	ret    

f01054a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01054a6:	55                   	push   %ebp
f01054a7:	89 e5                	mov    %esp,%ebp
f01054a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01054af:	eb 06                	jmp    f01054b7 <strcmp+0x11>
		p++, q++;
f01054b1:	83 c1 01             	add    $0x1,%ecx
f01054b4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01054b7:	0f b6 01             	movzbl (%ecx),%eax
f01054ba:	84 c0                	test   %al,%al
f01054bc:	74 04                	je     f01054c2 <strcmp+0x1c>
f01054be:	3a 02                	cmp    (%edx),%al
f01054c0:	74 ef                	je     f01054b1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01054c2:	0f b6 c0             	movzbl %al,%eax
f01054c5:	0f b6 12             	movzbl (%edx),%edx
f01054c8:	29 d0                	sub    %edx,%eax
}
f01054ca:	5d                   	pop    %ebp
f01054cb:	c3                   	ret    

f01054cc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01054cc:	55                   	push   %ebp
f01054cd:	89 e5                	mov    %esp,%ebp
f01054cf:	53                   	push   %ebx
f01054d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01054d3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054d6:	89 c3                	mov    %eax,%ebx
f01054d8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01054db:	eb 06                	jmp    f01054e3 <strncmp+0x17>
		n--, p++, q++;
f01054dd:	83 c0 01             	add    $0x1,%eax
f01054e0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01054e3:	39 d8                	cmp    %ebx,%eax
f01054e5:	74 15                	je     f01054fc <strncmp+0x30>
f01054e7:	0f b6 08             	movzbl (%eax),%ecx
f01054ea:	84 c9                	test   %cl,%cl
f01054ec:	74 04                	je     f01054f2 <strncmp+0x26>
f01054ee:	3a 0a                	cmp    (%edx),%cl
f01054f0:	74 eb                	je     f01054dd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01054f2:	0f b6 00             	movzbl (%eax),%eax
f01054f5:	0f b6 12             	movzbl (%edx),%edx
f01054f8:	29 d0                	sub    %edx,%eax
f01054fa:	eb 05                	jmp    f0105501 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01054fc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105501:	5b                   	pop    %ebx
f0105502:	5d                   	pop    %ebp
f0105503:	c3                   	ret    

f0105504 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105504:	55                   	push   %ebp
f0105505:	89 e5                	mov    %esp,%ebp
f0105507:	8b 45 08             	mov    0x8(%ebp),%eax
f010550a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010550e:	eb 07                	jmp    f0105517 <strchr+0x13>
		if (*s == c)
f0105510:	38 ca                	cmp    %cl,%dl
f0105512:	74 0f                	je     f0105523 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105514:	83 c0 01             	add    $0x1,%eax
f0105517:	0f b6 10             	movzbl (%eax),%edx
f010551a:	84 d2                	test   %dl,%dl
f010551c:	75 f2                	jne    f0105510 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010551e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105523:	5d                   	pop    %ebp
f0105524:	c3                   	ret    

f0105525 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105525:	55                   	push   %ebp
f0105526:	89 e5                	mov    %esp,%ebp
f0105528:	8b 45 08             	mov    0x8(%ebp),%eax
f010552b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010552f:	eb 03                	jmp    f0105534 <strfind+0xf>
f0105531:	83 c0 01             	add    $0x1,%eax
f0105534:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105537:	38 ca                	cmp    %cl,%dl
f0105539:	74 04                	je     f010553f <strfind+0x1a>
f010553b:	84 d2                	test   %dl,%dl
f010553d:	75 f2                	jne    f0105531 <strfind+0xc>
			break;
	return (char *) s;
}
f010553f:	5d                   	pop    %ebp
f0105540:	c3                   	ret    

f0105541 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105541:	55                   	push   %ebp
f0105542:	89 e5                	mov    %esp,%ebp
f0105544:	57                   	push   %edi
f0105545:	56                   	push   %esi
f0105546:	53                   	push   %ebx
f0105547:	8b 7d 08             	mov    0x8(%ebp),%edi
f010554a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010554d:	85 c9                	test   %ecx,%ecx
f010554f:	74 36                	je     f0105587 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105551:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105557:	75 28                	jne    f0105581 <memset+0x40>
f0105559:	f6 c1 03             	test   $0x3,%cl
f010555c:	75 23                	jne    f0105581 <memset+0x40>
		c &= 0xFF;
f010555e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105562:	89 d3                	mov    %edx,%ebx
f0105564:	c1 e3 08             	shl    $0x8,%ebx
f0105567:	89 d6                	mov    %edx,%esi
f0105569:	c1 e6 18             	shl    $0x18,%esi
f010556c:	89 d0                	mov    %edx,%eax
f010556e:	c1 e0 10             	shl    $0x10,%eax
f0105571:	09 f0                	or     %esi,%eax
f0105573:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105575:	89 d8                	mov    %ebx,%eax
f0105577:	09 d0                	or     %edx,%eax
f0105579:	c1 e9 02             	shr    $0x2,%ecx
f010557c:	fc                   	cld    
f010557d:	f3 ab                	rep stos %eax,%es:(%edi)
f010557f:	eb 06                	jmp    f0105587 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105581:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105584:	fc                   	cld    
f0105585:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105587:	89 f8                	mov    %edi,%eax
f0105589:	5b                   	pop    %ebx
f010558a:	5e                   	pop    %esi
f010558b:	5f                   	pop    %edi
f010558c:	5d                   	pop    %ebp
f010558d:	c3                   	ret    

f010558e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010558e:	55                   	push   %ebp
f010558f:	89 e5                	mov    %esp,%ebp
f0105591:	57                   	push   %edi
f0105592:	56                   	push   %esi
f0105593:	8b 45 08             	mov    0x8(%ebp),%eax
f0105596:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105599:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010559c:	39 c6                	cmp    %eax,%esi
f010559e:	73 35                	jae    f01055d5 <memmove+0x47>
f01055a0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01055a3:	39 d0                	cmp    %edx,%eax
f01055a5:	73 2e                	jae    f01055d5 <memmove+0x47>
		s += n;
		d += n;
f01055a7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055aa:	89 d6                	mov    %edx,%esi
f01055ac:	09 fe                	or     %edi,%esi
f01055ae:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01055b4:	75 13                	jne    f01055c9 <memmove+0x3b>
f01055b6:	f6 c1 03             	test   $0x3,%cl
f01055b9:	75 0e                	jne    f01055c9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01055bb:	83 ef 04             	sub    $0x4,%edi
f01055be:	8d 72 fc             	lea    -0x4(%edx),%esi
f01055c1:	c1 e9 02             	shr    $0x2,%ecx
f01055c4:	fd                   	std    
f01055c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055c7:	eb 09                	jmp    f01055d2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01055c9:	83 ef 01             	sub    $0x1,%edi
f01055cc:	8d 72 ff             	lea    -0x1(%edx),%esi
f01055cf:	fd                   	std    
f01055d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01055d2:	fc                   	cld    
f01055d3:	eb 1d                	jmp    f01055f2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055d5:	89 f2                	mov    %esi,%edx
f01055d7:	09 c2                	or     %eax,%edx
f01055d9:	f6 c2 03             	test   $0x3,%dl
f01055dc:	75 0f                	jne    f01055ed <memmove+0x5f>
f01055de:	f6 c1 03             	test   $0x3,%cl
f01055e1:	75 0a                	jne    f01055ed <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01055e3:	c1 e9 02             	shr    $0x2,%ecx
f01055e6:	89 c7                	mov    %eax,%edi
f01055e8:	fc                   	cld    
f01055e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055eb:	eb 05                	jmp    f01055f2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01055ed:	89 c7                	mov    %eax,%edi
f01055ef:	fc                   	cld    
f01055f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01055f2:	5e                   	pop    %esi
f01055f3:	5f                   	pop    %edi
f01055f4:	5d                   	pop    %ebp
f01055f5:	c3                   	ret    

f01055f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01055f6:	55                   	push   %ebp
f01055f7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01055f9:	ff 75 10             	pushl  0x10(%ebp)
f01055fc:	ff 75 0c             	pushl  0xc(%ebp)
f01055ff:	ff 75 08             	pushl  0x8(%ebp)
f0105602:	e8 87 ff ff ff       	call   f010558e <memmove>
}
f0105607:	c9                   	leave  
f0105608:	c3                   	ret    

f0105609 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105609:	55                   	push   %ebp
f010560a:	89 e5                	mov    %esp,%ebp
f010560c:	56                   	push   %esi
f010560d:	53                   	push   %ebx
f010560e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105611:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105614:	89 c6                	mov    %eax,%esi
f0105616:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105619:	eb 1a                	jmp    f0105635 <memcmp+0x2c>
		if (*s1 != *s2)
f010561b:	0f b6 08             	movzbl (%eax),%ecx
f010561e:	0f b6 1a             	movzbl (%edx),%ebx
f0105621:	38 d9                	cmp    %bl,%cl
f0105623:	74 0a                	je     f010562f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105625:	0f b6 c1             	movzbl %cl,%eax
f0105628:	0f b6 db             	movzbl %bl,%ebx
f010562b:	29 d8                	sub    %ebx,%eax
f010562d:	eb 0f                	jmp    f010563e <memcmp+0x35>
		s1++, s2++;
f010562f:	83 c0 01             	add    $0x1,%eax
f0105632:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105635:	39 f0                	cmp    %esi,%eax
f0105637:	75 e2                	jne    f010561b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105639:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010563e:	5b                   	pop    %ebx
f010563f:	5e                   	pop    %esi
f0105640:	5d                   	pop    %ebp
f0105641:	c3                   	ret    

f0105642 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105642:	55                   	push   %ebp
f0105643:	89 e5                	mov    %esp,%ebp
f0105645:	53                   	push   %ebx
f0105646:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105649:	89 c1                	mov    %eax,%ecx
f010564b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010564e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105652:	eb 0a                	jmp    f010565e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105654:	0f b6 10             	movzbl (%eax),%edx
f0105657:	39 da                	cmp    %ebx,%edx
f0105659:	74 07                	je     f0105662 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010565b:	83 c0 01             	add    $0x1,%eax
f010565e:	39 c8                	cmp    %ecx,%eax
f0105660:	72 f2                	jb     f0105654 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105662:	5b                   	pop    %ebx
f0105663:	5d                   	pop    %ebp
f0105664:	c3                   	ret    

f0105665 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105665:	55                   	push   %ebp
f0105666:	89 e5                	mov    %esp,%ebp
f0105668:	57                   	push   %edi
f0105669:	56                   	push   %esi
f010566a:	53                   	push   %ebx
f010566b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010566e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105671:	eb 03                	jmp    f0105676 <strtol+0x11>
		s++;
f0105673:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105676:	0f b6 01             	movzbl (%ecx),%eax
f0105679:	3c 20                	cmp    $0x20,%al
f010567b:	74 f6                	je     f0105673 <strtol+0xe>
f010567d:	3c 09                	cmp    $0x9,%al
f010567f:	74 f2                	je     f0105673 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105681:	3c 2b                	cmp    $0x2b,%al
f0105683:	75 0a                	jne    f010568f <strtol+0x2a>
		s++;
f0105685:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105688:	bf 00 00 00 00       	mov    $0x0,%edi
f010568d:	eb 11                	jmp    f01056a0 <strtol+0x3b>
f010568f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105694:	3c 2d                	cmp    $0x2d,%al
f0105696:	75 08                	jne    f01056a0 <strtol+0x3b>
		s++, neg = 1;
f0105698:	83 c1 01             	add    $0x1,%ecx
f010569b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01056a0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01056a6:	75 15                	jne    f01056bd <strtol+0x58>
f01056a8:	80 39 30             	cmpb   $0x30,(%ecx)
f01056ab:	75 10                	jne    f01056bd <strtol+0x58>
f01056ad:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01056b1:	75 7c                	jne    f010572f <strtol+0xca>
		s += 2, base = 16;
f01056b3:	83 c1 02             	add    $0x2,%ecx
f01056b6:	bb 10 00 00 00       	mov    $0x10,%ebx
f01056bb:	eb 16                	jmp    f01056d3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01056bd:	85 db                	test   %ebx,%ebx
f01056bf:	75 12                	jne    f01056d3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01056c1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01056c6:	80 39 30             	cmpb   $0x30,(%ecx)
f01056c9:	75 08                	jne    f01056d3 <strtol+0x6e>
		s++, base = 8;
f01056cb:	83 c1 01             	add    $0x1,%ecx
f01056ce:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01056d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01056d8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01056db:	0f b6 11             	movzbl (%ecx),%edx
f01056de:	8d 72 d0             	lea    -0x30(%edx),%esi
f01056e1:	89 f3                	mov    %esi,%ebx
f01056e3:	80 fb 09             	cmp    $0x9,%bl
f01056e6:	77 08                	ja     f01056f0 <strtol+0x8b>
			dig = *s - '0';
f01056e8:	0f be d2             	movsbl %dl,%edx
f01056eb:	83 ea 30             	sub    $0x30,%edx
f01056ee:	eb 22                	jmp    f0105712 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01056f0:	8d 72 9f             	lea    -0x61(%edx),%esi
f01056f3:	89 f3                	mov    %esi,%ebx
f01056f5:	80 fb 19             	cmp    $0x19,%bl
f01056f8:	77 08                	ja     f0105702 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01056fa:	0f be d2             	movsbl %dl,%edx
f01056fd:	83 ea 57             	sub    $0x57,%edx
f0105700:	eb 10                	jmp    f0105712 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105702:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105705:	89 f3                	mov    %esi,%ebx
f0105707:	80 fb 19             	cmp    $0x19,%bl
f010570a:	77 16                	ja     f0105722 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010570c:	0f be d2             	movsbl %dl,%edx
f010570f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105712:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105715:	7d 0b                	jge    f0105722 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105717:	83 c1 01             	add    $0x1,%ecx
f010571a:	0f af 45 10          	imul   0x10(%ebp),%eax
f010571e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105720:	eb b9                	jmp    f01056db <strtol+0x76>

	if (endptr)
f0105722:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105726:	74 0d                	je     f0105735 <strtol+0xd0>
		*endptr = (char *) s;
f0105728:	8b 75 0c             	mov    0xc(%ebp),%esi
f010572b:	89 0e                	mov    %ecx,(%esi)
f010572d:	eb 06                	jmp    f0105735 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010572f:	85 db                	test   %ebx,%ebx
f0105731:	74 98                	je     f01056cb <strtol+0x66>
f0105733:	eb 9e                	jmp    f01056d3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105735:	89 c2                	mov    %eax,%edx
f0105737:	f7 da                	neg    %edx
f0105739:	85 ff                	test   %edi,%edi
f010573b:	0f 45 c2             	cmovne %edx,%eax
}
f010573e:	5b                   	pop    %ebx
f010573f:	5e                   	pop    %esi
f0105740:	5f                   	pop    %edi
f0105741:	5d                   	pop    %ebp
f0105742:	c3                   	ret    
f0105743:	90                   	nop

f0105744 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105744:	fa                   	cli    

	xorw    %ax, %ax
f0105745:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105747:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105749:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010574b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010574d:	0f 01 16             	lgdtl  (%esi)
f0105750:	74 70                	je     f01057c2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105752:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105755:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105759:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010575c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105762:	08 00                	or     %al,(%eax)

f0105764 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105764:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105768:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010576a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010576c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010576e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105772:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105774:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105776:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010577b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010577e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105781:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105786:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105789:	8b 25 84 fe 22 f0    	mov    0xf022fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010578f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105794:	b8 14 02 10 f0       	mov    $0xf0100214,%eax
	call    *%eax
f0105799:	ff d0                	call   *%eax

f010579b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010579b:	eb fe                	jmp    f010579b <spin>
f010579d:	8d 76 00             	lea    0x0(%esi),%esi

f01057a0 <gdt>:
	...
f01057a8:	ff                   	(bad)  
f01057a9:	ff 00                	incl   (%eax)
f01057ab:	00 00                	add    %al,(%eax)
f01057ad:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01057b4:	00                   	.byte 0x0
f01057b5:	92                   	xchg   %eax,%edx
f01057b6:	cf                   	iret   
	...

f01057b8 <gdtdesc>:
f01057b8:	17                   	pop    %ss
f01057b9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01057be <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01057be:	90                   	nop

f01057bf <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01057bf:	55                   	push   %ebp
f01057c0:	89 e5                	mov    %esp,%ebp
f01057c2:	57                   	push   %edi
f01057c3:	56                   	push   %esi
f01057c4:	53                   	push   %ebx
f01057c5:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057c8:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01057ce:	89 c3                	mov    %eax,%ebx
f01057d0:	c1 eb 0c             	shr    $0xc,%ebx
f01057d3:	39 cb                	cmp    %ecx,%ebx
f01057d5:	72 12                	jb     f01057e9 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057d7:	50                   	push   %eax
f01057d8:	68 c4 62 10 f0       	push   $0xf01062c4
f01057dd:	6a 57                	push   $0x57
f01057df:	68 41 80 10 f0       	push   $0xf0108041
f01057e4:	e8 ab a8 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01057e9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01057ef:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057f1:	89 c2                	mov    %eax,%edx
f01057f3:	c1 ea 0c             	shr    $0xc,%edx
f01057f6:	39 ca                	cmp    %ecx,%edx
f01057f8:	72 12                	jb     f010580c <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057fa:	50                   	push   %eax
f01057fb:	68 c4 62 10 f0       	push   $0xf01062c4
f0105800:	6a 57                	push   $0x57
f0105802:	68 41 80 10 f0       	push   $0xf0108041
f0105807:	e8 88 a8 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f010580c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105812:	eb 2f                	jmp    f0105843 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105814:	83 ec 04             	sub    $0x4,%esp
f0105817:	6a 04                	push   $0x4
f0105819:	68 51 80 10 f0       	push   $0xf0108051
f010581e:	53                   	push   %ebx
f010581f:	e8 e5 fd ff ff       	call   f0105609 <memcmp>
f0105824:	83 c4 10             	add    $0x10,%esp
f0105827:	85 c0                	test   %eax,%eax
f0105829:	75 15                	jne    f0105840 <mpsearch1+0x81>
f010582b:	89 da                	mov    %ebx,%edx
f010582d:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105830:	0f b6 0a             	movzbl (%edx),%ecx
f0105833:	01 c8                	add    %ecx,%eax
f0105835:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105838:	39 d7                	cmp    %edx,%edi
f010583a:	75 f4                	jne    f0105830 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010583c:	84 c0                	test   %al,%al
f010583e:	74 0e                	je     f010584e <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105840:	83 c3 10             	add    $0x10,%ebx
f0105843:	39 f3                	cmp    %esi,%ebx
f0105845:	72 cd                	jb     f0105814 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105847:	b8 00 00 00 00       	mov    $0x0,%eax
f010584c:	eb 02                	jmp    f0105850 <mpsearch1+0x91>
f010584e:	89 d8                	mov    %ebx,%eax
}
f0105850:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105853:	5b                   	pop    %ebx
f0105854:	5e                   	pop    %esi
f0105855:	5f                   	pop    %edi
f0105856:	5d                   	pop    %ebp
f0105857:	c3                   	ret    

f0105858 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105858:	55                   	push   %ebp
f0105859:	89 e5                	mov    %esp,%ebp
f010585b:	57                   	push   %edi
f010585c:	56                   	push   %esi
f010585d:	53                   	push   %ebx
f010585e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105861:	c7 05 c0 03 23 f0 20 	movl   $0xf0230020,0xf02303c0
f0105868:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010586b:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105872:	75 16                	jne    f010588a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105874:	68 00 04 00 00       	push   $0x400
f0105879:	68 c4 62 10 f0       	push   $0xf01062c4
f010587e:	6a 6f                	push   $0x6f
f0105880:	68 41 80 10 f0       	push   $0xf0108041
f0105885:	e8 0a a8 ff ff       	call   f0100094 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010588a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105891:	85 c0                	test   %eax,%eax
f0105893:	74 16                	je     f01058ab <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105895:	c1 e0 04             	shl    $0x4,%eax
f0105898:	ba 00 04 00 00       	mov    $0x400,%edx
f010589d:	e8 1d ff ff ff       	call   f01057bf <mpsearch1>
f01058a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058a5:	85 c0                	test   %eax,%eax
f01058a7:	75 3c                	jne    f01058e5 <mp_init+0x8d>
f01058a9:	eb 20                	jmp    f01058cb <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01058ab:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01058b2:	c1 e0 0a             	shl    $0xa,%eax
f01058b5:	2d 00 04 00 00       	sub    $0x400,%eax
f01058ba:	ba 00 04 00 00       	mov    $0x400,%edx
f01058bf:	e8 fb fe ff ff       	call   f01057bf <mpsearch1>
f01058c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058c7:	85 c0                	test   %eax,%eax
f01058c9:	75 1a                	jne    f01058e5 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01058cb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058d0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01058d5:	e8 e5 fe ff ff       	call   f01057bf <mpsearch1>
f01058da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01058dd:	85 c0                	test   %eax,%eax
f01058df:	0f 84 5d 02 00 00    	je     f0105b42 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01058e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058e8:	8b 70 04             	mov    0x4(%eax),%esi
f01058eb:	85 f6                	test   %esi,%esi
f01058ed:	74 06                	je     f01058f5 <mp_init+0x9d>
f01058ef:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01058f3:	74 15                	je     f010590a <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f01058f5:	83 ec 0c             	sub    $0xc,%esp
f01058f8:	68 b4 7e 10 f0       	push   $0xf0107eb4
f01058fd:	e8 86 df ff ff       	call   f0103888 <cprintf>
f0105902:	83 c4 10             	add    $0x10,%esp
f0105905:	e9 38 02 00 00       	jmp    f0105b42 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010590a:	89 f0                	mov    %esi,%eax
f010590c:	c1 e8 0c             	shr    $0xc,%eax
f010590f:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0105915:	72 15                	jb     f010592c <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105917:	56                   	push   %esi
f0105918:	68 c4 62 10 f0       	push   $0xf01062c4
f010591d:	68 90 00 00 00       	push   $0x90
f0105922:	68 41 80 10 f0       	push   $0xf0108041
f0105927:	e8 68 a7 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f010592c:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105932:	83 ec 04             	sub    $0x4,%esp
f0105935:	6a 04                	push   $0x4
f0105937:	68 56 80 10 f0       	push   $0xf0108056
f010593c:	53                   	push   %ebx
f010593d:	e8 c7 fc ff ff       	call   f0105609 <memcmp>
f0105942:	83 c4 10             	add    $0x10,%esp
f0105945:	85 c0                	test   %eax,%eax
f0105947:	74 15                	je     f010595e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105949:	83 ec 0c             	sub    $0xc,%esp
f010594c:	68 e4 7e 10 f0       	push   $0xf0107ee4
f0105951:	e8 32 df ff ff       	call   f0103888 <cprintf>
f0105956:	83 c4 10             	add    $0x10,%esp
f0105959:	e9 e4 01 00 00       	jmp    f0105b42 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010595e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105962:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105966:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105969:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010596e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105973:	eb 0d                	jmp    f0105982 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105975:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f010597c:	f0 
f010597d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010597f:	83 c0 01             	add    $0x1,%eax
f0105982:	39 c7                	cmp    %eax,%edi
f0105984:	75 ef                	jne    f0105975 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105986:	84 d2                	test   %dl,%dl
f0105988:	74 15                	je     f010599f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010598a:	83 ec 0c             	sub    $0xc,%esp
f010598d:	68 18 7f 10 f0       	push   $0xf0107f18
f0105992:	e8 f1 de ff ff       	call   f0103888 <cprintf>
f0105997:	83 c4 10             	add    $0x10,%esp
f010599a:	e9 a3 01 00 00       	jmp    f0105b42 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010599f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01059a3:	3c 01                	cmp    $0x1,%al
f01059a5:	74 1d                	je     f01059c4 <mp_init+0x16c>
f01059a7:	3c 04                	cmp    $0x4,%al
f01059a9:	74 19                	je     f01059c4 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01059ab:	83 ec 08             	sub    $0x8,%esp
f01059ae:	0f b6 c0             	movzbl %al,%eax
f01059b1:	50                   	push   %eax
f01059b2:	68 3c 7f 10 f0       	push   $0xf0107f3c
f01059b7:	e8 cc de ff ff       	call   f0103888 <cprintf>
f01059bc:	83 c4 10             	add    $0x10,%esp
f01059bf:	e9 7e 01 00 00       	jmp    f0105b42 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01059c4:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01059c8:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059cc:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059d1:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01059d6:	01 ce                	add    %ecx,%esi
f01059d8:	eb 0d                	jmp    f01059e7 <mp_init+0x18f>
f01059da:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01059e1:	f0 
f01059e2:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059e4:	83 c0 01             	add    $0x1,%eax
f01059e7:	39 c7                	cmp    %eax,%edi
f01059e9:	75 ef                	jne    f01059da <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01059eb:	89 d0                	mov    %edx,%eax
f01059ed:	02 43 2a             	add    0x2a(%ebx),%al
f01059f0:	74 15                	je     f0105a07 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01059f2:	83 ec 0c             	sub    $0xc,%esp
f01059f5:	68 5c 7f 10 f0       	push   $0xf0107f5c
f01059fa:	e8 89 de ff ff       	call   f0103888 <cprintf>
f01059ff:	83 c4 10             	add    $0x10,%esp
f0105a02:	e9 3b 01 00 00       	jmp    f0105b42 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a07:	85 db                	test   %ebx,%ebx
f0105a09:	0f 84 33 01 00 00    	je     f0105b42 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105a0f:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f0105a16:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105a19:	8b 43 24             	mov    0x24(%ebx),%eax
f0105a1c:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105a21:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105a24:	be 00 00 00 00       	mov    $0x0,%esi
f0105a29:	e9 85 00 00 00       	jmp    f0105ab3 <mp_init+0x25b>
		switch (*p) {
f0105a2e:	0f b6 07             	movzbl (%edi),%eax
f0105a31:	84 c0                	test   %al,%al
f0105a33:	74 06                	je     f0105a3b <mp_init+0x1e3>
f0105a35:	3c 04                	cmp    $0x4,%al
f0105a37:	77 55                	ja     f0105a8e <mp_init+0x236>
f0105a39:	eb 4e                	jmp    f0105a89 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105a3b:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105a3f:	74 11                	je     f0105a52 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105a41:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0105a48:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105a4d:	a3 c0 03 23 f0       	mov    %eax,0xf02303c0
			if (ncpu < NCPU) {
f0105a52:	a1 c4 03 23 f0       	mov    0xf02303c4,%eax
f0105a57:	83 f8 07             	cmp    $0x7,%eax
f0105a5a:	7f 13                	jg     f0105a6f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105a5c:	6b d0 74             	imul   $0x74,%eax,%edx
f0105a5f:	88 82 20 00 23 f0    	mov    %al,-0xfdcffe0(%edx)
				ncpu++;
f0105a65:	83 c0 01             	add    $0x1,%eax
f0105a68:	a3 c4 03 23 f0       	mov    %eax,0xf02303c4
f0105a6d:	eb 15                	jmp    f0105a84 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105a6f:	83 ec 08             	sub    $0x8,%esp
f0105a72:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105a76:	50                   	push   %eax
f0105a77:	68 8c 7f 10 f0       	push   $0xf0107f8c
f0105a7c:	e8 07 de ff ff       	call   f0103888 <cprintf>
f0105a81:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105a84:	83 c7 14             	add    $0x14,%edi
			continue;
f0105a87:	eb 27                	jmp    f0105ab0 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105a89:	83 c7 08             	add    $0x8,%edi
			continue;
f0105a8c:	eb 22                	jmp    f0105ab0 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105a8e:	83 ec 08             	sub    $0x8,%esp
f0105a91:	0f b6 c0             	movzbl %al,%eax
f0105a94:	50                   	push   %eax
f0105a95:	68 b4 7f 10 f0       	push   $0xf0107fb4
f0105a9a:	e8 e9 dd ff ff       	call   f0103888 <cprintf>
			ismp = 0;
f0105a9f:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f0105aa6:	00 00 00 
			i = conf->entry;
f0105aa9:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105aad:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ab0:	83 c6 01             	add    $0x1,%esi
f0105ab3:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105ab7:	39 c6                	cmp    %eax,%esi
f0105ab9:	0f 82 6f ff ff ff    	jb     f0105a2e <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105abf:	a1 c0 03 23 f0       	mov    0xf02303c0,%eax
f0105ac4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105acb:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105ad2:	75 26                	jne    f0105afa <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105ad4:	c7 05 c4 03 23 f0 01 	movl   $0x1,0xf02303c4
f0105adb:	00 00 00 
		lapicaddr = 0;
f0105ade:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105ae5:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105ae8:	83 ec 0c             	sub    $0xc,%esp
f0105aeb:	68 d4 7f 10 f0       	push   $0xf0107fd4
f0105af0:	e8 93 dd ff ff       	call   f0103888 <cprintf>
		return;
f0105af5:	83 c4 10             	add    $0x10,%esp
f0105af8:	eb 48                	jmp    f0105b42 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105afa:	83 ec 04             	sub    $0x4,%esp
f0105afd:	ff 35 c4 03 23 f0    	pushl  0xf02303c4
f0105b03:	0f b6 00             	movzbl (%eax),%eax
f0105b06:	50                   	push   %eax
f0105b07:	68 5b 80 10 f0       	push   $0xf010805b
f0105b0c:	e8 77 dd ff ff       	call   f0103888 <cprintf>

	if (mp->imcrp) {
f0105b11:	83 c4 10             	add    $0x10,%esp
f0105b14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b17:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105b1b:	74 25                	je     f0105b42 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105b1d:	83 ec 0c             	sub    $0xc,%esp
f0105b20:	68 00 80 10 f0       	push   $0xf0108000
f0105b25:	e8 5e dd ff ff       	call   f0103888 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b2a:	ba 22 00 00 00       	mov    $0x22,%edx
f0105b2f:	b8 70 00 00 00       	mov    $0x70,%eax
f0105b34:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105b35:	ba 23 00 00 00       	mov    $0x23,%edx
f0105b3a:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b3b:	83 c8 01             	or     $0x1,%eax
f0105b3e:	ee                   	out    %al,(%dx)
f0105b3f:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b45:	5b                   	pop    %ebx
f0105b46:	5e                   	pop    %esi
f0105b47:	5f                   	pop    %edi
f0105b48:	5d                   	pop    %ebp
f0105b49:	c3                   	ret    

f0105b4a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105b4a:	55                   	push   %ebp
f0105b4b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105b4d:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f0105b53:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105b56:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105b58:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105b5d:	8b 40 20             	mov    0x20(%eax),%eax
//	panic("after lapicw.\n");
}
f0105b60:	5d                   	pop    %ebp
f0105b61:	c3                   	ret    

f0105b62 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105b62:	55                   	push   %ebp
f0105b63:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105b65:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105b6a:	85 c0                	test   %eax,%eax
f0105b6c:	74 08                	je     f0105b76 <cpunum+0x14>
		return lapic[ID] >> 24;
f0105b6e:	8b 40 20             	mov    0x20(%eax),%eax
f0105b71:	c1 e8 18             	shr    $0x18,%eax
f0105b74:	eb 05                	jmp    f0105b7b <cpunum+0x19>
	return 0;
f0105b76:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b7b:	5d                   	pop    %ebp
f0105b7c:	c3                   	ret    

f0105b7d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105b7d:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105b82:	85 c0                	test   %eax,%eax
f0105b84:	0f 84 21 01 00 00    	je     f0105cab <lapic_init+0x12e>
//	panic("after lapicw.\n");
}

void
lapic_init(void)
{
f0105b8a:	55                   	push   %ebp
f0105b8b:	89 e5                	mov    %esp,%ebp
f0105b8d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105b90:	68 00 10 00 00       	push   $0x1000
f0105b95:	50                   	push   %eax
f0105b96:	e8 7f b8 ff ff       	call   f010141a <mmio_map_region>
f0105b9b:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105ba0:	ba 27 01 00 00       	mov    $0x127,%edx
f0105ba5:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105baa:	e8 9b ff ff ff       	call   f0105b4a <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105baf:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105bb4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105bb9:	e8 8c ff ff ff       	call   f0105b4a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105bbe:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105bc3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105bc8:	e8 7d ff ff ff       	call   f0105b4a <lapicw>
	lapicw(TICR, 10000000); 
f0105bcd:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105bd2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105bd7:	e8 6e ff ff ff       	call   f0105b4a <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105bdc:	e8 81 ff ff ff       	call   f0105b62 <cpunum>
f0105be1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105be4:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105be9:	83 c4 10             	add    $0x10,%esp
f0105bec:	39 05 c0 03 23 f0    	cmp    %eax,0xf02303c0
f0105bf2:	74 0f                	je     f0105c03 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105bf4:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bf9:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105bfe:	e8 47 ff ff ff       	call   f0105b4a <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c03:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c08:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105c0d:	e8 38 ff ff ff       	call   f0105b4a <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105c12:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105c17:	8b 40 30             	mov    0x30(%eax),%eax
f0105c1a:	c1 e8 10             	shr    $0x10,%eax
f0105c1d:	3c 03                	cmp    $0x3,%al
f0105c1f:	76 0f                	jbe    f0105c30 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105c21:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c26:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105c2b:	e8 1a ff ff ff       	call   f0105b4a <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105c30:	ba 33 00 00 00       	mov    $0x33,%edx
f0105c35:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105c3a:	e8 0b ff ff ff       	call   f0105b4a <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105c3f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c44:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c49:	e8 fc fe ff ff       	call   f0105b4a <lapicw>
	lapicw(ESR, 0);
f0105c4e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c53:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c58:	e8 ed fe ff ff       	call   f0105b4a <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105c5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c62:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105c67:	e8 de fe ff ff       	call   f0105b4a <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105c6c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c71:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c76:	e8 cf fe ff ff       	call   f0105b4a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105c7b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105c80:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c85:	e8 c0 fe ff ff       	call   f0105b4a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105c8a:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105c90:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105c96:	f6 c4 10             	test   $0x10,%ah
f0105c99:	75 f5                	jne    f0105c90 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105c9b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ca0:	b8 20 00 00 00       	mov    $0x20,%eax
f0105ca5:	e8 a0 fe ff ff       	call   f0105b4a <lapicw>
}
f0105caa:	c9                   	leave  
f0105cab:	f3 c3                	repz ret 

f0105cad <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105cad:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105cb4:	74 13                	je     f0105cc9 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105cb6:	55                   	push   %ebp
f0105cb7:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105cb9:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cbe:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105cc3:	e8 82 fe ff ff       	call   f0105b4a <lapicw>
}
f0105cc8:	5d                   	pop    %ebp
f0105cc9:	f3 c3                	repz ret 

f0105ccb <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ccb:	55                   	push   %ebp
f0105ccc:	89 e5                	mov    %esp,%ebp
f0105cce:	56                   	push   %esi
f0105ccf:	53                   	push   %ebx
f0105cd0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105cd6:	ba 70 00 00 00       	mov    $0x70,%edx
f0105cdb:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105ce0:	ee                   	out    %al,(%dx)
f0105ce1:	ba 71 00 00 00       	mov    $0x71,%edx
f0105ce6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105ceb:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105cec:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105cf3:	75 19                	jne    f0105d0e <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105cf5:	68 67 04 00 00       	push   $0x467
f0105cfa:	68 c4 62 10 f0       	push   $0xf01062c4
f0105cff:	68 99 00 00 00       	push   $0x99
f0105d04:	68 78 80 10 f0       	push   $0xf0108078
f0105d09:	e8 86 a3 ff ff       	call   f0100094 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105d0e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105d15:	00 00 
	wrv[1] = addr >> 4;
f0105d17:	89 d8                	mov    %ebx,%eax
f0105d19:	c1 e8 04             	shr    $0x4,%eax
f0105d1c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105d22:	c1 e6 18             	shl    $0x18,%esi
f0105d25:	89 f2                	mov    %esi,%edx
f0105d27:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d2c:	e8 19 fe ff ff       	call   f0105b4a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105d31:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105d36:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d3b:	e8 0a fe ff ff       	call   f0105b4a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105d40:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105d45:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d4a:	e8 fb fd ff ff       	call   f0105b4a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d4f:	c1 eb 0c             	shr    $0xc,%ebx
f0105d52:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d55:	89 f2                	mov    %esi,%edx
f0105d57:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d5c:	e8 e9 fd ff ff       	call   f0105b4a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d61:	89 da                	mov    %ebx,%edx
f0105d63:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d68:	e8 dd fd ff ff       	call   f0105b4a <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d6d:	89 f2                	mov    %esi,%edx
f0105d6f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d74:	e8 d1 fd ff ff       	call   f0105b4a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d79:	89 da                	mov    %ebx,%edx
f0105d7b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d80:	e8 c5 fd ff ff       	call   f0105b4a <lapicw>
		microdelay(200);
	}
}
f0105d85:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105d88:	5b                   	pop    %ebx
f0105d89:	5e                   	pop    %esi
f0105d8a:	5d                   	pop    %ebp
f0105d8b:	c3                   	ret    

f0105d8c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105d8c:	55                   	push   %ebp
f0105d8d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105d8f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105d92:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105d98:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d9d:	e8 a8 fd ff ff       	call   f0105b4a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105da2:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105da8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105dae:	f6 c4 10             	test   $0x10,%ah
f0105db1:	75 f5                	jne    f0105da8 <lapic_ipi+0x1c>
		;
}
f0105db3:	5d                   	pop    %ebp
f0105db4:	c3                   	ret    

f0105db5 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105db5:	55                   	push   %ebp
f0105db6:	89 e5                	mov    %esp,%ebp
f0105db8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105dbb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105dc4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105dc7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105dce:	5d                   	pop    %ebp
f0105dcf:	c3                   	ret    

f0105dd0 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105dd0:	55                   	push   %ebp
f0105dd1:	89 e5                	mov    %esp,%ebp
f0105dd3:	56                   	push   %esi
f0105dd4:	53                   	push   %ebx
f0105dd5:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105dd8:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105ddb:	74 14                	je     f0105df1 <spin_lock+0x21>
f0105ddd:	8b 73 08             	mov    0x8(%ebx),%esi
f0105de0:	e8 7d fd ff ff       	call   f0105b62 <cpunum>
f0105de5:	6b c0 74             	imul   $0x74,%eax,%eax
f0105de8:	05 20 00 23 f0       	add    $0xf0230020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105ded:	39 c6                	cmp    %eax,%esi
f0105def:	74 07                	je     f0105df8 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105df1:	ba 01 00 00 00       	mov    $0x1,%edx
f0105df6:	eb 20                	jmp    f0105e18 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105df8:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105dfb:	e8 62 fd ff ff       	call   f0105b62 <cpunum>
f0105e00:	83 ec 0c             	sub    $0xc,%esp
f0105e03:	53                   	push   %ebx
f0105e04:	50                   	push   %eax
f0105e05:	68 88 80 10 f0       	push   $0xf0108088
f0105e0a:	6a 41                	push   $0x41
f0105e0c:	68 ec 80 10 f0       	push   $0xf01080ec
f0105e11:	e8 7e a2 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105e16:	f3 90                	pause  
f0105e18:	89 d0                	mov    %edx,%eax
f0105e1a:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105e1d:	85 c0                	test   %eax,%eax
f0105e1f:	75 f5                	jne    f0105e16 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105e21:	e8 3c fd ff ff       	call   f0105b62 <cpunum>
f0105e26:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e29:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105e2e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105e31:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105e34:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e36:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e3b:	eb 0b                	jmp    f0105e48 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105e3d:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105e40:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105e43:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e45:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105e48:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105e4e:	76 11                	jbe    f0105e61 <spin_lock+0x91>
f0105e50:	83 f8 09             	cmp    $0x9,%eax
f0105e53:	7e e8                	jle    f0105e3d <spin_lock+0x6d>
f0105e55:	eb 0a                	jmp    f0105e61 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105e57:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105e5e:	83 c0 01             	add    $0x1,%eax
f0105e61:	83 f8 09             	cmp    $0x9,%eax
f0105e64:	7e f1                	jle    f0105e57 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105e66:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e69:	5b                   	pop    %ebx
f0105e6a:	5e                   	pop    %esi
f0105e6b:	5d                   	pop    %ebp
f0105e6c:	c3                   	ret    

f0105e6d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105e6d:	55                   	push   %ebp
f0105e6e:	89 e5                	mov    %esp,%ebp
f0105e70:	57                   	push   %edi
f0105e71:	56                   	push   %esi
f0105e72:	53                   	push   %ebx
f0105e73:	83 ec 4c             	sub    $0x4c,%esp
f0105e76:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e79:	83 3e 00             	cmpl   $0x0,(%esi)
f0105e7c:	74 18                	je     f0105e96 <spin_unlock+0x29>
f0105e7e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105e81:	e8 dc fc ff ff       	call   f0105b62 <cpunum>
f0105e86:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e89:	05 20 00 23 f0       	add    $0xf0230020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105e8e:	39 c3                	cmp    %eax,%ebx
f0105e90:	0f 84 a5 00 00 00    	je     f0105f3b <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105e96:	83 ec 04             	sub    $0x4,%esp
f0105e99:	6a 28                	push   $0x28
f0105e9b:	8d 46 0c             	lea    0xc(%esi),%eax
f0105e9e:	50                   	push   %eax
f0105e9f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105ea2:	53                   	push   %ebx
f0105ea3:	e8 e6 f6 ff ff       	call   f010558e <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105ea8:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105eab:	0f b6 38             	movzbl (%eax),%edi
f0105eae:	8b 76 04             	mov    0x4(%esi),%esi
f0105eb1:	e8 ac fc ff ff       	call   f0105b62 <cpunum>
f0105eb6:	57                   	push   %edi
f0105eb7:	56                   	push   %esi
f0105eb8:	50                   	push   %eax
f0105eb9:	68 b4 80 10 f0       	push   $0xf01080b4
f0105ebe:	e8 c5 d9 ff ff       	call   f0103888 <cprintf>
f0105ec3:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105ec6:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105ec9:	eb 54                	jmp    f0105f1f <spin_unlock+0xb2>
f0105ecb:	83 ec 08             	sub    $0x8,%esp
f0105ece:	57                   	push   %edi
f0105ecf:	50                   	push   %eax
f0105ed0:	e8 c3 ec ff ff       	call   f0104b98 <debuginfo_eip>
f0105ed5:	83 c4 10             	add    $0x10,%esp
f0105ed8:	85 c0                	test   %eax,%eax
f0105eda:	78 27                	js     f0105f03 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105edc:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105ede:	83 ec 04             	sub    $0x4,%esp
f0105ee1:	89 c2                	mov    %eax,%edx
f0105ee3:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105ee6:	52                   	push   %edx
f0105ee7:	ff 75 b0             	pushl  -0x50(%ebp)
f0105eea:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105eed:	ff 75 ac             	pushl  -0x54(%ebp)
f0105ef0:	ff 75 a8             	pushl  -0x58(%ebp)
f0105ef3:	50                   	push   %eax
f0105ef4:	68 fc 80 10 f0       	push   $0xf01080fc
f0105ef9:	e8 8a d9 ff ff       	call   f0103888 <cprintf>
f0105efe:	83 c4 20             	add    $0x20,%esp
f0105f01:	eb 12                	jmp    f0105f15 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f03:	83 ec 08             	sub    $0x8,%esp
f0105f06:	ff 36                	pushl  (%esi)
f0105f08:	68 13 81 10 f0       	push   $0xf0108113
f0105f0d:	e8 76 d9 ff ff       	call   f0103888 <cprintf>
f0105f12:	83 c4 10             	add    $0x10,%esp
f0105f15:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105f18:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105f1b:	39 c3                	cmp    %eax,%ebx
f0105f1d:	74 08                	je     f0105f27 <spin_unlock+0xba>
f0105f1f:	89 de                	mov    %ebx,%esi
f0105f21:	8b 03                	mov    (%ebx),%eax
f0105f23:	85 c0                	test   %eax,%eax
f0105f25:	75 a4                	jne    f0105ecb <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105f27:	83 ec 04             	sub    $0x4,%esp
f0105f2a:	68 1b 81 10 f0       	push   $0xf010811b
f0105f2f:	6a 67                	push   $0x67
f0105f31:	68 ec 80 10 f0       	push   $0xf01080ec
f0105f36:	e8 59 a1 ff ff       	call   f0100094 <_panic>
	}

	lk->pcs[0] = 0;
f0105f3b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105f42:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105f49:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f4e:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f54:	5b                   	pop    %ebx
f0105f55:	5e                   	pop    %esi
f0105f56:	5f                   	pop    %edi
f0105f57:	5d                   	pop    %ebp
f0105f58:	c3                   	ret    
f0105f59:	66 90                	xchg   %ax,%ax
f0105f5b:	66 90                	xchg   %ax,%ax
f0105f5d:	66 90                	xchg   %ax,%ax
f0105f5f:	90                   	nop

f0105f60 <__udivdi3>:
f0105f60:	55                   	push   %ebp
f0105f61:	57                   	push   %edi
f0105f62:	56                   	push   %esi
f0105f63:	53                   	push   %ebx
f0105f64:	83 ec 1c             	sub    $0x1c,%esp
f0105f67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105f6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105f6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105f77:	85 f6                	test   %esi,%esi
f0105f79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f7d:	89 ca                	mov    %ecx,%edx
f0105f7f:	89 f8                	mov    %edi,%eax
f0105f81:	75 3d                	jne    f0105fc0 <__udivdi3+0x60>
f0105f83:	39 cf                	cmp    %ecx,%edi
f0105f85:	0f 87 c5 00 00 00    	ja     f0106050 <__udivdi3+0xf0>
f0105f8b:	85 ff                	test   %edi,%edi
f0105f8d:	89 fd                	mov    %edi,%ebp
f0105f8f:	75 0b                	jne    f0105f9c <__udivdi3+0x3c>
f0105f91:	b8 01 00 00 00       	mov    $0x1,%eax
f0105f96:	31 d2                	xor    %edx,%edx
f0105f98:	f7 f7                	div    %edi
f0105f9a:	89 c5                	mov    %eax,%ebp
f0105f9c:	89 c8                	mov    %ecx,%eax
f0105f9e:	31 d2                	xor    %edx,%edx
f0105fa0:	f7 f5                	div    %ebp
f0105fa2:	89 c1                	mov    %eax,%ecx
f0105fa4:	89 d8                	mov    %ebx,%eax
f0105fa6:	89 cf                	mov    %ecx,%edi
f0105fa8:	f7 f5                	div    %ebp
f0105faa:	89 c3                	mov    %eax,%ebx
f0105fac:	89 d8                	mov    %ebx,%eax
f0105fae:	89 fa                	mov    %edi,%edx
f0105fb0:	83 c4 1c             	add    $0x1c,%esp
f0105fb3:	5b                   	pop    %ebx
f0105fb4:	5e                   	pop    %esi
f0105fb5:	5f                   	pop    %edi
f0105fb6:	5d                   	pop    %ebp
f0105fb7:	c3                   	ret    
f0105fb8:	90                   	nop
f0105fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105fc0:	39 ce                	cmp    %ecx,%esi
f0105fc2:	77 74                	ja     f0106038 <__udivdi3+0xd8>
f0105fc4:	0f bd fe             	bsr    %esi,%edi
f0105fc7:	83 f7 1f             	xor    $0x1f,%edi
f0105fca:	0f 84 98 00 00 00    	je     f0106068 <__udivdi3+0x108>
f0105fd0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105fd5:	89 f9                	mov    %edi,%ecx
f0105fd7:	89 c5                	mov    %eax,%ebp
f0105fd9:	29 fb                	sub    %edi,%ebx
f0105fdb:	d3 e6                	shl    %cl,%esi
f0105fdd:	89 d9                	mov    %ebx,%ecx
f0105fdf:	d3 ed                	shr    %cl,%ebp
f0105fe1:	89 f9                	mov    %edi,%ecx
f0105fe3:	d3 e0                	shl    %cl,%eax
f0105fe5:	09 ee                	or     %ebp,%esi
f0105fe7:	89 d9                	mov    %ebx,%ecx
f0105fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fed:	89 d5                	mov    %edx,%ebp
f0105fef:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105ff3:	d3 ed                	shr    %cl,%ebp
f0105ff5:	89 f9                	mov    %edi,%ecx
f0105ff7:	d3 e2                	shl    %cl,%edx
f0105ff9:	89 d9                	mov    %ebx,%ecx
f0105ffb:	d3 e8                	shr    %cl,%eax
f0105ffd:	09 c2                	or     %eax,%edx
f0105fff:	89 d0                	mov    %edx,%eax
f0106001:	89 ea                	mov    %ebp,%edx
f0106003:	f7 f6                	div    %esi
f0106005:	89 d5                	mov    %edx,%ebp
f0106007:	89 c3                	mov    %eax,%ebx
f0106009:	f7 64 24 0c          	mull   0xc(%esp)
f010600d:	39 d5                	cmp    %edx,%ebp
f010600f:	72 10                	jb     f0106021 <__udivdi3+0xc1>
f0106011:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106015:	89 f9                	mov    %edi,%ecx
f0106017:	d3 e6                	shl    %cl,%esi
f0106019:	39 c6                	cmp    %eax,%esi
f010601b:	73 07                	jae    f0106024 <__udivdi3+0xc4>
f010601d:	39 d5                	cmp    %edx,%ebp
f010601f:	75 03                	jne    f0106024 <__udivdi3+0xc4>
f0106021:	83 eb 01             	sub    $0x1,%ebx
f0106024:	31 ff                	xor    %edi,%edi
f0106026:	89 d8                	mov    %ebx,%eax
f0106028:	89 fa                	mov    %edi,%edx
f010602a:	83 c4 1c             	add    $0x1c,%esp
f010602d:	5b                   	pop    %ebx
f010602e:	5e                   	pop    %esi
f010602f:	5f                   	pop    %edi
f0106030:	5d                   	pop    %ebp
f0106031:	c3                   	ret    
f0106032:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106038:	31 ff                	xor    %edi,%edi
f010603a:	31 db                	xor    %ebx,%ebx
f010603c:	89 d8                	mov    %ebx,%eax
f010603e:	89 fa                	mov    %edi,%edx
f0106040:	83 c4 1c             	add    $0x1c,%esp
f0106043:	5b                   	pop    %ebx
f0106044:	5e                   	pop    %esi
f0106045:	5f                   	pop    %edi
f0106046:	5d                   	pop    %ebp
f0106047:	c3                   	ret    
f0106048:	90                   	nop
f0106049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106050:	89 d8                	mov    %ebx,%eax
f0106052:	f7 f7                	div    %edi
f0106054:	31 ff                	xor    %edi,%edi
f0106056:	89 c3                	mov    %eax,%ebx
f0106058:	89 d8                	mov    %ebx,%eax
f010605a:	89 fa                	mov    %edi,%edx
f010605c:	83 c4 1c             	add    $0x1c,%esp
f010605f:	5b                   	pop    %ebx
f0106060:	5e                   	pop    %esi
f0106061:	5f                   	pop    %edi
f0106062:	5d                   	pop    %ebp
f0106063:	c3                   	ret    
f0106064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106068:	39 ce                	cmp    %ecx,%esi
f010606a:	72 0c                	jb     f0106078 <__udivdi3+0x118>
f010606c:	31 db                	xor    %ebx,%ebx
f010606e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106072:	0f 87 34 ff ff ff    	ja     f0105fac <__udivdi3+0x4c>
f0106078:	bb 01 00 00 00       	mov    $0x1,%ebx
f010607d:	e9 2a ff ff ff       	jmp    f0105fac <__udivdi3+0x4c>
f0106082:	66 90                	xchg   %ax,%ax
f0106084:	66 90                	xchg   %ax,%ax
f0106086:	66 90                	xchg   %ax,%ax
f0106088:	66 90                	xchg   %ax,%ax
f010608a:	66 90                	xchg   %ax,%ax
f010608c:	66 90                	xchg   %ax,%ax
f010608e:	66 90                	xchg   %ax,%ax

f0106090 <__umoddi3>:
f0106090:	55                   	push   %ebp
f0106091:	57                   	push   %edi
f0106092:	56                   	push   %esi
f0106093:	53                   	push   %ebx
f0106094:	83 ec 1c             	sub    $0x1c,%esp
f0106097:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010609b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010609f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01060a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01060a7:	85 d2                	test   %edx,%edx
f01060a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01060ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01060b1:	89 f3                	mov    %esi,%ebx
f01060b3:	89 3c 24             	mov    %edi,(%esp)
f01060b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01060ba:	75 1c                	jne    f01060d8 <__umoddi3+0x48>
f01060bc:	39 f7                	cmp    %esi,%edi
f01060be:	76 50                	jbe    f0106110 <__umoddi3+0x80>
f01060c0:	89 c8                	mov    %ecx,%eax
f01060c2:	89 f2                	mov    %esi,%edx
f01060c4:	f7 f7                	div    %edi
f01060c6:	89 d0                	mov    %edx,%eax
f01060c8:	31 d2                	xor    %edx,%edx
f01060ca:	83 c4 1c             	add    $0x1c,%esp
f01060cd:	5b                   	pop    %ebx
f01060ce:	5e                   	pop    %esi
f01060cf:	5f                   	pop    %edi
f01060d0:	5d                   	pop    %ebp
f01060d1:	c3                   	ret    
f01060d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060d8:	39 f2                	cmp    %esi,%edx
f01060da:	89 d0                	mov    %edx,%eax
f01060dc:	77 52                	ja     f0106130 <__umoddi3+0xa0>
f01060de:	0f bd ea             	bsr    %edx,%ebp
f01060e1:	83 f5 1f             	xor    $0x1f,%ebp
f01060e4:	75 5a                	jne    f0106140 <__umoddi3+0xb0>
f01060e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01060ea:	0f 82 e0 00 00 00    	jb     f01061d0 <__umoddi3+0x140>
f01060f0:	39 0c 24             	cmp    %ecx,(%esp)
f01060f3:	0f 86 d7 00 00 00    	jbe    f01061d0 <__umoddi3+0x140>
f01060f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01060fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106101:	83 c4 1c             	add    $0x1c,%esp
f0106104:	5b                   	pop    %ebx
f0106105:	5e                   	pop    %esi
f0106106:	5f                   	pop    %edi
f0106107:	5d                   	pop    %ebp
f0106108:	c3                   	ret    
f0106109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106110:	85 ff                	test   %edi,%edi
f0106112:	89 fd                	mov    %edi,%ebp
f0106114:	75 0b                	jne    f0106121 <__umoddi3+0x91>
f0106116:	b8 01 00 00 00       	mov    $0x1,%eax
f010611b:	31 d2                	xor    %edx,%edx
f010611d:	f7 f7                	div    %edi
f010611f:	89 c5                	mov    %eax,%ebp
f0106121:	89 f0                	mov    %esi,%eax
f0106123:	31 d2                	xor    %edx,%edx
f0106125:	f7 f5                	div    %ebp
f0106127:	89 c8                	mov    %ecx,%eax
f0106129:	f7 f5                	div    %ebp
f010612b:	89 d0                	mov    %edx,%eax
f010612d:	eb 99                	jmp    f01060c8 <__umoddi3+0x38>
f010612f:	90                   	nop
f0106130:	89 c8                	mov    %ecx,%eax
f0106132:	89 f2                	mov    %esi,%edx
f0106134:	83 c4 1c             	add    $0x1c,%esp
f0106137:	5b                   	pop    %ebx
f0106138:	5e                   	pop    %esi
f0106139:	5f                   	pop    %edi
f010613a:	5d                   	pop    %ebp
f010613b:	c3                   	ret    
f010613c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106140:	8b 34 24             	mov    (%esp),%esi
f0106143:	bf 20 00 00 00       	mov    $0x20,%edi
f0106148:	89 e9                	mov    %ebp,%ecx
f010614a:	29 ef                	sub    %ebp,%edi
f010614c:	d3 e0                	shl    %cl,%eax
f010614e:	89 f9                	mov    %edi,%ecx
f0106150:	89 f2                	mov    %esi,%edx
f0106152:	d3 ea                	shr    %cl,%edx
f0106154:	89 e9                	mov    %ebp,%ecx
f0106156:	09 c2                	or     %eax,%edx
f0106158:	89 d8                	mov    %ebx,%eax
f010615a:	89 14 24             	mov    %edx,(%esp)
f010615d:	89 f2                	mov    %esi,%edx
f010615f:	d3 e2                	shl    %cl,%edx
f0106161:	89 f9                	mov    %edi,%ecx
f0106163:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106167:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010616b:	d3 e8                	shr    %cl,%eax
f010616d:	89 e9                	mov    %ebp,%ecx
f010616f:	89 c6                	mov    %eax,%esi
f0106171:	d3 e3                	shl    %cl,%ebx
f0106173:	89 f9                	mov    %edi,%ecx
f0106175:	89 d0                	mov    %edx,%eax
f0106177:	d3 e8                	shr    %cl,%eax
f0106179:	89 e9                	mov    %ebp,%ecx
f010617b:	09 d8                	or     %ebx,%eax
f010617d:	89 d3                	mov    %edx,%ebx
f010617f:	89 f2                	mov    %esi,%edx
f0106181:	f7 34 24             	divl   (%esp)
f0106184:	89 d6                	mov    %edx,%esi
f0106186:	d3 e3                	shl    %cl,%ebx
f0106188:	f7 64 24 04          	mull   0x4(%esp)
f010618c:	39 d6                	cmp    %edx,%esi
f010618e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106192:	89 d1                	mov    %edx,%ecx
f0106194:	89 c3                	mov    %eax,%ebx
f0106196:	72 08                	jb     f01061a0 <__umoddi3+0x110>
f0106198:	75 11                	jne    f01061ab <__umoddi3+0x11b>
f010619a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010619e:	73 0b                	jae    f01061ab <__umoddi3+0x11b>
f01061a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01061a4:	1b 14 24             	sbb    (%esp),%edx
f01061a7:	89 d1                	mov    %edx,%ecx
f01061a9:	89 c3                	mov    %eax,%ebx
f01061ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01061af:	29 da                	sub    %ebx,%edx
f01061b1:	19 ce                	sbb    %ecx,%esi
f01061b3:	89 f9                	mov    %edi,%ecx
f01061b5:	89 f0                	mov    %esi,%eax
f01061b7:	d3 e0                	shl    %cl,%eax
f01061b9:	89 e9                	mov    %ebp,%ecx
f01061bb:	d3 ea                	shr    %cl,%edx
f01061bd:	89 e9                	mov    %ebp,%ecx
f01061bf:	d3 ee                	shr    %cl,%esi
f01061c1:	09 d0                	or     %edx,%eax
f01061c3:	89 f2                	mov    %esi,%edx
f01061c5:	83 c4 1c             	add    $0x1c,%esp
f01061c8:	5b                   	pop    %ebx
f01061c9:	5e                   	pop    %esi
f01061ca:	5f                   	pop    %edi
f01061cb:	5d                   	pop    %ebp
f01061cc:	c3                   	ret    
f01061cd:	8d 76 00             	lea    0x0(%esi),%esi
f01061d0:	29 f9                	sub    %edi,%ecx
f01061d2:	19 d6                	sbb    %edx,%esi
f01061d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01061d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061dc:	e9 18 ff ff ff       	jmp    f01060f9 <__umoddi3+0x69>
