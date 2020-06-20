
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 c0 23 80 00       	push   $0x8023c0
  800043:	e8 79 19 00 00       	call   8019c1 <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 c5 23 80 00       	push   $0x8023c5
  800057:	6a 0c                	push   $0xc
  800059:	68 d3 23 80 00       	push   $0x8023d3
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 35 16 00 00       	call   8016a3 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 4d 15 00 00       	call   8015ce <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 e8 23 80 00       	push   $0x8023e8
  800090:	6a 0f                	push   $0xf
  800092:	68 d3 23 80 00       	push   $0x8023d3
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 cb 0f 00 00       	call   80106c <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 f2 23 80 00       	push   $0x8023f2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 d3 23 80 00       	push   $0x8023d3
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 d7 15 00 00       	call   8016a3 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 e3 14 00 00       	call   8015ce <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 74 24 80 00       	push   $0x802474
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 d3 23 80 00       	push   $0x8023d3
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 b2 09 00 00       	call   800acd <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 a0 24 80 00       	push   $0x8024a0
  80012a:	6a 19                	push   $0x19
  80012c:	68 d3 23 80 00       	push   $0x8023d3
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 fb 23 80 00       	push   $0x8023fb
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 55 15 00 00       	call   8016a3 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 ab 12 00 00       	call   801401 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 5a 1c 00 00       	call   801dc1 <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 54 14 00 00       	call   8015ce <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 d8 24 80 00       	push   $0x8024d8
  80018b:	6a 21                	push   $0x21
  80018d:	68 d3 23 80 00       	push   $0x8023d3
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 14 24 80 00       	push   $0x802414
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 55 12 00 00       	call   801401 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 bd 0a 00 00       	call   800c85 <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 23 12 00 00       	call   80142c <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 31 0a 00 00       	call   800c44 <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 5a 0a 00 00       	call   800c85 <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 08 25 80 00       	push   $0x802508
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 23 29 80 00 	movl   $0x802923,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 79 09 00 00       	call   800c07 <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 54 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 1e 09 00 00       	call   800c07 <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 d7 1d 00 00       	call   802130 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 c4 1e 00 00       	call   802260 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 2b 25 80 00 	movsbl 0x80252b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b7:	83 fa 01             	cmp    $0x1,%edx
  8003ba:	7e 0e                	jle    8003ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003bc:	8b 10                	mov    (%eax),%edx
  8003be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 02                	mov    (%edx),%eax
  8003c5:	8b 52 04             	mov    0x4(%edx),%edx
  8003c8:	eb 22                	jmp    8003ec <getuint+0x38>
	else if (lflag)
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	74 10                	je     8003de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003dc:	eb 0e                	jmp    8003ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
	va_end(ap);
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	eb 12                	jmp    80044e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80043c:	85 c0                	test   %eax,%eax
  80043e:	0f 84 d3 03 00 00    	je     800817 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	53                   	push   %ebx
  800448:	50                   	push   %eax
  800449:	ff d6                	call   *%esi
  80044b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80044e:	83 c7 01             	add    $0x1,%edi
  800451:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800455:	83 f8 25             	cmp    $0x25,%eax
  800458:	75 e2                	jne    80043c <vprintfmt+0x14>
  80045a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80045e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800465:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80046c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	eb 07                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80047d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8d 47 01             	lea    0x1(%edi),%eax
  800484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800487:	0f b6 07             	movzbl (%edi),%eax
  80048a:	0f b6 c8             	movzbl %al,%ecx
  80048d:	83 e8 23             	sub    $0x23,%eax
  800490:	3c 55                	cmp    $0x55,%al
  800492:	0f 87 64 03 00 00    	ja     8007fc <vprintfmt+0x3d4>
  800498:	0f b6 c0             	movzbl %al,%eax
  80049b:	ff 24 85 60 26 80 00 	jmp    *0x802660(,%eax,4)
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004a9:	eb d6                	jmp    800481 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004c3:	83 fa 09             	cmp    $0x9,%edx
  8004c6:	77 39                	ja     800501 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004cb:	eb e9                	jmp    8004b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004de:	eb 27                	jmp    800507 <vprintfmt+0xdf>
  8004e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004ea:	0f 49 c8             	cmovns %eax,%ecx
  8004ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	eb 8c                	jmp    800481 <vprintfmt+0x59>
  8004f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004ff:	eb 80                	jmp    800481 <vprintfmt+0x59>
  800501:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800504:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	0f 89 70 ff ff ff    	jns    800481 <vprintfmt+0x59>
				width = precision, precision = -1;
  800511:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80051e:	e9 5e ff ff ff       	jmp    800481 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800523:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800526:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800529:	e9 53 ff ff ff       	jmp    800481 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 50 04             	lea    0x4(%eax),%edx
  800534:	89 55 14             	mov    %edx,0x14(%ebp)
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	ff 30                	pushl  (%eax)
  80053d:	ff d6                	call   *%esi
			break;
  80053f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 04 ff ff ff       	jmp    80044e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	99                   	cltd   
  800556:	31 d0                	xor    %edx,%eax
  800558:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055a:	83 f8 0f             	cmp    $0xf,%eax
  80055d:	7f 0b                	jg     80056a <vprintfmt+0x142>
  80055f:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	75 18                	jne    800582 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80056a:	50                   	push   %eax
  80056b:	68 43 25 80 00       	push   $0x802543
  800570:	53                   	push   %ebx
  800571:	56                   	push   %esi
  800572:	e8 94 fe ff ff       	call   80040b <printfmt>
  800577:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80057d:	e9 cc fe ff ff       	jmp    80044e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800582:	52                   	push   %edx
  800583:	68 69 2a 80 00       	push   $0x802a69
  800588:	53                   	push   %ebx
  800589:	56                   	push   %esi
  80058a:	e8 7c fe ff ff       	call   80040b <printfmt>
  80058f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800595:	e9 b4 fe ff ff       	jmp    80044e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8d 50 04             	lea    0x4(%eax),%edx
  8005a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	b8 3c 25 80 00       	mov    $0x80253c,%eax
  8005ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b3:	0f 8e 94 00 00 00    	jle    80064d <vprintfmt+0x225>
  8005b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005bd:	0f 84 98 00 00 00    	je     80065b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 c8             	pushl  -0x38(%ebp)
  8005c9:	57                   	push   %edi
  8005ca:	e8 d0 02 00 00       	call   80089f <strnlen>
  8005cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d2:	29 c1                	sub    %eax,%ecx
  8005d4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	eb 0f                	jmp    8005f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <vprintfmt+0x1c0>
  8005fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005fe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800601:	85 c9                	test   %ecx,%ecx
  800603:	b8 00 00 00 00       	mov    $0x0,%eax
  800608:	0f 49 c1             	cmovns %ecx,%eax
  80060b:	29 c1                	sub    %eax,%ecx
  80060d:	89 75 08             	mov    %esi,0x8(%ebp)
  800610:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800613:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800616:	89 cb                	mov    %ecx,%ebx
  800618:	eb 4d                	jmp    800667 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80061a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061e:	74 1b                	je     80063b <vprintfmt+0x213>
  800620:	0f be c0             	movsbl %al,%eax
  800623:	83 e8 20             	sub    $0x20,%eax
  800626:	83 f8 5e             	cmp    $0x5e,%eax
  800629:	76 10                	jbe    80063b <vprintfmt+0x213>
					putch('?', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	6a 3f                	push   $0x3f
  800633:	ff 55 08             	call   *0x8(%ebp)
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb 0d                	jmp    800648 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	52                   	push   %edx
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800648:	83 eb 01             	sub    $0x1,%ebx
  80064b:	eb 1a                	jmp    800667 <vprintfmt+0x23f>
  80064d:	89 75 08             	mov    %esi,0x8(%ebp)
  800650:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800653:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800656:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800659:	eb 0c                	jmp    800667 <vprintfmt+0x23f>
  80065b:	89 75 08             	mov    %esi,0x8(%ebp)
  80065e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800661:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800664:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800667:	83 c7 01             	add    $0x1,%edi
  80066a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066e:	0f be d0             	movsbl %al,%edx
  800671:	85 d2                	test   %edx,%edx
  800673:	74 23                	je     800698 <vprintfmt+0x270>
  800675:	85 f6                	test   %esi,%esi
  800677:	78 a1                	js     80061a <vprintfmt+0x1f2>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 9c                	jns    80061a <vprintfmt+0x1f2>
  80067e:	89 df                	mov    %ebx,%edi
  800680:	8b 75 08             	mov    0x8(%ebp),%esi
  800683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800686:	eb 18                	jmp    8006a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 20                	push   $0x20
  80068e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb 08                	jmp    8006a0 <vprintfmt+0x278>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	85 ff                	test   %edi,%edi
  8006a2:	7f e4                	jg     800688 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a7:	e9 a2 fd ff ff       	jmp    80044e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 fa 01             	cmp    $0x1,%edx
  8006af:	7e 16                	jle    8006c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 08             	lea    0x8(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006c2:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006c5:	eb 32                	jmp    8006f9 <vprintfmt+0x2d1>
	else if (lflag)
  8006c7:	85 d2                	test   %edx,%edx
  8006c9:	74 18                	je     8006e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006d9:	89 c1                	mov    %eax,%ecx
  8006db:	c1 f9 1f             	sar    $0x1f,%ecx
  8006de:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e1:	eb 16                	jmp    8006f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 50 04             	lea    0x4(%eax),%edx
  8006e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ec:	8b 00                	mov    (%eax),%eax
  8006ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006f1:	89 c1                	mov    %eax,%ecx
  8006f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006fc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800702:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800705:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80070a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80070e:	0f 89 b0 00 00 00    	jns    8007c4 <vprintfmt+0x39c>
				putch('-', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 2d                	push   $0x2d
  80071a:	ff d6                	call   *%esi
				num = -(long long) num;
  80071c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80071f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800722:	f7 d8                	neg    %eax
  800724:	83 d2 00             	adc    $0x0,%edx
  800727:	f7 da                	neg    %edx
  800729:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80072f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800732:	b8 0a 00 00 00       	mov    $0xa,%eax
  800737:	e9 88 00 00 00       	jmp    8007c4 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073c:	8d 45 14             	lea    0x14(%ebp),%eax
  80073f:	e8 70 fc ff ff       	call   8003b4 <getuint>
  800744:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800747:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80074a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80074f:	eb 73                	jmp    8007c4 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
  800754:	e8 5b fc ff ff       	call   8003b4 <getuint>
  800759:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	6a 58                	push   $0x58
  800765:	ff d6                	call   *%esi
			putch('X', putdat);
  800767:	83 c4 08             	add    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 58                	push   $0x58
  80076d:	ff d6                	call   *%esi
			putch('X', putdat);
  80076f:	83 c4 08             	add    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 58                	push   $0x58
  800775:	ff d6                	call   *%esi
			goto number;
  800777:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80077a:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80077f:	eb 43                	jmp    8007c4 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 30                	push   $0x30
  800787:	ff d6                	call   *%esi
			putch('x', putdat);
  800789:	83 c4 08             	add    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 78                	push   $0x78
  80078f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 50 04             	lea    0x4(%eax),%edx
  800797:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007aa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007af:	eb 13                	jmp    8007c4 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b4:	e8 fb fb ff ff       	call   8003b4 <getuint>
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c4:	83 ec 0c             	sub    $0xc,%esp
  8007c7:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8007cb:	52                   	push   %edx
  8007cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8007cf:	50                   	push   %eax
  8007d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8007d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8007d6:	89 da                	mov    %ebx,%edx
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	e8 26 fb ff ff       	call   800305 <printnum>
			break;
  8007df:	83 c4 20             	add    $0x20,%esp
  8007e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007e5:	e9 64 fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	51                   	push   %ecx
  8007ef:	ff d6                	call   *%esi
			break;
  8007f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007f7:	e9 52 fc ff ff       	jmp    80044e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	53                   	push   %ebx
  800800:	6a 25                	push   $0x25
  800802:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	eb 03                	jmp    80080c <vprintfmt+0x3e4>
  800809:	83 ef 01             	sub    $0x1,%edi
  80080c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800810:	75 f7                	jne    800809 <vprintfmt+0x3e1>
  800812:	e9 37 fc ff ff       	jmp    80044e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081a:	5b                   	pop    %ebx
  80081b:	5e                   	pop    %esi
  80081c:	5f                   	pop    %edi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	83 ec 18             	sub    $0x18,%esp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800832:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 26                	je     800866 <vsnprintf+0x47>
  800840:	85 d2                	test   %edx,%edx
  800842:	7e 22                	jle    800866 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800844:	ff 75 14             	pushl  0x14(%ebp)
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	68 ee 03 80 00       	push   $0x8003ee
  800853:	e8 d0 fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	eb 05                	jmp    80086b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800866:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800873:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800876:	50                   	push   %eax
  800877:	ff 75 10             	pushl  0x10(%ebp)
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	ff 75 08             	pushl  0x8(%ebp)
  800880:	e8 9a ff ff ff       	call   80081f <vsnprintf>
	va_end(ap);

	return rc;
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
  800892:	eb 03                	jmp    800897 <strlen+0x10>
		n++;
  800894:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800897:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089b:	75 f7                	jne    800894 <strlen+0xd>
		n++;
	return n;
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ad:	eb 03                	jmp    8008b2 <strnlen+0x13>
		n++;
  8008af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b2:	39 c2                	cmp    %eax,%edx
  8008b4:	74 08                	je     8008be <strnlen+0x1f>
  8008b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ba:	75 f3                	jne    8008af <strnlen+0x10>
  8008bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ca:	89 c2                	mov    %eax,%edx
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d9:	84 db                	test   %bl,%bl
  8008db:	75 ef                	jne    8008cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e7:	53                   	push   %ebx
  8008e8:	e8 9a ff ff ff       	call   800887 <strlen>
  8008ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	01 d8                	add    %ebx,%eax
  8008f5:	50                   	push   %eax
  8008f6:	e8 c5 ff ff ff       	call   8008c0 <strcpy>
	return dst;
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
  800907:	8b 75 08             	mov    0x8(%ebp),%esi
  80090a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090d:	89 f3                	mov    %esi,%ebx
  80090f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800912:	89 f2                	mov    %esi,%edx
  800914:	eb 0f                	jmp    800925 <strncpy+0x23>
		*dst++ = *src;
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	0f b6 01             	movzbl (%ecx),%eax
  80091c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091f:	80 39 01             	cmpb   $0x1,(%ecx)
  800922:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800925:	39 da                	cmp    %ebx,%edx
  800927:	75 ed                	jne    800916 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800929:	89 f0                	mov    %esi,%eax
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093a:	8b 55 10             	mov    0x10(%ebp),%edx
  80093d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093f:	85 d2                	test   %edx,%edx
  800941:	74 21                	je     800964 <strlcpy+0x35>
  800943:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 09                	jmp    800954 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800954:	39 c2                	cmp    %eax,%edx
  800956:	74 09                	je     800961 <strlcpy+0x32>
  800958:	0f b6 19             	movzbl (%ecx),%ebx
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ec                	jne    80094b <strlcpy+0x1c>
  80095f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800961:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800964:	29 f0                	sub    %esi,%eax
}
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800970:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800973:	eb 06                	jmp    80097b <strcmp+0x11>
		p++, q++;
  800975:	83 c1 01             	add    $0x1,%ecx
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097b:	0f b6 01             	movzbl (%ecx),%eax
  80097e:	84 c0                	test   %al,%al
  800980:	74 04                	je     800986 <strcmp+0x1c>
  800982:	3a 02                	cmp    (%edx),%al
  800984:	74 ef                	je     800975 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 c0             	movzbl %al,%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	53                   	push   %ebx
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099a:	89 c3                	mov    %eax,%ebx
  80099c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strncmp+0x17>
		n--, p++, q++;
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009a7:	39 d8                	cmp    %ebx,%eax
  8009a9:	74 15                	je     8009c0 <strncmp+0x30>
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	84 c9                	test   %cl,%cl
  8009b0:	74 04                	je     8009b6 <strncmp+0x26>
  8009b2:	3a 0a                	cmp    (%edx),%cl
  8009b4:	74 eb                	je     8009a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 00             	movzbl (%eax),%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
  8009be:	eb 05                	jmp    8009c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d2:	eb 07                	jmp    8009db <strchr+0x13>
		if (*s == c)
  8009d4:	38 ca                	cmp    %cl,%dl
  8009d6:	74 0f                	je     8009e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	0f b6 10             	movzbl (%eax),%edx
  8009de:	84 d2                	test   %dl,%dl
  8009e0:	75 f2                	jne    8009d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	eb 03                	jmp    8009f8 <strfind+0xf>
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	74 04                	je     800a03 <strfind+0x1a>
  8009ff:	84 d2                	test   %dl,%dl
  800a01:	75 f2                	jne    8009f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a11:	85 c9                	test   %ecx,%ecx
  800a13:	74 36                	je     800a4b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1b:	75 28                	jne    800a45 <memset+0x40>
  800a1d:	f6 c1 03             	test   $0x3,%cl
  800a20:	75 23                	jne    800a45 <memset+0x40>
		c &= 0xFF;
  800a22:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a26:	89 d3                	mov    %edx,%ebx
  800a28:	c1 e3 08             	shl    $0x8,%ebx
  800a2b:	89 d6                	mov    %edx,%esi
  800a2d:	c1 e6 18             	shl    $0x18,%esi
  800a30:	89 d0                	mov    %edx,%eax
  800a32:	c1 e0 10             	shl    $0x10,%eax
  800a35:	09 f0                	or     %esi,%eax
  800a37:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a39:	89 d8                	mov    %ebx,%eax
  800a3b:	09 d0                	or     %edx,%eax
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
  800a40:	fc                   	cld    
  800a41:	f3 ab                	rep stos %eax,%es:(%edi)
  800a43:	eb 06                	jmp    800a4b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a48:	fc                   	cld    
  800a49:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4b:	89 f8                	mov    %edi,%eax
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a60:	39 c6                	cmp    %eax,%esi
  800a62:	73 35                	jae    800a99 <memmove+0x47>
  800a64:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a67:	39 d0                	cmp    %edx,%eax
  800a69:	73 2e                	jae    800a99 <memmove+0x47>
		s += n;
		d += n;
  800a6b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6e:	89 d6                	mov    %edx,%esi
  800a70:	09 fe                	or     %edi,%esi
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 13                	jne    800a8d <memmove+0x3b>
  800a7a:	f6 c1 03             	test   $0x3,%cl
  800a7d:	75 0e                	jne    800a8d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a7f:	83 ef 04             	sub    $0x4,%edi
  800a82:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a85:	c1 e9 02             	shr    $0x2,%ecx
  800a88:	fd                   	std    
  800a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8b:	eb 09                	jmp    800a96 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8d:	83 ef 01             	sub    $0x1,%edi
  800a90:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a93:	fd                   	std    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a96:	fc                   	cld    
  800a97:	eb 1d                	jmp    800ab6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a99:	89 f2                	mov    %esi,%edx
  800a9b:	09 c2                	or     %eax,%edx
  800a9d:	f6 c2 03             	test   $0x3,%dl
  800aa0:	75 0f                	jne    800ab1 <memmove+0x5f>
  800aa2:	f6 c1 03             	test   $0x3,%cl
  800aa5:	75 0a                	jne    800ab1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	fc                   	cld    
  800aad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aaf:	eb 05                	jmp    800ab6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	fc                   	cld    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abd:	ff 75 10             	pushl  0x10(%ebp)
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	ff 75 08             	pushl  0x8(%ebp)
  800ac6:	e8 87 ff ff ff       	call   800a52 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad8:	89 c6                	mov    %eax,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	eb 1a                	jmp    800af9 <memcmp+0x2c>
		if (*s1 != *s2)
  800adf:	0f b6 08             	movzbl (%eax),%ecx
  800ae2:	0f b6 1a             	movzbl (%edx),%ebx
  800ae5:	38 d9                	cmp    %bl,%cl
  800ae7:	74 0a                	je     800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c1             	movzbl %cl,%eax
  800aec:	0f b6 db             	movzbl %bl,%ebx
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	eb 0f                	jmp    800b02 <memcmp+0x35>
		s1++, s2++;
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f0                	cmp    %esi,%eax
  800afb:	75 e2                	jne    800adf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b0d:	89 c1                	mov    %eax,%ecx
  800b0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b16:	eb 0a                	jmp    800b22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b18:	0f b6 10             	movzbl (%eax),%edx
  800b1b:	39 da                	cmp    %ebx,%edx
  800b1d:	74 07                	je     800b26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1f:	83 c0 01             	add    $0x1,%eax
  800b22:	39 c8                	cmp    %ecx,%eax
  800b24:	72 f2                	jb     800b18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b35:	eb 03                	jmp    800b3a <strtol+0x11>
		s++;
  800b37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 01             	movzbl (%ecx),%eax
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f6                	je     800b37 <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f2                	je     800b37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	75 0a                	jne    800b53 <strtol+0x2a>
		s++;
  800b49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b51:	eb 11                	jmp    800b64 <strtol+0x3b>
  800b53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b58:	3c 2d                	cmp    $0x2d,%al
  800b5a:	75 08                	jne    800b64 <strtol+0x3b>
		s++, neg = 1;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6a:	75 15                	jne    800b81 <strtol+0x58>
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 10                	jne    800b81 <strtol+0x58>
  800b71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b75:	75 7c                	jne    800bf3 <strtol+0xca>
		s += 2, base = 16;
  800b77:	83 c1 02             	add    $0x2,%ecx
  800b7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b7f:	eb 16                	jmp    800b97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b81:	85 db                	test   %ebx,%ebx
  800b83:	75 12                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8d:	75 08                	jne    800b97 <strtol+0x6e>
		s++, base = 8;
  800b8f:	83 c1 01             	add    $0x1,%ecx
  800b92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9f:	0f b6 11             	movzbl (%ecx),%edx
  800ba2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ba5:	89 f3                	mov    %esi,%ebx
  800ba7:	80 fb 09             	cmp    $0x9,%bl
  800baa:	77 08                	ja     800bb4 <strtol+0x8b>
			dig = *s - '0';
  800bac:	0f be d2             	movsbl %dl,%edx
  800baf:	83 ea 30             	sub    $0x30,%edx
  800bb2:	eb 22                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bb4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb7:	89 f3                	mov    %esi,%ebx
  800bb9:	80 fb 19             	cmp    $0x19,%bl
  800bbc:	77 08                	ja     800bc6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bbe:	0f be d2             	movsbl %dl,%edx
  800bc1:	83 ea 57             	sub    $0x57,%edx
  800bc4:	eb 10                	jmp    800bd6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 19             	cmp    $0x19,%bl
  800bce:	77 16                	ja     800be6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bd0:	0f be d2             	movsbl %dl,%edx
  800bd3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bd6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd9:	7d 0b                	jge    800be6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bdb:	83 c1 01             	add    $0x1,%ecx
  800bde:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800be4:	eb b9                	jmp    800b9f <strtol+0x76>

	if (endptr)
  800be6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bea:	74 0d                	je     800bf9 <strtol+0xd0>
		*endptr = (char *) s;
  800bec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bef:	89 0e                	mov    %ecx,(%esi)
  800bf1:	eb 06                	jmp    800bf9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf3:	85 db                	test   %ebx,%ebx
  800bf5:	74 98                	je     800b8f <strtol+0x66>
  800bf7:	eb 9e                	jmp    800b97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	f7 da                	neg    %edx
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	89 c6                	mov    %eax,%esi
  800c1e:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 01 00 00 00       	mov    $0x1,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	b8 03 00 00 00       	mov    $0x3,%eax
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 cb                	mov    %ecx,%ebx
  800c5c:	89 cf                	mov    %ecx,%edi
  800c5e:	89 ce                	mov    %ecx,%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 03                	push   $0x3
  800c6c:	68 1f 28 80 00       	push   $0x80281f
  800c71:	6a 23                	push   $0x23
  800c73:	68 3c 28 80 00       	push   $0x80283c
  800c78:	e8 9b f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 04                	push   $0x4
  800ced:	68 1f 28 80 00       	push   $0x80281f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 3c 28 80 00       	push   $0x80283c
  800cf9:	e8 1a f5 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d20:	8b 75 18             	mov    0x18(%ebp),%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 05                	push   $0x5
  800d2f:	68 1f 28 80 00       	push   $0x80281f
  800d34:	6a 23                	push   $0x23
  800d36:	68 3c 28 80 00       	push   $0x80283c
  800d3b:	e8 d8 f4 ff ff       	call   800218 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 17                	jle    800d82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	50                   	push   %eax
  800d6f:	6a 06                	push   $0x6
  800d71:	68 1f 28 80 00       	push   $0x80281f
  800d76:	6a 23                	push   $0x23
  800d78:	68 3c 28 80 00       	push   $0x80283c
  800d7d:	e8 96 f4 ff ff       	call   800218 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	b8 08 00 00 00       	mov    $0x8,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 08                	push   $0x8
  800db3:	68 1f 28 80 00       	push   $0x80281f
  800db8:	6a 23                	push   $0x23
  800dba:	68 3c 28 80 00       	push   $0x80283c
  800dbf:	e8 54 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 09 00 00 00       	mov    $0x9,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 17                	jle    800e06 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 09                	push   $0x9
  800df5:	68 1f 28 80 00       	push   $0x80281f
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 3c 28 80 00       	push   $0x80283c
  800e01:	e8 12 f4 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	89 de                	mov    %ebx,%esi
  800e2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7e 17                	jle    800e48 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e31:	83 ec 0c             	sub    $0xc,%esp
  800e34:	50                   	push   %eax
  800e35:	6a 0a                	push   $0xa
  800e37:	68 1f 28 80 00       	push   $0x80281f
  800e3c:	6a 23                	push   $0x23
  800e3e:	68 3c 28 80 00       	push   $0x80283c
  800e43:	e8 d0 f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e56:	be 00 00 00 00       	mov    $0x0,%esi
  800e5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    

00800e73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e73:	55                   	push   %ebp
  800e74:	89 e5                	mov    %esp,%ebp
  800e76:	57                   	push   %edi
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800e7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	89 cb                	mov    %ecx,%ebx
  800e8b:	89 cf                	mov    %ecx,%edi
  800e8d:	89 ce                	mov    %ecx,%esi
  800e8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800e91:	85 c0                	test   %eax,%eax
  800e93:	7e 17                	jle    800eac <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	50                   	push   %eax
  800e99:	6a 0d                	push   $0xd
  800e9b:	68 1f 28 80 00       	push   $0x80281f
  800ea0:	6a 23                	push   $0x23
  800ea2:	68 3c 28 80 00       	push   $0x80283c
  800ea7:	e8 6c f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ebc:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800ebe:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ec2:	74 11                	je     800ed5 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800ec4:	89 d8                	mov    %ebx,%eax
  800ec6:	c1 e8 0c             	shr    $0xc,%eax
  800ec9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800ed0:	f6 c4 08             	test   $0x8,%ah
  800ed3:	75 14                	jne    800ee9 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 4a 28 80 00       	push   $0x80284a
  800edd:	6a 21                	push   $0x21
  800edf:	68 60 28 80 00       	push   $0x802860
  800ee4:	e8 2f f3 ff ff       	call   800218 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800ee9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800eef:	e8 91 fd ff ff       	call   800c85 <sys_getenvid>
  800ef4:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	6a 07                	push   $0x7
  800efb:	68 00 f0 7f 00       	push   $0x7ff000
  800f00:	50                   	push   %eax
  800f01:	e8 bd fd ff ff       	call   800cc3 <sys_page_alloc>
  800f06:	83 c4 10             	add    $0x10,%esp
  800f09:	85 c0                	test   %eax,%eax
  800f0b:	79 14                	jns    800f21 <pgfault+0x6d>
		panic("sys_page_alloc");
  800f0d:	83 ec 04             	sub    $0x4,%esp
  800f10:	68 6b 28 80 00       	push   $0x80286b
  800f15:	6a 30                	push   $0x30
  800f17:	68 60 28 80 00       	push   $0x802860
  800f1c:	e8 f7 f2 ff ff       	call   800218 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	68 00 10 00 00       	push   $0x1000
  800f29:	53                   	push   %ebx
  800f2a:	68 00 f0 7f 00       	push   $0x7ff000
  800f2f:	e8 86 fb ff ff       	call   800aba <memcpy>
	retv = sys_page_unmap(envid, addr);
  800f34:	83 c4 08             	add    $0x8,%esp
  800f37:	53                   	push   %ebx
  800f38:	56                   	push   %esi
  800f39:	e8 0a fe ff ff       	call   800d48 <sys_page_unmap>
	if(retv < 0){
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	79 12                	jns    800f57 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800f45:	50                   	push   %eax
  800f46:	68 58 29 80 00       	push   $0x802958
  800f4b:	6a 35                	push   $0x35
  800f4d:	68 60 28 80 00       	push   $0x802860
  800f52:	e8 c1 f2 ff ff       	call   800218 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800f57:	83 ec 0c             	sub    $0xc,%esp
  800f5a:	6a 07                	push   $0x7
  800f5c:	53                   	push   %ebx
  800f5d:	56                   	push   %esi
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	56                   	push   %esi
  800f64:	e8 9d fd ff ff       	call   800d06 <sys_page_map>
	if(retv < 0){
  800f69:	83 c4 20             	add    $0x20,%esp
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	79 14                	jns    800f84 <pgfault+0xd0>
		panic("sys_page_map");
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	68 7a 28 80 00       	push   $0x80287a
  800f78:	6a 39                	push   $0x39
  800f7a:	68 60 28 80 00       	push   $0x802860
  800f7f:	e8 94 f2 ff ff       	call   800218 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	68 00 f0 7f 00       	push   $0x7ff000
  800f8c:	56                   	push   %esi
  800f8d:	e8 b6 fd ff ff       	call   800d48 <sys_page_unmap>
	if(retv < 0){
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 14                	jns    800fad <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 87 28 80 00       	push   $0x802887
  800fa1:	6a 3d                	push   $0x3d
  800fa3:	68 60 28 80 00       	push   $0x802860
  800fa8:	e8 6b f2 ff ff       	call   800218 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800fad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800fbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fbf:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800fc2:	83 ec 08             	sub    $0x8,%esp
  800fc5:	53                   	push   %ebx
  800fc6:	68 a4 28 80 00       	push   $0x8028a4
  800fcb:	e8 21 f3 ff ff       	call   8002f1 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800fd0:	83 c4 0c             	add    $0xc,%esp
  800fd3:	6a 07                	push   $0x7
  800fd5:	53                   	push   %ebx
  800fd6:	56                   	push   %esi
  800fd7:	e8 e7 fc ff ff       	call   800cc3 <sys_page_alloc>
  800fdc:	83 c4 10             	add    $0x10,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	79 15                	jns    800ff8 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800fe3:	50                   	push   %eax
  800fe4:	68 b7 28 80 00       	push   $0x8028b7
  800fe9:	68 90 00 00 00       	push   $0x90
  800fee:	68 60 28 80 00       	push   $0x802860
  800ff3:	e8 20 f2 ff ff       	call   800218 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800ff8:	83 ec 0c             	sub    $0xc,%esp
  800ffb:	68 ca 28 80 00       	push   $0x8028ca
  801000:	e8 ec f2 ff ff       	call   8002f1 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801005:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80100c:	68 00 00 40 00       	push   $0x400000
  801011:	6a 00                	push   $0x0
  801013:	53                   	push   %ebx
  801014:	56                   	push   %esi
  801015:	e8 ec fc ff ff       	call   800d06 <sys_page_map>
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	79 15                	jns    801036 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  801021:	50                   	push   %eax
  801022:	68 d2 28 80 00       	push   $0x8028d2
  801027:	68 94 00 00 00       	push   $0x94
  80102c:	68 60 28 80 00       	push   $0x802860
  801031:	e8 e2 f1 ff ff       	call   800218 <_panic>
        cprintf("af_p_m.");
  801036:	83 ec 0c             	sub    $0xc,%esp
  801039:	68 e3 28 80 00       	push   $0x8028e3
  80103e:	e8 ae f2 ff ff       	call   8002f1 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  801043:	83 c4 0c             	add    $0xc,%esp
  801046:	68 00 10 00 00       	push   $0x1000
  80104b:	53                   	push   %ebx
  80104c:	68 00 00 40 00       	push   $0x400000
  801051:	e8 fc f9 ff ff       	call   800a52 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  801056:	c7 04 24 eb 28 80 00 	movl   $0x8028eb,(%esp)
  80105d:	e8 8f f2 ff ff       	call   8002f1 <cprintf>
}
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  801075:	68 b4 0e 80 00       	push   $0x800eb4
  80107a:	e8 14 0f 00 00       	call   801f93 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80107f:	b8 07 00 00 00       	mov    $0x7,%eax
  801084:	cd 30                	int    $0x30
  801086:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801089:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	85 c0                	test   %eax,%eax
  801091:	79 17                	jns    8010aa <fork+0x3e>
		panic("sys_exofork failed.");
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	68 f9 28 80 00       	push   $0x8028f9
  80109b:	68 b7 00 00 00       	push   $0xb7
  8010a0:	68 60 28 80 00       	push   $0x802860
  8010a5:	e8 6e f1 ff ff       	call   800218 <_panic>
  8010aa:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  8010af:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010b3:	75 21                	jne    8010d6 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010b5:	e8 cb fb ff ff       	call   800c85 <sys_getenvid>
  8010ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c7:	a3 20 44 80 00       	mov    %eax,0x804420
//		cprintf("we are the child.\n");
		return 0;
  8010cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d1:	e9 69 01 00 00       	jmp    80123f <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	c1 e8 16             	shr    $0x16,%eax
  8010db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  8010e2:	a8 01                	test   $0x1,%al
  8010e4:	0f 84 d6 00 00 00    	je     8011c0 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  8010ea:	89 de                	mov    %ebx,%esi
  8010ec:	c1 ee 0c             	shr    $0xc,%esi
  8010ef:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  8010f6:	a8 01                	test   $0x1,%al
  8010f8:	0f 84 c2 00 00 00    	je     8011c0 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  8010fe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  801105:	89 f7                	mov    %esi,%edi
  801107:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  80110a:	e8 76 fb ff ff       	call   800c85 <sys_getenvid>
  80110f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  801112:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801119:	f6 c4 04             	test   $0x4,%ah
  80111c:	74 1c                	je     80113a <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	68 07 0e 00 00       	push   $0xe07
  801126:	57                   	push   %edi
  801127:	ff 75 e0             	pushl  -0x20(%ebp)
  80112a:	57                   	push   %edi
  80112b:	6a 00                	push   $0x0
  80112d:	e8 d4 fb ff ff       	call   800d06 <sys_page_map>
  801132:	83 c4 20             	add    $0x20,%esp
  801135:	e9 86 00 00 00       	jmp    8011c0 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  80113a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801141:	a8 02                	test   $0x2,%al
  801143:	75 0c                	jne    801151 <fork+0xe5>
  801145:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80114c:	f6 c4 08             	test   $0x8,%ah
  80114f:	74 5b                	je     8011ac <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	68 05 08 00 00       	push   $0x805
  801159:	57                   	push   %edi
  80115a:	ff 75 e0             	pushl  -0x20(%ebp)
  80115d:	57                   	push   %edi
  80115e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801161:	e8 a0 fb ff ff       	call   800d06 <sys_page_map>
  801166:	83 c4 20             	add    $0x20,%esp
  801169:	85 c0                	test   %eax,%eax
  80116b:	79 12                	jns    80117f <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  80116d:	50                   	push   %eax
  80116e:	68 7c 29 80 00       	push   $0x80297c
  801173:	6a 5f                	push   $0x5f
  801175:	68 60 28 80 00       	push   $0x802860
  80117a:	e8 99 f0 ff ff       	call   800218 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	68 05 08 00 00       	push   $0x805
  801187:	57                   	push   %edi
  801188:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80118b:	50                   	push   %eax
  80118c:	57                   	push   %edi
  80118d:	50                   	push   %eax
  80118e:	e8 73 fb ff ff       	call   800d06 <sys_page_map>
  801193:	83 c4 20             	add    $0x20,%esp
  801196:	85 c0                	test   %eax,%eax
  801198:	79 26                	jns    8011c0 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  80119a:	50                   	push   %eax
  80119b:	68 a0 29 80 00       	push   $0x8029a0
  8011a0:	6a 64                	push   $0x64
  8011a2:	68 60 28 80 00       	push   $0x802860
  8011a7:	e8 6c f0 ff ff       	call   800218 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8011ac:	83 ec 0c             	sub    $0xc,%esp
  8011af:	6a 05                	push   $0x5
  8011b1:	57                   	push   %edi
  8011b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b5:	57                   	push   %edi
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 49 fb ff ff       	call   800d06 <sys_page_map>
  8011bd:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8011c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011c6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011cc:	0f 85 04 ff ff ff    	jne    8010d6 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	6a 07                	push   $0x7
  8011d7:	68 00 f0 bf ee       	push   $0xeebff000
  8011dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8011df:	e8 df fa ff ff       	call   800cc3 <sys_page_alloc>
	if(retv < 0){
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	79 17                	jns    801202 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	68 0d 29 80 00       	push   $0x80290d
  8011f3:	68 cc 00 00 00       	push   $0xcc
  8011f8:	68 60 28 80 00       	push   $0x802860
  8011fd:	e8 16 f0 ff ff       	call   800218 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	68 f8 1f 80 00       	push   $0x801ff8
  80120a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80120d:	57                   	push   %edi
  80120e:	e8 fb fb ff ff       	call   800e0e <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  801213:	83 c4 08             	add    $0x8,%esp
  801216:	6a 02                	push   $0x2
  801218:	57                   	push   %edi
  801219:	e8 6c fb ff ff       	call   800d8a <sys_env_set_status>
	if(retv < 0){
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	85 c0                	test   %eax,%eax
  801223:	79 17                	jns    80123c <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  801225:	83 ec 04             	sub    $0x4,%esp
  801228:	68 25 29 80 00       	push   $0x802925
  80122d:	68 dd 00 00 00       	push   $0xdd
  801232:	68 60 28 80 00       	push   $0x802860
  801237:	e8 dc ef ff ff       	call   800218 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  80123c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  80123f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <sfork>:

// Challenge!
int
sfork(void)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80124d:	68 41 29 80 00       	push   $0x802941
  801252:	68 e8 00 00 00       	push   $0xe8
  801257:	68 60 28 80 00       	push   $0x802860
  80125c:	e8 b7 ef ff ff       	call   800218 <_panic>

00801261 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801264:	8b 45 08             	mov    0x8(%ebp),%eax
  801267:	05 00 00 00 30       	add    $0x30000000,%eax
  80126c:	c1 e8 0c             	shr    $0xc,%eax
}
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801274:	8b 45 08             	mov    0x8(%ebp),%eax
  801277:	05 00 00 00 30       	add    $0x30000000,%eax
  80127c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801281:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801293:	89 c2                	mov    %eax,%edx
  801295:	c1 ea 16             	shr    $0x16,%edx
  801298:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129f:	f6 c2 01             	test   $0x1,%dl
  8012a2:	74 11                	je     8012b5 <fd_alloc+0x2d>
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	c1 ea 0c             	shr    $0xc,%edx
  8012a9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b0:	f6 c2 01             	test   $0x1,%dl
  8012b3:	75 09                	jne    8012be <fd_alloc+0x36>
			*fd_store = fd;
  8012b5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bc:	eb 17                	jmp    8012d5 <fd_alloc+0x4d>
  8012be:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012c3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012c8:	75 c9                	jne    801293 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ca:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012d0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012dd:	83 f8 1f             	cmp    $0x1f,%eax
  8012e0:	77 36                	ja     801318 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e2:	c1 e0 0c             	shl    $0xc,%eax
  8012e5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	c1 ea 16             	shr    $0x16,%edx
  8012ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	74 24                	je     80131f <fd_lookup+0x48>
  8012fb:	89 c2                	mov    %eax,%edx
  8012fd:	c1 ea 0c             	shr    $0xc,%edx
  801300:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801307:	f6 c2 01             	test   $0x1,%dl
  80130a:	74 1a                	je     801326 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80130c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130f:	89 02                	mov    %eax,(%edx)
	return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
  801316:	eb 13                	jmp    80132b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801318:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131d:	eb 0c                	jmp    80132b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80131f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801324:	eb 05                	jmp    80132b <fd_lookup+0x54>
  801326:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    

0080132d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 08             	sub    $0x8,%esp
  801333:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801336:	ba 40 2a 80 00       	mov    $0x802a40,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80133b:	eb 13                	jmp    801350 <dev_lookup+0x23>
  80133d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801340:	39 08                	cmp    %ecx,(%eax)
  801342:	75 0c                	jne    801350 <dev_lookup+0x23>
			*dev = devtab[i];
  801344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801347:	89 01                	mov    %eax,(%ecx)
			return 0;
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	eb 2e                	jmp    80137e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801350:	8b 02                	mov    (%edx),%eax
  801352:	85 c0                	test   %eax,%eax
  801354:	75 e7                	jne    80133d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801356:	a1 20 44 80 00       	mov    0x804420,%eax
  80135b:	8b 40 48             	mov    0x48(%eax),%eax
  80135e:	83 ec 04             	sub    $0x4,%esp
  801361:	51                   	push   %ecx
  801362:	50                   	push   %eax
  801363:	68 c4 29 80 00       	push   $0x8029c4
  801368:	e8 84 ef ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  80136d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801370:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 10             	sub    $0x10,%esp
  801388:	8b 75 08             	mov    0x8(%ebp),%esi
  80138b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80138e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801398:	c1 e8 0c             	shr    $0xc,%eax
  80139b:	50                   	push   %eax
  80139c:	e8 36 ff ff ff       	call   8012d7 <fd_lookup>
  8013a1:	83 c4 08             	add    $0x8,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 05                	js     8013ad <fd_close+0x2d>
	    || fd != fd2)
  8013a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ab:	74 0c                	je     8013b9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013ad:	84 db                	test   %bl,%bl
  8013af:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b4:	0f 44 c2             	cmove  %edx,%eax
  8013b7:	eb 41                	jmp    8013fa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bf:	50                   	push   %eax
  8013c0:	ff 36                	pushl  (%esi)
  8013c2:	e8 66 ff ff ff       	call   80132d <dev_lookup>
  8013c7:	89 c3                	mov    %eax,%ebx
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 1a                	js     8013ea <fd_close+0x6a>
		if (dev->dev_close)
  8013d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013d6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	74 0b                	je     8013ea <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013df:	83 ec 0c             	sub    $0xc,%esp
  8013e2:	56                   	push   %esi
  8013e3:	ff d0                	call   *%eax
  8013e5:	89 c3                	mov    %eax,%ebx
  8013e7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	56                   	push   %esi
  8013ee:	6a 00                	push   $0x0
  8013f0:	e8 53 f9 ff ff       	call   800d48 <sys_page_unmap>
	return r;
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	89 d8                	mov    %ebx,%eax
}
  8013fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	ff 75 08             	pushl  0x8(%ebp)
  80140e:	e8 c4 fe ff ff       	call   8012d7 <fd_lookup>
  801413:	83 c4 08             	add    $0x8,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	78 10                	js     80142a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	6a 01                	push   $0x1
  80141f:	ff 75 f4             	pushl  -0xc(%ebp)
  801422:	e8 59 ff ff ff       	call   801380 <fd_close>
  801427:	83 c4 10             	add    $0x10,%esp
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <close_all>:

void
close_all(void)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801433:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801438:	83 ec 0c             	sub    $0xc,%esp
  80143b:	53                   	push   %ebx
  80143c:	e8 c0 ff ff ff       	call   801401 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801441:	83 c3 01             	add    $0x1,%ebx
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	83 fb 20             	cmp    $0x20,%ebx
  80144a:	75 ec                	jne    801438 <close_all+0xc>
		close(i);
}
  80144c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	57                   	push   %edi
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	83 ec 2c             	sub    $0x2c,%esp
  80145a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80145d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	ff 75 08             	pushl  0x8(%ebp)
  801464:	e8 6e fe ff ff       	call   8012d7 <fd_lookup>
  801469:	83 c4 08             	add    $0x8,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	0f 88 c1 00 00 00    	js     801535 <dup+0xe4>
		return r;
	close(newfdnum);
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	56                   	push   %esi
  801478:	e8 84 ff ff ff       	call   801401 <close>

	newfd = INDEX2FD(newfdnum);
  80147d:	89 f3                	mov    %esi,%ebx
  80147f:	c1 e3 0c             	shl    $0xc,%ebx
  801482:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801488:	83 c4 04             	add    $0x4,%esp
  80148b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80148e:	e8 de fd ff ff       	call   801271 <fd2data>
  801493:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801495:	89 1c 24             	mov    %ebx,(%esp)
  801498:	e8 d4 fd ff ff       	call   801271 <fd2data>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a3:	89 f8                	mov    %edi,%eax
  8014a5:	c1 e8 16             	shr    $0x16,%eax
  8014a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014af:	a8 01                	test   $0x1,%al
  8014b1:	74 37                	je     8014ea <dup+0x99>
  8014b3:	89 f8                	mov    %edi,%eax
  8014b5:	c1 e8 0c             	shr    $0xc,%eax
  8014b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014bf:	f6 c2 01             	test   $0x1,%dl
  8014c2:	74 26                	je     8014ea <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014cb:	83 ec 0c             	sub    $0xc,%esp
  8014ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014d7:	6a 00                	push   $0x0
  8014d9:	57                   	push   %edi
  8014da:	6a 00                	push   $0x0
  8014dc:	e8 25 f8 ff ff       	call   800d06 <sys_page_map>
  8014e1:	89 c7                	mov    %eax,%edi
  8014e3:	83 c4 20             	add    $0x20,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	78 2e                	js     801518 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014ed:	89 d0                	mov    %edx,%eax
  8014ef:	c1 e8 0c             	shr    $0xc,%eax
  8014f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	25 07 0e 00 00       	and    $0xe07,%eax
  801501:	50                   	push   %eax
  801502:	53                   	push   %ebx
  801503:	6a 00                	push   $0x0
  801505:	52                   	push   %edx
  801506:	6a 00                	push   $0x0
  801508:	e8 f9 f7 ff ff       	call   800d06 <sys_page_map>
  80150d:	89 c7                	mov    %eax,%edi
  80150f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801512:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801514:	85 ff                	test   %edi,%edi
  801516:	79 1d                	jns    801535 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	53                   	push   %ebx
  80151c:	6a 00                	push   $0x0
  80151e:	e8 25 f8 ff ff       	call   800d48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801523:	83 c4 08             	add    $0x8,%esp
  801526:	ff 75 d4             	pushl  -0x2c(%ebp)
  801529:	6a 00                	push   $0x0
  80152b:	e8 18 f8 ff ff       	call   800d48 <sys_page_unmap>
	return r;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	89 f8                	mov    %edi,%eax
}
  801535:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801538:	5b                   	pop    %ebx
  801539:	5e                   	pop    %esi
  80153a:	5f                   	pop    %edi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 14             	sub    $0x14,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801547:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	53                   	push   %ebx
  80154c:	e8 86 fd ff ff       	call   8012d7 <fd_lookup>
  801551:	83 c4 08             	add    $0x8,%esp
  801554:	89 c2                	mov    %eax,%edx
  801556:	85 c0                	test   %eax,%eax
  801558:	78 6d                	js     8015c7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	50                   	push   %eax
  801561:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801564:	ff 30                	pushl  (%eax)
  801566:	e8 c2 fd ff ff       	call   80132d <dev_lookup>
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 4c                	js     8015be <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801572:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801575:	8b 42 08             	mov    0x8(%edx),%eax
  801578:	83 e0 03             	and    $0x3,%eax
  80157b:	83 f8 01             	cmp    $0x1,%eax
  80157e:	75 21                	jne    8015a1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801580:	a1 20 44 80 00       	mov    0x804420,%eax
  801585:	8b 40 48             	mov    0x48(%eax),%eax
  801588:	83 ec 04             	sub    $0x4,%esp
  80158b:	53                   	push   %ebx
  80158c:	50                   	push   %eax
  80158d:	68 05 2a 80 00       	push   $0x802a05
  801592:	e8 5a ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801597:	83 c4 10             	add    $0x10,%esp
  80159a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80159f:	eb 26                	jmp    8015c7 <read+0x8a>
	}
	if (!dev->dev_read)
  8015a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a4:	8b 40 08             	mov    0x8(%eax),%eax
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	74 17                	je     8015c2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	ff 75 10             	pushl  0x10(%ebp)
  8015b1:	ff 75 0c             	pushl  0xc(%ebp)
  8015b4:	52                   	push   %edx
  8015b5:	ff d0                	call   *%eax
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 09                	jmp    8015c7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	eb 05                	jmp    8015c7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015c2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015c7:	89 d0                	mov    %edx,%eax
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e2:	eb 21                	jmp    801605 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	89 f0                	mov    %esi,%eax
  8015e9:	29 d8                	sub    %ebx,%eax
  8015eb:	50                   	push   %eax
  8015ec:	89 d8                	mov    %ebx,%eax
  8015ee:	03 45 0c             	add    0xc(%ebp),%eax
  8015f1:	50                   	push   %eax
  8015f2:	57                   	push   %edi
  8015f3:	e8 45 ff ff ff       	call   80153d <read>
		if (m < 0)
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 10                	js     80160f <readn+0x41>
			return m;
		if (m == 0)
  8015ff:	85 c0                	test   %eax,%eax
  801601:	74 0a                	je     80160d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801603:	01 c3                	add    %eax,%ebx
  801605:	39 f3                	cmp    %esi,%ebx
  801607:	72 db                	jb     8015e4 <readn+0x16>
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	eb 02                	jmp    80160f <readn+0x41>
  80160d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	53                   	push   %ebx
  80161b:	83 ec 14             	sub    $0x14,%esp
  80161e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801621:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	53                   	push   %ebx
  801626:	e8 ac fc ff ff       	call   8012d7 <fd_lookup>
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	89 c2                	mov    %eax,%edx
  801630:	85 c0                	test   %eax,%eax
  801632:	78 68                	js     80169c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80163e:	ff 30                	pushl  (%eax)
  801640:	e8 e8 fc ff ff       	call   80132d <dev_lookup>
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	85 c0                	test   %eax,%eax
  80164a:	78 47                	js     801693 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801653:	75 21                	jne    801676 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801655:	a1 20 44 80 00       	mov    0x804420,%eax
  80165a:	8b 40 48             	mov    0x48(%eax),%eax
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	53                   	push   %ebx
  801661:	50                   	push   %eax
  801662:	68 21 2a 80 00       	push   $0x802a21
  801667:	e8 85 ec ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801674:	eb 26                	jmp    80169c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801676:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801679:	8b 52 0c             	mov    0xc(%edx),%edx
  80167c:	85 d2                	test   %edx,%edx
  80167e:	74 17                	je     801697 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801680:	83 ec 04             	sub    $0x4,%esp
  801683:	ff 75 10             	pushl  0x10(%ebp)
  801686:	ff 75 0c             	pushl  0xc(%ebp)
  801689:	50                   	push   %eax
  80168a:	ff d2                	call   *%edx
  80168c:	89 c2                	mov    %eax,%edx
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	eb 09                	jmp    80169c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801693:	89 c2                	mov    %eax,%edx
  801695:	eb 05                	jmp    80169c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801697:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80169c:	89 d0                	mov    %edx,%eax
  80169e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ac:	50                   	push   %eax
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 22 fc ff ff       	call   8012d7 <fd_lookup>
  8016b5:	83 c4 08             	add    $0x8,%esp
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 0e                	js     8016ca <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 14             	sub    $0x14,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	53                   	push   %ebx
  8016db:	e8 f7 fb ff ff       	call   8012d7 <fd_lookup>
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 65                	js     80174e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	ff 30                	pushl  (%eax)
  8016f5:	e8 33 fc ff ff       	call   80132d <dev_lookup>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 44                	js     801745 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801708:	75 21                	jne    80172b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80170a:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80170f:	8b 40 48             	mov    0x48(%eax),%eax
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	53                   	push   %ebx
  801716:	50                   	push   %eax
  801717:	68 e4 29 80 00       	push   $0x8029e4
  80171c:	e8 d0 eb ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801729:	eb 23                	jmp    80174e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80172b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172e:	8b 52 18             	mov    0x18(%edx),%edx
  801731:	85 d2                	test   %edx,%edx
  801733:	74 14                	je     801749 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	ff 75 0c             	pushl  0xc(%ebp)
  80173b:	50                   	push   %eax
  80173c:	ff d2                	call   *%edx
  80173e:	89 c2                	mov    %eax,%edx
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	eb 09                	jmp    80174e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801745:	89 c2                	mov    %eax,%edx
  801747:	eb 05                	jmp    80174e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801749:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80174e:	89 d0                	mov    %edx,%eax
  801750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801753:	c9                   	leave  
  801754:	c3                   	ret    

00801755 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	53                   	push   %ebx
  801759:	83 ec 14             	sub    $0x14,%esp
  80175c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801762:	50                   	push   %eax
  801763:	ff 75 08             	pushl  0x8(%ebp)
  801766:	e8 6c fb ff ff       	call   8012d7 <fd_lookup>
  80176b:	83 c4 08             	add    $0x8,%esp
  80176e:	89 c2                	mov    %eax,%edx
  801770:	85 c0                	test   %eax,%eax
  801772:	78 58                	js     8017cc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177a:	50                   	push   %eax
  80177b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177e:	ff 30                	pushl  (%eax)
  801780:	e8 a8 fb ff ff       	call   80132d <dev_lookup>
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	78 37                	js     8017c3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80178c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801793:	74 32                	je     8017c7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801795:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801798:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80179f:	00 00 00 
	stat->st_isdir = 0;
  8017a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a9:	00 00 00 
	stat->st_dev = dev;
  8017ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	53                   	push   %ebx
  8017b6:	ff 75 f0             	pushl  -0x10(%ebp)
  8017b9:	ff 50 14             	call   *0x14(%eax)
  8017bc:	89 c2                	mov    %eax,%edx
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	eb 09                	jmp    8017cc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c3:	89 c2                	mov    %eax,%edx
  8017c5:	eb 05                	jmp    8017cc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017cc:	89 d0                	mov    %edx,%eax
  8017ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017d8:	83 ec 08             	sub    $0x8,%esp
  8017db:	6a 00                	push   $0x0
  8017dd:	ff 75 08             	pushl  0x8(%ebp)
  8017e0:	e8 dc 01 00 00       	call   8019c1 <open>
  8017e5:	89 c3                	mov    %eax,%ebx
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	78 1b                	js     801809 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	50                   	push   %eax
  8017f5:	e8 5b ff ff ff       	call   801755 <fstat>
  8017fa:	89 c6                	mov    %eax,%esi
	close(fd);
  8017fc:	89 1c 24             	mov    %ebx,(%esp)
  8017ff:	e8 fd fb ff ff       	call   801401 <close>
	return r;
  801804:	83 c4 10             	add    $0x10,%esp
  801807:	89 f0                	mov    %esi,%eax
}
  801809:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180c:	5b                   	pop    %ebx
  80180d:	5e                   	pop    %esi
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	56                   	push   %esi
  801814:	53                   	push   %ebx
  801815:	89 c6                	mov    %eax,%esi
  801817:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801819:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801820:	75 12                	jne    801834 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	6a 01                	push   $0x1
  801827:	e8 90 08 00 00       	call   8020bc <ipc_find_env>
  80182c:	a3 00 40 80 00       	mov    %eax,0x804000
  801831:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801834:	6a 07                	push   $0x7
  801836:	68 00 50 80 00       	push   $0x805000
  80183b:	56                   	push   %esi
  80183c:	ff 35 00 40 80 00    	pushl  0x804000
  801842:	e8 32 08 00 00       	call   802079 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801847:	83 c4 0c             	add    $0xc,%esp
  80184a:	6a 00                	push   $0x0
  80184c:	53                   	push   %ebx
  80184d:	6a 00                	push   $0x0
  80184f:	e8 c8 07 00 00       	call   80201c <ipc_recv>
}
  801854:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	8b 40 0c             	mov    0xc(%eax),%eax
  801867:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 02 00 00 00       	mov    $0x2,%eax
  80187e:	e8 8d ff ff ff       	call   801810 <fsipc>
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 40 0c             	mov    0xc(%eax),%eax
  801891:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a0:	e8 6b ff ff ff       	call   801810 <fsipc>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	53                   	push   %ebx
  8018ab:	83 ec 04             	sub    $0x4,%esp
  8018ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c6:	e8 45 ff ff ff       	call   801810 <fsipc>
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 2c                	js     8018fb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	68 00 50 80 00       	push   $0x805000
  8018d7:	53                   	push   %ebx
  8018d8:	e8 e3 ef ff ff       	call   8008c0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8018ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018f3:	83 c4 10             	add    $0x10,%esp
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	83 ec 0c             	sub    $0xc,%esp
  801906:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801909:	8b 55 08             	mov    0x8(%ebp),%edx
  80190c:	8b 52 0c             	mov    0xc(%edx),%edx
  80190f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801915:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80191a:	50                   	push   %eax
  80191b:	ff 75 0c             	pushl  0xc(%ebp)
  80191e:	68 08 50 80 00       	push   $0x805008
  801923:	e8 2a f1 ff ff       	call   800a52 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801928:	ba 00 00 00 00       	mov    $0x0,%edx
  80192d:	b8 04 00 00 00       	mov    $0x4,%eax
  801932:	e8 d9 fe ff ff       	call   801810 <fsipc>
	//panic("devfile_write not implemented");
}
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	56                   	push   %esi
  80193d:	53                   	push   %ebx
  80193e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801941:	8b 45 08             	mov    0x8(%ebp),%eax
  801944:	8b 40 0c             	mov    0xc(%eax),%eax
  801947:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80194c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801952:	ba 00 00 00 00       	mov    $0x0,%edx
  801957:	b8 03 00 00 00       	mov    $0x3,%eax
  80195c:	e8 af fe ff ff       	call   801810 <fsipc>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	85 c0                	test   %eax,%eax
  801965:	78 51                	js     8019b8 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801967:	39 c6                	cmp    %eax,%esi
  801969:	73 19                	jae    801984 <devfile_read+0x4b>
  80196b:	68 50 2a 80 00       	push   $0x802a50
  801970:	68 57 2a 80 00       	push   $0x802a57
  801975:	68 80 00 00 00       	push   $0x80
  80197a:	68 6c 2a 80 00       	push   $0x802a6c
  80197f:	e8 94 e8 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801984:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801989:	7e 19                	jle    8019a4 <devfile_read+0x6b>
  80198b:	68 77 2a 80 00       	push   $0x802a77
  801990:	68 57 2a 80 00       	push   $0x802a57
  801995:	68 81 00 00 00       	push   $0x81
  80199a:	68 6c 2a 80 00       	push   $0x802a6c
  80199f:	e8 74 e8 ff ff       	call   800218 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019a4:	83 ec 04             	sub    $0x4,%esp
  8019a7:	50                   	push   %eax
  8019a8:	68 00 50 80 00       	push   $0x805000
  8019ad:	ff 75 0c             	pushl  0xc(%ebp)
  8019b0:	e8 9d f0 ff ff       	call   800a52 <memmove>
	return r;
  8019b5:	83 c4 10             	add    $0x10,%esp
}
  8019b8:	89 d8                	mov    %ebx,%eax
  8019ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5e                   	pop    %esi
  8019bf:	5d                   	pop    %ebp
  8019c0:	c3                   	ret    

008019c1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	53                   	push   %ebx
  8019c5:	83 ec 20             	sub    $0x20,%esp
  8019c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019cb:	53                   	push   %ebx
  8019cc:	e8 b6 ee ff ff       	call   800887 <strlen>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019d9:	7f 67                	jg     801a42 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e1:	50                   	push   %eax
  8019e2:	e8 a1 f8 ff ff       	call   801288 <fd_alloc>
  8019e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ea:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 57                	js     801a47 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019f0:	83 ec 08             	sub    $0x8,%esp
  8019f3:	53                   	push   %ebx
  8019f4:	68 00 50 80 00       	push   $0x805000
  8019f9:	e8 c2 ee ff ff       	call   8008c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a01:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a09:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0e:	e8 fd fd ff ff       	call   801810 <fsipc>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	85 c0                	test   %eax,%eax
  801a1a:	79 14                	jns    801a30 <open+0x6f>
		
		fd_close(fd, 0);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	6a 00                	push   $0x0
  801a21:	ff 75 f4             	pushl  -0xc(%ebp)
  801a24:	e8 57 f9 ff ff       	call   801380 <fd_close>
		return r;
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	89 da                	mov    %ebx,%edx
  801a2e:	eb 17                	jmp    801a47 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	ff 75 f4             	pushl  -0xc(%ebp)
  801a36:	e8 26 f8 ff ff       	call   801261 <fd2num>
  801a3b:	89 c2                	mov    %eax,%edx
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	eb 05                	jmp    801a47 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a42:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801a47:	89 d0                	mov    %edx,%eax
  801a49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
  801a59:	b8 08 00 00 00       	mov    $0x8,%eax
  801a5e:	e8 ad fd ff ff       	call   801810 <fsipc>
}
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	ff 75 08             	pushl  0x8(%ebp)
  801a73:	e8 f9 f7 ff ff       	call   801271 <fd2data>
  801a78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a7a:	83 c4 08             	add    $0x8,%esp
  801a7d:	68 83 2a 80 00       	push   $0x802a83
  801a82:	53                   	push   %ebx
  801a83:	e8 38 ee ff ff       	call   8008c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a88:	8b 46 04             	mov    0x4(%esi),%eax
  801a8b:	2b 06                	sub    (%esi),%eax
  801a8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9a:	00 00 00 
	stat->st_dev = &devpipe;
  801a9d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801aa4:	30 80 00 
	return 0;
}
  801aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  801aac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaf:	5b                   	pop    %ebx
  801ab0:	5e                   	pop    %esi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 0c             	sub    $0xc,%esp
  801aba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801abd:	53                   	push   %ebx
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 83 f2 ff ff       	call   800d48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac5:	89 1c 24             	mov    %ebx,(%esp)
  801ac8:	e8 a4 f7 ff ff       	call   801271 <fd2data>
  801acd:	83 c4 08             	add    $0x8,%esp
  801ad0:	50                   	push   %eax
  801ad1:	6a 00                	push   $0x0
  801ad3:	e8 70 f2 ff ff       	call   800d48 <sys_page_unmap>
}
  801ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801adb:	c9                   	leave  
  801adc:	c3                   	ret    

00801add <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	57                   	push   %edi
  801ae1:	56                   	push   %esi
  801ae2:	53                   	push   %ebx
  801ae3:	83 ec 1c             	sub    $0x1c,%esp
  801ae6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ae9:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aeb:	a1 20 44 80 00       	mov    0x804420,%eax
  801af0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	ff 75 e0             	pushl  -0x20(%ebp)
  801af9:	e8 f7 05 00 00       	call   8020f5 <pageref>
  801afe:	89 c3                	mov    %eax,%ebx
  801b00:	89 3c 24             	mov    %edi,(%esp)
  801b03:	e8 ed 05 00 00       	call   8020f5 <pageref>
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	39 c3                	cmp    %eax,%ebx
  801b0d:	0f 94 c1             	sete   %cl
  801b10:	0f b6 c9             	movzbl %cl,%ecx
  801b13:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b16:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801b1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b1f:	39 ce                	cmp    %ecx,%esi
  801b21:	74 1b                	je     801b3e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b23:	39 c3                	cmp    %eax,%ebx
  801b25:	75 c4                	jne    801aeb <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b27:	8b 42 58             	mov    0x58(%edx),%eax
  801b2a:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b2d:	50                   	push   %eax
  801b2e:	56                   	push   %esi
  801b2f:	68 8a 2a 80 00       	push   $0x802a8a
  801b34:	e8 b8 e7 ff ff       	call   8002f1 <cprintf>
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	eb ad                	jmp    801aeb <_pipeisclosed+0xe>
	}
}
  801b3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b44:	5b                   	pop    %ebx
  801b45:	5e                   	pop    %esi
  801b46:	5f                   	pop    %edi
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	57                   	push   %edi
  801b4d:	56                   	push   %esi
  801b4e:	53                   	push   %ebx
  801b4f:	83 ec 28             	sub    $0x28,%esp
  801b52:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b55:	56                   	push   %esi
  801b56:	e8 16 f7 ff ff       	call   801271 <fd2data>
  801b5b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	bf 00 00 00 00       	mov    $0x0,%edi
  801b65:	eb 4b                	jmp    801bb2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b67:	89 da                	mov    %ebx,%edx
  801b69:	89 f0                	mov    %esi,%eax
  801b6b:	e8 6d ff ff ff       	call   801add <_pipeisclosed>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	75 48                	jne    801bbc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b74:	e8 2b f1 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b79:	8b 43 04             	mov    0x4(%ebx),%eax
  801b7c:	8b 0b                	mov    (%ebx),%ecx
  801b7e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b81:	39 d0                	cmp    %edx,%eax
  801b83:	73 e2                	jae    801b67 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b88:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b8c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b8f:	89 c2                	mov    %eax,%edx
  801b91:	c1 fa 1f             	sar    $0x1f,%edx
  801b94:	89 d1                	mov    %edx,%ecx
  801b96:	c1 e9 1b             	shr    $0x1b,%ecx
  801b99:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b9c:	83 e2 1f             	and    $0x1f,%edx
  801b9f:	29 ca                	sub    %ecx,%edx
  801ba1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba9:	83 c0 01             	add    $0x1,%eax
  801bac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801baf:	83 c7 01             	add    $0x1,%edi
  801bb2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bb5:	75 c2                	jne    801b79 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bb7:	8b 45 10             	mov    0x10(%ebp),%eax
  801bba:	eb 05                	jmp    801bc1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bbc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	57                   	push   %edi
  801bcd:	56                   	push   %esi
  801bce:	53                   	push   %ebx
  801bcf:	83 ec 18             	sub    $0x18,%esp
  801bd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bd5:	57                   	push   %edi
  801bd6:	e8 96 f6 ff ff       	call   801271 <fd2data>
  801bdb:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801be5:	eb 3d                	jmp    801c24 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801be7:	85 db                	test   %ebx,%ebx
  801be9:	74 04                	je     801bef <devpipe_read+0x26>
				return i;
  801beb:	89 d8                	mov    %ebx,%eax
  801bed:	eb 44                	jmp    801c33 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bef:	89 f2                	mov    %esi,%edx
  801bf1:	89 f8                	mov    %edi,%eax
  801bf3:	e8 e5 fe ff ff       	call   801add <_pipeisclosed>
  801bf8:	85 c0                	test   %eax,%eax
  801bfa:	75 32                	jne    801c2e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bfc:	e8 a3 f0 ff ff       	call   800ca4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c01:	8b 06                	mov    (%esi),%eax
  801c03:	3b 46 04             	cmp    0x4(%esi),%eax
  801c06:	74 df                	je     801be7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c08:	99                   	cltd   
  801c09:	c1 ea 1b             	shr    $0x1b,%edx
  801c0c:	01 d0                	add    %edx,%eax
  801c0e:	83 e0 1f             	and    $0x1f,%eax
  801c11:	29 d0                	sub    %edx,%eax
  801c13:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c1e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c21:	83 c3 01             	add    $0x1,%ebx
  801c24:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c27:	75 d8                	jne    801c01 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c29:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2c:	eb 05                	jmp    801c33 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c2e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c36:	5b                   	pop    %ebx
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	56                   	push   %esi
  801c3f:	53                   	push   %ebx
  801c40:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c46:	50                   	push   %eax
  801c47:	e8 3c f6 ff ff       	call   801288 <fd_alloc>
  801c4c:	83 c4 10             	add    $0x10,%esp
  801c4f:	89 c2                	mov    %eax,%edx
  801c51:	85 c0                	test   %eax,%eax
  801c53:	0f 88 2c 01 00 00    	js     801d85 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c59:	83 ec 04             	sub    $0x4,%esp
  801c5c:	68 07 04 00 00       	push   $0x407
  801c61:	ff 75 f4             	pushl  -0xc(%ebp)
  801c64:	6a 00                	push   $0x0
  801c66:	e8 58 f0 ff ff       	call   800cc3 <sys_page_alloc>
  801c6b:	83 c4 10             	add    $0x10,%esp
  801c6e:	89 c2                	mov    %eax,%edx
  801c70:	85 c0                	test   %eax,%eax
  801c72:	0f 88 0d 01 00 00    	js     801d85 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c78:	83 ec 0c             	sub    $0xc,%esp
  801c7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	e8 04 f6 ff ff       	call   801288 <fd_alloc>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	0f 88 e2 00 00 00    	js     801d73 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c91:	83 ec 04             	sub    $0x4,%esp
  801c94:	68 07 04 00 00       	push   $0x407
  801c99:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9c:	6a 00                	push   $0x0
  801c9e:	e8 20 f0 ff ff       	call   800cc3 <sys_page_alloc>
  801ca3:	89 c3                	mov    %eax,%ebx
  801ca5:	83 c4 10             	add    $0x10,%esp
  801ca8:	85 c0                	test   %eax,%eax
  801caa:	0f 88 c3 00 00 00    	js     801d73 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb6:	e8 b6 f5 ff ff       	call   801271 <fd2data>
  801cbb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbd:	83 c4 0c             	add    $0xc,%esp
  801cc0:	68 07 04 00 00       	push   $0x407
  801cc5:	50                   	push   %eax
  801cc6:	6a 00                	push   $0x0
  801cc8:	e8 f6 ef ff ff       	call   800cc3 <sys_page_alloc>
  801ccd:	89 c3                	mov    %eax,%ebx
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	85 c0                	test   %eax,%eax
  801cd4:	0f 88 89 00 00 00    	js     801d63 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cda:	83 ec 0c             	sub    $0xc,%esp
  801cdd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce0:	e8 8c f5 ff ff       	call   801271 <fd2data>
  801ce5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cec:	50                   	push   %eax
  801ced:	6a 00                	push   $0x0
  801cef:	56                   	push   %esi
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 0f f0 ff ff       	call   800d06 <sys_page_map>
  801cf7:	89 c3                	mov    %eax,%ebx
  801cf9:	83 c4 20             	add    $0x20,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 55                	js     801d55 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d00:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d15:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d23:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d2a:	83 ec 0c             	sub    $0xc,%esp
  801d2d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d30:	e8 2c f5 ff ff       	call   801261 <fd2num>
  801d35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d38:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d3a:	83 c4 04             	add    $0x4,%esp
  801d3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d40:	e8 1c f5 ff ff       	call   801261 <fd2num>
  801d45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d48:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d53:	eb 30                	jmp    801d85 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d55:	83 ec 08             	sub    $0x8,%esp
  801d58:	56                   	push   %esi
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 e8 ef ff ff       	call   800d48 <sys_page_unmap>
  801d60:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d63:	83 ec 08             	sub    $0x8,%esp
  801d66:	ff 75 f0             	pushl  -0x10(%ebp)
  801d69:	6a 00                	push   $0x0
  801d6b:	e8 d8 ef ff ff       	call   800d48 <sys_page_unmap>
  801d70:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d73:	83 ec 08             	sub    $0x8,%esp
  801d76:	ff 75 f4             	pushl  -0xc(%ebp)
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 c8 ef ff ff       	call   800d48 <sys_page_unmap>
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d85:	89 d0                	mov    %edx,%eax
  801d87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d8a:	5b                   	pop    %ebx
  801d8b:	5e                   	pop    %esi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d97:	50                   	push   %eax
  801d98:	ff 75 08             	pushl  0x8(%ebp)
  801d9b:	e8 37 f5 ff ff       	call   8012d7 <fd_lookup>
  801da0:	83 c4 10             	add    $0x10,%esp
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 18                	js     801dbf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801da7:	83 ec 0c             	sub    $0xc,%esp
  801daa:	ff 75 f4             	pushl  -0xc(%ebp)
  801dad:	e8 bf f4 ff ff       	call   801271 <fd2data>
	return _pipeisclosed(fd, p);
  801db2:	89 c2                	mov    %eax,%edx
  801db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db7:	e8 21 fd ff ff       	call   801add <_pipeisclosed>
  801dbc:	83 c4 10             	add    $0x10,%esp
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801dc9:	85 f6                	test   %esi,%esi
  801dcb:	75 16                	jne    801de3 <wait+0x22>
  801dcd:	68 a2 2a 80 00       	push   $0x802aa2
  801dd2:	68 57 2a 80 00       	push   $0x802a57
  801dd7:	6a 09                	push   $0x9
  801dd9:	68 ad 2a 80 00       	push   $0x802aad
  801dde:	e8 35 e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801de3:	89 f3                	mov    %esi,%ebx
  801de5:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801deb:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801dee:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801df4:	eb 05                	jmp    801dfb <wait+0x3a>
		sys_yield();
  801df6:	e8 a9 ee ff ff       	call   800ca4 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dfb:	8b 43 48             	mov    0x48(%ebx),%eax
  801dfe:	39 c6                	cmp    %eax,%esi
  801e00:	75 07                	jne    801e09 <wait+0x48>
  801e02:	8b 43 54             	mov    0x54(%ebx),%eax
  801e05:	85 c0                	test   %eax,%eax
  801e07:	75 ed                	jne    801df6 <wait+0x35>
		sys_yield();
}
  801e09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
  801e18:	5d                   	pop    %ebp
  801e19:	c3                   	ret    

00801e1a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e20:	68 b8 2a 80 00       	push   $0x802ab8
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	e8 93 ea ff ff       	call   8008c0 <strcpy>
	return 0;
}
  801e2d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e32:	c9                   	leave  
  801e33:	c3                   	ret    

00801e34 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	57                   	push   %edi
  801e38:	56                   	push   %esi
  801e39:	53                   	push   %ebx
  801e3a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e40:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e45:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e4b:	eb 2d                	jmp    801e7a <devcons_write+0x46>
		m = n - tot;
  801e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e50:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e52:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e55:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e5a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e5d:	83 ec 04             	sub    $0x4,%esp
  801e60:	53                   	push   %ebx
  801e61:	03 45 0c             	add    0xc(%ebp),%eax
  801e64:	50                   	push   %eax
  801e65:	57                   	push   %edi
  801e66:	e8 e7 eb ff ff       	call   800a52 <memmove>
		sys_cputs(buf, m);
  801e6b:	83 c4 08             	add    $0x8,%esp
  801e6e:	53                   	push   %ebx
  801e6f:	57                   	push   %edi
  801e70:	e8 92 ed ff ff       	call   800c07 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e75:	01 de                	add    %ebx,%esi
  801e77:	83 c4 10             	add    $0x10,%esp
  801e7a:	89 f0                	mov    %esi,%eax
  801e7c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e7f:	72 cc                	jb     801e4d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e84:	5b                   	pop    %ebx
  801e85:	5e                   	pop    %esi
  801e86:	5f                   	pop    %edi
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	83 ec 08             	sub    $0x8,%esp
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e94:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e98:	74 2a                	je     801ec4 <devcons_read+0x3b>
  801e9a:	eb 05                	jmp    801ea1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e9c:	e8 03 ee ff ff       	call   800ca4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ea1:	e8 7f ed ff ff       	call   800c25 <sys_cgetc>
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	74 f2                	je     801e9c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 16                	js     801ec4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eae:	83 f8 04             	cmp    $0x4,%eax
  801eb1:	74 0c                	je     801ebf <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801eb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eb6:	88 02                	mov    %al,(%edx)
	return 1;
  801eb8:	b8 01 00 00 00       	mov    $0x1,%eax
  801ebd:	eb 05                	jmp    801ec4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ebf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ec4:	c9                   	leave  
  801ec5:	c3                   	ret    

00801ec6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ed2:	6a 01                	push   $0x1
  801ed4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ed7:	50                   	push   %eax
  801ed8:	e8 2a ed ff ff       	call   800c07 <sys_cputs>
}
  801edd:	83 c4 10             	add    $0x10,%esp
  801ee0:	c9                   	leave  
  801ee1:	c3                   	ret    

00801ee2 <getchar>:

int
getchar(void)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ee8:	6a 01                	push   $0x1
  801eea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eed:	50                   	push   %eax
  801eee:	6a 00                	push   $0x0
  801ef0:	e8 48 f6 ff ff       	call   80153d <read>
	if (r < 0)
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	78 0f                	js     801f0b <getchar+0x29>
		return r;
	if (r < 1)
  801efc:	85 c0                	test   %eax,%eax
  801efe:	7e 06                	jle    801f06 <getchar+0x24>
		return -E_EOF;
	return c;
  801f00:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f04:	eb 05                	jmp    801f0b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f06:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f0b:	c9                   	leave  
  801f0c:	c3                   	ret    

00801f0d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f16:	50                   	push   %eax
  801f17:	ff 75 08             	pushl  0x8(%ebp)
  801f1a:	e8 b8 f3 ff ff       	call   8012d7 <fd_lookup>
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 11                	js     801f37 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f2f:	39 10                	cmp    %edx,(%eax)
  801f31:	0f 94 c0             	sete   %al
  801f34:	0f b6 c0             	movzbl %al,%eax
}
  801f37:	c9                   	leave  
  801f38:	c3                   	ret    

00801f39 <opencons>:

int
opencons(void)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f42:	50                   	push   %eax
  801f43:	e8 40 f3 ff ff       	call   801288 <fd_alloc>
  801f48:	83 c4 10             	add    $0x10,%esp
		return r;
  801f4b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 3e                	js     801f8f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f51:	83 ec 04             	sub    $0x4,%esp
  801f54:	68 07 04 00 00       	push   $0x407
  801f59:	ff 75 f4             	pushl  -0xc(%ebp)
  801f5c:	6a 00                	push   $0x0
  801f5e:	e8 60 ed ff ff       	call   800cc3 <sys_page_alloc>
  801f63:	83 c4 10             	add    $0x10,%esp
		return r;
  801f66:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f68:	85 c0                	test   %eax,%eax
  801f6a:	78 23                	js     801f8f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f6c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f75:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f81:	83 ec 0c             	sub    $0xc,%esp
  801f84:	50                   	push   %eax
  801f85:	e8 d7 f2 ff ff       	call   801261 <fd2num>
  801f8a:	89 c2                	mov    %eax,%edx
  801f8c:	83 c4 10             	add    $0x10,%esp
}
  801f8f:	89 d0                	mov    %edx,%eax
  801f91:	c9                   	leave  
  801f92:	c3                   	ret    

00801f93 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801f99:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa0:	75 4c                	jne    801fee <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801fa2:	a1 20 44 80 00       	mov    0x804420,%eax
  801fa7:	8b 40 48             	mov    0x48(%eax),%eax
  801faa:	83 ec 04             	sub    $0x4,%esp
  801fad:	6a 07                	push   $0x7
  801faf:	68 00 f0 bf ee       	push   $0xeebff000
  801fb4:	50                   	push   %eax
  801fb5:	e8 09 ed ff ff       	call   800cc3 <sys_page_alloc>
		if(retv != 0){
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	74 14                	je     801fd5 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801fc1:	83 ec 04             	sub    $0x4,%esp
  801fc4:	68 c4 2a 80 00       	push   $0x802ac4
  801fc9:	6a 27                	push   $0x27
  801fcb:	68 f0 2a 80 00       	push   $0x802af0
  801fd0:	e8 43 e2 ff ff       	call   800218 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801fd5:	a1 20 44 80 00       	mov    0x804420,%eax
  801fda:	8b 40 48             	mov    0x48(%eax),%eax
  801fdd:	83 ec 08             	sub    $0x8,%esp
  801fe0:	68 f8 1f 80 00       	push   $0x801ff8
  801fe5:	50                   	push   %eax
  801fe6:	e8 23 ee ff ff       	call   800e0e <sys_env_set_pgfault_upcall>
  801feb:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801ff6:	c9                   	leave  
  801ff7:	c3                   	ret    

00801ff8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ff8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ff9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ffe:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  802000:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  802003:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  802007:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  80200c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  802010:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  802012:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  802015:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  802016:	83 c4 04             	add    $0x4,%esp
	popfl
  802019:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80201a:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80201b:	c3                   	ret    

0080201c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	56                   	push   %esi
  802020:	53                   	push   %ebx
  802021:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802024:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802027:	83 ec 0c             	sub    $0xc,%esp
  80202a:	ff 75 0c             	pushl  0xc(%ebp)
  80202d:	e8 41 ee ff ff       	call   800e73 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  802032:	83 c4 10             	add    $0x10,%esp
  802035:	85 f6                	test   %esi,%esi
  802037:	74 1c                	je     802055 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  802039:	a1 20 44 80 00       	mov    0x804420,%eax
  80203e:	8b 40 78             	mov    0x78(%eax),%eax
  802041:	89 06                	mov    %eax,(%esi)
  802043:	eb 10                	jmp    802055 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802045:	83 ec 0c             	sub    $0xc,%esp
  802048:	68 fe 2a 80 00       	push   $0x802afe
  80204d:	e8 9f e2 ff ff       	call   8002f1 <cprintf>
  802052:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802055:	a1 20 44 80 00       	mov    0x804420,%eax
  80205a:	8b 50 74             	mov    0x74(%eax),%edx
  80205d:	85 d2                	test   %edx,%edx
  80205f:	74 e4                	je     802045 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  802061:	85 db                	test   %ebx,%ebx
  802063:	74 05                	je     80206a <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802065:	8b 40 74             	mov    0x74(%eax),%eax
  802068:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80206a:	a1 20 44 80 00       	mov    0x804420,%eax
  80206f:	8b 40 70             	mov    0x70(%eax),%eax

}
  802072:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    

00802079 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	57                   	push   %edi
  80207d:	56                   	push   %esi
  80207e:	53                   	push   %ebx
  80207f:	83 ec 0c             	sub    $0xc,%esp
  802082:	8b 7d 08             	mov    0x8(%ebp),%edi
  802085:	8b 75 0c             	mov    0xc(%ebp),%esi
  802088:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  80208b:	85 db                	test   %ebx,%ebx
  80208d:	75 13                	jne    8020a2 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  80208f:	6a 00                	push   $0x0
  802091:	68 00 00 c0 ee       	push   $0xeec00000
  802096:	56                   	push   %esi
  802097:	57                   	push   %edi
  802098:	e8 b3 ed ff ff       	call   800e50 <sys_ipc_try_send>
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	eb 0e                	jmp    8020b0 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  8020a2:	ff 75 14             	pushl  0x14(%ebp)
  8020a5:	53                   	push   %ebx
  8020a6:	56                   	push   %esi
  8020a7:	57                   	push   %edi
  8020a8:	e8 a3 ed ff ff       	call   800e50 <sys_ipc_try_send>
  8020ad:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	75 d7                	jne    80208b <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8020b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    

008020bc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020bc:	55                   	push   %ebp
  8020bd:	89 e5                	mov    %esp,%ebp
  8020bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020d0:	8b 52 50             	mov    0x50(%edx),%edx
  8020d3:	39 ca                	cmp    %ecx,%edx
  8020d5:	75 0d                	jne    8020e4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020d7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020da:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020df:	8b 40 48             	mov    0x48(%eax),%eax
  8020e2:	eb 0f                	jmp    8020f3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020e4:	83 c0 01             	add    $0x1,%eax
  8020e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020ec:	75 d9                	jne    8020c7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    

008020f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	c1 e8 16             	shr    $0x16,%eax
  802100:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802107:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80210c:	f6 c1 01             	test   $0x1,%cl
  80210f:	74 1d                	je     80212e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802111:	c1 ea 0c             	shr    $0xc,%edx
  802114:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80211b:	f6 c2 01             	test   $0x1,%dl
  80211e:	74 0e                	je     80212e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802120:	c1 ea 0c             	shr    $0xc,%edx
  802123:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80212a:	ef 
  80212b:	0f b7 c0             	movzwl %ax,%eax
}
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <__udivdi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80213b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80213f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 f6                	test   %esi,%esi
  802149:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80214d:	89 ca                	mov    %ecx,%edx
  80214f:	89 f8                	mov    %edi,%eax
  802151:	75 3d                	jne    802190 <__udivdi3+0x60>
  802153:	39 cf                	cmp    %ecx,%edi
  802155:	0f 87 c5 00 00 00    	ja     802220 <__udivdi3+0xf0>
  80215b:	85 ff                	test   %edi,%edi
  80215d:	89 fd                	mov    %edi,%ebp
  80215f:	75 0b                	jne    80216c <__udivdi3+0x3c>
  802161:	b8 01 00 00 00       	mov    $0x1,%eax
  802166:	31 d2                	xor    %edx,%edx
  802168:	f7 f7                	div    %edi
  80216a:	89 c5                	mov    %eax,%ebp
  80216c:	89 c8                	mov    %ecx,%eax
  80216e:	31 d2                	xor    %edx,%edx
  802170:	f7 f5                	div    %ebp
  802172:	89 c1                	mov    %eax,%ecx
  802174:	89 d8                	mov    %ebx,%eax
  802176:	89 cf                	mov    %ecx,%edi
  802178:	f7 f5                	div    %ebp
  80217a:	89 c3                	mov    %eax,%ebx
  80217c:	89 d8                	mov    %ebx,%eax
  80217e:	89 fa                	mov    %edi,%edx
  802180:	83 c4 1c             	add    $0x1c,%esp
  802183:	5b                   	pop    %ebx
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
  802188:	90                   	nop
  802189:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802190:	39 ce                	cmp    %ecx,%esi
  802192:	77 74                	ja     802208 <__udivdi3+0xd8>
  802194:	0f bd fe             	bsr    %esi,%edi
  802197:	83 f7 1f             	xor    $0x1f,%edi
  80219a:	0f 84 98 00 00 00    	je     802238 <__udivdi3+0x108>
  8021a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	89 c5                	mov    %eax,%ebp
  8021a9:	29 fb                	sub    %edi,%ebx
  8021ab:	d3 e6                	shl    %cl,%esi
  8021ad:	89 d9                	mov    %ebx,%ecx
  8021af:	d3 ed                	shr    %cl,%ebp
  8021b1:	89 f9                	mov    %edi,%ecx
  8021b3:	d3 e0                	shl    %cl,%eax
  8021b5:	09 ee                	or     %ebp,%esi
  8021b7:	89 d9                	mov    %ebx,%ecx
  8021b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021bd:	89 d5                	mov    %edx,%ebp
  8021bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021c3:	d3 ed                	shr    %cl,%ebp
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e2                	shl    %cl,%edx
  8021c9:	89 d9                	mov    %ebx,%ecx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	09 c2                	or     %eax,%edx
  8021cf:	89 d0                	mov    %edx,%eax
  8021d1:	89 ea                	mov    %ebp,%edx
  8021d3:	f7 f6                	div    %esi
  8021d5:	89 d5                	mov    %edx,%ebp
  8021d7:	89 c3                	mov    %eax,%ebx
  8021d9:	f7 64 24 0c          	mull   0xc(%esp)
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	72 10                	jb     8021f1 <__udivdi3+0xc1>
  8021e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	d3 e6                	shl    %cl,%esi
  8021e9:	39 c6                	cmp    %eax,%esi
  8021eb:	73 07                	jae    8021f4 <__udivdi3+0xc4>
  8021ed:	39 d5                	cmp    %edx,%ebp
  8021ef:	75 03                	jne    8021f4 <__udivdi3+0xc4>
  8021f1:	83 eb 01             	sub    $0x1,%ebx
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 d8                	mov    %ebx,%eax
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	83 c4 1c             	add    $0x1c,%esp
  8021fd:	5b                   	pop    %ebx
  8021fe:	5e                   	pop    %esi
  8021ff:	5f                   	pop    %edi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    
  802202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802208:	31 ff                	xor    %edi,%edi
  80220a:	31 db                	xor    %ebx,%ebx
  80220c:	89 d8                	mov    %ebx,%eax
  80220e:	89 fa                	mov    %edi,%edx
  802210:	83 c4 1c             	add    $0x1c,%esp
  802213:	5b                   	pop    %ebx
  802214:	5e                   	pop    %esi
  802215:	5f                   	pop    %edi
  802216:	5d                   	pop    %ebp
  802217:	c3                   	ret    
  802218:	90                   	nop
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d8                	mov    %ebx,%eax
  802222:	f7 f7                	div    %edi
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 c3                	mov    %eax,%ebx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 fa                	mov    %edi,%edx
  80222c:	83 c4 1c             	add    $0x1c,%esp
  80222f:	5b                   	pop    %ebx
  802230:	5e                   	pop    %esi
  802231:	5f                   	pop    %edi
  802232:	5d                   	pop    %ebp
  802233:	c3                   	ret    
  802234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802238:	39 ce                	cmp    %ecx,%esi
  80223a:	72 0c                	jb     802248 <__udivdi3+0x118>
  80223c:	31 db                	xor    %ebx,%ebx
  80223e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802242:	0f 87 34 ff ff ff    	ja     80217c <__udivdi3+0x4c>
  802248:	bb 01 00 00 00       	mov    $0x1,%ebx
  80224d:	e9 2a ff ff ff       	jmp    80217c <__udivdi3+0x4c>
  802252:	66 90                	xchg   %ax,%ax
  802254:	66 90                	xchg   %ax,%ax
  802256:	66 90                	xchg   %ax,%ax
  802258:	66 90                	xchg   %ax,%ax
  80225a:	66 90                	xchg   %ax,%ax
  80225c:	66 90                	xchg   %ax,%ax
  80225e:	66 90                	xchg   %ax,%ax

00802260 <__umoddi3>:
  802260:	55                   	push   %ebp
  802261:	57                   	push   %edi
  802262:	56                   	push   %esi
  802263:	53                   	push   %ebx
  802264:	83 ec 1c             	sub    $0x1c,%esp
  802267:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80226b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80226f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802277:	85 d2                	test   %edx,%edx
  802279:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80227d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802281:	89 f3                	mov    %esi,%ebx
  802283:	89 3c 24             	mov    %edi,(%esp)
  802286:	89 74 24 04          	mov    %esi,0x4(%esp)
  80228a:	75 1c                	jne    8022a8 <__umoddi3+0x48>
  80228c:	39 f7                	cmp    %esi,%edi
  80228e:	76 50                	jbe    8022e0 <__umoddi3+0x80>
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	f7 f7                	div    %edi
  802296:	89 d0                	mov    %edx,%eax
  802298:	31 d2                	xor    %edx,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	89 d0                	mov    %edx,%eax
  8022ac:	77 52                	ja     802300 <__umoddi3+0xa0>
  8022ae:	0f bd ea             	bsr    %edx,%ebp
  8022b1:	83 f5 1f             	xor    $0x1f,%ebp
  8022b4:	75 5a                	jne    802310 <__umoddi3+0xb0>
  8022b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ba:	0f 82 e0 00 00 00    	jb     8023a0 <__umoddi3+0x140>
  8022c0:	39 0c 24             	cmp    %ecx,(%esp)
  8022c3:	0f 86 d7 00 00 00    	jbe    8023a0 <__umoddi3+0x140>
  8022c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022d1:	83 c4 1c             	add    $0x1c,%esp
  8022d4:	5b                   	pop    %ebx
  8022d5:	5e                   	pop    %esi
  8022d6:	5f                   	pop    %edi
  8022d7:	5d                   	pop    %ebp
  8022d8:	c3                   	ret    
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	85 ff                	test   %edi,%edi
  8022e2:	89 fd                	mov    %edi,%ebp
  8022e4:	75 0b                	jne    8022f1 <__umoddi3+0x91>
  8022e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f7                	div    %edi
  8022ef:	89 c5                	mov    %eax,%ebp
  8022f1:	89 f0                	mov    %esi,%eax
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	f7 f5                	div    %ebp
  8022f7:	89 c8                	mov    %ecx,%eax
  8022f9:	f7 f5                	div    %ebp
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	eb 99                	jmp    802298 <__umoddi3+0x38>
  8022ff:	90                   	nop
  802300:	89 c8                	mov    %ecx,%eax
  802302:	89 f2                	mov    %esi,%edx
  802304:	83 c4 1c             	add    $0x1c,%esp
  802307:	5b                   	pop    %ebx
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    
  80230c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802310:	8b 34 24             	mov    (%esp),%esi
  802313:	bf 20 00 00 00       	mov    $0x20,%edi
  802318:	89 e9                	mov    %ebp,%ecx
  80231a:	29 ef                	sub    %ebp,%edi
  80231c:	d3 e0                	shl    %cl,%eax
  80231e:	89 f9                	mov    %edi,%ecx
  802320:	89 f2                	mov    %esi,%edx
  802322:	d3 ea                	shr    %cl,%edx
  802324:	89 e9                	mov    %ebp,%ecx
  802326:	09 c2                	or     %eax,%edx
  802328:	89 d8                	mov    %ebx,%eax
  80232a:	89 14 24             	mov    %edx,(%esp)
  80232d:	89 f2                	mov    %esi,%edx
  80232f:	d3 e2                	shl    %cl,%edx
  802331:	89 f9                	mov    %edi,%ecx
  802333:	89 54 24 04          	mov    %edx,0x4(%esp)
  802337:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80233b:	d3 e8                	shr    %cl,%eax
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	89 c6                	mov    %eax,%esi
  802341:	d3 e3                	shl    %cl,%ebx
  802343:	89 f9                	mov    %edi,%ecx
  802345:	89 d0                	mov    %edx,%eax
  802347:	d3 e8                	shr    %cl,%eax
  802349:	89 e9                	mov    %ebp,%ecx
  80234b:	09 d8                	or     %ebx,%eax
  80234d:	89 d3                	mov    %edx,%ebx
  80234f:	89 f2                	mov    %esi,%edx
  802351:	f7 34 24             	divl   (%esp)
  802354:	89 d6                	mov    %edx,%esi
  802356:	d3 e3                	shl    %cl,%ebx
  802358:	f7 64 24 04          	mull   0x4(%esp)
  80235c:	39 d6                	cmp    %edx,%esi
  80235e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802362:	89 d1                	mov    %edx,%ecx
  802364:	89 c3                	mov    %eax,%ebx
  802366:	72 08                	jb     802370 <__umoddi3+0x110>
  802368:	75 11                	jne    80237b <__umoddi3+0x11b>
  80236a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80236e:	73 0b                	jae    80237b <__umoddi3+0x11b>
  802370:	2b 44 24 04          	sub    0x4(%esp),%eax
  802374:	1b 14 24             	sbb    (%esp),%edx
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 c3                	mov    %eax,%ebx
  80237b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80237f:	29 da                	sub    %ebx,%edx
  802381:	19 ce                	sbb    %ecx,%esi
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 f0                	mov    %esi,%eax
  802387:	d3 e0                	shl    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	d3 ea                	shr    %cl,%edx
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	d3 ee                	shr    %cl,%esi
  802391:	09 d0                	or     %edx,%eax
  802393:	89 f2                	mov    %esi,%edx
  802395:	83 c4 1c             	add    $0x1c,%esp
  802398:	5b                   	pop    %ebx
  802399:	5e                   	pop    %esi
  80239a:	5f                   	pop    %edi
  80239b:	5d                   	pop    %ebp
  80239c:	c3                   	ret    
  80239d:	8d 76 00             	lea    0x0(%esi),%esi
  8023a0:	29 f9                	sub    %edi,%ecx
  8023a2:	19 d6                	sbb    %edx,%esi
  8023a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ac:	e9 18 ff ff ff       	jmp    8022c9 <__umoddi3+0x69>
