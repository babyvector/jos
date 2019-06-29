
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 00 10 80 00       	push   $0x801000
  80004a:	e8 1c 01 00 00       	call   80016b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 ab 0a 00 00       	call   800aff <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 62 0a 00 00       	call   800abe <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 7b 0c 00 00       	call   800cec <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 6f 0a 00 00       	call   800aff <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 eb 09 00 00       	call   800abe <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 1a                	jne    800111 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 79 09 00 00       	call   800a81 <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	68 d8 00 80 00       	push   $0x8000d8
  800149:	e8 54 01 00 00       	call   8002a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	83 c4 08             	add    $0x8,%esp
  800151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 1e 09 00 00       	call   800a81 <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	50                   	push   %eax
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	e8 9d ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 1c             	sub    $0x1c,%esp
  800188:	89 c7                	mov    %eax,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800195:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800198:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80019b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a6:	39 d3                	cmp    %edx,%ebx
  8001a8:	72 05                	jb     8001af <printnum+0x30>
  8001aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ad:	77 45                	ja     8001f4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	ff 75 18             	pushl  0x18(%ebp)
  8001b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001bb:	53                   	push   %ebx
  8001bc:	ff 75 10             	pushl  0x10(%ebp)
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ce:	e8 8d 0b 00 00       	call   800d60 <__udivdi3>
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	52                   	push   %edx
  8001d7:	50                   	push   %eax
  8001d8:	89 f2                	mov    %esi,%edx
  8001da:	89 f8                	mov    %edi,%eax
  8001dc:	e8 9e ff ff ff       	call   80017f <printnum>
  8001e1:	83 c4 20             	add    $0x20,%esp
  8001e4:	eb 18                	jmp    8001fe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff d7                	call   *%edi
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	eb 03                	jmp    8001f7 <printnum+0x78>
  8001f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	85 db                	test   %ebx,%ebx
  8001fc:	7f e8                	jg     8001e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	56                   	push   %esi
  800202:	83 ec 04             	sub    $0x4,%esp
  800205:	ff 75 e4             	pushl  -0x1c(%ebp)
  800208:	ff 75 e0             	pushl  -0x20(%ebp)
  80020b:	ff 75 dc             	pushl  -0x24(%ebp)
  80020e:	ff 75 d8             	pushl  -0x28(%ebp)
  800211:	e8 7a 0c 00 00       	call   800e90 <__umoddi3>
  800216:	83 c4 14             	add    $0x14,%esp
  800219:	0f be 80 26 10 80 00 	movsbl 0x801026(%eax),%eax
  800220:	50                   	push   %eax
  800221:	ff d7                	call   *%edi
}
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800231:	83 fa 01             	cmp    $0x1,%edx
  800234:	7e 0e                	jle    800244 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 08             	lea    0x8(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	8b 52 04             	mov    0x4(%edx),%edx
  800242:	eb 22                	jmp    800266 <getuint+0x38>
	else if (lflag)
  800244:	85 d2                	test   %edx,%edx
  800246:	74 10                	je     800258 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	ba 00 00 00 00       	mov    $0x0,%edx
  800256:	eb 0e                	jmp    800266 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800272:	8b 10                	mov    (%eax),%edx
  800274:	3b 50 04             	cmp    0x4(%eax),%edx
  800277:	73 0a                	jae    800283 <sprintputch+0x1b>
		*b->buf++ = ch;
  800279:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	88 02                	mov    %al,(%edx)
}
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028e:	50                   	push   %eax
  80028f:	ff 75 10             	pushl  0x10(%ebp)
  800292:	ff 75 0c             	pushl  0xc(%ebp)
  800295:	ff 75 08             	pushl  0x8(%ebp)
  800298:	e8 05 00 00 00       	call   8002a2 <vprintfmt>
	va_end(ap);
}
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 2c             	sub    $0x2c,%esp
  8002ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b4:	eb 12                	jmp    8002c8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	0f 84 d3 03 00 00    	je     800691 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	53                   	push   %ebx
  8002c2:	50                   	push   %eax
  8002c3:	ff d6                	call   *%esi
  8002c5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c8:	83 c7 01             	add    $0x1,%edi
  8002cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002cf:	83 f8 25             	cmp    $0x25,%eax
  8002d2:	75 e2                	jne    8002b6 <vprintfmt+0x14>
  8002d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 07                	jmp    8002fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8d 47 01             	lea    0x1(%edi),%eax
  8002fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800301:	0f b6 07             	movzbl (%edi),%eax
  800304:	0f b6 c8             	movzbl %al,%ecx
  800307:	83 e8 23             	sub    $0x23,%eax
  80030a:	3c 55                	cmp    $0x55,%al
  80030c:	0f 87 64 03 00 00    	ja     800676 <vprintfmt+0x3d4>
  800312:	0f b6 c0             	movzbl %al,%eax
  800315:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800323:	eb d6                	jmp    8002fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800328:	b8 00 00 00 00       	mov    $0x0,%eax
  80032d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800330:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800333:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800337:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80033a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80033d:	83 fa 09             	cmp    $0x9,%edx
  800340:	77 39                	ja     80037b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800342:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800345:	eb e9                	jmp    800330 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800347:	8b 45 14             	mov    0x14(%ebp),%eax
  80034a:	8d 48 04             	lea    0x4(%eax),%ecx
  80034d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800350:	8b 00                	mov    (%eax),%eax
  800352:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800358:	eb 27                	jmp    800381 <vprintfmt+0xdf>
  80035a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035d:	85 c0                	test   %eax,%eax
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800364:	0f 49 c8             	cmovns %eax,%ecx
  800367:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	eb 8c                	jmp    8002fb <vprintfmt+0x59>
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800372:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800379:	eb 80                	jmp    8002fb <vprintfmt+0x59>
  80037b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037e:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800381:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800385:	0f 89 70 ff ff ff    	jns    8002fb <vprintfmt+0x59>
				width = precision, precision = -1;
  80038b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80038e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800391:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800398:	e9 5e ff ff ff       	jmp    8002fb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a3:	e9 53 ff ff ff       	jmp    8002fb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	53                   	push   %ebx
  8003b5:	ff 30                	pushl  (%eax)
  8003b7:	ff d6                	call   *%esi
			break;
  8003b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bf:	e9 04 ff ff ff       	jmp    8002c8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	99                   	cltd   
  8003d0:	31 d0                	xor    %edx,%eax
  8003d2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d4:	83 f8 08             	cmp    $0x8,%eax
  8003d7:	7f 0b                	jg     8003e4 <vprintfmt+0x142>
  8003d9:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	75 18                	jne    8003fc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003e4:	50                   	push   %eax
  8003e5:	68 3e 10 80 00       	push   $0x80103e
  8003ea:	53                   	push   %ebx
  8003eb:	56                   	push   %esi
  8003ec:	e8 94 fe ff ff       	call   800285 <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f7:	e9 cc fe ff ff       	jmp    8002c8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003fc:	52                   	push   %edx
  8003fd:	68 47 10 80 00       	push   $0x801047
  800402:	53                   	push   %ebx
  800403:	56                   	push   %esi
  800404:	e8 7c fe ff ff       	call   800285 <printfmt>
  800409:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	e9 b4 fe ff ff       	jmp    8002c8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041f:	85 ff                	test   %edi,%edi
  800421:	b8 37 10 80 00       	mov    $0x801037,%eax
  800426:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042d:	0f 8e 94 00 00 00    	jle    8004c7 <vprintfmt+0x225>
  800433:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800437:	0f 84 98 00 00 00    	je     8004d5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	ff 75 c8             	pushl  -0x38(%ebp)
  800443:	57                   	push   %edi
  800444:	e8 d0 02 00 00       	call   800719 <strnlen>
  800449:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044c:	29 c1                	sub    %eax,%ecx
  80044e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800451:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800454:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	eb 0f                	jmp    800471 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	83 ef 01             	sub    $0x1,%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	85 ff                	test   %edi,%edi
  800473:	7f ed                	jg     800462 <vprintfmt+0x1c0>
  800475:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800478:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80047b:	85 c9                	test   %ecx,%ecx
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	0f 49 c1             	cmovns %ecx,%eax
  800485:	29 c1                	sub    %eax,%ecx
  800487:	89 75 08             	mov    %esi,0x8(%ebp)
  80048a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80048d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800490:	89 cb                	mov    %ecx,%ebx
  800492:	eb 4d                	jmp    8004e1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800494:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800498:	74 1b                	je     8004b5 <vprintfmt+0x213>
  80049a:	0f be c0             	movsbl %al,%eax
  80049d:	83 e8 20             	sub    $0x20,%eax
  8004a0:	83 f8 5e             	cmp    $0x5e,%eax
  8004a3:	76 10                	jbe    8004b5 <vprintfmt+0x213>
					putch('?', putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	6a 3f                	push   $0x3f
  8004ad:	ff 55 08             	call   *0x8(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	eb 0d                	jmp    8004c2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 0c             	pushl  0xc(%ebp)
  8004bb:	52                   	push   %edx
  8004bc:	ff 55 08             	call   *0x8(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c2:	83 eb 01             	sub    $0x1,%ebx
  8004c5:	eb 1a                	jmp    8004e1 <vprintfmt+0x23f>
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d3:	eb 0c                	jmp    8004e1 <vprintfmt+0x23f>
  8004d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d8:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004de:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e1:	83 c7 01             	add    $0x1,%edi
  8004e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e8:	0f be d0             	movsbl %al,%edx
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 23                	je     800512 <vprintfmt+0x270>
  8004ef:	85 f6                	test   %esi,%esi
  8004f1:	78 a1                	js     800494 <vprintfmt+0x1f2>
  8004f3:	83 ee 01             	sub    $0x1,%esi
  8004f6:	79 9c                	jns    800494 <vprintfmt+0x1f2>
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800500:	eb 18                	jmp    80051a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	53                   	push   %ebx
  800506:	6a 20                	push   $0x20
  800508:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	eb 08                	jmp    80051a <vprintfmt+0x278>
  800512:	89 df                	mov    %ebx,%edi
  800514:	8b 75 08             	mov    0x8(%ebp),%esi
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f e4                	jg     800502 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800521:	e9 a2 fd ff ff       	jmp    8002c8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800526:	83 fa 01             	cmp    $0x1,%edx
  800529:	7e 16                	jle    800541 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 08             	lea    0x8(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 50 04             	mov    0x4(%eax),%edx
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80053c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80053f:	eb 32                	jmp    800573 <vprintfmt+0x2d1>
	else if (lflag)
  800541:	85 d2                	test   %edx,%edx
  800543:	74 18                	je     80055d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800553:	89 c1                	mov    %eax,%ecx
  800555:	c1 f9 1f             	sar    $0x1f,%ecx
  800558:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80055b:	eb 16                	jmp    800573 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80056b:	89 c1                	mov    %eax,%ecx
  80056d:	c1 f9 1f             	sar    $0x1f,%ecx
  800570:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800573:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800576:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80057f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800584:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800588:	0f 89 b0 00 00 00    	jns    80063e <vprintfmt+0x39c>
				putch('-', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 2d                	push   $0x2d
  800594:	ff d6                	call   *%esi
				num = -(long long) num;
  800596:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800599:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80059c:	f7 d8                	neg    %eax
  80059e:	83 d2 00             	adc    $0x0,%edx
  8005a1:	f7 da                	neg    %edx
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 88 00 00 00       	jmp    80063e <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 70 fc ff ff       	call   80022e <getuint>
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005c9:	eb 73                	jmp    80063e <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 5b fc ff ff       	call   80022e <getuint>
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 58                	push   $0x58
  8005df:	ff d6                	call   *%esi
			putch('X', putdat);
  8005e1:	83 c4 08             	add    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	6a 58                	push   $0x58
  8005e7:	ff d6                	call   *%esi
			putch('X', putdat);
  8005e9:	83 c4 08             	add    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	6a 58                	push   $0x58
  8005ef:	ff d6                	call   *%esi
			goto number;
  8005f1:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005f4:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005f9:	eb 43                	jmp    80063e <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 30                	push   $0x30
  800601:	ff d6                	call   *%esi
			putch('x', putdat);
  800603:	83 c4 08             	add    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 78                	push   $0x78
  800609:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	ba 00 00 00 00       	mov    $0x0,%edx
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800621:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800624:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800629:	eb 13                	jmp    80063e <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 fb fb ff ff       	call   80022e <getuint>
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800639:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800645:	52                   	push   %edx
  800646:	ff 75 e0             	pushl  -0x20(%ebp)
  800649:	50                   	push   %eax
  80064a:	ff 75 dc             	pushl  -0x24(%ebp)
  80064d:	ff 75 d8             	pushl  -0x28(%ebp)
  800650:	89 da                	mov    %ebx,%edx
  800652:	89 f0                	mov    %esi,%eax
  800654:	e8 26 fb ff ff       	call   80017f <printnum>
			break;
  800659:	83 c4 20             	add    $0x20,%esp
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065f:	e9 64 fc ff ff       	jmp    8002c8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	51                   	push   %ecx
  800669:	ff d6                	call   *%esi
			break;
  80066b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800671:	e9 52 fc ff ff       	jmp    8002c8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 25                	push   $0x25
  80067c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	eb 03                	jmp    800686 <vprintfmt+0x3e4>
  800683:	83 ef 01             	sub    $0x1,%edi
  800686:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80068a:	75 f7                	jne    800683 <vprintfmt+0x3e1>
  80068c:	e9 37 fc ff ff       	jmp    8002c8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800691:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800694:	5b                   	pop    %ebx
  800695:	5e                   	pop    %esi
  800696:	5f                   	pop    %edi
  800697:	5d                   	pop    %ebp
  800698:	c3                   	ret    

00800699 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800699:	55                   	push   %ebp
  80069a:	89 e5                	mov    %esp,%ebp
  80069c:	83 ec 18             	sub    $0x18,%esp
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006a8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ac:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006b6:	85 c0                	test   %eax,%eax
  8006b8:	74 26                	je     8006e0 <vsnprintf+0x47>
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	7e 22                	jle    8006e0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006be:	ff 75 14             	pushl  0x14(%ebp)
  8006c1:	ff 75 10             	pushl  0x10(%ebp)
  8006c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006c7:	50                   	push   %eax
  8006c8:	68 68 02 80 00       	push   $0x800268
  8006cd:	e8 d0 fb ff ff       	call   8002a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	eb 05                	jmp    8006e5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006f0:	50                   	push   %eax
  8006f1:	ff 75 10             	pushl  0x10(%ebp)
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	ff 75 08             	pushl  0x8(%ebp)
  8006fa:	e8 9a ff ff ff       	call   800699 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800707:	b8 00 00 00 00       	mov    $0x0,%eax
  80070c:	eb 03                	jmp    800711 <strlen+0x10>
		n++;
  80070e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800711:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800715:	75 f7                	jne    80070e <strlen+0xd>
		n++;
	return n;
}
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800722:	ba 00 00 00 00       	mov    $0x0,%edx
  800727:	eb 03                	jmp    80072c <strnlen+0x13>
		n++;
  800729:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072c:	39 c2                	cmp    %eax,%edx
  80072e:	74 08                	je     800738 <strnlen+0x1f>
  800730:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800734:	75 f3                	jne    800729 <strnlen+0x10>
  800736:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	53                   	push   %ebx
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800744:	89 c2                	mov    %eax,%edx
  800746:	83 c2 01             	add    $0x1,%edx
  800749:	83 c1 01             	add    $0x1,%ecx
  80074c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800750:	88 5a ff             	mov    %bl,-0x1(%edx)
  800753:	84 db                	test   %bl,%bl
  800755:	75 ef                	jne    800746 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800757:	5b                   	pop    %ebx
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800761:	53                   	push   %ebx
  800762:	e8 9a ff ff ff       	call   800701 <strlen>
  800767:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80076a:	ff 75 0c             	pushl  0xc(%ebp)
  80076d:	01 d8                	add    %ebx,%eax
  80076f:	50                   	push   %eax
  800770:	e8 c5 ff ff ff       	call   80073a <strcpy>
	return dst;
}
  800775:	89 d8                	mov    %ebx,%eax
  800777:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	56                   	push   %esi
  800780:	53                   	push   %ebx
  800781:	8b 75 08             	mov    0x8(%ebp),%esi
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800787:	89 f3                	mov    %esi,%ebx
  800789:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078c:	89 f2                	mov    %esi,%edx
  80078e:	eb 0f                	jmp    80079f <strncpy+0x23>
		*dst++ = *src;
  800790:	83 c2 01             	add    $0x1,%edx
  800793:	0f b6 01             	movzbl (%ecx),%eax
  800796:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800799:	80 39 01             	cmpb   $0x1,(%ecx)
  80079c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079f:	39 da                	cmp    %ebx,%edx
  8007a1:	75 ed                	jne    800790 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007a3:	89 f0                	mov    %esi,%eax
  8007a5:	5b                   	pop    %ebx
  8007a6:	5e                   	pop    %esi
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	56                   	push   %esi
  8007ad:	53                   	push   %ebx
  8007ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8007b7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	74 21                	je     8007de <strlcpy+0x35>
  8007bd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007c1:	89 f2                	mov    %esi,%edx
  8007c3:	eb 09                	jmp    8007ce <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	83 c1 01             	add    $0x1,%ecx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ce:	39 c2                	cmp    %eax,%edx
  8007d0:	74 09                	je     8007db <strlcpy+0x32>
  8007d2:	0f b6 19             	movzbl (%ecx),%ebx
  8007d5:	84 db                	test   %bl,%bl
  8007d7:	75 ec                	jne    8007c5 <strlcpy+0x1c>
  8007d9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007db:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007de:	29 f0                	sub    %esi,%eax
}
  8007e0:	5b                   	pop    %ebx
  8007e1:	5e                   	pop    %esi
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ed:	eb 06                	jmp    8007f5 <strcmp+0x11>
		p++, q++;
  8007ef:	83 c1 01             	add    $0x1,%ecx
  8007f2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007f5:	0f b6 01             	movzbl (%ecx),%eax
  8007f8:	84 c0                	test   %al,%al
  8007fa:	74 04                	je     800800 <strcmp+0x1c>
  8007fc:	3a 02                	cmp    (%edx),%al
  8007fe:	74 ef                	je     8007ef <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800800:	0f b6 c0             	movzbl %al,%eax
  800803:	0f b6 12             	movzbl (%edx),%edx
  800806:	29 d0                	sub    %edx,%eax
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 55 0c             	mov    0xc(%ebp),%edx
  800814:	89 c3                	mov    %eax,%ebx
  800816:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800819:	eb 06                	jmp    800821 <strncmp+0x17>
		n--, p++, q++;
  80081b:	83 c0 01             	add    $0x1,%eax
  80081e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800821:	39 d8                	cmp    %ebx,%eax
  800823:	74 15                	je     80083a <strncmp+0x30>
  800825:	0f b6 08             	movzbl (%eax),%ecx
  800828:	84 c9                	test   %cl,%cl
  80082a:	74 04                	je     800830 <strncmp+0x26>
  80082c:	3a 0a                	cmp    (%edx),%cl
  80082e:	74 eb                	je     80081b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800830:	0f b6 00             	movzbl (%eax),%eax
  800833:	0f b6 12             	movzbl (%edx),%edx
  800836:	29 d0                	sub    %edx,%eax
  800838:	eb 05                	jmp    80083f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80083f:	5b                   	pop    %ebx
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 08             	mov    0x8(%ebp),%eax
  800848:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084c:	eb 07                	jmp    800855 <strchr+0x13>
		if (*s == c)
  80084e:	38 ca                	cmp    %cl,%dl
  800850:	74 0f                	je     800861 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800852:	83 c0 01             	add    $0x1,%eax
  800855:	0f b6 10             	movzbl (%eax),%edx
  800858:	84 d2                	test   %dl,%dl
  80085a:	75 f2                	jne    80084e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086d:	eb 03                	jmp    800872 <strfind+0xf>
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800875:	38 ca                	cmp    %cl,%dl
  800877:	74 04                	je     80087d <strfind+0x1a>
  800879:	84 d2                	test   %dl,%dl
  80087b:	75 f2                	jne    80086f <strfind+0xc>
			break;
	return (char *) s;
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	57                   	push   %edi
  800883:	56                   	push   %esi
  800884:	53                   	push   %ebx
  800885:	8b 7d 08             	mov    0x8(%ebp),%edi
  800888:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80088b:	85 c9                	test   %ecx,%ecx
  80088d:	74 36                	je     8008c5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80088f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800895:	75 28                	jne    8008bf <memset+0x40>
  800897:	f6 c1 03             	test   $0x3,%cl
  80089a:	75 23                	jne    8008bf <memset+0x40>
		c &= 0xFF;
  80089c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008a0:	89 d3                	mov    %edx,%ebx
  8008a2:	c1 e3 08             	shl    $0x8,%ebx
  8008a5:	89 d6                	mov    %edx,%esi
  8008a7:	c1 e6 18             	shl    $0x18,%esi
  8008aa:	89 d0                	mov    %edx,%eax
  8008ac:	c1 e0 10             	shl    $0x10,%eax
  8008af:	09 f0                	or     %esi,%eax
  8008b1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008b3:	89 d8                	mov    %ebx,%eax
  8008b5:	09 d0                	or     %edx,%eax
  8008b7:	c1 e9 02             	shr    $0x2,%ecx
  8008ba:	fc                   	cld    
  8008bb:	f3 ab                	rep stos %eax,%es:(%edi)
  8008bd:	eb 06                	jmp    8008c5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c2:	fc                   	cld    
  8008c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008c5:	89 f8                	mov    %edi,%eax
  8008c7:	5b                   	pop    %ebx
  8008c8:	5e                   	pop    %esi
  8008c9:	5f                   	pop    %edi
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008da:	39 c6                	cmp    %eax,%esi
  8008dc:	73 35                	jae    800913 <memmove+0x47>
  8008de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008e1:	39 d0                	cmp    %edx,%eax
  8008e3:	73 2e                	jae    800913 <memmove+0x47>
		s += n;
		d += n;
  8008e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e8:	89 d6                	mov    %edx,%esi
  8008ea:	09 fe                	or     %edi,%esi
  8008ec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008f2:	75 13                	jne    800907 <memmove+0x3b>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 0e                	jne    800907 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008f9:	83 ef 04             	sub    $0x4,%edi
  8008fc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
  800902:	fd                   	std    
  800903:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800905:	eb 09                	jmp    800910 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800907:	83 ef 01             	sub    $0x1,%edi
  80090a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80090d:	fd                   	std    
  80090e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800910:	fc                   	cld    
  800911:	eb 1d                	jmp    800930 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800913:	89 f2                	mov    %esi,%edx
  800915:	09 c2                	or     %eax,%edx
  800917:	f6 c2 03             	test   $0x3,%dl
  80091a:	75 0f                	jne    80092b <memmove+0x5f>
  80091c:	f6 c1 03             	test   $0x3,%cl
  80091f:	75 0a                	jne    80092b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800921:	c1 e9 02             	shr    $0x2,%ecx
  800924:	89 c7                	mov    %eax,%edi
  800926:	fc                   	cld    
  800927:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800929:	eb 05                	jmp    800930 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80092b:	89 c7                	mov    %eax,%edi
  80092d:	fc                   	cld    
  80092e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800930:	5e                   	pop    %esi
  800931:	5f                   	pop    %edi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800937:	ff 75 10             	pushl  0x10(%ebp)
  80093a:	ff 75 0c             	pushl  0xc(%ebp)
  80093d:	ff 75 08             	pushl  0x8(%ebp)
  800940:	e8 87 ff ff ff       	call   8008cc <memmove>
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800952:	89 c6                	mov    %eax,%esi
  800954:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800957:	eb 1a                	jmp    800973 <memcmp+0x2c>
		if (*s1 != *s2)
  800959:	0f b6 08             	movzbl (%eax),%ecx
  80095c:	0f b6 1a             	movzbl (%edx),%ebx
  80095f:	38 d9                	cmp    %bl,%cl
  800961:	74 0a                	je     80096d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800963:	0f b6 c1             	movzbl %cl,%eax
  800966:	0f b6 db             	movzbl %bl,%ebx
  800969:	29 d8                	sub    %ebx,%eax
  80096b:	eb 0f                	jmp    80097c <memcmp+0x35>
		s1++, s2++;
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800973:	39 f0                	cmp    %esi,%eax
  800975:	75 e2                	jne    800959 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800987:	89 c1                	mov    %eax,%ecx
  800989:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80098c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800990:	eb 0a                	jmp    80099c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800992:	0f b6 10             	movzbl (%eax),%edx
  800995:	39 da                	cmp    %ebx,%edx
  800997:	74 07                	je     8009a0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	39 c8                	cmp    %ecx,%eax
  80099e:	72 f2                	jb     800992 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009af:	eb 03                	jmp    8009b4 <strtol+0x11>
		s++;
  8009b1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009b4:	0f b6 01             	movzbl (%ecx),%eax
  8009b7:	3c 20                	cmp    $0x20,%al
  8009b9:	74 f6                	je     8009b1 <strtol+0xe>
  8009bb:	3c 09                	cmp    $0x9,%al
  8009bd:	74 f2                	je     8009b1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009bf:	3c 2b                	cmp    $0x2b,%al
  8009c1:	75 0a                	jne    8009cd <strtol+0x2a>
		s++;
  8009c3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009cb:	eb 11                	jmp    8009de <strtol+0x3b>
  8009cd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009d2:	3c 2d                	cmp    $0x2d,%al
  8009d4:	75 08                	jne    8009de <strtol+0x3b>
		s++, neg = 1;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009de:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e4:	75 15                	jne    8009fb <strtol+0x58>
  8009e6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e9:	75 10                	jne    8009fb <strtol+0x58>
  8009eb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ef:	75 7c                	jne    800a6d <strtol+0xca>
		s += 2, base = 16;
  8009f1:	83 c1 02             	add    $0x2,%ecx
  8009f4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009f9:	eb 16                	jmp    800a11 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009fb:	85 db                	test   %ebx,%ebx
  8009fd:	75 12                	jne    800a11 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ff:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a04:	80 39 30             	cmpb   $0x30,(%ecx)
  800a07:	75 08                	jne    800a11 <strtol+0x6e>
		s++, base = 8;
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a19:	0f b6 11             	movzbl (%ecx),%edx
  800a1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	80 fb 09             	cmp    $0x9,%bl
  800a24:	77 08                	ja     800a2e <strtol+0x8b>
			dig = *s - '0';
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 30             	sub    $0x30,%edx
  800a2c:	eb 22                	jmp    800a50 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a31:	89 f3                	mov    %esi,%ebx
  800a33:	80 fb 19             	cmp    $0x19,%bl
  800a36:	77 08                	ja     800a40 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a38:	0f be d2             	movsbl %dl,%edx
  800a3b:	83 ea 57             	sub    $0x57,%edx
  800a3e:	eb 10                	jmp    800a50 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a43:	89 f3                	mov    %esi,%ebx
  800a45:	80 fb 19             	cmp    $0x19,%bl
  800a48:	77 16                	ja     800a60 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a4a:	0f be d2             	movsbl %dl,%edx
  800a4d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a53:	7d 0b                	jge    800a60 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a55:	83 c1 01             	add    $0x1,%ecx
  800a58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a5e:	eb b9                	jmp    800a19 <strtol+0x76>

	if (endptr)
  800a60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a64:	74 0d                	je     800a73 <strtol+0xd0>
		*endptr = (char *) s;
  800a66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a69:	89 0e                	mov    %ecx,(%esi)
  800a6b:	eb 06                	jmp    800a73 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	74 98                	je     800a09 <strtol+0x66>
  800a71:	eb 9e                	jmp    800a11 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a73:	89 c2                	mov    %eax,%edx
  800a75:	f7 da                	neg    %edx
  800a77:	85 ff                	test   %edi,%edi
  800a79:	0f 45 c2             	cmovne %edx,%eax
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	89 c7                	mov    %eax,%edi
  800a96:	89 c6                	mov    %eax,%esi
  800a98:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	b8 01 00 00 00       	mov    $0x1,%eax
  800aaf:	89 d1                	mov    %edx,%ecx
  800ab1:	89 d3                	mov    %edx,%ebx
  800ab3:	89 d7                	mov    %edx,%edi
  800ab5:	89 d6                	mov    %edx,%esi
  800ab7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ac7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800acc:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad4:	89 cb                	mov    %ecx,%ebx
  800ad6:	89 cf                	mov    %ecx,%edi
  800ad8:	89 ce                	mov    %ecx,%esi
  800ada:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800adc:	85 c0                	test   %eax,%eax
  800ade:	7e 17                	jle    800af7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ae0:	83 ec 0c             	sub    $0xc,%esp
  800ae3:	50                   	push   %eax
  800ae4:	6a 03                	push   $0x3
  800ae6:	68 64 12 80 00       	push   $0x801264
  800aeb:	6a 23                	push   $0x23
  800aed:	68 81 12 80 00       	push   $0x801281
  800af2:	e8 22 02 00 00       	call   800d19 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b05:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b0f:	89 d1                	mov    %edx,%ecx
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	89 d7                	mov    %edx,%edi
  800b15:	89 d6                	mov    %edx,%esi
  800b17:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <sys_yield>:

void
sys_yield(void)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b24:	ba 00 00 00 00       	mov    $0x0,%edx
  800b29:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b2e:	89 d1                	mov    %edx,%ecx
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	89 d7                	mov    %edx,%edi
  800b34:	89 d6                	mov    %edx,%esi
  800b36:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b46:	be 00 00 00 00       	mov    $0x0,%esi
  800b4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b59:	89 f7                	mov    %esi,%edi
  800b5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	7e 17                	jle    800b78 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b61:	83 ec 0c             	sub    $0xc,%esp
  800b64:	50                   	push   %eax
  800b65:	6a 04                	push   $0x4
  800b67:	68 64 12 80 00       	push   $0x801264
  800b6c:	6a 23                	push   $0x23
  800b6e:	68 81 12 80 00       	push   $0x801281
  800b73:	e8 a1 01 00 00       	call   800d19 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b89:	b8 05 00 00 00       	mov    $0x5,%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b9a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7e 17                	jle    800bba <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 05                	push   $0x5
  800ba9:	68 64 12 80 00       	push   $0x801264
  800bae:	6a 23                	push   $0x23
  800bb0:	68 81 12 80 00       	push   $0x801281
  800bb5:	e8 5f 01 00 00       	call   800d19 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdb:	89 df                	mov    %ebx,%edi
  800bdd:	89 de                	mov    %ebx,%esi
  800bdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7e 17                	jle    800bfc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be5:	83 ec 0c             	sub    $0xc,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 06                	push   $0x6
  800beb:	68 64 12 80 00       	push   $0x801264
  800bf0:	6a 23                	push   $0x23
  800bf2:	68 81 12 80 00       	push   $0x801281
  800bf7:	e8 1d 01 00 00       	call   800d19 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c12:	b8 08 00 00 00       	mov    $0x8,%eax
  800c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	89 df                	mov    %ebx,%edi
  800c1f:	89 de                	mov    %ebx,%esi
  800c21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c23:	85 c0                	test   %eax,%eax
  800c25:	7e 17                	jle    800c3e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	50                   	push   %eax
  800c2b:	6a 08                	push   $0x8
  800c2d:	68 64 12 80 00       	push   $0x801264
  800c32:	6a 23                	push   $0x23
  800c34:	68 81 12 80 00       	push   $0x801281
  800c39:	e8 db 00 00 00       	call   800d19 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c54:	b8 09 00 00 00       	mov    $0x9,%eax
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	89 df                	mov    %ebx,%edi
  800c61:	89 de                	mov    %ebx,%esi
  800c63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c65:	85 c0                	test   %eax,%eax
  800c67:	7e 17                	jle    800c80 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	50                   	push   %eax
  800c6d:	6a 09                	push   $0x9
  800c6f:	68 64 12 80 00       	push   $0x801264
  800c74:	6a 23                	push   $0x23
  800c76:	68 81 12 80 00       	push   $0x801281
  800c7b:	e8 99 00 00 00       	call   800d19 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8e:	be 00 00 00 00       	mov    $0x0,%esi
  800c93:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0c                	push   $0xc
  800cd3:	68 64 12 80 00       	push   $0x801264
  800cd8:	6a 23                	push   $0x23
  800cda:	68 81 12 80 00       	push   $0x801281
  800cdf:	e8 35 00 00 00       	call   800d19 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cf2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cf9:	75 14                	jne    800d0f <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800cfb:	83 ec 04             	sub    $0x4,%esp
  800cfe:	68 90 12 80 00       	push   $0x801290
  800d03:	6a 20                	push   $0x20
  800d05:	68 b4 12 80 00       	push   $0x8012b4
  800d0a:	e8 0a 00 00 00       	call   800d19 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d1e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d21:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d27:	e8 d3 fd ff ff       	call   800aff <sys_getenvid>
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	ff 75 0c             	pushl  0xc(%ebp)
  800d32:	ff 75 08             	pushl  0x8(%ebp)
  800d35:	56                   	push   %esi
  800d36:	50                   	push   %eax
  800d37:	68 c4 12 80 00       	push   $0x8012c4
  800d3c:	e8 2a f4 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d41:	83 c4 18             	add    $0x18,%esp
  800d44:	53                   	push   %ebx
  800d45:	ff 75 10             	pushl  0x10(%ebp)
  800d48:	e8 cd f3 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800d4d:	c7 04 24 1a 10 80 00 	movl   $0x80101a,(%esp)
  800d54:	e8 12 f4 ff ff       	call   80016b <cprintf>
  800d59:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d5c:	cc                   	int3   
  800d5d:	eb fd                	jmp    800d5c <_panic+0x43>
  800d5f:	90                   	nop

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 f6                	test   %esi,%esi
  800d79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d7d:	89 ca                	mov    %ecx,%edx
  800d7f:	89 f8                	mov    %edi,%eax
  800d81:	75 3d                	jne    800dc0 <__udivdi3+0x60>
  800d83:	39 cf                	cmp    %ecx,%edi
  800d85:	0f 87 c5 00 00 00    	ja     800e50 <__udivdi3+0xf0>
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	89 fd                	mov    %edi,%ebp
  800d8f:	75 0b                	jne    800d9c <__udivdi3+0x3c>
  800d91:	b8 01 00 00 00       	mov    $0x1,%eax
  800d96:	31 d2                	xor    %edx,%edx
  800d98:	f7 f7                	div    %edi
  800d9a:	89 c5                	mov    %eax,%ebp
  800d9c:	89 c8                	mov    %ecx,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f5                	div    %ebp
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	89 d8                	mov    %ebx,%eax
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	f7 f5                	div    %ebp
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	89 d8                	mov    %ebx,%eax
  800dae:	89 fa                	mov    %edi,%edx
  800db0:	83 c4 1c             	add    $0x1c,%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
  800db8:	90                   	nop
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	39 ce                	cmp    %ecx,%esi
  800dc2:	77 74                	ja     800e38 <__udivdi3+0xd8>
  800dc4:	0f bd fe             	bsr    %esi,%edi
  800dc7:	83 f7 1f             	xor    $0x1f,%edi
  800dca:	0f 84 98 00 00 00    	je     800e68 <__udivdi3+0x108>
  800dd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	89 c5                	mov    %eax,%ebp
  800dd9:	29 fb                	sub    %edi,%ebx
  800ddb:	d3 e6                	shl    %cl,%esi
  800ddd:	89 d9                	mov    %ebx,%ecx
  800ddf:	d3 ed                	shr    %cl,%ebp
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e0                	shl    %cl,%eax
  800de5:	09 ee                	or     %ebp,%esi
  800de7:	89 d9                	mov    %ebx,%ecx
  800de9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ded:	89 d5                	mov    %edx,%ebp
  800def:	8b 44 24 08          	mov    0x8(%esp),%eax
  800df3:	d3 ed                	shr    %cl,%ebp
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e2                	shl    %cl,%edx
  800df9:	89 d9                	mov    %ebx,%ecx
  800dfb:	d3 e8                	shr    %cl,%eax
  800dfd:	09 c2                	or     %eax,%edx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	89 ea                	mov    %ebp,%edx
  800e03:	f7 f6                	div    %esi
  800e05:	89 d5                	mov    %edx,%ebp
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	f7 64 24 0c          	mull   0xc(%esp)
  800e0d:	39 d5                	cmp    %edx,%ebp
  800e0f:	72 10                	jb     800e21 <__udivdi3+0xc1>
  800e11:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	d3 e6                	shl    %cl,%esi
  800e19:	39 c6                	cmp    %eax,%esi
  800e1b:	73 07                	jae    800e24 <__udivdi3+0xc4>
  800e1d:	39 d5                	cmp    %edx,%ebp
  800e1f:	75 03                	jne    800e24 <__udivdi3+0xc4>
  800e21:	83 eb 01             	sub    $0x1,%ebx
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 d8                	mov    %ebx,%eax
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	31 ff                	xor    %edi,%edi
  800e3a:	31 db                	xor    %ebx,%ebx
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	89 fa                	mov    %edi,%edx
  800e40:	83 c4 1c             	add    $0x1c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	f7 f7                	div    %edi
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	89 d8                	mov    %ebx,%eax
  800e5a:	89 fa                	mov    %edi,%edx
  800e5c:	83 c4 1c             	add    $0x1c,%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	39 ce                	cmp    %ecx,%esi
  800e6a:	72 0c                	jb     800e78 <__udivdi3+0x118>
  800e6c:	31 db                	xor    %ebx,%ebx
  800e6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e72:	0f 87 34 ff ff ff    	ja     800dac <__udivdi3+0x4c>
  800e78:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e7d:	e9 2a ff ff ff       	jmp    800dac <__udivdi3+0x4c>
  800e82:	66 90                	xchg   %ax,%ax
  800e84:	66 90                	xchg   %ax,%ax
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 d2                	test   %edx,%edx
  800ea9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f3                	mov    %esi,%ebx
  800eb3:	89 3c 24             	mov    %edi,(%esp)
  800eb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eba:	75 1c                	jne    800ed8 <__umoddi3+0x48>
  800ebc:	39 f7                	cmp    %esi,%edi
  800ebe:	76 50                	jbe    800f10 <__umoddi3+0x80>
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	f7 f7                	div    %edi
  800ec6:	89 d0                	mov    %edx,%eax
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	89 d0                	mov    %edx,%eax
  800edc:	77 52                	ja     800f30 <__umoddi3+0xa0>
  800ede:	0f bd ea             	bsr    %edx,%ebp
  800ee1:	83 f5 1f             	xor    $0x1f,%ebp
  800ee4:	75 5a                	jne    800f40 <__umoddi3+0xb0>
  800ee6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eea:	0f 82 e0 00 00 00    	jb     800fd0 <__umoddi3+0x140>
  800ef0:	39 0c 24             	cmp    %ecx,(%esp)
  800ef3:	0f 86 d7 00 00 00    	jbe    800fd0 <__umoddi3+0x140>
  800ef9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800efd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f01:	83 c4 1c             	add    $0x1c,%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	85 ff                	test   %edi,%edi
  800f12:	89 fd                	mov    %edi,%ebp
  800f14:	75 0b                	jne    800f21 <__umoddi3+0x91>
  800f16:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	f7 f7                	div    %edi
  800f1f:	89 c5                	mov    %eax,%ebp
  800f21:	89 f0                	mov    %esi,%eax
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	f7 f5                	div    %ebp
  800f27:	89 c8                	mov    %ecx,%eax
  800f29:	f7 f5                	div    %ebp
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	eb 99                	jmp    800ec8 <__umoddi3+0x38>
  800f2f:	90                   	nop
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	83 c4 1c             	add    $0x1c,%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
  800f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f40:	8b 34 24             	mov    (%esp),%esi
  800f43:	bf 20 00 00 00       	mov    $0x20,%edi
  800f48:	89 e9                	mov    %ebp,%ecx
  800f4a:	29 ef                	sub    %ebp,%edi
  800f4c:	d3 e0                	shl    %cl,%eax
  800f4e:	89 f9                	mov    %edi,%ecx
  800f50:	89 f2                	mov    %esi,%edx
  800f52:	d3 ea                	shr    %cl,%edx
  800f54:	89 e9                	mov    %ebp,%ecx
  800f56:	09 c2                	or     %eax,%edx
  800f58:	89 d8                	mov    %ebx,%eax
  800f5a:	89 14 24             	mov    %edx,(%esp)
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	d3 e2                	shl    %cl,%edx
  800f61:	89 f9                	mov    %edi,%ecx
  800f63:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	89 c6                	mov    %eax,%esi
  800f71:	d3 e3                	shl    %cl,%ebx
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 d0                	mov    %edx,%eax
  800f77:	d3 e8                	shr    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	09 d8                	or     %ebx,%eax
  800f7d:	89 d3                	mov    %edx,%ebx
  800f7f:	89 f2                	mov    %esi,%edx
  800f81:	f7 34 24             	divl   (%esp)
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	d3 e3                	shl    %cl,%ebx
  800f88:	f7 64 24 04          	mull   0x4(%esp)
  800f8c:	39 d6                	cmp    %edx,%esi
  800f8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	72 08                	jb     800fa0 <__umoddi3+0x110>
  800f98:	75 11                	jne    800fab <__umoddi3+0x11b>
  800f9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f9e:	73 0b                	jae    800fab <__umoddi3+0x11b>
  800fa0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fa4:	1b 14 24             	sbb    (%esp),%edx
  800fa7:	89 d1                	mov    %edx,%ecx
  800fa9:	89 c3                	mov    %eax,%ebx
  800fab:	8b 54 24 08          	mov    0x8(%esp),%edx
  800faf:	29 da                	sub    %ebx,%edx
  800fb1:	19 ce                	sbb    %ecx,%esi
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	d3 e0                	shl    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	d3 ea                	shr    %cl,%edx
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	d3 ee                	shr    %cl,%esi
  800fc1:	09 d0                	or     %edx,%eax
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	83 c4 1c             	add    $0x1c,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	29 f9                	sub    %edi,%ecx
  800fd2:	19 d6                	sbb    %edx,%esi
  800fd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdc:	e9 18 ff ff ff       	jmp    800ef9 <__umoddi3+0x69>
