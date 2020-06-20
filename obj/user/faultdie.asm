
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 5b 00 00 00       	call   80008c <libmain>
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
  800045:	68 a0 1e 80 00       	push   $0x801ea0
  80004a:	e8 30 01 00 00       	call   80017f <cprintf>
	cprintf("here I add some commit.\n");
  80004f:	c7 04 24 bc 1e 80 00 	movl   $0x801ebc,(%esp)
  800056:	e8 24 01 00 00       	call   80017f <cprintf>
	sys_env_destroy(sys_getenvid());
  80005b:	e8 b3 0a 00 00       	call   800b13 <sys_getenvid>
  800060:	89 04 24             	mov    %eax,(%esp)
  800063:	e8 6a 0a 00 00       	call   800ad2 <sys_env_destroy>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <umain>:

void
umain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800073:	68 33 00 80 00       	push   $0x800033
  800078:	e8 c5 0c 00 00       	call   800d42 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  80007d:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800084:	00 00 00 
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800094:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800097:	e8 77 0a 00 00       	call   800b13 <sys_getenvid>
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a9:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	85 db                	test   %ebx,%ebx
  8000b0:	7e 07                	jle    8000b9 <libmain+0x2d>
		binaryname = argv[0];
  8000b2:	8b 06                	mov    (%esi),%eax
  8000b4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
  8000be:	e8 aa ff ff ff       	call   80006d <umain>

	// exit gracefully
	exit();
  8000c3:	e8 0a 00 00 00       	call   8000d2 <exit>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d8:	e8 b9 0e 00 00       	call   800f96 <close_all>
	sys_env_destroy(0);
  8000dd:	83 ec 0c             	sub    $0xc,%esp
  8000e0:	6a 00                	push   $0x0
  8000e2:	e8 eb 09 00 00       	call   800ad2 <sys_env_destroy>
}
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f6:	8b 13                	mov    (%ebx),%edx
  8000f8:	8d 42 01             	lea    0x1(%edx),%eax
  8000fb:	89 03                	mov    %eax,(%ebx)
  8000fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800100:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800104:	3d ff 00 00 00       	cmp    $0xff,%eax
  800109:	75 1a                	jne    800125 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	68 ff 00 00 00       	push   $0xff
  800113:	8d 43 08             	lea    0x8(%ebx),%eax
  800116:	50                   	push   %eax
  800117:	e8 79 09 00 00       	call   800a95 <sys_cputs>
		b->idx = 0;
  80011c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800122:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800125:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800129:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80012c:	c9                   	leave  
  80012d:	c3                   	ret    

0080012e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800137:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013e:	00 00 00 
	b.cnt = 0;
  800141:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800148:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80014b:	ff 75 0c             	pushl  0xc(%ebp)
  80014e:	ff 75 08             	pushl  0x8(%ebp)
  800151:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 ec 00 80 00       	push   $0x8000ec
  80015d:	e8 54 01 00 00       	call   8002b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800162:	83 c4 08             	add    $0x8,%esp
  800165:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80016b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800171:	50                   	push   %eax
  800172:	e8 1e 09 00 00       	call   800a95 <sys_cputs>

	return b.cnt;
}
  800177:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800185:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800188:	50                   	push   %eax
  800189:	ff 75 08             	pushl  0x8(%ebp)
  80018c:	e8 9d ff ff ff       	call   80012e <vcprintf>
	va_end(ap);

	return cnt;
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	57                   	push   %edi
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 1c             	sub    $0x1c,%esp
  80019c:	89 c7                	mov    %eax,%edi
  80019e:	89 d6                	mov    %edx,%esi
  8001a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001b7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ba:	39 d3                	cmp    %edx,%ebx
  8001bc:	72 05                	jb     8001c3 <printnum+0x30>
  8001be:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c1:	77 45                	ja     800208 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	ff 75 18             	pushl  0x18(%ebp)
  8001c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8001cc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001cf:	53                   	push   %ebx
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001df:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e2:	e8 29 1a 00 00       	call   801c10 <__udivdi3>
  8001e7:	83 c4 18             	add    $0x18,%esp
  8001ea:	52                   	push   %edx
  8001eb:	50                   	push   %eax
  8001ec:	89 f2                	mov    %esi,%edx
  8001ee:	89 f8                	mov    %edi,%eax
  8001f0:	e8 9e ff ff ff       	call   800193 <printnum>
  8001f5:	83 c4 20             	add    $0x20,%esp
  8001f8:	eb 18                	jmp    800212 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001fa:	83 ec 08             	sub    $0x8,%esp
  8001fd:	56                   	push   %esi
  8001fe:	ff 75 18             	pushl  0x18(%ebp)
  800201:	ff d7                	call   *%edi
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	eb 03                	jmp    80020b <printnum+0x78>
  800208:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80020b:	83 eb 01             	sub    $0x1,%ebx
  80020e:	85 db                	test   %ebx,%ebx
  800210:	7f e8                	jg     8001fa <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800212:	83 ec 08             	sub    $0x8,%esp
  800215:	56                   	push   %esi
  800216:	83 ec 04             	sub    $0x4,%esp
  800219:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021c:	ff 75 e0             	pushl  -0x20(%ebp)
  80021f:	ff 75 dc             	pushl  -0x24(%ebp)
  800222:	ff 75 d8             	pushl  -0x28(%ebp)
  800225:	e8 16 1b 00 00       	call   801d40 <__umoddi3>
  80022a:	83 c4 14             	add    $0x14,%esp
  80022d:	0f be 80 df 1e 80 00 	movsbl 0x801edf(%eax),%eax
  800234:	50                   	push   %eax
  800235:	ff d7                	call   *%edi
}
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023d:	5b                   	pop    %ebx
  80023e:	5e                   	pop    %esi
  80023f:	5f                   	pop    %edi
  800240:	5d                   	pop    %ebp
  800241:	c3                   	ret    

00800242 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800245:	83 fa 01             	cmp    $0x1,%edx
  800248:	7e 0e                	jle    800258 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80024a:	8b 10                	mov    (%eax),%edx
  80024c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80024f:	89 08                	mov    %ecx,(%eax)
  800251:	8b 02                	mov    (%edx),%eax
  800253:	8b 52 04             	mov    0x4(%edx),%edx
  800256:	eb 22                	jmp    80027a <getuint+0x38>
	else if (lflag)
  800258:	85 d2                	test   %edx,%edx
  80025a:	74 10                	je     80026c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 02                	mov    (%edx),%eax
  800265:	ba 00 00 00 00       	mov    $0x0,%edx
  80026a:	eb 0e                	jmp    80027a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80026c:	8b 10                	mov    (%eax),%edx
  80026e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800271:	89 08                	mov    %ecx,(%eax)
  800273:	8b 02                	mov    (%edx),%eax
  800275:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80027a:	5d                   	pop    %ebp
  80027b:	c3                   	ret    

0080027c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800282:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800286:	8b 10                	mov    (%eax),%edx
  800288:	3b 50 04             	cmp    0x4(%eax),%edx
  80028b:	73 0a                	jae    800297 <sprintputch+0x1b>
		*b->buf++ = ch;
  80028d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800290:	89 08                	mov    %ecx,(%eax)
  800292:	8b 45 08             	mov    0x8(%ebp),%eax
  800295:	88 02                	mov    %al,(%edx)
}
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a2:	50                   	push   %eax
  8002a3:	ff 75 10             	pushl  0x10(%ebp)
  8002a6:	ff 75 0c             	pushl  0xc(%ebp)
  8002a9:	ff 75 08             	pushl  0x8(%ebp)
  8002ac:	e8 05 00 00 00       	call   8002b6 <vprintfmt>
	va_end(ap);
}
  8002b1:	83 c4 10             	add    $0x10,%esp
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	57                   	push   %edi
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
  8002bc:	83 ec 2c             	sub    $0x2c,%esp
  8002bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c8:	eb 12                	jmp    8002dc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ca:	85 c0                	test   %eax,%eax
  8002cc:	0f 84 d3 03 00 00    	je     8006a5 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002d2:	83 ec 08             	sub    $0x8,%esp
  8002d5:	53                   	push   %ebx
  8002d6:	50                   	push   %eax
  8002d7:	ff d6                	call   *%esi
  8002d9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002dc:	83 c7 01             	add    $0x1,%edi
  8002df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e3:	83 f8 25             	cmp    $0x25,%eax
  8002e6:	75 e2                	jne    8002ca <vprintfmt+0x14>
  8002e8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f3:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002fa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800301:	ba 00 00 00 00       	mov    $0x0,%edx
  800306:	eb 07                	jmp    80030f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80030b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8d 47 01             	lea    0x1(%edi),%eax
  800312:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800315:	0f b6 07             	movzbl (%edi),%eax
  800318:	0f b6 c8             	movzbl %al,%ecx
  80031b:	83 e8 23             	sub    $0x23,%eax
  80031e:	3c 55                	cmp    $0x55,%al
  800320:	0f 87 64 03 00 00    	ja     80068a <vprintfmt+0x3d4>
  800326:	0f b6 c0             	movzbl %al,%eax
  800329:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800333:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800337:	eb d6                	jmp    80030f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033c:	b8 00 00 00 00       	mov    $0x0,%eax
  800341:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800344:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800347:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80034b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80034e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800351:	83 fa 09             	cmp    $0x9,%edx
  800354:	77 39                	ja     80038f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800356:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800359:	eb e9                	jmp    800344 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 48 04             	lea    0x4(%eax),%ecx
  800361:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800364:	8b 00                	mov    (%eax),%eax
  800366:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036c:	eb 27                	jmp    800395 <vprintfmt+0xdf>
  80036e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800371:	85 c0                	test   %eax,%eax
  800373:	b9 00 00 00 00       	mov    $0x0,%ecx
  800378:	0f 49 c8             	cmovns %eax,%ecx
  80037b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800381:	eb 8c                	jmp    80030f <vprintfmt+0x59>
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800386:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038d:	eb 80                	jmp    80030f <vprintfmt+0x59>
  80038f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800392:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800395:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800399:	0f 89 70 ff ff ff    	jns    80030f <vprintfmt+0x59>
				width = precision, precision = -1;
  80039f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003ac:	e9 5e ff ff ff       	jmp    80030f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b7:	e9 53 ff ff ff       	jmp    80030f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8d 50 04             	lea    0x4(%eax),%edx
  8003c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	53                   	push   %ebx
  8003c9:	ff 30                	pushl  (%eax)
  8003cb:	ff d6                	call   *%esi
			break;
  8003cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d3:	e9 04 ff ff ff       	jmp    8002dc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 50 04             	lea    0x4(%eax),%edx
  8003de:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	99                   	cltd   
  8003e4:	31 d0                	xor    %edx,%eax
  8003e6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e8:	83 f8 0f             	cmp    $0xf,%eax
  8003eb:	7f 0b                	jg     8003f8 <vprintfmt+0x142>
  8003ed:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8003f4:	85 d2                	test   %edx,%edx
  8003f6:	75 18                	jne    800410 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003f8:	50                   	push   %eax
  8003f9:	68 f7 1e 80 00       	push   $0x801ef7
  8003fe:	53                   	push   %ebx
  8003ff:	56                   	push   %esi
  800400:	e8 94 fe ff ff       	call   800299 <printfmt>
  800405:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040b:	e9 cc fe ff ff       	jmp    8002dc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800410:	52                   	push   %edx
  800411:	68 ed 22 80 00       	push   $0x8022ed
  800416:	53                   	push   %ebx
  800417:	56                   	push   %esi
  800418:	e8 7c fe ff ff       	call   800299 <printfmt>
  80041d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800423:	e9 b4 fe ff ff       	jmp    8002dc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 50 04             	lea    0x4(%eax),%edx
  80042e:	89 55 14             	mov    %edx,0x14(%ebp)
  800431:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800433:	85 ff                	test   %edi,%edi
  800435:	b8 f0 1e 80 00       	mov    $0x801ef0,%eax
  80043a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800441:	0f 8e 94 00 00 00    	jle    8004db <vprintfmt+0x225>
  800447:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044b:	0f 84 98 00 00 00    	je     8004e9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	ff 75 c8             	pushl  -0x38(%ebp)
  800457:	57                   	push   %edi
  800458:	e8 d0 02 00 00       	call   80072d <strnlen>
  80045d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800460:	29 c1                	sub    %eax,%ecx
  800462:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800465:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800468:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80046c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800472:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800474:	eb 0f                	jmp    800485 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	53                   	push   %ebx
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	83 ef 01             	sub    $0x1,%edi
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	85 ff                	test   %edi,%edi
  800487:	7f ed                	jg     800476 <vprintfmt+0x1c0>
  800489:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80048c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80048f:	85 c9                	test   %ecx,%ecx
  800491:	b8 00 00 00 00       	mov    $0x0,%eax
  800496:	0f 49 c1             	cmovns %ecx,%eax
  800499:	29 c1                	sub    %eax,%ecx
  80049b:	89 75 08             	mov    %esi,0x8(%ebp)
  80049e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a4:	89 cb                	mov    %ecx,%ebx
  8004a6:	eb 4d                	jmp    8004f5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ac:	74 1b                	je     8004c9 <vprintfmt+0x213>
  8004ae:	0f be c0             	movsbl %al,%eax
  8004b1:	83 e8 20             	sub    $0x20,%eax
  8004b4:	83 f8 5e             	cmp    $0x5e,%eax
  8004b7:	76 10                	jbe    8004c9 <vprintfmt+0x213>
					putch('?', putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 0c             	pushl  0xc(%ebp)
  8004bf:	6a 3f                	push   $0x3f
  8004c1:	ff 55 08             	call   *0x8(%ebp)
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	eb 0d                	jmp    8004d6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 0c             	pushl  0xc(%ebp)
  8004cf:	52                   	push   %edx
  8004d0:	ff 55 08             	call   *0x8(%ebp)
  8004d3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d6:	83 eb 01             	sub    $0x1,%ebx
  8004d9:	eb 1a                	jmp    8004f5 <vprintfmt+0x23f>
  8004db:	89 75 08             	mov    %esi,0x8(%ebp)
  8004de:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004e1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e7:	eb 0c                	jmp    8004f5 <vprintfmt+0x23f>
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	83 c7 01             	add    $0x1,%edi
  8004f8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fc:	0f be d0             	movsbl %al,%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	74 23                	je     800526 <vprintfmt+0x270>
  800503:	85 f6                	test   %esi,%esi
  800505:	78 a1                	js     8004a8 <vprintfmt+0x1f2>
  800507:	83 ee 01             	sub    $0x1,%esi
  80050a:	79 9c                	jns    8004a8 <vprintfmt+0x1f2>
  80050c:	89 df                	mov    %ebx,%edi
  80050e:	8b 75 08             	mov    0x8(%ebp),%esi
  800511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800514:	eb 18                	jmp    80052e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	53                   	push   %ebx
  80051a:	6a 20                	push   $0x20
  80051c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051e:	83 ef 01             	sub    $0x1,%edi
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	eb 08                	jmp    80052e <vprintfmt+0x278>
  800526:	89 df                	mov    %ebx,%edi
  800528:	8b 75 08             	mov    0x8(%ebp),%esi
  80052b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052e:	85 ff                	test   %edi,%edi
  800530:	7f e4                	jg     800516 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800535:	e9 a2 fd ff ff       	jmp    8002dc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053a:	83 fa 01             	cmp    $0x1,%edx
  80053d:	7e 16                	jle    800555 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 08             	lea    0x8(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 50 04             	mov    0x4(%eax),%edx
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800550:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800553:	eb 32                	jmp    800587 <vprintfmt+0x2d1>
	else if (lflag)
  800555:	85 d2                	test   %edx,%edx
  800557:	74 18                	je     800571 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 50 04             	lea    0x4(%eax),%edx
  80055f:	89 55 14             	mov    %edx,0x14(%ebp)
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800567:	89 c1                	mov    %eax,%ecx
  800569:	c1 f9 1f             	sar    $0x1f,%ecx
  80056c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80056f:	eb 16                	jmp    800587 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057f:	89 c1                	mov    %eax,%ecx
  800581:	c1 f9 1f             	sar    $0x1f,%ecx
  800584:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800587:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80058a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800598:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80059c:	0f 89 b0 00 00 00    	jns    800652 <vprintfmt+0x39c>
				putch('-', putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	53                   	push   %ebx
  8005a6:	6a 2d                	push   $0x2d
  8005a8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005aa:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005ad:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005b0:	f7 d8                	neg    %eax
  8005b2:	83 d2 00             	adc    $0x0,%edx
  8005b5:	f7 da                	neg    %edx
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005bd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c5:	e9 88 00 00 00       	jmp    800652 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cd:	e8 70 fc ff ff       	call   800242 <getuint>
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005dd:	eb 73                	jmp    800652 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005df:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e2:	e8 5b fc ff ff       	call   800242 <getuint>
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005ed:	83 ec 08             	sub    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 58                	push   $0x58
  8005f3:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f5:	83 c4 08             	add    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 58                	push   $0x58
  8005fb:	ff d6                	call   *%esi
			putch('X', putdat);
  8005fd:	83 c4 08             	add    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 58                	push   $0x58
  800603:	ff d6                	call   *%esi
			goto number;
  800605:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800608:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80060d:	eb 43                	jmp    800652 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 30                	push   $0x30
  800615:	ff d6                	call   *%esi
			putch('x', putdat);
  800617:	83 c4 08             	add    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 78                	push   $0x78
  80061d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 50 04             	lea    0x4(%eax),%edx
  800625:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	ba 00 00 00 00       	mov    $0x0,%edx
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800635:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800638:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80063d:	eb 13                	jmp    800652 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 fb fb ff ff       	call   800242 <getuint>
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80064d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800659:	52                   	push   %edx
  80065a:	ff 75 e0             	pushl  -0x20(%ebp)
  80065d:	50                   	push   %eax
  80065e:	ff 75 dc             	pushl  -0x24(%ebp)
  800661:	ff 75 d8             	pushl  -0x28(%ebp)
  800664:	89 da                	mov    %ebx,%edx
  800666:	89 f0                	mov    %esi,%eax
  800668:	e8 26 fb ff ff       	call   800193 <printnum>
			break;
  80066d:	83 c4 20             	add    $0x20,%esp
  800670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800673:	e9 64 fc ff ff       	jmp    8002dc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	51                   	push   %ecx
  80067d:	ff d6                	call   *%esi
			break;
  80067f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800682:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800685:	e9 52 fc ff ff       	jmp    8002dc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 25                	push   $0x25
  800690:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800692:	83 c4 10             	add    $0x10,%esp
  800695:	eb 03                	jmp    80069a <vprintfmt+0x3e4>
  800697:	83 ef 01             	sub    $0x1,%edi
  80069a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80069e:	75 f7                	jne    800697 <vprintfmt+0x3e1>
  8006a0:	e9 37 fc ff ff       	jmp    8002dc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a8:	5b                   	pop    %ebx
  8006a9:	5e                   	pop    %esi
  8006aa:	5f                   	pop    %edi
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 18             	sub    $0x18,%esp
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	74 26                	je     8006f4 <vsnprintf+0x47>
  8006ce:	85 d2                	test   %edx,%edx
  8006d0:	7e 22                	jle    8006f4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d2:	ff 75 14             	pushl  0x14(%ebp)
  8006d5:	ff 75 10             	pushl  0x10(%ebp)
  8006d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	68 7c 02 80 00       	push   $0x80027c
  8006e1:	e8 d0 fb ff ff       	call   8002b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 05                	jmp    8006f9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800701:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800704:	50                   	push   %eax
  800705:	ff 75 10             	pushl  0x10(%ebp)
  800708:	ff 75 0c             	pushl  0xc(%ebp)
  80070b:	ff 75 08             	pushl  0x8(%ebp)
  80070e:	e8 9a ff ff ff       	call   8006ad <vsnprintf>
	va_end(ap);

	return rc;
}
  800713:	c9                   	leave  
  800714:	c3                   	ret    

00800715 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80071b:	b8 00 00 00 00       	mov    $0x0,%eax
  800720:	eb 03                	jmp    800725 <strlen+0x10>
		n++;
  800722:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800725:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800729:	75 f7                	jne    800722 <strlen+0xd>
		n++;
	return n;
}
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800733:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800736:	ba 00 00 00 00       	mov    $0x0,%edx
  80073b:	eb 03                	jmp    800740 <strnlen+0x13>
		n++;
  80073d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800740:	39 c2                	cmp    %eax,%edx
  800742:	74 08                	je     80074c <strnlen+0x1f>
  800744:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800748:	75 f3                	jne    80073d <strnlen+0x10>
  80074a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	53                   	push   %ebx
  800752:	8b 45 08             	mov    0x8(%ebp),%eax
  800755:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800758:	89 c2                	mov    %eax,%edx
  80075a:	83 c2 01             	add    $0x1,%edx
  80075d:	83 c1 01             	add    $0x1,%ecx
  800760:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800764:	88 5a ff             	mov    %bl,-0x1(%edx)
  800767:	84 db                	test   %bl,%bl
  800769:	75 ef                	jne    80075a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80076b:	5b                   	pop    %ebx
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	53                   	push   %ebx
  800772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800775:	53                   	push   %ebx
  800776:	e8 9a ff ff ff       	call   800715 <strlen>
  80077b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80077e:	ff 75 0c             	pushl  0xc(%ebp)
  800781:	01 d8                	add    %ebx,%eax
  800783:	50                   	push   %eax
  800784:	e8 c5 ff ff ff       	call   80074e <strcpy>
	return dst;
}
  800789:	89 d8                	mov    %ebx,%eax
  80078b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078e:	c9                   	leave  
  80078f:	c3                   	ret    

00800790 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	56                   	push   %esi
  800794:	53                   	push   %ebx
  800795:	8b 75 08             	mov    0x8(%ebp),%esi
  800798:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079b:	89 f3                	mov    %esi,%ebx
  80079d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	eb 0f                	jmp    8007b3 <strncpy+0x23>
		*dst++ = *src;
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	0f b6 01             	movzbl (%ecx),%eax
  8007aa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ad:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b3:	39 da                	cmp    %ebx,%edx
  8007b5:	75 ed                	jne    8007a4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007b7:	89 f0                	mov    %esi,%eax
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	56                   	push   %esi
  8007c1:	53                   	push   %ebx
  8007c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007cb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cd:	85 d2                	test   %edx,%edx
  8007cf:	74 21                	je     8007f2 <strlcpy+0x35>
  8007d1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d5:	89 f2                	mov    %esi,%edx
  8007d7:	eb 09                	jmp    8007e2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d9:	83 c2 01             	add    $0x1,%edx
  8007dc:	83 c1 01             	add    $0x1,%ecx
  8007df:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e2:	39 c2                	cmp    %eax,%edx
  8007e4:	74 09                	je     8007ef <strlcpy+0x32>
  8007e6:	0f b6 19             	movzbl (%ecx),%ebx
  8007e9:	84 db                	test   %bl,%bl
  8007eb:	75 ec                	jne    8007d9 <strlcpy+0x1c>
  8007ed:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f2:	29 f0                	sub    %esi,%eax
}
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800801:	eb 06                	jmp    800809 <strcmp+0x11>
		p++, q++;
  800803:	83 c1 01             	add    $0x1,%ecx
  800806:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800809:	0f b6 01             	movzbl (%ecx),%eax
  80080c:	84 c0                	test   %al,%al
  80080e:	74 04                	je     800814 <strcmp+0x1c>
  800810:	3a 02                	cmp    (%edx),%al
  800812:	74 ef                	je     800803 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800814:	0f b6 c0             	movzbl %al,%eax
  800817:	0f b6 12             	movzbl (%edx),%edx
  80081a:	29 d0                	sub    %edx,%eax
}
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
  800828:	89 c3                	mov    %eax,%ebx
  80082a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80082d:	eb 06                	jmp    800835 <strncmp+0x17>
		n--, p++, q++;
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800835:	39 d8                	cmp    %ebx,%eax
  800837:	74 15                	je     80084e <strncmp+0x30>
  800839:	0f b6 08             	movzbl (%eax),%ecx
  80083c:	84 c9                	test   %cl,%cl
  80083e:	74 04                	je     800844 <strncmp+0x26>
  800840:	3a 0a                	cmp    (%edx),%cl
  800842:	74 eb                	je     80082f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800844:	0f b6 00             	movzbl (%eax),%eax
  800847:	0f b6 12             	movzbl (%edx),%edx
  80084a:	29 d0                	sub    %edx,%eax
  80084c:	eb 05                	jmp    800853 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800860:	eb 07                	jmp    800869 <strchr+0x13>
		if (*s == c)
  800862:	38 ca                	cmp    %cl,%dl
  800864:	74 0f                	je     800875 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	0f b6 10             	movzbl (%eax),%edx
  80086c:	84 d2                	test   %dl,%dl
  80086e:	75 f2                	jne    800862 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800881:	eb 03                	jmp    800886 <strfind+0xf>
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800889:	38 ca                	cmp    %cl,%dl
  80088b:	74 04                	je     800891 <strfind+0x1a>
  80088d:	84 d2                	test   %dl,%dl
  80088f:	75 f2                	jne    800883 <strfind+0xc>
			break;
	return (char *) s;
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	57                   	push   %edi
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80089f:	85 c9                	test   %ecx,%ecx
  8008a1:	74 36                	je     8008d9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a9:	75 28                	jne    8008d3 <memset+0x40>
  8008ab:	f6 c1 03             	test   $0x3,%cl
  8008ae:	75 23                	jne    8008d3 <memset+0x40>
		c &= 0xFF;
  8008b0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008b4:	89 d3                	mov    %edx,%ebx
  8008b6:	c1 e3 08             	shl    $0x8,%ebx
  8008b9:	89 d6                	mov    %edx,%esi
  8008bb:	c1 e6 18             	shl    $0x18,%esi
  8008be:	89 d0                	mov    %edx,%eax
  8008c0:	c1 e0 10             	shl    $0x10,%eax
  8008c3:	09 f0                	or     %esi,%eax
  8008c5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008c7:	89 d8                	mov    %ebx,%eax
  8008c9:	09 d0                	or     %edx,%eax
  8008cb:	c1 e9 02             	shr    $0x2,%ecx
  8008ce:	fc                   	cld    
  8008cf:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d1:	eb 06                	jmp    8008d9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d6:	fc                   	cld    
  8008d7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d9:	89 f8                	mov    %edi,%eax
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5f                   	pop    %edi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	57                   	push   %edi
  8008e4:	56                   	push   %esi
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ee:	39 c6                	cmp    %eax,%esi
  8008f0:	73 35                	jae    800927 <memmove+0x47>
  8008f2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008f5:	39 d0                	cmp    %edx,%eax
  8008f7:	73 2e                	jae    800927 <memmove+0x47>
		s += n;
		d += n;
  8008f9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fc:	89 d6                	mov    %edx,%esi
  8008fe:	09 fe                	or     %edi,%esi
  800900:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800906:	75 13                	jne    80091b <memmove+0x3b>
  800908:	f6 c1 03             	test   $0x3,%cl
  80090b:	75 0e                	jne    80091b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80090d:	83 ef 04             	sub    $0x4,%edi
  800910:	8d 72 fc             	lea    -0x4(%edx),%esi
  800913:	c1 e9 02             	shr    $0x2,%ecx
  800916:	fd                   	std    
  800917:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800919:	eb 09                	jmp    800924 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80091b:	83 ef 01             	sub    $0x1,%edi
  80091e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800921:	fd                   	std    
  800922:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800924:	fc                   	cld    
  800925:	eb 1d                	jmp    800944 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800927:	89 f2                	mov    %esi,%edx
  800929:	09 c2                	or     %eax,%edx
  80092b:	f6 c2 03             	test   $0x3,%dl
  80092e:	75 0f                	jne    80093f <memmove+0x5f>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 0a                	jne    80093f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800935:	c1 e9 02             	shr    $0x2,%ecx
  800938:	89 c7                	mov    %eax,%edi
  80093a:	fc                   	cld    
  80093b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093d:	eb 05                	jmp    800944 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80093f:	89 c7                	mov    %eax,%edi
  800941:	fc                   	cld    
  800942:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80094b:	ff 75 10             	pushl  0x10(%ebp)
  80094e:	ff 75 0c             	pushl  0xc(%ebp)
  800951:	ff 75 08             	pushl  0x8(%ebp)
  800954:	e8 87 ff ff ff       	call   8008e0 <memmove>
}
  800959:	c9                   	leave  
  80095a:	c3                   	ret    

0080095b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	56                   	push   %esi
  80095f:	53                   	push   %ebx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 55 0c             	mov    0xc(%ebp),%edx
  800966:	89 c6                	mov    %eax,%esi
  800968:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80096b:	eb 1a                	jmp    800987 <memcmp+0x2c>
		if (*s1 != *s2)
  80096d:	0f b6 08             	movzbl (%eax),%ecx
  800970:	0f b6 1a             	movzbl (%edx),%ebx
  800973:	38 d9                	cmp    %bl,%cl
  800975:	74 0a                	je     800981 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800977:	0f b6 c1             	movzbl %cl,%eax
  80097a:	0f b6 db             	movzbl %bl,%ebx
  80097d:	29 d8                	sub    %ebx,%eax
  80097f:	eb 0f                	jmp    800990 <memcmp+0x35>
		s1++, s2++;
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800987:	39 f0                	cmp    %esi,%eax
  800989:	75 e2                	jne    80096d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80098b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	53                   	push   %ebx
  800998:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80099b:	89 c1                	mov    %eax,%ecx
  80099d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a0:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a4:	eb 0a                	jmp    8009b0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a6:	0f b6 10             	movzbl (%eax),%edx
  8009a9:	39 da                	cmp    %ebx,%edx
  8009ab:	74 07                	je     8009b4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	39 c8                	cmp    %ecx,%eax
  8009b2:	72 f2                	jb     8009a6 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009b4:	5b                   	pop    %ebx
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	57                   	push   %edi
  8009bb:	56                   	push   %esi
  8009bc:	53                   	push   %ebx
  8009bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c3:	eb 03                	jmp    8009c8 <strtol+0x11>
		s++;
  8009c5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	3c 20                	cmp    $0x20,%al
  8009cd:	74 f6                	je     8009c5 <strtol+0xe>
  8009cf:	3c 09                	cmp    $0x9,%al
  8009d1:	74 f2                	je     8009c5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d3:	3c 2b                	cmp    $0x2b,%al
  8009d5:	75 0a                	jne    8009e1 <strtol+0x2a>
		s++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009da:	bf 00 00 00 00       	mov    $0x0,%edi
  8009df:	eb 11                	jmp    8009f2 <strtol+0x3b>
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009e6:	3c 2d                	cmp    $0x2d,%al
  8009e8:	75 08                	jne    8009f2 <strtol+0x3b>
		s++, neg = 1;
  8009ea:	83 c1 01             	add    $0x1,%ecx
  8009ed:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f8:	75 15                	jne    800a0f <strtol+0x58>
  8009fa:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fd:	75 10                	jne    800a0f <strtol+0x58>
  8009ff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a03:	75 7c                	jne    800a81 <strtol+0xca>
		s += 2, base = 16;
  800a05:	83 c1 02             	add    $0x2,%ecx
  800a08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0d:	eb 16                	jmp    800a25 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a0f:	85 db                	test   %ebx,%ebx
  800a11:	75 12                	jne    800a25 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a13:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a18:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1b:	75 08                	jne    800a25 <strtol+0x6e>
		s++, base = 8;
  800a1d:	83 c1 01             	add    $0x1,%ecx
  800a20:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a25:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a2d:	0f b6 11             	movzbl (%ecx),%edx
  800a30:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a33:	89 f3                	mov    %esi,%ebx
  800a35:	80 fb 09             	cmp    $0x9,%bl
  800a38:	77 08                	ja     800a42 <strtol+0x8b>
			dig = *s - '0';
  800a3a:	0f be d2             	movsbl %dl,%edx
  800a3d:	83 ea 30             	sub    $0x30,%edx
  800a40:	eb 22                	jmp    800a64 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a42:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a45:	89 f3                	mov    %esi,%ebx
  800a47:	80 fb 19             	cmp    $0x19,%bl
  800a4a:	77 08                	ja     800a54 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a4c:	0f be d2             	movsbl %dl,%edx
  800a4f:	83 ea 57             	sub    $0x57,%edx
  800a52:	eb 10                	jmp    800a64 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a57:	89 f3                	mov    %esi,%ebx
  800a59:	80 fb 19             	cmp    $0x19,%bl
  800a5c:	77 16                	ja     800a74 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a5e:	0f be d2             	movsbl %dl,%edx
  800a61:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a64:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a67:	7d 0b                	jge    800a74 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a70:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a72:	eb b9                	jmp    800a2d <strtol+0x76>

	if (endptr)
  800a74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a78:	74 0d                	je     800a87 <strtol+0xd0>
		*endptr = (char *) s;
  800a7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7d:	89 0e                	mov    %ecx,(%esi)
  800a7f:	eb 06                	jmp    800a87 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	74 98                	je     800a1d <strtol+0x66>
  800a85:	eb 9e                	jmp    800a25 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	f7 da                	neg    %edx
  800a8b:	85 ff                	test   %edi,%edi
  800a8d:	0f 45 c2             	cmovne %edx,%eax
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa6:	89 c3                	mov    %eax,%ebx
  800aa8:	89 c7                	mov    %eax,%edi
  800aaa:	89 c6                	mov    %eax,%esi
  800aac:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5f                   	pop    %edi
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	57                   	push   %edi
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac3:	89 d1                	mov    %edx,%ecx
  800ac5:	89 d3                	mov    %edx,%ebx
  800ac7:	89 d7                	mov    %edx,%edi
  800ac9:	89 d6                	mov    %edx,%esi
  800acb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
  800ad8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800adb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ae5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae8:	89 cb                	mov    %ecx,%ebx
  800aea:	89 cf                	mov    %ecx,%edi
  800aec:	89 ce                	mov    %ecx,%esi
  800aee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800af0:	85 c0                	test   %eax,%eax
  800af2:	7e 17                	jle    800b0b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af4:	83 ec 0c             	sub    $0xc,%esp
  800af7:	50                   	push   %eax
  800af8:	6a 03                	push   $0x3
  800afa:	68 df 21 80 00       	push   $0x8021df
  800aff:	6a 23                	push   $0x23
  800b01:	68 fc 21 80 00       	push   $0x8021fc
  800b06:	e8 a3 0f 00 00       	call   801aae <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b23:	89 d1                	mov    %edx,%ecx
  800b25:	89 d3                	mov    %edx,%ebx
  800b27:	89 d7                	mov    %edx,%edi
  800b29:	89 d6                	mov    %edx,%esi
  800b2b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_yield>:

void
sys_yield(void)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b38:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b42:	89 d1                	mov    %edx,%ecx
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	89 d7                	mov    %edx,%edi
  800b48:	89 d6                	mov    %edx,%esi
  800b4a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	57                   	push   %edi
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b5a:	be 00 00 00 00       	mov    $0x0,%esi
  800b5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6d:	89 f7                	mov    %esi,%edi
  800b6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b71:	85 c0                	test   %eax,%eax
  800b73:	7e 17                	jle    800b8c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	50                   	push   %eax
  800b79:	6a 04                	push   $0x4
  800b7b:	68 df 21 80 00       	push   $0x8021df
  800b80:	6a 23                	push   $0x23
  800b82:	68 fc 21 80 00       	push   $0x8021fc
  800b87:	e8 22 0f 00 00       	call   801aae <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b9d:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bae:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	7e 17                	jle    800bce <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 05                	push   $0x5
  800bbd:	68 df 21 80 00       	push   $0x8021df
  800bc2:	6a 23                	push   $0x23
  800bc4:	68 fc 21 80 00       	push   $0x8021fc
  800bc9:	e8 e0 0e 00 00       	call   801aae <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be4:	b8 06 00 00 00       	mov    $0x6,%eax
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	89 df                	mov    %ebx,%edi
  800bf1:	89 de                	mov    %ebx,%esi
  800bf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7e 17                	jle    800c10 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	50                   	push   %eax
  800bfd:	6a 06                	push   $0x6
  800bff:	68 df 21 80 00       	push   $0x8021df
  800c04:	6a 23                	push   $0x23
  800c06:	68 fc 21 80 00       	push   $0x8021fc
  800c0b:	e8 9e 0e 00 00       	call   801aae <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c26:	b8 08 00 00 00       	mov    $0x8,%eax
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	89 df                	mov    %ebx,%edi
  800c33:	89 de                	mov    %ebx,%esi
  800c35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	7e 17                	jle    800c52 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3b:	83 ec 0c             	sub    $0xc,%esp
  800c3e:	50                   	push   %eax
  800c3f:	6a 08                	push   $0x8
  800c41:	68 df 21 80 00       	push   $0x8021df
  800c46:	6a 23                	push   $0x23
  800c48:	68 fc 21 80 00       	push   $0x8021fc
  800c4d:	e8 5c 0e 00 00       	call   801aae <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c68:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	89 df                	mov    %ebx,%edi
  800c75:	89 de                	mov    %ebx,%esi
  800c77:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	7e 17                	jle    800c94 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	50                   	push   %eax
  800c81:	6a 09                	push   $0x9
  800c83:	68 df 21 80 00       	push   $0x8021df
  800c88:	6a 23                	push   $0x23
  800c8a:	68 fc 21 80 00       	push   $0x8021fc
  800c8f:	e8 1a 0e 00 00       	call   801aae <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800caf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 df                	mov    %ebx,%edi
  800cb7:	89 de                	mov    %ebx,%esi
  800cb9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	7e 17                	jle    800cd6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	50                   	push   %eax
  800cc3:	6a 0a                	push   $0xa
  800cc5:	68 df 21 80 00       	push   $0x8021df
  800cca:	6a 23                	push   $0x23
  800ccc:	68 fc 21 80 00       	push   $0x8021fc
  800cd1:	e8 d8 0d 00 00       	call   801aae <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ce4:	be 00 00 00 00       	mov    $0x0,%esi
  800ce9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cfa:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d0f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 cb                	mov    %ecx,%ebx
  800d19:	89 cf                	mov    %ecx,%edi
  800d1b:	89 ce                	mov    %ecx,%esi
  800d1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	7e 17                	jle    800d3a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 0d                	push   $0xd
  800d29:	68 df 21 80 00       	push   $0x8021df
  800d2e:	6a 23                	push   $0x23
  800d30:	68 fc 21 80 00       	push   $0x8021fc
  800d35:	e8 74 0d 00 00       	call   801aae <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  800d48:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d4f:	75 4c                	jne    800d9d <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  800d51:	a1 04 40 80 00       	mov    0x804004,%eax
  800d56:	8b 40 48             	mov    0x48(%eax),%eax
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	6a 07                	push   $0x7
  800d5e:	68 00 f0 bf ee       	push   $0xeebff000
  800d63:	50                   	push   %eax
  800d64:	e8 e8 fd ff ff       	call   800b51 <sys_page_alloc>
		if(retv != 0){
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	74 14                	je     800d84 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  800d70:	83 ec 04             	sub    $0x4,%esp
  800d73:	68 0c 22 80 00       	push   $0x80220c
  800d78:	6a 27                	push   $0x27
  800d7a:	68 38 22 80 00       	push   $0x802238
  800d7f:	e8 2a 0d 00 00       	call   801aae <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800d84:	a1 04 40 80 00       	mov    0x804004,%eax
  800d89:	8b 40 48             	mov    0x48(%eax),%eax
  800d8c:	83 ec 08             	sub    $0x8,%esp
  800d8f:	68 a7 0d 80 00       	push   $0x800da7
  800d94:	50                   	push   %eax
  800d95:	e8 02 ff ff ff       	call   800c9c <sys_env_set_pgfault_upcall>
  800d9a:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	a3 08 40 80 00       	mov    %eax,0x804008

}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800da7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800da8:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dad:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  800daf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  800db2:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  800db6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  800dbb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  800dbf:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  800dc1:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  800dc4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  800dc5:	83 c4 04             	add    $0x4,%esp
	popfl
  800dc8:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800dc9:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dca:	c3                   	ret    

00800dcb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd6:	c1 e8 0c             	shr    $0xc,%eax
}
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	05 00 00 00 30       	add    $0x30000000,%eax
  800de6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800deb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dfd:	89 c2                	mov    %eax,%edx
  800dff:	c1 ea 16             	shr    $0x16,%edx
  800e02:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e09:	f6 c2 01             	test   $0x1,%dl
  800e0c:	74 11                	je     800e1f <fd_alloc+0x2d>
  800e0e:	89 c2                	mov    %eax,%edx
  800e10:	c1 ea 0c             	shr    $0xc,%edx
  800e13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1a:	f6 c2 01             	test   $0x1,%dl
  800e1d:	75 09                	jne    800e28 <fd_alloc+0x36>
			*fd_store = fd;
  800e1f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e21:	b8 00 00 00 00       	mov    $0x0,%eax
  800e26:	eb 17                	jmp    800e3f <fd_alloc+0x4d>
  800e28:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e2d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e32:	75 c9                	jne    800dfd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e34:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e3a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e47:	83 f8 1f             	cmp    $0x1f,%eax
  800e4a:	77 36                	ja     800e82 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e4c:	c1 e0 0c             	shl    $0xc,%eax
  800e4f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e54:	89 c2                	mov    %eax,%edx
  800e56:	c1 ea 16             	shr    $0x16,%edx
  800e59:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	74 24                	je     800e89 <fd_lookup+0x48>
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 0c             	shr    $0xc,%edx
  800e6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 1a                	je     800e90 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e79:	89 02                	mov    %eax,(%edx)
	return 0;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	eb 13                	jmp    800e95 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e87:	eb 0c                	jmp    800e95 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8e:	eb 05                	jmp    800e95 <fd_lookup+0x54>
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    

00800e97 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	83 ec 08             	sub    $0x8,%esp
  800e9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea0:	ba c4 22 80 00       	mov    $0x8022c4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea5:	eb 13                	jmp    800eba <dev_lookup+0x23>
  800ea7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eaa:	39 08                	cmp    %ecx,(%eax)
  800eac:	75 0c                	jne    800eba <dev_lookup+0x23>
			*dev = devtab[i];
  800eae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	eb 2e                	jmp    800ee8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eba:	8b 02                	mov    (%edx),%eax
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	75 e7                	jne    800ea7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec0:	a1 04 40 80 00       	mov    0x804004,%eax
  800ec5:	8b 40 48             	mov    0x48(%eax),%eax
  800ec8:	83 ec 04             	sub    $0x4,%esp
  800ecb:	51                   	push   %ecx
  800ecc:	50                   	push   %eax
  800ecd:	68 48 22 80 00       	push   $0x802248
  800ed2:	e8 a8 f2 ff ff       	call   80017f <cprintf>
	*dev = 0;
  800ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eda:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 10             	sub    $0x10,%esp
  800ef2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ef5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ef8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800efb:	50                   	push   %eax
  800efc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f02:	c1 e8 0c             	shr    $0xc,%eax
  800f05:	50                   	push   %eax
  800f06:	e8 36 ff ff ff       	call   800e41 <fd_lookup>
  800f0b:	83 c4 08             	add    $0x8,%esp
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	78 05                	js     800f17 <fd_close+0x2d>
	    || fd != fd2)
  800f12:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f15:	74 0c                	je     800f23 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f17:	84 db                	test   %bl,%bl
  800f19:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1e:	0f 44 c2             	cmove  %edx,%eax
  800f21:	eb 41                	jmp    800f64 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f23:	83 ec 08             	sub    $0x8,%esp
  800f26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f29:	50                   	push   %eax
  800f2a:	ff 36                	pushl  (%esi)
  800f2c:	e8 66 ff ff ff       	call   800e97 <dev_lookup>
  800f31:	89 c3                	mov    %eax,%ebx
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 1a                	js     800f54 <fd_close+0x6a>
		if (dev->dev_close)
  800f3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f40:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	74 0b                	je     800f54 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	56                   	push   %esi
  800f4d:	ff d0                	call   *%eax
  800f4f:	89 c3                	mov    %eax,%ebx
  800f51:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f54:	83 ec 08             	sub    $0x8,%esp
  800f57:	56                   	push   %esi
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 77 fc ff ff       	call   800bd6 <sys_page_unmap>
	return r;
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	89 d8                	mov    %ebx,%eax
}
  800f64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	ff 75 08             	pushl  0x8(%ebp)
  800f78:	e8 c4 fe ff ff       	call   800e41 <fd_lookup>
  800f7d:	83 c4 08             	add    $0x8,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	78 10                	js     800f94 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f84:	83 ec 08             	sub    $0x8,%esp
  800f87:	6a 01                	push   $0x1
  800f89:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8c:	e8 59 ff ff ff       	call   800eea <fd_close>
  800f91:	83 c4 10             	add    $0x10,%esp
}
  800f94:	c9                   	leave  
  800f95:	c3                   	ret    

00800f96 <close_all>:

void
close_all(void)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	53                   	push   %ebx
  800f9a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	53                   	push   %ebx
  800fa6:	e8 c0 ff ff ff       	call   800f6b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fab:	83 c3 01             	add    $0x1,%ebx
  800fae:	83 c4 10             	add    $0x10,%esp
  800fb1:	83 fb 20             	cmp    $0x20,%ebx
  800fb4:	75 ec                	jne    800fa2 <close_all+0xc>
		close(i);
}
  800fb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 2c             	sub    $0x2c,%esp
  800fc4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fc7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fca:	50                   	push   %eax
  800fcb:	ff 75 08             	pushl  0x8(%ebp)
  800fce:	e8 6e fe ff ff       	call   800e41 <fd_lookup>
  800fd3:	83 c4 08             	add    $0x8,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	0f 88 c1 00 00 00    	js     80109f <dup+0xe4>
		return r;
	close(newfdnum);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	56                   	push   %esi
  800fe2:	e8 84 ff ff ff       	call   800f6b <close>

	newfd = INDEX2FD(newfdnum);
  800fe7:	89 f3                	mov    %esi,%ebx
  800fe9:	c1 e3 0c             	shl    $0xc,%ebx
  800fec:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ff2:	83 c4 04             	add    $0x4,%esp
  800ff5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff8:	e8 de fd ff ff       	call   800ddb <fd2data>
  800ffd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fff:	89 1c 24             	mov    %ebx,(%esp)
  801002:	e8 d4 fd ff ff       	call   800ddb <fd2data>
  801007:	83 c4 10             	add    $0x10,%esp
  80100a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80100d:	89 f8                	mov    %edi,%eax
  80100f:	c1 e8 16             	shr    $0x16,%eax
  801012:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	74 37                	je     801054 <dup+0x99>
  80101d:	89 f8                	mov    %edi,%eax
  80101f:	c1 e8 0c             	shr    $0xc,%eax
  801022:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801029:	f6 c2 01             	test   $0x1,%dl
  80102c:	74 26                	je     801054 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80102e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801035:	83 ec 0c             	sub    $0xc,%esp
  801038:	25 07 0e 00 00       	and    $0xe07,%eax
  80103d:	50                   	push   %eax
  80103e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801041:	6a 00                	push   $0x0
  801043:	57                   	push   %edi
  801044:	6a 00                	push   $0x0
  801046:	e8 49 fb ff ff       	call   800b94 <sys_page_map>
  80104b:	89 c7                	mov    %eax,%edi
  80104d:	83 c4 20             	add    $0x20,%esp
  801050:	85 c0                	test   %eax,%eax
  801052:	78 2e                	js     801082 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801054:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801057:	89 d0                	mov    %edx,%eax
  801059:	c1 e8 0c             	shr    $0xc,%eax
  80105c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801063:	83 ec 0c             	sub    $0xc,%esp
  801066:	25 07 0e 00 00       	and    $0xe07,%eax
  80106b:	50                   	push   %eax
  80106c:	53                   	push   %ebx
  80106d:	6a 00                	push   $0x0
  80106f:	52                   	push   %edx
  801070:	6a 00                	push   $0x0
  801072:	e8 1d fb ff ff       	call   800b94 <sys_page_map>
  801077:	89 c7                	mov    %eax,%edi
  801079:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80107c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107e:	85 ff                	test   %edi,%edi
  801080:	79 1d                	jns    80109f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801082:	83 ec 08             	sub    $0x8,%esp
  801085:	53                   	push   %ebx
  801086:	6a 00                	push   $0x0
  801088:	e8 49 fb ff ff       	call   800bd6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80108d:	83 c4 08             	add    $0x8,%esp
  801090:	ff 75 d4             	pushl  -0x2c(%ebp)
  801093:	6a 00                	push   $0x0
  801095:	e8 3c fb ff ff       	call   800bd6 <sys_page_unmap>
	return r;
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	89 f8                	mov    %edi,%eax
}
  80109f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5e                   	pop    %esi
  8010a4:	5f                   	pop    %edi
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	53                   	push   %ebx
  8010ab:	83 ec 14             	sub    $0x14,%esp
  8010ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	53                   	push   %ebx
  8010b6:	e8 86 fd ff ff       	call   800e41 <fd_lookup>
  8010bb:	83 c4 08             	add    $0x8,%esp
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	85 c0                	test   %eax,%eax
  8010c2:	78 6d                	js     801131 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ce:	ff 30                	pushl  (%eax)
  8010d0:	e8 c2 fd ff ff       	call   800e97 <dev_lookup>
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 4c                	js     801128 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010df:	8b 42 08             	mov    0x8(%edx),%eax
  8010e2:	83 e0 03             	and    $0x3,%eax
  8010e5:	83 f8 01             	cmp    $0x1,%eax
  8010e8:	75 21                	jne    80110b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010ea:	a1 04 40 80 00       	mov    0x804004,%eax
  8010ef:	8b 40 48             	mov    0x48(%eax),%eax
  8010f2:	83 ec 04             	sub    $0x4,%esp
  8010f5:	53                   	push   %ebx
  8010f6:	50                   	push   %eax
  8010f7:	68 89 22 80 00       	push   $0x802289
  8010fc:	e8 7e f0 ff ff       	call   80017f <cprintf>
		return -E_INVAL;
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801109:	eb 26                	jmp    801131 <read+0x8a>
	}
	if (!dev->dev_read)
  80110b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110e:	8b 40 08             	mov    0x8(%eax),%eax
  801111:	85 c0                	test   %eax,%eax
  801113:	74 17                	je     80112c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	ff 75 10             	pushl  0x10(%ebp)
  80111b:	ff 75 0c             	pushl  0xc(%ebp)
  80111e:	52                   	push   %edx
  80111f:	ff d0                	call   *%eax
  801121:	89 c2                	mov    %eax,%edx
  801123:	83 c4 10             	add    $0x10,%esp
  801126:	eb 09                	jmp    801131 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801128:	89 c2                	mov    %eax,%edx
  80112a:	eb 05                	jmp    801131 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80112c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801131:	89 d0                	mov    %edx,%eax
  801133:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	8b 7d 08             	mov    0x8(%ebp),%edi
  801144:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801147:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114c:	eb 21                	jmp    80116f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	89 f0                	mov    %esi,%eax
  801153:	29 d8                	sub    %ebx,%eax
  801155:	50                   	push   %eax
  801156:	89 d8                	mov    %ebx,%eax
  801158:	03 45 0c             	add    0xc(%ebp),%eax
  80115b:	50                   	push   %eax
  80115c:	57                   	push   %edi
  80115d:	e8 45 ff ff ff       	call   8010a7 <read>
		if (m < 0)
  801162:	83 c4 10             	add    $0x10,%esp
  801165:	85 c0                	test   %eax,%eax
  801167:	78 10                	js     801179 <readn+0x41>
			return m;
		if (m == 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	74 0a                	je     801177 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116d:	01 c3                	add    %eax,%ebx
  80116f:	39 f3                	cmp    %esi,%ebx
  801171:	72 db                	jb     80114e <readn+0x16>
  801173:	89 d8                	mov    %ebx,%eax
  801175:	eb 02                	jmp    801179 <readn+0x41>
  801177:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	53                   	push   %ebx
  801185:	83 ec 14             	sub    $0x14,%esp
  801188:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80118b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118e:	50                   	push   %eax
  80118f:	53                   	push   %ebx
  801190:	e8 ac fc ff ff       	call   800e41 <fd_lookup>
  801195:	83 c4 08             	add    $0x8,%esp
  801198:	89 c2                	mov    %eax,%edx
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 68                	js     801206 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a8:	ff 30                	pushl  (%eax)
  8011aa:	e8 e8 fc ff ff       	call   800e97 <dev_lookup>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 47                	js     8011fd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bd:	75 21                	jne    8011e0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011bf:	a1 04 40 80 00       	mov    0x804004,%eax
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	53                   	push   %ebx
  8011cb:	50                   	push   %eax
  8011cc:	68 a5 22 80 00       	push   $0x8022a5
  8011d1:	e8 a9 ef ff ff       	call   80017f <cprintf>
		return -E_INVAL;
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011de:	eb 26                	jmp    801206 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e6:	85 d2                	test   %edx,%edx
  8011e8:	74 17                	je     801201 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	ff 75 10             	pushl  0x10(%ebp)
  8011f0:	ff 75 0c             	pushl  0xc(%ebp)
  8011f3:	50                   	push   %eax
  8011f4:	ff d2                	call   *%edx
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	eb 09                	jmp    801206 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	eb 05                	jmp    801206 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801201:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801206:	89 d0                	mov    %edx,%eax
  801208:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <seek>:

int
seek(int fdnum, off_t offset)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801213:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	ff 75 08             	pushl  0x8(%ebp)
  80121a:	e8 22 fc ff ff       	call   800e41 <fd_lookup>
  80121f:	83 c4 08             	add    $0x8,%esp
  801222:	85 c0                	test   %eax,%eax
  801224:	78 0e                	js     801234 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801226:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801234:	c9                   	leave  
  801235:	c3                   	ret    

00801236 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801236:	55                   	push   %ebp
  801237:	89 e5                	mov    %esp,%ebp
  801239:	53                   	push   %ebx
  80123a:	83 ec 14             	sub    $0x14,%esp
  80123d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801240:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801243:	50                   	push   %eax
  801244:	53                   	push   %ebx
  801245:	e8 f7 fb ff ff       	call   800e41 <fd_lookup>
  80124a:	83 c4 08             	add    $0x8,%esp
  80124d:	89 c2                	mov    %eax,%edx
  80124f:	85 c0                	test   %eax,%eax
  801251:	78 65                	js     8012b8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801253:	83 ec 08             	sub    $0x8,%esp
  801256:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125d:	ff 30                	pushl  (%eax)
  80125f:	e8 33 fc ff ff       	call   800e97 <dev_lookup>
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 44                	js     8012af <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80126b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801272:	75 21                	jne    801295 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801274:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801279:	8b 40 48             	mov    0x48(%eax),%eax
  80127c:	83 ec 04             	sub    $0x4,%esp
  80127f:	53                   	push   %ebx
  801280:	50                   	push   %eax
  801281:	68 68 22 80 00       	push   $0x802268
  801286:	e8 f4 ee ff ff       	call   80017f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801293:	eb 23                	jmp    8012b8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801295:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801298:	8b 52 18             	mov    0x18(%edx),%edx
  80129b:	85 d2                	test   %edx,%edx
  80129d:	74 14                	je     8012b3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80129f:	83 ec 08             	sub    $0x8,%esp
  8012a2:	ff 75 0c             	pushl  0xc(%ebp)
  8012a5:	50                   	push   %eax
  8012a6:	ff d2                	call   *%edx
  8012a8:	89 c2                	mov    %eax,%edx
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	eb 09                	jmp    8012b8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012af:	89 c2                	mov    %eax,%edx
  8012b1:	eb 05                	jmp    8012b8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012b8:	89 d0                	mov    %edx,%eax
  8012ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bd:	c9                   	leave  
  8012be:	c3                   	ret    

008012bf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 14             	sub    $0x14,%esp
  8012c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 75 08             	pushl  0x8(%ebp)
  8012d0:	e8 6c fb ff ff       	call   800e41 <fd_lookup>
  8012d5:	83 c4 08             	add    $0x8,%esp
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	78 58                	js     801336 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e4:	50                   	push   %eax
  8012e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e8:	ff 30                	pushl  (%eax)
  8012ea:	e8 a8 fb ff ff       	call   800e97 <dev_lookup>
  8012ef:	83 c4 10             	add    $0x10,%esp
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	78 37                	js     80132d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012fd:	74 32                	je     801331 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ff:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801302:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801309:	00 00 00 
	stat->st_isdir = 0;
  80130c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801313:	00 00 00 
	stat->st_dev = dev;
  801316:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	53                   	push   %ebx
  801320:	ff 75 f0             	pushl  -0x10(%ebp)
  801323:	ff 50 14             	call   *0x14(%eax)
  801326:	89 c2                	mov    %eax,%edx
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	eb 09                	jmp    801336 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	eb 05                	jmp    801336 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801331:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801336:	89 d0                	mov    %edx,%eax
  801338:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801342:	83 ec 08             	sub    $0x8,%esp
  801345:	6a 00                	push   $0x0
  801347:	ff 75 08             	pushl  0x8(%ebp)
  80134a:	e8 dc 01 00 00       	call   80152b <open>
  80134f:	89 c3                	mov    %eax,%ebx
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	78 1b                	js     801373 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801358:	83 ec 08             	sub    $0x8,%esp
  80135b:	ff 75 0c             	pushl  0xc(%ebp)
  80135e:	50                   	push   %eax
  80135f:	e8 5b ff ff ff       	call   8012bf <fstat>
  801364:	89 c6                	mov    %eax,%esi
	close(fd);
  801366:	89 1c 24             	mov    %ebx,(%esp)
  801369:	e8 fd fb ff ff       	call   800f6b <close>
	return r;
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	89 f0                	mov    %esi,%eax
}
  801373:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801376:	5b                   	pop    %ebx
  801377:	5e                   	pop    %esi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	56                   	push   %esi
  80137e:	53                   	push   %ebx
  80137f:	89 c6                	mov    %eax,%esi
  801381:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801383:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80138a:	75 12                	jne    80139e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	6a 01                	push   $0x1
  801391:	e8 fe 07 00 00       	call   801b94 <ipc_find_env>
  801396:	a3 00 40 80 00       	mov    %eax,0x804000
  80139b:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139e:	6a 07                	push   $0x7
  8013a0:	68 00 50 80 00       	push   $0x805000
  8013a5:	56                   	push   %esi
  8013a6:	ff 35 00 40 80 00    	pushl  0x804000
  8013ac:	e8 a0 07 00 00       	call   801b51 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8013b1:	83 c4 0c             	add    $0xc,%esp
  8013b4:	6a 00                	push   $0x0
  8013b6:	53                   	push   %ebx
  8013b7:	6a 00                	push   $0x0
  8013b9:	e8 36 07 00 00       	call   801af4 <ipc_recv>
}
  8013be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5d                   	pop    %ebp
  8013c4:	c3                   	ret    

008013c5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8013d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013de:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8013e8:	e8 8d ff ff ff       	call   80137a <fsipc>
}
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801400:	ba 00 00 00 00       	mov    $0x0,%edx
  801405:	b8 06 00 00 00       	mov    $0x6,%eax
  80140a:	e8 6b ff ff ff       	call   80137a <fsipc>
}
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	53                   	push   %ebx
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80141b:	8b 45 08             	mov    0x8(%ebp),%eax
  80141e:	8b 40 0c             	mov    0xc(%eax),%eax
  801421:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801426:	ba 00 00 00 00       	mov    $0x0,%edx
  80142b:	b8 05 00 00 00       	mov    $0x5,%eax
  801430:	e8 45 ff ff ff       	call   80137a <fsipc>
  801435:	85 c0                	test   %eax,%eax
  801437:	78 2c                	js     801465 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801439:	83 ec 08             	sub    $0x8,%esp
  80143c:	68 00 50 80 00       	push   $0x805000
  801441:	53                   	push   %ebx
  801442:	e8 07 f3 ff ff       	call   80074e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801447:	a1 80 50 80 00       	mov    0x805080,%eax
  80144c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801452:	a1 84 50 80 00       	mov    0x805084,%eax
  801457:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 0c             	sub    $0xc,%esp
  801470:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801473:	8b 55 08             	mov    0x8(%ebp),%edx
  801476:	8b 52 0c             	mov    0xc(%edx),%edx
  801479:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80147f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801484:	50                   	push   %eax
  801485:	ff 75 0c             	pushl  0xc(%ebp)
  801488:	68 08 50 80 00       	push   $0x805008
  80148d:	e8 4e f4 ff ff       	call   8008e0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801492:	ba 00 00 00 00       	mov    $0x0,%edx
  801497:	b8 04 00 00 00       	mov    $0x4,%eax
  80149c:	e8 d9 fe ff ff       	call   80137a <fsipc>
	//panic("devfile_write not implemented");
}
  8014a1:	c9                   	leave  
  8014a2:	c3                   	ret    

008014a3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014b6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8014c6:	e8 af fe ff ff       	call   80137a <fsipc>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 51                	js     801522 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8014d1:	39 c6                	cmp    %eax,%esi
  8014d3:	73 19                	jae    8014ee <devfile_read+0x4b>
  8014d5:	68 d4 22 80 00       	push   $0x8022d4
  8014da:	68 db 22 80 00       	push   $0x8022db
  8014df:	68 80 00 00 00       	push   $0x80
  8014e4:	68 f0 22 80 00       	push   $0x8022f0
  8014e9:	e8 c0 05 00 00       	call   801aae <_panic>
	assert(r <= PGSIZE);
  8014ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014f3:	7e 19                	jle    80150e <devfile_read+0x6b>
  8014f5:	68 fb 22 80 00       	push   $0x8022fb
  8014fa:	68 db 22 80 00       	push   $0x8022db
  8014ff:	68 81 00 00 00       	push   $0x81
  801504:	68 f0 22 80 00       	push   $0x8022f0
  801509:	e8 a0 05 00 00       	call   801aae <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	50                   	push   %eax
  801512:	68 00 50 80 00       	push   $0x805000
  801517:	ff 75 0c             	pushl  0xc(%ebp)
  80151a:	e8 c1 f3 ff ff       	call   8008e0 <memmove>
	return r;
  80151f:	83 c4 10             	add    $0x10,%esp
}
  801522:	89 d8                	mov    %ebx,%eax
  801524:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    

0080152b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	53                   	push   %ebx
  80152f:	83 ec 20             	sub    $0x20,%esp
  801532:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801535:	53                   	push   %ebx
  801536:	e8 da f1 ff ff       	call   800715 <strlen>
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801543:	7f 67                	jg     8015ac <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	e8 a1 f8 ff ff       	call   800df2 <fd_alloc>
  801551:	83 c4 10             	add    $0x10,%esp
		return r;
  801554:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801556:	85 c0                	test   %eax,%eax
  801558:	78 57                	js     8015b1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80155a:	83 ec 08             	sub    $0x8,%esp
  80155d:	53                   	push   %ebx
  80155e:	68 00 50 80 00       	push   $0x805000
  801563:	e8 e6 f1 ff ff       	call   80074e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156b:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801570:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801573:	b8 01 00 00 00       	mov    $0x1,%eax
  801578:	e8 fd fd ff ff       	call   80137a <fsipc>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	79 14                	jns    80159a <open+0x6f>
		
		fd_close(fd, 0);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	6a 00                	push   $0x0
  80158b:	ff 75 f4             	pushl  -0xc(%ebp)
  80158e:	e8 57 f9 ff ff       	call   800eea <fd_close>
		return r;
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	89 da                	mov    %ebx,%edx
  801598:	eb 17                	jmp    8015b1 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 26 f8 ff ff       	call   800dcb <fd2num>
  8015a5:	89 c2                	mov    %eax,%edx
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	eb 05                	jmp    8015b1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015ac:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8015b1:	89 d0                	mov    %edx,%eax
  8015b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015be:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8015c8:	e8 ad fd ff ff       	call   80137a <fsipc>
}
  8015cd:	c9                   	leave  
  8015ce:	c3                   	ret    

008015cf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	ff 75 08             	pushl  0x8(%ebp)
  8015dd:	e8 f9 f7 ff ff       	call   800ddb <fd2data>
  8015e2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015e4:	83 c4 08             	add    $0x8,%esp
  8015e7:	68 07 23 80 00       	push   $0x802307
  8015ec:	53                   	push   %ebx
  8015ed:	e8 5c f1 ff ff       	call   80074e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8015f2:	8b 46 04             	mov    0x4(%esi),%eax
  8015f5:	2b 06                	sub    (%esi),%eax
  8015f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8015fd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801604:	00 00 00 
	stat->st_dev = &devpipe;
  801607:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80160e:	30 80 00 
	return 0;
}
  801611:	b8 00 00 00 00       	mov    $0x0,%eax
  801616:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    

0080161d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	53                   	push   %ebx
  801621:	83 ec 0c             	sub    $0xc,%esp
  801624:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801627:	53                   	push   %ebx
  801628:	6a 00                	push   $0x0
  80162a:	e8 a7 f5 ff ff       	call   800bd6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80162f:	89 1c 24             	mov    %ebx,(%esp)
  801632:	e8 a4 f7 ff ff       	call   800ddb <fd2data>
  801637:	83 c4 08             	add    $0x8,%esp
  80163a:	50                   	push   %eax
  80163b:	6a 00                	push   $0x0
  80163d:	e8 94 f5 ff ff       	call   800bd6 <sys_page_unmap>
}
  801642:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	57                   	push   %edi
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	83 ec 1c             	sub    $0x1c,%esp
  801650:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801653:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801655:	a1 04 40 80 00       	mov    0x804004,%eax
  80165a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80165d:	83 ec 0c             	sub    $0xc,%esp
  801660:	ff 75 e0             	pushl  -0x20(%ebp)
  801663:	e8 65 05 00 00       	call   801bcd <pageref>
  801668:	89 c3                	mov    %eax,%ebx
  80166a:	89 3c 24             	mov    %edi,(%esp)
  80166d:	e8 5b 05 00 00       	call   801bcd <pageref>
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	39 c3                	cmp    %eax,%ebx
  801677:	0f 94 c1             	sete   %cl
  80167a:	0f b6 c9             	movzbl %cl,%ecx
  80167d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801680:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801686:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801689:	39 ce                	cmp    %ecx,%esi
  80168b:	74 1b                	je     8016a8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80168d:	39 c3                	cmp    %eax,%ebx
  80168f:	75 c4                	jne    801655 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801691:	8b 42 58             	mov    0x58(%edx),%eax
  801694:	ff 75 e4             	pushl  -0x1c(%ebp)
  801697:	50                   	push   %eax
  801698:	56                   	push   %esi
  801699:	68 0e 23 80 00       	push   $0x80230e
  80169e:	e8 dc ea ff ff       	call   80017f <cprintf>
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	eb ad                	jmp    801655 <_pipeisclosed+0xe>
	}
}
  8016a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ae:	5b                   	pop    %ebx
  8016af:	5e                   	pop    %esi
  8016b0:	5f                   	pop    %edi
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	57                   	push   %edi
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 28             	sub    $0x28,%esp
  8016bc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016bf:	56                   	push   %esi
  8016c0:	e8 16 f7 ff ff       	call   800ddb <fd2data>
  8016c5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8016cf:	eb 4b                	jmp    80171c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016d1:	89 da                	mov    %ebx,%edx
  8016d3:	89 f0                	mov    %esi,%eax
  8016d5:	e8 6d ff ff ff       	call   801647 <_pipeisclosed>
  8016da:	85 c0                	test   %eax,%eax
  8016dc:	75 48                	jne    801726 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016de:	e8 4f f4 ff ff       	call   800b32 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016e3:	8b 43 04             	mov    0x4(%ebx),%eax
  8016e6:	8b 0b                	mov    (%ebx),%ecx
  8016e8:	8d 51 20             	lea    0x20(%ecx),%edx
  8016eb:	39 d0                	cmp    %edx,%eax
  8016ed:	73 e2                	jae    8016d1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8016ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8016f6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	c1 fa 1f             	sar    $0x1f,%edx
  8016fe:	89 d1                	mov    %edx,%ecx
  801700:	c1 e9 1b             	shr    $0x1b,%ecx
  801703:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801706:	83 e2 1f             	and    $0x1f,%edx
  801709:	29 ca                	sub    %ecx,%edx
  80170b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80170f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801713:	83 c0 01             	add    $0x1,%eax
  801716:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801719:	83 c7 01             	add    $0x1,%edi
  80171c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80171f:	75 c2                	jne    8016e3 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801721:	8b 45 10             	mov    0x10(%ebp),%eax
  801724:	eb 05                	jmp    80172b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801726:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80172b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5e                   	pop    %esi
  801730:	5f                   	pop    %edi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	57                   	push   %edi
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
  801739:	83 ec 18             	sub    $0x18,%esp
  80173c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80173f:	57                   	push   %edi
  801740:	e8 96 f6 ff ff       	call   800ddb <fd2data>
  801745:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801747:	83 c4 10             	add    $0x10,%esp
  80174a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80174f:	eb 3d                	jmp    80178e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801751:	85 db                	test   %ebx,%ebx
  801753:	74 04                	je     801759 <devpipe_read+0x26>
				return i;
  801755:	89 d8                	mov    %ebx,%eax
  801757:	eb 44                	jmp    80179d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801759:	89 f2                	mov    %esi,%edx
  80175b:	89 f8                	mov    %edi,%eax
  80175d:	e8 e5 fe ff ff       	call   801647 <_pipeisclosed>
  801762:	85 c0                	test   %eax,%eax
  801764:	75 32                	jne    801798 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801766:	e8 c7 f3 ff ff       	call   800b32 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80176b:	8b 06                	mov    (%esi),%eax
  80176d:	3b 46 04             	cmp    0x4(%esi),%eax
  801770:	74 df                	je     801751 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801772:	99                   	cltd   
  801773:	c1 ea 1b             	shr    $0x1b,%edx
  801776:	01 d0                	add    %edx,%eax
  801778:	83 e0 1f             	and    $0x1f,%eax
  80177b:	29 d0                	sub    %edx,%eax
  80177d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801782:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801785:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801788:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178b:	83 c3 01             	add    $0x1,%ebx
  80178e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801791:	75 d8                	jne    80176b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801793:	8b 45 10             	mov    0x10(%ebp),%eax
  801796:	eb 05                	jmp    80179d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801798:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80179d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017a0:	5b                   	pop    %ebx
  8017a1:	5e                   	pop    %esi
  8017a2:	5f                   	pop    %edi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	56                   	push   %esi
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	e8 3c f6 ff ff       	call   800df2 <fd_alloc>
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	89 c2                	mov    %eax,%edx
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	0f 88 2c 01 00 00    	js     8018ef <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c3:	83 ec 04             	sub    $0x4,%esp
  8017c6:	68 07 04 00 00       	push   $0x407
  8017cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ce:	6a 00                	push   $0x0
  8017d0:	e8 7c f3 ff ff       	call   800b51 <sys_page_alloc>
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	89 c2                	mov    %eax,%edx
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	0f 88 0d 01 00 00    	js     8018ef <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e8:	50                   	push   %eax
  8017e9:	e8 04 f6 ff ff       	call   800df2 <fd_alloc>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	0f 88 e2 00 00 00    	js     8018dd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	68 07 04 00 00       	push   $0x407
  801803:	ff 75 f0             	pushl  -0x10(%ebp)
  801806:	6a 00                	push   $0x0
  801808:	e8 44 f3 ff ff       	call   800b51 <sys_page_alloc>
  80180d:	89 c3                	mov    %eax,%ebx
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	85 c0                	test   %eax,%eax
  801814:	0f 88 c3 00 00 00    	js     8018dd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	ff 75 f4             	pushl  -0xc(%ebp)
  801820:	e8 b6 f5 ff ff       	call   800ddb <fd2data>
  801825:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801827:	83 c4 0c             	add    $0xc,%esp
  80182a:	68 07 04 00 00       	push   $0x407
  80182f:	50                   	push   %eax
  801830:	6a 00                	push   $0x0
  801832:	e8 1a f3 ff ff       	call   800b51 <sys_page_alloc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	0f 88 89 00 00 00    	js     8018cd <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801844:	83 ec 0c             	sub    $0xc,%esp
  801847:	ff 75 f0             	pushl  -0x10(%ebp)
  80184a:	e8 8c f5 ff ff       	call   800ddb <fd2data>
  80184f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801856:	50                   	push   %eax
  801857:	6a 00                	push   $0x0
  801859:	56                   	push   %esi
  80185a:	6a 00                	push   $0x0
  80185c:	e8 33 f3 ff ff       	call   800b94 <sys_page_map>
  801861:	89 c3                	mov    %eax,%ebx
  801863:	83 c4 20             	add    $0x20,%esp
  801866:	85 c0                	test   %eax,%eax
  801868:	78 55                	js     8018bf <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80186a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801870:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801873:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801875:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801878:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80187f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801885:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801888:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80188a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	ff 75 f4             	pushl  -0xc(%ebp)
  80189a:	e8 2c f5 ff ff       	call   800dcb <fd2num>
  80189f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018a2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018a4:	83 c4 04             	add    $0x4,%esp
  8018a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8018aa:	e8 1c f5 ff ff       	call   800dcb <fd2num>
  8018af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bd:	eb 30                	jmp    8018ef <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018bf:	83 ec 08             	sub    $0x8,%esp
  8018c2:	56                   	push   %esi
  8018c3:	6a 00                	push   $0x0
  8018c5:	e8 0c f3 ff ff       	call   800bd6 <sys_page_unmap>
  8018ca:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018cd:	83 ec 08             	sub    $0x8,%esp
  8018d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d3:	6a 00                	push   $0x0
  8018d5:	e8 fc f2 ff ff       	call   800bd6 <sys_page_unmap>
  8018da:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e3:	6a 00                	push   $0x0
  8018e5:	e8 ec f2 ff ff       	call   800bd6 <sys_page_unmap>
  8018ea:	83 c4 10             	add    $0x10,%esp
  8018ed:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8018ef:	89 d0                	mov    %edx,%eax
  8018f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801901:	50                   	push   %eax
  801902:	ff 75 08             	pushl  0x8(%ebp)
  801905:	e8 37 f5 ff ff       	call   800e41 <fd_lookup>
  80190a:	83 c4 10             	add    $0x10,%esp
  80190d:	85 c0                	test   %eax,%eax
  80190f:	78 18                	js     801929 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801911:	83 ec 0c             	sub    $0xc,%esp
  801914:	ff 75 f4             	pushl  -0xc(%ebp)
  801917:	e8 bf f4 ff ff       	call   800ddb <fd2data>
	return _pipeisclosed(fd, p);
  80191c:	89 c2                	mov    %eax,%edx
  80191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801921:	e8 21 fd ff ff       	call   801647 <_pipeisclosed>
  801926:	83 c4 10             	add    $0x10,%esp
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80192e:	b8 00 00 00 00       	mov    $0x0,%eax
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80193b:	68 26 23 80 00       	push   $0x802326
  801940:	ff 75 0c             	pushl  0xc(%ebp)
  801943:	e8 06 ee ff ff       	call   80074e <strcpy>
	return 0;
}
  801948:	b8 00 00 00 00       	mov    $0x0,%eax
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	57                   	push   %edi
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80195b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801960:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801966:	eb 2d                	jmp    801995 <devcons_write+0x46>
		m = n - tot;
  801968:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80196b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80196d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801970:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801975:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	53                   	push   %ebx
  80197c:	03 45 0c             	add    0xc(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	57                   	push   %edi
  801981:	e8 5a ef ff ff       	call   8008e0 <memmove>
		sys_cputs(buf, m);
  801986:	83 c4 08             	add    $0x8,%esp
  801989:	53                   	push   %ebx
  80198a:	57                   	push   %edi
  80198b:	e8 05 f1 ff ff       	call   800a95 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801990:	01 de                	add    %ebx,%esi
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	89 f0                	mov    %esi,%eax
  801997:	3b 75 10             	cmp    0x10(%ebp),%esi
  80199a:	72 cc                	jb     801968 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80199c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5f                   	pop    %edi
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 08             	sub    $0x8,%esp
  8019aa:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019b3:	74 2a                	je     8019df <devcons_read+0x3b>
  8019b5:	eb 05                	jmp    8019bc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019b7:	e8 76 f1 ff ff       	call   800b32 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019bc:	e8 f2 f0 ff ff       	call   800ab3 <sys_cgetc>
  8019c1:	85 c0                	test   %eax,%eax
  8019c3:	74 f2                	je     8019b7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 16                	js     8019df <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019c9:	83 f8 04             	cmp    $0x4,%eax
  8019cc:	74 0c                	je     8019da <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019d1:	88 02                	mov    %al,(%edx)
	return 1;
  8019d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019d8:	eb 05                	jmp    8019df <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019da:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ea:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019ed:	6a 01                	push   $0x1
  8019ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8019f2:	50                   	push   %eax
  8019f3:	e8 9d f0 ff ff       	call   800a95 <sys_cputs>
}
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <getchar>:

int
getchar(void)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a03:	6a 01                	push   $0x1
  801a05:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a08:	50                   	push   %eax
  801a09:	6a 00                	push   $0x0
  801a0b:	e8 97 f6 ff ff       	call   8010a7 <read>
	if (r < 0)
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 0f                	js     801a26 <getchar+0x29>
		return r;
	if (r < 1)
  801a17:	85 c0                	test   %eax,%eax
  801a19:	7e 06                	jle    801a21 <getchar+0x24>
		return -E_EOF;
	return c;
  801a1b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a1f:	eb 05                	jmp    801a26 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a21:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a31:	50                   	push   %eax
  801a32:	ff 75 08             	pushl  0x8(%ebp)
  801a35:	e8 07 f4 ff ff       	call   800e41 <fd_lookup>
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 11                	js     801a52 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a44:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a4a:	39 10                	cmp    %edx,(%eax)
  801a4c:	0f 94 c0             	sete   %al
  801a4f:	0f b6 c0             	movzbl %al,%eax
}
  801a52:	c9                   	leave  
  801a53:	c3                   	ret    

00801a54 <opencons>:

int
opencons(void)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5d:	50                   	push   %eax
  801a5e:	e8 8f f3 ff ff       	call   800df2 <fd_alloc>
  801a63:	83 c4 10             	add    $0x10,%esp
		return r;
  801a66:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	78 3e                	js     801aaa <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a6c:	83 ec 04             	sub    $0x4,%esp
  801a6f:	68 07 04 00 00       	push   $0x407
  801a74:	ff 75 f4             	pushl  -0xc(%ebp)
  801a77:	6a 00                	push   $0x0
  801a79:	e8 d3 f0 ff ff       	call   800b51 <sys_page_alloc>
  801a7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801a81:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 23                	js     801aaa <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a87:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a90:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a95:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a9c:	83 ec 0c             	sub    $0xc,%esp
  801a9f:	50                   	push   %eax
  801aa0:	e8 26 f3 ff ff       	call   800dcb <fd2num>
  801aa5:	89 c2                	mov    %eax,%edx
  801aa7:	83 c4 10             	add    $0x10,%esp
}
  801aaa:	89 d0                	mov    %edx,%eax
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ab3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ab6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801abc:	e8 52 f0 ff ff       	call   800b13 <sys_getenvid>
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	ff 75 0c             	pushl  0xc(%ebp)
  801ac7:	ff 75 08             	pushl  0x8(%ebp)
  801aca:	56                   	push   %esi
  801acb:	50                   	push   %eax
  801acc:	68 34 23 80 00       	push   $0x802334
  801ad1:	e8 a9 e6 ff ff       	call   80017f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ad6:	83 c4 18             	add    $0x18,%esp
  801ad9:	53                   	push   %ebx
  801ada:	ff 75 10             	pushl  0x10(%ebp)
  801add:	e8 4c e6 ff ff       	call   80012e <vcprintf>
	cprintf("\n");
  801ae2:	c7 04 24 d3 1e 80 00 	movl   $0x801ed3,(%esp)
  801ae9:	e8 91 e6 ff ff       	call   80017f <cprintf>
  801aee:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801af1:	cc                   	int3   
  801af2:	eb fd                	jmp    801af1 <_panic+0x43>

00801af4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801afc:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801aff:	83 ec 0c             	sub    $0xc,%esp
  801b02:	ff 75 0c             	pushl  0xc(%ebp)
  801b05:	e8 f7 f1 ff ff       	call   800d01 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801b0a:	83 c4 10             	add    $0x10,%esp
  801b0d:	85 f6                	test   %esi,%esi
  801b0f:	74 1c                	je     801b2d <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801b11:	a1 04 40 80 00       	mov    0x804004,%eax
  801b16:	8b 40 78             	mov    0x78(%eax),%eax
  801b19:	89 06                	mov    %eax,(%esi)
  801b1b:	eb 10                	jmp    801b2d <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801b1d:	83 ec 0c             	sub    $0xc,%esp
  801b20:	68 58 23 80 00       	push   $0x802358
  801b25:	e8 55 e6 ff ff       	call   80017f <cprintf>
  801b2a:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801b2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b32:	8b 50 74             	mov    0x74(%eax),%edx
  801b35:	85 d2                	test   %edx,%edx
  801b37:	74 e4                	je     801b1d <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801b39:	85 db                	test   %ebx,%ebx
  801b3b:	74 05                	je     801b42 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801b3d:	8b 40 74             	mov    0x74(%eax),%eax
  801b40:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b42:	a1 04 40 80 00       	mov    0x804004,%eax
  801b47:	8b 40 70             	mov    0x70(%eax),%eax

}
  801b4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	57                   	push   %edi
  801b55:	56                   	push   %esi
  801b56:	53                   	push   %ebx
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801b63:	85 db                	test   %ebx,%ebx
  801b65:	75 13                	jne    801b7a <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801b67:	6a 00                	push   $0x0
  801b69:	68 00 00 c0 ee       	push   $0xeec00000
  801b6e:	56                   	push   %esi
  801b6f:	57                   	push   %edi
  801b70:	e8 69 f1 ff ff       	call   800cde <sys_ipc_try_send>
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	eb 0e                	jmp    801b88 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801b7a:	ff 75 14             	pushl  0x14(%ebp)
  801b7d:	53                   	push   %ebx
  801b7e:	56                   	push   %esi
  801b7f:	57                   	push   %edi
  801b80:	e8 59 f1 ff ff       	call   800cde <sys_ipc_try_send>
  801b85:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	75 d7                	jne    801b63 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8f:	5b                   	pop    %ebx
  801b90:	5e                   	pop    %esi
  801b91:	5f                   	pop    %edi
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b9f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ba8:	8b 52 50             	mov    0x50(%edx),%edx
  801bab:	39 ca                	cmp    %ecx,%edx
  801bad:	75 0d                	jne    801bbc <ipc_find_env+0x28>
			return envs[i].env_id;
  801baf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb7:	8b 40 48             	mov    0x48(%eax),%eax
  801bba:	eb 0f                	jmp    801bcb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbc:	83 c0 01             	add    $0x1,%eax
  801bbf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc4:	75 d9                	jne    801b9f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd3:	89 d0                	mov    %edx,%eax
  801bd5:	c1 e8 16             	shr    $0x16,%eax
  801bd8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be4:	f6 c1 01             	test   $0x1,%cl
  801be7:	74 1d                	je     801c06 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801be9:	c1 ea 0c             	shr    $0xc,%edx
  801bec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf3:	f6 c2 01             	test   $0x1,%dl
  801bf6:	74 0e                	je     801c06 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf8:	c1 ea 0c             	shr    $0xc,%edx
  801bfb:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c02:	ef 
  801c03:	0f b7 c0             	movzwl %ax,%eax
}
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	66 90                	xchg   %ax,%ax
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 f6                	test   %esi,%esi
  801c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c2d:	89 ca                	mov    %ecx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	75 3d                	jne    801c70 <__udivdi3+0x60>
  801c33:	39 cf                	cmp    %ecx,%edi
  801c35:	0f 87 c5 00 00 00    	ja     801d00 <__udivdi3+0xf0>
  801c3b:	85 ff                	test   %edi,%edi
  801c3d:	89 fd                	mov    %edi,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f7                	div    %edi
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 c8                	mov    %ecx,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c1                	mov    %eax,%ecx
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	89 cf                	mov    %ecx,%edi
  801c58:	f7 f5                	div    %ebp
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	77 74                	ja     801ce8 <__udivdi3+0xd8>
  801c74:	0f bd fe             	bsr    %esi,%edi
  801c77:	83 f7 1f             	xor    $0x1f,%edi
  801c7a:	0f 84 98 00 00 00    	je     801d18 <__udivdi3+0x108>
  801c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	89 c5                	mov    %eax,%ebp
  801c89:	29 fb                	sub    %edi,%ebx
  801c8b:	d3 e6                	shl    %cl,%esi
  801c8d:	89 d9                	mov    %ebx,%ecx
  801c8f:	d3 ed                	shr    %cl,%ebp
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	09 ee                	or     %ebp,%esi
  801c97:	89 d9                	mov    %ebx,%ecx
  801c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9d:	89 d5                	mov    %edx,%ebp
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	d3 ed                	shr    %cl,%ebp
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e2                	shl    %cl,%edx
  801ca9:	89 d9                	mov    %ebx,%ecx
  801cab:	d3 e8                	shr    %cl,%eax
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 d0                	mov    %edx,%eax
  801cb1:	89 ea                	mov    %ebp,%edx
  801cb3:	f7 f6                	div    %esi
  801cb5:	89 d5                	mov    %edx,%ebp
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	f7 64 24 0c          	mull   0xc(%esp)
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	72 10                	jb     801cd1 <__udivdi3+0xc1>
  801cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e6                	shl    %cl,%esi
  801cc9:	39 c6                	cmp    %eax,%esi
  801ccb:	73 07                	jae    801cd4 <__udivdi3+0xc4>
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	75 03                	jne    801cd4 <__udivdi3+0xc4>
  801cd1:	83 eb 01             	sub    $0x1,%ebx
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 db                	xor    %ebx,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	f7 f7                	div    %edi
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	39 ce                	cmp    %ecx,%esi
  801d1a:	72 0c                	jb     801d28 <__udivdi3+0x118>
  801d1c:	31 db                	xor    %ebx,%ebx
  801d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d22:	0f 87 34 ff ff ff    	ja     801c5c <__udivdi3+0x4c>
  801d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d2d:	e9 2a ff ff ff       	jmp    801c5c <__udivdi3+0x4c>
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 d2                	test   %edx,%edx
  801d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f3                	mov    %esi,%ebx
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	75 1c                	jne    801d88 <__umoddi3+0x48>
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	76 50                	jbe    801dc0 <__umoddi3+0x80>
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	f7 f7                	div    %edi
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	77 52                	ja     801de0 <__umoddi3+0xa0>
  801d8e:	0f bd ea             	bsr    %edx,%ebp
  801d91:	83 f5 1f             	xor    $0x1f,%ebp
  801d94:	75 5a                	jne    801df0 <__umoddi3+0xb0>
  801d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	39 0c 24             	cmp    %ecx,(%esp)
  801da3:	0f 86 d7 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	85 ff                	test   %edi,%edi
  801dc2:	89 fd                	mov    %edi,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	eb 99                	jmp    801d78 <__umoddi3+0x38>
  801ddf:	90                   	nop
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	8b 34 24             	mov    (%esp),%esi
  801df3:	bf 20 00 00 00       	mov    $0x20,%edi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	29 ef                	sub    %ebp,%edi
  801dfc:	d3 e0                	shl    %cl,%eax
  801dfe:	89 f9                	mov    %edi,%ecx
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	d3 ea                	shr    %cl,%edx
  801e04:	89 e9                	mov    %ebp,%ecx
  801e06:	09 c2                	or     %eax,%edx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 14 24             	mov    %edx,(%esp)
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	d3 e3                	shl    %cl,%ebx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	09 d8                	or     %ebx,%eax
  801e2d:	89 d3                	mov    %edx,%ebx
  801e2f:	89 f2                	mov    %esi,%edx
  801e31:	f7 34 24             	divl   (%esp)
  801e34:	89 d6                	mov    %edx,%esi
  801e36:	d3 e3                	shl    %cl,%ebx
  801e38:	f7 64 24 04          	mull   0x4(%esp)
  801e3c:	39 d6                	cmp    %edx,%esi
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	72 08                	jb     801e50 <__umoddi3+0x110>
  801e48:	75 11                	jne    801e5b <__umoddi3+0x11b>
  801e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e4e:	73 0b                	jae    801e5b <__umoddi3+0x11b>
  801e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e54:	1b 14 24             	sbb    (%esp),%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e5f:	29 da                	sub    %ebx,%edx
  801e61:	19 ce                	sbb    %ecx,%esi
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e0                	shl    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 ea                	shr    %cl,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d0                	or     %edx,%eax
  801e73:	89 f2                	mov    %esi,%edx
  801e75:	83 c4 1c             	add    $0x1c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 f9                	sub    %edi,%ecx
  801e82:	19 d6                	sbb    %edx,%esi
  801e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e8c:	e9 18 ff ff ff       	jmp    801da9 <__umoddi3+0x69>
