
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 e0 0f 80 00       	push   $0x800fe0
  800048:	e8 38 01 00 00       	call   800185 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 de 0a 00 00       	call   800b38 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 00 10 80 00       	push   $0x801000
  80006c:	e8 14 01 00 00       	call   800185 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 2c 10 80 00       	push   $0x80102c
  80008d:	e8 f3 00 00 00       	call   800185 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 6f 0a 00 00       	call   800b19 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 eb 09 00 00       	call   800ad8 <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 1a                	jne    80012b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 79 09 00 00       	call   800a9b <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800128:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	68 f2 00 80 00       	push   $0x8000f2
  800163:	e8 54 01 00 00       	call   8002bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	83 c4 08             	add    $0x8,%esp
  80016b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800171:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	e8 1e 09 00 00       	call   800a9b <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018e:	50                   	push   %eax
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	e8 9d ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 1c             	sub    $0x1c,%esp
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001af:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001bd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c0:	39 d3                	cmp    %edx,%ebx
  8001c2:	72 05                	jb     8001c9 <printnum+0x30>
  8001c4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c7:	77 45                	ja     80020e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	ff 75 18             	pushl  0x18(%ebp)
  8001cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d5:	53                   	push   %ebx
  8001d6:	ff 75 10             	pushl  0x10(%ebp)
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001df:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e8:	e8 63 0b 00 00       	call   800d50 <__udivdi3>
  8001ed:	83 c4 18             	add    $0x18,%esp
  8001f0:	52                   	push   %edx
  8001f1:	50                   	push   %eax
  8001f2:	89 f2                	mov    %esi,%edx
  8001f4:	89 f8                	mov    %edi,%eax
  8001f6:	e8 9e ff ff ff       	call   800199 <printnum>
  8001fb:	83 c4 20             	add    $0x20,%esp
  8001fe:	eb 18                	jmp    800218 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	56                   	push   %esi
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	ff d7                	call   *%edi
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb 03                	jmp    800211 <printnum+0x78>
  80020e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800211:	83 eb 01             	sub    $0x1,%ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f e8                	jg     800200 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	56                   	push   %esi
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800222:	ff 75 e0             	pushl  -0x20(%ebp)
  800225:	ff 75 dc             	pushl  -0x24(%ebp)
  800228:	ff 75 d8             	pushl  -0x28(%ebp)
  80022b:	e8 50 0c 00 00       	call   800e80 <__umoddi3>
  800230:	83 c4 14             	add    $0x14,%esp
  800233:	0f be 80 55 10 80 00 	movsbl 0x801055(%eax),%eax
  80023a:	50                   	push   %eax
  80023b:	ff d7                	call   *%edi
}
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024b:	83 fa 01             	cmp    $0x1,%edx
  80024e:	7e 0e                	jle    80025e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 08             	lea    0x8(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	8b 52 04             	mov    0x4(%edx),%edx
  80025c:	eb 22                	jmp    800280 <getuint+0x38>
	else if (lflag)
  80025e:	85 d2                	test   %edx,%edx
  800260:	74 10                	je     800272 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
  800270:	eb 0e                	jmp    800280 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800288:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	3b 50 04             	cmp    0x4(%eax),%edx
  800291:	73 0a                	jae    80029d <sprintputch+0x1b>
		*b->buf++ = ch;
  800293:	8d 4a 01             	lea    0x1(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	88 02                	mov    %al,(%edx)
}
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a8:	50                   	push   %eax
  8002a9:	ff 75 10             	pushl  0x10(%ebp)
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	ff 75 08             	pushl  0x8(%ebp)
  8002b2:	e8 05 00 00 00       	call   8002bc <vprintfmt>
	va_end(ap);
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 2c             	sub    $0x2c,%esp
  8002c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002cb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ce:	eb 12                	jmp    8002e2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	0f 84 d3 03 00 00    	je     8006ab <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	53                   	push   %ebx
  8002dc:	50                   	push   %eax
  8002dd:	ff d6                	call   *%esi
  8002df:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e2:	83 c7 01             	add    $0x1,%edi
  8002e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e9:	83 f8 25             	cmp    $0x25,%eax
  8002ec:	75 e2                	jne    8002d0 <vprintfmt+0x14>
  8002ee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f9:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800300:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	eb 07                	jmp    800315 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800311:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8d 47 01             	lea    0x1(%edi),%eax
  800318:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031b:	0f b6 07             	movzbl (%edi),%eax
  80031e:	0f b6 c8             	movzbl %al,%ecx
  800321:	83 e8 23             	sub    $0x23,%eax
  800324:	3c 55                	cmp    $0x55,%al
  800326:	0f 87 64 03 00 00    	ja     800690 <vprintfmt+0x3d4>
  80032c:	0f b6 c0             	movzbl %al,%eax
  80032f:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800339:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033d:	eb d6                	jmp    800315 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800342:	b8 00 00 00 00       	mov    $0x0,%eax
  800347:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800351:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800354:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800357:	83 fa 09             	cmp    $0x9,%edx
  80035a:	77 39                	ja     800395 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035f:	eb e9                	jmp    80034a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 48 04             	lea    0x4(%eax),%ecx
  800367:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800372:	eb 27                	jmp    80039b <vprintfmt+0xdf>
  800374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800377:	85 c0                	test   %eax,%eax
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	0f 49 c8             	cmovns %eax,%ecx
  800381:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800387:	eb 8c                	jmp    800315 <vprintfmt+0x59>
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800393:	eb 80                	jmp    800315 <vprintfmt+0x59>
  800395:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800398:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80039b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039f:	0f 89 70 ff ff ff    	jns    800315 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ab:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003b2:	e9 5e ff ff ff       	jmp    800315 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bd:	e9 53 ff ff ff       	jmp    800315 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 50 04             	lea    0x4(%eax),%edx
  8003c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	53                   	push   %ebx
  8003cf:	ff 30                	pushl  (%eax)
  8003d1:	ff d6                	call   *%esi
			break;
  8003d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d9:	e9 04 ff ff ff       	jmp    8002e2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8d 50 04             	lea    0x4(%eax),%edx
  8003e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	99                   	cltd   
  8003ea:	31 d0                	xor    %edx,%eax
  8003ec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ee:	83 f8 08             	cmp    $0x8,%eax
  8003f1:	7f 0b                	jg     8003fe <vprintfmt+0x142>
  8003f3:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  8003fa:	85 d2                	test   %edx,%edx
  8003fc:	75 18                	jne    800416 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003fe:	50                   	push   %eax
  8003ff:	68 6d 10 80 00       	push   $0x80106d
  800404:	53                   	push   %ebx
  800405:	56                   	push   %esi
  800406:	e8 94 fe ff ff       	call   80029f <printfmt>
  80040b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800411:	e9 cc fe ff ff       	jmp    8002e2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800416:	52                   	push   %edx
  800417:	68 76 10 80 00       	push   $0x801076
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 7c fe ff ff       	call   80029f <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	e9 b4 fe ff ff       	jmp    8002e2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800439:	85 ff                	test   %edi,%edi
  80043b:	b8 66 10 80 00       	mov    $0x801066,%eax
  800440:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800443:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800447:	0f 8e 94 00 00 00    	jle    8004e1 <vprintfmt+0x225>
  80044d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800451:	0f 84 98 00 00 00    	je     8004ef <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 c8             	pushl  -0x38(%ebp)
  80045d:	57                   	push   %edi
  80045e:	e8 d0 02 00 00       	call   800733 <strnlen>
  800463:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800466:	29 c1                	sub    %eax,%ecx
  800468:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800478:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	eb 0f                	jmp    80048b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ef 01             	sub    $0x1,%edi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 ff                	test   %edi,%edi
  80048d:	7f ed                	jg     80047c <vprintfmt+0x1c0>
  80048f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800492:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800495:	85 c9                	test   %ecx,%ecx
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	0f 49 c1             	cmovns %ecx,%eax
  80049f:	29 c1                	sub    %eax,%ecx
  8004a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a4:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004aa:	89 cb                	mov    %ecx,%ebx
  8004ac:	eb 4d                	jmp    8004fb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b2:	74 1b                	je     8004cf <vprintfmt+0x213>
  8004b4:	0f be c0             	movsbl %al,%eax
  8004b7:	83 e8 20             	sub    $0x20,%eax
  8004ba:	83 f8 5e             	cmp    $0x5e,%eax
  8004bd:	76 10                	jbe    8004cf <vprintfmt+0x213>
					putch('?', putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	6a 3f                	push   $0x3f
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	eb 0d                	jmp    8004dc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 0c             	pushl  0xc(%ebp)
  8004d5:	52                   	push   %edx
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dc:	83 eb 01             	sub    $0x1,%ebx
  8004df:	eb 1a                	jmp    8004fb <vprintfmt+0x23f>
  8004e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e4:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ed:	eb 0c                	jmp    8004fb <vprintfmt+0x23f>
  8004ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f2:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fb:	83 c7 01             	add    $0x1,%edi
  8004fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800502:	0f be d0             	movsbl %al,%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	74 23                	je     80052c <vprintfmt+0x270>
  800509:	85 f6                	test   %esi,%esi
  80050b:	78 a1                	js     8004ae <vprintfmt+0x1f2>
  80050d:	83 ee 01             	sub    $0x1,%esi
  800510:	79 9c                	jns    8004ae <vprintfmt+0x1f2>
  800512:	89 df                	mov    %ebx,%edi
  800514:	8b 75 08             	mov    0x8(%ebp),%esi
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051a:	eb 18                	jmp    800534 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 20                	push   $0x20
  800522:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800524:	83 ef 01             	sub    $0x1,%edi
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb 08                	jmp    800534 <vprintfmt+0x278>
  80052c:	89 df                	mov    %ebx,%edi
  80052e:	8b 75 08             	mov    0x8(%ebp),%esi
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800534:	85 ff                	test   %edi,%edi
  800536:	7f e4                	jg     80051c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053b:	e9 a2 fd ff ff       	jmp    8002e2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800540:	83 fa 01             	cmp    $0x1,%edx
  800543:	7e 16                	jle    80055b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 08             	lea    0x8(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 50 04             	mov    0x4(%eax),%edx
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800556:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800559:	eb 32                	jmp    80058d <vprintfmt+0x2d1>
	else if (lflag)
  80055b:	85 d2                	test   %edx,%edx
  80055d:	74 18                	je     800577 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80056d:	89 c1                	mov    %eax,%ecx
  80056f:	c1 f9 1f             	sar    $0x1f,%ecx
  800572:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800575:	eb 16                	jmp    80058d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800590:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800593:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800596:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005a2:	0f 89 b0 00 00 00    	jns    800658 <vprintfmt+0x39c>
				putch('-', putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	53                   	push   %ebx
  8005ac:	6a 2d                	push   $0x2d
  8005ae:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005b3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005b6:	f7 d8                	neg    %eax
  8005b8:	83 d2 00             	adc    $0x0,%edx
  8005bb:	f7 da                	neg    %edx
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cb:	e9 88 00 00 00       	jmp    800658 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d3:	e8 70 fc ff ff       	call   800248 <getuint>
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005e3:	eb 73                	jmp    800658 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e8:	e8 5b fc ff ff       	call   800248 <getuint>
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 58                	push   $0x58
  8005f9:	ff d6                	call   *%esi
			putch('X', putdat);
  8005fb:	83 c4 08             	add    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 58                	push   $0x58
  800601:	ff d6                	call   *%esi
			putch('X', putdat);
  800603:	83 c4 08             	add    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 58                	push   $0x58
  800609:	ff d6                	call   *%esi
			goto number;
  80060b:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80060e:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800613:	eb 43                	jmp    800658 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	53                   	push   %ebx
  800619:	6a 30                	push   $0x30
  80061b:	ff d6                	call   *%esi
			putch('x', putdat);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 78                	push   $0x78
  800623:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80062e:	8b 00                	mov    (%eax),%eax
  800630:	ba 00 00 00 00       	mov    $0x0,%edx
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80063b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80063e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800643:	eb 13                	jmp    800658 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800645:	8d 45 14             	lea    0x14(%ebp),%eax
  800648:	e8 fb fb ff ff       	call   800248 <getuint>
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800653:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800658:	83 ec 0c             	sub    $0xc,%esp
  80065b:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80065f:	52                   	push   %edx
  800660:	ff 75 e0             	pushl  -0x20(%ebp)
  800663:	50                   	push   %eax
  800664:	ff 75 dc             	pushl  -0x24(%ebp)
  800667:	ff 75 d8             	pushl  -0x28(%ebp)
  80066a:	89 da                	mov    %ebx,%edx
  80066c:	89 f0                	mov    %esi,%eax
  80066e:	e8 26 fb ff ff       	call   800199 <printnum>
			break;
  800673:	83 c4 20             	add    $0x20,%esp
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800679:	e9 64 fc ff ff       	jmp    8002e2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	53                   	push   %ebx
  800682:	51                   	push   %ecx
  800683:	ff d6                	call   *%esi
			break;
  800685:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068b:	e9 52 fc ff ff       	jmp    8002e2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 25                	push   $0x25
  800696:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	eb 03                	jmp    8006a0 <vprintfmt+0x3e4>
  80069d:	83 ef 01             	sub    $0x1,%edi
  8006a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a4:	75 f7                	jne    80069d <vprintfmt+0x3e1>
  8006a6:	e9 37 fc ff ff       	jmp    8002e2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ae:	5b                   	pop    %ebx
  8006af:	5e                   	pop    %esi
  8006b0:	5f                   	pop    %edi
  8006b1:	5d                   	pop    %ebp
  8006b2:	c3                   	ret    

008006b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	83 ec 18             	sub    $0x18,%esp
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 26                	je     8006fa <vsnprintf+0x47>
  8006d4:	85 d2                	test   %edx,%edx
  8006d6:	7e 22                	jle    8006fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d8:	ff 75 14             	pushl  0x14(%ebp)
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e1:	50                   	push   %eax
  8006e2:	68 82 02 80 00       	push   $0x800282
  8006e7:	e8 d0 fb ff ff       	call   8002bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb 05                	jmp    8006ff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800707:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070a:	50                   	push   %eax
  80070b:	ff 75 10             	pushl  0x10(%ebp)
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	ff 75 08             	pushl  0x8(%ebp)
  800714:	e8 9a ff ff ff       	call   8006b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800719:	c9                   	leave  
  80071a:	c3                   	ret    

0080071b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800721:	b8 00 00 00 00       	mov    $0x0,%eax
  800726:	eb 03                	jmp    80072b <strlen+0x10>
		n++;
  800728:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072f:	75 f7                	jne    800728 <strlen+0xd>
		n++;
	return n;
}
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800739:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073c:	ba 00 00 00 00       	mov    $0x0,%edx
  800741:	eb 03                	jmp    800746 <strnlen+0x13>
		n++;
  800743:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800746:	39 c2                	cmp    %eax,%edx
  800748:	74 08                	je     800752 <strnlen+0x1f>
  80074a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074e:	75 f3                	jne    800743 <strnlen+0x10>
  800750:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	53                   	push   %ebx
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075e:	89 c2                	mov    %eax,%edx
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	83 c1 01             	add    $0x1,%ecx
  800766:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076d:	84 db                	test   %bl,%bl
  80076f:	75 ef                	jne    800760 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800771:	5b                   	pop    %ebx
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077b:	53                   	push   %ebx
  80077c:	e8 9a ff ff ff       	call   80071b <strlen>
  800781:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800784:	ff 75 0c             	pushl  0xc(%ebp)
  800787:	01 d8                	add    %ebx,%eax
  800789:	50                   	push   %eax
  80078a:	e8 c5 ff ff ff       	call   800754 <strcpy>
	return dst;
}
  80078f:	89 d8                	mov    %ebx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	8b 75 08             	mov    0x8(%ebp),%esi
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a1:	89 f3                	mov    %esi,%ebx
  8007a3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a6:	89 f2                	mov    %esi,%edx
  8007a8:	eb 0f                	jmp    8007b9 <strncpy+0x23>
		*dst++ = *src;
  8007aa:	83 c2 01             	add    $0x1,%edx
  8007ad:	0f b6 01             	movzbl (%ecx),%eax
  8007b0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b9:	39 da                	cmp    %ebx,%edx
  8007bb:	75 ed                	jne    8007aa <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007bd:	89 f0                	mov    %esi,%eax
  8007bf:	5b                   	pop    %ebx
  8007c0:	5e                   	pop    %esi
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	56                   	push   %esi
  8007c7:	53                   	push   %ebx
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ce:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d3:	85 d2                	test   %edx,%edx
  8007d5:	74 21                	je     8007f8 <strlcpy+0x35>
  8007d7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007db:	89 f2                	mov    %esi,%edx
  8007dd:	eb 09                	jmp    8007e8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e8:	39 c2                	cmp    %eax,%edx
  8007ea:	74 09                	je     8007f5 <strlcpy+0x32>
  8007ec:	0f b6 19             	movzbl (%ecx),%ebx
  8007ef:	84 db                	test   %bl,%bl
  8007f1:	75 ec                	jne    8007df <strlcpy+0x1c>
  8007f3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f8:	29 f0                	sub    %esi,%eax
}
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800807:	eb 06                	jmp    80080f <strcmp+0x11>
		p++, q++;
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80080f:	0f b6 01             	movzbl (%ecx),%eax
  800812:	84 c0                	test   %al,%al
  800814:	74 04                	je     80081a <strcmp+0x1c>
  800816:	3a 02                	cmp    (%edx),%al
  800818:	74 ef                	je     800809 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081a:	0f b6 c0             	movzbl %al,%eax
  80081d:	0f b6 12             	movzbl (%edx),%edx
  800820:	29 d0                	sub    %edx,%eax
}
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800833:	eb 06                	jmp    80083b <strncmp+0x17>
		n--, p++, q++;
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083b:	39 d8                	cmp    %ebx,%eax
  80083d:	74 15                	je     800854 <strncmp+0x30>
  80083f:	0f b6 08             	movzbl (%eax),%ecx
  800842:	84 c9                	test   %cl,%cl
  800844:	74 04                	je     80084a <strncmp+0x26>
  800846:	3a 0a                	cmp    (%edx),%cl
  800848:	74 eb                	je     800835 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 00             	movzbl (%eax),%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
  800852:	eb 05                	jmp    800859 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800854:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800859:	5b                   	pop    %ebx
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800866:	eb 07                	jmp    80086f <strchr+0x13>
		if (*s == c)
  800868:	38 ca                	cmp    %cl,%dl
  80086a:	74 0f                	je     80087b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	0f b6 10             	movzbl (%eax),%edx
  800872:	84 d2                	test   %dl,%dl
  800874:	75 f2                	jne    800868 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800887:	eb 03                	jmp    80088c <strfind+0xf>
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80088f:	38 ca                	cmp    %cl,%dl
  800891:	74 04                	je     800897 <strfind+0x1a>
  800893:	84 d2                	test   %dl,%dl
  800895:	75 f2                	jne    800889 <strfind+0xc>
			break;
	return (char *) s;
}
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	57                   	push   %edi
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
  80089f:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a5:	85 c9                	test   %ecx,%ecx
  8008a7:	74 36                	je     8008df <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008a9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008af:	75 28                	jne    8008d9 <memset+0x40>
  8008b1:	f6 c1 03             	test   $0x3,%cl
  8008b4:	75 23                	jne    8008d9 <memset+0x40>
		c &= 0xFF;
  8008b6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ba:	89 d3                	mov    %edx,%ebx
  8008bc:	c1 e3 08             	shl    $0x8,%ebx
  8008bf:	89 d6                	mov    %edx,%esi
  8008c1:	c1 e6 18             	shl    $0x18,%esi
  8008c4:	89 d0                	mov    %edx,%eax
  8008c6:	c1 e0 10             	shl    $0x10,%eax
  8008c9:	09 f0                	or     %esi,%eax
  8008cb:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008cd:	89 d8                	mov    %ebx,%eax
  8008cf:	09 d0                	or     %edx,%eax
  8008d1:	c1 e9 02             	shr    $0x2,%ecx
  8008d4:	fc                   	cld    
  8008d5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d7:	eb 06                	jmp    8008df <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dc:	fc                   	cld    
  8008dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008df:	89 f8                	mov    %edi,%eax
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5f                   	pop    %edi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	57                   	push   %edi
  8008ea:	56                   	push   %esi
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f4:	39 c6                	cmp    %eax,%esi
  8008f6:	73 35                	jae    80092d <memmove+0x47>
  8008f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fb:	39 d0                	cmp    %edx,%eax
  8008fd:	73 2e                	jae    80092d <memmove+0x47>
		s += n;
		d += n;
  8008ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800902:	89 d6                	mov    %edx,%esi
  800904:	09 fe                	or     %edi,%esi
  800906:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090c:	75 13                	jne    800921 <memmove+0x3b>
  80090e:	f6 c1 03             	test   $0x3,%cl
  800911:	75 0e                	jne    800921 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800913:	83 ef 04             	sub    $0x4,%edi
  800916:	8d 72 fc             	lea    -0x4(%edx),%esi
  800919:	c1 e9 02             	shr    $0x2,%ecx
  80091c:	fd                   	std    
  80091d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091f:	eb 09                	jmp    80092a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800921:	83 ef 01             	sub    $0x1,%edi
  800924:	8d 72 ff             	lea    -0x1(%edx),%esi
  800927:	fd                   	std    
  800928:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092a:	fc                   	cld    
  80092b:	eb 1d                	jmp    80094a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	89 f2                	mov    %esi,%edx
  80092f:	09 c2                	or     %eax,%edx
  800931:	f6 c2 03             	test   $0x3,%dl
  800934:	75 0f                	jne    800945 <memmove+0x5f>
  800936:	f6 c1 03             	test   $0x3,%cl
  800939:	75 0a                	jne    800945 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	89 c7                	mov    %eax,%edi
  800940:	fc                   	cld    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 05                	jmp    80094a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800951:	ff 75 10             	pushl  0x10(%ebp)
  800954:	ff 75 0c             	pushl  0xc(%ebp)
  800957:	ff 75 08             	pushl  0x8(%ebp)
  80095a:	e8 87 ff ff ff       	call   8008e6 <memmove>
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096c:	89 c6                	mov    %eax,%esi
  80096e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800971:	eb 1a                	jmp    80098d <memcmp+0x2c>
		if (*s1 != *s2)
  800973:	0f b6 08             	movzbl (%eax),%ecx
  800976:	0f b6 1a             	movzbl (%edx),%ebx
  800979:	38 d9                	cmp    %bl,%cl
  80097b:	74 0a                	je     800987 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097d:	0f b6 c1             	movzbl %cl,%eax
  800980:	0f b6 db             	movzbl %bl,%ebx
  800983:	29 d8                	sub    %ebx,%eax
  800985:	eb 0f                	jmp    800996 <memcmp+0x35>
		s1++, s2++;
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098d:	39 f0                	cmp    %esi,%eax
  80098f:	75 e2                	jne    800973 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a1:	89 c1                	mov    %eax,%ecx
  8009a3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009aa:	eb 0a                	jmp    8009b6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ac:	0f b6 10             	movzbl (%eax),%edx
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	74 07                	je     8009ba <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	39 c8                	cmp    %ecx,%eax
  8009b8:	72 f2                	jb     8009ac <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	57                   	push   %edi
  8009c1:	56                   	push   %esi
  8009c2:	53                   	push   %ebx
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c9:	eb 03                	jmp    8009ce <strtol+0x11>
		s++;
  8009cb:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	3c 20                	cmp    $0x20,%al
  8009d3:	74 f6                	je     8009cb <strtol+0xe>
  8009d5:	3c 09                	cmp    $0x9,%al
  8009d7:	74 f2                	je     8009cb <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009d9:	3c 2b                	cmp    $0x2b,%al
  8009db:	75 0a                	jne    8009e7 <strtol+0x2a>
		s++;
  8009dd:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e5:	eb 11                	jmp    8009f8 <strtol+0x3b>
  8009e7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ec:	3c 2d                	cmp    $0x2d,%al
  8009ee:	75 08                	jne    8009f8 <strtol+0x3b>
		s++, neg = 1;
  8009f0:	83 c1 01             	add    $0x1,%ecx
  8009f3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fe:	75 15                	jne    800a15 <strtol+0x58>
  800a00:	80 39 30             	cmpb   $0x30,(%ecx)
  800a03:	75 10                	jne    800a15 <strtol+0x58>
  800a05:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a09:	75 7c                	jne    800a87 <strtol+0xca>
		s += 2, base = 16;
  800a0b:	83 c1 02             	add    $0x2,%ecx
  800a0e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a13:	eb 16                	jmp    800a2b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a15:	85 db                	test   %ebx,%ebx
  800a17:	75 12                	jne    800a2b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a19:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a21:	75 08                	jne    800a2b <strtol+0x6e>
		s++, base = 8;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a33:	0f b6 11             	movzbl (%ecx),%edx
  800a36:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a39:	89 f3                	mov    %esi,%ebx
  800a3b:	80 fb 09             	cmp    $0x9,%bl
  800a3e:	77 08                	ja     800a48 <strtol+0x8b>
			dig = *s - '0';
  800a40:	0f be d2             	movsbl %dl,%edx
  800a43:	83 ea 30             	sub    $0x30,%edx
  800a46:	eb 22                	jmp    800a6a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a48:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4b:	89 f3                	mov    %esi,%ebx
  800a4d:	80 fb 19             	cmp    $0x19,%bl
  800a50:	77 08                	ja     800a5a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a52:	0f be d2             	movsbl %dl,%edx
  800a55:	83 ea 57             	sub    $0x57,%edx
  800a58:	eb 10                	jmp    800a6a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	80 fb 19             	cmp    $0x19,%bl
  800a62:	77 16                	ja     800a7a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a64:	0f be d2             	movsbl %dl,%edx
  800a67:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6d:	7d 0b                	jge    800a7a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a76:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a78:	eb b9                	jmp    800a33 <strtol+0x76>

	if (endptr)
  800a7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7e:	74 0d                	je     800a8d <strtol+0xd0>
		*endptr = (char *) s;
  800a80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a83:	89 0e                	mov    %ecx,(%esi)
  800a85:	eb 06                	jmp    800a8d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a87:	85 db                	test   %ebx,%ebx
  800a89:	74 98                	je     800a23 <strtol+0x66>
  800a8b:	eb 9e                	jmp    800a2b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8d:	89 c2                	mov    %eax,%edx
  800a8f:	f7 da                	neg    %edx
  800a91:	85 ff                	test   %edi,%edi
  800a93:	0f 45 c2             	cmovne %edx,%eax
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	89 c7                	mov    %eax,%edi
  800ab0:	89 c6                	mov    %eax,%esi
  800ab2:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5e                   	pop    %esi
  800ab6:	5f                   	pop    %edi
  800ab7:	5d                   	pop    %ebp
  800ab8:	c3                   	ret    

00800ab9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800abf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac9:	89 d1                	mov    %edx,%ecx
  800acb:	89 d3                	mov    %edx,%ebx
  800acd:	89 d7                	mov    %edx,%edi
  800acf:	89 d6                	mov    %edx,%esi
  800ad1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	53                   	push   %ebx
  800ade:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae6:	b8 03 00 00 00       	mov    $0x3,%eax
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800aee:	89 cb                	mov    %ecx,%ebx
  800af0:	89 cf                	mov    %ecx,%edi
  800af2:	89 ce                	mov    %ecx,%esi
  800af4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af6:	85 c0                	test   %eax,%eax
  800af8:	7e 17                	jle    800b11 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afa:	83 ec 0c             	sub    $0xc,%esp
  800afd:	50                   	push   %eax
  800afe:	6a 03                	push   $0x3
  800b00:	68 a4 12 80 00       	push   $0x8012a4
  800b05:	6a 23                	push   $0x23
  800b07:	68 c1 12 80 00       	push   $0x8012c1
  800b0c:	e8 f5 01 00 00       	call   800d06 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b24:	b8 02 00 00 00       	mov    $0x2,%eax
  800b29:	89 d1                	mov    %edx,%ecx
  800b2b:	89 d3                	mov    %edx,%ebx
  800b2d:	89 d7                	mov    %edx,%edi
  800b2f:	89 d6                	mov    %edx,%esi
  800b31:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <sys_yield>:

void
sys_yield(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b48:	89 d1                	mov    %edx,%ecx
  800b4a:	89 d3                	mov    %edx,%ebx
  800b4c:	89 d7                	mov    %edx,%edi
  800b4e:	89 d6                	mov    %edx,%esi
  800b50:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b60:	be 00 00 00 00       	mov    $0x0,%esi
  800b65:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b73:	89 f7                	mov    %esi,%edi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 04                	push   $0x4
  800b81:	68 a4 12 80 00       	push   $0x8012a4
  800b86:	6a 23                	push   $0x23
  800b88:	68 c1 12 80 00       	push   $0x8012c1
  800b8d:	e8 74 01 00 00       	call   800d06 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bab:	8b 55 08             	mov    0x8(%ebp),%edx
  800bae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 05                	push   $0x5
  800bc3:	68 a4 12 80 00       	push   $0x8012a4
  800bc8:	6a 23                	push   $0x23
  800bca:	68 c1 12 80 00       	push   $0x8012c1
  800bcf:	e8 32 01 00 00       	call   800d06 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 06 00 00 00       	mov    $0x6,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 06                	push   $0x6
  800c05:	68 a4 12 80 00       	push   $0x8012a4
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 c1 12 80 00       	push   $0x8012c1
  800c11:	e8 f0 00 00 00       	call   800d06 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	89 df                	mov    %ebx,%edi
  800c39:	89 de                	mov    %ebx,%esi
  800c3b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 08                	push   $0x8
  800c47:	68 a4 12 80 00       	push   $0x8012a4
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 c1 12 80 00       	push   $0x8012c1
  800c53:	e8 ae 00 00 00       	call   800d06 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 09                	push   $0x9
  800c89:	68 a4 12 80 00       	push   $0x8012a4
  800c8e:	6a 23                	push   $0x23
  800c90:	68 c1 12 80 00       	push   $0x8012c1
  800c95:	e8 6c 00 00 00       	call   800d06 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cbe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 cb                	mov    %ecx,%ebx
  800cdd:	89 cf                	mov    %ecx,%edi
  800cdf:	89 ce                	mov    %ecx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 0c                	push   $0xc
  800ced:	68 a4 12 80 00       	push   $0x8012a4
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 c1 12 80 00       	push   $0x8012c1
  800cf9:	e8 08 00 00 00       	call   800d06 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d0b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d0e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d14:	e8 00 fe ff ff       	call   800b19 <sys_getenvid>
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	ff 75 0c             	pushl  0xc(%ebp)
  800d1f:	ff 75 08             	pushl  0x8(%ebp)
  800d22:	56                   	push   %esi
  800d23:	50                   	push   %eax
  800d24:	68 d0 12 80 00       	push   $0x8012d0
  800d29:	e8 57 f4 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d2e:	83 c4 18             	add    $0x18,%esp
  800d31:	53                   	push   %ebx
  800d32:	ff 75 10             	pushl  0x10(%ebp)
  800d35:	e8 fa f3 ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  800d3a:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  800d41:	e8 3f f4 ff ff       	call   800185 <cprintf>
  800d46:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d49:	cc                   	int3   
  800d4a:	eb fd                	jmp    800d49 <_panic+0x43>
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__udivdi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d67:	85 f6                	test   %esi,%esi
  800d69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d6d:	89 ca                	mov    %ecx,%edx
  800d6f:	89 f8                	mov    %edi,%eax
  800d71:	75 3d                	jne    800db0 <__udivdi3+0x60>
  800d73:	39 cf                	cmp    %ecx,%edi
  800d75:	0f 87 c5 00 00 00    	ja     800e40 <__udivdi3+0xf0>
  800d7b:	85 ff                	test   %edi,%edi
  800d7d:	89 fd                	mov    %edi,%ebp
  800d7f:	75 0b                	jne    800d8c <__udivdi3+0x3c>
  800d81:	b8 01 00 00 00       	mov    $0x1,%eax
  800d86:	31 d2                	xor    %edx,%edx
  800d88:	f7 f7                	div    %edi
  800d8a:	89 c5                	mov    %eax,%ebp
  800d8c:	89 c8                	mov    %ecx,%eax
  800d8e:	31 d2                	xor    %edx,%edx
  800d90:	f7 f5                	div    %ebp
  800d92:	89 c1                	mov    %eax,%ecx
  800d94:	89 d8                	mov    %ebx,%eax
  800d96:	89 cf                	mov    %ecx,%edi
  800d98:	f7 f5                	div    %ebp
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	89 d8                	mov    %ebx,%eax
  800d9e:	89 fa                	mov    %edi,%edx
  800da0:	83 c4 1c             	add    $0x1c,%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    
  800da8:	90                   	nop
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	39 ce                	cmp    %ecx,%esi
  800db2:	77 74                	ja     800e28 <__udivdi3+0xd8>
  800db4:	0f bd fe             	bsr    %esi,%edi
  800db7:	83 f7 1f             	xor    $0x1f,%edi
  800dba:	0f 84 98 00 00 00    	je     800e58 <__udivdi3+0x108>
  800dc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	89 c5                	mov    %eax,%ebp
  800dc9:	29 fb                	sub    %edi,%ebx
  800dcb:	d3 e6                	shl    %cl,%esi
  800dcd:	89 d9                	mov    %ebx,%ecx
  800dcf:	d3 ed                	shr    %cl,%ebp
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e0                	shl    %cl,%eax
  800dd5:	09 ee                	or     %ebp,%esi
  800dd7:	89 d9                	mov    %ebx,%ecx
  800dd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ddd:	89 d5                	mov    %edx,%ebp
  800ddf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800de3:	d3 ed                	shr    %cl,%ebp
  800de5:	89 f9                	mov    %edi,%ecx
  800de7:	d3 e2                	shl    %cl,%edx
  800de9:	89 d9                	mov    %ebx,%ecx
  800deb:	d3 e8                	shr    %cl,%eax
  800ded:	09 c2                	or     %eax,%edx
  800def:	89 d0                	mov    %edx,%eax
  800df1:	89 ea                	mov    %ebp,%edx
  800df3:	f7 f6                	div    %esi
  800df5:	89 d5                	mov    %edx,%ebp
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	f7 64 24 0c          	mull   0xc(%esp)
  800dfd:	39 d5                	cmp    %edx,%ebp
  800dff:	72 10                	jb     800e11 <__udivdi3+0xc1>
  800e01:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e05:	89 f9                	mov    %edi,%ecx
  800e07:	d3 e6                	shl    %cl,%esi
  800e09:	39 c6                	cmp    %eax,%esi
  800e0b:	73 07                	jae    800e14 <__udivdi3+0xc4>
  800e0d:	39 d5                	cmp    %edx,%ebp
  800e0f:	75 03                	jne    800e14 <__udivdi3+0xc4>
  800e11:	83 eb 01             	sub    $0x1,%ebx
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 d8                	mov    %ebx,%eax
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	83 c4 1c             	add    $0x1c,%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
  800e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e28:	31 ff                	xor    %edi,%edi
  800e2a:	31 db                	xor    %ebx,%ebx
  800e2c:	89 d8                	mov    %ebx,%eax
  800e2e:	89 fa                	mov    %edi,%edx
  800e30:	83 c4 1c             	add    $0x1c,%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d8                	mov    %ebx,%eax
  800e42:	f7 f7                	div    %edi
  800e44:	31 ff                	xor    %edi,%edi
  800e46:	89 c3                	mov    %eax,%ebx
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	89 fa                	mov    %edi,%edx
  800e4c:	83 c4 1c             	add    $0x1c,%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    
  800e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e58:	39 ce                	cmp    %ecx,%esi
  800e5a:	72 0c                	jb     800e68 <__udivdi3+0x118>
  800e5c:	31 db                	xor    %ebx,%ebx
  800e5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e62:	0f 87 34 ff ff ff    	ja     800d9c <__udivdi3+0x4c>
  800e68:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e6d:	e9 2a ff ff ff       	jmp    800d9c <__udivdi3+0x4c>
  800e72:	66 90                	xchg   %ax,%ax
  800e74:	66 90                	xchg   %ax,%ax
  800e76:	66 90                	xchg   %ax,%ax
  800e78:	66 90                	xchg   %ax,%ax
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <__umoddi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 1c             	sub    $0x1c,%esp
  800e87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e97:	85 d2                	test   %edx,%edx
  800e99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ea1:	89 f3                	mov    %esi,%ebx
  800ea3:	89 3c 24             	mov    %edi,(%esp)
  800ea6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eaa:	75 1c                	jne    800ec8 <__umoddi3+0x48>
  800eac:	39 f7                	cmp    %esi,%edi
  800eae:	76 50                	jbe    800f00 <__umoddi3+0x80>
  800eb0:	89 c8                	mov    %ecx,%eax
  800eb2:	89 f2                	mov    %esi,%edx
  800eb4:	f7 f7                	div    %edi
  800eb6:	89 d0                	mov    %edx,%eax
  800eb8:	31 d2                	xor    %edx,%edx
  800eba:	83 c4 1c             	add    $0x1c,%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    
  800ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ec8:	39 f2                	cmp    %esi,%edx
  800eca:	89 d0                	mov    %edx,%eax
  800ecc:	77 52                	ja     800f20 <__umoddi3+0xa0>
  800ece:	0f bd ea             	bsr    %edx,%ebp
  800ed1:	83 f5 1f             	xor    $0x1f,%ebp
  800ed4:	75 5a                	jne    800f30 <__umoddi3+0xb0>
  800ed6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eda:	0f 82 e0 00 00 00    	jb     800fc0 <__umoddi3+0x140>
  800ee0:	39 0c 24             	cmp    %ecx,(%esp)
  800ee3:	0f 86 d7 00 00 00    	jbe    800fc0 <__umoddi3+0x140>
  800ee9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800eed:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ef1:	83 c4 1c             	add    $0x1c,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	85 ff                	test   %edi,%edi
  800f02:	89 fd                	mov    %edi,%ebp
  800f04:	75 0b                	jne    800f11 <__umoddi3+0x91>
  800f06:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	f7 f7                	div    %edi
  800f0f:	89 c5                	mov    %eax,%ebp
  800f11:	89 f0                	mov    %esi,%eax
  800f13:	31 d2                	xor    %edx,%edx
  800f15:	f7 f5                	div    %ebp
  800f17:	89 c8                	mov    %ecx,%eax
  800f19:	f7 f5                	div    %ebp
  800f1b:	89 d0                	mov    %edx,%eax
  800f1d:	eb 99                	jmp    800eb8 <__umoddi3+0x38>
  800f1f:	90                   	nop
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	83 c4 1c             	add    $0x1c,%esp
  800f27:	5b                   	pop    %ebx
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    
  800f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f30:	8b 34 24             	mov    (%esp),%esi
  800f33:	bf 20 00 00 00       	mov    $0x20,%edi
  800f38:	89 e9                	mov    %ebp,%ecx
  800f3a:	29 ef                	sub    %ebp,%edi
  800f3c:	d3 e0                	shl    %cl,%eax
  800f3e:	89 f9                	mov    %edi,%ecx
  800f40:	89 f2                	mov    %esi,%edx
  800f42:	d3 ea                	shr    %cl,%edx
  800f44:	89 e9                	mov    %ebp,%ecx
  800f46:	09 c2                	or     %eax,%edx
  800f48:	89 d8                	mov    %ebx,%eax
  800f4a:	89 14 24             	mov    %edx,(%esp)
  800f4d:	89 f2                	mov    %esi,%edx
  800f4f:	d3 e2                	shl    %cl,%edx
  800f51:	89 f9                	mov    %edi,%ecx
  800f53:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f5b:	d3 e8                	shr    %cl,%eax
  800f5d:	89 e9                	mov    %ebp,%ecx
  800f5f:	89 c6                	mov    %eax,%esi
  800f61:	d3 e3                	shl    %cl,%ebx
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 d0                	mov    %edx,%eax
  800f67:	d3 e8                	shr    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	09 d8                	or     %ebx,%eax
  800f6d:	89 d3                	mov    %edx,%ebx
  800f6f:	89 f2                	mov    %esi,%edx
  800f71:	f7 34 24             	divl   (%esp)
  800f74:	89 d6                	mov    %edx,%esi
  800f76:	d3 e3                	shl    %cl,%ebx
  800f78:	f7 64 24 04          	mull   0x4(%esp)
  800f7c:	39 d6                	cmp    %edx,%esi
  800f7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f82:	89 d1                	mov    %edx,%ecx
  800f84:	89 c3                	mov    %eax,%ebx
  800f86:	72 08                	jb     800f90 <__umoddi3+0x110>
  800f88:	75 11                	jne    800f9b <__umoddi3+0x11b>
  800f8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f8e:	73 0b                	jae    800f9b <__umoddi3+0x11b>
  800f90:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f94:	1b 14 24             	sbb    (%esp),%edx
  800f97:	89 d1                	mov    %edx,%ecx
  800f99:	89 c3                	mov    %eax,%ebx
  800f9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f9f:	29 da                	sub    %ebx,%edx
  800fa1:	19 ce                	sbb    %ecx,%esi
  800fa3:	89 f9                	mov    %edi,%ecx
  800fa5:	89 f0                	mov    %esi,%eax
  800fa7:	d3 e0                	shl    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	d3 ea                	shr    %cl,%edx
  800fad:	89 e9                	mov    %ebp,%ecx
  800faf:	d3 ee                	shr    %cl,%esi
  800fb1:	09 d0                	or     %edx,%eax
  800fb3:	89 f2                	mov    %esi,%edx
  800fb5:	83 c4 1c             	add    $0x1c,%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    
  800fbd:	8d 76 00             	lea    0x0(%esi),%esi
  800fc0:	29 f9                	sub    %edi,%ecx
  800fc2:	19 d6                	sbb    %edx,%esi
  800fc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fcc:	e9 18 ff ff ff       	jmp    800ee9 <__umoddi3+0x69>
