
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
  80002c:	e8 2a 00 00 00       	call   80005b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("\t we are at faultread umain now.\n");
  800039:	68 a0 0f 80 00       	push   $0x800fa0
  80003e:	e8 03 01 00 00       	call   800146 <cprintf>
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800043:	83 c4 08             	add    $0x8,%esp
  800046:	ff 35 00 00 00 00    	pushl  0x0
  80004c:	68 c2 0f 80 00       	push   $0x800fc2
  800051:	e8 f0 00 00 00       	call   800146 <cprintf>
}
  800056:	83 c4 10             	add    $0x10,%esp
  800059:	c9                   	leave  
  80005a:	c3                   	ret    

0080005b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005b:	55                   	push   %ebp
  80005c:	89 e5                	mov    %esp,%ebp
  80005e:	56                   	push   %esi
  80005f:	53                   	push   %ebx
  800060:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800063:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800066:	e8 6f 0a 00 00       	call   800ada <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 db                	test   %ebx,%ebx
  80007f:	7e 07                	jle    800088 <libmain+0x2d>
		binaryname = argv[0];
  800081:	8b 06                	mov    (%esi),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	e8 a1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800092:	e8 0a 00 00 00       	call   8000a1 <exit>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a7:	6a 00                	push   $0x0
  8000a9:	e8 eb 09 00 00       	call   800a99 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	53                   	push   %ebx
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000bd:	8b 13                	mov    (%ebx),%edx
  8000bf:	8d 42 01             	lea    0x1(%edx),%eax
  8000c2:	89 03                	mov    %eax,(%ebx)
  8000c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d0:	75 1a                	jne    8000ec <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	68 ff 00 00 00       	push   $0xff
  8000da:	8d 43 08             	lea    0x8(%ebx),%eax
  8000dd:	50                   	push   %eax
  8000de:	e8 79 09 00 00       	call   800a5c <sys_cputs>
		b->idx = 0;
  8000e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8000fe:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800105:	00 00 00 
	b.cnt = 0;
  800108:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800112:	ff 75 0c             	pushl  0xc(%ebp)
  800115:	ff 75 08             	pushl  0x8(%ebp)
  800118:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011e:	50                   	push   %eax
  80011f:	68 b3 00 80 00       	push   $0x8000b3
  800124:	e8 54 01 00 00       	call   80027d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800132:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	e8 1e 09 00 00       	call   800a5c <sys_cputs>

	return b.cnt;
}
  80013e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014f:	50                   	push   %eax
  800150:	ff 75 08             	pushl  0x8(%ebp)
  800153:	e8 9d ff ff ff       	call   8000f5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 1c             	sub    $0x1c,%esp
  800163:	89 c7                	mov    %eax,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	8b 45 08             	mov    0x8(%ebp),%eax
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800170:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800173:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800176:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80017e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800181:	39 d3                	cmp    %edx,%ebx
  800183:	72 05                	jb     80018a <printnum+0x30>
  800185:	39 45 10             	cmp    %eax,0x10(%ebp)
  800188:	77 45                	ja     8001cf <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	ff 75 18             	pushl  0x18(%ebp)
  800190:	8b 45 14             	mov    0x14(%ebp),%eax
  800193:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800196:	53                   	push   %ebx
  800197:	ff 75 10             	pushl  0x10(%ebp)
  80019a:	83 ec 08             	sub    $0x8,%esp
  80019d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a9:	e8 62 0b 00 00       	call   800d10 <__udivdi3>
  8001ae:	83 c4 18             	add    $0x18,%esp
  8001b1:	52                   	push   %edx
  8001b2:	50                   	push   %eax
  8001b3:	89 f2                	mov    %esi,%edx
  8001b5:	89 f8                	mov    %edi,%eax
  8001b7:	e8 9e ff ff ff       	call   80015a <printnum>
  8001bc:	83 c4 20             	add    $0x20,%esp
  8001bf:	eb 18                	jmp    8001d9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	56                   	push   %esi
  8001c5:	ff 75 18             	pushl  0x18(%ebp)
  8001c8:	ff d7                	call   *%edi
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	eb 03                	jmp    8001d2 <printnum+0x78>
  8001cf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d2:	83 eb 01             	sub    $0x1,%ebx
  8001d5:	85 db                	test   %ebx,%ebx
  8001d7:	7f e8                	jg     8001c1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ec:	e8 4f 0c 00 00       	call   800e40 <__umoddi3>
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	0f be 80 ea 0f 80 00 	movsbl 0x800fea(%eax),%eax
  8001fb:	50                   	push   %eax
  8001fc:	ff d7                	call   *%edi
}
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020c:	83 fa 01             	cmp    $0x1,%edx
  80020f:	7e 0e                	jle    80021f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800211:	8b 10                	mov    (%eax),%edx
  800213:	8d 4a 08             	lea    0x8(%edx),%ecx
  800216:	89 08                	mov    %ecx,(%eax)
  800218:	8b 02                	mov    (%edx),%eax
  80021a:	8b 52 04             	mov    0x4(%edx),%edx
  80021d:	eb 22                	jmp    800241 <getuint+0x38>
	else if (lflag)
  80021f:	85 d2                	test   %edx,%edx
  800221:	74 10                	je     800233 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800223:	8b 10                	mov    (%eax),%edx
  800225:	8d 4a 04             	lea    0x4(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 02                	mov    (%edx),%eax
  80022c:	ba 00 00 00 00       	mov    $0x0,%edx
  800231:	eb 0e                	jmp    800241 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800233:	8b 10                	mov    (%eax),%edx
  800235:	8d 4a 04             	lea    0x4(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 02                	mov    (%edx),%eax
  80023c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800249:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80024d:	8b 10                	mov    (%eax),%edx
  80024f:	3b 50 04             	cmp    0x4(%eax),%edx
  800252:	73 0a                	jae    80025e <sprintputch+0x1b>
		*b->buf++ = ch;
  800254:	8d 4a 01             	lea    0x1(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	88 02                	mov    %al,(%edx)
}
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800266:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800269:	50                   	push   %eax
  80026a:	ff 75 10             	pushl  0x10(%ebp)
  80026d:	ff 75 0c             	pushl  0xc(%ebp)
  800270:	ff 75 08             	pushl  0x8(%ebp)
  800273:	e8 05 00 00 00       	call   80027d <vprintfmt>
	va_end(ap);
}
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	83 ec 2c             	sub    $0x2c,%esp
  800286:	8b 75 08             	mov    0x8(%ebp),%esi
  800289:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028f:	eb 12                	jmp    8002a3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800291:	85 c0                	test   %eax,%eax
  800293:	0f 84 d3 03 00 00    	je     80066c <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	53                   	push   %ebx
  80029d:	50                   	push   %eax
  80029e:	ff d6                	call   *%esi
  8002a0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a3:	83 c7 01             	add    $0x1,%edi
  8002a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002aa:	83 f8 25             	cmp    $0x25,%eax
  8002ad:	75 e2                	jne    800291 <vprintfmt+0x14>
  8002af:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ba:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002c1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	eb 07                	jmp    8002d6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d6:	8d 47 01             	lea    0x1(%edi),%eax
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	0f b6 07             	movzbl (%edi),%eax
  8002df:	0f b6 c8             	movzbl %al,%ecx
  8002e2:	83 e8 23             	sub    $0x23,%eax
  8002e5:	3c 55                	cmp    $0x55,%al
  8002e7:	0f 87 64 03 00 00    	ja     800651 <vprintfmt+0x3d4>
  8002ed:	0f b6 c0             	movzbl %al,%eax
  8002f0:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002fe:	eb d6                	jmp    8002d6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
  800308:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800312:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800315:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800318:	83 fa 09             	cmp    $0x9,%edx
  80031b:	77 39                	ja     800356 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800320:	eb e9                	jmp    80030b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800322:	8b 45 14             	mov    0x14(%ebp),%eax
  800325:	8d 48 04             	lea    0x4(%eax),%ecx
  800328:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032b:	8b 00                	mov    (%eax),%eax
  80032d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800333:	eb 27                	jmp    80035c <vprintfmt+0xdf>
  800335:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800338:	85 c0                	test   %eax,%eax
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	0f 49 c8             	cmovns %eax,%ecx
  800342:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800348:	eb 8c                	jmp    8002d6 <vprintfmt+0x59>
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800354:	eb 80                	jmp    8002d6 <vprintfmt+0x59>
  800356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800359:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80035c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800360:	0f 89 70 ff ff ff    	jns    8002d6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800366:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800369:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800373:	e9 5e ff ff ff       	jmp    8002d6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800378:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037e:	e9 53 ff ff ff       	jmp    8002d6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 50 04             	lea    0x4(%eax),%edx
  800389:	89 55 14             	mov    %edx,0x14(%ebp)
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	53                   	push   %ebx
  800390:	ff 30                	pushl  (%eax)
  800392:	ff d6                	call   *%esi
			break;
  800394:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039a:	e9 04 ff ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 50 04             	lea    0x4(%eax),%edx
  8003a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	99                   	cltd   
  8003ab:	31 d0                	xor    %edx,%eax
  8003ad:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003af:	83 f8 08             	cmp    $0x8,%eax
  8003b2:	7f 0b                	jg     8003bf <vprintfmt+0x142>
  8003b4:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	75 18                	jne    8003d7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003bf:	50                   	push   %eax
  8003c0:	68 02 10 80 00       	push   $0x801002
  8003c5:	53                   	push   %ebx
  8003c6:	56                   	push   %esi
  8003c7:	e8 94 fe ff ff       	call   800260 <printfmt>
  8003cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d2:	e9 cc fe ff ff       	jmp    8002a3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d7:	52                   	push   %edx
  8003d8:	68 0b 10 80 00       	push   $0x80100b
  8003dd:	53                   	push   %ebx
  8003de:	56                   	push   %esi
  8003df:	e8 7c fe ff ff       	call   800260 <printfmt>
  8003e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ea:	e9 b4 fe ff ff       	jmp    8002a3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003fa:	85 ff                	test   %edi,%edi
  8003fc:	b8 fb 0f 80 00       	mov    $0x800ffb,%eax
  800401:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 8e 94 00 00 00    	jle    8004a2 <vprintfmt+0x225>
  80040e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800412:	0f 84 98 00 00 00    	je     8004b0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	ff 75 c8             	pushl  -0x38(%ebp)
  80041e:	57                   	push   %edi
  80041f:	e8 d0 02 00 00       	call   8006f4 <strnlen>
  800424:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800427:	29 c1                	sub    %eax,%ecx
  800429:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80042c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800439:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	eb 0f                	jmp    80044c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	ff 75 e0             	pushl  -0x20(%ebp)
  800444:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	83 ef 01             	sub    $0x1,%edi
  800449:	83 c4 10             	add    $0x10,%esp
  80044c:	85 ff                	test   %edi,%edi
  80044e:	7f ed                	jg     80043d <vprintfmt+0x1c0>
  800450:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800453:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800456:	85 c9                	test   %ecx,%ecx
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	0f 49 c1             	cmovns %ecx,%eax
  800460:	29 c1                	sub    %eax,%ecx
  800462:	89 75 08             	mov    %esi,0x8(%ebp)
  800465:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800468:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046b:	89 cb                	mov    %ecx,%ebx
  80046d:	eb 4d                	jmp    8004bc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800473:	74 1b                	je     800490 <vprintfmt+0x213>
  800475:	0f be c0             	movsbl %al,%eax
  800478:	83 e8 20             	sub    $0x20,%eax
  80047b:	83 f8 5e             	cmp    $0x5e,%eax
  80047e:	76 10                	jbe    800490 <vprintfmt+0x213>
					putch('?', putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 0c             	pushl  0xc(%ebp)
  800486:	6a 3f                	push   $0x3f
  800488:	ff 55 08             	call   *0x8(%ebp)
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	eb 0d                	jmp    80049d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	52                   	push   %edx
  800497:	ff 55 08             	call   *0x8(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	eb 1a                	jmp    8004bc <vprintfmt+0x23f>
  8004a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a5:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ae:	eb 0c                	jmp    8004bc <vprintfmt+0x23f>
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bc:	83 c7 01             	add    $0x1,%edi
  8004bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c3:	0f be d0             	movsbl %al,%edx
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	74 23                	je     8004ed <vprintfmt+0x270>
  8004ca:	85 f6                	test   %esi,%esi
  8004cc:	78 a1                	js     80046f <vprintfmt+0x1f2>
  8004ce:	83 ee 01             	sub    $0x1,%esi
  8004d1:	79 9c                	jns    80046f <vprintfmt+0x1f2>
  8004d3:	89 df                	mov    %ebx,%edi
  8004d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004db:	eb 18                	jmp    8004f5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	6a 20                	push   $0x20
  8004e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e5:	83 ef 01             	sub    $0x1,%edi
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	eb 08                	jmp    8004f5 <vprintfmt+0x278>
  8004ed:	89 df                	mov    %ebx,%edi
  8004ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f5:	85 ff                	test   %edi,%edi
  8004f7:	7f e4                	jg     8004dd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fc:	e9 a2 fd ff ff       	jmp    8002a3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800501:	83 fa 01             	cmp    $0x1,%edx
  800504:	7e 16                	jle    80051c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 08             	lea    0x8(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 50 04             	mov    0x4(%eax),%edx
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800517:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80051a:	eb 32                	jmp    80054e <vprintfmt+0x2d1>
	else if (lflag)
  80051c:	85 d2                	test   %edx,%edx
  80051e:	74 18                	je     800538 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80052e:	89 c1                	mov    %eax,%ecx
  800530:	c1 f9 1f             	sar    $0x1f,%ecx
  800533:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800536:	eb 16                	jmp    80054e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800546:	89 c1                	mov    %eax,%ecx
  800548:	c1 f9 1f             	sar    $0x1f,%ecx
  80054b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800551:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800563:	0f 89 b0 00 00 00    	jns    800619 <vprintfmt+0x39c>
				putch('-', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	6a 2d                	push   $0x2d
  80056f:	ff d6                	call   *%esi
				num = -(long long) num;
  800571:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800574:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800577:	f7 d8                	neg    %eax
  800579:	83 d2 00             	adc    $0x0,%edx
  80057c:	f7 da                	neg    %edx
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058c:	e9 88 00 00 00       	jmp    800619 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800591:	8d 45 14             	lea    0x14(%ebp),%eax
  800594:	e8 70 fc ff ff       	call   800209 <getuint>
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a4:	eb 73                	jmp    800619 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a9:	e8 5b fc ff ff       	call   800209 <getuint>
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	6a 58                	push   $0x58
  8005ba:	ff d6                	call   *%esi
			putch('X', putdat);
  8005bc:	83 c4 08             	add    $0x8,%esp
  8005bf:	53                   	push   %ebx
  8005c0:	6a 58                	push   $0x58
  8005c2:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c4:	83 c4 08             	add    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 58                	push   $0x58
  8005ca:	ff d6                	call   *%esi
			goto number;
  8005cc:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005cf:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005d4:	eb 43                	jmp    800619 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 30                	push   $0x30
  8005dc:	ff d6                	call   *%esi
			putch('x', putdat);
  8005de:	83 c4 08             	add    $0x8,%esp
  8005e1:	53                   	push   %ebx
  8005e2:	6a 78                	push   $0x78
  8005e4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005fc:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ff:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800604:	eb 13                	jmp    800619 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800606:	8d 45 14             	lea    0x14(%ebp),%eax
  800609:	e8 fb fb ff ff       	call   800209 <getuint>
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800614:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800619:	83 ec 0c             	sub    $0xc,%esp
  80061c:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800620:	52                   	push   %edx
  800621:	ff 75 e0             	pushl  -0x20(%ebp)
  800624:	50                   	push   %eax
  800625:	ff 75 dc             	pushl  -0x24(%ebp)
  800628:	ff 75 d8             	pushl  -0x28(%ebp)
  80062b:	89 da                	mov    %ebx,%edx
  80062d:	89 f0                	mov    %esi,%eax
  80062f:	e8 26 fb ff ff       	call   80015a <printnum>
			break;
  800634:	83 c4 20             	add    $0x20,%esp
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063a:	e9 64 fc ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	51                   	push   %ecx
  800644:	ff d6                	call   *%esi
			break;
  800646:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80064c:	e9 52 fc ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 25                	push   $0x25
  800657:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	eb 03                	jmp    800661 <vprintfmt+0x3e4>
  80065e:	83 ef 01             	sub    $0x1,%edi
  800661:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800665:	75 f7                	jne    80065e <vprintfmt+0x3e1>
  800667:	e9 37 fc ff ff       	jmp    8002a3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80066c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066f:	5b                   	pop    %ebx
  800670:	5e                   	pop    %esi
  800671:	5f                   	pop    %edi
  800672:	5d                   	pop    %ebp
  800673:	c3                   	ret    

00800674 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800674:	55                   	push   %ebp
  800675:	89 e5                	mov    %esp,%ebp
  800677:	83 ec 18             	sub    $0x18,%esp
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800680:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800683:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800687:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800691:	85 c0                	test   %eax,%eax
  800693:	74 26                	je     8006bb <vsnprintf+0x47>
  800695:	85 d2                	test   %edx,%edx
  800697:	7e 22                	jle    8006bb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800699:	ff 75 14             	pushl  0x14(%ebp)
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	68 43 02 80 00       	push   $0x800243
  8006a8:	e8 d0 fb ff ff       	call   80027d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 05                	jmp    8006c0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cb:	50                   	push   %eax
  8006cc:	ff 75 10             	pushl  0x10(%ebp)
  8006cf:	ff 75 0c             	pushl  0xc(%ebp)
  8006d2:	ff 75 08             	pushl  0x8(%ebp)
  8006d5:	e8 9a ff ff ff       	call   800674 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e7:	eb 03                	jmp    8006ec <strlen+0x10>
		n++;
  8006e9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ec:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f0:	75 f7                	jne    8006e9 <strlen+0xd>
		n++;
	return n;
}
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    

008006f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800702:	eb 03                	jmp    800707 <strnlen+0x13>
		n++;
  800704:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	39 c2                	cmp    %eax,%edx
  800709:	74 08                	je     800713 <strnlen+0x1f>
  80070b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070f:	75 f3                	jne    800704 <strnlen+0x10>
  800711:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    

00800715 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800715:	55                   	push   %ebp
  800716:	89 e5                	mov    %esp,%ebp
  800718:	53                   	push   %ebx
  800719:	8b 45 08             	mov    0x8(%ebp),%eax
  80071c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071f:	89 c2                	mov    %eax,%edx
  800721:	83 c2 01             	add    $0x1,%edx
  800724:	83 c1 01             	add    $0x1,%ecx
  800727:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072e:	84 db                	test   %bl,%bl
  800730:	75 ef                	jne    800721 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800732:	5b                   	pop    %ebx
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	53                   	push   %ebx
  800739:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073c:	53                   	push   %ebx
  80073d:	e8 9a ff ff ff       	call   8006dc <strlen>
  800742:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800745:	ff 75 0c             	pushl  0xc(%ebp)
  800748:	01 d8                	add    %ebx,%eax
  80074a:	50                   	push   %eax
  80074b:	e8 c5 ff ff ff       	call   800715 <strcpy>
	return dst;
}
  800750:	89 d8                	mov    %ebx,%eax
  800752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800755:	c9                   	leave  
  800756:	c3                   	ret    

00800757 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	56                   	push   %esi
  80075b:	53                   	push   %ebx
  80075c:	8b 75 08             	mov    0x8(%ebp),%esi
  80075f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800762:	89 f3                	mov    %esi,%ebx
  800764:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800767:	89 f2                	mov    %esi,%edx
  800769:	eb 0f                	jmp    80077a <strncpy+0x23>
		*dst++ = *src;
  80076b:	83 c2 01             	add    $0x1,%edx
  80076e:	0f b6 01             	movzbl (%ecx),%eax
  800771:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800774:	80 39 01             	cmpb   $0x1,(%ecx)
  800777:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077a:	39 da                	cmp    %ebx,%edx
  80077c:	75 ed                	jne    80076b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077e:	89 f0                	mov    %esi,%eax
  800780:	5b                   	pop    %ebx
  800781:	5e                   	pop    %esi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
  800789:	8b 75 08             	mov    0x8(%ebp),%esi
  80078c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078f:	8b 55 10             	mov    0x10(%ebp),%edx
  800792:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800794:	85 d2                	test   %edx,%edx
  800796:	74 21                	je     8007b9 <strlcpy+0x35>
  800798:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079c:	89 f2                	mov    %esi,%edx
  80079e:	eb 09                	jmp    8007a9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a0:	83 c2 01             	add    $0x1,%edx
  8007a3:	83 c1 01             	add    $0x1,%ecx
  8007a6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a9:	39 c2                	cmp    %eax,%edx
  8007ab:	74 09                	je     8007b6 <strlcpy+0x32>
  8007ad:	0f b6 19             	movzbl (%ecx),%ebx
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ec                	jne    8007a0 <strlcpy+0x1c>
  8007b4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b9:	29 f0                	sub    %esi,%eax
}
  8007bb:	5b                   	pop    %ebx
  8007bc:	5e                   	pop    %esi
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c8:	eb 06                	jmp    8007d0 <strcmp+0x11>
		p++, q++;
  8007ca:	83 c1 01             	add    $0x1,%ecx
  8007cd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d0:	0f b6 01             	movzbl (%ecx),%eax
  8007d3:	84 c0                	test   %al,%al
  8007d5:	74 04                	je     8007db <strcmp+0x1c>
  8007d7:	3a 02                	cmp    (%edx),%al
  8007d9:	74 ef                	je     8007ca <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007db:	0f b6 c0             	movzbl %al,%eax
  8007de:	0f b6 12             	movzbl (%edx),%edx
  8007e1:	29 d0                	sub    %edx,%eax
}
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ef:	89 c3                	mov    %eax,%ebx
  8007f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f4:	eb 06                	jmp    8007fc <strncmp+0x17>
		n--, p++, q++;
  8007f6:	83 c0 01             	add    $0x1,%eax
  8007f9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fc:	39 d8                	cmp    %ebx,%eax
  8007fe:	74 15                	je     800815 <strncmp+0x30>
  800800:	0f b6 08             	movzbl (%eax),%ecx
  800803:	84 c9                	test   %cl,%cl
  800805:	74 04                	je     80080b <strncmp+0x26>
  800807:	3a 0a                	cmp    (%edx),%cl
  800809:	74 eb                	je     8007f6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 00             	movzbl (%eax),%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
  800813:	eb 05                	jmp    80081a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081a:	5b                   	pop    %ebx
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800827:	eb 07                	jmp    800830 <strchr+0x13>
		if (*s == c)
  800829:	38 ca                	cmp    %cl,%dl
  80082b:	74 0f                	je     80083c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082d:	83 c0 01             	add    $0x1,%eax
  800830:	0f b6 10             	movzbl (%eax),%edx
  800833:	84 d2                	test   %dl,%dl
  800835:	75 f2                	jne    800829 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 45 08             	mov    0x8(%ebp),%eax
  800844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800848:	eb 03                	jmp    80084d <strfind+0xf>
  80084a:	83 c0 01             	add    $0x1,%eax
  80084d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800850:	38 ca                	cmp    %cl,%dl
  800852:	74 04                	je     800858 <strfind+0x1a>
  800854:	84 d2                	test   %dl,%dl
  800856:	75 f2                	jne    80084a <strfind+0xc>
			break;
	return (char *) s;
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	57                   	push   %edi
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 7d 08             	mov    0x8(%ebp),%edi
  800863:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800866:	85 c9                	test   %ecx,%ecx
  800868:	74 36                	je     8008a0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800870:	75 28                	jne    80089a <memset+0x40>
  800872:	f6 c1 03             	test   $0x3,%cl
  800875:	75 23                	jne    80089a <memset+0x40>
		c &= 0xFF;
  800877:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087b:	89 d3                	mov    %edx,%ebx
  80087d:	c1 e3 08             	shl    $0x8,%ebx
  800880:	89 d6                	mov    %edx,%esi
  800882:	c1 e6 18             	shl    $0x18,%esi
  800885:	89 d0                	mov    %edx,%eax
  800887:	c1 e0 10             	shl    $0x10,%eax
  80088a:	09 f0                	or     %esi,%eax
  80088c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	09 d0                	or     %edx,%eax
  800892:	c1 e9 02             	shr    $0x2,%ecx
  800895:	fc                   	cld    
  800896:	f3 ab                	rep stos %eax,%es:(%edi)
  800898:	eb 06                	jmp    8008a0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089d:	fc                   	cld    
  80089e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a0:	89 f8                	mov    %edi,%eax
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5f                   	pop    %edi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	57                   	push   %edi
  8008ab:	56                   	push   %esi
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b5:	39 c6                	cmp    %eax,%esi
  8008b7:	73 35                	jae    8008ee <memmove+0x47>
  8008b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008bc:	39 d0                	cmp    %edx,%eax
  8008be:	73 2e                	jae    8008ee <memmove+0x47>
		s += n;
		d += n;
  8008c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c3:	89 d6                	mov    %edx,%esi
  8008c5:	09 fe                	or     %edi,%esi
  8008c7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008cd:	75 13                	jne    8008e2 <memmove+0x3b>
  8008cf:	f6 c1 03             	test   $0x3,%cl
  8008d2:	75 0e                	jne    8008e2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d4:	83 ef 04             	sub    $0x4,%edi
  8008d7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008da:	c1 e9 02             	shr    $0x2,%ecx
  8008dd:	fd                   	std    
  8008de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e0:	eb 09                	jmp    8008eb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e2:	83 ef 01             	sub    $0x1,%edi
  8008e5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e8:	fd                   	std    
  8008e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008eb:	fc                   	cld    
  8008ec:	eb 1d                	jmp    80090b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ee:	89 f2                	mov    %esi,%edx
  8008f0:	09 c2                	or     %eax,%edx
  8008f2:	f6 c2 03             	test   $0x3,%dl
  8008f5:	75 0f                	jne    800906 <memmove+0x5f>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 0a                	jne    800906 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008fc:	c1 e9 02             	shr    $0x2,%ecx
  8008ff:	89 c7                	mov    %eax,%edi
  800901:	fc                   	cld    
  800902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800904:	eb 05                	jmp    80090b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800906:	89 c7                	mov    %eax,%edi
  800908:	fc                   	cld    
  800909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090b:	5e                   	pop    %esi
  80090c:	5f                   	pop    %edi
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800912:	ff 75 10             	pushl  0x10(%ebp)
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	ff 75 08             	pushl  0x8(%ebp)
  80091b:	e8 87 ff ff ff       	call   8008a7 <memmove>
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	89 c6                	mov    %eax,%esi
  80092f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800932:	eb 1a                	jmp    80094e <memcmp+0x2c>
		if (*s1 != *s2)
  800934:	0f b6 08             	movzbl (%eax),%ecx
  800937:	0f b6 1a             	movzbl (%edx),%ebx
  80093a:	38 d9                	cmp    %bl,%cl
  80093c:	74 0a                	je     800948 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093e:	0f b6 c1             	movzbl %cl,%eax
  800941:	0f b6 db             	movzbl %bl,%ebx
  800944:	29 d8                	sub    %ebx,%eax
  800946:	eb 0f                	jmp    800957 <memcmp+0x35>
		s1++, s2++;
  800948:	83 c0 01             	add    $0x1,%eax
  80094b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094e:	39 f0                	cmp    %esi,%eax
  800950:	75 e2                	jne    800934 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800962:	89 c1                	mov    %eax,%ecx
  800964:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800967:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096b:	eb 0a                	jmp    800977 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	39 da                	cmp    %ebx,%edx
  800972:	74 07                	je     80097b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800974:	83 c0 01             	add    $0x1,%eax
  800977:	39 c8                	cmp    %ecx,%eax
  800979:	72 f2                	jb     80096d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098a:	eb 03                	jmp    80098f <strtol+0x11>
		s++;
  80098c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098f:	0f b6 01             	movzbl (%ecx),%eax
  800992:	3c 20                	cmp    $0x20,%al
  800994:	74 f6                	je     80098c <strtol+0xe>
  800996:	3c 09                	cmp    $0x9,%al
  800998:	74 f2                	je     80098c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099a:	3c 2b                	cmp    $0x2b,%al
  80099c:	75 0a                	jne    8009a8 <strtol+0x2a>
		s++;
  80099e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a6:	eb 11                	jmp    8009b9 <strtol+0x3b>
  8009a8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ad:	3c 2d                	cmp    $0x2d,%al
  8009af:	75 08                	jne    8009b9 <strtol+0x3b>
		s++, neg = 1;
  8009b1:	83 c1 01             	add    $0x1,%ecx
  8009b4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bf:	75 15                	jne    8009d6 <strtol+0x58>
  8009c1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c4:	75 10                	jne    8009d6 <strtol+0x58>
  8009c6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009ca:	75 7c                	jne    800a48 <strtol+0xca>
		s += 2, base = 16;
  8009cc:	83 c1 02             	add    $0x2,%ecx
  8009cf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d4:	eb 16                	jmp    8009ec <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d6:	85 db                	test   %ebx,%ebx
  8009d8:	75 12                	jne    8009ec <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009da:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009df:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e2:	75 08                	jne    8009ec <strtol+0x6e>
		s++, base = 8;
  8009e4:	83 c1 01             	add    $0x1,%ecx
  8009e7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f4:	0f b6 11             	movzbl (%ecx),%edx
  8009f7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fa:	89 f3                	mov    %esi,%ebx
  8009fc:	80 fb 09             	cmp    $0x9,%bl
  8009ff:	77 08                	ja     800a09 <strtol+0x8b>
			dig = *s - '0';
  800a01:	0f be d2             	movsbl %dl,%edx
  800a04:	83 ea 30             	sub    $0x30,%edx
  800a07:	eb 22                	jmp    800a2b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a09:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0c:	89 f3                	mov    %esi,%ebx
  800a0e:	80 fb 19             	cmp    $0x19,%bl
  800a11:	77 08                	ja     800a1b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a13:	0f be d2             	movsbl %dl,%edx
  800a16:	83 ea 57             	sub    $0x57,%edx
  800a19:	eb 10                	jmp    800a2b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1e:	89 f3                	mov    %esi,%ebx
  800a20:	80 fb 19             	cmp    $0x19,%bl
  800a23:	77 16                	ja     800a3b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a25:	0f be d2             	movsbl %dl,%edx
  800a28:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2e:	7d 0b                	jge    800a3b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a37:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a39:	eb b9                	jmp    8009f4 <strtol+0x76>

	if (endptr)
  800a3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3f:	74 0d                	je     800a4e <strtol+0xd0>
		*endptr = (char *) s;
  800a41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a44:	89 0e                	mov    %ecx,(%esi)
  800a46:	eb 06                	jmp    800a4e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a48:	85 db                	test   %ebx,%ebx
  800a4a:	74 98                	je     8009e4 <strtol+0x66>
  800a4c:	eb 9e                	jmp    8009ec <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	f7 da                	neg    %edx
  800a52:	85 ff                	test   %edi,%edi
  800a54:	0f 45 c2             	cmovne %edx,%eax
}
  800a57:	5b                   	pop    %ebx
  800a58:	5e                   	pop    %esi
  800a59:	5f                   	pop    %edi
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
  800a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	89 c3                	mov    %eax,%ebx
  800a6f:	89 c7                	mov    %eax,%edi
  800a71:	89 c6                	mov    %eax,%esi
  800a73:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a80:	ba 00 00 00 00       	mov    $0x0,%edx
  800a85:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8a:	89 d1                	mov    %edx,%ecx
  800a8c:	89 d3                	mov    %edx,%ebx
  800a8e:	89 d7                	mov    %edx,%edi
  800a90:	89 d6                	mov    %edx,%esi
  800a92:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5f                   	pop    %edi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aac:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaf:	89 cb                	mov    %ecx,%ebx
  800ab1:	89 cf                	mov    %ecx,%edi
  800ab3:	89 ce                	mov    %ecx,%esi
  800ab5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab7:	85 c0                	test   %eax,%eax
  800ab9:	7e 17                	jle    800ad2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abb:	83 ec 0c             	sub    $0xc,%esp
  800abe:	50                   	push   %eax
  800abf:	6a 03                	push   $0x3
  800ac1:	68 44 12 80 00       	push   $0x801244
  800ac6:	6a 23                	push   $0x23
  800ac8:	68 61 12 80 00       	push   $0x801261
  800acd:	e8 f5 01 00 00       	call   800cc7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 02 00 00 00       	mov    $0x2,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_yield>:

void
sys_yield(void)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aff:	ba 00 00 00 00       	mov    $0x0,%edx
  800b04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b09:	89 d1                	mov    %edx,%ecx
  800b0b:	89 d3                	mov    %edx,%ebx
  800b0d:	89 d7                	mov    %edx,%edi
  800b0f:	89 d6                	mov    %edx,%esi
  800b11:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b21:	be 00 00 00 00       	mov    $0x0,%esi
  800b26:	b8 04 00 00 00       	mov    $0x4,%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b34:	89 f7                	mov    %esi,%edi
  800b36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	7e 17                	jle    800b53 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3c:	83 ec 0c             	sub    $0xc,%esp
  800b3f:	50                   	push   %eax
  800b40:	6a 04                	push   $0x4
  800b42:	68 44 12 80 00       	push   $0x801244
  800b47:	6a 23                	push   $0x23
  800b49:	68 61 12 80 00       	push   $0x801261
  800b4e:	e8 74 01 00 00       	call   800cc7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b64:	b8 05 00 00 00       	mov    $0x5,%eax
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b75:	8b 75 18             	mov    0x18(%ebp),%esi
  800b78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 05                	push   $0x5
  800b84:	68 44 12 80 00       	push   $0x801244
  800b89:	6a 23                	push   $0x23
  800b8b:	68 61 12 80 00       	push   $0x801261
  800b90:	e8 32 01 00 00       	call   800cc7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bab:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	89 df                	mov    %ebx,%edi
  800bb8:	89 de                	mov    %ebx,%esi
  800bba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 06                	push   $0x6
  800bc6:	68 44 12 80 00       	push   $0x801244
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 61 12 80 00       	push   $0x801261
  800bd2:	e8 f0 00 00 00       	call   800cc7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800be8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bed:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	89 df                	mov    %ebx,%edi
  800bfa:	89 de                	mov    %ebx,%esi
  800bfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 08                	push   $0x8
  800c08:	68 44 12 80 00       	push   $0x801244
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 61 12 80 00       	push   $0x801261
  800c14:	e8 ae 00 00 00       	call   800cc7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 df                	mov    %ebx,%edi
  800c3c:	89 de                	mov    %ebx,%esi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 09                	push   $0x9
  800c4a:	68 44 12 80 00       	push   $0x801244
  800c4f:	6a 23                	push   $0x23
  800c51:	68 61 12 80 00       	push   $0x801261
  800c56:	e8 6c 00 00 00       	call   800cc7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c69:	be 00 00 00 00       	mov    $0x0,%esi
  800c6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 cb                	mov    %ecx,%ebx
  800c9e:	89 cf                	mov    %ecx,%edi
  800ca0:	89 ce                	mov    %ecx,%esi
  800ca2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7e 17                	jle    800cbf <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca8:	83 ec 0c             	sub    $0xc,%esp
  800cab:	50                   	push   %eax
  800cac:	6a 0c                	push   $0xc
  800cae:	68 44 12 80 00       	push   $0x801244
  800cb3:	6a 23                	push   $0x23
  800cb5:	68 61 12 80 00       	push   $0x801261
  800cba:	e8 08 00 00 00       	call   800cc7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc2:	5b                   	pop    %ebx
  800cc3:	5e                   	pop    %esi
  800cc4:	5f                   	pop    %edi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ccc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ccf:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cd5:	e8 00 fe ff ff       	call   800ada <sys_getenvid>
  800cda:	83 ec 0c             	sub    $0xc,%esp
  800cdd:	ff 75 0c             	pushl  0xc(%ebp)
  800ce0:	ff 75 08             	pushl  0x8(%ebp)
  800ce3:	56                   	push   %esi
  800ce4:	50                   	push   %eax
  800ce5:	68 70 12 80 00       	push   $0x801270
  800cea:	e8 57 f4 ff ff       	call   800146 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cef:	83 c4 18             	add    $0x18,%esp
  800cf2:	53                   	push   %ebx
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	e8 fa f3 ff ff       	call   8000f5 <vcprintf>
	cprintf("\n");
  800cfb:	c7 04 24 de 0f 80 00 	movl   $0x800fde,(%esp)
  800d02:	e8 3f f4 ff ff       	call   800146 <cprintf>
  800d07:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d0a:	cc                   	int3   
  800d0b:	eb fd                	jmp    800d0a <_panic+0x43>
  800d0d:	66 90                	xchg   %ax,%ax
  800d0f:	90                   	nop

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
