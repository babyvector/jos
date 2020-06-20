
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 eb 0e 00 00       	call   800f2c <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 f6 0a 00 00       	call   800b45 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 80 22 80 00       	push   $0x802280
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 12 11 00 00       	call   80117e <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 a2 10 00 00       	call   801121 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 bc 0a 00 00       	call   800b45 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 96 22 80 00       	push   $0x802296
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 d0 10 00 00       	call   80117e <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 77 0a 00 00       	call   800b45 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 b6 12 00 00       	call   8013c5 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 eb 09 00 00       	call   800b04 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 79 09 00 00       	call   800ac7 <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 54 01 00 00       	call   8002e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 1e 09 00 00       	call   800ac7 <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 d7 1d 00 00       	call   801ff0 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 c4 1e 00 00       	call   802120 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 b3 22 80 00 	movsbl 0x8022b3(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800277:	83 fa 01             	cmp    $0x1,%edx
  80027a:	7e 0e                	jle    80028a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027c:	8b 10                	mov    (%eax),%edx
  80027e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800281:	89 08                	mov    %ecx,(%eax)
  800283:	8b 02                	mov    (%edx),%eax
  800285:	8b 52 04             	mov    0x4(%edx),%edx
  800288:	eb 22                	jmp    8002ac <getuint+0x38>
	else if (lflag)
  80028a:	85 d2                	test   %edx,%edx
  80028c:	74 10                	je     80029e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 04             	lea    0x4(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	ba 00 00 00 00       	mov    $0x0,%edx
  80029c:	eb 0e                	jmp    8002ac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b8:	8b 10                	mov    (%eax),%edx
  8002ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bd:	73 0a                	jae    8002c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c7:	88 02                	mov    %al,(%edx)
}
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 05 00 00 00       	call   8002e8 <vprintfmt>
	va_end(ap);
}
  8002e3:	83 c4 10             	add    $0x10,%esp
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 2c             	sub    $0x2c,%esp
  8002f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fa:	eb 12                	jmp    80030e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 84 d3 03 00 00    	je     8006d7 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  800304:	83 ec 08             	sub    $0x8,%esp
  800307:	53                   	push   %ebx
  800308:	50                   	push   %eax
  800309:	ff d6                	call   *%esi
  80030b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030e:	83 c7 01             	add    $0x1,%edi
  800311:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800315:	83 f8 25             	cmp    $0x25,%eax
  800318:	75 e2                	jne    8002fc <vprintfmt+0x14>
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800325:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800333:	ba 00 00 00 00       	mov    $0x0,%edx
  800338:	eb 07                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 07             	movzbl (%edi),%eax
  80034a:	0f b6 c8             	movzbl %al,%ecx
  80034d:	83 e8 23             	sub    $0x23,%eax
  800350:	3c 55                	cmp    $0x55,%al
  800352:	0f 87 64 03 00 00    	ja     8006bc <vprintfmt+0x3d4>
  800358:	0f b6 c0             	movzbl %al,%eax
  80035b:	ff 24 85 00 24 80 00 	jmp    *0x802400(,%eax,4)
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800365:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800369:	eb d6                	jmp    800341 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800380:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800383:	83 fa 09             	cmp    $0x9,%edx
  800386:	77 39                	ja     8003c1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 48 04             	lea    0x4(%eax),%ecx
  800393:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80039e:	eb 27                	jmp    8003c7 <vprintfmt+0xdf>
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003aa:	0f 49 c8             	cmovns %eax,%ecx
  8003ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b3:	eb 8c                	jmp    800341 <vprintfmt+0x59>
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003bf:	eb 80                	jmp    800341 <vprintfmt+0x59>
  8003c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c4:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cb:	0f 89 70 ff ff ff    	jns    800341 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d7:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003de:	e9 5e ff ff ff       	jmp    800341 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e9:	e9 53 ff ff ff       	jmp    800341 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8d 50 04             	lea    0x4(%eax),%edx
  8003f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	53                   	push   %ebx
  8003fb:	ff 30                	pushl  (%eax)
  8003fd:	ff d6                	call   *%esi
			break;
  8003ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800405:	e9 04 ff ff ff       	jmp    80030e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040a:	8b 45 14             	mov    0x14(%ebp),%eax
  80040d:	8d 50 04             	lea    0x4(%eax),%edx
  800410:	89 55 14             	mov    %edx,0x14(%ebp)
  800413:	8b 00                	mov    (%eax),%eax
  800415:	99                   	cltd   
  800416:	31 d0                	xor    %edx,%eax
  800418:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041a:	83 f8 0f             	cmp    $0xf,%eax
  80041d:	7f 0b                	jg     80042a <vprintfmt+0x142>
  80041f:	8b 14 85 60 25 80 00 	mov    0x802560(,%eax,4),%edx
  800426:	85 d2                	test   %edx,%edx
  800428:	75 18                	jne    800442 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042a:	50                   	push   %eax
  80042b:	68 cb 22 80 00       	push   $0x8022cb
  800430:	53                   	push   %ebx
  800431:	56                   	push   %esi
  800432:	e8 94 fe ff ff       	call   8002cb <printfmt>
  800437:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043d:	e9 cc fe ff ff       	jmp    80030e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800442:	52                   	push   %edx
  800443:	68 19 28 80 00       	push   $0x802819
  800448:	53                   	push   %ebx
  800449:	56                   	push   %esi
  80044a:	e8 7c fe ff ff       	call   8002cb <printfmt>
  80044f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 b4 fe ff ff       	jmp    80030e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800465:	85 ff                	test   %edi,%edi
  800467:	b8 c4 22 80 00       	mov    $0x8022c4,%eax
  80046c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800473:	0f 8e 94 00 00 00    	jle    80050d <vprintfmt+0x225>
  800479:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047d:	0f 84 98 00 00 00    	je     80051b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 c8             	pushl  -0x38(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 d0 02 00 00       	call   80075f <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1c0>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 4d                	jmp    800527 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	74 1b                	je     8004fb <vprintfmt+0x213>
  8004e0:	0f be c0             	movsbl %al,%eax
  8004e3:	83 e8 20             	sub    $0x20,%eax
  8004e6:	83 f8 5e             	cmp    $0x5e,%eax
  8004e9:	76 10                	jbe    8004fb <vprintfmt+0x213>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb 0d                	jmp    800508 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	52                   	push   %edx
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800508:	83 eb 01             	sub    $0x1,%ebx
  80050b:	eb 1a                	jmp    800527 <vprintfmt+0x23f>
  80050d:	89 75 08             	mov    %esi,0x8(%ebp)
  800510:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800513:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800516:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800519:	eb 0c                	jmp    800527 <vprintfmt+0x23f>
  80051b:	89 75 08             	mov    %esi,0x8(%ebp)
  80051e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800521:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800527:	83 c7 01             	add    $0x1,%edi
  80052a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052e:	0f be d0             	movsbl %al,%edx
  800531:	85 d2                	test   %edx,%edx
  800533:	74 23                	je     800558 <vprintfmt+0x270>
  800535:	85 f6                	test   %esi,%esi
  800537:	78 a1                	js     8004da <vprintfmt+0x1f2>
  800539:	83 ee 01             	sub    $0x1,%esi
  80053c:	79 9c                	jns    8004da <vprintfmt+0x1f2>
  80053e:	89 df                	mov    %ebx,%edi
  800540:	8b 75 08             	mov    0x8(%ebp),%esi
  800543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800546:	eb 18                	jmp    800560 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 20                	push   $0x20
  80054e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800550:	83 ef 01             	sub    $0x1,%edi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 08                	jmp    800560 <vprintfmt+0x278>
  800558:	89 df                	mov    %ebx,%edi
  80055a:	8b 75 08             	mov    0x8(%ebp),%esi
  80055d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800560:	85 ff                	test   %edi,%edi
  800562:	7f e4                	jg     800548 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800567:	e9 a2 fd ff ff       	jmp    80030e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056c:	83 fa 01             	cmp    $0x1,%edx
  80056f:	7e 16                	jle    800587 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 08             	lea    0x8(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800582:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800585:	eb 32                	jmp    8005b9 <vprintfmt+0x2d1>
	else if (lflag)
  800587:	85 d2                	test   %edx,%edx
  800589:	74 18                	je     8005a3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 50 04             	lea    0x4(%eax),%edx
  800591:	89 55 14             	mov    %edx,0x14(%ebp)
  800594:	8b 00                	mov    (%eax),%eax
  800596:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800599:	89 c1                	mov    %eax,%ecx
  80059b:	c1 f9 1f             	sar    $0x1f,%ecx
  80059e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a1:	eb 16                	jmp    8005b9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ca:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005ce:	0f 89 b0 00 00 00    	jns    800684 <vprintfmt+0x39c>
				putch('-', putdat);
  8005d4:	83 ec 08             	sub    $0x8,%esp
  8005d7:	53                   	push   %ebx
  8005d8:	6a 2d                	push   $0x2d
  8005da:	ff d6                	call   *%esi
				num = -(long long) num;
  8005dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005df:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e2:	f7 d8                	neg    %eax
  8005e4:	83 d2 00             	adc    $0x0,%edx
  8005e7:	f7 da                	neg    %edx
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ef:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 88 00 00 00       	jmp    800684 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ff:	e8 70 fc ff ff       	call   800274 <getuint>
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80060a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80060f:	eb 73                	jmp    800684 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800611:	8d 45 14             	lea    0x14(%ebp),%eax
  800614:	e8 5b fc ff ff       	call   800274 <getuint>
  800619:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 58                	push   $0x58
  800625:	ff d6                	call   *%esi
			putch('X', putdat);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 58                	push   $0x58
  80062d:	ff d6                	call   *%esi
			putch('X', putdat);
  80062f:	83 c4 08             	add    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 58                	push   $0x58
  800635:	ff d6                	call   *%esi
			goto number;
  800637:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  80063a:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80063f:	eb 43                	jmp    800684 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 30                	push   $0x30
  800647:	ff d6                	call   *%esi
			putch('x', putdat);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 78                	push   $0x78
  80064f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 04             	lea    0x4(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	ba 00 00 00 00       	mov    $0x0,%edx
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800667:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80066a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80066f:	eb 13                	jmp    800684 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 fb fb ff ff       	call   800274 <getuint>
  800679:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80067f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800684:	83 ec 0c             	sub    $0xc,%esp
  800687:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80068b:	52                   	push   %edx
  80068c:	ff 75 e0             	pushl  -0x20(%ebp)
  80068f:	50                   	push   %eax
  800690:	ff 75 dc             	pushl  -0x24(%ebp)
  800693:	ff 75 d8             	pushl  -0x28(%ebp)
  800696:	89 da                	mov    %ebx,%edx
  800698:	89 f0                	mov    %esi,%eax
  80069a:	e8 26 fb ff ff       	call   8001c5 <printnum>
			break;
  80069f:	83 c4 20             	add    $0x20,%esp
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a5:	e9 64 fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	51                   	push   %ecx
  8006af:	ff d6                	call   *%esi
			break;
  8006b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b7:	e9 52 fc ff ff       	jmp    80030e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb 03                	jmp    8006cc <vprintfmt+0x3e4>
  8006c9:	83 ef 01             	sub    $0x1,%edi
  8006cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d0:	75 f7                	jne    8006c9 <vprintfmt+0x3e1>
  8006d2:	e9 37 fc ff ff       	jmp    80030e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006da:	5b                   	pop    %ebx
  8006db:	5e                   	pop    %esi
  8006dc:	5f                   	pop    %edi
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 18             	sub    $0x18,%esp
  8006e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 26                	je     800726 <vsnprintf+0x47>
  800700:	85 d2                	test   %edx,%edx
  800702:	7e 22                	jle    800726 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800704:	ff 75 14             	pushl  0x14(%ebp)
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	68 ae 02 80 00       	push   $0x8002ae
  800713:	e8 d0 fb ff ff       	call   8002e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 05                	jmp    80072b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800736:	50                   	push   %eax
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	ff 75 08             	pushl  0x8(%ebp)
  800740:	e8 9a ff ff ff       	call   8006df <vsnprintf>
	va_end(ap);

	return rc;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	eb 03                	jmp    800757 <strlen+0x10>
		n++;
  800754:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800757:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075b:	75 f7                	jne    800754 <strlen+0xd>
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	ba 00 00 00 00       	mov    $0x0,%edx
  80076d:	eb 03                	jmp    800772 <strnlen+0x13>
		n++;
  80076f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800772:	39 c2                	cmp    %eax,%edx
  800774:	74 08                	je     80077e <strnlen+0x1f>
  800776:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077a:	75 f3                	jne    80076f <strnlen+0x10>
  80077c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078a:	89 c2                	mov    %eax,%edx
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	83 c1 01             	add    $0x1,%ecx
  800792:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800796:	88 5a ff             	mov    %bl,-0x1(%edx)
  800799:	84 db                	test   %bl,%bl
  80079b:	75 ef                	jne    80078c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a7:	53                   	push   %ebx
  8007a8:	e8 9a ff ff ff       	call   800747 <strlen>
  8007ad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b0:	ff 75 0c             	pushl  0xc(%ebp)
  8007b3:	01 d8                	add    %ebx,%eax
  8007b5:	50                   	push   %eax
  8007b6:	e8 c5 ff ff ff       	call   800780 <strcpy>
	return dst;
}
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	89 f3                	mov    %esi,%ebx
  8007cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 0f                	jmp    8007e5 <strncpy+0x23>
		*dst++ = *src;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	0f b6 01             	movzbl (%ecx),%eax
  8007dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007df:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	39 da                	cmp    %ebx,%edx
  8007e7:	75 ed                	jne    8007d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ff:	85 d2                	test   %edx,%edx
  800801:	74 21                	je     800824 <strlcpy+0x35>
  800803:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 09                	jmp    800814 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800814:	39 c2                	cmp    %eax,%edx
  800816:	74 09                	je     800821 <strlcpy+0x32>
  800818:	0f b6 19             	movzbl (%ecx),%ebx
  80081b:	84 db                	test   %bl,%bl
  80081d:	75 ec                	jne    80080b <strlcpy+0x1c>
  80081f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800824:	29 f0                	sub    %esi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800833:	eb 06                	jmp    80083b <strcmp+0x11>
		p++, q++;
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083b:	0f b6 01             	movzbl (%ecx),%eax
  80083e:	84 c0                	test   %al,%al
  800840:	74 04                	je     800846 <strcmp+0x1c>
  800842:	3a 02                	cmp    (%edx),%al
  800844:	74 ef                	je     800835 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strncmp+0x17>
		n--, p++, q++;
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 15                	je     800880 <strncmp+0x30>
  80086b:	0f b6 08             	movzbl (%eax),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	74 04                	je     800876 <strncmp+0x26>
  800872:	3a 0a                	cmp    (%edx),%cl
  800874:	74 eb                	je     800861 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 00             	movzbl (%eax),%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
  80087e:	eb 05                	jmp    800885 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	eb 07                	jmp    80089b <strchr+0x13>
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 0f                	je     8008a7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	0f b6 10             	movzbl (%eax),%edx
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	75 f2                	jne    800894 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b3:	eb 03                	jmp    8008b8 <strfind+0xf>
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 04                	je     8008c3 <strfind+0x1a>
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f2                	jne    8008b5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	74 36                	je     80090b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 28                	jne    800905 <memset+0x40>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 23                	jne    800905 <memset+0x40>
		c &= 0xFF;
  8008e2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e6:	89 d3                	mov    %edx,%ebx
  8008e8:	c1 e3 08             	shl    $0x8,%ebx
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	c1 e6 18             	shl    $0x18,%esi
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	c1 e0 10             	shl    $0x10,%eax
  8008f5:	09 f0                	or     %esi,%eax
  8008f7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f9:	89 d8                	mov    %ebx,%eax
  8008fb:	09 d0                	or     %edx,%eax
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 06                	jmp    80090b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	fc                   	cld    
  800909:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800920:	39 c6                	cmp    %eax,%esi
  800922:	73 35                	jae    800959 <memmove+0x47>
  800924:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800927:	39 d0                	cmp    %edx,%eax
  800929:	73 2e                	jae    800959 <memmove+0x47>
		s += n;
		d += n;
  80092b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 d6                	mov    %edx,%esi
  800930:	09 fe                	or     %edi,%esi
  800932:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800938:	75 13                	jne    80094d <memmove+0x3b>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 0e                	jne    80094d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093f:	83 ef 04             	sub    $0x4,%edi
  800942:	8d 72 fc             	lea    -0x4(%edx),%esi
  800945:	c1 e9 02             	shr    $0x2,%ecx
  800948:	fd                   	std    
  800949:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094b:	eb 09                	jmp    800956 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094d:	83 ef 01             	sub    $0x1,%edi
  800950:	8d 72 ff             	lea    -0x1(%edx),%esi
  800953:	fd                   	std    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800956:	fc                   	cld    
  800957:	eb 1d                	jmp    800976 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 f2                	mov    %esi,%edx
  80095b:	09 c2                	or     %eax,%edx
  80095d:	f6 c2 03             	test   $0x3,%dl
  800960:	75 0f                	jne    800971 <memmove+0x5f>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0a                	jne    800971 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800967:	c1 e9 02             	shr    $0x2,%ecx
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096f:	eb 05                	jmp    800976 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097d:	ff 75 10             	pushl  0x10(%ebp)
  800980:	ff 75 0c             	pushl  0xc(%ebp)
  800983:	ff 75 08             	pushl  0x8(%ebp)
  800986:	e8 87 ff ff ff       	call   800912 <memmove>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
  800998:	89 c6                	mov    %eax,%esi
  80099a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099d:	eb 1a                	jmp    8009b9 <memcmp+0x2c>
		if (*s1 != *s2)
  80099f:	0f b6 08             	movzbl (%eax),%ecx
  8009a2:	0f b6 1a             	movzbl (%edx),%ebx
  8009a5:	38 d9                	cmp    %bl,%cl
  8009a7:	74 0a                	je     8009b3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a9:	0f b6 c1             	movzbl %cl,%eax
  8009ac:	0f b6 db             	movzbl %bl,%ebx
  8009af:	29 d8                	sub    %ebx,%eax
  8009b1:	eb 0f                	jmp    8009c2 <memcmp+0x35>
		s1++, s2++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b9:	39 f0                	cmp    %esi,%eax
  8009bb:	75 e2                	jne    80099f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009cd:	89 c1                	mov    %eax,%ecx
  8009cf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	eb 0a                	jmp    8009e2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d8:	0f b6 10             	movzbl (%eax),%edx
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	74 07                	je     8009e6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	39 c8                	cmp    %ecx,%eax
  8009e4:	72 f2                	jb     8009d8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f5:	eb 03                	jmp    8009fa <strtol+0x11>
		s++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	0f b6 01             	movzbl (%ecx),%eax
  8009fd:	3c 20                	cmp    $0x20,%al
  8009ff:	74 f6                	je     8009f7 <strtol+0xe>
  800a01:	3c 09                	cmp    $0x9,%al
  800a03:	74 f2                	je     8009f7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a05:	3c 2b                	cmp    $0x2b,%al
  800a07:	75 0a                	jne    800a13 <strtol+0x2a>
		s++;
  800a09:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a11:	eb 11                	jmp    800a24 <strtol+0x3b>
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a18:	3c 2d                	cmp    $0x2d,%al
  800a1a:	75 08                	jne    800a24 <strtol+0x3b>
		s++, neg = 1;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2a:	75 15                	jne    800a41 <strtol+0x58>
  800a2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2f:	75 10                	jne    800a41 <strtol+0x58>
  800a31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a35:	75 7c                	jne    800ab3 <strtol+0xca>
		s += 2, base = 16;
  800a37:	83 c1 02             	add    $0x2,%ecx
  800a3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3f:	eb 16                	jmp    800a57 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	75 12                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4d:	75 08                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5f:	0f b6 11             	movzbl (%ecx),%edx
  800a62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 09             	cmp    $0x9,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0x8b>
			dig = *s - '0';
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 30             	sub    $0x30,%edx
  800a72:	eb 22                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 57             	sub    $0x57,%edx
  800a84:	eb 10                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 16                	ja     800aa6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 0b                	jge    800aa6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa4:	eb b9                	jmp    800a5f <strtol+0x76>

	if (endptr)
  800aa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaa:	74 0d                	je     800ab9 <strtol+0xd0>
		*endptr = (char *) s;
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	89 0e                	mov    %ecx,(%esi)
  800ab1:	eb 06                	jmp    800ab9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	74 98                	je     800a4f <strtol+0x66>
  800ab7:	eb 9e                	jmp    800a57 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	f7 da                	neg    %edx
  800abd:	85 ff                	test   %edi,%edi
  800abf:	0f 45 c2             	cmovne %edx,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	89 c6                	mov    %eax,%esi
  800ade:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	b8 03 00 00 00       	mov    $0x3,%eax
  800b17:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1a:	89 cb                	mov    %ecx,%ebx
  800b1c:	89 cf                	mov    %ecx,%edi
  800b1e:	89 ce                	mov    %ecx,%esi
  800b20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b22:	85 c0                	test   %eax,%eax
  800b24:	7e 17                	jle    800b3d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	50                   	push   %eax
  800b2a:	6a 03                	push   $0x3
  800b2c:	68 bf 25 80 00       	push   $0x8025bf
  800b31:	6a 23                	push   $0x23
  800b33:	68 dc 25 80 00       	push   $0x8025dc
  800b38:	e8 a0 13 00 00       	call   801edd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 02 00 00 00       	mov    $0x2,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_yield>:

void
sys_yield(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b8c:	be 00 00 00 00       	mov    $0x0,%esi
  800b91:	b8 04 00 00 00       	mov    $0x4,%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	89 f7                	mov    %esi,%edi
  800ba1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 17                	jle    800bbe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 04                	push   $0x4
  800bad:	68 bf 25 80 00       	push   $0x8025bf
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 dc 25 80 00       	push   $0x8025dc
  800bb9:	e8 1f 13 00 00       	call   801edd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bcf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be0:	8b 75 18             	mov    0x18(%ebp),%esi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 05                	push   $0x5
  800bef:	68 bf 25 80 00       	push   $0x8025bf
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 dc 25 80 00       	push   $0x8025dc
  800bfb:	e8 dd 12 00 00       	call   801edd <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 06                	push   $0x6
  800c31:	68 bf 25 80 00       	push   $0x8025bf
  800c36:	6a 23                	push   $0x23
  800c38:	68 dc 25 80 00       	push   $0x8025dc
  800c3d:	e8 9b 12 00 00       	call   801edd <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 08                	push   $0x8
  800c73:	68 bf 25 80 00       	push   $0x8025bf
  800c78:	6a 23                	push   $0x23
  800c7a:	68 dc 25 80 00       	push   $0x8025dc
  800c7f:	e8 59 12 00 00       	call   801edd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 09                	push   $0x9
  800cb5:	68 bf 25 80 00       	push   $0x8025bf
  800cba:	6a 23                	push   $0x23
  800cbc:	68 dc 25 80 00       	push   $0x8025dc
  800cc1:	e8 17 12 00 00       	call   801edd <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cd7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce7:	89 df                	mov    %ebx,%edi
  800ce9:	89 de                	mov    %ebx,%esi
  800ceb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ced:	85 c0                	test   %eax,%eax
  800cef:	7e 17                	jle    800d08 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf1:	83 ec 0c             	sub    $0xc,%esp
  800cf4:	50                   	push   %eax
  800cf5:	6a 0a                	push   $0xa
  800cf7:	68 bf 25 80 00       	push   $0x8025bf
  800cfc:	6a 23                	push   $0x23
  800cfe:	68 dc 25 80 00       	push   $0x8025dc
  800d03:	e8 d5 11 00 00       	call   801edd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d16:	be 00 00 00 00       	mov    $0x0,%esi
  800d1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	8b 55 08             	mov    0x8(%ebp),%edx
  800d26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	57                   	push   %edi
  800d37:	56                   	push   %esi
  800d38:	53                   	push   %ebx
  800d39:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d41:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	89 cb                	mov    %ecx,%ebx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	89 ce                	mov    %ecx,%esi
  800d4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d51:	85 c0                	test   %eax,%eax
  800d53:	7e 17                	jle    800d6c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 0d                	push   $0xd
  800d5b:	68 bf 25 80 00       	push   $0x8025bf
  800d60:	6a 23                	push   $0x23
  800d62:	68 dc 25 80 00       	push   $0x8025dc
  800d67:	e8 71 11 00 00       	call   801edd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d7c:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800d7e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d82:	74 11                	je     800d95 <pgfault+0x21>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800d84:	89 d8                	mov    %ebx,%eax
  800d86:	c1 e8 0c             	shr    $0xc,%eax
  800d89:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//cprintf("err&FEC_WR:%d,uvpd[PDX(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_P:%d,uvpt[PGNUM(addr)]&PTE_COW:%d\n",err&FEC_WR,uvpd[PDX(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_P,uvpt[PGNUM(addr)]&PTE_COW);
	if(!(
  800d90:	f6 c4 08             	test   $0x8,%ah
  800d93:	75 14                	jne    800da9 <pgfault+0x35>
		(err&FEC_WR)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	68 ea 25 80 00       	push   $0x8025ea
  800d9d:	6a 21                	push   $0x21
  800d9f:	68 00 26 80 00       	push   $0x802600
  800da4:	e8 34 11 00 00       	call   801edd <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800da9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800daf:	e8 91 fd ff ff       	call   800b45 <sys_getenvid>
  800db4:	89 c6                	mov    %eax,%esi
	if(sys_page_alloc(envid, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	6a 07                	push   $0x7
  800dbb:	68 00 f0 7f 00       	push   $0x7ff000
  800dc0:	50                   	push   %eax
  800dc1:	e8 bd fd ff ff       	call   800b83 <sys_page_alloc>
  800dc6:	83 c4 10             	add    $0x10,%esp
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	79 14                	jns    800de1 <pgfault+0x6d>
		panic("sys_page_alloc");
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	68 0b 26 80 00       	push   $0x80260b
  800dd5:	6a 30                	push   $0x30
  800dd7:	68 00 26 80 00       	push   $0x802600
  800ddc:	e8 fc 10 00 00       	call   801edd <_panic>
	}
	memcpy(PFTEMP, ROUNDDOWN(addr,PGSIZE), PGSIZE);
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	68 00 10 00 00       	push   $0x1000
  800de9:	53                   	push   %ebx
  800dea:	68 00 f0 7f 00       	push   $0x7ff000
  800def:	e8 86 fb ff ff       	call   80097a <memcpy>
	retv = sys_page_unmap(envid, addr);
  800df4:	83 c4 08             	add    $0x8,%esp
  800df7:	53                   	push   %ebx
  800df8:	56                   	push   %esi
  800df9:	e8 0a fe ff ff       	call   800c08 <sys_page_unmap>
	if(retv < 0){
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	85 c0                	test   %eax,%eax
  800e03:	79 12                	jns    800e17 <pgfault+0xa3>
		panic("pgfault:page unmapping failed : %e",retv);
  800e05:	50                   	push   %eax
  800e06:	68 f8 26 80 00       	push   $0x8026f8
  800e0b:	6a 35                	push   $0x35
  800e0d:	68 00 26 80 00       	push   $0x802600
  800e12:	e8 c6 10 00 00       	call   801edd <_panic>
	}
	retv = sys_page_map(envid, PFTEMP, envid, addr, PTE_W|PTE_U|PTE_P);
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	6a 07                	push   $0x7
  800e1c:	53                   	push   %ebx
  800e1d:	56                   	push   %esi
  800e1e:	68 00 f0 7f 00       	push   $0x7ff000
  800e23:	56                   	push   %esi
  800e24:	e8 9d fd ff ff       	call   800bc6 <sys_page_map>
	if(retv < 0){
  800e29:	83 c4 20             	add    $0x20,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	79 14                	jns    800e44 <pgfault+0xd0>
		panic("sys_page_map");
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	68 1a 26 80 00       	push   $0x80261a
  800e38:	6a 39                	push   $0x39
  800e3a:	68 00 26 80 00       	push   $0x802600
  800e3f:	e8 99 10 00 00       	call   801edd <_panic>
	}
	retv = sys_page_unmap(envid, PFTEMP);
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	68 00 f0 7f 00       	push   $0x7ff000
  800e4c:	56                   	push   %esi
  800e4d:	e8 b6 fd ff ff       	call   800c08 <sys_page_unmap>
	if(retv < 0){
  800e52:	83 c4 10             	add    $0x10,%esp
  800e55:	85 c0                	test   %eax,%eax
  800e57:	79 14                	jns    800e6d <pgfault+0xf9>
		panic("pgfault: can not unmap page.");
  800e59:	83 ec 04             	sub    $0x4,%esp
  800e5c:	68 27 26 80 00       	push   $0x802627
  800e61:	6a 3d                	push   $0x3d
  800e63:	68 00 26 80 00       	push   $0x802600
  800e68:	e8 70 10 00 00       	call   801edd <_panic>
	}
//	cprintf("pgfault:finish the pgfault.\n");
	//cprintf("out of pgfault.\n");
	return;
	panic("pgfault not implemented");
}
  800e6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <dupagege>:
	//panic("duppage not implemented");
	return 0;
}
//
void dupagege(envid_t dstenv, unsigned pn)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	8b 75 08             	mov    0x8(%ebp),%esi
	void * addr = (void*)(pn*PGSIZE);
  800e7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e7f:	c1 e3 0c             	shl    $0xc,%ebx

        int r;
       	cprintf("we are copying %x.",addr);
  800e82:	83 ec 08             	sub    $0x8,%esp
  800e85:	53                   	push   %ebx
  800e86:	68 44 26 80 00       	push   $0x802644
  800e8b:	e8 21 f3 ff ff       	call   8001b1 <cprintf>
	 if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800e90:	83 c4 0c             	add    $0xc,%esp
  800e93:	6a 07                	push   $0x7
  800e95:	53                   	push   %ebx
  800e96:	56                   	push   %esi
  800e97:	e8 e7 fc ff ff       	call   800b83 <sys_page_alloc>
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	79 15                	jns    800eb8 <dupagege+0x44>
                panic("sys_page_alloc: %e", r);
  800ea3:	50                   	push   %eax
  800ea4:	68 57 26 80 00       	push   $0x802657
  800ea9:	68 90 00 00 00       	push   $0x90
  800eae:	68 00 26 80 00       	push   $0x802600
  800eb3:	e8 25 10 00 00       	call   801edd <_panic>
      	//panic("we panic here.\n");
	cprintf("af p_a.");
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	68 6a 26 80 00       	push   $0x80266a
  800ec0:	e8 ec f2 ff ff       	call   8001b1 <cprintf>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800ec5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ecc:	68 00 00 40 00       	push   $0x400000
  800ed1:	6a 00                	push   $0x0
  800ed3:	53                   	push   %ebx
  800ed4:	56                   	push   %esi
  800ed5:	e8 ec fc ff ff       	call   800bc6 <sys_page_map>
  800eda:	83 c4 20             	add    $0x20,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 15                	jns    800ef6 <dupagege+0x82>
                panic("sys_page_map: %e", r);
  800ee1:	50                   	push   %eax
  800ee2:	68 72 26 80 00       	push   $0x802672
  800ee7:	68 94 00 00 00       	push   $0x94
  800eec:	68 00 26 80 00       	push   $0x802600
  800ef1:	e8 e7 0f 00 00       	call   801edd <_panic>
        cprintf("af_p_m.");
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	68 83 26 80 00       	push   $0x802683
  800efe:	e8 ae f2 ff ff       	call   8001b1 <cprintf>
	memmove(UTEMP, addr, PGSIZE);
  800f03:	83 c4 0c             	add    $0xc,%esp
  800f06:	68 00 10 00 00       	push   $0x1000
  800f0b:	53                   	push   %ebx
  800f0c:	68 00 00 40 00       	push   $0x400000
  800f11:	e8 fc f9 ff ff       	call   800912 <memmove>
//        if ((r = sys_page_unmap(0, UTEMP)) < 0)
  //              panic("sys_page_unmap: %e", r);
	cprintf("copying done.");
  800f16:	c7 04 24 8b 26 80 00 	movl   $0x80268b,(%esp)
  800f1d:	e8 8f f2 ff ff       	call   8001b1 <cprintf>
}
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	57                   	push   %edi
  800f30:	56                   	push   %esi
  800f31:	53                   	push   %ebx
  800f32:	83 ec 28             	sub    $0x28,%esp
	//cprintf("\t\t we are in the fork().\n");
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	extern unsigned char end[];
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800f35:	68 74 0d 80 00       	push   $0x800d74
  800f3a:	e8 e4 0f 00 00       	call   801f23 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f3f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f44:	cd 30                	int    $0x30
  800f46:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f49:	89 45 e0             	mov    %eax,-0x20(%ebp)
	//create a child
	child_envid = sys_exofork();
	
	//cprintf("after the ENVX(child_envid:%d\n",ENVX(child_envid));
	if(child_envid < 0 ){
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	79 17                	jns    800f6a <fork+0x3e>
		panic("sys_exofork failed.");
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	68 99 26 80 00       	push   $0x802699
  800f5b:	68 b7 00 00 00       	push   $0xb7
  800f60:	68 00 26 80 00       	push   $0x802600
  800f65:	e8 73 0f 00 00       	call   801edd <_panic>
  800f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	if(child_envid == 0){
  800f6f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f73:	75 21                	jne    800f96 <fork+0x6a>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f75:	e8 cb fb ff ff       	call   800b45 <sys_getenvid>
  800f7a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f82:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f87:	a3 04 40 80 00       	mov    %eax,0x804004
//		cprintf("we are the child.\n");
		return 0;
  800f8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f91:	e9 69 01 00 00       	jmp    8010ff <fork+0x1d3>
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800f96:	89 d8                	mov    %ebx,%eax
  800f98:	c1 e8 16             	shr    $0x16,%eax
  800f9b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800fa2:	a8 01                	test   $0x1,%al
  800fa4:	0f 84 d6 00 00 00    	je     801080 <fork+0x154>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)
  800faa:	89 de                	mov    %ebx,%esi
  800fac:	c1 ee 0c             	shr    $0xc,%esi
  800faf:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800fb6:	a8 01                	test   $0x1,%al
  800fb8:	0f 84 c2 00 00 00    	je     801080 <fork+0x154>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;
	//cprintf("get into duppage.\n");
	// LAB 4: Your code here.
	pte_t pte  = uvpt[pn];
  800fbe:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm = PTE_U | PTE_P;
	void *addr = (void*)(pn*PGSIZE);
  800fc5:	89 f7                	mov    %esi,%edi
  800fc7:	c1 e7 0c             	shl    $0xc,%edi
	envid_t kern_envid = sys_getenvid();
  800fca:	e8 76 fb ff ff       	call   800b45 <sys_getenvid>
  800fcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (uvpt[pn] & PTE_SHARE) {
  800fd2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fd9:	f6 c4 04             	test   $0x4,%ah
  800fdc:	74 1c                	je     800ffa <fork+0xce>
		sys_page_map(0, addr, envid, addr, PTE_SYSCALL);		
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	68 07 0e 00 00       	push   $0xe07
  800fe6:	57                   	push   %edi
  800fe7:	ff 75 e0             	pushl  -0x20(%ebp)
  800fea:	57                   	push   %edi
  800feb:	6a 00                	push   $0x0
  800fed:	e8 d4 fb ff ff       	call   800bc6 <sys_page_map>
  800ff2:	83 c4 20             	add    $0x20,%esp
  800ff5:	e9 86 00 00 00       	jmp    801080 <fork+0x154>
	}else if( (uvpt[pn] & PTE_W) > 0 || (uvpt[pn] & PTE_COW) > 0 ){
  800ffa:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801001:	a8 02                	test   $0x2,%al
  801003:	75 0c                	jne    801011 <fork+0xe5>
  801005:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80100c:	f6 c4 08             	test   $0x8,%ah
  80100f:	74 5b                	je     80106c <fork+0x140>

		if((r = sys_page_map(kern_envid, addr, envid, addr, PTE_P|PTE_U|PTE_COW)) <0 ){
  801011:	83 ec 0c             	sub    $0xc,%esp
  801014:	68 05 08 00 00       	push   $0x805
  801019:	57                   	push   %edi
  80101a:	ff 75 e0             	pushl  -0x20(%ebp)
  80101d:	57                   	push   %edi
  80101e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801021:	e8 a0 fb ff ff       	call   800bc6 <sys_page_map>
  801026:	83 c4 20             	add    $0x20,%esp
  801029:	85 c0                	test   %eax,%eax
  80102b:	79 12                	jns    80103f <fork+0x113>
			panic("duppage:page_re-mapping failed : %e",r);
  80102d:	50                   	push   %eax
  80102e:	68 1c 27 80 00       	push   $0x80271c
  801033:	6a 5f                	push   $0x5f
  801035:	68 00 26 80 00       	push   $0x802600
  80103a:	e8 9e 0e 00 00       	call   801edd <_panic>
			return r;
		}
	
		if((r = sys_page_map(kern_envid, addr, kern_envid, addr, PTE_P|PTE_U|PTE_COW))<0){
  80103f:	83 ec 0c             	sub    $0xc,%esp
  801042:	68 05 08 00 00       	push   $0x805
  801047:	57                   	push   %edi
  801048:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80104b:	50                   	push   %eax
  80104c:	57                   	push   %edi
  80104d:	50                   	push   %eax
  80104e:	e8 73 fb ff ff       	call   800bc6 <sys_page_map>
  801053:	83 c4 20             	add    $0x20,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	79 26                	jns    801080 <fork+0x154>
			panic("duppage:page re-mapping failed:%e",r);
  80105a:	50                   	push   %eax
  80105b:	68 40 27 80 00       	push   $0x802740
  801060:	6a 64                	push   $0x64
  801062:	68 00 26 80 00       	push   $0x802600
  801067:	e8 71 0e 00 00       	call   801edd <_panic>
			return r;
		}

	}else{

		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	6a 05                	push   $0x5
  801071:	57                   	push   %edi
  801072:	ff 75 e0             	pushl  -0x20(%ebp)
  801075:	57                   	push   %edi
  801076:	6a 00                	push   $0x0
  801078:	e8 49 fb ff ff       	call   800bc6 <sys_page_map>
  80107d:	83 c4 20             	add    $0x20,%esp
		return 0;
	}	
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	//cprintf("\t\t\t\tthisenv->env_id%x,child_envid %x\n",thisenv->env_id,child_envid);
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  801080:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801086:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80108c:	0f 85 04 ff ff ff    	jne    800f96 <fork+0x6a>
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  801092:	83 ec 04             	sub    $0x4,%esp
  801095:	6a 07                	push   $0x7
  801097:	68 00 f0 bf ee       	push   $0xeebff000
  80109c:	ff 75 dc             	pushl  -0x24(%ebp)
  80109f:	e8 df fa ff ff       	call   800b83 <sys_page_alloc>
	if(retv < 0){
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 17                	jns    8010c2 <fork+0x196>
		panic("sys_page_alloc failed.\n");
  8010ab:	83 ec 04             	sub    $0x4,%esp
  8010ae:	68 ad 26 80 00       	push   $0x8026ad
  8010b3:	68 cc 00 00 00       	push   $0xcc
  8010b8:	68 00 26 80 00       	push   $0x802600
  8010bd:	e8 1b 0e 00 00       	call   801edd <_panic>
	if(retv < 0){
		panic("sys_page_unmap failed.\n");
	}
	*/
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  8010c2:	83 ec 08             	sub    $0x8,%esp
  8010c5:	68 88 1f 80 00       	push   $0x801f88
  8010ca:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010cd:	57                   	push   %edi
  8010ce:	e8 fb fb ff ff       	call   800cce <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  8010d3:	83 c4 08             	add    $0x8,%esp
  8010d6:	6a 02                	push   $0x2
  8010d8:	57                   	push   %edi
  8010d9:	e8 6c fb ff ff       	call   800c4a <sys_env_set_status>
	if(retv < 0){
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	79 17                	jns    8010fc <fork+0x1d0>
		panic("sys_env_set_status failed.\n");
  8010e5:	83 ec 04             	sub    $0x4,%esp
  8010e8:	68 c5 26 80 00       	push   $0x8026c5
  8010ed:	68 dd 00 00 00       	push   $0xdd
  8010f2:	68 00 26 80 00       	push   $0x802600
  8010f7:	e8 e1 0d 00 00       	call   801edd <_panic>
	}
//	cprintf("\tfork():total fork done.\n");
	return child_envid;
  8010fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
	panic("fork not implemented");
}
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <sfork>:

// Challenge!
int
sfork(void)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80110d:	68 e1 26 80 00       	push   $0x8026e1
  801112:	68 e8 00 00 00       	push   $0xe8
  801117:	68 00 26 80 00       	push   $0x802600
  80111c:	e8 bc 0d 00 00       	call   801edd <_panic>

00801121 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	56                   	push   %esi
  801125:	53                   	push   %ebx
  801126:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801129:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	ff 75 0c             	pushl  0xc(%ebp)
  801132:	e8 fc fb ff ff       	call   800d33 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801137:	83 c4 10             	add    $0x10,%esp
  80113a:	85 f6                	test   %esi,%esi
  80113c:	74 1c                	je     80115a <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  80113e:	a1 04 40 80 00       	mov    0x804004,%eax
  801143:	8b 40 78             	mov    0x78(%eax),%eax
  801146:	89 06                	mov    %eax,(%esi)
  801148:	eb 10                	jmp    80115a <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  80114a:	83 ec 0c             	sub    $0xc,%esp
  80114d:	68 62 27 80 00       	push   $0x802762
  801152:	e8 5a f0 ff ff       	call   8001b1 <cprintf>
  801157:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  80115a:	a1 04 40 80 00       	mov    0x804004,%eax
  80115f:	8b 50 74             	mov    0x74(%eax),%edx
  801162:	85 d2                	test   %edx,%edx
  801164:	74 e4                	je     80114a <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801166:	85 db                	test   %ebx,%ebx
  801168:	74 05                	je     80116f <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  80116a:	8b 40 74             	mov    0x74(%eax),%eax
  80116d:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80116f:	a1 04 40 80 00       	mov    0x804004,%eax
  801174:	8b 40 70             	mov    0x70(%eax),%eax

}
  801177:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    

0080117e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80118d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801190:	85 db                	test   %ebx,%ebx
  801192:	75 13                	jne    8011a7 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801194:	6a 00                	push   $0x0
  801196:	68 00 00 c0 ee       	push   $0xeec00000
  80119b:	56                   	push   %esi
  80119c:	57                   	push   %edi
  80119d:	e8 6e fb ff ff       	call   800d10 <sys_ipc_try_send>
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	eb 0e                	jmp    8011b5 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  8011a7:	ff 75 14             	pushl  0x14(%ebp)
  8011aa:	53                   	push   %ebx
  8011ab:	56                   	push   %esi
  8011ac:	57                   	push   %edi
  8011ad:	e8 5e fb ff ff       	call   800d10 <sys_ipc_try_send>
  8011b2:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  8011b5:	85 c0                	test   %eax,%eax
  8011b7:	75 d7                	jne    801190 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  8011b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    

008011c1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011c7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011cc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011cf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011d5:	8b 52 50             	mov    0x50(%edx),%edx
  8011d8:	39 ca                	cmp    %ecx,%edx
  8011da:	75 0d                	jne    8011e9 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e4:	8b 40 48             	mov    0x48(%eax),%eax
  8011e7:	eb 0f                	jmp    8011f8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011e9:	83 c0 01             	add    $0x1,%eax
  8011ec:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011f1:	75 d9                	jne    8011cc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801200:	05 00 00 00 30       	add    $0x30000000,%eax
  801205:	c1 e8 0c             	shr    $0xc,%eax
}
  801208:	5d                   	pop    %ebp
  801209:	c3                   	ret    

0080120a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80120d:	8b 45 08             	mov    0x8(%ebp),%eax
  801210:	05 00 00 00 30       	add    $0x30000000,%eax
  801215:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80121a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801227:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	c1 ea 16             	shr    $0x16,%edx
  801231:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801238:	f6 c2 01             	test   $0x1,%dl
  80123b:	74 11                	je     80124e <fd_alloc+0x2d>
  80123d:	89 c2                	mov    %eax,%edx
  80123f:	c1 ea 0c             	shr    $0xc,%edx
  801242:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801249:	f6 c2 01             	test   $0x1,%dl
  80124c:	75 09                	jne    801257 <fd_alloc+0x36>
			*fd_store = fd;
  80124e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
  801255:	eb 17                	jmp    80126e <fd_alloc+0x4d>
  801257:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80125c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801261:	75 c9                	jne    80122c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801263:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801269:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801276:	83 f8 1f             	cmp    $0x1f,%eax
  801279:	77 36                	ja     8012b1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80127b:	c1 e0 0c             	shl    $0xc,%eax
  80127e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801283:	89 c2                	mov    %eax,%edx
  801285:	c1 ea 16             	shr    $0x16,%edx
  801288:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	74 24                	je     8012b8 <fd_lookup+0x48>
  801294:	89 c2                	mov    %eax,%edx
  801296:	c1 ea 0c             	shr    $0xc,%edx
  801299:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a0:	f6 c2 01             	test   $0x1,%dl
  8012a3:	74 1a                	je     8012bf <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a8:	89 02                	mov    %eax,(%edx)
	return 0;
  8012aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012af:	eb 13                	jmp    8012c4 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012b6:	eb 0c                	jmp    8012c4 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bd:	eb 05                	jmp    8012c4 <fd_lookup+0x54>
  8012bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    

008012c6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c6:	55                   	push   %ebp
  8012c7:	89 e5                	mov    %esp,%ebp
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cf:	ba f0 27 80 00       	mov    $0x8027f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d4:	eb 13                	jmp    8012e9 <dev_lookup+0x23>
  8012d6:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012d9:	39 08                	cmp    %ecx,(%eax)
  8012db:	75 0c                	jne    8012e9 <dev_lookup+0x23>
			*dev = devtab[i];
  8012dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e7:	eb 2e                	jmp    801317 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012e9:	8b 02                	mov    (%edx),%eax
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	75 e7                	jne    8012d6 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f4:	8b 40 48             	mov    0x48(%eax),%eax
  8012f7:	83 ec 04             	sub    $0x4,%esp
  8012fa:	51                   	push   %ecx
  8012fb:	50                   	push   %eax
  8012fc:	68 74 27 80 00       	push   $0x802774
  801301:	e8 ab ee ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  801306:	8b 45 0c             	mov    0xc(%ebp),%eax
  801309:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801317:	c9                   	leave  
  801318:	c3                   	ret    

00801319 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 10             	sub    $0x10,%esp
  801321:	8b 75 08             	mov    0x8(%ebp),%esi
  801324:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	50                   	push   %eax
  80132b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801331:	c1 e8 0c             	shr    $0xc,%eax
  801334:	50                   	push   %eax
  801335:	e8 36 ff ff ff       	call   801270 <fd_lookup>
  80133a:	83 c4 08             	add    $0x8,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	78 05                	js     801346 <fd_close+0x2d>
	    || fd != fd2)
  801341:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801344:	74 0c                	je     801352 <fd_close+0x39>
		return (must_exist ? r : 0);
  801346:	84 db                	test   %bl,%bl
  801348:	ba 00 00 00 00       	mov    $0x0,%edx
  80134d:	0f 44 c2             	cmove  %edx,%eax
  801350:	eb 41                	jmp    801393 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 36                	pushl  (%esi)
  80135b:	e8 66 ff ff ff       	call   8012c6 <dev_lookup>
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 1a                	js     801383 <fd_close+0x6a>
		if (dev->dev_close)
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80136f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801374:	85 c0                	test   %eax,%eax
  801376:	74 0b                	je     801383 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801378:	83 ec 0c             	sub    $0xc,%esp
  80137b:	56                   	push   %esi
  80137c:	ff d0                	call   *%eax
  80137e:	89 c3                	mov    %eax,%ebx
  801380:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	56                   	push   %esi
  801387:	6a 00                	push   $0x0
  801389:	e8 7a f8 ff ff       	call   800c08 <sys_page_unmap>
	return r;
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	89 d8                	mov    %ebx,%eax
}
  801393:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	ff 75 08             	pushl  0x8(%ebp)
  8013a7:	e8 c4 fe ff ff       	call   801270 <fd_lookup>
  8013ac:	83 c4 08             	add    $0x8,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 10                	js     8013c3 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	6a 01                	push   $0x1
  8013b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013bb:	e8 59 ff ff ff       	call   801319 <fd_close>
  8013c0:	83 c4 10             	add    $0x10,%esp
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <close_all>:

void
close_all(void)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	53                   	push   %ebx
  8013c9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013cc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d1:	83 ec 0c             	sub    $0xc,%esp
  8013d4:	53                   	push   %ebx
  8013d5:	e8 c0 ff ff ff       	call   80139a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013da:	83 c3 01             	add    $0x1,%ebx
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	83 fb 20             	cmp    $0x20,%ebx
  8013e3:	75 ec                	jne    8013d1 <close_all+0xc>
		close(i);
}
  8013e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	57                   	push   %edi
  8013ee:	56                   	push   %esi
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 2c             	sub    $0x2c,%esp
  8013f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	ff 75 08             	pushl  0x8(%ebp)
  8013fd:	e8 6e fe ff ff       	call   801270 <fd_lookup>
  801402:	83 c4 08             	add    $0x8,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	0f 88 c1 00 00 00    	js     8014ce <dup+0xe4>
		return r;
	close(newfdnum);
  80140d:	83 ec 0c             	sub    $0xc,%esp
  801410:	56                   	push   %esi
  801411:	e8 84 ff ff ff       	call   80139a <close>

	newfd = INDEX2FD(newfdnum);
  801416:	89 f3                	mov    %esi,%ebx
  801418:	c1 e3 0c             	shl    $0xc,%ebx
  80141b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801421:	83 c4 04             	add    $0x4,%esp
  801424:	ff 75 e4             	pushl  -0x1c(%ebp)
  801427:	e8 de fd ff ff       	call   80120a <fd2data>
  80142c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80142e:	89 1c 24             	mov    %ebx,(%esp)
  801431:	e8 d4 fd ff ff       	call   80120a <fd2data>
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80143c:	89 f8                	mov    %edi,%eax
  80143e:	c1 e8 16             	shr    $0x16,%eax
  801441:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801448:	a8 01                	test   $0x1,%al
  80144a:	74 37                	je     801483 <dup+0x99>
  80144c:	89 f8                	mov    %edi,%eax
  80144e:	c1 e8 0c             	shr    $0xc,%eax
  801451:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801458:	f6 c2 01             	test   $0x1,%dl
  80145b:	74 26                	je     801483 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80145d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	25 07 0e 00 00       	and    $0xe07,%eax
  80146c:	50                   	push   %eax
  80146d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801470:	6a 00                	push   $0x0
  801472:	57                   	push   %edi
  801473:	6a 00                	push   $0x0
  801475:	e8 4c f7 ff ff       	call   800bc6 <sys_page_map>
  80147a:	89 c7                	mov    %eax,%edi
  80147c:	83 c4 20             	add    $0x20,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 2e                	js     8014b1 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801483:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801486:	89 d0                	mov    %edx,%eax
  801488:	c1 e8 0c             	shr    $0xc,%eax
  80148b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	25 07 0e 00 00       	and    $0xe07,%eax
  80149a:	50                   	push   %eax
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	52                   	push   %edx
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 20 f7 ff ff       	call   800bc6 <sys_page_map>
  8014a6:	89 c7                	mov    %eax,%edi
  8014a8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ab:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ad:	85 ff                	test   %edi,%edi
  8014af:	79 1d                	jns    8014ce <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 4c f7 ff ff       	call   800c08 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014bc:	83 c4 08             	add    $0x8,%esp
  8014bf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c2:	6a 00                	push   $0x0
  8014c4:	e8 3f f7 ff ff       	call   800c08 <sys_page_unmap>
	return r;
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	89 f8                	mov    %edi,%eax
}
  8014ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5e                   	pop    %esi
  8014d3:	5f                   	pop    %edi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 14             	sub    $0x14,%esp
  8014dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	53                   	push   %ebx
  8014e5:	e8 86 fd ff ff       	call   801270 <fd_lookup>
  8014ea:	83 c4 08             	add    $0x8,%esp
  8014ed:	89 c2                	mov    %eax,%edx
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 6d                	js     801560 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f9:	50                   	push   %eax
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	ff 30                	pushl  (%eax)
  8014ff:	e8 c2 fd ff ff       	call   8012c6 <dev_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 4c                	js     801557 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80150b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80150e:	8b 42 08             	mov    0x8(%edx),%eax
  801511:	83 e0 03             	and    $0x3,%eax
  801514:	83 f8 01             	cmp    $0x1,%eax
  801517:	75 21                	jne    80153a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801519:	a1 04 40 80 00       	mov    0x804004,%eax
  80151e:	8b 40 48             	mov    0x48(%eax),%eax
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	53                   	push   %ebx
  801525:	50                   	push   %eax
  801526:	68 b5 27 80 00       	push   $0x8027b5
  80152b:	e8 81 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801530:	83 c4 10             	add    $0x10,%esp
  801533:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801538:	eb 26                	jmp    801560 <read+0x8a>
	}
	if (!dev->dev_read)
  80153a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153d:	8b 40 08             	mov    0x8(%eax),%eax
  801540:	85 c0                	test   %eax,%eax
  801542:	74 17                	je     80155b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	ff 75 10             	pushl  0x10(%ebp)
  80154a:	ff 75 0c             	pushl  0xc(%ebp)
  80154d:	52                   	push   %edx
  80154e:	ff d0                	call   *%eax
  801550:	89 c2                	mov    %eax,%edx
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	eb 09                	jmp    801560 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801557:	89 c2                	mov    %eax,%edx
  801559:	eb 05                	jmp    801560 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80155b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801560:	89 d0                	mov    %edx,%eax
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	57                   	push   %edi
  80156b:	56                   	push   %esi
  80156c:	53                   	push   %ebx
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	8b 7d 08             	mov    0x8(%ebp),%edi
  801573:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801576:	bb 00 00 00 00       	mov    $0x0,%ebx
  80157b:	eb 21                	jmp    80159e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80157d:	83 ec 04             	sub    $0x4,%esp
  801580:	89 f0                	mov    %esi,%eax
  801582:	29 d8                	sub    %ebx,%eax
  801584:	50                   	push   %eax
  801585:	89 d8                	mov    %ebx,%eax
  801587:	03 45 0c             	add    0xc(%ebp),%eax
  80158a:	50                   	push   %eax
  80158b:	57                   	push   %edi
  80158c:	e8 45 ff ff ff       	call   8014d6 <read>
		if (m < 0)
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	78 10                	js     8015a8 <readn+0x41>
			return m;
		if (m == 0)
  801598:	85 c0                	test   %eax,%eax
  80159a:	74 0a                	je     8015a6 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80159c:	01 c3                	add    %eax,%ebx
  80159e:	39 f3                	cmp    %esi,%ebx
  8015a0:	72 db                	jb     80157d <readn+0x16>
  8015a2:	89 d8                	mov    %ebx,%eax
  8015a4:	eb 02                	jmp    8015a8 <readn+0x41>
  8015a6:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5f                   	pop    %edi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 14             	sub    $0x14,%esp
  8015b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	53                   	push   %ebx
  8015bf:	e8 ac fc ff ff       	call   801270 <fd_lookup>
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 68                	js     801635 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d3:	50                   	push   %eax
  8015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d7:	ff 30                	pushl  (%eax)
  8015d9:	e8 e8 fc ff ff       	call   8012c6 <dev_lookup>
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 47                	js     80162c <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ec:	75 21                	jne    80160f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f3:	8b 40 48             	mov    0x48(%eax),%eax
  8015f6:	83 ec 04             	sub    $0x4,%esp
  8015f9:	53                   	push   %ebx
  8015fa:	50                   	push   %eax
  8015fb:	68 d1 27 80 00       	push   $0x8027d1
  801600:	e8 ac eb ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80160d:	eb 26                	jmp    801635 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80160f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801612:	8b 52 0c             	mov    0xc(%edx),%edx
  801615:	85 d2                	test   %edx,%edx
  801617:	74 17                	je     801630 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801619:	83 ec 04             	sub    $0x4,%esp
  80161c:	ff 75 10             	pushl  0x10(%ebp)
  80161f:	ff 75 0c             	pushl  0xc(%ebp)
  801622:	50                   	push   %eax
  801623:	ff d2                	call   *%edx
  801625:	89 c2                	mov    %eax,%edx
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	eb 09                	jmp    801635 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80162c:	89 c2                	mov    %eax,%edx
  80162e:	eb 05                	jmp    801635 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801630:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801635:	89 d0                	mov    %edx,%eax
  801637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <seek>:

int
seek(int fdnum, off_t offset)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801642:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	ff 75 08             	pushl  0x8(%ebp)
  801649:	e8 22 fc ff ff       	call   801270 <fd_lookup>
  80164e:	83 c4 08             	add    $0x8,%esp
  801651:	85 c0                	test   %eax,%eax
  801653:	78 0e                	js     801663 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801655:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801658:	8b 55 0c             	mov    0xc(%ebp),%edx
  80165b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80165e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	53                   	push   %ebx
  801669:	83 ec 14             	sub    $0x14,%esp
  80166c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	53                   	push   %ebx
  801674:	e8 f7 fb ff ff       	call   801270 <fd_lookup>
  801679:	83 c4 08             	add    $0x8,%esp
  80167c:	89 c2                	mov    %eax,%edx
  80167e:	85 c0                	test   %eax,%eax
  801680:	78 65                	js     8016e7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801682:	83 ec 08             	sub    $0x8,%esp
  801685:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801688:	50                   	push   %eax
  801689:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80168c:	ff 30                	pushl  (%eax)
  80168e:	e8 33 fc ff ff       	call   8012c6 <dev_lookup>
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	85 c0                	test   %eax,%eax
  801698:	78 44                	js     8016de <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a1:	75 21                	jne    8016c4 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a3:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016a8:	8b 40 48             	mov    0x48(%eax),%eax
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	53                   	push   %ebx
  8016af:	50                   	push   %eax
  8016b0:	68 94 27 80 00       	push   $0x802794
  8016b5:	e8 f7 ea ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016ba:	83 c4 10             	add    $0x10,%esp
  8016bd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c2:	eb 23                	jmp    8016e7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c7:	8b 52 18             	mov    0x18(%edx),%edx
  8016ca:	85 d2                	test   %edx,%edx
  8016cc:	74 14                	je     8016e2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	50                   	push   %eax
  8016d5:	ff d2                	call   *%edx
  8016d7:	89 c2                	mov    %eax,%edx
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	eb 09                	jmp    8016e7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016de:	89 c2                	mov    %eax,%edx
  8016e0:	eb 05                	jmp    8016e7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016e7:	89 d0                	mov    %edx,%eax
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 14             	sub    $0x14,%esp
  8016f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	ff 75 08             	pushl  0x8(%ebp)
  8016ff:	e8 6c fb ff ff       	call   801270 <fd_lookup>
  801704:	83 c4 08             	add    $0x8,%esp
  801707:	89 c2                	mov    %eax,%edx
  801709:	85 c0                	test   %eax,%eax
  80170b:	78 58                	js     801765 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801717:	ff 30                	pushl  (%eax)
  801719:	e8 a8 fb ff ff       	call   8012c6 <dev_lookup>
  80171e:	83 c4 10             	add    $0x10,%esp
  801721:	85 c0                	test   %eax,%eax
  801723:	78 37                	js     80175c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801728:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172c:	74 32                	je     801760 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80172e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801731:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801738:	00 00 00 
	stat->st_isdir = 0;
  80173b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801742:	00 00 00 
	stat->st_dev = dev;
  801745:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80174b:	83 ec 08             	sub    $0x8,%esp
  80174e:	53                   	push   %ebx
  80174f:	ff 75 f0             	pushl  -0x10(%ebp)
  801752:	ff 50 14             	call   *0x14(%eax)
  801755:	89 c2                	mov    %eax,%edx
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	eb 09                	jmp    801765 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175c:	89 c2                	mov    %eax,%edx
  80175e:	eb 05                	jmp    801765 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801760:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801765:	89 d0                	mov    %edx,%eax
  801767:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	6a 00                	push   $0x0
  801776:	ff 75 08             	pushl  0x8(%ebp)
  801779:	e8 dc 01 00 00       	call   80195a <open>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 1b                	js     8017a2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	ff 75 0c             	pushl  0xc(%ebp)
  80178d:	50                   	push   %eax
  80178e:	e8 5b ff ff ff       	call   8016ee <fstat>
  801793:	89 c6                	mov    %eax,%esi
	close(fd);
  801795:	89 1c 24             	mov    %ebx,(%esp)
  801798:	e8 fd fb ff ff       	call   80139a <close>
	return r;
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	89 f0                	mov    %esi,%eax
}
  8017a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
  8017ae:	89 c6                	mov    %eax,%esi
  8017b0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017b2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017b9:	75 12                	jne    8017cd <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	6a 01                	push   $0x1
  8017c0:	e8 fc f9 ff ff       	call   8011c1 <ipc_find_env>
  8017c5:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ca:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017cd:	6a 07                	push   $0x7
  8017cf:	68 00 50 80 00       	push   $0x805000
  8017d4:	56                   	push   %esi
  8017d5:	ff 35 00 40 80 00    	pushl  0x804000
  8017db:	e8 9e f9 ff ff       	call   80117e <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  8017e0:	83 c4 0c             	add    $0xc,%esp
  8017e3:	6a 00                	push   $0x0
  8017e5:	53                   	push   %ebx
  8017e6:	6a 00                	push   $0x0
  8017e8:	e8 34 f9 ff ff       	call   801121 <ipc_recv>
}
  8017ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f0:	5b                   	pop    %ebx
  8017f1:	5e                   	pop    %esi
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801800:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801805:	8b 45 0c             	mov    0xc(%ebp),%eax
  801808:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	b8 02 00 00 00       	mov    $0x2,%eax
  801817:	e8 8d ff ff ff       	call   8017a9 <fsipc>
}
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 06 00 00 00       	mov    $0x6,%eax
  801839:	e8 6b ff ff ff       	call   8017a9 <fsipc>
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	8b 40 0c             	mov    0xc(%eax),%eax
  801850:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801855:	ba 00 00 00 00       	mov    $0x0,%edx
  80185a:	b8 05 00 00 00       	mov    $0x5,%eax
  80185f:	e8 45 ff ff ff       	call   8017a9 <fsipc>
  801864:	85 c0                	test   %eax,%eax
  801866:	78 2c                	js     801894 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	68 00 50 80 00       	push   $0x805000
  801870:	53                   	push   %ebx
  801871:	e8 0a ef ff ff       	call   800780 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801876:	a1 80 50 80 00       	mov    0x805080,%eax
  80187b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801881:	a1 84 50 80 00       	mov    0x805084,%eax
  801886:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801894:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a5:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ae:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b3:	50                   	push   %eax
  8018b4:	ff 75 0c             	pushl  0xc(%ebp)
  8018b7:	68 08 50 80 00       	push   $0x805008
  8018bc:	e8 51 f0 ff ff       	call   800912 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8018cb:	e8 d9 fe ff ff       	call   8017a9 <fsipc>
	//panic("devfile_write not implemented");
}
  8018d0:	c9                   	leave  
  8018d1:	c3                   	ret    

008018d2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d2:	55                   	push   %ebp
  8018d3:	89 e5                	mov    %esp,%ebp
  8018d5:	56                   	push   %esi
  8018d6:	53                   	push   %ebx
  8018d7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f5:	e8 af fe ff ff       	call   8017a9 <fsipc>
  8018fa:	89 c3                	mov    %eax,%ebx
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 51                	js     801951 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801900:	39 c6                	cmp    %eax,%esi
  801902:	73 19                	jae    80191d <devfile_read+0x4b>
  801904:	68 00 28 80 00       	push   $0x802800
  801909:	68 07 28 80 00       	push   $0x802807
  80190e:	68 80 00 00 00       	push   $0x80
  801913:	68 1c 28 80 00       	push   $0x80281c
  801918:	e8 c0 05 00 00       	call   801edd <_panic>
	assert(r <= PGSIZE);
  80191d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801922:	7e 19                	jle    80193d <devfile_read+0x6b>
  801924:	68 27 28 80 00       	push   $0x802827
  801929:	68 07 28 80 00       	push   $0x802807
  80192e:	68 81 00 00 00       	push   $0x81
  801933:	68 1c 28 80 00       	push   $0x80281c
  801938:	e8 a0 05 00 00       	call   801edd <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	50                   	push   %eax
  801941:	68 00 50 80 00       	push   $0x805000
  801946:	ff 75 0c             	pushl  0xc(%ebp)
  801949:	e8 c4 ef ff ff       	call   800912 <memmove>
	return r;
  80194e:	83 c4 10             	add    $0x10,%esp
}
  801951:	89 d8                	mov    %ebx,%eax
  801953:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	83 ec 20             	sub    $0x20,%esp
  801961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801964:	53                   	push   %ebx
  801965:	e8 dd ed ff ff       	call   800747 <strlen>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801972:	7f 67                	jg     8019db <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197a:	50                   	push   %eax
  80197b:	e8 a1 f8 ff ff       	call   801221 <fd_alloc>
  801980:	83 c4 10             	add    $0x10,%esp
		return r;
  801983:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801985:	85 c0                	test   %eax,%eax
  801987:	78 57                	js     8019e0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801989:	83 ec 08             	sub    $0x8,%esp
  80198c:	53                   	push   %ebx
  80198d:	68 00 50 80 00       	push   $0x805000
  801992:	e8 e9 ed ff ff       	call   800780 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801997:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199a:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80199f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a7:	e8 fd fd ff ff       	call   8017a9 <fsipc>
  8019ac:	89 c3                	mov    %eax,%ebx
  8019ae:	83 c4 10             	add    $0x10,%esp
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	79 14                	jns    8019c9 <open+0x6f>
		
		fd_close(fd, 0);
  8019b5:	83 ec 08             	sub    $0x8,%esp
  8019b8:	6a 00                	push   $0x0
  8019ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8019bd:	e8 57 f9 ff ff       	call   801319 <fd_close>
		return r;
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	89 da                	mov    %ebx,%edx
  8019c7:	eb 17                	jmp    8019e0 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cf:	e8 26 f8 ff ff       	call   8011fa <fd2num>
  8019d4:	89 c2                	mov    %eax,%edx
  8019d6:	83 c4 10             	add    $0x10,%esp
  8019d9:	eb 05                	jmp    8019e0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019db:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  8019e0:	89 d0                	mov    %edx,%eax
  8019e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f2:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f7:	e8 ad fd ff ff       	call   8017a9 <fsipc>
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	ff 75 08             	pushl  0x8(%ebp)
  801a0c:	e8 f9 f7 ff ff       	call   80120a <fd2data>
  801a11:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a13:	83 c4 08             	add    $0x8,%esp
  801a16:	68 33 28 80 00       	push   $0x802833
  801a1b:	53                   	push   %ebx
  801a1c:	e8 5f ed ff ff       	call   800780 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a21:	8b 46 04             	mov    0x4(%esi),%eax
  801a24:	2b 06                	sub    (%esi),%eax
  801a26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a2c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a33:	00 00 00 
	stat->st_dev = &devpipe;
  801a36:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a3d:	30 80 00 
	return 0;
}
  801a40:	b8 00 00 00 00       	mov    $0x0,%eax
  801a45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a48:	5b                   	pop    %ebx
  801a49:	5e                   	pop    %esi
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a56:	53                   	push   %ebx
  801a57:	6a 00                	push   $0x0
  801a59:	e8 aa f1 ff ff       	call   800c08 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5e:	89 1c 24             	mov    %ebx,(%esp)
  801a61:	e8 a4 f7 ff ff       	call   80120a <fd2data>
  801a66:	83 c4 08             	add    $0x8,%esp
  801a69:	50                   	push   %eax
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 97 f1 ff ff       	call   800c08 <sys_page_unmap>
}
  801a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	57                   	push   %edi
  801a7a:	56                   	push   %esi
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 1c             	sub    $0x1c,%esp
  801a7f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a82:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a84:	a1 04 40 80 00       	mov    0x804004,%eax
  801a89:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a8c:	83 ec 0c             	sub    $0xc,%esp
  801a8f:	ff 75 e0             	pushl  -0x20(%ebp)
  801a92:	e8 15 05 00 00       	call   801fac <pageref>
  801a97:	89 c3                	mov    %eax,%ebx
  801a99:	89 3c 24             	mov    %edi,(%esp)
  801a9c:	e8 0b 05 00 00       	call   801fac <pageref>
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	39 c3                	cmp    %eax,%ebx
  801aa6:	0f 94 c1             	sete   %cl
  801aa9:	0f b6 c9             	movzbl %cl,%ecx
  801aac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aaf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ab5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab8:	39 ce                	cmp    %ecx,%esi
  801aba:	74 1b                	je     801ad7 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801abc:	39 c3                	cmp    %eax,%ebx
  801abe:	75 c4                	jne    801a84 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ac0:	8b 42 58             	mov    0x58(%edx),%eax
  801ac3:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac6:	50                   	push   %eax
  801ac7:	56                   	push   %esi
  801ac8:	68 3a 28 80 00       	push   $0x80283a
  801acd:	e8 df e6 ff ff       	call   8001b1 <cprintf>
  801ad2:	83 c4 10             	add    $0x10,%esp
  801ad5:	eb ad                	jmp    801a84 <_pipeisclosed+0xe>
	}
}
  801ad7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	57                   	push   %edi
  801ae6:	56                   	push   %esi
  801ae7:	53                   	push   %ebx
  801ae8:	83 ec 28             	sub    $0x28,%esp
  801aeb:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aee:	56                   	push   %esi
  801aef:	e8 16 f7 ff ff       	call   80120a <fd2data>
  801af4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	bf 00 00 00 00       	mov    $0x0,%edi
  801afe:	eb 4b                	jmp    801b4b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b00:	89 da                	mov    %ebx,%edx
  801b02:	89 f0                	mov    %esi,%eax
  801b04:	e8 6d ff ff ff       	call   801a76 <_pipeisclosed>
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	75 48                	jne    801b55 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b0d:	e8 52 f0 ff ff       	call   800b64 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b12:	8b 43 04             	mov    0x4(%ebx),%eax
  801b15:	8b 0b                	mov    (%ebx),%ecx
  801b17:	8d 51 20             	lea    0x20(%ecx),%edx
  801b1a:	39 d0                	cmp    %edx,%eax
  801b1c:	73 e2                	jae    801b00 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b21:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b25:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b28:	89 c2                	mov    %eax,%edx
  801b2a:	c1 fa 1f             	sar    $0x1f,%edx
  801b2d:	89 d1                	mov    %edx,%ecx
  801b2f:	c1 e9 1b             	shr    $0x1b,%ecx
  801b32:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b35:	83 e2 1f             	and    $0x1f,%edx
  801b38:	29 ca                	sub    %ecx,%edx
  801b3a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b3e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b42:	83 c0 01             	add    $0x1,%eax
  801b45:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b48:	83 c7 01             	add    $0x1,%edi
  801b4b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4e:	75 c2                	jne    801b12 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b50:	8b 45 10             	mov    0x10(%ebp),%eax
  801b53:	eb 05                	jmp    801b5a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    

00801b62 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 18             	sub    $0x18,%esp
  801b6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b6e:	57                   	push   %edi
  801b6f:	e8 96 f6 ff ff       	call   80120a <fd2data>
  801b74:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7e:	eb 3d                	jmp    801bbd <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b80:	85 db                	test   %ebx,%ebx
  801b82:	74 04                	je     801b88 <devpipe_read+0x26>
				return i;
  801b84:	89 d8                	mov    %ebx,%eax
  801b86:	eb 44                	jmp    801bcc <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b88:	89 f2                	mov    %esi,%edx
  801b8a:	89 f8                	mov    %edi,%eax
  801b8c:	e8 e5 fe ff ff       	call   801a76 <_pipeisclosed>
  801b91:	85 c0                	test   %eax,%eax
  801b93:	75 32                	jne    801bc7 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b95:	e8 ca ef ff ff       	call   800b64 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b9a:	8b 06                	mov    (%esi),%eax
  801b9c:	3b 46 04             	cmp    0x4(%esi),%eax
  801b9f:	74 df                	je     801b80 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ba1:	99                   	cltd   
  801ba2:	c1 ea 1b             	shr    $0x1b,%edx
  801ba5:	01 d0                	add    %edx,%eax
  801ba7:	83 e0 1f             	and    $0x1f,%eax
  801baa:	29 d0                	sub    %edx,%eax
  801bac:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb4:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bb7:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bba:	83 c3 01             	add    $0x1,%ebx
  801bbd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc0:	75 d8                	jne    801b9a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc5:	eb 05                	jmp    801bcc <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc7:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcf:	5b                   	pop    %ebx
  801bd0:	5e                   	pop    %esi
  801bd1:	5f                   	pop    %edi
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	56                   	push   %esi
  801bd8:	53                   	push   %ebx
  801bd9:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdf:	50                   	push   %eax
  801be0:	e8 3c f6 ff ff       	call   801221 <fd_alloc>
  801be5:	83 c4 10             	add    $0x10,%esp
  801be8:	89 c2                	mov    %eax,%edx
  801bea:	85 c0                	test   %eax,%eax
  801bec:	0f 88 2c 01 00 00    	js     801d1e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf2:	83 ec 04             	sub    $0x4,%esp
  801bf5:	68 07 04 00 00       	push   $0x407
  801bfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 7f ef ff ff       	call   800b83 <sys_page_alloc>
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	89 c2                	mov    %eax,%edx
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 0d 01 00 00    	js     801d1e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c17:	50                   	push   %eax
  801c18:	e8 04 f6 ff ff       	call   801221 <fd_alloc>
  801c1d:	89 c3                	mov    %eax,%ebx
  801c1f:	83 c4 10             	add    $0x10,%esp
  801c22:	85 c0                	test   %eax,%eax
  801c24:	0f 88 e2 00 00 00    	js     801d0c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c2a:	83 ec 04             	sub    $0x4,%esp
  801c2d:	68 07 04 00 00       	push   $0x407
  801c32:	ff 75 f0             	pushl  -0x10(%ebp)
  801c35:	6a 00                	push   $0x0
  801c37:	e8 47 ef ff ff       	call   800b83 <sys_page_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	85 c0                	test   %eax,%eax
  801c43:	0f 88 c3 00 00 00    	js     801d0c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4f:	e8 b6 f5 ff ff       	call   80120a <fd2data>
  801c54:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c56:	83 c4 0c             	add    $0xc,%esp
  801c59:	68 07 04 00 00       	push   $0x407
  801c5e:	50                   	push   %eax
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 1d ef ff ff       	call   800b83 <sys_page_alloc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	0f 88 89 00 00 00    	js     801cfc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c73:	83 ec 0c             	sub    $0xc,%esp
  801c76:	ff 75 f0             	pushl  -0x10(%ebp)
  801c79:	e8 8c f5 ff ff       	call   80120a <fd2data>
  801c7e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c85:	50                   	push   %eax
  801c86:	6a 00                	push   $0x0
  801c88:	56                   	push   %esi
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 36 ef ff ff       	call   800bc6 <sys_page_map>
  801c90:	89 c3                	mov    %eax,%ebx
  801c92:	83 c4 20             	add    $0x20,%esp
  801c95:	85 c0                	test   %eax,%eax
  801c97:	78 55                	js     801cee <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc9:	e8 2c f5 ff ff       	call   8011fa <fd2num>
  801cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd3:	83 c4 04             	add    $0x4,%esp
  801cd6:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd9:	e8 1c f5 ff ff       	call   8011fa <fd2num>
  801cde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cec:	eb 30                	jmp    801d1e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cee:	83 ec 08             	sub    $0x8,%esp
  801cf1:	56                   	push   %esi
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 0f ef ff ff       	call   800c08 <sys_page_unmap>
  801cf9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cfc:	83 ec 08             	sub    $0x8,%esp
  801cff:	ff 75 f0             	pushl  -0x10(%ebp)
  801d02:	6a 00                	push   $0x0
  801d04:	e8 ff ee ff ff       	call   800c08 <sys_page_unmap>
  801d09:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d0c:	83 ec 08             	sub    $0x8,%esp
  801d0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d12:	6a 00                	push   $0x0
  801d14:	e8 ef ee ff ff       	call   800c08 <sys_page_unmap>
  801d19:	83 c4 10             	add    $0x10,%esp
  801d1c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d1e:	89 d0                	mov    %edx,%eax
  801d20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d30:	50                   	push   %eax
  801d31:	ff 75 08             	pushl  0x8(%ebp)
  801d34:	e8 37 f5 ff ff       	call   801270 <fd_lookup>
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	78 18                	js     801d58 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d40:	83 ec 0c             	sub    $0xc,%esp
  801d43:	ff 75 f4             	pushl  -0xc(%ebp)
  801d46:	e8 bf f4 ff ff       	call   80120a <fd2data>
	return _pipeisclosed(fd, p);
  801d4b:	89 c2                	mov    %eax,%edx
  801d4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d50:	e8 21 fd ff ff       	call   801a76 <_pipeisclosed>
  801d55:	83 c4 10             	add    $0x10,%esp
}
  801d58:	c9                   	leave  
  801d59:	c3                   	ret    

00801d5a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801d62:	5d                   	pop    %ebp
  801d63:	c3                   	ret    

00801d64 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d6a:	68 52 28 80 00       	push   $0x802852
  801d6f:	ff 75 0c             	pushl  0xc(%ebp)
  801d72:	e8 09 ea ff ff       	call   800780 <strcpy>
	return 0;
}
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7c:	c9                   	leave  
  801d7d:	c3                   	ret    

00801d7e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d95:	eb 2d                	jmp    801dc4 <devcons_write+0x46>
		m = n - tot;
  801d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d9a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d9c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d9f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da4:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	53                   	push   %ebx
  801dab:	03 45 0c             	add    0xc(%ebp),%eax
  801dae:	50                   	push   %eax
  801daf:	57                   	push   %edi
  801db0:	e8 5d eb ff ff       	call   800912 <memmove>
		sys_cputs(buf, m);
  801db5:	83 c4 08             	add    $0x8,%esp
  801db8:	53                   	push   %ebx
  801db9:	57                   	push   %edi
  801dba:	e8 08 ed ff ff       	call   800ac7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbf:	01 de                	add    %ebx,%esi
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	89 f0                	mov    %esi,%eax
  801dc6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc9:	72 cc                	jb     801d97 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5e                   	pop    %esi
  801dd0:	5f                   	pop    %edi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 08             	sub    $0x8,%esp
  801dd9:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dde:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de2:	74 2a                	je     801e0e <devcons_read+0x3b>
  801de4:	eb 05                	jmp    801deb <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de6:	e8 79 ed ff ff       	call   800b64 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801deb:	e8 f5 ec ff ff       	call   800ae5 <sys_cgetc>
  801df0:	85 c0                	test   %eax,%eax
  801df2:	74 f2                	je     801de6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 16                	js     801e0e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df8:	83 f8 04             	cmp    $0x4,%eax
  801dfb:	74 0c                	je     801e09 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e00:	88 02                	mov    %al,(%edx)
	return 1;
  801e02:	b8 01 00 00 00       	mov    $0x1,%eax
  801e07:	eb 05                	jmp    801e0e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e09:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0e:	c9                   	leave  
  801e0f:	c3                   	ret    

00801e10 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e16:	8b 45 08             	mov    0x8(%ebp),%eax
  801e19:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e1c:	6a 01                	push   $0x1
  801e1e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e21:	50                   	push   %eax
  801e22:	e8 a0 ec ff ff       	call   800ac7 <sys_cputs>
}
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <getchar>:

int
getchar(void)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e32:	6a 01                	push   $0x1
  801e34:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e37:	50                   	push   %eax
  801e38:	6a 00                	push   $0x0
  801e3a:	e8 97 f6 ff ff       	call   8014d6 <read>
	if (r < 0)
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	85 c0                	test   %eax,%eax
  801e44:	78 0f                	js     801e55 <getchar+0x29>
		return r;
	if (r < 1)
  801e46:	85 c0                	test   %eax,%eax
  801e48:	7e 06                	jle    801e50 <getchar+0x24>
		return -E_EOF;
	return c;
  801e4a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e4e:	eb 05                	jmp    801e55 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e50:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e55:	c9                   	leave  
  801e56:	c3                   	ret    

00801e57 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e60:	50                   	push   %eax
  801e61:	ff 75 08             	pushl  0x8(%ebp)
  801e64:	e8 07 f4 ff ff       	call   801270 <fd_lookup>
  801e69:	83 c4 10             	add    $0x10,%esp
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 11                	js     801e81 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e73:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e79:	39 10                	cmp    %edx,(%eax)
  801e7b:	0f 94 c0             	sete   %al
  801e7e:	0f b6 c0             	movzbl %al,%eax
}
  801e81:	c9                   	leave  
  801e82:	c3                   	ret    

00801e83 <opencons>:

int
opencons(void)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8c:	50                   	push   %eax
  801e8d:	e8 8f f3 ff ff       	call   801221 <fd_alloc>
  801e92:	83 c4 10             	add    $0x10,%esp
		return r;
  801e95:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e97:	85 c0                	test   %eax,%eax
  801e99:	78 3e                	js     801ed9 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9b:	83 ec 04             	sub    $0x4,%esp
  801e9e:	68 07 04 00 00       	push   $0x407
  801ea3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea6:	6a 00                	push   $0x0
  801ea8:	e8 d6 ec ff ff       	call   800b83 <sys_page_alloc>
  801ead:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb0:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 23                	js     801ed9 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ecb:	83 ec 0c             	sub    $0xc,%esp
  801ece:	50                   	push   %eax
  801ecf:	e8 26 f3 ff ff       	call   8011fa <fd2num>
  801ed4:	89 c2                	mov    %eax,%edx
  801ed6:	83 c4 10             	add    $0x10,%esp
}
  801ed9:	89 d0                	mov    %edx,%eax
  801edb:	c9                   	leave  
  801edc:	c3                   	ret    

00801edd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	56                   	push   %esi
  801ee1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ee2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ee5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eeb:	e8 55 ec ff ff       	call   800b45 <sys_getenvid>
  801ef0:	83 ec 0c             	sub    $0xc,%esp
  801ef3:	ff 75 0c             	pushl  0xc(%ebp)
  801ef6:	ff 75 08             	pushl  0x8(%ebp)
  801ef9:	56                   	push   %esi
  801efa:	50                   	push   %eax
  801efb:	68 60 28 80 00       	push   $0x802860
  801f00:	e8 ac e2 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f05:	83 c4 18             	add    $0x18,%esp
  801f08:	53                   	push   %ebx
  801f09:	ff 75 10             	pushl  0x10(%ebp)
  801f0c:	e8 4f e2 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801f11:	c7 04 24 c3 26 80 00 	movl   $0x8026c3,(%esp)
  801f18:	e8 94 e2 ff ff       	call   8001b1 <cprintf>
  801f1d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f20:	cc                   	int3   
  801f21:	eb fd                	jmp    801f20 <_panic+0x43>

00801f23 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 08             	sub    $0x8,%esp
	int r;
//	cprintf("\twe enter set_pgfault_handler.\n");	
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801f29:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f30:	75 4c                	jne    801f7e <set_pgfault_handler+0x5b>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  801f32:	a1 04 40 80 00       	mov    0x804004,%eax
  801f37:	8b 40 48             	mov    0x48(%eax),%eax
  801f3a:	83 ec 04             	sub    $0x4,%esp
  801f3d:	6a 07                	push   $0x7
  801f3f:	68 00 f0 bf ee       	push   $0xeebff000
  801f44:	50                   	push   %eax
  801f45:	e8 39 ec ff ff       	call   800b83 <sys_page_alloc>
		if(retv != 0){
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	74 14                	je     801f65 <set_pgfault_handler+0x42>
			panic("can't alloc page for user exception stack.\n");
  801f51:	83 ec 04             	sub    $0x4,%esp
  801f54:	68 84 28 80 00       	push   $0x802884
  801f59:	6a 27                	push   $0x27
  801f5b:	68 b0 28 80 00       	push   $0x8028b0
  801f60:	e8 78 ff ff ff       	call   801edd <_panic>
		}
//		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
//		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f65:	a1 04 40 80 00       	mov    0x804004,%eax
  801f6a:	8b 40 48             	mov    0x48(%eax),%eax
  801f6d:	83 ec 08             	sub    $0x8,%esp
  801f70:	68 88 1f 80 00       	push   $0x801f88
  801f75:	50                   	push   %eax
  801f76:	e8 53 ed ff ff       	call   800cce <sys_env_set_pgfault_upcall>
  801f7b:	83 c4 10             	add    $0x10,%esp
//		cprintf("\twe set_pgfault_upcall done.\n");			
	
	}
//	cprintf("\twe set _pgfault_handler after this.\n");
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f81:	a3 00 60 80 00       	mov    %eax,0x806000

}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f88:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f89:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8e:	ff d0                	call   *%eax
//	call *%eax
	addl $4, %esp			// pop function argument
  801f90:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%edx//trap-time eip
  801f93:	8b 54 24 28          	mov    0x28(%esp),%edx
	subl $0x4,0x30(%esp)
  801f97:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp),%eax //trap-time esp-4
  801f9c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %edx,(%eax)
  801fa0:	89 10                	mov    %edx,(%eax)
	addl $0x8,%esp
  801fa2:	83 c4 08             	add    $0x8,%esp

	
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal;
  801fa5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4,%esp //eip
  801fa6:	83 c4 04             	add    $0x4,%esp
	popfl
  801fa9:	9d                   	popf   
	add $4,   %esp
	popfl
*/
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801faa:	5c                   	pop    %esp
/*
	popl %esp
*/
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fab:	c3                   	ret    

00801fac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	c1 e8 16             	shr    $0x16,%eax
  801fb7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc3:	f6 c1 01             	test   $0x1,%cl
  801fc6:	74 1d                	je     801fe5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fc8:	c1 ea 0c             	shr    $0xc,%edx
  801fcb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fd2:	f6 c2 01             	test   $0x1,%dl
  801fd5:	74 0e                	je     801fe5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd7:	c1 ea 0c             	shr    $0xc,%edx
  801fda:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe1:	ef 
  801fe2:	0f b7 c0             	movzwl %ax,%eax
}
  801fe5:	5d                   	pop    %ebp
  801fe6:	c3                   	ret    
  801fe7:	66 90                	xchg   %ax,%ax
  801fe9:	66 90                	xchg   %ax,%ax
  801feb:	66 90                	xchg   %ax,%ax
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

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
