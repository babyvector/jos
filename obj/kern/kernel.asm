
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
f010004b:	68 60 5f 10 f0       	push   $0xf0105f60
f0100050:	e8 29 38 00 00       	call   f010387e <cprintf>
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
f0100076:	e8 61 08 00 00       	call   f01008dc <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 7c 5f 10 f0       	push   $0xf0105f7c
f0100087:	e8 f2 37 00 00       	call   f010387e <cprintf>


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
f01000b0:	e8 11 58 00 00       	call   f01058c6 <cpunum>
f01000b5:	ff 75 0c             	pushl  0xc(%ebp)
f01000b8:	ff 75 08             	pushl  0x8(%ebp)
f01000bb:	50                   	push   %eax
f01000bc:	68 f0 5f 10 f0       	push   $0xf0105ff0
f01000c1:	e8 b8 37 00 00       	call   f010387e <cprintf>
	vcprintf(fmt, ap);
f01000c6:	83 c4 08             	add    $0x8,%esp
f01000c9:	53                   	push   %ebx
f01000ca:	56                   	push   %esi
f01000cb:	e8 88 37 00 00       	call   f0103858 <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 24 63 10 f0 	movl   $0xf0106324,(%esp)
f01000d7:	e8 a2 37 00 00       	call   f010387e <cprintf>
	va_end(ap);
f01000dc:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	83 ec 0c             	sub    $0xc,%esp
f01000e2:	6a 00                	push   $0x0
f01000e4:	e8 6a 08 00 00       	call   f0100953 <monitor>
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
f0100107:	e8 97 51 00 00       	call   f01052a3 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 8a 05 00 00       	call   f010069b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	68 ac 1a 00 00       	push   $0x1aac
f0100119:	68 97 5f 10 f0       	push   $0xf0105f97
f010011e:	e8 5b 37 00 00       	call   f010387e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100123:	e8 2a 13 00 00       	call   f0101452 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100128:	e8 4f 2f 00 00       	call   f010307c <env_init>

	trap_init();
f010012d:	e8 4d 38 00 00       	call   f010397f <trap_init>
	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100132:	e8 85 54 00 00       	call   f01055bc <mp_init>
	lapic_init();
f0100137:	e8 a5 57 00 00       	call   f01058e1 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013c:	e8 64 36 00 00       	call   f01037a5 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100141:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100148:	e8 e7 59 00 00       	call   f0105b34 <spin_lock>
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
f010015e:	68 14 60 10 f0       	push   $0xf0106014
f0100163:	6a 6d                	push   $0x6d
f0100165:	68 b2 5f 10 f0       	push   $0xf0105fb2
f010016a:	e8 25 ff ff ff       	call   f0100094 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010016f:	83 ec 04             	sub    $0x4,%esp
f0100172:	b8 22 55 10 f0       	mov    $0xf0105522,%eax
f0100177:	2d a8 54 10 f0       	sub    $0xf01054a8,%eax
f010017c:	50                   	push   %eax
f010017d:	68 a8 54 10 f0       	push   $0xf01054a8
f0100182:	68 00 70 00 f0       	push   $0xf0007000
f0100187:	e8 64 51 00 00       	call   f01052f0 <memmove>
f010018c:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018f:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
f0100194:	eb 4d                	jmp    f01001e3 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100196:	e8 2b 57 00 00       	call   f01058c6 <cpunum>
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
f01001d0:	e8 5a 58 00 00       	call   f0105a2f <lapic_startap>
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
	//ENV_CREATE(user_yield,ENV_TYPE_USER);
	//ENV_CREATE(user_yield,ENV_TYPE_USER);
	//ENV_CREATE(user_yield,ENV_TYPE_USER);

	//we use the next  line to test Excerse 7
	ENV_CREATE(user_dumbfork,ENV_TYPE_USER);
f01001f3:	83 ec 08             	sub    $0x8,%esp
f01001f6:	6a 00                	push   $0x0
f01001f8:	68 08 0d 1a f0       	push   $0xf01a0d08
f01001fd:	e8 7f 30 00 00       	call   f0103281 <env_create>
#endif 
	// Schedule and run the first user environment!
	sched_yield();
f0100202:	e8 93 40 00 00       	call   f010429a <sched_yield>

f0100207 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f0100207:	55                   	push   %ebp
f0100208:	89 e5                	mov    %esp,%ebp
f010020a:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f010020d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100212:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100217:	77 15                	ja     f010022e <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100219:	50                   	push   %eax
f010021a:	68 38 60 10 f0       	push   $0xf0106038
f010021f:	68 85 00 00 00       	push   $0x85
f0100224:	68 b2 5f 10 f0       	push   $0xf0105fb2
f0100229:	e8 66 fe ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010022e:	05 00 00 00 10       	add    $0x10000000,%eax
f0100233:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100236:	e8 8b 56 00 00       	call   f01058c6 <cpunum>
f010023b:	83 ec 08             	sub    $0x8,%esp
f010023e:	50                   	push   %eax
f010023f:	68 be 5f 10 f0       	push   $0xf0105fbe
f0100244:	e8 35 36 00 00       	call   f010387e <cprintf>

	lapic_init();
f0100249:	e8 93 56 00 00       	call   f01058e1 <lapic_init>
	env_init_percpu();
f010024e:	e8 f9 2d 00 00       	call   f010304c <env_init_percpu>
	trap_init_percpu();
f0100253:	e8 3a 36 00 00       	call   f0103892 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100258:	e8 69 56 00 00       	call   f01058c6 <cpunum>
f010025d:	6b d0 74             	imul   $0x74,%eax,%edx
f0100260:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100266:	b8 01 00 00 00       	mov    $0x1,%eax
f010026b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010026f:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100276:	e8 b9 58 00 00       	call   f0105b34 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010027b:	e8 1a 40 00 00       	call   f010429a <sched_yield>

f0100280 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100280:	55                   	push   %ebp
f0100281:	89 e5                	mov    %esp,%ebp
f0100283:	53                   	push   %ebx
f0100284:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100287:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010028a:	ff 75 0c             	pushl  0xc(%ebp)
f010028d:	ff 75 08             	pushl  0x8(%ebp)
f0100290:	68 d4 5f 10 f0       	push   $0xf0105fd4
f0100295:	e8 e4 35 00 00       	call   f010387e <cprintf>
	vcprintf(fmt, ap);
f010029a:	83 c4 08             	add    $0x8,%esp
f010029d:	53                   	push   %ebx
f010029e:	ff 75 10             	pushl  0x10(%ebp)
f01002a1:	e8 b2 35 00 00       	call   f0103858 <vcprintf>
	cprintf("\n");
f01002a6:	c7 04 24 24 63 10 f0 	movl   $0xf0106324,(%esp)
f01002ad:	e8 cc 35 00 00       	call   f010387e <cprintf>
	va_end(ap);
}
f01002b2:	83 c4 10             	add    $0x10,%esp
f01002b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002b8:	c9                   	leave  
f01002b9:	c3                   	ret    

f01002ba <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ba:	55                   	push   %ebp
f01002bb:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002bd:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002c3:	a8 01                	test   $0x1,%al
f01002c5:	74 0b                	je     f01002d2 <serial_proc_data+0x18>
f01002c7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002cc:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002cd:	0f b6 c0             	movzbl %al,%eax
f01002d0:	eb 05                	jmp    f01002d7 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002d7:	5d                   	pop    %ebp
f01002d8:	c3                   	ret    

f01002d9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002d9:	55                   	push   %ebp
f01002da:	89 e5                	mov    %esp,%ebp
f01002dc:	53                   	push   %ebx
f01002dd:	83 ec 04             	sub    $0x4,%esp
f01002e0:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002e2:	eb 2b                	jmp    f010030f <cons_intr+0x36>
		if (c == 0)
f01002e4:	85 c0                	test   %eax,%eax
f01002e6:	74 27                	je     f010030f <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002e8:	8b 0d 24 b2 22 f0    	mov    0xf022b224,%ecx
f01002ee:	8d 51 01             	lea    0x1(%ecx),%edx
f01002f1:	89 15 24 b2 22 f0    	mov    %edx,0xf022b224
f01002f7:	88 81 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002fd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100303:	75 0a                	jne    f010030f <cons_intr+0x36>
			cons.wpos = 0;
f0100305:	c7 05 24 b2 22 f0 00 	movl   $0x0,0xf022b224
f010030c:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010030f:	ff d3                	call   *%ebx
f0100311:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100314:	75 ce                	jne    f01002e4 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100316:	83 c4 04             	add    $0x4,%esp
f0100319:	5b                   	pop    %ebx
f010031a:	5d                   	pop    %ebp
f010031b:	c3                   	ret    

f010031c <kbd_proc_data>:
f010031c:	ba 64 00 00 00       	mov    $0x64,%edx
f0100321:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100322:	a8 01                	test   $0x1,%al
f0100324:	0f 84 f8 00 00 00    	je     f0100422 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010032a:	a8 20                	test   $0x20,%al
f010032c:	0f 85 f6 00 00 00    	jne    f0100428 <kbd_proc_data+0x10c>
f0100332:	ba 60 00 00 00       	mov    $0x60,%edx
f0100337:	ec                   	in     (%dx),%al
f0100338:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010033a:	3c e0                	cmp    $0xe0,%al
f010033c:	75 0d                	jne    f010034b <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010033e:	83 0d 00 b0 22 f0 40 	orl    $0x40,0xf022b000
		return 0;
f0100345:	b8 00 00 00 00       	mov    $0x0,%eax
f010034a:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010034b:	55                   	push   %ebp
f010034c:	89 e5                	mov    %esp,%ebp
f010034e:	53                   	push   %ebx
f010034f:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100352:	84 c0                	test   %al,%al
f0100354:	79 36                	jns    f010038c <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100356:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f010035c:	89 cb                	mov    %ecx,%ebx
f010035e:	83 e3 40             	and    $0x40,%ebx
f0100361:	83 e0 7f             	and    $0x7f,%eax
f0100364:	85 db                	test   %ebx,%ebx
f0100366:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100369:	0f b6 d2             	movzbl %dl,%edx
f010036c:	0f b6 82 c0 61 10 f0 	movzbl -0xfef9e40(%edx),%eax
f0100373:	83 c8 40             	or     $0x40,%eax
f0100376:	0f b6 c0             	movzbl %al,%eax
f0100379:	f7 d0                	not    %eax
f010037b:	21 c8                	and    %ecx,%eax
f010037d:	a3 00 b0 22 f0       	mov    %eax,0xf022b000
		return 0;
f0100382:	b8 00 00 00 00       	mov    $0x0,%eax
f0100387:	e9 a4 00 00 00       	jmp    f0100430 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010038c:	8b 0d 00 b0 22 f0    	mov    0xf022b000,%ecx
f0100392:	f6 c1 40             	test   $0x40,%cl
f0100395:	74 0e                	je     f01003a5 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100397:	83 c8 80             	or     $0xffffff80,%eax
f010039a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010039c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010039f:	89 0d 00 b0 22 f0    	mov    %ecx,0xf022b000
	}

	shift |= shiftcode[data];
f01003a5:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01003a8:	0f b6 82 c0 61 10 f0 	movzbl -0xfef9e40(%edx),%eax
f01003af:	0b 05 00 b0 22 f0    	or     0xf022b000,%eax
f01003b5:	0f b6 8a c0 60 10 f0 	movzbl -0xfef9f40(%edx),%ecx
f01003bc:	31 c8                	xor    %ecx,%eax
f01003be:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003c3:	89 c1                	mov    %eax,%ecx
f01003c5:	83 e1 03             	and    $0x3,%ecx
f01003c8:	8b 0c 8d a0 60 10 f0 	mov    -0xfef9f60(,%ecx,4),%ecx
f01003cf:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003d3:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003d6:	a8 08                	test   $0x8,%al
f01003d8:	74 1b                	je     f01003f5 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01003da:	89 da                	mov    %ebx,%edx
f01003dc:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003df:	83 f9 19             	cmp    $0x19,%ecx
f01003e2:	77 05                	ja     f01003e9 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003e4:	83 eb 20             	sub    $0x20,%ebx
f01003e7:	eb 0c                	jmp    f01003f5 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003e9:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ec:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003ef:	83 fa 19             	cmp    $0x19,%edx
f01003f2:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003f5:	f7 d0                	not    %eax
f01003f7:	a8 06                	test   $0x6,%al
f01003f9:	75 33                	jne    f010042e <kbd_proc_data+0x112>
f01003fb:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100401:	75 2b                	jne    f010042e <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100403:	83 ec 0c             	sub    $0xc,%esp
f0100406:	68 5c 60 10 f0       	push   $0xf010605c
f010040b:	e8 6e 34 00 00       	call   f010387e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100410:	ba 92 00 00 00       	mov    $0x92,%edx
f0100415:	b8 03 00 00 00       	mov    $0x3,%eax
f010041a:	ee                   	out    %al,(%dx)
f010041b:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010041e:	89 d8                	mov    %ebx,%eax
f0100420:	eb 0e                	jmp    f0100430 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100427:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100428:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010042d:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010042e:	89 d8                	mov    %ebx,%eax
}
f0100430:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100433:	c9                   	leave  
f0100434:	c3                   	ret    

f0100435 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100435:	55                   	push   %ebp
f0100436:	89 e5                	mov    %esp,%ebp
f0100438:	57                   	push   %edi
f0100439:	56                   	push   %esi
f010043a:	53                   	push   %ebx
f010043b:	83 ec 1c             	sub    $0x1c,%esp
f010043e:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100440:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100445:	be fd 03 00 00       	mov    $0x3fd,%esi
f010044a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010044f:	eb 09                	jmp    f010045a <cons_putc+0x25>
f0100451:	89 ca                	mov    %ecx,%edx
f0100453:	ec                   	in     (%dx),%al
f0100454:	ec                   	in     (%dx),%al
f0100455:	ec                   	in     (%dx),%al
f0100456:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100457:	83 c3 01             	add    $0x1,%ebx
f010045a:	89 f2                	mov    %esi,%edx
f010045c:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010045d:	a8 20                	test   $0x20,%al
f010045f:	75 08                	jne    f0100469 <cons_putc+0x34>
f0100461:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100467:	7e e8                	jle    f0100451 <cons_putc+0x1c>
f0100469:	89 f8                	mov    %edi,%eax
f010046b:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100473:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100474:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100479:	be 79 03 00 00       	mov    $0x379,%esi
f010047e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100483:	eb 09                	jmp    f010048e <cons_putc+0x59>
f0100485:	89 ca                	mov    %ecx,%edx
f0100487:	ec                   	in     (%dx),%al
f0100488:	ec                   	in     (%dx),%al
f0100489:	ec                   	in     (%dx),%al
f010048a:	ec                   	in     (%dx),%al
f010048b:	83 c3 01             	add    $0x1,%ebx
f010048e:	89 f2                	mov    %esi,%edx
f0100490:	ec                   	in     (%dx),%al
f0100491:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100497:	7f 04                	jg     f010049d <cons_putc+0x68>
f0100499:	84 c0                	test   %al,%al
f010049b:	79 e8                	jns    f0100485 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010049d:	ba 78 03 00 00       	mov    $0x378,%edx
f01004a2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01004a6:	ee                   	out    %al,(%dx)
f01004a7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004ac:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004b1:	ee                   	out    %al,(%dx)
f01004b2:	b8 08 00 00 00       	mov    $0x8,%eax
f01004b7:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01004b8:	89 fa                	mov    %edi,%edx
f01004ba:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004c0:	89 f8                	mov    %edi,%eax
f01004c2:	80 cc 07             	or     $0x7,%ah
f01004c5:	85 d2                	test   %edx,%edx
f01004c7:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004ca:	89 f8                	mov    %edi,%eax
f01004cc:	0f b6 c0             	movzbl %al,%eax
f01004cf:	83 f8 09             	cmp    $0x9,%eax
f01004d2:	74 78                	je     f010054c <cons_putc+0x117>
f01004d4:	83 f8 09             	cmp    $0x9,%eax
f01004d7:	7f 0a                	jg     f01004e3 <cons_putc+0xae>
f01004d9:	83 f8 08             	cmp    $0x8,%eax
f01004dc:	74 14                	je     f01004f2 <cons_putc+0xbd>
f01004de:	e9 9d 00 00 00       	jmp    f0100580 <cons_putc+0x14b>
f01004e3:	83 f8 0a             	cmp    $0xa,%eax
f01004e6:	74 3a                	je     f0100522 <cons_putc+0xed>
f01004e8:	83 f8 0d             	cmp    $0xd,%eax
f01004eb:	74 3e                	je     f010052b <cons_putc+0xf6>
f01004ed:	e9 8e 00 00 00       	jmp    f0100580 <cons_putc+0x14b>
	case '\b':
		if (crt_pos > 0) {
f01004f2:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f01004f9:	66 85 c0             	test   %ax,%ax
f01004fc:	0f 84 eb 00 00 00    	je     f01005ed <cons_putc+0x1b8>
			crt_pos--;
f0100502:	83 e8 01             	sub    $0x1,%eax
f0100505:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010050b:	0f b7 c0             	movzwl %ax,%eax
f010050e:	66 81 e7 00 ff       	and    $0xff00,%di
f0100513:	83 cf 20             	or     $0x20,%edi
f0100516:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f010051c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100520:	eb 7c                	jmp    f010059e <cons_putc+0x169>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100522:	66 81 05 28 b2 22 f0 	addw   $0x8f,0xf022b228
f0100529:	8f 00 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010052b:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100532:	69 c0 93 72 00 00    	imul   $0x7293,%eax,%eax
f0100538:	c1 e8 16             	shr    $0x16,%eax
f010053b:	8d 14 c0             	lea    (%eax,%eax,8),%edx
f010053e:	c1 e2 04             	shl    $0x4,%edx
f0100541:	29 c2                	sub    %eax,%edx
f0100543:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
f010054a:	eb 52                	jmp    f010059e <cons_putc+0x169>
		break;
	case '\t':
		cons_putc(' ');
f010054c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100551:	e8 df fe ff ff       	call   f0100435 <cons_putc>
		cons_putc(' ');
f0100556:	b8 20 00 00 00       	mov    $0x20,%eax
f010055b:	e8 d5 fe ff ff       	call   f0100435 <cons_putc>
		cons_putc(' ');
f0100560:	b8 20 00 00 00       	mov    $0x20,%eax
f0100565:	e8 cb fe ff ff       	call   f0100435 <cons_putc>
		cons_putc(' ');
f010056a:	b8 20 00 00 00       	mov    $0x20,%eax
f010056f:	e8 c1 fe ff ff       	call   f0100435 <cons_putc>
		cons_putc(' ');
f0100574:	b8 20 00 00 00       	mov    $0x20,%eax
f0100579:	e8 b7 fe ff ff       	call   f0100435 <cons_putc>
f010057e:	eb 1e                	jmp    f010059e <cons_putc+0x169>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100580:	0f b7 05 28 b2 22 f0 	movzwl 0xf022b228,%eax
f0100587:	8d 50 01             	lea    0x1(%eax),%edx
f010058a:	66 89 15 28 b2 22 f0 	mov    %dx,0xf022b228
f0100591:	0f b7 c0             	movzwl %ax,%eax
f0100594:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f010059a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010059e:	66 81 3d 28 b2 22 f0 	cmpw   $0x1804,0xf022b228
f01005a5:	04 18 
f01005a7:	76 44                	jbe    f01005ed <cons_putc+0x1b8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01005a9:	a1 2c b2 22 f0       	mov    0xf022b22c,%eax
f01005ae:	83 ec 04             	sub    $0x4,%esp
f01005b1:	68 ec 2e 00 00       	push   $0x2eec
f01005b6:	8d 90 1e 01 00 00    	lea    0x11e(%eax),%edx
f01005bc:	52                   	push   %edx
f01005bd:	50                   	push   %eax
f01005be:	e8 2d 4d 00 00       	call   f01052f0 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01005c3:	8b 15 2c b2 22 f0    	mov    0xf022b22c,%edx
f01005c9:	8d 82 ec 2e 00 00    	lea    0x2eec(%edx),%eax
f01005cf:	81 c2 0a 30 00 00    	add    $0x300a,%edx
f01005d5:	83 c4 10             	add    $0x10,%esp
f01005d8:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005dd:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005e0:	39 d0                	cmp    %edx,%eax
f01005e2:	75 f4                	jne    f01005d8 <cons_putc+0x1a3>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005e4:	66 81 2d 28 b2 22 f0 	subw   $0x8f,0xf022b228
f01005eb:	8f 00 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005ed:	8b 0d 30 b2 22 f0    	mov    0xf022b230,%ecx
f01005f3:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005f8:	89 ca                	mov    %ecx,%edx
f01005fa:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005fb:	0f b7 1d 28 b2 22 f0 	movzwl 0xf022b228,%ebx
f0100602:	8d 71 01             	lea    0x1(%ecx),%esi
f0100605:	89 d8                	mov    %ebx,%eax
f0100607:	66 c1 e8 08          	shr    $0x8,%ax
f010060b:	89 f2                	mov    %esi,%edx
f010060d:	ee                   	out    %al,(%dx)
f010060e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ee                   	out    %al,(%dx)
f0100616:	89 d8                	mov    %ebx,%eax
f0100618:	89 f2                	mov    %esi,%edx
f010061a:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010061e:	5b                   	pop    %ebx
f010061f:	5e                   	pop    %esi
f0100620:	5f                   	pop    %edi
f0100621:	5d                   	pop    %ebp
f0100622:	c3                   	ret    

f0100623 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100623:	80 3d 34 b2 22 f0 00 	cmpb   $0x0,0xf022b234
f010062a:	74 11                	je     f010063d <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010062c:	55                   	push   %ebp
f010062d:	89 e5                	mov    %esp,%ebp
f010062f:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100632:	b8 ba 02 10 f0       	mov    $0xf01002ba,%eax
f0100637:	e8 9d fc ff ff       	call   f01002d9 <cons_intr>
}
f010063c:	c9                   	leave  
f010063d:	f3 c3                	repz ret 

f010063f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010063f:	55                   	push   %ebp
f0100640:	89 e5                	mov    %esp,%ebp
f0100642:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100645:	b8 1c 03 10 f0       	mov    $0xf010031c,%eax
f010064a:	e8 8a fc ff ff       	call   f01002d9 <cons_intr>
}
f010064f:	c9                   	leave  
f0100650:	c3                   	ret    

f0100651 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100651:	55                   	push   %ebp
f0100652:	89 e5                	mov    %esp,%ebp
f0100654:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100657:	e8 c7 ff ff ff       	call   f0100623 <serial_intr>
	kbd_intr();
f010065c:	e8 de ff ff ff       	call   f010063f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100661:	a1 20 b2 22 f0       	mov    0xf022b220,%eax
f0100666:	3b 05 24 b2 22 f0    	cmp    0xf022b224,%eax
f010066c:	74 26                	je     f0100694 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010066e:	8d 50 01             	lea    0x1(%eax),%edx
f0100671:	89 15 20 b2 22 f0    	mov    %edx,0xf022b220
f0100677:	0f b6 88 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010067e:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100680:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100686:	75 11                	jne    f0100699 <cons_getc+0x48>
			cons.rpos = 0;
f0100688:	c7 05 20 b2 22 f0 00 	movl   $0x0,0xf022b220
f010068f:	00 00 00 
f0100692:	eb 05                	jmp    f0100699 <cons_getc+0x48>
		return c;
	}
	return 0;
f0100694:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100699:	c9                   	leave  
f010069a:	c3                   	ret    

f010069b <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010069b:	55                   	push   %ebp
f010069c:	89 e5                	mov    %esp,%ebp
f010069e:	57                   	push   %edi
f010069f:	56                   	push   %esi
f01006a0:	53                   	push   %ebx
f01006a1:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006a4:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01006ab:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006b2:	5a a5 
	if (*cp != 0xA55A) {
f01006b4:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006bb:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006bf:	74 11                	je     f01006d2 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006c1:	c7 05 30 b2 22 f0 b4 	movl   $0x3b4,0xf022b230
f01006c8:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006cb:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006d0:	eb 16                	jmp    f01006e8 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006d2:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006d9:	c7 05 30 b2 22 f0 d4 	movl   $0x3d4,0xf022b230
f01006e0:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006e3:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006e8:	8b 3d 30 b2 22 f0    	mov    0xf022b230,%edi
f01006ee:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006f3:	89 fa                	mov    %edi,%edx
f01006f5:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006f6:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f9:	89 da                	mov    %ebx,%edx
f01006fb:	ec                   	in     (%dx),%al
f01006fc:	0f b6 c8             	movzbl %al,%ecx
f01006ff:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100702:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100707:	89 fa                	mov    %edi,%edx
f0100709:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070a:	89 da                	mov    %ebx,%edx
f010070c:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010070d:	89 35 2c b2 22 f0    	mov    %esi,0xf022b22c
	crt_pos = pos;
f0100713:	0f b6 c0             	movzbl %al,%eax
f0100716:	09 c8                	or     %ecx,%eax
f0100718:	66 a3 28 b2 22 f0    	mov    %ax,0xf022b228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010071e:	e8 1c ff ff ff       	call   f010063f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100723:	83 ec 0c             	sub    $0xc,%esp
f0100726:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010072d:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100732:	50                   	push   %eax
f0100733:	e8 f5 2f 00 00       	call   f010372d <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100738:	be fa 03 00 00       	mov    $0x3fa,%esi
f010073d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100742:	89 f2                	mov    %esi,%edx
f0100744:	ee                   	out    %al,(%dx)
f0100745:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010074a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010074f:	ee                   	out    %al,(%dx)
f0100750:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100755:	b8 0c 00 00 00       	mov    $0xc,%eax
f010075a:	89 da                	mov    %ebx,%edx
f010075c:	ee                   	out    %al,(%dx)
f010075d:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100762:	b8 00 00 00 00       	mov    $0x0,%eax
f0100767:	ee                   	out    %al,(%dx)
f0100768:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010076d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100772:	ee                   	out    %al,(%dx)
f0100773:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100778:	b8 00 00 00 00       	mov    $0x0,%eax
f010077d:	ee                   	out    %al,(%dx)
f010077e:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100783:	b8 01 00 00 00       	mov    $0x1,%eax
f0100788:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100789:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010078e:	ec                   	in     (%dx),%al
f010078f:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100791:	83 c4 10             	add    $0x10,%esp
f0100794:	3c ff                	cmp    $0xff,%al
f0100796:	0f 95 05 34 b2 22 f0 	setne  0xf022b234
f010079d:	89 f2                	mov    %esi,%edx
f010079f:	ec                   	in     (%dx),%al
f01007a0:	89 da                	mov    %ebx,%edx
f01007a2:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007a3:	80 f9 ff             	cmp    $0xff,%cl
f01007a6:	75 10                	jne    f01007b8 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f01007a8:	83 ec 0c             	sub    $0xc,%esp
f01007ab:	68 68 60 10 f0       	push   $0xf0106068
f01007b0:	e8 c9 30 00 00       	call   f010387e <cprintf>
f01007b5:	83 c4 10             	add    $0x10,%esp
}
f01007b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007bb:	5b                   	pop    %ebx
f01007bc:	5e                   	pop    %esi
f01007bd:	5f                   	pop    %edi
f01007be:	5d                   	pop    %ebp
f01007bf:	c3                   	ret    

f01007c0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01007c0:	55                   	push   %ebp
f01007c1:	89 e5                	mov    %esp,%ebp
f01007c3:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01007c9:	e8 67 fc ff ff       	call   f0100435 <cons_putc>
}
f01007ce:	c9                   	leave  
f01007cf:	c3                   	ret    

f01007d0 <getchar>:

int
getchar(void)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007d6:	e8 76 fe ff ff       	call   f0100651 <cons_getc>
f01007db:	85 c0                	test   %eax,%eax
f01007dd:	74 f7                	je     f01007d6 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007df:	c9                   	leave  
f01007e0:	c3                   	ret    

f01007e1 <iscons>:

int
iscons(int fdnum)
{
f01007e1:	55                   	push   %ebp
f01007e2:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007e4:	b8 01 00 00 00       	mov    $0x1,%eax
f01007e9:	5d                   	pop    %ebp
f01007ea:	c3                   	ret    

f01007eb <mon_quit>:

	}

	return 0x1001;
}
int mon_quit(int agrc,char **agrv,struct Trapframe *tf){
f01007eb:	55                   	push   %ebp
f01007ec:	89 e5                	mov    %esp,%ebp
	
	return -1;
}
f01007ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007f3:	5d                   	pop    %ebp
f01007f4:	c3                   	ret    

f01007f5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
f01007f8:	56                   	push   %esi
f01007f9:	53                   	push   %ebx
f01007fa:	bb c0 65 10 f0       	mov    $0xf01065c0,%ebx
f01007ff:	be f0 65 10 f0       	mov    $0xf01065f0,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100804:	83 ec 04             	sub    $0x4,%esp
f0100807:	ff 73 04             	pushl  0x4(%ebx)
f010080a:	ff 33                	pushl  (%ebx)
f010080c:	68 c0 62 10 f0       	push   $0xf01062c0
f0100811:	e8 68 30 00 00       	call   f010387e <cprintf>
f0100816:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100819:	83 c4 10             	add    $0x10,%esp
f010081c:	39 f3                	cmp    %esi,%ebx
f010081e:	75 e4                	jne    f0100804 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100820:	b8 00 00 00 00       	mov    $0x0,%eax
f0100825:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100828:	5b                   	pop    %ebx
f0100829:	5e                   	pop    %esi
f010082a:	5d                   	pop    %ebp
f010082b:	c3                   	ret    

f010082c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010082c:	55                   	push   %ebp
f010082d:	89 e5                	mov    %esp,%ebp
f010082f:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100832:	68 c9 62 10 f0       	push   $0xf01062c9
f0100837:	e8 42 30 00 00       	call   f010387e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010083c:	83 c4 08             	add    $0x8,%esp
f010083f:	68 0c 00 10 00       	push   $0x10000c
f0100844:	68 c4 63 10 f0       	push   $0xf01063c4
f0100849:	e8 30 30 00 00       	call   f010387e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 0c 00 10 00       	push   $0x10000c
f0100856:	68 0c 00 10 f0       	push   $0xf010000c
f010085b:	68 ec 63 10 f0       	push   $0xf01063ec
f0100860:	e8 19 30 00 00       	call   f010387e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 41 5f 10 00       	push   $0x105f41
f010086d:	68 41 5f 10 f0       	push   $0xf0105f41
f0100872:	68 10 64 10 f0       	push   $0xf0106410
f0100877:	e8 02 30 00 00       	call   f010387e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010087c:	83 c4 0c             	add    $0xc,%esp
f010087f:	68 98 a5 22 00       	push   $0x22a598
f0100884:	68 98 a5 22 f0       	push   $0xf022a598
f0100889:	68 34 64 10 f0       	push   $0xf0106434
f010088e:	e8 eb 2f 00 00       	call   f010387e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100893:	83 c4 0c             	add    $0xc,%esp
f0100896:	68 08 d0 26 00       	push   $0x26d008
f010089b:	68 08 d0 26 f0       	push   $0xf026d008
f01008a0:	68 58 64 10 f0       	push   $0xf0106458
f01008a5:	e8 d4 2f 00 00       	call   f010387e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01008aa:	b8 07 d4 26 f0       	mov    $0xf026d407,%eax
f01008af:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b4:	83 c4 08             	add    $0x8,%esp
f01008b7:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01008bc:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008c2:	85 c0                	test   %eax,%eax
f01008c4:	0f 48 c2             	cmovs  %edx,%eax
f01008c7:	c1 f8 0a             	sar    $0xa,%eax
f01008ca:	50                   	push   %eax
f01008cb:	68 7c 64 10 f0       	push   $0xf010647c
f01008d0:	e8 a9 2f 00 00       	call   f010387e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008da:	c9                   	leave  
f01008db:	c3                   	ret    

f01008dc <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008dc:	55                   	push   %ebp
f01008dd:	89 e5                	mov    %esp,%ebp
f01008df:	57                   	push   %edi
f01008e0:	56                   	push   %esi
f01008e1:	53                   	push   %ebx
f01008e2:	83 ec 2c             	sub    $0x2c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008e5:	89 ea                	mov    %ebp,%edx
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
f01008e7:	89 d0                	mov    %edx,%eax
	int before_ebp = *(int*)esp_position;
f01008e9:	8b 32                	mov    (%edx),%esi
		int pra_5 = (int)*((int*)esp_position+6);
	
		cprintf("ebp:0x%8.0x eip:0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x\n",esp_position,eip,pra_1,pra_2,pra_3,pra_4,pra_5);
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f01008eb:	8d 7d d0             	lea    -0x30(%ebp),%edi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
	int before_ebp = *(int*)esp_position;
	while(before_ebp != 0){//here the ebp is 0,because the i386_init set it 0 before it comes into a real function
f01008ee:	eb 48                	jmp    f0100938 <mon_backtrace+0x5c>
		before_ebp = *(int*)esp_position;//read the ebp of the before stack
f01008f0:	8b 30                	mov    (%eax),%esi
		int eip = (int)*((int*)esp_position+1);
f01008f2:	8b 58 04             	mov    0x4(%eax),%ebx
		int pra_2 = (int)*((int*)esp_position+3);
		int pra_3 = (int)*((int*)esp_position+4);
		int pra_4 = (int)*((int*)esp_position+5);
		int pra_5 = (int)*((int*)esp_position+6);
	
		cprintf("ebp:0x%8.0x eip:0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x 0x%8.0x\n",esp_position,eip,pra_1,pra_2,pra_3,pra_4,pra_5);
f01008f5:	ff 70 18             	pushl  0x18(%eax)
f01008f8:	ff 70 14             	pushl  0x14(%eax)
f01008fb:	ff 70 10             	pushl  0x10(%eax)
f01008fe:	ff 70 0c             	pushl  0xc(%eax)
f0100901:	ff 70 08             	pushl  0x8(%eax)
f0100904:	53                   	push   %ebx
f0100905:	50                   	push   %eax
f0100906:	68 a8 64 10 f0       	push   $0xf01064a8
f010090b:	e8 6e 2f 00 00       	call   f010387e <cprintf>
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f0100910:	83 c4 18             	add    $0x18,%esp
f0100913:	57                   	push   %edi
f0100914:	53                   	push   %ebx
f0100915:	e8 e0 3f 00 00       	call   f01048fa <debuginfo_eip>
		cprintf("%s:%d   %s:%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip-info.eip_fn_addr);	
f010091a:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010091d:	89 1c 24             	mov    %ebx,(%esp)
f0100920:	ff 75 d8             	pushl  -0x28(%ebp)
f0100923:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100926:	ff 75 d0             	pushl  -0x30(%ebp)
f0100929:	68 e2 62 10 f0       	push   $0xf01062e2
f010092e:	e8 4b 2f 00 00       	call   f010387e <cprintf>
f0100933:	83 c4 20             	add    $0x20,%esp

		//finally we can get the pra num of one function by info.
		esp_position = before_ebp;		
f0100936:	89 f0                	mov    %esi,%eax
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int esp_position = read_ebp();//read the ebp of the mon_b function which points to the positon of the ebp which belongs to the before function(nested in) and the position+1 is the ret ip value of this mon_b function and position+n is the n-1 pra that sent into this funcion.	
	int before_ebp = *(int*)esp_position;
	while(before_ebp != 0){//here the ebp is 0,because the i386_init set it 0 before it comes into a real function
f0100938:	85 f6                	test   %esi,%esi
f010093a:	75 b4                	jne    f01008f0 <mon_backtrace+0x14>
		esp_position = before_ebp;		

	}

	return 0x1001;
}
f010093c:	b8 01 10 00 00       	mov    $0x1001,%eax
f0100941:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100944:	5b                   	pop    %ebx
f0100945:	5e                   	pop    %esi
f0100946:	5f                   	pop    %edi
f0100947:	5d                   	pop    %ebp
f0100948:	c3                   	ret    

f0100949 <mon_test>:
int mon_quit(int agrc,char **agrv,struct Trapframe *tf){
	
	return -1;
}
//just my own code for test ,delete please.
int mon_test(int argc,char **argv,int argc1,int argc2,int argc3,int argc4,struct Trapframe *tf){
f0100949:	55                   	push   %ebp
f010094a:	89 e5                	mov    %esp,%ebp
	return 1;
}
f010094c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100951:	5d                   	pop    %ebp
f0100952:	c3                   	ret    

f0100953 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100953:	55                   	push   %ebp
f0100954:	89 e5                	mov    %esp,%ebp
f0100956:	57                   	push   %edi
f0100957:	56                   	push   %esi
f0100958:	53                   	push   %ebx
f0100959:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010095c:	68 ec 64 10 f0       	push   $0xf01064ec
f0100961:	e8 18 2f 00 00       	call   f010387e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100966:	c7 04 24 10 65 10 f0 	movl   $0xf0106510,(%esp)
f010096d:	e8 0c 2f 00 00       	call   f010387e <cprintf>


	if (tf != NULL)
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100979:	74 0e                	je     f0100989 <monitor+0x36>
		print_trapframe(tf);
f010097b:	83 ec 0c             	sub    $0xc,%esp
f010097e:	ff 75 08             	pushl  0x8(%ebp)
f0100981:	e8 9a 33 00 00       	call   f0103d20 <print_trapframe>
f0100986:	83 c4 10             	add    $0x10,%esp


	//my code here 
	cprintf("here show code of myself\n");
f0100989:	83 ec 0c             	sub    $0xc,%esp
f010098c:	68 f1 62 10 f0       	push   $0xf01062f1
f0100991:	e8 e8 2e 00 00       	call   f010387e <cprintf>
	for(int i = 0;i<200;i++){
		cprintf("%d",i);
		cprintf("abcdefghijklmnopqrstuvwxyz0123456789");
	}
	*/
	cprintf("yourname is xuyongkang.");
f0100996:	c7 04 24 0b 63 10 f0 	movl   $0xf010630b,(%esp)
f010099d:	e8 dc 2e 00 00       	call   f010387e <cprintf>
	cprintf("\033[1m\033[45;33m HELLO_WORLD \033[0m\n");
f01009a2:	c7 04 24 38 65 10 f0 	movl   $0xf0106538,(%esp)
f01009a9:	e8 d0 2e 00 00       	call   f010387e <cprintf>
	cprintf("\a\n");
f01009ae:	c7 04 24 23 63 10 f0 	movl   $0xf0106323,(%esp)
f01009b5:	e8 c4 2e 00 00       	call   f010387e <cprintf>
	cprintf("\a\n");
f01009ba:	c7 04 24 23 63 10 f0 	movl   $0xf0106323,(%esp)
f01009c1:	e8 b8 2e 00 00       	call   f010387e <cprintf>
	int x = 1,y = 3,z = 4;
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009c6:	6a 04                	push   $0x4
f01009c8:	6a 03                	push   $0x3
f01009ca:	6a 01                	push   $0x1
f01009cc:	68 26 63 10 f0       	push   $0xf0106326
f01009d1:	e8 a8 2e 00 00       	call   f010387e <cprintf>
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009d6:	83 c4 20             	add    $0x20,%esp
f01009d9:	6a 04                	push   $0x4
f01009db:	6a 03                	push   $0x3
f01009dd:	6a 01                	push   $0x1
f01009df:	68 26 63 10 f0       	push   $0xf0106326
f01009e4:	e8 95 2e 00 00       	call   f010387e <cprintf>
 	cprintf("x,y,x");
f01009e9:	c7 04 24 36 63 10 f0 	movl   $0xf0106336,(%esp)
f01009f0:	e8 89 2e 00 00       	call   f010387e <cprintf>
f01009f5:	83 c4 10             	add    $0x10,%esp
       

	//my code end

	while (1) {
		buf = readline("K> ");
f01009f8:	83 ec 0c             	sub    $0xc,%esp
f01009fb:	68 3c 63 10 f0       	push   $0xf010633c
f0100a00:	e8 47 46 00 00       	call   f010504c <readline>
f0100a05:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a07:	83 c4 10             	add    $0x10,%esp
f0100a0a:	85 c0                	test   %eax,%eax
f0100a0c:	74 ea                	je     f01009f8 <monitor+0xa5>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100a0e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100a15:	be 00 00 00 00       	mov    $0x0,%esi
f0100a1a:	eb 0a                	jmp    f0100a26 <monitor+0xd3>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100a1c:	c6 03 00             	movb   $0x0,(%ebx)
f0100a1f:	89 f7                	mov    %esi,%edi
f0100a21:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a24:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100a26:	0f b6 03             	movzbl (%ebx),%eax
f0100a29:	84 c0                	test   %al,%al
f0100a2b:	74 63                	je     f0100a90 <monitor+0x13d>
f0100a2d:	83 ec 08             	sub    $0x8,%esp
f0100a30:	0f be c0             	movsbl %al,%eax
f0100a33:	50                   	push   %eax
f0100a34:	68 40 63 10 f0       	push   $0xf0106340
f0100a39:	e8 28 48 00 00       	call   f0105266 <strchr>
f0100a3e:	83 c4 10             	add    $0x10,%esp
f0100a41:	85 c0                	test   %eax,%eax
f0100a43:	75 d7                	jne    f0100a1c <monitor+0xc9>
			*buf++ = 0;
		if (*buf == 0)
f0100a45:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a48:	74 46                	je     f0100a90 <monitor+0x13d>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100a4a:	83 fe 0f             	cmp    $0xf,%esi
f0100a4d:	75 14                	jne    f0100a63 <monitor+0x110>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a4f:	83 ec 08             	sub    $0x8,%esp
f0100a52:	6a 10                	push   $0x10
f0100a54:	68 45 63 10 f0       	push   $0xf0106345
f0100a59:	e8 20 2e 00 00       	call   f010387e <cprintf>
f0100a5e:	83 c4 10             	add    $0x10,%esp
f0100a61:	eb 95                	jmp    f01009f8 <monitor+0xa5>
			return 0;
		}
		argv[argc++] = buf;
f0100a63:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a66:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a6a:	eb 03                	jmp    f0100a6f <monitor+0x11c>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a6c:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a6f:	0f b6 03             	movzbl (%ebx),%eax
f0100a72:	84 c0                	test   %al,%al
f0100a74:	74 ae                	je     f0100a24 <monitor+0xd1>
f0100a76:	83 ec 08             	sub    $0x8,%esp
f0100a79:	0f be c0             	movsbl %al,%eax
f0100a7c:	50                   	push   %eax
f0100a7d:	68 40 63 10 f0       	push   $0xf0106340
f0100a82:	e8 df 47 00 00       	call   f0105266 <strchr>
f0100a87:	83 c4 10             	add    $0x10,%esp
f0100a8a:	85 c0                	test   %eax,%eax
f0100a8c:	74 de                	je     f0100a6c <monitor+0x119>
f0100a8e:	eb 94                	jmp    f0100a24 <monitor+0xd1>
			buf++;
	}
	argv[argc] = 0;
f0100a90:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a97:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a98:	85 f6                	test   %esi,%esi
f0100a9a:	0f 84 58 ff ff ff    	je     f01009f8 <monitor+0xa5>
f0100aa0:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aa5:	83 ec 08             	sub    $0x8,%esp
f0100aa8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aab:	ff 34 85 c0 65 10 f0 	pushl  -0xfef9a40(,%eax,4)
f0100ab2:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ab5:	e8 4e 47 00 00       	call   f0105208 <strcmp>
f0100aba:	83 c4 10             	add    $0x10,%esp
f0100abd:	85 c0                	test   %eax,%eax
f0100abf:	75 21                	jne    f0100ae2 <monitor+0x18f>
			return commands[i].func(argc, argv, tf);
f0100ac1:	83 ec 04             	sub    $0x4,%esp
f0100ac4:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ac7:	ff 75 08             	pushl  0x8(%ebp)
f0100aca:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100acd:	52                   	push   %edx
f0100ace:	56                   	push   %esi
f0100acf:	ff 14 85 c8 65 10 f0 	call   *-0xfef9a38(,%eax,4)
	//my code end

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100ad6:	83 c4 10             	add    $0x10,%esp
f0100ad9:	85 c0                	test   %eax,%eax
f0100adb:	78 25                	js     f0100b02 <monitor+0x1af>
f0100add:	e9 16 ff ff ff       	jmp    f01009f8 <monitor+0xa5>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ae2:	83 c3 01             	add    $0x1,%ebx
f0100ae5:	83 fb 04             	cmp    $0x4,%ebx
f0100ae8:	75 bb                	jne    f0100aa5 <monitor+0x152>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aea:	83 ec 08             	sub    $0x8,%esp
f0100aed:	ff 75 a8             	pushl  -0x58(%ebp)
f0100af0:	68 62 63 10 f0       	push   $0xf0106362
f0100af5:	e8 84 2d 00 00       	call   f010387e <cprintf>
f0100afa:	83 c4 10             	add    $0x10,%esp
f0100afd:	e9 f6 fe ff ff       	jmp    f01009f8 <monitor+0xa5>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b05:	5b                   	pop    %ebx
f0100b06:	5e                   	pop    %esi
f0100b07:	5f                   	pop    %edi
f0100b08:	5d                   	pop    %ebp
f0100b09:	c3                   	ret    

f0100b0a <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b0a:	55                   	push   %ebp
f0100b0b:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b0d:	83 3d 38 b2 22 f0 00 	cmpl   $0x0,0xf022b238
f0100b14:	75 11                	jne    f0100b27 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b16:	ba 07 e0 26 f0       	mov    $0xf026e007,%edx
f0100b1b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b21:	89 15 38 b2 22 f0    	mov    %edx,0xf022b238
	if(n>0){
		result = nextfree;
		nextfree = ROUNDUP(nextfree+n,PGSIZE);
		return result;
	}else{
		return nextfree;
f0100b27:	8b 15 38 b2 22 f0    	mov    0xf022b238,%edx
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n>0){
f0100b2d:	85 c0                	test   %eax,%eax
f0100b2f:	74 11                	je     f0100b42 <boot_alloc+0x38>
		result = nextfree;
		nextfree = ROUNDUP(nextfree+n,PGSIZE);
f0100b31:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b38:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3d:	a3 38 b2 22 f0       	mov    %eax,0xf022b238
		return result;
	}else{
		return nextfree;
	}
	return NULL;
}
f0100b42:	89 d0                	mov    %edx,%eax
f0100b44:	5d                   	pop    %ebp
f0100b45:	c3                   	ret    

f0100b46 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b46:	55                   	push   %ebp
f0100b47:	89 e5                	mov    %esp,%ebp
f0100b49:	56                   	push   %esi
f0100b4a:	53                   	push   %ebx
f0100b4b:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b4d:	83 ec 0c             	sub    $0xc,%esp
f0100b50:	50                   	push   %eax
f0100b51:	e8 a9 2b 00 00       	call   f01036ff <mc146818_read>
f0100b56:	89 c6                	mov    %eax,%esi
f0100b58:	83 c3 01             	add    $0x1,%ebx
f0100b5b:	89 1c 24             	mov    %ebx,(%esp)
f0100b5e:	e8 9c 2b 00 00       	call   f01036ff <mc146818_read>
f0100b63:	c1 e0 08             	shl    $0x8,%eax
f0100b66:	09 f0                	or     %esi,%eax
}
f0100b68:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b6b:	5b                   	pop    %ebx
f0100b6c:	5e                   	pop    %esi
f0100b6d:	5d                   	pop    %ebp
f0100b6e:	c3                   	ret    

f0100b6f <check_va2pa>:
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
//	cprintf("	*pgdir: 0x%x\n",*pgdir);
	if (!(*pgdir & PTE_P))
f0100b6f:	89 d1                	mov    %edx,%ecx
f0100b71:	c1 e9 16             	shr    $0x16,%ecx
f0100b74:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b77:	a8 01                	test   $0x1,%al
f0100b79:	74 52                	je     f0100bcd <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b80:	89 c1                	mov    %eax,%ecx
f0100b82:	c1 e9 0c             	shr    $0xc,%ecx
f0100b85:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0100b8b:	72 1b                	jb     f0100ba8 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b8d:	55                   	push   %ebp
f0100b8e:	89 e5                	mov    %esp,%ebp
f0100b90:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b93:	50                   	push   %eax
f0100b94:	68 14 60 10 f0       	push   $0xf0106014
f0100b99:	68 44 05 00 00       	push   $0x544
f0100b9e:	68 61 6f 10 f0       	push   $0xf0106f61
f0100ba3:	e8 ec f4 ff ff       	call   f0100094 <_panic>
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
//	cprintf("	PTX(va):%x\n",PTX(va));
//	cprintf("	p[PTX(va)]:0x%x\n",p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
f0100ba8:	c1 ea 0c             	shr    $0xc,%edx
f0100bab:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100bb1:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100bb8:	89 c2                	mov    %eax,%edx
f0100bba:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100bbd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bc2:	85 d2                	test   %edx,%edx
f0100bc4:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bc9:	0f 44 c2             	cmove  %edx,%eax
f0100bcc:	c3                   	ret    
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
//	cprintf("	*pgdir: 0x%x\n",*pgdir);
	if (!(*pgdir & PTE_P))
		return ~0;
f0100bcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
//	cprintf("	PTX(va):%x\n",PTX(va));
//	cprintf("	p[PTX(va)]:0x%x\n",p[PTX(va)]);
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100bd2:	c3                   	ret    

f0100bd3 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100bd3:	55                   	push   %ebp
f0100bd4:	89 e5                	mov    %esp,%ebp
f0100bd6:	57                   	push   %edi
f0100bd7:	56                   	push   %esi
f0100bd8:	53                   	push   %ebx
f0100bd9:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bdc:	84 c0                	test   %al,%al
f0100bde:	0f 85 9d 02 00 00    	jne    f0100e81 <check_page_free_list+0x2ae>
f0100be4:	e9 aa 02 00 00       	jmp    f0100e93 <check_page_free_list+0x2c0>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100be9:	83 ec 04             	sub    $0x4,%esp
f0100bec:	68 f0 65 10 f0       	push   $0xf01065f0
f0100bf1:	68 46 04 00 00       	push   $0x446
f0100bf6:	68 61 6f 10 f0       	push   $0xf0106f61
f0100bfb:	e8 94 f4 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100c00:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c03:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c06:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c0c:	89 c2                	mov    %eax,%edx
f0100c0e:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0100c14:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c1a:	0f 95 c2             	setne  %dl
f0100c1d:	0f b6 d2             	movzbl %dl,%edx
			//cprintf("page2pa(pp):%x\n",page2pa(pp));
			//cprintf("PDX(page2pa(pp)):%x\n",PDX(page2pa(pp)));
			//cprintf("pagetype:%x\n",pagetype);
			*tp[pagetype] = pp;
f0100c20:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100c24:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100c26:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c2a:	8b 00                	mov    (%eax),%eax
f0100c2c:	85 c0                	test   %eax,%eax
f0100c2e:	75 dc                	jne    f0100c0c <check_page_free_list+0x39>
			//cprintf("PDX(page2pa(pp)):%x\n",PDX(page2pa(pp)));
			//cprintf("pagetype:%x\n",pagetype);
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100c30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c33:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100c39:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c3c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c3f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100c41:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c44:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c49:	be 01 00 00 00       	mov    $0x1,%esi
//		cprintf("pp1 next :%x\n",pp1->pp_link);
	}
//	cprintf("here after the only_low_memory\n");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c4e:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
f0100c54:	eb 50                	jmp    f0100ca6 <check_page_free_list+0xd3>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c56:	89 d8                	mov    %ebx,%eax
f0100c58:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100c5e:	c1 f8 03             	sar    $0x3,%eax
f0100c61:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit){
f0100c64:	89 c2                	mov    %eax,%edx
f0100c66:	c1 ea 16             	shr    $0x16,%edx
f0100c69:	39 f2                	cmp    %esi,%edx
f0100c6b:	73 37                	jae    f0100ca4 <check_page_free_list+0xd1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c6d:	89 c2                	mov    %eax,%edx
f0100c6f:	c1 ea 0c             	shr    $0xc,%edx
f0100c72:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100c78:	72 12                	jb     f0100c8c <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c7a:	50                   	push   %eax
f0100c7b:	68 14 60 10 f0       	push   $0xf0106014
f0100c80:	6a 58                	push   $0x58
f0100c82:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0100c87:	e8 08 f4 ff ff       	call   f0100094 <_panic>
			//cprintf("PageInfo.size():%x\n",sizeof(struct PageInfo));

			//:/cprintf("#check_page_free_list:page2kva(pp):%x\n",page2kva(pp));
			memset(page2kva(pp), 0x00, 128);
f0100c8c:	83 ec 04             	sub    $0x4,%esp
f0100c8f:	68 80 00 00 00       	push   $0x80
f0100c94:	6a 00                	push   $0x0
f0100c96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c9b:	50                   	push   %eax
f0100c9c:	e8 02 46 00 00       	call   f01052a3 <memset>
f0100ca1:	83 c4 10             	add    $0x10,%esp
//		cprintf("pp1 next :%x\n",pp1->pp_link);
	}
//	cprintf("here after the only_low_memory\n");
	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ca4:	8b 1b                	mov    (%ebx),%ebx
f0100ca6:	85 db                	test   %ebx,%ebx
f0100ca8:	75 ac                	jne    f0100c56 <check_page_free_list+0x83>
		}else{
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
f0100caa:	b8 00 00 00 00       	mov    $0x0,%eax
f0100caf:	e8 56 fe ff ff       	call   f0100b0a <boot_alloc>
f0100cb4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cb7:	8b 15 40 b2 22 f0    	mov    0xf022b240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cbd:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
		assert(pp < pages + npages);
f0100cc3:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0100cc8:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100ccb:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100cce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cd1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cd4:	be 00 00 00 00       	mov    $0x0,%esi
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cd9:	e9 52 01 00 00       	jmp    f0100e30 <check_page_free_list+0x25d>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100cde:	39 ca                	cmp    %ecx,%edx
f0100ce0:	73 19                	jae    f0100cfb <check_page_free_list+0x128>
f0100ce2:	68 7b 6f 10 f0       	push   $0xf0106f7b
f0100ce7:	68 87 6f 10 f0       	push   $0xf0106f87
f0100cec:	68 6d 04 00 00       	push   $0x46d
f0100cf1:	68 61 6f 10 f0       	push   $0xf0106f61
f0100cf6:	e8 99 f3 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100cfb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cfe:	72 19                	jb     f0100d19 <check_page_free_list+0x146>
f0100d00:	68 9c 6f 10 f0       	push   $0xf0106f9c
f0100d05:	68 87 6f 10 f0       	push   $0xf0106f87
f0100d0a:	68 6e 04 00 00       	push   $0x46e
f0100d0f:	68 61 6f 10 f0       	push   $0xf0106f61
f0100d14:	e8 7b f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d19:	89 d0                	mov    %edx,%eax
f0100d1b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d1e:	a8 07                	test   $0x7,%al
f0100d20:	74 19                	je     f0100d3b <check_page_free_list+0x168>
f0100d22:	68 14 66 10 f0       	push   $0xf0106614
f0100d27:	68 87 6f 10 f0       	push   $0xf0106f87
f0100d2c:	68 6f 04 00 00       	push   $0x46f
f0100d31:	68 61 6f 10 f0       	push   $0xf0106f61
f0100d36:	e8 59 f3 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d3b:	c1 f8 03             	sar    $0x3,%eax
f0100d3e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		//my code:
		//cprintf("pp:%x,page2pa(pp):%x\n",pp,page2pa(pp));
		//my code end.
		assert(page2pa(pp) != 0);
f0100d41:	85 c0                	test   %eax,%eax
f0100d43:	75 19                	jne    f0100d5e <check_page_free_list+0x18b>
f0100d45:	68 b0 6f 10 f0       	push   $0xf0106fb0
f0100d4a:	68 87 6f 10 f0       	push   $0xf0106f87
f0100d4f:	68 75 04 00 00       	push   $0x475
f0100d54:	68 61 6f 10 f0       	push   $0xf0106f61
f0100d59:	e8 36 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d5e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d63:	75 19                	jne    f0100d7e <check_page_free_list+0x1ab>
f0100d65:	68 c1 6f 10 f0       	push   $0xf0106fc1
f0100d6a:	68 87 6f 10 f0       	push   $0xf0106f87
f0100d6f:	68 76 04 00 00       	push   $0x476
f0100d74:	68 61 6f 10 f0       	push   $0xf0106f61
f0100d79:	e8 16 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d7e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d83:	75 19                	jne    f0100d9e <check_page_free_list+0x1cb>
f0100d85:	68 48 66 10 f0       	push   $0xf0106648
f0100d8a:	68 87 6f 10 f0       	push   $0xf0106f87
f0100d8f:	68 77 04 00 00       	push   $0x477
f0100d94:	68 61 6f 10 f0       	push   $0xf0106f61
f0100d99:	e8 f6 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da3:	75 19                	jne    f0100dbe <check_page_free_list+0x1eb>
f0100da5:	68 da 6f 10 f0       	push   $0xf0106fda
f0100daa:	68 87 6f 10 f0       	push   $0xf0106f87
f0100daf:	68 78 04 00 00       	push   $0x478
f0100db4:	68 61 6f 10 f0       	push   $0xf0106f61
f0100db9:	e8 d6 f2 ff ff       	call   f0100094 <_panic>
		//cprintf("pp'address:%x,page2kva(pp):%x\n",pp,page2kva(pp));
		//cprintf("first_free_page:%x\n",first_free_page);
		//assert( (char *)page2kva(pp) >= first_free_page );
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dbe:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dc3:	0f 86 f1 00 00 00    	jbe    f0100eba <check_page_free_list+0x2e7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dc9:	89 c7                	mov    %eax,%edi
f0100dcb:	c1 ef 0c             	shr    $0xc,%edi
f0100dce:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100dd1:	77 12                	ja     f0100de5 <check_page_free_list+0x212>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd3:	50                   	push   %eax
f0100dd4:	68 14 60 10 f0       	push   $0xf0106014
f0100dd9:	6a 58                	push   $0x58
f0100ddb:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0100de0:	e8 af f2 ff ff       	call   f0100094 <_panic>
f0100de5:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100deb:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100dee:	0f 86 b6 00 00 00    	jbe    f0100eaa <check_page_free_list+0x2d7>
f0100df4:	68 6c 66 10 f0       	push   $0xf010666c
f0100df9:	68 87 6f 10 f0       	push   $0xf0106f87
f0100dfe:	68 7c 04 00 00       	push   $0x47c
f0100e03:	68 61 6f 10 f0       	push   $0xf0106f61
f0100e08:	e8 87 f2 ff ff       	call   f0100094 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e0d:	68 f4 6f 10 f0       	push   $0xf0106ff4
f0100e12:	68 87 6f 10 f0       	push   $0xf0106f87
f0100e17:	68 7e 04 00 00       	push   $0x47e
f0100e1c:	68 61 6f 10 f0       	push   $0xf0106f61
f0100e21:	e8 6e f2 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100e26:	83 c6 01             	add    $0x1,%esi
f0100e29:	eb 03                	jmp    f0100e2e <check_page_free_list+0x25b>
		else
			++nfree_extmem;
f0100e2b:	83 c3 01             	add    $0x1,%ebx
			//cprintf("here in the else:%x\n",pp);
		}
	
//	cprintf("now we are in memset page2kva(pp) 0x97 128\n");
	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e2e:	8b 12                	mov    (%edx),%edx
f0100e30:	85 d2                	test   %edx,%edx
f0100e32:	0f 85 a6 fe ff ff    	jne    f0100cde <check_page_free_list+0x10b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e38:	85 f6                	test   %esi,%esi
f0100e3a:	7f 19                	jg     f0100e55 <check_page_free_list+0x282>
f0100e3c:	68 11 70 10 f0       	push   $0xf0107011
f0100e41:	68 87 6f 10 f0       	push   $0xf0106f87
f0100e46:	68 86 04 00 00       	push   $0x486
f0100e4b:	68 61 6f 10 f0       	push   $0xf0106f61
f0100e50:	e8 3f f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100e55:	85 db                	test   %ebx,%ebx
f0100e57:	7f 19                	jg     f0100e72 <check_page_free_list+0x29f>
f0100e59:	68 23 70 10 f0       	push   $0xf0107023
f0100e5e:	68 87 6f 10 f0       	push   $0xf0106f87
f0100e63:	68 87 04 00 00       	push   $0x487
f0100e68:	68 61 6f 10 f0       	push   $0xf0106f61
f0100e6d:	e8 22 f2 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e72:	83 ec 0c             	sub    $0xc,%esp
f0100e75:	68 b4 66 10 f0       	push   $0xf01066b4
f0100e7a:	e8 ff 29 00 00       	call   f010387e <cprintf>
}
f0100e7f:	eb 49                	jmp    f0100eca <check_page_free_list+0x2f7>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e81:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0100e86:	85 c0                	test   %eax,%eax
f0100e88:	0f 85 72 fd ff ff    	jne    f0100c00 <check_page_free_list+0x2d>
f0100e8e:	e9 56 fd ff ff       	jmp    f0100be9 <check_page_free_list+0x16>
f0100e93:	83 3d 40 b2 22 f0 00 	cmpl   $0x0,0xf022b240
f0100e9a:	0f 84 49 fd ff ff    	je     f0100be9 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ea0:	be 00 04 00 00       	mov    $0x400,%esi
f0100ea5:	e9 a4 fd ff ff       	jmp    f0100c4e <check_page_free_list+0x7b>
		//cprintf("pp'address:%x,page2kva(pp):%x\n",pp,page2kva(pp));
		//cprintf("first_free_page:%x\n",first_free_page);
		//assert( (char *)page2kva(pp) >= first_free_page );
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100eaa:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100eaf:	0f 85 76 ff ff ff    	jne    f0100e2b <check_page_free_list+0x258>
f0100eb5:	e9 53 ff ff ff       	jmp    f0100e0d <check_page_free_list+0x23a>
f0100eba:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ebf:	0f 85 61 ff ff ff    	jne    f0100e26 <check_page_free_list+0x253>
f0100ec5:	e9 43 ff ff ff       	jmp    f0100e0d <check_page_free_list+0x23a>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ecd:	5b                   	pop    %ebx
f0100ece:	5e                   	pop    %esi
f0100ecf:	5f                   	pop    %edi
f0100ed0:	5d                   	pop    %ebp
f0100ed1:	c3                   	ret    

f0100ed2 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ed2:	55                   	push   %ebp
f0100ed3:	89 e5                	mov    %esp,%ebp
f0100ed5:	56                   	push   %esi
f0100ed6:	53                   	push   %ebx
	}
*/

//=======
     size_t i;
     pages[0].pp_ref = 1;
f0100ed7:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0100edc:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
     pages[0].pp_link = NULL;
f0100ee2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
f0100ee8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eed:	e8 18 fc ff ff       	call   f0100b0a <boot_alloc>
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
     {
         if (( (i >= (IOPHYSMEM / PGSIZE)) && (i < ((nextfree - KERNBASE)/ PGSIZE))) || i == (MPENTRY_PADDR/PGSIZE)) 
f0100ef2:	05 00 00 00 10       	add    $0x10000000,%eax
f0100ef7:	c1 e8 0c             	shr    $0xc,%eax
f0100efa:	8b 35 40 b2 22 f0    	mov    0xf022b240,%esi
     pages[0].pp_link = NULL;
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
f0100f00:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f05:	ba 01 00 00 00       	mov    $0x1,%edx
f0100f0a:	eb 4f                	jmp    f0100f5b <page_init+0x89>
     {
         if (( (i >= (IOPHYSMEM / PGSIZE)) && (i < ((nextfree - KERNBASE)/ PGSIZE))) || i == (MPENTRY_PADDR/PGSIZE)) 
f0100f0c:	81 fa 9f 00 00 00    	cmp    $0x9f,%edx
f0100f12:	76 04                	jbe    f0100f18 <page_init+0x46>
f0100f14:	39 c2                	cmp    %eax,%edx
f0100f16:	72 05                	jb     f0100f1d <page_init+0x4b>
f0100f18:	83 fa 07             	cmp    $0x7,%edx
f0100f1b:	75 17                	jne    f0100f34 <page_init+0x62>
         {
             pages[i].pp_ref = 1;
f0100f1d:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
f0100f23:	8d 0c d1             	lea    (%ecx,%edx,8),%ecx
f0100f26:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
             pages[i].pp_link = NULL;
f0100f2c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0100f32:	eb 24                	jmp    f0100f58 <page_init+0x86>
         }
         else 
         {
             pages[i].pp_ref = 0;
f0100f34:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100f3b:	89 cb                	mov    %ecx,%ebx
f0100f3d:	03 1d 90 be 22 f0    	add    0xf022be90,%ebx
f0100f43:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
             pages[i].pp_link = page_free_list;
f0100f49:	89 33                	mov    %esi,(%ebx)
             page_free_list = &pages[i];
f0100f4b:	89 ce                	mov    %ecx,%esi
f0100f4d:	03 35 90 be 22 f0    	add    0xf022be90,%esi
f0100f53:	bb 01 00 00 00       	mov    $0x1,%ebx
     pages[0].pp_link = NULL;
 
     uint32_t nextfree = (uint32_t)boot_alloc(0);
//     cprintf("NPAGES: %d NPAGES_BASE_MEM: %d\n", npages, npages_basemem);
//     cprintf("nextfree-KERNBASE: %08x IOPHY: %08x  EXT: %08x\n", nextfree - KERNBASE, IOPHYSMEM, EXTPHYSMEM);
     for (i = 1; i < npages; i++) 
f0100f58:	83 c2 01             	add    $0x1,%edx
f0100f5b:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100f61:	72 a9                	jb     f0100f0c <page_init+0x3a>
f0100f63:	84 db                	test   %bl,%bl
f0100f65:	74 06                	je     f0100f6d <page_init+0x9b>
f0100f67:	89 35 40 b2 22 f0    	mov    %esi,0xf022b240
             page_free_list = &pages[i];
        }
     }

//>>>>>>> lab3
}
f0100f6d:	5b                   	pop    %ebx
f0100f6e:	5e                   	pop    %esi
f0100f6f:	5d                   	pop    %ebp
f0100f70:	c3                   	ret    

f0100f71 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f71:	55                   	push   %ebp
f0100f72:	89 e5                	mov    %esp,%ebp
f0100f74:	53                   	push   %ebx
f0100f75:	83 ec 04             	sub    $0x4,%esp
f0100f78:	8b 1d 40 b2 22 f0    	mov    0xf022b240,%ebx
	//my code start
	//first check is there any pages left

	//here we delete the page in the page_free_list but used by others.e.g.pp2
//cprintf("$$now we are at the page_alloc() function.$$\n\n");
	while( page_free_list && page_free_list->pp_ref > 0 ){
f0100f7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f83:	eb 07                	jmp    f0100f8c <page_alloc+0x1b>
		page_free_list = page_free_list->pp_link;
f0100f85:	8b 1b                	mov    (%ebx),%ebx
f0100f87:	b8 01 00 00 00       	mov    $0x1,%eax
	//my code start
	//first check is there any pages left

	//here we delete the page in the page_free_list but used by others.e.g.pp2
//cprintf("$$now we are at the page_alloc() function.$$\n\n");
	while( page_free_list && page_free_list->pp_ref > 0 ){
f0100f8c:	85 db                	test   %ebx,%ebx
f0100f8e:	75 14                	jne    f0100fa4 <page_alloc+0x33>
f0100f90:	84 c0                	test   %al,%al
f0100f92:	0f 84 8b 00 00 00    	je     f0101023 <page_alloc+0xb2>
f0100f98:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0100f9f:	00 00 00 
f0100fa2:	eb 7f                	jmp    f0101023 <page_alloc+0xb2>
f0100fa4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0100fa9:	75 da                	jne    f0100f85 <page_alloc+0x14>
f0100fab:	84 c0                	test   %al,%al
f0100fad:	74 06                	je     f0100fb5 <page_alloc+0x44>
f0100faf:	89 1d 40 b2 22 f0    	mov    %ebx,0xf022b240
//cprintf("#497 alloc_error:we don't consider the condition that only one node left.\n");
//cprintf("page_free_list->pp_ref:0x%x,pp_link:0x%x\n\n\n",page_free_list->pp_ref,page_free_list->pp_link);			
		struct PageInfo * return_PageInfo = NULL;
		return_PageInfo = page_free_list;
		
		if(page_free_list->pp_link == NULL){
f0100fb5:	8b 03                	mov    (%ebx),%eax
f0100fb7:	85 c0                	test   %eax,%eax
f0100fb9:	75 12                	jne    f0100fcd <page_alloc+0x5c>
			page_free_list = NULL;
f0100fbb:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0100fc2:	00 00 00 
			return_PageInfo->pp_link = NULL;
f0100fc5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
f0100fcb:	eb 0b                	jmp    f0100fd8 <page_alloc+0x67>
		}else{
			page_free_list = return_PageInfo->pp_link;
f0100fcd:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
			return_PageInfo->pp_link = NULL;	
f0100fd2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		}
		
		if(alloc_flags & ALLOC_ZERO){
f0100fd8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fdc:	74 45                	je     f0101023 <page_alloc+0xb2>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fde:	89 d8                	mov    %ebx,%eax
f0100fe0:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0100fe6:	c1 f8 03             	sar    $0x3,%eax
f0100fe9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fec:	89 c2                	mov    %eax,%edx
f0100fee:	c1 ea 0c             	shr    $0xc,%edx
f0100ff1:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0100ff7:	72 12                	jb     f010100b <page_alloc+0x9a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ff9:	50                   	push   %eax
f0100ffa:	68 14 60 10 f0       	push   $0xf0106014
f0100fff:	6a 58                	push   $0x58
f0101001:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0101006:	e8 89 f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(return_PageInfo),'\0',PGSIZE);
f010100b:	83 ec 04             	sub    $0x4,%esp
f010100e:	68 00 10 00 00       	push   $0x1000
f0101013:	6a 00                	push   $0x0
f0101015:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010101a:	50                   	push   %eax
f010101b:	e8 83 42 00 00       	call   f01052a3 <memset>
f0101020:	83 c4 10             	add    $0x10,%esp
//		panic("page_alloc():alloc failed.\n");
		return NULL;
	}
	//my code end.
	return 0;
}
f0101023:	89 d8                	mov    %ebx,%eax
f0101025:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101028:	c9                   	leave  
f0101029:	c3                   	ret    

f010102a <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f010102a:	55                   	push   %ebp
f010102b:	89 e5                	mov    %esp,%ebp
f010102d:	53                   	push   %ebx
f010102e:	83 ec 04             	sub    $0x4,%esp
f0101031:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_ref != 0 || pp->pp_link != NULL){
f0101034:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101039:	75 05                	jne    f0101040 <page_free+0x16>
f010103b:	83 3b 00             	cmpl   $0x0,(%ebx)
f010103e:	74 17                	je     f0101057 <page_free+0x2d>
		
		panic("page_free():page free failed.\n");
f0101040:	83 ec 04             	sub    $0x4,%esp
f0101043:	68 d8 66 10 f0       	push   $0xf01066d8
f0101048:	68 ff 01 00 00       	push   $0x1ff
f010104d:	68 61 6f 10 f0       	push   $0xf0106f61
f0101052:	e8 3d f0 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101057:	89 d8                	mov    %ebx,%eax
f0101059:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010105f:	c1 f8 03             	sar    $0x3,%eax
f0101062:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101065:	89 c2                	mov    %eax,%edx
f0101067:	c1 ea 0c             	shr    $0xc,%edx
f010106a:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101070:	72 12                	jb     f0101084 <page_free+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101072:	50                   	push   %eax
f0101073:	68 14 60 10 f0       	push   $0xf0106014
f0101078:	6a 58                	push   $0x58
f010107a:	68 6d 6f 10 f0       	push   $0xf0106f6d
f010107f:	e8 10 f0 ff ff       	call   f0100094 <_panic>
//			cprintf("$$in the page_free:page_free_list->pp_ref :%x$$\n\n",page_free_list->pp_ref);	
			
			//here we should do something additional,that is clear 
			//the freed page,set the value to 0;
			
			memset((page2kva(pp)),0x00,PGSIZE);
f0101084:	83 ec 04             	sub    $0x4,%esp
f0101087:	68 00 10 00 00       	push   $0x1000
f010108c:	6a 00                	push   $0x0
f010108e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101093:	50                   	push   %eax
f0101094:	e8 0a 42 00 00       	call   f01052a3 <memset>
f0101099:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
			
			while(page_free_list && page_free_list->pp_ref >0){
f010109e:	83 c4 10             	add    $0x10,%esp
f01010a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01010a6:	eb 07                	jmp    f01010af <page_free+0x85>
				page_free_list = page_free_list->pp_link;
f01010a8:	8b 00                	mov    (%eax),%eax
f01010aa:	ba 01 00 00 00       	mov    $0x1,%edx
			//here we should do something additional,that is clear 
			//the freed page,set the value to 0;
			
			memset((page2kva(pp)),0x00,PGSIZE);
			
			while(page_free_list && page_free_list->pp_ref >0){
f01010af:	85 c0                	test   %eax,%eax
f01010b1:	75 10                	jne    f01010c3 <page_free+0x99>
f01010b3:	84 d2                	test   %dl,%dl
f01010b5:	74 1c                	je     f01010d3 <page_free+0xa9>
f01010b7:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f01010be:	00 00 00 
f01010c1:	eb 10                	jmp    f01010d3 <page_free+0xa9>
f01010c3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010c8:	75 de                	jne    f01010a8 <page_free+0x7e>
f01010ca:	84 d2                	test   %dl,%dl
f01010cc:	74 05                	je     f01010d3 <page_free+0xa9>
f01010ce:	a3 40 b2 22 f0       	mov    %eax,0xf022b240
				page_free_list = page_free_list->pp_link;
			}
			if(pp != page_free_list){
f01010d3:	39 c3                	cmp    %eax,%ebx
f01010d5:	74 08                	je     f01010df <page_free+0xb5>
				struct PageInfo * temp_free_page_list = page_free_list;
				page_free_list = pp;
f01010d7:	89 1d 40 b2 22 f0    	mov    %ebx,0xf022b240
				page_free_list->pp_link = temp_free_page_list;
f01010dd:	89 03                	mov    %eax,(%ebx)
			}
		return;

	}
	
}
f01010df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010e2:	c9                   	leave  
f01010e3:	c3                   	ret    

f01010e4 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01010e4:	55                   	push   %ebp
f01010e5:	89 e5                	mov    %esp,%ebp
f01010e7:	83 ec 08             	sub    $0x8,%esp
f01010ea:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010ed:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010f1:	83 e8 01             	sub    $0x1,%eax
f01010f4:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010f8:	66 85 c0             	test   %ax,%ax
f01010fb:	75 0c                	jne    f0101109 <page_decref+0x25>
		page_free(pp);
f01010fd:	83 ec 0c             	sub    $0xc,%esp
f0101100:	52                   	push   %edx
f0101101:	e8 24 ff ff ff       	call   f010102a <page_free>
f0101106:	83 c4 10             	add    $0x10,%esp
}
f0101109:	c9                   	leave  
f010110a:	c3                   	ret    

f010110b <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010110b:	55                   	push   %ebp
f010110c:	89 e5                	mov    %esp,%ebp
f010110e:	56                   	push   %esi
f010110f:	53                   	push   %ebx
f0101110:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//a new page table table if there is not a page table page exist.

const void* out_va = va;
//if( (uint32_t)out_va&0xf0000000 && !((uint32_t)out_va&0x0ffffff) )
//cprintf("va :%x\n",va);
	if( pgdir[PDX(va)] == 0 ){//memset has already set it to zero?
f0101113:	89 de                	mov    %ebx,%esi
f0101115:	c1 ee 16             	shr    $0x16,%esi
f0101118:	c1 e6 02             	shl    $0x2,%esi
f010111b:	03 75 08             	add    0x8(%ebp),%esi
f010111e:	8b 06                	mov    (%esi),%eax
f0101120:	85 c0                	test   %eax,%eax
f0101122:	75 74                	jne    f0101198 <pgdir_walk+0x8d>
		if(create == 0)
f0101124:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101128:	0f 84 a3 00 00 00    	je     f01011d1 <pgdir_walk+0xc6>
			return NULL;
		else{
			struct PageInfo * return_page = page_alloc(0);
f010112e:	83 ec 0c             	sub    $0xc,%esp
f0101131:	6a 00                	push   $0x0
f0101133:	e8 39 fe ff ff       	call   f0100f71 <page_alloc>
//cprintf(" we are at the page_allloc to check #497\n");
//cprintf("the mapped va is:%x\n",va);
			//return_page->pp_ref++;
			if(return_page == NULL){//run out of memery
f0101138:	83 c4 10             	add    $0x10,%esp
f010113b:	85 c0                	test   %eax,%eax
f010113d:	0f 84 95 00 00 00    	je     f01011d8 <pgdir_walk+0xcd>
				return NULL;
			}else{
//				cprintf("#page_walk in the if  else(new alloc)\n");
//				cprintf("#page_walk return_page :%x\n",return_page);
//				cprintf("#page_walk page2pa(return_page):%x\n",page2pa(return_page));
				return_page->pp_ref++;
f0101143:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
				//this line can make the
				//the line assert(ptep == ptep1+PTX(va))
				//pass in the check_page();
				pgdir[PDX(va)] = page2pa(return_page);	
f0101148:	89 c2                	mov    %eax,%edx
f010114a:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101150:	c1 fa 03             	sar    $0x3,%edx
f0101153:	c1 e2 0c             	shl    $0xc,%edx
f0101156:	89 16                	mov    %edx,(%esi)
//cprintf("from the else exit.\n\n");
				return (pte_t*)(KADDR(PTE_ADDR(page2pa(return_page))))+PTX(va);
f0101158:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010115e:	c1 f8 03             	sar    $0x3,%eax
f0101161:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101164:	89 c2                	mov    %eax,%edx
f0101166:	c1 ea 0c             	shr    $0xc,%edx
f0101169:	39 15 88 be 22 f0    	cmp    %edx,0xf022be88
f010116f:	77 15                	ja     f0101186 <pgdir_walk+0x7b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101171:	50                   	push   %eax
f0101172:	68 14 60 10 f0       	push   $0xf0106014
f0101177:	68 71 02 00 00       	push   $0x271
f010117c:	68 61 6f 10 f0       	push   $0xf0106f61
f0101181:	e8 0e ef ff ff       	call   f0100094 <_panic>
f0101186:	c1 eb 0a             	shr    $0xa,%ebx
f0101189:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010118f:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101196:	eb 45                	jmp    f01011dd <pgdir_walk+0xd2>
			}
		}	
	}else{
		//cprintf("B");
		//cprintf("the page_walk else:0x%x\n",pgdir[PDX(va)]);
		return (pte_t*)(KADDR(PTE_ADDR(pgdir[PDX(va)])))+PTX(va);
f0101198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010119d:	89 c2                	mov    %eax,%edx
f010119f:	c1 ea 0c             	shr    $0xc,%edx
f01011a2:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01011a8:	72 15                	jb     f01011bf <pgdir_walk+0xb4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011aa:	50                   	push   %eax
f01011ab:	68 14 60 10 f0       	push   $0xf0106014
f01011b0:	68 79 02 00 00       	push   $0x279
f01011b5:	68 61 6f 10 f0       	push   $0xf0106f61
f01011ba:	e8 d5 ee ff ff       	call   f0100094 <_panic>
f01011bf:	c1 eb 0a             	shr    $0xa,%ebx
f01011c2:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01011c8:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01011cf:	eb 0c                	jmp    f01011dd <pgdir_walk+0xd2>
const void* out_va = va;
//if( (uint32_t)out_va&0xf0000000 && !((uint32_t)out_va&0x0ffffff) )
//cprintf("va :%x\n",va);
	if( pgdir[PDX(va)] == 0 ){//memset has already set it to zero?
		if(create == 0)
			return NULL;
f01011d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d6:	eb 05                	jmp    f01011dd <pgdir_walk+0xd2>
//cprintf(" we are at the page_allloc to check #497\n");
//cprintf("the mapped va is:%x\n",va);
			//return_page->pp_ref++;
			if(return_page == NULL){//run out of memery
//cprintf("from the NULL exit.\n\n");
				return NULL;
f01011d8:	b8 00 00 00 00       	mov    $0x0,%eax


	//my code end.

	return NULL;
}
f01011dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011e0:	5b                   	pop    %ebx
f01011e1:	5e                   	pop    %esi
f01011e2:	5d                   	pop    %ebp
f01011e3:	c3                   	ret    

f01011e4 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01011e4:	55                   	push   %ebp
f01011e5:	89 e5                	mov    %esp,%ebp
f01011e7:	57                   	push   %edi
f01011e8:	56                   	push   %esi
f01011e9:	53                   	push   %ebx
f01011ea:	83 ec 1c             	sub    $0x1c,%esp
f01011ed:	89 c7                	mov    %eax,%edi
//			cprintf("*returned_page_table:%x\n",*returned_page_table);

//		}

		*returned_page_table = ((temp_pa))|perm|PTE_P;
		if(temp_va == va+ROUNDUP(size,PGSIZE)-PGSIZE){
f01011ef:	8d 5c 0a ff          	lea    -0x1(%edx,%ecx,1),%ebx
f01011f3:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f01011f9:	25 ff 0f 00 00       	and    $0xfff,%eax
f01011fe:	29 c3                	sub    %eax,%ebx
f0101200:	89 5d d8             	mov    %ebx,-0x28(%ebp)
	pde_t * returned_page_table;

	//pgdir_walk(pgdir,va,1);
	uintptr_t temp_va;
	physaddr_t temp_pa;
	for(temp_va = va,temp_pa = pa;temp_va<va+size;temp_va+=PGSIZE,temp_pa+=PGSIZE){
f0101203:	89 d3                	mov    %edx,%ebx
f0101205:	8b 45 08             	mov    0x8(%ebp),%eax
f0101208:	29 d0                	sub    %edx,%eax
f010120a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010120d:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f0101210:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101213:	eb 56                	jmp    f010126b <boot_map_region+0x87>
	/* here we should use a new mapping way because we should finish it in static
		
		//the third version is below.
		
	*/
		returned_page_table = pgdir_walk(pgdir,(void*)temp_va,1);
f0101215:	83 ec 04             	sub    $0x4,%esp
f0101218:	6a 01                	push   $0x1
f010121a:	53                   	push   %ebx
f010121b:	57                   	push   %edi
f010121c:	e8 ea fe ff ff       	call   f010110b <pgdir_walk>
//cprintf("A");
//cprintf("w");
		pgdir[PDX(temp_va)] = PADDR((void*)((uint32_t)(returned_page_table)|perm|PTE_P));
f0101221:	89 da                	mov    %ebx,%edx
f0101223:	c1 ea 16             	shr    $0x16,%edx
f0101226:	8d 34 97             	lea    (%edi,%edx,4),%esi
f0101229:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010122c:	83 c9 01             	or     $0x1,%ecx
f010122f:	89 c2                	mov    %eax,%edx
f0101231:	09 ca                	or     %ecx,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101233:	83 c4 10             	add    $0x10,%esp
f0101236:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010123c:	77 15                	ja     f0101253 <boot_map_region+0x6f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010123e:	52                   	push   %edx
f010123f:	68 38 60 10 f0       	push   $0xf0106038
f0101244:	68 a8 02 00 00       	push   $0x2a8
f0101249:	68 61 6f 10 f0       	push   $0xf0106f61
f010124e:	e8 41 ee ff ff       	call   f0100094 <_panic>
f0101253:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101259:	89 16                	mov    %edx,(%esi)
//			cprintf("returned_page_table:%x\n",returned_page_table);
//			cprintf("*returned_page_table:%x\n",*returned_page_table);

//		}

		*returned_page_table = ((temp_pa))|perm|PTE_P;
f010125b:	0b 4d e4             	or     -0x1c(%ebp),%ecx
f010125e:	89 08                	mov    %ecx,(%eax)
		if(temp_va == va+ROUNDUP(size,PGSIZE)-PGSIZE){
f0101260:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0101263:	74 13                	je     f0101278 <boot_map_region+0x94>
	pde_t * returned_page_table;

	//pgdir_walk(pgdir,va,1);
	uintptr_t temp_va;
	physaddr_t temp_pa;
	for(temp_va = va,temp_pa = pa;temp_va<va+size;temp_va+=PGSIZE,temp_pa+=PGSIZE){
f0101265:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010126b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010126e:	01 d8                	add    %ebx,%eax
f0101270:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101273:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0101276:	72 9d                	jb     f0101215 <boot_map_region+0x31>
//cprintf("for test temp_va:%x temp_pa:%x\n",temp_va,temp_pa);
	}	
	
	//my code end
//cprintf("now we get out of boot_map_region\n\n\n");
}
f0101278:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127b:	5b                   	pop    %ebx
f010127c:	5e                   	pop    %esi
f010127d:	5f                   	pop    %edi
f010127e:	5d                   	pop    %ebp
f010127f:	c3                   	ret    

f0101280 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101280:	55                   	push   %ebp
f0101281:	89 e5                	mov    %esp,%ebp
f0101283:	53                   	push   %ebx
f0101284:	83 ec 08             	sub    $0x8,%esp
f0101287:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	//my second time code
	//page_remove(pgdir,va);
	pte_t*p = NULL;
	if((p = pgdir_walk(pgdir,va,0)) == NULL){
f010128a:	6a 00                	push   $0x0
f010128c:	ff 75 0c             	pushl  0xc(%ebp)
f010128f:	ff 75 08             	pushl  0x8(%ebp)
f0101292:	e8 74 fe ff ff       	call   f010110b <pgdir_walk>
f0101297:	83 c4 10             	add    $0x10,%esp
f010129a:	85 c0                	test   %eax,%eax
f010129c:	74 36                	je     f01012d4 <page_lookup+0x54>
//		cprintf("#page_lookup:in NULL chose.\n");
		return NULL;	
	}else{
//		cprintf("#page_lookup:in else.\n");
		if(pte_store != NULL){
f010129e:	85 db                	test   %ebx,%ebx
f01012a0:	74 02                	je     f01012a4 <page_lookup+0x24>
			*pte_store = (p);		
f01012a2:	89 03                	mov    %eax,(%ebx)
		}
//		//pte_t  inner_p = PTE_ADDR((pte_t)p);
//		cprintf("the address of va is:0x%x\n",va);
//		cprintf("the PTX(va):0x%x\n",PTX(va));
//cprintf("### in page_lookup: 10.3 %x\n",*p);
		if((void*)(*p) == NULL){
f01012a4:	8b 00                	mov    (%eax),%eax
f01012a6:	85 c0                	test   %eax,%eax
f01012a8:	74 31                	je     f01012db <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012aa:	c1 e8 0c             	shr    $0xc,%eax
f01012ad:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01012b3:	72 14                	jb     f01012c9 <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f01012b5:	83 ec 04             	sub    $0x4,%esp
f01012b8:	68 f8 66 10 f0       	push   $0xf01066f8
f01012bd:	6a 51                	push   $0x51
f01012bf:	68 6d 6f 10 f0       	push   $0xf0106f6d
f01012c4:	e8 cb ed ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f01012c9:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f01012cf:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		}else{
//			cprintf("#page_lookup in the else else 0x%x\n",p);
		//	cprintf("#page lookup in the else else 0x%x\n",p[PTX(va)]) ;


			return pa2page( *p );
f01012d2:	eb 0c                	jmp    f01012e0 <page_lookup+0x60>
	//my second time code
	//page_remove(pgdir,va);
	pte_t*p = NULL;
	if((p = pgdir_walk(pgdir,va,0)) == NULL){
//		cprintf("#page_lookup:in NULL chose.\n");
		return NULL;	
f01012d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d9:	eb 05                	jmp    f01012e0 <page_lookup+0x60>
//		cprintf("the address of va is:0x%x\n",va);
//		cprintf("the PTX(va):0x%x\n",PTX(va));
//cprintf("### in page_lookup: 10.3 %x\n",*p);
		if((void*)(*p) == NULL){
	
			return NULL;
f01012db:	b8 00 00 00 00       	mov    $0x0,%eax
		return NULL;
	}
	return NULL;
	*/

}
f01012e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012e3:	c9                   	leave  
f01012e4:	c3                   	ret    

f01012e5 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01012e5:	55                   	push   %ebp
f01012e6:	89 e5                	mov    %esp,%ebp
f01012e8:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01012eb:	e8 d6 45 00 00       	call   f01058c6 <cpunum>
f01012f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01012f3:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01012fa:	74 16                	je     f0101312 <tlb_invalidate+0x2d>
f01012fc:	e8 c5 45 00 00       	call   f01058c6 <cpunum>
f0101301:	6b c0 74             	imul   $0x74,%eax,%eax
f0101304:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010130a:	8b 55 08             	mov    0x8(%ebp),%edx
f010130d:	39 50 60             	cmp    %edx,0x60(%eax)
f0101310:	75 06                	jne    f0101318 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101312:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101315:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101318:	c9                   	leave  
f0101319:	c3                   	ret    

f010131a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010131a:	55                   	push   %ebp
f010131b:	89 e5                	mov    %esp,%ebp
f010131d:	56                   	push   %esi
f010131e:	53                   	push   %ebx
f010131f:	83 ec 14             	sub    $0x14,%esp
f0101322:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101325:	8b 75 0c             	mov    0xc(%ebp),%esi
	//address space the TLB will be preload the concerned 
	//page table entrys so we invalidate it first...(maybe)
	//but I still do not know when to use it clearly.
	pde_t * temp_pte;
	struct PageInfo * page_to_free;
	page_to_free = page_lookup(pgdir,va,&temp_pte);
f0101328:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010132b:	50                   	push   %eax
f010132c:	56                   	push   %esi
f010132d:	53                   	push   %ebx
f010132e:	e8 4d ff ff ff       	call   f0101280 <page_lookup>
	
	if(page_to_free != NULL){
f0101333:	83 c4 10             	add    $0x10,%esp
f0101336:	85 c0                	test   %eax,%eax
f0101338:	74 1f                	je     f0101359 <page_remove+0x3f>
	//we should handle the page returned.
		page_decref(page_to_free);	
f010133a:	83 ec 0c             	sub    $0xc,%esp
f010133d:	50                   	push   %eax
f010133e:	e8 a1 fd ff ff       	call   f01010e4 <page_decref>
		tlb_invalidate(pgdir,va);
f0101343:	83 c4 08             	add    $0x8,%esp
f0101346:	56                   	push   %esi
f0101347:	53                   	push   %ebx
f0101348:	e8 98 ff ff ff       	call   f01012e5 <tlb_invalidate>
		//now we remove the entry in page table
		//I don't know 
	//	temp_pte = (pte_t*)(PTE_ADDR(temp_pte));
		//change pa to va so that we can use temp_pte[]
		*temp_pte = 0;
f010134d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101350:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101356:	83 c4 10             	add    $0x10,%esp
	}else{
		//do nothing.
	}
	return;
	//my code end
}
f0101359:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010135c:	5b                   	pop    %ebx
f010135d:	5e                   	pop    %esi
f010135e:	5d                   	pop    %ebp
f010135f:	c3                   	ret    

f0101360 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101360:	55                   	push   %ebp
f0101361:	89 e5                	mov    %esp,%ebp
f0101363:	57                   	push   %edi
f0101364:	56                   	push   %esi
f0101365:	53                   	push   %ebx
f0101366:	83 ec 14             	sub    $0x14,%esp
f0101369:	8b 7d 08             	mov    0x8(%ebp),%edi
f010136c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010136f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	//my code start here
	pde_t * returned_page_table_entry;
	struct PageInfo * returned_page_table_entry_page;
//cprintf("#### before remove page_free_list:%x\n",page_free_list);
	page_remove(pgdir,va);
f0101372:	53                   	push   %ebx
f0101373:	57                   	push   %edi
f0101374:	e8 a1 ff ff ff       	call   f010131a <page_remove>
//cprintf("#### after remove page_free_list:%x\n",page_free_list);
	//if it is not mapped,page_remove() do nothing.
	returned_page_table_entry = pgdir_walk(pgdir,va,1);
f0101379:	83 c4 0c             	add    $0xc,%esp
f010137c:	6a 01                	push   $0x1
f010137e:	53                   	push   %ebx
f010137f:	57                   	push   %edi
f0101380:	e8 86 fd ff ff       	call   f010110b <pgdir_walk>
	*/
//	cprintf("the pp is:%x\n",pp);	
//	cprintf("the page2pa(pp) is:%x\n",page2pa(pp));
//	cprintf("the returned_page_table_entry:%x\n",returned_page_table_entry);	

	if(returned_page_table_entry != NULL){
f0101385:	83 c4 10             	add    $0x10,%esp
f0101388:	85 c0                	test   %eax,%eax
f010138a:	74 53                	je     f01013df <page_insert+0x7f>
		

		//we have already insert the right side of the equation in
		// the pgdir[PDX(va)] in the pgdir_walk(),but we do it again 
		//here to insert the permission
		pgdir[PDX(va)] = PADDR((void*)((uint32_t)(returned_page_table_entry)|perm|PTE_P));
f010138c:	c1 eb 16             	shr    $0x16,%ebx
f010138f:	8d 1c 9f             	lea    (%edi,%ebx,4),%ebx
f0101392:	8b 55 14             	mov    0x14(%ebp),%edx
f0101395:	83 ca 01             	or     $0x1,%edx
f0101398:	89 c1                	mov    %eax,%ecx
f010139a:	09 d1                	or     %edx,%ecx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010139c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01013a2:	77 15                	ja     f01013b9 <page_insert+0x59>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013a4:	51                   	push   %ecx
f01013a5:	68 38 60 10 f0       	push   $0xf0106038
f01013aa:	68 f1 02 00 00       	push   $0x2f1
f01013af:	68 61 6f 10 f0       	push   $0xf0106f61
f01013b4:	e8 db ec ff ff       	call   f0100094 <_panic>
f01013b9:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f01013bf:	89 0b                	mov    %ecx,(%ebx)
			//PTE_ADDR(page2pa(returned_page_table_table_entry)));
//		cprintf("in the return is not NULL before\n");
//		cprintf("PTX(va):%d\n",PTX(va));
//		cprintf("the va address:%x\n",va);
//		cprintf("the returned_page_table_entry:%x\n",returned_page_table_entry);
		*returned_page_table_entry = (page2pa(pp))|perm|PTE_P;
f01013c1:	89 f1                	mov    %esi,%ecx
f01013c3:	2b 0d 90 be 22 f0    	sub    0xf022be90,%ecx
f01013c9:	c1 f9 03             	sar    $0x3,%ecx
f01013cc:	c1 e1 0c             	shl    $0xc,%ecx
f01013cf:	09 ca                	or     %ecx,%edx
f01013d1:	89 10                	mov    %edx,(%eax)
		//NOTE. 

	
//cprintf("after KADDR:%x\n",((pde_t*)((pde_t)returned_page_table_entry))[PTX(va)] );

		pp->pp_ref++;
f01013d3:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
//		cprintf("page2pa(pp)|perm|PTE_P:%x\n",page2pa(pp)|perm|PTE_P);	
		//how do you know the 'va' has phy page mapped
		//use function page_lookup.	
		//pgdir_walk();->page_alloc();
		//page_remove();
		return 0;	
f01013d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01013dd:	eb 05                	jmp    f01013e4 <page_insert+0x84>
	}else{
//		cprintf("E_NO_MEM%d\n",-E_NO_MEM);
		return -E_NO_MEM;
f01013df:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	}
}
f01013e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013e7:	5b                   	pop    %ebx
f01013e8:	5e                   	pop    %esi
f01013e9:	5f                   	pop    %edi
f01013ea:	5d                   	pop    %ebp
f01013eb:	c3                   	ret    

f01013ec <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01013ec:	55                   	push   %ebp
f01013ed:	89 e5                	mov    %esp,%ebp
f01013ef:	53                   	push   %ebx
f01013f0:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size_t total_size = ROUNDUP(size,PGSIZE);
f01013f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013f6:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01013fc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(MMIOBASE+total_size>MMIOLIM){
f0101402:	8d 83 00 00 80 ef    	lea    -0x10800000(%ebx),%eax
f0101408:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010140d:	76 17                	jbe    f0101426 <mmio_map_region+0x3a>
		panic("panic at mmio_map_region.\n");
f010140f:	83 ec 04             	sub    $0x4,%esp
f0101412:	68 34 70 10 f0       	push   $0xf0107034
f0101417:	68 ca 03 00 00       	push   $0x3ca
f010141c:	68 61 6f 10 f0       	push   $0xf0106f61
f0101421:	e8 6e ec ff ff       	call   f0100094 <_panic>
	}else{
		boot_map_region(kern_pgdir,base,total_size,pa,PTE_W|PTE_PCD|PTE_PWT);
f0101426:	83 ec 08             	sub    $0x8,%esp
f0101429:	6a 1a                	push   $0x1a
f010142b:	ff 75 08             	pushl  0x8(%ebp)
f010142e:	89 d9                	mov    %ebx,%ecx
f0101430:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101436:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010143b:	e8 a4 fd ff ff       	call   f01011e4 <boot_map_region>
	}
	base+=total_size;
f0101440:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f0101445:	01 c3                	add    %eax,%ebx
f0101447:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
	return (void *)base-total_size;
}
f010144d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101450:	c9                   	leave  
f0101451:	c3                   	ret    

f0101452 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101452:	55                   	push   %ebp
f0101453:	89 e5                	mov    %esp,%ebp
f0101455:	57                   	push   %edi
f0101456:	56                   	push   %esi
f0101457:	53                   	push   %ebx
f0101458:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f010145b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101460:	e8 e1 f6 ff ff       	call   f0100b46 <nvram_read>
f0101465:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101467:	b8 17 00 00 00       	mov    $0x17,%eax
f010146c:	e8 d5 f6 ff ff       	call   f0100b46 <nvram_read>
f0101471:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101473:	b8 34 00 00 00       	mov    $0x34,%eax
f0101478:	e8 c9 f6 ff ff       	call   f0100b46 <nvram_read>
f010147d:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101480:	85 c0                	test   %eax,%eax
f0101482:	74 07                	je     f010148b <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101484:	05 00 40 00 00       	add    $0x4000,%eax
f0101489:	eb 0b                	jmp    f0101496 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010148b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101491:	85 f6                	test   %esi,%esi
f0101493:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101496:	89 c2                	mov    %eax,%edx
f0101498:	c1 ea 02             	shr    $0x2,%edx
f010149b:	89 15 88 be 22 f0    	mov    %edx,0xf022be88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01014a1:	89 c2                	mov    %eax,%edx
f01014a3:	29 da                	sub    %ebx,%edx
f01014a5:	52                   	push   %edx
f01014a6:	53                   	push   %ebx
f01014a7:	50                   	push   %eax
f01014a8:	68 18 67 10 f0       	push   $0xf0106718
f01014ad:	e8 cc 23 00 00       	call   f010387e <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01014b2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01014b7:	e8 4e f6 ff ff       	call   f0100b0a <boot_alloc>
f01014bc:	a3 8c be 22 f0       	mov    %eax,0xf022be8c
	memset(kern_pgdir, 0, PGSIZE);
f01014c1:	83 c4 0c             	add    $0xc,%esp
f01014c4:	68 00 10 00 00       	push   $0x1000
f01014c9:	6a 00                	push   $0x0
f01014cb:	50                   	push   %eax
f01014cc:	e8 d2 3d 00 00       	call   f01052a3 <memset>
	// a virtual page table at virtual address VPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01014d1:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01014d6:	83 c4 10             	add    $0x10,%esp
f01014d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01014de:	77 15                	ja     f01014f5 <mem_init+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014e0:	50                   	push   %eax
f01014e1:	68 38 60 10 f0       	push   $0xf0106038
f01014e6:	68 9f 00 00 00       	push   $0x9f
f01014eb:	68 61 6f 10 f0       	push   $0xf0106f61
f01014f0:	e8 9f eb ff ff       	call   f0100094 <_panic>
f01014f5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014fb:	83 ca 05             	or     $0x5,%edx
f01014fe:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pde_t * page_root = (pde_t*)boot_alloc(sizeof(struct PageInfo)*npages); 	
f0101504:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f0101509:	c1 e0 03             	shl    $0x3,%eax
f010150c:	e8 f9 f5 ff ff       	call   f0100b0a <boot_alloc>
f0101511:	89 c3                	mov    %eax,%ebx
	memset(page_root, 0, (sizeof(struct PageInfo)*npages));
f0101513:	83 ec 04             	sub    $0x4,%esp
f0101516:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f010151b:	c1 e0 03             	shl    $0x3,%eax
f010151e:	50                   	push   %eax
f010151f:	6a 00                	push   $0x0
f0101521:	53                   	push   %ebx
f0101522:	e8 7c 3d 00 00       	call   f01052a3 <memset>

        pages = (struct PageInfo*)page_root;
f0101527:	89 1d 90 be 22 f0    	mov    %ebx,0xf022be90

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));	
f010152d:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101532:	e8 d3 f5 ff ff       	call   f0100b0a <boot_alloc>
f0101537:	a3 44 b2 22 f0       	mov    %eax,0xf022b244
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010153c:	e8 91 f9 ff ff       	call   f0100ed2 <page_init>

	check_page_free_list(1);
f0101541:	b8 01 00 00 00       	mov    $0x1,%eax
f0101546:	e8 88 f6 ff ff       	call   f0100bd3 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010154b:	83 c4 10             	add    $0x10,%esp
f010154e:	83 3d 90 be 22 f0 00 	cmpl   $0x0,0xf022be90
f0101555:	75 17                	jne    f010156e <mem_init+0x11c>
		panic("'pages' is a null pointer!");
f0101557:	83 ec 04             	sub    $0x4,%esp
f010155a:	68 4f 70 10 f0       	push   $0xf010704f
f010155f:	68 9a 04 00 00       	push   $0x49a
f0101564:	68 61 6f 10 f0       	push   $0xf0106f61
f0101569:	e8 26 eb ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010156e:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101573:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101578:	eb 05                	jmp    f010157f <mem_init+0x12d>
		++nfree;
f010157a:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010157d:	8b 00                	mov    (%eax),%eax
f010157f:	85 c0                	test   %eax,%eax
f0101581:	75 f7                	jne    f010157a <mem_init+0x128>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101583:	83 ec 0c             	sub    $0xc,%esp
f0101586:	6a 00                	push   $0x0
f0101588:	e8 e4 f9 ff ff       	call   f0100f71 <page_alloc>
f010158d:	89 c7                	mov    %eax,%edi
f010158f:	83 c4 10             	add    $0x10,%esp
f0101592:	85 c0                	test   %eax,%eax
f0101594:	75 19                	jne    f01015af <mem_init+0x15d>
f0101596:	68 6a 70 10 f0       	push   $0xf010706a
f010159b:	68 87 6f 10 f0       	push   $0xf0106f87
f01015a0:	68 a2 04 00 00       	push   $0x4a2
f01015a5:	68 61 6f 10 f0       	push   $0xf0106f61
f01015aa:	e8 e5 ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01015af:	83 ec 0c             	sub    $0xc,%esp
f01015b2:	6a 00                	push   $0x0
f01015b4:	e8 b8 f9 ff ff       	call   f0100f71 <page_alloc>
f01015b9:	89 c6                	mov    %eax,%esi
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	85 c0                	test   %eax,%eax
f01015c0:	75 19                	jne    f01015db <mem_init+0x189>
f01015c2:	68 80 70 10 f0       	push   $0xf0107080
f01015c7:	68 87 6f 10 f0       	push   $0xf0106f87
f01015cc:	68 a3 04 00 00       	push   $0x4a3
f01015d1:	68 61 6f 10 f0       	push   $0xf0106f61
f01015d6:	e8 b9 ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015db:	83 ec 0c             	sub    $0xc,%esp
f01015de:	6a 00                	push   $0x0
f01015e0:	e8 8c f9 ff ff       	call   f0100f71 <page_alloc>
f01015e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015e8:	83 c4 10             	add    $0x10,%esp
f01015eb:	85 c0                	test   %eax,%eax
f01015ed:	75 19                	jne    f0101608 <mem_init+0x1b6>
f01015ef:	68 96 70 10 f0       	push   $0xf0107096
f01015f4:	68 87 6f 10 f0       	push   $0xf0106f87
f01015f9:	68 a4 04 00 00       	push   $0x4a4
f01015fe:	68 61 6f 10 f0       	push   $0xf0106f61
f0101603:	e8 8c ea ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1033.\n");	


	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101608:	39 f7                	cmp    %esi,%edi
f010160a:	75 19                	jne    f0101625 <mem_init+0x1d3>
f010160c:	68 ac 70 10 f0       	push   $0xf01070ac
f0101611:	68 87 6f 10 f0       	push   $0xf0106f87
f0101616:	68 aa 04 00 00       	push   $0x4aa
f010161b:	68 61 6f 10 f0       	push   $0xf0106f61
f0101620:	e8 6f ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101625:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101628:	39 c6                	cmp    %eax,%esi
f010162a:	74 04                	je     f0101630 <mem_init+0x1de>
f010162c:	39 c7                	cmp    %eax,%edi
f010162e:	75 19                	jne    f0101649 <mem_init+0x1f7>
f0101630:	68 54 67 10 f0       	push   $0xf0106754
f0101635:	68 87 6f 10 f0       	push   $0xf0106f87
f010163a:	68 ab 04 00 00       	push   $0x4ab
f010163f:	68 61 6f 10 f0       	push   $0xf0106f61
f0101644:	e8 4b ea ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101649:	8b 0d 90 be 22 f0    	mov    0xf022be90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010164f:	8b 15 88 be 22 f0    	mov    0xf022be88,%edx
f0101655:	c1 e2 0c             	shl    $0xc,%edx
f0101658:	89 f8                	mov    %edi,%eax
f010165a:	29 c8                	sub    %ecx,%eax
f010165c:	c1 f8 03             	sar    $0x3,%eax
f010165f:	c1 e0 0c             	shl    $0xc,%eax
f0101662:	39 d0                	cmp    %edx,%eax
f0101664:	72 19                	jb     f010167f <mem_init+0x22d>
f0101666:	68 be 70 10 f0       	push   $0xf01070be
f010166b:	68 87 6f 10 f0       	push   $0xf0106f87
f0101670:	68 ac 04 00 00       	push   $0x4ac
f0101675:	68 61 6f 10 f0       	push   $0xf0106f61
f010167a:	e8 15 ea ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010167f:	89 f0                	mov    %esi,%eax
f0101681:	29 c8                	sub    %ecx,%eax
f0101683:	c1 f8 03             	sar    $0x3,%eax
f0101686:	c1 e0 0c             	shl    $0xc,%eax
f0101689:	39 c2                	cmp    %eax,%edx
f010168b:	77 19                	ja     f01016a6 <mem_init+0x254>
f010168d:	68 db 70 10 f0       	push   $0xf01070db
f0101692:	68 87 6f 10 f0       	push   $0xf0106f87
f0101697:	68 ad 04 00 00       	push   $0x4ad
f010169c:	68 61 6f 10 f0       	push   $0xf0106f61
f01016a1:	e8 ee e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016a9:	29 c8                	sub    %ecx,%eax
f01016ab:	c1 f8 03             	sar    $0x3,%eax
f01016ae:	c1 e0 0c             	shl    $0xc,%eax
f01016b1:	39 c2                	cmp    %eax,%edx
f01016b3:	77 19                	ja     f01016ce <mem_init+0x27c>
f01016b5:	68 f8 70 10 f0       	push   $0xf01070f8
f01016ba:	68 87 6f 10 f0       	push   $0xf0106f87
f01016bf:	68 ae 04 00 00       	push   $0x4ae
f01016c4:	68 61 6f 10 f0       	push   $0xf0106f61
f01016c9:	e8 c6 e9 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016ce:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f01016d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016d6:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f01016dd:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016e0:	83 ec 0c             	sub    $0xc,%esp
f01016e3:	6a 00                	push   $0x0
f01016e5:	e8 87 f8 ff ff       	call   f0100f71 <page_alloc>
f01016ea:	83 c4 10             	add    $0x10,%esp
f01016ed:	85 c0                	test   %eax,%eax
f01016ef:	74 19                	je     f010170a <mem_init+0x2b8>
f01016f1:	68 15 71 10 f0       	push   $0xf0107115
f01016f6:	68 87 6f 10 f0       	push   $0xf0106f87
f01016fb:	68 b5 04 00 00       	push   $0x4b5
f0101700:	68 61 6f 10 f0       	push   $0xf0106f61
f0101705:	e8 8a e9 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1050.\n");	


	// free and re-allocate?
	page_free(pp0);
f010170a:	83 ec 0c             	sub    $0xc,%esp
f010170d:	57                   	push   %edi
f010170e:	e8 17 f9 ff ff       	call   f010102a <page_free>
	page_free(pp1);
f0101713:	89 34 24             	mov    %esi,(%esp)
f0101716:	e8 0f f9 ff ff       	call   f010102a <page_free>
	page_free(pp2);
f010171b:	83 c4 04             	add    $0x4,%esp
f010171e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101721:	e8 04 f9 ff ff       	call   f010102a <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101726:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010172d:	e8 3f f8 ff ff       	call   f0100f71 <page_alloc>
f0101732:	89 c6                	mov    %eax,%esi
f0101734:	83 c4 10             	add    $0x10,%esp
f0101737:	85 c0                	test   %eax,%eax
f0101739:	75 19                	jne    f0101754 <mem_init+0x302>
f010173b:	68 6a 70 10 f0       	push   $0xf010706a
f0101740:	68 87 6f 10 f0       	push   $0xf0106f87
f0101745:	68 bf 04 00 00       	push   $0x4bf
f010174a:	68 61 6f 10 f0       	push   $0xf0106f61
f010174f:	e8 40 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101754:	83 ec 0c             	sub    $0xc,%esp
f0101757:	6a 00                	push   $0x0
f0101759:	e8 13 f8 ff ff       	call   f0100f71 <page_alloc>
f010175e:	89 c7                	mov    %eax,%edi
f0101760:	83 c4 10             	add    $0x10,%esp
f0101763:	85 c0                	test   %eax,%eax
f0101765:	75 19                	jne    f0101780 <mem_init+0x32e>
f0101767:	68 80 70 10 f0       	push   $0xf0107080
f010176c:	68 87 6f 10 f0       	push   $0xf0106f87
f0101771:	68 c0 04 00 00       	push   $0x4c0
f0101776:	68 61 6f 10 f0       	push   $0xf0106f61
f010177b:	e8 14 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101780:	83 ec 0c             	sub    $0xc,%esp
f0101783:	6a 00                	push   $0x0
f0101785:	e8 e7 f7 ff ff       	call   f0100f71 <page_alloc>
f010178a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010178d:	83 c4 10             	add    $0x10,%esp
f0101790:	85 c0                	test   %eax,%eax
f0101792:	75 19                	jne    f01017ad <mem_init+0x35b>
f0101794:	68 96 70 10 f0       	push   $0xf0107096
f0101799:	68 87 6f 10 f0       	push   $0xf0106f87
f010179e:	68 c1 04 00 00       	push   $0x4c1
f01017a3:	68 61 6f 10 f0       	push   $0xf0106f61
f01017a8:	e8 e7 e8 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017ad:	39 fe                	cmp    %edi,%esi
f01017af:	75 19                	jne    f01017ca <mem_init+0x378>
f01017b1:	68 ac 70 10 f0       	push   $0xf01070ac
f01017b6:	68 87 6f 10 f0       	push   $0xf0106f87
f01017bb:	68 c3 04 00 00       	push   $0x4c3
f01017c0:	68 61 6f 10 f0       	push   $0xf0106f61
f01017c5:	e8 ca e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017cd:	39 c7                	cmp    %eax,%edi
f01017cf:	74 04                	je     f01017d5 <mem_init+0x383>
f01017d1:	39 c6                	cmp    %eax,%esi
f01017d3:	75 19                	jne    f01017ee <mem_init+0x39c>
f01017d5:	68 54 67 10 f0       	push   $0xf0106754
f01017da:	68 87 6f 10 f0       	push   $0xf0106f87
f01017df:	68 c4 04 00 00       	push   $0x4c4
f01017e4:	68 61 6f 10 f0       	push   $0xf0106f61
f01017e9:	e8 a6 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017ee:	83 ec 0c             	sub    $0xc,%esp
f01017f1:	6a 00                	push   $0x0
f01017f3:	e8 79 f7 ff ff       	call   f0100f71 <page_alloc>
f01017f8:	83 c4 10             	add    $0x10,%esp
f01017fb:	85 c0                	test   %eax,%eax
f01017fd:	74 19                	je     f0101818 <mem_init+0x3c6>
f01017ff:	68 15 71 10 f0       	push   $0xf0107115
f0101804:	68 87 6f 10 f0       	push   $0xf0106f87
f0101809:	68 c5 04 00 00       	push   $0x4c5
f010180e:	68 61 6f 10 f0       	push   $0xf0106f61
f0101813:	e8 7c e8 ff ff       	call   f0100094 <_panic>
f0101818:	89 f0                	mov    %esi,%eax
f010181a:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101820:	c1 f8 03             	sar    $0x3,%eax
f0101823:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101826:	89 c2                	mov    %eax,%edx
f0101828:	c1 ea 0c             	shr    $0xc,%edx
f010182b:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0101831:	72 12                	jb     f0101845 <mem_init+0x3f3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101833:	50                   	push   %eax
f0101834:	68 14 60 10 f0       	push   $0xf0106014
f0101839:	6a 58                	push   $0x58
f010183b:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0101840:	e8 4f e8 ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1066.\n");	


	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101845:	83 ec 04             	sub    $0x4,%esp
f0101848:	68 00 10 00 00       	push   $0x1000
f010184d:	6a 01                	push   $0x1
f010184f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101854:	50                   	push   %eax
f0101855:	e8 49 3a 00 00       	call   f01052a3 <memset>
	page_free(pp0);
f010185a:	89 34 24             	mov    %esi,(%esp)
f010185d:	e8 c8 f7 ff ff       	call   f010102a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101862:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101869:	e8 03 f7 ff ff       	call   f0100f71 <page_alloc>
f010186e:	83 c4 10             	add    $0x10,%esp
f0101871:	85 c0                	test   %eax,%eax
f0101873:	75 19                	jne    f010188e <mem_init+0x43c>
f0101875:	68 24 71 10 f0       	push   $0xf0107124
f010187a:	68 87 6f 10 f0       	push   $0xf0106f87
f010187f:	68 cd 04 00 00       	push   $0x4cd
f0101884:	68 61 6f 10 f0       	push   $0xf0106f61
f0101889:	e8 06 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010188e:	39 c6                	cmp    %eax,%esi
f0101890:	74 19                	je     f01018ab <mem_init+0x459>
f0101892:	68 42 71 10 f0       	push   $0xf0107142
f0101897:	68 87 6f 10 f0       	push   $0xf0106f87
f010189c:	68 ce 04 00 00       	push   $0x4ce
f01018a1:	68 61 6f 10 f0       	push   $0xf0106f61
f01018a6:	e8 e9 e7 ff ff       	call   f0100094 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018ab:	89 f0                	mov    %esi,%eax
f01018ad:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f01018b3:	c1 f8 03             	sar    $0x3,%eax
f01018b6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018b9:	89 c2                	mov    %eax,%edx
f01018bb:	c1 ea 0c             	shr    $0xc,%edx
f01018be:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f01018c4:	72 12                	jb     f01018d8 <mem_init+0x486>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018c6:	50                   	push   %eax
f01018c7:	68 14 60 10 f0       	push   $0xf0106014
f01018cc:	6a 58                	push   $0x58
f01018ce:	68 6d 6f 10 f0       	push   $0xf0106f6d
f01018d3:	e8 bc e7 ff ff       	call   f0100094 <_panic>
f01018d8:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018de:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018e4:	80 38 00             	cmpb   $0x0,(%eax)
f01018e7:	74 19                	je     f0101902 <mem_init+0x4b0>
f01018e9:	68 52 71 10 f0       	push   $0xf0107152
f01018ee:	68 87 6f 10 f0       	push   $0xf0106f87
f01018f3:	68 d1 04 00 00       	push   $0x4d1
f01018f8:	68 61 6f 10 f0       	push   $0xf0106f61
f01018fd:	e8 92 e7 ff ff       	call   f0100094 <_panic>
f0101902:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101905:	39 d0                	cmp    %edx,%eax
f0101907:	75 db                	jne    f01018e4 <mem_init+0x492>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101909:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010190c:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f0101911:	83 ec 0c             	sub    $0xc,%esp
f0101914:	56                   	push   %esi
f0101915:	e8 10 f7 ff ff       	call   f010102a <page_free>
	page_free(pp1);
f010191a:	89 3c 24             	mov    %edi,(%esp)
f010191d:	e8 08 f7 ff ff       	call   f010102a <page_free>
	page_free(pp2);
f0101922:	83 c4 04             	add    $0x4,%esp
f0101925:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101928:	e8 fd f6 ff ff       	call   f010102a <page_free>
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010192d:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101932:	83 c4 10             	add    $0x10,%esp
f0101935:	eb 05                	jmp    f010193c <mem_init+0x4ea>
		--nfree;
f0101937:	83 eb 01             	sub    $0x1,%ebx
//my test code
	//cprintf("here is my test code 1086.\n");	


	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010193a:	8b 00                	mov    (%eax),%eax
f010193c:	85 c0                	test   %eax,%eax
f010193e:	75 f7                	jne    f0101937 <mem_init+0x4e5>
		--nfree;
	assert(nfree == 0);
f0101940:	85 db                	test   %ebx,%ebx
f0101942:	74 19                	je     f010195d <mem_init+0x50b>
f0101944:	68 5c 71 10 f0       	push   $0xf010715c
f0101949:	68 87 6f 10 f0       	push   $0xf0106f87
f010194e:	68 e1 04 00 00       	push   $0x4e1
f0101953:	68 61 6f 10 f0       	push   $0xf0106f61
f0101958:	e8 37 e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010195d:	83 ec 0c             	sub    $0xc,%esp
f0101960:	68 74 67 10 f0       	push   $0xf0106774
f0101965:	e8 14 1f 00 00       	call   f010387e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010196a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101971:	e8 fb f5 ff ff       	call   f0100f71 <page_alloc>
f0101976:	89 c6                	mov    %eax,%esi
f0101978:	83 c4 10             	add    $0x10,%esp
f010197b:	85 c0                	test   %eax,%eax
f010197d:	75 19                	jne    f0101998 <mem_init+0x546>
f010197f:	68 6a 70 10 f0       	push   $0xf010706a
f0101984:	68 87 6f 10 f0       	push   $0xf0106f87
f0101989:	68 5b 05 00 00       	push   $0x55b
f010198e:	68 61 6f 10 f0       	push   $0xf0106f61
f0101993:	e8 fc e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101998:	83 ec 0c             	sub    $0xc,%esp
f010199b:	6a 00                	push   $0x0
f010199d:	e8 cf f5 ff ff       	call   f0100f71 <page_alloc>
f01019a2:	89 c3                	mov    %eax,%ebx
f01019a4:	83 c4 10             	add    $0x10,%esp
f01019a7:	85 c0                	test   %eax,%eax
f01019a9:	75 19                	jne    f01019c4 <mem_init+0x572>
f01019ab:	68 80 70 10 f0       	push   $0xf0107080
f01019b0:	68 87 6f 10 f0       	push   $0xf0106f87
f01019b5:	68 5c 05 00 00       	push   $0x55c
f01019ba:	68 61 6f 10 f0       	push   $0xf0106f61
f01019bf:	e8 d0 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01019c4:	83 ec 0c             	sub    $0xc,%esp
f01019c7:	6a 00                	push   $0x0
f01019c9:	e8 a3 f5 ff ff       	call   f0100f71 <page_alloc>
f01019ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019d1:	83 c4 10             	add    $0x10,%esp
f01019d4:	85 c0                	test   %eax,%eax
f01019d6:	75 19                	jne    f01019f1 <mem_init+0x59f>
f01019d8:	68 96 70 10 f0       	push   $0xf0107096
f01019dd:	68 87 6f 10 f0       	push   $0xf0106f87
f01019e2:	68 5d 05 00 00       	push   $0x55d
f01019e7:	68 61 6f 10 f0       	push   $0xf0106f61
f01019ec:	e8 a3 e6 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019f1:	39 de                	cmp    %ebx,%esi
f01019f3:	75 19                	jne    f0101a0e <mem_init+0x5bc>
f01019f5:	68 ac 70 10 f0       	push   $0xf01070ac
f01019fa:	68 87 6f 10 f0       	push   $0xf0106f87
f01019ff:	68 60 05 00 00       	push   $0x560
f0101a04:	68 61 6f 10 f0       	push   $0xf0106f61
f0101a09:	e8 86 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a11:	39 c6                	cmp    %eax,%esi
f0101a13:	74 04                	je     f0101a19 <mem_init+0x5c7>
f0101a15:	39 c3                	cmp    %eax,%ebx
f0101a17:	75 19                	jne    f0101a32 <mem_init+0x5e0>
f0101a19:	68 54 67 10 f0       	push   $0xf0106754
f0101a1e:	68 87 6f 10 f0       	push   $0xf0106f87
f0101a23:	68 61 05 00 00       	push   $0x561
f0101a28:	68 61 6f 10 f0       	push   $0xf0106f61
f0101a2d:	e8 62 e6 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a32:	a1 40 b2 22 f0       	mov    0xf022b240,%eax
f0101a37:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a3a:	c7 05 40 b2 22 f0 00 	movl   $0x0,0xf022b240
f0101a41:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a44:	83 ec 0c             	sub    $0xc,%esp
f0101a47:	6a 00                	push   $0x0
f0101a49:	e8 23 f5 ff ff       	call   f0100f71 <page_alloc>
f0101a4e:	83 c4 10             	add    $0x10,%esp
f0101a51:	85 c0                	test   %eax,%eax
f0101a53:	74 19                	je     f0101a6e <mem_init+0x61c>
f0101a55:	68 15 71 10 f0       	push   $0xf0107115
f0101a5a:	68 87 6f 10 f0       	push   $0xf0106f87
f0101a5f:	68 68 05 00 00       	push   $0x568
f0101a64:	68 61 6f 10 f0       	push   $0xf0106f61
f0101a69:	e8 26 e6 ff ff       	call   f0100094 <_panic>
//cprintf("the page_free_list:%d\n",page_free_list);

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a6e:	83 ec 04             	sub    $0x4,%esp
f0101a71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a74:	50                   	push   %eax
f0101a75:	6a 00                	push   $0x0
f0101a77:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101a7d:	e8 fe f7 ff ff       	call   f0101280 <page_lookup>
f0101a82:	83 c4 10             	add    $0x10,%esp
f0101a85:	85 c0                	test   %eax,%eax
f0101a87:	74 19                	je     f0101aa2 <mem_init+0x650>
f0101a89:	68 94 67 10 f0       	push   $0xf0106794
f0101a8e:	68 87 6f 10 f0       	push   $0xf0106f87
f0101a93:	68 6c 05 00 00       	push   $0x56c
f0101a98:	68 61 6f 10 f0       	push   $0xf0106f61
f0101a9d:	e8 f2 e5 ff ff       	call   f0100094 <_panic>
	
//cprintf("#    the page_free_list:%d\n",page_free_list);

	// there is no free memory, so we can't allocate a page table
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101aa2:	6a 02                	push   $0x2
f0101aa4:	6a 00                	push   $0x0
f0101aa6:	53                   	push   %ebx
f0101aa7:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101aad:	e8 ae f8 ff ff       	call   f0101360 <page_insert>
f0101ab2:	83 c4 10             	add    $0x10,%esp
f0101ab5:	85 c0                	test   %eax,%eax
f0101ab7:	78 19                	js     f0101ad2 <mem_init+0x680>
f0101ab9:	68 cc 67 10 f0       	push   $0xf01067cc
f0101abe:	68 87 6f 10 f0       	push   $0xf0106f87
f0101ac3:	68 74 05 00 00       	push   $0x574
f0101ac8:	68 61 6f 10 f0       	push   $0xf0106f61
f0101acd:	e8 c2 e5 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
//cprintf("##     the page_free_list:%d\n",page_free_list);
//cprintf("$$ at before the page_free(pp0)\n\n");
	page_free(pp0);
f0101ad2:	83 ec 0c             	sub    $0xc,%esp
f0101ad5:	56                   	push   %esi
f0101ad6:	e8 4f f5 ff ff       	call   f010102a <page_free>
//cprintf("$$ at before the page_insert pp1 at 0x0\n\n");
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101adb:	6a 02                	push   $0x2
f0101add:	6a 00                	push   $0x0
f0101adf:	53                   	push   %ebx
f0101ae0:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101ae6:	e8 75 f8 ff ff       	call   f0101360 <page_insert>
f0101aeb:	83 c4 20             	add    $0x20,%esp
f0101aee:	85 c0                	test   %eax,%eax
f0101af0:	74 19                	je     f0101b0b <mem_init+0x6b9>
f0101af2:	68 fc 67 10 f0       	push   $0xf01067fc
f0101af7:	68 87 6f 10 f0       	push   $0xf0106f87
f0101afc:	68 7b 05 00 00       	push   $0x57b
f0101b01:	68 61 6f 10 f0       	push   $0xf0106f61
f0101b06:	e8 89 e5 ff ff       	call   f0100094 <_panic>

//cprintf("## %x  %x\n",PTE_ADDR(kern_pgdir[0]),page2pa(pp0));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b0b:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b11:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0101b16:	89 c1                	mov    %eax,%ecx
f0101b18:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b1b:	8b 17                	mov    (%edi),%edx
f0101b1d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b23:	89 f0                	mov    %esi,%eax
f0101b25:	29 c8                	sub    %ecx,%eax
f0101b27:	c1 f8 03             	sar    $0x3,%eax
f0101b2a:	c1 e0 0c             	shl    $0xc,%eax
f0101b2d:	39 c2                	cmp    %eax,%edx
f0101b2f:	74 19                	je     f0101b4a <mem_init+0x6f8>
f0101b31:	68 2c 68 10 f0       	push   $0xf010682c
f0101b36:	68 87 6f 10 f0       	push   $0xf0106f87
f0101b3b:	68 7e 05 00 00       	push   $0x57e
f0101b40:	68 61 6f 10 f0       	push   $0xf0106f61
f0101b45:	e8 4a e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b4f:	89 f8                	mov    %edi,%eax
f0101b51:	e8 19 f0 ff ff       	call   f0100b6f <check_va2pa>
f0101b56:	89 da                	mov    %ebx,%edx
f0101b58:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b5b:	c1 fa 03             	sar    $0x3,%edx
f0101b5e:	c1 e2 0c             	shl    $0xc,%edx
f0101b61:	39 d0                	cmp    %edx,%eax
f0101b63:	74 19                	je     f0101b7e <mem_init+0x72c>
f0101b65:	68 54 68 10 f0       	push   $0xf0106854
f0101b6a:	68 87 6f 10 f0       	push   $0xf0106f87
f0101b6f:	68 7f 05 00 00       	push   $0x57f
f0101b74:	68 61 6f 10 f0       	push   $0xf0106f61
f0101b79:	e8 16 e5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101b7e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b83:	74 19                	je     f0101b9e <mem_init+0x74c>
f0101b85:	68 67 71 10 f0       	push   $0xf0107167
f0101b8a:	68 87 6f 10 f0       	push   $0xf0106f87
f0101b8f:	68 80 05 00 00       	push   $0x580
f0101b94:	68 61 6f 10 f0       	push   $0xf0106f61
f0101b99:	e8 f6 e4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101b9e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ba3:	74 19                	je     f0101bbe <mem_init+0x76c>
f0101ba5:	68 78 71 10 f0       	push   $0xf0107178
f0101baa:	68 87 6f 10 f0       	push   $0xf0106f87
f0101baf:	68 81 05 00 00       	push   $0x581
f0101bb4:	68 61 6f 10 f0       	push   $0xf0106f61
f0101bb9:	e8 d6 e4 ff ff       	call   f0100094 <_panic>
//cprintf("###  before page_insert pp2  the page_free_list:%d\n",page_free_list);

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
//cprintf("$$ at before the page_insert pp2 at PGSIZE\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101bbe:	6a 02                	push   $0x2
f0101bc0:	68 00 10 00 00       	push   $0x1000
f0101bc5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101bc8:	57                   	push   %edi
f0101bc9:	e8 92 f7 ff ff       	call   f0101360 <page_insert>
f0101bce:	83 c4 10             	add    $0x10,%esp
f0101bd1:	85 c0                	test   %eax,%eax
f0101bd3:	74 19                	je     f0101bee <mem_init+0x79c>
f0101bd5:	68 84 68 10 f0       	push   $0xf0106884
f0101bda:	68 87 6f 10 f0       	push   $0xf0106f87
f0101bdf:	68 86 05 00 00       	push   $0x586
f0101be4:	68 61 6f 10 f0       	push   $0xf0106f61
f0101be9:	e8 a6 e4 ff ff       	call   f0100094 <_panic>
//cprintf("#### here we get over the page_insert page_free_list:%x.\n",page_free_list);
//cprintf("pp0:%x\npp1:%x\npp2:%x\n",pp0,pp1,pp2);	
//cprintf("!! the check_va2pa is %d,page2pa(pp1) %x\n",check_va2pa(kern_pgdir,PGSIZE),page2pa(pp2));


	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bee:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bf3:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101bf8:	e8 72 ef ff ff       	call   f0100b6f <check_va2pa>
f0101bfd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c00:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101c06:	c1 fa 03             	sar    $0x3,%edx
f0101c09:	c1 e2 0c             	shl    $0xc,%edx
f0101c0c:	39 d0                	cmp    %edx,%eax
f0101c0e:	74 19                	je     f0101c29 <mem_init+0x7d7>
f0101c10:	68 c0 68 10 f0       	push   $0xf01068c0
f0101c15:	68 87 6f 10 f0       	push   $0xf0106f87
f0101c1a:	68 8c 05 00 00       	push   $0x58c
f0101c1f:	68 61 6f 10 f0       	push   $0xf0106f61
f0101c24:	e8 6b e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c2c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c31:	74 19                	je     f0101c4c <mem_init+0x7fa>
f0101c33:	68 89 71 10 f0       	push   $0xf0107189
f0101c38:	68 87 6f 10 f0       	push   $0xf0106f87
f0101c3d:	68 8d 05 00 00       	push   $0x58d
f0101c42:	68 61 6f 10 f0       	push   $0xf0106f61
f0101c47:	e8 48 e4 ff ff       	call   f0100094 <_panic>

	// should be no free memory
//cprintf("##### before_page_alloc:  the page_free_list:%d\n",page_free_list);
	assert(!page_alloc(0));
f0101c4c:	83 ec 0c             	sub    $0xc,%esp
f0101c4f:	6a 00                	push   $0x0
f0101c51:	e8 1b f3 ff ff       	call   f0100f71 <page_alloc>
f0101c56:	83 c4 10             	add    $0x10,%esp
f0101c59:	85 c0                	test   %eax,%eax
f0101c5b:	74 19                	je     f0101c76 <mem_init+0x824>
f0101c5d:	68 15 71 10 f0       	push   $0xf0107115
f0101c62:	68 87 6f 10 f0       	push   $0xf0106f87
f0101c67:	68 91 05 00 00       	push   $0x591
f0101c6c:	68 61 6f 10 f0       	push   $0xf0106f61
f0101c71:	e8 1e e4 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
//cprintf("$$ at twice before the page_insert pp2 at PGSIZE.\n\n");
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c76:	6a 02                	push   $0x2
f0101c78:	68 00 10 00 00       	push   $0x1000
f0101c7d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c80:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101c86:	e8 d5 f6 ff ff       	call   f0101360 <page_insert>
f0101c8b:	83 c4 10             	add    $0x10,%esp
f0101c8e:	85 c0                	test   %eax,%eax
f0101c90:	74 19                	je     f0101cab <mem_init+0x859>
f0101c92:	68 84 68 10 f0       	push   $0xf0106884
f0101c97:	68 87 6f 10 f0       	push   $0xf0106f87
f0101c9c:	68 95 05 00 00       	push   $0x595
f0101ca1:	68 61 6f 10 f0       	push   $0xf0106f61
f0101ca6:	e8 e9 e3 ff ff       	call   f0100094 <_panic>
//	for(struct PageInfo *temp_pp = page_free_list;temp_pp;temp_pp = temp_pp->pp_link){
//		cprintf("the temp_pp:%x\n",temp_pp);
//	}
	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cab:	83 ec 0c             	sub    $0xc,%esp
f0101cae:	6a 00                	push   $0x0
f0101cb0:	e8 bc f2 ff ff       	call   f0100f71 <page_alloc>
f0101cb5:	83 c4 10             	add    $0x10,%esp
f0101cb8:	85 c0                	test   %eax,%eax
f0101cba:	74 19                	je     f0101cd5 <mem_init+0x883>
f0101cbc:	68 15 71 10 f0       	push   $0xf0107115
f0101cc1:	68 87 6f 10 f0       	push   $0xf0106f87
f0101cc6:	68 a1 05 00 00       	push   $0x5a1
f0101ccb:	68 61 6f 10 f0       	push   $0xf0106f61
f0101cd0:	e8 bf e3 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101cd5:	8b 15 8c be 22 f0    	mov    0xf022be8c,%edx
f0101cdb:	8b 02                	mov    (%edx),%eax
f0101cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ce2:	89 c1                	mov    %eax,%ecx
f0101ce4:	c1 e9 0c             	shr    $0xc,%ecx
f0101ce7:	3b 0d 88 be 22 f0    	cmp    0xf022be88,%ecx
f0101ced:	72 15                	jb     f0101d04 <mem_init+0x8b2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101cef:	50                   	push   %eax
f0101cf0:	68 14 60 10 f0       	push   $0xf0106014
f0101cf5:	68 a4 05 00 00       	push   $0x5a4
f0101cfa:	68 61 6f 10 f0       	push   $0xf0106f61
f0101cff:	e8 90 e3 ff ff       	call   f0100094 <_panic>
f0101d04:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
//cprintf("the pgdir_walk(kern_pgdir,(void*)PGSIZE,0):%x\n",pgdir_walk(kern_pgdir,(void*)PGSIZE,0));
//cprintf("ptep+PTX(PGSIZE):%x\n",ptep+PTX(PGSIZE));
//cprintf("ptep:%x\n",ptep);
//cprintf("PTX(PGSIZE):%x\n",PTX(PGSIZE));
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d0c:	83 ec 04             	sub    $0x4,%esp
f0101d0f:	6a 00                	push   $0x0
f0101d11:	68 00 10 00 00       	push   $0x1000
f0101d16:	52                   	push   %edx
f0101d17:	e8 ef f3 ff ff       	call   f010110b <pgdir_walk>
f0101d1c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d1f:	8d 51 04             	lea    0x4(%ecx),%edx
f0101d22:	83 c4 10             	add    $0x10,%esp
f0101d25:	39 d0                	cmp    %edx,%eax
f0101d27:	74 19                	je     f0101d42 <mem_init+0x8f0>
f0101d29:	68 f0 68 10 f0       	push   $0xf01068f0
f0101d2e:	68 87 6f 10 f0       	push   $0xf0106f87
f0101d33:	68 a9 05 00 00       	push   $0x5a9
f0101d38:	68 61 6f 10 f0       	push   $0xf0106f61
f0101d3d:	e8 52 e3 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 3th page_insert pp2 to PGSIZE with changing the permissions.\n\n");
	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d42:	6a 06                	push   $0x6
f0101d44:	68 00 10 00 00       	push   $0x1000
f0101d49:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d4c:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101d52:	e8 09 f6 ff ff       	call   f0101360 <page_insert>
f0101d57:	83 c4 10             	add    $0x10,%esp
f0101d5a:	85 c0                	test   %eax,%eax
f0101d5c:	74 19                	je     f0101d77 <mem_init+0x925>
f0101d5e:	68 30 69 10 f0       	push   $0xf0106930
f0101d63:	68 87 6f 10 f0       	push   $0xf0106f87
f0101d68:	68 ac 05 00 00       	push   $0x5ac
f0101d6d:	68 61 6f 10 f0       	push   $0xf0106f61
f0101d72:	e8 1d e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d77:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0101d7d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d82:	89 f8                	mov    %edi,%eax
f0101d84:	e8 e6 ed ff ff       	call   f0100b6f <check_va2pa>
f0101d89:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101d8c:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0101d92:	c1 fa 03             	sar    $0x3,%edx
f0101d95:	c1 e2 0c             	shl    $0xc,%edx
f0101d98:	39 d0                	cmp    %edx,%eax
f0101d9a:	74 19                	je     f0101db5 <mem_init+0x963>
f0101d9c:	68 c0 68 10 f0       	push   $0xf01068c0
f0101da1:	68 87 6f 10 f0       	push   $0xf0106f87
f0101da6:	68 ad 05 00 00       	push   $0x5ad
f0101dab:	68 61 6f 10 f0       	push   $0xf0106f61
f0101db0:	e8 df e2 ff ff       	call   f0100094 <_panic>
//	cprintf("the final pp2->pp_ref:%x\n",pp2->pp_ref);
	assert(pp2->pp_ref == 1);
f0101db5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dbd:	74 19                	je     f0101dd8 <mem_init+0x986>
f0101dbf:	68 89 71 10 f0       	push   $0xf0107189
f0101dc4:	68 87 6f 10 f0       	push   $0xf0106f87
f0101dc9:	68 af 05 00 00       	push   $0x5af
f0101dce:	68 61 6f 10 f0       	push   $0xf0106f61
f0101dd3:	e8 bc e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101dd8:	83 ec 04             	sub    $0x4,%esp
f0101ddb:	6a 00                	push   $0x0
f0101ddd:	68 00 10 00 00       	push   $0x1000
f0101de2:	57                   	push   %edi
f0101de3:	e8 23 f3 ff ff       	call   f010110b <pgdir_walk>
f0101de8:	83 c4 10             	add    $0x10,%esp
f0101deb:	f6 00 04             	testb  $0x4,(%eax)
f0101dee:	75 19                	jne    f0101e09 <mem_init+0x9b7>
f0101df0:	68 70 69 10 f0       	push   $0xf0106970
f0101df5:	68 87 6f 10 f0       	push   $0xf0106f87
f0101dfa:	68 b0 05 00 00       	push   $0x5b0
f0101dff:	68 61 6f 10 f0       	push   $0xf0106f61
f0101e04:	e8 8b e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e09:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101e0e:	f6 00 04             	testb  $0x4,(%eax)
f0101e11:	75 19                	jne    f0101e2c <mem_init+0x9da>
f0101e13:	68 9a 71 10 f0       	push   $0xf010719a
f0101e18:	68 87 6f 10 f0       	push   $0xf0106f87
f0101e1d:	68 b1 05 00 00       	push   $0x5b1
f0101e22:	68 61 6f 10 f0       	push   $0xf0106f61
f0101e27:	e8 68 e2 ff ff       	call   f0100094 <_panic>
//cprintf("$$ at 4th the new line page_insert pp2 PGSIZE with fewer permissions\n\n");
	// should be able to remap with fewer permissions ??
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e2c:	6a 02                	push   $0x2
f0101e2e:	68 00 10 00 00       	push   $0x1000
f0101e33:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e36:	50                   	push   %eax
f0101e37:	e8 24 f5 ff ff       	call   f0101360 <page_insert>
f0101e3c:	83 c4 10             	add    $0x10,%esp
f0101e3f:	85 c0                	test   %eax,%eax
f0101e41:	74 19                	je     f0101e5c <mem_init+0xa0a>
f0101e43:	68 84 68 10 f0       	push   $0xf0106884
f0101e48:	68 87 6f 10 f0       	push   $0xf0106f87
f0101e4d:	68 b4 05 00 00       	push   $0x5b4
f0101e52:	68 61 6f 10 f0       	push   $0xf0106f61
f0101e57:	e8 38 e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e5c:	83 ec 04             	sub    $0x4,%esp
f0101e5f:	6a 00                	push   $0x0
f0101e61:	68 00 10 00 00       	push   $0x1000
f0101e66:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101e6c:	e8 9a f2 ff ff       	call   f010110b <pgdir_walk>
f0101e71:	83 c4 10             	add    $0x10,%esp
f0101e74:	f6 00 02             	testb  $0x2,(%eax)
f0101e77:	75 19                	jne    f0101e92 <mem_init+0xa40>
f0101e79:	68 a4 69 10 f0       	push   $0xf01069a4
f0101e7e:	68 87 6f 10 f0       	push   $0xf0106f87
f0101e83:	68 b5 05 00 00       	push   $0x5b5
f0101e88:	68 61 6f 10 f0       	push   $0xf0106f61
f0101e8d:	e8 02 e2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e92:	83 ec 04             	sub    $0x4,%esp
f0101e95:	6a 00                	push   $0x0
f0101e97:	68 00 10 00 00       	push   $0x1000
f0101e9c:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101ea2:	e8 64 f2 ff ff       	call   f010110b <pgdir_walk>
f0101ea7:	83 c4 10             	add    $0x10,%esp
f0101eaa:	f6 00 04             	testb  $0x4,(%eax)
f0101ead:	74 19                	je     f0101ec8 <mem_init+0xa76>
f0101eaf:	68 d8 69 10 f0       	push   $0xf01069d8
f0101eb4:	68 87 6f 10 f0       	push   $0xf0106f87
f0101eb9:	68 b6 05 00 00       	push   $0x5b6
f0101ebe:	68 61 6f 10 f0       	push   $0xf0106f61
f0101ec3:	e8 cc e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
//cprintf("$$ before the page_insert into PTSIZE\n\n");
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ec8:	6a 02                	push   $0x2
f0101eca:	68 00 00 40 00       	push   $0x400000
f0101ecf:	56                   	push   %esi
f0101ed0:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101ed6:	e8 85 f4 ff ff       	call   f0101360 <page_insert>
f0101edb:	83 c4 10             	add    $0x10,%esp
f0101ede:	85 c0                	test   %eax,%eax
f0101ee0:	78 19                	js     f0101efb <mem_init+0xaa9>
f0101ee2:	68 10 6a 10 f0       	push   $0xf0106a10
f0101ee7:	68 87 6f 10 f0       	push   $0xf0106f87
f0101eec:	68 ba 05 00 00       	push   $0x5ba
f0101ef1:	68 61 6f 10 f0       	push   $0xf0106f61
f0101ef6:	e8 99 e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
//cprintf("$$ before insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101efb:	6a 02                	push   $0x2
f0101efd:	68 00 10 00 00       	push   $0x1000
f0101f02:	53                   	push   %ebx
f0101f03:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f09:	e8 52 f4 ff ff       	call   f0101360 <page_insert>
f0101f0e:	83 c4 10             	add    $0x10,%esp
f0101f11:	85 c0                	test   %eax,%eax
f0101f13:	74 19                	je     f0101f2e <mem_init+0xadc>
f0101f15:	68 48 6a 10 f0       	push   $0xf0106a48
f0101f1a:	68 87 6f 10 f0       	push   $0xf0106f87
f0101f1f:	68 be 05 00 00       	push   $0x5be
f0101f24:	68 61 6f 10 f0       	push   $0xf0106f61
f0101f29:	e8 66 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after insert pp1 at PGSIZE(replacing pp2)\n\n");
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f2e:	83 ec 04             	sub    $0x4,%esp
f0101f31:	6a 00                	push   $0x0
f0101f33:	68 00 10 00 00       	push   $0x1000
f0101f38:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0101f3e:	e8 c8 f1 ff ff       	call   f010110b <pgdir_walk>
f0101f43:	83 c4 10             	add    $0x10,%esp
f0101f46:	f6 00 04             	testb  $0x4,(%eax)
f0101f49:	74 19                	je     f0101f64 <mem_init+0xb12>
f0101f4b:	68 d8 69 10 f0       	push   $0xf01069d8
f0101f50:	68 87 6f 10 f0       	push   $0xf0106f87
f0101f55:	68 c0 05 00 00       	push   $0x5c0
f0101f5a:	68 61 6f 10 f0       	push   $0xf0106f61
f0101f5f:	e8 30 e1 ff ff       	call   f0100094 <_panic>
//cprintf("$$ after checking the (!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U)\n\n");
	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f64:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0101f6a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f6f:	89 f8                	mov    %edi,%eax
f0101f71:	e8 f9 eb ff ff       	call   f0100b6f <check_va2pa>
f0101f76:	89 c1                	mov    %eax,%ecx
f0101f78:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f7b:	89 d8                	mov    %ebx,%eax
f0101f7d:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0101f83:	c1 f8 03             	sar    $0x3,%eax
f0101f86:	c1 e0 0c             	shl    $0xc,%eax
f0101f89:	39 c1                	cmp    %eax,%ecx
f0101f8b:	74 19                	je     f0101fa6 <mem_init+0xb54>
f0101f8d:	68 84 6a 10 f0       	push   $0xf0106a84
f0101f92:	68 87 6f 10 f0       	push   $0xf0106f87
f0101f97:	68 c3 05 00 00       	push   $0x5c3
f0101f9c:	68 61 6f 10 f0       	push   $0xf0106f61
f0101fa1:	e8 ee e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fa6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fab:	89 f8                	mov    %edi,%eax
f0101fad:	e8 bd eb ff ff       	call   f0100b6f <check_va2pa>
f0101fb2:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fb5:	74 19                	je     f0101fd0 <mem_init+0xb7e>
f0101fb7:	68 b0 6a 10 f0       	push   $0xf0106ab0
f0101fbc:	68 87 6f 10 f0       	push   $0xf0106f87
f0101fc1:	68 c4 05 00 00       	push   $0x5c4
f0101fc6:	68 61 6f 10 f0       	push   $0xf0106f61
f0101fcb:	e8 c4 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fd0:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fd5:	74 19                	je     f0101ff0 <mem_init+0xb9e>
f0101fd7:	68 b0 71 10 f0       	push   $0xf01071b0
f0101fdc:	68 87 6f 10 f0       	push   $0xf0106f87
f0101fe1:	68 c6 05 00 00       	push   $0x5c6
f0101fe6:	68 61 6f 10 f0       	push   $0xf0106f61
f0101feb:	e8 a4 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0101ff0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ff8:	74 19                	je     f0102013 <mem_init+0xbc1>
f0101ffa:	68 c1 71 10 f0       	push   $0xf01071c1
f0101fff:	68 87 6f 10 f0       	push   $0xf0106f87
f0102004:	68 c7 05 00 00       	push   $0x5c7
f0102009:	68 61 6f 10 f0       	push   $0xf0106f61
f010200e:	e8 81 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102013:	83 ec 0c             	sub    $0xc,%esp
f0102016:	6a 00                	push   $0x0
f0102018:	e8 54 ef ff ff       	call   f0100f71 <page_alloc>
f010201d:	83 c4 10             	add    $0x10,%esp
f0102020:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102023:	75 04                	jne    f0102029 <mem_init+0xbd7>
f0102025:	85 c0                	test   %eax,%eax
f0102027:	75 19                	jne    f0102042 <mem_init+0xbf0>
f0102029:	68 e0 6a 10 f0       	push   $0xf0106ae0
f010202e:	68 87 6f 10 f0       	push   $0xf0106f87
f0102033:	68 ca 05 00 00       	push   $0x5ca
f0102038:	68 61 6f 10 f0       	push   $0xf0106f61
f010203d:	e8 52 e0 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102042:	83 ec 08             	sub    $0x8,%esp
f0102045:	6a 00                	push   $0x0
f0102047:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010204d:	e8 c8 f2 ff ff       	call   f010131a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102052:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102058:	ba 00 00 00 00       	mov    $0x0,%edx
f010205d:	89 f8                	mov    %edi,%eax
f010205f:	e8 0b eb ff ff       	call   f0100b6f <check_va2pa>
f0102064:	83 c4 10             	add    $0x10,%esp
f0102067:	83 f8 ff             	cmp    $0xffffffff,%eax
f010206a:	74 19                	je     f0102085 <mem_init+0xc33>
f010206c:	68 04 6b 10 f0       	push   $0xf0106b04
f0102071:	68 87 6f 10 f0       	push   $0xf0106f87
f0102076:	68 ce 05 00 00       	push   $0x5ce
f010207b:	68 61 6f 10 f0       	push   $0xf0106f61
f0102080:	e8 0f e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102085:	ba 00 10 00 00       	mov    $0x1000,%edx
f010208a:	89 f8                	mov    %edi,%eax
f010208c:	e8 de ea ff ff       	call   f0100b6f <check_va2pa>
f0102091:	89 da                	mov    %ebx,%edx
f0102093:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f0102099:	c1 fa 03             	sar    $0x3,%edx
f010209c:	c1 e2 0c             	shl    $0xc,%edx
f010209f:	39 d0                	cmp    %edx,%eax
f01020a1:	74 19                	je     f01020bc <mem_init+0xc6a>
f01020a3:	68 b0 6a 10 f0       	push   $0xf0106ab0
f01020a8:	68 87 6f 10 f0       	push   $0xf0106f87
f01020ad:	68 cf 05 00 00       	push   $0x5cf
f01020b2:	68 61 6f 10 f0       	push   $0xf0106f61
f01020b7:	e8 d8 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01020bc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020c1:	74 19                	je     f01020dc <mem_init+0xc8a>
f01020c3:	68 67 71 10 f0       	push   $0xf0107167
f01020c8:	68 87 6f 10 f0       	push   $0xf0106f87
f01020cd:	68 d0 05 00 00       	push   $0x5d0
f01020d2:	68 61 6f 10 f0       	push   $0xf0106f61
f01020d7:	e8 b8 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01020dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020df:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01020e4:	74 19                	je     f01020ff <mem_init+0xcad>
f01020e6:	68 c1 71 10 f0       	push   $0xf01071c1
f01020eb:	68 87 6f 10 f0       	push   $0xf0106f87
f01020f0:	68 d1 05 00 00       	push   $0x5d1
f01020f5:	68 61 6f 10 f0       	push   $0xf0106f61
f01020fa:	e8 95 df ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020ff:	6a 00                	push   $0x0
f0102101:	68 00 10 00 00       	push   $0x1000
f0102106:	53                   	push   %ebx
f0102107:	57                   	push   %edi
f0102108:	e8 53 f2 ff ff       	call   f0101360 <page_insert>
f010210d:	83 c4 10             	add    $0x10,%esp
f0102110:	85 c0                	test   %eax,%eax
f0102112:	74 19                	je     f010212d <mem_init+0xcdb>
f0102114:	68 28 6b 10 f0       	push   $0xf0106b28
f0102119:	68 87 6f 10 f0       	push   $0xf0106f87
f010211e:	68 d4 05 00 00       	push   $0x5d4
f0102123:	68 61 6f 10 f0       	push   $0xf0106f61
f0102128:	e8 67 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010212d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102132:	75 19                	jne    f010214d <mem_init+0xcfb>
f0102134:	68 d2 71 10 f0       	push   $0xf01071d2
f0102139:	68 87 6f 10 f0       	push   $0xf0106f87
f010213e:	68 d5 05 00 00       	push   $0x5d5
f0102143:	68 61 6f 10 f0       	push   $0xf0106f61
f0102148:	e8 47 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010214d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102150:	74 19                	je     f010216b <mem_init+0xd19>
f0102152:	68 de 71 10 f0       	push   $0xf01071de
f0102157:	68 87 6f 10 f0       	push   $0xf0106f87
f010215c:	68 d6 05 00 00       	push   $0x5d6
f0102161:	68 61 6f 10 f0       	push   $0xf0106f61
f0102166:	e8 29 df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010216b:	83 ec 08             	sub    $0x8,%esp
f010216e:	68 00 10 00 00       	push   $0x1000
f0102173:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102179:	e8 9c f1 ff ff       	call   f010131a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010217e:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102184:	ba 00 00 00 00       	mov    $0x0,%edx
f0102189:	89 f8                	mov    %edi,%eax
f010218b:	e8 df e9 ff ff       	call   f0100b6f <check_va2pa>
f0102190:	83 c4 10             	add    $0x10,%esp
f0102193:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102196:	74 19                	je     f01021b1 <mem_init+0xd5f>
f0102198:	68 04 6b 10 f0       	push   $0xf0106b04
f010219d:	68 87 6f 10 f0       	push   $0xf0106f87
f01021a2:	68 da 05 00 00       	push   $0x5da
f01021a7:	68 61 6f 10 f0       	push   $0xf0106f61
f01021ac:	e8 e3 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021b1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021b6:	89 f8                	mov    %edi,%eax
f01021b8:	e8 b2 e9 ff ff       	call   f0100b6f <check_va2pa>
f01021bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021c0:	74 19                	je     f01021db <mem_init+0xd89>
f01021c2:	68 60 6b 10 f0       	push   $0xf0106b60
f01021c7:	68 87 6f 10 f0       	push   $0xf0106f87
f01021cc:	68 db 05 00 00       	push   $0x5db
f01021d1:	68 61 6f 10 f0       	push   $0xf0106f61
f01021d6:	e8 b9 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01021db:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021e0:	74 19                	je     f01021fb <mem_init+0xda9>
f01021e2:	68 f3 71 10 f0       	push   $0xf01071f3
f01021e7:	68 87 6f 10 f0       	push   $0xf0106f87
f01021ec:	68 dc 05 00 00       	push   $0x5dc
f01021f1:	68 61 6f 10 f0       	push   $0xf0106f61
f01021f6:	e8 99 de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01021fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021fe:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102203:	74 19                	je     f010221e <mem_init+0xdcc>
f0102205:	68 c1 71 10 f0       	push   $0xf01071c1
f010220a:	68 87 6f 10 f0       	push   $0xf0106f87
f010220f:	68 dd 05 00 00       	push   $0x5dd
f0102214:	68 61 6f 10 f0       	push   $0xf0106f61
f0102219:	e8 76 de ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010221e:	83 ec 0c             	sub    $0xc,%esp
f0102221:	6a 00                	push   $0x0
f0102223:	e8 49 ed ff ff       	call   f0100f71 <page_alloc>
f0102228:	83 c4 10             	add    $0x10,%esp
f010222b:	85 c0                	test   %eax,%eax
f010222d:	74 04                	je     f0102233 <mem_init+0xde1>
f010222f:	39 c3                	cmp    %eax,%ebx
f0102231:	74 19                	je     f010224c <mem_init+0xdfa>
f0102233:	68 88 6b 10 f0       	push   $0xf0106b88
f0102238:	68 87 6f 10 f0       	push   $0xf0106f87
f010223d:	68 e0 05 00 00       	push   $0x5e0
f0102242:	68 61 6f 10 f0       	push   $0xf0106f61
f0102247:	e8 48 de ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010224c:	83 ec 0c             	sub    $0xc,%esp
f010224f:	6a 00                	push   $0x0
f0102251:	e8 1b ed ff ff       	call   f0100f71 <page_alloc>
f0102256:	83 c4 10             	add    $0x10,%esp
f0102259:	85 c0                	test   %eax,%eax
f010225b:	74 19                	je     f0102276 <mem_init+0xe24>
f010225d:	68 15 71 10 f0       	push   $0xf0107115
f0102262:	68 87 6f 10 f0       	push   $0xf0106f87
f0102267:	68 e3 05 00 00       	push   $0x5e3
f010226c:	68 61 6f 10 f0       	push   $0xf0106f61
f0102271:	e8 1e de ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102276:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f010227c:	8b 11                	mov    (%ecx),%edx
f010227e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102284:	89 f0                	mov    %esi,%eax
f0102286:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010228c:	c1 f8 03             	sar    $0x3,%eax
f010228f:	c1 e0 0c             	shl    $0xc,%eax
f0102292:	39 c2                	cmp    %eax,%edx
f0102294:	74 19                	je     f01022af <mem_init+0xe5d>
f0102296:	68 2c 68 10 f0       	push   $0xf010682c
f010229b:	68 87 6f 10 f0       	push   $0xf0106f87
f01022a0:	68 e6 05 00 00       	push   $0x5e6
f01022a5:	68 61 6f 10 f0       	push   $0xf0106f61
f01022aa:	e8 e5 dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01022af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022b5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022ba:	74 19                	je     f01022d5 <mem_init+0xe83>
f01022bc:	68 78 71 10 f0       	push   $0xf0107178
f01022c1:	68 87 6f 10 f0       	push   $0xf0106f87
f01022c6:	68 e8 05 00 00       	push   $0x5e8
f01022cb:	68 61 6f 10 f0       	push   $0xf0106f61
f01022d0:	e8 bf dd ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01022d5:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022db:	83 ec 0c             	sub    $0xc,%esp
f01022de:	56                   	push   %esi
f01022df:	e8 46 ed ff ff       	call   f010102a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022e4:	83 c4 0c             	add    $0xc,%esp
f01022e7:	6a 01                	push   $0x1
f01022e9:	68 00 10 40 00       	push   $0x401000
f01022ee:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f01022f4:	e8 12 ee ff ff       	call   f010110b <pgdir_walk>
f01022f9:	89 c7                	mov    %eax,%edi
f01022fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022fe:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102303:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102306:	8b 40 04             	mov    0x4(%eax),%eax
f0102309:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010230e:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0102314:	89 c2                	mov    %eax,%edx
f0102316:	c1 ea 0c             	shr    $0xc,%edx
f0102319:	83 c4 10             	add    $0x10,%esp
f010231c:	39 ca                	cmp    %ecx,%edx
f010231e:	72 15                	jb     f0102335 <mem_init+0xee3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102320:	50                   	push   %eax
f0102321:	68 14 60 10 f0       	push   $0xf0106014
f0102326:	68 ef 05 00 00       	push   $0x5ef
f010232b:	68 61 6f 10 f0       	push   $0xf0106f61
f0102330:	e8 5f dd ff ff       	call   f0100094 <_panic>
	
//now we fault at ptep == ptep1+PTX(va)
//cprintf("ptep:%x , PTX(va):%x,va:%x,ptep1:%x\n",ptep,PTX(va),va,ptep1);

	assert(ptep == ptep1 + PTX(va));
f0102335:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010233a:	39 c7                	cmp    %eax,%edi
f010233c:	74 19                	je     f0102357 <mem_init+0xf05>
f010233e:	68 04 72 10 f0       	push   $0xf0107204
f0102343:	68 87 6f 10 f0       	push   $0xf0106f87
f0102348:	68 f4 05 00 00       	push   $0x5f4
f010234d:	68 61 6f 10 f0       	push   $0xf0106f61
f0102352:	e8 3d dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102357:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010235a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102361:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102367:	89 f0                	mov    %esi,%eax
f0102369:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f010236f:	c1 f8 03             	sar    $0x3,%eax
f0102372:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102375:	89 c2                	mov    %eax,%edx
f0102377:	c1 ea 0c             	shr    $0xc,%edx
f010237a:	39 d1                	cmp    %edx,%ecx
f010237c:	77 12                	ja     f0102390 <mem_init+0xf3e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010237e:	50                   	push   %eax
f010237f:	68 14 60 10 f0       	push   $0xf0106014
f0102384:	6a 58                	push   $0x58
f0102386:	68 6d 6f 10 f0       	push   $0xf0106f6d
f010238b:	e8 04 dd ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102390:	83 ec 04             	sub    $0x4,%esp
f0102393:	68 00 10 00 00       	push   $0x1000
f0102398:	68 ff 00 00 00       	push   $0xff
f010239d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023a2:	50                   	push   %eax
f01023a3:	e8 fb 2e 00 00       	call   f01052a3 <memset>
	page_free(pp0);
f01023a8:	89 34 24             	mov    %esi,(%esp)
f01023ab:	e8 7a ec ff ff       	call   f010102a <page_free>


//here below is my commit,so if we set all pp0(the page table entry)
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023b0:	83 c4 0c             	add    $0xc,%esp
f01023b3:	6a 01                	push   $0x1
f01023b5:	6a 00                	push   $0x0
f01023b7:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f01023bd:	e8 49 ed ff ff       	call   f010110b <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023c2:	89 f2                	mov    %esi,%edx
f01023c4:	2b 15 90 be 22 f0    	sub    0xf022be90,%edx
f01023ca:	c1 fa 03             	sar    $0x3,%edx
f01023cd:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d0:	89 d0                	mov    %edx,%eax
f01023d2:	c1 e8 0c             	shr    $0xc,%eax
f01023d5:	83 c4 10             	add    $0x10,%esp
f01023d8:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01023de:	72 12                	jb     f01023f2 <mem_init+0xfa0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e0:	52                   	push   %edx
f01023e1:	68 14 60 10 f0       	push   $0xf0106014
f01023e6:	6a 58                	push   $0x58
f01023e8:	68 6d 6f 10 f0       	push   $0xf0106f6d
f01023ed:	e8 a2 dc ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01023f2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023fb:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	
	for(i=0; i<NPTENTRIES; i++){
		//:/cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
		assert((ptep[i] & PTE_P) == 0);
f0102401:	f6 00 01             	testb  $0x1,(%eax)
f0102404:	74 19                	je     f010241f <mem_init+0xfcd>
f0102406:	68 1c 72 10 f0       	push   $0xf010721c
f010240b:	68 87 6f 10 f0       	push   $0xf0106f87
f0102410:	68 08 06 00 00       	push   $0x608
f0102415:	68 61 6f 10 f0       	push   $0xf0106f61
f010241a:	e8 75 dc ff ff       	call   f0100094 <_panic>
f010241f:	83 c0 04             	add    $0x4,%eax
//to 0 all maps will be invalid.so then what we should do release all
//the pages?(free them.)
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	
	for(i=0; i<NPTENTRIES; i++){
f0102422:	39 d0                	cmp    %edx,%eax
f0102424:	75 db                	jne    f0102401 <mem_init+0xfaf>
		assert((ptep[i] & PTE_P) == 0);
	}
//here is the error again.
//	for(i = 0;i<NPTENTRIES;i++)
//		cprintf("### error 1. ptep[i]:%x PTE_P:%x\n",ptep[i],PTE_P);
	kern_pgdir[0] = 0;
f0102426:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f010242b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102431:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102437:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010243a:	a3 40 b2 22 f0       	mov    %eax,0xf022b240

	// free the pages we took
	page_free(pp0);
f010243f:	83 ec 0c             	sub    $0xc,%esp
f0102442:	56                   	push   %esi
f0102443:	e8 e2 eb ff ff       	call   f010102a <page_free>
	page_free(pp1);
f0102448:	89 1c 24             	mov    %ebx,(%esp)
f010244b:	e8 da eb ff ff       	call   f010102a <page_free>
	page_free(pp2);
f0102450:	83 c4 04             	add    $0x4,%esp
f0102453:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102456:	e8 cf eb ff ff       	call   f010102a <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010245b:	83 c4 08             	add    $0x8,%esp
f010245e:	68 01 10 00 00       	push   $0x1001
f0102463:	6a 00                	push   $0x0
f0102465:	e8 82 ef ff ff       	call   f01013ec <mmio_map_region>
f010246a:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010246c:	83 c4 08             	add    $0x8,%esp
f010246f:	68 00 10 00 00       	push   $0x1000
f0102474:	6a 00                	push   $0x0
f0102476:	e8 71 ef ff ff       	call   f01013ec <mmio_map_region>
f010247b:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010247d:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102483:	83 c4 10             	add    $0x10,%esp
f0102486:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010248c:	76 07                	jbe    f0102495 <mem_init+0x1043>
f010248e:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102493:	76 19                	jbe    f01024ae <mem_init+0x105c>
f0102495:	68 ac 6b 10 f0       	push   $0xf0106bac
f010249a:	68 87 6f 10 f0       	push   $0xf0106f87
f010249f:	68 1c 06 00 00       	push   $0x61c
f01024a4:	68 61 6f 10 f0       	push   $0xf0106f61
f01024a9:	e8 e6 db ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01024ae:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024b4:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024ba:	77 08                	ja     f01024c4 <mem_init+0x1072>
f01024bc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024c2:	77 19                	ja     f01024dd <mem_init+0x108b>
f01024c4:	68 d4 6b 10 f0       	push   $0xf0106bd4
f01024c9:	68 87 6f 10 f0       	push   $0xf0106f87
f01024ce:	68 1d 06 00 00       	push   $0x61d
f01024d3:	68 61 6f 10 f0       	push   $0xf0106f61
f01024d8:	e8 b7 db ff ff       	call   f0100094 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024dd:	89 da                	mov    %ebx,%edx
f01024df:	09 f2                	or     %esi,%edx
f01024e1:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024e7:	74 19                	je     f0102502 <mem_init+0x10b0>
f01024e9:	68 fc 6b 10 f0       	push   $0xf0106bfc
f01024ee:	68 87 6f 10 f0       	push   $0xf0106f87
f01024f3:	68 1f 06 00 00       	push   $0x61f
f01024f8:	68 61 6f 10 f0       	push   $0xf0106f61
f01024fd:	e8 92 db ff ff       	call   f0100094 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102502:	39 c6                	cmp    %eax,%esi
f0102504:	73 19                	jae    f010251f <mem_init+0x10cd>
f0102506:	68 33 72 10 f0       	push   $0xf0107233
f010250b:	68 87 6f 10 f0       	push   $0xf0106f87
f0102510:	68 21 06 00 00       	push   $0x621
f0102515:	68 61 6f 10 f0       	push   $0xf0106f61
f010251a:	e8 75 db ff ff       	call   f0100094 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010251f:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102525:	89 da                	mov    %ebx,%edx
f0102527:	89 f8                	mov    %edi,%eax
f0102529:	e8 41 e6 ff ff       	call   f0100b6f <check_va2pa>
f010252e:	85 c0                	test   %eax,%eax
f0102530:	74 19                	je     f010254b <mem_init+0x10f9>
f0102532:	68 24 6c 10 f0       	push   $0xf0106c24
f0102537:	68 87 6f 10 f0       	push   $0xf0106f87
f010253c:	68 23 06 00 00       	push   $0x623
f0102541:	68 61 6f 10 f0       	push   $0xf0106f61
f0102546:	e8 49 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010254b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102551:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102554:	89 c2                	mov    %eax,%edx
f0102556:	89 f8                	mov    %edi,%eax
f0102558:	e8 12 e6 ff ff       	call   f0100b6f <check_va2pa>
f010255d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102562:	74 19                	je     f010257d <mem_init+0x112b>
f0102564:	68 48 6c 10 f0       	push   $0xf0106c48
f0102569:	68 87 6f 10 f0       	push   $0xf0106f87
f010256e:	68 24 06 00 00       	push   $0x624
f0102573:	68 61 6f 10 f0       	push   $0xf0106f61
f0102578:	e8 17 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010257d:	89 f2                	mov    %esi,%edx
f010257f:	89 f8                	mov    %edi,%eax
f0102581:	e8 e9 e5 ff ff       	call   f0100b6f <check_va2pa>
f0102586:	85 c0                	test   %eax,%eax
f0102588:	74 19                	je     f01025a3 <mem_init+0x1151>
f010258a:	68 78 6c 10 f0       	push   $0xf0106c78
f010258f:	68 87 6f 10 f0       	push   $0xf0106f87
f0102594:	68 25 06 00 00       	push   $0x625
f0102599:	68 61 6f 10 f0       	push   $0xf0106f61
f010259e:	e8 f1 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025a3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01025a9:	89 f8                	mov    %edi,%eax
f01025ab:	e8 bf e5 ff ff       	call   f0100b6f <check_va2pa>
f01025b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025b3:	74 19                	je     f01025ce <mem_init+0x117c>
f01025b5:	68 9c 6c 10 f0       	push   $0xf0106c9c
f01025ba:	68 87 6f 10 f0       	push   $0xf0106f87
f01025bf:	68 26 06 00 00       	push   $0x626
f01025c4:	68 61 6f 10 f0       	push   $0xf0106f61
f01025c9:	e8 c6 da ff ff       	call   f0100094 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01025ce:	83 ec 04             	sub    $0x4,%esp
f01025d1:	6a 00                	push   $0x0
f01025d3:	53                   	push   %ebx
f01025d4:	57                   	push   %edi
f01025d5:	e8 31 eb ff ff       	call   f010110b <pgdir_walk>
f01025da:	83 c4 10             	add    $0x10,%esp
f01025dd:	f6 00 1a             	testb  $0x1a,(%eax)
f01025e0:	75 19                	jne    f01025fb <mem_init+0x11a9>
f01025e2:	68 c8 6c 10 f0       	push   $0xf0106cc8
f01025e7:	68 87 6f 10 f0       	push   $0xf0106f87
f01025ec:	68 28 06 00 00       	push   $0x628
f01025f1:	68 61 6f 10 f0       	push   $0xf0106f61
f01025f6:	e8 99 da ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01025fb:	83 ec 04             	sub    $0x4,%esp
f01025fe:	6a 00                	push   $0x0
f0102600:	53                   	push   %ebx
f0102601:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102607:	e8 ff ea ff ff       	call   f010110b <pgdir_walk>
f010260c:	8b 00                	mov    (%eax),%eax
f010260e:	83 c4 10             	add    $0x10,%esp
f0102611:	83 e0 04             	and    $0x4,%eax
f0102614:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102617:	74 19                	je     f0102632 <mem_init+0x11e0>
f0102619:	68 0c 6d 10 f0       	push   $0xf0106d0c
f010261e:	68 87 6f 10 f0       	push   $0xf0106f87
f0102623:	68 29 06 00 00       	push   $0x629
f0102628:	68 61 6f 10 f0       	push   $0xf0106f61
f010262d:	e8 62 da ff ff       	call   f0100094 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102632:	83 ec 04             	sub    $0x4,%esp
f0102635:	6a 00                	push   $0x0
f0102637:	53                   	push   %ebx
f0102638:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010263e:	e8 c8 ea ff ff       	call   f010110b <pgdir_walk>
f0102643:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102649:	83 c4 0c             	add    $0xc,%esp
f010264c:	6a 00                	push   $0x0
f010264e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102651:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102657:	e8 af ea ff ff       	call   f010110b <pgdir_walk>
f010265c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102662:	83 c4 0c             	add    $0xc,%esp
f0102665:	6a 00                	push   $0x0
f0102667:	56                   	push   %esi
f0102668:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010266e:	e8 98 ea ff ff       	call   f010110b <pgdir_walk>
f0102673:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102679:	c7 04 24 45 72 10 f0 	movl   $0xf0107245,(%esp)
f0102680:	e8 f9 11 00 00       	call   f010387e <cprintf>
	//I know the meaning of some special 'entry'  and I know the perm is 
	//set to which entry.
	//it is just 4MB to hold the pages so it is perfect we just need
	//one page table,insert to the kern_pgdir.
//here is the new version,npages*4 because one page address occupy 4B?
	boot_map_region(kern_pgdir,UPAGES,0x400000,PADDR(pages),PTE_U|PTE_P|PTE_W);
f0102685:	a1 90 be 22 f0       	mov    0xf022be90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010268a:	83 c4 10             	add    $0x10,%esp
f010268d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102692:	77 15                	ja     f01026a9 <mem_init+0x1257>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102694:	50                   	push   %eax
f0102695:	68 38 60 10 f0       	push   $0xf0106038
f010269a:	68 06 01 00 00       	push   $0x106
f010269f:	68 61 6f 10 f0       	push   $0xf0106f61
f01026a4:	e8 eb d9 ff ff       	call   f0100094 <_panic>
f01026a9:	83 ec 08             	sub    $0x8,%esp
f01026ac:	6a 07                	push   $0x7
f01026ae:	05 00 00 00 10       	add    $0x10000000,%eax
f01026b3:	50                   	push   %eax
f01026b4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01026b9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01026be:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01026c3:	e8 1c eb ff ff       	call   f01011e4 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Pemissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,NENV*sizeof(struct Env),PADDR(envs),PTE_P|PTE_W|PTE_A|PTE_U);
f01026c8:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026cd:	83 c4 10             	add    $0x10,%esp
f01026d0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d5:	77 15                	ja     f01026ec <mem_init+0x129a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d7:	50                   	push   %eax
f01026d8:	68 38 60 10 f0       	push   $0xf0106038
f01026dd:	68 12 01 00 00       	push   $0x112
f01026e2:	68 61 6f 10 f0       	push   $0xf0106f61
f01026e7:	e8 a8 d9 ff ff       	call   f0100094 <_panic>
f01026ec:	83 ec 08             	sub    $0x8,%esp
f01026ef:	6a 27                	push   $0x27
f01026f1:	05 00 00 00 10       	add    $0x10000000,%eax
f01026f6:	50                   	push   %eax
f01026f7:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01026fc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102701:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102706:	e8 d9 ea ff ff       	call   f01011e4 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270b:	83 c4 10             	add    $0x10,%esp
f010270e:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f0102713:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102718:	77 15                	ja     f010272f <mem_init+0x12dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010271a:	50                   	push   %eax
f010271b:	68 38 60 10 f0       	push   $0xf0106038
f0102720:	68 27 01 00 00       	push   $0x127
f0102725:	68 61 6f 10 f0       	push   $0xf0106f61
f010272a:	e8 65 d9 ff ff       	call   f0100094 <_panic>
	//the second seg is 4M-32K size as the guard page.
	//[KSTACKTOP-KSTKSIZE,KSTACKTOP)is mapped in physical address
	//[KSTACKOP-PTSIZE,KSTACKTOP-KSTKSIZE)is not mapped by physical mem
	//so it will cause fault if we access it.(which is the 'back' means)

	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
f010272f:	83 ec 08             	sub    $0x8,%esp
f0102732:	6a 22                	push   $0x22
f0102734:	68 00 60 11 00       	push   $0x116000
f0102739:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010273e:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102743:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0102748:	e8 97 ea ff ff       	call   f01011e4 <boot_map_region>
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
f010274d:	83 c4 08             	add    $0x8,%esp
f0102750:	6a 08                	push   $0x8
f0102752:	68 5e 72 10 f0       	push   $0xf010725e
f0102757:	e8 22 11 00 00       	call   f010387e <cprintf>
f010275c:	c7 45 c4 00 d0 22 f0 	movl   $0xf022d000,-0x3c(%ebp)
f0102763:	83 c4 10             	add    $0x10,%esp
f0102766:	bb 00 d0 22 f0       	mov    $0xf022d000,%ebx
f010276b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102770:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102776:	77 15                	ja     f010278d <mem_init+0x133b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102778:	53                   	push   %ebx
f0102779:	68 38 60 10 f0       	push   $0xf0106038
f010277e:	68 6e 01 00 00       	push   $0x16e
f0102783:	68 61 6f 10 f0       	push   $0xf0106f61
f0102788:	e8 07 d9 ff ff       	call   f0100094 <_panic>
	for(int i = 0;i<NCPU;i++){
		uintptr_t kstacktop_i = KSTACKTOP-(i)*(KSTKSIZE+KSTKGAP);	
		boot_map_region(kern_pgdir,kstacktop_i-KSTKSIZE,KSTKSIZE,PADDR(&percpu_kstacks[i]),PTE_P|PTE_W);
f010278d:	83 ec 08             	sub    $0x8,%esp
f0102790:	6a 03                	push   $0x3
f0102792:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102798:	50                   	push   %eax
f0102799:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010279e:	89 f2                	mov    %esi,%edx
f01027a0:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027a5:	e8 3a ea ff ff       	call   f01011e4 <boot_map_region>
f01027aa:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01027b0:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	//boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W|PTE_A);
	cprintf("ncpu:%d\n",NCPU);
	for(int i = 0;i<NCPU;i++){
f01027b6:	83 c4 10             	add    $0x10,%esp
f01027b9:	b8 00 d0 26 f0       	mov    $0xf026d000,%eax
f01027be:	39 d8                	cmp    %ebx,%eax
f01027c0:	75 ae                	jne    f0102770 <mem_init+0x131e>

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	
	boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W|PTE_A);	
f01027c2:	83 ec 08             	sub    $0x8,%esp
f01027c5:	6a 22                	push   $0x22
f01027c7:	6a 00                	push   $0x0
f01027c9:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01027ce:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027d3:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f01027d8:	e8 07 ea ff ff       	call   f01011e4 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01027dd:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01027e3:	a1 88 be 22 f0       	mov    0xf022be88,%eax
f01027e8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027eb:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01027f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01027f7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE){

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01027fa:	8b 35 90 be 22 f0    	mov    0xf022be90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102800:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102803:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f0102806:	bb 00 00 00 00       	mov    $0x0,%ebx
f010280b:	eb 55                	jmp    f0102862 <mem_init+0x1410>

		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010280d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102813:	89 f8                	mov    %edi,%eax
f0102815:	e8 55 e3 ff ff       	call   f0100b6f <check_va2pa>
f010281a:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102821:	77 15                	ja     f0102838 <mem_init+0x13e6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102823:	56                   	push   %esi
f0102824:	68 38 60 10 f0       	push   $0xf0106038
f0102829:	68 fa 04 00 00       	push   $0x4fa
f010282e:	68 61 6f 10 f0       	push   $0xf0106f61
f0102833:	e8 5c d8 ff ff       	call   f0100094 <_panic>
f0102838:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010283f:	39 c2                	cmp    %eax,%edx
f0102841:	74 19                	je     f010285c <mem_init+0x140a>
f0102843:	68 40 6d 10 f0       	push   $0xf0106d40
f0102848:	68 87 6f 10 f0       	push   $0xf0106f87
f010284d:	68 fa 04 00 00       	push   $0x4fa
f0102852:	68 61 6f 10 f0       	push   $0xf0106f61
f0102857:	e8 38 d8 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f010285c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102862:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102865:	77 a6                	ja     f010280d <mem_init+0x13bb>

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102867:	8b 35 44 b2 22 f0    	mov    0xf022b244,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010286d:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102870:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102875:	89 da                	mov    %ebx,%edx
f0102877:	89 f8                	mov    %edi,%eax
f0102879:	e8 f1 e2 ff ff       	call   f0100b6f <check_va2pa>
f010287e:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102885:	77 15                	ja     f010289c <mem_init+0x144a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102887:	56                   	push   %esi
f0102888:	68 38 60 10 f0       	push   $0xf0106038
f010288d:	68 00 05 00 00       	push   $0x500
f0102892:	68 61 6f 10 f0       	push   $0xf0106f61
f0102897:	e8 f8 d7 ff ff       	call   f0100094 <_panic>
f010289c:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01028a3:	39 d0                	cmp    %edx,%eax
f01028a5:	74 19                	je     f01028c0 <mem_init+0x146e>
f01028a7:	68 74 6d 10 f0       	push   $0xf0106d74
f01028ac:	68 87 6f 10 f0       	push   $0xf0106f87
f01028b1:	68 00 05 00 00       	push   $0x500
f01028b6:	68 61 6f 10 f0       	push   $0xf0106f61
f01028bb:	e8 d4 d7 ff ff       	call   f0100094 <_panic>
f01028c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	}
	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE){
f01028c6:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01028cc:	75 a7                	jne    f0102875 <mem_init+0x1423>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f01028ce:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01028d1:	c1 e6 0c             	shl    $0xc,%esi
f01028d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028d9:	eb 30                	jmp    f010290b <mem_init+0x14b9>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01028db:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01028e1:	89 f8                	mov    %edi,%eax
f01028e3:	e8 87 e2 ff ff       	call   f0100b6f <check_va2pa>
f01028e8:	39 c3                	cmp    %eax,%ebx
f01028ea:	74 19                	je     f0102905 <mem_init+0x14b3>
f01028ec:	68 a8 6d 10 f0       	push   $0xf0106da8
f01028f1:	68 87 6f 10 f0       	push   $0xf0106f87
f01028f6:	68 06 05 00 00       	push   $0x506
f01028fb:	68 61 6f 10 f0       	push   $0xf0106f61
f0102900:	e8 8f d7 ff ff       	call   f0100094 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);


	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE){
f0102905:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010290b:	39 f3                	cmp    %esi,%ebx
f010290d:	72 cc                	jb     f01028db <mem_init+0x1489>
f010290f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102914:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102917:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010291a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010291d:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102923:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102926:	89 c3                	mov    %eax,%ebx
	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102928:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010292b:	05 00 80 00 20       	add    $0x20008000,%eax
f0102930:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102933:	89 da                	mov    %ebx,%edx
f0102935:	89 f8                	mov    %edi,%eax
f0102937:	e8 33 e2 ff ff       	call   f0100b6f <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010293c:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102942:	77 15                	ja     f0102959 <mem_init+0x1507>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102944:	56                   	push   %esi
f0102945:	68 38 60 10 f0       	push   $0xf0106038
f010294a:	68 11 05 00 00       	push   $0x511
f010294f:	68 61 6f 10 f0       	push   $0xf0106f61
f0102954:	e8 3b d7 ff ff       	call   f0100094 <_panic>
f0102959:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010295c:	8d 94 0b 00 d0 22 f0 	lea    -0xfdd3000(%ebx,%ecx,1),%edx
f0102963:	39 d0                	cmp    %edx,%eax
f0102965:	74 19                	je     f0102980 <mem_init+0x152e>
f0102967:	68 d0 6d 10 f0       	push   $0xf0106dd0
f010296c:	68 87 6f 10 f0       	push   $0xf0106f87
f0102971:	68 11 05 00 00       	push   $0x511
f0102976:	68 61 6f 10 f0       	push   $0xf0106f61
f010297b:	e8 14 d7 ff ff       	call   f0100094 <_panic>
f0102980:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102986:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102989:	75 a8                	jne    f0102933 <mem_init+0x14e1>
f010298b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010298e:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102994:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102997:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102999:	89 da                	mov    %ebx,%edx
f010299b:	89 f8                	mov    %edi,%eax
f010299d:	e8 cd e1 ff ff       	call   f0100b6f <check_va2pa>
f01029a2:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a5:	74 19                	je     f01029c0 <mem_init+0x156e>
f01029a7:	68 18 6e 10 f0       	push   $0xf0106e18
f01029ac:	68 87 6f 10 f0       	push   $0xf0106f87
f01029b1:	68 13 05 00 00       	push   $0x513
f01029b6:	68 61 6f 10 f0       	push   $0xf0106f61
f01029bb:	e8 d4 d6 ff ff       	call   f0100094 <_panic>
f01029c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029c6:	39 f3                	cmp    %esi,%ebx
f01029c8:	75 cf                	jne    f0102999 <mem_init+0x1547>
f01029ca:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01029cd:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01029d4:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01029db:	81 c6 00 80 00 00    	add    $0x8000,%esi

	// check kernel stack

	// (updated in lab 4 to check per-CPU kernel stacks)

	for (n = 0; n < NCPU; n++) {
f01029e1:	b8 00 d0 26 f0       	mov    $0xf026d000,%eax
f01029e6:	39 f0                	cmp    %esi,%eax
f01029e8:	0f 85 2c ff ff ff    	jne    f010291a <mem_init+0x14c8>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029ee:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01029f3:	89 f8                	mov    %edi,%eax
f01029f5:	e8 75 e1 ff ff       	call   f0100b6f <check_va2pa>
f01029fa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029fd:	74 47                	je     f0102a46 <mem_init+0x15f4>
f01029ff:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0102a04:	68 87 6f 10 f0       	push   $0xf0106f87
f0102a09:	68 1d 05 00 00       	push   $0x51d
f0102a0e:	68 61 6f 10 f0       	push   $0xf0106f61
f0102a13:	e8 7c d6 ff ff       	call   f0100094 <_panic>


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a18:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a1e:	83 fa 04             	cmp    $0x4,%edx
f0102a21:	77 28                	ja     f0102a4b <mem_init+0x15f9>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102a23:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a27:	0f 85 83 00 00 00    	jne    f0102ab0 <mem_init+0x165e>
f0102a2d:	68 67 72 10 f0       	push   $0xf0107267
f0102a32:	68 87 6f 10 f0       	push   $0xf0106f87
f0102a37:	68 28 05 00 00       	push   $0x528
f0102a3c:	68 61 6f 10 f0       	push   $0xf0106f61
f0102a41:	e8 4e d6 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE){
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);

	}
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a46:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a4b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a50:	76 3f                	jbe    f0102a91 <mem_init+0x163f>
				assert(pgdir[i] & PTE_P);
f0102a52:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102a55:	f6 c2 01             	test   $0x1,%dl
f0102a58:	75 19                	jne    f0102a73 <mem_init+0x1621>
f0102a5a:	68 67 72 10 f0       	push   $0xf0107267
f0102a5f:	68 87 6f 10 f0       	push   $0xf0106f87
f0102a64:	68 2c 05 00 00       	push   $0x52c
f0102a69:	68 61 6f 10 f0       	push   $0xf0106f61
f0102a6e:	e8 21 d6 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a73:	f6 c2 02             	test   $0x2,%dl
f0102a76:	75 38                	jne    f0102ab0 <mem_init+0x165e>
f0102a78:	68 78 72 10 f0       	push   $0xf0107278
f0102a7d:	68 87 6f 10 f0       	push   $0xf0106f87
f0102a82:	68 2d 05 00 00       	push   $0x52d
f0102a87:	68 61 6f 10 f0       	push   $0xf0106f61
f0102a8c:	e8 03 d6 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a91:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a95:	74 19                	je     f0102ab0 <mem_init+0x165e>
f0102a97:	68 89 72 10 f0       	push   $0xf0107289
f0102a9c:	68 87 6f 10 f0       	push   $0xf0106f87
f0102aa1:	68 2f 05 00 00       	push   $0x52f
f0102aa6:	68 61 6f 10 f0       	push   $0xf0106f61
f0102aab:	e8 e4 d5 ff ff       	call   f0100094 <_panic>
*/
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);


	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102ab0:	83 c0 01             	add    $0x1,%eax
f0102ab3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102ab8:	0f 86 5a ff ff ff    	jbe    f0102a18 <mem_init+0x15c6>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102abe:	83 ec 0c             	sub    $0xc,%esp
f0102ac1:	68 6c 6e 10 f0       	push   $0xf0106e6c
f0102ac6:	e8 b3 0d 00 00       	call   f010387e <cprintf>
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.

	lcr3(PADDR(kern_pgdir));
f0102acb:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ad0:	83 c4 10             	add    $0x10,%esp
f0102ad3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ad8:	77 15                	ja     f0102aef <mem_init+0x169d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ada:	50                   	push   %eax
f0102adb:	68 38 60 10 f0       	push   $0xf0106038
f0102ae0:	68 43 01 00 00       	push   $0x143
f0102ae5:	68 61 6f 10 f0       	push   $0xf0106f61
f0102aea:	e8 a5 d5 ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102aef:	05 00 00 00 10       	add    $0x10000000,%eax
f0102af4:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102af7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102afc:	e8 d2 e0 ff ff       	call   f0100bd3 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b01:	0f 20 c0             	mov    %cr0,%eax
f0102b04:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b07:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b0c:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b0f:	83 ec 0c             	sub    $0xc,%esp
f0102b12:	6a 00                	push   $0x0
f0102b14:	e8 58 e4 ff ff       	call   f0100f71 <page_alloc>
f0102b19:	89 c3                	mov    %eax,%ebx
f0102b1b:	83 c4 10             	add    $0x10,%esp
f0102b1e:	85 c0                	test   %eax,%eax
f0102b20:	75 19                	jne    f0102b3b <mem_init+0x16e9>
f0102b22:	68 6a 70 10 f0       	push   $0xf010706a
f0102b27:	68 87 6f 10 f0       	push   $0xf0106f87
f0102b2c:	68 3e 06 00 00       	push   $0x63e
f0102b31:	68 61 6f 10 f0       	push   $0xf0106f61
f0102b36:	e8 59 d5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b3b:	83 ec 0c             	sub    $0xc,%esp
f0102b3e:	6a 00                	push   $0x0
f0102b40:	e8 2c e4 ff ff       	call   f0100f71 <page_alloc>
f0102b45:	89 c7                	mov    %eax,%edi
f0102b47:	83 c4 10             	add    $0x10,%esp
f0102b4a:	85 c0                	test   %eax,%eax
f0102b4c:	75 19                	jne    f0102b67 <mem_init+0x1715>
f0102b4e:	68 80 70 10 f0       	push   $0xf0107080
f0102b53:	68 87 6f 10 f0       	push   $0xf0106f87
f0102b58:	68 3f 06 00 00       	push   $0x63f
f0102b5d:	68 61 6f 10 f0       	push   $0xf0106f61
f0102b62:	e8 2d d5 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b67:	83 ec 0c             	sub    $0xc,%esp
f0102b6a:	6a 00                	push   $0x0
f0102b6c:	e8 00 e4 ff ff       	call   f0100f71 <page_alloc>
f0102b71:	89 c6                	mov    %eax,%esi
f0102b73:	83 c4 10             	add    $0x10,%esp
f0102b76:	85 c0                	test   %eax,%eax
f0102b78:	75 19                	jne    f0102b93 <mem_init+0x1741>
f0102b7a:	68 96 70 10 f0       	push   $0xf0107096
f0102b7f:	68 87 6f 10 f0       	push   $0xf0106f87
f0102b84:	68 40 06 00 00       	push   $0x640
f0102b89:	68 61 6f 10 f0       	push   $0xf0106f61
f0102b8e:	e8 01 d5 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102b93:	83 ec 0c             	sub    $0xc,%esp
f0102b96:	53                   	push   %ebx
f0102b97:	e8 8e e4 ff ff       	call   f010102a <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b9c:	89 f8                	mov    %edi,%eax
f0102b9e:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102ba4:	c1 f8 03             	sar    $0x3,%eax
f0102ba7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102baa:	89 c2                	mov    %eax,%edx
f0102bac:	c1 ea 0c             	shr    $0xc,%edx
f0102baf:	83 c4 10             	add    $0x10,%esp
f0102bb2:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102bb8:	72 12                	jb     f0102bcc <mem_init+0x177a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bba:	50                   	push   %eax
f0102bbb:	68 14 60 10 f0       	push   $0xf0106014
f0102bc0:	6a 58                	push   $0x58
f0102bc2:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0102bc7:	e8 c8 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bcc:	83 ec 04             	sub    $0x4,%esp
f0102bcf:	68 00 10 00 00       	push   $0x1000
f0102bd4:	6a 01                	push   $0x1
f0102bd6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bdb:	50                   	push   %eax
f0102bdc:	e8 c2 26 00 00       	call   f01052a3 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102be1:	89 f0                	mov    %esi,%eax
f0102be3:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102be9:	c1 f8 03             	sar    $0x3,%eax
f0102bec:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bef:	89 c2                	mov    %eax,%edx
f0102bf1:	c1 ea 0c             	shr    $0xc,%edx
f0102bf4:	83 c4 10             	add    $0x10,%esp
f0102bf7:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102bfd:	72 12                	jb     f0102c11 <mem_init+0x17bf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bff:	50                   	push   %eax
f0102c00:	68 14 60 10 f0       	push   $0xf0106014
f0102c05:	6a 58                	push   $0x58
f0102c07:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0102c0c:	e8 83 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c11:	83 ec 04             	sub    $0x4,%esp
f0102c14:	68 00 10 00 00       	push   $0x1000
f0102c19:	6a 02                	push   $0x2
f0102c1b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c20:	50                   	push   %eax
f0102c21:	e8 7d 26 00 00       	call   f01052a3 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c26:	6a 02                	push   $0x2
f0102c28:	68 00 10 00 00       	push   $0x1000
f0102c2d:	57                   	push   %edi
f0102c2e:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102c34:	e8 27 e7 ff ff       	call   f0101360 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c39:	83 c4 20             	add    $0x20,%esp
f0102c3c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c41:	74 19                	je     f0102c5c <mem_init+0x180a>
f0102c43:	68 67 71 10 f0       	push   $0xf0107167
f0102c48:	68 87 6f 10 f0       	push   $0xf0106f87
f0102c4d:	68 45 06 00 00       	push   $0x645
f0102c52:	68 61 6f 10 f0       	push   $0xf0106f61
f0102c57:	e8 38 d4 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c5c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c63:	01 01 01 
f0102c66:	74 19                	je     f0102c81 <mem_init+0x182f>
f0102c68:	68 8c 6e 10 f0       	push   $0xf0106e8c
f0102c6d:	68 87 6f 10 f0       	push   $0xf0106f87
f0102c72:	68 46 06 00 00       	push   $0x646
f0102c77:	68 61 6f 10 f0       	push   $0xf0106f61
f0102c7c:	e8 13 d4 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c81:	6a 02                	push   $0x2
f0102c83:	68 00 10 00 00       	push   $0x1000
f0102c88:	56                   	push   %esi
f0102c89:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102c8f:	e8 cc e6 ff ff       	call   f0101360 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c94:	83 c4 10             	add    $0x10,%esp
f0102c97:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c9e:	02 02 02 
f0102ca1:	74 19                	je     f0102cbc <mem_init+0x186a>
f0102ca3:	68 b0 6e 10 f0       	push   $0xf0106eb0
f0102ca8:	68 87 6f 10 f0       	push   $0xf0106f87
f0102cad:	68 48 06 00 00       	push   $0x648
f0102cb2:	68 61 6f 10 f0       	push   $0xf0106f61
f0102cb7:	e8 d8 d3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102cbc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cc1:	74 19                	je     f0102cdc <mem_init+0x188a>
f0102cc3:	68 89 71 10 f0       	push   $0xf0107189
f0102cc8:	68 87 6f 10 f0       	push   $0xf0106f87
f0102ccd:	68 49 06 00 00       	push   $0x649
f0102cd2:	68 61 6f 10 f0       	push   $0xf0106f61
f0102cd7:	e8 b8 d3 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102cdc:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ce1:	74 19                	je     f0102cfc <mem_init+0x18aa>
f0102ce3:	68 f3 71 10 f0       	push   $0xf01071f3
f0102ce8:	68 87 6f 10 f0       	push   $0xf0106f87
f0102ced:	68 4a 06 00 00       	push   $0x64a
f0102cf2:	68 61 6f 10 f0       	push   $0xf0106f61
f0102cf7:	e8 98 d3 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cfc:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d03:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d06:	89 f0                	mov    %esi,%eax
f0102d08:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102d0e:	c1 f8 03             	sar    $0x3,%eax
f0102d11:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d14:	89 c2                	mov    %eax,%edx
f0102d16:	c1 ea 0c             	shr    $0xc,%edx
f0102d19:	3b 15 88 be 22 f0    	cmp    0xf022be88,%edx
f0102d1f:	72 12                	jb     f0102d33 <mem_init+0x18e1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d21:	50                   	push   %eax
f0102d22:	68 14 60 10 f0       	push   $0xf0106014
f0102d27:	6a 58                	push   $0x58
f0102d29:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0102d2e:	e8 61 d3 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d33:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d3a:	03 03 03 
f0102d3d:	74 19                	je     f0102d58 <mem_init+0x1906>
f0102d3f:	68 d4 6e 10 f0       	push   $0xf0106ed4
f0102d44:	68 87 6f 10 f0       	push   $0xf0106f87
f0102d49:	68 4c 06 00 00       	push   $0x64c
f0102d4e:	68 61 6f 10 f0       	push   $0xf0106f61
f0102d53:	e8 3c d3 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d58:	83 ec 08             	sub    $0x8,%esp
f0102d5b:	68 00 10 00 00       	push   $0x1000
f0102d60:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f0102d66:	e8 af e5 ff ff       	call   f010131a <page_remove>
	assert(pp2->pp_ref == 0);
f0102d6b:	83 c4 10             	add    $0x10,%esp
f0102d6e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102d73:	74 19                	je     f0102d8e <mem_init+0x193c>
f0102d75:	68 c1 71 10 f0       	push   $0xf01071c1
f0102d7a:	68 87 6f 10 f0       	push   $0xf0106f87
f0102d7f:	68 4e 06 00 00       	push   $0x64e
f0102d84:	68 61 6f 10 f0       	push   $0xf0106f61
f0102d89:	e8 06 d3 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d8e:	8b 0d 8c be 22 f0    	mov    0xf022be8c,%ecx
f0102d94:	8b 11                	mov    (%ecx),%edx
f0102d96:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d9c:	89 d8                	mov    %ebx,%eax
f0102d9e:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0102da4:	c1 f8 03             	sar    $0x3,%eax
f0102da7:	c1 e0 0c             	shl    $0xc,%eax
f0102daa:	39 c2                	cmp    %eax,%edx
f0102dac:	74 19                	je     f0102dc7 <mem_init+0x1975>
f0102dae:	68 2c 68 10 f0       	push   $0xf010682c
f0102db3:	68 87 6f 10 f0       	push   $0xf0106f87
f0102db8:	68 51 06 00 00       	push   $0x651
f0102dbd:	68 61 6f 10 f0       	push   $0xf0106f61
f0102dc2:	e8 cd d2 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102dc7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102dcd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102dd2:	74 19                	je     f0102ded <mem_init+0x199b>
f0102dd4:	68 78 71 10 f0       	push   $0xf0107178
f0102dd9:	68 87 6f 10 f0       	push   $0xf0106f87
f0102dde:	68 53 06 00 00       	push   $0x653
f0102de3:	68 61 6f 10 f0       	push   $0xf0106f61
f0102de8:	e8 a7 d2 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102ded:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102df3:	83 ec 0c             	sub    $0xc,%esp
f0102df6:	53                   	push   %ebx
f0102df7:	e8 2e e2 ff ff       	call   f010102a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dfc:	c7 04 24 00 6f 10 f0 	movl   $0xf0106f00,(%esp)
f0102e03:	e8 76 0a 00 00       	call   f010387e <cprintf>
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
	//cprintf("here I put out the tag.\n");
}
f0102e08:	83 c4 10             	add    $0x10,%esp
f0102e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e0e:	5b                   	pop    %ebx
f0102e0f:	5e                   	pop    %esi
f0102e10:	5f                   	pop    %edi
f0102e11:	5d                   	pop    %ebp
f0102e12:	c3                   	ret    

f0102e13 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e13:	55                   	push   %ebp
f0102e14:	89 e5                	mov    %esp,%ebp
f0102e16:	57                   	push   %edi
f0102e17:	56                   	push   %esi
f0102e18:	53                   	push   %ebx
f0102e19:	83 ec 1c             	sub    $0x1c,%esp
f0102e1c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102e1f:	8b 75 14             	mov    0x14(%ebp),%esi
	//the code is very bad written by myself.
	*/


	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102e22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e25:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e2e:	03 45 10             	add    0x10(%ebp),%eax
f0102e31:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102e36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102e3e:	eb 43                	jmp    f0102e83 <user_mem_check+0x70>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102e40:	83 ec 04             	sub    $0x4,%esp
f0102e43:	6a 00                	push   $0x0
f0102e45:	53                   	push   %ebx
f0102e46:	ff 77 60             	pushl  0x60(%edi)
f0102e49:	e8 bd e2 ff ff       	call   f010110b <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102e4e:	83 c4 10             	add    $0x10,%esp
f0102e51:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102e57:	77 10                	ja     f0102e69 <user_mem_check+0x56>
f0102e59:	85 c0                	test   %eax,%eax
f0102e5b:	74 0c                	je     f0102e69 <user_mem_check+0x56>
f0102e5d:	8b 00                	mov    (%eax),%eax
f0102e5f:	a8 01                	test   $0x1,%al
f0102e61:	74 06                	je     f0102e69 <user_mem_check+0x56>
f0102e63:	21 f0                	and    %esi,%eax
f0102e65:	39 c6                	cmp    %eax,%esi
f0102e67:	74 14                	je     f0102e7d <user_mem_check+0x6a>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102e69:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102e6c:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102e70:	89 1d 3c b2 22 f0    	mov    %ebx,0xf022b23c
			return -E_FAULT;
f0102e76:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e7b:	eb 10                	jmp    f0102e8d <user_mem_check+0x7a>

	//other people's code.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102e7d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e83:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102e86:	72 b8                	jb     f0102e40 <user_mem_check+0x2d>
			return -E_FAULT;
		}
	}

//	cprintf("user_mem_check success va: %x, len: %x\n", va, len);	
	return 0;
f0102e88:	b8 00 00 00 00       	mov    $0x0,%eax


}
f0102e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e90:	5b                   	pop    %ebx
f0102e91:	5e                   	pop    %esi
f0102e92:	5f                   	pop    %edi
f0102e93:	5d                   	pop    %ebp
f0102e94:	c3                   	ret    

f0102e95 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102e95:	55                   	push   %ebp
f0102e96:	89 e5                	mov    %esp,%ebp
f0102e98:	53                   	push   %ebx
f0102e99:	83 ec 04             	sub    $0x4,%esp
f0102e9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102e9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ea2:	83 c8 04             	or     $0x4,%eax
f0102ea5:	50                   	push   %eax
f0102ea6:	ff 75 10             	pushl  0x10(%ebp)
f0102ea9:	ff 75 0c             	pushl  0xc(%ebp)
f0102eac:	53                   	push   %ebx
f0102ead:	e8 61 ff ff ff       	call   f0102e13 <user_mem_check>
f0102eb2:	83 c4 10             	add    $0x10,%esp
f0102eb5:	85 c0                	test   %eax,%eax
f0102eb7:	79 21                	jns    f0102eda <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102eb9:	83 ec 04             	sub    $0x4,%esp
f0102ebc:	ff 35 3c b2 22 f0    	pushl  0xf022b23c
f0102ec2:	ff 73 48             	pushl  0x48(%ebx)
f0102ec5:	68 2c 6f 10 f0       	push   $0xf0106f2c
f0102eca:	e8 af 09 00 00       	call   f010387e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102ecf:	89 1c 24             	mov    %ebx,(%esp)
f0102ed2:	e8 ea 06 00 00       	call   f01035c1 <env_destroy>
f0102ed7:	83 c4 10             	add    $0x10,%esp
	}
}
f0102eda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102edd:	c9                   	leave  
f0102ede:	c3                   	ret    

f0102edf <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102edf:	55                   	push   %ebp
f0102ee0:	89 e5                	mov    %esp,%ebp
f0102ee2:	57                   	push   %edi
f0102ee3:	56                   	push   %esi
f0102ee4:	53                   	push   %ebx
f0102ee5:	83 ec 0c             	sub    $0xc,%esp
f0102ee8:	89 c7                	mov    %eax,%edi
		va+=PGSIZE;
	}
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
f0102eea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102ef0:	89 d6                	mov    %edx,%esi
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
f0102ef2:	8d 81 ff 0f 00 00    	lea    0xfff(%ecx),%eax
f0102ef8:	25 ff 0f 00 00       	and    $0xfff,%eax
f0102efd:	8d 99 ff 1f 00 00    	lea    0x1fff(%ecx),%ebx
f0102f03:	29 c3                	sub    %eax,%ebx
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f05:	eb 5e                	jmp    f0102f65 <region_alloc+0x86>
	{
		pp = page_alloc(0);
f0102f07:	83 ec 0c             	sub    $0xc,%esp
f0102f0a:	6a 00                	push   $0x0
f0102f0c:	e8 60 e0 ff ff       	call   f0100f71 <page_alloc>
 
		if(!pp)
f0102f11:	83 c4 10             	add    $0x10,%esp
f0102f14:	85 c0                	test   %eax,%eax
f0102f16:	75 17                	jne    f0102f2f <region_alloc+0x50>
		{
			panic("region_alloc failed!\n");
f0102f18:	83 ec 04             	sub    $0x4,%esp
f0102f1b:	68 97 72 10 f0       	push   $0xf0107297
f0102f20:	68 52 01 00 00       	push   $0x152
f0102f25:	68 ad 72 10 f0       	push   $0xf01072ad
f0102f2a:	e8 65 d1 ff ff       	call   f0100094 <_panic>
		}
		ret = page_insert(e->env_pgdir,pp,va,PTE_U|PTE_W|PTE_P);
f0102f2f:	6a 07                	push   $0x7
f0102f31:	56                   	push   %esi
f0102f32:	50                   	push   %eax
f0102f33:	ff 77 60             	pushl  0x60(%edi)
f0102f36:	e8 25 e4 ff ff       	call   f0101360 <page_insert>
 
		if(ret)
f0102f3b:	83 c4 10             	add    $0x10,%esp
f0102f3e:	85 c0                	test   %eax,%eax
f0102f40:	74 17                	je     f0102f59 <region_alloc+0x7a>
		{
			panic("region_alloc failed!\n");
f0102f42:	83 ec 04             	sub    $0x4,%esp
f0102f45:	68 97 72 10 f0       	push   $0xf0107297
f0102f4a:	68 58 01 00 00       	push   $0x158
f0102f4f:	68 ad 72 10 f0       	push   $0xf01072ad
f0102f54:	e8 3b d1 ff ff       	call   f0100094 <_panic>
*/	
	struct PageInfo *pp;
	int ret = 0;
	va  = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE)+PGSIZE; 
	for(;len > 0; len -= PGSIZE, va += PGSIZE)
f0102f59:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
f0102f5f:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102f65:	85 db                	test   %ebx,%ebx
f0102f67:	75 9e                	jne    f0102f07 <region_alloc+0x28>
			panic("region_alloc failed!\n");
		}
	}


}
f0102f69:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f6c:	5b                   	pop    %ebx
f0102f6d:	5e                   	pop    %esi
f0102f6e:	5f                   	pop    %edi
f0102f6f:	5d                   	pop    %ebp
f0102f70:	c3                   	ret    

f0102f71 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f71:	55                   	push   %ebp
f0102f72:	89 e5                	mov    %esp,%ebp
f0102f74:	56                   	push   %esi
f0102f75:	53                   	push   %ebx
f0102f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f79:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102f7c:	85 c0                	test   %eax,%eax
f0102f7e:	75 1d                	jne    f0102f9d <envid2env+0x2c>
		*env_store = curenv;
f0102f80:	e8 41 29 00 00       	call   f01058c6 <cpunum>
f0102f85:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f88:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0102f8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102f91:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102f93:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f98:	e9 a8 00 00 00       	jmp    f0103045 <envid2env+0xd4>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102f9d:	89 c3                	mov    %eax,%ebx
f0102f9f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102fa5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102fa8:	03 1d 44 b2 22 f0    	add    0xf022b244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fae:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102fb2:	74 05                	je     f0102fb9 <envid2env+0x48>
f0102fb4:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102fb7:	74 24                	je     f0102fdd <envid2env+0x6c>
		cprintf("we are at e->env_id:%d == envid:%d\n",e->env_id,envid);
f0102fb9:	83 ec 04             	sub    $0x4,%esp
f0102fbc:	50                   	push   %eax
f0102fbd:	ff 73 48             	pushl  0x48(%ebx)
f0102fc0:	68 30 73 10 f0       	push   $0xf0107330
f0102fc5:	e8 b4 08 00 00       	call   f010387e <cprintf>
		*env_store = 0;
f0102fca:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fcd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102fd3:	83 c4 10             	add    $0x10,%esp
f0102fd6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fdb:	eb 68                	jmp    f0103045 <envid2env+0xd4>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fdd:	84 d2                	test   %dl,%dl
f0102fdf:	74 5a                	je     f010303b <envid2env+0xca>
f0102fe1:	e8 e0 28 00 00       	call   f01058c6 <cpunum>
f0102fe6:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fe9:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f0102fef:	74 4a                	je     f010303b <envid2env+0xca>
f0102ff1:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ff4:	e8 cd 28 00 00       	call   f01058c6 <cpunum>
f0102ff9:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ffc:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103002:	3b 70 48             	cmp    0x48(%eax),%esi
f0103005:	74 34                	je     f010303b <envid2env+0xca>
		*env_store = 0;
f0103007:	8b 45 0c             	mov    0xc(%ebp),%eax
f010300a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		cprintf("we are at e->env_parent_id:%d curenv->env_id:%d\n",e->env_parent_id,curenv->env_id);
f0103010:	e8 b1 28 00 00       	call   f01058c6 <cpunum>
f0103015:	83 ec 04             	sub    $0x4,%esp
f0103018:	6b c0 74             	imul   $0x74,%eax,%eax
f010301b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103021:	ff 70 48             	pushl  0x48(%eax)
f0103024:	ff 73 4c             	pushl  0x4c(%ebx)
f0103027:	68 54 73 10 f0       	push   $0xf0107354
f010302c:	e8 4d 08 00 00       	call   f010387e <cprintf>
		return -E_BAD_ENV;
f0103031:	83 c4 10             	add    $0x10,%esp
f0103034:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103039:	eb 0a                	jmp    f0103045 <envid2env+0xd4>
	}

	*env_store = e;
f010303b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010303e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103040:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103045:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103048:	5b                   	pop    %ebx
f0103049:	5e                   	pop    %esi
f010304a:	5d                   	pop    %ebp
f010304b:	c3                   	ret    

f010304c <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010304c:	55                   	push   %ebp
f010304d:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f010304f:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f0103054:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103057:	b8 23 00 00 00       	mov    $0x23,%eax
f010305c:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010305e:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103060:	b8 10 00 00 00       	mov    $0x10,%eax
f0103065:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103067:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103069:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010306b:	ea 72 30 10 f0 08 00 	ljmp   $0x8,$0xf0103072
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103072:	b8 00 00 00 00       	mov    $0x0,%eax
f0103077:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010307a:	5d                   	pop    %ebp
f010307b:	c3                   	ret    

f010307c <env_init>:
};
*/

void
env_init(void)
{
f010307c:	55                   	push   %ebp
f010307d:	89 e5                	mov    %esp,%ebp
f010307f:	56                   	push   %esi
f0103080:	53                   	push   %ebx
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
	{
		envs[temp].env_id = 0;
f0103081:	8b 35 44 b2 22 f0    	mov    0xf022b244,%esi
f0103087:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f010308d:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0103090:	ba 00 00 00 00       	mov    $0x0,%edx
f0103095:	89 c1                	mov    %eax,%ecx
f0103097:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[temp].env_parent_id = 0;
f010309e:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		envs[temp].env_type = ENV_TYPE_USER;
f01030a5:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
		envs[temp].env_status = 0;
f01030ac:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[temp].env_runs = 0;
f01030b3:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
		envs[temp].env_pgdir = NULL;
f01030ba:	c7 40 60 00 00 00 00 	movl   $0x0,0x60(%eax)
		envs[temp].env_link = env_free_list;
f01030c1:	89 50 44             	mov    %edx,0x44(%eax)
f01030c4:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[temp];
f01030c7:	89 ca                	mov    %ecx,%edx
	// Set up envs array
	// LAB 3: Your code here.
	int temp = 0;
	env_free_list = NULL;
	//cprintf("THE START ENVS IS:0x%x\n",envs);
	for(temp = NENV -1;temp >= 0;temp--)
f01030c9:	39 d8                	cmp    %ebx,%eax
f01030cb:	75 c8                	jne    f0103095 <env_init+0x19>
f01030cd:	89 35 48 b2 22 f0    	mov    %esi,0xf022b248
		envs[temp].env_pgdir = NULL;
		envs[temp].env_link = env_free_list;
		env_free_list = &envs[temp];
	}
 
	cprintf("env_free_list : 0x%08x, &envs[temp]: 0x%08x\n",env_free_list,&envs[temp]);
f01030d3:	83 ec 04             	sub    $0x4,%esp
f01030d6:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01030db:	83 e8 7c             	sub    $0x7c,%eax
f01030de:	50                   	push   %eax
f01030df:	56                   	push   %esi
f01030e0:	68 88 73 10 f0       	push   $0xf0107388
f01030e5:	e8 94 07 00 00       	call   f010387e <cprintf>
 

	// Per-CPU part of the initialization
	env_init_percpu();
f01030ea:	e8 5d ff ff ff       	call   f010304c <env_init_percpu>
}
f01030ef:	83 c4 10             	add    $0x10,%esp
f01030f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030f5:	5b                   	pop    %ebx
f01030f6:	5e                   	pop    %esi
f01030f7:	5d                   	pop    %ebp
f01030f8:	c3                   	ret    

f01030f9 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030f9:	55                   	push   %ebp
f01030fa:	89 e5                	mov    %esp,%ebp
f01030fc:	57                   	push   %edi
f01030fd:	56                   	push   %esi
f01030fe:	53                   	push   %ebx
f01030ff:	83 ec 0c             	sub    $0xc,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103102:	8b 1d 48 b2 22 f0    	mov    0xf022b248,%ebx
f0103108:	85 db                	test   %ebx,%ebx
f010310a:	0f 84 5d 01 00 00    	je     f010326d <env_alloc+0x174>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103110:	83 ec 0c             	sub    $0xc,%esp
f0103113:	6a 01                	push   $0x1
f0103115:	e8 57 de ff ff       	call   f0100f71 <page_alloc>
f010311a:	83 c4 10             	add    $0x10,%esp
f010311d:	85 c0                	test   %eax,%eax
f010311f:	0f 84 4f 01 00 00    	je     f0103274 <env_alloc+0x17b>

	
	// LAB 3: Your code here.

	//!copy from web ,just to know how it runs.
	(p->pp_ref)++;
f0103125:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010312a:	2b 05 90 be 22 f0    	sub    0xf022be90,%eax
f0103130:	89 c6                	mov    %eax,%esi
f0103132:	c1 fe 03             	sar    $0x3,%esi
f0103135:	c1 e6 0c             	shl    $0xc,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103138:	89 f0                	mov    %esi,%eax
f010313a:	c1 e8 0c             	shr    $0xc,%eax
f010313d:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103143:	72 12                	jb     f0103157 <env_alloc+0x5e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103145:	56                   	push   %esi
f0103146:	68 14 60 10 f0       	push   $0xf0106014
f010314b:	6a 58                	push   $0x58
f010314d:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0103152:	e8 3d cf ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0103157:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
        pde_t* page_dir = page2kva(p);
	memcpy(page_dir,kern_pgdir,PGSIZE);
f010315d:	83 ec 04             	sub    $0x4,%esp
f0103160:	68 00 10 00 00       	push   $0x1000
f0103165:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010316b:	57                   	push   %edi
f010316c:	e8 e7 21 00 00       	call   f0105358 <memcpy>
	e->env_pgdir = page_dir;
f0103171:	89 7b 60             	mov    %edi,0x60(%ebx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103174:	83 c4 10             	add    $0x10,%esp
f0103177:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010317d:	77 15                	ja     f0103194 <env_alloc+0x9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010317f:	57                   	push   %edi
f0103180:	68 38 60 10 f0       	push   $0xf0106038
f0103185:	68 e6 00 00 00       	push   $0xe6
f010318a:	68 ad 72 10 f0       	push   $0xf01072ad
f010318f:	e8 00 cf ff ff       	call   f0100094 <_panic>
	
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103194:	83 ce 05             	or     $0x5,%esi
f0103197:	89 b7 f4 0e 00 00    	mov    %esi,0xef4(%edi)

	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010319d:	8b 43 48             	mov    0x48(%ebx),%eax
f01031a0:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031a5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031aa:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031af:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031b2:	89 da                	mov    %ebx,%edx
f01031b4:	2b 15 44 b2 22 f0    	sub    0xf022b244,%edx
f01031ba:	c1 fa 02             	sar    $0x2,%edx
f01031bd:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031c3:	09 d0                	or     %edx,%eax
f01031c5:	89 43 48             	mov    %eax,0x48(%ebx)
	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031cb:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031ce:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031d5:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031dc:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031e3:	83 ec 04             	sub    $0x4,%esp
f01031e6:	6a 44                	push   $0x44
f01031e8:	6a 00                	push   $0x0
f01031ea:	53                   	push   %ebx
f01031eb:	e8 b3 20 00 00       	call   f01052a3 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031f0:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031f6:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031fc:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103202:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103209:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010320f:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103216:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010321a:	8b 43 44             	mov    0x44(%ebx),%eax
f010321d:	a3 48 b2 22 f0       	mov    %eax,0xf022b248
	*newenv_store = e;
f0103222:	8b 45 08             	mov    0x8(%ebp),%eax
f0103225:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103227:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010322a:	e8 97 26 00 00       	call   f01058c6 <cpunum>
f010322f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103232:	83 c4 10             	add    $0x10,%esp
f0103235:	ba 00 00 00 00       	mov    $0x0,%edx
f010323a:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103241:	74 11                	je     f0103254 <env_alloc+0x15b>
f0103243:	e8 7e 26 00 00       	call   f01058c6 <cpunum>
f0103248:	6b c0 74             	imul   $0x74,%eax,%eax
f010324b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103251:	8b 50 48             	mov    0x48(%eax),%edx
f0103254:	83 ec 04             	sub    $0x4,%esp
f0103257:	53                   	push   %ebx
f0103258:	52                   	push   %edx
f0103259:	68 b8 72 10 f0       	push   $0xf01072b8
f010325e:	e8 1b 06 00 00       	call   f010387e <cprintf>
	return 0;
f0103263:	83 c4 10             	add    $0x10,%esp
f0103266:	b8 00 00 00 00       	mov    $0x0,%eax
f010326b:	eb 0c                	jmp    f0103279 <env_alloc+0x180>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010326d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103272:	eb 05                	jmp    f0103279 <env_alloc+0x180>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103274:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// commit the allocation
	env_free_list = e->env_link;
	*newenv_store = e;
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103279:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010327c:	5b                   	pop    %ebx
f010327d:	5e                   	pop    %esi
f010327e:	5f                   	pop    %edi
f010327f:	5d                   	pop    %ebp
f0103280:	c3                   	ret    

f0103281 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103281:	55                   	push   %ebp
f0103282:	89 e5                	mov    %esp,%ebp
f0103284:	57                   	push   %edi
f0103285:	56                   	push   %esi
f0103286:	53                   	push   %ebx
f0103287:	83 ec 34             	sub    $0x34,%esp
f010328a:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	int ret = 0;
	struct Env * e = NULL;	
f010328d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	

	ret = env_alloc(&e,0);
f0103294:	6a 00                	push   $0x0
f0103296:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103299:	50                   	push   %eax
f010329a:	e8 5a fe ff ff       	call   f01030f9 <env_alloc>
	//panic("panic at env_alloc().\n");
	if(ret < 0){
f010329f:	83 c4 10             	add    $0x10,%esp
f01032a2:	85 c0                	test   %eax,%eax
f01032a4:	79 15                	jns    f01032bb <env_create+0x3a>
		panic("env_create:%e\n",ret);
f01032a6:	50                   	push   %eax
f01032a7:	68 cd 72 10 f0       	push   $0xf01072cd
f01032ac:	68 d0 01 00 00       	push   $0x1d0
f01032b1:	68 ad 72 10 f0       	push   $0xf01072ad
f01032b6:	e8 d9 cd ff ff       	call   f0100094 <_panic>
	}
	load_icode(e,binary);
f01032bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032be:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Proghdr *ph,*eph;
	struct Elf * ELFHDR = ((struct Elf*)binary);
	
	if(ELFHDR->e_magic != ELF_MAGIC){
f01032c1:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032c7:	74 17                	je     f01032e0 <env_create+0x5f>
		panic("This is not a valid file.\n");
f01032c9:	83 ec 04             	sub    $0x4,%esp
f01032cc:	68 dc 72 10 f0       	push   $0xf01072dc
f01032d1:	68 99 01 00 00       	push   $0x199
f01032d6:	68 ad 72 10 f0       	push   $0xf01072ad
f01032db:	e8 b4 cd ff ff       	call   f0100094 <_panic>
	}
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
f01032e0:	89 fb                	mov    %edi,%ebx
f01032e2:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph+ELFHDR->e_phnum;
f01032e5:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032e9:	c1 e6 05             	shl    $0x5,%esi
f01032ec:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f01032ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032f1:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f9:	77 15                	ja     f0103310 <env_create+0x8f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032fb:	50                   	push   %eax
f01032fc:	68 38 60 10 f0       	push   $0xf0106038
f0103301:	68 9e 01 00 00       	push   $0x19e
f0103306:	68 ad 72 10 f0       	push   $0xf01072ad
f010330b:	e8 84 cd ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103310:	05 00 00 00 10       	add    $0x10000000,%eax
f0103315:	0f 22 d8             	mov    %eax,%cr3
f0103318:	eb 60                	jmp    f010337a <env_create+0xf9>

	for(;ph<eph;ph++){

		if(ph->p_type != ELF_PROG_LOAD)
f010331a:	83 3b 01             	cmpl   $0x1,(%ebx)
f010331d:	75 58                	jne    f0103377 <env_create+0xf6>
		{
			continue;
		}
 
		if(ph->p_filesz > ph->p_memsz)
f010331f:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103322:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103325:	76 17                	jbe    f010333e <env_create+0xbd>
		{
			panic("file size is great than memory size\n");
f0103327:	83 ec 04             	sub    $0x4,%esp
f010332a:	68 b8 73 10 f0       	push   $0xf01073b8
f010332f:	68 a9 01 00 00       	push   $0x1a9
f0103334:	68 ad 72 10 f0       	push   $0xf01072ad
f0103339:	e8 56 cd ff ff       	call   f0100094 <_panic>
		}
		//cprintf("ph->p_memsz:0x%x\n",ph->p_memsz); 
		region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f010333e:	8b 53 08             	mov    0x8(%ebx),%edx
f0103341:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103344:	e8 96 fb ff ff       	call   f0102edf <region_alloc>
		//cprintf("DES:0x%x,SRC:0x%x\n",ph->p_va,binary+ph->p_offset);
		//cprintf("ph->filesz:0x%x\n",ph->p_filesz);
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f0103349:	83 ec 04             	sub    $0x4,%esp
f010334c:	ff 73 10             	pushl  0x10(%ebx)
f010334f:	89 f8                	mov    %edi,%eax
f0103351:	03 43 04             	add    0x4(%ebx),%eax
f0103354:	50                   	push   %eax
f0103355:	ff 73 08             	pushl  0x8(%ebx)
f0103358:	e8 93 1f 00 00       	call   f01052f0 <memmove>
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
f010335d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103360:	83 c4 0c             	add    $0xc,%esp
f0103363:	8b 53 14             	mov    0x14(%ebx),%edx
f0103366:	29 c2                	sub    %eax,%edx
f0103368:	52                   	push   %edx
f0103369:	6a 00                	push   $0x0
f010336b:	03 43 08             	add    0x8(%ebx),%eax
f010336e:	50                   	push   %eax
f010336f:	e8 2f 1f 00 00       	call   f01052a3 <memset>
f0103374:	83 c4 10             	add    $0x10,%esp
	ph = (struct Proghdr *)((uint8_t *)ELFHDR+ELFHDR->e_phoff);
	eph = ph+ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	for(;ph<eph;ph++){
f0103377:	83 c3 20             	add    $0x20,%ebx
f010337a:	39 de                	cmp    %ebx,%esi
f010337c:	77 9c                	ja     f010331a <env_create+0x99>
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
	}


	e->env_tf.tf_eip = ELFHDR->e_entry;
f010337e:	8b 47 18             	mov    0x18(%edi),%eax
f0103381:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103384:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	lcr3(PADDR(kern_pgdir));
f0103387:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010338c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103391:	77 15                	ja     f01033a8 <env_create+0x127>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103393:	50                   	push   %eax
f0103394:	68 38 60 10 f0       	push   $0xf0106038
f0103399:	68 b8 01 00 00       	push   $0x1b8
f010339e:	68 ad 72 10 f0       	push   $0xf01072ad
f01033a3:	e8 ec cc ff ff       	call   f0100094 <_panic>
f01033a8:	05 00 00 00 10       	add    $0x10000000,%eax
f01033ad:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e,(void *)USTACKTOP-PGSIZE,(size_t)PGSIZE);	
f01033b0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033b5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033bd:	e8 1d fb ff ff       	call   f0102edf <region_alloc>
	if(ret < 0){
		panic("env_create:%e\n",ret);
	}
	load_icode(e,binary);
	//panic("panic in the load_icode.\n");
	e->env_type = type;
f01033c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033c8:	89 50 50             	mov    %edx,0x50(%eax)
	cprintf("THE e->env_id is:%d\n",e->env_id);
f01033cb:	83 ec 08             	sub    $0x8,%esp
f01033ce:	ff 70 48             	pushl  0x48(%eax)
f01033d1:	68 f7 72 10 f0       	push   $0xf01072f7
f01033d6:	e8 a3 04 00 00       	call   f010387e <cprintf>
}
f01033db:	83 c4 10             	add    $0x10,%esp
f01033de:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033e1:	5b                   	pop    %ebx
f01033e2:	5e                   	pop    %esi
f01033e3:	5f                   	pop    %edi
f01033e4:	5d                   	pop    %ebp
f01033e5:	c3                   	ret    

f01033e6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033e6:	55                   	push   %ebp
f01033e7:	89 e5                	mov    %esp,%ebp
f01033e9:	57                   	push   %edi
f01033ea:	56                   	push   %esi
f01033eb:	53                   	push   %ebx
f01033ec:	83 ec 1c             	sub    $0x1c,%esp
f01033ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033f2:	e8 cf 24 00 00       	call   f01058c6 <cpunum>
f01033f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01033fa:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f0103400:	75 29                	jne    f010342b <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103402:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103407:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010340c:	77 15                	ja     f0103423 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010340e:	50                   	push   %eax
f010340f:	68 38 60 10 f0       	push   $0xf0106038
f0103414:	68 e6 01 00 00       	push   $0x1e6
f0103419:	68 ad 72 10 f0       	push   $0xf01072ad
f010341e:	e8 71 cc ff ff       	call   f0100094 <_panic>
f0103423:	05 00 00 00 10       	add    $0x10000000,%eax
f0103428:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010342b:	8b 5f 48             	mov    0x48(%edi),%ebx
f010342e:	e8 93 24 00 00       	call   f01058c6 <cpunum>
f0103433:	6b c0 74             	imul   $0x74,%eax,%eax
f0103436:	ba 00 00 00 00       	mov    $0x0,%edx
f010343b:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103442:	74 11                	je     f0103455 <env_free+0x6f>
f0103444:	e8 7d 24 00 00       	call   f01058c6 <cpunum>
f0103449:	6b c0 74             	imul   $0x74,%eax,%eax
f010344c:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103452:	8b 50 48             	mov    0x48(%eax),%edx
f0103455:	83 ec 04             	sub    $0x4,%esp
f0103458:	53                   	push   %ebx
f0103459:	52                   	push   %edx
f010345a:	68 0c 73 10 f0       	push   $0xf010730c
f010345f:	e8 1a 04 00 00       	call   f010387e <cprintf>
f0103464:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103467:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010346e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103471:	89 d0                	mov    %edx,%eax
f0103473:	c1 e0 02             	shl    $0x2,%eax
f0103476:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103479:	8b 47 60             	mov    0x60(%edi),%eax
f010347c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010347f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103485:	0f 84 a8 00 00 00    	je     f0103533 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010348b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103491:	89 f0                	mov    %esi,%eax
f0103493:	c1 e8 0c             	shr    $0xc,%eax
f0103496:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103499:	39 05 88 be 22 f0    	cmp    %eax,0xf022be88
f010349f:	77 15                	ja     f01034b6 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01034a1:	56                   	push   %esi
f01034a2:	68 14 60 10 f0       	push   $0xf0106014
f01034a7:	68 f5 01 00 00       	push   $0x1f5
f01034ac:	68 ad 72 10 f0       	push   $0xf01072ad
f01034b1:	e8 de cb ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034b9:	c1 e0 16             	shl    $0x16,%eax
f01034bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034bf:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034c4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034cb:	01 
f01034cc:	74 17                	je     f01034e5 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034ce:	83 ec 08             	sub    $0x8,%esp
f01034d1:	89 d8                	mov    %ebx,%eax
f01034d3:	c1 e0 0c             	shl    $0xc,%eax
f01034d6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034d9:	50                   	push   %eax
f01034da:	ff 77 60             	pushl  0x60(%edi)
f01034dd:	e8 38 de ff ff       	call   f010131a <page_remove>
f01034e2:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034e5:	83 c3 01             	add    $0x1,%ebx
f01034e8:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034ee:	75 d4                	jne    f01034c4 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034f0:	8b 47 60             	mov    0x60(%edi),%eax
f01034f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034f6:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103500:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103506:	72 14                	jb     f010351c <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103508:	83 ec 04             	sub    $0x4,%esp
f010350b:	68 f8 66 10 f0       	push   $0xf01066f8
f0103510:	6a 51                	push   $0x51
f0103512:	68 6d 6f 10 f0       	push   $0xf0106f6d
f0103517:	e8 78 cb ff ff       	call   f0100094 <_panic>
		page_decref(pa2page(pa));
f010351c:	83 ec 0c             	sub    $0xc,%esp
f010351f:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0103524:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103527:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010352a:	50                   	push   %eax
f010352b:	e8 b4 db ff ff       	call   f01010e4 <page_decref>
f0103530:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103533:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103537:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010353a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010353f:	0f 85 29 ff ff ff    	jne    f010346e <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103545:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103548:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010354d:	77 15                	ja     f0103564 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010354f:	50                   	push   %eax
f0103550:	68 38 60 10 f0       	push   $0xf0106038
f0103555:	68 03 02 00 00       	push   $0x203
f010355a:	68 ad 72 10 f0       	push   $0xf01072ad
f010355f:	e8 30 cb ff ff       	call   f0100094 <_panic>
	e->env_pgdir = 0;
f0103564:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010356b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103570:	c1 e8 0c             	shr    $0xc,%eax
f0103573:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103579:	72 14                	jb     f010358f <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f010357b:	83 ec 04             	sub    $0x4,%esp
f010357e:	68 f8 66 10 f0       	push   $0xf01066f8
f0103583:	6a 51                	push   $0x51
f0103585:	68 6d 6f 10 f0       	push   $0xf0106f6d
f010358a:	e8 05 cb ff ff       	call   f0100094 <_panic>
	page_decref(pa2page(pa));
f010358f:	83 ec 0c             	sub    $0xc,%esp
f0103592:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0103598:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010359b:	50                   	push   %eax
f010359c:	e8 43 db ff ff       	call   f01010e4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035a1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01035a8:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f01035ad:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01035b0:	89 3d 48 b2 22 f0    	mov    %edi,0xf022b248
}
f01035b6:	83 c4 10             	add    $0x10,%esp
f01035b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035bc:	5b                   	pop    %ebx
f01035bd:	5e                   	pop    %esi
f01035be:	5f                   	pop    %edi
f01035bf:	5d                   	pop    %ebp
f01035c0:	c3                   	ret    

f01035c1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035c1:	55                   	push   %ebp
f01035c2:	89 e5                	mov    %esp,%ebp
f01035c4:	53                   	push   %ebx
f01035c5:	83 ec 04             	sub    $0x4,%esp
f01035c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035cb:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035cf:	75 19                	jne    f01035ea <env_destroy+0x29>
f01035d1:	e8 f0 22 00 00       	call   f01058c6 <cpunum>
f01035d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01035d9:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01035df:	74 09                	je     f01035ea <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035e1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035e8:	eb 33                	jmp    f010361d <env_destroy+0x5c>
	}

	env_free(e);
f01035ea:	83 ec 0c             	sub    $0xc,%esp
f01035ed:	53                   	push   %ebx
f01035ee:	e8 f3 fd ff ff       	call   f01033e6 <env_free>

	if (curenv == e) {
f01035f3:	e8 ce 22 00 00       	call   f01058c6 <cpunum>
f01035f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fb:	83 c4 10             	add    $0x10,%esp
f01035fe:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f0103604:	75 17                	jne    f010361d <env_destroy+0x5c>
		curenv = NULL;
f0103606:	e8 bb 22 00 00       	call   f01058c6 <cpunum>
f010360b:	6b c0 74             	imul   $0x74,%eax,%eax
f010360e:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0103615:	00 00 00 
		sched_yield();
f0103618:	e8 7d 0c 00 00       	call   f010429a <sched_yield>
	}
}
f010361d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103620:	c9                   	leave  
f0103621:	c3                   	ret    

f0103622 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103622:	55                   	push   %ebp
f0103623:	89 e5                	mov    %esp,%ebp
f0103625:	53                   	push   %ebx
f0103626:	83 ec 04             	sub    $0x4,%esp

	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103629:	e8 98 22 00 00       	call   f01058c6 <cpunum>
f010362e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103631:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103637:	e8 8a 22 00 00       	call   f01058c6 <cpunum>
f010363c:	89 43 5c             	mov    %eax,0x5c(%ebx)
	asm volatile(
f010363f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103642:	61                   	popa   
f0103643:	07                   	pop    %es
f0103644:	1f                   	pop    %ds
f0103645:	83 c4 08             	add    $0x8,%esp
f0103648:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103649:	83 ec 04             	sub    $0x4,%esp
f010364c:	68 22 73 10 f0       	push   $0xf0107322
f0103651:	68 3a 02 00 00       	push   $0x23a
f0103656:	68 ad 72 10 f0       	push   $0xf01072ad
f010365b:	e8 34 ca ff ff       	call   f0100094 <_panic>

f0103660 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103660:	55                   	push   %ebp
f0103661:	89 e5                	mov    %esp,%ebp
f0103663:	53                   	push   %ebx
f0103664:	83 ec 04             	sub    $0x4,%esp
f0103667:	8b 5d 08             	mov    0x8(%ebp),%ebx

	// LAB 3: Your code here.

//	cprintf("		We are going to run a env.\n");

	if(curenv && curenv->env_status == ENV_RUNNING)
f010366a:	e8 57 22 00 00       	call   f01058c6 <cpunum>
f010366f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103672:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103679:	74 29                	je     f01036a4 <env_run+0x44>
f010367b:	e8 46 22 00 00       	call   f01058c6 <cpunum>
f0103680:	6b c0 74             	imul   $0x74,%eax,%eax
f0103683:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103689:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010368d:	75 15                	jne    f01036a4 <env_run+0x44>
	{
			curenv->env_status = ENV_RUNNABLE;
f010368f:	e8 32 22 00 00       	call   f01058c6 <cpunum>
f0103694:	6b c0 74             	imul   $0x74,%eax,%eax
f0103697:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010369d:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
 
	curenv = e;
f01036a4:	e8 1d 22 00 00       	call   f01058c6 <cpunum>
f01036a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ac:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
	e->env_status = ENV_RUNNING;
f01036b2:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f01036b9:	83 43 58 01          	addl   $0x1,0x58(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036bd:	83 ec 0c             	sub    $0xc,%esp
f01036c0:	68 c0 03 12 f0       	push   $0xf01203c0
f01036c5:	e8 07 25 00 00       	call   f0105bd1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036ca:	f3 90                	pause  
	unlock_kernel();
	lcr3(PADDR(e->env_pgdir));	
f01036cc:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036cf:	83 c4 10             	add    $0x10,%esp
f01036d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036d7:	77 15                	ja     f01036ee <env_run+0x8e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036d9:	50                   	push   %eax
f01036da:	68 38 60 10 f0       	push   $0xf0106038
f01036df:	68 64 02 00 00       	push   $0x264
f01036e4:	68 ad 72 10 f0       	push   $0xf01072ad
f01036e9:	e8 a6 c9 ff ff       	call   f0100094 <_panic>
f01036ee:	05 00 00 00 10       	add    $0x10000000,%eax
f01036f3:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&(e->env_tf));
f01036f6:	83 ec 0c             	sub    $0xc,%esp
f01036f9:	53                   	push   %ebx
f01036fa:	e8 23 ff ff ff       	call   f0103622 <env_pop_tf>

f01036ff <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
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

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010370b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103710:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103711:	0f b6 c0             	movzbl %al,%eax
}
f0103714:	5d                   	pop    %ebp
f0103715:	c3                   	ret    

f0103716 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103716:	55                   	push   %ebp
f0103717:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103719:	ba 70 00 00 00       	mov    $0x70,%edx
f010371e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103721:	ee                   	out    %al,(%dx)
f0103722:	ba 71 00 00 00       	mov    $0x71,%edx
f0103727:	8b 45 0c             	mov    0xc(%ebp),%eax
f010372a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010372b:	5d                   	pop    %ebp
f010372c:	c3                   	ret    

f010372d <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010372d:	55                   	push   %ebp
f010372e:	89 e5                	mov    %esp,%ebp
f0103730:	56                   	push   %esi
f0103731:	53                   	push   %ebx
f0103732:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103735:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f010373b:	80 3d 4c b2 22 f0 00 	cmpb   $0x0,0xf022b24c
f0103742:	74 5a                	je     f010379e <irq_setmask_8259A+0x71>
f0103744:	89 c6                	mov    %eax,%esi
f0103746:	ba 21 00 00 00       	mov    $0x21,%edx
f010374b:	ee                   	out    %al,(%dx)
f010374c:	66 c1 e8 08          	shr    $0x8,%ax
f0103750:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103755:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103756:	83 ec 0c             	sub    $0xc,%esp
f0103759:	68 dd 73 10 f0       	push   $0xf01073dd
f010375e:	e8 1b 01 00 00       	call   f010387e <cprintf>
f0103763:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103766:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010376b:	0f b7 f6             	movzwl %si,%esi
f010376e:	f7 d6                	not    %esi
f0103770:	0f a3 de             	bt     %ebx,%esi
f0103773:	73 11                	jae    f0103786 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103775:	83 ec 08             	sub    $0x8,%esp
f0103778:	53                   	push   %ebx
f0103779:	68 4f 79 10 f0       	push   $0xf010794f
f010377e:	e8 fb 00 00 00       	call   f010387e <cprintf>
f0103783:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103786:	83 c3 01             	add    $0x1,%ebx
f0103789:	83 fb 10             	cmp    $0x10,%ebx
f010378c:	75 e2                	jne    f0103770 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010378e:	83 ec 0c             	sub    $0xc,%esp
f0103791:	68 24 63 10 f0       	push   $0xf0106324
f0103796:	e8 e3 00 00 00       	call   f010387e <cprintf>
f010379b:	83 c4 10             	add    $0x10,%esp
}
f010379e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037a1:	5b                   	pop    %ebx
f01037a2:	5e                   	pop    %esi
f01037a3:	5d                   	pop    %ebp
f01037a4:	c3                   	ret    

f01037a5 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01037a5:	c6 05 4c b2 22 f0 01 	movb   $0x1,0xf022b24c
f01037ac:	ba 21 00 00 00       	mov    $0x21,%edx
f01037b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037b6:	ee                   	out    %al,(%dx)
f01037b7:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037bc:	ee                   	out    %al,(%dx)
f01037bd:	ba 20 00 00 00       	mov    $0x20,%edx
f01037c2:	b8 11 00 00 00       	mov    $0x11,%eax
f01037c7:	ee                   	out    %al,(%dx)
f01037c8:	ba 21 00 00 00       	mov    $0x21,%edx
f01037cd:	b8 20 00 00 00       	mov    $0x20,%eax
f01037d2:	ee                   	out    %al,(%dx)
f01037d3:	b8 04 00 00 00       	mov    $0x4,%eax
f01037d8:	ee                   	out    %al,(%dx)
f01037d9:	b8 03 00 00 00       	mov    $0x3,%eax
f01037de:	ee                   	out    %al,(%dx)
f01037df:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037e4:	b8 11 00 00 00       	mov    $0x11,%eax
f01037e9:	ee                   	out    %al,(%dx)
f01037ea:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037ef:	b8 28 00 00 00       	mov    $0x28,%eax
f01037f4:	ee                   	out    %al,(%dx)
f01037f5:	b8 02 00 00 00       	mov    $0x2,%eax
f01037fa:	ee                   	out    %al,(%dx)
f01037fb:	b8 01 00 00 00       	mov    $0x1,%eax
f0103800:	ee                   	out    %al,(%dx)
f0103801:	ba 20 00 00 00       	mov    $0x20,%edx
f0103806:	b8 68 00 00 00       	mov    $0x68,%eax
f010380b:	ee                   	out    %al,(%dx)
f010380c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103811:	ee                   	out    %al,(%dx)
f0103812:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103817:	b8 68 00 00 00       	mov    $0x68,%eax
f010381c:	ee                   	out    %al,(%dx)
f010381d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103822:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103823:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010382a:	66 83 f8 ff          	cmp    $0xffff,%ax
f010382e:	74 13                	je     f0103843 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103830:	55                   	push   %ebp
f0103831:	89 e5                	mov    %esp,%ebp
f0103833:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103836:	0f b7 c0             	movzwl %ax,%eax
f0103839:	50                   	push   %eax
f010383a:	e8 ee fe ff ff       	call   f010372d <irq_setmask_8259A>
f010383f:	83 c4 10             	add    $0x10,%esp
}
f0103842:	c9                   	leave  
f0103843:	f3 c3                	repz ret 

f0103845 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103845:	55                   	push   %ebp
f0103846:	89 e5                	mov    %esp,%ebp
f0103848:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010384b:	ff 75 08             	pushl  0x8(%ebp)
f010384e:	e8 6d cf ff ff       	call   f01007c0 <cputchar>
	*cnt++;
}
f0103853:	83 c4 10             	add    $0x10,%esp
f0103856:	c9                   	leave  
f0103857:	c3                   	ret    

f0103858 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103858:	55                   	push   %ebp
f0103859:	89 e5                	mov    %esp,%ebp
f010385b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010385e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103865:	ff 75 0c             	pushl  0xc(%ebp)
f0103868:	ff 75 08             	pushl  0x8(%ebp)
f010386b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010386e:	50                   	push   %eax
f010386f:	68 45 38 10 f0       	push   $0xf0103845
f0103874:	e8 74 13 00 00       	call   f0104bed <vprintfmt>
	return cnt;
}
f0103879:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010387c:	c9                   	leave  
f010387d:	c3                   	ret    

f010387e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010387e:	55                   	push   %ebp
f010387f:	89 e5                	mov    %esp,%ebp
f0103881:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103884:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103887:	50                   	push   %eax
f0103888:	ff 75 08             	pushl  0x8(%ebp)
f010388b:	e8 c8 ff ff ff       	call   f0103858 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103890:	c9                   	leave  
f0103891:	c3                   	ret    

f0103892 <trap_init_percpu>:
*/
// Initialize and load the per-CPU TSS and IDT

void
trap_init_percpu(void)
{
f0103892:	55                   	push   %ebp
f0103893:	89 e5                	mov    %esp,%ebp
f0103895:	57                   	push   %edi
f0103896:	56                   	push   %esi
f0103897:	53                   	push   %ebx
f0103898:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP-cpunum()*(KSTKSIZE+KSTKGAP);
f010389b:	e8 26 20 00 00       	call   f01058c6 <cpunum>
f01038a0:	89 c3                	mov    %eax,%ebx
f01038a2:	e8 1f 20 00 00       	call   f01058c6 <cpunum>
f01038a7:	6b db 74             	imul   $0x74,%ebx,%ebx
f01038aa:	c1 e0 10             	shl    $0x10,%eax
f01038ad:	89 c2                	mov    %eax,%edx
f01038af:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01038b4:	29 d0                	sub    %edx,%eax
f01038b6:	89 83 30 c0 22 f0    	mov    %eax,-0xfdd3fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038bc:	e8 05 20 00 00       	call   f01058c6 <cpunum>
f01038c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c4:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f01038cb:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038cd:	e8 f4 1f 00 00       	call   f01058c6 <cpunum>
f01038d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d5:	66 c7 80 92 c0 22 f0 	movw   $0x68,-0xfdd3f6e(%eax)
f01038dc:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01038de:	e8 e3 1f 00 00       	call   f01058c6 <cpunum>
f01038e3:	8d 58 05             	lea    0x5(%eax),%ebx
f01038e6:	e8 db 1f 00 00       	call   f01058c6 <cpunum>
f01038eb:	89 c7                	mov    %eax,%edi
f01038ed:	e8 d4 1f 00 00       	call   f01058c6 <cpunum>
f01038f2:	89 c6                	mov    %eax,%esi
f01038f4:	e8 cd 1f 00 00       	call   f01058c6 <cpunum>
f01038f9:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f0103900:	f0 67 00 
f0103903:	6b ff 74             	imul   $0x74,%edi,%edi
f0103906:	81 c7 2c c0 22 f0    	add    $0xf022c02c,%edi
f010390c:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103913:	f0 
f0103914:	6b d6 74             	imul   $0x74,%esi,%edx
f0103917:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f010391d:	c1 ea 10             	shr    $0x10,%edx
f0103920:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103927:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f010392e:	99 
f010392f:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103936:	40 
f0103937:	6b c0 74             	imul   $0x74,%eax,%eax
f010393a:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f010393f:	c1 e8 18             	shr    $0x18,%eax
f0103942:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+cpunum()].sd_s = 0;
f0103949:	e8 78 1f 00 00       	call   f01058c6 <cpunum>
f010394e:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f0103955:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(thiscpu->cpu_id<<3));//why do this?I cannot unstanderd.
f0103956:	e8 6b 1f 00 00       	call   f01058c6 <cpunum>
f010395b:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f010395e:	0f b6 80 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%eax
f0103965:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f010396c:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010396f:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103974:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
	*/
}
f0103977:	83 c4 0c             	add    $0xc,%esp
f010397a:	5b                   	pop    %ebx
f010397b:	5e                   	pop    %esi
f010397c:	5f                   	pop    %edi
f010397d:	5d                   	pop    %ebp
f010397e:	c3                   	ret    

f010397f <trap_init>:
}


void
trap_init(void)
{
f010397f:	55                   	push   %ebp
f0103980:	89 e5                	mov    %esp,%ebp
f0103982:	83 ec 08             	sub    $0x8,%esp
   	void t_align();
	void t_mchk();
	void t_simderr();
	void t_syscall();

	SETGATE(idt[T_DIVIDE],0,GD_KT,t_divide,0);
f0103985:	b8 52 41 10 f0       	mov    $0xf0104152,%eax
f010398a:	66 a3 60 b2 22 f0    	mov    %ax,0xf022b260
f0103990:	66 c7 05 62 b2 22 f0 	movw   $0x8,0xf022b262
f0103997:	08 00 
f0103999:	c6 05 64 b2 22 f0 00 	movb   $0x0,0xf022b264
f01039a0:	c6 05 65 b2 22 f0 8e 	movb   $0x8e,0xf022b265
f01039a7:	c1 e8 10             	shr    $0x10,%eax
f01039aa:	66 a3 66 b2 22 f0    	mov    %ax,0xf022b266
	SETGATE(idt[T_DEBUG],0,GD_KT,t_debug,0);
f01039b0:	b8 58 41 10 f0       	mov    $0xf0104158,%eax
f01039b5:	66 a3 68 b2 22 f0    	mov    %ax,0xf022b268
f01039bb:	66 c7 05 6a b2 22 f0 	movw   $0x8,0xf022b26a
f01039c2:	08 00 
f01039c4:	c6 05 6c b2 22 f0 00 	movb   $0x0,0xf022b26c
f01039cb:	c6 05 6d b2 22 f0 8e 	movb   $0x8e,0xf022b26d
f01039d2:	c1 e8 10             	shr    $0x10,%eax
f01039d5:	66 a3 6e b2 22 f0    	mov    %ax,0xf022b26e
//	SETGAET(idt[T_NMI],0,GD_KT,t_nmi,0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01039db:	b8 64 41 10 f0       	mov    $0xf0104164,%eax
f01039e0:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f01039e6:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f01039ed:	08 00 
f01039ef:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f01039f6:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f01039fd:	c1 e8 10             	shr    $0x10,%eax
f0103a00:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e
   	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0103a06:	b8 6a 41 10 f0       	mov    $0xf010416a,%eax
f0103a0b:	66 a3 80 b2 22 f0    	mov    %ax,0xf022b280
f0103a11:	66 c7 05 82 b2 22 f0 	movw   $0x8,0xf022b282
f0103a18:	08 00 
f0103a1a:	c6 05 84 b2 22 f0 00 	movb   $0x0,0xf022b284
f0103a21:	c6 05 85 b2 22 f0 8e 	movb   $0x8e,0xf022b285
f0103a28:	c1 e8 10             	shr    $0x10,%eax
f0103a2b:	66 a3 86 b2 22 f0    	mov    %ax,0xf022b286
        SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103a31:	b8 70 41 10 f0       	mov    $0xf0104170,%eax
f0103a36:	66 a3 88 b2 22 f0    	mov    %ax,0xf022b288
f0103a3c:	66 c7 05 8a b2 22 f0 	movw   $0x8,0xf022b28a
f0103a43:	08 00 
f0103a45:	c6 05 8c b2 22 f0 00 	movb   $0x0,0xf022b28c
f0103a4c:	c6 05 8d b2 22 f0 8e 	movb   $0x8e,0xf022b28d
f0103a53:	c1 e8 10             	shr    $0x10,%eax
f0103a56:	66 a3 8e b2 22 f0    	mov    %ax,0xf022b28e
        SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103a5c:	b8 76 41 10 f0       	mov    $0xf0104176,%eax
f0103a61:	66 a3 90 b2 22 f0    	mov    %ax,0xf022b290
f0103a67:	66 c7 05 92 b2 22 f0 	movw   $0x8,0xf022b292
f0103a6e:	08 00 
f0103a70:	c6 05 94 b2 22 f0 00 	movb   $0x0,0xf022b294
f0103a77:	c6 05 95 b2 22 f0 8e 	movb   $0x8e,0xf022b295
f0103a7e:	c1 e8 10             	shr    $0x10,%eax
f0103a81:	66 a3 96 b2 22 f0    	mov    %ax,0xf022b296
        SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103a87:	b8 7c 41 10 f0       	mov    $0xf010417c,%eax
f0103a8c:	66 a3 98 b2 22 f0    	mov    %ax,0xf022b298
f0103a92:	66 c7 05 9a b2 22 f0 	movw   $0x8,0xf022b29a
f0103a99:	08 00 
f0103a9b:	c6 05 9c b2 22 f0 00 	movb   $0x0,0xf022b29c
f0103aa2:	c6 05 9d b2 22 f0 8e 	movb   $0x8e,0xf022b29d
f0103aa9:	c1 e8 10             	shr    $0x10,%eax
f0103aac:	66 a3 9e b2 22 f0    	mov    %ax,0xf022b29e
   	 SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103ab2:	b8 82 41 10 f0       	mov    $0xf0104182,%eax
f0103ab7:	66 a3 a0 b2 22 f0    	mov    %ax,0xf022b2a0
f0103abd:	66 c7 05 a2 b2 22 f0 	movw   $0x8,0xf022b2a2
f0103ac4:	08 00 
f0103ac6:	c6 05 a4 b2 22 f0 00 	movb   $0x0,0xf022b2a4
f0103acd:	c6 05 a5 b2 22 f0 8e 	movb   $0x8e,0xf022b2a5
f0103ad4:	c1 e8 10             	shr    $0x10,%eax
f0103ad7:	66 a3 a6 b2 22 f0    	mov    %ax,0xf022b2a6
   	 SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103add:	b8 86 41 10 f0       	mov    $0xf0104186,%eax
f0103ae2:	66 a3 b0 b2 22 f0    	mov    %ax,0xf022b2b0
f0103ae8:	66 c7 05 b2 b2 22 f0 	movw   $0x8,0xf022b2b2
f0103aef:	08 00 
f0103af1:	c6 05 b4 b2 22 f0 00 	movb   $0x0,0xf022b2b4
f0103af8:	c6 05 b5 b2 22 f0 8e 	movb   $0x8e,0xf022b2b5
f0103aff:	c1 e8 10             	shr    $0x10,%eax
f0103b02:	66 a3 b6 b2 22 f0    	mov    %ax,0xf022b2b6
  	 SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103b08:	b8 8a 41 10 f0       	mov    $0xf010418a,%eax
f0103b0d:	66 a3 b8 b2 22 f0    	mov    %ax,0xf022b2b8
f0103b13:	66 c7 05 ba b2 22 f0 	movw   $0x8,0xf022b2ba
f0103b1a:	08 00 
f0103b1c:	c6 05 bc b2 22 f0 00 	movb   $0x0,0xf022b2bc
f0103b23:	c6 05 bd b2 22 f0 8e 	movb   $0x8e,0xf022b2bd
f0103b2a:	c1 e8 10             	shr    $0x10,%eax
f0103b2d:	66 a3 be b2 22 f0    	mov    %ax,0xf022b2be
   	 SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103b33:	b8 8e 41 10 f0       	mov    $0xf010418e,%eax
f0103b38:	66 a3 c0 b2 22 f0    	mov    %ax,0xf022b2c0
f0103b3e:	66 c7 05 c2 b2 22 f0 	movw   $0x8,0xf022b2c2
f0103b45:	08 00 
f0103b47:	c6 05 c4 b2 22 f0 00 	movb   $0x0,0xf022b2c4
f0103b4e:	c6 05 c5 b2 22 f0 8e 	movb   $0x8e,0xf022b2c5
f0103b55:	c1 e8 10             	shr    $0x10,%eax
f0103b58:	66 a3 c6 b2 22 f0    	mov    %ax,0xf022b2c6
   	 SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103b5e:	b8 92 41 10 f0       	mov    $0xf0104192,%eax
f0103b63:	66 a3 c8 b2 22 f0    	mov    %ax,0xf022b2c8
f0103b69:	66 c7 05 ca b2 22 f0 	movw   $0x8,0xf022b2ca
f0103b70:	08 00 
f0103b72:	c6 05 cc b2 22 f0 00 	movb   $0x0,0xf022b2cc
f0103b79:	c6 05 cd b2 22 f0 8e 	movb   $0x8e,0xf022b2cd
f0103b80:	c1 e8 10             	shr    $0x10,%eax
f0103b83:	66 a3 ce b2 22 f0    	mov    %ax,0xf022b2ce
   	 SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103b89:	b8 96 41 10 f0       	mov    $0xf0104196,%eax
f0103b8e:	66 a3 d0 b2 22 f0    	mov    %ax,0xf022b2d0
f0103b94:	66 c7 05 d2 b2 22 f0 	movw   $0x8,0xf022b2d2
f0103b9b:	08 00 
f0103b9d:	c6 05 d4 b2 22 f0 00 	movb   $0x0,0xf022b2d4
f0103ba4:	c6 05 d5 b2 22 f0 8e 	movb   $0x8e,0xf022b2d5
f0103bab:	c1 e8 10             	shr    $0x10,%eax
f0103bae:	66 a3 d6 b2 22 f0    	mov    %ax,0xf022b2d6
   	 SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103bb4:	b8 9a 41 10 f0       	mov    $0xf010419a,%eax
f0103bb9:	66 a3 e0 b2 22 f0    	mov    %ax,0xf022b2e0
f0103bbf:	66 c7 05 e2 b2 22 f0 	movw   $0x8,0xf022b2e2
f0103bc6:	08 00 
f0103bc8:	c6 05 e4 b2 22 f0 00 	movb   $0x0,0xf022b2e4
f0103bcf:	c6 05 e5 b2 22 f0 8e 	movb   $0x8e,0xf022b2e5
f0103bd6:	c1 e8 10             	shr    $0x10,%eax
f0103bd9:	66 a3 e6 b2 22 f0    	mov    %ax,0xf022b2e6
   	 SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103bdf:	b8 a0 41 10 f0       	mov    $0xf01041a0,%eax
f0103be4:	66 a3 e8 b2 22 f0    	mov    %ax,0xf022b2e8
f0103bea:	66 c7 05 ea b2 22 f0 	movw   $0x8,0xf022b2ea
f0103bf1:	08 00 
f0103bf3:	c6 05 ec b2 22 f0 00 	movb   $0x0,0xf022b2ec
f0103bfa:	c6 05 ed b2 22 f0 8e 	movb   $0x8e,0xf022b2ed
f0103c01:	c1 e8 10             	shr    $0x10,%eax
f0103c04:	66 a3 ee b2 22 f0    	mov    %ax,0xf022b2ee
   	 SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103c0a:	b8 a4 41 10 f0       	mov    $0xf01041a4,%eax
f0103c0f:	66 a3 f0 b2 22 f0    	mov    %ax,0xf022b2f0
f0103c15:	66 c7 05 f2 b2 22 f0 	movw   $0x8,0xf022b2f2
f0103c1c:	08 00 
f0103c1e:	c6 05 f4 b2 22 f0 00 	movb   $0x0,0xf022b2f4
f0103c25:	c6 05 f5 b2 22 f0 8e 	movb   $0x8e,0xf022b2f5
f0103c2c:	c1 e8 10             	shr    $0x10,%eax
f0103c2f:	66 a3 f6 b2 22 f0    	mov    %ax,0xf022b2f6
   	 SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103c35:	b8 aa 41 10 f0       	mov    $0xf01041aa,%eax
f0103c3a:	66 a3 f8 b2 22 f0    	mov    %ax,0xf022b2f8
f0103c40:	66 c7 05 fa b2 22 f0 	movw   $0x8,0xf022b2fa
f0103c47:	08 00 
f0103c49:	c6 05 fc b2 22 f0 00 	movb   $0x0,0xf022b2fc
f0103c50:	c6 05 fd b2 22 f0 8e 	movb   $0x8e,0xf022b2fd
f0103c57:	c1 e8 10             	shr    $0x10,%eax
f0103c5a:	66 a3 fe b2 22 f0    	mov    %ax,0xf022b2fe
   	 SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103c60:	b8 b0 41 10 f0       	mov    $0xf01041b0,%eax
f0103c65:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f0103c6b:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f0103c72:	08 00 
f0103c74:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f0103c7b:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f0103c82:	c1 e8 10             	shr    $0x10,%eax
f0103c85:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6
	// Per-CPU setup 
	trap_init_percpu();
f0103c8b:	e8 02 fc ff ff       	call   f0103892 <trap_init_percpu>
}
f0103c90:	c9                   	leave  
f0103c91:	c3                   	ret    

f0103c92 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c92:	55                   	push   %ebp
f0103c93:	89 e5                	mov    %esp,%ebp
f0103c95:	53                   	push   %ebx
f0103c96:	83 ec 0c             	sub    $0xc,%esp
f0103c99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c9c:	ff 33                	pushl  (%ebx)
f0103c9e:	68 f1 73 10 f0       	push   $0xf01073f1
f0103ca3:	e8 d6 fb ff ff       	call   f010387e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ca8:	83 c4 08             	add    $0x8,%esp
f0103cab:	ff 73 04             	pushl  0x4(%ebx)
f0103cae:	68 00 74 10 f0       	push   $0xf0107400
f0103cb3:	e8 c6 fb ff ff       	call   f010387e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103cb8:	83 c4 08             	add    $0x8,%esp
f0103cbb:	ff 73 08             	pushl  0x8(%ebx)
f0103cbe:	68 0f 74 10 f0       	push   $0xf010740f
f0103cc3:	e8 b6 fb ff ff       	call   f010387e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cc8:	83 c4 08             	add    $0x8,%esp
f0103ccb:	ff 73 0c             	pushl  0xc(%ebx)
f0103cce:	68 1e 74 10 f0       	push   $0xf010741e
f0103cd3:	e8 a6 fb ff ff       	call   f010387e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103cd8:	83 c4 08             	add    $0x8,%esp
f0103cdb:	ff 73 10             	pushl  0x10(%ebx)
f0103cde:	68 2d 74 10 f0       	push   $0xf010742d
f0103ce3:	e8 96 fb ff ff       	call   f010387e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103ce8:	83 c4 08             	add    $0x8,%esp
f0103ceb:	ff 73 14             	pushl  0x14(%ebx)
f0103cee:	68 3c 74 10 f0       	push   $0xf010743c
f0103cf3:	e8 86 fb ff ff       	call   f010387e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103cf8:	83 c4 08             	add    $0x8,%esp
f0103cfb:	ff 73 18             	pushl  0x18(%ebx)
f0103cfe:	68 4b 74 10 f0       	push   $0xf010744b
f0103d03:	e8 76 fb ff ff       	call   f010387e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103d08:	83 c4 08             	add    $0x8,%esp
f0103d0b:	ff 73 1c             	pushl  0x1c(%ebx)
f0103d0e:	68 5a 74 10 f0       	push   $0xf010745a
f0103d13:	e8 66 fb ff ff       	call   f010387e <cprintf>
}
f0103d18:	83 c4 10             	add    $0x10,%esp
f0103d1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d1e:	c9                   	leave  
f0103d1f:	c3                   	ret    

f0103d20 <print_trapframe>:
	*/
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d20:	55                   	push   %ebp
f0103d21:	89 e5                	mov    %esp,%ebp
f0103d23:	56                   	push   %esi
f0103d24:	53                   	push   %ebx
f0103d25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d28:	e8 99 1b 00 00       	call   f01058c6 <cpunum>
f0103d2d:	83 ec 04             	sub    $0x4,%esp
f0103d30:	50                   	push   %eax
f0103d31:	53                   	push   %ebx
f0103d32:	68 be 74 10 f0       	push   $0xf01074be
f0103d37:	e8 42 fb ff ff       	call   f010387e <cprintf>
	print_regs(&tf->tf_regs);
f0103d3c:	89 1c 24             	mov    %ebx,(%esp)
f0103d3f:	e8 4e ff ff ff       	call   f0103c92 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d44:	83 c4 08             	add    $0x8,%esp
f0103d47:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d4b:	50                   	push   %eax
f0103d4c:	68 dc 74 10 f0       	push   $0xf01074dc
f0103d51:	e8 28 fb ff ff       	call   f010387e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d56:	83 c4 08             	add    $0x8,%esp
f0103d59:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d5d:	50                   	push   %eax
f0103d5e:	68 ef 74 10 f0       	push   $0xf01074ef
f0103d63:	e8 16 fb ff ff       	call   f010387e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d68:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103d6b:	83 c4 10             	add    $0x10,%esp
f0103d6e:	83 f8 13             	cmp    $0x13,%eax
f0103d71:	77 09                	ja     f0103d7c <print_trapframe+0x5c>
		return excnames[trapno];
f0103d73:	8b 14 85 a0 77 10 f0 	mov    -0xfef8860(,%eax,4),%edx
f0103d7a:	eb 1f                	jmp    f0103d9b <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103d7c:	83 f8 30             	cmp    $0x30,%eax
f0103d7f:	74 15                	je     f0103d96 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103d81:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103d84:	83 fa 10             	cmp    $0x10,%edx
f0103d87:	b9 88 74 10 f0       	mov    $0xf0107488,%ecx
f0103d8c:	ba 75 74 10 f0       	mov    $0xf0107475,%edx
f0103d91:	0f 43 d1             	cmovae %ecx,%edx
f0103d94:	eb 05                	jmp    f0103d9b <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103d96:	ba 69 74 10 f0       	mov    $0xf0107469,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d9b:	83 ec 04             	sub    $0x4,%esp
f0103d9e:	52                   	push   %edx
f0103d9f:	50                   	push   %eax
f0103da0:	68 02 75 10 f0       	push   $0xf0107502
f0103da5:	e8 d4 fa ff ff       	call   f010387e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103daa:	83 c4 10             	add    $0x10,%esp
f0103dad:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0103db3:	75 1a                	jne    f0103dcf <print_trapframe+0xaf>
f0103db5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103db9:	75 14                	jne    f0103dcf <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103dbb:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103dbe:	83 ec 08             	sub    $0x8,%esp
f0103dc1:	50                   	push   %eax
f0103dc2:	68 14 75 10 f0       	push   $0xf0107514
f0103dc7:	e8 b2 fa ff ff       	call   f010387e <cprintf>
f0103dcc:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103dcf:	83 ec 08             	sub    $0x8,%esp
f0103dd2:	ff 73 2c             	pushl  0x2c(%ebx)
f0103dd5:	68 23 75 10 f0       	push   $0xf0107523
f0103dda:	e8 9f fa ff ff       	call   f010387e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103ddf:	83 c4 10             	add    $0x10,%esp
f0103de2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103de6:	75 49                	jne    f0103e31 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103de8:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103deb:	89 c2                	mov    %eax,%edx
f0103ded:	83 e2 01             	and    $0x1,%edx
f0103df0:	ba a2 74 10 f0       	mov    $0xf01074a2,%edx
f0103df5:	b9 97 74 10 f0       	mov    $0xf0107497,%ecx
f0103dfa:	0f 44 ca             	cmove  %edx,%ecx
f0103dfd:	89 c2                	mov    %eax,%edx
f0103dff:	83 e2 02             	and    $0x2,%edx
f0103e02:	ba b4 74 10 f0       	mov    $0xf01074b4,%edx
f0103e07:	be ae 74 10 f0       	mov    $0xf01074ae,%esi
f0103e0c:	0f 45 d6             	cmovne %esi,%edx
f0103e0f:	83 e0 04             	and    $0x4,%eax
f0103e12:	be ee 75 10 f0       	mov    $0xf01075ee,%esi
f0103e17:	b8 b9 74 10 f0       	mov    $0xf01074b9,%eax
f0103e1c:	0f 44 c6             	cmove  %esi,%eax
f0103e1f:	51                   	push   %ecx
f0103e20:	52                   	push   %edx
f0103e21:	50                   	push   %eax
f0103e22:	68 31 75 10 f0       	push   $0xf0107531
f0103e27:	e8 52 fa ff ff       	call   f010387e <cprintf>
f0103e2c:	83 c4 10             	add    $0x10,%esp
f0103e2f:	eb 10                	jmp    f0103e41 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e31:	83 ec 0c             	sub    $0xc,%esp
f0103e34:	68 24 63 10 f0       	push   $0xf0106324
f0103e39:	e8 40 fa ff ff       	call   f010387e <cprintf>
f0103e3e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e41:	83 ec 08             	sub    $0x8,%esp
f0103e44:	ff 73 30             	pushl  0x30(%ebx)
f0103e47:	68 40 75 10 f0       	push   $0xf0107540
f0103e4c:	e8 2d fa ff ff       	call   f010387e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e51:	83 c4 08             	add    $0x8,%esp
f0103e54:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e58:	50                   	push   %eax
f0103e59:	68 4f 75 10 f0       	push   $0xf010754f
f0103e5e:	e8 1b fa ff ff       	call   f010387e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e63:	83 c4 08             	add    $0x8,%esp
f0103e66:	ff 73 38             	pushl  0x38(%ebx)
f0103e69:	68 62 75 10 f0       	push   $0xf0107562
f0103e6e:	e8 0b fa ff ff       	call   f010387e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e73:	83 c4 10             	add    $0x10,%esp
f0103e76:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e7a:	74 25                	je     f0103ea1 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e7c:	83 ec 08             	sub    $0x8,%esp
f0103e7f:	ff 73 3c             	pushl  0x3c(%ebx)
f0103e82:	68 71 75 10 f0       	push   $0xf0107571
f0103e87:	e8 f2 f9 ff ff       	call   f010387e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e8c:	83 c4 08             	add    $0x8,%esp
f0103e8f:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e93:	50                   	push   %eax
f0103e94:	68 80 75 10 f0       	push   $0xf0107580
f0103e99:	e8 e0 f9 ff ff       	call   f010387e <cprintf>
f0103e9e:	83 c4 10             	add    $0x10,%esp
	}
}
f0103ea1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ea4:	5b                   	pop    %ebx
f0103ea5:	5e                   	pop    %esi
f0103ea6:	5d                   	pop    %ebp
f0103ea7:	c3                   	ret    

f0103ea8 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ea8:	55                   	push   %ebp
f0103ea9:	89 e5                	mov    %esp,%ebp
f0103eab:	57                   	push   %edi
f0103eac:	56                   	push   %esi
f0103ead:	53                   	push   %ebx
f0103eae:	83 ec 18             	sub    $0x18,%esp
f0103eb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103eb4:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	print_trapframe(tf);
f0103eb7:	53                   	push   %ebx
f0103eb8:	e8 63 fe ff ff       	call   f0103d20 <print_trapframe>
	if ((tf->tf_cs&3) == 0)
f0103ebd:	83 c4 10             	add    $0x10,%esp
f0103ec0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103ec4:	75 17                	jne    f0103edd <page_fault_handler+0x35>
		panic("a page fault happens in kernel [eip:%x]", tf->tf_eip);
f0103ec6:	ff 73 30             	pushl  0x30(%ebx)
f0103ec9:	68 38 77 10 f0       	push   $0xf0107738
f0103ece:	68 ee 01 00 00       	push   $0x1ee
f0103ed3:	68 93 75 10 f0       	push   $0xf0107593
f0103ed8:	e8 b7 c1 ff ff       	call   f0100094 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
f0103edd:	83 ec 0c             	sub    $0xc,%esp
f0103ee0:	53                   	push   %ebx
f0103ee1:	e8 3a fe ff ff       	call   f0103d20 <print_trapframe>
	env_destroy(curenv);
f0103ee6:	e8 db 19 00 00       	call   f01058c6 <cpunum>
f0103eeb:	83 c4 04             	add    $0x4,%esp
f0103eee:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ef1:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103ef7:	e8 c5 f6 ff ff       	call   f01035c1 <env_destroy>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103efc:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103eff:	e8 c2 19 00 00       	call   f01058c6 <cpunum>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f04:	57                   	push   %edi
f0103f05:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103f06:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103f09:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103f0f:	ff 70 48             	pushl  0x48(%eax)
f0103f12:	68 60 77 10 f0       	push   $0xf0107760
f0103f17:	e8 62 f9 ff ff       	call   f010387e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103f1c:	83 c4 14             	add    $0x14,%esp
f0103f1f:	53                   	push   %ebx
f0103f20:	e8 fb fd ff ff       	call   f0103d20 <print_trapframe>
	env_destroy(curenv);
f0103f25:	e8 9c 19 00 00       	call   f01058c6 <cpunum>
f0103f2a:	83 c4 04             	add    $0x4,%esp
f0103f2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f30:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103f36:	e8 86 f6 ff ff       	call   f01035c1 <env_destroy>
}
f0103f3b:	83 c4 10             	add    $0x10,%esp
f0103f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f41:	5b                   	pop    %ebx
f0103f42:	5e                   	pop    %esi
f0103f43:	5f                   	pop    %edi
f0103f44:	5d                   	pop    %ebp
f0103f45:	c3                   	ret    

f0103f46 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103f46:	55                   	push   %ebp
f0103f47:	89 e5                	mov    %esp,%ebp
f0103f49:	57                   	push   %edi
f0103f4a:	56                   	push   %esi
f0103f4b:	8b 75 08             	mov    0x8(%ebp),%esi

	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f4e:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103f4f:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0103f56:	74 01                	je     f0103f59 <trap+0x13>
		asm volatile("hlt");
f0103f58:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103f59:	e8 68 19 00 00       	call   f01058c6 <cpunum>
f0103f5e:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f61:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0103f67:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f6c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103f70:	83 f8 02             	cmp    $0x2,%eax
f0103f73:	75 10                	jne    f0103f85 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103f75:	83 ec 0c             	sub    $0xc,%esp
f0103f78:	68 c0 03 12 f0       	push   $0xf01203c0
f0103f7d:	e8 b2 1b 00 00       	call   f0105b34 <spin_lock>
f0103f82:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103f85:	9c                   	pushf  
f0103f86:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f87:	f6 c4 02             	test   $0x2,%ah
f0103f8a:	74 19                	je     f0103fa5 <trap+0x5f>
f0103f8c:	68 9f 75 10 f0       	push   $0xf010759f
f0103f91:	68 87 6f 10 f0       	push   $0xf0106f87
f0103f96:	68 b4 01 00 00       	push   $0x1b4
f0103f9b:	68 93 75 10 f0       	push   $0xf0107593
f0103fa0:	e8 ef c0 ff ff       	call   f0100094 <_panic>
//cprintf("tf.tf_regs.reg_eax:%d\n",tf->tf_regs.reg_eax);
	if ((tf->tf_cs & 3) == 3) {
f0103fa5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103fa9:	83 e0 03             	and    $0x3,%eax
f0103fac:	66 83 f8 03          	cmp    $0x3,%ax
f0103fb0:	0f 85 a0 00 00 00    	jne    f0104056 <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103fb6:	e8 0b 19 00 00       	call   f01058c6 <cpunum>
f0103fbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fbe:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103fc5:	75 19                	jne    f0103fe0 <trap+0x9a>
f0103fc7:	68 b8 75 10 f0       	push   $0xf01075b8
f0103fcc:	68 87 6f 10 f0       	push   $0xf0106f87
f0103fd1:	68 bb 01 00 00       	push   $0x1bb
f0103fd6:	68 93 75 10 f0       	push   $0xf0107593
f0103fdb:	e8 b4 c0 ff ff       	call   f0100094 <_panic>
f0103fe0:	83 ec 0c             	sub    $0xc,%esp
f0103fe3:	68 c0 03 12 f0       	push   $0xf01203c0
f0103fe8:	e8 47 1b 00 00       	call   f0105b34 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103fed:	e8 d4 18 00 00       	call   f01058c6 <cpunum>
f0103ff2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103ffb:	83 c4 10             	add    $0x10,%esp
f0103ffe:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104002:	75 2d                	jne    f0104031 <trap+0xeb>
			env_free(curenv);
f0104004:	e8 bd 18 00 00       	call   f01058c6 <cpunum>
f0104009:	83 ec 0c             	sub    $0xc,%esp
f010400c:	6b c0 74             	imul   $0x74,%eax,%eax
f010400f:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104015:	e8 cc f3 ff ff       	call   f01033e6 <env_free>
			curenv = NULL;
f010401a:	e8 a7 18 00 00       	call   f01058c6 <cpunum>
f010401f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104022:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104029:	00 00 00 
			sched_yield();
f010402c:	e8 69 02 00 00       	call   f010429a <sched_yield>
		}
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104031:	e8 90 18 00 00       	call   f01058c6 <cpunum>
f0104036:	6b c0 74             	imul   $0x74,%eax,%eax
f0104039:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010403f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104044:	89 c7                	mov    %eax,%edi
f0104046:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104048:	e8 79 18 00 00       	call   f01058c6 <cpunum>
f010404d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104050:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104056:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010405c:	8b 46 28             	mov    0x28(%esi),%eax
f010405f:	83 f8 27             	cmp    $0x27,%eax
f0104062:	75 1d                	jne    f0104081 <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0104064:	83 ec 0c             	sub    $0xc,%esp
f0104067:	68 bf 75 10 f0       	push   $0xf01075bf
f010406c:	e8 0d f8 ff ff       	call   f010387e <cprintf>
		print_trapframe(tf);
f0104071:	89 34 24             	mov    %esi,(%esp)
f0104074:	e8 a7 fc ff ff       	call   f0103d20 <print_trapframe>
f0104079:	83 c4 10             	add    $0x10,%esp
f010407c:	e9 91 00 00 00       	jmp    f0104112 <trap+0x1cc>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	switch(tf->tf_trapno){
f0104081:	83 f8 0e             	cmp    $0xe,%eax
f0104084:	74 0c                	je     f0104092 <trap+0x14c>
f0104086:	83 f8 30             	cmp    $0x30,%eax
f0104089:	74 23                	je     f01040ae <trap+0x168>
f010408b:	83 f8 03             	cmp    $0x3,%eax
f010408e:	75 3f                	jne    f01040cf <trap+0x189>
f0104090:	eb 0e                	jmp    f01040a0 <trap+0x15a>
		case T_PGFLT:
			page_fault_handler(tf);
f0104092:	83 ec 0c             	sub    $0xc,%esp
f0104095:	56                   	push   %esi
f0104096:	e8 0d fe ff ff       	call   f0103ea8 <page_fault_handler>
f010409b:	83 c4 10             	add    $0x10,%esp
f010409e:	eb 72                	jmp    f0104112 <trap+0x1cc>
			return;
		case T_BRKPT:
			//cprintf("Function:trap_dispatch()->T_BRKPT.\n");
			monitor(tf);
f01040a0:	83 ec 0c             	sub    $0xc,%esp
f01040a3:	56                   	push   %esi
f01040a4:	e8 aa c8 ff ff       	call   f0100953 <monitor>
f01040a9:	83 c4 10             	add    $0x10,%esp
f01040ac:	eb 64                	jmp    f0104112 <trap+0x1cc>
			return;
		case T_SYSCALL:
			//cprintf("Function:trap_dispatch()->T_SYSCALL.\n");
			tf->tf_regs.reg_eax = syscall(
f01040ae:	83 ec 08             	sub    $0x8,%esp
f01040b1:	ff 76 04             	pushl  0x4(%esi)
f01040b4:	ff 36                	pushl  (%esi)
f01040b6:	ff 76 10             	pushl  0x10(%esi)
f01040b9:	ff 76 18             	pushl  0x18(%esi)
f01040bc:	ff 76 14             	pushl  0x14(%esi)
f01040bf:	ff 76 1c             	pushl  0x1c(%esi)
f01040c2:	e8 da 02 00 00       	call   f01043a1 <syscall>
f01040c7:	89 46 1c             	mov    %eax,0x1c(%esi)
f01040ca:	83 c4 20             	add    $0x20,%esp
f01040cd:	eb 43                	jmp    f0104112 <trap+0x1cc>
       				 tf->tf_regs.reg_esi
   			 );
  			  return;
		default:break;
	}
	print_trapframe(tf);
f01040cf:	83 ec 0c             	sub    $0xc,%esp
f01040d2:	56                   	push   %esi
f01040d3:	e8 48 fc ff ff       	call   f0103d20 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01040d8:	83 c4 10             	add    $0x10,%esp
f01040db:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01040e0:	75 17                	jne    f01040f9 <trap+0x1b3>
		panic("unhandled trap in kernel");
f01040e2:	83 ec 04             	sub    $0x4,%esp
f01040e5:	68 dc 75 10 f0       	push   $0xf01075dc
f01040ea:	68 99 01 00 00       	push   $0x199
f01040ef:	68 93 75 10 f0       	push   $0xf0107593
f01040f4:	e8 9b bf ff ff       	call   f0100094 <_panic>
	else {
		env_destroy(curenv);
f01040f9:	e8 c8 17 00 00       	call   f01058c6 <cpunum>
f01040fe:	83 ec 0c             	sub    $0xc,%esp
f0104101:	6b c0 74             	imul   $0x74,%eax,%eax
f0104104:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010410a:	e8 b2 f4 ff ff       	call   f01035c1 <env_destroy>
f010410f:	83 c4 10             	add    $0x10,%esp


	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104112:	e8 af 17 00 00       	call   f01058c6 <cpunum>
f0104117:	6b c0 74             	imul   $0x74,%eax,%eax
f010411a:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104121:	74 2a                	je     f010414d <trap+0x207>
f0104123:	e8 9e 17 00 00       	call   f01058c6 <cpunum>
f0104128:	6b c0 74             	imul   $0x74,%eax,%eax
f010412b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104131:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104135:	75 16                	jne    f010414d <trap+0x207>
		env_run(curenv);
f0104137:	e8 8a 17 00 00       	call   f01058c6 <cpunum>
f010413c:	83 ec 0c             	sub    $0xc,%esp
f010413f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104142:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104148:	e8 13 f5 ff ff       	call   f0103660 <env_run>
	else
		sched_yield();
f010414d:	e8 48 01 00 00       	call   f010429a <sched_yield>

f0104152 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f0104152:	6a 00                	push   $0x0
f0104154:	6a 00                	push   $0x0
f0104156:	eb 5e                	jmp    f01041b6 <_alltraps>

f0104158 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);        // 1
f0104158:	6a 00                	push   $0x0
f010415a:	6a 01                	push   $0x1
f010415c:	eb 58                	jmp    f01041b6 <_alltraps>

f010415e <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);            // 2
f010415e:	6a 00                	push   $0x0
f0104160:	6a 02                	push   $0x2
f0104162:	eb 52                	jmp    f01041b6 <_alltraps>

f0104164 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)        // 3
f0104164:	6a 00                	push   $0x0
f0104166:	6a 03                	push   $0x3
f0104168:	eb 4c                	jmp    f01041b6 <_alltraps>

f010416a <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)        // 4
f010416a:	6a 00                	push   $0x0
f010416c:	6a 04                	push   $0x4
f010416e:	eb 46                	jmp    f01041b6 <_alltraps>

f0104170 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)        // 5
f0104170:	6a 00                	push   $0x0
f0104172:	6a 05                	push   $0x5
f0104174:	eb 40                	jmp    f01041b6 <_alltraps>

f0104176 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)        // 6
f0104176:	6a 00                	push   $0x0
f0104178:	6a 06                	push   $0x6
f010417a:	eb 3a                	jmp    f01041b6 <_alltraps>

f010417c <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)    // 7
f010417c:	6a 00                	push   $0x0
f010417e:	6a 07                	push   $0x7
f0104180:	eb 34                	jmp    f01041b6 <_alltraps>

f0104182 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)            // 8
f0104182:	6a 08                	push   $0x8
f0104184:	eb 30                	jmp    f01041b6 <_alltraps>

f0104186 <t_tss>:
                                        // 9
TRAPHANDLER(t_tss, T_TSS)                // 10
f0104186:	6a 0a                	push   $0xa
f0104188:	eb 2c                	jmp    f01041b6 <_alltraps>

f010418a <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)            // 11
f010418a:	6a 0b                	push   $0xb
f010418c:	eb 28                	jmp    f01041b6 <_alltraps>

f010418e <t_stack>:
TRAPHANDLER(t_stack, T_STACK)            // 12
f010418e:	6a 0c                	push   $0xc
f0104190:	eb 24                	jmp    f01041b6 <_alltraps>

f0104192 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)            // 13
f0104192:	6a 0d                	push   $0xd
f0104194:	eb 20                	jmp    f01041b6 <_alltraps>

f0104196 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)            // 14
f0104196:	6a 0e                	push   $0xe
f0104198:	eb 1c                	jmp    f01041b6 <_alltraps>

f010419a <t_fperr>:
                                        // 15
TRAPHANDLER_NOEC(t_fperr, T_FPERR)        // 16
f010419a:	6a 00                	push   $0x0
f010419c:	6a 10                	push   $0x10
f010419e:	eb 16                	jmp    f01041b6 <_alltraps>

f01041a0 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)            // 17
f01041a0:	6a 11                	push   $0x11
f01041a2:	eb 12                	jmp    f01041b6 <_alltraps>

f01041a4 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)        // 18
f01041a4:	6a 00                	push   $0x0
f01041a6:	6a 12                	push   $0x12
f01041a8:	eb 0c                	jmp    f01041b6 <_alltraps>

f01041aa <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)    // 19
f01041aa:	6a 00                	push   $0x0
f01041ac:	6a 13                	push   $0x13
f01041ae:	eb 06                	jmp    f01041b6 <_alltraps>

f01041b0 <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01041b0:	6a 00                	push   $0x0
f01041b2:	6a 30                	push   $0x30
f01041b4:	eb 00                	jmp    f01041b6 <_alltraps>

f01041b6 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01041b6:	1e                   	push   %ds
	pushl %es
f01041b7:	06                   	push   %es
	pushal
f01041b8:	60                   	pusha  

	movw $GD_KD,%eax
f01041b9:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax,%ds
f01041bd:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f01041bf:	8e c0                	mov    %eax,%es

	pushl %esp
f01041c1:	54                   	push   %esp
	call trap
f01041c2:	e8 7f fd ff ff       	call   f0103f46 <trap>

f01041c7 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01041c7:	55                   	push   %ebp
f01041c8:	89 e5                	mov    %esp,%ebp
f01041ca:	83 ec 08             	sub    $0x8,%esp
f01041cd:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01041d2:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041d5:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01041da:	8b 02                	mov    (%edx),%eax
f01041dc:	83 e8 01             	sub    $0x1,%eax
f01041df:	83 f8 02             	cmp    $0x2,%eax
f01041e2:	76 10                	jbe    f01041f4 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041e4:	83 c1 01             	add    $0x1,%ecx
f01041e7:	83 c2 7c             	add    $0x7c,%edx
f01041ea:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041f0:	75 e8                	jne    f01041da <sched_halt+0x13>
f01041f2:	eb 08                	jmp    f01041fc <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01041f4:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041fa:	75 1f                	jne    f010421b <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01041fc:	83 ec 0c             	sub    $0xc,%esp
f01041ff:	68 f0 77 10 f0       	push   $0xf01077f0
f0104204:	e8 75 f6 ff ff       	call   f010387e <cprintf>
f0104209:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f010420c:	83 ec 0c             	sub    $0xc,%esp
f010420f:	6a 00                	push   $0x0
f0104211:	e8 3d c7 ff ff       	call   f0100953 <monitor>
f0104216:	83 c4 10             	add    $0x10,%esp
f0104219:	eb f1                	jmp    f010420c <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010421b:	e8 a6 16 00 00       	call   f01058c6 <cpunum>
f0104220:	6b c0 74             	imul   $0x74,%eax,%eax
f0104223:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f010422a:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010422d:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104232:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104237:	77 12                	ja     f010424b <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104239:	50                   	push   %eax
f010423a:	68 38 60 10 f0       	push   $0xf0106038
f010423f:	6a 69                	push   $0x69
f0104241:	68 19 78 10 f0       	push   $0xf0107819
f0104246:	e8 49 be ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010424b:	05 00 00 00 10       	add    $0x10000000,%eax
f0104250:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104253:	e8 6e 16 00 00       	call   f01058c6 <cpunum>
f0104258:	6b d0 74             	imul   $0x74,%eax,%edx
f010425b:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104261:	b8 02 00 00 00       	mov    $0x2,%eax
f0104266:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010426a:	83 ec 0c             	sub    $0xc,%esp
f010426d:	68 c0 03 12 f0       	push   $0xf01203c0
f0104272:	e8 5a 19 00 00       	call   f0105bd1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104277:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104279:	e8 48 16 00 00       	call   f01058c6 <cpunum>
f010427e:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104281:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104287:	bd 00 00 00 00       	mov    $0x0,%ebp
f010428c:	89 c4                	mov    %eax,%esp
f010428e:	6a 00                	push   $0x0
f0104290:	6a 00                	push   $0x0
f0104292:	f4                   	hlt    
f0104293:	eb fd                	jmp    f0104292 <sched_halt+0xcb>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104295:	83 c4 10             	add    $0x10,%esp
f0104298:	c9                   	leave  
f0104299:	c3                   	ret    

f010429a <sched_yield>:
};
*/
// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010429a:	55                   	push   %ebp
f010429b:	89 e5                	mov    %esp,%ebp
f010429d:	57                   	push   %edi
f010429e:	56                   	push   %esi
f010429f:	53                   	push   %ebx
f01042a0:	83 ec 18             	sub    $0x18,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
f01042a3:	68 26 78 10 f0       	push   $0xf0107826
f01042a8:	e8 d1 f5 ff ff       	call   f010387e <cprintf>
	int running_env_id = -1;
	if(curenv == 0){
f01042ad:	e8 14 16 00 00       	call   f01058c6 <cpunum>
f01042b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01042b5:	83 c4 10             	add    $0x10,%esp
		running_env_id = -1;
f01042b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
	int running_env_id = -1;
	if(curenv == 0){
f01042bd:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01042c4:	74 17                	je     f01042dd <sched_yield+0x43>
		running_env_id = -1;
	}else{
		running_env_id = ENVX(curenv->env_id);
f01042c6:	e8 fb 15 00 00       	call   f01058c6 <cpunum>
f01042cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ce:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01042d4:	8b 58 48             	mov    0x48(%eax),%ebx
f01042d7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	}
	cprintf("The running_env_id is:%d\n",running_env_id);
f01042dd:	83 ec 08             	sub    $0x8,%esp
f01042e0:	53                   	push   %ebx
f01042e1:	68 3c 78 10 f0       	push   $0xf010783c
f01042e6:	e8 93 f5 ff ff       	call   f010387e <cprintf>

		if(running_env_id == NENV-1)running_env_id = 0;
		else{
			running_env_id++;
		}
		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f01042eb:	8b 0d 44 b2 22 f0    	mov    0xf022b244,%ecx
f01042f1:	83 c4 10             	add    $0x10,%esp
		running_env_id = -1;
	}else{
		running_env_id = ENVX(curenv->env_id);
	}
	cprintf("The running_env_id is:%d\n",running_env_id);
	for(int i = 0;i<NENV;i++){
f01042f4:	be 00 00 00 00       	mov    $0x0,%esi

		if(running_env_id == NENV-1)running_env_id = 0;
		else{
			running_env_id++;
f01042f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01042fe:	8d 43 01             	lea    0x1(%ebx),%eax
f0104301:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f0104307:	0f 44 c2             	cmove  %edx,%eax
f010430a:	89 c3                	mov    %eax,%ebx
		}
		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f010430c:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010430f:	89 c7                	mov    %eax,%edi
f0104311:	83 7c 01 54 02       	cmpl   $0x2,0x54(%ecx,%eax,1)
f0104316:	75 29                	jne    f0104341 <sched_yield+0xa7>
			;;;
			cprintf("shed_yield():WE ARE RUNNING.\n");
f0104318:	83 ec 0c             	sub    $0xc,%esp
f010431b:	68 56 78 10 f0       	push   $0xf0107856
f0104320:	e8 59 f5 ff ff       	call   f010387e <cprintf>
			cprintf("the running i is:%d\n",i);
f0104325:	83 c4 08             	add    $0x8,%esp
f0104328:	56                   	push   %esi
f0104329:	68 74 78 10 f0       	push   $0xf0107874
f010432e:	e8 4b f5 ff ff       	call   f010387e <cprintf>
			env_run(&envs[running_env_id]);			
f0104333:	03 3d 44 b2 22 f0    	add    0xf022b244,%edi
f0104339:	89 3c 24             	mov    %edi,(%esp)
f010433c:	e8 1f f3 ff ff       	call   f0103660 <env_run>
		running_env_id = -1;
	}else{
		running_env_id = ENVX(curenv->env_id);
	}
	cprintf("The running_env_id is:%d\n",running_env_id);
	for(int i = 0;i<NENV;i++){
f0104341:	83 c6 01             	add    $0x1,%esi
f0104344:	81 fe 00 04 00 00    	cmp    $0x400,%esi
f010434a:	75 b2                	jne    f01042fe <sched_yield+0x64>
	}
	//if the code run here,it says that there is only one env which is
	//running but now and here we are in kern mode,so if we don't chose
	//the running env to run we will trap in sched_halt().AND WE ARE AT
	//KERNEL MODE!
	if(curenv && curenv->env_status == ENV_RUNNING){
f010434c:	e8 75 15 00 00       	call   f01058c6 <cpunum>
f0104351:	6b c0 74             	imul   $0x74,%eax,%eax
f0104354:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010435b:	74 37                	je     f0104394 <sched_yield+0xfa>
f010435d:	e8 64 15 00 00       	call   f01058c6 <cpunum>
f0104362:	6b c0 74             	imul   $0x74,%eax,%eax
f0104365:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010436b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010436f:	75 23                	jne    f0104394 <sched_yield+0xfa>
		cprintf("I AM THE ONLY ONE ENV.\n");
f0104371:	83 ec 0c             	sub    $0xc,%esp
f0104374:	68 89 78 10 f0       	push   $0xf0107889
f0104379:	e8 00 f5 ff ff       	call   f010387e <cprintf>
		env_run(curenv);
f010437e:	e8 43 15 00 00       	call   f01058c6 <cpunum>
f0104383:	83 c4 04             	add    $0x4,%esp
f0104386:	6b c0 74             	imul   $0x74,%eax,%eax
f0104389:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010438f:	e8 cc f2 ff ff       	call   f0103660 <env_run>
		return;
	}
	// sched_halt never returns
	sched_halt();
f0104394:	e8 2e fe ff ff       	call   f01041c7 <sched_halt>
}
f0104399:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010439c:	5b                   	pop    %ebx
f010439d:	5e                   	pop    %esi
f010439e:	5f                   	pop    %edi
f010439f:	5d                   	pop    %ebp
f01043a0:	c3                   	ret    

f01043a1 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01043a1:	55                   	push   %ebp
f01043a2:	89 e5                	mov    %esp,%ebp
f01043a4:	53                   	push   %ebx
f01043a5:	83 ec 14             	sub    $0x14,%esp
f01043a8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
f01043ab:	83 f8 0a             	cmp    $0xa,%eax
f01043ae:	0f 87 46 04 00 00    	ja     f01047fa <syscall+0x459>
f01043b4:	ff 24 85 fc 78 10 f0 	jmp    *-0xfef8704(,%eax,4)
	// LAB 3: Your code here.


	struct Env *e;
	//envid2env(sys_getenvid(), &e, 1);
	user_mem_assert(curenv, s, len, PTE_U);
f01043bb:	e8 06 15 00 00       	call   f01058c6 <cpunum>
f01043c0:	6a 04                	push   $0x4
f01043c2:	ff 75 10             	pushl  0x10(%ebp)
f01043c5:	ff 75 0c             	pushl  0xc(%ebp)
f01043c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043cb:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01043d1:	e8 bf ea ff ff       	call   f0102e95 <user_mem_assert>

	cprintf("%.*s", len, s);
f01043d6:	83 c4 0c             	add    $0xc,%esp
f01043d9:	ff 75 0c             	pushl  0xc(%ebp)
f01043dc:	ff 75 10             	pushl  0x10(%ebp)
f01043df:	68 a1 78 10 f0       	push   $0xf01078a1
f01043e4:	e8 95 f4 ff ff       	call   f010387e <cprintf>
f01043e9:	83 c4 10             	add    $0x10,%esp
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01043ec:	e8 60 c2 ff ff       	call   f0100651 <cons_getc>
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
       	       case SYS_cputs:
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
f01043f1:	e9 09 04 00 00       	jmp    f01047ff <syscall+0x45e>
       	       case SYS_getenvid:
           		 assert(curenv);
f01043f6:	e8 cb 14 00 00       	call   f01058c6 <cpunum>
f01043fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01043fe:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104405:	75 19                	jne    f0104420 <syscall+0x7f>
f0104407:	68 b8 75 10 f0       	push   $0xf01075b8
f010440c:	68 87 6f 10 f0       	push   $0xf0106f87
f0104411:	68 79 01 00 00       	push   $0x179
f0104416:	68 a6 78 10 f0       	push   $0xf01078a6
f010441b:	e8 74 bc ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104420:	e8 a1 14 00 00       	call   f01058c6 <cpunum>
f0104425:	6b c0 74             	imul   $0x74,%eax,%eax
f0104428:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010442e:	8b 40 48             	mov    0x48(%eax),%eax
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
       	       case SYS_getenvid:
           		 assert(curenv);
            		return sys_getenvid();
f0104431:	e9 c9 03 00 00       	jmp    f01047ff <syscall+0x45e>
       	       case SYS_env_destroy:
          		  assert(curenv);
f0104436:	e8 8b 14 00 00       	call   f01058c6 <cpunum>
f010443b:	6b c0 74             	imul   $0x74,%eax,%eax
f010443e:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104445:	75 19                	jne    f0104460 <syscall+0xbf>
f0104447:	68 b8 75 10 f0       	push   $0xf01075b8
f010444c:	68 87 6f 10 f0       	push   $0xf0106f87
f0104451:	68 7c 01 00 00       	push   $0x17c
f0104456:	68 a6 78 10 f0       	push   $0xf01078a6
f010445b:	e8 34 bc ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104460:	e8 61 14 00 00       	call   f01058c6 <cpunum>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104465:	83 ec 04             	sub    $0x4,%esp
f0104468:	6a 01                	push   $0x1
f010446a:	8d 55 f4             	lea    -0xc(%ebp),%edx
f010446d:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010446e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104471:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104477:	ff 70 48             	pushl  0x48(%eax)
f010447a:	e8 f2 ea ff ff       	call   f0102f71 <envid2env>
f010447f:	83 c4 10             	add    $0x10,%esp
f0104482:	85 c0                	test   %eax,%eax
f0104484:	0f 88 75 03 00 00    	js     f01047ff <syscall+0x45e>
		return r;
	if (e == curenv)
f010448a:	e8 37 14 00 00       	call   f01058c6 <cpunum>
f010448f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104492:	6b c0 74             	imul   $0x74,%eax,%eax
f0104495:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f010449b:	75 23                	jne    f01044c0 <syscall+0x11f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010449d:	e8 24 14 00 00       	call   f01058c6 <cpunum>
f01044a2:	83 ec 08             	sub    $0x8,%esp
f01044a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a8:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044ae:	ff 70 48             	pushl  0x48(%eax)
f01044b1:	68 b5 78 10 f0       	push   $0xf01078b5
f01044b6:	e8 c3 f3 ff ff       	call   f010387e <cprintf>
f01044bb:	83 c4 10             	add    $0x10,%esp
f01044be:	eb 25                	jmp    f01044e5 <syscall+0x144>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01044c0:	8b 5a 48             	mov    0x48(%edx),%ebx
f01044c3:	e8 fe 13 00 00       	call   f01058c6 <cpunum>
f01044c8:	83 ec 04             	sub    $0x4,%esp
f01044cb:	53                   	push   %ebx
f01044cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01044cf:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044d5:	ff 70 48             	pushl  0x48(%eax)
f01044d8:	68 d0 78 10 f0       	push   $0xf01078d0
f01044dd:	e8 9c f3 ff ff       	call   f010387e <cprintf>
f01044e2:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01044e5:	83 ec 0c             	sub    $0xc,%esp
f01044e8:	ff 75 f4             	pushl  -0xc(%ebp)
f01044eb:	e8 d1 f0 ff ff       	call   f01035c1 <env_destroy>
f01044f0:	83 c4 10             	add    $0x10,%esp
	return 0;
f01044f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01044f8:	e9 02 03 00 00       	jmp    f01047ff <syscall+0x45e>
            		return sys_getenvid();
       	       case SYS_env_destroy:
          		  assert(curenv);
            		return sys_env_destroy(sys_getenvid());
	       case SYS_yield:
			assert(curenv);
f01044fd:	e8 c4 13 00 00       	call   f01058c6 <cpunum>
f0104502:	6b c0 74             	imul   $0x74,%eax,%eax
f0104505:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010450c:	75 19                	jne    f0104527 <syscall+0x186>
f010450e:	68 b8 75 10 f0       	push   $0xf01075b8
f0104513:	68 87 6f 10 f0       	push   $0xf0106f87
f0104518:	68 7f 01 00 00       	push   $0x17f
f010451d:	68 a6 78 10 f0       	push   $0xf01078a6
f0104522:	e8 6d bb ff ff       	call   f0100094 <_panic>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104527:	e8 6e fd ff ff       	call   f010429a <sched_yield>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	// LAB 4: Your code here.
	struct Env * newenv_store;
	if(curenv->env_id == 0)
f010452c:	e8 95 13 00 00       	call   f01058c6 <cpunum>
f0104531:	6b c0 74             	imul   $0x74,%eax,%eax
f0104534:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010453a:	8b 40 48             	mov    0x48(%eax),%eax
f010453d:	85 c0                	test   %eax,%eax
f010453f:	0f 84 ba 02 00 00    	je     f01047ff <syscall+0x45e>
		return 0;
	int r_env_alloc = env_alloc(&newenv_store,curenv->env_id);
f0104545:	e8 7c 13 00 00       	call   f01058c6 <cpunum>
f010454a:	83 ec 08             	sub    $0x8,%esp
f010454d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104550:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104556:	ff 70 48             	pushl  0x48(%eax)
f0104559:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010455c:	50                   	push   %eax
f010455d:	e8 97 eb ff ff       	call   f01030f9 <env_alloc>
	
	if(r_env_alloc<0)
f0104562:	83 c4 10             	add    $0x10,%esp
f0104565:	85 c0                	test   %eax,%eax
f0104567:	0f 88 92 02 00 00    	js     f01047ff <syscall+0x45e>
		return r_env_alloc;
	
	newenv_store->env_status = ENV_NOT_RUNNABLE;
f010456d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104570:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove(&newenv_store->env_tf,&curenv->env_tf,sizeof(curenv->env_tf));
f0104577:	e8 4a 13 00 00       	call   f01058c6 <cpunum>
f010457c:	83 ec 04             	sub    $0x4,%esp
f010457f:	6a 44                	push   $0x44
f0104581:	6b c0 74             	imul   $0x74,%eax,%eax
f0104584:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010458a:	ff 75 f4             	pushl  -0xc(%ebp)
f010458d:	e8 5e 0d 00 00       	call   f01052f0 <memmove>
	newenv_store->env_tf.tf_regs.reg_eax =0;
f0104592:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104595:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv_store->env_id;
f010459c:	8b 40 48             	mov    0x48(%eax),%eax
f010459f:	83 c4 10             	add    $0x10,%esp
f01045a2:	e9 58 02 00 00       	jmp    f01047ff <syscall+0x45e>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01045a7:	83 ec 04             	sub    $0x4,%esp
f01045aa:	6a 01                	push   $0x1
f01045ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045af:	50                   	push   %eax
f01045b0:	ff 75 0c             	pushl  0xc(%ebp)
f01045b3:	e8 b9 e9 ff ff       	call   f0102f71 <envid2env>
	if(r_value)
f01045b8:	83 c4 10             	add    $0x10,%esp
f01045bb:	85 c0                	test   %eax,%eax
f01045bd:	0f 85 3c 02 00 00    	jne    f01047ff <syscall+0x45e>
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f01045c3:	8b 45 10             	mov    0x10(%ebp),%eax
f01045c6:	83 e8 02             	sub    $0x2,%eax
f01045c9:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01045ce:	75 13                	jne    f01045e3 <syscall+0x242>
		return -E_INVAL;
	newenv_store->env_status = status;
f01045d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01045d6:	89 58 54             	mov    %ebx,0x54(%eax)

	return 0;
f01045d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01045de:	e9 1c 02 00 00       	jmp    f01047ff <syscall+0x45e>
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f01045e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			sys_yield();
			return 1;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f01045e8:	e9 12 02 00 00       	jmp    f01047ff <syscall+0x45e>
	//   allocated!

	// LAB 4: Your code here.
//	cprintf("the kernel env index is:%d\n",ENVX(curenv->env_id));
	struct Env *newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01045ed:	83 ec 04             	sub    $0x4,%esp
f01045f0:	6a 01                	push   $0x1
f01045f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045f5:	50                   	push   %eax
f01045f6:	ff 75 0c             	pushl  0xc(%ebp)
f01045f9:	e8 73 e9 ff ff       	call   f0102f71 <envid2env>
	if(r_value)
f01045fe:	83 c4 10             	add    $0x10,%esp
f0104601:	85 c0                	test   %eax,%eax
f0104603:	0f 85 f6 01 00 00    	jne    f01047ff <syscall+0x45e>
		return r_value;
	cprintf("after envid2env().\n");
f0104609:	83 ec 0c             	sub    $0xc,%esp
f010460c:	68 e8 78 10 f0       	push   $0xf01078e8
f0104611:	e8 68 f2 ff ff       	call   f010387e <cprintf>
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
f0104616:	83 c4 10             	add    $0x10,%esp
f0104619:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104620:	77 56                	ja     f0104678 <syscall+0x2d7>
f0104622:	8b 45 10             	mov    0x10(%ebp),%eax
f0104625:	c1 e0 14             	shl    $0x14,%eax
f0104628:	85 c0                	test   %eax,%eax
f010462a:	75 56                	jne    f0104682 <syscall+0x2e1>
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f010462c:	8b 55 14             	mov    0x14(%ebp),%edx
f010462f:	83 e2 fd             	and    $0xfffffffd,%edx
f0104632:	83 fa 05             	cmp    $0x5,%edx
f0104635:	74 11                	je     f0104648 <syscall+0x2a7>
		return -E_INVAL;
f0104637:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f010463c:	81 fa 05 0e 00 00    	cmp    $0xe05,%edx
f0104642:	0f 85 b7 01 00 00    	jne    f01047ff <syscall+0x45e>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
f0104648:	83 ec 0c             	sub    $0xc,%esp
f010464b:	6a 00                	push   $0x0
f010464d:	e8 1f c9 ff ff       	call   f0100f71 <page_alloc>
	if(!pp)
f0104652:	83 c4 10             	add    $0x10,%esp
f0104655:	85 c0                	test   %eax,%eax
f0104657:	74 33                	je     f010468c <syscall+0x2eb>
		return -E_NO_MEM;

	int ret = page_insert(newenv_store->env_pgdir,pp,va,perm);	
f0104659:	ff 75 14             	pushl  0x14(%ebp)
f010465c:	ff 75 10             	pushl  0x10(%ebp)
f010465f:	50                   	push   %eax
f0104660:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104663:	ff 70 60             	pushl  0x60(%eax)
f0104666:	e8 f5 cc ff ff       	call   f0101360 <page_insert>
f010466b:	83 c4 10             	add    $0x10,%esp
	if(!ret)
		return ret;
	return 0;
f010466e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104673:	e9 87 01 00 00       	jmp    f01047ff <syscall+0x45e>
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
		return -E_INVAL;
f0104678:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010467d:	e9 7d 01 00 00       	jmp    f01047ff <syscall+0x45e>
f0104682:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104687:	e9 73 01 00 00       	jmp    f01047ff <syscall+0x45e>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
	if(!pp)
		return -E_NO_MEM;
f010468c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0104691:	e9 69 01 00 00       	jmp    f01047ff <syscall+0x45e>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
f0104696:	83 ec 04             	sub    $0x4,%esp
f0104699:	6a 01                	push   $0x1
f010469b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010469e:	50                   	push   %eax
f010469f:	ff 75 0c             	pushl  0xc(%ebp)
f01046a2:	e8 ca e8 ff ff       	call   f0102f71 <envid2env>
f01046a7:	89 c3                	mov    %eax,%ebx
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
f01046a9:	83 c4 0c             	add    $0xc,%esp
f01046ac:	6a 01                	push   $0x1
f01046ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01046b1:	50                   	push   %eax
f01046b2:	ff 75 14             	pushl  0x14(%ebp)
f01046b5:	e8 b7 e8 ff ff       	call   f0102f71 <envid2env>
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
f01046ba:	83 c4 10             	add    $0x10,%esp
f01046bd:	83 fb fe             	cmp    $0xfffffffe,%ebx
f01046c0:	0f 84 ab 00 00 00    	je     f0104771 <syscall+0x3d0>
f01046c6:	83 f8 fe             	cmp    $0xfffffffe,%eax
f01046c9:	0f 84 a2 00 00 00    	je     f0104771 <syscall+0x3d0>
		return -E_BAD_ENV;
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
f01046cf:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046d6:	0f 87 9f 00 00 00    	ja     f010477b <syscall+0x3da>
f01046dc:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01046e3:	0f 87 92 00 00 00    	ja     f010477b <syscall+0x3da>
		return -E_INVAL;

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
f01046e9:	8b 45 10             	mov    0x10(%ebp),%eax
f01046ec:	c1 e0 14             	shl    $0x14,%eax
f01046ef:	85 c0                	test   %eax,%eax
f01046f1:	0f 85 8b 00 00 00    	jne    f0104782 <syscall+0x3e1>
f01046f7:	8b 45 18             	mov    0x18(%ebp),%eax
f01046fa:	c1 e0 14             	shl    $0x14,%eax
f01046fd:	85 c0                	test   %eax,%eax
f01046ff:	0f 85 84 00 00 00    	jne    f0104789 <syscall+0x3e8>
		return -E_INVAL;

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
f0104705:	83 ec 04             	sub    $0x4,%esp
f0104708:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010470b:	50                   	push   %eax
f010470c:	ff 75 10             	pushl  0x10(%ebp)
f010470f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104712:	ff 70 60             	pushl  0x60(%eax)
f0104715:	e8 66 cb ff ff       	call   f0101280 <page_lookup>
f010471a:	89 c2                	mov    %eax,%edx
	if(!pp)
f010471c:	83 c4 10             	add    $0x10,%esp
f010471f:	85 c0                	test   %eax,%eax
f0104721:	74 6d                	je     f0104790 <syscall+0x3ef>

	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104723:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104726:	83 e1 fd             	and    $0xfffffffd,%ecx
f0104729:	83 f9 05             	cmp    $0x5,%ecx
f010472c:	74 11                	je     f010473f <syscall+0x39e>
		return -E_INVAL;
f010472e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104733:	81 f9 05 0e 00 00    	cmp    $0xe05,%ecx
f0104739:	0f 85 c0 00 00 00    	jne    f01047ff <syscall+0x45e>
		return -E_INVAL;

	if(perm&PTE_W && !((*pte_store)&PTE_W))
f010473f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104743:	74 08                	je     f010474d <syscall+0x3ac>
f0104745:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104748:	f6 00 02             	testb  $0x2,(%eax)
f010474b:	74 4a                	je     f0104797 <syscall+0x3f6>
		return -E_INVAL;


	if(page_insert(newenv_store_dst->env_pgdir,pp,dstva,perm))
f010474d:	ff 75 1c             	pushl  0x1c(%ebp)
f0104750:	ff 75 18             	pushl  0x18(%ebp)
f0104753:	52                   	push   %edx
f0104754:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104757:	ff 70 60             	pushl  0x60(%eax)
f010475a:	e8 01 cc ff ff       	call   f0101360 <page_insert>
f010475f:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104762:	85 c0                	test   %eax,%eax
f0104764:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0104769:	0f 45 c2             	cmovne %edx,%eax
f010476c:	e9 8e 00 00 00       	jmp    f01047ff <syscall+0x45e>
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
		return -E_BAD_ENV;
f0104771:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104776:	e9 84 00 00 00       	jmp    f01047ff <syscall+0x45e>
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
		return -E_INVAL;
f010477b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104780:	eb 7d                	jmp    f01047ff <syscall+0x45e>

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
		return -E_INVAL;
f0104782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104787:	eb 76                	jmp    f01047ff <syscall+0x45e>
f0104789:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010478e:	eb 6f                	jmp    f01047ff <syscall+0x45e>

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
	if(!pp)
		return -E_INVAL;
f0104790:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104795:	eb 68                	jmp    f01047ff <syscall+0x45e>
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
		return -E_INVAL;

	if(perm&PTE_W && !((*pte_store)&PTE_W))
		return -E_INVAL;
f0104797:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010479c:	eb 61                	jmp    f01047ff <syscall+0x45e>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f010479e:	83 ec 04             	sub    $0x4,%esp
f01047a1:	6a 01                	push   $0x1
f01047a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01047a6:	50                   	push   %eax
f01047a7:	ff 75 0c             	pushl  0xc(%ebp)
f01047aa:	e8 c2 e7 ff ff       	call   f0102f71 <envid2env>
	if(r_value == -E_BAD_ENV)
f01047af:	83 c4 10             	add    $0x10,%esp
f01047b2:	83 f8 fe             	cmp    $0xfffffffe,%eax
f01047b5:	74 2e                	je     f01047e5 <syscall+0x444>
		return -E_BAD_ENV;
	
	if(va>=(void*)UTOP)
f01047b7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047be:	77 2c                	ja     f01047ec <syscall+0x44b>
		return -E_INVAL;

	if(((unsigned int)va<<20))
f01047c0:	8b 45 10             	mov    0x10(%ebp),%eax
f01047c3:	c1 e0 14             	shl    $0x14,%eax
f01047c6:	85 c0                	test   %eax,%eax
f01047c8:	75 29                	jne    f01047f3 <syscall+0x452>
		return -E_INVAL;

	page_remove(newenv_store->env_pgdir,va);
f01047ca:	83 ec 08             	sub    $0x8,%esp
f01047cd:	ff 75 10             	pushl  0x10(%ebp)
f01047d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01047d3:	ff 70 60             	pushl  0x60(%eax)
f01047d6:	e8 3f cb ff ff       	call   f010131a <page_remove>
f01047db:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f01047de:	b8 00 00 00 00       	mov    $0x0,%eax
f01047e3:	eb 1a                	jmp    f01047ff <syscall+0x45e>
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value == -E_BAD_ENV)
		return -E_BAD_ENV;
f01047e5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01047ea:	eb 13                	jmp    f01047ff <syscall+0x45e>
	
	if(va>=(void*)UTOP)
		return -E_INVAL;
f01047ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047f1:	eb 0c                	jmp    f01047ff <syscall+0x45e>

	if(((unsigned int)va<<20))
		return -E_INVAL;
f01047f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
f01047f8:	eb 05                	jmp    f01047ff <syscall+0x45e>
		default:
			return -E_INVAL;
f01047fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01047ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104802:	c9                   	leave  
f0104803:	c3                   	ret    

f0104804 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104804:	55                   	push   %ebp
f0104805:	89 e5                	mov    %esp,%ebp
f0104807:	57                   	push   %edi
f0104808:	56                   	push   %esi
f0104809:	53                   	push   %ebx
f010480a:	83 ec 14             	sub    $0x14,%esp
f010480d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104810:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104813:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104816:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104819:	8b 1a                	mov    (%edx),%ebx
f010481b:	8b 01                	mov    (%ecx),%eax
f010481d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104820:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104827:	eb 7f                	jmp    f01048a8 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104829:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010482c:	01 d8                	add    %ebx,%eax
f010482e:	89 c6                	mov    %eax,%esi
f0104830:	c1 ee 1f             	shr    $0x1f,%esi
f0104833:	01 c6                	add    %eax,%esi
f0104835:	d1 fe                	sar    %esi
f0104837:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010483a:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010483d:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104840:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104842:	eb 03                	jmp    f0104847 <stab_binsearch+0x43>
			m--;
f0104844:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104847:	39 c3                	cmp    %eax,%ebx
f0104849:	7f 0d                	jg     f0104858 <stab_binsearch+0x54>
f010484b:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010484f:	83 ea 0c             	sub    $0xc,%edx
f0104852:	39 f9                	cmp    %edi,%ecx
f0104854:	75 ee                	jne    f0104844 <stab_binsearch+0x40>
f0104856:	eb 05                	jmp    f010485d <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104858:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010485b:	eb 4b                	jmp    f01048a8 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010485d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104860:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104863:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104867:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010486a:	76 11                	jbe    f010487d <stab_binsearch+0x79>
			*region_left = m;
f010486c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010486f:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104871:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104874:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010487b:	eb 2b                	jmp    f01048a8 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010487d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104880:	73 14                	jae    f0104896 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104882:	83 e8 01             	sub    $0x1,%eax
f0104885:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104888:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010488b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010488d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104894:	eb 12                	jmp    f01048a8 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104896:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104899:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010489b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010489f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01048a1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01048a8:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01048ab:	0f 8e 78 ff ff ff    	jle    f0104829 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01048b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01048b5:	75 0f                	jne    f01048c6 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01048b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048ba:	8b 00                	mov    (%eax),%eax
f01048bc:	83 e8 01             	sub    $0x1,%eax
f01048bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048c2:	89 06                	mov    %eax,(%esi)
f01048c4:	eb 2c                	jmp    f01048f2 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01048c9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01048cb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01048ce:	8b 0e                	mov    (%esi),%ecx
f01048d0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01048d3:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01048d6:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048d9:	eb 03                	jmp    f01048de <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01048db:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01048de:	39 c8                	cmp    %ecx,%eax
f01048e0:	7e 0b                	jle    f01048ed <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01048e2:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01048e6:	83 ea 0c             	sub    $0xc,%edx
f01048e9:	39 df                	cmp    %ebx,%edi
f01048eb:	75 ee                	jne    f01048db <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01048ed:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01048f0:	89 06                	mov    %eax,(%esi)
	}
}
f01048f2:	83 c4 14             	add    $0x14,%esp
f01048f5:	5b                   	pop    %ebx
f01048f6:	5e                   	pop    %esi
f01048f7:	5f                   	pop    %edi
f01048f8:	5d                   	pop    %ebp
f01048f9:	c3                   	ret    

f01048fa <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01048fa:	55                   	push   %ebp
f01048fb:	89 e5                	mov    %esp,%ebp
f01048fd:	57                   	push   %edi
f01048fe:	56                   	push   %esi
f01048ff:	53                   	push   %ebx
f0104900:	83 ec 2c             	sub    $0x2c,%esp
f0104903:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104906:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104909:	c7 06 28 79 10 f0    	movl   $0xf0107928,(%esi)
	info->eip_line = 0;
f010490f:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104916:	c7 46 08 28 79 10 f0 	movl   $0xf0107928,0x8(%esi)
	info->eip_fn_namelen = 9;
f010491d:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104924:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104927:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010492e:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104934:	77 21                	ja     f0104957 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104936:	a1 00 00 20 00       	mov    0x200000,%eax
f010493b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010493e:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104943:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104949:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010494c:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104952:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104955:	eb 1a                	jmp    f0104971 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104957:	c7 45 d0 a4 55 11 f0 	movl   $0xf01155a4,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010495e:	c7 45 cc 29 1e 11 f0 	movl   $0xf0111e29,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104965:	b8 28 1e 11 f0       	mov    $0xf0111e28,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010496a:	c7 45 d4 14 7e 10 f0 	movl   $0xf0107e14,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104971:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104974:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104977:	0f 83 2b 01 00 00    	jae    f0104aa8 <debuginfo_eip+0x1ae>
f010497d:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104981:	0f 85 28 01 00 00    	jne    f0104aaf <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104987:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010498e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104991:	29 d8                	sub    %ebx,%eax
f0104993:	c1 f8 02             	sar    $0x2,%eax
f0104996:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010499c:	83 e8 01             	sub    $0x1,%eax
f010499f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01049a2:	57                   	push   %edi
f01049a3:	6a 64                	push   $0x64
f01049a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049a8:	89 c1                	mov    %eax,%ecx
f01049aa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049ad:	89 d8                	mov    %ebx,%eax
f01049af:	e8 50 fe ff ff       	call   f0104804 <stab_binsearch>
	if (lfile == 0)
f01049b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049b7:	83 c4 08             	add    $0x8,%esp
f01049ba:	85 c0                	test   %eax,%eax
f01049bc:	0f 84 f4 00 00 00    	je     f0104ab6 <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01049c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01049c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01049cb:	57                   	push   %edi
f01049cc:	6a 24                	push   $0x24
f01049ce:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01049d1:	89 c1                	mov    %eax,%ecx
f01049d3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01049d6:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01049d9:	89 d8                	mov    %ebx,%eax
f01049db:	e8 24 fe ff ff       	call   f0104804 <stab_binsearch>

	if (lfun <= rfun) {
f01049e0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01049e3:	83 c4 08             	add    $0x8,%esp
f01049e6:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01049e9:	7f 24                	jg     f0104a0f <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01049eb:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01049ee:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01049f1:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01049f4:	8b 02                	mov    (%edx),%eax
f01049f6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01049f9:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01049fc:	29 f9                	sub    %edi,%ecx
f01049fe:	39 c8                	cmp    %ecx,%eax
f0104a00:	73 05                	jae    f0104a07 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104a02:	01 f8                	add    %edi,%eax
f0104a04:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104a07:	8b 42 08             	mov    0x8(%edx),%eax
f0104a0a:	89 46 10             	mov    %eax,0x10(%esi)
f0104a0d:	eb 06                	jmp    f0104a15 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104a0f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104a12:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104a15:	83 ec 08             	sub    $0x8,%esp
f0104a18:	6a 3a                	push   $0x3a
f0104a1a:	ff 76 08             	pushl  0x8(%esi)
f0104a1d:	e8 65 08 00 00       	call   f0105287 <strfind>
f0104a22:	2b 46 08             	sub    0x8(%esi),%eax
f0104a25:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a2b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a2e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104a31:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104a34:	83 c4 10             	add    $0x10,%esp
f0104a37:	eb 06                	jmp    f0104a3f <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104a39:	83 eb 01             	sub    $0x1,%ebx
f0104a3c:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a3f:	39 fb                	cmp    %edi,%ebx
f0104a41:	7c 2d                	jl     f0104a70 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104a43:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104a47:	80 fa 84             	cmp    $0x84,%dl
f0104a4a:	74 0b                	je     f0104a57 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a4c:	80 fa 64             	cmp    $0x64,%dl
f0104a4f:	75 e8                	jne    f0104a39 <debuginfo_eip+0x13f>
f0104a51:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104a55:	74 e2                	je     f0104a39 <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104a57:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a5a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104a5d:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104a60:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104a63:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104a66:	29 f8                	sub    %edi,%eax
f0104a68:	39 c2                	cmp    %eax,%edx
f0104a6a:	73 04                	jae    f0104a70 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104a6c:	01 fa                	add    %edi,%edx
f0104a6e:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104a70:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104a73:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104a76:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104a7b:	39 cb                	cmp    %ecx,%ebx
f0104a7d:	7d 43                	jge    f0104ac2 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104a7f:	8d 53 01             	lea    0x1(%ebx),%edx
f0104a82:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a85:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104a88:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104a8b:	eb 07                	jmp    f0104a94 <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104a8d:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104a91:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104a94:	39 ca                	cmp    %ecx,%edx
f0104a96:	74 25                	je     f0104abd <debuginfo_eip+0x1c3>
f0104a98:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104a9b:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104a9f:	74 ec                	je     f0104a8d <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104aa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104aa6:	eb 1a                	jmp    f0104ac2 <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104aa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104aad:	eb 13                	jmp    f0104ac2 <debuginfo_eip+0x1c8>
f0104aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104ab4:	eb 0c                	jmp    f0104ac2 <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104ab6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104abb:	eb 05                	jmp    f0104ac2 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104abd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ac2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ac5:	5b                   	pop    %ebx
f0104ac6:	5e                   	pop    %esi
f0104ac7:	5f                   	pop    %edi
f0104ac8:	5d                   	pop    %ebp
f0104ac9:	c3                   	ret    

f0104aca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104aca:	55                   	push   %ebp
f0104acb:	89 e5                	mov    %esp,%ebp
f0104acd:	57                   	push   %edi
f0104ace:	56                   	push   %esi
f0104acf:	53                   	push   %ebx
f0104ad0:	83 ec 1c             	sub    $0x1c,%esp
f0104ad3:	89 c7                	mov    %eax,%edi
f0104ad5:	89 d6                	mov    %edx,%esi
f0104ad7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ada:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104add:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ae0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104ae3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ae6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104aeb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104aee:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104af1:	39 d3                	cmp    %edx,%ebx
f0104af3:	72 05                	jb     f0104afa <printnum+0x30>
f0104af5:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104af8:	77 45                	ja     f0104b3f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104afa:	83 ec 0c             	sub    $0xc,%esp
f0104afd:	ff 75 18             	pushl  0x18(%ebp)
f0104b00:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b03:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104b06:	53                   	push   %ebx
f0104b07:	ff 75 10             	pushl  0x10(%ebp)
f0104b0a:	83 ec 08             	sub    $0x8,%esp
f0104b0d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b10:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b13:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b16:	ff 75 d8             	pushl  -0x28(%ebp)
f0104b19:	e8 a2 11 00 00       	call   f0105cc0 <__udivdi3>
f0104b1e:	83 c4 18             	add    $0x18,%esp
f0104b21:	52                   	push   %edx
f0104b22:	50                   	push   %eax
f0104b23:	89 f2                	mov    %esi,%edx
f0104b25:	89 f8                	mov    %edi,%eax
f0104b27:	e8 9e ff ff ff       	call   f0104aca <printnum>
f0104b2c:	83 c4 20             	add    $0x20,%esp
f0104b2f:	eb 18                	jmp    f0104b49 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104b31:	83 ec 08             	sub    $0x8,%esp
f0104b34:	56                   	push   %esi
f0104b35:	ff 75 18             	pushl  0x18(%ebp)
f0104b38:	ff d7                	call   *%edi
f0104b3a:	83 c4 10             	add    $0x10,%esp
f0104b3d:	eb 03                	jmp    f0104b42 <printnum+0x78>
f0104b3f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b42:	83 eb 01             	sub    $0x1,%ebx
f0104b45:	85 db                	test   %ebx,%ebx
f0104b47:	7f e8                	jg     f0104b31 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104b49:	83 ec 08             	sub    $0x8,%esp
f0104b4c:	56                   	push   %esi
f0104b4d:	83 ec 04             	sub    $0x4,%esp
f0104b50:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b53:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b56:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b59:	ff 75 d8             	pushl  -0x28(%ebp)
f0104b5c:	e8 8f 12 00 00       	call   f0105df0 <__umoddi3>
f0104b61:	83 c4 14             	add    $0x14,%esp
f0104b64:	0f be 80 32 79 10 f0 	movsbl -0xfef86ce(%eax),%eax
f0104b6b:	50                   	push   %eax
f0104b6c:	ff d7                	call   *%edi
}
f0104b6e:	83 c4 10             	add    $0x10,%esp
f0104b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b74:	5b                   	pop    %ebx
f0104b75:	5e                   	pop    %esi
f0104b76:	5f                   	pop    %edi
f0104b77:	5d                   	pop    %ebp
f0104b78:	c3                   	ret    

f0104b79 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104b79:	55                   	push   %ebp
f0104b7a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104b7c:	83 fa 01             	cmp    $0x1,%edx
f0104b7f:	7e 0e                	jle    f0104b8f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104b81:	8b 10                	mov    (%eax),%edx
f0104b83:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104b86:	89 08                	mov    %ecx,(%eax)
f0104b88:	8b 02                	mov    (%edx),%eax
f0104b8a:	8b 52 04             	mov    0x4(%edx),%edx
f0104b8d:	eb 22                	jmp    f0104bb1 <getuint+0x38>
	else if (lflag)
f0104b8f:	85 d2                	test   %edx,%edx
f0104b91:	74 10                	je     f0104ba3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104b93:	8b 10                	mov    (%eax),%edx
f0104b95:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104b98:	89 08                	mov    %ecx,(%eax)
f0104b9a:	8b 02                	mov    (%edx),%eax
f0104b9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ba1:	eb 0e                	jmp    f0104bb1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104ba3:	8b 10                	mov    (%eax),%edx
f0104ba5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ba8:	89 08                	mov    %ecx,(%eax)
f0104baa:	8b 02                	mov    (%edx),%eax
f0104bac:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104bb1:	5d                   	pop    %ebp
f0104bb2:	c3                   	ret    

f0104bb3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104bb3:	55                   	push   %ebp
f0104bb4:	89 e5                	mov    %esp,%ebp
f0104bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104bb9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104bbd:	8b 10                	mov    (%eax),%edx
f0104bbf:	3b 50 04             	cmp    0x4(%eax),%edx
f0104bc2:	73 0a                	jae    f0104bce <sprintputch+0x1b>
		*b->buf++ = ch;
f0104bc4:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104bc7:	89 08                	mov    %ecx,(%eax)
f0104bc9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bcc:	88 02                	mov    %al,(%edx)
}
f0104bce:	5d                   	pop    %ebp
f0104bcf:	c3                   	ret    

f0104bd0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104bd0:	55                   	push   %ebp
f0104bd1:	89 e5                	mov    %esp,%ebp
f0104bd3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104bd6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104bd9:	50                   	push   %eax
f0104bda:	ff 75 10             	pushl  0x10(%ebp)
f0104bdd:	ff 75 0c             	pushl  0xc(%ebp)
f0104be0:	ff 75 08             	pushl  0x8(%ebp)
f0104be3:	e8 05 00 00 00       	call   f0104bed <vprintfmt>
	va_end(ap);
}
f0104be8:	83 c4 10             	add    $0x10,%esp
f0104beb:	c9                   	leave  
f0104bec:	c3                   	ret    

f0104bed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104bed:	55                   	push   %ebp
f0104bee:	89 e5                	mov    %esp,%ebp
f0104bf0:	57                   	push   %edi
f0104bf1:	56                   	push   %esi
f0104bf2:	53                   	push   %ebx
f0104bf3:	83 ec 2c             	sub    $0x2c,%esp
f0104bf6:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bf9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104bfc:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104bff:	eb 12                	jmp    f0104c13 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104c01:	85 c0                	test   %eax,%eax
f0104c03:	0f 84 d3 03 00 00    	je     f0104fdc <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
f0104c09:	83 ec 08             	sub    $0x8,%esp
f0104c0c:	53                   	push   %ebx
f0104c0d:	50                   	push   %eax
f0104c0e:	ff d6                	call   *%esi
f0104c10:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104c13:	83 c7 01             	add    $0x1,%edi
f0104c16:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c1a:	83 f8 25             	cmp    $0x25,%eax
f0104c1d:	75 e2                	jne    f0104c01 <vprintfmt+0x14>
f0104c1f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104c23:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104c2a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104c31:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104c38:	ba 00 00 00 00       	mov    $0x0,%edx
f0104c3d:	eb 07                	jmp    f0104c46 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104c42:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c46:	8d 47 01             	lea    0x1(%edi),%eax
f0104c49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c4c:	0f b6 07             	movzbl (%edi),%eax
f0104c4f:	0f b6 c8             	movzbl %al,%ecx
f0104c52:	83 e8 23             	sub    $0x23,%eax
f0104c55:	3c 55                	cmp    $0x55,%al
f0104c57:	0f 87 64 03 00 00    	ja     f0104fc1 <vprintfmt+0x3d4>
f0104c5d:	0f b6 c0             	movzbl %al,%eax
f0104c60:	ff 24 85 00 7a 10 f0 	jmp    *-0xfef8600(,%eax,4)
f0104c67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104c6a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104c6e:	eb d6                	jmp    f0104c46 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104c73:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104c7b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104c7e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104c82:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104c85:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104c88:	83 fa 09             	cmp    $0x9,%edx
f0104c8b:	77 39                	ja     f0104cc6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104c8d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104c90:	eb e9                	jmp    f0104c7b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104c92:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c95:	8d 48 04             	lea    0x4(%eax),%ecx
f0104c98:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104c9b:	8b 00                	mov    (%eax),%eax
f0104c9d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ca0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104ca3:	eb 27                	jmp    f0104ccc <vprintfmt+0xdf>
f0104ca5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ca8:	85 c0                	test   %eax,%eax
f0104caa:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104caf:	0f 49 c8             	cmovns %eax,%ecx
f0104cb2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cb8:	eb 8c                	jmp    f0104c46 <vprintfmt+0x59>
f0104cba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104cbd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104cc4:	eb 80                	jmp    f0104c46 <vprintfmt+0x59>
f0104cc6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104cc9:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f0104ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104cd0:	0f 89 70 ff ff ff    	jns    f0104c46 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104cd6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104cd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104cdc:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104ce3:	e9 5e ff ff ff       	jmp    f0104c46 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104ce8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ceb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104cee:	e9 53 ff ff ff       	jmp    f0104c46 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104cf3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cf6:	8d 50 04             	lea    0x4(%eax),%edx
f0104cf9:	89 55 14             	mov    %edx,0x14(%ebp)
f0104cfc:	83 ec 08             	sub    $0x8,%esp
f0104cff:	53                   	push   %ebx
f0104d00:	ff 30                	pushl  (%eax)
f0104d02:	ff d6                	call   *%esi
			break;
f0104d04:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104d0a:	e9 04 ff ff ff       	jmp    f0104c13 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104d0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d12:	8d 50 04             	lea    0x4(%eax),%edx
f0104d15:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d18:	8b 00                	mov    (%eax),%eax
f0104d1a:	99                   	cltd   
f0104d1b:	31 d0                	xor    %edx,%eax
f0104d1d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104d1f:	83 f8 08             	cmp    $0x8,%eax
f0104d22:	7f 0b                	jg     f0104d2f <vprintfmt+0x142>
f0104d24:	8b 14 85 60 7b 10 f0 	mov    -0xfef84a0(,%eax,4),%edx
f0104d2b:	85 d2                	test   %edx,%edx
f0104d2d:	75 18                	jne    f0104d47 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104d2f:	50                   	push   %eax
f0104d30:	68 4a 79 10 f0       	push   $0xf010794a
f0104d35:	53                   	push   %ebx
f0104d36:	56                   	push   %esi
f0104d37:	e8 94 fe ff ff       	call   f0104bd0 <printfmt>
f0104d3c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104d42:	e9 cc fe ff ff       	jmp    f0104c13 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104d47:	52                   	push   %edx
f0104d48:	68 99 6f 10 f0       	push   $0xf0106f99
f0104d4d:	53                   	push   %ebx
f0104d4e:	56                   	push   %esi
f0104d4f:	e8 7c fe ff ff       	call   f0104bd0 <printfmt>
f0104d54:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d57:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d5a:	e9 b4 fe ff ff       	jmp    f0104c13 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104d5f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d62:	8d 50 04             	lea    0x4(%eax),%edx
f0104d65:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d68:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104d6a:	85 ff                	test   %edi,%edi
f0104d6c:	b8 43 79 10 f0       	mov    $0xf0107943,%eax
f0104d71:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104d74:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d78:	0f 8e 94 00 00 00    	jle    f0104e12 <vprintfmt+0x225>
f0104d7e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104d82:	0f 84 98 00 00 00    	je     f0104e20 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104d88:	83 ec 08             	sub    $0x8,%esp
f0104d8b:	ff 75 c8             	pushl  -0x38(%ebp)
f0104d8e:	57                   	push   %edi
f0104d8f:	e8 a9 03 00 00       	call   f010513d <strnlen>
f0104d94:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104d97:	29 c1                	sub    %eax,%ecx
f0104d99:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104d9c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104d9f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104da3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104da6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104da9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104dab:	eb 0f                	jmp    f0104dbc <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104dad:	83 ec 08             	sub    $0x8,%esp
f0104db0:	53                   	push   %ebx
f0104db1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104db4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104db6:	83 ef 01             	sub    $0x1,%edi
f0104db9:	83 c4 10             	add    $0x10,%esp
f0104dbc:	85 ff                	test   %edi,%edi
f0104dbe:	7f ed                	jg     f0104dad <vprintfmt+0x1c0>
f0104dc0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104dc3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104dc6:	85 c9                	test   %ecx,%ecx
f0104dc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dcd:	0f 49 c1             	cmovns %ecx,%eax
f0104dd0:	29 c1                	sub    %eax,%ecx
f0104dd2:	89 75 08             	mov    %esi,0x8(%ebp)
f0104dd5:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104dd8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104ddb:	89 cb                	mov    %ecx,%ebx
f0104ddd:	eb 4d                	jmp    f0104e2c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104ddf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104de3:	74 1b                	je     f0104e00 <vprintfmt+0x213>
f0104de5:	0f be c0             	movsbl %al,%eax
f0104de8:	83 e8 20             	sub    $0x20,%eax
f0104deb:	83 f8 5e             	cmp    $0x5e,%eax
f0104dee:	76 10                	jbe    f0104e00 <vprintfmt+0x213>
					putch('?', putdat);
f0104df0:	83 ec 08             	sub    $0x8,%esp
f0104df3:	ff 75 0c             	pushl  0xc(%ebp)
f0104df6:	6a 3f                	push   $0x3f
f0104df8:	ff 55 08             	call   *0x8(%ebp)
f0104dfb:	83 c4 10             	add    $0x10,%esp
f0104dfe:	eb 0d                	jmp    f0104e0d <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104e00:	83 ec 08             	sub    $0x8,%esp
f0104e03:	ff 75 0c             	pushl  0xc(%ebp)
f0104e06:	52                   	push   %edx
f0104e07:	ff 55 08             	call   *0x8(%ebp)
f0104e0a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104e0d:	83 eb 01             	sub    $0x1,%ebx
f0104e10:	eb 1a                	jmp    f0104e2c <vprintfmt+0x23f>
f0104e12:	89 75 08             	mov    %esi,0x8(%ebp)
f0104e15:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104e18:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e1b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e1e:	eb 0c                	jmp    f0104e2c <vprintfmt+0x23f>
f0104e20:	89 75 08             	mov    %esi,0x8(%ebp)
f0104e23:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104e26:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e29:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e2c:	83 c7 01             	add    $0x1,%edi
f0104e2f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104e33:	0f be d0             	movsbl %al,%edx
f0104e36:	85 d2                	test   %edx,%edx
f0104e38:	74 23                	je     f0104e5d <vprintfmt+0x270>
f0104e3a:	85 f6                	test   %esi,%esi
f0104e3c:	78 a1                	js     f0104ddf <vprintfmt+0x1f2>
f0104e3e:	83 ee 01             	sub    $0x1,%esi
f0104e41:	79 9c                	jns    f0104ddf <vprintfmt+0x1f2>
f0104e43:	89 df                	mov    %ebx,%edi
f0104e45:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e4b:	eb 18                	jmp    f0104e65 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104e4d:	83 ec 08             	sub    $0x8,%esp
f0104e50:	53                   	push   %ebx
f0104e51:	6a 20                	push   $0x20
f0104e53:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104e55:	83 ef 01             	sub    $0x1,%edi
f0104e58:	83 c4 10             	add    $0x10,%esp
f0104e5b:	eb 08                	jmp    f0104e65 <vprintfmt+0x278>
f0104e5d:	89 df                	mov    %ebx,%edi
f0104e5f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e65:	85 ff                	test   %edi,%edi
f0104e67:	7f e4                	jg     f0104e4d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e6c:	e9 a2 fd ff ff       	jmp    f0104c13 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104e71:	83 fa 01             	cmp    $0x1,%edx
f0104e74:	7e 16                	jle    f0104e8c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104e76:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e79:	8d 50 08             	lea    0x8(%eax),%edx
f0104e7c:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e7f:	8b 50 04             	mov    0x4(%eax),%edx
f0104e82:	8b 00                	mov    (%eax),%eax
f0104e84:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104e87:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104e8a:	eb 32                	jmp    f0104ebe <vprintfmt+0x2d1>
	else if (lflag)
f0104e8c:	85 d2                	test   %edx,%edx
f0104e8e:	74 18                	je     f0104ea8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104e90:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e93:	8d 50 04             	lea    0x4(%eax),%edx
f0104e96:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e99:	8b 00                	mov    (%eax),%eax
f0104e9b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104e9e:	89 c1                	mov    %eax,%ecx
f0104ea0:	c1 f9 1f             	sar    $0x1f,%ecx
f0104ea3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104ea6:	eb 16                	jmp    f0104ebe <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104ea8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eab:	8d 50 04             	lea    0x4(%eax),%edx
f0104eae:	89 55 14             	mov    %edx,0x14(%ebp)
f0104eb1:	8b 00                	mov    (%eax),%eax
f0104eb3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104eb6:	89 c1                	mov    %eax,%ecx
f0104eb8:	c1 f9 1f             	sar    $0x1f,%ecx
f0104ebb:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104ebe:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104ec1:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104ec4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ec7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104eca:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104ecf:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104ed3:	0f 89 b0 00 00 00    	jns    f0104f89 <vprintfmt+0x39c>
				putch('-', putdat);
f0104ed9:	83 ec 08             	sub    $0x8,%esp
f0104edc:	53                   	push   %ebx
f0104edd:	6a 2d                	push   $0x2d
f0104edf:	ff d6                	call   *%esi
				num = -(long long) num;
f0104ee1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104ee4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104ee7:	f7 d8                	neg    %eax
f0104ee9:	83 d2 00             	adc    $0x0,%edx
f0104eec:	f7 da                	neg    %edx
f0104eee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ef1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104ef4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104ef7:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104efc:	e9 88 00 00 00       	jmp    f0104f89 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104f01:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f04:	e8 70 fc ff ff       	call   f0104b79 <getuint>
f0104f09:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f0c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0104f0f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104f14:	eb 73                	jmp    f0104f89 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
f0104f16:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f19:	e8 5b fc ff ff       	call   f0104b79 <getuint>
f0104f1e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f21:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
f0104f24:	83 ec 08             	sub    $0x8,%esp
f0104f27:	53                   	push   %ebx
f0104f28:	6a 58                	push   $0x58
f0104f2a:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f2c:	83 c4 08             	add    $0x8,%esp
f0104f2f:	53                   	push   %ebx
f0104f30:	6a 58                	push   $0x58
f0104f32:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f34:	83 c4 08             	add    $0x8,%esp
f0104f37:	53                   	push   %ebx
f0104f38:	6a 58                	push   $0x58
f0104f3a:	ff d6                	call   *%esi
			goto number;
f0104f3c:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
f0104f3f:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
f0104f44:	eb 43                	jmp    f0104f89 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0104f46:	83 ec 08             	sub    $0x8,%esp
f0104f49:	53                   	push   %ebx
f0104f4a:	6a 30                	push   $0x30
f0104f4c:	ff d6                	call   *%esi
			putch('x', putdat);
f0104f4e:	83 c4 08             	add    $0x8,%esp
f0104f51:	53                   	push   %ebx
f0104f52:	6a 78                	push   $0x78
f0104f54:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104f56:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f59:	8d 50 04             	lea    0x4(%eax),%edx
f0104f5c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104f5f:	8b 00                	mov    (%eax),%eax
f0104f61:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f66:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f69:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104f6c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104f6f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104f74:	eb 13                	jmp    f0104f89 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104f76:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f79:	e8 fb fb ff ff       	call   f0104b79 <getuint>
f0104f7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f81:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0104f84:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104f89:	83 ec 0c             	sub    $0xc,%esp
f0104f8c:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0104f90:	52                   	push   %edx
f0104f91:	ff 75 e0             	pushl  -0x20(%ebp)
f0104f94:	50                   	push   %eax
f0104f95:	ff 75 dc             	pushl  -0x24(%ebp)
f0104f98:	ff 75 d8             	pushl  -0x28(%ebp)
f0104f9b:	89 da                	mov    %ebx,%edx
f0104f9d:	89 f0                	mov    %esi,%eax
f0104f9f:	e8 26 fb ff ff       	call   f0104aca <printnum>
			break;
f0104fa4:	83 c4 20             	add    $0x20,%esp
f0104fa7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104faa:	e9 64 fc ff ff       	jmp    f0104c13 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104faf:	83 ec 08             	sub    $0x8,%esp
f0104fb2:	53                   	push   %ebx
f0104fb3:	51                   	push   %ecx
f0104fb4:	ff d6                	call   *%esi
			break;
f0104fb6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104fbc:	e9 52 fc ff ff       	jmp    f0104c13 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104fc1:	83 ec 08             	sub    $0x8,%esp
f0104fc4:	53                   	push   %ebx
f0104fc5:	6a 25                	push   $0x25
f0104fc7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104fc9:	83 c4 10             	add    $0x10,%esp
f0104fcc:	eb 03                	jmp    f0104fd1 <vprintfmt+0x3e4>
f0104fce:	83 ef 01             	sub    $0x1,%edi
f0104fd1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104fd5:	75 f7                	jne    f0104fce <vprintfmt+0x3e1>
f0104fd7:	e9 37 fc ff ff       	jmp    f0104c13 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104fdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fdf:	5b                   	pop    %ebx
f0104fe0:	5e                   	pop    %esi
f0104fe1:	5f                   	pop    %edi
f0104fe2:	5d                   	pop    %ebp
f0104fe3:	c3                   	ret    

f0104fe4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104fe4:	55                   	push   %ebp
f0104fe5:	89 e5                	mov    %esp,%ebp
f0104fe7:	83 ec 18             	sub    $0x18,%esp
f0104fea:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104ff0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ff3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ff7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104ffa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105001:	85 c0                	test   %eax,%eax
f0105003:	74 26                	je     f010502b <vsnprintf+0x47>
f0105005:	85 d2                	test   %edx,%edx
f0105007:	7e 22                	jle    f010502b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105009:	ff 75 14             	pushl  0x14(%ebp)
f010500c:	ff 75 10             	pushl  0x10(%ebp)
f010500f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105012:	50                   	push   %eax
f0105013:	68 b3 4b 10 f0       	push   $0xf0104bb3
f0105018:	e8 d0 fb ff ff       	call   f0104bed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010501d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105020:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105023:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105026:	83 c4 10             	add    $0x10,%esp
f0105029:	eb 05                	jmp    f0105030 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010502b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105030:	c9                   	leave  
f0105031:	c3                   	ret    

f0105032 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105032:	55                   	push   %ebp
f0105033:	89 e5                	mov    %esp,%ebp
f0105035:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105038:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010503b:	50                   	push   %eax
f010503c:	ff 75 10             	pushl  0x10(%ebp)
f010503f:	ff 75 0c             	pushl  0xc(%ebp)
f0105042:	ff 75 08             	pushl  0x8(%ebp)
f0105045:	e8 9a ff ff ff       	call   f0104fe4 <vsnprintf>
	va_end(ap);

	return rc;
}
f010504a:	c9                   	leave  
f010504b:	c3                   	ret    

f010504c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010504c:	55                   	push   %ebp
f010504d:	89 e5                	mov    %esp,%ebp
f010504f:	57                   	push   %edi
f0105050:	56                   	push   %esi
f0105051:	53                   	push   %ebx
f0105052:	83 ec 0c             	sub    $0xc,%esp
f0105055:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105058:	85 c0                	test   %eax,%eax
f010505a:	74 11                	je     f010506d <readline+0x21>
		cprintf("%s", prompt);
f010505c:	83 ec 08             	sub    $0x8,%esp
f010505f:	50                   	push   %eax
f0105060:	68 99 6f 10 f0       	push   $0xf0106f99
f0105065:	e8 14 e8 ff ff       	call   f010387e <cprintf>
f010506a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010506d:	83 ec 0c             	sub    $0xc,%esp
f0105070:	6a 00                	push   $0x0
f0105072:	e8 6a b7 ff ff       	call   f01007e1 <iscons>
f0105077:	89 c7                	mov    %eax,%edi
f0105079:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010507c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105081:	e8 4a b7 ff ff       	call   f01007d0 <getchar>
f0105086:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105088:	85 c0                	test   %eax,%eax
f010508a:	79 18                	jns    f01050a4 <readline+0x58>
			cprintf("read error: %e\n", c);
f010508c:	83 ec 08             	sub    $0x8,%esp
f010508f:	50                   	push   %eax
f0105090:	68 84 7b 10 f0       	push   $0xf0107b84
f0105095:	e8 e4 e7 ff ff       	call   f010387e <cprintf>
			return NULL;
f010509a:	83 c4 10             	add    $0x10,%esp
f010509d:	b8 00 00 00 00       	mov    $0x0,%eax
f01050a2:	eb 79                	jmp    f010511d <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01050a4:	83 f8 08             	cmp    $0x8,%eax
f01050a7:	0f 94 c2             	sete   %dl
f01050aa:	83 f8 7f             	cmp    $0x7f,%eax
f01050ad:	0f 94 c0             	sete   %al
f01050b0:	08 c2                	or     %al,%dl
f01050b2:	74 1a                	je     f01050ce <readline+0x82>
f01050b4:	85 f6                	test   %esi,%esi
f01050b6:	7e 16                	jle    f01050ce <readline+0x82>
			if (echoing)
f01050b8:	85 ff                	test   %edi,%edi
f01050ba:	74 0d                	je     f01050c9 <readline+0x7d>
				cputchar('\b');
f01050bc:	83 ec 0c             	sub    $0xc,%esp
f01050bf:	6a 08                	push   $0x8
f01050c1:	e8 fa b6 ff ff       	call   f01007c0 <cputchar>
f01050c6:	83 c4 10             	add    $0x10,%esp
			i--;
f01050c9:	83 ee 01             	sub    $0x1,%esi
f01050cc:	eb b3                	jmp    f0105081 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01050ce:	83 fb 1f             	cmp    $0x1f,%ebx
f01050d1:	7e 23                	jle    f01050f6 <readline+0xaa>
f01050d3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01050d9:	7f 1b                	jg     f01050f6 <readline+0xaa>
			if (echoing)
f01050db:	85 ff                	test   %edi,%edi
f01050dd:	74 0c                	je     f01050eb <readline+0x9f>
				cputchar(c);
f01050df:	83 ec 0c             	sub    $0xc,%esp
f01050e2:	53                   	push   %ebx
f01050e3:	e8 d8 b6 ff ff       	call   f01007c0 <cputchar>
f01050e8:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01050eb:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f01050f1:	8d 76 01             	lea    0x1(%esi),%esi
f01050f4:	eb 8b                	jmp    f0105081 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01050f6:	83 fb 0a             	cmp    $0xa,%ebx
f01050f9:	74 05                	je     f0105100 <readline+0xb4>
f01050fb:	83 fb 0d             	cmp    $0xd,%ebx
f01050fe:	75 81                	jne    f0105081 <readline+0x35>
			if (echoing)
f0105100:	85 ff                	test   %edi,%edi
f0105102:	74 0d                	je     f0105111 <readline+0xc5>
				cputchar('\n');
f0105104:	83 ec 0c             	sub    $0xc,%esp
f0105107:	6a 0a                	push   $0xa
f0105109:	e8 b2 b6 ff ff       	call   f01007c0 <cputchar>
f010510e:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0105111:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f0105118:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f010511d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105120:	5b                   	pop    %ebx
f0105121:	5e                   	pop    %esi
f0105122:	5f                   	pop    %edi
f0105123:	5d                   	pop    %ebp
f0105124:	c3                   	ret    

f0105125 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105125:	55                   	push   %ebp
f0105126:	89 e5                	mov    %esp,%ebp
f0105128:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010512b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105130:	eb 03                	jmp    f0105135 <strlen+0x10>
		n++;
f0105132:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105135:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105139:	75 f7                	jne    f0105132 <strlen+0xd>
		n++;
	return n;
}
f010513b:	5d                   	pop    %ebp
f010513c:	c3                   	ret    

f010513d <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010513d:	55                   	push   %ebp
f010513e:	89 e5                	mov    %esp,%ebp
f0105140:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105143:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105146:	ba 00 00 00 00       	mov    $0x0,%edx
f010514b:	eb 03                	jmp    f0105150 <strnlen+0x13>
		n++;
f010514d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105150:	39 c2                	cmp    %eax,%edx
f0105152:	74 08                	je     f010515c <strnlen+0x1f>
f0105154:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105158:	75 f3                	jne    f010514d <strnlen+0x10>
f010515a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010515c:	5d                   	pop    %ebp
f010515d:	c3                   	ret    

f010515e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010515e:	55                   	push   %ebp
f010515f:	89 e5                	mov    %esp,%ebp
f0105161:	53                   	push   %ebx
f0105162:	8b 45 08             	mov    0x8(%ebp),%eax
f0105165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105168:	89 c2                	mov    %eax,%edx
f010516a:	83 c2 01             	add    $0x1,%edx
f010516d:	83 c1 01             	add    $0x1,%ecx
f0105170:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105174:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105177:	84 db                	test   %bl,%bl
f0105179:	75 ef                	jne    f010516a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010517b:	5b                   	pop    %ebx
f010517c:	5d                   	pop    %ebp
f010517d:	c3                   	ret    

f010517e <strcat>:

char *
strcat(char *dst, const char *src)
{
f010517e:	55                   	push   %ebp
f010517f:	89 e5                	mov    %esp,%ebp
f0105181:	53                   	push   %ebx
f0105182:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105185:	53                   	push   %ebx
f0105186:	e8 9a ff ff ff       	call   f0105125 <strlen>
f010518b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010518e:	ff 75 0c             	pushl  0xc(%ebp)
f0105191:	01 d8                	add    %ebx,%eax
f0105193:	50                   	push   %eax
f0105194:	e8 c5 ff ff ff       	call   f010515e <strcpy>
	return dst;
}
f0105199:	89 d8                	mov    %ebx,%eax
f010519b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010519e:	c9                   	leave  
f010519f:	c3                   	ret    

f01051a0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01051a0:	55                   	push   %ebp
f01051a1:	89 e5                	mov    %esp,%ebp
f01051a3:	56                   	push   %esi
f01051a4:	53                   	push   %ebx
f01051a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01051a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01051ab:	89 f3                	mov    %esi,%ebx
f01051ad:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01051b0:	89 f2                	mov    %esi,%edx
f01051b2:	eb 0f                	jmp    f01051c3 <strncpy+0x23>
		*dst++ = *src;
f01051b4:	83 c2 01             	add    $0x1,%edx
f01051b7:	0f b6 01             	movzbl (%ecx),%eax
f01051ba:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01051bd:	80 39 01             	cmpb   $0x1,(%ecx)
f01051c0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01051c3:	39 da                	cmp    %ebx,%edx
f01051c5:	75 ed                	jne    f01051b4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01051c7:	89 f0                	mov    %esi,%eax
f01051c9:	5b                   	pop    %ebx
f01051ca:	5e                   	pop    %esi
f01051cb:	5d                   	pop    %ebp
f01051cc:	c3                   	ret    

f01051cd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01051cd:	55                   	push   %ebp
f01051ce:	89 e5                	mov    %esp,%ebp
f01051d0:	56                   	push   %esi
f01051d1:	53                   	push   %ebx
f01051d2:	8b 75 08             	mov    0x8(%ebp),%esi
f01051d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01051d8:	8b 55 10             	mov    0x10(%ebp),%edx
f01051db:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01051dd:	85 d2                	test   %edx,%edx
f01051df:	74 21                	je     f0105202 <strlcpy+0x35>
f01051e1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01051e5:	89 f2                	mov    %esi,%edx
f01051e7:	eb 09                	jmp    f01051f2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01051e9:	83 c2 01             	add    $0x1,%edx
f01051ec:	83 c1 01             	add    $0x1,%ecx
f01051ef:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01051f2:	39 c2                	cmp    %eax,%edx
f01051f4:	74 09                	je     f01051ff <strlcpy+0x32>
f01051f6:	0f b6 19             	movzbl (%ecx),%ebx
f01051f9:	84 db                	test   %bl,%bl
f01051fb:	75 ec                	jne    f01051e9 <strlcpy+0x1c>
f01051fd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01051ff:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105202:	29 f0                	sub    %esi,%eax
}
f0105204:	5b                   	pop    %ebx
f0105205:	5e                   	pop    %esi
f0105206:	5d                   	pop    %ebp
f0105207:	c3                   	ret    

f0105208 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105208:	55                   	push   %ebp
f0105209:	89 e5                	mov    %esp,%ebp
f010520b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010520e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105211:	eb 06                	jmp    f0105219 <strcmp+0x11>
		p++, q++;
f0105213:	83 c1 01             	add    $0x1,%ecx
f0105216:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105219:	0f b6 01             	movzbl (%ecx),%eax
f010521c:	84 c0                	test   %al,%al
f010521e:	74 04                	je     f0105224 <strcmp+0x1c>
f0105220:	3a 02                	cmp    (%edx),%al
f0105222:	74 ef                	je     f0105213 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105224:	0f b6 c0             	movzbl %al,%eax
f0105227:	0f b6 12             	movzbl (%edx),%edx
f010522a:	29 d0                	sub    %edx,%eax
}
f010522c:	5d                   	pop    %ebp
f010522d:	c3                   	ret    

f010522e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010522e:	55                   	push   %ebp
f010522f:	89 e5                	mov    %esp,%ebp
f0105231:	53                   	push   %ebx
f0105232:	8b 45 08             	mov    0x8(%ebp),%eax
f0105235:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105238:	89 c3                	mov    %eax,%ebx
f010523a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010523d:	eb 06                	jmp    f0105245 <strncmp+0x17>
		n--, p++, q++;
f010523f:	83 c0 01             	add    $0x1,%eax
f0105242:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105245:	39 d8                	cmp    %ebx,%eax
f0105247:	74 15                	je     f010525e <strncmp+0x30>
f0105249:	0f b6 08             	movzbl (%eax),%ecx
f010524c:	84 c9                	test   %cl,%cl
f010524e:	74 04                	je     f0105254 <strncmp+0x26>
f0105250:	3a 0a                	cmp    (%edx),%cl
f0105252:	74 eb                	je     f010523f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105254:	0f b6 00             	movzbl (%eax),%eax
f0105257:	0f b6 12             	movzbl (%edx),%edx
f010525a:	29 d0                	sub    %edx,%eax
f010525c:	eb 05                	jmp    f0105263 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010525e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105263:	5b                   	pop    %ebx
f0105264:	5d                   	pop    %ebp
f0105265:	c3                   	ret    

f0105266 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105266:	55                   	push   %ebp
f0105267:	89 e5                	mov    %esp,%ebp
f0105269:	8b 45 08             	mov    0x8(%ebp),%eax
f010526c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105270:	eb 07                	jmp    f0105279 <strchr+0x13>
		if (*s == c)
f0105272:	38 ca                	cmp    %cl,%dl
f0105274:	74 0f                	je     f0105285 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105276:	83 c0 01             	add    $0x1,%eax
f0105279:	0f b6 10             	movzbl (%eax),%edx
f010527c:	84 d2                	test   %dl,%dl
f010527e:	75 f2                	jne    f0105272 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105280:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105285:	5d                   	pop    %ebp
f0105286:	c3                   	ret    

f0105287 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105287:	55                   	push   %ebp
f0105288:	89 e5                	mov    %esp,%ebp
f010528a:	8b 45 08             	mov    0x8(%ebp),%eax
f010528d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105291:	eb 03                	jmp    f0105296 <strfind+0xf>
f0105293:	83 c0 01             	add    $0x1,%eax
f0105296:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105299:	38 ca                	cmp    %cl,%dl
f010529b:	74 04                	je     f01052a1 <strfind+0x1a>
f010529d:	84 d2                	test   %dl,%dl
f010529f:	75 f2                	jne    f0105293 <strfind+0xc>
			break;
	return (char *) s;
}
f01052a1:	5d                   	pop    %ebp
f01052a2:	c3                   	ret    

f01052a3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01052a3:	55                   	push   %ebp
f01052a4:	89 e5                	mov    %esp,%ebp
f01052a6:	57                   	push   %edi
f01052a7:	56                   	push   %esi
f01052a8:	53                   	push   %ebx
f01052a9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01052ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01052af:	85 c9                	test   %ecx,%ecx
f01052b1:	74 36                	je     f01052e9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01052b3:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01052b9:	75 28                	jne    f01052e3 <memset+0x40>
f01052bb:	f6 c1 03             	test   $0x3,%cl
f01052be:	75 23                	jne    f01052e3 <memset+0x40>
		c &= 0xFF;
f01052c0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01052c4:	89 d3                	mov    %edx,%ebx
f01052c6:	c1 e3 08             	shl    $0x8,%ebx
f01052c9:	89 d6                	mov    %edx,%esi
f01052cb:	c1 e6 18             	shl    $0x18,%esi
f01052ce:	89 d0                	mov    %edx,%eax
f01052d0:	c1 e0 10             	shl    $0x10,%eax
f01052d3:	09 f0                	or     %esi,%eax
f01052d5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01052d7:	89 d8                	mov    %ebx,%eax
f01052d9:	09 d0                	or     %edx,%eax
f01052db:	c1 e9 02             	shr    $0x2,%ecx
f01052de:	fc                   	cld    
f01052df:	f3 ab                	rep stos %eax,%es:(%edi)
f01052e1:	eb 06                	jmp    f01052e9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01052e3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01052e6:	fc                   	cld    
f01052e7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01052e9:	89 f8                	mov    %edi,%eax
f01052eb:	5b                   	pop    %ebx
f01052ec:	5e                   	pop    %esi
f01052ed:	5f                   	pop    %edi
f01052ee:	5d                   	pop    %ebp
f01052ef:	c3                   	ret    

f01052f0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01052f0:	55                   	push   %ebp
f01052f1:	89 e5                	mov    %esp,%ebp
f01052f3:	57                   	push   %edi
f01052f4:	56                   	push   %esi
f01052f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01052f8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01052fe:	39 c6                	cmp    %eax,%esi
f0105300:	73 35                	jae    f0105337 <memmove+0x47>
f0105302:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105305:	39 d0                	cmp    %edx,%eax
f0105307:	73 2e                	jae    f0105337 <memmove+0x47>
		s += n;
		d += n;
f0105309:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010530c:	89 d6                	mov    %edx,%esi
f010530e:	09 fe                	or     %edi,%esi
f0105310:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105316:	75 13                	jne    f010532b <memmove+0x3b>
f0105318:	f6 c1 03             	test   $0x3,%cl
f010531b:	75 0e                	jne    f010532b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010531d:	83 ef 04             	sub    $0x4,%edi
f0105320:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105323:	c1 e9 02             	shr    $0x2,%ecx
f0105326:	fd                   	std    
f0105327:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105329:	eb 09                	jmp    f0105334 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010532b:	83 ef 01             	sub    $0x1,%edi
f010532e:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105331:	fd                   	std    
f0105332:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105334:	fc                   	cld    
f0105335:	eb 1d                	jmp    f0105354 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105337:	89 f2                	mov    %esi,%edx
f0105339:	09 c2                	or     %eax,%edx
f010533b:	f6 c2 03             	test   $0x3,%dl
f010533e:	75 0f                	jne    f010534f <memmove+0x5f>
f0105340:	f6 c1 03             	test   $0x3,%cl
f0105343:	75 0a                	jne    f010534f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105345:	c1 e9 02             	shr    $0x2,%ecx
f0105348:	89 c7                	mov    %eax,%edi
f010534a:	fc                   	cld    
f010534b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010534d:	eb 05                	jmp    f0105354 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010534f:	89 c7                	mov    %eax,%edi
f0105351:	fc                   	cld    
f0105352:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105354:	5e                   	pop    %esi
f0105355:	5f                   	pop    %edi
f0105356:	5d                   	pop    %ebp
f0105357:	c3                   	ret    

f0105358 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105358:	55                   	push   %ebp
f0105359:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010535b:	ff 75 10             	pushl  0x10(%ebp)
f010535e:	ff 75 0c             	pushl  0xc(%ebp)
f0105361:	ff 75 08             	pushl  0x8(%ebp)
f0105364:	e8 87 ff ff ff       	call   f01052f0 <memmove>
}
f0105369:	c9                   	leave  
f010536a:	c3                   	ret    

f010536b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010536b:	55                   	push   %ebp
f010536c:	89 e5                	mov    %esp,%ebp
f010536e:	56                   	push   %esi
f010536f:	53                   	push   %ebx
f0105370:	8b 45 08             	mov    0x8(%ebp),%eax
f0105373:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105376:	89 c6                	mov    %eax,%esi
f0105378:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010537b:	eb 1a                	jmp    f0105397 <memcmp+0x2c>
		if (*s1 != *s2)
f010537d:	0f b6 08             	movzbl (%eax),%ecx
f0105380:	0f b6 1a             	movzbl (%edx),%ebx
f0105383:	38 d9                	cmp    %bl,%cl
f0105385:	74 0a                	je     f0105391 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105387:	0f b6 c1             	movzbl %cl,%eax
f010538a:	0f b6 db             	movzbl %bl,%ebx
f010538d:	29 d8                	sub    %ebx,%eax
f010538f:	eb 0f                	jmp    f01053a0 <memcmp+0x35>
		s1++, s2++;
f0105391:	83 c0 01             	add    $0x1,%eax
f0105394:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105397:	39 f0                	cmp    %esi,%eax
f0105399:	75 e2                	jne    f010537d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010539b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01053a0:	5b                   	pop    %ebx
f01053a1:	5e                   	pop    %esi
f01053a2:	5d                   	pop    %ebp
f01053a3:	c3                   	ret    

f01053a4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01053a4:	55                   	push   %ebp
f01053a5:	89 e5                	mov    %esp,%ebp
f01053a7:	53                   	push   %ebx
f01053a8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01053ab:	89 c1                	mov    %eax,%ecx
f01053ad:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01053b0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053b4:	eb 0a                	jmp    f01053c0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01053b6:	0f b6 10             	movzbl (%eax),%edx
f01053b9:	39 da                	cmp    %ebx,%edx
f01053bb:	74 07                	je     f01053c4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053bd:	83 c0 01             	add    $0x1,%eax
f01053c0:	39 c8                	cmp    %ecx,%eax
f01053c2:	72 f2                	jb     f01053b6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01053c4:	5b                   	pop    %ebx
f01053c5:	5d                   	pop    %ebp
f01053c6:	c3                   	ret    

f01053c7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01053c7:	55                   	push   %ebp
f01053c8:	89 e5                	mov    %esp,%ebp
f01053ca:	57                   	push   %edi
f01053cb:	56                   	push   %esi
f01053cc:	53                   	push   %ebx
f01053cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053d3:	eb 03                	jmp    f01053d8 <strtol+0x11>
		s++;
f01053d5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01053d8:	0f b6 01             	movzbl (%ecx),%eax
f01053db:	3c 20                	cmp    $0x20,%al
f01053dd:	74 f6                	je     f01053d5 <strtol+0xe>
f01053df:	3c 09                	cmp    $0x9,%al
f01053e1:	74 f2                	je     f01053d5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01053e3:	3c 2b                	cmp    $0x2b,%al
f01053e5:	75 0a                	jne    f01053f1 <strtol+0x2a>
		s++;
f01053e7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01053ea:	bf 00 00 00 00       	mov    $0x0,%edi
f01053ef:	eb 11                	jmp    f0105402 <strtol+0x3b>
f01053f1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01053f6:	3c 2d                	cmp    $0x2d,%al
f01053f8:	75 08                	jne    f0105402 <strtol+0x3b>
		s++, neg = 1;
f01053fa:	83 c1 01             	add    $0x1,%ecx
f01053fd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105402:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105408:	75 15                	jne    f010541f <strtol+0x58>
f010540a:	80 39 30             	cmpb   $0x30,(%ecx)
f010540d:	75 10                	jne    f010541f <strtol+0x58>
f010540f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105413:	75 7c                	jne    f0105491 <strtol+0xca>
		s += 2, base = 16;
f0105415:	83 c1 02             	add    $0x2,%ecx
f0105418:	bb 10 00 00 00       	mov    $0x10,%ebx
f010541d:	eb 16                	jmp    f0105435 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010541f:	85 db                	test   %ebx,%ebx
f0105421:	75 12                	jne    f0105435 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105423:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105428:	80 39 30             	cmpb   $0x30,(%ecx)
f010542b:	75 08                	jne    f0105435 <strtol+0x6e>
		s++, base = 8;
f010542d:	83 c1 01             	add    $0x1,%ecx
f0105430:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105435:	b8 00 00 00 00       	mov    $0x0,%eax
f010543a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010543d:	0f b6 11             	movzbl (%ecx),%edx
f0105440:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105443:	89 f3                	mov    %esi,%ebx
f0105445:	80 fb 09             	cmp    $0x9,%bl
f0105448:	77 08                	ja     f0105452 <strtol+0x8b>
			dig = *s - '0';
f010544a:	0f be d2             	movsbl %dl,%edx
f010544d:	83 ea 30             	sub    $0x30,%edx
f0105450:	eb 22                	jmp    f0105474 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105452:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105455:	89 f3                	mov    %esi,%ebx
f0105457:	80 fb 19             	cmp    $0x19,%bl
f010545a:	77 08                	ja     f0105464 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010545c:	0f be d2             	movsbl %dl,%edx
f010545f:	83 ea 57             	sub    $0x57,%edx
f0105462:	eb 10                	jmp    f0105474 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105464:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105467:	89 f3                	mov    %esi,%ebx
f0105469:	80 fb 19             	cmp    $0x19,%bl
f010546c:	77 16                	ja     f0105484 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010546e:	0f be d2             	movsbl %dl,%edx
f0105471:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105474:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105477:	7d 0b                	jge    f0105484 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105479:	83 c1 01             	add    $0x1,%ecx
f010547c:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105480:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105482:	eb b9                	jmp    f010543d <strtol+0x76>

	if (endptr)
f0105484:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105488:	74 0d                	je     f0105497 <strtol+0xd0>
		*endptr = (char *) s;
f010548a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010548d:	89 0e                	mov    %ecx,(%esi)
f010548f:	eb 06                	jmp    f0105497 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105491:	85 db                	test   %ebx,%ebx
f0105493:	74 98                	je     f010542d <strtol+0x66>
f0105495:	eb 9e                	jmp    f0105435 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105497:	89 c2                	mov    %eax,%edx
f0105499:	f7 da                	neg    %edx
f010549b:	85 ff                	test   %edi,%edi
f010549d:	0f 45 c2             	cmovne %edx,%eax
}
f01054a0:	5b                   	pop    %ebx
f01054a1:	5e                   	pop    %esi
f01054a2:	5f                   	pop    %edi
f01054a3:	5d                   	pop    %ebp
f01054a4:	c3                   	ret    
f01054a5:	66 90                	xchg   %ax,%ax
f01054a7:	90                   	nop

f01054a8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01054a8:	fa                   	cli    

	xorw    %ax, %ax
f01054a9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01054ab:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01054ad:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01054af:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01054b1:	0f 01 16             	lgdtl  (%esi)
f01054b4:	74 70                	je     f0105526 <mpsearch1+0x3>
	movl    %cr0, %eax
f01054b6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01054b9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01054bd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01054c0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f01054c6:	08 00                	or     %al,(%eax)

f01054c8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f01054c8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f01054cc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01054ce:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01054d0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f01054d2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01054d6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01054d8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01054da:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f01054df:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01054e2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01054e5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01054ea:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01054ed:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01054f3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01054f8:	b8 07 02 10 f0       	mov    $0xf0100207,%eax
	call    *%eax
f01054fd:	ff d0                	call   *%eax

f01054ff <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01054ff:	eb fe                	jmp    f01054ff <spin>
f0105501:	8d 76 00             	lea    0x0(%esi),%esi

f0105504 <gdt>:
	...
f010550c:	ff                   	(bad)  
f010550d:	ff 00                	incl   (%eax)
f010550f:	00 00                	add    %al,(%eax)
f0105511:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105518:	00                   	.byte 0x0
f0105519:	92                   	xchg   %eax,%edx
f010551a:	cf                   	iret   
	...

f010551c <gdtdesc>:
f010551c:	17                   	pop    %ss
f010551d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105522 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105522:	90                   	nop

f0105523 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105523:	55                   	push   %ebp
f0105524:	89 e5                	mov    %esp,%ebp
f0105526:	57                   	push   %edi
f0105527:	56                   	push   %esi
f0105528:	53                   	push   %ebx
f0105529:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010552c:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f0105532:	89 c3                	mov    %eax,%ebx
f0105534:	c1 eb 0c             	shr    $0xc,%ebx
f0105537:	39 cb                	cmp    %ecx,%ebx
f0105539:	72 12                	jb     f010554d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010553b:	50                   	push   %eax
f010553c:	68 14 60 10 f0       	push   $0xf0106014
f0105541:	6a 57                	push   $0x57
f0105543:	68 21 7d 10 f0       	push   $0xf0107d21
f0105548:	e8 47 ab ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f010554d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105553:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105555:	89 c2                	mov    %eax,%edx
f0105557:	c1 ea 0c             	shr    $0xc,%edx
f010555a:	39 ca                	cmp    %ecx,%edx
f010555c:	72 12                	jb     f0105570 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010555e:	50                   	push   %eax
f010555f:	68 14 60 10 f0       	push   $0xf0106014
f0105564:	6a 57                	push   $0x57
f0105566:	68 21 7d 10 f0       	push   $0xf0107d21
f010556b:	e8 24 ab ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105570:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105576:	eb 2f                	jmp    f01055a7 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105578:	83 ec 04             	sub    $0x4,%esp
f010557b:	6a 04                	push   $0x4
f010557d:	68 31 7d 10 f0       	push   $0xf0107d31
f0105582:	53                   	push   %ebx
f0105583:	e8 e3 fd ff ff       	call   f010536b <memcmp>
f0105588:	83 c4 10             	add    $0x10,%esp
f010558b:	85 c0                	test   %eax,%eax
f010558d:	75 15                	jne    f01055a4 <mpsearch1+0x81>
f010558f:	89 da                	mov    %ebx,%edx
f0105591:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105594:	0f b6 0a             	movzbl (%edx),%ecx
f0105597:	01 c8                	add    %ecx,%eax
f0105599:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010559c:	39 d7                	cmp    %edx,%edi
f010559e:	75 f4                	jne    f0105594 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01055a0:	84 c0                	test   %al,%al
f01055a2:	74 0e                	je     f01055b2 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01055a4:	83 c3 10             	add    $0x10,%ebx
f01055a7:	39 f3                	cmp    %esi,%ebx
f01055a9:	72 cd                	jb     f0105578 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01055ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01055b0:	eb 02                	jmp    f01055b4 <mpsearch1+0x91>
f01055b2:	89 d8                	mov    %ebx,%eax
}
f01055b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055b7:	5b                   	pop    %ebx
f01055b8:	5e                   	pop    %esi
f01055b9:	5f                   	pop    %edi
f01055ba:	5d                   	pop    %ebp
f01055bb:	c3                   	ret    

f01055bc <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01055bc:	55                   	push   %ebp
f01055bd:	89 e5                	mov    %esp,%ebp
f01055bf:	57                   	push   %edi
f01055c0:	56                   	push   %esi
f01055c1:	53                   	push   %ebx
f01055c2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01055c5:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f01055cc:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01055cf:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f01055d6:	75 16                	jne    f01055ee <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055d8:	68 00 04 00 00       	push   $0x400
f01055dd:	68 14 60 10 f0       	push   $0xf0106014
f01055e2:	6a 6f                	push   $0x6f
f01055e4:	68 21 7d 10 f0       	push   $0xf0107d21
f01055e9:	e8 a6 aa ff ff       	call   f0100094 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01055ee:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01055f5:	85 c0                	test   %eax,%eax
f01055f7:	74 16                	je     f010560f <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01055f9:	c1 e0 04             	shl    $0x4,%eax
f01055fc:	ba 00 04 00 00       	mov    $0x400,%edx
f0105601:	e8 1d ff ff ff       	call   f0105523 <mpsearch1>
f0105606:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105609:	85 c0                	test   %eax,%eax
f010560b:	75 3c                	jne    f0105649 <mp_init+0x8d>
f010560d:	eb 20                	jmp    f010562f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010560f:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105616:	c1 e0 0a             	shl    $0xa,%eax
f0105619:	2d 00 04 00 00       	sub    $0x400,%eax
f010561e:	ba 00 04 00 00       	mov    $0x400,%edx
f0105623:	e8 fb fe ff ff       	call   f0105523 <mpsearch1>
f0105628:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010562b:	85 c0                	test   %eax,%eax
f010562d:	75 1a                	jne    f0105649 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010562f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105634:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105639:	e8 e5 fe ff ff       	call   f0105523 <mpsearch1>
f010563e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105641:	85 c0                	test   %eax,%eax
f0105643:	0f 84 5d 02 00 00    	je     f01058a6 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105649:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010564c:	8b 70 04             	mov    0x4(%eax),%esi
f010564f:	85 f6                	test   %esi,%esi
f0105651:	74 06                	je     f0105659 <mp_init+0x9d>
f0105653:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105657:	74 15                	je     f010566e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105659:	83 ec 0c             	sub    $0xc,%esp
f010565c:	68 94 7b 10 f0       	push   $0xf0107b94
f0105661:	e8 18 e2 ff ff       	call   f010387e <cprintf>
f0105666:	83 c4 10             	add    $0x10,%esp
f0105669:	e9 38 02 00 00       	jmp    f01058a6 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010566e:	89 f0                	mov    %esi,%eax
f0105670:	c1 e8 0c             	shr    $0xc,%eax
f0105673:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0105679:	72 15                	jb     f0105690 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010567b:	56                   	push   %esi
f010567c:	68 14 60 10 f0       	push   $0xf0106014
f0105681:	68 90 00 00 00       	push   $0x90
f0105686:	68 21 7d 10 f0       	push   $0xf0107d21
f010568b:	e8 04 aa ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105690:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105696:	83 ec 04             	sub    $0x4,%esp
f0105699:	6a 04                	push   $0x4
f010569b:	68 36 7d 10 f0       	push   $0xf0107d36
f01056a0:	53                   	push   %ebx
f01056a1:	e8 c5 fc ff ff       	call   f010536b <memcmp>
f01056a6:	83 c4 10             	add    $0x10,%esp
f01056a9:	85 c0                	test   %eax,%eax
f01056ab:	74 15                	je     f01056c2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01056ad:	83 ec 0c             	sub    $0xc,%esp
f01056b0:	68 c4 7b 10 f0       	push   $0xf0107bc4
f01056b5:	e8 c4 e1 ff ff       	call   f010387e <cprintf>
f01056ba:	83 c4 10             	add    $0x10,%esp
f01056bd:	e9 e4 01 00 00       	jmp    f01058a6 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01056c2:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01056c6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01056ca:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01056cd:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01056d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01056d7:	eb 0d                	jmp    f01056e6 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01056d9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01056e0:	f0 
f01056e1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01056e3:	83 c0 01             	add    $0x1,%eax
f01056e6:	39 c7                	cmp    %eax,%edi
f01056e8:	75 ef                	jne    f01056d9 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01056ea:	84 d2                	test   %dl,%dl
f01056ec:	74 15                	je     f0105703 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01056ee:	83 ec 0c             	sub    $0xc,%esp
f01056f1:	68 f8 7b 10 f0       	push   $0xf0107bf8
f01056f6:	e8 83 e1 ff ff       	call   f010387e <cprintf>
f01056fb:	83 c4 10             	add    $0x10,%esp
f01056fe:	e9 a3 01 00 00       	jmp    f01058a6 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105703:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105707:	3c 01                	cmp    $0x1,%al
f0105709:	74 1d                	je     f0105728 <mp_init+0x16c>
f010570b:	3c 04                	cmp    $0x4,%al
f010570d:	74 19                	je     f0105728 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010570f:	83 ec 08             	sub    $0x8,%esp
f0105712:	0f b6 c0             	movzbl %al,%eax
f0105715:	50                   	push   %eax
f0105716:	68 1c 7c 10 f0       	push   $0xf0107c1c
f010571b:	e8 5e e1 ff ff       	call   f010387e <cprintf>
f0105720:	83 c4 10             	add    $0x10,%esp
f0105723:	e9 7e 01 00 00       	jmp    f01058a6 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105728:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f010572c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105730:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105735:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010573a:	01 ce                	add    %ecx,%esi
f010573c:	eb 0d                	jmp    f010574b <mp_init+0x18f>
f010573e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105745:	f0 
f0105746:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105748:	83 c0 01             	add    $0x1,%eax
f010574b:	39 c7                	cmp    %eax,%edi
f010574d:	75 ef                	jne    f010573e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010574f:	89 d0                	mov    %edx,%eax
f0105751:	02 43 2a             	add    0x2a(%ebx),%al
f0105754:	74 15                	je     f010576b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105756:	83 ec 0c             	sub    $0xc,%esp
f0105759:	68 3c 7c 10 f0       	push   $0xf0107c3c
f010575e:	e8 1b e1 ff ff       	call   f010387e <cprintf>
f0105763:	83 c4 10             	add    $0x10,%esp
f0105766:	e9 3b 01 00 00       	jmp    f01058a6 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010576b:	85 db                	test   %ebx,%ebx
f010576d:	0f 84 33 01 00 00    	je     f01058a6 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105773:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f010577a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010577d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105780:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105785:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105788:	be 00 00 00 00       	mov    $0x0,%esi
f010578d:	e9 85 00 00 00       	jmp    f0105817 <mp_init+0x25b>
		switch (*p) {
f0105792:	0f b6 07             	movzbl (%edi),%eax
f0105795:	84 c0                	test   %al,%al
f0105797:	74 06                	je     f010579f <mp_init+0x1e3>
f0105799:	3c 04                	cmp    $0x4,%al
f010579b:	77 55                	ja     f01057f2 <mp_init+0x236>
f010579d:	eb 4e                	jmp    f01057ed <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010579f:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01057a3:	74 11                	je     f01057b6 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01057a5:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01057ac:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01057b1:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f01057b6:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f01057bb:	83 f8 07             	cmp    $0x7,%eax
f01057be:	7f 13                	jg     f01057d3 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01057c0:	6b d0 74             	imul   $0x74,%eax,%edx
f01057c3:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f01057c9:	83 c0 01             	add    $0x1,%eax
f01057cc:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f01057d1:	eb 15                	jmp    f01057e8 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01057d3:	83 ec 08             	sub    $0x8,%esp
f01057d6:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01057da:	50                   	push   %eax
f01057db:	68 6c 7c 10 f0       	push   $0xf0107c6c
f01057e0:	e8 99 e0 ff ff       	call   f010387e <cprintf>
f01057e5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01057e8:	83 c7 14             	add    $0x14,%edi
			continue;
f01057eb:	eb 27                	jmp    f0105814 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01057ed:	83 c7 08             	add    $0x8,%edi
			continue;
f01057f0:	eb 22                	jmp    f0105814 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01057f2:	83 ec 08             	sub    $0x8,%esp
f01057f5:	0f b6 c0             	movzbl %al,%eax
f01057f8:	50                   	push   %eax
f01057f9:	68 94 7c 10 f0       	push   $0xf0107c94
f01057fe:	e8 7b e0 ff ff       	call   f010387e <cprintf>
			ismp = 0;
f0105803:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f010580a:	00 00 00 
			i = conf->entry;
f010580d:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105811:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105814:	83 c6 01             	add    $0x1,%esi
f0105817:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010581b:	39 c6                	cmp    %eax,%esi
f010581d:	0f 82 6f ff ff ff    	jb     f0105792 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105823:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f0105828:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010582f:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f0105836:	75 26                	jne    f010585e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105838:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f010583f:	00 00 00 
		lapicaddr = 0;
f0105842:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f0105849:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010584c:	83 ec 0c             	sub    $0xc,%esp
f010584f:	68 b4 7c 10 f0       	push   $0xf0107cb4
f0105854:	e8 25 e0 ff ff       	call   f010387e <cprintf>
		return;
f0105859:	83 c4 10             	add    $0x10,%esp
f010585c:	eb 48                	jmp    f01058a6 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010585e:	83 ec 04             	sub    $0x4,%esp
f0105861:	ff 35 c4 c3 22 f0    	pushl  0xf022c3c4
f0105867:	0f b6 00             	movzbl (%eax),%eax
f010586a:	50                   	push   %eax
f010586b:	68 3b 7d 10 f0       	push   $0xf0107d3b
f0105870:	e8 09 e0 ff ff       	call   f010387e <cprintf>

	if (mp->imcrp) {
f0105875:	83 c4 10             	add    $0x10,%esp
f0105878:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010587b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010587f:	74 25                	je     f01058a6 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105881:	83 ec 0c             	sub    $0xc,%esp
f0105884:	68 e0 7c 10 f0       	push   $0xf0107ce0
f0105889:	e8 f0 df ff ff       	call   f010387e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010588e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105893:	b8 70 00 00 00       	mov    $0x70,%eax
f0105898:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105899:	ba 23 00 00 00       	mov    $0x23,%edx
f010589e:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010589f:	83 c8 01             	or     $0x1,%eax
f01058a2:	ee                   	out    %al,(%dx)
f01058a3:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01058a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058a9:	5b                   	pop    %ebx
f01058aa:	5e                   	pop    %esi
f01058ab:	5f                   	pop    %edi
f01058ac:	5d                   	pop    %ebp
f01058ad:	c3                   	ret    

f01058ae <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01058ae:	55                   	push   %ebp
f01058af:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01058b1:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f01058b7:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01058ba:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01058bc:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01058c1:	8b 40 20             	mov    0x20(%eax),%eax
//	panic("after lapicw.\n");
}
f01058c4:	5d                   	pop    %ebp
f01058c5:	c3                   	ret    

f01058c6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01058c6:	55                   	push   %ebp
f01058c7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01058c9:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01058ce:	85 c0                	test   %eax,%eax
f01058d0:	74 08                	je     f01058da <cpunum+0x14>
		return lapic[ID] >> 24;
f01058d2:	8b 40 20             	mov    0x20(%eax),%eax
f01058d5:	c1 e8 18             	shr    $0x18,%eax
f01058d8:	eb 05                	jmp    f01058df <cpunum+0x19>
	return 0;
f01058da:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01058df:	5d                   	pop    %ebp
f01058e0:	c3                   	ret    

f01058e1 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01058e1:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f01058e6:	85 c0                	test   %eax,%eax
f01058e8:	0f 84 21 01 00 00    	je     f0105a0f <lapic_init+0x12e>
//	panic("after lapicw.\n");
}

void
lapic_init(void)
{
f01058ee:	55                   	push   %ebp
f01058ef:	89 e5                	mov    %esp,%ebp
f01058f1:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01058f4:	68 00 10 00 00       	push   $0x1000
f01058f9:	50                   	push   %eax
f01058fa:	e8 ed ba ff ff       	call   f01013ec <mmio_map_region>
f01058ff:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105904:	ba 27 01 00 00       	mov    $0x127,%edx
f0105909:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010590e:	e8 9b ff ff ff       	call   f01058ae <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105913:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105918:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010591d:	e8 8c ff ff ff       	call   f01058ae <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105922:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105927:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010592c:	e8 7d ff ff ff       	call   f01058ae <lapicw>
	lapicw(TICR, 10000000); 
f0105931:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105936:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010593b:	e8 6e ff ff ff       	call   f01058ae <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105940:	e8 81 ff ff ff       	call   f01058c6 <cpunum>
f0105945:	6b c0 74             	imul   $0x74,%eax,%eax
f0105948:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f010594d:	83 c4 10             	add    $0x10,%esp
f0105950:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f0105956:	74 0f                	je     f0105967 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105958:	ba 00 00 01 00       	mov    $0x10000,%edx
f010595d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105962:	e8 47 ff ff ff       	call   f01058ae <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105967:	ba 00 00 01 00       	mov    $0x10000,%edx
f010596c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105971:	e8 38 ff ff ff       	call   f01058ae <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105976:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f010597b:	8b 40 30             	mov    0x30(%eax),%eax
f010597e:	c1 e8 10             	shr    $0x10,%eax
f0105981:	3c 03                	cmp    $0x3,%al
f0105983:	76 0f                	jbe    f0105994 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105985:	ba 00 00 01 00       	mov    $0x10000,%edx
f010598a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010598f:	e8 1a ff ff ff       	call   f01058ae <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105994:	ba 33 00 00 00       	mov    $0x33,%edx
f0105999:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010599e:	e8 0b ff ff ff       	call   f01058ae <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01059a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01059a8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01059ad:	e8 fc fe ff ff       	call   f01058ae <lapicw>
	lapicw(ESR, 0);
f01059b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01059b7:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01059bc:	e8 ed fe ff ff       	call   f01058ae <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01059c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01059c6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01059cb:	e8 de fe ff ff       	call   f01058ae <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01059d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01059d5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01059da:	e8 cf fe ff ff       	call   f01058ae <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01059df:	ba 00 85 08 00       	mov    $0x88500,%edx
f01059e4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059e9:	e8 c0 fe ff ff       	call   f01058ae <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01059ee:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f01059f4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01059fa:	f6 c4 10             	test   $0x10,%ah
f01059fd:	75 f5                	jne    f01059f4 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01059ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a04:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a09:	e8 a0 fe ff ff       	call   f01058ae <lapicw>
}
f0105a0e:	c9                   	leave  
f0105a0f:	f3 c3                	repz ret 

f0105a11 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105a11:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f0105a18:	74 13                	je     f0105a2d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105a1a:	55                   	push   %ebp
f0105a1b:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105a1d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a22:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105a27:	e8 82 fe ff ff       	call   f01058ae <lapicw>
}
f0105a2c:	5d                   	pop    %ebp
f0105a2d:	f3 c3                	repz ret 

f0105a2f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105a2f:	55                   	push   %ebp
f0105a30:	89 e5                	mov    %esp,%ebp
f0105a32:	56                   	push   %esi
f0105a33:	53                   	push   %ebx
f0105a34:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a3a:	ba 70 00 00 00       	mov    $0x70,%edx
f0105a3f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105a44:	ee                   	out    %al,(%dx)
f0105a45:	ba 71 00 00 00       	mov    $0x71,%edx
f0105a4a:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a4f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a50:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105a57:	75 19                	jne    f0105a72 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a59:	68 67 04 00 00       	push   $0x467
f0105a5e:	68 14 60 10 f0       	push   $0xf0106014
f0105a63:	68 99 00 00 00       	push   $0x99
f0105a68:	68 58 7d 10 f0       	push   $0xf0107d58
f0105a6d:	e8 22 a6 ff ff       	call   f0100094 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105a72:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105a79:	00 00 
	wrv[1] = addr >> 4;
f0105a7b:	89 d8                	mov    %ebx,%eax
f0105a7d:	c1 e8 04             	shr    $0x4,%eax
f0105a80:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105a86:	c1 e6 18             	shl    $0x18,%esi
f0105a89:	89 f2                	mov    %esi,%edx
f0105a8b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a90:	e8 19 fe ff ff       	call   f01058ae <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105a95:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105a9a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a9f:	e8 0a fe ff ff       	call   f01058ae <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105aa4:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105aa9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105aae:	e8 fb fd ff ff       	call   f01058ae <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ab3:	c1 eb 0c             	shr    $0xc,%ebx
f0105ab6:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ab9:	89 f2                	mov    %esi,%edx
f0105abb:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ac0:	e8 e9 fd ff ff       	call   f01058ae <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105ac5:	89 da                	mov    %ebx,%edx
f0105ac7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105acc:	e8 dd fd ff ff       	call   f01058ae <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105ad1:	89 f2                	mov    %esi,%edx
f0105ad3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105ad8:	e8 d1 fd ff ff       	call   f01058ae <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105add:	89 da                	mov    %ebx,%edx
f0105adf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105ae4:	e8 c5 fd ff ff       	call   f01058ae <lapicw>
		microdelay(200);
	}
}
f0105ae9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105aec:	5b                   	pop    %ebx
f0105aed:	5e                   	pop    %esi
f0105aee:	5d                   	pop    %ebp
f0105aef:	c3                   	ret    

f0105af0 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105af0:	55                   	push   %ebp
f0105af1:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105af3:	8b 55 08             	mov    0x8(%ebp),%edx
f0105af6:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105afc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b01:	e8 a8 fd ff ff       	call   f01058ae <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105b06:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105b0c:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105b12:	f6 c4 10             	test   $0x10,%ah
f0105b15:	75 f5                	jne    f0105b0c <lapic_ipi+0x1c>
		;
}
f0105b17:	5d                   	pop    %ebp
f0105b18:	c3                   	ret    

f0105b19 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105b19:	55                   	push   %ebp
f0105b1a:	89 e5                	mov    %esp,%ebp
f0105b1c:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105b1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105b25:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b28:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105b2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105b32:	5d                   	pop    %ebp
f0105b33:	c3                   	ret    

f0105b34 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105b34:	55                   	push   %ebp
f0105b35:	89 e5                	mov    %esp,%ebp
f0105b37:	56                   	push   %esi
f0105b38:	53                   	push   %ebx
f0105b39:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105b3c:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105b3f:	74 14                	je     f0105b55 <spin_lock+0x21>
f0105b41:	8b 73 08             	mov    0x8(%ebx),%esi
f0105b44:	e8 7d fd ff ff       	call   f01058c6 <cpunum>
f0105b49:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b4c:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105b51:	39 c6                	cmp    %eax,%esi
f0105b53:	74 07                	je     f0105b5c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105b55:	ba 01 00 00 00       	mov    $0x1,%edx
f0105b5a:	eb 20                	jmp    f0105b7c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105b5c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105b5f:	e8 62 fd ff ff       	call   f01058c6 <cpunum>
f0105b64:	83 ec 0c             	sub    $0xc,%esp
f0105b67:	53                   	push   %ebx
f0105b68:	50                   	push   %eax
f0105b69:	68 68 7d 10 f0       	push   $0xf0107d68
f0105b6e:	6a 41                	push   $0x41
f0105b70:	68 cc 7d 10 f0       	push   $0xf0107dcc
f0105b75:	e8 1a a5 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105b7a:	f3 90                	pause  
f0105b7c:	89 d0                	mov    %edx,%eax
f0105b7e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105b81:	85 c0                	test   %eax,%eax
f0105b83:	75 f5                	jne    f0105b7a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105b85:	e8 3c fd ff ff       	call   f01058c6 <cpunum>
f0105b8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b8d:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105b92:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105b95:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105b98:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105b9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b9f:	eb 0b                	jmp    f0105bac <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105ba1:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105ba4:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105ba7:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105ba9:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105bac:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105bb2:	76 11                	jbe    f0105bc5 <spin_lock+0x91>
f0105bb4:	83 f8 09             	cmp    $0x9,%eax
f0105bb7:	7e e8                	jle    f0105ba1 <spin_lock+0x6d>
f0105bb9:	eb 0a                	jmp    f0105bc5 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105bbb:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105bc2:	83 c0 01             	add    $0x1,%eax
f0105bc5:	83 f8 09             	cmp    $0x9,%eax
f0105bc8:	7e f1                	jle    f0105bbb <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105bca:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105bcd:	5b                   	pop    %ebx
f0105bce:	5e                   	pop    %esi
f0105bcf:	5d                   	pop    %ebp
f0105bd0:	c3                   	ret    

f0105bd1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105bd1:	55                   	push   %ebp
f0105bd2:	89 e5                	mov    %esp,%ebp
f0105bd4:	57                   	push   %edi
f0105bd5:	56                   	push   %esi
f0105bd6:	53                   	push   %ebx
f0105bd7:	83 ec 4c             	sub    $0x4c,%esp
f0105bda:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105bdd:	83 3e 00             	cmpl   $0x0,(%esi)
f0105be0:	74 18                	je     f0105bfa <spin_unlock+0x29>
f0105be2:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105be5:	e8 dc fc ff ff       	call   f01058c6 <cpunum>
f0105bea:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bed:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105bf2:	39 c3                	cmp    %eax,%ebx
f0105bf4:	0f 84 a5 00 00 00    	je     f0105c9f <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105bfa:	83 ec 04             	sub    $0x4,%esp
f0105bfd:	6a 28                	push   $0x28
f0105bff:	8d 46 0c             	lea    0xc(%esi),%eax
f0105c02:	50                   	push   %eax
f0105c03:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105c06:	53                   	push   %ebx
f0105c07:	e8 e4 f6 ff ff       	call   f01052f0 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105c0c:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105c0f:	0f b6 38             	movzbl (%eax),%edi
f0105c12:	8b 76 04             	mov    0x4(%esi),%esi
f0105c15:	e8 ac fc ff ff       	call   f01058c6 <cpunum>
f0105c1a:	57                   	push   %edi
f0105c1b:	56                   	push   %esi
f0105c1c:	50                   	push   %eax
f0105c1d:	68 94 7d 10 f0       	push   $0xf0107d94
f0105c22:	e8 57 dc ff ff       	call   f010387e <cprintf>
f0105c27:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105c2a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105c2d:	eb 54                	jmp    f0105c83 <spin_unlock+0xb2>
f0105c2f:	83 ec 08             	sub    $0x8,%esp
f0105c32:	57                   	push   %edi
f0105c33:	50                   	push   %eax
f0105c34:	e8 c1 ec ff ff       	call   f01048fa <debuginfo_eip>
f0105c39:	83 c4 10             	add    $0x10,%esp
f0105c3c:	85 c0                	test   %eax,%eax
f0105c3e:	78 27                	js     f0105c67 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105c40:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105c42:	83 ec 04             	sub    $0x4,%esp
f0105c45:	89 c2                	mov    %eax,%edx
f0105c47:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105c4a:	52                   	push   %edx
f0105c4b:	ff 75 b0             	pushl  -0x50(%ebp)
f0105c4e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105c51:	ff 75 ac             	pushl  -0x54(%ebp)
f0105c54:	ff 75 a8             	pushl  -0x58(%ebp)
f0105c57:	50                   	push   %eax
f0105c58:	68 dc 7d 10 f0       	push   $0xf0107ddc
f0105c5d:	e8 1c dc ff ff       	call   f010387e <cprintf>
f0105c62:	83 c4 20             	add    $0x20,%esp
f0105c65:	eb 12                	jmp    f0105c79 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105c67:	83 ec 08             	sub    $0x8,%esp
f0105c6a:	ff 36                	pushl  (%esi)
f0105c6c:	68 f3 7d 10 f0       	push   $0xf0107df3
f0105c71:	e8 08 dc ff ff       	call   f010387e <cprintf>
f0105c76:	83 c4 10             	add    $0x10,%esp
f0105c79:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105c7c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105c7f:	39 c3                	cmp    %eax,%ebx
f0105c81:	74 08                	je     f0105c8b <spin_unlock+0xba>
f0105c83:	89 de                	mov    %ebx,%esi
f0105c85:	8b 03                	mov    (%ebx),%eax
f0105c87:	85 c0                	test   %eax,%eax
f0105c89:	75 a4                	jne    f0105c2f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105c8b:	83 ec 04             	sub    $0x4,%esp
f0105c8e:	68 fb 7d 10 f0       	push   $0xf0107dfb
f0105c93:	6a 67                	push   $0x67
f0105c95:	68 cc 7d 10 f0       	push   $0xf0107dcc
f0105c9a:	e8 f5 a3 ff ff       	call   f0100094 <_panic>
	}

	lk->pcs[0] = 0;
f0105c9f:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105ca6:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105cad:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cb2:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cb8:	5b                   	pop    %ebx
f0105cb9:	5e                   	pop    %esi
f0105cba:	5f                   	pop    %edi
f0105cbb:	5d                   	pop    %ebp
f0105cbc:	c3                   	ret    
f0105cbd:	66 90                	xchg   %ax,%ax
f0105cbf:	90                   	nop

f0105cc0 <__udivdi3>:
f0105cc0:	55                   	push   %ebp
f0105cc1:	57                   	push   %edi
f0105cc2:	56                   	push   %esi
f0105cc3:	53                   	push   %ebx
f0105cc4:	83 ec 1c             	sub    $0x1c,%esp
f0105cc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105ccb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105ccf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105cd7:	85 f6                	test   %esi,%esi
f0105cd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105cdd:	89 ca                	mov    %ecx,%edx
f0105cdf:	89 f8                	mov    %edi,%eax
f0105ce1:	75 3d                	jne    f0105d20 <__udivdi3+0x60>
f0105ce3:	39 cf                	cmp    %ecx,%edi
f0105ce5:	0f 87 c5 00 00 00    	ja     f0105db0 <__udivdi3+0xf0>
f0105ceb:	85 ff                	test   %edi,%edi
f0105ced:	89 fd                	mov    %edi,%ebp
f0105cef:	75 0b                	jne    f0105cfc <__udivdi3+0x3c>
f0105cf1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105cf6:	31 d2                	xor    %edx,%edx
f0105cf8:	f7 f7                	div    %edi
f0105cfa:	89 c5                	mov    %eax,%ebp
f0105cfc:	89 c8                	mov    %ecx,%eax
f0105cfe:	31 d2                	xor    %edx,%edx
f0105d00:	f7 f5                	div    %ebp
f0105d02:	89 c1                	mov    %eax,%ecx
f0105d04:	89 d8                	mov    %ebx,%eax
f0105d06:	89 cf                	mov    %ecx,%edi
f0105d08:	f7 f5                	div    %ebp
f0105d0a:	89 c3                	mov    %eax,%ebx
f0105d0c:	89 d8                	mov    %ebx,%eax
f0105d0e:	89 fa                	mov    %edi,%edx
f0105d10:	83 c4 1c             	add    $0x1c,%esp
f0105d13:	5b                   	pop    %ebx
f0105d14:	5e                   	pop    %esi
f0105d15:	5f                   	pop    %edi
f0105d16:	5d                   	pop    %ebp
f0105d17:	c3                   	ret    
f0105d18:	90                   	nop
f0105d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105d20:	39 ce                	cmp    %ecx,%esi
f0105d22:	77 74                	ja     f0105d98 <__udivdi3+0xd8>
f0105d24:	0f bd fe             	bsr    %esi,%edi
f0105d27:	83 f7 1f             	xor    $0x1f,%edi
f0105d2a:	0f 84 98 00 00 00    	je     f0105dc8 <__udivdi3+0x108>
f0105d30:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105d35:	89 f9                	mov    %edi,%ecx
f0105d37:	89 c5                	mov    %eax,%ebp
f0105d39:	29 fb                	sub    %edi,%ebx
f0105d3b:	d3 e6                	shl    %cl,%esi
f0105d3d:	89 d9                	mov    %ebx,%ecx
f0105d3f:	d3 ed                	shr    %cl,%ebp
f0105d41:	89 f9                	mov    %edi,%ecx
f0105d43:	d3 e0                	shl    %cl,%eax
f0105d45:	09 ee                	or     %ebp,%esi
f0105d47:	89 d9                	mov    %ebx,%ecx
f0105d49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d4d:	89 d5                	mov    %edx,%ebp
f0105d4f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d53:	d3 ed                	shr    %cl,%ebp
f0105d55:	89 f9                	mov    %edi,%ecx
f0105d57:	d3 e2                	shl    %cl,%edx
f0105d59:	89 d9                	mov    %ebx,%ecx
f0105d5b:	d3 e8                	shr    %cl,%eax
f0105d5d:	09 c2                	or     %eax,%edx
f0105d5f:	89 d0                	mov    %edx,%eax
f0105d61:	89 ea                	mov    %ebp,%edx
f0105d63:	f7 f6                	div    %esi
f0105d65:	89 d5                	mov    %edx,%ebp
f0105d67:	89 c3                	mov    %eax,%ebx
f0105d69:	f7 64 24 0c          	mull   0xc(%esp)
f0105d6d:	39 d5                	cmp    %edx,%ebp
f0105d6f:	72 10                	jb     f0105d81 <__udivdi3+0xc1>
f0105d71:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105d75:	89 f9                	mov    %edi,%ecx
f0105d77:	d3 e6                	shl    %cl,%esi
f0105d79:	39 c6                	cmp    %eax,%esi
f0105d7b:	73 07                	jae    f0105d84 <__udivdi3+0xc4>
f0105d7d:	39 d5                	cmp    %edx,%ebp
f0105d7f:	75 03                	jne    f0105d84 <__udivdi3+0xc4>
f0105d81:	83 eb 01             	sub    $0x1,%ebx
f0105d84:	31 ff                	xor    %edi,%edi
f0105d86:	89 d8                	mov    %ebx,%eax
f0105d88:	89 fa                	mov    %edi,%edx
f0105d8a:	83 c4 1c             	add    $0x1c,%esp
f0105d8d:	5b                   	pop    %ebx
f0105d8e:	5e                   	pop    %esi
f0105d8f:	5f                   	pop    %edi
f0105d90:	5d                   	pop    %ebp
f0105d91:	c3                   	ret    
f0105d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105d98:	31 ff                	xor    %edi,%edi
f0105d9a:	31 db                	xor    %ebx,%ebx
f0105d9c:	89 d8                	mov    %ebx,%eax
f0105d9e:	89 fa                	mov    %edi,%edx
f0105da0:	83 c4 1c             	add    $0x1c,%esp
f0105da3:	5b                   	pop    %ebx
f0105da4:	5e                   	pop    %esi
f0105da5:	5f                   	pop    %edi
f0105da6:	5d                   	pop    %ebp
f0105da7:	c3                   	ret    
f0105da8:	90                   	nop
f0105da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105db0:	89 d8                	mov    %ebx,%eax
f0105db2:	f7 f7                	div    %edi
f0105db4:	31 ff                	xor    %edi,%edi
f0105db6:	89 c3                	mov    %eax,%ebx
f0105db8:	89 d8                	mov    %ebx,%eax
f0105dba:	89 fa                	mov    %edi,%edx
f0105dbc:	83 c4 1c             	add    $0x1c,%esp
f0105dbf:	5b                   	pop    %ebx
f0105dc0:	5e                   	pop    %esi
f0105dc1:	5f                   	pop    %edi
f0105dc2:	5d                   	pop    %ebp
f0105dc3:	c3                   	ret    
f0105dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105dc8:	39 ce                	cmp    %ecx,%esi
f0105dca:	72 0c                	jb     f0105dd8 <__udivdi3+0x118>
f0105dcc:	31 db                	xor    %ebx,%ebx
f0105dce:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105dd2:	0f 87 34 ff ff ff    	ja     f0105d0c <__udivdi3+0x4c>
f0105dd8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105ddd:	e9 2a ff ff ff       	jmp    f0105d0c <__udivdi3+0x4c>
f0105de2:	66 90                	xchg   %ax,%ax
f0105de4:	66 90                	xchg   %ax,%ax
f0105de6:	66 90                	xchg   %ax,%ax
f0105de8:	66 90                	xchg   %ax,%ax
f0105dea:	66 90                	xchg   %ax,%ax
f0105dec:	66 90                	xchg   %ax,%ax
f0105dee:	66 90                	xchg   %ax,%ax

f0105df0 <__umoddi3>:
f0105df0:	55                   	push   %ebp
f0105df1:	57                   	push   %edi
f0105df2:	56                   	push   %esi
f0105df3:	53                   	push   %ebx
f0105df4:	83 ec 1c             	sub    $0x1c,%esp
f0105df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105dfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105dff:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105e07:	85 d2                	test   %edx,%edx
f0105e09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105e11:	89 f3                	mov    %esi,%ebx
f0105e13:	89 3c 24             	mov    %edi,(%esp)
f0105e16:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e1a:	75 1c                	jne    f0105e38 <__umoddi3+0x48>
f0105e1c:	39 f7                	cmp    %esi,%edi
f0105e1e:	76 50                	jbe    f0105e70 <__umoddi3+0x80>
f0105e20:	89 c8                	mov    %ecx,%eax
f0105e22:	89 f2                	mov    %esi,%edx
f0105e24:	f7 f7                	div    %edi
f0105e26:	89 d0                	mov    %edx,%eax
f0105e28:	31 d2                	xor    %edx,%edx
f0105e2a:	83 c4 1c             	add    $0x1c,%esp
f0105e2d:	5b                   	pop    %ebx
f0105e2e:	5e                   	pop    %esi
f0105e2f:	5f                   	pop    %edi
f0105e30:	5d                   	pop    %ebp
f0105e31:	c3                   	ret    
f0105e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105e38:	39 f2                	cmp    %esi,%edx
f0105e3a:	89 d0                	mov    %edx,%eax
f0105e3c:	77 52                	ja     f0105e90 <__umoddi3+0xa0>
f0105e3e:	0f bd ea             	bsr    %edx,%ebp
f0105e41:	83 f5 1f             	xor    $0x1f,%ebp
f0105e44:	75 5a                	jne    f0105ea0 <__umoddi3+0xb0>
f0105e46:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105e4a:	0f 82 e0 00 00 00    	jb     f0105f30 <__umoddi3+0x140>
f0105e50:	39 0c 24             	cmp    %ecx,(%esp)
f0105e53:	0f 86 d7 00 00 00    	jbe    f0105f30 <__umoddi3+0x140>
f0105e59:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105e5d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105e61:	83 c4 1c             	add    $0x1c,%esp
f0105e64:	5b                   	pop    %ebx
f0105e65:	5e                   	pop    %esi
f0105e66:	5f                   	pop    %edi
f0105e67:	5d                   	pop    %ebp
f0105e68:	c3                   	ret    
f0105e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105e70:	85 ff                	test   %edi,%edi
f0105e72:	89 fd                	mov    %edi,%ebp
f0105e74:	75 0b                	jne    f0105e81 <__umoddi3+0x91>
f0105e76:	b8 01 00 00 00       	mov    $0x1,%eax
f0105e7b:	31 d2                	xor    %edx,%edx
f0105e7d:	f7 f7                	div    %edi
f0105e7f:	89 c5                	mov    %eax,%ebp
f0105e81:	89 f0                	mov    %esi,%eax
f0105e83:	31 d2                	xor    %edx,%edx
f0105e85:	f7 f5                	div    %ebp
f0105e87:	89 c8                	mov    %ecx,%eax
f0105e89:	f7 f5                	div    %ebp
f0105e8b:	89 d0                	mov    %edx,%eax
f0105e8d:	eb 99                	jmp    f0105e28 <__umoddi3+0x38>
f0105e8f:	90                   	nop
f0105e90:	89 c8                	mov    %ecx,%eax
f0105e92:	89 f2                	mov    %esi,%edx
f0105e94:	83 c4 1c             	add    $0x1c,%esp
f0105e97:	5b                   	pop    %ebx
f0105e98:	5e                   	pop    %esi
f0105e99:	5f                   	pop    %edi
f0105e9a:	5d                   	pop    %ebp
f0105e9b:	c3                   	ret    
f0105e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105ea0:	8b 34 24             	mov    (%esp),%esi
f0105ea3:	bf 20 00 00 00       	mov    $0x20,%edi
f0105ea8:	89 e9                	mov    %ebp,%ecx
f0105eaa:	29 ef                	sub    %ebp,%edi
f0105eac:	d3 e0                	shl    %cl,%eax
f0105eae:	89 f9                	mov    %edi,%ecx
f0105eb0:	89 f2                	mov    %esi,%edx
f0105eb2:	d3 ea                	shr    %cl,%edx
f0105eb4:	89 e9                	mov    %ebp,%ecx
f0105eb6:	09 c2                	or     %eax,%edx
f0105eb8:	89 d8                	mov    %ebx,%eax
f0105eba:	89 14 24             	mov    %edx,(%esp)
f0105ebd:	89 f2                	mov    %esi,%edx
f0105ebf:	d3 e2                	shl    %cl,%edx
f0105ec1:	89 f9                	mov    %edi,%ecx
f0105ec3:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105ec7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105ecb:	d3 e8                	shr    %cl,%eax
f0105ecd:	89 e9                	mov    %ebp,%ecx
f0105ecf:	89 c6                	mov    %eax,%esi
f0105ed1:	d3 e3                	shl    %cl,%ebx
f0105ed3:	89 f9                	mov    %edi,%ecx
f0105ed5:	89 d0                	mov    %edx,%eax
f0105ed7:	d3 e8                	shr    %cl,%eax
f0105ed9:	89 e9                	mov    %ebp,%ecx
f0105edb:	09 d8                	or     %ebx,%eax
f0105edd:	89 d3                	mov    %edx,%ebx
f0105edf:	89 f2                	mov    %esi,%edx
f0105ee1:	f7 34 24             	divl   (%esp)
f0105ee4:	89 d6                	mov    %edx,%esi
f0105ee6:	d3 e3                	shl    %cl,%ebx
f0105ee8:	f7 64 24 04          	mull   0x4(%esp)
f0105eec:	39 d6                	cmp    %edx,%esi
f0105eee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105ef2:	89 d1                	mov    %edx,%ecx
f0105ef4:	89 c3                	mov    %eax,%ebx
f0105ef6:	72 08                	jb     f0105f00 <__umoddi3+0x110>
f0105ef8:	75 11                	jne    f0105f0b <__umoddi3+0x11b>
f0105efa:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105efe:	73 0b                	jae    f0105f0b <__umoddi3+0x11b>
f0105f00:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105f04:	1b 14 24             	sbb    (%esp),%edx
f0105f07:	89 d1                	mov    %edx,%ecx
f0105f09:	89 c3                	mov    %eax,%ebx
f0105f0b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105f0f:	29 da                	sub    %ebx,%edx
f0105f11:	19 ce                	sbb    %ecx,%esi
f0105f13:	89 f9                	mov    %edi,%ecx
f0105f15:	89 f0                	mov    %esi,%eax
f0105f17:	d3 e0                	shl    %cl,%eax
f0105f19:	89 e9                	mov    %ebp,%ecx
f0105f1b:	d3 ea                	shr    %cl,%edx
f0105f1d:	89 e9                	mov    %ebp,%ecx
f0105f1f:	d3 ee                	shr    %cl,%esi
f0105f21:	09 d0                	or     %edx,%eax
f0105f23:	89 f2                	mov    %esi,%edx
f0105f25:	83 c4 1c             	add    $0x1c,%esp
f0105f28:	5b                   	pop    %ebx
f0105f29:	5e                   	pop    %esi
f0105f2a:	5f                   	pop    %edi
f0105f2b:	5d                   	pop    %ebp
f0105f2c:	c3                   	ret    
f0105f2d:	8d 76 00             	lea    0x0(%esi),%esi
f0105f30:	29 f9                	sub    %edi,%ecx
f0105f32:	19 d6                	sbb    %edx,%esi
f0105f34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105f3c:	e9 18 ff ff ff       	jmp    f0105e59 <__umoddi3+0x69>
