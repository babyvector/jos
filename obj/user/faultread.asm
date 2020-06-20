
obj/user/faultread.debug:     file format elf32-i386


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
  800039:	68 e0 1d 80 00       	push   $0x801de0
  80003e:	e8 0b 01 00 00       	call   80014e <cprintf>
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800043:	83 c4 08             	add    $0x8,%esp
  800046:	ff 35 00 00 00 00    	pushl  0x0
  80004c:	68 02 1e 80 00       	push   $0x801e02
  800051:	e8 f8 00 00 00       	call   80014e <cprintf>
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
  800066:	e8 77 0a 00 00       	call   800ae2 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 db                	test   %ebx,%ebx
  80007f:	7e 07                	jle    800088 <libmain+0x2d>
		binaryname = argv[0];
  800081:	8b 06                	mov    (%esi),%eax
  800083:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000a4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a7:	e8 30 0e 00 00       	call   800edc <close_all>
	sys_env_destroy(0);
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 eb 09 00 00       	call   800aa1 <sys_env_destroy>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	53                   	push   %ebx
  8000bf:	83 ec 04             	sub    $0x4,%esp
  8000c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c5:	8b 13                	mov    (%ebx),%edx
  8000c7:	8d 42 01             	lea    0x1(%edx),%eax
  8000ca:	89 03                	mov    %eax,(%ebx)
  8000cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d8:	75 1a                	jne    8000f4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000da:	83 ec 08             	sub    $0x8,%esp
  8000dd:	68 ff 00 00 00       	push   $0xff
  8000e2:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e5:	50                   	push   %eax
  8000e6:	e8 79 09 00 00       	call   800a64 <sys_cputs>
		b->idx = 0;
  8000eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    

008000fd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800106:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010d:	00 00 00 
	b.cnt = 0;
  800110:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800117:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011a:	ff 75 0c             	pushl  0xc(%ebp)
  80011d:	ff 75 08             	pushl  0x8(%ebp)
  800120:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800126:	50                   	push   %eax
  800127:	68 bb 00 80 00       	push   $0x8000bb
  80012c:	e8 54 01 00 00       	call   800285 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800131:	83 c4 08             	add    $0x8,%esp
  800134:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800140:	50                   	push   %eax
  800141:	e8 1e 09 00 00       	call   800a64 <sys_cputs>

	return b.cnt;
}
  800146:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800154:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800157:	50                   	push   %eax
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	e8 9d ff ff ff       	call   8000fd <vcprintf>
	va_end(ap);

	return cnt;
}
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 1c             	sub    $0x1c,%esp
  80016b:	89 c7                	mov    %eax,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	8b 45 08             	mov    0x8(%ebp),%eax
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800178:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800183:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800186:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800189:	39 d3                	cmp    %edx,%ebx
  80018b:	72 05                	jb     800192 <printnum+0x30>
  80018d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800190:	77 45                	ja     8001d7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	ff 75 18             	pushl  0x18(%ebp)
  800198:	8b 45 14             	mov    0x14(%ebp),%eax
  80019b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019e:	53                   	push   %ebx
  80019f:	ff 75 10             	pushl  0x10(%ebp)
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b1:	e8 9a 19 00 00       	call   801b50 <__udivdi3>
  8001b6:	83 c4 18             	add    $0x18,%esp
  8001b9:	52                   	push   %edx
  8001ba:	50                   	push   %eax
  8001bb:	89 f2                	mov    %esi,%edx
  8001bd:	89 f8                	mov    %edi,%eax
  8001bf:	e8 9e ff ff ff       	call   800162 <printnum>
  8001c4:	83 c4 20             	add    $0x20,%esp
  8001c7:	eb 18                	jmp    8001e1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	ff 75 18             	pushl  0x18(%ebp)
  8001d0:	ff d7                	call   *%edi
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	eb 03                	jmp    8001da <printnum+0x78>
  8001d7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	85 db                	test   %ebx,%ebx
  8001df:	7f e8                	jg     8001c9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	56                   	push   %esi
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 87 1a 00 00       	call   801c80 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 2a 1e 80 00 	movsbl 0x801e2a(%eax),%eax
  800203:	50                   	push   %eax
  800204:	ff d7                	call   *%edi
}
  800206:	83 c4 10             	add    $0x10,%esp
  800209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020c:	5b                   	pop    %ebx
  80020d:	5e                   	pop    %esi
  80020e:	5f                   	pop    %edi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800214:	83 fa 01             	cmp    $0x1,%edx
  800217:	7e 0e                	jle    800227 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	8b 52 04             	mov    0x4(%edx),%edx
  800225:	eb 22                	jmp    800249 <getuint+0x38>
	else if (lflag)
  800227:	85 d2                	test   %edx,%edx
  800229:	74 10                	je     80023b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800230:	89 08                	mov    %ecx,(%eax)
  800232:	8b 02                	mov    (%edx),%eax
  800234:	ba 00 00 00 00       	mov    $0x0,%edx
  800239:	eb 0e                	jmp    800249 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80023b:	8b 10                	mov    (%eax),%edx
  80023d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800240:	89 08                	mov    %ecx,(%eax)
  800242:	8b 02                	mov    (%edx),%eax
  800244:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800251:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800255:	8b 10                	mov    (%eax),%edx
  800257:	3b 50 04             	cmp    0x4(%eax),%edx
  80025a:	73 0a                	jae    800266 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025f:	89 08                	mov    %ecx,(%eax)
  800261:	8b 45 08             	mov    0x8(%ebp),%eax
  800264:	88 02                	mov    %al,(%edx)
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800271:	50                   	push   %eax
  800272:	ff 75 10             	pushl  0x10(%ebp)
  800275:	ff 75 0c             	pushl  0xc(%ebp)
  800278:	ff 75 08             	pushl  0x8(%ebp)
  80027b:	e8 05 00 00 00       	call   800285 <vprintfmt>
	va_end(ap);
}
  800280:	83 c4 10             	add    $0x10,%esp
  800283:	c9                   	leave  
  800284:	c3                   	ret    

00800285 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	57                   	push   %edi
  800289:	56                   	push   %esi
  80028a:	53                   	push   %ebx
  80028b:	83 ec 2c             	sub    $0x2c,%esp
  80028e:	8b 75 08             	mov    0x8(%ebp),%esi
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800294:	8b 7d 10             	mov    0x10(%ebp),%edi
  800297:	eb 12                	jmp    8002ab <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800299:	85 c0                	test   %eax,%eax
  80029b:	0f 84 d3 03 00 00    	je     800674 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	53                   	push   %ebx
  8002a5:	50                   	push   %eax
  8002a6:	ff d6                	call   *%esi
  8002a8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ab:	83 c7 01             	add    $0x1,%edi
  8002ae:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b2:	83 f8 25             	cmp    $0x25,%eax
  8002b5:	75 e2                	jne    800299 <vprintfmt+0x14>
  8002b7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002c9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d5:	eb 07                	jmp    8002de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002da:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8d 47 01             	lea    0x1(%edi),%eax
  8002e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e4:	0f b6 07             	movzbl (%edi),%eax
  8002e7:	0f b6 c8             	movzbl %al,%ecx
  8002ea:	83 e8 23             	sub    $0x23,%eax
  8002ed:	3c 55                	cmp    $0x55,%al
  8002ef:	0f 87 64 03 00 00    	ja     800659 <vprintfmt+0x3d4>
  8002f5:	0f b6 c0             	movzbl %al,%eax
  8002f8:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800302:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800306:	eb d6                	jmp    8002de <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030b:	b8 00 00 00 00       	mov    $0x0,%eax
  800310:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800313:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800316:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80031a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800320:	83 fa 09             	cmp    $0x9,%edx
  800323:	77 39                	ja     80035e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800325:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800328:	eb e9                	jmp    800313 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80032a:	8b 45 14             	mov    0x14(%ebp),%eax
  80032d:	8d 48 04             	lea    0x4(%eax),%ecx
  800330:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800333:	8b 00                	mov    (%eax),%eax
  800335:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80033b:	eb 27                	jmp    800364 <vprintfmt+0xdf>
  80033d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800340:	85 c0                	test   %eax,%eax
  800342:	b9 00 00 00 00       	mov    $0x0,%ecx
  800347:	0f 49 c8             	cmovns %eax,%ecx
  80034a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800350:	eb 8c                	jmp    8002de <vprintfmt+0x59>
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800355:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80035c:	eb 80                	jmp    8002de <vprintfmt+0x59>
  80035e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800361:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800364:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800368:	0f 89 70 ff ff ff    	jns    8002de <vprintfmt+0x59>
				width = precision, precision = -1;
  80036e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800371:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800374:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80037b:	e9 5e ff ff ff       	jmp    8002de <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800380:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800386:	e9 53 ff ff ff       	jmp    8002de <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 50 04             	lea    0x4(%eax),%edx
  800391:	89 55 14             	mov    %edx,0x14(%ebp)
  800394:	83 ec 08             	sub    $0x8,%esp
  800397:	53                   	push   %ebx
  800398:	ff 30                	pushl  (%eax)
  80039a:	ff d6                	call   *%esi
			break;
  80039c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a2:	e9 04 ff ff ff       	jmp    8002ab <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 50 04             	lea    0x4(%eax),%edx
  8003ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	99                   	cltd   
  8003b3:	31 d0                	xor    %edx,%eax
  8003b5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b7:	83 f8 0f             	cmp    $0xf,%eax
  8003ba:	7f 0b                	jg     8003c7 <vprintfmt+0x142>
  8003bc:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  8003c3:	85 d2                	test   %edx,%edx
  8003c5:	75 18                	jne    8003df <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c7:	50                   	push   %eax
  8003c8:	68 42 1e 80 00       	push   $0x801e42
  8003cd:	53                   	push   %ebx
  8003ce:	56                   	push   %esi
  8003cf:	e8 94 fe ff ff       	call   800268 <printfmt>
  8003d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003da:	e9 cc fe ff ff       	jmp    8002ab <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003df:	52                   	push   %edx
  8003e0:	68 f1 21 80 00       	push   $0x8021f1
  8003e5:	53                   	push   %ebx
  8003e6:	56                   	push   %esi
  8003e7:	e8 7c fe ff ff       	call   800268 <printfmt>
  8003ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f2:	e9 b4 fe ff ff       	jmp    8002ab <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 50 04             	lea    0x4(%eax),%edx
  8003fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800400:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800402:	85 ff                	test   %edi,%edi
  800404:	b8 3b 1e 80 00       	mov    $0x801e3b,%eax
  800409:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80040c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800410:	0f 8e 94 00 00 00    	jle    8004aa <vprintfmt+0x225>
  800416:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80041a:	0f 84 98 00 00 00    	je     8004b8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	ff 75 c8             	pushl  -0x38(%ebp)
  800426:	57                   	push   %edi
  800427:	e8 d0 02 00 00       	call   8006fc <strnlen>
  80042c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042f:	29 c1                	sub    %eax,%ecx
  800431:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800434:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800437:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80043b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800441:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	eb 0f                	jmp    800454 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	53                   	push   %ebx
  800449:	ff 75 e0             	pushl  -0x20(%ebp)
  80044c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044e:	83 ef 01             	sub    $0x1,%edi
  800451:	83 c4 10             	add    $0x10,%esp
  800454:	85 ff                	test   %edi,%edi
  800456:	7f ed                	jg     800445 <vprintfmt+0x1c0>
  800458:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80045b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80045e:	85 c9                	test   %ecx,%ecx
  800460:	b8 00 00 00 00       	mov    $0x0,%eax
  800465:	0f 49 c1             	cmovns %ecx,%eax
  800468:	29 c1                	sub    %eax,%ecx
  80046a:	89 75 08             	mov    %esi,0x8(%ebp)
  80046d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800470:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800473:	89 cb                	mov    %ecx,%ebx
  800475:	eb 4d                	jmp    8004c4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800477:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80047b:	74 1b                	je     800498 <vprintfmt+0x213>
  80047d:	0f be c0             	movsbl %al,%eax
  800480:	83 e8 20             	sub    $0x20,%eax
  800483:	83 f8 5e             	cmp    $0x5e,%eax
  800486:	76 10                	jbe    800498 <vprintfmt+0x213>
					putch('?', putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	ff 75 0c             	pushl  0xc(%ebp)
  80048e:	6a 3f                	push   $0x3f
  800490:	ff 55 08             	call   *0x8(%ebp)
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	eb 0d                	jmp    8004a5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	ff 75 0c             	pushl  0xc(%ebp)
  80049e:	52                   	push   %edx
  80049f:	ff 55 08             	call   *0x8(%ebp)
  8004a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a5:	83 eb 01             	sub    $0x1,%ebx
  8004a8:	eb 1a                	jmp    8004c4 <vprintfmt+0x23f>
  8004aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ad:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b6:	eb 0c                	jmp    8004c4 <vprintfmt+0x23f>
  8004b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c4:	83 c7 01             	add    $0x1,%edi
  8004c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cb:	0f be d0             	movsbl %al,%edx
  8004ce:	85 d2                	test   %edx,%edx
  8004d0:	74 23                	je     8004f5 <vprintfmt+0x270>
  8004d2:	85 f6                	test   %esi,%esi
  8004d4:	78 a1                	js     800477 <vprintfmt+0x1f2>
  8004d6:	83 ee 01             	sub    $0x1,%esi
  8004d9:	79 9c                	jns    800477 <vprintfmt+0x1f2>
  8004db:	89 df                	mov    %ebx,%edi
  8004dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e3:	eb 18                	jmp    8004fd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	6a 20                	push   $0x20
  8004eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ed:	83 ef 01             	sub    $0x1,%edi
  8004f0:	83 c4 10             	add    $0x10,%esp
  8004f3:	eb 08                	jmp    8004fd <vprintfmt+0x278>
  8004f5:	89 df                	mov    %ebx,%edi
  8004f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	7f e4                	jg     8004e5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800504:	e9 a2 fd ff ff       	jmp    8002ab <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800509:	83 fa 01             	cmp    $0x1,%edx
  80050c:	7e 16                	jle    800524 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	8d 50 08             	lea    0x8(%eax),%edx
  800514:	89 55 14             	mov    %edx,0x14(%ebp)
  800517:	8b 50 04             	mov    0x4(%eax),%edx
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80051f:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800522:	eb 32                	jmp    800556 <vprintfmt+0x2d1>
	else if (lflag)
  800524:	85 d2                	test   %edx,%edx
  800526:	74 18                	je     800540 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800536:	89 c1                	mov    %eax,%ecx
  800538:	c1 f9 1f             	sar    $0x1f,%ecx
  80053b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80053e:	eb 16                	jmp    800556 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80054e:	89 c1                	mov    %eax,%ecx
  800550:	c1 f9 1f             	sar    $0x1f,%ecx
  800553:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800556:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800559:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800567:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80056b:	0f 89 b0 00 00 00    	jns    800621 <vprintfmt+0x39c>
				putch('-', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	53                   	push   %ebx
  800575:	6a 2d                	push   $0x2d
  800577:	ff d6                	call   *%esi
				num = -(long long) num;
  800579:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80057c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80057f:	f7 d8                	neg    %eax
  800581:	83 d2 00             	adc    $0x0,%edx
  800584:	f7 da                	neg    %edx
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80058f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800594:	e9 88 00 00 00       	jmp    800621 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800599:	8d 45 14             	lea    0x14(%ebp),%eax
  80059c:	e8 70 fc ff ff       	call   800211 <getuint>
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005ac:	eb 73                	jmp    800621 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b1:	e8 5b fc ff ff       	call   800211 <getuint>
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	53                   	push   %ebx
  8005c0:	6a 58                	push   $0x58
  8005c2:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c4:	83 c4 08             	add    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 58                	push   $0x58
  8005ca:	ff d6                	call   *%esi
			putch('X', putdat);
  8005cc:	83 c4 08             	add    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 58                	push   $0x58
  8005d2:	ff d6                	call   *%esi
			goto number;
  8005d4:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8005d7:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8005dc:	eb 43                	jmp    800621 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	53                   	push   %ebx
  8005e2:	6a 30                	push   $0x30
  8005e4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e6:	83 c4 08             	add    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	6a 78                	push   $0x78
  8005ec:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800601:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800604:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060c:	eb 13                	jmp    800621 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 fb fb ff ff       	call   800211 <getuint>
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80061c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800628:	52                   	push   %edx
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	50                   	push   %eax
  80062d:	ff 75 dc             	pushl  -0x24(%ebp)
  800630:	ff 75 d8             	pushl  -0x28(%ebp)
  800633:	89 da                	mov    %ebx,%edx
  800635:	89 f0                	mov    %esi,%eax
  800637:	e8 26 fb ff ff       	call   800162 <printnum>
			break;
  80063c:	83 c4 20             	add    $0x20,%esp
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 64 fc ff ff       	jmp    8002ab <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	51                   	push   %ecx
  80064c:	ff d6                	call   *%esi
			break;
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800654:	e9 52 fc ff ff       	jmp    8002ab <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 25                	push   $0x25
  80065f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	eb 03                	jmp    800669 <vprintfmt+0x3e4>
  800666:	83 ef 01             	sub    $0x1,%edi
  800669:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066d:	75 f7                	jne    800666 <vprintfmt+0x3e1>
  80066f:	e9 37 fc ff ff       	jmp    8002ab <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800677:	5b                   	pop    %ebx
  800678:	5e                   	pop    %esi
  800679:	5f                   	pop    %edi
  80067a:	5d                   	pop    %ebp
  80067b:	c3                   	ret    

0080067c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	83 ec 18             	sub    $0x18,%esp
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800688:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800692:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800699:	85 c0                	test   %eax,%eax
  80069b:	74 26                	je     8006c3 <vsnprintf+0x47>
  80069d:	85 d2                	test   %edx,%edx
  80069f:	7e 22                	jle    8006c3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a1:	ff 75 14             	pushl  0x14(%ebp)
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006aa:	50                   	push   %eax
  8006ab:	68 4b 02 80 00       	push   $0x80024b
  8006b0:	e8 d0 fb ff ff       	call   800285 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 05                	jmp    8006c8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9a ff ff ff       	call   80067c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	eb 03                	jmp    8006f4 <strlen+0x10>
		n++;
  8006f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f8:	75 f7                	jne    8006f1 <strlen+0xd>
		n++;
	return n;
}
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800702:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800705:	ba 00 00 00 00       	mov    $0x0,%edx
  80070a:	eb 03                	jmp    80070f <strnlen+0x13>
		n++;
  80070c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	39 c2                	cmp    %eax,%edx
  800711:	74 08                	je     80071b <strnlen+0x1f>
  800713:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800717:	75 f3                	jne    80070c <strnlen+0x10>
  800719:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	53                   	push   %ebx
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800727:	89 c2                	mov    %eax,%edx
  800729:	83 c2 01             	add    $0x1,%edx
  80072c:	83 c1 01             	add    $0x1,%ecx
  80072f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800733:	88 5a ff             	mov    %bl,-0x1(%edx)
  800736:	84 db                	test   %bl,%bl
  800738:	75 ef                	jne    800729 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073a:	5b                   	pop    %ebx
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800744:	53                   	push   %ebx
  800745:	e8 9a ff ff ff       	call   8006e4 <strlen>
  80074a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	01 d8                	add    %ebx,%eax
  800752:	50                   	push   %eax
  800753:	e8 c5 ff ff ff       	call   80071d <strcpy>
	return dst;
}
  800758:	89 d8                	mov    %ebx,%eax
  80075a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	8b 75 08             	mov    0x8(%ebp),%esi
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076a:	89 f3                	mov    %esi,%ebx
  80076c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076f:	89 f2                	mov    %esi,%edx
  800771:	eb 0f                	jmp    800782 <strncpy+0x23>
		*dst++ = *src;
  800773:	83 c2 01             	add    $0x1,%edx
  800776:	0f b6 01             	movzbl (%ecx),%eax
  800779:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077c:	80 39 01             	cmpb   $0x1,(%ecx)
  80077f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800782:	39 da                	cmp    %ebx,%edx
  800784:	75 ed                	jne    800773 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800786:	89 f0                	mov    %esi,%eax
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800797:	8b 55 10             	mov    0x10(%ebp),%edx
  80079a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079c:	85 d2                	test   %edx,%edx
  80079e:	74 21                	je     8007c1 <strlcpy+0x35>
  8007a0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a4:	89 f2                	mov    %esi,%edx
  8007a6:	eb 09                	jmp    8007b1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a8:	83 c2 01             	add    $0x1,%edx
  8007ab:	83 c1 01             	add    $0x1,%ecx
  8007ae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b1:	39 c2                	cmp    %eax,%edx
  8007b3:	74 09                	je     8007be <strlcpy+0x32>
  8007b5:	0f b6 19             	movzbl (%ecx),%ebx
  8007b8:	84 db                	test   %bl,%bl
  8007ba:	75 ec                	jne    8007a8 <strlcpy+0x1c>
  8007bc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007be:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c1:	29 f0                	sub    %esi,%eax
}
  8007c3:	5b                   	pop    %ebx
  8007c4:	5e                   	pop    %esi
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d0:	eb 06                	jmp    8007d8 <strcmp+0x11>
		p++, q++;
  8007d2:	83 c1 01             	add    $0x1,%ecx
  8007d5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d8:	0f b6 01             	movzbl (%ecx),%eax
  8007db:	84 c0                	test   %al,%al
  8007dd:	74 04                	je     8007e3 <strcmp+0x1c>
  8007df:	3a 02                	cmp    (%edx),%al
  8007e1:	74 ef                	je     8007d2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e3:	0f b6 c0             	movzbl %al,%eax
  8007e6:	0f b6 12             	movzbl (%edx),%edx
  8007e9:	29 d0                	sub    %edx,%eax
}
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f7:	89 c3                	mov    %eax,%ebx
  8007f9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fc:	eb 06                	jmp    800804 <strncmp+0x17>
		n--, p++, q++;
  8007fe:	83 c0 01             	add    $0x1,%eax
  800801:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800804:	39 d8                	cmp    %ebx,%eax
  800806:	74 15                	je     80081d <strncmp+0x30>
  800808:	0f b6 08             	movzbl (%eax),%ecx
  80080b:	84 c9                	test   %cl,%cl
  80080d:	74 04                	je     800813 <strncmp+0x26>
  80080f:	3a 0a                	cmp    (%edx),%cl
  800811:	74 eb                	je     8007fe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800813:	0f b6 00             	movzbl (%eax),%eax
  800816:	0f b6 12             	movzbl (%edx),%edx
  800819:	29 d0                	sub    %edx,%eax
  80081b:	eb 05                	jmp    800822 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800822:	5b                   	pop    %ebx
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082f:	eb 07                	jmp    800838 <strchr+0x13>
		if (*s == c)
  800831:	38 ca                	cmp    %cl,%dl
  800833:	74 0f                	je     800844 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	0f b6 10             	movzbl (%eax),%edx
  80083b:	84 d2                	test   %dl,%dl
  80083d:	75 f2                	jne    800831 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800850:	eb 03                	jmp    800855 <strfind+0xf>
  800852:	83 c0 01             	add    $0x1,%eax
  800855:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800858:	38 ca                	cmp    %cl,%dl
  80085a:	74 04                	je     800860 <strfind+0x1a>
  80085c:	84 d2                	test   %dl,%dl
  80085e:	75 f2                	jne    800852 <strfind+0xc>
			break;
	return (char *) s;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086e:	85 c9                	test   %ecx,%ecx
  800870:	74 36                	je     8008a8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800872:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800878:	75 28                	jne    8008a2 <memset+0x40>
  80087a:	f6 c1 03             	test   $0x3,%cl
  80087d:	75 23                	jne    8008a2 <memset+0x40>
		c &= 0xFF;
  80087f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800883:	89 d3                	mov    %edx,%ebx
  800885:	c1 e3 08             	shl    $0x8,%ebx
  800888:	89 d6                	mov    %edx,%esi
  80088a:	c1 e6 18             	shl    $0x18,%esi
  80088d:	89 d0                	mov    %edx,%eax
  80088f:	c1 e0 10             	shl    $0x10,%eax
  800892:	09 f0                	or     %esi,%eax
  800894:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800896:	89 d8                	mov    %ebx,%eax
  800898:	09 d0                	or     %edx,%eax
  80089a:	c1 e9 02             	shr    $0x2,%ecx
  80089d:	fc                   	cld    
  80089e:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a0:	eb 06                	jmp    8008a8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a5:	fc                   	cld    
  8008a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a8:	89 f8                	mov    %edi,%eax
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5f                   	pop    %edi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	57                   	push   %edi
  8008b3:	56                   	push   %esi
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bd:	39 c6                	cmp    %eax,%esi
  8008bf:	73 35                	jae    8008f6 <memmove+0x47>
  8008c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c4:	39 d0                	cmp    %edx,%eax
  8008c6:	73 2e                	jae    8008f6 <memmove+0x47>
		s += n;
		d += n;
  8008c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cb:	89 d6                	mov    %edx,%esi
  8008cd:	09 fe                	or     %edi,%esi
  8008cf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d5:	75 13                	jne    8008ea <memmove+0x3b>
  8008d7:	f6 c1 03             	test   $0x3,%cl
  8008da:	75 0e                	jne    8008ea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008dc:	83 ef 04             	sub    $0x4,%edi
  8008df:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e2:	c1 e9 02             	shr    $0x2,%ecx
  8008e5:	fd                   	std    
  8008e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e8:	eb 09                	jmp    8008f3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ea:	83 ef 01             	sub    $0x1,%edi
  8008ed:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f0:	fd                   	std    
  8008f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f3:	fc                   	cld    
  8008f4:	eb 1d                	jmp    800913 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f6:	89 f2                	mov    %esi,%edx
  8008f8:	09 c2                	or     %eax,%edx
  8008fa:	f6 c2 03             	test   $0x3,%dl
  8008fd:	75 0f                	jne    80090e <memmove+0x5f>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 0a                	jne    80090e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800904:	c1 e9 02             	shr    $0x2,%ecx
  800907:	89 c7                	mov    %eax,%edi
  800909:	fc                   	cld    
  80090a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090c:	eb 05                	jmp    800913 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090e:	89 c7                	mov    %eax,%edi
  800910:	fc                   	cld    
  800911:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091a:	ff 75 10             	pushl  0x10(%ebp)
  80091d:	ff 75 0c             	pushl  0xc(%ebp)
  800920:	ff 75 08             	pushl  0x8(%ebp)
  800923:	e8 87 ff ff ff       	call   8008af <memmove>
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	89 c6                	mov    %eax,%esi
  800937:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093a:	eb 1a                	jmp    800956 <memcmp+0x2c>
		if (*s1 != *s2)
  80093c:	0f b6 08             	movzbl (%eax),%ecx
  80093f:	0f b6 1a             	movzbl (%edx),%ebx
  800942:	38 d9                	cmp    %bl,%cl
  800944:	74 0a                	je     800950 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800946:	0f b6 c1             	movzbl %cl,%eax
  800949:	0f b6 db             	movzbl %bl,%ebx
  80094c:	29 d8                	sub    %ebx,%eax
  80094e:	eb 0f                	jmp    80095f <memcmp+0x35>
		s1++, s2++;
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	39 f0                	cmp    %esi,%eax
  800958:	75 e2                	jne    80093c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096a:	89 c1                	mov    %eax,%ecx
  80096c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800973:	eb 0a                	jmp    80097f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	39 da                	cmp    %ebx,%edx
  80097a:	74 07                	je     800983 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	39 c8                	cmp    %ecx,%eax
  800981:	72 f2                	jb     800975 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800992:	eb 03                	jmp    800997 <strtol+0x11>
		s++;
  800994:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	3c 20                	cmp    $0x20,%al
  80099c:	74 f6                	je     800994 <strtol+0xe>
  80099e:	3c 09                	cmp    $0x9,%al
  8009a0:	74 f2                	je     800994 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a2:	3c 2b                	cmp    $0x2b,%al
  8009a4:	75 0a                	jne    8009b0 <strtol+0x2a>
		s++;
  8009a6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ae:	eb 11                	jmp    8009c1 <strtol+0x3b>
  8009b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b5:	3c 2d                	cmp    $0x2d,%al
  8009b7:	75 08                	jne    8009c1 <strtol+0x3b>
		s++, neg = 1;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c7:	75 15                	jne    8009de <strtol+0x58>
  8009c9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cc:	75 10                	jne    8009de <strtol+0x58>
  8009ce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d2:	75 7c                	jne    800a50 <strtol+0xca>
		s += 2, base = 16;
  8009d4:	83 c1 02             	add    $0x2,%ecx
  8009d7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009dc:	eb 16                	jmp    8009f4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009de:	85 db                	test   %ebx,%ebx
  8009e0:	75 12                	jne    8009f4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ea:	75 08                	jne    8009f4 <strtol+0x6e>
		s++, base = 8;
  8009ec:	83 c1 01             	add    $0x1,%ecx
  8009ef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fc:	0f b6 11             	movzbl (%ecx),%edx
  8009ff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	80 fb 09             	cmp    $0x9,%bl
  800a07:	77 08                	ja     800a11 <strtol+0x8b>
			dig = *s - '0';
  800a09:	0f be d2             	movsbl %dl,%edx
  800a0c:	83 ea 30             	sub    $0x30,%edx
  800a0f:	eb 22                	jmp    800a33 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a14:	89 f3                	mov    %esi,%ebx
  800a16:	80 fb 19             	cmp    $0x19,%bl
  800a19:	77 08                	ja     800a23 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1b:	0f be d2             	movsbl %dl,%edx
  800a1e:	83 ea 57             	sub    $0x57,%edx
  800a21:	eb 10                	jmp    800a33 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a26:	89 f3                	mov    %esi,%ebx
  800a28:	80 fb 19             	cmp    $0x19,%bl
  800a2b:	77 16                	ja     800a43 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2d:	0f be d2             	movsbl %dl,%edx
  800a30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a36:	7d 0b                	jge    800a43 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a38:	83 c1 01             	add    $0x1,%ecx
  800a3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a41:	eb b9                	jmp    8009fc <strtol+0x76>

	if (endptr)
  800a43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a47:	74 0d                	je     800a56 <strtol+0xd0>
		*endptr = (char *) s;
  800a49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4c:	89 0e                	mov    %ecx,(%esi)
  800a4e:	eb 06                	jmp    800a56 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a50:	85 db                	test   %ebx,%ebx
  800a52:	74 98                	je     8009ec <strtol+0x66>
  800a54:	eb 9e                	jmp    8009f4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	f7 da                	neg    %edx
  800a5a:	85 ff                	test   %edi,%edi
  800a5c:	0f 45 c2             	cmovne %edx,%eax
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	89 c7                	mov    %eax,%edi
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a92:	89 d1                	mov    %edx,%ecx
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 cb                	mov    %ecx,%ebx
  800ab9:	89 cf                	mov    %ecx,%edi
  800abb:	89 ce                	mov    %ecx,%esi
  800abd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	7e 17                	jle    800ada <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac3:	83 ec 0c             	sub    $0xc,%esp
  800ac6:	50                   	push   %eax
  800ac7:	6a 03                	push   $0x3
  800ac9:	68 1f 21 80 00       	push   $0x80211f
  800ace:	6a 23                	push   $0x23
  800ad0:	68 3c 21 80 00       	push   $0x80213c
  800ad5:	e8 1a 0f 00 00       	call   8019f4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 02 00 00 00       	mov    $0x2,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_yield>:

void
sys_yield(void)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b07:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b11:	89 d1                	mov    %edx,%ecx
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b29:	be 00 00 00 00       	mov    $0x0,%esi
  800b2e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3c:	89 f7                	mov    %esi,%edi
  800b3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b40:	85 c0                	test   %eax,%eax
  800b42:	7e 17                	jle    800b5b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b44:	83 ec 0c             	sub    $0xc,%esp
  800b47:	50                   	push   %eax
  800b48:	6a 04                	push   $0x4
  800b4a:	68 1f 21 80 00       	push   $0x80211f
  800b4f:	6a 23                	push   $0x23
  800b51:	68 3c 21 80 00       	push   $0x80213c
  800b56:	e8 99 0e 00 00       	call   8019f4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b6c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7d:	8b 75 18             	mov    0x18(%ebp),%esi
  800b80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b82:	85 c0                	test   %eax,%eax
  800b84:	7e 17                	jle    800b9d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b86:	83 ec 0c             	sub    $0xc,%esp
  800b89:	50                   	push   %eax
  800b8a:	6a 05                	push   $0x5
  800b8c:	68 1f 21 80 00       	push   $0x80211f
  800b91:	6a 23                	push   $0x23
  800b93:	68 3c 21 80 00       	push   $0x80213c
  800b98:	e8 57 0e 00 00       	call   8019f4 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	89 df                	mov    %ebx,%edi
  800bc0:	89 de                	mov    %ebx,%esi
  800bc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	7e 17                	jle    800bdf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	50                   	push   %eax
  800bcc:	6a 06                	push   $0x6
  800bce:	68 1f 21 80 00       	push   $0x80211f
  800bd3:	6a 23                	push   $0x23
  800bd5:	68 3c 21 80 00       	push   $0x80213c
  800bda:	e8 15 0e 00 00       	call   8019f4 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	53                   	push   %ebx
  800bed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf5:	b8 08 00 00 00       	mov    $0x8,%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	89 df                	mov    %ebx,%edi
  800c02:	89 de                	mov    %ebx,%esi
  800c04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c06:	85 c0                	test   %eax,%eax
  800c08:	7e 17                	jle    800c21 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 08                	push   $0x8
  800c10:	68 1f 21 80 00       	push   $0x80211f
  800c15:	6a 23                	push   $0x23
  800c17:	68 3c 21 80 00       	push   $0x80213c
  800c1c:	e8 d3 0d 00 00       	call   8019f4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	53                   	push   %ebx
  800c2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c32:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c37:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c42:	89 df                	mov    %ebx,%edi
  800c44:	89 de                	mov    %ebx,%esi
  800c46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c48:	85 c0                	test   %eax,%eax
  800c4a:	7e 17                	jle    800c63 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4c:	83 ec 0c             	sub    $0xc,%esp
  800c4f:	50                   	push   %eax
  800c50:	6a 09                	push   $0x9
  800c52:	68 1f 21 80 00       	push   $0x80211f
  800c57:	6a 23                	push   $0x23
  800c59:	68 3c 21 80 00       	push   $0x80213c
  800c5e:	e8 91 0d 00 00       	call   8019f4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    

00800c6b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	57                   	push   %edi
  800c6f:	56                   	push   %esi
  800c70:	53                   	push   %ebx
  800c71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	89 df                	mov    %ebx,%edi
  800c86:	89 de                	mov    %ebx,%esi
  800c88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	7e 17                	jle    800ca5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	6a 0a                	push   $0xa
  800c94:	68 1f 21 80 00       	push   $0x80211f
  800c99:	6a 23                	push   $0x23
  800c9b:	68 3c 21 80 00       	push   $0x80213c
  800ca0:	e8 4f 0d 00 00       	call   8019f4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb3:	be 00 00 00 00       	mov    $0x0,%esi
  800cb8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5f                   	pop    %edi
  800cce:	5d                   	pop    %ebp
  800ccf:	c3                   	ret    

00800cd0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
  800cd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cde:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	89 cb                	mov    %ecx,%ebx
  800ce8:	89 cf                	mov    %ecx,%edi
  800cea:	89 ce                	mov    %ecx,%esi
  800cec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7e 17                	jle    800d09 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 0d                	push   $0xd
  800cf8:	68 1f 21 80 00       	push   $0x80211f
  800cfd:	6a 23                	push   $0x23
  800cff:	68 3c 21 80 00       	push   $0x80213c
  800d04:	e8 eb 0c 00 00       	call   8019f4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	05 00 00 00 30       	add    $0x30000000,%eax
  800d1c:	c1 e8 0c             	shr    $0xc,%eax
}
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	05 00 00 00 30       	add    $0x30000000,%eax
  800d2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d31:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d43:	89 c2                	mov    %eax,%edx
  800d45:	c1 ea 16             	shr    $0x16,%edx
  800d48:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d4f:	f6 c2 01             	test   $0x1,%dl
  800d52:	74 11                	je     800d65 <fd_alloc+0x2d>
  800d54:	89 c2                	mov    %eax,%edx
  800d56:	c1 ea 0c             	shr    $0xc,%edx
  800d59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d60:	f6 c2 01             	test   $0x1,%dl
  800d63:	75 09                	jne    800d6e <fd_alloc+0x36>
			*fd_store = fd;
  800d65:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d67:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6c:	eb 17                	jmp    800d85 <fd_alloc+0x4d>
  800d6e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d73:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d78:	75 c9                	jne    800d43 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d7a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800d80:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d8d:	83 f8 1f             	cmp    $0x1f,%eax
  800d90:	77 36                	ja     800dc8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d92:	c1 e0 0c             	shl    $0xc,%eax
  800d95:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d9a:	89 c2                	mov    %eax,%edx
  800d9c:	c1 ea 16             	shr    $0x16,%edx
  800d9f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800da6:	f6 c2 01             	test   $0x1,%dl
  800da9:	74 24                	je     800dcf <fd_lookup+0x48>
  800dab:	89 c2                	mov    %eax,%edx
  800dad:	c1 ea 0c             	shr    $0xc,%edx
  800db0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800db7:	f6 c2 01             	test   $0x1,%dl
  800dba:	74 1a                	je     800dd6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbf:	89 02                	mov    %eax,(%edx)
	return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 13                	jmp    800ddb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dc8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dcd:	eb 0c                	jmp    800ddb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800dcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dd4:	eb 05                	jmp    800ddb <fd_lookup+0x54>
  800dd6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	83 ec 08             	sub    $0x8,%esp
  800de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de6:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800deb:	eb 13                	jmp    800e00 <dev_lookup+0x23>
  800ded:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800df0:	39 08                	cmp    %ecx,(%eax)
  800df2:	75 0c                	jne    800e00 <dev_lookup+0x23>
			*dev = devtab[i];
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	eb 2e                	jmp    800e2e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e00:	8b 02                	mov    (%edx),%eax
  800e02:	85 c0                	test   %eax,%eax
  800e04:	75 e7                	jne    800ded <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e06:	a1 04 40 80 00       	mov    0x804004,%eax
  800e0b:	8b 40 48             	mov    0x48(%eax),%eax
  800e0e:	83 ec 04             	sub    $0x4,%esp
  800e11:	51                   	push   %ecx
  800e12:	50                   	push   %eax
  800e13:	68 4c 21 80 00       	push   $0x80214c
  800e18:	e8 31 f3 ff ff       	call   80014e <cprintf>
	*dev = 0;
  800e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e2e:	c9                   	leave  
  800e2f:	c3                   	ret    

00800e30 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
  800e35:	83 ec 10             	sub    $0x10,%esp
  800e38:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e41:	50                   	push   %eax
  800e42:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e48:	c1 e8 0c             	shr    $0xc,%eax
  800e4b:	50                   	push   %eax
  800e4c:	e8 36 ff ff ff       	call   800d87 <fd_lookup>
  800e51:	83 c4 08             	add    $0x8,%esp
  800e54:	85 c0                	test   %eax,%eax
  800e56:	78 05                	js     800e5d <fd_close+0x2d>
	    || fd != fd2)
  800e58:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e5b:	74 0c                	je     800e69 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e5d:	84 db                	test   %bl,%bl
  800e5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e64:	0f 44 c2             	cmove  %edx,%eax
  800e67:	eb 41                	jmp    800eaa <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e6f:	50                   	push   %eax
  800e70:	ff 36                	pushl  (%esi)
  800e72:	e8 66 ff ff ff       	call   800ddd <dev_lookup>
  800e77:	89 c3                	mov    %eax,%ebx
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	78 1a                	js     800e9a <fd_close+0x6a>
		if (dev->dev_close)
  800e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e83:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800e86:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	74 0b                	je     800e9a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800e8f:	83 ec 0c             	sub    $0xc,%esp
  800e92:	56                   	push   %esi
  800e93:	ff d0                	call   *%eax
  800e95:	89 c3                	mov    %eax,%ebx
  800e97:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800e9a:	83 ec 08             	sub    $0x8,%esp
  800e9d:	56                   	push   %esi
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 00 fd ff ff       	call   800ba5 <sys_page_unmap>
	return r;
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	89 d8                	mov    %ebx,%eax
}
  800eaa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	ff 75 08             	pushl  0x8(%ebp)
  800ebe:	e8 c4 fe ff ff       	call   800d87 <fd_lookup>
  800ec3:	83 c4 08             	add    $0x8,%esp
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 10                	js     800eda <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800eca:	83 ec 08             	sub    $0x8,%esp
  800ecd:	6a 01                	push   $0x1
  800ecf:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed2:	e8 59 ff ff ff       	call   800e30 <fd_close>
  800ed7:	83 c4 10             	add    $0x10,%esp
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <close_all>:

void
close_all(void)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	53                   	push   %ebx
  800ee0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ee3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	53                   	push   %ebx
  800eec:	e8 c0 ff ff ff       	call   800eb1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ef1:	83 c3 01             	add    $0x1,%ebx
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	83 fb 20             	cmp    $0x20,%ebx
  800efa:	75 ec                	jne    800ee8 <close_all+0xc>
		close(i);
}
  800efc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	57                   	push   %edi
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	83 ec 2c             	sub    $0x2c,%esp
  800f0a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f0d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f10:	50                   	push   %eax
  800f11:	ff 75 08             	pushl  0x8(%ebp)
  800f14:	e8 6e fe ff ff       	call   800d87 <fd_lookup>
  800f19:	83 c4 08             	add    $0x8,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	0f 88 c1 00 00 00    	js     800fe5 <dup+0xe4>
		return r;
	close(newfdnum);
  800f24:	83 ec 0c             	sub    $0xc,%esp
  800f27:	56                   	push   %esi
  800f28:	e8 84 ff ff ff       	call   800eb1 <close>

	newfd = INDEX2FD(newfdnum);
  800f2d:	89 f3                	mov    %esi,%ebx
  800f2f:	c1 e3 0c             	shl    $0xc,%ebx
  800f32:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f38:	83 c4 04             	add    $0x4,%esp
  800f3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3e:	e8 de fd ff ff       	call   800d21 <fd2data>
  800f43:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f45:	89 1c 24             	mov    %ebx,(%esp)
  800f48:	e8 d4 fd ff ff       	call   800d21 <fd2data>
  800f4d:	83 c4 10             	add    $0x10,%esp
  800f50:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f53:	89 f8                	mov    %edi,%eax
  800f55:	c1 e8 16             	shr    $0x16,%eax
  800f58:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f5f:	a8 01                	test   $0x1,%al
  800f61:	74 37                	je     800f9a <dup+0x99>
  800f63:	89 f8                	mov    %edi,%eax
  800f65:	c1 e8 0c             	shr    $0xc,%eax
  800f68:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f6f:	f6 c2 01             	test   $0x1,%dl
  800f72:	74 26                	je     800f9a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f74:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7b:	83 ec 0c             	sub    $0xc,%esp
  800f7e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f83:	50                   	push   %eax
  800f84:	ff 75 d4             	pushl  -0x2c(%ebp)
  800f87:	6a 00                	push   $0x0
  800f89:	57                   	push   %edi
  800f8a:	6a 00                	push   $0x0
  800f8c:	e8 d2 fb ff ff       	call   800b63 <sys_page_map>
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 2e                	js     800fc8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f9a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f9d:	89 d0                	mov    %edx,%eax
  800f9f:	c1 e8 0c             	shr    $0xc,%eax
  800fa2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	25 07 0e 00 00       	and    $0xe07,%eax
  800fb1:	50                   	push   %eax
  800fb2:	53                   	push   %ebx
  800fb3:	6a 00                	push   $0x0
  800fb5:	52                   	push   %edx
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 a6 fb ff ff       	call   800b63 <sys_page_map>
  800fbd:	89 c7                	mov    %eax,%edi
  800fbf:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fc2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc4:	85 ff                	test   %edi,%edi
  800fc6:	79 1d                	jns    800fe5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800fc8:	83 ec 08             	sub    $0x8,%esp
  800fcb:	53                   	push   %ebx
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 d2 fb ff ff       	call   800ba5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fd3:	83 c4 08             	add    $0x8,%esp
  800fd6:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fd9:	6a 00                	push   $0x0
  800fdb:	e8 c5 fb ff ff       	call   800ba5 <sys_page_unmap>
	return r;
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	89 f8                	mov    %edi,%eax
}
  800fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	53                   	push   %ebx
  800ff1:	83 ec 14             	sub    $0x14,%esp
  800ff4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ff7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	53                   	push   %ebx
  800ffc:	e8 86 fd ff ff       	call   800d87 <fd_lookup>
  801001:	83 c4 08             	add    $0x8,%esp
  801004:	89 c2                	mov    %eax,%edx
  801006:	85 c0                	test   %eax,%eax
  801008:	78 6d                	js     801077 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80100a:	83 ec 08             	sub    $0x8,%esp
  80100d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801014:	ff 30                	pushl  (%eax)
  801016:	e8 c2 fd ff ff       	call   800ddd <dev_lookup>
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	78 4c                	js     80106e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801022:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801025:	8b 42 08             	mov    0x8(%edx),%eax
  801028:	83 e0 03             	and    $0x3,%eax
  80102b:	83 f8 01             	cmp    $0x1,%eax
  80102e:	75 21                	jne    801051 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801030:	a1 04 40 80 00       	mov    0x804004,%eax
  801035:	8b 40 48             	mov    0x48(%eax),%eax
  801038:	83 ec 04             	sub    $0x4,%esp
  80103b:	53                   	push   %ebx
  80103c:	50                   	push   %eax
  80103d:	68 8d 21 80 00       	push   $0x80218d
  801042:	e8 07 f1 ff ff       	call   80014e <cprintf>
		return -E_INVAL;
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80104f:	eb 26                	jmp    801077 <read+0x8a>
	}
	if (!dev->dev_read)
  801051:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801054:	8b 40 08             	mov    0x8(%eax),%eax
  801057:	85 c0                	test   %eax,%eax
  801059:	74 17                	je     801072 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80105b:	83 ec 04             	sub    $0x4,%esp
  80105e:	ff 75 10             	pushl  0x10(%ebp)
  801061:	ff 75 0c             	pushl  0xc(%ebp)
  801064:	52                   	push   %edx
  801065:	ff d0                	call   *%eax
  801067:	89 c2                	mov    %eax,%edx
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	eb 09                	jmp    801077 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106e:	89 c2                	mov    %eax,%edx
  801070:	eb 05                	jmp    801077 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801072:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801077:	89 d0                	mov    %edx,%eax
  801079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107c:	c9                   	leave  
  80107d:	c3                   	ret    

0080107e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 0c             	sub    $0xc,%esp
  801087:	8b 7d 08             	mov    0x8(%ebp),%edi
  80108a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80108d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801092:	eb 21                	jmp    8010b5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	89 f0                	mov    %esi,%eax
  801099:	29 d8                	sub    %ebx,%eax
  80109b:	50                   	push   %eax
  80109c:	89 d8                	mov    %ebx,%eax
  80109e:	03 45 0c             	add    0xc(%ebp),%eax
  8010a1:	50                   	push   %eax
  8010a2:	57                   	push   %edi
  8010a3:	e8 45 ff ff ff       	call   800fed <read>
		if (m < 0)
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	78 10                	js     8010bf <readn+0x41>
			return m;
		if (m == 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	74 0a                	je     8010bd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b3:	01 c3                	add    %eax,%ebx
  8010b5:	39 f3                	cmp    %esi,%ebx
  8010b7:	72 db                	jb     801094 <readn+0x16>
  8010b9:	89 d8                	mov    %ebx,%eax
  8010bb:	eb 02                	jmp    8010bf <readn+0x41>
  8010bd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c2:	5b                   	pop    %ebx
  8010c3:	5e                   	pop    %esi
  8010c4:	5f                   	pop    %edi
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 14             	sub    $0x14,%esp
  8010ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	53                   	push   %ebx
  8010d6:	e8 ac fc ff ff       	call   800d87 <fd_lookup>
  8010db:	83 c4 08             	add    $0x8,%esp
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 68                	js     80114c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ee:	ff 30                	pushl  (%eax)
  8010f0:	e8 e8 fc ff ff       	call   800ddd <dev_lookup>
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 47                	js     801143 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ff:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801103:	75 21                	jne    801126 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801105:	a1 04 40 80 00       	mov    0x804004,%eax
  80110a:	8b 40 48             	mov    0x48(%eax),%eax
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	53                   	push   %ebx
  801111:	50                   	push   %eax
  801112:	68 a9 21 80 00       	push   $0x8021a9
  801117:	e8 32 f0 ff ff       	call   80014e <cprintf>
		return -E_INVAL;
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801124:	eb 26                	jmp    80114c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801126:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801129:	8b 52 0c             	mov    0xc(%edx),%edx
  80112c:	85 d2                	test   %edx,%edx
  80112e:	74 17                	je     801147 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	ff 75 10             	pushl  0x10(%ebp)
  801136:	ff 75 0c             	pushl  0xc(%ebp)
  801139:	50                   	push   %eax
  80113a:	ff d2                	call   *%edx
  80113c:	89 c2                	mov    %eax,%edx
  80113e:	83 c4 10             	add    $0x10,%esp
  801141:	eb 09                	jmp    80114c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801143:	89 c2                	mov    %eax,%edx
  801145:	eb 05                	jmp    80114c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801147:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80114c:	89 d0                	mov    %edx,%eax
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <seek>:

int
seek(int fdnum, off_t offset)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801159:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80115c:	50                   	push   %eax
  80115d:	ff 75 08             	pushl  0x8(%ebp)
  801160:	e8 22 fc ff ff       	call   800d87 <fd_lookup>
  801165:	83 c4 08             	add    $0x8,%esp
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 0e                	js     80117a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80116c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80116f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801172:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801175:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    

0080117c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	53                   	push   %ebx
  801180:	83 ec 14             	sub    $0x14,%esp
  801183:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801186:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801189:	50                   	push   %eax
  80118a:	53                   	push   %ebx
  80118b:	e8 f7 fb ff ff       	call   800d87 <fd_lookup>
  801190:	83 c4 08             	add    $0x8,%esp
  801193:	89 c2                	mov    %eax,%edx
  801195:	85 c0                	test   %eax,%eax
  801197:	78 65                	js     8011fe <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a3:	ff 30                	pushl  (%eax)
  8011a5:	e8 33 fc ff ff       	call   800ddd <dev_lookup>
  8011aa:	83 c4 10             	add    $0x10,%esp
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	78 44                	js     8011f5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011b8:	75 21                	jne    8011db <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011ba:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011bf:	8b 40 48             	mov    0x48(%eax),%eax
  8011c2:	83 ec 04             	sub    $0x4,%esp
  8011c5:	53                   	push   %ebx
  8011c6:	50                   	push   %eax
  8011c7:	68 6c 21 80 00       	push   $0x80216c
  8011cc:	e8 7d ef ff ff       	call   80014e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011d9:	eb 23                	jmp    8011fe <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8011db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011de:	8b 52 18             	mov    0x18(%edx),%edx
  8011e1:	85 d2                	test   %edx,%edx
  8011e3:	74 14                	je     8011f9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8011e5:	83 ec 08             	sub    $0x8,%esp
  8011e8:	ff 75 0c             	pushl  0xc(%ebp)
  8011eb:	50                   	push   %eax
  8011ec:	ff d2                	call   *%edx
  8011ee:	89 c2                	mov    %eax,%edx
  8011f0:	83 c4 10             	add    $0x10,%esp
  8011f3:	eb 09                	jmp    8011fe <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	eb 05                	jmp    8011fe <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8011f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8011fe:	89 d0                	mov    %edx,%eax
  801200:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801203:	c9                   	leave  
  801204:	c3                   	ret    

00801205 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	53                   	push   %ebx
  801209:	83 ec 14             	sub    $0x14,%esp
  80120c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	ff 75 08             	pushl  0x8(%ebp)
  801216:	e8 6c fb ff ff       	call   800d87 <fd_lookup>
  80121b:	83 c4 08             	add    $0x8,%esp
  80121e:	89 c2                	mov    %eax,%edx
  801220:	85 c0                	test   %eax,%eax
  801222:	78 58                	js     80127c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	ff 30                	pushl  (%eax)
  801230:	e8 a8 fb ff ff       	call   800ddd <dev_lookup>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 37                	js     801273 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80123c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801243:	74 32                	je     801277 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801245:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801248:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80124f:	00 00 00 
	stat->st_isdir = 0;
  801252:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801259:	00 00 00 
	stat->st_dev = dev;
  80125c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801262:	83 ec 08             	sub    $0x8,%esp
  801265:	53                   	push   %ebx
  801266:	ff 75 f0             	pushl  -0x10(%ebp)
  801269:	ff 50 14             	call   *0x14(%eax)
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	83 c4 10             	add    $0x10,%esp
  801271:	eb 09                	jmp    80127c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801273:	89 c2                	mov    %eax,%edx
  801275:	eb 05                	jmp    80127c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801277:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80127c:	89 d0                	mov    %edx,%eax
  80127e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801288:	83 ec 08             	sub    $0x8,%esp
  80128b:	6a 00                	push   $0x0
  80128d:	ff 75 08             	pushl  0x8(%ebp)
  801290:	e8 dc 01 00 00       	call   801471 <open>
  801295:	89 c3                	mov    %eax,%ebx
  801297:	83 c4 10             	add    $0x10,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 1b                	js     8012b9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80129e:	83 ec 08             	sub    $0x8,%esp
  8012a1:	ff 75 0c             	pushl  0xc(%ebp)
  8012a4:	50                   	push   %eax
  8012a5:	e8 5b ff ff ff       	call   801205 <fstat>
  8012aa:	89 c6                	mov    %eax,%esi
	close(fd);
  8012ac:	89 1c 24             	mov    %ebx,(%esp)
  8012af:	e8 fd fb ff ff       	call   800eb1 <close>
	return r;
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	89 f0                	mov    %esi,%eax
}
  8012b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
  8012c5:	89 c6                	mov    %eax,%esi
  8012c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012c9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012d0:	75 12                	jne    8012e4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012d2:	83 ec 0c             	sub    $0xc,%esp
  8012d5:	6a 01                	push   $0x1
  8012d7:	e8 fe 07 00 00       	call   801ada <ipc_find_env>
  8012dc:	a3 00 40 80 00       	mov    %eax,0x804000
  8012e1:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012e4:	6a 07                	push   $0x7
  8012e6:	68 00 50 80 00       	push   $0x805000
  8012eb:	56                   	push   %esi
  8012ec:	ff 35 00 40 80 00    	pushl  0x804000
  8012f2:	e8 a0 07 00 00       	call   801a97 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8012f7:	83 c4 0c             	add    $0xc,%esp
  8012fa:	6a 00                	push   $0x0
  8012fc:	53                   	push   %ebx
  8012fd:	6a 00                	push   $0x0
  8012ff:	e8 36 07 00 00       	call   801a3a <ipc_recv>
}
  801304:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
  801314:	8b 40 0c             	mov    0xc(%eax),%eax
  801317:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80131c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801324:	ba 00 00 00 00       	mov    $0x0,%edx
  801329:	b8 02 00 00 00       	mov    $0x2,%eax
  80132e:	e8 8d ff ff ff       	call   8012c0 <fsipc>
}
  801333:	c9                   	leave  
  801334:	c3                   	ret    

00801335 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80133b:	8b 45 08             	mov    0x8(%ebp),%eax
  80133e:	8b 40 0c             	mov    0xc(%eax),%eax
  801341:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801346:	ba 00 00 00 00       	mov    $0x0,%edx
  80134b:	b8 06 00 00 00       	mov    $0x6,%eax
  801350:	e8 6b ff ff ff       	call   8012c0 <fsipc>
}
  801355:	c9                   	leave  
  801356:	c3                   	ret    

00801357 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801357:	55                   	push   %ebp
  801358:	89 e5                	mov    %esp,%ebp
  80135a:	53                   	push   %ebx
  80135b:	83 ec 04             	sub    $0x4,%esp
  80135e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801361:	8b 45 08             	mov    0x8(%ebp),%eax
  801364:	8b 40 0c             	mov    0xc(%eax),%eax
  801367:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80136c:	ba 00 00 00 00       	mov    $0x0,%edx
  801371:	b8 05 00 00 00       	mov    $0x5,%eax
  801376:	e8 45 ff ff ff       	call   8012c0 <fsipc>
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 2c                	js     8013ab <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	68 00 50 80 00       	push   $0x805000
  801387:	53                   	push   %ebx
  801388:	e8 90 f3 ff ff       	call   80071d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80138d:	a1 80 50 80 00       	mov    0x805080,%eax
  801392:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801398:	a1 84 50 80 00       	mov    0x805084,%eax
  80139d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ae:	c9                   	leave  
  8013af:	c3                   	ret    

008013b0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bc:	8b 52 0c             	mov    0xc(%edx),%edx
  8013bf:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013c5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8013ca:	50                   	push   %eax
  8013cb:	ff 75 0c             	pushl  0xc(%ebp)
  8013ce:	68 08 50 80 00       	push   $0x805008
  8013d3:	e8 d7 f4 ff ff       	call   8008af <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013dd:	b8 04 00 00 00       	mov    $0x4,%eax
  8013e2:	e8 d9 fe ff ff       	call   8012c0 <fsipc>
	//panic("devfile_write not implemented");
}
  8013e7:	c9                   	leave  
  8013e8:	c3                   	ret    

008013e9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	56                   	push   %esi
  8013ed:	53                   	push   %ebx
  8013ee:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013fc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801402:	ba 00 00 00 00       	mov    $0x0,%edx
  801407:	b8 03 00 00 00       	mov    $0x3,%eax
  80140c:	e8 af fe ff ff       	call   8012c0 <fsipc>
  801411:	89 c3                	mov    %eax,%ebx
  801413:	85 c0                	test   %eax,%eax
  801415:	78 51                	js     801468 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801417:	39 c6                	cmp    %eax,%esi
  801419:	73 19                	jae    801434 <devfile_read+0x4b>
  80141b:	68 d8 21 80 00       	push   $0x8021d8
  801420:	68 df 21 80 00       	push   $0x8021df
  801425:	68 80 00 00 00       	push   $0x80
  80142a:	68 f4 21 80 00       	push   $0x8021f4
  80142f:	e8 c0 05 00 00       	call   8019f4 <_panic>
	assert(r <= PGSIZE);
  801434:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801439:	7e 19                	jle    801454 <devfile_read+0x6b>
  80143b:	68 ff 21 80 00       	push   $0x8021ff
  801440:	68 df 21 80 00       	push   $0x8021df
  801445:	68 81 00 00 00       	push   $0x81
  80144a:	68 f4 21 80 00       	push   $0x8021f4
  80144f:	e8 a0 05 00 00       	call   8019f4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801454:	83 ec 04             	sub    $0x4,%esp
  801457:	50                   	push   %eax
  801458:	68 00 50 80 00       	push   $0x805000
  80145d:	ff 75 0c             	pushl  0xc(%ebp)
  801460:	e8 4a f4 ff ff       	call   8008af <memmove>
	return r;
  801465:	83 c4 10             	add    $0x10,%esp
}
  801468:	89 d8                	mov    %ebx,%eax
  80146a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80146d:	5b                   	pop    %ebx
  80146e:	5e                   	pop    %esi
  80146f:	5d                   	pop    %ebp
  801470:	c3                   	ret    

00801471 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	53                   	push   %ebx
  801475:	83 ec 20             	sub    $0x20,%esp
  801478:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80147b:	53                   	push   %ebx
  80147c:	e8 63 f2 ff ff       	call   8006e4 <strlen>
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801489:	7f 67                	jg     8014f2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	e8 a1 f8 ff ff       	call   800d38 <fd_alloc>
  801497:	83 c4 10             	add    $0x10,%esp
		return r;
  80149a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 57                	js     8014f7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	53                   	push   %ebx
  8014a4:	68 00 50 80 00       	push   $0x805000
  8014a9:	e8 6f f2 ff ff       	call   80071d <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b1:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8014be:	e8 fd fd ff ff       	call   8012c0 <fsipc>
  8014c3:	89 c3                	mov    %eax,%ebx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	79 14                	jns    8014e0 <open+0x6f>
		
		fd_close(fd, 0);
  8014cc:	83 ec 08             	sub    $0x8,%esp
  8014cf:	6a 00                	push   $0x0
  8014d1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d4:	e8 57 f9 ff ff       	call   800e30 <fd_close>
		return r;
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	89 da                	mov    %ebx,%edx
  8014de:	eb 17                	jmp    8014f7 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8014e0:	83 ec 0c             	sub    $0xc,%esp
  8014e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e6:	e8 26 f8 ff ff       	call   800d11 <fd2num>
  8014eb:	89 c2                	mov    %eax,%edx
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	eb 05                	jmp    8014f7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8014f2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8014f7:	89 d0                	mov    %edx,%eax
  8014f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
  801509:	b8 08 00 00 00       	mov    $0x8,%eax
  80150e:	e8 ad fd ff ff       	call   8012c0 <fsipc>
}
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
  80151a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80151d:	83 ec 0c             	sub    $0xc,%esp
  801520:	ff 75 08             	pushl  0x8(%ebp)
  801523:	e8 f9 f7 ff ff       	call   800d21 <fd2data>
  801528:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	68 0b 22 80 00       	push   $0x80220b
  801532:	53                   	push   %ebx
  801533:	e8 e5 f1 ff ff       	call   80071d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801538:	8b 46 04             	mov    0x4(%esi),%eax
  80153b:	2b 06                	sub    (%esi),%eax
  80153d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801543:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80154a:	00 00 00 
	stat->st_dev = &devpipe;
  80154d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801554:	30 80 00 
	return 0;
}
  801557:	b8 00 00 00 00       	mov    $0x0,%eax
  80155c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 0c             	sub    $0xc,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80156d:	53                   	push   %ebx
  80156e:	6a 00                	push   $0x0
  801570:	e8 30 f6 ff ff       	call   800ba5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801575:	89 1c 24             	mov    %ebx,(%esp)
  801578:	e8 a4 f7 ff ff       	call   800d21 <fd2data>
  80157d:	83 c4 08             	add    $0x8,%esp
  801580:	50                   	push   %eax
  801581:	6a 00                	push   $0x0
  801583:	e8 1d f6 ff ff       	call   800ba5 <sys_page_unmap>
}
  801588:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    

0080158d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	57                   	push   %edi
  801591:	56                   	push   %esi
  801592:	53                   	push   %ebx
  801593:	83 ec 1c             	sub    $0x1c,%esp
  801596:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801599:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80159b:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a0:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a9:	e8 65 05 00 00       	call   801b13 <pageref>
  8015ae:	89 c3                	mov    %eax,%ebx
  8015b0:	89 3c 24             	mov    %edi,(%esp)
  8015b3:	e8 5b 05 00 00       	call   801b13 <pageref>
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	39 c3                	cmp    %eax,%ebx
  8015bd:	0f 94 c1             	sete   %cl
  8015c0:	0f b6 c9             	movzbl %cl,%ecx
  8015c3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015c6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015cc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015cf:	39 ce                	cmp    %ecx,%esi
  8015d1:	74 1b                	je     8015ee <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8015d3:	39 c3                	cmp    %eax,%ebx
  8015d5:	75 c4                	jne    80159b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015d7:	8b 42 58             	mov    0x58(%edx),%eax
  8015da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015dd:	50                   	push   %eax
  8015de:	56                   	push   %esi
  8015df:	68 12 22 80 00       	push   $0x802212
  8015e4:	e8 65 eb ff ff       	call   80014e <cprintf>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	eb ad                	jmp    80159b <_pipeisclosed+0xe>
	}
}
  8015ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5e                   	pop    %esi
  8015f6:	5f                   	pop    %edi
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    

008015f9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	57                   	push   %edi
  8015fd:	56                   	push   %esi
  8015fe:	53                   	push   %ebx
  8015ff:	83 ec 28             	sub    $0x28,%esp
  801602:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801605:	56                   	push   %esi
  801606:	e8 16 f7 ff ff       	call   800d21 <fd2data>
  80160b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	bf 00 00 00 00       	mov    $0x0,%edi
  801615:	eb 4b                	jmp    801662 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801617:	89 da                	mov    %ebx,%edx
  801619:	89 f0                	mov    %esi,%eax
  80161b:	e8 6d ff ff ff       	call   80158d <_pipeisclosed>
  801620:	85 c0                	test   %eax,%eax
  801622:	75 48                	jne    80166c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801624:	e8 d8 f4 ff ff       	call   800b01 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801629:	8b 43 04             	mov    0x4(%ebx),%eax
  80162c:	8b 0b                	mov    (%ebx),%ecx
  80162e:	8d 51 20             	lea    0x20(%ecx),%edx
  801631:	39 d0                	cmp    %edx,%eax
  801633:	73 e2                	jae    801617 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801638:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80163c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80163f:	89 c2                	mov    %eax,%edx
  801641:	c1 fa 1f             	sar    $0x1f,%edx
  801644:	89 d1                	mov    %edx,%ecx
  801646:	c1 e9 1b             	shr    $0x1b,%ecx
  801649:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80164c:	83 e2 1f             	and    $0x1f,%edx
  80164f:	29 ca                	sub    %ecx,%edx
  801651:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801655:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801659:	83 c0 01             	add    $0x1,%eax
  80165c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165f:	83 c7 01             	add    $0x1,%edi
  801662:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801665:	75 c2                	jne    801629 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801667:	8b 45 10             	mov    0x10(%ebp),%eax
  80166a:	eb 05                	jmp    801671 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801674:	5b                   	pop    %ebx
  801675:	5e                   	pop    %esi
  801676:	5f                   	pop    %edi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	57                   	push   %edi
  80167d:	56                   	push   %esi
  80167e:	53                   	push   %ebx
  80167f:	83 ec 18             	sub    $0x18,%esp
  801682:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801685:	57                   	push   %edi
  801686:	e8 96 f6 ff ff       	call   800d21 <fd2data>
  80168b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	bb 00 00 00 00       	mov    $0x0,%ebx
  801695:	eb 3d                	jmp    8016d4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801697:	85 db                	test   %ebx,%ebx
  801699:	74 04                	je     80169f <devpipe_read+0x26>
				return i;
  80169b:	89 d8                	mov    %ebx,%eax
  80169d:	eb 44                	jmp    8016e3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80169f:	89 f2                	mov    %esi,%edx
  8016a1:	89 f8                	mov    %edi,%eax
  8016a3:	e8 e5 fe ff ff       	call   80158d <_pipeisclosed>
  8016a8:	85 c0                	test   %eax,%eax
  8016aa:	75 32                	jne    8016de <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016ac:	e8 50 f4 ff ff       	call   800b01 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016b1:	8b 06                	mov    (%esi),%eax
  8016b3:	3b 46 04             	cmp    0x4(%esi),%eax
  8016b6:	74 df                	je     801697 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016b8:	99                   	cltd   
  8016b9:	c1 ea 1b             	shr    $0x1b,%edx
  8016bc:	01 d0                	add    %edx,%eax
  8016be:	83 e0 1f             	and    $0x1f,%eax
  8016c1:	29 d0                	sub    %edx,%eax
  8016c3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016cb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8016ce:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d1:	83 c3 01             	add    $0x1,%ebx
  8016d4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8016d7:	75 d8                	jne    8016b1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8016d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8016dc:	eb 05                	jmp    8016e3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016de:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8016e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e6:	5b                   	pop    %ebx
  8016e7:	5e                   	pop    %esi
  8016e8:	5f                   	pop    %edi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f6:	50                   	push   %eax
  8016f7:	e8 3c f6 ff ff       	call   800d38 <fd_alloc>
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	89 c2                	mov    %eax,%edx
  801701:	85 c0                	test   %eax,%eax
  801703:	0f 88 2c 01 00 00    	js     801835 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	68 07 04 00 00       	push   $0x407
  801711:	ff 75 f4             	pushl  -0xc(%ebp)
  801714:	6a 00                	push   $0x0
  801716:	e8 05 f4 ff ff       	call   800b20 <sys_page_alloc>
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	89 c2                	mov    %eax,%edx
  801720:	85 c0                	test   %eax,%eax
  801722:	0f 88 0d 01 00 00    	js     801835 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801728:	83 ec 0c             	sub    $0xc,%esp
  80172b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	e8 04 f6 ff ff       	call   800d38 <fd_alloc>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	0f 88 e2 00 00 00    	js     801823 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801741:	83 ec 04             	sub    $0x4,%esp
  801744:	68 07 04 00 00       	push   $0x407
  801749:	ff 75 f0             	pushl  -0x10(%ebp)
  80174c:	6a 00                	push   $0x0
  80174e:	e8 cd f3 ff ff       	call   800b20 <sys_page_alloc>
  801753:	89 c3                	mov    %eax,%ebx
  801755:	83 c4 10             	add    $0x10,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	0f 88 c3 00 00 00    	js     801823 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801760:	83 ec 0c             	sub    $0xc,%esp
  801763:	ff 75 f4             	pushl  -0xc(%ebp)
  801766:	e8 b6 f5 ff ff       	call   800d21 <fd2data>
  80176b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176d:	83 c4 0c             	add    $0xc,%esp
  801770:	68 07 04 00 00       	push   $0x407
  801775:	50                   	push   %eax
  801776:	6a 00                	push   $0x0
  801778:	e8 a3 f3 ff ff       	call   800b20 <sys_page_alloc>
  80177d:	89 c3                	mov    %eax,%ebx
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	85 c0                	test   %eax,%eax
  801784:	0f 88 89 00 00 00    	js     801813 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178a:	83 ec 0c             	sub    $0xc,%esp
  80178d:	ff 75 f0             	pushl  -0x10(%ebp)
  801790:	e8 8c f5 ff ff       	call   800d21 <fd2data>
  801795:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80179c:	50                   	push   %eax
  80179d:	6a 00                	push   $0x0
  80179f:	56                   	push   %esi
  8017a0:	6a 00                	push   $0x0
  8017a2:	e8 bc f3 ff ff       	call   800b63 <sys_page_map>
  8017a7:	89 c3                	mov    %eax,%ebx
  8017a9:	83 c4 20             	add    $0x20,%esp
  8017ac:	85 c0                	test   %eax,%eax
  8017ae:	78 55                	js     801805 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017b0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017be:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017c5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ce:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8017d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e0:	e8 2c f5 ff ff       	call   800d11 <fd2num>
  8017e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017ea:	83 c4 04             	add    $0x4,%esp
  8017ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8017f0:	e8 1c f5 ff ff       	call   800d11 <fd2num>
  8017f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017fb:	83 c4 10             	add    $0x10,%esp
  8017fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801803:	eb 30                	jmp    801835 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801805:	83 ec 08             	sub    $0x8,%esp
  801808:	56                   	push   %esi
  801809:	6a 00                	push   $0x0
  80180b:	e8 95 f3 ff ff       	call   800ba5 <sys_page_unmap>
  801810:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801813:	83 ec 08             	sub    $0x8,%esp
  801816:	ff 75 f0             	pushl  -0x10(%ebp)
  801819:	6a 00                	push   $0x0
  80181b:	e8 85 f3 ff ff       	call   800ba5 <sys_page_unmap>
  801820:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	ff 75 f4             	pushl  -0xc(%ebp)
  801829:	6a 00                	push   $0x0
  80182b:	e8 75 f3 ff ff       	call   800ba5 <sys_page_unmap>
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801835:	89 d0                	mov    %edx,%eax
  801837:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801847:	50                   	push   %eax
  801848:	ff 75 08             	pushl  0x8(%ebp)
  80184b:	e8 37 f5 ff ff       	call   800d87 <fd_lookup>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	78 18                	js     80186f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	ff 75 f4             	pushl  -0xc(%ebp)
  80185d:	e8 bf f4 ff ff       	call   800d21 <fd2data>
	return _pipeisclosed(fd, p);
  801862:	89 c2                	mov    %eax,%edx
  801864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801867:	e8 21 fd ff ff       	call   80158d <_pipeisclosed>
  80186c:	83 c4 10             	add    $0x10,%esp
}
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801874:	b8 00 00 00 00       	mov    $0x0,%eax
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801881:	68 2a 22 80 00       	push   $0x80222a
  801886:	ff 75 0c             	pushl  0xc(%ebp)
  801889:	e8 8f ee ff ff       	call   80071d <strcpy>
	return 0;
}
  80188e:	b8 00 00 00 00       	mov    $0x0,%eax
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	57                   	push   %edi
  801899:	56                   	push   %esi
  80189a:	53                   	push   %ebx
  80189b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018a1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018a6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ac:	eb 2d                	jmp    8018db <devcons_write+0x46>
		m = n - tot;
  8018ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018b1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018b3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018b6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018bb:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018be:	83 ec 04             	sub    $0x4,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	03 45 0c             	add    0xc(%ebp),%eax
  8018c5:	50                   	push   %eax
  8018c6:	57                   	push   %edi
  8018c7:	e8 e3 ef ff ff       	call   8008af <memmove>
		sys_cputs(buf, m);
  8018cc:	83 c4 08             	add    $0x8,%esp
  8018cf:	53                   	push   %ebx
  8018d0:	57                   	push   %edi
  8018d1:	e8 8e f1 ff ff       	call   800a64 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d6:	01 de                	add    %ebx,%esi
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	89 f0                	mov    %esi,%eax
  8018dd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018e0:	72 cc                	jb     8018ae <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8018e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e5:	5b                   	pop    %ebx
  8018e6:	5e                   	pop    %esi
  8018e7:	5f                   	pop    %edi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    

008018ea <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8018f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8018f9:	74 2a                	je     801925 <devcons_read+0x3b>
  8018fb:	eb 05                	jmp    801902 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8018fd:	e8 ff f1 ff ff       	call   800b01 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801902:	e8 7b f1 ff ff       	call   800a82 <sys_cgetc>
  801907:	85 c0                	test   %eax,%eax
  801909:	74 f2                	je     8018fd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 16                	js     801925 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80190f:	83 f8 04             	cmp    $0x4,%eax
  801912:	74 0c                	je     801920 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801914:	8b 55 0c             	mov    0xc(%ebp),%edx
  801917:	88 02                	mov    %al,(%edx)
	return 1;
  801919:	b8 01 00 00 00       	mov    $0x1,%eax
  80191e:	eb 05                	jmp    801925 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801933:	6a 01                	push   $0x1
  801935:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801938:	50                   	push   %eax
  801939:	e8 26 f1 ff ff       	call   800a64 <sys_cputs>
}
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <getchar>:

int
getchar(void)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801949:	6a 01                	push   $0x1
  80194b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80194e:	50                   	push   %eax
  80194f:	6a 00                	push   $0x0
  801951:	e8 97 f6 ff ff       	call   800fed <read>
	if (r < 0)
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 0f                	js     80196c <getchar+0x29>
		return r;
	if (r < 1)
  80195d:	85 c0                	test   %eax,%eax
  80195f:	7e 06                	jle    801967 <getchar+0x24>
		return -E_EOF;
	return c;
  801961:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801965:	eb 05                	jmp    80196c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801967:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80196c:	c9                   	leave  
  80196d:	c3                   	ret    

0080196e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801974:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801977:	50                   	push   %eax
  801978:	ff 75 08             	pushl  0x8(%ebp)
  80197b:	e8 07 f4 ff ff       	call   800d87 <fd_lookup>
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	85 c0                	test   %eax,%eax
  801985:	78 11                	js     801998 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801987:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801990:	39 10                	cmp    %edx,(%eax)
  801992:	0f 94 c0             	sete   %al
  801995:	0f b6 c0             	movzbl %al,%eax
}
  801998:	c9                   	leave  
  801999:	c3                   	ret    

0080199a <opencons>:

int
opencons(void)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a3:	50                   	push   %eax
  8019a4:	e8 8f f3 ff ff       	call   800d38 <fd_alloc>
  8019a9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ac:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 3e                	js     8019f0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019b2:	83 ec 04             	sub    $0x4,%esp
  8019b5:	68 07 04 00 00       	push   $0x407
  8019ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bd:	6a 00                	push   $0x0
  8019bf:	e8 5c f1 ff ff       	call   800b20 <sys_page_alloc>
  8019c4:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 23                	js     8019f0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8019cd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019db:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	50                   	push   %eax
  8019e6:	e8 26 f3 ff ff       	call   800d11 <fd2num>
  8019eb:	89 c2                	mov    %eax,%edx
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	89 d0                	mov    %edx,%eax
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	56                   	push   %esi
  8019f8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019f9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019fc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a02:	e8 db f0 ff ff       	call   800ae2 <sys_getenvid>
  801a07:	83 ec 0c             	sub    $0xc,%esp
  801a0a:	ff 75 0c             	pushl  0xc(%ebp)
  801a0d:	ff 75 08             	pushl  0x8(%ebp)
  801a10:	56                   	push   %esi
  801a11:	50                   	push   %eax
  801a12:	68 38 22 80 00       	push   $0x802238
  801a17:	e8 32 e7 ff ff       	call   80014e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a1c:	83 c4 18             	add    $0x18,%esp
  801a1f:	53                   	push   %ebx
  801a20:	ff 75 10             	pushl  0x10(%ebp)
  801a23:	e8 d5 e6 ff ff       	call   8000fd <vcprintf>
	cprintf("\n");
  801a28:	c7 04 24 1e 1e 80 00 	movl   $0x801e1e,(%esp)
  801a2f:	e8 1a e7 ff ff       	call   80014e <cprintf>
  801a34:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a37:	cc                   	int3   
  801a38:	eb fd                	jmp    801a37 <_panic+0x43>

00801a3a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	56                   	push   %esi
  801a3e:	53                   	push   %ebx
  801a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a42:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	ff 75 0c             	pushl  0xc(%ebp)
  801a4b:	e8 80 f2 ff ff       	call   800cd0 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 f6                	test   %esi,%esi
  801a55:	74 1c                	je     801a73 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a57:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5c:	8b 40 78             	mov    0x78(%eax),%eax
  801a5f:	89 06                	mov    %eax,(%esi)
  801a61:	eb 10                	jmp    801a73 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a63:	83 ec 0c             	sub    $0xc,%esp
  801a66:	68 5c 22 80 00       	push   $0x80225c
  801a6b:	e8 de e6 ff ff       	call   80014e <cprintf>
  801a70:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a73:	a1 04 40 80 00       	mov    0x804004,%eax
  801a78:	8b 50 74             	mov    0x74(%eax),%edx
  801a7b:	85 d2                	test   %edx,%edx
  801a7d:	74 e4                	je     801a63 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a7f:	85 db                	test   %ebx,%ebx
  801a81:	74 05                	je     801a88 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a83:	8b 40 74             	mov    0x74(%eax),%eax
  801a86:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a88:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8d:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801aa9:	85 db                	test   %ebx,%ebx
  801aab:	75 13                	jne    801ac0 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801aad:	6a 00                	push   $0x0
  801aaf:	68 00 00 c0 ee       	push   $0xeec00000
  801ab4:	56                   	push   %esi
  801ab5:	57                   	push   %edi
  801ab6:	e8 f2 f1 ff ff       	call   800cad <sys_ipc_try_send>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	eb 0e                	jmp    801ace <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ac0:	ff 75 14             	pushl  0x14(%ebp)
  801ac3:	53                   	push   %ebx
  801ac4:	56                   	push   %esi
  801ac5:	57                   	push   %edi
  801ac6:	e8 e2 f1 ff ff       	call   800cad <sys_ipc_try_send>
  801acb:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	75 d7                	jne    801aa9 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad5:	5b                   	pop    %ebx
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ae5:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ae8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aee:	8b 52 50             	mov    0x50(%edx),%edx
  801af1:	39 ca                	cmp    %ecx,%edx
  801af3:	75 0d                	jne    801b02 <ipc_find_env+0x28>
			return envs[i].env_id;
  801af5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801afd:	8b 40 48             	mov    0x48(%eax),%eax
  801b00:	eb 0f                	jmp    801b11 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b02:	83 c0 01             	add    $0x1,%eax
  801b05:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b0a:	75 d9                	jne    801ae5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b19:	89 d0                	mov    %edx,%eax
  801b1b:	c1 e8 16             	shr    $0x16,%eax
  801b1e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2a:	f6 c1 01             	test   $0x1,%cl
  801b2d:	74 1d                	je     801b4c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b2f:	c1 ea 0c             	shr    $0xc,%edx
  801b32:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b39:	f6 c2 01             	test   $0x1,%dl
  801b3c:	74 0e                	je     801b4c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b3e:	c1 ea 0c             	shr    $0xc,%edx
  801b41:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b48:	ef 
  801b49:	0f b7 c0             	movzwl %ax,%eax
}
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    
  801b4e:	66 90                	xchg   %ax,%ax

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
