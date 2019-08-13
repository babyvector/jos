
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
f010004b:	68 40 5f 10 f0       	push   $0xf0105f40
f0100050:	e8 12 38 00 00       	call   f0103867 <cprintf>
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
f0100082:	68 5c 5f 10 f0       	push   $0xf0105f5c
f0100087:	e8 db 37 00 00       	call   f0103867 <cprintf>


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
f010009c:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f01000a3:	75 3a                	jne    f01000df <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f01000a5:	89 35 80 be 22 f0    	mov    %esi,0xf022be80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000ab:	fa                   	cli    
f01000ac:	fc                   	cld    

	va_start(ap, fmt);
f01000ad:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000b0:	e8 f5 57 00 00       	call   f01058aa <cpunum>
f01000b5:	ff 75 0c             	pushl  0xc(%ebp)
f01000b8:	ff 75 08             	pushl  0x8(%ebp)
f01000bb:	50                   	push   %eax
f01000bc:	68 e4 5f 10 f0       	push   $0xf0105fe4
f01000c1:	e8 a1 37 00 00       	call   f0103867 <cprintf>
	vcprintf(fmt, ap);
f01000c6:	83 c4 08             	add    $0x8,%esp
f01000c9:	53                   	push   %ebx
f01000ca:	56                   	push   %esi
f01000cb:	e8 71 37 00 00       	call   f0103841 <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 04 63 10 f0 	movl   $0xf0106304,(%esp)
f01000d7:	e8 8b 37 00 00       	call   f0103867 <cprintf>
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
f01000f5:	b8 08 d0 26 f0       	mov    $0xf026d008,%eax
f01000fa:	2d 98 a5 22 f0       	sub    $0xf022a598,%eax
f01000ff:	50                   	push   %eax
f0100100:	6a 00                	push   $0x0
f0100102:	68 98 a5 22 f0       	push   $0xf022a598
f0100107:	e8 7d 51 00 00       	call   f0105289 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 97 05 00 00       	call   f01006a8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	68 ac 1a 00 00       	push   $0x1aac
f0100119:	68 77 5f 10 f0       	push   $0xf0105f77
f010011e:	e8 44 37 00 00       	call   f0103867 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100123:	e8 37 13 00 00       	call   f010145f <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100128:	e8 38 2f 00 00       	call   f0103065 <env_init>

	trap_init();
f010012d:	e8 36 38 00 00       	call   f0103968 <trap_init>
	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100132:	e8 69 54 00 00       	call   f01055a0 <mp_init>
	lapic_init();
f0100137:	e8 89 57 00 00       	call   f01058c5 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013c:	e8 4d 36 00 00       	call   f010378e <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100141:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100148:	e8 cb 59 00 00       	call   f0105b18 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010014d:	83 c4 10             	add    $0x10,%esp
f0100150:	83 3d 88 be 22 f0 07 	cmpl   $0x7,0xf022be88
f0100157:	77 16                	ja     f010016f <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100159:	68 00 70 00 00       	push   $0x7000
f010015e:	68 08 60 10 f0       	push   $0xf0106008
f0100163:	6a 6d                	push   $0x6d
f0100165:	68 92 5f 10 f0       	push   $0xf0105f92
f010016a:	e8 25 ff ff ff       	call   f0100094 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010016f:	83 ec 04             	sub    $0x4,%esp
f0100172:	b8 06 55 10 f0       	mov    $0xf0105506,%eax
f0100177:	2d 8c 54 10 f0       	sub    $0xf010548c,%eax
f010017c:	50                   	push   %eax
f010017d:	68 8c 54 10 f0       	push   $0xf010548c
f0100182:	68 00 70 00 f0       	push   $0xf0007000
f0100187:	e8 4a 51 00 00       	call   f01052d6 <memmove>
f010018c:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018f:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
f0100194:	eb 4d                	jmp    f01001e3 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100196:	e8 0f 57 00 00       	call   f01058aa <cpunum>
f010019b:	6b c0 74             	imul   $0x74,%eax,%eax
f010019e:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01001a3:	39 c3                	cmp    %eax,%ebx
f01001a5:	74 39                	je     f01001e0 <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001a7:	89 d8                	mov    %ebx,%eax
f01001a9:	2d 20 c0 22 f0       	sub    $0xf022c020,%eax
f01001ae:	c1 f8 02             	sar    $0x2,%eax
f01001b1:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f01001b7:	c1 e0 0f             	shl    $0xf,%eax
f01001ba:	05 00 50 23 f0       	add    $0xf0235000,%eax
f01001bf:	a3 84 be 22 f0       	mov    %eax,0xf022be84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f01001c4:	83 ec 08             	sub    $0x8,%esp
f01001c7:	68 00 70 00 00       	push   $0x7000
f01001cc:	0f b6 03             	movzbl (%ebx),%eax
f01001cf:	50                   	push   %eax
f01001d0:	e8 3e 58 00 00       	call   f0105a13 <lapic_startap>
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
f01001e3:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01001ea:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01001ef:	39 c3                	cmp    %eax,%ebx
f01001f1:	72 a3                	jb     f0100196 <i386_init+0xa8>
#if defined(TEST)
	// Don't touch -- used by grading script!
	cprintf("in the if TEST.\n");
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	cprintf("in the else TEST.\n");
f01001f3:	83 ec 0c             	sub    $0xc,%esp
f01001f6:	68 9e 5f 10 f0       	push   $0xf0105f9e
f01001fb:	e8 67 36 00 00       	call   f0103867 <cprintf>
	//ENV_CREATE(user_yield,ENV_TYPE_USER);
	//ENV_CREATE(user_yield,ENV_TYPE_USER);
	//ENV_CREATE(user_yield,ENV_TYPE_USER);

	//we use the next  line to test Excerse 7
	ENV_CREATE(user_dumbfork,ENV_TYPE_USER);
f0100200:	83 c4 08             	add    $0x8,%esp
f0100203:	6a 00                	push   $0x0
f0100205:	68 08 0d 1a f0       	push   $0xf01a0d08
f010020a:	e8 5b 30 00 00       	call   f010326a <env_create>
#endif 
	// Schedule and run the first user environment!
	sched_yield();
f010020f:	e8 70 40 00 00       	call   f0104284 <sched_yield>

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
f010021a:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010021f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100224:	77 15                	ja     f010023b <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100226:	50                   	push   %eax
f0100227:	68 2c 60 10 f0       	push   $0xf010602c
f010022c:	68 85 00 00 00       	push   $0x85
f0100231:	68 92 5f 10 f0       	push   $0xf0105f92
f0100236:	e8 59 fe ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010023b:	05 00 00 00 10       	add    $0x10000000,%eax
f0100240:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100243:	e8 62 56 00 00       	call   f01058aa <cpunum>
f0100248:	83 ec 08             	sub    $0x8,%esp
f010024b:	50                   	push   %eax
f010024c:	68 b1 5f 10 f0       	push   $0xf0105fb1
f0100251:	e8 11 36 00 00       	call   f0103867 <cprintf>

	lapic_init();
f0100256:	e8 6a 56 00 00       	call   f01058c5 <lapic_init>
	env_init_percpu();
f010025b:	e8 d5 2d 00 00       	call   f0103035 <env_init_percpu>
	trap_init_percpu();
f0100260:	e8 16 36 00 00       	call   f010387b <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100265:	e8 40 56 00 00       	call   f01058aa <cpunum>
f010026a:	6b d0 74             	imul   $0x74,%eax,%edx
f010026d:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100273:	b8 01 00 00 00       	mov    $0x1,%eax
f0100278:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010027c:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100283:	e8 90 58 00 00       	call   f0105b18 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100288:	e8 f7 3f 00 00       	call   f0104284 <sched_yield>

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
f010029d:	68 c7 5f 10 f0       	push   $0xf0105fc7
f01002a2:	e8 c0 35 00 00       	call   f0103867 <cprintf>
	vcprintf(fmt, ap);
f01002a7:	83 c4 08             	add    $0x8,%esp
f01002aa:	53                   	push   %ebx
f01002ab:	ff 75 10             	pushl  0x10(%ebp)
f01002ae:	e8 8e 35 00 00       	call   f0103841 <vcprintf>
	cprintf("\n");
f01002b3:	c7 04 24 04 63 10 f0 	movl   $0xf0106304,(%esp)
f01002ba:	e8 a8 35 00 00       	call   f0103867 <cprintf>
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
f01002f5:	8b 0d 24 b2 22 f0    	mov    0xf022b224,%ecx
f01002fb:	8d 51 01             	lea    0x1(%ecx),%edx
f01002fe:	89 15 24 b2 22 f0    	mov    %edx,0xf022b224
f0100304:	88 81 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010030a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100310:	75 0a                	jne    f010031c <cons_intr+0x36>
			cons.wpos = 0;
f0100312:	c7 05 24 b2 22 f0 00 	movl   $0x0,0xf022b224
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
f010034b:	83 0d 00 b0 22 f0 40 	orl    $0x40,0xf022b000
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
f0100363:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f0100369:	89 cb                	mov    %ecx,%ebx
f010036b:	83 e3 40             	and    $0x40,%ebx
f010036e:	83 e0 7f             	and    $0x7f,%eax
f0100371:	85 db                	test   %ebx,%ebx
f0100373:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100376:	0f b6 d2             	movzbl %dl,%edx
f0100379:	0f b6 82 a0 61 10 f0 	movzbl -0xfef9e60(%edx),%eax
f0100380:	83 c8 40             	or     $0x40,%eax
f0100383:	0f b6 c0             	movzbl %al,%eax
f0100386:	f7 d0                	not    %eax
f0100388:	21 c8                	and    %ecx,%eax
f010038a:	a3 00 b0 22 f0       	mov    %eax,0xf022b000
		return 0;
f010038f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100394:	e9 a4 00 00 00       	jmp    f010043d <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100399:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f010039f:	f6 c1 40             	test   $0x40,%cl
f01003a2:	74 0e                	je     f01003b2 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003a4:	83 c8 80             	or     $0xffffff80,%eax
f01003a7:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003a9:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003ac:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
	}

	shift |= shiftcode[data];
f01003b2:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01003b5:	0f b6 82 a0 61 10 f0 	movzbl -0xfef9e60(%edx),%eax
f01003bc:	0b 05 00 b0 22 f0    	or     0xf022b000,%eax
f01003c2:	0f b6 8a a0 60 10 f0 	movzbl -0xfef9f60(%edx),%ecx
f01003c9:	31 c8                	xor    %ecx,%eax
f01003cb:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003d0:	89 c1                	mov    %eax,%ecx
f01003d2:	83 e1 03             	and    $0x3,%ecx
f01003d5:	8b 0c 8d 80 60 10 f0 	mov    -0xfef9f80(,%ecx,4),%ecx
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
f0100413:	68 50 60 10 f0       	push   $0xf0106050
f0100418:	e8 4a 34 00 00       	call   f0103867 <cprintf>
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
f01004ff:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100506:	66 85 c0             	test   %ax,%ax
f0100509:	0f 84 eb 00 00 00    	je     f01005fa <cons_putc+0x1b8>
			crt_pos--;
f010050f:	83 e8 01             	sub    $0x1,%eax
f0100512:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100518:	0f b7 c0             	movzwl %ax,%eax
f010051b:	66 81 e7 00 ff       	and    $0xff00,%di
f0100520:	83 cf 20             	or     $0x20,%edi
f0100523:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f0100529:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052d:	eb 7c                	jmp    f01005ab <cons_putc+0x169>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010052f:	66 81 05 28 b2 22 f0 	addw   $0x8f,0xf022b228
f0100536:	8f 00 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100538:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f010053f:	69 c0 93 72 00 00    	imul   $0x7293,%eax,%eax
f0100545:	c1 e8 16             	shr    $0x16,%eax
f0100548:	8d 14 c0             	lea    (%eax,%eax,8),%edx
f010054b:	c1 e2 04             	shl    $0x4,%edx
f010054e:	29 c2                	sub    %eax,%edx
f0100550:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
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
f010058d:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100594:	8d 50 01             	lea    0x1(%eax),%edx
f0100597:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
f010059e:	0f b7 c0             	movzwl %ax,%eax
f01005a1:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f01005a7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005ab:	66 81 3d 28 b2 22 f0 	cmpw   $0x1804,0xf022b228
f01005b2:	04 18 
f01005b4:	76 44                	jbe    f01005fa <cons_putc+0x1b8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005b6:	a1 2c b2 22 f0       	mov    0xf022b22c,%eax
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	68 ec 2e 00 00       	push   $0x2eec
f01005c3:	8d 90 1e 01 00 00    	lea    0x11e(%eax),%edx
f01005c9:	52                   	push   %edx
f01005ca:	50                   	push   %eax
f01005cb:	e8 06 4d 00 00       	call   f01052d6 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005d0:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
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
f01005f1:	66 81 2d 28 b2 22 f0 	subw   $0x8f,0xf022b228
f01005f8:	8f 00 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005fa:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f0100600:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100605:	89 ca                	mov    %ecx,%edx
f0100607:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100608:	0f b7 1d 28 b2 22 f0 	movzwl 0xf022b228,%ebx
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
f0100630:	80 3d 34 b2 22 f0 00 	cmpb   $0x0,0xf022b234
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
f010066e:	a1 20 b2 22 f0       	mov    0xf022b220,%eax
f0100673:	3b 05 24 b2 22 f0    	cmp    0xf022b224,%eax
f0100679:	74 26                	je     f01006a1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010067b:	8d 50 01             	lea    0x1(%eax),%edx
f010067e:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
f0100684:	0f b6 88 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ecx
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
f0100695:	c7 05 20 b2 22 f0 00 	movl   $0x0,0xf022b220
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
f01006ce:	c7 05 30 b2 22 f0 b4 	movl   $0x3b4,0xf022b230
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
f01006e6:	c7 05 30 b2 22 f0 d4 	movl   $0x3d4,0xf022b230
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
f01006f5:	8b 3d 30 b2 22 f0    	mov    0xf022b230,%edi
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
f010071a:	89 35 2c b2 22 f0    	mov    %esi,0xf022b22c
	crt_pos = pos;
f0100720:	0f b6 c0             	movzbl %al,%eax
f0100723:	09 c8                	or     %ecx,%eax
f0100725:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228

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
f0100740:	e8 d1 2f 00 00       	call   f0103716 <irq_setmask_8259A>
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
f01007a3:	0f 95 05 34 b2 22 f0 	setne  0xf022b234
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
f01007b8:	68 5c 60 10 f0       	push   $0xf010605c
f01007bd:	e8 a5 30 00 00       	call   f0103867 <cprintf>
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
f0100807:	bb a0 65 10 f0       	mov    $0xf01065a0,%ebx
f010080c:	be d0 65 10 f0       	mov    $0xf01065d0,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100811:	83 ec 04             	sub    $0x4,%esp
f0100814:	ff 73 04             	pushl  0x4(%ebx)
f0100817:	ff 33                	pushl  (%ebx)
f0100819:	68 a0 62 10 f0       	push   $0xf01062a0
f010081e:	e8 44 30 00 00       	call   f0103867 <cprintf>
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
f010083f:	68 a9 62 10 f0       	push   $0xf01062a9
f0100844:	e8 1e 30 00 00       	call   f0103867 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100849:	83 c4 08             	add    $0x8,%esp
f010084c:	68 0c 00 10 00       	push   $0x10000c
f0100851:	68 a4 63 10 f0       	push   $0xf01063a4
f0100856:	e8 0c 30 00 00       	call   f0103867 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010085b:	83 c4 0c             	add    $0xc,%esp
f010085e:	68 0c 00 10 00       	push   $0x10000c
f0100863:	68 0c 00 10 f0       	push   $0xf010000c
f0100868:	68 cc 63 10 f0       	push   $0xf01063cc
f010086d:	e8 f5 2f 00 00       	call   f0103867 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100872:	83 c4 0c             	add    $0xc,%esp
f0100875:	68 31 5f 10 00       	push   $0x105f31
f010087a:	68 31 5f 10 f0       	push   $0xf0105f31
f010087f:	68 f0 63 10 f0       	push   $0xf01063f0
f0100884:	e8 de 2f 00 00       	call   f0103867 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100889:	83 c4 0c             	add    $0xc,%esp
f010088c:	68 98 a5 22 00       	push   $0x22a598
f0100891:	68 98 a5 22 f0       	push   $0xf022a598
f0100896:	68 14 64 10 f0       	push   $0xf0106414
f010089b:	e8 c7 2f 00 00       	call   f0103867 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008a0:	83 c4 0c             	add    $0xc,%esp
f01008a3:	68 08 d0 26 00       	push   $0x26d008
f01008a8:	68 08 d0 26 f0       	push   $0xf026d008
f01008ad:	68 38 64 10 f0       	push   $0xf0106438
f01008b2:	e8 b0 2f 00 00       	call   f0103867 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008b7:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
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
f01008d8:	68 5c 64 10 f0       	push   $0xf010645c
f01008dd:	e8 85 2f 00 00       	call   f0103867 <cprintf>
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
f0100913:	68 88 64 10 f0       	push   $0xf0106488
f0100918:	e8 4a 2f 00 00       	call   f0103867 <cprintf>
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f010091d:	83 c4 18             	add    $0x18,%esp
f0100920:	57                   	push   %edi
f0100921:	53                   	push   %ebx
f0100922:	e8 b9 3f 00 00       	call   f01048e0 <debuginfo_eip>
		cprintf("%s:%d   %s:%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip-info.eip_fn_addr);	
f0100927:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010092a:	89 1c 24             	mov    %ebx,(%esp)
f010092d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100930:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100933:	ff 75 d0             	pushl  -0x30(%ebp)
f0100936:	68 c2 62 10 f0       	push   $0xf01062c2
f010093b:	e8 27 2f 00 00       	call   f0103867 <cprintf>
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
f0100969:	68 cc 64 10 f0       	push   $0xf01064cc
f010096e:	e8 f4 2e 00 00       	call   f0103867 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100973:	c7 04 24 f0 64 10 f0 	movl   $0xf01064f0,(%esp)
f010097a:	e8 e8 2e 00 00       	call   f0103867 <cprintf>


	if (tf != NULL)
f010097f:	83 c4 10             	add    $0x10,%esp
f0100982:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100986:	74 0e                	je     f0100996 <monitor+0x36>
		print_trapframe(tf);
f0100988:	83 ec 0c             	sub    $0xc,%esp
f010098b:	ff 75 08             	pushl  0x8(%ebp)
f010098e:	e8 76 33 00 00       	call   f0103d09 <print_trapframe>
f0100993:	83 c4 10             	add    $0x10,%esp


	//my code here 
	cprintf("here show code of myself\n");
f0100996:	83 ec 0c             	sub    $0xc,%esp
f0100999:	68 d1 62 10 f0       	push   $0xf01062d1
f010099e:	e8 c4 2e 00 00       	call   f0103867 <cprintf>
	for(int i = 0;i<200;i++){
		cprintf("%d",i);
		cprintf("abcdefghijklmnopqrstuvwxyz0123456789");
	}
	*/
	cprintf("yourname is xuyongkang.");
f01009a3:	c7 04 24 eb 62 10 f0 	movl   $0xf01062eb,(%esp)
f01009aa:	e8 b8 2e 00 00       	call   f0103867 <cprintf>
	cprintf("\033[1m\033[45;33m HELLO_WORLD \033[0m\n");
f01009af:	c7 04 24 18 65 10 f0 	movl   $0xf0106518,(%esp)
f01009b6:	e8 ac 2e 00 00       	call   f0103867 <cprintf>
	cprintf("\a\n");
f01009bb:	c7 04 24 03 63 10 f0 	movl   $0xf0106303,(%esp)
f01009c2:	e8 a0 2e 00 00       	call   f0103867 <cprintf>
	cprintf("\a\n");
f01009c7:	c7 04 24 03 63 10 f0 	movl   $0xf0106303,(%esp)
f01009ce:	e8 94 2e 00 00       	call   f0103867 <cprintf>
	int x = 1,y = 3,z = 4;
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009d3:	6a 04                	push   $0x4
f01009d5:	6a 03                	push   $0x3
f01009d7:	6a 01                	push   $0x1
f01009d9:	68 06 63 10 f0       	push   $0xf0106306
f01009de:	e8 84 2e 00 00       	call   f0103867 <cprintf>
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009e3:	83 c4 20             	add    $0x20,%esp
f01009e6:	6a 04                	push   $0x4
f01009e8:	6a 03                	push   $0x3
f01009ea:	6a 01                	push   $0x1
f01009ec:	68 06 63 10 f0       	push   $0xf0106306
f01009f1:	e8 71 2e 00 00       	call   f0103867 <cprintf>
 	cprintf("x,y,x");
f01009f6:	c7 04 24 16 63 10 f0 	movl   $0xf0106316,(%esp)
f01009fd:	e8 65 2e 00 00       	call   f0103867 <cprintf>
f0100a02:	83 c4 10             	add    $0x10,%esp
       

	//my code end

	while (1) {
		buf = readline("K> ");
f0100a05:	83 ec 0c             	sub    $0xc,%esp
f0100a08:	68 1c 63 10 f0       	push   $0xf010631c
f0100a0d:	e8 20 46 00 00       	call   f0105032 <readline>
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
f0100a41:	68 20 63 10 f0       	push   $0xf0106320
f0100a46:	e8 01 48 00 00       	call   f010524c <strchr>
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
f0100a61:	68 25 63 10 f0       	push   $0xf0106325
f0100a66:	e8 fc 2d 00 00       	call   f0103867 <cprintf>
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
f0100a8a:	68 20 63 10 f0       	push   $0xf0106320
f0100a8f:	e8 b8 47 00 00       	call   f010524c <strchr>
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
f0100ab8:	ff 34 85 a0 65 10 f0 	pushl  -0xfef9a60(,%eax,4)
f0100abf:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ac2:	e8 27 47 00 00       	call   f01051ee <strcmp>
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
f0100adc:	ff 14 85 a8 65 10 f0 	call   *-0xfef9a58(,%eax,4)
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
f0100afd:	68 42 63 10 f0       	push   $0xf0106342
f0100b02:	e8 60 2d 00 00       	call   f0103867 <cprintf>
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
f0100b1a:	83 3d 38 b2 22 f0 00 	cmpl   $0x0,0xf022b238
f0100b21:	75 11                	jne    f0100b34 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b23:	ba 07 e0 26 f0       	mov    $0xf026e007,%edx
f0100b28:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b2e:	89 15 38 b2 22 f0    	mov    %edx,0xf022b238
	if(n>0){
		result = nextfree;
		nextfree = ROUNDUP(nextfree+n,PGSIZE);
		return result;
	}else{
		return nextfree;
f0100b34:	8b 15 38 b2 22 f0    	mov    0xf022b238,%edx
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
f0100b4a:	a3 38 b2 22 f0       	mov    %eax,0xf022b238
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
f0100b5e:	e8 85 2b 00 00       	call   f01036e8 <mc146818_read>
f0100b63:	89 c6                	mov    %eax,%esi
f0100b65:	83 c3 01             	add    $0x1,%ebx
f0100b68:	89 1c 24             	mov    %ebx,(%esp)
f0100b6b:	e8 78 2b 00 00       	call   f01036e8 <mc146818_read>
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
f0100b92:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
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
f0100ba1:	68 08 60 10 f0       	push   $0xf0106008
f0100ba6:	68 44 05 00 00       	push   $0x544
f0100bab:	68 41 6f 10 f0       	push   $0xf0106f41
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
f0100bf9:	68 d0 65 10 f0       	push   $0xf01065d0
f0100bfe:	68 46 04 00 00       	push   $0x446
f0100c03:	68 41 6f 10 f0       	push   $0xf0106f41
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
f0100c1b:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
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
f0100c51:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
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
f0100c5b:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100c61:	eb 50                	jmp    f0100cb3 <check_page_free_list+0xd3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c63:	89 d8                	mov    %ebx,%eax
f0100c65:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
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
f0100c7f:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100c85:	72 12                	jb     f0100c99 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c87:	50                   	push   %eax
f0100c88:	68 08 60 10 f0       	push   $0xf0106008
f0100c8d:	6a 58                	push   $0x58
f0100c8f:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0100c94:	e8 fb f3 ff ff       	call   f0100094 <_panic>
			//cprintf("PageInfo.size():%x\n",sizeof(struct PageInfo));

			//:/cprintf("#check_page_free_list:page2kva(pp):%x\n",page2kva(pp));
			memset(page2kva(pp), 0x00, 128);
f0100c99:	83 ec 04             	sub    $0x4,%esp
f0100c9c:	68 80 00 00 00       	push   $0x80
f0100ca1:	6a 00                	push   $0x0
f0100ca3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ca8:	50                   	push   %eax
f0100ca9:	e8 db 45 00 00       	call   f0105289 <memset>
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
f0100cc4:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cca:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
		assert(pp < pages + npages);
f0100cd0:	a1 88 be 22 f0       	mov    0xf022be88,%eax
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
f0100cef:	68 5b 6f 10 f0       	push   $0xf0106f5b
f0100cf4:	68 67 6f 10 f0       	push   $0xf0106f67
f0100cf9:	68 6d 04 00 00       	push   $0x46d
f0100cfe:	68 41 6f 10 f0       	push   $0xf0106f41
f0100d03:	e8 8c f3 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100d08:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d0b:	72 19                	jb     f0100d26 <check_page_free_list+0x146>
f0100d0d:	68 7c 6f 10 f0       	push   $0xf0106f7c
f0100d12:	68 67 6f 10 f0       	push   $0xf0106f67
f0100d17:	68 6e 04 00 00       	push   $0x46e
f0100d1c:	68 41 6f 10 f0       	push   $0xf0106f41
f0100d21:	e8 6e f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d26:	89 d0                	mov    %edx,%eax
f0100d28:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d2b:	a8 07                	test   $0x7,%al
f0100d2d:	74 19                	je     f0100d48 <check_page_free_list+0x168>
f0100d2f:	68 f4 65 10 f0       	push   $0xf01065f4
f0100d34:	68 67 6f 10 f0       	push   $0xf0106f67
f0100d39:	68 6f 04 00 00       	push   $0x46f
f0100d3e:	68 41 6f 10 f0       	push   $0xf0106f41
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
f0100d52:	68 90 6f 10 f0       	push   $0xf0106f90
f0100d57:	68 67 6f 10 f0       	push   $0xf0106f67
f0100d5c:	68 75 04 00 00       	push   $0x475
f0100d61:	68 41 6f 10 f0       	push   $0xf0106f41
f0100d66:	e8 29 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d6b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d70:	75 19                	jne    f0100d8b <check_page_free_list+0x1ab>
f0100d72:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100d77:	68 67 6f 10 f0       	push   $0xf0106f67
f0100d7c:	68 76 04 00 00       	push   $0x476
f0100d81:	68 41 6f 10 f0       	push   $0xf0106f41
f0100d86:	e8 09 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d8b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d90:	75 19                	jne    f0100dab <check_page_free_list+0x1cb>
f0100d92:	68 28 66 10 f0       	push   $0xf0106628
f0100d97:	68 67 6f 10 f0       	push   $0xf0106f67
f0100d9c:	68 77 04 00 00       	push   $0x477
f0100da1:	68 41 6f 10 f0       	push   $0xf0106f41
f0100da6:	e8 e9 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dab:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100db0:	75 19                	jne    f0100dcb <check_page_free_list+0x1eb>
f0100db2:	68 ba 6f 10 f0       	push   $0xf0106fba
f0100db7:	68 67 6f 10 f0       	push   $0xf0106f67
f0100dbc:	68 78 04 00 00       	push   $0x478
f0100dc1:	68 41 6f 10 f0       	push   $0xf0106f41
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
f0100de1:	68 08 60 10 f0       	push   $0xf0106008
f0100de6:	6a 58                	push   $0x58
f0100de8:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0100ded:	e8 a2 f2 ff ff       	call   f0100094 <_panic>
f0100df2:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100df8:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100dfb:	0f 86 b6 00 00 00    	jbe    f0100eb7 <check_page_free_list+0x2d7>
f0100e01:	68 4c 66 10 f0       	push   $0xf010664c
f0100e06:	68 67 6f 10 f0       	push   $0xf0106f67
f0100e0b:	68 7c 04 00 00       	push   $0x47c
f0100e10:	68 41 6f 10 f0       	push   $0xf0106f41
f0100e15:	e8 7a f2 ff ff       	call   f0100094 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e1a:	68 d4 6f 10 f0       	push   $0xf0106fd4
f0100e1f:	68 67 6f 10 f0       	push   $0xf0106f67
f0100e24:	68 7e 04 00 00       	push   $0x47e
f0100e29:	68 41 6f 10 f0       	push   $0xf0106f41
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
f0100e49:	68 f1 6f 10 f0       	push   $0xf0106ff1
f0100e4e:	68 67 6f 10 f0       	push   $0xf0106f67
f0100e53:	68 86 04 00 00       	push   $0x486
f0100e58:	68 41 6f 10 f0       	push   $0xf0106f41
f0100e5d:	e8 32 f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100e62:	85 db                	test   %ebx,%ebx
f0100e64:	7f 19                	jg     f0100e7f <check_page_free_list+0x29f>
f0100e66:	68 03 70 10 f0       	push   $0xf0107003
f0100e6b:	68 67 6f 10 f0       	push   $0xf0106f67
f0100e70:	68 87 04 00 00       	push   $0x487
f0100e75:	68 41 6f 10 f0       	push   $0xf0106f41
f0100e7a:	e8 15 f2 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e7f:	83 ec 0c             	sub    $0xc,%esp
f0100e82:	68 94 66 10 f0       	push   $0xf0106694
f0100e87:	e8 db 29 00 00       	call   f0103867 <cprintf>
}
f0100e8c:	eb 49                	jmp    f0100ed7 <check_page_free_list+0x2f7>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e8e:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0100e93:	85 c0                	test   %eax,%eax
f0100e95:	0f 85 72 fd ff ff    	jne    f0100c0d <check_page_free_list+0x2d>
f0100e9b:	e9 56 fd ff ff       	jmp    f0100bf6 <check_page_free_list+0x16>
f0100ea0:	83 3d 40 b2 22 f0 00 	cmpl   $0x0,0xf022b240
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
f0100ee4:	a1 90 be 22 f0       	mov    0xf022be90,%eax
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
f0100f07:	8b 35 40 b2 22 f0    	mov    0xf022b240,%esi
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
f0100f2a:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
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
f0100f4a:	03 1d 90 be 22 f0    	add    0xf022be90,%ebx
f0100f50:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
             pages[i].pp_link = page_free_list;
f0100f56:	89 33                	mov    %esi,(%ebx)
             page_free_list = &pages[i];
f0100f58:	89 ce                	mov    %ecx,%esi
f0100f5a:	03 35 90 be 22 f0    	add    0xf022be90,%esi
f0100f60:	bb 01 00 00 00       	mov    $0x1,%ebx
     pages[0].pp_link = NULL;
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
f0100f65:	83 c2 01             	add    $0x1,%edx
f0100f68:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100f6e:	72 a9                	jb     f0100f19 <page_init+0x3a>
f0100f70:	84 db                	test   %bl,%bl
f0100f72:	74 06                	je     f0100f7a <page_init+0x9b>
f0100f74:	89 35 40 b2 22 f0    	mov    %esi,0xf022b240
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
f0100f85:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
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
f0100fa5:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0100fac:	00 00 00 
f0100faf:	eb 7f                	jmp    f0101030 <page_alloc+0xb2>
f0100fb1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100fb6:	75 da                	jne    f0100f92 <page_alloc+0x14>
f0100fb8:	84 c0                	test   %al,%al
f0100fba:	74 06                	je     f0100fc2 <page_alloc+0x44>
f0100fbc:	89 1d 40 b2 22 f0    	mov    %ebx,0xf022b240
//cprintf("#497 alloc_error:we don't consider the condition that only one node left.\n");
//cprintf("page_free_list->pp_ref:0x%x,pp_link:0x%x\n\n\n",page_free_list->pp_ref,page_free_list->pp_link);			
		struct PageInfo * return_PageInfo = NULL;
		return_PageInfo = page_free_list;
		
		if(page_free_list->pp_link == NULL){
f0100fc2:	8b 03                	mov    (%ebx),%eax
f0100fc4:	85 c0                	test   %eax,%eax
f0100fc6:	75 12                	jne    f0100fda <page_alloc+0x5c>
			page_free_list = NULL;
f0100fc8:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0100fcf:	00 00 00 
			return_PageInfo->pp_link = NULL;
f0100fd2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
f0100fd8:	eb 0b                	jmp    f0100fe5 <page_alloc+0x67>
		}else{
			page_free_list = return_PageInfo->pp_link;
f0100fda:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
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
f0100fed:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100ff3:	c1 f8 03             	sar    $0x3,%eax
f0100ff6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff9:	89 c2                	mov    %eax,%edx
f0100ffb:	c1 ea 0c             	shr    $0xc,%edx
f0100ffe:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101004:	72 12                	jb     f0101018 <page_alloc+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101006:	50                   	push   %eax
f0101007:	68 08 60 10 f0       	push   $0xf0106008
f010100c:	6a 58                	push   $0x58
f010100e:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0101013:	e8 7c f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(return_PageInfo),'\0',PGSIZE);
f0101018:	83 ec 04             	sub    $0x4,%esp
f010101b:	68 00 10 00 00       	push   $0x1000
f0101020:	6a 00                	push   $0x0
f0101022:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101027:	50                   	push   %eax
f0101028:	e8 5c 42 00 00       	call   f0105289 <memset>
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
f0101050:	68 b8 66 10 f0       	push   $0xf01066b8
f0101055:	68 ff 01 00 00       	push   $0x1ff
f010105a:	68 41 6f 10 f0       	push   $0xf0106f41
f010105f:	e8 30 f0 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101064:	89 d8                	mov    %ebx,%eax
f0101066:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010106c:	c1 f8 03             	sar    $0x3,%eax
f010106f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101072:	89 c2                	mov    %eax,%edx
f0101074:	c1 ea 0c             	shr    $0xc,%edx
f0101077:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010107d:	72 12                	jb     f0101091 <page_free+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010107f:	50                   	push   %eax
f0101080:	68 08 60 10 f0       	push   $0xf0106008
f0101085:	6a 58                	push   $0x58
f0101087:	68 4d 6f 10 f0       	push   $0xf0106f4d
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
f01010a1:	e8 e3 41 00 00       	call   f0105289 <memset>
f01010a6:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
			
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
f01010c4:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f01010cb:	00 00 00 
f01010ce:	eb 10                	jmp    f01010e0 <page_free+0xa9>
f01010d0:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010d5:	75 de                	jne    f01010b5 <page_free+0x7e>
f01010d7:	84 d2                	test   %dl,%dl
f01010d9:	74 05                	je     f01010e0 <page_free+0xa9>
f01010db:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
				page_free_list = page_free_list->pp_link;
			}
			if(pp != page_free_list){
f01010e0:	39 c3                	cmp    %eax,%ebx
f01010e2:	74 08                	je     f01010ec <page_free+0xb5>
				struct PageInfo * temp_free_page_list = page_free_list;
				page_free_list = pp;
f01010e4:	89 1d 40 b2 22 f0    	mov    %ebx,0xf022b240
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
f0101157:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f010115d:	c1 fa 03             	sar    $0x3,%edx
f0101160:	c1 e2 0c             	shl    $0xc,%edx
f0101163:	89 16                	mov    %edx,(%esi)
//cprintf("from the else exit.\n\n");
				return (pte_t*)(KADDR(PTE_ADDR(page2pa(return_page))))+PTX(va);
f0101165:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010116b:	c1 f8 03             	sar    $0x3,%eax
f010116e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101171:	89 c2                	mov    %eax,%edx
f0101173:	c1 ea 0c             	shr    $0xc,%edx
f0101176:	39 15 88 be 22 f0    	cmp    %edx,0xf022be88
f010117c:	77 15                	ja     f0101193 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010117e:	50                   	push   %eax
f010117f:	68 08 60 10 f0       	push   $0xf0106008
f0101184:	68 71 02 00 00       	push   $0x271
f0101189:	68 41 6f 10 f0       	push   $0xf0106f41
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
f01011af:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01011b5:	72 15                	jb     f01011cc <pgdir_walk+0xb4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011b7:	50                   	push   %eax
f01011b8:	68 08 60 10 f0       	push   $0xf0106008
f01011bd:	68 79 02 00 00       	push   $0x279
f01011c2:	68 41 6f 10 f0       	push   $0xf0106f41
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
f010124c:	68 2c 60 10 f0       	push   $0xf010602c
f0101251:	68 a8 02 00 00       	push   $0x2a8
f0101256:	68 41 6f 10 f0       	push   $0xf0106f41
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
f01012ba:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01012c0:	72 14                	jb     f01012d6 <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f01012c2:	83 ec 04             	sub    $0x4,%esp
f01012c5:	68 d8 66 10 f0       	push   $0xf01066d8
f01012ca:	6a 51                	push   $0x51
f01012cc:	68 4d 6f 10 f0       	push   $0xf0106f4d
f01012d1:	e8 be ed ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f01012d6:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
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
f01012f8:	e8 ad 45 00 00       	call   f01058aa <cpunum>
f01012fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0101300:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0101307:	74 16                	je     f010131f <tlb_invalidate+0x2d>
f0101309:	e8 9c 45 00 00       	call   f01058aa <cpunum>
f010130e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101311:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
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
f0101376:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101379:	8b 75 0c             	mov    0xc(%ebp),%esi
f010137c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	//my code start here
	pde_t * returned_page_table_entry;
	struct PageInfo * returned_page_table_entry_page;
//cprintf("#### before remove page_free_list:%x\n",page_free_list);
	page_remove(pgdir,va);
f010137f:	53                   	push   %ebx
f0101380:	57                   	push   %edi
f0101381:	e8 a1 ff ff ff       	call   f0101327 <page_remove>
//cprintf("#### after remove page_free_list:%x\n",page_free_list);
	//if it is not mapped,page_remove() do nothing.
	returned_page_table_entry = pgdir_walk(pgdir,va,1);
f0101386:	83 c4 0c             	add    $0xc,%esp
f0101389:	6a 01                	push   $0x1
f010138b:	53                   	push   %ebx
f010138c:	57                   	push   %edi
f010138d:	e8 86 fd ff ff       	call   f0101118 <pgdir_walk>
	*/
//	cprintf("the pp is:%x\n",pp);	
//	cprintf("the page2pa(pp) is:%x\n",page2pa(pp));
//	cprintf("the returned_page_table_entry:%x\n",returned_page_table_entry);	

	if(returned_page_table_entry != NULL){
f0101392:	83 c4 10             	add    $0x10,%esp
f0101395:	85 c0                	test   %eax,%eax
f0101397:	74 53                	je     f01013ec <page_insert+0x7f>
		

		//we have already insert the right side of the equation in
		// the pgdir[PDX(va)] in the pgdir_walk(),but we do it again 
		//here to insert the permission
		pgdir[PDX(va)] = PADDR((void*)((uint32_t)(returned_page_table_entry)|perm|PTE_P));
f0101399:	c1 eb 16             	shr    $0x16,%ebx
f010139c:	8d 1c 9f             	lea    (%edi,%ebx,4),%ebx
f010139f:	8b 55 14             	mov    0x14(%ebp),%edx
f01013a2:	83 ca 01             	or     $0x1,%edx
f01013a5:	89 c1                	mov    %eax,%ecx
f01013a7:	09 d1                	or     %edx,%ecx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013a9:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01013af:	77 15                	ja     f01013c6 <page_insert+0x59>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013b1:	51                   	push   %ecx
f01013b2:	68 2c 60 10 f0       	push   $0xf010602c
f01013b7:	68 f1 02 00 00       	push   $0x2f1
f01013bc:	68 41 6f 10 f0       	push   $0xf0106f41
f01013c1:	e8 ce ec ff ff       	call   f0100094 <_panic>
f01013c6:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f01013cc:	89 0b                	mov    %ecx,(%ebx)
			//PTE_ADDR(page2pa(returned_page_table_table_entry)));
//		cprintf("in the return is not NULL before\n");
//		cprintf("PTX(va):%d\n",PTX(va));
//		cprintf("the va address:%x\n",va);
//		cprintf("the returned_page_table_entry:%x\n",returned_page_table_entry);
		*returned_page_table_entry = (page2pa(pp))|perm|PTE_P;
f01013ce:	89 f1                	mov    %esi,%ecx
f01013d0:	2b 0d 90 be 22 f0    	sub    0xf022be90,%ecx
f01013d6:	c1 f9 03             	sar    $0x3,%ecx
f01013d9:	c1 e1 0c             	shl    $0xc,%ecx
f01013dc:	09 ca                	or     %ecx,%edx
f01013de:	89 10                	mov    %edx,(%eax)
		//NOTE. 

	
//cprintf("after KADDR:%x\n",((pde_t*)((pde_t)returned_page_table_entry))[PTX(va)] );

		pp->pp_ref++;
f01013e0:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
//		cprintf("page2pa(pp)|perm|PTE_P:%x\n",page2pa(pp)|perm|PTE_P);	
		//how do you know the 'va' has phy page mapped
		//use function page_lookup.	
		//pgdir_walk();->page_alloc();
		//page_remove();
		return 0;	
f01013e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01013ea:	eb 05                	jmp    f01013f1 <page_insert+0x84>
	}else{
//		cprintf("E_NO_MEM%d\n",-E_NO_MEM);
		return -E_NO_MEM;
f01013ec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
}
f01013f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013f4:	5b                   	pop    %ebx
f01013f5:	5e                   	pop    %esi
f01013f6:	5f                   	pop    %edi
f01013f7:	5d                   	pop    %ebp
f01013f8:	c3                   	ret    

f01013f9 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013f9:	55                   	push   %ebp
f01013fa:	89 e5                	mov    %esp,%ebp
f01013fc:	53                   	push   %ebx
f01013fd:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t total_size = ROUNDUP(size,PGSIZE);
f0101400:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101403:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101409:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(MMIOBASE+total_size>MMIOLIM){
f010140f:	8d 83 00 00 80 ef    	lea    -0x10800000(%ebx),%eax
f0101415:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010141a:	76 17                	jbe    f0101433 <mmio_map_region+0x3a>
		panic("panic at mmio_map_region.\n");
f010141c:	83 ec 04             	sub    $0x4,%esp
f010141f:	68 14 70 10 f0       	push   $0xf0107014
f0101424:	68 ca 03 00 00       	push   $0x3ca
f0101429:	68 41 6f 10 f0       	push   $0xf0106f41
f010142e:	e8 61 ec ff ff       	call   f0100094 <_panic>
	}else{
		boot_map_region(kern_pgdir,base,total_size,pa,PTE_W|PTE_PCD|PTE_PWT);
f0101433:	83 ec 08             	sub    $0x8,%esp
f0101436:	6a 1a                	push   $0x1a
f0101438:	ff 75 08             	pushl  0x8(%ebp)
f010143b:	89 d9                	mov    %ebx,%ecx
f010143d:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101443:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101448:	e8 a4 fd ff ff       	call   f01011f1 <boot_map_region>
	}
	base+=total_size;
f010144d:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101452:	01 c3                	add    %eax,%ebx
f0101454:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void *)base-total_size;
}
f010145a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010145d:	c9                   	leave  
f010145e:	c3                   	ret    

f010145f <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010145f:	55                   	push   %ebp
f0101460:	89 e5                	mov    %esp,%ebp
f0101462:	57                   	push   %edi
f0101463:	56                   	push   %esi
f0101464:	53                   	push   %ebx
f0101465:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101468:	b8 15 00 00 00       	mov    $0x15,%eax
f010146d:	e8 e1 f6 ff ff       	call   f0100b53 <nvram_read>
f0101472:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101474:	b8 17 00 00 00       	mov    $0x17,%eax
f0101479:	e8 d5 f6 ff ff       	call   f0100b53 <nvram_read>
f010147e:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101480:	b8 34 00 00 00       	mov    $0x34,%eax
f0101485:	e8 c9 f6 ff ff       	call   f0100b53 <nvram_read>
f010148a:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010148d:	85 c0                	test   %eax,%eax
f010148f:	74 07                	je     f0101498 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101491:	05 00 40 00 00       	add    $0x4000,%eax
f0101496:	eb 0b                	jmp    f01014a3 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101498:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f010149e:	85 f6                	test   %esi,%esi
f01014a0:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014a3:	89 c2                	mov    %eax,%edx
f01014a5:	c1 ea 02             	shr    $0x2,%edx
f01014a8:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014ae:	89 c2                	mov    %eax,%edx
f01014b0:	29 da                	sub    %ebx,%edx
f01014b2:	52                   	push   %edx
f01014b3:	53                   	push   %ebx
f01014b4:	50                   	push   %eax
f01014b5:	68 f8 66 10 f0       	push   $0xf01066f8
f01014ba:	e8 a8 23 00 00       	call   f0103867 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014bf:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014c4:	e8 4e f6 ff ff       	call   f0100b17 <boot_alloc>
f01014c9:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f01014ce:	83 c4 0c             	add    $0xc,%esp
f01014d1:	68 00 10 00 00       	push   $0x1000
f01014d6:	6a 00                	push   $0x0
f01014d8:	50                   	push   %eax
f01014d9:	e8 ab 3d 00 00       	call   f0105289 <memset>
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014de:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014e3:	83 c4 10             	add    $0x10,%esp
f01014e6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014eb:	77 15                	ja     f0101502 <mem_init+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014ed:	50                   	push   %eax
f01014ee:	68 2c 60 10 f0       	push   $0xf010602c
f01014f3:	68 9f 00 00 00       	push   $0x9f
f01014f8:	68 41 6f 10 f0       	push   $0xf0106f41
f01014fd:	e8 92 eb ff ff       	call   f0100094 <_panic>
f0101502:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101508:	83 ca 05             	or     $0x5,%edx
f010150b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pde_t * page_root = (pde_t*)boot_alloc(sizeof(struct PageInfo)*npages); 	
f0101511:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101516:	c1 e0 03             	shl    $0x3,%eax
f0101519:	e8 f9 f5 ff ff       	call   f0100b17 <boot_alloc>
f010151e:	89 c3                	mov    %eax,%ebx
	memset(page_root, 0, (sizeof(struct PageInfo)*npages));
f0101520:	83 ec 04             	sub    $0x4,%esp
f0101523:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101528:	c1 e0 03             	shl    $0x3,%eax
f010152b:	50                   	push   %eax
f010152c:	6a 00                	push   $0x0
f010152e:	53                   	push   %ebx
f010152f:	e8 55 3d 00 00       	call   f0105289 <memset>

        pages = (struct PageInfo*)page_root;
f0101534:	89 1d 90 be 22 f0    	mov    %ebx,0xf022be90

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));	
f010153a:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010153f:	e8 d3 f5 ff ff       	call   f0100b17 <boot_alloc>
f0101544:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101549:	e8 91 f9 ff ff       	call   f0100edf <page_init>

	check_page_free_list(1);
f010154e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101553:	e8 88 f6 ff ff       	call   f0100be0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101558:	83 c4 10             	add    $0x10,%esp
f010155b:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0101562:	75 17                	jne    f010157b <mem_init+0x11c>
		panic("'pages' is a null pointer!");
f0101564:	83 ec 04             	sub    $0x4,%esp
f0101567:	68 2f 70 10 f0       	push   $0xf010702f
f010156c:	68 9a 04 00 00       	push   $0x49a
f0101571:	68 41 6f 10 f0       	push   $0xf0106f41
f0101576:	e8 19 eb ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010157b:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101580:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101585:	eb 05                	jmp    f010158c <mem_init+0x12d>
		++nfree;
f0101587:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010158a:	8b 00                	mov    (%eax),%eax
f010158c:	85 c0                	test   %eax,%eax
f010158e:	75 f7                	jne    f0101587 <mem_init+0x128>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101590:	83 ec 0c             	sub    $0xc,%esp
f0101593:	6a 00                	push   $0x0
f0101595:	e8 e4 f9 ff ff       	call   f0100f7e <page_alloc>
f010159a:	89 c7                	mov    %eax,%edi
f010159c:	83 c4 10             	add    $0x10,%esp
f010159f:	85 c0                	test   %eax,%eax
f01015a1:	75 19                	jne    f01015bc <mem_init+0x15d>
f01015a3:	68 4a 70 10 f0       	push   $0xf010704a
f01015a8:	68 67 6f 10 f0       	push   $0xf0106f67
f01015ad:	68 a2 04 00 00       	push   $0x4a2
f01015b2:	68 41 6f 10 f0       	push   $0xf0106f41
f01015b7:	e8 d8 ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01015bc:	83 ec 0c             	sub    $0xc,%esp
f01015bf:	6a 00                	push   $0x0
f01015c1:	e8 b8 f9 ff ff       	call   f0100f7e <page_alloc>
f01015c6:	89 c6                	mov    %eax,%esi
f01015c8:	83 c4 10             	add    $0x10,%esp
f01015cb:	85 c0                	test   %eax,%eax
f01015cd:	75 19                	jne    f01015e8 <mem_init+0x189>
f01015cf:	68 60 70 10 f0       	push   $0xf0107060
f01015d4:	68 67 6f 10 f0       	push   $0xf0106f67
f01015d9:	68 a3 04 00 00       	push   $0x4a3
f01015de:	68 41 6f 10 f0       	push   $0xf0106f41
f01015e3:	e8 ac ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015e8:	83 ec 0c             	sub    $0xc,%esp
f01015eb:	6a 00                	push   $0x0
f01015ed:	e8 8c f9 ff ff       	call   f0100f7e <page_alloc>
f01015f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015f5:	83 c4 10             	add    $0x10,%esp
f01015f8:	85 c0                	test   %eax,%eax
f01015fa:	75 19                	jne    f0101615 <mem_init+0x1b6>
f01015fc:	68 76 70 10 f0       	push   $0xf0107076
f0101601:	68 67 6f 10 f0       	push   $0xf0106f67
f0101606:	68 a4 04 00 00       	push   $0x4a4
f010160b:	68 41 6f 10 f0       	push   $0xf0106f41
f0101610:	e8 7f ea ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1033.\n");	


	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101615:	39 f7                	cmp    %esi,%edi
f0101617:	75 19                	jne    f0101632 <mem_init+0x1d3>
f0101619:	68 8c 70 10 f0       	push   $0xf010708c
f010161e:	68 67 6f 10 f0       	push   $0xf0106f67
f0101623:	68 aa 04 00 00       	push   $0x4aa
f0101628:	68 41 6f 10 f0       	push   $0xf0106f41
f010162d:	e8 62 ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101632:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101635:	39 c6                	cmp    %eax,%esi
f0101637:	74 04                	je     f010163d <mem_init+0x1de>
f0101639:	39 c7                	cmp    %eax,%edi
f010163b:	75 19                	jne    f0101656 <mem_init+0x1f7>
f010163d:	68 34 67 10 f0       	push   $0xf0106734
f0101642:	68 67 6f 10 f0       	push   $0xf0106f67
f0101647:	68 ab 04 00 00       	push   $0x4ab
f010164c:	68 41 6f 10 f0       	push   $0xf0106f41
f0101651:	e8 3e ea ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101656:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010165c:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f0101662:	c1 e2 0c             	shl    $0xc,%edx
f0101665:	89 f8                	mov    %edi,%eax
f0101667:	29 c8                	sub    %ecx,%eax
f0101669:	c1 f8 03             	sar    $0x3,%eax
f010166c:	c1 e0 0c             	shl    $0xc,%eax
f010166f:	39 d0                	cmp    %edx,%eax
f0101671:	72 19                	jb     f010168c <mem_init+0x22d>
f0101673:	68 9e 70 10 f0       	push   $0xf010709e
f0101678:	68 67 6f 10 f0       	push   $0xf0106f67
f010167d:	68 ac 04 00 00       	push   $0x4ac
f0101682:	68 41 6f 10 f0       	push   $0xf0106f41
f0101687:	e8 08 ea ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010168c:	89 f0                	mov    %esi,%eax
f010168e:	29 c8                	sub    %ecx,%eax
f0101690:	c1 f8 03             	sar    $0x3,%eax
f0101693:	c1 e0 0c             	shl    $0xc,%eax
f0101696:	39 c2                	cmp    %eax,%edx
f0101698:	77 19                	ja     f01016b3 <mem_init+0x254>
f010169a:	68 bb 70 10 f0       	push   $0xf01070bb
f010169f:	68 67 6f 10 f0       	push   $0xf0106f67
f01016a4:	68 ad 04 00 00       	push   $0x4ad
f01016a9:	68 41 6f 10 f0       	push   $0xf0106f41
f01016ae:	e8 e1 e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016b6:	29 c8                	sub    %ecx,%eax
f01016b8:	c1 f8 03             	sar    $0x3,%eax
f01016bb:	c1 e0 0c             	shl    $0xc,%eax
f01016be:	39 c2                	cmp    %eax,%edx
f01016c0:	77 19                	ja     f01016db <mem_init+0x27c>
f01016c2:	68 d8 70 10 f0       	push   $0xf01070d8
f01016c7:	68 67 6f 10 f0       	push   $0xf0106f67
f01016cc:	68 ae 04 00 00       	push   $0x4ae
f01016d1:	68 41 6f 10 f0       	push   $0xf0106f41
f01016d6:	e8 b9 e9 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016db:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f01016e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016e3:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f01016ea:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016ed:	83 ec 0c             	sub    $0xc,%esp
f01016f0:	6a 00                	push   $0x0
f01016f2:	e8 87 f8 ff ff       	call   f0100f7e <page_alloc>
f01016f7:	83 c4 10             	add    $0x10,%esp
f01016fa:	85 c0                	test   %eax,%eax
f01016fc:	74 19                	je     f0101717 <mem_init+0x2b8>
f01016fe:	68 f5 70 10 f0       	push   $0xf01070f5
f0101703:	68 67 6f 10 f0       	push   $0xf0106f67
f0101708:	68 b5 04 00 00       	push   $0x4b5
f010170d:	68 41 6f 10 f0       	push   $0xf0106f41
f0101712:	e8 7d e9 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1050.\n");	


	// free and re-allocate?
	page_free(pp0);
f0101717:	83 ec 0c             	sub    $0xc,%esp
f010171a:	57                   	push   %edi
f010171b:	e8 17 f9 ff ff       	call   f0101037 <page_free>
	page_free(pp1);
f0101720:	89 34 24             	mov    %esi,(%esp)
f0101723:	e8 0f f9 ff ff       	call   f0101037 <page_free>
	page_free(pp2);
f0101728:	83 c4 04             	add    $0x4,%esp
f010172b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010172e:	e8 04 f9 ff ff       	call   f0101037 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101733:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010173a:	e8 3f f8 ff ff       	call   f0100f7e <page_alloc>
f010173f:	89 c6                	mov    %eax,%esi
f0101741:	83 c4 10             	add    $0x10,%esp
f0101744:	85 c0                	test   %eax,%eax
f0101746:	75 19                	jne    f0101761 <mem_init+0x302>
f0101748:	68 4a 70 10 f0       	push   $0xf010704a
f010174d:	68 67 6f 10 f0       	push   $0xf0106f67
f0101752:	68 bf 04 00 00       	push   $0x4bf
f0101757:	68 41 6f 10 f0       	push   $0xf0106f41
f010175c:	e8 33 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101761:	83 ec 0c             	sub    $0xc,%esp
f0101764:	6a 00                	push   $0x0
f0101766:	e8 13 f8 ff ff       	call   f0100f7e <page_alloc>
f010176b:	89 c7                	mov    %eax,%edi
f010176d:	83 c4 10             	add    $0x10,%esp
f0101770:	85 c0                	test   %eax,%eax
f0101772:	75 19                	jne    f010178d <mem_init+0x32e>
f0101774:	68 60 70 10 f0       	push   $0xf0107060
f0101779:	68 67 6f 10 f0       	push   $0xf0106f67
f010177e:	68 c0 04 00 00       	push   $0x4c0
f0101783:	68 41 6f 10 f0       	push   $0xf0106f41
f0101788:	e8 07 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010178d:	83 ec 0c             	sub    $0xc,%esp
f0101790:	6a 00                	push   $0x0
f0101792:	e8 e7 f7 ff ff       	call   f0100f7e <page_alloc>
f0101797:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010179a:	83 c4 10             	add    $0x10,%esp
f010179d:	85 c0                	test   %eax,%eax
f010179f:	75 19                	jne    f01017ba <mem_init+0x35b>
f01017a1:	68 76 70 10 f0       	push   $0xf0107076
f01017a6:	68 67 6f 10 f0       	push   $0xf0106f67
f01017ab:	68 c1 04 00 00       	push   $0x4c1
f01017b0:	68 41 6f 10 f0       	push   $0xf0106f41
f01017b5:	e8 da e8 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017ba:	39 fe                	cmp    %edi,%esi
f01017bc:	75 19                	jne    f01017d7 <mem_init+0x378>
f01017be:	68 8c 70 10 f0       	push   $0xf010708c
f01017c3:	68 67 6f 10 f0       	push   $0xf0106f67
f01017c8:	68 c3 04 00 00       	push   $0x4c3
f01017cd:	68 41 6f 10 f0       	push   $0xf0106f41
f01017d2:	e8 bd e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017da:	39 c7                	cmp    %eax,%edi
f01017dc:	74 04                	je     f01017e2 <mem_init+0x383>
f01017de:	39 c6                	cmp    %eax,%esi
f01017e0:	75 19                	jne    f01017fb <mem_init+0x39c>
f01017e2:	68 34 67 10 f0       	push   $0xf0106734
f01017e7:	68 67 6f 10 f0       	push   $0xf0106f67
f01017ec:	68 c4 04 00 00       	push   $0x4c4
f01017f1:	68 41 6f 10 f0       	push   $0xf0106f41
f01017f6:	e8 99 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017fb:	83 ec 0c             	sub    $0xc,%esp
f01017fe:	6a 00                	push   $0x0
f0101800:	e8 79 f7 ff ff       	call   f0100f7e <page_alloc>
f0101805:	83 c4 10             	add    $0x10,%esp
f0101808:	85 c0                	test   %eax,%eax
f010180a:	74 19                	je     f0101825 <mem_init+0x3c6>
f010180c:	68 f5 70 10 f0       	push   $0xf01070f5
f0101811:	68 67 6f 10 f0       	push   $0xf0106f67
f0101816:	68 c5 04 00 00       	push   $0x4c5
f010181b:	68 41 6f 10 f0       	push   $0xf0106f41
f0101820:	e8 6f e8 ff ff       	call   f0100094 <_panic>
f0101825:	89 f0                	mov    %esi,%eax
f0101827:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010182d:	c1 f8 03             	sar    $0x3,%eax
f0101830:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101833:	89 c2                	mov    %eax,%edx
f0101835:	c1 ea 0c             	shr    $0xc,%edx
f0101838:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f010183e:	72 12                	jb     f0101852 <mem_init+0x3f3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101840:	50                   	push   %eax
f0101841:	68 08 60 10 f0       	push   $0xf0106008
f0101846:	6a 58                	push   $0x58
f0101848:	68 4d 6f 10 f0       	push   $0xf0106f4d
f010184d:	e8 42 e8 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1066.\n");	


	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101852:	83 ec 04             	sub    $0x4,%esp
f0101855:	68 00 10 00 00       	push   $0x1000
f010185a:	6a 01                	push   $0x1
f010185c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101861:	50                   	push   %eax
f0101862:	e8 22 3a 00 00       	call   f0105289 <memset>
	page_free(pp0);
f0101867:	89 34 24             	mov    %esi,(%esp)
f010186a:	e8 c8 f7 ff ff       	call   f0101037 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010186f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101876:	e8 03 f7 ff ff       	call   f0100f7e <page_alloc>
f010187b:	83 c4 10             	add    $0x10,%esp
f010187e:	85 c0                	test   %eax,%eax
f0101880:	75 19                	jne    f010189b <mem_init+0x43c>
f0101882:	68 04 71 10 f0       	push   $0xf0107104
f0101887:	68 67 6f 10 f0       	push   $0xf0106f67
f010188c:	68 cd 04 00 00       	push   $0x4cd
f0101891:	68 41 6f 10 f0       	push   $0xf0106f41
f0101896:	e8 f9 e7 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010189b:	39 c6                	cmp    %eax,%esi
f010189d:	74 19                	je     f01018b8 <mem_init+0x459>
f010189f:	68 22 71 10 f0       	push   $0xf0107122
f01018a4:	68 67 6f 10 f0       	push   $0xf0106f67
f01018a9:	68 ce 04 00 00       	push   $0x4ce
f01018ae:	68 41 6f 10 f0       	push   $0xf0106f41
f01018b3:	e8 dc e7 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b8:	89 f0                	mov    %esi,%eax
f01018ba:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01018c0:	c1 f8 03             	sar    $0x3,%eax
f01018c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018c6:	89 c2                	mov    %eax,%edx
f01018c8:	c1 ea 0c             	shr    $0xc,%edx
f01018cb:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01018d1:	72 12                	jb     f01018e5 <mem_init+0x486>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d3:	50                   	push   %eax
f01018d4:	68 08 60 10 f0       	push   $0xf0106008
f01018d9:	6a 58                	push   $0x58
f01018db:	68 4d 6f 10 f0       	push   $0xf0106f4d
f01018e0:	e8 af e7 ff ff       	call   f0100094 <_panic>
f01018e5:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018eb:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018f1:	80 38 00             	cmpb   $0x0,(%eax)
f01018f4:	74 19                	je     f010190f <mem_init+0x4b0>
f01018f6:	68 32 71 10 f0       	push   $0xf0107132
f01018fb:	68 67 6f 10 f0       	push   $0xf0106f67
f0101900:	68 d1 04 00 00       	push   $0x4d1
f0101905:	68 41 6f 10 f0       	push   $0xf0106f41
f010190a:	e8 85 e7 ff ff       	call   f0100094 <_panic>
f010190f:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101912:	39 d0                	cmp    %edx,%eax
f0101914:	75 db                	jne    f01018f1 <mem_init+0x492>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101916:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101919:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f010191e:	83 ec 0c             	sub    $0xc,%esp
f0101921:	56                   	push   %esi
f0101922:	e8 10 f7 ff ff       	call   f0101037 <page_free>
	page_free(pp1);
f0101927:	89 3c 24             	mov    %edi,(%esp)
f010192a:	e8 08 f7 ff ff       	call   f0101037 <page_free>
	page_free(pp2);
f010192f:	83 c4 04             	add    $0x4,%esp
f0101932:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101935:	e8 fd f6 ff ff       	call   f0101037 <page_free>
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010193a:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f010193f:	83 c4 10             	add    $0x10,%esp
f0101942:	eb 05                	jmp    f0101949 <mem_init+0x4ea>
		--nfree;
f0101944:	83 eb 01             	sub    $0x1,%ebx
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101947:	8b 00                	mov    (%eax),%eax
f0101949:	85 c0                	test   %eax,%eax
f010194b:	75 f7                	jne    f0101944 <mem_init+0x4e5>
		--nfree;
	assert(nfree == 0);
f010194d:	85 db                	test   %ebx,%ebx
f010194f:	74 19                	je     f010196a <mem_init+0x50b>
f0101951:	68 3c 71 10 f0       	push   $0xf010713c
f0101956:	68 67 6f 10 f0       	push   $0xf0106f67
f010195b:	68 e1 04 00 00       	push   $0x4e1
f0101960:	68 41 6f 10 f0       	push   $0xf0106f41
f0101965:	e8 2a e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010196a:	83 ec 0c             	sub    $0xc,%esp
f010196d:	68 54 67 10 f0       	push   $0xf0106754
f0101972:	e8 f0 1e 00 00       	call   f0103867 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101977:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010197e:	e8 fb f5 ff ff       	call   f0100f7e <page_alloc>
f0101983:	89 c6                	mov    %eax,%esi
f0101985:	83 c4 10             	add    $0x10,%esp
f0101988:	85 c0                	test   %eax,%eax
f010198a:	75 19                	jne    f01019a5 <mem_init+0x546>
f010198c:	68 4a 70 10 f0       	push   $0xf010704a
f0101991:	68 67 6f 10 f0       	push   $0xf0106f67
f0101996:	68 5b 05 00 00       	push   $0x55b
f010199b:	68 41 6f 10 f0       	push   $0xf0106f41
f01019a0:	e8 ef e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01019a5:	83 ec 0c             	sub    $0xc,%esp
f01019a8:	6a 00                	push   $0x0
f01019aa:	e8 cf f5 ff ff       	call   f0100f7e <page_alloc>
f01019af:	89 c3                	mov    %eax,%ebx
f01019b1:	83 c4 10             	add    $0x10,%esp
f01019b4:	85 c0                	test   %eax,%eax
f01019b6:	75 19                	jne    f01019d1 <mem_init+0x572>
f01019b8:	68 60 70 10 f0       	push   $0xf0107060
f01019bd:	68 67 6f 10 f0       	push   $0xf0106f67
f01019c2:	68 5c 05 00 00       	push   $0x55c
f01019c7:	68 41 6f 10 f0       	push   $0xf0106f41
f01019cc:	e8 c3 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01019d1:	83 ec 0c             	sub    $0xc,%esp
f01019d4:	6a 00                	push   $0x0
f01019d6:	e8 a3 f5 ff ff       	call   f0100f7e <page_alloc>
f01019db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019de:	83 c4 10             	add    $0x10,%esp
f01019e1:	85 c0                	test   %eax,%eax
f01019e3:	75 19                	jne    f01019fe <mem_init+0x59f>
f01019e5:	68 76 70 10 f0       	push   $0xf0107076
f01019ea:	68 67 6f 10 f0       	push   $0xf0106f67
f01019ef:	68 5d 05 00 00       	push   $0x55d
f01019f4:	68 41 6f 10 f0       	push   $0xf0106f41
f01019f9:	e8 96 e6 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019fe:	39 de                	cmp    %ebx,%esi
f0101a00:	75 19                	jne    f0101a1b <mem_init+0x5bc>
f0101a02:	68 8c 70 10 f0       	push   $0xf010708c
f0101a07:	68 67 6f 10 f0       	push   $0xf0106f67
f0101a0c:	68 60 05 00 00       	push   $0x560
f0101a11:	68 41 6f 10 f0       	push   $0xf0106f41
f0101a16:	e8 79 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a1e:	39 c6                	cmp    %eax,%esi
f0101a20:	74 04                	je     f0101a26 <mem_init+0x5c7>
f0101a22:	39 c3                	cmp    %eax,%ebx
f0101a24:	75 19                	jne    f0101a3f <mem_init+0x5e0>
f0101a26:	68 34 67 10 f0       	push   $0xf0106734
f0101a2b:	68 67 6f 10 f0       	push   $0xf0106f67
f0101a30:	68 61 05 00 00       	push   $0x561
f0101a35:	68 41 6f 10 f0       	push   $0xf0106f41
f0101a3a:	e8 55 e6 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a3f:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101a44:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a47:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101a4e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a51:	83 ec 0c             	sub    $0xc,%esp
f0101a54:	6a 00                	push   $0x0
f0101a56:	e8 23 f5 ff ff       	call   f0100f7e <page_alloc>
f0101a5b:	83 c4 10             	add    $0x10,%esp
f0101a5e:	85 c0                	test   %eax,%eax
f0101a60:	74 19                	je     f0101a7b <mem_init+0x61c>
f0101a62:	68 f5 70 10 f0       	push   $0xf01070f5
f0101a67:	68 67 6f 10 f0       	push   $0xf0106f67
f0101a6c:	68 68 05 00 00       	push   $0x568
f0101a71:	68 41 6f 10 f0       	push   $0xf0106f41
f0101a76:	e8 19 e6 ff ff       	call   f0100094 <_panic>
//cprintf("the page_free_list:%d\n",page_free_list);

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a7b:	83 ec 04             	sub    $0x4,%esp
f0101a7e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a81:	50                   	push   %eax
f0101a82:	6a 00                	push   $0x0
f0101a84:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101a8a:	e8 fe f7 ff ff       	call   f010128d <page_lookup>
f0101a8f:	83 c4 10             	add    $0x10,%esp
f0101a92:	85 c0                	test   %eax,%eax
f0101a94:	74 19                	je     f0101aaf <mem_init+0x650>
f0101a96:	68 74 67 10 f0       	push   $0xf0106774
f0101a9b:	68 67 6f 10 f0       	push   $0xf0106f67
f0101aa0:	68 6c 05 00 00       	push   $0x56c
f0101aa5:	68 41 6f 10 f0       	push   $0xf0106f41
f0101aaa:	e8 e5 e5 ff ff       	call   f0100094 <_panic>
	
//cprintf("#    the page_free_list:%d\n",page_free_list);

	// there is no free memory, so we can't allocate a page table
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101aaf:	6a 02                	push   $0x2
f0101ab1:	6a 00                	push   $0x0
f0101ab3:	53                   	push   %ebx
f0101ab4:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101aba:	e8 ae f8 ff ff       	call   f010136d <page_insert>
f0101abf:	83 c4 10             	add    $0x10,%esp
f0101ac2:	85 c0                	test   %eax,%eax
f0101ac4:	78 19                	js     f0101adf <mem_init+0x680>
f0101ac6:	68 ac 67 10 f0       	push   $0xf01067ac
f0101acb:	68 67 6f 10 f0       	push   $0xf0106f67
f0101ad0:	68 74 05 00 00       	push   $0x574
f0101ad5:	68 41 6f 10 f0       	push   $0xf0106f41
f0101ada:	e8 b5 e5 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
//cprintf("##     the page_free_list:%d\n",page_free_list);
//cprintf("$$ at before the page_free(pp0)\n\n");
	page_free(pp0);
f0101adf:	83 ec 0c             	sub    $0xc,%esp
f0101ae2:	56                   	push   %esi
f0101ae3:	e8 4f f5 ff ff       	call   f0101037 <page_free>
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ae8:	6a 02                	push   $0x2
f0101aea:	6a 00                	push   $0x0
f0101aec:	53                   	push   %ebx
f0101aed:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101af3:	e8 75 f8 ff ff       	call   f010136d <page_insert>
f0101af8:	83 c4 20             	add    $0x20,%esp
f0101afb:	85 c0                	test   %eax,%eax
f0101afd:	74 19                	je     f0101b18 <mem_init+0x6b9>
f0101aff:	68 dc 67 10 f0       	push   $0xf01067dc
f0101b04:	68 67 6f 10 f0       	push   $0xf0106f67
f0101b09:	68 7b 05 00 00       	push   $0x57b
f0101b0e:	68 41 6f 10 f0       	push   $0xf0106f41
f0101b13:	e8 7c e5 ff ff       	call   f0100094 <_panic>

//cprintf("## %x  %x\n",PTE_ADDR(kern_pgdir[0]),page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b18:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b1e:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0101b23:	89 c1                	mov    %eax,%ecx
f0101b25:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b28:	8b 17                	mov    (%edi),%edx
f0101b2a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b30:	89 f0                	mov    %esi,%eax
f0101b32:	29 c8                	sub    %ecx,%eax
f0101b34:	c1 f8 03             	sar    $0x3,%eax
f0101b37:	c1 e0 0c             	shl    $0xc,%eax
f0101b3a:	39 c2                	cmp    %eax,%edx
f0101b3c:	74 19                	je     f0101b57 <mem_init+0x6f8>
f0101b3e:	68 0c 68 10 f0       	push   $0xf010680c
f0101b43:	68 67 6f 10 f0       	push   $0xf0106f67
f0101b48:	68 7e 05 00 00       	push   $0x57e
f0101b4d:	68 41 6f 10 f0       	push   $0xf0106f41
f0101b52:	e8 3d e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b57:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b5c:	89 f8                	mov    %edi,%eax
f0101b5e:	e8 19 f0 ff ff       	call   f0100b7c <check_va2pa>
f0101b63:	89 da                	mov    %ebx,%edx
f0101b65:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b68:	c1 fa 03             	sar    $0x3,%edx
f0101b6b:	c1 e2 0c             	shl    $0xc,%edx
f0101b6e:	39 d0                	cmp    %edx,%eax
f0101b70:	74 19                	je     f0101b8b <mem_init+0x72c>
f0101b72:	68 34 68 10 f0       	push   $0xf0106834
f0101b77:	68 67 6f 10 f0       	push   $0xf0106f67
f0101b7c:	68 7f 05 00 00       	push   $0x57f
f0101b81:	68 41 6f 10 f0       	push   $0xf0106f41
f0101b86:	e8 09 e5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101b8b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b90:	74 19                	je     f0101bab <mem_init+0x74c>
f0101b92:	68 47 71 10 f0       	push   $0xf0107147
f0101b97:	68 67 6f 10 f0       	push   $0xf0106f67
f0101b9c:	68 80 05 00 00       	push   $0x580
f0101ba1:	68 41 6f 10 f0       	push   $0xf0106f41
f0101ba6:	e8 e9 e4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101bab:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bb0:	74 19                	je     f0101bcb <mem_init+0x76c>
f0101bb2:	68 58 71 10 f0       	push   $0xf0107158
f0101bb7:	68 67 6f 10 f0       	push   $0xf0106f67
f0101bbc:	68 81 05 00 00       	push   $0x581
f0101bc1:	68 41 6f 10 f0       	push   $0xf0106f41
f0101bc6:	e8 c9 e4 ff ff       	call   f0100094 <_panic>
//cprintf("###  before page_insert pp2  the page_free_list:%d\n",page_free_list);

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
//cprintf("$$ at before the page_insert pp2 at PGSIZE\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bcb:	6a 02                	push   $0x2
f0101bcd:	68 00 10 00 00       	push   $0x1000
f0101bd2:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bd5:	57                   	push   %edi
f0101bd6:	e8 92 f7 ff ff       	call   f010136d <page_insert>
f0101bdb:	83 c4 10             	add    $0x10,%esp
f0101bde:	85 c0                	test   %eax,%eax
f0101be0:	74 19                	je     f0101bfb <mem_init+0x79c>
f0101be2:	68 64 68 10 f0       	push   $0xf0106864
f0101be7:	68 67 6f 10 f0       	push   $0xf0106f67
f0101bec:	68 86 05 00 00       	push   $0x586
f0101bf1:	68 41 6f 10 f0       	push   $0xf0106f41
f0101bf6:	e8 99 e4 ff ff       	call   f0100094 <_panic>
//cprintf("#### here we get over the page_insert page_free_list:%x.\n",page_free_list);
//cprintf("pp0:%x\npp1:%x\npp2:%x\n",pp0,pp1,pp2);	
//cprintf("!! the check_va2pa is %d,page2pa(pp1) %x\n",check_va2pa(kern_pgdir,PGSIZE),page2pa(pp2));


	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bfb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c00:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101c05:	e8 72 ef ff ff       	call   f0100b7c <check_va2pa>
f0101c0a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c0d:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101c13:	c1 fa 03             	sar    $0x3,%edx
f0101c16:	c1 e2 0c             	shl    $0xc,%edx
f0101c19:	39 d0                	cmp    %edx,%eax
f0101c1b:	74 19                	je     f0101c36 <mem_init+0x7d7>
f0101c1d:	68 a0 68 10 f0       	push   $0xf01068a0
f0101c22:	68 67 6f 10 f0       	push   $0xf0106f67
f0101c27:	68 8c 05 00 00       	push   $0x58c
f0101c2c:	68 41 6f 10 f0       	push   $0xf0106f41
f0101c31:	e8 5e e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101c36:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c39:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c3e:	74 19                	je     f0101c59 <mem_init+0x7fa>
f0101c40:	68 69 71 10 f0       	push   $0xf0107169
f0101c45:	68 67 6f 10 f0       	push   $0xf0106f67
f0101c4a:	68 8d 05 00 00       	push   $0x58d
f0101c4f:	68 41 6f 10 f0       	push   $0xf0106f41
f0101c54:	e8 3b e4 ff ff       	call   f0100094 <_panic>

	// should be no free memory
//cprintf("##### before_page_alloc:  the page_free_list:%d\n",page_free_list);
	assert(!page_alloc(0));
f0101c59:	83 ec 0c             	sub    $0xc,%esp
f0101c5c:	6a 00                	push   $0x0
f0101c5e:	e8 1b f3 ff ff       	call   f0100f7e <page_alloc>
f0101c63:	83 c4 10             	add    $0x10,%esp
f0101c66:	85 c0                	test   %eax,%eax
f0101c68:	74 19                	je     f0101c83 <mem_init+0x824>
f0101c6a:	68 f5 70 10 f0       	push   $0xf01070f5
f0101c6f:	68 67 6f 10 f0       	push   $0xf0106f67
f0101c74:	68 91 05 00 00       	push   $0x591
f0101c79:	68 41 6f 10 f0       	push   $0xf0106f41
f0101c7e:	e8 11 e4 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
//cprintf("$$ at twice before the page_insert pp2 at PGSIZE.\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c83:	6a 02                	push   $0x2
f0101c85:	68 00 10 00 00       	push   $0x1000
f0101c8a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c8d:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101c93:	e8 d5 f6 ff ff       	call   f010136d <page_insert>
f0101c98:	83 c4 10             	add    $0x10,%esp
f0101c9b:	85 c0                	test   %eax,%eax
f0101c9d:	74 19                	je     f0101cb8 <mem_init+0x859>
f0101c9f:	68 64 68 10 f0       	push   $0xf0106864
f0101ca4:	68 67 6f 10 f0       	push   $0xf0106f67
f0101ca9:	68 95 05 00 00       	push   $0x595
f0101cae:	68 41 6f 10 f0       	push   $0xf0106f41
f0101cb3:	e8 dc e3 ff ff       	call   f0100094 <_panic>
//	for(struct PageInfo *temp_pp = page_free_list;temp_pp;temp_pp = temp_pp->pp_link){
//		cprintf("the temp_pp:%x\n",temp_pp);
//	}
	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cb8:	83 ec 0c             	sub    $0xc,%esp
f0101cbb:	6a 00                	push   $0x0
f0101cbd:	e8 bc f2 ff ff       	call   f0100f7e <page_alloc>
f0101cc2:	83 c4 10             	add    $0x10,%esp
f0101cc5:	85 c0                	test   %eax,%eax
f0101cc7:	74 19                	je     f0101ce2 <mem_init+0x883>
f0101cc9:	68 f5 70 10 f0       	push   $0xf01070f5
f0101cce:	68 67 6f 10 f0       	push   $0xf0106f67
f0101cd3:	68 a1 05 00 00       	push   $0x5a1
f0101cd8:	68 41 6f 10 f0       	push   $0xf0106f41
f0101cdd:	e8 b2 e3 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ce2:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0101ce8:	8b 02                	mov    (%edx),%eax
f0101cea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101cef:	89 c1                	mov    %eax,%ecx
f0101cf1:	c1 e9 0c             	shr    $0xc,%ecx
f0101cf4:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0101cfa:	72 15                	jb     f0101d11 <mem_init+0x8b2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cfc:	50                   	push   %eax
f0101cfd:	68 08 60 10 f0       	push   $0xf0106008
f0101d02:	68 a4 05 00 00       	push   $0x5a4
f0101d07:	68 41 6f 10 f0       	push   $0xf0106f41
f0101d0c:	e8 83 e3 ff ff       	call   f0100094 <_panic>
f0101d11:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
//cprintf("the pgdir_walk(kern_pgdir,(void*)PGSIZE,0):%x\n",pgdir_walk(kern_pgdir,(void*)PGSIZE,0));
//cprintf("ptep+PTX(PGSIZE):%x\n",ptep+PTX(PGSIZE));
//cprintf("ptep:%x\n",ptep);
//cprintf("PTX(PGSIZE):%x\n",PTX(PGSIZE));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d19:	83 ec 04             	sub    $0x4,%esp
f0101d1c:	6a 00                	push   $0x0
f0101d1e:	68 00 10 00 00       	push   $0x1000
f0101d23:	52                   	push   %edx
f0101d24:	e8 ef f3 ff ff       	call   f0101118 <pgdir_walk>
f0101d29:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d2c:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d2f:	83 c4 10             	add    $0x10,%esp
f0101d32:	39 d0                	cmp    %edx,%eax
f0101d34:	74 19                	je     f0101d4f <mem_init+0x8f0>
f0101d36:	68 d0 68 10 f0       	push   $0xf01068d0
f0101d3b:	68 67 6f 10 f0       	push   $0xf0106f67
f0101d40:	68 a9 05 00 00       	push   $0x5a9
f0101d45:	68 41 6f 10 f0       	push   $0xf0106f41
f0101d4a:	e8 45 e3 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 3th page_insert pp2 to PGSIZE with changing the permissions.\n\n");
	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d4f:	6a 06                	push   $0x6
f0101d51:	68 00 10 00 00       	push   $0x1000
f0101d56:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d59:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101d5f:	e8 09 f6 ff ff       	call   f010136d <page_insert>
f0101d64:	83 c4 10             	add    $0x10,%esp
f0101d67:	85 c0                	test   %eax,%eax
f0101d69:	74 19                	je     f0101d84 <mem_init+0x925>
f0101d6b:	68 10 69 10 f0       	push   $0xf0106910
f0101d70:	68 67 6f 10 f0       	push   $0xf0106f67
f0101d75:	68 ac 05 00 00       	push   $0x5ac
f0101d7a:	68 41 6f 10 f0       	push   $0xf0106f41
f0101d7f:	e8 10 e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d84:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0101d8a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d8f:	89 f8                	mov    %edi,%eax
f0101d91:	e8 e6 ed ff ff       	call   f0100b7c <check_va2pa>
f0101d96:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d99:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101d9f:	c1 fa 03             	sar    $0x3,%edx
f0101da2:	c1 e2 0c             	shl    $0xc,%edx
f0101da5:	39 d0                	cmp    %edx,%eax
f0101da7:	74 19                	je     f0101dc2 <mem_init+0x963>
f0101da9:	68 a0 68 10 f0       	push   $0xf01068a0
f0101dae:	68 67 6f 10 f0       	push   $0xf0106f67
f0101db3:	68 ad 05 00 00       	push   $0x5ad
f0101db8:	68 41 6f 10 f0       	push   $0xf0106f41
f0101dbd:	e8 d2 e2 ff ff       	call   f0100094 <_panic>
//	cprintf("the final pp2->pp_ref:%x\n",pp2->pp_ref);
	assert(pp2->pp_ref == 1);
f0101dc2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dca:	74 19                	je     f0101de5 <mem_init+0x986>
f0101dcc:	68 69 71 10 f0       	push   $0xf0107169
f0101dd1:	68 67 6f 10 f0       	push   $0xf0106f67
f0101dd6:	68 af 05 00 00       	push   $0x5af
f0101ddb:	68 41 6f 10 f0       	push   $0xf0106f41
f0101de0:	e8 af e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101de5:	83 ec 04             	sub    $0x4,%esp
f0101de8:	6a 00                	push   $0x0
f0101dea:	68 00 10 00 00       	push   $0x1000
f0101def:	57                   	push   %edi
f0101df0:	e8 23 f3 ff ff       	call   f0101118 <pgdir_walk>
f0101df5:	83 c4 10             	add    $0x10,%esp
f0101df8:	f6 00 04             	testb  $0x4,(%eax)
f0101dfb:	75 19                	jne    f0101e16 <mem_init+0x9b7>
f0101dfd:	68 50 69 10 f0       	push   $0xf0106950
f0101e02:	68 67 6f 10 f0       	push   $0xf0106f67
f0101e07:	68 b0 05 00 00       	push   $0x5b0
f0101e0c:	68 41 6f 10 f0       	push   $0xf0106f41
f0101e11:	e8 7e e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e16:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101e1b:	f6 00 04             	testb  $0x4,(%eax)
f0101e1e:	75 19                	jne    f0101e39 <mem_init+0x9da>
f0101e20:	68 7a 71 10 f0       	push   $0xf010717a
f0101e25:	68 67 6f 10 f0       	push   $0xf0106f67
f0101e2a:	68 b1 05 00 00       	push   $0x5b1
f0101e2f:	68 41 6f 10 f0       	push   $0xf0106f41
f0101e34:	e8 5b e2 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 4th the new line page_insert pp2 PGSIZE with fewer permissions\n\n");
	// should be able to remap with fewer permissions ??
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e39:	6a 02                	push   $0x2
f0101e3b:	68 00 10 00 00       	push   $0x1000
f0101e40:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e43:	50                   	push   %eax
f0101e44:	e8 24 f5 ff ff       	call   f010136d <page_insert>
f0101e49:	83 c4 10             	add    $0x10,%esp
f0101e4c:	85 c0                	test   %eax,%eax
f0101e4e:	74 19                	je     f0101e69 <mem_init+0xa0a>
f0101e50:	68 64 68 10 f0       	push   $0xf0106864
f0101e55:	68 67 6f 10 f0       	push   $0xf0106f67
f0101e5a:	68 b4 05 00 00       	push   $0x5b4
f0101e5f:	68 41 6f 10 f0       	push   $0xf0106f41
f0101e64:	e8 2b e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e69:	83 ec 04             	sub    $0x4,%esp
f0101e6c:	6a 00                	push   $0x0
f0101e6e:	68 00 10 00 00       	push   $0x1000
f0101e73:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101e79:	e8 9a f2 ff ff       	call   f0101118 <pgdir_walk>
f0101e7e:	83 c4 10             	add    $0x10,%esp
f0101e81:	f6 00 02             	testb  $0x2,(%eax)
f0101e84:	75 19                	jne    f0101e9f <mem_init+0xa40>
f0101e86:	68 84 69 10 f0       	push   $0xf0106984
f0101e8b:	68 67 6f 10 f0       	push   $0xf0106f67
f0101e90:	68 b5 05 00 00       	push   $0x5b5
f0101e95:	68 41 6f 10 f0       	push   $0xf0106f41
f0101e9a:	e8 f5 e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e9f:	83 ec 04             	sub    $0x4,%esp
f0101ea2:	6a 00                	push   $0x0
f0101ea4:	68 00 10 00 00       	push   $0x1000
f0101ea9:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101eaf:	e8 64 f2 ff ff       	call   f0101118 <pgdir_walk>
f0101eb4:	83 c4 10             	add    $0x10,%esp
f0101eb7:	f6 00 04             	testb  $0x4,(%eax)
f0101eba:	74 19                	je     f0101ed5 <mem_init+0xa76>
f0101ebc:	68 b8 69 10 f0       	push   $0xf01069b8
f0101ec1:	68 67 6f 10 f0       	push   $0xf0106f67
f0101ec6:	68 b6 05 00 00       	push   $0x5b6
f0101ecb:	68 41 6f 10 f0       	push   $0xf0106f41
f0101ed0:	e8 bf e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
//cprintf("$$ before the page_insert into PTSIZE\n\n");
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ed5:	6a 02                	push   $0x2
f0101ed7:	68 00 00 40 00       	push   $0x400000
f0101edc:	56                   	push   %esi
f0101edd:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101ee3:	e8 85 f4 ff ff       	call   f010136d <page_insert>
f0101ee8:	83 c4 10             	add    $0x10,%esp
f0101eeb:	85 c0                	test   %eax,%eax
f0101eed:	78 19                	js     f0101f08 <mem_init+0xaa9>
f0101eef:	68 f0 69 10 f0       	push   $0xf01069f0
f0101ef4:	68 67 6f 10 f0       	push   $0xf0106f67
f0101ef9:	68 ba 05 00 00       	push   $0x5ba
f0101efe:	68 41 6f 10 f0       	push   $0xf0106f41
f0101f03:	e8 8c e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
//cprintf("$$ before insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f08:	6a 02                	push   $0x2
f0101f0a:	68 00 10 00 00       	push   $0x1000
f0101f0f:	53                   	push   %ebx
f0101f10:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f16:	e8 52 f4 ff ff       	call   f010136d <page_insert>
f0101f1b:	83 c4 10             	add    $0x10,%esp
f0101f1e:	85 c0                	test   %eax,%eax
f0101f20:	74 19                	je     f0101f3b <mem_init+0xadc>
f0101f22:	68 28 6a 10 f0       	push   $0xf0106a28
f0101f27:	68 67 6f 10 f0       	push   $0xf0106f67
f0101f2c:	68 be 05 00 00       	push   $0x5be
f0101f31:	68 41 6f 10 f0       	push   $0xf0106f41
f0101f36:	e8 59 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f3b:	83 ec 04             	sub    $0x4,%esp
f0101f3e:	6a 00                	push   $0x0
f0101f40:	68 00 10 00 00       	push   $0x1000
f0101f45:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f4b:	e8 c8 f1 ff ff       	call   f0101118 <pgdir_walk>
f0101f50:	83 c4 10             	add    $0x10,%esp
f0101f53:	f6 00 04             	testb  $0x4,(%eax)
f0101f56:	74 19                	je     f0101f71 <mem_init+0xb12>
f0101f58:	68 b8 69 10 f0       	push   $0xf01069b8
f0101f5d:	68 67 6f 10 f0       	push   $0xf0106f67
f0101f62:	68 c0 05 00 00       	push   $0x5c0
f0101f67:	68 41 6f 10 f0       	push   $0xf0106f41
f0101f6c:	e8 23 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after checking the (!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U)\n\n");
	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f71:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0101f77:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f7c:	89 f8                	mov    %edi,%eax
f0101f7e:	e8 f9 eb ff ff       	call   f0100b7c <check_va2pa>
f0101f83:	89 c1                	mov    %eax,%ecx
f0101f85:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f88:	89 d8                	mov    %ebx,%eax
f0101f8a:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101f90:	c1 f8 03             	sar    $0x3,%eax
f0101f93:	c1 e0 0c             	shl    $0xc,%eax
f0101f96:	39 c1                	cmp    %eax,%ecx
f0101f98:	74 19                	je     f0101fb3 <mem_init+0xb54>
f0101f9a:	68 64 6a 10 f0       	push   $0xf0106a64
f0101f9f:	68 67 6f 10 f0       	push   $0xf0106f67
f0101fa4:	68 c3 05 00 00       	push   $0x5c3
f0101fa9:	68 41 6f 10 f0       	push   $0xf0106f41
f0101fae:	e8 e1 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fb3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fb8:	89 f8                	mov    %edi,%eax
f0101fba:	e8 bd eb ff ff       	call   f0100b7c <check_va2pa>
f0101fbf:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fc2:	74 19                	je     f0101fdd <mem_init+0xb7e>
f0101fc4:	68 90 6a 10 f0       	push   $0xf0106a90
f0101fc9:	68 67 6f 10 f0       	push   $0xf0106f67
f0101fce:	68 c4 05 00 00       	push   $0x5c4
f0101fd3:	68 41 6f 10 f0       	push   $0xf0106f41
f0101fd8:	e8 b7 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fdd:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fe2:	74 19                	je     f0101ffd <mem_init+0xb9e>
f0101fe4:	68 90 71 10 f0       	push   $0xf0107190
f0101fe9:	68 67 6f 10 f0       	push   $0xf0106f67
f0101fee:	68 c6 05 00 00       	push   $0x5c6
f0101ff3:	68 41 6f 10 f0       	push   $0xf0106f41
f0101ff8:	e8 97 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0101ffd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102000:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102005:	74 19                	je     f0102020 <mem_init+0xbc1>
f0102007:	68 a1 71 10 f0       	push   $0xf01071a1
f010200c:	68 67 6f 10 f0       	push   $0xf0106f67
f0102011:	68 c7 05 00 00       	push   $0x5c7
f0102016:	68 41 6f 10 f0       	push   $0xf0106f41
f010201b:	e8 74 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102020:	83 ec 0c             	sub    $0xc,%esp
f0102023:	6a 00                	push   $0x0
f0102025:	e8 54 ef ff ff       	call   f0100f7e <page_alloc>
f010202a:	83 c4 10             	add    $0x10,%esp
f010202d:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102030:	75 04                	jne    f0102036 <mem_init+0xbd7>
f0102032:	85 c0                	test   %eax,%eax
f0102034:	75 19                	jne    f010204f <mem_init+0xbf0>
f0102036:	68 c0 6a 10 f0       	push   $0xf0106ac0
f010203b:	68 67 6f 10 f0       	push   $0xf0106f67
f0102040:	68 ca 05 00 00       	push   $0x5ca
f0102045:	68 41 6f 10 f0       	push   $0xf0106f41
f010204a:	e8 45 e0 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010204f:	83 ec 08             	sub    $0x8,%esp
f0102052:	6a 00                	push   $0x0
f0102054:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010205a:	e8 c8 f2 ff ff       	call   f0101327 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010205f:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102065:	ba 00 00 00 00       	mov    $0x0,%edx
f010206a:	89 f8                	mov    %edi,%eax
f010206c:	e8 0b eb ff ff       	call   f0100b7c <check_va2pa>
f0102071:	83 c4 10             	add    $0x10,%esp
f0102074:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102077:	74 19                	je     f0102092 <mem_init+0xc33>
f0102079:	68 e4 6a 10 f0       	push   $0xf0106ae4
f010207e:	68 67 6f 10 f0       	push   $0xf0106f67
f0102083:	68 ce 05 00 00       	push   $0x5ce
f0102088:	68 41 6f 10 f0       	push   $0xf0106f41
f010208d:	e8 02 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102092:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102097:	89 f8                	mov    %edi,%eax
f0102099:	e8 de ea ff ff       	call   f0100b7c <check_va2pa>
f010209e:	89 da                	mov    %ebx,%edx
f01020a0:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01020a6:	c1 fa 03             	sar    $0x3,%edx
f01020a9:	c1 e2 0c             	shl    $0xc,%edx
f01020ac:	39 d0                	cmp    %edx,%eax
f01020ae:	74 19                	je     f01020c9 <mem_init+0xc6a>
f01020b0:	68 90 6a 10 f0       	push   $0xf0106a90
f01020b5:	68 67 6f 10 f0       	push   $0xf0106f67
f01020ba:	68 cf 05 00 00       	push   $0x5cf
f01020bf:	68 41 6f 10 f0       	push   $0xf0106f41
f01020c4:	e8 cb df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01020c9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020ce:	74 19                	je     f01020e9 <mem_init+0xc8a>
f01020d0:	68 47 71 10 f0       	push   $0xf0107147
f01020d5:	68 67 6f 10 f0       	push   $0xf0106f67
f01020da:	68 d0 05 00 00       	push   $0x5d0
f01020df:	68 41 6f 10 f0       	push   $0xf0106f41
f01020e4:	e8 ab df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01020e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ec:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01020f1:	74 19                	je     f010210c <mem_init+0xcad>
f01020f3:	68 a1 71 10 f0       	push   $0xf01071a1
f01020f8:	68 67 6f 10 f0       	push   $0xf0106f67
f01020fd:	68 d1 05 00 00       	push   $0x5d1
f0102102:	68 41 6f 10 f0       	push   $0xf0106f41
f0102107:	e8 88 df ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010210c:	6a 00                	push   $0x0
f010210e:	68 00 10 00 00       	push   $0x1000
f0102113:	53                   	push   %ebx
f0102114:	57                   	push   %edi
f0102115:	e8 53 f2 ff ff       	call   f010136d <page_insert>
f010211a:	83 c4 10             	add    $0x10,%esp
f010211d:	85 c0                	test   %eax,%eax
f010211f:	74 19                	je     f010213a <mem_init+0xcdb>
f0102121:	68 08 6b 10 f0       	push   $0xf0106b08
f0102126:	68 67 6f 10 f0       	push   $0xf0106f67
f010212b:	68 d4 05 00 00       	push   $0x5d4
f0102130:	68 41 6f 10 f0       	push   $0xf0106f41
f0102135:	e8 5a df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010213a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010213f:	75 19                	jne    f010215a <mem_init+0xcfb>
f0102141:	68 b2 71 10 f0       	push   $0xf01071b2
f0102146:	68 67 6f 10 f0       	push   $0xf0106f67
f010214b:	68 d5 05 00 00       	push   $0x5d5
f0102150:	68 41 6f 10 f0       	push   $0xf0106f41
f0102155:	e8 3a df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010215a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010215d:	74 19                	je     f0102178 <mem_init+0xd19>
f010215f:	68 be 71 10 f0       	push   $0xf01071be
f0102164:	68 67 6f 10 f0       	push   $0xf0106f67
f0102169:	68 d6 05 00 00       	push   $0x5d6
f010216e:	68 41 6f 10 f0       	push   $0xf0106f41
f0102173:	e8 1c df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102178:	83 ec 08             	sub    $0x8,%esp
f010217b:	68 00 10 00 00       	push   $0x1000
f0102180:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102186:	e8 9c f1 ff ff       	call   f0101327 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010218b:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102191:	ba 00 00 00 00       	mov    $0x0,%edx
f0102196:	89 f8                	mov    %edi,%eax
f0102198:	e8 df e9 ff ff       	call   f0100b7c <check_va2pa>
f010219d:	83 c4 10             	add    $0x10,%esp
f01021a0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021a3:	74 19                	je     f01021be <mem_init+0xd5f>
f01021a5:	68 e4 6a 10 f0       	push   $0xf0106ae4
f01021aa:	68 67 6f 10 f0       	push   $0xf0106f67
f01021af:	68 da 05 00 00       	push   $0x5da
f01021b4:	68 41 6f 10 f0       	push   $0xf0106f41
f01021b9:	e8 d6 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021be:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021c3:	89 f8                	mov    %edi,%eax
f01021c5:	e8 b2 e9 ff ff       	call   f0100b7c <check_va2pa>
f01021ca:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021cd:	74 19                	je     f01021e8 <mem_init+0xd89>
f01021cf:	68 40 6b 10 f0       	push   $0xf0106b40
f01021d4:	68 67 6f 10 f0       	push   $0xf0106f67
f01021d9:	68 db 05 00 00       	push   $0x5db
f01021de:	68 41 6f 10 f0       	push   $0xf0106f41
f01021e3:	e8 ac de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01021e8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021ed:	74 19                	je     f0102208 <mem_init+0xda9>
f01021ef:	68 d3 71 10 f0       	push   $0xf01071d3
f01021f4:	68 67 6f 10 f0       	push   $0xf0106f67
f01021f9:	68 dc 05 00 00       	push   $0x5dc
f01021fe:	68 41 6f 10 f0       	push   $0xf0106f41
f0102203:	e8 8c de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102208:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010220b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102210:	74 19                	je     f010222b <mem_init+0xdcc>
f0102212:	68 a1 71 10 f0       	push   $0xf01071a1
f0102217:	68 67 6f 10 f0       	push   $0xf0106f67
f010221c:	68 dd 05 00 00       	push   $0x5dd
f0102221:	68 41 6f 10 f0       	push   $0xf0106f41
f0102226:	e8 69 de ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010222b:	83 ec 0c             	sub    $0xc,%esp
f010222e:	6a 00                	push   $0x0
f0102230:	e8 49 ed ff ff       	call   f0100f7e <page_alloc>
f0102235:	83 c4 10             	add    $0x10,%esp
f0102238:	85 c0                	test   %eax,%eax
f010223a:	74 04                	je     f0102240 <mem_init+0xde1>
f010223c:	39 c3                	cmp    %eax,%ebx
f010223e:	74 19                	je     f0102259 <mem_init+0xdfa>
f0102240:	68 68 6b 10 f0       	push   $0xf0106b68
f0102245:	68 67 6f 10 f0       	push   $0xf0106f67
f010224a:	68 e0 05 00 00       	push   $0x5e0
f010224f:	68 41 6f 10 f0       	push   $0xf0106f41
f0102254:	e8 3b de ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102259:	83 ec 0c             	sub    $0xc,%esp
f010225c:	6a 00                	push   $0x0
f010225e:	e8 1b ed ff ff       	call   f0100f7e <page_alloc>
f0102263:	83 c4 10             	add    $0x10,%esp
f0102266:	85 c0                	test   %eax,%eax
f0102268:	74 19                	je     f0102283 <mem_init+0xe24>
f010226a:	68 f5 70 10 f0       	push   $0xf01070f5
f010226f:	68 67 6f 10 f0       	push   $0xf0106f67
f0102274:	68 e3 05 00 00       	push   $0x5e3
f0102279:	68 41 6f 10 f0       	push   $0xf0106f41
f010227e:	e8 11 de ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102283:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0102289:	8b 11                	mov    (%ecx),%edx
f010228b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102291:	89 f0                	mov    %esi,%eax
f0102293:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102299:	c1 f8 03             	sar    $0x3,%eax
f010229c:	c1 e0 0c             	shl    $0xc,%eax
f010229f:	39 c2                	cmp    %eax,%edx
f01022a1:	74 19                	je     f01022bc <mem_init+0xe5d>
f01022a3:	68 0c 68 10 f0       	push   $0xf010680c
f01022a8:	68 67 6f 10 f0       	push   $0xf0106f67
f01022ad:	68 e6 05 00 00       	push   $0x5e6
f01022b2:	68 41 6f 10 f0       	push   $0xf0106f41
f01022b7:	e8 d8 dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01022bc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022c2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022c7:	74 19                	je     f01022e2 <mem_init+0xe83>
f01022c9:	68 58 71 10 f0       	push   $0xf0107158
f01022ce:	68 67 6f 10 f0       	push   $0xf0106f67
f01022d3:	68 e8 05 00 00       	push   $0x5e8
f01022d8:	68 41 6f 10 f0       	push   $0xf0106f41
f01022dd:	e8 b2 dd ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01022e2:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022e8:	83 ec 0c             	sub    $0xc,%esp
f01022eb:	56                   	push   %esi
f01022ec:	e8 46 ed ff ff       	call   f0101037 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022f1:	83 c4 0c             	add    $0xc,%esp
f01022f4:	6a 01                	push   $0x1
f01022f6:	68 00 10 40 00       	push   $0x401000
f01022fb:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102301:	e8 12 ee ff ff       	call   f0101118 <pgdir_walk>
f0102306:	89 c7                	mov    %eax,%edi
f0102308:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010230b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102310:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102313:	8b 40 04             	mov    0x4(%eax),%eax
f0102316:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010231b:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0102321:	89 c2                	mov    %eax,%edx
f0102323:	c1 ea 0c             	shr    $0xc,%edx
f0102326:	83 c4 10             	add    $0x10,%esp
f0102329:	39 ca                	cmp    %ecx,%edx
f010232b:	72 15                	jb     f0102342 <mem_init+0xee3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010232d:	50                   	push   %eax
f010232e:	68 08 60 10 f0       	push   $0xf0106008
f0102333:	68 ef 05 00 00       	push   $0x5ef
f0102338:	68 41 6f 10 f0       	push   $0xf0106f41
f010233d:	e8 52 dd ff ff       	call   f0100094 <_panic>
	
//now we fault at ptep == ptep1+PTX(va)
//cprintf("ptep:%x , PTX(va):%x,va:%x,ptep1:%x\n",ptep,PTX(va),va,ptep1);

	assert(ptep == ptep1 + PTX(va));
f0102342:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102347:	39 c7                	cmp    %eax,%edi
f0102349:	74 19                	je     f0102364 <mem_init+0xf05>
f010234b:	68 e4 71 10 f0       	push   $0xf01071e4
f0102350:	68 67 6f 10 f0       	push   $0xf0106f67
f0102355:	68 f4 05 00 00       	push   $0x5f4
f010235a:	68 41 6f 10 f0       	push   $0xf0106f41
f010235f:	e8 30 dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102364:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102367:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010236e:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102374:	89 f0                	mov    %esi,%eax
f0102376:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010237c:	c1 f8 03             	sar    $0x3,%eax
f010237f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102382:	89 c2                	mov    %eax,%edx
f0102384:	c1 ea 0c             	shr    $0xc,%edx
f0102387:	39 d1                	cmp    %edx,%ecx
f0102389:	77 12                	ja     f010239d <mem_init+0xf3e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010238b:	50                   	push   %eax
f010238c:	68 08 60 10 f0       	push   $0xf0106008
f0102391:	6a 58                	push   $0x58
f0102393:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0102398:	e8 f7 dc ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010239d:	83 ec 04             	sub    $0x4,%esp
f01023a0:	68 00 10 00 00       	push   $0x1000
f01023a5:	68 ff 00 00 00       	push   $0xff
f01023aa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023af:	50                   	push   %eax
f01023b0:	e8 d4 2e 00 00       	call   f0105289 <memset>
	page_free(pp0);
f01023b5:	89 34 24             	mov    %esi,(%esp)
f01023b8:	e8 7a ec ff ff       	call   f0101037 <page_free>


//here below is my commit,so if we set all pp0(the page table entry)
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023bd:	83 c4 0c             	add    $0xc,%esp
f01023c0:	6a 01                	push   $0x1
f01023c2:	6a 00                	push   $0x0
f01023c4:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f01023ca:	e8 49 ed ff ff       	call   f0101118 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023cf:	89 f2                	mov    %esi,%edx
f01023d1:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01023d7:	c1 fa 03             	sar    $0x3,%edx
f01023da:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023dd:	89 d0                	mov    %edx,%eax
f01023df:	c1 e8 0c             	shr    $0xc,%eax
f01023e2:	83 c4 10             	add    $0x10,%esp
f01023e5:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01023eb:	72 12                	jb     f01023ff <mem_init+0xfa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023ed:	52                   	push   %edx
f01023ee:	68 08 60 10 f0       	push   $0xf0106008
f01023f3:	6a 58                	push   $0x58
f01023f5:	68 4d 6f 10 f0       	push   $0xf0106f4d
f01023fa:	e8 95 dc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01023ff:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102405:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102408:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	
	for(i=0; i<NPTENTRIES; i++){
		//:/cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
		assert((ptep[i] & PTE_P) == 0);
f010240e:	f6 00 01             	testb  $0x1,(%eax)
f0102411:	74 19                	je     f010242c <mem_init+0xfcd>
f0102413:	68 fc 71 10 f0       	push   $0xf01071fc
f0102418:	68 67 6f 10 f0       	push   $0xf0106f67
f010241d:	68 08 06 00 00       	push   $0x608
f0102422:	68 41 6f 10 f0       	push   $0xf0106f41
f0102427:	e8 68 dc ff ff       	call   f0100094 <_panic>
f010242c:	83 c0 04             	add    $0x4,%eax
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	
	for(i=0; i<NPTENTRIES; i++){
f010242f:	39 d0                	cmp    %edx,%eax
f0102431:	75 db                	jne    f010240e <mem_init+0xfaf>
		assert((ptep[i] & PTE_P) == 0);
	}
//here is the error again.
//	for(i = 0;i<NPTENTRIES;i++)
//		cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
	kern_pgdir[0] = 0;
f0102433:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102438:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010243e:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102444:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102447:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f010244c:	83 ec 0c             	sub    $0xc,%esp
f010244f:	56                   	push   %esi
f0102450:	e8 e2 eb ff ff       	call   f0101037 <page_free>
	page_free(pp1);
f0102455:	89 1c 24             	mov    %ebx,(%esp)
f0102458:	e8 da eb ff ff       	call   f0101037 <page_free>
	page_free(pp2);
f010245d:	83 c4 04             	add    $0x4,%esp
f0102460:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102463:	e8 cf eb ff ff       	call   f0101037 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102468:	83 c4 08             	add    $0x8,%esp
f010246b:	68 01 10 00 00       	push   $0x1001
f0102470:	6a 00                	push   $0x0
f0102472:	e8 82 ef ff ff       	call   f01013f9 <mmio_map_region>
f0102477:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102479:	83 c4 08             	add    $0x8,%esp
f010247c:	68 00 10 00 00       	push   $0x1000
f0102481:	6a 00                	push   $0x0
f0102483:	e8 71 ef ff ff       	call   f01013f9 <mmio_map_region>
f0102488:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010248a:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102490:	83 c4 10             	add    $0x10,%esp
f0102493:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102499:	76 07                	jbe    f01024a2 <mem_init+0x1043>
f010249b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01024a0:	76 19                	jbe    f01024bb <mem_init+0x105c>
f01024a2:	68 8c 6b 10 f0       	push   $0xf0106b8c
f01024a7:	68 67 6f 10 f0       	push   $0xf0106f67
f01024ac:	68 1c 06 00 00       	push   $0x61c
f01024b1:	68 41 6f 10 f0       	push   $0xf0106f41
f01024b6:	e8 d9 db ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01024bb:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024c1:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024c7:	77 08                	ja     f01024d1 <mem_init+0x1072>
f01024c9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024cf:	77 19                	ja     f01024ea <mem_init+0x108b>
f01024d1:	68 b4 6b 10 f0       	push   $0xf0106bb4
f01024d6:	68 67 6f 10 f0       	push   $0xf0106f67
f01024db:	68 1d 06 00 00       	push   $0x61d
f01024e0:	68 41 6f 10 f0       	push   $0xf0106f41
f01024e5:	e8 aa db ff ff       	call   f0100094 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024ea:	89 da                	mov    %ebx,%edx
f01024ec:	09 f2                	or     %esi,%edx
f01024ee:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024f4:	74 19                	je     f010250f <mem_init+0x10b0>
f01024f6:	68 dc 6b 10 f0       	push   $0xf0106bdc
f01024fb:	68 67 6f 10 f0       	push   $0xf0106f67
f0102500:	68 1f 06 00 00       	push   $0x61f
f0102505:	68 41 6f 10 f0       	push   $0xf0106f41
f010250a:	e8 85 db ff ff       	call   f0100094 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f010250f:	39 c6                	cmp    %eax,%esi
f0102511:	73 19                	jae    f010252c <mem_init+0x10cd>
f0102513:	68 13 72 10 f0       	push   $0xf0107213
f0102518:	68 67 6f 10 f0       	push   $0xf0106f67
f010251d:	68 21 06 00 00       	push   $0x621
f0102522:	68 41 6f 10 f0       	push   $0xf0106f41
f0102527:	e8 68 db ff ff       	call   f0100094 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010252c:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102532:	89 da                	mov    %ebx,%edx
f0102534:	89 f8                	mov    %edi,%eax
f0102536:	e8 41 e6 ff ff       	call   f0100b7c <check_va2pa>
f010253b:	85 c0                	test   %eax,%eax
f010253d:	74 19                	je     f0102558 <mem_init+0x10f9>
f010253f:	68 04 6c 10 f0       	push   $0xf0106c04
f0102544:	68 67 6f 10 f0       	push   $0xf0106f67
f0102549:	68 23 06 00 00       	push   $0x623
f010254e:	68 41 6f 10 f0       	push   $0xf0106f41
f0102553:	e8 3c db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102558:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010255e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102561:	89 c2                	mov    %eax,%edx
f0102563:	89 f8                	mov    %edi,%eax
f0102565:	e8 12 e6 ff ff       	call   f0100b7c <check_va2pa>
f010256a:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010256f:	74 19                	je     f010258a <mem_init+0x112b>
f0102571:	68 28 6c 10 f0       	push   $0xf0106c28
f0102576:	68 67 6f 10 f0       	push   $0xf0106f67
f010257b:	68 24 06 00 00       	push   $0x624
f0102580:	68 41 6f 10 f0       	push   $0xf0106f41
f0102585:	e8 0a db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010258a:	89 f2                	mov    %esi,%edx
f010258c:	89 f8                	mov    %edi,%eax
f010258e:	e8 e9 e5 ff ff       	call   f0100b7c <check_va2pa>
f0102593:	85 c0                	test   %eax,%eax
f0102595:	74 19                	je     f01025b0 <mem_init+0x1151>
f0102597:	68 58 6c 10 f0       	push   $0xf0106c58
f010259c:	68 67 6f 10 f0       	push   $0xf0106f67
f01025a1:	68 25 06 00 00       	push   $0x625
f01025a6:	68 41 6f 10 f0       	push   $0xf0106f41
f01025ab:	e8 e4 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025b0:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01025b6:	89 f8                	mov    %edi,%eax
f01025b8:	e8 bf e5 ff ff       	call   f0100b7c <check_va2pa>
f01025bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025c0:	74 19                	je     f01025db <mem_init+0x117c>
f01025c2:	68 7c 6c 10 f0       	push   $0xf0106c7c
f01025c7:	68 67 6f 10 f0       	push   $0xf0106f67
f01025cc:	68 26 06 00 00       	push   $0x626
f01025d1:	68 41 6f 10 f0       	push   $0xf0106f41
f01025d6:	e8 b9 da ff ff       	call   f0100094 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01025db:	83 ec 04             	sub    $0x4,%esp
f01025de:	6a 00                	push   $0x0
f01025e0:	53                   	push   %ebx
f01025e1:	57                   	push   %edi
f01025e2:	e8 31 eb ff ff       	call   f0101118 <pgdir_walk>
f01025e7:	83 c4 10             	add    $0x10,%esp
f01025ea:	f6 00 1a             	testb  $0x1a,(%eax)
f01025ed:	75 19                	jne    f0102608 <mem_init+0x11a9>
f01025ef:	68 a8 6c 10 f0       	push   $0xf0106ca8
f01025f4:	68 67 6f 10 f0       	push   $0xf0106f67
f01025f9:	68 28 06 00 00       	push   $0x628
f01025fe:	68 41 6f 10 f0       	push   $0xf0106f41
f0102603:	e8 8c da ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102608:	83 ec 04             	sub    $0x4,%esp
f010260b:	6a 00                	push   $0x0
f010260d:	53                   	push   %ebx
f010260e:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102614:	e8 ff ea ff ff       	call   f0101118 <pgdir_walk>
f0102619:	8b 00                	mov    (%eax),%eax
f010261b:	83 c4 10             	add    $0x10,%esp
f010261e:	83 e0 04             	and    $0x4,%eax
f0102621:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102624:	74 19                	je     f010263f <mem_init+0x11e0>
f0102626:	68 ec 6c 10 f0       	push   $0xf0106cec
f010262b:	68 67 6f 10 f0       	push   $0xf0106f67
f0102630:	68 29 06 00 00       	push   $0x629
f0102635:	68 41 6f 10 f0       	push   $0xf0106f41
f010263a:	e8 55 da ff ff       	call   f0100094 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010263f:	83 ec 04             	sub    $0x4,%esp
f0102642:	6a 00                	push   $0x0
f0102644:	53                   	push   %ebx
f0102645:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010264b:	e8 c8 ea ff ff       	call   f0101118 <pgdir_walk>
f0102650:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102656:	83 c4 0c             	add    $0xc,%esp
f0102659:	6a 00                	push   $0x0
f010265b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010265e:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102664:	e8 af ea ff ff       	call   f0101118 <pgdir_walk>
f0102669:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010266f:	83 c4 0c             	add    $0xc,%esp
f0102672:	6a 00                	push   $0x0
f0102674:	56                   	push   %esi
f0102675:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010267b:	e8 98 ea ff ff       	call   f0101118 <pgdir_walk>
f0102680:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102686:	c7 04 24 25 72 10 f0 	movl   $0xf0107225,(%esp)
f010268d:	e8 d5 11 00 00       	call   f0103867 <cprintf>
	//I know the meaning of some special 'entry'  and I know the perm is 
	//set to which entry.
	//it is just 4MB to hold the pages so it is perfect we just need
	//one page table,insert to the kern_pgdir.
//here is the new version,npages*4 because one page address occupy 4B?
	boot_map_region(kern_pgdir,UPAGES,0x400000,PADDR(pages),PTE_U|PTE_P|PTE_W);
f0102692:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102697:	83 c4 10             	add    $0x10,%esp
f010269a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010269f:	77 15                	ja     f01026b6 <mem_init+0x1257>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a1:	50                   	push   %eax
f01026a2:	68 2c 60 10 f0       	push   $0xf010602c
f01026a7:	68 06 01 00 00       	push   $0x106
f01026ac:	68 41 6f 10 f0       	push   $0xf0106f41
f01026b1:	e8 de d9 ff ff       	call   f0100094 <_panic>
f01026b6:	83 ec 08             	sub    $0x8,%esp
f01026b9:	6a 07                	push   $0x7
f01026bb:	05 00 00 00 10       	add    $0x10000000,%eax
f01026c0:	50                   	push   %eax
f01026c1:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026c6:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026cb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01026d0:	e8 1c eb ff ff       	call   f01011f1 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Pemissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,NENV*sizeof(struct Env),PADDR(envs),PTE_P|PTE_W|PTE_A|PTE_U);
f01026d5:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026da:	83 c4 10             	add    $0x10,%esp
f01026dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026e2:	77 15                	ja     f01026f9 <mem_init+0x129a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026e4:	50                   	push   %eax
f01026e5:	68 2c 60 10 f0       	push   $0xf010602c
f01026ea:	68 12 01 00 00       	push   $0x112
f01026ef:	68 41 6f 10 f0       	push   $0xf0106f41
f01026f4:	e8 9b d9 ff ff       	call   f0100094 <_panic>
f01026f9:	83 ec 08             	sub    $0x8,%esp
f01026fc:	6a 27                	push   $0x27
f01026fe:	05 00 00 00 10       	add    $0x10000000,%eax
f0102703:	50                   	push   %eax
f0102704:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102709:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010270e:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102713:	e8 d9 ea ff ff       	call   f01011f1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102718:	83 c4 10             	add    $0x10,%esp
f010271b:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102720:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102725:	77 15                	ja     f010273c <mem_init+0x12dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102727:	50                   	push   %eax
f0102728:	68 2c 60 10 f0       	push   $0xf010602c
f010272d:	68 27 01 00 00       	push   $0x127
f0102732:	68 41 6f 10 f0       	push   $0xf0106f41
f0102737:	e8 58 d9 ff ff       	call   f0100094 <_panic>
	//the second seg is 4M-32K size as the guard page.
	//[KSTACKTOP-KSTKSIZE,KSTACKTOP)is mapped in physical address
	//[KSTACKOP-PTSIZE,KSTACKTOP-KSTKSIZE)is not mapped by physical mem
	//so it will cause fault if we access it.(which is the 'back' means)

	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
f010273c:	83 ec 08             	sub    $0x8,%esp
f010273f:	6a 22                	push   $0x22
f0102741:	68 00 60 11 00       	push   $0x116000
f0102746:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010274b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102750:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102755:	e8 97 ea ff ff       	call   f01011f1 <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
f010275a:	83 c4 08             	add    $0x8,%esp
f010275d:	6a 08                	push   $0x8
f010275f:	68 3e 72 10 f0       	push   $0xf010723e
f0102764:	e8 fe 10 00 00       	call   f0103867 <cprintf>
f0102769:	c7 45 c4 00 d0 22 f0 	movl   $0xf022d000,-0x3c(%ebp)
f0102770:	83 c4 10             	add    $0x10,%esp
f0102773:	bb 00 d0 22 f0       	mov    $0xf022d000,%ebx
f0102778:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010277d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102783:	77 15                	ja     f010279a <mem_init+0x133b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102785:	53                   	push   %ebx
f0102786:	68 2c 60 10 f0       	push   $0xf010602c
f010278b:	68 6e 01 00 00       	push   $0x16e
f0102790:	68 41 6f 10 f0       	push   $0xf0106f41
f0102795:	e8 fa d8 ff ff       	call   f0100094 <_panic>
	for(int i = 0;i<NCPU;i++){
		uintptr_t kstacktop_i = KSTACKTOP-(i)*(KSTKSIZE+KSTKGAP);	
		boot_map_region(kern_pgdir,kstacktop_i-KSTKSIZE,KSTKSIZE,PADDR(&percpu_kstacks[i]),PTE_P|PTE_W);
f010279a:	83 ec 08             	sub    $0x8,%esp
f010279d:	6a 03                	push   $0x3
f010279f:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01027a5:	50                   	push   %eax
f01027a6:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027ab:	89 f2                	mov    %esi,%edx
f01027ad:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027b2:	e8 3a ea ff ff       	call   f01011f1 <boot_map_region>
f01027b7:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01027bd:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
	for(int i = 0;i<NCPU;i++){
f01027c3:	83 c4 10             	add    $0x10,%esp
f01027c6:	b8 00 d0 26 f0       	mov    $0xf026d000,%eax
f01027cb:	39 d8                	cmp    %ebx,%eax
f01027cd:	75 ae                	jne    f010277d <mem_init+0x131e>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	
	boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W|PTE_A);	
f01027cf:	83 ec 08             	sub    $0x8,%esp
f01027d2:	6a 22                	push   $0x22
f01027d4:	6a 00                	push   $0x0
f01027d6:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01027db:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027e0:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027e5:	e8 07 ea ff ff       	call   f01011f1 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027ea:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027f0:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f01027f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027f8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01027ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102804:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE){

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102807:	8b 35 90 be 22 f0    	mov    0xf022be90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010280d:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102810:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f0102813:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102818:	eb 55                	jmp    f010286f <mem_init+0x1410>

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010281a:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102820:	89 f8                	mov    %edi,%eax
f0102822:	e8 55 e3 ff ff       	call   f0100b7c <check_va2pa>
f0102827:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010282e:	77 15                	ja     f0102845 <mem_init+0x13e6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102830:	56                   	push   %esi
f0102831:	68 2c 60 10 f0       	push   $0xf010602c
f0102836:	68 fa 04 00 00       	push   $0x4fa
f010283b:	68 41 6f 10 f0       	push   $0xf0106f41
f0102840:	e8 4f d8 ff ff       	call   f0100094 <_panic>
f0102845:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010284c:	39 c2                	cmp    %eax,%edx
f010284e:	74 19                	je     f0102869 <mem_init+0x140a>
f0102850:	68 20 6d 10 f0       	push   $0xf0106d20
f0102855:	68 67 6f 10 f0       	push   $0xf0106f67
f010285a:	68 fa 04 00 00       	push   $0x4fa
f010285f:	68 41 6f 10 f0       	push   $0xf0106f41
f0102864:	e8 2b d8 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f0102869:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010286f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102872:	77 a6                	ja     f010281a <mem_init+0x13bb>

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102874:	8b 35 44 b2 22 f0    	mov    0xf022b244,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010287a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010287d:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102882:	89 da                	mov    %ebx,%edx
f0102884:	89 f8                	mov    %edi,%eax
f0102886:	e8 f1 e2 ff ff       	call   f0100b7c <check_va2pa>
f010288b:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102892:	77 15                	ja     f01028a9 <mem_init+0x144a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102894:	56                   	push   %esi
f0102895:	68 2c 60 10 f0       	push   $0xf010602c
f010289a:	68 00 05 00 00       	push   $0x500
f010289f:	68 41 6f 10 f0       	push   $0xf0106f41
f01028a4:	e8 eb d7 ff ff       	call   f0100094 <_panic>
f01028a9:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01028b0:	39 d0                	cmp    %edx,%eax
f01028b2:	74 19                	je     f01028cd <mem_init+0x146e>
f01028b4:	68 54 6d 10 f0       	push   $0xf0106d54
f01028b9:	68 67 6f 10 f0       	push   $0xf0106f67
f01028be:	68 00 05 00 00       	push   $0x500
f01028c3:	68 41 6f 10 f0       	push   $0xf0106f41
f01028c8:	e8 c7 d7 ff ff       	call   f0100094 <_panic>
f01028cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f01028d3:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028d9:	75 a7                	jne    f0102882 <mem_init+0x1423>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f01028db:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01028de:	c1 e6 0c             	shl    $0xc,%esi
f01028e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028e6:	eb 30                	jmp    f0102918 <mem_init+0x14b9>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028e8:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028ee:	89 f8                	mov    %edi,%eax
f01028f0:	e8 87 e2 ff ff       	call   f0100b7c <check_va2pa>
f01028f5:	39 c3                	cmp    %eax,%ebx
f01028f7:	74 19                	je     f0102912 <mem_init+0x14b3>
f01028f9:	68 88 6d 10 f0       	push   $0xf0106d88
f01028fe:	68 67 6f 10 f0       	push   $0xf0106f67
f0102903:	68 06 05 00 00       	push   $0x506
f0102908:	68 41 6f 10 f0       	push   $0xf0106f41
f010290d:	e8 82 d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0102912:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102918:	39 f3                	cmp    %esi,%ebx
f010291a:	72 cc                	jb     f01028e8 <mem_init+0x1489>
f010291c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102921:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102924:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102927:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010292a:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102930:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102933:	89 c3                	mov    %eax,%ebx
	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102935:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102938:	05 00 80 00 20       	add    $0x20008000,%eax
f010293d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102940:	89 da                	mov    %ebx,%edx
f0102942:	89 f8                	mov    %edi,%eax
f0102944:	e8 33 e2 ff ff       	call   f0100b7c <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102949:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010294f:	77 15                	ja     f0102966 <mem_init+0x1507>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102951:	56                   	push   %esi
f0102952:	68 2c 60 10 f0       	push   $0xf010602c
f0102957:	68 11 05 00 00       	push   $0x511
f010295c:	68 41 6f 10 f0       	push   $0xf0106f41
f0102961:	e8 2e d7 ff ff       	call   f0100094 <_panic>
f0102966:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102969:	8d 94 0b 00 d0 22 f0 	lea    -0xfdd3000(%ebx,%ecx,1),%edx
f0102970:	39 d0                	cmp    %edx,%eax
f0102972:	74 19                	je     f010298d <mem_init+0x152e>
f0102974:	68 b0 6d 10 f0       	push   $0xf0106db0
f0102979:	68 67 6f 10 f0       	push   $0xf0106f67
f010297e:	68 11 05 00 00       	push   $0x511
f0102983:	68 41 6f 10 f0       	push   $0xf0106f41
f0102988:	e8 07 d7 ff ff       	call   f0100094 <_panic>
f010298d:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102993:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102996:	75 a8                	jne    f0102940 <mem_init+0x14e1>
f0102998:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010299b:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01029a1:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01029a4:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029a6:	89 da                	mov    %ebx,%edx
f01029a8:	89 f8                	mov    %edi,%eax
f01029aa:	e8 cd e1 ff ff       	call   f0100b7c <check_va2pa>
f01029af:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029b2:	74 19                	je     f01029cd <mem_init+0x156e>
f01029b4:	68 f8 6d 10 f0       	push   $0xf0106df8
f01029b9:	68 67 6f 10 f0       	push   $0xf0106f67
f01029be:	68 13 05 00 00       	push   $0x513
f01029c3:	68 41 6f 10 f0       	push   $0xf0106f41
f01029c8:	e8 c7 d6 ff ff       	call   f0100094 <_panic>
f01029cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029d3:	39 f3                	cmp    %esi,%ebx
f01029d5:	75 cf                	jne    f01029a6 <mem_init+0x1547>
f01029d7:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01029da:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01029e1:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01029e8:	81 c6 00 80 00 00    	add    $0x8000,%esi

	// check kernel stack

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
f01029ee:	b8 00 d0 26 f0       	mov    $0xf026d000,%eax
f01029f3:	39 f0                	cmp    %esi,%eax
f01029f5:	0f 85 2c ff ff ff    	jne    f0102927 <mem_init+0x14c8>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029fb:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a00:	89 f8                	mov    %edi,%eax
f0102a02:	e8 75 e1 ff ff       	call   f0100b7c <check_va2pa>
f0102a07:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a0a:	74 47                	je     f0102a53 <mem_init+0x15f4>
f0102a0c:	68 1c 6e 10 f0       	push   $0xf0106e1c
f0102a11:	68 67 6f 10 f0       	push   $0xf0106f67
f0102a16:	68 1d 05 00 00       	push   $0x51d
f0102a1b:	68 41 6f 10 f0       	push   $0xf0106f41
f0102a20:	e8 6f d6 ff ff       	call   f0100094 <_panic>


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a25:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a2b:	83 fa 04             	cmp    $0x4,%edx
f0102a2e:	77 28                	ja     f0102a58 <mem_init+0x15f9>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a30:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a34:	0f 85 83 00 00 00    	jne    f0102abd <mem_init+0x165e>
f0102a3a:	68 47 72 10 f0       	push   $0xf0107247
f0102a3f:	68 67 6f 10 f0       	push   $0xf0106f67
f0102a44:	68 28 05 00 00       	push   $0x528
f0102a49:	68 41 6f 10 f0       	push   $0xf0106f41
f0102a4e:	e8 41 d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a53:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a58:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a5d:	76 3f                	jbe    f0102a9e <mem_init+0x163f>
				assert(pgdir[i] & PTE_P);
f0102a5f:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a62:	f6 c2 01             	test   $0x1,%dl
f0102a65:	75 19                	jne    f0102a80 <mem_init+0x1621>
f0102a67:	68 47 72 10 f0       	push   $0xf0107247
f0102a6c:	68 67 6f 10 f0       	push   $0xf0106f67
f0102a71:	68 2c 05 00 00       	push   $0x52c
f0102a76:	68 41 6f 10 f0       	push   $0xf0106f41
f0102a7b:	e8 14 d6 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a80:	f6 c2 02             	test   $0x2,%dl
f0102a83:	75 38                	jne    f0102abd <mem_init+0x165e>
f0102a85:	68 58 72 10 f0       	push   $0xf0107258
f0102a8a:	68 67 6f 10 f0       	push   $0xf0106f67
f0102a8f:	68 2d 05 00 00       	push   $0x52d
f0102a94:	68 41 6f 10 f0       	push   $0xf0106f41
f0102a99:	e8 f6 d5 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a9e:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102aa2:	74 19                	je     f0102abd <mem_init+0x165e>
f0102aa4:	68 69 72 10 f0       	push   $0xf0107269
f0102aa9:	68 67 6f 10 f0       	push   $0xf0106f67
f0102aae:	68 2f 05 00 00       	push   $0x52f
f0102ab3:	68 41 6f 10 f0       	push   $0xf0106f41
f0102ab8:	e8 d7 d5 ff ff       	call   f0100094 <_panic>
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102abd:	83 c0 01             	add    $0x1,%eax
f0102ac0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ac5:	0f 86 5a ff ff ff    	jbe    f0102a25 <mem_init+0x15c6>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102acb:	83 ec 0c             	sub    $0xc,%esp
f0102ace:	68 4c 6e 10 f0       	push   $0xf0106e4c
f0102ad3:	e8 8f 0d 00 00       	call   f0103867 <cprintf>
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.

	lcr3(PADDR(kern_pgdir));
f0102ad8:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102add:	83 c4 10             	add    $0x10,%esp
f0102ae0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ae5:	77 15                	ja     f0102afc <mem_init+0x169d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ae7:	50                   	push   %eax
f0102ae8:	68 2c 60 10 f0       	push   $0xf010602c
f0102aed:	68 43 01 00 00       	push   $0x143
f0102af2:	68 41 6f 10 f0       	push   $0xf0106f41
f0102af7:	e8 98 d5 ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102afc:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b01:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b04:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b09:	e8 d2 e0 ff ff       	call   f0100be0 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b0e:	0f 20 c0             	mov    %cr0,%eax
f0102b11:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b14:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b19:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b1c:	83 ec 0c             	sub    $0xc,%esp
f0102b1f:	6a 00                	push   $0x0
f0102b21:	e8 58 e4 ff ff       	call   f0100f7e <page_alloc>
f0102b26:	89 c3                	mov    %eax,%ebx
f0102b28:	83 c4 10             	add    $0x10,%esp
f0102b2b:	85 c0                	test   %eax,%eax
f0102b2d:	75 19                	jne    f0102b48 <mem_init+0x16e9>
f0102b2f:	68 4a 70 10 f0       	push   $0xf010704a
f0102b34:	68 67 6f 10 f0       	push   $0xf0106f67
f0102b39:	68 3e 06 00 00       	push   $0x63e
f0102b3e:	68 41 6f 10 f0       	push   $0xf0106f41
f0102b43:	e8 4c d5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b48:	83 ec 0c             	sub    $0xc,%esp
f0102b4b:	6a 00                	push   $0x0
f0102b4d:	e8 2c e4 ff ff       	call   f0100f7e <page_alloc>
f0102b52:	89 c7                	mov    %eax,%edi
f0102b54:	83 c4 10             	add    $0x10,%esp
f0102b57:	85 c0                	test   %eax,%eax
f0102b59:	75 19                	jne    f0102b74 <mem_init+0x1715>
f0102b5b:	68 60 70 10 f0       	push   $0xf0107060
f0102b60:	68 67 6f 10 f0       	push   $0xf0106f67
f0102b65:	68 3f 06 00 00       	push   $0x63f
f0102b6a:	68 41 6f 10 f0       	push   $0xf0106f41
f0102b6f:	e8 20 d5 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b74:	83 ec 0c             	sub    $0xc,%esp
f0102b77:	6a 00                	push   $0x0
f0102b79:	e8 00 e4 ff ff       	call   f0100f7e <page_alloc>
f0102b7e:	89 c6                	mov    %eax,%esi
f0102b80:	83 c4 10             	add    $0x10,%esp
f0102b83:	85 c0                	test   %eax,%eax
f0102b85:	75 19                	jne    f0102ba0 <mem_init+0x1741>
f0102b87:	68 76 70 10 f0       	push   $0xf0107076
f0102b8c:	68 67 6f 10 f0       	push   $0xf0106f67
f0102b91:	68 40 06 00 00       	push   $0x640
f0102b96:	68 41 6f 10 f0       	push   $0xf0106f41
f0102b9b:	e8 f4 d4 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102ba0:	83 ec 0c             	sub    $0xc,%esp
f0102ba3:	53                   	push   %ebx
f0102ba4:	e8 8e e4 ff ff       	call   f0101037 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ba9:	89 f8                	mov    %edi,%eax
f0102bab:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102bb1:	c1 f8 03             	sar    $0x3,%eax
f0102bb4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bb7:	89 c2                	mov    %eax,%edx
f0102bb9:	c1 ea 0c             	shr    $0xc,%edx
f0102bbc:	83 c4 10             	add    $0x10,%esp
f0102bbf:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102bc5:	72 12                	jb     f0102bd9 <mem_init+0x177a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bc7:	50                   	push   %eax
f0102bc8:	68 08 60 10 f0       	push   $0xf0106008
f0102bcd:	6a 58                	push   $0x58
f0102bcf:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0102bd4:	e8 bb d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bd9:	83 ec 04             	sub    $0x4,%esp
f0102bdc:	68 00 10 00 00       	push   $0x1000
f0102be1:	6a 01                	push   $0x1
f0102be3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102be8:	50                   	push   %eax
f0102be9:	e8 9b 26 00 00       	call   f0105289 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bee:	89 f0                	mov    %esi,%eax
f0102bf0:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102bf6:	c1 f8 03             	sar    $0x3,%eax
f0102bf9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bfc:	89 c2                	mov    %eax,%edx
f0102bfe:	c1 ea 0c             	shr    $0xc,%edx
f0102c01:	83 c4 10             	add    $0x10,%esp
f0102c04:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102c0a:	72 12                	jb     f0102c1e <mem_init+0x17bf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c0c:	50                   	push   %eax
f0102c0d:	68 08 60 10 f0       	push   $0xf0106008
f0102c12:	6a 58                	push   $0x58
f0102c14:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0102c19:	e8 76 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c1e:	83 ec 04             	sub    $0x4,%esp
f0102c21:	68 00 10 00 00       	push   $0x1000
f0102c26:	6a 02                	push   $0x2
f0102c28:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c2d:	50                   	push   %eax
f0102c2e:	e8 56 26 00 00       	call   f0105289 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c33:	6a 02                	push   $0x2
f0102c35:	68 00 10 00 00       	push   $0x1000
f0102c3a:	57                   	push   %edi
f0102c3b:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102c41:	e8 27 e7 ff ff       	call   f010136d <page_insert>
	assert(pp1->pp_ref == 1);
f0102c46:	83 c4 20             	add    $0x20,%esp
f0102c49:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c4e:	74 19                	je     f0102c69 <mem_init+0x180a>
f0102c50:	68 47 71 10 f0       	push   $0xf0107147
f0102c55:	68 67 6f 10 f0       	push   $0xf0106f67
f0102c5a:	68 45 06 00 00       	push   $0x645
f0102c5f:	68 41 6f 10 f0       	push   $0xf0106f41
f0102c64:	e8 2b d4 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c69:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c70:	01 01 01 
f0102c73:	74 19                	je     f0102c8e <mem_init+0x182f>
f0102c75:	68 6c 6e 10 f0       	push   $0xf0106e6c
f0102c7a:	68 67 6f 10 f0       	push   $0xf0106f67
f0102c7f:	68 46 06 00 00       	push   $0x646
f0102c84:	68 41 6f 10 f0       	push   $0xf0106f41
f0102c89:	e8 06 d4 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c8e:	6a 02                	push   $0x2
f0102c90:	68 00 10 00 00       	push   $0x1000
f0102c95:	56                   	push   %esi
f0102c96:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102c9c:	e8 cc e6 ff ff       	call   f010136d <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ca1:	83 c4 10             	add    $0x10,%esp
f0102ca4:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cab:	02 02 02 
f0102cae:	74 19                	je     f0102cc9 <mem_init+0x186a>
f0102cb0:	68 90 6e 10 f0       	push   $0xf0106e90
f0102cb5:	68 67 6f 10 f0       	push   $0xf0106f67
f0102cba:	68 48 06 00 00       	push   $0x648
f0102cbf:	68 41 6f 10 f0       	push   $0xf0106f41
f0102cc4:	e8 cb d3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102cc9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cce:	74 19                	je     f0102ce9 <mem_init+0x188a>
f0102cd0:	68 69 71 10 f0       	push   $0xf0107169
f0102cd5:	68 67 6f 10 f0       	push   $0xf0106f67
f0102cda:	68 49 06 00 00       	push   $0x649
f0102cdf:	68 41 6f 10 f0       	push   $0xf0106f41
f0102ce4:	e8 ab d3 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102ce9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102cee:	74 19                	je     f0102d09 <mem_init+0x18aa>
f0102cf0:	68 d3 71 10 f0       	push   $0xf01071d3
f0102cf5:	68 67 6f 10 f0       	push   $0xf0106f67
f0102cfa:	68 4a 06 00 00       	push   $0x64a
f0102cff:	68 41 6f 10 f0       	push   $0xf0106f41
f0102d04:	e8 8b d3 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d09:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d10:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d13:	89 f0                	mov    %esi,%eax
f0102d15:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102d1b:	c1 f8 03             	sar    $0x3,%eax
f0102d1e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d21:	89 c2                	mov    %eax,%edx
f0102d23:	c1 ea 0c             	shr    $0xc,%edx
f0102d26:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102d2c:	72 12                	jb     f0102d40 <mem_init+0x18e1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d2e:	50                   	push   %eax
f0102d2f:	68 08 60 10 f0       	push   $0xf0106008
f0102d34:	6a 58                	push   $0x58
f0102d36:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0102d3b:	e8 54 d3 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d40:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d47:	03 03 03 
f0102d4a:	74 19                	je     f0102d65 <mem_init+0x1906>
f0102d4c:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0102d51:	68 67 6f 10 f0       	push   $0xf0106f67
f0102d56:	68 4c 06 00 00       	push   $0x64c
f0102d5b:	68 41 6f 10 f0       	push   $0xf0106f41
f0102d60:	e8 2f d3 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d65:	83 ec 08             	sub    $0x8,%esp
f0102d68:	68 00 10 00 00       	push   $0x1000
f0102d6d:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102d73:	e8 af e5 ff ff       	call   f0101327 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d78:	83 c4 10             	add    $0x10,%esp
f0102d7b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d80:	74 19                	je     f0102d9b <mem_init+0x193c>
f0102d82:	68 a1 71 10 f0       	push   $0xf01071a1
f0102d87:	68 67 6f 10 f0       	push   $0xf0106f67
f0102d8c:	68 4e 06 00 00       	push   $0x64e
f0102d91:	68 41 6f 10 f0       	push   $0xf0106f41
f0102d96:	e8 f9 d2 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d9b:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0102da1:	8b 11                	mov    (%ecx),%edx
f0102da3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102da9:	89 d8                	mov    %ebx,%eax
f0102dab:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102db1:	c1 f8 03             	sar    $0x3,%eax
f0102db4:	c1 e0 0c             	shl    $0xc,%eax
f0102db7:	39 c2                	cmp    %eax,%edx
f0102db9:	74 19                	je     f0102dd4 <mem_init+0x1975>
f0102dbb:	68 0c 68 10 f0       	push   $0xf010680c
f0102dc0:	68 67 6f 10 f0       	push   $0xf0106f67
f0102dc5:	68 51 06 00 00       	push   $0x651
f0102dca:	68 41 6f 10 f0       	push   $0xf0106f41
f0102dcf:	e8 c0 d2 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102dd4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102dda:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ddf:	74 19                	je     f0102dfa <mem_init+0x199b>
f0102de1:	68 58 71 10 f0       	push   $0xf0107158
f0102de6:	68 67 6f 10 f0       	push   $0xf0106f67
f0102deb:	68 53 06 00 00       	push   $0x653
f0102df0:	68 41 6f 10 f0       	push   $0xf0106f41
f0102df5:	e8 9a d2 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102dfa:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e00:	83 ec 0c             	sub    $0xc,%esp
f0102e03:	53                   	push   %ebx
f0102e04:	e8 2e e2 ff ff       	call   f0101037 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e09:	c7 04 24 e0 6e 10 f0 	movl   $0xf0106ee0,(%esp)
f0102e10:	e8 52 0a 00 00       	call   f0103867 <cprintf>
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
	//cprintf("here I put out the tag.\n");
}
f0102e15:	83 c4 10             	add    $0x10,%esp
f0102e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e1b:	5b                   	pop    %ebx
f0102e1c:	5e                   	pop    %esi
f0102e1d:	5f                   	pop    %edi
f0102e1e:	5d                   	pop    %ebp
f0102e1f:	c3                   	ret    

f0102e20 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e20:	55                   	push   %ebp
f0102e21:	89 e5                	mov    %esp,%ebp
f0102e23:	57                   	push   %edi
f0102e24:	56                   	push   %esi
f0102e25:	53                   	push   %ebx
f0102e26:	83 ec 1c             	sub    $0x1c,%esp
f0102e29:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e2c:	8b 75 14             	mov    0x14(%ebp),%esi
	//the code is very bad written by myself.
	*/


	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102e2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e32:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102e38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e3b:	03 45 10             	add    0x10(%ebp),%eax
f0102e3e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102e43:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e48:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102e4b:	eb 43                	jmp    f0102e90 <user_mem_check+0x70>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102e4d:	83 ec 04             	sub    $0x4,%esp
f0102e50:	6a 00                	push   $0x0
f0102e52:	53                   	push   %ebx
f0102e53:	ff 77 60             	pushl  0x60(%edi)
f0102e56:	e8 bd e2 ff ff       	call   f0101118 <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102e5b:	83 c4 10             	add    $0x10,%esp
f0102e5e:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e64:	77 10                	ja     f0102e76 <user_mem_check+0x56>
f0102e66:	85 c0                	test   %eax,%eax
f0102e68:	74 0c                	je     f0102e76 <user_mem_check+0x56>
f0102e6a:	8b 00                	mov    (%eax),%eax
f0102e6c:	a8 01                	test   $0x1,%al
f0102e6e:	74 06                	je     f0102e76 <user_mem_check+0x56>
f0102e70:	21 f0                	and    %esi,%eax
f0102e72:	39 c6                	cmp    %eax,%esi
f0102e74:	74 14                	je     f0102e8a <user_mem_check+0x6a>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102e76:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e79:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102e7d:	89 1d 3c b2 22 f0    	mov    %ebx,0xf022b23c
			return -E_FAULT;
f0102e83:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e88:	eb 10                	jmp    f0102e9a <user_mem_check+0x7a>

	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102e8a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e90:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e93:	72 b8                	jb     f0102e4d <user_mem_check+0x2d>
			return -E_FAULT;
		}
	}

//	cprintf("user_mem_check success va: %x, len: %x\n", va, len);	
	return 0;
f0102e95:	b8 00 00 00 00       	mov    $0x0,%eax


}
f0102e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e9d:	5b                   	pop    %ebx
f0102e9e:	5e                   	pop    %esi
f0102e9f:	5f                   	pop    %edi
f0102ea0:	5d                   	pop    %ebp
f0102ea1:	c3                   	ret    

f0102ea2 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102ea2:	55                   	push   %ebp
f0102ea3:	89 e5                	mov    %esp,%ebp
f0102ea5:	53                   	push   %ebx
f0102ea6:	83 ec 04             	sub    $0x4,%esp
f0102ea9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102eac:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eaf:	83 c8 04             	or     $0x4,%eax
f0102eb2:	50                   	push   %eax
f0102eb3:	ff 75 10             	pushl  0x10(%ebp)
f0102eb6:	ff 75 0c             	pushl  0xc(%ebp)
f0102eb9:	53                   	push   %ebx
f0102eba:	e8 61 ff ff ff       	call   f0102e20 <user_mem_check>
f0102ebf:	83 c4 10             	add    $0x10,%esp
f0102ec2:	85 c0                	test   %eax,%eax
f0102ec4:	79 21                	jns    f0102ee7 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102ec6:	83 ec 04             	sub    $0x4,%esp
f0102ec9:	ff 35 3c b2 22 f0    	pushl  0xf022b23c
f0102ecf:	ff 73 48             	pushl  0x48(%ebx)
f0102ed2:	68 0c 6f 10 f0       	push   $0xf0106f0c
f0102ed7:	e8 8b 09 00 00       	call   f0103867 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102edc:	89 1c 24             	mov    %ebx,(%esp)
f0102edf:	e8 c6 06 00 00       	call   f01035aa <env_destroy>
f0102ee4:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ee7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102eea:	c9                   	leave  
f0102eeb:	c3                   	ret    

f0102eec <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102eec:	55                   	push   %ebp
f0102eed:	89 e5                	mov    %esp,%ebp
f0102eef:	57                   	push   %edi
f0102ef0:	56                   	push   %esi
f0102ef1:	53                   	push   %ebx
f0102ef2:	83 ec 0c             	sub    $0xc,%esp
f0102ef5:	89 c7                	mov    %eax,%edi
		va+=PGSIZE;
	}
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
f0102ef7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102efd:	89 d6                	mov    %edx,%esi
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
f0102eff:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0102f05:	25 ff 0f 00 00       	and    $0xfff,%eax
f0102f0a:	8d 99 ff 1f 00 00    	lea    0x1fff(%ecx),%ebx
f0102f10:	29 c3                	sub    %eax,%ebx
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f12:	eb 5e                	jmp    f0102f72 <region_alloc+0x86>
	{
		pp = page_alloc(0);
f0102f14:	83 ec 0c             	sub    $0xc,%esp
f0102f17:	6a 00                	push   $0x0
f0102f19:	e8 60 e0 ff ff       	call   f0100f7e <page_alloc>
 
		if(!pp)
f0102f1e:	83 c4 10             	add    $0x10,%esp
f0102f21:	85 c0                	test   %eax,%eax
f0102f23:	75 17                	jne    f0102f3c <region_alloc+0x50>
		{
			panic("region_alloc failed!\n");
f0102f25:	83 ec 04             	sub    $0x4,%esp
f0102f28:	68 77 72 10 f0       	push   $0xf0107277
f0102f2d:	68 51 01 00 00       	push   $0x151
f0102f32:	68 8d 72 10 f0       	push   $0xf010728d
f0102f37:	e8 58 d1 ff ff       	call   f0100094 <_panic>
		}
		ret = page_insert(e->env_pgdir,pp,va,PTE_U|PTE_W|PTE_P);
f0102f3c:	6a 07                	push   $0x7
f0102f3e:	56                   	push   %esi
f0102f3f:	50                   	push   %eax
f0102f40:	ff 77 60             	pushl  0x60(%edi)
f0102f43:	e8 25 e4 ff ff       	call   f010136d <page_insert>
 
		if(ret)
f0102f48:	83 c4 10             	add    $0x10,%esp
f0102f4b:	85 c0                	test   %eax,%eax
f0102f4d:	74 17                	je     f0102f66 <region_alloc+0x7a>
		{
			panic("region_alloc failed!\n");
f0102f4f:	83 ec 04             	sub    $0x4,%esp
f0102f52:	68 77 72 10 f0       	push   $0xf0107277
f0102f57:	68 57 01 00 00       	push   $0x157
f0102f5c:	68 8d 72 10 f0       	push   $0xf010728d
f0102f61:	e8 2e d1 ff ff       	call   f0100094 <_panic>
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f66:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
f0102f6c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f72:	85 db                	test   %ebx,%ebx
f0102f74:	75 9e                	jne    f0102f14 <region_alloc+0x28>
			panic("region_alloc failed!\n");
		}
	}


}
f0102f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f79:	5b                   	pop    %ebx
f0102f7a:	5e                   	pop    %esi
f0102f7b:	5f                   	pop    %edi
f0102f7c:	5d                   	pop    %ebp
f0102f7d:	c3                   	ret    

f0102f7e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f7e:	55                   	push   %ebp
f0102f7f:	89 e5                	mov    %esp,%ebp
f0102f81:	56                   	push   %esi
f0102f82:	53                   	push   %ebx
f0102f83:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f86:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f89:	85 c0                	test   %eax,%eax
f0102f8b:	75 1d                	jne    f0102faa <envid2env+0x2c>
		*env_store = curenv;
f0102f8d:	e8 18 29 00 00       	call   f01058aa <cpunum>
f0102f92:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f95:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0102f9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f9e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102fa0:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fa5:	e9 84 00 00 00       	jmp    f010302e <envid2env+0xb0>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102faa:	89 c3                	mov    %eax,%ebx
f0102fac:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fb2:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fb5:	03 1d 44 b2 22 f0    	add    0xf022b244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fbb:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102fbf:	74 05                	je     f0102fc6 <envid2env+0x48>
f0102fc1:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102fc4:	74 24                	je     f0102fea <envid2env+0x6c>
		cprintf("we are at e->env_id:%d == envid:%d\n",e->env_id,envid);
f0102fc6:	83 ec 04             	sub    $0x4,%esp
f0102fc9:	50                   	push   %eax
f0102fca:	ff 73 48             	pushl  0x48(%ebx)
f0102fcd:	68 10 73 10 f0       	push   $0xf0107310
f0102fd2:	e8 90 08 00 00       	call   f0103867 <cprintf>
		*env_store = 0;
f0102fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fe0:	83 c4 10             	add    $0x10,%esp
f0102fe3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fe8:	eb 44                	jmp    f010302e <envid2env+0xb0>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fea:	84 d2                	test   %dl,%dl
f0102fec:	74 36                	je     f0103024 <envid2env+0xa6>
f0102fee:	e8 b7 28 00 00       	call   f01058aa <cpunum>
f0102ff3:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ff6:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f0102ffc:	74 26                	je     f0103024 <envid2env+0xa6>
f0102ffe:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103001:	e8 a4 28 00 00       	call   f01058aa <cpunum>
f0103006:	6b c0 74             	imul   $0x74,%eax,%eax
f0103009:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010300f:	3b 70 48             	cmp    0x48(%eax),%esi
f0103012:	74 10                	je     f0103024 <envid2env+0xa6>
		*env_store = 0;
f0103014:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103017:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010301d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103022:	eb 0a                	jmp    f010302e <envid2env+0xb0>
	}

	*env_store = e;
f0103024:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103027:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103029:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010302e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103031:	5b                   	pop    %ebx
f0103032:	5e                   	pop    %esi
f0103033:	5d                   	pop    %ebp
f0103034:	c3                   	ret    

f0103035 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103035:	55                   	push   %ebp
f0103036:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103038:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f010303d:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103040:	b8 23 00 00 00       	mov    $0x23,%eax
f0103045:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103047:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103049:	b8 10 00 00 00       	mov    $0x10,%eax
f010304e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103050:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103052:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103054:	ea 5b 30 10 f0 08 00 	ljmp   $0x8,$0xf010305b
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010305b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103060:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103063:	5d                   	pop    %ebp
f0103064:	c3                   	ret    

f0103065 <env_init>:
};
*/

void
env_init(void)
{
f0103065:	55                   	push   %ebp
f0103066:	89 e5                	mov    %esp,%ebp
f0103068:	56                   	push   %esi
f0103069:	53                   	push   %ebx
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
	{
		envs[temp].env_id = 0;
f010306a:	8b 35 44 b2 22 f0    	mov    0xf022b244,%esi
f0103070:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103076:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103079:	ba 00 00 00 00       	mov    $0x0,%edx
f010307e:	89 c1                	mov    %eax,%ecx
f0103080:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[temp].env_parent_id = 0;
f0103087:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		envs[temp].env_type = ENV_TYPE_USER;
f010308e:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		envs[temp].env_status = 0;
f0103095:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[temp].env_runs = 0;
f010309c:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
		envs[temp].env_pgdir = NULL;
f01030a3:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
		envs[temp].env_link = env_free_list;
f01030aa:	89 50 44             	mov    %edx,0x44(%eax)
f01030ad:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[temp];
f01030b0:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
f01030b2:	39 d8                	cmp    %ebx,%eax
f01030b4:	75 c8                	jne    f010307e <env_init+0x19>
f01030b6:	89 35 48 b2 22 f0    	mov    %esi,0xf022b248
		envs[temp].env_pgdir = NULL;
		envs[temp].env_link = env_free_list;
		env_free_list = &envs[temp];
	}
 
	cprintf("env_free_list : 0x%08x, &envs[temp]: 0x%08x\n",env_free_list,&envs[temp]);
f01030bc:	83 ec 04             	sub    $0x4,%esp
f01030bf:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01030c4:	83 e8 7c             	sub    $0x7c,%eax
f01030c7:	50                   	push   %eax
f01030c8:	56                   	push   %esi
f01030c9:	68 34 73 10 f0       	push   $0xf0107334
f01030ce:	e8 94 07 00 00       	call   f0103867 <cprintf>
 

	// Per-CPU part of the initialization
	env_init_percpu();
f01030d3:	e8 5d ff ff ff       	call   f0103035 <env_init_percpu>
}
f01030d8:	83 c4 10             	add    $0x10,%esp
f01030db:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030de:	5b                   	pop    %ebx
f01030df:	5e                   	pop    %esi
f01030e0:	5d                   	pop    %ebp
f01030e1:	c3                   	ret    

f01030e2 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030e2:	55                   	push   %ebp
f01030e3:	89 e5                	mov    %esp,%ebp
f01030e5:	57                   	push   %edi
f01030e6:	56                   	push   %esi
f01030e7:	53                   	push   %ebx
f01030e8:	83 ec 0c             	sub    $0xc,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01030eb:	8b 1d 48 b2 22 f0    	mov    0xf022b248,%ebx
f01030f1:	85 db                	test   %ebx,%ebx
f01030f3:	0f 84 5d 01 00 00    	je     f0103256 <env_alloc+0x174>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01030f9:	83 ec 0c             	sub    $0xc,%esp
f01030fc:	6a 01                	push   $0x1
f01030fe:	e8 7b de ff ff       	call   f0100f7e <page_alloc>
f0103103:	83 c4 10             	add    $0x10,%esp
f0103106:	85 c0                	test   %eax,%eax
f0103108:	0f 84 4f 01 00 00    	je     f010325d <env_alloc+0x17b>

	
	// LAB 3: Your code here.

	//!copy from web ,just to know how it runs.
	(p->pp_ref)++;
f010310e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103113:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103119:	89 c6                	mov    %eax,%esi
f010311b:	c1 fe 03             	sar    $0x3,%esi
f010311e:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103121:	89 f0                	mov    %esi,%eax
f0103123:	c1 e8 0c             	shr    $0xc,%eax
f0103126:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f010312c:	72 12                	jb     f0103140 <env_alloc+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010312e:	56                   	push   %esi
f010312f:	68 08 60 10 f0       	push   $0xf0106008
f0103134:	6a 58                	push   $0x58
f0103136:	68 4d 6f 10 f0       	push   $0xf0106f4d
f010313b:	e8 54 cf ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0103140:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
        pde_t* page_dir = page2kva(p);
	memcpy(page_dir,kern_pgdir,PGSIZE);
f0103146:	83 ec 04             	sub    $0x4,%esp
f0103149:	68 00 10 00 00       	push   $0x1000
f010314e:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0103154:	57                   	push   %edi
f0103155:	e8 e4 21 00 00       	call   f010533e <memcpy>
	e->env_pgdir = page_dir;
f010315a:	89 7b 60             	mov    %edi,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010315d:	83 c4 10             	add    $0x10,%esp
f0103160:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0103166:	77 15                	ja     f010317d <env_alloc+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103168:	57                   	push   %edi
f0103169:	68 2c 60 10 f0       	push   $0xf010602c
f010316e:	68 e5 00 00 00       	push   $0xe5
f0103173:	68 8d 72 10 f0       	push   $0xf010728d
f0103178:	e8 17 cf ff ff       	call   f0100094 <_panic>
	
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010317d:	83 ce 05             	or     $0x5,%esi
f0103180:	89 b7 f4 0e 00 00    	mov    %esi,0xef4(%edi)

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103186:	8b 43 48             	mov    0x48(%ebx),%eax
f0103189:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010318e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103193:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103198:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010319b:	89 da                	mov    %ebx,%edx
f010319d:	2b 15 44 b2 22 f0    	sub    0xf022b244,%edx
f01031a3:	c1 fa 02             	sar    $0x2,%edx
f01031a6:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031ac:	09 d0                	or     %edx,%eax
f01031ae:	89 43 48             	mov    %eax,0x48(%ebx)
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031b4:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031b7:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031be:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031c5:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031cc:	83 ec 04             	sub    $0x4,%esp
f01031cf:	6a 44                	push   $0x44
f01031d1:	6a 00                	push   $0x0
f01031d3:	53                   	push   %ebx
f01031d4:	e8 b0 20 00 00       	call   f0105289 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031d9:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031df:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031e5:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031eb:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01031f2:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01031f8:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01031ff:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103203:	8b 43 44             	mov    0x44(%ebx),%eax
f0103206:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	*newenv_store = e;
f010320b:	8b 45 08             	mov    0x8(%ebp),%eax
f010320e:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103210:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103213:	e8 92 26 00 00       	call   f01058aa <cpunum>
f0103218:	6b c0 74             	imul   $0x74,%eax,%eax
f010321b:	83 c4 10             	add    $0x10,%esp
f010321e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103223:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010322a:	74 11                	je     f010323d <env_alloc+0x15b>
f010322c:	e8 79 26 00 00       	call   f01058aa <cpunum>
f0103231:	6b c0 74             	imul   $0x74,%eax,%eax
f0103234:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010323a:	8b 50 48             	mov    0x48(%eax),%edx
f010323d:	83 ec 04             	sub    $0x4,%esp
f0103240:	53                   	push   %ebx
f0103241:	52                   	push   %edx
f0103242:	68 98 72 10 f0       	push   $0xf0107298
f0103247:	e8 1b 06 00 00       	call   f0103867 <cprintf>
	return 0;
f010324c:	83 c4 10             	add    $0x10,%esp
f010324f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103254:	eb 0c                	jmp    f0103262 <env_alloc+0x180>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103256:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010325b:	eb 05                	jmp    f0103262 <env_alloc+0x180>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010325d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// commit the allocation
	env_free_list = e->env_link;
	*newenv_store = e;
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103262:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103265:	5b                   	pop    %ebx
f0103266:	5e                   	pop    %esi
f0103267:	5f                   	pop    %edi
f0103268:	5d                   	pop    %ebp
f0103269:	c3                   	ret    

f010326a <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010326a:	55                   	push   %ebp
f010326b:	89 e5                	mov    %esp,%ebp
f010326d:	57                   	push   %edi
f010326e:	56                   	push   %esi
f010326f:	53                   	push   %ebx
f0103270:	83 ec 34             	sub    $0x34,%esp
f0103273:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	int ret = 0;
	struct Env * e = NULL;	
f0103276:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	

	ret = env_alloc(&e,0);
f010327d:	6a 00                	push   $0x0
f010327f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103282:	50                   	push   %eax
f0103283:	e8 5a fe ff ff       	call   f01030e2 <env_alloc>
	//panic("panic at env_alloc().\n");
	if(ret < 0){
f0103288:	83 c4 10             	add    $0x10,%esp
f010328b:	85 c0                	test   %eax,%eax
f010328d:	79 15                	jns    f01032a4 <env_create+0x3a>
		panic("env_create:%e\n",ret);
f010328f:	50                   	push   %eax
f0103290:	68 ad 72 10 f0       	push   $0xf01072ad
f0103295:	68 cf 01 00 00       	push   $0x1cf
f010329a:	68 8d 72 10 f0       	push   $0xf010728d
f010329f:	e8 f0 cd ff ff       	call   f0100094 <_panic>
	}
	load_icode(e,binary);
f01032a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Proghdr *ph,*eph;
	struct Elf * ELFHDR = ((struct Elf*)binary);
	
	if(ELFHDR->e_magic != ELF_MAGIC){
f01032aa:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032b0:	74 17                	je     f01032c9 <env_create+0x5f>
		panic("This is not a valid file.\n");
f01032b2:	83 ec 04             	sub    $0x4,%esp
f01032b5:	68 bc 72 10 f0       	push   $0xf01072bc
f01032ba:	68 98 01 00 00       	push   $0x198
f01032bf:	68 8d 72 10 f0       	push   $0xf010728d
f01032c4:	e8 cb cd ff ff       	call   f0100094 <_panic>
	}
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
f01032c9:	89 fb                	mov    %edi,%ebx
f01032cb:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph+ELFHDR->e_phnum;
f01032ce:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032d2:	c1 e6 05             	shl    $0x5,%esi
f01032d5:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f01032d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032da:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032dd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e2:	77 15                	ja     f01032f9 <env_create+0x8f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e4:	50                   	push   %eax
f01032e5:	68 2c 60 10 f0       	push   $0xf010602c
f01032ea:	68 9d 01 00 00       	push   $0x19d
f01032ef:	68 8d 72 10 f0       	push   $0xf010728d
f01032f4:	e8 9b cd ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01032f9:	05 00 00 00 10       	add    $0x10000000,%eax
f01032fe:	0f 22 d8             	mov    %eax,%cr3
f0103301:	eb 60                	jmp    f0103363 <env_create+0xf9>

	for(;ph<eph;ph++){

		if(ph->p_type != ELF_PROG_LOAD)
f0103303:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103306:	75 58                	jne    f0103360 <env_create+0xf6>
		{
			continue;
		}
 
		if(ph->p_filesz > ph->p_memsz)
f0103308:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010330b:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f010330e:	76 17                	jbe    f0103327 <env_create+0xbd>
		{
			panic("file size is great than memory size\n");
f0103310:	83 ec 04             	sub    $0x4,%esp
f0103313:	68 64 73 10 f0       	push   $0xf0107364
f0103318:	68 a8 01 00 00       	push   $0x1a8
f010331d:	68 8d 72 10 f0       	push   $0xf010728d
f0103322:	e8 6d cd ff ff       	call   f0100094 <_panic>
		}
		//cprintf("ph->p_memsz:0x%x\n",ph->p_memsz); 
		region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f0103327:	8b 53 08             	mov    0x8(%ebx),%edx
f010332a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010332d:	e8 ba fb ff ff       	call   f0102eec <region_alloc>
		//cprintf("DES:0x%x,SRC:0x%x\n",ph->p_va,binary+ph->p_offset);
		//cprintf("ph->filesz:0x%x\n",ph->p_filesz);
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f0103332:	83 ec 04             	sub    $0x4,%esp
f0103335:	ff 73 10             	pushl  0x10(%ebx)
f0103338:	89 f8                	mov    %edi,%eax
f010333a:	03 43 04             	add    0x4(%ebx),%eax
f010333d:	50                   	push   %eax
f010333e:	ff 73 08             	pushl  0x8(%ebx)
f0103341:	e8 90 1f 00 00       	call   f01052d6 <memmove>
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
f0103346:	8b 43 10             	mov    0x10(%ebx),%eax
f0103349:	83 c4 0c             	add    $0xc,%esp
f010334c:	8b 53 14             	mov    0x14(%ebx),%edx
f010334f:	29 c2                	sub    %eax,%edx
f0103351:	52                   	push   %edx
f0103352:	6a 00                	push   $0x0
f0103354:	03 43 08             	add    0x8(%ebx),%eax
f0103357:	50                   	push   %eax
f0103358:	e8 2c 1f 00 00       	call   f0105289 <memset>
f010335d:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
	eph = ph+ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	for(;ph<eph;ph++){
f0103360:	83 c3 20             	add    $0x20,%ebx
f0103363:	39 de                	cmp    %ebx,%esi
f0103365:	77 9c                	ja     f0103303 <env_create+0x99>
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
	}


	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103367:	8b 47 18             	mov    0x18(%edi),%eax
f010336a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010336d:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	lcr3(PADDR(kern_pgdir));
f0103370:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103375:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010337a:	77 15                	ja     f0103391 <env_create+0x127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010337c:	50                   	push   %eax
f010337d:	68 2c 60 10 f0       	push   $0xf010602c
f0103382:	68 b7 01 00 00       	push   $0x1b7
f0103387:	68 8d 72 10 f0       	push   $0xf010728d
f010338c:	e8 03 cd ff ff       	call   f0100094 <_panic>
f0103391:	05 00 00 00 10       	add    $0x10000000,%eax
f0103396:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e,(void *)USTACKTOP-PGSIZE,(size_t)PGSIZE);	
f0103399:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010339e:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033a6:	e8 41 fb ff ff       	call   f0102eec <region_alloc>
	if(ret < 0){
		panic("env_create:%e\n",ret);
	}
	load_icode(e,binary);
	//panic("panic in the load_icode.\n");
	e->env_type = type;
f01033ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033ae:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033b1:	89 50 50             	mov    %edx,0x50(%eax)
	cprintf("THE e->env_id is:%d\n",e->env_id);
f01033b4:	83 ec 08             	sub    $0x8,%esp
f01033b7:	ff 70 48             	pushl  0x48(%eax)
f01033ba:	68 d7 72 10 f0       	push   $0xf01072d7
f01033bf:	e8 a3 04 00 00       	call   f0103867 <cprintf>
}
f01033c4:	83 c4 10             	add    $0x10,%esp
f01033c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ca:	5b                   	pop    %ebx
f01033cb:	5e                   	pop    %esi
f01033cc:	5f                   	pop    %edi
f01033cd:	5d                   	pop    %ebp
f01033ce:	c3                   	ret    

f01033cf <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033cf:	55                   	push   %ebp
f01033d0:	89 e5                	mov    %esp,%ebp
f01033d2:	57                   	push   %edi
f01033d3:	56                   	push   %esi
f01033d4:	53                   	push   %ebx
f01033d5:	83 ec 1c             	sub    $0x1c,%esp
f01033d8:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033db:	e8 ca 24 00 00       	call   f01058aa <cpunum>
f01033e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e3:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f01033e9:	75 29                	jne    f0103414 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01033eb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f5:	77 15                	ja     f010340c <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f7:	50                   	push   %eax
f01033f8:	68 2c 60 10 f0       	push   $0xf010602c
f01033fd:	68 e5 01 00 00       	push   $0x1e5
f0103402:	68 8d 72 10 f0       	push   $0xf010728d
f0103407:	e8 88 cc ff ff       	call   f0100094 <_panic>
f010340c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103411:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103414:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103417:	e8 8e 24 00 00       	call   f01058aa <cpunum>
f010341c:	6b c0 74             	imul   $0x74,%eax,%eax
f010341f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103424:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010342b:	74 11                	je     f010343e <env_free+0x6f>
f010342d:	e8 78 24 00 00       	call   f01058aa <cpunum>
f0103432:	6b c0 74             	imul   $0x74,%eax,%eax
f0103435:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010343b:	8b 50 48             	mov    0x48(%eax),%edx
f010343e:	83 ec 04             	sub    $0x4,%esp
f0103441:	53                   	push   %ebx
f0103442:	52                   	push   %edx
f0103443:	68 ec 72 10 f0       	push   $0xf01072ec
f0103448:	e8 1a 04 00 00       	call   f0103867 <cprintf>
f010344d:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103450:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103457:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010345a:	89 d0                	mov    %edx,%eax
f010345c:	c1 e0 02             	shl    $0x2,%eax
f010345f:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103462:	8b 47 60             	mov    0x60(%edi),%eax
f0103465:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103468:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010346e:	0f 84 a8 00 00 00    	je     f010351c <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103474:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010347a:	89 f0                	mov    %esi,%eax
f010347c:	c1 e8 0c             	shr    $0xc,%eax
f010347f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103482:	39 05 88 be 22 f0    	cmp    %eax,0xf022be88
f0103488:	77 15                	ja     f010349f <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010348a:	56                   	push   %esi
f010348b:	68 08 60 10 f0       	push   $0xf0106008
f0103490:	68 f4 01 00 00       	push   $0x1f4
f0103495:	68 8d 72 10 f0       	push   $0xf010728d
f010349a:	e8 f5 cb ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010349f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034a2:	c1 e0 16             	shl    $0x16,%eax
f01034a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034a8:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034ad:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034b4:	01 
f01034b5:	74 17                	je     f01034ce <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034b7:	83 ec 08             	sub    $0x8,%esp
f01034ba:	89 d8                	mov    %ebx,%eax
f01034bc:	c1 e0 0c             	shl    $0xc,%eax
f01034bf:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034c2:	50                   	push   %eax
f01034c3:	ff 77 60             	pushl  0x60(%edi)
f01034c6:	e8 5c de ff ff       	call   f0101327 <page_remove>
f01034cb:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034ce:	83 c3 01             	add    $0x1,%ebx
f01034d1:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034d7:	75 d4                	jne    f01034ad <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034d9:	8b 47 60             	mov    0x60(%edi),%eax
f01034dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034df:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034e9:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01034ef:	72 14                	jb     f0103505 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01034f1:	83 ec 04             	sub    $0x4,%esp
f01034f4:	68 d8 66 10 f0       	push   $0xf01066d8
f01034f9:	6a 51                	push   $0x51
f01034fb:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0103500:	e8 8f cb ff ff       	call   f0100094 <_panic>
		page_decref(pa2page(pa));
f0103505:	83 ec 0c             	sub    $0xc,%esp
f0103508:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f010350d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103510:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103513:	50                   	push   %eax
f0103514:	e8 d8 db ff ff       	call   f01010f1 <page_decref>
f0103519:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010351c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103520:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103523:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103528:	0f 85 29 ff ff ff    	jne    f0103457 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010352e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103531:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103536:	77 15                	ja     f010354d <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103538:	50                   	push   %eax
f0103539:	68 2c 60 10 f0       	push   $0xf010602c
f010353e:	68 02 02 00 00       	push   $0x202
f0103543:	68 8d 72 10 f0       	push   $0xf010728d
f0103548:	e8 47 cb ff ff       	call   f0100094 <_panic>
	e->env_pgdir = 0;
f010354d:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103554:	05 00 00 00 10       	add    $0x10000000,%eax
f0103559:	c1 e8 0c             	shr    $0xc,%eax
f010355c:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103562:	72 14                	jb     f0103578 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103564:	83 ec 04             	sub    $0x4,%esp
f0103567:	68 d8 66 10 f0       	push   $0xf01066d8
f010356c:	6a 51                	push   $0x51
f010356e:	68 4d 6f 10 f0       	push   $0xf0106f4d
f0103573:	e8 1c cb ff ff       	call   f0100094 <_panic>
	page_decref(pa2page(pa));
f0103578:	83 ec 0c             	sub    $0xc,%esp
f010357b:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0103581:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103584:	50                   	push   %eax
f0103585:	e8 67 db ff ff       	call   f01010f1 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010358a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103591:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f0103596:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103599:	89 3d 48 b2 22 f0    	mov    %edi,0xf022b248
}
f010359f:	83 c4 10             	add    $0x10,%esp
f01035a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035a5:	5b                   	pop    %ebx
f01035a6:	5e                   	pop    %esi
f01035a7:	5f                   	pop    %edi
f01035a8:	5d                   	pop    %ebp
f01035a9:	c3                   	ret    

f01035aa <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035aa:	55                   	push   %ebp
f01035ab:	89 e5                	mov    %esp,%ebp
f01035ad:	53                   	push   %ebx
f01035ae:	83 ec 04             	sub    $0x4,%esp
f01035b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035b4:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035b8:	75 19                	jne    f01035d3 <env_destroy+0x29>
f01035ba:	e8 eb 22 00 00       	call   f01058aa <cpunum>
f01035bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c2:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01035c8:	74 09                	je     f01035d3 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035ca:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035d1:	eb 33                	jmp    f0103606 <env_destroy+0x5c>
	}

	env_free(e);
f01035d3:	83 ec 0c             	sub    $0xc,%esp
f01035d6:	53                   	push   %ebx
f01035d7:	e8 f3 fd ff ff       	call   f01033cf <env_free>

	if (curenv == e) {
f01035dc:	e8 c9 22 00 00       	call   f01058aa <cpunum>
f01035e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e4:	83 c4 10             	add    $0x10,%esp
f01035e7:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01035ed:	75 17                	jne    f0103606 <env_destroy+0x5c>
		curenv = NULL;
f01035ef:	e8 b6 22 00 00       	call   f01058aa <cpunum>
f01035f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035f7:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f01035fe:	00 00 00 
		sched_yield();
f0103601:	e8 7e 0c 00 00       	call   f0104284 <sched_yield>
	}
}
f0103606:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103609:	c9                   	leave  
f010360a:	c3                   	ret    

f010360b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010360b:	55                   	push   %ebp
f010360c:	89 e5                	mov    %esp,%ebp
f010360e:	53                   	push   %ebx
f010360f:	83 ec 04             	sub    $0x4,%esp

	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103612:	e8 93 22 00 00       	call   f01058aa <cpunum>
f0103617:	6b c0 74             	imul   $0x74,%eax,%eax
f010361a:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103620:	e8 85 22 00 00       	call   f01058aa <cpunum>
f0103625:	89 43 5c             	mov    %eax,0x5c(%ebx)
	asm volatile(
f0103628:	8b 65 08             	mov    0x8(%ebp),%esp
f010362b:	61                   	popa   
f010362c:	07                   	pop    %es
f010362d:	1f                   	pop    %ds
f010362e:	83 c4 08             	add    $0x8,%esp
f0103631:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103632:	83 ec 04             	sub    $0x4,%esp
f0103635:	68 02 73 10 f0       	push   $0xf0107302
f010363a:	68 39 02 00 00       	push   $0x239
f010363f:	68 8d 72 10 f0       	push   $0xf010728d
f0103644:	e8 4b ca ff ff       	call   f0100094 <_panic>

f0103649 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103649:	55                   	push   %ebp
f010364a:	89 e5                	mov    %esp,%ebp
f010364c:	53                   	push   %ebx
f010364d:	83 ec 04             	sub    $0x4,%esp
f0103650:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.

//	cprintf("		We are going to run a env.\n");

	if(curenv && curenv->env_status == ENV_RUNNING)
f0103653:	e8 52 22 00 00       	call   f01058aa <cpunum>
f0103658:	6b c0 74             	imul   $0x74,%eax,%eax
f010365b:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103662:	74 29                	je     f010368d <env_run+0x44>
f0103664:	e8 41 22 00 00       	call   f01058aa <cpunum>
f0103669:	6b c0 74             	imul   $0x74,%eax,%eax
f010366c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103672:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103676:	75 15                	jne    f010368d <env_run+0x44>
	{
			curenv->env_status = ENV_RUNNABLE;
f0103678:	e8 2d 22 00 00       	call   f01058aa <cpunum>
f010367d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103680:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103686:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
 
	curenv = e;
f010368d:	e8 18 22 00 00       	call   f01058aa <cpunum>
f0103692:	6b c0 74             	imul   $0x74,%eax,%eax
f0103695:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
	e->env_status = ENV_RUNNING;
f010369b:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f01036a2:	83 43 58 01          	addl   $0x1,0x58(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036a6:	83 ec 0c             	sub    $0xc,%esp
f01036a9:	68 c0 03 12 f0       	push   $0xf01203c0
f01036ae:	e8 02 25 00 00       	call   f0105bb5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036b3:	f3 90                	pause  
	unlock_kernel();
	lcr3(PADDR(e->env_pgdir));	
f01036b5:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036b8:	83 c4 10             	add    $0x10,%esp
f01036bb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036c0:	77 15                	ja     f01036d7 <env_run+0x8e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036c2:	50                   	push   %eax
f01036c3:	68 2c 60 10 f0       	push   $0xf010602c
f01036c8:	68 63 02 00 00       	push   $0x263
f01036cd:	68 8d 72 10 f0       	push   $0xf010728d
f01036d2:	e8 bd c9 ff ff       	call   f0100094 <_panic>
f01036d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01036dc:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&(e->env_tf));
f01036df:	83 ec 0c             	sub    $0xc,%esp
f01036e2:	53                   	push   %ebx
f01036e3:	e8 23 ff ff ff       	call   f010360b <env_pop_tf>

f01036e8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036e8:	55                   	push   %ebp
f01036e9:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036eb:	ba 70 00 00 00       	mov    $0x70,%edx
f01036f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f3:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036f4:	ba 71 00 00 00       	mov    $0x71,%edx
f01036f9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036fa:	0f b6 c0             	movzbl %al,%eax
}
f01036fd:	5d                   	pop    %ebp
f01036fe:	c3                   	ret    

f01036ff <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103702:	ba 70 00 00 00       	mov    $0x70,%edx
f0103707:	8b 45 08             	mov    0x8(%ebp),%eax
f010370a:	ee                   	out    %al,(%dx)
f010370b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103710:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103713:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103714:	5d                   	pop    %ebp
f0103715:	c3                   	ret    

f0103716 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103716:	55                   	push   %ebp
f0103717:	89 e5                	mov    %esp,%ebp
f0103719:	56                   	push   %esi
f010371a:	53                   	push   %ebx
f010371b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010371e:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103724:	80 3d 4c b2 22 f0 00 	cmpb   $0x0,0xf022b24c
f010372b:	74 5a                	je     f0103787 <irq_setmask_8259A+0x71>
f010372d:	89 c6                	mov    %eax,%esi
f010372f:	ba 21 00 00 00       	mov    $0x21,%edx
f0103734:	ee                   	out    %al,(%dx)
f0103735:	66 c1 e8 08          	shr    $0x8,%ax
f0103739:	ba a1 00 00 00       	mov    $0xa1,%edx
f010373e:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010373f:	83 ec 0c             	sub    $0xc,%esp
f0103742:	68 89 73 10 f0       	push   $0xf0107389
f0103747:	e8 1b 01 00 00       	call   f0103867 <cprintf>
f010374c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010374f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103754:	0f b7 f6             	movzwl %si,%esi
f0103757:	f7 d6                	not    %esi
f0103759:	0f a3 de             	bt     %ebx,%esi
f010375c:	73 11                	jae    f010376f <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010375e:	83 ec 08             	sub    $0x8,%esp
f0103761:	53                   	push   %ebx
f0103762:	68 ef 78 10 f0       	push   $0xf01078ef
f0103767:	e8 fb 00 00 00       	call   f0103867 <cprintf>
f010376c:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010376f:	83 c3 01             	add    $0x1,%ebx
f0103772:	83 fb 10             	cmp    $0x10,%ebx
f0103775:	75 e2                	jne    f0103759 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103777:	83 ec 0c             	sub    $0xc,%esp
f010377a:	68 04 63 10 f0       	push   $0xf0106304
f010377f:	e8 e3 00 00 00       	call   f0103867 <cprintf>
f0103784:	83 c4 10             	add    $0x10,%esp
}
f0103787:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010378a:	5b                   	pop    %ebx
f010378b:	5e                   	pop    %esi
f010378c:	5d                   	pop    %ebp
f010378d:	c3                   	ret    

f010378e <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010378e:	c6 05 4c b2 22 f0 01 	movb   $0x1,0xf022b24c
f0103795:	ba 21 00 00 00       	mov    $0x21,%edx
f010379a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010379f:	ee                   	out    %al,(%dx)
f01037a0:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037a5:	ee                   	out    %al,(%dx)
f01037a6:	ba 20 00 00 00       	mov    $0x20,%edx
f01037ab:	b8 11 00 00 00       	mov    $0x11,%eax
f01037b0:	ee                   	out    %al,(%dx)
f01037b1:	ba 21 00 00 00       	mov    $0x21,%edx
f01037b6:	b8 20 00 00 00       	mov    $0x20,%eax
f01037bb:	ee                   	out    %al,(%dx)
f01037bc:	b8 04 00 00 00       	mov    $0x4,%eax
f01037c1:	ee                   	out    %al,(%dx)
f01037c2:	b8 03 00 00 00       	mov    $0x3,%eax
f01037c7:	ee                   	out    %al,(%dx)
f01037c8:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037cd:	b8 11 00 00 00       	mov    $0x11,%eax
f01037d2:	ee                   	out    %al,(%dx)
f01037d3:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037d8:	b8 28 00 00 00       	mov    $0x28,%eax
f01037dd:	ee                   	out    %al,(%dx)
f01037de:	b8 02 00 00 00       	mov    $0x2,%eax
f01037e3:	ee                   	out    %al,(%dx)
f01037e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01037e9:	ee                   	out    %al,(%dx)
f01037ea:	ba 20 00 00 00       	mov    $0x20,%edx
f01037ef:	b8 68 00 00 00       	mov    $0x68,%eax
f01037f4:	ee                   	out    %al,(%dx)
f01037f5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037fa:	ee                   	out    %al,(%dx)
f01037fb:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103800:	b8 68 00 00 00       	mov    $0x68,%eax
f0103805:	ee                   	out    %al,(%dx)
f0103806:	b8 0a 00 00 00       	mov    $0xa,%eax
f010380b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010380c:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103813:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103817:	74 13                	je     f010382c <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103819:	55                   	push   %ebp
f010381a:	89 e5                	mov    %esp,%ebp
f010381c:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010381f:	0f b7 c0             	movzwl %ax,%eax
f0103822:	50                   	push   %eax
f0103823:	e8 ee fe ff ff       	call   f0103716 <irq_setmask_8259A>
f0103828:	83 c4 10             	add    $0x10,%esp
}
f010382b:	c9                   	leave  
f010382c:	f3 c3                	repz ret 

f010382e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010382e:	55                   	push   %ebp
f010382f:	89 e5                	mov    %esp,%ebp
f0103831:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103834:	ff 75 08             	pushl  0x8(%ebp)
f0103837:	e8 91 cf ff ff       	call   f01007cd <cputchar>
	*cnt++;
}
f010383c:	83 c4 10             	add    $0x10,%esp
f010383f:	c9                   	leave  
f0103840:	c3                   	ret    

f0103841 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103841:	55                   	push   %ebp
f0103842:	89 e5                	mov    %esp,%ebp
f0103844:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103847:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010384e:	ff 75 0c             	pushl  0xc(%ebp)
f0103851:	ff 75 08             	pushl  0x8(%ebp)
f0103854:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103857:	50                   	push   %eax
f0103858:	68 2e 38 10 f0       	push   $0xf010382e
f010385d:	e8 71 13 00 00       	call   f0104bd3 <vprintfmt>
	return cnt;
}
f0103862:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103865:	c9                   	leave  
f0103866:	c3                   	ret    

f0103867 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103867:	55                   	push   %ebp
f0103868:	89 e5                	mov    %esp,%ebp
f010386a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010386d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103870:	50                   	push   %eax
f0103871:	ff 75 08             	pushl  0x8(%ebp)
f0103874:	e8 c8 ff ff ff       	call   f0103841 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103879:	c9                   	leave  
f010387a:	c3                   	ret    

f010387b <trap_init_percpu>:
*/
// Initialize and load the per-CPU TSS and IDT

void
trap_init_percpu(void)
{
f010387b:	55                   	push   %ebp
f010387c:	89 e5                	mov    %esp,%ebp
f010387e:	57                   	push   %edi
f010387f:	56                   	push   %esi
f0103880:	53                   	push   %ebx
f0103881:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP-cpunum()*(KSTKSIZE+KSTKGAP);
f0103884:	e8 21 20 00 00       	call   f01058aa <cpunum>
f0103889:	89 c3                	mov    %eax,%ebx
f010388b:	e8 1a 20 00 00       	call   f01058aa <cpunum>
f0103890:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103893:	c1 e0 10             	shl    $0x10,%eax
f0103896:	89 c2                	mov    %eax,%edx
f0103898:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f010389d:	29 d0                	sub    %edx,%eax
f010389f:	89 83 30 c0 22 f0    	mov    %eax,-0xfdd3fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038a5:	e8 00 20 00 00       	call   f01058aa <cpunum>
f01038aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ad:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f01038b4:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038b6:	e8 ef 1f 00 00       	call   f01058aa <cpunum>
f01038bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01038be:	66 c7 80 92 c0 22 f0 	movw   $0x68,-0xfdd3f6e(%eax)
f01038c5:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01038c7:	e8 de 1f 00 00       	call   f01058aa <cpunum>
f01038cc:	8d 58 05             	lea    0x5(%eax),%ebx
f01038cf:	e8 d6 1f 00 00       	call   f01058aa <cpunum>
f01038d4:	89 c7                	mov    %eax,%edi
f01038d6:	e8 cf 1f 00 00       	call   f01058aa <cpunum>
f01038db:	89 c6                	mov    %eax,%esi
f01038dd:	e8 c8 1f 00 00       	call   f01058aa <cpunum>
f01038e2:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01038e9:	f0 67 00 
f01038ec:	6b ff 74             	imul   $0x74,%edi,%edi
f01038ef:	81 c7 2c c0 22 f0    	add    $0xf022c02c,%edi
f01038f5:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f01038fc:	f0 
f01038fd:	6b d6 74             	imul   $0x74,%esi,%edx
f0103900:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f0103906:	c1 ea 10             	shr    $0x10,%edx
f0103909:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103910:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f0103917:	99 
f0103918:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f010391f:	40 
f0103920:	6b c0 74             	imul   $0x74,%eax,%eax
f0103923:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f0103928:	c1 e8 18             	shr    $0x18,%eax
f010392b:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+cpunum()].sd_s = 0;
f0103932:	e8 73 1f 00 00       	call   f01058aa <cpunum>
f0103937:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010393e:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(thiscpu->cpu_id<<3));//why do this?I cannot unstanderd.
f010393f:	e8 66 1f 00 00       	call   f01058aa <cpunum>
f0103944:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103947:	0f b6 80 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%eax
f010394e:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103955:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103958:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010395d:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
	*/
}
f0103960:	83 c4 0c             	add    $0xc,%esp
f0103963:	5b                   	pop    %ebx
f0103964:	5e                   	pop    %esi
f0103965:	5f                   	pop    %edi
f0103966:	5d                   	pop    %ebp
f0103967:	c3                   	ret    

f0103968 <trap_init>:
}


void
trap_init(void)
{
f0103968:	55                   	push   %ebp
f0103969:	89 e5                	mov    %esp,%ebp
f010396b:	83 ec 08             	sub    $0x8,%esp
   	void t_align();
	void t_mchk();
	void t_simderr();
	void t_syscall();

	SETGATE(idt[T_DIVIDE],0,GD_KT,t_divide,0);
f010396e:	b8 3c 41 10 f0       	mov    $0xf010413c,%eax
f0103973:	66 a3 60 b2 22 f0    	mov    %ax,0xf022b260
f0103979:	66 c7 05 62 b2 22 f0 	movw   $0x8,0xf022b262
f0103980:	08 00 
f0103982:	c6 05 64 b2 22 f0 00 	movb   $0x0,0xf022b264
f0103989:	c6 05 65 b2 22 f0 8e 	movb   $0x8e,0xf022b265
f0103990:	c1 e8 10             	shr    $0x10,%eax
f0103993:	66 a3 66 b2 22 f0    	mov    %ax,0xf022b266
	SETGATE(idt[T_DEBUG],0,GD_KT,t_debug,0);
f0103999:	b8 42 41 10 f0       	mov    $0xf0104142,%eax
f010399e:	66 a3 68 b2 22 f0    	mov    %ax,0xf022b268
f01039a4:	66 c7 05 6a b2 22 f0 	movw   $0x8,0xf022b26a
f01039ab:	08 00 
f01039ad:	c6 05 6c b2 22 f0 00 	movb   $0x0,0xf022b26c
f01039b4:	c6 05 6d b2 22 f0 8e 	movb   $0x8e,0xf022b26d
f01039bb:	c1 e8 10             	shr    $0x10,%eax
f01039be:	66 a3 6e b2 22 f0    	mov    %ax,0xf022b26e
//	SETGAET(idt[T_NMI],0,GD_KT,t_nmi,0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01039c4:	b8 4e 41 10 f0       	mov    $0xf010414e,%eax
f01039c9:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f01039cf:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f01039d6:	08 00 
f01039d8:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f01039df:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f01039e6:	c1 e8 10             	shr    $0x10,%eax
f01039e9:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e
   	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01039ef:	b8 54 41 10 f0       	mov    $0xf0104154,%eax
f01039f4:	66 a3 80 b2 22 f0    	mov    %ax,0xf022b280
f01039fa:	66 c7 05 82 b2 22 f0 	movw   $0x8,0xf022b282
f0103a01:	08 00 
f0103a03:	c6 05 84 b2 22 f0 00 	movb   $0x0,0xf022b284
f0103a0a:	c6 05 85 b2 22 f0 8e 	movb   $0x8e,0xf022b285
f0103a11:	c1 e8 10             	shr    $0x10,%eax
f0103a14:	66 a3 86 b2 22 f0    	mov    %ax,0xf022b286
        SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103a1a:	b8 5a 41 10 f0       	mov    $0xf010415a,%eax
f0103a1f:	66 a3 88 b2 22 f0    	mov    %ax,0xf022b288
f0103a25:	66 c7 05 8a b2 22 f0 	movw   $0x8,0xf022b28a
f0103a2c:	08 00 
f0103a2e:	c6 05 8c b2 22 f0 00 	movb   $0x0,0xf022b28c
f0103a35:	c6 05 8d b2 22 f0 8e 	movb   $0x8e,0xf022b28d
f0103a3c:	c1 e8 10             	shr    $0x10,%eax
f0103a3f:	66 a3 8e b2 22 f0    	mov    %ax,0xf022b28e
        SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103a45:	b8 60 41 10 f0       	mov    $0xf0104160,%eax
f0103a4a:	66 a3 90 b2 22 f0    	mov    %ax,0xf022b290
f0103a50:	66 c7 05 92 b2 22 f0 	movw   $0x8,0xf022b292
f0103a57:	08 00 
f0103a59:	c6 05 94 b2 22 f0 00 	movb   $0x0,0xf022b294
f0103a60:	c6 05 95 b2 22 f0 8e 	movb   $0x8e,0xf022b295
f0103a67:	c1 e8 10             	shr    $0x10,%eax
f0103a6a:	66 a3 96 b2 22 f0    	mov    %ax,0xf022b296
        SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103a70:	b8 66 41 10 f0       	mov    $0xf0104166,%eax
f0103a75:	66 a3 98 b2 22 f0    	mov    %ax,0xf022b298
f0103a7b:	66 c7 05 9a b2 22 f0 	movw   $0x8,0xf022b29a
f0103a82:	08 00 
f0103a84:	c6 05 9c b2 22 f0 00 	movb   $0x0,0xf022b29c
f0103a8b:	c6 05 9d b2 22 f0 8e 	movb   $0x8e,0xf022b29d
f0103a92:	c1 e8 10             	shr    $0x10,%eax
f0103a95:	66 a3 9e b2 22 f0    	mov    %ax,0xf022b29e
   	 SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103a9b:	b8 6c 41 10 f0       	mov    $0xf010416c,%eax
f0103aa0:	66 a3 a0 b2 22 f0    	mov    %ax,0xf022b2a0
f0103aa6:	66 c7 05 a2 b2 22 f0 	movw   $0x8,0xf022b2a2
f0103aad:	08 00 
f0103aaf:	c6 05 a4 b2 22 f0 00 	movb   $0x0,0xf022b2a4
f0103ab6:	c6 05 a5 b2 22 f0 8e 	movb   $0x8e,0xf022b2a5
f0103abd:	c1 e8 10             	shr    $0x10,%eax
f0103ac0:	66 a3 a6 b2 22 f0    	mov    %ax,0xf022b2a6
   	 SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103ac6:	b8 70 41 10 f0       	mov    $0xf0104170,%eax
f0103acb:	66 a3 b0 b2 22 f0    	mov    %ax,0xf022b2b0
f0103ad1:	66 c7 05 b2 b2 22 f0 	movw   $0x8,0xf022b2b2
f0103ad8:	08 00 
f0103ada:	c6 05 b4 b2 22 f0 00 	movb   $0x0,0xf022b2b4
f0103ae1:	c6 05 b5 b2 22 f0 8e 	movb   $0x8e,0xf022b2b5
f0103ae8:	c1 e8 10             	shr    $0x10,%eax
f0103aeb:	66 a3 b6 b2 22 f0    	mov    %ax,0xf022b2b6
  	 SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103af1:	b8 74 41 10 f0       	mov    $0xf0104174,%eax
f0103af6:	66 a3 b8 b2 22 f0    	mov    %ax,0xf022b2b8
f0103afc:	66 c7 05 ba b2 22 f0 	movw   $0x8,0xf022b2ba
f0103b03:	08 00 
f0103b05:	c6 05 bc b2 22 f0 00 	movb   $0x0,0xf022b2bc
f0103b0c:	c6 05 bd b2 22 f0 8e 	movb   $0x8e,0xf022b2bd
f0103b13:	c1 e8 10             	shr    $0x10,%eax
f0103b16:	66 a3 be b2 22 f0    	mov    %ax,0xf022b2be
   	 SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103b1c:	b8 78 41 10 f0       	mov    $0xf0104178,%eax
f0103b21:	66 a3 c0 b2 22 f0    	mov    %ax,0xf022b2c0
f0103b27:	66 c7 05 c2 b2 22 f0 	movw   $0x8,0xf022b2c2
f0103b2e:	08 00 
f0103b30:	c6 05 c4 b2 22 f0 00 	movb   $0x0,0xf022b2c4
f0103b37:	c6 05 c5 b2 22 f0 8e 	movb   $0x8e,0xf022b2c5
f0103b3e:	c1 e8 10             	shr    $0x10,%eax
f0103b41:	66 a3 c6 b2 22 f0    	mov    %ax,0xf022b2c6
   	 SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103b47:	b8 7c 41 10 f0       	mov    $0xf010417c,%eax
f0103b4c:	66 a3 c8 b2 22 f0    	mov    %ax,0xf022b2c8
f0103b52:	66 c7 05 ca b2 22 f0 	movw   $0x8,0xf022b2ca
f0103b59:	08 00 
f0103b5b:	c6 05 cc b2 22 f0 00 	movb   $0x0,0xf022b2cc
f0103b62:	c6 05 cd b2 22 f0 8e 	movb   $0x8e,0xf022b2cd
f0103b69:	c1 e8 10             	shr    $0x10,%eax
f0103b6c:	66 a3 ce b2 22 f0    	mov    %ax,0xf022b2ce
   	 SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103b72:	b8 80 41 10 f0       	mov    $0xf0104180,%eax
f0103b77:	66 a3 d0 b2 22 f0    	mov    %ax,0xf022b2d0
f0103b7d:	66 c7 05 d2 b2 22 f0 	movw   $0x8,0xf022b2d2
f0103b84:	08 00 
f0103b86:	c6 05 d4 b2 22 f0 00 	movb   $0x0,0xf022b2d4
f0103b8d:	c6 05 d5 b2 22 f0 8e 	movb   $0x8e,0xf022b2d5
f0103b94:	c1 e8 10             	shr    $0x10,%eax
f0103b97:	66 a3 d6 b2 22 f0    	mov    %ax,0xf022b2d6
   	 SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103b9d:	b8 84 41 10 f0       	mov    $0xf0104184,%eax
f0103ba2:	66 a3 e0 b2 22 f0    	mov    %ax,0xf022b2e0
f0103ba8:	66 c7 05 e2 b2 22 f0 	movw   $0x8,0xf022b2e2
f0103baf:	08 00 
f0103bb1:	c6 05 e4 b2 22 f0 00 	movb   $0x0,0xf022b2e4
f0103bb8:	c6 05 e5 b2 22 f0 8e 	movb   $0x8e,0xf022b2e5
f0103bbf:	c1 e8 10             	shr    $0x10,%eax
f0103bc2:	66 a3 e6 b2 22 f0    	mov    %ax,0xf022b2e6
   	 SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103bc8:	b8 8a 41 10 f0       	mov    $0xf010418a,%eax
f0103bcd:	66 a3 e8 b2 22 f0    	mov    %ax,0xf022b2e8
f0103bd3:	66 c7 05 ea b2 22 f0 	movw   $0x8,0xf022b2ea
f0103bda:	08 00 
f0103bdc:	c6 05 ec b2 22 f0 00 	movb   $0x0,0xf022b2ec
f0103be3:	c6 05 ed b2 22 f0 8e 	movb   $0x8e,0xf022b2ed
f0103bea:	c1 e8 10             	shr    $0x10,%eax
f0103bed:	66 a3 ee b2 22 f0    	mov    %ax,0xf022b2ee
   	 SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103bf3:	b8 8e 41 10 f0       	mov    $0xf010418e,%eax
f0103bf8:	66 a3 f0 b2 22 f0    	mov    %ax,0xf022b2f0
f0103bfe:	66 c7 05 f2 b2 22 f0 	movw   $0x8,0xf022b2f2
f0103c05:	08 00 
f0103c07:	c6 05 f4 b2 22 f0 00 	movb   $0x0,0xf022b2f4
f0103c0e:	c6 05 f5 b2 22 f0 8e 	movb   $0x8e,0xf022b2f5
f0103c15:	c1 e8 10             	shr    $0x10,%eax
f0103c18:	66 a3 f6 b2 22 f0    	mov    %ax,0xf022b2f6
   	 SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103c1e:	b8 94 41 10 f0       	mov    $0xf0104194,%eax
f0103c23:	66 a3 f8 b2 22 f0    	mov    %ax,0xf022b2f8
f0103c29:	66 c7 05 fa b2 22 f0 	movw   $0x8,0xf022b2fa
f0103c30:	08 00 
f0103c32:	c6 05 fc b2 22 f0 00 	movb   $0x0,0xf022b2fc
f0103c39:	c6 05 fd b2 22 f0 8e 	movb   $0x8e,0xf022b2fd
f0103c40:	c1 e8 10             	shr    $0x10,%eax
f0103c43:	66 a3 fe b2 22 f0    	mov    %ax,0xf022b2fe
   	 SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103c49:	b8 9a 41 10 f0       	mov    $0xf010419a,%eax
f0103c4e:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f0103c54:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f0103c5b:	08 00 
f0103c5d:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f0103c64:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f0103c6b:	c1 e8 10             	shr    $0x10,%eax
f0103c6e:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6
	// Per-CPU setup 
	trap_init_percpu();
f0103c74:	e8 02 fc ff ff       	call   f010387b <trap_init_percpu>
}
f0103c79:	c9                   	leave  
f0103c7a:	c3                   	ret    

f0103c7b <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c7b:	55                   	push   %ebp
f0103c7c:	89 e5                	mov    %esp,%ebp
f0103c7e:	53                   	push   %ebx
f0103c7f:	83 ec 0c             	sub    $0xc,%esp
f0103c82:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c85:	ff 33                	pushl  (%ebx)
f0103c87:	68 9d 73 10 f0       	push   $0xf010739d
f0103c8c:	e8 d6 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c91:	83 c4 08             	add    $0x8,%esp
f0103c94:	ff 73 04             	pushl  0x4(%ebx)
f0103c97:	68 ac 73 10 f0       	push   $0xf01073ac
f0103c9c:	e8 c6 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ca1:	83 c4 08             	add    $0x8,%esp
f0103ca4:	ff 73 08             	pushl  0x8(%ebx)
f0103ca7:	68 bb 73 10 f0       	push   $0xf01073bb
f0103cac:	e8 b6 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cb1:	83 c4 08             	add    $0x8,%esp
f0103cb4:	ff 73 0c             	pushl  0xc(%ebx)
f0103cb7:	68 ca 73 10 f0       	push   $0xf01073ca
f0103cbc:	e8 a6 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103cc1:	83 c4 08             	add    $0x8,%esp
f0103cc4:	ff 73 10             	pushl  0x10(%ebx)
f0103cc7:	68 d9 73 10 f0       	push   $0xf01073d9
f0103ccc:	e8 96 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103cd1:	83 c4 08             	add    $0x8,%esp
f0103cd4:	ff 73 14             	pushl  0x14(%ebx)
f0103cd7:	68 e8 73 10 f0       	push   $0xf01073e8
f0103cdc:	e8 86 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ce1:	83 c4 08             	add    $0x8,%esp
f0103ce4:	ff 73 18             	pushl  0x18(%ebx)
f0103ce7:	68 f7 73 10 f0       	push   $0xf01073f7
f0103cec:	e8 76 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103cf1:	83 c4 08             	add    $0x8,%esp
f0103cf4:	ff 73 1c             	pushl  0x1c(%ebx)
f0103cf7:	68 06 74 10 f0       	push   $0xf0107406
f0103cfc:	e8 66 fb ff ff       	call   f0103867 <cprintf>
}
f0103d01:	83 c4 10             	add    $0x10,%esp
f0103d04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d07:	c9                   	leave  
f0103d08:	c3                   	ret    

f0103d09 <print_trapframe>:
	*/
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d09:	55                   	push   %ebp
f0103d0a:	89 e5                	mov    %esp,%ebp
f0103d0c:	56                   	push   %esi
f0103d0d:	53                   	push   %ebx
f0103d0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d11:	e8 94 1b 00 00       	call   f01058aa <cpunum>
f0103d16:	83 ec 04             	sub    $0x4,%esp
f0103d19:	50                   	push   %eax
f0103d1a:	53                   	push   %ebx
f0103d1b:	68 6a 74 10 f0       	push   $0xf010746a
f0103d20:	e8 42 fb ff ff       	call   f0103867 <cprintf>
	print_regs(&tf->tf_regs);
f0103d25:	89 1c 24             	mov    %ebx,(%esp)
f0103d28:	e8 4e ff ff ff       	call   f0103c7b <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d2d:	83 c4 08             	add    $0x8,%esp
f0103d30:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d34:	50                   	push   %eax
f0103d35:	68 88 74 10 f0       	push   $0xf0107488
f0103d3a:	e8 28 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d3f:	83 c4 08             	add    $0x8,%esp
f0103d42:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d46:	50                   	push   %eax
f0103d47:	68 9b 74 10 f0       	push   $0xf010749b
f0103d4c:	e8 16 fb ff ff       	call   f0103867 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d51:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103d54:	83 c4 10             	add    $0x10,%esp
f0103d57:	83 f8 13             	cmp    $0x13,%eax
f0103d5a:	77 09                	ja     f0103d65 <print_trapframe+0x5c>
		return excnames[trapno];
f0103d5c:	8b 14 85 40 77 10 f0 	mov    -0xfef88c0(,%eax,4),%edx
f0103d63:	eb 1f                	jmp    f0103d84 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103d65:	83 f8 30             	cmp    $0x30,%eax
f0103d68:	74 15                	je     f0103d7f <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103d6a:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103d6d:	83 fa 10             	cmp    $0x10,%edx
f0103d70:	b9 34 74 10 f0       	mov    $0xf0107434,%ecx
f0103d75:	ba 21 74 10 f0       	mov    $0xf0107421,%edx
f0103d7a:	0f 43 d1             	cmovae %ecx,%edx
f0103d7d:	eb 05                	jmp    f0103d84 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103d7f:	ba 15 74 10 f0       	mov    $0xf0107415,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d84:	83 ec 04             	sub    $0x4,%esp
f0103d87:	52                   	push   %edx
f0103d88:	50                   	push   %eax
f0103d89:	68 ae 74 10 f0       	push   $0xf01074ae
f0103d8e:	e8 d4 fa ff ff       	call   f0103867 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d93:	83 c4 10             	add    $0x10,%esp
f0103d96:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0103d9c:	75 1a                	jne    f0103db8 <print_trapframe+0xaf>
f0103d9e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103da2:	75 14                	jne    f0103db8 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103da4:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103da7:	83 ec 08             	sub    $0x8,%esp
f0103daa:	50                   	push   %eax
f0103dab:	68 c0 74 10 f0       	push   $0xf01074c0
f0103db0:	e8 b2 fa ff ff       	call   f0103867 <cprintf>
f0103db5:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103db8:	83 ec 08             	sub    $0x8,%esp
f0103dbb:	ff 73 2c             	pushl  0x2c(%ebx)
f0103dbe:	68 cf 74 10 f0       	push   $0xf01074cf
f0103dc3:	e8 9f fa ff ff       	call   f0103867 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103dc8:	83 c4 10             	add    $0x10,%esp
f0103dcb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103dcf:	75 49                	jne    f0103e1a <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103dd1:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103dd4:	89 c2                	mov    %eax,%edx
f0103dd6:	83 e2 01             	and    $0x1,%edx
f0103dd9:	ba 4e 74 10 f0       	mov    $0xf010744e,%edx
f0103dde:	b9 43 74 10 f0       	mov    $0xf0107443,%ecx
f0103de3:	0f 44 ca             	cmove  %edx,%ecx
f0103de6:	89 c2                	mov    %eax,%edx
f0103de8:	83 e2 02             	and    $0x2,%edx
f0103deb:	ba 60 74 10 f0       	mov    $0xf0107460,%edx
f0103df0:	be 5a 74 10 f0       	mov    $0xf010745a,%esi
f0103df5:	0f 45 d6             	cmovne %esi,%edx
f0103df8:	83 e0 04             	and    $0x4,%eax
f0103dfb:	be 9a 75 10 f0       	mov    $0xf010759a,%esi
f0103e00:	b8 65 74 10 f0       	mov    $0xf0107465,%eax
f0103e05:	0f 44 c6             	cmove  %esi,%eax
f0103e08:	51                   	push   %ecx
f0103e09:	52                   	push   %edx
f0103e0a:	50                   	push   %eax
f0103e0b:	68 dd 74 10 f0       	push   $0xf01074dd
f0103e10:	e8 52 fa ff ff       	call   f0103867 <cprintf>
f0103e15:	83 c4 10             	add    $0x10,%esp
f0103e18:	eb 10                	jmp    f0103e2a <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e1a:	83 ec 0c             	sub    $0xc,%esp
f0103e1d:	68 04 63 10 f0       	push   $0xf0106304
f0103e22:	e8 40 fa ff ff       	call   f0103867 <cprintf>
f0103e27:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e2a:	83 ec 08             	sub    $0x8,%esp
f0103e2d:	ff 73 30             	pushl  0x30(%ebx)
f0103e30:	68 ec 74 10 f0       	push   $0xf01074ec
f0103e35:	e8 2d fa ff ff       	call   f0103867 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e3a:	83 c4 08             	add    $0x8,%esp
f0103e3d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e41:	50                   	push   %eax
f0103e42:	68 fb 74 10 f0       	push   $0xf01074fb
f0103e47:	e8 1b fa ff ff       	call   f0103867 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e4c:	83 c4 08             	add    $0x8,%esp
f0103e4f:	ff 73 38             	pushl  0x38(%ebx)
f0103e52:	68 0e 75 10 f0       	push   $0xf010750e
f0103e57:	e8 0b fa ff ff       	call   f0103867 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e5c:	83 c4 10             	add    $0x10,%esp
f0103e5f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e63:	74 25                	je     f0103e8a <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e65:	83 ec 08             	sub    $0x8,%esp
f0103e68:	ff 73 3c             	pushl  0x3c(%ebx)
f0103e6b:	68 1d 75 10 f0       	push   $0xf010751d
f0103e70:	e8 f2 f9 ff ff       	call   f0103867 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e75:	83 c4 08             	add    $0x8,%esp
f0103e78:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e7c:	50                   	push   %eax
f0103e7d:	68 2c 75 10 f0       	push   $0xf010752c
f0103e82:	e8 e0 f9 ff ff       	call   f0103867 <cprintf>
f0103e87:	83 c4 10             	add    $0x10,%esp
	}
}
f0103e8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e8d:	5b                   	pop    %ebx
f0103e8e:	5e                   	pop    %esi
f0103e8f:	5d                   	pop    %ebp
f0103e90:	c3                   	ret    

f0103e91 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e91:	55                   	push   %ebp
f0103e92:	89 e5                	mov    %esp,%ebp
f0103e94:	57                   	push   %edi
f0103e95:	56                   	push   %esi
f0103e96:	53                   	push   %ebx
f0103e97:	83 ec 18             	sub    $0x18,%esp
f0103e9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103e9d:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	print_trapframe(tf);
f0103ea0:	53                   	push   %ebx
f0103ea1:	e8 63 fe ff ff       	call   f0103d09 <print_trapframe>
	if ((tf->tf_cs&3) == 0)
f0103ea6:	83 c4 10             	add    $0x10,%esp
f0103ea9:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ead:	75 17                	jne    f0103ec6 <page_fault_handler+0x35>
		panic("a page fault happens in kernel [eip:%x]", tf->tf_eip);
f0103eaf:	ff 73 30             	pushl  0x30(%ebx)
f0103eb2:	68 e4 76 10 f0       	push   $0xf01076e4
f0103eb7:	68 ee 01 00 00       	push   $0x1ee
f0103ebc:	68 3f 75 10 f0       	push   $0xf010753f
f0103ec1:	e8 ce c1 ff ff       	call   f0100094 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
f0103ec6:	83 ec 0c             	sub    $0xc,%esp
f0103ec9:	53                   	push   %ebx
f0103eca:	e8 3a fe ff ff       	call   f0103d09 <print_trapframe>
	env_destroy(curenv);
f0103ecf:	e8 d6 19 00 00       	call   f01058aa <cpunum>
f0103ed4:	83 c4 04             	add    $0x4,%esp
f0103ed7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eda:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103ee0:	e8 c5 f6 ff ff       	call   f01035aa <env_destroy>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ee5:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ee8:	e8 bd 19 00 00       	call   f01058aa <cpunum>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103eed:	57                   	push   %edi
f0103eee:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103eef:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ef2:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103ef8:	ff 70 48             	pushl  0x48(%eax)
f0103efb:	68 0c 77 10 f0       	push   $0xf010770c
f0103f00:	e8 62 f9 ff ff       	call   f0103867 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103f05:	83 c4 14             	add    $0x14,%esp
f0103f08:	53                   	push   %ebx
f0103f09:	e8 fb fd ff ff       	call   f0103d09 <print_trapframe>
	env_destroy(curenv);
f0103f0e:	e8 97 19 00 00       	call   f01058aa <cpunum>
f0103f13:	83 c4 04             	add    $0x4,%esp
f0103f16:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f19:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103f1f:	e8 86 f6 ff ff       	call   f01035aa <env_destroy>
}
f0103f24:	83 c4 10             	add    $0x10,%esp
f0103f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f2a:	5b                   	pop    %ebx
f0103f2b:	5e                   	pop    %esi
f0103f2c:	5f                   	pop    %edi
f0103f2d:	5d                   	pop    %ebp
f0103f2e:	c3                   	ret    

f0103f2f <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103f2f:	55                   	push   %ebp
f0103f30:	89 e5                	mov    %esp,%ebp
f0103f32:	57                   	push   %edi
f0103f33:	56                   	push   %esi
f0103f34:	8b 75 08             	mov    0x8(%ebp),%esi

	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f37:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103f38:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0103f3f:	74 01                	je     f0103f42 <trap+0x13>
		asm volatile("hlt");
f0103f41:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103f42:	e8 63 19 00 00       	call   f01058aa <cpunum>
f0103f47:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f4a:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0103f50:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f55:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103f59:	83 f8 02             	cmp    $0x2,%eax
f0103f5c:	75 10                	jne    f0103f6e <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103f5e:	83 ec 0c             	sub    $0xc,%esp
f0103f61:	68 c0 03 12 f0       	push   $0xf01203c0
f0103f66:	e8 ad 1b 00 00       	call   f0105b18 <spin_lock>
f0103f6b:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103f6e:	9c                   	pushf  
f0103f6f:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f70:	f6 c4 02             	test   $0x2,%ah
f0103f73:	74 19                	je     f0103f8e <trap+0x5f>
f0103f75:	68 4b 75 10 f0       	push   $0xf010754b
f0103f7a:	68 67 6f 10 f0       	push   $0xf0106f67
f0103f7f:	68 b4 01 00 00       	push   $0x1b4
f0103f84:	68 3f 75 10 f0       	push   $0xf010753f
f0103f89:	e8 06 c1 ff ff       	call   f0100094 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103f8e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f92:	83 e0 03             	and    $0x3,%eax
f0103f95:	66 83 f8 03          	cmp    $0x3,%ax
f0103f99:	0f 85 a0 00 00 00    	jne    f010403f <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103f9f:	e8 06 19 00 00       	call   f01058aa <cpunum>
f0103fa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fa7:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103fae:	75 19                	jne    f0103fc9 <trap+0x9a>
f0103fb0:	68 64 75 10 f0       	push   $0xf0107564
f0103fb5:	68 67 6f 10 f0       	push   $0xf0106f67
f0103fba:	68 bb 01 00 00       	push   $0x1bb
f0103fbf:	68 3f 75 10 f0       	push   $0xf010753f
f0103fc4:	e8 cb c0 ff ff       	call   f0100094 <_panic>
f0103fc9:	83 ec 0c             	sub    $0xc,%esp
f0103fcc:	68 c0 03 12 f0       	push   $0xf01203c0
f0103fd1:	e8 42 1b 00 00       	call   f0105b18 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103fd6:	e8 cf 18 00 00       	call   f01058aa <cpunum>
f0103fdb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fde:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103fe4:	83 c4 10             	add    $0x10,%esp
f0103fe7:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103feb:	75 2d                	jne    f010401a <trap+0xeb>
			env_free(curenv);
f0103fed:	e8 b8 18 00 00       	call   f01058aa <cpunum>
f0103ff2:	83 ec 0c             	sub    $0xc,%esp
f0103ff5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff8:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103ffe:	e8 cc f3 ff ff       	call   f01033cf <env_free>
			curenv = NULL;
f0104003:	e8 a2 18 00 00       	call   f01058aa <cpunum>
f0104008:	6b c0 74             	imul   $0x74,%eax,%eax
f010400b:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104012:	00 00 00 
			sched_yield();
f0104015:	e8 6a 02 00 00       	call   f0104284 <sched_yield>
		}
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010401a:	e8 8b 18 00 00       	call   f01058aa <cpunum>
f010401f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104022:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104028:	b9 11 00 00 00       	mov    $0x11,%ecx
f010402d:	89 c7                	mov    %eax,%edi
f010402f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104031:	e8 74 18 00 00       	call   f01058aa <cpunum>
f0104036:	6b c0 74             	imul   $0x74,%eax,%eax
f0104039:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f010403f:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104045:	8b 46 28             	mov    0x28(%esi),%eax
f0104048:	83 f8 27             	cmp    $0x27,%eax
f010404b:	75 1d                	jne    f010406a <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f010404d:	83 ec 0c             	sub    $0xc,%esp
f0104050:	68 6b 75 10 f0       	push   $0xf010756b
f0104055:	e8 0d f8 ff ff       	call   f0103867 <cprintf>
		print_trapframe(tf);
f010405a:	89 34 24             	mov    %esi,(%esp)
f010405d:	e8 a7 fc ff ff       	call   f0103d09 <print_trapframe>
f0104062:	83 c4 10             	add    $0x10,%esp
f0104065:	e9 91 00 00 00       	jmp    f01040fb <trap+0x1cc>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	switch(tf->tf_trapno){
f010406a:	83 f8 0e             	cmp    $0xe,%eax
f010406d:	74 0c                	je     f010407b <trap+0x14c>
f010406f:	83 f8 30             	cmp    $0x30,%eax
f0104072:	74 23                	je     f0104097 <trap+0x168>
f0104074:	83 f8 03             	cmp    $0x3,%eax
f0104077:	75 3f                	jne    f01040b8 <trap+0x189>
f0104079:	eb 0e                	jmp    f0104089 <trap+0x15a>
		case T_PGFLT:
			page_fault_handler(tf);
f010407b:	83 ec 0c             	sub    $0xc,%esp
f010407e:	56                   	push   %esi
f010407f:	e8 0d fe ff ff       	call   f0103e91 <page_fault_handler>
f0104084:	83 c4 10             	add    $0x10,%esp
f0104087:	eb 72                	jmp    f01040fb <trap+0x1cc>
			return;
		case T_BRKPT:
			//cprintf("Function:trap_dispatch()->T_BRKPT.\n");
			monitor(tf);
f0104089:	83 ec 0c             	sub    $0xc,%esp
f010408c:	56                   	push   %esi
f010408d:	e8 ce c8 ff ff       	call   f0100960 <monitor>
f0104092:	83 c4 10             	add    $0x10,%esp
f0104095:	eb 64                	jmp    f01040fb <trap+0x1cc>
			return;
		case T_SYSCALL:
			//cprintf("Function:trap_dispatch()->T_SYSCALL.\n");
			tf->tf_regs.reg_eax = syscall(
f0104097:	83 ec 08             	sub    $0x8,%esp
f010409a:	ff 76 04             	pushl  0x4(%esi)
f010409d:	ff 36                	pushl  (%esi)
f010409f:	ff 76 10             	pushl  0x10(%esi)
f01040a2:	ff 76 18             	pushl  0x18(%esi)
f01040a5:	ff 76 14             	pushl  0x14(%esi)
f01040a8:	ff 76 1c             	pushl  0x1c(%esi)
f01040ab:	e8 d7 02 00 00       	call   f0104387 <syscall>
f01040b0:	89 46 1c             	mov    %eax,0x1c(%esi)
f01040b3:	83 c4 20             	add    $0x20,%esp
f01040b6:	eb 43                	jmp    f01040fb <trap+0x1cc>
       				 tf->tf_regs.reg_esi
   			 );
  			  return;
		default:break;
	}
	print_trapframe(tf);
f01040b8:	83 ec 0c             	sub    $0xc,%esp
f01040bb:	56                   	push   %esi
f01040bc:	e8 48 fc ff ff       	call   f0103d09 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01040c1:	83 c4 10             	add    $0x10,%esp
f01040c4:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01040c9:	75 17                	jne    f01040e2 <trap+0x1b3>
		panic("unhandled trap in kernel");
f01040cb:	83 ec 04             	sub    $0x4,%esp
f01040ce:	68 88 75 10 f0       	push   $0xf0107588
f01040d3:	68 99 01 00 00       	push   $0x199
f01040d8:	68 3f 75 10 f0       	push   $0xf010753f
f01040dd:	e8 b2 bf ff ff       	call   f0100094 <_panic>
	else {
		env_destroy(curenv);
f01040e2:	e8 c3 17 00 00       	call   f01058aa <cpunum>
f01040e7:	83 ec 0c             	sub    $0xc,%esp
f01040ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ed:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01040f3:	e8 b2 f4 ff ff       	call   f01035aa <env_destroy>
f01040f8:	83 c4 10             	add    $0x10,%esp


	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if(curenv && curenv->env_status == ENV_RUNNING)
f01040fb:	e8 aa 17 00 00       	call   f01058aa <cpunum>
f0104100:	6b c0 74             	imul   $0x74,%eax,%eax
f0104103:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010410a:	74 2a                	je     f0104136 <trap+0x207>
f010410c:	e8 99 17 00 00       	call   f01058aa <cpunum>
f0104111:	6b c0 74             	imul   $0x74,%eax,%eax
f0104114:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010411a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010411e:	75 16                	jne    f0104136 <trap+0x207>
		env_run(curenv);
f0104120:	e8 85 17 00 00       	call   f01058aa <cpunum>
f0104125:	83 ec 0c             	sub    $0xc,%esp
f0104128:	6b c0 74             	imul   $0x74,%eax,%eax
f010412b:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104131:	e8 13 f5 ff ff       	call   f0103649 <env_run>
	else
		sched_yield();
f0104136:	e8 49 01 00 00       	call   f0104284 <sched_yield>
f010413b:	90                   	nop

f010413c <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f010413c:	6a 00                	push   $0x0
f010413e:	6a 00                	push   $0x0
f0104140:	eb 5e                	jmp    f01041a0 <_alltraps>

f0104142 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);        // 1
f0104142:	6a 00                	push   $0x0
f0104144:	6a 01                	push   $0x1
f0104146:	eb 58                	jmp    f01041a0 <_alltraps>

f0104148 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);            // 2
f0104148:	6a 00                	push   $0x0
f010414a:	6a 02                	push   $0x2
f010414c:	eb 52                	jmp    f01041a0 <_alltraps>

f010414e <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)        // 3
f010414e:	6a 00                	push   $0x0
f0104150:	6a 03                	push   $0x3
f0104152:	eb 4c                	jmp    f01041a0 <_alltraps>

f0104154 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)        // 4
f0104154:	6a 00                	push   $0x0
f0104156:	6a 04                	push   $0x4
f0104158:	eb 46                	jmp    f01041a0 <_alltraps>

f010415a <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)        // 5
f010415a:	6a 00                	push   $0x0
f010415c:	6a 05                	push   $0x5
f010415e:	eb 40                	jmp    f01041a0 <_alltraps>

f0104160 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)        // 6
f0104160:	6a 00                	push   $0x0
f0104162:	6a 06                	push   $0x6
f0104164:	eb 3a                	jmp    f01041a0 <_alltraps>

f0104166 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)    // 7
f0104166:	6a 00                	push   $0x0
f0104168:	6a 07                	push   $0x7
f010416a:	eb 34                	jmp    f01041a0 <_alltraps>

f010416c <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)            // 8
f010416c:	6a 08                	push   $0x8
f010416e:	eb 30                	jmp    f01041a0 <_alltraps>

f0104170 <t_tss>:
                                        // 9
TRAPHANDLER(t_tss, T_TSS)                // 10
f0104170:	6a 0a                	push   $0xa
f0104172:	eb 2c                	jmp    f01041a0 <_alltraps>

f0104174 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)            // 11
f0104174:	6a 0b                	push   $0xb
f0104176:	eb 28                	jmp    f01041a0 <_alltraps>

f0104178 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)            // 12
f0104178:	6a 0c                	push   $0xc
f010417a:	eb 24                	jmp    f01041a0 <_alltraps>

f010417c <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)            // 13
f010417c:	6a 0d                	push   $0xd
f010417e:	eb 20                	jmp    f01041a0 <_alltraps>

f0104180 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)            // 14
f0104180:	6a 0e                	push   $0xe
f0104182:	eb 1c                	jmp    f01041a0 <_alltraps>

f0104184 <t_fperr>:
                                        // 15
TRAPHANDLER_NOEC(t_fperr, T_FPERR)        // 16
f0104184:	6a 00                	push   $0x0
f0104186:	6a 10                	push   $0x10
f0104188:	eb 16                	jmp    f01041a0 <_alltraps>

f010418a <t_align>:
TRAPHANDLER(t_align, T_ALIGN)            // 17
f010418a:	6a 11                	push   $0x11
f010418c:	eb 12                	jmp    f01041a0 <_alltraps>

f010418e <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)        // 18
f010418e:	6a 00                	push   $0x0
f0104190:	6a 12                	push   $0x12
f0104192:	eb 0c                	jmp    f01041a0 <_alltraps>

f0104194 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)    // 19
f0104194:	6a 00                	push   $0x0
f0104196:	6a 13                	push   $0x13
f0104198:	eb 06                	jmp    f01041a0 <_alltraps>

f010419a <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f010419a:	6a 00                	push   $0x0
f010419c:	6a 30                	push   $0x30
f010419e:	eb 00                	jmp    f01041a0 <_alltraps>

f01041a0 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01041a0:	1e                   	push   %ds
	pushl %es
f01041a1:	06                   	push   %es
	pushal
f01041a2:	60                   	pusha  

	movw $GD_KD,%eax
f01041a3:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax,%ds
f01041a7:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f01041a9:	8e c0                	mov    %eax,%es

	pushl %esp
f01041ab:	54                   	push   %esp
	call trap
f01041ac:	e8 7e fd ff ff       	call   f0103f2f <trap>

f01041b1 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01041b1:	55                   	push   %ebp
f01041b2:	89 e5                	mov    %esp,%ebp
f01041b4:	83 ec 08             	sub    $0x8,%esp
f01041b7:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01041bc:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041bf:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01041c4:	8b 02                	mov    (%edx),%eax
f01041c6:	83 e8 01             	sub    $0x1,%eax
f01041c9:	83 f8 02             	cmp    $0x2,%eax
f01041cc:	76 10                	jbe    f01041de <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041ce:	83 c1 01             	add    $0x1,%ecx
f01041d1:	83 c2 7c             	add    $0x7c,%edx
f01041d4:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041da:	75 e8                	jne    f01041c4 <sched_halt+0x13>
f01041dc:	eb 08                	jmp    f01041e6 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01041de:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041e4:	75 1f                	jne    f0104205 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01041e6:	83 ec 0c             	sub    $0xc,%esp
f01041e9:	68 90 77 10 f0       	push   $0xf0107790
f01041ee:	e8 74 f6 ff ff       	call   f0103867 <cprintf>
f01041f3:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01041f6:	83 ec 0c             	sub    $0xc,%esp
f01041f9:	6a 00                	push   $0x0
f01041fb:	e8 60 c7 ff ff       	call   f0100960 <monitor>
f0104200:	83 c4 10             	add    $0x10,%esp
f0104203:	eb f1                	jmp    f01041f6 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104205:	e8 a0 16 00 00       	call   f01058aa <cpunum>
f010420a:	6b c0 74             	imul   $0x74,%eax,%eax
f010420d:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104214:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104217:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010421c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104221:	77 12                	ja     f0104235 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104223:	50                   	push   %eax
f0104224:	68 2c 60 10 f0       	push   $0xf010602c
f0104229:	6a 6c                	push   $0x6c
f010422b:	68 b9 77 10 f0       	push   $0xf01077b9
f0104230:	e8 5f be ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104235:	05 00 00 00 10       	add    $0x10000000,%eax
f010423a:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010423d:	e8 68 16 00 00       	call   f01058aa <cpunum>
f0104242:	6b d0 74             	imul   $0x74,%eax,%edx
f0104245:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010424b:	b8 02 00 00 00       	mov    $0x2,%eax
f0104250:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104254:	83 ec 0c             	sub    $0xc,%esp
f0104257:	68 c0 03 12 f0       	push   $0xf01203c0
f010425c:	e8 54 19 00 00       	call   f0105bb5 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104261:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104263:	e8 42 16 00 00       	call   f01058aa <cpunum>
f0104268:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010426b:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104271:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104276:	89 c4                	mov    %eax,%esp
f0104278:	6a 00                	push   $0x0
f010427a:	6a 00                	push   $0x0
f010427c:	f4                   	hlt    
f010427d:	eb fd                	jmp    f010427c <sched_halt+0xcb>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010427f:	83 c4 10             	add    $0x10,%esp
f0104282:	c9                   	leave  
f0104283:	c3                   	ret    

f0104284 <sched_yield>:
};
*/
// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104284:	55                   	push   %ebp
f0104285:	89 e5                	mov    %esp,%ebp
f0104287:	56                   	push   %esi
f0104288:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
f0104289:	83 ec 0c             	sub    $0xc,%esp
f010428c:	68 c6 77 10 f0       	push   $0xf01077c6
f0104291:	e8 d1 f5 ff ff       	call   f0103867 <cprintf>
	int running_env_id = -1;
	if(curenv == 0){
f0104296:	e8 0f 16 00 00       	call   f01058aa <cpunum>
f010429b:	6b c0 74             	imul   $0x74,%eax,%eax
f010429e:	83 c4 10             	add    $0x10,%esp
		running_env_id = -1;
f01042a1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
	int running_env_id = -1;
	if(curenv == 0){
f01042a6:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01042ad:	74 17                	je     f01042c6 <sched_yield+0x42>
		running_env_id = -1;
	}else{
		running_env_id = ENVX(curenv->env_id);
f01042af:	e8 f6 15 00 00       	call   f01058aa <cpunum>
f01042b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b7:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01042bd:	8b 58 48             	mov    0x48(%eax),%ebx
f01042c0:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	}
	//cprintf("the real running env_id:%d\n",ENVX(curenv->env_id));
	cprintf("The running_env_id is:%d\n",running_env_id);
f01042c6:	83 ec 08             	sub    $0x8,%esp
f01042c9:	53                   	push   %ebx
f01042ca:	68 dc 77 10 f0       	push   $0xf01077dc
f01042cf:	e8 93 f5 ff ff       	call   f0103867 <cprintf>
			running_env_id = 0;
		}else{
			running_env_id++;
		}

		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f01042d4:	8b 0d 44 b2 22 f0    	mov    0xf022b244,%ecx
f01042da:	83 c4 10             	add    $0x10,%esp
	}else{
		running_env_id = ENVX(curenv->env_id);
	}
	//cprintf("the real running env_id:%d\n",ENVX(curenv->env_id));
	cprintf("The running_env_id is:%d\n",running_env_id);
	for(int i = 0;i<NENV;i++){
f01042dd:	be 00 00 00 00       	mov    $0x0,%esi

		if(running_env_id == NENV-1){
			running_env_id = 0;
		}else{
			running_env_id++;
f01042e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01042e7:	8d 43 01             	lea    0x1(%ebx),%eax
f01042ea:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f01042f0:	0f 44 c2             	cmove  %edx,%eax
f01042f3:	89 c3                	mov    %eax,%ebx
		}

		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f01042f5:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01042f8:	83 7c 01 54 02       	cmpl   $0x2,0x54(%ecx,%eax,1)
f01042fd:	75 29                	jne    f0104328 <sched_yield+0xa4>
			cprintf("shed_yield():WE ARE RUNNING.\n");
f01042ff:	83 ec 0c             	sub    $0xc,%esp
f0104302:	68 f6 77 10 f0       	push   $0xf01077f6
f0104307:	e8 5b f5 ff ff       	call   f0103867 <cprintf>
			cprintf("the running i is:%d\n",i);
f010430c:	83 c4 08             	add    $0x8,%esp
f010430f:	56                   	push   %esi
f0104310:	68 14 78 10 f0       	push   $0xf0107814
f0104315:	e8 4d f5 ff ff       	call   f0103867 <cprintf>
			env_run(&envs[0]);
f010431a:	83 c4 04             	add    $0x4,%esp
f010431d:	ff 35 44 b2 22 f0    	pushl  0xf022b244
f0104323:	e8 21 f3 ff ff       	call   f0103649 <env_run>
	}else{
		running_env_id = ENVX(curenv->env_id);
	}
	//cprintf("the real running env_id:%d\n",ENVX(curenv->env_id));
	cprintf("The running_env_id is:%d\n",running_env_id);
	for(int i = 0;i<NENV;i++){
f0104328:	83 c6 01             	add    $0x1,%esi
f010432b:	81 fe 00 04 00 00    	cmp    $0x400,%esi
f0104331:	75 b4                	jne    f01042e7 <sched_yield+0x63>
	}
	//if the code run here,it says that there is only one env which is
	//running but now and here we are in kern mode,so if we don't chose
	//the running env to run we will trap in sched_halt().AND WE ARE AT
	//KERNEL MODE!
	if(curenv && curenv->env_status == ENV_RUNNING){
f0104333:	e8 72 15 00 00       	call   f01058aa <cpunum>
f0104338:	6b c0 74             	imul   $0x74,%eax,%eax
f010433b:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104342:	74 37                	je     f010437b <sched_yield+0xf7>
f0104344:	e8 61 15 00 00       	call   f01058aa <cpunum>
f0104349:	6b c0 74             	imul   $0x74,%eax,%eax
f010434c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104352:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104356:	75 23                	jne    f010437b <sched_yield+0xf7>
		cprintf("I AM THE ONLY ONE ENV.\n");
f0104358:	83 ec 0c             	sub    $0xc,%esp
f010435b:	68 29 78 10 f0       	push   $0xf0107829
f0104360:	e8 02 f5 ff ff       	call   f0103867 <cprintf>
		env_run(curenv);
f0104365:	e8 40 15 00 00       	call   f01058aa <cpunum>
f010436a:	83 c4 04             	add    $0x4,%esp
f010436d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104370:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104376:	e8 ce f2 ff ff       	call   f0103649 <env_run>
		return;
	}
	// sched_halt never returns
	sched_halt();
f010437b:	e8 31 fe ff ff       	call   f01041b1 <sched_halt>
}
f0104380:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104383:	5b                   	pop    %ebx
f0104384:	5e                   	pop    %esi
f0104385:	5d                   	pop    %ebp
f0104386:	c3                   	ret    

f0104387 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104387:	55                   	push   %ebp
f0104388:	89 e5                	mov    %esp,%ebp
f010438a:	53                   	push   %ebx
f010438b:	83 ec 14             	sub    $0x14,%esp
f010438e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
f0104391:	83 f8 0a             	cmp    $0xa,%eax
f0104394:	0f 87 46 04 00 00    	ja     f01047e0 <syscall+0x459>
f010439a:	ff 24 85 9c 78 10 f0 	jmp    *-0xfef8764(,%eax,4)
	// LAB 3: Your code here.


	struct Env *e;
	//envid2env(sys_getenvid(), &e, 1);
	user_mem_assert(curenv, s, len, PTE_U);
f01043a1:	e8 04 15 00 00       	call   f01058aa <cpunum>
f01043a6:	6a 04                	push   $0x4
f01043a8:	ff 75 10             	pushl  0x10(%ebp)
f01043ab:	ff 75 0c             	pushl  0xc(%ebp)
f01043ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b1:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01043b7:	e8 e6 ea ff ff       	call   f0102ea2 <user_mem_assert>

	cprintf("%.*s", len, s);
f01043bc:	83 c4 0c             	add    $0xc,%esp
f01043bf:	ff 75 0c             	pushl  0xc(%ebp)
f01043c2:	ff 75 10             	pushl  0x10(%ebp)
f01043c5:	68 41 78 10 f0       	push   $0xf0107841
f01043ca:	e8 98 f4 ff ff       	call   f0103867 <cprintf>
f01043cf:	83 c4 10             	add    $0x10,%esp
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01043d2:	e8 87 c2 ff ff       	call   f010065e <cons_getc>
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
       	       case SYS_cputs:
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
f01043d7:	e9 09 04 00 00       	jmp    f01047e5 <syscall+0x45e>
       	       case SYS_getenvid:
           		 assert(curenv);
f01043dc:	e8 c9 14 00 00       	call   f01058aa <cpunum>
f01043e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e4:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01043eb:	75 19                	jne    f0104406 <syscall+0x7f>
f01043ed:	68 64 75 10 f0       	push   $0xf0107564
f01043f2:	68 67 6f 10 f0       	push   $0xf0106f67
f01043f7:	68 80 01 00 00       	push   $0x180
f01043fc:	68 46 78 10 f0       	push   $0xf0107846
f0104401:	e8 8e bc ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104406:	e8 9f 14 00 00       	call   f01058aa <cpunum>
f010440b:	6b c0 74             	imul   $0x74,%eax,%eax
f010440e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104414:	8b 40 48             	mov    0x48(%eax),%eax
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
       	       case SYS_getenvid:
           		 assert(curenv);
            		return sys_getenvid();
f0104417:	e9 c9 03 00 00       	jmp    f01047e5 <syscall+0x45e>
       	       case SYS_env_destroy:
          		  assert(curenv);
f010441c:	e8 89 14 00 00       	call   f01058aa <cpunum>
f0104421:	6b c0 74             	imul   $0x74,%eax,%eax
f0104424:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010442b:	75 19                	jne    f0104446 <syscall+0xbf>
f010442d:	68 64 75 10 f0       	push   $0xf0107564
f0104432:	68 67 6f 10 f0       	push   $0xf0106f67
f0104437:	68 83 01 00 00       	push   $0x183
f010443c:	68 46 78 10 f0       	push   $0xf0107846
f0104441:	e8 4e bc ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104446:	e8 5f 14 00 00       	call   f01058aa <cpunum>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010444b:	83 ec 04             	sub    $0x4,%esp
f010444e:	6a 01                	push   $0x1
f0104450:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0104453:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104454:	6b c0 74             	imul   $0x74,%eax,%eax
f0104457:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010445d:	ff 70 48             	pushl  0x48(%eax)
f0104460:	e8 19 eb ff ff       	call   f0102f7e <envid2env>
f0104465:	83 c4 10             	add    $0x10,%esp
f0104468:	85 c0                	test   %eax,%eax
f010446a:	0f 88 75 03 00 00    	js     f01047e5 <syscall+0x45e>
		return r;
	if (e == curenv)
f0104470:	e8 35 14 00 00       	call   f01058aa <cpunum>
f0104475:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104478:	6b c0 74             	imul   $0x74,%eax,%eax
f010447b:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0104481:	75 23                	jne    f01044a6 <syscall+0x11f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104483:	e8 22 14 00 00       	call   f01058aa <cpunum>
f0104488:	83 ec 08             	sub    $0x8,%esp
f010448b:	6b c0 74             	imul   $0x74,%eax,%eax
f010448e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104494:	ff 70 48             	pushl  0x48(%eax)
f0104497:	68 55 78 10 f0       	push   $0xf0107855
f010449c:	e8 c6 f3 ff ff       	call   f0103867 <cprintf>
f01044a1:	83 c4 10             	add    $0x10,%esp
f01044a4:	eb 25                	jmp    f01044cb <syscall+0x144>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01044a6:	8b 5a 48             	mov    0x48(%edx),%ebx
f01044a9:	e8 fc 13 00 00       	call   f01058aa <cpunum>
f01044ae:	83 ec 04             	sub    $0x4,%esp
f01044b1:	53                   	push   %ebx
f01044b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01044b5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044bb:	ff 70 48             	pushl  0x48(%eax)
f01044be:	68 70 78 10 f0       	push   $0xf0107870
f01044c3:	e8 9f f3 ff ff       	call   f0103867 <cprintf>
f01044c8:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01044cb:	83 ec 0c             	sub    $0xc,%esp
f01044ce:	ff 75 f4             	pushl  -0xc(%ebp)
f01044d1:	e8 d4 f0 ff ff       	call   f01035aa <env_destroy>
f01044d6:	83 c4 10             	add    $0x10,%esp
	return 0;
f01044d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01044de:	e9 02 03 00 00       	jmp    f01047e5 <syscall+0x45e>
            		return sys_getenvid();
       	       case SYS_env_destroy:
          		  assert(curenv);
            		return sys_env_destroy(sys_getenvid());
	       case SYS_yield:
			assert(curenv);
f01044e3:	e8 c2 13 00 00       	call   f01058aa <cpunum>
f01044e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01044eb:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01044f2:	75 19                	jne    f010450d <syscall+0x186>
f01044f4:	68 64 75 10 f0       	push   $0xf0107564
f01044f9:	68 67 6f 10 f0       	push   $0xf0106f67
f01044fe:	68 86 01 00 00       	push   $0x186
f0104503:	68 46 78 10 f0       	push   $0xf0107846
f0104508:	e8 87 bb ff ff       	call   f0100094 <_panic>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010450d:	e8 72 fd ff ff       	call   f0104284 <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env * newenv_store;
	if(curenv->env_id == 0)
f0104512:	e8 93 13 00 00       	call   f01058aa <cpunum>
f0104517:	6b c0 74             	imul   $0x74,%eax,%eax
f010451a:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104520:	8b 40 48             	mov    0x48(%eax),%eax
f0104523:	85 c0                	test   %eax,%eax
f0104525:	0f 84 ba 02 00 00    	je     f01047e5 <syscall+0x45e>
		return 0;
	int r_env_alloc = env_alloc(&newenv_store,curenv->env_id);
f010452b:	e8 7a 13 00 00       	call   f01058aa <cpunum>
f0104530:	83 ec 08             	sub    $0x8,%esp
f0104533:	6b c0 74             	imul   $0x74,%eax,%eax
f0104536:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010453c:	ff 70 48             	pushl  0x48(%eax)
f010453f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104542:	50                   	push   %eax
f0104543:	e8 9a eb ff ff       	call   f01030e2 <env_alloc>
	
	if(r_env_alloc<0)
f0104548:	83 c4 10             	add    $0x10,%esp
f010454b:	85 c0                	test   %eax,%eax
f010454d:	0f 88 92 02 00 00    	js     f01047e5 <syscall+0x45e>
		return r_env_alloc;
	
	newenv_store->env_status = ENV_NOT_RUNNABLE;
f0104553:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104556:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove(&newenv_store->env_tf,&curenv->env_tf,sizeof(curenv->env_tf));
f010455d:	e8 48 13 00 00       	call   f01058aa <cpunum>
f0104562:	83 ec 04             	sub    $0x4,%esp
f0104565:	6a 44                	push   $0x44
f0104567:	6b c0 74             	imul   $0x74,%eax,%eax
f010456a:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104570:	ff 75 f4             	pushl  -0xc(%ebp)
f0104573:	e8 5e 0d 00 00       	call   f01052d6 <memmove>
	newenv_store->env_tf.tf_regs.reg_eax =0;
f0104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010457b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv_store->env_id;
f0104582:	8b 40 48             	mov    0x48(%eax),%eax
f0104585:	83 c4 10             	add    $0x10,%esp
f0104588:	e9 58 02 00 00       	jmp    f01047e5 <syscall+0x45e>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f010458d:	83 ec 04             	sub    $0x4,%esp
f0104590:	6a 01                	push   $0x1
f0104592:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104595:	50                   	push   %eax
f0104596:	ff 75 0c             	pushl  0xc(%ebp)
f0104599:	e8 e0 e9 ff ff       	call   f0102f7e <envid2env>
	if(r_value)
f010459e:	83 c4 10             	add    $0x10,%esp
f01045a1:	85 c0                	test   %eax,%eax
f01045a3:	0f 85 3c 02 00 00    	jne    f01047e5 <syscall+0x45e>
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f01045a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01045ac:	83 e8 02             	sub    $0x2,%eax
f01045af:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01045b4:	75 13                	jne    f01045c9 <syscall+0x242>
		return -E_INVAL;
	newenv_store->env_status = status;
f01045b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01045bc:	89 58 54             	mov    %ebx,0x54(%eax)

	return 0;
f01045bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01045c4:	e9 1c 02 00 00       	jmp    f01047e5 <syscall+0x45e>
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f01045c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			sys_yield();
			return 1;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f01045ce:	e9 12 02 00 00       	jmp    f01047e5 <syscall+0x45e>
	//   allocated!

	// LAB 4: Your code here.
//	cprintf("the kernel env index is:%d\n",ENVX(curenv->env_id));
	struct Env *newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01045d3:	83 ec 04             	sub    $0x4,%esp
f01045d6:	6a 01                	push   $0x1
f01045d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045db:	50                   	push   %eax
f01045dc:	ff 75 0c             	pushl  0xc(%ebp)
f01045df:	e8 9a e9 ff ff       	call   f0102f7e <envid2env>
	if(r_value)
f01045e4:	83 c4 10             	add    $0x10,%esp
f01045e7:	85 c0                	test   %eax,%eax
f01045e9:	0f 85 f6 01 00 00    	jne    f01047e5 <syscall+0x45e>
		return r_value;
	cprintf("after envid2env().\n");
f01045ef:	83 ec 0c             	sub    $0xc,%esp
f01045f2:	68 88 78 10 f0       	push   $0xf0107888
f01045f7:	e8 6b f2 ff ff       	call   f0103867 <cprintf>
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
f01045fc:	83 c4 10             	add    $0x10,%esp
f01045ff:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104606:	77 56                	ja     f010465e <syscall+0x2d7>
f0104608:	8b 45 10             	mov    0x10(%ebp),%eax
f010460b:	c1 e0 14             	shl    $0x14,%eax
f010460e:	85 c0                	test   %eax,%eax
f0104610:	75 56                	jne    f0104668 <syscall+0x2e1>
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104612:	8b 55 14             	mov    0x14(%ebp),%edx
f0104615:	83 e2 fd             	and    $0xfffffffd,%edx
f0104618:	83 fa 05             	cmp    $0x5,%edx
f010461b:	74 11                	je     f010462e <syscall+0x2a7>
		return -E_INVAL;
f010461d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104622:	81 fa 05 0e 00 00    	cmp    $0xe05,%edx
f0104628:	0f 85 b7 01 00 00    	jne    f01047e5 <syscall+0x45e>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
f010462e:	83 ec 0c             	sub    $0xc,%esp
f0104631:	6a 00                	push   $0x0
f0104633:	e8 46 c9 ff ff       	call   f0100f7e <page_alloc>
	if(!pp)
f0104638:	83 c4 10             	add    $0x10,%esp
f010463b:	85 c0                	test   %eax,%eax
f010463d:	74 33                	je     f0104672 <syscall+0x2eb>
		return -E_NO_MEM;

	int ret = page_insert(newenv_store->env_pgdir,pp,va,perm);	
f010463f:	ff 75 14             	pushl  0x14(%ebp)
f0104642:	ff 75 10             	pushl  0x10(%ebp)
f0104645:	50                   	push   %eax
f0104646:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104649:	ff 70 60             	pushl  0x60(%eax)
f010464c:	e8 1c cd ff ff       	call   f010136d <page_insert>
f0104651:	83 c4 10             	add    $0x10,%esp
	if(!ret)
		return ret;
	return 0;
f0104654:	b8 00 00 00 00       	mov    $0x0,%eax
f0104659:	e9 87 01 00 00       	jmp    f01047e5 <syscall+0x45e>
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
		return -E_INVAL;
f010465e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104663:	e9 7d 01 00 00       	jmp    f01047e5 <syscall+0x45e>
f0104668:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010466d:	e9 73 01 00 00       	jmp    f01047e5 <syscall+0x45e>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
	if(!pp)
		return -E_NO_MEM;
f0104672:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104677:	e9 69 01 00 00       	jmp    f01047e5 <syscall+0x45e>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
f010467c:	83 ec 04             	sub    $0x4,%esp
f010467f:	6a 01                	push   $0x1
f0104681:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104684:	50                   	push   %eax
f0104685:	ff 75 0c             	pushl  0xc(%ebp)
f0104688:	e8 f1 e8 ff ff       	call   f0102f7e <envid2env>
f010468d:	89 c3                	mov    %eax,%ebx
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
f010468f:	83 c4 0c             	add    $0xc,%esp
f0104692:	6a 01                	push   $0x1
f0104694:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0104697:	50                   	push   %eax
f0104698:	ff 75 14             	pushl  0x14(%ebp)
f010469b:	e8 de e8 ff ff       	call   f0102f7e <envid2env>
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
f01046a0:	83 c4 10             	add    $0x10,%esp
f01046a3:	83 fb fe             	cmp    $0xfffffffe,%ebx
f01046a6:	0f 84 ab 00 00 00    	je     f0104757 <syscall+0x3d0>
f01046ac:	83 f8 fe             	cmp    $0xfffffffe,%eax
f01046af:	0f 84 a2 00 00 00    	je     f0104757 <syscall+0x3d0>
		return -E_BAD_ENV;
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
f01046b5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046bc:	0f 87 9f 00 00 00    	ja     f0104761 <syscall+0x3da>
f01046c2:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01046c9:	0f 87 92 00 00 00    	ja     f0104761 <syscall+0x3da>
		return -E_INVAL;

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
f01046cf:	8b 45 10             	mov    0x10(%ebp),%eax
f01046d2:	c1 e0 14             	shl    $0x14,%eax
f01046d5:	85 c0                	test   %eax,%eax
f01046d7:	0f 85 8b 00 00 00    	jne    f0104768 <syscall+0x3e1>
f01046dd:	8b 45 18             	mov    0x18(%ebp),%eax
f01046e0:	c1 e0 14             	shl    $0x14,%eax
f01046e3:	85 c0                	test   %eax,%eax
f01046e5:	0f 85 84 00 00 00    	jne    f010476f <syscall+0x3e8>
		return -E_INVAL;

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
f01046eb:	83 ec 04             	sub    $0x4,%esp
f01046ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01046f1:	50                   	push   %eax
f01046f2:	ff 75 10             	pushl  0x10(%ebp)
f01046f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01046f8:	ff 70 60             	pushl  0x60(%eax)
f01046fb:	e8 8d cb ff ff       	call   f010128d <page_lookup>
f0104700:	89 c2                	mov    %eax,%edx
	if(!pp)
f0104702:	83 c4 10             	add    $0x10,%esp
f0104705:	85 c0                	test   %eax,%eax
f0104707:	74 6d                	je     f0104776 <syscall+0x3ef>

	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104709:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f010470c:	83 e1 fd             	and    $0xfffffffd,%ecx
f010470f:	83 f9 05             	cmp    $0x5,%ecx
f0104712:	74 11                	je     f0104725 <syscall+0x39e>
		return -E_INVAL;
f0104714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104719:	81 f9 05 0e 00 00    	cmp    $0xe05,%ecx
f010471f:	0f 85 c0 00 00 00    	jne    f01047e5 <syscall+0x45e>
		return -E_INVAL;

	if(perm&PTE_W && !((*pte_store)&PTE_W))
f0104725:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104729:	74 08                	je     f0104733 <syscall+0x3ac>
f010472b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010472e:	f6 00 02             	testb  $0x2,(%eax)
f0104731:	74 4a                	je     f010477d <syscall+0x3f6>
		return -E_INVAL;


	if(page_insert(newenv_store_dst->env_pgdir,pp,dstva,perm))
f0104733:	ff 75 1c             	pushl  0x1c(%ebp)
f0104736:	ff 75 18             	pushl  0x18(%ebp)
f0104739:	52                   	push   %edx
f010473a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010473d:	ff 70 60             	pushl  0x60(%eax)
f0104740:	e8 28 cc ff ff       	call   f010136d <page_insert>
f0104745:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104748:	85 c0                	test   %eax,%eax
f010474a:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f010474f:	0f 45 c2             	cmovne %edx,%eax
f0104752:	e9 8e 00 00 00       	jmp    f01047e5 <syscall+0x45e>
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
		return -E_BAD_ENV;
f0104757:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010475c:	e9 84 00 00 00       	jmp    f01047e5 <syscall+0x45e>
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
		return -E_INVAL;
f0104761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104766:	eb 7d                	jmp    f01047e5 <syscall+0x45e>

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
		return -E_INVAL;
f0104768:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010476d:	eb 76                	jmp    f01047e5 <syscall+0x45e>
f010476f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104774:	eb 6f                	jmp    f01047e5 <syscall+0x45e>

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
	if(!pp)
		return -E_INVAL;
f0104776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010477b:	eb 68                	jmp    f01047e5 <syscall+0x45e>
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
		return -E_INVAL;

	if(perm&PTE_W && !((*pte_store)&PTE_W))
		return -E_INVAL;
f010477d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104782:	eb 61                	jmp    f01047e5 <syscall+0x45e>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f0104784:	83 ec 04             	sub    $0x4,%esp
f0104787:	6a 01                	push   $0x1
f0104789:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010478c:	50                   	push   %eax
f010478d:	ff 75 0c             	pushl  0xc(%ebp)
f0104790:	e8 e9 e7 ff ff       	call   f0102f7e <envid2env>
	if(r_value == -E_BAD_ENV)
f0104795:	83 c4 10             	add    $0x10,%esp
f0104798:	83 f8 fe             	cmp    $0xfffffffe,%eax
f010479b:	74 2e                	je     f01047cb <syscall+0x444>
		return -E_BAD_ENV;
	
	if(va>=(void*)UTOP)
f010479d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047a4:	77 2c                	ja     f01047d2 <syscall+0x44b>
		return -E_INVAL;

	if(((unsigned int)va<<20))
f01047a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01047a9:	c1 e0 14             	shl    $0x14,%eax
f01047ac:	85 c0                	test   %eax,%eax
f01047ae:	75 29                	jne    f01047d9 <syscall+0x452>
		return -E_INVAL;

	page_remove(newenv_store->env_pgdir,va);
f01047b0:	83 ec 08             	sub    $0x8,%esp
f01047b3:	ff 75 10             	pushl  0x10(%ebp)
f01047b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047b9:	ff 70 60             	pushl  0x60(%eax)
f01047bc:	e8 66 cb ff ff       	call   f0101327 <page_remove>
f01047c1:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f01047c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01047c9:	eb 1a                	jmp    f01047e5 <syscall+0x45e>
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value == -E_BAD_ENV)
		return -E_BAD_ENV;
f01047cb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01047d0:	eb 13                	jmp    f01047e5 <syscall+0x45e>
	
	if(va>=(void*)UTOP)
		return -E_INVAL;
f01047d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047d7:	eb 0c                	jmp    f01047e5 <syscall+0x45e>

	if(((unsigned int)va<<20))
		return -E_INVAL;
f01047d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
f01047de:	eb 05                	jmp    f01047e5 <syscall+0x45e>
		default:
			return -E_INVAL;
f01047e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01047e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01047e8:	c9                   	leave  
f01047e9:	c3                   	ret    

f01047ea <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01047ea:	55                   	push   %ebp
f01047eb:	89 e5                	mov    %esp,%ebp
f01047ed:	57                   	push   %edi
f01047ee:	56                   	push   %esi
f01047ef:	53                   	push   %ebx
f01047f0:	83 ec 14             	sub    $0x14,%esp
f01047f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01047f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01047fc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01047ff:	8b 1a                	mov    (%edx),%ebx
f0104801:	8b 01                	mov    (%ecx),%eax
f0104803:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104806:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010480d:	eb 7f                	jmp    f010488e <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010480f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104812:	01 d8                	add    %ebx,%eax
f0104814:	89 c6                	mov    %eax,%esi
f0104816:	c1 ee 1f             	shr    $0x1f,%esi
f0104819:	01 c6                	add    %eax,%esi
f010481b:	d1 fe                	sar    %esi
f010481d:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104820:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104823:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104826:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104828:	eb 03                	jmp    f010482d <stab_binsearch+0x43>
			m--;
f010482a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010482d:	39 c3                	cmp    %eax,%ebx
f010482f:	7f 0d                	jg     f010483e <stab_binsearch+0x54>
f0104831:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104835:	83 ea 0c             	sub    $0xc,%edx
f0104838:	39 f9                	cmp    %edi,%ecx
f010483a:	75 ee                	jne    f010482a <stab_binsearch+0x40>
f010483c:	eb 05                	jmp    f0104843 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010483e:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104841:	eb 4b                	jmp    f010488e <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104843:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104846:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104849:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010484d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104850:	76 11                	jbe    f0104863 <stab_binsearch+0x79>
			*region_left = m;
f0104852:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104855:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104857:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010485a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104861:	eb 2b                	jmp    f010488e <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104863:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104866:	73 14                	jae    f010487c <stab_binsearch+0x92>
			*region_right = m - 1;
f0104868:	83 e8 01             	sub    $0x1,%eax
f010486b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010486e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104871:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104873:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010487a:	eb 12                	jmp    f010488e <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010487c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010487f:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104881:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104885:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104887:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010488e:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104891:	0f 8e 78 ff ff ff    	jle    f010480f <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104897:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010489b:	75 0f                	jne    f01048ac <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010489d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048a0:	8b 00                	mov    (%eax),%eax
f01048a2:	83 e8 01             	sub    $0x1,%eax
f01048a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048a8:	89 06                	mov    %eax,(%esi)
f01048aa:	eb 2c                	jmp    f01048d8 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048af:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01048b1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01048b4:	8b 0e                	mov    (%esi),%ecx
f01048b6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01048b9:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01048bc:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048bf:	eb 03                	jmp    f01048c4 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01048c1:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048c4:	39 c8                	cmp    %ecx,%eax
f01048c6:	7e 0b                	jle    f01048d3 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01048c8:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01048cc:	83 ea 0c             	sub    $0xc,%edx
f01048cf:	39 df                	cmp    %ebx,%edi
f01048d1:	75 ee                	jne    f01048c1 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01048d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01048d6:	89 06                	mov    %eax,(%esi)
	}
}
f01048d8:	83 c4 14             	add    $0x14,%esp
f01048db:	5b                   	pop    %ebx
f01048dc:	5e                   	pop    %esi
f01048dd:	5f                   	pop    %edi
f01048de:	5d                   	pop    %ebp
f01048df:	c3                   	ret    

f01048e0 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01048e0:	55                   	push   %ebp
f01048e1:	89 e5                	mov    %esp,%ebp
f01048e3:	57                   	push   %edi
f01048e4:	56                   	push   %esi
f01048e5:	53                   	push   %ebx
f01048e6:	83 ec 2c             	sub    $0x2c,%esp
f01048e9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01048ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01048ef:	c7 06 c8 78 10 f0    	movl   $0xf01078c8,(%esi)
	info->eip_line = 0;
f01048f5:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01048fc:	c7 46 08 c8 78 10 f0 	movl   $0xf01078c8,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104903:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010490a:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010490d:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104914:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010491a:	77 21                	ja     f010493d <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010491c:	a1 00 00 20 00       	mov    0x200000,%eax
f0104921:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0104924:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104929:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f010492f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f0104932:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104938:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010493b:	eb 1a                	jmp    f0104957 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010493d:	c7 45 d0 44 55 11 f0 	movl   $0xf0115544,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104944:	c7 45 cc c9 1d 11 f0 	movl   $0xf0111dc9,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f010494b:	b8 c8 1d 11 f0       	mov    $0xf0111dc8,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104950:	c7 45 d4 b4 7d 10 f0 	movl   $0xf0107db4,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104957:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010495a:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010495d:	0f 83 2b 01 00 00    	jae    f0104a8e <debuginfo_eip+0x1ae>
f0104963:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104967:	0f 85 28 01 00 00    	jne    f0104a95 <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010496d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104974:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104977:	29 d8                	sub    %ebx,%eax
f0104979:	c1 f8 02             	sar    $0x2,%eax
f010497c:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104982:	83 e8 01             	sub    $0x1,%eax
f0104985:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104988:	57                   	push   %edi
f0104989:	6a 64                	push   $0x64
f010498b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010498e:	89 c1                	mov    %eax,%ecx
f0104990:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104993:	89 d8                	mov    %ebx,%eax
f0104995:	e8 50 fe ff ff       	call   f01047ea <stab_binsearch>
	if (lfile == 0)
f010499a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010499d:	83 c4 08             	add    $0x8,%esp
f01049a0:	85 c0                	test   %eax,%eax
f01049a2:	0f 84 f4 00 00 00    	je     f0104a9c <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01049a8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01049ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01049b1:	57                   	push   %edi
f01049b2:	6a 24                	push   $0x24
f01049b4:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01049b7:	89 c1                	mov    %eax,%ecx
f01049b9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01049bc:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01049bf:	89 d8                	mov    %ebx,%eax
f01049c1:	e8 24 fe ff ff       	call   f01047ea <stab_binsearch>

	if (lfun <= rfun) {
f01049c6:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01049c9:	83 c4 08             	add    $0x8,%esp
f01049cc:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01049cf:	7f 24                	jg     f01049f5 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01049d1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01049d4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01049d7:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01049da:	8b 02                	mov    (%edx),%eax
f01049dc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01049df:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01049e2:	29 f9                	sub    %edi,%ecx
f01049e4:	39 c8                	cmp    %ecx,%eax
f01049e6:	73 05                	jae    f01049ed <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01049e8:	01 f8                	add    %edi,%eax
f01049ea:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01049ed:	8b 42 08             	mov    0x8(%edx),%eax
f01049f0:	89 46 10             	mov    %eax,0x10(%esi)
f01049f3:	eb 06                	jmp    f01049fb <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01049f5:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01049f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01049fb:	83 ec 08             	sub    $0x8,%esp
f01049fe:	6a 3a                	push   $0x3a
f0104a00:	ff 76 08             	pushl  0x8(%esi)
f0104a03:	e8 65 08 00 00       	call   f010526d <strfind>
f0104a08:	2b 46 08             	sub    0x8(%esi),%eax
f0104a0b:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a11:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a14:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104a17:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104a1a:	83 c4 10             	add    $0x10,%esp
f0104a1d:	eb 06                	jmp    f0104a25 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104a1f:	83 eb 01             	sub    $0x1,%ebx
f0104a22:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a25:	39 fb                	cmp    %edi,%ebx
f0104a27:	7c 2d                	jl     f0104a56 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104a29:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104a2d:	80 fa 84             	cmp    $0x84,%dl
f0104a30:	74 0b                	je     f0104a3d <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a32:	80 fa 64             	cmp    $0x64,%dl
f0104a35:	75 e8                	jne    f0104a1f <debuginfo_eip+0x13f>
f0104a37:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104a3b:	74 e2                	je     f0104a1f <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104a3d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a40:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104a43:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104a46:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104a49:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104a4c:	29 f8                	sub    %edi,%eax
f0104a4e:	39 c2                	cmp    %eax,%edx
f0104a50:	73 04                	jae    f0104a56 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104a52:	01 fa                	add    %edi,%edx
f0104a54:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104a56:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104a59:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104a5c:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104a61:	39 cb                	cmp    %ecx,%ebx
f0104a63:	7d 43                	jge    f0104aa8 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104a65:	8d 53 01             	lea    0x1(%ebx),%edx
f0104a68:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a6b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104a6e:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104a71:	eb 07                	jmp    f0104a7a <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104a73:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104a77:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104a7a:	39 ca                	cmp    %ecx,%edx
f0104a7c:	74 25                	je     f0104aa3 <debuginfo_eip+0x1c3>
f0104a7e:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104a81:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104a85:	74 ec                	je     f0104a73 <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104a87:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a8c:	eb 1a                	jmp    f0104aa8 <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a93:	eb 13                	jmp    f0104aa8 <debuginfo_eip+0x1c8>
f0104a95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104a9a:	eb 0c                	jmp    f0104aa8 <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104a9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104aa1:	eb 05                	jmp    f0104aa8 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104aab:	5b                   	pop    %ebx
f0104aac:	5e                   	pop    %esi
f0104aad:	5f                   	pop    %edi
f0104aae:	5d                   	pop    %ebp
f0104aaf:	c3                   	ret    

f0104ab0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104ab0:	55                   	push   %ebp
f0104ab1:	89 e5                	mov    %esp,%ebp
f0104ab3:	57                   	push   %edi
f0104ab4:	56                   	push   %esi
f0104ab5:	53                   	push   %ebx
f0104ab6:	83 ec 1c             	sub    $0x1c,%esp
f0104ab9:	89 c7                	mov    %eax,%edi
f0104abb:	89 d6                	mov    %edx,%esi
f0104abd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ac3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ac6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104ac9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104acc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ad1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ad4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104ad7:	39 d3                	cmp    %edx,%ebx
f0104ad9:	72 05                	jb     f0104ae0 <printnum+0x30>
f0104adb:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104ade:	77 45                	ja     f0104b25 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104ae0:	83 ec 0c             	sub    $0xc,%esp
f0104ae3:	ff 75 18             	pushl  0x18(%ebp)
f0104ae6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ae9:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104aec:	53                   	push   %ebx
f0104aed:	ff 75 10             	pushl  0x10(%ebp)
f0104af0:	83 ec 08             	sub    $0x8,%esp
f0104af3:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104af6:	ff 75 e0             	pushl  -0x20(%ebp)
f0104af9:	ff 75 dc             	pushl  -0x24(%ebp)
f0104afc:	ff 75 d8             	pushl  -0x28(%ebp)
f0104aff:	e8 ac 11 00 00       	call   f0105cb0 <__udivdi3>
f0104b04:	83 c4 18             	add    $0x18,%esp
f0104b07:	52                   	push   %edx
f0104b08:	50                   	push   %eax
f0104b09:	89 f2                	mov    %esi,%edx
f0104b0b:	89 f8                	mov    %edi,%eax
f0104b0d:	e8 9e ff ff ff       	call   f0104ab0 <printnum>
f0104b12:	83 c4 20             	add    $0x20,%esp
f0104b15:	eb 18                	jmp    f0104b2f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104b17:	83 ec 08             	sub    $0x8,%esp
f0104b1a:	56                   	push   %esi
f0104b1b:	ff 75 18             	pushl  0x18(%ebp)
f0104b1e:	ff d7                	call   *%edi
f0104b20:	83 c4 10             	add    $0x10,%esp
f0104b23:	eb 03                	jmp    f0104b28 <printnum+0x78>
f0104b25:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b28:	83 eb 01             	sub    $0x1,%ebx
f0104b2b:	85 db                	test   %ebx,%ebx
f0104b2d:	7f e8                	jg     f0104b17 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104b2f:	83 ec 08             	sub    $0x8,%esp
f0104b32:	56                   	push   %esi
f0104b33:	83 ec 04             	sub    $0x4,%esp
f0104b36:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b39:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b3c:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b3f:	ff 75 d8             	pushl  -0x28(%ebp)
f0104b42:	e8 99 12 00 00       	call   f0105de0 <__umoddi3>
f0104b47:	83 c4 14             	add    $0x14,%esp
f0104b4a:	0f be 80 d2 78 10 f0 	movsbl -0xfef872e(%eax),%eax
f0104b51:	50                   	push   %eax
f0104b52:	ff d7                	call   *%edi
}
f0104b54:	83 c4 10             	add    $0x10,%esp
f0104b57:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b5a:	5b                   	pop    %ebx
f0104b5b:	5e                   	pop    %esi
f0104b5c:	5f                   	pop    %edi
f0104b5d:	5d                   	pop    %ebp
f0104b5e:	c3                   	ret    

f0104b5f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104b5f:	55                   	push   %ebp
f0104b60:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104b62:	83 fa 01             	cmp    $0x1,%edx
f0104b65:	7e 0e                	jle    f0104b75 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104b67:	8b 10                	mov    (%eax),%edx
f0104b69:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104b6c:	89 08                	mov    %ecx,(%eax)
f0104b6e:	8b 02                	mov    (%edx),%eax
f0104b70:	8b 52 04             	mov    0x4(%edx),%edx
f0104b73:	eb 22                	jmp    f0104b97 <getuint+0x38>
	else if (lflag)
f0104b75:	85 d2                	test   %edx,%edx
f0104b77:	74 10                	je     f0104b89 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104b79:	8b 10                	mov    (%eax),%edx
f0104b7b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104b7e:	89 08                	mov    %ecx,(%eax)
f0104b80:	8b 02                	mov    (%edx),%eax
f0104b82:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b87:	eb 0e                	jmp    f0104b97 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104b89:	8b 10                	mov    (%eax),%edx
f0104b8b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104b8e:	89 08                	mov    %ecx,(%eax)
f0104b90:	8b 02                	mov    (%edx),%eax
f0104b92:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104b97:	5d                   	pop    %ebp
f0104b98:	c3                   	ret    

f0104b99 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104b99:	55                   	push   %ebp
f0104b9a:	89 e5                	mov    %esp,%ebp
f0104b9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104b9f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104ba3:	8b 10                	mov    (%eax),%edx
f0104ba5:	3b 50 04             	cmp    0x4(%eax),%edx
f0104ba8:	73 0a                	jae    f0104bb4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104baa:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104bad:	89 08                	mov    %ecx,(%eax)
f0104baf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bb2:	88 02                	mov    %al,(%edx)
}
f0104bb4:	5d                   	pop    %ebp
f0104bb5:	c3                   	ret    

f0104bb6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104bb6:	55                   	push   %ebp
f0104bb7:	89 e5                	mov    %esp,%ebp
f0104bb9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104bbc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104bbf:	50                   	push   %eax
f0104bc0:	ff 75 10             	pushl  0x10(%ebp)
f0104bc3:	ff 75 0c             	pushl  0xc(%ebp)
f0104bc6:	ff 75 08             	pushl  0x8(%ebp)
f0104bc9:	e8 05 00 00 00       	call   f0104bd3 <vprintfmt>
	va_end(ap);
}
f0104bce:	83 c4 10             	add    $0x10,%esp
f0104bd1:	c9                   	leave  
f0104bd2:	c3                   	ret    

f0104bd3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104bd3:	55                   	push   %ebp
f0104bd4:	89 e5                	mov    %esp,%ebp
f0104bd6:	57                   	push   %edi
f0104bd7:	56                   	push   %esi
f0104bd8:	53                   	push   %ebx
f0104bd9:	83 ec 2c             	sub    $0x2c,%esp
f0104bdc:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104be2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104be5:	eb 12                	jmp    f0104bf9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104be7:	85 c0                	test   %eax,%eax
f0104be9:	0f 84 d3 03 00 00    	je     f0104fc2 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
f0104bef:	83 ec 08             	sub    $0x8,%esp
f0104bf2:	53                   	push   %ebx
f0104bf3:	50                   	push   %eax
f0104bf4:	ff d6                	call   *%esi
f0104bf6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104bf9:	83 c7 01             	add    $0x1,%edi
f0104bfc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c00:	83 f8 25             	cmp    $0x25,%eax
f0104c03:	75 e2                	jne    f0104be7 <vprintfmt+0x14>
f0104c05:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104c09:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104c10:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104c17:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104c1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104c23:	eb 07                	jmp    f0104c2c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c25:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104c28:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c2c:	8d 47 01             	lea    0x1(%edi),%eax
f0104c2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c32:	0f b6 07             	movzbl (%edi),%eax
f0104c35:	0f b6 c8             	movzbl %al,%ecx
f0104c38:	83 e8 23             	sub    $0x23,%eax
f0104c3b:	3c 55                	cmp    $0x55,%al
f0104c3d:	0f 87 64 03 00 00    	ja     f0104fa7 <vprintfmt+0x3d4>
f0104c43:	0f b6 c0             	movzbl %al,%eax
f0104c46:	ff 24 85 a0 79 10 f0 	jmp    *-0xfef8660(,%eax,4)
f0104c4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104c50:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104c54:	eb d6                	jmp    f0104c2c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c59:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104c61:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104c64:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104c68:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104c6b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104c6e:	83 fa 09             	cmp    $0x9,%edx
f0104c71:	77 39                	ja     f0104cac <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104c73:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104c76:	eb e9                	jmp    f0104c61 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104c78:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c7b:	8d 48 04             	lea    0x4(%eax),%ecx
f0104c7e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104c81:	8b 00                	mov    (%eax),%eax
f0104c83:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104c89:	eb 27                	jmp    f0104cb2 <vprintfmt+0xdf>
f0104c8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c8e:	85 c0                	test   %eax,%eax
f0104c90:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c95:	0f 49 c8             	cmovns %eax,%ecx
f0104c98:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c9e:	eb 8c                	jmp    f0104c2c <vprintfmt+0x59>
f0104ca0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104ca3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104caa:	eb 80                	jmp    f0104c2c <vprintfmt+0x59>
f0104cac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104caf:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f0104cb2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104cb6:	0f 89 70 ff ff ff    	jns    f0104c2c <vprintfmt+0x59>
				width = precision, precision = -1;
f0104cbc:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104cbf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104cc2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104cc9:	e9 5e ff ff ff       	jmp    f0104c2c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104cce:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cd1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104cd4:	e9 53 ff ff ff       	jmp    f0104c2c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104cd9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cdc:	8d 50 04             	lea    0x4(%eax),%edx
f0104cdf:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ce2:	83 ec 08             	sub    $0x8,%esp
f0104ce5:	53                   	push   %ebx
f0104ce6:	ff 30                	pushl  (%eax)
f0104ce8:	ff d6                	call   *%esi
			break;
f0104cea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ced:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104cf0:	e9 04 ff ff ff       	jmp    f0104bf9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104cf5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cf8:	8d 50 04             	lea    0x4(%eax),%edx
f0104cfb:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cfe:	8b 00                	mov    (%eax),%eax
f0104d00:	99                   	cltd   
f0104d01:	31 d0                	xor    %edx,%eax
f0104d03:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104d05:	83 f8 08             	cmp    $0x8,%eax
f0104d08:	7f 0b                	jg     f0104d15 <vprintfmt+0x142>
f0104d0a:	8b 14 85 00 7b 10 f0 	mov    -0xfef8500(,%eax,4),%edx
f0104d11:	85 d2                	test   %edx,%edx
f0104d13:	75 18                	jne    f0104d2d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104d15:	50                   	push   %eax
f0104d16:	68 ea 78 10 f0       	push   $0xf01078ea
f0104d1b:	53                   	push   %ebx
f0104d1c:	56                   	push   %esi
f0104d1d:	e8 94 fe ff ff       	call   f0104bb6 <printfmt>
f0104d22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104d28:	e9 cc fe ff ff       	jmp    f0104bf9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104d2d:	52                   	push   %edx
f0104d2e:	68 79 6f 10 f0       	push   $0xf0106f79
f0104d33:	53                   	push   %ebx
f0104d34:	56                   	push   %esi
f0104d35:	e8 7c fe ff ff       	call   f0104bb6 <printfmt>
f0104d3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d40:	e9 b4 fe ff ff       	jmp    f0104bf9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104d45:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d48:	8d 50 04             	lea    0x4(%eax),%edx
f0104d4b:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d4e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104d50:	85 ff                	test   %edi,%edi
f0104d52:	b8 e3 78 10 f0       	mov    $0xf01078e3,%eax
f0104d57:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104d5a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d5e:	0f 8e 94 00 00 00    	jle    f0104df8 <vprintfmt+0x225>
f0104d64:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104d68:	0f 84 98 00 00 00    	je     f0104e06 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d6e:	83 ec 08             	sub    $0x8,%esp
f0104d71:	ff 75 c8             	pushl  -0x38(%ebp)
f0104d74:	57                   	push   %edi
f0104d75:	e8 a9 03 00 00       	call   f0105123 <strnlen>
f0104d7a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104d7d:	29 c1                	sub    %eax,%ecx
f0104d7f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104d82:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104d85:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104d89:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d8c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104d8f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d91:	eb 0f                	jmp    f0104da2 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104d93:	83 ec 08             	sub    $0x8,%esp
f0104d96:	53                   	push   %ebx
f0104d97:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d9a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d9c:	83 ef 01             	sub    $0x1,%edi
f0104d9f:	83 c4 10             	add    $0x10,%esp
f0104da2:	85 ff                	test   %edi,%edi
f0104da4:	7f ed                	jg     f0104d93 <vprintfmt+0x1c0>
f0104da6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104da9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104dac:	85 c9                	test   %ecx,%ecx
f0104dae:	b8 00 00 00 00       	mov    $0x0,%eax
f0104db3:	0f 49 c1             	cmovns %ecx,%eax
f0104db6:	29 c1                	sub    %eax,%ecx
f0104db8:	89 75 08             	mov    %esi,0x8(%ebp)
f0104dbb:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104dbe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104dc1:	89 cb                	mov    %ecx,%ebx
f0104dc3:	eb 4d                	jmp    f0104e12 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104dc5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104dc9:	74 1b                	je     f0104de6 <vprintfmt+0x213>
f0104dcb:	0f be c0             	movsbl %al,%eax
f0104dce:	83 e8 20             	sub    $0x20,%eax
f0104dd1:	83 f8 5e             	cmp    $0x5e,%eax
f0104dd4:	76 10                	jbe    f0104de6 <vprintfmt+0x213>
					putch('?', putdat);
f0104dd6:	83 ec 08             	sub    $0x8,%esp
f0104dd9:	ff 75 0c             	pushl  0xc(%ebp)
f0104ddc:	6a 3f                	push   $0x3f
f0104dde:	ff 55 08             	call   *0x8(%ebp)
f0104de1:	83 c4 10             	add    $0x10,%esp
f0104de4:	eb 0d                	jmp    f0104df3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104de6:	83 ec 08             	sub    $0x8,%esp
f0104de9:	ff 75 0c             	pushl  0xc(%ebp)
f0104dec:	52                   	push   %edx
f0104ded:	ff 55 08             	call   *0x8(%ebp)
f0104df0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104df3:	83 eb 01             	sub    $0x1,%ebx
f0104df6:	eb 1a                	jmp    f0104e12 <vprintfmt+0x23f>
f0104df8:	89 75 08             	mov    %esi,0x8(%ebp)
f0104dfb:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104dfe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e01:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e04:	eb 0c                	jmp    f0104e12 <vprintfmt+0x23f>
f0104e06:	89 75 08             	mov    %esi,0x8(%ebp)
f0104e09:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104e0c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e0f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e12:	83 c7 01             	add    $0x1,%edi
f0104e15:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104e19:	0f be d0             	movsbl %al,%edx
f0104e1c:	85 d2                	test   %edx,%edx
f0104e1e:	74 23                	je     f0104e43 <vprintfmt+0x270>
f0104e20:	85 f6                	test   %esi,%esi
f0104e22:	78 a1                	js     f0104dc5 <vprintfmt+0x1f2>
f0104e24:	83 ee 01             	sub    $0x1,%esi
f0104e27:	79 9c                	jns    f0104dc5 <vprintfmt+0x1f2>
f0104e29:	89 df                	mov    %ebx,%edi
f0104e2b:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e31:	eb 18                	jmp    f0104e4b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104e33:	83 ec 08             	sub    $0x8,%esp
f0104e36:	53                   	push   %ebx
f0104e37:	6a 20                	push   $0x20
f0104e39:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104e3b:	83 ef 01             	sub    $0x1,%edi
f0104e3e:	83 c4 10             	add    $0x10,%esp
f0104e41:	eb 08                	jmp    f0104e4b <vprintfmt+0x278>
f0104e43:	89 df                	mov    %ebx,%edi
f0104e45:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e4b:	85 ff                	test   %edi,%edi
f0104e4d:	7f e4                	jg     f0104e33 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e52:	e9 a2 fd ff ff       	jmp    f0104bf9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104e57:	83 fa 01             	cmp    $0x1,%edx
f0104e5a:	7e 16                	jle    f0104e72 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104e5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e5f:	8d 50 08             	lea    0x8(%eax),%edx
f0104e62:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e65:	8b 50 04             	mov    0x4(%eax),%edx
f0104e68:	8b 00                	mov    (%eax),%eax
f0104e6a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104e6d:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104e70:	eb 32                	jmp    f0104ea4 <vprintfmt+0x2d1>
	else if (lflag)
f0104e72:	85 d2                	test   %edx,%edx
f0104e74:	74 18                	je     f0104e8e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104e76:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e79:	8d 50 04             	lea    0x4(%eax),%edx
f0104e7c:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e7f:	8b 00                	mov    (%eax),%eax
f0104e81:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104e84:	89 c1                	mov    %eax,%ecx
f0104e86:	c1 f9 1f             	sar    $0x1f,%ecx
f0104e89:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104e8c:	eb 16                	jmp    f0104ea4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104e8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e91:	8d 50 04             	lea    0x4(%eax),%edx
f0104e94:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e97:	8b 00                	mov    (%eax),%eax
f0104e99:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104e9c:	89 c1                	mov    %eax,%ecx
f0104e9e:	c1 f9 1f             	sar    $0x1f,%ecx
f0104ea1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104ea4:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104ea7:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104eaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ead:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104eb0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104eb5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104eb9:	0f 89 b0 00 00 00    	jns    f0104f6f <vprintfmt+0x39c>
				putch('-', putdat);
f0104ebf:	83 ec 08             	sub    $0x8,%esp
f0104ec2:	53                   	push   %ebx
f0104ec3:	6a 2d                	push   $0x2d
f0104ec5:	ff d6                	call   *%esi
				num = -(long long) num;
f0104ec7:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104eca:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104ecd:	f7 d8                	neg    %eax
f0104ecf:	83 d2 00             	adc    $0x0,%edx
f0104ed2:	f7 da                	neg    %edx
f0104ed4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ed7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104eda:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104edd:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104ee2:	e9 88 00 00 00       	jmp    f0104f6f <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104ee7:	8d 45 14             	lea    0x14(%ebp),%eax
f0104eea:	e8 70 fc ff ff       	call   f0104b5f <getuint>
f0104eef:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ef2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0104ef5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104efa:	eb 73                	jmp    f0104f6f <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
f0104efc:	8d 45 14             	lea    0x14(%ebp),%eax
f0104eff:	e8 5b fc ff ff       	call   f0104b5f <getuint>
f0104f04:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f07:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
f0104f0a:	83 ec 08             	sub    $0x8,%esp
f0104f0d:	53                   	push   %ebx
f0104f0e:	6a 58                	push   $0x58
f0104f10:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f12:	83 c4 08             	add    $0x8,%esp
f0104f15:	53                   	push   %ebx
f0104f16:	6a 58                	push   $0x58
f0104f18:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f1a:	83 c4 08             	add    $0x8,%esp
f0104f1d:	53                   	push   %ebx
f0104f1e:	6a 58                	push   $0x58
f0104f20:	ff d6                	call   *%esi
			goto number;
f0104f22:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
f0104f25:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
f0104f2a:	eb 43                	jmp    f0104f6f <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0104f2c:	83 ec 08             	sub    $0x8,%esp
f0104f2f:	53                   	push   %ebx
f0104f30:	6a 30                	push   $0x30
f0104f32:	ff d6                	call   *%esi
			putch('x', putdat);
f0104f34:	83 c4 08             	add    $0x8,%esp
f0104f37:	53                   	push   %ebx
f0104f38:	6a 78                	push   $0x78
f0104f3a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104f3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f3f:	8d 50 04             	lea    0x4(%eax),%edx
f0104f42:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104f45:	8b 00                	mov    (%eax),%eax
f0104f47:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f4c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f4f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104f52:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104f55:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104f5a:	eb 13                	jmp    f0104f6f <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104f5c:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f5f:	e8 fb fb ff ff       	call   f0104b5f <getuint>
f0104f64:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f67:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0104f6a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104f6f:	83 ec 0c             	sub    $0xc,%esp
f0104f72:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0104f76:	52                   	push   %edx
f0104f77:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f7a:	50                   	push   %eax
f0104f7b:	ff 75 dc             	pushl  -0x24(%ebp)
f0104f7e:	ff 75 d8             	pushl  -0x28(%ebp)
f0104f81:	89 da                	mov    %ebx,%edx
f0104f83:	89 f0                	mov    %esi,%eax
f0104f85:	e8 26 fb ff ff       	call   f0104ab0 <printnum>
			break;
f0104f8a:	83 c4 20             	add    $0x20,%esp
f0104f8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f90:	e9 64 fc ff ff       	jmp    f0104bf9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104f95:	83 ec 08             	sub    $0x8,%esp
f0104f98:	53                   	push   %ebx
f0104f99:	51                   	push   %ecx
f0104f9a:	ff d6                	call   *%esi
			break;
f0104f9c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104fa2:	e9 52 fc ff ff       	jmp    f0104bf9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104fa7:	83 ec 08             	sub    $0x8,%esp
f0104faa:	53                   	push   %ebx
f0104fab:	6a 25                	push   $0x25
f0104fad:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104faf:	83 c4 10             	add    $0x10,%esp
f0104fb2:	eb 03                	jmp    f0104fb7 <vprintfmt+0x3e4>
f0104fb4:	83 ef 01             	sub    $0x1,%edi
f0104fb7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104fbb:	75 f7                	jne    f0104fb4 <vprintfmt+0x3e1>
f0104fbd:	e9 37 fc ff ff       	jmp    f0104bf9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104fc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fc5:	5b                   	pop    %ebx
f0104fc6:	5e                   	pop    %esi
f0104fc7:	5f                   	pop    %edi
f0104fc8:	5d                   	pop    %ebp
f0104fc9:	c3                   	ret    

f0104fca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104fca:	55                   	push   %ebp
f0104fcb:	89 e5                	mov    %esp,%ebp
f0104fcd:	83 ec 18             	sub    $0x18,%esp
f0104fd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fd3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104fd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104fd9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104fdd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104fe0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104fe7:	85 c0                	test   %eax,%eax
f0104fe9:	74 26                	je     f0105011 <vsnprintf+0x47>
f0104feb:	85 d2                	test   %edx,%edx
f0104fed:	7e 22                	jle    f0105011 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104fef:	ff 75 14             	pushl  0x14(%ebp)
f0104ff2:	ff 75 10             	pushl  0x10(%ebp)
f0104ff5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ff8:	50                   	push   %eax
f0104ff9:	68 99 4b 10 f0       	push   $0xf0104b99
f0104ffe:	e8 d0 fb ff ff       	call   f0104bd3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105003:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105006:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105009:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010500c:	83 c4 10             	add    $0x10,%esp
f010500f:	eb 05                	jmp    f0105016 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105011:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105016:	c9                   	leave  
f0105017:	c3                   	ret    

f0105018 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105018:	55                   	push   %ebp
f0105019:	89 e5                	mov    %esp,%ebp
f010501b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010501e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105021:	50                   	push   %eax
f0105022:	ff 75 10             	pushl  0x10(%ebp)
f0105025:	ff 75 0c             	pushl  0xc(%ebp)
f0105028:	ff 75 08             	pushl  0x8(%ebp)
f010502b:	e8 9a ff ff ff       	call   f0104fca <vsnprintf>
	va_end(ap);

	return rc;
}
f0105030:	c9                   	leave  
f0105031:	c3                   	ret    

f0105032 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105032:	55                   	push   %ebp
f0105033:	89 e5                	mov    %esp,%ebp
f0105035:	57                   	push   %edi
f0105036:	56                   	push   %esi
f0105037:	53                   	push   %ebx
f0105038:	83 ec 0c             	sub    $0xc,%esp
f010503b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010503e:	85 c0                	test   %eax,%eax
f0105040:	74 11                	je     f0105053 <readline+0x21>
		cprintf("%s", prompt);
f0105042:	83 ec 08             	sub    $0x8,%esp
f0105045:	50                   	push   %eax
f0105046:	68 79 6f 10 f0       	push   $0xf0106f79
f010504b:	e8 17 e8 ff ff       	call   f0103867 <cprintf>
f0105050:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105053:	83 ec 0c             	sub    $0xc,%esp
f0105056:	6a 00                	push   $0x0
f0105058:	e8 91 b7 ff ff       	call   f01007ee <iscons>
f010505d:	89 c7                	mov    %eax,%edi
f010505f:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105062:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105067:	e8 71 b7 ff ff       	call   f01007dd <getchar>
f010506c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010506e:	85 c0                	test   %eax,%eax
f0105070:	79 18                	jns    f010508a <readline+0x58>
			cprintf("read error: %e\n", c);
f0105072:	83 ec 08             	sub    $0x8,%esp
f0105075:	50                   	push   %eax
f0105076:	68 24 7b 10 f0       	push   $0xf0107b24
f010507b:	e8 e7 e7 ff ff       	call   f0103867 <cprintf>
			return NULL;
f0105080:	83 c4 10             	add    $0x10,%esp
f0105083:	b8 00 00 00 00       	mov    $0x0,%eax
f0105088:	eb 79                	jmp    f0105103 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010508a:	83 f8 08             	cmp    $0x8,%eax
f010508d:	0f 94 c2             	sete   %dl
f0105090:	83 f8 7f             	cmp    $0x7f,%eax
f0105093:	0f 94 c0             	sete   %al
f0105096:	08 c2                	or     %al,%dl
f0105098:	74 1a                	je     f01050b4 <readline+0x82>
f010509a:	85 f6                	test   %esi,%esi
f010509c:	7e 16                	jle    f01050b4 <readline+0x82>
			if (echoing)
f010509e:	85 ff                	test   %edi,%edi
f01050a0:	74 0d                	je     f01050af <readline+0x7d>
				cputchar('\b');
f01050a2:	83 ec 0c             	sub    $0xc,%esp
f01050a5:	6a 08                	push   $0x8
f01050a7:	e8 21 b7 ff ff       	call   f01007cd <cputchar>
f01050ac:	83 c4 10             	add    $0x10,%esp
			i--;
f01050af:	83 ee 01             	sub    $0x1,%esi
f01050b2:	eb b3                	jmp    f0105067 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01050b4:	83 fb 1f             	cmp    $0x1f,%ebx
f01050b7:	7e 23                	jle    f01050dc <readline+0xaa>
f01050b9:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01050bf:	7f 1b                	jg     f01050dc <readline+0xaa>
			if (echoing)
f01050c1:	85 ff                	test   %edi,%edi
f01050c3:	74 0c                	je     f01050d1 <readline+0x9f>
				cputchar(c);
f01050c5:	83 ec 0c             	sub    $0xc,%esp
f01050c8:	53                   	push   %ebx
f01050c9:	e8 ff b6 ff ff       	call   f01007cd <cputchar>
f01050ce:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01050d1:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f01050d7:	8d 76 01             	lea    0x1(%esi),%esi
f01050da:	eb 8b                	jmp    f0105067 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01050dc:	83 fb 0a             	cmp    $0xa,%ebx
f01050df:	74 05                	je     f01050e6 <readline+0xb4>
f01050e1:	83 fb 0d             	cmp    $0xd,%ebx
f01050e4:	75 81                	jne    f0105067 <readline+0x35>
			if (echoing)
f01050e6:	85 ff                	test   %edi,%edi
f01050e8:	74 0d                	je     f01050f7 <readline+0xc5>
				cputchar('\n');
f01050ea:	83 ec 0c             	sub    $0xc,%esp
f01050ed:	6a 0a                	push   $0xa
f01050ef:	e8 d9 b6 ff ff       	call   f01007cd <cputchar>
f01050f4:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01050f7:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f01050fe:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f0105103:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105106:	5b                   	pop    %ebx
f0105107:	5e                   	pop    %esi
f0105108:	5f                   	pop    %edi
f0105109:	5d                   	pop    %ebp
f010510a:	c3                   	ret    

f010510b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010510b:	55                   	push   %ebp
f010510c:	89 e5                	mov    %esp,%ebp
f010510e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105111:	b8 00 00 00 00       	mov    $0x0,%eax
f0105116:	eb 03                	jmp    f010511b <strlen+0x10>
		n++;
f0105118:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010511b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010511f:	75 f7                	jne    f0105118 <strlen+0xd>
		n++;
	return n;
}
f0105121:	5d                   	pop    %ebp
f0105122:	c3                   	ret    

f0105123 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105123:	55                   	push   %ebp
f0105124:	89 e5                	mov    %esp,%ebp
f0105126:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105129:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010512c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105131:	eb 03                	jmp    f0105136 <strnlen+0x13>
		n++;
f0105133:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105136:	39 c2                	cmp    %eax,%edx
f0105138:	74 08                	je     f0105142 <strnlen+0x1f>
f010513a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010513e:	75 f3                	jne    f0105133 <strnlen+0x10>
f0105140:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105142:	5d                   	pop    %ebp
f0105143:	c3                   	ret    

f0105144 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105144:	55                   	push   %ebp
f0105145:	89 e5                	mov    %esp,%ebp
f0105147:	53                   	push   %ebx
f0105148:	8b 45 08             	mov    0x8(%ebp),%eax
f010514b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010514e:	89 c2                	mov    %eax,%edx
f0105150:	83 c2 01             	add    $0x1,%edx
f0105153:	83 c1 01             	add    $0x1,%ecx
f0105156:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010515a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010515d:	84 db                	test   %bl,%bl
f010515f:	75 ef                	jne    f0105150 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105161:	5b                   	pop    %ebx
f0105162:	5d                   	pop    %ebp
f0105163:	c3                   	ret    

f0105164 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105164:	55                   	push   %ebp
f0105165:	89 e5                	mov    %esp,%ebp
f0105167:	53                   	push   %ebx
f0105168:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010516b:	53                   	push   %ebx
f010516c:	e8 9a ff ff ff       	call   f010510b <strlen>
f0105171:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105174:	ff 75 0c             	pushl  0xc(%ebp)
f0105177:	01 d8                	add    %ebx,%eax
f0105179:	50                   	push   %eax
f010517a:	e8 c5 ff ff ff       	call   f0105144 <strcpy>
	return dst;
}
f010517f:	89 d8                	mov    %ebx,%eax
f0105181:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105184:	c9                   	leave  
f0105185:	c3                   	ret    

f0105186 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105186:	55                   	push   %ebp
f0105187:	89 e5                	mov    %esp,%ebp
f0105189:	56                   	push   %esi
f010518a:	53                   	push   %ebx
f010518b:	8b 75 08             	mov    0x8(%ebp),%esi
f010518e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105191:	89 f3                	mov    %esi,%ebx
f0105193:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105196:	89 f2                	mov    %esi,%edx
f0105198:	eb 0f                	jmp    f01051a9 <strncpy+0x23>
		*dst++ = *src;
f010519a:	83 c2 01             	add    $0x1,%edx
f010519d:	0f b6 01             	movzbl (%ecx),%eax
f01051a0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01051a3:	80 39 01             	cmpb   $0x1,(%ecx)
f01051a6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01051a9:	39 da                	cmp    %ebx,%edx
f01051ab:	75 ed                	jne    f010519a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01051ad:	89 f0                	mov    %esi,%eax
f01051af:	5b                   	pop    %ebx
f01051b0:	5e                   	pop    %esi
f01051b1:	5d                   	pop    %ebp
f01051b2:	c3                   	ret    

f01051b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01051b3:	55                   	push   %ebp
f01051b4:	89 e5                	mov    %esp,%ebp
f01051b6:	56                   	push   %esi
f01051b7:	53                   	push   %ebx
f01051b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01051bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01051be:	8b 55 10             	mov    0x10(%ebp),%edx
f01051c1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01051c3:	85 d2                	test   %edx,%edx
f01051c5:	74 21                	je     f01051e8 <strlcpy+0x35>
f01051c7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01051cb:	89 f2                	mov    %esi,%edx
f01051cd:	eb 09                	jmp    f01051d8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01051cf:	83 c2 01             	add    $0x1,%edx
f01051d2:	83 c1 01             	add    $0x1,%ecx
f01051d5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01051d8:	39 c2                	cmp    %eax,%edx
f01051da:	74 09                	je     f01051e5 <strlcpy+0x32>
f01051dc:	0f b6 19             	movzbl (%ecx),%ebx
f01051df:	84 db                	test   %bl,%bl
f01051e1:	75 ec                	jne    f01051cf <strlcpy+0x1c>
f01051e3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01051e5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01051e8:	29 f0                	sub    %esi,%eax
}
f01051ea:	5b                   	pop    %ebx
f01051eb:	5e                   	pop    %esi
f01051ec:	5d                   	pop    %ebp
f01051ed:	c3                   	ret    

f01051ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01051ee:	55                   	push   %ebp
f01051ef:	89 e5                	mov    %esp,%ebp
f01051f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01051f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01051f7:	eb 06                	jmp    f01051ff <strcmp+0x11>
		p++, q++;
f01051f9:	83 c1 01             	add    $0x1,%ecx
f01051fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01051ff:	0f b6 01             	movzbl (%ecx),%eax
f0105202:	84 c0                	test   %al,%al
f0105204:	74 04                	je     f010520a <strcmp+0x1c>
f0105206:	3a 02                	cmp    (%edx),%al
f0105208:	74 ef                	je     f01051f9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010520a:	0f b6 c0             	movzbl %al,%eax
f010520d:	0f b6 12             	movzbl (%edx),%edx
f0105210:	29 d0                	sub    %edx,%eax
}
f0105212:	5d                   	pop    %ebp
f0105213:	c3                   	ret    

f0105214 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105214:	55                   	push   %ebp
f0105215:	89 e5                	mov    %esp,%ebp
f0105217:	53                   	push   %ebx
f0105218:	8b 45 08             	mov    0x8(%ebp),%eax
f010521b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010521e:	89 c3                	mov    %eax,%ebx
f0105220:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105223:	eb 06                	jmp    f010522b <strncmp+0x17>
		n--, p++, q++;
f0105225:	83 c0 01             	add    $0x1,%eax
f0105228:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010522b:	39 d8                	cmp    %ebx,%eax
f010522d:	74 15                	je     f0105244 <strncmp+0x30>
f010522f:	0f b6 08             	movzbl (%eax),%ecx
f0105232:	84 c9                	test   %cl,%cl
f0105234:	74 04                	je     f010523a <strncmp+0x26>
f0105236:	3a 0a                	cmp    (%edx),%cl
f0105238:	74 eb                	je     f0105225 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010523a:	0f b6 00             	movzbl (%eax),%eax
f010523d:	0f b6 12             	movzbl (%edx),%edx
f0105240:	29 d0                	sub    %edx,%eax
f0105242:	eb 05                	jmp    f0105249 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105244:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105249:	5b                   	pop    %ebx
f010524a:	5d                   	pop    %ebp
f010524b:	c3                   	ret    

f010524c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010524c:	55                   	push   %ebp
f010524d:	89 e5                	mov    %esp,%ebp
f010524f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105252:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105256:	eb 07                	jmp    f010525f <strchr+0x13>
		if (*s == c)
f0105258:	38 ca                	cmp    %cl,%dl
f010525a:	74 0f                	je     f010526b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010525c:	83 c0 01             	add    $0x1,%eax
f010525f:	0f b6 10             	movzbl (%eax),%edx
f0105262:	84 d2                	test   %dl,%dl
f0105264:	75 f2                	jne    f0105258 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105266:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010526b:	5d                   	pop    %ebp
f010526c:	c3                   	ret    

f010526d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010526d:	55                   	push   %ebp
f010526e:	89 e5                	mov    %esp,%ebp
f0105270:	8b 45 08             	mov    0x8(%ebp),%eax
f0105273:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105277:	eb 03                	jmp    f010527c <strfind+0xf>
f0105279:	83 c0 01             	add    $0x1,%eax
f010527c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010527f:	38 ca                	cmp    %cl,%dl
f0105281:	74 04                	je     f0105287 <strfind+0x1a>
f0105283:	84 d2                	test   %dl,%dl
f0105285:	75 f2                	jne    f0105279 <strfind+0xc>
			break;
	return (char *) s;
}
f0105287:	5d                   	pop    %ebp
f0105288:	c3                   	ret    

f0105289 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105289:	55                   	push   %ebp
f010528a:	89 e5                	mov    %esp,%ebp
f010528c:	57                   	push   %edi
f010528d:	56                   	push   %esi
f010528e:	53                   	push   %ebx
f010528f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105292:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105295:	85 c9                	test   %ecx,%ecx
f0105297:	74 36                	je     f01052cf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105299:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010529f:	75 28                	jne    f01052c9 <memset+0x40>
f01052a1:	f6 c1 03             	test   $0x3,%cl
f01052a4:	75 23                	jne    f01052c9 <memset+0x40>
		c &= 0xFF;
f01052a6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01052aa:	89 d3                	mov    %edx,%ebx
f01052ac:	c1 e3 08             	shl    $0x8,%ebx
f01052af:	89 d6                	mov    %edx,%esi
f01052b1:	c1 e6 18             	shl    $0x18,%esi
f01052b4:	89 d0                	mov    %edx,%eax
f01052b6:	c1 e0 10             	shl    $0x10,%eax
f01052b9:	09 f0                	or     %esi,%eax
f01052bb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01052bd:	89 d8                	mov    %ebx,%eax
f01052bf:	09 d0                	or     %edx,%eax
f01052c1:	c1 e9 02             	shr    $0x2,%ecx
f01052c4:	fc                   	cld    
f01052c5:	f3 ab                	rep stos %eax,%es:(%edi)
f01052c7:	eb 06                	jmp    f01052cf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01052c9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052cc:	fc                   	cld    
f01052cd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01052cf:	89 f8                	mov    %edi,%eax
f01052d1:	5b                   	pop    %ebx
f01052d2:	5e                   	pop    %esi
f01052d3:	5f                   	pop    %edi
f01052d4:	5d                   	pop    %ebp
f01052d5:	c3                   	ret    

f01052d6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01052d6:	55                   	push   %ebp
f01052d7:	89 e5                	mov    %esp,%ebp
f01052d9:	57                   	push   %edi
f01052da:	56                   	push   %esi
f01052db:	8b 45 08             	mov    0x8(%ebp),%eax
f01052de:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01052e4:	39 c6                	cmp    %eax,%esi
f01052e6:	73 35                	jae    f010531d <memmove+0x47>
f01052e8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01052eb:	39 d0                	cmp    %edx,%eax
f01052ed:	73 2e                	jae    f010531d <memmove+0x47>
		s += n;
		d += n;
f01052ef:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01052f2:	89 d6                	mov    %edx,%esi
f01052f4:	09 fe                	or     %edi,%esi
f01052f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01052fc:	75 13                	jne    f0105311 <memmove+0x3b>
f01052fe:	f6 c1 03             	test   $0x3,%cl
f0105301:	75 0e                	jne    f0105311 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105303:	83 ef 04             	sub    $0x4,%edi
f0105306:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105309:	c1 e9 02             	shr    $0x2,%ecx
f010530c:	fd                   	std    
f010530d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010530f:	eb 09                	jmp    f010531a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105311:	83 ef 01             	sub    $0x1,%edi
f0105314:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105317:	fd                   	std    
f0105318:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010531a:	fc                   	cld    
f010531b:	eb 1d                	jmp    f010533a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010531d:	89 f2                	mov    %esi,%edx
f010531f:	09 c2                	or     %eax,%edx
f0105321:	f6 c2 03             	test   $0x3,%dl
f0105324:	75 0f                	jne    f0105335 <memmove+0x5f>
f0105326:	f6 c1 03             	test   $0x3,%cl
f0105329:	75 0a                	jne    f0105335 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010532b:	c1 e9 02             	shr    $0x2,%ecx
f010532e:	89 c7                	mov    %eax,%edi
f0105330:	fc                   	cld    
f0105331:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105333:	eb 05                	jmp    f010533a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105335:	89 c7                	mov    %eax,%edi
f0105337:	fc                   	cld    
f0105338:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010533a:	5e                   	pop    %esi
f010533b:	5f                   	pop    %edi
f010533c:	5d                   	pop    %ebp
f010533d:	c3                   	ret    

f010533e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010533e:	55                   	push   %ebp
f010533f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105341:	ff 75 10             	pushl  0x10(%ebp)
f0105344:	ff 75 0c             	pushl  0xc(%ebp)
f0105347:	ff 75 08             	pushl  0x8(%ebp)
f010534a:	e8 87 ff ff ff       	call   f01052d6 <memmove>
}
f010534f:	c9                   	leave  
f0105350:	c3                   	ret    

f0105351 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105351:	55                   	push   %ebp
f0105352:	89 e5                	mov    %esp,%ebp
f0105354:	56                   	push   %esi
f0105355:	53                   	push   %ebx
f0105356:	8b 45 08             	mov    0x8(%ebp),%eax
f0105359:	8b 55 0c             	mov    0xc(%ebp),%edx
f010535c:	89 c6                	mov    %eax,%esi
f010535e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105361:	eb 1a                	jmp    f010537d <memcmp+0x2c>
		if (*s1 != *s2)
f0105363:	0f b6 08             	movzbl (%eax),%ecx
f0105366:	0f b6 1a             	movzbl (%edx),%ebx
f0105369:	38 d9                	cmp    %bl,%cl
f010536b:	74 0a                	je     f0105377 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010536d:	0f b6 c1             	movzbl %cl,%eax
f0105370:	0f b6 db             	movzbl %bl,%ebx
f0105373:	29 d8                	sub    %ebx,%eax
f0105375:	eb 0f                	jmp    f0105386 <memcmp+0x35>
		s1++, s2++;
f0105377:	83 c0 01             	add    $0x1,%eax
f010537a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010537d:	39 f0                	cmp    %esi,%eax
f010537f:	75 e2                	jne    f0105363 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105381:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105386:	5b                   	pop    %ebx
f0105387:	5e                   	pop    %esi
f0105388:	5d                   	pop    %ebp
f0105389:	c3                   	ret    

f010538a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010538a:	55                   	push   %ebp
f010538b:	89 e5                	mov    %esp,%ebp
f010538d:	53                   	push   %ebx
f010538e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105391:	89 c1                	mov    %eax,%ecx
f0105393:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105396:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010539a:	eb 0a                	jmp    f01053a6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010539c:	0f b6 10             	movzbl (%eax),%edx
f010539f:	39 da                	cmp    %ebx,%edx
f01053a1:	74 07                	je     f01053aa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053a3:	83 c0 01             	add    $0x1,%eax
f01053a6:	39 c8                	cmp    %ecx,%eax
f01053a8:	72 f2                	jb     f010539c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01053aa:	5b                   	pop    %ebx
f01053ab:	5d                   	pop    %ebp
f01053ac:	c3                   	ret    

f01053ad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01053ad:	55                   	push   %ebp
f01053ae:	89 e5                	mov    %esp,%ebp
f01053b0:	57                   	push   %edi
f01053b1:	56                   	push   %esi
f01053b2:	53                   	push   %ebx
f01053b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053b9:	eb 03                	jmp    f01053be <strtol+0x11>
		s++;
f01053bb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053be:	0f b6 01             	movzbl (%ecx),%eax
f01053c1:	3c 20                	cmp    $0x20,%al
f01053c3:	74 f6                	je     f01053bb <strtol+0xe>
f01053c5:	3c 09                	cmp    $0x9,%al
f01053c7:	74 f2                	je     f01053bb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01053c9:	3c 2b                	cmp    $0x2b,%al
f01053cb:	75 0a                	jne    f01053d7 <strtol+0x2a>
		s++;
f01053cd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01053d0:	bf 00 00 00 00       	mov    $0x0,%edi
f01053d5:	eb 11                	jmp    f01053e8 <strtol+0x3b>
f01053d7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01053dc:	3c 2d                	cmp    $0x2d,%al
f01053de:	75 08                	jne    f01053e8 <strtol+0x3b>
		s++, neg = 1;
f01053e0:	83 c1 01             	add    $0x1,%ecx
f01053e3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01053e8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01053ee:	75 15                	jne    f0105405 <strtol+0x58>
f01053f0:	80 39 30             	cmpb   $0x30,(%ecx)
f01053f3:	75 10                	jne    f0105405 <strtol+0x58>
f01053f5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01053f9:	75 7c                	jne    f0105477 <strtol+0xca>
		s += 2, base = 16;
f01053fb:	83 c1 02             	add    $0x2,%ecx
f01053fe:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105403:	eb 16                	jmp    f010541b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105405:	85 db                	test   %ebx,%ebx
f0105407:	75 12                	jne    f010541b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105409:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010540e:	80 39 30             	cmpb   $0x30,(%ecx)
f0105411:	75 08                	jne    f010541b <strtol+0x6e>
		s++, base = 8;
f0105413:	83 c1 01             	add    $0x1,%ecx
f0105416:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010541b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105420:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105423:	0f b6 11             	movzbl (%ecx),%edx
f0105426:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105429:	89 f3                	mov    %esi,%ebx
f010542b:	80 fb 09             	cmp    $0x9,%bl
f010542e:	77 08                	ja     f0105438 <strtol+0x8b>
			dig = *s - '0';
f0105430:	0f be d2             	movsbl %dl,%edx
f0105433:	83 ea 30             	sub    $0x30,%edx
f0105436:	eb 22                	jmp    f010545a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105438:	8d 72 9f             	lea    -0x61(%edx),%esi
f010543b:	89 f3                	mov    %esi,%ebx
f010543d:	80 fb 19             	cmp    $0x19,%bl
f0105440:	77 08                	ja     f010544a <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105442:	0f be d2             	movsbl %dl,%edx
f0105445:	83 ea 57             	sub    $0x57,%edx
f0105448:	eb 10                	jmp    f010545a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010544a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010544d:	89 f3                	mov    %esi,%ebx
f010544f:	80 fb 19             	cmp    $0x19,%bl
f0105452:	77 16                	ja     f010546a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105454:	0f be d2             	movsbl %dl,%edx
f0105457:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010545a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010545d:	7d 0b                	jge    f010546a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010545f:	83 c1 01             	add    $0x1,%ecx
f0105462:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105466:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105468:	eb b9                	jmp    f0105423 <strtol+0x76>

	if (endptr)
f010546a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010546e:	74 0d                	je     f010547d <strtol+0xd0>
		*endptr = (char *) s;
f0105470:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105473:	89 0e                	mov    %ecx,(%esi)
f0105475:	eb 06                	jmp    f010547d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105477:	85 db                	test   %ebx,%ebx
f0105479:	74 98                	je     f0105413 <strtol+0x66>
f010547b:	eb 9e                	jmp    f010541b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010547d:	89 c2                	mov    %eax,%edx
f010547f:	f7 da                	neg    %edx
f0105481:	85 ff                	test   %edi,%edi
f0105483:	0f 45 c2             	cmovne %edx,%eax
}
f0105486:	5b                   	pop    %ebx
f0105487:	5e                   	pop    %esi
f0105488:	5f                   	pop    %edi
f0105489:	5d                   	pop    %ebp
f010548a:	c3                   	ret    
f010548b:	90                   	nop

f010548c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010548c:	fa                   	cli    

	xorw    %ax, %ax
f010548d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010548f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105491:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105493:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105495:	0f 01 16             	lgdtl  (%esi)
f0105498:	74 70                	je     f010550a <mpsearch1+0x3>
	movl    %cr0, %eax
f010549a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010549d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01054a1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01054a4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01054aa:	08 00                	or     %al,(%eax)

f01054ac <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01054ac:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01054b0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01054b2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01054b4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01054b6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01054ba:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01054bc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01054be:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01054c3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01054c6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01054c9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01054ce:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01054d1:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01054d7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01054dc:	b8 14 02 10 f0       	mov    $0xf0100214,%eax
	call    *%eax
f01054e1:	ff d0                	call   *%eax

f01054e3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01054e3:	eb fe                	jmp    f01054e3 <spin>
f01054e5:	8d 76 00             	lea    0x0(%esi),%esi

f01054e8 <gdt>:
	...
f01054f0:	ff                   	(bad)  
f01054f1:	ff 00                	incl   (%eax)
f01054f3:	00 00                	add    %al,(%eax)
f01054f5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01054fc:	00                   	.byte 0x0
f01054fd:	92                   	xchg   %eax,%edx
f01054fe:	cf                   	iret   
	...

f0105500 <gdtdesc>:
f0105500:	17                   	pop    %ss
f0105501:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105506 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105506:	90                   	nop

f0105507 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105507:	55                   	push   %ebp
f0105508:	89 e5                	mov    %esp,%ebp
f010550a:	57                   	push   %edi
f010550b:	56                   	push   %esi
f010550c:	53                   	push   %ebx
f010550d:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105510:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0105516:	89 c3                	mov    %eax,%ebx
f0105518:	c1 eb 0c             	shr    $0xc,%ebx
f010551b:	39 cb                	cmp    %ecx,%ebx
f010551d:	72 12                	jb     f0105531 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010551f:	50                   	push   %eax
f0105520:	68 08 60 10 f0       	push   $0xf0106008
f0105525:	6a 57                	push   $0x57
f0105527:	68 c1 7c 10 f0       	push   $0xf0107cc1
f010552c:	e8 63 ab ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105531:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105537:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105539:	89 c2                	mov    %eax,%edx
f010553b:	c1 ea 0c             	shr    $0xc,%edx
f010553e:	39 ca                	cmp    %ecx,%edx
f0105540:	72 12                	jb     f0105554 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105542:	50                   	push   %eax
f0105543:	68 08 60 10 f0       	push   $0xf0106008
f0105548:	6a 57                	push   $0x57
f010554a:	68 c1 7c 10 f0       	push   $0xf0107cc1
f010554f:	e8 40 ab ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105554:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010555a:	eb 2f                	jmp    f010558b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010555c:	83 ec 04             	sub    $0x4,%esp
f010555f:	6a 04                	push   $0x4
f0105561:	68 d1 7c 10 f0       	push   $0xf0107cd1
f0105566:	53                   	push   %ebx
f0105567:	e8 e5 fd ff ff       	call   f0105351 <memcmp>
f010556c:	83 c4 10             	add    $0x10,%esp
f010556f:	85 c0                	test   %eax,%eax
f0105571:	75 15                	jne    f0105588 <mpsearch1+0x81>
f0105573:	89 da                	mov    %ebx,%edx
f0105575:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105578:	0f b6 0a             	movzbl (%edx),%ecx
f010557b:	01 c8                	add    %ecx,%eax
f010557d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105580:	39 d7                	cmp    %edx,%edi
f0105582:	75 f4                	jne    f0105578 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105584:	84 c0                	test   %al,%al
f0105586:	74 0e                	je     f0105596 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105588:	83 c3 10             	add    $0x10,%ebx
f010558b:	39 f3                	cmp    %esi,%ebx
f010558d:	72 cd                	jb     f010555c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010558f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105594:	eb 02                	jmp    f0105598 <mpsearch1+0x91>
f0105596:	89 d8                	mov    %ebx,%eax
}
f0105598:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010559b:	5b                   	pop    %ebx
f010559c:	5e                   	pop    %esi
f010559d:	5f                   	pop    %edi
f010559e:	5d                   	pop    %ebp
f010559f:	c3                   	ret    

f01055a0 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01055a0:	55                   	push   %ebp
f01055a1:	89 e5                	mov    %esp,%ebp
f01055a3:	57                   	push   %edi
f01055a4:	56                   	push   %esi
f01055a5:	53                   	push   %ebx
f01055a6:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01055a9:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f01055b0:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01055b3:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f01055ba:	75 16                	jne    f01055d2 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055bc:	68 00 04 00 00       	push   $0x400
f01055c1:	68 08 60 10 f0       	push   $0xf0106008
f01055c6:	6a 6f                	push   $0x6f
f01055c8:	68 c1 7c 10 f0       	push   $0xf0107cc1
f01055cd:	e8 c2 aa ff ff       	call   f0100094 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01055d2:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01055d9:	85 c0                	test   %eax,%eax
f01055db:	74 16                	je     f01055f3 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01055dd:	c1 e0 04             	shl    $0x4,%eax
f01055e0:	ba 00 04 00 00       	mov    $0x400,%edx
f01055e5:	e8 1d ff ff ff       	call   f0105507 <mpsearch1>
f01055ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01055ed:	85 c0                	test   %eax,%eax
f01055ef:	75 3c                	jne    f010562d <mp_init+0x8d>
f01055f1:	eb 20                	jmp    f0105613 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01055f3:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01055fa:	c1 e0 0a             	shl    $0xa,%eax
f01055fd:	2d 00 04 00 00       	sub    $0x400,%eax
f0105602:	ba 00 04 00 00       	mov    $0x400,%edx
f0105607:	e8 fb fe ff ff       	call   f0105507 <mpsearch1>
f010560c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010560f:	85 c0                	test   %eax,%eax
f0105611:	75 1a                	jne    f010562d <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105613:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105618:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f010561d:	e8 e5 fe ff ff       	call   f0105507 <mpsearch1>
f0105622:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105625:	85 c0                	test   %eax,%eax
f0105627:	0f 84 5d 02 00 00    	je     f010588a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f010562d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105630:	8b 70 04             	mov    0x4(%eax),%esi
f0105633:	85 f6                	test   %esi,%esi
f0105635:	74 06                	je     f010563d <mp_init+0x9d>
f0105637:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010563b:	74 15                	je     f0105652 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010563d:	83 ec 0c             	sub    $0xc,%esp
f0105640:	68 34 7b 10 f0       	push   $0xf0107b34
f0105645:	e8 1d e2 ff ff       	call   f0103867 <cprintf>
f010564a:	83 c4 10             	add    $0x10,%esp
f010564d:	e9 38 02 00 00       	jmp    f010588a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105652:	89 f0                	mov    %esi,%eax
f0105654:	c1 e8 0c             	shr    $0xc,%eax
f0105657:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f010565d:	72 15                	jb     f0105674 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010565f:	56                   	push   %esi
f0105660:	68 08 60 10 f0       	push   $0xf0106008
f0105665:	68 90 00 00 00       	push   $0x90
f010566a:	68 c1 7c 10 f0       	push   $0xf0107cc1
f010566f:	e8 20 aa ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105674:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010567a:	83 ec 04             	sub    $0x4,%esp
f010567d:	6a 04                	push   $0x4
f010567f:	68 d6 7c 10 f0       	push   $0xf0107cd6
f0105684:	53                   	push   %ebx
f0105685:	e8 c7 fc ff ff       	call   f0105351 <memcmp>
f010568a:	83 c4 10             	add    $0x10,%esp
f010568d:	85 c0                	test   %eax,%eax
f010568f:	74 15                	je     f01056a6 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105691:	83 ec 0c             	sub    $0xc,%esp
f0105694:	68 64 7b 10 f0       	push   $0xf0107b64
f0105699:	e8 c9 e1 ff ff       	call   f0103867 <cprintf>
f010569e:	83 c4 10             	add    $0x10,%esp
f01056a1:	e9 e4 01 00 00       	jmp    f010588a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01056a6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01056aa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01056ae:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01056b1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01056b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01056bb:	eb 0d                	jmp    f01056ca <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01056bd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01056c4:	f0 
f01056c5:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01056c7:	83 c0 01             	add    $0x1,%eax
f01056ca:	39 c7                	cmp    %eax,%edi
f01056cc:	75 ef                	jne    f01056bd <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01056ce:	84 d2                	test   %dl,%dl
f01056d0:	74 15                	je     f01056e7 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01056d2:	83 ec 0c             	sub    $0xc,%esp
f01056d5:	68 98 7b 10 f0       	push   $0xf0107b98
f01056da:	e8 88 e1 ff ff       	call   f0103867 <cprintf>
f01056df:	83 c4 10             	add    $0x10,%esp
f01056e2:	e9 a3 01 00 00       	jmp    f010588a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01056e7:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01056eb:	3c 01                	cmp    $0x1,%al
f01056ed:	74 1d                	je     f010570c <mp_init+0x16c>
f01056ef:	3c 04                	cmp    $0x4,%al
f01056f1:	74 19                	je     f010570c <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01056f3:	83 ec 08             	sub    $0x8,%esp
f01056f6:	0f b6 c0             	movzbl %al,%eax
f01056f9:	50                   	push   %eax
f01056fa:	68 bc 7b 10 f0       	push   $0xf0107bbc
f01056ff:	e8 63 e1 ff ff       	call   f0103867 <cprintf>
f0105704:	83 c4 10             	add    $0x10,%esp
f0105707:	e9 7e 01 00 00       	jmp    f010588a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010570c:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105710:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105714:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105719:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010571e:	01 ce                	add    %ecx,%esi
f0105720:	eb 0d                	jmp    f010572f <mp_init+0x18f>
f0105722:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105729:	f0 
f010572a:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010572c:	83 c0 01             	add    $0x1,%eax
f010572f:	39 c7                	cmp    %eax,%edi
f0105731:	75 ef                	jne    f0105722 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105733:	89 d0                	mov    %edx,%eax
f0105735:	02 43 2a             	add    0x2a(%ebx),%al
f0105738:	74 15                	je     f010574f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010573a:	83 ec 0c             	sub    $0xc,%esp
f010573d:	68 dc 7b 10 f0       	push   $0xf0107bdc
f0105742:	e8 20 e1 ff ff       	call   f0103867 <cprintf>
f0105747:	83 c4 10             	add    $0x10,%esp
f010574a:	e9 3b 01 00 00       	jmp    f010588a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010574f:	85 db                	test   %ebx,%ebx
f0105751:	0f 84 33 01 00 00    	je     f010588a <mp_init+0x2ea>
		return;
	ismp = 1;
f0105757:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f010575e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105761:	8b 43 24             	mov    0x24(%ebx),%eax
f0105764:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105769:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f010576c:	be 00 00 00 00       	mov    $0x0,%esi
f0105771:	e9 85 00 00 00       	jmp    f01057fb <mp_init+0x25b>
		switch (*p) {
f0105776:	0f b6 07             	movzbl (%edi),%eax
f0105779:	84 c0                	test   %al,%al
f010577b:	74 06                	je     f0105783 <mp_init+0x1e3>
f010577d:	3c 04                	cmp    $0x4,%al
f010577f:	77 55                	ja     f01057d6 <mp_init+0x236>
f0105781:	eb 4e                	jmp    f01057d1 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105783:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105787:	74 11                	je     f010579a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105789:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f0105790:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105795:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f010579a:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f010579f:	83 f8 07             	cmp    $0x7,%eax
f01057a2:	7f 13                	jg     f01057b7 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01057a4:	6b d0 74             	imul   $0x74,%eax,%edx
f01057a7:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f01057ad:	83 c0 01             	add    $0x1,%eax
f01057b0:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f01057b5:	eb 15                	jmp    f01057cc <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01057b7:	83 ec 08             	sub    $0x8,%esp
f01057ba:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01057be:	50                   	push   %eax
f01057bf:	68 0c 7c 10 f0       	push   $0xf0107c0c
f01057c4:	e8 9e e0 ff ff       	call   f0103867 <cprintf>
f01057c9:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01057cc:	83 c7 14             	add    $0x14,%edi
			continue;
f01057cf:	eb 27                	jmp    f01057f8 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01057d1:	83 c7 08             	add    $0x8,%edi
			continue;
f01057d4:	eb 22                	jmp    f01057f8 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01057d6:	83 ec 08             	sub    $0x8,%esp
f01057d9:	0f b6 c0             	movzbl %al,%eax
f01057dc:	50                   	push   %eax
f01057dd:	68 34 7c 10 f0       	push   $0xf0107c34
f01057e2:	e8 80 e0 ff ff       	call   f0103867 <cprintf>
			ismp = 0;
f01057e7:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f01057ee:	00 00 00 
			i = conf->entry;
f01057f1:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01057f5:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01057f8:	83 c6 01             	add    $0x1,%esi
f01057fb:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01057ff:	39 c6                	cmp    %eax,%esi
f0105801:	0f 82 6f ff ff ff    	jb     f0105776 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105807:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f010580c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105813:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f010581a:	75 26                	jne    f0105842 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f010581c:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f0105823:	00 00 00 
		lapicaddr = 0;
f0105826:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f010582d:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105830:	83 ec 0c             	sub    $0xc,%esp
f0105833:	68 54 7c 10 f0       	push   $0xf0107c54
f0105838:	e8 2a e0 ff ff       	call   f0103867 <cprintf>
		return;
f010583d:	83 c4 10             	add    $0x10,%esp
f0105840:	eb 48                	jmp    f010588a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105842:	83 ec 04             	sub    $0x4,%esp
f0105845:	ff 35 c4 c3 22 f0    	pushl  0xf022c3c4
f010584b:	0f b6 00             	movzbl (%eax),%eax
f010584e:	50                   	push   %eax
f010584f:	68 db 7c 10 f0       	push   $0xf0107cdb
f0105854:	e8 0e e0 ff ff       	call   f0103867 <cprintf>

	if (mp->imcrp) {
f0105859:	83 c4 10             	add    $0x10,%esp
f010585c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010585f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105863:	74 25                	je     f010588a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105865:	83 ec 0c             	sub    $0xc,%esp
f0105868:	68 80 7c 10 f0       	push   $0xf0107c80
f010586d:	e8 f5 df ff ff       	call   f0103867 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105872:	ba 22 00 00 00       	mov    $0x22,%edx
f0105877:	b8 70 00 00 00       	mov    $0x70,%eax
f010587c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010587d:	ba 23 00 00 00       	mov    $0x23,%edx
f0105882:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105883:	83 c8 01             	or     $0x1,%eax
f0105886:	ee                   	out    %al,(%dx)
f0105887:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010588a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010588d:	5b                   	pop    %ebx
f010588e:	5e                   	pop    %esi
f010588f:	5f                   	pop    %edi
f0105890:	5d                   	pop    %ebp
f0105891:	c3                   	ret    

f0105892 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105892:	55                   	push   %ebp
f0105893:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105895:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f010589b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010589e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01058a0:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01058a5:	8b 40 20             	mov    0x20(%eax),%eax
//	panic("after lapicw.\n");
}
f01058a8:	5d                   	pop    %ebp
f01058a9:	c3                   	ret    

f01058aa <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01058aa:	55                   	push   %ebp
f01058ab:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01058ad:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01058b2:	85 c0                	test   %eax,%eax
f01058b4:	74 08                	je     f01058be <cpunum+0x14>
		return lapic[ID] >> 24;
f01058b6:	8b 40 20             	mov    0x20(%eax),%eax
f01058b9:	c1 e8 18             	shr    $0x18,%eax
f01058bc:	eb 05                	jmp    f01058c3 <cpunum+0x19>
	return 0;
f01058be:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058c3:	5d                   	pop    %ebp
f01058c4:	c3                   	ret    

f01058c5 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01058c5:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f01058ca:	85 c0                	test   %eax,%eax
f01058cc:	0f 84 21 01 00 00    	je     f01059f3 <lapic_init+0x12e>
//	panic("after lapicw.\n");
}

void
lapic_init(void)
{
f01058d2:	55                   	push   %ebp
f01058d3:	89 e5                	mov    %esp,%ebp
f01058d5:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01058d8:	68 00 10 00 00       	push   $0x1000
f01058dd:	50                   	push   %eax
f01058de:	e8 16 bb ff ff       	call   f01013f9 <mmio_map_region>
f01058e3:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01058e8:	ba 27 01 00 00       	mov    $0x127,%edx
f01058ed:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01058f2:	e8 9b ff ff ff       	call   f0105892 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01058f7:	ba 0b 00 00 00       	mov    $0xb,%edx
f01058fc:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105901:	e8 8c ff ff ff       	call   f0105892 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105906:	ba 20 00 02 00       	mov    $0x20020,%edx
f010590b:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105910:	e8 7d ff ff ff       	call   f0105892 <lapicw>
	lapicw(TICR, 10000000); 
f0105915:	ba 80 96 98 00       	mov    $0x989680,%edx
f010591a:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010591f:	e8 6e ff ff ff       	call   f0105892 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105924:	e8 81 ff ff ff       	call   f01058aa <cpunum>
f0105929:	6b c0 74             	imul   $0x74,%eax,%eax
f010592c:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105931:	83 c4 10             	add    $0x10,%esp
f0105934:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f010593a:	74 0f                	je     f010594b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f010593c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105941:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105946:	e8 47 ff ff ff       	call   f0105892 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010594b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105950:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105955:	e8 38 ff ff ff       	call   f0105892 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010595a:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f010595f:	8b 40 30             	mov    0x30(%eax),%eax
f0105962:	c1 e8 10             	shr    $0x10,%eax
f0105965:	3c 03                	cmp    $0x3,%al
f0105967:	76 0f                	jbe    f0105978 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105969:	ba 00 00 01 00       	mov    $0x10000,%edx
f010596e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105973:	e8 1a ff ff ff       	call   f0105892 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105978:	ba 33 00 00 00       	mov    $0x33,%edx
f010597d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105982:	e8 0b ff ff ff       	call   f0105892 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105987:	ba 00 00 00 00       	mov    $0x0,%edx
f010598c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105991:	e8 fc fe ff ff       	call   f0105892 <lapicw>
	lapicw(ESR, 0);
f0105996:	ba 00 00 00 00       	mov    $0x0,%edx
f010599b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01059a0:	e8 ed fe ff ff       	call   f0105892 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01059a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01059aa:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01059af:	e8 de fe ff ff       	call   f0105892 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01059b4:	ba 00 00 00 00       	mov    $0x0,%edx
f01059b9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01059be:	e8 cf fe ff ff       	call   f0105892 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01059c3:	ba 00 85 08 00       	mov    $0x88500,%edx
f01059c8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059cd:	e8 c0 fe ff ff       	call   f0105892 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01059d2:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f01059d8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01059de:	f6 c4 10             	test   $0x10,%ah
f01059e1:	75 f5                	jne    f01059d8 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01059e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01059e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01059ed:	e8 a0 fe ff ff       	call   f0105892 <lapicw>
}
f01059f2:	c9                   	leave  
f01059f3:	f3 c3                	repz ret 

f01059f5 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01059f5:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f01059fc:	74 13                	je     f0105a11 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01059fe:	55                   	push   %ebp
f01059ff:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105a01:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a06:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105a0b:	e8 82 fe ff ff       	call   f0105892 <lapicw>
}
f0105a10:	5d                   	pop    %ebp
f0105a11:	f3 c3                	repz ret 

f0105a13 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105a13:	55                   	push   %ebp
f0105a14:	89 e5                	mov    %esp,%ebp
f0105a16:	56                   	push   %esi
f0105a17:	53                   	push   %ebx
f0105a18:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a1e:	ba 70 00 00 00       	mov    $0x70,%edx
f0105a23:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105a28:	ee                   	out    %al,(%dx)
f0105a29:	ba 71 00 00 00       	mov    $0x71,%edx
f0105a2e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a33:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a34:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105a3b:	75 19                	jne    f0105a56 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a3d:	68 67 04 00 00       	push   $0x467
f0105a42:	68 08 60 10 f0       	push   $0xf0106008
f0105a47:	68 99 00 00 00       	push   $0x99
f0105a4c:	68 f8 7c 10 f0       	push   $0xf0107cf8
f0105a51:	e8 3e a6 ff ff       	call   f0100094 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105a56:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105a5d:	00 00 
	wrv[1] = addr >> 4;
f0105a5f:	89 d8                	mov    %ebx,%eax
f0105a61:	c1 e8 04             	shr    $0x4,%eax
f0105a64:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105a6a:	c1 e6 18             	shl    $0x18,%esi
f0105a6d:	89 f2                	mov    %esi,%edx
f0105a6f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a74:	e8 19 fe ff ff       	call   f0105892 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105a79:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105a7e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a83:	e8 0a fe ff ff       	call   f0105892 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105a88:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105a8d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a92:	e8 fb fd ff ff       	call   f0105892 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105a97:	c1 eb 0c             	shr    $0xc,%ebx
f0105a9a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105a9d:	89 f2                	mov    %esi,%edx
f0105a9f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105aa4:	e8 e9 fd ff ff       	call   f0105892 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105aa9:	89 da                	mov    %ebx,%edx
f0105aab:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ab0:	e8 dd fd ff ff       	call   f0105892 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ab5:	89 f2                	mov    %esi,%edx
f0105ab7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105abc:	e8 d1 fd ff ff       	call   f0105892 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ac1:	89 da                	mov    %ebx,%edx
f0105ac3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ac8:	e8 c5 fd ff ff       	call   f0105892 <lapicw>
		microdelay(200);
	}
}
f0105acd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105ad0:	5b                   	pop    %ebx
f0105ad1:	5e                   	pop    %esi
f0105ad2:	5d                   	pop    %ebp
f0105ad3:	c3                   	ret    

f0105ad4 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105ad4:	55                   	push   %ebp
f0105ad5:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105ad7:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ada:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105ae0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ae5:	e8 a8 fd ff ff       	call   f0105892 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105aea:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105af0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105af6:	f6 c4 10             	test   $0x10,%ah
f0105af9:	75 f5                	jne    f0105af0 <lapic_ipi+0x1c>
		;
}
f0105afb:	5d                   	pop    %ebp
f0105afc:	c3                   	ret    

f0105afd <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105afd:	55                   	push   %ebp
f0105afe:	89 e5                	mov    %esp,%ebp
f0105b00:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105b03:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105b09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b0c:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105b0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105b16:	5d                   	pop    %ebp
f0105b17:	c3                   	ret    

f0105b18 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105b18:	55                   	push   %ebp
f0105b19:	89 e5                	mov    %esp,%ebp
f0105b1b:	56                   	push   %esi
f0105b1c:	53                   	push   %ebx
f0105b1d:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105b20:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105b23:	74 14                	je     f0105b39 <spin_lock+0x21>
f0105b25:	8b 73 08             	mov    0x8(%ebx),%esi
f0105b28:	e8 7d fd ff ff       	call   f01058aa <cpunum>
f0105b2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b30:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105b35:	39 c6                	cmp    %eax,%esi
f0105b37:	74 07                	je     f0105b40 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105b39:	ba 01 00 00 00       	mov    $0x1,%edx
f0105b3e:	eb 20                	jmp    f0105b60 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105b40:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105b43:	e8 62 fd ff ff       	call   f01058aa <cpunum>
f0105b48:	83 ec 0c             	sub    $0xc,%esp
f0105b4b:	53                   	push   %ebx
f0105b4c:	50                   	push   %eax
f0105b4d:	68 08 7d 10 f0       	push   $0xf0107d08
f0105b52:	6a 41                	push   $0x41
f0105b54:	68 6c 7d 10 f0       	push   $0xf0107d6c
f0105b59:	e8 36 a5 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105b5e:	f3 90                	pause  
f0105b60:	89 d0                	mov    %edx,%eax
f0105b62:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105b65:	85 c0                	test   %eax,%eax
f0105b67:	75 f5                	jne    f0105b5e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105b69:	e8 3c fd ff ff       	call   f01058aa <cpunum>
f0105b6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b71:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105b76:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105b79:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105b7c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105b7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b83:	eb 0b                	jmp    f0105b90 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105b85:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105b88:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105b8b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105b8d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105b90:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105b96:	76 11                	jbe    f0105ba9 <spin_lock+0x91>
f0105b98:	83 f8 09             	cmp    $0x9,%eax
f0105b9b:	7e e8                	jle    f0105b85 <spin_lock+0x6d>
f0105b9d:	eb 0a                	jmp    f0105ba9 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105b9f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105ba6:	83 c0 01             	add    $0x1,%eax
f0105ba9:	83 f8 09             	cmp    $0x9,%eax
f0105bac:	7e f1                	jle    f0105b9f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105bae:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105bb1:	5b                   	pop    %ebx
f0105bb2:	5e                   	pop    %esi
f0105bb3:	5d                   	pop    %ebp
f0105bb4:	c3                   	ret    

f0105bb5 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105bb5:	55                   	push   %ebp
f0105bb6:	89 e5                	mov    %esp,%ebp
f0105bb8:	57                   	push   %edi
f0105bb9:	56                   	push   %esi
f0105bba:	53                   	push   %ebx
f0105bbb:	83 ec 4c             	sub    $0x4c,%esp
f0105bbe:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105bc1:	83 3e 00             	cmpl   $0x0,(%esi)
f0105bc4:	74 18                	je     f0105bde <spin_unlock+0x29>
f0105bc6:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105bc9:	e8 dc fc ff ff       	call   f01058aa <cpunum>
f0105bce:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bd1:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105bd6:	39 c3                	cmp    %eax,%ebx
f0105bd8:	0f 84 a5 00 00 00    	je     f0105c83 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105bde:	83 ec 04             	sub    $0x4,%esp
f0105be1:	6a 28                	push   $0x28
f0105be3:	8d 46 0c             	lea    0xc(%esi),%eax
f0105be6:	50                   	push   %eax
f0105be7:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105bea:	53                   	push   %ebx
f0105beb:	e8 e6 f6 ff ff       	call   f01052d6 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105bf0:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105bf3:	0f b6 38             	movzbl (%eax),%edi
f0105bf6:	8b 76 04             	mov    0x4(%esi),%esi
f0105bf9:	e8 ac fc ff ff       	call   f01058aa <cpunum>
f0105bfe:	57                   	push   %edi
f0105bff:	56                   	push   %esi
f0105c00:	50                   	push   %eax
f0105c01:	68 34 7d 10 f0       	push   $0xf0107d34
f0105c06:	e8 5c dc ff ff       	call   f0103867 <cprintf>
f0105c0b:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105c0e:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105c11:	eb 54                	jmp    f0105c67 <spin_unlock+0xb2>
f0105c13:	83 ec 08             	sub    $0x8,%esp
f0105c16:	57                   	push   %edi
f0105c17:	50                   	push   %eax
f0105c18:	e8 c3 ec ff ff       	call   f01048e0 <debuginfo_eip>
f0105c1d:	83 c4 10             	add    $0x10,%esp
f0105c20:	85 c0                	test   %eax,%eax
f0105c22:	78 27                	js     f0105c4b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105c24:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105c26:	83 ec 04             	sub    $0x4,%esp
f0105c29:	89 c2                	mov    %eax,%edx
f0105c2b:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105c2e:	52                   	push   %edx
f0105c2f:	ff 75 b0             	pushl  -0x50(%ebp)
f0105c32:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105c35:	ff 75 ac             	pushl  -0x54(%ebp)
f0105c38:	ff 75 a8             	pushl  -0x58(%ebp)
f0105c3b:	50                   	push   %eax
f0105c3c:	68 7c 7d 10 f0       	push   $0xf0107d7c
f0105c41:	e8 21 dc ff ff       	call   f0103867 <cprintf>
f0105c46:	83 c4 20             	add    $0x20,%esp
f0105c49:	eb 12                	jmp    f0105c5d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105c4b:	83 ec 08             	sub    $0x8,%esp
f0105c4e:	ff 36                	pushl  (%esi)
f0105c50:	68 93 7d 10 f0       	push   $0xf0107d93
f0105c55:	e8 0d dc ff ff       	call   f0103867 <cprintf>
f0105c5a:	83 c4 10             	add    $0x10,%esp
f0105c5d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105c60:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105c63:	39 c3                	cmp    %eax,%ebx
f0105c65:	74 08                	je     f0105c6f <spin_unlock+0xba>
f0105c67:	89 de                	mov    %ebx,%esi
f0105c69:	8b 03                	mov    (%ebx),%eax
f0105c6b:	85 c0                	test   %eax,%eax
f0105c6d:	75 a4                	jne    f0105c13 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105c6f:	83 ec 04             	sub    $0x4,%esp
f0105c72:	68 9b 7d 10 f0       	push   $0xf0107d9b
f0105c77:	6a 67                	push   $0x67
f0105c79:	68 6c 7d 10 f0       	push   $0xf0107d6c
f0105c7e:	e8 11 a4 ff ff       	call   f0100094 <_panic>
	}

	lk->pcs[0] = 0;
f0105c83:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105c8a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105c91:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c96:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105c9c:	5b                   	pop    %ebx
f0105c9d:	5e                   	pop    %esi
f0105c9e:	5f                   	pop    %edi
f0105c9f:	5d                   	pop    %ebp
f0105ca0:	c3                   	ret    
f0105ca1:	66 90                	xchg   %ax,%ax
f0105ca3:	66 90                	xchg   %ax,%ax
f0105ca5:	66 90                	xchg   %ax,%ax
f0105ca7:	66 90                	xchg   %ax,%ax
f0105ca9:	66 90                	xchg   %ax,%ax
f0105cab:	66 90                	xchg   %ax,%ax
f0105cad:	66 90                	xchg   %ax,%ax
f0105caf:	90                   	nop

f0105cb0 <__udivdi3>:
f0105cb0:	55                   	push   %ebp
f0105cb1:	57                   	push   %edi
f0105cb2:	56                   	push   %esi
f0105cb3:	53                   	push   %ebx
f0105cb4:	83 ec 1c             	sub    $0x1c,%esp
f0105cb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105cbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105cbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105cc7:	85 f6                	test   %esi,%esi
f0105cc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ccd:	89 ca                	mov    %ecx,%edx
f0105ccf:	89 f8                	mov    %edi,%eax
f0105cd1:	75 3d                	jne    f0105d10 <__udivdi3+0x60>
f0105cd3:	39 cf                	cmp    %ecx,%edi
f0105cd5:	0f 87 c5 00 00 00    	ja     f0105da0 <__udivdi3+0xf0>
f0105cdb:	85 ff                	test   %edi,%edi
f0105cdd:	89 fd                	mov    %edi,%ebp
f0105cdf:	75 0b                	jne    f0105cec <__udivdi3+0x3c>
f0105ce1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ce6:	31 d2                	xor    %edx,%edx
f0105ce8:	f7 f7                	div    %edi
f0105cea:	89 c5                	mov    %eax,%ebp
f0105cec:	89 c8                	mov    %ecx,%eax
f0105cee:	31 d2                	xor    %edx,%edx
f0105cf0:	f7 f5                	div    %ebp
f0105cf2:	89 c1                	mov    %eax,%ecx
f0105cf4:	89 d8                	mov    %ebx,%eax
f0105cf6:	89 cf                	mov    %ecx,%edi
f0105cf8:	f7 f5                	div    %ebp
f0105cfa:	89 c3                	mov    %eax,%ebx
f0105cfc:	89 d8                	mov    %ebx,%eax
f0105cfe:	89 fa                	mov    %edi,%edx
f0105d00:	83 c4 1c             	add    $0x1c,%esp
f0105d03:	5b                   	pop    %ebx
f0105d04:	5e                   	pop    %esi
f0105d05:	5f                   	pop    %edi
f0105d06:	5d                   	pop    %ebp
f0105d07:	c3                   	ret    
f0105d08:	90                   	nop
f0105d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105d10:	39 ce                	cmp    %ecx,%esi
f0105d12:	77 74                	ja     f0105d88 <__udivdi3+0xd8>
f0105d14:	0f bd fe             	bsr    %esi,%edi
f0105d17:	83 f7 1f             	xor    $0x1f,%edi
f0105d1a:	0f 84 98 00 00 00    	je     f0105db8 <__udivdi3+0x108>
f0105d20:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105d25:	89 f9                	mov    %edi,%ecx
f0105d27:	89 c5                	mov    %eax,%ebp
f0105d29:	29 fb                	sub    %edi,%ebx
f0105d2b:	d3 e6                	shl    %cl,%esi
f0105d2d:	89 d9                	mov    %ebx,%ecx
f0105d2f:	d3 ed                	shr    %cl,%ebp
f0105d31:	89 f9                	mov    %edi,%ecx
f0105d33:	d3 e0                	shl    %cl,%eax
f0105d35:	09 ee                	or     %ebp,%esi
f0105d37:	89 d9                	mov    %ebx,%ecx
f0105d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d3d:	89 d5                	mov    %edx,%ebp
f0105d3f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d43:	d3 ed                	shr    %cl,%ebp
f0105d45:	89 f9                	mov    %edi,%ecx
f0105d47:	d3 e2                	shl    %cl,%edx
f0105d49:	89 d9                	mov    %ebx,%ecx
f0105d4b:	d3 e8                	shr    %cl,%eax
f0105d4d:	09 c2                	or     %eax,%edx
f0105d4f:	89 d0                	mov    %edx,%eax
f0105d51:	89 ea                	mov    %ebp,%edx
f0105d53:	f7 f6                	div    %esi
f0105d55:	89 d5                	mov    %edx,%ebp
f0105d57:	89 c3                	mov    %eax,%ebx
f0105d59:	f7 64 24 0c          	mull   0xc(%esp)
f0105d5d:	39 d5                	cmp    %edx,%ebp
f0105d5f:	72 10                	jb     f0105d71 <__udivdi3+0xc1>
f0105d61:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105d65:	89 f9                	mov    %edi,%ecx
f0105d67:	d3 e6                	shl    %cl,%esi
f0105d69:	39 c6                	cmp    %eax,%esi
f0105d6b:	73 07                	jae    f0105d74 <__udivdi3+0xc4>
f0105d6d:	39 d5                	cmp    %edx,%ebp
f0105d6f:	75 03                	jne    f0105d74 <__udivdi3+0xc4>
f0105d71:	83 eb 01             	sub    $0x1,%ebx
f0105d74:	31 ff                	xor    %edi,%edi
f0105d76:	89 d8                	mov    %ebx,%eax
f0105d78:	89 fa                	mov    %edi,%edx
f0105d7a:	83 c4 1c             	add    $0x1c,%esp
f0105d7d:	5b                   	pop    %ebx
f0105d7e:	5e                   	pop    %esi
f0105d7f:	5f                   	pop    %edi
f0105d80:	5d                   	pop    %ebp
f0105d81:	c3                   	ret    
f0105d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105d88:	31 ff                	xor    %edi,%edi
f0105d8a:	31 db                	xor    %ebx,%ebx
f0105d8c:	89 d8                	mov    %ebx,%eax
f0105d8e:	89 fa                	mov    %edi,%edx
f0105d90:	83 c4 1c             	add    $0x1c,%esp
f0105d93:	5b                   	pop    %ebx
f0105d94:	5e                   	pop    %esi
f0105d95:	5f                   	pop    %edi
f0105d96:	5d                   	pop    %ebp
f0105d97:	c3                   	ret    
f0105d98:	90                   	nop
f0105d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105da0:	89 d8                	mov    %ebx,%eax
f0105da2:	f7 f7                	div    %edi
f0105da4:	31 ff                	xor    %edi,%edi
f0105da6:	89 c3                	mov    %eax,%ebx
f0105da8:	89 d8                	mov    %ebx,%eax
f0105daa:	89 fa                	mov    %edi,%edx
f0105dac:	83 c4 1c             	add    $0x1c,%esp
f0105daf:	5b                   	pop    %ebx
f0105db0:	5e                   	pop    %esi
f0105db1:	5f                   	pop    %edi
f0105db2:	5d                   	pop    %ebp
f0105db3:	c3                   	ret    
f0105db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105db8:	39 ce                	cmp    %ecx,%esi
f0105dba:	72 0c                	jb     f0105dc8 <__udivdi3+0x118>
f0105dbc:	31 db                	xor    %ebx,%ebx
f0105dbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105dc2:	0f 87 34 ff ff ff    	ja     f0105cfc <__udivdi3+0x4c>
f0105dc8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105dcd:	e9 2a ff ff ff       	jmp    f0105cfc <__udivdi3+0x4c>
f0105dd2:	66 90                	xchg   %ax,%ax
f0105dd4:	66 90                	xchg   %ax,%ax
f0105dd6:	66 90                	xchg   %ax,%ax
f0105dd8:	66 90                	xchg   %ax,%ax
f0105dda:	66 90                	xchg   %ax,%ax
f0105ddc:	66 90                	xchg   %ax,%ax
f0105dde:	66 90                	xchg   %ax,%ax

f0105de0 <__umoddi3>:
f0105de0:	55                   	push   %ebp
f0105de1:	57                   	push   %edi
f0105de2:	56                   	push   %esi
f0105de3:	53                   	push   %ebx
f0105de4:	83 ec 1c             	sub    $0x1c,%esp
f0105de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105deb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105def:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105df7:	85 d2                	test   %edx,%edx
f0105df9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105dfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105e01:	89 f3                	mov    %esi,%ebx
f0105e03:	89 3c 24             	mov    %edi,(%esp)
f0105e06:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e0a:	75 1c                	jne    f0105e28 <__umoddi3+0x48>
f0105e0c:	39 f7                	cmp    %esi,%edi
f0105e0e:	76 50                	jbe    f0105e60 <__umoddi3+0x80>
f0105e10:	89 c8                	mov    %ecx,%eax
f0105e12:	89 f2                	mov    %esi,%edx
f0105e14:	f7 f7                	div    %edi
f0105e16:	89 d0                	mov    %edx,%eax
f0105e18:	31 d2                	xor    %edx,%edx
f0105e1a:	83 c4 1c             	add    $0x1c,%esp
f0105e1d:	5b                   	pop    %ebx
f0105e1e:	5e                   	pop    %esi
f0105e1f:	5f                   	pop    %edi
f0105e20:	5d                   	pop    %ebp
f0105e21:	c3                   	ret    
f0105e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105e28:	39 f2                	cmp    %esi,%edx
f0105e2a:	89 d0                	mov    %edx,%eax
f0105e2c:	77 52                	ja     f0105e80 <__umoddi3+0xa0>
f0105e2e:	0f bd ea             	bsr    %edx,%ebp
f0105e31:	83 f5 1f             	xor    $0x1f,%ebp
f0105e34:	75 5a                	jne    f0105e90 <__umoddi3+0xb0>
f0105e36:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105e3a:	0f 82 e0 00 00 00    	jb     f0105f20 <__umoddi3+0x140>
f0105e40:	39 0c 24             	cmp    %ecx,(%esp)
f0105e43:	0f 86 d7 00 00 00    	jbe    f0105f20 <__umoddi3+0x140>
f0105e49:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105e4d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105e51:	83 c4 1c             	add    $0x1c,%esp
f0105e54:	5b                   	pop    %ebx
f0105e55:	5e                   	pop    %esi
f0105e56:	5f                   	pop    %edi
f0105e57:	5d                   	pop    %ebp
f0105e58:	c3                   	ret    
f0105e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105e60:	85 ff                	test   %edi,%edi
f0105e62:	89 fd                	mov    %edi,%ebp
f0105e64:	75 0b                	jne    f0105e71 <__umoddi3+0x91>
f0105e66:	b8 01 00 00 00       	mov    $0x1,%eax
f0105e6b:	31 d2                	xor    %edx,%edx
f0105e6d:	f7 f7                	div    %edi
f0105e6f:	89 c5                	mov    %eax,%ebp
f0105e71:	89 f0                	mov    %esi,%eax
f0105e73:	31 d2                	xor    %edx,%edx
f0105e75:	f7 f5                	div    %ebp
f0105e77:	89 c8                	mov    %ecx,%eax
f0105e79:	f7 f5                	div    %ebp
f0105e7b:	89 d0                	mov    %edx,%eax
f0105e7d:	eb 99                	jmp    f0105e18 <__umoddi3+0x38>
f0105e7f:	90                   	nop
f0105e80:	89 c8                	mov    %ecx,%eax
f0105e82:	89 f2                	mov    %esi,%edx
f0105e84:	83 c4 1c             	add    $0x1c,%esp
f0105e87:	5b                   	pop    %ebx
f0105e88:	5e                   	pop    %esi
f0105e89:	5f                   	pop    %edi
f0105e8a:	5d                   	pop    %ebp
f0105e8b:	c3                   	ret    
f0105e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105e90:	8b 34 24             	mov    (%esp),%esi
f0105e93:	bf 20 00 00 00       	mov    $0x20,%edi
f0105e98:	89 e9                	mov    %ebp,%ecx
f0105e9a:	29 ef                	sub    %ebp,%edi
f0105e9c:	d3 e0                	shl    %cl,%eax
f0105e9e:	89 f9                	mov    %edi,%ecx
f0105ea0:	89 f2                	mov    %esi,%edx
f0105ea2:	d3 ea                	shr    %cl,%edx
f0105ea4:	89 e9                	mov    %ebp,%ecx
f0105ea6:	09 c2                	or     %eax,%edx
f0105ea8:	89 d8                	mov    %ebx,%eax
f0105eaa:	89 14 24             	mov    %edx,(%esp)
f0105ead:	89 f2                	mov    %esi,%edx
f0105eaf:	d3 e2                	shl    %cl,%edx
f0105eb1:	89 f9                	mov    %edi,%ecx
f0105eb3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105eb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105ebb:	d3 e8                	shr    %cl,%eax
f0105ebd:	89 e9                	mov    %ebp,%ecx
f0105ebf:	89 c6                	mov    %eax,%esi
f0105ec1:	d3 e3                	shl    %cl,%ebx
f0105ec3:	89 f9                	mov    %edi,%ecx
f0105ec5:	89 d0                	mov    %edx,%eax
f0105ec7:	d3 e8                	shr    %cl,%eax
f0105ec9:	89 e9                	mov    %ebp,%ecx
f0105ecb:	09 d8                	or     %ebx,%eax
f0105ecd:	89 d3                	mov    %edx,%ebx
f0105ecf:	89 f2                	mov    %esi,%edx
f0105ed1:	f7 34 24             	divl   (%esp)
f0105ed4:	89 d6                	mov    %edx,%esi
f0105ed6:	d3 e3                	shl    %cl,%ebx
f0105ed8:	f7 64 24 04          	mull   0x4(%esp)
f0105edc:	39 d6                	cmp    %edx,%esi
f0105ede:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ee2:	89 d1                	mov    %edx,%ecx
f0105ee4:	89 c3                	mov    %eax,%ebx
f0105ee6:	72 08                	jb     f0105ef0 <__umoddi3+0x110>
f0105ee8:	75 11                	jne    f0105efb <__umoddi3+0x11b>
f0105eea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105eee:	73 0b                	jae    f0105efb <__umoddi3+0x11b>
f0105ef0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105ef4:	1b 14 24             	sbb    (%esp),%edx
f0105ef7:	89 d1                	mov    %edx,%ecx
f0105ef9:	89 c3                	mov    %eax,%ebx
f0105efb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105eff:	29 da                	sub    %ebx,%edx
f0105f01:	19 ce                	sbb    %ecx,%esi
f0105f03:	89 f9                	mov    %edi,%ecx
f0105f05:	89 f0                	mov    %esi,%eax
f0105f07:	d3 e0                	shl    %cl,%eax
f0105f09:	89 e9                	mov    %ebp,%ecx
f0105f0b:	d3 ea                	shr    %cl,%edx
f0105f0d:	89 e9                	mov    %ebp,%ecx
f0105f0f:	d3 ee                	shr    %cl,%esi
f0105f11:	09 d0                	or     %edx,%eax
f0105f13:	89 f2                	mov    %esi,%edx
f0105f15:	83 c4 1c             	add    $0x1c,%esp
f0105f18:	5b                   	pop    %ebx
f0105f19:	5e                   	pop    %esi
f0105f1a:	5f                   	pop    %edi
f0105f1b:	5d                   	pop    %ebp
f0105f1c:	c3                   	ret    
f0105f1d:	8d 76 00             	lea    0x0(%esi),%esi
f0105f20:	29 f9                	sub    %edi,%ecx
f0105f22:	19 d6                	sbb    %edx,%esi
f0105f24:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105f2c:	e9 18 ff ff ff       	jmp    f0105e49 <__umoddi3+0x69>
