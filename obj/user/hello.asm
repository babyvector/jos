
obj/user/hello:     file format elf32-i386


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
  800039:	68 a0 0f 80 00       	push   $0x800fa0
  80003e:	e8 06 01 00 00       	call   800149 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ae 0f 80 00       	push   $0x800fae
  800054:	e8 f0 00 00 00       	call   800149 <cprintf>

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
  800069:	e8 6f 0a 00 00       	call   800add <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 eb 09 00 00       	call   800a9c <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 1a                	jne    8000ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 79 09 00 00       	call   800a5f <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	ff 75 08             	pushl  0x8(%ebp)
  80011b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	68 b6 00 80 00       	push   $0x8000b6
  800127:	e8 54 01 00 00       	call   800280 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012c:	83 c4 08             	add    $0x8,%esp
  80012f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800135:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 1e 09 00 00       	call   800a5f <sys_cputs>

	return b.cnt;
}
  800141:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800152:	50                   	push   %eax
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	e8 9d ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 1c             	sub    $0x1c,%esp
  800166:	89 c7                	mov    %eax,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800173:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800176:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800179:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800181:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800184:	39 d3                	cmp    %edx,%ebx
  800186:	72 05                	jb     80018d <printnum+0x30>
  800188:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018b:	77 45                	ja     8001d2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	ff 75 18             	pushl  0x18(%ebp)
  800193:	8b 45 14             	mov    0x14(%ebp),%eax
  800196:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800199:	53                   	push   %ebx
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ac:	e8 5f 0b 00 00       	call   800d10 <__udivdi3>
  8001b1:	83 c4 18             	add    $0x18,%esp
  8001b4:	52                   	push   %edx
  8001b5:	50                   	push   %eax
  8001b6:	89 f2                	mov    %esi,%edx
  8001b8:	89 f8                	mov    %edi,%eax
  8001ba:	e8 9e ff ff ff       	call   80015d <printnum>
  8001bf:	83 c4 20             	add    $0x20,%esp
  8001c2:	eb 18                	jmp    8001dc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	56                   	push   %esi
  8001c8:	ff 75 18             	pushl  0x18(%ebp)
  8001cb:	ff d7                	call   *%edi
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	eb 03                	jmp    8001d5 <printnum+0x78>
  8001d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d5:	83 eb 01             	sub    $0x1,%ebx
  8001d8:	85 db                	test   %ebx,%ebx
  8001da:	7f e8                	jg     8001c4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	56                   	push   %esi
  8001e0:	83 ec 04             	sub    $0x4,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 4c 0c 00 00       	call   800e40 <__umoddi3>
  8001f4:	83 c4 14             	add    $0x14,%esp
  8001f7:	0f be 80 cf 0f 80 00 	movsbl 0x800fcf(%eax),%eax
  8001fe:	50                   	push   %eax
  8001ff:	ff d7                	call   *%edi
}
  800201:	83 c4 10             	add    $0x10,%esp
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020f:	83 fa 01             	cmp    $0x1,%edx
  800212:	7e 0e                	jle    800222 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800214:	8b 10                	mov    (%eax),%edx
  800216:	8d 4a 08             	lea    0x8(%edx),%ecx
  800219:	89 08                	mov    %ecx,(%eax)
  80021b:	8b 02                	mov    (%edx),%eax
  80021d:	8b 52 04             	mov    0x4(%edx),%edx
  800220:	eb 22                	jmp    800244 <getuint+0x38>
	else if (lflag)
  800222:	85 d2                	test   %edx,%edx
  800224:	74 10                	je     800236 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
  800234:	eb 0e                	jmp    800244 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800250:	8b 10                	mov    (%eax),%edx
  800252:	3b 50 04             	cmp    0x4(%eax),%edx
  800255:	73 0a                	jae    800261 <sprintputch+0x1b>
		*b->buf++ = ch;
  800257:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	88 02                	mov    %al,(%edx)
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800269:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 08             	pushl  0x8(%ebp)
  800276:	e8 05 00 00 00       	call   800280 <vprintfmt>
	va_end(ap);
}
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 2c             	sub    $0x2c,%esp
  800289:	8b 75 08             	mov    0x8(%ebp),%esi
  80028c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800292:	eb 12                	jmp    8002a6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800294:	85 c0                	test   %eax,%eax
  800296:	0f 84 d3 03 00 00    	je     80066f <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	53                   	push   %ebx
  8002a0:	50                   	push   %eax
  8002a1:	ff d6                	call   *%esi
  8002a3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a6:	83 c7 01             	add    $0x1,%edi
  8002a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ad:	83 f8 25             	cmp    $0x25,%eax
  8002b0:	75 e2                	jne    800294 <vprintfmt+0x14>
  8002b2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bd:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002c4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	eb 07                	jmp    8002d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d9:	8d 47 01             	lea    0x1(%edi),%eax
  8002dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002df:	0f b6 07             	movzbl (%edi),%eax
  8002e2:	0f b6 c8             	movzbl %al,%ecx
  8002e5:	83 e8 23             	sub    $0x23,%eax
  8002e8:	3c 55                	cmp    $0x55,%al
  8002ea:	0f 87 64 03 00 00    	ja     800654 <vprintfmt+0x3d4>
  8002f0:	0f b6 c0             	movzbl %al,%eax
  8002f3:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8002fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800301:	eb d6                	jmp    8002d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800306:	b8 00 00 00 00       	mov    $0x0,%eax
  80030b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800311:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800315:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800318:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031b:	83 fa 09             	cmp    $0x9,%edx
  80031e:	77 39                	ja     800359 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800320:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800323:	eb e9                	jmp    80030e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800325:	8b 45 14             	mov    0x14(%ebp),%eax
  800328:	8d 48 04             	lea    0x4(%eax),%ecx
  80032b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032e:	8b 00                	mov    (%eax),%eax
  800330:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800336:	eb 27                	jmp    80035f <vprintfmt+0xdf>
  800338:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033b:	85 c0                	test   %eax,%eax
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	0f 49 c8             	cmovns %eax,%ecx
  800345:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034b:	eb 8c                	jmp    8002d9 <vprintfmt+0x59>
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800350:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800357:	eb 80                	jmp    8002d9 <vprintfmt+0x59>
  800359:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80035f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800363:	0f 89 70 ff ff ff    	jns    8002d9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800369:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800376:	e9 5e ff ff ff       	jmp    8002d9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800381:	e9 53 ff ff ff       	jmp    8002d9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 50 04             	lea    0x4(%eax),%edx
  80038c:	89 55 14             	mov    %edx,0x14(%ebp)
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	53                   	push   %ebx
  800393:	ff 30                	pushl  (%eax)
  800395:	ff d6                	call   *%esi
			break;
  800397:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039d:	e9 04 ff ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 50 04             	lea    0x4(%eax),%edx
  8003a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	99                   	cltd   
  8003ae:	31 d0                	xor    %edx,%eax
  8003b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 08             	cmp    $0x8,%eax
  8003b5:	7f 0b                	jg     8003c2 <vprintfmt+0x142>
  8003b7:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	75 18                	jne    8003da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c2:	50                   	push   %eax
  8003c3:	68 e7 0f 80 00       	push   $0x800fe7
  8003c8:	53                   	push   %ebx
  8003c9:	56                   	push   %esi
  8003ca:	e8 94 fe ff ff       	call   800263 <printfmt>
  8003cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d5:	e9 cc fe ff ff       	jmp    8002a6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003da:	52                   	push   %edx
  8003db:	68 f0 0f 80 00       	push   $0x800ff0
  8003e0:	53                   	push   %ebx
  8003e1:	56                   	push   %esi
  8003e2:	e8 7c fe ff ff       	call   800263 <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ed:	e9 b4 fe ff ff       	jmp    8002a6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 50 04             	lea    0x4(%eax),%edx
  8003f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	b8 e0 0f 80 00       	mov    $0x800fe0,%eax
  800404:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 8e 94 00 00 00    	jle    8004a5 <vprintfmt+0x225>
  800411:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800415:	0f 84 98 00 00 00    	je     8004b3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	ff 75 c8             	pushl  -0x38(%ebp)
  800421:	57                   	push   %edi
  800422:	e8 d0 02 00 00       	call   8006f7 <strnlen>
  800427:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042a:	29 c1                	sub    %eax,%ecx
  80042c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80042f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800432:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043e:	eb 0f                	jmp    80044f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ef 01             	sub    $0x1,%edi
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	85 ff                	test   %edi,%edi
  800451:	7f ed                	jg     800440 <vprintfmt+0x1c0>
  800453:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800456:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800459:	85 c9                	test   %ecx,%ecx
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	0f 49 c1             	cmovns %ecx,%eax
  800463:	29 c1                	sub    %eax,%ecx
  800465:	89 75 08             	mov    %esi,0x8(%ebp)
  800468:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80046b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046e:	89 cb                	mov    %ecx,%ebx
  800470:	eb 4d                	jmp    8004bf <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800472:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800476:	74 1b                	je     800493 <vprintfmt+0x213>
  800478:	0f be c0             	movsbl %al,%eax
  80047b:	83 e8 20             	sub    $0x20,%eax
  80047e:	83 f8 5e             	cmp    $0x5e,%eax
  800481:	76 10                	jbe    800493 <vprintfmt+0x213>
					putch('?', putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 0c             	pushl  0xc(%ebp)
  800489:	6a 3f                	push   $0x3f
  80048b:	ff 55 08             	call   *0x8(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	eb 0d                	jmp    8004a0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 0c             	pushl  0xc(%ebp)
  800499:	52                   	push   %edx
  80049a:	ff 55 08             	call   *0x8(%ebp)
  80049d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a0:	83 eb 01             	sub    $0x1,%ebx
  8004a3:	eb 1a                	jmp    8004bf <vprintfmt+0x23f>
  8004a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a8:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b1:	eb 0c                	jmp    8004bf <vprintfmt+0x23f>
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bf:	83 c7 01             	add    $0x1,%edi
  8004c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c6:	0f be d0             	movsbl %al,%edx
  8004c9:	85 d2                	test   %edx,%edx
  8004cb:	74 23                	je     8004f0 <vprintfmt+0x270>
  8004cd:	85 f6                	test   %esi,%esi
  8004cf:	78 a1                	js     800472 <vprintfmt+0x1f2>
  8004d1:	83 ee 01             	sub    $0x1,%esi
  8004d4:	79 9c                	jns    800472 <vprintfmt+0x1f2>
  8004d6:	89 df                	mov    %ebx,%edi
  8004d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004de:	eb 18                	jmp    8004f8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	53                   	push   %ebx
  8004e4:	6a 20                	push   $0x20
  8004e6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e8:	83 ef 01             	sub    $0x1,%edi
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb 08                	jmp    8004f8 <vprintfmt+0x278>
  8004f0:	89 df                	mov    %ebx,%edi
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	85 ff                	test   %edi,%edi
  8004fa:	7f e4                	jg     8004e0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	e9 a2 fd ff ff       	jmp    8002a6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800504:	83 fa 01             	cmp    $0x1,%edx
  800507:	7e 16                	jle    80051f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 08             	lea    0x8(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 50 04             	mov    0x4(%eax),%edx
  800515:	8b 00                	mov    (%eax),%eax
  800517:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80051a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80051d:	eb 32                	jmp    800551 <vprintfmt+0x2d1>
	else if (lflag)
  80051f:	85 d2                	test   %edx,%edx
  800521:	74 18                	je     80053b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800531:	89 c1                	mov    %eax,%ecx
  800533:	c1 f9 1f             	sar    $0x1f,%ecx
  800536:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800539:	eb 16                	jmp    800551 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 00                	mov    (%eax),%eax
  800546:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800549:	89 c1                	mov    %eax,%ecx
  80054b:	c1 f9 1f             	sar    $0x1f,%ecx
  80054e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800551:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800554:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800562:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800566:	0f 89 b0 00 00 00    	jns    80061c <vprintfmt+0x39c>
				putch('-', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 2d                	push   $0x2d
  800572:	ff d6                	call   *%esi
				num = -(long long) num;
  800574:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800577:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80057a:	f7 d8                	neg    %eax
  80057c:	83 d2 00             	adc    $0x0,%edx
  80057f:	f7 da                	neg    %edx
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058f:	e9 88 00 00 00       	jmp    80061c <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800594:	8d 45 14             	lea    0x14(%ebp),%eax
  800597:	e8 70 fc ff ff       	call   80020c <getuint>
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a7:	eb 73                	jmp    80061c <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ac:	e8 5b fc ff ff       	call   80020c <getuint>
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005b7:	83 ec 08             	sub    $0x8,%esp
  8005ba:	53                   	push   %ebx
  8005bb:	6a 58                	push   $0x58
  8005bd:	ff d6                	call   *%esi
			putch('X', putdat);
  8005bf:	83 c4 08             	add    $0x8,%esp
  8005c2:	53                   	push   %ebx
  8005c3:	6a 58                	push   $0x58
  8005c5:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c7:	83 c4 08             	add    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 58                	push   $0x58
  8005cd:	ff d6                	call   *%esi
			goto number;
  8005cf:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005d2:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005d7:	eb 43                	jmp    80061c <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 30                	push   $0x30
  8005df:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e1:	83 c4 08             	add    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	6a 78                	push   $0x78
  8005e7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005ff:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800602:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800607:	eb 13                	jmp    80061c <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800609:	8d 45 14             	lea    0x14(%ebp),%eax
  80060c:	e8 fb fb ff ff       	call   80020c <getuint>
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80061c:	83 ec 0c             	sub    $0xc,%esp
  80061f:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800623:	52                   	push   %edx
  800624:	ff 75 e0             	pushl  -0x20(%ebp)
  800627:	50                   	push   %eax
  800628:	ff 75 dc             	pushl  -0x24(%ebp)
  80062b:	ff 75 d8             	pushl  -0x28(%ebp)
  80062e:	89 da                	mov    %ebx,%edx
  800630:	89 f0                	mov    %esi,%eax
  800632:	e8 26 fb ff ff       	call   80015d <printnum>
			break;
  800637:	83 c4 20             	add    $0x20,%esp
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063d:	e9 64 fc ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	53                   	push   %ebx
  800646:	51                   	push   %ecx
  800647:	ff d6                	call   *%esi
			break;
  800649:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064f:	e9 52 fc ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 25                	push   $0x25
  80065a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065c:	83 c4 10             	add    $0x10,%esp
  80065f:	eb 03                	jmp    800664 <vprintfmt+0x3e4>
  800661:	83 ef 01             	sub    $0x1,%edi
  800664:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800668:	75 f7                	jne    800661 <vprintfmt+0x3e1>
  80066a:	e9 37 fc ff ff       	jmp    8002a6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800672:	5b                   	pop    %ebx
  800673:	5e                   	pop    %esi
  800674:	5f                   	pop    %edi
  800675:	5d                   	pop    %ebp
  800676:	c3                   	ret    

00800677 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	83 ec 18             	sub    $0x18,%esp
  80067d:	8b 45 08             	mov    0x8(%ebp),%eax
  800680:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800683:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800686:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800694:	85 c0                	test   %eax,%eax
  800696:	74 26                	je     8006be <vsnprintf+0x47>
  800698:	85 d2                	test   %edx,%edx
  80069a:	7e 22                	jle    8006be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069c:	ff 75 14             	pushl  0x14(%ebp)
  80069f:	ff 75 10             	pushl  0x10(%ebp)
  8006a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a5:	50                   	push   %eax
  8006a6:	68 46 02 80 00       	push   $0x800246
  8006ab:	e8 d0 fb ff ff       	call   800280 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	eb 05                	jmp    8006c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c3:	c9                   	leave  
  8006c4:	c3                   	ret    

008006c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006ce:	50                   	push   %eax
  8006cf:	ff 75 10             	pushl  0x10(%ebp)
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	ff 75 08             	pushl  0x8(%ebp)
  8006d8:	e8 9a ff ff ff       	call   800677 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	eb 03                	jmp    8006ef <strlen+0x10>
		n++;
  8006ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f3:	75 f7                	jne    8006ec <strlen+0xd>
		n++;
	return n;
}
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800700:	ba 00 00 00 00       	mov    $0x0,%edx
  800705:	eb 03                	jmp    80070a <strnlen+0x13>
		n++;
  800707:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070a:	39 c2                	cmp    %eax,%edx
  80070c:	74 08                	je     800716 <strnlen+0x1f>
  80070e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800712:	75 f3                	jne    800707 <strnlen+0x10>
  800714:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800722:	89 c2                	mov    %eax,%edx
  800724:	83 c2 01             	add    $0x1,%edx
  800727:	83 c1 01             	add    $0x1,%ecx
  80072a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800731:	84 db                	test   %bl,%bl
  800733:	75 ef                	jne    800724 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800735:	5b                   	pop    %ebx
  800736:	5d                   	pop    %ebp
  800737:	c3                   	ret    

00800738 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800738:	55                   	push   %ebp
  800739:	89 e5                	mov    %esp,%ebp
  80073b:	53                   	push   %ebx
  80073c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073f:	53                   	push   %ebx
  800740:	e8 9a ff ff ff       	call   8006df <strlen>
  800745:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	01 d8                	add    %ebx,%eax
  80074d:	50                   	push   %eax
  80074e:	e8 c5 ff ff ff       	call   800718 <strcpy>
	return dst;
}
  800753:	89 d8                	mov    %ebx,%eax
  800755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	56                   	push   %esi
  80075e:	53                   	push   %ebx
  80075f:	8b 75 08             	mov    0x8(%ebp),%esi
  800762:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800765:	89 f3                	mov    %esi,%ebx
  800767:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076a:	89 f2                	mov    %esi,%edx
  80076c:	eb 0f                	jmp    80077d <strncpy+0x23>
		*dst++ = *src;
  80076e:	83 c2 01             	add    $0x1,%edx
  800771:	0f b6 01             	movzbl (%ecx),%eax
  800774:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800777:	80 39 01             	cmpb   $0x1,(%ecx)
  80077a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077d:	39 da                	cmp    %ebx,%edx
  80077f:	75 ed                	jne    80076e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800781:	89 f0                	mov    %esi,%eax
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	8b 55 10             	mov    0x10(%ebp),%edx
  800795:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800797:	85 d2                	test   %edx,%edx
  800799:	74 21                	je     8007bc <strlcpy+0x35>
  80079b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079f:	89 f2                	mov    %esi,%edx
  8007a1:	eb 09                	jmp    8007ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ac:	39 c2                	cmp    %eax,%edx
  8007ae:	74 09                	je     8007b9 <strlcpy+0x32>
  8007b0:	0f b6 19             	movzbl (%ecx),%ebx
  8007b3:	84 db                	test   %bl,%bl
  8007b5:	75 ec                	jne    8007a3 <strlcpy+0x1c>
  8007b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bc:	29 f0                	sub    %esi,%eax
}
  8007be:	5b                   	pop    %ebx
  8007bf:	5e                   	pop    %esi
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cb:	eb 06                	jmp    8007d3 <strcmp+0x11>
		p++, q++;
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d3:	0f b6 01             	movzbl (%ecx),%eax
  8007d6:	84 c0                	test   %al,%al
  8007d8:	74 04                	je     8007de <strcmp+0x1c>
  8007da:	3a 02                	cmp    (%edx),%al
  8007dc:	74 ef                	je     8007cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007de:	0f b6 c0             	movzbl %al,%eax
  8007e1:	0f b6 12             	movzbl (%edx),%edx
  8007e4:	29 d0                	sub    %edx,%eax
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	53                   	push   %ebx
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	89 c3                	mov    %eax,%ebx
  8007f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f7:	eb 06                	jmp    8007ff <strncmp+0x17>
		n--, p++, q++;
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ff:	39 d8                	cmp    %ebx,%eax
  800801:	74 15                	je     800818 <strncmp+0x30>
  800803:	0f b6 08             	movzbl (%eax),%ecx
  800806:	84 c9                	test   %cl,%cl
  800808:	74 04                	je     80080e <strncmp+0x26>
  80080a:	3a 0a                	cmp    (%edx),%cl
  80080c:	74 eb                	je     8007f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080e:	0f b6 00             	movzbl (%eax),%eax
  800811:	0f b6 12             	movzbl (%edx),%edx
  800814:	29 d0                	sub    %edx,%eax
  800816:	eb 05                	jmp    80081d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081d:	5b                   	pop    %ebx
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082a:	eb 07                	jmp    800833 <strchr+0x13>
		if (*s == c)
  80082c:	38 ca                	cmp    %cl,%dl
  80082e:	74 0f                	je     80083f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800830:	83 c0 01             	add    $0x1,%eax
  800833:	0f b6 10             	movzbl (%eax),%edx
  800836:	84 d2                	test   %dl,%dl
  800838:	75 f2                	jne    80082c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084b:	eb 03                	jmp    800850 <strfind+0xf>
  80084d:	83 c0 01             	add    $0x1,%eax
  800850:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800853:	38 ca                	cmp    %cl,%dl
  800855:	74 04                	je     80085b <strfind+0x1a>
  800857:	84 d2                	test   %dl,%dl
  800859:	75 f2                	jne    80084d <strfind+0xc>
			break;
	return (char *) s;
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	57                   	push   %edi
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 7d 08             	mov    0x8(%ebp),%edi
  800866:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800869:	85 c9                	test   %ecx,%ecx
  80086b:	74 36                	je     8008a3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800873:	75 28                	jne    80089d <memset+0x40>
  800875:	f6 c1 03             	test   $0x3,%cl
  800878:	75 23                	jne    80089d <memset+0x40>
		c &= 0xFF;
  80087a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087e:	89 d3                	mov    %edx,%ebx
  800880:	c1 e3 08             	shl    $0x8,%ebx
  800883:	89 d6                	mov    %edx,%esi
  800885:	c1 e6 18             	shl    $0x18,%esi
  800888:	89 d0                	mov    %edx,%eax
  80088a:	c1 e0 10             	shl    $0x10,%eax
  80088d:	09 f0                	or     %esi,%eax
  80088f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800891:	89 d8                	mov    %ebx,%eax
  800893:	09 d0                	or     %edx,%eax
  800895:	c1 e9 02             	shr    $0x2,%ecx
  800898:	fc                   	cld    
  800899:	f3 ab                	rep stos %eax,%es:(%edi)
  80089b:	eb 06                	jmp    8008a3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	fc                   	cld    
  8008a1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a3:	89 f8                	mov    %edi,%eax
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5f                   	pop    %edi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	57                   	push   %edi
  8008ae:	56                   	push   %esi
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b8:	39 c6                	cmp    %eax,%esi
  8008ba:	73 35                	jae    8008f1 <memmove+0x47>
  8008bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bf:	39 d0                	cmp    %edx,%eax
  8008c1:	73 2e                	jae    8008f1 <memmove+0x47>
		s += n;
		d += n;
  8008c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c6:	89 d6                	mov    %edx,%esi
  8008c8:	09 fe                	or     %edi,%esi
  8008ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d0:	75 13                	jne    8008e5 <memmove+0x3b>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 0e                	jne    8008e5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d7:	83 ef 04             	sub    $0x4,%edi
  8008da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008dd:	c1 e9 02             	shr    $0x2,%ecx
  8008e0:	fd                   	std    
  8008e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e3:	eb 09                	jmp    8008ee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e5:	83 ef 01             	sub    $0x1,%edi
  8008e8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008eb:	fd                   	std    
  8008ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ee:	fc                   	cld    
  8008ef:	eb 1d                	jmp    80090e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f1:	89 f2                	mov    %esi,%edx
  8008f3:	09 c2                	or     %eax,%edx
  8008f5:	f6 c2 03             	test   $0x3,%dl
  8008f8:	75 0f                	jne    800909 <memmove+0x5f>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 0a                	jne    800909 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ff:	c1 e9 02             	shr    $0x2,%ecx
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800907:	eb 05                	jmp    80090e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800915:	ff 75 10             	pushl  0x10(%ebp)
  800918:	ff 75 0c             	pushl  0xc(%ebp)
  80091b:	ff 75 08             	pushl  0x8(%ebp)
  80091e:	e8 87 ff ff ff       	call   8008aa <memmove>
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    

00800925 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 c6                	mov    %eax,%esi
  800932:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800935:	eb 1a                	jmp    800951 <memcmp+0x2c>
		if (*s1 != *s2)
  800937:	0f b6 08             	movzbl (%eax),%ecx
  80093a:	0f b6 1a             	movzbl (%edx),%ebx
  80093d:	38 d9                	cmp    %bl,%cl
  80093f:	74 0a                	je     80094b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800941:	0f b6 c1             	movzbl %cl,%eax
  800944:	0f b6 db             	movzbl %bl,%ebx
  800947:	29 d8                	sub    %ebx,%eax
  800949:	eb 0f                	jmp    80095a <memcmp+0x35>
		s1++, s2++;
  80094b:	83 c0 01             	add    $0x1,%eax
  80094e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800951:	39 f0                	cmp    %esi,%eax
  800953:	75 e2                	jne    800937 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	53                   	push   %ebx
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800965:	89 c1                	mov    %eax,%ecx
  800967:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096e:	eb 0a                	jmp    80097a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800970:	0f b6 10             	movzbl (%eax),%edx
  800973:	39 da                	cmp    %ebx,%edx
  800975:	74 07                	je     80097e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800977:	83 c0 01             	add    $0x1,%eax
  80097a:	39 c8                	cmp    %ecx,%eax
  80097c:	72 f2                	jb     800970 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098d:	eb 03                	jmp    800992 <strtol+0x11>
		s++;
  80098f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800992:	0f b6 01             	movzbl (%ecx),%eax
  800995:	3c 20                	cmp    $0x20,%al
  800997:	74 f6                	je     80098f <strtol+0xe>
  800999:	3c 09                	cmp    $0x9,%al
  80099b:	74 f2                	je     80098f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099d:	3c 2b                	cmp    $0x2b,%al
  80099f:	75 0a                	jne    8009ab <strtol+0x2a>
		s++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a9:	eb 11                	jmp    8009bc <strtol+0x3b>
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b0:	3c 2d                	cmp    $0x2d,%al
  8009b2:	75 08                	jne    8009bc <strtol+0x3b>
		s++, neg = 1;
  8009b4:	83 c1 01             	add    $0x1,%ecx
  8009b7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c2:	75 15                	jne    8009d9 <strtol+0x58>
  8009c4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c7:	75 10                	jne    8009d9 <strtol+0x58>
  8009c9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cd:	75 7c                	jne    800a4b <strtol+0xca>
		s += 2, base = 16;
  8009cf:	83 c1 02             	add    $0x2,%ecx
  8009d2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d7:	eb 16                	jmp    8009ef <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d9:	85 db                	test   %ebx,%ebx
  8009db:	75 12                	jne    8009ef <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009dd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e5:	75 08                	jne    8009ef <strtol+0x6e>
		s++, base = 8;
  8009e7:	83 c1 01             	add    $0x1,%ecx
  8009ea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f7:	0f b6 11             	movzbl (%ecx),%edx
  8009fa:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fd:	89 f3                	mov    %esi,%ebx
  8009ff:	80 fb 09             	cmp    $0x9,%bl
  800a02:	77 08                	ja     800a0c <strtol+0x8b>
			dig = *s - '0';
  800a04:	0f be d2             	movsbl %dl,%edx
  800a07:	83 ea 30             	sub    $0x30,%edx
  800a0a:	eb 22                	jmp    800a2e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0f:	89 f3                	mov    %esi,%ebx
  800a11:	80 fb 19             	cmp    $0x19,%bl
  800a14:	77 08                	ja     800a1e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a16:	0f be d2             	movsbl %dl,%edx
  800a19:	83 ea 57             	sub    $0x57,%edx
  800a1c:	eb 10                	jmp    800a2e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a21:	89 f3                	mov    %esi,%ebx
  800a23:	80 fb 19             	cmp    $0x19,%bl
  800a26:	77 16                	ja     800a3e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a28:	0f be d2             	movsbl %dl,%edx
  800a2b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a31:	7d 0b                	jge    800a3e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3c:	eb b9                	jmp    8009f7 <strtol+0x76>

	if (endptr)
  800a3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a42:	74 0d                	je     800a51 <strtol+0xd0>
		*endptr = (char *) s;
  800a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a47:	89 0e                	mov    %ecx,(%esi)
  800a49:	eb 06                	jmp    800a51 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4b:	85 db                	test   %ebx,%ebx
  800a4d:	74 98                	je     8009e7 <strtol+0x66>
  800a4f:	eb 9e                	jmp    8009ef <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	f7 da                	neg    %edx
  800a55:	85 ff                	test   %edi,%edi
  800a57:	0f 45 c2             	cmovne %edx,%eax
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a70:	89 c3                	mov    %eax,%ebx
  800a72:	89 c7                	mov    %eax,%edi
  800a74:	89 c6                	mov    %eax,%esi
  800a76:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8d:	89 d1                	mov    %edx,%ecx
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	89 d7                	mov    %edx,%edi
  800a93:	89 d6                	mov    %edx,%esi
  800a95:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaa:	b8 03 00 00 00       	mov    $0x3,%eax
  800aaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab2:	89 cb                	mov    %ecx,%ebx
  800ab4:	89 cf                	mov    %ecx,%edi
  800ab6:	89 ce                	mov    %ecx,%esi
  800ab8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	7e 17                	jle    800ad5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abe:	83 ec 0c             	sub    $0xc,%esp
  800ac1:	50                   	push   %eax
  800ac2:	6a 03                	push   $0x3
  800ac4:	68 24 12 80 00       	push   $0x801224
  800ac9:	6a 23                	push   $0x23
  800acb:	68 41 12 80 00       	push   $0x801241
  800ad0:	e8 f5 01 00 00       	call   800cca <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	57                   	push   %edi
  800ae1:	56                   	push   %esi
  800ae2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae8:	b8 02 00 00 00       	mov    $0x2,%eax
  800aed:	89 d1                	mov    %edx,%ecx
  800aef:	89 d3                	mov    %edx,%ebx
  800af1:	89 d7                	mov    %edx,%edi
  800af3:	89 d6                	mov    %edx,%esi
  800af5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_yield>:

void
sys_yield(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b24:	be 00 00 00 00       	mov    $0x0,%esi
  800b29:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b31:	8b 55 08             	mov    0x8(%ebp),%edx
  800b34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b37:	89 f7                	mov    %esi,%edi
  800b39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	7e 17                	jle    800b56 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	50                   	push   %eax
  800b43:	6a 04                	push   $0x4
  800b45:	68 24 12 80 00       	push   $0x801224
  800b4a:	6a 23                	push   $0x23
  800b4c:	68 41 12 80 00       	push   $0x801241
  800b51:	e8 74 01 00 00       	call   800cca <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b67:	b8 05 00 00 00       	mov    $0x5,%eax
  800b6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b78:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 05                	push   $0x5
  800b87:	68 24 12 80 00       	push   $0x801224
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 41 12 80 00       	push   $0x801241
  800b93:	e8 32 01 00 00       	call   800cca <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bae:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	89 df                	mov    %ebx,%edi
  800bbb:	89 de                	mov    %ebx,%esi
  800bbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7e 17                	jle    800bda <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	50                   	push   %eax
  800bc7:	6a 06                	push   $0x6
  800bc9:	68 24 12 80 00       	push   $0x801224
  800bce:	6a 23                	push   $0x23
  800bd0:	68 41 12 80 00       	push   $0x801241
  800bd5:	e8 f0 00 00 00       	call   800cca <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800beb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	89 df                	mov    %ebx,%edi
  800bfd:	89 de                	mov    %ebx,%esi
  800bff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7e 17                	jle    800c1c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	50                   	push   %eax
  800c09:	6a 08                	push   $0x8
  800c0b:	68 24 12 80 00       	push   $0x801224
  800c10:	6a 23                	push   $0x23
  800c12:	68 41 12 80 00       	push   $0x801241
  800c17:	e8 ae 00 00 00       	call   800cca <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	b8 09 00 00 00       	mov    $0x9,%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7e 17                	jle    800c5e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c47:	83 ec 0c             	sub    $0xc,%esp
  800c4a:	50                   	push   %eax
  800c4b:	6a 09                	push   $0x9
  800c4d:	68 24 12 80 00       	push   $0x801224
  800c52:	6a 23                	push   $0x23
  800c54:	68 41 12 80 00       	push   $0x801241
  800c59:	e8 6c 00 00 00       	call   800cca <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c61:	5b                   	pop    %ebx
  800c62:	5e                   	pop    %esi
  800c63:	5f                   	pop    %edi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c6c:	be 00 00 00 00       	mov    $0x0,%esi
  800c71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c82:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c97:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 cb                	mov    %ecx,%ebx
  800ca1:	89 cf                	mov    %ecx,%edi
  800ca3:	89 ce                	mov    %ecx,%esi
  800ca5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7e 17                	jle    800cc2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cab:	83 ec 0c             	sub    $0xc,%esp
  800cae:	50                   	push   %eax
  800caf:	6a 0c                	push   $0xc
  800cb1:	68 24 12 80 00       	push   $0x801224
  800cb6:	6a 23                	push   $0x23
  800cb8:	68 41 12 80 00       	push   $0x801241
  800cbd:	e8 08 00 00 00       	call   800cca <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ccf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cd2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cd8:	e8 00 fe ff ff       	call   800add <sys_getenvid>
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	ff 75 0c             	pushl  0xc(%ebp)
  800ce3:	ff 75 08             	pushl  0x8(%ebp)
  800ce6:	56                   	push   %esi
  800ce7:	50                   	push   %eax
  800ce8:	68 50 12 80 00       	push   $0x801250
  800ced:	e8 57 f4 ff ff       	call   800149 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cf2:	83 c4 18             	add    $0x18,%esp
  800cf5:	53                   	push   %ebx
  800cf6:	ff 75 10             	pushl  0x10(%ebp)
  800cf9:	e8 fa f3 ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  800cfe:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  800d05:	e8 3f f4 ff ff       	call   800149 <cprintf>
  800d0a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d0d:	cc                   	int3   
  800d0e:	eb fd                	jmp    800d0d <_panic+0x43>

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 f6                	test   %esi,%esi
  800d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2d:	89 ca                	mov    %ecx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	75 3d                	jne    800d70 <__udivdi3+0x60>
  800d33:	39 cf                	cmp    %ecx,%edi
  800d35:	0f 87 c5 00 00 00    	ja     800e00 <__udivdi3+0xf0>
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	89 fd                	mov    %edi,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f7                	div    %edi
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 c8                	mov    %ecx,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c1                	mov    %eax,%ecx
  800d54:	89 d8                	mov    %ebx,%eax
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	f7 f5                	div    %ebp
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 d8                	mov    %ebx,%eax
  800d5e:	89 fa                	mov    %edi,%edx
  800d60:	83 c4 1c             	add    $0x1c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	90                   	nop
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	39 ce                	cmp    %ecx,%esi
  800d72:	77 74                	ja     800de8 <__udivdi3+0xd8>
  800d74:	0f bd fe             	bsr    %esi,%edi
  800d77:	83 f7 1f             	xor    $0x1f,%edi
  800d7a:	0f 84 98 00 00 00    	je     800e18 <__udivdi3+0x108>
  800d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	89 c5                	mov    %eax,%ebp
  800d89:	29 fb                	sub    %edi,%ebx
  800d8b:	d3 e6                	shl    %cl,%esi
  800d8d:	89 d9                	mov    %ebx,%ecx
  800d8f:	d3 ed                	shr    %cl,%ebp
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	09 ee                	or     %ebp,%esi
  800d97:	89 d9                	mov    %ebx,%ecx
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	89 d5                	mov    %edx,%ebp
  800d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da3:	d3 ed                	shr    %cl,%ebp
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	89 d9                	mov    %ebx,%ecx
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	09 c2                	or     %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	f7 f6                	div    %esi
  800db5:	89 d5                	mov    %edx,%ebp
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	f7 64 24 0c          	mull   0xc(%esp)
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	72 10                	jb     800dd1 <__udivdi3+0xc1>
  800dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e6                	shl    %cl,%esi
  800dc9:	39 c6                	cmp    %eax,%esi
  800dcb:	73 07                	jae    800dd4 <__udivdi3+0xc4>
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	75 03                	jne    800dd4 <__udivdi3+0xc4>
  800dd1:	83 eb 01             	sub    $0x1,%ebx
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	f7 f7                	div    %edi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	39 ce                	cmp    %ecx,%esi
  800e1a:	72 0c                	jb     800e28 <__udivdi3+0x118>
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e22:	0f 87 34 ff ff ff    	ja     800d5c <__udivdi3+0x4c>
  800e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e2d:	e9 2a ff ff ff       	jmp    800d5c <__udivdi3+0x4c>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 d2                	test   %edx,%edx
  800e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f3                	mov    %esi,%ebx
  800e63:	89 3c 24             	mov    %edi,(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	75 1c                	jne    800e88 <__umoddi3+0x48>
  800e6c:	39 f7                	cmp    %esi,%edi
  800e6e:	76 50                	jbe    800ec0 <__umoddi3+0x80>
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	f7 f7                	div    %edi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	77 52                	ja     800ee0 <__umoddi3+0xa0>
  800e8e:	0f bd ea             	bsr    %edx,%ebp
  800e91:	83 f5 1f             	xor    $0x1f,%ebp
  800e94:	75 5a                	jne    800ef0 <__umoddi3+0xb0>
  800e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e9a:	0f 82 e0 00 00 00    	jb     800f80 <__umoddi3+0x140>
  800ea0:	39 0c 24             	cmp    %ecx,(%esp)
  800ea3:	0f 86 d7 00 00 00    	jbe    800f80 <__umoddi3+0x140>
  800ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	89 fd                	mov    %edi,%ebp
  800ec4:	75 0b                	jne    800ed1 <__umoddi3+0x91>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f7                	div    %edi
  800ecf:	89 c5                	mov    %eax,%ebp
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f5                	div    %ebp
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	f7 f5                	div    %ebp
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	eb 99                	jmp    800e78 <__umoddi3+0x38>
  800edf:	90                   	nop
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	8b 34 24             	mov    (%esp),%esi
  800ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	29 ef                	sub    %ebp,%edi
  800efc:	d3 e0                	shl    %cl,%eax
  800efe:	89 f9                	mov    %edi,%ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 e9                	mov    %ebp,%ecx
  800f06:	09 c2                	or     %eax,%edx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 14 24             	mov    %edx,(%esp)
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	d3 e3                	shl    %cl,%ebx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 f2                	mov    %esi,%edx
  800f31:	f7 34 24             	divl   (%esp)
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	d3 e3                	shl    %cl,%ebx
  800f38:	f7 64 24 04          	mull   0x4(%esp)
  800f3c:	39 d6                	cmp    %edx,%esi
  800f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	72 08                	jb     800f50 <__umoddi3+0x110>
  800f48:	75 11                	jne    800f5b <__umoddi3+0x11b>
  800f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f4e:	73 0b                	jae    800f5b <__umoddi3+0x11b>
  800f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f54:	1b 14 24             	sbb    (%esp),%edx
  800f57:	89 d1                	mov    %edx,%ecx
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f5f:	29 da                	sub    %ebx,%edx
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	d3 e0                	shl    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	d3 ee                	shr    %cl,%esi
  800f71:	09 d0                	or     %edx,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	83 c4 1c             	add    $0x1c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	29 f9                	sub    %edi,%ecx
  800f82:	19 d6                	sbb    %edx,%esi
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8c:	e9 18 ff ff ff       	jmp    800ea9 <__umoddi3+0x69>
