
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp

	cprintf("hello, world\n");
  800039:	68 00 1e 80 00       	push   $0x801e00
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 0e 1e 80 00       	push   $0x801e0e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>

}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 77 0a 00 00       	call   800ae5 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 30 0e 00 00       	call   800edf <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 eb 09 00 00       	call   800aa4 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 79 09 00 00       	call   800a67 <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 54 01 00 00       	call   800288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 1e 09 00 00       	call   800a67 <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 a7 19 00 00       	call   801b60 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 94 1a 00 00       	call   801c90 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 2f 1e 80 00 	movsbl 0x801e2f(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800217:	83 fa 01             	cmp    $0x1,%edx
  80021a:	7e 0e                	jle    80022a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021c:	8b 10                	mov    (%eax),%edx
  80021e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800221:	89 08                	mov    %ecx,(%eax)
  800223:	8b 02                	mov    (%edx),%eax
  800225:	8b 52 04             	mov    0x4(%edx),%edx
  800228:	eb 22                	jmp    80024c <getuint+0x38>
	else if (lflag)
  80022a:	85 d2                	test   %edx,%edx
  80022c:	74 10                	je     80023e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022e:	8b 10                	mov    (%eax),%edx
  800230:	8d 4a 04             	lea    0x4(%edx),%ecx
  800233:	89 08                	mov    %ecx,(%eax)
  800235:	8b 02                	mov    (%edx),%eax
  800237:	ba 00 00 00 00       	mov    $0x0,%edx
  80023c:	eb 0e                	jmp    80024c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023e:	8b 10                	mov    (%eax),%edx
  800240:	8d 4a 04             	lea    0x4(%edx),%ecx
  800243:	89 08                	mov    %ecx,(%eax)
  800245:	8b 02                	mov    (%edx),%eax
  800247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	3b 50 04             	cmp    0x4(%eax),%edx
  80025d:	73 0a                	jae    800269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800262:	89 08                	mov    %ecx,(%eax)
  800264:	8b 45 08             	mov    0x8(%ebp),%eax
  800267:	88 02                	mov    %al,(%edx)
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	ff 75 0c             	pushl  0xc(%ebp)
  80027b:	ff 75 08             	pushl  0x8(%ebp)
  80027e:	e8 05 00 00 00       	call   800288 <vprintfmt>
	va_end(ap);
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	57                   	push   %edi
  80028c:	56                   	push   %esi
  80028d:	53                   	push   %ebx
  80028e:	83 ec 2c             	sub    $0x2c,%esp
  800291:	8b 75 08             	mov    0x8(%ebp),%esi
  800294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029a:	eb 12                	jmp    8002ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029c:	85 c0                	test   %eax,%eax
  80029e:	0f 84 d3 03 00 00    	je     800677 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	53                   	push   %ebx
  8002a8:	50                   	push   %eax
  8002a9:	ff d6                	call   *%esi
  8002ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ae:	83 c7 01             	add    $0x1,%edi
  8002b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b5:	83 f8 25             	cmp    $0x25,%eax
  8002b8:	75 e2                	jne    80029c <vprintfmt+0x14>
  8002ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c5:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	eb 07                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 07             	movzbl (%edi),%eax
  8002ea:	0f b6 c8             	movzbl %al,%ecx
  8002ed:	83 e8 23             	sub    $0x23,%eax
  8002f0:	3c 55                	cmp    $0x55,%al
  8002f2:	0f 87 64 03 00 00    	ja     80065c <vprintfmt+0x3d4>
  8002f8:	0f b6 c0             	movzbl %al,%eax
  8002fb:	ff 24 85 80 1f 80 00 	jmp    *0x801f80(,%eax,4)
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800305:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800309:	eb d6                	jmp    8002e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030e:	b8 00 00 00 00       	mov    $0x0,%eax
  800313:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800316:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800319:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800320:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800323:	83 fa 09             	cmp    $0x9,%edx
  800326:	77 39                	ja     800361 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800328:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032b:	eb e9                	jmp    800316 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032d:	8b 45 14             	mov    0x14(%ebp),%eax
  800330:	8d 48 04             	lea    0x4(%eax),%ecx
  800333:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800336:	8b 00                	mov    (%eax),%eax
  800338:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80033e:	eb 27                	jmp    800367 <vprintfmt+0xdf>
  800340:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800343:	85 c0                	test   %eax,%eax
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034a:	0f 49 c8             	cmovns %eax,%ecx
  80034d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	eb 8c                	jmp    8002e1 <vprintfmt+0x59>
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800358:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035f:	eb 80                	jmp    8002e1 <vprintfmt+0x59>
  800361:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800364:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036b:	0f 89 70 ff ff ff    	jns    8002e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800371:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800374:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800377:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80037e:	e9 5e ff ff ff       	jmp    8002e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800383:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800389:	e9 53 ff ff ff       	jmp    8002e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8d 50 04             	lea    0x4(%eax),%edx
  800394:	89 55 14             	mov    %edx,0x14(%ebp)
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	53                   	push   %ebx
  80039b:	ff 30                	pushl  (%eax)
  80039d:	ff d6                	call   *%esi
			break;
  80039f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a5:	e9 04 ff ff ff       	jmp    8002ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 50 04             	lea    0x4(%eax),%edx
  8003b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b3:	8b 00                	mov    (%eax),%eax
  8003b5:	99                   	cltd   
  8003b6:	31 d0                	xor    %edx,%eax
  8003b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ba:	83 f8 0f             	cmp    $0xf,%eax
  8003bd:	7f 0b                	jg     8003ca <vprintfmt+0x142>
  8003bf:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  8003c6:	85 d2                	test   %edx,%edx
  8003c8:	75 18                	jne    8003e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ca:	50                   	push   %eax
  8003cb:	68 47 1e 80 00       	push   $0x801e47
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 94 fe ff ff       	call   80026b <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003dd:	e9 cc fe ff ff       	jmp    8002ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e2:	52                   	push   %edx
  8003e3:	68 11 22 80 00       	push   $0x802211
  8003e8:	53                   	push   %ebx
  8003e9:	56                   	push   %esi
  8003ea:	e8 7c fe ff ff       	call   80026b <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	e9 b4 fe ff ff       	jmp    8002ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 50 04             	lea    0x4(%eax),%edx
  800400:	89 55 14             	mov    %edx,0x14(%ebp)
  800403:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800405:	85 ff                	test   %edi,%edi
  800407:	b8 40 1e 80 00       	mov    $0x801e40,%eax
  80040c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80040f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800413:	0f 8e 94 00 00 00    	jle    8004ad <vprintfmt+0x225>
  800419:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041d:	0f 84 98 00 00 00    	je     8004bb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	ff 75 c8             	pushl  -0x38(%ebp)
  800429:	57                   	push   %edi
  80042a:	e8 d0 02 00 00       	call   8006ff <strnlen>
  80042f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800432:	29 c1                	sub    %eax,%ecx
  800434:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800437:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800441:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800444:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	eb 0f                	jmp    800457 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	53                   	push   %ebx
  80044c:	ff 75 e0             	pushl  -0x20(%ebp)
  80044f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ef 01             	sub    $0x1,%edi
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	85 ff                	test   %edi,%edi
  800459:	7f ed                	jg     800448 <vprintfmt+0x1c0>
  80045b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800461:	85 c9                	test   %ecx,%ecx
  800463:	b8 00 00 00 00       	mov    $0x0,%eax
  800468:	0f 49 c1             	cmovns %ecx,%eax
  80046b:	29 c1                	sub    %eax,%ecx
  80046d:	89 75 08             	mov    %esi,0x8(%ebp)
  800470:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800473:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800476:	89 cb                	mov    %ecx,%ebx
  800478:	eb 4d                	jmp    8004c7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047e:	74 1b                	je     80049b <vprintfmt+0x213>
  800480:	0f be c0             	movsbl %al,%eax
  800483:	83 e8 20             	sub    $0x20,%eax
  800486:	83 f8 5e             	cmp    $0x5e,%eax
  800489:	76 10                	jbe    80049b <vprintfmt+0x213>
					putch('?', putdat);
  80048b:	83 ec 08             	sub    $0x8,%esp
  80048e:	ff 75 0c             	pushl  0xc(%ebp)
  800491:	6a 3f                	push   $0x3f
  800493:	ff 55 08             	call   *0x8(%ebp)
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	eb 0d                	jmp    8004a8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	52                   	push   %edx
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a8:	83 eb 01             	sub    $0x1,%ebx
  8004ab:	eb 1a                	jmp    8004c7 <vprintfmt+0x23f>
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b9:	eb 0c                	jmp    8004c7 <vprintfmt+0x23f>
  8004bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004be:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c7:	83 c7 01             	add    $0x1,%edi
  8004ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ce:	0f be d0             	movsbl %al,%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	74 23                	je     8004f8 <vprintfmt+0x270>
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	78 a1                	js     80047a <vprintfmt+0x1f2>
  8004d9:	83 ee 01             	sub    $0x1,%esi
  8004dc:	79 9c                	jns    80047a <vprintfmt+0x1f2>
  8004de:	89 df                	mov    %ebx,%edi
  8004e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e6:	eb 18                	jmp    800500 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	6a 20                	push   $0x20
  8004ee:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb 08                	jmp    800500 <vprintfmt+0x278>
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800500:	85 ff                	test   %edi,%edi
  800502:	7f e4                	jg     8004e8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800507:	e9 a2 fd ff ff       	jmp    8002ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050c:	83 fa 01             	cmp    $0x1,%edx
  80050f:	7e 16                	jle    800527 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 50 08             	lea    0x8(%eax),%edx
  800517:	89 55 14             	mov    %edx,0x14(%ebp)
  80051a:	8b 50 04             	mov    0x4(%eax),%edx
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800522:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800525:	eb 32                	jmp    800559 <vprintfmt+0x2d1>
	else if (lflag)
  800527:	85 d2                	test   %edx,%edx
  800529:	74 18                	je     800543 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800539:	89 c1                	mov    %eax,%ecx
  80053b:	c1 f9 1f             	sar    $0x1f,%ecx
  80053e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800541:	eb 16                	jmp    800559 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800559:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80055c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80055f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800562:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800565:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80056e:	0f 89 b0 00 00 00    	jns    800624 <vprintfmt+0x39c>
				putch('-', putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	53                   	push   %ebx
  800578:	6a 2d                	push   $0x2d
  80057a:	ff d6                	call   *%esi
				num = -(long long) num;
  80057c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800582:	f7 d8                	neg    %eax
  800584:	83 d2 00             	adc    $0x0,%edx
  800587:	f7 da                	neg    %edx
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 88 00 00 00       	jmp    800624 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059c:	8d 45 14             	lea    0x14(%ebp),%eax
  80059f:	e8 70 fc ff ff       	call   800214 <getuint>
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005af:	eb 73                	jmp    800624 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b4:	e8 5b fc ff ff       	call   800214 <getuint>
  8005b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	6a 58                	push   $0x58
  8005c5:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c7:	83 c4 08             	add    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 58                	push   $0x58
  8005cd:	ff d6                	call   *%esi
			putch('X', putdat);
  8005cf:	83 c4 08             	add    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 58                	push   $0x58
  8005d5:	ff d6                	call   *%esi
			goto number;
  8005d7:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005da:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005df:	eb 43                	jmp    800624 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	6a 30                	push   $0x30
  8005e7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e9:	83 c4 08             	add    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	6a 78                	push   $0x78
  8005ef:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 04             	lea    0x4(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800607:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060f:	eb 13                	jmp    800624 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 fb fb ff ff       	call   800214 <getuint>
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80061f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80062b:	52                   	push   %edx
  80062c:	ff 75 e0             	pushl  -0x20(%ebp)
  80062f:	50                   	push   %eax
  800630:	ff 75 dc             	pushl  -0x24(%ebp)
  800633:	ff 75 d8             	pushl  -0x28(%ebp)
  800636:	89 da                	mov    %ebx,%edx
  800638:	89 f0                	mov    %esi,%eax
  80063a:	e8 26 fb ff ff       	call   800165 <printnum>
			break;
  80063f:	83 c4 20             	add    $0x20,%esp
  800642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800645:	e9 64 fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	51                   	push   %ecx
  80064f:	ff d6                	call   *%esi
			break;
  800651:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800657:	e9 52 fc ff ff       	jmp    8002ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	6a 25                	push   $0x25
  800662:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	eb 03                	jmp    80066c <vprintfmt+0x3e4>
  800669:	83 ef 01             	sub    $0x1,%edi
  80066c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800670:	75 f7                	jne    800669 <vprintfmt+0x3e1>
  800672:	e9 37 fc ff ff       	jmp    8002ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800677:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067a:	5b                   	pop    %ebx
  80067b:	5e                   	pop    %esi
  80067c:	5f                   	pop    %edi
  80067d:	5d                   	pop    %ebp
  80067e:	c3                   	ret    

0080067f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	83 ec 18             	sub    $0x18,%esp
  800685:	8b 45 08             	mov    0x8(%ebp),%eax
  800688:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800692:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800695:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069c:	85 c0                	test   %eax,%eax
  80069e:	74 26                	je     8006c6 <vsnprintf+0x47>
  8006a0:	85 d2                	test   %edx,%edx
  8006a2:	7e 22                	jle    8006c6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a4:	ff 75 14             	pushl  0x14(%ebp)
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ad:	50                   	push   %eax
  8006ae:	68 4e 02 80 00       	push   $0x80024e
  8006b3:	e8 d0 fb ff ff       	call   800288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 05                	jmp    8006cb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    

008006cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d6:	50                   	push   %eax
  8006d7:	ff 75 10             	pushl  0x10(%ebp)
  8006da:	ff 75 0c             	pushl  0xc(%ebp)
  8006dd:	ff 75 08             	pushl  0x8(%ebp)
  8006e0:	e8 9a ff ff ff       	call   80067f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e5:	c9                   	leave  
  8006e6:	c3                   	ret    

008006e7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e7:	55                   	push   %ebp
  8006e8:	89 e5                	mov    %esp,%ebp
  8006ea:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f2:	eb 03                	jmp    8006f7 <strlen+0x10>
		n++;
  8006f4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fb:	75 f7                	jne    8006f4 <strlen+0xd>
		n++;
	return n;
}
  8006fd:	5d                   	pop    %ebp
  8006fe:	c3                   	ret    

008006ff <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800705:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800708:	ba 00 00 00 00       	mov    $0x0,%edx
  80070d:	eb 03                	jmp    800712 <strnlen+0x13>
		n++;
  80070f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800712:	39 c2                	cmp    %eax,%edx
  800714:	74 08                	je     80071e <strnlen+0x1f>
  800716:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80071a:	75 f3                	jne    80070f <strnlen+0x10>
  80071c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072a:	89 c2                	mov    %eax,%edx
  80072c:	83 c2 01             	add    $0x1,%edx
  80072f:	83 c1 01             	add    $0x1,%ecx
  800732:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800736:	88 5a ff             	mov    %bl,-0x1(%edx)
  800739:	84 db                	test   %bl,%bl
  80073b:	75 ef                	jne    80072c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073d:	5b                   	pop    %ebx
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	53                   	push   %ebx
  800744:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800747:	53                   	push   %ebx
  800748:	e8 9a ff ff ff       	call   8006e7 <strlen>
  80074d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	01 d8                	add    %ebx,%eax
  800755:	50                   	push   %eax
  800756:	e8 c5 ff ff ff       	call   800720 <strcpy>
	return dst;
}
  80075b:	89 d8                	mov    %ebx,%eax
  80075d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	56                   	push   %esi
  800766:	53                   	push   %ebx
  800767:	8b 75 08             	mov    0x8(%ebp),%esi
  80076a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076d:	89 f3                	mov    %esi,%ebx
  80076f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800772:	89 f2                	mov    %esi,%edx
  800774:	eb 0f                	jmp    800785 <strncpy+0x23>
		*dst++ = *src;
  800776:	83 c2 01             	add    $0x1,%edx
  800779:	0f b6 01             	movzbl (%ecx),%eax
  80077c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077f:	80 39 01             	cmpb   $0x1,(%ecx)
  800782:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800785:	39 da                	cmp    %ebx,%edx
  800787:	75 ed                	jne    800776 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800789:	89 f0                	mov    %esi,%eax
  80078b:	5b                   	pop    %ebx
  80078c:	5e                   	pop    %esi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	56                   	push   %esi
  800793:	53                   	push   %ebx
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079a:	8b 55 10             	mov    0x10(%ebp),%edx
  80079d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079f:	85 d2                	test   %edx,%edx
  8007a1:	74 21                	je     8007c4 <strlcpy+0x35>
  8007a3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a7:	89 f2                	mov    %esi,%edx
  8007a9:	eb 09                	jmp    8007b4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ab:	83 c2 01             	add    $0x1,%edx
  8007ae:	83 c1 01             	add    $0x1,%ecx
  8007b1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b4:	39 c2                	cmp    %eax,%edx
  8007b6:	74 09                	je     8007c1 <strlcpy+0x32>
  8007b8:	0f b6 19             	movzbl (%ecx),%ebx
  8007bb:	84 db                	test   %bl,%bl
  8007bd:	75 ec                	jne    8007ab <strlcpy+0x1c>
  8007bf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c4:	29 f0                	sub    %esi,%eax
}
  8007c6:	5b                   	pop    %ebx
  8007c7:	5e                   	pop    %esi
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d3:	eb 06                	jmp    8007db <strcmp+0x11>
		p++, q++;
  8007d5:	83 c1 01             	add    $0x1,%ecx
  8007d8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007db:	0f b6 01             	movzbl (%ecx),%eax
  8007de:	84 c0                	test   %al,%al
  8007e0:	74 04                	je     8007e6 <strcmp+0x1c>
  8007e2:	3a 02                	cmp    (%edx),%al
  8007e4:	74 ef                	je     8007d5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e6:	0f b6 c0             	movzbl %al,%eax
  8007e9:	0f b6 12             	movzbl (%edx),%edx
  8007ec:	29 d0                	sub    %edx,%eax
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	89 c3                	mov    %eax,%ebx
  8007fc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007ff:	eb 06                	jmp    800807 <strncmp+0x17>
		n--, p++, q++;
  800801:	83 c0 01             	add    $0x1,%eax
  800804:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800807:	39 d8                	cmp    %ebx,%eax
  800809:	74 15                	je     800820 <strncmp+0x30>
  80080b:	0f b6 08             	movzbl (%eax),%ecx
  80080e:	84 c9                	test   %cl,%cl
  800810:	74 04                	je     800816 <strncmp+0x26>
  800812:	3a 0a                	cmp    (%edx),%cl
  800814:	74 eb                	je     800801 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800816:	0f b6 00             	movzbl (%eax),%eax
  800819:	0f b6 12             	movzbl (%edx),%edx
  80081c:	29 d0                	sub    %edx,%eax
  80081e:	eb 05                	jmp    800825 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800825:	5b                   	pop    %ebx
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800832:	eb 07                	jmp    80083b <strchr+0x13>
		if (*s == c)
  800834:	38 ca                	cmp    %cl,%dl
  800836:	74 0f                	je     800847 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800838:	83 c0 01             	add    $0x1,%eax
  80083b:	0f b6 10             	movzbl (%eax),%edx
  80083e:	84 d2                	test   %dl,%dl
  800840:	75 f2                	jne    800834 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800853:	eb 03                	jmp    800858 <strfind+0xf>
  800855:	83 c0 01             	add    $0x1,%eax
  800858:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085b:	38 ca                	cmp    %cl,%dl
  80085d:	74 04                	je     800863 <strfind+0x1a>
  80085f:	84 d2                	test   %dl,%dl
  800861:	75 f2                	jne    800855 <strfind+0xc>
			break;
	return (char *) s;
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	57                   	push   %edi
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800871:	85 c9                	test   %ecx,%ecx
  800873:	74 36                	je     8008ab <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800875:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087b:	75 28                	jne    8008a5 <memset+0x40>
  80087d:	f6 c1 03             	test   $0x3,%cl
  800880:	75 23                	jne    8008a5 <memset+0x40>
		c &= 0xFF;
  800882:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800886:	89 d3                	mov    %edx,%ebx
  800888:	c1 e3 08             	shl    $0x8,%ebx
  80088b:	89 d6                	mov    %edx,%esi
  80088d:	c1 e6 18             	shl    $0x18,%esi
  800890:	89 d0                	mov    %edx,%eax
  800892:	c1 e0 10             	shl    $0x10,%eax
  800895:	09 f0                	or     %esi,%eax
  800897:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800899:	89 d8                	mov    %ebx,%eax
  80089b:	09 d0                	or     %edx,%eax
  80089d:	c1 e9 02             	shr    $0x2,%ecx
  8008a0:	fc                   	cld    
  8008a1:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a3:	eb 06                	jmp    8008ab <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a8:	fc                   	cld    
  8008a9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ab:	89 f8                	mov    %edi,%eax
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5f                   	pop    %edi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	57                   	push   %edi
  8008b6:	56                   	push   %esi
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c0:	39 c6                	cmp    %eax,%esi
  8008c2:	73 35                	jae    8008f9 <memmove+0x47>
  8008c4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c7:	39 d0                	cmp    %edx,%eax
  8008c9:	73 2e                	jae    8008f9 <memmove+0x47>
		s += n;
		d += n;
  8008cb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ce:	89 d6                	mov    %edx,%esi
  8008d0:	09 fe                	or     %edi,%esi
  8008d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d8:	75 13                	jne    8008ed <memmove+0x3b>
  8008da:	f6 c1 03             	test   $0x3,%cl
  8008dd:	75 0e                	jne    8008ed <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008df:	83 ef 04             	sub    $0x4,%edi
  8008e2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e5:	c1 e9 02             	shr    $0x2,%ecx
  8008e8:	fd                   	std    
  8008e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008eb:	eb 09                	jmp    8008f6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ed:	83 ef 01             	sub    $0x1,%edi
  8008f0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f3:	fd                   	std    
  8008f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f6:	fc                   	cld    
  8008f7:	eb 1d                	jmp    800916 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f9:	89 f2                	mov    %esi,%edx
  8008fb:	09 c2                	or     %eax,%edx
  8008fd:	f6 c2 03             	test   $0x3,%dl
  800900:	75 0f                	jne    800911 <memmove+0x5f>
  800902:	f6 c1 03             	test   $0x3,%cl
  800905:	75 0a                	jne    800911 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800907:	c1 e9 02             	shr    $0x2,%ecx
  80090a:	89 c7                	mov    %eax,%edi
  80090c:	fc                   	cld    
  80090d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090f:	eb 05                	jmp    800916 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800911:	89 c7                	mov    %eax,%edi
  800913:	fc                   	cld    
  800914:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091d:	ff 75 10             	pushl  0x10(%ebp)
  800920:	ff 75 0c             	pushl  0xc(%ebp)
  800923:	ff 75 08             	pushl  0x8(%ebp)
  800926:	e8 87 ff ff ff       	call   8008b2 <memmove>
}
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    

0080092d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	56                   	push   %esi
  800931:	53                   	push   %ebx
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 55 0c             	mov    0xc(%ebp),%edx
  800938:	89 c6                	mov    %eax,%esi
  80093a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093d:	eb 1a                	jmp    800959 <memcmp+0x2c>
		if (*s1 != *s2)
  80093f:	0f b6 08             	movzbl (%eax),%ecx
  800942:	0f b6 1a             	movzbl (%edx),%ebx
  800945:	38 d9                	cmp    %bl,%cl
  800947:	74 0a                	je     800953 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800949:	0f b6 c1             	movzbl %cl,%eax
  80094c:	0f b6 db             	movzbl %bl,%ebx
  80094f:	29 d8                	sub    %ebx,%eax
  800951:	eb 0f                	jmp    800962 <memcmp+0x35>
		s1++, s2++;
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800959:	39 f0                	cmp    %esi,%eax
  80095b:	75 e2                	jne    80093f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800962:	5b                   	pop    %ebx
  800963:	5e                   	pop    %esi
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096d:	89 c1                	mov    %eax,%ecx
  80096f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800972:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800976:	eb 0a                	jmp    800982 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800978:	0f b6 10             	movzbl (%eax),%edx
  80097b:	39 da                	cmp    %ebx,%edx
  80097d:	74 07                	je     800986 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097f:	83 c0 01             	add    $0x1,%eax
  800982:	39 c8                	cmp    %ecx,%eax
  800984:	72 f2                	jb     800978 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800986:	5b                   	pop    %ebx
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	57                   	push   %edi
  80098d:	56                   	push   %esi
  80098e:	53                   	push   %ebx
  80098f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800992:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800995:	eb 03                	jmp    80099a <strtol+0x11>
		s++;
  800997:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099a:	0f b6 01             	movzbl (%ecx),%eax
  80099d:	3c 20                	cmp    $0x20,%al
  80099f:	74 f6                	je     800997 <strtol+0xe>
  8009a1:	3c 09                	cmp    $0x9,%al
  8009a3:	74 f2                	je     800997 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a5:	3c 2b                	cmp    $0x2b,%al
  8009a7:	75 0a                	jne    8009b3 <strtol+0x2a>
		s++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b1:	eb 11                	jmp    8009c4 <strtol+0x3b>
  8009b3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b8:	3c 2d                	cmp    $0x2d,%al
  8009ba:	75 08                	jne    8009c4 <strtol+0x3b>
		s++, neg = 1;
  8009bc:	83 c1 01             	add    $0x1,%ecx
  8009bf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ca:	75 15                	jne    8009e1 <strtol+0x58>
  8009cc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cf:	75 10                	jne    8009e1 <strtol+0x58>
  8009d1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d5:	75 7c                	jne    800a53 <strtol+0xca>
		s += 2, base = 16;
  8009d7:	83 c1 02             	add    $0x2,%ecx
  8009da:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009df:	eb 16                	jmp    8009f7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e1:	85 db                	test   %ebx,%ebx
  8009e3:	75 12                	jne    8009f7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ea:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ed:	75 08                	jne    8009f7 <strtol+0x6e>
		s++, base = 8;
  8009ef:	83 c1 01             	add    $0x1,%ecx
  8009f2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ff:	0f b6 11             	movzbl (%ecx),%edx
  800a02:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a05:	89 f3                	mov    %esi,%ebx
  800a07:	80 fb 09             	cmp    $0x9,%bl
  800a0a:	77 08                	ja     800a14 <strtol+0x8b>
			dig = *s - '0';
  800a0c:	0f be d2             	movsbl %dl,%edx
  800a0f:	83 ea 30             	sub    $0x30,%edx
  800a12:	eb 22                	jmp    800a36 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a14:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a17:	89 f3                	mov    %esi,%ebx
  800a19:	80 fb 19             	cmp    $0x19,%bl
  800a1c:	77 08                	ja     800a26 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1e:	0f be d2             	movsbl %dl,%edx
  800a21:	83 ea 57             	sub    $0x57,%edx
  800a24:	eb 10                	jmp    800a36 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a26:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a29:	89 f3                	mov    %esi,%ebx
  800a2b:	80 fb 19             	cmp    $0x19,%bl
  800a2e:	77 16                	ja     800a46 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a30:	0f be d2             	movsbl %dl,%edx
  800a33:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a36:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a39:	7d 0b                	jge    800a46 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a3b:	83 c1 01             	add    $0x1,%ecx
  800a3e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a42:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a44:	eb b9                	jmp    8009ff <strtol+0x76>

	if (endptr)
  800a46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4a:	74 0d                	je     800a59 <strtol+0xd0>
		*endptr = (char *) s;
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	89 0e                	mov    %ecx,(%esi)
  800a51:	eb 06                	jmp    800a59 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a53:	85 db                	test   %ebx,%ebx
  800a55:	74 98                	je     8009ef <strtol+0x66>
  800a57:	eb 9e                	jmp    8009f7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a59:	89 c2                	mov    %eax,%edx
  800a5b:	f7 da                	neg    %edx
  800a5d:	85 ff                	test   %edi,%edi
  800a5f:	0f 45 c2             	cmovne %edx,%eax
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a75:	8b 55 08             	mov    0x8(%ebp),%edx
  800a78:	89 c3                	mov    %eax,%ebx
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	89 c6                	mov    %eax,%esi
  800a7e:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5f                   	pop    %edi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	57                   	push   %edi
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a90:	b8 01 00 00 00       	mov    $0x1,%eax
  800a95:	89 d1                	mov    %edx,%ecx
  800a97:	89 d3                	mov    %edx,%ebx
  800a99:	89 d7                	mov    %edx,%edi
  800a9b:	89 d6                	mov    %edx,%esi
  800a9d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aba:	89 cb                	mov    %ecx,%ebx
  800abc:	89 cf                	mov    %ecx,%edi
  800abe:	89 ce                	mov    %ecx,%esi
  800ac0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	7e 17                	jle    800add <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac6:	83 ec 0c             	sub    $0xc,%esp
  800ac9:	50                   	push   %eax
  800aca:	6a 03                	push   $0x3
  800acc:	68 3f 21 80 00       	push   $0x80213f
  800ad1:	6a 23                	push   $0x23
  800ad3:	68 5c 21 80 00       	push   $0x80215c
  800ad8:	e8 1a 0f 00 00       	call   8019f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800add:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 02 00 00 00       	mov    $0x2,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_yield>:

void
sys_yield(void)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b2c:	be 00 00 00 00       	mov    $0x0,%esi
  800b31:	b8 04 00 00 00       	mov    $0x4,%eax
  800b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3f:	89 f7                	mov    %esi,%edi
  800b41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	7e 17                	jle    800b5e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	50                   	push   %eax
  800b4b:	6a 04                	push   $0x4
  800b4d:	68 3f 21 80 00       	push   $0x80213f
  800b52:	6a 23                	push   $0x23
  800b54:	68 5c 21 80 00       	push   $0x80215c
  800b59:	e8 99 0e 00 00       	call   8019f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b77:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b80:	8b 75 18             	mov    0x18(%ebp),%esi
  800b83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	7e 17                	jle    800ba0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	50                   	push   %eax
  800b8d:	6a 05                	push   $0x5
  800b8f:	68 3f 21 80 00       	push   $0x80213f
  800b94:	6a 23                	push   $0x23
  800b96:	68 5c 21 80 00       	push   $0x80215c
  800b9b:	e8 57 0e 00 00       	call   8019f7 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	89 df                	mov    %ebx,%edi
  800bc3:	89 de                	mov    %ebx,%esi
  800bc5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7e 17                	jle    800be2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 06                	push   $0x6
  800bd1:	68 3f 21 80 00       	push   $0x80213f
  800bd6:	6a 23                	push   $0x23
  800bd8:	68 5c 21 80 00       	push   $0x80215c
  800bdd:	e8 15 0e 00 00       	call   8019f7 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 08             	mov    0x8(%ebp),%edx
  800c03:	89 df                	mov    %ebx,%edi
  800c05:	89 de                	mov    %ebx,%esi
  800c07:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7e 17                	jle    800c24 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 08                	push   $0x8
  800c13:	68 3f 21 80 00       	push   $0x80213f
  800c18:	6a 23                	push   $0x23
  800c1a:	68 5c 21 80 00       	push   $0x80215c
  800c1f:	e8 d3 0d 00 00       	call   8019f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c42:	8b 55 08             	mov    0x8(%ebp),%edx
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7e 17                	jle    800c66 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 09                	push   $0x9
  800c55:	68 3f 21 80 00       	push   $0x80213f
  800c5a:	6a 23                	push   $0x23
  800c5c:	68 5c 21 80 00       	push   $0x80215c
  800c61:	e8 91 0d 00 00       	call   8019f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	89 df                	mov    %ebx,%edi
  800c89:	89 de                	mov    %ebx,%esi
  800c8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7e 17                	jle    800ca8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	6a 0a                	push   $0xa
  800c97:	68 3f 21 80 00       	push   $0x80213f
  800c9c:	6a 23                	push   $0x23
  800c9e:	68 5c 21 80 00       	push   $0x80215c
  800ca3:	e8 4f 0d 00 00       	call   8019f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb6:	be 00 00 00 00       	mov    $0x0,%esi
  800cbb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	89 cb                	mov    %ecx,%ebx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	89 ce                	mov    %ecx,%esi
  800cef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7e 17                	jle    800d0c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 0d                	push   $0xd
  800cfb:	68 3f 21 80 00       	push   $0x80213f
  800d00:	6a 23                	push   $0x23
  800d02:	68 5c 21 80 00       	push   $0x80215c
  800d07:	e8 eb 0c 00 00       	call   8019f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d17:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1f:	c1 e8 0c             	shr    $0xc,%eax
}
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	05 00 00 00 30       	add    $0x30000000,%eax
  800d2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d34:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d41:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d46:	89 c2                	mov    %eax,%edx
  800d48:	c1 ea 16             	shr    $0x16,%edx
  800d4b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d52:	f6 c2 01             	test   $0x1,%dl
  800d55:	74 11                	je     800d68 <fd_alloc+0x2d>
  800d57:	89 c2                	mov    %eax,%edx
  800d59:	c1 ea 0c             	shr    $0xc,%edx
  800d5c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d63:	f6 c2 01             	test   $0x1,%dl
  800d66:	75 09                	jne    800d71 <fd_alloc+0x36>
			*fd_store = fd;
  800d68:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6f:	eb 17                	jmp    800d88 <fd_alloc+0x4d>
  800d71:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d76:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d7b:	75 c9                	jne    800d46 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d7d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d83:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d90:	83 f8 1f             	cmp    $0x1f,%eax
  800d93:	77 36                	ja     800dcb <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d95:	c1 e0 0c             	shl    $0xc,%eax
  800d98:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	c1 ea 16             	shr    $0x16,%edx
  800da2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da9:	f6 c2 01             	test   $0x1,%dl
  800dac:	74 24                	je     800dd2 <fd_lookup+0x48>
  800dae:	89 c2                	mov    %eax,%edx
  800db0:	c1 ea 0c             	shr    $0xc,%edx
  800db3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dba:	f6 c2 01             	test   $0x1,%dl
  800dbd:	74 1a                	je     800dd9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc2:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc4:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc9:	eb 13                	jmp    800dde <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd0:	eb 0c                	jmp    800dde <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd7:	eb 05                	jmp    800dde <fd_lookup+0x54>
  800dd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 08             	sub    $0x8,%esp
  800de6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de9:	ba e8 21 80 00       	mov    $0x8021e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dee:	eb 13                	jmp    800e03 <dev_lookup+0x23>
  800df0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800df3:	39 08                	cmp    %ecx,(%eax)
  800df5:	75 0c                	jne    800e03 <dev_lookup+0x23>
			*dev = devtab[i];
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800e01:	eb 2e                	jmp    800e31 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e03:	8b 02                	mov    (%edx),%eax
  800e05:	85 c0                	test   %eax,%eax
  800e07:	75 e7                	jne    800df0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e09:	a1 04 40 80 00       	mov    0x804004,%eax
  800e0e:	8b 40 48             	mov    0x48(%eax),%eax
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	51                   	push   %ecx
  800e15:	50                   	push   %eax
  800e16:	68 6c 21 80 00       	push   $0x80216c
  800e1b:	e8 31 f3 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e23:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e31:	c9                   	leave  
  800e32:	c3                   	ret    

00800e33 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 10             	sub    $0x10,%esp
  800e3b:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e44:	50                   	push   %eax
  800e45:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e4b:	c1 e8 0c             	shr    $0xc,%eax
  800e4e:	50                   	push   %eax
  800e4f:	e8 36 ff ff ff       	call   800d8a <fd_lookup>
  800e54:	83 c4 08             	add    $0x8,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	78 05                	js     800e60 <fd_close+0x2d>
	    || fd != fd2)
  800e5b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e5e:	74 0c                	je     800e6c <fd_close+0x39>
		return (must_exist ? r : 0);
  800e60:	84 db                	test   %bl,%bl
  800e62:	ba 00 00 00 00       	mov    $0x0,%edx
  800e67:	0f 44 c2             	cmove  %edx,%eax
  800e6a:	eb 41                	jmp    800ead <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e72:	50                   	push   %eax
  800e73:	ff 36                	pushl  (%esi)
  800e75:	e8 66 ff ff ff       	call   800de0 <dev_lookup>
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	83 c4 10             	add    $0x10,%esp
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	78 1a                	js     800e9d <fd_close+0x6a>
		if (dev->dev_close)
  800e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e86:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e89:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	74 0b                	je     800e9d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	56                   	push   %esi
  800e96:	ff d0                	call   *%eax
  800e98:	89 c3                	mov    %eax,%ebx
  800e9a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	56                   	push   %esi
  800ea1:	6a 00                	push   $0x0
  800ea3:	e8 00 fd ff ff       	call   800ba8 <sys_page_unmap>
	return r;
  800ea8:	83 c4 10             	add    $0x10,%esp
  800eab:	89 d8                	mov    %ebx,%eax
}
  800ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebd:	50                   	push   %eax
  800ebe:	ff 75 08             	pushl  0x8(%ebp)
  800ec1:	e8 c4 fe ff ff       	call   800d8a <fd_lookup>
  800ec6:	83 c4 08             	add    $0x8,%esp
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	78 10                	js     800edd <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ecd:	83 ec 08             	sub    $0x8,%esp
  800ed0:	6a 01                	push   $0x1
  800ed2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed5:	e8 59 ff ff ff       	call   800e33 <fd_close>
  800eda:	83 c4 10             	add    $0x10,%esp
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <close_all>:

void
close_all(void)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eeb:	83 ec 0c             	sub    $0xc,%esp
  800eee:	53                   	push   %ebx
  800eef:	e8 c0 ff ff ff       	call   800eb4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef4:	83 c3 01             	add    $0x1,%ebx
  800ef7:	83 c4 10             	add    $0x10,%esp
  800efa:	83 fb 20             	cmp    $0x20,%ebx
  800efd:	75 ec                	jne    800eeb <close_all+0xc>
		close(i);
}
  800eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	57                   	push   %edi
  800f08:	56                   	push   %esi
  800f09:	53                   	push   %ebx
  800f0a:	83 ec 2c             	sub    $0x2c,%esp
  800f0d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f13:	50                   	push   %eax
  800f14:	ff 75 08             	pushl  0x8(%ebp)
  800f17:	e8 6e fe ff ff       	call   800d8a <fd_lookup>
  800f1c:	83 c4 08             	add    $0x8,%esp
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	0f 88 c1 00 00 00    	js     800fe8 <dup+0xe4>
		return r;
	close(newfdnum);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	56                   	push   %esi
  800f2b:	e8 84 ff ff ff       	call   800eb4 <close>

	newfd = INDEX2FD(newfdnum);
  800f30:	89 f3                	mov    %esi,%ebx
  800f32:	c1 e3 0c             	shl    $0xc,%ebx
  800f35:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f3b:	83 c4 04             	add    $0x4,%esp
  800f3e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f41:	e8 de fd ff ff       	call   800d24 <fd2data>
  800f46:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f48:	89 1c 24             	mov    %ebx,(%esp)
  800f4b:	e8 d4 fd ff ff       	call   800d24 <fd2data>
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f56:	89 f8                	mov    %edi,%eax
  800f58:	c1 e8 16             	shr    $0x16,%eax
  800f5b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f62:	a8 01                	test   $0x1,%al
  800f64:	74 37                	je     800f9d <dup+0x99>
  800f66:	89 f8                	mov    %edi,%eax
  800f68:	c1 e8 0c             	shr    $0xc,%eax
  800f6b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f72:	f6 c2 01             	test   $0x1,%dl
  800f75:	74 26                	je     800f9d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f77:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	25 07 0e 00 00       	and    $0xe07,%eax
  800f86:	50                   	push   %eax
  800f87:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f8a:	6a 00                	push   $0x0
  800f8c:	57                   	push   %edi
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 d2 fb ff ff       	call   800b66 <sys_page_map>
  800f94:	89 c7                	mov    %eax,%edi
  800f96:	83 c4 20             	add    $0x20,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 2e                	js     800fcb <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fa0:	89 d0                	mov    %edx,%eax
  800fa2:	c1 e8 0c             	shr    $0xc,%eax
  800fa5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fac:	83 ec 0c             	sub    $0xc,%esp
  800faf:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb4:	50                   	push   %eax
  800fb5:	53                   	push   %ebx
  800fb6:	6a 00                	push   $0x0
  800fb8:	52                   	push   %edx
  800fb9:	6a 00                	push   $0x0
  800fbb:	e8 a6 fb ff ff       	call   800b66 <sys_page_map>
  800fc0:	89 c7                	mov    %eax,%edi
  800fc2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fc5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc7:	85 ff                	test   %edi,%edi
  800fc9:	79 1d                	jns    800fe8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fcb:	83 ec 08             	sub    $0x8,%esp
  800fce:	53                   	push   %ebx
  800fcf:	6a 00                	push   $0x0
  800fd1:	e8 d2 fb ff ff       	call   800ba8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd6:	83 c4 08             	add    $0x8,%esp
  800fd9:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 c5 fb ff ff       	call   800ba8 <sys_page_unmap>
	return r;
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	89 f8                	mov    %edi,%eax
}
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 14             	sub    $0x14,%esp
  800ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ffa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ffd:	50                   	push   %eax
  800ffe:	53                   	push   %ebx
  800fff:	e8 86 fd ff ff       	call   800d8a <fd_lookup>
  801004:	83 c4 08             	add    $0x8,%esp
  801007:	89 c2                	mov    %eax,%edx
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 6d                	js     80107a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100d:	83 ec 08             	sub    $0x8,%esp
  801010:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801013:	50                   	push   %eax
  801014:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801017:	ff 30                	pushl  (%eax)
  801019:	e8 c2 fd ff ff       	call   800de0 <dev_lookup>
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 4c                	js     801071 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801025:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801028:	8b 42 08             	mov    0x8(%edx),%eax
  80102b:	83 e0 03             	and    $0x3,%eax
  80102e:	83 f8 01             	cmp    $0x1,%eax
  801031:	75 21                	jne    801054 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801033:	a1 04 40 80 00       	mov    0x804004,%eax
  801038:	8b 40 48             	mov    0x48(%eax),%eax
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	53                   	push   %ebx
  80103f:	50                   	push   %eax
  801040:	68 ad 21 80 00       	push   $0x8021ad
  801045:	e8 07 f1 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801052:	eb 26                	jmp    80107a <read+0x8a>
	}
	if (!dev->dev_read)
  801054:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801057:	8b 40 08             	mov    0x8(%eax),%eax
  80105a:	85 c0                	test   %eax,%eax
  80105c:	74 17                	je     801075 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80105e:	83 ec 04             	sub    $0x4,%esp
  801061:	ff 75 10             	pushl  0x10(%ebp)
  801064:	ff 75 0c             	pushl  0xc(%ebp)
  801067:	52                   	push   %edx
  801068:	ff d0                	call   *%eax
  80106a:	89 c2                	mov    %eax,%edx
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	eb 09                	jmp    80107a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801071:	89 c2                	mov    %eax,%edx
  801073:	eb 05                	jmp    80107a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801075:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80107a:	89 d0                	mov    %edx,%eax
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	57                   	push   %edi
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 0c             	sub    $0xc,%esp
  80108a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801090:	bb 00 00 00 00       	mov    $0x0,%ebx
  801095:	eb 21                	jmp    8010b8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801097:	83 ec 04             	sub    $0x4,%esp
  80109a:	89 f0                	mov    %esi,%eax
  80109c:	29 d8                	sub    %ebx,%eax
  80109e:	50                   	push   %eax
  80109f:	89 d8                	mov    %ebx,%eax
  8010a1:	03 45 0c             	add    0xc(%ebp),%eax
  8010a4:	50                   	push   %eax
  8010a5:	57                   	push   %edi
  8010a6:	e8 45 ff ff ff       	call   800ff0 <read>
		if (m < 0)
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 10                	js     8010c2 <readn+0x41>
			return m;
		if (m == 0)
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	74 0a                	je     8010c0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b6:	01 c3                	add    %eax,%ebx
  8010b8:	39 f3                	cmp    %esi,%ebx
  8010ba:	72 db                	jb     801097 <readn+0x16>
  8010bc:	89 d8                	mov    %ebx,%eax
  8010be:	eb 02                	jmp    8010c2 <readn+0x41>
  8010c0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 14             	sub    $0x14,%esp
  8010d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	53                   	push   %ebx
  8010d9:	e8 ac fc ff ff       	call   800d8a <fd_lookup>
  8010de:	83 c4 08             	add    $0x8,%esp
  8010e1:	89 c2                	mov    %eax,%edx
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 68                	js     80114f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f1:	ff 30                	pushl  (%eax)
  8010f3:	e8 e8 fc ff ff       	call   800de0 <dev_lookup>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	78 47                	js     801146 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801102:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801106:	75 21                	jne    801129 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801108:	a1 04 40 80 00       	mov    0x804004,%eax
  80110d:	8b 40 48             	mov    0x48(%eax),%eax
  801110:	83 ec 04             	sub    $0x4,%esp
  801113:	53                   	push   %ebx
  801114:	50                   	push   %eax
  801115:	68 c9 21 80 00       	push   $0x8021c9
  80111a:	e8 32 f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801127:	eb 26                	jmp    80114f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801129:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112c:	8b 52 0c             	mov    0xc(%edx),%edx
  80112f:	85 d2                	test   %edx,%edx
  801131:	74 17                	je     80114a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801133:	83 ec 04             	sub    $0x4,%esp
  801136:	ff 75 10             	pushl  0x10(%ebp)
  801139:	ff 75 0c             	pushl  0xc(%ebp)
  80113c:	50                   	push   %eax
  80113d:	ff d2                	call   *%edx
  80113f:	89 c2                	mov    %eax,%edx
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	eb 09                	jmp    80114f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801146:	89 c2                	mov    %eax,%edx
  801148:	eb 05                	jmp    80114f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80114a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80114f:	89 d0                	mov    %edx,%eax
  801151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <seek>:

int
seek(int fdnum, off_t offset)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80115f:	50                   	push   %eax
  801160:	ff 75 08             	pushl  0x8(%ebp)
  801163:	e8 22 fc ff ff       	call   800d8a <fd_lookup>
  801168:	83 c4 08             	add    $0x8,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 0e                	js     80117d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80116f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801172:	8b 55 0c             	mov    0xc(%ebp),%edx
  801175:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801178:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	53                   	push   %ebx
  801183:	83 ec 14             	sub    $0x14,%esp
  801186:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801189:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118c:	50                   	push   %eax
  80118d:	53                   	push   %ebx
  80118e:	e8 f7 fb ff ff       	call   800d8a <fd_lookup>
  801193:	83 c4 08             	add    $0x8,%esp
  801196:	89 c2                	mov    %eax,%edx
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 65                	js     801201 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a6:	ff 30                	pushl  (%eax)
  8011a8:	e8 33 fc ff ff       	call   800de0 <dev_lookup>
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	78 44                	js     8011f8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bb:	75 21                	jne    8011de <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011bd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011c2:	8b 40 48             	mov    0x48(%eax),%eax
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	53                   	push   %ebx
  8011c9:	50                   	push   %eax
  8011ca:	68 8c 21 80 00       	push   $0x80218c
  8011cf:	e8 7d ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011dc:	eb 23                	jmp    801201 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e1:	8b 52 18             	mov    0x18(%edx),%edx
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	74 14                	je     8011fc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	ff 75 0c             	pushl  0xc(%ebp)
  8011ee:	50                   	push   %eax
  8011ef:	ff d2                	call   *%edx
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	eb 09                	jmp    801201 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f8:	89 c2                	mov    %eax,%edx
  8011fa:	eb 05                	jmp    801201 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801201:	89 d0                	mov    %edx,%eax
  801203:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	53                   	push   %ebx
  80120c:	83 ec 14             	sub    $0x14,%esp
  80120f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801212:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801215:	50                   	push   %eax
  801216:	ff 75 08             	pushl  0x8(%ebp)
  801219:	e8 6c fb ff ff       	call   800d8a <fd_lookup>
  80121e:	83 c4 08             	add    $0x8,%esp
  801221:	89 c2                	mov    %eax,%edx
  801223:	85 c0                	test   %eax,%eax
  801225:	78 58                	js     80127f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801227:	83 ec 08             	sub    $0x8,%esp
  80122a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122d:	50                   	push   %eax
  80122e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801231:	ff 30                	pushl  (%eax)
  801233:	e8 a8 fb ff ff       	call   800de0 <dev_lookup>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 37                	js     801276 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801242:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801246:	74 32                	je     80127a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801248:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80124b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801252:	00 00 00 
	stat->st_isdir = 0;
  801255:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80125c:	00 00 00 
	stat->st_dev = dev;
  80125f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	53                   	push   %ebx
  801269:	ff 75 f0             	pushl  -0x10(%ebp)
  80126c:	ff 50 14             	call   *0x14(%eax)
  80126f:	89 c2                	mov    %eax,%edx
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	eb 09                	jmp    80127f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801276:	89 c2                	mov    %eax,%edx
  801278:	eb 05                	jmp    80127f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80127a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80127f:	89 d0                	mov    %edx,%eax
  801281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801284:	c9                   	leave  
  801285:	c3                   	ret    

00801286 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	56                   	push   %esi
  80128a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	6a 00                	push   $0x0
  801290:	ff 75 08             	pushl  0x8(%ebp)
  801293:	e8 dc 01 00 00       	call   801474 <open>
  801298:	89 c3                	mov    %eax,%ebx
  80129a:	83 c4 10             	add    $0x10,%esp
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 1b                	js     8012bc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	e8 5b ff ff ff       	call   801208 <fstat>
  8012ad:	89 c6                	mov    %eax,%esi
	close(fd);
  8012af:	89 1c 24             	mov    %ebx,(%esp)
  8012b2:	e8 fd fb ff ff       	call   800eb4 <close>
	return r;
  8012b7:	83 c4 10             	add    $0x10,%esp
  8012ba:	89 f0                	mov    %esi,%eax
}
  8012bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	89 c6                	mov    %eax,%esi
  8012ca:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012cc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012d3:	75 12                	jne    8012e7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	6a 01                	push   $0x1
  8012da:	e8 fe 07 00 00       	call   801add <ipc_find_env>
  8012df:	a3 00 40 80 00       	mov    %eax,0x804000
  8012e4:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e7:	6a 07                	push   $0x7
  8012e9:	68 00 50 80 00       	push   $0x805000
  8012ee:	56                   	push   %esi
  8012ef:	ff 35 00 40 80 00    	pushl  0x804000
  8012f5:	e8 a0 07 00 00       	call   801a9a <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8012fa:	83 c4 0c             	add    $0xc,%esp
  8012fd:	6a 00                	push   $0x0
  8012ff:	53                   	push   %ebx
  801300:	6a 00                	push   $0x0
  801302:	e8 36 07 00 00       	call   801a3d <ipc_recv>
}
  801307:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801314:	8b 45 08             	mov    0x8(%ebp),%eax
  801317:	8b 40 0c             	mov    0xc(%eax),%eax
  80131a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80131f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801322:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801327:	ba 00 00 00 00       	mov    $0x0,%edx
  80132c:	b8 02 00 00 00       	mov    $0x2,%eax
  801331:	e8 8d ff ff ff       	call   8012c3 <fsipc>
}
  801336:	c9                   	leave  
  801337:	c3                   	ret    

00801338 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80133e:	8b 45 08             	mov    0x8(%ebp),%eax
  801341:	8b 40 0c             	mov    0xc(%eax),%eax
  801344:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801349:	ba 00 00 00 00       	mov    $0x0,%edx
  80134e:	b8 06 00 00 00       	mov    $0x6,%eax
  801353:	e8 6b ff ff ff       	call   8012c3 <fsipc>
}
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 04             	sub    $0x4,%esp
  801361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801364:	8b 45 08             	mov    0x8(%ebp),%eax
  801367:	8b 40 0c             	mov    0xc(%eax),%eax
  80136a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80136f:	ba 00 00 00 00       	mov    $0x0,%edx
  801374:	b8 05 00 00 00       	mov    $0x5,%eax
  801379:	e8 45 ff ff ff       	call   8012c3 <fsipc>
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 2c                	js     8013ae <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	68 00 50 80 00       	push   $0x805000
  80138a:	53                   	push   %ebx
  80138b:	e8 90 f3 ff ff       	call   800720 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801390:	a1 80 50 80 00       	mov    0x805080,%eax
  801395:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80139b:	a1 84 50 80 00       	mov    0x805084,%eax
  8013a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 0c             	sub    $0xc,%esp
  8013b9:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8013c2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013c8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013cd:	50                   	push   %eax
  8013ce:	ff 75 0c             	pushl  0xc(%ebp)
  8013d1:	68 08 50 80 00       	push   $0x805008
  8013d6:	e8 d7 f4 ff ff       	call   8008b2 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013db:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e5:	e8 d9 fe ff ff       	call   8012c3 <fsipc>
	//panic("devfile_write not implemented");
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ff:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	b8 03 00 00 00       	mov    $0x3,%eax
  80140f:	e8 af fe ff ff       	call   8012c3 <fsipc>
  801414:	89 c3                	mov    %eax,%ebx
  801416:	85 c0                	test   %eax,%eax
  801418:	78 51                	js     80146b <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80141a:	39 c6                	cmp    %eax,%esi
  80141c:	73 19                	jae    801437 <devfile_read+0x4b>
  80141e:	68 f8 21 80 00       	push   $0x8021f8
  801423:	68 ff 21 80 00       	push   $0x8021ff
  801428:	68 80 00 00 00       	push   $0x80
  80142d:	68 14 22 80 00       	push   $0x802214
  801432:	e8 c0 05 00 00       	call   8019f7 <_panic>
	assert(r <= PGSIZE);
  801437:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80143c:	7e 19                	jle    801457 <devfile_read+0x6b>
  80143e:	68 1f 22 80 00       	push   $0x80221f
  801443:	68 ff 21 80 00       	push   $0x8021ff
  801448:	68 81 00 00 00       	push   $0x81
  80144d:	68 14 22 80 00       	push   $0x802214
  801452:	e8 a0 05 00 00       	call   8019f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801457:	83 ec 04             	sub    $0x4,%esp
  80145a:	50                   	push   %eax
  80145b:	68 00 50 80 00       	push   $0x805000
  801460:	ff 75 0c             	pushl  0xc(%ebp)
  801463:	e8 4a f4 ff ff       	call   8008b2 <memmove>
	return r;
  801468:	83 c4 10             	add    $0x10,%esp
}
  80146b:	89 d8                	mov    %ebx,%eax
  80146d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801470:	5b                   	pop    %ebx
  801471:	5e                   	pop    %esi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    

00801474 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	53                   	push   %ebx
  801478:	83 ec 20             	sub    $0x20,%esp
  80147b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80147e:	53                   	push   %ebx
  80147f:	e8 63 f2 ff ff       	call   8006e7 <strlen>
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80148c:	7f 67                	jg     8014f5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	e8 a1 f8 ff ff       	call   800d3b <fd_alloc>
  80149a:	83 c4 10             	add    $0x10,%esp
		return r;
  80149d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 57                	js     8014fa <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	68 00 50 80 00       	push   $0x805000
  8014ac:	e8 6f f2 ff ff       	call   800720 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b4:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8014c1:	e8 fd fd ff ff       	call   8012c3 <fsipc>
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	79 14                	jns    8014e3 <open+0x6f>
		
		fd_close(fd, 0);
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	6a 00                	push   $0x0
  8014d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d7:	e8 57 f9 ff ff       	call   800e33 <fd_close>
		return r;
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	89 da                	mov    %ebx,%edx
  8014e1:	eb 17                	jmp    8014fa <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8014e3:	83 ec 0c             	sub    $0xc,%esp
  8014e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e9:	e8 26 f8 ff ff       	call   800d14 <fd2num>
  8014ee:	89 c2                	mov    %eax,%edx
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb 05                	jmp    8014fa <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014f5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8014fa:	89 d0                	mov    %edx,%eax
  8014fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    

00801501 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801507:	ba 00 00 00 00       	mov    $0x0,%edx
  80150c:	b8 08 00 00 00       	mov    $0x8,%eax
  801511:	e8 ad fd ff ff       	call   8012c3 <fsipc>
}
  801516:	c9                   	leave  
  801517:	c3                   	ret    

00801518 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	56                   	push   %esi
  80151c:	53                   	push   %ebx
  80151d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801520:	83 ec 0c             	sub    $0xc,%esp
  801523:	ff 75 08             	pushl  0x8(%ebp)
  801526:	e8 f9 f7 ff ff       	call   800d24 <fd2data>
  80152b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	68 2b 22 80 00       	push   $0x80222b
  801535:	53                   	push   %ebx
  801536:	e8 e5 f1 ff ff       	call   800720 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80153b:	8b 46 04             	mov    0x4(%esi),%eax
  80153e:	2b 06                	sub    (%esi),%eax
  801540:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801546:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80154d:	00 00 00 
	stat->st_dev = &devpipe;
  801550:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801557:	30 80 00 
	return 0;
}
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
  80155f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801562:	5b                   	pop    %ebx
  801563:	5e                   	pop    %esi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801570:	53                   	push   %ebx
  801571:	6a 00                	push   $0x0
  801573:	e8 30 f6 ff ff       	call   800ba8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801578:	89 1c 24             	mov    %ebx,(%esp)
  80157b:	e8 a4 f7 ff ff       	call   800d24 <fd2data>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	50                   	push   %eax
  801584:	6a 00                	push   $0x0
  801586:	e8 1d f6 ff ff       	call   800ba8 <sys_page_unmap>
}
  80158b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	57                   	push   %edi
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
  801596:	83 ec 1c             	sub    $0x1c,%esp
  801599:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80159c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80159e:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015a6:	83 ec 0c             	sub    $0xc,%esp
  8015a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ac:	e8 65 05 00 00       	call   801b16 <pageref>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	89 3c 24             	mov    %edi,(%esp)
  8015b6:	e8 5b 05 00 00       	call   801b16 <pageref>
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	39 c3                	cmp    %eax,%ebx
  8015c0:	0f 94 c1             	sete   %cl
  8015c3:	0f b6 c9             	movzbl %cl,%ecx
  8015c6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015c9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015cf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015d2:	39 ce                	cmp    %ecx,%esi
  8015d4:	74 1b                	je     8015f1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015d6:	39 c3                	cmp    %eax,%ebx
  8015d8:	75 c4                	jne    80159e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015da:	8b 42 58             	mov    0x58(%edx),%eax
  8015dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e0:	50                   	push   %eax
  8015e1:	56                   	push   %esi
  8015e2:	68 32 22 80 00       	push   $0x802232
  8015e7:	e8 65 eb ff ff       	call   800151 <cprintf>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb ad                	jmp    80159e <_pipeisclosed+0xe>
	}
}
  8015f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5e                   	pop    %esi
  8015f9:	5f                   	pop    %edi
  8015fa:	5d                   	pop    %ebp
  8015fb:	c3                   	ret    

008015fc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	57                   	push   %edi
  801600:	56                   	push   %esi
  801601:	53                   	push   %ebx
  801602:	83 ec 28             	sub    $0x28,%esp
  801605:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801608:	56                   	push   %esi
  801609:	e8 16 f7 ff ff       	call   800d24 <fd2data>
  80160e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	bf 00 00 00 00       	mov    $0x0,%edi
  801618:	eb 4b                	jmp    801665 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80161a:	89 da                	mov    %ebx,%edx
  80161c:	89 f0                	mov    %esi,%eax
  80161e:	e8 6d ff ff ff       	call   801590 <_pipeisclosed>
  801623:	85 c0                	test   %eax,%eax
  801625:	75 48                	jne    80166f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801627:	e8 d8 f4 ff ff       	call   800b04 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80162c:	8b 43 04             	mov    0x4(%ebx),%eax
  80162f:	8b 0b                	mov    (%ebx),%ecx
  801631:	8d 51 20             	lea    0x20(%ecx),%edx
  801634:	39 d0                	cmp    %edx,%eax
  801636:	73 e2                	jae    80161a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801638:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80163f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801642:	89 c2                	mov    %eax,%edx
  801644:	c1 fa 1f             	sar    $0x1f,%edx
  801647:	89 d1                	mov    %edx,%ecx
  801649:	c1 e9 1b             	shr    $0x1b,%ecx
  80164c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80164f:	83 e2 1f             	and    $0x1f,%edx
  801652:	29 ca                	sub    %ecx,%edx
  801654:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801658:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80165c:	83 c0 01             	add    $0x1,%eax
  80165f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801662:	83 c7 01             	add    $0x1,%edi
  801665:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801668:	75 c2                	jne    80162c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80166a:	8b 45 10             	mov    0x10(%ebp),%eax
  80166d:	eb 05                	jmp    801674 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80166f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5f                   	pop    %edi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	57                   	push   %edi
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
  801682:	83 ec 18             	sub    $0x18,%esp
  801685:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801688:	57                   	push   %edi
  801689:	e8 96 f6 ff ff       	call   800d24 <fd2data>
  80168e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	bb 00 00 00 00       	mov    $0x0,%ebx
  801698:	eb 3d                	jmp    8016d7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80169a:	85 db                	test   %ebx,%ebx
  80169c:	74 04                	je     8016a2 <devpipe_read+0x26>
				return i;
  80169e:	89 d8                	mov    %ebx,%eax
  8016a0:	eb 44                	jmp    8016e6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016a2:	89 f2                	mov    %esi,%edx
  8016a4:	89 f8                	mov    %edi,%eax
  8016a6:	e8 e5 fe ff ff       	call   801590 <_pipeisclosed>
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	75 32                	jne    8016e1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016af:	e8 50 f4 ff ff       	call   800b04 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016b4:	8b 06                	mov    (%esi),%eax
  8016b6:	3b 46 04             	cmp    0x4(%esi),%eax
  8016b9:	74 df                	je     80169a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016bb:	99                   	cltd   
  8016bc:	c1 ea 1b             	shr    $0x1b,%edx
  8016bf:	01 d0                	add    %edx,%eax
  8016c1:	83 e0 1f             	and    $0x1f,%eax
  8016c4:	29 d0                	sub    %edx,%eax
  8016c6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016ce:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016d1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d4:	83 c3 01             	add    $0x1,%ebx
  8016d7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016da:	75 d8                	jne    8016b4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8016df:	eb 05                	jmp    8016e6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5f                   	pop    %edi
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	e8 3c f6 ff ff       	call   800d3b <fd_alloc>
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	89 c2                	mov    %eax,%edx
  801704:	85 c0                	test   %eax,%eax
  801706:	0f 88 2c 01 00 00    	js     801838 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170c:	83 ec 04             	sub    $0x4,%esp
  80170f:	68 07 04 00 00       	push   $0x407
  801714:	ff 75 f4             	pushl  -0xc(%ebp)
  801717:	6a 00                	push   $0x0
  801719:	e8 05 f4 ff ff       	call   800b23 <sys_page_alloc>
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	89 c2                	mov    %eax,%edx
  801723:	85 c0                	test   %eax,%eax
  801725:	0f 88 0d 01 00 00    	js     801838 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80172b:	83 ec 0c             	sub    $0xc,%esp
  80172e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	e8 04 f6 ff ff       	call   800d3b <fd_alloc>
  801737:	89 c3                	mov    %eax,%ebx
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	0f 88 e2 00 00 00    	js     801826 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801744:	83 ec 04             	sub    $0x4,%esp
  801747:	68 07 04 00 00       	push   $0x407
  80174c:	ff 75 f0             	pushl  -0x10(%ebp)
  80174f:	6a 00                	push   $0x0
  801751:	e8 cd f3 ff ff       	call   800b23 <sys_page_alloc>
  801756:	89 c3                	mov    %eax,%ebx
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	85 c0                	test   %eax,%eax
  80175d:	0f 88 c3 00 00 00    	js     801826 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801763:	83 ec 0c             	sub    $0xc,%esp
  801766:	ff 75 f4             	pushl  -0xc(%ebp)
  801769:	e8 b6 f5 ff ff       	call   800d24 <fd2data>
  80176e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801770:	83 c4 0c             	add    $0xc,%esp
  801773:	68 07 04 00 00       	push   $0x407
  801778:	50                   	push   %eax
  801779:	6a 00                	push   $0x0
  80177b:	e8 a3 f3 ff ff       	call   800b23 <sys_page_alloc>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	0f 88 89 00 00 00    	js     801816 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178d:	83 ec 0c             	sub    $0xc,%esp
  801790:	ff 75 f0             	pushl  -0x10(%ebp)
  801793:	e8 8c f5 ff ff       	call   800d24 <fd2data>
  801798:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80179f:	50                   	push   %eax
  8017a0:	6a 00                	push   $0x0
  8017a2:	56                   	push   %esi
  8017a3:	6a 00                	push   $0x0
  8017a5:	e8 bc f3 ff ff       	call   800b66 <sys_page_map>
  8017aa:	89 c3                	mov    %eax,%ebx
  8017ac:	83 c4 20             	add    $0x20,%esp
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 55                	js     801808 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017b3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017bc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017c8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017dd:	83 ec 0c             	sub    $0xc,%esp
  8017e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e3:	e8 2c f5 ff ff       	call   800d14 <fd2num>
  8017e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017eb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017ed:	83 c4 04             	add    $0x4,%esp
  8017f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f3:	e8 1c f5 ff ff       	call   800d14 <fd2num>
  8017f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017fe:	83 c4 10             	add    $0x10,%esp
  801801:	ba 00 00 00 00       	mov    $0x0,%edx
  801806:	eb 30                	jmp    801838 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	56                   	push   %esi
  80180c:	6a 00                	push   $0x0
  80180e:	e8 95 f3 ff ff       	call   800ba8 <sys_page_unmap>
  801813:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	ff 75 f0             	pushl  -0x10(%ebp)
  80181c:	6a 00                	push   $0x0
  80181e:	e8 85 f3 ff ff       	call   800ba8 <sys_page_unmap>
  801823:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801826:	83 ec 08             	sub    $0x8,%esp
  801829:	ff 75 f4             	pushl  -0xc(%ebp)
  80182c:	6a 00                	push   $0x0
  80182e:	e8 75 f3 ff ff       	call   800ba8 <sys_page_unmap>
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801838:	89 d0                	mov    %edx,%eax
  80183a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183d:	5b                   	pop    %ebx
  80183e:	5e                   	pop    %esi
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184a:	50                   	push   %eax
  80184b:	ff 75 08             	pushl  0x8(%ebp)
  80184e:	e8 37 f5 ff ff       	call   800d8a <fd_lookup>
  801853:	83 c4 10             	add    $0x10,%esp
  801856:	85 c0                	test   %eax,%eax
  801858:	78 18                	js     801872 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80185a:	83 ec 0c             	sub    $0xc,%esp
  80185d:	ff 75 f4             	pushl  -0xc(%ebp)
  801860:	e8 bf f4 ff ff       	call   800d24 <fd2data>
	return _pipeisclosed(fd, p);
  801865:	89 c2                	mov    %eax,%edx
  801867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186a:	e8 21 fd ff ff       	call   801590 <_pipeisclosed>
  80186f:	83 c4 10             	add    $0x10,%esp
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801877:	b8 00 00 00 00       	mov    $0x0,%eax
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801884:	68 4a 22 80 00       	push   $0x80224a
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	e8 8f ee ff ff       	call   800720 <strcpy>
	return 0;
}
  801891:	b8 00 00 00 00       	mov    $0x0,%eax
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	57                   	push   %edi
  80189c:	56                   	push   %esi
  80189d:	53                   	push   %ebx
  80189e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018a9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018af:	eb 2d                	jmp    8018de <devcons_write+0x46>
		m = n - tot;
  8018b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018b4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018b6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018b9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018be:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	53                   	push   %ebx
  8018c5:	03 45 0c             	add    0xc(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	57                   	push   %edi
  8018ca:	e8 e3 ef ff ff       	call   8008b2 <memmove>
		sys_cputs(buf, m);
  8018cf:	83 c4 08             	add    $0x8,%esp
  8018d2:	53                   	push   %ebx
  8018d3:	57                   	push   %edi
  8018d4:	e8 8e f1 ff ff       	call   800a67 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d9:	01 de                	add    %ebx,%esi
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	89 f0                	mov    %esi,%eax
  8018e0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018e3:	72 cc                	jb     8018b1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e8:	5b                   	pop    %ebx
  8018e9:	5e                   	pop    %esi
  8018ea:	5f                   	pop    %edi
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018fc:	74 2a                	je     801928 <devcons_read+0x3b>
  8018fe:	eb 05                	jmp    801905 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801900:	e8 ff f1 ff ff       	call   800b04 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801905:	e8 7b f1 ff ff       	call   800a85 <sys_cgetc>
  80190a:	85 c0                	test   %eax,%eax
  80190c:	74 f2                	je     801900 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 16                	js     801928 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801912:	83 f8 04             	cmp    $0x4,%eax
  801915:	74 0c                	je     801923 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191a:	88 02                	mov    %al,(%edx)
	return 1;
  80191c:	b8 01 00 00 00       	mov    $0x1,%eax
  801921:	eb 05                	jmp    801928 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801923:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801928:	c9                   	leave  
  801929:	c3                   	ret    

0080192a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801936:	6a 01                	push   $0x1
  801938:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80193b:	50                   	push   %eax
  80193c:	e8 26 f1 ff ff       	call   800a67 <sys_cputs>
}
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <getchar>:

int
getchar(void)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80194c:	6a 01                	push   $0x1
  80194e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801951:	50                   	push   %eax
  801952:	6a 00                	push   $0x0
  801954:	e8 97 f6 ff ff       	call   800ff0 <read>
	if (r < 0)
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 c0                	test   %eax,%eax
  80195e:	78 0f                	js     80196f <getchar+0x29>
		return r;
	if (r < 1)
  801960:	85 c0                	test   %eax,%eax
  801962:	7e 06                	jle    80196a <getchar+0x24>
		return -E_EOF;
	return c;
  801964:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801968:	eb 05                	jmp    80196f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80196a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801977:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197a:	50                   	push   %eax
  80197b:	ff 75 08             	pushl  0x8(%ebp)
  80197e:	e8 07 f4 ff ff       	call   800d8a <fd_lookup>
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	85 c0                	test   %eax,%eax
  801988:	78 11                	js     80199b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80198a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801993:	39 10                	cmp    %edx,(%eax)
  801995:	0f 94 c0             	sete   %al
  801998:	0f b6 c0             	movzbl %al,%eax
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <opencons>:

int
opencons(void)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a6:	50                   	push   %eax
  8019a7:	e8 8f f3 ff ff       	call   800d3b <fd_alloc>
  8019ac:	83 c4 10             	add    $0x10,%esp
		return r;
  8019af:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 3e                	js     8019f3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b5:	83 ec 04             	sub    $0x4,%esp
  8019b8:	68 07 04 00 00       	push   $0x407
  8019bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c0:	6a 00                	push   $0x0
  8019c2:	e8 5c f1 ff ff       	call   800b23 <sys_page_alloc>
  8019c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ca:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 23                	js     8019f3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019d0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019e5:	83 ec 0c             	sub    $0xc,%esp
  8019e8:	50                   	push   %eax
  8019e9:	e8 26 f3 ff ff       	call   800d14 <fd2num>
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	83 c4 10             	add    $0x10,%esp
}
  8019f3:	89 d0                	mov    %edx,%eax
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	56                   	push   %esi
  8019fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a05:	e8 db f0 ff ff       	call   800ae5 <sys_getenvid>
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	ff 75 0c             	pushl  0xc(%ebp)
  801a10:	ff 75 08             	pushl  0x8(%ebp)
  801a13:	56                   	push   %esi
  801a14:	50                   	push   %eax
  801a15:	68 58 22 80 00       	push   $0x802258
  801a1a:	e8 32 e7 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a1f:	83 c4 18             	add    $0x18,%esp
  801a22:	53                   	push   %ebx
  801a23:	ff 75 10             	pushl  0x10(%ebp)
  801a26:	e8 d5 e6 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801a2b:	c7 04 24 43 22 80 00 	movl   $0x802243,(%esp)
  801a32:	e8 1a e7 ff ff       	call   800151 <cprintf>
  801a37:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a3a:	cc                   	int3   
  801a3b:	eb fd                	jmp    801a3a <_panic+0x43>

00801a3d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a45:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	ff 75 0c             	pushl  0xc(%ebp)
  801a4e:	e8 80 f2 ff ff       	call   800cd3 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	85 f6                	test   %esi,%esi
  801a58:	74 1c                	je     801a76 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 40 78             	mov    0x78(%eax),%eax
  801a62:	89 06                	mov    %eax,(%esi)
  801a64:	eb 10                	jmp    801a76 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	68 7c 22 80 00       	push   $0x80227c
  801a6e:	e8 de e6 ff ff       	call   800151 <cprintf>
  801a73:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a76:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7b:	8b 50 74             	mov    0x74(%eax),%edx
  801a7e:	85 d2                	test   %edx,%edx
  801a80:	74 e4                	je     801a66 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a82:	85 db                	test   %ebx,%ebx
  801a84:	74 05                	je     801a8b <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a86:	8b 40 74             	mov    0x74(%eax),%eax
  801a89:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a8b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a90:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a96:	5b                   	pop    %ebx
  801a97:	5e                   	pop    %esi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	57                   	push   %edi
  801a9e:	56                   	push   %esi
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801aac:	85 db                	test   %ebx,%ebx
  801aae:	75 13                	jne    801ac3 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801ab0:	6a 00                	push   $0x0
  801ab2:	68 00 00 c0 ee       	push   $0xeec00000
  801ab7:	56                   	push   %esi
  801ab8:	57                   	push   %edi
  801ab9:	e8 f2 f1 ff ff       	call   800cb0 <sys_ipc_try_send>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	eb 0e                	jmp    801ad1 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ac3:	ff 75 14             	pushl  0x14(%ebp)
  801ac6:	53                   	push   %ebx
  801ac7:	56                   	push   %esi
  801ac8:	57                   	push   %edi
  801ac9:	e8 e2 f1 ff ff       	call   800cb0 <sys_ipc_try_send>
  801ace:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	75 d7                	jne    801aac <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5e                   	pop    %esi
  801ada:	5f                   	pop    %edi
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    

00801add <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801add:	55                   	push   %ebp
  801ade:	89 e5                	mov    %esp,%ebp
  801ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ae8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aeb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af1:	8b 52 50             	mov    0x50(%edx),%edx
  801af4:	39 ca                	cmp    %ecx,%edx
  801af6:	75 0d                	jne    801b05 <ipc_find_env+0x28>
			return envs[i].env_id;
  801af8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801afb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b00:	8b 40 48             	mov    0x48(%eax),%eax
  801b03:	eb 0f                	jmp    801b14 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b05:	83 c0 01             	add    $0x1,%eax
  801b08:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b0d:	75 d9                	jne    801ae8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1c:	89 d0                	mov    %edx,%eax
  801b1e:	c1 e8 16             	shr    $0x16,%eax
  801b21:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2d:	f6 c1 01             	test   $0x1,%cl
  801b30:	74 1d                	je     801b4f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b32:	c1 ea 0c             	shr    $0xc,%edx
  801b35:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b3c:	f6 c2 01             	test   $0x1,%dl
  801b3f:	74 0e                	je     801b4f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b41:	c1 ea 0c             	shr    $0xc,%edx
  801b44:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b4b:	ef 
  801b4c:	0f b7 c0             	movzwl %ax,%eax
}
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    
  801b51:	66 90                	xchg   %ax,%ax
  801b53:	66 90                	xchg   %ax,%ax
  801b55:	66 90                	xchg   %ax,%ax
  801b57:	66 90                	xchg   %ax,%ax
  801b59:	66 90                	xchg   %ax,%ax
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
