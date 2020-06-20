
obj/user/yield.debug:     file format elf32-i386


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
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 20 1e 80 00       	push   $0x801e20
  800048:	e8 40 01 00 00       	call   80018d <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 e6 0a 00 00       	call   800b40 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 40 1e 80 00       	push   $0x801e40
  80006c:	e8 1c 01 00 00       	call   80018d <cprintf>
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
  80007c:	a1 04 40 80 00       	mov    0x804004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 6c 1e 80 00       	push   $0x801e6c
  80008d:	e8 fb 00 00 00       	call   80018d <cprintf>
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
  8000a5:	e8 77 0a 00 00       	call   800b21 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000e3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e6:	e8 30 0e 00 00       	call   800f1b <close_all>
	sys_env_destroy(0);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	6a 00                	push   $0x0
  8000f0:	e8 eb 09 00 00       	call   800ae0 <sys_env_destroy>
}
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	53                   	push   %ebx
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800104:	8b 13                	mov    (%ebx),%edx
  800106:	8d 42 01             	lea    0x1(%edx),%eax
  800109:	89 03                	mov    %eax,(%ebx)
  80010b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800112:	3d ff 00 00 00       	cmp    $0xff,%eax
  800117:	75 1a                	jne    800133 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800119:	83 ec 08             	sub    $0x8,%esp
  80011c:	68 ff 00 00 00       	push   $0xff
  800121:	8d 43 08             	lea    0x8(%ebx),%eax
  800124:	50                   	push   %eax
  800125:	e8 79 09 00 00       	call   800aa3 <sys_cputs>
		b->idx = 0;
  80012a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800130:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800133:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800137:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800145:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014c:	00 00 00 
	b.cnt = 0;
  80014f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800156:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800159:	ff 75 0c             	pushl  0xc(%ebp)
  80015c:	ff 75 08             	pushl  0x8(%ebp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	68 fa 00 80 00       	push   $0x8000fa
  80016b:	e8 54 01 00 00       	call   8002c4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 1e 09 00 00       	call   800aa3 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800196:	50                   	push   %eax
  800197:	ff 75 08             	pushl  0x8(%ebp)
  80019a:	e8 9d ff ff ff       	call   80013c <vcprintf>
	va_end(ap);

	return cnt;
}
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 1c             	sub    $0x1c,%esp
  8001aa:	89 c7                	mov    %eax,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c8:	39 d3                	cmp    %edx,%ebx
  8001ca:	72 05                	jb     8001d1 <printnum+0x30>
  8001cc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cf:	77 45                	ja     800216 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001da:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 10             	pushl  0x10(%ebp)
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f0:	e8 9b 19 00 00       	call   801b90 <__udivdi3>
  8001f5:	83 c4 18             	add    $0x18,%esp
  8001f8:	52                   	push   %edx
  8001f9:	50                   	push   %eax
  8001fa:	89 f2                	mov    %esi,%edx
  8001fc:	89 f8                	mov    %edi,%eax
  8001fe:	e8 9e ff ff ff       	call   8001a1 <printnum>
  800203:	83 c4 20             	add    $0x20,%esp
  800206:	eb 18                	jmp    800220 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	ff 75 18             	pushl  0x18(%ebp)
  80020f:	ff d7                	call   *%edi
  800211:	83 c4 10             	add    $0x10,%esp
  800214:	eb 03                	jmp    800219 <printnum+0x78>
  800216:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800219:	83 eb 01             	sub    $0x1,%ebx
  80021c:	85 db                	test   %ebx,%ebx
  80021e:	7f e8                	jg     800208 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	83 ec 04             	sub    $0x4,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 88 1a 00 00       	call   801cc0 <__umoddi3>
  800238:	83 c4 14             	add    $0x14,%esp
  80023b:	0f be 80 95 1e 80 00 	movsbl 0x801e95(%eax),%eax
  800242:	50                   	push   %eax
  800243:	ff d7                	call   *%edi
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800253:	83 fa 01             	cmp    $0x1,%edx
  800256:	7e 0e                	jle    800266 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	8b 52 04             	mov    0x4(%edx),%edx
  800264:	eb 22                	jmp    800288 <getuint+0x38>
	else if (lflag)
  800266:	85 d2                	test   %edx,%edx
  800268:	74 10                	je     80027a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80026a:	8b 10                	mov    (%eax),%edx
  80026c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026f:	89 08                	mov    %ecx,(%eax)
  800271:	8b 02                	mov    (%edx),%eax
  800273:	ba 00 00 00 00       	mov    $0x0,%edx
  800278:	eb 0e                	jmp    800288 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80027a:	8b 10                	mov    (%eax),%edx
  80027c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 02                	mov    (%edx),%eax
  800283:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800290:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800294:	8b 10                	mov    (%eax),%edx
  800296:	3b 50 04             	cmp    0x4(%eax),%edx
  800299:	73 0a                	jae    8002a5 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029e:	89 08                	mov    %ecx,(%eax)
  8002a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a3:	88 02                	mov    %al,(%edx)
}
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b0:	50                   	push   %eax
  8002b1:	ff 75 10             	pushl  0x10(%ebp)
  8002b4:	ff 75 0c             	pushl  0xc(%ebp)
  8002b7:	ff 75 08             	pushl  0x8(%ebp)
  8002ba:	e8 05 00 00 00       	call   8002c4 <vprintfmt>
	va_end(ap);
}
  8002bf:	83 c4 10             	add    $0x10,%esp
  8002c2:	c9                   	leave  
  8002c3:	c3                   	ret    

008002c4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 2c             	sub    $0x2c,%esp
  8002cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	eb 12                	jmp    8002ea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	0f 84 d3 03 00 00    	je     8006b3 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	53                   	push   %ebx
  8002e4:	50                   	push   %eax
  8002e5:	ff d6                	call   *%esi
  8002e7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ea:	83 c7 01             	add    $0x1,%edi
  8002ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e2                	jne    8002d8 <vprintfmt+0x14>
  8002f6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002fa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800301:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800308:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 07                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800316:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800319:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8d 47 01             	lea    0x1(%edi),%eax
  800320:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800323:	0f b6 07             	movzbl (%edi),%eax
  800326:	0f b6 c8             	movzbl %al,%ecx
  800329:	83 e8 23             	sub    $0x23,%eax
  80032c:	3c 55                	cmp    $0x55,%al
  80032e:	0f 87 64 03 00 00    	ja     800698 <vprintfmt+0x3d4>
  800334:	0f b6 c0             	movzbl %al,%eax
  800337:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  80033e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800341:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800345:	eb d6                	jmp    80031d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035f:	83 fa 09             	cmp    $0x9,%edx
  800362:	77 39                	ja     80039d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800364:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800367:	eb e9                	jmp    800352 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 48 04             	lea    0x4(%eax),%ecx
  80036f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80037a:	eb 27                	jmp    8003a3 <vprintfmt+0xdf>
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	0f 49 c8             	cmovns %eax,%ecx
  800389:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	eb 8c                	jmp    80031d <vprintfmt+0x59>
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039b:	eb 80                	jmp    80031d <vprintfmt+0x59>
  80039d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a0:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a7:	0f 89 70 ff ff ff    	jns    80031d <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ad:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003ba:	e9 5e ff ff ff       	jmp    80031d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003bf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c5:	e9 53 ff ff ff       	jmp    80031d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	8d 50 04             	lea    0x4(%eax),%edx
  8003d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	53                   	push   %ebx
  8003d7:	ff 30                	pushl  (%eax)
  8003d9:	ff d6                	call   *%esi
			break;
  8003db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e1:	e9 04 ff ff ff       	jmp    8002ea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 00                	mov    (%eax),%eax
  8003f1:	99                   	cltd   
  8003f2:	31 d0                	xor    %edx,%eax
  8003f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 0f             	cmp    $0xf,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0x142>
  8003fb:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 18                	jne    80041e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	68 ad 1e 80 00       	push   $0x801ead
  80040c:	53                   	push   %ebx
  80040d:	56                   	push   %esi
  80040e:	e8 94 fe ff ff       	call   8002a7 <printfmt>
  800413:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800419:	e9 cc fe ff ff       	jmp    8002ea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041e:	52                   	push   %edx
  80041f:	68 71 22 80 00       	push   $0x802271
  800424:	53                   	push   %ebx
  800425:	56                   	push   %esi
  800426:	e8 7c fe ff ff       	call   8002a7 <printfmt>
  80042b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	e9 b4 fe ff ff       	jmp    8002ea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 50 04             	lea    0x4(%eax),%edx
  80043c:	89 55 14             	mov    %edx,0x14(%ebp)
  80043f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800441:	85 ff                	test   %edi,%edi
  800443:	b8 a6 1e 80 00       	mov    $0x801ea6,%eax
  800448:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044f:	0f 8e 94 00 00 00    	jle    8004e9 <vprintfmt+0x225>
  800455:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800459:	0f 84 98 00 00 00    	je     8004f7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 c8             	pushl  -0x38(%ebp)
  800465:	57                   	push   %edi
  800466:	e8 d0 02 00 00       	call   80073b <strnlen>
  80046b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046e:	29 c1                	sub    %eax,%ecx
  800470:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800473:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800476:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80047a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800480:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	eb 0f                	jmp    800493 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 ff                	test   %edi,%edi
  800495:	7f ed                	jg     800484 <vprintfmt+0x1c0>
  800497:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80049a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a4:	0f 49 c1             	cmovns %ecx,%eax
  8004a7:	29 c1                	sub    %eax,%ecx
  8004a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ac:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b2:	89 cb                	mov    %ecx,%ebx
  8004b4:	eb 4d                	jmp    800503 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ba:	74 1b                	je     8004d7 <vprintfmt+0x213>
  8004bc:	0f be c0             	movsbl %al,%eax
  8004bf:	83 e8 20             	sub    $0x20,%eax
  8004c2:	83 f8 5e             	cmp    $0x5e,%eax
  8004c5:	76 10                	jbe    8004d7 <vprintfmt+0x213>
					putch('?', putdat);
  8004c7:	83 ec 08             	sub    $0x8,%esp
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	6a 3f                	push   $0x3f
  8004cf:	ff 55 08             	call   *0x8(%ebp)
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	eb 0d                	jmp    8004e4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	52                   	push   %edx
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e4:	83 eb 01             	sub    $0x1,%ebx
  8004e7:	eb 1a                	jmp    800503 <vprintfmt+0x23f>
  8004e9:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ec:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f5:	eb 0c                	jmp    800503 <vprintfmt+0x23f>
  8004f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004fa:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800500:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800503:	83 c7 01             	add    $0x1,%edi
  800506:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050a:	0f be d0             	movsbl %al,%edx
  80050d:	85 d2                	test   %edx,%edx
  80050f:	74 23                	je     800534 <vprintfmt+0x270>
  800511:	85 f6                	test   %esi,%esi
  800513:	78 a1                	js     8004b6 <vprintfmt+0x1f2>
  800515:	83 ee 01             	sub    $0x1,%esi
  800518:	79 9c                	jns    8004b6 <vprintfmt+0x1f2>
  80051a:	89 df                	mov    %ebx,%edi
  80051c:	8b 75 08             	mov    0x8(%ebp),%esi
  80051f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800522:	eb 18                	jmp    80053c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	53                   	push   %ebx
  800528:	6a 20                	push   $0x20
  80052a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052c:	83 ef 01             	sub    $0x1,%edi
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb 08                	jmp    80053c <vprintfmt+0x278>
  800534:	89 df                	mov    %ebx,%edi
  800536:	8b 75 08             	mov    0x8(%ebp),%esi
  800539:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053c:	85 ff                	test   %edi,%edi
  80053e:	7f e4                	jg     800524 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800543:	e9 a2 fd ff ff       	jmp    8002ea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800548:	83 fa 01             	cmp    $0x1,%edx
  80054b:	7e 16                	jle    800563 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054d:	8b 45 14             	mov    0x14(%ebp),%eax
  800550:	8d 50 08             	lea    0x8(%eax),%edx
  800553:	89 55 14             	mov    %edx,0x14(%ebp)
  800556:	8b 50 04             	mov    0x4(%eax),%edx
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80055e:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800561:	eb 32                	jmp    800595 <vprintfmt+0x2d1>
	else if (lflag)
  800563:	85 d2                	test   %edx,%edx
  800565:	74 18                	je     80057f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 50 04             	lea    0x4(%eax),%edx
  80056d:	89 55 14             	mov    %edx,0x14(%ebp)
  800570:	8b 00                	mov    (%eax),%eax
  800572:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800575:	89 c1                	mov    %eax,%ecx
  800577:	c1 f9 1f             	sar    $0x1f,%ecx
  80057a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80057d:	eb 16                	jmp    800595 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 50 04             	lea    0x4(%eax),%edx
  800585:	89 55 14             	mov    %edx,0x14(%ebp)
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80058d:	89 c1                	mov    %eax,%ecx
  80058f:	c1 f9 1f             	sar    $0x1f,%ecx
  800592:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800595:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800598:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80059b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005aa:	0f 89 b0 00 00 00    	jns    800660 <vprintfmt+0x39c>
				putch('-', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 2d                	push   $0x2d
  8005b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005bb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005be:	f7 d8                	neg    %eax
  8005c0:	83 d2 00             	adc    $0x0,%edx
  8005c3:	f7 da                	neg    %edx
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d3:	e9 88 00 00 00       	jmp    800660 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005db:	e8 70 fc ff ff       	call   800250 <getuint>
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005eb:	eb 73                	jmp    800660 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  8005ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f0:	e8 5b fc ff ff       	call   800250 <getuint>
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	53                   	push   %ebx
  8005ff:	6a 58                	push   $0x58
  800601:	ff d6                	call   *%esi
			putch('X', putdat);
  800603:	83 c4 08             	add    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 58                	push   $0x58
  800609:	ff d6                	call   *%esi
			putch('X', putdat);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 58                	push   $0x58
  800611:	ff d6                	call   *%esi
			goto number;
  800613:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800616:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80061b:	eb 43                	jmp    800660 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 30                	push   $0x30
  800623:	ff d6                	call   *%esi
			putch('x', putdat);
  800625:	83 c4 08             	add    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 78                	push   $0x78
  80062b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800636:	8b 00                	mov    (%eax),%eax
  800638:	ba 00 00 00 00       	mov    $0x0,%edx
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800643:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800646:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064b:	eb 13                	jmp    800660 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064d:	8d 45 14             	lea    0x14(%ebp),%eax
  800650:	e8 fb fb ff ff       	call   800250 <getuint>
  800655:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800658:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80065b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800667:	52                   	push   %edx
  800668:	ff 75 e0             	pushl  -0x20(%ebp)
  80066b:	50                   	push   %eax
  80066c:	ff 75 dc             	pushl  -0x24(%ebp)
  80066f:	ff 75 d8             	pushl  -0x28(%ebp)
  800672:	89 da                	mov    %ebx,%edx
  800674:	89 f0                	mov    %esi,%eax
  800676:	e8 26 fb ff ff       	call   8001a1 <printnum>
			break;
  80067b:	83 c4 20             	add    $0x20,%esp
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800681:	e9 64 fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	51                   	push   %ecx
  80068b:	ff d6                	call   *%esi
			break;
  80068d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800693:	e9 52 fc ff ff       	jmp    8002ea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 25                	push   $0x25
  80069e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	eb 03                	jmp    8006a8 <vprintfmt+0x3e4>
  8006a5:	83 ef 01             	sub    $0x1,%edi
  8006a8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ac:	75 f7                	jne    8006a5 <vprintfmt+0x3e1>
  8006ae:	e9 37 fc ff ff       	jmp    8002ea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b6:	5b                   	pop    %ebx
  8006b7:	5e                   	pop    %esi
  8006b8:	5f                   	pop    %edi
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 18             	sub    $0x18,%esp
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 26                	je     800702 <vsnprintf+0x47>
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	7e 22                	jle    800702 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e0:	ff 75 14             	pushl  0x14(%ebp)
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	68 8a 02 80 00       	push   $0x80028a
  8006ef:	e8 d0 fb ff ff       	call   8002c4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	eb 05                	jmp    800707 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800712:	50                   	push   %eax
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	ff 75 0c             	pushl  0xc(%ebp)
  800719:	ff 75 08             	pushl  0x8(%ebp)
  80071c:	e8 9a ff ff ff       	call   8006bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	eb 03                	jmp    800733 <strlen+0x10>
		n++;
  800730:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800733:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800737:	75 f7                	jne    800730 <strlen+0xd>
		n++;
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800741:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800744:	ba 00 00 00 00       	mov    $0x0,%edx
  800749:	eb 03                	jmp    80074e <strnlen+0x13>
		n++;
  80074b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074e:	39 c2                	cmp    %eax,%edx
  800750:	74 08                	je     80075a <strnlen+0x1f>
  800752:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800756:	75 f3                	jne    80074b <strnlen+0x10>
  800758:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	53                   	push   %ebx
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800766:	89 c2                	mov    %eax,%edx
  800768:	83 c2 01             	add    $0x1,%edx
  80076b:	83 c1 01             	add    $0x1,%ecx
  80076e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800772:	88 5a ff             	mov    %bl,-0x1(%edx)
  800775:	84 db                	test   %bl,%bl
  800777:	75 ef                	jne    800768 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800779:	5b                   	pop    %ebx
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	53                   	push   %ebx
  800780:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800783:	53                   	push   %ebx
  800784:	e8 9a ff ff ff       	call   800723 <strlen>
  800789:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	01 d8                	add    %ebx,%eax
  800791:	50                   	push   %eax
  800792:	e8 c5 ff ff ff       	call   80075c <strcpy>
	return dst;
}
  800797:	89 d8                	mov    %ebx,%eax
  800799:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	56                   	push   %esi
  8007a2:	53                   	push   %ebx
  8007a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a9:	89 f3                	mov    %esi,%ebx
  8007ab:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ae:	89 f2                	mov    %esi,%edx
  8007b0:	eb 0f                	jmp    8007c1 <strncpy+0x23>
		*dst++ = *src;
  8007b2:	83 c2 01             	add    $0x1,%edx
  8007b5:	0f b6 01             	movzbl (%ecx),%eax
  8007b8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007be:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	39 da                	cmp    %ebx,%edx
  8007c3:	75 ed                	jne    8007b2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c5:	89 f0                	mov    %esi,%eax
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	56                   	push   %esi
  8007cf:	53                   	push   %ebx
  8007d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	74 21                	je     800800 <strlcpy+0x35>
  8007df:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e3:	89 f2                	mov    %esi,%edx
  8007e5:	eb 09                	jmp    8007f0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	83 c1 01             	add    $0x1,%ecx
  8007ed:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f0:	39 c2                	cmp    %eax,%edx
  8007f2:	74 09                	je     8007fd <strlcpy+0x32>
  8007f4:	0f b6 19             	movzbl (%ecx),%ebx
  8007f7:	84 db                	test   %bl,%bl
  8007f9:	75 ec                	jne    8007e7 <strlcpy+0x1c>
  8007fb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800800:	29 f0                	sub    %esi,%eax
}
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080f:	eb 06                	jmp    800817 <strcmp+0x11>
		p++, q++;
  800811:	83 c1 01             	add    $0x1,%ecx
  800814:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800817:	0f b6 01             	movzbl (%ecx),%eax
  80081a:	84 c0                	test   %al,%al
  80081c:	74 04                	je     800822 <strcmp+0x1c>
  80081e:	3a 02                	cmp    (%edx),%al
  800820:	74 ef                	je     800811 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800822:	0f b6 c0             	movzbl %al,%eax
  800825:	0f b6 12             	movzbl (%edx),%edx
  800828:	29 d0                	sub    %edx,%eax
}
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	53                   	push   %ebx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	89 c3                	mov    %eax,%ebx
  800838:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083b:	eb 06                	jmp    800843 <strncmp+0x17>
		n--, p++, q++;
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800843:	39 d8                	cmp    %ebx,%eax
  800845:	74 15                	je     80085c <strncmp+0x30>
  800847:	0f b6 08             	movzbl (%eax),%ecx
  80084a:	84 c9                	test   %cl,%cl
  80084c:	74 04                	je     800852 <strncmp+0x26>
  80084e:	3a 0a                	cmp    (%edx),%cl
  800850:	74 eb                	je     80083d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800852:	0f b6 00             	movzbl (%eax),%eax
  800855:	0f b6 12             	movzbl (%edx),%edx
  800858:	29 d0                	sub    %edx,%eax
  80085a:	eb 05                	jmp    800861 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086e:	eb 07                	jmp    800877 <strchr+0x13>
		if (*s == c)
  800870:	38 ca                	cmp    %cl,%dl
  800872:	74 0f                	je     800883 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800874:	83 c0 01             	add    $0x1,%eax
  800877:	0f b6 10             	movzbl (%eax),%edx
  80087a:	84 d2                	test   %dl,%dl
  80087c:	75 f2                	jne    800870 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	eb 03                	jmp    800894 <strfind+0xf>
  800891:	83 c0 01             	add    $0x1,%eax
  800894:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800897:	38 ca                	cmp    %cl,%dl
  800899:	74 04                	je     80089f <strfind+0x1a>
  80089b:	84 d2                	test   %dl,%dl
  80089d:	75 f2                	jne    800891 <strfind+0xc>
			break;
	return (char *) s;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	57                   	push   %edi
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ad:	85 c9                	test   %ecx,%ecx
  8008af:	74 36                	je     8008e7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b7:	75 28                	jne    8008e1 <memset+0x40>
  8008b9:	f6 c1 03             	test   $0x3,%cl
  8008bc:	75 23                	jne    8008e1 <memset+0x40>
		c &= 0xFF;
  8008be:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c2:	89 d3                	mov    %edx,%ebx
  8008c4:	c1 e3 08             	shl    $0x8,%ebx
  8008c7:	89 d6                	mov    %edx,%esi
  8008c9:	c1 e6 18             	shl    $0x18,%esi
  8008cc:	89 d0                	mov    %edx,%eax
  8008ce:	c1 e0 10             	shl    $0x10,%eax
  8008d1:	09 f0                	or     %esi,%eax
  8008d3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	09 d0                	or     %edx,%eax
  8008d9:	c1 e9 02             	shr    $0x2,%ecx
  8008dc:	fc                   	cld    
  8008dd:	f3 ab                	rep stos %eax,%es:(%edi)
  8008df:	eb 06                	jmp    8008e7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	fc                   	cld    
  8008e5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	57                   	push   %edi
  8008f2:	56                   	push   %esi
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fc:	39 c6                	cmp    %eax,%esi
  8008fe:	73 35                	jae    800935 <memmove+0x47>
  800900:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800903:	39 d0                	cmp    %edx,%eax
  800905:	73 2e                	jae    800935 <memmove+0x47>
		s += n;
		d += n;
  800907:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090a:	89 d6                	mov    %edx,%esi
  80090c:	09 fe                	or     %edi,%esi
  80090e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800914:	75 13                	jne    800929 <memmove+0x3b>
  800916:	f6 c1 03             	test   $0x3,%cl
  800919:	75 0e                	jne    800929 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091b:	83 ef 04             	sub    $0x4,%edi
  80091e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800921:	c1 e9 02             	shr    $0x2,%ecx
  800924:	fd                   	std    
  800925:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800927:	eb 09                	jmp    800932 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800929:	83 ef 01             	sub    $0x1,%edi
  80092c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092f:	fd                   	std    
  800930:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800932:	fc                   	cld    
  800933:	eb 1d                	jmp    800952 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800935:	89 f2                	mov    %esi,%edx
  800937:	09 c2                	or     %eax,%edx
  800939:	f6 c2 03             	test   $0x3,%dl
  80093c:	75 0f                	jne    80094d <memmove+0x5f>
  80093e:	f6 c1 03             	test   $0x3,%cl
  800941:	75 0a                	jne    80094d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800943:	c1 e9 02             	shr    $0x2,%ecx
  800946:	89 c7                	mov    %eax,%edi
  800948:	fc                   	cld    
  800949:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094b:	eb 05                	jmp    800952 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	fc                   	cld    
  800950:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800952:	5e                   	pop    %esi
  800953:	5f                   	pop    %edi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800959:	ff 75 10             	pushl  0x10(%ebp)
  80095c:	ff 75 0c             	pushl  0xc(%ebp)
  80095f:	ff 75 08             	pushl  0x8(%ebp)
  800962:	e8 87 ff ff ff       	call   8008ee <memmove>
}
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
  800974:	89 c6                	mov    %eax,%esi
  800976:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800979:	eb 1a                	jmp    800995 <memcmp+0x2c>
		if (*s1 != *s2)
  80097b:	0f b6 08             	movzbl (%eax),%ecx
  80097e:	0f b6 1a             	movzbl (%edx),%ebx
  800981:	38 d9                	cmp    %bl,%cl
  800983:	74 0a                	je     80098f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800985:	0f b6 c1             	movzbl %cl,%eax
  800988:	0f b6 db             	movzbl %bl,%ebx
  80098b:	29 d8                	sub    %ebx,%eax
  80098d:	eb 0f                	jmp    80099e <memcmp+0x35>
		s1++, s2++;
  80098f:	83 c0 01             	add    $0x1,%eax
  800992:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800995:	39 f0                	cmp    %esi,%eax
  800997:	75 e2                	jne    80097b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099e:	5b                   	pop    %ebx
  80099f:	5e                   	pop    %esi
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a9:	89 c1                	mov    %eax,%ecx
  8009ab:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ae:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b2:	eb 0a                	jmp    8009be <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b4:	0f b6 10             	movzbl (%eax),%edx
  8009b7:	39 da                	cmp    %ebx,%edx
  8009b9:	74 07                	je     8009c2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	39 c8                	cmp    %ecx,%eax
  8009c0:	72 f2                	jb     8009b4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	57                   	push   %edi
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d1:	eb 03                	jmp    8009d6 <strtol+0x11>
		s++;
  8009d3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d6:	0f b6 01             	movzbl (%ecx),%eax
  8009d9:	3c 20                	cmp    $0x20,%al
  8009db:	74 f6                	je     8009d3 <strtol+0xe>
  8009dd:	3c 09                	cmp    $0x9,%al
  8009df:	74 f2                	je     8009d3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e1:	3c 2b                	cmp    $0x2b,%al
  8009e3:	75 0a                	jne    8009ef <strtol+0x2a>
		s++;
  8009e5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ed:	eb 11                	jmp    800a00 <strtol+0x3b>
  8009ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f4:	3c 2d                	cmp    $0x2d,%al
  8009f6:	75 08                	jne    800a00 <strtol+0x3b>
		s++, neg = 1;
  8009f8:	83 c1 01             	add    $0x1,%ecx
  8009fb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a00:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a06:	75 15                	jne    800a1d <strtol+0x58>
  800a08:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0b:	75 10                	jne    800a1d <strtol+0x58>
  800a0d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a11:	75 7c                	jne    800a8f <strtol+0xca>
		s += 2, base = 16;
  800a13:	83 c1 02             	add    $0x2,%ecx
  800a16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1b:	eb 16                	jmp    800a33 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1d:	85 db                	test   %ebx,%ebx
  800a1f:	75 12                	jne    800a33 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a21:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a26:	80 39 30             	cmpb   $0x30,(%ecx)
  800a29:	75 08                	jne    800a33 <strtol+0x6e>
		s++, base = 8;
  800a2b:	83 c1 01             	add    $0x1,%ecx
  800a2e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a33:	b8 00 00 00 00       	mov    $0x0,%eax
  800a38:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3b:	0f b6 11             	movzbl (%ecx),%edx
  800a3e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a41:	89 f3                	mov    %esi,%ebx
  800a43:	80 fb 09             	cmp    $0x9,%bl
  800a46:	77 08                	ja     800a50 <strtol+0x8b>
			dig = *s - '0';
  800a48:	0f be d2             	movsbl %dl,%edx
  800a4b:	83 ea 30             	sub    $0x30,%edx
  800a4e:	eb 22                	jmp    800a72 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a50:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a53:	89 f3                	mov    %esi,%ebx
  800a55:	80 fb 19             	cmp    $0x19,%bl
  800a58:	77 08                	ja     800a62 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5a:	0f be d2             	movsbl %dl,%edx
  800a5d:	83 ea 57             	sub    $0x57,%edx
  800a60:	eb 10                	jmp    800a72 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a62:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 16                	ja     800a82 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a75:	7d 0b                	jge    800a82 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a80:	eb b9                	jmp    800a3b <strtol+0x76>

	if (endptr)
  800a82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a86:	74 0d                	je     800a95 <strtol+0xd0>
		*endptr = (char *) s;
  800a88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8b:	89 0e                	mov    %ecx,(%esi)
  800a8d:	eb 06                	jmp    800a95 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8f:	85 db                	test   %ebx,%ebx
  800a91:	74 98                	je     800a2b <strtol+0x66>
  800a93:	eb 9e                	jmp    800a33 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	f7 da                	neg    %edx
  800a99:	85 ff                	test   %edi,%edi
  800a9b:	0f 45 c2             	cmovne %edx,%eax
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab4:	89 c3                	mov    %eax,%ebx
  800ab6:	89 c7                	mov    %eax,%edi
  800ab8:	89 c6                	mov    %eax,%esi
  800aba:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  800acc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad1:	89 d1                	mov    %edx,%ecx
  800ad3:	89 d3                	mov    %edx,%ebx
  800ad5:	89 d7                	mov    %edx,%edi
  800ad7:	89 d6                	mov    %edx,%esi
  800ad9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	57                   	push   %edi
  800ae4:	56                   	push   %esi
  800ae5:	53                   	push   %ebx
  800ae6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ae9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aee:	b8 03 00 00 00       	mov    $0x3,%eax
  800af3:	8b 55 08             	mov    0x8(%ebp),%edx
  800af6:	89 cb                	mov    %ecx,%ebx
  800af8:	89 cf                	mov    %ecx,%edi
  800afa:	89 ce                	mov    %ecx,%esi
  800afc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800afe:	85 c0                	test   %eax,%eax
  800b00:	7e 17                	jle    800b19 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	50                   	push   %eax
  800b06:	6a 03                	push   $0x3
  800b08:	68 9f 21 80 00       	push   $0x80219f
  800b0d:	6a 23                	push   $0x23
  800b0f:	68 bc 21 80 00       	push   $0x8021bc
  800b14:	e8 1a 0f 00 00       	call   801a33 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b31:	89 d1                	mov    %edx,%ecx
  800b33:	89 d3                	mov    %edx,%ebx
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_yield>:

void
sys_yield(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b68:	be 00 00 00 00       	mov    $0x0,%esi
  800b6d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
  800b78:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7b:	89 f7                	mov    %esi,%edi
  800b7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	7e 17                	jle    800b9a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	50                   	push   %eax
  800b87:	6a 04                	push   $0x4
  800b89:	68 9f 21 80 00       	push   $0x80219f
  800b8e:	6a 23                	push   $0x23
  800b90:	68 bc 21 80 00       	push   $0x8021bc
  800b95:	e8 99 0e 00 00       	call   801a33 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
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
  800bab:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbc:	8b 75 18             	mov    0x18(%ebp),%esi
  800bbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bc1:	85 c0                	test   %eax,%eax
  800bc3:	7e 17                	jle    800bdc <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	50                   	push   %eax
  800bc9:	6a 05                	push   $0x5
  800bcb:	68 9f 21 80 00       	push   $0x80219f
  800bd0:	6a 23                	push   $0x23
  800bd2:	68 bc 21 80 00       	push   $0x8021bc
  800bd7:	e8 57 0e 00 00       	call   801a33 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdf:	5b                   	pop    %ebx
  800be0:	5e                   	pop    %esi
  800be1:	5f                   	pop    %edi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800bf2:	b8 06 00 00 00       	mov    $0x6,%eax
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
  800c05:	7e 17                	jle    800c1e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	50                   	push   %eax
  800c0b:	6a 06                	push   $0x6
  800c0d:	68 9f 21 80 00       	push   $0x80219f
  800c12:	6a 23                	push   $0x23
  800c14:	68 bc 21 80 00       	push   $0x8021bc
  800c19:	e8 15 0e 00 00       	call   801a33 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c34:	b8 08 00 00 00       	mov    $0x8,%eax
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
  800c47:	7e 17                	jle    800c60 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 08                	push   $0x8
  800c4f:	68 9f 21 80 00       	push   $0x80219f
  800c54:	6a 23                	push   $0x23
  800c56:	68 bc 21 80 00       	push   $0x8021bc
  800c5b:	e8 d3 0d 00 00       	call   801a33 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c76:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	89 df                	mov    %ebx,%edi
  800c83:	89 de                	mov    %ebx,%esi
  800c85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c87:	85 c0                	test   %eax,%eax
  800c89:	7e 17                	jle    800ca2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8b:	83 ec 0c             	sub    $0xc,%esp
  800c8e:	50                   	push   %eax
  800c8f:	6a 09                	push   $0x9
  800c91:	68 9f 21 80 00       	push   $0x80219f
  800c96:	6a 23                	push   $0x23
  800c98:	68 bc 21 80 00       	push   $0x8021bc
  800c9d:	e8 91 0d 00 00       	call   801a33 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
  800cb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc3:	89 df                	mov    %ebx,%edi
  800cc5:	89 de                	mov    %ebx,%esi
  800cc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7e 17                	jle    800ce4 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccd:	83 ec 0c             	sub    $0xc,%esp
  800cd0:	50                   	push   %eax
  800cd1:	6a 0a                	push   $0xa
  800cd3:	68 9f 21 80 00       	push   $0x80219f
  800cd8:	6a 23                	push   $0x23
  800cda:	68 bc 21 80 00       	push   $0x8021bc
  800cdf:	e8 4f 0d 00 00       	call   801a33 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cf2:	be 00 00 00 00       	mov    $0x0,%esi
  800cf7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d05:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d08:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 cb                	mov    %ecx,%ebx
  800d27:	89 cf                	mov    %ecx,%edi
  800d29:	89 ce                	mov    %ecx,%esi
  800d2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 0d                	push   $0xd
  800d37:	68 9f 21 80 00       	push   $0x80219f
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 bc 21 80 00       	push   $0x8021bc
  800d43:	e8 eb 0c 00 00       	call   801a33 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	05 00 00 00 30       	add    $0x30000000,%eax
  800d5b:	c1 e8 0c             	shr    $0xc,%eax
}
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	05 00 00 00 30       	add    $0x30000000,%eax
  800d6b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d70:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	c1 ea 16             	shr    $0x16,%edx
  800d87:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d8e:	f6 c2 01             	test   $0x1,%dl
  800d91:	74 11                	je     800da4 <fd_alloc+0x2d>
  800d93:	89 c2                	mov    %eax,%edx
  800d95:	c1 ea 0c             	shr    $0xc,%edx
  800d98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9f:	f6 c2 01             	test   $0x1,%dl
  800da2:	75 09                	jne    800dad <fd_alloc+0x36>
			*fd_store = fd;
  800da4:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dab:	eb 17                	jmp    800dc4 <fd_alloc+0x4d>
  800dad:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800db2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db7:	75 c9                	jne    800d82 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dbf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dcc:	83 f8 1f             	cmp    $0x1f,%eax
  800dcf:	77 36                	ja     800e07 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd1:	c1 e0 0c             	shl    $0xc,%eax
  800dd4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd9:	89 c2                	mov    %eax,%edx
  800ddb:	c1 ea 16             	shr    $0x16,%edx
  800dde:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de5:	f6 c2 01             	test   $0x1,%dl
  800de8:	74 24                	je     800e0e <fd_lookup+0x48>
  800dea:	89 c2                	mov    %eax,%edx
  800dec:	c1 ea 0c             	shr    $0xc,%edx
  800def:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df6:	f6 c2 01             	test   $0x1,%dl
  800df9:	74 1a                	je     800e15 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfe:	89 02                	mov    %eax,(%edx)
	return 0;
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	eb 13                	jmp    800e1a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0c:	eb 0c                	jmp    800e1a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e13:	eb 05                	jmp    800e1a <fd_lookup+0x54>
  800e15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    

00800e1c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 08             	sub    $0x8,%esp
  800e22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e25:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e2a:	eb 13                	jmp    800e3f <dev_lookup+0x23>
  800e2c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e2f:	39 08                	cmp    %ecx,(%eax)
  800e31:	75 0c                	jne    800e3f <dev_lookup+0x23>
			*dev = devtab[i];
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e36:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e38:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3d:	eb 2e                	jmp    800e6d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3f:	8b 02                	mov    (%edx),%eax
  800e41:	85 c0                	test   %eax,%eax
  800e43:	75 e7                	jne    800e2c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e45:	a1 04 40 80 00       	mov    0x804004,%eax
  800e4a:	8b 40 48             	mov    0x48(%eax),%eax
  800e4d:	83 ec 04             	sub    $0x4,%esp
  800e50:	51                   	push   %ecx
  800e51:	50                   	push   %eax
  800e52:	68 cc 21 80 00       	push   $0x8021cc
  800e57:	e8 31 f3 ff ff       	call   80018d <cprintf>
	*dev = 0;
  800e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e65:	83 c4 10             	add    $0x10,%esp
  800e68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 10             	sub    $0x10,%esp
  800e77:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e80:	50                   	push   %eax
  800e81:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e87:	c1 e8 0c             	shr    $0xc,%eax
  800e8a:	50                   	push   %eax
  800e8b:	e8 36 ff ff ff       	call   800dc6 <fd_lookup>
  800e90:	83 c4 08             	add    $0x8,%esp
  800e93:	85 c0                	test   %eax,%eax
  800e95:	78 05                	js     800e9c <fd_close+0x2d>
	    || fd != fd2)
  800e97:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e9a:	74 0c                	je     800ea8 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e9c:	84 db                	test   %bl,%bl
  800e9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea3:	0f 44 c2             	cmove  %edx,%eax
  800ea6:	eb 41                	jmp    800ee9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eae:	50                   	push   %eax
  800eaf:	ff 36                	pushl  (%esi)
  800eb1:	e8 66 ff ff ff       	call   800e1c <dev_lookup>
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 1a                	js     800ed9 <fd_close+0x6a>
		if (dev->dev_close)
  800ebf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eca:	85 c0                	test   %eax,%eax
  800ecc:	74 0b                	je     800ed9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ece:	83 ec 0c             	sub    $0xc,%esp
  800ed1:	56                   	push   %esi
  800ed2:	ff d0                	call   *%eax
  800ed4:	89 c3                	mov    %eax,%ebx
  800ed6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	56                   	push   %esi
  800edd:	6a 00                	push   $0x0
  800edf:	e8 00 fd ff ff       	call   800be4 <sys_page_unmap>
	return r;
  800ee4:	83 c4 10             	add    $0x10,%esp
  800ee7:	89 d8                	mov    %ebx,%eax
}
  800ee9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eec:	5b                   	pop    %ebx
  800eed:	5e                   	pop    %esi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef9:	50                   	push   %eax
  800efa:	ff 75 08             	pushl  0x8(%ebp)
  800efd:	e8 c4 fe ff ff       	call   800dc6 <fd_lookup>
  800f02:	83 c4 08             	add    $0x8,%esp
  800f05:	85 c0                	test   %eax,%eax
  800f07:	78 10                	js     800f19 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f09:	83 ec 08             	sub    $0x8,%esp
  800f0c:	6a 01                	push   $0x1
  800f0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f11:	e8 59 ff ff ff       	call   800e6f <fd_close>
  800f16:	83 c4 10             	add    $0x10,%esp
}
  800f19:	c9                   	leave  
  800f1a:	c3                   	ret    

00800f1b <close_all>:

void
close_all(void)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	e8 c0 ff ff ff       	call   800ef0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f30:	83 c3 01             	add    $0x1,%ebx
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	83 fb 20             	cmp    $0x20,%ebx
  800f39:	75 ec                	jne    800f27 <close_all+0xc>
		close(i);
}
  800f3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f3e:	c9                   	leave  
  800f3f:	c3                   	ret    

00800f40 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	83 ec 2c             	sub    $0x2c,%esp
  800f49:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f4c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	ff 75 08             	pushl  0x8(%ebp)
  800f53:	e8 6e fe ff ff       	call   800dc6 <fd_lookup>
  800f58:	83 c4 08             	add    $0x8,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	0f 88 c1 00 00 00    	js     801024 <dup+0xe4>
		return r;
	close(newfdnum);
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	56                   	push   %esi
  800f67:	e8 84 ff ff ff       	call   800ef0 <close>

	newfd = INDEX2FD(newfdnum);
  800f6c:	89 f3                	mov    %esi,%ebx
  800f6e:	c1 e3 0c             	shl    $0xc,%ebx
  800f71:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f77:	83 c4 04             	add    $0x4,%esp
  800f7a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7d:	e8 de fd ff ff       	call   800d60 <fd2data>
  800f82:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f84:	89 1c 24             	mov    %ebx,(%esp)
  800f87:	e8 d4 fd ff ff       	call   800d60 <fd2data>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f92:	89 f8                	mov    %edi,%eax
  800f94:	c1 e8 16             	shr    $0x16,%eax
  800f97:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9e:	a8 01                	test   $0x1,%al
  800fa0:	74 37                	je     800fd9 <dup+0x99>
  800fa2:	89 f8                	mov    %edi,%eax
  800fa4:	c1 e8 0c             	shr    $0xc,%eax
  800fa7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fae:	f6 c2 01             	test   $0x1,%dl
  800fb1:	74 26                	je     800fd9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	25 07 0e 00 00       	and    $0xe07,%eax
  800fc2:	50                   	push   %eax
  800fc3:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc6:	6a 00                	push   $0x0
  800fc8:	57                   	push   %edi
  800fc9:	6a 00                	push   $0x0
  800fcb:	e8 d2 fb ff ff       	call   800ba2 <sys_page_map>
  800fd0:	89 c7                	mov    %eax,%edi
  800fd2:	83 c4 20             	add    $0x20,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	78 2e                	js     801007 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fdc:	89 d0                	mov    %edx,%eax
  800fde:	c1 e8 0c             	shr    $0xc,%eax
  800fe1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe8:	83 ec 0c             	sub    $0xc,%esp
  800feb:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff0:	50                   	push   %eax
  800ff1:	53                   	push   %ebx
  800ff2:	6a 00                	push   $0x0
  800ff4:	52                   	push   %edx
  800ff5:	6a 00                	push   $0x0
  800ff7:	e8 a6 fb ff ff       	call   800ba2 <sys_page_map>
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801001:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801003:	85 ff                	test   %edi,%edi
  801005:	79 1d                	jns    801024 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801007:	83 ec 08             	sub    $0x8,%esp
  80100a:	53                   	push   %ebx
  80100b:	6a 00                	push   $0x0
  80100d:	e8 d2 fb ff ff       	call   800be4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801012:	83 c4 08             	add    $0x8,%esp
  801015:	ff 75 d4             	pushl  -0x2c(%ebp)
  801018:	6a 00                	push   $0x0
  80101a:	e8 c5 fb ff ff       	call   800be4 <sys_page_unmap>
	return r;
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	89 f8                	mov    %edi,%eax
}
  801024:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    

0080102c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	53                   	push   %ebx
  801030:	83 ec 14             	sub    $0x14,%esp
  801033:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801036:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801039:	50                   	push   %eax
  80103a:	53                   	push   %ebx
  80103b:	e8 86 fd ff ff       	call   800dc6 <fd_lookup>
  801040:	83 c4 08             	add    $0x8,%esp
  801043:	89 c2                	mov    %eax,%edx
  801045:	85 c0                	test   %eax,%eax
  801047:	78 6d                	js     8010b6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801049:	83 ec 08             	sub    $0x8,%esp
  80104c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104f:	50                   	push   %eax
  801050:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801053:	ff 30                	pushl  (%eax)
  801055:	e8 c2 fd ff ff       	call   800e1c <dev_lookup>
  80105a:	83 c4 10             	add    $0x10,%esp
  80105d:	85 c0                	test   %eax,%eax
  80105f:	78 4c                	js     8010ad <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801061:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801064:	8b 42 08             	mov    0x8(%edx),%eax
  801067:	83 e0 03             	and    $0x3,%eax
  80106a:	83 f8 01             	cmp    $0x1,%eax
  80106d:	75 21                	jne    801090 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106f:	a1 04 40 80 00       	mov    0x804004,%eax
  801074:	8b 40 48             	mov    0x48(%eax),%eax
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	53                   	push   %ebx
  80107b:	50                   	push   %eax
  80107c:	68 0d 22 80 00       	push   $0x80220d
  801081:	e8 07 f1 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  801086:	83 c4 10             	add    $0x10,%esp
  801089:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80108e:	eb 26                	jmp    8010b6 <read+0x8a>
	}
	if (!dev->dev_read)
  801090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801093:	8b 40 08             	mov    0x8(%eax),%eax
  801096:	85 c0                	test   %eax,%eax
  801098:	74 17                	je     8010b1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	ff 75 10             	pushl  0x10(%ebp)
  8010a0:	ff 75 0c             	pushl  0xc(%ebp)
  8010a3:	52                   	push   %edx
  8010a4:	ff d0                	call   *%eax
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	eb 09                	jmp    8010b6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	eb 05                	jmp    8010b6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010b6:	89 d0                	mov    %edx,%eax
  8010b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bb:	c9                   	leave  
  8010bc:	c3                   	ret    

008010bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	57                   	push   %edi
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
  8010c3:	83 ec 0c             	sub    $0xc,%esp
  8010c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d1:	eb 21                	jmp    8010f4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	89 f0                	mov    %esi,%eax
  8010d8:	29 d8                	sub    %ebx,%eax
  8010da:	50                   	push   %eax
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	03 45 0c             	add    0xc(%ebp),%eax
  8010e0:	50                   	push   %eax
  8010e1:	57                   	push   %edi
  8010e2:	e8 45 ff ff ff       	call   80102c <read>
		if (m < 0)
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	78 10                	js     8010fe <readn+0x41>
			return m;
		if (m == 0)
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	74 0a                	je     8010fc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f2:	01 c3                	add    %eax,%ebx
  8010f4:	39 f3                	cmp    %esi,%ebx
  8010f6:	72 db                	jb     8010d3 <readn+0x16>
  8010f8:	89 d8                	mov    %ebx,%eax
  8010fa:	eb 02                	jmp    8010fe <readn+0x41>
  8010fc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5f                   	pop    %edi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	53                   	push   %ebx
  80110a:	83 ec 14             	sub    $0x14,%esp
  80110d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801110:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801113:	50                   	push   %eax
  801114:	53                   	push   %ebx
  801115:	e8 ac fc ff ff       	call   800dc6 <fd_lookup>
  80111a:	83 c4 08             	add    $0x8,%esp
  80111d:	89 c2                	mov    %eax,%edx
  80111f:	85 c0                	test   %eax,%eax
  801121:	78 68                	js     80118b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80112d:	ff 30                	pushl  (%eax)
  80112f:	e8 e8 fc ff ff       	call   800e1c <dev_lookup>
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	85 c0                	test   %eax,%eax
  801139:	78 47                	js     801182 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80113b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80113e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801142:	75 21                	jne    801165 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801144:	a1 04 40 80 00       	mov    0x804004,%eax
  801149:	8b 40 48             	mov    0x48(%eax),%eax
  80114c:	83 ec 04             	sub    $0x4,%esp
  80114f:	53                   	push   %ebx
  801150:	50                   	push   %eax
  801151:	68 29 22 80 00       	push   $0x802229
  801156:	e8 32 f0 ff ff       	call   80018d <cprintf>
		return -E_INVAL;
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801163:	eb 26                	jmp    80118b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801165:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801168:	8b 52 0c             	mov    0xc(%edx),%edx
  80116b:	85 d2                	test   %edx,%edx
  80116d:	74 17                	je     801186 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 10             	pushl  0x10(%ebp)
  801175:	ff 75 0c             	pushl  0xc(%ebp)
  801178:	50                   	push   %eax
  801179:	ff d2                	call   *%edx
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	eb 09                	jmp    80118b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801182:	89 c2                	mov    %eax,%edx
  801184:	eb 05                	jmp    80118b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801186:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80118b:	89 d0                	mov    %edx,%eax
  80118d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801190:	c9                   	leave  
  801191:	c3                   	ret    

00801192 <seek>:

int
seek(int fdnum, off_t offset)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801198:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	ff 75 08             	pushl  0x8(%ebp)
  80119f:	e8 22 fc ff ff       	call   800dc6 <fd_lookup>
  8011a4:	83 c4 08             	add    $0x8,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	78 0e                	js     8011b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011ab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b9:	c9                   	leave  
  8011ba:	c3                   	ret    

008011bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 14             	sub    $0x14,%esp
  8011c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	53                   	push   %ebx
  8011ca:	e8 f7 fb ff ff       	call   800dc6 <fd_lookup>
  8011cf:	83 c4 08             	add    $0x8,%esp
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 65                	js     80123d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	ff 30                	pushl  (%eax)
  8011e4:	e8 33 fc ff ff       	call   800e1c <dev_lookup>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 44                	js     801234 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f7:	75 21                	jne    80121a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011fe:	8b 40 48             	mov    0x48(%eax),%eax
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	53                   	push   %ebx
  801205:	50                   	push   %eax
  801206:	68 ec 21 80 00       	push   $0x8021ec
  80120b:	e8 7d ef ff ff       	call   80018d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801218:	eb 23                	jmp    80123d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80121a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121d:	8b 52 18             	mov    0x18(%edx),%edx
  801220:	85 d2                	test   %edx,%edx
  801222:	74 14                	je     801238 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	ff 75 0c             	pushl  0xc(%ebp)
  80122a:	50                   	push   %eax
  80122b:	ff d2                	call   *%edx
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	83 c4 10             	add    $0x10,%esp
  801232:	eb 09                	jmp    80123d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	89 c2                	mov    %eax,%edx
  801236:	eb 05                	jmp    80123d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801238:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80123d:	89 d0                	mov    %edx,%eax
  80123f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801242:	c9                   	leave  
  801243:	c3                   	ret    

00801244 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801244:	55                   	push   %ebp
  801245:	89 e5                	mov    %esp,%ebp
  801247:	53                   	push   %ebx
  801248:	83 ec 14             	sub    $0x14,%esp
  80124b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801251:	50                   	push   %eax
  801252:	ff 75 08             	pushl  0x8(%ebp)
  801255:	e8 6c fb ff ff       	call   800dc6 <fd_lookup>
  80125a:	83 c4 08             	add    $0x8,%esp
  80125d:	89 c2                	mov    %eax,%edx
  80125f:	85 c0                	test   %eax,%eax
  801261:	78 58                	js     8012bb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801269:	50                   	push   %eax
  80126a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126d:	ff 30                	pushl  (%eax)
  80126f:	e8 a8 fb ff ff       	call   800e1c <dev_lookup>
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	85 c0                	test   %eax,%eax
  801279:	78 37                	js     8012b2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80127b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801282:	74 32                	je     8012b6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801284:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801287:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128e:	00 00 00 
	stat->st_isdir = 0;
  801291:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801298:	00 00 00 
	stat->st_dev = dev;
  80129b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	53                   	push   %ebx
  8012a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a8:	ff 50 14             	call   *0x14(%eax)
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	83 c4 10             	add    $0x10,%esp
  8012b0:	eb 09                	jmp    8012bb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b2:	89 c2                	mov    %eax,%edx
  8012b4:	eb 05                	jmp    8012bb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012bb:	89 d0                	mov    %edx,%eax
  8012bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	56                   	push   %esi
  8012c6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	6a 00                	push   $0x0
  8012cc:	ff 75 08             	pushl  0x8(%ebp)
  8012cf:	e8 dc 01 00 00       	call   8014b0 <open>
  8012d4:	89 c3                	mov    %eax,%ebx
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 1b                	js     8012f8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	ff 75 0c             	pushl  0xc(%ebp)
  8012e3:	50                   	push   %eax
  8012e4:	e8 5b ff ff ff       	call   801244 <fstat>
  8012e9:	89 c6                	mov    %eax,%esi
	close(fd);
  8012eb:	89 1c 24             	mov    %ebx,(%esp)
  8012ee:	e8 fd fb ff ff       	call   800ef0 <close>
	return r;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	89 f0                	mov    %esi,%eax
}
  8012f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	89 c6                	mov    %eax,%esi
  801306:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801308:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130f:	75 12                	jne    801323 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801311:	83 ec 0c             	sub    $0xc,%esp
  801314:	6a 01                	push   $0x1
  801316:	e8 fe 07 00 00       	call   801b19 <ipc_find_env>
  80131b:	a3 00 40 80 00       	mov    %eax,0x804000
  801320:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801323:	6a 07                	push   $0x7
  801325:	68 00 50 80 00       	push   $0x805000
  80132a:	56                   	push   %esi
  80132b:	ff 35 00 40 80 00    	pushl  0x804000
  801331:	e8 a0 07 00 00       	call   801ad6 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801336:	83 c4 0c             	add    $0xc,%esp
  801339:	6a 00                	push   $0x0
  80133b:	53                   	push   %ebx
  80133c:	6a 00                	push   $0x0
  80133e:	e8 36 07 00 00       	call   801a79 <ipc_recv>
}
  801343:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801346:	5b                   	pop    %ebx
  801347:	5e                   	pop    %esi
  801348:	5d                   	pop    %ebp
  801349:	c3                   	ret    

0080134a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80134a:	55                   	push   %ebp
  80134b:	89 e5                	mov    %esp,%ebp
  80134d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801350:	8b 45 08             	mov    0x8(%ebp),%eax
  801353:	8b 40 0c             	mov    0xc(%eax),%eax
  801356:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80135b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801363:	ba 00 00 00 00       	mov    $0x0,%edx
  801368:	b8 02 00 00 00       	mov    $0x2,%eax
  80136d:	e8 8d ff ff ff       	call   8012ff <fsipc>
}
  801372:	c9                   	leave  
  801373:	c3                   	ret    

00801374 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	8b 40 0c             	mov    0xc(%eax),%eax
  801380:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801385:	ba 00 00 00 00       	mov    $0x0,%edx
  80138a:	b8 06 00 00 00       	mov    $0x6,%eax
  80138f:	e8 6b ff ff ff       	call   8012ff <fsipc>
}
  801394:	c9                   	leave  
  801395:	c3                   	ret    

00801396 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
  801399:	53                   	push   %ebx
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b5:	e8 45 ff ff ff       	call   8012ff <fsipc>
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 2c                	js     8013ea <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	68 00 50 80 00       	push   $0x805000
  8013c6:	53                   	push   %ebx
  8013c7:	e8 90 f3 ff ff       	call   80075c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8013dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fb:	8b 52 0c             	mov    0xc(%edx),%edx
  8013fe:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801404:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801409:	50                   	push   %eax
  80140a:	ff 75 0c             	pushl  0xc(%ebp)
  80140d:	68 08 50 80 00       	push   $0x805008
  801412:	e8 d7 f4 ff ff       	call   8008ee <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801417:	ba 00 00 00 00       	mov    $0x0,%edx
  80141c:	b8 04 00 00 00       	mov    $0x4,%eax
  801421:	e8 d9 fe ff ff       	call   8012ff <fsipc>
	//panic("devfile_write not implemented");
}
  801426:	c9                   	leave  
  801427:	c3                   	ret    

00801428 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	56                   	push   %esi
  80142c:	53                   	push   %ebx
  80142d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	8b 40 0c             	mov    0xc(%eax),%eax
  801436:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80143b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 03 00 00 00       	mov    $0x3,%eax
  80144b:	e8 af fe ff ff       	call   8012ff <fsipc>
  801450:	89 c3                	mov    %eax,%ebx
  801452:	85 c0                	test   %eax,%eax
  801454:	78 51                	js     8014a7 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801456:	39 c6                	cmp    %eax,%esi
  801458:	73 19                	jae    801473 <devfile_read+0x4b>
  80145a:	68 58 22 80 00       	push   $0x802258
  80145f:	68 5f 22 80 00       	push   $0x80225f
  801464:	68 80 00 00 00       	push   $0x80
  801469:	68 74 22 80 00       	push   $0x802274
  80146e:	e8 c0 05 00 00       	call   801a33 <_panic>
	assert(r <= PGSIZE);
  801473:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801478:	7e 19                	jle    801493 <devfile_read+0x6b>
  80147a:	68 7f 22 80 00       	push   $0x80227f
  80147f:	68 5f 22 80 00       	push   $0x80225f
  801484:	68 81 00 00 00       	push   $0x81
  801489:	68 74 22 80 00       	push   $0x802274
  80148e:	e8 a0 05 00 00       	call   801a33 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801493:	83 ec 04             	sub    $0x4,%esp
  801496:	50                   	push   %eax
  801497:	68 00 50 80 00       	push   $0x805000
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	e8 4a f4 ff ff       	call   8008ee <memmove>
	return r;
  8014a4:	83 c4 10             	add    $0x10,%esp
}
  8014a7:	89 d8                	mov    %ebx,%eax
  8014a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ac:	5b                   	pop    %ebx
  8014ad:	5e                   	pop    %esi
  8014ae:	5d                   	pop    %ebp
  8014af:	c3                   	ret    

008014b0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 20             	sub    $0x20,%esp
  8014b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014ba:	53                   	push   %ebx
  8014bb:	e8 63 f2 ff ff       	call   800723 <strlen>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c8:	7f 67                	jg     801531 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ca:	83 ec 0c             	sub    $0xc,%esp
  8014cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d0:	50                   	push   %eax
  8014d1:	e8 a1 f8 ff ff       	call   800d77 <fd_alloc>
  8014d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8014d9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 57                	js     801536 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	53                   	push   %ebx
  8014e3:	68 00 50 80 00       	push   $0x805000
  8014e8:	e8 6f f2 ff ff       	call   80075c <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f0:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fd:	e8 fd fd ff ff       	call   8012ff <fsipc>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	79 14                	jns    80151f <open+0x6f>
		
		fd_close(fd, 0);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	6a 00                	push   $0x0
  801510:	ff 75 f4             	pushl  -0xc(%ebp)
  801513:	e8 57 f9 ff ff       	call   800e6f <fd_close>
		return r;
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	89 da                	mov    %ebx,%edx
  80151d:	eb 17                	jmp    801536 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	ff 75 f4             	pushl  -0xc(%ebp)
  801525:	e8 26 f8 ff ff       	call   800d50 <fd2num>
  80152a:	89 c2                	mov    %eax,%edx
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 05                	jmp    801536 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801531:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801536:	89 d0                	mov    %edx,%eax
  801538:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801543:	ba 00 00 00 00       	mov    $0x0,%edx
  801548:	b8 08 00 00 00       	mov    $0x8,%eax
  80154d:	e8 ad fd ff ff       	call   8012ff <fsipc>
}
  801552:	c9                   	leave  
  801553:	c3                   	ret    

00801554 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	56                   	push   %esi
  801558:	53                   	push   %ebx
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80155c:	83 ec 0c             	sub    $0xc,%esp
  80155f:	ff 75 08             	pushl  0x8(%ebp)
  801562:	e8 f9 f7 ff ff       	call   800d60 <fd2data>
  801567:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801569:	83 c4 08             	add    $0x8,%esp
  80156c:	68 8b 22 80 00       	push   $0x80228b
  801571:	53                   	push   %ebx
  801572:	e8 e5 f1 ff ff       	call   80075c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801577:	8b 46 04             	mov    0x4(%esi),%eax
  80157a:	2b 06                	sub    (%esi),%eax
  80157c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801582:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801589:	00 00 00 
	stat->st_dev = &devpipe;
  80158c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801593:	30 80 00 
	return 0;
}
  801596:	b8 00 00 00 00       	mov    $0x0,%eax
  80159b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5e                   	pop    %esi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 0c             	sub    $0xc,%esp
  8015a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015ac:	53                   	push   %ebx
  8015ad:	6a 00                	push   $0x0
  8015af:	e8 30 f6 ff ff       	call   800be4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b4:	89 1c 24             	mov    %ebx,(%esp)
  8015b7:	e8 a4 f7 ff ff       	call   800d60 <fd2data>
  8015bc:	83 c4 08             	add    $0x8,%esp
  8015bf:	50                   	push   %eax
  8015c0:	6a 00                	push   $0x0
  8015c2:	e8 1d f6 ff ff       	call   800be4 <sys_page_unmap>
}
  8015c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 1c             	sub    $0x1c,%esp
  8015d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015d8:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015da:	a1 04 40 80 00       	mov    0x804004,%eax
  8015df:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015e2:	83 ec 0c             	sub    $0xc,%esp
  8015e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e8:	e8 65 05 00 00       	call   801b52 <pageref>
  8015ed:	89 c3                	mov    %eax,%ebx
  8015ef:	89 3c 24             	mov    %edi,(%esp)
  8015f2:	e8 5b 05 00 00       	call   801b52 <pageref>
  8015f7:	83 c4 10             	add    $0x10,%esp
  8015fa:	39 c3                	cmp    %eax,%ebx
  8015fc:	0f 94 c1             	sete   %cl
  8015ff:	0f b6 c9             	movzbl %cl,%ecx
  801602:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801605:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80160b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80160e:	39 ce                	cmp    %ecx,%esi
  801610:	74 1b                	je     80162d <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801612:	39 c3                	cmp    %eax,%ebx
  801614:	75 c4                	jne    8015da <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801616:	8b 42 58             	mov    0x58(%edx),%eax
  801619:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161c:	50                   	push   %eax
  80161d:	56                   	push   %esi
  80161e:	68 92 22 80 00       	push   $0x802292
  801623:	e8 65 eb ff ff       	call   80018d <cprintf>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb ad                	jmp    8015da <_pipeisclosed+0xe>
	}
}
  80162d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801630:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801633:	5b                   	pop    %ebx
  801634:	5e                   	pop    %esi
  801635:	5f                   	pop    %edi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	57                   	push   %edi
  80163c:	56                   	push   %esi
  80163d:	53                   	push   %ebx
  80163e:	83 ec 28             	sub    $0x28,%esp
  801641:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801644:	56                   	push   %esi
  801645:	e8 16 f7 ff ff       	call   800d60 <fd2data>
  80164a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	bf 00 00 00 00       	mov    $0x0,%edi
  801654:	eb 4b                	jmp    8016a1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801656:	89 da                	mov    %ebx,%edx
  801658:	89 f0                	mov    %esi,%eax
  80165a:	e8 6d ff ff ff       	call   8015cc <_pipeisclosed>
  80165f:	85 c0                	test   %eax,%eax
  801661:	75 48                	jne    8016ab <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801663:	e8 d8 f4 ff ff       	call   800b40 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801668:	8b 43 04             	mov    0x4(%ebx),%eax
  80166b:	8b 0b                	mov    (%ebx),%ecx
  80166d:	8d 51 20             	lea    0x20(%ecx),%edx
  801670:	39 d0                	cmp    %edx,%eax
  801672:	73 e2                	jae    801656 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801674:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801677:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80167b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80167e:	89 c2                	mov    %eax,%edx
  801680:	c1 fa 1f             	sar    $0x1f,%edx
  801683:	89 d1                	mov    %edx,%ecx
  801685:	c1 e9 1b             	shr    $0x1b,%ecx
  801688:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80168b:	83 e2 1f             	and    $0x1f,%edx
  80168e:	29 ca                	sub    %ecx,%edx
  801690:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801694:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801698:	83 c0 01             	add    $0x1,%eax
  80169b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80169e:	83 c7 01             	add    $0x1,%edi
  8016a1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016a4:	75 c2                	jne    801668 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8016a9:	eb 05                	jmp    8016b0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b3:	5b                   	pop    %ebx
  8016b4:	5e                   	pop    %esi
  8016b5:	5f                   	pop    %edi
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	57                   	push   %edi
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 18             	sub    $0x18,%esp
  8016c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016c4:	57                   	push   %edi
  8016c5:	e8 96 f6 ff ff       	call   800d60 <fd2data>
  8016ca:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d4:	eb 3d                	jmp    801713 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016d6:	85 db                	test   %ebx,%ebx
  8016d8:	74 04                	je     8016de <devpipe_read+0x26>
				return i;
  8016da:	89 d8                	mov    %ebx,%eax
  8016dc:	eb 44                	jmp    801722 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016de:	89 f2                	mov    %esi,%edx
  8016e0:	89 f8                	mov    %edi,%eax
  8016e2:	e8 e5 fe ff ff       	call   8015cc <_pipeisclosed>
  8016e7:	85 c0                	test   %eax,%eax
  8016e9:	75 32                	jne    80171d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016eb:	e8 50 f4 ff ff       	call   800b40 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f0:	8b 06                	mov    (%esi),%eax
  8016f2:	3b 46 04             	cmp    0x4(%esi),%eax
  8016f5:	74 df                	je     8016d6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016f7:	99                   	cltd   
  8016f8:	c1 ea 1b             	shr    $0x1b,%edx
  8016fb:	01 d0                	add    %edx,%eax
  8016fd:	83 e0 1f             	and    $0x1f,%eax
  801700:	29 d0                	sub    %edx,%eax
  801702:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80170d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801710:	83 c3 01             	add    $0x1,%ebx
  801713:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801716:	75 d8                	jne    8016f0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801718:	8b 45 10             	mov    0x10(%ebp),%eax
  80171b:	eb 05                	jmp    801722 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80171d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801722:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5f                   	pop    %edi
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801732:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801735:	50                   	push   %eax
  801736:	e8 3c f6 ff ff       	call   800d77 <fd_alloc>
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	89 c2                	mov    %eax,%edx
  801740:	85 c0                	test   %eax,%eax
  801742:	0f 88 2c 01 00 00    	js     801874 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	68 07 04 00 00       	push   $0x407
  801750:	ff 75 f4             	pushl  -0xc(%ebp)
  801753:	6a 00                	push   $0x0
  801755:	e8 05 f4 ff ff       	call   800b5f <sys_page_alloc>
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	89 c2                	mov    %eax,%edx
  80175f:	85 c0                	test   %eax,%eax
  801761:	0f 88 0d 01 00 00    	js     801874 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801767:	83 ec 0c             	sub    $0xc,%esp
  80176a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176d:	50                   	push   %eax
  80176e:	e8 04 f6 ff ff       	call   800d77 <fd_alloc>
  801773:	89 c3                	mov    %eax,%ebx
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	85 c0                	test   %eax,%eax
  80177a:	0f 88 e2 00 00 00    	js     801862 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801780:	83 ec 04             	sub    $0x4,%esp
  801783:	68 07 04 00 00       	push   $0x407
  801788:	ff 75 f0             	pushl  -0x10(%ebp)
  80178b:	6a 00                	push   $0x0
  80178d:	e8 cd f3 ff ff       	call   800b5f <sys_page_alloc>
  801792:	89 c3                	mov    %eax,%ebx
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	85 c0                	test   %eax,%eax
  801799:	0f 88 c3 00 00 00    	js     801862 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80179f:	83 ec 0c             	sub    $0xc,%esp
  8017a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a5:	e8 b6 f5 ff ff       	call   800d60 <fd2data>
  8017aa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ac:	83 c4 0c             	add    $0xc,%esp
  8017af:	68 07 04 00 00       	push   $0x407
  8017b4:	50                   	push   %eax
  8017b5:	6a 00                	push   $0x0
  8017b7:	e8 a3 f3 ff ff       	call   800b5f <sys_page_alloc>
  8017bc:	89 c3                	mov    %eax,%ebx
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	0f 88 89 00 00 00    	js     801852 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017c9:	83 ec 0c             	sub    $0xc,%esp
  8017cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8017cf:	e8 8c f5 ff ff       	call   800d60 <fd2data>
  8017d4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017db:	50                   	push   %eax
  8017dc:	6a 00                	push   $0x0
  8017de:	56                   	push   %esi
  8017df:	6a 00                	push   $0x0
  8017e1:	e8 bc f3 ff ff       	call   800ba2 <sys_page_map>
  8017e6:	89 c3                	mov    %eax,%ebx
  8017e8:	83 c4 20             	add    $0x20,%esp
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 55                	js     801844 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017ef:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fd:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801804:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801812:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	ff 75 f4             	pushl  -0xc(%ebp)
  80181f:	e8 2c f5 ff ff       	call   800d50 <fd2num>
  801824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801827:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801829:	83 c4 04             	add    $0x4,%esp
  80182c:	ff 75 f0             	pushl  -0x10(%ebp)
  80182f:	e8 1c f5 ff ff       	call   800d50 <fd2num>
  801834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801837:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80183a:	83 c4 10             	add    $0x10,%esp
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	eb 30                	jmp    801874 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	56                   	push   %esi
  801848:	6a 00                	push   $0x0
  80184a:	e8 95 f3 ff ff       	call   800be4 <sys_page_unmap>
  80184f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	ff 75 f0             	pushl  -0x10(%ebp)
  801858:	6a 00                	push   $0x0
  80185a:	e8 85 f3 ff ff       	call   800be4 <sys_page_unmap>
  80185f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	ff 75 f4             	pushl  -0xc(%ebp)
  801868:	6a 00                	push   $0x0
  80186a:	e8 75 f3 ff ff       	call   800be4 <sys_page_unmap>
  80186f:	83 c4 10             	add    $0x10,%esp
  801872:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801874:	89 d0                	mov    %edx,%eax
  801876:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801886:	50                   	push   %eax
  801887:	ff 75 08             	pushl  0x8(%ebp)
  80188a:	e8 37 f5 ff ff       	call   800dc6 <fd_lookup>
  80188f:	83 c4 10             	add    $0x10,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 18                	js     8018ae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	ff 75 f4             	pushl  -0xc(%ebp)
  80189c:	e8 bf f4 ff ff       	call   800d60 <fd2data>
	return _pipeisclosed(fd, p);
  8018a1:	89 c2                	mov    %eax,%edx
  8018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a6:	e8 21 fd ff ff       	call   8015cc <_pipeisclosed>
  8018ab:	83 c4 10             	add    $0x10,%esp
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b8:	5d                   	pop    %ebp
  8018b9:	c3                   	ret    

008018ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018c0:	68 aa 22 80 00       	push   $0x8022aa
  8018c5:	ff 75 0c             	pushl  0xc(%ebp)
  8018c8:	e8 8f ee ff ff       	call   80075c <strcpy>
	return 0;
}
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	57                   	push   %edi
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e0:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018eb:	eb 2d                	jmp    80191a <devcons_write+0x46>
		m = n - tot;
  8018ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018f2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018f5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018fa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018fd:	83 ec 04             	sub    $0x4,%esp
  801900:	53                   	push   %ebx
  801901:	03 45 0c             	add    0xc(%ebp),%eax
  801904:	50                   	push   %eax
  801905:	57                   	push   %edi
  801906:	e8 e3 ef ff ff       	call   8008ee <memmove>
		sys_cputs(buf, m);
  80190b:	83 c4 08             	add    $0x8,%esp
  80190e:	53                   	push   %ebx
  80190f:	57                   	push   %edi
  801910:	e8 8e f1 ff ff       	call   800aa3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801915:	01 de                	add    %ebx,%esi
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	89 f0                	mov    %esi,%eax
  80191c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80191f:	72 cc                	jb     8018ed <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801921:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5f                   	pop    %edi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801934:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801938:	74 2a                	je     801964 <devcons_read+0x3b>
  80193a:	eb 05                	jmp    801941 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80193c:	e8 ff f1 ff ff       	call   800b40 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801941:	e8 7b f1 ff ff       	call   800ac1 <sys_cgetc>
  801946:	85 c0                	test   %eax,%eax
  801948:	74 f2                	je     80193c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 16                	js     801964 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80194e:	83 f8 04             	cmp    $0x4,%eax
  801951:	74 0c                	je     80195f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801953:	8b 55 0c             	mov    0xc(%ebp),%edx
  801956:	88 02                	mov    %al,(%edx)
	return 1;
  801958:	b8 01 00 00 00       	mov    $0x1,%eax
  80195d:	eb 05                	jmp    801964 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80195f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801972:	6a 01                	push   $0x1
  801974:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801977:	50                   	push   %eax
  801978:	e8 26 f1 ff ff       	call   800aa3 <sys_cputs>
}
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <getchar>:

int
getchar(void)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801988:	6a 01                	push   $0x1
  80198a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80198d:	50                   	push   %eax
  80198e:	6a 00                	push   $0x0
  801990:	e8 97 f6 ff ff       	call   80102c <read>
	if (r < 0)
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	85 c0                	test   %eax,%eax
  80199a:	78 0f                	js     8019ab <getchar+0x29>
		return r;
	if (r < 1)
  80199c:	85 c0                	test   %eax,%eax
  80199e:	7e 06                	jle    8019a6 <getchar+0x24>
		return -E_EOF;
	return c;
  8019a0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a4:	eb 05                	jmp    8019ab <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b6:	50                   	push   %eax
  8019b7:	ff 75 08             	pushl  0x8(%ebp)
  8019ba:	e8 07 f4 ff ff       	call   800dc6 <fd_lookup>
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	78 11                	js     8019d7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019cf:	39 10                	cmp    %edx,(%eax)
  8019d1:	0f 94 c0             	sete   %al
  8019d4:	0f b6 c0             	movzbl %al,%eax
}
  8019d7:	c9                   	leave  
  8019d8:	c3                   	ret    

008019d9 <opencons>:

int
opencons(void)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e2:	50                   	push   %eax
  8019e3:	e8 8f f3 ff ff       	call   800d77 <fd_alloc>
  8019e8:	83 c4 10             	add    $0x10,%esp
		return r;
  8019eb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	78 3e                	js     801a2f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f1:	83 ec 04             	sub    $0x4,%esp
  8019f4:	68 07 04 00 00       	push   $0x407
  8019f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 5c f1 ff ff       	call   800b5f <sys_page_alloc>
  801a03:	83 c4 10             	add    $0x10,%esp
		return r;
  801a06:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 23                	js     801a2f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a0c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a15:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	50                   	push   %eax
  801a25:	e8 26 f3 ff ff       	call   800d50 <fd2num>
  801a2a:	89 c2                	mov    %eax,%edx
  801a2c:	83 c4 10             	add    $0x10,%esp
}
  801a2f:	89 d0                	mov    %edx,%eax
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a38:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a3b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a41:	e8 db f0 ff ff       	call   800b21 <sys_getenvid>
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	ff 75 0c             	pushl  0xc(%ebp)
  801a4c:	ff 75 08             	pushl  0x8(%ebp)
  801a4f:	56                   	push   %esi
  801a50:	50                   	push   %eax
  801a51:	68 b8 22 80 00       	push   $0x8022b8
  801a56:	e8 32 e7 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a5b:	83 c4 18             	add    $0x18,%esp
  801a5e:	53                   	push   %ebx
  801a5f:	ff 75 10             	pushl  0x10(%ebp)
  801a62:	e8 d5 e6 ff ff       	call   80013c <vcprintf>
	cprintf("\n");
  801a67:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a6e:	e8 1a e7 ff ff       	call   80018d <cprintf>
  801a73:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a76:	cc                   	int3   
  801a77:	eb fd                	jmp    801a76 <_panic+0x43>

00801a79 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	56                   	push   %esi
  801a7d:	53                   	push   %ebx
  801a7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a81:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	ff 75 0c             	pushl  0xc(%ebp)
  801a8a:	e8 80 f2 ff ff       	call   800d0f <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a8f:	83 c4 10             	add    $0x10,%esp
  801a92:	85 f6                	test   %esi,%esi
  801a94:	74 1c                	je     801ab2 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a96:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9b:	8b 40 78             	mov    0x78(%eax),%eax
  801a9e:	89 06                	mov    %eax,(%esi)
  801aa0:	eb 10                	jmp    801ab2 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	68 dc 22 80 00       	push   $0x8022dc
  801aaa:	e8 de e6 ff ff       	call   80018d <cprintf>
  801aaf:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801ab2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab7:	8b 50 74             	mov    0x74(%eax),%edx
  801aba:	85 d2                	test   %edx,%edx
  801abc:	74 e4                	je     801aa2 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801abe:	85 db                	test   %ebx,%ebx
  801ac0:	74 05                	je     801ac7 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801ac2:	8b 40 74             	mov    0x74(%eax),%eax
  801ac5:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ac7:	a1 04 40 80 00       	mov    0x804004,%eax
  801acc:	8b 40 70             	mov    0x70(%eax),%eax

}
  801acf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad2:	5b                   	pop    %ebx
  801ad3:	5e                   	pop    %esi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	57                   	push   %edi
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ae2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801ae8:	85 db                	test   %ebx,%ebx
  801aea:	75 13                	jne    801aff <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801aec:	6a 00                	push   $0x0
  801aee:	68 00 00 c0 ee       	push   $0xeec00000
  801af3:	56                   	push   %esi
  801af4:	57                   	push   %edi
  801af5:	e8 f2 f1 ff ff       	call   800cec <sys_ipc_try_send>
  801afa:	83 c4 10             	add    $0x10,%esp
  801afd:	eb 0e                	jmp    801b0d <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801aff:	ff 75 14             	pushl  0x14(%ebp)
  801b02:	53                   	push   %ebx
  801b03:	56                   	push   %esi
  801b04:	57                   	push   %edi
  801b05:	e8 e2 f1 ff ff       	call   800cec <sys_ipc_try_send>
  801b0a:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801b0d:	85 c0                	test   %eax,%eax
  801b0f:	75 d7                	jne    801ae8 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b14:	5b                   	pop    %ebx
  801b15:	5e                   	pop    %esi
  801b16:	5f                   	pop    %edi
  801b17:	5d                   	pop    %ebp
  801b18:	c3                   	ret    

00801b19 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b24:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b27:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2d:	8b 52 50             	mov    0x50(%edx),%edx
  801b30:	39 ca                	cmp    %ecx,%edx
  801b32:	75 0d                	jne    801b41 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b34:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b37:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3c:	8b 40 48             	mov    0x48(%eax),%eax
  801b3f:	eb 0f                	jmp    801b50 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b41:	83 c0 01             	add    $0x1,%eax
  801b44:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b49:	75 d9                	jne    801b24 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b58:	89 d0                	mov    %edx,%eax
  801b5a:	c1 e8 16             	shr    $0x16,%eax
  801b5d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b69:	f6 c1 01             	test   $0x1,%cl
  801b6c:	74 1d                	je     801b8b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6e:	c1 ea 0c             	shr    $0xc,%edx
  801b71:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b78:	f6 c2 01             	test   $0x1,%dl
  801b7b:	74 0e                	je     801b8b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7d:	c1 ea 0c             	shr    $0xc,%edx
  801b80:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b87:	ef 
  801b88:	0f b7 c0             	movzwl %ax,%eax
}
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    
  801b8d:	66 90                	xchg   %ax,%ax
  801b8f:	90                   	nop

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
