
obj/user/faultreadkernel.debug:     file format elf32-i386


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
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 e0 1d 80 00       	push   $0x801de0
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
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
  800059:	e8 77 0a 00 00       	call   800ad5 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 30 0e 00 00       	call   800ecf <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 eb 09 00 00       	call   800a94 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 79 09 00 00       	call   800a57 <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 54 01 00 00       	call   800278 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 1e 09 00 00       	call   800a57 <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 a7 19 00 00       	call   801b50 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 94 1a 00 00       	call   801c80 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 11 1e 80 00 	movsbl 0x801e11(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800207:	83 fa 01             	cmp    $0x1,%edx
  80020a:	7e 0e                	jle    80021a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020c:	8b 10                	mov    (%eax),%edx
  80020e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800211:	89 08                	mov    %ecx,(%eax)
  800213:	8b 02                	mov    (%edx),%eax
  800215:	8b 52 04             	mov    0x4(%edx),%edx
  800218:	eb 22                	jmp    80023c <getuint+0x38>
	else if (lflag)
  80021a:	85 d2                	test   %edx,%edx
  80021c:	74 10                	je     80022e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 04             	lea    0x4(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	ba 00 00 00 00       	mov    $0x0,%edx
  80022c:	eb 0e                	jmp    80023c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800244:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	3b 50 04             	cmp    0x4(%eax),%edx
  80024d:	73 0a                	jae    800259 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800252:	89 08                	mov    %ecx,(%eax)
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	88 02                	mov    %al,(%edx)
}
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800261:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800264:	50                   	push   %eax
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	e8 05 00 00 00       	call   800278 <vprintfmt>
	va_end(ap);
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	c9                   	leave  
  800277:	c3                   	ret    

00800278 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 2c             	sub    $0x2c,%esp
  800281:	8b 75 08             	mov    0x8(%ebp),%esi
  800284:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800287:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028a:	eb 12                	jmp    80029e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028c:	85 c0                	test   %eax,%eax
  80028e:	0f 84 d3 03 00 00    	je     800667 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	53                   	push   %ebx
  800298:	50                   	push   %eax
  800299:	ff d6                	call   *%esi
  80029b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80029e:	83 c7 01             	add    $0x1,%edi
  8002a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a5:	83 f8 25             	cmp    $0x25,%eax
  8002a8:	75 e2                	jne    80028c <vprintfmt+0x14>
  8002aa:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002ae:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002bc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c8:	eb 07                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002cd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8d 47 01             	lea    0x1(%edi),%eax
  8002d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d7:	0f b6 07             	movzbl (%edi),%eax
  8002da:	0f b6 c8             	movzbl %al,%ecx
  8002dd:	83 e8 23             	sub    $0x23,%eax
  8002e0:	3c 55                	cmp    $0x55,%al
  8002e2:	0f 87 64 03 00 00    	ja     80064c <vprintfmt+0x3d4>
  8002e8:	0f b6 c0             	movzbl %al,%eax
  8002eb:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
  8002f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f9:	eb d6                	jmp    8002d1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800303:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800306:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800309:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80030d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800310:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800313:	83 fa 09             	cmp    $0x9,%edx
  800316:	77 39                	ja     800351 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800318:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031b:	eb e9                	jmp    800306 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 48 04             	lea    0x4(%eax),%ecx
  800323:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800326:	8b 00                	mov    (%eax),%eax
  800328:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80032e:	eb 27                	jmp    800357 <vprintfmt+0xdf>
  800330:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800333:	85 c0                	test   %eax,%eax
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	0f 49 c8             	cmovns %eax,%ecx
  80033d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800343:	eb 8c                	jmp    8002d1 <vprintfmt+0x59>
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800348:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034f:	eb 80                	jmp    8002d1 <vprintfmt+0x59>
  800351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800354:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800357:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035b:	0f 89 70 ff ff ff    	jns    8002d1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800361:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800364:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800367:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80036e:	e9 5e ff ff ff       	jmp    8002d1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800373:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800379:	e9 53 ff ff ff       	jmp    8002d1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 50 04             	lea    0x4(%eax),%edx
  800384:	89 55 14             	mov    %edx,0x14(%ebp)
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	ff 30                	pushl  (%eax)
  80038d:	ff d6                	call   *%esi
			break;
  80038f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800395:	e9 04 ff ff ff       	jmp    80029e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 50 04             	lea    0x4(%eax),%edx
  8003a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a3:	8b 00                	mov    (%eax),%eax
  8003a5:	99                   	cltd   
  8003a6:	31 d0                	xor    %edx,%eax
  8003a8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003aa:	83 f8 0f             	cmp    $0xf,%eax
  8003ad:	7f 0b                	jg     8003ba <vprintfmt+0x142>
  8003af:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  8003b6:	85 d2                	test   %edx,%edx
  8003b8:	75 18                	jne    8003d2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ba:	50                   	push   %eax
  8003bb:	68 29 1e 80 00       	push   $0x801e29
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	e8 94 fe ff ff       	call   80025b <printfmt>
  8003c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cd:	e9 cc fe ff ff       	jmp    80029e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d2:	52                   	push   %edx
  8003d3:	68 f1 21 80 00       	push   $0x8021f1
  8003d8:	53                   	push   %ebx
  8003d9:	56                   	push   %esi
  8003da:	e8 7c fe ff ff       	call   80025b <printfmt>
  8003df:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e5:	e9 b4 fe ff ff       	jmp    80029e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ed:	8d 50 04             	lea    0x4(%eax),%edx
  8003f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f5:	85 ff                	test   %edi,%edi
  8003f7:	b8 22 1e 80 00       	mov    $0x801e22,%eax
  8003fc:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	0f 8e 94 00 00 00    	jle    80049d <vprintfmt+0x225>
  800409:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040d:	0f 84 98 00 00 00    	je     8004ab <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	ff 75 c8             	pushl  -0x38(%ebp)
  800419:	57                   	push   %edi
  80041a:	e8 d0 02 00 00       	call   8006ef <strnlen>
  80041f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800422:	29 c1                	sub    %eax,%ecx
  800424:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800427:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800431:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800434:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800436:	eb 0f                	jmp    800447 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 75 e0             	pushl  -0x20(%ebp)
  80043f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	83 ef 01             	sub    $0x1,%edi
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 ff                	test   %edi,%edi
  800449:	7f ed                	jg     800438 <vprintfmt+0x1c0>
  80044b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800451:	85 c9                	test   %ecx,%ecx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c1             	cmovns %ecx,%eax
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 75 08             	mov    %esi,0x8(%ebp)
  800460:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800463:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800466:	89 cb                	mov    %ecx,%ebx
  800468:	eb 4d                	jmp    8004b7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046e:	74 1b                	je     80048b <vprintfmt+0x213>
  800470:	0f be c0             	movsbl %al,%eax
  800473:	83 e8 20             	sub    $0x20,%eax
  800476:	83 f8 5e             	cmp    $0x5e,%eax
  800479:	76 10                	jbe    80048b <vprintfmt+0x213>
					putch('?', putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 0c             	pushl  0xc(%ebp)
  800481:	6a 3f                	push   $0x3f
  800483:	ff 55 08             	call   *0x8(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	eb 0d                	jmp    800498 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	52                   	push   %edx
  800492:	ff 55 08             	call   *0x8(%ebp)
  800495:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	eb 1a                	jmp    8004b7 <vprintfmt+0x23f>
  80049d:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a9:	eb 0c                	jmp    8004b7 <vprintfmt+0x23f>
  8004ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ae:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b7:	83 c7 01             	add    $0x1,%edi
  8004ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004be:	0f be d0             	movsbl %al,%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 23                	je     8004e8 <vprintfmt+0x270>
  8004c5:	85 f6                	test   %esi,%esi
  8004c7:	78 a1                	js     80046a <vprintfmt+0x1f2>
  8004c9:	83 ee 01             	sub    $0x1,%esi
  8004cc:	79 9c                	jns    80046a <vprintfmt+0x1f2>
  8004ce:	89 df                	mov    %ebx,%edi
  8004d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d6:	eb 18                	jmp    8004f0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	6a 20                	push   $0x20
  8004de:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e0:	83 ef 01             	sub    $0x1,%edi
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb 08                	jmp    8004f0 <vprintfmt+0x278>
  8004e8:	89 df                	mov    %ebx,%edi
  8004ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f e4                	jg     8004d8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f7:	e9 a2 fd ff ff       	jmp    80029e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fc:	83 fa 01             	cmp    $0x1,%edx
  8004ff:	7e 16                	jle    800517 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 08             	lea    0x8(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	8b 50 04             	mov    0x4(%eax),%edx
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800512:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800515:	eb 32                	jmp    800549 <vprintfmt+0x2d1>
	else if (lflag)
  800517:	85 d2                	test   %edx,%edx
  800519:	74 18                	je     800533 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800531:	eb 16                	jmp    800549 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 50 04             	lea    0x4(%eax),%edx
  800539:	89 55 14             	mov    %edx,0x14(%ebp)
  80053c:	8b 00                	mov    (%eax),%eax
  80053e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800541:	89 c1                	mov    %eax,%ecx
  800543:	c1 f9 1f             	sar    $0x1f,%ecx
  800546:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800549:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80054f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800552:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80055e:	0f 89 b0 00 00 00    	jns    800614 <vprintfmt+0x39c>
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 2d                	push   $0x2d
  80056a:	ff d6                	call   *%esi
				num = -(long long) num;
  80056c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800572:	f7 d8                	neg    %eax
  800574:	83 d2 00             	adc    $0x0,%edx
  800577:	f7 da                	neg    %edx
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800582:	b8 0a 00 00 00       	mov    $0xa,%eax
  800587:	e9 88 00 00 00       	jmp    800614 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058c:	8d 45 14             	lea    0x14(%ebp),%eax
  80058f:	e8 70 fc ff ff       	call   800204 <getuint>
  800594:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800597:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80059f:	eb 73                	jmp    800614 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a4:	e8 5b fc ff ff       	call   800204 <getuint>
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 58                	push   $0x58
  8005b5:	ff d6                	call   *%esi
			putch('X', putdat);
  8005b7:	83 c4 08             	add    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 58                	push   $0x58
  8005bd:	ff d6                	call   *%esi
			putch('X', putdat);
  8005bf:	83 c4 08             	add    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	6a 58                	push   $0x58
  8005c5:	ff d6                	call   *%esi
			goto number;
  8005c7:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005ca:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005cf:	eb 43                	jmp    800614 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 30                	push   $0x30
  8005d7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d9:	83 c4 08             	add    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 78                	push   $0x78
  8005df:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 04             	lea    0x4(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005fa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005ff:	eb 13                	jmp    800614 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800601:	8d 45 14             	lea    0x14(%ebp),%eax
  800604:	e8 fb fb ff ff       	call   800204 <getuint>
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80060f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80061b:	52                   	push   %edx
  80061c:	ff 75 e0             	pushl  -0x20(%ebp)
  80061f:	50                   	push   %eax
  800620:	ff 75 dc             	pushl  -0x24(%ebp)
  800623:	ff 75 d8             	pushl  -0x28(%ebp)
  800626:	89 da                	mov    %ebx,%edx
  800628:	89 f0                	mov    %esi,%eax
  80062a:	e8 26 fb ff ff       	call   800155 <printnum>
			break;
  80062f:	83 c4 20             	add    $0x20,%esp
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800635:	e9 64 fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	51                   	push   %ecx
  80063f:	ff d6                	call   *%esi
			break;
  800641:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800647:	e9 52 fc ff ff       	jmp    80029e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 25                	push   $0x25
  800652:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 03                	jmp    80065c <vprintfmt+0x3e4>
  800659:	83 ef 01             	sub    $0x1,%edi
  80065c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800660:	75 f7                	jne    800659 <vprintfmt+0x3e1>
  800662:	e9 37 fc ff ff       	jmp    80029e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	83 ec 18             	sub    $0x18,%esp
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800682:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068c:	85 c0                	test   %eax,%eax
  80068e:	74 26                	je     8006b6 <vsnprintf+0x47>
  800690:	85 d2                	test   %edx,%edx
  800692:	7e 22                	jle    8006b6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800694:	ff 75 14             	pushl  0x14(%ebp)
  800697:	ff 75 10             	pushl  0x10(%ebp)
  80069a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069d:	50                   	push   %eax
  80069e:	68 3e 02 80 00       	push   $0x80023e
  8006a3:	e8 d0 fb ff ff       	call   800278 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 05                	jmp    8006bb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c6:	50                   	push   %eax
  8006c7:	ff 75 10             	pushl  0x10(%ebp)
  8006ca:	ff 75 0c             	pushl  0xc(%ebp)
  8006cd:	ff 75 08             	pushl  0x8(%ebp)
  8006d0:	e8 9a ff ff ff       	call   80066f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e2:	eb 03                	jmp    8006e7 <strlen+0x10>
		n++;
  8006e4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006eb:	75 f7                	jne    8006e4 <strlen+0xd>
		n++;
	return n;
}
  8006ed:	5d                   	pop    %ebp
  8006ee:	c3                   	ret    

008006ef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fd:	eb 03                	jmp    800702 <strnlen+0x13>
		n++;
  8006ff:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800702:	39 c2                	cmp    %eax,%edx
  800704:	74 08                	je     80070e <strnlen+0x1f>
  800706:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070a:	75 f3                	jne    8006ff <strnlen+0x10>
  80070c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071a:	89 c2                	mov    %eax,%edx
  80071c:	83 c2 01             	add    $0x1,%edx
  80071f:	83 c1 01             	add    $0x1,%ecx
  800722:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800726:	88 5a ff             	mov    %bl,-0x1(%edx)
  800729:	84 db                	test   %bl,%bl
  80072b:	75 ef                	jne    80071c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072d:	5b                   	pop    %ebx
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	53                   	push   %ebx
  800734:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800737:	53                   	push   %ebx
  800738:	e8 9a ff ff ff       	call   8006d7 <strlen>
  80073d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800740:	ff 75 0c             	pushl  0xc(%ebp)
  800743:	01 d8                	add    %ebx,%eax
  800745:	50                   	push   %eax
  800746:	e8 c5 ff ff ff       	call   800710 <strcpy>
	return dst;
}
  80074b:	89 d8                	mov    %ebx,%eax
  80074d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800750:	c9                   	leave  
  800751:	c3                   	ret    

00800752 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	56                   	push   %esi
  800756:	53                   	push   %ebx
  800757:	8b 75 08             	mov    0x8(%ebp),%esi
  80075a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075d:	89 f3                	mov    %esi,%ebx
  80075f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800762:	89 f2                	mov    %esi,%edx
  800764:	eb 0f                	jmp    800775 <strncpy+0x23>
		*dst++ = *src;
  800766:	83 c2 01             	add    $0x1,%edx
  800769:	0f b6 01             	movzbl (%ecx),%eax
  80076c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076f:	80 39 01             	cmpb   $0x1,(%ecx)
  800772:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800775:	39 da                	cmp    %ebx,%edx
  800777:	75 ed                	jne    800766 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800779:	89 f0                	mov    %esi,%eax
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5d                   	pop    %ebp
  80077e:	c3                   	ret    

0080077f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	56                   	push   %esi
  800783:	53                   	push   %ebx
  800784:	8b 75 08             	mov    0x8(%ebp),%esi
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078a:	8b 55 10             	mov    0x10(%ebp),%edx
  80078d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078f:	85 d2                	test   %edx,%edx
  800791:	74 21                	je     8007b4 <strlcpy+0x35>
  800793:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800797:	89 f2                	mov    %esi,%edx
  800799:	eb 09                	jmp    8007a4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	83 c1 01             	add    $0x1,%ecx
  8007a1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a4:	39 c2                	cmp    %eax,%edx
  8007a6:	74 09                	je     8007b1 <strlcpy+0x32>
  8007a8:	0f b6 19             	movzbl (%ecx),%ebx
  8007ab:	84 db                	test   %bl,%bl
  8007ad:	75 ec                	jne    80079b <strlcpy+0x1c>
  8007af:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b4:	29 f0                	sub    %esi,%eax
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5e                   	pop    %esi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c3:	eb 06                	jmp    8007cb <strcmp+0x11>
		p++, q++;
  8007c5:	83 c1 01             	add    $0x1,%ecx
  8007c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cb:	0f b6 01             	movzbl (%ecx),%eax
  8007ce:	84 c0                	test   %al,%al
  8007d0:	74 04                	je     8007d6 <strcmp+0x1c>
  8007d2:	3a 02                	cmp    (%edx),%al
  8007d4:	74 ef                	je     8007c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d6:	0f b6 c0             	movzbl %al,%eax
  8007d9:	0f b6 12             	movzbl (%edx),%edx
  8007dc:	29 d0                	sub    %edx,%eax
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ea:	89 c3                	mov    %eax,%ebx
  8007ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007ef:	eb 06                	jmp    8007f7 <strncmp+0x17>
		n--, p++, q++;
  8007f1:	83 c0 01             	add    $0x1,%eax
  8007f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f7:	39 d8                	cmp    %ebx,%eax
  8007f9:	74 15                	je     800810 <strncmp+0x30>
  8007fb:	0f b6 08             	movzbl (%eax),%ecx
  8007fe:	84 c9                	test   %cl,%cl
  800800:	74 04                	je     800806 <strncmp+0x26>
  800802:	3a 0a                	cmp    (%edx),%cl
  800804:	74 eb                	je     8007f1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800806:	0f b6 00             	movzbl (%eax),%eax
  800809:	0f b6 12             	movzbl (%edx),%edx
  80080c:	29 d0                	sub    %edx,%eax
  80080e:	eb 05                	jmp    800815 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800810:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800822:	eb 07                	jmp    80082b <strchr+0x13>
		if (*s == c)
  800824:	38 ca                	cmp    %cl,%dl
  800826:	74 0f                	je     800837 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800828:	83 c0 01             	add    $0x1,%eax
  80082b:	0f b6 10             	movzbl (%eax),%edx
  80082e:	84 d2                	test   %dl,%dl
  800830:	75 f2                	jne    800824 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800832:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800843:	eb 03                	jmp    800848 <strfind+0xf>
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084b:	38 ca                	cmp    %cl,%dl
  80084d:	74 04                	je     800853 <strfind+0x1a>
  80084f:	84 d2                	test   %dl,%dl
  800851:	75 f2                	jne    800845 <strfind+0xc>
			break;
	return (char *) s;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	57                   	push   %edi
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800861:	85 c9                	test   %ecx,%ecx
  800863:	74 36                	je     80089b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800865:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086b:	75 28                	jne    800895 <memset+0x40>
  80086d:	f6 c1 03             	test   $0x3,%cl
  800870:	75 23                	jne    800895 <memset+0x40>
		c &= 0xFF;
  800872:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800876:	89 d3                	mov    %edx,%ebx
  800878:	c1 e3 08             	shl    $0x8,%ebx
  80087b:	89 d6                	mov    %edx,%esi
  80087d:	c1 e6 18             	shl    $0x18,%esi
  800880:	89 d0                	mov    %edx,%eax
  800882:	c1 e0 10             	shl    $0x10,%eax
  800885:	09 f0                	or     %esi,%eax
  800887:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800889:	89 d8                	mov    %ebx,%eax
  80088b:	09 d0                	or     %edx,%eax
  80088d:	c1 e9 02             	shr    $0x2,%ecx
  800890:	fc                   	cld    
  800891:	f3 ab                	rep stos %eax,%es:(%edi)
  800893:	eb 06                	jmp    80089b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800895:	8b 45 0c             	mov    0xc(%ebp),%eax
  800898:	fc                   	cld    
  800899:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089b:	89 f8                	mov    %edi,%eax
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	5f                   	pop    %edi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b0:	39 c6                	cmp    %eax,%esi
  8008b2:	73 35                	jae    8008e9 <memmove+0x47>
  8008b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b7:	39 d0                	cmp    %edx,%eax
  8008b9:	73 2e                	jae    8008e9 <memmove+0x47>
		s += n;
		d += n;
  8008bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008be:	89 d6                	mov    %edx,%esi
  8008c0:	09 fe                	or     %edi,%esi
  8008c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c8:	75 13                	jne    8008dd <memmove+0x3b>
  8008ca:	f6 c1 03             	test   $0x3,%cl
  8008cd:	75 0e                	jne    8008dd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008cf:	83 ef 04             	sub    $0x4,%edi
  8008d2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d5:	c1 e9 02             	shr    $0x2,%ecx
  8008d8:	fd                   	std    
  8008d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008db:	eb 09                	jmp    8008e6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008dd:	83 ef 01             	sub    $0x1,%edi
  8008e0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e3:	fd                   	std    
  8008e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e6:	fc                   	cld    
  8008e7:	eb 1d                	jmp    800906 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e9:	89 f2                	mov    %esi,%edx
  8008eb:	09 c2                	or     %eax,%edx
  8008ed:	f6 c2 03             	test   $0x3,%dl
  8008f0:	75 0f                	jne    800901 <memmove+0x5f>
  8008f2:	f6 c1 03             	test   $0x3,%cl
  8008f5:	75 0a                	jne    800901 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f7:	c1 e9 02             	shr    $0x2,%ecx
  8008fa:	89 c7                	mov    %eax,%edi
  8008fc:	fc                   	cld    
  8008fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ff:	eb 05                	jmp    800906 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800901:	89 c7                	mov    %eax,%edi
  800903:	fc                   	cld    
  800904:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800906:	5e                   	pop    %esi
  800907:	5f                   	pop    %edi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090d:	ff 75 10             	pushl  0x10(%ebp)
  800910:	ff 75 0c             	pushl  0xc(%ebp)
  800913:	ff 75 08             	pushl  0x8(%ebp)
  800916:	e8 87 ff ff ff       	call   8008a2 <memmove>
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
  800928:	89 c6                	mov    %eax,%esi
  80092a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092d:	eb 1a                	jmp    800949 <memcmp+0x2c>
		if (*s1 != *s2)
  80092f:	0f b6 08             	movzbl (%eax),%ecx
  800932:	0f b6 1a             	movzbl (%edx),%ebx
  800935:	38 d9                	cmp    %bl,%cl
  800937:	74 0a                	je     800943 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800939:	0f b6 c1             	movzbl %cl,%eax
  80093c:	0f b6 db             	movzbl %bl,%ebx
  80093f:	29 d8                	sub    %ebx,%eax
  800941:	eb 0f                	jmp    800952 <memcmp+0x35>
		s1++, s2++;
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800949:	39 f0                	cmp    %esi,%eax
  80094b:	75 e2                	jne    80092f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	53                   	push   %ebx
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095d:	89 c1                	mov    %eax,%ecx
  80095f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800962:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800966:	eb 0a                	jmp    800972 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800968:	0f b6 10             	movzbl (%eax),%edx
  80096b:	39 da                	cmp    %ebx,%edx
  80096d:	74 07                	je     800976 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096f:	83 c0 01             	add    $0x1,%eax
  800972:	39 c8                	cmp    %ecx,%eax
  800974:	72 f2                	jb     800968 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800976:	5b                   	pop    %ebx
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800985:	eb 03                	jmp    80098a <strtol+0x11>
		s++;
  800987:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098a:	0f b6 01             	movzbl (%ecx),%eax
  80098d:	3c 20                	cmp    $0x20,%al
  80098f:	74 f6                	je     800987 <strtol+0xe>
  800991:	3c 09                	cmp    $0x9,%al
  800993:	74 f2                	je     800987 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800995:	3c 2b                	cmp    $0x2b,%al
  800997:	75 0a                	jne    8009a3 <strtol+0x2a>
		s++;
  800999:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099c:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a1:	eb 11                	jmp    8009b4 <strtol+0x3b>
  8009a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a8:	3c 2d                	cmp    $0x2d,%al
  8009aa:	75 08                	jne    8009b4 <strtol+0x3b>
		s++, neg = 1;
  8009ac:	83 c1 01             	add    $0x1,%ecx
  8009af:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ba:	75 15                	jne    8009d1 <strtol+0x58>
  8009bc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009bf:	75 10                	jne    8009d1 <strtol+0x58>
  8009c1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c5:	75 7c                	jne    800a43 <strtol+0xca>
		s += 2, base = 16;
  8009c7:	83 c1 02             	add    $0x2,%ecx
  8009ca:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009cf:	eb 16                	jmp    8009e7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d1:	85 db                	test   %ebx,%ebx
  8009d3:	75 12                	jne    8009e7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009da:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dd:	75 08                	jne    8009e7 <strtol+0x6e>
		s++, base = 8;
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ef:	0f b6 11             	movzbl (%ecx),%edx
  8009f2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f5:	89 f3                	mov    %esi,%ebx
  8009f7:	80 fb 09             	cmp    $0x9,%bl
  8009fa:	77 08                	ja     800a04 <strtol+0x8b>
			dig = *s - '0';
  8009fc:	0f be d2             	movsbl %dl,%edx
  8009ff:	83 ea 30             	sub    $0x30,%edx
  800a02:	eb 22                	jmp    800a26 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a04:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a07:	89 f3                	mov    %esi,%ebx
  800a09:	80 fb 19             	cmp    $0x19,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a0e:	0f be d2             	movsbl %dl,%edx
  800a11:	83 ea 57             	sub    $0x57,%edx
  800a14:	eb 10                	jmp    800a26 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a16:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a19:	89 f3                	mov    %esi,%ebx
  800a1b:	80 fb 19             	cmp    $0x19,%bl
  800a1e:	77 16                	ja     800a36 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a20:	0f be d2             	movsbl %dl,%edx
  800a23:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a26:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a29:	7d 0b                	jge    800a36 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a32:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a34:	eb b9                	jmp    8009ef <strtol+0x76>

	if (endptr)
  800a36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3a:	74 0d                	je     800a49 <strtol+0xd0>
		*endptr = (char *) s;
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	89 0e                	mov    %ecx,(%esi)
  800a41:	eb 06                	jmp    800a49 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a43:	85 db                	test   %ebx,%ebx
  800a45:	74 98                	je     8009df <strtol+0x66>
  800a47:	eb 9e                	jmp    8009e7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a49:	89 c2                	mov    %eax,%edx
  800a4b:	f7 da                	neg    %edx
  800a4d:	85 ff                	test   %edi,%edi
  800a4f:	0f 45 c2             	cmovne %edx,%eax
}
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a5d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a65:	8b 55 08             	mov    0x8(%ebp),%edx
  800a68:	89 c3                	mov    %eax,%ebx
  800a6a:	89 c7                	mov    %eax,%edi
  800a6c:	89 c6                	mov    %eax,%esi
  800a6e:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a80:	b8 01 00 00 00       	mov    $0x1,%eax
  800a85:	89 d1                	mov    %edx,%ecx
  800a87:	89 d3                	mov    %edx,%ebx
  800a89:	89 d7                	mov    %edx,%edi
  800a8b:	89 d6                	mov    %edx,%esi
  800a8d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5f                   	pop    %edi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa2:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaa:	89 cb                	mov    %ecx,%ebx
  800aac:	89 cf                	mov    %ecx,%edi
  800aae:	89 ce                	mov    %ecx,%esi
  800ab0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	7e 17                	jle    800acd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab6:	83 ec 0c             	sub    $0xc,%esp
  800ab9:	50                   	push   %eax
  800aba:	6a 03                	push   $0x3
  800abc:	68 1f 21 80 00       	push   $0x80211f
  800ac1:	6a 23                	push   $0x23
  800ac3:	68 3c 21 80 00       	push   $0x80213c
  800ac8:	e8 1a 0f 00 00       	call   8019e7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800acd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5f                   	pop    %edi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	57                   	push   %edi
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800adb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae5:	89 d1                	mov    %edx,%ecx
  800ae7:	89 d3                	mov    %edx,%ebx
  800ae9:	89 d7                	mov    %edx,%edi
  800aeb:	89 d6                	mov    %edx,%esi
  800aed:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <sys_yield>:

void
sys_yield(void)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b04:	89 d1                	mov    %edx,%ecx
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	89 d7                	mov    %edx,%edi
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
  800b19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b1c:	be 00 00 00 00       	mov    $0x0,%esi
  800b21:	b8 04 00 00 00       	mov    $0x4,%eax
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2f:	89 f7                	mov    %esi,%edi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 17                	jle    800b4e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 04                	push   $0x4
  800b3d:	68 1f 21 80 00       	push   $0x80211f
  800b42:	6a 23                	push   $0x23
  800b44:	68 3c 21 80 00       	push   $0x80213c
  800b49:	e8 99 0e 00 00       	call   8019e7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b67:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b70:	8b 75 18             	mov    0x18(%ebp),%esi
  800b73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 17                	jle    800b90 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 05                	push   $0x5
  800b7f:	68 1f 21 80 00       	push   $0x80211f
  800b84:	6a 23                	push   $0x23
  800b86:	68 3c 21 80 00       	push   $0x80213c
  800b8b:	e8 57 0e 00 00       	call   8019e7 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 df                	mov    %ebx,%edi
  800bb3:	89 de                	mov    %ebx,%esi
  800bb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 06                	push   $0x6
  800bc1:	68 1f 21 80 00       	push   $0x80211f
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 3c 21 80 00       	push   $0x80213c
  800bcd:	e8 15 0e 00 00       	call   8019e7 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800be3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 df                	mov    %ebx,%edi
  800bf5:	89 de                	mov    %ebx,%esi
  800bf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 17                	jle    800c14 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 08                	push   $0x8
  800c03:	68 1f 21 80 00       	push   $0x80211f
  800c08:	6a 23                	push   $0x23
  800c0a:	68 3c 21 80 00       	push   $0x80213c
  800c0f:	e8 d3 0d 00 00       	call   8019e7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 df                	mov    %ebx,%edi
  800c37:	89 de                	mov    %ebx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 17                	jle    800c56 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 09                	push   $0x9
  800c45:	68 1f 21 80 00       	push   $0x80211f
  800c4a:	6a 23                	push   $0x23
  800c4c:	68 3c 21 80 00       	push   $0x80213c
  800c51:	e8 91 0d 00 00       	call   8019e7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 17                	jle    800c98 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 0a                	push   $0xa
  800c87:	68 1f 21 80 00       	push   $0x80211f
  800c8c:	6a 23                	push   $0x23
  800c8e:	68 3c 21 80 00       	push   $0x80213c
  800c93:	e8 4f 0d 00 00       	call   8019e7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ca6:	be 00 00 00 00       	mov    $0x0,%esi
  800cab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800ccc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	89 cb                	mov    %ecx,%ebx
  800cdb:	89 cf                	mov    %ecx,%edi
  800cdd:	89 ce                	mov    %ecx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 0d                	push   $0xd
  800ceb:	68 1f 21 80 00       	push   $0x80211f
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 3c 21 80 00       	push   $0x80213c
  800cf7:	e8 eb 0c 00 00       	call   8019e7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d0f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d24:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d31:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d36:	89 c2                	mov    %eax,%edx
  800d38:	c1 ea 16             	shr    $0x16,%edx
  800d3b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d42:	f6 c2 01             	test   $0x1,%dl
  800d45:	74 11                	je     800d58 <fd_alloc+0x2d>
  800d47:	89 c2                	mov    %eax,%edx
  800d49:	c1 ea 0c             	shr    $0xc,%edx
  800d4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d53:	f6 c2 01             	test   $0x1,%dl
  800d56:	75 09                	jne    800d61 <fd_alloc+0x36>
			*fd_store = fd;
  800d58:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5f:	eb 17                	jmp    800d78 <fd_alloc+0x4d>
  800d61:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d66:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d6b:	75 c9                	jne    800d36 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d6d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d73:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    

00800d7a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d80:	83 f8 1f             	cmp    $0x1f,%eax
  800d83:	77 36                	ja     800dbb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d85:	c1 e0 0c             	shl    $0xc,%eax
  800d88:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	c1 ea 16             	shr    $0x16,%edx
  800d92:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d99:	f6 c2 01             	test   $0x1,%dl
  800d9c:	74 24                	je     800dc2 <fd_lookup+0x48>
  800d9e:	89 c2                	mov    %eax,%edx
  800da0:	c1 ea 0c             	shr    $0xc,%edx
  800da3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800daa:	f6 c2 01             	test   $0x1,%dl
  800dad:	74 1a                	je     800dc9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800daf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db2:	89 02                	mov    %eax,(%edx)
	return 0;
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	eb 13                	jmp    800dce <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dbb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc0:	eb 0c                	jmp    800dce <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dc7:	eb 05                	jmp    800dce <fd_lookup+0x54>
  800dc9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	83 ec 08             	sub    $0x8,%esp
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dde:	eb 13                	jmp    800df3 <dev_lookup+0x23>
  800de0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800de3:	39 08                	cmp    %ecx,(%eax)
  800de5:	75 0c                	jne    800df3 <dev_lookup+0x23>
			*dev = devtab[i];
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dec:	b8 00 00 00 00       	mov    $0x0,%eax
  800df1:	eb 2e                	jmp    800e21 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800df3:	8b 02                	mov    (%edx),%eax
  800df5:	85 c0                	test   %eax,%eax
  800df7:	75 e7                	jne    800de0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800df9:	a1 04 40 80 00       	mov    0x804004,%eax
  800dfe:	8b 40 48             	mov    0x48(%eax),%eax
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	51                   	push   %ecx
  800e05:	50                   	push   %eax
  800e06:	68 4c 21 80 00       	push   $0x80214c
  800e0b:	e8 31 f3 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e21:	c9                   	leave  
  800e22:	c3                   	ret    

00800e23 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 10             	sub    $0x10,%esp
  800e2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e34:	50                   	push   %eax
  800e35:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
  800e3e:	50                   	push   %eax
  800e3f:	e8 36 ff ff ff       	call   800d7a <fd_lookup>
  800e44:	83 c4 08             	add    $0x8,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	78 05                	js     800e50 <fd_close+0x2d>
	    || fd != fd2)
  800e4b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e4e:	74 0c                	je     800e5c <fd_close+0x39>
		return (must_exist ? r : 0);
  800e50:	84 db                	test   %bl,%bl
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	0f 44 c2             	cmove  %edx,%eax
  800e5a:	eb 41                	jmp    800e9d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e62:	50                   	push   %eax
  800e63:	ff 36                	pushl  (%esi)
  800e65:	e8 66 ff ff ff       	call   800dd0 <dev_lookup>
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	78 1a                	js     800e8d <fd_close+0x6a>
		if (dev->dev_close)
  800e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e76:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e79:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	74 0b                	je     800e8d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e82:	83 ec 0c             	sub    $0xc,%esp
  800e85:	56                   	push   %esi
  800e86:	ff d0                	call   *%eax
  800e88:	89 c3                	mov    %eax,%ebx
  800e8a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e8d:	83 ec 08             	sub    $0x8,%esp
  800e90:	56                   	push   %esi
  800e91:	6a 00                	push   $0x0
  800e93:	e8 00 fd ff ff       	call   800b98 <sys_page_unmap>
	return r;
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	89 d8                	mov    %ebx,%eax
}
  800e9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eaa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ead:	50                   	push   %eax
  800eae:	ff 75 08             	pushl  0x8(%ebp)
  800eb1:	e8 c4 fe ff ff       	call   800d7a <fd_lookup>
  800eb6:	83 c4 08             	add    $0x8,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	78 10                	js     800ecd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ebd:	83 ec 08             	sub    $0x8,%esp
  800ec0:	6a 01                	push   $0x1
  800ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec5:	e8 59 ff ff ff       	call   800e23 <fd_close>
  800eca:	83 c4 10             	add    $0x10,%esp
}
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <close_all>:

void
close_all(void)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	53                   	push   %ebx
  800ed3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ed6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800edb:	83 ec 0c             	sub    $0xc,%esp
  800ede:	53                   	push   %ebx
  800edf:	e8 c0 ff ff ff       	call   800ea4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee4:	83 c3 01             	add    $0x1,%ebx
  800ee7:	83 c4 10             	add    $0x10,%esp
  800eea:	83 fb 20             	cmp    $0x20,%ebx
  800eed:	75 ec                	jne    800edb <close_all+0xc>
		close(i);
}
  800eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	57                   	push   %edi
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 2c             	sub    $0x2c,%esp
  800efd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f00:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f03:	50                   	push   %eax
  800f04:	ff 75 08             	pushl  0x8(%ebp)
  800f07:	e8 6e fe ff ff       	call   800d7a <fd_lookup>
  800f0c:	83 c4 08             	add    $0x8,%esp
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	0f 88 c1 00 00 00    	js     800fd8 <dup+0xe4>
		return r;
	close(newfdnum);
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	56                   	push   %esi
  800f1b:	e8 84 ff ff ff       	call   800ea4 <close>

	newfd = INDEX2FD(newfdnum);
  800f20:	89 f3                	mov    %esi,%ebx
  800f22:	c1 e3 0c             	shl    $0xc,%ebx
  800f25:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f2b:	83 c4 04             	add    $0x4,%esp
  800f2e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f31:	e8 de fd ff ff       	call   800d14 <fd2data>
  800f36:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f38:	89 1c 24             	mov    %ebx,(%esp)
  800f3b:	e8 d4 fd ff ff       	call   800d14 <fd2data>
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f46:	89 f8                	mov    %edi,%eax
  800f48:	c1 e8 16             	shr    $0x16,%eax
  800f4b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f52:	a8 01                	test   $0x1,%al
  800f54:	74 37                	je     800f8d <dup+0x99>
  800f56:	89 f8                	mov    %edi,%eax
  800f58:	c1 e8 0c             	shr    $0xc,%eax
  800f5b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f62:	f6 c2 01             	test   $0x1,%dl
  800f65:	74 26                	je     800f8d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	25 07 0e 00 00       	and    $0xe07,%eax
  800f76:	50                   	push   %eax
  800f77:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f7a:	6a 00                	push   $0x0
  800f7c:	57                   	push   %edi
  800f7d:	6a 00                	push   $0x0
  800f7f:	e8 d2 fb ff ff       	call   800b56 <sys_page_map>
  800f84:	89 c7                	mov    %eax,%edi
  800f86:	83 c4 20             	add    $0x20,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 2e                	js     800fbb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f90:	89 d0                	mov    %edx,%eax
  800f92:	c1 e8 0c             	shr    $0xc,%eax
  800f95:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	25 07 0e 00 00       	and    $0xe07,%eax
  800fa4:	50                   	push   %eax
  800fa5:	53                   	push   %ebx
  800fa6:	6a 00                	push   $0x0
  800fa8:	52                   	push   %edx
  800fa9:	6a 00                	push   $0x0
  800fab:	e8 a6 fb ff ff       	call   800b56 <sys_page_map>
  800fb0:	89 c7                	mov    %eax,%edi
  800fb2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fb5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fb7:	85 ff                	test   %edi,%edi
  800fb9:	79 1d                	jns    800fd8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fbb:	83 ec 08             	sub    $0x8,%esp
  800fbe:	53                   	push   %ebx
  800fbf:	6a 00                	push   $0x0
  800fc1:	e8 d2 fb ff ff       	call   800b98 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fc6:	83 c4 08             	add    $0x8,%esp
  800fc9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 c5 fb ff ff       	call   800b98 <sys_page_unmap>
	return r;
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	89 f8                	mov    %edi,%eax
}
  800fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fdb:	5b                   	pop    %ebx
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    

00800fe0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	53                   	push   %ebx
  800fe4:	83 ec 14             	sub    $0x14,%esp
  800fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	53                   	push   %ebx
  800fef:	e8 86 fd ff ff       	call   800d7a <fd_lookup>
  800ff4:	83 c4 08             	add    $0x8,%esp
  800ff7:	89 c2                	mov    %eax,%edx
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 6d                	js     80106a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ffd:	83 ec 08             	sub    $0x8,%esp
  801000:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801007:	ff 30                	pushl  (%eax)
  801009:	e8 c2 fd ff ff       	call   800dd0 <dev_lookup>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	78 4c                	js     801061 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801015:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801018:	8b 42 08             	mov    0x8(%edx),%eax
  80101b:	83 e0 03             	and    $0x3,%eax
  80101e:	83 f8 01             	cmp    $0x1,%eax
  801021:	75 21                	jne    801044 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801023:	a1 04 40 80 00       	mov    0x804004,%eax
  801028:	8b 40 48             	mov    0x48(%eax),%eax
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	53                   	push   %ebx
  80102f:	50                   	push   %eax
  801030:	68 8d 21 80 00       	push   $0x80218d
  801035:	e8 07 f1 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801042:	eb 26                	jmp    80106a <read+0x8a>
	}
	if (!dev->dev_read)
  801044:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801047:	8b 40 08             	mov    0x8(%eax),%eax
  80104a:	85 c0                	test   %eax,%eax
  80104c:	74 17                	je     801065 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80104e:	83 ec 04             	sub    $0x4,%esp
  801051:	ff 75 10             	pushl  0x10(%ebp)
  801054:	ff 75 0c             	pushl  0xc(%ebp)
  801057:	52                   	push   %edx
  801058:	ff d0                	call   *%eax
  80105a:	89 c2                	mov    %eax,%edx
  80105c:	83 c4 10             	add    $0x10,%esp
  80105f:	eb 09                	jmp    80106a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801061:	89 c2                	mov    %eax,%edx
  801063:	eb 05                	jmp    80106a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801065:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	53                   	push   %ebx
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80107d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801080:	bb 00 00 00 00       	mov    $0x0,%ebx
  801085:	eb 21                	jmp    8010a8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801087:	83 ec 04             	sub    $0x4,%esp
  80108a:	89 f0                	mov    %esi,%eax
  80108c:	29 d8                	sub    %ebx,%eax
  80108e:	50                   	push   %eax
  80108f:	89 d8                	mov    %ebx,%eax
  801091:	03 45 0c             	add    0xc(%ebp),%eax
  801094:	50                   	push   %eax
  801095:	57                   	push   %edi
  801096:	e8 45 ff ff ff       	call   800fe0 <read>
		if (m < 0)
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 10                	js     8010b2 <readn+0x41>
			return m;
		if (m == 0)
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	74 0a                	je     8010b0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010a6:	01 c3                	add    %eax,%ebx
  8010a8:	39 f3                	cmp    %esi,%ebx
  8010aa:	72 db                	jb     801087 <readn+0x16>
  8010ac:	89 d8                	mov    %ebx,%eax
  8010ae:	eb 02                	jmp    8010b2 <readn+0x41>
  8010b0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 14             	sub    $0x14,%esp
  8010c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c7:	50                   	push   %eax
  8010c8:	53                   	push   %ebx
  8010c9:	e8 ac fc ff ff       	call   800d7a <fd_lookup>
  8010ce:	83 c4 08             	add    $0x8,%esp
  8010d1:	89 c2                	mov    %eax,%edx
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 68                	js     80113f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d7:	83 ec 08             	sub    $0x8,%esp
  8010da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010dd:	50                   	push   %eax
  8010de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010e1:	ff 30                	pushl  (%eax)
  8010e3:	e8 e8 fc ff ff       	call   800dd0 <dev_lookup>
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 47                	js     801136 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010f6:	75 21                	jne    801119 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fd:	8b 40 48             	mov    0x48(%eax),%eax
  801100:	83 ec 04             	sub    $0x4,%esp
  801103:	53                   	push   %ebx
  801104:	50                   	push   %eax
  801105:	68 a9 21 80 00       	push   $0x8021a9
  80110a:	e8 32 f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801117:	eb 26                	jmp    80113f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801119:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80111c:	8b 52 0c             	mov    0xc(%edx),%edx
  80111f:	85 d2                	test   %edx,%edx
  801121:	74 17                	je     80113a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	ff 75 10             	pushl  0x10(%ebp)
  801129:	ff 75 0c             	pushl  0xc(%ebp)
  80112c:	50                   	push   %eax
  80112d:	ff d2                	call   *%edx
  80112f:	89 c2                	mov    %eax,%edx
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	eb 09                	jmp    80113f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801136:	89 c2                	mov    %eax,%edx
  801138:	eb 05                	jmp    80113f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80113a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80113f:	89 d0                	mov    %edx,%eax
  801141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <seek>:

int
seek(int fdnum, off_t offset)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	ff 75 08             	pushl  0x8(%ebp)
  801153:	e8 22 fc ff ff       	call   800d7a <fd_lookup>
  801158:	83 c4 08             	add    $0x8,%esp
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 0e                	js     80116d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80115f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801162:	8b 55 0c             	mov    0xc(%ebp),%edx
  801165:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801168:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80116d:	c9                   	leave  
  80116e:	c3                   	ret    

0080116f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	53                   	push   %ebx
  801173:	83 ec 14             	sub    $0x14,%esp
  801176:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801179:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117c:	50                   	push   %eax
  80117d:	53                   	push   %ebx
  80117e:	e8 f7 fb ff ff       	call   800d7a <fd_lookup>
  801183:	83 c4 08             	add    $0x8,%esp
  801186:	89 c2                	mov    %eax,%edx
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 65                	js     8011f1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	50                   	push   %eax
  801193:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801196:	ff 30                	pushl  (%eax)
  801198:	e8 33 fc ff ff       	call   800dd0 <dev_lookup>
  80119d:	83 c4 10             	add    $0x10,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 44                	js     8011e8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ab:	75 21                	jne    8011ce <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ad:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b2:	8b 40 48             	mov    0x48(%eax),%eax
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	53                   	push   %ebx
  8011b9:	50                   	push   %eax
  8011ba:	68 6c 21 80 00       	push   $0x80216c
  8011bf:	e8 7d ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011cc:	eb 23                	jmp    8011f1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011d1:	8b 52 18             	mov    0x18(%edx),%edx
  8011d4:	85 d2                	test   %edx,%edx
  8011d6:	74 14                	je     8011ec <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	50                   	push   %eax
  8011df:	ff d2                	call   *%edx
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb 09                	jmp    8011f1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	eb 05                	jmp    8011f1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011f1:	89 d0                	mov    %edx,%eax
  8011f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 14             	sub    $0x14,%esp
  8011ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801202:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	ff 75 08             	pushl  0x8(%ebp)
  801209:	e8 6c fb ff ff       	call   800d7a <fd_lookup>
  80120e:	83 c4 08             	add    $0x8,%esp
  801211:	89 c2                	mov    %eax,%edx
  801213:	85 c0                	test   %eax,%eax
  801215:	78 58                	js     80126f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801217:	83 ec 08             	sub    $0x8,%esp
  80121a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121d:	50                   	push   %eax
  80121e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801221:	ff 30                	pushl  (%eax)
  801223:	e8 a8 fb ff ff       	call   800dd0 <dev_lookup>
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 37                	js     801266 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80122f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801232:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801236:	74 32                	je     80126a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801238:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80123b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801242:	00 00 00 
	stat->st_isdir = 0;
  801245:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80124c:	00 00 00 
	stat->st_dev = dev;
  80124f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801255:	83 ec 08             	sub    $0x8,%esp
  801258:	53                   	push   %ebx
  801259:	ff 75 f0             	pushl  -0x10(%ebp)
  80125c:	ff 50 14             	call   *0x14(%eax)
  80125f:	89 c2                	mov    %eax,%edx
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	eb 09                	jmp    80126f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801266:	89 c2                	mov    %eax,%edx
  801268:	eb 05                	jmp    80126f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80126a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80126f:	89 d0                	mov    %edx,%eax
  801271:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801274:	c9                   	leave  
  801275:	c3                   	ret    

00801276 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80127b:	83 ec 08             	sub    $0x8,%esp
  80127e:	6a 00                	push   $0x0
  801280:	ff 75 08             	pushl  0x8(%ebp)
  801283:	e8 dc 01 00 00       	call   801464 <open>
  801288:	89 c3                	mov    %eax,%ebx
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 1b                	js     8012ac <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801291:	83 ec 08             	sub    $0x8,%esp
  801294:	ff 75 0c             	pushl  0xc(%ebp)
  801297:	50                   	push   %eax
  801298:	e8 5b ff ff ff       	call   8011f8 <fstat>
  80129d:	89 c6                	mov    %eax,%esi
	close(fd);
  80129f:	89 1c 24             	mov    %ebx,(%esp)
  8012a2:	e8 fd fb ff ff       	call   800ea4 <close>
	return r;
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	89 f0                	mov    %esi,%eax
}
  8012ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012af:	5b                   	pop    %ebx
  8012b0:	5e                   	pop    %esi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	56                   	push   %esi
  8012b7:	53                   	push   %ebx
  8012b8:	89 c6                	mov    %eax,%esi
  8012ba:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012bc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012c3:	75 12                	jne    8012d7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	6a 01                	push   $0x1
  8012ca:	e8 fe 07 00 00       	call   801acd <ipc_find_env>
  8012cf:	a3 00 40 80 00       	mov    %eax,0x804000
  8012d4:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012d7:	6a 07                	push   $0x7
  8012d9:	68 00 50 80 00       	push   $0x805000
  8012de:	56                   	push   %esi
  8012df:	ff 35 00 40 80 00    	pushl  0x804000
  8012e5:	e8 a0 07 00 00       	call   801a8a <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8012ea:	83 c4 0c             	add    $0xc,%esp
  8012ed:	6a 00                	push   $0x0
  8012ef:	53                   	push   %ebx
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 36 07 00 00       	call   801a2d <ipc_recv>
}
  8012f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5e                   	pop    %esi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801304:	8b 45 08             	mov    0x8(%ebp),%eax
  801307:	8b 40 0c             	mov    0xc(%eax),%eax
  80130a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80130f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801312:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801317:	ba 00 00 00 00       	mov    $0x0,%edx
  80131c:	b8 02 00 00 00       	mov    $0x2,%eax
  801321:	e8 8d ff ff ff       	call   8012b3 <fsipc>
}
  801326:	c9                   	leave  
  801327:	c3                   	ret    

00801328 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80132e:	8b 45 08             	mov    0x8(%ebp),%eax
  801331:	8b 40 0c             	mov    0xc(%eax),%eax
  801334:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801339:	ba 00 00 00 00       	mov    $0x0,%edx
  80133e:	b8 06 00 00 00       	mov    $0x6,%eax
  801343:	e8 6b ff ff ff       	call   8012b3 <fsipc>
}
  801348:	c9                   	leave  
  801349:	c3                   	ret    

0080134a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	53                   	push   %ebx
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
  801357:	8b 40 0c             	mov    0xc(%eax),%eax
  80135a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	b8 05 00 00 00       	mov    $0x5,%eax
  801369:	e8 45 ff ff ff       	call   8012b3 <fsipc>
  80136e:	85 c0                	test   %eax,%eax
  801370:	78 2c                	js     80139e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	68 00 50 80 00       	push   $0x805000
  80137a:	53                   	push   %ebx
  80137b:	e8 90 f3 ff ff       	call   800710 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801380:	a1 80 50 80 00       	mov    0x805080,%eax
  801385:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80138b:	a1 84 50 80 00       	mov    0x805084,%eax
  801390:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80139e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8013af:	8b 52 0c             	mov    0xc(%edx),%edx
  8013b2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013b8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013bd:	50                   	push   %eax
  8013be:	ff 75 0c             	pushl  0xc(%ebp)
  8013c1:	68 08 50 80 00       	push   $0x805008
  8013c6:	e8 d7 f4 ff ff       	call   8008a2 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d5:	e8 d9 fe ff ff       	call   8012b3 <fsipc>
	//panic("devfile_write not implemented");
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ef:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8013ff:	e8 af fe ff ff       	call   8012b3 <fsipc>
  801404:	89 c3                	mov    %eax,%ebx
  801406:	85 c0                	test   %eax,%eax
  801408:	78 51                	js     80145b <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80140a:	39 c6                	cmp    %eax,%esi
  80140c:	73 19                	jae    801427 <devfile_read+0x4b>
  80140e:	68 d8 21 80 00       	push   $0x8021d8
  801413:	68 df 21 80 00       	push   $0x8021df
  801418:	68 80 00 00 00       	push   $0x80
  80141d:	68 f4 21 80 00       	push   $0x8021f4
  801422:	e8 c0 05 00 00       	call   8019e7 <_panic>
	assert(r <= PGSIZE);
  801427:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80142c:	7e 19                	jle    801447 <devfile_read+0x6b>
  80142e:	68 ff 21 80 00       	push   $0x8021ff
  801433:	68 df 21 80 00       	push   $0x8021df
  801438:	68 81 00 00 00       	push   $0x81
  80143d:	68 f4 21 80 00       	push   $0x8021f4
  801442:	e8 a0 05 00 00       	call   8019e7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801447:	83 ec 04             	sub    $0x4,%esp
  80144a:	50                   	push   %eax
  80144b:	68 00 50 80 00       	push   $0x805000
  801450:	ff 75 0c             	pushl  0xc(%ebp)
  801453:	e8 4a f4 ff ff       	call   8008a2 <memmove>
	return r;
  801458:	83 c4 10             	add    $0x10,%esp
}
  80145b:	89 d8                	mov    %ebx,%eax
  80145d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801460:	5b                   	pop    %ebx
  801461:	5e                   	pop    %esi
  801462:	5d                   	pop    %ebp
  801463:	c3                   	ret    

00801464 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	83 ec 20             	sub    $0x20,%esp
  80146b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80146e:	53                   	push   %ebx
  80146f:	e8 63 f2 ff ff       	call   8006d7 <strlen>
  801474:	83 c4 10             	add    $0x10,%esp
  801477:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80147c:	7f 67                	jg     8014e5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80147e:	83 ec 0c             	sub    $0xc,%esp
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	e8 a1 f8 ff ff       	call   800d2b <fd_alloc>
  80148a:	83 c4 10             	add    $0x10,%esp
		return r;
  80148d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80148f:	85 c0                	test   %eax,%eax
  801491:	78 57                	js     8014ea <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	53                   	push   %ebx
  801497:	68 00 50 80 00       	push   $0x805000
  80149c:	e8 6f f2 ff ff       	call   800710 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a4:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b1:	e8 fd fd ff ff       	call   8012b3 <fsipc>
  8014b6:	89 c3                	mov    %eax,%ebx
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	79 14                	jns    8014d3 <open+0x6f>
		
		fd_close(fd, 0);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	6a 00                	push   $0x0
  8014c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c7:	e8 57 f9 ff ff       	call   800e23 <fd_close>
		return r;
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	89 da                	mov    %ebx,%edx
  8014d1:	eb 17                	jmp    8014ea <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d9:	e8 26 f8 ff ff       	call   800d04 <fd2num>
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	eb 05                	jmp    8014ea <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014e5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8014ea:	89 d0                	mov    %edx,%eax
  8014ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ef:	c9                   	leave  
  8014f0:	c3                   	ret    

008014f1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801501:	e8 ad fd ff ff       	call   8012b3 <fsipc>
}
  801506:	c9                   	leave  
  801507:	c3                   	ret    

00801508 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801510:	83 ec 0c             	sub    $0xc,%esp
  801513:	ff 75 08             	pushl  0x8(%ebp)
  801516:	e8 f9 f7 ff ff       	call   800d14 <fd2data>
  80151b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	68 0b 22 80 00       	push   $0x80220b
  801525:	53                   	push   %ebx
  801526:	e8 e5 f1 ff ff       	call   800710 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80152b:	8b 46 04             	mov    0x4(%esi),%eax
  80152e:	2b 06                	sub    (%esi),%eax
  801530:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801536:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80153d:	00 00 00 
	stat->st_dev = &devpipe;
  801540:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801547:	30 80 00 
	return 0;
}
  80154a:	b8 00 00 00 00       	mov    $0x0,%eax
  80154f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	53                   	push   %ebx
  80155a:	83 ec 0c             	sub    $0xc,%esp
  80155d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801560:	53                   	push   %ebx
  801561:	6a 00                	push   $0x0
  801563:	e8 30 f6 ff ff       	call   800b98 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801568:	89 1c 24             	mov    %ebx,(%esp)
  80156b:	e8 a4 f7 ff ff       	call   800d14 <fd2data>
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	50                   	push   %eax
  801574:	6a 00                	push   $0x0
  801576:	e8 1d f6 ff ff       	call   800b98 <sys_page_unmap>
}
  80157b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	53                   	push   %ebx
  801586:	83 ec 1c             	sub    $0x1c,%esp
  801589:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80158c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80158e:	a1 04 40 80 00       	mov    0x804004,%eax
  801593:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801596:	83 ec 0c             	sub    $0xc,%esp
  801599:	ff 75 e0             	pushl  -0x20(%ebp)
  80159c:	e8 65 05 00 00       	call   801b06 <pageref>
  8015a1:	89 c3                	mov    %eax,%ebx
  8015a3:	89 3c 24             	mov    %edi,(%esp)
  8015a6:	e8 5b 05 00 00       	call   801b06 <pageref>
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	39 c3                	cmp    %eax,%ebx
  8015b0:	0f 94 c1             	sete   %cl
  8015b3:	0f b6 c9             	movzbl %cl,%ecx
  8015b6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015b9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015bf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015c2:	39 ce                	cmp    %ecx,%esi
  8015c4:	74 1b                	je     8015e1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015c6:	39 c3                	cmp    %eax,%ebx
  8015c8:	75 c4                	jne    80158e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015ca:	8b 42 58             	mov    0x58(%edx),%eax
  8015cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d0:	50                   	push   %eax
  8015d1:	56                   	push   %esi
  8015d2:	68 12 22 80 00       	push   $0x802212
  8015d7:	e8 65 eb ff ff       	call   800141 <cprintf>
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	eb ad                	jmp    80158e <_pipeisclosed+0xe>
	}
}
  8015e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e7:	5b                   	pop    %ebx
  8015e8:	5e                   	pop    %esi
  8015e9:	5f                   	pop    %edi
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	57                   	push   %edi
  8015f0:	56                   	push   %esi
  8015f1:	53                   	push   %ebx
  8015f2:	83 ec 28             	sub    $0x28,%esp
  8015f5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8015f8:	56                   	push   %esi
  8015f9:	e8 16 f7 ff ff       	call   800d14 <fd2data>
  8015fe:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	bf 00 00 00 00       	mov    $0x0,%edi
  801608:	eb 4b                	jmp    801655 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80160a:	89 da                	mov    %ebx,%edx
  80160c:	89 f0                	mov    %esi,%eax
  80160e:	e8 6d ff ff ff       	call   801580 <_pipeisclosed>
  801613:	85 c0                	test   %eax,%eax
  801615:	75 48                	jne    80165f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801617:	e8 d8 f4 ff ff       	call   800af4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80161c:	8b 43 04             	mov    0x4(%ebx),%eax
  80161f:	8b 0b                	mov    (%ebx),%ecx
  801621:	8d 51 20             	lea    0x20(%ecx),%edx
  801624:	39 d0                	cmp    %edx,%eax
  801626:	73 e2                	jae    80160a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801628:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80162f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801632:	89 c2                	mov    %eax,%edx
  801634:	c1 fa 1f             	sar    $0x1f,%edx
  801637:	89 d1                	mov    %edx,%ecx
  801639:	c1 e9 1b             	shr    $0x1b,%ecx
  80163c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80163f:	83 e2 1f             	and    $0x1f,%edx
  801642:	29 ca                	sub    %ecx,%edx
  801644:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801648:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80164c:	83 c0 01             	add    $0x1,%eax
  80164f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801652:	83 c7 01             	add    $0x1,%edi
  801655:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801658:	75 c2                	jne    80161c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80165a:	8b 45 10             	mov    0x10(%ebp),%eax
  80165d:	eb 05                	jmp    801664 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80165f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
  801672:	83 ec 18             	sub    $0x18,%esp
  801675:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801678:	57                   	push   %edi
  801679:	e8 96 f6 ff ff       	call   800d14 <fd2data>
  80167e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	bb 00 00 00 00       	mov    $0x0,%ebx
  801688:	eb 3d                	jmp    8016c7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80168a:	85 db                	test   %ebx,%ebx
  80168c:	74 04                	je     801692 <devpipe_read+0x26>
				return i;
  80168e:	89 d8                	mov    %ebx,%eax
  801690:	eb 44                	jmp    8016d6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801692:	89 f2                	mov    %esi,%edx
  801694:	89 f8                	mov    %edi,%eax
  801696:	e8 e5 fe ff ff       	call   801580 <_pipeisclosed>
  80169b:	85 c0                	test   %eax,%eax
  80169d:	75 32                	jne    8016d1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80169f:	e8 50 f4 ff ff       	call   800af4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016a4:	8b 06                	mov    (%esi),%eax
  8016a6:	3b 46 04             	cmp    0x4(%esi),%eax
  8016a9:	74 df                	je     80168a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ab:	99                   	cltd   
  8016ac:	c1 ea 1b             	shr    $0x1b,%edx
  8016af:	01 d0                	add    %edx,%eax
  8016b1:	83 e0 1f             	and    $0x1f,%eax
  8016b4:	29 d0                	sub    %edx,%eax
  8016b6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016be:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016c1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c4:	83 c3 01             	add    $0x1,%ebx
  8016c7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016ca:	75 d8                	jne    8016a4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8016cf:	eb 05                	jmp    8016d6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016d1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016d9:	5b                   	pop    %ebx
  8016da:	5e                   	pop    %esi
  8016db:	5f                   	pop    %edi
  8016dc:	5d                   	pop    %ebp
  8016dd:	c3                   	ret    

008016de <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e9:	50                   	push   %eax
  8016ea:	e8 3c f6 ff ff       	call   800d2b <fd_alloc>
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	89 c2                	mov    %eax,%edx
  8016f4:	85 c0                	test   %eax,%eax
  8016f6:	0f 88 2c 01 00 00    	js     801828 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8016fc:	83 ec 04             	sub    $0x4,%esp
  8016ff:	68 07 04 00 00       	push   $0x407
  801704:	ff 75 f4             	pushl  -0xc(%ebp)
  801707:	6a 00                	push   $0x0
  801709:	e8 05 f4 ff ff       	call   800b13 <sys_page_alloc>
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	89 c2                	mov    %eax,%edx
  801713:	85 c0                	test   %eax,%eax
  801715:	0f 88 0d 01 00 00    	js     801828 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80171b:	83 ec 0c             	sub    $0xc,%esp
  80171e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	e8 04 f6 ff ff       	call   800d2b <fd_alloc>
  801727:	89 c3                	mov    %eax,%ebx
  801729:	83 c4 10             	add    $0x10,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	0f 88 e2 00 00 00    	js     801816 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801734:	83 ec 04             	sub    $0x4,%esp
  801737:	68 07 04 00 00       	push   $0x407
  80173c:	ff 75 f0             	pushl  -0x10(%ebp)
  80173f:	6a 00                	push   $0x0
  801741:	e8 cd f3 ff ff       	call   800b13 <sys_page_alloc>
  801746:	89 c3                	mov    %eax,%ebx
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	0f 88 c3 00 00 00    	js     801816 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801753:	83 ec 0c             	sub    $0xc,%esp
  801756:	ff 75 f4             	pushl  -0xc(%ebp)
  801759:	e8 b6 f5 ff ff       	call   800d14 <fd2data>
  80175e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801760:	83 c4 0c             	add    $0xc,%esp
  801763:	68 07 04 00 00       	push   $0x407
  801768:	50                   	push   %eax
  801769:	6a 00                	push   $0x0
  80176b:	e8 a3 f3 ff ff       	call   800b13 <sys_page_alloc>
  801770:	89 c3                	mov    %eax,%ebx
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	85 c0                	test   %eax,%eax
  801777:	0f 88 89 00 00 00    	js     801806 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80177d:	83 ec 0c             	sub    $0xc,%esp
  801780:	ff 75 f0             	pushl  -0x10(%ebp)
  801783:	e8 8c f5 ff ff       	call   800d14 <fd2data>
  801788:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80178f:	50                   	push   %eax
  801790:	6a 00                	push   $0x0
  801792:	56                   	push   %esi
  801793:	6a 00                	push   $0x0
  801795:	e8 bc f3 ff ff       	call   800b56 <sys_page_map>
  80179a:	89 c3                	mov    %eax,%ebx
  80179c:	83 c4 20             	add    $0x20,%esp
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	78 55                	js     8017f8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017a3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017b8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017cd:	83 ec 0c             	sub    $0xc,%esp
  8017d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d3:	e8 2c f5 ff ff       	call   800d04 <fd2num>
  8017d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017db:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017dd:	83 c4 04             	add    $0x4,%esp
  8017e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017e3:	e8 1c f5 ff ff       	call   800d04 <fd2num>
  8017e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017eb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f6:	eb 30                	jmp    801828 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	56                   	push   %esi
  8017fc:	6a 00                	push   $0x0
  8017fe:	e8 95 f3 ff ff       	call   800b98 <sys_page_unmap>
  801803:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	ff 75 f0             	pushl  -0x10(%ebp)
  80180c:	6a 00                	push   $0x0
  80180e:	e8 85 f3 ff ff       	call   800b98 <sys_page_unmap>
  801813:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	ff 75 f4             	pushl  -0xc(%ebp)
  80181c:	6a 00                	push   $0x0
  80181e:	e8 75 f3 ff ff       	call   800b98 <sys_page_unmap>
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801828:	89 d0                	mov    %edx,%eax
  80182a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801837:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183a:	50                   	push   %eax
  80183b:	ff 75 08             	pushl  0x8(%ebp)
  80183e:	e8 37 f5 ff ff       	call   800d7a <fd_lookup>
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	85 c0                	test   %eax,%eax
  801848:	78 18                	js     801862 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80184a:	83 ec 0c             	sub    $0xc,%esp
  80184d:	ff 75 f4             	pushl  -0xc(%ebp)
  801850:	e8 bf f4 ff ff       	call   800d14 <fd2data>
	return _pipeisclosed(fd, p);
  801855:	89 c2                	mov    %eax,%edx
  801857:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80185a:	e8 21 fd ff ff       	call   801580 <_pipeisclosed>
  80185f:	83 c4 10             	add    $0x10,%esp
}
  801862:	c9                   	leave  
  801863:	c3                   	ret    

00801864 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801867:	b8 00 00 00 00       	mov    $0x0,%eax
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    

0080186e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801874:	68 2a 22 80 00       	push   $0x80222a
  801879:	ff 75 0c             	pushl  0xc(%ebp)
  80187c:	e8 8f ee ff ff       	call   800710 <strcpy>
	return 0;
}
  801881:	b8 00 00 00 00       	mov    $0x0,%eax
  801886:	c9                   	leave  
  801887:	c3                   	ret    

00801888 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	57                   	push   %edi
  80188c:	56                   	push   %esi
  80188d:	53                   	push   %ebx
  80188e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801894:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801899:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80189f:	eb 2d                	jmp    8018ce <devcons_write+0x46>
		m = n - tot;
  8018a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018a4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018a6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018a9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018ae:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018b1:	83 ec 04             	sub    $0x4,%esp
  8018b4:	53                   	push   %ebx
  8018b5:	03 45 0c             	add    0xc(%ebp),%eax
  8018b8:	50                   	push   %eax
  8018b9:	57                   	push   %edi
  8018ba:	e8 e3 ef ff ff       	call   8008a2 <memmove>
		sys_cputs(buf, m);
  8018bf:	83 c4 08             	add    $0x8,%esp
  8018c2:	53                   	push   %ebx
  8018c3:	57                   	push   %edi
  8018c4:	e8 8e f1 ff ff       	call   800a57 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018c9:	01 de                	add    %ebx,%esi
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	89 f0                	mov    %esi,%eax
  8018d0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018d3:	72 cc                	jb     8018a1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5f                   	pop    %edi
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018ec:	74 2a                	je     801918 <devcons_read+0x3b>
  8018ee:	eb 05                	jmp    8018f5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018f0:	e8 ff f1 ff ff       	call   800af4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8018f5:	e8 7b f1 ff ff       	call   800a75 <sys_cgetc>
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	74 f2                	je     8018f0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8018fe:	85 c0                	test   %eax,%eax
  801900:	78 16                	js     801918 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801902:	83 f8 04             	cmp    $0x4,%eax
  801905:	74 0c                	je     801913 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801907:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190a:	88 02                	mov    %al,(%edx)
	return 1;
  80190c:	b8 01 00 00 00       	mov    $0x1,%eax
  801911:	eb 05                	jmp    801918 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801913:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801926:	6a 01                	push   $0x1
  801928:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80192b:	50                   	push   %eax
  80192c:	e8 26 f1 ff ff       	call   800a57 <sys_cputs>
}
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	c9                   	leave  
  801935:	c3                   	ret    

00801936 <getchar>:

int
getchar(void)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80193c:	6a 01                	push   $0x1
  80193e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	6a 00                	push   $0x0
  801944:	e8 97 f6 ff ff       	call   800fe0 <read>
	if (r < 0)
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 0f                	js     80195f <getchar+0x29>
		return r;
	if (r < 1)
  801950:	85 c0                	test   %eax,%eax
  801952:	7e 06                	jle    80195a <getchar+0x24>
		return -E_EOF;
	return c;
  801954:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801958:	eb 05                	jmp    80195f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80195a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801967:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196a:	50                   	push   %eax
  80196b:	ff 75 08             	pushl  0x8(%ebp)
  80196e:	e8 07 f4 ff ff       	call   800d7a <fd_lookup>
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	85 c0                	test   %eax,%eax
  801978:	78 11                	js     80198b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80197a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801983:	39 10                	cmp    %edx,(%eax)
  801985:	0f 94 c0             	sete   %al
  801988:	0f b6 c0             	movzbl %al,%eax
}
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <opencons>:

int
opencons(void)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801993:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801996:	50                   	push   %eax
  801997:	e8 8f f3 ff ff       	call   800d2b <fd_alloc>
  80199c:	83 c4 10             	add    $0x10,%esp
		return r;
  80199f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a1:	85 c0                	test   %eax,%eax
  8019a3:	78 3e                	js     8019e3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019a5:	83 ec 04             	sub    $0x4,%esp
  8019a8:	68 07 04 00 00       	push   $0x407
  8019ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b0:	6a 00                	push   $0x0
  8019b2:	e8 5c f1 ff ff       	call   800b13 <sys_page_alloc>
  8019b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ba:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 23                	js     8019e3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019c0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	50                   	push   %eax
  8019d9:	e8 26 f3 ff ff       	call   800d04 <fd2num>
  8019de:	89 c2                	mov    %eax,%edx
  8019e0:	83 c4 10             	add    $0x10,%esp
}
  8019e3:	89 d0                	mov    %edx,%eax
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019ec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019ef:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8019f5:	e8 db f0 ff ff       	call   800ad5 <sys_getenvid>
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 0c             	pushl  0xc(%ebp)
  801a00:	ff 75 08             	pushl  0x8(%ebp)
  801a03:	56                   	push   %esi
  801a04:	50                   	push   %eax
  801a05:	68 38 22 80 00       	push   $0x802238
  801a0a:	e8 32 e7 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a0f:	83 c4 18             	add    $0x18,%esp
  801a12:	53                   	push   %ebx
  801a13:	ff 75 10             	pushl  0x10(%ebp)
  801a16:	e8 d5 e6 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801a1b:	c7 04 24 23 22 80 00 	movl   $0x802223,(%esp)
  801a22:	e8 1a e7 ff ff       	call   800141 <cprintf>
  801a27:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a2a:	cc                   	int3   
  801a2b:	eb fd                	jmp    801a2a <_panic+0x43>

00801a2d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a35:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 0c             	pushl  0xc(%ebp)
  801a3e:	e8 80 f2 ff ff       	call   800cc3 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 f6                	test   %esi,%esi
  801a48:	74 1c                	je     801a66 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4f:	8b 40 78             	mov    0x78(%eax),%eax
  801a52:	89 06                	mov    %eax,(%esi)
  801a54:	eb 10                	jmp    801a66 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	68 5c 22 80 00       	push   $0x80225c
  801a5e:	e8 de e6 ff ff       	call   800141 <cprintf>
  801a63:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 50 74             	mov    0x74(%eax),%edx
  801a6e:	85 d2                	test   %edx,%edx
  801a70:	74 e4                	je     801a56 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a72:	85 db                	test   %ebx,%ebx
  801a74:	74 05                	je     801a7b <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a76:	8b 40 74             	mov    0x74(%eax),%eax
  801a79:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a80:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	57                   	push   %edi
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a96:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801a9c:	85 db                	test   %ebx,%ebx
  801a9e:	75 13                	jne    801ab3 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801aa0:	6a 00                	push   $0x0
  801aa2:	68 00 00 c0 ee       	push   $0xeec00000
  801aa7:	56                   	push   %esi
  801aa8:	57                   	push   %edi
  801aa9:	e8 f2 f1 ff ff       	call   800ca0 <sys_ipc_try_send>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	eb 0e                	jmp    801ac1 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ab3:	ff 75 14             	pushl  0x14(%ebp)
  801ab6:	53                   	push   %ebx
  801ab7:	56                   	push   %esi
  801ab8:	57                   	push   %edi
  801ab9:	e8 e2 f1 ff ff       	call   800ca0 <sys_ipc_try_send>
  801abe:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	75 d7                	jne    801a9c <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac8:	5b                   	pop    %ebx
  801ac9:	5e                   	pop    %esi
  801aca:	5f                   	pop    %edi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801adb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae1:	8b 52 50             	mov    0x50(%edx),%edx
  801ae4:	39 ca                	cmp    %ecx,%edx
  801ae6:	75 0d                	jne    801af5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aeb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af0:	8b 40 48             	mov    0x48(%eax),%eax
  801af3:	eb 0f                	jmp    801b04 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af5:	83 c0 01             	add    $0x1,%eax
  801af8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801afd:	75 d9                	jne    801ad8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	89 d0                	mov    %edx,%eax
  801b0e:	c1 e8 16             	shr    $0x16,%eax
  801b11:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1d:	f6 c1 01             	test   $0x1,%cl
  801b20:	74 1d                	je     801b3f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b22:	c1 ea 0c             	shr    $0xc,%edx
  801b25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2c:	f6 c2 01             	test   $0x1,%dl
  801b2f:	74 0e                	je     801b3f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b31:	c1 ea 0c             	shr    $0xc,%edx
  801b34:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3b:	ef 
  801b3c:	0f b7 c0             	movzwl %ax,%eax
}
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    
  801b41:	66 90                	xchg   %ax,%ax
  801b43:	66 90                	xchg   %ax,%ax
  801b45:	66 90                	xchg   %ax,%ax
  801b47:	66 90                	xchg   %ax,%ax
  801b49:	66 90                	xchg   %ax,%ax
  801b4b:	66 90                	xchg   %ax,%ax
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 1c             	sub    $0x1c,%esp
  801b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b67:	85 f6                	test   %esi,%esi
  801b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b6d:	89 ca                	mov    %ecx,%edx
  801b6f:	89 f8                	mov    %edi,%eax
  801b71:	75 3d                	jne    801bb0 <__udivdi3+0x60>
  801b73:	39 cf                	cmp    %ecx,%edi
  801b75:	0f 87 c5 00 00 00    	ja     801c40 <__udivdi3+0xf0>
  801b7b:	85 ff                	test   %edi,%edi
  801b7d:	89 fd                	mov    %edi,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f7                	div    %edi
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 c8                	mov    %ecx,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c1                	mov    %eax,%ecx
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	89 cf                	mov    %ecx,%edi
  801b98:	f7 f5                	div    %ebp
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	89 d8                	mov    %ebx,%eax
  801b9e:	89 fa                	mov    %edi,%edx
  801ba0:	83 c4 1c             	add    $0x1c,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
  801ba8:	90                   	nop
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	39 ce                	cmp    %ecx,%esi
  801bb2:	77 74                	ja     801c28 <__udivdi3+0xd8>
  801bb4:	0f bd fe             	bsr    %esi,%edi
  801bb7:	83 f7 1f             	xor    $0x1f,%edi
  801bba:	0f 84 98 00 00 00    	je     801c58 <__udivdi3+0x108>
  801bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	89 c5                	mov    %eax,%ebp
  801bc9:	29 fb                	sub    %edi,%ebx
  801bcb:	d3 e6                	shl    %cl,%esi
  801bcd:	89 d9                	mov    %ebx,%ecx
  801bcf:	d3 ed                	shr    %cl,%ebp
  801bd1:	89 f9                	mov    %edi,%ecx
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	09 ee                	or     %ebp,%esi
  801bd7:	89 d9                	mov    %ebx,%ecx
  801bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdd:	89 d5                	mov    %edx,%ebp
  801bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801be3:	d3 ed                	shr    %cl,%ebp
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e2                	shl    %cl,%edx
  801be9:	89 d9                	mov    %ebx,%ecx
  801beb:	d3 e8                	shr    %cl,%eax
  801bed:	09 c2                	or     %eax,%edx
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	89 ea                	mov    %ebp,%edx
  801bf3:	f7 f6                	div    %esi
  801bf5:	89 d5                	mov    %edx,%ebp
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	f7 64 24 0c          	mull   0xc(%esp)
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	72 10                	jb     801c11 <__udivdi3+0xc1>
  801c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	d3 e6                	shl    %cl,%esi
  801c09:	39 c6                	cmp    %eax,%esi
  801c0b:	73 07                	jae    801c14 <__udivdi3+0xc4>
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	75 03                	jne    801c14 <__udivdi3+0xc4>
  801c11:	83 eb 01             	sub    $0x1,%ebx
  801c14:	31 ff                	xor    %edi,%edi
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	89 fa                	mov    %edi,%edx
  801c1a:	83 c4 1c             	add    $0x1c,%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    
  801c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c28:	31 ff                	xor    %edi,%edi
  801c2a:	31 db                	xor    %ebx,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	f7 f7                	div    %edi
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	89 d8                	mov    %ebx,%eax
  801c4a:	89 fa                	mov    %edi,%edx
  801c4c:	83 c4 1c             	add    $0x1c,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5f                   	pop    %edi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	39 ce                	cmp    %ecx,%esi
  801c5a:	72 0c                	jb     801c68 <__udivdi3+0x118>
  801c5c:	31 db                	xor    %ebx,%ebx
  801c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c62:	0f 87 34 ff ff ff    	ja     801b9c <__udivdi3+0x4c>
  801c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c6d:	e9 2a ff ff ff       	jmp    801b9c <__udivdi3+0x4c>
  801c72:	66 90                	xchg   %ax,%ax
  801c74:	66 90                	xchg   %ax,%ax
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 d2                	test   %edx,%edx
  801c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ca1:	89 f3                	mov    %esi,%ebx
  801ca3:	89 3c 24             	mov    %edi,(%esp)
  801ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801caa:	75 1c                	jne    801cc8 <__umoddi3+0x48>
  801cac:	39 f7                	cmp    %esi,%edi
  801cae:	76 50                	jbe    801d00 <__umoddi3+0x80>
  801cb0:	89 c8                	mov    %ecx,%eax
  801cb2:	89 f2                	mov    %esi,%edx
  801cb4:	f7 f7                	div    %edi
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	31 d2                	xor    %edx,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	77 52                	ja     801d20 <__umoddi3+0xa0>
  801cce:	0f bd ea             	bsr    %edx,%ebp
  801cd1:	83 f5 1f             	xor    $0x1f,%ebp
  801cd4:	75 5a                	jne    801d30 <__umoddi3+0xb0>
  801cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	39 0c 24             	cmp    %ecx,(%esp)
  801ce3:	0f 86 d7 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	85 ff                	test   %edi,%edi
  801d02:	89 fd                	mov    %edi,%ebp
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 c8                	mov    %ecx,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	eb 99                	jmp    801cb8 <__umoddi3+0x38>
  801d1f:	90                   	nop
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 1c             	add    $0x1c,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	8b 34 24             	mov    (%esp),%esi
  801d33:	bf 20 00 00 00       	mov    $0x20,%edi
  801d38:	89 e9                	mov    %ebp,%ecx
  801d3a:	29 ef                	sub    %ebp,%edi
  801d3c:	d3 e0                	shl    %cl,%eax
  801d3e:	89 f9                	mov    %edi,%ecx
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	d3 ea                	shr    %cl,%edx
  801d44:	89 e9                	mov    %ebp,%ecx
  801d46:	09 c2                	or     %eax,%edx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 14 24             	mov    %edx,(%esp)
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	d3 e2                	shl    %cl,%edx
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	89 c6                	mov    %eax,%esi
  801d61:	d3 e3                	shl    %cl,%ebx
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 d0                	mov    %edx,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	09 d8                	or     %ebx,%eax
  801d6d:	89 d3                	mov    %edx,%ebx
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	f7 34 24             	divl   (%esp)
  801d74:	89 d6                	mov    %edx,%esi
  801d76:	d3 e3                	shl    %cl,%ebx
  801d78:	f7 64 24 04          	mull   0x4(%esp)
  801d7c:	39 d6                	cmp    %edx,%esi
  801d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d82:	89 d1                	mov    %edx,%ecx
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	72 08                	jb     801d90 <__umoddi3+0x110>
  801d88:	75 11                	jne    801d9b <__umoddi3+0x11b>
  801d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d8e:	73 0b                	jae    801d9b <__umoddi3+0x11b>
  801d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d94:	1b 14 24             	sbb    (%esp),%edx
  801d97:	89 d1                	mov    %edx,%ecx
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d9f:	29 da                	sub    %ebx,%edx
  801da1:	19 ce                	sbb    %ecx,%esi
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	d3 e0                	shl    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	d3 ea                	shr    %cl,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 ee                	shr    %cl,%esi
  801db1:	09 d0                	or     %edx,%eax
  801db3:	89 f2                	mov    %esi,%edx
  801db5:	83 c4 1c             	add    $0x1c,%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 f9                	sub    %edi,%ecx
  801dc2:	19 d6                	sbb    %edx,%esi
  801dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dcc:	e9 18 ff ff ff       	jmp    801ce9 <__umoddi3+0x69>
