
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 cc 00 00 00       	call   8000fd <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 20 1f 80 00       	push   $0x801f20
  800045:	e8 ec 01 00 00       	call   800236 <cprintf>
	cprintf("\t in handler:\n");
  80004a:	c7 04 24 2a 1f 80 00 	movl   $0x801f2a,(%esp)
  800051:	e8 e0 01 00 00       	call   800236 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	6a 07                	push   $0x7
  80005b:	89 d8                	mov    %ebx,%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	50                   	push   %eax
  800063:	6a 00                	push   $0x0
  800065:	e8 9e 0b 00 00       	call   800c08 <sys_page_alloc>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	85 c0                	test   %eax,%eax
  80006f:	79 16                	jns    800087 <handler+0x54>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800071:	83 ec 0c             	sub    $0xc,%esp
  800074:	50                   	push   %eax
  800075:	53                   	push   %ebx
  800076:	68 7c 1f 80 00       	push   $0x801f7c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 39 1f 80 00       	push   $0x801f39
  800082:	e8 d6 00 00 00       	call   80015d <_panic>
	cprintf("\t !!before snprintf.\n");
  800087:	83 ec 0c             	sub    $0xc,%esp
  80008a:	68 4b 1f 80 00       	push   $0x801f4b
  80008f:	e8 a2 01 00 00       	call   800236 <cprintf>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800094:	53                   	push   %ebx
  800095:	68 a8 1f 80 00       	push   $0x801fa8
  80009a:	6a 64                	push   $0x64
  80009c:	53                   	push   %ebx
  80009d:	e8 10 07 00 00       	call   8007b2 <snprintf>
	cprintf("%s\n",addr);
  8000a2:	83 c4 18             	add    $0x18,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	68 61 1f 80 00       	push   $0x801f61
  8000ab:	e8 86 01 00 00       	call   800236 <cprintf>
	cprintf("\t !!after snprintf.\n");
  8000b0:	c7 04 24 65 1f 80 00 	movl   $0x801f65,(%esp)
  8000b7:	e8 7a 01 00 00       	call   800236 <cprintf>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c2:	c9                   	leave  
  8000c3:	c3                   	ret    

008000c4 <umain>:

void
umain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  8000ca:	68 33 00 80 00       	push   $0x800033
  8000cf:	e8 25 0d 00 00       	call   800df9 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000d4:	83 c4 08             	add    $0x8,%esp
  8000d7:	68 ef be ad de       	push   $0xdeadbeef
  8000dc:	68 61 1f 80 00       	push   $0x801f61
  8000e1:	e8 50 01 00 00       	call   800236 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000e6:	83 c4 08             	add    $0x8,%esp
  8000e9:	68 fe bf fe ca       	push   $0xcafebffe
  8000ee:	68 61 1f 80 00       	push   $0x801f61
  8000f3:	e8 3e 01 00 00       	call   800236 <cprintf>
}
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800105:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800108:	e8 bd 0a 00 00       	call   800bca <sys_getenvid>
  80010d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800112:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800115:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011a:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011f:	85 db                	test   %ebx,%ebx
  800121:	7e 07                	jle    80012a <libmain+0x2d>
		binaryname = argv[0];
  800123:	8b 06                	mov    (%esi),%eax
  800125:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
  80012f:	e8 90 ff ff ff       	call   8000c4 <umain>

	// exit gracefully
	exit();
  800134:	e8 0a 00 00 00       	call   800143 <exit>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800149:	e8 ff 0e 00 00       	call   80104d <close_all>
	sys_env_destroy(0);
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	6a 00                	push   $0x0
  800153:	e8 31 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800162:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800165:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80016b:	e8 5a 0a 00 00       	call   800bca <sys_getenvid>
  800170:	83 ec 0c             	sub    $0xc,%esp
  800173:	ff 75 0c             	pushl  0xc(%ebp)
  800176:	ff 75 08             	pushl  0x8(%ebp)
  800179:	56                   	push   %esi
  80017a:	50                   	push   %eax
  80017b:	68 d4 1f 80 00       	push   $0x801fd4
  800180:	e8 b1 00 00 00       	call   800236 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800185:	83 c4 18             	add    $0x18,%esp
  800188:	53                   	push   %ebx
  800189:	ff 75 10             	pushl  0x10(%ebp)
  80018c:	e8 54 00 00 00       	call   8001e5 <vcprintf>
	cprintf("\n");
  800191:	c7 04 24 5f 1f 80 00 	movl   $0x801f5f,(%esp)
  800198:	e8 99 00 00 00       	call   800236 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a0:	cc                   	int3   
  8001a1:	eb fd                	jmp    8001a0 <_panic+0x43>

008001a3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 04             	sub    $0x4,%esp
  8001aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ad:	8b 13                	mov    (%ebx),%edx
  8001af:	8d 42 01             	lea    0x1(%edx),%eax
  8001b2:	89 03                	mov    %eax,(%ebx)
  8001b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001bb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c0:	75 1a                	jne    8001dc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c2:	83 ec 08             	sub    $0x8,%esp
  8001c5:	68 ff 00 00 00       	push   $0xff
  8001ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 79 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  8001d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001dc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f5:	00 00 00 
	b.cnt = 0;
  8001f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800202:	ff 75 0c             	pushl  0xc(%ebp)
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	68 a3 01 80 00       	push   $0x8001a3
  800214:	e8 54 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800219:	83 c4 08             	add    $0x8,%esp
  80021c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800222:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800228:	50                   	push   %eax
  800229:	e8 1e 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  80022e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023f:	50                   	push   %eax
  800240:	ff 75 08             	pushl  0x8(%ebp)
  800243:	e8 9d ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 1c             	sub    $0x1c,%esp
  800253:	89 c7                	mov    %eax,%edi
  800255:	89 d6                	mov    %edx,%esi
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800260:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800263:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800271:	39 d3                	cmp    %edx,%ebx
  800273:	72 05                	jb     80027a <printnum+0x30>
  800275:	39 45 10             	cmp    %eax,0x10(%ebp)
  800278:	77 45                	ja     8002bf <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	ff 75 18             	pushl  0x18(%ebp)
  800280:	8b 45 14             	mov    0x14(%ebp),%eax
  800283:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800286:	53                   	push   %ebx
  800287:	ff 75 10             	pushl  0x10(%ebp)
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	ff 75 dc             	pushl  -0x24(%ebp)
  800296:	ff 75 d8             	pushl  -0x28(%ebp)
  800299:	e8 e2 19 00 00       	call   801c80 <__udivdi3>
  80029e:	83 c4 18             	add    $0x18,%esp
  8002a1:	52                   	push   %edx
  8002a2:	50                   	push   %eax
  8002a3:	89 f2                	mov    %esi,%edx
  8002a5:	89 f8                	mov    %edi,%eax
  8002a7:	e8 9e ff ff ff       	call   80024a <printnum>
  8002ac:	83 c4 20             	add    $0x20,%esp
  8002af:	eb 18                	jmp    8002c9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	ff 75 18             	pushl  0x18(%ebp)
  8002b8:	ff d7                	call   *%edi
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	eb 03                	jmp    8002c2 <printnum+0x78>
  8002bf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c2:	83 eb 01             	sub    $0x1,%ebx
  8002c5:	85 db                	test   %ebx,%ebx
  8002c7:	7f e8                	jg     8002b1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	56                   	push   %esi
  8002cd:	83 ec 04             	sub    $0x4,%esp
  8002d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002dc:	e8 cf 1a 00 00       	call   801db0 <__umoddi3>
  8002e1:	83 c4 14             	add    $0x14,%esp
  8002e4:	0f be 80 f7 1f 80 00 	movsbl 0x801ff7(%eax),%eax
  8002eb:	50                   	push   %eax
  8002ec:	ff d7                	call   *%edi
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fc:	83 fa 01             	cmp    $0x1,%edx
  8002ff:	7e 0e                	jle    80030f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 08             	lea    0x8(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	8b 52 04             	mov    0x4(%edx),%edx
  80030d:	eb 22                	jmp    800331 <getuint+0x38>
	else if (lflag)
  80030f:	85 d2                	test   %edx,%edx
  800311:	74 10                	je     800323 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 04             	lea    0x4(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	ba 00 00 00 00       	mov    $0x0,%edx
  800321:	eb 0e                	jmp    800331 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800323:	8b 10                	mov    (%eax),%edx
  800325:	8d 4a 04             	lea    0x4(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 02                	mov    (%edx),%eax
  80032c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800339:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	3b 50 04             	cmp    0x4(%eax),%edx
  800342:	73 0a                	jae    80034e <sprintputch+0x1b>
		*b->buf++ = ch;
  800344:	8d 4a 01             	lea    0x1(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	88 02                	mov    %al,(%edx)
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800356:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800359:	50                   	push   %eax
  80035a:	ff 75 10             	pushl  0x10(%ebp)
  80035d:	ff 75 0c             	pushl  0xc(%ebp)
  800360:	ff 75 08             	pushl  0x8(%ebp)
  800363:	e8 05 00 00 00       	call   80036d <vprintfmt>
	va_end(ap);
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 2c             	sub    $0x2c,%esp
  800376:	8b 75 08             	mov    0x8(%ebp),%esi
  800379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037f:	eb 12                	jmp    800393 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800381:	85 c0                	test   %eax,%eax
  800383:	0f 84 d3 03 00 00    	je     80075c <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	53                   	push   %ebx
  80038d:	50                   	push   %eax
  80038e:	ff d6                	call   *%esi
  800390:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800393:	83 c7 01             	add    $0x1,%edi
  800396:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039a:	83 f8 25             	cmp    $0x25,%eax
  80039d:	75 e2                	jne    800381 <vprintfmt+0x14>
  80039f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003aa:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003b1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bd:	eb 07                	jmp    8003c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8d 47 01             	lea    0x1(%edi),%eax
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	0f b6 07             	movzbl (%edi),%eax
  8003cf:	0f b6 c8             	movzbl %al,%ecx
  8003d2:	83 e8 23             	sub    $0x23,%eax
  8003d5:	3c 55                	cmp    $0x55,%al
  8003d7:	0f 87 64 03 00 00    	ja     800741 <vprintfmt+0x3d4>
  8003dd:	0f b6 c0             	movzbl %al,%eax
  8003e0:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ea:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ee:	eb d6                	jmp    8003c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800402:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800405:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800408:	83 fa 09             	cmp    $0x9,%edx
  80040b:	77 39                	ja     800446 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800410:	eb e9                	jmp    8003fb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 48 04             	lea    0x4(%eax),%ecx
  800418:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800423:	eb 27                	jmp    80044c <vprintfmt+0xdf>
  800425:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800428:	85 c0                	test   %eax,%eax
  80042a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042f:	0f 49 c8             	cmovns %eax,%ecx
  800432:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800438:	eb 8c                	jmp    8003c6 <vprintfmt+0x59>
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800444:	eb 80                	jmp    8003c6 <vprintfmt+0x59>
  800446:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800449:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80044c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800450:	0f 89 70 ff ff ff    	jns    8003c6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800456:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800459:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800463:	e9 5e ff ff ff       	jmp    8003c6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800468:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046e:	e9 53 ff ff ff       	jmp    8003c6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 50 04             	lea    0x4(%eax),%edx
  800479:	89 55 14             	mov    %edx,0x14(%ebp)
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 30                	pushl  (%eax)
  800482:	ff d6                	call   *%esi
			break;
  800484:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048a:	e9 04 ff ff ff       	jmp    800393 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	99                   	cltd   
  80049b:	31 d0                	xor    %edx,%eax
  80049d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049f:	83 f8 0f             	cmp    $0xf,%eax
  8004a2:	7f 0b                	jg     8004af <vprintfmt+0x142>
  8004a4:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	75 18                	jne    8004c7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004af:	50                   	push   %eax
  8004b0:	68 0f 20 80 00       	push   $0x80200f
  8004b5:	53                   	push   %ebx
  8004b6:	56                   	push   %esi
  8004b7:	e8 94 fe ff ff       	call   800350 <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c2:	e9 cc fe ff ff       	jmp    800393 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c7:	52                   	push   %edx
  8004c8:	68 11 24 80 00       	push   $0x802411
  8004cd:	53                   	push   %ebx
  8004ce:	56                   	push   %esi
  8004cf:	e8 7c fe ff ff       	call   800350 <printfmt>
  8004d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	e9 b4 fe ff ff       	jmp    800393 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	b8 08 20 80 00       	mov    $0x802008,%eax
  8004f1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f8:	0f 8e 94 00 00 00    	jle    800592 <vprintfmt+0x225>
  8004fe:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800502:	0f 84 98 00 00 00    	je     8005a0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	ff 75 c8             	pushl  -0x38(%ebp)
  80050e:	57                   	push   %edi
  80050f:	e8 d0 02 00 00       	call   8007e4 <strnlen>
  800514:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800517:	29 c1                	sub    %eax,%ecx
  800519:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80051c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800523:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800526:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800529:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	eb 0f                	jmp    80053c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	ff 75 e0             	pushl  -0x20(%ebp)
  800534:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800536:	83 ef 01             	sub    $0x1,%edi
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f ed                	jg     80052d <vprintfmt+0x1c0>
  800540:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800543:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800546:	85 c9                	test   %ecx,%ecx
  800548:	b8 00 00 00 00       	mov    $0x0,%eax
  80054d:	0f 49 c1             	cmovns %ecx,%eax
  800550:	29 c1                	sub    %eax,%ecx
  800552:	89 75 08             	mov    %esi,0x8(%ebp)
  800555:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800558:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055b:	89 cb                	mov    %ecx,%ebx
  80055d:	eb 4d                	jmp    8005ac <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800563:	74 1b                	je     800580 <vprintfmt+0x213>
  800565:	0f be c0             	movsbl %al,%eax
  800568:	83 e8 20             	sub    $0x20,%eax
  80056b:	83 f8 5e             	cmp    $0x5e,%eax
  80056e:	76 10                	jbe    800580 <vprintfmt+0x213>
					putch('?', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	ff 75 0c             	pushl  0xc(%ebp)
  800576:	6a 3f                	push   $0x3f
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
  80057e:	eb 0d                	jmp    80058d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	ff 75 0c             	pushl  0xc(%ebp)
  800586:	52                   	push   %edx
  800587:	ff 55 08             	call   *0x8(%ebp)
  80058a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058d:	83 eb 01             	sub    $0x1,%ebx
  800590:	eb 1a                	jmp    8005ac <vprintfmt+0x23f>
  800592:	89 75 08             	mov    %esi,0x8(%ebp)
  800595:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800598:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059e:	eb 0c                	jmp    8005ac <vprintfmt+0x23f>
  8005a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ac:	83 c7 01             	add    $0x1,%edi
  8005af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b3:	0f be d0             	movsbl %al,%edx
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	74 23                	je     8005dd <vprintfmt+0x270>
  8005ba:	85 f6                	test   %esi,%esi
  8005bc:	78 a1                	js     80055f <vprintfmt+0x1f2>
  8005be:	83 ee 01             	sub    $0x1,%esi
  8005c1:	79 9c                	jns    80055f <vprintfmt+0x1f2>
  8005c3:	89 df                	mov    %ebx,%edi
  8005c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cb:	eb 18                	jmp    8005e5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	53                   	push   %ebx
  8005d1:	6a 20                	push   $0x20
  8005d3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d5:	83 ef 01             	sub    $0x1,%edi
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	eb 08                	jmp    8005e5 <vprintfmt+0x278>
  8005dd:	89 df                	mov    %ebx,%edi
  8005df:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	7f e4                	jg     8005cd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ec:	e9 a2 fd ff ff       	jmp    800393 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f1:	83 fa 01             	cmp    $0x1,%edx
  8005f4:	7e 16                	jle    80060c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 50 08             	lea    0x8(%eax),%edx
  8005fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ff:	8b 50 04             	mov    0x4(%eax),%edx
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800607:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80060a:	eb 32                	jmp    80063e <vprintfmt+0x2d1>
	else if (lflag)
  80060c:	85 d2                	test   %edx,%edx
  80060e:	74 18                	je     800628 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80061e:	89 c1                	mov    %eax,%ecx
  800620:	c1 f9 1f             	sar    $0x1f,%ecx
  800623:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800626:	eb 16                	jmp    80063e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 50 04             	lea    0x4(%eax),%edx
  80062e:	89 55 14             	mov    %edx,0x14(%ebp)
  800631:	8b 00                	mov    (%eax),%eax
  800633:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800636:	89 c1                	mov    %eax,%ecx
  800638:	c1 f9 1f             	sar    $0x1f,%ecx
  80063b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800641:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800653:	0f 89 b0 00 00 00    	jns    800709 <vprintfmt+0x39c>
				putch('-', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 2d                	push   $0x2d
  80065f:	ff d6                	call   *%esi
				num = -(long long) num;
  800661:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800664:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800667:	f7 d8                	neg    %eax
  800669:	83 d2 00             	adc    $0x0,%edx
  80066c:	f7 da                	neg    %edx
  80066e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800671:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800674:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067c:	e9 88 00 00 00       	jmp    800709 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
  800684:	e8 70 fc ff ff       	call   8002f9 <getuint>
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80068f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800694:	eb 73                	jmp    800709 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 5b fc ff ff       	call   8002f9 <getuint>
  80069e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 58                	push   $0x58
  8006aa:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 58                	push   $0x58
  8006b2:	ff d6                	call   *%esi
			putch('X', putdat);
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 58                	push   $0x58
  8006ba:	ff d6                	call   *%esi
			goto number;
  8006bc:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006bf:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006c4:	eb 43                	jmp    800709 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 30                	push   $0x30
  8006cc:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ce:	83 c4 08             	add    $0x8,%esp
  8006d1:	53                   	push   %ebx
  8006d2:	6a 78                	push   $0x78
  8006d4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f4:	eb 13                	jmp    800709 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 fb fb ff ff       	call   8002f9 <getuint>
  8006fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800701:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800704:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800710:	52                   	push   %edx
  800711:	ff 75 e0             	pushl  -0x20(%ebp)
  800714:	50                   	push   %eax
  800715:	ff 75 dc             	pushl  -0x24(%ebp)
  800718:	ff 75 d8             	pushl  -0x28(%ebp)
  80071b:	89 da                	mov    %ebx,%edx
  80071d:	89 f0                	mov    %esi,%eax
  80071f:	e8 26 fb ff ff       	call   80024a <printnum>
			break;
  800724:	83 c4 20             	add    $0x20,%esp
  800727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072a:	e9 64 fc ff ff       	jmp    800393 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	51                   	push   %ecx
  800734:	ff d6                	call   *%esi
			break;
  800736:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073c:	e9 52 fc ff ff       	jmp    800393 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 25                	push   $0x25
  800747:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 03                	jmp    800751 <vprintfmt+0x3e4>
  80074e:	83 ef 01             	sub    $0x1,%edi
  800751:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800755:	75 f7                	jne    80074e <vprintfmt+0x3e1>
  800757:	e9 37 fc ff ff       	jmp    800393 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80075f:	5b                   	pop    %ebx
  800760:	5e                   	pop    %esi
  800761:	5f                   	pop    %edi
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 18             	sub    $0x18,%esp
  80076a:	8b 45 08             	mov    0x8(%ebp),%eax
  80076d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800770:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800773:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800777:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800781:	85 c0                	test   %eax,%eax
  800783:	74 26                	je     8007ab <vsnprintf+0x47>
  800785:	85 d2                	test   %edx,%edx
  800787:	7e 22                	jle    8007ab <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800789:	ff 75 14             	pushl  0x14(%ebp)
  80078c:	ff 75 10             	pushl  0x10(%ebp)
  80078f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	68 33 03 80 00       	push   $0x800333
  800798:	e8 d0 fb ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a6:	83 c4 10             	add    $0x10,%esp
  8007a9:	eb 05                	jmp    8007b0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bb:	50                   	push   %eax
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	ff 75 08             	pushl  0x8(%ebp)
  8007c5:	e8 9a ff ff ff       	call   800764 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    

008007cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d7:	eb 03                	jmp    8007dc <strlen+0x10>
		n++;
  8007d9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007dc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e0:	75 f7                	jne    8007d9 <strlen+0xd>
		n++;
	return n;
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f2:	eb 03                	jmp    8007f7 <strnlen+0x13>
		n++;
  8007f4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	39 c2                	cmp    %eax,%edx
  8007f9:	74 08                	je     800803 <strnlen+0x1f>
  8007fb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ff:	75 f3                	jne    8007f4 <strnlen+0x10>
  800801:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080f:	89 c2                	mov    %eax,%edx
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	83 c1 01             	add    $0x1,%ecx
  800817:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081e:	84 db                	test   %bl,%bl
  800820:	75 ef                	jne    800811 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800822:	5b                   	pop    %ebx
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082c:	53                   	push   %ebx
  80082d:	e8 9a ff ff ff       	call   8007cc <strlen>
  800832:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800835:	ff 75 0c             	pushl  0xc(%ebp)
  800838:	01 d8                	add    %ebx,%eax
  80083a:	50                   	push   %eax
  80083b:	e8 c5 ff ff ff       	call   800805 <strcpy>
	return dst;
}
  800840:	89 d8                	mov    %ebx,%eax
  800842:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800845:	c9                   	leave  
  800846:	c3                   	ret    

00800847 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	89 f3                	mov    %esi,%ebx
  800854:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	89 f2                	mov    %esi,%edx
  800859:	eb 0f                	jmp    80086a <strncpy+0x23>
		*dst++ = *src;
  80085b:	83 c2 01             	add    $0x1,%edx
  80085e:	0f b6 01             	movzbl (%ecx),%eax
  800861:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800864:	80 39 01             	cmpb   $0x1,(%ecx)
  800867:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086a:	39 da                	cmp    %ebx,%edx
  80086c:	75 ed                	jne    80085b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086e:	89 f0                	mov    %esi,%eax
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 75 08             	mov    0x8(%ebp),%esi
  80087c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087f:	8b 55 10             	mov    0x10(%ebp),%edx
  800882:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	85 d2                	test   %edx,%edx
  800886:	74 21                	je     8008a9 <strlcpy+0x35>
  800888:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088c:	89 f2                	mov    %esi,%edx
  80088e:	eb 09                	jmp    800899 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	83 c1 01             	add    $0x1,%ecx
  800896:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800899:	39 c2                	cmp    %eax,%edx
  80089b:	74 09                	je     8008a6 <strlcpy+0x32>
  80089d:	0f b6 19             	movzbl (%ecx),%ebx
  8008a0:	84 db                	test   %bl,%bl
  8008a2:	75 ec                	jne    800890 <strlcpy+0x1c>
  8008a4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a9:	29 f0                	sub    %esi,%eax
}
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b8:	eb 06                	jmp    8008c0 <strcmp+0x11>
		p++, q++;
  8008ba:	83 c1 01             	add    $0x1,%ecx
  8008bd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c0:	0f b6 01             	movzbl (%ecx),%eax
  8008c3:	84 c0                	test   %al,%al
  8008c5:	74 04                	je     8008cb <strcmp+0x1c>
  8008c7:	3a 02                	cmp    (%edx),%al
  8008c9:	74 ef                	je     8008ba <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cb:	0f b6 c0             	movzbl %al,%eax
  8008ce:	0f b6 12             	movzbl (%edx),%edx
  8008d1:	29 d0                	sub    %edx,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e4:	eb 06                	jmp    8008ec <strncmp+0x17>
		n--, p++, q++;
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ec:	39 d8                	cmp    %ebx,%eax
  8008ee:	74 15                	je     800905 <strncmp+0x30>
  8008f0:	0f b6 08             	movzbl (%eax),%ecx
  8008f3:	84 c9                	test   %cl,%cl
  8008f5:	74 04                	je     8008fb <strncmp+0x26>
  8008f7:	3a 0a                	cmp    (%edx),%cl
  8008f9:	74 eb                	je     8008e6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 00             	movzbl (%eax),%eax
  8008fe:	0f b6 12             	movzbl (%edx),%edx
  800901:	29 d0                	sub    %edx,%eax
  800903:	eb 05                	jmp    80090a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090a:	5b                   	pop    %ebx
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800917:	eb 07                	jmp    800920 <strchr+0x13>
		if (*s == c)
  800919:	38 ca                	cmp    %cl,%dl
  80091b:	74 0f                	je     80092c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	0f b6 10             	movzbl (%eax),%edx
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f2                	jne    800919 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800938:	eb 03                	jmp    80093d <strfind+0xf>
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800940:	38 ca                	cmp    %cl,%dl
  800942:	74 04                	je     800948 <strfind+0x1a>
  800944:	84 d2                	test   %dl,%dl
  800946:	75 f2                	jne    80093a <strfind+0xc>
			break;
	return (char *) s;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	8b 7d 08             	mov    0x8(%ebp),%edi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800956:	85 c9                	test   %ecx,%ecx
  800958:	74 36                	je     800990 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800960:	75 28                	jne    80098a <memset+0x40>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 23                	jne    80098a <memset+0x40>
		c &= 0xFF;
  800967:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096b:	89 d3                	mov    %edx,%ebx
  80096d:	c1 e3 08             	shl    $0x8,%ebx
  800970:	89 d6                	mov    %edx,%esi
  800972:	c1 e6 18             	shl    $0x18,%esi
  800975:	89 d0                	mov    %edx,%eax
  800977:	c1 e0 10             	shl    $0x10,%eax
  80097a:	09 f0                	or     %esi,%eax
  80097c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80097e:	89 d8                	mov    %ebx,%eax
  800980:	09 d0                	or     %edx,%eax
  800982:	c1 e9 02             	shr    $0x2,%ecx
  800985:	fc                   	cld    
  800986:	f3 ab                	rep stos %eax,%es:(%edi)
  800988:	eb 06                	jmp    800990 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098d:	fc                   	cld    
  80098e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800990:	89 f8                	mov    %edi,%eax
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a5:	39 c6                	cmp    %eax,%esi
  8009a7:	73 35                	jae    8009de <memmove+0x47>
  8009a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ac:	39 d0                	cmp    %edx,%eax
  8009ae:	73 2e                	jae    8009de <memmove+0x47>
		s += n;
		d += n;
  8009b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	89 d6                	mov    %edx,%esi
  8009b5:	09 fe                	or     %edi,%esi
  8009b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bd:	75 13                	jne    8009d2 <memmove+0x3b>
  8009bf:	f6 c1 03             	test   $0x3,%cl
  8009c2:	75 0e                	jne    8009d2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c4:	83 ef 04             	sub    $0x4,%edi
  8009c7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ca:	c1 e9 02             	shr    $0x2,%ecx
  8009cd:	fd                   	std    
  8009ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d0:	eb 09                	jmp    8009db <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d2:	83 ef 01             	sub    $0x1,%edi
  8009d5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d8:	fd                   	std    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009db:	fc                   	cld    
  8009dc:	eb 1d                	jmp    8009fb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009de:	89 f2                	mov    %esi,%edx
  8009e0:	09 c2                	or     %eax,%edx
  8009e2:	f6 c2 03             	test   $0x3,%dl
  8009e5:	75 0f                	jne    8009f6 <memmove+0x5f>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 0a                	jne    8009f6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
  8009ef:	89 c7                	mov    %eax,%edi
  8009f1:	fc                   	cld    
  8009f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f4:	eb 05                	jmp    8009fb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fb:	5e                   	pop    %esi
  8009fc:	5f                   	pop    %edi
  8009fd:	5d                   	pop    %ebp
  8009fe:	c3                   	ret    

008009ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a02:	ff 75 10             	pushl  0x10(%ebp)
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	ff 75 08             	pushl  0x8(%ebp)
  800a0b:	e8 87 ff ff ff       	call   800997 <memmove>
}
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	56                   	push   %esi
  800a16:	53                   	push   %ebx
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1d:	89 c6                	mov    %eax,%esi
  800a1f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	eb 1a                	jmp    800a3e <memcmp+0x2c>
		if (*s1 != *s2)
  800a24:	0f b6 08             	movzbl (%eax),%ecx
  800a27:	0f b6 1a             	movzbl (%edx),%ebx
  800a2a:	38 d9                	cmp    %bl,%cl
  800a2c:	74 0a                	je     800a38 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a2e:	0f b6 c1             	movzbl %cl,%eax
  800a31:	0f b6 db             	movzbl %bl,%ebx
  800a34:	29 d8                	sub    %ebx,%eax
  800a36:	eb 0f                	jmp    800a47 <memcmp+0x35>
		s1++, s2++;
  800a38:	83 c0 01             	add    $0x1,%eax
  800a3b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	75 e2                	jne    800a24 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	53                   	push   %ebx
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a52:	89 c1                	mov    %eax,%ecx
  800a54:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a57:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5b:	eb 0a                	jmp    800a67 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	39 da                	cmp    %ebx,%edx
  800a62:	74 07                	je     800a6b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a64:	83 c0 01             	add    $0x1,%eax
  800a67:	39 c8                	cmp    %ecx,%eax
  800a69:	72 f2                	jb     800a5d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6b:	5b                   	pop    %ebx
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	53                   	push   %ebx
  800a74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7a:	eb 03                	jmp    800a7f <strtol+0x11>
		s++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7f:	0f b6 01             	movzbl (%ecx),%eax
  800a82:	3c 20                	cmp    $0x20,%al
  800a84:	74 f6                	je     800a7c <strtol+0xe>
  800a86:	3c 09                	cmp    $0x9,%al
  800a88:	74 f2                	je     800a7c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8a:	3c 2b                	cmp    $0x2b,%al
  800a8c:	75 0a                	jne    800a98 <strtol+0x2a>
		s++;
  800a8e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
  800a96:	eb 11                	jmp    800aa9 <strtol+0x3b>
  800a98:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9d:	3c 2d                	cmp    $0x2d,%al
  800a9f:	75 08                	jne    800aa9 <strtol+0x3b>
		s++, neg = 1;
  800aa1:	83 c1 01             	add    $0x1,%ecx
  800aa4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aaf:	75 15                	jne    800ac6 <strtol+0x58>
  800ab1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab4:	75 10                	jne    800ac6 <strtol+0x58>
  800ab6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aba:	75 7c                	jne    800b38 <strtol+0xca>
		s += 2, base = 16;
  800abc:	83 c1 02             	add    $0x2,%ecx
  800abf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac4:	eb 16                	jmp    800adc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac6:	85 db                	test   %ebx,%ebx
  800ac8:	75 12                	jne    800adc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aca:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad2:	75 08                	jne    800adc <strtol+0x6e>
		s++, base = 8;
  800ad4:	83 c1 01             	add    $0x1,%ecx
  800ad7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800adc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae4:	0f b6 11             	movzbl (%ecx),%edx
  800ae7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 09             	cmp    $0x9,%bl
  800aef:	77 08                	ja     800af9 <strtol+0x8b>
			dig = *s - '0';
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 30             	sub    $0x30,%edx
  800af7:	eb 22                	jmp    800b1b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 08                	ja     800b0b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b03:	0f be d2             	movsbl %dl,%edx
  800b06:	83 ea 57             	sub    $0x57,%edx
  800b09:	eb 10                	jmp    800b1b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	80 fb 19             	cmp    $0x19,%bl
  800b13:	77 16                	ja     800b2b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b15:	0f be d2             	movsbl %dl,%edx
  800b18:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b1e:	7d 0b                	jge    800b2b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b20:	83 c1 01             	add    $0x1,%ecx
  800b23:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b27:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b29:	eb b9                	jmp    800ae4 <strtol+0x76>

	if (endptr)
  800b2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2f:	74 0d                	je     800b3e <strtol+0xd0>
		*endptr = (char *) s;
  800b31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b34:	89 0e                	mov    %ecx,(%esi)
  800b36:	eb 06                	jmp    800b3e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b38:	85 db                	test   %ebx,%ebx
  800b3a:	74 98                	je     800ad4 <strtol+0x66>
  800b3c:	eb 9e                	jmp    800adc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b3e:	89 c2                	mov    %eax,%edx
  800b40:	f7 da                	neg    %edx
  800b42:	85 ff                	test   %edi,%edi
  800b44:	0f 45 c2             	cmovne %edx,%eax
}
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5d:	89 c3                	mov    %eax,%ebx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	89 c6                	mov    %eax,%esi
  800b63:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7e 17                	jle    800bc2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	50                   	push   %eax
  800baf:	6a 03                	push   $0x3
  800bb1:	68 ff 22 80 00       	push   $0x8022ff
  800bb6:	6a 23                	push   $0x23
  800bb8:	68 1c 23 80 00       	push   $0x80231c
  800bbd:	e8 9b f5 ff ff       	call   80015d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bda:	89 d1                	mov    %edx,%ecx
  800bdc:	89 d3                	mov    %edx,%ebx
  800bde:	89 d7                	mov    %edx,%edi
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_yield>:

void
sys_yield(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf9:	89 d1                	mov    %edx,%ecx
  800bfb:	89 d3                	mov    %edx,%ebx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c11:	be 00 00 00 00       	mov    $0x0,%esi
  800c16:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c24:	89 f7                	mov    %esi,%edi
  800c26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7e 17                	jle    800c43 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 04                	push   $0x4
  800c32:	68 ff 22 80 00       	push   $0x8022ff
  800c37:	6a 23                	push   $0x23
  800c39:	68 1c 23 80 00       	push   $0x80231c
  800c3e:	e8 1a f5 ff ff       	call   80015d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c54:	b8 05 00 00 00       	mov    $0x5,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c65:	8b 75 18             	mov    0x18(%ebp),%esi
  800c68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7e 17                	jle    800c85 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 05                	push   $0x5
  800c74:	68 ff 22 80 00       	push   $0x8022ff
  800c79:	6a 23                	push   $0x23
  800c7b:	68 1c 23 80 00       	push   $0x80231c
  800c80:	e8 d8 f4 ff ff       	call   80015d <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7e 17                	jle    800cc7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 06                	push   $0x6
  800cb6:	68 ff 22 80 00       	push   $0x8022ff
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 1c 23 80 00       	push   $0x80231c
  800cc2:	e8 96 f4 ff ff       	call   80015d <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cca:	5b                   	pop    %ebx
  800ccb:	5e                   	pop    %esi
  800ccc:	5f                   	pop    %edi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 17                	jle    800d09 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 08                	push   $0x8
  800cf8:	68 ff 22 80 00       	push   $0x8022ff
  800cfd:	6a 23                	push   $0x23
  800cff:	68 1c 23 80 00       	push   $0x80231c
  800d04:	e8 54 f4 ff ff       	call   80015d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7e 17                	jle    800d4b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 09                	push   $0x9
  800d3a:	68 ff 22 80 00       	push   $0x8022ff
  800d3f:	6a 23                	push   $0x23
  800d41:	68 1c 23 80 00       	push   $0x80231c
  800d46:	e8 12 f4 ff ff       	call   80015d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 df                	mov    %ebx,%edi
  800d6e:	89 de                	mov    %ebx,%esi
  800d70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d72:	85 c0                	test   %eax,%eax
  800d74:	7e 17                	jle    800d8d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 0a                	push   $0xa
  800d7c:	68 ff 22 80 00       	push   $0x8022ff
  800d81:	6a 23                	push   $0x23
  800d83:	68 1c 23 80 00       	push   $0x80231c
  800d88:	e8 d0 f3 ff ff       	call   80015d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d9b:	be 00 00 00 00       	mov    $0x0,%esi
  800da0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	57                   	push   %edi
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800dc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	89 cb                	mov    %ecx,%ebx
  800dd0:	89 cf                	mov    %ecx,%edi
  800dd2:	89 ce                	mov    %ecx,%esi
  800dd4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	7e 17                	jle    800df1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	50                   	push   %eax
  800dde:	6a 0d                	push   $0xd
  800de0:	68 ff 22 80 00       	push   $0x8022ff
  800de5:	6a 23                	push   $0x23
  800de7:	68 1c 23 80 00       	push   $0x80231c
  800dec:	e8 6c f3 ff ff       	call   80015d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df4:	5b                   	pop    %ebx
  800df5:	5e                   	pop    %esi
  800df6:	5f                   	pop    %edi
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  800dff:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e06:	75 4c                	jne    800e54 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  800e08:	a1 04 40 80 00       	mov    0x804004,%eax
  800e0d:	8b 40 48             	mov    0x48(%eax),%eax
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	6a 07                	push   $0x7
  800e15:	68 00 f0 bf ee       	push   $0xeebff000
  800e1a:	50                   	push   %eax
  800e1b:	e8 e8 fd ff ff       	call   800c08 <sys_page_alloc>
		if(retv != 0){
  800e20:	83 c4 10             	add    $0x10,%esp
  800e23:	85 c0                	test   %eax,%eax
  800e25:	74 14                	je     800e3b <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 2c 23 80 00       	push   $0x80232c
  800e2f:	6a 27                	push   $0x27
  800e31:	68 58 23 80 00       	push   $0x802358
  800e36:	e8 22 f3 ff ff       	call   80015d <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e3b:	a1 04 40 80 00       	mov    0x804004,%eax
  800e40:	8b 40 48             	mov    0x48(%eax),%eax
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	68 5e 0e 80 00       	push   $0x800e5e
  800e4b:	50                   	push   %eax
  800e4c:	e8 02 ff ff ff       	call   800d53 <sys_env_set_pgfault_upcall>
  800e51:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	a3 08 40 80 00       	mov    %eax,0x804008

}
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e5e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e5f:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e64:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  800e66:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  800e69:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  800e6d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  800e72:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  800e76:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  800e78:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  800e7b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  800e7c:	83 c4 04             	add    $0x4,%esp
	popfl
  800e7f:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e80:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e81:	c3                   	ret    

00800e82 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	05 00 00 00 30       	add    $0x30000000,%eax
  800e8d:	c1 e8 0c             	shr    $0xc,%eax
}
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	05 00 00 00 30       	add    $0x30000000,%eax
  800e9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ea2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaf:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	c1 ea 16             	shr    $0x16,%edx
  800eb9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec0:	f6 c2 01             	test   $0x1,%dl
  800ec3:	74 11                	je     800ed6 <fd_alloc+0x2d>
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	c1 ea 0c             	shr    $0xc,%edx
  800eca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed1:	f6 c2 01             	test   $0x1,%dl
  800ed4:	75 09                	jne    800edf <fd_alloc+0x36>
			*fd_store = fd;
  800ed6:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	eb 17                	jmp    800ef6 <fd_alloc+0x4d>
  800edf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ee4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ee9:	75 c9                	jne    800eb4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eeb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ef1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800efe:	83 f8 1f             	cmp    $0x1f,%eax
  800f01:	77 36                	ja     800f39 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f03:	c1 e0 0c             	shl    $0xc,%eax
  800f06:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f0b:	89 c2                	mov    %eax,%edx
  800f0d:	c1 ea 16             	shr    $0x16,%edx
  800f10:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f17:	f6 c2 01             	test   $0x1,%dl
  800f1a:	74 24                	je     800f40 <fd_lookup+0x48>
  800f1c:	89 c2                	mov    %eax,%edx
  800f1e:	c1 ea 0c             	shr    $0xc,%edx
  800f21:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f28:	f6 c2 01             	test   $0x1,%dl
  800f2b:	74 1a                	je     800f47 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f30:	89 02                	mov    %eax,(%edx)
	return 0;
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
  800f37:	eb 13                	jmp    800f4c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f3e:	eb 0c                	jmp    800f4c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f40:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f45:	eb 05                	jmp    800f4c <fd_lookup+0x54>
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 08             	sub    $0x8,%esp
  800f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f57:	ba e8 23 80 00       	mov    $0x8023e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f5c:	eb 13                	jmp    800f71 <dev_lookup+0x23>
  800f5e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f61:	39 08                	cmp    %ecx,(%eax)
  800f63:	75 0c                	jne    800f71 <dev_lookup+0x23>
			*dev = devtab[i];
  800f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f68:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	eb 2e                	jmp    800f9f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f71:	8b 02                	mov    (%edx),%eax
  800f73:	85 c0                	test   %eax,%eax
  800f75:	75 e7                	jne    800f5e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f77:	a1 04 40 80 00       	mov    0x804004,%eax
  800f7c:	8b 40 48             	mov    0x48(%eax),%eax
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	51                   	push   %ecx
  800f83:	50                   	push   %eax
  800f84:	68 68 23 80 00       	push   $0x802368
  800f89:	e8 a8 f2 ff ff       	call   800236 <cprintf>
	*dev = 0;
  800f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f97:	83 c4 10             	add    $0x10,%esp
  800f9a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
  800fa6:	83 ec 10             	sub    $0x10,%esp
  800fa9:	8b 75 08             	mov    0x8(%ebp),%esi
  800fac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800faf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb2:	50                   	push   %eax
  800fb3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fb9:	c1 e8 0c             	shr    $0xc,%eax
  800fbc:	50                   	push   %eax
  800fbd:	e8 36 ff ff ff       	call   800ef8 <fd_lookup>
  800fc2:	83 c4 08             	add    $0x8,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 05                	js     800fce <fd_close+0x2d>
	    || fd != fd2)
  800fc9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fcc:	74 0c                	je     800fda <fd_close+0x39>
		return (must_exist ? r : 0);
  800fce:	84 db                	test   %bl,%bl
  800fd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd5:	0f 44 c2             	cmove  %edx,%eax
  800fd8:	eb 41                	jmp    80101b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	ff 36                	pushl  (%esi)
  800fe3:	e8 66 ff ff ff       	call   800f4e <dev_lookup>
  800fe8:	89 c3                	mov    %eax,%ebx
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 1a                	js     80100b <fd_close+0x6a>
		if (dev->dev_close)
  800ff1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ff7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	74 0b                	je     80100b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	56                   	push   %esi
  801004:	ff d0                	call   *%eax
  801006:	89 c3                	mov    %eax,%ebx
  801008:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	56                   	push   %esi
  80100f:	6a 00                	push   $0x0
  801011:	e8 77 fc ff ff       	call   800c8d <sys_page_unmap>
	return r;
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	89 d8                	mov    %ebx,%eax
}
  80101b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80101e:	5b                   	pop    %ebx
  80101f:	5e                   	pop    %esi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801028:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80102b:	50                   	push   %eax
  80102c:	ff 75 08             	pushl  0x8(%ebp)
  80102f:	e8 c4 fe ff ff       	call   800ef8 <fd_lookup>
  801034:	83 c4 08             	add    $0x8,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	78 10                	js     80104b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	6a 01                	push   $0x1
  801040:	ff 75 f4             	pushl  -0xc(%ebp)
  801043:	e8 59 ff ff ff       	call   800fa1 <fd_close>
  801048:	83 c4 10             	add    $0x10,%esp
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <close_all>:

void
close_all(void)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	53                   	push   %ebx
  801051:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801054:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	53                   	push   %ebx
  80105d:	e8 c0 ff ff ff       	call   801022 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801062:	83 c3 01             	add    $0x1,%ebx
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	83 fb 20             	cmp    $0x20,%ebx
  80106b:	75 ec                	jne    801059 <close_all+0xc>
		close(i);
}
  80106d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	57                   	push   %edi
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
  801078:	83 ec 2c             	sub    $0x2c,%esp
  80107b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80107e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801081:	50                   	push   %eax
  801082:	ff 75 08             	pushl  0x8(%ebp)
  801085:	e8 6e fe ff ff       	call   800ef8 <fd_lookup>
  80108a:	83 c4 08             	add    $0x8,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	0f 88 c1 00 00 00    	js     801156 <dup+0xe4>
		return r;
	close(newfdnum);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	56                   	push   %esi
  801099:	e8 84 ff ff ff       	call   801022 <close>

	newfd = INDEX2FD(newfdnum);
  80109e:	89 f3                	mov    %esi,%ebx
  8010a0:	c1 e3 0c             	shl    $0xc,%ebx
  8010a3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010a9:	83 c4 04             	add    $0x4,%esp
  8010ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010af:	e8 de fd ff ff       	call   800e92 <fd2data>
  8010b4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010b6:	89 1c 24             	mov    %ebx,(%esp)
  8010b9:	e8 d4 fd ff ff       	call   800e92 <fd2data>
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010c4:	89 f8                	mov    %edi,%eax
  8010c6:	c1 e8 16             	shr    $0x16,%eax
  8010c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d0:	a8 01                	test   $0x1,%al
  8010d2:	74 37                	je     80110b <dup+0x99>
  8010d4:	89 f8                	mov    %edi,%eax
  8010d6:	c1 e8 0c             	shr    $0xc,%eax
  8010d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e0:	f6 c2 01             	test   $0x1,%dl
  8010e3:	74 26                	je     80110b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f4:	50                   	push   %eax
  8010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f8:	6a 00                	push   $0x0
  8010fa:	57                   	push   %edi
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 49 fb ff ff       	call   800c4b <sys_page_map>
  801102:	89 c7                	mov    %eax,%edi
  801104:	83 c4 20             	add    $0x20,%esp
  801107:	85 c0                	test   %eax,%eax
  801109:	78 2e                	js     801139 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80110b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80110e:	89 d0                	mov    %edx,%eax
  801110:	c1 e8 0c             	shr    $0xc,%eax
  801113:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	25 07 0e 00 00       	and    $0xe07,%eax
  801122:	50                   	push   %eax
  801123:	53                   	push   %ebx
  801124:	6a 00                	push   $0x0
  801126:	52                   	push   %edx
  801127:	6a 00                	push   $0x0
  801129:	e8 1d fb ff ff       	call   800c4b <sys_page_map>
  80112e:	89 c7                	mov    %eax,%edi
  801130:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801133:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801135:	85 ff                	test   %edi,%edi
  801137:	79 1d                	jns    801156 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	53                   	push   %ebx
  80113d:	6a 00                	push   $0x0
  80113f:	e8 49 fb ff ff       	call   800c8d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801144:	83 c4 08             	add    $0x8,%esp
  801147:	ff 75 d4             	pushl  -0x2c(%ebp)
  80114a:	6a 00                	push   $0x0
  80114c:	e8 3c fb ff ff       	call   800c8d <sys_page_unmap>
	return r;
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	89 f8                	mov    %edi,%eax
}
  801156:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801159:	5b                   	pop    %ebx
  80115a:	5e                   	pop    %esi
  80115b:	5f                   	pop    %edi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	53                   	push   %ebx
  801162:	83 ec 14             	sub    $0x14,%esp
  801165:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801168:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116b:	50                   	push   %eax
  80116c:	53                   	push   %ebx
  80116d:	e8 86 fd ff ff       	call   800ef8 <fd_lookup>
  801172:	83 c4 08             	add    $0x8,%esp
  801175:	89 c2                	mov    %eax,%edx
  801177:	85 c0                	test   %eax,%eax
  801179:	78 6d                	js     8011e8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801185:	ff 30                	pushl  (%eax)
  801187:	e8 c2 fd ff ff       	call   800f4e <dev_lookup>
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	85 c0                	test   %eax,%eax
  801191:	78 4c                	js     8011df <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801193:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801196:	8b 42 08             	mov    0x8(%edx),%eax
  801199:	83 e0 03             	and    $0x3,%eax
  80119c:	83 f8 01             	cmp    $0x1,%eax
  80119f:	75 21                	jne    8011c2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a6:	8b 40 48             	mov    0x48(%eax),%eax
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	53                   	push   %ebx
  8011ad:	50                   	push   %eax
  8011ae:	68 ac 23 80 00       	push   $0x8023ac
  8011b3:	e8 7e f0 ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c0:	eb 26                	jmp    8011e8 <read+0x8a>
	}
	if (!dev->dev_read)
  8011c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c5:	8b 40 08             	mov    0x8(%eax),%eax
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	74 17                	je     8011e3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 10             	pushl  0x10(%ebp)
  8011d2:	ff 75 0c             	pushl  0xc(%ebp)
  8011d5:	52                   	push   %edx
  8011d6:	ff d0                	call   *%eax
  8011d8:	89 c2                	mov    %eax,%edx
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	eb 09                	jmp    8011e8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011df:	89 c2                	mov    %eax,%edx
  8011e1:	eb 05                	jmp    8011e8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011e8:	89 d0                	mov    %edx,%eax
  8011ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ed:	c9                   	leave  
  8011ee:	c3                   	ret    

008011ef <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	57                   	push   %edi
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801203:	eb 21                	jmp    801226 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801205:	83 ec 04             	sub    $0x4,%esp
  801208:	89 f0                	mov    %esi,%eax
  80120a:	29 d8                	sub    %ebx,%eax
  80120c:	50                   	push   %eax
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	03 45 0c             	add    0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	57                   	push   %edi
  801214:	e8 45 ff ff ff       	call   80115e <read>
		if (m < 0)
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	78 10                	js     801230 <readn+0x41>
			return m;
		if (m == 0)
  801220:	85 c0                	test   %eax,%eax
  801222:	74 0a                	je     80122e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801224:	01 c3                	add    %eax,%ebx
  801226:	39 f3                	cmp    %esi,%ebx
  801228:	72 db                	jb     801205 <readn+0x16>
  80122a:	89 d8                	mov    %ebx,%eax
  80122c:	eb 02                	jmp    801230 <readn+0x41>
  80122e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	53                   	push   %ebx
  80123c:	83 ec 14             	sub    $0x14,%esp
  80123f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801242:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801245:	50                   	push   %eax
  801246:	53                   	push   %ebx
  801247:	e8 ac fc ff ff       	call   800ef8 <fd_lookup>
  80124c:	83 c4 08             	add    $0x8,%esp
  80124f:	89 c2                	mov    %eax,%edx
  801251:	85 c0                	test   %eax,%eax
  801253:	78 68                	js     8012bd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80125b:	50                   	push   %eax
  80125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125f:	ff 30                	pushl  (%eax)
  801261:	e8 e8 fc ff ff       	call   800f4e <dev_lookup>
  801266:	83 c4 10             	add    $0x10,%esp
  801269:	85 c0                	test   %eax,%eax
  80126b:	78 47                	js     8012b4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801270:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801274:	75 21                	jne    801297 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801276:	a1 04 40 80 00       	mov    0x804004,%eax
  80127b:	8b 40 48             	mov    0x48(%eax),%eax
  80127e:	83 ec 04             	sub    $0x4,%esp
  801281:	53                   	push   %ebx
  801282:	50                   	push   %eax
  801283:	68 c8 23 80 00       	push   $0x8023c8
  801288:	e8 a9 ef ff ff       	call   800236 <cprintf>
		return -E_INVAL;
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801295:	eb 26                	jmp    8012bd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801297:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129a:	8b 52 0c             	mov    0xc(%edx),%edx
  80129d:	85 d2                	test   %edx,%edx
  80129f:	74 17                	je     8012b8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012a1:	83 ec 04             	sub    $0x4,%esp
  8012a4:	ff 75 10             	pushl  0x10(%ebp)
  8012a7:	ff 75 0c             	pushl  0xc(%ebp)
  8012aa:	50                   	push   %eax
  8012ab:	ff d2                	call   *%edx
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	eb 09                	jmp    8012bd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	eb 05                	jmp    8012bd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012bd:	89 d0                	mov    %edx,%eax
  8012bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ca:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 75 08             	pushl  0x8(%ebp)
  8012d1:	e8 22 fc ff ff       	call   800ef8 <fd_lookup>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 0e                	js     8012eb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012eb:	c9                   	leave  
  8012ec:	c3                   	ret    

008012ed <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 14             	sub    $0x14,%esp
  8012f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fa:	50                   	push   %eax
  8012fb:	53                   	push   %ebx
  8012fc:	e8 f7 fb ff ff       	call   800ef8 <fd_lookup>
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	89 c2                	mov    %eax,%edx
  801306:	85 c0                	test   %eax,%eax
  801308:	78 65                	js     80136f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801314:	ff 30                	pushl  (%eax)
  801316:	e8 33 fc ff ff       	call   800f4e <dev_lookup>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 44                	js     801366 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801322:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801325:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801329:	75 21                	jne    80134c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80132b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801330:	8b 40 48             	mov    0x48(%eax),%eax
  801333:	83 ec 04             	sub    $0x4,%esp
  801336:	53                   	push   %ebx
  801337:	50                   	push   %eax
  801338:	68 88 23 80 00       	push   $0x802388
  80133d:	e8 f4 ee ff ff       	call   800236 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80134a:	eb 23                	jmp    80136f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80134c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80134f:	8b 52 18             	mov    0x18(%edx),%edx
  801352:	85 d2                	test   %edx,%edx
  801354:	74 14                	je     80136a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	ff 75 0c             	pushl  0xc(%ebp)
  80135c:	50                   	push   %eax
  80135d:	ff d2                	call   *%edx
  80135f:	89 c2                	mov    %eax,%edx
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	eb 09                	jmp    80136f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801366:	89 c2                	mov    %eax,%edx
  801368:	eb 05                	jmp    80136f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80136a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80136f:	89 d0                	mov    %edx,%eax
  801371:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	53                   	push   %ebx
  80137a:	83 ec 14             	sub    $0x14,%esp
  80137d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801380:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	ff 75 08             	pushl  0x8(%ebp)
  801387:	e8 6c fb ff ff       	call   800ef8 <fd_lookup>
  80138c:	83 c4 08             	add    $0x8,%esp
  80138f:	89 c2                	mov    %eax,%edx
  801391:	85 c0                	test   %eax,%eax
  801393:	78 58                	js     8013ed <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139f:	ff 30                	pushl  (%eax)
  8013a1:	e8 a8 fb ff ff       	call   800f4e <dev_lookup>
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 37                	js     8013e4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013b4:	74 32                	je     8013e8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c0:	00 00 00 
	stat->st_isdir = 0;
  8013c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ca:	00 00 00 
	stat->st_dev = dev;
  8013cd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	53                   	push   %ebx
  8013d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8013da:	ff 50 14             	call   *0x14(%eax)
  8013dd:	89 c2                	mov    %eax,%edx
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	eb 09                	jmp    8013ed <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	eb 05                	jmp    8013ed <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013ed:	89 d0                	mov    %edx,%eax
  8013ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    

008013f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013f4:	55                   	push   %ebp
  8013f5:	89 e5                	mov    %esp,%ebp
  8013f7:	56                   	push   %esi
  8013f8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013f9:	83 ec 08             	sub    $0x8,%esp
  8013fc:	6a 00                	push   $0x0
  8013fe:	ff 75 08             	pushl  0x8(%ebp)
  801401:	e8 dc 01 00 00       	call   8015e2 <open>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	85 c0                	test   %eax,%eax
  80140d:	78 1b                	js     80142a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80140f:	83 ec 08             	sub    $0x8,%esp
  801412:	ff 75 0c             	pushl  0xc(%ebp)
  801415:	50                   	push   %eax
  801416:	e8 5b ff ff ff       	call   801376 <fstat>
  80141b:	89 c6                	mov    %eax,%esi
	close(fd);
  80141d:	89 1c 24             	mov    %ebx,(%esp)
  801420:	e8 fd fb ff ff       	call   801022 <close>
	return r;
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	89 f0                	mov    %esi,%eax
}
  80142a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5d                   	pop    %ebp
  801430:	c3                   	ret    

00801431 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	89 c6                	mov    %eax,%esi
  801438:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80143a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801441:	75 12                	jne    801455 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	6a 01                	push   $0x1
  801448:	e8 b8 07 00 00       	call   801c05 <ipc_find_env>
  80144d:	a3 00 40 80 00       	mov    %eax,0x804000
  801452:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801455:	6a 07                	push   $0x7
  801457:	68 00 50 80 00       	push   $0x805000
  80145c:	56                   	push   %esi
  80145d:	ff 35 00 40 80 00    	pushl  0x804000
  801463:	e8 5a 07 00 00       	call   801bc2 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801468:	83 c4 0c             	add    $0xc,%esp
  80146b:	6a 00                	push   $0x0
  80146d:	53                   	push   %ebx
  80146e:	6a 00                	push   $0x0
  801470:	e8 f0 06 00 00       	call   801b65 <ipc_recv>
}
  801475:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    

0080147c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801482:	8b 45 08             	mov    0x8(%ebp),%eax
  801485:	8b 40 0c             	mov    0xc(%eax),%eax
  801488:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80148d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801490:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	b8 02 00 00 00       	mov    $0x2,%eax
  80149f:	e8 8d ff ff ff       	call   801431 <fsipc>
}
  8014a4:	c9                   	leave  
  8014a5:	c3                   	ret    

008014a6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8014c1:	e8 6b ff ff ff       	call   801431 <fsipc>
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	53                   	push   %ebx
  8014cc:	83 ec 04             	sub    $0x4,%esp
  8014cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e7:	e8 45 ff ff ff       	call   801431 <fsipc>
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	78 2c                	js     80151c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	68 00 50 80 00       	push   $0x805000
  8014f8:	53                   	push   %ebx
  8014f9:	e8 07 f3 ff ff       	call   800805 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014fe:	a1 80 50 80 00       	mov    0x805080,%eax
  801503:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801509:	a1 84 50 80 00       	mov    0x805084,%eax
  80150e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80151c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 0c             	sub    $0xc,%esp
  801527:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80152a:	8b 55 08             	mov    0x8(%ebp),%edx
  80152d:	8b 52 0c             	mov    0xc(%edx),%edx
  801530:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801536:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80153b:	50                   	push   %eax
  80153c:	ff 75 0c             	pushl  0xc(%ebp)
  80153f:	68 08 50 80 00       	push   $0x805008
  801544:	e8 4e f4 ff ff       	call   800997 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801549:	ba 00 00 00 00       	mov    $0x0,%edx
  80154e:	b8 04 00 00 00       	mov    $0x4,%eax
  801553:	e8 d9 fe ff ff       	call   801431 <fsipc>
	//panic("devfile_write not implemented");
}
  801558:	c9                   	leave  
  801559:	c3                   	ret    

0080155a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	56                   	push   %esi
  80155e:	53                   	push   %ebx
  80155f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801562:	8b 45 08             	mov    0x8(%ebp),%eax
  801565:	8b 40 0c             	mov    0xc(%eax),%eax
  801568:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80156d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801573:	ba 00 00 00 00       	mov    $0x0,%edx
  801578:	b8 03 00 00 00       	mov    $0x3,%eax
  80157d:	e8 af fe ff ff       	call   801431 <fsipc>
  801582:	89 c3                	mov    %eax,%ebx
  801584:	85 c0                	test   %eax,%eax
  801586:	78 51                	js     8015d9 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801588:	39 c6                	cmp    %eax,%esi
  80158a:	73 19                	jae    8015a5 <devfile_read+0x4b>
  80158c:	68 f8 23 80 00       	push   $0x8023f8
  801591:	68 ff 23 80 00       	push   $0x8023ff
  801596:	68 80 00 00 00       	push   $0x80
  80159b:	68 14 24 80 00       	push   $0x802414
  8015a0:	e8 b8 eb ff ff       	call   80015d <_panic>
	assert(r <= PGSIZE);
  8015a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015aa:	7e 19                	jle    8015c5 <devfile_read+0x6b>
  8015ac:	68 1f 24 80 00       	push   $0x80241f
  8015b1:	68 ff 23 80 00       	push   $0x8023ff
  8015b6:	68 81 00 00 00       	push   $0x81
  8015bb:	68 14 24 80 00       	push   $0x802414
  8015c0:	e8 98 eb ff ff       	call   80015d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	50                   	push   %eax
  8015c9:	68 00 50 80 00       	push   $0x805000
  8015ce:	ff 75 0c             	pushl  0xc(%ebp)
  8015d1:	e8 c1 f3 ff ff       	call   800997 <memmove>
	return r;
  8015d6:	83 c4 10             	add    $0x10,%esp
}
  8015d9:	89 d8                	mov    %ebx,%eax
  8015db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015de:	5b                   	pop    %ebx
  8015df:	5e                   	pop    %esi
  8015e0:	5d                   	pop    %ebp
  8015e1:	c3                   	ret    

008015e2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	53                   	push   %ebx
  8015e6:	83 ec 20             	sub    $0x20,%esp
  8015e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015ec:	53                   	push   %ebx
  8015ed:	e8 da f1 ff ff       	call   8007cc <strlen>
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fa:	7f 67                	jg     801663 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	e8 a1 f8 ff ff       	call   800ea9 <fd_alloc>
  801608:	83 c4 10             	add    $0x10,%esp
		return r;
  80160b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 57                	js     801668 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	53                   	push   %ebx
  801615:	68 00 50 80 00       	push   $0x805000
  80161a:	e8 e6 f1 ff ff       	call   800805 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80161f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801622:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801627:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162a:	b8 01 00 00 00       	mov    $0x1,%eax
  80162f:	e8 fd fd ff ff       	call   801431 <fsipc>
  801634:	89 c3                	mov    %eax,%ebx
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	79 14                	jns    801651 <open+0x6f>
		
		fd_close(fd, 0);
  80163d:	83 ec 08             	sub    $0x8,%esp
  801640:	6a 00                	push   $0x0
  801642:	ff 75 f4             	pushl  -0xc(%ebp)
  801645:	e8 57 f9 ff ff       	call   800fa1 <fd_close>
		return r;
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	89 da                	mov    %ebx,%edx
  80164f:	eb 17                	jmp    801668 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801651:	83 ec 0c             	sub    $0xc,%esp
  801654:	ff 75 f4             	pushl  -0xc(%ebp)
  801657:	e8 26 f8 ff ff       	call   800e82 <fd2num>
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb 05                	jmp    801668 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801663:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801668:	89 d0                	mov    %edx,%eax
  80166a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801675:	ba 00 00 00 00       	mov    $0x0,%edx
  80167a:	b8 08 00 00 00       	mov    $0x8,%eax
  80167f:	e8 ad fd ff ff       	call   801431 <fsipc>
}
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	56                   	push   %esi
  80168a:	53                   	push   %ebx
  80168b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	ff 75 08             	pushl  0x8(%ebp)
  801694:	e8 f9 f7 ff ff       	call   800e92 <fd2data>
  801699:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80169b:	83 c4 08             	add    $0x8,%esp
  80169e:	68 2b 24 80 00       	push   $0x80242b
  8016a3:	53                   	push   %ebx
  8016a4:	e8 5c f1 ff ff       	call   800805 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016a9:	8b 46 04             	mov    0x4(%esi),%eax
  8016ac:	2b 06                	sub    (%esi),%eax
  8016ae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016b4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016bb:	00 00 00 
	stat->st_dev = &devpipe;
  8016be:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016c5:	30 80 00 
	return 0;
}
  8016c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5e                   	pop    %esi
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	53                   	push   %ebx
  8016d8:	83 ec 0c             	sub    $0xc,%esp
  8016db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016de:	53                   	push   %ebx
  8016df:	6a 00                	push   $0x0
  8016e1:	e8 a7 f5 ff ff       	call   800c8d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016e6:	89 1c 24             	mov    %ebx,(%esp)
  8016e9:	e8 a4 f7 ff ff       	call   800e92 <fd2data>
  8016ee:	83 c4 08             	add    $0x8,%esp
  8016f1:	50                   	push   %eax
  8016f2:	6a 00                	push   $0x0
  8016f4:	e8 94 f5 ff ff       	call   800c8d <sys_page_unmap>
}
  8016f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
  801704:	83 ec 1c             	sub    $0x1c,%esp
  801707:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80170a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80170c:	a1 04 40 80 00       	mov    0x804004,%eax
  801711:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801714:	83 ec 0c             	sub    $0xc,%esp
  801717:	ff 75 e0             	pushl  -0x20(%ebp)
  80171a:	e8 1f 05 00 00       	call   801c3e <pageref>
  80171f:	89 c3                	mov    %eax,%ebx
  801721:	89 3c 24             	mov    %edi,(%esp)
  801724:	e8 15 05 00 00       	call   801c3e <pageref>
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	39 c3                	cmp    %eax,%ebx
  80172e:	0f 94 c1             	sete   %cl
  801731:	0f b6 c9             	movzbl %cl,%ecx
  801734:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801737:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80173d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801740:	39 ce                	cmp    %ecx,%esi
  801742:	74 1b                	je     80175f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801744:	39 c3                	cmp    %eax,%ebx
  801746:	75 c4                	jne    80170c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801748:	8b 42 58             	mov    0x58(%edx),%eax
  80174b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80174e:	50                   	push   %eax
  80174f:	56                   	push   %esi
  801750:	68 32 24 80 00       	push   $0x802432
  801755:	e8 dc ea ff ff       	call   800236 <cprintf>
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb ad                	jmp    80170c <_pipeisclosed+0xe>
	}
}
  80175f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5f                   	pop    %edi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	57                   	push   %edi
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	83 ec 28             	sub    $0x28,%esp
  801773:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801776:	56                   	push   %esi
  801777:	e8 16 f7 ff ff       	call   800e92 <fd2data>
  80177c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80177e:	83 c4 10             	add    $0x10,%esp
  801781:	bf 00 00 00 00       	mov    $0x0,%edi
  801786:	eb 4b                	jmp    8017d3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801788:	89 da                	mov    %ebx,%edx
  80178a:	89 f0                	mov    %esi,%eax
  80178c:	e8 6d ff ff ff       	call   8016fe <_pipeisclosed>
  801791:	85 c0                	test   %eax,%eax
  801793:	75 48                	jne    8017dd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801795:	e8 4f f4 ff ff       	call   800be9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80179a:	8b 43 04             	mov    0x4(%ebx),%eax
  80179d:	8b 0b                	mov    (%ebx),%ecx
  80179f:	8d 51 20             	lea    0x20(%ecx),%edx
  8017a2:	39 d0                	cmp    %edx,%eax
  8017a4:	73 e2                	jae    801788 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017ad:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	c1 fa 1f             	sar    $0x1f,%edx
  8017b5:	89 d1                	mov    %edx,%ecx
  8017b7:	c1 e9 1b             	shr    $0x1b,%ecx
  8017ba:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017bd:	83 e2 1f             	and    $0x1f,%edx
  8017c0:	29 ca                	sub    %ecx,%edx
  8017c2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017c6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017ca:	83 c0 01             	add    $0x1,%eax
  8017cd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d0:	83 c7 01             	add    $0x1,%edi
  8017d3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017d6:	75 c2                	jne    80179a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017db:	eb 05                	jmp    8017e2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017dd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5f                   	pop    %edi
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	57                   	push   %edi
  8017ee:	56                   	push   %esi
  8017ef:	53                   	push   %ebx
  8017f0:	83 ec 18             	sub    $0x18,%esp
  8017f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017f6:	57                   	push   %edi
  8017f7:	e8 96 f6 ff ff       	call   800e92 <fd2data>
  8017fc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	bb 00 00 00 00       	mov    $0x0,%ebx
  801806:	eb 3d                	jmp    801845 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801808:	85 db                	test   %ebx,%ebx
  80180a:	74 04                	je     801810 <devpipe_read+0x26>
				return i;
  80180c:	89 d8                	mov    %ebx,%eax
  80180e:	eb 44                	jmp    801854 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801810:	89 f2                	mov    %esi,%edx
  801812:	89 f8                	mov    %edi,%eax
  801814:	e8 e5 fe ff ff       	call   8016fe <_pipeisclosed>
  801819:	85 c0                	test   %eax,%eax
  80181b:	75 32                	jne    80184f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80181d:	e8 c7 f3 ff ff       	call   800be9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801822:	8b 06                	mov    (%esi),%eax
  801824:	3b 46 04             	cmp    0x4(%esi),%eax
  801827:	74 df                	je     801808 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801829:	99                   	cltd   
  80182a:	c1 ea 1b             	shr    $0x1b,%edx
  80182d:	01 d0                	add    %edx,%eax
  80182f:	83 e0 1f             	and    $0x1f,%eax
  801832:	29 d0                	sub    %edx,%eax
  801834:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801839:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80183c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80183f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801842:	83 c3 01             	add    $0x1,%ebx
  801845:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801848:	75 d8                	jne    801822 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80184a:	8b 45 10             	mov    0x10(%ebp),%eax
  80184d:	eb 05                	jmp    801854 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80184f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801854:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801857:	5b                   	pop    %ebx
  801858:	5e                   	pop    %esi
  801859:	5f                   	pop    %edi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    

0080185c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801864:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	e8 3c f6 ff ff       	call   800ea9 <fd_alloc>
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	89 c2                	mov    %eax,%edx
  801872:	85 c0                	test   %eax,%eax
  801874:	0f 88 2c 01 00 00    	js     8019a6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80187a:	83 ec 04             	sub    $0x4,%esp
  80187d:	68 07 04 00 00       	push   $0x407
  801882:	ff 75 f4             	pushl  -0xc(%ebp)
  801885:	6a 00                	push   $0x0
  801887:	e8 7c f3 ff ff       	call   800c08 <sys_page_alloc>
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	89 c2                	mov    %eax,%edx
  801891:	85 c0                	test   %eax,%eax
  801893:	0f 88 0d 01 00 00    	js     8019a6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801899:	83 ec 0c             	sub    $0xc,%esp
  80189c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80189f:	50                   	push   %eax
  8018a0:	e8 04 f6 ff ff       	call   800ea9 <fd_alloc>
  8018a5:	89 c3                	mov    %eax,%ebx
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	0f 88 e2 00 00 00    	js     801994 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	68 07 04 00 00       	push   $0x407
  8018ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bd:	6a 00                	push   $0x0
  8018bf:	e8 44 f3 ff ff       	call   800c08 <sys_page_alloc>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	0f 88 c3 00 00 00    	js     801994 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018d1:	83 ec 0c             	sub    $0xc,%esp
  8018d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018d7:	e8 b6 f5 ff ff       	call   800e92 <fd2data>
  8018dc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018de:	83 c4 0c             	add    $0xc,%esp
  8018e1:	68 07 04 00 00       	push   $0x407
  8018e6:	50                   	push   %eax
  8018e7:	6a 00                	push   $0x0
  8018e9:	e8 1a f3 ff ff       	call   800c08 <sys_page_alloc>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	0f 88 89 00 00 00    	js     801984 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801901:	e8 8c f5 ff ff       	call   800e92 <fd2data>
  801906:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80190d:	50                   	push   %eax
  80190e:	6a 00                	push   $0x0
  801910:	56                   	push   %esi
  801911:	6a 00                	push   $0x0
  801913:	e8 33 f3 ff ff       	call   800c4b <sys_page_map>
  801918:	89 c3                	mov    %eax,%ebx
  80191a:	83 c4 20             	add    $0x20,%esp
  80191d:	85 c0                	test   %eax,%eax
  80191f:	78 55                	js     801976 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801921:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801927:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80192c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801936:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80193c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80193f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801941:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801944:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80194b:	83 ec 0c             	sub    $0xc,%esp
  80194e:	ff 75 f4             	pushl  -0xc(%ebp)
  801951:	e8 2c f5 ff ff       	call   800e82 <fd2num>
  801956:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801959:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80195b:	83 c4 04             	add    $0x4,%esp
  80195e:	ff 75 f0             	pushl  -0x10(%ebp)
  801961:	e8 1c f5 ff ff       	call   800e82 <fd2num>
  801966:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801969:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	ba 00 00 00 00       	mov    $0x0,%edx
  801974:	eb 30                	jmp    8019a6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801976:	83 ec 08             	sub    $0x8,%esp
  801979:	56                   	push   %esi
  80197a:	6a 00                	push   $0x0
  80197c:	e8 0c f3 ff ff       	call   800c8d <sys_page_unmap>
  801981:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	ff 75 f0             	pushl  -0x10(%ebp)
  80198a:	6a 00                	push   $0x0
  80198c:	e8 fc f2 ff ff       	call   800c8d <sys_page_unmap>
  801991:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	ff 75 f4             	pushl  -0xc(%ebp)
  80199a:	6a 00                	push   $0x0
  80199c:	e8 ec f2 ff ff       	call   800c8d <sys_page_unmap>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019a6:	89 d0                	mov    %edx,%eax
  8019a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b8:	50                   	push   %eax
  8019b9:	ff 75 08             	pushl  0x8(%ebp)
  8019bc:	e8 37 f5 ff ff       	call   800ef8 <fd_lookup>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 18                	js     8019e0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019c8:	83 ec 0c             	sub    $0xc,%esp
  8019cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ce:	e8 bf f4 ff ff       	call   800e92 <fd2data>
	return _pipeisclosed(fd, p);
  8019d3:	89 c2                	mov    %eax,%edx
  8019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d8:	e8 21 fd ff ff       	call   8016fe <_pipeisclosed>
  8019dd:	83 c4 10             	add    $0x10,%esp
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ea:	5d                   	pop    %ebp
  8019eb:	c3                   	ret    

008019ec <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019f2:	68 4a 24 80 00       	push   $0x80244a
  8019f7:	ff 75 0c             	pushl  0xc(%ebp)
  8019fa:	e8 06 ee ff ff       	call   800805 <strcpy>
	return 0;
}
  8019ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	57                   	push   %edi
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a12:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a17:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a1d:	eb 2d                	jmp    801a4c <devcons_write+0x46>
		m = n - tot;
  801a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a22:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a24:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a27:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a2c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a2f:	83 ec 04             	sub    $0x4,%esp
  801a32:	53                   	push   %ebx
  801a33:	03 45 0c             	add    0xc(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	57                   	push   %edi
  801a38:	e8 5a ef ff ff       	call   800997 <memmove>
		sys_cputs(buf, m);
  801a3d:	83 c4 08             	add    $0x8,%esp
  801a40:	53                   	push   %ebx
  801a41:	57                   	push   %edi
  801a42:	e8 05 f1 ff ff       	call   800b4c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a47:	01 de                	add    %ebx,%esi
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	89 f0                	mov    %esi,%eax
  801a4e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a51:	72 cc                	jb     801a1f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a66:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a6a:	74 2a                	je     801a96 <devcons_read+0x3b>
  801a6c:	eb 05                	jmp    801a73 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a6e:	e8 76 f1 ff ff       	call   800be9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a73:	e8 f2 f0 ff ff       	call   800b6a <sys_cgetc>
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	74 f2                	je     801a6e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a7c:	85 c0                	test   %eax,%eax
  801a7e:	78 16                	js     801a96 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a80:	83 f8 04             	cmp    $0x4,%eax
  801a83:	74 0c                	je     801a91 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a85:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a88:	88 02                	mov    %al,(%edx)
	return 1;
  801a8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8f:	eb 05                	jmp    801a96 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a91:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801aa4:	6a 01                	push   $0x1
  801aa6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aa9:	50                   	push   %eax
  801aaa:	e8 9d f0 ff ff       	call   800b4c <sys_cputs>
}
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	c9                   	leave  
  801ab3:	c3                   	ret    

00801ab4 <getchar>:

int
getchar(void)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aba:	6a 01                	push   $0x1
  801abc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801abf:	50                   	push   %eax
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 97 f6 ff ff       	call   80115e <read>
	if (r < 0)
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 0f                	js     801add <getchar+0x29>
		return r;
	if (r < 1)
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	7e 06                	jle    801ad8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ad2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ad6:	eb 05                	jmp    801add <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ad8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ae5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae8:	50                   	push   %eax
  801ae9:	ff 75 08             	pushl  0x8(%ebp)
  801aec:	e8 07 f4 ff ff       	call   800ef8 <fd_lookup>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 11                	js     801b09 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b01:	39 10                	cmp    %edx,(%eax)
  801b03:	0f 94 c0             	sete   %al
  801b06:	0f b6 c0             	movzbl %al,%eax
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <opencons>:

int
opencons(void)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b14:	50                   	push   %eax
  801b15:	e8 8f f3 ff ff       	call   800ea9 <fd_alloc>
  801b1a:	83 c4 10             	add    $0x10,%esp
		return r;
  801b1d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	78 3e                	js     801b61 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b23:	83 ec 04             	sub    $0x4,%esp
  801b26:	68 07 04 00 00       	push   $0x407
  801b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2e:	6a 00                	push   $0x0
  801b30:	e8 d3 f0 ff ff       	call   800c08 <sys_page_alloc>
  801b35:	83 c4 10             	add    $0x10,%esp
		return r;
  801b38:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	78 23                	js     801b61 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b47:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b53:	83 ec 0c             	sub    $0xc,%esp
  801b56:	50                   	push   %eax
  801b57:	e8 26 f3 ff ff       	call   800e82 <fd2num>
  801b5c:	89 c2                	mov    %eax,%edx
  801b5e:	83 c4 10             	add    $0x10,%esp
}
  801b61:	89 d0                	mov    %edx,%eax
  801b63:	c9                   	leave  
  801b64:	c3                   	ret    

00801b65 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b6d:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	ff 75 0c             	pushl  0xc(%ebp)
  801b76:	e8 3d f2 ff ff       	call   800db8 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801b7b:	83 c4 10             	add    $0x10,%esp
  801b7e:	85 f6                	test   %esi,%esi
  801b80:	74 1c                	je     801b9e <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801b82:	a1 04 40 80 00       	mov    0x804004,%eax
  801b87:	8b 40 78             	mov    0x78(%eax),%eax
  801b8a:	89 06                	mov    %eax,(%esi)
  801b8c:	eb 10                	jmp    801b9e <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801b8e:	83 ec 0c             	sub    $0xc,%esp
  801b91:	68 56 24 80 00       	push   $0x802456
  801b96:	e8 9b e6 ff ff       	call   800236 <cprintf>
  801b9b:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801b9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba3:	8b 50 74             	mov    0x74(%eax),%edx
  801ba6:	85 d2                	test   %edx,%edx
  801ba8:	74 e4                	je     801b8e <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801baa:	85 db                	test   %ebx,%ebx
  801bac:	74 05                	je     801bb3 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801bae:	8b 40 74             	mov    0x74(%eax),%eax
  801bb1:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801bb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb8:	8b 40 70             	mov    0x70(%eax),%eax

}
  801bbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbe:	5b                   	pop    %ebx
  801bbf:	5e                   	pop    %esi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	57                   	push   %edi
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801bd4:	85 db                	test   %ebx,%ebx
  801bd6:	75 13                	jne    801beb <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801bd8:	6a 00                	push   $0x0
  801bda:	68 00 00 c0 ee       	push   $0xeec00000
  801bdf:	56                   	push   %esi
  801be0:	57                   	push   %edi
  801be1:	e8 af f1 ff ff       	call   800d95 <sys_ipc_try_send>
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	eb 0e                	jmp    801bf9 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801beb:	ff 75 14             	pushl  0x14(%ebp)
  801bee:	53                   	push   %ebx
  801bef:	56                   	push   %esi
  801bf0:	57                   	push   %edi
  801bf1:	e8 9f f1 ff ff       	call   800d95 <sys_ipc_try_send>
  801bf6:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801bf9:	85 c0                	test   %eax,%eax
  801bfb:	75 d7                	jne    801bd4 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c10:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c13:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c19:	8b 52 50             	mov    0x50(%edx),%edx
  801c1c:	39 ca                	cmp    %ecx,%edx
  801c1e:	75 0d                	jne    801c2d <ipc_find_env+0x28>
			return envs[i].env_id;
  801c20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c28:	8b 40 48             	mov    0x48(%eax),%eax
  801c2b:	eb 0f                	jmp    801c3c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c2d:	83 c0 01             	add    $0x1,%eax
  801c30:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c35:	75 d9                	jne    801c10 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c44:	89 d0                	mov    %edx,%eax
  801c46:	c1 e8 16             	shr    $0x16,%eax
  801c49:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c50:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c55:	f6 c1 01             	test   $0x1,%cl
  801c58:	74 1d                	je     801c77 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c5a:	c1 ea 0c             	shr    $0xc,%edx
  801c5d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c64:	f6 c2 01             	test   $0x1,%dl
  801c67:	74 0e                	je     801c77 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c69:	c1 ea 0c             	shr    $0xc,%edx
  801c6c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c73:	ef 
  801c74:	0f b7 c0             	movzwl %ax,%eax
}
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__udivdi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 f6                	test   %esi,%esi
  801c99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9d:	89 ca                	mov    %ecx,%edx
  801c9f:	89 f8                	mov    %edi,%eax
  801ca1:	75 3d                	jne    801ce0 <__udivdi3+0x60>
  801ca3:	39 cf                	cmp    %ecx,%edi
  801ca5:	0f 87 c5 00 00 00    	ja     801d70 <__udivdi3+0xf0>
  801cab:	85 ff                	test   %edi,%edi
  801cad:	89 fd                	mov    %edi,%ebp
  801caf:	75 0b                	jne    801cbc <__udivdi3+0x3c>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	31 d2                	xor    %edx,%edx
  801cb8:	f7 f7                	div    %edi
  801cba:	89 c5                	mov    %eax,%ebp
  801cbc:	89 c8                	mov    %ecx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	f7 f5                	div    %ebp
  801cc2:	89 c1                	mov    %eax,%ecx
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	89 cf                	mov    %ecx,%edi
  801cc8:	f7 f5                	div    %ebp
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	39 ce                	cmp    %ecx,%esi
  801ce2:	77 74                	ja     801d58 <__udivdi3+0xd8>
  801ce4:	0f bd fe             	bsr    %esi,%edi
  801ce7:	83 f7 1f             	xor    $0x1f,%edi
  801cea:	0f 84 98 00 00 00    	je     801d88 <__udivdi3+0x108>
  801cf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	89 c5                	mov    %eax,%ebp
  801cf9:	29 fb                	sub    %edi,%ebx
  801cfb:	d3 e6                	shl    %cl,%esi
  801cfd:	89 d9                	mov    %ebx,%ecx
  801cff:	d3 ed                	shr    %cl,%ebp
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e0                	shl    %cl,%eax
  801d05:	09 ee                	or     %ebp,%esi
  801d07:	89 d9                	mov    %ebx,%ecx
  801d09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0d:	89 d5                	mov    %edx,%ebp
  801d0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d13:	d3 ed                	shr    %cl,%ebp
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e2                	shl    %cl,%edx
  801d19:	89 d9                	mov    %ebx,%ecx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	09 c2                	or     %eax,%edx
  801d1f:	89 d0                	mov    %edx,%eax
  801d21:	89 ea                	mov    %ebp,%edx
  801d23:	f7 f6                	div    %esi
  801d25:	89 d5                	mov    %edx,%ebp
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	f7 64 24 0c          	mull   0xc(%esp)
  801d2d:	39 d5                	cmp    %edx,%ebp
  801d2f:	72 10                	jb     801d41 <__udivdi3+0xc1>
  801d31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e6                	shl    %cl,%esi
  801d39:	39 c6                	cmp    %eax,%esi
  801d3b:	73 07                	jae    801d44 <__udivdi3+0xc4>
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	75 03                	jne    801d44 <__udivdi3+0xc4>
  801d41:	83 eb 01             	sub    $0x1,%ebx
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	31 ff                	xor    %edi,%edi
  801d5a:	31 db                	xor    %ebx,%ebx
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	89 fa                	mov    %edi,%edx
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    
  801d68:	90                   	nop
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	f7 f7                	div    %edi
  801d74:	31 ff                	xor    %edi,%edi
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 fa                	mov    %edi,%edx
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	39 ce                	cmp    %ecx,%esi
  801d8a:	72 0c                	jb     801d98 <__udivdi3+0x118>
  801d8c:	31 db                	xor    %ebx,%ebx
  801d8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d92:	0f 87 34 ff ff ff    	ja     801ccc <__udivdi3+0x4c>
  801d98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d9d:	e9 2a ff ff ff       	jmp    801ccc <__udivdi3+0x4c>
  801da2:	66 90                	xchg   %ax,%ax
  801da4:	66 90                	xchg   %ax,%ax
  801da6:	66 90                	xchg   %ax,%ax
  801da8:	66 90                	xchg   %ax,%ax
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 d2                	test   %edx,%edx
  801dc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dd1:	89 f3                	mov    %esi,%ebx
  801dd3:	89 3c 24             	mov    %edi,(%esp)
  801dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dda:	75 1c                	jne    801df8 <__umoddi3+0x48>
  801ddc:	39 f7                	cmp    %esi,%edi
  801dde:	76 50                	jbe    801e30 <__umoddi3+0x80>
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	f7 f7                	div    %edi
  801de6:	89 d0                	mov    %edx,%eax
  801de8:	31 d2                	xor    %edx,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	39 f2                	cmp    %esi,%edx
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	77 52                	ja     801e50 <__umoddi3+0xa0>
  801dfe:	0f bd ea             	bsr    %edx,%ebp
  801e01:	83 f5 1f             	xor    $0x1f,%ebp
  801e04:	75 5a                	jne    801e60 <__umoddi3+0xb0>
  801e06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	39 0c 24             	cmp    %ecx,(%esp)
  801e13:	0f 86 d7 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e21:	83 c4 1c             	add    $0x1c,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	85 ff                	test   %edi,%edi
  801e32:	89 fd                	mov    %edi,%ebp
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 f0                	mov    %esi,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 c8                	mov    %ecx,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	eb 99                	jmp    801de8 <__umoddi3+0x38>
  801e4f:	90                   	nop
  801e50:	89 c8                	mov    %ecx,%eax
  801e52:	89 f2                	mov    %esi,%edx
  801e54:	83 c4 1c             	add    $0x1c,%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    
  801e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e60:	8b 34 24             	mov    (%esp),%esi
  801e63:	bf 20 00 00 00       	mov    $0x20,%edi
  801e68:	89 e9                	mov    %ebp,%ecx
  801e6a:	29 ef                	sub    %ebp,%edi
  801e6c:	d3 e0                	shl    %cl,%eax
  801e6e:	89 f9                	mov    %edi,%ecx
  801e70:	89 f2                	mov    %esi,%edx
  801e72:	d3 ea                	shr    %cl,%edx
  801e74:	89 e9                	mov    %ebp,%ecx
  801e76:	09 c2                	or     %eax,%edx
  801e78:	89 d8                	mov    %ebx,%eax
  801e7a:	89 14 24             	mov    %edx,(%esp)
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	d3 e2                	shl    %cl,%edx
  801e81:	89 f9                	mov    %edi,%ecx
  801e83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e8b:	d3 e8                	shr    %cl,%eax
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	89 c6                	mov    %eax,%esi
  801e91:	d3 e3                	shl    %cl,%ebx
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 d0                	mov    %edx,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	09 d8                	or     %ebx,%eax
  801e9d:	89 d3                	mov    %edx,%ebx
  801e9f:	89 f2                	mov    %esi,%edx
  801ea1:	f7 34 24             	divl   (%esp)
  801ea4:	89 d6                	mov    %edx,%esi
  801ea6:	d3 e3                	shl    %cl,%ebx
  801ea8:	f7 64 24 04          	mull   0x4(%esp)
  801eac:	39 d6                	cmp    %edx,%esi
  801eae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb2:	89 d1                	mov    %edx,%ecx
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	72 08                	jb     801ec0 <__umoddi3+0x110>
  801eb8:	75 11                	jne    801ecb <__umoddi3+0x11b>
  801eba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ebe:	73 0b                	jae    801ecb <__umoddi3+0x11b>
  801ec0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ec4:	1b 14 24             	sbb    (%esp),%edx
  801ec7:	89 d1                	mov    %edx,%ecx
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ecf:	29 da                	sub    %ebx,%edx
  801ed1:	19 ce                	sbb    %ecx,%esi
  801ed3:	89 f9                	mov    %edi,%ecx
  801ed5:	89 f0                	mov    %esi,%eax
  801ed7:	d3 e0                	shl    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	d3 ea                	shr    %cl,%edx
  801edd:	89 e9                	mov    %ebp,%ecx
  801edf:	d3 ee                	shr    %cl,%esi
  801ee1:	09 d0                	or     %edx,%eax
  801ee3:	89 f2                	mov    %esi,%edx
  801ee5:	83 c4 1c             	add    $0x1c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 f9                	sub    %edi,%ecx
  801ef2:	19 d6                	sbb    %edx,%esi
  801ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801efc:	e9 18 ff ff ff       	jmp    801e19 <__umoddi3+0x69>
