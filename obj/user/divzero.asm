
obj/user/divzero.debug:     file format elf32-i386


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
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 00 1e 80 00       	push   $0x801e00
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
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
  80006b:	e8 77 0a 00 00       	call   800ae7 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 30 0e 00 00       	call   800ee1 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 eb 09 00 00       	call   800aa6 <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 79 09 00 00       	call   800a69 <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 54 01 00 00       	call   80028a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 1e 09 00 00       	call   800a69 <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 45                	ja     8001dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 a5 19 00 00       	call   801b60 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 18                	jmp    8001e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb 03                	jmp    8001df <printnum+0x78>
  8001dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	85 db                	test   %ebx,%ebx
  8001e4:	7f e8                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 92 1a 00 00       	call   801c90 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 18 1e 80 00 	movsbl 0x801e18(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff d7                	call   *%edi
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800219:	83 fa 01             	cmp    $0x1,%edx
  80021c:	7e 0e                	jle    80022c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	8d 4a 08             	lea    0x8(%edx),%ecx
  800223:	89 08                	mov    %ecx,(%eax)
  800225:	8b 02                	mov    (%edx),%eax
  800227:	8b 52 04             	mov    0x4(%edx),%edx
  80022a:	eb 22                	jmp    80024e <getuint+0x38>
	else if (lflag)
  80022c:	85 d2                	test   %edx,%edx
  80022e:	74 10                	je     800240 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
  80023e:	eb 0e                	jmp    80024e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800240:	8b 10                	mov    (%eax),%edx
  800242:	8d 4a 04             	lea    0x4(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 02                	mov    (%edx),%eax
  800249:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800256:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025a:	8b 10                	mov    (%eax),%edx
  80025c:	3b 50 04             	cmp    0x4(%eax),%edx
  80025f:	73 0a                	jae    80026b <sprintputch+0x1b>
		*b->buf++ = ch;
  800261:	8d 4a 01             	lea    0x1(%edx),%ecx
  800264:	89 08                	mov    %ecx,(%eax)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	88 02                	mov    %al,(%edx)
}
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800276:	50                   	push   %eax
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	ff 75 0c             	pushl  0xc(%ebp)
  80027d:	ff 75 08             	pushl  0x8(%ebp)
  800280:	e8 05 00 00 00       	call   80028a <vprintfmt>
	va_end(ap);
}
  800285:	83 c4 10             	add    $0x10,%esp
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 2c             	sub    $0x2c,%esp
  800293:	8b 75 08             	mov    0x8(%ebp),%esi
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800299:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029c:	eb 12                	jmp    8002b0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	0f 84 d3 03 00 00    	je     800679 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002a6:	83 ec 08             	sub    $0x8,%esp
  8002a9:	53                   	push   %ebx
  8002aa:	50                   	push   %eax
  8002ab:	ff d6                	call   *%esi
  8002ad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b0:	83 c7 01             	add    $0x1,%edi
  8002b3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b7:	83 f8 25             	cmp    $0x25,%eax
  8002ba:	75 e2                	jne    80029e <vprintfmt+0x14>
  8002bc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c7:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	eb 07                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002df:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8d 47 01             	lea    0x1(%edi),%eax
  8002e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e9:	0f b6 07             	movzbl (%edi),%eax
  8002ec:	0f b6 c8             	movzbl %al,%ecx
  8002ef:	83 e8 23             	sub    $0x23,%eax
  8002f2:	3c 55                	cmp    $0x55,%al
  8002f4:	0f 87 64 03 00 00    	ja     80065e <vprintfmt+0x3d4>
  8002fa:	0f b6 c0             	movzbl %al,%eax
  8002fd:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800307:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030b:	eb d6                	jmp    8002e3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800310:	b8 00 00 00 00       	mov    $0x0,%eax
  800315:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800318:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800322:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800325:	83 fa 09             	cmp    $0x9,%edx
  800328:	77 39                	ja     800363 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032d:	eb e9                	jmp    800318 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8d 48 04             	lea    0x4(%eax),%ecx
  800335:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800338:	8b 00                	mov    (%eax),%eax
  80033a:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800340:	eb 27                	jmp    800369 <vprintfmt+0xdf>
  800342:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800345:	85 c0                	test   %eax,%eax
  800347:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034c:	0f 49 c8             	cmovns %eax,%ecx
  80034f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800355:	eb 8c                	jmp    8002e3 <vprintfmt+0x59>
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800361:	eb 80                	jmp    8002e3 <vprintfmt+0x59>
  800363:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800366:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800369:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036d:	0f 89 70 ff ff ff    	jns    8002e3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800373:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800376:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800379:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800380:	e9 5e ff ff ff       	jmp    8002e3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800385:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038b:	e9 53 ff ff ff       	jmp    8002e3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 50 04             	lea    0x4(%eax),%edx
  800396:	89 55 14             	mov    %edx,0x14(%ebp)
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	53                   	push   %ebx
  80039d:	ff 30                	pushl  (%eax)
  80039f:	ff d6                	call   *%esi
			break;
  8003a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a7:	e9 04 ff ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 50 04             	lea    0x4(%eax),%edx
  8003b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b5:	8b 00                	mov    (%eax),%eax
  8003b7:	99                   	cltd   
  8003b8:	31 d0                	xor    %edx,%eax
  8003ba:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bc:	83 f8 0f             	cmp    $0xf,%eax
  8003bf:	7f 0b                	jg     8003cc <vprintfmt+0x142>
  8003c1:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  8003c8:	85 d2                	test   %edx,%edx
  8003ca:	75 18                	jne    8003e4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003cc:	50                   	push   %eax
  8003cd:	68 30 1e 80 00       	push   $0x801e30
  8003d2:	53                   	push   %ebx
  8003d3:	56                   	push   %esi
  8003d4:	e8 94 fe ff ff       	call   80026d <printfmt>
  8003d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003df:	e9 cc fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e4:	52                   	push   %edx
  8003e5:	68 f1 21 80 00       	push   $0x8021f1
  8003ea:	53                   	push   %ebx
  8003eb:	56                   	push   %esi
  8003ec:	e8 7c fe ff ff       	call   80026d <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f7:	e9 b4 fe ff ff       	jmp    8002b0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 50 04             	lea    0x4(%eax),%edx
  800402:	89 55 14             	mov    %edx,0x14(%ebp)
  800405:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800407:	85 ff                	test   %edi,%edi
  800409:	b8 29 1e 80 00       	mov    $0x801e29,%eax
  80040e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	0f 8e 94 00 00 00    	jle    8004af <vprintfmt+0x225>
  80041b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041f:	0f 84 98 00 00 00    	je     8004bd <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	ff 75 c8             	pushl  -0x38(%ebp)
  80042b:	57                   	push   %edi
  80042c:	e8 d0 02 00 00       	call   800701 <strnlen>
  800431:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800434:	29 c1                	sub    %eax,%ecx
  800436:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800439:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800446:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800448:	eb 0f                	jmp    800459 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	53                   	push   %ebx
  80044e:	ff 75 e0             	pushl  -0x20(%ebp)
  800451:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	83 ef 01             	sub    $0x1,%edi
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 ff                	test   %edi,%edi
  80045b:	7f ed                	jg     80044a <vprintfmt+0x1c0>
  80045d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800460:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800463:	85 c9                	test   %ecx,%ecx
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	0f 49 c1             	cmovns %ecx,%eax
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 75 08             	mov    %esi,0x8(%ebp)
  800472:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	89 cb                	mov    %ecx,%ebx
  80047a:	eb 4d                	jmp    8004c9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800480:	74 1b                	je     80049d <vprintfmt+0x213>
  800482:	0f be c0             	movsbl %al,%eax
  800485:	83 e8 20             	sub    $0x20,%eax
  800488:	83 f8 5e             	cmp    $0x5e,%eax
  80048b:	76 10                	jbe    80049d <vprintfmt+0x213>
					putch('?', putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	6a 3f                	push   $0x3f
  800495:	ff 55 08             	call   *0x8(%ebp)
  800498:	83 c4 10             	add    $0x10,%esp
  80049b:	eb 0d                	jmp    8004aa <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	52                   	push   %edx
  8004a4:	ff 55 08             	call   *0x8(%ebp)
  8004a7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	eb 1a                	jmp    8004c9 <vprintfmt+0x23f>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	eb 0c                	jmp    8004c9 <vprintfmt+0x23f>
  8004bd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004c3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c9:	83 c7 01             	add    $0x1,%edi
  8004cc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d0:	0f be d0             	movsbl %al,%edx
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	74 23                	je     8004fa <vprintfmt+0x270>
  8004d7:	85 f6                	test   %esi,%esi
  8004d9:	78 a1                	js     80047c <vprintfmt+0x1f2>
  8004db:	83 ee 01             	sub    $0x1,%esi
  8004de:	79 9c                	jns    80047c <vprintfmt+0x1f2>
  8004e0:	89 df                	mov    %ebx,%edi
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e8:	eb 18                	jmp    800502 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	6a 20                	push   $0x20
  8004f0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb 08                	jmp    800502 <vprintfmt+0x278>
  8004fa:	89 df                	mov    %ebx,%edi
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800502:	85 ff                	test   %edi,%edi
  800504:	7f e4                	jg     8004ea <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800509:	e9 a2 fd ff ff       	jmp    8002b0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80050e:	83 fa 01             	cmp    $0x1,%edx
  800511:	7e 16                	jle    800529 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 50 08             	lea    0x8(%eax),%edx
  800519:	89 55 14             	mov    %edx,0x14(%ebp)
  80051c:	8b 50 04             	mov    0x4(%eax),%edx
  80051f:	8b 00                	mov    (%eax),%eax
  800521:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800524:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800527:	eb 32                	jmp    80055b <vprintfmt+0x2d1>
	else if (lflag)
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 18                	je     800545 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80053b:	89 c1                	mov    %eax,%ecx
  80053d:	c1 f9 1f             	sar    $0x1f,%ecx
  800540:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800543:	eb 16                	jmp    80055b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800553:	89 c1                	mov    %eax,%ecx
  800555:	c1 f9 1f             	sar    $0x1f,%ecx
  800558:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80055e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800570:	0f 89 b0 00 00 00    	jns    800626 <vprintfmt+0x39c>
				putch('-', putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	53                   	push   %ebx
  80057a:	6a 2d                	push   $0x2d
  80057c:	ff d6                	call   *%esi
				num = -(long long) num;
  80057e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800581:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800584:	f7 d8                	neg    %eax
  800586:	83 d2 00             	adc    $0x0,%edx
  800589:	f7 da                	neg    %edx
  80058b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800591:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
  800599:	e9 88 00 00 00       	jmp    800626 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80059e:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a1:	e8 70 fc ff ff       	call   800216 <getuint>
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005b1:	eb 73                	jmp    800626 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b6:	e8 5b fc ff ff       	call   800216 <getuint>
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 58                	push   $0x58
  8005c7:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c9:	83 c4 08             	add    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 58                	push   $0x58
  8005cf:	ff d6                	call   *%esi
			putch('X', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 58                	push   $0x58
  8005d7:	ff d6                	call   *%esi
			goto number;
  8005d9:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005dc:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005e1:	eb 43                	jmp    800626 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 30                	push   $0x30
  8005e9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005eb:	83 c4 08             	add    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 78                	push   $0x78
  8005f1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800609:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80060c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800611:	eb 13                	jmp    800626 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 fb fb ff ff       	call   800216 <getuint>
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800621:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80062d:	52                   	push   %edx
  80062e:	ff 75 e0             	pushl  -0x20(%ebp)
  800631:	50                   	push   %eax
  800632:	ff 75 dc             	pushl  -0x24(%ebp)
  800635:	ff 75 d8             	pushl  -0x28(%ebp)
  800638:	89 da                	mov    %ebx,%edx
  80063a:	89 f0                	mov    %esi,%eax
  80063c:	e8 26 fb ff ff       	call   800167 <printnum>
			break;
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800647:	e9 64 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	51                   	push   %ecx
  800651:	ff d6                	call   *%esi
			break;
  800653:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800659:	e9 52 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 25                	push   $0x25
  800664:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	eb 03                	jmp    80066e <vprintfmt+0x3e4>
  80066b:	83 ef 01             	sub    $0x1,%edi
  80066e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800672:	75 f7                	jne    80066b <vprintfmt+0x3e1>
  800674:	e9 37 fc ff ff       	jmp    8002b0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067c:	5b                   	pop    %ebx
  80067d:	5e                   	pop    %esi
  80067e:	5f                   	pop    %edi
  80067f:	5d                   	pop    %ebp
  800680:	c3                   	ret    

00800681 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800681:	55                   	push   %ebp
  800682:	89 e5                	mov    %esp,%ebp
  800684:	83 ec 18             	sub    $0x18,%esp
  800687:	8b 45 08             	mov    0x8(%ebp),%eax
  80068a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800690:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800694:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	74 26                	je     8006c8 <vsnprintf+0x47>
  8006a2:	85 d2                	test   %edx,%edx
  8006a4:	7e 22                	jle    8006c8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a6:	ff 75 14             	pushl  0x14(%ebp)
  8006a9:	ff 75 10             	pushl  0x10(%ebp)
  8006ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006af:	50                   	push   %eax
  8006b0:	68 50 02 80 00       	push   $0x800250
  8006b5:	e8 d0 fb ff ff       	call   80028a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	eb 05                	jmp    8006cd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    

008006cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d8:	50                   	push   %eax
  8006d9:	ff 75 10             	pushl  0x10(%ebp)
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	ff 75 08             	pushl  0x8(%ebp)
  8006e2:	e8 9a ff ff ff       	call   800681 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e7:	c9                   	leave  
  8006e8:	c3                   	ret    

008006e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f4:	eb 03                	jmp    8006f9 <strlen+0x10>
		n++;
  8006f6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fd:	75 f7                	jne    8006f6 <strlen+0xd>
		n++;
	return n;
}
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800707:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070a:	ba 00 00 00 00       	mov    $0x0,%edx
  80070f:	eb 03                	jmp    800714 <strnlen+0x13>
		n++;
  800711:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800714:	39 c2                	cmp    %eax,%edx
  800716:	74 08                	je     800720 <strnlen+0x1f>
  800718:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80071c:	75 f3                	jne    800711 <strnlen+0x10>
  80071e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	53                   	push   %ebx
  800726:	8b 45 08             	mov    0x8(%ebp),%eax
  800729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072c:	89 c2                	mov    %eax,%edx
  80072e:	83 c2 01             	add    $0x1,%edx
  800731:	83 c1 01             	add    $0x1,%ecx
  800734:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800738:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073b:	84 db                	test   %bl,%bl
  80073d:	75 ef                	jne    80072e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073f:	5b                   	pop    %ebx
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	53                   	push   %ebx
  800746:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800749:	53                   	push   %ebx
  80074a:	e8 9a ff ff ff       	call   8006e9 <strlen>
  80074f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	01 d8                	add    %ebx,%eax
  800757:	50                   	push   %eax
  800758:	e8 c5 ff ff ff       	call   800722 <strcpy>
	return dst;
}
  80075d:	89 d8                	mov    %ebx,%eax
  80075f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	56                   	push   %esi
  800768:	53                   	push   %ebx
  800769:	8b 75 08             	mov    0x8(%ebp),%esi
  80076c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076f:	89 f3                	mov    %esi,%ebx
  800771:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800774:	89 f2                	mov    %esi,%edx
  800776:	eb 0f                	jmp    800787 <strncpy+0x23>
		*dst++ = *src;
  800778:	83 c2 01             	add    $0x1,%edx
  80077b:	0f b6 01             	movzbl (%ecx),%eax
  80077e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800781:	80 39 01             	cmpb   $0x1,(%ecx)
  800784:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800787:	39 da                	cmp    %ebx,%edx
  800789:	75 ed                	jne    800778 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078b:	89 f0                	mov    %esi,%eax
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	56                   	push   %esi
  800795:	53                   	push   %ebx
  800796:	8b 75 08             	mov    0x8(%ebp),%esi
  800799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079c:	8b 55 10             	mov    0x10(%ebp),%edx
  80079f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 21                	je     8007c6 <strlcpy+0x35>
  8007a5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	eb 09                	jmp    8007b6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ad:	83 c2 01             	add    $0x1,%edx
  8007b0:	83 c1 01             	add    $0x1,%ecx
  8007b3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b6:	39 c2                	cmp    %eax,%edx
  8007b8:	74 09                	je     8007c3 <strlcpy+0x32>
  8007ba:	0f b6 19             	movzbl (%ecx),%ebx
  8007bd:	84 db                	test   %bl,%bl
  8007bf:	75 ec                	jne    8007ad <strlcpy+0x1c>
  8007c1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c6:	29 f0                	sub    %esi,%eax
}
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d5:	eb 06                	jmp    8007dd <strcmp+0x11>
		p++, q++;
  8007d7:	83 c1 01             	add    $0x1,%ecx
  8007da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007dd:	0f b6 01             	movzbl (%ecx),%eax
  8007e0:	84 c0                	test   %al,%al
  8007e2:	74 04                	je     8007e8 <strcmp+0x1c>
  8007e4:	3a 02                	cmp    (%edx),%al
  8007e6:	74 ef                	je     8007d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e8:	0f b6 c0             	movzbl %al,%eax
  8007eb:	0f b6 12             	movzbl (%edx),%edx
  8007ee:	29 d0                	sub    %edx,%eax
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fc:	89 c3                	mov    %eax,%ebx
  8007fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800801:	eb 06                	jmp    800809 <strncmp+0x17>
		n--, p++, q++;
  800803:	83 c0 01             	add    $0x1,%eax
  800806:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800809:	39 d8                	cmp    %ebx,%eax
  80080b:	74 15                	je     800822 <strncmp+0x30>
  80080d:	0f b6 08             	movzbl (%eax),%ecx
  800810:	84 c9                	test   %cl,%cl
  800812:	74 04                	je     800818 <strncmp+0x26>
  800814:	3a 0a                	cmp    (%edx),%cl
  800816:	74 eb                	je     800803 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800818:	0f b6 00             	movzbl (%eax),%eax
  80081b:	0f b6 12             	movzbl (%edx),%edx
  80081e:	29 d0                	sub    %edx,%eax
  800820:	eb 05                	jmp    800827 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800834:	eb 07                	jmp    80083d <strchr+0x13>
		if (*s == c)
  800836:	38 ca                	cmp    %cl,%dl
  800838:	74 0f                	je     800849 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083a:	83 c0 01             	add    $0x1,%eax
  80083d:	0f b6 10             	movzbl (%eax),%edx
  800840:	84 d2                	test   %dl,%dl
  800842:	75 f2                	jne    800836 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800844:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800855:	eb 03                	jmp    80085a <strfind+0xf>
  800857:	83 c0 01             	add    $0x1,%eax
  80085a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085d:	38 ca                	cmp    %cl,%dl
  80085f:	74 04                	je     800865 <strfind+0x1a>
  800861:	84 d2                	test   %dl,%dl
  800863:	75 f2                	jne    800857 <strfind+0xc>
			break;
	return (char *) s;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	57                   	push   %edi
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800873:	85 c9                	test   %ecx,%ecx
  800875:	74 36                	je     8008ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800877:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087d:	75 28                	jne    8008a7 <memset+0x40>
  80087f:	f6 c1 03             	test   $0x3,%cl
  800882:	75 23                	jne    8008a7 <memset+0x40>
		c &= 0xFF;
  800884:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800888:	89 d3                	mov    %edx,%ebx
  80088a:	c1 e3 08             	shl    $0x8,%ebx
  80088d:	89 d6                	mov    %edx,%esi
  80088f:	c1 e6 18             	shl    $0x18,%esi
  800892:	89 d0                	mov    %edx,%eax
  800894:	c1 e0 10             	shl    $0x10,%eax
  800897:	09 f0                	or     %esi,%eax
  800899:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80089b:	89 d8                	mov    %ebx,%eax
  80089d:	09 d0                	or     %edx,%eax
  80089f:	c1 e9 02             	shr    $0x2,%ecx
  8008a2:	fc                   	cld    
  8008a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a5:	eb 06                	jmp    8008ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008aa:	fc                   	cld    
  8008ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ad:	89 f8                	mov    %edi,%eax
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5f                   	pop    %edi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c2:	39 c6                	cmp    %eax,%esi
  8008c4:	73 35                	jae    8008fb <memmove+0x47>
  8008c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c9:	39 d0                	cmp    %edx,%eax
  8008cb:	73 2e                	jae    8008fb <memmove+0x47>
		s += n;
		d += n;
  8008cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	89 d6                	mov    %edx,%esi
  8008d2:	09 fe                	or     %edi,%esi
  8008d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008da:	75 13                	jne    8008ef <memmove+0x3b>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	75 0e                	jne    8008ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e1:	83 ef 04             	sub    $0x4,%edi
  8008e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
  8008ea:	fd                   	std    
  8008eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ed:	eb 09                	jmp    8008f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ef:	83 ef 01             	sub    $0x1,%edi
  8008f2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f5:	fd                   	std    
  8008f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f8:	fc                   	cld    
  8008f9:	eb 1d                	jmp    800918 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fb:	89 f2                	mov    %esi,%edx
  8008fd:	09 c2                	or     %eax,%edx
  8008ff:	f6 c2 03             	test   $0x3,%dl
  800902:	75 0f                	jne    800913 <memmove+0x5f>
  800904:	f6 c1 03             	test   $0x3,%cl
  800907:	75 0a                	jne    800913 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800909:	c1 e9 02             	shr    $0x2,%ecx
  80090c:	89 c7                	mov    %eax,%edi
  80090e:	fc                   	cld    
  80090f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800911:	eb 05                	jmp    800918 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800913:	89 c7                	mov    %eax,%edi
  800915:	fc                   	cld    
  800916:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800918:	5e                   	pop    %esi
  800919:	5f                   	pop    %edi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091f:	ff 75 10             	pushl  0x10(%ebp)
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	ff 75 08             	pushl  0x8(%ebp)
  800928:	e8 87 ff ff ff       	call   8008b4 <memmove>
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093a:	89 c6                	mov    %eax,%esi
  80093c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093f:	eb 1a                	jmp    80095b <memcmp+0x2c>
		if (*s1 != *s2)
  800941:	0f b6 08             	movzbl (%eax),%ecx
  800944:	0f b6 1a             	movzbl (%edx),%ebx
  800947:	38 d9                	cmp    %bl,%cl
  800949:	74 0a                	je     800955 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094b:	0f b6 c1             	movzbl %cl,%eax
  80094e:	0f b6 db             	movzbl %bl,%ebx
  800951:	29 d8                	sub    %ebx,%eax
  800953:	eb 0f                	jmp    800964 <memcmp+0x35>
		s1++, s2++;
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095b:	39 f0                	cmp    %esi,%eax
  80095d:	75 e2                	jne    800941 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096f:	89 c1                	mov    %eax,%ecx
  800971:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800974:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800978:	eb 0a                	jmp    800984 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097a:	0f b6 10             	movzbl (%eax),%edx
  80097d:	39 da                	cmp    %ebx,%edx
  80097f:	74 07                	je     800988 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	39 c8                	cmp    %ecx,%eax
  800986:	72 f2                	jb     80097a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	57                   	push   %edi
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800994:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800997:	eb 03                	jmp    80099c <strtol+0x11>
		s++;
  800999:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	3c 20                	cmp    $0x20,%al
  8009a1:	74 f6                	je     800999 <strtol+0xe>
  8009a3:	3c 09                	cmp    $0x9,%al
  8009a5:	74 f2                	je     800999 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a7:	3c 2b                	cmp    $0x2b,%al
  8009a9:	75 0a                	jne    8009b5 <strtol+0x2a>
		s++;
  8009ab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b3:	eb 11                	jmp    8009c6 <strtol+0x3b>
  8009b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ba:	3c 2d                	cmp    $0x2d,%al
  8009bc:	75 08                	jne    8009c6 <strtol+0x3b>
		s++, neg = 1;
  8009be:	83 c1 01             	add    $0x1,%ecx
  8009c1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009cc:	75 15                	jne    8009e3 <strtol+0x58>
  8009ce:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d1:	75 10                	jne    8009e3 <strtol+0x58>
  8009d3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d7:	75 7c                	jne    800a55 <strtol+0xca>
		s += 2, base = 16;
  8009d9:	83 c1 02             	add    $0x2,%ecx
  8009dc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e1:	eb 16                	jmp    8009f9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e3:	85 db                	test   %ebx,%ebx
  8009e5:	75 12                	jne    8009f9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ec:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ef:	75 08                	jne    8009f9 <strtol+0x6e>
		s++, base = 8;
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a01:	0f b6 11             	movzbl (%ecx),%edx
  800a04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a07:	89 f3                	mov    %esi,%ebx
  800a09:	80 fb 09             	cmp    $0x9,%bl
  800a0c:	77 08                	ja     800a16 <strtol+0x8b>
			dig = *s - '0';
  800a0e:	0f be d2             	movsbl %dl,%edx
  800a11:	83 ea 30             	sub    $0x30,%edx
  800a14:	eb 22                	jmp    800a38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a19:	89 f3                	mov    %esi,%ebx
  800a1b:	80 fb 19             	cmp    $0x19,%bl
  800a1e:	77 08                	ja     800a28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a20:	0f be d2             	movsbl %dl,%edx
  800a23:	83 ea 57             	sub    $0x57,%edx
  800a26:	eb 10                	jmp    800a38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	80 fb 19             	cmp    $0x19,%bl
  800a30:	77 16                	ja     800a48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a32:	0f be d2             	movsbl %dl,%edx
  800a35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a38:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a3b:	7d 0b                	jge    800a48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a46:	eb b9                	jmp    800a01 <strtol+0x76>

	if (endptr)
  800a48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4c:	74 0d                	je     800a5b <strtol+0xd0>
		*endptr = (char *) s;
  800a4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a51:	89 0e                	mov    %ecx,(%esi)
  800a53:	eb 06                	jmp    800a5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a55:	85 db                	test   %ebx,%ebx
  800a57:	74 98                	je     8009f1 <strtol+0x66>
  800a59:	eb 9e                	jmp    8009f9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5b:	89 c2                	mov    %eax,%edx
  800a5d:	f7 da                	neg    %edx
  800a5f:	85 ff                	test   %edi,%edi
  800a61:	0f 45 c2             	cmovne %edx,%eax
}
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5f                   	pop    %edi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    

00800a69 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a77:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	89 c7                	mov    %eax,%edi
  800a7e:	89 c6                	mov    %eax,%esi
  800a80:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a92:	b8 01 00 00 00       	mov    $0x1,%eax
  800a97:	89 d1                	mov    %edx,%ecx
  800a99:	89 d3                	mov    %edx,%ebx
  800a9b:	89 d7                	mov    %edx,%edi
  800a9d:	89 d6                	mov    %edx,%esi
  800a9f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5f                   	pop    %edi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	57                   	push   %edi
  800aaa:	56                   	push   %esi
  800aab:	53                   	push   %ebx
  800aac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aaf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab9:	8b 55 08             	mov    0x8(%ebp),%edx
  800abc:	89 cb                	mov    %ecx,%ebx
  800abe:	89 cf                	mov    %ecx,%edi
  800ac0:	89 ce                	mov    %ecx,%esi
  800ac2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ac4:	85 c0                	test   %eax,%eax
  800ac6:	7e 17                	jle    800adf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	50                   	push   %eax
  800acc:	6a 03                	push   $0x3
  800ace:	68 1f 21 80 00       	push   $0x80211f
  800ad3:	6a 23                	push   $0x23
  800ad5:	68 3c 21 80 00       	push   $0x80213c
  800ada:	e8 1a 0f 00 00       	call   8019f9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	b8 02 00 00 00       	mov    $0x2,%eax
  800af7:	89 d1                	mov    %edx,%ecx
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	89 d7                	mov    %edx,%edi
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_yield>:

void
sys_yield(void)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b2e:	be 00 00 00 00       	mov    $0x0,%esi
  800b33:	b8 04 00 00 00       	mov    $0x4,%eax
  800b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b41:	89 f7                	mov    %esi,%edi
  800b43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7e 17                	jle    800b60 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	6a 04                	push   $0x4
  800b4f:	68 1f 21 80 00       	push   $0x80211f
  800b54:	6a 23                	push   $0x23
  800b56:	68 3c 21 80 00       	push   $0x80213c
  800b5b:	e8 99 0e 00 00       	call   8019f9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
  800b6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b71:	b8 05 00 00 00       	mov    $0x5,%eax
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b82:	8b 75 18             	mov    0x18(%ebp),%esi
  800b85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 17                	jle    800ba2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 05                	push   $0x5
  800b91:	68 1f 21 80 00       	push   $0x80211f
  800b96:	6a 23                	push   $0x23
  800b98:	68 3c 21 80 00       	push   $0x80213c
  800b9d:	e8 57 0e 00 00       	call   8019f9 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb8:	b8 06 00 00 00       	mov    $0x6,%eax
  800bbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc3:	89 df                	mov    %ebx,%edi
  800bc5:	89 de                	mov    %ebx,%esi
  800bc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	7e 17                	jle    800be4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 06                	push   $0x6
  800bd3:	68 1f 21 80 00       	push   $0x80211f
  800bd8:	6a 23                	push   $0x23
  800bda:	68 3c 21 80 00       	push   $0x80213c
  800bdf:	e8 15 0e 00 00       	call   8019f9 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfa:	b8 08 00 00 00       	mov    $0x8,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 df                	mov    %ebx,%edi
  800c07:	89 de                	mov    %ebx,%esi
  800c09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 08                	push   $0x8
  800c15:	68 1f 21 80 00       	push   $0x80211f
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 3c 21 80 00       	push   $0x80213c
  800c21:	e8 d3 0d 00 00       	call   8019f9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3c:	b8 09 00 00 00       	mov    $0x9,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 df                	mov    %ebx,%edi
  800c49:	89 de                	mov    %ebx,%esi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 09                	push   $0x9
  800c57:	68 1f 21 80 00       	push   $0x80211f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 3c 21 80 00       	push   $0x80213c
  800c63:	e8 91 0d 00 00       	call   8019f9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 df                	mov    %ebx,%edi
  800c8b:	89 de                	mov    %ebx,%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 0a                	push   $0xa
  800c99:	68 1f 21 80 00       	push   $0x80211f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 3c 21 80 00       	push   $0x80213c
  800ca5:	e8 4f 0d 00 00       	call   8019f9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb8:	be 00 00 00 00       	mov    $0x0,%esi
  800cbd:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ccb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cce:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cde:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	89 cb                	mov    %ecx,%ebx
  800ced:	89 cf                	mov    %ecx,%edi
  800cef:	89 ce                	mov    %ecx,%esi
  800cf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7e 17                	jle    800d0e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	6a 0d                	push   $0xd
  800cfd:	68 1f 21 80 00       	push   $0x80211f
  800d02:	6a 23                	push   $0x23
  800d04:	68 3c 21 80 00       	push   $0x80213c
  800d09:	e8 eb 0c 00 00       	call   8019f9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d21:	c1 e8 0c             	shr    $0xc,%eax
}
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	05 00 00 00 30       	add    $0x30000000,%eax
  800d31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d36:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d43:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d48:	89 c2                	mov    %eax,%edx
  800d4a:	c1 ea 16             	shr    $0x16,%edx
  800d4d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d54:	f6 c2 01             	test   $0x1,%dl
  800d57:	74 11                	je     800d6a <fd_alloc+0x2d>
  800d59:	89 c2                	mov    %eax,%edx
  800d5b:	c1 ea 0c             	shr    $0xc,%edx
  800d5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d65:	f6 c2 01             	test   $0x1,%dl
  800d68:	75 09                	jne    800d73 <fd_alloc+0x36>
			*fd_store = fd;
  800d6a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d71:	eb 17                	jmp    800d8a <fd_alloc+0x4d>
  800d73:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d78:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d7d:	75 c9                	jne    800d48 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d7f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d85:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d92:	83 f8 1f             	cmp    $0x1f,%eax
  800d95:	77 36                	ja     800dcd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d97:	c1 e0 0c             	shl    $0xc,%eax
  800d9a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	c1 ea 16             	shr    $0x16,%edx
  800da4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dab:	f6 c2 01             	test   $0x1,%dl
  800dae:	74 24                	je     800dd4 <fd_lookup+0x48>
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	c1 ea 0c             	shr    $0xc,%edx
  800db5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbc:	f6 c2 01             	test   $0x1,%dl
  800dbf:	74 1a                	je     800ddb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc4:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	eb 13                	jmp    800de0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd2:	eb 0c                	jmp    800de0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dd4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd9:	eb 05                	jmp    800de0 <fd_lookup+0x54>
  800ddb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 08             	sub    $0x8,%esp
  800de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800deb:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800df0:	eb 13                	jmp    800e05 <dev_lookup+0x23>
  800df2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800df5:	39 08                	cmp    %ecx,(%eax)
  800df7:	75 0c                	jne    800e05 <dev_lookup+0x23>
			*dev = devtab[i];
  800df9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dfe:	b8 00 00 00 00       	mov    $0x0,%eax
  800e03:	eb 2e                	jmp    800e33 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e05:	8b 02                	mov    (%edx),%eax
  800e07:	85 c0                	test   %eax,%eax
  800e09:	75 e7                	jne    800df2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e0b:	a1 08 40 80 00       	mov    0x804008,%eax
  800e10:	8b 40 48             	mov    0x48(%eax),%eax
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	51                   	push   %ecx
  800e17:	50                   	push   %eax
  800e18:	68 4c 21 80 00       	push   $0x80214c
  800e1d:	e8 31 f3 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e25:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e2b:	83 c4 10             	add    $0x10,%esp
  800e2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	83 ec 10             	sub    $0x10,%esp
  800e3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800e40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e46:	50                   	push   %eax
  800e47:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e4d:	c1 e8 0c             	shr    $0xc,%eax
  800e50:	50                   	push   %eax
  800e51:	e8 36 ff ff ff       	call   800d8c <fd_lookup>
  800e56:	83 c4 08             	add    $0x8,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 05                	js     800e62 <fd_close+0x2d>
	    || fd != fd2)
  800e5d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e60:	74 0c                	je     800e6e <fd_close+0x39>
		return (must_exist ? r : 0);
  800e62:	84 db                	test   %bl,%bl
  800e64:	ba 00 00 00 00       	mov    $0x0,%edx
  800e69:	0f 44 c2             	cmove  %edx,%eax
  800e6c:	eb 41                	jmp    800eaf <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e6e:	83 ec 08             	sub    $0x8,%esp
  800e71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e74:	50                   	push   %eax
  800e75:	ff 36                	pushl  (%esi)
  800e77:	e8 66 ff ff ff       	call   800de2 <dev_lookup>
  800e7c:	89 c3                	mov    %eax,%ebx
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	78 1a                	js     800e9f <fd_close+0x6a>
		if (dev->dev_close)
  800e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e88:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e8b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e90:	85 c0                	test   %eax,%eax
  800e92:	74 0b                	je     800e9f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	56                   	push   %esi
  800e98:	ff d0                	call   *%eax
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e9f:	83 ec 08             	sub    $0x8,%esp
  800ea2:	56                   	push   %esi
  800ea3:	6a 00                	push   $0x0
  800ea5:	e8 00 fd ff ff       	call   800baa <sys_page_unmap>
	return r;
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	89 d8                	mov    %ebx,%eax
}
  800eaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb2:	5b                   	pop    %ebx
  800eb3:	5e                   	pop    %esi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ebf:	50                   	push   %eax
  800ec0:	ff 75 08             	pushl  0x8(%ebp)
  800ec3:	e8 c4 fe ff ff       	call   800d8c <fd_lookup>
  800ec8:	83 c4 08             	add    $0x8,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	78 10                	js     800edf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ecf:	83 ec 08             	sub    $0x8,%esp
  800ed2:	6a 01                	push   $0x1
  800ed4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed7:	e8 59 ff ff ff       	call   800e35 <fd_close>
  800edc:	83 c4 10             	add    $0x10,%esp
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <close_all>:

void
close_all(void)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	53                   	push   %ebx
  800ee5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	53                   	push   %ebx
  800ef1:	e8 c0 ff ff ff       	call   800eb6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef6:	83 c3 01             	add    $0x1,%ebx
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	83 fb 20             	cmp    $0x20,%ebx
  800eff:	75 ec                	jne    800eed <close_all+0xc>
		close(i);
}
  800f01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	83 ec 2c             	sub    $0x2c,%esp
  800f0f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f12:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f15:	50                   	push   %eax
  800f16:	ff 75 08             	pushl  0x8(%ebp)
  800f19:	e8 6e fe ff ff       	call   800d8c <fd_lookup>
  800f1e:	83 c4 08             	add    $0x8,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	0f 88 c1 00 00 00    	js     800fea <dup+0xe4>
		return r;
	close(newfdnum);
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	56                   	push   %esi
  800f2d:	e8 84 ff ff ff       	call   800eb6 <close>

	newfd = INDEX2FD(newfdnum);
  800f32:	89 f3                	mov    %esi,%ebx
  800f34:	c1 e3 0c             	shl    $0xc,%ebx
  800f37:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f3d:	83 c4 04             	add    $0x4,%esp
  800f40:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f43:	e8 de fd ff ff       	call   800d26 <fd2data>
  800f48:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f4a:	89 1c 24             	mov    %ebx,(%esp)
  800f4d:	e8 d4 fd ff ff       	call   800d26 <fd2data>
  800f52:	83 c4 10             	add    $0x10,%esp
  800f55:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f58:	89 f8                	mov    %edi,%eax
  800f5a:	c1 e8 16             	shr    $0x16,%eax
  800f5d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f64:	a8 01                	test   $0x1,%al
  800f66:	74 37                	je     800f9f <dup+0x99>
  800f68:	89 f8                	mov    %edi,%eax
  800f6a:	c1 e8 0c             	shr    $0xc,%eax
  800f6d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f74:	f6 c2 01             	test   $0x1,%dl
  800f77:	74 26                	je     800f9f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f79:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	25 07 0e 00 00       	and    $0xe07,%eax
  800f88:	50                   	push   %eax
  800f89:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f8c:	6a 00                	push   $0x0
  800f8e:	57                   	push   %edi
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 d2 fb ff ff       	call   800b68 <sys_page_map>
  800f96:	89 c7                	mov    %eax,%edi
  800f98:	83 c4 20             	add    $0x20,%esp
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	78 2e                	js     800fcd <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fa2:	89 d0                	mov    %edx,%eax
  800fa4:	c1 e8 0c             	shr    $0xc,%eax
  800fa7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fae:	83 ec 0c             	sub    $0xc,%esp
  800fb1:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb6:	50                   	push   %eax
  800fb7:	53                   	push   %ebx
  800fb8:	6a 00                	push   $0x0
  800fba:	52                   	push   %edx
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 a6 fb ff ff       	call   800b68 <sys_page_map>
  800fc2:	89 c7                	mov    %eax,%edi
  800fc4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fc7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc9:	85 ff                	test   %edi,%edi
  800fcb:	79 1d                	jns    800fea <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fcd:	83 ec 08             	sub    $0x8,%esp
  800fd0:	53                   	push   %ebx
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 d2 fb ff ff       	call   800baa <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd8:	83 c4 08             	add    $0x8,%esp
  800fdb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 c5 fb ff ff       	call   800baa <sys_page_unmap>
	return r;
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	89 f8                	mov    %edi,%eax
}
  800fea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5f                   	pop    %edi
  800ff0:	5d                   	pop    %ebp
  800ff1:	c3                   	ret    

00800ff2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	53                   	push   %ebx
  800ff6:	83 ec 14             	sub    $0x14,%esp
  800ff9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ffc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	53                   	push   %ebx
  801001:	e8 86 fd ff ff       	call   800d8c <fd_lookup>
  801006:	83 c4 08             	add    $0x8,%esp
  801009:	89 c2                	mov    %eax,%edx
  80100b:	85 c0                	test   %eax,%eax
  80100d:	78 6d                	js     80107c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801015:	50                   	push   %eax
  801016:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801019:	ff 30                	pushl  (%eax)
  80101b:	e8 c2 fd ff ff       	call   800de2 <dev_lookup>
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	85 c0                	test   %eax,%eax
  801025:	78 4c                	js     801073 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801027:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80102a:	8b 42 08             	mov    0x8(%edx),%eax
  80102d:	83 e0 03             	and    $0x3,%eax
  801030:	83 f8 01             	cmp    $0x1,%eax
  801033:	75 21                	jne    801056 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801035:	a1 08 40 80 00       	mov    0x804008,%eax
  80103a:	8b 40 48             	mov    0x48(%eax),%eax
  80103d:	83 ec 04             	sub    $0x4,%esp
  801040:	53                   	push   %ebx
  801041:	50                   	push   %eax
  801042:	68 8d 21 80 00       	push   $0x80218d
  801047:	e8 07 f1 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  80104c:	83 c4 10             	add    $0x10,%esp
  80104f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801054:	eb 26                	jmp    80107c <read+0x8a>
	}
	if (!dev->dev_read)
  801056:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801059:	8b 40 08             	mov    0x8(%eax),%eax
  80105c:	85 c0                	test   %eax,%eax
  80105e:	74 17                	je     801077 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	ff 75 10             	pushl  0x10(%ebp)
  801066:	ff 75 0c             	pushl  0xc(%ebp)
  801069:	52                   	push   %edx
  80106a:	ff d0                	call   *%eax
  80106c:	89 c2                	mov    %eax,%edx
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	eb 09                	jmp    80107c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801073:	89 c2                	mov    %eax,%edx
  801075:	eb 05                	jmp    80107c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801077:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80107c:	89 d0                	mov    %edx,%eax
  80107e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801081:	c9                   	leave  
  801082:	c3                   	ret    

00801083 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	57                   	push   %edi
  801087:	56                   	push   %esi
  801088:	53                   	push   %ebx
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801092:	bb 00 00 00 00       	mov    $0x0,%ebx
  801097:	eb 21                	jmp    8010ba <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	89 f0                	mov    %esi,%eax
  80109e:	29 d8                	sub    %ebx,%eax
  8010a0:	50                   	push   %eax
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	03 45 0c             	add    0xc(%ebp),%eax
  8010a6:	50                   	push   %eax
  8010a7:	57                   	push   %edi
  8010a8:	e8 45 ff ff ff       	call   800ff2 <read>
		if (m < 0)
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	78 10                	js     8010c4 <readn+0x41>
			return m;
		if (m == 0)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 0a                	je     8010c2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b8:	01 c3                	add    %eax,%ebx
  8010ba:	39 f3                	cmp    %esi,%ebx
  8010bc:	72 db                	jb     801099 <readn+0x16>
  8010be:	89 d8                	mov    %ebx,%eax
  8010c0:	eb 02                	jmp    8010c4 <readn+0x41>
  8010c2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    

008010cc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 14             	sub    $0x14,%esp
  8010d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	53                   	push   %ebx
  8010db:	e8 ac fc ff ff       	call   800d8c <fd_lookup>
  8010e0:	83 c4 08             	add    $0x8,%esp
  8010e3:	89 c2                	mov    %eax,%edx
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 68                	js     801151 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f3:	ff 30                	pushl  (%eax)
  8010f5:	e8 e8 fc ff ff       	call   800de2 <dev_lookup>
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	78 47                	js     801148 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801101:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801104:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801108:	75 21                	jne    80112b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80110a:	a1 08 40 80 00       	mov    0x804008,%eax
  80110f:	8b 40 48             	mov    0x48(%eax),%eax
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	53                   	push   %ebx
  801116:	50                   	push   %eax
  801117:	68 a9 21 80 00       	push   $0x8021a9
  80111c:	e8 32 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801129:	eb 26                	jmp    801151 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80112b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112e:	8b 52 0c             	mov    0xc(%edx),%edx
  801131:	85 d2                	test   %edx,%edx
  801133:	74 17                	je     80114c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	ff 75 10             	pushl  0x10(%ebp)
  80113b:	ff 75 0c             	pushl  0xc(%ebp)
  80113e:	50                   	push   %eax
  80113f:	ff d2                	call   *%edx
  801141:	89 c2                	mov    %eax,%edx
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	eb 09                	jmp    801151 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801148:	89 c2                	mov    %eax,%edx
  80114a:	eb 05                	jmp    801151 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80114c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801151:	89 d0                	mov    %edx,%eax
  801153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801156:	c9                   	leave  
  801157:	c3                   	ret    

00801158 <seek>:

int
seek(int fdnum, off_t offset)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801161:	50                   	push   %eax
  801162:	ff 75 08             	pushl  0x8(%ebp)
  801165:	e8 22 fc ff ff       	call   800d8c <fd_lookup>
  80116a:	83 c4 08             	add    $0x8,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 0e                	js     80117f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801171:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801174:	8b 55 0c             	mov    0xc(%ebp),%edx
  801177:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
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
  801190:	e8 f7 fb ff ff       	call   800d8c <fd_lookup>
  801195:	83 c4 08             	add    $0x8,%esp
  801198:	89 c2                	mov    %eax,%edx
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 65                	js     801203 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a4:	50                   	push   %eax
  8011a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a8:	ff 30                	pushl  (%eax)
  8011aa:	e8 33 fc ff ff       	call   800de2 <dev_lookup>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 44                	js     8011fa <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011bd:	75 21                	jne    8011e0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011bf:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011c4:	8b 40 48             	mov    0x48(%eax),%eax
  8011c7:	83 ec 04             	sub    $0x4,%esp
  8011ca:	53                   	push   %ebx
  8011cb:	50                   	push   %eax
  8011cc:	68 6c 21 80 00       	push   $0x80216c
  8011d1:	e8 7d ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011de:	eb 23                	jmp    801203 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e3:	8b 52 18             	mov    0x18(%edx),%edx
  8011e6:	85 d2                	test   %edx,%edx
  8011e8:	74 14                	je     8011fe <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011ea:	83 ec 08             	sub    $0x8,%esp
  8011ed:	ff 75 0c             	pushl  0xc(%ebp)
  8011f0:	50                   	push   %eax
  8011f1:	ff d2                	call   *%edx
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	eb 09                	jmp    801203 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	eb 05                	jmp    801203 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801203:	89 d0                	mov    %edx,%eax
  801205:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	53                   	push   %ebx
  80120e:	83 ec 14             	sub    $0x14,%esp
  801211:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801214:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801217:	50                   	push   %eax
  801218:	ff 75 08             	pushl  0x8(%ebp)
  80121b:	e8 6c fb ff ff       	call   800d8c <fd_lookup>
  801220:	83 c4 08             	add    $0x8,%esp
  801223:	89 c2                	mov    %eax,%edx
  801225:	85 c0                	test   %eax,%eax
  801227:	78 58                	js     801281 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801229:	83 ec 08             	sub    $0x8,%esp
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801233:	ff 30                	pushl  (%eax)
  801235:	e8 a8 fb ff ff       	call   800de2 <dev_lookup>
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 37                	js     801278 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801241:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801244:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801248:	74 32                	je     80127c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80124a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80124d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801254:	00 00 00 
	stat->st_isdir = 0;
  801257:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80125e:	00 00 00 
	stat->st_dev = dev;
  801261:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801267:	83 ec 08             	sub    $0x8,%esp
  80126a:	53                   	push   %ebx
  80126b:	ff 75 f0             	pushl  -0x10(%ebp)
  80126e:	ff 50 14             	call   *0x14(%eax)
  801271:	89 c2                	mov    %eax,%edx
  801273:	83 c4 10             	add    $0x10,%esp
  801276:	eb 09                	jmp    801281 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801278:	89 c2                	mov    %eax,%edx
  80127a:	eb 05                	jmp    801281 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80127c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801281:	89 d0                	mov    %edx,%eax
  801283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	6a 00                	push   $0x0
  801292:	ff 75 08             	pushl  0x8(%ebp)
  801295:	e8 dc 01 00 00       	call   801476 <open>
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 1b                	js     8012be <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012a3:	83 ec 08             	sub    $0x8,%esp
  8012a6:	ff 75 0c             	pushl  0xc(%ebp)
  8012a9:	50                   	push   %eax
  8012aa:	e8 5b ff ff ff       	call   80120a <fstat>
  8012af:	89 c6                	mov    %eax,%esi
	close(fd);
  8012b1:	89 1c 24             	mov    %ebx,(%esp)
  8012b4:	e8 fd fb ff ff       	call   800eb6 <close>
	return r;
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	89 f0                	mov    %esi,%eax
}
  8012be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	89 c6                	mov    %eax,%esi
  8012cc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012ce:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012d5:	75 12                	jne    8012e9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	6a 01                	push   $0x1
  8012dc:	e8 fe 07 00 00       	call   801adf <ipc_find_env>
  8012e1:	a3 00 40 80 00       	mov    %eax,0x804000
  8012e6:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e9:	6a 07                	push   $0x7
  8012eb:	68 00 50 80 00       	push   $0x805000
  8012f0:	56                   	push   %esi
  8012f1:	ff 35 00 40 80 00    	pushl  0x804000
  8012f7:	e8 a0 07 00 00       	call   801a9c <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8012fc:	83 c4 0c             	add    $0xc,%esp
  8012ff:	6a 00                	push   $0x0
  801301:	53                   	push   %ebx
  801302:	6a 00                	push   $0x0
  801304:	e8 36 07 00 00       	call   801a3f <ipc_recv>
}
  801309:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    

00801310 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801316:	8b 45 08             	mov    0x8(%ebp),%eax
  801319:	8b 40 0c             	mov    0xc(%eax),%eax
  80131c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801329:	ba 00 00 00 00       	mov    $0x0,%edx
  80132e:	b8 02 00 00 00       	mov    $0x2,%eax
  801333:	e8 8d ff ff ff       	call   8012c5 <fsipc>
}
  801338:	c9                   	leave  
  801339:	c3                   	ret    

0080133a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	8b 40 0c             	mov    0xc(%eax),%eax
  801346:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80134b:	ba 00 00 00 00       	mov    $0x0,%edx
  801350:	b8 06 00 00 00       	mov    $0x6,%eax
  801355:	e8 6b ff ff ff       	call   8012c5 <fsipc>
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	53                   	push   %ebx
  801360:	83 ec 04             	sub    $0x4,%esp
  801363:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801366:	8b 45 08             	mov    0x8(%ebp),%eax
  801369:	8b 40 0c             	mov    0xc(%eax),%eax
  80136c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
  801376:	b8 05 00 00 00       	mov    $0x5,%eax
  80137b:	e8 45 ff ff ff       	call   8012c5 <fsipc>
  801380:	85 c0                	test   %eax,%eax
  801382:	78 2c                	js     8013b0 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801384:	83 ec 08             	sub    $0x8,%esp
  801387:	68 00 50 80 00       	push   $0x805000
  80138c:	53                   	push   %ebx
  80138d:	e8 90 f3 ff ff       	call   800722 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801392:	a1 80 50 80 00       	mov    0x805080,%eax
  801397:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80139d:	a1 84 50 80 00       	mov    0x805084,%eax
  8013a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b3:	c9                   	leave  
  8013b4:	c3                   	ret    

008013b5 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013be:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8013c4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013ca:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013cf:	50                   	push   %eax
  8013d0:	ff 75 0c             	pushl  0xc(%ebp)
  8013d3:	68 08 50 80 00       	push   $0x805008
  8013d8:	e8 d7 f4 ff ff       	call   8008b4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e2:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e7:	e8 d9 fe ff ff       	call   8012c5 <fsipc>
	//panic("devfile_write not implemented");
}
  8013ec:	c9                   	leave  
  8013ed:	c3                   	ret    

008013ee <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801401:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801407:	ba 00 00 00 00       	mov    $0x0,%edx
  80140c:	b8 03 00 00 00       	mov    $0x3,%eax
  801411:	e8 af fe ff ff       	call   8012c5 <fsipc>
  801416:	89 c3                	mov    %eax,%ebx
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 51                	js     80146d <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80141c:	39 c6                	cmp    %eax,%esi
  80141e:	73 19                	jae    801439 <devfile_read+0x4b>
  801420:	68 d8 21 80 00       	push   $0x8021d8
  801425:	68 df 21 80 00       	push   $0x8021df
  80142a:	68 80 00 00 00       	push   $0x80
  80142f:	68 f4 21 80 00       	push   $0x8021f4
  801434:	e8 c0 05 00 00       	call   8019f9 <_panic>
	assert(r <= PGSIZE);
  801439:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80143e:	7e 19                	jle    801459 <devfile_read+0x6b>
  801440:	68 ff 21 80 00       	push   $0x8021ff
  801445:	68 df 21 80 00       	push   $0x8021df
  80144a:	68 81 00 00 00       	push   $0x81
  80144f:	68 f4 21 80 00       	push   $0x8021f4
  801454:	e8 a0 05 00 00       	call   8019f9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801459:	83 ec 04             	sub    $0x4,%esp
  80145c:	50                   	push   %eax
  80145d:	68 00 50 80 00       	push   $0x805000
  801462:	ff 75 0c             	pushl  0xc(%ebp)
  801465:	e8 4a f4 ff ff       	call   8008b4 <memmove>
	return r;
  80146a:	83 c4 10             	add    $0x10,%esp
}
  80146d:	89 d8                	mov    %ebx,%eax
  80146f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 20             	sub    $0x20,%esp
  80147d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801480:	53                   	push   %ebx
  801481:	e8 63 f2 ff ff       	call   8006e9 <strlen>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80148e:	7f 67                	jg     8014f7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801490:	83 ec 0c             	sub    $0xc,%esp
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	e8 a1 f8 ff ff       	call   800d3d <fd_alloc>
  80149c:	83 c4 10             	add    $0x10,%esp
		return r;
  80149f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 57                	js     8014fc <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	53                   	push   %ebx
  8014a9:	68 00 50 80 00       	push   $0x805000
  8014ae:	e8 6f f2 ff ff       	call   800722 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b6:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014be:	b8 01 00 00 00       	mov    $0x1,%eax
  8014c3:	e8 fd fd ff ff       	call   8012c5 <fsipc>
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	79 14                	jns    8014e5 <open+0x6f>
		
		fd_close(fd, 0);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	6a 00                	push   $0x0
  8014d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d9:	e8 57 f9 ff ff       	call   800e35 <fd_close>
		return r;
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	89 da                	mov    %ebx,%edx
  8014e3:	eb 17                	jmp    8014fc <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8014eb:	e8 26 f8 ff ff       	call   800d16 <fd2num>
  8014f0:	89 c2                	mov    %eax,%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 05                	jmp    8014fc <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014f7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8014fc:	89 d0                	mov    %edx,%eax
  8014fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801509:	ba 00 00 00 00       	mov    $0x0,%edx
  80150e:	b8 08 00 00 00       	mov    $0x8,%eax
  801513:	e8 ad fd ff ff       	call   8012c5 <fsipc>
}
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	56                   	push   %esi
  80151e:	53                   	push   %ebx
  80151f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801522:	83 ec 0c             	sub    $0xc,%esp
  801525:	ff 75 08             	pushl  0x8(%ebp)
  801528:	e8 f9 f7 ff ff       	call   800d26 <fd2data>
  80152d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80152f:	83 c4 08             	add    $0x8,%esp
  801532:	68 0b 22 80 00       	push   $0x80220b
  801537:	53                   	push   %ebx
  801538:	e8 e5 f1 ff ff       	call   800722 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80153d:	8b 46 04             	mov    0x4(%esi),%eax
  801540:	2b 06                	sub    (%esi),%eax
  801542:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801548:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80154f:	00 00 00 
	stat->st_dev = &devpipe;
  801552:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801559:	30 80 00 
	return 0;
}
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
  801561:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801564:	5b                   	pop    %ebx
  801565:	5e                   	pop    %esi
  801566:	5d                   	pop    %ebp
  801567:	c3                   	ret    

00801568 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	53                   	push   %ebx
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801572:	53                   	push   %ebx
  801573:	6a 00                	push   $0x0
  801575:	e8 30 f6 ff ff       	call   800baa <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80157a:	89 1c 24             	mov    %ebx,(%esp)
  80157d:	e8 a4 f7 ff ff       	call   800d26 <fd2data>
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	50                   	push   %eax
  801586:	6a 00                	push   $0x0
  801588:	e8 1d f6 ff ff       	call   800baa <sys_page_unmap>
}
  80158d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	57                   	push   %edi
  801596:	56                   	push   %esi
  801597:	53                   	push   %ebx
  801598:	83 ec 1c             	sub    $0x1c,%esp
  80159b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80159e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8015a5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015a8:	83 ec 0c             	sub    $0xc,%esp
  8015ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ae:	e8 65 05 00 00       	call   801b18 <pageref>
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	89 3c 24             	mov    %edi,(%esp)
  8015b8:	e8 5b 05 00 00       	call   801b18 <pageref>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	39 c3                	cmp    %eax,%ebx
  8015c2:	0f 94 c1             	sete   %cl
  8015c5:	0f b6 c9             	movzbl %cl,%ecx
  8015c8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015cb:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8015d1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015d4:	39 ce                	cmp    %ecx,%esi
  8015d6:	74 1b                	je     8015f3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015d8:	39 c3                	cmp    %eax,%ebx
  8015da:	75 c4                	jne    8015a0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015dc:	8b 42 58             	mov    0x58(%edx),%eax
  8015df:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e2:	50                   	push   %eax
  8015e3:	56                   	push   %esi
  8015e4:	68 12 22 80 00       	push   $0x802212
  8015e9:	e8 65 eb ff ff       	call   800153 <cprintf>
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	eb ad                	jmp    8015a0 <_pipeisclosed+0xe>
	}
}
  8015f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5e                   	pop    %esi
  8015fb:	5f                   	pop    %edi
  8015fc:	5d                   	pop    %ebp
  8015fd:	c3                   	ret    

008015fe <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	57                   	push   %edi
  801602:	56                   	push   %esi
  801603:	53                   	push   %ebx
  801604:	83 ec 28             	sub    $0x28,%esp
  801607:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80160a:	56                   	push   %esi
  80160b:	e8 16 f7 ff ff       	call   800d26 <fd2data>
  801610:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	bf 00 00 00 00       	mov    $0x0,%edi
  80161a:	eb 4b                	jmp    801667 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80161c:	89 da                	mov    %ebx,%edx
  80161e:	89 f0                	mov    %esi,%eax
  801620:	e8 6d ff ff ff       	call   801592 <_pipeisclosed>
  801625:	85 c0                	test   %eax,%eax
  801627:	75 48                	jne    801671 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801629:	e8 d8 f4 ff ff       	call   800b06 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80162e:	8b 43 04             	mov    0x4(%ebx),%eax
  801631:	8b 0b                	mov    (%ebx),%ecx
  801633:	8d 51 20             	lea    0x20(%ecx),%edx
  801636:	39 d0                	cmp    %edx,%eax
  801638:	73 e2                	jae    80161c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80163a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80163d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801641:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801644:	89 c2                	mov    %eax,%edx
  801646:	c1 fa 1f             	sar    $0x1f,%edx
  801649:	89 d1                	mov    %edx,%ecx
  80164b:	c1 e9 1b             	shr    $0x1b,%ecx
  80164e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801651:	83 e2 1f             	and    $0x1f,%edx
  801654:	29 ca                	sub    %ecx,%edx
  801656:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80165a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80165e:	83 c0 01             	add    $0x1,%eax
  801661:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801664:	83 c7 01             	add    $0x1,%edi
  801667:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80166a:	75 c2                	jne    80162e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80166c:	8b 45 10             	mov    0x10(%ebp),%eax
  80166f:	eb 05                	jmp    801676 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801679:	5b                   	pop    %ebx
  80167a:	5e                   	pop    %esi
  80167b:	5f                   	pop    %edi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 18             	sub    $0x18,%esp
  801687:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80168a:	57                   	push   %edi
  80168b:	e8 96 f6 ff ff       	call   800d26 <fd2data>
  801690:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801692:	83 c4 10             	add    $0x10,%esp
  801695:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169a:	eb 3d                	jmp    8016d9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80169c:	85 db                	test   %ebx,%ebx
  80169e:	74 04                	je     8016a4 <devpipe_read+0x26>
				return i;
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	eb 44                	jmp    8016e8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016a4:	89 f2                	mov    %esi,%edx
  8016a6:	89 f8                	mov    %edi,%eax
  8016a8:	e8 e5 fe ff ff       	call   801592 <_pipeisclosed>
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	75 32                	jne    8016e3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016b1:	e8 50 f4 ff ff       	call   800b06 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016b6:	8b 06                	mov    (%esi),%eax
  8016b8:	3b 46 04             	cmp    0x4(%esi),%eax
  8016bb:	74 df                	je     80169c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016bd:	99                   	cltd   
  8016be:	c1 ea 1b             	shr    $0x1b,%edx
  8016c1:	01 d0                	add    %edx,%eax
  8016c3:	83 e0 1f             	and    $0x1f,%eax
  8016c6:	29 d0                	sub    %edx,%eax
  8016c8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016d3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d6:	83 c3 01             	add    $0x1,%ebx
  8016d9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016dc:	75 d8                	jne    8016b6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016de:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e1:	eb 05                	jmp    8016e8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5f                   	pop    %edi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	e8 3c f6 ff ff       	call   800d3d <fd_alloc>
  801701:	83 c4 10             	add    $0x10,%esp
  801704:	89 c2                	mov    %eax,%edx
  801706:	85 c0                	test   %eax,%eax
  801708:	0f 88 2c 01 00 00    	js     80183a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	68 07 04 00 00       	push   $0x407
  801716:	ff 75 f4             	pushl  -0xc(%ebp)
  801719:	6a 00                	push   $0x0
  80171b:	e8 05 f4 ff ff       	call   800b25 <sys_page_alloc>
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	89 c2                	mov    %eax,%edx
  801725:	85 c0                	test   %eax,%eax
  801727:	0f 88 0d 01 00 00    	js     80183a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801733:	50                   	push   %eax
  801734:	e8 04 f6 ff ff       	call   800d3d <fd_alloc>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	0f 88 e2 00 00 00    	js     801828 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	68 07 04 00 00       	push   $0x407
  80174e:	ff 75 f0             	pushl  -0x10(%ebp)
  801751:	6a 00                	push   $0x0
  801753:	e8 cd f3 ff ff       	call   800b25 <sys_page_alloc>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	85 c0                	test   %eax,%eax
  80175f:	0f 88 c3 00 00 00    	js     801828 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	ff 75 f4             	pushl  -0xc(%ebp)
  80176b:	e8 b6 f5 ff ff       	call   800d26 <fd2data>
  801770:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801772:	83 c4 0c             	add    $0xc,%esp
  801775:	68 07 04 00 00       	push   $0x407
  80177a:	50                   	push   %eax
  80177b:	6a 00                	push   $0x0
  80177d:	e8 a3 f3 ff ff       	call   800b25 <sys_page_alloc>
  801782:	89 c3                	mov    %eax,%ebx
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	0f 88 89 00 00 00    	js     801818 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178f:	83 ec 0c             	sub    $0xc,%esp
  801792:	ff 75 f0             	pushl  -0x10(%ebp)
  801795:	e8 8c f5 ff ff       	call   800d26 <fd2data>
  80179a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017a1:	50                   	push   %eax
  8017a2:	6a 00                	push   $0x0
  8017a4:	56                   	push   %esi
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 bc f3 ff ff       	call   800b68 <sys_page_map>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 20             	add    $0x20,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 55                	js     80180a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017b5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017be:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017ca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017df:	83 ec 0c             	sub    $0xc,%esp
  8017e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e5:	e8 2c f5 ff ff       	call   800d16 <fd2num>
  8017ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ed:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017ef:	83 c4 04             	add    $0x4,%esp
  8017f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f5:	e8 1c f5 ff ff       	call   800d16 <fd2num>
  8017fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	eb 30                	jmp    80183a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80180a:	83 ec 08             	sub    $0x8,%esp
  80180d:	56                   	push   %esi
  80180e:	6a 00                	push   $0x0
  801810:	e8 95 f3 ff ff       	call   800baa <sys_page_unmap>
  801815:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801818:	83 ec 08             	sub    $0x8,%esp
  80181b:	ff 75 f0             	pushl  -0x10(%ebp)
  80181e:	6a 00                	push   $0x0
  801820:	e8 85 f3 ff ff       	call   800baa <sys_page_unmap>
  801825:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801828:	83 ec 08             	sub    $0x8,%esp
  80182b:	ff 75 f4             	pushl  -0xc(%ebp)
  80182e:	6a 00                	push   $0x0
  801830:	e8 75 f3 ff ff       	call   800baa <sys_page_unmap>
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801849:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184c:	50                   	push   %eax
  80184d:	ff 75 08             	pushl  0x8(%ebp)
  801850:	e8 37 f5 ff ff       	call   800d8c <fd_lookup>
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	78 18                	js     801874 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80185c:	83 ec 0c             	sub    $0xc,%esp
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 bf f4 ff ff       	call   800d26 <fd2data>
	return _pipeisclosed(fd, p);
  801867:	89 c2                	mov    %eax,%edx
  801869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186c:	e8 21 fd ff ff       	call   801592 <_pipeisclosed>
  801871:	83 c4 10             	add    $0x10,%esp
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
  80187e:	5d                   	pop    %ebp
  80187f:	c3                   	ret    

00801880 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801886:	68 2a 22 80 00       	push   $0x80222a
  80188b:	ff 75 0c             	pushl  0xc(%ebp)
  80188e:	e8 8f ee ff ff       	call   800722 <strcpy>
	return 0;
}
  801893:	b8 00 00 00 00       	mov    $0x0,%eax
  801898:	c9                   	leave  
  801899:	c3                   	ret    

0080189a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	57                   	push   %edi
  80189e:	56                   	push   %esi
  80189f:	53                   	push   %ebx
  8018a0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ab:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018b1:	eb 2d                	jmp    8018e0 <devcons_write+0x46>
		m = n - tot;
  8018b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018b6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018b8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018bb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018c0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018c3:	83 ec 04             	sub    $0x4,%esp
  8018c6:	53                   	push   %ebx
  8018c7:	03 45 0c             	add    0xc(%ebp),%eax
  8018ca:	50                   	push   %eax
  8018cb:	57                   	push   %edi
  8018cc:	e8 e3 ef ff ff       	call   8008b4 <memmove>
		sys_cputs(buf, m);
  8018d1:	83 c4 08             	add    $0x8,%esp
  8018d4:	53                   	push   %ebx
  8018d5:	57                   	push   %edi
  8018d6:	e8 8e f1 ff ff       	call   800a69 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018db:	01 de                	add    %ebx,%esi
  8018dd:	83 c4 10             	add    $0x10,%esp
  8018e0:	89 f0                	mov    %esi,%eax
  8018e2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018e5:	72 cc                	jb     8018b3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5f                   	pop    %edi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 08             	sub    $0x8,%esp
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018fa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018fe:	74 2a                	je     80192a <devcons_read+0x3b>
  801900:	eb 05                	jmp    801907 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801902:	e8 ff f1 ff ff       	call   800b06 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801907:	e8 7b f1 ff ff       	call   800a87 <sys_cgetc>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	74 f2                	je     801902 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801910:	85 c0                	test   %eax,%eax
  801912:	78 16                	js     80192a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801914:	83 f8 04             	cmp    $0x4,%eax
  801917:	74 0c                	je     801925 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191c:	88 02                	mov    %al,(%edx)
	return 1;
  80191e:	b8 01 00 00 00       	mov    $0x1,%eax
  801923:	eb 05                	jmp    80192a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
  801935:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801938:	6a 01                	push   $0x1
  80193a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80193d:	50                   	push   %eax
  80193e:	e8 26 f1 ff ff       	call   800a69 <sys_cputs>
}
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	c9                   	leave  
  801947:	c3                   	ret    

00801948 <getchar>:

int
getchar(void)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80194e:	6a 01                	push   $0x1
  801950:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801953:	50                   	push   %eax
  801954:	6a 00                	push   $0x0
  801956:	e8 97 f6 ff ff       	call   800ff2 <read>
	if (r < 0)
  80195b:	83 c4 10             	add    $0x10,%esp
  80195e:	85 c0                	test   %eax,%eax
  801960:	78 0f                	js     801971 <getchar+0x29>
		return r;
	if (r < 1)
  801962:	85 c0                	test   %eax,%eax
  801964:	7e 06                	jle    80196c <getchar+0x24>
		return -E_EOF;
	return c;
  801966:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80196a:	eb 05                	jmp    801971 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80196c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801971:	c9                   	leave  
  801972:	c3                   	ret    

00801973 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801979:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197c:	50                   	push   %eax
  80197d:	ff 75 08             	pushl  0x8(%ebp)
  801980:	e8 07 f4 ff ff       	call   800d8c <fd_lookup>
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 11                	js     80199d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801995:	39 10                	cmp    %edx,(%eax)
  801997:	0f 94 c0             	sete   %al
  80199a:	0f b6 c0             	movzbl %al,%eax
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <opencons>:

int
opencons(void)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a8:	50                   	push   %eax
  8019a9:	e8 8f f3 ff ff       	call   800d3d <fd_alloc>
  8019ae:	83 c4 10             	add    $0x10,%esp
		return r;
  8019b1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019b3:	85 c0                	test   %eax,%eax
  8019b5:	78 3e                	js     8019f5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b7:	83 ec 04             	sub    $0x4,%esp
  8019ba:	68 07 04 00 00       	push   $0x407
  8019bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c2:	6a 00                	push   $0x0
  8019c4:	e8 5c f1 ff ff       	call   800b25 <sys_page_alloc>
  8019c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019cc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 23                	js     8019f5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019d2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019db:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019e7:	83 ec 0c             	sub    $0xc,%esp
  8019ea:	50                   	push   %eax
  8019eb:	e8 26 f3 ff ff       	call   800d16 <fd2num>
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	83 c4 10             	add    $0x10,%esp
}
  8019f5:	89 d0                	mov    %edx,%eax
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a01:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a07:	e8 db f0 ff ff       	call   800ae7 <sys_getenvid>
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	ff 75 0c             	pushl  0xc(%ebp)
  801a12:	ff 75 08             	pushl  0x8(%ebp)
  801a15:	56                   	push   %esi
  801a16:	50                   	push   %eax
  801a17:	68 38 22 80 00       	push   $0x802238
  801a1c:	e8 32 e7 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a21:	83 c4 18             	add    $0x18,%esp
  801a24:	53                   	push   %ebx
  801a25:	ff 75 10             	pushl  0x10(%ebp)
  801a28:	e8 d5 e6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801a2d:	c7 04 24 0c 1e 80 00 	movl   $0x801e0c,(%esp)
  801a34:	e8 1a e7 ff ff       	call   800153 <cprintf>
  801a39:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a3c:	cc                   	int3   
  801a3d:	eb fd                	jmp    801a3c <_panic+0x43>

00801a3f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a47:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	e8 80 f2 ff ff       	call   800cd5 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 f6                	test   %esi,%esi
  801a5a:	74 1c                	je     801a78 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a5c:	a1 08 40 80 00       	mov    0x804008,%eax
  801a61:	8b 40 78             	mov    0x78(%eax),%eax
  801a64:	89 06                	mov    %eax,(%esi)
  801a66:	eb 10                	jmp    801a78 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	68 5c 22 80 00       	push   $0x80225c
  801a70:	e8 de e6 ff ff       	call   800153 <cprintf>
  801a75:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a78:	a1 08 40 80 00       	mov    0x804008,%eax
  801a7d:	8b 50 74             	mov    0x74(%eax),%edx
  801a80:	85 d2                	test   %edx,%edx
  801a82:	74 e4                	je     801a68 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a84:	85 db                	test   %ebx,%ebx
  801a86:	74 05                	je     801a8d <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a88:	8b 40 74             	mov    0x74(%eax),%eax
  801a8b:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a8d:	a1 08 40 80 00       	mov    0x804008,%eax
  801a92:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	57                   	push   %edi
  801aa0:	56                   	push   %esi
  801aa1:	53                   	push   %ebx
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801aae:	85 db                	test   %ebx,%ebx
  801ab0:	75 13                	jne    801ac5 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801ab2:	6a 00                	push   $0x0
  801ab4:	68 00 00 c0 ee       	push   $0xeec00000
  801ab9:	56                   	push   %esi
  801aba:	57                   	push   %edi
  801abb:	e8 f2 f1 ff ff       	call   800cb2 <sys_ipc_try_send>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	eb 0e                	jmp    801ad3 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ac5:	ff 75 14             	pushl  0x14(%ebp)
  801ac8:	53                   	push   %ebx
  801ac9:	56                   	push   %esi
  801aca:	57                   	push   %edi
  801acb:	e8 e2 f1 ff ff       	call   800cb2 <sys_ipc_try_send>
  801ad0:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	75 d7                	jne    801aae <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ad7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ada:	5b                   	pop    %ebx
  801adb:	5e                   	pop    %esi
  801adc:	5f                   	pop    %edi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aea:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aed:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af3:	8b 52 50             	mov    0x50(%edx),%edx
  801af6:	39 ca                	cmp    %ecx,%edx
  801af8:	75 0d                	jne    801b07 <ipc_find_env+0x28>
			return envs[i].env_id;
  801afa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801afd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b02:	8b 40 48             	mov    0x48(%eax),%eax
  801b05:	eb 0f                	jmp    801b16 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b07:	83 c0 01             	add    $0x1,%eax
  801b0a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b0f:	75 d9                	jne    801aea <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1e:	89 d0                	mov    %edx,%eax
  801b20:	c1 e8 16             	shr    $0x16,%eax
  801b23:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2f:	f6 c1 01             	test   $0x1,%cl
  801b32:	74 1d                	je     801b51 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b34:	c1 ea 0c             	shr    $0xc,%edx
  801b37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b3e:	f6 c2 01             	test   $0x1,%dl
  801b41:	74 0e                	je     801b51 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b43:	c1 ea 0c             	shr    $0xc,%edx
  801b46:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b4d:	ef 
  801b4e:	0f b7 c0             	movzwl %ax,%eax
}
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    
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
