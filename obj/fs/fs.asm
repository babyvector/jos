
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 42 1a 00 00       	call   801a73 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 80 38 80 00       	push   $0x803880
  8000b7:	e8 f0 1a 00 00       	call   801bac <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 97 38 80 00       	push   $0x803897
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 a7 38 80 00       	push   $0x8038a7
  8000e0:	e8 ee 19 00 00       	call   801ad3 <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 b0 38 80 00       	push   $0x8038b0
  80010b:	68 bd 38 80 00       	push   $0x8038bd
  800110:	6a 44                	push   $0x44
  800112:	68 a7 38 80 00       	push   $0x8038a7
  800117:	e8 b7 19 00 00       	call   801ad3 <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 b0 38 80 00       	push   $0x8038b0
  8001cf:	68 bd 38 80 00       	push   $0x8038bd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 a7 38 80 00       	push   $0x8038a7
  8001db:	e8 f3 18 00 00       	call   801ad3 <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 d4 38 80 00       	push   $0x8038d4
  80029f:	6a 27                	push   $0x27
  8002a1:	68 e0 39 80 00       	push   $0x8039e0
  8002a6:	e8 28 18 00 00       	call   801ad3 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 04 39 80 00       	push   $0x803904
  8002bf:	6a 2b                	push   $0x2b
  8002c1:	68 e0 39 80 00       	push   $0x8039e0
  8002c6:	e8 08 18 00 00       	call   801ad3 <_panic>
	// the disk.
	//
	// LAB 5: you code here:


	addr = ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, addr, PTE_W|PTE_U|PTE_P);
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 a0 22 00 00       	call   80257e <sys_page_alloc>
	if((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS))<0)
  8002de:	83 c4 0c             	add    $0xc,%esp
  8002e1:	6a 08                	push   $0x8
  8002e3:	53                   	push   %ebx
  8002e4:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8002eb:	50                   	push   %eax
  8002ec:	e8 fb fd ff ff       	call   8000ec <ide_read>
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	79 12                	jns    80030a <bc_pgfault+0x96>
		panic("ide_read:%e", r);
  8002f8:	50                   	push   %eax
  8002f9:	68 e8 39 80 00       	push   $0x8039e8
  8002fe:	6a 38                	push   $0x38
  800300:	68 e0 39 80 00       	push   $0x8039e0
  800305:	e8 c9 17 00 00       	call   801ad3 <_panic>


	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80030a:	89 d8                	mov    %ebx,%eax
  80030c:	c1 e8 0c             	shr    $0xc,%eax
  80030f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800316:	83 ec 0c             	sub    $0xc,%esp
  800319:	25 07 0e 00 00       	and    $0xe07,%eax
  80031e:	50                   	push   %eax
  80031f:	53                   	push   %ebx
  800320:	6a 00                	push   $0x0
  800322:	53                   	push   %ebx
  800323:	6a 00                	push   $0x0
  800325:	e8 97 22 00 00       	call   8025c1 <sys_page_map>
  80032a:	83 c4 20             	add    $0x20,%esp
  80032d:	85 c0                	test   %eax,%eax
  80032f:	79 12                	jns    800343 <bc_pgfault+0xcf>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800331:	50                   	push   %eax
  800332:	68 28 39 80 00       	push   $0x803928
  800337:	6a 3e                	push   $0x3e
  800339:	68 e0 39 80 00       	push   $0x8039e0
  80033e:	e8 90 17 00 00       	call   801ad3 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800343:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  80034a:	74 22                	je     80036e <bc_pgfault+0xfa>
  80034c:	83 ec 0c             	sub    $0xc,%esp
  80034f:	56                   	push   %esi
  800350:	e8 8e 04 00 00       	call   8007e3 <block_is_free>
  800355:	83 c4 10             	add    $0x10,%esp
  800358:	84 c0                	test   %al,%al
  80035a:	74 12                	je     80036e <bc_pgfault+0xfa>
		panic("reading free block %08x\n", blockno);
  80035c:	56                   	push   %esi
  80035d:	68 f4 39 80 00       	push   $0x8039f4
  800362:	6a 44                	push   $0x44
  800364:	68 e0 39 80 00       	push   $0x8039e0
  800369:	e8 65 17 00 00       	call   801ad3 <_panic>
}
  80036e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80037e:	85 c0                	test   %eax,%eax
  800380:	74 0f                	je     800391 <diskaddr+0x1c>
  800382:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800388:	85 d2                	test   %edx,%edx
  80038a:	74 17                	je     8003a3 <diskaddr+0x2e>
  80038c:	3b 42 04             	cmp    0x4(%edx),%eax
  80038f:	72 12                	jb     8003a3 <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800391:	50                   	push   %eax
  800392:	68 48 39 80 00       	push   $0x803948
  800397:	6a 09                	push   $0x9
  800399:	68 e0 39 80 00       	push   $0x8039e0
  80039e:	e8 30 17 00 00       	call   801ad3 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003a3:	05 00 00 01 00       	add    $0x10000,%eax
  8003a8:	c1 e0 0c             	shl    $0xc,%eax
}
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    

008003ad <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003b3:	89 d0                	mov    %edx,%eax
  8003b5:	c1 e8 16             	shr    $0x16,%eax
  8003b8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c4:	f6 c1 01             	test   $0x1,%cl
  8003c7:	74 0d                	je     8003d6 <va_is_mapped+0x29>
  8003c9:	c1 ea 0c             	shr    $0xc,%edx
  8003cc:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003d3:	83 e0 01             	and    $0x1,%eax
  8003d6:	83 e0 01             	and    $0x1,%eax
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	c1 e8 0c             	shr    $0xc,%eax
  8003e4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003eb:	c1 e8 06             	shr    $0x6,%eax
  8003ee:	83 e0 01             	and    $0x1,%eax
}
  8003f1:	5d                   	pop    %ebp
  8003f2:	c3                   	ret    

008003f3 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8003fb:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800401:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800406:	76 12                	jbe    80041a <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800408:	53                   	push   %ebx
  800409:	68 0d 3a 80 00       	push   $0x803a0d
  80040e:	6a 54                	push   $0x54
  800410:	68 e0 39 80 00       	push   $0x8039e0
  800415:	e8 b9 16 00 00       	call   801ad3 <_panic>

	// LAB 5: Your code here.
//	panic("flush_block not implemented");
	addr = ROUNDDOWN(addr, PGSIZE);
  80041a:	89 de                	mov    %ebx,%esi
  80041c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if(!va_is_mapped(addr) || !va_is_dirty(addr))
  800422:	83 ec 0c             	sub    $0xc,%esp
  800425:	56                   	push   %esi
  800426:	e8 82 ff ff ff       	call   8003ad <va_is_mapped>
  80042b:	83 c4 10             	add    $0x10,%esp
  80042e:	84 c0                	test   %al,%al
  800430:	74 7a                	je     8004ac <flush_block+0xb9>
  800432:	83 ec 0c             	sub    $0xc,%esp
  800435:	56                   	push   %esi
  800436:	e8 a0 ff ff ff       	call   8003db <va_is_dirty>
  80043b:	83 c4 10             	add    $0x10,%esp
  80043e:	84 c0                	test   %al,%al
  800440:	74 6a                	je     8004ac <flush_block+0xb9>
	{
		return ;
	}
	int r;
	if((r = ide_write(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  800442:	83 ec 04             	sub    $0x4,%esp
  800445:	6a 08                	push   $0x8
  800447:	56                   	push   %esi
  800448:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  80044e:	c1 eb 0c             	shr    $0xc,%ebx
  800451:	c1 e3 03             	shl    $0x3,%ebx
  800454:	53                   	push   %ebx
  800455:	e8 56 fd ff ff       	call   8001b0 <ide_write>
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	85 c0                	test   %eax,%eax
  80045f:	79 12                	jns    800473 <flush_block+0x80>
	{
		panic("panic bc.c/flush_block, ide_write():%e", r);
  800461:	50                   	push   %eax
  800462:	68 6c 39 80 00       	push   $0x80396c
  800467:	6a 60                	push   $0x60
  800469:	68 e0 39 80 00       	push   $0x8039e0
  80046e:	e8 60 16 00 00       	call   801ad3 <_panic>
	}
	
	if( (r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)]&PTE_SYSCALL))<0)
  800473:	89 f0                	mov    %esi,%eax
  800475:	c1 e8 0c             	shr    $0xc,%eax
  800478:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80047f:	83 ec 0c             	sub    $0xc,%esp
  800482:	25 07 0e 00 00       	and    $0xe07,%eax
  800487:	50                   	push   %eax
  800488:	56                   	push   %esi
  800489:	6a 00                	push   $0x0
  80048b:	56                   	push   %esi
  80048c:	6a 00                	push   $0x0
  80048e:	e8 2e 21 00 00       	call   8025c1 <sys_page_map>
  800493:	83 c4 20             	add    $0x20,%esp
  800496:	85 c0                	test   %eax,%eax
  800498:	79 12                	jns    8004ac <flush_block+0xb9>
		panic("panic bc.c/flush_block, sys_page_map:%e", r);
  80049a:	50                   	push   %eax
  80049b:	68 94 39 80 00       	push   $0x803994
  8004a0:	6a 64                	push   $0x64
  8004a2:	68 e0 39 80 00       	push   $0x8039e0
  8004a7:	e8 27 16 00 00       	call   801ad3 <_panic>
}
  8004ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004af:	5b                   	pop    %ebx
  8004b0:	5e                   	pop    %esi
  8004b1:	5d                   	pop    %ebp
  8004b2:	c3                   	ret    

008004b3 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
  8004b6:	53                   	push   %ebx
  8004b7:	81 ec 20 02 00 00    	sub    $0x220,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004bd:	68 74 02 80 00       	push   $0x800274
  8004c2:	e8 a8 22 00 00       	call   80276f <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004c7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ce:	e8 a2 fe ff ff       	call   800375 <diskaddr>
  8004d3:	83 c4 0c             	add    $0xc,%esp
  8004d6:	68 08 01 00 00       	push   $0x108
  8004db:	50                   	push   %eax
  8004dc:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004e2:	50                   	push   %eax
  8004e3:	e8 25 1e 00 00       	call   80230d <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ef:	e8 81 fe ff ff       	call   800375 <diskaddr>
  8004f4:	83 c4 08             	add    $0x8,%esp
  8004f7:	68 28 3a 80 00       	push   $0x803a28
  8004fc:	50                   	push   %eax
  8004fd:	e8 79 1c 00 00       	call   80217b <strcpy>
	flush_block(diskaddr(1));
  800502:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800509:	e8 67 fe ff ff       	call   800375 <diskaddr>
  80050e:	89 04 24             	mov    %eax,(%esp)
  800511:	e8 dd fe ff ff       	call   8003f3 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800516:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051d:	e8 53 fe ff ff       	call   800375 <diskaddr>
  800522:	89 04 24             	mov    %eax,(%esp)
  800525:	e8 83 fe ff ff       	call   8003ad <va_is_mapped>
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	84 c0                	test   %al,%al
  80052f:	75 16                	jne    800547 <bc_init+0x94>
  800531:	68 4a 3a 80 00       	push   $0x803a4a
  800536:	68 bd 38 80 00       	push   $0x8038bd
  80053b:	6a 74                	push   $0x74
  80053d:	68 e0 39 80 00       	push   $0x8039e0
  800542:	e8 8c 15 00 00       	call   801ad3 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800547:	83 ec 0c             	sub    $0xc,%esp
  80054a:	6a 01                	push   $0x1
  80054c:	e8 24 fe ff ff       	call   800375 <diskaddr>
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	e8 82 fe ff ff       	call   8003db <va_is_dirty>
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	84 c0                	test   %al,%al
  80055e:	74 16                	je     800576 <bc_init+0xc3>
  800560:	68 2f 3a 80 00       	push   $0x803a2f
  800565:	68 bd 38 80 00       	push   $0x8038bd
  80056a:	6a 75                	push   $0x75
  80056c:	68 e0 39 80 00       	push   $0x8039e0
  800571:	e8 5d 15 00 00       	call   801ad3 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800576:	83 ec 0c             	sub    $0xc,%esp
  800579:	6a 01                	push   $0x1
  80057b:	e8 f5 fd ff ff       	call   800375 <diskaddr>
  800580:	83 c4 08             	add    $0x8,%esp
  800583:	50                   	push   %eax
  800584:	6a 00                	push   $0x0
  800586:	e8 78 20 00 00       	call   802603 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80058b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800592:	e8 de fd ff ff       	call   800375 <diskaddr>
  800597:	89 04 24             	mov    %eax,(%esp)
  80059a:	e8 0e fe ff ff       	call   8003ad <va_is_mapped>
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	84 c0                	test   %al,%al
  8005a4:	74 16                	je     8005bc <bc_init+0x109>
  8005a6:	68 49 3a 80 00       	push   $0x803a49
  8005ab:	68 bd 38 80 00       	push   $0x8038bd
  8005b0:	6a 79                	push   $0x79
  8005b2:	68 e0 39 80 00       	push   $0x8039e0
  8005b7:	e8 17 15 00 00       	call   801ad3 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005bc:	83 ec 0c             	sub    $0xc,%esp
  8005bf:	6a 01                	push   $0x1
  8005c1:	e8 af fd ff ff       	call   800375 <diskaddr>
  8005c6:	83 c4 08             	add    $0x8,%esp
  8005c9:	68 28 3a 80 00       	push   $0x803a28
  8005ce:	50                   	push   %eax
  8005cf:	e8 51 1c 00 00       	call   802225 <strcmp>
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	74 16                	je     8005f1 <bc_init+0x13e>
  8005db:	68 bc 39 80 00       	push   $0x8039bc
  8005e0:	68 bd 38 80 00       	push   $0x8038bd
  8005e5:	6a 7c                	push   $0x7c
  8005e7:	68 e0 39 80 00       	push   $0x8039e0
  8005ec:	e8 e2 14 00 00       	call   801ad3 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	6a 01                	push   $0x1
  8005f6:	e8 7a fd ff ff       	call   800375 <diskaddr>
  8005fb:	83 c4 0c             	add    $0xc,%esp
  8005fe:	68 08 01 00 00       	push   $0x108
  800603:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800609:	53                   	push   %ebx
  80060a:	50                   	push   %eax
  80060b:	e8 fd 1c 00 00       	call   80230d <memmove>
	flush_block(diskaddr(1));
  800610:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800617:	e8 59 fd ff ff       	call   800375 <diskaddr>
  80061c:	89 04 24             	mov    %eax,(%esp)
  80061f:	e8 cf fd ff ff       	call   8003f3 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800624:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062b:	e8 45 fd ff ff       	call   800375 <diskaddr>
  800630:	83 c4 0c             	add    $0xc,%esp
  800633:	68 08 01 00 00       	push   $0x108
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 ce 1c 00 00       	call   80230d <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80063f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800646:	e8 2a fd ff ff       	call   800375 <diskaddr>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	68 28 3a 80 00       	push   $0x803a28
  800653:	50                   	push   %eax
  800654:	e8 22 1b 00 00       	call   80217b <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800659:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800660:	e8 10 fd ff ff       	call   800375 <diskaddr>
  800665:	83 c0 14             	add    $0x14,%eax
  800668:	89 04 24             	mov    %eax,(%esp)
  80066b:	e8 83 fd ff ff       	call   8003f3 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800670:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800677:	e8 f9 fc ff ff       	call   800375 <diskaddr>
  80067c:	89 04 24             	mov    %eax,(%esp)
  80067f:	e8 29 fd ff ff       	call   8003ad <va_is_mapped>
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	84 c0                	test   %al,%al
  800689:	75 19                	jne    8006a4 <bc_init+0x1f1>
  80068b:	68 4a 3a 80 00       	push   $0x803a4a
  800690:	68 bd 38 80 00       	push   $0x8038bd
  800695:	68 8d 00 00 00       	push   $0x8d
  80069a:	68 e0 39 80 00       	push   $0x8039e0
  80069f:	e8 2f 14 00 00       	call   801ad3 <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	6a 01                	push   $0x1
  8006a9:	e8 c7 fc ff ff       	call   800375 <diskaddr>
  8006ae:	83 c4 08             	add    $0x8,%esp
  8006b1:	50                   	push   %eax
  8006b2:	6a 00                	push   $0x0
  8006b4:	e8 4a 1f 00 00       	call   802603 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8006b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006c0:	e8 b0 fc ff ff       	call   800375 <diskaddr>
  8006c5:	89 04 24             	mov    %eax,(%esp)
  8006c8:	e8 e0 fc ff ff       	call   8003ad <va_is_mapped>
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	84 c0                	test   %al,%al
  8006d2:	74 19                	je     8006ed <bc_init+0x23a>
  8006d4:	68 49 3a 80 00       	push   $0x803a49
  8006d9:	68 bd 38 80 00       	push   $0x8038bd
  8006de:	68 95 00 00 00       	push   $0x95
  8006e3:	68 e0 39 80 00       	push   $0x8039e0
  8006e8:	e8 e6 13 00 00       	call   801ad3 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	6a 01                	push   $0x1
  8006f2:	e8 7e fc ff ff       	call   800375 <diskaddr>
  8006f7:	83 c4 08             	add    $0x8,%esp
  8006fa:	68 28 3a 80 00       	push   $0x803a28
  8006ff:	50                   	push   %eax
  800700:	e8 20 1b 00 00       	call   802225 <strcmp>
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 19                	je     800725 <bc_init+0x272>
  80070c:	68 bc 39 80 00       	push   $0x8039bc
  800711:	68 bd 38 80 00       	push   $0x8038bd
  800716:	68 98 00 00 00       	push   $0x98
  80071b:	68 e0 39 80 00       	push   $0x8039e0
  800720:	e8 ae 13 00 00       	call   801ad3 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800725:	83 ec 0c             	sub    $0xc,%esp
  800728:	6a 01                	push   $0x1
  80072a:	e8 46 fc ff ff       	call   800375 <diskaddr>
  80072f:	83 c4 0c             	add    $0xc,%esp
  800732:	68 08 01 00 00       	push   $0x108
  800737:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80073d:	52                   	push   %edx
  80073e:	50                   	push   %eax
  80073f:	e8 c9 1b 00 00       	call   80230d <memmove>
	flush_block(diskaddr(1));
  800744:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80074b:	e8 25 fc ff ff       	call   800375 <diskaddr>
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	e8 9b fc ff ff       	call   8003f3 <flush_block>

	cprintf("block cache is good\n");
  800758:	c7 04 24 64 3a 80 00 	movl   $0x803a64,(%esp)
  80075f:	e8 48 14 00 00       	call   801bac <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800764:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80076b:	e8 05 fc ff ff       	call   800375 <diskaddr>
  800770:	83 c4 0c             	add    $0xc,%esp
  800773:	68 08 01 00 00       	push   $0x108
  800778:	50                   	push   %eax
  800779:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	e8 88 1b 00 00       	call   80230d <memmove>
}
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  800793:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800798:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  80079e:	74 14                	je     8007b4 <check_super+0x27>
		panic("bad file system magic number");
  8007a0:	83 ec 04             	sub    $0x4,%esp
  8007a3:	68 79 3a 80 00       	push   $0x803a79
  8007a8:	6a 0f                	push   $0xf
  8007aa:	68 96 3a 80 00       	push   $0x803a96
  8007af:	e8 1f 13 00 00       	call   801ad3 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8007b4:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8007bb:	76 14                	jbe    8007d1 <check_super+0x44>
		panic("file system is too large");
  8007bd:	83 ec 04             	sub    $0x4,%esp
  8007c0:	68 9e 3a 80 00       	push   $0x803a9e
  8007c5:	6a 12                	push   $0x12
  8007c7:	68 96 3a 80 00       	push   $0x803a96
  8007cc:	e8 02 13 00 00       	call   801ad3 <_panic>

	cprintf("superblock is good\n");
  8007d1:	83 ec 0c             	sub    $0xc,%esp
  8007d4:	68 b7 3a 80 00       	push   $0x803ab7
  8007d9:	e8 ce 13 00 00       	call   801bac <cprintf>
}
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8007ea:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8007f0:	85 d2                	test   %edx,%edx
  8007f2:	74 24                	je     800818 <block_is_free+0x35>
		return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8007f9:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8007fc:	76 1f                	jbe    80081d <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8007fe:	89 cb                	mov    %ecx,%ebx
  800800:	c1 eb 05             	shr    $0x5,%ebx
  800803:	b8 01 00 00 00       	mov    $0x1,%eax
  800808:	d3 e0                	shl    %cl,%eax
  80080a:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800810:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  800813:	0f 95 c0             	setne  %al
  800816:	eb 05                	jmp    80081d <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	83 ec 04             	sub    $0x4,%esp
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  80082a:	85 c9                	test   %ecx,%ecx
  80082c:	75 14                	jne    800842 <free_block+0x22>
		panic("attempt to free zero block");
  80082e:	83 ec 04             	sub    $0x4,%esp
  800831:	68 cb 3a 80 00       	push   $0x803acb
  800836:	6a 2d                	push   $0x2d
  800838:	68 96 3a 80 00       	push   $0x803a96
  80083d:	e8 91 12 00 00       	call   801ad3 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800842:	89 cb                	mov    %ecx,%ebx
  800844:	c1 eb 05             	shr    $0x5,%ebx
  800847:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80084d:	b8 01 00 00 00       	mov    $0x1,%eax
  800852:	d3 e0                	shl    %cl,%eax
  800854:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800857:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085a:	c9                   	leave  
  80085b:	c3                   	ret    

0080085c <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	56                   	push   %esi
  800860:	53                   	push   %ebx
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	uint32_t bmpblock_start = 2;
	for(uint32_t blockno = 0; blockno < super->s_nblocks; blockno++)
  800861:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800866:	8b 70 04             	mov    0x4(%eax),%esi
  800869:	bb 00 00 00 00       	mov    $0x0,%ebx
  80086e:	eb 49                	jmp    8008b9 <alloc_block+0x5d>
	{
		if(block_is_free(blockno))
  800870:	53                   	push   %ebx
  800871:	e8 6d ff ff ff       	call   8007e3 <block_is_free>
  800876:	83 c4 04             	add    $0x4,%esp
  800879:	84 c0                	test   %al,%al
  80087b:	74 39                	je     8008b6 <alloc_block+0x5a>
		{
			bitmap[blockno/32] &= ~(1<<(blockno%32));
  80087d:	89 de                	mov    %ebx,%esi
  80087f:	c1 ee 05             	shr    $0x5,%esi
  800882:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800888:	b8 01 00 00 00       	mov    $0x1,%eax
  80088d:	89 d9                	mov    %ebx,%ecx
  80088f:	d3 e0                	shl    %cl,%eax
  800891:	f7 d0                	not    %eax
  800893:	21 04 b2             	and    %eax,(%edx,%esi,4)
			flush_block(diskaddr(bmpblock_start + (blockno/32)/NINDIRECT));
  800896:	83 ec 0c             	sub    $0xc,%esp
  800899:	89 d8                	mov    %ebx,%eax
  80089b:	c1 e8 0f             	shr    $0xf,%eax
  80089e:	83 c0 02             	add    $0x2,%eax
  8008a1:	50                   	push   %eax
  8008a2:	e8 ce fa ff ff       	call   800375 <diskaddr>
  8008a7:	89 04 24             	mov    %eax,(%esp)
  8008aa:	e8 44 fb ff ff       	call   8003f3 <flush_block>
			return blockno;
  8008af:	89 d8                	mov    %ebx,%eax
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 0c                	jmp    8008c2 <alloc_block+0x66>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	uint32_t bmpblock_start = 2;
	for(uint32_t blockno = 0; blockno < super->s_nblocks; blockno++)
  8008b6:	83 c3 01             	add    $0x1,%ebx
  8008b9:	39 f3                	cmp    %esi,%ebx
  8008bb:	75 b3                	jne    800870 <alloc_block+0x14>
			flush_block(diskaddr(bmpblock_start + (blockno/32)/NINDIRECT));
			return blockno;
		}
	}
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  8008bd:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8008c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	57                   	push   %edi
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	83 ec 1c             	sub    $0x1c,%esp
  8008d2:	8b 7d 08             	mov    0x8(%ebp),%edi

	int bn;
	uint32_t *indirects;
	if (filebno >= NDIRECT + NINDIRECT)
  8008d5:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8008db:	0f 87 85 00 00 00    	ja     800966 <file_block_walk+0x9d>
		return -E_INVAL;

	if (filebno < NDIRECT) {
  8008e1:	83 fa 09             	cmp    $0x9,%edx
  8008e4:	77 10                	ja     8008f6 <file_block_walk+0x2d>
		*ppdiskbno = &(f->f_direct[filebno]);
  8008e6:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8008ed:	89 01                	mov    %eax,(%ecx)
			indirects = diskaddr(bn);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		}
	}

	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f4:	eb 7c                	jmp    800972 <file_block_walk+0xa9>
  8008f6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8008f9:	89 d3                	mov    %edx,%ebx
  8008fb:	89 c6                	mov    %eax,%esi
		return -E_INVAL;

	if (filebno < NDIRECT) {
		*ppdiskbno = &(f->f_direct[filebno]);
	} else {
		if (f->f_indirect) {
  8008fd:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
  800903:	85 c0                	test   %eax,%eax
  800905:	74 1c                	je     800923 <file_block_walk+0x5a>
			indirects = diskaddr(f->f_indirect);
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	50                   	push   %eax
  80090b:	e8 65 fa ff ff       	call   800375 <diskaddr>
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
  800910:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800914:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800917:	89 06                	mov    %eax,(%esi)
  800919:	83 c4 10             	add    $0x10,%esp
			indirects = diskaddr(bn);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		}
	}

	return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb 4f                	jmp    800972 <file_block_walk+0xa9>
	} else {
		if (f->f_indirect) {
			indirects = diskaddr(f->f_indirect);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		} else {
			if (!alloc)
  800923:	89 f8                	mov    %edi,%eax
  800925:	84 c0                	test   %al,%al
  800927:	74 44                	je     80096d <file_block_walk+0xa4>
				return -E_NOT_FOUND;
			if ((bn = alloc_block()) < 0)
  800929:	e8 2e ff ff ff       	call   80085c <alloc_block>
  80092e:	89 c7                	mov    %eax,%edi
  800930:	85 c0                	test   %eax,%eax
  800932:	78 3e                	js     800972 <file_block_walk+0xa9>
				return bn;
			f->f_indirect = bn;
  800934:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
			flush_block(diskaddr(bn));
  80093a:	83 ec 0c             	sub    $0xc,%esp
  80093d:	50                   	push   %eax
  80093e:	e8 32 fa ff ff       	call   800375 <diskaddr>
  800943:	89 04 24             	mov    %eax,(%esp)
  800946:	e8 a8 fa ff ff       	call   8003f3 <flush_block>
			indirects = diskaddr(bn);
  80094b:	89 3c 24             	mov    %edi,(%esp)
  80094e:	e8 22 fa ff ff       	call   800375 <diskaddr>
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
  800953:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800957:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80095a:	89 03                	mov    %eax,(%ebx)
  80095c:	83 c4 10             	add    $0x10,%esp
		}
	}

	return 0;
  80095f:	b8 00 00 00 00       	mov    $0x0,%eax
  800964:	eb 0c                	jmp    800972 <file_block_walk+0xa9>
{

	int bn;
	uint32_t *indirects;
	if (filebno >= NDIRECT + NINDIRECT)
		return -E_INVAL;
  800966:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096b:	eb 05                	jmp    800972 <file_block_walk+0xa9>
		if (f->f_indirect) {
			indirects = diskaddr(f->f_indirect);
			*ppdiskbno = &(indirects[filebno - NDIRECT]);
		} else {
			if (!alloc)
				return -E_NOT_FOUND;
  80096d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	return 0;

       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
}
  800972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80097f:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800984:	8b 70 04             	mov    0x4(%eax),%esi
  800987:	bb 00 00 00 00       	mov    $0x0,%ebx
  80098c:	eb 29                	jmp    8009b7 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  80098e:	8d 43 02             	lea    0x2(%ebx),%eax
  800991:	50                   	push   %eax
  800992:	e8 4c fe ff ff       	call   8007e3 <block_is_free>
  800997:	83 c4 04             	add    $0x4,%esp
  80099a:	84 c0                	test   %al,%al
  80099c:	74 16                	je     8009b4 <check_bitmap+0x3a>
  80099e:	68 e6 3a 80 00       	push   $0x803ae6
  8009a3:	68 bd 38 80 00       	push   $0x8038bd
  8009a8:	6a 5a                	push   $0x5a
  8009aa:	68 96 3a 80 00       	push   $0x803a96
  8009af:	e8 1f 11 00 00       	call   801ad3 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8009b4:	83 c3 01             	add    $0x1,%ebx
  8009b7:	89 d8                	mov    %ebx,%eax
  8009b9:	c1 e0 0f             	shl    $0xf,%eax
  8009bc:	39 f0                	cmp    %esi,%eax
  8009be:	72 ce                	jb     80098e <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8009c0:	83 ec 0c             	sub    $0xc,%esp
  8009c3:	6a 00                	push   $0x0
  8009c5:	e8 19 fe ff ff       	call   8007e3 <block_is_free>
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	84 c0                	test   %al,%al
  8009cf:	74 16                	je     8009e7 <check_bitmap+0x6d>
  8009d1:	68 fa 3a 80 00       	push   $0x803afa
  8009d6:	68 bd 38 80 00       	push   $0x8038bd
  8009db:	6a 5d                	push   $0x5d
  8009dd:	68 96 3a 80 00       	push   $0x803a96
  8009e2:	e8 ec 10 00 00       	call   801ad3 <_panic>
	assert(!block_is_free(1));
  8009e7:	83 ec 0c             	sub    $0xc,%esp
  8009ea:	6a 01                	push   $0x1
  8009ec:	e8 f2 fd ff ff       	call   8007e3 <block_is_free>
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	84 c0                	test   %al,%al
  8009f6:	74 16                	je     800a0e <check_bitmap+0x94>
  8009f8:	68 0c 3b 80 00       	push   $0x803b0c
  8009fd:	68 bd 38 80 00       	push   $0x8038bd
  800a02:	6a 5e                	push   $0x5e
  800a04:	68 96 3a 80 00       	push   $0x803a96
  800a09:	e8 c5 10 00 00       	call   801ad3 <_panic>

	cprintf("bitmap is good\n");
  800a0e:	83 ec 0c             	sub    $0xc,%esp
  800a11:	68 1e 3b 80 00       	push   $0x803b1e
  800a16:	e8 91 11 00 00       	call   801bac <cprintf>
}
  800a1b:	83 c4 10             	add    $0x10,%esp
  800a1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800a2b:	e8 2f f6 ff ff       	call   80005f <ide_probe_disk1>
  800a30:	84 c0                	test   %al,%al
  800a32:	74 0f                	je     800a43 <fs_init+0x1e>
		ide_set_disk(1);
  800a34:	83 ec 0c             	sub    $0xc,%esp
  800a37:	6a 01                	push   $0x1
  800a39:	e8 85 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a3e:	83 c4 10             	add    $0x10,%esp
  800a41:	eb 0d                	jmp    800a50 <fs_init+0x2b>
	else
		ide_set_disk(0);
  800a43:	83 ec 0c             	sub    $0xc,%esp
  800a46:	6a 00                	push   $0x0
  800a48:	e8 76 f6 ff ff       	call   8000c3 <ide_set_disk>
  800a4d:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800a50:	e8 5e fa ff ff       	call   8004b3 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800a55:	83 ec 0c             	sub    $0xc,%esp
  800a58:	6a 01                	push   $0x1
  800a5a:	e8 16 f9 ff ff       	call   800375 <diskaddr>
  800a5f:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800a64:	e8 24 fd ff ff       	call   80078d <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800a69:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a70:	e8 00 f9 ff ff       	call   800375 <diskaddr>
  800a75:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800a7a:	e8 fb fe ff ff       	call   80097a <check_bitmap>
	cprintf("fs/fs_init():after fs_init().\n");	
  800a7f:	c7 04 24 68 3b 80 00 	movl   $0x803b68,(%esp)
  800a86:	e8 21 11 00 00       	call   801bac <cprintf>
}
  800a8b:	83 c4 10             	add    $0x10,%esp
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	83 ec 24             	sub    $0x24,%esp
       // LAB 5: Your code here.
	int r;
	uint32_t *pdiskbno;
	if ((r = file_block_walk(f, filebno, &pdiskbno, true)) < 0) {
  800a96:	6a 01                	push   $0x1
  800a98:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800a9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	e8 23 fe ff ff       	call   8008c9 <file_block_walk>
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	78 46                	js     800af3 <file_get_block+0x63>
		  return r;
	}

	int bn;
	if (*pdiskbno == 0) 
  800aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ab0:	83 38 00             	cmpl   $0x0,(%eax)
  800ab3:	75 24                	jne    800ad9 <file_get_block+0x49>
	{
			//此时*pdiskbno保存着文件f第filebno块block的索引
			if ((bn = alloc_block()) < 0) {
  800ab5:	e8 a2 fd ff ff       	call   80085c <alloc_block>
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	85 c0                	test   %eax,%eax
  800abe:	78 33                	js     800af3 <file_get_block+0x63>
				return bn;
			}
			*pdiskbno = bn;
  800ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac3:	89 10                	mov    %edx,(%eax)
			flush_block(diskaddr(bn));
  800ac5:	83 ec 0c             	sub    $0xc,%esp
  800ac8:	52                   	push   %edx
  800ac9:	e8 a7 f8 ff ff       	call   800375 <diskaddr>
  800ace:	89 04 24             	mov    %eax,(%esp)
  800ad1:	e8 1d f9 ff ff       	call   8003f3 <flush_block>
  800ad6:	83 c4 10             	add    $0x10,%esp
	}
	*blk = diskaddr(*pdiskbno);
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adf:	ff 30                	pushl  (%eax)
  800ae1:	e8 8f f8 ff ff       	call   800375 <diskaddr>
  800ae6:	8b 55 10             	mov    0x10(%ebp),%edx
  800ae9:	89 02                	mov    %eax,(%edx)
	return 0;
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
       panic("file_get_block not implemented");
}
  800af3:	c9                   	leave  
  800af4:	c3                   	ret    

00800af5 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800b01:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800b07:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  800b0d:	eb 03                	jmp    800b12 <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b0f:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b12:	80 38 2f             	cmpb   $0x2f,(%eax)
  800b15:	74 f8                	je     800b0f <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800b17:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  800b1d:	83 c1 08             	add    $0x8,%ecx
  800b20:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800b26:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800b2d:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  800b33:	85 c9                	test   %ecx,%ecx
  800b35:	74 06                	je     800b3d <walk_path+0x48>
		*pdir = 0;
  800b37:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800b3d:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800b43:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b4e:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b54:	e9 5f 01 00 00       	jmp    800cb8 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800b59:	83 c7 01             	add    $0x1,%edi
  800b5c:	eb 02                	jmp    800b60 <walk_path+0x6b>
  800b5e:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800b60:	0f b6 17             	movzbl (%edi),%edx
  800b63:	80 fa 2f             	cmp    $0x2f,%dl
  800b66:	74 04                	je     800b6c <walk_path+0x77>
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 ed                	jne    800b59 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800b6c:	89 fb                	mov    %edi,%ebx
  800b6e:	29 c3                	sub    %eax,%ebx
  800b70:	83 fb 7f             	cmp    $0x7f,%ebx
  800b73:	0f 8f 69 01 00 00    	jg     800ce2 <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800b79:	83 ec 04             	sub    $0x4,%esp
  800b7c:	53                   	push   %ebx
  800b7d:	50                   	push   %eax
  800b7e:	56                   	push   %esi
  800b7f:	e8 89 17 00 00       	call   80230d <memmove>
		name[path - p] = '\0';
  800b84:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800b8b:	00 
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	eb 03                	jmp    800b94 <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800b91:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800b94:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800b97:	74 f8                	je     800b91 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800b99:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800b9f:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800ba6:	0f 85 3d 01 00 00    	jne    800ce9 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800bac:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800bb2:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800bb7:	74 19                	je     800bd2 <walk_path+0xdd>
  800bb9:	68 2e 3b 80 00       	push   $0x803b2e
  800bbe:	68 bd 38 80 00       	push   $0x8038bd
  800bc3:	68 e1 00 00 00       	push   $0xe1
  800bc8:	68 96 3a 80 00       	push   $0x803a96
  800bcd:	e8 01 0f 00 00       	call   801ad3 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800bd2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	0f 48 c2             	cmovs  %edx,%eax
  800bdd:	c1 f8 0c             	sar    $0xc,%eax
  800be0:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800be6:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800bed:	00 00 00 
  800bf0:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800bf6:	eb 5e                	jmp    800c56 <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800bf8:	83 ec 04             	sub    $0x4,%esp
  800bfb:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800c01:	50                   	push   %eax
  800c02:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800c08:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800c0e:	e8 7d fe ff ff       	call   800a90 <file_get_block>
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	85 c0                	test   %eax,%eax
  800c18:	0f 88 ee 00 00 00    	js     800d0c <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800c1e:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800c24:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800c2a:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800c30:	83 ec 08             	sub    $0x8,%esp
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	e8 eb 15 00 00       	call   802225 <strcmp>
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	0f 84 ab 00 00 00    	je     800cf0 <walk_path+0x1fb>
  800c45:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800c4b:	39 fb                	cmp    %edi,%ebx
  800c4d:	75 db                	jne    800c2a <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800c4f:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800c56:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800c5c:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800c62:	75 94                	jne    800bf8 <walk_path+0x103>
  800c64:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800c6a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800c6f:	80 3f 00             	cmpb   $0x0,(%edi)
  800c72:	0f 85 a3 00 00 00    	jne    800d1b <walk_path+0x226>
				if (pdir)
  800c78:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	74 08                	je     800c8a <walk_path+0x195>
					*pdir = dir;
  800c82:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800c88:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800c8a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800c8e:	74 15                	je     800ca5 <walk_path+0x1b0>
					strcpy(lastelem, name);
  800c90:	83 ec 08             	sub    $0x8,%esp
  800c93:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800c99:	50                   	push   %eax
  800c9a:	ff 75 08             	pushl  0x8(%ebp)
  800c9d:	e8 d9 14 00 00       	call   80217b <strcpy>
  800ca2:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800ca5:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800cb1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cb6:	eb 63                	jmp    800d1b <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cb8:	80 38 00             	cmpb   $0x0,(%eax)
  800cbb:	0f 85 9d fe ff ff    	jne    800b5e <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800cc1:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	74 02                	je     800ccd <walk_path+0x1d8>
		*pdir = dir;
  800ccb:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800ccd:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800cd3:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800cd9:	89 08                	mov    %ecx,(%eax)
	return 0;
  800cdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce0:	eb 39                	jmp    800d1b <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800ce2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800ce7:	eb 32                	jmp    800d1b <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800ce9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800cee:	eb 2b                	jmp    800d1b <walk_path+0x226>
  800cf0:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800cf6:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800cfc:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d02:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800d08:	89 f8                	mov    %edi,%eax
  800d0a:	eb ac                	jmp    800cb8 <walk_path+0x1c3>
  800d0c:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d12:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d15:	0f 84 4f ff ff ff    	je     800c6a <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800d29:	6a 00                	push   $0x0
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	e8 ba fd ff ff       	call   800af5 <walk_path>
}
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 2c             	sub    $0x2c,%esp
  800d46:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d49:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800d55:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800d5a:	39 ca                	cmp    %ecx,%edx
  800d5c:	7e 7c                	jle    800dda <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800d5e:	29 ca                	sub    %ecx,%edx
  800d60:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d63:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800d67:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800d6a:	89 ce                	mov    %ecx,%esi
  800d6c:	01 d1                	add    %edx,%ecx
  800d6e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800d71:	eb 5d                	jmp    800dd0 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800d73:	83 ec 04             	sub    $0x4,%esp
  800d76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800d79:	50                   	push   %eax
  800d7a:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800d80:	85 f6                	test   %esi,%esi
  800d82:	0f 49 c6             	cmovns %esi,%eax
  800d85:	c1 f8 0c             	sar    $0xc,%eax
  800d88:	50                   	push   %eax
  800d89:	ff 75 08             	pushl  0x8(%ebp)
  800d8c:	e8 ff fc ff ff       	call   800a90 <file_get_block>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 42                	js     800dda <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800d98:	89 f2                	mov    %esi,%edx
  800d9a:	c1 fa 1f             	sar    $0x1f,%edx
  800d9d:	c1 ea 14             	shr    $0x14,%edx
  800da0:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800da3:	25 ff 0f 00 00       	and    $0xfff,%eax
  800da8:	29 d0                	sub    %edx,%eax
  800daa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800dad:	29 da                	sub    %ebx,%edx
  800daf:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800db4:	29 c3                	sub    %eax,%ebx
  800db6:	39 da                	cmp    %ebx,%edx
  800db8:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	53                   	push   %ebx
  800dbf:	03 45 e4             	add    -0x1c(%ebp),%eax
  800dc2:	50                   	push   %eax
  800dc3:	57                   	push   %edi
  800dc4:	e8 44 15 00 00       	call   80230d <memmove>
		pos += bn;
  800dc9:	01 de                	add    %ebx,%esi
		buf += bn;
  800dcb:	01 df                	add    %ebx,%edi
  800dcd:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800dd0:	89 f3                	mov    %esi,%ebx
  800dd2:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800dd5:	77 9c                	ja     800d73 <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800dd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 2c             	sub    $0x2c,%esp
  800deb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800dee:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800df4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800df7:	0f 8e a7 00 00 00    	jle    800ea4 <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800dfd:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800e03:	05 ff 0f 00 00       	add    $0xfff,%eax
  800e08:	0f 49 f8             	cmovns %eax,%edi
  800e0b:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e11:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800e16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e19:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800e1f:	0f 49 c2             	cmovns %edx,%eax
  800e22:	c1 f8 0c             	sar    $0xc,%eax
  800e25:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e28:	89 c3                	mov    %eax,%ebx
  800e2a:	eb 39                	jmp    800e65 <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	6a 00                	push   $0x0
  800e31:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800e34:	89 da                	mov    %ebx,%edx
  800e36:	89 f0                	mov    %esi,%eax
  800e38:	e8 8c fa ff ff       	call   8008c9 <file_block_walk>
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	85 c0                	test   %eax,%eax
  800e42:	78 4d                	js     800e91 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800e44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e47:	8b 00                	mov    (%eax),%eax
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	74 15                	je     800e62 <file_set_size+0x80>
		free_block(*ptr);
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	50                   	push   %eax
  800e51:	e8 ca f9 ff ff       	call   800820 <free_block>
		*ptr = 0;
  800e56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e5f:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800e62:	83 c3 01             	add    $0x1,%ebx
  800e65:	39 df                	cmp    %ebx,%edi
  800e67:	77 c3                	ja     800e2c <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800e69:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800e6d:	77 35                	ja     800ea4 <file_set_size+0xc2>
  800e6f:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e75:	85 c0                	test   %eax,%eax
  800e77:	74 2b                	je     800ea4 <file_set_size+0xc2>
		free_block(f->f_indirect);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	e8 9e f9 ff ff       	call   800820 <free_block>
		f->f_indirect = 0;
  800e82:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800e89:	00 00 00 
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	eb 13                	jmp    800ea4 <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	50                   	push   %eax
  800e95:	68 4b 3b 80 00       	push   $0x803b4b
  800e9a:	e8 0d 0d 00 00       	call   801bac <cprintf>
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	eb be                	jmp    800e62 <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea7:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800ead:	83 ec 0c             	sub    $0xc,%esp
  800eb0:	56                   	push   %esi
  800eb1:	e8 3d f5 ff ff       	call   8003f3 <flush_block>
	return 0;
}
  800eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
  800ecc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ecf:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800ed2:	89 f0                	mov    %esi,%eax
  800ed4:	03 45 10             	add    0x10(%ebp),%eax
  800ed7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800eda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800edd:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800ee3:	76 72                	jbe    800f57 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800ee5:	83 ec 08             	sub    $0x8,%esp
  800ee8:	50                   	push   %eax
  800ee9:	51                   	push   %ecx
  800eea:	e8 f3 fe ff ff       	call   800de2 <file_set_size>
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	79 61                	jns    800f57 <file_write+0x94>
  800ef6:	eb 69                	jmp    800f61 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800efe:	50                   	push   %eax
  800eff:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800f05:	85 f6                	test   %esi,%esi
  800f07:	0f 49 c6             	cmovns %esi,%eax
  800f0a:	c1 f8 0c             	sar    $0xc,%eax
  800f0d:	50                   	push   %eax
  800f0e:	ff 75 08             	pushl  0x8(%ebp)
  800f11:	e8 7a fb ff ff       	call   800a90 <file_get_block>
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 44                	js     800f61 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	c1 fa 1f             	sar    $0x1f,%edx
  800f22:	c1 ea 14             	shr    $0x14,%edx
  800f25:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800f28:	25 ff 0f 00 00       	and    $0xfff,%eax
  800f2d:	29 d0                	sub    %edx,%eax
  800f2f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f32:	29 d9                	sub    %ebx,%ecx
  800f34:	89 cb                	mov    %ecx,%ebx
  800f36:	ba 00 10 00 00       	mov    $0x1000,%edx
  800f3b:	29 c2                	sub    %eax,%edx
  800f3d:	39 d1                	cmp    %edx,%ecx
  800f3f:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	53                   	push   %ebx
  800f46:	57                   	push   %edi
  800f47:	03 45 e4             	add    -0x1c(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	e8 bd 13 00 00       	call   80230d <memmove>
		pos += bn;
  800f50:	01 de                	add    %ebx,%esi
		buf += bn;
  800f52:	01 df                	add    %ebx,%edi
  800f54:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f57:	89 f3                	mov    %esi,%ebx
  800f59:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800f5c:	77 9a                	ja     800ef8 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800f5e:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 10             	sub    $0x10,%esp
  800f71:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800f74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f79:	eb 3c                	jmp    800fb7 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	6a 00                	push   $0x0
  800f80:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800f83:	89 da                	mov    %ebx,%edx
  800f85:	89 f0                	mov    %esi,%eax
  800f87:	e8 3d f9 ff ff       	call   8008c9 <file_block_walk>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 21                	js     800fb4 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800f96:	85 c0                	test   %eax,%eax
  800f98:	74 1a                	je     800fb4 <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800f9a:	8b 00                	mov    (%eax),%eax
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	74 14                	je     800fb4 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800fa0:	83 ec 0c             	sub    $0xc,%esp
  800fa3:	50                   	push   %eax
  800fa4:	e8 cc f3 ff ff       	call   800375 <diskaddr>
  800fa9:	89 04 24             	mov    %eax,(%esp)
  800fac:	e8 42 f4 ff ff       	call   8003f3 <flush_block>
  800fb1:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800fb4:	83 c3 01             	add    $0x1,%ebx
  800fb7:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800fbd:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800fc3:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800fc9:	85 c9                	test   %ecx,%ecx
  800fcb:	0f 49 c1             	cmovns %ecx,%eax
  800fce:	c1 f8 0c             	sar    $0xc,%eax
  800fd1:	39 c3                	cmp    %eax,%ebx
  800fd3:	7c a6                	jl     800f7b <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	56                   	push   %esi
  800fd9:	e8 15 f4 ff ff       	call   8003f3 <flush_block>
	if (f->f_indirect)
  800fde:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	74 14                	je     800fff <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	50                   	push   %eax
  800fef:	e8 81 f3 ff ff       	call   800375 <diskaddr>
  800ff4:	89 04 24             	mov    %eax,(%esp)
  800ff7:	e8 f7 f3 ff ff       	call   8003f3 <flush_block>
  800ffc:	83 c4 10             	add    $0x10,%esp
}
  800fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	57                   	push   %edi
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801012:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801018:	50                   	push   %eax
  801019:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  80101f:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	e8 c8 fa ff ff       	call   800af5 <walk_path>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	0f 84 d1 00 00 00    	je     801109 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801038:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80103b:	0f 85 0c 01 00 00    	jne    80114d <file_create+0x147>
  801041:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  801047:	85 f6                	test   %esi,%esi
  801049:	0f 84 c1 00 00 00    	je     801110 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80104f:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  801055:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80105a:	74 19                	je     801075 <file_create+0x6f>
  80105c:	68 2e 3b 80 00       	push   $0x803b2e
  801061:	68 bd 38 80 00       	push   $0x8038bd
  801066:	68 fa 00 00 00       	push   $0xfa
  80106b:	68 96 3a 80 00       	push   $0x803a96
  801070:	e8 5e 0a 00 00       	call   801ad3 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801075:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80107b:	85 c0                	test   %eax,%eax
  80107d:	0f 48 c2             	cmovs  %edx,%eax
  801080:	c1 f8 0c             	sar    $0xc,%eax
  801083:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801089:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80108e:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801094:	eb 3b                	jmp    8010d1 <file_create+0xcb>
  801096:	83 ec 04             	sub    $0x4,%esp
  801099:	57                   	push   %edi
  80109a:	53                   	push   %ebx
  80109b:	56                   	push   %esi
  80109c:	e8 ef f9 ff ff       	call   800a90 <file_get_block>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	0f 88 a1 00 00 00    	js     80114d <file_create+0x147>
			return r;
		f = (struct File*) blk;
  8010ac:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  8010b2:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8010b8:	80 38 00             	cmpb   $0x0,(%eax)
  8010bb:	75 08                	jne    8010c5 <file_create+0xbf>
				*file = &f[j];
  8010bd:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8010c3:	eb 52                	jmp    801117 <file_create+0x111>
  8010c5:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8010ca:	39 d0                	cmp    %edx,%eax
  8010cc:	75 ea                	jne    8010b8 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8010ce:	83 c3 01             	add    $0x1,%ebx
  8010d1:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  8010d7:	75 bd                	jne    801096 <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8010d9:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  8010e0:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8010e3:	83 ec 04             	sub    $0x4,%esp
  8010e6:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	53                   	push   %ebx
  8010ee:	56                   	push   %esi
  8010ef:	e8 9c f9 ff ff       	call   800a90 <file_get_block>
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 52                	js     80114d <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8010fb:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801101:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801107:	eb 0e                	jmp    801117 <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  801109:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  80110e:	eb 3d                	jmp    80114d <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  801110:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801115:	eb 36                	jmp    80114d <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  801117:	83 ec 08             	sub    $0x8,%esp
  80111a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  801127:	e8 4f 10 00 00       	call   80217b <strcpy>
	*pf = f;
  80112c:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801132:	8b 45 0c             	mov    0xc(%ebp),%eax
  801135:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801137:	83 c4 04             	add    $0x4,%esp
  80113a:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  801140:	e8 24 fe ff ff       	call   800f69 <file_flush>
	return 0;
  801145:	83 c4 10             	add    $0x10,%esp
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5f                   	pop    %edi
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	53                   	push   %ebx
  801159:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80115c:	bb 01 00 00 00       	mov    $0x1,%ebx
  801161:	eb 17                	jmp    80117a <fs_sync+0x25>
		flush_block(diskaddr(i));
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	53                   	push   %ebx
  801167:	e8 09 f2 ff ff       	call   800375 <diskaddr>
  80116c:	89 04 24             	mov    %eax,(%esp)
  80116f:	e8 7f f2 ff ff       	call   8003f3 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801174:	83 c3 01             	add    $0x1,%ebx
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80117f:	39 58 04             	cmp    %ebx,0x4(%eax)
  801182:	77 df                	ja     801163 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  801184:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801187:	c9                   	leave  
  801188:	c3                   	ret    

00801189 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80118f:	e8 c1 ff ff ff       	call   801155 <fs_sync>
	return 0;
}
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  8011a3:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8011a8:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8011ad:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8011af:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8011b2:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8011b8:	83 c0 01             	add    $0x1,%eax
  8011bb:	83 c2 10             	add    $0x10,%edx
  8011be:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011c3:	75 e8                	jne    8011ad <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
  8011cc:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8011cf:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  8011d4:	83 ec 0c             	sub    $0xc,%esp
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	c1 e0 04             	shl    $0x4,%eax
  8011dc:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8011e2:	e8 ee 1e 00 00       	call   8030d5 <pageref>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	74 07                	je     8011f5 <openfile_alloc+0x2e>
  8011ee:	83 f8 01             	cmp    $0x1,%eax
  8011f1:	74 20                	je     801213 <openfile_alloc+0x4c>
  8011f3:	eb 51                	jmp    801246 <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	6a 07                	push   $0x7
  8011fa:	89 d8                	mov    %ebx,%eax
  8011fc:	c1 e0 04             	shl    $0x4,%eax
  8011ff:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  801205:	6a 00                	push   $0x0
  801207:	e8 72 13 00 00       	call   80257e <sys_page_alloc>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 43                	js     801256 <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801213:	c1 e3 04             	shl    $0x4,%ebx
  801216:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  80121c:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801223:	04 00 00 
			*o = &opentab[i];
  801226:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	68 00 10 00 00       	push   $0x1000
  801230:	6a 00                	push   $0x0
  801232:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  801238:	e8 83 10 00 00       	call   8022c0 <memset>
			return (*o)->o_fileid;
  80123d:	8b 06                	mov    (%esi),%eax
  80123f:	8b 00                	mov    (%eax),%eax
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	eb 10                	jmp    801256 <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801246:	83 c3 01             	add    $0x1,%ebx
  801249:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80124f:	75 83                	jne    8011d4 <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801251:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801256:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5d                   	pop    %ebp
  80125c:	c3                   	ret    

0080125d <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 18             	sub    $0x18,%esp
  801266:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801269:	89 fb                	mov    %edi,%ebx
  80126b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801271:	89 de                	mov    %ebx,%esi
  801273:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801276:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  80127c:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801282:	e8 4e 1e 00 00       	call   8030d5 <pageref>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	83 f8 01             	cmp    $0x1,%eax
  80128d:	7e 17                	jle    8012a6 <openfile_lookup+0x49>
  80128f:	c1 e3 04             	shl    $0x4,%ebx
  801292:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801298:	75 13                	jne    8012ad <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  80129a:	8b 45 10             	mov    0x10(%ebp),%eax
  80129d:	89 30                	mov    %esi,(%eax)
	return 0;
  80129f:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a4:	eb 0c                	jmp    8012b2 <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8012a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ab:	eb 05                	jmp    8012b2 <openfile_lookup+0x55>
  8012ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8012b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5f                   	pop    %edi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 18             	sub    $0x18,%esp
  8012c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c7:	50                   	push   %eax
  8012c8:	ff 33                	pushl  (%ebx)
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 8b ff ff ff       	call   80125d <openfile_lookup>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 14                	js     8012ed <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 73 04             	pushl  0x4(%ebx)
  8012df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e2:	ff 70 04             	pushl  0x4(%eax)
  8012e5:	e8 f8 fa ff ff       	call   800de2 <file_set_size>
  8012ea:	83 c4 10             	add    $0x10,%esp
}
  8012ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 18             	sub    $0x18,%esp
  8012f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	struct OpenFile *o;
	int r;
	r = openfile_lookup(envid, req->req_fileid, &o);
  8012fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	ff 33                	pushl  (%ebx)
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 53 ff ff ff       	call   80125d <openfile_lookup>
	if (r < 0)		//通过fileid找到Openfile结构
  80130a:	83 c4 10             	add    $0x10,%esp
		return r;
  80130d:	89 c2                	mov    %eax,%edx

	// Lab 5: Your code here:
	struct OpenFile *o;
	int r;
	r = openfile_lookup(envid, req->req_fileid, &o);
	if (r < 0)		//通过fileid找到Openfile结构
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 2b                	js     80133e <serve_read+0x4c>
		return r;
	if ((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)	//调用fs.c中函数进行真正的读操作
  801313:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801316:	8b 50 0c             	mov    0xc(%eax),%edx
  801319:	ff 72 04             	pushl  0x4(%edx)
  80131c:	ff 73 04             	pushl  0x4(%ebx)
  80131f:	53                   	push   %ebx
  801320:	ff 70 04             	pushl  0x4(%eax)
  801323:	e8 15 fa ff ff       	call   800d3d <file_read>
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	78 0d                	js     80133c <serve_read+0x4a>
		return r;
	o->o_fd->fd_offset += r;
  80132f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801332:	8b 52 0c             	mov    0xc(%edx),%edx
  801335:	01 42 04             	add    %eax,0x4(%edx)
	
	return r;
  801338:	89 c2                	mov    %eax,%edx
  80133a:	eb 02                	jmp    80133e <serve_read+0x4c>
	int r;
	r = openfile_lookup(envid, req->req_fileid, &o);
	if (r < 0)		//通过fileid找到Openfile结构
		return r;
	if ((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)	//调用fs.c中函数进行真正的读操作
		return r;
  80133c:	89 c2                	mov    %eax,%edx
	o->o_fd->fd_offset += r;
	
	return r;
}
  80133e:	89 d0                	mov    %edx,%eax
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	57                   	push   %edi
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	83 ec 20             	sub    $0x20,%esp
  80134e:	8b 75 0c             	mov    0xc(%ebp),%esi
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  801351:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 36                	pushl  (%esi)
  801357:	ff 75 08             	pushl  0x8(%ebp)
  80135a:	e8 fe fe ff ff       	call   80125d <openfile_lookup>
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 36                	js     80139c <serve_write+0x57>
  801366:	bb 00 00 00 00       	mov    $0x0,%ebx
		return r;
	}
	int total = 0;
	while (1) {
		r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
  80136b:	8d 7e 08             	lea    0x8(%esi),%edi
  80136e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801371:	8b 50 0c             	mov    0xc(%eax),%edx
  801374:	ff 72 04             	pushl  0x4(%edx)
  801377:	ff 76 04             	pushl  0x4(%esi)
  80137a:	57                   	push   %edi
  80137b:	ff 70 04             	pushl  0x4(%eax)
  80137e:	e8 40 fb ff ff       	call   800ec3 <file_write>
		if (r < 0) return r;
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 12                	js     80139c <serve_write+0x57>
		total += r;
  80138a:	01 c3                	add    %eax,%ebx
		o->o_fd->fd_offset += r;
  80138c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138f:	8b 52 0c             	mov    0xc(%edx),%edx
  801392:	01 42 04             	add    %eax,0x4(%edx)
		if (req->req_n <= total)
  801395:	39 5e 04             	cmp    %ebx,0x4(%esi)
  801398:	77 d4                	ja     80136e <serve_write+0x29>
	}
	int total = 0;
	while (1) {
		r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset);
		if (r < 0) return r;
		total += r;
  80139a:	89 d8                	mov    %ebx,%eax
		if (req->req_n <= total)
			break;
	}
	return total;
	panic("serve_write not implemented");
}
  80139c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    

008013a4 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8013a4:	55                   	push   %ebp
  8013a5:	89 e5                	mov    %esp,%ebp
  8013a7:	53                   	push   %ebx
  8013a8:	83 ec 18             	sub    $0x18,%esp
  8013ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 33                	pushl  (%ebx)
  8013b4:	ff 75 08             	pushl  0x8(%ebp)
  8013b7:	e8 a1 fe ff ff       	call   80125d <openfile_lookup>
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 3f                	js     801402 <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	ff 70 04             	pushl  0x4(%eax)
  8013cc:	53                   	push   %ebx
  8013cd:	e8 a9 0d 00 00       	call   80217b <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d5:	8b 50 04             	mov    0x4(%eax),%edx
  8013d8:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8013de:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8013e4:	8b 40 04             	mov    0x4(%eax),%eax
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8013f1:	0f 94 c0             	sete   %al
  8013f4:	0f b6 c0             	movzbl %al,%eax
  8013f7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801402:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80140d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801410:	50                   	push   %eax
  801411:	8b 45 0c             	mov    0xc(%ebp),%eax
  801414:	ff 30                	pushl  (%eax)
  801416:	ff 75 08             	pushl  0x8(%ebp)
  801419:	e8 3f fe ff ff       	call   80125d <openfile_lookup>
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 16                	js     80143b <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142b:	ff 70 04             	pushl  0x4(%eax)
  80142e:	e8 36 fb ff ff       	call   800f69 <file_flush>
	return 0;
  801433:	83 c4 10             	add    $0x10,%esp
  801436:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	53                   	push   %ebx
  801441:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801447:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  80144a:	68 00 04 00 00       	push   $0x400
  80144f:	53                   	push   %ebx
  801450:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	e8 b1 0e 00 00       	call   80230d <memmove>
	path[MAXPATHLEN-1] = 0;
  80145c:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801460:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801466:	89 04 24             	mov    %eax,(%esp)
  801469:	e8 59 fd ff ff       	call   8011c7 <openfile_alloc>
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	0f 88 f0 00 00 00    	js     801569 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801479:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801480:	74 33                	je     8014b5 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	e8 6e fb ff ff       	call   801006 <file_create>
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	79 37                	jns    8014d6 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80149f:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8014a6:	0f 85 bd 00 00 00    	jne    801569 <serve_open+0x12c>
  8014ac:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8014af:	0f 85 b4 00 00 00    	jne    801569 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	e8 58 f8 ff ff       	call   800d23 <file_open>
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	0f 88 93 00 00 00    	js     801569 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8014d6:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8014dd:	74 17                	je     8014f6 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	6a 00                	push   $0x0
  8014e4:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8014ea:	e8 f3 f8 ff ff       	call   800de2 <file_set_size>
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 73                	js     801569 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	e8 17 f8 ff ff       	call   800d23 <file_open>
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	78 56                	js     801569 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801513:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801519:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80151f:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801522:	8b 50 0c             	mov    0xc(%eax),%edx
  801525:	8b 08                	mov    (%eax),%ecx
  801527:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  80152a:	8b 48 0c             	mov    0xc(%eax),%ecx
  80152d:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801533:	83 e2 03             	and    $0x3,%edx
  801536:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801539:	8b 40 0c             	mov    0xc(%eax),%eax
  80153c:	8b 15 64 90 80 00    	mov    0x809064,%edx
  801542:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801544:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80154a:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801550:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801553:	8b 50 0c             	mov    0xc(%eax),%edx
  801556:	8b 45 10             	mov    0x10(%ebp),%eax
  801559:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80155b:	8b 45 14             	mov    0x14(%ebp),%eax
  80155e:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801564:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801569:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156c:	c9                   	leave  
  80156d:	c3                   	ret    

0080156e <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	56                   	push   %esi
  801572:	53                   	push   %ebx
  801573:	83 ec 10             	sub    $0x10,%esp
	void *pg;

	while (1) {
		perm = 0;
		//cprintf("fs/serv.c/serve().");
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801576:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801579:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80157c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		//cprintf("fs/serv.c/serve().");
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	53                   	push   %ebx
  801587:	ff 35 44 50 80 00    	pushl  0x805044
  80158d:	56                   	push   %esi
  80158e:	e8 65 12 00 00       	call   8027f8 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);
		//cprintf("fs/serv.c/serve() after ipc_rec().\n");
		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  80159a:	75 15                	jne    8015b1 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a2:	68 88 3b 80 00       	push   $0x803b88
  8015a7:	e8 00 06 00 00       	call   801bac <cprintf>
				whom);
			continue; // just leave it hanging...
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	eb cb                	jmp    80157c <serve+0xe>
		}

		pg = NULL;
  8015b1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8015b8:	83 f8 01             	cmp    $0x1,%eax
  8015bb:	75 18                	jne    8015d5 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8015bd:	53                   	push   %ebx
  8015be:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8015c1:	50                   	push   %eax
  8015c2:	ff 35 44 50 80 00    	pushl  0x805044
  8015c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015cb:	e8 6d fe ff ff       	call   80143d <serve_open>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	eb 3c                	jmp    801611 <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8015d5:	83 f8 08             	cmp    $0x8,%eax
  8015d8:	77 1e                	ja     8015f8 <serve+0x8a>
  8015da:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8015e1:	85 d2                	test   %edx,%edx
  8015e3:	74 13                	je     8015f8 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	ff 35 44 50 80 00    	pushl  0x805044
  8015ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f1:	ff d2                	call   *%edx
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	eb 19                	jmp    801611 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8015f8:	83 ec 04             	sub    $0x4,%esp
  8015fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fe:	50                   	push   %eax
  8015ff:	68 b8 3b 80 00       	push   $0x803bb8
  801604:	e8 a3 05 00 00       	call   801bac <cprintf>
  801609:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  80160c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801611:	ff 75 f0             	pushl  -0x10(%ebp)
  801614:	ff 75 ec             	pushl  -0x14(%ebp)
  801617:	50                   	push   %eax
  801618:	ff 75 f4             	pushl  -0xc(%ebp)
  80161b:	e8 35 12 00 00       	call   802855 <ipc_send>
		sys_page_unmap(0, fsreq);
  801620:	83 c4 08             	add    $0x8,%esp
  801623:	ff 35 44 50 80 00    	pushl  0x805044
  801629:	6a 00                	push   $0x0
  80162b:	e8 d3 0f 00 00       	call   802603 <sys_page_unmap>
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	e9 44 ff ff ff       	jmp    80157c <serve+0xe>

00801638 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80163e:	c7 05 60 90 80 00 db 	movl   $0x803bdb,0x809060
  801645:	3b 80 00 
	cprintf("FS is running\n");
  801648:	68 de 3b 80 00       	push   $0x803bde
  80164d:	e8 5a 05 00 00       	call   801bac <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801652:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801657:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80165c:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80165e:	c7 04 24 ed 3b 80 00 	movl   $0x803bed,(%esp)
  801665:	e8 42 05 00 00       	call   801bac <cprintf>

	serve_init();
  80166a:	e8 2c fb ff ff       	call   80119b <serve_init>
	fs_init();
  80166f:	e8 b1 f3 ff ff       	call   800a25 <fs_init>
        fs_test();
  801674:	e8 05 00 00 00       	call   80167e <fs_test>
	serve();
  801679:	e8 f0 fe ff ff       	call   80156e <serve>

0080167e <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	53                   	push   %ebx
  801682:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801685:	6a 07                	push   $0x7
  801687:	68 00 10 00 00       	push   $0x1000
  80168c:	6a 00                	push   $0x0
  80168e:	e8 eb 0e 00 00       	call   80257e <sys_page_alloc>
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	79 12                	jns    8016ac <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  80169a:	50                   	push   %eax
  80169b:	68 fc 3b 80 00       	push   $0x803bfc
  8016a0:	6a 12                	push   $0x12
  8016a2:	68 0f 3c 80 00       	push   $0x803c0f
  8016a7:	e8 27 04 00 00       	call   801ad3 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8016ac:	83 ec 04             	sub    $0x4,%esp
  8016af:	68 00 10 00 00       	push   $0x1000
  8016b4:	ff 35 04 a0 80 00    	pushl  0x80a004
  8016ba:	68 00 10 00 00       	push   $0x1000
  8016bf:	e8 49 0c 00 00       	call   80230d <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8016c4:	e8 93 f1 ff ff       	call   80085c <alloc_block>
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	79 12                	jns    8016e2 <fs_test+0x64>
		panic("alloc_block: %e", r);
  8016d0:	50                   	push   %eax
  8016d1:	68 19 3c 80 00       	push   $0x803c19
  8016d6:	6a 17                	push   $0x17
  8016d8:	68 0f 3c 80 00       	push   $0x803c0f
  8016dd:	e8 f1 03 00 00       	call   801ad3 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8016e2:	8d 50 1f             	lea    0x1f(%eax),%edx
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	0f 49 d0             	cmovns %eax,%edx
  8016ea:	c1 fa 05             	sar    $0x5,%edx
  8016ed:	89 c3                	mov    %eax,%ebx
  8016ef:	c1 fb 1f             	sar    $0x1f,%ebx
  8016f2:	c1 eb 1b             	shr    $0x1b,%ebx
  8016f5:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8016f8:	83 e1 1f             	and    $0x1f,%ecx
  8016fb:	29 d9                	sub    %ebx,%ecx
  8016fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801702:	d3 e0                	shl    %cl,%eax
  801704:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  80170b:	75 16                	jne    801723 <fs_test+0xa5>
  80170d:	68 29 3c 80 00       	push   $0x803c29
  801712:	68 bd 38 80 00       	push   $0x8038bd
  801717:	6a 19                	push   $0x19
  801719:	68 0f 3c 80 00       	push   $0x803c0f
  80171e:	e8 b0 03 00 00       	call   801ad3 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801723:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  801729:	85 04 91             	test   %eax,(%ecx,%edx,4)
  80172c:	74 16                	je     801744 <fs_test+0xc6>
  80172e:	68 c4 3d 80 00       	push   $0x803dc4
  801733:	68 bd 38 80 00       	push   $0x8038bd
  801738:	6a 1b                	push   $0x1b
  80173a:	68 0f 3c 80 00       	push   $0x803c0f
  80173f:	e8 8f 03 00 00       	call   801ad3 <_panic>
	cprintf("alloc_block is good\n");
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	68 44 3c 80 00       	push   $0x803c44
  80174c:	e8 5b 04 00 00       	call   801bac <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801751:	83 c4 08             	add    $0x8,%esp
  801754:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	68 59 3c 80 00       	push   $0x803c59
  80175d:	e8 c1 f5 ff ff       	call   800d23 <file_open>
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801768:	74 1b                	je     801785 <fs_test+0x107>
  80176a:	89 c2                	mov    %eax,%edx
  80176c:	c1 ea 1f             	shr    $0x1f,%edx
  80176f:	84 d2                	test   %dl,%dl
  801771:	74 12                	je     801785 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  801773:	50                   	push   %eax
  801774:	68 64 3c 80 00       	push   $0x803c64
  801779:	6a 1f                	push   $0x1f
  80177b:	68 0f 3c 80 00       	push   $0x803c0f
  801780:	e8 4e 03 00 00       	call   801ad3 <_panic>
	else if (r == 0)
  801785:	85 c0                	test   %eax,%eax
  801787:	75 14                	jne    80179d <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801789:	83 ec 04             	sub    $0x4,%esp
  80178c:	68 e4 3d 80 00       	push   $0x803de4
  801791:	6a 21                	push   $0x21
  801793:	68 0f 3c 80 00       	push   $0x803c0f
  801798:	e8 36 03 00 00       	call   801ad3 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a3:	50                   	push   %eax
  8017a4:	68 7d 3c 80 00       	push   $0x803c7d
  8017a9:	e8 75 f5 ff ff       	call   800d23 <file_open>
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	79 12                	jns    8017c7 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  8017b5:	50                   	push   %eax
  8017b6:	68 86 3c 80 00       	push   $0x803c86
  8017bb:	6a 23                	push   $0x23
  8017bd:	68 0f 3c 80 00       	push   $0x803c0f
  8017c2:	e8 0c 03 00 00       	call   801ad3 <_panic>
	cprintf("file_open is good\n");
  8017c7:	83 ec 0c             	sub    $0xc,%esp
  8017ca:	68 9d 3c 80 00       	push   $0x803c9d
  8017cf:	e8 d8 03 00 00       	call   801bac <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8017d4:	83 c4 0c             	add    $0xc,%esp
  8017d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017da:	50                   	push   %eax
  8017db:	6a 00                	push   $0x0
  8017dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e0:	e8 ab f2 ff ff       	call   800a90 <file_get_block>
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	79 12                	jns    8017fe <fs_test+0x180>
		panic("file_get_block: %e", r);
  8017ec:	50                   	push   %eax
  8017ed:	68 b0 3c 80 00       	push   $0x803cb0
  8017f2:	6a 27                	push   $0x27
  8017f4:	68 0f 3c 80 00       	push   $0x803c0f
  8017f9:	e8 d5 02 00 00       	call   801ad3 <_panic>
	cprintf("this is blk:%s\n",blk);
  8017fe:	83 ec 08             	sub    $0x8,%esp
  801801:	ff 75 f0             	pushl  -0x10(%ebp)
  801804:	68 c3 3c 80 00       	push   $0x803cc3
  801809:	e8 9e 03 00 00       	call   801bac <cprintf>
	cprintf("this is msg:%s\n",msg);
  80180e:	83 c4 08             	add    $0x8,%esp
  801811:	68 04 3e 80 00       	push   $0x803e04
  801816:	68 d3 3c 80 00       	push   $0x803cd3
  80181b:	e8 8c 03 00 00       	call   801bac <cprintf>
	if (strcmp(blk, msg) != 0)
  801820:	83 c4 08             	add    $0x8,%esp
  801823:	68 04 3e 80 00       	push   $0x803e04
  801828:	ff 75 f0             	pushl  -0x10(%ebp)
  80182b:	e8 f5 09 00 00       	call   802225 <strcmp>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	85 c0                	test   %eax,%eax
  801835:	74 14                	je     80184b <fs_test+0x1cd>
		panic("file_get_block returned wrong data");
  801837:	83 ec 04             	sub    $0x4,%esp
  80183a:	68 2c 3e 80 00       	push   $0x803e2c
  80183f:	6a 2b                	push   $0x2b
  801841:	68 0f 3c 80 00       	push   $0x803c0f
  801846:	e8 88 02 00 00       	call   801ad3 <_panic>
	cprintf("file_get_block is good\n");
  80184b:	83 ec 0c             	sub    $0xc,%esp
  80184e:	68 e3 3c 80 00       	push   $0x803ce3
  801853:	e8 54 03 00 00       	call   801bac <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185b:	0f b6 10             	movzbl (%eax),%edx
  80185e:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801860:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801863:	c1 e8 0c             	shr    $0xc,%eax
  801866:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	a8 40                	test   $0x40,%al
  801872:	75 16                	jne    80188a <fs_test+0x20c>
  801874:	68 fc 3c 80 00       	push   $0x803cfc
  801879:	68 bd 38 80 00       	push   $0x8038bd
  80187e:	6a 2f                	push   $0x2f
  801880:	68 0f 3c 80 00       	push   $0x803c0f
  801885:	e8 49 02 00 00       	call   801ad3 <_panic>
	file_flush(f);
  80188a:	83 ec 0c             	sub    $0xc,%esp
  80188d:	ff 75 f4             	pushl  -0xc(%ebp)
  801890:	e8 d4 f6 ff ff       	call   800f69 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801895:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801898:	c1 e8 0c             	shr    $0xc,%eax
  80189b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018a2:	83 c4 10             	add    $0x10,%esp
  8018a5:	a8 40                	test   $0x40,%al
  8018a7:	74 16                	je     8018bf <fs_test+0x241>
  8018a9:	68 fb 3c 80 00       	push   $0x803cfb
  8018ae:	68 bd 38 80 00       	push   $0x8038bd
  8018b3:	6a 31                	push   $0x31
  8018b5:	68 0f 3c 80 00       	push   $0x803c0f
  8018ba:	e8 14 02 00 00       	call   801ad3 <_panic>
	cprintf("file_flush is good\n");
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	68 17 3d 80 00       	push   $0x803d17
  8018c7:	e8 e0 02 00 00       	call   801bac <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8018cc:	83 c4 08             	add    $0x8,%esp
  8018cf:	6a 00                	push   $0x0
  8018d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d4:	e8 09 f5 ff ff       	call   800de2 <file_set_size>
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	85 c0                	test   %eax,%eax
  8018de:	79 12                	jns    8018f2 <fs_test+0x274>
		panic("file_set_size: %e", r);
  8018e0:	50                   	push   %eax
  8018e1:	68 2b 3d 80 00       	push   $0x803d2b
  8018e6:	6a 35                	push   $0x35
  8018e8:	68 0f 3c 80 00       	push   $0x803c0f
  8018ed:	e8 e1 01 00 00       	call   801ad3 <_panic>
	assert(f->f_direct[0] == 0);
  8018f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018f5:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8018fc:	74 16                	je     801914 <fs_test+0x296>
  8018fe:	68 3d 3d 80 00       	push   $0x803d3d
  801903:	68 bd 38 80 00       	push   $0x8038bd
  801908:	6a 36                	push   $0x36
  80190a:	68 0f 3c 80 00       	push   $0x803c0f
  80190f:	e8 bf 01 00 00       	call   801ad3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801914:	c1 e8 0c             	shr    $0xc,%eax
  801917:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80191e:	a8 40                	test   $0x40,%al
  801920:	74 16                	je     801938 <fs_test+0x2ba>
  801922:	68 51 3d 80 00       	push   $0x803d51
  801927:	68 bd 38 80 00       	push   $0x8038bd
  80192c:	6a 37                	push   $0x37
  80192e:	68 0f 3c 80 00       	push   $0x803c0f
  801933:	e8 9b 01 00 00       	call   801ad3 <_panic>
	cprintf("file_truncate is good\n");
  801938:	83 ec 0c             	sub    $0xc,%esp
  80193b:	68 6b 3d 80 00       	push   $0x803d6b
  801940:	e8 67 02 00 00       	call   801bac <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801945:	c7 04 24 04 3e 80 00 	movl   $0x803e04,(%esp)
  80194c:	e8 f1 07 00 00       	call   802142 <strlen>
  801951:	83 c4 08             	add    $0x8,%esp
  801954:	50                   	push   %eax
  801955:	ff 75 f4             	pushl  -0xc(%ebp)
  801958:	e8 85 f4 ff ff       	call   800de2 <file_set_size>
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	79 12                	jns    801976 <fs_test+0x2f8>
		panic("file_set_size 2: %e", r);
  801964:	50                   	push   %eax
  801965:	68 82 3d 80 00       	push   $0x803d82
  80196a:	6a 3b                	push   $0x3b
  80196c:	68 0f 3c 80 00       	push   $0x803c0f
  801971:	e8 5d 01 00 00       	call   801ad3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801976:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801979:	89 c2                	mov    %eax,%edx
  80197b:	c1 ea 0c             	shr    $0xc,%edx
  80197e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801985:	f6 c2 40             	test   $0x40,%dl
  801988:	74 16                	je     8019a0 <fs_test+0x322>
  80198a:	68 51 3d 80 00       	push   $0x803d51
  80198f:	68 bd 38 80 00       	push   $0x8038bd
  801994:	6a 3c                	push   $0x3c
  801996:	68 0f 3c 80 00       	push   $0x803c0f
  80199b:	e8 33 01 00 00       	call   801ad3 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8019a0:	83 ec 04             	sub    $0x4,%esp
  8019a3:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8019a6:	52                   	push   %edx
  8019a7:	6a 00                	push   $0x0
  8019a9:	50                   	push   %eax
  8019aa:	e8 e1 f0 ff ff       	call   800a90 <file_get_block>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	79 12                	jns    8019c8 <fs_test+0x34a>
		panic("file_get_block 2: %e", r);
  8019b6:	50                   	push   %eax
  8019b7:	68 96 3d 80 00       	push   $0x803d96
  8019bc:	6a 3e                	push   $0x3e
  8019be:	68 0f 3c 80 00       	push   $0x803c0f
  8019c3:	e8 0b 01 00 00       	call   801ad3 <_panic>
	strcpy(blk, msg);
  8019c8:	83 ec 08             	sub    $0x8,%esp
  8019cb:	68 04 3e 80 00       	push   $0x803e04
  8019d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019d3:	e8 a3 07 00 00       	call   80217b <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8019d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019db:	c1 e8 0c             	shr    $0xc,%eax
  8019de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	a8 40                	test   $0x40,%al
  8019ea:	75 16                	jne    801a02 <fs_test+0x384>
  8019ec:	68 fc 3c 80 00       	push   $0x803cfc
  8019f1:	68 bd 38 80 00       	push   $0x8038bd
  8019f6:	6a 40                	push   $0x40
  8019f8:	68 0f 3c 80 00       	push   $0x803c0f
  8019fd:	e8 d1 00 00 00       	call   801ad3 <_panic>
	file_flush(f);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	e8 5c f5 ff ff       	call   800f69 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a10:	c1 e8 0c             	shr    $0xc,%eax
  801a13:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a1a:	83 c4 10             	add    $0x10,%esp
  801a1d:	a8 40                	test   $0x40,%al
  801a1f:	74 16                	je     801a37 <fs_test+0x3b9>
  801a21:	68 fb 3c 80 00       	push   $0x803cfb
  801a26:	68 bd 38 80 00       	push   $0x8038bd
  801a2b:	6a 42                	push   $0x42
  801a2d:	68 0f 3c 80 00       	push   $0x803c0f
  801a32:	e8 9c 00 00 00       	call   801ad3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3a:	c1 e8 0c             	shr    $0xc,%eax
  801a3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a44:	a8 40                	test   $0x40,%al
  801a46:	74 16                	je     801a5e <fs_test+0x3e0>
  801a48:	68 51 3d 80 00       	push   $0x803d51
  801a4d:	68 bd 38 80 00       	push   $0x8038bd
  801a52:	6a 43                	push   $0x43
  801a54:	68 0f 3c 80 00       	push   $0x803c0f
  801a59:	e8 75 00 00 00       	call   801ad3 <_panic>
	cprintf("file rewrite is good\n");
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	68 ab 3d 80 00       	push   $0x803dab
  801a66:	e8 41 01 00 00       	call   801bac <cprintf>
}
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  801a7e:	e8 bd 0a 00 00       	call   802540 <sys_getenvid>
  801a83:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a88:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a8b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801a90:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	// save the name of the program so that panic() can use it
	if (argc > 0)
  801a95:	85 db                	test   %ebx,%ebx
  801a97:	7e 07                	jle    801aa0 <libmain+0x2d>
		binaryname = argv[0];
  801a99:	8b 06                	mov    (%esi),%eax
  801a9b:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801aa0:	83 ec 08             	sub    $0x8,%esp
  801aa3:	56                   	push   %esi
  801aa4:	53                   	push   %ebx
  801aa5:	e8 8e fb ff ff       	call   801638 <umain>

	// exit gracefully
	exit();
  801aaa:	e8 0a 00 00 00       	call   801ab9 <exit>
}
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801abf:	e8 d8 0f 00 00       	call   802a9c <close_all>
	sys_env_destroy(0);
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	6a 00                	push   $0x0
  801ac9:	e8 31 0a 00 00       	call   8024ff <sys_env_destroy>
}
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	c9                   	leave  
  801ad2:	c3                   	ret    

00801ad3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ad8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801adb:	8b 35 60 90 80 00    	mov    0x809060,%esi
  801ae1:	e8 5a 0a 00 00       	call   802540 <sys_getenvid>
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	ff 75 0c             	pushl  0xc(%ebp)
  801aec:	ff 75 08             	pushl  0x8(%ebp)
  801aef:	56                   	push   %esi
  801af0:	50                   	push   %eax
  801af1:	68 5c 3e 80 00       	push   $0x803e5c
  801af6:	e8 b1 00 00 00       	call   801bac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801afb:	83 c4 18             	add    $0x18,%esp
  801afe:	53                   	push   %ebx
  801aff:	ff 75 10             	pushl  0x10(%ebp)
  801b02:	e8 54 00 00 00       	call   801b5b <vcprintf>
	cprintf("\n");
  801b07:	c7 04 24 2d 3a 80 00 	movl   $0x803a2d,(%esp)
  801b0e:	e8 99 00 00 00       	call   801bac <cprintf>
  801b13:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b16:	cc                   	int3   
  801b17:	eb fd                	jmp    801b16 <_panic+0x43>

00801b19 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	53                   	push   %ebx
  801b1d:	83 ec 04             	sub    $0x4,%esp
  801b20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b23:	8b 13                	mov    (%ebx),%edx
  801b25:	8d 42 01             	lea    0x1(%edx),%eax
  801b28:	89 03                	mov    %eax,(%ebx)
  801b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801b31:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b36:	75 1a                	jne    801b52 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	68 ff 00 00 00       	push   $0xff
  801b40:	8d 43 08             	lea    0x8(%ebx),%eax
  801b43:	50                   	push   %eax
  801b44:	e8 79 09 00 00       	call   8024c2 <sys_cputs>
		b->idx = 0;
  801b49:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b4f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801b52:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801b56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  801b64:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b6b:	00 00 00 
	b.cnt = 0;
  801b6e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801b75:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801b78:	ff 75 0c             	pushl  0xc(%ebp)
  801b7b:	ff 75 08             	pushl  0x8(%ebp)
  801b7e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801b84:	50                   	push   %eax
  801b85:	68 19 1b 80 00       	push   $0x801b19
  801b8a:	e8 54 01 00 00       	call   801ce3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801b8f:	83 c4 08             	add    $0x8,%esp
  801b92:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801b98:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801b9e:	50                   	push   %eax
  801b9f:	e8 1e 09 00 00       	call   8024c2 <sys_cputs>

	return b.cnt;
}
  801ba4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801baa:	c9                   	leave  
  801bab:	c3                   	ret    

00801bac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bb2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bb5:	50                   	push   %eax
  801bb6:	ff 75 08             	pushl  0x8(%ebp)
  801bb9:	e8 9d ff ff ff       	call   801b5b <vcprintf>
	va_end(ap);

	return cnt;
}
  801bbe:	c9                   	leave  
  801bbf:	c3                   	ret    

00801bc0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	57                   	push   %edi
  801bc4:	56                   	push   %esi
  801bc5:	53                   	push   %ebx
  801bc6:	83 ec 1c             	sub    $0x1c,%esp
  801bc9:	89 c7                	mov    %eax,%edi
  801bcb:	89 d6                	mov    %edx,%esi
  801bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801bd6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801bd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bdc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801be4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801be7:	39 d3                	cmp    %edx,%ebx
  801be9:	72 05                	jb     801bf0 <printnum+0x30>
  801beb:	39 45 10             	cmp    %eax,0x10(%ebp)
  801bee:	77 45                	ja     801c35 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801bf0:	83 ec 0c             	sub    $0xc,%esp
  801bf3:	ff 75 18             	pushl  0x18(%ebp)
  801bf6:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801bfc:	53                   	push   %ebx
  801bfd:	ff 75 10             	pushl  0x10(%ebp)
  801c00:	83 ec 08             	sub    $0x8,%esp
  801c03:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c06:	ff 75 e0             	pushl  -0x20(%ebp)
  801c09:	ff 75 dc             	pushl  -0x24(%ebp)
  801c0c:	ff 75 d8             	pushl  -0x28(%ebp)
  801c0f:	e8 dc 19 00 00       	call   8035f0 <__udivdi3>
  801c14:	83 c4 18             	add    $0x18,%esp
  801c17:	52                   	push   %edx
  801c18:	50                   	push   %eax
  801c19:	89 f2                	mov    %esi,%edx
  801c1b:	89 f8                	mov    %edi,%eax
  801c1d:	e8 9e ff ff ff       	call   801bc0 <printnum>
  801c22:	83 c4 20             	add    $0x20,%esp
  801c25:	eb 18                	jmp    801c3f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c27:	83 ec 08             	sub    $0x8,%esp
  801c2a:	56                   	push   %esi
  801c2b:	ff 75 18             	pushl  0x18(%ebp)
  801c2e:	ff d7                	call   *%edi
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	eb 03                	jmp    801c38 <printnum+0x78>
  801c35:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c38:	83 eb 01             	sub    $0x1,%ebx
  801c3b:	85 db                	test   %ebx,%ebx
  801c3d:	7f e8                	jg     801c27 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c3f:	83 ec 08             	sub    $0x8,%esp
  801c42:	56                   	push   %esi
  801c43:	83 ec 04             	sub    $0x4,%esp
  801c46:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c49:	ff 75 e0             	pushl  -0x20(%ebp)
  801c4c:	ff 75 dc             	pushl  -0x24(%ebp)
  801c4f:	ff 75 d8             	pushl  -0x28(%ebp)
  801c52:	e8 c9 1a 00 00       	call   803720 <__umoddi3>
  801c57:	83 c4 14             	add    $0x14,%esp
  801c5a:	0f be 80 7f 3e 80 00 	movsbl 0x803e7f(%eax),%eax
  801c61:	50                   	push   %eax
  801c62:	ff d7                	call   *%edi
}
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6a:	5b                   	pop    %ebx
  801c6b:	5e                   	pop    %esi
  801c6c:	5f                   	pop    %edi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    

00801c6f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801c6f:	55                   	push   %ebp
  801c70:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801c72:	83 fa 01             	cmp    $0x1,%edx
  801c75:	7e 0e                	jle    801c85 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801c77:	8b 10                	mov    (%eax),%edx
  801c79:	8d 4a 08             	lea    0x8(%edx),%ecx
  801c7c:	89 08                	mov    %ecx,(%eax)
  801c7e:	8b 02                	mov    (%edx),%eax
  801c80:	8b 52 04             	mov    0x4(%edx),%edx
  801c83:	eb 22                	jmp    801ca7 <getuint+0x38>
	else if (lflag)
  801c85:	85 d2                	test   %edx,%edx
  801c87:	74 10                	je     801c99 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801c89:	8b 10                	mov    (%eax),%edx
  801c8b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c8e:	89 08                	mov    %ecx,(%eax)
  801c90:	8b 02                	mov    (%edx),%eax
  801c92:	ba 00 00 00 00       	mov    $0x0,%edx
  801c97:	eb 0e                	jmp    801ca7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801c99:	8b 10                	mov    (%eax),%edx
  801c9b:	8d 4a 04             	lea    0x4(%edx),%ecx
  801c9e:	89 08                	mov    %ecx,(%eax)
  801ca0:	8b 02                	mov    (%edx),%eax
  801ca2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801caf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801cb3:	8b 10                	mov    (%eax),%edx
  801cb5:	3b 50 04             	cmp    0x4(%eax),%edx
  801cb8:	73 0a                	jae    801cc4 <sprintputch+0x1b>
		*b->buf++ = ch;
  801cba:	8d 4a 01             	lea    0x1(%edx),%ecx
  801cbd:	89 08                	mov    %ecx,(%eax)
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	88 02                	mov    %al,(%edx)
}
  801cc4:	5d                   	pop    %ebp
  801cc5:	c3                   	ret    

00801cc6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801ccc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801ccf:	50                   	push   %eax
  801cd0:	ff 75 10             	pushl  0x10(%ebp)
  801cd3:	ff 75 0c             	pushl  0xc(%ebp)
  801cd6:	ff 75 08             	pushl  0x8(%ebp)
  801cd9:	e8 05 00 00 00       	call   801ce3 <vprintfmt>
	va_end(ap);
}
  801cde:	83 c4 10             	add    $0x10,%esp
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	57                   	push   %edi
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	83 ec 2c             	sub    $0x2c,%esp
  801cec:	8b 75 08             	mov    0x8(%ebp),%esi
  801cef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801cf2:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cf5:	eb 12                	jmp    801d09 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	0f 84 d3 03 00 00    	je     8020d2 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  801cff:	83 ec 08             	sub    $0x8,%esp
  801d02:	53                   	push   %ebx
  801d03:	50                   	push   %eax
  801d04:	ff d6                	call   *%esi
  801d06:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d09:	83 c7 01             	add    $0x1,%edi
  801d0c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801d10:	83 f8 25             	cmp    $0x25,%eax
  801d13:	75 e2                	jne    801cf7 <vprintfmt+0x14>
  801d15:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801d19:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801d20:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801d27:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d33:	eb 07                	jmp    801d3c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d35:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801d38:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d3c:	8d 47 01             	lea    0x1(%edi),%eax
  801d3f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d42:	0f b6 07             	movzbl (%edi),%eax
  801d45:	0f b6 c8             	movzbl %al,%ecx
  801d48:	83 e8 23             	sub    $0x23,%eax
  801d4b:	3c 55                	cmp    $0x55,%al
  801d4d:	0f 87 64 03 00 00    	ja     8020b7 <vprintfmt+0x3d4>
  801d53:	0f b6 c0             	movzbl %al,%eax
  801d56:	ff 24 85 c0 3f 80 00 	jmp    *0x803fc0(,%eax,4)
  801d5d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801d60:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801d64:	eb d6                	jmp    801d3c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d69:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801d71:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801d74:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801d78:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801d7b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801d7e:	83 fa 09             	cmp    $0x9,%edx
  801d81:	77 39                	ja     801dbc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801d83:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801d86:	eb e9                	jmp    801d71 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801d88:	8b 45 14             	mov    0x14(%ebp),%eax
  801d8b:	8d 48 04             	lea    0x4(%eax),%ecx
  801d8e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801d91:	8b 00                	mov    (%eax),%eax
  801d93:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801d99:	eb 27                	jmp    801dc2 <vprintfmt+0xdf>
  801d9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801da5:	0f 49 c8             	cmovns %eax,%ecx
  801da8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801dae:	eb 8c                	jmp    801d3c <vprintfmt+0x59>
  801db0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801db3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801dba:	eb 80                	jmp    801d3c <vprintfmt+0x59>
  801dbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801dbf:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  801dc2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801dc6:	0f 89 70 ff ff ff    	jns    801d3c <vprintfmt+0x59>
				width = precision, precision = -1;
  801dcc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801dcf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dd2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801dd9:	e9 5e ff ff ff       	jmp    801d3c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801dde:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801de1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801de4:	e9 53 ff ff ff       	jmp    801d3c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801de9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dec:	8d 50 04             	lea    0x4(%eax),%edx
  801def:	89 55 14             	mov    %edx,0x14(%ebp)
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	53                   	push   %ebx
  801df6:	ff 30                	pushl  (%eax)
  801df8:	ff d6                	call   *%esi
			break;
  801dfa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dfd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801e00:	e9 04 ff ff ff       	jmp    801d09 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801e05:	8b 45 14             	mov    0x14(%ebp),%eax
  801e08:	8d 50 04             	lea    0x4(%eax),%edx
  801e0b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e0e:	8b 00                	mov    (%eax),%eax
  801e10:	99                   	cltd   
  801e11:	31 d0                	xor    %edx,%eax
  801e13:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e15:	83 f8 0f             	cmp    $0xf,%eax
  801e18:	7f 0b                	jg     801e25 <vprintfmt+0x142>
  801e1a:	8b 14 85 20 41 80 00 	mov    0x804120(,%eax,4),%edx
  801e21:	85 d2                	test   %edx,%edx
  801e23:	75 18                	jne    801e3d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801e25:	50                   	push   %eax
  801e26:	68 97 3e 80 00       	push   $0x803e97
  801e2b:	53                   	push   %ebx
  801e2c:	56                   	push   %esi
  801e2d:	e8 94 fe ff ff       	call   801cc6 <printfmt>
  801e32:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e38:	e9 cc fe ff ff       	jmp    801d09 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801e3d:	52                   	push   %edx
  801e3e:	68 cf 38 80 00       	push   $0x8038cf
  801e43:	53                   	push   %ebx
  801e44:	56                   	push   %esi
  801e45:	e8 7c fe ff ff       	call   801cc6 <printfmt>
  801e4a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e50:	e9 b4 fe ff ff       	jmp    801d09 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801e55:	8b 45 14             	mov    0x14(%ebp),%eax
  801e58:	8d 50 04             	lea    0x4(%eax),%edx
  801e5b:	89 55 14             	mov    %edx,0x14(%ebp)
  801e5e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801e60:	85 ff                	test   %edi,%edi
  801e62:	b8 90 3e 80 00       	mov    $0x803e90,%eax
  801e67:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801e6a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801e6e:	0f 8e 94 00 00 00    	jle    801f08 <vprintfmt+0x225>
  801e74:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801e78:	0f 84 98 00 00 00    	je     801f16 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801e7e:	83 ec 08             	sub    $0x8,%esp
  801e81:	ff 75 c8             	pushl  -0x38(%ebp)
  801e84:	57                   	push   %edi
  801e85:	e8 d0 02 00 00       	call   80215a <strnlen>
  801e8a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801e8d:	29 c1                	sub    %eax,%ecx
  801e8f:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801e92:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801e95:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801e99:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e9c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801e9f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801ea1:	eb 0f                	jmp    801eb2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801ea3:	83 ec 08             	sub    $0x8,%esp
  801ea6:	53                   	push   %ebx
  801ea7:	ff 75 e0             	pushl  -0x20(%ebp)
  801eaa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801eac:	83 ef 01             	sub    $0x1,%edi
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	85 ff                	test   %edi,%edi
  801eb4:	7f ed                	jg     801ea3 <vprintfmt+0x1c0>
  801eb6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801eb9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801ebc:	85 c9                	test   %ecx,%ecx
  801ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec3:	0f 49 c1             	cmovns %ecx,%eax
  801ec6:	29 c1                	sub    %eax,%ecx
  801ec8:	89 75 08             	mov    %esi,0x8(%ebp)
  801ecb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801ece:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ed1:	89 cb                	mov    %ecx,%ebx
  801ed3:	eb 4d                	jmp    801f22 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801ed5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801ed9:	74 1b                	je     801ef6 <vprintfmt+0x213>
  801edb:	0f be c0             	movsbl %al,%eax
  801ede:	83 e8 20             	sub    $0x20,%eax
  801ee1:	83 f8 5e             	cmp    $0x5e,%eax
  801ee4:	76 10                	jbe    801ef6 <vprintfmt+0x213>
					putch('?', putdat);
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	ff 75 0c             	pushl  0xc(%ebp)
  801eec:	6a 3f                	push   $0x3f
  801eee:	ff 55 08             	call   *0x8(%ebp)
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	eb 0d                	jmp    801f03 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	ff 75 0c             	pushl  0xc(%ebp)
  801efc:	52                   	push   %edx
  801efd:	ff 55 08             	call   *0x8(%ebp)
  801f00:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f03:	83 eb 01             	sub    $0x1,%ebx
  801f06:	eb 1a                	jmp    801f22 <vprintfmt+0x23f>
  801f08:	89 75 08             	mov    %esi,0x8(%ebp)
  801f0b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801f0e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f11:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f14:	eb 0c                	jmp    801f22 <vprintfmt+0x23f>
  801f16:	89 75 08             	mov    %esi,0x8(%ebp)
  801f19:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801f1c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801f1f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801f22:	83 c7 01             	add    $0x1,%edi
  801f25:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801f29:	0f be d0             	movsbl %al,%edx
  801f2c:	85 d2                	test   %edx,%edx
  801f2e:	74 23                	je     801f53 <vprintfmt+0x270>
  801f30:	85 f6                	test   %esi,%esi
  801f32:	78 a1                	js     801ed5 <vprintfmt+0x1f2>
  801f34:	83 ee 01             	sub    $0x1,%esi
  801f37:	79 9c                	jns    801ed5 <vprintfmt+0x1f2>
  801f39:	89 df                	mov    %ebx,%edi
  801f3b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f41:	eb 18                	jmp    801f5b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f43:	83 ec 08             	sub    $0x8,%esp
  801f46:	53                   	push   %ebx
  801f47:	6a 20                	push   $0x20
  801f49:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f4b:	83 ef 01             	sub    $0x1,%edi
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	eb 08                	jmp    801f5b <vprintfmt+0x278>
  801f53:	89 df                	mov    %ebx,%edi
  801f55:	8b 75 08             	mov    0x8(%ebp),%esi
  801f58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	7f e4                	jg     801f43 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f62:	e9 a2 fd ff ff       	jmp    801d09 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f67:	83 fa 01             	cmp    $0x1,%edx
  801f6a:	7e 16                	jle    801f82 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801f6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f6f:	8d 50 08             	lea    0x8(%eax),%edx
  801f72:	89 55 14             	mov    %edx,0x14(%ebp)
  801f75:	8b 50 04             	mov    0x4(%eax),%edx
  801f78:	8b 00                	mov    (%eax),%eax
  801f7a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801f7d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801f80:	eb 32                	jmp    801fb4 <vprintfmt+0x2d1>
	else if (lflag)
  801f82:	85 d2                	test   %edx,%edx
  801f84:	74 18                	je     801f9e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801f86:	8b 45 14             	mov    0x14(%ebp),%eax
  801f89:	8d 50 04             	lea    0x4(%eax),%edx
  801f8c:	89 55 14             	mov    %edx,0x14(%ebp)
  801f8f:	8b 00                	mov    (%eax),%eax
  801f91:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801f94:	89 c1                	mov    %eax,%ecx
  801f96:	c1 f9 1f             	sar    $0x1f,%ecx
  801f99:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801f9c:	eb 16                	jmp    801fb4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801f9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801fa1:	8d 50 04             	lea    0x4(%eax),%edx
  801fa4:	89 55 14             	mov    %edx,0x14(%ebp)
  801fa7:	8b 00                	mov    (%eax),%eax
  801fa9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801fac:	89 c1                	mov    %eax,%ecx
  801fae:	c1 f9 1f             	sar    $0x1f,%ecx
  801fb1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801fb4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801fb7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801fba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fbd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801fc0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801fc5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801fc9:	0f 89 b0 00 00 00    	jns    80207f <vprintfmt+0x39c>
				putch('-', putdat);
  801fcf:	83 ec 08             	sub    $0x8,%esp
  801fd2:	53                   	push   %ebx
  801fd3:	6a 2d                	push   $0x2d
  801fd5:	ff d6                	call   *%esi
				num = -(long long) num;
  801fd7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801fda:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801fdd:	f7 d8                	neg    %eax
  801fdf:	83 d2 00             	adc    $0x0,%edx
  801fe2:	f7 da                	neg    %edx
  801fe4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801fe7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801fea:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801fed:	b8 0a 00 00 00       	mov    $0xa,%eax
  801ff2:	e9 88 00 00 00       	jmp    80207f <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ff7:	8d 45 14             	lea    0x14(%ebp),%eax
  801ffa:	e8 70 fc ff ff       	call   801c6f <getuint>
  801fff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802002:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  802005:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80200a:	eb 73                	jmp    80207f <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80200c:	8d 45 14             	lea    0x14(%ebp),%eax
  80200f:	e8 5b fc ff ff       	call   801c6f <getuint>
  802014:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802017:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80201a:	83 ec 08             	sub    $0x8,%esp
  80201d:	53                   	push   %ebx
  80201e:	6a 58                	push   $0x58
  802020:	ff d6                	call   *%esi
			putch('X', putdat);
  802022:	83 c4 08             	add    $0x8,%esp
  802025:	53                   	push   %ebx
  802026:	6a 58                	push   $0x58
  802028:	ff d6                	call   *%esi
			putch('X', putdat);
  80202a:	83 c4 08             	add    $0x8,%esp
  80202d:	53                   	push   %ebx
  80202e:	6a 58                	push   $0x58
  802030:	ff d6                	call   *%esi
			goto number;
  802032:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  802035:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80203a:	eb 43                	jmp    80207f <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80203c:	83 ec 08             	sub    $0x8,%esp
  80203f:	53                   	push   %ebx
  802040:	6a 30                	push   $0x30
  802042:	ff d6                	call   *%esi
			putch('x', putdat);
  802044:	83 c4 08             	add    $0x8,%esp
  802047:	53                   	push   %ebx
  802048:	6a 78                	push   $0x78
  80204a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80204c:	8b 45 14             	mov    0x14(%ebp),%eax
  80204f:	8d 50 04             	lea    0x4(%eax),%edx
  802052:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802055:	8b 00                	mov    (%eax),%eax
  802057:	ba 00 00 00 00       	mov    $0x0,%edx
  80205c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80205f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802062:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  802065:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80206a:	eb 13                	jmp    80207f <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80206c:	8d 45 14             	lea    0x14(%ebp),%eax
  80206f:	e8 fb fb ff ff       	call   801c6f <getuint>
  802074:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802077:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80207a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80207f:	83 ec 0c             	sub    $0xc,%esp
  802082:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  802086:	52                   	push   %edx
  802087:	ff 75 e0             	pushl  -0x20(%ebp)
  80208a:	50                   	push   %eax
  80208b:	ff 75 dc             	pushl  -0x24(%ebp)
  80208e:	ff 75 d8             	pushl  -0x28(%ebp)
  802091:	89 da                	mov    %ebx,%edx
  802093:	89 f0                	mov    %esi,%eax
  802095:	e8 26 fb ff ff       	call   801bc0 <printnum>
			break;
  80209a:	83 c4 20             	add    $0x20,%esp
  80209d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8020a0:	e9 64 fc ff ff       	jmp    801d09 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020a5:	83 ec 08             	sub    $0x8,%esp
  8020a8:	53                   	push   %ebx
  8020a9:	51                   	push   %ecx
  8020aa:	ff d6                	call   *%esi
			break;
  8020ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020b2:	e9 52 fc ff ff       	jmp    801d09 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020b7:	83 ec 08             	sub    $0x8,%esp
  8020ba:	53                   	push   %ebx
  8020bb:	6a 25                	push   $0x25
  8020bd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020bf:	83 c4 10             	add    $0x10,%esp
  8020c2:	eb 03                	jmp    8020c7 <vprintfmt+0x3e4>
  8020c4:	83 ef 01             	sub    $0x1,%edi
  8020c7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8020cb:	75 f7                	jne    8020c4 <vprintfmt+0x3e1>
  8020cd:	e9 37 fc ff ff       	jmp    801d09 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8020d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d5:	5b                   	pop    %ebx
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	5d                   	pop    %ebp
  8020d9:	c3                   	ret    

008020da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020da:	55                   	push   %ebp
  8020db:	89 e5                	mov    %esp,%ebp
  8020dd:	83 ec 18             	sub    $0x18,%esp
  8020e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8020e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8020ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	74 26                	je     802121 <vsnprintf+0x47>
  8020fb:	85 d2                	test   %edx,%edx
  8020fd:	7e 22                	jle    802121 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8020ff:	ff 75 14             	pushl  0x14(%ebp)
  802102:	ff 75 10             	pushl  0x10(%ebp)
  802105:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802108:	50                   	push   %eax
  802109:	68 a9 1c 80 00       	push   $0x801ca9
  80210e:	e8 d0 fb ff ff       	call   801ce3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802113:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802116:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802119:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211c:	83 c4 10             	add    $0x10,%esp
  80211f:	eb 05                	jmp    802126 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802121:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802126:	c9                   	leave  
  802127:	c3                   	ret    

00802128 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80212e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  802131:	50                   	push   %eax
  802132:	ff 75 10             	pushl  0x10(%ebp)
  802135:	ff 75 0c             	pushl  0xc(%ebp)
  802138:	ff 75 08             	pushl  0x8(%ebp)
  80213b:	e8 9a ff ff ff       	call   8020da <vsnprintf>
	va_end(ap);

	return rc;
}
  802140:	c9                   	leave  
  802141:	c3                   	ret    

00802142 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802142:	55                   	push   %ebp
  802143:	89 e5                	mov    %esp,%ebp
  802145:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802148:	b8 00 00 00 00       	mov    $0x0,%eax
  80214d:	eb 03                	jmp    802152 <strlen+0x10>
		n++;
  80214f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802152:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802156:	75 f7                	jne    80214f <strlen+0xd>
		n++;
	return n;
}
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    

0080215a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80215a:	55                   	push   %ebp
  80215b:	89 e5                	mov    %esp,%ebp
  80215d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802160:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802163:	ba 00 00 00 00       	mov    $0x0,%edx
  802168:	eb 03                	jmp    80216d <strnlen+0x13>
		n++;
  80216a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80216d:	39 c2                	cmp    %eax,%edx
  80216f:	74 08                	je     802179 <strnlen+0x1f>
  802171:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802175:	75 f3                	jne    80216a <strnlen+0x10>
  802177:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802179:	5d                   	pop    %ebp
  80217a:	c3                   	ret    

0080217b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80217b:	55                   	push   %ebp
  80217c:	89 e5                	mov    %esp,%ebp
  80217e:	53                   	push   %ebx
  80217f:	8b 45 08             	mov    0x8(%ebp),%eax
  802182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802185:	89 c2                	mov    %eax,%edx
  802187:	83 c2 01             	add    $0x1,%edx
  80218a:	83 c1 01             	add    $0x1,%ecx
  80218d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  802191:	88 5a ff             	mov    %bl,-0x1(%edx)
  802194:	84 db                	test   %bl,%bl
  802196:	75 ef                	jne    802187 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802198:	5b                   	pop    %ebx
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	53                   	push   %ebx
  80219f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8021a2:	53                   	push   %ebx
  8021a3:	e8 9a ff ff ff       	call   802142 <strlen>
  8021a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8021ab:	ff 75 0c             	pushl  0xc(%ebp)
  8021ae:	01 d8                	add    %ebx,%eax
  8021b0:	50                   	push   %eax
  8021b1:	e8 c5 ff ff ff       	call   80217b <strcpy>
	return dst;
}
  8021b6:	89 d8                	mov    %ebx,%eax
  8021b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021bb:	c9                   	leave  
  8021bc:	c3                   	ret    

008021bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8021bd:	55                   	push   %ebp
  8021be:	89 e5                	mov    %esp,%ebp
  8021c0:	56                   	push   %esi
  8021c1:	53                   	push   %ebx
  8021c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8021c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021c8:	89 f3                	mov    %esi,%ebx
  8021ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	eb 0f                	jmp    8021e0 <strncpy+0x23>
		*dst++ = *src;
  8021d1:	83 c2 01             	add    $0x1,%edx
  8021d4:	0f b6 01             	movzbl (%ecx),%eax
  8021d7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8021da:	80 39 01             	cmpb   $0x1,(%ecx)
  8021dd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8021e0:	39 da                	cmp    %ebx,%edx
  8021e2:	75 ed                	jne    8021d1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8021e4:	89 f0                	mov    %esi,%eax
  8021e6:	5b                   	pop    %ebx
  8021e7:	5e                   	pop    %esi
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    

008021ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8021ea:	55                   	push   %ebp
  8021eb:	89 e5                	mov    %esp,%ebp
  8021ed:	56                   	push   %esi
  8021ee:	53                   	push   %ebx
  8021ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8021f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8021f8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8021fa:	85 d2                	test   %edx,%edx
  8021fc:	74 21                	je     80221f <strlcpy+0x35>
  8021fe:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	eb 09                	jmp    80220f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  802206:	83 c2 01             	add    $0x1,%edx
  802209:	83 c1 01             	add    $0x1,%ecx
  80220c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80220f:	39 c2                	cmp    %eax,%edx
  802211:	74 09                	je     80221c <strlcpy+0x32>
  802213:	0f b6 19             	movzbl (%ecx),%ebx
  802216:	84 db                	test   %bl,%bl
  802218:	75 ec                	jne    802206 <strlcpy+0x1c>
  80221a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80221c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80221f:	29 f0                	sub    %esi,%eax
}
  802221:	5b                   	pop    %ebx
  802222:	5e                   	pop    %esi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80222b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80222e:	eb 06                	jmp    802236 <strcmp+0x11>
		p++, q++;
  802230:	83 c1 01             	add    $0x1,%ecx
  802233:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802236:	0f b6 01             	movzbl (%ecx),%eax
  802239:	84 c0                	test   %al,%al
  80223b:	74 04                	je     802241 <strcmp+0x1c>
  80223d:	3a 02                	cmp    (%edx),%al
  80223f:	74 ef                	je     802230 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802241:	0f b6 c0             	movzbl %al,%eax
  802244:	0f b6 12             	movzbl (%edx),%edx
  802247:	29 d0                	sub    %edx,%eax
}
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	53                   	push   %ebx
  80224f:	8b 45 08             	mov    0x8(%ebp),%eax
  802252:	8b 55 0c             	mov    0xc(%ebp),%edx
  802255:	89 c3                	mov    %eax,%ebx
  802257:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80225a:	eb 06                	jmp    802262 <strncmp+0x17>
		n--, p++, q++;
  80225c:	83 c0 01             	add    $0x1,%eax
  80225f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802262:	39 d8                	cmp    %ebx,%eax
  802264:	74 15                	je     80227b <strncmp+0x30>
  802266:	0f b6 08             	movzbl (%eax),%ecx
  802269:	84 c9                	test   %cl,%cl
  80226b:	74 04                	je     802271 <strncmp+0x26>
  80226d:	3a 0a                	cmp    (%edx),%cl
  80226f:	74 eb                	je     80225c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802271:	0f b6 00             	movzbl (%eax),%eax
  802274:	0f b6 12             	movzbl (%edx),%edx
  802277:	29 d0                	sub    %edx,%eax
  802279:	eb 05                	jmp    802280 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80227b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802280:	5b                   	pop    %ebx
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	8b 45 08             	mov    0x8(%ebp),%eax
  802289:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80228d:	eb 07                	jmp    802296 <strchr+0x13>
		if (*s == c)
  80228f:	38 ca                	cmp    %cl,%dl
  802291:	74 0f                	je     8022a2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802293:	83 c0 01             	add    $0x1,%eax
  802296:	0f b6 10             	movzbl (%eax),%edx
  802299:	84 d2                	test   %dl,%dl
  80229b:	75 f2                	jne    80228f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80229d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    

008022a4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8022ae:	eb 03                	jmp    8022b3 <strfind+0xf>
  8022b0:	83 c0 01             	add    $0x1,%eax
  8022b3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8022b6:	38 ca                	cmp    %cl,%dl
  8022b8:	74 04                	je     8022be <strfind+0x1a>
  8022ba:	84 d2                	test   %dl,%dl
  8022bc:	75 f2                	jne    8022b0 <strfind+0xc>
			break;
	return (char *) s;
}
  8022be:	5d                   	pop    %ebp
  8022bf:	c3                   	ret    

008022c0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	57                   	push   %edi
  8022c4:	56                   	push   %esi
  8022c5:	53                   	push   %ebx
  8022c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8022cc:	85 c9                	test   %ecx,%ecx
  8022ce:	74 36                	je     802306 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8022d0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8022d6:	75 28                	jne    802300 <memset+0x40>
  8022d8:	f6 c1 03             	test   $0x3,%cl
  8022db:	75 23                	jne    802300 <memset+0x40>
		c &= 0xFF;
  8022dd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8022e1:	89 d3                	mov    %edx,%ebx
  8022e3:	c1 e3 08             	shl    $0x8,%ebx
  8022e6:	89 d6                	mov    %edx,%esi
  8022e8:	c1 e6 18             	shl    $0x18,%esi
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	c1 e0 10             	shl    $0x10,%eax
  8022f0:	09 f0                	or     %esi,%eax
  8022f2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8022f4:	89 d8                	mov    %ebx,%eax
  8022f6:	09 d0                	or     %edx,%eax
  8022f8:	c1 e9 02             	shr    $0x2,%ecx
  8022fb:	fc                   	cld    
  8022fc:	f3 ab                	rep stos %eax,%es:(%edi)
  8022fe:	eb 06                	jmp    802306 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802300:	8b 45 0c             	mov    0xc(%ebp),%eax
  802303:	fc                   	cld    
  802304:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802306:	89 f8                	mov    %edi,%eax
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	57                   	push   %edi
  802311:	56                   	push   %esi
  802312:	8b 45 08             	mov    0x8(%ebp),%eax
  802315:	8b 75 0c             	mov    0xc(%ebp),%esi
  802318:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80231b:	39 c6                	cmp    %eax,%esi
  80231d:	73 35                	jae    802354 <memmove+0x47>
  80231f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802322:	39 d0                	cmp    %edx,%eax
  802324:	73 2e                	jae    802354 <memmove+0x47>
		s += n;
		d += n;
  802326:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802329:	89 d6                	mov    %edx,%esi
  80232b:	09 fe                	or     %edi,%esi
  80232d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802333:	75 13                	jne    802348 <memmove+0x3b>
  802335:	f6 c1 03             	test   $0x3,%cl
  802338:	75 0e                	jne    802348 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80233a:	83 ef 04             	sub    $0x4,%edi
  80233d:	8d 72 fc             	lea    -0x4(%edx),%esi
  802340:	c1 e9 02             	shr    $0x2,%ecx
  802343:	fd                   	std    
  802344:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802346:	eb 09                	jmp    802351 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802348:	83 ef 01             	sub    $0x1,%edi
  80234b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80234e:	fd                   	std    
  80234f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802351:	fc                   	cld    
  802352:	eb 1d                	jmp    802371 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802354:	89 f2                	mov    %esi,%edx
  802356:	09 c2                	or     %eax,%edx
  802358:	f6 c2 03             	test   $0x3,%dl
  80235b:	75 0f                	jne    80236c <memmove+0x5f>
  80235d:	f6 c1 03             	test   $0x3,%cl
  802360:	75 0a                	jne    80236c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  802362:	c1 e9 02             	shr    $0x2,%ecx
  802365:	89 c7                	mov    %eax,%edi
  802367:	fc                   	cld    
  802368:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80236a:	eb 05                	jmp    802371 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80236c:	89 c7                	mov    %eax,%edi
  80236e:	fc                   	cld    
  80236f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802371:	5e                   	pop    %esi
  802372:	5f                   	pop    %edi
  802373:	5d                   	pop    %ebp
  802374:	c3                   	ret    

00802375 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802378:	ff 75 10             	pushl  0x10(%ebp)
  80237b:	ff 75 0c             	pushl  0xc(%ebp)
  80237e:	ff 75 08             	pushl  0x8(%ebp)
  802381:	e8 87 ff ff ff       	call   80230d <memmove>
}
  802386:	c9                   	leave  
  802387:	c3                   	ret    

00802388 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	56                   	push   %esi
  80238c:	53                   	push   %ebx
  80238d:	8b 45 08             	mov    0x8(%ebp),%eax
  802390:	8b 55 0c             	mov    0xc(%ebp),%edx
  802393:	89 c6                	mov    %eax,%esi
  802395:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802398:	eb 1a                	jmp    8023b4 <memcmp+0x2c>
		if (*s1 != *s2)
  80239a:	0f b6 08             	movzbl (%eax),%ecx
  80239d:	0f b6 1a             	movzbl (%edx),%ebx
  8023a0:	38 d9                	cmp    %bl,%cl
  8023a2:	74 0a                	je     8023ae <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8023a4:	0f b6 c1             	movzbl %cl,%eax
  8023a7:	0f b6 db             	movzbl %bl,%ebx
  8023aa:	29 d8                	sub    %ebx,%eax
  8023ac:	eb 0f                	jmp    8023bd <memcmp+0x35>
		s1++, s2++;
  8023ae:	83 c0 01             	add    $0x1,%eax
  8023b1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8023b4:	39 f0                	cmp    %esi,%eax
  8023b6:	75 e2                	jne    80239a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8023b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    

008023c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	53                   	push   %ebx
  8023c5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8023c8:	89 c1                	mov    %eax,%ecx
  8023ca:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8023cd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023d1:	eb 0a                	jmp    8023dd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8023d3:	0f b6 10             	movzbl (%eax),%edx
  8023d6:	39 da                	cmp    %ebx,%edx
  8023d8:	74 07                	je     8023e1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8023da:	83 c0 01             	add    $0x1,%eax
  8023dd:	39 c8                	cmp    %ecx,%eax
  8023df:	72 f2                	jb     8023d3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8023e1:	5b                   	pop    %ebx
  8023e2:	5d                   	pop    %ebp
  8023e3:	c3                   	ret    

008023e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8023e4:	55                   	push   %ebp
  8023e5:	89 e5                	mov    %esp,%ebp
  8023e7:	57                   	push   %edi
  8023e8:	56                   	push   %esi
  8023e9:	53                   	push   %ebx
  8023ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023f0:	eb 03                	jmp    8023f5 <strtol+0x11>
		s++;
  8023f2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8023f5:	0f b6 01             	movzbl (%ecx),%eax
  8023f8:	3c 20                	cmp    $0x20,%al
  8023fa:	74 f6                	je     8023f2 <strtol+0xe>
  8023fc:	3c 09                	cmp    $0x9,%al
  8023fe:	74 f2                	je     8023f2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802400:	3c 2b                	cmp    $0x2b,%al
  802402:	75 0a                	jne    80240e <strtol+0x2a>
		s++;
  802404:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802407:	bf 00 00 00 00       	mov    $0x0,%edi
  80240c:	eb 11                	jmp    80241f <strtol+0x3b>
  80240e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802413:	3c 2d                	cmp    $0x2d,%al
  802415:	75 08                	jne    80241f <strtol+0x3b>
		s++, neg = 1;
  802417:	83 c1 01             	add    $0x1,%ecx
  80241a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80241f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802425:	75 15                	jne    80243c <strtol+0x58>
  802427:	80 39 30             	cmpb   $0x30,(%ecx)
  80242a:	75 10                	jne    80243c <strtol+0x58>
  80242c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  802430:	75 7c                	jne    8024ae <strtol+0xca>
		s += 2, base = 16;
  802432:	83 c1 02             	add    $0x2,%ecx
  802435:	bb 10 00 00 00       	mov    $0x10,%ebx
  80243a:	eb 16                	jmp    802452 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80243c:	85 db                	test   %ebx,%ebx
  80243e:	75 12                	jne    802452 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802440:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802445:	80 39 30             	cmpb   $0x30,(%ecx)
  802448:	75 08                	jne    802452 <strtol+0x6e>
		s++, base = 8;
  80244a:	83 c1 01             	add    $0x1,%ecx
  80244d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802452:	b8 00 00 00 00       	mov    $0x0,%eax
  802457:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80245a:	0f b6 11             	movzbl (%ecx),%edx
  80245d:	8d 72 d0             	lea    -0x30(%edx),%esi
  802460:	89 f3                	mov    %esi,%ebx
  802462:	80 fb 09             	cmp    $0x9,%bl
  802465:	77 08                	ja     80246f <strtol+0x8b>
			dig = *s - '0';
  802467:	0f be d2             	movsbl %dl,%edx
  80246a:	83 ea 30             	sub    $0x30,%edx
  80246d:	eb 22                	jmp    802491 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80246f:	8d 72 9f             	lea    -0x61(%edx),%esi
  802472:	89 f3                	mov    %esi,%ebx
  802474:	80 fb 19             	cmp    $0x19,%bl
  802477:	77 08                	ja     802481 <strtol+0x9d>
			dig = *s - 'a' + 10;
  802479:	0f be d2             	movsbl %dl,%edx
  80247c:	83 ea 57             	sub    $0x57,%edx
  80247f:	eb 10                	jmp    802491 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  802481:	8d 72 bf             	lea    -0x41(%edx),%esi
  802484:	89 f3                	mov    %esi,%ebx
  802486:	80 fb 19             	cmp    $0x19,%bl
  802489:	77 16                	ja     8024a1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  80248b:	0f be d2             	movsbl %dl,%edx
  80248e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  802491:	3b 55 10             	cmp    0x10(%ebp),%edx
  802494:	7d 0b                	jge    8024a1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802496:	83 c1 01             	add    $0x1,%ecx
  802499:	0f af 45 10          	imul   0x10(%ebp),%eax
  80249d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80249f:	eb b9                	jmp    80245a <strtol+0x76>

	if (endptr)
  8024a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024a5:	74 0d                	je     8024b4 <strtol+0xd0>
		*endptr = (char *) s;
  8024a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024aa:	89 0e                	mov    %ecx,(%esi)
  8024ac:	eb 06                	jmp    8024b4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8024ae:	85 db                	test   %ebx,%ebx
  8024b0:	74 98                	je     80244a <strtol+0x66>
  8024b2:	eb 9e                	jmp    802452 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8024b4:	89 c2                	mov    %eax,%edx
  8024b6:	f7 da                	neg    %edx
  8024b8:	85 ff                	test   %edi,%edi
  8024ba:	0f 45 c2             	cmovne %edx,%eax
}
  8024bd:	5b                   	pop    %ebx
  8024be:	5e                   	pop    %esi
  8024bf:	5f                   	pop    %edi
  8024c0:	5d                   	pop    %ebp
  8024c1:	c3                   	ret    

008024c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8024c2:	55                   	push   %ebp
  8024c3:	89 e5                	mov    %esp,%ebp
  8024c5:	57                   	push   %edi
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8024c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8024cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8024d3:	89 c3                	mov    %eax,%ebx
  8024d5:	89 c7                	mov    %eax,%edi
  8024d7:	89 c6                	mov    %eax,%esi
  8024d9:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8024db:	5b                   	pop    %ebx
  8024dc:	5e                   	pop    %esi
  8024dd:	5f                   	pop    %edi
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    

008024e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	57                   	push   %edi
  8024e4:	56                   	push   %esi
  8024e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8024e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8024eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f0:	89 d1                	mov    %edx,%ecx
  8024f2:	89 d3                	mov    %edx,%ebx
  8024f4:	89 d7                	mov    %edx,%edi
  8024f6:	89 d6                	mov    %edx,%esi
  8024f8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8024fa:	5b                   	pop    %ebx
  8024fb:	5e                   	pop    %esi
  8024fc:	5f                   	pop    %edi
  8024fd:	5d                   	pop    %ebp
  8024fe:	c3                   	ret    

008024ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8024ff:	55                   	push   %ebp
  802500:	89 e5                	mov    %esp,%ebp
  802502:	57                   	push   %edi
  802503:	56                   	push   %esi
  802504:	53                   	push   %ebx
  802505:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  802508:	b9 00 00 00 00       	mov    $0x0,%ecx
  80250d:	b8 03 00 00 00       	mov    $0x3,%eax
  802512:	8b 55 08             	mov    0x8(%ebp),%edx
  802515:	89 cb                	mov    %ecx,%ebx
  802517:	89 cf                	mov    %ecx,%edi
  802519:	89 ce                	mov    %ecx,%esi
  80251b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80251d:	85 c0                	test   %eax,%eax
  80251f:	7e 17                	jle    802538 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802521:	83 ec 0c             	sub    $0xc,%esp
  802524:	50                   	push   %eax
  802525:	6a 03                	push   $0x3
  802527:	68 7f 41 80 00       	push   $0x80417f
  80252c:	6a 23                	push   $0x23
  80252e:	68 9c 41 80 00       	push   $0x80419c
  802533:	e8 9b f5 ff ff       	call   801ad3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802538:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80253b:	5b                   	pop    %ebx
  80253c:	5e                   	pop    %esi
  80253d:	5f                   	pop    %edi
  80253e:	5d                   	pop    %ebp
  80253f:	c3                   	ret    

00802540 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	57                   	push   %edi
  802544:	56                   	push   %esi
  802545:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  802546:	ba 00 00 00 00       	mov    $0x0,%edx
  80254b:	b8 02 00 00 00       	mov    $0x2,%eax
  802550:	89 d1                	mov    %edx,%ecx
  802552:	89 d3                	mov    %edx,%ebx
  802554:	89 d7                	mov    %edx,%edi
  802556:	89 d6                	mov    %edx,%esi
  802558:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80255a:	5b                   	pop    %ebx
  80255b:	5e                   	pop    %esi
  80255c:	5f                   	pop    %edi
  80255d:	5d                   	pop    %ebp
  80255e:	c3                   	ret    

0080255f <sys_yield>:

void
sys_yield(void)
{
  80255f:	55                   	push   %ebp
  802560:	89 e5                	mov    %esp,%ebp
  802562:	57                   	push   %edi
  802563:	56                   	push   %esi
  802564:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  802565:	ba 00 00 00 00       	mov    $0x0,%edx
  80256a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80256f:	89 d1                	mov    %edx,%ecx
  802571:	89 d3                	mov    %edx,%ebx
  802573:	89 d7                	mov    %edx,%edi
  802575:	89 d6                	mov    %edx,%esi
  802577:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802579:	5b                   	pop    %ebx
  80257a:	5e                   	pop    %esi
  80257b:	5f                   	pop    %edi
  80257c:	5d                   	pop    %ebp
  80257d:	c3                   	ret    

0080257e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  802587:	be 00 00 00 00       	mov    $0x0,%esi
  80258c:	b8 04 00 00 00       	mov    $0x4,%eax
  802591:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802594:	8b 55 08             	mov    0x8(%ebp),%edx
  802597:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80259a:	89 f7                	mov    %esi,%edi
  80259c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80259e:	85 c0                	test   %eax,%eax
  8025a0:	7e 17                	jle    8025b9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025a2:	83 ec 0c             	sub    $0xc,%esp
  8025a5:	50                   	push   %eax
  8025a6:	6a 04                	push   $0x4
  8025a8:	68 7f 41 80 00       	push   $0x80417f
  8025ad:	6a 23                	push   $0x23
  8025af:	68 9c 41 80 00       	push   $0x80419c
  8025b4:	e8 1a f5 ff ff       	call   801ad3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8025b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025bc:	5b                   	pop    %ebx
  8025bd:	5e                   	pop    %esi
  8025be:	5f                   	pop    %edi
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    

008025c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8025c1:	55                   	push   %ebp
  8025c2:	89 e5                	mov    %esp,%ebp
  8025c4:	57                   	push   %edi
  8025c5:	56                   	push   %esi
  8025c6:	53                   	push   %ebx
  8025c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8025ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8025cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8025d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025db:	8b 75 18             	mov    0x18(%ebp),%esi
  8025de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8025e0:	85 c0                	test   %eax,%eax
  8025e2:	7e 17                	jle    8025fb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025e4:	83 ec 0c             	sub    $0xc,%esp
  8025e7:	50                   	push   %eax
  8025e8:	6a 05                	push   $0x5
  8025ea:	68 7f 41 80 00       	push   $0x80417f
  8025ef:	6a 23                	push   $0x23
  8025f1:	68 9c 41 80 00       	push   $0x80419c
  8025f6:	e8 d8 f4 ff ff       	call   801ad3 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8025fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025fe:	5b                   	pop    %ebx
  8025ff:	5e                   	pop    %esi
  802600:	5f                   	pop    %edi
  802601:	5d                   	pop    %ebp
  802602:	c3                   	ret    

00802603 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802603:	55                   	push   %ebp
  802604:	89 e5                	mov    %esp,%ebp
  802606:	57                   	push   %edi
  802607:	56                   	push   %esi
  802608:	53                   	push   %ebx
  802609:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80260c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802611:	b8 06 00 00 00       	mov    $0x6,%eax
  802616:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802619:	8b 55 08             	mov    0x8(%ebp),%edx
  80261c:	89 df                	mov    %ebx,%edi
  80261e:	89 de                	mov    %ebx,%esi
  802620:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  802622:	85 c0                	test   %eax,%eax
  802624:	7e 17                	jle    80263d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802626:	83 ec 0c             	sub    $0xc,%esp
  802629:	50                   	push   %eax
  80262a:	6a 06                	push   $0x6
  80262c:	68 7f 41 80 00       	push   $0x80417f
  802631:	6a 23                	push   $0x23
  802633:	68 9c 41 80 00       	push   $0x80419c
  802638:	e8 96 f4 ff ff       	call   801ad3 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80263d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802640:	5b                   	pop    %ebx
  802641:	5e                   	pop    %esi
  802642:	5f                   	pop    %edi
  802643:	5d                   	pop    %ebp
  802644:	c3                   	ret    

00802645 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802645:	55                   	push   %ebp
  802646:	89 e5                	mov    %esp,%ebp
  802648:	57                   	push   %edi
  802649:	56                   	push   %esi
  80264a:	53                   	push   %ebx
  80264b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80264e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802653:	b8 08 00 00 00       	mov    $0x8,%eax
  802658:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80265b:	8b 55 08             	mov    0x8(%ebp),%edx
  80265e:	89 df                	mov    %ebx,%edi
  802660:	89 de                	mov    %ebx,%esi
  802662:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  802664:	85 c0                	test   %eax,%eax
  802666:	7e 17                	jle    80267f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802668:	83 ec 0c             	sub    $0xc,%esp
  80266b:	50                   	push   %eax
  80266c:	6a 08                	push   $0x8
  80266e:	68 7f 41 80 00       	push   $0x80417f
  802673:	6a 23                	push   $0x23
  802675:	68 9c 41 80 00       	push   $0x80419c
  80267a:	e8 54 f4 ff ff       	call   801ad3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80267f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802682:	5b                   	pop    %ebx
  802683:	5e                   	pop    %esi
  802684:	5f                   	pop    %edi
  802685:	5d                   	pop    %ebp
  802686:	c3                   	ret    

00802687 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802687:	55                   	push   %ebp
  802688:	89 e5                	mov    %esp,%ebp
  80268a:	57                   	push   %edi
  80268b:	56                   	push   %esi
  80268c:	53                   	push   %ebx
  80268d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  802690:	bb 00 00 00 00       	mov    $0x0,%ebx
  802695:	b8 09 00 00 00       	mov    $0x9,%eax
  80269a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80269d:	8b 55 08             	mov    0x8(%ebp),%edx
  8026a0:	89 df                	mov    %ebx,%edi
  8026a2:	89 de                	mov    %ebx,%esi
  8026a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8026a6:	85 c0                	test   %eax,%eax
  8026a8:	7e 17                	jle    8026c1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026aa:	83 ec 0c             	sub    $0xc,%esp
  8026ad:	50                   	push   %eax
  8026ae:	6a 09                	push   $0x9
  8026b0:	68 7f 41 80 00       	push   $0x80417f
  8026b5:	6a 23                	push   $0x23
  8026b7:	68 9c 41 80 00       	push   $0x80419c
  8026bc:	e8 12 f4 ff ff       	call   801ad3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8026c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8026c4:	5b                   	pop    %ebx
  8026c5:	5e                   	pop    %esi
  8026c6:	5f                   	pop    %edi
  8026c7:	5d                   	pop    %ebp
  8026c8:	c3                   	ret    

008026c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8026c9:	55                   	push   %ebp
  8026ca:	89 e5                	mov    %esp,%ebp
  8026cc:	57                   	push   %edi
  8026cd:	56                   	push   %esi
  8026ce:	53                   	push   %ebx
  8026cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8026d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8026dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026df:	8b 55 08             	mov    0x8(%ebp),%edx
  8026e2:	89 df                	mov    %ebx,%edi
  8026e4:	89 de                	mov    %ebx,%esi
  8026e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8026e8:	85 c0                	test   %eax,%eax
  8026ea:	7e 17                	jle    802703 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026ec:	83 ec 0c             	sub    $0xc,%esp
  8026ef:	50                   	push   %eax
  8026f0:	6a 0a                	push   $0xa
  8026f2:	68 7f 41 80 00       	push   $0x80417f
  8026f7:	6a 23                	push   $0x23
  8026f9:	68 9c 41 80 00       	push   $0x80419c
  8026fe:	e8 d0 f3 ff ff       	call   801ad3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802706:	5b                   	pop    %ebx
  802707:	5e                   	pop    %esi
  802708:	5f                   	pop    %edi
  802709:	5d                   	pop    %ebp
  80270a:	c3                   	ret    

0080270b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80270b:	55                   	push   %ebp
  80270c:	89 e5                	mov    %esp,%ebp
  80270e:	57                   	push   %edi
  80270f:	56                   	push   %esi
  802710:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  802711:	be 00 00 00 00       	mov    $0x0,%esi
  802716:	b8 0c 00 00 00       	mov    $0xc,%eax
  80271b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80271e:	8b 55 08             	mov    0x8(%ebp),%edx
  802721:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802724:	8b 7d 14             	mov    0x14(%ebp),%edi
  802727:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802729:	5b                   	pop    %ebx
  80272a:	5e                   	pop    %esi
  80272b:	5f                   	pop    %edi
  80272c:	5d                   	pop    %ebp
  80272d:	c3                   	ret    

0080272e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80272e:	55                   	push   %ebp
  80272f:	89 e5                	mov    %esp,%ebp
  802731:	57                   	push   %edi
  802732:	56                   	push   %esi
  802733:	53                   	push   %ebx
  802734:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  802737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80273c:	b8 0d 00 00 00       	mov    $0xd,%eax
  802741:	8b 55 08             	mov    0x8(%ebp),%edx
  802744:	89 cb                	mov    %ecx,%ebx
  802746:	89 cf                	mov    %ecx,%edi
  802748:	89 ce                	mov    %ecx,%esi
  80274a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80274c:	85 c0                	test   %eax,%eax
  80274e:	7e 17                	jle    802767 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  802750:	83 ec 0c             	sub    $0xc,%esp
  802753:	50                   	push   %eax
  802754:	6a 0d                	push   $0xd
  802756:	68 7f 41 80 00       	push   $0x80417f
  80275b:	6a 23                	push   $0x23
  80275d:	68 9c 41 80 00       	push   $0x80419c
  802762:	e8 6c f3 ff ff       	call   801ad3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802767:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80276a:	5b                   	pop    %ebx
  80276b:	5e                   	pop    %esi
  80276c:	5f                   	pop    %edi
  80276d:	5d                   	pop    %ebp
  80276e:	c3                   	ret    

0080276f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80276f:	55                   	push   %ebp
  802770:	89 e5                	mov    %esp,%ebp
  802772:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  802775:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  80277c:	75 4c                	jne    8027ca <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  80277e:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802783:	8b 40 48             	mov    0x48(%eax),%eax
  802786:	83 ec 04             	sub    $0x4,%esp
  802789:	6a 07                	push   $0x7
  80278b:	68 00 f0 bf ee       	push   $0xeebff000
  802790:	50                   	push   %eax
  802791:	e8 e8 fd ff ff       	call   80257e <sys_page_alloc>
		if(retv != 0){
  802796:	83 c4 10             	add    $0x10,%esp
  802799:	85 c0                	test   %eax,%eax
  80279b:	74 14                	je     8027b1 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  80279d:	83 ec 04             	sub    $0x4,%esp
  8027a0:	68 ac 41 80 00       	push   $0x8041ac
  8027a5:	6a 27                	push   $0x27
  8027a7:	68 d8 41 80 00       	push   $0x8041d8
  8027ac:	e8 22 f3 ff ff       	call   801ad3 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  8027b1:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8027b6:	8b 40 48             	mov    0x48(%eax),%eax
  8027b9:	83 ec 08             	sub    $0x8,%esp
  8027bc:	68 d4 27 80 00       	push   $0x8027d4
  8027c1:	50                   	push   %eax
  8027c2:	e8 02 ff ff ff       	call   8026c9 <sys_env_set_pgfault_upcall>
  8027c7:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8027ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cd:	a3 10 a0 80 00       	mov    %eax,0x80a010

}
  8027d2:	c9                   	leave  
  8027d3:	c3                   	ret    

008027d4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8027d4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8027d5:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8027da:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  8027dc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  8027df:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  8027e3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  8027e8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  8027ec:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  8027ee:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  8027f1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  8027f2:	83 c4 04             	add    $0x4,%esp
	popfl
  8027f5:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8027f6:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8027f7:	c3                   	ret    

008027f8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8027f8:	55                   	push   %ebp
  8027f9:	89 e5                	mov    %esp,%ebp
  8027fb:	56                   	push   %esi
  8027fc:	53                   	push   %ebx
  8027fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802800:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802803:	83 ec 0c             	sub    $0xc,%esp
  802806:	ff 75 0c             	pushl  0xc(%ebp)
  802809:	e8 20 ff ff ff       	call   80272e <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  80280e:	83 c4 10             	add    $0x10,%esp
  802811:	85 f6                	test   %esi,%esi
  802813:	74 1c                	je     802831 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  802815:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80281a:	8b 40 78             	mov    0x78(%eax),%eax
  80281d:	89 06                	mov    %eax,(%esi)
  80281f:	eb 10                	jmp    802831 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802821:	83 ec 0c             	sub    $0xc,%esp
  802824:	68 e6 41 80 00       	push   $0x8041e6
  802829:	e8 7e f3 ff ff       	call   801bac <cprintf>
  80282e:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802831:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802836:	8b 50 74             	mov    0x74(%eax),%edx
  802839:	85 d2                	test   %edx,%edx
  80283b:	74 e4                	je     802821 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  80283d:	85 db                	test   %ebx,%ebx
  80283f:	74 05                	je     802846 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802841:	8b 40 74             	mov    0x74(%eax),%eax
  802844:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802846:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80284b:	8b 40 70             	mov    0x70(%eax),%eax

}
  80284e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802851:	5b                   	pop    %ebx
  802852:	5e                   	pop    %esi
  802853:	5d                   	pop    %ebp
  802854:	c3                   	ret    

00802855 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802855:	55                   	push   %ebp
  802856:	89 e5                	mov    %esp,%ebp
  802858:	57                   	push   %edi
  802859:	56                   	push   %esi
  80285a:	53                   	push   %ebx
  80285b:	83 ec 0c             	sub    $0xc,%esp
  80285e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802861:	8b 75 0c             	mov    0xc(%ebp),%esi
  802864:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  802867:	85 db                	test   %ebx,%ebx
  802869:	75 13                	jne    80287e <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  80286b:	6a 00                	push   $0x0
  80286d:	68 00 00 c0 ee       	push   $0xeec00000
  802872:	56                   	push   %esi
  802873:	57                   	push   %edi
  802874:	e8 92 fe ff ff       	call   80270b <sys_ipc_try_send>
  802879:	83 c4 10             	add    $0x10,%esp
  80287c:	eb 0e                	jmp    80288c <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  80287e:	ff 75 14             	pushl  0x14(%ebp)
  802881:	53                   	push   %ebx
  802882:	56                   	push   %esi
  802883:	57                   	push   %edi
  802884:	e8 82 fe ff ff       	call   80270b <sys_ipc_try_send>
  802889:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  80288c:	85 c0                	test   %eax,%eax
  80288e:	75 d7                	jne    802867 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  802890:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802893:	5b                   	pop    %ebx
  802894:	5e                   	pop    %esi
  802895:	5f                   	pop    %edi
  802896:	5d                   	pop    %ebp
  802897:	c3                   	ret    

00802898 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802898:	55                   	push   %ebp
  802899:	89 e5                	mov    %esp,%ebp
  80289b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80289e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8028a3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8028a6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8028ac:	8b 52 50             	mov    0x50(%edx),%edx
  8028af:	39 ca                	cmp    %ecx,%edx
  8028b1:	75 0d                	jne    8028c0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8028b3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8028b6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8028bb:	8b 40 48             	mov    0x48(%eax),%eax
  8028be:	eb 0f                	jmp    8028cf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8028c0:	83 c0 01             	add    $0x1,%eax
  8028c3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8028c8:	75 d9                	jne    8028a3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8028ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8028cf:	5d                   	pop    %ebp
  8028d0:	c3                   	ret    

008028d1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8028d1:	55                   	push   %ebp
  8028d2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8028d7:	05 00 00 00 30       	add    $0x30000000,%eax
  8028dc:	c1 e8 0c             	shr    $0xc,%eax
}
  8028df:	5d                   	pop    %ebp
  8028e0:	c3                   	ret    

008028e1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8028e1:	55                   	push   %ebp
  8028e2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8028e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8028e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8028ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8028f1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8028f6:	5d                   	pop    %ebp
  8028f7:	c3                   	ret    

008028f8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8028f8:	55                   	push   %ebp
  8028f9:	89 e5                	mov    %esp,%ebp
  8028fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028fe:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802903:	89 c2                	mov    %eax,%edx
  802905:	c1 ea 16             	shr    $0x16,%edx
  802908:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80290f:	f6 c2 01             	test   $0x1,%dl
  802912:	74 11                	je     802925 <fd_alloc+0x2d>
  802914:	89 c2                	mov    %eax,%edx
  802916:	c1 ea 0c             	shr    $0xc,%edx
  802919:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802920:	f6 c2 01             	test   $0x1,%dl
  802923:	75 09                	jne    80292e <fd_alloc+0x36>
			*fd_store = fd;
  802925:	89 01                	mov    %eax,(%ecx)
			return 0;
  802927:	b8 00 00 00 00       	mov    $0x0,%eax
  80292c:	eb 17                	jmp    802945 <fd_alloc+0x4d>
  80292e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802933:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802938:	75 c9                	jne    802903 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80293a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802940:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802945:	5d                   	pop    %ebp
  802946:	c3                   	ret    

00802947 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802947:	55                   	push   %ebp
  802948:	89 e5                	mov    %esp,%ebp
  80294a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80294d:	83 f8 1f             	cmp    $0x1f,%eax
  802950:	77 36                	ja     802988 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802952:	c1 e0 0c             	shl    $0xc,%eax
  802955:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80295a:	89 c2                	mov    %eax,%edx
  80295c:	c1 ea 16             	shr    $0x16,%edx
  80295f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802966:	f6 c2 01             	test   $0x1,%dl
  802969:	74 24                	je     80298f <fd_lookup+0x48>
  80296b:	89 c2                	mov    %eax,%edx
  80296d:	c1 ea 0c             	shr    $0xc,%edx
  802970:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802977:	f6 c2 01             	test   $0x1,%dl
  80297a:	74 1a                	je     802996 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80297c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80297f:	89 02                	mov    %eax,(%edx)
	return 0;
  802981:	b8 00 00 00 00       	mov    $0x0,%eax
  802986:	eb 13                	jmp    80299b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802988:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80298d:	eb 0c                	jmp    80299b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80298f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802994:	eb 05                	jmp    80299b <fd_lookup+0x54>
  802996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80299b:	5d                   	pop    %ebp
  80299c:	c3                   	ret    

0080299d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80299d:	55                   	push   %ebp
  80299e:	89 e5                	mov    %esp,%ebp
  8029a0:	83 ec 08             	sub    $0x8,%esp
  8029a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029a6:	ba 78 42 80 00       	mov    $0x804278,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8029ab:	eb 13                	jmp    8029c0 <dev_lookup+0x23>
  8029ad:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8029b0:	39 08                	cmp    %ecx,(%eax)
  8029b2:	75 0c                	jne    8029c0 <dev_lookup+0x23>
			*dev = devtab[i];
  8029b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029b7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8029b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8029be:	eb 2e                	jmp    8029ee <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8029c0:	8b 02                	mov    (%edx),%eax
  8029c2:	85 c0                	test   %eax,%eax
  8029c4:	75 e7                	jne    8029ad <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8029c6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029cb:	8b 40 48             	mov    0x48(%eax),%eax
  8029ce:	83 ec 04             	sub    $0x4,%esp
  8029d1:	51                   	push   %ecx
  8029d2:	50                   	push   %eax
  8029d3:	68 f8 41 80 00       	push   $0x8041f8
  8029d8:	e8 cf f1 ff ff       	call   801bac <cprintf>
	*dev = 0;
  8029dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8029e6:	83 c4 10             	add    $0x10,%esp
  8029e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8029ee:	c9                   	leave  
  8029ef:	c3                   	ret    

008029f0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8029f0:	55                   	push   %ebp
  8029f1:	89 e5                	mov    %esp,%ebp
  8029f3:	56                   	push   %esi
  8029f4:	53                   	push   %ebx
  8029f5:	83 ec 10             	sub    $0x10,%esp
  8029f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8029fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8029fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a01:	50                   	push   %eax
  802a02:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  802a08:	c1 e8 0c             	shr    $0xc,%eax
  802a0b:	50                   	push   %eax
  802a0c:	e8 36 ff ff ff       	call   802947 <fd_lookup>
  802a11:	83 c4 08             	add    $0x8,%esp
  802a14:	85 c0                	test   %eax,%eax
  802a16:	78 05                	js     802a1d <fd_close+0x2d>
	    || fd != fd2)
  802a18:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802a1b:	74 0c                	je     802a29 <fd_close+0x39>
		return (must_exist ? r : 0);
  802a1d:	84 db                	test   %bl,%bl
  802a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  802a24:	0f 44 c2             	cmove  %edx,%eax
  802a27:	eb 41                	jmp    802a6a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a29:	83 ec 08             	sub    $0x8,%esp
  802a2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a2f:	50                   	push   %eax
  802a30:	ff 36                	pushl  (%esi)
  802a32:	e8 66 ff ff ff       	call   80299d <dev_lookup>
  802a37:	89 c3                	mov    %eax,%ebx
  802a39:	83 c4 10             	add    $0x10,%esp
  802a3c:	85 c0                	test   %eax,%eax
  802a3e:	78 1a                	js     802a5a <fd_close+0x6a>
		if (dev->dev_close)
  802a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a43:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a46:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a4b:	85 c0                	test   %eax,%eax
  802a4d:	74 0b                	je     802a5a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802a4f:	83 ec 0c             	sub    $0xc,%esp
  802a52:	56                   	push   %esi
  802a53:	ff d0                	call   *%eax
  802a55:	89 c3                	mov    %eax,%ebx
  802a57:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a5a:	83 ec 08             	sub    $0x8,%esp
  802a5d:	56                   	push   %esi
  802a5e:	6a 00                	push   $0x0
  802a60:	e8 9e fb ff ff       	call   802603 <sys_page_unmap>
	return r;
  802a65:	83 c4 10             	add    $0x10,%esp
  802a68:	89 d8                	mov    %ebx,%eax
}
  802a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802a6d:	5b                   	pop    %ebx
  802a6e:	5e                   	pop    %esi
  802a6f:	5d                   	pop    %ebp
  802a70:	c3                   	ret    

00802a71 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a71:	55                   	push   %ebp
  802a72:	89 e5                	mov    %esp,%ebp
  802a74:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a7a:	50                   	push   %eax
  802a7b:	ff 75 08             	pushl  0x8(%ebp)
  802a7e:	e8 c4 fe ff ff       	call   802947 <fd_lookup>
  802a83:	83 c4 08             	add    $0x8,%esp
  802a86:	85 c0                	test   %eax,%eax
  802a88:	78 10                	js     802a9a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  802a8a:	83 ec 08             	sub    $0x8,%esp
  802a8d:	6a 01                	push   $0x1
  802a8f:	ff 75 f4             	pushl  -0xc(%ebp)
  802a92:	e8 59 ff ff ff       	call   8029f0 <fd_close>
  802a97:	83 c4 10             	add    $0x10,%esp
}
  802a9a:	c9                   	leave  
  802a9b:	c3                   	ret    

00802a9c <close_all>:

void
close_all(void)
{
  802a9c:	55                   	push   %ebp
  802a9d:	89 e5                	mov    %esp,%ebp
  802a9f:	53                   	push   %ebx
  802aa0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802aa3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802aa8:	83 ec 0c             	sub    $0xc,%esp
  802aab:	53                   	push   %ebx
  802aac:	e8 c0 ff ff ff       	call   802a71 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802ab1:	83 c3 01             	add    $0x1,%ebx
  802ab4:	83 c4 10             	add    $0x10,%esp
  802ab7:	83 fb 20             	cmp    $0x20,%ebx
  802aba:	75 ec                	jne    802aa8 <close_all+0xc>
		close(i);
}
  802abc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802abf:	c9                   	leave  
  802ac0:	c3                   	ret    

00802ac1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802ac1:	55                   	push   %ebp
  802ac2:	89 e5                	mov    %esp,%ebp
  802ac4:	57                   	push   %edi
  802ac5:	56                   	push   %esi
  802ac6:	53                   	push   %ebx
  802ac7:	83 ec 2c             	sub    $0x2c,%esp
  802aca:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802acd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ad0:	50                   	push   %eax
  802ad1:	ff 75 08             	pushl  0x8(%ebp)
  802ad4:	e8 6e fe ff ff       	call   802947 <fd_lookup>
  802ad9:	83 c4 08             	add    $0x8,%esp
  802adc:	85 c0                	test   %eax,%eax
  802ade:	0f 88 c1 00 00 00    	js     802ba5 <dup+0xe4>
		return r;
	close(newfdnum);
  802ae4:	83 ec 0c             	sub    $0xc,%esp
  802ae7:	56                   	push   %esi
  802ae8:	e8 84 ff ff ff       	call   802a71 <close>

	newfd = INDEX2FD(newfdnum);
  802aed:	89 f3                	mov    %esi,%ebx
  802aef:	c1 e3 0c             	shl    $0xc,%ebx
  802af2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802af8:	83 c4 04             	add    $0x4,%esp
  802afb:	ff 75 e4             	pushl  -0x1c(%ebp)
  802afe:	e8 de fd ff ff       	call   8028e1 <fd2data>
  802b03:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802b05:	89 1c 24             	mov    %ebx,(%esp)
  802b08:	e8 d4 fd ff ff       	call   8028e1 <fd2data>
  802b0d:	83 c4 10             	add    $0x10,%esp
  802b10:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802b13:	89 f8                	mov    %edi,%eax
  802b15:	c1 e8 16             	shr    $0x16,%eax
  802b18:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b1f:	a8 01                	test   $0x1,%al
  802b21:	74 37                	je     802b5a <dup+0x99>
  802b23:	89 f8                	mov    %edi,%eax
  802b25:	c1 e8 0c             	shr    $0xc,%eax
  802b28:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b2f:	f6 c2 01             	test   $0x1,%dl
  802b32:	74 26                	je     802b5a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b34:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b3b:	83 ec 0c             	sub    $0xc,%esp
  802b3e:	25 07 0e 00 00       	and    $0xe07,%eax
  802b43:	50                   	push   %eax
  802b44:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b47:	6a 00                	push   $0x0
  802b49:	57                   	push   %edi
  802b4a:	6a 00                	push   $0x0
  802b4c:	e8 70 fa ff ff       	call   8025c1 <sys_page_map>
  802b51:	89 c7                	mov    %eax,%edi
  802b53:	83 c4 20             	add    $0x20,%esp
  802b56:	85 c0                	test   %eax,%eax
  802b58:	78 2e                	js     802b88 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b5a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802b5d:	89 d0                	mov    %edx,%eax
  802b5f:	c1 e8 0c             	shr    $0xc,%eax
  802b62:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b69:	83 ec 0c             	sub    $0xc,%esp
  802b6c:	25 07 0e 00 00       	and    $0xe07,%eax
  802b71:	50                   	push   %eax
  802b72:	53                   	push   %ebx
  802b73:	6a 00                	push   $0x0
  802b75:	52                   	push   %edx
  802b76:	6a 00                	push   $0x0
  802b78:	e8 44 fa ff ff       	call   8025c1 <sys_page_map>
  802b7d:	89 c7                	mov    %eax,%edi
  802b7f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802b82:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b84:	85 ff                	test   %edi,%edi
  802b86:	79 1d                	jns    802ba5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802b88:	83 ec 08             	sub    $0x8,%esp
  802b8b:	53                   	push   %ebx
  802b8c:	6a 00                	push   $0x0
  802b8e:	e8 70 fa ff ff       	call   802603 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802b93:	83 c4 08             	add    $0x8,%esp
  802b96:	ff 75 d4             	pushl  -0x2c(%ebp)
  802b99:	6a 00                	push   $0x0
  802b9b:	e8 63 fa ff ff       	call   802603 <sys_page_unmap>
	return r;
  802ba0:	83 c4 10             	add    $0x10,%esp
  802ba3:	89 f8                	mov    %edi,%eax
}
  802ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba8:	5b                   	pop    %ebx
  802ba9:	5e                   	pop    %esi
  802baa:	5f                   	pop    %edi
  802bab:	5d                   	pop    %ebp
  802bac:	c3                   	ret    

00802bad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802bad:	55                   	push   %ebp
  802bae:	89 e5                	mov    %esp,%ebp
  802bb0:	53                   	push   %ebx
  802bb1:	83 ec 14             	sub    $0x14,%esp
  802bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bb7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bba:	50                   	push   %eax
  802bbb:	53                   	push   %ebx
  802bbc:	e8 86 fd ff ff       	call   802947 <fd_lookup>
  802bc1:	83 c4 08             	add    $0x8,%esp
  802bc4:	89 c2                	mov    %eax,%edx
  802bc6:	85 c0                	test   %eax,%eax
  802bc8:	78 6d                	js     802c37 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bca:	83 ec 08             	sub    $0x8,%esp
  802bcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bd0:	50                   	push   %eax
  802bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bd4:	ff 30                	pushl  (%eax)
  802bd6:	e8 c2 fd ff ff       	call   80299d <dev_lookup>
  802bdb:	83 c4 10             	add    $0x10,%esp
  802bde:	85 c0                	test   %eax,%eax
  802be0:	78 4c                	js     802c2e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802be2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802be5:	8b 42 08             	mov    0x8(%edx),%eax
  802be8:	83 e0 03             	and    $0x3,%eax
  802beb:	83 f8 01             	cmp    $0x1,%eax
  802bee:	75 21                	jne    802c11 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802bf0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802bf5:	8b 40 48             	mov    0x48(%eax),%eax
  802bf8:	83 ec 04             	sub    $0x4,%esp
  802bfb:	53                   	push   %ebx
  802bfc:	50                   	push   %eax
  802bfd:	68 3c 42 80 00       	push   $0x80423c
  802c02:	e8 a5 ef ff ff       	call   801bac <cprintf>
		return -E_INVAL;
  802c07:	83 c4 10             	add    $0x10,%esp
  802c0a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c0f:	eb 26                	jmp    802c37 <read+0x8a>
	}
	if (!dev->dev_read)
  802c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802c14:	8b 40 08             	mov    0x8(%eax),%eax
  802c17:	85 c0                	test   %eax,%eax
  802c19:	74 17                	je     802c32 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c1b:	83 ec 04             	sub    $0x4,%esp
  802c1e:	ff 75 10             	pushl  0x10(%ebp)
  802c21:	ff 75 0c             	pushl  0xc(%ebp)
  802c24:	52                   	push   %edx
  802c25:	ff d0                	call   *%eax
  802c27:	89 c2                	mov    %eax,%edx
  802c29:	83 c4 10             	add    $0x10,%esp
  802c2c:	eb 09                	jmp    802c37 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c2e:	89 c2                	mov    %eax,%edx
  802c30:	eb 05                	jmp    802c37 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c32:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802c37:	89 d0                	mov    %edx,%eax
  802c39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c3c:	c9                   	leave  
  802c3d:	c3                   	ret    

00802c3e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c3e:	55                   	push   %ebp
  802c3f:	89 e5                	mov    %esp,%ebp
  802c41:	57                   	push   %edi
  802c42:	56                   	push   %esi
  802c43:	53                   	push   %ebx
  802c44:	83 ec 0c             	sub    $0xc,%esp
  802c47:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c4a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c52:	eb 21                	jmp    802c75 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c54:	83 ec 04             	sub    $0x4,%esp
  802c57:	89 f0                	mov    %esi,%eax
  802c59:	29 d8                	sub    %ebx,%eax
  802c5b:	50                   	push   %eax
  802c5c:	89 d8                	mov    %ebx,%eax
  802c5e:	03 45 0c             	add    0xc(%ebp),%eax
  802c61:	50                   	push   %eax
  802c62:	57                   	push   %edi
  802c63:	e8 45 ff ff ff       	call   802bad <read>
		if (m < 0)
  802c68:	83 c4 10             	add    $0x10,%esp
  802c6b:	85 c0                	test   %eax,%eax
  802c6d:	78 10                	js     802c7f <readn+0x41>
			return m;
		if (m == 0)
  802c6f:	85 c0                	test   %eax,%eax
  802c71:	74 0a                	je     802c7d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c73:	01 c3                	add    %eax,%ebx
  802c75:	39 f3                	cmp    %esi,%ebx
  802c77:	72 db                	jb     802c54 <readn+0x16>
  802c79:	89 d8                	mov    %ebx,%eax
  802c7b:	eb 02                	jmp    802c7f <readn+0x41>
  802c7d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c82:	5b                   	pop    %ebx
  802c83:	5e                   	pop    %esi
  802c84:	5f                   	pop    %edi
  802c85:	5d                   	pop    %ebp
  802c86:	c3                   	ret    

00802c87 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c87:	55                   	push   %ebp
  802c88:	89 e5                	mov    %esp,%ebp
  802c8a:	53                   	push   %ebx
  802c8b:	83 ec 14             	sub    $0x14,%esp
  802c8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c94:	50                   	push   %eax
  802c95:	53                   	push   %ebx
  802c96:	e8 ac fc ff ff       	call   802947 <fd_lookup>
  802c9b:	83 c4 08             	add    $0x8,%esp
  802c9e:	89 c2                	mov    %eax,%edx
  802ca0:	85 c0                	test   %eax,%eax
  802ca2:	78 68                	js     802d0c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ca4:	83 ec 08             	sub    $0x8,%esp
  802ca7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802caa:	50                   	push   %eax
  802cab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cae:	ff 30                	pushl  (%eax)
  802cb0:	e8 e8 fc ff ff       	call   80299d <dev_lookup>
  802cb5:	83 c4 10             	add    $0x10,%esp
  802cb8:	85 c0                	test   %eax,%eax
  802cba:	78 47                	js     802d03 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cbf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802cc3:	75 21                	jne    802ce6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802cc5:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cca:	8b 40 48             	mov    0x48(%eax),%eax
  802ccd:	83 ec 04             	sub    $0x4,%esp
  802cd0:	53                   	push   %ebx
  802cd1:	50                   	push   %eax
  802cd2:	68 58 42 80 00       	push   $0x804258
  802cd7:	e8 d0 ee ff ff       	call   801bac <cprintf>
		return -E_INVAL;
  802cdc:	83 c4 10             	add    $0x10,%esp
  802cdf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ce4:	eb 26                	jmp    802d0c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ce9:	8b 52 0c             	mov    0xc(%edx),%edx
  802cec:	85 d2                	test   %edx,%edx
  802cee:	74 17                	je     802d07 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802cf0:	83 ec 04             	sub    $0x4,%esp
  802cf3:	ff 75 10             	pushl  0x10(%ebp)
  802cf6:	ff 75 0c             	pushl  0xc(%ebp)
  802cf9:	50                   	push   %eax
  802cfa:	ff d2                	call   *%edx
  802cfc:	89 c2                	mov    %eax,%edx
  802cfe:	83 c4 10             	add    $0x10,%esp
  802d01:	eb 09                	jmp    802d0c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d03:	89 c2                	mov    %eax,%edx
  802d05:	eb 05                	jmp    802d0c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d07:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802d0c:	89 d0                	mov    %edx,%eax
  802d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d11:	c9                   	leave  
  802d12:	c3                   	ret    

00802d13 <seek>:

int
seek(int fdnum, off_t offset)
{
  802d13:	55                   	push   %ebp
  802d14:	89 e5                	mov    %esp,%ebp
  802d16:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d19:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d1c:	50                   	push   %eax
  802d1d:	ff 75 08             	pushl  0x8(%ebp)
  802d20:	e8 22 fc ff ff       	call   802947 <fd_lookup>
  802d25:	83 c4 08             	add    $0x8,%esp
  802d28:	85 c0                	test   %eax,%eax
  802d2a:	78 0e                	js     802d3a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802d2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d32:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d3a:	c9                   	leave  
  802d3b:	c3                   	ret    

00802d3c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d3c:	55                   	push   %ebp
  802d3d:	89 e5                	mov    %esp,%ebp
  802d3f:	53                   	push   %ebx
  802d40:	83 ec 14             	sub    $0x14,%esp
  802d43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d49:	50                   	push   %eax
  802d4a:	53                   	push   %ebx
  802d4b:	e8 f7 fb ff ff       	call   802947 <fd_lookup>
  802d50:	83 c4 08             	add    $0x8,%esp
  802d53:	89 c2                	mov    %eax,%edx
  802d55:	85 c0                	test   %eax,%eax
  802d57:	78 65                	js     802dbe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d59:	83 ec 08             	sub    $0x8,%esp
  802d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d5f:	50                   	push   %eax
  802d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d63:	ff 30                	pushl  (%eax)
  802d65:	e8 33 fc ff ff       	call   80299d <dev_lookup>
  802d6a:	83 c4 10             	add    $0x10,%esp
  802d6d:	85 c0                	test   %eax,%eax
  802d6f:	78 44                	js     802db5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d74:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d78:	75 21                	jne    802d9b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d7a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d7f:	8b 40 48             	mov    0x48(%eax),%eax
  802d82:	83 ec 04             	sub    $0x4,%esp
  802d85:	53                   	push   %ebx
  802d86:	50                   	push   %eax
  802d87:	68 18 42 80 00       	push   $0x804218
  802d8c:	e8 1b ee ff ff       	call   801bac <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802d91:	83 c4 10             	add    $0x10,%esp
  802d94:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802d99:	eb 23                	jmp    802dbe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802d9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802d9e:	8b 52 18             	mov    0x18(%edx),%edx
  802da1:	85 d2                	test   %edx,%edx
  802da3:	74 14                	je     802db9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802da5:	83 ec 08             	sub    $0x8,%esp
  802da8:	ff 75 0c             	pushl  0xc(%ebp)
  802dab:	50                   	push   %eax
  802dac:	ff d2                	call   *%edx
  802dae:	89 c2                	mov    %eax,%edx
  802db0:	83 c4 10             	add    $0x10,%esp
  802db3:	eb 09                	jmp    802dbe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802db5:	89 c2                	mov    %eax,%edx
  802db7:	eb 05                	jmp    802dbe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802db9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802dbe:	89 d0                	mov    %edx,%eax
  802dc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802dc3:	c9                   	leave  
  802dc4:	c3                   	ret    

00802dc5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802dc5:	55                   	push   %ebp
  802dc6:	89 e5                	mov    %esp,%ebp
  802dc8:	53                   	push   %ebx
  802dc9:	83 ec 14             	sub    $0x14,%esp
  802dcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802dcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dd2:	50                   	push   %eax
  802dd3:	ff 75 08             	pushl  0x8(%ebp)
  802dd6:	e8 6c fb ff ff       	call   802947 <fd_lookup>
  802ddb:	83 c4 08             	add    $0x8,%esp
  802dde:	89 c2                	mov    %eax,%edx
  802de0:	85 c0                	test   %eax,%eax
  802de2:	78 58                	js     802e3c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802de4:	83 ec 08             	sub    $0x8,%esp
  802de7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dea:	50                   	push   %eax
  802deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dee:	ff 30                	pushl  (%eax)
  802df0:	e8 a8 fb ff ff       	call   80299d <dev_lookup>
  802df5:	83 c4 10             	add    $0x10,%esp
  802df8:	85 c0                	test   %eax,%eax
  802dfa:	78 37                	js     802e33 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802dff:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e03:	74 32                	je     802e37 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e05:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e08:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e0f:	00 00 00 
	stat->st_isdir = 0;
  802e12:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e19:	00 00 00 
	stat->st_dev = dev;
  802e1c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e22:	83 ec 08             	sub    $0x8,%esp
  802e25:	53                   	push   %ebx
  802e26:	ff 75 f0             	pushl  -0x10(%ebp)
  802e29:	ff 50 14             	call   *0x14(%eax)
  802e2c:	89 c2                	mov    %eax,%edx
  802e2e:	83 c4 10             	add    $0x10,%esp
  802e31:	eb 09                	jmp    802e3c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802e33:	89 c2                	mov    %eax,%edx
  802e35:	eb 05                	jmp    802e3c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e37:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e3c:	89 d0                	mov    %edx,%eax
  802e3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e41:	c9                   	leave  
  802e42:	c3                   	ret    

00802e43 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e43:	55                   	push   %ebp
  802e44:	89 e5                	mov    %esp,%ebp
  802e46:	56                   	push   %esi
  802e47:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e48:	83 ec 08             	sub    $0x8,%esp
  802e4b:	6a 00                	push   $0x0
  802e4d:	ff 75 08             	pushl  0x8(%ebp)
  802e50:	e8 dc 01 00 00       	call   803031 <open>
  802e55:	89 c3                	mov    %eax,%ebx
  802e57:	83 c4 10             	add    $0x10,%esp
  802e5a:	85 c0                	test   %eax,%eax
  802e5c:	78 1b                	js     802e79 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802e5e:	83 ec 08             	sub    $0x8,%esp
  802e61:	ff 75 0c             	pushl  0xc(%ebp)
  802e64:	50                   	push   %eax
  802e65:	e8 5b ff ff ff       	call   802dc5 <fstat>
  802e6a:	89 c6                	mov    %eax,%esi
	close(fd);
  802e6c:	89 1c 24             	mov    %ebx,(%esp)
  802e6f:	e8 fd fb ff ff       	call   802a71 <close>
	return r;
  802e74:	83 c4 10             	add    $0x10,%esp
  802e77:	89 f0                	mov    %esi,%eax
}
  802e79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802e7c:	5b                   	pop    %ebx
  802e7d:	5e                   	pop    %esi
  802e7e:	5d                   	pop    %ebp
  802e7f:	c3                   	ret    

00802e80 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802e80:	55                   	push   %ebp
  802e81:	89 e5                	mov    %esp,%ebp
  802e83:	56                   	push   %esi
  802e84:	53                   	push   %ebx
  802e85:	89 c6                	mov    %eax,%esi
  802e87:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802e89:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802e90:	75 12                	jne    802ea4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802e92:	83 ec 0c             	sub    $0xc,%esp
  802e95:	6a 01                	push   $0x1
  802e97:	e8 fc f9 ff ff       	call   802898 <ipc_find_env>
  802e9c:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802ea1:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802ea4:	6a 07                	push   $0x7
  802ea6:	68 00 b0 80 00       	push   $0x80b000
  802eab:	56                   	push   %esi
  802eac:	ff 35 00 a0 80 00    	pushl  0x80a000
  802eb2:	e8 9e f9 ff ff       	call   802855 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  802eb7:	83 c4 0c             	add    $0xc,%esp
  802eba:	6a 00                	push   $0x0
  802ebc:	53                   	push   %ebx
  802ebd:	6a 00                	push   $0x0
  802ebf:	e8 34 f9 ff ff       	call   8027f8 <ipc_recv>
}
  802ec4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802ec7:	5b                   	pop    %ebx
  802ec8:	5e                   	pop    %esi
  802ec9:	5d                   	pop    %ebp
  802eca:	c3                   	ret    

00802ecb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802ecb:	55                   	push   %ebp
  802ecc:	89 e5                	mov    %esp,%ebp
  802ece:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  802ed4:	8b 40 0c             	mov    0xc(%eax),%eax
  802ed7:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802edc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802edf:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  802ee9:	b8 02 00 00 00       	mov    $0x2,%eax
  802eee:	e8 8d ff ff ff       	call   802e80 <fsipc>
}
  802ef3:	c9                   	leave  
  802ef4:	c3                   	ret    

00802ef5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802ef5:	55                   	push   %ebp
  802ef6:	89 e5                	mov    %esp,%ebp
  802ef8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802efb:	8b 45 08             	mov    0x8(%ebp),%eax
  802efe:	8b 40 0c             	mov    0xc(%eax),%eax
  802f01:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802f06:	ba 00 00 00 00       	mov    $0x0,%edx
  802f0b:	b8 06 00 00 00       	mov    $0x6,%eax
  802f10:	e8 6b ff ff ff       	call   802e80 <fsipc>
}
  802f15:	c9                   	leave  
  802f16:	c3                   	ret    

00802f17 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802f17:	55                   	push   %ebp
  802f18:	89 e5                	mov    %esp,%ebp
  802f1a:	53                   	push   %ebx
  802f1b:	83 ec 04             	sub    $0x4,%esp
  802f1e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802f21:	8b 45 08             	mov    0x8(%ebp),%eax
  802f24:	8b 40 0c             	mov    0xc(%eax),%eax
  802f27:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802f2c:	ba 00 00 00 00       	mov    $0x0,%edx
  802f31:	b8 05 00 00 00       	mov    $0x5,%eax
  802f36:	e8 45 ff ff ff       	call   802e80 <fsipc>
  802f3b:	85 c0                	test   %eax,%eax
  802f3d:	78 2c                	js     802f6b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802f3f:	83 ec 08             	sub    $0x8,%esp
  802f42:	68 00 b0 80 00       	push   $0x80b000
  802f47:	53                   	push   %ebx
  802f48:	e8 2e f2 ff ff       	call   80217b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802f4d:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802f52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802f58:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802f5d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802f63:	83 c4 10             	add    $0x10,%esp
  802f66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f6e:	c9                   	leave  
  802f6f:	c3                   	ret    

00802f70 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802f70:	55                   	push   %ebp
  802f71:	89 e5                	mov    %esp,%ebp
  802f73:	83 ec 0c             	sub    $0xc,%esp
  802f76:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802f79:	8b 55 08             	mov    0x8(%ebp),%edx
  802f7c:	8b 52 0c             	mov    0xc(%edx),%edx
  802f7f:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  802f85:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(fsipcbuf.write.req_buf, buf, n);
  802f8a:	50                   	push   %eax
  802f8b:	ff 75 0c             	pushl  0xc(%ebp)
  802f8e:	68 08 b0 80 00       	push   $0x80b008
  802f93:	e8 75 f3 ff ff       	call   80230d <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802f98:	ba 00 00 00 00       	mov    $0x0,%edx
  802f9d:	b8 04 00 00 00       	mov    $0x4,%eax
  802fa2:	e8 d9 fe ff ff       	call   802e80 <fsipc>
	//panic("devfile_write not implemented");
}
  802fa7:	c9                   	leave  
  802fa8:	c3                   	ret    

00802fa9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802fa9:	55                   	push   %ebp
  802faa:	89 e5                	mov    %esp,%ebp
  802fac:	56                   	push   %esi
  802fad:	53                   	push   %ebx
  802fae:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  802fb4:	8b 40 0c             	mov    0xc(%eax),%eax
  802fb7:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802fbc:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802fc2:	ba 00 00 00 00       	mov    $0x0,%edx
  802fc7:	b8 03 00 00 00       	mov    $0x3,%eax
  802fcc:	e8 af fe ff ff       	call   802e80 <fsipc>
  802fd1:	89 c3                	mov    %eax,%ebx
  802fd3:	85 c0                	test   %eax,%eax
  802fd5:	78 51                	js     803028 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  802fd7:	39 c6                	cmp    %eax,%esi
  802fd9:	73 19                	jae    802ff4 <devfile_read+0x4b>
  802fdb:	68 88 42 80 00       	push   $0x804288
  802fe0:	68 bd 38 80 00       	push   $0x8038bd
  802fe5:	68 80 00 00 00       	push   $0x80
  802fea:	68 8f 42 80 00       	push   $0x80428f
  802fef:	e8 df ea ff ff       	call   801ad3 <_panic>
	assert(r <= PGSIZE);
  802ff4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802ff9:	7e 19                	jle    803014 <devfile_read+0x6b>
  802ffb:	68 9a 42 80 00       	push   $0x80429a
  803000:	68 bd 38 80 00       	push   $0x8038bd
  803005:	68 81 00 00 00       	push   $0x81
  80300a:	68 8f 42 80 00       	push   $0x80428f
  80300f:	e8 bf ea ff ff       	call   801ad3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803014:	83 ec 04             	sub    $0x4,%esp
  803017:	50                   	push   %eax
  803018:	68 00 b0 80 00       	push   $0x80b000
  80301d:	ff 75 0c             	pushl  0xc(%ebp)
  803020:	e8 e8 f2 ff ff       	call   80230d <memmove>
	return r;
  803025:	83 c4 10             	add    $0x10,%esp
}
  803028:	89 d8                	mov    %ebx,%eax
  80302a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80302d:	5b                   	pop    %ebx
  80302e:	5e                   	pop    %esi
  80302f:	5d                   	pop    %ebp
  803030:	c3                   	ret    

00803031 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803031:	55                   	push   %ebp
  803032:	89 e5                	mov    %esp,%ebp
  803034:	53                   	push   %ebx
  803035:	83 ec 20             	sub    $0x20,%esp
  803038:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80303b:	53                   	push   %ebx
  80303c:	e8 01 f1 ff ff       	call   802142 <strlen>
  803041:	83 c4 10             	add    $0x10,%esp
  803044:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803049:	7f 67                	jg     8030b2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80304b:	83 ec 0c             	sub    $0xc,%esp
  80304e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803051:	50                   	push   %eax
  803052:	e8 a1 f8 ff ff       	call   8028f8 <fd_alloc>
  803057:	83 c4 10             	add    $0x10,%esp
		return r;
  80305a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80305c:	85 c0                	test   %eax,%eax
  80305e:	78 57                	js     8030b7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803060:	83 ec 08             	sub    $0x8,%esp
  803063:	53                   	push   %ebx
  803064:	68 00 b0 80 00       	push   $0x80b000
  803069:	e8 0d f1 ff ff       	call   80217b <strcpy>
	fsipcbuf.open.req_omode = mode;
  80306e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803071:	a3 00 b4 80 00       	mov    %eax,0x80b400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  803076:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803079:	b8 01 00 00 00       	mov    $0x1,%eax
  80307e:	e8 fd fd ff ff       	call   802e80 <fsipc>
  803083:	89 c3                	mov    %eax,%ebx
  803085:	83 c4 10             	add    $0x10,%esp
  803088:	85 c0                	test   %eax,%eax
  80308a:	79 14                	jns    8030a0 <open+0x6f>
		
		fd_close(fd, 0);
  80308c:	83 ec 08             	sub    $0x8,%esp
  80308f:	6a 00                	push   $0x0
  803091:	ff 75 f4             	pushl  -0xc(%ebp)
  803094:	e8 57 f9 ff ff       	call   8029f0 <fd_close>
		return r;
  803099:	83 c4 10             	add    $0x10,%esp
  80309c:	89 da                	mov    %ebx,%edx
  80309e:	eb 17                	jmp    8030b7 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8030a0:	83 ec 0c             	sub    $0xc,%esp
  8030a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8030a6:	e8 26 f8 ff ff       	call   8028d1 <fd2num>
  8030ab:	89 c2                	mov    %eax,%edx
  8030ad:	83 c4 10             	add    $0x10,%esp
  8030b0:	eb 05                	jmp    8030b7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8030b2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8030b7:	89 d0                	mov    %edx,%eax
  8030b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030bc:	c9                   	leave  
  8030bd:	c3                   	ret    

008030be <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8030be:	55                   	push   %ebp
  8030bf:	89 e5                	mov    %esp,%ebp
  8030c1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8030c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8030c9:	b8 08 00 00 00       	mov    $0x8,%eax
  8030ce:	e8 ad fd ff ff       	call   802e80 <fsipc>
}
  8030d3:	c9                   	leave  
  8030d4:	c3                   	ret    

008030d5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8030d5:	55                   	push   %ebp
  8030d6:	89 e5                	mov    %esp,%ebp
  8030d8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030db:	89 d0                	mov    %edx,%eax
  8030dd:	c1 e8 16             	shr    $0x16,%eax
  8030e0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030e7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8030ec:	f6 c1 01             	test   $0x1,%cl
  8030ef:	74 1d                	je     80310e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8030f1:	c1 ea 0c             	shr    $0xc,%edx
  8030f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030fb:	f6 c2 01             	test   $0x1,%dl
  8030fe:	74 0e                	je     80310e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803100:	c1 ea 0c             	shr    $0xc,%edx
  803103:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80310a:	ef 
  80310b:	0f b7 c0             	movzwl %ax,%eax
}
  80310e:	5d                   	pop    %ebp
  80310f:	c3                   	ret    

00803110 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803110:	55                   	push   %ebp
  803111:	89 e5                	mov    %esp,%ebp
  803113:	56                   	push   %esi
  803114:	53                   	push   %ebx
  803115:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803118:	83 ec 0c             	sub    $0xc,%esp
  80311b:	ff 75 08             	pushl  0x8(%ebp)
  80311e:	e8 be f7 ff ff       	call   8028e1 <fd2data>
  803123:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803125:	83 c4 08             	add    $0x8,%esp
  803128:	68 a6 42 80 00       	push   $0x8042a6
  80312d:	53                   	push   %ebx
  80312e:	e8 48 f0 ff ff       	call   80217b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803133:	8b 46 04             	mov    0x4(%esi),%eax
  803136:	2b 06                	sub    (%esi),%eax
  803138:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80313e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803145:	00 00 00 
	stat->st_dev = &devpipe;
  803148:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  80314f:	90 80 00 
	return 0;
}
  803152:	b8 00 00 00 00       	mov    $0x0,%eax
  803157:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80315a:	5b                   	pop    %ebx
  80315b:	5e                   	pop    %esi
  80315c:	5d                   	pop    %ebp
  80315d:	c3                   	ret    

0080315e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80315e:	55                   	push   %ebp
  80315f:	89 e5                	mov    %esp,%ebp
  803161:	53                   	push   %ebx
  803162:	83 ec 0c             	sub    $0xc,%esp
  803165:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803168:	53                   	push   %ebx
  803169:	6a 00                	push   $0x0
  80316b:	e8 93 f4 ff ff       	call   802603 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803170:	89 1c 24             	mov    %ebx,(%esp)
  803173:	e8 69 f7 ff ff       	call   8028e1 <fd2data>
  803178:	83 c4 08             	add    $0x8,%esp
  80317b:	50                   	push   %eax
  80317c:	6a 00                	push   $0x0
  80317e:	e8 80 f4 ff ff       	call   802603 <sys_page_unmap>
}
  803183:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803186:	c9                   	leave  
  803187:	c3                   	ret    

00803188 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803188:	55                   	push   %ebp
  803189:	89 e5                	mov    %esp,%ebp
  80318b:	57                   	push   %edi
  80318c:	56                   	push   %esi
  80318d:	53                   	push   %ebx
  80318e:	83 ec 1c             	sub    $0x1c,%esp
  803191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  803194:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803196:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80319b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80319e:	83 ec 0c             	sub    $0xc,%esp
  8031a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8031a4:	e8 2c ff ff ff       	call   8030d5 <pageref>
  8031a9:	89 c3                	mov    %eax,%ebx
  8031ab:	89 3c 24             	mov    %edi,(%esp)
  8031ae:	e8 22 ff ff ff       	call   8030d5 <pageref>
  8031b3:	83 c4 10             	add    $0x10,%esp
  8031b6:	39 c3                	cmp    %eax,%ebx
  8031b8:	0f 94 c1             	sete   %cl
  8031bb:	0f b6 c9             	movzbl %cl,%ecx
  8031be:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8031c1:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8031c7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8031ca:	39 ce                	cmp    %ecx,%esi
  8031cc:	74 1b                	je     8031e9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8031ce:	39 c3                	cmp    %eax,%ebx
  8031d0:	75 c4                	jne    803196 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8031d2:	8b 42 58             	mov    0x58(%edx),%eax
  8031d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8031d8:	50                   	push   %eax
  8031d9:	56                   	push   %esi
  8031da:	68 ad 42 80 00       	push   $0x8042ad
  8031df:	e8 c8 e9 ff ff       	call   801bac <cprintf>
  8031e4:	83 c4 10             	add    $0x10,%esp
  8031e7:	eb ad                	jmp    803196 <_pipeisclosed+0xe>
	}
}
  8031e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8031ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031ef:	5b                   	pop    %ebx
  8031f0:	5e                   	pop    %esi
  8031f1:	5f                   	pop    %edi
  8031f2:	5d                   	pop    %ebp
  8031f3:	c3                   	ret    

008031f4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8031f4:	55                   	push   %ebp
  8031f5:	89 e5                	mov    %esp,%ebp
  8031f7:	57                   	push   %edi
  8031f8:	56                   	push   %esi
  8031f9:	53                   	push   %ebx
  8031fa:	83 ec 28             	sub    $0x28,%esp
  8031fd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803200:	56                   	push   %esi
  803201:	e8 db f6 ff ff       	call   8028e1 <fd2data>
  803206:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803208:	83 c4 10             	add    $0x10,%esp
  80320b:	bf 00 00 00 00       	mov    $0x0,%edi
  803210:	eb 4b                	jmp    80325d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803212:	89 da                	mov    %ebx,%edx
  803214:	89 f0                	mov    %esi,%eax
  803216:	e8 6d ff ff ff       	call   803188 <_pipeisclosed>
  80321b:	85 c0                	test   %eax,%eax
  80321d:	75 48                	jne    803267 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80321f:	e8 3b f3 ff ff       	call   80255f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803224:	8b 43 04             	mov    0x4(%ebx),%eax
  803227:	8b 0b                	mov    (%ebx),%ecx
  803229:	8d 51 20             	lea    0x20(%ecx),%edx
  80322c:	39 d0                	cmp    %edx,%eax
  80322e:	73 e2                	jae    803212 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803233:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803237:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80323a:	89 c2                	mov    %eax,%edx
  80323c:	c1 fa 1f             	sar    $0x1f,%edx
  80323f:	89 d1                	mov    %edx,%ecx
  803241:	c1 e9 1b             	shr    $0x1b,%ecx
  803244:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803247:	83 e2 1f             	and    $0x1f,%edx
  80324a:	29 ca                	sub    %ecx,%edx
  80324c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803250:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803254:	83 c0 01             	add    $0x1,%eax
  803257:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80325a:	83 c7 01             	add    $0x1,%edi
  80325d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803260:	75 c2                	jne    803224 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803262:	8b 45 10             	mov    0x10(%ebp),%eax
  803265:	eb 05                	jmp    80326c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803267:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80326c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80326f:	5b                   	pop    %ebx
  803270:	5e                   	pop    %esi
  803271:	5f                   	pop    %edi
  803272:	5d                   	pop    %ebp
  803273:	c3                   	ret    

00803274 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803274:	55                   	push   %ebp
  803275:	89 e5                	mov    %esp,%ebp
  803277:	57                   	push   %edi
  803278:	56                   	push   %esi
  803279:	53                   	push   %ebx
  80327a:	83 ec 18             	sub    $0x18,%esp
  80327d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803280:	57                   	push   %edi
  803281:	e8 5b f6 ff ff       	call   8028e1 <fd2data>
  803286:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803288:	83 c4 10             	add    $0x10,%esp
  80328b:	bb 00 00 00 00       	mov    $0x0,%ebx
  803290:	eb 3d                	jmp    8032cf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803292:	85 db                	test   %ebx,%ebx
  803294:	74 04                	je     80329a <devpipe_read+0x26>
				return i;
  803296:	89 d8                	mov    %ebx,%eax
  803298:	eb 44                	jmp    8032de <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80329a:	89 f2                	mov    %esi,%edx
  80329c:	89 f8                	mov    %edi,%eax
  80329e:	e8 e5 fe ff ff       	call   803188 <_pipeisclosed>
  8032a3:	85 c0                	test   %eax,%eax
  8032a5:	75 32                	jne    8032d9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8032a7:	e8 b3 f2 ff ff       	call   80255f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8032ac:	8b 06                	mov    (%esi),%eax
  8032ae:	3b 46 04             	cmp    0x4(%esi),%eax
  8032b1:	74 df                	je     803292 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8032b3:	99                   	cltd   
  8032b4:	c1 ea 1b             	shr    $0x1b,%edx
  8032b7:	01 d0                	add    %edx,%eax
  8032b9:	83 e0 1f             	and    $0x1f,%eax
  8032bc:	29 d0                	sub    %edx,%eax
  8032be:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8032c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8032c6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8032c9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8032cc:	83 c3 01             	add    $0x1,%ebx
  8032cf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8032d2:	75 d8                	jne    8032ac <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8032d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8032d7:	eb 05                	jmp    8032de <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8032d9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8032de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032e1:	5b                   	pop    %ebx
  8032e2:	5e                   	pop    %esi
  8032e3:	5f                   	pop    %edi
  8032e4:	5d                   	pop    %ebp
  8032e5:	c3                   	ret    

008032e6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8032e6:	55                   	push   %ebp
  8032e7:	89 e5                	mov    %esp,%ebp
  8032e9:	56                   	push   %esi
  8032ea:	53                   	push   %ebx
  8032eb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8032ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8032f1:	50                   	push   %eax
  8032f2:	e8 01 f6 ff ff       	call   8028f8 <fd_alloc>
  8032f7:	83 c4 10             	add    $0x10,%esp
  8032fa:	89 c2                	mov    %eax,%edx
  8032fc:	85 c0                	test   %eax,%eax
  8032fe:	0f 88 2c 01 00 00    	js     803430 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803304:	83 ec 04             	sub    $0x4,%esp
  803307:	68 07 04 00 00       	push   $0x407
  80330c:	ff 75 f4             	pushl  -0xc(%ebp)
  80330f:	6a 00                	push   $0x0
  803311:	e8 68 f2 ff ff       	call   80257e <sys_page_alloc>
  803316:	83 c4 10             	add    $0x10,%esp
  803319:	89 c2                	mov    %eax,%edx
  80331b:	85 c0                	test   %eax,%eax
  80331d:	0f 88 0d 01 00 00    	js     803430 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803323:	83 ec 0c             	sub    $0xc,%esp
  803326:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803329:	50                   	push   %eax
  80332a:	e8 c9 f5 ff ff       	call   8028f8 <fd_alloc>
  80332f:	89 c3                	mov    %eax,%ebx
  803331:	83 c4 10             	add    $0x10,%esp
  803334:	85 c0                	test   %eax,%eax
  803336:	0f 88 e2 00 00 00    	js     80341e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80333c:	83 ec 04             	sub    $0x4,%esp
  80333f:	68 07 04 00 00       	push   $0x407
  803344:	ff 75 f0             	pushl  -0x10(%ebp)
  803347:	6a 00                	push   $0x0
  803349:	e8 30 f2 ff ff       	call   80257e <sys_page_alloc>
  80334e:	89 c3                	mov    %eax,%ebx
  803350:	83 c4 10             	add    $0x10,%esp
  803353:	85 c0                	test   %eax,%eax
  803355:	0f 88 c3 00 00 00    	js     80341e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80335b:	83 ec 0c             	sub    $0xc,%esp
  80335e:	ff 75 f4             	pushl  -0xc(%ebp)
  803361:	e8 7b f5 ff ff       	call   8028e1 <fd2data>
  803366:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803368:	83 c4 0c             	add    $0xc,%esp
  80336b:	68 07 04 00 00       	push   $0x407
  803370:	50                   	push   %eax
  803371:	6a 00                	push   $0x0
  803373:	e8 06 f2 ff ff       	call   80257e <sys_page_alloc>
  803378:	89 c3                	mov    %eax,%ebx
  80337a:	83 c4 10             	add    $0x10,%esp
  80337d:	85 c0                	test   %eax,%eax
  80337f:	0f 88 89 00 00 00    	js     80340e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803385:	83 ec 0c             	sub    $0xc,%esp
  803388:	ff 75 f0             	pushl  -0x10(%ebp)
  80338b:	e8 51 f5 ff ff       	call   8028e1 <fd2data>
  803390:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803397:	50                   	push   %eax
  803398:	6a 00                	push   $0x0
  80339a:	56                   	push   %esi
  80339b:	6a 00                	push   $0x0
  80339d:	e8 1f f2 ff ff       	call   8025c1 <sys_page_map>
  8033a2:	89 c3                	mov    %eax,%ebx
  8033a4:	83 c4 20             	add    $0x20,%esp
  8033a7:	85 c0                	test   %eax,%eax
  8033a9:	78 55                	js     803400 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8033ab:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033b4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8033b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033b9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8033c0:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8033c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033c9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8033cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8033ce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8033d5:	83 ec 0c             	sub    $0xc,%esp
  8033d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8033db:	e8 f1 f4 ff ff       	call   8028d1 <fd2num>
  8033e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033e3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8033e5:	83 c4 04             	add    $0x4,%esp
  8033e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8033eb:	e8 e1 f4 ff ff       	call   8028d1 <fd2num>
  8033f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8033f3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8033f6:	83 c4 10             	add    $0x10,%esp
  8033f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8033fe:	eb 30                	jmp    803430 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803400:	83 ec 08             	sub    $0x8,%esp
  803403:	56                   	push   %esi
  803404:	6a 00                	push   $0x0
  803406:	e8 f8 f1 ff ff       	call   802603 <sys_page_unmap>
  80340b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80340e:	83 ec 08             	sub    $0x8,%esp
  803411:	ff 75 f0             	pushl  -0x10(%ebp)
  803414:	6a 00                	push   $0x0
  803416:	e8 e8 f1 ff ff       	call   802603 <sys_page_unmap>
  80341b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80341e:	83 ec 08             	sub    $0x8,%esp
  803421:	ff 75 f4             	pushl  -0xc(%ebp)
  803424:	6a 00                	push   $0x0
  803426:	e8 d8 f1 ff ff       	call   802603 <sys_page_unmap>
  80342b:	83 c4 10             	add    $0x10,%esp
  80342e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803430:	89 d0                	mov    %edx,%eax
  803432:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803435:	5b                   	pop    %ebx
  803436:	5e                   	pop    %esi
  803437:	5d                   	pop    %ebp
  803438:	c3                   	ret    

00803439 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803439:	55                   	push   %ebp
  80343a:	89 e5                	mov    %esp,%ebp
  80343c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80343f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803442:	50                   	push   %eax
  803443:	ff 75 08             	pushl  0x8(%ebp)
  803446:	e8 fc f4 ff ff       	call   802947 <fd_lookup>
  80344b:	83 c4 10             	add    $0x10,%esp
  80344e:	85 c0                	test   %eax,%eax
  803450:	78 18                	js     80346a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803452:	83 ec 0c             	sub    $0xc,%esp
  803455:	ff 75 f4             	pushl  -0xc(%ebp)
  803458:	e8 84 f4 ff ff       	call   8028e1 <fd2data>
	return _pipeisclosed(fd, p);
  80345d:	89 c2                	mov    %eax,%edx
  80345f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803462:	e8 21 fd ff ff       	call   803188 <_pipeisclosed>
  803467:	83 c4 10             	add    $0x10,%esp
}
  80346a:	c9                   	leave  
  80346b:	c3                   	ret    

0080346c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80346c:	55                   	push   %ebp
  80346d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80346f:	b8 00 00 00 00       	mov    $0x0,%eax
  803474:	5d                   	pop    %ebp
  803475:	c3                   	ret    

00803476 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803476:	55                   	push   %ebp
  803477:	89 e5                	mov    %esp,%ebp
  803479:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80347c:	68 c5 42 80 00       	push   $0x8042c5
  803481:	ff 75 0c             	pushl  0xc(%ebp)
  803484:	e8 f2 ec ff ff       	call   80217b <strcpy>
	return 0;
}
  803489:	b8 00 00 00 00       	mov    $0x0,%eax
  80348e:	c9                   	leave  
  80348f:	c3                   	ret    

00803490 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803490:	55                   	push   %ebp
  803491:	89 e5                	mov    %esp,%ebp
  803493:	57                   	push   %edi
  803494:	56                   	push   %esi
  803495:	53                   	push   %ebx
  803496:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80349c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034a1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034a7:	eb 2d                	jmp    8034d6 <devcons_write+0x46>
		m = n - tot;
  8034a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8034ac:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8034ae:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8034b1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8034b6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8034b9:	83 ec 04             	sub    $0x4,%esp
  8034bc:	53                   	push   %ebx
  8034bd:	03 45 0c             	add    0xc(%ebp),%eax
  8034c0:	50                   	push   %eax
  8034c1:	57                   	push   %edi
  8034c2:	e8 46 ee ff ff       	call   80230d <memmove>
		sys_cputs(buf, m);
  8034c7:	83 c4 08             	add    $0x8,%esp
  8034ca:	53                   	push   %ebx
  8034cb:	57                   	push   %edi
  8034cc:	e8 f1 ef ff ff       	call   8024c2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8034d1:	01 de                	add    %ebx,%esi
  8034d3:	83 c4 10             	add    $0x10,%esp
  8034d6:	89 f0                	mov    %esi,%eax
  8034d8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8034db:	72 cc                	jb     8034a9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8034dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8034e0:	5b                   	pop    %ebx
  8034e1:	5e                   	pop    %esi
  8034e2:	5f                   	pop    %edi
  8034e3:	5d                   	pop    %ebp
  8034e4:	c3                   	ret    

008034e5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8034e5:	55                   	push   %ebp
  8034e6:	89 e5                	mov    %esp,%ebp
  8034e8:	83 ec 08             	sub    $0x8,%esp
  8034eb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8034f0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8034f4:	74 2a                	je     803520 <devcons_read+0x3b>
  8034f6:	eb 05                	jmp    8034fd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8034f8:	e8 62 f0 ff ff       	call   80255f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8034fd:	e8 de ef ff ff       	call   8024e0 <sys_cgetc>
  803502:	85 c0                	test   %eax,%eax
  803504:	74 f2                	je     8034f8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803506:	85 c0                	test   %eax,%eax
  803508:	78 16                	js     803520 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80350a:	83 f8 04             	cmp    $0x4,%eax
  80350d:	74 0c                	je     80351b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80350f:	8b 55 0c             	mov    0xc(%ebp),%edx
  803512:	88 02                	mov    %al,(%edx)
	return 1;
  803514:	b8 01 00 00 00       	mov    $0x1,%eax
  803519:	eb 05                	jmp    803520 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80351b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803520:	c9                   	leave  
  803521:	c3                   	ret    

00803522 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803522:	55                   	push   %ebp
  803523:	89 e5                	mov    %esp,%ebp
  803525:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  803528:	8b 45 08             	mov    0x8(%ebp),%eax
  80352b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80352e:	6a 01                	push   $0x1
  803530:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803533:	50                   	push   %eax
  803534:	e8 89 ef ff ff       	call   8024c2 <sys_cputs>
}
  803539:	83 c4 10             	add    $0x10,%esp
  80353c:	c9                   	leave  
  80353d:	c3                   	ret    

0080353e <getchar>:

int
getchar(void)
{
  80353e:	55                   	push   %ebp
  80353f:	89 e5                	mov    %esp,%ebp
  803541:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803544:	6a 01                	push   $0x1
  803546:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803549:	50                   	push   %eax
  80354a:	6a 00                	push   $0x0
  80354c:	e8 5c f6 ff ff       	call   802bad <read>
	if (r < 0)
  803551:	83 c4 10             	add    $0x10,%esp
  803554:	85 c0                	test   %eax,%eax
  803556:	78 0f                	js     803567 <getchar+0x29>
		return r;
	if (r < 1)
  803558:	85 c0                	test   %eax,%eax
  80355a:	7e 06                	jle    803562 <getchar+0x24>
		return -E_EOF;
	return c;
  80355c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803560:	eb 05                	jmp    803567 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803562:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803567:	c9                   	leave  
  803568:	c3                   	ret    

00803569 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803569:	55                   	push   %ebp
  80356a:	89 e5                	mov    %esp,%ebp
  80356c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80356f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803572:	50                   	push   %eax
  803573:	ff 75 08             	pushl  0x8(%ebp)
  803576:	e8 cc f3 ff ff       	call   802947 <fd_lookup>
  80357b:	83 c4 10             	add    $0x10,%esp
  80357e:	85 c0                	test   %eax,%eax
  803580:	78 11                	js     803593 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803585:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80358b:	39 10                	cmp    %edx,(%eax)
  80358d:	0f 94 c0             	sete   %al
  803590:	0f b6 c0             	movzbl %al,%eax
}
  803593:	c9                   	leave  
  803594:	c3                   	ret    

00803595 <opencons>:

int
opencons(void)
{
  803595:	55                   	push   %ebp
  803596:	89 e5                	mov    %esp,%ebp
  803598:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80359b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80359e:	50                   	push   %eax
  80359f:	e8 54 f3 ff ff       	call   8028f8 <fd_alloc>
  8035a4:	83 c4 10             	add    $0x10,%esp
		return r;
  8035a7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8035a9:	85 c0                	test   %eax,%eax
  8035ab:	78 3e                	js     8035eb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035ad:	83 ec 04             	sub    $0x4,%esp
  8035b0:	68 07 04 00 00       	push   $0x407
  8035b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8035b8:	6a 00                	push   $0x0
  8035ba:	e8 bf ef ff ff       	call   80257e <sys_page_alloc>
  8035bf:	83 c4 10             	add    $0x10,%esp
		return r;
  8035c2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8035c4:	85 c0                	test   %eax,%eax
  8035c6:	78 23                	js     8035eb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8035c8:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8035ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035d1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8035d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8035d6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8035dd:	83 ec 0c             	sub    $0xc,%esp
  8035e0:	50                   	push   %eax
  8035e1:	e8 eb f2 ff ff       	call   8028d1 <fd2num>
  8035e6:	89 c2                	mov    %eax,%edx
  8035e8:	83 c4 10             	add    $0x10,%esp
}
  8035eb:	89 d0                	mov    %edx,%eax
  8035ed:	c9                   	leave  
  8035ee:	c3                   	ret    
  8035ef:	90                   	nop

008035f0 <__udivdi3>:
  8035f0:	55                   	push   %ebp
  8035f1:	57                   	push   %edi
  8035f2:	56                   	push   %esi
  8035f3:	53                   	push   %ebx
  8035f4:	83 ec 1c             	sub    $0x1c,%esp
  8035f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8035fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8035ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803603:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803607:	85 f6                	test   %esi,%esi
  803609:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80360d:	89 ca                	mov    %ecx,%edx
  80360f:	89 f8                	mov    %edi,%eax
  803611:	75 3d                	jne    803650 <__udivdi3+0x60>
  803613:	39 cf                	cmp    %ecx,%edi
  803615:	0f 87 c5 00 00 00    	ja     8036e0 <__udivdi3+0xf0>
  80361b:	85 ff                	test   %edi,%edi
  80361d:	89 fd                	mov    %edi,%ebp
  80361f:	75 0b                	jne    80362c <__udivdi3+0x3c>
  803621:	b8 01 00 00 00       	mov    $0x1,%eax
  803626:	31 d2                	xor    %edx,%edx
  803628:	f7 f7                	div    %edi
  80362a:	89 c5                	mov    %eax,%ebp
  80362c:	89 c8                	mov    %ecx,%eax
  80362e:	31 d2                	xor    %edx,%edx
  803630:	f7 f5                	div    %ebp
  803632:	89 c1                	mov    %eax,%ecx
  803634:	89 d8                	mov    %ebx,%eax
  803636:	89 cf                	mov    %ecx,%edi
  803638:	f7 f5                	div    %ebp
  80363a:	89 c3                	mov    %eax,%ebx
  80363c:	89 d8                	mov    %ebx,%eax
  80363e:	89 fa                	mov    %edi,%edx
  803640:	83 c4 1c             	add    $0x1c,%esp
  803643:	5b                   	pop    %ebx
  803644:	5e                   	pop    %esi
  803645:	5f                   	pop    %edi
  803646:	5d                   	pop    %ebp
  803647:	c3                   	ret    
  803648:	90                   	nop
  803649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803650:	39 ce                	cmp    %ecx,%esi
  803652:	77 74                	ja     8036c8 <__udivdi3+0xd8>
  803654:	0f bd fe             	bsr    %esi,%edi
  803657:	83 f7 1f             	xor    $0x1f,%edi
  80365a:	0f 84 98 00 00 00    	je     8036f8 <__udivdi3+0x108>
  803660:	bb 20 00 00 00       	mov    $0x20,%ebx
  803665:	89 f9                	mov    %edi,%ecx
  803667:	89 c5                	mov    %eax,%ebp
  803669:	29 fb                	sub    %edi,%ebx
  80366b:	d3 e6                	shl    %cl,%esi
  80366d:	89 d9                	mov    %ebx,%ecx
  80366f:	d3 ed                	shr    %cl,%ebp
  803671:	89 f9                	mov    %edi,%ecx
  803673:	d3 e0                	shl    %cl,%eax
  803675:	09 ee                	or     %ebp,%esi
  803677:	89 d9                	mov    %ebx,%ecx
  803679:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80367d:	89 d5                	mov    %edx,%ebp
  80367f:	8b 44 24 08          	mov    0x8(%esp),%eax
  803683:	d3 ed                	shr    %cl,%ebp
  803685:	89 f9                	mov    %edi,%ecx
  803687:	d3 e2                	shl    %cl,%edx
  803689:	89 d9                	mov    %ebx,%ecx
  80368b:	d3 e8                	shr    %cl,%eax
  80368d:	09 c2                	or     %eax,%edx
  80368f:	89 d0                	mov    %edx,%eax
  803691:	89 ea                	mov    %ebp,%edx
  803693:	f7 f6                	div    %esi
  803695:	89 d5                	mov    %edx,%ebp
  803697:	89 c3                	mov    %eax,%ebx
  803699:	f7 64 24 0c          	mull   0xc(%esp)
  80369d:	39 d5                	cmp    %edx,%ebp
  80369f:	72 10                	jb     8036b1 <__udivdi3+0xc1>
  8036a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8036a5:	89 f9                	mov    %edi,%ecx
  8036a7:	d3 e6                	shl    %cl,%esi
  8036a9:	39 c6                	cmp    %eax,%esi
  8036ab:	73 07                	jae    8036b4 <__udivdi3+0xc4>
  8036ad:	39 d5                	cmp    %edx,%ebp
  8036af:	75 03                	jne    8036b4 <__udivdi3+0xc4>
  8036b1:	83 eb 01             	sub    $0x1,%ebx
  8036b4:	31 ff                	xor    %edi,%edi
  8036b6:	89 d8                	mov    %ebx,%eax
  8036b8:	89 fa                	mov    %edi,%edx
  8036ba:	83 c4 1c             	add    $0x1c,%esp
  8036bd:	5b                   	pop    %ebx
  8036be:	5e                   	pop    %esi
  8036bf:	5f                   	pop    %edi
  8036c0:	5d                   	pop    %ebp
  8036c1:	c3                   	ret    
  8036c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036c8:	31 ff                	xor    %edi,%edi
  8036ca:	31 db                	xor    %ebx,%ebx
  8036cc:	89 d8                	mov    %ebx,%eax
  8036ce:	89 fa                	mov    %edi,%edx
  8036d0:	83 c4 1c             	add    $0x1c,%esp
  8036d3:	5b                   	pop    %ebx
  8036d4:	5e                   	pop    %esi
  8036d5:	5f                   	pop    %edi
  8036d6:	5d                   	pop    %ebp
  8036d7:	c3                   	ret    
  8036d8:	90                   	nop
  8036d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036e0:	89 d8                	mov    %ebx,%eax
  8036e2:	f7 f7                	div    %edi
  8036e4:	31 ff                	xor    %edi,%edi
  8036e6:	89 c3                	mov    %eax,%ebx
  8036e8:	89 d8                	mov    %ebx,%eax
  8036ea:	89 fa                	mov    %edi,%edx
  8036ec:	83 c4 1c             	add    $0x1c,%esp
  8036ef:	5b                   	pop    %ebx
  8036f0:	5e                   	pop    %esi
  8036f1:	5f                   	pop    %edi
  8036f2:	5d                   	pop    %ebp
  8036f3:	c3                   	ret    
  8036f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036f8:	39 ce                	cmp    %ecx,%esi
  8036fa:	72 0c                	jb     803708 <__udivdi3+0x118>
  8036fc:	31 db                	xor    %ebx,%ebx
  8036fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803702:	0f 87 34 ff ff ff    	ja     80363c <__udivdi3+0x4c>
  803708:	bb 01 00 00 00       	mov    $0x1,%ebx
  80370d:	e9 2a ff ff ff       	jmp    80363c <__udivdi3+0x4c>
  803712:	66 90                	xchg   %ax,%ax
  803714:	66 90                	xchg   %ax,%ax
  803716:	66 90                	xchg   %ax,%ax
  803718:	66 90                	xchg   %ax,%ax
  80371a:	66 90                	xchg   %ax,%ax
  80371c:	66 90                	xchg   %ax,%ax
  80371e:	66 90                	xchg   %ax,%ax

00803720 <__umoddi3>:
  803720:	55                   	push   %ebp
  803721:	57                   	push   %edi
  803722:	56                   	push   %esi
  803723:	53                   	push   %ebx
  803724:	83 ec 1c             	sub    $0x1c,%esp
  803727:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80372b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80372f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803733:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803737:	85 d2                	test   %edx,%edx
  803739:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80373d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803741:	89 f3                	mov    %esi,%ebx
  803743:	89 3c 24             	mov    %edi,(%esp)
  803746:	89 74 24 04          	mov    %esi,0x4(%esp)
  80374a:	75 1c                	jne    803768 <__umoddi3+0x48>
  80374c:	39 f7                	cmp    %esi,%edi
  80374e:	76 50                	jbe    8037a0 <__umoddi3+0x80>
  803750:	89 c8                	mov    %ecx,%eax
  803752:	89 f2                	mov    %esi,%edx
  803754:	f7 f7                	div    %edi
  803756:	89 d0                	mov    %edx,%eax
  803758:	31 d2                	xor    %edx,%edx
  80375a:	83 c4 1c             	add    $0x1c,%esp
  80375d:	5b                   	pop    %ebx
  80375e:	5e                   	pop    %esi
  80375f:	5f                   	pop    %edi
  803760:	5d                   	pop    %ebp
  803761:	c3                   	ret    
  803762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803768:	39 f2                	cmp    %esi,%edx
  80376a:	89 d0                	mov    %edx,%eax
  80376c:	77 52                	ja     8037c0 <__umoddi3+0xa0>
  80376e:	0f bd ea             	bsr    %edx,%ebp
  803771:	83 f5 1f             	xor    $0x1f,%ebp
  803774:	75 5a                	jne    8037d0 <__umoddi3+0xb0>
  803776:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80377a:	0f 82 e0 00 00 00    	jb     803860 <__umoddi3+0x140>
  803780:	39 0c 24             	cmp    %ecx,(%esp)
  803783:	0f 86 d7 00 00 00    	jbe    803860 <__umoddi3+0x140>
  803789:	8b 44 24 08          	mov    0x8(%esp),%eax
  80378d:	8b 54 24 04          	mov    0x4(%esp),%edx
  803791:	83 c4 1c             	add    $0x1c,%esp
  803794:	5b                   	pop    %ebx
  803795:	5e                   	pop    %esi
  803796:	5f                   	pop    %edi
  803797:	5d                   	pop    %ebp
  803798:	c3                   	ret    
  803799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8037a0:	85 ff                	test   %edi,%edi
  8037a2:	89 fd                	mov    %edi,%ebp
  8037a4:	75 0b                	jne    8037b1 <__umoddi3+0x91>
  8037a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8037ab:	31 d2                	xor    %edx,%edx
  8037ad:	f7 f7                	div    %edi
  8037af:	89 c5                	mov    %eax,%ebp
  8037b1:	89 f0                	mov    %esi,%eax
  8037b3:	31 d2                	xor    %edx,%edx
  8037b5:	f7 f5                	div    %ebp
  8037b7:	89 c8                	mov    %ecx,%eax
  8037b9:	f7 f5                	div    %ebp
  8037bb:	89 d0                	mov    %edx,%eax
  8037bd:	eb 99                	jmp    803758 <__umoddi3+0x38>
  8037bf:	90                   	nop
  8037c0:	89 c8                	mov    %ecx,%eax
  8037c2:	89 f2                	mov    %esi,%edx
  8037c4:	83 c4 1c             	add    $0x1c,%esp
  8037c7:	5b                   	pop    %ebx
  8037c8:	5e                   	pop    %esi
  8037c9:	5f                   	pop    %edi
  8037ca:	5d                   	pop    %ebp
  8037cb:	c3                   	ret    
  8037cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8037d0:	8b 34 24             	mov    (%esp),%esi
  8037d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8037d8:	89 e9                	mov    %ebp,%ecx
  8037da:	29 ef                	sub    %ebp,%edi
  8037dc:	d3 e0                	shl    %cl,%eax
  8037de:	89 f9                	mov    %edi,%ecx
  8037e0:	89 f2                	mov    %esi,%edx
  8037e2:	d3 ea                	shr    %cl,%edx
  8037e4:	89 e9                	mov    %ebp,%ecx
  8037e6:	09 c2                	or     %eax,%edx
  8037e8:	89 d8                	mov    %ebx,%eax
  8037ea:	89 14 24             	mov    %edx,(%esp)
  8037ed:	89 f2                	mov    %esi,%edx
  8037ef:	d3 e2                	shl    %cl,%edx
  8037f1:	89 f9                	mov    %edi,%ecx
  8037f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8037f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8037fb:	d3 e8                	shr    %cl,%eax
  8037fd:	89 e9                	mov    %ebp,%ecx
  8037ff:	89 c6                	mov    %eax,%esi
  803801:	d3 e3                	shl    %cl,%ebx
  803803:	89 f9                	mov    %edi,%ecx
  803805:	89 d0                	mov    %edx,%eax
  803807:	d3 e8                	shr    %cl,%eax
  803809:	89 e9                	mov    %ebp,%ecx
  80380b:	09 d8                	or     %ebx,%eax
  80380d:	89 d3                	mov    %edx,%ebx
  80380f:	89 f2                	mov    %esi,%edx
  803811:	f7 34 24             	divl   (%esp)
  803814:	89 d6                	mov    %edx,%esi
  803816:	d3 e3                	shl    %cl,%ebx
  803818:	f7 64 24 04          	mull   0x4(%esp)
  80381c:	39 d6                	cmp    %edx,%esi
  80381e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803822:	89 d1                	mov    %edx,%ecx
  803824:	89 c3                	mov    %eax,%ebx
  803826:	72 08                	jb     803830 <__umoddi3+0x110>
  803828:	75 11                	jne    80383b <__umoddi3+0x11b>
  80382a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80382e:	73 0b                	jae    80383b <__umoddi3+0x11b>
  803830:	2b 44 24 04          	sub    0x4(%esp),%eax
  803834:	1b 14 24             	sbb    (%esp),%edx
  803837:	89 d1                	mov    %edx,%ecx
  803839:	89 c3                	mov    %eax,%ebx
  80383b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80383f:	29 da                	sub    %ebx,%edx
  803841:	19 ce                	sbb    %ecx,%esi
  803843:	89 f9                	mov    %edi,%ecx
  803845:	89 f0                	mov    %esi,%eax
  803847:	d3 e0                	shl    %cl,%eax
  803849:	89 e9                	mov    %ebp,%ecx
  80384b:	d3 ea                	shr    %cl,%edx
  80384d:	89 e9                	mov    %ebp,%ecx
  80384f:	d3 ee                	shr    %cl,%esi
  803851:	09 d0                	or     %edx,%eax
  803853:	89 f2                	mov    %esi,%edx
  803855:	83 c4 1c             	add    $0x1c,%esp
  803858:	5b                   	pop    %ebx
  803859:	5e                   	pop    %esi
  80385a:	5f                   	pop    %edi
  80385b:	5d                   	pop    %ebp
  80385c:	c3                   	ret    
  80385d:	8d 76 00             	lea    0x0(%esi),%esi
  803860:	29 f9                	sub    %edi,%ecx
  803862:	19 d6                	sbb    %edx,%esi
  803864:	89 74 24 04          	mov    %esi,0x4(%esp)
  803868:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80386c:	e9 18 ff ff ff       	jmp    803789 <__umoddi3+0x69>
