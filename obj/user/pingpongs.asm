
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 84 0f 00 00       	call   800fc5 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 2a 0b 00 00       	call   800b7d <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 20 14 80 00       	push   $0x801420
  80005d:	e8 87 01 00 00       	call   8001e9 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 13 0b 00 00       	call   800b7d <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 3a 14 80 00       	push   $0x80143a
  800074:	e8 70 01 00 00       	call   8001e9 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 6f 0f 00 00       	call   800ff6 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 45 0f 00 00       	call   800fdf <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 ca 0a 00 00       	call   800b7d <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 50 14 80 00       	push   $0x801450
  8000c2:	e8 22 01 00 00       	call   8001e9 <cprintf>
		if (val == 10)
  8000c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 0c 0f 00 00       	call   800ff6 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 6f 0a 00 00       	call   800b7d <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014a:	6a 00                	push   $0x0
  80014c:	e8 eb 09 00 00       	call   800b3c <sys_env_destroy>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 13                	mov    (%ebx),%edx
  800162:	8d 42 01             	lea    0x1(%edx),%eax
  800165:	89 03                	mov    %eax,(%ebx)
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	75 1a                	jne    80018f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	68 ff 00 00 00       	push   $0xff
  80017d:	8d 43 08             	lea    0x8(%ebx),%eax
  800180:	50                   	push   %eax
  800181:	e8 79 09 00 00       	call   800aff <sys_cputs>
		b->idx = 0;
  800186:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80018c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800196:	c9                   	leave  
  800197:	c3                   	ret    

00800198 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001a1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a8:	00 00 00 
	b.cnt = 0;
  8001ab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c1:	50                   	push   %eax
  8001c2:	68 56 01 80 00       	push   $0x800156
  8001c7:	e8 54 01 00 00       	call   800320 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cc:	83 c4 08             	add    $0x8,%esp
  8001cf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 1e 09 00 00       	call   800aff <sys_cputs>

	return b.cnt;
}
  8001e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f2:	50                   	push   %eax
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	e8 9d ff ff ff       	call   800198 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 1c             	sub    $0x1c,%esp
  800206:	89 c7                	mov    %eax,%edi
  800208:	89 d6                	mov    %edx,%esi
  80020a:	8b 45 08             	mov    0x8(%ebp),%eax
  80020d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800210:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800213:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800216:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800221:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800224:	39 d3                	cmp    %edx,%ebx
  800226:	72 05                	jb     80022d <printnum+0x30>
  800228:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022b:	77 45                	ja     800272 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022d:	83 ec 0c             	sub    $0xc,%esp
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	8b 45 14             	mov    0x14(%ebp),%eax
  800236:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800239:	53                   	push   %ebx
  80023a:	ff 75 10             	pushl  0x10(%ebp)
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	ff 75 e4             	pushl  -0x1c(%ebp)
  800243:	ff 75 e0             	pushl  -0x20(%ebp)
  800246:	ff 75 dc             	pushl  -0x24(%ebp)
  800249:	ff 75 d8             	pushl  -0x28(%ebp)
  80024c:	e8 2f 0f 00 00       	call   801180 <__udivdi3>
  800251:	83 c4 18             	add    $0x18,%esp
  800254:	52                   	push   %edx
  800255:	50                   	push   %eax
  800256:	89 f2                	mov    %esi,%edx
  800258:	89 f8                	mov    %edi,%eax
  80025a:	e8 9e ff ff ff       	call   8001fd <printnum>
  80025f:	83 c4 20             	add    $0x20,%esp
  800262:	eb 18                	jmp    80027c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	ff d7                	call   *%edi
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	eb 03                	jmp    800275 <printnum+0x78>
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	85 db                	test   %ebx,%ebx
  80027a:	7f e8                	jg     800264 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	56                   	push   %esi
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	ff 75 e4             	pushl  -0x1c(%ebp)
  800286:	ff 75 e0             	pushl  -0x20(%ebp)
  800289:	ff 75 dc             	pushl  -0x24(%ebp)
  80028c:	ff 75 d8             	pushl  -0x28(%ebp)
  80028f:	e8 1c 10 00 00       	call   8012b0 <__umoddi3>
  800294:	83 c4 14             	add    $0x14,%esp
  800297:	0f be 80 80 14 80 00 	movsbl 0x801480(%eax),%eax
  80029e:	50                   	push   %eax
  80029f:	ff d7                	call   *%edi
}
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002af:	83 fa 01             	cmp    $0x1,%edx
  8002b2:	7e 0e                	jle    8002c2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b4:	8b 10                	mov    (%eax),%edx
  8002b6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b9:	89 08                	mov    %ecx,(%eax)
  8002bb:	8b 02                	mov    (%edx),%eax
  8002bd:	8b 52 04             	mov    0x4(%edx),%edx
  8002c0:	eb 22                	jmp    8002e4 <getuint+0x38>
	else if (lflag)
  8002c2:	85 d2                	test   %edx,%edx
  8002c4:	74 10                	je     8002d6 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d4:	eb 0e                	jmp    8002e4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ec:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f5:	73 0a                	jae    800301 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ff:	88 02                	mov    %al,(%edx)
}
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800309:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030c:	50                   	push   %eax
  80030d:	ff 75 10             	pushl  0x10(%ebp)
  800310:	ff 75 0c             	pushl  0xc(%ebp)
  800313:	ff 75 08             	pushl  0x8(%ebp)
  800316:	e8 05 00 00 00       	call   800320 <vprintfmt>
	va_end(ap);
}
  80031b:	83 c4 10             	add    $0x10,%esp
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 2c             	sub    $0x2c,%esp
  800329:	8b 75 08             	mov    0x8(%ebp),%esi
  80032c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800332:	eb 12                	jmp    800346 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800334:	85 c0                	test   %eax,%eax
  800336:	0f 84 d3 03 00 00    	je     80070f <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80033c:	83 ec 08             	sub    $0x8,%esp
  80033f:	53                   	push   %ebx
  800340:	50                   	push   %eax
  800341:	ff d6                	call   *%esi
  800343:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800346:	83 c7 01             	add    $0x1,%edi
  800349:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034d:	83 f8 25             	cmp    $0x25,%eax
  800350:	75 e2                	jne    800334 <vprintfmt+0x14>
  800352:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800356:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800364:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 07                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800375:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8d 47 01             	lea    0x1(%edi),%eax
  80037c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037f:	0f b6 07             	movzbl (%edi),%eax
  800382:	0f b6 c8             	movzbl %al,%ecx
  800385:	83 e8 23             	sub    $0x23,%eax
  800388:	3c 55                	cmp    $0x55,%al
  80038a:	0f 87 64 03 00 00    	ja     8006f4 <vprintfmt+0x3d4>
  800390:	0f b6 c0             	movzbl %al,%eax
  800393:	ff 24 85 40 15 80 00 	jmp    *0x801540(,%eax,4)
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a1:	eb d6                	jmp    800379 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ab:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003bb:	83 fa 09             	cmp    $0x9,%edx
  8003be:	77 39                	ja     8003f9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c3:	eb e9                	jmp    8003ae <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ce:	8b 00                	mov    (%eax),%eax
  8003d0:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d6:	eb 27                	jmp    8003ff <vprintfmt+0xdf>
  8003d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e2:	0f 49 c8             	cmovns %eax,%ecx
  8003e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	eb 8c                	jmp    800379 <vprintfmt+0x59>
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f7:	eb 80                	jmp    800379 <vprintfmt+0x59>
  8003f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003fc:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800403:	0f 89 70 ff ff ff    	jns    800379 <vprintfmt+0x59>
				width = precision, precision = -1;
  800409:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80040c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800416:	e9 5e ff ff ff       	jmp    800379 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80041b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800421:	e9 53 ff ff ff       	jmp    800379 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 50 04             	lea    0x4(%eax),%edx
  80042c:	89 55 14             	mov    %edx,0x14(%ebp)
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	53                   	push   %ebx
  800433:	ff 30                	pushl  (%eax)
  800435:	ff d6                	call   *%esi
			break;
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043d:	e9 04 ff ff ff       	jmp    800346 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	99                   	cltd   
  80044e:	31 d0                	xor    %edx,%eax
  800450:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800452:	83 f8 08             	cmp    $0x8,%eax
  800455:	7f 0b                	jg     800462 <vprintfmt+0x142>
  800457:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	75 18                	jne    80047a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800462:	50                   	push   %eax
  800463:	68 98 14 80 00       	push   $0x801498
  800468:	53                   	push   %ebx
  800469:	56                   	push   %esi
  80046a:	e8 94 fe ff ff       	call   800303 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800475:	e9 cc fe ff ff       	jmp    800346 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80047a:	52                   	push   %edx
  80047b:	68 a1 14 80 00       	push   $0x8014a1
  800480:	53                   	push   %ebx
  800481:	56                   	push   %esi
  800482:	e8 7c fe ff ff       	call   800303 <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048d:	e9 b4 fe ff ff       	jmp    800346 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049d:	85 ff                	test   %edi,%edi
  80049f:	b8 91 14 80 00       	mov    $0x801491,%eax
  8004a4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ab:	0f 8e 94 00 00 00    	jle    800545 <vprintfmt+0x225>
  8004b1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b5:	0f 84 98 00 00 00    	je     800553 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	ff 75 c8             	pushl  -0x38(%ebp)
  8004c1:	57                   	push   %edi
  8004c2:	e8 d0 02 00 00       	call   800797 <strnlen>
  8004c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ca:	29 c1                	sub    %eax,%ecx
  8004cc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004cf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004dc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004de:	eb 0f                	jmp    8004ef <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	53                   	push   %ebx
  8004e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	83 ef 01             	sub    $0x1,%edi
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	85 ff                	test   %edi,%edi
  8004f1:	7f ed                	jg     8004e0 <vprintfmt+0x1c0>
  8004f3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004f9:	85 c9                	test   %ecx,%ecx
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	0f 49 c1             	cmovns %ecx,%eax
  800503:	29 c1                	sub    %eax,%ecx
  800505:	89 75 08             	mov    %esi,0x8(%ebp)
  800508:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80050b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050e:	89 cb                	mov    %ecx,%ebx
  800510:	eb 4d                	jmp    80055f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800512:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800516:	74 1b                	je     800533 <vprintfmt+0x213>
  800518:	0f be c0             	movsbl %al,%eax
  80051b:	83 e8 20             	sub    $0x20,%eax
  80051e:	83 f8 5e             	cmp    $0x5e,%eax
  800521:	76 10                	jbe    800533 <vprintfmt+0x213>
					putch('?', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	ff 75 0c             	pushl  0xc(%ebp)
  800529:	6a 3f                	push   $0x3f
  80052b:	ff 55 08             	call   *0x8(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 0d                	jmp    800540 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	ff 75 0c             	pushl  0xc(%ebp)
  800539:	52                   	push   %edx
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800540:	83 eb 01             	sub    $0x1,%ebx
  800543:	eb 1a                	jmp    80055f <vprintfmt+0x23f>
  800545:	89 75 08             	mov    %esi,0x8(%ebp)
  800548:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80054b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800551:	eb 0c                	jmp    80055f <vprintfmt+0x23f>
  800553:	89 75 08             	mov    %esi,0x8(%ebp)
  800556:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800559:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055f:	83 c7 01             	add    $0x1,%edi
  800562:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800566:	0f be d0             	movsbl %al,%edx
  800569:	85 d2                	test   %edx,%edx
  80056b:	74 23                	je     800590 <vprintfmt+0x270>
  80056d:	85 f6                	test   %esi,%esi
  80056f:	78 a1                	js     800512 <vprintfmt+0x1f2>
  800571:	83 ee 01             	sub    $0x1,%esi
  800574:	79 9c                	jns    800512 <vprintfmt+0x1f2>
  800576:	89 df                	mov    %ebx,%edi
  800578:	8b 75 08             	mov    0x8(%ebp),%esi
  80057b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057e:	eb 18                	jmp    800598 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	6a 20                	push   $0x20
  800586:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800588:	83 ef 01             	sub    $0x1,%edi
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	eb 08                	jmp    800598 <vprintfmt+0x278>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	85 ff                	test   %edi,%edi
  80059a:	7f e4                	jg     800580 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059f:	e9 a2 fd ff ff       	jmp    800346 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a4:	83 fa 01             	cmp    $0x1,%edx
  8005a7:	7e 16                	jle    8005bf <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 50 08             	lea    0x8(%eax),%edx
  8005af:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b2:	8b 50 04             	mov    0x4(%eax),%edx
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ba:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005bd:	eb 32                	jmp    8005f1 <vprintfmt+0x2d1>
	else if (lflag)
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	74 18                	je     8005db <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d1:	89 c1                	mov    %eax,%ecx
  8005d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d9:	eb 16                	jmp    8005f1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e9:	89 c1                	mov    %eax,%ecx
  8005eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ee:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005f4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005fd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800602:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800606:	0f 89 b0 00 00 00    	jns    8006bc <vprintfmt+0x39c>
				putch('-', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 2d                	push   $0x2d
  800612:	ff d6                	call   *%esi
				num = -(long long) num;
  800614:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800617:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80061a:	f7 d8                	neg    %eax
  80061c:	83 d2 00             	adc    $0x0,%edx
  80061f:	f7 da                	neg    %edx
  800621:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800624:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800627:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062f:	e9 88 00 00 00       	jmp    8006bc <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800634:	8d 45 14             	lea    0x14(%ebp),%eax
  800637:	e8 70 fc ff ff       	call   8002ac <getuint>
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800647:	eb 73                	jmp    8006bc <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800649:	8d 45 14             	lea    0x14(%ebp),%eax
  80064c:	e8 5b fc ff ff       	call   8002ac <getuint>
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 58                	push   $0x58
  80065d:	ff d6                	call   *%esi
			putch('X', putdat);
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 58                	push   $0x58
  800665:	ff d6                	call   *%esi
			putch('X', putdat);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 58                	push   $0x58
  80066d:	ff d6                	call   *%esi
			goto number;
  80066f:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800672:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800677:	eb 43                	jmp    8006bc <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 30                	push   $0x30
  80067f:	ff d6                	call   *%esi
			putch('x', putdat);
  800681:	83 c4 08             	add    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 78                	push   $0x78
  800687:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 50 04             	lea    0x4(%eax),%edx
  80068f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800692:	8b 00                	mov    (%eax),%eax
  800694:	ba 00 00 00 00       	mov    $0x0,%edx
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a7:	eb 13                	jmp    8006bc <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ac:	e8 fb fb ff ff       	call   8002ac <getuint>
  8006b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bc:	83 ec 0c             	sub    $0xc,%esp
  8006bf:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006c3:	52                   	push   %edx
  8006c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c7:	50                   	push   %eax
  8006c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8006cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 26 fb ff ff       	call   8001fd <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	e9 64 fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	51                   	push   %ecx
  8006e7:	ff d6                	call   *%esi
			break;
  8006e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ef:	e9 52 fc ff ff       	jmp    800346 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	6a 25                	push   $0x25
  8006fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 03                	jmp    800704 <vprintfmt+0x3e4>
  800701:	83 ef 01             	sub    $0x1,%edi
  800704:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800708:	75 f7                	jne    800701 <vprintfmt+0x3e1>
  80070a:	e9 37 fc ff ff       	jmp    800346 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 26                	je     80075e <vsnprintf+0x47>
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e 22                	jle    80075e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073c:	ff 75 14             	pushl  0x14(%ebp)
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	68 e6 02 80 00       	push   $0x8002e6
  80074b:	e8 d0 fb ff ff       	call   800320 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 05                	jmp    800763 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 9a ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 03                	jmp    80078f <strlen+0x10>
		n++;
  80078c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800793:	75 f7                	jne    80078c <strlen+0xd>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a5:	eb 03                	jmp    8007aa <strnlen+0x13>
		n++;
  8007a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 08                	je     8007b6 <strnlen+0x1f>
  8007ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b2:	75 f3                	jne    8007a7 <strnlen+0x10>
  8007b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ef                	jne    8007c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007df:	53                   	push   %ebx
  8007e0:	e8 9a ff ff ff       	call   80077f <strlen>
  8007e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	01 d8                	add    %ebx,%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 c5 ff ff ff       	call   8007b8 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	89 f3                	mov    %esi,%ebx
  800807:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 0f                	jmp    80081d <strncpy+0x23>
		*dst++ = *src;
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800817:	80 39 01             	cmpb   $0x1,(%ecx)
  80081a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	39 da                	cmp    %ebx,%edx
  80081f:	75 ed                	jne    80080e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800821:	89 f0                	mov    %esi,%eax
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	8b 55 10             	mov    0x10(%ebp),%edx
  800835:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800837:	85 d2                	test   %edx,%edx
  800839:	74 21                	je     80085c <strlcpy+0x35>
  80083b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083f:	89 f2                	mov    %esi,%edx
  800841:	eb 09                	jmp    80084c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 09                	je     800859 <strlcpy+0x32>
  800850:	0f b6 19             	movzbl (%ecx),%ebx
  800853:	84 db                	test   %bl,%bl
  800855:	75 ec                	jne    800843 <strlcpy+0x1c>
  800857:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085c:	29 f0                	sub    %esi,%eax
}
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086b:	eb 06                	jmp    800873 <strcmp+0x11>
		p++, q++;
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800873:	0f b6 01             	movzbl (%ecx),%eax
  800876:	84 c0                	test   %al,%al
  800878:	74 04                	je     80087e <strcmp+0x1c>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	74 ef                	je     80086d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	89 c3                	mov    %eax,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800897:	eb 06                	jmp    80089f <strncmp+0x17>
		n--, p++, q++;
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089f:	39 d8                	cmp    %ebx,%eax
  8008a1:	74 15                	je     8008b8 <strncmp+0x30>
  8008a3:	0f b6 08             	movzbl (%eax),%ecx
  8008a6:	84 c9                	test   %cl,%cl
  8008a8:	74 04                	je     8008ae <strncmp+0x26>
  8008aa:	3a 0a                	cmp    (%edx),%cl
  8008ac:	74 eb                	je     800899 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 00             	movzbl (%eax),%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
  8008b6:	eb 05                	jmp    8008bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 07                	jmp    8008d3 <strchr+0x13>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 0f                	je     8008df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	0f b6 10             	movzbl (%eax),%edx
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008eb:	eb 03                	jmp    8008f0 <strfind+0xf>
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 04                	je     8008fb <strfind+0x1a>
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f2                	jne    8008ed <strfind+0xc>
			break;
	return (char *) s;
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 36                	je     800943 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800913:	75 28                	jne    80093d <memset+0x40>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 23                	jne    80093d <memset+0x40>
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d3                	mov    %edx,%ebx
  800920:	c1 e3 08             	shl    $0x8,%ebx
  800923:	89 d6                	mov    %edx,%esi
  800925:	c1 e6 18             	shl    $0x18,%esi
  800928:	89 d0                	mov    %edx,%eax
  80092a:	c1 e0 10             	shl    $0x10,%eax
  80092d:	09 f0                	or     %esi,%eax
  80092f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800931:	89 d8                	mov    %ebx,%eax
  800933:	09 d0                	or     %edx,%eax
  800935:	c1 e9 02             	shr    $0x2,%ecx
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb 06                	jmp    800943 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	fc                   	cld    
  800941:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800943:	89 f8                	mov    %edi,%eax
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 75 0c             	mov    0xc(%ebp),%esi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 35                	jae    800991 <memmove+0x47>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 d0                	cmp    %edx,%eax
  800961:	73 2e                	jae    800991 <memmove+0x47>
		s += n;
		d += n;
  800963:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	89 d6                	mov    %edx,%esi
  800968:	09 fe                	or     %edi,%esi
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 13                	jne    800985 <memmove+0x3b>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0e                	jne    800985 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800977:	83 ef 04             	sub    $0x4,%edi
  80097a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	fd                   	std    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 09                	jmp    80098e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800985:	83 ef 01             	sub    $0x1,%edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
  80098f:	eb 1d                	jmp    8009ae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	89 f2                	mov    %esi,%edx
  800993:	09 c2                	or     %eax,%edx
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0f                	jne    8009a9 <memmove+0x5f>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0a                	jne    8009a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099f:	c1 e9 02             	shr    $0x2,%ecx
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 05                	jmp    8009ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b5:	ff 75 10             	pushl  0x10(%ebp)
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 87 ff ff ff       	call   80094a <memmove>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c6                	mov    %eax,%esi
  8009d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	eb 1a                	jmp    8009f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	0f b6 1a             	movzbl (%edx),%ebx
  8009dd:	38 d9                	cmp    %bl,%cl
  8009df:	74 0a                	je     8009eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c1             	movzbl %cl,%eax
  8009e4:	0f b6 db             	movzbl %bl,%ebx
  8009e7:	29 d8                	sub    %ebx,%eax
  8009e9:	eb 0f                	jmp    8009fa <memcmp+0x35>
		s1++, s2++;
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	39 f0                	cmp    %esi,%eax
  8009f3:	75 e2                	jne    8009d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	53                   	push   %ebx
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a05:	89 c1                	mov    %eax,%ecx
  800a07:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0e:	eb 0a                	jmp    800a1a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	74 07                	je     800a1e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	39 c8                	cmp    %ecx,%eax
  800a1c:	72 f2                	jb     800a10 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	eb 03                	jmp    800a32 <strtol+0x11>
		s++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	0f b6 01             	movzbl (%ecx),%eax
  800a35:	3c 20                	cmp    $0x20,%al
  800a37:	74 f6                	je     800a2f <strtol+0xe>
  800a39:	3c 09                	cmp    $0x9,%al
  800a3b:	74 f2                	je     800a2f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3d:	3c 2b                	cmp    $0x2b,%al
  800a3f:	75 0a                	jne    800a4b <strtol+0x2a>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb 11                	jmp    800a5c <strtol+0x3b>
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a50:	3c 2d                	cmp    $0x2d,%al
  800a52:	75 08                	jne    800a5c <strtol+0x3b>
		s++, neg = 1;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a62:	75 15                	jne    800a79 <strtol+0x58>
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	75 10                	jne    800a79 <strtol+0x58>
  800a69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6d:	75 7c                	jne    800aeb <strtol+0xca>
		s += 2, base = 16;
  800a6f:	83 c1 02             	add    $0x2,%ecx
  800a72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a77:	eb 16                	jmp    800a8f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	75 12                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	75 08                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a97:	0f b6 11             	movzbl (%ecx),%edx
  800a9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 09             	cmp    $0x9,%bl
  800aa2:	77 08                	ja     800aac <strtol+0x8b>
			dig = *s - '0';
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 30             	sub    $0x30,%edx
  800aaa:	eb 22                	jmp    800ace <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 57             	sub    $0x57,%edx
  800abc:	eb 10                	jmp    800ace <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 16                	ja     800ade <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ace:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad1:	7d 0b                	jge    800ade <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ada:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adc:	eb b9                	jmp    800a97 <strtol+0x76>

	if (endptr)
  800ade:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae2:	74 0d                	je     800af1 <strtol+0xd0>
		*endptr = (char *) s;
  800ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae7:	89 0e                	mov    %ecx,(%esi)
  800ae9:	eb 06                	jmp    800af1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	74 98                	je     800a87 <strtol+0x66>
  800aef:	eb 9e                	jmp    800a8f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	f7 da                	neg    %edx
  800af5:	85 ff                	test   %edi,%edi
  800af7:	0f 45 c2             	cmovne %edx,%eax
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	89 c6                	mov    %eax,%esi
  800b16:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	89 cb                	mov    %ecx,%ebx
  800b54:	89 cf                	mov    %ecx,%edi
  800b56:	89 ce                	mov    %ecx,%esi
  800b58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7e 17                	jle    800b75 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	50                   	push   %eax
  800b62:	6a 03                	push   $0x3
  800b64:	68 c4 16 80 00       	push   $0x8016c4
  800b69:	6a 23                	push   $0x23
  800b6b:	68 e1 16 80 00       	push   $0x8016e1
  800b70:	e8 d1 04 00 00       	call   801046 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	89 d3                	mov    %edx,%ebx
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	89 d6                	mov    %edx,%esi
  800b95:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_yield>:

void
sys_yield(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bac:	89 d1                	mov    %edx,%ecx
  800bae:	89 d3                	mov    %edx,%ebx
  800bb0:	89 d7                	mov    %edx,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc4:	be 00 00 00 00       	mov    $0x0,%esi
  800bc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd7:	89 f7                	mov    %esi,%edi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 04                	push   $0x4
  800be5:	68 c4 16 80 00       	push   $0x8016c4
  800bea:	6a 23                	push   $0x23
  800bec:	68 e1 16 80 00       	push   $0x8016e1
  800bf1:	e8 50 04 00 00       	call   801046 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c07:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c18:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 05                	push   $0x5
  800c27:	68 c4 16 80 00       	push   $0x8016c4
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 e1 16 80 00       	push   $0x8016e1
  800c33:	e8 0e 04 00 00       	call   801046 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 06                	push   $0x6
  800c69:	68 c4 16 80 00       	push   $0x8016c4
  800c6e:	6a 23                	push   $0x23
  800c70:	68 e1 16 80 00       	push   $0x8016e1
  800c75:	e8 cc 03 00 00       	call   801046 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 08 00 00 00       	mov    $0x8,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 08                	push   $0x8
  800cab:	68 c4 16 80 00       	push   $0x8016c4
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 e1 16 80 00       	push   $0x8016e1
  800cb7:	e8 8a 03 00 00       	call   801046 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 09                	push   $0x9
  800ced:	68 c4 16 80 00       	push   $0x8016c4
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 e1 16 80 00       	push   $0x8016e1
  800cf9:	e8 48 03 00 00       	call   801046 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0c:	be 00 00 00 00       	mov    $0x0,%esi
  800d11:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d22:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 cb                	mov    %ecx,%ebx
  800d41:	89 cf                	mov    %ecx,%edi
  800d43:	89 ce                	mov    %ecx,%esi
  800d45:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d47:	85 c0                	test   %eax,%eax
  800d49:	7e 17                	jle    800d62 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 0c                	push   $0xc
  800d51:	68 c4 16 80 00       	push   $0x8016c4
  800d56:	6a 23                	push   $0x23
  800d58:	68 e1 16 80 00       	push   $0x8016e1
  800d5d:	e8 e4 02 00 00       	call   801046 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d74:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800d76:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d7a:	74 2d                	je     800da9 <pgfault+0x3f>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d7c:	89 d8                	mov    %ebx,%eax
  800d7e:	c1 e8 16             	shr    $0x16,%eax
  800d81:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
  800d88:	a8 01                	test   $0x1,%al
  800d8a:	74 1d                	je     800da9 <pgfault+0x3f>
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
  800d8c:	89 d8                	mov    %ebx,%eax
  800d8e:	c1 e8 0c             	shr    $0xc,%eax
  800d91:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d98:	f6 c2 01             	test   $0x1,%dl
  800d9b:	74 0c                	je     800da9 <pgfault+0x3f>
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800d9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800da4:	f6 c4 08             	test   $0x8,%ah
  800da7:	75 14                	jne    800dbd <pgfault+0x53>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	68 ef 16 80 00       	push   $0x8016ef
  800db1:	6a 22                	push   $0x22
  800db3:	68 05 17 80 00       	push   $0x801705
  800db8:	e8 89 02 00 00       	call   801046 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	cprintf("in pgfault.\n");
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	68 10 17 80 00       	push   $0x801710
  800dc5:	e8 1f f4 ff ff       	call   8001e9 <cprintf>
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800dca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800dd0:	83 c4 0c             	add    $0xc,%esp
  800dd3:	6a 07                	push   $0x7
  800dd5:	68 00 f0 7f 00       	push   $0x7ff000
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 da fd ff ff       	call   800bbb <sys_page_alloc>
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	79 14                	jns    800dfc <pgfault+0x92>
		panic("sys_page_alloc");
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	68 1d 17 80 00       	push   $0x80171d
  800df0:	6a 30                	push   $0x30
  800df2:	68 05 17 80 00       	push   $0x801705
  800df7:	e8 4a 02 00 00       	call   801046 <_panic>
	}
	memcpy(PFTEMP, addr, PGSIZE);
  800dfc:	83 ec 04             	sub    $0x4,%esp
  800dff:	68 00 10 00 00       	push   $0x1000
  800e04:	53                   	push   %ebx
  800e05:	68 00 f0 7f 00       	push   $0x7ff000
  800e0a:	e8 a3 fb ff ff       	call   8009b2 <memcpy>
	
	retv = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P);
  800e0f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e16:	53                   	push   %ebx
  800e17:	6a 00                	push   $0x0
  800e19:	68 00 f0 7f 00       	push   $0x7ff000
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 d9 fd ff ff       	call   800bfe <sys_page_map>
	if(retv < 0){
  800e25:	83 c4 20             	add    $0x20,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	79 14                	jns    800e40 <pgfault+0xd6>
		panic("sys_page_map");
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	68 2c 17 80 00       	push   $0x80172c
  800e34:	6a 36                	push   $0x36
  800e36:	68 05 17 80 00       	push   $0x801705
  800e3b:	e8 06 02 00 00       	call   801046 <_panic>
	}
	cprintf("out of pgfault.\n");
  800e40:	83 ec 0c             	sub    $0xc,%esp
  800e43:	68 39 17 80 00       	push   $0x801739
  800e48:	e8 9c f3 ff ff       	call   8001e9 <cprintf>
	return;
  800e4d:	83 c4 10             	add    $0x10,%esp
	panic("pgfault not implemented");
}
  800e50:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e53:	c9                   	leave  
  800e54:	c3                   	ret    

00800e55 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 18             	sub    $0x18,%esp
	cprintf("\t\t we are in the fork().\n");
  800e5e:	68 4a 17 80 00       	push   $0x80174a
  800e63:	e8 81 f3 ff ff       	call   8001e9 <cprintf>
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800e68:	c7 04 24 6a 0d 80 00 	movl   $0x800d6a,(%esp)
  800e6f:	e8 18 02 00 00       	call   80108c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e74:	b8 07 00 00 00       	mov    $0x7,%eax
  800e79:	cd 30                	int    $0x30
  800e7b:	89 c6                	mov    %eax,%esi
	//create a child
	child_envid = sys_exofork();
	if(child_envid < 0 ){
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	85 c0                	test   %eax,%eax
  800e87:	79 17                	jns    800ea0 <fork+0x4b>
		panic("sys_exofork failed.");
  800e89:	83 ec 04             	sub    $0x4,%esp
  800e8c:	68 64 17 80 00       	push   $0x801764
  800e91:	68 82 00 00 00       	push   $0x82
  800e96:	68 05 17 80 00       	push   $0x801705
  800e9b:	e8 a6 01 00 00       	call   801046 <_panic>
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800ea0:	89 d8                	mov    %ebx,%eax
  800ea2:	c1 e8 16             	shr    $0x16,%eax
  800ea5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800eac:	a8 01                	test   $0x1,%al
  800eae:	0f 84 e8 00 00 00    	je     800f9c <fork+0x147>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800eb4:	89 d8                	mov    %ebx,%eax
  800eb6:	c1 e8 0c             	shr    $0xc,%eax
  800eb9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800ec0:	f6 c2 01             	test   $0x1,%dl
  800ec3:	0f 84 d3 00 00 00    	je     800f9c <fork+0x147>
			(uvpt[PGNUM(addr)] & PTE_P)&& 
			(uvpt[PGNUM(addr)] & PTE_U)
  800ec9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800ed0:	f6 c2 04             	test   $0x4,%dl
  800ed3:	0f 84 c3 00 00 00    	je     800f9c <fork+0x147>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;

	// LAB 4: Your code here.
	void *addr = (void*)(pn*PGSIZE);
  800ed9:	89 c7                	mov    %eax,%edi
  800edb:	c1 e7 0c             	shl    $0xc,%edi
	if( (uvpt[pn] & PTE_W)||(uvpt[pn]) & PTE_COW ){
  800ede:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ee5:	f6 c2 02             	test   $0x2,%dl
  800ee8:	75 10                	jne    800efa <fork+0xa5>
  800eea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ef1:	f6 c4 08             	test   $0x8,%ah
  800ef4:	0f 84 90 00 00 00    	je     800f8a <fork+0x135>
		cprintf("!!start page map.\n");	
  800efa:	83 ec 0c             	sub    $0xc,%esp
  800efd:	68 78 17 80 00       	push   $0x801778
  800f02:	e8 e2 f2 ff ff       	call   8001e9 <cprintf>
		r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_P|PTE_U);
  800f07:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	57                   	push   %edi
  800f11:	6a 00                	push   $0x0
  800f13:	e8 e6 fc ff ff       	call   800bfe <sys_page_map>
		if(r<0){
  800f18:	83 c4 20             	add    $0x20,%esp
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	79 22                	jns    800f41 <fork+0xec>
			cprintf("sys_page_map failed :%d\n",r);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	50                   	push   %eax
  800f23:	68 8b 17 80 00       	push   $0x80178b
  800f28:	e8 bc f2 ff ff       	call   8001e9 <cprintf>
			panic("map env id 0 to child_envid failed.");
  800f2d:	83 c4 0c             	add    $0xc,%esp
  800f30:	68 f4 17 80 00       	push   $0x8017f4
  800f35:	6a 54                	push   $0x54
  800f37:	68 05 17 80 00       	push   $0x801705
  800f3c:	e8 05 01 00 00       	call   801046 <_panic>
		
		}
		cprintf("mapping addr is:%x\n",addr);
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	57                   	push   %edi
  800f45:	68 a4 17 80 00       	push   $0x8017a4
  800f4a:	e8 9a f2 ff ff       	call   8001e9 <cprintf>
		r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_P|PTE_U);
  800f4f:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800f56:	57                   	push   %edi
  800f57:	6a 00                	push   $0x0
  800f59:	57                   	push   %edi
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 9d fc ff ff       	call   800bfe <sys_page_map>
//		cprintf("!!end sys_page_map 0.\n");
		if(r<0){
  800f61:	83 c4 20             	add    $0x20,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	79 34                	jns    800f9c <fork+0x147>
			cprintf("sys_page_map failed :%d\n",r);
  800f68:	83 ec 08             	sub    $0x8,%esp
  800f6b:	50                   	push   %eax
  800f6c:	68 8b 17 80 00       	push   $0x80178b
  800f71:	e8 73 f2 ff ff       	call   8001e9 <cprintf>
			panic("map env id 0 to 0");
  800f76:	83 c4 0c             	add    $0xc,%esp
  800f79:	68 b8 17 80 00       	push   $0x8017b8
  800f7e:	6a 5c                	push   $0x5c
  800f80:	68 05 17 80 00       	push   $0x801705
  800f85:	e8 bc 00 00 00       	call   801046 <_panic>
		}//?we should mark PTE_COW both to two id.
//		cprintf("!!end page map.\n");	
	}else{
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	6a 05                	push   $0x5
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	57                   	push   %edi
  800f92:	6a 00                	push   $0x0
  800f94:	e8 65 fc ff ff       	call   800bfe <sys_page_map>
  800f99:	83 c4 20             	add    $0x20,%esp
	if(child_envid < 0 ){
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f9c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fa8:	0f 85 f2 fe ff ff    	jne    800ea0 <fork+0x4b>
			(uvpt[PGNUM(addr)] & PTE_U)
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	panic("failed at duppage.");
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	68 ca 17 80 00       	push   $0x8017ca
  800fb6:	68 8f 00 00 00       	push   $0x8f
  800fbb:	68 05 17 80 00       	push   $0x801705
  800fc0:	e8 81 00 00 00       	call   801046 <_panic>

00800fc5 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fcb:	68 dd 17 80 00       	push   $0x8017dd
  800fd0:	68 a4 00 00 00       	push   $0xa4
  800fd5:	68 05 17 80 00       	push   $0x801705
  800fda:	e8 67 00 00 00       	call   801046 <_panic>

00800fdf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800fe5:	68 18 18 80 00       	push   $0x801818
  800fea:	6a 1a                	push   $0x1a
  800fec:	68 31 18 80 00       	push   $0x801831
  800ff1:	e8 50 00 00 00       	call   801046 <_panic>

00800ff6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800ffc:	68 3b 18 80 00       	push   $0x80183b
  801001:	6a 2a                	push   $0x2a
  801003:	68 31 18 80 00       	push   $0x801831
  801008:	e8 39 00 00 00       	call   801046 <_panic>

0080100d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801018:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80101b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801021:	8b 52 50             	mov    0x50(%edx),%edx
  801024:	39 ca                	cmp    %ecx,%edx
  801026:	75 0d                	jne    801035 <ipc_find_env+0x28>
			return envs[i].env_id;
  801028:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80102b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801030:	8b 40 48             	mov    0x48(%eax),%eax
  801033:	eb 0f                	jmp    801044 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801035:	83 c0 01             	add    $0x1,%eax
  801038:	3d 00 04 00 00       	cmp    $0x400,%eax
  80103d:	75 d9                	jne    801018 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801054:	e8 24 fb ff ff       	call   800b7d <sys_getenvid>
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	ff 75 0c             	pushl  0xc(%ebp)
  80105f:	ff 75 08             	pushl  0x8(%ebp)
  801062:	56                   	push   %esi
  801063:	50                   	push   %eax
  801064:	68 54 18 80 00       	push   $0x801854
  801069:	e8 7b f1 ff ff       	call   8001e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106e:	83 c4 18             	add    $0x18,%esp
  801071:	53                   	push   %ebx
  801072:	ff 75 10             	pushl  0x10(%ebp)
  801075:	e8 1e f1 ff ff       	call   800198 <vcprintf>
	cprintf("\n");
  80107a:	c7 04 24 62 17 80 00 	movl   $0x801762,(%esp)
  801081:	e8 63 f1 ff ff       	call   8001e9 <cprintf>
  801086:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801089:	cc                   	int3   
  80108a:	eb fd                	jmp    801089 <_panic+0x43>

0080108c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  801092:	68 78 18 80 00       	push   $0x801878
  801097:	e8 4d f1 ff ff       	call   8001e9 <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  80109c:	83 c4 10             	add    $0x10,%esp
  80109f:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8010a6:	0f 85 8d 00 00 00    	jne    801139 <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	68 98 18 80 00       	push   $0x801898
  8010b4:	e8 30 f1 ff ff       	call   8001e9 <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  8010b9:	a1 08 20 80 00       	mov    0x802008,%eax
  8010be:	8b 40 48             	mov    0x48(%eax),%eax
  8010c1:	83 c4 0c             	add    $0xc,%esp
  8010c4:	6a 07                	push   $0x7
  8010c6:	68 00 f0 bf ee       	push   $0xeebff000
  8010cb:	50                   	push   %eax
  8010cc:	e8 ea fa ff ff       	call   800bbb <sys_page_alloc>
		if(retv != 0){
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	74 14                	je     8010ec <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	68 bc 18 80 00       	push   $0x8018bc
  8010e0:	6a 27                	push   $0x27
  8010e2:	68 10 19 80 00       	push   $0x801910
  8010e7:	e8 5a ff ff ff       	call   801046 <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	68 53 11 80 00       	push   $0x801153
  8010f4:	68 1e 19 80 00       	push   $0x80191e
  8010f9:	e8 eb f0 ff ff       	call   8001e9 <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  8010fe:	a1 08 20 80 00       	mov    0x802008,%eax
  801103:	8b 40 48             	mov    0x48(%eax),%eax
  801106:	83 c4 08             	add    $0x8,%esp
  801109:	50                   	push   %eax
  80110a:	68 39 19 80 00       	push   $0x801939
  80110f:	e8 d5 f0 ff ff       	call   8001e9 <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801114:	a1 08 20 80 00       	mov    0x802008,%eax
  801119:	8b 40 48             	mov    0x48(%eax),%eax
  80111c:	83 c4 08             	add    $0x8,%esp
  80111f:	68 53 11 80 00       	push   $0x801153
  801124:	50                   	push   %eax
  801125:	e8 9a fb ff ff       	call   800cc4 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  80112a:	c7 04 24 50 19 80 00 	movl   $0x801950,(%esp)
  801131:	e8 b3 f0 ff ff       	call   8001e9 <cprintf>
  801136:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  801139:	83 ec 0c             	sub    $0xc,%esp
  80113c:	68 e8 18 80 00       	push   $0x8018e8
  801141:	e8 a3 f0 ff ff       	call   8001e9 <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	a3 0c 20 80 00       	mov    %eax,0x80200c

}
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801153:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801154:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801159:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80115b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  80115e:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  801160:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  801164:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801168:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  801169:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  80116b:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  801172:	00 
	popl %eax
  801173:	58                   	pop    %eax
	popl %eax
  801174:	58                   	pop    %eax
	popal
  801175:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  801176:	83 c4 04             	add    $0x4,%esp
	popfl
  801179:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80117a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80117b:	c3                   	ret    
  80117c:	66 90                	xchg   %ax,%ax
  80117e:	66 90                	xchg   %ax,%ax

00801180 <__udivdi3>:
  801180:	55                   	push   %ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 1c             	sub    $0x1c,%esp
  801187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80118b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80118f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801197:	85 f6                	test   %esi,%esi
  801199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80119d:	89 ca                	mov    %ecx,%edx
  80119f:	89 f8                	mov    %edi,%eax
  8011a1:	75 3d                	jne    8011e0 <__udivdi3+0x60>
  8011a3:	39 cf                	cmp    %ecx,%edi
  8011a5:	0f 87 c5 00 00 00    	ja     801270 <__udivdi3+0xf0>
  8011ab:	85 ff                	test   %edi,%edi
  8011ad:	89 fd                	mov    %edi,%ebp
  8011af:	75 0b                	jne    8011bc <__udivdi3+0x3c>
  8011b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b6:	31 d2                	xor    %edx,%edx
  8011b8:	f7 f7                	div    %edi
  8011ba:	89 c5                	mov    %eax,%ebp
  8011bc:	89 c8                	mov    %ecx,%eax
  8011be:	31 d2                	xor    %edx,%edx
  8011c0:	f7 f5                	div    %ebp
  8011c2:	89 c1                	mov    %eax,%ecx
  8011c4:	89 d8                	mov    %ebx,%eax
  8011c6:	89 cf                	mov    %ecx,%edi
  8011c8:	f7 f5                	div    %ebp
  8011ca:	89 c3                	mov    %eax,%ebx
  8011cc:	89 d8                	mov    %ebx,%eax
  8011ce:	89 fa                	mov    %edi,%edx
  8011d0:	83 c4 1c             	add    $0x1c,%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    
  8011d8:	90                   	nop
  8011d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	39 ce                	cmp    %ecx,%esi
  8011e2:	77 74                	ja     801258 <__udivdi3+0xd8>
  8011e4:	0f bd fe             	bsr    %esi,%edi
  8011e7:	83 f7 1f             	xor    $0x1f,%edi
  8011ea:	0f 84 98 00 00 00    	je     801288 <__udivdi3+0x108>
  8011f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011f5:	89 f9                	mov    %edi,%ecx
  8011f7:	89 c5                	mov    %eax,%ebp
  8011f9:	29 fb                	sub    %edi,%ebx
  8011fb:	d3 e6                	shl    %cl,%esi
  8011fd:	89 d9                	mov    %ebx,%ecx
  8011ff:	d3 ed                	shr    %cl,%ebp
  801201:	89 f9                	mov    %edi,%ecx
  801203:	d3 e0                	shl    %cl,%eax
  801205:	09 ee                	or     %ebp,%esi
  801207:	89 d9                	mov    %ebx,%ecx
  801209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120d:	89 d5                	mov    %edx,%ebp
  80120f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801213:	d3 ed                	shr    %cl,%ebp
  801215:	89 f9                	mov    %edi,%ecx
  801217:	d3 e2                	shl    %cl,%edx
  801219:	89 d9                	mov    %ebx,%ecx
  80121b:	d3 e8                	shr    %cl,%eax
  80121d:	09 c2                	or     %eax,%edx
  80121f:	89 d0                	mov    %edx,%eax
  801221:	89 ea                	mov    %ebp,%edx
  801223:	f7 f6                	div    %esi
  801225:	89 d5                	mov    %edx,%ebp
  801227:	89 c3                	mov    %eax,%ebx
  801229:	f7 64 24 0c          	mull   0xc(%esp)
  80122d:	39 d5                	cmp    %edx,%ebp
  80122f:	72 10                	jb     801241 <__udivdi3+0xc1>
  801231:	8b 74 24 08          	mov    0x8(%esp),%esi
  801235:	89 f9                	mov    %edi,%ecx
  801237:	d3 e6                	shl    %cl,%esi
  801239:	39 c6                	cmp    %eax,%esi
  80123b:	73 07                	jae    801244 <__udivdi3+0xc4>
  80123d:	39 d5                	cmp    %edx,%ebp
  80123f:	75 03                	jne    801244 <__udivdi3+0xc4>
  801241:	83 eb 01             	sub    $0x1,%ebx
  801244:	31 ff                	xor    %edi,%edi
  801246:	89 d8                	mov    %ebx,%eax
  801248:	89 fa                	mov    %edi,%edx
  80124a:	83 c4 1c             	add    $0x1c,%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	31 ff                	xor    %edi,%edi
  80125a:	31 db                	xor    %ebx,%ebx
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	89 fa                	mov    %edi,%edx
  801260:	83 c4 1c             	add    $0x1c,%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    
  801268:	90                   	nop
  801269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 d8                	mov    %ebx,%eax
  801272:	f7 f7                	div    %edi
  801274:	31 ff                	xor    %edi,%edi
  801276:	89 c3                	mov    %eax,%ebx
  801278:	89 d8                	mov    %ebx,%eax
  80127a:	89 fa                	mov    %edi,%edx
  80127c:	83 c4 1c             	add    $0x1c,%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5f                   	pop    %edi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	39 ce                	cmp    %ecx,%esi
  80128a:	72 0c                	jb     801298 <__udivdi3+0x118>
  80128c:	31 db                	xor    %ebx,%ebx
  80128e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801292:	0f 87 34 ff ff ff    	ja     8011cc <__udivdi3+0x4c>
  801298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80129d:	e9 2a ff ff ff       	jmp    8011cc <__udivdi3+0x4c>
  8012a2:	66 90                	xchg   %ax,%ax
  8012a4:	66 90                	xchg   %ax,%ax
  8012a6:	66 90                	xchg   %ax,%ax
  8012a8:	66 90                	xchg   %ax,%ax
  8012aa:	66 90                	xchg   %ax,%ax
  8012ac:	66 90                	xchg   %ax,%ax
  8012ae:	66 90                	xchg   %ax,%ax

008012b0 <__umoddi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 1c             	sub    $0x1c,%esp
  8012b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012c7:	85 d2                	test   %edx,%edx
  8012c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d1:	89 f3                	mov    %esi,%ebx
  8012d3:	89 3c 24             	mov    %edi,(%esp)
  8012d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012da:	75 1c                	jne    8012f8 <__umoddi3+0x48>
  8012dc:	39 f7                	cmp    %esi,%edi
  8012de:	76 50                	jbe    801330 <__umoddi3+0x80>
  8012e0:	89 c8                	mov    %ecx,%eax
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	f7 f7                	div    %edi
  8012e6:	89 d0                	mov    %edx,%eax
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	83 c4 1c             	add    $0x1c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    
  8012f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f8:	39 f2                	cmp    %esi,%edx
  8012fa:	89 d0                	mov    %edx,%eax
  8012fc:	77 52                	ja     801350 <__umoddi3+0xa0>
  8012fe:	0f bd ea             	bsr    %edx,%ebp
  801301:	83 f5 1f             	xor    $0x1f,%ebp
  801304:	75 5a                	jne    801360 <__umoddi3+0xb0>
  801306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80130a:	0f 82 e0 00 00 00    	jb     8013f0 <__umoddi3+0x140>
  801310:	39 0c 24             	cmp    %ecx,(%esp)
  801313:	0f 86 d7 00 00 00    	jbe    8013f0 <__umoddi3+0x140>
  801319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80131d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801321:	83 c4 1c             	add    $0x1c,%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5f                   	pop    %edi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	85 ff                	test   %edi,%edi
  801332:	89 fd                	mov    %edi,%ebp
  801334:	75 0b                	jne    801341 <__umoddi3+0x91>
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	f7 f7                	div    %edi
  80133f:	89 c5                	mov    %eax,%ebp
  801341:	89 f0                	mov    %esi,%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	f7 f5                	div    %ebp
  801347:	89 c8                	mov    %ecx,%eax
  801349:	f7 f5                	div    %ebp
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	eb 99                	jmp    8012e8 <__umoddi3+0x38>
  80134f:	90                   	nop
  801350:	89 c8                	mov    %ecx,%eax
  801352:	89 f2                	mov    %esi,%edx
  801354:	83 c4 1c             	add    $0x1c,%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	8b 34 24             	mov    (%esp),%esi
  801363:	bf 20 00 00 00       	mov    $0x20,%edi
  801368:	89 e9                	mov    %ebp,%ecx
  80136a:	29 ef                	sub    %ebp,%edi
  80136c:	d3 e0                	shl    %cl,%eax
  80136e:	89 f9                	mov    %edi,%ecx
  801370:	89 f2                	mov    %esi,%edx
  801372:	d3 ea                	shr    %cl,%edx
  801374:	89 e9                	mov    %ebp,%ecx
  801376:	09 c2                	or     %eax,%edx
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	89 14 24             	mov    %edx,(%esp)
  80137d:	89 f2                	mov    %esi,%edx
  80137f:	d3 e2                	shl    %cl,%edx
  801381:	89 f9                	mov    %edi,%ecx
  801383:	89 54 24 04          	mov    %edx,0x4(%esp)
  801387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80138b:	d3 e8                	shr    %cl,%eax
  80138d:	89 e9                	mov    %ebp,%ecx
  80138f:	89 c6                	mov    %eax,%esi
  801391:	d3 e3                	shl    %cl,%ebx
  801393:	89 f9                	mov    %edi,%ecx
  801395:	89 d0                	mov    %edx,%eax
  801397:	d3 e8                	shr    %cl,%eax
  801399:	89 e9                	mov    %ebp,%ecx
  80139b:	09 d8                	or     %ebx,%eax
  80139d:	89 d3                	mov    %edx,%ebx
  80139f:	89 f2                	mov    %esi,%edx
  8013a1:	f7 34 24             	divl   (%esp)
  8013a4:	89 d6                	mov    %edx,%esi
  8013a6:	d3 e3                	shl    %cl,%ebx
  8013a8:	f7 64 24 04          	mull   0x4(%esp)
  8013ac:	39 d6                	cmp    %edx,%esi
  8013ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b2:	89 d1                	mov    %edx,%ecx
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	72 08                	jb     8013c0 <__umoddi3+0x110>
  8013b8:	75 11                	jne    8013cb <__umoddi3+0x11b>
  8013ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013be:	73 0b                	jae    8013cb <__umoddi3+0x11b>
  8013c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013c4:	1b 14 24             	sbb    (%esp),%edx
  8013c7:	89 d1                	mov    %edx,%ecx
  8013c9:	89 c3                	mov    %eax,%ebx
  8013cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013cf:	29 da                	sub    %ebx,%edx
  8013d1:	19 ce                	sbb    %ecx,%esi
  8013d3:	89 f9                	mov    %edi,%ecx
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	d3 e0                	shl    %cl,%eax
  8013d9:	89 e9                	mov    %ebp,%ecx
  8013db:	d3 ea                	shr    %cl,%edx
  8013dd:	89 e9                	mov    %ebp,%ecx
  8013df:	d3 ee                	shr    %cl,%esi
  8013e1:	09 d0                	or     %edx,%eax
  8013e3:	89 f2                	mov    %esi,%edx
  8013e5:	83 c4 1c             	add    $0x1c,%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    
  8013ed:	8d 76 00             	lea    0x0(%esi),%esi
  8013f0:	29 f9                	sub    %edi,%ecx
  8013f2:	19 d6                	sbb    %edx,%esi
  8013f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013fc:	e9 18 ff ff ff       	jmp    801319 <__umoddi3+0x69>
