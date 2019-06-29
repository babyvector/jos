
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
f010004b:	68 a0 5f 10 f0       	push   $0xf0105fa0
f0100050:	e8 16 38 00 00       	call   f010386b <cprintf>
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
f0100082:	68 bc 5f 10 f0       	push   $0xf0105fbc
f0100087:	e8 df 37 00 00       	call   f010386b <cprintf>


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
f01000b0:	e8 4d 58 00 00       	call   f0105902 <cpunum>
f01000b5:	ff 75 0c             	pushl  0xc(%ebp)
f01000b8:	ff 75 08             	pushl  0x8(%ebp)
f01000bb:	50                   	push   %eax
f01000bc:	68 30 60 10 f0       	push   $0xf0106030
f01000c1:	e8 a5 37 00 00       	call   f010386b <cprintf>
	vcprintf(fmt, ap);
f01000c6:	83 c4 08             	add    $0x8,%esp
f01000c9:	53                   	push   %ebx
f01000ca:	56                   	push   %esi
f01000cb:	e8 75 37 00 00       	call   f0103845 <vcprintf>
	cprintf("\n");
f01000d0:	c7 04 24 64 63 10 f0 	movl   $0xf0106364,(%esp)
f01000d7:	e8 8f 37 00 00       	call   f010386b <cprintf>
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
f0100107:	e8 d5 51 00 00       	call   f01052e1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010010c:	e8 8a 05 00 00       	call   f010069b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	68 ac 1a 00 00       	push   $0x1aac
f0100119:	68 d7 5f 10 f0       	push   $0xf0105fd7
f010011e:	e8 48 37 00 00       	call   f010386b <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100123:	e8 2a 13 00 00       	call   f0101452 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100128:	e8 4f 2f 00 00       	call   f010307c <env_init>

	trap_init();
f010012d:	e8 3a 38 00 00       	call   f010396c <trap_init>
	// Lab 4 multiprocessor initialization functions
	mp_init();
f0100132:	e8 c1 54 00 00       	call   f01055f8 <mp_init>
	lapic_init();
f0100137:	e8 e1 57 00 00       	call   f010591d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f010013c:	e8 51 36 00 00       	call   f0103792 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100141:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f0100148:	e8 23 5a 00 00       	call   f0105b70 <spin_lock>
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
f010015e:	68 54 60 10 f0       	push   $0xf0106054
f0100163:	6a 6d                	push   $0x6d
f0100165:	68 f2 5f 10 f0       	push   $0xf0105ff2
f010016a:	e8 25 ff ff ff       	call   f0100094 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010016f:	83 ec 04             	sub    $0x4,%esp
f0100172:	b8 5e 55 10 f0       	mov    $0xf010555e,%eax
f0100177:	2d e4 54 10 f0       	sub    $0xf01054e4,%eax
f010017c:	50                   	push   %eax
f010017d:	68 e4 54 10 f0       	push   $0xf01054e4
f0100182:	68 00 70 00 f0       	push   $0xf0007000
f0100187:	e8 a2 51 00 00       	call   f010532e <memmove>
f010018c:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018f:	bb 20 c0 22 f0       	mov    $0xf022c020,%ebx
f0100194:	eb 4d                	jmp    f01001e3 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100196:	e8 67 57 00 00       	call   f0105902 <cpunum>
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
f01001d0:	e8 96 58 00 00       	call   f0105a6b <lapic_startap>
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
f0100202:	e8 81 40 00 00       	call   f0104288 <sched_yield>

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
f010021a:	68 78 60 10 f0       	push   $0xf0106078
f010021f:	68 85 00 00 00       	push   $0x85
f0100224:	68 f2 5f 10 f0       	push   $0xf0105ff2
f0100229:	e8 66 fe ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010022e:	05 00 00 00 10       	add    $0x10000000,%eax
f0100233:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100236:	e8 c7 56 00 00       	call   f0105902 <cpunum>
f010023b:	83 ec 08             	sub    $0x8,%esp
f010023e:	50                   	push   %eax
f010023f:	68 fe 5f 10 f0       	push   $0xf0105ffe
f0100244:	e8 22 36 00 00       	call   f010386b <cprintf>

	lapic_init();
f0100249:	e8 cf 56 00 00       	call   f010591d <lapic_init>
	env_init_percpu();
f010024e:	e8 f9 2d 00 00       	call   f010304c <env_init_percpu>
	trap_init_percpu();
f0100253:	e8 27 36 00 00       	call   f010387f <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100258:	e8 a5 56 00 00       	call   f0105902 <cpunum>
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
f0100276:	e8 f5 58 00 00       	call   f0105b70 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f010027b:	e8 08 40 00 00       	call   f0104288 <sched_yield>

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
f0100290:	68 14 60 10 f0       	push   $0xf0106014
f0100295:	e8 d1 35 00 00       	call   f010386b <cprintf>
	vcprintf(fmt, ap);
f010029a:	83 c4 08             	add    $0x8,%esp
f010029d:	53                   	push   %ebx
f010029e:	ff 75 10             	pushl  0x10(%ebp)
f01002a1:	e8 9f 35 00 00       	call   f0103845 <vcprintf>
	cprintf("\n");
f01002a6:	c7 04 24 64 63 10 f0 	movl   $0xf0106364,(%esp)
f01002ad:	e8 b9 35 00 00       	call   f010386b <cprintf>
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
f010036c:	0f b6 82 00 62 10 f0 	movzbl -0xfef9e00(%edx),%eax
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
f01003a8:	0f b6 82 00 62 10 f0 	movzbl -0xfef9e00(%edx),%eax
f01003af:	0b 05 00 b0 22 f0    	or     0xf022b000,%eax
f01003b5:	0f b6 8a 00 61 10 f0 	movzbl -0xfef9f00(%edx),%ecx
f01003bc:	31 c8                	xor    %ecx,%eax
f01003be:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	c = charcode[shift & (CTL | SHIFT)][data];
f01003c3:	89 c1                	mov    %eax,%ecx
f01003c5:	83 e1 03             	and    $0x3,%ecx
f01003c8:	8b 0c 8d e0 60 10 f0 	mov    -0xfef9f20(,%ecx,4),%ecx
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
f0100406:	68 9c 60 10 f0       	push   $0xf010609c
f010040b:	e8 5b 34 00 00       	call   f010386b <cprintf>
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
f01005be:	e8 6b 4d 00 00       	call   f010532e <memmove>
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
f0100733:	e8 e2 2f 00 00       	call   f010371a <irq_setmask_8259A>
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
f01007ab:	68 a8 60 10 f0       	push   $0xf01060a8
f01007b0:	e8 b6 30 00 00       	call   f010386b <cprintf>
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
f01007fa:	bb 00 66 10 f0       	mov    $0xf0106600,%ebx
f01007ff:	be 30 66 10 f0       	mov    $0xf0106630,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100804:	83 ec 04             	sub    $0x4,%esp
f0100807:	ff 73 04             	pushl  0x4(%ebx)
f010080a:	ff 33                	pushl  (%ebx)
f010080c:	68 00 63 10 f0       	push   $0xf0106300
f0100811:	e8 55 30 00 00       	call   f010386b <cprintf>
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
f0100832:	68 09 63 10 f0       	push   $0xf0106309
f0100837:	e8 2f 30 00 00       	call   f010386b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010083c:	83 c4 08             	add    $0x8,%esp
f010083f:	68 0c 00 10 00       	push   $0x10000c
f0100844:	68 04 64 10 f0       	push   $0xf0106404
f0100849:	e8 1d 30 00 00       	call   f010386b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 0c 00 10 00       	push   $0x10000c
f0100856:	68 0c 00 10 f0       	push   $0xf010000c
f010085b:	68 2c 64 10 f0       	push   $0xf010642c
f0100860:	e8 06 30 00 00       	call   f010386b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 81 5f 10 00       	push   $0x105f81
f010086d:	68 81 5f 10 f0       	push   $0xf0105f81
f0100872:	68 50 64 10 f0       	push   $0xf0106450
f0100877:	e8 ef 2f 00 00       	call   f010386b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010087c:	83 c4 0c             	add    $0xc,%esp
f010087f:	68 98 a5 22 00       	push   $0x22a598
f0100884:	68 98 a5 22 f0       	push   $0xf022a598
f0100889:	68 74 64 10 f0       	push   $0xf0106474
f010088e:	e8 d8 2f 00 00       	call   f010386b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100893:	83 c4 0c             	add    $0xc,%esp
f0100896:	68 08 d0 26 00       	push   $0x26d008
f010089b:	68 08 d0 26 f0       	push   $0xf026d008
f01008a0:	68 98 64 10 f0       	push   $0xf0106498
f01008a5:	e8 c1 2f 00 00       	call   f010386b <cprintf>
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
f01008cb:	68 bc 64 10 f0       	push   $0xf01064bc
f01008d0:	e8 96 2f 00 00       	call   f010386b <cprintf>
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
f0100906:	68 e8 64 10 f0       	push   $0xf01064e8
f010090b:	e8 5b 2f 00 00       	call   f010386b <cprintf>
		
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f0100910:	83 c4 18             	add    $0x18,%esp
f0100913:	57                   	push   %edi
f0100914:	53                   	push   %ebx
f0100915:	e8 1e 40 00 00       	call   f0104938 <debuginfo_eip>
		cprintf("%s:%d   %s:%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip-info.eip_fn_addr);	
f010091a:	2b 5d e0             	sub    -0x20(%ebp),%ebx
f010091d:	89 1c 24             	mov    %ebx,(%esp)
f0100920:	ff 75 d8             	pushl  -0x28(%ebp)
f0100923:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100926:	ff 75 d0             	pushl  -0x30(%ebp)
f0100929:	68 22 63 10 f0       	push   $0xf0106322
f010092e:	e8 38 2f 00 00       	call   f010386b <cprintf>
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
f010095c:	68 2c 65 10 f0       	push   $0xf010652c
f0100961:	e8 05 2f 00 00       	call   f010386b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100966:	c7 04 24 50 65 10 f0 	movl   $0xf0106550,(%esp)
f010096d:	e8 f9 2e 00 00       	call   f010386b <cprintf>


	if (tf != NULL)
f0100972:	83 c4 10             	add    $0x10,%esp
f0100975:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100979:	74 0e                	je     f0100989 <monitor+0x36>
		print_trapframe(tf);
f010097b:	83 ec 0c             	sub    $0xc,%esp
f010097e:	ff 75 08             	pushl  0x8(%ebp)
f0100981:	e8 87 33 00 00       	call   f0103d0d <print_trapframe>
f0100986:	83 c4 10             	add    $0x10,%esp


	//my code here 
	cprintf("here show code of myself\n");
f0100989:	83 ec 0c             	sub    $0xc,%esp
f010098c:	68 31 63 10 f0       	push   $0xf0106331
f0100991:	e8 d5 2e 00 00       	call   f010386b <cprintf>
	for(int i = 0;i<200;i++){
		cprintf("%d",i);
		cprintf("abcdefghijklmnopqrstuvwxyz0123456789");
	}
	*/
	cprintf("yourname is xuyongkang.");
f0100996:	c7 04 24 4b 63 10 f0 	movl   $0xf010634b,(%esp)
f010099d:	e8 c9 2e 00 00       	call   f010386b <cprintf>
	cprintf("\033[1m\033[45;33m HELLO_WORLD \033[0m\n");
f01009a2:	c7 04 24 78 65 10 f0 	movl   $0xf0106578,(%esp)
f01009a9:	e8 bd 2e 00 00       	call   f010386b <cprintf>
	cprintf("\a\n");
f01009ae:	c7 04 24 63 63 10 f0 	movl   $0xf0106363,(%esp)
f01009b5:	e8 b1 2e 00 00       	call   f010386b <cprintf>
	cprintf("\a\n");
f01009ba:	c7 04 24 63 63 10 f0 	movl   $0xf0106363,(%esp)
f01009c1:	e8 a5 2e 00 00       	call   f010386b <cprintf>
	int x = 1,y = 3,z = 4;
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009c6:	6a 04                	push   $0x4
f01009c8:	6a 03                	push   $0x3
f01009ca:	6a 01                	push   $0x1
f01009cc:	68 66 63 10 f0       	push   $0xf0106366
f01009d1:	e8 95 2e 00 00       	call   f010386b <cprintf>
	cprintf("x %d,y %x,z %x\n",x,y,z);
f01009d6:	83 c4 20             	add    $0x20,%esp
f01009d9:	6a 04                	push   $0x4
f01009db:	6a 03                	push   $0x3
f01009dd:	6a 01                	push   $0x1
f01009df:	68 66 63 10 f0       	push   $0xf0106366
f01009e4:	e8 82 2e 00 00       	call   f010386b <cprintf>
 	cprintf("x,y,x");
f01009e9:	c7 04 24 76 63 10 f0 	movl   $0xf0106376,(%esp)
f01009f0:	e8 76 2e 00 00       	call   f010386b <cprintf>
f01009f5:	83 c4 10             	add    $0x10,%esp
       

	//my code end

	while (1) {
		buf = readline("K> ");
f01009f8:	83 ec 0c             	sub    $0xc,%esp
f01009fb:	68 7c 63 10 f0       	push   $0xf010637c
f0100a00:	e8 85 46 00 00       	call   f010508a <readline>
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
f0100a34:	68 80 63 10 f0       	push   $0xf0106380
f0100a39:	e8 66 48 00 00       	call   f01052a4 <strchr>
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
f0100a54:	68 85 63 10 f0       	push   $0xf0106385
f0100a59:	e8 0d 2e 00 00       	call   f010386b <cprintf>
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
f0100a7d:	68 80 63 10 f0       	push   $0xf0106380
f0100a82:	e8 1d 48 00 00       	call   f01052a4 <strchr>
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
f0100aab:	ff 34 85 00 66 10 f0 	pushl  -0xfef9a00(,%eax,4)
f0100ab2:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ab5:	e8 8c 47 00 00       	call   f0105246 <strcmp>
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
f0100acf:	ff 14 85 08 66 10 f0 	call   *-0xfef99f8(,%eax,4)
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
f0100af0:	68 a2 63 10 f0       	push   $0xf01063a2
f0100af5:	e8 71 2d 00 00       	call   f010386b <cprintf>
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
f0100b51:	e8 96 2b 00 00       	call   f01036ec <mc146818_read>
f0100b56:	89 c6                	mov    %eax,%esi
f0100b58:	83 c3 01             	add    $0x1,%ebx
f0100b5b:	89 1c 24             	mov    %ebx,(%esp)
f0100b5e:	e8 89 2b 00 00       	call   f01036ec <mc146818_read>
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
f0100b94:	68 54 60 10 f0       	push   $0xf0106054
f0100b99:	68 44 05 00 00       	push   $0x544
f0100b9e:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0100bec:	68 30 66 10 f0       	push   $0xf0106630
f0100bf1:	68 46 04 00 00       	push   $0x446
f0100bf6:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0100c7b:	68 54 60 10 f0       	push   $0xf0106054
f0100c80:	6a 58                	push   $0x58
f0100c82:	68 ad 6f 10 f0       	push   $0xf0106fad
f0100c87:	e8 08 f4 ff ff       	call   f0100094 <_panic>
			//cprintf("PageInfo.size():%x\n",sizeof(struct PageInfo));

			//:/cprintf("#check_page_free_list:page2kva(pp):%x\n",page2kva(pp));
			memset(page2kva(pp), 0x00, 128);
f0100c8c:	83 ec 04             	sub    $0x4,%esp
f0100c8f:	68 80 00 00 00       	push   $0x80
f0100c94:	6a 00                	push   $0x0
f0100c96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c9b:	50                   	push   %eax
f0100c9c:	e8 40 46 00 00       	call   f01052e1 <memset>
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
f0100ce2:	68 bb 6f 10 f0       	push   $0xf0106fbb
f0100ce7:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100cec:	68 6d 04 00 00       	push   $0x46d
f0100cf1:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100cf6:	e8 99 f3 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100cfb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cfe:	72 19                	jb     f0100d19 <check_page_free_list+0x146>
f0100d00:	68 dc 6f 10 f0       	push   $0xf0106fdc
f0100d05:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100d0a:	68 6e 04 00 00       	push   $0x46e
f0100d0f:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100d14:	e8 7b f3 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d19:	89 d0                	mov    %edx,%eax
f0100d1b:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d1e:	a8 07                	test   $0x7,%al
f0100d20:	74 19                	je     f0100d3b <check_page_free_list+0x168>
f0100d22:	68 54 66 10 f0       	push   $0xf0106654
f0100d27:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100d2c:	68 6f 04 00 00       	push   $0x46f
f0100d31:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0100d45:	68 f0 6f 10 f0       	push   $0xf0106ff0
f0100d4a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100d4f:	68 75 04 00 00       	push   $0x475
f0100d54:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100d59:	e8 36 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d5e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d63:	75 19                	jne    f0100d7e <check_page_free_list+0x1ab>
f0100d65:	68 01 70 10 f0       	push   $0xf0107001
f0100d6a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100d6f:	68 76 04 00 00       	push   $0x476
f0100d74:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100d79:	e8 16 f3 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d7e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d83:	75 19                	jne    f0100d9e <check_page_free_list+0x1cb>
f0100d85:	68 88 66 10 f0       	push   $0xf0106688
f0100d8a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100d8f:	68 77 04 00 00       	push   $0x477
f0100d94:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100d99:	e8 f6 f2 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d9e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da3:	75 19                	jne    f0100dbe <check_page_free_list+0x1eb>
f0100da5:	68 1a 70 10 f0       	push   $0xf010701a
f0100daa:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100daf:	68 78 04 00 00       	push   $0x478
f0100db4:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0100dd4:	68 54 60 10 f0       	push   $0xf0106054
f0100dd9:	6a 58                	push   $0x58
f0100ddb:	68 ad 6f 10 f0       	push   $0xf0106fad
f0100de0:	e8 af f2 ff ff       	call   f0100094 <_panic>
f0100de5:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100deb:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100dee:	0f 86 b6 00 00 00    	jbe    f0100eaa <check_page_free_list+0x2d7>
f0100df4:	68 ac 66 10 f0       	push   $0xf01066ac
f0100df9:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100dfe:	68 7c 04 00 00       	push   $0x47c
f0100e03:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100e08:	e8 87 f2 ff ff       	call   f0100094 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e0d:	68 34 70 10 f0       	push   $0xf0107034
f0100e12:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100e17:	68 7e 04 00 00       	push   $0x47e
f0100e1c:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0100e3c:	68 51 70 10 f0       	push   $0xf0107051
f0100e41:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100e46:	68 86 04 00 00       	push   $0x486
f0100e4b:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100e50:	e8 3f f2 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100e55:	85 db                	test   %ebx,%ebx
f0100e57:	7f 19                	jg     f0100e72 <check_page_free_list+0x29f>
f0100e59:	68 63 70 10 f0       	push   $0xf0107063
f0100e5e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0100e63:	68 87 04 00 00       	push   $0x487
f0100e68:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0100e6d:	e8 22 f2 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e72:	83 ec 0c             	sub    $0xc,%esp
f0100e75:	68 f4 66 10 f0       	push   $0xf01066f4
f0100e7a:	e8 ec 29 00 00       	call   f010386b <cprintf>
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
f0100ffa:	68 54 60 10 f0       	push   $0xf0106054
f0100fff:	6a 58                	push   $0x58
f0101001:	68 ad 6f 10 f0       	push   $0xf0106fad
f0101006:	e8 89 f0 ff ff       	call   f0100094 <_panic>
			memset(page2kva(return_PageInfo),'\0',PGSIZE);
f010100b:	83 ec 04             	sub    $0x4,%esp
f010100e:	68 00 10 00 00       	push   $0x1000
f0101013:	6a 00                	push   $0x0
f0101015:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010101a:	50                   	push   %eax
f010101b:	e8 c1 42 00 00       	call   f01052e1 <memset>
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
f0101043:	68 18 67 10 f0       	push   $0xf0106718
f0101048:	68 ff 01 00 00       	push   $0x1ff
f010104d:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101073:	68 54 60 10 f0       	push   $0xf0106054
f0101078:	6a 58                	push   $0x58
f010107a:	68 ad 6f 10 f0       	push   $0xf0106fad
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
f0101094:	e8 48 42 00 00       	call   f01052e1 <memset>
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
f0101172:	68 54 60 10 f0       	push   $0xf0106054
f0101177:	68 71 02 00 00       	push   $0x271
f010117c:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01011ab:	68 54 60 10 f0       	push   $0xf0106054
f01011b0:	68 79 02 00 00       	push   $0x279
f01011b5:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f010123f:	68 78 60 10 f0       	push   $0xf0106078
f0101244:	68 a8 02 00 00       	push   $0x2a8
f0101249:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01012b8:	68 38 67 10 f0       	push   $0xf0106738
f01012bd:	6a 51                	push   $0x51
f01012bf:	68 ad 6f 10 f0       	push   $0xf0106fad
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
f01012eb:	e8 12 46 00 00       	call   f0105902 <cpunum>
f01012f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01012f3:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01012fa:	74 16                	je     f0101312 <tlb_invalidate+0x2d>
f01012fc:	e8 01 46 00 00       	call   f0105902 <cpunum>
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
f01013a5:	68 78 60 10 f0       	push   $0xf0106078
f01013aa:	68 f1 02 00 00       	push   $0x2f1
f01013af:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101412:	68 74 70 10 f0       	push   $0xf0107074
f0101417:	68 ca 03 00 00       	push   $0x3ca
f010141c:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01014a8:	68 58 67 10 f0       	push   $0xf0106758
f01014ad:	e8 b9 23 00 00       	call   f010386b <cprintf>
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
f01014cc:	e8 10 3e 00 00       	call   f01052e1 <memset>
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
f01014e1:	68 78 60 10 f0       	push   $0xf0106078
f01014e6:	68 9f 00 00 00       	push   $0x9f
f01014eb:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101522:	e8 ba 3d 00 00       	call   f01052e1 <memset>

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
f010155a:	68 8f 70 10 f0       	push   $0xf010708f
f010155f:	68 9a 04 00 00       	push   $0x49a
f0101564:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101596:	68 aa 70 10 f0       	push   $0xf01070aa
f010159b:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01015a0:	68 a2 04 00 00       	push   $0x4a2
f01015a5:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01015aa:	e8 e5 ea ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01015af:	83 ec 0c             	sub    $0xc,%esp
f01015b2:	6a 00                	push   $0x0
f01015b4:	e8 b8 f9 ff ff       	call   f0100f71 <page_alloc>
f01015b9:	89 c6                	mov    %eax,%esi
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	85 c0                	test   %eax,%eax
f01015c0:	75 19                	jne    f01015db <mem_init+0x189>
f01015c2:	68 c0 70 10 f0       	push   $0xf01070c0
f01015c7:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01015cc:	68 a3 04 00 00       	push   $0x4a3
f01015d1:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01015d6:	e8 b9 ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015db:	83 ec 0c             	sub    $0xc,%esp
f01015de:	6a 00                	push   $0x0
f01015e0:	e8 8c f9 ff ff       	call   f0100f71 <page_alloc>
f01015e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015e8:	83 c4 10             	add    $0x10,%esp
f01015eb:	85 c0                	test   %eax,%eax
f01015ed:	75 19                	jne    f0101608 <mem_init+0x1b6>
f01015ef:	68 d6 70 10 f0       	push   $0xf01070d6
f01015f4:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01015f9:	68 a4 04 00 00       	push   $0x4a4
f01015fe:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101603:	e8 8c ea ff ff       	call   f0100094 <_panic>
//my test code
	//cprintf("here is my test code 1033.\n");	


	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101608:	39 f7                	cmp    %esi,%edi
f010160a:	75 19                	jne    f0101625 <mem_init+0x1d3>
f010160c:	68 ec 70 10 f0       	push   $0xf01070ec
f0101611:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101616:	68 aa 04 00 00       	push   $0x4aa
f010161b:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101620:	e8 6f ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101625:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101628:	39 c6                	cmp    %eax,%esi
f010162a:	74 04                	je     f0101630 <mem_init+0x1de>
f010162c:	39 c7                	cmp    %eax,%edi
f010162e:	75 19                	jne    f0101649 <mem_init+0x1f7>
f0101630:	68 94 67 10 f0       	push   $0xf0106794
f0101635:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010163a:	68 ab 04 00 00       	push   $0x4ab
f010163f:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101666:	68 fe 70 10 f0       	push   $0xf01070fe
f010166b:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101670:	68 ac 04 00 00       	push   $0x4ac
f0101675:	68 a1 6f 10 f0       	push   $0xf0106fa1
f010167a:	e8 15 ea ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010167f:	89 f0                	mov    %esi,%eax
f0101681:	29 c8                	sub    %ecx,%eax
f0101683:	c1 f8 03             	sar    $0x3,%eax
f0101686:	c1 e0 0c             	shl    $0xc,%eax
f0101689:	39 c2                	cmp    %eax,%edx
f010168b:	77 19                	ja     f01016a6 <mem_init+0x254>
f010168d:	68 1b 71 10 f0       	push   $0xf010711b
f0101692:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101697:	68 ad 04 00 00       	push   $0x4ad
f010169c:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01016a1:	e8 ee e9 ff ff       	call   f0100094 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016a9:	29 c8                	sub    %ecx,%eax
f01016ab:	c1 f8 03             	sar    $0x3,%eax
f01016ae:	c1 e0 0c             	shl    $0xc,%eax
f01016b1:	39 c2                	cmp    %eax,%edx
f01016b3:	77 19                	ja     f01016ce <mem_init+0x27c>
f01016b5:	68 38 71 10 f0       	push   $0xf0107138
f01016ba:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01016bf:	68 ae 04 00 00       	push   $0x4ae
f01016c4:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01016f1:	68 55 71 10 f0       	push   $0xf0107155
f01016f6:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01016fb:	68 b5 04 00 00       	push   $0x4b5
f0101700:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f010173b:	68 aa 70 10 f0       	push   $0xf01070aa
f0101740:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101745:	68 bf 04 00 00       	push   $0x4bf
f010174a:	68 a1 6f 10 f0       	push   $0xf0106fa1
f010174f:	e8 40 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101754:	83 ec 0c             	sub    $0xc,%esp
f0101757:	6a 00                	push   $0x0
f0101759:	e8 13 f8 ff ff       	call   f0100f71 <page_alloc>
f010175e:	89 c7                	mov    %eax,%edi
f0101760:	83 c4 10             	add    $0x10,%esp
f0101763:	85 c0                	test   %eax,%eax
f0101765:	75 19                	jne    f0101780 <mem_init+0x32e>
f0101767:	68 c0 70 10 f0       	push   $0xf01070c0
f010176c:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101771:	68 c0 04 00 00       	push   $0x4c0
f0101776:	68 a1 6f 10 f0       	push   $0xf0106fa1
f010177b:	e8 14 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101780:	83 ec 0c             	sub    $0xc,%esp
f0101783:	6a 00                	push   $0x0
f0101785:	e8 e7 f7 ff ff       	call   f0100f71 <page_alloc>
f010178a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010178d:	83 c4 10             	add    $0x10,%esp
f0101790:	85 c0                	test   %eax,%eax
f0101792:	75 19                	jne    f01017ad <mem_init+0x35b>
f0101794:	68 d6 70 10 f0       	push   $0xf01070d6
f0101799:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010179e:	68 c1 04 00 00       	push   $0x4c1
f01017a3:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01017a8:	e8 e7 e8 ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017ad:	39 fe                	cmp    %edi,%esi
f01017af:	75 19                	jne    f01017ca <mem_init+0x378>
f01017b1:	68 ec 70 10 f0       	push   $0xf01070ec
f01017b6:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01017bb:	68 c3 04 00 00       	push   $0x4c3
f01017c0:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01017c5:	e8 ca e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017cd:	39 c7                	cmp    %eax,%edi
f01017cf:	74 04                	je     f01017d5 <mem_init+0x383>
f01017d1:	39 c6                	cmp    %eax,%esi
f01017d3:	75 19                	jne    f01017ee <mem_init+0x39c>
f01017d5:	68 94 67 10 f0       	push   $0xf0106794
f01017da:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01017df:	68 c4 04 00 00       	push   $0x4c4
f01017e4:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01017e9:	e8 a6 e8 ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f01017ee:	83 ec 0c             	sub    $0xc,%esp
f01017f1:	6a 00                	push   $0x0
f01017f3:	e8 79 f7 ff ff       	call   f0100f71 <page_alloc>
f01017f8:	83 c4 10             	add    $0x10,%esp
f01017fb:	85 c0                	test   %eax,%eax
f01017fd:	74 19                	je     f0101818 <mem_init+0x3c6>
f01017ff:	68 55 71 10 f0       	push   $0xf0107155
f0101804:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101809:	68 c5 04 00 00       	push   $0x4c5
f010180e:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101834:	68 54 60 10 f0       	push   $0xf0106054
f0101839:	6a 58                	push   $0x58
f010183b:	68 ad 6f 10 f0       	push   $0xf0106fad
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
f0101855:	e8 87 3a 00 00       	call   f01052e1 <memset>
	page_free(pp0);
f010185a:	89 34 24             	mov    %esi,(%esp)
f010185d:	e8 c8 f7 ff ff       	call   f010102a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101862:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101869:	e8 03 f7 ff ff       	call   f0100f71 <page_alloc>
f010186e:	83 c4 10             	add    $0x10,%esp
f0101871:	85 c0                	test   %eax,%eax
f0101873:	75 19                	jne    f010188e <mem_init+0x43c>
f0101875:	68 64 71 10 f0       	push   $0xf0107164
f010187a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010187f:	68 cd 04 00 00       	push   $0x4cd
f0101884:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101889:	e8 06 e8 ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010188e:	39 c6                	cmp    %eax,%esi
f0101890:	74 19                	je     f01018ab <mem_init+0x459>
f0101892:	68 82 71 10 f0       	push   $0xf0107182
f0101897:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010189c:	68 ce 04 00 00       	push   $0x4ce
f01018a1:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01018c7:	68 54 60 10 f0       	push   $0xf0106054
f01018cc:	6a 58                	push   $0x58
f01018ce:	68 ad 6f 10 f0       	push   $0xf0106fad
f01018d3:	e8 bc e7 ff ff       	call   f0100094 <_panic>
f01018d8:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018de:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018e4:	80 38 00             	cmpb   $0x0,(%eax)
f01018e7:	74 19                	je     f0101902 <mem_init+0x4b0>
f01018e9:	68 92 71 10 f0       	push   $0xf0107192
f01018ee:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01018f3:	68 d1 04 00 00       	push   $0x4d1
f01018f8:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101944:	68 9c 71 10 f0       	push   $0xf010719c
f0101949:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010194e:	68 e1 04 00 00       	push   $0x4e1
f0101953:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101958:	e8 37 e7 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010195d:	83 ec 0c             	sub    $0xc,%esp
f0101960:	68 b4 67 10 f0       	push   $0xf01067b4
f0101965:	e8 01 1f 00 00       	call   f010386b <cprintf>
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
f010197f:	68 aa 70 10 f0       	push   $0xf01070aa
f0101984:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101989:	68 5b 05 00 00       	push   $0x55b
f010198e:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101993:	e8 fc e6 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101998:	83 ec 0c             	sub    $0xc,%esp
f010199b:	6a 00                	push   $0x0
f010199d:	e8 cf f5 ff ff       	call   f0100f71 <page_alloc>
f01019a2:	89 c3                	mov    %eax,%ebx
f01019a4:	83 c4 10             	add    $0x10,%esp
f01019a7:	85 c0                	test   %eax,%eax
f01019a9:	75 19                	jne    f01019c4 <mem_init+0x572>
f01019ab:	68 c0 70 10 f0       	push   $0xf01070c0
f01019b0:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01019b5:	68 5c 05 00 00       	push   $0x55c
f01019ba:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01019bf:	e8 d0 e6 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01019c4:	83 ec 0c             	sub    $0xc,%esp
f01019c7:	6a 00                	push   $0x0
f01019c9:	e8 a3 f5 ff ff       	call   f0100f71 <page_alloc>
f01019ce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019d1:	83 c4 10             	add    $0x10,%esp
f01019d4:	85 c0                	test   %eax,%eax
f01019d6:	75 19                	jne    f01019f1 <mem_init+0x59f>
f01019d8:	68 d6 70 10 f0       	push   $0xf01070d6
f01019dd:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01019e2:	68 5d 05 00 00       	push   $0x55d
f01019e7:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01019ec:	e8 a3 e6 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019f1:	39 de                	cmp    %ebx,%esi
f01019f3:	75 19                	jne    f0101a0e <mem_init+0x5bc>
f01019f5:	68 ec 70 10 f0       	push   $0xf01070ec
f01019fa:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01019ff:	68 60 05 00 00       	push   $0x560
f0101a04:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101a09:	e8 86 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a11:	39 c6                	cmp    %eax,%esi
f0101a13:	74 04                	je     f0101a19 <mem_init+0x5c7>
f0101a15:	39 c3                	cmp    %eax,%ebx
f0101a17:	75 19                	jne    f0101a32 <mem_init+0x5e0>
f0101a19:	68 94 67 10 f0       	push   $0xf0106794
f0101a1e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101a23:	68 61 05 00 00       	push   $0x561
f0101a28:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101a55:	68 55 71 10 f0       	push   $0xf0107155
f0101a5a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101a5f:	68 68 05 00 00       	push   $0x568
f0101a64:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101a89:	68 d4 67 10 f0       	push   $0xf01067d4
f0101a8e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101a93:	68 6c 05 00 00       	push   $0x56c
f0101a98:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101ab9:	68 0c 68 10 f0       	push   $0xf010680c
f0101abe:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101ac3:	68 74 05 00 00       	push   $0x574
f0101ac8:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101af2:	68 3c 68 10 f0       	push   $0xf010683c
f0101af7:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101afc:	68 7b 05 00 00       	push   $0x57b
f0101b01:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101b31:	68 6c 68 10 f0       	push   $0xf010686c
f0101b36:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101b3b:	68 7e 05 00 00       	push   $0x57e
f0101b40:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101b65:	68 94 68 10 f0       	push   $0xf0106894
f0101b6a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101b6f:	68 7f 05 00 00       	push   $0x57f
f0101b74:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101b79:	e8 16 e5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101b7e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b83:	74 19                	je     f0101b9e <mem_init+0x74c>
f0101b85:	68 a7 71 10 f0       	push   $0xf01071a7
f0101b8a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101b8f:	68 80 05 00 00       	push   $0x580
f0101b94:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101b99:	e8 f6 e4 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101b9e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ba3:	74 19                	je     f0101bbe <mem_init+0x76c>
f0101ba5:	68 b8 71 10 f0       	push   $0xf01071b8
f0101baa:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101baf:	68 81 05 00 00       	push   $0x581
f0101bb4:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101bd5:	68 c4 68 10 f0       	push   $0xf01068c4
f0101bda:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101bdf:	68 86 05 00 00       	push   $0x586
f0101be4:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101c10:	68 00 69 10 f0       	push   $0xf0106900
f0101c15:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101c1a:	68 8c 05 00 00       	push   $0x58c
f0101c1f:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101c24:	e8 6b e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101c29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c2c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c31:	74 19                	je     f0101c4c <mem_init+0x7fa>
f0101c33:	68 c9 71 10 f0       	push   $0xf01071c9
f0101c38:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101c3d:	68 8d 05 00 00       	push   $0x58d
f0101c42:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101c5d:	68 55 71 10 f0       	push   $0xf0107155
f0101c62:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101c67:	68 91 05 00 00       	push   $0x591
f0101c6c:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101c92:	68 c4 68 10 f0       	push   $0xf01068c4
f0101c97:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101c9c:	68 95 05 00 00       	push   $0x595
f0101ca1:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101cbc:	68 55 71 10 f0       	push   $0xf0107155
f0101cc1:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101cc6:	68 a1 05 00 00       	push   $0x5a1
f0101ccb:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101cf0:	68 54 60 10 f0       	push   $0xf0106054
f0101cf5:	68 a4 05 00 00       	push   $0x5a4
f0101cfa:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101d29:	68 30 69 10 f0       	push   $0xf0106930
f0101d2e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101d33:	68 a9 05 00 00       	push   $0x5a9
f0101d38:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101d5e:	68 70 69 10 f0       	push   $0xf0106970
f0101d63:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101d68:	68 ac 05 00 00       	push   $0x5ac
f0101d6d:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101d9c:	68 00 69 10 f0       	push   $0xf0106900
f0101da1:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101da6:	68 ad 05 00 00       	push   $0x5ad
f0101dab:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101db0:	e8 df e2 ff ff       	call   f0100094 <_panic>
//	cprintf("the final pp2->pp_ref:%x\n",pp2->pp_ref);
	assert(pp2->pp_ref == 1);
f0101db5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db8:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dbd:	74 19                	je     f0101dd8 <mem_init+0x986>
f0101dbf:	68 c9 71 10 f0       	push   $0xf01071c9
f0101dc4:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101dc9:	68 af 05 00 00       	push   $0x5af
f0101dce:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101df0:	68 b0 69 10 f0       	push   $0xf01069b0
f0101df5:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101dfa:	68 b0 05 00 00       	push   $0x5b0
f0101dff:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101e04:	e8 8b e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e09:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
f0101e0e:	f6 00 04             	testb  $0x4,(%eax)
f0101e11:	75 19                	jne    f0101e2c <mem_init+0x9da>
f0101e13:	68 da 71 10 f0       	push   $0xf01071da
f0101e18:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101e1d:	68 b1 05 00 00       	push   $0x5b1
f0101e22:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101e43:	68 c4 68 10 f0       	push   $0xf01068c4
f0101e48:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101e4d:	68 b4 05 00 00       	push   $0x5b4
f0101e52:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101e79:	68 e4 69 10 f0       	push   $0xf01069e4
f0101e7e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101e83:	68 b5 05 00 00       	push   $0x5b5
f0101e88:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101eaf:	68 18 6a 10 f0       	push   $0xf0106a18
f0101eb4:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101eb9:	68 b6 05 00 00       	push   $0x5b6
f0101ebe:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101ee2:	68 50 6a 10 f0       	push   $0xf0106a50
f0101ee7:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101eec:	68 ba 05 00 00       	push   $0x5ba
f0101ef1:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101f15:	68 88 6a 10 f0       	push   $0xf0106a88
f0101f1a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101f1f:	68 be 05 00 00       	push   $0x5be
f0101f24:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101f4b:	68 18 6a 10 f0       	push   $0xf0106a18
f0101f50:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101f55:	68 c0 05 00 00       	push   $0x5c0
f0101f5a:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0101f8d:	68 c4 6a 10 f0       	push   $0xf0106ac4
f0101f92:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101f97:	68 c3 05 00 00       	push   $0x5c3
f0101f9c:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101fa1:	e8 ee e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fa6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fab:	89 f8                	mov    %edi,%eax
f0101fad:	e8 bd eb ff ff       	call   f0100b6f <check_va2pa>
f0101fb2:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101fb5:	74 19                	je     f0101fd0 <mem_init+0xb7e>
f0101fb7:	68 f0 6a 10 f0       	push   $0xf0106af0
f0101fbc:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101fc1:	68 c4 05 00 00       	push   $0x5c4
f0101fc6:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101fcb:	e8 c4 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101fd0:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101fd5:	74 19                	je     f0101ff0 <mem_init+0xb9e>
f0101fd7:	68 f0 71 10 f0       	push   $0xf01071f0
f0101fdc:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0101fe1:	68 c6 05 00 00       	push   $0x5c6
f0101fe6:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0101feb:	e8 a4 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0101ff0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ff8:	74 19                	je     f0102013 <mem_init+0xbc1>
f0101ffa:	68 01 72 10 f0       	push   $0xf0107201
f0101fff:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102004:	68 c7 05 00 00       	push   $0x5c7
f0102009:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102029:	68 20 6b 10 f0       	push   $0xf0106b20
f010202e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102033:	68 ca 05 00 00       	push   $0x5ca
f0102038:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f010206c:	68 44 6b 10 f0       	push   $0xf0106b44
f0102071:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102076:	68 ce 05 00 00       	push   $0x5ce
f010207b:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01020a3:	68 f0 6a 10 f0       	push   $0xf0106af0
f01020a8:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01020ad:	68 cf 05 00 00       	push   $0x5cf
f01020b2:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01020b7:	e8 d8 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01020bc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020c1:	74 19                	je     f01020dc <mem_init+0xc8a>
f01020c3:	68 a7 71 10 f0       	push   $0xf01071a7
f01020c8:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01020cd:	68 d0 05 00 00       	push   $0x5d0
f01020d2:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01020d7:	e8 b8 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01020dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020df:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01020e4:	74 19                	je     f01020ff <mem_init+0xcad>
f01020e6:	68 01 72 10 f0       	push   $0xf0107201
f01020eb:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01020f0:	68 d1 05 00 00       	push   $0x5d1
f01020f5:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102114:	68 68 6b 10 f0       	push   $0xf0106b68
f0102119:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010211e:	68 d4 05 00 00       	push   $0x5d4
f0102123:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102128:	e8 67 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f010212d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102132:	75 19                	jne    f010214d <mem_init+0xcfb>
f0102134:	68 12 72 10 f0       	push   $0xf0107212
f0102139:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010213e:	68 d5 05 00 00       	push   $0x5d5
f0102143:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102148:	e8 47 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010214d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102150:	74 19                	je     f010216b <mem_init+0xd19>
f0102152:	68 1e 72 10 f0       	push   $0xf010721e
f0102157:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010215c:	68 d6 05 00 00       	push   $0x5d6
f0102161:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102198:	68 44 6b 10 f0       	push   $0xf0106b44
f010219d:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01021a2:	68 da 05 00 00       	push   $0x5da
f01021a7:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01021ac:	e8 e3 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021b1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021b6:	89 f8                	mov    %edi,%eax
f01021b8:	e8 b2 e9 ff ff       	call   f0100b6f <check_va2pa>
f01021bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021c0:	74 19                	je     f01021db <mem_init+0xd89>
f01021c2:	68 a0 6b 10 f0       	push   $0xf0106ba0
f01021c7:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01021cc:	68 db 05 00 00       	push   $0x5db
f01021d1:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01021d6:	e8 b9 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01021db:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021e0:	74 19                	je     f01021fb <mem_init+0xda9>
f01021e2:	68 33 72 10 f0       	push   $0xf0107233
f01021e7:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01021ec:	68 dc 05 00 00       	push   $0x5dc
f01021f1:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01021f6:	e8 99 de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01021fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021fe:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102203:	74 19                	je     f010221e <mem_init+0xdcc>
f0102205:	68 01 72 10 f0       	push   $0xf0107201
f010220a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010220f:	68 dd 05 00 00       	push   $0x5dd
f0102214:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102233:	68 c8 6b 10 f0       	push   $0xf0106bc8
f0102238:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010223d:	68 e0 05 00 00       	push   $0x5e0
f0102242:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102247:	e8 48 de ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010224c:	83 ec 0c             	sub    $0xc,%esp
f010224f:	6a 00                	push   $0x0
f0102251:	e8 1b ed ff ff       	call   f0100f71 <page_alloc>
f0102256:	83 c4 10             	add    $0x10,%esp
f0102259:	85 c0                	test   %eax,%eax
f010225b:	74 19                	je     f0102276 <mem_init+0xe24>
f010225d:	68 55 71 10 f0       	push   $0xf0107155
f0102262:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102267:	68 e3 05 00 00       	push   $0x5e3
f010226c:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102296:	68 6c 68 10 f0       	push   $0xf010686c
f010229b:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01022a0:	68 e6 05 00 00       	push   $0x5e6
f01022a5:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01022aa:	e8 e5 dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01022af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022b5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022ba:	74 19                	je     f01022d5 <mem_init+0xe83>
f01022bc:	68 b8 71 10 f0       	push   $0xf01071b8
f01022c1:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01022c6:	68 e8 05 00 00       	push   $0x5e8
f01022cb:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102321:	68 54 60 10 f0       	push   $0xf0106054
f0102326:	68 ef 05 00 00       	push   $0x5ef
f010232b:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102330:	e8 5f dd ff ff       	call   f0100094 <_panic>
	
//now we fault at ptep == ptep1+PTX(va)
//cprintf("ptep:%x , PTX(va):%x,va:%x,ptep1:%x\n",ptep,PTX(va),va,ptep1);

	assert(ptep == ptep1 + PTX(va));
f0102335:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010233a:	39 c7                	cmp    %eax,%edi
f010233c:	74 19                	je     f0102357 <mem_init+0xf05>
f010233e:	68 44 72 10 f0       	push   $0xf0107244
f0102343:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102348:	68 f4 05 00 00       	push   $0x5f4
f010234d:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f010237f:	68 54 60 10 f0       	push   $0xf0106054
f0102384:	6a 58                	push   $0x58
f0102386:	68 ad 6f 10 f0       	push   $0xf0106fad
f010238b:	e8 04 dd ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102390:	83 ec 04             	sub    $0x4,%esp
f0102393:	68 00 10 00 00       	push   $0x1000
f0102398:	68 ff 00 00 00       	push   $0xff
f010239d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023a2:	50                   	push   %eax
f01023a3:	e8 39 2f 00 00       	call   f01052e1 <memset>
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
f01023e1:	68 54 60 10 f0       	push   $0xf0106054
f01023e6:	6a 58                	push   $0x58
f01023e8:	68 ad 6f 10 f0       	push   $0xf0106fad
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
f0102406:	68 5c 72 10 f0       	push   $0xf010725c
f010240b:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102410:	68 08 06 00 00       	push   $0x608
f0102415:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102495:	68 ec 6b 10 f0       	push   $0xf0106bec
f010249a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010249f:	68 1c 06 00 00       	push   $0x61c
f01024a4:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01024a9:	e8 e6 db ff ff       	call   f0100094 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01024ae:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01024b4:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01024ba:	77 08                	ja     f01024c4 <mem_init+0x1072>
f01024bc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01024c2:	77 19                	ja     f01024dd <mem_init+0x108b>
f01024c4:	68 14 6c 10 f0       	push   $0xf0106c14
f01024c9:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01024ce:	68 1d 06 00 00       	push   $0x61d
f01024d3:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01024d8:	e8 b7 db ff ff       	call   f0100094 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01024dd:	89 da                	mov    %ebx,%edx
f01024df:	09 f2                	or     %esi,%edx
f01024e1:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01024e7:	74 19                	je     f0102502 <mem_init+0x10b0>
f01024e9:	68 3c 6c 10 f0       	push   $0xf0106c3c
f01024ee:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01024f3:	68 1f 06 00 00       	push   $0x61f
f01024f8:	68 a1 6f 10 f0       	push   $0xf0106fa1
f01024fd:	e8 92 db ff ff       	call   f0100094 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102502:	39 c6                	cmp    %eax,%esi
f0102504:	73 19                	jae    f010251f <mem_init+0x10cd>
f0102506:	68 73 72 10 f0       	push   $0xf0107273
f010250b:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102510:	68 21 06 00 00       	push   $0x621
f0102515:	68 a1 6f 10 f0       	push   $0xf0106fa1
f010251a:	e8 75 db ff ff       	call   f0100094 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010251f:	8b 3d 8c be 22 f0    	mov    0xf022be8c,%edi
f0102525:	89 da                	mov    %ebx,%edx
f0102527:	89 f8                	mov    %edi,%eax
f0102529:	e8 41 e6 ff ff       	call   f0100b6f <check_va2pa>
f010252e:	85 c0                	test   %eax,%eax
f0102530:	74 19                	je     f010254b <mem_init+0x10f9>
f0102532:	68 64 6c 10 f0       	push   $0xf0106c64
f0102537:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010253c:	68 23 06 00 00       	push   $0x623
f0102541:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102546:	e8 49 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010254b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102551:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102554:	89 c2                	mov    %eax,%edx
f0102556:	89 f8                	mov    %edi,%eax
f0102558:	e8 12 e6 ff ff       	call   f0100b6f <check_va2pa>
f010255d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102562:	74 19                	je     f010257d <mem_init+0x112b>
f0102564:	68 88 6c 10 f0       	push   $0xf0106c88
f0102569:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010256e:	68 24 06 00 00       	push   $0x624
f0102573:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102578:	e8 17 db ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010257d:	89 f2                	mov    %esi,%edx
f010257f:	89 f8                	mov    %edi,%eax
f0102581:	e8 e9 e5 ff ff       	call   f0100b6f <check_va2pa>
f0102586:	85 c0                	test   %eax,%eax
f0102588:	74 19                	je     f01025a3 <mem_init+0x1151>
f010258a:	68 b8 6c 10 f0       	push   $0xf0106cb8
f010258f:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102594:	68 25 06 00 00       	push   $0x625
f0102599:	68 a1 6f 10 f0       	push   $0xf0106fa1
f010259e:	e8 f1 da ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01025a3:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01025a9:	89 f8                	mov    %edi,%eax
f01025ab:	e8 bf e5 ff ff       	call   f0100b6f <check_va2pa>
f01025b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025b3:	74 19                	je     f01025ce <mem_init+0x117c>
f01025b5:	68 dc 6c 10 f0       	push   $0xf0106cdc
f01025ba:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01025bf:	68 26 06 00 00       	push   $0x626
f01025c4:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01025e2:	68 08 6d 10 f0       	push   $0xf0106d08
f01025e7:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01025ec:	68 28 06 00 00       	push   $0x628
f01025f1:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102619:	68 4c 6d 10 f0       	push   $0xf0106d4c
f010261e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102623:	68 29 06 00 00       	push   $0x629
f0102628:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102679:	c7 04 24 85 72 10 f0 	movl   $0xf0107285,(%esp)
f0102680:	e8 e6 11 00 00       	call   f010386b <cprintf>
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
f0102695:	68 78 60 10 f0       	push   $0xf0106078
f010269a:	68 06 01 00 00       	push   $0x106
f010269f:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01026d8:	68 78 60 10 f0       	push   $0xf0106078
f01026dd:	68 12 01 00 00       	push   $0x112
f01026e2:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f010271b:	68 78 60 10 f0       	push   $0xf0106078
f0102720:	68 27 01 00 00       	push   $0x127
f0102725:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102752:	68 9e 72 10 f0       	push   $0xf010729e
f0102757:	e8 0f 11 00 00       	call   f010386b <cprintf>
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
f0102779:	68 78 60 10 f0       	push   $0xf0106078
f010277e:	68 6e 01 00 00       	push   $0x16e
f0102783:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102824:	68 78 60 10 f0       	push   $0xf0106078
f0102829:	68 fa 04 00 00       	push   $0x4fa
f010282e:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102833:	e8 5c d8 ff ff       	call   f0100094 <_panic>
f0102838:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010283f:	39 c2                	cmp    %eax,%edx
f0102841:	74 19                	je     f010285c <mem_init+0x140a>
f0102843:	68 80 6d 10 f0       	push   $0xf0106d80
f0102848:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010284d:	68 fa 04 00 00       	push   $0x4fa
f0102852:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102888:	68 78 60 10 f0       	push   $0xf0106078
f010288d:	68 00 05 00 00       	push   $0x500
f0102892:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102897:	e8 f8 d7 ff ff       	call   f0100094 <_panic>
f010289c:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01028a3:	39 d0                	cmp    %edx,%eax
f01028a5:	74 19                	je     f01028c0 <mem_init+0x146e>
f01028a7:	68 b4 6d 10 f0       	push   $0xf0106db4
f01028ac:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01028b1:	68 00 05 00 00       	push   $0x500
f01028b6:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01028ec:	68 e8 6d 10 f0       	push   $0xf0106de8
f01028f1:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01028f6:	68 06 05 00 00       	push   $0x506
f01028fb:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102945:	68 78 60 10 f0       	push   $0xf0106078
f010294a:	68 11 05 00 00       	push   $0x511
f010294f:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102954:	e8 3b d7 ff ff       	call   f0100094 <_panic>
f0102959:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010295c:	8d 94 0b 00 d0 22 f0 	lea    -0xfdd3000(%ebx,%ecx,1),%edx
f0102963:	39 d0                	cmp    %edx,%eax
f0102965:	74 19                	je     f0102980 <mem_init+0x152e>
f0102967:	68 10 6e 10 f0       	push   $0xf0106e10
f010296c:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102971:	68 11 05 00 00       	push   $0x511
f0102976:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01029a7:	68 58 6e 10 f0       	push   $0xf0106e58
f01029ac:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01029b1:	68 13 05 00 00       	push   $0x513
f01029b6:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f01029ff:	68 7c 6e 10 f0       	push   $0xf0106e7c
f0102a04:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102a09:	68 1d 05 00 00       	push   $0x51d
f0102a0e:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102a2d:	68 a7 72 10 f0       	push   $0xf01072a7
f0102a32:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102a37:	68 28 05 00 00       	push   $0x528
f0102a3c:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102a5a:	68 a7 72 10 f0       	push   $0xf01072a7
f0102a5f:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102a64:	68 2c 05 00 00       	push   $0x52c
f0102a69:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102a6e:	e8 21 d6 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a73:	f6 c2 02             	test   $0x2,%dl
f0102a76:	75 38                	jne    f0102ab0 <mem_init+0x165e>
f0102a78:	68 b8 72 10 f0       	push   $0xf01072b8
f0102a7d:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102a82:	68 2d 05 00 00       	push   $0x52d
f0102a87:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102a8c:	e8 03 d6 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102a91:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a95:	74 19                	je     f0102ab0 <mem_init+0x165e>
f0102a97:	68 c9 72 10 f0       	push   $0xf01072c9
f0102a9c:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102aa1:	68 2f 05 00 00       	push   $0x52f
f0102aa6:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102ac1:	68 ac 6e 10 f0       	push   $0xf0106eac
f0102ac6:	e8 a0 0d 00 00       	call   f010386b <cprintf>
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
f0102adb:	68 78 60 10 f0       	push   $0xf0106078
f0102ae0:	68 43 01 00 00       	push   $0x143
f0102ae5:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102b22:	68 aa 70 10 f0       	push   $0xf01070aa
f0102b27:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102b2c:	68 3e 06 00 00       	push   $0x63e
f0102b31:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102b36:	e8 59 d5 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b3b:	83 ec 0c             	sub    $0xc,%esp
f0102b3e:	6a 00                	push   $0x0
f0102b40:	e8 2c e4 ff ff       	call   f0100f71 <page_alloc>
f0102b45:	89 c7                	mov    %eax,%edi
f0102b47:	83 c4 10             	add    $0x10,%esp
f0102b4a:	85 c0                	test   %eax,%eax
f0102b4c:	75 19                	jne    f0102b67 <mem_init+0x1715>
f0102b4e:	68 c0 70 10 f0       	push   $0xf01070c0
f0102b53:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102b58:	68 3f 06 00 00       	push   $0x63f
f0102b5d:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102b62:	e8 2d d5 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102b67:	83 ec 0c             	sub    $0xc,%esp
f0102b6a:	6a 00                	push   $0x0
f0102b6c:	e8 00 e4 ff ff       	call   f0100f71 <page_alloc>
f0102b71:	89 c6                	mov    %eax,%esi
f0102b73:	83 c4 10             	add    $0x10,%esp
f0102b76:	85 c0                	test   %eax,%eax
f0102b78:	75 19                	jne    f0102b93 <mem_init+0x1741>
f0102b7a:	68 d6 70 10 f0       	push   $0xf01070d6
f0102b7f:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102b84:	68 40 06 00 00       	push   $0x640
f0102b89:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102bbb:	68 54 60 10 f0       	push   $0xf0106054
f0102bc0:	6a 58                	push   $0x58
f0102bc2:	68 ad 6f 10 f0       	push   $0xf0106fad
f0102bc7:	e8 c8 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bcc:	83 ec 04             	sub    $0x4,%esp
f0102bcf:	68 00 10 00 00       	push   $0x1000
f0102bd4:	6a 01                	push   $0x1
f0102bd6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102bdb:	50                   	push   %eax
f0102bdc:	e8 00 27 00 00       	call   f01052e1 <memset>
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
f0102c00:	68 54 60 10 f0       	push   $0xf0106054
f0102c05:	6a 58                	push   $0x58
f0102c07:	68 ad 6f 10 f0       	push   $0xf0106fad
f0102c0c:	e8 83 d4 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c11:	83 ec 04             	sub    $0x4,%esp
f0102c14:	68 00 10 00 00       	push   $0x1000
f0102c19:	6a 02                	push   $0x2
f0102c1b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c20:	50                   	push   %eax
f0102c21:	e8 bb 26 00 00       	call   f01052e1 <memset>
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
f0102c43:	68 a7 71 10 f0       	push   $0xf01071a7
f0102c48:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102c4d:	68 45 06 00 00       	push   $0x645
f0102c52:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102c57:	e8 38 d4 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c5c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c63:	01 01 01 
f0102c66:	74 19                	je     f0102c81 <mem_init+0x182f>
f0102c68:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0102c6d:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102c72:	68 46 06 00 00       	push   $0x646
f0102c77:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102ca3:	68 f0 6e 10 f0       	push   $0xf0106ef0
f0102ca8:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102cad:	68 48 06 00 00       	push   $0x648
f0102cb2:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102cb7:	e8 d8 d3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102cbc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cc1:	74 19                	je     f0102cdc <mem_init+0x188a>
f0102cc3:	68 c9 71 10 f0       	push   $0xf01071c9
f0102cc8:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102ccd:	68 49 06 00 00       	push   $0x649
f0102cd2:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102cd7:	e8 b8 d3 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102cdc:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ce1:	74 19                	je     f0102cfc <mem_init+0x18aa>
f0102ce3:	68 33 72 10 f0       	push   $0xf0107233
f0102ce8:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102ced:	68 4a 06 00 00       	push   $0x64a
f0102cf2:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102d22:	68 54 60 10 f0       	push   $0xf0106054
f0102d27:	6a 58                	push   $0x58
f0102d29:	68 ad 6f 10 f0       	push   $0xf0106fad
f0102d2e:	e8 61 d3 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d33:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d3a:	03 03 03 
f0102d3d:	74 19                	je     f0102d58 <mem_init+0x1906>
f0102d3f:	68 14 6f 10 f0       	push   $0xf0106f14
f0102d44:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102d49:	68 4c 06 00 00       	push   $0x64c
f0102d4e:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102d75:	68 01 72 10 f0       	push   $0xf0107201
f0102d7a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102d7f:	68 4e 06 00 00       	push   $0x64e
f0102d84:	68 a1 6f 10 f0       	push   $0xf0106fa1
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
f0102dae:	68 6c 68 10 f0       	push   $0xf010686c
f0102db3:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102db8:	68 51 06 00 00       	push   $0x651
f0102dbd:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102dc2:	e8 cd d2 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102dc7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102dcd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102dd2:	74 19                	je     f0102ded <mem_init+0x199b>
f0102dd4:	68 b8 71 10 f0       	push   $0xf01071b8
f0102dd9:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0102dde:	68 53 06 00 00       	push   $0x653
f0102de3:	68 a1 6f 10 f0       	push   $0xf0106fa1
f0102de8:	e8 a7 d2 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102ded:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102df3:	83 ec 0c             	sub    $0xc,%esp
f0102df6:	53                   	push   %ebx
f0102df7:	e8 2e e2 ff ff       	call   f010102a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102dfc:	c7 04 24 40 6f 10 f0 	movl   $0xf0106f40,(%esp)
f0102e03:	e8 63 0a 00 00       	call   f010386b <cprintf>
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
f0102ec5:	68 6c 6f 10 f0       	push   $0xf0106f6c
f0102eca:	e8 9c 09 00 00       	call   f010386b <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102ecf:	89 1c 24             	mov    %ebx,(%esp)
f0102ed2:	e8 d7 06 00 00       	call   f01035ae <env_destroy>
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
f0102f1b:	68 d7 72 10 f0       	push   $0xf01072d7
f0102f20:	68 52 01 00 00       	push   $0x152
f0102f25:	68 ed 72 10 f0       	push   $0xf01072ed
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
f0102f45:	68 d7 72 10 f0       	push   $0xf01072d7
f0102f4a:	68 58 01 00 00       	push   $0x158
f0102f4f:	68 ed 72 10 f0       	push   $0xf01072ed
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
f0102f80:	e8 7d 29 00 00       	call   f0105902 <cpunum>
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
f0102fc0:	68 5c 73 10 f0       	push   $0xf010735c
f0102fc5:	e8 a1 08 00 00       	call   f010386b <cprintf>
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
f0102fe1:	e8 1c 29 00 00       	call   f0105902 <cpunum>
f0102fe6:	6b c0 74             	imul   $0x74,%eax,%eax
f0102fe9:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f0102fef:	74 4a                	je     f010303b <envid2env+0xca>
f0102ff1:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102ff4:	e8 09 29 00 00       	call   f0105902 <cpunum>
f0102ff9:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ffc:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103002:	3b 70 48             	cmp    0x48(%eax),%esi
f0103005:	74 34                	je     f010303b <envid2env+0xca>
		*env_store = 0;
f0103007:	8b 45 0c             	mov    0xc(%ebp),%eax
f010300a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		cprintf("we are at e->env_parent_id:%d curenv->env_id:%d\n",e->env_parent_id,curenv->env_id);
f0103010:	e8 ed 28 00 00       	call   f0105902 <cpunum>
f0103015:	83 ec 04             	sub    $0x4,%esp
f0103018:	6b c0 74             	imul   $0x74,%eax,%eax
f010301b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103021:	ff 70 48             	pushl  0x48(%eax)
f0103024:	ff 73 4c             	pushl  0x4c(%ebx)
f0103027:	68 80 73 10 f0       	push   $0xf0107380
f010302c:	e8 3a 08 00 00       	call   f010386b <cprintf>
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
f01030e0:	68 b4 73 10 f0       	push   $0xf01073b4
f01030e5:	e8 81 07 00 00       	call   f010386b <cprintf>
 

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
f0103146:	68 54 60 10 f0       	push   $0xf0106054
f010314b:	6a 58                	push   $0x58
f010314d:	68 ad 6f 10 f0       	push   $0xf0106fad
f0103152:	e8 3d cf ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0103157:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
        pde_t* page_dir = page2kva(p);
	memcpy(page_dir,kern_pgdir,PGSIZE);
f010315d:	83 ec 04             	sub    $0x4,%esp
f0103160:	68 00 10 00 00       	push   $0x1000
f0103165:	ff 35 8c be 22 f0    	pushl  0xf022be8c
f010316b:	57                   	push   %edi
f010316c:	e8 25 22 00 00       	call   f0105396 <memcpy>
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
f0103180:	68 78 60 10 f0       	push   $0xf0106078
f0103185:	68 e6 00 00 00       	push   $0xe6
f010318a:	68 ed 72 10 f0       	push   $0xf01072ed
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
f01031eb:	e8 f1 20 00 00       	call   f01052e1 <memset>
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
f010322a:	e8 d3 26 00 00       	call   f0105902 <cpunum>
f010322f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103232:	83 c4 10             	add    $0x10,%esp
f0103235:	ba 00 00 00 00       	mov    $0x0,%edx
f010323a:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103241:	74 11                	je     f0103254 <env_alloc+0x15b>
f0103243:	e8 ba 26 00 00       	call   f0105902 <cpunum>
f0103248:	6b c0 74             	imul   $0x74,%eax,%eax
f010324b:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103251:	8b 50 48             	mov    0x48(%eax),%edx
f0103254:	83 ec 04             	sub    $0x4,%esp
f0103257:	53                   	push   %ebx
f0103258:	52                   	push   %edx
f0103259:	68 f8 72 10 f0       	push   $0xf01072f8
f010325e:	e8 08 06 00 00       	call   f010386b <cprintf>
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
f01032a7:	68 0d 73 10 f0       	push   $0xf010730d
f01032ac:	68 d0 01 00 00       	push   $0x1d0
f01032b1:	68 ed 72 10 f0       	push   $0xf01072ed
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
f01032cc:	68 1c 73 10 f0       	push   $0xf010731c
f01032d1:	68 99 01 00 00       	push   $0x199
f01032d6:	68 ed 72 10 f0       	push   $0xf01072ed
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
f01032fc:	68 78 60 10 f0       	push   $0xf0106078
f0103301:	68 9e 01 00 00       	push   $0x19e
f0103306:	68 ed 72 10 f0       	push   $0xf01072ed
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
f010332a:	68 e4 73 10 f0       	push   $0xf01073e4
f010332f:	68 a9 01 00 00       	push   $0x1a9
f0103334:	68 ed 72 10 f0       	push   $0xf01072ed
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
f0103358:	e8 d1 1f 00 00       	call   f010532e <memmove>
		memset((void*)ph->p_va + ph->p_filesz,0,(ph->p_memsz - ph->p_filesz));
f010335d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103360:	83 c4 0c             	add    $0xc,%esp
f0103363:	8b 53 14             	mov    0x14(%ebx),%edx
f0103366:	29 c2                	sub    %eax,%edx
f0103368:	52                   	push   %edx
f0103369:	6a 00                	push   $0x0
f010336b:	03 43 08             	add    0x8(%ebx),%eax
f010336e:	50                   	push   %eax
f010336f:	e8 6d 1f 00 00       	call   f01052e1 <memset>
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
f0103394:	68 78 60 10 f0       	push   $0xf0106078
f0103399:	68 b8 01 00 00       	push   $0x1b8
f010339e:	68 ed 72 10 f0       	push   $0xf01072ed
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
}
f01033cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ce:	5b                   	pop    %ebx
f01033cf:	5e                   	pop    %esi
f01033d0:	5f                   	pop    %edi
f01033d1:	5d                   	pop    %ebp
f01033d2:	c3                   	ret    

f01033d3 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033d3:	55                   	push   %ebp
f01033d4:	89 e5                	mov    %esp,%ebp
f01033d6:	57                   	push   %edi
f01033d7:	56                   	push   %esi
f01033d8:	53                   	push   %ebx
f01033d9:	83 ec 1c             	sub    $0x1c,%esp
f01033dc:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033df:	e8 1e 25 00 00       	call   f0105902 <cpunum>
f01033e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e7:	39 b8 28 c0 22 f0    	cmp    %edi,-0xfdd3fd8(%eax)
f01033ed:	75 29                	jne    f0103418 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01033ef:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f9:	77 15                	ja     f0103410 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033fb:	50                   	push   %eax
f01033fc:	68 78 60 10 f0       	push   $0xf0106078
f0103401:	68 e5 01 00 00       	push   $0x1e5
f0103406:	68 ed 72 10 f0       	push   $0xf01072ed
f010340b:	e8 84 cc ff ff       	call   f0100094 <_panic>
f0103410:	05 00 00 00 10       	add    $0x10000000,%eax
f0103415:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103418:	8b 5f 48             	mov    0x48(%edi),%ebx
f010341b:	e8 e2 24 00 00       	call   f0105902 <cpunum>
f0103420:	6b c0 74             	imul   $0x74,%eax,%eax
f0103423:	ba 00 00 00 00       	mov    $0x0,%edx
f0103428:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010342f:	74 11                	je     f0103442 <env_free+0x6f>
f0103431:	e8 cc 24 00 00       	call   f0105902 <cpunum>
f0103436:	6b c0 74             	imul   $0x74,%eax,%eax
f0103439:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010343f:	8b 50 48             	mov    0x48(%eax),%edx
f0103442:	83 ec 04             	sub    $0x4,%esp
f0103445:	53                   	push   %ebx
f0103446:	52                   	push   %edx
f0103447:	68 37 73 10 f0       	push   $0xf0107337
f010344c:	e8 1a 04 00 00       	call   f010386b <cprintf>
f0103451:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103454:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010345b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010345e:	89 d0                	mov    %edx,%eax
f0103460:	c1 e0 02             	shl    $0x2,%eax
f0103463:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103466:	8b 47 60             	mov    0x60(%edi),%eax
f0103469:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010346c:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103472:	0f 84 a8 00 00 00    	je     f0103520 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103478:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010347e:	89 f0                	mov    %esi,%eax
f0103480:	c1 e8 0c             	shr    $0xc,%eax
f0103483:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103486:	39 05 88 be 22 f0    	cmp    %eax,0xf022be88
f010348c:	77 15                	ja     f01034a3 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010348e:	56                   	push   %esi
f010348f:	68 54 60 10 f0       	push   $0xf0106054
f0103494:	68 f4 01 00 00       	push   $0x1f4
f0103499:	68 ed 72 10 f0       	push   $0xf01072ed
f010349e:	e8 f1 cb ff ff       	call   f0100094 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034a6:	c1 e0 16             	shl    $0x16,%eax
f01034a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034ac:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034b1:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034b8:	01 
f01034b9:	74 17                	je     f01034d2 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034bb:	83 ec 08             	sub    $0x8,%esp
f01034be:	89 d8                	mov    %ebx,%eax
f01034c0:	c1 e0 0c             	shl    $0xc,%eax
f01034c3:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034c6:	50                   	push   %eax
f01034c7:	ff 77 60             	pushl  0x60(%edi)
f01034ca:	e8 4b de ff ff       	call   f010131a <page_remove>
f01034cf:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034d2:	83 c3 01             	add    $0x1,%ebx
f01034d5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034db:	75 d4                	jne    f01034b1 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034dd:	8b 47 60             	mov    0x60(%edi),%eax
f01034e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034e3:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034ea:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034ed:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01034f3:	72 14                	jb     f0103509 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01034f5:	83 ec 04             	sub    $0x4,%esp
f01034f8:	68 38 67 10 f0       	push   $0xf0106738
f01034fd:	6a 51                	push   $0x51
f01034ff:	68 ad 6f 10 f0       	push   $0xf0106fad
f0103504:	e8 8b cb ff ff       	call   f0100094 <_panic>
		page_decref(pa2page(pa));
f0103509:	83 ec 0c             	sub    $0xc,%esp
f010350c:	a1 90 be 22 f0       	mov    0xf022be90,%eax
f0103511:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103514:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103517:	50                   	push   %eax
f0103518:	e8 c7 db ff ff       	call   f01010e4 <page_decref>
f010351d:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103520:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103524:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103527:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010352c:	0f 85 29 ff ff ff    	jne    f010345b <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103532:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103535:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010353a:	77 15                	ja     f0103551 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010353c:	50                   	push   %eax
f010353d:	68 78 60 10 f0       	push   $0xf0106078
f0103542:	68 02 02 00 00       	push   $0x202
f0103547:	68 ed 72 10 f0       	push   $0xf01072ed
f010354c:	e8 43 cb ff ff       	call   f0100094 <_panic>
	e->env_pgdir = 0;
f0103551:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103558:	05 00 00 00 10       	add    $0x10000000,%eax
f010355d:	c1 e8 0c             	shr    $0xc,%eax
f0103560:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f0103566:	72 14                	jb     f010357c <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103568:	83 ec 04             	sub    $0x4,%esp
f010356b:	68 38 67 10 f0       	push   $0xf0106738
f0103570:	6a 51                	push   $0x51
f0103572:	68 ad 6f 10 f0       	push   $0xf0106fad
f0103577:	e8 18 cb ff ff       	call   f0100094 <_panic>
	page_decref(pa2page(pa));
f010357c:	83 ec 0c             	sub    $0xc,%esp
f010357f:	8b 15 90 be 22 f0    	mov    0xf022be90,%edx
f0103585:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103588:	50                   	push   %eax
f0103589:	e8 56 db ff ff       	call   f01010e4 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010358e:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103595:	a1 48 b2 22 f0       	mov    0xf022b248,%eax
f010359a:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010359d:	89 3d 48 b2 22 f0    	mov    %edi,0xf022b248
}
f01035a3:	83 c4 10             	add    $0x10,%esp
f01035a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035a9:	5b                   	pop    %ebx
f01035aa:	5e                   	pop    %esi
f01035ab:	5f                   	pop    %edi
f01035ac:	5d                   	pop    %ebp
f01035ad:	c3                   	ret    

f01035ae <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035ae:	55                   	push   %ebp
f01035af:	89 e5                	mov    %esp,%ebp
f01035b1:	53                   	push   %ebx
f01035b2:	83 ec 04             	sub    $0x4,%esp
f01035b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035b8:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035bc:	75 19                	jne    f01035d7 <env_destroy+0x29>
f01035be:	e8 3f 23 00 00       	call   f0105902 <cpunum>
f01035c3:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c6:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01035cc:	74 09                	je     f01035d7 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035ce:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035d5:	eb 33                	jmp    f010360a <env_destroy+0x5c>
	}

	env_free(e);
f01035d7:	83 ec 0c             	sub    $0xc,%esp
f01035da:	53                   	push   %ebx
f01035db:	e8 f3 fd ff ff       	call   f01033d3 <env_free>

	if (curenv == e) {
f01035e0:	e8 1d 23 00 00       	call   f0105902 <cpunum>
f01035e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e8:	83 c4 10             	add    $0x10,%esp
f01035eb:	3b 98 28 c0 22 f0    	cmp    -0xfdd3fd8(%eax),%ebx
f01035f1:	75 17                	jne    f010360a <env_destroy+0x5c>
		curenv = NULL;
f01035f3:	e8 0a 23 00 00       	call   f0105902 <cpunum>
f01035f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fb:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0103602:	00 00 00 
		sched_yield();
f0103605:	e8 7e 0c 00 00       	call   f0104288 <sched_yield>
	}
}
f010360a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010360d:	c9                   	leave  
f010360e:	c3                   	ret    

f010360f <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010360f:	55                   	push   %ebp
f0103610:	89 e5                	mov    %esp,%ebp
f0103612:	53                   	push   %ebx
f0103613:	83 ec 04             	sub    $0x4,%esp

	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103616:	e8 e7 22 00 00       	call   f0105902 <cpunum>
f010361b:	6b c0 74             	imul   $0x74,%eax,%eax
f010361e:	8b 98 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%ebx
f0103624:	e8 d9 22 00 00       	call   f0105902 <cpunum>
f0103629:	89 43 5c             	mov    %eax,0x5c(%ebx)
	asm volatile(
f010362c:	8b 65 08             	mov    0x8(%ebp),%esp
f010362f:	61                   	popa   
f0103630:	07                   	pop    %es
f0103631:	1f                   	pop    %ds
f0103632:	83 c4 08             	add    $0x8,%esp
f0103635:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103636:	83 ec 04             	sub    $0x4,%esp
f0103639:	68 4d 73 10 f0       	push   $0xf010734d
f010363e:	68 39 02 00 00       	push   $0x239
f0103643:	68 ed 72 10 f0       	push   $0xf01072ed
f0103648:	e8 47 ca ff ff       	call   f0100094 <_panic>

f010364d <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010364d:	55                   	push   %ebp
f010364e:	89 e5                	mov    %esp,%ebp
f0103650:	53                   	push   %ebx
f0103651:	83 ec 04             	sub    $0x4,%esp
f0103654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if(curenv && curenv->env_status == ENV_RUNNING)
f0103657:	e8 a6 22 00 00       	call   f0105902 <cpunum>
f010365c:	6b c0 74             	imul   $0x74,%eax,%eax
f010365f:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103666:	74 29                	je     f0103691 <env_run+0x44>
f0103668:	e8 95 22 00 00       	call   f0105902 <cpunum>
f010366d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103670:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103676:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010367a:	75 15                	jne    f0103691 <env_run+0x44>
	{
			curenv->env_status = ENV_RUNNABLE;
f010367c:	e8 81 22 00 00       	call   f0105902 <cpunum>
f0103681:	6b c0 74             	imul   $0x74,%eax,%eax
f0103684:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010368a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
 
	curenv = e;
f0103691:	e8 6c 22 00 00       	call   f0105902 <cpunum>
f0103696:	6b c0 74             	imul   $0x74,%eax,%eax
f0103699:	89 98 28 c0 22 f0    	mov    %ebx,-0xfdd3fd8(%eax)
	e->env_status = ENV_RUNNING;
f010369f:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f01036a6:	83 43 58 01          	addl   $0x1,0x58(%ebx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036aa:	83 ec 0c             	sub    $0xc,%esp
f01036ad:	68 c0 03 12 f0       	push   $0xf01203c0
f01036b2:	e8 56 25 00 00       	call   f0105c0d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036b7:	f3 90                	pause  
	unlock_kernel();
	lcr3(PADDR(e->env_pgdir));	
f01036b9:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036bc:	83 c4 10             	add    $0x10,%esp
f01036bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036c4:	77 15                	ja     f01036db <env_run+0x8e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036c6:	50                   	push   %eax
f01036c7:	68 78 60 10 f0       	push   $0xf0106078
f01036cc:	68 61 02 00 00       	push   $0x261
f01036d1:	68 ed 72 10 f0       	push   $0xf01072ed
f01036d6:	e8 b9 c9 ff ff       	call   f0100094 <_panic>
f01036db:	05 00 00 00 10       	add    $0x10000000,%eax
f01036e0:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&(e->env_tf));
f01036e3:	83 ec 0c             	sub    $0xc,%esp
f01036e6:	53                   	push   %ebx
f01036e7:	e8 23 ff ff ff       	call   f010360f <env_pop_tf>

f01036ec <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036ec:	55                   	push   %ebp
f01036ed:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036ef:	ba 70 00 00 00       	mov    $0x70,%edx
f01036f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01036f7:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036f8:	ba 71 00 00 00       	mov    $0x71,%edx
f01036fd:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036fe:	0f b6 c0             	movzbl %al,%eax
}
f0103701:	5d                   	pop    %ebp
f0103702:	c3                   	ret    

f0103703 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103703:	55                   	push   %ebp
f0103704:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103706:	ba 70 00 00 00       	mov    $0x70,%edx
f010370b:	8b 45 08             	mov    0x8(%ebp),%eax
f010370e:	ee                   	out    %al,(%dx)
f010370f:	ba 71 00 00 00       	mov    $0x71,%edx
f0103714:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103717:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103718:	5d                   	pop    %ebp
f0103719:	c3                   	ret    

f010371a <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010371a:	55                   	push   %ebp
f010371b:	89 e5                	mov    %esp,%ebp
f010371d:	56                   	push   %esi
f010371e:	53                   	push   %ebx
f010371f:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103722:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103728:	80 3d 4c b2 22 f0 00 	cmpb   $0x0,0xf022b24c
f010372f:	74 5a                	je     f010378b <irq_setmask_8259A+0x71>
f0103731:	89 c6                	mov    %eax,%esi
f0103733:	ba 21 00 00 00       	mov    $0x21,%edx
f0103738:	ee                   	out    %al,(%dx)
f0103739:	66 c1 e8 08          	shr    $0x8,%ax
f010373d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103742:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103743:	83 ec 0c             	sub    $0xc,%esp
f0103746:	68 09 74 10 f0       	push   $0xf0107409
f010374b:	e8 1b 01 00 00       	call   f010386b <cprintf>
f0103750:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103753:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103758:	0f b7 f6             	movzwl %si,%esi
f010375b:	f7 d6                	not    %esi
f010375d:	0f a3 de             	bt     %ebx,%esi
f0103760:	73 11                	jae    f0103773 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103762:	83 ec 08             	sub    $0x8,%esp
f0103765:	53                   	push   %ebx
f0103766:	68 d7 79 10 f0       	push   $0xf01079d7
f010376b:	e8 fb 00 00 00       	call   f010386b <cprintf>
f0103770:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103773:	83 c3 01             	add    $0x1,%ebx
f0103776:	83 fb 10             	cmp    $0x10,%ebx
f0103779:	75 e2                	jne    f010375d <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010377b:	83 ec 0c             	sub    $0xc,%esp
f010377e:	68 64 63 10 f0       	push   $0xf0106364
f0103783:	e8 e3 00 00 00       	call   f010386b <cprintf>
f0103788:	83 c4 10             	add    $0x10,%esp
}
f010378b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010378e:	5b                   	pop    %ebx
f010378f:	5e                   	pop    %esi
f0103790:	5d                   	pop    %ebp
f0103791:	c3                   	ret    

f0103792 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103792:	c6 05 4c b2 22 f0 01 	movb   $0x1,0xf022b24c
f0103799:	ba 21 00 00 00       	mov    $0x21,%edx
f010379e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037a3:	ee                   	out    %al,(%dx)
f01037a4:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037a9:	ee                   	out    %al,(%dx)
f01037aa:	ba 20 00 00 00       	mov    $0x20,%edx
f01037af:	b8 11 00 00 00       	mov    $0x11,%eax
f01037b4:	ee                   	out    %al,(%dx)
f01037b5:	ba 21 00 00 00       	mov    $0x21,%edx
f01037ba:	b8 20 00 00 00       	mov    $0x20,%eax
f01037bf:	ee                   	out    %al,(%dx)
f01037c0:	b8 04 00 00 00       	mov    $0x4,%eax
f01037c5:	ee                   	out    %al,(%dx)
f01037c6:	b8 03 00 00 00       	mov    $0x3,%eax
f01037cb:	ee                   	out    %al,(%dx)
f01037cc:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037d1:	b8 11 00 00 00       	mov    $0x11,%eax
f01037d6:	ee                   	out    %al,(%dx)
f01037d7:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037dc:	b8 28 00 00 00       	mov    $0x28,%eax
f01037e1:	ee                   	out    %al,(%dx)
f01037e2:	b8 02 00 00 00       	mov    $0x2,%eax
f01037e7:	ee                   	out    %al,(%dx)
f01037e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01037ed:	ee                   	out    %al,(%dx)
f01037ee:	ba 20 00 00 00       	mov    $0x20,%edx
f01037f3:	b8 68 00 00 00       	mov    $0x68,%eax
f01037f8:	ee                   	out    %al,(%dx)
f01037f9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037fe:	ee                   	out    %al,(%dx)
f01037ff:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103804:	b8 68 00 00 00       	mov    $0x68,%eax
f0103809:	ee                   	out    %al,(%dx)
f010380a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010380f:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103810:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f0103817:	66 83 f8 ff          	cmp    $0xffff,%ax
f010381b:	74 13                	je     f0103830 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010381d:	55                   	push   %ebp
f010381e:	89 e5                	mov    %esp,%ebp
f0103820:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103823:	0f b7 c0             	movzwl %ax,%eax
f0103826:	50                   	push   %eax
f0103827:	e8 ee fe ff ff       	call   f010371a <irq_setmask_8259A>
f010382c:	83 c4 10             	add    $0x10,%esp
}
f010382f:	c9                   	leave  
f0103830:	f3 c3                	repz ret 

f0103832 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103832:	55                   	push   %ebp
f0103833:	89 e5                	mov    %esp,%ebp
f0103835:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103838:	ff 75 08             	pushl  0x8(%ebp)
f010383b:	e8 80 cf ff ff       	call   f01007c0 <cputchar>
	*cnt++;
}
f0103840:	83 c4 10             	add    $0x10,%esp
f0103843:	c9                   	leave  
f0103844:	c3                   	ret    

f0103845 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103845:	55                   	push   %ebp
f0103846:	89 e5                	mov    %esp,%ebp
f0103848:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010384b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103852:	ff 75 0c             	pushl  0xc(%ebp)
f0103855:	ff 75 08             	pushl  0x8(%ebp)
f0103858:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010385b:	50                   	push   %eax
f010385c:	68 32 38 10 f0       	push   $0xf0103832
f0103861:	e8 c5 13 00 00       	call   f0104c2b <vprintfmt>
	return cnt;
}
f0103866:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103869:	c9                   	leave  
f010386a:	c3                   	ret    

f010386b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010386b:	55                   	push   %ebp
f010386c:	89 e5                	mov    %esp,%ebp
f010386e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103871:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103874:	50                   	push   %eax
f0103875:	ff 75 08             	pushl  0x8(%ebp)
f0103878:	e8 c8 ff ff ff       	call   f0103845 <vcprintf>
	va_end(ap);

	return cnt;
}
f010387d:	c9                   	leave  
f010387e:	c3                   	ret    

f010387f <trap_init_percpu>:
*/
// Initialize and load the per-CPU TSS and IDT

void
trap_init_percpu(void)
{
f010387f:	55                   	push   %ebp
f0103880:	89 e5                	mov    %esp,%ebp
f0103882:	57                   	push   %edi
f0103883:	56                   	push   %esi
f0103884:	53                   	push   %ebx
f0103885:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP-cpunum()*(KSTKSIZE+KSTKGAP);
f0103888:	e8 75 20 00 00       	call   f0105902 <cpunum>
f010388d:	89 c3                	mov    %eax,%ebx
f010388f:	e8 6e 20 00 00       	call   f0105902 <cpunum>
f0103894:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103897:	c1 e0 10             	shl    $0x10,%eax
f010389a:	89 c2                	mov    %eax,%edx
f010389c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01038a1:	29 d0                	sub    %edx,%eax
f01038a3:	89 83 30 c0 22 f0    	mov    %eax,-0xfdd3fd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038a9:	e8 54 20 00 00       	call   f0105902 <cpunum>
f01038ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01038b1:	66 c7 80 34 c0 22 f0 	movw   $0x10,-0xfdd3fcc(%eax)
f01038b8:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01038ba:	e8 43 20 00 00       	call   f0105902 <cpunum>
f01038bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c2:	66 c7 80 92 c0 22 f0 	movw   $0x68,-0xfdd3f6e(%eax)
f01038c9:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01038cb:	e8 32 20 00 00       	call   f0105902 <cpunum>
f01038d0:	8d 58 05             	lea    0x5(%eax),%ebx
f01038d3:	e8 2a 20 00 00       	call   f0105902 <cpunum>
f01038d8:	89 c7                	mov    %eax,%edi
f01038da:	e8 23 20 00 00       	call   f0105902 <cpunum>
f01038df:	89 c6                	mov    %eax,%esi
f01038e1:	e8 1c 20 00 00       	call   f0105902 <cpunum>
f01038e6:	66 c7 04 dd 40 03 12 	movw   $0x67,-0xfedfcc0(,%ebx,8)
f01038ed:	f0 67 00 
f01038f0:	6b ff 74             	imul   $0x74,%edi,%edi
f01038f3:	81 c7 2c c0 22 f0    	add    $0xf022c02c,%edi
f01038f9:	66 89 3c dd 42 03 12 	mov    %di,-0xfedfcbe(,%ebx,8)
f0103900:	f0 
f0103901:	6b d6 74             	imul   $0x74,%esi,%edx
f0103904:	81 c2 2c c0 22 f0    	add    $0xf022c02c,%edx
f010390a:	c1 ea 10             	shr    $0x10,%edx
f010390d:	88 14 dd 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%ebx,8)
f0103914:	c6 04 dd 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%ebx,8)
f010391b:	99 
f010391c:	c6 04 dd 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%ebx,8)
f0103923:	40 
f0103924:	6b c0 74             	imul   $0x74,%eax,%eax
f0103927:	05 2c c0 22 f0       	add    $0xf022c02c,%eax
f010392c:	c1 e8 18             	shr    $0x18,%eax
f010392f:	88 04 dd 47 03 12 f0 	mov    %al,-0xfedfcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+cpunum()].sd_s = 0;
f0103936:	e8 c7 1f 00 00       	call   f0105902 <cpunum>
f010393b:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f0103942:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(thiscpu->cpu_id<<3));//why do this?I cannot unstanderd.
f0103943:	e8 ba 1f 00 00       	call   f0105902 <cpunum>
f0103948:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f010394b:	0f b6 80 20 c0 22 f0 	movzbl -0xfdd3fe0(%eax),%eax
f0103952:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103959:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010395c:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f0103961:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
	*/
}
f0103964:	83 c4 0c             	add    $0xc,%esp
f0103967:	5b                   	pop    %ebx
f0103968:	5e                   	pop    %esi
f0103969:	5f                   	pop    %edi
f010396a:	5d                   	pop    %ebp
f010396b:	c3                   	ret    

f010396c <trap_init>:
}


void
trap_init(void)
{
f010396c:	55                   	push   %ebp
f010396d:	89 e5                	mov    %esp,%ebp
f010396f:	83 ec 08             	sub    $0x8,%esp
   	void t_align();
	void t_mchk();
	void t_simderr();
	void t_syscall();

	SETGATE(idt[T_DIVIDE],0,GD_KT,t_divide,0);
f0103972:	b8 40 41 10 f0       	mov    $0xf0104140,%eax
f0103977:	66 a3 60 b2 22 f0    	mov    %ax,0xf022b260
f010397d:	66 c7 05 62 b2 22 f0 	movw   $0x8,0xf022b262
f0103984:	08 00 
f0103986:	c6 05 64 b2 22 f0 00 	movb   $0x0,0xf022b264
f010398d:	c6 05 65 b2 22 f0 8e 	movb   $0x8e,0xf022b265
f0103994:	c1 e8 10             	shr    $0x10,%eax
f0103997:	66 a3 66 b2 22 f0    	mov    %ax,0xf022b266
	SETGATE(idt[T_DEBUG],0,GD_KT,t_debug,0);
f010399d:	b8 46 41 10 f0       	mov    $0xf0104146,%eax
f01039a2:	66 a3 68 b2 22 f0    	mov    %ax,0xf022b268
f01039a8:	66 c7 05 6a b2 22 f0 	movw   $0x8,0xf022b26a
f01039af:	08 00 
f01039b1:	c6 05 6c b2 22 f0 00 	movb   $0x0,0xf022b26c
f01039b8:	c6 05 6d b2 22 f0 8e 	movb   $0x8e,0xf022b26d
f01039bf:	c1 e8 10             	shr    $0x10,%eax
f01039c2:	66 a3 6e b2 22 f0    	mov    %ax,0xf022b26e
//	SETGAET(idt[T_NMI],0,GD_KT,t_nmi,0);
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01039c8:	b8 52 41 10 f0       	mov    $0xf0104152,%eax
f01039cd:	66 a3 78 b2 22 f0    	mov    %ax,0xf022b278
f01039d3:	66 c7 05 7a b2 22 f0 	movw   $0x8,0xf022b27a
f01039da:	08 00 
f01039dc:	c6 05 7c b2 22 f0 00 	movb   $0x0,0xf022b27c
f01039e3:	c6 05 7d b2 22 f0 ee 	movb   $0xee,0xf022b27d
f01039ea:	c1 e8 10             	shr    $0x10,%eax
f01039ed:	66 a3 7e b2 22 f0    	mov    %ax,0xf022b27e
   	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01039f3:	b8 58 41 10 f0       	mov    $0xf0104158,%eax
f01039f8:	66 a3 80 b2 22 f0    	mov    %ax,0xf022b280
f01039fe:	66 c7 05 82 b2 22 f0 	movw   $0x8,0xf022b282
f0103a05:	08 00 
f0103a07:	c6 05 84 b2 22 f0 00 	movb   $0x0,0xf022b284
f0103a0e:	c6 05 85 b2 22 f0 8e 	movb   $0x8e,0xf022b285
f0103a15:	c1 e8 10             	shr    $0x10,%eax
f0103a18:	66 a3 86 b2 22 f0    	mov    %ax,0xf022b286
        SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103a1e:	b8 5e 41 10 f0       	mov    $0xf010415e,%eax
f0103a23:	66 a3 88 b2 22 f0    	mov    %ax,0xf022b288
f0103a29:	66 c7 05 8a b2 22 f0 	movw   $0x8,0xf022b28a
f0103a30:	08 00 
f0103a32:	c6 05 8c b2 22 f0 00 	movb   $0x0,0xf022b28c
f0103a39:	c6 05 8d b2 22 f0 8e 	movb   $0x8e,0xf022b28d
f0103a40:	c1 e8 10             	shr    $0x10,%eax
f0103a43:	66 a3 8e b2 22 f0    	mov    %ax,0xf022b28e
        SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103a49:	b8 64 41 10 f0       	mov    $0xf0104164,%eax
f0103a4e:	66 a3 90 b2 22 f0    	mov    %ax,0xf022b290
f0103a54:	66 c7 05 92 b2 22 f0 	movw   $0x8,0xf022b292
f0103a5b:	08 00 
f0103a5d:	c6 05 94 b2 22 f0 00 	movb   $0x0,0xf022b294
f0103a64:	c6 05 95 b2 22 f0 8e 	movb   $0x8e,0xf022b295
f0103a6b:	c1 e8 10             	shr    $0x10,%eax
f0103a6e:	66 a3 96 b2 22 f0    	mov    %ax,0xf022b296
        SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103a74:	b8 6a 41 10 f0       	mov    $0xf010416a,%eax
f0103a79:	66 a3 98 b2 22 f0    	mov    %ax,0xf022b298
f0103a7f:	66 c7 05 9a b2 22 f0 	movw   $0x8,0xf022b29a
f0103a86:	08 00 
f0103a88:	c6 05 9c b2 22 f0 00 	movb   $0x0,0xf022b29c
f0103a8f:	c6 05 9d b2 22 f0 8e 	movb   $0x8e,0xf022b29d
f0103a96:	c1 e8 10             	shr    $0x10,%eax
f0103a99:	66 a3 9e b2 22 f0    	mov    %ax,0xf022b29e
   	 SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103a9f:	b8 70 41 10 f0       	mov    $0xf0104170,%eax
f0103aa4:	66 a3 a0 b2 22 f0    	mov    %ax,0xf022b2a0
f0103aaa:	66 c7 05 a2 b2 22 f0 	movw   $0x8,0xf022b2a2
f0103ab1:	08 00 
f0103ab3:	c6 05 a4 b2 22 f0 00 	movb   $0x0,0xf022b2a4
f0103aba:	c6 05 a5 b2 22 f0 8e 	movb   $0x8e,0xf022b2a5
f0103ac1:	c1 e8 10             	shr    $0x10,%eax
f0103ac4:	66 a3 a6 b2 22 f0    	mov    %ax,0xf022b2a6
   	 SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103aca:	b8 74 41 10 f0       	mov    $0xf0104174,%eax
f0103acf:	66 a3 b0 b2 22 f0    	mov    %ax,0xf022b2b0
f0103ad5:	66 c7 05 b2 b2 22 f0 	movw   $0x8,0xf022b2b2
f0103adc:	08 00 
f0103ade:	c6 05 b4 b2 22 f0 00 	movb   $0x0,0xf022b2b4
f0103ae5:	c6 05 b5 b2 22 f0 8e 	movb   $0x8e,0xf022b2b5
f0103aec:	c1 e8 10             	shr    $0x10,%eax
f0103aef:	66 a3 b6 b2 22 f0    	mov    %ax,0xf022b2b6
  	 SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103af5:	b8 78 41 10 f0       	mov    $0xf0104178,%eax
f0103afa:	66 a3 b8 b2 22 f0    	mov    %ax,0xf022b2b8
f0103b00:	66 c7 05 ba b2 22 f0 	movw   $0x8,0xf022b2ba
f0103b07:	08 00 
f0103b09:	c6 05 bc b2 22 f0 00 	movb   $0x0,0xf022b2bc
f0103b10:	c6 05 bd b2 22 f0 8e 	movb   $0x8e,0xf022b2bd
f0103b17:	c1 e8 10             	shr    $0x10,%eax
f0103b1a:	66 a3 be b2 22 f0    	mov    %ax,0xf022b2be
   	 SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103b20:	b8 7c 41 10 f0       	mov    $0xf010417c,%eax
f0103b25:	66 a3 c0 b2 22 f0    	mov    %ax,0xf022b2c0
f0103b2b:	66 c7 05 c2 b2 22 f0 	movw   $0x8,0xf022b2c2
f0103b32:	08 00 
f0103b34:	c6 05 c4 b2 22 f0 00 	movb   $0x0,0xf022b2c4
f0103b3b:	c6 05 c5 b2 22 f0 8e 	movb   $0x8e,0xf022b2c5
f0103b42:	c1 e8 10             	shr    $0x10,%eax
f0103b45:	66 a3 c6 b2 22 f0    	mov    %ax,0xf022b2c6
   	 SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103b4b:	b8 80 41 10 f0       	mov    $0xf0104180,%eax
f0103b50:	66 a3 c8 b2 22 f0    	mov    %ax,0xf022b2c8
f0103b56:	66 c7 05 ca b2 22 f0 	movw   $0x8,0xf022b2ca
f0103b5d:	08 00 
f0103b5f:	c6 05 cc b2 22 f0 00 	movb   $0x0,0xf022b2cc
f0103b66:	c6 05 cd b2 22 f0 8e 	movb   $0x8e,0xf022b2cd
f0103b6d:	c1 e8 10             	shr    $0x10,%eax
f0103b70:	66 a3 ce b2 22 f0    	mov    %ax,0xf022b2ce
   	 SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103b76:	b8 84 41 10 f0       	mov    $0xf0104184,%eax
f0103b7b:	66 a3 d0 b2 22 f0    	mov    %ax,0xf022b2d0
f0103b81:	66 c7 05 d2 b2 22 f0 	movw   $0x8,0xf022b2d2
f0103b88:	08 00 
f0103b8a:	c6 05 d4 b2 22 f0 00 	movb   $0x0,0xf022b2d4
f0103b91:	c6 05 d5 b2 22 f0 8e 	movb   $0x8e,0xf022b2d5
f0103b98:	c1 e8 10             	shr    $0x10,%eax
f0103b9b:	66 a3 d6 b2 22 f0    	mov    %ax,0xf022b2d6
   	 SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f0103ba1:	b8 88 41 10 f0       	mov    $0xf0104188,%eax
f0103ba6:	66 a3 e0 b2 22 f0    	mov    %ax,0xf022b2e0
f0103bac:	66 c7 05 e2 b2 22 f0 	movw   $0x8,0xf022b2e2
f0103bb3:	08 00 
f0103bb5:	c6 05 e4 b2 22 f0 00 	movb   $0x0,0xf022b2e4
f0103bbc:	c6 05 e5 b2 22 f0 8e 	movb   $0x8e,0xf022b2e5
f0103bc3:	c1 e8 10             	shr    $0x10,%eax
f0103bc6:	66 a3 e6 b2 22 f0    	mov    %ax,0xf022b2e6
   	 SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103bcc:	b8 8e 41 10 f0       	mov    $0xf010418e,%eax
f0103bd1:	66 a3 e8 b2 22 f0    	mov    %ax,0xf022b2e8
f0103bd7:	66 c7 05 ea b2 22 f0 	movw   $0x8,0xf022b2ea
f0103bde:	08 00 
f0103be0:	c6 05 ec b2 22 f0 00 	movb   $0x0,0xf022b2ec
f0103be7:	c6 05 ed b2 22 f0 8e 	movb   $0x8e,0xf022b2ed
f0103bee:	c1 e8 10             	shr    $0x10,%eax
f0103bf1:	66 a3 ee b2 22 f0    	mov    %ax,0xf022b2ee
   	 SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103bf7:	b8 92 41 10 f0       	mov    $0xf0104192,%eax
f0103bfc:	66 a3 f0 b2 22 f0    	mov    %ax,0xf022b2f0
f0103c02:	66 c7 05 f2 b2 22 f0 	movw   $0x8,0xf022b2f2
f0103c09:	08 00 
f0103c0b:	c6 05 f4 b2 22 f0 00 	movb   $0x0,0xf022b2f4
f0103c12:	c6 05 f5 b2 22 f0 8e 	movb   $0x8e,0xf022b2f5
f0103c19:	c1 e8 10             	shr    $0x10,%eax
f0103c1c:	66 a3 f6 b2 22 f0    	mov    %ax,0xf022b2f6
   	 SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103c22:	b8 98 41 10 f0       	mov    $0xf0104198,%eax
f0103c27:	66 a3 f8 b2 22 f0    	mov    %ax,0xf022b2f8
f0103c2d:	66 c7 05 fa b2 22 f0 	movw   $0x8,0xf022b2fa
f0103c34:	08 00 
f0103c36:	c6 05 fc b2 22 f0 00 	movb   $0x0,0xf022b2fc
f0103c3d:	c6 05 fd b2 22 f0 8e 	movb   $0x8e,0xf022b2fd
f0103c44:	c1 e8 10             	shr    $0x10,%eax
f0103c47:	66 a3 fe b2 22 f0    	mov    %ax,0xf022b2fe
   	 SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103c4d:	b8 9e 41 10 f0       	mov    $0xf010419e,%eax
f0103c52:	66 a3 e0 b3 22 f0    	mov    %ax,0xf022b3e0
f0103c58:	66 c7 05 e2 b3 22 f0 	movw   $0x8,0xf022b3e2
f0103c5f:	08 00 
f0103c61:	c6 05 e4 b3 22 f0 00 	movb   $0x0,0xf022b3e4
f0103c68:	c6 05 e5 b3 22 f0 ee 	movb   $0xee,0xf022b3e5
f0103c6f:	c1 e8 10             	shr    $0x10,%eax
f0103c72:	66 a3 e6 b3 22 f0    	mov    %ax,0xf022b3e6
	// Per-CPU setup 
	trap_init_percpu();
f0103c78:	e8 02 fc ff ff       	call   f010387f <trap_init_percpu>
}
f0103c7d:	c9                   	leave  
f0103c7e:	c3                   	ret    

f0103c7f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103c7f:	55                   	push   %ebp
f0103c80:	89 e5                	mov    %esp,%ebp
f0103c82:	53                   	push   %ebx
f0103c83:	83 ec 0c             	sub    $0xc,%esp
f0103c86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103c89:	ff 33                	pushl  (%ebx)
f0103c8b:	68 1d 74 10 f0       	push   $0xf010741d
f0103c90:	e8 d6 fb ff ff       	call   f010386b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103c95:	83 c4 08             	add    $0x8,%esp
f0103c98:	ff 73 04             	pushl  0x4(%ebx)
f0103c9b:	68 2c 74 10 f0       	push   $0xf010742c
f0103ca0:	e8 c6 fb ff ff       	call   f010386b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ca5:	83 c4 08             	add    $0x8,%esp
f0103ca8:	ff 73 08             	pushl  0x8(%ebx)
f0103cab:	68 3b 74 10 f0       	push   $0xf010743b
f0103cb0:	e8 b6 fb ff ff       	call   f010386b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103cb5:	83 c4 08             	add    $0x8,%esp
f0103cb8:	ff 73 0c             	pushl  0xc(%ebx)
f0103cbb:	68 4a 74 10 f0       	push   $0xf010744a
f0103cc0:	e8 a6 fb ff ff       	call   f010386b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103cc5:	83 c4 08             	add    $0x8,%esp
f0103cc8:	ff 73 10             	pushl  0x10(%ebx)
f0103ccb:	68 59 74 10 f0       	push   $0xf0107459
f0103cd0:	e8 96 fb ff ff       	call   f010386b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103cd5:	83 c4 08             	add    $0x8,%esp
f0103cd8:	ff 73 14             	pushl  0x14(%ebx)
f0103cdb:	68 68 74 10 f0       	push   $0xf0107468
f0103ce0:	e8 86 fb ff ff       	call   f010386b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103ce5:	83 c4 08             	add    $0x8,%esp
f0103ce8:	ff 73 18             	pushl  0x18(%ebx)
f0103ceb:	68 77 74 10 f0       	push   $0xf0107477
f0103cf0:	e8 76 fb ff ff       	call   f010386b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103cf5:	83 c4 08             	add    $0x8,%esp
f0103cf8:	ff 73 1c             	pushl  0x1c(%ebx)
f0103cfb:	68 86 74 10 f0       	push   $0xf0107486
f0103d00:	e8 66 fb ff ff       	call   f010386b <cprintf>
}
f0103d05:	83 c4 10             	add    $0x10,%esp
f0103d08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d0b:	c9                   	leave  
f0103d0c:	c3                   	ret    

f0103d0d <print_trapframe>:
	*/
}

void
print_trapframe(struct Trapframe *tf)
{
f0103d0d:	55                   	push   %ebp
f0103d0e:	89 e5                	mov    %esp,%ebp
f0103d10:	56                   	push   %esi
f0103d11:	53                   	push   %ebx
f0103d12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103d15:	e8 e8 1b 00 00       	call   f0105902 <cpunum>
f0103d1a:	83 ec 04             	sub    $0x4,%esp
f0103d1d:	50                   	push   %eax
f0103d1e:	53                   	push   %ebx
f0103d1f:	68 ea 74 10 f0       	push   $0xf01074ea
f0103d24:	e8 42 fb ff ff       	call   f010386b <cprintf>
	print_regs(&tf->tf_regs);
f0103d29:	89 1c 24             	mov    %ebx,(%esp)
f0103d2c:	e8 4e ff ff ff       	call   f0103c7f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103d31:	83 c4 08             	add    $0x8,%esp
f0103d34:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103d38:	50                   	push   %eax
f0103d39:	68 08 75 10 f0       	push   $0xf0107508
f0103d3e:	e8 28 fb ff ff       	call   f010386b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103d43:	83 c4 08             	add    $0x8,%esp
f0103d46:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103d4a:	50                   	push   %eax
f0103d4b:	68 1b 75 10 f0       	push   $0xf010751b
f0103d50:	e8 16 fb ff ff       	call   f010386b <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d55:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103d58:	83 c4 10             	add    $0x10,%esp
f0103d5b:	83 f8 13             	cmp    $0x13,%eax
f0103d5e:	77 09                	ja     f0103d69 <print_trapframe+0x5c>
		return excnames[trapno];
f0103d60:	8b 14 85 c0 77 10 f0 	mov    -0xfef8840(,%eax,4),%edx
f0103d67:	eb 1f                	jmp    f0103d88 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103d69:	83 f8 30             	cmp    $0x30,%eax
f0103d6c:	74 15                	je     f0103d83 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103d6e:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103d71:	83 fa 10             	cmp    $0x10,%edx
f0103d74:	b9 b4 74 10 f0       	mov    $0xf01074b4,%ecx
f0103d79:	ba a1 74 10 f0       	mov    $0xf01074a1,%edx
f0103d7e:	0f 43 d1             	cmovae %ecx,%edx
f0103d81:	eb 05                	jmp    f0103d88 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103d83:	ba 95 74 10 f0       	mov    $0xf0107495,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103d88:	83 ec 04             	sub    $0x4,%esp
f0103d8b:	52                   	push   %edx
f0103d8c:	50                   	push   %eax
f0103d8d:	68 2e 75 10 f0       	push   $0xf010752e
f0103d92:	e8 d4 fa ff ff       	call   f010386b <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103d97:	83 c4 10             	add    $0x10,%esp
f0103d9a:	3b 1d 60 ba 22 f0    	cmp    0xf022ba60,%ebx
f0103da0:	75 1a                	jne    f0103dbc <print_trapframe+0xaf>
f0103da2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103da6:	75 14                	jne    f0103dbc <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103da8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103dab:	83 ec 08             	sub    $0x8,%esp
f0103dae:	50                   	push   %eax
f0103daf:	68 40 75 10 f0       	push   $0xf0107540
f0103db4:	e8 b2 fa ff ff       	call   f010386b <cprintf>
f0103db9:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103dbc:	83 ec 08             	sub    $0x8,%esp
f0103dbf:	ff 73 2c             	pushl  0x2c(%ebx)
f0103dc2:	68 4f 75 10 f0       	push   $0xf010754f
f0103dc7:	e8 9f fa ff ff       	call   f010386b <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103dcc:	83 c4 10             	add    $0x10,%esp
f0103dcf:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103dd3:	75 49                	jne    f0103e1e <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103dd5:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103dd8:	89 c2                	mov    %eax,%edx
f0103dda:	83 e2 01             	and    $0x1,%edx
f0103ddd:	ba ce 74 10 f0       	mov    $0xf01074ce,%edx
f0103de2:	b9 c3 74 10 f0       	mov    $0xf01074c3,%ecx
f0103de7:	0f 44 ca             	cmove  %edx,%ecx
f0103dea:	89 c2                	mov    %eax,%edx
f0103dec:	83 e2 02             	and    $0x2,%edx
f0103def:	ba e0 74 10 f0       	mov    $0xf01074e0,%edx
f0103df4:	be da 74 10 f0       	mov    $0xf01074da,%esi
f0103df9:	0f 45 d6             	cmovne %esi,%edx
f0103dfc:	83 e0 04             	and    $0x4,%eax
f0103dff:	be 1a 76 10 f0       	mov    $0xf010761a,%esi
f0103e04:	b8 e5 74 10 f0       	mov    $0xf01074e5,%eax
f0103e09:	0f 44 c6             	cmove  %esi,%eax
f0103e0c:	51                   	push   %ecx
f0103e0d:	52                   	push   %edx
f0103e0e:	50                   	push   %eax
f0103e0f:	68 5d 75 10 f0       	push   $0xf010755d
f0103e14:	e8 52 fa ff ff       	call   f010386b <cprintf>
f0103e19:	83 c4 10             	add    $0x10,%esp
f0103e1c:	eb 10                	jmp    f0103e2e <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103e1e:	83 ec 0c             	sub    $0xc,%esp
f0103e21:	68 64 63 10 f0       	push   $0xf0106364
f0103e26:	e8 40 fa ff ff       	call   f010386b <cprintf>
f0103e2b:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103e2e:	83 ec 08             	sub    $0x8,%esp
f0103e31:	ff 73 30             	pushl  0x30(%ebx)
f0103e34:	68 6c 75 10 f0       	push   $0xf010756c
f0103e39:	e8 2d fa ff ff       	call   f010386b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103e3e:	83 c4 08             	add    $0x8,%esp
f0103e41:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103e45:	50                   	push   %eax
f0103e46:	68 7b 75 10 f0       	push   $0xf010757b
f0103e4b:	e8 1b fa ff ff       	call   f010386b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103e50:	83 c4 08             	add    $0x8,%esp
f0103e53:	ff 73 38             	pushl  0x38(%ebx)
f0103e56:	68 8e 75 10 f0       	push   $0xf010758e
f0103e5b:	e8 0b fa ff ff       	call   f010386b <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103e60:	83 c4 10             	add    $0x10,%esp
f0103e63:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e67:	74 25                	je     f0103e8e <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103e69:	83 ec 08             	sub    $0x8,%esp
f0103e6c:	ff 73 3c             	pushl  0x3c(%ebx)
f0103e6f:	68 9d 75 10 f0       	push   $0xf010759d
f0103e74:	e8 f2 f9 ff ff       	call   f010386b <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103e79:	83 c4 08             	add    $0x8,%esp
f0103e7c:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103e80:	50                   	push   %eax
f0103e81:	68 ac 75 10 f0       	push   $0xf01075ac
f0103e86:	e8 e0 f9 ff ff       	call   f010386b <cprintf>
f0103e8b:	83 c4 10             	add    $0x10,%esp
	}
}
f0103e8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103e91:	5b                   	pop    %ebx
f0103e92:	5e                   	pop    %esi
f0103e93:	5d                   	pop    %ebp
f0103e94:	c3                   	ret    

f0103e95 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103e95:	55                   	push   %ebp
f0103e96:	89 e5                	mov    %esp,%ebp
f0103e98:	57                   	push   %edi
f0103e99:	56                   	push   %esi
f0103e9a:	53                   	push   %ebx
f0103e9b:	83 ec 18             	sub    $0x18,%esp
f0103e9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103ea1:	0f 20 d6             	mov    %cr2,%esi

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	print_trapframe(tf);
f0103ea4:	53                   	push   %ebx
f0103ea5:	e8 63 fe ff ff       	call   f0103d0d <print_trapframe>
	if ((tf->tf_cs&3) == 0)
f0103eaa:	83 c4 10             	add    $0x10,%esp
f0103ead:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103eb1:	75 17                	jne    f0103eca <page_fault_handler+0x35>
		panic("a page fault happens in kernel [eip:%x]", tf->tf_eip);
f0103eb3:	ff 73 30             	pushl  0x30(%ebx)
f0103eb6:	68 64 77 10 f0       	push   $0xf0107764
f0103ebb:	68 e2 01 00 00       	push   $0x1e2
f0103ec0:	68 bf 75 10 f0       	push   $0xf01075bf
f0103ec5:	e8 ca c1 ff ff       	call   f0100094 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
f0103eca:	83 ec 0c             	sub    $0xc,%esp
f0103ecd:	53                   	push   %ebx
f0103ece:	e8 3a fe ff ff       	call   f0103d0d <print_trapframe>
	env_destroy(curenv);
f0103ed3:	e8 2a 1a 00 00       	call   f0105902 <cpunum>
f0103ed8:	83 c4 04             	add    $0x4,%esp
f0103edb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ede:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103ee4:	e8 c5 f6 ff ff       	call   f01035ae <env_destroy>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ee9:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103eec:	e8 11 1a 00 00       	call   f0105902 <cpunum>
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ef1:	57                   	push   %edi
f0103ef2:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ef3:	6b c0 74             	imul   $0x74,%eax,%eax
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	print_trapframe(tf);
	env_destroy(curenv);
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ef6:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103efc:	ff 70 48             	pushl  0x48(%eax)
f0103eff:	68 8c 77 10 f0       	push   $0xf010778c
f0103f04:	e8 62 f9 ff ff       	call   f010386b <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103f09:	83 c4 14             	add    $0x14,%esp
f0103f0c:	53                   	push   %ebx
f0103f0d:	e8 fb fd ff ff       	call   f0103d0d <print_trapframe>
	env_destroy(curenv);
f0103f12:	e8 eb 19 00 00       	call   f0105902 <cpunum>
f0103f17:	83 c4 04             	add    $0x4,%esp
f0103f1a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f1d:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0103f23:	e8 86 f6 ff ff       	call   f01035ae <env_destroy>
}
f0103f28:	83 c4 10             	add    $0x10,%esp
f0103f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f2e:	5b                   	pop    %ebx
f0103f2f:	5e                   	pop    %esi
f0103f30:	5f                   	pop    %edi
f0103f31:	5d                   	pop    %ebp
f0103f32:	c3                   	ret    

f0103f33 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103f33:	55                   	push   %ebp
f0103f34:	89 e5                	mov    %esp,%ebp
f0103f36:	57                   	push   %edi
f0103f37:	56                   	push   %esi
f0103f38:	8b 75 08             	mov    0x8(%ebp),%esi

	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103f3b:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103f3c:	83 3d 80 be 22 f0 00 	cmpl   $0x0,0xf022be80
f0103f43:	74 01                	je     f0103f46 <trap+0x13>
		asm volatile("hlt");
f0103f45:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103f46:	e8 b7 19 00 00       	call   f0105902 <cpunum>
f0103f4b:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f4e:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0103f54:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f59:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103f5d:	83 f8 02             	cmp    $0x2,%eax
f0103f60:	75 10                	jne    f0103f72 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103f62:	83 ec 0c             	sub    $0xc,%esp
f0103f65:	68 c0 03 12 f0       	push   $0xf01203c0
f0103f6a:	e8 01 1c 00 00       	call   f0105b70 <spin_lock>
f0103f6f:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103f72:	9c                   	pushf  
f0103f73:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103f74:	f6 c4 02             	test   $0x2,%ah
f0103f77:	74 19                	je     f0103f92 <trap+0x5f>
f0103f79:	68 cb 75 10 f0       	push   $0xf01075cb
f0103f7e:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0103f83:	68 a8 01 00 00       	push   $0x1a8
f0103f88:	68 bf 75 10 f0       	push   $0xf01075bf
f0103f8d:	e8 02 c1 ff ff       	call   f0100094 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103f92:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103f96:	83 e0 03             	and    $0x3,%eax
f0103f99:	66 83 f8 03          	cmp    $0x3,%ax
f0103f9d:	0f 85 a0 00 00 00    	jne    f0104043 <trap+0x110>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0103fa3:	e8 5a 19 00 00       	call   f0105902 <cpunum>
f0103fa8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fab:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0103fb2:	75 19                	jne    f0103fcd <trap+0x9a>
f0103fb4:	68 e4 75 10 f0       	push   $0xf01075e4
f0103fb9:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0103fbe:	68 af 01 00 00       	push   $0x1af
f0103fc3:	68 bf 75 10 f0       	push   $0xf01075bf
f0103fc8:	e8 c7 c0 ff ff       	call   f0100094 <_panic>
f0103fcd:	83 ec 0c             	sub    $0xc,%esp
f0103fd0:	68 c0 03 12 f0       	push   $0xf01203c0
f0103fd5:	e8 96 1b 00 00       	call   f0105b70 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103fda:	e8 23 19 00 00       	call   f0105902 <cpunum>
f0103fdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe2:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0103fe8:	83 c4 10             	add    $0x10,%esp
f0103feb:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103fef:	75 2d                	jne    f010401e <trap+0xeb>
			env_free(curenv);
f0103ff1:	e8 0c 19 00 00       	call   f0105902 <cpunum>
f0103ff6:	83 ec 0c             	sub    $0xc,%esp
f0103ff9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ffc:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104002:	e8 cc f3 ff ff       	call   f01033d3 <env_free>
			curenv = NULL;
f0104007:	e8 f6 18 00 00       	call   f0105902 <cpunum>
f010400c:	6b c0 74             	imul   $0x74,%eax,%eax
f010400f:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104016:	00 00 00 
			sched_yield();
f0104019:	e8 6a 02 00 00       	call   f0104288 <sched_yield>
		}
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010401e:	e8 df 18 00 00       	call   f0105902 <cpunum>
f0104023:	6b c0 74             	imul   $0x74,%eax,%eax
f0104026:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010402c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104031:	89 c7                	mov    %eax,%edi
f0104033:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104035:	e8 c8 18 00 00       	call   f0105902 <cpunum>
f010403a:	6b c0 74             	imul   $0x74,%eax,%eax
f010403d:	8b b0 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104043:	89 35 60 ba 22 f0    	mov    %esi,0xf022ba60


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104049:	8b 46 28             	mov    0x28(%esi),%eax
f010404c:	83 f8 27             	cmp    $0x27,%eax
f010404f:	75 1d                	jne    f010406e <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0104051:	83 ec 0c             	sub    $0xc,%esp
f0104054:	68 eb 75 10 f0       	push   $0xf01075eb
f0104059:	e8 0d f8 ff ff       	call   f010386b <cprintf>
		print_trapframe(tf);
f010405e:	89 34 24             	mov    %esi,(%esp)
f0104061:	e8 a7 fc ff ff       	call   f0103d0d <print_trapframe>
f0104066:	83 c4 10             	add    $0x10,%esp
f0104069:	e9 91 00 00 00       	jmp    f01040ff <trap+0x1cc>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	switch(tf->tf_trapno){
f010406e:	83 f8 0e             	cmp    $0xe,%eax
f0104071:	74 0c                	je     f010407f <trap+0x14c>
f0104073:	83 f8 30             	cmp    $0x30,%eax
f0104076:	74 23                	je     f010409b <trap+0x168>
f0104078:	83 f8 03             	cmp    $0x3,%eax
f010407b:	75 3f                	jne    f01040bc <trap+0x189>
f010407d:	eb 0e                	jmp    f010408d <trap+0x15a>
		case T_PGFLT:
			page_fault_handler(tf);
f010407f:	83 ec 0c             	sub    $0xc,%esp
f0104082:	56                   	push   %esi
f0104083:	e8 0d fe ff ff       	call   f0103e95 <page_fault_handler>
f0104088:	83 c4 10             	add    $0x10,%esp
f010408b:	eb 72                	jmp    f01040ff <trap+0x1cc>
			return;
		case T_BRKPT:
			//cprintf("Function:trap_dispatch()->T_BRKPT.\n");
			monitor(tf);
f010408d:	83 ec 0c             	sub    $0xc,%esp
f0104090:	56                   	push   %esi
f0104091:	e8 bd c8 ff ff       	call   f0100953 <monitor>
f0104096:	83 c4 10             	add    $0x10,%esp
f0104099:	eb 64                	jmp    f01040ff <trap+0x1cc>
			return;
		case T_SYSCALL:
			//cprintf("Function:trap_dispatch()->T_SYSCALL.\n");
			tf->tf_regs.reg_eax = syscall(
f010409b:	83 ec 08             	sub    $0x8,%esp
f010409e:	ff 76 04             	pushl  0x4(%esi)
f01040a1:	ff 36                	pushl  (%esi)
f01040a3:	ff 76 10             	pushl  0x10(%esi)
f01040a6:	ff 76 18             	pushl  0x18(%esi)
f01040a9:	ff 76 14             	pushl  0x14(%esi)
f01040ac:	ff 76 1c             	pushl  0x1c(%esi)
f01040af:	e8 db 02 00 00       	call   f010438f <syscall>
f01040b4:	89 46 1c             	mov    %eax,0x1c(%esi)
f01040b7:	83 c4 20             	add    $0x20,%esp
f01040ba:	eb 43                	jmp    f01040ff <trap+0x1cc>
       				 tf->tf_regs.reg_esi
   			 );
  			  return;
		default:break;
	}
	print_trapframe(tf);
f01040bc:	83 ec 0c             	sub    $0xc,%esp
f01040bf:	56                   	push   %esi
f01040c0:	e8 48 fc ff ff       	call   f0103d0d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01040c5:	83 c4 10             	add    $0x10,%esp
f01040c8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01040cd:	75 17                	jne    f01040e6 <trap+0x1b3>
		panic("unhandled trap in kernel");
f01040cf:	83 ec 04             	sub    $0x4,%esp
f01040d2:	68 08 76 10 f0       	push   $0xf0107608
f01040d7:	68 8d 01 00 00       	push   $0x18d
f01040dc:	68 bf 75 10 f0       	push   $0xf01075bf
f01040e1:	e8 ae bf ff ff       	call   f0100094 <_panic>
	else {
		env_destroy(curenv);
f01040e6:	e8 17 18 00 00       	call   f0105902 <cpunum>
f01040eb:	83 ec 0c             	sub    $0xc,%esp
f01040ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01040f1:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01040f7:	e8 b2 f4 ff ff       	call   f01035ae <env_destroy>
f01040fc:	83 c4 10             	add    $0x10,%esp


	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01040ff:	e8 fe 17 00 00       	call   f0105902 <cpunum>
f0104104:	6b c0 74             	imul   $0x74,%eax,%eax
f0104107:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f010410e:	74 2a                	je     f010413a <trap+0x207>
f0104110:	e8 ed 17 00 00       	call   f0105902 <cpunum>
f0104115:	6b c0 74             	imul   $0x74,%eax,%eax
f0104118:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010411e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104122:	75 16                	jne    f010413a <trap+0x207>
		env_run(curenv);
f0104124:	e8 d9 17 00 00       	call   f0105902 <cpunum>
f0104129:	83 ec 0c             	sub    $0xc,%esp
f010412c:	6b c0 74             	imul   $0x74,%eax,%eax
f010412f:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104135:	e8 13 f5 ff ff       	call   f010364d <env_run>
	else
		sched_yield();
f010413a:	e8 49 01 00 00       	call   f0104288 <sched_yield>
f010413f:	90                   	nop

f0104140 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
f0104140:	6a 00                	push   $0x0
f0104142:	6a 00                	push   $0x0
f0104144:	eb 5e                	jmp    f01041a4 <_alltraps>

f0104146 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG);        // 1
f0104146:	6a 00                	push   $0x0
f0104148:	6a 01                	push   $0x1
f010414a:	eb 58                	jmp    f01041a4 <_alltraps>

f010414c <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI);            // 2
f010414c:	6a 00                	push   $0x0
f010414e:	6a 02                	push   $0x2
f0104150:	eb 52                	jmp    f01041a4 <_alltraps>

f0104152 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)        // 3
f0104152:	6a 00                	push   $0x0
f0104154:	6a 03                	push   $0x3
f0104156:	eb 4c                	jmp    f01041a4 <_alltraps>

f0104158 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)        // 4
f0104158:	6a 00                	push   $0x0
f010415a:	6a 04                	push   $0x4
f010415c:	eb 46                	jmp    f01041a4 <_alltraps>

f010415e <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)        // 5
f010415e:	6a 00                	push   $0x0
f0104160:	6a 05                	push   $0x5
f0104162:	eb 40                	jmp    f01041a4 <_alltraps>

f0104164 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)        // 6
f0104164:	6a 00                	push   $0x0
f0104166:	6a 06                	push   $0x6
f0104168:	eb 3a                	jmp    f01041a4 <_alltraps>

f010416a <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)    // 7
f010416a:	6a 00                	push   $0x0
f010416c:	6a 07                	push   $0x7
f010416e:	eb 34                	jmp    f01041a4 <_alltraps>

f0104170 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)            // 8
f0104170:	6a 08                	push   $0x8
f0104172:	eb 30                	jmp    f01041a4 <_alltraps>

f0104174 <t_tss>:
                                        // 9
TRAPHANDLER(t_tss, T_TSS)                // 10
f0104174:	6a 0a                	push   $0xa
f0104176:	eb 2c                	jmp    f01041a4 <_alltraps>

f0104178 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)            // 11
f0104178:	6a 0b                	push   $0xb
f010417a:	eb 28                	jmp    f01041a4 <_alltraps>

f010417c <t_stack>:
TRAPHANDLER(t_stack, T_STACK)            // 12
f010417c:	6a 0c                	push   $0xc
f010417e:	eb 24                	jmp    f01041a4 <_alltraps>

f0104180 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)            // 13
f0104180:	6a 0d                	push   $0xd
f0104182:	eb 20                	jmp    f01041a4 <_alltraps>

f0104184 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)            // 14
f0104184:	6a 0e                	push   $0xe
f0104186:	eb 1c                	jmp    f01041a4 <_alltraps>

f0104188 <t_fperr>:
                                        // 15
TRAPHANDLER_NOEC(t_fperr, T_FPERR)        // 16
f0104188:	6a 00                	push   $0x0
f010418a:	6a 10                	push   $0x10
f010418c:	eb 16                	jmp    f01041a4 <_alltraps>

f010418e <t_align>:
TRAPHANDLER(t_align, T_ALIGN)            // 17
f010418e:	6a 11                	push   $0x11
f0104190:	eb 12                	jmp    f01041a4 <_alltraps>

f0104192 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)        // 18
f0104192:	6a 00                	push   $0x0
f0104194:	6a 12                	push   $0x12
f0104196:	eb 0c                	jmp    f01041a4 <_alltraps>

f0104198 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)    // 19
f0104198:	6a 00                	push   $0x0
f010419a:	6a 13                	push   $0x13
f010419c:	eb 06                	jmp    f01041a4 <_alltraps>

f010419e <t_syscall>:

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f010419e:	6a 00                	push   $0x0
f01041a0:	6a 30                	push   $0x30
f01041a2:	eb 00                	jmp    f01041a4 <_alltraps>

f01041a4 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01041a4:	1e                   	push   %ds
	pushl %es
f01041a5:	06                   	push   %es
	pushal
f01041a6:	60                   	pusha  

	movw $GD_KD,%eax
f01041a7:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax,%ds
f01041ab:	8e d8                	mov    %eax,%ds
	movw %ax,%es
f01041ad:	8e c0                	mov    %eax,%es

	pushl %esp
f01041af:	54                   	push   %esp
	call trap
f01041b0:	e8 7e fd ff ff       	call   f0103f33 <trap>

f01041b5 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01041b5:	55                   	push   %ebp
f01041b6:	89 e5                	mov    %esp,%ebp
f01041b8:	83 ec 08             	sub    $0x8,%esp
f01041bb:	a1 44 b2 22 f0       	mov    0xf022b244,%eax
f01041c0:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041c3:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01041c8:	8b 02                	mov    (%edx),%eax
f01041ca:	83 e8 01             	sub    $0x1,%eax
f01041cd:	83 f8 02             	cmp    $0x2,%eax
f01041d0:	76 10                	jbe    f01041e2 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01041d2:	83 c1 01             	add    $0x1,%ecx
f01041d5:	83 c2 7c             	add    $0x7c,%edx
f01041d8:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041de:	75 e8                	jne    f01041c8 <sched_halt+0x13>
f01041e0:	eb 08                	jmp    f01041ea <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01041e2:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01041e8:	75 1f                	jne    f0104209 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01041ea:	83 ec 0c             	sub    $0xc,%esp
f01041ed:	68 10 78 10 f0       	push   $0xf0107810
f01041f2:	e8 74 f6 ff ff       	call   f010386b <cprintf>
f01041f7:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01041fa:	83 ec 0c             	sub    $0xc,%esp
f01041fd:	6a 00                	push   $0x0
f01041ff:	e8 4f c7 ff ff       	call   f0100953 <monitor>
f0104204:	83 c4 10             	add    $0x10,%esp
f0104207:	eb f1                	jmp    f01041fa <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104209:	e8 f4 16 00 00       	call   f0105902 <cpunum>
f010420e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104211:	c7 80 28 c0 22 f0 00 	movl   $0x0,-0xfdd3fd8(%eax)
f0104218:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010421b:	a1 8c be 22 f0       	mov    0xf022be8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104220:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104225:	77 12                	ja     f0104239 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104227:	50                   	push   %eax
f0104228:	68 78 60 10 f0       	push   $0xf0106078
f010422d:	6a 69                	push   $0x69
f010422f:	68 39 78 10 f0       	push   $0xf0107839
f0104234:	e8 5b be ff ff       	call   f0100094 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104239:	05 00 00 00 10       	add    $0x10000000,%eax
f010423e:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104241:	e8 bc 16 00 00       	call   f0105902 <cpunum>
f0104246:	6b d0 74             	imul   $0x74,%eax,%edx
f0104249:	81 c2 20 c0 22 f0    	add    $0xf022c020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010424f:	b8 02 00 00 00       	mov    $0x2,%eax
f0104254:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104258:	83 ec 0c             	sub    $0xc,%esp
f010425b:	68 c0 03 12 f0       	push   $0xf01203c0
f0104260:	e8 a8 19 00 00       	call   f0105c0d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104265:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104267:	e8 96 16 00 00       	call   f0105902 <cpunum>
f010426c:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010426f:	8b 80 30 c0 22 f0    	mov    -0xfdd3fd0(%eax),%eax
f0104275:	bd 00 00 00 00       	mov    $0x0,%ebp
f010427a:	89 c4                	mov    %eax,%esp
f010427c:	6a 00                	push   $0x0
f010427e:	6a 00                	push   $0x0
f0104280:	f4                   	hlt    
f0104281:	eb fd                	jmp    f0104280 <sched_halt+0xcb>
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104283:	83 c4 10             	add    $0x10,%esp
f0104286:	c9                   	leave  
f0104287:	c3                   	ret    

f0104288 <sched_yield>:
};
*/
// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104288:	55                   	push   %ebp
f0104289:	89 e5                	mov    %esp,%ebp
f010428b:	57                   	push   %edi
f010428c:	56                   	push   %esi
f010428d:	53                   	push   %ebx
f010428e:	83 ec 18             	sub    $0x18,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
f0104291:	68 46 78 10 f0       	push   $0xf0107846
f0104296:	e8 d0 f5 ff ff       	call   f010386b <cprintf>
	int running_env_id = -1;
	if(curenv == 0){
f010429b:	e8 62 16 00 00       	call   f0105902 <cpunum>
f01042a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a3:	83 c4 10             	add    $0x10,%esp
		running_env_id = -1;
f01042a6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx

	// LAB 4: Your code here.
	//	e = &envs[ENVX(envid)];
	cprintf("!kern/sched_yield().\n");
	int running_env_id = -1;
	if(curenv == 0){
f01042ab:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01042b2:	74 17                	je     f01042cb <sched_yield+0x43>
		running_env_id = -1;
	}else{
		running_env_id = ENVX(curenv->env_id);
f01042b4:	e8 49 16 00 00       	call   f0105902 <cpunum>
f01042b9:	6b c0 74             	imul   $0x74,%eax,%eax
f01042bc:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01042c2:	8b 58 48             	mov    0x48(%eax),%ebx
f01042c5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	}
	cprintf("The running_env_id is:%d\n",running_env_id);
f01042cb:	83 ec 08             	sub    $0x8,%esp
f01042ce:	53                   	push   %ebx
f01042cf:	68 5c 78 10 f0       	push   $0xf010785c
f01042d4:	e8 92 f5 ff ff       	call   f010386b <cprintf>

		if(running_env_id == NENV-1)running_env_id = 0;
		else{
			running_env_id++;
		}
		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f01042d9:	8b 0d 44 b2 22 f0    	mov    0xf022b244,%ecx
f01042df:	83 c4 10             	add    $0x10,%esp
		running_env_id = -1;
	}else{
		running_env_id = ENVX(curenv->env_id);
	}
	cprintf("The running_env_id is:%d\n",running_env_id);
	for(int i = 0;i<NENV;i++){
f01042e2:	be 00 00 00 00       	mov    $0x0,%esi

		if(running_env_id == NENV-1)running_env_id = 0;
		else{
			running_env_id++;
f01042e7:	ba 00 00 00 00       	mov    $0x0,%edx
f01042ec:	8d 43 01             	lea    0x1(%ebx),%eax
f01042ef:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
f01042f5:	0f 44 c2             	cmove  %edx,%eax
f01042f8:	89 c3                	mov    %eax,%ebx
		}
		if(envs[running_env_id].env_status == ENV_RUNNABLE){
f01042fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01042fd:	89 c7                	mov    %eax,%edi
f01042ff:	83 7c 01 54 02       	cmpl   $0x2,0x54(%ecx,%eax,1)
f0104304:	75 29                	jne    f010432f <sched_yield+0xa7>
			;;;
			cprintf("shed_yield():WE ARE RUNNING.\n");
f0104306:	83 ec 0c             	sub    $0xc,%esp
f0104309:	68 76 78 10 f0       	push   $0xf0107876
f010430e:	e8 58 f5 ff ff       	call   f010386b <cprintf>
			cprintf("the running i is:%d\n",i);
f0104313:	83 c4 08             	add    $0x8,%esp
f0104316:	56                   	push   %esi
f0104317:	68 94 78 10 f0       	push   $0xf0107894
f010431c:	e8 4a f5 ff ff       	call   f010386b <cprintf>
			env_run(&envs[running_env_id]);			
f0104321:	03 3d 44 b2 22 f0    	add    0xf022b244,%edi
f0104327:	89 3c 24             	mov    %edi,(%esp)
f010432a:	e8 1e f3 ff ff       	call   f010364d <env_run>
		running_env_id = -1;
	}else{
		running_env_id = ENVX(curenv->env_id);
	}
	cprintf("The running_env_id is:%d\n",running_env_id);
	for(int i = 0;i<NENV;i++){
f010432f:	83 c6 01             	add    $0x1,%esi
f0104332:	81 fe 00 04 00 00    	cmp    $0x400,%esi
f0104338:	75 b2                	jne    f01042ec <sched_yield+0x64>
	}
	//if the code run here,it says that there is only one env which is
	//running but now and here we are in kern mode,so if we don't chose
	//the running env to run we will trap in sched_halt().AND WE ARE AT
	//KERNEL MODE!
	if(curenv && curenv->env_status == ENV_RUNNING){
f010433a:	e8 c3 15 00 00       	call   f0105902 <cpunum>
f010433f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104342:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104349:	74 37                	je     f0104382 <sched_yield+0xfa>
f010434b:	e8 b2 15 00 00       	call   f0105902 <cpunum>
f0104350:	6b c0 74             	imul   $0x74,%eax,%eax
f0104353:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104359:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010435d:	75 23                	jne    f0104382 <sched_yield+0xfa>
		cprintf("I AM THE ONLY ONE ENV.\n");
f010435f:	83 ec 0c             	sub    $0xc,%esp
f0104362:	68 a9 78 10 f0       	push   $0xf01078a9
f0104367:	e8 ff f4 ff ff       	call   f010386b <cprintf>
		env_run(curenv);
f010436c:	e8 91 15 00 00       	call   f0105902 <cpunum>
f0104371:	83 c4 04             	add    $0x4,%esp
f0104374:	6b c0 74             	imul   $0x74,%eax,%eax
f0104377:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f010437d:	e8 cb f2 ff ff       	call   f010364d <env_run>
		return;
	}
	// sched_halt never returns
	sched_halt();
f0104382:	e8 2e fe ff ff       	call   f01041b5 <sched_halt>
}
f0104387:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010438a:	5b                   	pop    %ebx
f010438b:	5e                   	pop    %esi
f010438c:	5f                   	pop    %edi
f010438d:	5d                   	pop    %ebp
f010438e:	c3                   	ret    

f010438f <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010438f:	55                   	push   %ebp
f0104390:	89 e5                	mov    %esp,%ebp
f0104392:	53                   	push   %ebx
f0104393:	83 ec 14             	sub    $0x14,%esp
f0104396:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
f0104399:	83 f8 0a             	cmp    $0xa,%eax
f010439c:	0f 87 96 04 00 00    	ja     f0104838 <syscall+0x4a9>
f01043a2:	ff 24 85 84 79 10 f0 	jmp    *-0xfef867c(,%eax,4)
	// LAB 3: Your code here.


	struct Env *e;
	//envid2env(sys_getenvid(), &e, 1);
	user_mem_assert(curenv, s, len, PTE_U);
f01043a9:	e8 54 15 00 00       	call   f0105902 <cpunum>
f01043ae:	6a 04                	push   $0x4
f01043b0:	ff 75 10             	pushl  0x10(%ebp)
f01043b3:	ff 75 0c             	pushl  0xc(%ebp)
f01043b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01043b9:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f01043bf:	e8 d1 ea ff ff       	call   f0102e95 <user_mem_assert>

	cprintf("%.*s", len, s);
f01043c4:	83 c4 0c             	add    $0xc,%esp
f01043c7:	ff 75 0c             	pushl  0xc(%ebp)
f01043ca:	ff 75 10             	pushl  0x10(%ebp)
f01043cd:	68 c1 78 10 f0       	push   $0xf01078c1
f01043d2:	e8 94 f4 ff ff       	call   f010386b <cprintf>
f01043d7:	83 c4 10             	add    $0x10,%esp
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01043da:	e8 72 c2 ff ff       	call   f0100651 <cons_getc>
//cprintf("KERN/SYSCALL:%x ,%x,%x,%x,%x",a1,a2,a3,a4,a5);
	switch (syscallno) {
       	       case SYS_cputs:
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
f01043df:	e9 59 04 00 00       	jmp    f010483d <syscall+0x4ae>
       	       case SYS_getenvid:
           		 assert(curenv);
f01043e4:	e8 19 15 00 00       	call   f0105902 <cpunum>
f01043e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01043ec:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01043f3:	75 19                	jne    f010440e <syscall+0x7f>
f01043f5:	68 e4 75 10 f0       	push   $0xf01075e4
f01043fa:	68 c7 6f 10 f0       	push   $0xf0106fc7
f01043ff:	68 7d 01 00 00       	push   $0x17d
f0104404:	68 c6 78 10 f0       	push   $0xf01078c6
f0104409:	e8 86 bc ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010440e:	e8 ef 14 00 00       	call   f0105902 <cpunum>
f0104413:	6b c0 74             	imul   $0x74,%eax,%eax
f0104416:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010441c:	8b 40 48             	mov    0x48(%eax),%eax
           		 sys_cputs((char*)a1, (size_t)a2);
       	       case SYS_cgetc:
            		return sys_cgetc();
       	       case SYS_getenvid:
           		 assert(curenv);
            		return sys_getenvid();
f010441f:	e9 19 04 00 00       	jmp    f010483d <syscall+0x4ae>
       	       case SYS_env_destroy:
          		  assert(curenv);
f0104424:	e8 d9 14 00 00       	call   f0105902 <cpunum>
f0104429:	6b c0 74             	imul   $0x74,%eax,%eax
f010442c:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f0104433:	75 19                	jne    f010444e <syscall+0xbf>
f0104435:	68 e4 75 10 f0       	push   $0xf01075e4
f010443a:	68 c7 6f 10 f0       	push   $0xf0106fc7
f010443f:	68 80 01 00 00       	push   $0x180
f0104444:	68 c6 78 10 f0       	push   $0xf01078c6
f0104449:	e8 46 bc ff ff       	call   f0100094 <_panic>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010444e:	e8 af 14 00 00       	call   f0105902 <cpunum>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104453:	83 ec 04             	sub    $0x4,%esp
f0104456:	6a 01                	push   $0x1
f0104458:	8d 55 f4             	lea    -0xc(%ebp),%edx
f010445b:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010445c:	6b c0 74             	imul   $0x74,%eax,%eax
f010445f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104465:	ff 70 48             	pushl  0x48(%eax)
f0104468:	e8 04 eb ff ff       	call   f0102f71 <envid2env>
f010446d:	83 c4 10             	add    $0x10,%esp
f0104470:	85 c0                	test   %eax,%eax
f0104472:	0f 88 c5 03 00 00    	js     f010483d <syscall+0x4ae>
		return r;
	if (e == curenv)
f0104478:	e8 85 14 00 00       	call   f0105902 <cpunum>
f010447d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104480:	6b c0 74             	imul   $0x74,%eax,%eax
f0104483:	39 90 28 c0 22 f0    	cmp    %edx,-0xfdd3fd8(%eax)
f0104489:	75 23                	jne    f01044ae <syscall+0x11f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010448b:	e8 72 14 00 00       	call   f0105902 <cpunum>
f0104490:	83 ec 08             	sub    $0x8,%esp
f0104493:	6b c0 74             	imul   $0x74,%eax,%eax
f0104496:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f010449c:	ff 70 48             	pushl  0x48(%eax)
f010449f:	68 d5 78 10 f0       	push   $0xf01078d5
f01044a4:	e8 c2 f3 ff ff       	call   f010386b <cprintf>
f01044a9:	83 c4 10             	add    $0x10,%esp
f01044ac:	eb 25                	jmp    f01044d3 <syscall+0x144>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01044ae:	8b 5a 48             	mov    0x48(%edx),%ebx
f01044b1:	e8 4c 14 00 00       	call   f0105902 <cpunum>
f01044b6:	83 ec 04             	sub    $0x4,%esp
f01044b9:	53                   	push   %ebx
f01044ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01044bd:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01044c3:	ff 70 48             	pushl  0x48(%eax)
f01044c6:	68 f0 78 10 f0       	push   $0xf01078f0
f01044cb:	e8 9b f3 ff ff       	call   f010386b <cprintf>
f01044d0:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01044d3:	83 ec 0c             	sub    $0xc,%esp
f01044d6:	ff 75 f4             	pushl  -0xc(%ebp)
f01044d9:	e8 d0 f0 ff ff       	call   f01035ae <env_destroy>
f01044de:	83 c4 10             	add    $0x10,%esp
	return 0;
f01044e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01044e6:	e9 52 03 00 00       	jmp    f010483d <syscall+0x4ae>
            		return sys_getenvid();
       	       case SYS_env_destroy:
          		  assert(curenv);
            		return sys_env_destroy(sys_getenvid());
	       case SYS_yield:
			assert(curenv);
f01044eb:	e8 12 14 00 00       	call   f0105902 <cpunum>
f01044f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f3:	83 b8 28 c0 22 f0 00 	cmpl   $0x0,-0xfdd3fd8(%eax)
f01044fa:	75 19                	jne    f0104515 <syscall+0x186>
f01044fc:	68 e4 75 10 f0       	push   $0xf01075e4
f0104501:	68 c7 6f 10 f0       	push   $0xf0106fc7
f0104506:	68 83 01 00 00       	push   $0x183
f010450b:	68 c6 78 10 f0       	push   $0xf01078c6
f0104510:	e8 7f bb ff ff       	call   f0100094 <_panic>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104515:	e8 6e fd ff ff       	call   f0104288 <sched_yield>
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.
	cprintf("!we at sys_exofork().\n");
f010451a:	83 ec 0c             	sub    $0xc,%esp
f010451d:	68 08 79 10 f0       	push   $0xf0107908
f0104522:	e8 44 f3 ff ff       	call   f010386b <cprintf>
	// LAB 4: Your code here.
	struct Env * newenv_store;
	if(curenv->env_id == 0)
f0104527:	e8 d6 13 00 00       	call   f0105902 <cpunum>
f010452c:	6b c0 74             	imul   $0x74,%eax,%eax
f010452f:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104535:	8b 40 48             	mov    0x48(%eax),%eax
f0104538:	83 c4 10             	add    $0x10,%esp
f010453b:	85 c0                	test   %eax,%eax
f010453d:	0f 84 fa 02 00 00    	je     f010483d <syscall+0x4ae>
		return 0;
	int r_env_alloc = env_alloc(&newenv_store,curenv->env_id);
f0104543:	e8 ba 13 00 00       	call   f0105902 <cpunum>
f0104548:	83 ec 08             	sub    $0x8,%esp
f010454b:	6b c0 74             	imul   $0x74,%eax,%eax
f010454e:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f0104554:	ff 70 48             	pushl  0x48(%eax)
f0104557:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010455a:	50                   	push   %eax
f010455b:	e8 99 eb ff ff       	call   f01030f9 <env_alloc>
	
	if(r_env_alloc<0)
f0104560:	83 c4 10             	add    $0x10,%esp
f0104563:	85 c0                	test   %eax,%eax
f0104565:	0f 88 d2 02 00 00    	js     f010483d <syscall+0x4ae>
		return r_env_alloc;
	
	newenv_store->env_status = ENV_NOT_RUNNABLE;
f010456b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010456e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove(&newenv_store->env_tf,&curenv->env_tf,sizeof(curenv->env_tf));
f0104575:	e8 88 13 00 00       	call   f0105902 <cpunum>
f010457a:	83 ec 04             	sub    $0x4,%esp
f010457d:	6a 44                	push   $0x44
f010457f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104582:	ff b0 28 c0 22 f0    	pushl  -0xfdd3fd8(%eax)
f0104588:	ff 75 f4             	pushl  -0xc(%ebp)
f010458b:	e8 9e 0d 00 00       	call   f010532e <memmove>
	newenv_store->env_tf.tf_regs.reg_eax =100;
f0104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104593:	c7 40 1c 64 00 00 00 	movl   $0x64,0x1c(%eax)
	cprintf("curenv->env_id:%d\n",curenv->env_id);
f010459a:	e8 63 13 00 00       	call   f0105902 <cpunum>
f010459f:	83 c4 08             	add    $0x8,%esp
f01045a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a5:	8b 80 28 c0 22 f0    	mov    -0xfdd3fd8(%eax),%eax
f01045ab:	ff 70 48             	pushl  0x48(%eax)
f01045ae:	68 1f 79 10 f0       	push   $0xf010791f
f01045b3:	e8 b3 f2 ff ff       	call   f010386b <cprintf>
	cprintf("newenv_store->env_id:%d\n",newenv_store->env_id);
f01045b8:	83 c4 08             	add    $0x8,%esp
f01045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045be:	ff 70 48             	pushl  0x48(%eax)
f01045c1:	68 32 79 10 f0       	push   $0xf0107932
f01045c6:	e8 a0 f2 ff ff       	call   f010386b <cprintf>
	cprintf("GOING TO RETURN TO SYSTEM CALL.\n");
f01045cb:	c7 04 24 60 79 10 f0 	movl   $0xf0107960,(%esp)
f01045d2:	e8 94 f2 ff ff       	call   f010386b <cprintf>
	return newenv_store->env_id;
f01045d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01045da:	8b 40 48             	mov    0x48(%eax),%eax
f01045dd:	83 c4 10             	add    $0x10,%esp
f01045e0:	e9 58 02 00 00       	jmp    f010483d <syscall+0x4ae>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01045e5:	83 ec 04             	sub    $0x4,%esp
f01045e8:	6a 01                	push   $0x1
f01045ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01045ed:	50                   	push   %eax
f01045ee:	ff 75 0c             	pushl  0xc(%ebp)
f01045f1:	e8 7b e9 ff ff       	call   f0102f71 <envid2env>
	if(r_value)
f01045f6:	83 c4 10             	add    $0x10,%esp
f01045f9:	85 c0                	test   %eax,%eax
f01045fb:	0f 85 3c 02 00 00    	jne    f010483d <syscall+0x4ae>
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0104601:	8b 45 10             	mov    0x10(%ebp),%eax
f0104604:	83 e8 02             	sub    $0x2,%eax
f0104607:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010460c:	75 13                	jne    f0104621 <syscall+0x292>
		return -E_INVAL;
	newenv_store->env_status = status;
f010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104611:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104614:	89 58 54             	mov    %ebx,0x54(%eax)

	return 0;
f0104617:	b8 00 00 00 00       	mov    $0x0,%eax
f010461c:	e9 1c 02 00 00       	jmp    f010483d <syscall+0x4ae>
	struct Env * newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	if(!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f0104621:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			sys_yield();
			return 1;
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
f0104626:	e9 12 02 00 00       	jmp    f010483d <syscall+0x4ae>
	//   allocated!

	// LAB 4: Your code here.
//	cprintf("the kernel env index is:%d\n",ENVX(curenv->env_id));
	struct Env *newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f010462b:	83 ec 04             	sub    $0x4,%esp
f010462e:	6a 01                	push   $0x1
f0104630:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104633:	50                   	push   %eax
f0104634:	ff 75 0c             	pushl  0xc(%ebp)
f0104637:	e8 35 e9 ff ff       	call   f0102f71 <envid2env>
	if(r_value)
f010463c:	83 c4 10             	add    $0x10,%esp
f010463f:	85 c0                	test   %eax,%eax
f0104641:	0f 85 f6 01 00 00    	jne    f010483d <syscall+0x4ae>
		return r_value;
	cprintf("after envid2env().\n");
f0104647:	83 ec 0c             	sub    $0xc,%esp
f010464a:	68 4b 79 10 f0       	push   $0xf010794b
f010464f:	e8 17 f2 ff ff       	call   f010386b <cprintf>
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
f0104654:	83 c4 10             	add    $0x10,%esp
f0104657:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010465e:	77 56                	ja     f01046b6 <syscall+0x327>
f0104660:	8b 45 10             	mov    0x10(%ebp),%eax
f0104663:	c1 e0 14             	shl    $0x14,%eax
f0104666:	85 c0                	test   %eax,%eax
f0104668:	75 56                	jne    f01046c0 <syscall+0x331>
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f010466a:	8b 55 14             	mov    0x14(%ebp),%edx
f010466d:	83 e2 fd             	and    $0xfffffffd,%edx
f0104670:	83 fa 05             	cmp    $0x5,%edx
f0104673:	74 11                	je     f0104686 <syscall+0x2f7>
		return -E_INVAL;
f0104675:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	
	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f010467a:	81 fa 05 0e 00 00    	cmp    $0xe05,%edx
f0104680:	0f 85 b7 01 00 00    	jne    f010483d <syscall+0x4ae>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
f0104686:	83 ec 0c             	sub    $0xc,%esp
f0104689:	6a 00                	push   $0x0
f010468b:	e8 e1 c8 ff ff       	call   f0100f71 <page_alloc>
	if(!pp)
f0104690:	83 c4 10             	add    $0x10,%esp
f0104693:	85 c0                	test   %eax,%eax
f0104695:	74 33                	je     f01046ca <syscall+0x33b>
		return -E_NO_MEM;

	int ret = page_insert(newenv_store->env_pgdir,pp,va,perm);	
f0104697:	ff 75 14             	pushl  0x14(%ebp)
f010469a:	ff 75 10             	pushl  0x10(%ebp)
f010469d:	50                   	push   %eax
f010469e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01046a1:	ff 70 60             	pushl  0x60(%eax)
f01046a4:	e8 b7 cc ff ff       	call   f0101360 <page_insert>
f01046a9:	83 c4 10             	add    $0x10,%esp
	if(!ret)
		return ret;
	return 0;
f01046ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01046b1:	e9 87 01 00 00       	jmp    f010483d <syscall+0x4ae>
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value)
		return r_value;
	cprintf("after envid2env().\n");
	if(va>=(void*)UTOP || ((unsigned int)va<<20))
		return -E_INVAL;
f01046b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046bb:	e9 7d 01 00 00       	jmp    f010483d <syscall+0x4ae>
f01046c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01046c5:	e9 73 01 00 00       	jmp    f010483d <syscall+0x4ae>
		return -E_INVAL;

	struct PageInfo*pp;
	pp = page_alloc(0);
	if(!pp)
		return -E_NO_MEM;
f01046ca:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status((envid_t)a1,(int)a2);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f01046cf:	e9 69 01 00 00       	jmp    f010483d <syscall+0x4ae>
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
f01046d4:	83 ec 04             	sub    $0x4,%esp
f01046d7:	6a 01                	push   $0x1
f01046d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01046dc:	50                   	push   %eax
f01046dd:	ff 75 0c             	pushl  0xc(%ebp)
f01046e0:	e8 8c e8 ff ff       	call   f0102f71 <envid2env>
f01046e5:	89 c3                	mov    %eax,%ebx
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
f01046e7:	83 c4 0c             	add    $0xc,%esp
f01046ea:	6a 01                	push   $0x1
f01046ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01046ef:	50                   	push   %eax
f01046f0:	ff 75 14             	pushl  0x14(%ebp)
f01046f3:	e8 79 e8 ff ff       	call   f0102f71 <envid2env>
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
f01046f8:	83 c4 10             	add    $0x10,%esp
f01046fb:	83 fb fe             	cmp    $0xfffffffe,%ebx
f01046fe:	0f 84 ab 00 00 00    	je     f01047af <syscall+0x420>
f0104704:	83 f8 fe             	cmp    $0xfffffffe,%eax
f0104707:	0f 84 a2 00 00 00    	je     f01047af <syscall+0x420>
		return -E_BAD_ENV;
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
f010470d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104714:	0f 87 9f 00 00 00    	ja     f01047b9 <syscall+0x42a>
f010471a:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104721:	0f 87 92 00 00 00    	ja     f01047b9 <syscall+0x42a>
		return -E_INVAL;

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
f0104727:	8b 45 10             	mov    0x10(%ebp),%eax
f010472a:	c1 e0 14             	shl    $0x14,%eax
f010472d:	85 c0                	test   %eax,%eax
f010472f:	0f 85 8b 00 00 00    	jne    f01047c0 <syscall+0x431>
f0104735:	8b 45 18             	mov    0x18(%ebp),%eax
f0104738:	c1 e0 14             	shl    $0x14,%eax
f010473b:	85 c0                	test   %eax,%eax
f010473d:	0f 85 84 00 00 00    	jne    f01047c7 <syscall+0x438>
		return -E_INVAL;

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
f0104743:	83 ec 04             	sub    $0x4,%esp
f0104746:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104749:	50                   	push   %eax
f010474a:	ff 75 10             	pushl  0x10(%ebp)
f010474d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104750:	ff 70 60             	pushl  0x60(%eax)
f0104753:	e8 28 cb ff ff       	call   f0101280 <page_lookup>
f0104758:	89 c2                	mov    %eax,%edx
	if(!pp)
f010475a:	83 c4 10             	add    $0x10,%esp
f010475d:	85 c0                	test   %eax,%eax
f010475f:	74 6d                	je     f01047ce <syscall+0x43f>

	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104761:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104764:	83 e1 fd             	and    $0xfffffffd,%ecx
f0104767:	83 f9 05             	cmp    $0x5,%ecx
f010476a:	74 11                	je     f010477d <syscall+0x3ee>
		return -E_INVAL;
f010476c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	int check_perm1 = PTE_U|PTE_P;
	int check_perm2 = PTE_U|PTE_P|PTE_AVAIL;
	int check_perm3 = PTE_U|PTE_P|PTE_W;
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
f0104771:	81 f9 05 0e 00 00    	cmp    $0xe05,%ecx
f0104777:	0f 85 c0 00 00 00    	jne    f010483d <syscall+0x4ae>
		return -E_INVAL;

	if(perm&PTE_W && !((*pte_store)&PTE_W))
f010477d:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104781:	74 08                	je     f010478b <syscall+0x3fc>
f0104783:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104786:	f6 00 02             	testb  $0x2,(%eax)
f0104789:	74 4a                	je     f01047d5 <syscall+0x446>
		return -E_INVAL;


	if(page_insert(newenv_store_dst->env_pgdir,pp,dstva,perm))
f010478b:	ff 75 1c             	pushl  0x1c(%ebp)
f010478e:	ff 75 18             	pushl  0x18(%ebp)
f0104791:	52                   	push   %edx
f0104792:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104795:	ff 70 60             	pushl  0x60(%eax)
f0104798:	e8 c3 cb ff ff       	call   f0101360 <page_insert>
f010479d:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f01047a0:	85 c0                	test   %eax,%eax
f01047a2:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f01047a7:	0f 45 c2             	cmovne %edx,%eax
f01047aa:	e9 8e 00 00 00       	jmp    f010483d <syscall+0x4ae>
	struct Env* newenv_store_src;
	struct Env* newenv_store_dst;
	int r_value_src = envid2env(srcenvid,&newenv_store_src,1);
	int r_value_dst = envid2env(dstenvid,&newenv_store_dst,1);
	if(r_value_src == -E_BAD_ENV || r_value_dst == -E_BAD_ENV)
		return -E_BAD_ENV;
f01047af:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01047b4:	e9 84 00 00 00       	jmp    f010483d <syscall+0x4ae>
	
	if(srcva>=(void*)UTOP || dstva>=(void*)UTOP)
		return -E_INVAL;
f01047b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047be:	eb 7d                	jmp    f010483d <syscall+0x4ae>

	if(((unsigned int)srcva<<20)||((unsigned int)dstva<<20))
		return -E_INVAL;
f01047c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047c5:	eb 76                	jmp    f010483d <syscall+0x4ae>
f01047c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047cc:	eb 6f                	jmp    f010483d <syscall+0x4ae>

	pte_t * pte_store;
	struct PageInfo* pp;	
 	pp = page_lookup(newenv_store_src->env_pgdir,srcva,&pte_store);
	if(!pp)
		return -E_INVAL;
f01047ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047d3:	eb 68                	jmp    f010483d <syscall+0x4ae>
	int check_perm4 = PTE_U|PTE_P|PTE_AVAIL|PTE_W;
	if(!(perm == check_perm1 || perm == check_perm2 || perm == check_perm3 || perm == check_perm4))
		return -E_INVAL;

	if(perm&PTE_W && !((*pte_store)&PTE_W))
		return -E_INVAL;
f01047d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01047da:	eb 61                	jmp    f010483d <syscall+0x4ae>
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
f01047dc:	83 ec 04             	sub    $0x4,%esp
f01047df:	6a 01                	push   $0x1
f01047e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01047e4:	50                   	push   %eax
f01047e5:	ff 75 0c             	pushl  0xc(%ebp)
f01047e8:	e8 84 e7 ff ff       	call   f0102f71 <envid2env>
	if(r_value == -E_BAD_ENV)
f01047ed:	83 c4 10             	add    $0x10,%esp
f01047f0:	83 f8 fe             	cmp    $0xfffffffe,%eax
f01047f3:	74 2e                	je     f0104823 <syscall+0x494>
		return -E_BAD_ENV;
	
	if(va>=(void*)UTOP)
f01047f5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047fc:	77 2c                	ja     f010482a <syscall+0x49b>
		return -E_INVAL;

	if(((unsigned int)va<<20))
f01047fe:	8b 45 10             	mov    0x10(%ebp),%eax
f0104801:	c1 e0 14             	shl    $0x14,%eax
f0104804:	85 c0                	test   %eax,%eax
f0104806:	75 29                	jne    f0104831 <syscall+0x4a2>
		return -E_INVAL;

	page_remove(newenv_store->env_pgdir,va);
f0104808:	83 ec 08             	sub    $0x8,%esp
f010480b:	ff 75 10             	pushl  0x10(%ebp)
f010480e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104811:	ff 70 60             	pushl  0x60(%eax)
f0104814:	e8 01 cb ff ff       	call   f010131a <page_remove>
f0104819:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f010481c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104821:	eb 1a                	jmp    f010483d <syscall+0x4ae>
{
	// Hint: This function is a wrapper around page_remove().
	struct Env* newenv_store;
	int r_value = envid2env(envid,&newenv_store,1);
	if(r_value == -E_BAD_ENV)
		return -E_BAD_ENV;
f0104823:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0104828:	eb 13                	jmp    f010483d <syscall+0x4ae>
	
	if(va>=(void*)UTOP)
		return -E_INVAL;
f010482a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010482f:	eb 0c                	jmp    f010483d <syscall+0x4ae>

	if(((unsigned int)va<<20))
		return -E_INVAL;
f0104831:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,(int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((envid_t)a1,(void*)a2);
f0104836:	eb 05                	jmp    f010483d <syscall+0x4ae>
		default:
			return -E_INVAL;
f0104838:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f010483d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104840:	c9                   	leave  
f0104841:	c3                   	ret    

f0104842 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104842:	55                   	push   %ebp
f0104843:	89 e5                	mov    %esp,%ebp
f0104845:	57                   	push   %edi
f0104846:	56                   	push   %esi
f0104847:	53                   	push   %ebx
f0104848:	83 ec 14             	sub    $0x14,%esp
f010484b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010484e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104851:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104854:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104857:	8b 1a                	mov    (%edx),%ebx
f0104859:	8b 01                	mov    (%ecx),%eax
f010485b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010485e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104865:	eb 7f                	jmp    f01048e6 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104867:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010486a:	01 d8                	add    %ebx,%eax
f010486c:	89 c6                	mov    %eax,%esi
f010486e:	c1 ee 1f             	shr    $0x1f,%esi
f0104871:	01 c6                	add    %eax,%esi
f0104873:	d1 fe                	sar    %esi
f0104875:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104878:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010487b:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010487e:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104880:	eb 03                	jmp    f0104885 <stab_binsearch+0x43>
			m--;
f0104882:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104885:	39 c3                	cmp    %eax,%ebx
f0104887:	7f 0d                	jg     f0104896 <stab_binsearch+0x54>
f0104889:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010488d:	83 ea 0c             	sub    $0xc,%edx
f0104890:	39 f9                	cmp    %edi,%ecx
f0104892:	75 ee                	jne    f0104882 <stab_binsearch+0x40>
f0104894:	eb 05                	jmp    f010489b <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104896:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104899:	eb 4b                	jmp    f01048e6 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010489b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010489e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01048a1:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01048a5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01048a8:	76 11                	jbe    f01048bb <stab_binsearch+0x79>
			*region_left = m;
f01048aa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01048ad:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01048af:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01048b2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01048b9:	eb 2b                	jmp    f01048e6 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01048bb:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01048be:	73 14                	jae    f01048d4 <stab_binsearch+0x92>
			*region_right = m - 1;
f01048c0:	83 e8 01             	sub    $0x1,%eax
f01048c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01048c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048c9:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01048cb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01048d2:	eb 12                	jmp    f01048e6 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01048d4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01048d7:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01048d9:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01048dd:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01048df:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01048e6:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01048e9:	0f 8e 78 ff ff ff    	jle    f0104867 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01048ef:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01048f3:	75 0f                	jne    f0104904 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01048f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048f8:	8b 00                	mov    (%eax),%eax
f01048fa:	83 e8 01             	sub    $0x1,%eax
f01048fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104900:	89 06                	mov    %eax,(%esi)
f0104902:	eb 2c                	jmp    f0104930 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104904:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104907:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104909:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010490c:	8b 0e                	mov    (%esi),%ecx
f010490e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104911:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104914:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104917:	eb 03                	jmp    f010491c <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104919:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010491c:	39 c8                	cmp    %ecx,%eax
f010491e:	7e 0b                	jle    f010492b <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104920:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104924:	83 ea 0c             	sub    $0xc,%edx
f0104927:	39 df                	cmp    %ebx,%edi
f0104929:	75 ee                	jne    f0104919 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f010492b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010492e:	89 06                	mov    %eax,(%esi)
	}
}
f0104930:	83 c4 14             	add    $0x14,%esp
f0104933:	5b                   	pop    %ebx
f0104934:	5e                   	pop    %esi
f0104935:	5f                   	pop    %edi
f0104936:	5d                   	pop    %ebp
f0104937:	c3                   	ret    

f0104938 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104938:	55                   	push   %ebp
f0104939:	89 e5                	mov    %esp,%ebp
f010493b:	57                   	push   %edi
f010493c:	56                   	push   %esi
f010493d:	53                   	push   %ebx
f010493e:	83 ec 2c             	sub    $0x2c,%esp
f0104941:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104944:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104947:	c7 06 b0 79 10 f0    	movl   $0xf01079b0,(%esi)
	info->eip_line = 0;
f010494d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104954:	c7 46 08 b0 79 10 f0 	movl   $0xf01079b0,0x8(%esi)
	info->eip_fn_namelen = 9;
f010495b:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104962:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0104965:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010496c:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104972:	77 21                	ja     f0104995 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104974:	a1 00 00 20 00       	mov    0x200000,%eax
f0104979:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f010497c:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104981:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0104987:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010498a:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0104990:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104993:	eb 1a                	jmp    f01049af <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104995:	c7 45 d0 48 56 11 f0 	movl   $0xf0115648,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010499c:	c7 45 cc cd 1e 11 f0 	movl   $0xf0111ecd,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01049a3:	b8 cc 1e 11 f0       	mov    $0xf0111ecc,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01049a8:	c7 45 d4 94 7e 10 f0 	movl   $0xf0107e94,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01049af:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01049b2:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f01049b5:	0f 83 2b 01 00 00    	jae    f0104ae6 <debuginfo_eip+0x1ae>
f01049bb:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01049bf:	0f 85 28 01 00 00    	jne    f0104aed <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01049c5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01049cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01049cf:	29 d8                	sub    %ebx,%eax
f01049d1:	c1 f8 02             	sar    $0x2,%eax
f01049d4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01049da:	83 e8 01             	sub    $0x1,%eax
f01049dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01049e0:	57                   	push   %edi
f01049e1:	6a 64                	push   $0x64
f01049e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01049e6:	89 c1                	mov    %eax,%ecx
f01049e8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049eb:	89 d8                	mov    %ebx,%eax
f01049ed:	e8 50 fe ff ff       	call   f0104842 <stab_binsearch>
	if (lfile == 0)
f01049f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049f5:	83 c4 08             	add    $0x8,%esp
f01049f8:	85 c0                	test   %eax,%eax
f01049fa:	0f 84 f4 00 00 00    	je     f0104af4 <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104a00:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104a03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a06:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104a09:	57                   	push   %edi
f0104a0a:	6a 24                	push   $0x24
f0104a0c:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104a0f:	89 c1                	mov    %eax,%ecx
f0104a11:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104a14:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104a17:	89 d8                	mov    %ebx,%eax
f0104a19:	e8 24 fe ff ff       	call   f0104842 <stab_binsearch>

	if (lfun <= rfun) {
f0104a1e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104a21:	83 c4 08             	add    $0x8,%esp
f0104a24:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104a27:	7f 24                	jg     f0104a4d <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104a29:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a2c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104a2f:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104a32:	8b 02                	mov    (%edx),%eax
f0104a34:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104a37:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104a3a:	29 f9                	sub    %edi,%ecx
f0104a3c:	39 c8                	cmp    %ecx,%eax
f0104a3e:	73 05                	jae    f0104a45 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104a40:	01 f8                	add    %edi,%eax
f0104a42:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104a45:	8b 42 08             	mov    0x8(%edx),%eax
f0104a48:	89 46 10             	mov    %eax,0x10(%esi)
f0104a4b:	eb 06                	jmp    f0104a53 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104a4d:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104a50:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104a53:	83 ec 08             	sub    $0x8,%esp
f0104a56:	6a 3a                	push   $0x3a
f0104a58:	ff 76 08             	pushl  0x8(%esi)
f0104a5b:	e8 65 08 00 00       	call   f01052c5 <strfind>
f0104a60:	2b 46 08             	sub    0x8(%esi),%eax
f0104a63:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a69:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a6c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104a6f:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104a72:	83 c4 10             	add    $0x10,%esp
f0104a75:	eb 06                	jmp    f0104a7d <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104a77:	83 eb 01             	sub    $0x1,%ebx
f0104a7a:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a7d:	39 fb                	cmp    %edi,%ebx
f0104a7f:	7c 2d                	jl     f0104aae <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0104a81:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104a85:	80 fa 84             	cmp    $0x84,%dl
f0104a88:	74 0b                	je     f0104a95 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104a8a:	80 fa 64             	cmp    $0x64,%dl
f0104a8d:	75 e8                	jne    f0104a77 <debuginfo_eip+0x13f>
f0104a8f:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0104a93:	74 e2                	je     f0104a77 <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104a95:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104a98:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104a9b:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104a9e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104aa1:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104aa4:	29 f8                	sub    %edi,%eax
f0104aa6:	39 c2                	cmp    %eax,%edx
f0104aa8:	73 04                	jae    f0104aae <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104aaa:	01 fa                	add    %edi,%edx
f0104aac:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104aae:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104ab1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104ab4:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ab9:	39 cb                	cmp    %ecx,%ebx
f0104abb:	7d 43                	jge    f0104b00 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104abd:	8d 53 01             	lea    0x1(%ebx),%edx
f0104ac0:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ac3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ac6:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104ac9:	eb 07                	jmp    f0104ad2 <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104acb:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104acf:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104ad2:	39 ca                	cmp    %ecx,%edx
f0104ad4:	74 25                	je     f0104afb <debuginfo_eip+0x1c3>
f0104ad6:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104ad9:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104add:	74 ec                	je     f0104acb <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104adf:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ae4:	eb 1a                	jmp    f0104b00 <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104ae6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104aeb:	eb 13                	jmp    f0104b00 <debuginfo_eip+0x1c8>
f0104aed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104af2:	eb 0c                	jmp    f0104b00 <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104af4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104af9:	eb 05                	jmp    f0104b00 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104b00:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b03:	5b                   	pop    %ebx
f0104b04:	5e                   	pop    %esi
f0104b05:	5f                   	pop    %edi
f0104b06:	5d                   	pop    %ebp
f0104b07:	c3                   	ret    

f0104b08 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104b08:	55                   	push   %ebp
f0104b09:	89 e5                	mov    %esp,%ebp
f0104b0b:	57                   	push   %edi
f0104b0c:	56                   	push   %esi
f0104b0d:	53                   	push   %ebx
f0104b0e:	83 ec 1c             	sub    $0x1c,%esp
f0104b11:	89 c7                	mov    %eax,%edi
f0104b13:	89 d6                	mov    %edx,%esi
f0104b15:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b18:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104b1e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104b21:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b24:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b29:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104b2c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104b2f:	39 d3                	cmp    %edx,%ebx
f0104b31:	72 05                	jb     f0104b38 <printnum+0x30>
f0104b33:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104b36:	77 45                	ja     f0104b7d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104b38:	83 ec 0c             	sub    $0xc,%esp
f0104b3b:	ff 75 18             	pushl  0x18(%ebp)
f0104b3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b41:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104b44:	53                   	push   %ebx
f0104b45:	ff 75 10             	pushl  0x10(%ebp)
f0104b48:	83 ec 08             	sub    $0x8,%esp
f0104b4b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b4e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b51:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b54:	ff 75 d8             	pushl  -0x28(%ebp)
f0104b57:	e8 a4 11 00 00       	call   f0105d00 <__udivdi3>
f0104b5c:	83 c4 18             	add    $0x18,%esp
f0104b5f:	52                   	push   %edx
f0104b60:	50                   	push   %eax
f0104b61:	89 f2                	mov    %esi,%edx
f0104b63:	89 f8                	mov    %edi,%eax
f0104b65:	e8 9e ff ff ff       	call   f0104b08 <printnum>
f0104b6a:	83 c4 20             	add    $0x20,%esp
f0104b6d:	eb 18                	jmp    f0104b87 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104b6f:	83 ec 08             	sub    $0x8,%esp
f0104b72:	56                   	push   %esi
f0104b73:	ff 75 18             	pushl  0x18(%ebp)
f0104b76:	ff d7                	call   *%edi
f0104b78:	83 c4 10             	add    $0x10,%esp
f0104b7b:	eb 03                	jmp    f0104b80 <printnum+0x78>
f0104b7d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104b80:	83 eb 01             	sub    $0x1,%ebx
f0104b83:	85 db                	test   %ebx,%ebx
f0104b85:	7f e8                	jg     f0104b6f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104b87:	83 ec 08             	sub    $0x8,%esp
f0104b8a:	56                   	push   %esi
f0104b8b:	83 ec 04             	sub    $0x4,%esp
f0104b8e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b91:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b94:	ff 75 dc             	pushl  -0x24(%ebp)
f0104b97:	ff 75 d8             	pushl  -0x28(%ebp)
f0104b9a:	e8 91 12 00 00       	call   f0105e30 <__umoddi3>
f0104b9f:	83 c4 14             	add    $0x14,%esp
f0104ba2:	0f be 80 ba 79 10 f0 	movsbl -0xfef8646(%eax),%eax
f0104ba9:	50                   	push   %eax
f0104baa:	ff d7                	call   *%edi
}
f0104bac:	83 c4 10             	add    $0x10,%esp
f0104baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104bb2:	5b                   	pop    %ebx
f0104bb3:	5e                   	pop    %esi
f0104bb4:	5f                   	pop    %edi
f0104bb5:	5d                   	pop    %ebp
f0104bb6:	c3                   	ret    

f0104bb7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104bb7:	55                   	push   %ebp
f0104bb8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104bba:	83 fa 01             	cmp    $0x1,%edx
f0104bbd:	7e 0e                	jle    f0104bcd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104bbf:	8b 10                	mov    (%eax),%edx
f0104bc1:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104bc4:	89 08                	mov    %ecx,(%eax)
f0104bc6:	8b 02                	mov    (%edx),%eax
f0104bc8:	8b 52 04             	mov    0x4(%edx),%edx
f0104bcb:	eb 22                	jmp    f0104bef <getuint+0x38>
	else if (lflag)
f0104bcd:	85 d2                	test   %edx,%edx
f0104bcf:	74 10                	je     f0104be1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104bd1:	8b 10                	mov    (%eax),%edx
f0104bd3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104bd6:	89 08                	mov    %ecx,(%eax)
f0104bd8:	8b 02                	mov    (%edx),%eax
f0104bda:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bdf:	eb 0e                	jmp    f0104bef <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104be1:	8b 10                	mov    (%eax),%edx
f0104be3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104be6:	89 08                	mov    %ecx,(%eax)
f0104be8:	8b 02                	mov    (%edx),%eax
f0104bea:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104bef:	5d                   	pop    %ebp
f0104bf0:	c3                   	ret    

f0104bf1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104bf1:	55                   	push   %ebp
f0104bf2:	89 e5                	mov    %esp,%ebp
f0104bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104bf7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104bfb:	8b 10                	mov    (%eax),%edx
f0104bfd:	3b 50 04             	cmp    0x4(%eax),%edx
f0104c00:	73 0a                	jae    f0104c0c <sprintputch+0x1b>
		*b->buf++ = ch;
f0104c02:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104c05:	89 08                	mov    %ecx,(%eax)
f0104c07:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c0a:	88 02                	mov    %al,(%edx)
}
f0104c0c:	5d                   	pop    %ebp
f0104c0d:	c3                   	ret    

f0104c0e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104c0e:	55                   	push   %ebp
f0104c0f:	89 e5                	mov    %esp,%ebp
f0104c11:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104c14:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104c17:	50                   	push   %eax
f0104c18:	ff 75 10             	pushl  0x10(%ebp)
f0104c1b:	ff 75 0c             	pushl  0xc(%ebp)
f0104c1e:	ff 75 08             	pushl  0x8(%ebp)
f0104c21:	e8 05 00 00 00       	call   f0104c2b <vprintfmt>
	va_end(ap);
}
f0104c26:	83 c4 10             	add    $0x10,%esp
f0104c29:	c9                   	leave  
f0104c2a:	c3                   	ret    

f0104c2b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104c2b:	55                   	push   %ebp
f0104c2c:	89 e5                	mov    %esp,%ebp
f0104c2e:	57                   	push   %edi
f0104c2f:	56                   	push   %esi
f0104c30:	53                   	push   %ebx
f0104c31:	83 ec 2c             	sub    $0x2c,%esp
f0104c34:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c3a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104c3d:	eb 12                	jmp    f0104c51 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104c3f:	85 c0                	test   %eax,%eax
f0104c41:	0f 84 d3 03 00 00    	je     f010501a <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
f0104c47:	83 ec 08             	sub    $0x8,%esp
f0104c4a:	53                   	push   %ebx
f0104c4b:	50                   	push   %eax
f0104c4c:	ff d6                	call   *%esi
f0104c4e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104c51:	83 c7 01             	add    $0x1,%edi
f0104c54:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c58:	83 f8 25             	cmp    $0x25,%eax
f0104c5b:	75 e2                	jne    f0104c3f <vprintfmt+0x14>
f0104c5d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104c61:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104c68:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104c6f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104c76:	ba 00 00 00 00       	mov    $0x0,%edx
f0104c7b:	eb 07                	jmp    f0104c84 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104c80:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104c84:	8d 47 01             	lea    0x1(%edi),%eax
f0104c87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c8a:	0f b6 07             	movzbl (%edi),%eax
f0104c8d:	0f b6 c8             	movzbl %al,%ecx
f0104c90:	83 e8 23             	sub    $0x23,%eax
f0104c93:	3c 55                	cmp    $0x55,%al
f0104c95:	0f 87 64 03 00 00    	ja     f0104fff <vprintfmt+0x3d4>
f0104c9b:	0f b6 c0             	movzbl %al,%eax
f0104c9e:	ff 24 85 80 7a 10 f0 	jmp    *-0xfef8580(,%eax,4)
f0104ca5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104ca8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104cac:	eb d6                	jmp    f0104c84 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cb1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cb6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104cb9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104cbc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104cc0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104cc3:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104cc6:	83 fa 09             	cmp    $0x9,%edx
f0104cc9:	77 39                	ja     f0104d04 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104ccb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104cce:	eb e9                	jmp    f0104cb9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104cd0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cd3:	8d 48 04             	lea    0x4(%eax),%ecx
f0104cd6:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104cd9:	8b 00                	mov    (%eax),%eax
f0104cdb:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104ce1:	eb 27                	jmp    f0104d0a <vprintfmt+0xdf>
f0104ce3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ce6:	85 c0                	test   %eax,%eax
f0104ce8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ced:	0f 49 c8             	cmovns %eax,%ecx
f0104cf0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cf3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cf6:	eb 8c                	jmp    f0104c84 <vprintfmt+0x59>
f0104cf8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104cfb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104d02:	eb 80                	jmp    f0104c84 <vprintfmt+0x59>
f0104d04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d07:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f0104d0a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104d0e:	0f 89 70 ff ff ff    	jns    f0104c84 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104d14:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104d17:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d1a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104d21:	e9 5e ff ff ff       	jmp    f0104c84 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104d26:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d29:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104d2c:	e9 53 ff ff ff       	jmp    f0104c84 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104d31:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d34:	8d 50 04             	lea    0x4(%eax),%edx
f0104d37:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d3a:	83 ec 08             	sub    $0x8,%esp
f0104d3d:	53                   	push   %ebx
f0104d3e:	ff 30                	pushl  (%eax)
f0104d40:	ff d6                	call   *%esi
			break;
f0104d42:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104d48:	e9 04 ff ff ff       	jmp    f0104c51 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104d4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d50:	8d 50 04             	lea    0x4(%eax),%edx
f0104d53:	89 55 14             	mov    %edx,0x14(%ebp)
f0104d56:	8b 00                	mov    (%eax),%eax
f0104d58:	99                   	cltd   
f0104d59:	31 d0                	xor    %edx,%eax
f0104d5b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104d5d:	83 f8 08             	cmp    $0x8,%eax
f0104d60:	7f 0b                	jg     f0104d6d <vprintfmt+0x142>
f0104d62:	8b 14 85 e0 7b 10 f0 	mov    -0xfef8420(,%eax,4),%edx
f0104d69:	85 d2                	test   %edx,%edx
f0104d6b:	75 18                	jne    f0104d85 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104d6d:	50                   	push   %eax
f0104d6e:	68 d2 79 10 f0       	push   $0xf01079d2
f0104d73:	53                   	push   %ebx
f0104d74:	56                   	push   %esi
f0104d75:	e8 94 fe ff ff       	call   f0104c0e <printfmt>
f0104d7a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d7d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104d80:	e9 cc fe ff ff       	jmp    f0104c51 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104d85:	52                   	push   %edx
f0104d86:	68 d9 6f 10 f0       	push   $0xf0106fd9
f0104d8b:	53                   	push   %ebx
f0104d8c:	56                   	push   %esi
f0104d8d:	e8 7c fe ff ff       	call   f0104c0e <printfmt>
f0104d92:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d98:	e9 b4 fe ff ff       	jmp    f0104c51 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104d9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104da0:	8d 50 04             	lea    0x4(%eax),%edx
f0104da3:	89 55 14             	mov    %edx,0x14(%ebp)
f0104da6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104da8:	85 ff                	test   %edi,%edi
f0104daa:	b8 cb 79 10 f0       	mov    $0xf01079cb,%eax
f0104daf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104db2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104db6:	0f 8e 94 00 00 00    	jle    f0104e50 <vprintfmt+0x225>
f0104dbc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104dc0:	0f 84 98 00 00 00    	je     f0104e5e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104dc6:	83 ec 08             	sub    $0x8,%esp
f0104dc9:	ff 75 c8             	pushl  -0x38(%ebp)
f0104dcc:	57                   	push   %edi
f0104dcd:	e8 a9 03 00 00       	call   f010517b <strnlen>
f0104dd2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104dd5:	29 c1                	sub    %eax,%ecx
f0104dd7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104dda:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104ddd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104de1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104de4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104de7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104de9:	eb 0f                	jmp    f0104dfa <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104deb:	83 ec 08             	sub    $0x8,%esp
f0104dee:	53                   	push   %ebx
f0104def:	ff 75 e0             	pushl  -0x20(%ebp)
f0104df2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104df4:	83 ef 01             	sub    $0x1,%edi
f0104df7:	83 c4 10             	add    $0x10,%esp
f0104dfa:	85 ff                	test   %edi,%edi
f0104dfc:	7f ed                	jg     f0104deb <vprintfmt+0x1c0>
f0104dfe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104e01:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e04:	85 c9                	test   %ecx,%ecx
f0104e06:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e0b:	0f 49 c1             	cmovns %ecx,%eax
f0104e0e:	29 c1                	sub    %eax,%ecx
f0104e10:	89 75 08             	mov    %esi,0x8(%ebp)
f0104e13:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104e16:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e19:	89 cb                	mov    %ecx,%ebx
f0104e1b:	eb 4d                	jmp    f0104e6a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104e1d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104e21:	74 1b                	je     f0104e3e <vprintfmt+0x213>
f0104e23:	0f be c0             	movsbl %al,%eax
f0104e26:	83 e8 20             	sub    $0x20,%eax
f0104e29:	83 f8 5e             	cmp    $0x5e,%eax
f0104e2c:	76 10                	jbe    f0104e3e <vprintfmt+0x213>
					putch('?', putdat);
f0104e2e:	83 ec 08             	sub    $0x8,%esp
f0104e31:	ff 75 0c             	pushl  0xc(%ebp)
f0104e34:	6a 3f                	push   $0x3f
f0104e36:	ff 55 08             	call   *0x8(%ebp)
f0104e39:	83 c4 10             	add    $0x10,%esp
f0104e3c:	eb 0d                	jmp    f0104e4b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0104e3e:	83 ec 08             	sub    $0x8,%esp
f0104e41:	ff 75 0c             	pushl  0xc(%ebp)
f0104e44:	52                   	push   %edx
f0104e45:	ff 55 08             	call   *0x8(%ebp)
f0104e48:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104e4b:	83 eb 01             	sub    $0x1,%ebx
f0104e4e:	eb 1a                	jmp    f0104e6a <vprintfmt+0x23f>
f0104e50:	89 75 08             	mov    %esi,0x8(%ebp)
f0104e53:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104e56:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e59:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e5c:	eb 0c                	jmp    f0104e6a <vprintfmt+0x23f>
f0104e5e:	89 75 08             	mov    %esi,0x8(%ebp)
f0104e61:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104e64:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104e67:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104e6a:	83 c7 01             	add    $0x1,%edi
f0104e6d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104e71:	0f be d0             	movsbl %al,%edx
f0104e74:	85 d2                	test   %edx,%edx
f0104e76:	74 23                	je     f0104e9b <vprintfmt+0x270>
f0104e78:	85 f6                	test   %esi,%esi
f0104e7a:	78 a1                	js     f0104e1d <vprintfmt+0x1f2>
f0104e7c:	83 ee 01             	sub    $0x1,%esi
f0104e7f:	79 9c                	jns    f0104e1d <vprintfmt+0x1f2>
f0104e81:	89 df                	mov    %ebx,%edi
f0104e83:	8b 75 08             	mov    0x8(%ebp),%esi
f0104e86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104e89:	eb 18                	jmp    f0104ea3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104e8b:	83 ec 08             	sub    $0x8,%esp
f0104e8e:	53                   	push   %ebx
f0104e8f:	6a 20                	push   $0x20
f0104e91:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104e93:	83 ef 01             	sub    $0x1,%edi
f0104e96:	83 c4 10             	add    $0x10,%esp
f0104e99:	eb 08                	jmp    f0104ea3 <vprintfmt+0x278>
f0104e9b:	89 df                	mov    %ebx,%edi
f0104e9d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ea0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ea3:	85 ff                	test   %edi,%edi
f0104ea5:	7f e4                	jg     f0104e8b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ea7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104eaa:	e9 a2 fd ff ff       	jmp    f0104c51 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104eaf:	83 fa 01             	cmp    $0x1,%edx
f0104eb2:	7e 16                	jle    f0104eca <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0104eb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104eb7:	8d 50 08             	lea    0x8(%eax),%edx
f0104eba:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ebd:	8b 50 04             	mov    0x4(%eax),%edx
f0104ec0:	8b 00                	mov    (%eax),%eax
f0104ec2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104ec5:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104ec8:	eb 32                	jmp    f0104efc <vprintfmt+0x2d1>
	else if (lflag)
f0104eca:	85 d2                	test   %edx,%edx
f0104ecc:	74 18                	je     f0104ee6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104ece:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ed1:	8d 50 04             	lea    0x4(%eax),%edx
f0104ed4:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ed7:	8b 00                	mov    (%eax),%eax
f0104ed9:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104edc:	89 c1                	mov    %eax,%ecx
f0104ede:	c1 f9 1f             	sar    $0x1f,%ecx
f0104ee1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104ee4:	eb 16                	jmp    f0104efc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104ee6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ee9:	8d 50 04             	lea    0x4(%eax),%edx
f0104eec:	89 55 14             	mov    %edx,0x14(%ebp)
f0104eef:	8b 00                	mov    (%eax),%eax
f0104ef1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104ef4:	89 c1                	mov    %eax,%ecx
f0104ef6:	c1 f9 1f             	sar    $0x1f,%ecx
f0104ef9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104efc:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104eff:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104f02:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f05:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104f08:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104f0d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104f11:	0f 89 b0 00 00 00    	jns    f0104fc7 <vprintfmt+0x39c>
				putch('-', putdat);
f0104f17:	83 ec 08             	sub    $0x8,%esp
f0104f1a:	53                   	push   %ebx
f0104f1b:	6a 2d                	push   $0x2d
f0104f1d:	ff d6                	call   *%esi
				num = -(long long) num;
f0104f1f:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0104f22:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0104f25:	f7 d8                	neg    %eax
f0104f27:	83 d2 00             	adc    $0x0,%edx
f0104f2a:	f7 da                	neg    %edx
f0104f2c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f2f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104f32:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104f35:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104f3a:	e9 88 00 00 00       	jmp    f0104fc7 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104f3f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f42:	e8 70 fc ff ff       	call   f0104bb7 <getuint>
f0104f47:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f4a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0104f4d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104f52:	eb 73                	jmp    f0104fc7 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
f0104f54:	8d 45 14             	lea    0x14(%ebp),%eax
f0104f57:	e8 5b fc ff ff       	call   f0104bb7 <getuint>
f0104f5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f5f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
f0104f62:	83 ec 08             	sub    $0x8,%esp
f0104f65:	53                   	push   %ebx
f0104f66:	6a 58                	push   $0x58
f0104f68:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f6a:	83 c4 08             	add    $0x8,%esp
f0104f6d:	53                   	push   %ebx
f0104f6e:	6a 58                	push   $0x58
f0104f70:	ff d6                	call   *%esi
			putch('X', putdat);
f0104f72:	83 c4 08             	add    $0x8,%esp
f0104f75:	53                   	push   %ebx
f0104f76:	6a 58                	push   $0x58
f0104f78:	ff d6                	call   *%esi
			goto number;
f0104f7a:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
f0104f7d:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
f0104f82:	eb 43                	jmp    f0104fc7 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0104f84:	83 ec 08             	sub    $0x8,%esp
f0104f87:	53                   	push   %ebx
f0104f88:	6a 30                	push   $0x30
f0104f8a:	ff d6                	call   *%esi
			putch('x', putdat);
f0104f8c:	83 c4 08             	add    $0x8,%esp
f0104f8f:	53                   	push   %ebx
f0104f90:	6a 78                	push   $0x78
f0104f92:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104f94:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f97:	8d 50 04             	lea    0x4(%eax),%edx
f0104f9a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104f9d:	8b 00                	mov    (%eax),%eax
f0104f9f:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fa4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fa7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104faa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104fad:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104fb2:	eb 13                	jmp    f0104fc7 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104fb4:	8d 45 14             	lea    0x14(%ebp),%eax
f0104fb7:	e8 fb fb ff ff       	call   f0104bb7 <getuint>
f0104fbc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fbf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0104fc2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104fc7:	83 ec 0c             	sub    $0xc,%esp
f0104fca:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0104fce:	52                   	push   %edx
f0104fcf:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fd2:	50                   	push   %eax
f0104fd3:	ff 75 dc             	pushl  -0x24(%ebp)
f0104fd6:	ff 75 d8             	pushl  -0x28(%ebp)
f0104fd9:	89 da                	mov    %ebx,%edx
f0104fdb:	89 f0                	mov    %esi,%eax
f0104fdd:	e8 26 fb ff ff       	call   f0104b08 <printnum>
			break;
f0104fe2:	83 c4 20             	add    $0x20,%esp
f0104fe5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fe8:	e9 64 fc ff ff       	jmp    f0104c51 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104fed:	83 ec 08             	sub    $0x8,%esp
f0104ff0:	53                   	push   %ebx
f0104ff1:	51                   	push   %ecx
f0104ff2:	ff d6                	call   *%esi
			break;
f0104ff4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ff7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104ffa:	e9 52 fc ff ff       	jmp    f0104c51 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104fff:	83 ec 08             	sub    $0x8,%esp
f0105002:	53                   	push   %ebx
f0105003:	6a 25                	push   $0x25
f0105005:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105007:	83 c4 10             	add    $0x10,%esp
f010500a:	eb 03                	jmp    f010500f <vprintfmt+0x3e4>
f010500c:	83 ef 01             	sub    $0x1,%edi
f010500f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105013:	75 f7                	jne    f010500c <vprintfmt+0x3e1>
f0105015:	e9 37 fc ff ff       	jmp    f0104c51 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010501a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010501d:	5b                   	pop    %ebx
f010501e:	5e                   	pop    %esi
f010501f:	5f                   	pop    %edi
f0105020:	5d                   	pop    %ebp
f0105021:	c3                   	ret    

f0105022 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105022:	55                   	push   %ebp
f0105023:	89 e5                	mov    %esp,%ebp
f0105025:	83 ec 18             	sub    $0x18,%esp
f0105028:	8b 45 08             	mov    0x8(%ebp),%eax
f010502b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010502e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105031:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105035:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105038:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010503f:	85 c0                	test   %eax,%eax
f0105041:	74 26                	je     f0105069 <vsnprintf+0x47>
f0105043:	85 d2                	test   %edx,%edx
f0105045:	7e 22                	jle    f0105069 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105047:	ff 75 14             	pushl  0x14(%ebp)
f010504a:	ff 75 10             	pushl  0x10(%ebp)
f010504d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105050:	50                   	push   %eax
f0105051:	68 f1 4b 10 f0       	push   $0xf0104bf1
f0105056:	e8 d0 fb ff ff       	call   f0104c2b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010505b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010505e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105061:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105064:	83 c4 10             	add    $0x10,%esp
f0105067:	eb 05                	jmp    f010506e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105069:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010506e:	c9                   	leave  
f010506f:	c3                   	ret    

f0105070 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105070:	55                   	push   %ebp
f0105071:	89 e5                	mov    %esp,%ebp
f0105073:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105076:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105079:	50                   	push   %eax
f010507a:	ff 75 10             	pushl  0x10(%ebp)
f010507d:	ff 75 0c             	pushl  0xc(%ebp)
f0105080:	ff 75 08             	pushl  0x8(%ebp)
f0105083:	e8 9a ff ff ff       	call   f0105022 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105088:	c9                   	leave  
f0105089:	c3                   	ret    

f010508a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010508a:	55                   	push   %ebp
f010508b:	89 e5                	mov    %esp,%ebp
f010508d:	57                   	push   %edi
f010508e:	56                   	push   %esi
f010508f:	53                   	push   %ebx
f0105090:	83 ec 0c             	sub    $0xc,%esp
f0105093:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105096:	85 c0                	test   %eax,%eax
f0105098:	74 11                	je     f01050ab <readline+0x21>
		cprintf("%s", prompt);
f010509a:	83 ec 08             	sub    $0x8,%esp
f010509d:	50                   	push   %eax
f010509e:	68 d9 6f 10 f0       	push   $0xf0106fd9
f01050a3:	e8 c3 e7 ff ff       	call   f010386b <cprintf>
f01050a8:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01050ab:	83 ec 0c             	sub    $0xc,%esp
f01050ae:	6a 00                	push   $0x0
f01050b0:	e8 2c b7 ff ff       	call   f01007e1 <iscons>
f01050b5:	89 c7                	mov    %eax,%edi
f01050b7:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01050ba:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01050bf:	e8 0c b7 ff ff       	call   f01007d0 <getchar>
f01050c4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01050c6:	85 c0                	test   %eax,%eax
f01050c8:	79 18                	jns    f01050e2 <readline+0x58>
			cprintf("read error: %e\n", c);
f01050ca:	83 ec 08             	sub    $0x8,%esp
f01050cd:	50                   	push   %eax
f01050ce:	68 04 7c 10 f0       	push   $0xf0107c04
f01050d3:	e8 93 e7 ff ff       	call   f010386b <cprintf>
			return NULL;
f01050d8:	83 c4 10             	add    $0x10,%esp
f01050db:	b8 00 00 00 00       	mov    $0x0,%eax
f01050e0:	eb 79                	jmp    f010515b <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01050e2:	83 f8 08             	cmp    $0x8,%eax
f01050e5:	0f 94 c2             	sete   %dl
f01050e8:	83 f8 7f             	cmp    $0x7f,%eax
f01050eb:	0f 94 c0             	sete   %al
f01050ee:	08 c2                	or     %al,%dl
f01050f0:	74 1a                	je     f010510c <readline+0x82>
f01050f2:	85 f6                	test   %esi,%esi
f01050f4:	7e 16                	jle    f010510c <readline+0x82>
			if (echoing)
f01050f6:	85 ff                	test   %edi,%edi
f01050f8:	74 0d                	je     f0105107 <readline+0x7d>
				cputchar('\b');
f01050fa:	83 ec 0c             	sub    $0xc,%esp
f01050fd:	6a 08                	push   $0x8
f01050ff:	e8 bc b6 ff ff       	call   f01007c0 <cputchar>
f0105104:	83 c4 10             	add    $0x10,%esp
			i--;
f0105107:	83 ee 01             	sub    $0x1,%esi
f010510a:	eb b3                	jmp    f01050bf <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010510c:	83 fb 1f             	cmp    $0x1f,%ebx
f010510f:	7e 23                	jle    f0105134 <readline+0xaa>
f0105111:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105117:	7f 1b                	jg     f0105134 <readline+0xaa>
			if (echoing)
f0105119:	85 ff                	test   %edi,%edi
f010511b:	74 0c                	je     f0105129 <readline+0x9f>
				cputchar(c);
f010511d:	83 ec 0c             	sub    $0xc,%esp
f0105120:	53                   	push   %ebx
f0105121:	e8 9a b6 ff ff       	call   f01007c0 <cputchar>
f0105126:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105129:	88 9e 80 ba 22 f0    	mov    %bl,-0xfdd4580(%esi)
f010512f:	8d 76 01             	lea    0x1(%esi),%esi
f0105132:	eb 8b                	jmp    f01050bf <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105134:	83 fb 0a             	cmp    $0xa,%ebx
f0105137:	74 05                	je     f010513e <readline+0xb4>
f0105139:	83 fb 0d             	cmp    $0xd,%ebx
f010513c:	75 81                	jne    f01050bf <readline+0x35>
			if (echoing)
f010513e:	85 ff                	test   %edi,%edi
f0105140:	74 0d                	je     f010514f <readline+0xc5>
				cputchar('\n');
f0105142:	83 ec 0c             	sub    $0xc,%esp
f0105145:	6a 0a                	push   $0xa
f0105147:	e8 74 b6 ff ff       	call   f01007c0 <cputchar>
f010514c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010514f:	c6 86 80 ba 22 f0 00 	movb   $0x0,-0xfdd4580(%esi)
			return buf;
f0105156:	b8 80 ba 22 f0       	mov    $0xf022ba80,%eax
		}
	}
}
f010515b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010515e:	5b                   	pop    %ebx
f010515f:	5e                   	pop    %esi
f0105160:	5f                   	pop    %edi
f0105161:	5d                   	pop    %ebp
f0105162:	c3                   	ret    

f0105163 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105163:	55                   	push   %ebp
f0105164:	89 e5                	mov    %esp,%ebp
f0105166:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105169:	b8 00 00 00 00       	mov    $0x0,%eax
f010516e:	eb 03                	jmp    f0105173 <strlen+0x10>
		n++;
f0105170:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105173:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105177:	75 f7                	jne    f0105170 <strlen+0xd>
		n++;
	return n;
}
f0105179:	5d                   	pop    %ebp
f010517a:	c3                   	ret    

f010517b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010517b:	55                   	push   %ebp
f010517c:	89 e5                	mov    %esp,%ebp
f010517e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105181:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105184:	ba 00 00 00 00       	mov    $0x0,%edx
f0105189:	eb 03                	jmp    f010518e <strnlen+0x13>
		n++;
f010518b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010518e:	39 c2                	cmp    %eax,%edx
f0105190:	74 08                	je     f010519a <strnlen+0x1f>
f0105192:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105196:	75 f3                	jne    f010518b <strnlen+0x10>
f0105198:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010519a:	5d                   	pop    %ebp
f010519b:	c3                   	ret    

f010519c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010519c:	55                   	push   %ebp
f010519d:	89 e5                	mov    %esp,%ebp
f010519f:	53                   	push   %ebx
f01051a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01051a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01051a6:	89 c2                	mov    %eax,%edx
f01051a8:	83 c2 01             	add    $0x1,%edx
f01051ab:	83 c1 01             	add    $0x1,%ecx
f01051ae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01051b2:	88 5a ff             	mov    %bl,-0x1(%edx)
f01051b5:	84 db                	test   %bl,%bl
f01051b7:	75 ef                	jne    f01051a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01051b9:	5b                   	pop    %ebx
f01051ba:	5d                   	pop    %ebp
f01051bb:	c3                   	ret    

f01051bc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01051bc:	55                   	push   %ebp
f01051bd:	89 e5                	mov    %esp,%ebp
f01051bf:	53                   	push   %ebx
f01051c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01051c3:	53                   	push   %ebx
f01051c4:	e8 9a ff ff ff       	call   f0105163 <strlen>
f01051c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01051cc:	ff 75 0c             	pushl  0xc(%ebp)
f01051cf:	01 d8                	add    %ebx,%eax
f01051d1:	50                   	push   %eax
f01051d2:	e8 c5 ff ff ff       	call   f010519c <strcpy>
	return dst;
}
f01051d7:	89 d8                	mov    %ebx,%eax
f01051d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01051dc:	c9                   	leave  
f01051dd:	c3                   	ret    

f01051de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01051de:	55                   	push   %ebp
f01051df:	89 e5                	mov    %esp,%ebp
f01051e1:	56                   	push   %esi
f01051e2:	53                   	push   %ebx
f01051e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01051e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01051e9:	89 f3                	mov    %esi,%ebx
f01051eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01051ee:	89 f2                	mov    %esi,%edx
f01051f0:	eb 0f                	jmp    f0105201 <strncpy+0x23>
		*dst++ = *src;
f01051f2:	83 c2 01             	add    $0x1,%edx
f01051f5:	0f b6 01             	movzbl (%ecx),%eax
f01051f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01051fb:	80 39 01             	cmpb   $0x1,(%ecx)
f01051fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105201:	39 da                	cmp    %ebx,%edx
f0105203:	75 ed                	jne    f01051f2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105205:	89 f0                	mov    %esi,%eax
f0105207:	5b                   	pop    %ebx
f0105208:	5e                   	pop    %esi
f0105209:	5d                   	pop    %ebp
f010520a:	c3                   	ret    

f010520b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010520b:	55                   	push   %ebp
f010520c:	89 e5                	mov    %esp,%ebp
f010520e:	56                   	push   %esi
f010520f:	53                   	push   %ebx
f0105210:	8b 75 08             	mov    0x8(%ebp),%esi
f0105213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105216:	8b 55 10             	mov    0x10(%ebp),%edx
f0105219:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010521b:	85 d2                	test   %edx,%edx
f010521d:	74 21                	je     f0105240 <strlcpy+0x35>
f010521f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105223:	89 f2                	mov    %esi,%edx
f0105225:	eb 09                	jmp    f0105230 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105227:	83 c2 01             	add    $0x1,%edx
f010522a:	83 c1 01             	add    $0x1,%ecx
f010522d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105230:	39 c2                	cmp    %eax,%edx
f0105232:	74 09                	je     f010523d <strlcpy+0x32>
f0105234:	0f b6 19             	movzbl (%ecx),%ebx
f0105237:	84 db                	test   %bl,%bl
f0105239:	75 ec                	jne    f0105227 <strlcpy+0x1c>
f010523b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010523d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105240:	29 f0                	sub    %esi,%eax
}
f0105242:	5b                   	pop    %ebx
f0105243:	5e                   	pop    %esi
f0105244:	5d                   	pop    %ebp
f0105245:	c3                   	ret    

f0105246 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105246:	55                   	push   %ebp
f0105247:	89 e5                	mov    %esp,%ebp
f0105249:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010524c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010524f:	eb 06                	jmp    f0105257 <strcmp+0x11>
		p++, q++;
f0105251:	83 c1 01             	add    $0x1,%ecx
f0105254:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105257:	0f b6 01             	movzbl (%ecx),%eax
f010525a:	84 c0                	test   %al,%al
f010525c:	74 04                	je     f0105262 <strcmp+0x1c>
f010525e:	3a 02                	cmp    (%edx),%al
f0105260:	74 ef                	je     f0105251 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105262:	0f b6 c0             	movzbl %al,%eax
f0105265:	0f b6 12             	movzbl (%edx),%edx
f0105268:	29 d0                	sub    %edx,%eax
}
f010526a:	5d                   	pop    %ebp
f010526b:	c3                   	ret    

f010526c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010526c:	55                   	push   %ebp
f010526d:	89 e5                	mov    %esp,%ebp
f010526f:	53                   	push   %ebx
f0105270:	8b 45 08             	mov    0x8(%ebp),%eax
f0105273:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105276:	89 c3                	mov    %eax,%ebx
f0105278:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010527b:	eb 06                	jmp    f0105283 <strncmp+0x17>
		n--, p++, q++;
f010527d:	83 c0 01             	add    $0x1,%eax
f0105280:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105283:	39 d8                	cmp    %ebx,%eax
f0105285:	74 15                	je     f010529c <strncmp+0x30>
f0105287:	0f b6 08             	movzbl (%eax),%ecx
f010528a:	84 c9                	test   %cl,%cl
f010528c:	74 04                	je     f0105292 <strncmp+0x26>
f010528e:	3a 0a                	cmp    (%edx),%cl
f0105290:	74 eb                	je     f010527d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105292:	0f b6 00             	movzbl (%eax),%eax
f0105295:	0f b6 12             	movzbl (%edx),%edx
f0105298:	29 d0                	sub    %edx,%eax
f010529a:	eb 05                	jmp    f01052a1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010529c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01052a1:	5b                   	pop    %ebx
f01052a2:	5d                   	pop    %ebp
f01052a3:	c3                   	ret    

f01052a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01052a4:	55                   	push   %ebp
f01052a5:	89 e5                	mov    %esp,%ebp
f01052a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01052aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01052ae:	eb 07                	jmp    f01052b7 <strchr+0x13>
		if (*s == c)
f01052b0:	38 ca                	cmp    %cl,%dl
f01052b2:	74 0f                	je     f01052c3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01052b4:	83 c0 01             	add    $0x1,%eax
f01052b7:	0f b6 10             	movzbl (%eax),%edx
f01052ba:	84 d2                	test   %dl,%dl
f01052bc:	75 f2                	jne    f01052b0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01052be:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052c3:	5d                   	pop    %ebp
f01052c4:	c3                   	ret    

f01052c5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01052c5:	55                   	push   %ebp
f01052c6:	89 e5                	mov    %esp,%ebp
f01052c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01052cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01052cf:	eb 03                	jmp    f01052d4 <strfind+0xf>
f01052d1:	83 c0 01             	add    $0x1,%eax
f01052d4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01052d7:	38 ca                	cmp    %cl,%dl
f01052d9:	74 04                	je     f01052df <strfind+0x1a>
f01052db:	84 d2                	test   %dl,%dl
f01052dd:	75 f2                	jne    f01052d1 <strfind+0xc>
			break;
	return (char *) s;
}
f01052df:	5d                   	pop    %ebp
f01052e0:	c3                   	ret    

f01052e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01052e1:	55                   	push   %ebp
f01052e2:	89 e5                	mov    %esp,%ebp
f01052e4:	57                   	push   %edi
f01052e5:	56                   	push   %esi
f01052e6:	53                   	push   %ebx
f01052e7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01052ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01052ed:	85 c9                	test   %ecx,%ecx
f01052ef:	74 36                	je     f0105327 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01052f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01052f7:	75 28                	jne    f0105321 <memset+0x40>
f01052f9:	f6 c1 03             	test   $0x3,%cl
f01052fc:	75 23                	jne    f0105321 <memset+0x40>
		c &= 0xFF;
f01052fe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105302:	89 d3                	mov    %edx,%ebx
f0105304:	c1 e3 08             	shl    $0x8,%ebx
f0105307:	89 d6                	mov    %edx,%esi
f0105309:	c1 e6 18             	shl    $0x18,%esi
f010530c:	89 d0                	mov    %edx,%eax
f010530e:	c1 e0 10             	shl    $0x10,%eax
f0105311:	09 f0                	or     %esi,%eax
f0105313:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105315:	89 d8                	mov    %ebx,%eax
f0105317:	09 d0                	or     %edx,%eax
f0105319:	c1 e9 02             	shr    $0x2,%ecx
f010531c:	fc                   	cld    
f010531d:	f3 ab                	rep stos %eax,%es:(%edi)
f010531f:	eb 06                	jmp    f0105327 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105321:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105324:	fc                   	cld    
f0105325:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105327:	89 f8                	mov    %edi,%eax
f0105329:	5b                   	pop    %ebx
f010532a:	5e                   	pop    %esi
f010532b:	5f                   	pop    %edi
f010532c:	5d                   	pop    %ebp
f010532d:	c3                   	ret    

f010532e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010532e:	55                   	push   %ebp
f010532f:	89 e5                	mov    %esp,%ebp
f0105331:	57                   	push   %edi
f0105332:	56                   	push   %esi
f0105333:	8b 45 08             	mov    0x8(%ebp),%eax
f0105336:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105339:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010533c:	39 c6                	cmp    %eax,%esi
f010533e:	73 35                	jae    f0105375 <memmove+0x47>
f0105340:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105343:	39 d0                	cmp    %edx,%eax
f0105345:	73 2e                	jae    f0105375 <memmove+0x47>
		s += n;
		d += n;
f0105347:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010534a:	89 d6                	mov    %edx,%esi
f010534c:	09 fe                	or     %edi,%esi
f010534e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105354:	75 13                	jne    f0105369 <memmove+0x3b>
f0105356:	f6 c1 03             	test   $0x3,%cl
f0105359:	75 0e                	jne    f0105369 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010535b:	83 ef 04             	sub    $0x4,%edi
f010535e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105361:	c1 e9 02             	shr    $0x2,%ecx
f0105364:	fd                   	std    
f0105365:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105367:	eb 09                	jmp    f0105372 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105369:	83 ef 01             	sub    $0x1,%edi
f010536c:	8d 72 ff             	lea    -0x1(%edx),%esi
f010536f:	fd                   	std    
f0105370:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105372:	fc                   	cld    
f0105373:	eb 1d                	jmp    f0105392 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105375:	89 f2                	mov    %esi,%edx
f0105377:	09 c2                	or     %eax,%edx
f0105379:	f6 c2 03             	test   $0x3,%dl
f010537c:	75 0f                	jne    f010538d <memmove+0x5f>
f010537e:	f6 c1 03             	test   $0x3,%cl
f0105381:	75 0a                	jne    f010538d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105383:	c1 e9 02             	shr    $0x2,%ecx
f0105386:	89 c7                	mov    %eax,%edi
f0105388:	fc                   	cld    
f0105389:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010538b:	eb 05                	jmp    f0105392 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010538d:	89 c7                	mov    %eax,%edi
f010538f:	fc                   	cld    
f0105390:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105392:	5e                   	pop    %esi
f0105393:	5f                   	pop    %edi
f0105394:	5d                   	pop    %ebp
f0105395:	c3                   	ret    

f0105396 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105396:	55                   	push   %ebp
f0105397:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105399:	ff 75 10             	pushl  0x10(%ebp)
f010539c:	ff 75 0c             	pushl  0xc(%ebp)
f010539f:	ff 75 08             	pushl  0x8(%ebp)
f01053a2:	e8 87 ff ff ff       	call   f010532e <memmove>
}
f01053a7:	c9                   	leave  
f01053a8:	c3                   	ret    

f01053a9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01053a9:	55                   	push   %ebp
f01053aa:	89 e5                	mov    %esp,%ebp
f01053ac:	56                   	push   %esi
f01053ad:	53                   	push   %ebx
f01053ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01053b1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053b4:	89 c6                	mov    %eax,%esi
f01053b6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01053b9:	eb 1a                	jmp    f01053d5 <memcmp+0x2c>
		if (*s1 != *s2)
f01053bb:	0f b6 08             	movzbl (%eax),%ecx
f01053be:	0f b6 1a             	movzbl (%edx),%ebx
f01053c1:	38 d9                	cmp    %bl,%cl
f01053c3:	74 0a                	je     f01053cf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01053c5:	0f b6 c1             	movzbl %cl,%eax
f01053c8:	0f b6 db             	movzbl %bl,%ebx
f01053cb:	29 d8                	sub    %ebx,%eax
f01053cd:	eb 0f                	jmp    f01053de <memcmp+0x35>
		s1++, s2++;
f01053cf:	83 c0 01             	add    $0x1,%eax
f01053d2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01053d5:	39 f0                	cmp    %esi,%eax
f01053d7:	75 e2                	jne    f01053bb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01053d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01053de:	5b                   	pop    %ebx
f01053df:	5e                   	pop    %esi
f01053e0:	5d                   	pop    %ebp
f01053e1:	c3                   	ret    

f01053e2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01053e2:	55                   	push   %ebp
f01053e3:	89 e5                	mov    %esp,%ebp
f01053e5:	53                   	push   %ebx
f01053e6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01053e9:	89 c1                	mov    %eax,%ecx
f01053eb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01053ee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053f2:	eb 0a                	jmp    f01053fe <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01053f4:	0f b6 10             	movzbl (%eax),%edx
f01053f7:	39 da                	cmp    %ebx,%edx
f01053f9:	74 07                	je     f0105402 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01053fb:	83 c0 01             	add    $0x1,%eax
f01053fe:	39 c8                	cmp    %ecx,%eax
f0105400:	72 f2                	jb     f01053f4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105402:	5b                   	pop    %ebx
f0105403:	5d                   	pop    %ebp
f0105404:	c3                   	ret    

f0105405 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105405:	55                   	push   %ebp
f0105406:	89 e5                	mov    %esp,%ebp
f0105408:	57                   	push   %edi
f0105409:	56                   	push   %esi
f010540a:	53                   	push   %ebx
f010540b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010540e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105411:	eb 03                	jmp    f0105416 <strtol+0x11>
		s++;
f0105413:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105416:	0f b6 01             	movzbl (%ecx),%eax
f0105419:	3c 20                	cmp    $0x20,%al
f010541b:	74 f6                	je     f0105413 <strtol+0xe>
f010541d:	3c 09                	cmp    $0x9,%al
f010541f:	74 f2                	je     f0105413 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105421:	3c 2b                	cmp    $0x2b,%al
f0105423:	75 0a                	jne    f010542f <strtol+0x2a>
		s++;
f0105425:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105428:	bf 00 00 00 00       	mov    $0x0,%edi
f010542d:	eb 11                	jmp    f0105440 <strtol+0x3b>
f010542f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105434:	3c 2d                	cmp    $0x2d,%al
f0105436:	75 08                	jne    f0105440 <strtol+0x3b>
		s++, neg = 1;
f0105438:	83 c1 01             	add    $0x1,%ecx
f010543b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105440:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105446:	75 15                	jne    f010545d <strtol+0x58>
f0105448:	80 39 30             	cmpb   $0x30,(%ecx)
f010544b:	75 10                	jne    f010545d <strtol+0x58>
f010544d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105451:	75 7c                	jne    f01054cf <strtol+0xca>
		s += 2, base = 16;
f0105453:	83 c1 02             	add    $0x2,%ecx
f0105456:	bb 10 00 00 00       	mov    $0x10,%ebx
f010545b:	eb 16                	jmp    f0105473 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010545d:	85 db                	test   %ebx,%ebx
f010545f:	75 12                	jne    f0105473 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105461:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105466:	80 39 30             	cmpb   $0x30,(%ecx)
f0105469:	75 08                	jne    f0105473 <strtol+0x6e>
		s++, base = 8;
f010546b:	83 c1 01             	add    $0x1,%ecx
f010546e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105473:	b8 00 00 00 00       	mov    $0x0,%eax
f0105478:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010547b:	0f b6 11             	movzbl (%ecx),%edx
f010547e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105481:	89 f3                	mov    %esi,%ebx
f0105483:	80 fb 09             	cmp    $0x9,%bl
f0105486:	77 08                	ja     f0105490 <strtol+0x8b>
			dig = *s - '0';
f0105488:	0f be d2             	movsbl %dl,%edx
f010548b:	83 ea 30             	sub    $0x30,%edx
f010548e:	eb 22                	jmp    f01054b2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105490:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105493:	89 f3                	mov    %esi,%ebx
f0105495:	80 fb 19             	cmp    $0x19,%bl
f0105498:	77 08                	ja     f01054a2 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010549a:	0f be d2             	movsbl %dl,%edx
f010549d:	83 ea 57             	sub    $0x57,%edx
f01054a0:	eb 10                	jmp    f01054b2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01054a2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01054a5:	89 f3                	mov    %esi,%ebx
f01054a7:	80 fb 19             	cmp    $0x19,%bl
f01054aa:	77 16                	ja     f01054c2 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01054ac:	0f be d2             	movsbl %dl,%edx
f01054af:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01054b2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01054b5:	7d 0b                	jge    f01054c2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01054b7:	83 c1 01             	add    $0x1,%ecx
f01054ba:	0f af 45 10          	imul   0x10(%ebp),%eax
f01054be:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01054c0:	eb b9                	jmp    f010547b <strtol+0x76>

	if (endptr)
f01054c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01054c6:	74 0d                	je     f01054d5 <strtol+0xd0>
		*endptr = (char *) s;
f01054c8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01054cb:	89 0e                	mov    %ecx,(%esi)
f01054cd:	eb 06                	jmp    f01054d5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01054cf:	85 db                	test   %ebx,%ebx
f01054d1:	74 98                	je     f010546b <strtol+0x66>
f01054d3:	eb 9e                	jmp    f0105473 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01054d5:	89 c2                	mov    %eax,%edx
f01054d7:	f7 da                	neg    %edx
f01054d9:	85 ff                	test   %edi,%edi
f01054db:	0f 45 c2             	cmovne %edx,%eax
}
f01054de:	5b                   	pop    %ebx
f01054df:	5e                   	pop    %esi
f01054e0:	5f                   	pop    %edi
f01054e1:	5d                   	pop    %ebp
f01054e2:	c3                   	ret    
f01054e3:	90                   	nop

f01054e4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01054e4:	fa                   	cli    

	xorw    %ax, %ax
f01054e5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01054e7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01054e9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01054eb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01054ed:	0f 01 16             	lgdtl  (%esi)
f01054f0:	74 70                	je     f0105562 <mpsearch1+0x3>
	movl    %cr0, %eax
f01054f2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01054f5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f01054f9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f01054fc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105502:	08 00                	or     %al,(%eax)

f0105504 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105504:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105508:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010550a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010550c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010550e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105512:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105514:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105516:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f010551b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010551e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105521:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105526:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105529:	8b 25 84 be 22 f0    	mov    0xf022be84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010552f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105534:	b8 07 02 10 f0       	mov    $0xf0100207,%eax
	call    *%eax
f0105539:	ff d0                	call   *%eax

f010553b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010553b:	eb fe                	jmp    f010553b <spin>
f010553d:	8d 76 00             	lea    0x0(%esi),%esi

f0105540 <gdt>:
	...
f0105548:	ff                   	(bad)  
f0105549:	ff 00                	incl   (%eax)
f010554b:	00 00                	add    %al,(%eax)
f010554d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105554:	00                   	.byte 0x0
f0105555:	92                   	xchg   %eax,%edx
f0105556:	cf                   	iret   
	...

f0105558 <gdtdesc>:
f0105558:	17                   	pop    %ss
f0105559:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010555e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010555e:	90                   	nop

f010555f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010555f:	55                   	push   %ebp
f0105560:	89 e5                	mov    %esp,%ebp
f0105562:	57                   	push   %edi
f0105563:	56                   	push   %esi
f0105564:	53                   	push   %ebx
f0105565:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105568:	8b 0d 88 be 22 f0    	mov    0xf022be88,%ecx
f010556e:	89 c3                	mov    %eax,%ebx
f0105570:	c1 eb 0c             	shr    $0xc,%ebx
f0105573:	39 cb                	cmp    %ecx,%ebx
f0105575:	72 12                	jb     f0105589 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105577:	50                   	push   %eax
f0105578:	68 54 60 10 f0       	push   $0xf0106054
f010557d:	6a 57                	push   $0x57
f010557f:	68 a1 7d 10 f0       	push   $0xf0107da1
f0105584:	e8 0b ab ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0105589:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010558f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105591:	89 c2                	mov    %eax,%edx
f0105593:	c1 ea 0c             	shr    $0xc,%edx
f0105596:	39 ca                	cmp    %ecx,%edx
f0105598:	72 12                	jb     f01055ac <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010559a:	50                   	push   %eax
f010559b:	68 54 60 10 f0       	push   $0xf0106054
f01055a0:	6a 57                	push   $0x57
f01055a2:	68 a1 7d 10 f0       	push   $0xf0107da1
f01055a7:	e8 e8 aa ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01055ac:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01055b2:	eb 2f                	jmp    f01055e3 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01055b4:	83 ec 04             	sub    $0x4,%esp
f01055b7:	6a 04                	push   $0x4
f01055b9:	68 b1 7d 10 f0       	push   $0xf0107db1
f01055be:	53                   	push   %ebx
f01055bf:	e8 e5 fd ff ff       	call   f01053a9 <memcmp>
f01055c4:	83 c4 10             	add    $0x10,%esp
f01055c7:	85 c0                	test   %eax,%eax
f01055c9:	75 15                	jne    f01055e0 <mpsearch1+0x81>
f01055cb:	89 da                	mov    %ebx,%edx
f01055cd:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f01055d0:	0f b6 0a             	movzbl (%edx),%ecx
f01055d3:	01 c8                	add    %ecx,%eax
f01055d5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01055d8:	39 d7                	cmp    %edx,%edi
f01055da:	75 f4                	jne    f01055d0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01055dc:	84 c0                	test   %al,%al
f01055de:	74 0e                	je     f01055ee <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01055e0:	83 c3 10             	add    $0x10,%ebx
f01055e3:	39 f3                	cmp    %esi,%ebx
f01055e5:	72 cd                	jb     f01055b4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f01055e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01055ec:	eb 02                	jmp    f01055f0 <mpsearch1+0x91>
f01055ee:	89 d8                	mov    %ebx,%eax
}
f01055f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01055f3:	5b                   	pop    %ebx
f01055f4:	5e                   	pop    %esi
f01055f5:	5f                   	pop    %edi
f01055f6:	5d                   	pop    %ebp
f01055f7:	c3                   	ret    

f01055f8 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01055f8:	55                   	push   %ebp
f01055f9:	89 e5                	mov    %esp,%ebp
f01055fb:	57                   	push   %edi
f01055fc:	56                   	push   %esi
f01055fd:	53                   	push   %ebx
f01055fe:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105601:	c7 05 c0 c3 22 f0 20 	movl   $0xf022c020,0xf022c3c0
f0105608:	c0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010560b:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105612:	75 16                	jne    f010562a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105614:	68 00 04 00 00       	push   $0x400
f0105619:	68 54 60 10 f0       	push   $0xf0106054
f010561e:	6a 6f                	push   $0x6f
f0105620:	68 a1 7d 10 f0       	push   $0xf0107da1
f0105625:	e8 6a aa ff ff       	call   f0100094 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010562a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105631:	85 c0                	test   %eax,%eax
f0105633:	74 16                	je     f010564b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105635:	c1 e0 04             	shl    $0x4,%eax
f0105638:	ba 00 04 00 00       	mov    $0x400,%edx
f010563d:	e8 1d ff ff ff       	call   f010555f <mpsearch1>
f0105642:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105645:	85 c0                	test   %eax,%eax
f0105647:	75 3c                	jne    f0105685 <mp_init+0x8d>
f0105649:	eb 20                	jmp    f010566b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f010564b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105652:	c1 e0 0a             	shl    $0xa,%eax
f0105655:	2d 00 04 00 00       	sub    $0x400,%eax
f010565a:	ba 00 04 00 00       	mov    $0x400,%edx
f010565f:	e8 fb fe ff ff       	call   f010555f <mpsearch1>
f0105664:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105667:	85 c0                	test   %eax,%eax
f0105669:	75 1a                	jne    f0105685 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010566b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105670:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105675:	e8 e5 fe ff ff       	call   f010555f <mpsearch1>
f010567a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010567d:	85 c0                	test   %eax,%eax
f010567f:	0f 84 5d 02 00 00    	je     f01058e2 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105685:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105688:	8b 70 04             	mov    0x4(%eax),%esi
f010568b:	85 f6                	test   %esi,%esi
f010568d:	74 06                	je     f0105695 <mp_init+0x9d>
f010568f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105693:	74 15                	je     f01056aa <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105695:	83 ec 0c             	sub    $0xc,%esp
f0105698:	68 14 7c 10 f0       	push   $0xf0107c14
f010569d:	e8 c9 e1 ff ff       	call   f010386b <cprintf>
f01056a2:	83 c4 10             	add    $0x10,%esp
f01056a5:	e9 38 02 00 00       	jmp    f01058e2 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01056aa:	89 f0                	mov    %esi,%eax
f01056ac:	c1 e8 0c             	shr    $0xc,%eax
f01056af:	3b 05 88 be 22 f0    	cmp    0xf022be88,%eax
f01056b5:	72 15                	jb     f01056cc <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01056b7:	56                   	push   %esi
f01056b8:	68 54 60 10 f0       	push   $0xf0106054
f01056bd:	68 90 00 00 00       	push   $0x90
f01056c2:	68 a1 7d 10 f0       	push   $0xf0107da1
f01056c7:	e8 c8 a9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01056cc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f01056d2:	83 ec 04             	sub    $0x4,%esp
f01056d5:	6a 04                	push   $0x4
f01056d7:	68 b6 7d 10 f0       	push   $0xf0107db6
f01056dc:	53                   	push   %ebx
f01056dd:	e8 c7 fc ff ff       	call   f01053a9 <memcmp>
f01056e2:	83 c4 10             	add    $0x10,%esp
f01056e5:	85 c0                	test   %eax,%eax
f01056e7:	74 15                	je     f01056fe <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01056e9:	83 ec 0c             	sub    $0xc,%esp
f01056ec:	68 44 7c 10 f0       	push   $0xf0107c44
f01056f1:	e8 75 e1 ff ff       	call   f010386b <cprintf>
f01056f6:	83 c4 10             	add    $0x10,%esp
f01056f9:	e9 e4 01 00 00       	jmp    f01058e2 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01056fe:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105702:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105706:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105709:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010570e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105713:	eb 0d                	jmp    f0105722 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105715:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f010571c:	f0 
f010571d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010571f:	83 c0 01             	add    $0x1,%eax
f0105722:	39 c7                	cmp    %eax,%edi
f0105724:	75 ef                	jne    f0105715 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105726:	84 d2                	test   %dl,%dl
f0105728:	74 15                	je     f010573f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010572a:	83 ec 0c             	sub    $0xc,%esp
f010572d:	68 78 7c 10 f0       	push   $0xf0107c78
f0105732:	e8 34 e1 ff ff       	call   f010386b <cprintf>
f0105737:	83 c4 10             	add    $0x10,%esp
f010573a:	e9 a3 01 00 00       	jmp    f01058e2 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010573f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105743:	3c 01                	cmp    $0x1,%al
f0105745:	74 1d                	je     f0105764 <mp_init+0x16c>
f0105747:	3c 04                	cmp    $0x4,%al
f0105749:	74 19                	je     f0105764 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010574b:	83 ec 08             	sub    $0x8,%esp
f010574e:	0f b6 c0             	movzbl %al,%eax
f0105751:	50                   	push   %eax
f0105752:	68 9c 7c 10 f0       	push   $0xf0107c9c
f0105757:	e8 0f e1 ff ff       	call   f010386b <cprintf>
f010575c:	83 c4 10             	add    $0x10,%esp
f010575f:	e9 7e 01 00 00       	jmp    f01058e2 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105764:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105768:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010576c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105771:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105776:	01 ce                	add    %ecx,%esi
f0105778:	eb 0d                	jmp    f0105787 <mp_init+0x18f>
f010577a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105781:	f0 
f0105782:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105784:	83 c0 01             	add    $0x1,%eax
f0105787:	39 c7                	cmp    %eax,%edi
f0105789:	75 ef                	jne    f010577a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010578b:	89 d0                	mov    %edx,%eax
f010578d:	02 43 2a             	add    0x2a(%ebx),%al
f0105790:	74 15                	je     f01057a7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105792:	83 ec 0c             	sub    $0xc,%esp
f0105795:	68 bc 7c 10 f0       	push   $0xf0107cbc
f010579a:	e8 cc e0 ff ff       	call   f010386b <cprintf>
f010579f:	83 c4 10             	add    $0x10,%esp
f01057a2:	e9 3b 01 00 00       	jmp    f01058e2 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01057a7:	85 db                	test   %ebx,%ebx
f01057a9:	0f 84 33 01 00 00    	je     f01058e2 <mp_init+0x2ea>
		return;
	ismp = 1;
f01057af:	c7 05 00 c0 22 f0 01 	movl   $0x1,0xf022c000
f01057b6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01057b9:	8b 43 24             	mov    0x24(%ebx),%eax
f01057bc:	a3 00 d0 26 f0       	mov    %eax,0xf026d000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01057c1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f01057c4:	be 00 00 00 00       	mov    $0x0,%esi
f01057c9:	e9 85 00 00 00       	jmp    f0105853 <mp_init+0x25b>
		switch (*p) {
f01057ce:	0f b6 07             	movzbl (%edi),%eax
f01057d1:	84 c0                	test   %al,%al
f01057d3:	74 06                	je     f01057db <mp_init+0x1e3>
f01057d5:	3c 04                	cmp    $0x4,%al
f01057d7:	77 55                	ja     f010582e <mp_init+0x236>
f01057d9:	eb 4e                	jmp    f0105829 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01057db:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01057df:	74 11                	je     f01057f2 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f01057e1:	6b 05 c4 c3 22 f0 74 	imul   $0x74,0xf022c3c4,%eax
f01057e8:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f01057ed:	a3 c0 c3 22 f0       	mov    %eax,0xf022c3c0
			if (ncpu < NCPU) {
f01057f2:	a1 c4 c3 22 f0       	mov    0xf022c3c4,%eax
f01057f7:	83 f8 07             	cmp    $0x7,%eax
f01057fa:	7f 13                	jg     f010580f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01057fc:	6b d0 74             	imul   $0x74,%eax,%edx
f01057ff:	88 82 20 c0 22 f0    	mov    %al,-0xfdd3fe0(%edx)
				ncpu++;
f0105805:	83 c0 01             	add    $0x1,%eax
f0105808:	a3 c4 c3 22 f0       	mov    %eax,0xf022c3c4
f010580d:	eb 15                	jmp    f0105824 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010580f:	83 ec 08             	sub    $0x8,%esp
f0105812:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105816:	50                   	push   %eax
f0105817:	68 ec 7c 10 f0       	push   $0xf0107cec
f010581c:	e8 4a e0 ff ff       	call   f010386b <cprintf>
f0105821:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105824:	83 c7 14             	add    $0x14,%edi
			continue;
f0105827:	eb 27                	jmp    f0105850 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105829:	83 c7 08             	add    $0x8,%edi
			continue;
f010582c:	eb 22                	jmp    f0105850 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010582e:	83 ec 08             	sub    $0x8,%esp
f0105831:	0f b6 c0             	movzbl %al,%eax
f0105834:	50                   	push   %eax
f0105835:	68 14 7d 10 f0       	push   $0xf0107d14
f010583a:	e8 2c e0 ff ff       	call   f010386b <cprintf>
			ismp = 0;
f010583f:	c7 05 00 c0 22 f0 00 	movl   $0x0,0xf022c000
f0105846:	00 00 00 
			i = conf->entry;
f0105849:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010584d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105850:	83 c6 01             	add    $0x1,%esi
f0105853:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105857:	39 c6                	cmp    %eax,%esi
f0105859:	0f 82 6f ff ff ff    	jb     f01057ce <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010585f:	a1 c0 c3 22 f0       	mov    0xf022c3c0,%eax
f0105864:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010586b:	83 3d 00 c0 22 f0 00 	cmpl   $0x0,0xf022c000
f0105872:	75 26                	jne    f010589a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105874:	c7 05 c4 c3 22 f0 01 	movl   $0x1,0xf022c3c4
f010587b:	00 00 00 
		lapicaddr = 0;
f010587e:	c7 05 00 d0 26 f0 00 	movl   $0x0,0xf026d000
f0105885:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105888:	83 ec 0c             	sub    $0xc,%esp
f010588b:	68 34 7d 10 f0       	push   $0xf0107d34
f0105890:	e8 d6 df ff ff       	call   f010386b <cprintf>
		return;
f0105895:	83 c4 10             	add    $0x10,%esp
f0105898:	eb 48                	jmp    f01058e2 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010589a:	83 ec 04             	sub    $0x4,%esp
f010589d:	ff 35 c4 c3 22 f0    	pushl  0xf022c3c4
f01058a3:	0f b6 00             	movzbl (%eax),%eax
f01058a6:	50                   	push   %eax
f01058a7:	68 bb 7d 10 f0       	push   $0xf0107dbb
f01058ac:	e8 ba df ff ff       	call   f010386b <cprintf>

	if (mp->imcrp) {
f01058b1:	83 c4 10             	add    $0x10,%esp
f01058b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058b7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01058bb:	74 25                	je     f01058e2 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01058bd:	83 ec 0c             	sub    $0xc,%esp
f01058c0:	68 60 7d 10 f0       	push   $0xf0107d60
f01058c5:	e8 a1 df ff ff       	call   f010386b <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01058ca:	ba 22 00 00 00       	mov    $0x22,%edx
f01058cf:	b8 70 00 00 00       	mov    $0x70,%eax
f01058d4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01058d5:	ba 23 00 00 00       	mov    $0x23,%edx
f01058da:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01058db:	83 c8 01             	or     $0x1,%eax
f01058de:	ee                   	out    %al,(%dx)
f01058df:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01058e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01058e5:	5b                   	pop    %ebx
f01058e6:	5e                   	pop    %esi
f01058e7:	5f                   	pop    %edi
f01058e8:	5d                   	pop    %ebp
f01058e9:	c3                   	ret    

f01058ea <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01058ea:	55                   	push   %ebp
f01058eb:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01058ed:	8b 0d 04 d0 26 f0    	mov    0xf026d004,%ecx
f01058f3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01058f6:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01058f8:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01058fd:	8b 40 20             	mov    0x20(%eax),%eax
//	panic("after lapicw.\n");
}
f0105900:	5d                   	pop    %ebp
f0105901:	c3                   	ret    

f0105902 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105902:	55                   	push   %ebp
f0105903:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105905:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f010590a:	85 c0                	test   %eax,%eax
f010590c:	74 08                	je     f0105916 <cpunum+0x14>
		return lapic[ID] >> 24;
f010590e:	8b 40 20             	mov    0x20(%eax),%eax
f0105911:	c1 e8 18             	shr    $0x18,%eax
f0105914:	eb 05                	jmp    f010591b <cpunum+0x19>
	return 0;
f0105916:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010591b:	5d                   	pop    %ebp
f010591c:	c3                   	ret    

f010591d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f010591d:	a1 00 d0 26 f0       	mov    0xf026d000,%eax
f0105922:	85 c0                	test   %eax,%eax
f0105924:	0f 84 21 01 00 00    	je     f0105a4b <lapic_init+0x12e>
//	panic("after lapicw.\n");
}

void
lapic_init(void)
{
f010592a:	55                   	push   %ebp
f010592b:	89 e5                	mov    %esp,%ebp
f010592d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105930:	68 00 10 00 00       	push   $0x1000
f0105935:	50                   	push   %eax
f0105936:	e8 b1 ba ff ff       	call   f01013ec <mmio_map_region>
f010593b:	a3 04 d0 26 f0       	mov    %eax,0xf026d004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105940:	ba 27 01 00 00       	mov    $0x127,%edx
f0105945:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010594a:	e8 9b ff ff ff       	call   f01058ea <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010594f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105954:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105959:	e8 8c ff ff ff       	call   f01058ea <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010595e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105963:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105968:	e8 7d ff ff ff       	call   f01058ea <lapicw>
	lapicw(TICR, 10000000); 
f010596d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105972:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105977:	e8 6e ff ff ff       	call   f01058ea <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010597c:	e8 81 ff ff ff       	call   f0105902 <cpunum>
f0105981:	6b c0 74             	imul   $0x74,%eax,%eax
f0105984:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105989:	83 c4 10             	add    $0x10,%esp
f010598c:	39 05 c0 c3 22 f0    	cmp    %eax,0xf022c3c0
f0105992:	74 0f                	je     f01059a3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105994:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105999:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010599e:	e8 47 ff ff ff       	call   f01058ea <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01059a3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01059a8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01059ad:	e8 38 ff ff ff       	call   f01058ea <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01059b2:	a1 04 d0 26 f0       	mov    0xf026d004,%eax
f01059b7:	8b 40 30             	mov    0x30(%eax),%eax
f01059ba:	c1 e8 10             	shr    $0x10,%eax
f01059bd:	3c 03                	cmp    $0x3,%al
f01059bf:	76 0f                	jbe    f01059d0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01059c1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01059c6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01059cb:	e8 1a ff ff ff       	call   f01058ea <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01059d0:	ba 33 00 00 00       	mov    $0x33,%edx
f01059d5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01059da:	e8 0b ff ff ff       	call   f01058ea <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01059df:	ba 00 00 00 00       	mov    $0x0,%edx
f01059e4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01059e9:	e8 fc fe ff ff       	call   f01058ea <lapicw>
	lapicw(ESR, 0);
f01059ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01059f3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01059f8:	e8 ed fe ff ff       	call   f01058ea <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01059fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a02:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105a07:	e8 de fe ff ff       	call   f01058ea <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105a0c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a11:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105a16:	e8 cf fe ff ff       	call   f01058ea <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105a1b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105a20:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105a25:	e8 c0 fe ff ff       	call   f01058ea <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105a2a:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105a30:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105a36:	f6 c4 10             	test   $0x10,%ah
f0105a39:	75 f5                	jne    f0105a30 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105a3b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a40:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a45:	e8 a0 fe ff ff       	call   f01058ea <lapicw>
}
f0105a4a:	c9                   	leave  
f0105a4b:	f3 c3                	repz ret 

f0105a4d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105a4d:	83 3d 04 d0 26 f0 00 	cmpl   $0x0,0xf026d004
f0105a54:	74 13                	je     f0105a69 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105a56:	55                   	push   %ebp
f0105a57:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105a59:	ba 00 00 00 00       	mov    $0x0,%edx
f0105a5e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105a63:	e8 82 fe ff ff       	call   f01058ea <lapicw>
}
f0105a68:	5d                   	pop    %ebp
f0105a69:	f3 c3                	repz ret 

f0105a6b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105a6b:	55                   	push   %ebp
f0105a6c:	89 e5                	mov    %esp,%ebp
f0105a6e:	56                   	push   %esi
f0105a6f:	53                   	push   %ebx
f0105a70:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105a76:	ba 70 00 00 00       	mov    $0x70,%edx
f0105a7b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105a80:	ee                   	out    %al,(%dx)
f0105a81:	ba 71 00 00 00       	mov    $0x71,%edx
f0105a86:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a8b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a8c:	83 3d 88 be 22 f0 00 	cmpl   $0x0,0xf022be88
f0105a93:	75 19                	jne    f0105aae <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105a95:	68 67 04 00 00       	push   $0x467
f0105a9a:	68 54 60 10 f0       	push   $0xf0106054
f0105a9f:	68 99 00 00 00       	push   $0x99
f0105aa4:	68 d8 7d 10 f0       	push   $0xf0107dd8
f0105aa9:	e8 e6 a5 ff ff       	call   f0100094 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105aae:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105ab5:	00 00 
	wrv[1] = addr >> 4;
f0105ab7:	89 d8                	mov    %ebx,%eax
f0105ab9:	c1 e8 04             	shr    $0x4,%eax
f0105abc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105ac2:	c1 e6 18             	shl    $0x18,%esi
f0105ac5:	89 f2                	mov    %esi,%edx
f0105ac7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105acc:	e8 19 fe ff ff       	call   f01058ea <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105ad1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105ad6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105adb:	e8 0a fe ff ff       	call   f01058ea <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105ae0:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105ae5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105aea:	e8 fb fd ff ff       	call   f01058ea <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105aef:	c1 eb 0c             	shr    $0xc,%ebx
f0105af2:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105af5:	89 f2                	mov    %esi,%edx
f0105af7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105afc:	e8 e9 fd ff ff       	call   f01058ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b01:	89 da                	mov    %ebx,%edx
f0105b03:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b08:	e8 dd fd ff ff       	call   f01058ea <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105b0d:	89 f2                	mov    %esi,%edx
f0105b0f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105b14:	e8 d1 fd ff ff       	call   f01058ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105b19:	89 da                	mov    %ebx,%edx
f0105b1b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b20:	e8 c5 fd ff ff       	call   f01058ea <lapicw>
		microdelay(200);
	}
}
f0105b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105b28:	5b                   	pop    %ebx
f0105b29:	5e                   	pop    %esi
f0105b2a:	5d                   	pop    %ebp
f0105b2b:	c3                   	ret    

f0105b2c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105b2c:	55                   	push   %ebp
f0105b2d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105b2f:	8b 55 08             	mov    0x8(%ebp),%edx
f0105b32:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105b38:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105b3d:	e8 a8 fd ff ff       	call   f01058ea <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105b42:	8b 15 04 d0 26 f0    	mov    0xf026d004,%edx
f0105b48:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105b4e:	f6 c4 10             	test   $0x10,%ah
f0105b51:	75 f5                	jne    f0105b48 <lapic_ipi+0x1c>
		;
}
f0105b53:	5d                   	pop    %ebp
f0105b54:	c3                   	ret    

f0105b55 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105b55:	55                   	push   %ebp
f0105b56:	89 e5                	mov    %esp,%ebp
f0105b58:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105b5b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105b61:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b64:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105b67:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105b6e:	5d                   	pop    %ebp
f0105b6f:	c3                   	ret    

f0105b70 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105b70:	55                   	push   %ebp
f0105b71:	89 e5                	mov    %esp,%ebp
f0105b73:	56                   	push   %esi
f0105b74:	53                   	push   %ebx
f0105b75:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105b78:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105b7b:	74 14                	je     f0105b91 <spin_lock+0x21>
f0105b7d:	8b 73 08             	mov    0x8(%ebx),%esi
f0105b80:	e8 7d fd ff ff       	call   f0105902 <cpunum>
f0105b85:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b88:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105b8d:	39 c6                	cmp    %eax,%esi
f0105b8f:	74 07                	je     f0105b98 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105b91:	ba 01 00 00 00       	mov    $0x1,%edx
f0105b96:	eb 20                	jmp    f0105bb8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105b98:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105b9b:	e8 62 fd ff ff       	call   f0105902 <cpunum>
f0105ba0:	83 ec 0c             	sub    $0xc,%esp
f0105ba3:	53                   	push   %ebx
f0105ba4:	50                   	push   %eax
f0105ba5:	68 e8 7d 10 f0       	push   $0xf0107de8
f0105baa:	6a 41                	push   $0x41
f0105bac:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0105bb1:	e8 de a4 ff ff       	call   f0100094 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105bb6:	f3 90                	pause  
f0105bb8:	89 d0                	mov    %edx,%eax
f0105bba:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105bbd:	85 c0                	test   %eax,%eax
f0105bbf:	75 f5                	jne    f0105bb6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105bc1:	e8 3c fd ff ff       	call   f0105902 <cpunum>
f0105bc6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bc9:	05 20 c0 22 f0       	add    $0xf022c020,%eax
f0105bce:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105bd1:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105bd4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105bd6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bdb:	eb 0b                	jmp    f0105be8 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105bdd:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105be0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105be3:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105be5:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105be8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105bee:	76 11                	jbe    f0105c01 <spin_lock+0x91>
f0105bf0:	83 f8 09             	cmp    $0x9,%eax
f0105bf3:	7e e8                	jle    f0105bdd <spin_lock+0x6d>
f0105bf5:	eb 0a                	jmp    f0105c01 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105bf7:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105bfe:	83 c0 01             	add    $0x1,%eax
f0105c01:	83 f8 09             	cmp    $0x9,%eax
f0105c04:	7e f1                	jle    f0105bf7 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105c06:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105c09:	5b                   	pop    %ebx
f0105c0a:	5e                   	pop    %esi
f0105c0b:	5d                   	pop    %ebp
f0105c0c:	c3                   	ret    

f0105c0d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105c0d:	55                   	push   %ebp
f0105c0e:	89 e5                	mov    %esp,%ebp
f0105c10:	57                   	push   %edi
f0105c11:	56                   	push   %esi
f0105c12:	53                   	push   %ebx
f0105c13:	83 ec 4c             	sub    $0x4c,%esp
f0105c16:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105c19:	83 3e 00             	cmpl   $0x0,(%esi)
f0105c1c:	74 18                	je     f0105c36 <spin_unlock+0x29>
f0105c1e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105c21:	e8 dc fc ff ff       	call   f0105902 <cpunum>
f0105c26:	6b c0 74             	imul   $0x74,%eax,%eax
f0105c29:	05 20 c0 22 f0       	add    $0xf022c020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105c2e:	39 c3                	cmp    %eax,%ebx
f0105c30:	0f 84 a5 00 00 00    	je     f0105cdb <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105c36:	83 ec 04             	sub    $0x4,%esp
f0105c39:	6a 28                	push   $0x28
f0105c3b:	8d 46 0c             	lea    0xc(%esi),%eax
f0105c3e:	50                   	push   %eax
f0105c3f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105c42:	53                   	push   %ebx
f0105c43:	e8 e6 f6 ff ff       	call   f010532e <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105c48:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105c4b:	0f b6 38             	movzbl (%eax),%edi
f0105c4e:	8b 76 04             	mov    0x4(%esi),%esi
f0105c51:	e8 ac fc ff ff       	call   f0105902 <cpunum>
f0105c56:	57                   	push   %edi
f0105c57:	56                   	push   %esi
f0105c58:	50                   	push   %eax
f0105c59:	68 14 7e 10 f0       	push   $0xf0107e14
f0105c5e:	e8 08 dc ff ff       	call   f010386b <cprintf>
f0105c63:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105c66:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105c69:	eb 54                	jmp    f0105cbf <spin_unlock+0xb2>
f0105c6b:	83 ec 08             	sub    $0x8,%esp
f0105c6e:	57                   	push   %edi
f0105c6f:	50                   	push   %eax
f0105c70:	e8 c3 ec ff ff       	call   f0104938 <debuginfo_eip>
f0105c75:	83 c4 10             	add    $0x10,%esp
f0105c78:	85 c0                	test   %eax,%eax
f0105c7a:	78 27                	js     f0105ca3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105c7c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105c7e:	83 ec 04             	sub    $0x4,%esp
f0105c81:	89 c2                	mov    %eax,%edx
f0105c83:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105c86:	52                   	push   %edx
f0105c87:	ff 75 b0             	pushl  -0x50(%ebp)
f0105c8a:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105c8d:	ff 75 ac             	pushl  -0x54(%ebp)
f0105c90:	ff 75 a8             	pushl  -0x58(%ebp)
f0105c93:	50                   	push   %eax
f0105c94:	68 5c 7e 10 f0       	push   $0xf0107e5c
f0105c99:	e8 cd db ff ff       	call   f010386b <cprintf>
f0105c9e:	83 c4 20             	add    $0x20,%esp
f0105ca1:	eb 12                	jmp    f0105cb5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105ca3:	83 ec 08             	sub    $0x8,%esp
f0105ca6:	ff 36                	pushl  (%esi)
f0105ca8:	68 73 7e 10 f0       	push   $0xf0107e73
f0105cad:	e8 b9 db ff ff       	call   f010386b <cprintf>
f0105cb2:	83 c4 10             	add    $0x10,%esp
f0105cb5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105cb8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105cbb:	39 c3                	cmp    %eax,%ebx
f0105cbd:	74 08                	je     f0105cc7 <spin_unlock+0xba>
f0105cbf:	89 de                	mov    %ebx,%esi
f0105cc1:	8b 03                	mov    (%ebx),%eax
f0105cc3:	85 c0                	test   %eax,%eax
f0105cc5:	75 a4                	jne    f0105c6b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105cc7:	83 ec 04             	sub    $0x4,%esp
f0105cca:	68 7b 7e 10 f0       	push   $0xf0107e7b
f0105ccf:	6a 67                	push   $0x67
f0105cd1:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0105cd6:	e8 b9 a3 ff ff       	call   f0100094 <_panic>
	}

	lk->pcs[0] = 0;
f0105cdb:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105ce2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105ce9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cee:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105cf1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105cf4:	5b                   	pop    %ebx
f0105cf5:	5e                   	pop    %esi
f0105cf6:	5f                   	pop    %edi
f0105cf7:	5d                   	pop    %ebp
f0105cf8:	c3                   	ret    
f0105cf9:	66 90                	xchg   %ax,%ax
f0105cfb:	66 90                	xchg   %ax,%ax
f0105cfd:	66 90                	xchg   %ax,%ax
f0105cff:	90                   	nop

f0105d00 <__udivdi3>:
f0105d00:	55                   	push   %ebp
f0105d01:	57                   	push   %edi
f0105d02:	56                   	push   %esi
f0105d03:	53                   	push   %ebx
f0105d04:	83 ec 1c             	sub    $0x1c,%esp
f0105d07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105d0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105d0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105d17:	85 f6                	test   %esi,%esi
f0105d19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105d1d:	89 ca                	mov    %ecx,%edx
f0105d1f:	89 f8                	mov    %edi,%eax
f0105d21:	75 3d                	jne    f0105d60 <__udivdi3+0x60>
f0105d23:	39 cf                	cmp    %ecx,%edi
f0105d25:	0f 87 c5 00 00 00    	ja     f0105df0 <__udivdi3+0xf0>
f0105d2b:	85 ff                	test   %edi,%edi
f0105d2d:	89 fd                	mov    %edi,%ebp
f0105d2f:	75 0b                	jne    f0105d3c <__udivdi3+0x3c>
f0105d31:	b8 01 00 00 00       	mov    $0x1,%eax
f0105d36:	31 d2                	xor    %edx,%edx
f0105d38:	f7 f7                	div    %edi
f0105d3a:	89 c5                	mov    %eax,%ebp
f0105d3c:	89 c8                	mov    %ecx,%eax
f0105d3e:	31 d2                	xor    %edx,%edx
f0105d40:	f7 f5                	div    %ebp
f0105d42:	89 c1                	mov    %eax,%ecx
f0105d44:	89 d8                	mov    %ebx,%eax
f0105d46:	89 cf                	mov    %ecx,%edi
f0105d48:	f7 f5                	div    %ebp
f0105d4a:	89 c3                	mov    %eax,%ebx
f0105d4c:	89 d8                	mov    %ebx,%eax
f0105d4e:	89 fa                	mov    %edi,%edx
f0105d50:	83 c4 1c             	add    $0x1c,%esp
f0105d53:	5b                   	pop    %ebx
f0105d54:	5e                   	pop    %esi
f0105d55:	5f                   	pop    %edi
f0105d56:	5d                   	pop    %ebp
f0105d57:	c3                   	ret    
f0105d58:	90                   	nop
f0105d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105d60:	39 ce                	cmp    %ecx,%esi
f0105d62:	77 74                	ja     f0105dd8 <__udivdi3+0xd8>
f0105d64:	0f bd fe             	bsr    %esi,%edi
f0105d67:	83 f7 1f             	xor    $0x1f,%edi
f0105d6a:	0f 84 98 00 00 00    	je     f0105e08 <__udivdi3+0x108>
f0105d70:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105d75:	89 f9                	mov    %edi,%ecx
f0105d77:	89 c5                	mov    %eax,%ebp
f0105d79:	29 fb                	sub    %edi,%ebx
f0105d7b:	d3 e6                	shl    %cl,%esi
f0105d7d:	89 d9                	mov    %ebx,%ecx
f0105d7f:	d3 ed                	shr    %cl,%ebp
f0105d81:	89 f9                	mov    %edi,%ecx
f0105d83:	d3 e0                	shl    %cl,%eax
f0105d85:	09 ee                	or     %ebp,%esi
f0105d87:	89 d9                	mov    %ebx,%ecx
f0105d89:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105d8d:	89 d5                	mov    %edx,%ebp
f0105d8f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d93:	d3 ed                	shr    %cl,%ebp
f0105d95:	89 f9                	mov    %edi,%ecx
f0105d97:	d3 e2                	shl    %cl,%edx
f0105d99:	89 d9                	mov    %ebx,%ecx
f0105d9b:	d3 e8                	shr    %cl,%eax
f0105d9d:	09 c2                	or     %eax,%edx
f0105d9f:	89 d0                	mov    %edx,%eax
f0105da1:	89 ea                	mov    %ebp,%edx
f0105da3:	f7 f6                	div    %esi
f0105da5:	89 d5                	mov    %edx,%ebp
f0105da7:	89 c3                	mov    %eax,%ebx
f0105da9:	f7 64 24 0c          	mull   0xc(%esp)
f0105dad:	39 d5                	cmp    %edx,%ebp
f0105daf:	72 10                	jb     f0105dc1 <__udivdi3+0xc1>
f0105db1:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105db5:	89 f9                	mov    %edi,%ecx
f0105db7:	d3 e6                	shl    %cl,%esi
f0105db9:	39 c6                	cmp    %eax,%esi
f0105dbb:	73 07                	jae    f0105dc4 <__udivdi3+0xc4>
f0105dbd:	39 d5                	cmp    %edx,%ebp
f0105dbf:	75 03                	jne    f0105dc4 <__udivdi3+0xc4>
f0105dc1:	83 eb 01             	sub    $0x1,%ebx
f0105dc4:	31 ff                	xor    %edi,%edi
f0105dc6:	89 d8                	mov    %ebx,%eax
f0105dc8:	89 fa                	mov    %edi,%edx
f0105dca:	83 c4 1c             	add    $0x1c,%esp
f0105dcd:	5b                   	pop    %ebx
f0105dce:	5e                   	pop    %esi
f0105dcf:	5f                   	pop    %edi
f0105dd0:	5d                   	pop    %ebp
f0105dd1:	c3                   	ret    
f0105dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105dd8:	31 ff                	xor    %edi,%edi
f0105dda:	31 db                	xor    %ebx,%ebx
f0105ddc:	89 d8                	mov    %ebx,%eax
f0105dde:	89 fa                	mov    %edi,%edx
f0105de0:	83 c4 1c             	add    $0x1c,%esp
f0105de3:	5b                   	pop    %ebx
f0105de4:	5e                   	pop    %esi
f0105de5:	5f                   	pop    %edi
f0105de6:	5d                   	pop    %ebp
f0105de7:	c3                   	ret    
f0105de8:	90                   	nop
f0105de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105df0:	89 d8                	mov    %ebx,%eax
f0105df2:	f7 f7                	div    %edi
f0105df4:	31 ff                	xor    %edi,%edi
f0105df6:	89 c3                	mov    %eax,%ebx
f0105df8:	89 d8                	mov    %ebx,%eax
f0105dfa:	89 fa                	mov    %edi,%edx
f0105dfc:	83 c4 1c             	add    $0x1c,%esp
f0105dff:	5b                   	pop    %ebx
f0105e00:	5e                   	pop    %esi
f0105e01:	5f                   	pop    %edi
f0105e02:	5d                   	pop    %ebp
f0105e03:	c3                   	ret    
f0105e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105e08:	39 ce                	cmp    %ecx,%esi
f0105e0a:	72 0c                	jb     f0105e18 <__udivdi3+0x118>
f0105e0c:	31 db                	xor    %ebx,%ebx
f0105e0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105e12:	0f 87 34 ff ff ff    	ja     f0105d4c <__udivdi3+0x4c>
f0105e18:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105e1d:	e9 2a ff ff ff       	jmp    f0105d4c <__udivdi3+0x4c>
f0105e22:	66 90                	xchg   %ax,%ax
f0105e24:	66 90                	xchg   %ax,%ax
f0105e26:	66 90                	xchg   %ax,%ax
f0105e28:	66 90                	xchg   %ax,%ax
f0105e2a:	66 90                	xchg   %ax,%ax
f0105e2c:	66 90                	xchg   %ax,%ax
f0105e2e:	66 90                	xchg   %ax,%ax

f0105e30 <__umoddi3>:
f0105e30:	55                   	push   %ebp
f0105e31:	57                   	push   %edi
f0105e32:	56                   	push   %esi
f0105e33:	53                   	push   %ebx
f0105e34:	83 ec 1c             	sub    $0x1c,%esp
f0105e37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105e3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105e3f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105e47:	85 d2                	test   %edx,%edx
f0105e49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105e51:	89 f3                	mov    %esi,%ebx
f0105e53:	89 3c 24             	mov    %edi,(%esp)
f0105e56:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e5a:	75 1c                	jne    f0105e78 <__umoddi3+0x48>
f0105e5c:	39 f7                	cmp    %esi,%edi
f0105e5e:	76 50                	jbe    f0105eb0 <__umoddi3+0x80>
f0105e60:	89 c8                	mov    %ecx,%eax
f0105e62:	89 f2                	mov    %esi,%edx
f0105e64:	f7 f7                	div    %edi
f0105e66:	89 d0                	mov    %edx,%eax
f0105e68:	31 d2                	xor    %edx,%edx
f0105e6a:	83 c4 1c             	add    $0x1c,%esp
f0105e6d:	5b                   	pop    %ebx
f0105e6e:	5e                   	pop    %esi
f0105e6f:	5f                   	pop    %edi
f0105e70:	5d                   	pop    %ebp
f0105e71:	c3                   	ret    
f0105e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105e78:	39 f2                	cmp    %esi,%edx
f0105e7a:	89 d0                	mov    %edx,%eax
f0105e7c:	77 52                	ja     f0105ed0 <__umoddi3+0xa0>
f0105e7e:	0f bd ea             	bsr    %edx,%ebp
f0105e81:	83 f5 1f             	xor    $0x1f,%ebp
f0105e84:	75 5a                	jne    f0105ee0 <__umoddi3+0xb0>
f0105e86:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105e8a:	0f 82 e0 00 00 00    	jb     f0105f70 <__umoddi3+0x140>
f0105e90:	39 0c 24             	cmp    %ecx,(%esp)
f0105e93:	0f 86 d7 00 00 00    	jbe    f0105f70 <__umoddi3+0x140>
f0105e99:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105e9d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105ea1:	83 c4 1c             	add    $0x1c,%esp
f0105ea4:	5b                   	pop    %ebx
f0105ea5:	5e                   	pop    %esi
f0105ea6:	5f                   	pop    %edi
f0105ea7:	5d                   	pop    %ebp
f0105ea8:	c3                   	ret    
f0105ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105eb0:	85 ff                	test   %edi,%edi
f0105eb2:	89 fd                	mov    %edi,%ebp
f0105eb4:	75 0b                	jne    f0105ec1 <__umoddi3+0x91>
f0105eb6:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ebb:	31 d2                	xor    %edx,%edx
f0105ebd:	f7 f7                	div    %edi
f0105ebf:	89 c5                	mov    %eax,%ebp
f0105ec1:	89 f0                	mov    %esi,%eax
f0105ec3:	31 d2                	xor    %edx,%edx
f0105ec5:	f7 f5                	div    %ebp
f0105ec7:	89 c8                	mov    %ecx,%eax
f0105ec9:	f7 f5                	div    %ebp
f0105ecb:	89 d0                	mov    %edx,%eax
f0105ecd:	eb 99                	jmp    f0105e68 <__umoddi3+0x38>
f0105ecf:	90                   	nop
f0105ed0:	89 c8                	mov    %ecx,%eax
f0105ed2:	89 f2                	mov    %esi,%edx
f0105ed4:	83 c4 1c             	add    $0x1c,%esp
f0105ed7:	5b                   	pop    %ebx
f0105ed8:	5e                   	pop    %esi
f0105ed9:	5f                   	pop    %edi
f0105eda:	5d                   	pop    %ebp
f0105edb:	c3                   	ret    
f0105edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105ee0:	8b 34 24             	mov    (%esp),%esi
f0105ee3:	bf 20 00 00 00       	mov    $0x20,%edi
f0105ee8:	89 e9                	mov    %ebp,%ecx
f0105eea:	29 ef                	sub    %ebp,%edi
f0105eec:	d3 e0                	shl    %cl,%eax
f0105eee:	89 f9                	mov    %edi,%ecx
f0105ef0:	89 f2                	mov    %esi,%edx
f0105ef2:	d3 ea                	shr    %cl,%edx
f0105ef4:	89 e9                	mov    %ebp,%ecx
f0105ef6:	09 c2                	or     %eax,%edx
f0105ef8:	89 d8                	mov    %ebx,%eax
f0105efa:	89 14 24             	mov    %edx,(%esp)
f0105efd:	89 f2                	mov    %esi,%edx
f0105eff:	d3 e2                	shl    %cl,%edx
f0105f01:	89 f9                	mov    %edi,%ecx
f0105f03:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105f07:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105f0b:	d3 e8                	shr    %cl,%eax
f0105f0d:	89 e9                	mov    %ebp,%ecx
f0105f0f:	89 c6                	mov    %eax,%esi
f0105f11:	d3 e3                	shl    %cl,%ebx
f0105f13:	89 f9                	mov    %edi,%ecx
f0105f15:	89 d0                	mov    %edx,%eax
f0105f17:	d3 e8                	shr    %cl,%eax
f0105f19:	89 e9                	mov    %ebp,%ecx
f0105f1b:	09 d8                	or     %ebx,%eax
f0105f1d:	89 d3                	mov    %edx,%ebx
f0105f1f:	89 f2                	mov    %esi,%edx
f0105f21:	f7 34 24             	divl   (%esp)
f0105f24:	89 d6                	mov    %edx,%esi
f0105f26:	d3 e3                	shl    %cl,%ebx
f0105f28:	f7 64 24 04          	mull   0x4(%esp)
f0105f2c:	39 d6                	cmp    %edx,%esi
f0105f2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f32:	89 d1                	mov    %edx,%ecx
f0105f34:	89 c3                	mov    %eax,%ebx
f0105f36:	72 08                	jb     f0105f40 <__umoddi3+0x110>
f0105f38:	75 11                	jne    f0105f4b <__umoddi3+0x11b>
f0105f3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105f3e:	73 0b                	jae    f0105f4b <__umoddi3+0x11b>
f0105f40:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105f44:	1b 14 24             	sbb    (%esp),%edx
f0105f47:	89 d1                	mov    %edx,%ecx
f0105f49:	89 c3                	mov    %eax,%ebx
f0105f4b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105f4f:	29 da                	sub    %ebx,%edx
f0105f51:	19 ce                	sbb    %ecx,%esi
f0105f53:	89 f9                	mov    %edi,%ecx
f0105f55:	89 f0                	mov    %esi,%eax
f0105f57:	d3 e0                	shl    %cl,%eax
f0105f59:	89 e9                	mov    %ebp,%ecx
f0105f5b:	d3 ea                	shr    %cl,%edx
f0105f5d:	89 e9                	mov    %ebp,%ecx
f0105f5f:	d3 ee                	shr    %cl,%esi
f0105f61:	09 d0                	or     %edx,%eax
f0105f63:	89 f2                	mov    %esi,%edx
f0105f65:	83 c4 1c             	add    $0x1c,%esp
f0105f68:	5b                   	pop    %ebx
f0105f69:	5e                   	pop    %esi
f0105f6a:	5f                   	pop    %edi
f0105f6b:	5d                   	pop    %ebp
f0105f6c:	c3                   	ret    
f0105f6d:	8d 76 00             	lea    0x0(%esi),%esi
f0105f70:	29 f9                	sub    %edi,%ecx
f0105f72:	19 d6                	sbb    %edx,%esi
f0105f74:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105f7c:	e9 18 ff ff ff       	jmp    f0105e99 <__umoddi3+0x69>
