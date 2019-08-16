
obj/user/pingpong:     file format elf32-i386


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
  80003c:	e8 b9 0d 00 00       	call   800dfa <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 ee 0a 00 00       	call   800b3d <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 14 80 00       	push   $0x801420
  800059:	e8 4b 01 00 00       	call   8001a9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 80 0f 00 00       	call   800fec <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 56 0f 00 00       	call   800fd5 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 b4 0a 00 00       	call   800b3d <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 14 80 00       	push   $0x801436
  800091:	e8 13 01 00 00       	call   8001a9 <cprintf>
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
  8000a9:	e8 3e 0f 00 00       	call   800fec <ipc_send>
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
  8000c9:	e8 6f 0a 00 00       	call   800b3d <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 eb 09 00 00       	call   800afc <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 04             	sub    $0x4,%esp
  80011d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800120:	8b 13                	mov    (%ebx),%edx
  800122:	8d 42 01             	lea    0x1(%edx),%eax
  800125:	89 03                	mov    %eax,(%ebx)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 79 09 00 00       	call   800abf <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 16 01 80 00       	push   $0x800116
  800187:	e8 54 01 00 00       	call   8002e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 1e 09 00 00       	call   800abf <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e4:	39 d3                	cmp    %edx,%ebx
  8001e6:	72 05                	jb     8001ed <printnum+0x30>
  8001e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001eb:	77 45                	ja     800232 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f9:	53                   	push   %ebx
  8001fa:	ff 75 10             	pushl  0x10(%ebp)
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 6f 0f 00 00       	call   801180 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	89 f8                	mov    %edi,%eax
  80021a:	e8 9e ff ff ff       	call   8001bd <printnum>
  80021f:	83 c4 20             	add    $0x20,%esp
  800222:	eb 18                	jmp    80023c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	ff 75 18             	pushl  0x18(%ebp)
  80022b:	ff d7                	call   *%edi
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	eb 03                	jmp    800235 <printnum+0x78>
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800235:	83 eb 01             	sub    $0x1,%ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f e8                	jg     800224 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	56                   	push   %esi
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	ff 75 e4             	pushl  -0x1c(%ebp)
  800246:	ff 75 e0             	pushl  -0x20(%ebp)
  800249:	ff 75 dc             	pushl  -0x24(%ebp)
  80024c:	ff 75 d8             	pushl  -0x28(%ebp)
  80024f:	e8 5c 10 00 00       	call   8012b0 <__umoddi3>
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	0f be 80 53 14 80 00 	movsbl 0x801453(%eax),%eax
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026f:	83 fa 01             	cmp    $0x1,%edx
  800272:	7e 0e                	jle    800282 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 08             	lea    0x8(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	8b 52 04             	mov    0x4(%edx),%edx
  800280:	eb 22                	jmp    8002a4 <getuint+0x38>
	else if (lflag)
  800282:	85 d2                	test   %edx,%edx
  800284:	74 10                	je     800296 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	ba 00 00 00 00       	mov    $0x0,%edx
  800294:	eb 0e                	jmp    8002a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b5:	73 0a                	jae    8002c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	88 02                	mov    %al,(%edx)
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cc:	50                   	push   %eax
  8002cd:	ff 75 10             	pushl  0x10(%ebp)
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	ff 75 08             	pushl  0x8(%ebp)
  8002d6:	e8 05 00 00 00       	call   8002e0 <vprintfmt>
	va_end(ap);
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 2c             	sub    $0x2c,%esp
  8002e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f2:	eb 12                	jmp    800306 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	0f 84 d3 03 00 00    	je     8006cf <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  8002fc:	83 ec 08             	sub    $0x8,%esp
  8002ff:	53                   	push   %ebx
  800300:	50                   	push   %eax
  800301:	ff d6                	call   *%esi
  800303:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800306:	83 c7 01             	add    $0x1,%edi
  800309:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030d:	83 f8 25             	cmp    $0x25,%eax
  800310:	75 e2                	jne    8002f4 <vprintfmt+0x14>
  800312:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800316:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800324:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032b:	ba 00 00 00 00       	mov    $0x0,%edx
  800330:	eb 07                	jmp    800339 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800335:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8d 47 01             	lea    0x1(%edi),%eax
  80033c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033f:	0f b6 07             	movzbl (%edi),%eax
  800342:	0f b6 c8             	movzbl %al,%ecx
  800345:	83 e8 23             	sub    $0x23,%eax
  800348:	3c 55                	cmp    $0x55,%al
  80034a:	0f 87 64 03 00 00    	ja     8006b4 <vprintfmt+0x3d4>
  800350:	0f b6 c0             	movzbl %al,%eax
  800353:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800361:	eb d6                	jmp    800339 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800366:	b8 00 00 00 00       	mov    $0x0,%eax
  80036b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800371:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800375:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800378:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037b:	83 fa 09             	cmp    $0x9,%edx
  80037e:	77 39                	ja     8003b9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800380:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800383:	eb e9                	jmp    80036e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 48 04             	lea    0x4(%eax),%ecx
  80038b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038e:	8b 00                	mov    (%eax),%eax
  800390:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800396:	eb 27                	jmp    8003bf <vprintfmt+0xdf>
  800398:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039b:	85 c0                	test   %eax,%eax
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	0f 49 c8             	cmovns %eax,%ecx
  8003a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	eb 8c                	jmp    800339 <vprintfmt+0x59>
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b7:	eb 80                	jmp    800339 <vprintfmt+0x59>
  8003b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bc:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c3:	0f 89 70 ff ff ff    	jns    800339 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003d6:	e9 5e ff ff ff       	jmp    800339 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003db:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e1:	e9 53 ff ff ff       	jmp    800339 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	53                   	push   %ebx
  8003f3:	ff 30                	pushl  (%eax)
  8003f5:	ff d6                	call   *%esi
			break;
  8003f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fd:	e9 04 ff ff ff       	jmp    800306 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 50 04             	lea    0x4(%eax),%edx
  800408:	89 55 14             	mov    %edx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	99                   	cltd   
  80040e:	31 d0                	xor    %edx,%eax
  800410:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800412:	83 f8 08             	cmp    $0x8,%eax
  800415:	7f 0b                	jg     800422 <vprintfmt+0x142>
  800417:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	75 18                	jne    80043a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800422:	50                   	push   %eax
  800423:	68 6b 14 80 00       	push   $0x80146b
  800428:	53                   	push   %ebx
  800429:	56                   	push   %esi
  80042a:	e8 94 fe ff ff       	call   8002c3 <printfmt>
  80042f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800435:	e9 cc fe ff ff       	jmp    800306 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80043a:	52                   	push   %edx
  80043b:	68 74 14 80 00       	push   $0x801474
  800440:	53                   	push   %ebx
  800441:	56                   	push   %esi
  800442:	e8 7c fe ff ff       	call   8002c3 <printfmt>
  800447:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044d:	e9 b4 fe ff ff       	jmp    800306 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045d:	85 ff                	test   %edi,%edi
  80045f:	b8 64 14 80 00       	mov    $0x801464,%eax
  800464:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800467:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046b:	0f 8e 94 00 00 00    	jle    800505 <vprintfmt+0x225>
  800471:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800475:	0f 84 98 00 00 00    	je     800513 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 c8             	pushl  -0x38(%ebp)
  800481:	57                   	push   %edi
  800482:	e8 d0 02 00 00       	call   800757 <strnlen>
  800487:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048a:	29 c1                	sub    %eax,%ecx
  80048c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80048f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800492:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800496:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800499:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	eb 0f                	jmp    8004af <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	53                   	push   %ebx
  8004a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ef 01             	sub    $0x1,%edi
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	7f ed                	jg     8004a0 <vprintfmt+0x1c0>
  8004b3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b9:	85 c9                	test   %ecx,%ecx
  8004bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c0:	0f 49 c1             	cmovns %ecx,%eax
  8004c3:	29 c1                	sub    %eax,%ecx
  8004c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c8:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ce:	89 cb                	mov    %ecx,%ebx
  8004d0:	eb 4d                	jmp    80051f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d6:	74 1b                	je     8004f3 <vprintfmt+0x213>
  8004d8:	0f be c0             	movsbl %al,%eax
  8004db:	83 e8 20             	sub    $0x20,%eax
  8004de:	83 f8 5e             	cmp    $0x5e,%eax
  8004e1:	76 10                	jbe    8004f3 <vprintfmt+0x213>
					putch('?', putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	ff 75 0c             	pushl  0xc(%ebp)
  8004e9:	6a 3f                	push   $0x3f
  8004eb:	ff 55 08             	call   *0x8(%ebp)
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	eb 0d                	jmp    800500 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	ff 75 0c             	pushl  0xc(%ebp)
  8004f9:	52                   	push   %edx
  8004fa:	ff 55 08             	call   *0x8(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800500:	83 eb 01             	sub    $0x1,%ebx
  800503:	eb 1a                	jmp    80051f <vprintfmt+0x23f>
  800505:	89 75 08             	mov    %esi,0x8(%ebp)
  800508:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80050b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800511:	eb 0c                	jmp    80051f <vprintfmt+0x23f>
  800513:	89 75 08             	mov    %esi,0x8(%ebp)
  800516:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800519:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051f:	83 c7 01             	add    $0x1,%edi
  800522:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800526:	0f be d0             	movsbl %al,%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 23                	je     800550 <vprintfmt+0x270>
  80052d:	85 f6                	test   %esi,%esi
  80052f:	78 a1                	js     8004d2 <vprintfmt+0x1f2>
  800531:	83 ee 01             	sub    $0x1,%esi
  800534:	79 9c                	jns    8004d2 <vprintfmt+0x1f2>
  800536:	89 df                	mov    %ebx,%edi
  800538:	8b 75 08             	mov    0x8(%ebp),%esi
  80053b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053e:	eb 18                	jmp    800558 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	53                   	push   %ebx
  800544:	6a 20                	push   $0x20
  800546:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	eb 08                	jmp    800558 <vprintfmt+0x278>
  800550:	89 df                	mov    %ebx,%edi
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800558:	85 ff                	test   %edi,%edi
  80055a:	7f e4                	jg     800540 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055f:	e9 a2 fd ff ff       	jmp    800306 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800564:	83 fa 01             	cmp    $0x1,%edx
  800567:	7e 16                	jle    80057f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 08             	lea    0x8(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 50 04             	mov    0x4(%eax),%edx
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80057d:	eb 32                	jmp    8005b1 <vprintfmt+0x2d1>
	else if (lflag)
  80057f:	85 d2                	test   %edx,%edx
  800581:	74 18                	je     80059b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800591:	89 c1                	mov    %eax,%ecx
  800593:	c1 f9 1f             	sar    $0x1f,%ecx
  800596:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800599:	eb 16                	jmp    8005b1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 50 04             	lea    0x4(%eax),%edx
  8005a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005a9:	89 c1                	mov    %eax,%ecx
  8005ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ae:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005b4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005bd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005c6:	0f 89 b0 00 00 00    	jns    80067c <vprintfmt+0x39c>
				putch('-', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	6a 2d                	push   $0x2d
  8005d2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005d7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005da:	f7 d8                	neg    %eax
  8005dc:	83 d2 00             	adc    $0x0,%edx
  8005df:	f7 da                	neg    %edx
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 88 00 00 00       	jmp    80067c <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f7:	e8 70 fc ff ff       	call   80026c <getuint>
  8005fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800607:	eb 73                	jmp    80067c <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800609:	8d 45 14             	lea    0x14(%ebp),%eax
  80060c:	e8 5b fc ff ff       	call   80026c <getuint>
  800611:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800614:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 58                	push   $0x58
  80061d:	ff d6                	call   *%esi
			putch('X', putdat);
  80061f:	83 c4 08             	add    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 58                	push   $0x58
  800625:	ff d6                	call   *%esi
			putch('X', putdat);
  800627:	83 c4 08             	add    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 58                	push   $0x58
  80062d:	ff d6                	call   *%esi
			goto number;
  80062f:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800632:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800637:	eb 43                	jmp    80067c <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 30                	push   $0x30
  80063f:	ff d6                	call   *%esi
			putch('x', putdat);
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 78                	push   $0x78
  800647:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	ba 00 00 00 00       	mov    $0x0,%edx
  800659:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065c:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800667:	eb 13                	jmp    80067c <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800669:	8d 45 14             	lea    0x14(%ebp),%eax
  80066c:	e8 fb fb ff ff       	call   80026c <getuint>
  800671:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800674:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067c:	83 ec 0c             	sub    $0xc,%esp
  80067f:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800683:	52                   	push   %edx
  800684:	ff 75 e0             	pushl  -0x20(%ebp)
  800687:	50                   	push   %eax
  800688:	ff 75 dc             	pushl  -0x24(%ebp)
  80068b:	ff 75 d8             	pushl  -0x28(%ebp)
  80068e:	89 da                	mov    %ebx,%edx
  800690:	89 f0                	mov    %esi,%eax
  800692:	e8 26 fb ff ff       	call   8001bd <printnum>
			break;
  800697:	83 c4 20             	add    $0x20,%esp
  80069a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069d:	e9 64 fc ff ff       	jmp    800306 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	51                   	push   %ecx
  8006a7:	ff d6                	call   *%esi
			break;
  8006a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006af:	e9 52 fc ff ff       	jmp    800306 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 25                	push   $0x25
  8006ba:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb 03                	jmp    8006c4 <vprintfmt+0x3e4>
  8006c1:	83 ef 01             	sub    $0x1,%edi
  8006c4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c8:	75 f7                	jne    8006c1 <vprintfmt+0x3e1>
  8006ca:	e9 37 fc ff ff       	jmp    800306 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d2:	5b                   	pop    %ebx
  8006d3:	5e                   	pop    %esi
  8006d4:	5f                   	pop    %edi
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	83 ec 18             	sub    $0x18,%esp
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	74 26                	je     80071e <vsnprintf+0x47>
  8006f8:	85 d2                	test   %edx,%edx
  8006fa:	7e 22                	jle    80071e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fc:	ff 75 14             	pushl  0x14(%ebp)
  8006ff:	ff 75 10             	pushl  0x10(%ebp)
  800702:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	68 a6 02 80 00       	push   $0x8002a6
  80070b:	e8 d0 fb ff ff       	call   8002e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800710:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800713:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	eb 05                	jmp    800723 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800723:	c9                   	leave  
  800724:	c3                   	ret    

00800725 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072e:	50                   	push   %eax
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	ff 75 08             	pushl  0x8(%ebp)
  800738:	e8 9a ff ff ff       	call   8006d7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    

0080073f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	eb 03                	jmp    80074f <strlen+0x10>
		n++;
  80074c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800753:	75 f7                	jne    80074c <strlen+0xd>
		n++;
	return n;
}
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	ba 00 00 00 00       	mov    $0x0,%edx
  800765:	eb 03                	jmp    80076a <strnlen+0x13>
		n++;
  800767:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076a:	39 c2                	cmp    %eax,%edx
  80076c:	74 08                	je     800776 <strnlen+0x1f>
  80076e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800772:	75 f3                	jne    800767 <strnlen+0x10>
  800774:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c2 01             	add    $0x1,%edx
  800787:	83 c1 01             	add    $0x1,%ecx
  80078a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800791:	84 db                	test   %bl,%bl
  800793:	75 ef                	jne    800784 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800795:	5b                   	pop    %ebx
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079f:	53                   	push   %ebx
  8007a0:	e8 9a ff ff ff       	call   80073f <strlen>
  8007a5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a8:	ff 75 0c             	pushl  0xc(%ebp)
  8007ab:	01 d8                	add    %ebx,%eax
  8007ad:	50                   	push   %eax
  8007ae:	e8 c5 ff ff ff       	call   800778 <strcpy>
	return dst;
}
  8007b3:	89 d8                	mov    %ebx,%eax
  8007b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c5:	89 f3                	mov    %esi,%ebx
  8007c7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ca:	89 f2                	mov    %esi,%edx
  8007cc:	eb 0f                	jmp    8007dd <strncpy+0x23>
		*dst++ = *src;
  8007ce:	83 c2 01             	add    $0x1,%edx
  8007d1:	0f b6 01             	movzbl (%ecx),%eax
  8007d4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007da:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	39 da                	cmp    %ebx,%edx
  8007df:	75 ed                	jne    8007ce <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e1:	89 f0                	mov    %esi,%eax
  8007e3:	5b                   	pop    %ebx
  8007e4:	5e                   	pop    %esi
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f2:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f7:	85 d2                	test   %edx,%edx
  8007f9:	74 21                	je     80081c <strlcpy+0x35>
  8007fb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ff:	89 f2                	mov    %esi,%edx
  800801:	eb 09                	jmp    80080c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800803:	83 c2 01             	add    $0x1,%edx
  800806:	83 c1 01             	add    $0x1,%ecx
  800809:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080c:	39 c2                	cmp    %eax,%edx
  80080e:	74 09                	je     800819 <strlcpy+0x32>
  800810:	0f b6 19             	movzbl (%ecx),%ebx
  800813:	84 db                	test   %bl,%bl
  800815:	75 ec                	jne    800803 <strlcpy+0x1c>
  800817:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800819:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081c:	29 f0                	sub    %esi,%eax
}
  80081e:	5b                   	pop    %ebx
  80081f:	5e                   	pop    %esi
  800820:	5d                   	pop    %ebp
  800821:	c3                   	ret    

00800822 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800828:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082b:	eb 06                	jmp    800833 <strcmp+0x11>
		p++, q++;
  80082d:	83 c1 01             	add    $0x1,%ecx
  800830:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800833:	0f b6 01             	movzbl (%ecx),%eax
  800836:	84 c0                	test   %al,%al
  800838:	74 04                	je     80083e <strcmp+0x1c>
  80083a:	3a 02                	cmp    (%edx),%al
  80083c:	74 ef                	je     80082d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083e:	0f b6 c0             	movzbl %al,%eax
  800841:	0f b6 12             	movzbl (%edx),%edx
  800844:	29 d0                	sub    %edx,%eax
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	8b 45 08             	mov    0x8(%ebp),%eax
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800852:	89 c3                	mov    %eax,%ebx
  800854:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800857:	eb 06                	jmp    80085f <strncmp+0x17>
		n--, p++, q++;
  800859:	83 c0 01             	add    $0x1,%eax
  80085c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085f:	39 d8                	cmp    %ebx,%eax
  800861:	74 15                	je     800878 <strncmp+0x30>
  800863:	0f b6 08             	movzbl (%eax),%ecx
  800866:	84 c9                	test   %cl,%cl
  800868:	74 04                	je     80086e <strncmp+0x26>
  80086a:	3a 0a                	cmp    (%edx),%cl
  80086c:	74 eb                	je     800859 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086e:	0f b6 00             	movzbl (%eax),%eax
  800871:	0f b6 12             	movzbl (%edx),%edx
  800874:	29 d0                	sub    %edx,%eax
  800876:	eb 05                	jmp    80087d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088a:	eb 07                	jmp    800893 <strchr+0x13>
		if (*s == c)
  80088c:	38 ca                	cmp    %cl,%dl
  80088e:	74 0f                	je     80089f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	0f b6 10             	movzbl (%eax),%edx
  800896:	84 d2                	test   %dl,%dl
  800898:	75 f2                	jne    80088c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ab:	eb 03                	jmp    8008b0 <strfind+0xf>
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b3:	38 ca                	cmp    %cl,%dl
  8008b5:	74 04                	je     8008bb <strfind+0x1a>
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	75 f2                	jne    8008ad <strfind+0xc>
			break;
	return (char *) s;
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c9:	85 c9                	test   %ecx,%ecx
  8008cb:	74 36                	je     800903 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d3:	75 28                	jne    8008fd <memset+0x40>
  8008d5:	f6 c1 03             	test   $0x3,%cl
  8008d8:	75 23                	jne    8008fd <memset+0x40>
		c &= 0xFF;
  8008da:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008de:	89 d3                	mov    %edx,%ebx
  8008e0:	c1 e3 08             	shl    $0x8,%ebx
  8008e3:	89 d6                	mov    %edx,%esi
  8008e5:	c1 e6 18             	shl    $0x18,%esi
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	c1 e0 10             	shl    $0x10,%eax
  8008ed:	09 f0                	or     %esi,%eax
  8008ef:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f1:	89 d8                	mov    %ebx,%eax
  8008f3:	09 d0                	or     %edx,%eax
  8008f5:	c1 e9 02             	shr    $0x2,%ecx
  8008f8:	fc                   	cld    
  8008f9:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fb:	eb 06                	jmp    800903 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800900:	fc                   	cld    
  800901:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800903:	89 f8                	mov    %edi,%eax
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5f                   	pop    %edi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	8b 75 0c             	mov    0xc(%ebp),%esi
  800915:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800918:	39 c6                	cmp    %eax,%esi
  80091a:	73 35                	jae    800951 <memmove+0x47>
  80091c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091f:	39 d0                	cmp    %edx,%eax
  800921:	73 2e                	jae    800951 <memmove+0x47>
		s += n;
		d += n;
  800923:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800926:	89 d6                	mov    %edx,%esi
  800928:	09 fe                	or     %edi,%esi
  80092a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800930:	75 13                	jne    800945 <memmove+0x3b>
  800932:	f6 c1 03             	test   $0x3,%cl
  800935:	75 0e                	jne    800945 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800937:	83 ef 04             	sub    $0x4,%edi
  80093a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093d:	c1 e9 02             	shr    $0x2,%ecx
  800940:	fd                   	std    
  800941:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800943:	eb 09                	jmp    80094e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800945:	83 ef 01             	sub    $0x1,%edi
  800948:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094b:	fd                   	std    
  80094c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094e:	fc                   	cld    
  80094f:	eb 1d                	jmp    80096e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800951:	89 f2                	mov    %esi,%edx
  800953:	09 c2                	or     %eax,%edx
  800955:	f6 c2 03             	test   $0x3,%dl
  800958:	75 0f                	jne    800969 <memmove+0x5f>
  80095a:	f6 c1 03             	test   $0x3,%cl
  80095d:	75 0a                	jne    800969 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095f:	c1 e9 02             	shr    $0x2,%ecx
  800962:	89 c7                	mov    %eax,%edi
  800964:	fc                   	cld    
  800965:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800967:	eb 05                	jmp    80096e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800969:	89 c7                	mov    %eax,%edi
  80096b:	fc                   	cld    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800975:	ff 75 10             	pushl  0x10(%ebp)
  800978:	ff 75 0c             	pushl  0xc(%ebp)
  80097b:	ff 75 08             	pushl  0x8(%ebp)
  80097e:	e8 87 ff ff ff       	call   80090a <memmove>
}
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800990:	89 c6                	mov    %eax,%esi
  800992:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800995:	eb 1a                	jmp    8009b1 <memcmp+0x2c>
		if (*s1 != *s2)
  800997:	0f b6 08             	movzbl (%eax),%ecx
  80099a:	0f b6 1a             	movzbl (%edx),%ebx
  80099d:	38 d9                	cmp    %bl,%cl
  80099f:	74 0a                	je     8009ab <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a1:	0f b6 c1             	movzbl %cl,%eax
  8009a4:	0f b6 db             	movzbl %bl,%ebx
  8009a7:	29 d8                	sub    %ebx,%eax
  8009a9:	eb 0f                	jmp    8009ba <memcmp+0x35>
		s1++, s2++;
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b1:	39 f0                	cmp    %esi,%eax
  8009b3:	75 e2                	jne    800997 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	53                   	push   %ebx
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c5:	89 c1                	mov    %eax,%ecx
  8009c7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ca:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ce:	eb 0a                	jmp    8009da <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d0:	0f b6 10             	movzbl (%eax),%edx
  8009d3:	39 da                	cmp    %ebx,%edx
  8009d5:	74 07                	je     8009de <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	39 c8                	cmp    %ecx,%eax
  8009dc:	72 f2                	jb     8009d0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009de:	5b                   	pop    %ebx
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	eb 03                	jmp    8009f2 <strtol+0x11>
		s++;
  8009ef:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	0f b6 01             	movzbl (%ecx),%eax
  8009f5:	3c 20                	cmp    $0x20,%al
  8009f7:	74 f6                	je     8009ef <strtol+0xe>
  8009f9:	3c 09                	cmp    $0x9,%al
  8009fb:	74 f2                	je     8009ef <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fd:	3c 2b                	cmp    $0x2b,%al
  8009ff:	75 0a                	jne    800a0b <strtol+0x2a>
		s++;
  800a01:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a04:	bf 00 00 00 00       	mov    $0x0,%edi
  800a09:	eb 11                	jmp    800a1c <strtol+0x3b>
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a10:	3c 2d                	cmp    $0x2d,%al
  800a12:	75 08                	jne    800a1c <strtol+0x3b>
		s++, neg = 1;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a22:	75 15                	jne    800a39 <strtol+0x58>
  800a24:	80 39 30             	cmpb   $0x30,(%ecx)
  800a27:	75 10                	jne    800a39 <strtol+0x58>
  800a29:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2d:	75 7c                	jne    800aab <strtol+0xca>
		s += 2, base = 16;
  800a2f:	83 c1 02             	add    $0x2,%ecx
  800a32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a37:	eb 16                	jmp    800a4f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a39:	85 db                	test   %ebx,%ebx
  800a3b:	75 12                	jne    800a4f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a42:	80 39 30             	cmpb   $0x30,(%ecx)
  800a45:	75 08                	jne    800a4f <strtol+0x6e>
		s++, base = 8;
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a57:	0f b6 11             	movzbl (%ecx),%edx
  800a5a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	80 fb 09             	cmp    $0x9,%bl
  800a62:	77 08                	ja     800a6c <strtol+0x8b>
			dig = *s - '0';
  800a64:	0f be d2             	movsbl %dl,%edx
  800a67:	83 ea 30             	sub    $0x30,%edx
  800a6a:	eb 22                	jmp    800a8e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6f:	89 f3                	mov    %esi,%ebx
  800a71:	80 fb 19             	cmp    $0x19,%bl
  800a74:	77 08                	ja     800a7e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a76:	0f be d2             	movsbl %dl,%edx
  800a79:	83 ea 57             	sub    $0x57,%edx
  800a7c:	eb 10                	jmp    800a8e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 19             	cmp    $0x19,%bl
  800a86:	77 16                	ja     800a9e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a88:	0f be d2             	movsbl %dl,%edx
  800a8b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a91:	7d 0b                	jge    800a9e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a93:	83 c1 01             	add    $0x1,%ecx
  800a96:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9c:	eb b9                	jmp    800a57 <strtol+0x76>

	if (endptr)
  800a9e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa2:	74 0d                	je     800ab1 <strtol+0xd0>
		*endptr = (char *) s;
  800aa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa7:	89 0e                	mov    %ecx,(%esi)
  800aa9:	eb 06                	jmp    800ab1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	74 98                	je     800a47 <strtol+0x66>
  800aaf:	eb 9e                	jmp    800a4f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab1:	89 c2                	mov    %eax,%edx
  800ab3:	f7 da                	neg    %edx
  800ab5:	85 ff                	test   %edi,%edi
  800ab7:	0f 45 c2             	cmovne %edx,%eax
}
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5f                   	pop    %edi
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ac5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad0:	89 c3                	mov    %eax,%ebx
  800ad2:	89 c7                	mov    %eax,%edi
  800ad4:	89 c6                	mov    %eax,%esi
  800ad6:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5f                   	pop    %edi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <sys_cgetc>:

int
sys_cgetc(void)
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
  800ae8:	b8 01 00 00 00       	mov    $0x1,%eax
  800aed:	89 d1                	mov    %edx,%ecx
  800aef:	89 d3                	mov    %edx,%ebx
  800af1:	89 d7                	mov    %edx,%edi
  800af3:	89 d6                	mov    %edx,%esi
  800af5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	89 cb                	mov    %ecx,%ebx
  800b14:	89 cf                	mov    %ecx,%edi
  800b16:	89 ce                	mov    %ecx,%esi
  800b18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	7e 17                	jle    800b35 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	50                   	push   %eax
  800b22:	6a 03                	push   $0x3
  800b24:	68 a4 16 80 00       	push   $0x8016a4
  800b29:	6a 23                	push   $0x23
  800b2b:	68 c1 16 80 00       	push   $0x8016c1
  800b30:	e8 07 05 00 00       	call   80103c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_yield>:

void
sys_yield(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b84:	be 00 00 00 00       	mov    $0x0,%esi
  800b89:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b97:	89 f7                	mov    %esi,%edi
  800b99:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9b:	85 c0                	test   %eax,%eax
  800b9d:	7e 17                	jle    800bb6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	50                   	push   %eax
  800ba3:	6a 04                	push   $0x4
  800ba5:	68 a4 16 80 00       	push   $0x8016a4
  800baa:	6a 23                	push   $0x23
  800bac:	68 c1 16 80 00       	push   $0x8016c1
  800bb1:	e8 86 04 00 00       	call   80103c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 05                	push   $0x5
  800be7:	68 a4 16 80 00       	push   $0x8016a4
  800bec:	6a 23                	push   $0x23
  800bee:	68 c1 16 80 00       	push   $0x8016c1
  800bf3:	e8 44 04 00 00       	call   80103c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c09:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c16:	8b 55 08             	mov    0x8(%ebp),%edx
  800c19:	89 df                	mov    %ebx,%edi
  800c1b:	89 de                	mov    %ebx,%esi
  800c1d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 06                	push   $0x6
  800c29:	68 a4 16 80 00       	push   $0x8016a4
  800c2e:	6a 23                	push   $0x23
  800c30:	68 c1 16 80 00       	push   $0x8016c1
  800c35:	e8 02 04 00 00       	call   80103c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 08 00 00 00       	mov    $0x8,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 08                	push   $0x8
  800c6b:	68 a4 16 80 00       	push   $0x8016a4
  800c70:	6a 23                	push   $0x23
  800c72:	68 c1 16 80 00       	push   $0x8016c1
  800c77:	e8 c0 03 00 00       	call   80103c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 09 00 00 00       	mov    $0x9,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 09                	push   $0x9
  800cad:	68 a4 16 80 00       	push   $0x8016a4
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 c1 16 80 00       	push   $0x8016c1
  800cb9:	e8 7e 03 00 00       	call   80103c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800cf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 cb                	mov    %ecx,%ebx
  800d01:	89 cf                	mov    %ecx,%edi
  800d03:	89 ce                	mov    %ecx,%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 0c                	push   $0xc
  800d11:	68 a4 16 80 00       	push   $0x8016a4
  800d16:	6a 23                	push   $0x23
  800d18:	68 c1 16 80 00       	push   $0x8016c1
  800d1d:	e8 1a 03 00 00       	call   80103c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 04             	sub    $0x4,%esp
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800d34:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800d36:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800d3a:	74 2e                	je     800d6a <pgfault+0x40>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	c1 ea 16             	shr    $0x16,%edx
  800d41:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
  800d48:	f6 c2 01             	test   $0x1,%dl
  800d4b:	74 1d                	je     800d6a <pgfault+0x40>
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
  800d4d:	89 c2                	mov    %eax,%edx
  800d4f:	c1 ea 0c             	shr    $0xc,%edx
  800d52:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800d59:	f6 c1 01             	test   $0x1,%cl
  800d5c:	74 0c                	je     800d6a <pgfault+0x40>
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800d5e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800d65:	f6 c6 08             	test   $0x8,%dh
  800d68:	75 14                	jne    800d7e <pgfault+0x54>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800d6a:	83 ec 04             	sub    $0x4,%esp
  800d6d:	68 cf 16 80 00       	push   $0x8016cf
  800d72:	6a 22                	push   $0x22
  800d74:	68 e5 16 80 00       	push   $0x8016e5
  800d79:	e8 be 02 00 00       	call   80103c <_panic>
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800d7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d83:	89 c3                	mov    %eax,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	6a 07                	push   $0x7
  800d8a:	68 00 f0 7f 00       	push   $0x7ff000
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 e5 fd ff ff       	call   800b7b <sys_page_alloc>
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	79 14                	jns    800db1 <pgfault+0x87>
		panic("sys_page_alloc");
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	68 f0 16 80 00       	push   $0x8016f0
  800da5:	6a 2f                	push   $0x2f
  800da7:	68 e5 16 80 00       	push   $0x8016e5
  800dac:	e8 8b 02 00 00       	call   80103c <_panic>
	}
	memcpy(PFTEMP, addr, PGSIZE);
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	68 00 10 00 00       	push   $0x1000
  800db9:	53                   	push   %ebx
  800dba:	68 00 f0 7f 00       	push   $0x7ff000
  800dbf:	e8 ae fb ff ff       	call   800972 <memcpy>
	
	retv = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P);
  800dc4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800dcb:	53                   	push   %ebx
  800dcc:	6a 00                	push   $0x0
  800dce:	68 00 f0 7f 00       	push   $0x7ff000
  800dd3:	6a 00                	push   $0x0
  800dd5:	e8 e4 fd ff ff       	call   800bbe <sys_page_map>
	if(retv < 0){
  800dda:	83 c4 20             	add    $0x20,%esp
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	79 14                	jns    800df5 <pgfault+0xcb>
		panic("sys_page_map");
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	68 ff 16 80 00       	push   $0x8016ff
  800de9:	6a 35                	push   $0x35
  800deb:	68 e5 16 80 00       	push   $0x8016e5
  800df0:	e8 47 02 00 00       	call   80103c <_panic>
	}
	return;
	panic("pgfault not implemented");
}
  800df5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    

00800dfa <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 28             	sub    $0x28,%esp
	cprintf("\t\t we are in the fork().\n");
  800e03:	68 0c 17 80 00       	push   $0x80170c
  800e08:	e8 9c f3 ff ff       	call   8001a9 <cprintf>
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800e0d:	c7 04 24 2a 0d 80 00 	movl   $0x800d2a,(%esp)
  800e14:	e8 69 02 00 00       	call   801082 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e19:	b8 07 00 00 00       	mov    $0x7,%eax
  800e1e:	cd 30                	int    $0x30
  800e20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	//create a child
	child_envid = sys_exofork();
	if(child_envid < 0 ){
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	85 c0                	test   %eax,%eax
  800e28:	79 14                	jns    800e3e <fork+0x44>
		panic("sys_exofork failed.");
  800e2a:	83 ec 04             	sub    $0x4,%esp
  800e2d:	68 26 17 80 00       	push   $0x801726
  800e32:	6a 7d                	push   $0x7d
  800e34:	68 e5 16 80 00       	push   $0x8016e5
  800e39:	e8 fe 01 00 00       	call   80103c <_panic>
  800e3e:	89 c7                	mov    %eax,%edi
  800e40:	bb 00 00 00 00       	mov    $0x0,%ebx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800e45:	89 d8                	mov    %ebx,%eax
  800e47:	c1 e8 16             	shr    $0x16,%eax
  800e4a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800e51:	a8 01                	test   $0x1,%al
  800e53:	0f 84 db 00 00 00    	je     800f34 <fork+0x13a>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800e59:	89 d8                	mov    %ebx,%eax
  800e5b:	c1 e8 0c             	shr    $0xc,%eax
  800e5e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800e65:	f6 c2 01             	test   $0x1,%dl
  800e68:	0f 84 c6 00 00 00    	je     800f34 <fork+0x13a>
			(uvpt[PGNUM(addr)] & PTE_P)&& 
			(uvpt[PGNUM(addr)] & PTE_U)
  800e6e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800e75:	f6 c2 04             	test   $0x4,%dl
  800e78:	0f 84 b6 00 00 00    	je     800f34 <fork+0x13a>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;

	// LAB 4: Your code here.
	void *addr = (void*)(pn*PGSIZE);
  800e7e:	89 c6                	mov    %eax,%esi
  800e80:	c1 e6 0c             	shl    $0xc,%esi
	if( (uvpt[pn] & PTE_W)||(uvpt[pn]) & PTE_COW ){
  800e83:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800e8a:	f6 c2 02             	test   $0x2,%dl
  800e8d:	75 0c                	jne    800e9b <fork+0xa1>
  800e8f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e96:	f6 c4 08             	test   $0x8,%ah
  800e99:	74 77                	je     800f12 <fork+0x118>
		
		r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_P|PTE_U);
  800e9b:	83 ec 0c             	sub    $0xc,%esp
  800e9e:	68 05 08 00 00       	push   $0x805
  800ea3:	56                   	push   %esi
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 11 fd ff ff       	call   800bbe <sys_page_map>
		if(r<0){
  800ead:	83 c4 20             	add    $0x20,%esp
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	79 22                	jns    800ed6 <fork+0xdc>
			cprintf("sys_page_map failed :%d\n",r);
  800eb4:	83 ec 08             	sub    $0x8,%esp
  800eb7:	50                   	push   %eax
  800eb8:	68 3a 17 80 00       	push   $0x80173a
  800ebd:	e8 e7 f2 ff ff       	call   8001a9 <cprintf>
			panic("map env id 0 to child_envid failed.");
  800ec2:	83 c4 0c             	add    $0xc,%esp
  800ec5:	68 b4 17 80 00       	push   $0x8017b4
  800eca:	6a 52                	push   $0x52
  800ecc:	68 e5 16 80 00       	push   $0x8016e5
  800ed1:	e8 66 01 00 00       	call   80103c <_panic>
		
		}
		r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_P|PTE_U);
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	68 05 08 00 00       	push   $0x805
  800ede:	56                   	push   %esi
  800edf:	6a 00                	push   $0x0
  800ee1:	56                   	push   %esi
  800ee2:	6a 00                	push   $0x0
  800ee4:	e8 d5 fc ff ff       	call   800bbe <sys_page_map>
		if(r<0){
  800ee9:	83 c4 20             	add    $0x20,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	79 34                	jns    800f24 <fork+0x12a>
			cprintf("sys_page_map failed :%d\n",r);
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	50                   	push   %eax
  800ef4:	68 3a 17 80 00       	push   $0x80173a
  800ef9:	e8 ab f2 ff ff       	call   8001a9 <cprintf>
			panic("map env id 0 to 0");
  800efe:	83 c4 0c             	add    $0xc,%esp
  800f01:	68 53 17 80 00       	push   $0x801753
  800f06:	6a 58                	push   $0x58
  800f08:	68 e5 16 80 00       	push   $0x8016e5
  800f0d:	e8 2a 01 00 00       	call   80103c <_panic>
		}//?we should mark PTE_COW both to two id.
	}else{
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	6a 05                	push   $0x5
  800f17:	56                   	push   %esi
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	6a 00                	push   $0x0
  800f1c:	e8 9d fc ff ff       	call   800bbe <sys_page_map>
  800f21:	83 c4 20             	add    $0x20,%esp
	}
	cprintf("1.");
  800f24:	83 ec 0c             	sub    $0xc,%esp
  800f27:	68 65 17 80 00       	push   $0x801765
  800f2c:	e8 78 f2 ff ff       	call   8001a9 <cprintf>
  800f31:	83 c4 10             	add    $0x10,%esp
	if(child_envid < 0 ){
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800f34:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f3a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f40:	0f 85 ff fe ff ff    	jne    800e45 <fork+0x4b>
	 	    }	
	}
	//panic("failed at duppage.");
	//set up a user exception stack for pgfault() to run.
	int retv = 0;
	retv = sys_page_alloc(child_envid, (void*)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P);
  800f46:	83 ec 04             	sub    $0x4,%esp
  800f49:	6a 07                	push   $0x7
  800f4b:	68 00 f0 bf ee       	push   $0xeebff000
  800f50:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f53:	e8 23 fc ff ff       	call   800b7b <sys_page_alloc>
	if(retv < 0){
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	79 17                	jns    800f76 <fork+0x17c>
		panic("sys_page_alloc failed.\n");
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	68 68 17 80 00       	push   $0x801768
  800f67:	68 8f 00 00 00       	push   $0x8f
  800f6c:	68 e5 16 80 00       	push   $0x8016e5
  800f71:	e8 c6 00 00 00       	call   80103c <_panic>
	}
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(child_envid, _pgfault_upcall);
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	68 49 11 80 00       	push   $0x801149
  800f7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f81:	57                   	push   %edi
  800f82:	e8 fd fc ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
	retv = sys_env_set_status(child_envid, ENV_RUNNABLE);
  800f87:	83 c4 08             	add    $0x8,%esp
  800f8a:	6a 02                	push   $0x2
  800f8c:	57                   	push   %edi
  800f8d:	e8 b0 fc ff ff       	call   800c42 <sys_env_set_status>
	if(retv < 0){
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 17                	jns    800fb0 <fork+0x1b6>
		panic("sys_env_set_status failed.\n");
  800f99:	83 ec 04             	sub    $0x4,%esp
  800f9c:	68 80 17 80 00       	push   $0x801780
  800fa1:	68 95 00 00 00       	push   $0x95
  800fa6:	68 e5 16 80 00       	push   $0x8016e5
  800fab:	e8 8c 00 00 00       	call   80103c <_panic>
	}
	return child_envid;
	panic("fork not implemented");
}
  800fb0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <sfork>:

// Challenge!
int
sfork(void)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fc1:	68 9c 17 80 00       	push   $0x80179c
  800fc6:	68 9f 00 00 00       	push   $0x9f
  800fcb:	68 e5 16 80 00       	push   $0x8016e5
  800fd0:	e8 67 00 00 00       	call   80103c <_panic>

00800fd5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800fdb:	68 d8 17 80 00       	push   $0x8017d8
  800fe0:	6a 1a                	push   $0x1a
  800fe2:	68 f1 17 80 00       	push   $0x8017f1
  800fe7:	e8 50 00 00 00       	call   80103c <_panic>

00800fec <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800ff2:	68 fb 17 80 00       	push   $0x8017fb
  800ff7:	6a 2a                	push   $0x2a
  800ff9:	68 f1 17 80 00       	push   $0x8017f1
  800ffe:	e8 39 00 00 00       	call   80103c <_panic>

00801003 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80100e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801011:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801017:	8b 52 50             	mov    0x50(%edx),%edx
  80101a:	39 ca                	cmp    %ecx,%edx
  80101c:	75 0d                	jne    80102b <ipc_find_env+0x28>
			return envs[i].env_id;
  80101e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801021:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801026:	8b 40 48             	mov    0x48(%eax),%eax
  801029:	eb 0f                	jmp    80103a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80102b:	83 c0 01             	add    $0x1,%eax
  80102e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801033:	75 d9                	jne    80100e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    

0080103c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	56                   	push   %esi
  801040:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801041:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801044:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80104a:	e8 ee fa ff ff       	call   800b3d <sys_getenvid>
  80104f:	83 ec 0c             	sub    $0xc,%esp
  801052:	ff 75 0c             	pushl  0xc(%ebp)
  801055:	ff 75 08             	pushl  0x8(%ebp)
  801058:	56                   	push   %esi
  801059:	50                   	push   %eax
  80105a:	68 14 18 80 00       	push   $0x801814
  80105f:	e8 45 f1 ff ff       	call   8001a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801064:	83 c4 18             	add    $0x18,%esp
  801067:	53                   	push   %ebx
  801068:	ff 75 10             	pushl  0x10(%ebp)
  80106b:	e8 e8 f0 ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  801070:	c7 04 24 24 17 80 00 	movl   $0x801724,(%esp)
  801077:	e8 2d f1 ff ff       	call   8001a9 <cprintf>
  80107c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107f:	cc                   	int3   
  801080:	eb fd                	jmp    80107f <_panic+0x43>

00801082 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  801088:	68 38 18 80 00       	push   $0x801838
  80108d:	e8 17 f1 ff ff       	call   8001a9 <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80109c:	0f 85 8d 00 00 00    	jne    80112f <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	68 58 18 80 00       	push   $0x801858
  8010aa:	e8 fa f0 ff ff       	call   8001a9 <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  8010af:	a1 04 20 80 00       	mov    0x802004,%eax
  8010b4:	8b 40 48             	mov    0x48(%eax),%eax
  8010b7:	83 c4 0c             	add    $0xc,%esp
  8010ba:	6a 07                	push   $0x7
  8010bc:	68 00 f0 bf ee       	push   $0xeebff000
  8010c1:	50                   	push   %eax
  8010c2:	e8 b4 fa ff ff       	call   800b7b <sys_page_alloc>
		if(retv != 0){
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	85 c0                	test   %eax,%eax
  8010cc:	74 14                	je     8010e2 <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	68 7c 18 80 00       	push   $0x80187c
  8010d6:	6a 27                	push   $0x27
  8010d8:	68 d0 18 80 00       	push   $0x8018d0
  8010dd:	e8 5a ff ff ff       	call   80103c <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	68 49 11 80 00       	push   $0x801149
  8010ea:	68 de 18 80 00       	push   $0x8018de
  8010ef:	e8 b5 f0 ff ff       	call   8001a9 <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  8010f4:	a1 04 20 80 00       	mov    0x802004,%eax
  8010f9:	8b 40 48             	mov    0x48(%eax),%eax
  8010fc:	83 c4 08             	add    $0x8,%esp
  8010ff:	50                   	push   %eax
  801100:	68 f9 18 80 00       	push   $0x8018f9
  801105:	e8 9f f0 ff ff       	call   8001a9 <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80110a:	a1 04 20 80 00       	mov    0x802004,%eax
  80110f:	8b 40 48             	mov    0x48(%eax),%eax
  801112:	83 c4 08             	add    $0x8,%esp
  801115:	68 49 11 80 00       	push   $0x801149
  80111a:	50                   	push   %eax
  80111b:	e8 64 fb ff ff       	call   800c84 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  801120:	c7 04 24 10 19 80 00 	movl   $0x801910,(%esp)
  801127:	e8 7d f0 ff ff       	call   8001a9 <cprintf>
  80112c:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  80112f:	83 ec 0c             	sub    $0xc,%esp
  801132:	68 a8 18 80 00       	push   $0x8018a8
  801137:	e8 6d f0 ff ff       	call   8001a9 <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80113c:	8b 45 08             	mov    0x8(%ebp),%eax
  80113f:	a3 08 20 80 00       	mov    %eax,0x802008

}
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801149:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80114a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80114f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801151:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  801154:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  801156:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  80115a:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  80115e:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  80115f:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  801161:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  801168:	00 
	popl %eax
  801169:	58                   	pop    %eax
	popl %eax
  80116a:	58                   	pop    %eax
	popal
  80116b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  80116c:	83 c4 04             	add    $0x4,%esp
	popfl
  80116f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801170:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801171:	c3                   	ret    
  801172:	66 90                	xchg   %ax,%ax
  801174:	66 90                	xchg   %ax,%ax
  801176:	66 90                	xchg   %ax,%ax
  801178:	66 90                	xchg   %ax,%ax
  80117a:	66 90                	xchg   %ax,%ax
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
