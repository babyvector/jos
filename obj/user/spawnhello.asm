
obj/user/spawnhello.debug:     file format elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 c0 23 80 00       	push   $0x8023c0
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 de 23 80 00       	push   $0x8023de
  800056:	68 de 23 80 00       	push   $0x8023de
  80005b:	e8 5c 1a 00 00       	call   801abc <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 e4 23 80 00       	push   $0x8023e4
  80006d:	6a 09                	push   $0x9
  80006f:	68 fc 23 80 00       	push   $0x8023fc
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 bd 0a 00 00       	call   800b48 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 76 0e 00 00       	call   800f42 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 31 0a 00 00       	call   800b07 <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 5a 0a 00 00       	call   800b48 <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 18 24 80 00       	push   $0x802418
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 e0 28 80 00 	movl   $0x8028e0,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 79 09 00 00       	call   800aca <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 1e 09 00 00       	call   800aca <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 14 1f 00 00       	call   802130 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 01 20 00 00       	call   802260 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 3b 24 80 00 	movsbl 0x80243b(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 d3 03 00 00    	je     8006da <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 64 03 00 00    	ja     8006bf <vprintfmt+0x3d4>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xdf>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x59>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x59>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x142>
  800422:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 53 24 80 00       	push   $0x802453
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 94 fe ff ff       	call   8002ce <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 11 28 80 00       	push   $0x802811
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 7c fe ff ff       	call   8002ce <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 4c 24 80 00       	mov    $0x80244c,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x225>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 c8             	pushl  -0x38(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 d0 02 00 00       	call   800762 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c0>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x213>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x213>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x23f>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x23f>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x270>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f2>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f2>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x278>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800585:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2d1>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005bf:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005d1:	0f 89 b0 00 00 00    	jns    800687 <vprintfmt+0x39c>
				putch('-', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	53                   	push   %ebx
  8005db:	6a 2d                	push   $0x2d
  8005dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005df:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e5:	f7 d8                	neg    %eax
  8005e7:	83 d2 00             	adc    $0x0,%edx
  8005ea:	f7 da                	neg    %edx
  8005ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fa:	e9 88 00 00 00       	jmp    800687 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 70 fc ff ff       	call   800277 <getuint>
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800612:	eb 73                	jmp    800687 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 5b fc ff ff       	call   800277 <getuint>
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 58                	push   $0x58
  800628:	ff d6                	call   *%esi
			putch('X', putdat);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 58                	push   $0x58
  800630:	ff d6                	call   *%esi
			putch('X', putdat);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 58                	push   $0x58
  800638:	ff d6                	call   *%esi
			goto number;
  80063a:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80063d:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800642:	eb 43                	jmp    800687 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
  800664:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800667:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800672:	eb 13                	jmp    800687 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 fb fb ff ff       	call   800277 <getuint>
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800682:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800687:	83 ec 0c             	sub    $0xc,%esp
  80068a:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80068e:	52                   	push   %edx
  80068f:	ff 75 e0             	pushl  -0x20(%ebp)
  800692:	50                   	push   %eax
  800693:	ff 75 dc             	pushl  -0x24(%ebp)
  800696:	ff 75 d8             	pushl  -0x28(%ebp)
  800699:	89 da                	mov    %ebx,%edx
  80069b:	89 f0                	mov    %esi,%eax
  80069d:	e8 26 fb ff ff       	call   8001c8 <printnum>
			break;
  8006a2:	83 c4 20             	add    $0x20,%esp
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a8:	e9 64 fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	51                   	push   %ecx
  8006b2:	ff d6                	call   *%esi
			break;
  8006b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ba:	e9 52 fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	6a 25                	push   $0x25
  8006c5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	eb 03                	jmp    8006cf <vprintfmt+0x3e4>
  8006cc:	83 ef 01             	sub    $0x1,%edi
  8006cf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d3:	75 f7                	jne    8006cc <vprintfmt+0x3e1>
  8006d5:	e9 37 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006dd:	5b                   	pop    %ebx
  8006de:	5e                   	pop    %esi
  8006df:	5f                   	pop    %edi
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 18             	sub    $0x18,%esp
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ff:	85 c0                	test   %eax,%eax
  800701:	74 26                	je     800729 <vsnprintf+0x47>
  800703:	85 d2                	test   %edx,%edx
  800705:	7e 22                	jle    800729 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800707:	ff 75 14             	pushl  0x14(%ebp)
  80070a:	ff 75 10             	pushl  0x10(%ebp)
  80070d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800710:	50                   	push   %eax
  800711:	68 b1 02 80 00       	push   $0x8002b1
  800716:	e8 d0 fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800721:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 05                	jmp    80072e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800729:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800739:	50                   	push   %eax
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	ff 75 08             	pushl  0x8(%ebp)
  800743:	e8 9a ff ff ff       	call   8006e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
  800755:	eb 03                	jmp    80075a <strlen+0x10>
		n++;
  800757:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075e:	75 f7                	jne    800757 <strlen+0xd>
		n++;
	return n;
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800768:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	ba 00 00 00 00       	mov    $0x0,%edx
  800770:	eb 03                	jmp    800775 <strnlen+0x13>
		n++;
  800772:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	39 c2                	cmp    %eax,%edx
  800777:	74 08                	je     800781 <strnlen+0x1f>
  800779:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077d:	75 f3                	jne    800772 <strnlen+0x10>
  80077f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	83 c1 01             	add    $0x1,%ecx
  800795:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800799:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079c:	84 db                	test   %bl,%bl
  80079e:	75 ef                	jne    80078f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 9a ff ff ff       	call   80074a <strlen>
  8007b0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	01 d8                	add    %ebx,%eax
  8007b8:	50                   	push   %eax
  8007b9:	e8 c5 ff ff ff       	call   800783 <strcpy>
	return dst;
}
  8007be:	89 d8                	mov    %ebx,%eax
  8007c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d0:	89 f3                	mov    %esi,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	89 f2                	mov    %esi,%edx
  8007d7:	eb 0f                	jmp    8007e8 <strncpy+0x23>
		*dst++ = *src;
  8007d9:	83 c2 01             	add    $0x1,%edx
  8007dc:	0f b6 01             	movzbl (%ecx),%eax
  8007df:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	39 da                	cmp    %ebx,%edx
  8007ea:	75 ed                	jne    8007d9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800800:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	74 21                	je     800827 <strlcpy+0x35>
  800806:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 09                	jmp    800817 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	83 c1 01             	add    $0x1,%ecx
  800814:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800817:	39 c2                	cmp    %eax,%edx
  800819:	74 09                	je     800824 <strlcpy+0x32>
  80081b:	0f b6 19             	movzbl (%ecx),%ebx
  80081e:	84 db                	test   %bl,%bl
  800820:	75 ec                	jne    80080e <strlcpy+0x1c>
  800822:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800824:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800827:	29 f0                	sub    %esi,%eax
}
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800836:	eb 06                	jmp    80083e <strcmp+0x11>
		p++, q++;
  800838:	83 c1 01             	add    $0x1,%ecx
  80083b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083e:	0f b6 01             	movzbl (%ecx),%eax
  800841:	84 c0                	test   %al,%al
  800843:	74 04                	je     800849 <strcmp+0x1c>
  800845:	3a 02                	cmp    (%edx),%al
  800847:	74 ef                	je     800838 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 c3                	mov    %eax,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800862:	eb 06                	jmp    80086a <strncmp+0x17>
		n--, p++, q++;
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086a:	39 d8                	cmp    %ebx,%eax
  80086c:	74 15                	je     800883 <strncmp+0x30>
  80086e:	0f b6 08             	movzbl (%eax),%ecx
  800871:	84 c9                	test   %cl,%cl
  800873:	74 04                	je     800879 <strncmp+0x26>
  800875:	3a 0a                	cmp    (%edx),%cl
  800877:	74 eb                	je     800864 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 00             	movzbl (%eax),%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
  800881:	eb 05                	jmp    800888 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800895:	eb 07                	jmp    80089e <strchr+0x13>
		if (*s == c)
  800897:	38 ca                	cmp    %cl,%dl
  800899:	74 0f                	je     8008aa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	0f b6 10             	movzbl (%eax),%edx
  8008a1:	84 d2                	test   %dl,%dl
  8008a3:	75 f2                	jne    800897 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b6:	eb 03                	jmp    8008bb <strfind+0xf>
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008be:	38 ca                	cmp    %cl,%dl
  8008c0:	74 04                	je     8008c6 <strfind+0x1a>
  8008c2:	84 d2                	test   %dl,%dl
  8008c4:	75 f2                	jne    8008b8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	74 36                	je     80090e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008de:	75 28                	jne    800908 <memset+0x40>
  8008e0:	f6 c1 03             	test   $0x3,%cl
  8008e3:	75 23                	jne    800908 <memset+0x40>
		c &= 0xFF;
  8008e5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e9:	89 d3                	mov    %edx,%ebx
  8008eb:	c1 e3 08             	shl    $0x8,%ebx
  8008ee:	89 d6                	mov    %edx,%esi
  8008f0:	c1 e6 18             	shl    $0x18,%esi
  8008f3:	89 d0                	mov    %edx,%eax
  8008f5:	c1 e0 10             	shl    $0x10,%eax
  8008f8:	09 f0                	or     %esi,%eax
  8008fa:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fc:	89 d8                	mov    %ebx,%eax
  8008fe:	09 d0                	or     %edx,%eax
  800900:	c1 e9 02             	shr    $0x2,%ecx
  800903:	fc                   	cld    
  800904:	f3 ab                	rep stos %eax,%es:(%edi)
  800906:	eb 06                	jmp    80090e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	fc                   	cld    
  80090c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090e:	89 f8                	mov    %edi,%eax
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800920:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800923:	39 c6                	cmp    %eax,%esi
  800925:	73 35                	jae    80095c <memmove+0x47>
  800927:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092a:	39 d0                	cmp    %edx,%eax
  80092c:	73 2e                	jae    80095c <memmove+0x47>
		s += n;
		d += n;
  80092e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800931:	89 d6                	mov    %edx,%esi
  800933:	09 fe                	or     %edi,%esi
  800935:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093b:	75 13                	jne    800950 <memmove+0x3b>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 0e                	jne    800950 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800942:	83 ef 04             	sub    $0x4,%edi
  800945:	8d 72 fc             	lea    -0x4(%edx),%esi
  800948:	c1 e9 02             	shr    $0x2,%ecx
  80094b:	fd                   	std    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb 09                	jmp    800959 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800950:	83 ef 01             	sub    $0x1,%edi
  800953:	8d 72 ff             	lea    -0x1(%edx),%esi
  800956:	fd                   	std    
  800957:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800959:	fc                   	cld    
  80095a:	eb 1d                	jmp    800979 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095c:	89 f2                	mov    %esi,%edx
  80095e:	09 c2                	or     %eax,%edx
  800960:	f6 c2 03             	test   $0x3,%dl
  800963:	75 0f                	jne    800974 <memmove+0x5f>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0a                	jne    800974 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096a:	c1 e9 02             	shr    $0x2,%ecx
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	fc                   	cld    
  800970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800972:	eb 05                	jmp    800979 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800980:	ff 75 10             	pushl  0x10(%ebp)
  800983:	ff 75 0c             	pushl  0xc(%ebp)
  800986:	ff 75 08             	pushl  0x8(%ebp)
  800989:	e8 87 ff ff ff       	call   800915 <memmove>
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	89 c6                	mov    %eax,%esi
  80099d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a0:	eb 1a                	jmp    8009bc <memcmp+0x2c>
		if (*s1 != *s2)
  8009a2:	0f b6 08             	movzbl (%eax),%ecx
  8009a5:	0f b6 1a             	movzbl (%edx),%ebx
  8009a8:	38 d9                	cmp    %bl,%cl
  8009aa:	74 0a                	je     8009b6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ac:	0f b6 c1             	movzbl %cl,%eax
  8009af:	0f b6 db             	movzbl %bl,%ebx
  8009b2:	29 d8                	sub    %ebx,%eax
  8009b4:	eb 0f                	jmp    8009c5 <memcmp+0x35>
		s1++, s2++;
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bc:	39 f0                	cmp    %esi,%eax
  8009be:	75 e2                	jne    8009a2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d0:	89 c1                	mov    %eax,%ecx
  8009d2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d9:	eb 0a                	jmp    8009e5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009db:	0f b6 10             	movzbl (%eax),%edx
  8009de:	39 da                	cmp    %ebx,%edx
  8009e0:	74 07                	je     8009e9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	39 c8                	cmp    %ecx,%eax
  8009e7:	72 f2                	jb     8009db <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f8:	eb 03                	jmp    8009fd <strtol+0x11>
		s++;
  8009fa:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	3c 20                	cmp    $0x20,%al
  800a02:	74 f6                	je     8009fa <strtol+0xe>
  800a04:	3c 09                	cmp    $0x9,%al
  800a06:	74 f2                	je     8009fa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a08:	3c 2b                	cmp    $0x2b,%al
  800a0a:	75 0a                	jne    800a16 <strtol+0x2a>
		s++;
  800a0c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a14:	eb 11                	jmp    800a27 <strtol+0x3b>
  800a16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1b:	3c 2d                	cmp    $0x2d,%al
  800a1d:	75 08                	jne    800a27 <strtol+0x3b>
		s++, neg = 1;
  800a1f:	83 c1 01             	add    $0x1,%ecx
  800a22:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a27:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2d:	75 15                	jne    800a44 <strtol+0x58>
  800a2f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a32:	75 10                	jne    800a44 <strtol+0x58>
  800a34:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a38:	75 7c                	jne    800ab6 <strtol+0xca>
		s += 2, base = 16;
  800a3a:	83 c1 02             	add    $0x2,%ecx
  800a3d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a42:	eb 16                	jmp    800a5a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	75 12                	jne    800a5a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a48:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a50:	75 08                	jne    800a5a <strtol+0x6e>
		s++, base = 8;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a62:	0f b6 11             	movzbl (%ecx),%edx
  800a65:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a68:	89 f3                	mov    %esi,%ebx
  800a6a:	80 fb 09             	cmp    $0x9,%bl
  800a6d:	77 08                	ja     800a77 <strtol+0x8b>
			dig = *s - '0';
  800a6f:	0f be d2             	movsbl %dl,%edx
  800a72:	83 ea 30             	sub    $0x30,%edx
  800a75:	eb 22                	jmp    800a99 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a77:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7a:	89 f3                	mov    %esi,%ebx
  800a7c:	80 fb 19             	cmp    $0x19,%bl
  800a7f:	77 08                	ja     800a89 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 57             	sub    $0x57,%edx
  800a87:	eb 10                	jmp    800a99 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a89:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 19             	cmp    $0x19,%bl
  800a91:	77 16                	ja     800aa9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a99:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9c:	7d 0b                	jge    800aa9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9e:	83 c1 01             	add    $0x1,%ecx
  800aa1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa7:	eb b9                	jmp    800a62 <strtol+0x76>

	if (endptr)
  800aa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aad:	74 0d                	je     800abc <strtol+0xd0>
		*endptr = (char *) s;
  800aaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab2:	89 0e                	mov    %ecx,(%esi)
  800ab4:	eb 06                	jmp    800abc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	74 98                	je     800a52 <strtol+0x66>
  800aba:	eb 9e                	jmp    800a5a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abc:	89 c2                	mov    %eax,%edx
  800abe:	f7 da                	neg    %edx
  800ac0:	85 ff                	test   %edi,%edi
  800ac2:	0f 45 c2             	cmovne %edx,%eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 c3                	mov    %eax,%ebx
  800add:	89 c7                	mov    %eax,%edi
  800adf:	89 c6                	mov    %eax,%esi
  800ae1:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 01 00 00 00       	mov    $0x1,%eax
  800af8:	89 d1                	mov    %edx,%ecx
  800afa:	89 d3                	mov    %edx,%ebx
  800afc:	89 d7                	mov    %edx,%edi
  800afe:	89 d6                	mov    %edx,%esi
  800b00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b15:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	89 cb                	mov    %ecx,%ebx
  800b1f:	89 cf                	mov    %ecx,%edi
  800b21:	89 ce                	mov    %ecx,%esi
  800b23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	7e 17                	jle    800b40 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b29:	83 ec 0c             	sub    $0xc,%esp
  800b2c:	50                   	push   %eax
  800b2d:	6a 03                	push   $0x3
  800b2f:	68 3f 27 80 00       	push   $0x80273f
  800b34:	6a 23                	push   $0x23
  800b36:	68 5c 27 80 00       	push   $0x80275c
  800b3b:	e8 9b f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	b8 02 00 00 00       	mov    $0x2,%eax
  800b58:	89 d1                	mov    %edx,%ecx
  800b5a:	89 d3                	mov    %edx,%ebx
  800b5c:	89 d7                	mov    %edx,%edi
  800b5e:	89 d6                	mov    %edx,%esi
  800b60:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_yield>:

void
sys_yield(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b8f:	be 00 00 00 00       	mov    $0x0,%esi
  800b94:	b8 04 00 00 00       	mov    $0x4,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba2:	89 f7                	mov    %esi,%edi
  800ba4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ba6:	85 c0                	test   %eax,%eax
  800ba8:	7e 17                	jle    800bc1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	50                   	push   %eax
  800bae:	6a 04                	push   $0x4
  800bb0:	68 3f 27 80 00       	push   $0x80273f
  800bb5:	6a 23                	push   $0x23
  800bb7:	68 5c 27 80 00       	push   $0x80275c
  800bbc:	e8 1a f5 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be3:	8b 75 18             	mov    0x18(%ebp),%esi
  800be6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800be8:	85 c0                	test   %eax,%eax
  800bea:	7e 17                	jle    800c03 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 05                	push   $0x5
  800bf2:	68 3f 27 80 00       	push   $0x80273f
  800bf7:	6a 23                	push   $0x23
  800bf9:	68 5c 27 80 00       	push   $0x80275c
  800bfe:	e8 d8 f4 ff ff       	call   8000db <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c19:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 df                	mov    %ebx,%edi
  800c26:	89 de                	mov    %ebx,%esi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 06                	push   $0x6
  800c34:	68 3f 27 80 00       	push   $0x80273f
  800c39:	6a 23                	push   $0x23
  800c3b:	68 5c 27 80 00       	push   $0x80275c
  800c40:	e8 96 f4 ff ff       	call   8000db <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	89 df                	mov    %ebx,%edi
  800c68:	89 de                	mov    %ebx,%esi
  800c6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 08                	push   $0x8
  800c76:	68 3f 27 80 00       	push   $0x80273f
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 5c 27 80 00       	push   $0x80275c
  800c82:	e8 54 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 09                	push   $0x9
  800cb8:	68 3f 27 80 00       	push   $0x80273f
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 5c 27 80 00       	push   $0x80275c
  800cc4:	e8 12 f4 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 0a                	push   $0xa
  800cfa:	68 3f 27 80 00       	push   $0x80273f
  800cff:	6a 23                	push   $0x23
  800d01:	68 5c 27 80 00       	push   $0x80275c
  800d06:	e8 d0 f3 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d19:	be 00 00 00 00       	mov    $0x0,%esi
  800d1e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 cb                	mov    %ecx,%ebx
  800d4e:	89 cf                	mov    %ecx,%edi
  800d50:	89 ce                	mov    %ecx,%esi
  800d52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 17                	jle    800d6f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 0d                	push   $0xd
  800d5e:	68 3f 27 80 00       	push   $0x80273f
  800d63:	6a 23                	push   $0x23
  800d65:	68 5c 27 80 00       	push   $0x80275c
  800d6a:	e8 6c f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d82:	c1 e8 0c             	shr    $0xc,%eax
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	05 00 00 00 30       	add    $0x30000000,%eax
  800d92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d97:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800da9:	89 c2                	mov    %eax,%edx
  800dab:	c1 ea 16             	shr    $0x16,%edx
  800dae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db5:	f6 c2 01             	test   $0x1,%dl
  800db8:	74 11                	je     800dcb <fd_alloc+0x2d>
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	c1 ea 0c             	shr    $0xc,%edx
  800dbf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc6:	f6 c2 01             	test   $0x1,%dl
  800dc9:	75 09                	jne    800dd4 <fd_alloc+0x36>
			*fd_store = fd;
  800dcb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd2:	eb 17                	jmp    800deb <fd_alloc+0x4d>
  800dd4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dd9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dde:	75 c9                	jne    800da9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800de0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    

00800ded <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df3:	83 f8 1f             	cmp    $0x1f,%eax
  800df6:	77 36                	ja     800e2e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df8:	c1 e0 0c             	shl    $0xc,%eax
  800dfb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e00:	89 c2                	mov    %eax,%edx
  800e02:	c1 ea 16             	shr    $0x16,%edx
  800e05:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0c:	f6 c2 01             	test   $0x1,%dl
  800e0f:	74 24                	je     800e35 <fd_lookup+0x48>
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	c1 ea 0c             	shr    $0xc,%edx
  800e16:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1d:	f6 c2 01             	test   $0x1,%dl
  800e20:	74 1a                	je     800e3c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e25:	89 02                	mov    %eax,(%edx)
	return 0;
  800e27:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2c:	eb 13                	jmp    800e41 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e33:	eb 0c                	jmp    800e41 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e35:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3a:	eb 05                	jmp    800e41 <fd_lookup+0x54>
  800e3c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	83 ec 08             	sub    $0x8,%esp
  800e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4c:	ba e8 27 80 00       	mov    $0x8027e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e51:	eb 13                	jmp    800e66 <dev_lookup+0x23>
  800e53:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e56:	39 08                	cmp    %ecx,(%eax)
  800e58:	75 0c                	jne    800e66 <dev_lookup+0x23>
			*dev = devtab[i];
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	eb 2e                	jmp    800e94 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e66:	8b 02                	mov    (%edx),%eax
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	75 e7                	jne    800e53 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6c:	a1 04 40 80 00       	mov    0x804004,%eax
  800e71:	8b 40 48             	mov    0x48(%eax),%eax
  800e74:	83 ec 04             	sub    $0x4,%esp
  800e77:	51                   	push   %ecx
  800e78:	50                   	push   %eax
  800e79:	68 6c 27 80 00       	push   $0x80276c
  800e7e:	e8 31 f3 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800e83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e94:	c9                   	leave  
  800e95:	c3                   	ret    

00800e96 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 10             	sub    $0x10,%esp
  800e9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea7:	50                   	push   %eax
  800ea8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eae:	c1 e8 0c             	shr    $0xc,%eax
  800eb1:	50                   	push   %eax
  800eb2:	e8 36 ff ff ff       	call   800ded <fd_lookup>
  800eb7:	83 c4 08             	add    $0x8,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	78 05                	js     800ec3 <fd_close+0x2d>
	    || fd != fd2)
  800ebe:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ec1:	74 0c                	je     800ecf <fd_close+0x39>
		return (must_exist ? r : 0);
  800ec3:	84 db                	test   %bl,%bl
  800ec5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eca:	0f 44 c2             	cmove  %edx,%eax
  800ecd:	eb 41                	jmp    800f10 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	ff 36                	pushl  (%esi)
  800ed8:	e8 66 ff ff ff       	call   800e43 <dev_lookup>
  800edd:	89 c3                	mov    %eax,%ebx
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	78 1a                	js     800f00 <fd_close+0x6a>
		if (dev->dev_close)
  800ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eec:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	74 0b                	je     800f00 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef5:	83 ec 0c             	sub    $0xc,%esp
  800ef8:	56                   	push   %esi
  800ef9:	ff d0                	call   *%eax
  800efb:	89 c3                	mov    %eax,%ebx
  800efd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f00:	83 ec 08             	sub    $0x8,%esp
  800f03:	56                   	push   %esi
  800f04:	6a 00                	push   $0x0
  800f06:	e8 00 fd ff ff       	call   800c0b <sys_page_unmap>
	return r;
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	89 d8                	mov    %ebx,%eax
}
  800f10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	ff 75 08             	pushl  0x8(%ebp)
  800f24:	e8 c4 fe ff ff       	call   800ded <fd_lookup>
  800f29:	83 c4 08             	add    $0x8,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 10                	js     800f40 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	6a 01                	push   $0x1
  800f35:	ff 75 f4             	pushl  -0xc(%ebp)
  800f38:	e8 59 ff ff ff       	call   800e96 <fd_close>
  800f3d:	83 c4 10             	add    $0x10,%esp
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <close_all>:

void
close_all(void)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	53                   	push   %ebx
  800f46:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f49:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4e:	83 ec 0c             	sub    $0xc,%esp
  800f51:	53                   	push   %ebx
  800f52:	e8 c0 ff ff ff       	call   800f17 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f57:	83 c3 01             	add    $0x1,%ebx
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	83 fb 20             	cmp    $0x20,%ebx
  800f60:	75 ec                	jne    800f4e <close_all+0xc>
		close(i);
}
  800f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
  800f6d:	83 ec 2c             	sub    $0x2c,%esp
  800f70:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f73:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	ff 75 08             	pushl  0x8(%ebp)
  800f7a:	e8 6e fe ff ff       	call   800ded <fd_lookup>
  800f7f:	83 c4 08             	add    $0x8,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	0f 88 c1 00 00 00    	js     80104b <dup+0xe4>
		return r;
	close(newfdnum);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	56                   	push   %esi
  800f8e:	e8 84 ff ff ff       	call   800f17 <close>

	newfd = INDEX2FD(newfdnum);
  800f93:	89 f3                	mov    %esi,%ebx
  800f95:	c1 e3 0c             	shl    $0xc,%ebx
  800f98:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f9e:	83 c4 04             	add    $0x4,%esp
  800fa1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa4:	e8 de fd ff ff       	call   800d87 <fd2data>
  800fa9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fab:	89 1c 24             	mov    %ebx,(%esp)
  800fae:	e8 d4 fd ff ff       	call   800d87 <fd2data>
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fb9:	89 f8                	mov    %edi,%eax
  800fbb:	c1 e8 16             	shr    $0x16,%eax
  800fbe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc5:	a8 01                	test   $0x1,%al
  800fc7:	74 37                	je     801000 <dup+0x99>
  800fc9:	89 f8                	mov    %edi,%eax
  800fcb:	c1 e8 0c             	shr    $0xc,%eax
  800fce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd5:	f6 c2 01             	test   $0x1,%dl
  800fd8:	74 26                	je     801000 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe9:	50                   	push   %eax
  800fea:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fed:	6a 00                	push   $0x0
  800fef:	57                   	push   %edi
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 d2 fb ff ff       	call   800bc9 <sys_page_map>
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	83 c4 20             	add    $0x20,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	78 2e                	js     80102e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801000:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801003:	89 d0                	mov    %edx,%eax
  801005:	c1 e8 0c             	shr    $0xc,%eax
  801008:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	25 07 0e 00 00       	and    $0xe07,%eax
  801017:	50                   	push   %eax
  801018:	53                   	push   %ebx
  801019:	6a 00                	push   $0x0
  80101b:	52                   	push   %edx
  80101c:	6a 00                	push   $0x0
  80101e:	e8 a6 fb ff ff       	call   800bc9 <sys_page_map>
  801023:	89 c7                	mov    %eax,%edi
  801025:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801028:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80102a:	85 ff                	test   %edi,%edi
  80102c:	79 1d                	jns    80104b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80102e:	83 ec 08             	sub    $0x8,%esp
  801031:	53                   	push   %ebx
  801032:	6a 00                	push   $0x0
  801034:	e8 d2 fb ff ff       	call   800c0b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80103f:	6a 00                	push   $0x0
  801041:	e8 c5 fb ff ff       	call   800c0b <sys_page_unmap>
	return r;
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	89 f8                	mov    %edi,%eax
}
  80104b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 14             	sub    $0x14,%esp
  80105a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801060:	50                   	push   %eax
  801061:	53                   	push   %ebx
  801062:	e8 86 fd ff ff       	call   800ded <fd_lookup>
  801067:	83 c4 08             	add    $0x8,%esp
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	85 c0                	test   %eax,%eax
  80106e:	78 6d                	js     8010dd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801076:	50                   	push   %eax
  801077:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107a:	ff 30                	pushl  (%eax)
  80107c:	e8 c2 fd ff ff       	call   800e43 <dev_lookup>
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	85 c0                	test   %eax,%eax
  801086:	78 4c                	js     8010d4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108b:	8b 42 08             	mov    0x8(%edx),%eax
  80108e:	83 e0 03             	and    $0x3,%eax
  801091:	83 f8 01             	cmp    $0x1,%eax
  801094:	75 21                	jne    8010b7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801096:	a1 04 40 80 00       	mov    0x804004,%eax
  80109b:	8b 40 48             	mov    0x48(%eax),%eax
  80109e:	83 ec 04             	sub    $0x4,%esp
  8010a1:	53                   	push   %ebx
  8010a2:	50                   	push   %eax
  8010a3:	68 ad 27 80 00       	push   $0x8027ad
  8010a8:	e8 07 f1 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010b5:	eb 26                	jmp    8010dd <read+0x8a>
	}
	if (!dev->dev_read)
  8010b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ba:	8b 40 08             	mov    0x8(%eax),%eax
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	74 17                	je     8010d8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	ff 75 10             	pushl  0x10(%ebp)
  8010c7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ca:	52                   	push   %edx
  8010cb:	ff d0                	call   *%eax
  8010cd:	89 c2                	mov    %eax,%edx
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	eb 09                	jmp    8010dd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d4:	89 c2                	mov    %eax,%edx
  8010d6:	eb 05                	jmp    8010dd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010dd:	89 d0                	mov    %edx,%eax
  8010df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 0c             	sub    $0xc,%esp
  8010ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f8:	eb 21                	jmp    80111b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010fa:	83 ec 04             	sub    $0x4,%esp
  8010fd:	89 f0                	mov    %esi,%eax
  8010ff:	29 d8                	sub    %ebx,%eax
  801101:	50                   	push   %eax
  801102:	89 d8                	mov    %ebx,%eax
  801104:	03 45 0c             	add    0xc(%ebp),%eax
  801107:	50                   	push   %eax
  801108:	57                   	push   %edi
  801109:	e8 45 ff ff ff       	call   801053 <read>
		if (m < 0)
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	85 c0                	test   %eax,%eax
  801113:	78 10                	js     801125 <readn+0x41>
			return m;
		if (m == 0)
  801115:	85 c0                	test   %eax,%eax
  801117:	74 0a                	je     801123 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801119:	01 c3                	add    %eax,%ebx
  80111b:	39 f3                	cmp    %esi,%ebx
  80111d:	72 db                	jb     8010fa <readn+0x16>
  80111f:	89 d8                	mov    %ebx,%eax
  801121:	eb 02                	jmp    801125 <readn+0x41>
  801123:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	53                   	push   %ebx
  801131:	83 ec 14             	sub    $0x14,%esp
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801137:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	53                   	push   %ebx
  80113c:	e8 ac fc ff ff       	call   800ded <fd_lookup>
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	89 c2                	mov    %eax,%edx
  801146:	85 c0                	test   %eax,%eax
  801148:	78 68                	js     8011b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801154:	ff 30                	pushl  (%eax)
  801156:	e8 e8 fc ff ff       	call   800e43 <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 47                	js     8011a9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801169:	75 21                	jne    80118c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116b:	a1 04 40 80 00       	mov    0x804004,%eax
  801170:	8b 40 48             	mov    0x48(%eax),%eax
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	53                   	push   %ebx
  801177:	50                   	push   %eax
  801178:	68 c9 27 80 00       	push   $0x8027c9
  80117d:	e8 32 f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118a:	eb 26                	jmp    8011b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80118f:	8b 52 0c             	mov    0xc(%edx),%edx
  801192:	85 d2                	test   %edx,%edx
  801194:	74 17                	je     8011ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801196:	83 ec 04             	sub    $0x4,%esp
  801199:	ff 75 10             	pushl  0x10(%ebp)
  80119c:	ff 75 0c             	pushl  0xc(%ebp)
  80119f:	50                   	push   %eax
  8011a0:	ff d2                	call   *%edx
  8011a2:	89 c2                	mov    %eax,%edx
  8011a4:	83 c4 10             	add    $0x10,%esp
  8011a7:	eb 09                	jmp    8011b2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a9:	89 c2                	mov    %eax,%edx
  8011ab:	eb 05                	jmp    8011b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011b2:	89 d0                	mov    %edx,%eax
  8011b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b7:	c9                   	leave  
  8011b8:	c3                   	ret    

008011b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c2:	50                   	push   %eax
  8011c3:	ff 75 08             	pushl  0x8(%ebp)
  8011c6:	e8 22 fc ff ff       	call   800ded <fd_lookup>
  8011cb:	83 c4 08             	add    $0x8,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 0e                	js     8011e0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e0:	c9                   	leave  
  8011e1:	c3                   	ret    

008011e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 14             	sub    $0x14,%esp
  8011e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ef:	50                   	push   %eax
  8011f0:	53                   	push   %ebx
  8011f1:	e8 f7 fb ff ff       	call   800ded <fd_lookup>
  8011f6:	83 c4 08             	add    $0x8,%esp
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 65                	js     801264 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801209:	ff 30                	pushl  (%eax)
  80120b:	e8 33 fc ff ff       	call   800e43 <dev_lookup>
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	85 c0                	test   %eax,%eax
  801215:	78 44                	js     80125b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801217:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121e:	75 21                	jne    801241 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801220:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801225:	8b 40 48             	mov    0x48(%eax),%eax
  801228:	83 ec 04             	sub    $0x4,%esp
  80122b:	53                   	push   %ebx
  80122c:	50                   	push   %eax
  80122d:	68 8c 27 80 00       	push   $0x80278c
  801232:	e8 7d ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80123f:	eb 23                	jmp    801264 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801241:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801244:	8b 52 18             	mov    0x18(%edx),%edx
  801247:	85 d2                	test   %edx,%edx
  801249:	74 14                	je     80125f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124b:	83 ec 08             	sub    $0x8,%esp
  80124e:	ff 75 0c             	pushl  0xc(%ebp)
  801251:	50                   	push   %eax
  801252:	ff d2                	call   *%edx
  801254:	89 c2                	mov    %eax,%edx
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	eb 09                	jmp    801264 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	eb 05                	jmp    801264 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80125f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801264:	89 d0                	mov    %edx,%eax
  801266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801269:	c9                   	leave  
  80126a:	c3                   	ret    

0080126b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	53                   	push   %ebx
  80126f:	83 ec 14             	sub    $0x14,%esp
  801272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801275:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801278:	50                   	push   %eax
  801279:	ff 75 08             	pushl  0x8(%ebp)
  80127c:	e8 6c fb ff ff       	call   800ded <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	89 c2                	mov    %eax,%edx
  801286:	85 c0                	test   %eax,%eax
  801288:	78 58                	js     8012e2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801294:	ff 30                	pushl  (%eax)
  801296:	e8 a8 fb ff ff       	call   800e43 <dev_lookup>
  80129b:	83 c4 10             	add    $0x10,%esp
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 37                	js     8012d9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012a9:	74 32                	je     8012dd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ab:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ae:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b5:	00 00 00 
	stat->st_isdir = 0;
  8012b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012bf:	00 00 00 
	stat->st_dev = dev;
  8012c2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8012cf:	ff 50 14             	call   *0x14(%eax)
  8012d2:	89 c2                	mov    %eax,%edx
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	eb 09                	jmp    8012e2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	eb 05                	jmp    8012e2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e2:	89 d0                	mov    %edx,%eax
  8012e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e7:	c9                   	leave  
  8012e8:	c3                   	ret    

008012e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	6a 00                	push   $0x0
  8012f3:	ff 75 08             	pushl  0x8(%ebp)
  8012f6:	e8 dc 01 00 00       	call   8014d7 <open>
  8012fb:	89 c3                	mov    %eax,%ebx
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 1b                	js     80131f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801304:	83 ec 08             	sub    $0x8,%esp
  801307:	ff 75 0c             	pushl  0xc(%ebp)
  80130a:	50                   	push   %eax
  80130b:	e8 5b ff ff ff       	call   80126b <fstat>
  801310:	89 c6                	mov    %eax,%esi
	close(fd);
  801312:	89 1c 24             	mov    %ebx,(%esp)
  801315:	e8 fd fb ff ff       	call   800f17 <close>
	return r;
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	89 f0                	mov    %esi,%eax
}
  80131f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801322:	5b                   	pop    %ebx
  801323:	5e                   	pop    %esi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	56                   	push   %esi
  80132a:	53                   	push   %ebx
  80132b:	89 c6                	mov    %eax,%esi
  80132d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80132f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801336:	75 12                	jne    80134a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	6a 01                	push   $0x1
  80133d:	e8 6c 0d 00 00       	call   8020ae <ipc_find_env>
  801342:	a3 00 40 80 00       	mov    %eax,0x804000
  801347:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80134a:	6a 07                	push   $0x7
  80134c:	68 00 50 80 00       	push   $0x805000
  801351:	56                   	push   %esi
  801352:	ff 35 00 40 80 00    	pushl  0x804000
  801358:	e8 0e 0d 00 00       	call   80206b <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80135d:	83 c4 0c             	add    $0xc,%esp
  801360:	6a 00                	push   $0x0
  801362:	53                   	push   %ebx
  801363:	6a 00                	push   $0x0
  801365:	e8 a4 0c 00 00       	call   80200e <ipc_recv>
}
  80136a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	8b 40 0c             	mov    0xc(%eax),%eax
  80137d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801382:	8b 45 0c             	mov    0xc(%ebp),%eax
  801385:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80138a:	ba 00 00 00 00       	mov    $0x0,%edx
  80138f:	b8 02 00 00 00       	mov    $0x2,%eax
  801394:	e8 8d ff ff ff       	call   801326 <fsipc>
}
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b6:	e8 6b ff ff ff       	call   801326 <fsipc>
}
  8013bb:	c9                   	leave  
  8013bc:	c3                   	ret    

008013bd <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	53                   	push   %ebx
  8013c1:	83 ec 04             	sub    $0x4,%esp
  8013c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8013cd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013dc:	e8 45 ff ff ff       	call   801326 <fsipc>
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	78 2c                	js     801411 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	68 00 50 80 00       	push   $0x805000
  8013ed:	53                   	push   %ebx
  8013ee:	e8 90 f3 ff ff       	call   800783 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013fe:	a1 84 50 80 00       	mov    0x805084,%eax
  801403:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801411:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80141f:	8b 55 08             	mov    0x8(%ebp),%edx
  801422:	8b 52 0c             	mov    0xc(%edx),%edx
  801425:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80142b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801430:	50                   	push   %eax
  801431:	ff 75 0c             	pushl  0xc(%ebp)
  801434:	68 08 50 80 00       	push   $0x805008
  801439:	e8 d7 f4 ff ff       	call   800915 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80143e:	ba 00 00 00 00       	mov    $0x0,%edx
  801443:	b8 04 00 00 00       	mov    $0x4,%eax
  801448:	e8 d9 fe ff ff       	call   801326 <fsipc>
	//panic("devfile_write not implemented");
}
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	56                   	push   %esi
  801453:	53                   	push   %ebx
  801454:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801457:	8b 45 08             	mov    0x8(%ebp),%eax
  80145a:	8b 40 0c             	mov    0xc(%eax),%eax
  80145d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801462:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801468:	ba 00 00 00 00       	mov    $0x0,%edx
  80146d:	b8 03 00 00 00       	mov    $0x3,%eax
  801472:	e8 af fe ff ff       	call   801326 <fsipc>
  801477:	89 c3                	mov    %eax,%ebx
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 51                	js     8014ce <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80147d:	39 c6                	cmp    %eax,%esi
  80147f:	73 19                	jae    80149a <devfile_read+0x4b>
  801481:	68 f8 27 80 00       	push   $0x8027f8
  801486:	68 ff 27 80 00       	push   $0x8027ff
  80148b:	68 80 00 00 00       	push   $0x80
  801490:	68 14 28 80 00       	push   $0x802814
  801495:	e8 41 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  80149a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80149f:	7e 19                	jle    8014ba <devfile_read+0x6b>
  8014a1:	68 1f 28 80 00       	push   $0x80281f
  8014a6:	68 ff 27 80 00       	push   $0x8027ff
  8014ab:	68 81 00 00 00       	push   $0x81
  8014b0:	68 14 28 80 00       	push   $0x802814
  8014b5:	e8 21 ec ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	50                   	push   %eax
  8014be:	68 00 50 80 00       	push   $0x805000
  8014c3:	ff 75 0c             	pushl  0xc(%ebp)
  8014c6:	e8 4a f4 ff ff       	call   800915 <memmove>
	return r;
  8014cb:	83 c4 10             	add    $0x10,%esp
}
  8014ce:	89 d8                	mov    %ebx,%eax
  8014d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    

008014d7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	53                   	push   %ebx
  8014db:	83 ec 20             	sub    $0x20,%esp
  8014de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e1:	53                   	push   %ebx
  8014e2:	e8 63 f2 ff ff       	call   80074a <strlen>
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ef:	7f 67                	jg     801558 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f1:	83 ec 0c             	sub    $0xc,%esp
  8014f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f7:	50                   	push   %eax
  8014f8:	e8 a1 f8 ff ff       	call   800d9e <fd_alloc>
  8014fd:	83 c4 10             	add    $0x10,%esp
		return r;
  801500:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801502:	85 c0                	test   %eax,%eax
  801504:	78 57                	js     80155d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	53                   	push   %ebx
  80150a:	68 00 50 80 00       	push   $0x805000
  80150f:	e8 6f f2 ff ff       	call   800783 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801514:	8b 45 0c             	mov    0xc(%ebp),%eax
  801517:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80151c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151f:	b8 01 00 00 00       	mov    $0x1,%eax
  801524:	e8 fd fd ff ff       	call   801326 <fsipc>
  801529:	89 c3                	mov    %eax,%ebx
  80152b:	83 c4 10             	add    $0x10,%esp
  80152e:	85 c0                	test   %eax,%eax
  801530:	79 14                	jns    801546 <open+0x6f>
		
		fd_close(fd, 0);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	6a 00                	push   $0x0
  801537:	ff 75 f4             	pushl  -0xc(%ebp)
  80153a:	e8 57 f9 ff ff       	call   800e96 <fd_close>
		return r;
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	89 da                	mov    %ebx,%edx
  801544:	eb 17                	jmp    80155d <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801546:	83 ec 0c             	sub    $0xc,%esp
  801549:	ff 75 f4             	pushl  -0xc(%ebp)
  80154c:	e8 26 f8 ff ff       	call   800d77 <fd2num>
  801551:	89 c2                	mov    %eax,%edx
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	eb 05                	jmp    80155d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801558:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  80155d:	89 d0                	mov    %edx,%eax
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    

00801564 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80156a:	ba 00 00 00 00       	mov    $0x0,%edx
  80156f:	b8 08 00 00 00       	mov    $0x8,%eax
  801574:	e8 ad fd ff ff       	call   801326 <fsipc>
}
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	57                   	push   %edi
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801587:	6a 00                	push   $0x0
  801589:	ff 75 08             	pushl  0x8(%ebp)
  80158c:	e8 46 ff ff ff       	call   8014d7 <open>
  801591:	89 c7                	mov    %eax,%edi
  801593:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	85 c0                	test   %eax,%eax
  80159e:	0f 88 ae 04 00 00    	js     801a52 <spawn+0x4d7>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	68 00 02 00 00       	push   $0x200
  8015ac:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	57                   	push   %edi
  8015b4:	e8 2b fb ff ff       	call   8010e4 <readn>
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015c1:	75 0c                	jne    8015cf <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015c3:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8015ca:	45 4c 46 
  8015cd:	74 33                	je     801602 <spawn+0x87>
		close(fd);
  8015cf:	83 ec 0c             	sub    $0xc,%esp
  8015d2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8015d8:	e8 3a f9 ff ff       	call   800f17 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8015dd:	83 c4 0c             	add    $0xc,%esp
  8015e0:	68 7f 45 4c 46       	push   $0x464c457f
  8015e5:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8015eb:	68 2b 28 80 00       	push   $0x80282b
  8015f0:	e8 bf eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  8015fd:	e9 b0 04 00 00       	jmp    801ab2 <spawn+0x537>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801602:	b8 07 00 00 00       	mov    $0x7,%eax
  801607:	cd 30                	int    $0x30
  801609:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80160f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801615:	85 c0                	test   %eax,%eax
  801617:	0f 88 3d 04 00 00    	js     801a5a <spawn+0x4df>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80161d:	89 c6                	mov    %eax,%esi
  80161f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801625:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801628:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80162e:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801634:	b9 11 00 00 00       	mov    $0x11,%ecx
  801639:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80163b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801641:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801647:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  80164c:	be 00 00 00 00       	mov    $0x0,%esi
  801651:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801654:	eb 13                	jmp    801669 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801656:	83 ec 0c             	sub    $0xc,%esp
  801659:	50                   	push   %eax
  80165a:	e8 eb f0 ff ff       	call   80074a <strlen>
  80165f:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801663:	83 c3 01             	add    $0x1,%ebx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801670:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801673:	85 c0                	test   %eax,%eax
  801675:	75 df                	jne    801656 <spawn+0xdb>
  801677:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  80167d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801683:	bf 00 10 40 00       	mov    $0x401000,%edi
  801688:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80168a:	89 fa                	mov    %edi,%edx
  80168c:	83 e2 fc             	and    $0xfffffffc,%edx
  80168f:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801696:	29 c2                	sub    %eax,%edx
  801698:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  80169e:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016a1:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016a6:	0f 86 be 03 00 00    	jbe    801a6a <spawn+0x4ef>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016ac:	83 ec 04             	sub    $0x4,%esp
  8016af:	6a 07                	push   $0x7
  8016b1:	68 00 00 40 00       	push   $0x400000
  8016b6:	6a 00                	push   $0x0
  8016b8:	e8 c9 f4 ff ff       	call   800b86 <sys_page_alloc>
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	0f 88 a9 03 00 00    	js     801a71 <spawn+0x4f6>
  8016c8:	be 00 00 00 00       	mov    $0x0,%esi
  8016cd:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8016d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d6:	eb 30                	jmp    801708 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8016d8:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8016de:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8016e4:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8016e7:	83 ec 08             	sub    $0x8,%esp
  8016ea:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016ed:	57                   	push   %edi
  8016ee:	e8 90 f0 ff ff       	call   800783 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8016f3:	83 c4 04             	add    $0x4,%esp
  8016f6:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8016f9:	e8 4c f0 ff ff       	call   80074a <strlen>
  8016fe:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801702:	83 c6 01             	add    $0x1,%esi
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80170e:	7f c8                	jg     8016d8 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801710:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801716:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80171c:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801723:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801729:	74 19                	je     801744 <spawn+0x1c9>
  80172b:	68 a0 28 80 00       	push   $0x8028a0
  801730:	68 ff 27 80 00       	push   $0x8027ff
  801735:	68 f2 00 00 00       	push   $0xf2
  80173a:	68 45 28 80 00       	push   $0x802845
  80173f:	e8 97 e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801744:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80174a:	89 f8                	mov    %edi,%eax
  80174c:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801751:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801754:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  80175a:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80175d:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801763:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	6a 07                	push   $0x7
  80176e:	68 00 d0 bf ee       	push   $0xeebfd000
  801773:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801779:	68 00 00 40 00       	push   $0x400000
  80177e:	6a 00                	push   $0x0
  801780:	e8 44 f4 ff ff       	call   800bc9 <sys_page_map>
  801785:	89 c3                	mov    %eax,%ebx
  801787:	83 c4 20             	add    $0x20,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	0f 88 0e 03 00 00    	js     801aa0 <spawn+0x525>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	68 00 00 40 00       	push   $0x400000
  80179a:	6a 00                	push   $0x0
  80179c:	e8 6a f4 ff ff       	call   800c0b <sys_page_unmap>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	0f 88 f2 02 00 00    	js     801aa0 <spawn+0x525>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017ae:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017b4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017bb:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017c1:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  8017c8:	00 00 00 
  8017cb:	e9 88 01 00 00       	jmp    801958 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  8017d0:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  8017d6:	83 38 01             	cmpl   $0x1,(%eax)
  8017d9:	0f 85 6b 01 00 00    	jne    80194a <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8017df:	89 c7                	mov    %eax,%edi
  8017e1:	8b 40 18             	mov    0x18(%eax),%eax
  8017e4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8017ea:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8017ed:	83 f8 01             	cmp    $0x1,%eax
  8017f0:	19 c0                	sbb    %eax,%eax
  8017f2:	83 e0 fe             	and    $0xfffffffe,%eax
  8017f5:	83 c0 07             	add    $0x7,%eax
  8017f8:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  8017fe:	89 f8                	mov    %edi,%eax
  801800:	8b 7f 04             	mov    0x4(%edi),%edi
  801803:	89 f9                	mov    %edi,%ecx
  801805:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  80180b:	8b 78 10             	mov    0x10(%eax),%edi
  80180e:	8b 50 14             	mov    0x14(%eax),%edx
  801811:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801817:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  80181a:	89 f0                	mov    %esi,%eax
  80181c:	25 ff 0f 00 00       	and    $0xfff,%eax
  801821:	74 14                	je     801837 <spawn+0x2bc>
		va -= i;
  801823:	29 c6                	sub    %eax,%esi
		memsz += i;
  801825:	01 c2                	add    %eax,%edx
  801827:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  80182d:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80182f:	29 c1                	sub    %eax,%ecx
  801831:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801837:	bb 00 00 00 00       	mov    $0x0,%ebx
  80183c:	e9 f7 00 00 00       	jmp    801938 <spawn+0x3bd>
		if (i >= filesz) {
  801841:	39 df                	cmp    %ebx,%edi
  801843:	77 27                	ja     80186c <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801845:	83 ec 04             	sub    $0x4,%esp
  801848:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80184e:	56                   	push   %esi
  80184f:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801855:	e8 2c f3 ff ff       	call   800b86 <sys_page_alloc>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	0f 89 c7 00 00 00    	jns    80192c <spawn+0x3b1>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	e9 13 02 00 00       	jmp    801a7f <spawn+0x504>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80186c:	83 ec 04             	sub    $0x4,%esp
  80186f:	6a 07                	push   $0x7
  801871:	68 00 00 40 00       	push   $0x400000
  801876:	6a 00                	push   $0x0
  801878:	e8 09 f3 ff ff       	call   800b86 <sys_page_alloc>
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	0f 88 ed 01 00 00    	js     801a75 <spawn+0x4fa>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801891:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801897:	50                   	push   %eax
  801898:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80189e:	e8 16 f9 ff ff       	call   8011b9 <seek>
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	0f 88 cb 01 00 00    	js     801a79 <spawn+0x4fe>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	89 f8                	mov    %edi,%eax
  8018b3:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018b9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018be:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018c3:	0f 47 c2             	cmova  %edx,%eax
  8018c6:	50                   	push   %eax
  8018c7:	68 00 00 40 00       	push   $0x400000
  8018cc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018d2:	e8 0d f8 ff ff       	call   8010e4 <readn>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	0f 88 9b 01 00 00    	js     801a7d <spawn+0x502>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  8018e2:	83 ec 0c             	sub    $0xc,%esp
  8018e5:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018eb:	56                   	push   %esi
  8018ec:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018f2:	68 00 00 40 00       	push   $0x400000
  8018f7:	6a 00                	push   $0x0
  8018f9:	e8 cb f2 ff ff       	call   800bc9 <sys_page_map>
  8018fe:	83 c4 20             	add    $0x20,%esp
  801901:	85 c0                	test   %eax,%eax
  801903:	79 15                	jns    80191a <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801905:	50                   	push   %eax
  801906:	68 51 28 80 00       	push   $0x802851
  80190b:	68 25 01 00 00       	push   $0x125
  801910:	68 45 28 80 00       	push   $0x802845
  801915:	e8 c1 e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	68 00 00 40 00       	push   $0x400000
  801922:	6a 00                	push   $0x0
  801924:	e8 e2 f2 ff ff       	call   800c0b <sys_page_unmap>
  801929:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  80192c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801932:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801938:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80193e:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801944:	0f 87 f7 fe ff ff    	ja     801841 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80194a:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801951:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801958:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80195f:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801965:	0f 8c 65 fe ff ff    	jl     8017d0 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  80196b:	83 ec 0c             	sub    $0xc,%esp
  80196e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801974:	e8 9e f5 ff ff       	call   800f17 <close>
  801979:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  80197c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801981:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  801987:	89 d8                	mov    %ebx,%eax
  801989:	c1 e8 16             	shr    $0x16,%eax
  80198c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801993:	a8 01                	test   $0x1,%al
  801995:	74 46                	je     8019dd <spawn+0x462>
  801997:	89 d8                	mov    %ebx,%eax
  801999:	c1 e8 0c             	shr    $0xc,%eax
  80199c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019a3:	f6 c2 01             	test   $0x1,%dl
  8019a6:	74 35                	je     8019dd <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8019a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) &&
  8019af:	f6 c2 04             	test   $0x4,%dl
  8019b2:	74 29                	je     8019dd <spawn+0x462>
				(uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8019b4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019bb:	f6 c6 04             	test   $0x4,%dh
  8019be:	74 1d                	je     8019dd <spawn+0x462>
            sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  8019c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019c7:	83 ec 0c             	sub    $0xc,%esp
  8019ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8019cf:	50                   	push   %eax
  8019d0:	53                   	push   %ebx
  8019d1:	56                   	push   %esi
  8019d2:	53                   	push   %ebx
  8019d3:	6a 00                	push   $0x0
  8019d5:	e8 ef f1 ff ff       	call   800bc9 <sys_page_map>
  8019da:	83 c4 20             	add    $0x20,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	uintptr_t addr;
	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8019dd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019e3:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8019e9:	75 9c                	jne    801987 <spawn+0x40c>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  8019eb:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  8019f2:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  8019fe:	50                   	push   %eax
  8019ff:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a05:	e8 85 f2 ff ff       	call   800c8f <sys_env_set_trapframe>
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	79 15                	jns    801a26 <spawn+0x4ab>
		panic("sys_env_set_trapframe: %e", r);
  801a11:	50                   	push   %eax
  801a12:	68 6e 28 80 00       	push   $0x80286e
  801a17:	68 86 00 00 00       	push   $0x86
  801a1c:	68 45 28 80 00       	push   $0x802845
  801a21:	e8 b5 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a26:	83 ec 08             	sub    $0x8,%esp
  801a29:	6a 02                	push   $0x2
  801a2b:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a31:	e8 17 f2 ff ff       	call   800c4d <sys_env_set_status>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	79 25                	jns    801a62 <spawn+0x4e7>
		panic("sys_env_set_status: %e", r);
  801a3d:	50                   	push   %eax
  801a3e:	68 88 28 80 00       	push   $0x802888
  801a43:	68 89 00 00 00       	push   $0x89
  801a48:	68 45 28 80 00       	push   $0x802845
  801a4d:	e8 89 e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a52:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a58:	eb 58                	jmp    801ab2 <spawn+0x537>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a5a:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a60:	eb 50                	jmp    801ab2 <spawn+0x537>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a62:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a68:	eb 48                	jmp    801ab2 <spawn+0x537>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a6a:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a6f:	eb 41                	jmp    801ab2 <spawn+0x537>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	eb 3d                	jmp    801ab2 <spawn+0x537>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a75:	89 c3                	mov    %eax,%ebx
  801a77:	eb 06                	jmp    801a7f <spawn+0x504>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a79:	89 c3                	mov    %eax,%ebx
  801a7b:	eb 02                	jmp    801a7f <spawn+0x504>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a7d:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801a7f:	83 ec 0c             	sub    $0xc,%esp
  801a82:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a88:	e8 7a f0 ff ff       	call   800b07 <sys_env_destroy>
	close(fd);
  801a8d:	83 c4 04             	add    $0x4,%esp
  801a90:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a96:	e8 7c f4 ff ff       	call   800f17 <close>
	return r;
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	eb 12                	jmp    801ab2 <spawn+0x537>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801aa0:	83 ec 08             	sub    $0x8,%esp
  801aa3:	68 00 00 40 00       	push   $0x400000
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 5c f1 ff ff       	call   800c0b <sys_page_unmap>
  801aaf:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ab2:	89 d8                	mov    %ebx,%eax
  801ab4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5f                   	pop    %edi
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ac1:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ac9:	eb 03                	jmp    801ace <spawnl+0x12>
		argc++;
  801acb:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ace:	83 c2 04             	add    $0x4,%edx
  801ad1:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801ad5:	75 f4                	jne    801acb <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801ad7:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801ade:	83 e2 f0             	and    $0xfffffff0,%edx
  801ae1:	29 d4                	sub    %edx,%esp
  801ae3:	8d 54 24 03          	lea    0x3(%esp),%edx
  801ae7:	c1 ea 02             	shr    $0x2,%edx
  801aea:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801af1:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801af3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af6:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801afd:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b04:	00 
  801b05:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0c:	eb 0a                	jmp    801b18 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b0e:	83 c0 01             	add    $0x1,%eax
  801b11:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b15:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b18:	39 d0                	cmp    %edx,%eax
  801b1a:	75 f2                	jne    801b0e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	56                   	push   %esi
  801b20:	ff 75 08             	pushl  0x8(%ebp)
  801b23:	e8 53 fa ff ff       	call   80157b <spawn>
}
  801b28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b2b:	5b                   	pop    %ebx
  801b2c:	5e                   	pop    %esi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b37:	83 ec 0c             	sub    $0xc,%esp
  801b3a:	ff 75 08             	pushl  0x8(%ebp)
  801b3d:	e8 45 f2 ff ff       	call   800d87 <fd2data>
  801b42:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b44:	83 c4 08             	add    $0x8,%esp
  801b47:	68 c8 28 80 00       	push   $0x8028c8
  801b4c:	53                   	push   %ebx
  801b4d:	e8 31 ec ff ff       	call   800783 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b52:	8b 46 04             	mov    0x4(%esi),%eax
  801b55:	2b 06                	sub    (%esi),%eax
  801b57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b64:	00 00 00 
	stat->st_dev = &devpipe;
  801b67:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b6e:	30 80 00 
	return 0;
}
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
  801b76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b79:	5b                   	pop    %ebx
  801b7a:	5e                   	pop    %esi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	53                   	push   %ebx
  801b81:	83 ec 0c             	sub    $0xc,%esp
  801b84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b87:	53                   	push   %ebx
  801b88:	6a 00                	push   $0x0
  801b8a:	e8 7c f0 ff ff       	call   800c0b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b8f:	89 1c 24             	mov    %ebx,(%esp)
  801b92:	e8 f0 f1 ff ff       	call   800d87 <fd2data>
  801b97:	83 c4 08             	add    $0x8,%esp
  801b9a:	50                   	push   %eax
  801b9b:	6a 00                	push   $0x0
  801b9d:	e8 69 f0 ff ff       	call   800c0b <sys_page_unmap>
}
  801ba2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	57                   	push   %edi
  801bab:	56                   	push   %esi
  801bac:	53                   	push   %ebx
  801bad:	83 ec 1c             	sub    $0x1c,%esp
  801bb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bb3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bb5:	a1 04 40 80 00       	mov    0x804004,%eax
  801bba:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	ff 75 e0             	pushl  -0x20(%ebp)
  801bc3:	e8 1f 05 00 00       	call   8020e7 <pageref>
  801bc8:	89 c3                	mov    %eax,%ebx
  801bca:	89 3c 24             	mov    %edi,(%esp)
  801bcd:	e8 15 05 00 00       	call   8020e7 <pageref>
  801bd2:	83 c4 10             	add    $0x10,%esp
  801bd5:	39 c3                	cmp    %eax,%ebx
  801bd7:	0f 94 c1             	sete   %cl
  801bda:	0f b6 c9             	movzbl %cl,%ecx
  801bdd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801be0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801be6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801be9:	39 ce                	cmp    %ecx,%esi
  801beb:	74 1b                	je     801c08 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801bed:	39 c3                	cmp    %eax,%ebx
  801bef:	75 c4                	jne    801bb5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bf1:	8b 42 58             	mov    0x58(%edx),%eax
  801bf4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801bf7:	50                   	push   %eax
  801bf8:	56                   	push   %esi
  801bf9:	68 cf 28 80 00       	push   $0x8028cf
  801bfe:	e8 b1 e5 ff ff       	call   8001b4 <cprintf>
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	eb ad                	jmp    801bb5 <_pipeisclosed+0xe>
	}
}
  801c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5e                   	pop    %esi
  801c10:	5f                   	pop    %edi
  801c11:	5d                   	pop    %ebp
  801c12:	c3                   	ret    

00801c13 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	57                   	push   %edi
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	83 ec 28             	sub    $0x28,%esp
  801c1c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c1f:	56                   	push   %esi
  801c20:	e8 62 f1 ff ff       	call   800d87 <fd2data>
  801c25:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c2f:	eb 4b                	jmp    801c7c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c31:	89 da                	mov    %ebx,%edx
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	e8 6d ff ff ff       	call   801ba7 <_pipeisclosed>
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	75 48                	jne    801c86 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c3e:	e8 24 ef ff ff       	call   800b67 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c43:	8b 43 04             	mov    0x4(%ebx),%eax
  801c46:	8b 0b                	mov    (%ebx),%ecx
  801c48:	8d 51 20             	lea    0x20(%ecx),%edx
  801c4b:	39 d0                	cmp    %edx,%eax
  801c4d:	73 e2                	jae    801c31 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c52:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c56:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c59:	89 c2                	mov    %eax,%edx
  801c5b:	c1 fa 1f             	sar    $0x1f,%edx
  801c5e:	89 d1                	mov    %edx,%ecx
  801c60:	c1 e9 1b             	shr    $0x1b,%ecx
  801c63:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c66:	83 e2 1f             	and    $0x1f,%edx
  801c69:	29 ca                	sub    %ecx,%edx
  801c6b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c6f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c73:	83 c0 01             	add    $0x1,%eax
  801c76:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c79:	83 c7 01             	add    $0x1,%edi
  801c7c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7f:	75 c2                	jne    801c43 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c81:	8b 45 10             	mov    0x10(%ebp),%eax
  801c84:	eb 05                	jmp    801c8b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c86:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5f                   	pop    %edi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	57                   	push   %edi
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	83 ec 18             	sub    $0x18,%esp
  801c9c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c9f:	57                   	push   %edi
  801ca0:	e8 e2 f0 ff ff       	call   800d87 <fd2data>
  801ca5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  801caf:	eb 3d                	jmp    801cee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cb1:	85 db                	test   %ebx,%ebx
  801cb3:	74 04                	je     801cb9 <devpipe_read+0x26>
				return i;
  801cb5:	89 d8                	mov    %ebx,%eax
  801cb7:	eb 44                	jmp    801cfd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cb9:	89 f2                	mov    %esi,%edx
  801cbb:	89 f8                	mov    %edi,%eax
  801cbd:	e8 e5 fe ff ff       	call   801ba7 <_pipeisclosed>
  801cc2:	85 c0                	test   %eax,%eax
  801cc4:	75 32                	jne    801cf8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cc6:	e8 9c ee ff ff       	call   800b67 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ccb:	8b 06                	mov    (%esi),%eax
  801ccd:	3b 46 04             	cmp    0x4(%esi),%eax
  801cd0:	74 df                	je     801cb1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cd2:	99                   	cltd   
  801cd3:	c1 ea 1b             	shr    $0x1b,%edx
  801cd6:	01 d0                	add    %edx,%eax
  801cd8:	83 e0 1f             	and    $0x1f,%eax
  801cdb:	29 d0                	sub    %edx,%eax
  801cdd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ce5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ce8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ceb:	83 c3 01             	add    $0x1,%ebx
  801cee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cf1:	75 d8                	jne    801ccb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf6:	eb 05                	jmp    801cfd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801cf8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5f                   	pop    %edi
  801d03:	5d                   	pop    %ebp
  801d04:	c3                   	ret    

00801d05 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	56                   	push   %esi
  801d09:	53                   	push   %ebx
  801d0a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	e8 88 f0 ff ff       	call   800d9e <fd_alloc>
  801d16:	83 c4 10             	add    $0x10,%esp
  801d19:	89 c2                	mov    %eax,%edx
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	0f 88 2c 01 00 00    	js     801e4f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d23:	83 ec 04             	sub    $0x4,%esp
  801d26:	68 07 04 00 00       	push   $0x407
  801d2b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 51 ee ff ff       	call   800b86 <sys_page_alloc>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	89 c2                	mov    %eax,%edx
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	0f 88 0d 01 00 00    	js     801e4f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d48:	50                   	push   %eax
  801d49:	e8 50 f0 ff ff       	call   800d9e <fd_alloc>
  801d4e:	89 c3                	mov    %eax,%ebx
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	85 c0                	test   %eax,%eax
  801d55:	0f 88 e2 00 00 00    	js     801e3d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5b:	83 ec 04             	sub    $0x4,%esp
  801d5e:	68 07 04 00 00       	push   $0x407
  801d63:	ff 75 f0             	pushl  -0x10(%ebp)
  801d66:	6a 00                	push   $0x0
  801d68:	e8 19 ee ff ff       	call   800b86 <sys_page_alloc>
  801d6d:	89 c3                	mov    %eax,%ebx
  801d6f:	83 c4 10             	add    $0x10,%esp
  801d72:	85 c0                	test   %eax,%eax
  801d74:	0f 88 c3 00 00 00    	js     801e3d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d7a:	83 ec 0c             	sub    $0xc,%esp
  801d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d80:	e8 02 f0 ff ff       	call   800d87 <fd2data>
  801d85:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d87:	83 c4 0c             	add    $0xc,%esp
  801d8a:	68 07 04 00 00       	push   $0x407
  801d8f:	50                   	push   %eax
  801d90:	6a 00                	push   $0x0
  801d92:	e8 ef ed ff ff       	call   800b86 <sys_page_alloc>
  801d97:	89 c3                	mov    %eax,%ebx
  801d99:	83 c4 10             	add    $0x10,%esp
  801d9c:	85 c0                	test   %eax,%eax
  801d9e:	0f 88 89 00 00 00    	js     801e2d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da4:	83 ec 0c             	sub    $0xc,%esp
  801da7:	ff 75 f0             	pushl  -0x10(%ebp)
  801daa:	e8 d8 ef ff ff       	call   800d87 <fd2data>
  801daf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801db6:	50                   	push   %eax
  801db7:	6a 00                	push   $0x0
  801db9:	56                   	push   %esi
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 08 ee ff ff       	call   800bc9 <sys_page_map>
  801dc1:	89 c3                	mov    %eax,%ebx
  801dc3:	83 c4 20             	add    $0x20,%esp
  801dc6:	85 c0                	test   %eax,%eax
  801dc8:	78 55                	js     801e1f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ddf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801de8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ded:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfa:	e8 78 ef ff ff       	call   800d77 <fd2num>
  801dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e02:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e04:	83 c4 04             	add    $0x4,%esp
  801e07:	ff 75 f0             	pushl  -0x10(%ebp)
  801e0a:	e8 68 ef ff ff       	call   800d77 <fd2num>
  801e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e12:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1d:	eb 30                	jmp    801e4f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e1f:	83 ec 08             	sub    $0x8,%esp
  801e22:	56                   	push   %esi
  801e23:	6a 00                	push   $0x0
  801e25:	e8 e1 ed ff ff       	call   800c0b <sys_page_unmap>
  801e2a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e2d:	83 ec 08             	sub    $0x8,%esp
  801e30:	ff 75 f0             	pushl  -0x10(%ebp)
  801e33:	6a 00                	push   $0x0
  801e35:	e8 d1 ed ff ff       	call   800c0b <sys_page_unmap>
  801e3a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e3d:	83 ec 08             	sub    $0x8,%esp
  801e40:	ff 75 f4             	pushl  -0xc(%ebp)
  801e43:	6a 00                	push   $0x0
  801e45:	e8 c1 ed ff ff       	call   800c0b <sys_page_unmap>
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e4f:	89 d0                	mov    %edx,%eax
  801e51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5d                   	pop    %ebp
  801e57:	c3                   	ret    

00801e58 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	ff 75 08             	pushl  0x8(%ebp)
  801e65:	e8 83 ef ff ff       	call   800ded <fd_lookup>
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	78 18                	js     801e89 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	e8 0b ef ff ff       	call   800d87 <fd2data>
	return _pipeisclosed(fd, p);
  801e7c:	89 c2                	mov    %eax,%edx
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	e8 21 fd ff ff       	call   801ba7 <_pipeisclosed>
  801e86:	83 c4 10             	add    $0x10,%esp
}
  801e89:	c9                   	leave  
  801e8a:	c3                   	ret    

00801e8b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e9b:	68 e7 28 80 00       	push   $0x8028e7
  801ea0:	ff 75 0c             	pushl  0xc(%ebp)
  801ea3:	e8 db e8 ff ff       	call   800783 <strcpy>
	return 0;
}
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	57                   	push   %edi
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ebb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ec0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec6:	eb 2d                	jmp    801ef5 <devcons_write+0x46>
		m = n - tot;
  801ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ecb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ecd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ed0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ed5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ed8:	83 ec 04             	sub    $0x4,%esp
  801edb:	53                   	push   %ebx
  801edc:	03 45 0c             	add    0xc(%ebp),%eax
  801edf:	50                   	push   %eax
  801ee0:	57                   	push   %edi
  801ee1:	e8 2f ea ff ff       	call   800915 <memmove>
		sys_cputs(buf, m);
  801ee6:	83 c4 08             	add    $0x8,%esp
  801ee9:	53                   	push   %ebx
  801eea:	57                   	push   %edi
  801eeb:	e8 da eb ff ff       	call   800aca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ef0:	01 de                	add    %ebx,%esi
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	89 f0                	mov    %esi,%eax
  801ef7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801efa:	72 cc                	jb     801ec8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	83 ec 08             	sub    $0x8,%esp
  801f0a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f13:	74 2a                	je     801f3f <devcons_read+0x3b>
  801f15:	eb 05                	jmp    801f1c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f17:	e8 4b ec ff ff       	call   800b67 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f1c:	e8 c7 eb ff ff       	call   800ae8 <sys_cgetc>
  801f21:	85 c0                	test   %eax,%eax
  801f23:	74 f2                	je     801f17 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f25:	85 c0                	test   %eax,%eax
  801f27:	78 16                	js     801f3f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f29:	83 f8 04             	cmp    $0x4,%eax
  801f2c:	74 0c                	je     801f3a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f31:	88 02                	mov    %al,(%edx)
	return 1;
  801f33:	b8 01 00 00 00       	mov    $0x1,%eax
  801f38:	eb 05                	jmp    801f3f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f3a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f3f:	c9                   	leave  
  801f40:	c3                   	ret    

00801f41 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f47:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f4d:	6a 01                	push   $0x1
  801f4f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f52:	50                   	push   %eax
  801f53:	e8 72 eb ff ff       	call   800aca <sys_cputs>
}
  801f58:	83 c4 10             	add    $0x10,%esp
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <getchar>:

int
getchar(void)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f63:	6a 01                	push   $0x1
  801f65:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f68:	50                   	push   %eax
  801f69:	6a 00                	push   $0x0
  801f6b:	e8 e3 f0 ff ff       	call   801053 <read>
	if (r < 0)
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 0f                	js     801f86 <getchar+0x29>
		return r;
	if (r < 1)
  801f77:	85 c0                	test   %eax,%eax
  801f79:	7e 06                	jle    801f81 <getchar+0x24>
		return -E_EOF;
	return c;
  801f7b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f7f:	eb 05                	jmp    801f86 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f81:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f91:	50                   	push   %eax
  801f92:	ff 75 08             	pushl  0x8(%ebp)
  801f95:	e8 53 ee ff ff       	call   800ded <fd_lookup>
  801f9a:	83 c4 10             	add    $0x10,%esp
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 11                	js     801fb2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801faa:	39 10                	cmp    %edx,(%eax)
  801fac:	0f 94 c0             	sete   %al
  801faf:	0f b6 c0             	movzbl %al,%eax
}
  801fb2:	c9                   	leave  
  801fb3:	c3                   	ret    

00801fb4 <opencons>:

int
opencons(void)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbd:	50                   	push   %eax
  801fbe:	e8 db ed ff ff       	call   800d9e <fd_alloc>
  801fc3:	83 c4 10             	add    $0x10,%esp
		return r;
  801fc6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fc8:	85 c0                	test   %eax,%eax
  801fca:	78 3e                	js     80200a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fcc:	83 ec 04             	sub    $0x4,%esp
  801fcf:	68 07 04 00 00       	push   $0x407
  801fd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd7:	6a 00                	push   $0x0
  801fd9:	e8 a8 eb ff ff       	call   800b86 <sys_page_alloc>
  801fde:	83 c4 10             	add    $0x10,%esp
		return r;
  801fe1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	78 23                	js     80200a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fe7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ffc:	83 ec 0c             	sub    $0xc,%esp
  801fff:	50                   	push   %eax
  802000:	e8 72 ed ff ff       	call   800d77 <fd2num>
  802005:	89 c2                	mov    %eax,%edx
  802007:	83 c4 10             	add    $0x10,%esp
}
  80200a:	89 d0                	mov    %edx,%eax
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802016:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  802019:	83 ec 0c             	sub    $0xc,%esp
  80201c:	ff 75 0c             	pushl  0xc(%ebp)
  80201f:	e8 12 ed ff ff       	call   800d36 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  802024:	83 c4 10             	add    $0x10,%esp
  802027:	85 f6                	test   %esi,%esi
  802029:	74 1c                	je     802047 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  80202b:	a1 04 40 80 00       	mov    0x804004,%eax
  802030:	8b 40 78             	mov    0x78(%eax),%eax
  802033:	89 06                	mov    %eax,(%esi)
  802035:	eb 10                	jmp    802047 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  802037:	83 ec 0c             	sub    $0xc,%esp
  80203a:	68 f3 28 80 00       	push   $0x8028f3
  80203f:	e8 70 e1 ff ff       	call   8001b4 <cprintf>
  802044:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  802047:	a1 04 40 80 00       	mov    0x804004,%eax
  80204c:	8b 50 74             	mov    0x74(%eax),%edx
  80204f:	85 d2                	test   %edx,%edx
  802051:	74 e4                	je     802037 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  802053:	85 db                	test   %ebx,%ebx
  802055:	74 05                	je     80205c <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  802057:	8b 40 74             	mov    0x74(%eax),%eax
  80205a:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80205c:	a1 04 40 80 00       	mov    0x804004,%eax
  802061:	8b 40 70             	mov    0x70(%eax),%eax

}
  802064:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802067:	5b                   	pop    %ebx
  802068:	5e                   	pop    %esi
  802069:	5d                   	pop    %ebp
  80206a:	c3                   	ret    

0080206b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	57                   	push   %edi
  80206f:	56                   	push   %esi
  802070:	53                   	push   %ebx
  802071:	83 ec 0c             	sub    $0xc,%esp
  802074:	8b 7d 08             	mov    0x8(%ebp),%edi
  802077:	8b 75 0c             	mov    0xc(%ebp),%esi
  80207a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  80207d:	85 db                	test   %ebx,%ebx
  80207f:	75 13                	jne    802094 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  802081:	6a 00                	push   $0x0
  802083:	68 00 00 c0 ee       	push   $0xeec00000
  802088:	56                   	push   %esi
  802089:	57                   	push   %edi
  80208a:	e8 84 ec ff ff       	call   800d13 <sys_ipc_try_send>
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	eb 0e                	jmp    8020a2 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  802094:	ff 75 14             	pushl  0x14(%ebp)
  802097:	53                   	push   %ebx
  802098:	56                   	push   %esi
  802099:	57                   	push   %edi
  80209a:	e8 74 ec ff ff       	call   800d13 <sys_ipc_try_send>
  80209f:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8020a2:	85 c0                	test   %eax,%eax
  8020a4:	75 d7                	jne    80207d <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8020a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020b9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020bc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020c2:	8b 52 50             	mov    0x50(%edx),%edx
  8020c5:	39 ca                	cmp    %ecx,%edx
  8020c7:	75 0d                	jne    8020d6 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020c9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020cc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020d1:	8b 40 48             	mov    0x48(%eax),%eax
  8020d4:	eb 0f                	jmp    8020e5 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d6:	83 c0 01             	add    $0x1,%eax
  8020d9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020de:	75 d9                	jne    8020b9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    

008020e7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ed:	89 d0                	mov    %edx,%eax
  8020ef:	c1 e8 16             	shr    $0x16,%eax
  8020f2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020fe:	f6 c1 01             	test   $0x1,%cl
  802101:	74 1d                	je     802120 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802103:	c1 ea 0c             	shr    $0xc,%edx
  802106:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80210d:	f6 c2 01             	test   $0x1,%dl
  802110:	74 0e                	je     802120 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802112:	c1 ea 0c             	shr    $0xc,%edx
  802115:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80211c:	ef 
  80211d:	0f b7 c0             	movzwl %ax,%eax
}
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

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
