
obj/user/pingpongs.debug:     file format elf32-i386


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
  80003c:	e8 06 11 00 00       	call   801147 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 32 0b 00 00       	call   800b85 <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 c0 22 80 00       	push   $0x8022c0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 1b 0b 00 00       	call   800b85 <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 da 22 80 00       	push   $0x8022da
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 37 11 00 00       	call   8011be <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 c7 10 00 00       	call   801161 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 d2 0a 00 00       	call   800b85 <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 f0 22 80 00       	push   $0x8022f0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 d4 10 00 00       	call   8011be <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  800109:	e8 77 0a 00 00       	call   800b85 <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 b6 12 00 00       	call   801405 <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 eb 09 00 00       	call   800b44 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 79 09 00 00       	call   800b07 <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 54 01 00 00       	call   800328 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 1e 09 00 00       	call   800b07 <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 d7 1d 00 00       	call   802030 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 c4 1e 00 00       	call   802160 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 20 23 80 00 	movsbl 0x802320(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b7:	83 fa 01             	cmp    $0x1,%edx
  8002ba:	7e 0e                	jle    8002ca <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 02                	mov    (%edx),%eax
  8002c5:	8b 52 04             	mov    0x4(%edx),%edx
  8002c8:	eb 22                	jmp    8002ec <getuint+0x38>
	else if (lflag)
  8002ca:	85 d2                	test   %edx,%edx
  8002cc:	74 10                	je     8002de <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 0e                	jmp    8002ec <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002de:	8b 10                	mov    (%eax),%edx
  8002e0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e3:	89 08                	mov    %ecx,(%eax)
  8002e5:	8b 02                	mov    (%edx),%eax
  8002e7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fd:	73 0a                	jae    800309 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 45 08             	mov    0x8(%ebp),%eax
  800307:	88 02                	mov    %al,(%edx)
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800311:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800314:	50                   	push   %eax
  800315:	ff 75 10             	pushl  0x10(%ebp)
  800318:	ff 75 0c             	pushl  0xc(%ebp)
  80031b:	ff 75 08             	pushl  0x8(%ebp)
  80031e:	e8 05 00 00 00       	call   800328 <vprintfmt>
	va_end(ap);
}
  800323:	83 c4 10             	add    $0x10,%esp
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 2c             	sub    $0x2c,%esp
  800331:	8b 75 08             	mov    0x8(%ebp),%esi
  800334:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800337:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033a:	eb 12                	jmp    80034e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033c:	85 c0                	test   %eax,%eax
  80033e:	0f 84 d3 03 00 00    	je     800717 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	53                   	push   %ebx
  800348:	50                   	push   %eax
  800349:	ff d6                	call   *%esi
  80034b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034e:	83 c7 01             	add    $0x1,%edi
  800351:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e2                	jne    80033c <vprintfmt+0x14>
  80035a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800365:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80036c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800373:	ba 00 00 00 00       	mov    $0x0,%edx
  800378:	eb 07                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8d 47 01             	lea    0x1(%edi),%eax
  800384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800387:	0f b6 07             	movzbl (%edi),%eax
  80038a:	0f b6 c8             	movzbl %al,%ecx
  80038d:	83 e8 23             	sub    $0x23,%eax
  800390:	3c 55                	cmp    $0x55,%al
  800392:	0f 87 64 03 00 00    	ja     8006fc <vprintfmt+0x3d4>
  800398:	0f b6 c0             	movzbl %al,%eax
  80039b:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a9:	eb d6                	jmp    800381 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bd:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c0:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c3:	83 fa 09             	cmp    $0x9,%edx
  8003c6:	77 39                	ja     800401 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cb:	eb e9                	jmp    8003b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003de:	eb 27                	jmp    800407 <vprintfmt+0xdf>
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	85 c0                	test   %eax,%eax
  8003e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ea:	0f 49 c8             	cmovns %eax,%ecx
  8003ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f3:	eb 8c                	jmp    800381 <vprintfmt+0x59>
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ff:	eb 80                	jmp    800381 <vprintfmt+0x59>
  800401:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800404:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 89 70 ff ff ff    	jns    800381 <vprintfmt+0x59>
				width = precision, precision = -1;
  800411:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800414:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800417:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80041e:	e9 5e ff ff ff       	jmp    800381 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800423:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800429:	e9 53 ff ff ff       	jmp    800381 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	53                   	push   %ebx
  80043b:	ff 30                	pushl  (%eax)
  80043d:	ff d6                	call   *%esi
			break;
  80043f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800445:	e9 04 ff ff ff       	jmp    80034e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 50 04             	lea    0x4(%eax),%edx
  800450:	89 55 14             	mov    %edx,0x14(%ebp)
  800453:	8b 00                	mov    (%eax),%eax
  800455:	99                   	cltd   
  800456:	31 d0                	xor    %edx,%eax
  800458:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045a:	83 f8 0f             	cmp    $0xf,%eax
  80045d:	7f 0b                	jg     80046a <vprintfmt+0x142>
  80045f:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  800466:	85 d2                	test   %edx,%edx
  800468:	75 18                	jne    800482 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046a:	50                   	push   %eax
  80046b:	68 38 23 80 00       	push   $0x802338
  800470:	53                   	push   %ebx
  800471:	56                   	push   %esi
  800472:	e8 94 fe ff ff       	call   80030b <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 cc fe ff ff       	jmp    80034e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800482:	52                   	push   %edx
  800483:	68 79 28 80 00       	push   $0x802879
  800488:	53                   	push   %ebx
  800489:	56                   	push   %esi
  80048a:	e8 7c fe ff ff       	call   80030b <printfmt>
  80048f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800495:	e9 b4 fe ff ff       	jmp    80034e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a5:	85 ff                	test   %edi,%edi
  8004a7:	b8 31 23 80 00       	mov    $0x802331,%eax
  8004ac:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b3:	0f 8e 94 00 00 00    	jle    80054d <vprintfmt+0x225>
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 98 00 00 00    	je     80055b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 c8             	pushl  -0x38(%ebp)
  8004c9:	57                   	push   %edi
  8004ca:	e8 d0 02 00 00       	call   80079f <strnlen>
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 c1                	sub    %eax,%ecx
  8004d4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004da:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	eb 0f                	jmp    8004f7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	53                   	push   %ebx
  8004ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ef:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ed                	jg     8004e8 <vprintfmt+0x1c0>
  8004fb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fe:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800501:	85 c9                	test   %ecx,%ecx
  800503:	b8 00 00 00 00       	mov    $0x0,%eax
  800508:	0f 49 c1             	cmovns %ecx,%eax
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	89 cb                	mov    %ecx,%ebx
  800518:	eb 4d                	jmp    800567 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051e:	74 1b                	je     80053b <vprintfmt+0x213>
  800520:	0f be c0             	movsbl %al,%eax
  800523:	83 e8 20             	sub    $0x20,%eax
  800526:	83 f8 5e             	cmp    $0x5e,%eax
  800529:	76 10                	jbe    80053b <vprintfmt+0x213>
					putch('?', putdat);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 0c             	pushl  0xc(%ebp)
  800531:	6a 3f                	push   $0x3f
  800533:	ff 55 08             	call   *0x8(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	eb 0d                	jmp    800548 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	52                   	push   %edx
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800548:	83 eb 01             	sub    $0x1,%ebx
  80054b:	eb 1a                	jmp    800567 <vprintfmt+0x23f>
  80054d:	89 75 08             	mov    %esi,0x8(%ebp)
  800550:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800553:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800556:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800559:	eb 0c                	jmp    800567 <vprintfmt+0x23f>
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 23                	je     800598 <vprintfmt+0x270>
  800575:	85 f6                	test   %esi,%esi
  800577:	78 a1                	js     80051a <vprintfmt+0x1f2>
  800579:	83 ee 01             	sub    $0x1,%esi
  80057c:	79 9c                	jns    80051a <vprintfmt+0x1f2>
  80057e:	89 df                	mov    %ebx,%edi
  800580:	8b 75 08             	mov    0x8(%ebp),%esi
  800583:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800586:	eb 18                	jmp    8005a0 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	53                   	push   %ebx
  80058c:	6a 20                	push   $0x20
  80058e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	eb 08                	jmp    8005a0 <vprintfmt+0x278>
  800598:	89 df                	mov    %ebx,%edi
  80059a:	8b 75 08             	mov    0x8(%ebp),%esi
  80059d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a0:	85 ff                	test   %edi,%edi
  8005a2:	7f e4                	jg     800588 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	e9 a2 fd ff ff       	jmp    80034e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 fa 01             	cmp    $0x1,%edx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 50 04             	mov    0x4(%eax),%edx
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005c2:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x2d1>
	else if (lflag)
  8005c7:	85 d2                	test   %edx,%edx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f1:	89 c1                	mov    %eax,%ecx
  8005f3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005fc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80060e:	0f 89 b0 00 00 00    	jns    8006c4 <vprintfmt+0x39c>
				putch('-', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 2d                	push   $0x2d
  80061a:	ff d6                	call   *%esi
				num = -(long long) num;
  80061c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80061f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800622:	f7 d8                	neg    %eax
  800624:	83 d2 00             	adc    $0x0,%edx
  800627:	f7 da                	neg    %edx
  800629:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
  800637:	e9 88 00 00 00       	jmp    8006c4 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
  80063f:	e8 70 fc ff ff       	call   8002b4 <getuint>
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80064f:	eb 73                	jmp    8006c4 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
  800654:	e8 5b fc ff ff       	call   8002b4 <getuint>
  800659:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80065f:	83 ec 08             	sub    $0x8,%esp
  800662:	53                   	push   %ebx
  800663:	6a 58                	push   $0x58
  800665:	ff d6                	call   *%esi
			putch('X', putdat);
  800667:	83 c4 08             	add    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 58                	push   $0x58
  80066d:	ff d6                	call   *%esi
			putch('X', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 58                	push   $0x58
  800675:	ff d6                	call   *%esi
			goto number;
  800677:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80067a:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80067f:	eb 43                	jmp    8006c4 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 30                	push   $0x30
  800687:	ff d6                	call   *%esi
			putch('x', putdat);
  800689:	83 c4 08             	add    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 78                	push   $0x78
  80068f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006af:	eb 13                	jmp    8006c4 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b4:	e8 fb fb ff ff       	call   8002b4 <getuint>
  8006b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c4:	83 ec 0c             	sub    $0xc,%esp
  8006c7:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006cb:	52                   	push   %edx
  8006cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cf:	50                   	push   %eax
  8006d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	e8 26 fb ff ff       	call   800205 <printnum>
			break;
  8006df:	83 c4 20             	add    $0x20,%esp
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e5:	e9 64 fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	51                   	push   %ecx
  8006ef:	ff d6                	call   *%esi
			break;
  8006f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f7:	e9 52 fc ff ff       	jmp    80034e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 25                	push   $0x25
  800702:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb 03                	jmp    80070c <vprintfmt+0x3e4>
  800709:	83 ef 01             	sub    $0x1,%edi
  80070c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800710:	75 f7                	jne    800709 <vprintfmt+0x3e1>
  800712:	e9 37 fc ff ff       	jmp    80034e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x47>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 22                	jle    800766 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	pushl  0x14(%ebp)
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 ee 02 80 00       	push   $0x8002ee
  800753:	e8 d0 fb ff ff       	call   800328 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	eb 05                	jmp    80076b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076b:	c9                   	leave  
  80076c:	c3                   	ret    

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800776:	50                   	push   %eax
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	ff 75 08             	pushl  0x8(%ebp)
  800780:	e8 9a ff ff ff       	call   80071f <vsnprintf>
	va_end(ap);

	return rc;
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
  800792:	eb 03                	jmp    800797 <strlen+0x10>
		n++;
  800794:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800797:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079b:	75 f7                	jne    800794 <strlen+0xd>
		n++;
	return n;
}
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ad:	eb 03                	jmp    8007b2 <strnlen+0x13>
		n++;
  8007af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b2:	39 c2                	cmp    %eax,%edx
  8007b4:	74 08                	je     8007be <strnlen+0x1f>
  8007b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ba:	75 f3                	jne    8007af <strnlen+0x10>
  8007bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d9:	84 db                	test   %bl,%bl
  8007db:	75 ef                	jne    8007cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007dd:	5b                   	pop    %ebx
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e7:	53                   	push   %ebx
  8007e8:	e8 9a ff ff ff       	call   800787 <strlen>
  8007ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	01 d8                	add    %ebx,%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c5 ff ff ff       	call   8007c0 <strcpy>
	return dst;
}
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	89 f3                	mov    %esi,%ebx
  80080f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	89 f2                	mov    %esi,%edx
  800814:	eb 0f                	jmp    800825 <strncpy+0x23>
		*dst++ = *src;
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 01             	movzbl (%ecx),%eax
  80081c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081f:	80 39 01             	cmpb   $0x1,(%ecx)
  800822:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	39 da                	cmp    %ebx,%edx
  800827:	75 ed                	jne    800816 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800829:	89 f0                	mov    %esi,%eax
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	8b 75 08             	mov    0x8(%ebp),%esi
  800837:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083a:	8b 55 10             	mov    0x10(%ebp),%edx
  80083d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083f:	85 d2                	test   %edx,%edx
  800841:	74 21                	je     800864 <strlcpy+0x35>
  800843:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 09                	jmp    800854 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	83 c1 01             	add    $0x1,%ecx
  800851:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800854:	39 c2                	cmp    %eax,%edx
  800856:	74 09                	je     800861 <strlcpy+0x32>
  800858:	0f b6 19             	movzbl (%ecx),%ebx
  80085b:	84 db                	test   %bl,%bl
  80085d:	75 ec                	jne    80084b <strlcpy+0x1c>
  80085f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800861:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800864:	29 f0                	sub    %esi,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800870:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800873:	eb 06                	jmp    80087b <strcmp+0x11>
		p++, q++;
  800875:	83 c1 01             	add    $0x1,%ecx
  800878:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087b:	0f b6 01             	movzbl (%ecx),%eax
  80087e:	84 c0                	test   %al,%al
  800880:	74 04                	je     800886 <strcmp+0x1c>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	74 ef                	je     800875 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800886:	0f b6 c0             	movzbl %al,%eax
  800889:	0f b6 12             	movzbl (%edx),%edx
  80088c:	29 d0                	sub    %edx,%eax
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089a:	89 c3                	mov    %eax,%ebx
  80089c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089f:	eb 06                	jmp    8008a7 <strncmp+0x17>
		n--, p++, q++;
  8008a1:	83 c0 01             	add    $0x1,%eax
  8008a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a7:	39 d8                	cmp    %ebx,%eax
  8008a9:	74 15                	je     8008c0 <strncmp+0x30>
  8008ab:	0f b6 08             	movzbl (%eax),%ecx
  8008ae:	84 c9                	test   %cl,%cl
  8008b0:	74 04                	je     8008b6 <strncmp+0x26>
  8008b2:	3a 0a                	cmp    (%edx),%cl
  8008b4:	74 eb                	je     8008a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 00             	movzbl (%eax),%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
  8008be:	eb 05                	jmp    8008c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c5:	5b                   	pop    %ebx
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	eb 07                	jmp    8008db <strchr+0x13>
		if (*s == c)
  8008d4:	38 ca                	cmp    %cl,%dl
  8008d6:	74 0f                	je     8008e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	0f b6 10             	movzbl (%eax),%edx
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	75 f2                	jne    8008d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f3:	eb 03                	jmp    8008f8 <strfind+0xf>
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fb:	38 ca                	cmp    %cl,%dl
  8008fd:	74 04                	je     800903 <strfind+0x1a>
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f2                	jne    8008f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800911:	85 c9                	test   %ecx,%ecx
  800913:	74 36                	je     80094b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800915:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091b:	75 28                	jne    800945 <memset+0x40>
  80091d:	f6 c1 03             	test   $0x3,%cl
  800920:	75 23                	jne    800945 <memset+0x40>
		c &= 0xFF;
  800922:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800926:	89 d3                	mov    %edx,%ebx
  800928:	c1 e3 08             	shl    $0x8,%ebx
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	c1 e6 18             	shl    $0x18,%esi
  800930:	89 d0                	mov    %edx,%eax
  800932:	c1 e0 10             	shl    $0x10,%eax
  800935:	09 f0                	or     %esi,%eax
  800937:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800939:	89 d8                	mov    %ebx,%eax
  80093b:	09 d0                	or     %edx,%eax
  80093d:	c1 e9 02             	shr    $0x2,%ecx
  800940:	fc                   	cld    
  800941:	f3 ab                	rep stos %eax,%es:(%edi)
  800943:	eb 06                	jmp    80094b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800945:	8b 45 0c             	mov    0xc(%ebp),%eax
  800948:	fc                   	cld    
  800949:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094b:	89 f8                	mov    %edi,%eax
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5f                   	pop    %edi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    

00800952 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	57                   	push   %edi
  800956:	56                   	push   %esi
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800960:	39 c6                	cmp    %eax,%esi
  800962:	73 35                	jae    800999 <memmove+0x47>
  800964:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800967:	39 d0                	cmp    %edx,%eax
  800969:	73 2e                	jae    800999 <memmove+0x47>
		s += n;
		d += n;
  80096b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 d6                	mov    %edx,%esi
  800970:	09 fe                	or     %edi,%esi
  800972:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800978:	75 13                	jne    80098d <memmove+0x3b>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0e                	jne    80098d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097f:	83 ef 04             	sub    $0x4,%edi
  800982:	8d 72 fc             	lea    -0x4(%edx),%esi
  800985:	c1 e9 02             	shr    $0x2,%ecx
  800988:	fd                   	std    
  800989:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098b:	eb 09                	jmp    800996 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098d:	83 ef 01             	sub    $0x1,%edi
  800990:	8d 72 ff             	lea    -0x1(%edx),%esi
  800993:	fd                   	std    
  800994:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800996:	fc                   	cld    
  800997:	eb 1d                	jmp    8009b6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 f2                	mov    %esi,%edx
  80099b:	09 c2                	or     %eax,%edx
  80099d:	f6 c2 03             	test   $0x3,%dl
  8009a0:	75 0f                	jne    8009b1 <memmove+0x5f>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 0a                	jne    8009b1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	89 c7                	mov    %eax,%edi
  8009ac:	fc                   	cld    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 05                	jmp    8009b6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b1:	89 c7                	mov    %eax,%edi
  8009b3:	fc                   	cld    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b6:	5e                   	pop    %esi
  8009b7:	5f                   	pop    %edi
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bd:	ff 75 10             	pushl  0x10(%ebp)
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	ff 75 08             	pushl  0x8(%ebp)
  8009c6:	e8 87 ff ff ff       	call   800952 <memmove>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d8:	89 c6                	mov    %eax,%esi
  8009da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dd:	eb 1a                	jmp    8009f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	0f b6 1a             	movzbl (%edx),%ebx
  8009e5:	38 d9                	cmp    %bl,%cl
  8009e7:	74 0a                	je     8009f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e9:	0f b6 c1             	movzbl %cl,%eax
  8009ec:	0f b6 db             	movzbl %bl,%ebx
  8009ef:	29 d8                	sub    %ebx,%eax
  8009f1:	eb 0f                	jmp    800a02 <memcmp+0x35>
		s1++, s2++;
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f0                	cmp    %esi,%eax
  8009fb:	75 e2                	jne    8009df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0d:	89 c1                	mov    %eax,%ecx
  800a0f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a16:	eb 0a                	jmp    800a22 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a18:	0f b6 10             	movzbl (%eax),%edx
  800a1b:	39 da                	cmp    %ebx,%edx
  800a1d:	74 07                	je     800a26 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	39 c8                	cmp    %ecx,%eax
  800a24:	72 f2                	jb     800a18 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a26:	5b                   	pop    %ebx
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x11>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0xe>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	75 0a                	jne    800a53 <strtol+0x2a>
		s++;
  800a49:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a51:	eb 11                	jmp    800a64 <strtol+0x3b>
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a58:	3c 2d                	cmp    $0x2d,%al
  800a5a:	75 08                	jne    800a64 <strtol+0x3b>
		s++, neg = 1;
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6a:	75 15                	jne    800a81 <strtol+0x58>
  800a6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6f:	75 10                	jne    800a81 <strtol+0x58>
  800a71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a75:	75 7c                	jne    800af3 <strtol+0xca>
		s += 2, base = 16;
  800a77:	83 c1 02             	add    $0x2,%ecx
  800a7a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7f:	eb 16                	jmp    800a97 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a81:	85 db                	test   %ebx,%ebx
  800a83:	75 12                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a85:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8d:	75 08                	jne    800a97 <strtol+0x6e>
		s++, base = 8;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9f:	0f b6 11             	movzbl (%ecx),%edx
  800aa2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa5:	89 f3                	mov    %esi,%ebx
  800aa7:	80 fb 09             	cmp    $0x9,%bl
  800aaa:	77 08                	ja     800ab4 <strtol+0x8b>
			dig = *s - '0';
  800aac:	0f be d2             	movsbl %dl,%edx
  800aaf:	83 ea 30             	sub    $0x30,%edx
  800ab2:	eb 22                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab7:	89 f3                	mov    %esi,%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 08                	ja     800ac6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abe:	0f be d2             	movsbl %dl,%edx
  800ac1:	83 ea 57             	sub    $0x57,%edx
  800ac4:	eb 10                	jmp    800ad6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 16                	ja     800ae6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad9:	7d 0b                	jge    800ae6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800adb:	83 c1 01             	add    $0x1,%ecx
  800ade:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae4:	eb b9                	jmp    800a9f <strtol+0x76>

	if (endptr)
  800ae6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aea:	74 0d                	je     800af9 <strtol+0xd0>
		*endptr = (char *) s;
  800aec:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aef:	89 0e                	mov    %ecx,(%esi)
  800af1:	eb 06                	jmp    800af9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af3:	85 db                	test   %ebx,%ebx
  800af5:	74 98                	je     800a8f <strtol+0x66>
  800af7:	eb 9e                	jmp    800a97 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af9:	89 c2                	mov    %eax,%edx
  800afb:	f7 da                	neg    %edx
  800afd:	85 ff                	test   %edi,%edi
  800aff:	0f 45 c2             	cmovne %edx,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	89 c6                	mov    %eax,%esi
  800b1e:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b52:	b8 03 00 00 00       	mov    $0x3,%eax
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	89 cb                	mov    %ecx,%ebx
  800b5c:	89 cf                	mov    %ecx,%edi
  800b5e:	89 ce                	mov    %ecx,%esi
  800b60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b62:	85 c0                	test   %eax,%eax
  800b64:	7e 17                	jle    800b7d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b66:	83 ec 0c             	sub    $0xc,%esp
  800b69:	50                   	push   %eax
  800b6a:	6a 03                	push   $0x3
  800b6c:	68 1f 26 80 00       	push   $0x80261f
  800b71:	6a 23                	push   $0x23
  800b73:	68 3c 26 80 00       	push   $0x80263c
  800b78:	e8 a0 13 00 00       	call   801f1d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 02 00 00 00       	mov    $0x2,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_yield>:

void
sys_yield(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bcc:	be 00 00 00 00       	mov    $0x0,%esi
  800bd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	89 f7                	mov    %esi,%edi
  800be1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 17                	jle    800bfe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	50                   	push   %eax
  800beb:	6a 04                	push   $0x4
  800bed:	68 1f 26 80 00       	push   $0x80261f
  800bf2:	6a 23                	push   $0x23
  800bf4:	68 3c 26 80 00       	push   $0x80263c
  800bf9:	e8 1f 13 00 00       	call   801f1d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5e                   	pop    %esi
  800c03:	5f                   	pop    %edi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	57                   	push   %edi
  800c0a:	56                   	push   %esi
  800c0b:	53                   	push   %ebx
  800c0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c0f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c20:	8b 75 18             	mov    0x18(%ebp),%esi
  800c23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c25:	85 c0                	test   %eax,%eax
  800c27:	7e 17                	jle    800c40 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 05                	push   $0x5
  800c2f:	68 1f 26 80 00       	push   $0x80261f
  800c34:	6a 23                	push   $0x23
  800c36:	68 3c 26 80 00       	push   $0x80263c
  800c3b:	e8 dd 12 00 00       	call   801f1d <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c56:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	89 df                	mov    %ebx,%edi
  800c63:	89 de                	mov    %ebx,%esi
  800c65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	7e 17                	jle    800c82 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 06                	push   $0x6
  800c71:	68 1f 26 80 00       	push   $0x80261f
  800c76:	6a 23                	push   $0x23
  800c78:	68 3c 26 80 00       	push   $0x80263c
  800c7d:	e8 9b 12 00 00       	call   801f1d <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c98:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 df                	mov    %ebx,%edi
  800ca5:	89 de                	mov    %ebx,%esi
  800ca7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ca9:	85 c0                	test   %eax,%eax
  800cab:	7e 17                	jle    800cc4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 08                	push   $0x8
  800cb3:	68 1f 26 80 00       	push   $0x80261f
  800cb8:	6a 23                	push   $0x23
  800cba:	68 3c 26 80 00       	push   $0x80263c
  800cbf:	e8 59 12 00 00       	call   801f1d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	b8 09 00 00 00       	mov    $0x9,%eax
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7e 17                	jle    800d06 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 09                	push   $0x9
  800cf5:	68 1f 26 80 00       	push   $0x80261f
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 3c 26 80 00       	push   $0x80263c
  800d01:	e8 17 12 00 00       	call   801f1d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7e 17                	jle    800d48 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 0a                	push   $0xa
  800d37:	68 1f 26 80 00       	push   $0x80261f
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 3c 26 80 00       	push   $0x80263c
  800d43:	e8 d5 11 00 00       	call   801f1d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	57                   	push   %edi
  800d54:	56                   	push   %esi
  800d55:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 0d                	push   $0xd
  800d9b:	68 1f 26 80 00       	push   $0x80261f
  800da0:	6a 23                	push   $0x23
  800da2:	68 3c 26 80 00       	push   $0x80263c
  800da7:	e8 71 11 00 00       	call   801f1d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dbc:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800dbe:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dc2:	74 11                	je     800dd5 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800dc4:	89 d8                	mov    %ebx,%eax
  800dc6:	c1 e8 0c             	shr    $0xc,%eax
  800dc9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800dd0:	f6 c4 08             	test   $0x8,%ah
  800dd3:	75 14                	jne    800de9 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800dd5:	83 ec 04             	sub    $0x4,%esp
  800dd8:	68 4a 26 80 00       	push   $0x80264a
  800ddd:	6a 21                	push   $0x21
  800ddf:	68 60 26 80 00       	push   $0x802660
  800de4:	e8 34 11 00 00       	call   801f1d <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800de9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800def:	e8 91 fd ff ff       	call   800b85 <sys_getenvid>
  800df4:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	6a 07                	push   $0x7
  800dfb:	68 00 f0 7f 00       	push   $0x7ff000
  800e00:	50                   	push   %eax
  800e01:	e8 bd fd ff ff       	call   800bc3 <sys_page_alloc>
  800e06:	83 c4 10             	add    $0x10,%esp
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	79 14                	jns    800e21 <pgfault+0x6d>
		panic("sys_page_alloc");
  800e0d:	83 ec 04             	sub    $0x4,%esp
  800e10:	68 6b 26 80 00       	push   $0x80266b
  800e15:	6a 30                	push   $0x30
  800e17:	68 60 26 80 00       	push   $0x802660
  800e1c:	e8 fc 10 00 00       	call   801f1d <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800e21:	83 ec 04             	sub    $0x4,%esp
  800e24:	68 00 10 00 00       	push   $0x1000
  800e29:	53                   	push   %ebx
  800e2a:	68 00 f0 7f 00       	push   $0x7ff000
  800e2f:	e8 86 fb ff ff       	call   8009ba <memcpy>
	retv = sys_page_unmap(envid, addr);
  800e34:	83 c4 08             	add    $0x8,%esp
  800e37:	53                   	push   %ebx
  800e38:	56                   	push   %esi
  800e39:	e8 0a fe ff ff       	call   800c48 <sys_page_unmap>
	if(retv < 0){
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	79 12                	jns    800e57 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800e45:	50                   	push   %eax
  800e46:	68 58 27 80 00       	push   $0x802758
  800e4b:	6a 35                	push   $0x35
  800e4d:	68 60 26 80 00       	push   $0x802660
  800e52:	e8 c6 10 00 00       	call   801f1d <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800e57:	83 ec 0c             	sub    $0xc,%esp
  800e5a:	6a 07                	push   $0x7
  800e5c:	53                   	push   %ebx
  800e5d:	56                   	push   %esi
  800e5e:	68 00 f0 7f 00       	push   $0x7ff000
  800e63:	56                   	push   %esi
  800e64:	e8 9d fd ff ff       	call   800c06 <sys_page_map>
	if(retv < 0){
  800e69:	83 c4 20             	add    $0x20,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	79 14                	jns    800e84 <pgfault+0xd0>
		panic("sys_page_map");
  800e70:	83 ec 04             	sub    $0x4,%esp
  800e73:	68 7a 26 80 00       	push   $0x80267a
  800e78:	6a 39                	push   $0x39
  800e7a:	68 60 26 80 00       	push   $0x802660
  800e7f:	e8 99 10 00 00       	call   801f1d <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800e84:	83 ec 08             	sub    $0x8,%esp
  800e87:	68 00 f0 7f 00       	push   $0x7ff000
  800e8c:	56                   	push   %esi
  800e8d:	e8 b6 fd ff ff       	call   800c48 <sys_page_unmap>
	if(retv < 0){
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	79 14                	jns    800ead <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	68 87 26 80 00       	push   $0x802687
  800ea1:	6a 3d                	push   $0x3d
  800ea3:	68 60 26 80 00       	push   $0x802660
  800ea8:	e8 70 10 00 00       	call   801f1d <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800ead:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    

00800eb4 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800ebc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ebf:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	53                   	push   %ebx
  800ec6:	68 a4 26 80 00       	push   $0x8026a4
  800ecb:	e8 21 f3 ff ff       	call   8001f1 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800ed0:	83 c4 0c             	add    $0xc,%esp
  800ed3:	6a 07                	push   $0x7
  800ed5:	53                   	push   %ebx
  800ed6:	56                   	push   %esi
  800ed7:	e8 e7 fc ff ff       	call   800bc3 <sys_page_alloc>
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	79 15                	jns    800ef8 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800ee3:	50                   	push   %eax
  800ee4:	68 b7 26 80 00       	push   $0x8026b7
  800ee9:	68 90 00 00 00       	push   $0x90
  800eee:	68 60 26 80 00       	push   $0x802660
  800ef3:	e8 25 10 00 00       	call   801f1d <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	68 ca 26 80 00       	push   $0x8026ca
  800f00:	e8 ec f2 ff ff       	call   8001f1 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800f05:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0c:	68 00 00 40 00       	push   $0x400000
  800f11:	6a 00                	push   $0x0
  800f13:	53                   	push   %ebx
  800f14:	56                   	push   %esi
  800f15:	e8 ec fc ff ff       	call   800c06 <sys_page_map>
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 15                	jns    800f36 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800f21:	50                   	push   %eax
  800f22:	68 d2 26 80 00       	push   $0x8026d2
  800f27:	68 94 00 00 00       	push   $0x94
  800f2c:	68 60 26 80 00       	push   $0x802660
  800f31:	e8 e7 0f 00 00       	call   801f1d <_panic>
        cprintf("af_p_m.");
  800f36:	83 ec 0c             	sub    $0xc,%esp
  800f39:	68 e3 26 80 00       	push   $0x8026e3
  800f3e:	e8 ae f2 ff ff       	call   8001f1 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  800f43:	83 c4 0c             	add    $0xc,%esp
  800f46:	68 00 10 00 00       	push   $0x1000
  800f4b:	53                   	push   %ebx
  800f4c:	68 00 00 40 00       	push   $0x400000
  800f51:	e8 fc f9 ff ff       	call   800952 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  800f56:	c7 04 24 eb 26 80 00 	movl   $0x8026eb,(%esp)
  800f5d:	e8 8f f2 ff ff       	call   8001f1 <cprintf>
}
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	57                   	push   %edi
  800f70:	56                   	push   %esi
  800f71:	53                   	push   %ebx
  800f72:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800f75:	68 b4 0d 80 00       	push   $0x800db4
  800f7a:	e8 e4 0f 00 00       	call   801f63 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f7f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f84:	cd 30                	int    $0x30
  800f86:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f89:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	79 17                	jns    800faa <fork+0x3e>
		panic("sys_exofork failed.");
  800f93:	83 ec 04             	sub    $0x4,%esp
  800f96:	68 f9 26 80 00       	push   $0x8026f9
  800f9b:	68 b7 00 00 00       	push   $0xb7
  800fa0:	68 60 26 80 00       	push   $0x802660
  800fa5:	e8 73 0f 00 00       	call   801f1d <_panic>
  800faa:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  800faf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fb3:	75 21                	jne    800fd6 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fb5:	e8 cb fb ff ff       	call   800b85 <sys_getenvid>
  800fba:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fbf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fc2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fc7:	a3 08 40 80 00       	mov    %eax,0x804008
//		cprintf("we are the child.\n");
		return 0;
  800fcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd1:	e9 69 01 00 00       	jmp    80113f <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800fd6:	89 d8                	mov    %ebx,%eax
  800fd8:	c1 e8 16             	shr    $0x16,%eax
  800fdb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800fe2:	a8 01                	test   $0x1,%al
  800fe4:	0f 84 d6 00 00 00    	je     8010c0 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  800fea:	89 de                	mov    %ebx,%esi
  800fec:	c1 ee 0c             	shr    $0xc,%esi
  800fef:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800ff6:	a8 01                	test   $0x1,%al
  800ff8:	0f 84 c2 00 00 00    	je     8010c0 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  800ffe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  801005:	89 f7                	mov    %esi,%edi
  801007:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  80100a:	e8 76 fb ff ff       	call   800b85 <sys_getenvid>
  80100f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  801012:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801019:	f6 c4 04             	test   $0x4,%ah
  80101c:	74 1c                	je     80103a <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  80101e:	83 ec 0c             	sub    $0xc,%esp
  801021:	68 07 0e 00 00       	push   $0xe07
  801026:	57                   	push   %edi
  801027:	ff 75 e0             	pushl  -0x20(%ebp)
  80102a:	57                   	push   %edi
  80102b:	6a 00                	push   $0x0
  80102d:	e8 d4 fb ff ff       	call   800c06 <sys_page_map>
  801032:	83 c4 20             	add    $0x20,%esp
  801035:	e9 86 00 00 00       	jmp    8010c0 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  80103a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801041:	a8 02                	test   $0x2,%al
  801043:	75 0c                	jne    801051 <fork+0xe5>
  801045:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80104c:	f6 c4 08             	test   $0x8,%ah
  80104f:	74 5b                	je     8010ac <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	68 05 08 00 00       	push   $0x805
  801059:	57                   	push   %edi
  80105a:	ff 75 e0             	pushl  -0x20(%ebp)
  80105d:	57                   	push   %edi
  80105e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801061:	e8 a0 fb ff ff       	call   800c06 <sys_page_map>
  801066:	83 c4 20             	add    $0x20,%esp
  801069:	85 c0                	test   %eax,%eax
  80106b:	79 12                	jns    80107f <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  80106d:	50                   	push   %eax
  80106e:	68 7c 27 80 00       	push   $0x80277c
  801073:	6a 5f                	push   $0x5f
  801075:	68 60 26 80 00       	push   $0x802660
  80107a:	e8 9e 0e 00 00       	call   801f1d <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80107f:	83 ec 0c             	sub    $0xc,%esp
  801082:	68 05 08 00 00       	push   $0x805
  801087:	57                   	push   %edi
  801088:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108b:	50                   	push   %eax
  80108c:	57                   	push   %edi
  80108d:	50                   	push   %eax
  80108e:	e8 73 fb ff ff       	call   800c06 <sys_page_map>
  801093:	83 c4 20             	add    $0x20,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	79 26                	jns    8010c0 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  80109a:	50                   	push   %eax
  80109b:	68 a0 27 80 00       	push   $0x8027a0
  8010a0:	6a 64                	push   $0x64
  8010a2:	68 60 26 80 00       	push   $0x802660
  8010a7:	e8 71 0e 00 00       	call   801f1d <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	6a 05                	push   $0x5
  8010b1:	57                   	push   %edi
  8010b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8010b5:	57                   	push   %edi
  8010b6:	6a 00                	push   $0x0
  8010b8:	e8 49 fb ff ff       	call   800c06 <sys_page_map>
  8010bd:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  8010c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c6:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010cc:	0f 85 04 ff ff ff    	jne    800fd6 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	6a 07                	push   $0x7
  8010d7:	68 00 f0 bf ee       	push   $0xeebff000
  8010dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8010df:	e8 df fa ff ff       	call   800bc3 <sys_page_alloc>
	if(retv < 0){
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 17                	jns    801102 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8010eb:	83 ec 04             	sub    $0x4,%esp
  8010ee:	68 0d 27 80 00       	push   $0x80270d
  8010f3:	68 cc 00 00 00       	push   $0xcc
  8010f8:	68 60 26 80 00       	push   $0x802660
  8010fd:	e8 1b 0e 00 00       	call   801f1d <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  801102:	83 ec 08             	sub    $0x8,%esp
  801105:	68 c8 1f 80 00       	push   $0x801fc8
  80110a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80110d:	57                   	push   %edi
  80110e:	e8 fb fb ff ff       	call   800d0e <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  801113:	83 c4 08             	add    $0x8,%esp
  801116:	6a 02                	push   $0x2
  801118:	57                   	push   %edi
  801119:	e8 6c fb ff ff       	call   800c8a <sys_env_set_status>
	if(retv < 0){
  80111e:	83 c4 10             	add    $0x10,%esp
  801121:	85 c0                	test   %eax,%eax
  801123:	79 17                	jns    80113c <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  801125:	83 ec 04             	sub    $0x4,%esp
  801128:	68 25 27 80 00       	push   $0x802725
  80112d:	68 dd 00 00 00       	push   $0xdd
  801132:	68 60 26 80 00       	push   $0x802660
  801137:	e8 e1 0d 00 00       	call   801f1d <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  80113c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  80113f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801142:	5b                   	pop    %ebx
  801143:	5e                   	pop    %esi
  801144:	5f                   	pop    %edi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    

00801147 <sfork>:

// Challenge!
int
sfork(void)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80114d:	68 41 27 80 00       	push   $0x802741
  801152:	68 e8 00 00 00       	push   $0xe8
  801157:	68 60 26 80 00       	push   $0x802660
  80115c:	e8 bc 0d 00 00       	call   801f1d <_panic>

00801161 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801169:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	ff 75 0c             	pushl  0xc(%ebp)
  801172:	e8 fc fb ff ff       	call   800d73 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 f6                	test   %esi,%esi
  80117c:	74 1c                	je     80119a <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  80117e:	a1 08 40 80 00       	mov    0x804008,%eax
  801183:	8b 40 78             	mov    0x78(%eax),%eax
  801186:	89 06                	mov    %eax,(%esi)
  801188:	eb 10                	jmp    80119a <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	68 c2 27 80 00       	push   $0x8027c2
  801192:	e8 5a f0 ff ff       	call   8001f1 <cprintf>
  801197:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  80119a:	a1 08 40 80 00       	mov    0x804008,%eax
  80119f:	8b 50 74             	mov    0x74(%eax),%edx
  8011a2:	85 d2                	test   %edx,%edx
  8011a4:	74 e4                	je     80118a <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  8011a6:	85 db                	test   %ebx,%ebx
  8011a8:	74 05                	je     8011af <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  8011aa:	8b 40 74             	mov    0x74(%eax),%eax
  8011ad:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011af:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b4:	8b 40 70             	mov    0x70(%eax),%eax

}
  8011b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ba:	5b                   	pop    %ebx
  8011bb:	5e                   	pop    %esi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  8011d0:	85 db                	test   %ebx,%ebx
  8011d2:	75 13                	jne    8011e7 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  8011d4:	6a 00                	push   $0x0
  8011d6:	68 00 00 c0 ee       	push   $0xeec00000
  8011db:	56                   	push   %esi
  8011dc:	57                   	push   %edi
  8011dd:	e8 6e fb ff ff       	call   800d50 <sys_ipc_try_send>
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	eb 0e                	jmp    8011f5 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  8011e7:	ff 75 14             	pushl  0x14(%ebp)
  8011ea:	53                   	push   %ebx
  8011eb:	56                   	push   %esi
  8011ec:	57                   	push   %edi
  8011ed:	e8 5e fb ff ff       	call   800d50 <sys_ipc_try_send>
  8011f2:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	75 d7                	jne    8011d0 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8011f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fc:	5b                   	pop    %ebx
  8011fd:	5e                   	pop    %esi
  8011fe:	5f                   	pop    %edi
  8011ff:	5d                   	pop    %ebp
  801200:	c3                   	ret    

00801201 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801207:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80120c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80120f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801215:	8b 52 50             	mov    0x50(%edx),%edx
  801218:	39 ca                	cmp    %ecx,%edx
  80121a:	75 0d                	jne    801229 <ipc_find_env+0x28>
			return envs[i].env_id;
  80121c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80121f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801224:	8b 40 48             	mov    0x48(%eax),%eax
  801227:	eb 0f                	jmp    801238 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801229:	83 c0 01             	add    $0x1,%eax
  80122c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801231:	75 d9                	jne    80120c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801233:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    

0080123a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80123a:	55                   	push   %ebp
  80123b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123d:	8b 45 08             	mov    0x8(%ebp),%eax
  801240:	05 00 00 00 30       	add    $0x30000000,%eax
  801245:	c1 e8 0c             	shr    $0xc,%eax
}
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80124d:	8b 45 08             	mov    0x8(%ebp),%eax
  801250:	05 00 00 00 30       	add    $0x30000000,%eax
  801255:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80125a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80125f:	5d                   	pop    %ebp
  801260:	c3                   	ret    

00801261 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801267:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	c1 ea 16             	shr    $0x16,%edx
  801271:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801278:	f6 c2 01             	test   $0x1,%dl
  80127b:	74 11                	je     80128e <fd_alloc+0x2d>
  80127d:	89 c2                	mov    %eax,%edx
  80127f:	c1 ea 0c             	shr    $0xc,%edx
  801282:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801289:	f6 c2 01             	test   $0x1,%dl
  80128c:	75 09                	jne    801297 <fd_alloc+0x36>
			*fd_store = fd;
  80128e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801290:	b8 00 00 00 00       	mov    $0x0,%eax
  801295:	eb 17                	jmp    8012ae <fd_alloc+0x4d>
  801297:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a1:	75 c9                	jne    80126c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012a9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b6:	83 f8 1f             	cmp    $0x1f,%eax
  8012b9:	77 36                	ja     8012f1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012bb:	c1 e0 0c             	shl    $0xc,%eax
  8012be:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	c1 ea 16             	shr    $0x16,%edx
  8012c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012cf:	f6 c2 01             	test   $0x1,%dl
  8012d2:	74 24                	je     8012f8 <fd_lookup+0x48>
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	c1 ea 0c             	shr    $0xc,%edx
  8012d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e0:	f6 c2 01             	test   $0x1,%dl
  8012e3:	74 1a                	je     8012ff <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e8:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ef:	eb 13                	jmp    801304 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f6:	eb 0c                	jmp    801304 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fd:	eb 05                	jmp    801304 <fd_lookup+0x54>
  8012ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	83 ec 08             	sub    $0x8,%esp
  80130c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130f:	ba 50 28 80 00       	mov    $0x802850,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801314:	eb 13                	jmp    801329 <dev_lookup+0x23>
  801316:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801319:	39 08                	cmp    %ecx,(%eax)
  80131b:	75 0c                	jne    801329 <dev_lookup+0x23>
			*dev = devtab[i];
  80131d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801320:	89 01                	mov    %eax,(%ecx)
			return 0;
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
  801327:	eb 2e                	jmp    801357 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801329:	8b 02                	mov    (%edx),%eax
  80132b:	85 c0                	test   %eax,%eax
  80132d:	75 e7                	jne    801316 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80132f:	a1 08 40 80 00       	mov    0x804008,%eax
  801334:	8b 40 48             	mov    0x48(%eax),%eax
  801337:	83 ec 04             	sub    $0x4,%esp
  80133a:	51                   	push   %ecx
  80133b:	50                   	push   %eax
  80133c:	68 d4 27 80 00       	push   $0x8027d4
  801341:	e8 ab ee ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  801346:	8b 45 0c             	mov    0xc(%ebp),%eax
  801349:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801357:	c9                   	leave  
  801358:	c3                   	ret    

00801359 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	56                   	push   %esi
  80135d:	53                   	push   %ebx
  80135e:	83 ec 10             	sub    $0x10,%esp
  801361:	8b 75 08             	mov    0x8(%ebp),%esi
  801364:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801371:	c1 e8 0c             	shr    $0xc,%eax
  801374:	50                   	push   %eax
  801375:	e8 36 ff ff ff       	call   8012b0 <fd_lookup>
  80137a:	83 c4 08             	add    $0x8,%esp
  80137d:	85 c0                	test   %eax,%eax
  80137f:	78 05                	js     801386 <fd_close+0x2d>
	    || fd != fd2)
  801381:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801384:	74 0c                	je     801392 <fd_close+0x39>
		return (must_exist ? r : 0);
  801386:	84 db                	test   %bl,%bl
  801388:	ba 00 00 00 00       	mov    $0x0,%edx
  80138d:	0f 44 c2             	cmove  %edx,%eax
  801390:	eb 41                	jmp    8013d3 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801398:	50                   	push   %eax
  801399:	ff 36                	pushl  (%esi)
  80139b:	e8 66 ff ff ff       	call   801306 <dev_lookup>
  8013a0:	89 c3                	mov    %eax,%ebx
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 1a                	js     8013c3 <fd_close+0x6a>
		if (dev->dev_close)
  8013a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ac:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013af:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	74 0b                	je     8013c3 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	56                   	push   %esi
  8013bc:	ff d0                	call   *%eax
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	56                   	push   %esi
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 7a f8 ff ff       	call   800c48 <sys_page_unmap>
	return r;
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	89 d8                	mov    %ebx,%eax
}
  8013d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	ff 75 08             	pushl  0x8(%ebp)
  8013e7:	e8 c4 fe ff ff       	call   8012b0 <fd_lookup>
  8013ec:	83 c4 08             	add    $0x8,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 10                	js     801403 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	6a 01                	push   $0x1
  8013f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fb:	e8 59 ff ff ff       	call   801359 <fd_close>
  801400:	83 c4 10             	add    $0x10,%esp
}
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <close_all>:

void
close_all(void)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	53                   	push   %ebx
  801409:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801411:	83 ec 0c             	sub    $0xc,%esp
  801414:	53                   	push   %ebx
  801415:	e8 c0 ff ff ff       	call   8013da <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80141a:	83 c3 01             	add    $0x1,%ebx
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	83 fb 20             	cmp    $0x20,%ebx
  801423:	75 ec                	jne    801411 <close_all+0xc>
		close(i);
}
  801425:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	57                   	push   %edi
  80142e:	56                   	push   %esi
  80142f:	53                   	push   %ebx
  801430:	83 ec 2c             	sub    $0x2c,%esp
  801433:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801436:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	ff 75 08             	pushl  0x8(%ebp)
  80143d:	e8 6e fe ff ff       	call   8012b0 <fd_lookup>
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	85 c0                	test   %eax,%eax
  801447:	0f 88 c1 00 00 00    	js     80150e <dup+0xe4>
		return r;
	close(newfdnum);
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	56                   	push   %esi
  801451:	e8 84 ff ff ff       	call   8013da <close>

	newfd = INDEX2FD(newfdnum);
  801456:	89 f3                	mov    %esi,%ebx
  801458:	c1 e3 0c             	shl    $0xc,%ebx
  80145b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801461:	83 c4 04             	add    $0x4,%esp
  801464:	ff 75 e4             	pushl  -0x1c(%ebp)
  801467:	e8 de fd ff ff       	call   80124a <fd2data>
  80146c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80146e:	89 1c 24             	mov    %ebx,(%esp)
  801471:	e8 d4 fd ff ff       	call   80124a <fd2data>
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80147c:	89 f8                	mov    %edi,%eax
  80147e:	c1 e8 16             	shr    $0x16,%eax
  801481:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801488:	a8 01                	test   $0x1,%al
  80148a:	74 37                	je     8014c3 <dup+0x99>
  80148c:	89 f8                	mov    %edi,%eax
  80148e:	c1 e8 0c             	shr    $0xc,%eax
  801491:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801498:	f6 c2 01             	test   $0x1,%dl
  80149b:	74 26                	je     8014c3 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80149d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ac:	50                   	push   %eax
  8014ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b0:	6a 00                	push   $0x0
  8014b2:	57                   	push   %edi
  8014b3:	6a 00                	push   $0x0
  8014b5:	e8 4c f7 ff ff       	call   800c06 <sys_page_map>
  8014ba:	89 c7                	mov    %eax,%edi
  8014bc:	83 c4 20             	add    $0x20,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 2e                	js     8014f1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c6:	89 d0                	mov    %edx,%eax
  8014c8:	c1 e8 0c             	shr    $0xc,%eax
  8014cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8014da:	50                   	push   %eax
  8014db:	53                   	push   %ebx
  8014dc:	6a 00                	push   $0x0
  8014de:	52                   	push   %edx
  8014df:	6a 00                	push   $0x0
  8014e1:	e8 20 f7 ff ff       	call   800c06 <sys_page_map>
  8014e6:	89 c7                	mov    %eax,%edi
  8014e8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014eb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ed:	85 ff                	test   %edi,%edi
  8014ef:	79 1d                	jns    80150e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f1:	83 ec 08             	sub    $0x8,%esp
  8014f4:	53                   	push   %ebx
  8014f5:	6a 00                	push   $0x0
  8014f7:	e8 4c f7 ff ff       	call   800c48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014fc:	83 c4 08             	add    $0x8,%esp
  8014ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801502:	6a 00                	push   $0x0
  801504:	e8 3f f7 ff ff       	call   800c48 <sys_page_unmap>
	return r;
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	89 f8                	mov    %edi,%eax
}
  80150e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5f                   	pop    %edi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
  80151d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801520:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	53                   	push   %ebx
  801525:	e8 86 fd ff ff       	call   8012b0 <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 6d                	js     8015a0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	ff 30                	pushl  (%eax)
  80153f:	e8 c2 fd ff ff       	call   801306 <dev_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 4c                	js     801597 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80154e:	8b 42 08             	mov    0x8(%edx),%eax
  801551:	83 e0 03             	and    $0x3,%eax
  801554:	83 f8 01             	cmp    $0x1,%eax
  801557:	75 21                	jne    80157a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801559:	a1 08 40 80 00       	mov    0x804008,%eax
  80155e:	8b 40 48             	mov    0x48(%eax),%eax
  801561:	83 ec 04             	sub    $0x4,%esp
  801564:	53                   	push   %ebx
  801565:	50                   	push   %eax
  801566:	68 15 28 80 00       	push   $0x802815
  80156b:	e8 81 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801578:	eb 26                	jmp    8015a0 <read+0x8a>
	}
	if (!dev->dev_read)
  80157a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157d:	8b 40 08             	mov    0x8(%eax),%eax
  801580:	85 c0                	test   %eax,%eax
  801582:	74 17                	je     80159b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	ff 75 10             	pushl  0x10(%ebp)
  80158a:	ff 75 0c             	pushl  0xc(%ebp)
  80158d:	52                   	push   %edx
  80158e:	ff d0                	call   *%eax
  801590:	89 c2                	mov    %eax,%edx
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	eb 09                	jmp    8015a0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801597:	89 c2                	mov    %eax,%edx
  801599:	eb 05                	jmp    8015a0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015a0:	89 d0                	mov    %edx,%eax
  8015a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a5:	c9                   	leave  
  8015a6:	c3                   	ret    

008015a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a7:	55                   	push   %ebp
  8015a8:	89 e5                	mov    %esp,%ebp
  8015aa:	57                   	push   %edi
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 0c             	sub    $0xc,%esp
  8015b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bb:	eb 21                	jmp    8015de <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bd:	83 ec 04             	sub    $0x4,%esp
  8015c0:	89 f0                	mov    %esi,%eax
  8015c2:	29 d8                	sub    %ebx,%eax
  8015c4:	50                   	push   %eax
  8015c5:	89 d8                	mov    %ebx,%eax
  8015c7:	03 45 0c             	add    0xc(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	57                   	push   %edi
  8015cc:	e8 45 ff ff ff       	call   801516 <read>
		if (m < 0)
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 10                	js     8015e8 <readn+0x41>
			return m;
		if (m == 0)
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	74 0a                	je     8015e6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015dc:	01 c3                	add    %eax,%ebx
  8015de:	39 f3                	cmp    %esi,%ebx
  8015e0:	72 db                	jb     8015bd <readn+0x16>
  8015e2:	89 d8                	mov    %ebx,%eax
  8015e4:	eb 02                	jmp    8015e8 <readn+0x41>
  8015e6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	83 ec 14             	sub    $0x14,%esp
  8015f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fd:	50                   	push   %eax
  8015fe:	53                   	push   %ebx
  8015ff:	e8 ac fc ff ff       	call   8012b0 <fd_lookup>
  801604:	83 c4 08             	add    $0x8,%esp
  801607:	89 c2                	mov    %eax,%edx
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 68                	js     801675 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160d:	83 ec 08             	sub    $0x8,%esp
  801610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801613:	50                   	push   %eax
  801614:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801617:	ff 30                	pushl  (%eax)
  801619:	e8 e8 fc ff ff       	call   801306 <dev_lookup>
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 47                	js     80166c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801625:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801628:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162c:	75 21                	jne    80164f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162e:	a1 08 40 80 00       	mov    0x804008,%eax
  801633:	8b 40 48             	mov    0x48(%eax),%eax
  801636:	83 ec 04             	sub    $0x4,%esp
  801639:	53                   	push   %ebx
  80163a:	50                   	push   %eax
  80163b:	68 31 28 80 00       	push   $0x802831
  801640:	e8 ac eb ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801645:	83 c4 10             	add    $0x10,%esp
  801648:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164d:	eb 26                	jmp    801675 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801652:	8b 52 0c             	mov    0xc(%edx),%edx
  801655:	85 d2                	test   %edx,%edx
  801657:	74 17                	je     801670 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	ff 75 10             	pushl  0x10(%ebp)
  80165f:	ff 75 0c             	pushl  0xc(%ebp)
  801662:	50                   	push   %eax
  801663:	ff d2                	call   *%edx
  801665:	89 c2                	mov    %eax,%edx
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	eb 09                	jmp    801675 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	eb 05                	jmp    801675 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801670:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801675:	89 d0                	mov    %edx,%eax
  801677:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <seek>:

int
seek(int fdnum, off_t offset)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801682:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801685:	50                   	push   %eax
  801686:	ff 75 08             	pushl  0x8(%ebp)
  801689:	e8 22 fc ff ff       	call   8012b0 <fd_lookup>
  80168e:	83 c4 08             	add    $0x8,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	78 0e                	js     8016a3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801695:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801698:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	53                   	push   %ebx
  8016a9:	83 ec 14             	sub    $0x14,%esp
  8016ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b2:	50                   	push   %eax
  8016b3:	53                   	push   %ebx
  8016b4:	e8 f7 fb ff ff       	call   8012b0 <fd_lookup>
  8016b9:	83 c4 08             	add    $0x8,%esp
  8016bc:	89 c2                	mov    %eax,%edx
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 65                	js     801727 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	83 ec 08             	sub    $0x8,%esp
  8016c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c8:	50                   	push   %eax
  8016c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cc:	ff 30                	pushl  (%eax)
  8016ce:	e8 33 fc ff ff       	call   801306 <dev_lookup>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 44                	js     80171e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e1:	75 21                	jne    801704 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e3:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e8:	8b 40 48             	mov    0x48(%eax),%eax
  8016eb:	83 ec 04             	sub    $0x4,%esp
  8016ee:	53                   	push   %ebx
  8016ef:	50                   	push   %eax
  8016f0:	68 f4 27 80 00       	push   $0x8027f4
  8016f5:	e8 f7 ea ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801702:	eb 23                	jmp    801727 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801704:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801707:	8b 52 18             	mov    0x18(%edx),%edx
  80170a:	85 d2                	test   %edx,%edx
  80170c:	74 14                	je     801722 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	ff 75 0c             	pushl  0xc(%ebp)
  801714:	50                   	push   %eax
  801715:	ff d2                	call   *%edx
  801717:	89 c2                	mov    %eax,%edx
  801719:	83 c4 10             	add    $0x10,%esp
  80171c:	eb 09                	jmp    801727 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171e:	89 c2                	mov    %eax,%edx
  801720:	eb 05                	jmp    801727 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801722:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801727:	89 d0                	mov    %edx,%eax
  801729:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172c:	c9                   	leave  
  80172d:	c3                   	ret    

0080172e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	83 ec 14             	sub    $0x14,%esp
  801735:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801738:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	ff 75 08             	pushl  0x8(%ebp)
  80173f:	e8 6c fb ff ff       	call   8012b0 <fd_lookup>
  801744:	83 c4 08             	add    $0x8,%esp
  801747:	89 c2                	mov    %eax,%edx
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 58                	js     8017a5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174d:	83 ec 08             	sub    $0x8,%esp
  801750:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801753:	50                   	push   %eax
  801754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801757:	ff 30                	pushl  (%eax)
  801759:	e8 a8 fb ff ff       	call   801306 <dev_lookup>
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	85 c0                	test   %eax,%eax
  801763:	78 37                	js     80179c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801768:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176c:	74 32                	je     8017a0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801771:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801778:	00 00 00 
	stat->st_isdir = 0;
  80177b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801782:	00 00 00 
	stat->st_dev = dev;
  801785:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	53                   	push   %ebx
  80178f:	ff 75 f0             	pushl  -0x10(%ebp)
  801792:	ff 50 14             	call   *0x14(%eax)
  801795:	89 c2                	mov    %eax,%edx
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	eb 09                	jmp    8017a5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179c:	89 c2                	mov    %eax,%edx
  80179e:	eb 05                	jmp    8017a5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a5:	89 d0                	mov    %edx,%eax
  8017a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017aa:	c9                   	leave  
  8017ab:	c3                   	ret    

008017ac <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	56                   	push   %esi
  8017b0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	6a 00                	push   $0x0
  8017b6:	ff 75 08             	pushl  0x8(%ebp)
  8017b9:	e8 dc 01 00 00       	call   80199a <open>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 1b                	js     8017e2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	50                   	push   %eax
  8017ce:	e8 5b ff ff ff       	call   80172e <fstat>
  8017d3:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d5:	89 1c 24             	mov    %ebx,(%esp)
  8017d8:	e8 fd fb ff ff       	call   8013da <close>
	return r;
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	89 f0                	mov    %esi,%eax
}
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	89 c6                	mov    %eax,%esi
  8017f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f9:	75 12                	jne    80180d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	6a 01                	push   $0x1
  801800:	e8 fc f9 ff ff       	call   801201 <ipc_find_env>
  801805:	a3 00 40 80 00       	mov    %eax,0x804000
  80180a:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180d:	6a 07                	push   $0x7
  80180f:	68 00 50 80 00       	push   $0x805000
  801814:	56                   	push   %esi
  801815:	ff 35 00 40 80 00    	pushl  0x804000
  80181b:	e8 9e f9 ff ff       	call   8011be <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  801820:	83 c4 0c             	add    $0xc,%esp
  801823:	6a 00                	push   $0x0
  801825:	53                   	push   %ebx
  801826:	6a 00                	push   $0x0
  801828:	e8 34 f9 ff ff       	call   801161 <ipc_recv>
}
  80182d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801830:	5b                   	pop    %ebx
  801831:	5e                   	pop    %esi
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	8b 40 0c             	mov    0xc(%eax),%eax
  801840:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801845:	8b 45 0c             	mov    0xc(%ebp),%eax
  801848:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 02 00 00 00       	mov    $0x2,%eax
  801857:	e8 8d ff ff ff       	call   8017e9 <fsipc>
}
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801864:	8b 45 08             	mov    0x8(%ebp),%eax
  801867:	8b 40 0c             	mov    0xc(%eax),%eax
  80186a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
  801874:	b8 06 00 00 00       	mov    $0x6,%eax
  801879:	e8 6b ff ff ff       	call   8017e9 <fsipc>
}
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 04             	sub    $0x4,%esp
  801887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	8b 40 0c             	mov    0xc(%eax),%eax
  801890:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	b8 05 00 00 00       	mov    $0x5,%eax
  80189f:	e8 45 ff ff ff       	call   8017e9 <fsipc>
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 2c                	js     8018d4 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a8:	83 ec 08             	sub    $0x8,%esp
  8018ab:	68 00 50 80 00       	push   $0x805000
  8018b0:	53                   	push   %ebx
  8018b1:	e8 0a ef ff ff       	call   8007c0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8018bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d7:	c9                   	leave  
  8018d8:	c3                   	ret    

008018d9 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
  8018dc:	83 ec 0c             	sub    $0xc,%esp
  8018df:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ee:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018f3:	50                   	push   %eax
  8018f4:	ff 75 0c             	pushl  0xc(%ebp)
  8018f7:	68 08 50 80 00       	push   $0x805008
  8018fc:	e8 51 f0 ff ff       	call   800952 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	b8 04 00 00 00       	mov    $0x4,%eax
  80190b:	e8 d9 fe ff ff       	call   8017e9 <fsipc>
	//panic("devfile_write not implemented");
}
  801910:	c9                   	leave  
  801911:	c3                   	ret    

00801912 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80191a:	8b 45 08             	mov    0x8(%ebp),%eax
  80191d:	8b 40 0c             	mov    0xc(%eax),%eax
  801920:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801925:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192b:	ba 00 00 00 00       	mov    $0x0,%edx
  801930:	b8 03 00 00 00       	mov    $0x3,%eax
  801935:	e8 af fe ff ff       	call   8017e9 <fsipc>
  80193a:	89 c3                	mov    %eax,%ebx
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 51                	js     801991 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801940:	39 c6                	cmp    %eax,%esi
  801942:	73 19                	jae    80195d <devfile_read+0x4b>
  801944:	68 60 28 80 00       	push   $0x802860
  801949:	68 67 28 80 00       	push   $0x802867
  80194e:	68 80 00 00 00       	push   $0x80
  801953:	68 7c 28 80 00       	push   $0x80287c
  801958:	e8 c0 05 00 00       	call   801f1d <_panic>
	assert(r <= PGSIZE);
  80195d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801962:	7e 19                	jle    80197d <devfile_read+0x6b>
  801964:	68 87 28 80 00       	push   $0x802887
  801969:	68 67 28 80 00       	push   $0x802867
  80196e:	68 81 00 00 00       	push   $0x81
  801973:	68 7c 28 80 00       	push   $0x80287c
  801978:	e8 a0 05 00 00       	call   801f1d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80197d:	83 ec 04             	sub    $0x4,%esp
  801980:	50                   	push   %eax
  801981:	68 00 50 80 00       	push   $0x805000
  801986:	ff 75 0c             	pushl  0xc(%ebp)
  801989:	e8 c4 ef ff ff       	call   800952 <memmove>
	return r;
  80198e:	83 c4 10             	add    $0x10,%esp
}
  801991:	89 d8                	mov    %ebx,%eax
  801993:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	53                   	push   %ebx
  80199e:	83 ec 20             	sub    $0x20,%esp
  8019a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a4:	53                   	push   %ebx
  8019a5:	e8 dd ed ff ff       	call   800787 <strlen>
  8019aa:	83 c4 10             	add    $0x10,%esp
  8019ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b2:	7f 67                	jg     801a1b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b4:	83 ec 0c             	sub    $0xc,%esp
  8019b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ba:	50                   	push   %eax
  8019bb:	e8 a1 f8 ff ff       	call   801261 <fd_alloc>
  8019c0:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 57                	js     801a20 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	53                   	push   %ebx
  8019cd:	68 00 50 80 00       	push   $0x805000
  8019d2:	e8 e9 ed ff ff       	call   8007c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019da:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e7:	e8 fd fd ff ff       	call   8017e9 <fsipc>
  8019ec:	89 c3                	mov    %eax,%ebx
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	79 14                	jns    801a09 <open+0x6f>
		
		fd_close(fd, 0);
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	6a 00                	push   $0x0
  8019fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fd:	e8 57 f9 ff ff       	call   801359 <fd_close>
		return r;
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	89 da                	mov    %ebx,%edx
  801a07:	eb 17                	jmp    801a20 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0f:	e8 26 f8 ff ff       	call   80123a <fd2num>
  801a14:	89 c2                	mov    %eax,%edx
  801a16:	83 c4 10             	add    $0x10,%esp
  801a19:	eb 05                	jmp    801a20 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a1b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  801a20:	89 d0                	mov    %edx,%eax
  801a22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a32:	b8 08 00 00 00       	mov    $0x8,%eax
  801a37:	e8 ad fd ff ff       	call   8017e9 <fsipc>
}
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	56                   	push   %esi
  801a42:	53                   	push   %ebx
  801a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	ff 75 08             	pushl  0x8(%ebp)
  801a4c:	e8 f9 f7 ff ff       	call   80124a <fd2data>
  801a51:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a53:	83 c4 08             	add    $0x8,%esp
  801a56:	68 93 28 80 00       	push   $0x802893
  801a5b:	53                   	push   %ebx
  801a5c:	e8 5f ed ff ff       	call   8007c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a61:	8b 46 04             	mov    0x4(%esi),%eax
  801a64:	2b 06                	sub    (%esi),%eax
  801a66:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a73:	00 00 00 
	stat->st_dev = &devpipe;
  801a76:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a7d:	30 80 00 
	return 0;
}
  801a80:	b8 00 00 00 00       	mov    $0x0,%eax
  801a85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a88:	5b                   	pop    %ebx
  801a89:	5e                   	pop    %esi
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a96:	53                   	push   %ebx
  801a97:	6a 00                	push   $0x0
  801a99:	e8 aa f1 ff ff       	call   800c48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a9e:	89 1c 24             	mov    %ebx,(%esp)
  801aa1:	e8 a4 f7 ff ff       	call   80124a <fd2data>
  801aa6:	83 c4 08             	add    $0x8,%esp
  801aa9:	50                   	push   %eax
  801aaa:	6a 00                	push   $0x0
  801aac:	e8 97 f1 ff ff       	call   800c48 <sys_page_unmap>
}
  801ab1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab4:	c9                   	leave  
  801ab5:	c3                   	ret    

00801ab6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	57                   	push   %edi
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 1c             	sub    $0x1c,%esp
  801abf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac2:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac4:	a1 08 40 80 00       	mov    0x804008,%eax
  801ac9:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad2:	e8 15 05 00 00       	call   801fec <pageref>
  801ad7:	89 c3                	mov    %eax,%ebx
  801ad9:	89 3c 24             	mov    %edi,(%esp)
  801adc:	e8 0b 05 00 00       	call   801fec <pageref>
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	39 c3                	cmp    %eax,%ebx
  801ae6:	0f 94 c1             	sete   %cl
  801ae9:	0f b6 c9             	movzbl %cl,%ecx
  801aec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aef:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801af5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801af8:	39 ce                	cmp    %ecx,%esi
  801afa:	74 1b                	je     801b17 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801afc:	39 c3                	cmp    %eax,%ebx
  801afe:	75 c4                	jne    801ac4 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b00:	8b 42 58             	mov    0x58(%edx),%eax
  801b03:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b06:	50                   	push   %eax
  801b07:	56                   	push   %esi
  801b08:	68 9a 28 80 00       	push   $0x80289a
  801b0d:	e8 df e6 ff ff       	call   8001f1 <cprintf>
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	eb ad                	jmp    801ac4 <_pipeisclosed+0xe>
	}
}
  801b17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 28             	sub    $0x28,%esp
  801b2b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b2e:	56                   	push   %esi
  801b2f:	e8 16 f7 ff ff       	call   80124a <fd2data>
  801b34:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	bf 00 00 00 00       	mov    $0x0,%edi
  801b3e:	eb 4b                	jmp    801b8b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b40:	89 da                	mov    %ebx,%edx
  801b42:	89 f0                	mov    %esi,%eax
  801b44:	e8 6d ff ff ff       	call   801ab6 <_pipeisclosed>
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	75 48                	jne    801b95 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b4d:	e8 52 f0 ff ff       	call   800ba4 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b52:	8b 43 04             	mov    0x4(%ebx),%eax
  801b55:	8b 0b                	mov    (%ebx),%ecx
  801b57:	8d 51 20             	lea    0x20(%ecx),%edx
  801b5a:	39 d0                	cmp    %edx,%eax
  801b5c:	73 e2                	jae    801b40 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b61:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b65:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b68:	89 c2                	mov    %eax,%edx
  801b6a:	c1 fa 1f             	sar    $0x1f,%edx
  801b6d:	89 d1                	mov    %edx,%ecx
  801b6f:	c1 e9 1b             	shr    $0x1b,%ecx
  801b72:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b75:	83 e2 1f             	and    $0x1f,%edx
  801b78:	29 ca                	sub    %ecx,%edx
  801b7a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b7e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b82:	83 c0 01             	add    $0x1,%eax
  801b85:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b88:	83 c7 01             	add    $0x1,%edi
  801b8b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b8e:	75 c2                	jne    801b52 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b90:	8b 45 10             	mov    0x10(%ebp),%eax
  801b93:	eb 05                	jmp    801b9a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5f                   	pop    %edi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	57                   	push   %edi
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 18             	sub    $0x18,%esp
  801bab:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bae:	57                   	push   %edi
  801baf:	e8 96 f6 ff ff       	call   80124a <fd2data>
  801bb4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bbe:	eb 3d                	jmp    801bfd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bc0:	85 db                	test   %ebx,%ebx
  801bc2:	74 04                	je     801bc8 <devpipe_read+0x26>
				return i;
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	eb 44                	jmp    801c0c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bc8:	89 f2                	mov    %esi,%edx
  801bca:	89 f8                	mov    %edi,%eax
  801bcc:	e8 e5 fe ff ff       	call   801ab6 <_pipeisclosed>
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	75 32                	jne    801c07 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bd5:	e8 ca ef ff ff       	call   800ba4 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bda:	8b 06                	mov    (%esi),%eax
  801bdc:	3b 46 04             	cmp    0x4(%esi),%eax
  801bdf:	74 df                	je     801bc0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be1:	99                   	cltd   
  801be2:	c1 ea 1b             	shr    $0x1b,%edx
  801be5:	01 d0                	add    %edx,%eax
  801be7:	83 e0 1f             	and    $0x1f,%eax
  801bea:	29 d0                	sub    %edx,%eax
  801bec:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bf7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfa:	83 c3 01             	add    $0x1,%ebx
  801bfd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c00:	75 d8                	jne    801bda <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c02:	8b 45 10             	mov    0x10(%ebp),%eax
  801c05:	eb 05                	jmp    801c0c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0f:	5b                   	pop    %ebx
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1f:	50                   	push   %eax
  801c20:	e8 3c f6 ff ff       	call   801261 <fd_alloc>
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	89 c2                	mov    %eax,%edx
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	0f 88 2c 01 00 00    	js     801d5e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c32:	83 ec 04             	sub    $0x4,%esp
  801c35:	68 07 04 00 00       	push   $0x407
  801c3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3d:	6a 00                	push   $0x0
  801c3f:	e8 7f ef ff ff       	call   800bc3 <sys_page_alloc>
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	89 c2                	mov    %eax,%edx
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	0f 88 0d 01 00 00    	js     801d5e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c51:	83 ec 0c             	sub    $0xc,%esp
  801c54:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c57:	50                   	push   %eax
  801c58:	e8 04 f6 ff ff       	call   801261 <fd_alloc>
  801c5d:	89 c3                	mov    %eax,%ebx
  801c5f:	83 c4 10             	add    $0x10,%esp
  801c62:	85 c0                	test   %eax,%eax
  801c64:	0f 88 e2 00 00 00    	js     801d4c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	68 07 04 00 00       	push   $0x407
  801c72:	ff 75 f0             	pushl  -0x10(%ebp)
  801c75:	6a 00                	push   $0x0
  801c77:	e8 47 ef ff ff       	call   800bc3 <sys_page_alloc>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	0f 88 c3 00 00 00    	js     801d4c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c89:	83 ec 0c             	sub    $0xc,%esp
  801c8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8f:	e8 b6 f5 ff ff       	call   80124a <fd2data>
  801c94:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c96:	83 c4 0c             	add    $0xc,%esp
  801c99:	68 07 04 00 00       	push   $0x407
  801c9e:	50                   	push   %eax
  801c9f:	6a 00                	push   $0x0
  801ca1:	e8 1d ef ff ff       	call   800bc3 <sys_page_alloc>
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	83 c4 10             	add    $0x10,%esp
  801cab:	85 c0                	test   %eax,%eax
  801cad:	0f 88 89 00 00 00    	js     801d3c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb3:	83 ec 0c             	sub    $0xc,%esp
  801cb6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cb9:	e8 8c f5 ff ff       	call   80124a <fd2data>
  801cbe:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc5:	50                   	push   %eax
  801cc6:	6a 00                	push   $0x0
  801cc8:	56                   	push   %esi
  801cc9:	6a 00                	push   $0x0
  801ccb:	e8 36 ef ff ff       	call   800c06 <sys_page_map>
  801cd0:	89 c3                	mov    %eax,%ebx
  801cd2:	83 c4 20             	add    $0x20,%esp
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 55                	js     801d2e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cd9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cf7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d03:	83 ec 0c             	sub    $0xc,%esp
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	e8 2c f5 ff ff       	call   80123a <fd2num>
  801d0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d11:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d13:	83 c4 04             	add    $0x4,%esp
  801d16:	ff 75 f0             	pushl  -0x10(%ebp)
  801d19:	e8 1c f5 ff ff       	call   80123a <fd2num>
  801d1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d21:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2c:	eb 30                	jmp    801d5e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	56                   	push   %esi
  801d32:	6a 00                	push   $0x0
  801d34:	e8 0f ef ff ff       	call   800c48 <sys_page_unmap>
  801d39:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d3c:	83 ec 08             	sub    $0x8,%esp
  801d3f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d42:	6a 00                	push   $0x0
  801d44:	e8 ff ee ff ff       	call   800c48 <sys_page_unmap>
  801d49:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d4c:	83 ec 08             	sub    $0x8,%esp
  801d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d52:	6a 00                	push   $0x0
  801d54:	e8 ef ee ff ff       	call   800c48 <sys_page_unmap>
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d5e:	89 d0                	mov    %edx,%eax
  801d60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d70:	50                   	push   %eax
  801d71:	ff 75 08             	pushl  0x8(%ebp)
  801d74:	e8 37 f5 ff ff       	call   8012b0 <fd_lookup>
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	78 18                	js     801d98 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d80:	83 ec 0c             	sub    $0xc,%esp
  801d83:	ff 75 f4             	pushl  -0xc(%ebp)
  801d86:	e8 bf f4 ff ff       	call   80124a <fd2data>
	return _pipeisclosed(fd, p);
  801d8b:	89 c2                	mov    %eax,%edx
  801d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d90:	e8 21 fd ff ff       	call   801ab6 <_pipeisclosed>
  801d95:	83 c4 10             	add    $0x10,%esp
}
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9a:	55                   	push   %ebp
  801d9b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801daa:	68 b2 28 80 00       	push   $0x8028b2
  801daf:	ff 75 0c             	pushl  0xc(%ebp)
  801db2:	e8 09 ea ff ff       	call   8007c0 <strcpy>
	return 0;
}
  801db7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbc:	c9                   	leave  
  801dbd:	c3                   	ret    

00801dbe <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dca:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dcf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd5:	eb 2d                	jmp    801e04 <devcons_write+0x46>
		m = n - tot;
  801dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dda:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ddc:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ddf:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801de4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	53                   	push   %ebx
  801deb:	03 45 0c             	add    0xc(%ebp),%eax
  801dee:	50                   	push   %eax
  801def:	57                   	push   %edi
  801df0:	e8 5d eb ff ff       	call   800952 <memmove>
		sys_cputs(buf, m);
  801df5:	83 c4 08             	add    $0x8,%esp
  801df8:	53                   	push   %ebx
  801df9:	57                   	push   %edi
  801dfa:	e8 08 ed ff ff       	call   800b07 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dff:	01 de                	add    %ebx,%esi
  801e01:	83 c4 10             	add    $0x10,%esp
  801e04:	89 f0                	mov    %esi,%eax
  801e06:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e09:	72 cc                	jb     801dd7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5e                   	pop    %esi
  801e10:	5f                   	pop    %edi
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    

00801e13 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e1e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e22:	74 2a                	je     801e4e <devcons_read+0x3b>
  801e24:	eb 05                	jmp    801e2b <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e26:	e8 79 ed ff ff       	call   800ba4 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2b:	e8 f5 ec ff ff       	call   800b25 <sys_cgetc>
  801e30:	85 c0                	test   %eax,%eax
  801e32:	74 f2                	je     801e26 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e34:	85 c0                	test   %eax,%eax
  801e36:	78 16                	js     801e4e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e38:	83 f8 04             	cmp    $0x4,%eax
  801e3b:	74 0c                	je     801e49 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e40:	88 02                	mov    %al,(%edx)
	return 1;
  801e42:	b8 01 00 00 00       	mov    $0x1,%eax
  801e47:	eb 05                	jmp    801e4e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e4e:	c9                   	leave  
  801e4f:	c3                   	ret    

00801e50 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e50:	55                   	push   %ebp
  801e51:	89 e5                	mov    %esp,%ebp
  801e53:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e56:	8b 45 08             	mov    0x8(%ebp),%eax
  801e59:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e5c:	6a 01                	push   $0x1
  801e5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e61:	50                   	push   %eax
  801e62:	e8 a0 ec ff ff       	call   800b07 <sys_cputs>
}
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <getchar>:

int
getchar(void)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e72:	6a 01                	push   $0x1
  801e74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e77:	50                   	push   %eax
  801e78:	6a 00                	push   $0x0
  801e7a:	e8 97 f6 ff ff       	call   801516 <read>
	if (r < 0)
  801e7f:	83 c4 10             	add    $0x10,%esp
  801e82:	85 c0                	test   %eax,%eax
  801e84:	78 0f                	js     801e95 <getchar+0x29>
		return r;
	if (r < 1)
  801e86:	85 c0                	test   %eax,%eax
  801e88:	7e 06                	jle    801e90 <getchar+0x24>
		return -E_EOF;
	return c;
  801e8a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e8e:	eb 05                	jmp    801e95 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e90:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    

00801e97 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea0:	50                   	push   %eax
  801ea1:	ff 75 08             	pushl  0x8(%ebp)
  801ea4:	e8 07 f4 ff ff       	call   8012b0 <fd_lookup>
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	85 c0                	test   %eax,%eax
  801eae:	78 11                	js     801ec1 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eb9:	39 10                	cmp    %edx,(%eax)
  801ebb:	0f 94 c0             	sete   %al
  801ebe:	0f b6 c0             	movzbl %al,%eax
}
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    

00801ec3 <opencons>:

int
opencons(void)
{
  801ec3:	55                   	push   %ebp
  801ec4:	89 e5                	mov    %esp,%ebp
  801ec6:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ec9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecc:	50                   	push   %eax
  801ecd:	e8 8f f3 ff ff       	call   801261 <fd_alloc>
  801ed2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed5:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ed7:	85 c0                	test   %eax,%eax
  801ed9:	78 3e                	js     801f19 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801edb:	83 ec 04             	sub    $0x4,%esp
  801ede:	68 07 04 00 00       	push   $0x407
  801ee3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 d6 ec ff ff       	call   800bc3 <sys_page_alloc>
  801eed:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 23                	js     801f19 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ef6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f04:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	50                   	push   %eax
  801f0f:	e8 26 f3 ff ff       	call   80123a <fd2num>
  801f14:	89 c2                	mov    %eax,%edx
  801f16:	83 c4 10             	add    $0x10,%esp
}
  801f19:	89 d0                	mov    %edx,%eax
  801f1b:	c9                   	leave  
  801f1c:	c3                   	ret    

00801f1d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	56                   	push   %esi
  801f21:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f22:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f25:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f2b:	e8 55 ec ff ff       	call   800b85 <sys_getenvid>
  801f30:	83 ec 0c             	sub    $0xc,%esp
  801f33:	ff 75 0c             	pushl  0xc(%ebp)
  801f36:	ff 75 08             	pushl  0x8(%ebp)
  801f39:	56                   	push   %esi
  801f3a:	50                   	push   %eax
  801f3b:	68 c0 28 80 00       	push   $0x8028c0
  801f40:	e8 ac e2 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f45:	83 c4 18             	add    $0x18,%esp
  801f48:	53                   	push   %ebx
  801f49:	ff 75 10             	pushl  0x10(%ebp)
  801f4c:	e8 4f e2 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801f51:	c7 04 24 23 27 80 00 	movl   $0x802723,(%esp)
  801f58:	e8 94 e2 ff ff       	call   8001f1 <cprintf>
  801f5d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f60:	cc                   	int3   
  801f61:	eb fd                	jmp    801f60 <_panic+0x43>

00801f63 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801f69:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f70:	75 4c                	jne    801fbe <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801f72:	a1 08 40 80 00       	mov    0x804008,%eax
  801f77:	8b 40 48             	mov    0x48(%eax),%eax
  801f7a:	83 ec 04             	sub    $0x4,%esp
  801f7d:	6a 07                	push   $0x7
  801f7f:	68 00 f0 bf ee       	push   $0xeebff000
  801f84:	50                   	push   %eax
  801f85:	e8 39 ec ff ff       	call   800bc3 <sys_page_alloc>
		if(retv != 0){
  801f8a:	83 c4 10             	add    $0x10,%esp
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	74 14                	je     801fa5 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801f91:	83 ec 04             	sub    $0x4,%esp
  801f94:	68 e4 28 80 00       	push   $0x8028e4
  801f99:	6a 27                	push   $0x27
  801f9b:	68 10 29 80 00       	push   $0x802910
  801fa0:	e8 78 ff ff ff       	call   801f1d <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801fa5:	a1 08 40 80 00       	mov    0x804008,%eax
  801faa:	8b 40 48             	mov    0x48(%eax),%eax
  801fad:	83 ec 08             	sub    $0x8,%esp
  801fb0:	68 c8 1f 80 00       	push   $0x801fc8
  801fb5:	50                   	push   %eax
  801fb6:	e8 53 ed ff ff       	call   800d0e <sys_env_set_pgfault_upcall>
  801fbb:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc1:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fc8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fc9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fce:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801fd0:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801fd3:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801fd7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  801fdc:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801fe0:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801fe2:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801fe5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801fe6:	83 c4 04             	add    $0x4,%esp
	popfl
  801fe9:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fea:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801feb:	c3                   	ret    

00801fec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	c1 e8 16             	shr    $0x16,%eax
  801ff7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802003:	f6 c1 01             	test   $0x1,%cl
  802006:	74 1d                	je     802025 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802008:	c1 ea 0c             	shr    $0xc,%edx
  80200b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802012:	f6 c2 01             	test   $0x1,%dl
  802015:	74 0e                	je     802025 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802017:	c1 ea 0c             	shr    $0xc,%edx
  80201a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802021:	ef 
  802022:	0f b7 c0             	movzwl %ax,%eax
}
  802025:	5d                   	pop    %ebp
  802026:	c3                   	ret    
  802027:	66 90                	xchg   %ax,%ax
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
