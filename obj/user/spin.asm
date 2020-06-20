
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 90 00 00 00       	call   8000c1 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 80 22 80 00       	push   $0x802280
  80003f:	e8 70 01 00 00       	call   8001b4 <cprintf>
	cprintf("\t \t before the fork().\n");
  800044:	c7 04 24 f8 22 80 00 	movl   $0x8022f8,(%esp)
  80004b:	e8 64 01 00 00       	call   8001b4 <cprintf>
	if ((env = fork()) == 0) {
  800050:	e8 da 0e 00 00       	call   800f2f <fork>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	85 c0                	test   %eax,%eax
  80005a:	75 12                	jne    80006e <umain+0x3b>

		cprintf("I am the child.  Spinning...\n");
  80005c:	83 ec 0c             	sub    $0xc,%esp
  80005f:	68 10 23 80 00       	push   $0x802310
  800064:	e8 4b 01 00 00       	call   8001b4 <cprintf>
  800069:	83 c4 10             	add    $0x10,%esp
  80006c:	eb fe                	jmp    80006c <umain+0x39>
  80006e:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800070:	83 ec 0c             	sub    $0xc,%esp
  800073:	68 a8 22 80 00       	push   $0x8022a8
  800078:	e8 37 01 00 00       	call   8001b4 <cprintf>
	sys_yield();
  80007d:	e8 e5 0a 00 00       	call   800b67 <sys_yield>
	sys_yield();
  800082:	e8 e0 0a 00 00       	call   800b67 <sys_yield>
	sys_yield();
  800087:	e8 db 0a 00 00       	call   800b67 <sys_yield>
	sys_yield();
  80008c:	e8 d6 0a 00 00       	call   800b67 <sys_yield>
	sys_yield();
  800091:	e8 d1 0a 00 00       	call   800b67 <sys_yield>
	sys_yield();
  800096:	e8 cc 0a 00 00       	call   800b67 <sys_yield>
	sys_yield();
  80009b:	e8 c7 0a 00 00       	call   800b67 <sys_yield>
	sys_yield();
  8000a0:	e8 c2 0a 00 00       	call   800b67 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 d0 22 80 00 	movl   $0x8022d0,(%esp)
  8000ac:	e8 03 01 00 00       	call   8001b4 <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 4e 0a 00 00       	call   800b07 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cc:	e8 77 0a 00 00       	call   800b48 <sys_getenvid>
  8000d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000de:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e3:	85 db                	test   %ebx,%ebx
  8000e5:	7e 07                	jle    8000ee <libmain+0x2d>
		binaryname = argv[0];
  8000e7:	8b 06                	mov    (%esi),%eax
  8000e9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ee:	83 ec 08             	sub    $0x8,%esp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	e8 3b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f8:	e8 0a 00 00 00       	call   800107 <exit>
}
  8000fd:	83 c4 10             	add    $0x10,%esp
  800100:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010d:	e8 dd 11 00 00       	call   8012ef <close_all>
	sys_env_destroy(0);
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	6a 00                	push   $0x0
  800117:	e8 eb 09 00 00       	call   800b07 <sys_env_destroy>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 79 09 00 00       	call   800aca <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 54 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 1e 09 00 00       	call   800aca <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 d4 1d 00 00       	call   801ff0 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 c1 1e 00 00       	call   802120 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 38 23 80 00 	movsbl 0x802338(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027a:	83 fa 01             	cmp    $0x1,%edx
  80027d:	7e 0e                	jle    80028d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027f:	8b 10                	mov    (%eax),%edx
  800281:	8d 4a 08             	lea    0x8(%edx),%ecx
  800284:	89 08                	mov    %ecx,(%eax)
  800286:	8b 02                	mov    (%edx),%eax
  800288:	8b 52 04             	mov    0x4(%edx),%edx
  80028b:	eb 22                	jmp    8002af <getuint+0x38>
	else if (lflag)
  80028d:	85 d2                	test   %edx,%edx
  80028f:	74 10                	je     8002a1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800291:	8b 10                	mov    (%eax),%edx
  800293:	8d 4a 04             	lea    0x4(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 02                	mov    (%edx),%eax
  80029a:	ba 00 00 00 00       	mov    $0x0,%edx
  80029f:	eb 0e                	jmp    8002af <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 d3 03 00 00    	je     8006da <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	ba 00 00 00 00       	mov    $0x0,%edx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 c8             	movzbl %al,%ecx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 64 03 00 00    	ja     8006bf <vprintfmt+0x3d4>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800383:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800386:	83 fa 09             	cmp    $0x9,%edx
  800389:	77 39                	ja     8003c4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 48 04             	lea    0x4(%eax),%ecx
  800396:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a1:	eb 27                	jmp    8003ca <vprintfmt+0xdf>
  8003a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	0f 49 c8             	cmovns %eax,%ecx
  8003b0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b6:	eb 8c                	jmp    800344 <vprintfmt+0x59>
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c2:	eb 80                	jmp    800344 <vprintfmt+0x59>
  8003c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c7:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ce:	0f 89 70 ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003da:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e1:	e9 5e ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ec:	e9 53 ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 50 04             	lea    0x4(%eax),%edx
  8003f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	53                   	push   %ebx
  8003fe:	ff 30                	pushl  (%eax)
  800400:	ff d6                	call   *%esi
			break;
  800402:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 50 04             	lea    0x4(%eax),%edx
  800413:	89 55 14             	mov    %edx,0x14(%ebp)
  800416:	8b 00                	mov    (%eax),%eax
  800418:	99                   	cltd   
  800419:	31 d0                	xor    %edx,%eax
  80041b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041d:	83 f8 0f             	cmp    $0xf,%eax
  800420:	7f 0b                	jg     80042d <vprintfmt+0x142>
  800422:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800429:	85 d2                	test   %edx,%edx
  80042b:	75 18                	jne    800445 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042d:	50                   	push   %eax
  80042e:	68 50 23 80 00       	push   $0x802350
  800433:	53                   	push   %ebx
  800434:	56                   	push   %esi
  800435:	e8 94 fe ff ff       	call   8002ce <printfmt>
  80043a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800440:	e9 cc fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	68 89 28 80 00       	push   $0x802889
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 7c fe ff ff       	call   8002ce <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800458:	e9 b4 fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 50 04             	lea    0x4(%eax),%edx
  800463:	89 55 14             	mov    %edx,0x14(%ebp)
  800466:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800468:	85 ff                	test   %edi,%edi
  80046a:	b8 49 23 80 00       	mov    $0x802349,%eax
  80046f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	0f 8e 94 00 00 00    	jle    800510 <vprintfmt+0x225>
  80047c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800480:	0f 84 98 00 00 00    	je     80051e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 c8             	pushl  -0x38(%ebp)
  80048c:	57                   	push   %edi
  80048d:	e8 d0 02 00 00       	call   800762 <strnlen>
  800492:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800495:	29 c1                	sub    %eax,%ecx
  800497:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	eb 0f                	jmp    8004ba <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	53                   	push   %ebx
  8004af:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	83 ef 01             	sub    $0x1,%edi
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 ff                	test   %edi,%edi
  8004bc:	7f ed                	jg     8004ab <vprintfmt+0x1c0>
  8004be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	0f 49 c1             	cmovns %ecx,%eax
  8004ce:	29 c1                	sub    %eax,%ecx
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	89 cb                	mov    %ecx,%ebx
  8004db:	eb 4d                	jmp    80052a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e1:	74 1b                	je     8004fe <vprintfmt+0x213>
  8004e3:	0f be c0             	movsbl %al,%eax
  8004e6:	83 e8 20             	sub    $0x20,%eax
  8004e9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ec:	76 10                	jbe    8004fe <vprintfmt+0x213>
					putch('?', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	ff 75 0c             	pushl  0xc(%ebp)
  8004f4:	6a 3f                	push   $0x3f
  8004f6:	ff 55 08             	call   *0x8(%ebp)
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 0d                	jmp    80050b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	52                   	push   %edx
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	eb 1a                	jmp    80052a <vprintfmt+0x23f>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	eb 0c                	jmp    80052a <vprintfmt+0x23f>
  80051e:	89 75 08             	mov    %esi,0x8(%ebp)
  800521:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800524:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800527:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052a:	83 c7 01             	add    $0x1,%edi
  80052d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800531:	0f be d0             	movsbl %al,%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 23                	je     80055b <vprintfmt+0x270>
  800538:	85 f6                	test   %esi,%esi
  80053a:	78 a1                	js     8004dd <vprintfmt+0x1f2>
  80053c:	83 ee 01             	sub    $0x1,%esi
  80053f:	79 9c                	jns    8004dd <vprintfmt+0x1f2>
  800541:	89 df                	mov    %ebx,%edi
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	eb 18                	jmp    800563 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 20                	push   $0x20
  800551:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb 08                	jmp    800563 <vprintfmt+0x278>
  80055b:	89 df                	mov    %ebx,%edi
  80055d:	8b 75 08             	mov    0x8(%ebp),%esi
  800560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800563:	85 ff                	test   %edi,%edi
  800565:	7f e4                	jg     80054b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056a:	e9 a2 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056f:	83 fa 01             	cmp    $0x1,%edx
  800572:	7e 16                	jle    80058a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 08             	lea    0x8(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 50 04             	mov    0x4(%eax),%edx
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800585:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800588:	eb 32                	jmp    8005bc <vprintfmt+0x2d1>
	else if (lflag)
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 18                	je     8005a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 50 04             	lea    0x4(%eax),%edx
  800594:	89 55 14             	mov    %edx,0x14(%ebp)
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a4:	eb 16                	jmp    8005bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 00                	mov    (%eax),%eax
  8005b1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005b4:	89 c1                	mov    %eax,%ecx
  8005b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005bf:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005d1:	0f 89 b0 00 00 00    	jns    800687 <vprintfmt+0x39c>
				putch('-', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	53                   	push   %ebx
  8005db:	6a 2d                	push   $0x2d
  8005dd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005df:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e2:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e5:	f7 d8                	neg    %eax
  8005e7:	83 d2 00             	adc    $0x0,%edx
  8005ea:	f7 da                	neg    %edx
  8005ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fa:	e9 88 00 00 00       	jmp    800687 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800602:	e8 70 fc ff ff       	call   800277 <getuint>
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80060d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800612:	eb 73                	jmp    800687 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800614:	8d 45 14             	lea    0x14(%ebp),%eax
  800617:	e8 5b fc ff ff       	call   800277 <getuint>
  80061c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 58                	push   $0x58
  800628:	ff d6                	call   *%esi
			putch('X', putdat);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 58                	push   $0x58
  800630:	ff d6                	call   *%esi
			putch('X', putdat);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	6a 58                	push   $0x58
  800638:	ff d6                	call   *%esi
			goto number;
  80063a:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80063d:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800642:	eb 43                	jmp    800687 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 30                	push   $0x30
  80064a:	ff d6                	call   *%esi
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 78                	push   $0x78
  800652:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
  800664:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800667:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800672:	eb 13                	jmp    800687 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 fb fb ff ff       	call   800277 <getuint>
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800682:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800687:	83 ec 0c             	sub    $0xc,%esp
  80068a:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80068e:	52                   	push   %edx
  80068f:	ff 75 e0             	pushl  -0x20(%ebp)
  800692:	50                   	push   %eax
  800693:	ff 75 dc             	pushl  -0x24(%ebp)
  800696:	ff 75 d8             	pushl  -0x28(%ebp)
  800699:	89 da                	mov    %ebx,%edx
  80069b:	89 f0                	mov    %esi,%eax
  80069d:	e8 26 fb ff ff       	call   8001c8 <printnum>
			break;
  8006a2:	83 c4 20             	add    $0x20,%esp
  8006a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a8:	e9 64 fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	51                   	push   %ecx
  8006b2:	ff d6                	call   *%esi
			break;
  8006b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ba:	e9 52 fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	6a 25                	push   $0x25
  8006c5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c7:	83 c4 10             	add    $0x10,%esp
  8006ca:	eb 03                	jmp    8006cf <vprintfmt+0x3e4>
  8006cc:	83 ef 01             	sub    $0x1,%edi
  8006cf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d3:	75 f7                	jne    8006cc <vprintfmt+0x3e1>
  8006d5:	e9 37 fc ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006dd:	5b                   	pop    %ebx
  8006de:	5e                   	pop    %esi
  8006df:	5f                   	pop    %edi
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 18             	sub    $0x18,%esp
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ff:	85 c0                	test   %eax,%eax
  800701:	74 26                	je     800729 <vsnprintf+0x47>
  800703:	85 d2                	test   %edx,%edx
  800705:	7e 22                	jle    800729 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800707:	ff 75 14             	pushl  0x14(%ebp)
  80070a:	ff 75 10             	pushl  0x10(%ebp)
  80070d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800710:	50                   	push   %eax
  800711:	68 b1 02 80 00       	push   $0x8002b1
  800716:	e8 d0 fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800721:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 05                	jmp    80072e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800729:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072e:	c9                   	leave  
  80072f:	c3                   	ret    

00800730 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800736:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800739:	50                   	push   %eax
  80073a:	ff 75 10             	pushl  0x10(%ebp)
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	ff 75 08             	pushl  0x8(%ebp)
  800743:	e8 9a ff ff ff       	call   8006e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800750:	b8 00 00 00 00       	mov    $0x0,%eax
  800755:	eb 03                	jmp    80075a <strlen+0x10>
		n++;
  800757:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80075a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075e:	75 f7                	jne    800757 <strlen+0xd>
		n++;
	return n;
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800768:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076b:	ba 00 00 00 00       	mov    $0x0,%edx
  800770:	eb 03                	jmp    800775 <strnlen+0x13>
		n++;
  800772:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	39 c2                	cmp    %eax,%edx
  800777:	74 08                	je     800781 <strnlen+0x1f>
  800779:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077d:	75 f3                	jne    800772 <strnlen+0x10>
  80077f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	83 c2 01             	add    $0x1,%edx
  800792:	83 c1 01             	add    $0x1,%ecx
  800795:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800799:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079c:	84 db                	test   %bl,%bl
  80079e:	75 ef                	jne    80078f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 9a ff ff ff       	call   80074a <strlen>
  8007b0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	01 d8                	add    %ebx,%eax
  8007b8:	50                   	push   %eax
  8007b9:	e8 c5 ff ff ff       	call   800783 <strcpy>
	return dst;
}
  8007be:	89 d8                	mov    %ebx,%eax
  8007c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d0:	89 f3                	mov    %esi,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	89 f2                	mov    %esi,%edx
  8007d7:	eb 0f                	jmp    8007e8 <strncpy+0x23>
		*dst++ = *src;
  8007d9:	83 c2 01             	add    $0x1,%edx
  8007dc:	0f b6 01             	movzbl (%ecx),%eax
  8007df:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	39 da                	cmp    %ebx,%edx
  8007ea:	75 ed                	jne    8007d9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800800:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	74 21                	je     800827 <strlcpy+0x35>
  800806:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 09                	jmp    800817 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	83 c1 01             	add    $0x1,%ecx
  800814:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800817:	39 c2                	cmp    %eax,%edx
  800819:	74 09                	je     800824 <strlcpy+0x32>
  80081b:	0f b6 19             	movzbl (%ecx),%ebx
  80081e:	84 db                	test   %bl,%bl
  800820:	75 ec                	jne    80080e <strlcpy+0x1c>
  800822:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800824:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800827:	29 f0                	sub    %esi,%eax
}
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800836:	eb 06                	jmp    80083e <strcmp+0x11>
		p++, q++;
  800838:	83 c1 01             	add    $0x1,%ecx
  80083b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083e:	0f b6 01             	movzbl (%ecx),%eax
  800841:	84 c0                	test   %al,%al
  800843:	74 04                	je     800849 <strcmp+0x1c>
  800845:	3a 02                	cmp    (%edx),%al
  800847:	74 ef                	je     800838 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	0f b6 12             	movzbl (%edx),%edx
  80084f:	29 d0                	sub    %edx,%eax
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085d:	89 c3                	mov    %eax,%ebx
  80085f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800862:	eb 06                	jmp    80086a <strncmp+0x17>
		n--, p++, q++;
  800864:	83 c0 01             	add    $0x1,%eax
  800867:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80086a:	39 d8                	cmp    %ebx,%eax
  80086c:	74 15                	je     800883 <strncmp+0x30>
  80086e:	0f b6 08             	movzbl (%eax),%ecx
  800871:	84 c9                	test   %cl,%cl
  800873:	74 04                	je     800879 <strncmp+0x26>
  800875:	3a 0a                	cmp    (%edx),%cl
  800877:	74 eb                	je     800864 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800879:	0f b6 00             	movzbl (%eax),%eax
  80087c:	0f b6 12             	movzbl (%edx),%edx
  80087f:	29 d0                	sub    %edx,%eax
  800881:	eb 05                	jmp    800888 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800883:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800888:	5b                   	pop    %ebx
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800895:	eb 07                	jmp    80089e <strchr+0x13>
		if (*s == c)
  800897:	38 ca                	cmp    %cl,%dl
  800899:	74 0f                	je     8008aa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	0f b6 10             	movzbl (%eax),%edx
  8008a1:	84 d2                	test   %dl,%dl
  8008a3:	75 f2                	jne    800897 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b6:	eb 03                	jmp    8008bb <strfind+0xf>
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008be:	38 ca                	cmp    %cl,%dl
  8008c0:	74 04                	je     8008c6 <strfind+0x1a>
  8008c2:	84 d2                	test   %dl,%dl
  8008c4:	75 f2                	jne    8008b8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	57                   	push   %edi
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	74 36                	je     80090e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008de:	75 28                	jne    800908 <memset+0x40>
  8008e0:	f6 c1 03             	test   $0x3,%cl
  8008e3:	75 23                	jne    800908 <memset+0x40>
		c &= 0xFF;
  8008e5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e9:	89 d3                	mov    %edx,%ebx
  8008eb:	c1 e3 08             	shl    $0x8,%ebx
  8008ee:	89 d6                	mov    %edx,%esi
  8008f0:	c1 e6 18             	shl    $0x18,%esi
  8008f3:	89 d0                	mov    %edx,%eax
  8008f5:	c1 e0 10             	shl    $0x10,%eax
  8008f8:	09 f0                	or     %esi,%eax
  8008fa:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008fc:	89 d8                	mov    %ebx,%eax
  8008fe:	09 d0                	or     %edx,%eax
  800900:	c1 e9 02             	shr    $0x2,%ecx
  800903:	fc                   	cld    
  800904:	f3 ab                	rep stos %eax,%es:(%edi)
  800906:	eb 06                	jmp    80090e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	fc                   	cld    
  80090c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090e:	89 f8                	mov    %edi,%eax
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5f                   	pop    %edi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800920:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800923:	39 c6                	cmp    %eax,%esi
  800925:	73 35                	jae    80095c <memmove+0x47>
  800927:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092a:	39 d0                	cmp    %edx,%eax
  80092c:	73 2e                	jae    80095c <memmove+0x47>
		s += n;
		d += n;
  80092e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800931:	89 d6                	mov    %edx,%esi
  800933:	09 fe                	or     %edi,%esi
  800935:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093b:	75 13                	jne    800950 <memmove+0x3b>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 0e                	jne    800950 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800942:	83 ef 04             	sub    $0x4,%edi
  800945:	8d 72 fc             	lea    -0x4(%edx),%esi
  800948:	c1 e9 02             	shr    $0x2,%ecx
  80094b:	fd                   	std    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb 09                	jmp    800959 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800950:	83 ef 01             	sub    $0x1,%edi
  800953:	8d 72 ff             	lea    -0x1(%edx),%esi
  800956:	fd                   	std    
  800957:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800959:	fc                   	cld    
  80095a:	eb 1d                	jmp    800979 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095c:	89 f2                	mov    %esi,%edx
  80095e:	09 c2                	or     %eax,%edx
  800960:	f6 c2 03             	test   $0x3,%dl
  800963:	75 0f                	jne    800974 <memmove+0x5f>
  800965:	f6 c1 03             	test   $0x3,%cl
  800968:	75 0a                	jne    800974 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80096a:	c1 e9 02             	shr    $0x2,%ecx
  80096d:	89 c7                	mov    %eax,%edi
  80096f:	fc                   	cld    
  800970:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800972:	eb 05                	jmp    800979 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800974:	89 c7                	mov    %eax,%edi
  800976:	fc                   	cld    
  800977:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800980:	ff 75 10             	pushl  0x10(%ebp)
  800983:	ff 75 0c             	pushl  0xc(%ebp)
  800986:	ff 75 08             	pushl  0x8(%ebp)
  800989:	e8 87 ff ff ff       	call   800915 <memmove>
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	56                   	push   %esi
  800994:	53                   	push   %ebx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	89 c6                	mov    %eax,%esi
  80099d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a0:	eb 1a                	jmp    8009bc <memcmp+0x2c>
		if (*s1 != *s2)
  8009a2:	0f b6 08             	movzbl (%eax),%ecx
  8009a5:	0f b6 1a             	movzbl (%edx),%ebx
  8009a8:	38 d9                	cmp    %bl,%cl
  8009aa:	74 0a                	je     8009b6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ac:	0f b6 c1             	movzbl %cl,%eax
  8009af:	0f b6 db             	movzbl %bl,%ebx
  8009b2:	29 d8                	sub    %ebx,%eax
  8009b4:	eb 0f                	jmp    8009c5 <memcmp+0x35>
		s1++, s2++;
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bc:	39 f0                	cmp    %esi,%eax
  8009be:	75 e2                	jne    8009a2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009d0:	89 c1                	mov    %eax,%ecx
  8009d2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d9:	eb 0a                	jmp    8009e5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009db:	0f b6 10             	movzbl (%eax),%edx
  8009de:	39 da                	cmp    %ebx,%edx
  8009e0:	74 07                	je     8009e9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e2:	83 c0 01             	add    $0x1,%eax
  8009e5:	39 c8                	cmp    %ecx,%eax
  8009e7:	72 f2                	jb     8009db <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	57                   	push   %edi
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f8:	eb 03                	jmp    8009fd <strtol+0x11>
		s++;
  8009fa:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	3c 20                	cmp    $0x20,%al
  800a02:	74 f6                	je     8009fa <strtol+0xe>
  800a04:	3c 09                	cmp    $0x9,%al
  800a06:	74 f2                	je     8009fa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a08:	3c 2b                	cmp    $0x2b,%al
  800a0a:	75 0a                	jne    800a16 <strtol+0x2a>
		s++;
  800a0c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a14:	eb 11                	jmp    800a27 <strtol+0x3b>
  800a16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1b:	3c 2d                	cmp    $0x2d,%al
  800a1d:	75 08                	jne    800a27 <strtol+0x3b>
		s++, neg = 1;
  800a1f:	83 c1 01             	add    $0x1,%ecx
  800a22:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a27:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2d:	75 15                	jne    800a44 <strtol+0x58>
  800a2f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a32:	75 10                	jne    800a44 <strtol+0x58>
  800a34:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a38:	75 7c                	jne    800ab6 <strtol+0xca>
		s += 2, base = 16;
  800a3a:	83 c1 02             	add    $0x2,%ecx
  800a3d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a42:	eb 16                	jmp    800a5a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	75 12                	jne    800a5a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a48:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a50:	75 08                	jne    800a5a <strtol+0x6e>
		s++, base = 8;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a62:	0f b6 11             	movzbl (%ecx),%edx
  800a65:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a68:	89 f3                	mov    %esi,%ebx
  800a6a:	80 fb 09             	cmp    $0x9,%bl
  800a6d:	77 08                	ja     800a77 <strtol+0x8b>
			dig = *s - '0';
  800a6f:	0f be d2             	movsbl %dl,%edx
  800a72:	83 ea 30             	sub    $0x30,%edx
  800a75:	eb 22                	jmp    800a99 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a77:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a7a:	89 f3                	mov    %esi,%ebx
  800a7c:	80 fb 19             	cmp    $0x19,%bl
  800a7f:	77 08                	ja     800a89 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 57             	sub    $0x57,%edx
  800a87:	eb 10                	jmp    800a99 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a89:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 19             	cmp    $0x19,%bl
  800a91:	77 16                	ja     800aa9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a99:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a9c:	7d 0b                	jge    800aa9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9e:	83 c1 01             	add    $0x1,%ecx
  800aa1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa7:	eb b9                	jmp    800a62 <strtol+0x76>

	if (endptr)
  800aa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aad:	74 0d                	je     800abc <strtol+0xd0>
		*endptr = (char *) s;
  800aaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab2:	89 0e                	mov    %ecx,(%esi)
  800ab4:	eb 06                	jmp    800abc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	74 98                	je     800a52 <strtol+0x66>
  800aba:	eb 9e                	jmp    800a5a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abc:	89 c2                	mov    %eax,%edx
  800abe:	f7 da                	neg    %edx
  800ac0:	85 ff                	test   %edi,%edi
  800ac2:	0f 45 c2             	cmovne %edx,%eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	8b 55 08             	mov    0x8(%ebp),%edx
  800adb:	89 c3                	mov    %eax,%ebx
  800add:	89 c7                	mov    %eax,%edi
  800adf:	89 c6                	mov    %eax,%esi
  800ae1:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 01 00 00 00       	mov    $0x1,%eax
  800af8:	89 d1                	mov    %edx,%ecx
  800afa:	89 d3                	mov    %edx,%ebx
  800afc:	89 d7                	mov    %edx,%edi
  800afe:	89 d6                	mov    %edx,%esi
  800b00:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
  800b0d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b10:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b15:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	89 cb                	mov    %ecx,%ebx
  800b1f:	89 cf                	mov    %ecx,%edi
  800b21:	89 ce                	mov    %ecx,%esi
  800b23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	7e 17                	jle    800b40 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b29:	83 ec 0c             	sub    $0xc,%esp
  800b2c:	50                   	push   %eax
  800b2d:	6a 03                	push   $0x3
  800b2f:	68 3f 26 80 00       	push   $0x80263f
  800b34:	6a 23                	push   $0x23
  800b36:	68 5c 26 80 00       	push   $0x80265c
  800b3b:	e8 c7 12 00 00       	call   801e07 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	b8 02 00 00 00       	mov    $0x2,%eax
  800b58:	89 d1                	mov    %edx,%ecx
  800b5a:	89 d3                	mov    %edx,%ebx
  800b5c:	89 d7                	mov    %edx,%edi
  800b5e:	89 d6                	mov    %edx,%esi
  800b60:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_yield>:

void
sys_yield(void)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b72:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b77:	89 d1                	mov    %edx,%ecx
  800b79:	89 d3                	mov    %edx,%ebx
  800b7b:	89 d7                	mov    %edx,%edi
  800b7d:	89 d6                	mov    %edx,%esi
  800b7f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b8f:	be 00 00 00 00       	mov    $0x0,%esi
  800b94:	b8 04 00 00 00       	mov    $0x4,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba2:	89 f7                	mov    %esi,%edi
  800ba4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ba6:	85 c0                	test   %eax,%eax
  800ba8:	7e 17                	jle    800bc1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	50                   	push   %eax
  800bae:	6a 04                	push   $0x4
  800bb0:	68 3f 26 80 00       	push   $0x80263f
  800bb5:	6a 23                	push   $0x23
  800bb7:	68 5c 26 80 00       	push   $0x80265c
  800bbc:	e8 46 12 00 00       	call   801e07 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	57                   	push   %edi
  800bcd:	56                   	push   %esi
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be3:	8b 75 18             	mov    0x18(%ebp),%esi
  800be6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800be8:	85 c0                	test   %eax,%eax
  800bea:	7e 17                	jle    800c03 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	50                   	push   %eax
  800bf0:	6a 05                	push   $0x5
  800bf2:	68 3f 26 80 00       	push   $0x80263f
  800bf7:	6a 23                	push   $0x23
  800bf9:	68 5c 26 80 00       	push   $0x80265c
  800bfe:	e8 04 12 00 00       	call   801e07 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c19:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c21:	8b 55 08             	mov    0x8(%ebp),%edx
  800c24:	89 df                	mov    %ebx,%edi
  800c26:	89 de                	mov    %ebx,%esi
  800c28:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 06                	push   $0x6
  800c34:	68 3f 26 80 00       	push   $0x80263f
  800c39:	6a 23                	push   $0x23
  800c3b:	68 5c 26 80 00       	push   $0x80265c
  800c40:	e8 c2 11 00 00       	call   801e07 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	89 df                	mov    %ebx,%edi
  800c68:	89 de                	mov    %ebx,%esi
  800c6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 08                	push   $0x8
  800c76:	68 3f 26 80 00       	push   $0x80263f
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 5c 26 80 00       	push   $0x80265c
  800c82:	e8 80 11 00 00       	call   801e07 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 09                	push   $0x9
  800cb8:	68 3f 26 80 00       	push   $0x80263f
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 5c 26 80 00       	push   $0x80265c
  800cc4:	e8 3e 11 00 00       	call   801e07 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 0a                	push   $0xa
  800cfa:	68 3f 26 80 00       	push   $0x80263f
  800cff:	6a 23                	push   $0x23
  800d01:	68 5c 26 80 00       	push   $0x80265c
  800d06:	e8 fc 10 00 00       	call   801e07 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d19:	be 00 00 00 00       	mov    $0x0,%esi
  800d1e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	89 cb                	mov    %ecx,%ebx
  800d4e:	89 cf                	mov    %ecx,%edi
  800d50:	89 ce                	mov    %ecx,%esi
  800d52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d54:	85 c0                	test   %eax,%eax
  800d56:	7e 17                	jle    800d6f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 0d                	push   $0xd
  800d5e:	68 3f 26 80 00       	push   $0x80263f
  800d63:	6a 23                	push   $0x23
  800d65:	68 5c 26 80 00       	push   $0x80265c
  800d6a:	e8 98 10 00 00       	call   801e07 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	56                   	push   %esi
  800d7b:	53                   	push   %ebx
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7f:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800d81:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d85:	74 11                	je     800d98 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800d87:	89 d8                	mov    %ebx,%eax
  800d89:	c1 e8 0c             	shr    $0xc,%eax
  800d8c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800d93:	f6 c4 08             	test   $0x8,%ah
  800d96:	75 14                	jne    800dac <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800d98:	83 ec 04             	sub    $0x4,%esp
  800d9b:	68 6a 26 80 00       	push   $0x80266a
  800da0:	6a 21                	push   $0x21
  800da2:	68 80 26 80 00       	push   $0x802680
  800da7:	e8 5b 10 00 00       	call   801e07 <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800dac:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800db2:	e8 91 fd ff ff       	call   800b48 <sys_getenvid>
  800db7:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	6a 07                	push   $0x7
  800dbe:	68 00 f0 7f 00       	push   $0x7ff000
  800dc3:	50                   	push   %eax
  800dc4:	e8 bd fd ff ff       	call   800b86 <sys_page_alloc>
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	79 14                	jns    800de4 <pgfault+0x6d>
		panic("sys_page_alloc");
  800dd0:	83 ec 04             	sub    $0x4,%esp
  800dd3:	68 8b 26 80 00       	push   $0x80268b
  800dd8:	6a 30                	push   $0x30
  800dda:	68 80 26 80 00       	push   $0x802680
  800ddf:	e8 23 10 00 00       	call   801e07 <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	68 00 10 00 00       	push   $0x1000
  800dec:	53                   	push   %ebx
  800ded:	68 00 f0 7f 00       	push   $0x7ff000
  800df2:	e8 86 fb ff ff       	call   80097d <memcpy>
	retv = sys_page_unmap(envid, addr);
  800df7:	83 c4 08             	add    $0x8,%esp
  800dfa:	53                   	push   %ebx
  800dfb:	56                   	push   %esi
  800dfc:	e8 0a fe ff ff       	call   800c0b <sys_page_unmap>
	if(retv < 0){
  800e01:	83 c4 10             	add    $0x10,%esp
  800e04:	85 c0                	test   %eax,%eax
  800e06:	79 12                	jns    800e1a <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800e08:	50                   	push   %eax
  800e09:	68 78 27 80 00       	push   $0x802778
  800e0e:	6a 35                	push   $0x35
  800e10:	68 80 26 80 00       	push   $0x802680
  800e15:	e8 ed 0f 00 00       	call   801e07 <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	6a 07                	push   $0x7
  800e1f:	53                   	push   %ebx
  800e20:	56                   	push   %esi
  800e21:	68 00 f0 7f 00       	push   $0x7ff000
  800e26:	56                   	push   %esi
  800e27:	e8 9d fd ff ff       	call   800bc9 <sys_page_map>
	if(retv < 0){
  800e2c:	83 c4 20             	add    $0x20,%esp
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	79 14                	jns    800e47 <pgfault+0xd0>
		panic("sys_page_map");
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	68 9a 26 80 00       	push   $0x80269a
  800e3b:	6a 39                	push   $0x39
  800e3d:	68 80 26 80 00       	push   $0x802680
  800e42:	e8 c0 0f 00 00       	call   801e07 <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	68 00 f0 7f 00       	push   $0x7ff000
  800e4f:	56                   	push   %esi
  800e50:	e8 b6 fd ff ff       	call   800c0b <sys_page_unmap>
	if(retv < 0){
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	79 14                	jns    800e70 <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800e5c:	83 ec 04             	sub    $0x4,%esp
  800e5f:	68 a7 26 80 00       	push   $0x8026a7
  800e64:	6a 3d                	push   $0x3d
  800e66:	68 80 26 80 00       	push   $0x802680
  800e6b:	e8 97 0f 00 00       	call   801e07 <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800e70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  800e7c:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800e7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e82:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	53                   	push   %ebx
  800e89:	68 c4 26 80 00       	push   $0x8026c4
  800e8e:	e8 21 f3 ff ff       	call   8001b4 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e93:	83 c4 0c             	add    $0xc,%esp
  800e96:	6a 07                	push   $0x7
  800e98:	53                   	push   %ebx
  800e99:	56                   	push   %esi
  800e9a:	e8 e7 fc ff ff       	call   800b86 <sys_page_alloc>
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	79 15                	jns    800ebb <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800ea6:	50                   	push   %eax
  800ea7:	68 d7 26 80 00       	push   $0x8026d7
  800eac:	68 90 00 00 00       	push   $0x90
  800eb1:	68 80 26 80 00       	push   $0x802680
  800eb6:	e8 4c 0f 00 00       	call   801e07 <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	68 ea 26 80 00       	push   $0x8026ea
  800ec3:	e8 ec f2 ff ff       	call   8001b4 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800ec8:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ecf:	68 00 00 40 00       	push   $0x400000
  800ed4:	6a 00                	push   $0x0
  800ed6:	53                   	push   %ebx
  800ed7:	56                   	push   %esi
  800ed8:	e8 ec fc ff ff       	call   800bc9 <sys_page_map>
  800edd:	83 c4 20             	add    $0x20,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	79 15                	jns    800ef9 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800ee4:	50                   	push   %eax
  800ee5:	68 f2 26 80 00       	push   $0x8026f2
  800eea:	68 94 00 00 00       	push   $0x94
  800eef:	68 80 26 80 00       	push   $0x802680
  800ef4:	e8 0e 0f 00 00       	call   801e07 <_panic>
        cprintf("af_p_m.");
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	68 03 27 80 00       	push   $0x802703
  800f01:	e8 ae f2 ff ff       	call   8001b4 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  800f06:	83 c4 0c             	add    $0xc,%esp
  800f09:	68 00 10 00 00       	push   $0x1000
  800f0e:	53                   	push   %ebx
  800f0f:	68 00 00 40 00       	push   $0x400000
  800f14:	e8 fc f9 ff ff       	call   800915 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  800f19:	c7 04 24 0b 27 80 00 	movl   $0x80270b,(%esp)
  800f20:	e8 8f f2 ff ff       	call   8001b4 <cprintf>
}
  800f25:	83 c4 10             	add    $0x10,%esp
  800f28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	57                   	push   %edi
  800f33:	56                   	push   %esi
  800f34:	53                   	push   %ebx
  800f35:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800f38:	68 77 0d 80 00       	push   $0x800d77
  800f3d:	e8 0b 0f 00 00       	call   801e4d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f42:	b8 07 00 00 00       	mov    $0x7,%eax
  800f47:	cd 30                	int    $0x30
  800f49:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f4c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 17                	jns    800f6d <fork+0x3e>
		panic("sys_exofork failed.");
  800f56:	83 ec 04             	sub    $0x4,%esp
  800f59:	68 19 27 80 00       	push   $0x802719
  800f5e:	68 b7 00 00 00       	push   $0xb7
  800f63:	68 80 26 80 00       	push   $0x802680
  800f68:	e8 9a 0e 00 00       	call   801e07 <_panic>
  800f6d:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  800f72:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f76:	75 21                	jne    800f99 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f78:	e8 cb fb ff ff       	call   800b48 <sys_getenvid>
  800f7d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f82:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f85:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f8a:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  800f8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f94:	e9 69 01 00 00       	jmp    801102 <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800f99:	89 d8                	mov    %ebx,%eax
  800f9b:	c1 e8 16             	shr    $0x16,%eax
  800f9e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800fa5:	a8 01                	test   $0x1,%al
  800fa7:	0f 84 d6 00 00 00    	je     801083 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  800fad:	89 de                	mov    %ebx,%esi
  800faf:	c1 ee 0c             	shr    $0xc,%esi
  800fb2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800fb9:	a8 01                	test   $0x1,%al
  800fbb:	0f 84 c2 00 00 00    	je     801083 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  800fc1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  800fc8:	89 f7                	mov    %esi,%edi
  800fca:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  800fcd:	e8 76 fb ff ff       	call   800b48 <sys_getenvid>
  800fd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  800fd5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fdc:	f6 c4 04             	test   $0x4,%ah
  800fdf:	74 1c                	je     800ffd <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	68 07 0e 00 00       	push   $0xe07
  800fe9:	57                   	push   %edi
  800fea:	ff 75 e0             	pushl  -0x20(%ebp)
  800fed:	57                   	push   %edi
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 d4 fb ff ff       	call   800bc9 <sys_page_map>
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	e9 86 00 00 00       	jmp    801083 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  800ffd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801004:	a8 02                	test   $0x2,%al
  801006:	75 0c                	jne    801014 <fork+0xe5>
  801008:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100f:	f6 c4 08             	test   $0x8,%ah
  801012:	74 5b                	je     80106f <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	68 05 08 00 00       	push   $0x805
  80101c:	57                   	push   %edi
  80101d:	ff 75 e0             	pushl  -0x20(%ebp)
  801020:	57                   	push   %edi
  801021:	ff 75 e4             	pushl  -0x1c(%ebp)
  801024:	e8 a0 fb ff ff       	call   800bc9 <sys_page_map>
  801029:	83 c4 20             	add    $0x20,%esp
  80102c:	85 c0                	test   %eax,%eax
  80102e:	79 12                	jns    801042 <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  801030:	50                   	push   %eax
  801031:	68 9c 27 80 00       	push   $0x80279c
  801036:	6a 5f                	push   $0x5f
  801038:	68 80 26 80 00       	push   $0x802680
  80103d:	e8 c5 0d 00 00       	call   801e07 <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	68 05 08 00 00       	push   $0x805
  80104a:	57                   	push   %edi
  80104b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104e:	50                   	push   %eax
  80104f:	57                   	push   %edi
  801050:	50                   	push   %eax
  801051:	e8 73 fb ff ff       	call   800bc9 <sys_page_map>
  801056:	83 c4 20             	add    $0x20,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	79 26                	jns    801083 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  80105d:	50                   	push   %eax
  80105e:	68 c0 27 80 00       	push   $0x8027c0
  801063:	6a 64                	push   $0x64
  801065:	68 80 26 80 00       	push   $0x802680
  80106a:	e8 98 0d 00 00       	call   801e07 <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	6a 05                	push   $0x5
  801074:	57                   	push   %edi
  801075:	ff 75 e0             	pushl  -0x20(%ebp)
  801078:	57                   	push   %edi
  801079:	6a 00                	push   $0x0
  80107b:	e8 49 fb ff ff       	call   800bc9 <sys_page_map>
  801080:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801083:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801089:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80108f:	0f 85 04 ff ff ff    	jne    800f99 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	6a 07                	push   $0x7
  80109a:	68 00 f0 bf ee       	push   $0xeebff000
  80109f:	ff 75 dc             	pushl  -0x24(%ebp)
  8010a2:	e8 df fa ff ff       	call   800b86 <sys_page_alloc>
	if(retv < 0){
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	79 17                	jns    8010c5 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	68 2d 27 80 00       	push   $0x80272d
  8010b6:	68 cc 00 00 00       	push   $0xcc
  8010bb:	68 80 26 80 00       	push   $0x802680
  8010c0:	e8 42 0d 00 00       	call   801e07 <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	68 b2 1e 80 00       	push   $0x801eb2
  8010cd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010d0:	57                   	push   %edi
  8010d1:	e8 fb fb ff ff       	call   800cd1 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  8010d6:	83 c4 08             	add    $0x8,%esp
  8010d9:	6a 02                	push   $0x2
  8010db:	57                   	push   %edi
  8010dc:	e8 6c fb ff ff       	call   800c4d <sys_env_set_status>
	if(retv < 0){
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	79 17                	jns    8010ff <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	68 45 27 80 00       	push   $0x802745
  8010f0:	68 dd 00 00 00       	push   $0xdd
  8010f5:	68 80 26 80 00       	push   $0x802680
  8010fa:	e8 08 0d 00 00       	call   801e07 <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  8010ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  801102:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801105:	5b                   	pop    %ebx
  801106:	5e                   	pop    %esi
  801107:	5f                   	pop    %edi
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    

0080110a <sfork>:

// Challenge!
int
sfork(void)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801110:	68 61 27 80 00       	push   $0x802761
  801115:	68 e8 00 00 00       	push   $0xe8
  80111a:	68 80 26 80 00       	push   $0x802680
  80111f:	e8 e3 0c 00 00       	call   801e07 <_panic>

00801124 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
  80112a:	05 00 00 00 30       	add    $0x30000000,%eax
  80112f:	c1 e8 0c             	shr    $0xc,%eax
}
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801137:	8b 45 08             	mov    0x8(%ebp),%eax
  80113a:	05 00 00 00 30       	add    $0x30000000,%eax
  80113f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801144:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801151:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801156:	89 c2                	mov    %eax,%edx
  801158:	c1 ea 16             	shr    $0x16,%edx
  80115b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801162:	f6 c2 01             	test   $0x1,%dl
  801165:	74 11                	je     801178 <fd_alloc+0x2d>
  801167:	89 c2                	mov    %eax,%edx
  801169:	c1 ea 0c             	shr    $0xc,%edx
  80116c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801173:	f6 c2 01             	test   $0x1,%dl
  801176:	75 09                	jne    801181 <fd_alloc+0x36>
			*fd_store = fd;
  801178:	89 01                	mov    %eax,(%ecx)
			return 0;
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
  80117f:	eb 17                	jmp    801198 <fd_alloc+0x4d>
  801181:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801186:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118b:	75 c9                	jne    801156 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80118d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801193:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a0:	83 f8 1f             	cmp    $0x1f,%eax
  8011a3:	77 36                	ja     8011db <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a5:	c1 e0 0c             	shl    $0xc,%eax
  8011a8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ad:	89 c2                	mov    %eax,%edx
  8011af:	c1 ea 16             	shr    $0x16,%edx
  8011b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b9:	f6 c2 01             	test   $0x1,%dl
  8011bc:	74 24                	je     8011e2 <fd_lookup+0x48>
  8011be:	89 c2                	mov    %eax,%edx
  8011c0:	c1 ea 0c             	shr    $0xc,%edx
  8011c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ca:	f6 c2 01             	test   $0x1,%dl
  8011cd:	74 1a                	je     8011e9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d2:	89 02                	mov    %eax,(%edx)
	return 0;
  8011d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d9:	eb 13                	jmp    8011ee <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e0:	eb 0c                	jmp    8011ee <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e7:	eb 05                	jmp    8011ee <fd_lookup+0x54>
  8011e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f9:	ba 60 28 80 00       	mov    $0x802860,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011fe:	eb 13                	jmp    801213 <dev_lookup+0x23>
  801200:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801203:	39 08                	cmp    %ecx,(%eax)
  801205:	75 0c                	jne    801213 <dev_lookup+0x23>
			*dev = devtab[i];
  801207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  801211:	eb 2e                	jmp    801241 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801213:	8b 02                	mov    (%edx),%eax
  801215:	85 c0                	test   %eax,%eax
  801217:	75 e7                	jne    801200 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801219:	a1 04 40 80 00       	mov    0x804004,%eax
  80121e:	8b 40 48             	mov    0x48(%eax),%eax
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	51                   	push   %ecx
  801225:	50                   	push   %eax
  801226:	68 e4 27 80 00       	push   $0x8027e4
  80122b:	e8 84 ef ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  801230:	8b 45 0c             	mov    0xc(%ebp),%eax
  801233:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 10             	sub    $0x10,%esp
  80124b:	8b 75 08             	mov    0x8(%ebp),%esi
  80124e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801251:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801254:	50                   	push   %eax
  801255:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80125b:	c1 e8 0c             	shr    $0xc,%eax
  80125e:	50                   	push   %eax
  80125f:	e8 36 ff ff ff       	call   80119a <fd_lookup>
  801264:	83 c4 08             	add    $0x8,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 05                	js     801270 <fd_close+0x2d>
	    || fd != fd2)
  80126b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80126e:	74 0c                	je     80127c <fd_close+0x39>
		return (must_exist ? r : 0);
  801270:	84 db                	test   %bl,%bl
  801272:	ba 00 00 00 00       	mov    $0x0,%edx
  801277:	0f 44 c2             	cmove  %edx,%eax
  80127a:	eb 41                	jmp    8012bd <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80127c:	83 ec 08             	sub    $0x8,%esp
  80127f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 36                	pushl  (%esi)
  801285:	e8 66 ff ff ff       	call   8011f0 <dev_lookup>
  80128a:	89 c3                	mov    %eax,%ebx
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 1a                	js     8012ad <fd_close+0x6a>
		if (dev->dev_close)
  801293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801296:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801299:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	74 0b                	je     8012ad <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012a2:	83 ec 0c             	sub    $0xc,%esp
  8012a5:	56                   	push   %esi
  8012a6:	ff d0                	call   *%eax
  8012a8:	89 c3                	mov    %eax,%ebx
  8012aa:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	56                   	push   %esi
  8012b1:	6a 00                	push   $0x0
  8012b3:	e8 53 f9 ff ff       	call   800c0b <sys_page_unmap>
	return r;
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	89 d8                	mov    %ebx,%eax
}
  8012bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cd:	50                   	push   %eax
  8012ce:	ff 75 08             	pushl  0x8(%ebp)
  8012d1:	e8 c4 fe ff ff       	call   80119a <fd_lookup>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	78 10                	js     8012ed <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012dd:	83 ec 08             	sub    $0x8,%esp
  8012e0:	6a 01                	push   $0x1
  8012e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e5:	e8 59 ff ff ff       	call   801243 <fd_close>
  8012ea:	83 c4 10             	add    $0x10,%esp
}
  8012ed:	c9                   	leave  
  8012ee:	c3                   	ret    

008012ef <close_all>:

void
close_all(void)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	53                   	push   %ebx
  8012ff:	e8 c0 ff ff ff       	call   8012c4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801304:	83 c3 01             	add    $0x1,%ebx
  801307:	83 c4 10             	add    $0x10,%esp
  80130a:	83 fb 20             	cmp    $0x20,%ebx
  80130d:	75 ec                	jne    8012fb <close_all+0xc>
		close(i);
}
  80130f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	57                   	push   %edi
  801318:	56                   	push   %esi
  801319:	53                   	push   %ebx
  80131a:	83 ec 2c             	sub    $0x2c,%esp
  80131d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801320:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	ff 75 08             	pushl  0x8(%ebp)
  801327:	e8 6e fe ff ff       	call   80119a <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	0f 88 c1 00 00 00    	js     8013f8 <dup+0xe4>
		return r;
	close(newfdnum);
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	56                   	push   %esi
  80133b:	e8 84 ff ff ff       	call   8012c4 <close>

	newfd = INDEX2FD(newfdnum);
  801340:	89 f3                	mov    %esi,%ebx
  801342:	c1 e3 0c             	shl    $0xc,%ebx
  801345:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80134b:	83 c4 04             	add    $0x4,%esp
  80134e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801351:	e8 de fd ff ff       	call   801134 <fd2data>
  801356:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801358:	89 1c 24             	mov    %ebx,(%esp)
  80135b:	e8 d4 fd ff ff       	call   801134 <fd2data>
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801366:	89 f8                	mov    %edi,%eax
  801368:	c1 e8 16             	shr    $0x16,%eax
  80136b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801372:	a8 01                	test   $0x1,%al
  801374:	74 37                	je     8013ad <dup+0x99>
  801376:	89 f8                	mov    %edi,%eax
  801378:	c1 e8 0c             	shr    $0xc,%eax
  80137b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801382:	f6 c2 01             	test   $0x1,%dl
  801385:	74 26                	je     8013ad <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801387:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	25 07 0e 00 00       	and    $0xe07,%eax
  801396:	50                   	push   %eax
  801397:	ff 75 d4             	pushl  -0x2c(%ebp)
  80139a:	6a 00                	push   $0x0
  80139c:	57                   	push   %edi
  80139d:	6a 00                	push   $0x0
  80139f:	e8 25 f8 ff ff       	call   800bc9 <sys_page_map>
  8013a4:	89 c7                	mov    %eax,%edi
  8013a6:	83 c4 20             	add    $0x20,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 2e                	js     8013db <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ad:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013b0:	89 d0                	mov    %edx,%eax
  8013b2:	c1 e8 0c             	shr    $0xc,%eax
  8013b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013bc:	83 ec 0c             	sub    $0xc,%esp
  8013bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8013c4:	50                   	push   %eax
  8013c5:	53                   	push   %ebx
  8013c6:	6a 00                	push   $0x0
  8013c8:	52                   	push   %edx
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 f9 f7 ff ff       	call   800bc9 <sys_page_map>
  8013d0:	89 c7                	mov    %eax,%edi
  8013d2:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013d5:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013d7:	85 ff                	test   %edi,%edi
  8013d9:	79 1d                	jns    8013f8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	53                   	push   %ebx
  8013df:	6a 00                	push   $0x0
  8013e1:	e8 25 f8 ff ff       	call   800c0b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013e6:	83 c4 08             	add    $0x8,%esp
  8013e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ec:	6a 00                	push   $0x0
  8013ee:	e8 18 f8 ff ff       	call   800c0b <sys_page_unmap>
	return r;
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	89 f8                	mov    %edi,%eax
}
  8013f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5f                   	pop    %edi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 14             	sub    $0x14,%esp
  801407:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	53                   	push   %ebx
  80140f:	e8 86 fd ff ff       	call   80119a <fd_lookup>
  801414:	83 c4 08             	add    $0x8,%esp
  801417:	89 c2                	mov    %eax,%edx
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 6d                	js     80148a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801427:	ff 30                	pushl  (%eax)
  801429:	e8 c2 fd ff ff       	call   8011f0 <dev_lookup>
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 c0                	test   %eax,%eax
  801433:	78 4c                	js     801481 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801435:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801438:	8b 42 08             	mov    0x8(%edx),%eax
  80143b:	83 e0 03             	and    $0x3,%eax
  80143e:	83 f8 01             	cmp    $0x1,%eax
  801441:	75 21                	jne    801464 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801443:	a1 04 40 80 00       	mov    0x804004,%eax
  801448:	8b 40 48             	mov    0x48(%eax),%eax
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	53                   	push   %ebx
  80144f:	50                   	push   %eax
  801450:	68 25 28 80 00       	push   $0x802825
  801455:	e8 5a ed ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801462:	eb 26                	jmp    80148a <read+0x8a>
	}
	if (!dev->dev_read)
  801464:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801467:	8b 40 08             	mov    0x8(%eax),%eax
  80146a:	85 c0                	test   %eax,%eax
  80146c:	74 17                	je     801485 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	ff 75 10             	pushl  0x10(%ebp)
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	52                   	push   %edx
  801478:	ff d0                	call   *%eax
  80147a:	89 c2                	mov    %eax,%edx
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	eb 09                	jmp    80148a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801481:	89 c2                	mov    %eax,%edx
  801483:	eb 05                	jmp    80148a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801485:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80148a:	89 d0                	mov    %edx,%eax
  80148c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	57                   	push   %edi
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	83 ec 0c             	sub    $0xc,%esp
  80149a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80149d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a5:	eb 21                	jmp    8014c8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014a7:	83 ec 04             	sub    $0x4,%esp
  8014aa:	89 f0                	mov    %esi,%eax
  8014ac:	29 d8                	sub    %ebx,%eax
  8014ae:	50                   	push   %eax
  8014af:	89 d8                	mov    %ebx,%eax
  8014b1:	03 45 0c             	add    0xc(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	57                   	push   %edi
  8014b6:	e8 45 ff ff ff       	call   801400 <read>
		if (m < 0)
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 10                	js     8014d2 <readn+0x41>
			return m;
		if (m == 0)
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	74 0a                	je     8014d0 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014c6:	01 c3                	add    %eax,%ebx
  8014c8:	39 f3                	cmp    %esi,%ebx
  8014ca:	72 db                	jb     8014a7 <readn+0x16>
  8014cc:	89 d8                	mov    %ebx,%eax
  8014ce:	eb 02                	jmp    8014d2 <readn+0x41>
  8014d0:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5e                   	pop    %esi
  8014d7:	5f                   	pop    %edi
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 14             	sub    $0x14,%esp
  8014e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e7:	50                   	push   %eax
  8014e8:	53                   	push   %ebx
  8014e9:	e8 ac fc ff ff       	call   80119a <fd_lookup>
  8014ee:	83 c4 08             	add    $0x8,%esp
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 68                	js     80155f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fd:	50                   	push   %eax
  8014fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801501:	ff 30                	pushl  (%eax)
  801503:	e8 e8 fc ff ff       	call   8011f0 <dev_lookup>
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 47                	js     801556 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801512:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801516:	75 21                	jne    801539 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801518:	a1 04 40 80 00       	mov    0x804004,%eax
  80151d:	8b 40 48             	mov    0x48(%eax),%eax
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	53                   	push   %ebx
  801524:	50                   	push   %eax
  801525:	68 41 28 80 00       	push   $0x802841
  80152a:	e8 85 ec ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801537:	eb 26                	jmp    80155f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801539:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80153c:	8b 52 0c             	mov    0xc(%edx),%edx
  80153f:	85 d2                	test   %edx,%edx
  801541:	74 17                	je     80155a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801543:	83 ec 04             	sub    $0x4,%esp
  801546:	ff 75 10             	pushl  0x10(%ebp)
  801549:	ff 75 0c             	pushl  0xc(%ebp)
  80154c:	50                   	push   %eax
  80154d:	ff d2                	call   *%edx
  80154f:	89 c2                	mov    %eax,%edx
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	eb 09                	jmp    80155f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801556:	89 c2                	mov    %eax,%edx
  801558:	eb 05                	jmp    80155f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80155a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80155f:	89 d0                	mov    %edx,%eax
  801561:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801564:	c9                   	leave  
  801565:	c3                   	ret    

00801566 <seek>:

int
seek(int fdnum, off_t offset)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80156f:	50                   	push   %eax
  801570:	ff 75 08             	pushl  0x8(%ebp)
  801573:	e8 22 fc ff ff       	call   80119a <fd_lookup>
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 0e                	js     80158d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80157f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801582:	8b 55 0c             	mov    0xc(%ebp),%edx
  801585:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801588:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	53                   	push   %ebx
  801593:	83 ec 14             	sub    $0x14,%esp
  801596:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801599:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	53                   	push   %ebx
  80159e:	e8 f7 fb ff ff       	call   80119a <fd_lookup>
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	89 c2                	mov    %eax,%edx
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 65                	js     801611 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b6:	ff 30                	pushl  (%eax)
  8015b8:	e8 33 fc ff ff       	call   8011f0 <dev_lookup>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	85 c0                	test   %eax,%eax
  8015c2:	78 44                	js     801608 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015cb:	75 21                	jne    8015ee <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015cd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015d2:	8b 40 48             	mov    0x48(%eax),%eax
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	50                   	push   %eax
  8015da:	68 04 28 80 00       	push   $0x802804
  8015df:	e8 d0 eb ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ec:	eb 23                	jmp    801611 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f1:	8b 52 18             	mov    0x18(%edx),%edx
  8015f4:	85 d2                	test   %edx,%edx
  8015f6:	74 14                	je     80160c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	ff 75 0c             	pushl  0xc(%ebp)
  8015fe:	50                   	push   %eax
  8015ff:	ff d2                	call   *%edx
  801601:	89 c2                	mov    %eax,%edx
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	eb 09                	jmp    801611 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801608:	89 c2                	mov    %eax,%edx
  80160a:	eb 05                	jmp    801611 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80160c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801611:	89 d0                	mov    %edx,%eax
  801613:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801616:	c9                   	leave  
  801617:	c3                   	ret    

00801618 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	53                   	push   %ebx
  80161c:	83 ec 14             	sub    $0x14,%esp
  80161f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801622:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	ff 75 08             	pushl  0x8(%ebp)
  801629:	e8 6c fb ff ff       	call   80119a <fd_lookup>
  80162e:	83 c4 08             	add    $0x8,%esp
  801631:	89 c2                	mov    %eax,%edx
  801633:	85 c0                	test   %eax,%eax
  801635:	78 58                	js     80168f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801637:	83 ec 08             	sub    $0x8,%esp
  80163a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801641:	ff 30                	pushl  (%eax)
  801643:	e8 a8 fb ff ff       	call   8011f0 <dev_lookup>
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 37                	js     801686 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801652:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801656:	74 32                	je     80168a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801658:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80165b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801662:	00 00 00 
	stat->st_isdir = 0;
  801665:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80166c:	00 00 00 
	stat->st_dev = dev;
  80166f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	53                   	push   %ebx
  801679:	ff 75 f0             	pushl  -0x10(%ebp)
  80167c:	ff 50 14             	call   *0x14(%eax)
  80167f:	89 c2                	mov    %eax,%edx
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	eb 09                	jmp    80168f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801686:	89 c2                	mov    %eax,%edx
  801688:	eb 05                	jmp    80168f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80168a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80168f:	89 d0                	mov    %edx,%eax
  801691:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80169b:	83 ec 08             	sub    $0x8,%esp
  80169e:	6a 00                	push   $0x0
  8016a0:	ff 75 08             	pushl  0x8(%ebp)
  8016a3:	e8 dc 01 00 00       	call   801884 <open>
  8016a8:	89 c3                	mov    %eax,%ebx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 1b                	js     8016cc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	ff 75 0c             	pushl  0xc(%ebp)
  8016b7:	50                   	push   %eax
  8016b8:	e8 5b ff ff ff       	call   801618 <fstat>
  8016bd:	89 c6                	mov    %eax,%esi
	close(fd);
  8016bf:	89 1c 24             	mov    %ebx,(%esp)
  8016c2:	e8 fd fb ff ff       	call   8012c4 <close>
	return r;
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	89 f0                	mov    %esi,%eax
}
  8016cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5e                   	pop    %esi
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	56                   	push   %esi
  8016d7:	53                   	push   %ebx
  8016d8:	89 c6                	mov    %eax,%esi
  8016da:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016dc:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016e3:	75 12                	jne    8016f7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e5:	83 ec 0c             	sub    $0xc,%esp
  8016e8:	6a 01                	push   $0x1
  8016ea:	e8 87 08 00 00       	call   801f76 <ipc_find_env>
  8016ef:	a3 00 40 80 00       	mov    %eax,0x804000
  8016f4:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016f7:	6a 07                	push   $0x7
  8016f9:	68 00 50 80 00       	push   $0x805000
  8016fe:	56                   	push   %esi
  8016ff:	ff 35 00 40 80 00    	pushl  0x804000
  801705:	e8 29 08 00 00       	call   801f33 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80170a:	83 c4 0c             	add    $0xc,%esp
  80170d:	6a 00                	push   $0x0
  80170f:	53                   	push   %ebx
  801710:	6a 00                	push   $0x0
  801712:	e8 bf 07 00 00       	call   801ed6 <ipc_recv>
}
  801717:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801724:	8b 45 08             	mov    0x8(%ebp),%eax
  801727:	8b 40 0c             	mov    0xc(%eax),%eax
  80172a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80172f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801732:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801737:	ba 00 00 00 00       	mov    $0x0,%edx
  80173c:	b8 02 00 00 00       	mov    $0x2,%eax
  801741:	e8 8d ff ff ff       	call   8016d3 <fsipc>
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 40 0c             	mov    0xc(%eax),%eax
  801754:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 06 00 00 00       	mov    $0x6,%eax
  801763:	e8 6b ff ff ff       	call   8016d3 <fsipc>
}
  801768:	c9                   	leave  
  801769:	c3                   	ret    

0080176a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	8b 40 0c             	mov    0xc(%eax),%eax
  80177a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 05 00 00 00       	mov    $0x5,%eax
  801789:	e8 45 ff ff ff       	call   8016d3 <fsipc>
  80178e:	85 c0                	test   %eax,%eax
  801790:	78 2c                	js     8017be <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	68 00 50 80 00       	push   $0x805000
  80179a:	53                   	push   %ebx
  80179b:	e8 e3 ef ff ff       	call   800783 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017a0:	a1 80 50 80 00       	mov    0x805080,%eax
  8017a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ab:	a1 84 50 80 00       	mov    0x805084,%eax
  8017b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	83 ec 0c             	sub    $0xc,%esp
  8017c9:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cf:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017d8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017dd:	50                   	push   %eax
  8017de:	ff 75 0c             	pushl  0xc(%ebp)
  8017e1:	68 08 50 80 00       	push   $0x805008
  8017e6:	e8 2a f1 ff ff       	call   800915 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8017eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f5:	e8 d9 fe ff ff       	call   8016d3 <fsipc>
	//panic("devfile_write not implemented");
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801804:	8b 45 08             	mov    0x8(%ebp),%eax
  801807:	8b 40 0c             	mov    0xc(%eax),%eax
  80180a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80180f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
  80181a:	b8 03 00 00 00       	mov    $0x3,%eax
  80181f:	e8 af fe ff ff       	call   8016d3 <fsipc>
  801824:	89 c3                	mov    %eax,%ebx
  801826:	85 c0                	test   %eax,%eax
  801828:	78 51                	js     80187b <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80182a:	39 c6                	cmp    %eax,%esi
  80182c:	73 19                	jae    801847 <devfile_read+0x4b>
  80182e:	68 70 28 80 00       	push   $0x802870
  801833:	68 77 28 80 00       	push   $0x802877
  801838:	68 80 00 00 00       	push   $0x80
  80183d:	68 8c 28 80 00       	push   $0x80288c
  801842:	e8 c0 05 00 00       	call   801e07 <_panic>
	assert(r <= PGSIZE);
  801847:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80184c:	7e 19                	jle    801867 <devfile_read+0x6b>
  80184e:	68 97 28 80 00       	push   $0x802897
  801853:	68 77 28 80 00       	push   $0x802877
  801858:	68 81 00 00 00       	push   $0x81
  80185d:	68 8c 28 80 00       	push   $0x80288c
  801862:	e8 a0 05 00 00       	call   801e07 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801867:	83 ec 04             	sub    $0x4,%esp
  80186a:	50                   	push   %eax
  80186b:	68 00 50 80 00       	push   $0x805000
  801870:	ff 75 0c             	pushl  0xc(%ebp)
  801873:	e8 9d f0 ff ff       	call   800915 <memmove>
	return r;
  801878:	83 c4 10             	add    $0x10,%esp
}
  80187b:	89 d8                	mov    %ebx,%eax
  80187d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	53                   	push   %ebx
  801888:	83 ec 20             	sub    $0x20,%esp
  80188b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80188e:	53                   	push   %ebx
  80188f:	e8 b6 ee ff ff       	call   80074a <strlen>
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80189c:	7f 67                	jg     801905 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80189e:	83 ec 0c             	sub    $0xc,%esp
  8018a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a4:	50                   	push   %eax
  8018a5:	e8 a1 f8 ff ff       	call   80114b <fd_alloc>
  8018aa:	83 c4 10             	add    $0x10,%esp
		return r;
  8018ad:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	78 57                	js     80190a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	53                   	push   %ebx
  8018b7:	68 00 50 80 00       	push   $0x805000
  8018bc:	e8 c2 ee ff ff       	call   800783 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c4:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8018d1:	e8 fd fd ff ff       	call   8016d3 <fsipc>
  8018d6:	89 c3                	mov    %eax,%ebx
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	79 14                	jns    8018f3 <open+0x6f>
		
		fd_close(fd, 0);
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	6a 00                	push   $0x0
  8018e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e7:	e8 57 f9 ff ff       	call   801243 <fd_close>
		return r;
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	89 da                	mov    %ebx,%edx
  8018f1:	eb 17                	jmp    80190a <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8018f3:	83 ec 0c             	sub    $0xc,%esp
  8018f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f9:	e8 26 f8 ff ff       	call   801124 <fd2num>
  8018fe:	89 c2                	mov    %eax,%edx
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	eb 05                	jmp    80190a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801905:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  80190a:	89 d0                	mov    %edx,%eax
  80190c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801917:	ba 00 00 00 00       	mov    $0x0,%edx
  80191c:	b8 08 00 00 00       	mov    $0x8,%eax
  801921:	e8 ad fd ff ff       	call   8016d3 <fsipc>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	ff 75 08             	pushl  0x8(%ebp)
  801936:	e8 f9 f7 ff ff       	call   801134 <fd2data>
  80193b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80193d:	83 c4 08             	add    $0x8,%esp
  801940:	68 a3 28 80 00       	push   $0x8028a3
  801945:	53                   	push   %ebx
  801946:	e8 38 ee ff ff       	call   800783 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80194b:	8b 46 04             	mov    0x4(%esi),%eax
  80194e:	2b 06                	sub    (%esi),%eax
  801950:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801956:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80195d:	00 00 00 
	stat->st_dev = &devpipe;
  801960:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801967:	30 80 00 
	return 0;
}
  80196a:	b8 00 00 00 00       	mov    $0x0,%eax
  80196f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801972:	5b                   	pop    %ebx
  801973:	5e                   	pop    %esi
  801974:	5d                   	pop    %ebp
  801975:	c3                   	ret    

00801976 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801976:	55                   	push   %ebp
  801977:	89 e5                	mov    %esp,%ebp
  801979:	53                   	push   %ebx
  80197a:	83 ec 0c             	sub    $0xc,%esp
  80197d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801980:	53                   	push   %ebx
  801981:	6a 00                	push   $0x0
  801983:	e8 83 f2 ff ff       	call   800c0b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801988:	89 1c 24             	mov    %ebx,(%esp)
  80198b:	e8 a4 f7 ff ff       	call   801134 <fd2data>
  801990:	83 c4 08             	add    $0x8,%esp
  801993:	50                   	push   %eax
  801994:	6a 00                	push   $0x0
  801996:	e8 70 f2 ff ff       	call   800c0b <sys_page_unmap>
}
  80199b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199e:	c9                   	leave  
  80199f:	c3                   	ret    

008019a0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	57                   	push   %edi
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 1c             	sub    $0x1c,%esp
  8019a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019ac:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8019b3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019b6:	83 ec 0c             	sub    $0xc,%esp
  8019b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8019bc:	e8 ee 05 00 00       	call   801faf <pageref>
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	89 3c 24             	mov    %edi,(%esp)
  8019c6:	e8 e4 05 00 00       	call   801faf <pageref>
  8019cb:	83 c4 10             	add    $0x10,%esp
  8019ce:	39 c3                	cmp    %eax,%ebx
  8019d0:	0f 94 c1             	sete   %cl
  8019d3:	0f b6 c9             	movzbl %cl,%ecx
  8019d6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019d9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019df:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019e2:	39 ce                	cmp    %ecx,%esi
  8019e4:	74 1b                	je     801a01 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019e6:	39 c3                	cmp    %eax,%ebx
  8019e8:	75 c4                	jne    8019ae <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ea:	8b 42 58             	mov    0x58(%edx),%eax
  8019ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019f0:	50                   	push   %eax
  8019f1:	56                   	push   %esi
  8019f2:	68 aa 28 80 00       	push   $0x8028aa
  8019f7:	e8 b8 e7 ff ff       	call   8001b4 <cprintf>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	eb ad                	jmp    8019ae <_pipeisclosed+0xe>
	}
}
  801a01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a07:	5b                   	pop    %ebx
  801a08:	5e                   	pop    %esi
  801a09:	5f                   	pop    %edi
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	57                   	push   %edi
  801a10:	56                   	push   %esi
  801a11:	53                   	push   %ebx
  801a12:	83 ec 28             	sub    $0x28,%esp
  801a15:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a18:	56                   	push   %esi
  801a19:	e8 16 f7 ff ff       	call   801134 <fd2data>
  801a1e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	bf 00 00 00 00       	mov    $0x0,%edi
  801a28:	eb 4b                	jmp    801a75 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a2a:	89 da                	mov    %ebx,%edx
  801a2c:	89 f0                	mov    %esi,%eax
  801a2e:	e8 6d ff ff ff       	call   8019a0 <_pipeisclosed>
  801a33:	85 c0                	test   %eax,%eax
  801a35:	75 48                	jne    801a7f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a37:	e8 2b f1 ff ff       	call   800b67 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801a3f:	8b 0b                	mov    (%ebx),%ecx
  801a41:	8d 51 20             	lea    0x20(%ecx),%edx
  801a44:	39 d0                	cmp    %edx,%eax
  801a46:	73 e2                	jae    801a2a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a4b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a4f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a52:	89 c2                	mov    %eax,%edx
  801a54:	c1 fa 1f             	sar    $0x1f,%edx
  801a57:	89 d1                	mov    %edx,%ecx
  801a59:	c1 e9 1b             	shr    $0x1b,%ecx
  801a5c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a5f:	83 e2 1f             	and    $0x1f,%edx
  801a62:	29 ca                	sub    %ecx,%edx
  801a64:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a68:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a6c:	83 c0 01             	add    $0x1,%eax
  801a6f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a72:	83 c7 01             	add    $0x1,%edi
  801a75:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a78:	75 c2                	jne    801a3c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7d:	eb 05                	jmp    801a84 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a7f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5f                   	pop    %edi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	57                   	push   %edi
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	83 ec 18             	sub    $0x18,%esp
  801a95:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a98:	57                   	push   %edi
  801a99:	e8 96 f6 ff ff       	call   801134 <fd2data>
  801a9e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aa8:	eb 3d                	jmp    801ae7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	74 04                	je     801ab2 <devpipe_read+0x26>
				return i;
  801aae:	89 d8                	mov    %ebx,%eax
  801ab0:	eb 44                	jmp    801af6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ab2:	89 f2                	mov    %esi,%edx
  801ab4:	89 f8                	mov    %edi,%eax
  801ab6:	e8 e5 fe ff ff       	call   8019a0 <_pipeisclosed>
  801abb:	85 c0                	test   %eax,%eax
  801abd:	75 32                	jne    801af1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801abf:	e8 a3 f0 ff ff       	call   800b67 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ac4:	8b 06                	mov    (%esi),%eax
  801ac6:	3b 46 04             	cmp    0x4(%esi),%eax
  801ac9:	74 df                	je     801aaa <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801acb:	99                   	cltd   
  801acc:	c1 ea 1b             	shr    $0x1b,%edx
  801acf:	01 d0                	add    %edx,%eax
  801ad1:	83 e0 1f             	and    $0x1f,%eax
  801ad4:	29 d0                	sub    %edx,%eax
  801ad6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801adb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ade:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ae1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae4:	83 c3 01             	add    $0x1,%ebx
  801ae7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801aea:	75 d8                	jne    801ac4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801aec:	8b 45 10             	mov    0x10(%ebp),%eax
  801aef:	eb 05                	jmp    801af6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801af1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af9:	5b                   	pop    %ebx
  801afa:	5e                   	pop    %esi
  801afb:	5f                   	pop    %edi
  801afc:	5d                   	pop    %ebp
  801afd:	c3                   	ret    

00801afe <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b09:	50                   	push   %eax
  801b0a:	e8 3c f6 ff ff       	call   80114b <fd_alloc>
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	85 c0                	test   %eax,%eax
  801b16:	0f 88 2c 01 00 00    	js     801c48 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1c:	83 ec 04             	sub    $0x4,%esp
  801b1f:	68 07 04 00 00       	push   $0x407
  801b24:	ff 75 f4             	pushl  -0xc(%ebp)
  801b27:	6a 00                	push   $0x0
  801b29:	e8 58 f0 ff ff       	call   800b86 <sys_page_alloc>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	89 c2                	mov    %eax,%edx
  801b33:	85 c0                	test   %eax,%eax
  801b35:	0f 88 0d 01 00 00    	js     801c48 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b3b:	83 ec 0c             	sub    $0xc,%esp
  801b3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b41:	50                   	push   %eax
  801b42:	e8 04 f6 ff ff       	call   80114b <fd_alloc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	0f 88 e2 00 00 00    	js     801c36 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b54:	83 ec 04             	sub    $0x4,%esp
  801b57:	68 07 04 00 00       	push   $0x407
  801b5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5f:	6a 00                	push   $0x0
  801b61:	e8 20 f0 ff ff       	call   800b86 <sys_page_alloc>
  801b66:	89 c3                	mov    %eax,%ebx
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	0f 88 c3 00 00 00    	js     801c36 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	ff 75 f4             	pushl  -0xc(%ebp)
  801b79:	e8 b6 f5 ff ff       	call   801134 <fd2data>
  801b7e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b80:	83 c4 0c             	add    $0xc,%esp
  801b83:	68 07 04 00 00       	push   $0x407
  801b88:	50                   	push   %eax
  801b89:	6a 00                	push   $0x0
  801b8b:	e8 f6 ef ff ff       	call   800b86 <sys_page_alloc>
  801b90:	89 c3                	mov    %eax,%ebx
  801b92:	83 c4 10             	add    $0x10,%esp
  801b95:	85 c0                	test   %eax,%eax
  801b97:	0f 88 89 00 00 00    	js     801c26 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b9d:	83 ec 0c             	sub    $0xc,%esp
  801ba0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba3:	e8 8c f5 ff ff       	call   801134 <fd2data>
  801ba8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801baf:	50                   	push   %eax
  801bb0:	6a 00                	push   $0x0
  801bb2:	56                   	push   %esi
  801bb3:	6a 00                	push   $0x0
  801bb5:	e8 0f f0 ff ff       	call   800bc9 <sys_page_map>
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	83 c4 20             	add    $0x20,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 55                	js     801c18 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801bc3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bd8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801be6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bed:	83 ec 0c             	sub    $0xc,%esp
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	e8 2c f5 ff ff       	call   801124 <fd2num>
  801bf8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bfb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bfd:	83 c4 04             	add    $0x4,%esp
  801c00:	ff 75 f0             	pushl  -0x10(%ebp)
  801c03:	e8 1c f5 ff ff       	call   801124 <fd2num>
  801c08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	ba 00 00 00 00       	mov    $0x0,%edx
  801c16:	eb 30                	jmp    801c48 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c18:	83 ec 08             	sub    $0x8,%esp
  801c1b:	56                   	push   %esi
  801c1c:	6a 00                	push   $0x0
  801c1e:	e8 e8 ef ff ff       	call   800c0b <sys_page_unmap>
  801c23:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c26:	83 ec 08             	sub    $0x8,%esp
  801c29:	ff 75 f0             	pushl  -0x10(%ebp)
  801c2c:	6a 00                	push   $0x0
  801c2e:	e8 d8 ef ff ff       	call   800c0b <sys_page_unmap>
  801c33:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c36:	83 ec 08             	sub    $0x8,%esp
  801c39:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3c:	6a 00                	push   $0x0
  801c3e:	e8 c8 ef ff ff       	call   800c0b <sys_page_unmap>
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c48:	89 d0                	mov    %edx,%eax
  801c4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	ff 75 08             	pushl  0x8(%ebp)
  801c5e:	e8 37 f5 ff ff       	call   80119a <fd_lookup>
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 18                	js     801c82 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c70:	e8 bf f4 ff ff       	call   801134 <fd2data>
	return _pipeisclosed(fd, p);
  801c75:	89 c2                	mov    %eax,%edx
  801c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c7a:	e8 21 fd ff ff       	call   8019a0 <_pipeisclosed>
  801c7f:	83 c4 10             	add    $0x10,%esp
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c87:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8c:	5d                   	pop    %ebp
  801c8d:	c3                   	ret    

00801c8e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c94:	68 c2 28 80 00       	push   $0x8028c2
  801c99:	ff 75 0c             	pushl  0xc(%ebp)
  801c9c:	e8 e2 ea ff ff       	call   800783 <strcpy>
	return 0;
}
  801ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	57                   	push   %edi
  801cac:	56                   	push   %esi
  801cad:	53                   	push   %ebx
  801cae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cb4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cb9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cbf:	eb 2d                	jmp    801cee <devcons_write+0x46>
		m = n - tot;
  801cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801cc4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cc6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cc9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cce:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cd1:	83 ec 04             	sub    $0x4,%esp
  801cd4:	53                   	push   %ebx
  801cd5:	03 45 0c             	add    0xc(%ebp),%eax
  801cd8:	50                   	push   %eax
  801cd9:	57                   	push   %edi
  801cda:	e8 36 ec ff ff       	call   800915 <memmove>
		sys_cputs(buf, m);
  801cdf:	83 c4 08             	add    $0x8,%esp
  801ce2:	53                   	push   %ebx
  801ce3:	57                   	push   %edi
  801ce4:	e8 e1 ed ff ff       	call   800aca <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce9:	01 de                	add    %ebx,%esi
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	89 f0                	mov    %esi,%eax
  801cf0:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cf3:	72 cc                	jb     801cc1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf8:	5b                   	pop    %ebx
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    

00801cfd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	83 ec 08             	sub    $0x8,%esp
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d0c:	74 2a                	je     801d38 <devcons_read+0x3b>
  801d0e:	eb 05                	jmp    801d15 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d10:	e8 52 ee ff ff       	call   800b67 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d15:	e8 ce ed ff ff       	call   800ae8 <sys_cgetc>
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	74 f2                	je     801d10 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 16                	js     801d38 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d22:	83 f8 04             	cmp    $0x4,%eax
  801d25:	74 0c                	je     801d33 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2a:	88 02                	mov    %al,(%edx)
	return 1;
  801d2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801d31:	eb 05                	jmp    801d38 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d33:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d40:	8b 45 08             	mov    0x8(%ebp),%eax
  801d43:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d46:	6a 01                	push   $0x1
  801d48:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d4b:	50                   	push   %eax
  801d4c:	e8 79 ed ff ff       	call   800aca <sys_cputs>
}
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <getchar>:

int
getchar(void)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d5c:	6a 01                	push   $0x1
  801d5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d61:	50                   	push   %eax
  801d62:	6a 00                	push   $0x0
  801d64:	e8 97 f6 ff ff       	call   801400 <read>
	if (r < 0)
  801d69:	83 c4 10             	add    $0x10,%esp
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 0f                	js     801d7f <getchar+0x29>
		return r;
	if (r < 1)
  801d70:	85 c0                	test   %eax,%eax
  801d72:	7e 06                	jle    801d7a <getchar+0x24>
		return -E_EOF;
	return c;
  801d74:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d78:	eb 05                	jmp    801d7f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d7a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8a:	50                   	push   %eax
  801d8b:	ff 75 08             	pushl  0x8(%ebp)
  801d8e:	e8 07 f4 ff ff       	call   80119a <fd_lookup>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 11                	js     801dab <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801da3:	39 10                	cmp    %edx,(%eax)
  801da5:	0f 94 c0             	sete   %al
  801da8:	0f b6 c0             	movzbl %al,%eax
}
  801dab:	c9                   	leave  
  801dac:	c3                   	ret    

00801dad <opencons>:

int
opencons(void)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801db3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db6:	50                   	push   %eax
  801db7:	e8 8f f3 ff ff       	call   80114b <fd_alloc>
  801dbc:	83 c4 10             	add    $0x10,%esp
		return r;
  801dbf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	78 3e                	js     801e03 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc5:	83 ec 04             	sub    $0x4,%esp
  801dc8:	68 07 04 00 00       	push   $0x407
  801dcd:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd0:	6a 00                	push   $0x0
  801dd2:	e8 af ed ff ff       	call   800b86 <sys_page_alloc>
  801dd7:	83 c4 10             	add    $0x10,%esp
		return r;
  801dda:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	78 23                	js     801e03 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801de0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801df5:	83 ec 0c             	sub    $0xc,%esp
  801df8:	50                   	push   %eax
  801df9:	e8 26 f3 ff ff       	call   801124 <fd2num>
  801dfe:	89 c2                	mov    %eax,%edx
  801e00:	83 c4 10             	add    $0x10,%esp
}
  801e03:	89 d0                	mov    %edx,%eax
  801e05:	c9                   	leave  
  801e06:	c3                   	ret    

00801e07 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	56                   	push   %esi
  801e0b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e0c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e0f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e15:	e8 2e ed ff ff       	call   800b48 <sys_getenvid>
  801e1a:	83 ec 0c             	sub    $0xc,%esp
  801e1d:	ff 75 0c             	pushl  0xc(%ebp)
  801e20:	ff 75 08             	pushl  0x8(%ebp)
  801e23:	56                   	push   %esi
  801e24:	50                   	push   %eax
  801e25:	68 d0 28 80 00       	push   $0x8028d0
  801e2a:	e8 85 e3 ff ff       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e2f:	83 c4 18             	add    $0x18,%esp
  801e32:	53                   	push   %ebx
  801e33:	ff 75 10             	pushl  0x10(%ebp)
  801e36:	e8 28 e3 ff ff       	call   800163 <vcprintf>
	cprintf("\n");
  801e3b:	c7 04 24 0e 23 80 00 	movl   $0x80230e,(%esp)
  801e42:	e8 6d e3 ff ff       	call   8001b4 <cprintf>
  801e47:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e4a:	cc                   	int3   
  801e4b:	eb fd                	jmp    801e4a <_panic+0x43>

00801e4d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e4d:	55                   	push   %ebp
  801e4e:	89 e5                	mov    %esp,%ebp
  801e50:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801e53:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e5a:	75 4c                	jne    801ea8 <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801e5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e61:	8b 40 48             	mov    0x48(%eax),%eax
  801e64:	83 ec 04             	sub    $0x4,%esp
  801e67:	6a 07                	push   $0x7
  801e69:	68 00 f0 bf ee       	push   $0xeebff000
  801e6e:	50                   	push   %eax
  801e6f:	e8 12 ed ff ff       	call   800b86 <sys_page_alloc>
		if(retv != 0){
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	85 c0                	test   %eax,%eax
  801e79:	74 14                	je     801e8f <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801e7b:	83 ec 04             	sub    $0x4,%esp
  801e7e:	68 f4 28 80 00       	push   $0x8028f4
  801e83:	6a 27                	push   $0x27
  801e85:	68 20 29 80 00       	push   $0x802920
  801e8a:	e8 78 ff ff ff       	call   801e07 <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801e8f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e94:	8b 40 48             	mov    0x48(%eax),%eax
  801e97:	83 ec 08             	sub    $0x8,%esp
  801e9a:	68 b2 1e 80 00       	push   $0x801eb2
  801e9f:	50                   	push   %eax
  801ea0:	e8 2c ee ff ff       	call   800cd1 <sys_env_set_pgfault_upcall>
  801ea5:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  801eab:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801eb2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eb3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801eb8:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801eba:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801ebd:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801ec1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  801ec6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801eca:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801ecc:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801ecf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801ed0:	83 c4 04             	add    $0x4,%esp
	popfl
  801ed3:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801ed4:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ed5:	c3                   	ret    

00801ed6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ede:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801ee1:	83 ec 0c             	sub    $0xc,%esp
  801ee4:	ff 75 0c             	pushl  0xc(%ebp)
  801ee7:	e8 4a ee ff ff       	call   800d36 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	85 f6                	test   %esi,%esi
  801ef1:	74 1c                	je     801f0f <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801ef3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ef8:	8b 40 78             	mov    0x78(%eax),%eax
  801efb:	89 06                	mov    %eax,(%esi)
  801efd:	eb 10                	jmp    801f0f <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801eff:	83 ec 0c             	sub    $0xc,%esp
  801f02:	68 2e 29 80 00       	push   $0x80292e
  801f07:	e8 a8 e2 ff ff       	call   8001b4 <cprintf>
  801f0c:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801f0f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f14:	8b 50 74             	mov    0x74(%eax),%edx
  801f17:	85 d2                	test   %edx,%edx
  801f19:	74 e4                	je     801eff <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801f1b:	85 db                	test   %ebx,%ebx
  801f1d:	74 05                	je     801f24 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801f1f:	8b 40 74             	mov    0x74(%eax),%eax
  801f22:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801f24:	a1 04 40 80 00       	mov    0x804004,%eax
  801f29:	8b 40 70             	mov    0x70(%eax),%eax

}
  801f2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f2f:	5b                   	pop    %ebx
  801f30:	5e                   	pop    %esi
  801f31:	5d                   	pop    %ebp
  801f32:	c3                   	ret    

00801f33 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	57                   	push   %edi
  801f37:	56                   	push   %esi
  801f38:	53                   	push   %ebx
  801f39:	83 ec 0c             	sub    $0xc,%esp
  801f3c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801f45:	85 db                	test   %ebx,%ebx
  801f47:	75 13                	jne    801f5c <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801f49:	6a 00                	push   $0x0
  801f4b:	68 00 00 c0 ee       	push   $0xeec00000
  801f50:	56                   	push   %esi
  801f51:	57                   	push   %edi
  801f52:	e8 bc ed ff ff       	call   800d13 <sys_ipc_try_send>
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	eb 0e                	jmp    801f6a <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801f5c:	ff 75 14             	pushl  0x14(%ebp)
  801f5f:	53                   	push   %ebx
  801f60:	56                   	push   %esi
  801f61:	57                   	push   %edi
  801f62:	e8 ac ed ff ff       	call   800d13 <sys_ipc_try_send>
  801f67:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801f6a:	85 c0                	test   %eax,%eax
  801f6c:	75 d7                	jne    801f45 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f71:	5b                   	pop    %ebx
  801f72:	5e                   	pop    %esi
  801f73:	5f                   	pop    %edi
  801f74:	5d                   	pop    %ebp
  801f75:	c3                   	ret    

00801f76 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f7c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f81:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f84:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8a:	8b 52 50             	mov    0x50(%edx),%edx
  801f8d:	39 ca                	cmp    %ecx,%edx
  801f8f:	75 0d                	jne    801f9e <ipc_find_env+0x28>
			return envs[i].env_id;
  801f91:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f94:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f99:	8b 40 48             	mov    0x48(%eax),%eax
  801f9c:	eb 0f                	jmp    801fad <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f9e:	83 c0 01             	add    $0x1,%eax
  801fa1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa6:	75 d9                	jne    801f81 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb5:	89 d0                	mov    %edx,%eax
  801fb7:	c1 e8 16             	shr    $0x16,%eax
  801fba:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc6:	f6 c1 01             	test   $0x1,%cl
  801fc9:	74 1d                	je     801fe8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fcb:	c1 ea 0c             	shr    $0xc,%edx
  801fce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd5:	f6 c2 01             	test   $0x1,%dl
  801fd8:	74 0e                	je     801fe8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fda:	c1 ea 0c             	shr    $0xc,%edx
  801fdd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe4:	ef 
  801fe5:	0f b7 c0             	movzwl %ax,%eax
}
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
