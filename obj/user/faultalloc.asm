
obj/user/faultalloc:     file format elf32-i386


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
  800040:	68 40 11 80 00       	push   $0x801140
  800045:	e8 e4 01 00 00       	call   80022e <cprintf>
	cprintf("\t in handler:\n");
  80004a:	c7 04 24 4a 11 80 00 	movl   $0x80114a,(%esp)
  800051:	e8 d8 01 00 00       	call   80022e <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	6a 07                	push   $0x7
  80005b:	89 d8                	mov    %ebx,%eax
  80005d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800062:	50                   	push   %eax
  800063:	6a 00                	push   $0x0
  800065:	e8 96 0b 00 00       	call   800c00 <sys_page_alloc>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	85 c0                	test   %eax,%eax
  80006f:	79 16                	jns    800087 <handler+0x54>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800071:	83 ec 0c             	sub    $0xc,%esp
  800074:	50                   	push   %eax
  800075:	53                   	push   %ebx
  800076:	68 9c 11 80 00       	push   $0x80119c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 59 11 80 00       	push   $0x801159
  800082:	e8 ce 00 00 00       	call   800155 <_panic>
	cprintf("\t !!before snprintf.\n");
  800087:	83 ec 0c             	sub    $0xc,%esp
  80008a:	68 6b 11 80 00       	push   $0x80116b
  80008f:	e8 9a 01 00 00       	call   80022e <cprintf>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800094:	53                   	push   %ebx
  800095:	68 c8 11 80 00       	push   $0x8011c8
  80009a:	6a 64                	push   $0x64
  80009c:	53                   	push   %ebx
  80009d:	e8 08 07 00 00       	call   8007aa <snprintf>
	cprintf("%s\n",addr);
  8000a2:	83 c4 18             	add    $0x18,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	68 81 11 80 00       	push   $0x801181
  8000ab:	e8 7e 01 00 00       	call   80022e <cprintf>
	cprintf("\t !!after snprintf.\n");
  8000b0:	c7 04 24 85 11 80 00 	movl   $0x801185,(%esp)
  8000b7:	e8 72 01 00 00       	call   80022e <cprintf>
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
  8000cf:	e8 db 0c 00 00       	call   800daf <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000d4:	83 c4 08             	add    $0x8,%esp
  8000d7:	68 ef be ad de       	push   $0xdeadbeef
  8000dc:	68 81 11 80 00       	push   $0x801181
  8000e1:	e8 48 01 00 00       	call   80022e <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000e6:	83 c4 08             	add    $0x8,%esp
  8000e9:	68 fe bf fe ca       	push   $0xcafebffe
  8000ee:	68 81 11 80 00       	push   $0x801181
  8000f3:	e8 36 01 00 00       	call   80022e <cprintf>
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
  800108:	e8 b5 0a 00 00       	call   800bc2 <sys_getenvid>
  80010d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800112:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800115:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011f:	85 db                	test   %ebx,%ebx
  800121:	7e 07                	jle    80012a <libmain+0x2d>
		binaryname = argv[0];
  800123:	8b 06                	mov    (%esi),%eax
  800125:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800146:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800149:	6a 00                	push   $0x0
  80014b:	e8 31 0a 00 00       	call   800b81 <sys_env_destroy>
}
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800163:	e8 5a 0a 00 00       	call   800bc2 <sys_getenvid>
  800168:	83 ec 0c             	sub    $0xc,%esp
  80016b:	ff 75 0c             	pushl  0xc(%ebp)
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	56                   	push   %esi
  800172:	50                   	push   %eax
  800173:	68 f4 11 80 00       	push   $0x8011f4
  800178:	e8 b1 00 00 00       	call   80022e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017d:	83 c4 18             	add    $0x18,%esp
  800180:	53                   	push   %ebx
  800181:	ff 75 10             	pushl  0x10(%ebp)
  800184:	e8 54 00 00 00       	call   8001dd <vcprintf>
	cprintf("\n");
  800189:	c7 04 24 84 15 80 00 	movl   $0x801584,(%esp)
  800190:	e8 99 00 00 00       	call   80022e <cprintf>
  800195:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800198:	cc                   	int3   
  800199:	eb fd                	jmp    800198 <_panic+0x43>

0080019b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	83 ec 04             	sub    $0x4,%esp
  8001a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a5:	8b 13                	mov    (%ebx),%edx
  8001a7:	8d 42 01             	lea    0x1(%edx),%eax
  8001aa:	89 03                	mov    %eax,(%ebx)
  8001ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b8:	75 1a                	jne    8001d4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	68 ff 00 00 00       	push   $0xff
  8001c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c5:	50                   	push   %eax
  8001c6:	e8 79 09 00 00       	call   800b44 <sys_cputs>
		b->idx = 0;
  8001cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    

008001dd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ed:	00 00 00 
	b.cnt = 0;
  8001f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	ff 75 08             	pushl  0x8(%ebp)
  800200:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	68 9b 01 80 00       	push   $0x80019b
  80020c:	e8 54 01 00 00       	call   800365 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800211:	83 c4 08             	add    $0x8,%esp
  800214:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800220:	50                   	push   %eax
  800221:	e8 1e 09 00 00       	call   800b44 <sys_cputs>

	return b.cnt;
}
  800226:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800234:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800237:	50                   	push   %eax
  800238:	ff 75 08             	pushl  0x8(%ebp)
  80023b:	e8 9d ff ff ff       	call   8001dd <vcprintf>
	va_end(ap);

	return cnt;
}
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	57                   	push   %edi
  800246:	56                   	push   %esi
  800247:	53                   	push   %ebx
  800248:	83 ec 1c             	sub    $0x1c,%esp
  80024b:	89 c7                	mov    %eax,%edi
  80024d:	89 d6                	mov    %edx,%esi
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	8b 55 0c             	mov    0xc(%ebp),%edx
  800255:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800258:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800263:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800266:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800269:	39 d3                	cmp    %edx,%ebx
  80026b:	72 05                	jb     800272 <printnum+0x30>
  80026d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800270:	77 45                	ja     8002b7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	ff 75 18             	pushl  0x18(%ebp)
  800278:	8b 45 14             	mov    0x14(%ebp),%eax
  80027b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80027e:	53                   	push   %ebx
  80027f:	ff 75 10             	pushl  0x10(%ebp)
  800282:	83 ec 08             	sub    $0x8,%esp
  800285:	ff 75 e4             	pushl  -0x1c(%ebp)
  800288:	ff 75 e0             	pushl  -0x20(%ebp)
  80028b:	ff 75 dc             	pushl  -0x24(%ebp)
  80028e:	ff 75 d8             	pushl  -0x28(%ebp)
  800291:	e8 0a 0c 00 00       	call   800ea0 <__udivdi3>
  800296:	83 c4 18             	add    $0x18,%esp
  800299:	52                   	push   %edx
  80029a:	50                   	push   %eax
  80029b:	89 f2                	mov    %esi,%edx
  80029d:	89 f8                	mov    %edi,%eax
  80029f:	e8 9e ff ff ff       	call   800242 <printnum>
  8002a4:	83 c4 20             	add    $0x20,%esp
  8002a7:	eb 18                	jmp    8002c1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	ff 75 18             	pushl  0x18(%ebp)
  8002b0:	ff d7                	call   *%edi
  8002b2:	83 c4 10             	add    $0x10,%esp
  8002b5:	eb 03                	jmp    8002ba <printnum+0x78>
  8002b7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ba:	83 eb 01             	sub    $0x1,%ebx
  8002bd:	85 db                	test   %ebx,%ebx
  8002bf:	7f e8                	jg     8002a9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	56                   	push   %esi
  8002c5:	83 ec 04             	sub    $0x4,%esp
  8002c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d4:	e8 f7 0c 00 00       	call   800fd0 <__umoddi3>
  8002d9:	83 c4 14             	add    $0x14,%esp
  8002dc:	0f be 80 17 12 80 00 	movsbl 0x801217(%eax),%eax
  8002e3:	50                   	push   %eax
  8002e4:	ff d7                	call   *%edi
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f4:	83 fa 01             	cmp    $0x1,%edx
  8002f7:	7e 0e                	jle    800307 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	8b 52 04             	mov    0x4(%edx),%edx
  800305:	eb 22                	jmp    800329 <getuint+0x38>
	else if (lflag)
  800307:	85 d2                	test   %edx,%edx
  800309:	74 10                	je     80031b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	ba 00 00 00 00       	mov    $0x0,%edx
  800319:	eb 0e                	jmp    800329 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800320:	89 08                	mov    %ecx,(%eax)
  800322:	8b 02                	mov    (%edx),%eax
  800324:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800331:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800335:	8b 10                	mov    (%eax),%edx
  800337:	3b 50 04             	cmp    0x4(%eax),%edx
  80033a:	73 0a                	jae    800346 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 45 08             	mov    0x8(%ebp),%eax
  800344:	88 02                	mov    %al,(%edx)
}
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800351:	50                   	push   %eax
  800352:	ff 75 10             	pushl  0x10(%ebp)
  800355:	ff 75 0c             	pushl  0xc(%ebp)
  800358:	ff 75 08             	pushl  0x8(%ebp)
  80035b:	e8 05 00 00 00       	call   800365 <vprintfmt>
	va_end(ap);
}
  800360:	83 c4 10             	add    $0x10,%esp
  800363:	c9                   	leave  
  800364:	c3                   	ret    

00800365 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
  80036b:	83 ec 2c             	sub    $0x2c,%esp
  80036e:	8b 75 08             	mov    0x8(%ebp),%esi
  800371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800374:	8b 7d 10             	mov    0x10(%ebp),%edi
  800377:	eb 12                	jmp    80038b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800379:	85 c0                	test   %eax,%eax
  80037b:	0f 84 d3 03 00 00    	je     800754 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	50                   	push   %eax
  800386:	ff d6                	call   *%esi
  800388:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038b:	83 c7 01             	add    $0x1,%edi
  80038e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800392:	83 f8 25             	cmp    $0x25,%eax
  800395:	75 e2                	jne    800379 <vprintfmt+0x14>
  800397:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003a9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b5:	eb 07                	jmp    8003be <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ba:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8d 47 01             	lea    0x1(%edi),%eax
  8003c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c4:	0f b6 07             	movzbl (%edi),%eax
  8003c7:	0f b6 c8             	movzbl %al,%ecx
  8003ca:	83 e8 23             	sub    $0x23,%eax
  8003cd:	3c 55                	cmp    $0x55,%al
  8003cf:	0f 87 64 03 00 00    	ja     800739 <vprintfmt+0x3d4>
  8003d5:	0f b6 c0             	movzbl %al,%eax
  8003d8:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e6:	eb d6                	jmp    8003be <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003fd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800400:	83 fa 09             	cmp    $0x9,%edx
  800403:	77 39                	ja     80043e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800405:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800408:	eb e9                	jmp    8003f3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 48 04             	lea    0x4(%eax),%ecx
  800410:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041b:	eb 27                	jmp    800444 <vprintfmt+0xdf>
  80041d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800420:	85 c0                	test   %eax,%eax
  800422:	b9 00 00 00 00       	mov    $0x0,%ecx
  800427:	0f 49 c8             	cmovns %eax,%ecx
  80042a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800430:	eb 8c                	jmp    8003be <vprintfmt+0x59>
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800435:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043c:	eb 80                	jmp    8003be <vprintfmt+0x59>
  80043e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800441:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800444:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800448:	0f 89 70 ff ff ff    	jns    8003be <vprintfmt+0x59>
				width = precision, precision = -1;
  80044e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800451:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800454:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80045b:	e9 5e ff ff ff       	jmp    8003be <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800460:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800466:	e9 53 ff ff ff       	jmp    8003be <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8d 50 04             	lea    0x4(%eax),%edx
  800471:	89 55 14             	mov    %edx,0x14(%ebp)
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	53                   	push   %ebx
  800478:	ff 30                	pushl  (%eax)
  80047a:	ff d6                	call   *%esi
			break;
  80047c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800482:	e9 04 ff ff ff       	jmp    80038b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 50 04             	lea    0x4(%eax),%edx
  80048d:	89 55 14             	mov    %edx,0x14(%ebp)
  800490:	8b 00                	mov    (%eax),%eax
  800492:	99                   	cltd   
  800493:	31 d0                	xor    %edx,%eax
  800495:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800497:	83 f8 08             	cmp    $0x8,%eax
  80049a:	7f 0b                	jg     8004a7 <vprintfmt+0x142>
  80049c:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  8004a3:	85 d2                	test   %edx,%edx
  8004a5:	75 18                	jne    8004bf <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a7:	50                   	push   %eax
  8004a8:	68 2f 12 80 00       	push   $0x80122f
  8004ad:	53                   	push   %ebx
  8004ae:	56                   	push   %esi
  8004af:	e8 94 fe ff ff       	call   800348 <printfmt>
  8004b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ba:	e9 cc fe ff ff       	jmp    80038b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004bf:	52                   	push   %edx
  8004c0:	68 38 12 80 00       	push   $0x801238
  8004c5:	53                   	push   %ebx
  8004c6:	56                   	push   %esi
  8004c7:	e8 7c fe ff ff       	call   800348 <printfmt>
  8004cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d2:	e9 b4 fe ff ff       	jmp    80038b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8d 50 04             	lea    0x4(%eax),%edx
  8004dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e2:	85 ff                	test   %edi,%edi
  8004e4:	b8 28 12 80 00       	mov    $0x801228,%eax
  8004e9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f0:	0f 8e 94 00 00 00    	jle    80058a <vprintfmt+0x225>
  8004f6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fa:	0f 84 98 00 00 00    	je     800598 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	ff 75 c8             	pushl  -0x38(%ebp)
  800506:	57                   	push   %edi
  800507:	e8 d0 02 00 00       	call   8007dc <strnlen>
  80050c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050f:	29 c1                	sub    %eax,%ecx
  800511:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800517:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800521:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800523:	eb 0f                	jmp    800534 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	ff 75 e0             	pushl  -0x20(%ebp)
  80052c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052e:	83 ef 01             	sub    $0x1,%edi
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	85 ff                	test   %edi,%edi
  800536:	7f ed                	jg     800525 <vprintfmt+0x1c0>
  800538:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80053e:	85 c9                	test   %ecx,%ecx
  800540:	b8 00 00 00 00       	mov    $0x0,%eax
  800545:	0f 49 c1             	cmovns %ecx,%eax
  800548:	29 c1                	sub    %eax,%ecx
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	89 cb                	mov    %ecx,%ebx
  800555:	eb 4d                	jmp    8005a4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800557:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055b:	74 1b                	je     800578 <vprintfmt+0x213>
  80055d:	0f be c0             	movsbl %al,%eax
  800560:	83 e8 20             	sub    $0x20,%eax
  800563:	83 f8 5e             	cmp    $0x5e,%eax
  800566:	76 10                	jbe    800578 <vprintfmt+0x213>
					putch('?', putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	6a 3f                	push   $0x3f
  800570:	ff 55 08             	call   *0x8(%ebp)
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	eb 0d                	jmp    800585 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	ff 75 0c             	pushl  0xc(%ebp)
  80057e:	52                   	push   %edx
  80057f:	ff 55 08             	call   *0x8(%ebp)
  800582:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800585:	83 eb 01             	sub    $0x1,%ebx
  800588:	eb 1a                	jmp    8005a4 <vprintfmt+0x23f>
  80058a:	89 75 08             	mov    %esi,0x8(%ebp)
  80058d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800590:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800593:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800596:	eb 0c                	jmp    8005a4 <vprintfmt+0x23f>
  800598:	89 75 08             	mov    %esi,0x8(%ebp)
  80059b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80059e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a4:	83 c7 01             	add    $0x1,%edi
  8005a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ab:	0f be d0             	movsbl %al,%edx
  8005ae:	85 d2                	test   %edx,%edx
  8005b0:	74 23                	je     8005d5 <vprintfmt+0x270>
  8005b2:	85 f6                	test   %esi,%esi
  8005b4:	78 a1                	js     800557 <vprintfmt+0x1f2>
  8005b6:	83 ee 01             	sub    $0x1,%esi
  8005b9:	79 9c                	jns    800557 <vprintfmt+0x1f2>
  8005bb:	89 df                	mov    %ebx,%edi
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c3:	eb 18                	jmp    8005dd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	6a 20                	push   $0x20
  8005cb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cd:	83 ef 01             	sub    $0x1,%edi
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	eb 08                	jmp    8005dd <vprintfmt+0x278>
  8005d5:	89 df                	mov    %ebx,%edi
  8005d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005dd:	85 ff                	test   %edi,%edi
  8005df:	7f e4                	jg     8005c5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e4:	e9 a2 fd ff ff       	jmp    80038b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e9:	83 fa 01             	cmp    $0x1,%edx
  8005ec:	7e 16                	jle    800604 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 08             	lea    0x8(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 50 04             	mov    0x4(%eax),%edx
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ff:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800602:	eb 32                	jmp    800636 <vprintfmt+0x2d1>
	else if (lflag)
  800604:	85 d2                	test   %edx,%edx
  800606:	74 18                	je     800620 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 00                	mov    (%eax),%eax
  800613:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800616:	89 c1                	mov    %eax,%ecx
  800618:	c1 f9 1f             	sar    $0x1f,%ecx
  80061b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80061e:	eb 16                	jmp    800636 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	8b 00                	mov    (%eax),%eax
  80062b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80062e:	89 c1                	mov    %eax,%ecx
  800630:	c1 f9 1f             	sar    $0x1f,%ecx
  800633:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800636:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800639:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800647:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80064b:	0f 89 b0 00 00 00    	jns    800701 <vprintfmt+0x39c>
				putch('-', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 2d                	push   $0x2d
  800657:	ff d6                	call   *%esi
				num = -(long long) num;
  800659:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80065c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80065f:	f7 d8                	neg    %eax
  800661:	83 d2 00             	adc    $0x0,%edx
  800664:	f7 da                	neg    %edx
  800666:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800669:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 88 00 00 00       	jmp    800701 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 70 fc ff ff       	call   8002f1 <getuint>
  800681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800684:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800687:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068c:	eb 73                	jmp    800701 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 5b fc ff ff       	call   8002f1 <getuint>
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 58                	push   $0x58
  8006a2:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a4:	83 c4 08             	add    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 58                	push   $0x58
  8006aa:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ac:	83 c4 08             	add    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 58                	push   $0x58
  8006b2:	ff d6                	call   *%esi
			goto number;
  8006b4:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006b7:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006bc:	eb 43                	jmp    800701 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 30                	push   $0x30
  8006c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c6:	83 c4 08             	add    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 78                	push   $0x78
  8006cc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8d 50 04             	lea    0x4(%eax),%edx
  8006d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ec:	eb 13                	jmp    800701 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f1:	e8 fb fb ff ff       	call   8002f1 <getuint>
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006fc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800701:	83 ec 0c             	sub    $0xc,%esp
  800704:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800708:	52                   	push   %edx
  800709:	ff 75 e0             	pushl  -0x20(%ebp)
  80070c:	50                   	push   %eax
  80070d:	ff 75 dc             	pushl  -0x24(%ebp)
  800710:	ff 75 d8             	pushl  -0x28(%ebp)
  800713:	89 da                	mov    %ebx,%edx
  800715:	89 f0                	mov    %esi,%eax
  800717:	e8 26 fb ff ff       	call   800242 <printnum>
			break;
  80071c:	83 c4 20             	add    $0x20,%esp
  80071f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800722:	e9 64 fc ff ff       	jmp    80038b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	51                   	push   %ecx
  80072c:	ff d6                	call   *%esi
			break;
  80072e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800734:	e9 52 fc ff ff       	jmp    80038b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	6a 25                	push   $0x25
  80073f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	eb 03                	jmp    800749 <vprintfmt+0x3e4>
  800746:	83 ef 01             	sub    $0x1,%edi
  800749:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074d:	75 f7                	jne    800746 <vprintfmt+0x3e1>
  80074f:	e9 37 fc ff ff       	jmp    80038b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800754:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800757:	5b                   	pop    %ebx
  800758:	5e                   	pop    %esi
  800759:	5f                   	pop    %edi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 18             	sub    $0x18,%esp
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  800765:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800768:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800779:	85 c0                	test   %eax,%eax
  80077b:	74 26                	je     8007a3 <vsnprintf+0x47>
  80077d:	85 d2                	test   %edx,%edx
  80077f:	7e 22                	jle    8007a3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800781:	ff 75 14             	pushl  0x14(%ebp)
  800784:	ff 75 10             	pushl  0x10(%ebp)
  800787:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078a:	50                   	push   %eax
  80078b:	68 2b 03 80 00       	push   $0x80032b
  800790:	e8 d0 fb ff ff       	call   800365 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800795:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800798:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb 05                	jmp    8007a8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a8:	c9                   	leave  
  8007a9:	c3                   	ret    

008007aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b3:	50                   	push   %eax
  8007b4:	ff 75 10             	pushl  0x10(%ebp)
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	ff 75 08             	pushl  0x8(%ebp)
  8007bd:	e8 9a ff ff ff       	call   80075c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    

008007c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cf:	eb 03                	jmp    8007d4 <strlen+0x10>
		n++;
  8007d1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d8:	75 f7                	jne    8007d1 <strlen+0xd>
		n++;
	return n;
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ea:	eb 03                	jmp    8007ef <strnlen+0x13>
		n++;
  8007ec:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	39 c2                	cmp    %eax,%edx
  8007f1:	74 08                	je     8007fb <strnlen+0x1f>
  8007f3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f7:	75 f3                	jne    8007ec <strnlen+0x10>
  8007f9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800807:	89 c2                	mov    %eax,%edx
  800809:	83 c2 01             	add    $0x1,%edx
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800813:	88 5a ff             	mov    %bl,-0x1(%edx)
  800816:	84 db                	test   %bl,%bl
  800818:	75 ef                	jne    800809 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081a:	5b                   	pop    %ebx
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	53                   	push   %ebx
  800821:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800824:	53                   	push   %ebx
  800825:	e8 9a ff ff ff       	call   8007c4 <strlen>
  80082a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082d:	ff 75 0c             	pushl  0xc(%ebp)
  800830:	01 d8                	add    %ebx,%eax
  800832:	50                   	push   %eax
  800833:	e8 c5 ff ff ff       	call   8007fd <strcpy>
	return dst;
}
  800838:	89 d8                	mov    %ebx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 75 08             	mov    0x8(%ebp),%esi
  800847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084a:	89 f3                	mov    %esi,%ebx
  80084c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084f:	89 f2                	mov    %esi,%edx
  800851:	eb 0f                	jmp    800862 <strncpy+0x23>
		*dst++ = *src;
  800853:	83 c2 01             	add    $0x1,%edx
  800856:	0f b6 01             	movzbl (%ecx),%eax
  800859:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085c:	80 39 01             	cmpb   $0x1,(%ecx)
  80085f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	39 da                	cmp    %ebx,%edx
  800864:	75 ed                	jne    800853 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800866:	89 f0                	mov    %esi,%eax
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	8b 55 10             	mov    0x10(%ebp),%edx
  80087a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087c:	85 d2                	test   %edx,%edx
  80087e:	74 21                	je     8008a1 <strlcpy+0x35>
  800880:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800884:	89 f2                	mov    %esi,%edx
  800886:	eb 09                	jmp    800891 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800888:	83 c2 01             	add    $0x1,%edx
  80088b:	83 c1 01             	add    $0x1,%ecx
  80088e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800891:	39 c2                	cmp    %eax,%edx
  800893:	74 09                	je     80089e <strlcpy+0x32>
  800895:	0f b6 19             	movzbl (%ecx),%ebx
  800898:	84 db                	test   %bl,%bl
  80089a:	75 ec                	jne    800888 <strlcpy+0x1c>
  80089c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a1:	29 f0                	sub    %esi,%eax
}
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strcmp+0x11>
		p++, q++;
  8008b2:	83 c1 01             	add    $0x1,%ecx
  8008b5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b8:	0f b6 01             	movzbl (%ecx),%eax
  8008bb:	84 c0                	test   %al,%al
  8008bd:	74 04                	je     8008c3 <strcmp+0x1c>
  8008bf:	3a 02                	cmp    (%edx),%al
  8008c1:	74 ef                	je     8008b2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 c0             	movzbl %al,%eax
  8008c6:	0f b6 12             	movzbl (%edx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	53                   	push   %ebx
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d7:	89 c3                	mov    %eax,%ebx
  8008d9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008dc:	eb 06                	jmp    8008e4 <strncmp+0x17>
		n--, p++, q++;
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e4:	39 d8                	cmp    %ebx,%eax
  8008e6:	74 15                	je     8008fd <strncmp+0x30>
  8008e8:	0f b6 08             	movzbl (%eax),%ecx
  8008eb:	84 c9                	test   %cl,%cl
  8008ed:	74 04                	je     8008f3 <strncmp+0x26>
  8008ef:	3a 0a                	cmp    (%edx),%cl
  8008f1:	74 eb                	je     8008de <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f3:	0f b6 00             	movzbl (%eax),%eax
  8008f6:	0f b6 12             	movzbl (%edx),%edx
  8008f9:	29 d0                	sub    %edx,%eax
  8008fb:	eb 05                	jmp    800902 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800902:	5b                   	pop    %ebx
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090f:	eb 07                	jmp    800918 <strchr+0x13>
		if (*s == c)
  800911:	38 ca                	cmp    %cl,%dl
  800913:	74 0f                	je     800924 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f2                	jne    800911 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800930:	eb 03                	jmp    800935 <strfind+0xf>
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800938:	38 ca                	cmp    %cl,%dl
  80093a:	74 04                	je     800940 <strfind+0x1a>
  80093c:	84 d2                	test   %dl,%dl
  80093e:	75 f2                	jne    800932 <strfind+0xc>
			break;
	return (char *) s;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	57                   	push   %edi
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094e:	85 c9                	test   %ecx,%ecx
  800950:	74 36                	je     800988 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800952:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800958:	75 28                	jne    800982 <memset+0x40>
  80095a:	f6 c1 03             	test   $0x3,%cl
  80095d:	75 23                	jne    800982 <memset+0x40>
		c &= 0xFF;
  80095f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800963:	89 d3                	mov    %edx,%ebx
  800965:	c1 e3 08             	shl    $0x8,%ebx
  800968:	89 d6                	mov    %edx,%esi
  80096a:	c1 e6 18             	shl    $0x18,%esi
  80096d:	89 d0                	mov    %edx,%eax
  80096f:	c1 e0 10             	shl    $0x10,%eax
  800972:	09 f0                	or     %esi,%eax
  800974:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800976:	89 d8                	mov    %ebx,%eax
  800978:	09 d0                	or     %edx,%eax
  80097a:	c1 e9 02             	shr    $0x2,%ecx
  80097d:	fc                   	cld    
  80097e:	f3 ab                	rep stos %eax,%es:(%edi)
  800980:	eb 06                	jmp    800988 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800982:	8b 45 0c             	mov    0xc(%ebp),%eax
  800985:	fc                   	cld    
  800986:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800988:	89 f8                	mov    %edi,%eax
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	57                   	push   %edi
  800993:	56                   	push   %esi
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099d:	39 c6                	cmp    %eax,%esi
  80099f:	73 35                	jae    8009d6 <memmove+0x47>
  8009a1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a4:	39 d0                	cmp    %edx,%eax
  8009a6:	73 2e                	jae    8009d6 <memmove+0x47>
		s += n;
		d += n;
  8009a8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ab:	89 d6                	mov    %edx,%esi
  8009ad:	09 fe                	or     %edi,%esi
  8009af:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b5:	75 13                	jne    8009ca <memmove+0x3b>
  8009b7:	f6 c1 03             	test   $0x3,%cl
  8009ba:	75 0e                	jne    8009ca <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009bc:	83 ef 04             	sub    $0x4,%edi
  8009bf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
  8009c5:	fd                   	std    
  8009c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c8:	eb 09                	jmp    8009d3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ca:	83 ef 01             	sub    $0x1,%edi
  8009cd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d0:	fd                   	std    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d3:	fc                   	cld    
  8009d4:	eb 1d                	jmp    8009f3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d6:	89 f2                	mov    %esi,%edx
  8009d8:	09 c2                	or     %eax,%edx
  8009da:	f6 c2 03             	test   $0x3,%dl
  8009dd:	75 0f                	jne    8009ee <memmove+0x5f>
  8009df:	f6 c1 03             	test   $0x3,%cl
  8009e2:	75 0a                	jne    8009ee <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e4:	c1 e9 02             	shr    $0x2,%ecx
  8009e7:	89 c7                	mov    %eax,%edi
  8009e9:	fc                   	cld    
  8009ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ec:	eb 05                	jmp    8009f3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ee:	89 c7                	mov    %eax,%edi
  8009f0:	fc                   	cld    
  8009f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f3:	5e                   	pop    %esi
  8009f4:	5f                   	pop    %edi
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fa:	ff 75 10             	pushl  0x10(%ebp)
  8009fd:	ff 75 0c             	pushl  0xc(%ebp)
  800a00:	ff 75 08             	pushl  0x8(%ebp)
  800a03:	e8 87 ff ff ff       	call   80098f <memmove>
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a15:	89 c6                	mov    %eax,%esi
  800a17:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1a:	eb 1a                	jmp    800a36 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1c:	0f b6 08             	movzbl (%eax),%ecx
  800a1f:	0f b6 1a             	movzbl (%edx),%ebx
  800a22:	38 d9                	cmp    %bl,%cl
  800a24:	74 0a                	je     800a30 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a26:	0f b6 c1             	movzbl %cl,%eax
  800a29:	0f b6 db             	movzbl %bl,%ebx
  800a2c:	29 d8                	sub    %ebx,%eax
  800a2e:	eb 0f                	jmp    800a3f <memcmp+0x35>
		s1++, s2++;
  800a30:	83 c0 01             	add    $0x1,%eax
  800a33:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a36:	39 f0                	cmp    %esi,%eax
  800a38:	75 e2                	jne    800a1c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	53                   	push   %ebx
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4a:	89 c1                	mov    %eax,%ecx
  800a4c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a53:	eb 0a                	jmp    800a5f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a55:	0f b6 10             	movzbl (%eax),%edx
  800a58:	39 da                	cmp    %ebx,%edx
  800a5a:	74 07                	je     800a63 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	39 c8                	cmp    %ecx,%eax
  800a61:	72 f2                	jb     800a55 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a63:	5b                   	pop    %ebx
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	eb 03                	jmp    800a77 <strtol+0x11>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a77:	0f b6 01             	movzbl (%ecx),%eax
  800a7a:	3c 20                	cmp    $0x20,%al
  800a7c:	74 f6                	je     800a74 <strtol+0xe>
  800a7e:	3c 09                	cmp    $0x9,%al
  800a80:	74 f2                	je     800a74 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a82:	3c 2b                	cmp    $0x2b,%al
  800a84:	75 0a                	jne    800a90 <strtol+0x2a>
		s++;
  800a86:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a89:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8e:	eb 11                	jmp    800aa1 <strtol+0x3b>
  800a90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a95:	3c 2d                	cmp    $0x2d,%al
  800a97:	75 08                	jne    800aa1 <strtol+0x3b>
		s++, neg = 1;
  800a99:	83 c1 01             	add    $0x1,%ecx
  800a9c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa7:	75 15                	jne    800abe <strtol+0x58>
  800aa9:	80 39 30             	cmpb   $0x30,(%ecx)
  800aac:	75 10                	jne    800abe <strtol+0x58>
  800aae:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab2:	75 7c                	jne    800b30 <strtol+0xca>
		s += 2, base = 16;
  800ab4:	83 c1 02             	add    $0x2,%ecx
  800ab7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abc:	eb 16                	jmp    800ad4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800abe:	85 db                	test   %ebx,%ebx
  800ac0:	75 12                	jne    800ad4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aca:	75 08                	jne    800ad4 <strtol+0x6e>
		s++, base = 8;
  800acc:	83 c1 01             	add    $0x1,%ecx
  800acf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800adc:	0f b6 11             	movzbl (%ecx),%edx
  800adf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	80 fb 09             	cmp    $0x9,%bl
  800ae7:	77 08                	ja     800af1 <strtol+0x8b>
			dig = *s - '0';
  800ae9:	0f be d2             	movsbl %dl,%edx
  800aec:	83 ea 30             	sub    $0x30,%edx
  800aef:	eb 22                	jmp    800b13 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 19             	cmp    $0x19,%bl
  800af9:	77 08                	ja     800b03 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800afb:	0f be d2             	movsbl %dl,%edx
  800afe:	83 ea 57             	sub    $0x57,%edx
  800b01:	eb 10                	jmp    800b13 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b03:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 16                	ja     800b23 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b13:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b16:	7d 0b                	jge    800b23 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b18:	83 c1 01             	add    $0x1,%ecx
  800b1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b21:	eb b9                	jmp    800adc <strtol+0x76>

	if (endptr)
  800b23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b27:	74 0d                	je     800b36 <strtol+0xd0>
		*endptr = (char *) s;
  800b29:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2c:	89 0e                	mov    %ecx,(%esi)
  800b2e:	eb 06                	jmp    800b36 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	74 98                	je     800acc <strtol+0x66>
  800b34:	eb 9e                	jmp    800ad4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	f7 da                	neg    %edx
  800b3a:	85 ff                	test   %edi,%edi
  800b3c:	0f 45 c2             	cmovne %edx,%eax
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b94:	8b 55 08             	mov    0x8(%ebp),%edx
  800b97:	89 cb                	mov    %ecx,%ebx
  800b99:	89 cf                	mov    %ecx,%edi
  800b9b:	89 ce                	mov    %ecx,%esi
  800b9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 03                	push   $0x3
  800ba9:	68 64 14 80 00       	push   $0x801464
  800bae:	6a 23                	push   $0x23
  800bb0:	68 81 14 80 00       	push   $0x801481
  800bb5:	e8 9b f5 ff ff       	call   800155 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_yield>:

void
sys_yield(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf1:	89 d1                	mov    %edx,%ecx
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	89 d6                	mov    %edx,%esi
  800bf9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c09:	be 00 00 00 00       	mov    $0x0,%esi
  800c0e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	89 f7                	mov    %esi,%edi
  800c1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7e 17                	jle    800c3b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 04                	push   $0x4
  800c2a:	68 64 14 80 00       	push   $0x801464
  800c2f:	6a 23                	push   $0x23
  800c31:	68 81 14 80 00       	push   $0x801481
  800c36:	e8 1a f5 ff ff       	call   800155 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4c:	b8 05 00 00 00       	mov    $0x5,%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7e 17                	jle    800c7d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	50                   	push   %eax
  800c6a:	6a 05                	push   $0x5
  800c6c:	68 64 14 80 00       	push   $0x801464
  800c71:	6a 23                	push   $0x23
  800c73:	68 81 14 80 00       	push   $0x801481
  800c78:	e8 d8 f4 ff ff       	call   800155 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	b8 06 00 00 00       	mov    $0x6,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 06                	push   $0x6
  800cae:	68 64 14 80 00       	push   $0x801464
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 81 14 80 00       	push   $0x801481
  800cba:	e8 96 f4 ff ff       	call   800155 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7e 17                	jle    800d01 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	50                   	push   %eax
  800cee:	6a 08                	push   $0x8
  800cf0:	68 64 14 80 00       	push   $0x801464
  800cf5:	6a 23                	push   $0x23
  800cf7:	68 81 14 80 00       	push   $0x801481
  800cfc:	e8 54 f4 ff ff       	call   800155 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d17:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	89 df                	mov    %ebx,%edi
  800d24:	89 de                	mov    %ebx,%esi
  800d26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7e 17                	jle    800d43 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	50                   	push   %eax
  800d30:	6a 09                	push   $0x9
  800d32:	68 64 14 80 00       	push   $0x801464
  800d37:	6a 23                	push   $0x23
  800d39:	68 81 14 80 00       	push   $0x801481
  800d3e:	e8 12 f4 ff ff       	call   800155 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d51:	be 00 00 00 00       	mov    $0x0,%esi
  800d56:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7e 17                	jle    800da7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	50                   	push   %eax
  800d94:	6a 0c                	push   $0xc
  800d96:	68 64 14 80 00       	push   $0x801464
  800d9b:	6a 23                	push   $0x23
  800d9d:	68 81 14 80 00       	push   $0x801481
  800da2:	e8 ae f3 ff ff       	call   800155 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  800db5:	68 90 14 80 00       	push   $0x801490
  800dba:	e8 6f f4 ff ff       	call   80022e <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dc9:	0f 85 8d 00 00 00    	jne    800e5c <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	68 b0 14 80 00       	push   $0x8014b0
  800dd7:	e8 52 f4 ff ff       	call   80022e <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  800ddc:	a1 04 20 80 00       	mov    0x802004,%eax
  800de1:	8b 40 48             	mov    0x48(%eax),%eax
  800de4:	83 c4 0c             	add    $0xc,%esp
  800de7:	6a 07                	push   $0x7
  800de9:	68 00 f0 bf ee       	push   $0xeebff000
  800dee:	50                   	push   %eax
  800def:	e8 0c fe ff ff       	call   800c00 <sys_page_alloc>
		if(retv != 0){
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	74 14                	je     800e0f <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  800dfb:	83 ec 04             	sub    $0x4,%esp
  800dfe:	68 d4 14 80 00       	push   $0x8014d4
  800e03:	6a 27                	push   $0x27
  800e05:	68 28 15 80 00       	push   $0x801528
  800e0a:	e8 46 f3 ff ff       	call   800155 <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  800e0f:	83 ec 08             	sub    $0x8,%esp
  800e12:	68 76 0e 80 00       	push   $0x800e76
  800e17:	68 36 15 80 00       	push   $0x801536
  800e1c:	e8 0d f4 ff ff       	call   80022e <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  800e21:	a1 04 20 80 00       	mov    0x802004,%eax
  800e26:	8b 40 48             	mov    0x48(%eax),%eax
  800e29:	83 c4 08             	add    $0x8,%esp
  800e2c:	50                   	push   %eax
  800e2d:	68 51 15 80 00       	push   $0x801551
  800e32:	e8 f7 f3 ff ff       	call   80022e <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800e37:	a1 04 20 80 00       	mov    0x802004,%eax
  800e3c:	8b 40 48             	mov    0x48(%eax),%eax
  800e3f:	83 c4 08             	add    $0x8,%esp
  800e42:	68 76 0e 80 00       	push   $0x800e76
  800e47:	50                   	push   %eax
  800e48:	e8 bc fe ff ff       	call   800d09 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  800e4d:	c7 04 24 68 15 80 00 	movl   $0x801568,(%esp)
  800e54:	e8 d5 f3 ff ff       	call   80022e <cprintf>
  800e59:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  800e5c:	83 ec 0c             	sub    $0xc,%esp
  800e5f:	68 00 15 80 00       	push   $0x801500
  800e64:	e8 c5 f3 ff ff       	call   80022e <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	a3 08 20 80 00       	mov    %eax,0x802008

}
  800e71:	83 c4 10             	add    $0x10,%esp
  800e74:	c9                   	leave  
  800e75:	c3                   	ret    

00800e76 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e76:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e77:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e7c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e7e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  800e81:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  800e83:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  800e87:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800e8b:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  800e8c:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  800e8e:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  800e95:	00 
	popl %eax
  800e96:	58                   	pop    %eax
	popl %eax
  800e97:	58                   	pop    %eax
	popal
  800e98:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  800e99:	83 c4 04             	add    $0x4,%esp
	popfl
  800e9c:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e9d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e9e:	c3                   	ret    
  800e9f:	90                   	nop

00800ea0 <__udivdi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 1c             	sub    $0x1c,%esp
  800ea7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800eab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800eaf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800eb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800eb7:	85 f6                	test   %esi,%esi
  800eb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ebd:	89 ca                	mov    %ecx,%edx
  800ebf:	89 f8                	mov    %edi,%eax
  800ec1:	75 3d                	jne    800f00 <__udivdi3+0x60>
  800ec3:	39 cf                	cmp    %ecx,%edi
  800ec5:	0f 87 c5 00 00 00    	ja     800f90 <__udivdi3+0xf0>
  800ecb:	85 ff                	test   %edi,%edi
  800ecd:	89 fd                	mov    %edi,%ebp
  800ecf:	75 0b                	jne    800edc <__udivdi3+0x3c>
  800ed1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed6:	31 d2                	xor    %edx,%edx
  800ed8:	f7 f7                	div    %edi
  800eda:	89 c5                	mov    %eax,%ebp
  800edc:	89 c8                	mov    %ecx,%eax
  800ede:	31 d2                	xor    %edx,%edx
  800ee0:	f7 f5                	div    %ebp
  800ee2:	89 c1                	mov    %eax,%ecx
  800ee4:	89 d8                	mov    %ebx,%eax
  800ee6:	89 cf                	mov    %ecx,%edi
  800ee8:	f7 f5                	div    %ebp
  800eea:	89 c3                	mov    %eax,%ebx
  800eec:	89 d8                	mov    %ebx,%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	83 c4 1c             	add    $0x1c,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    
  800ef8:	90                   	nop
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	39 ce                	cmp    %ecx,%esi
  800f02:	77 74                	ja     800f78 <__udivdi3+0xd8>
  800f04:	0f bd fe             	bsr    %esi,%edi
  800f07:	83 f7 1f             	xor    $0x1f,%edi
  800f0a:	0f 84 98 00 00 00    	je     800fa8 <__udivdi3+0x108>
  800f10:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f15:	89 f9                	mov    %edi,%ecx
  800f17:	89 c5                	mov    %eax,%ebp
  800f19:	29 fb                	sub    %edi,%ebx
  800f1b:	d3 e6                	shl    %cl,%esi
  800f1d:	89 d9                	mov    %ebx,%ecx
  800f1f:	d3 ed                	shr    %cl,%ebp
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	d3 e0                	shl    %cl,%eax
  800f25:	09 ee                	or     %ebp,%esi
  800f27:	89 d9                	mov    %ebx,%ecx
  800f29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f2d:	89 d5                	mov    %edx,%ebp
  800f2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f33:	d3 ed                	shr    %cl,%ebp
  800f35:	89 f9                	mov    %edi,%ecx
  800f37:	d3 e2                	shl    %cl,%edx
  800f39:	89 d9                	mov    %ebx,%ecx
  800f3b:	d3 e8                	shr    %cl,%eax
  800f3d:	09 c2                	or     %eax,%edx
  800f3f:	89 d0                	mov    %edx,%eax
  800f41:	89 ea                	mov    %ebp,%edx
  800f43:	f7 f6                	div    %esi
  800f45:	89 d5                	mov    %edx,%ebp
  800f47:	89 c3                	mov    %eax,%ebx
  800f49:	f7 64 24 0c          	mull   0xc(%esp)
  800f4d:	39 d5                	cmp    %edx,%ebp
  800f4f:	72 10                	jb     800f61 <__udivdi3+0xc1>
  800f51:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	d3 e6                	shl    %cl,%esi
  800f59:	39 c6                	cmp    %eax,%esi
  800f5b:	73 07                	jae    800f64 <__udivdi3+0xc4>
  800f5d:	39 d5                	cmp    %edx,%ebp
  800f5f:	75 03                	jne    800f64 <__udivdi3+0xc4>
  800f61:	83 eb 01             	sub    $0x1,%ebx
  800f64:	31 ff                	xor    %edi,%edi
  800f66:	89 d8                	mov    %ebx,%eax
  800f68:	89 fa                	mov    %edi,%edx
  800f6a:	83 c4 1c             	add    $0x1c,%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    
  800f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f78:	31 ff                	xor    %edi,%edi
  800f7a:	31 db                	xor    %ebx,%ebx
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	89 fa                	mov    %edi,%edx
  800f80:	83 c4 1c             	add    $0x1c,%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5f                   	pop    %edi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    
  800f88:	90                   	nop
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	89 d8                	mov    %ebx,%eax
  800f92:	f7 f7                	div    %edi
  800f94:	31 ff                	xor    %edi,%edi
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	89 fa                	mov    %edi,%edx
  800f9c:	83 c4 1c             	add    $0x1c,%esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5f                   	pop    %edi
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    
  800fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	39 ce                	cmp    %ecx,%esi
  800faa:	72 0c                	jb     800fb8 <__udivdi3+0x118>
  800fac:	31 db                	xor    %ebx,%ebx
  800fae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800fb2:	0f 87 34 ff ff ff    	ja     800eec <__udivdi3+0x4c>
  800fb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800fbd:	e9 2a ff ff ff       	jmp    800eec <__udivdi3+0x4c>
  800fc2:	66 90                	xchg   %ax,%ax
  800fc4:	66 90                	xchg   %ax,%ax
  800fc6:	66 90                	xchg   %ax,%ax
  800fc8:	66 90                	xchg   %ax,%ax
  800fca:	66 90                	xchg   %ax,%ax
  800fcc:	66 90                	xchg   %ax,%ax
  800fce:	66 90                	xchg   %ax,%ax

00800fd0 <__umoddi3>:
  800fd0:	55                   	push   %ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 1c             	sub    $0x1c,%esp
  800fd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800fdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fe7:	85 d2                	test   %edx,%edx
  800fe9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ff1:	89 f3                	mov    %esi,%ebx
  800ff3:	89 3c 24             	mov    %edi,(%esp)
  800ff6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ffa:	75 1c                	jne    801018 <__umoddi3+0x48>
  800ffc:	39 f7                	cmp    %esi,%edi
  800ffe:	76 50                	jbe    801050 <__umoddi3+0x80>
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 f2                	mov    %esi,%edx
  801004:	f7 f7                	div    %edi
  801006:	89 d0                	mov    %edx,%eax
  801008:	31 d2                	xor    %edx,%edx
  80100a:	83 c4 1c             	add    $0x1c,%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    
  801012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801018:	39 f2                	cmp    %esi,%edx
  80101a:	89 d0                	mov    %edx,%eax
  80101c:	77 52                	ja     801070 <__umoddi3+0xa0>
  80101e:	0f bd ea             	bsr    %edx,%ebp
  801021:	83 f5 1f             	xor    $0x1f,%ebp
  801024:	75 5a                	jne    801080 <__umoddi3+0xb0>
  801026:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80102a:	0f 82 e0 00 00 00    	jb     801110 <__umoddi3+0x140>
  801030:	39 0c 24             	cmp    %ecx,(%esp)
  801033:	0f 86 d7 00 00 00    	jbe    801110 <__umoddi3+0x140>
  801039:	8b 44 24 08          	mov    0x8(%esp),%eax
  80103d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801041:	83 c4 1c             	add    $0x1c,%esp
  801044:	5b                   	pop    %ebx
  801045:	5e                   	pop    %esi
  801046:	5f                   	pop    %edi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    
  801049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801050:	85 ff                	test   %edi,%edi
  801052:	89 fd                	mov    %edi,%ebp
  801054:	75 0b                	jne    801061 <__umoddi3+0x91>
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f7                	div    %edi
  80105f:	89 c5                	mov    %eax,%ebp
  801061:	89 f0                	mov    %esi,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f5                	div    %ebp
  801067:	89 c8                	mov    %ecx,%eax
  801069:	f7 f5                	div    %ebp
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	eb 99                	jmp    801008 <__umoddi3+0x38>
  80106f:	90                   	nop
  801070:	89 c8                	mov    %ecx,%eax
  801072:	89 f2                	mov    %esi,%edx
  801074:	83 c4 1c             	add    $0x1c,%esp
  801077:	5b                   	pop    %ebx
  801078:	5e                   	pop    %esi
  801079:	5f                   	pop    %edi
  80107a:	5d                   	pop    %ebp
  80107b:	c3                   	ret    
  80107c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801080:	8b 34 24             	mov    (%esp),%esi
  801083:	bf 20 00 00 00       	mov    $0x20,%edi
  801088:	89 e9                	mov    %ebp,%ecx
  80108a:	29 ef                	sub    %ebp,%edi
  80108c:	d3 e0                	shl    %cl,%eax
  80108e:	89 f9                	mov    %edi,%ecx
  801090:	89 f2                	mov    %esi,%edx
  801092:	d3 ea                	shr    %cl,%edx
  801094:	89 e9                	mov    %ebp,%ecx
  801096:	09 c2                	or     %eax,%edx
  801098:	89 d8                	mov    %ebx,%eax
  80109a:	89 14 24             	mov    %edx,(%esp)
  80109d:	89 f2                	mov    %esi,%edx
  80109f:	d3 e2                	shl    %cl,%edx
  8010a1:	89 f9                	mov    %edi,%ecx
  8010a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010ab:	d3 e8                	shr    %cl,%eax
  8010ad:	89 e9                	mov    %ebp,%ecx
  8010af:	89 c6                	mov    %eax,%esi
  8010b1:	d3 e3                	shl    %cl,%ebx
  8010b3:	89 f9                	mov    %edi,%ecx
  8010b5:	89 d0                	mov    %edx,%eax
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	89 e9                	mov    %ebp,%ecx
  8010bb:	09 d8                	or     %ebx,%eax
  8010bd:	89 d3                	mov    %edx,%ebx
  8010bf:	89 f2                	mov    %esi,%edx
  8010c1:	f7 34 24             	divl   (%esp)
  8010c4:	89 d6                	mov    %edx,%esi
  8010c6:	d3 e3                	shl    %cl,%ebx
  8010c8:	f7 64 24 04          	mull   0x4(%esp)
  8010cc:	39 d6                	cmp    %edx,%esi
  8010ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010d2:	89 d1                	mov    %edx,%ecx
  8010d4:	89 c3                	mov    %eax,%ebx
  8010d6:	72 08                	jb     8010e0 <__umoddi3+0x110>
  8010d8:	75 11                	jne    8010eb <__umoddi3+0x11b>
  8010da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010de:	73 0b                	jae    8010eb <__umoddi3+0x11b>
  8010e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010e4:	1b 14 24             	sbb    (%esp),%edx
  8010e7:	89 d1                	mov    %edx,%ecx
  8010e9:	89 c3                	mov    %eax,%ebx
  8010eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8010ef:	29 da                	sub    %ebx,%edx
  8010f1:	19 ce                	sbb    %ecx,%esi
  8010f3:	89 f9                	mov    %edi,%ecx
  8010f5:	89 f0                	mov    %esi,%eax
  8010f7:	d3 e0                	shl    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	d3 ea                	shr    %cl,%edx
  8010fd:	89 e9                	mov    %ebp,%ecx
  8010ff:	d3 ee                	shr    %cl,%esi
  801101:	09 d0                	or     %edx,%eax
  801103:	89 f2                	mov    %esi,%edx
  801105:	83 c4 1c             	add    $0x1c,%esp
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    
  80110d:	8d 76 00             	lea    0x0(%esi),%esi
  801110:	29 f9                	sub    %edi,%ecx
  801112:	19 d6                	sbb    %edx,%esi
  801114:	89 74 24 04          	mov    %esi,0x4(%esp)
  801118:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80111c:	e9 18 ff ff ff       	jmp    801039 <__umoddi3+0x69>
