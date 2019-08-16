
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 c0 0f 80 00       	push   $0x800fc0
  800056:	e8 f0 00 00 00       	call   80014b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 6f 0a 00 00       	call   800adf <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 eb 09 00 00       	call   800a9e <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 1a                	jne    8000f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 79 09 00 00       	call   800a61 <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b8 00 80 00       	push   $0x8000b8
  800129:	e8 54 01 00 00       	call   800282 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 1e 09 00 00       	call   800a61 <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800175:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800178:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800180:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800183:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800186:	39 d3                	cmp    %edx,%ebx
  800188:	72 05                	jb     80018f <printnum+0x30>
  80018a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018d:	77 45                	ja     8001d4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 18             	pushl  0x18(%ebp)
  800195:	8b 45 14             	mov    0x14(%ebp),%eax
  800198:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019b:	53                   	push   %ebx
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ae:	e8 6d 0b 00 00       	call   800d20 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9e ff ff ff       	call   80015f <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 18                	jmp    8001de <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	eb 03                	jmp    8001d7 <printnum+0x78>
  8001d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d7:	83 eb 01             	sub    $0x1,%ebx
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7f e8                	jg     8001c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	56                   	push   %esi
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f1:	e8 5a 0c 00 00       	call   800e50 <__umoddi3>
  8001f6:	83 c4 14             	add    $0x14,%esp
  8001f9:	0f be 80 d8 0f 80 00 	movsbl 0x800fd8(%eax),%eax
  800200:	50                   	push   %eax
  800201:	ff d7                	call   *%edi
}
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800211:	83 fa 01             	cmp    $0x1,%edx
  800214:	7e 0e                	jle    800224 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	8b 52 04             	mov    0x4(%edx),%edx
  800222:	eb 22                	jmp    800246 <getuint+0x38>
	else if (lflag)
  800224:	85 d2                	test   %edx,%edx
  800226:	74 10                	je     800238 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
  800236:	eb 0e                	jmp    800246 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800252:	8b 10                	mov    (%eax),%edx
  800254:	3b 50 04             	cmp    0x4(%eax),%edx
  800257:	73 0a                	jae    800263 <sprintputch+0x1b>
		*b->buf++ = ch;
  800259:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	88 02                	mov    %al,(%edx)
}
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 05 00 00 00       	call   800282 <vprintfmt>
	va_end(ap);
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 2c             	sub    $0x2c,%esp
  80028b:	8b 75 08             	mov    0x8(%ebp),%esi
  80028e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800291:	8b 7d 10             	mov    0x10(%ebp),%edi
  800294:	eb 12                	jmp    8002a8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800296:	85 c0                	test   %eax,%eax
  800298:	0f 84 d3 03 00 00    	je     800671 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	53                   	push   %ebx
  8002a2:	50                   	push   %eax
  8002a3:	ff d6                	call   *%esi
  8002a5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a8:	83 c7 01             	add    $0x1,%edi
  8002ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002af:	83 f8 25             	cmp    $0x25,%eax
  8002b2:	75 e2                	jne    800296 <vprintfmt+0x14>
  8002b4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	eb 07                	jmp    8002db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	8d 47 01             	lea    0x1(%edi),%eax
  8002de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e1:	0f b6 07             	movzbl (%edi),%eax
  8002e4:	0f b6 c8             	movzbl %al,%ecx
  8002e7:	83 e8 23             	sub    $0x23,%eax
  8002ea:	3c 55                	cmp    $0x55,%al
  8002ec:	0f 87 64 03 00 00    	ja     800656 <vprintfmt+0x3d4>
  8002f2:	0f b6 c0             	movzbl %al,%eax
  8002f5:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ff:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800303:	eb d6                	jmp    8002db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800308:	b8 00 00 00 00       	mov    $0x0,%eax
  80030d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800310:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800313:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800317:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031d:	83 fa 09             	cmp    $0x9,%edx
  800320:	77 39                	ja     80035b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800322:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800325:	eb e9                	jmp    800310 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800327:	8b 45 14             	mov    0x14(%ebp),%eax
  80032a:	8d 48 04             	lea    0x4(%eax),%ecx
  80032d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800330:	8b 00                	mov    (%eax),%eax
  800332:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800338:	eb 27                	jmp    800361 <vprintfmt+0xdf>
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	85 c0                	test   %eax,%eax
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	0f 49 c8             	cmovns %eax,%ecx
  800347:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034d:	eb 8c                	jmp    8002db <vprintfmt+0x59>
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800352:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800359:	eb 80                	jmp    8002db <vprintfmt+0x59>
  80035b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035e:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800361:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800365:	0f 89 70 ff ff ff    	jns    8002db <vprintfmt+0x59>
				width = precision, precision = -1;
  80036b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80036e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800371:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800378:	e9 5e ff ff ff       	jmp    8002db <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800383:	e9 53 ff ff ff       	jmp    8002db <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 50 04             	lea    0x4(%eax),%edx
  80038e:	89 55 14             	mov    %edx,0x14(%ebp)
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	53                   	push   %ebx
  800395:	ff 30                	pushl  (%eax)
  800397:	ff d6                	call   *%esi
			break;
  800399:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039f:	e9 04 ff ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 50 04             	lea    0x4(%eax),%edx
  8003aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	99                   	cltd   
  8003b0:	31 d0                	xor    %edx,%eax
  8003b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b4:	83 f8 08             	cmp    $0x8,%eax
  8003b7:	7f 0b                	jg     8003c4 <vprintfmt+0x142>
  8003b9:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	75 18                	jne    8003dc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c4:	50                   	push   %eax
  8003c5:	68 f0 0f 80 00       	push   $0x800ff0
  8003ca:	53                   	push   %ebx
  8003cb:	56                   	push   %esi
  8003cc:	e8 94 fe ff ff       	call   800265 <printfmt>
  8003d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d7:	e9 cc fe ff ff       	jmp    8002a8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003dc:	52                   	push   %edx
  8003dd:	68 f9 0f 80 00       	push   $0x800ff9
  8003e2:	53                   	push   %ebx
  8003e3:	56                   	push   %esi
  8003e4:	e8 7c fe ff ff       	call   800265 <printfmt>
  8003e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	e9 b4 fe ff ff       	jmp    8002a8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ff:	85 ff                	test   %edi,%edi
  800401:	b8 e9 0f 80 00       	mov    $0x800fe9,%eax
  800406:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040d:	0f 8e 94 00 00 00    	jle    8004a7 <vprintfmt+0x225>
  800413:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800417:	0f 84 98 00 00 00    	je     8004b5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	ff 75 c8             	pushl  -0x38(%ebp)
  800423:	57                   	push   %edi
  800424:	e8 d0 02 00 00       	call   8006f9 <strnlen>
  800429:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042c:	29 c1                	sub    %eax,%ecx
  80042e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800431:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800434:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	eb 0f                	jmp    800451 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	ff 75 e0             	pushl  -0x20(%ebp)
  800449:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ef 01             	sub    $0x1,%edi
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	85 ff                	test   %edi,%edi
  800453:	7f ed                	jg     800442 <vprintfmt+0x1c0>
  800455:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800458:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80045b:	85 c9                	test   %ecx,%ecx
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	0f 49 c1             	cmovns %ecx,%eax
  800465:	29 c1                	sub    %eax,%ecx
  800467:	89 75 08             	mov    %esi,0x8(%ebp)
  80046a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80046d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800470:	89 cb                	mov    %ecx,%ebx
  800472:	eb 4d                	jmp    8004c1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	74 1b                	je     800495 <vprintfmt+0x213>
  80047a:	0f be c0             	movsbl %al,%eax
  80047d:	83 e8 20             	sub    $0x20,%eax
  800480:	83 f8 5e             	cmp    $0x5e,%eax
  800483:	76 10                	jbe    800495 <vprintfmt+0x213>
					putch('?', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	6a 3f                	push   $0x3f
  80048d:	ff 55 08             	call   *0x8(%ebp)
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb 0d                	jmp    8004a2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	52                   	push   %edx
  80049c:	ff 55 08             	call   *0x8(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	eb 1a                	jmp    8004c1 <vprintfmt+0x23f>
  8004a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004aa:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b3:	eb 0c                	jmp    8004c1 <vprintfmt+0x23f>
  8004b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b8:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c1:	83 c7 01             	add    $0x1,%edi
  8004c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c8:	0f be d0             	movsbl %al,%edx
  8004cb:	85 d2                	test   %edx,%edx
  8004cd:	74 23                	je     8004f2 <vprintfmt+0x270>
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	78 a1                	js     800474 <vprintfmt+0x1f2>
  8004d3:	83 ee 01             	sub    $0x1,%esi
  8004d6:	79 9c                	jns    800474 <vprintfmt+0x1f2>
  8004d8:	89 df                	mov    %ebx,%edi
  8004da:	8b 75 08             	mov    0x8(%ebp),%esi
  8004dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e0:	eb 18                	jmp    8004fa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 20                	push   $0x20
  8004e8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x278>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	7f e4                	jg     8004e2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 a2 fd ff ff       	jmp    8002a8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 fa 01             	cmp    $0x1,%edx
  800509:	7e 16                	jle    800521 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 08             	lea    0x8(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 50 04             	mov    0x4(%eax),%edx
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80051c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80051f:	eb 32                	jmp    800553 <vprintfmt+0x2d1>
	else if (lflag)
  800521:	85 d2                	test   %edx,%edx
  800523:	74 18                	je     80053d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800533:	89 c1                	mov    %eax,%ecx
  800535:	c1 f9 1f             	sar    $0x1f,%ecx
  800538:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80053b:	eb 16                	jmp    800553 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800553:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800556:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800559:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800564:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800568:	0f 89 b0 00 00 00    	jns    80061e <vprintfmt+0x39c>
				putch('-', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	6a 2d                	push   $0x2d
  800574:	ff d6                	call   *%esi
				num = -(long long) num;
  800576:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800579:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80057c:	f7 d8                	neg    %eax
  80057e:	83 d2 00             	adc    $0x0,%edx
  800581:	f7 da                	neg    %edx
  800583:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800586:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800589:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800591:	e9 88 00 00 00       	jmp    80061e <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800596:	8d 45 14             	lea    0x14(%ebp),%eax
  800599:	e8 70 fc ff ff       	call   80020e <getuint>
  80059e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a9:	eb 73                	jmp    80061e <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 5b fc ff ff       	call   80020e <getuint>
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 58                	push   $0x58
  8005bf:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c1:	83 c4 08             	add    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 58                	push   $0x58
  8005c7:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c9:	83 c4 08             	add    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 58                	push   $0x58
  8005cf:	ff d6                	call   *%esi
			goto number;
  8005d1:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005d4:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005d9:	eb 43                	jmp    80061e <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 30                	push   $0x30
  8005e1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e3:	83 c4 08             	add    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 78                	push   $0x78
  8005e9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800601:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800604:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800609:	eb 13                	jmp    80061e <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 fb fb ff ff       	call   80020e <getuint>
  800613:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800616:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800619:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061e:	83 ec 0c             	sub    $0xc,%esp
  800621:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800625:	52                   	push   %edx
  800626:	ff 75 e0             	pushl  -0x20(%ebp)
  800629:	50                   	push   %eax
  80062a:	ff 75 dc             	pushl  -0x24(%ebp)
  80062d:	ff 75 d8             	pushl  -0x28(%ebp)
  800630:	89 da                	mov    %ebx,%edx
  800632:	89 f0                	mov    %esi,%eax
  800634:	e8 26 fb ff ff       	call   80015f <printnum>
			break;
  800639:	83 c4 20             	add    $0x20,%esp
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063f:	e9 64 fc ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	51                   	push   %ecx
  800649:	ff d6                	call   *%esi
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800651:	e9 52 fc ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 25                	push   $0x25
  80065c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	eb 03                	jmp    800666 <vprintfmt+0x3e4>
  800663:	83 ef 01             	sub    $0x1,%edi
  800666:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066a:	75 f7                	jne    800663 <vprintfmt+0x3e1>
  80066c:	e9 37 fc ff ff       	jmp    8002a8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800674:	5b                   	pop    %ebx
  800675:	5e                   	pop    %esi
  800676:	5f                   	pop    %edi
  800677:	5d                   	pop    %ebp
  800678:	c3                   	ret    

00800679 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	83 ec 18             	sub    $0x18,%esp
  80067f:	8b 45 08             	mov    0x8(%ebp),%eax
  800682:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800685:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800688:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800696:	85 c0                	test   %eax,%eax
  800698:	74 26                	je     8006c0 <vsnprintf+0x47>
  80069a:	85 d2                	test   %edx,%edx
  80069c:	7e 22                	jle    8006c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069e:	ff 75 14             	pushl  0x14(%ebp)
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a7:	50                   	push   %eax
  8006a8:	68 48 02 80 00       	push   $0x800248
  8006ad:	e8 d0 fb ff ff       	call   800282 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb 05                	jmp    8006c5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c5:	c9                   	leave  
  8006c6:	c3                   	ret    

008006c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d0:	50                   	push   %eax
  8006d1:	ff 75 10             	pushl  0x10(%ebp)
  8006d4:	ff 75 0c             	pushl  0xc(%ebp)
  8006d7:	ff 75 08             	pushl  0x8(%ebp)
  8006da:	e8 9a ff ff ff       	call   800679 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006df:	c9                   	leave  
  8006e0:	c3                   	ret    

008006e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ec:	eb 03                	jmp    8006f1 <strlen+0x10>
		n++;
  8006ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f5:	75 f7                	jne    8006ee <strlen+0xd>
		n++;
	return n;
}
  8006f7:	5d                   	pop    %ebp
  8006f8:	c3                   	ret    

008006f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800702:	ba 00 00 00 00       	mov    $0x0,%edx
  800707:	eb 03                	jmp    80070c <strnlen+0x13>
		n++;
  800709:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070c:	39 c2                	cmp    %eax,%edx
  80070e:	74 08                	je     800718 <strnlen+0x1f>
  800710:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800714:	75 f3                	jne    800709 <strnlen+0x10>
  800716:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	53                   	push   %ebx
  80071e:	8b 45 08             	mov    0x8(%ebp),%eax
  800721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800724:	89 c2                	mov    %eax,%edx
  800726:	83 c2 01             	add    $0x1,%edx
  800729:	83 c1 01             	add    $0x1,%ecx
  80072c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800730:	88 5a ff             	mov    %bl,-0x1(%edx)
  800733:	84 db                	test   %bl,%bl
  800735:	75 ef                	jne    800726 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800737:	5b                   	pop    %ebx
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	53                   	push   %ebx
  80073e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800741:	53                   	push   %ebx
  800742:	e8 9a ff ff ff       	call   8006e1 <strlen>
  800747:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	01 d8                	add    %ebx,%eax
  80074f:	50                   	push   %eax
  800750:	e8 c5 ff ff ff       	call   80071a <strcpy>
	return dst;
}
  800755:	89 d8                	mov    %ebx,%eax
  800757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	56                   	push   %esi
  800760:	53                   	push   %ebx
  800761:	8b 75 08             	mov    0x8(%ebp),%esi
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800767:	89 f3                	mov    %esi,%ebx
  800769:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076c:	89 f2                	mov    %esi,%edx
  80076e:	eb 0f                	jmp    80077f <strncpy+0x23>
		*dst++ = *src;
  800770:	83 c2 01             	add    $0x1,%edx
  800773:	0f b6 01             	movzbl (%ecx),%eax
  800776:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800779:	80 39 01             	cmpb   $0x1,(%ecx)
  80077c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077f:	39 da                	cmp    %ebx,%edx
  800781:	75 ed                	jne    800770 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800783:	89 f0                	mov    %esi,%eax
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	56                   	push   %esi
  80078d:	53                   	push   %ebx
  80078e:	8b 75 08             	mov    0x8(%ebp),%esi
  800791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800794:	8b 55 10             	mov    0x10(%ebp),%edx
  800797:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800799:	85 d2                	test   %edx,%edx
  80079b:	74 21                	je     8007be <strlcpy+0x35>
  80079d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a1:	89 f2                	mov    %esi,%edx
  8007a3:	eb 09                	jmp    8007ae <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a5:	83 c2 01             	add    $0x1,%edx
  8007a8:	83 c1 01             	add    $0x1,%ecx
  8007ab:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ae:	39 c2                	cmp    %eax,%edx
  8007b0:	74 09                	je     8007bb <strlcpy+0x32>
  8007b2:	0f b6 19             	movzbl (%ecx),%ebx
  8007b5:	84 db                	test   %bl,%bl
  8007b7:	75 ec                	jne    8007a5 <strlcpy+0x1c>
  8007b9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007be:	29 f0                	sub    %esi,%eax
}
  8007c0:	5b                   	pop    %ebx
  8007c1:	5e                   	pop    %esi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cd:	eb 06                	jmp    8007d5 <strcmp+0x11>
		p++, q++;
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d5:	0f b6 01             	movzbl (%ecx),%eax
  8007d8:	84 c0                	test   %al,%al
  8007da:	74 04                	je     8007e0 <strcmp+0x1c>
  8007dc:	3a 02                	cmp    (%edx),%al
  8007de:	74 ef                	je     8007cf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e0:	0f b6 c0             	movzbl %al,%eax
  8007e3:	0f b6 12             	movzbl (%edx),%edx
  8007e6:	29 d0                	sub    %edx,%eax
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	89 c3                	mov    %eax,%ebx
  8007f6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f9:	eb 06                	jmp    800801 <strncmp+0x17>
		n--, p++, q++;
  8007fb:	83 c0 01             	add    $0x1,%eax
  8007fe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800801:	39 d8                	cmp    %ebx,%eax
  800803:	74 15                	je     80081a <strncmp+0x30>
  800805:	0f b6 08             	movzbl (%eax),%ecx
  800808:	84 c9                	test   %cl,%cl
  80080a:	74 04                	je     800810 <strncmp+0x26>
  80080c:	3a 0a                	cmp    (%edx),%cl
  80080e:	74 eb                	je     8007fb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800810:	0f b6 00             	movzbl (%eax),%eax
  800813:	0f b6 12             	movzbl (%edx),%edx
  800816:	29 d0                	sub    %edx,%eax
  800818:	eb 05                	jmp    80081f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081f:	5b                   	pop    %ebx
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082c:	eb 07                	jmp    800835 <strchr+0x13>
		if (*s == c)
  80082e:	38 ca                	cmp    %cl,%dl
  800830:	74 0f                	je     800841 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	0f b6 10             	movzbl (%eax),%edx
  800838:	84 d2                	test   %dl,%dl
  80083a:	75 f2                	jne    80082e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084d:	eb 03                	jmp    800852 <strfind+0xf>
  80084f:	83 c0 01             	add    $0x1,%eax
  800852:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800855:	38 ca                	cmp    %cl,%dl
  800857:	74 04                	je     80085d <strfind+0x1a>
  800859:	84 d2                	test   %dl,%dl
  80085b:	75 f2                	jne    80084f <strfind+0xc>
			break;
	return (char *) s;
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	57                   	push   %edi
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	8b 7d 08             	mov    0x8(%ebp),%edi
  800868:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086b:	85 c9                	test   %ecx,%ecx
  80086d:	74 36                	je     8008a5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800875:	75 28                	jne    80089f <memset+0x40>
  800877:	f6 c1 03             	test   $0x3,%cl
  80087a:	75 23                	jne    80089f <memset+0x40>
		c &= 0xFF;
  80087c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800880:	89 d3                	mov    %edx,%ebx
  800882:	c1 e3 08             	shl    $0x8,%ebx
  800885:	89 d6                	mov    %edx,%esi
  800887:	c1 e6 18             	shl    $0x18,%esi
  80088a:	89 d0                	mov    %edx,%eax
  80088c:	c1 e0 10             	shl    $0x10,%eax
  80088f:	09 f0                	or     %esi,%eax
  800891:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800893:	89 d8                	mov    %ebx,%eax
  800895:	09 d0                	or     %edx,%eax
  800897:	c1 e9 02             	shr    $0x2,%ecx
  80089a:	fc                   	cld    
  80089b:	f3 ab                	rep stos %eax,%es:(%edi)
  80089d:	eb 06                	jmp    8008a5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	fc                   	cld    
  8008a3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a5:	89 f8                	mov    %edi,%eax
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5f                   	pop    %edi
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	57                   	push   %edi
  8008b0:	56                   	push   %esi
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ba:	39 c6                	cmp    %eax,%esi
  8008bc:	73 35                	jae    8008f3 <memmove+0x47>
  8008be:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c1:	39 d0                	cmp    %edx,%eax
  8008c3:	73 2e                	jae    8008f3 <memmove+0x47>
		s += n;
		d += n;
  8008c5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c8:	89 d6                	mov    %edx,%esi
  8008ca:	09 fe                	or     %edi,%esi
  8008cc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d2:	75 13                	jne    8008e7 <memmove+0x3b>
  8008d4:	f6 c1 03             	test   $0x3,%cl
  8008d7:	75 0e                	jne    8008e7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d9:	83 ef 04             	sub    $0x4,%edi
  8008dc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008df:	c1 e9 02             	shr    $0x2,%ecx
  8008e2:	fd                   	std    
  8008e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e5:	eb 09                	jmp    8008f0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e7:	83 ef 01             	sub    $0x1,%edi
  8008ea:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ed:	fd                   	std    
  8008ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f0:	fc                   	cld    
  8008f1:	eb 1d                	jmp    800910 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 f2                	mov    %esi,%edx
  8008f5:	09 c2                	or     %eax,%edx
  8008f7:	f6 c2 03             	test   $0x3,%dl
  8008fa:	75 0f                	jne    80090b <memmove+0x5f>
  8008fc:	f6 c1 03             	test   $0x3,%cl
  8008ff:	75 0a                	jne    80090b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800901:	c1 e9 02             	shr    $0x2,%ecx
  800904:	89 c7                	mov    %eax,%edi
  800906:	fc                   	cld    
  800907:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800909:	eb 05                	jmp    800910 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090b:	89 c7                	mov    %eax,%edi
  80090d:	fc                   	cld    
  80090e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800910:	5e                   	pop    %esi
  800911:	5f                   	pop    %edi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800917:	ff 75 10             	pushl  0x10(%ebp)
  80091a:	ff 75 0c             	pushl  0xc(%ebp)
  80091d:	ff 75 08             	pushl  0x8(%ebp)
  800920:	e8 87 ff ff ff       	call   8008ac <memmove>
}
  800925:	c9                   	leave  
  800926:	c3                   	ret    

00800927 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800932:	89 c6                	mov    %eax,%esi
  800934:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800937:	eb 1a                	jmp    800953 <memcmp+0x2c>
		if (*s1 != *s2)
  800939:	0f b6 08             	movzbl (%eax),%ecx
  80093c:	0f b6 1a             	movzbl (%edx),%ebx
  80093f:	38 d9                	cmp    %bl,%cl
  800941:	74 0a                	je     80094d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800943:	0f b6 c1             	movzbl %cl,%eax
  800946:	0f b6 db             	movzbl %bl,%ebx
  800949:	29 d8                	sub    %ebx,%eax
  80094b:	eb 0f                	jmp    80095c <memcmp+0x35>
		s1++, s2++;
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800953:	39 f0                	cmp    %esi,%eax
  800955:	75 e2                	jne    800939 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800967:	89 c1                	mov    %eax,%ecx
  800969:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800970:	eb 0a                	jmp    80097c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800972:	0f b6 10             	movzbl (%eax),%edx
  800975:	39 da                	cmp    %ebx,%edx
  800977:	74 07                	je     800980 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	39 c8                	cmp    %ecx,%eax
  80097e:	72 f2                	jb     800972 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800980:	5b                   	pop    %ebx
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	57                   	push   %edi
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098f:	eb 03                	jmp    800994 <strtol+0x11>
		s++;
  800991:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800994:	0f b6 01             	movzbl (%ecx),%eax
  800997:	3c 20                	cmp    $0x20,%al
  800999:	74 f6                	je     800991 <strtol+0xe>
  80099b:	3c 09                	cmp    $0x9,%al
  80099d:	74 f2                	je     800991 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099f:	3c 2b                	cmp    $0x2b,%al
  8009a1:	75 0a                	jne    8009ad <strtol+0x2a>
		s++;
  8009a3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a6:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ab:	eb 11                	jmp    8009be <strtol+0x3b>
  8009ad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b2:	3c 2d                	cmp    $0x2d,%al
  8009b4:	75 08                	jne    8009be <strtol+0x3b>
		s++, neg = 1;
  8009b6:	83 c1 01             	add    $0x1,%ecx
  8009b9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009be:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c4:	75 15                	jne    8009db <strtol+0x58>
  8009c6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c9:	75 10                	jne    8009db <strtol+0x58>
  8009cb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cf:	75 7c                	jne    800a4d <strtol+0xca>
		s += 2, base = 16;
  8009d1:	83 c1 02             	add    $0x2,%ecx
  8009d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d9:	eb 16                	jmp    8009f1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009db:	85 db                	test   %ebx,%ebx
  8009dd:	75 12                	jne    8009f1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009df:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e7:	75 08                	jne    8009f1 <strtol+0x6e>
		s++, base = 8;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f9:	0f b6 11             	movzbl (%ecx),%edx
  8009fc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 09             	cmp    $0x9,%bl
  800a04:	77 08                	ja     800a0e <strtol+0x8b>
			dig = *s - '0';
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 30             	sub    $0x30,%edx
  800a0c:	eb 22                	jmp    800a30 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	80 fb 19             	cmp    $0x19,%bl
  800a16:	77 08                	ja     800a20 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	83 ea 57             	sub    $0x57,%edx
  800a1e:	eb 10                	jmp    800a30 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a20:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a23:	89 f3                	mov    %esi,%ebx
  800a25:	80 fb 19             	cmp    $0x19,%bl
  800a28:	77 16                	ja     800a40 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2a:	0f be d2             	movsbl %dl,%edx
  800a2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a30:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a33:	7d 0b                	jge    800a40 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a35:	83 c1 01             	add    $0x1,%ecx
  800a38:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3e:	eb b9                	jmp    8009f9 <strtol+0x76>

	if (endptr)
  800a40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a44:	74 0d                	je     800a53 <strtol+0xd0>
		*endptr = (char *) s;
  800a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a49:	89 0e                	mov    %ecx,(%esi)
  800a4b:	eb 06                	jmp    800a53 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4d:	85 db                	test   %ebx,%ebx
  800a4f:	74 98                	je     8009e9 <strtol+0x66>
  800a51:	eb 9e                	jmp    8009f1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a53:	89 c2                	mov    %eax,%edx
  800a55:	f7 da                	neg    %edx
  800a57:	85 ff                	test   %edi,%edi
  800a59:	0f 45 c2             	cmovne %edx,%eax
}
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5f                   	pop    %edi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	89 c6                	mov    %eax,%esi
  800a78:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8f:	89 d1                	mov    %edx,%ecx
  800a91:	89 d3                	mov    %edx,%ebx
  800a93:	89 d7                	mov    %edx,%edi
  800a95:	89 d6                	mov    %edx,%esi
  800a97:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aa7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aac:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab4:	89 cb                	mov    %ecx,%ebx
  800ab6:	89 cf                	mov    %ecx,%edi
  800ab8:	89 ce                	mov    %ecx,%esi
  800aba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800abc:	85 c0                	test   %eax,%eax
  800abe:	7e 17                	jle    800ad7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac0:	83 ec 0c             	sub    $0xc,%esp
  800ac3:	50                   	push   %eax
  800ac4:	6a 03                	push   $0x3
  800ac6:	68 24 12 80 00       	push   $0x801224
  800acb:	6a 23                	push   $0x23
  800acd:	68 41 12 80 00       	push   $0x801241
  800ad2:	e8 f5 01 00 00       	call   800ccc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 02 00 00 00       	mov    $0x2,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_yield>:

void
sys_yield(void)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
  800b09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0e:	89 d1                	mov    %edx,%ecx
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	89 d7                	mov    %edx,%edi
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b26:	be 00 00 00 00       	mov    $0x0,%esi
  800b2b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b39:	89 f7                	mov    %esi,%edi
  800b3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7e 17                	jle    800b58 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 04                	push   $0x4
  800b47:	68 24 12 80 00       	push   $0x801224
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 41 12 80 00       	push   $0x801241
  800b53:	e8 74 01 00 00       	call   800ccc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b69:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	8b 55 08             	mov    0x8(%ebp),%edx
  800b74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 05                	push   $0x5
  800b89:	68 24 12 80 00       	push   $0x801224
  800b8e:	6a 23                	push   $0x23
  800b90:	68 41 12 80 00       	push   $0x801241
  800b95:	e8 32 01 00 00       	call   800ccc <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb0:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbb:	89 df                	mov    %ebx,%edi
  800bbd:	89 de                	mov    %ebx,%esi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 06                	push   $0x6
  800bcb:	68 24 12 80 00       	push   $0x801224
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 41 12 80 00       	push   $0x801241
  800bd7:	e8 f0 00 00 00       	call   800ccc <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	57                   	push   %edi
  800be8:	56                   	push   %esi
  800be9:	53                   	push   %ebx
  800bea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	89 df                	mov    %ebx,%edi
  800bff:	89 de                	mov    %ebx,%esi
  800c01:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c03:	85 c0                	test   %eax,%eax
  800c05:	7e 17                	jle    800c1e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 08                	push   $0x8
  800c0d:	68 24 12 80 00       	push   $0x801224
  800c12:	6a 23                	push   $0x23
  800c14:	68 41 12 80 00       	push   $0x801241
  800c19:	e8 ae 00 00 00       	call   800ccc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c34:	b8 09 00 00 00       	mov    $0x9,%eax
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 df                	mov    %ebx,%edi
  800c41:	89 de                	mov    %ebx,%esi
  800c43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c45:	85 c0                	test   %eax,%eax
  800c47:	7e 17                	jle    800c60 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 09                	push   $0x9
  800c4f:	68 24 12 80 00       	push   $0x801224
  800c54:	6a 23                	push   $0x23
  800c56:	68 41 12 80 00       	push   $0x801241
  800c5b:	e8 6c 00 00 00       	call   800ccc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c6e:	be 00 00 00 00       	mov    $0x0,%esi
  800c73:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c84:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c99:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	89 cb                	mov    %ecx,%ebx
  800ca3:	89 cf                	mov    %ecx,%edi
  800ca5:	89 ce                	mov    %ecx,%esi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 0c                	push   $0xc
  800cb3:	68 24 12 80 00       	push   $0x801224
  800cb8:	6a 23                	push   $0x23
  800cba:	68 41 12 80 00       	push   $0x801241
  800cbf:	e8 08 00 00 00       	call   800ccc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cd1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cd4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cda:	e8 00 fe ff ff       	call   800adf <sys_getenvid>
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	ff 75 08             	pushl  0x8(%ebp)
  800ce8:	56                   	push   %esi
  800ce9:	50                   	push   %eax
  800cea:	68 50 12 80 00       	push   $0x801250
  800cef:	e8 57 f4 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cf4:	83 c4 18             	add    $0x18,%esp
  800cf7:	53                   	push   %ebx
  800cf8:	ff 75 10             	pushl  0x10(%ebp)
  800cfb:	e8 fa f3 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800d00:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  800d07:	e8 3f f4 ff ff       	call   80014b <cprintf>
  800d0c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d0f:	cc                   	int3   
  800d10:	eb fd                	jmp    800d0f <_panic+0x43>
  800d12:	66 90                	xchg   %ax,%ax
  800d14:	66 90                	xchg   %ax,%ax
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
