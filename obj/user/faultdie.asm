
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
  800045:	68 c0 10 80 00       	push   $0x8010c0
  80004a:	e8 28 01 00 00       	call   800177 <cprintf>
	cprintf("here I add some commit.\n");
  80004f:	c7 04 24 dc 10 80 00 	movl   $0x8010dc,(%esp)
  800056:	e8 1c 01 00 00       	call   800177 <cprintf>
	sys_env_destroy(sys_getenvid());
  80005b:	e8 ab 0a 00 00       	call   800b0b <sys_getenvid>
  800060:	89 04 24             	mov    %eax,(%esp)
  800063:	e8 62 0a 00 00       	call   800aca <sys_env_destroy>
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
  800078:	e8 7b 0c 00 00       	call   800cf8 <set_pgfault_handler>
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
  800097:	e8 6f 0a 00 00       	call   800b0b <sys_getenvid>
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a9:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	85 db                	test   %ebx,%ebx
  8000b0:	7e 07                	jle    8000b9 <libmain+0x2d>
		binaryname = argv[0];
  8000b2:	8b 06                	mov    (%esi),%eax
  8000b4:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000d5:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 eb 09 00 00       	call   800aca <sys_env_destroy>
}
  8000df:	83 c4 10             	add    $0x10,%esp
  8000e2:	c9                   	leave  
  8000e3:	c3                   	ret    

008000e4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 04             	sub    $0x4,%esp
  8000eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ee:	8b 13                	mov    (%ebx),%edx
  8000f0:	8d 42 01             	lea    0x1(%edx),%eax
  8000f3:	89 03                	mov    %eax,(%ebx)
  8000f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000fc:	3d ff 00 00 00       	cmp    $0xff,%eax
  800101:	75 1a                	jne    80011d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800103:	83 ec 08             	sub    $0x8,%esp
  800106:	68 ff 00 00 00       	push   $0xff
  80010b:	8d 43 08             	lea    0x8(%ebx),%eax
  80010e:	50                   	push   %eax
  80010f:	e8 79 09 00 00       	call   800a8d <sys_cputs>
		b->idx = 0;
  800114:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80011a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80011d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800124:	c9                   	leave  
  800125:	c3                   	ret    

00800126 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80012f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800136:	00 00 00 
	b.cnt = 0;
  800139:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800140:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	50                   	push   %eax
  800150:	68 e4 00 80 00       	push   $0x8000e4
  800155:	e8 54 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015a:	83 c4 08             	add    $0x8,%esp
  80015d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800163:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	e8 1e 09 00 00       	call   800a8d <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800180:	50                   	push   %eax
  800181:	ff 75 08             	pushl  0x8(%ebp)
  800184:	e8 9d ff ff ff       	call   800126 <vcprintf>
	va_end(ap);

	return cnt;
}
  800189:	c9                   	leave  
  80018a:	c3                   	ret    

0080018b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 1c             	sub    $0x1c,%esp
  800194:	89 c7                	mov    %eax,%edi
  800196:	89 d6                	mov    %edx,%esi
  800198:	8b 45 08             	mov    0x8(%ebp),%eax
  80019b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ac:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001af:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001b2:	39 d3                	cmp    %edx,%ebx
  8001b4:	72 05                	jb     8001bb <printnum+0x30>
  8001b6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b9:	77 45                	ja     800200 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 18             	pushl  0x18(%ebp)
  8001c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c7:	53                   	push   %ebx
  8001c8:	ff 75 10             	pushl  0x10(%ebp)
  8001cb:	83 ec 08             	sub    $0x8,%esp
  8001ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001da:	e8 51 0c 00 00       	call   800e30 <__udivdi3>
  8001df:	83 c4 18             	add    $0x18,%esp
  8001e2:	52                   	push   %edx
  8001e3:	50                   	push   %eax
  8001e4:	89 f2                	mov    %esi,%edx
  8001e6:	89 f8                	mov    %edi,%eax
  8001e8:	e8 9e ff ff ff       	call   80018b <printnum>
  8001ed:	83 c4 20             	add    $0x20,%esp
  8001f0:	eb 18                	jmp    80020a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	ff 75 18             	pushl  0x18(%ebp)
  8001f9:	ff d7                	call   *%edi
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	eb 03                	jmp    800203 <printnum+0x78>
  800200:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800203:	83 eb 01             	sub    $0x1,%ebx
  800206:	85 db                	test   %ebx,%ebx
  800208:	7f e8                	jg     8001f2 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	56                   	push   %esi
  80020e:	83 ec 04             	sub    $0x4,%esp
  800211:	ff 75 e4             	pushl  -0x1c(%ebp)
  800214:	ff 75 e0             	pushl  -0x20(%ebp)
  800217:	ff 75 dc             	pushl  -0x24(%ebp)
  80021a:	ff 75 d8             	pushl  -0x28(%ebp)
  80021d:	e8 3e 0d 00 00       	call   800f60 <__umoddi3>
  800222:	83 c4 14             	add    $0x14,%esp
  800225:	0f be 80 ff 10 80 00 	movsbl 0x8010ff(%eax),%eax
  80022c:	50                   	push   %eax
  80022d:	ff d7                	call   *%edi
}
  80022f:	83 c4 10             	add    $0x10,%esp
  800232:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800235:	5b                   	pop    %ebx
  800236:	5e                   	pop    %esi
  800237:	5f                   	pop    %edi
  800238:	5d                   	pop    %ebp
  800239:	c3                   	ret    

0080023a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80023d:	83 fa 01             	cmp    $0x1,%edx
  800240:	7e 0e                	jle    800250 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800242:	8b 10                	mov    (%eax),%edx
  800244:	8d 4a 08             	lea    0x8(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 02                	mov    (%edx),%eax
  80024b:	8b 52 04             	mov    0x4(%edx),%edx
  80024e:	eb 22                	jmp    800272 <getuint+0x38>
	else if (lflag)
  800250:	85 d2                	test   %edx,%edx
  800252:	74 10                	je     800264 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800254:	8b 10                	mov    (%eax),%edx
  800256:	8d 4a 04             	lea    0x4(%edx),%ecx
  800259:	89 08                	mov    %ecx,(%eax)
  80025b:	8b 02                	mov    (%edx),%eax
  80025d:	ba 00 00 00 00       	mov    $0x0,%edx
  800262:	eb 0e                	jmp    800272 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800264:	8b 10                	mov    (%eax),%edx
  800266:	8d 4a 04             	lea    0x4(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 02                	mov    (%edx),%eax
  80026d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1b>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	eb 12                	jmp    8002d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 84 d3 03 00 00    	je     80069d <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	ff d6                	call   *%esi
  8002d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d4:	83 c7 01             	add    $0x1,%edi
  8002d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002db:	83 f8 25             	cmp    $0x25,%eax
  8002de:	75 e2                	jne    8002c2 <vprintfmt+0x14>
  8002e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002eb:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fe:	eb 07                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 07             	movzbl (%edi),%eax
  800310:	0f b6 c8             	movzbl %al,%ecx
  800313:	83 e8 23             	sub    $0x23,%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 64 03 00 00    	ja     800682 <vprintfmt+0x3d4>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032f:	eb d6                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800346:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800349:	83 fa 09             	cmp    $0x9,%edx
  80034c:	77 39                	ja     800387 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800351:	eb e9                	jmp    80033c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8d 48 04             	lea    0x4(%eax),%ecx
  800359:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80035c:	8b 00                	mov    (%eax),%eax
  80035e:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800364:	eb 27                	jmp    80038d <vprintfmt+0xdf>
  800366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800369:	85 c0                	test   %eax,%eax
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800370:	0f 49 c8             	cmovns %eax,%ecx
  800373:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800379:	eb 8c                	jmp    800307 <vprintfmt+0x59>
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80037e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800385:	eb 80                	jmp    800307 <vprintfmt+0x59>
  800387:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80038a:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80038d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800391:	0f 89 70 ff ff ff    	jns    800307 <vprintfmt+0x59>
				width = precision, precision = -1;
  800397:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80039a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003a4:	e9 5e ff ff ff       	jmp    800307 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003af:	e9 53 ff ff ff       	jmp    800307 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bd:	83 ec 08             	sub    $0x8,%esp
  8003c0:	53                   	push   %ebx
  8003c1:	ff 30                	pushl  (%eax)
  8003c3:	ff d6                	call   *%esi
			break;
  8003c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003cb:	e9 04 ff ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 50 04             	lea    0x4(%eax),%edx
  8003d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	99                   	cltd   
  8003dc:	31 d0                	xor    %edx,%eax
  8003de:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e0:	83 f8 08             	cmp    $0x8,%eax
  8003e3:	7f 0b                	jg     8003f0 <vprintfmt+0x142>
  8003e5:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	75 18                	jne    800408 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003f0:	50                   	push   %eax
  8003f1:	68 17 11 80 00       	push   $0x801117
  8003f6:	53                   	push   %ebx
  8003f7:	56                   	push   %esi
  8003f8:	e8 94 fe ff ff       	call   800291 <printfmt>
  8003fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800403:	e9 cc fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800408:	52                   	push   %edx
  800409:	68 20 11 80 00       	push   $0x801120
  80040e:	53                   	push   %ebx
  80040f:	56                   	push   %esi
  800410:	e8 7c fe ff ff       	call   800291 <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	e9 b4 fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042b:	85 ff                	test   %edi,%edi
  80042d:	b8 10 11 80 00       	mov    $0x801110,%eax
  800432:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800435:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800439:	0f 8e 94 00 00 00    	jle    8004d3 <vprintfmt+0x225>
  80043f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800443:	0f 84 98 00 00 00    	je     8004e1 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	ff 75 c8             	pushl  -0x38(%ebp)
  80044f:	57                   	push   %edi
  800450:	e8 d0 02 00 00       	call   800725 <strnlen>
  800455:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800458:	29 c1                	sub    %eax,%ecx
  80045a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80045d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800460:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800467:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046c:	eb 0f                	jmp    80047d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	53                   	push   %ebx
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	83 ef 01             	sub    $0x1,%edi
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	85 ff                	test   %edi,%edi
  80047f:	7f ed                	jg     80046e <vprintfmt+0x1c0>
  800481:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800484:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800487:	85 c9                	test   %ecx,%ecx
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	0f 49 c1             	cmovns %ecx,%eax
  800491:	29 c1                	sub    %eax,%ecx
  800493:	89 75 08             	mov    %esi,0x8(%ebp)
  800496:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049c:	89 cb                	mov    %ecx,%ebx
  80049e:	eb 4d                	jmp    8004ed <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a4:	74 1b                	je     8004c1 <vprintfmt+0x213>
  8004a6:	0f be c0             	movsbl %al,%eax
  8004a9:	83 e8 20             	sub    $0x20,%eax
  8004ac:	83 f8 5e             	cmp    $0x5e,%eax
  8004af:	76 10                	jbe    8004c1 <vprintfmt+0x213>
					putch('?', putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	ff 75 0c             	pushl  0xc(%ebp)
  8004b7:	6a 3f                	push   $0x3f
  8004b9:	ff 55 08             	call   *0x8(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	eb 0d                	jmp    8004ce <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	52                   	push   %edx
  8004c8:	ff 55 08             	call   *0x8(%ebp)
  8004cb:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ce:	83 eb 01             	sub    $0x1,%ebx
  8004d1:	eb 1a                	jmp    8004ed <vprintfmt+0x23f>
  8004d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d6:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004df:	eb 0c                	jmp    8004ed <vprintfmt+0x23f>
  8004e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e4:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f4:	0f be d0             	movsbl %al,%edx
  8004f7:	85 d2                	test   %edx,%edx
  8004f9:	74 23                	je     80051e <vprintfmt+0x270>
  8004fb:	85 f6                	test   %esi,%esi
  8004fd:	78 a1                	js     8004a0 <vprintfmt+0x1f2>
  8004ff:	83 ee 01             	sub    $0x1,%esi
  800502:	79 9c                	jns    8004a0 <vprintfmt+0x1f2>
  800504:	89 df                	mov    %ebx,%edi
  800506:	8b 75 08             	mov    0x8(%ebp),%esi
  800509:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050c:	eb 18                	jmp    800526 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	6a 20                	push   $0x20
  800514:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800516:	83 ef 01             	sub    $0x1,%edi
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	eb 08                	jmp    800526 <vprintfmt+0x278>
  80051e:	89 df                	mov    %ebx,%edi
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800526:	85 ff                	test   %edi,%edi
  800528:	7f e4                	jg     80050e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80052d:	e9 a2 fd ff ff       	jmp    8002d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800532:	83 fa 01             	cmp    $0x1,%edx
  800535:	7e 16                	jle    80054d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 08             	lea    0x8(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 50 04             	mov    0x4(%eax),%edx
  800543:	8b 00                	mov    (%eax),%eax
  800545:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800548:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80054b:	eb 32                	jmp    80057f <vprintfmt+0x2d1>
	else if (lflag)
  80054d:	85 d2                	test   %edx,%edx
  80054f:	74 18                	je     800569 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80055f:	89 c1                	mov    %eax,%ecx
  800561:	c1 f9 1f             	sar    $0x1f,%ecx
  800564:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800567:	eb 16                	jmp    80057f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 04             	lea    0x4(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800577:	89 c1                	mov    %eax,%ecx
  800579:	c1 f9 1f             	sar    $0x1f,%ecx
  80057c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800582:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800585:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800588:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80058b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800590:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800594:	0f 89 b0 00 00 00    	jns    80064a <vprintfmt+0x39c>
				putch('-', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 2d                	push   $0x2d
  8005a0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005a5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005a8:	f7 d8                	neg    %eax
  8005aa:	83 d2 00             	adc    $0x0,%edx
  8005ad:	f7 da                	neg    %edx
  8005af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bd:	e9 88 00 00 00       	jmp    80064a <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c5:	e8 70 fc ff ff       	call   80023a <getuint>
  8005ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005d0:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005d5:	eb 73                	jmp    80064a <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005da:	e8 5b fc ff ff       	call   80023a <getuint>
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 58                	push   $0x58
  8005eb:	ff d6                	call   *%esi
			putch('X', putdat);
  8005ed:	83 c4 08             	add    $0x8,%esp
  8005f0:	53                   	push   %ebx
  8005f1:	6a 58                	push   $0x58
  8005f3:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f5:	83 c4 08             	add    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 58                	push   $0x58
  8005fb:	ff d6                	call   *%esi
			goto number;
  8005fd:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800600:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800605:	eb 43                	jmp    80064a <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 30                	push   $0x30
  80060d:	ff d6                	call   *%esi
			putch('x', putdat);
  80060f:	83 c4 08             	add    $0x8,%esp
  800612:	53                   	push   %ebx
  800613:	6a 78                	push   $0x78
  800615:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	ba 00 00 00 00       	mov    $0x0,%edx
  800627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800630:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800635:	eb 13                	jmp    80064a <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800637:	8d 45 14             	lea    0x14(%ebp),%eax
  80063a:	e8 fb fb ff ff       	call   80023a <getuint>
  80063f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800642:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800645:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064a:	83 ec 0c             	sub    $0xc,%esp
  80064d:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800651:	52                   	push   %edx
  800652:	ff 75 e0             	pushl  -0x20(%ebp)
  800655:	50                   	push   %eax
  800656:	ff 75 dc             	pushl  -0x24(%ebp)
  800659:	ff 75 d8             	pushl  -0x28(%ebp)
  80065c:	89 da                	mov    %ebx,%edx
  80065e:	89 f0                	mov    %esi,%eax
  800660:	e8 26 fb ff ff       	call   80018b <printnum>
			break;
  800665:	83 c4 20             	add    $0x20,%esp
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066b:	e9 64 fc ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800670:	83 ec 08             	sub    $0x8,%esp
  800673:	53                   	push   %ebx
  800674:	51                   	push   %ecx
  800675:	ff d6                	call   *%esi
			break;
  800677:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067d:	e9 52 fc ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	6a 25                	push   $0x25
  800688:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	eb 03                	jmp    800692 <vprintfmt+0x3e4>
  80068f:	83 ef 01             	sub    $0x1,%edi
  800692:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800696:	75 f7                	jne    80068f <vprintfmt+0x3e1>
  800698:	e9 37 fc ff ff       	jmp    8002d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80069d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a0:	5b                   	pop    %ebx
  8006a1:	5e                   	pop    %esi
  8006a2:	5f                   	pop    %edi
  8006a3:	5d                   	pop    %ebp
  8006a4:	c3                   	ret    

008006a5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	83 ec 18             	sub    $0x18,%esp
  8006ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ae:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006bb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c2:	85 c0                	test   %eax,%eax
  8006c4:	74 26                	je     8006ec <vsnprintf+0x47>
  8006c6:	85 d2                	test   %edx,%edx
  8006c8:	7e 22                	jle    8006ec <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ca:	ff 75 14             	pushl  0x14(%ebp)
  8006cd:	ff 75 10             	pushl  0x10(%ebp)
  8006d0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d3:	50                   	push   %eax
  8006d4:	68 74 02 80 00       	push   $0x800274
  8006d9:	e8 d0 fb ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	eb 05                	jmp    8006f1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fc:	50                   	push   %eax
  8006fd:	ff 75 10             	pushl  0x10(%ebp)
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	ff 75 08             	pushl  0x8(%ebp)
  800706:	e8 9a ff ff ff       	call   8006a5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070b:	c9                   	leave  
  80070c:	c3                   	ret    

0080070d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800713:	b8 00 00 00 00       	mov    $0x0,%eax
  800718:	eb 03                	jmp    80071d <strlen+0x10>
		n++;
  80071a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800721:	75 f7                	jne    80071a <strlen+0xd>
		n++;
	return n;
}
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072e:	ba 00 00 00 00       	mov    $0x0,%edx
  800733:	eb 03                	jmp    800738 <strnlen+0x13>
		n++;
  800735:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800738:	39 c2                	cmp    %eax,%edx
  80073a:	74 08                	je     800744 <strnlen+0x1f>
  80073c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800740:	75 f3                	jne    800735 <strnlen+0x10>
  800742:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	53                   	push   %ebx
  80074a:	8b 45 08             	mov    0x8(%ebp),%eax
  80074d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800750:	89 c2                	mov    %eax,%edx
  800752:	83 c2 01             	add    $0x1,%edx
  800755:	83 c1 01             	add    $0x1,%ecx
  800758:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075f:	84 db                	test   %bl,%bl
  800761:	75 ef                	jne    800752 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800763:	5b                   	pop    %ebx
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	53                   	push   %ebx
  80076a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076d:	53                   	push   %ebx
  80076e:	e8 9a ff ff ff       	call   80070d <strlen>
  800773:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800776:	ff 75 0c             	pushl  0xc(%ebp)
  800779:	01 d8                	add    %ebx,%eax
  80077b:	50                   	push   %eax
  80077c:	e8 c5 ff ff ff       	call   800746 <strcpy>
	return dst;
}
  800781:	89 d8                	mov    %ebx,%eax
  800783:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	56                   	push   %esi
  80078c:	53                   	push   %ebx
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800793:	89 f3                	mov    %esi,%ebx
  800795:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800798:	89 f2                	mov    %esi,%edx
  80079a:	eb 0f                	jmp    8007ab <strncpy+0x23>
		*dst++ = *src;
  80079c:	83 c2 01             	add    $0x1,%edx
  80079f:	0f b6 01             	movzbl (%ecx),%eax
  8007a2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a5:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ab:	39 da                	cmp    %ebx,%edx
  8007ad:	75 ed                	jne    80079c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007af:	89 f0                	mov    %esi,%eax
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	56                   	push   %esi
  8007b9:	53                   	push   %ebx
  8007ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c0:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c5:	85 d2                	test   %edx,%edx
  8007c7:	74 21                	je     8007ea <strlcpy+0x35>
  8007c9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cd:	89 f2                	mov    %esi,%edx
  8007cf:	eb 09                	jmp    8007da <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d1:	83 c2 01             	add    $0x1,%edx
  8007d4:	83 c1 01             	add    $0x1,%ecx
  8007d7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007da:	39 c2                	cmp    %eax,%edx
  8007dc:	74 09                	je     8007e7 <strlcpy+0x32>
  8007de:	0f b6 19             	movzbl (%ecx),%ebx
  8007e1:	84 db                	test   %bl,%bl
  8007e3:	75 ec                	jne    8007d1 <strlcpy+0x1c>
  8007e5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ea:	29 f0                	sub    %esi,%eax
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f9:	eb 06                	jmp    800801 <strcmp+0x11>
		p++, q++;
  8007fb:	83 c1 01             	add    $0x1,%ecx
  8007fe:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800801:	0f b6 01             	movzbl (%ecx),%eax
  800804:	84 c0                	test   %al,%al
  800806:	74 04                	je     80080c <strcmp+0x1c>
  800808:	3a 02                	cmp    (%edx),%al
  80080a:	74 ef                	je     8007fb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080c:	0f b6 c0             	movzbl %al,%eax
  80080f:	0f b6 12             	movzbl (%edx),%edx
  800812:	29 d0                	sub    %edx,%eax
}
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800820:	89 c3                	mov    %eax,%ebx
  800822:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800825:	eb 06                	jmp    80082d <strncmp+0x17>
		n--, p++, q++;
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082d:	39 d8                	cmp    %ebx,%eax
  80082f:	74 15                	je     800846 <strncmp+0x30>
  800831:	0f b6 08             	movzbl (%eax),%ecx
  800834:	84 c9                	test   %cl,%cl
  800836:	74 04                	je     80083c <strncmp+0x26>
  800838:	3a 0a                	cmp    (%edx),%cl
  80083a:	74 eb                	je     800827 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083c:	0f b6 00             	movzbl (%eax),%eax
  80083f:	0f b6 12             	movzbl (%edx),%edx
  800842:	29 d0                	sub    %edx,%eax
  800844:	eb 05                	jmp    80084b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800858:	eb 07                	jmp    800861 <strchr+0x13>
		if (*s == c)
  80085a:	38 ca                	cmp    %cl,%dl
  80085c:	74 0f                	je     80086d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	0f b6 10             	movzbl (%eax),%edx
  800864:	84 d2                	test   %dl,%dl
  800866:	75 f2                	jne    80085a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800868:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 45 08             	mov    0x8(%ebp),%eax
  800875:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800879:	eb 03                	jmp    80087e <strfind+0xf>
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800881:	38 ca                	cmp    %cl,%dl
  800883:	74 04                	je     800889 <strfind+0x1a>
  800885:	84 d2                	test   %dl,%dl
  800887:	75 f2                	jne    80087b <strfind+0xc>
			break;
	return (char *) s;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	57                   	push   %edi
  80088f:	56                   	push   %esi
  800890:	53                   	push   %ebx
  800891:	8b 7d 08             	mov    0x8(%ebp),%edi
  800894:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800897:	85 c9                	test   %ecx,%ecx
  800899:	74 36                	je     8008d1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a1:	75 28                	jne    8008cb <memset+0x40>
  8008a3:	f6 c1 03             	test   $0x3,%cl
  8008a6:	75 23                	jne    8008cb <memset+0x40>
		c &= 0xFF;
  8008a8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ac:	89 d3                	mov    %edx,%ebx
  8008ae:	c1 e3 08             	shl    $0x8,%ebx
  8008b1:	89 d6                	mov    %edx,%esi
  8008b3:	c1 e6 18             	shl    $0x18,%esi
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	c1 e0 10             	shl    $0x10,%eax
  8008bb:	09 f0                	or     %esi,%eax
  8008bd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008bf:	89 d8                	mov    %ebx,%eax
  8008c1:	09 d0                	or     %edx,%eax
  8008c3:	c1 e9 02             	shr    $0x2,%ecx
  8008c6:	fc                   	cld    
  8008c7:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c9:	eb 06                	jmp    8008d1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ce:	fc                   	cld    
  8008cf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d1:	89 f8                	mov    %edi,%eax
  8008d3:	5b                   	pop    %ebx
  8008d4:	5e                   	pop    %esi
  8008d5:	5f                   	pop    %edi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	57                   	push   %edi
  8008dc:	56                   	push   %esi
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e6:	39 c6                	cmp    %eax,%esi
  8008e8:	73 35                	jae    80091f <memmove+0x47>
  8008ea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ed:	39 d0                	cmp    %edx,%eax
  8008ef:	73 2e                	jae    80091f <memmove+0x47>
		s += n;
		d += n;
  8008f1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f4:	89 d6                	mov    %edx,%esi
  8008f6:	09 fe                	or     %edi,%esi
  8008f8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fe:	75 13                	jne    800913 <memmove+0x3b>
  800900:	f6 c1 03             	test   $0x3,%cl
  800903:	75 0e                	jne    800913 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800905:	83 ef 04             	sub    $0x4,%edi
  800908:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090b:	c1 e9 02             	shr    $0x2,%ecx
  80090e:	fd                   	std    
  80090f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800911:	eb 09                	jmp    80091c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800913:	83 ef 01             	sub    $0x1,%edi
  800916:	8d 72 ff             	lea    -0x1(%edx),%esi
  800919:	fd                   	std    
  80091a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091c:	fc                   	cld    
  80091d:	eb 1d                	jmp    80093c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091f:	89 f2                	mov    %esi,%edx
  800921:	09 c2                	or     %eax,%edx
  800923:	f6 c2 03             	test   $0x3,%dl
  800926:	75 0f                	jne    800937 <memmove+0x5f>
  800928:	f6 c1 03             	test   $0x3,%cl
  80092b:	75 0a                	jne    800937 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092d:	c1 e9 02             	shr    $0x2,%ecx
  800930:	89 c7                	mov    %eax,%edi
  800932:	fc                   	cld    
  800933:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800935:	eb 05                	jmp    80093c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800937:	89 c7                	mov    %eax,%edi
  800939:	fc                   	cld    
  80093a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093c:	5e                   	pop    %esi
  80093d:	5f                   	pop    %edi
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800943:	ff 75 10             	pushl  0x10(%ebp)
  800946:	ff 75 0c             	pushl  0xc(%ebp)
  800949:	ff 75 08             	pushl  0x8(%ebp)
  80094c:	e8 87 ff ff ff       	call   8008d8 <memmove>
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095e:	89 c6                	mov    %eax,%esi
  800960:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800963:	eb 1a                	jmp    80097f <memcmp+0x2c>
		if (*s1 != *s2)
  800965:	0f b6 08             	movzbl (%eax),%ecx
  800968:	0f b6 1a             	movzbl (%edx),%ebx
  80096b:	38 d9                	cmp    %bl,%cl
  80096d:	74 0a                	je     800979 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096f:	0f b6 c1             	movzbl %cl,%eax
  800972:	0f b6 db             	movzbl %bl,%ebx
  800975:	29 d8                	sub    %ebx,%eax
  800977:	eb 0f                	jmp    800988 <memcmp+0x35>
		s1++, s2++;
  800979:	83 c0 01             	add    $0x1,%eax
  80097c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097f:	39 f0                	cmp    %esi,%eax
  800981:	75 e2                	jne    800965 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	53                   	push   %ebx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800993:	89 c1                	mov    %eax,%ecx
  800995:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800998:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099c:	eb 0a                	jmp    8009a8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099e:	0f b6 10             	movzbl (%eax),%edx
  8009a1:	39 da                	cmp    %ebx,%edx
  8009a3:	74 07                	je     8009ac <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a5:	83 c0 01             	add    $0x1,%eax
  8009a8:	39 c8                	cmp    %ecx,%eax
  8009aa:	72 f2                	jb     80099e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	57                   	push   %edi
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bb:	eb 03                	jmp    8009c0 <strtol+0x11>
		s++;
  8009bd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c0:	0f b6 01             	movzbl (%ecx),%eax
  8009c3:	3c 20                	cmp    $0x20,%al
  8009c5:	74 f6                	je     8009bd <strtol+0xe>
  8009c7:	3c 09                	cmp    $0x9,%al
  8009c9:	74 f2                	je     8009bd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009cb:	3c 2b                	cmp    $0x2b,%al
  8009cd:	75 0a                	jne    8009d9 <strtol+0x2a>
		s++;
  8009cf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d2:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d7:	eb 11                	jmp    8009ea <strtol+0x3b>
  8009d9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009de:	3c 2d                	cmp    $0x2d,%al
  8009e0:	75 08                	jne    8009ea <strtol+0x3b>
		s++, neg = 1;
  8009e2:	83 c1 01             	add    $0x1,%ecx
  8009e5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f0:	75 15                	jne    800a07 <strtol+0x58>
  8009f2:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f5:	75 10                	jne    800a07 <strtol+0x58>
  8009f7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fb:	75 7c                	jne    800a79 <strtol+0xca>
		s += 2, base = 16;
  8009fd:	83 c1 02             	add    $0x2,%ecx
  800a00:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a05:	eb 16                	jmp    800a1d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a07:	85 db                	test   %ebx,%ebx
  800a09:	75 12                	jne    800a1d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a10:	80 39 30             	cmpb   $0x30,(%ecx)
  800a13:	75 08                	jne    800a1d <strtol+0x6e>
		s++, base = 8;
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a25:	0f b6 11             	movzbl (%ecx),%edx
  800a28:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2b:	89 f3                	mov    %esi,%ebx
  800a2d:	80 fb 09             	cmp    $0x9,%bl
  800a30:	77 08                	ja     800a3a <strtol+0x8b>
			dig = *s - '0';
  800a32:	0f be d2             	movsbl %dl,%edx
  800a35:	83 ea 30             	sub    $0x30,%edx
  800a38:	eb 22                	jmp    800a5c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a3a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3d:	89 f3                	mov    %esi,%ebx
  800a3f:	80 fb 19             	cmp    $0x19,%bl
  800a42:	77 08                	ja     800a4c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a44:	0f be d2             	movsbl %dl,%edx
  800a47:	83 ea 57             	sub    $0x57,%edx
  800a4a:	eb 10                	jmp    800a5c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4f:	89 f3                	mov    %esi,%ebx
  800a51:	80 fb 19             	cmp    $0x19,%bl
  800a54:	77 16                	ja     800a6c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a56:	0f be d2             	movsbl %dl,%edx
  800a59:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5f:	7d 0b                	jge    800a6c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a61:	83 c1 01             	add    $0x1,%ecx
  800a64:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a68:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a6a:	eb b9                	jmp    800a25 <strtol+0x76>

	if (endptr)
  800a6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a70:	74 0d                	je     800a7f <strtol+0xd0>
		*endptr = (char *) s;
  800a72:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a75:	89 0e                	mov    %ecx,(%esi)
  800a77:	eb 06                	jmp    800a7f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	74 98                	je     800a15 <strtol+0x66>
  800a7d:	eb 9e                	jmp    800a1d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7f:	89 c2                	mov    %eax,%edx
  800a81:	f7 da                	neg    %edx
  800a83:	85 ff                	test   %edi,%edi
  800a85:	0f 45 c2             	cmovne %edx,%eax
}
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
  800a98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9e:	89 c3                	mov    %eax,%ebx
  800aa0:	89 c7                	mov    %eax,%edi
  800aa2:	89 c6                	mov    %eax,%esi
  800aa4:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <sys_cgetc>:

int
sys_cgetc(void)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ab1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab6:	b8 01 00 00 00       	mov    $0x1,%eax
  800abb:	89 d1                	mov    %edx,%ecx
  800abd:	89 d3                	mov    %edx,%ebx
  800abf:	89 d7                	mov    %edx,%edi
  800ac1:	89 d6                	mov    %edx,%esi
  800ac3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ad3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad8:	b8 03 00 00 00       	mov    $0x3,%eax
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	89 cb                	mov    %ecx,%ebx
  800ae2:	89 cf                	mov    %ecx,%edi
  800ae4:	89 ce                	mov    %ecx,%esi
  800ae6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ae8:	85 c0                	test   %eax,%eax
  800aea:	7e 17                	jle    800b03 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aec:	83 ec 0c             	sub    $0xc,%esp
  800aef:	50                   	push   %eax
  800af0:	6a 03                	push   $0x3
  800af2:	68 44 13 80 00       	push   $0x801344
  800af7:	6a 23                	push   $0x23
  800af9:	68 61 13 80 00       	push   $0x801361
  800afe:	e8 e5 02 00 00       	call   800de8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1b:	89 d1                	mov    %edx,%ecx
  800b1d:	89 d3                	mov    %edx,%ebx
  800b1f:	89 d7                	mov    %edx,%edi
  800b21:	89 d6                	mov    %edx,%esi
  800b23:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <sys_yield>:

void
sys_yield(void)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b30:	ba 00 00 00 00       	mov    $0x0,%edx
  800b35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3a:	89 d1                	mov    %edx,%ecx
  800b3c:	89 d3                	mov    %edx,%ebx
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	53                   	push   %ebx
  800b4f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b52:	be 00 00 00 00       	mov    $0x0,%esi
  800b57:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b62:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b65:	89 f7                	mov    %esi,%edi
  800b67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	7e 17                	jle    800b84 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	50                   	push   %eax
  800b71:	6a 04                	push   $0x4
  800b73:	68 44 13 80 00       	push   $0x801344
  800b78:	6a 23                	push   $0x23
  800b7a:	68 61 13 80 00       	push   $0x801361
  800b7f:	e8 64 02 00 00       	call   800de8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	57                   	push   %edi
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b95:	b8 05 00 00 00       	mov    $0x5,%eax
  800b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba6:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bab:	85 c0                	test   %eax,%eax
  800bad:	7e 17                	jle    800bc6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	50                   	push   %eax
  800bb3:	6a 05                	push   $0x5
  800bb5:	68 44 13 80 00       	push   $0x801344
  800bba:	6a 23                	push   $0x23
  800bbc:	68 61 13 80 00       	push   $0x801361
  800bc1:	e8 22 02 00 00       	call   800de8 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdc:	b8 06 00 00 00       	mov    $0x6,%eax
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	89 df                	mov    %ebx,%edi
  800be9:	89 de                	mov    %ebx,%esi
  800beb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bed:	85 c0                	test   %eax,%eax
  800bef:	7e 17                	jle    800c08 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	50                   	push   %eax
  800bf5:	6a 06                	push   $0x6
  800bf7:	68 44 13 80 00       	push   $0x801344
  800bfc:	6a 23                	push   $0x23
  800bfe:	68 61 13 80 00       	push   $0x801361
  800c03:	e8 e0 01 00 00       	call   800de8 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 08             	mov    0x8(%ebp),%edx
  800c29:	89 df                	mov    %ebx,%edi
  800c2b:	89 de                	mov    %ebx,%esi
  800c2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	7e 17                	jle    800c4a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	50                   	push   %eax
  800c37:	6a 08                	push   $0x8
  800c39:	68 44 13 80 00       	push   $0x801344
  800c3e:	6a 23                	push   $0x23
  800c40:	68 61 13 80 00       	push   $0x801361
  800c45:	e8 9e 01 00 00       	call   800de8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    

00800c52 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	57                   	push   %edi
  800c56:	56                   	push   %esi
  800c57:	53                   	push   %ebx
  800c58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c60:	b8 09 00 00 00       	mov    $0x9,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 df                	mov    %ebx,%edi
  800c6d:	89 de                	mov    %ebx,%esi
  800c6f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c71:	85 c0                	test   %eax,%eax
  800c73:	7e 17                	jle    800c8c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c75:	83 ec 0c             	sub    $0xc,%esp
  800c78:	50                   	push   %eax
  800c79:	6a 09                	push   $0x9
  800c7b:	68 44 13 80 00       	push   $0x801344
  800c80:	6a 23                	push   $0x23
  800c82:	68 61 13 80 00       	push   $0x801361
  800c87:	e8 5c 01 00 00       	call   800de8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c9a:	be 00 00 00 00       	mov    $0x0,%esi
  800c9f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cad:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 cb                	mov    %ecx,%ebx
  800ccf:	89 cf                	mov    %ecx,%edi
  800cd1:	89 ce                	mov    %ecx,%esi
  800cd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 17                	jle    800cf0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	83 ec 0c             	sub    $0xc,%esp
  800cdc:	50                   	push   %eax
  800cdd:	6a 0c                	push   $0xc
  800cdf:	68 44 13 80 00       	push   $0x801344
  800ce4:	6a 23                	push   $0x23
  800ce6:	68 61 13 80 00       	push   $0x801361
  800ceb:	e8 f8 00 00 00       	call   800de8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  800cfe:	68 70 13 80 00       	push   $0x801370
  800d03:	e8 6f f4 ff ff       	call   800177 <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d12:	0f 85 8d 00 00 00    	jne    800da5 <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  800d18:	83 ec 0c             	sub    $0xc,%esp
  800d1b:	68 90 13 80 00       	push   $0x801390
  800d20:	e8 52 f4 ff ff       	call   800177 <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  800d25:	a1 04 20 80 00       	mov    0x802004,%eax
  800d2a:	8b 40 48             	mov    0x48(%eax),%eax
  800d2d:	83 c4 0c             	add    $0xc,%esp
  800d30:	6a 07                	push   $0x7
  800d32:	68 00 f0 bf ee       	push   $0xeebff000
  800d37:	50                   	push   %eax
  800d38:	e8 0c fe ff ff       	call   800b49 <sys_page_alloc>
		if(retv != 0){
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	85 c0                	test   %eax,%eax
  800d42:	74 14                	je     800d58 <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  800d44:	83 ec 04             	sub    $0x4,%esp
  800d47:	68 b4 13 80 00       	push   $0x8013b4
  800d4c:	6a 27                	push   $0x27
  800d4e:	68 06 14 80 00       	push   $0x801406
  800d53:	e8 90 00 00 00       	call   800de8 <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  800d58:	83 ec 08             	sub    $0x8,%esp
  800d5b:	68 bf 0d 80 00       	push   $0x800dbf
  800d60:	68 14 14 80 00       	push   $0x801414
  800d65:	e8 0d f4 ff ff       	call   800177 <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  800d6a:	a1 04 20 80 00       	mov    0x802004,%eax
  800d6f:	8b 40 48             	mov    0x48(%eax),%eax
  800d72:	83 c4 08             	add    $0x8,%esp
  800d75:	50                   	push   %eax
  800d76:	68 2f 14 80 00       	push   $0x80142f
  800d7b:	e8 f7 f3 ff ff       	call   800177 <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800d80:	a1 04 20 80 00       	mov    0x802004,%eax
  800d85:	8b 40 48             	mov    0x48(%eax),%eax
  800d88:	83 c4 08             	add    $0x8,%esp
  800d8b:	68 bf 0d 80 00       	push   $0x800dbf
  800d90:	50                   	push   %eax
  800d91:	e8 bc fe ff ff       	call   800c52 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  800d96:	c7 04 24 46 14 80 00 	movl   $0x801446,(%esp)
  800d9d:	e8 d5 f3 ff ff       	call   800177 <cprintf>
  800da2:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	68 e0 13 80 00       	push   $0x8013e0
  800dad:	e8 c5 f3 ff ff       	call   800177 <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	a3 08 20 80 00       	mov    %eax,0x802008

}
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	c9                   	leave  
  800dbe:	c3                   	ret    

00800dbf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dbf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dc0:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800dc5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dc7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  800dca:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  800dcc:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  800dd0:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  800dd4:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  800dd5:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  800dd7:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  800dde:	00 
	popl %eax
  800ddf:	58                   	pop    %eax
	popl %eax
  800de0:	58                   	pop    %eax
	popal
  800de1:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  800de2:	83 c4 04             	add    $0x4,%esp
	popfl
  800de5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800de6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800de7:	c3                   	ret    

00800de8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	56                   	push   %esi
  800dec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ded:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800df0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800df6:	e8 10 fd ff ff       	call   800b0b <sys_getenvid>
  800dfb:	83 ec 0c             	sub    $0xc,%esp
  800dfe:	ff 75 0c             	pushl  0xc(%ebp)
  800e01:	ff 75 08             	pushl  0x8(%ebp)
  800e04:	56                   	push   %esi
  800e05:	50                   	push   %eax
  800e06:	68 64 14 80 00       	push   $0x801464
  800e0b:	e8 67 f3 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e10:	83 c4 18             	add    $0x18,%esp
  800e13:	53                   	push   %ebx
  800e14:	ff 75 10             	pushl  0x10(%ebp)
  800e17:	e8 0a f3 ff ff       	call   800126 <vcprintf>
	cprintf("\n");
  800e1c:	c7 04 24 62 14 80 00 	movl   $0x801462,(%esp)
  800e23:	e8 4f f3 ff ff       	call   800177 <cprintf>
  800e28:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e2b:	cc                   	int3   
  800e2c:	eb fd                	jmp    800e2b <_panic+0x43>
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 f6                	test   %esi,%esi
  800e49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e4d:	89 ca                	mov    %ecx,%edx
  800e4f:	89 f8                	mov    %edi,%eax
  800e51:	75 3d                	jne    800e90 <__udivdi3+0x60>
  800e53:	39 cf                	cmp    %ecx,%edi
  800e55:	0f 87 c5 00 00 00    	ja     800f20 <__udivdi3+0xf0>
  800e5b:	85 ff                	test   %edi,%edi
  800e5d:	89 fd                	mov    %edi,%ebp
  800e5f:	75 0b                	jne    800e6c <__udivdi3+0x3c>
  800e61:	b8 01 00 00 00       	mov    $0x1,%eax
  800e66:	31 d2                	xor    %edx,%edx
  800e68:	f7 f7                	div    %edi
  800e6a:	89 c5                	mov    %eax,%ebp
  800e6c:	89 c8                	mov    %ecx,%eax
  800e6e:	31 d2                	xor    %edx,%edx
  800e70:	f7 f5                	div    %ebp
  800e72:	89 c1                	mov    %eax,%ecx
  800e74:	89 d8                	mov    %ebx,%eax
  800e76:	89 cf                	mov    %ecx,%edi
  800e78:	f7 f5                	div    %ebp
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	39 ce                	cmp    %ecx,%esi
  800e92:	77 74                	ja     800f08 <__udivdi3+0xd8>
  800e94:	0f bd fe             	bsr    %esi,%edi
  800e97:	83 f7 1f             	xor    $0x1f,%edi
  800e9a:	0f 84 98 00 00 00    	je     800f38 <__udivdi3+0x108>
  800ea0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	89 c5                	mov    %eax,%ebp
  800ea9:	29 fb                	sub    %edi,%ebx
  800eab:	d3 e6                	shl    %cl,%esi
  800ead:	89 d9                	mov    %ebx,%ecx
  800eaf:	d3 ed                	shr    %cl,%ebp
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	d3 e0                	shl    %cl,%eax
  800eb5:	09 ee                	or     %ebp,%esi
  800eb7:	89 d9                	mov    %ebx,%ecx
  800eb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ebd:	89 d5                	mov    %edx,%ebp
  800ebf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ec3:	d3 ed                	shr    %cl,%ebp
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e2                	shl    %cl,%edx
  800ec9:	89 d9                	mov    %ebx,%ecx
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	09 c2                	or     %eax,%edx
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	89 ea                	mov    %ebp,%edx
  800ed3:	f7 f6                	div    %esi
  800ed5:	89 d5                	mov    %edx,%ebp
  800ed7:	89 c3                	mov    %eax,%ebx
  800ed9:	f7 64 24 0c          	mull   0xc(%esp)
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	72 10                	jb     800ef1 <__udivdi3+0xc1>
  800ee1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e6                	shl    %cl,%esi
  800ee9:	39 c6                	cmp    %eax,%esi
  800eeb:	73 07                	jae    800ef4 <__udivdi3+0xc4>
  800eed:	39 d5                	cmp    %edx,%ebp
  800eef:	75 03                	jne    800ef4 <__udivdi3+0xc4>
  800ef1:	83 eb 01             	sub    $0x1,%ebx
  800ef4:	31 ff                	xor    %edi,%edi
  800ef6:	89 d8                	mov    %ebx,%eax
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	31 ff                	xor    %edi,%edi
  800f0a:	31 db                	xor    %ebx,%ebx
  800f0c:	89 d8                	mov    %ebx,%eax
  800f0e:	89 fa                	mov    %edi,%edx
  800f10:	83 c4 1c             	add    $0x1c,%esp
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
  800f18:	90                   	nop
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	f7 f7                	div    %edi
  800f24:	31 ff                	xor    %edi,%edi
  800f26:	89 c3                	mov    %eax,%ebx
  800f28:	89 d8                	mov    %ebx,%eax
  800f2a:	89 fa                	mov    %edi,%edx
  800f2c:	83 c4 1c             	add    $0x1c,%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	39 ce                	cmp    %ecx,%esi
  800f3a:	72 0c                	jb     800f48 <__udivdi3+0x118>
  800f3c:	31 db                	xor    %ebx,%ebx
  800f3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f42:	0f 87 34 ff ff ff    	ja     800e7c <__udivdi3+0x4c>
  800f48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f4d:	e9 2a ff ff ff       	jmp    800e7c <__udivdi3+0x4c>
  800f52:	66 90                	xchg   %ax,%ax
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	55                   	push   %ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	83 ec 1c             	sub    $0x1c,%esp
  800f67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f77:	85 d2                	test   %edx,%edx
  800f79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 f3                	mov    %esi,%ebx
  800f83:	89 3c 24             	mov    %edi,(%esp)
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	75 1c                	jne    800fa8 <__umoddi3+0x48>
  800f8c:	39 f7                	cmp    %esi,%edi
  800f8e:	76 50                	jbe    800fe0 <__umoddi3+0x80>
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	f7 f7                	div    %edi
  800f96:	89 d0                	mov    %edx,%eax
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	83 c4 1c             	add    $0x1c,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	89 d0                	mov    %edx,%eax
  800fac:	77 52                	ja     801000 <__umoddi3+0xa0>
  800fae:	0f bd ea             	bsr    %edx,%ebp
  800fb1:	83 f5 1f             	xor    $0x1f,%ebp
  800fb4:	75 5a                	jne    801010 <__umoddi3+0xb0>
  800fb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fba:	0f 82 e0 00 00 00    	jb     8010a0 <__umoddi3+0x140>
  800fc0:	39 0c 24             	cmp    %ecx,(%esp)
  800fc3:	0f 86 d7 00 00 00    	jbe    8010a0 <__umoddi3+0x140>
  800fc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd1:	83 c4 1c             	add    $0x1c,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	85 ff                	test   %edi,%edi
  800fe2:	89 fd                	mov    %edi,%ebp
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f7                	div    %edi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	89 f0                	mov    %esi,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f5                	div    %ebp
  800ff7:	89 c8                	mov    %ecx,%eax
  800ff9:	f7 f5                	div    %ebp
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	eb 99                	jmp    800f98 <__umoddi3+0x38>
  800fff:	90                   	nop
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 f2                	mov    %esi,%edx
  801004:	83 c4 1c             	add    $0x1c,%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    
  80100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801010:	8b 34 24             	mov    (%esp),%esi
  801013:	bf 20 00 00 00       	mov    $0x20,%edi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	29 ef                	sub    %ebp,%edi
  80101c:	d3 e0                	shl    %cl,%eax
  80101e:	89 f9                	mov    %edi,%ecx
  801020:	89 f2                	mov    %esi,%edx
  801022:	d3 ea                	shr    %cl,%edx
  801024:	89 e9                	mov    %ebp,%ecx
  801026:	09 c2                	or     %eax,%edx
  801028:	89 d8                	mov    %ebx,%eax
  80102a:	89 14 24             	mov    %edx,(%esp)
  80102d:	89 f2                	mov    %esi,%edx
  80102f:	d3 e2                	shl    %cl,%edx
  801031:	89 f9                	mov    %edi,%ecx
  801033:	89 54 24 04          	mov    %edx,0x4(%esp)
  801037:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	89 e9                	mov    %ebp,%ecx
  80103f:	89 c6                	mov    %eax,%esi
  801041:	d3 e3                	shl    %cl,%ebx
  801043:	89 f9                	mov    %edi,%ecx
  801045:	89 d0                	mov    %edx,%eax
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	09 d8                	or     %ebx,%eax
  80104d:	89 d3                	mov    %edx,%ebx
  80104f:	89 f2                	mov    %esi,%edx
  801051:	f7 34 24             	divl   (%esp)
  801054:	89 d6                	mov    %edx,%esi
  801056:	d3 e3                	shl    %cl,%ebx
  801058:	f7 64 24 04          	mull   0x4(%esp)
  80105c:	39 d6                	cmp    %edx,%esi
  80105e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801062:	89 d1                	mov    %edx,%ecx
  801064:	89 c3                	mov    %eax,%ebx
  801066:	72 08                	jb     801070 <__umoddi3+0x110>
  801068:	75 11                	jne    80107b <__umoddi3+0x11b>
  80106a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80106e:	73 0b                	jae    80107b <__umoddi3+0x11b>
  801070:	2b 44 24 04          	sub    0x4(%esp),%eax
  801074:	1b 14 24             	sbb    (%esp),%edx
  801077:	89 d1                	mov    %edx,%ecx
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80107f:	29 da                	sub    %ebx,%edx
  801081:	19 ce                	sbb    %ecx,%esi
  801083:	89 f9                	mov    %edi,%ecx
  801085:	89 f0                	mov    %esi,%eax
  801087:	d3 e0                	shl    %cl,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	d3 ea                	shr    %cl,%edx
  80108d:	89 e9                	mov    %ebp,%ecx
  80108f:	d3 ee                	shr    %cl,%esi
  801091:	09 d0                	or     %edx,%eax
  801093:	89 f2                	mov    %esi,%edx
  801095:	83 c4 1c             	add    $0x1c,%esp
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	29 f9                	sub    %edi,%ecx
  8010a2:	19 d6                	sbb    %edx,%esi
  8010a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010ac:	e9 18 ff ff ff       	jmp    800fc9 <__umoddi3+0x69>
