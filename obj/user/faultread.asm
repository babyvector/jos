
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
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
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 a0 0f 80 00       	push   $0x800fa0
  800044:	e8 f0 00 00 00       	call   800139 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 6f 0a 00 00       	call   800acd <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 eb 09 00 00       	call   800a8c <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 79 09 00 00       	call   800a4f <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 54 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 1e 09 00 00       	call   800a4f <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800163:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800166:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80016e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800171:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800174:	39 d3                	cmp    %edx,%ebx
  800176:	72 05                	jb     80017d <printnum+0x30>
  800178:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017b:	77 45                	ja     8001c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 18             	pushl  0x18(%ebp)
  800183:	8b 45 14             	mov    0x14(%ebp),%eax
  800186:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800189:	53                   	push   %ebx
  80018a:	ff 75 10             	pushl  0x10(%ebp)
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	ff 75 e4             	pushl  -0x1c(%ebp)
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	ff 75 dc             	pushl  -0x24(%ebp)
  800199:	ff 75 d8             	pushl  -0x28(%ebp)
  80019c:	e8 5f 0b 00 00       	call   800d00 <__udivdi3>
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	89 f2                	mov    %esi,%edx
  8001a8:	89 f8                	mov    %edi,%eax
  8001aa:	e8 9e ff ff ff       	call   80014d <printnum>
  8001af:	83 c4 20             	add    $0x20,%esp
  8001b2:	eb 18                	jmp    8001cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	ff d7                	call   *%edi
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	eb 03                	jmp    8001c5 <printnum+0x78>
  8001c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c5:	83 eb 01             	sub    $0x1,%ebx
  8001c8:	85 db                	test   %ebx,%ebx
  8001ca:	7f e8                	jg     8001b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001df:	e8 4c 0c 00 00       	call   800e30 <__umoddi3>
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	0f be 80 c8 0f 80 00 	movsbl 0x800fc8(%eax),%eax
  8001ee:	50                   	push   %eax
  8001ef:	ff d7                	call   *%edi
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    

008001fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001ff:	83 fa 01             	cmp    $0x1,%edx
  800202:	7e 0e                	jle    800212 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800204:	8b 10                	mov    (%eax),%edx
  800206:	8d 4a 08             	lea    0x8(%edx),%ecx
  800209:	89 08                	mov    %ecx,(%eax)
  80020b:	8b 02                	mov    (%edx),%eax
  80020d:	8b 52 04             	mov    0x4(%edx),%edx
  800210:	eb 22                	jmp    800234 <getuint+0x38>
	else if (lflag)
  800212:	85 d2                	test   %edx,%edx
  800214:	74 10                	je     800226 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	ba 00 00 00 00       	mov    $0x0,%edx
  800224:	eb 0e                	jmp    800234 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	eb 12                	jmp    800296 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800284:	85 c0                	test   %eax,%eax
  800286:	0f 84 d3 03 00 00    	je     80065f <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	ff d6                	call   *%esi
  800293:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800296:	83 c7 01             	add    $0x1,%edi
  800299:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029d:	83 f8 25             	cmp    $0x25,%eax
  8002a0:	75 e2                	jne    800284 <vprintfmt+0x14>
  8002a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ad:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c0:	eb 07                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cf:	0f b6 07             	movzbl (%edi),%eax
  8002d2:	0f b6 c8             	movzbl %al,%ecx
  8002d5:	83 e8 23             	sub    $0x23,%eax
  8002d8:	3c 55                	cmp    $0x55,%al
  8002da:	0f 87 64 03 00 00    	ja     800644 <vprintfmt+0x3d4>
  8002e0:	0f b6 c0             	movzbl %al,%eax
  8002e3:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f1:	eb d6                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800308:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80030b:	83 fa 09             	cmp    $0x9,%edx
  80030e:	77 39                	ja     800349 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8d 48 04             	lea    0x4(%eax),%ecx
  80031b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80031e:	8b 00                	mov    (%eax),%eax
  800320:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800326:	eb 27                	jmp    80034f <vprintfmt+0xdf>
  800328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032b:	85 c0                	test   %eax,%eax
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	0f 49 c8             	cmovns %eax,%ecx
  800335:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033b:	eb 8c                	jmp    8002c9 <vprintfmt+0x59>
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800340:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800347:	eb 80                	jmp    8002c9 <vprintfmt+0x59>
  800349:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80034c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80034f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800353:	0f 89 70 ff ff ff    	jns    8002c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800359:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80035c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800366:	e9 5e ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800371:	e9 53 ff ff ff       	jmp    8002c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 50 04             	lea    0x4(%eax),%edx
  80037c:	89 55 14             	mov    %edx,0x14(%ebp)
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	53                   	push   %ebx
  800383:	ff 30                	pushl  (%eax)
  800385:	ff d6                	call   *%esi
			break;
  800387:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80038d:	e9 04 ff ff ff       	jmp    800296 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800392:	8b 45 14             	mov    0x14(%ebp),%eax
  800395:	8d 50 04             	lea    0x4(%eax),%edx
  800398:	89 55 14             	mov    %edx,0x14(%ebp)
  80039b:	8b 00                	mov    (%eax),%eax
  80039d:	99                   	cltd   
  80039e:	31 d0                	xor    %edx,%eax
  8003a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a2:	83 f8 08             	cmp    $0x8,%eax
  8003a5:	7f 0b                	jg     8003b2 <vprintfmt+0x142>
  8003a7:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  8003ae:	85 d2                	test   %edx,%edx
  8003b0:	75 18                	jne    8003ca <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003b2:	50                   	push   %eax
  8003b3:	68 e0 0f 80 00       	push   $0x800fe0
  8003b8:	53                   	push   %ebx
  8003b9:	56                   	push   %esi
  8003ba:	e8 94 fe ff ff       	call   800253 <printfmt>
  8003bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c5:	e9 cc fe ff ff       	jmp    800296 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ca:	52                   	push   %edx
  8003cb:	68 e9 0f 80 00       	push   $0x800fe9
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 7c fe ff ff       	call   800253 <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dd:	e9 b4 fe ff ff       	jmp    800296 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 50 04             	lea    0x4(%eax),%edx
  8003e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ed:	85 ff                	test   %edi,%edi
  8003ef:	b8 d9 0f 80 00       	mov    $0x800fd9,%eax
  8003f4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fb:	0f 8e 94 00 00 00    	jle    800495 <vprintfmt+0x225>
  800401:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800405:	0f 84 98 00 00 00    	je     8004a3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	ff 75 c8             	pushl  -0x38(%ebp)
  800411:	57                   	push   %edi
  800412:	e8 d0 02 00 00       	call   8006e7 <strnlen>
  800417:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041a:	29 c1                	sub    %eax,%ecx
  80041c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80041f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800422:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800429:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80042c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80042e:	eb 0f                	jmp    80043f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	53                   	push   %ebx
  800434:	ff 75 e0             	pushl  -0x20(%ebp)
  800437:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	83 ef 01             	sub    $0x1,%edi
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	85 ff                	test   %edi,%edi
  800441:	7f ed                	jg     800430 <vprintfmt+0x1c0>
  800443:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800446:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800449:	85 c9                	test   %ecx,%ecx
  80044b:	b8 00 00 00 00       	mov    $0x0,%eax
  800450:	0f 49 c1             	cmovns %ecx,%eax
  800453:	29 c1                	sub    %eax,%ecx
  800455:	89 75 08             	mov    %esi,0x8(%ebp)
  800458:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80045b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80045e:	89 cb                	mov    %ecx,%ebx
  800460:	eb 4d                	jmp    8004af <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800462:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800466:	74 1b                	je     800483 <vprintfmt+0x213>
  800468:	0f be c0             	movsbl %al,%eax
  80046b:	83 e8 20             	sub    $0x20,%eax
  80046e:	83 f8 5e             	cmp    $0x5e,%eax
  800471:	76 10                	jbe    800483 <vprintfmt+0x213>
					putch('?', putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 0c             	pushl  0xc(%ebp)
  800479:	6a 3f                	push   $0x3f
  80047b:	ff 55 08             	call   *0x8(%ebp)
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	eb 0d                	jmp    800490 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 0c             	pushl  0xc(%ebp)
  800489:	52                   	push   %edx
  80048a:	ff 55 08             	call   *0x8(%ebp)
  80048d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800490:	83 eb 01             	sub    $0x1,%ebx
  800493:	eb 1a                	jmp    8004af <vprintfmt+0x23f>
  800495:	89 75 08             	mov    %esi,0x8(%ebp)
  800498:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80049b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a1:	eb 0c                	jmp    8004af <vprintfmt+0x23f>
  8004a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a6:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004af:	83 c7 01             	add    $0x1,%edi
  8004b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b6:	0f be d0             	movsbl %al,%edx
  8004b9:	85 d2                	test   %edx,%edx
  8004bb:	74 23                	je     8004e0 <vprintfmt+0x270>
  8004bd:	85 f6                	test   %esi,%esi
  8004bf:	78 a1                	js     800462 <vprintfmt+0x1f2>
  8004c1:	83 ee 01             	sub    $0x1,%esi
  8004c4:	79 9c                	jns    800462 <vprintfmt+0x1f2>
  8004c6:	89 df                	mov    %ebx,%edi
  8004c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ce:	eb 18                	jmp    8004e8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	6a 20                	push   $0x20
  8004d6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d8:	83 ef 01             	sub    $0x1,%edi
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	eb 08                	jmp    8004e8 <vprintfmt+0x278>
  8004e0:	89 df                	mov    %ebx,%edi
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	7f e4                	jg     8004d0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ef:	e9 a2 fd ff ff       	jmp    800296 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f4:	83 fa 01             	cmp    $0x1,%edx
  8004f7:	7e 16                	jle    80050f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 50 08             	lea    0x8(%eax),%edx
  8004ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800502:	8b 50 04             	mov    0x4(%eax),%edx
  800505:	8b 00                	mov    (%eax),%eax
  800507:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80050a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80050d:	eb 32                	jmp    800541 <vprintfmt+0x2d1>
	else if (lflag)
  80050f:	85 d2                	test   %edx,%edx
  800511:	74 18                	je     80052b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 50 04             	lea    0x4(%eax),%edx
  800519:	89 55 14             	mov    %edx,0x14(%ebp)
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800521:	89 c1                	mov    %eax,%ecx
  800523:	c1 f9 1f             	sar    $0x1f,%ecx
  800526:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800529:	eb 16                	jmp    800541 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800539:	89 c1                	mov    %eax,%ecx
  80053b:	c1 f9 1f             	sar    $0x1f,%ecx
  80053e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800541:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800544:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800552:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800556:	0f 89 b0 00 00 00    	jns    80060c <vprintfmt+0x39c>
				putch('-', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	6a 2d                	push   $0x2d
  800562:	ff d6                	call   *%esi
				num = -(long long) num;
  800564:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800567:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80056a:	f7 d8                	neg    %eax
  80056c:	83 d2 00             	adc    $0x0,%edx
  80056f:	f7 da                	neg    %edx
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057f:	e9 88 00 00 00       	jmp    80060c <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	e8 70 fc ff ff       	call   8001fc <getuint>
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800597:	eb 73                	jmp    80060c <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800599:	8d 45 14             	lea    0x14(%ebp),%eax
  80059c:	e8 5b fc ff ff       	call   8001fc <getuint>
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 58                	push   $0x58
  8005ad:	ff d6                	call   *%esi
			putch('X', putdat);
  8005af:	83 c4 08             	add    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 58                	push   $0x58
  8005b5:	ff d6                	call   *%esi
			putch('X', putdat);
  8005b7:	83 c4 08             	add    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 58                	push   $0x58
  8005bd:	ff d6                	call   *%esi
			goto number;
  8005bf:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005c2:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005c7:	eb 43                	jmp    80060c <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 04             	lea    0x4(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e2:	8b 00                	mov    (%eax),%eax
  8005e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ef:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f7:	eb 13                	jmp    80060c <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fc:	e8 fb fb ff ff       	call   8001fc <getuint>
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800613:	52                   	push   %edx
  800614:	ff 75 e0             	pushl  -0x20(%ebp)
  800617:	50                   	push   %eax
  800618:	ff 75 dc             	pushl  -0x24(%ebp)
  80061b:	ff 75 d8             	pushl  -0x28(%ebp)
  80061e:	89 da                	mov    %ebx,%edx
  800620:	89 f0                	mov    %esi,%eax
  800622:	e8 26 fb ff ff       	call   80014d <printnum>
			break;
  800627:	83 c4 20             	add    $0x20,%esp
  80062a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062d:	e9 64 fc ff ff       	jmp    800296 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	51                   	push   %ecx
  800637:	ff d6                	call   *%esi
			break;
  800639:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80063f:	e9 52 fc ff ff       	jmp    800296 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 25                	push   $0x25
  80064a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	eb 03                	jmp    800654 <vprintfmt+0x3e4>
  800651:	83 ef 01             	sub    $0x1,%edi
  800654:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800658:	75 f7                	jne    800651 <vprintfmt+0x3e1>
  80065a:	e9 37 fc ff ff       	jmp    800296 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80065f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800662:	5b                   	pop    %ebx
  800663:	5e                   	pop    %esi
  800664:	5f                   	pop    %edi
  800665:	5d                   	pop    %ebp
  800666:	c3                   	ret    

00800667 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	83 ec 18             	sub    $0x18,%esp
  80066d:	8b 45 08             	mov    0x8(%ebp),%eax
  800670:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800673:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800676:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800684:	85 c0                	test   %eax,%eax
  800686:	74 26                	je     8006ae <vsnprintf+0x47>
  800688:	85 d2                	test   %edx,%edx
  80068a:	7e 22                	jle    8006ae <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068c:	ff 75 14             	pushl  0x14(%ebp)
  80068f:	ff 75 10             	pushl  0x10(%ebp)
  800692:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800695:	50                   	push   %eax
  800696:	68 36 02 80 00       	push   $0x800236
  80069b:	e8 d0 fb ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	eb 05                	jmp    8006b3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    

008006b5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006be:	50                   	push   %eax
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	ff 75 08             	pushl  0x8(%ebp)
  8006c8:	e8 9a ff ff ff       	call   800667 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006da:	eb 03                	jmp    8006df <strlen+0x10>
		n++;
  8006dc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006df:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e3:	75 f7                	jne    8006dc <strlen+0xd>
		n++;
	return n;
}
  8006e5:	5d                   	pop    %ebp
  8006e6:	c3                   	ret    

008006e7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f5:	eb 03                	jmp    8006fa <strnlen+0x13>
		n++;
  8006f7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fa:	39 c2                	cmp    %eax,%edx
  8006fc:	74 08                	je     800706 <strnlen+0x1f>
  8006fe:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800702:	75 f3                	jne    8006f7 <strnlen+0x10>
  800704:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800708:	55                   	push   %ebp
  800709:	89 e5                	mov    %esp,%ebp
  80070b:	53                   	push   %ebx
  80070c:	8b 45 08             	mov    0x8(%ebp),%eax
  80070f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800712:	89 c2                	mov    %eax,%edx
  800714:	83 c2 01             	add    $0x1,%edx
  800717:	83 c1 01             	add    $0x1,%ecx
  80071a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80071e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800721:	84 db                	test   %bl,%bl
  800723:	75 ef                	jne    800714 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800725:	5b                   	pop    %ebx
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072f:	53                   	push   %ebx
  800730:	e8 9a ff ff ff       	call   8006cf <strlen>
  800735:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	01 d8                	add    %ebx,%eax
  80073d:	50                   	push   %eax
  80073e:	e8 c5 ff ff ff       	call   800708 <strcpy>
	return dst;
}
  800743:	89 d8                	mov    %ebx,%eax
  800745:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	56                   	push   %esi
  80074e:	53                   	push   %ebx
  80074f:	8b 75 08             	mov    0x8(%ebp),%esi
  800752:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800755:	89 f3                	mov    %esi,%ebx
  800757:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075a:	89 f2                	mov    %esi,%edx
  80075c:	eb 0f                	jmp    80076d <strncpy+0x23>
		*dst++ = *src;
  80075e:	83 c2 01             	add    $0x1,%edx
  800761:	0f b6 01             	movzbl (%ecx),%eax
  800764:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800767:	80 39 01             	cmpb   $0x1,(%ecx)
  80076a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076d:	39 da                	cmp    %ebx,%edx
  80076f:	75 ed                	jne    80075e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800771:	89 f0                	mov    %esi,%eax
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	56                   	push   %esi
  80077b:	53                   	push   %ebx
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800782:	8b 55 10             	mov    0x10(%ebp),%edx
  800785:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800787:	85 d2                	test   %edx,%edx
  800789:	74 21                	je     8007ac <strlcpy+0x35>
  80078b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80078f:	89 f2                	mov    %esi,%edx
  800791:	eb 09                	jmp    80079c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800793:	83 c2 01             	add    $0x1,%edx
  800796:	83 c1 01             	add    $0x1,%ecx
  800799:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079c:	39 c2                	cmp    %eax,%edx
  80079e:	74 09                	je     8007a9 <strlcpy+0x32>
  8007a0:	0f b6 19             	movzbl (%ecx),%ebx
  8007a3:	84 db                	test   %bl,%bl
  8007a5:	75 ec                	jne    800793 <strlcpy+0x1c>
  8007a7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ac:	29 f0                	sub    %esi,%eax
}
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bb:	eb 06                	jmp    8007c3 <strcmp+0x11>
		p++, q++;
  8007bd:	83 c1 01             	add    $0x1,%ecx
  8007c0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c3:	0f b6 01             	movzbl (%ecx),%eax
  8007c6:	84 c0                	test   %al,%al
  8007c8:	74 04                	je     8007ce <strcmp+0x1c>
  8007ca:	3a 02                	cmp    (%edx),%al
  8007cc:	74 ef                	je     8007bd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007ce:	0f b6 c0             	movzbl %al,%eax
  8007d1:	0f b6 12             	movzbl (%edx),%edx
  8007d4:	29 d0                	sub    %edx,%eax
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e2:	89 c3                	mov    %eax,%ebx
  8007e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e7:	eb 06                	jmp    8007ef <strncmp+0x17>
		n--, p++, q++;
  8007e9:	83 c0 01             	add    $0x1,%eax
  8007ec:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ef:	39 d8                	cmp    %ebx,%eax
  8007f1:	74 15                	je     800808 <strncmp+0x30>
  8007f3:	0f b6 08             	movzbl (%eax),%ecx
  8007f6:	84 c9                	test   %cl,%cl
  8007f8:	74 04                	je     8007fe <strncmp+0x26>
  8007fa:	3a 0a                	cmp    (%edx),%cl
  8007fc:	74 eb                	je     8007e9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fe:	0f b6 00             	movzbl (%eax),%eax
  800801:	0f b6 12             	movzbl (%edx),%edx
  800804:	29 d0                	sub    %edx,%eax
  800806:	eb 05                	jmp    80080d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800808:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081a:	eb 07                	jmp    800823 <strchr+0x13>
		if (*s == c)
  80081c:	38 ca                	cmp    %cl,%dl
  80081e:	74 0f                	je     80082f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800820:	83 c0 01             	add    $0x1,%eax
  800823:	0f b6 10             	movzbl (%eax),%edx
  800826:	84 d2                	test   %dl,%dl
  800828:	75 f2                	jne    80081c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083b:	eb 03                	jmp    800840 <strfind+0xf>
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800843:	38 ca                	cmp    %cl,%dl
  800845:	74 04                	je     80084b <strfind+0x1a>
  800847:	84 d2                	test   %dl,%dl
  800849:	75 f2                	jne    80083d <strfind+0xc>
			break;
	return (char *) s;
}
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	57                   	push   %edi
  800851:	56                   	push   %esi
  800852:	53                   	push   %ebx
  800853:	8b 7d 08             	mov    0x8(%ebp),%edi
  800856:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800859:	85 c9                	test   %ecx,%ecx
  80085b:	74 36                	je     800893 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800863:	75 28                	jne    80088d <memset+0x40>
  800865:	f6 c1 03             	test   $0x3,%cl
  800868:	75 23                	jne    80088d <memset+0x40>
		c &= 0xFF;
  80086a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086e:	89 d3                	mov    %edx,%ebx
  800870:	c1 e3 08             	shl    $0x8,%ebx
  800873:	89 d6                	mov    %edx,%esi
  800875:	c1 e6 18             	shl    $0x18,%esi
  800878:	89 d0                	mov    %edx,%eax
  80087a:	c1 e0 10             	shl    $0x10,%eax
  80087d:	09 f0                	or     %esi,%eax
  80087f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800881:	89 d8                	mov    %ebx,%eax
  800883:	09 d0                	or     %edx,%eax
  800885:	c1 e9 02             	shr    $0x2,%ecx
  800888:	fc                   	cld    
  800889:	f3 ab                	rep stos %eax,%es:(%edi)
  80088b:	eb 06                	jmp    800893 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800890:	fc                   	cld    
  800891:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800893:	89 f8                	mov    %edi,%eax
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5f                   	pop    %edi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a8:	39 c6                	cmp    %eax,%esi
  8008aa:	73 35                	jae    8008e1 <memmove+0x47>
  8008ac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008af:	39 d0                	cmp    %edx,%eax
  8008b1:	73 2e                	jae    8008e1 <memmove+0x47>
		s += n;
		d += n;
  8008b3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b6:	89 d6                	mov    %edx,%esi
  8008b8:	09 fe                	or     %edi,%esi
  8008ba:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c0:	75 13                	jne    8008d5 <memmove+0x3b>
  8008c2:	f6 c1 03             	test   $0x3,%cl
  8008c5:	75 0e                	jne    8008d5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c7:	83 ef 04             	sub    $0x4,%edi
  8008ca:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cd:	c1 e9 02             	shr    $0x2,%ecx
  8008d0:	fd                   	std    
  8008d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d3:	eb 09                	jmp    8008de <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d5:	83 ef 01             	sub    $0x1,%edi
  8008d8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008db:	fd                   	std    
  8008dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008de:	fc                   	cld    
  8008df:	eb 1d                	jmp    8008fe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e1:	89 f2                	mov    %esi,%edx
  8008e3:	09 c2                	or     %eax,%edx
  8008e5:	f6 c2 03             	test   $0x3,%dl
  8008e8:	75 0f                	jne    8008f9 <memmove+0x5f>
  8008ea:	f6 c1 03             	test   $0x3,%cl
  8008ed:	75 0a                	jne    8008f9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ef:	c1 e9 02             	shr    $0x2,%ecx
  8008f2:	89 c7                	mov    %eax,%edi
  8008f4:	fc                   	cld    
  8008f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f7:	eb 05                	jmp    8008fe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f9:	89 c7                	mov    %eax,%edi
  8008fb:	fc                   	cld    
  8008fc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fe:	5e                   	pop    %esi
  8008ff:	5f                   	pop    %edi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800905:	ff 75 10             	pushl  0x10(%ebp)
  800908:	ff 75 0c             	pushl  0xc(%ebp)
  80090b:	ff 75 08             	pushl  0x8(%ebp)
  80090e:	e8 87 ff ff ff       	call   80089a <memmove>
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800920:	89 c6                	mov    %eax,%esi
  800922:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800925:	eb 1a                	jmp    800941 <memcmp+0x2c>
		if (*s1 != *s2)
  800927:	0f b6 08             	movzbl (%eax),%ecx
  80092a:	0f b6 1a             	movzbl (%edx),%ebx
  80092d:	38 d9                	cmp    %bl,%cl
  80092f:	74 0a                	je     80093b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800931:	0f b6 c1             	movzbl %cl,%eax
  800934:	0f b6 db             	movzbl %bl,%ebx
  800937:	29 d8                	sub    %ebx,%eax
  800939:	eb 0f                	jmp    80094a <memcmp+0x35>
		s1++, s2++;
  80093b:	83 c0 01             	add    $0x1,%eax
  80093e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800941:	39 f0                	cmp    %esi,%eax
  800943:	75 e2                	jne    800927 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	53                   	push   %ebx
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800955:	89 c1                	mov    %eax,%ecx
  800957:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80095a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095e:	eb 0a                	jmp    80096a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800960:	0f b6 10             	movzbl (%eax),%edx
  800963:	39 da                	cmp    %ebx,%edx
  800965:	74 07                	je     80096e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800967:	83 c0 01             	add    $0x1,%eax
  80096a:	39 c8                	cmp    %ecx,%eax
  80096c:	72 f2                	jb     800960 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096e:	5b                   	pop    %ebx
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	57                   	push   %edi
  800975:	56                   	push   %esi
  800976:	53                   	push   %ebx
  800977:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097d:	eb 03                	jmp    800982 <strtol+0x11>
		s++;
  80097f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800982:	0f b6 01             	movzbl (%ecx),%eax
  800985:	3c 20                	cmp    $0x20,%al
  800987:	74 f6                	je     80097f <strtol+0xe>
  800989:	3c 09                	cmp    $0x9,%al
  80098b:	74 f2                	je     80097f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098d:	3c 2b                	cmp    $0x2b,%al
  80098f:	75 0a                	jne    80099b <strtol+0x2a>
		s++;
  800991:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800994:	bf 00 00 00 00       	mov    $0x0,%edi
  800999:	eb 11                	jmp    8009ac <strtol+0x3b>
  80099b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a0:	3c 2d                	cmp    $0x2d,%al
  8009a2:	75 08                	jne    8009ac <strtol+0x3b>
		s++, neg = 1;
  8009a4:	83 c1 01             	add    $0x1,%ecx
  8009a7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b2:	75 15                	jne    8009c9 <strtol+0x58>
  8009b4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b7:	75 10                	jne    8009c9 <strtol+0x58>
  8009b9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bd:	75 7c                	jne    800a3b <strtol+0xca>
		s += 2, base = 16;
  8009bf:	83 c1 02             	add    $0x2,%ecx
  8009c2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c7:	eb 16                	jmp    8009df <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c9:	85 db                	test   %ebx,%ebx
  8009cb:	75 12                	jne    8009df <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d5:	75 08                	jne    8009df <strtol+0x6e>
		s++, base = 8;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e7:	0f b6 11             	movzbl (%ecx),%edx
  8009ea:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ed:	89 f3                	mov    %esi,%ebx
  8009ef:	80 fb 09             	cmp    $0x9,%bl
  8009f2:	77 08                	ja     8009fc <strtol+0x8b>
			dig = *s - '0';
  8009f4:	0f be d2             	movsbl %dl,%edx
  8009f7:	83 ea 30             	sub    $0x30,%edx
  8009fa:	eb 22                	jmp    800a1e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fc:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	80 fb 19             	cmp    $0x19,%bl
  800a04:	77 08                	ja     800a0e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a06:	0f be d2             	movsbl %dl,%edx
  800a09:	83 ea 57             	sub    $0x57,%edx
  800a0c:	eb 10                	jmp    800a1e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a11:	89 f3                	mov    %esi,%ebx
  800a13:	80 fb 19             	cmp    $0x19,%bl
  800a16:	77 16                	ja     800a2e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a18:	0f be d2             	movsbl %dl,%edx
  800a1b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a21:	7d 0b                	jge    800a2e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a2a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a2c:	eb b9                	jmp    8009e7 <strtol+0x76>

	if (endptr)
  800a2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a32:	74 0d                	je     800a41 <strtol+0xd0>
		*endptr = (char *) s;
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	89 0e                	mov    %ecx,(%esi)
  800a39:	eb 06                	jmp    800a41 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	74 98                	je     8009d7 <strtol+0x66>
  800a3f:	eb 9e                	jmp    8009df <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a41:	89 c2                	mov    %eax,%edx
  800a43:	f7 da                	neg    %edx
  800a45:	85 ff                	test   %edi,%edi
  800a47:	0f 45 c2             	cmovne %edx,%eax
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	89 c3                	mov    %eax,%ebx
  800a62:	89 c7                	mov    %eax,%edi
  800a64:	89 c6                	mov    %eax,%esi
  800a66:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5f                   	pop    %edi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7d:	89 d1                	mov    %edx,%ecx
  800a7f:	89 d3                	mov    %edx,%ebx
  800a81:	89 d7                	mov    %edx,%edi
  800a83:	89 d6                	mov    %edx,%esi
  800a85:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa2:	89 cb                	mov    %ecx,%ebx
  800aa4:	89 cf                	mov    %ecx,%edi
  800aa6:	89 ce                	mov    %ecx,%esi
  800aa8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aaa:	85 c0                	test   %eax,%eax
  800aac:	7e 17                	jle    800ac5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	50                   	push   %eax
  800ab2:	6a 03                	push   $0x3
  800ab4:	68 04 12 80 00       	push   $0x801204
  800ab9:	6a 23                	push   $0x23
  800abb:	68 21 12 80 00       	push   $0x801221
  800ac0:	e8 f5 01 00 00       	call   800cba <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5f                   	pop    %edi
  800acb:	5d                   	pop    %ebp
  800acc:	c3                   	ret    

00800acd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad8:	b8 02 00 00 00       	mov    $0x2,%eax
  800add:	89 d1                	mov    %edx,%ecx
  800adf:	89 d3                	mov    %edx,%ebx
  800ae1:	89 d7                	mov    %edx,%edi
  800ae3:	89 d6                	mov    %edx,%esi
  800ae5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <sys_yield>:

void
sys_yield(void)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800af2:	ba 00 00 00 00       	mov    $0x0,%edx
  800af7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afc:	89 d1                	mov    %edx,%ecx
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	89 d7                	mov    %edx,%edi
  800b02:	89 d6                	mov    %edx,%esi
  800b04:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b14:	be 00 00 00 00       	mov    $0x0,%esi
  800b19:	b8 04 00 00 00       	mov    $0x4,%eax
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b21:	8b 55 08             	mov    0x8(%ebp),%edx
  800b24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b27:	89 f7                	mov    %esi,%edi
  800b29:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	7e 17                	jle    800b46 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b2f:	83 ec 0c             	sub    $0xc,%esp
  800b32:	50                   	push   %eax
  800b33:	6a 04                	push   $0x4
  800b35:	68 04 12 80 00       	push   $0x801204
  800b3a:	6a 23                	push   $0x23
  800b3c:	68 21 12 80 00       	push   $0x801221
  800b41:	e8 74 01 00 00       	call   800cba <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b57:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b65:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b68:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7e 17                	jle    800b88 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 05                	push   $0x5
  800b77:	68 04 12 80 00       	push   $0x801204
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 21 12 80 00       	push   $0x801221
  800b83:	e8 32 01 00 00       	call   800cba <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba9:	89 df                	mov    %ebx,%edi
  800bab:	89 de                	mov    %ebx,%esi
  800bad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	7e 17                	jle    800bca <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 06                	push   $0x6
  800bb9:	68 04 12 80 00       	push   $0x801204
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 21 12 80 00       	push   $0x801221
  800bc5:	e8 f0 00 00 00       	call   800cba <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bdb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be0:	b8 08 00 00 00       	mov    $0x8,%eax
  800be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	89 df                	mov    %ebx,%edi
  800bed:	89 de                	mov    %ebx,%esi
  800bef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7e 17                	jle    800c0c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf5:	83 ec 0c             	sub    $0xc,%esp
  800bf8:	50                   	push   %eax
  800bf9:	6a 08                	push   $0x8
  800bfb:	68 04 12 80 00       	push   $0x801204
  800c00:	6a 23                	push   $0x23
  800c02:	68 21 12 80 00       	push   $0x801221
  800c07:	e8 ae 00 00 00       	call   800cba <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c22:	b8 09 00 00 00       	mov    $0x9,%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	89 df                	mov    %ebx,%edi
  800c2f:	89 de                	mov    %ebx,%esi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 09                	push   $0x9
  800c3d:	68 04 12 80 00       	push   $0x801204
  800c42:	6a 23                	push   $0x23
  800c44:	68 21 12 80 00       	push   $0x801221
  800c49:	e8 6c 00 00 00       	call   800cba <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c5c:	be 00 00 00 00       	mov    $0x0,%esi
  800c61:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c72:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 17                	jle    800cb2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 0c                	push   $0xc
  800ca1:	68 04 12 80 00       	push   $0x801204
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 21 12 80 00       	push   $0x801221
  800cad:	e8 08 00 00 00       	call   800cba <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cbf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cc2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cc8:	e8 00 fe ff ff       	call   800acd <sys_getenvid>
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	ff 75 0c             	pushl  0xc(%ebp)
  800cd3:	ff 75 08             	pushl  0x8(%ebp)
  800cd6:	56                   	push   %esi
  800cd7:	50                   	push   %eax
  800cd8:	68 30 12 80 00       	push   $0x801230
  800cdd:	e8 57 f4 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ce2:	83 c4 18             	add    $0x18,%esp
  800ce5:	53                   	push   %ebx
  800ce6:	ff 75 10             	pushl  0x10(%ebp)
  800ce9:	e8 fa f3 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800cee:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800cf5:	e8 3f f4 ff ff       	call   800139 <cprintf>
  800cfa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cfd:	cc                   	int3   
  800cfe:	eb fd                	jmp    800cfd <_panic+0x43>

00800d00 <__udivdi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 f6                	test   %esi,%esi
  800d19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d1d:	89 ca                	mov    %ecx,%edx
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	75 3d                	jne    800d60 <__udivdi3+0x60>
  800d23:	39 cf                	cmp    %ecx,%edi
  800d25:	0f 87 c5 00 00 00    	ja     800df0 <__udivdi3+0xf0>
  800d2b:	85 ff                	test   %edi,%edi
  800d2d:	89 fd                	mov    %edi,%ebp
  800d2f:	75 0b                	jne    800d3c <__udivdi3+0x3c>
  800d31:	b8 01 00 00 00       	mov    $0x1,%eax
  800d36:	31 d2                	xor    %edx,%edx
  800d38:	f7 f7                	div    %edi
  800d3a:	89 c5                	mov    %eax,%ebp
  800d3c:	89 c8                	mov    %ecx,%eax
  800d3e:	31 d2                	xor    %edx,%edx
  800d40:	f7 f5                	div    %ebp
  800d42:	89 c1                	mov    %eax,%ecx
  800d44:	89 d8                	mov    %ebx,%eax
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	f7 f5                	div    %ebp
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 d8                	mov    %ebx,%eax
  800d4e:	89 fa                	mov    %edi,%edx
  800d50:	83 c4 1c             	add    $0x1c,%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
  800d58:	90                   	nop
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	39 ce                	cmp    %ecx,%esi
  800d62:	77 74                	ja     800dd8 <__udivdi3+0xd8>
  800d64:	0f bd fe             	bsr    %esi,%edi
  800d67:	83 f7 1f             	xor    $0x1f,%edi
  800d6a:	0f 84 98 00 00 00    	je     800e08 <__udivdi3+0x108>
  800d70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	89 c5                	mov    %eax,%ebp
  800d79:	29 fb                	sub    %edi,%ebx
  800d7b:	d3 e6                	shl    %cl,%esi
  800d7d:	89 d9                	mov    %ebx,%ecx
  800d7f:	d3 ed                	shr    %cl,%ebp
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e0                	shl    %cl,%eax
  800d85:	09 ee                	or     %ebp,%esi
  800d87:	89 d9                	mov    %ebx,%ecx
  800d89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8d:	89 d5                	mov    %edx,%ebp
  800d8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d93:	d3 ed                	shr    %cl,%ebp
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	d3 e2                	shl    %cl,%edx
  800d99:	89 d9                	mov    %ebx,%ecx
  800d9b:	d3 e8                	shr    %cl,%eax
  800d9d:	09 c2                	or     %eax,%edx
  800d9f:	89 d0                	mov    %edx,%eax
  800da1:	89 ea                	mov    %ebp,%edx
  800da3:	f7 f6                	div    %esi
  800da5:	89 d5                	mov    %edx,%ebp
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	f7 64 24 0c          	mull   0xc(%esp)
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	72 10                	jb     800dc1 <__udivdi3+0xc1>
  800db1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e6                	shl    %cl,%esi
  800db9:	39 c6                	cmp    %eax,%esi
  800dbb:	73 07                	jae    800dc4 <__udivdi3+0xc4>
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	75 03                	jne    800dc4 <__udivdi3+0xc4>
  800dc1:	83 eb 01             	sub    $0x1,%ebx
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 d8                	mov    %ebx,%eax
  800dc8:	89 fa                	mov    %edi,%edx
  800dca:	83 c4 1c             	add    $0x1c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
  800dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dd8:	31 ff                	xor    %edi,%edi
  800dda:	31 db                	xor    %ebx,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 d8                	mov    %ebx,%eax
  800df2:	f7 f7                	div    %edi
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 1c             	add    $0x1c,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	39 ce                	cmp    %ecx,%esi
  800e0a:	72 0c                	jb     800e18 <__udivdi3+0x118>
  800e0c:	31 db                	xor    %ebx,%ebx
  800e0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e12:	0f 87 34 ff ff ff    	ja     800d4c <__udivdi3+0x4c>
  800e18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e1d:	e9 2a ff ff ff       	jmp    800d4c <__udivdi3+0x4c>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 d2                	test   %edx,%edx
  800e49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e51:	89 f3                	mov    %esi,%ebx
  800e53:	89 3c 24             	mov    %edi,(%esp)
  800e56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5a:	75 1c                	jne    800e78 <__umoddi3+0x48>
  800e5c:	39 f7                	cmp    %esi,%edi
  800e5e:	76 50                	jbe    800eb0 <__umoddi3+0x80>
  800e60:	89 c8                	mov    %ecx,%eax
  800e62:	89 f2                	mov    %esi,%edx
  800e64:	f7 f7                	div    %edi
  800e66:	89 d0                	mov    %edx,%eax
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	77 52                	ja     800ed0 <__umoddi3+0xa0>
  800e7e:	0f bd ea             	bsr    %edx,%ebp
  800e81:	83 f5 1f             	xor    $0x1f,%ebp
  800e84:	75 5a                	jne    800ee0 <__umoddi3+0xb0>
  800e86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e8a:	0f 82 e0 00 00 00    	jb     800f70 <__umoddi3+0x140>
  800e90:	39 0c 24             	cmp    %ecx,(%esp)
  800e93:	0f 86 d7 00 00 00    	jbe    800f70 <__umoddi3+0x140>
  800e99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	85 ff                	test   %edi,%edi
  800eb2:	89 fd                	mov    %edi,%ebp
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x91>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f7                	div    %edi
  800ebf:	89 c5                	mov    %eax,%ebp
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f5                	div    %ebp
  800ec7:	89 c8                	mov    %ecx,%eax
  800ec9:	f7 f5                	div    %ebp
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	eb 99                	jmp    800e68 <__umoddi3+0x38>
  800ecf:	90                   	nop
  800ed0:	89 c8                	mov    %ecx,%eax
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	83 c4 1c             	add    $0x1c,%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	8b 34 24             	mov    (%esp),%esi
  800ee3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee8:	89 e9                	mov    %ebp,%ecx
  800eea:	29 ef                	sub    %ebp,%edi
  800eec:	d3 e0                	shl    %cl,%eax
  800eee:	89 f9                	mov    %edi,%ecx
  800ef0:	89 f2                	mov    %esi,%edx
  800ef2:	d3 ea                	shr    %cl,%edx
  800ef4:	89 e9                	mov    %ebp,%ecx
  800ef6:	09 c2                	or     %eax,%edx
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	89 14 24             	mov    %edx,(%esp)
  800efd:	89 f2                	mov    %esi,%edx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	89 e9                	mov    %ebp,%ecx
  800f0f:	89 c6                	mov    %eax,%esi
  800f11:	d3 e3                	shl    %cl,%ebx
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	89 d0                	mov    %edx,%eax
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	89 e9                	mov    %ebp,%ecx
  800f1b:	09 d8                	or     %ebx,%eax
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	89 f2                	mov    %esi,%edx
  800f21:	f7 34 24             	divl   (%esp)
  800f24:	89 d6                	mov    %edx,%esi
  800f26:	d3 e3                	shl    %cl,%ebx
  800f28:	f7 64 24 04          	mull   0x4(%esp)
  800f2c:	39 d6                	cmp    %edx,%esi
  800f2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f32:	89 d1                	mov    %edx,%ecx
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	72 08                	jb     800f40 <__umoddi3+0x110>
  800f38:	75 11                	jne    800f4b <__umoddi3+0x11b>
  800f3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f3e:	73 0b                	jae    800f4b <__umoddi3+0x11b>
  800f40:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f44:	1b 14 24             	sbb    (%esp),%edx
  800f47:	89 d1                	mov    %edx,%ecx
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f4f:	29 da                	sub    %ebx,%edx
  800f51:	19 ce                	sbb    %ecx,%esi
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 f0                	mov    %esi,%eax
  800f57:	d3 e0                	shl    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	d3 ea                	shr    %cl,%edx
  800f5d:	89 e9                	mov    %ebp,%ecx
  800f5f:	d3 ee                	shr    %cl,%esi
  800f61:	09 d0                	or     %edx,%eax
  800f63:	89 f2                	mov    %esi,%edx
  800f65:	83 c4 1c             	add    $0x1c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	29 f9                	sub    %edi,%ecx
  800f72:	19 d6                	sbb    %edx,%esi
  800f74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7c:	e9 18 ff ff ff       	jmp    800e99 <__umoddi3+0x69>
